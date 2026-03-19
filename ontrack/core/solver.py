#!/usr/bin/env python3
"""
solver.py — TSP/VRP route solver for OnTrack using Google OR-Tools.
Accepts the NxN duration matrix from matrix.py and returns an ordered
list of addresses optimized for minimum travel time.
"""

from dataclasses import dataclass
from ortools.constraint_solver import routing_enums_pb2, pywrapcp


@dataclass
class RouteResult:
    ordered_addresses: list[str]
    ordered_indices: list[int]
    total_duration_seconds: float
    dropped_nodes: list[int]  # indices of stops OR-Tools could not fit


def _scale_matrix(matrix: list[list[float]], scale: int = 1) -> list[list[int]]:
    """
    OR-Tools requires integer costs. Convert float seconds → int.
    Use scale=60 to work in minutes for large matrices (avoids int overflow).
    """
    return [[int(matrix[i][j] / scale) for j in range(len(matrix))] for i in range(len(matrix))]


def _create_data_model(
    matrix: list[list[float]],
    depot_index: int,
    num_vehicles: int,
    max_duration_per_vehicle: int | None,
    scale: int,
) -> dict:
    return {
        "matrix": _scale_matrix(matrix, scale),
        "num_vehicles": num_vehicles,
        "depot": depot_index,
        "max_duration": max_duration_per_vehicle,
    }


def _extract_route(
    manager: pywrapcp.RoutingIndexManager,
    routing: pywrapcp.RoutingModel,
    solution: pywrapcp.Assignment,
    locations: list[dict],
    num_vehicles: int,
    time_dim_name: str,
    scale: int,
) -> RouteResult:
    """Pull the best route for vehicle 0 (single-vehicle TSP default)."""
    all_ordered_indices: list[int] = []
    total_duration = 0.0

    for vehicle_id in range(num_vehicles):
        index = routing.Start(vehicle_id)
        while not routing.IsEnd(index):
            node = manager.IndexToNode(index)
            all_ordered_indices.append(node)
            index = solution.Value(routing.NextVar(index))

    time_dim = routing.GetDimensionOrDie(time_dim_name)
    end_index = routing.End(0)
    total_duration = solution.Value(time_dim.CumulVar(end_index)) * scale

    dropped = [
        manager.IndexToNode(routing.Start(v))
        for v in range(num_vehicles)
        if routing.IsVehicleUsed(solution, v) is False
    ]
    for node in range(routing.Size()):
        if routing.IsStart(node) or routing.IsEnd(node):
            continue
        if solution.Value(routing.NextVar(node)) == node:
            dropped.append(manager.IndexToNode(node))

    ordered_addresses = [locations[i]["address"] for i in all_ordered_indices]

    return RouteResult(
        ordered_addresses=ordered_addresses,
        ordered_indices=all_ordered_indices,
        total_duration_seconds=total_duration,
        dropped_nodes=dropped,
    )


def solve_tsp(
    locations: list[dict],
    matrix: list[list[float]],
    depot_index: int = 0,
    num_vehicles: int = 1,
    max_duration_seconds: int | None = None,
    time_limit_seconds: int = 30,
    scale: int = 1,
) -> RouteResult:
    """
    Solve the Travelling Salesman Problem (or multi-vehicle VRP) for OnTrack.

    Args:
        locations:             Geocoded location dicts (output of geocoder.py).
                               Must match the order used to build `matrix`.
        matrix:                NxN duration matrix (output of matrix.build_distance_matrix()).
        depot_index:           Index of the starting/ending depot location.
        num_vehicles:          Number of vehicles (1 = pure TSP, >1 = VRP).
        max_duration_seconds:  Optional hard cap on total route time per vehicle.
        time_limit_seconds:    OR-Tools search time budget.
        scale:                 Divide matrix values by this before passing to OR-Tools.
                               Use 60 for minute-resolution on large matrices.

    Returns:
        RouteResult dataclass with ordered addresses, indices, total duration,
        and any nodes OR-Tools could not fit into the route.

    Raises:
        ValueError: Mismatched locations/matrix dimensions or empty input.
        RuntimeError: OR-Tools failed to find any feasible solution.
    """
    n = len(locations)
    if n == 0:
        raise ValueError("No locations provided.")
    if len(matrix) != n or any(len(row) != n for row in matrix):
        raise ValueError(
            f"Matrix shape {len(matrix)}x{len(matrix[0]) if matrix else 0} "
            f"does not match locations count {n}."
        )
    if not (0 <= depot_index < n):
        raise ValueError(f"depot_index {depot_index} out of range [0, {n}).")

    data = _create_data_model(matrix, depot_index, num_vehicles, max_duration_seconds, scale)

    manager = pywrapcp.RoutingIndexManager(n, data["num_vehicles"], data["depot"])
    routing = pywrapcp.RoutingModel(manager)

    def transit_callback(from_index: int, to_index: int) -> int:
        i = manager.IndexToNode(from_index)
        j = manager.IndexToNode(to_index)
        return data["matrix"][i][j]

    transit_cb_idx = routing.RegisterTransitCallback(transit_callback)
    routing.SetArcCostEvaluatorOfAllVehicles(transit_cb_idx)

    dim_name = "Duration"
    max_route_duration = (
        int(data["max_duration"] / scale)
        if data["max_duration"]
        else int(sum(data["matrix"][i][j] for i in range(n) for j in range(n)))
    )
    routing.AddDimension(
        transit_cb_idx,
        0,
        max_route_duration,
        True,
        dim_name,
    )

    penalty = max_route_duration * 10
    for node in range(1, n):
        routing.AddDisjunction([manager.NodeToIndex(node)], penalty)

    search_params = pywrapcp.DefaultRoutingSearchParameters()
    search_params.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
    )
    search_params.local_search_metaheuristic = (
        routing_enums_pb2.LocalSearchMetaheuristic.GUIDED_LOCAL_SEARCH
    )
    search_params.time_limit.seconds = time_limit_seconds
    search_params.log_search = False

    solution = routing.SolveWithParameters(search_params)

    if not solution:
        raise RuntimeError(
            "OR-Tools could not find a feasible solution. "
            "Try increasing time_limit_seconds or relaxing max_duration_seconds."
        )

    return _extract_route(manager, routing, solution, locations, num_vehicles, dim_name, scale)


def solve_open_tsp(
    locations: list[dict],
    matrix: list[list[float]],
    start_index: int = 0,
    **kwargs,
) -> RouteResult:
    """
    Solve an open TSP where the driver does not return to the start.
    Adds a dummy sink node with zero-cost edges from every real node.
    """
    n = len(locations)

    # Append a zero-cost dummy destination row/col
    open_matrix = [row + [0] for row in matrix] + [[0] * (n + 1)]
    dummy_loc = {"address": "__end__", "lat": None, "lng": None}
    open_locations = locations + [dummy_loc]

    result = solve_tsp(
        open_locations,
        open_matrix,
        depot_index=start_index,
        **kwargs,
    )

    # Strip the dummy sink from output
    result.ordered_addresses = [a for a in result.ordered_addresses if a != "__end__"]
    result.ordered_indices = [i for i in result.ordered_indices if i != n]
    return result

