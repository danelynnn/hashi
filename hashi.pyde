from copy import copy

def randItem(lyst):
    return lyst[randInt(len(lyst))]

def randInt(*argv):
    return int(random(*argv))

def randBetween(start, finish, direction):
    totalDistance = (finish - start).abso().maximum()
    if totalDistance == 1:
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
        def __init__(self, bridges):
            self.bridges = bridges
            self.remaining = bridges
    
    def find_closest_bridge(self, island, direction):
        for bridge in self.bridges:
            # if bridge is perpendicular
            if unit(subtract(bridge[0], bridge[1])) != unit(direction):
                pass
    
    def in_bounds(self, island):
        return island.x >= 0 and island.x < self.grid_size and island.y >= 0 and island.y < self.grid_size
    
    def __init__(self, grid_size):
        self.grid_size = grid_size
        # self.grid = [[0 for x in range(grid_size)] for y in range(grid_size)]
        # self.grid[2][2] = self.Island(3)
        self.field = {} # Dict[Point, Island]
        # self.field[(2, 2)] = self.Island(3)
        self.bridges = []
        
        self.init_game(10, .5, .5)
    
    def make_island(self):
        # self.bridges = []
        randIsland = randItem(list(self.field.keys()))
        randDirection = randItem([Point(0, -1), Point(0, 1), Point(-1, 0), Point(1, 0)])
        
        # probe in direction
        found = False
        
        while not found:
            maxIsland = randIsland
            while self.in_bounds(maxIsland):
                test = maxIsland + randDirection
                
                if test in self.field:
                    break
                # elif test is fucked:
                #     break
                
                if self.in_bounds(test):
                    found = True
                    maxIsland = test
                else:
                    break
            
            if not found:
                randDirection = [Point(0, -1), Point(0, 1), Point(-1, 0), Point(1, 0)][randInt(4)]
                print('finding new direction', randDirection)
        
        newIsland = randBetween(randIsland, maxIsland, randDirection)
        print(str(randIsland), str(maxIsland), str(newIsland))
        if newIsland:
            self.field[randIsland].bridges += 1
            print('updated bridges of', str(randIsland), self.field[randIsland].bridges)
            self.field[newIsland] = self.field.get(newIsland, self.Island(0))
            self.field[newIsland].bridges += 1
            print('updated bridges of', str(newIsland), self.field[newIsland].bridges)
            print({str(k): self.field[k].bridges for k in self.field.keys()})
            self.bridges.append((randIsland, newIsland))
    
    def init_game(self, n, a, b):
        # step 1 - placement of the islands
        self.field[Point(randInt(self.grid_size), randInt(self.grid_size))] = self.Island(0)
        
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
        
        for (loc, island) in self.field.items():
            stroke(0)
            strokeWeight(2)
            fill(255)
            circle(40+loc.x*50, 40+loc.y*50, 30)
            fill(0)
            textAlign(CENTER, CENTER)
            text(island.bridges, 40+loc.x*50, 40+loc.y*50)

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
    
