#!/usr/bin/env python3
from geopy.geocoders import Nominatim

geolocator = Nominatim(user_agent="ontrack")

def geocode_addresses(addresses: list[str]) -> list[dict]:
    """Convert addresses to lat/lng dicts."""
    results = []
    for addr in addresses:
        loc = geolocator.geocode(addr)
        if loc:
            results.append({"address": addr, "lat": loc.latitude, "lng": loc.longitude})
        else:
            results.append({"address": addr, "lat": None, "lng": None})
    return results
