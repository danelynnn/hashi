from flask import Flask

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

from html.parser import HTMLParser

import numpy as np
import json

app = Flask(__name__)

options = Options()
options.page_load_strategy = 'eager'
# options.add_argument('--headless=new')
driver = webdriver.Chrome(options=options)

def loadPuzzle(puzzleId):
    global driver
    driver.get("https://www.puzzle-bridges.com/specific.php")

    specId = driver.find_element(By.ID, 'specid')
    specId.send_keys(puzzleId)

    form = driver.find_element(By.CLASS_NAME, 'specific-form')
    submit = form.find_element(By.TAG_NAME, 'puzzle-button')
    submit.click()

    board = driver.find_element(By.CLASS_NAME, 'board-tasks')
    source = board.get_attribute('outerHTML')

    # driver.close()
    return source

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
            

@app.route('/get_puzzle/<puzzleId>')
def getPuzzle(puzzleId):
    source = loadPuzzle(puzzleId)
    reader = GameReader()
    reader.feed(source)

    idx = np.linspace(0, reader.board.shape[0], 7, endpoint=False, dtype=int)
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

    return json.dumps({'id': puzzleId, 'board': ''.join(lst)})

if __name__ == "__main__":
    app.run(debug=True)
