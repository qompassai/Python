#!/usr/bin/env python3
import csv

def export_csv(ordered_addresses: list[str], output_path: str):
    with open(output_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["stop", "address"])
        for i, addr in enumerate(ordered_addresses, 1):
            writer.writerow([i, addr])

def build_maps_url(ordered_addresses: list[str]) -> str:
    base = "https://www.google.com/maps/dir/"
    return base + "/".join(a.replace(" ", "+") for a in ordered_addresses)
