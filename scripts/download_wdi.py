import urllib.request
import json
import csv
import os

# Ensure data directory exists
os.makedirs("data", exist_ok=True)

# 1. Fetch country metadata (to get regions, income levels, and filter out aggregates)
country_meta_url = "http://api.worldbank.org/v2/country?format=json&per_page=300"
req = urllib.request.Request(country_meta_url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    meta_json = json.loads(resp.read().decode("utf-8"))

# meta_json[1] has country objects
countries = {}
for c in meta_json[1]:
    # Exclude aggregate regions (their region value is 'Aggregates')
    if c.get("region", {}).get("value") != "Aggregates" and c.get("id"):
        countries[c["id"]] = {
            "country_code": c["id"],
            "country_name": c["name"],
            "region": c.get("region", {}).get("value", ""),
            "income_group": c.get("incomeLevel", {}).get("value", "")
        }

print(f"Loaded metadata for {len(countries)} countries.")

# 2. Fetch GDP per capita (current US$): NY.GDP.PCAP.CD for year 2019
gdp_url = "http://api.worldbank.org/v2/country/all/indicator/NY.GDP.PCAP.CD?date=2019&format=json&per_page=300"
req = urllib.request.Request(gdp_url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    gdp_json = json.loads(resp.read().decode("utf-8"))

gdp_data = {}
for item in gdp_json[1]:
    cid = item.get("countryiso3code")
    val = item.get("value")
    if cid in countries and val is not None:
        gdp_data[cid] = round(val, 2)

# 3. Fetch Life Expectancy at birth (years): SP.DYN.LE00.IN for year 2019
life_url = "http://api.worldbank.org/v2/country/all/indicator/SP.DYN.LE00.IN?date=2019&format=json&per_page=300"
req = urllib.request.Request(life_url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    life_json = json.loads(resp.read().decode("utf-8"))

life_data = {}
for item in life_json[1]:
    cid = item.get("countryiso3code")
    val = item.get("value")
    if cid in countries and val is not None:
        life_data[cid] = round(val, 2)

# 4. Fetch Infant Mortality rate (per 1,000 live births): SP.DYN.IMRT.IN for year 2019
im_url = "http://api.worldbank.org/v2/country/all/indicator/SP.DYN.IMRT.IN?date=2019&format=json&per_page=300"
req = urllib.request.Request(im_url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    im_json = json.loads(resp.read().decode("utf-8"))

im_data = {}
for item in im_json[1]:
    cid = item.get("countryiso3code")
    val = item.get("value")
    if cid in countries and val is not None:
        im_data[cid] = round(val, 2)

# Write data/wdi_gdp.csv
with open("data/wdi_gdp.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["country_code", "country_name", "region", "income_group", "year", "gdppc"])
    for cid, meta in sorted(countries.items()):
        if cid in gdp_data:
            writer.writerow([
                cid,
                meta["country_name"],
                meta["region"],
                meta["income_group"],
                2019,
                gdp_data[cid]
            ])

# Write data/wdi_life_expectancy.csv
with open("data/wdi_life_expectancy.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["country_code", "country_name", "year", "life_exp", "infant_mort"])
    for cid, meta in sorted(countries.items()):
        if cid in life_data:
            writer.writerow([
                cid,
                meta["country_name"],
                2019,
                life_data[cid],
                im_data.get(cid, "")
            ])

print("Successfully saved data/wdi_gdp.csv and data/wdi_life_expectancy.csv")
