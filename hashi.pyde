import operator

def randInt(high):
    return int(random(high))

def subtract(p1, p2):
    return tuple(map(operator.sub, p1, p2))

def divide(p, x):
    if x == 1:
        return p
    return tuple([i/x for i in p])

def unit(p):
    p_abs = [abs(i) for i in p]
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
    
    def __init__(self, grid_size):
        self.grid_size = grid_size
        # self.grid = [[0 for x in range(grid_size)] for y in range(grid_size)]
        # self.grid[2][2] = self.Island(3)
        self.field = {}
        self.field[(2, 2)] = self.Island(3)
        self.bridges = []
    
    def init_game(self, n, a, b):
        # step 1 - placement of the islands
        self.grid[randInt(self.grid_size)][randInt(self.grid_size)] = Island(0)
        
        for i in range(n-1):
            randIsland = self.field.items()[randInt(len(self.field.items()))]
            randDirection = [(0, -1), (0, 1), (-1, 0), (1, 0)][randInt(4)]
            
        
        pass
    
    def draw_game(self):
        for i in range(self.grid_size):
            for j in range(self.grid_size):
                fill(255)
                stroke(200)
                rect(40+i*50, 40+j*50, 50, 50)
                
        for (loc, island) in self.field.items():
            stroke(0)
            strokeWeight(2)
            circle(40+loc[0]*50, 40+loc[1]*50, 30)
            fill(0)
            textAlign(CENTER, CENTER)
            text(island.bridges, 40+loc[0]*50, 40+loc[1]*50)
        pass

def setup():
    font = createFont('OperatorMono.ttf', 128)
    textFont(font, 24)

    global game
    game = Hashi(5)
    
    size(500, 500)

def draw():
    global game
    background(255)
    game.draw_game()
    
