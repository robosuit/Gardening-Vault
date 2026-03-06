from datetime import datetime
from config import OUTPUT_FILE


def generate_newsletter(github_data: str, weather_data: list) -> str:
    """Compose the newsletter text and write it to the configured output
    location.  Returns the path to the file that was written so tests can
    inspect it.
    """

    today = datetime.now().strftime("%Y-%m-%d")

    lines = []
    lines.append("=" * 38)
    lines.append(f"GARDEN WEEKLY REPORT - {today}")
    lines.append("=" * 38)
    lines.append("")

    lines.append("---- GARDEN DATA FROM REPO ----")
    lines.append("")
    lines.append(github_data.strip())
    lines.append("")

    lines.append("---- WEATHER FORECAST ----")
    lines.append("")

    for entry in weather_data[:14]:
        lines.append(f"{entry['time']} | {entry['temp']}°F | {entry['description']}")

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    return OUTPUT_FILE
