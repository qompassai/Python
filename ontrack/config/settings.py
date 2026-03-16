from dotenv import load_dotenv
import os

load_dotenv()

GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY", "")
OSRM_BASE_URL = os.getenv("OSRM_BASE_URL", "http://router.project-osrm.org")
