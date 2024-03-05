from copy import copy

def randItem(lyst):
    return lyst[randInt(len(lyst))]

def randInt(*argv):
    return int(random(*argv))

def randBetween(start, finish, direction):
    totalDistance = (finish - start).abso().maximum()
    if totalDistance == 0:
        return None
    return start + direction * randInt(1, totalDistance)

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
    
    def is_valid(self, p):
        # Ensures given point is within bounds, does not contain an island, and does not intersect with a bridge
        def is_between_inclusive(a, b, c):
            return (a <= b and b <= c) or (c <= b and b <= a) 
        if not self.in_bounds(p):
            print("Point {0} not in bounds.".format(p))
            return False
        if p in self.islands:
            print("Point {0} collides with an island.".format(p))
            return False
        for (start, end) in self.bridges:
            if (start.x == end.x):
                if start.x == p.x and is_between_inclusive(start.y, p.y, end.y):
                    return False
            elif (start.y == end.y):
                if start.y == p.y and is_between_inclusive(start.x, p.x, end.x):
                    return False
            else:
                raise Exception("Yo, what is this bridge? Start:{0}, End:{1}".format(start, end))
        return True
    
    def in_bounds(self, p):
        return p.x >= 0 and p.x < self.grid_size and p.y >= 0 and p.y < self.grid_size
    
    def __init__(self, grid_size):
        self.grid_size = grid_size
        # self.grid = [[0 for x in range(grid_size)] for y in range(grid_size)]
        # self.grid[2][2] = self.Island(3)
        self.islands = {} # Dict[Point, Island]
        # self.islands[(2, 2)] = self.Island(3)
        self.bridges = []
        
        self.init_game(10, .5, .5)
    
    def make_island(self):
        # self.bridges = []
        randIsland = randItem(list(self.islands.keys()))
        randDirection = randItem([Point(0, -1), Point(0, 1), Point(-1, 0), Point(1, 0)])
        
        # probe in direction
        furthestPoint = randIsland
        while self.in_bounds(furthestPoint):
            nextPoint = furthestPoint + randDirection
            
            if self.is_valid(nextPoint):
                furthestPoint = nextPoint
            else:
                break
        
        newIsland = randBetween(randIsland, furthestPoint, randDirection)
        print("randIsland:{0}, furthestPoint:{1}, randDirection:{2}, newIsland:{3}".format(str(randIsland), str(furthestPoint), str(randDirection), str(newIsland)))
        if newIsland:
            self.islands[randIsland].numTotalBridges += 1
            print('updated bridges of', str(randIsland), self.islands[randIsland].numTotalBridges)
            self.islands[newIsland] = self.islands.get(newIsland, self.Island(0))
            self.islands[newIsland].numTotalBridges += 1
            print('updated bridges of', str(newIsland), self.islands[newIsland].numTotalBridges)
            self.bridges.append((randIsland, newIsland))
    
    def init_game(self, n, a, b):
        # step 1 - placement of the islands
        self.islands[Point(0, 0)] = self.Island(0)
        
        # for i in range(n-1):
            
    
    def draw_game(self):
        for i in range(self.grid_size):
            for j in range(self.grid_size):
                fill(255)
                stroke(200)
                strokeWeight(1)
                rect(40+i*50, 40+j*50, 50, 50)
        
        for (island1, island2) in self.bridges:
            # print(str(island1), str(island2))
            stroke(randInt(255), randInt(255), randInt(255))
            strokeWeight(2)
            
            line(40 + island1.x * 50, 40 + island1.y * 50, 40 + island2.x * 50, 40 + island2.y * 50)
        
        for (loc, island) in self.islands.items():
            stroke(0)
            strokeWeight(2)
            fill(255)
            circle(40+loc.x*50, 40+loc.y*50, 30)
            fill(0)
            textAlign(CENTER, CENTER)
            text(island.numTotalBridges, 40+loc.x*50, 40+loc.y*50)

def keyReleased():
    global game
    game.make_island()

def setup():
    global game
    game = Hashi(10)
    
    size(720, 720)

def draw():
    global game
    background(255)
    game.draw_game()
    
