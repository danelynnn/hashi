from flask import Flask, request

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.select import Select

from html.parser import HTMLParser

import numpy as np
import json
from random import randint

app = Flask(__name__)

options = Options()
options.page_load_strategy = 'eager'
options.add_argument('--headless=new')
driver = webdriver.Firefox(options=options)


def loadPuzzle(puzzleType, puzzleId):
    global driver

    if puzzleId == -1:
        driver.get("https://www.puzzle-bridges.com")
        
        sizes = ["7x7-easy",
            "7x7-normal",
            "7x7-hard",
            "10x10-easy",
            "10x10-normal",
            "10x10-hard",
            "15x150-easy",
            "15x15-normal",
            "15x15-hard",
            "25x25-easy",
            "25x25-normal",
            "25x25-hard",
            None,
            None,
            None,
            "7x7-dense",
            "10x10-dense",
            "15x15-dense",
            "25x25-dense"]
        menu = driver.find_element(By.ID, 'menuSizes')
        difficulty = driver.find_element(By.CSS_SELECTOR, f"[mvvm-class*='{sizes[int(puzzleType)]}']")
        difficulty.click()
    else:
        driver.get("https://www.puzzle-bridges.com/specific.php")

        size = Select(driver.find_element(By.ID, 'size'))
        size.select_by_value(puzzleType)

        specId = driver.find_element(By.ID, 'specid')
        specId.send_keys(puzzleId)

        form = driver.find_element(By.CLASS_NAME, 'specific-form')
        submit = form.find_element(By.TAG_NAME, 'puzzle-button')
        submit.click()

    id = -1
    source = ""

    try:
        board = driver.find_element(By.ID, 'puzzleID')
        id = board.get_attribute('innerHTML')

        board = driver.find_element(By.CLASS_NAME, 'board-tasks')
        source = board.get_attribute('outerHTML')
    except:
        print("error?")
        with open('out.html', 'w') as file:
            file.write(str(driver.page_source.encode("utf-8", errors="ignore")))

    # driver.close()
    return id, source

class GameReader(HTMLParser):
    def parse_style(self, style):
        dic = {}
        style = style.split(';')
        for tag in style:
            try:
                key, value = tag.split(':')
                dic[key.strip()] = value.strip()
            except:
                pass
        
        return dic
    
    def parse_int(self, string):
        return int(''.join([c for c in string if c.isdigit()]))

    def handle_starttag(self, tag, attrs):
        attrs = {tup[0]: tup[1] for tup in attrs}

        if tag == 'div' and 'board-tasks' in attrs['class']:
            style = self.parse_style(attrs['style'])
            w = self.parse_int(style['width'])
            h = self.parse_int(style['height'])
            self.board = np.zeros((w, h), dtype=int)
        if tag == 'div' and 'bridges-task-cell' in attrs['class']:
            style = self.parse_style(attrs['style'])
            self.x = self.parse_int(style['left'])
            self.y = self.parse_int(style['top'])
    
    def handle_data(self, data):
        if self.x > -1 and self.y > -1:
            self.board[self.y, self.x] = int(data)
            self.x = -1
            self.y = -1
        return
            

@app.route('/get_puzzle/<puzzleType>')
def getPuzzle(puzzleType):
    id = request.args.get('id', -1)
    id, source = loadPuzzle(puzzleType, id)
    if not source:
        return {'id': str(id), 'board': ''}

    reader = GameReader()
    reader.feed(source)

    puzzleType = int(puzzleType)
    if 0 <= puzzleType <= 2 or puzzleType == 15:
        step = 7
    elif 3 <= puzzleType <= 5 or puzzleType == 16:
        step = 10
    elif 6 <= puzzleType <= 8 or puzzleType == 17:
        step = 15
    else:
        step = 25

    idx = np.linspace(0, reader.board.shape[0], step, endpoint=False, dtype=int)
    compressed = reader.board[idx, :][:, idx]
    print(compressed)

    flat = compressed.flatten()

    lst = []
    counter = 0
    for i in range(flat.shape[0]):
        if flat[i] == 0:
            counter += 1
        else:
            if counter > 0:
                lst.append(chr(ord('a') + counter - 1))
                counter = 0
            lst.append(str(flat[i]))

    return json.dumps({'id': id, 'board': ''.join(lst)})

if __name__ == "__main__":
    app.run(debug=True)
