from p5 import *

def setup():
    size(720, 720)
    pass

def draw():
    background(255)

    noStroke()
    fill(255, 0, 0)
    circle(mouse_x, mouse_y, 60)

if __name__ == '__main__':
    run(frame_rate=30)
