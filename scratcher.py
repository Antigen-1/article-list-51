from selenium import webdriver
from selenium.webdriver.common.by import By

url = "https://51cg.fun"

options = webdriver.ChromeOptions()
options.add_argument("--headless")
options.add_argument("--disable-gpu")

# Get an entry to the website
driver1 = webdriver.Chrome(options=options)
driver1.get(url)
entries = driver1.find_elements(By.XPATH, "//*[@id=\"list-wrap\"]/a")
entry = entries[0].get_attribute('href')
driver1.close()

# Open the website and fetch all articles
driver2 = webdriver.Chrome(options=options)
driver2.get(entry)
articles = driver2.find_elements(By.XPATH, "//a[contains(@href, '/archives/')]")

# fetch information
table = {}
for a in articles:
    text = ""
    titles = a.find_elements(By.XPATH, './/div/div[2]/div/h2')
    if len(titles) != 0:
        text = titles[0].text
    else:
        continue
    table[a.get_attribute('href')] = text

for key, value in table.items():
    print(len(key), len(value))
    print(key, value, end="", sep="")