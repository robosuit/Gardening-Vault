import os
from dotenv import load_dotenv

load_dotenv()

#
# Configuration constants -- update these for your environment
#
GITHUB_REPO = os.getenv("GITHUB_REPO", "Anubis/Gardening-Vault")
GITHUB_BRANCH = os.getenv("GITHUB_BRANCH", "main")
GITHUB_FILE_PATH = os.getenv("GITHUB_FILE_PATH", "garden-data.json")

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

LOCATION = os.getenv("LOCATION", "Fuquay-Varina,NC")
WEATHER_API_KEY = os.getenv("WEATHER_API_KEY")

DESKTOP_PATH = os.path.join(os.path.expanduser("~"), "Desktop")
OUTPUT_FILE = os.path.join(DESKTOP_PATH, "Garden_Weekly_Report.txt")

# sample fallback data file used when APIs are unavailable
SAMPLE_GARDEN_PATH = os.path.join(os.path.dirname(__file__), "sample_garden.json")
SAMPLE_WEATHER_PATH = os.path.join(os.path.dirname(__file__), "sample_weather.json")
