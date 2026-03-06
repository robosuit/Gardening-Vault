import os
import requests
import base64
from config import (
    GITHUB_REPO,
    GITHUB_BRANCH,
    GITHUB_FILE_PATH,
    GITHUB_TOKEN,
    SAMPLE_GARDEN_PATH,
)


def fetch_github_data():
    """Attempt to pull the specified file from GitHub.  If the network
    request fails or there is no token configured, fall back to a local sample
    file so that the module can be exercised without credentials.
    """

    # if there is no token, skip the API call altogether
    if not GITHUB_TOKEN:
        return _load_local_sample()

    url = (
        f"https://api.github.com/repos/{GITHUB_REPO}/contents/{GITHUB_FILE_PATH}?ref={GITHUB_BRANCH}"
    )
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json",
    }

    try:
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        content = response.json().get("content", "")
        decoded = base64.b64decode(content).decode("utf-8")
        return decoded

    except Exception:
        # network failed or file not present; use a canned sample
        return _load_local_sample()


def _load_local_sample():
    if os.path.exists(SAMPLE_GARDEN_PATH):
        with open(SAMPLE_GARDEN_PATH, "r", encoding="utf-8") as f:
            return f.read()
    return "[no garden data available]"
