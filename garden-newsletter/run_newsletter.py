from github_data import fetch_github_data
from weather import fetch_weather
from newsletter import generate_newsletter


def run():
    github_data = fetch_github_data()
    weather_data = fetch_weather()
    output_file = generate_newsletter(github_data, weather_data)
    print(f"Newsletter generated at {output_file}")


if __name__ == "__main__":
    run()
