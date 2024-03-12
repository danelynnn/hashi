from p5 import *
from random import randint
from time import time
from statistics import mean

DEBUG_MODE = True

def randItem(lyst):
    return lyst[randint(0, len(lyst)-1)]

def randBetween(start, finish, direction):
    totalDistance = (finish - start).abso().maximum()
    if totalDistance == 0:
        return None
    elif totalDistance == 1:
        return start + direction
    return start + direction * randint(1, totalDistance-1)

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def __add__(self, p):
        return Point(self.x + p.x, self.y + p.y)
    
    def __sub__(self, p):
        return Point(self.x - p.x, self.y - p.y)
    
    def __mul__(self, x):
        return Point(self.x * x, self.y * x)
    
    def __truediv__(self, x):
        return Point(self.x / x, self.y / x)
    
    def abso(self):
        return Point(abs(self.x), abs(self.y))
    
    def maximum(self):
        return max(self.x, self.y)
    
    def unit(self):
        p_abs = self.abso()
        return p_abs / maximum(p_abs)
    
    def __str__(self):
        return '({0}, {1})'.format(self.x, self.y)
    
    def __eq__(self, other):
        return self.x == other.x and self.y == other.y
    
    def __hash__(self):
        return hash(self.x) + hash(self.y)

def unit(p):
    p_abs = abso(p)
    return divide(p_abs, max(p_abs))

class Hashi:
    class Island:
        def __init__(self, numBridges):
            self.numTotalBridges = numBridges
            self.numRemainingBridges = numBridges
    
    def in_bounds(self, p):
        return p.x >= 0 and p.x < self.grid_size and p.y >= 0 and p.y < self.grid_size
    
    def intersects_bridge(self, p):
        # Ensures given point does not intersect with a bridge
        def is_between_inclusive(a, b, c):
            return (a < b and b < c) or (c < b and b < a)

        for (start, end) in self.bridges:
            if (start.x == end.x):
                if start.x == p.x and is_between_inclusive(start.y, p.y, end.y):
                    return True
            elif (start.y == end.y):
                if start.y == p.y and is_between_inclusive(start.x, p.x, end.x):
                    return True
            else:
                raise Exception("Yo, what is this bridge? Start:{0}, End:{1}".format(start, end))
        return False
    
    def __init__(self, grid_size):
        self.grid_size = grid_size
        # self.grid = [[0 for x in range(grid_size)] for y in range(grid_size)]
        # self.grid[2][2] = self.Island(3)
        self.islands = {} # Dict[Point, Island]
        # self.islands[(2, 2)] = self.Island(3)
        self.bridges = []
        self.bridges2 = []
        
        self.init_game(10, .5, .5)
    
    def make_island(self):
        randIsland = randItem(list(self.islands.keys()))
        randDirection = randItem([Point(0, -1), Point(0, 1), Point(-1, 0), Point(1, 0)])
        
        # probe in direction
        furthestPoint = randIsland
        while self.in_bounds(furthestPoint):
            nextPoint = furthestPoint + randDirection
            
            if self.in_bounds(nextPoint) and nextPoint not in self.islands and not self.intersects_bridge(nextPoint):
                furthestPoint = nextPoint
            else:
                break
        
        newIsland = randBetween(randIsland, furthestPoint, randDirection)
        if DEBUG_MODE:
            print(f"created island from {randIsland}, in {randDirection} to {newIsland}")

        if newIsland:
            self.islands[randIsland].numTotalBridges += 1
            self.islands[newIsland] = self.islands.get(newIsland, self.Island(0))
            self.islands[newIsland].numTotalBridges += 1
            self.bridges.append((randIsland, newIsland))
            return newIsland
    
    def bridge_exists(self, a, b):
        result = False
        for bridge in self.bridges:
            if bridge[0] == a and bridge[1] == b or bridge[1] == a and bridge[0] == b:
                result = True
        
        return result
    
    def init_game(self, n, a, b):
        # step 1 - placement of the islands
        self.islands[Point(randint(0, self.grid_size-1), randint(0, self.grid_size-1))] = self.Island(0)
        
        num_islands = 0
        while num_islands < n-1:
            if (self.make_island()):
                num_islands += 1
        
        # step 2 - creating cycles
        for island in self.islands:
            # find closest unconnected island in every direction
            for direction in [Point(0, -1), Point(0, 1), Point(-1, 0), Point(1, 0)]:
                # find closest island
                closestIsland = None
                furthestPoint = island
                while self.in_bounds(furthestPoint):
                    nextPoint = furthestPoint + direction
            
                    if self.in_bounds(nextPoint) and not self.intersects_bridge(nextPoint) and not self.bridge_exists(island, nextPoint):
                        furthestPoint = nextPoint

                        if furthestPoint in self.islands:
                            closestIsland = furthestPoint
                            break
                    else:
                        break
                
                if closestIsland:
                    if DEBUG_MODE:
                        print(f'found connectable island, {island} to {closestIsland}')
                    self.islands[island].numTotalBridges += 1
                    self.islands[closestIsland].numTotalBridges += 1
                    self.bridges.append((island, closestIsland))
                    self.bridges2.append((island, closestIsland))
    
    def draw_game(self):
        for i in range(self.grid_size):
            for j in range(self.grid_size):
                stroke(200)
                stroke_weight(1)
                fill(255)
                rect(40+i*50, 40+j*50, 50, 50)
            
                if DEBUG_MODE:
                    noStroke()
                    fill(200)
                    text_align(LEFT, TOP)
                    text_size(11)
                    text(str(i), 40+i*50, 40+j*50+40)
                    text(str(j), 40+i*50+20, 40+j*50+20)
                    
                    stroke(0)
                    strokeWeight(5)
                    point(40+i*50, 40+j*50)
        
        for (island1, island2) in self.bridges:
            stroke(0)
            stroke_weight(2)
            line(40 + island1.x * 50, 40 + island1.y * 50, 40 + island2.x * 50, 40 + island2.y * 50)
        
        if DEBUG_MODE:
            for (island1, island2) in self.bridges2:
                stroke(255, 0, 0)
                stroke_weight(2)
                line(40 + island1.x * 50, 40 + island1.y * 50, 40 + island2.x * 50, 40 + island2.y * 50)
        
        for (loc, island) in self.islands.items():
            stroke(0)
            stroke_weight(2)
            fill(255)
            circle(40+loc.x*50, 40+loc.y*50, 30)

            noStroke()
            fill(0)
            text_align(CENTER, BOTTOM)
            text_size(20)
            text(str(island.numTotalBridges), 40+loc.x*50, 40+loc.y*50+10)

# def key_released():
#     global game
#     game.make_island()

def setup():
    global game
    game = Hashi(10)
    
    # Create the font
    # f = create_font("data/OperatorMono.ttf", 16)
    # text_font(f)
    text_align('CENTER')
    
    size(1280, 720)

frameRate = 0
lastFrame = time()
lastFrameRates = []

def draw():
    global game
    background(255)
    game.draw_game()

    global lastFrame
    timeDelta = time() - lastFrame
    lastFrame = time()
    frameRate = 1/timeDelta

    lastFrameRates.append(frameRate)
    if len(lastFrameRates) > 30:
        lastFrameRates.pop(0)

    noStroke()
    fill(0, 255, 0)
    text_align('RIGHT', 'BOTTOM')
    text(str(int(mean(lastFrameRates))), 710, 30)

if __name__ == '__main__':
    run(renderer='skia')
