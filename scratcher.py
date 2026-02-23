from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service
import argparse

parser = argparse.ArgumentParser(prog='scratcher')
parser.add_argument('-d', '--driver', default=False)
args = parser.parse_args()
driver_loc = args.driver

url = "https://51cg.fun"

options = webdriver.FirefoxOptions()
options.add_argument("--headless")
ser = Service()
if driver_loc:
    ser.executable_path=driver_loc

def create_driver():
    return webdriver.Firefox(service=ser, options=options)

# Get an entry to the website
driver1 = create_driver()
driver1.get(url)
entries = driver1.find_elements(By.XPATH, "//*[@id=\"list-wrap\"]/a")
entry = entries[0].get_attribute('href')
driver1.close()

# Open the website and fetch all articles
driver2 = create_driver()
driver2.get(entry)
articles = driver2.find_elements(By.XPATH, "//a[contains(@href, '/archives/')]")

# fetch information
coll = []
for a in articles:
    text = ""
    titles = a.find_elements(By.XPATH, './/div/div[2]/div/h2')
    if len(titles) != 0:
        text = titles[0].text
    else:
        continue
    # url title date
    coll.append([a.get_attribute('href'), text, a.find_element(By.XPATH, ".//div/div[2]/div/div/span[2]").text])

print(len(coll))
for record in coll:
    print(*map(len, record))
    print(*record, end="", sep="")