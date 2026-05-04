#!/usr/bin/env python3
import urllib.request
import sys
try:
    req = urllib.request.Request("http://wttr.in/?format=1", headers={"User-Agent": "curl/7.68.0"})
    with urllib.request.urlopen(req, timeout=5) as response:
        html = response.read().decode("utf-8").strip()
        if "Unknown" in html or "Sorry" in html or "<html" in html:
            print("Weather data not available")
        elif len(html) > 0:
            print(html)
        else:
            print("Weather data not available")
except Exception:
    print("Weather data not available")

