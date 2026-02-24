from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import argparse

parser = argparse.ArgumentParser(prog='scratcher')
parser.add_argument('-d', '--driver', required=True)
parser.add_argument('-c', '--chrome', required=True)
args = parser.parse_args()

url = "https://51cg.fun"

options = Options()
options.add_argument("--headless")
options.add_argument("--disable-gpu")
options.binary_location = args.chrome
ser = Service()
ser.path = args.driver

def create_driver():
    return webdriver.Chrome(service=ser, options=options)

# Get an entry to the website
driver1 = create_driver()
driver1.get(url)
entries = driver1.find_elements(By.XPATH, "//*[@id=\"list-wrap\"]/a")
entry = entries[0].get_attribute('href')
driver1.quit()

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
driver2.quit()

print(len(coll))
for record in coll:
    print(*map(len, record))
    print(*record, end="", sep="")