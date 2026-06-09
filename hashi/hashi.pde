import java.util.HashSet;

final boolean DEBUG_MODE = false;
final boolean CRUTCH_MODE = true;
final int SQUARE_SIZE = 50;

// TODO: add confetti

class Island {
  int number;
  int bridges;
  int x, y;
  
  public Island(int x, int y) {
    this.number = 0;
    this.bridges = 0;
    this.x = x;
    this.y = y;
  }
  
  public Island(int number, int x, int y) {
    this.number = number;
    this.bridges = 0;
    this.x = x;
    this.y = y;
  }
  
  public int remaining() {
    return number - bridges;
  }
  
  public boolean equals(Object other) {
    Island otherIsland = (Island)other;
    return this.x == otherIsland.x && this.y == otherIsland.y;
  }
  public int hashCode() {
    return parseInt("" + x + y);
  }
  
  public void draw() {
    stroke(0);
    strokeWeight(3);
    fill(255);
    circle(this.x * SQUARE_SIZE, this.y * SQUARE_SIZE, SQUARE_SIZE * 0.8);
    
    textSize(SQUARE_SIZE/2);
    textAlign(CENTER, CENTER);
    fill(0);
    text(CRUTCH_MODE ? remaining() : number, this.x * SQUARE_SIZE, this.y * SQUARE_SIZE-6);
  }
  
  public String toString() {
    return "(" + x + ", " + y + ")";
  }
}

class IslandPair {
  Island i1, i2;
  
  public IslandPair(Island i1, Island i2) {
    this.i1 = i1;
    this.i2 = i2;
  }
  
  public boolean equals(Object other) {
    IslandPair otherIP = (IslandPair)other;
    return (this.i1.equals(otherIP.i1) && this.i2.equals(otherIP.i2)) ||
           (this.i1.equals(otherIP.i2) && this.i2.equals(otherIP.i1));
  }
  public int hashCode() {
    return i1.hashCode() + i2.hashCode();
  }
}

// is n between x1 and x2
public boolean between(int n, int x1, int x2) {
  if (x1 < x2)
    return x1 < n && n < x2;
  else
    return x2 < n && n < x1;
}

class Bridge {
  Island i1, i2;
  int strength;
  
  public Bridge(IslandPair ip, int strength) {
    this.i1 = ip.i1;
    this.i2 = ip.i2;
    
    this.strengthen(strength);
  }
  
  public Bridge(IslandPair ip) {
    this(ip, 1);
  }
  
  public void strengthen(int amount) {
    // reset islands' bridge count
    i1.bridges -= strength;
    i2.bridges -= strength;
    
    // calculate new bridge strength
    strength += amount;
    strength %= 3;
    if (strength<0) strength += 3;
    
    // reapply bridge count to islands
    i1.bridges += strength;
    i2.bridges += strength;
  }
  
  public void strengthen() {
    strengthen(1);
  }
  
  //public boolean collides(Island i1, Island i2) {
  //  // if this bridge is horizontal
  //  if (this.i1.y == this.i2.y) {
  //    if (i1.x == i2.x) { // and the proposed bridge is vertical
  //      return between(i1.x, this.i1.x, this.i2.y) &&
  //             between(i;
  //    }
  //  }
  //}
  
  public void draw() {
    if (strength == 1) {
      strokeWeight(4);
      stroke(0);
      line(i1.x * SQUARE_SIZE, i1.y * SQUARE_SIZE, i2.x * SQUARE_SIZE, i2.y * SQUARE_SIZE);
    } else if (strength == 2) {
      strokeWeight(12);
      stroke(0);
      line(i1.x * SQUARE_SIZE, i1.y * SQUARE_SIZE, i2.x * SQUARE_SIZE, i2.y * SQUARE_SIZE);
      strokeWeight(4);
      stroke(255);
      line(i1.x * SQUARE_SIZE, i1.y * SQUARE_SIZE, i2.x * SQUARE_SIZE, i2.y * SQUARE_SIZE);
    }
  }
}

IslandPair potentialTest;

class Board {
  int w, h;
  HashSet<Island> islands;
  HashMap<IslandPair, Bridge> bridges;
  
  private int sum;
  public int win;
  
  public Board(int w, int h) {
    this.w = w;
    this.h = h;
    
    islands = new HashSet<Island>();
    bridges = new HashMap<IslandPair, Bridge>();
    
    win = -1;
    sum = 0;
  }
  
  private int dfs(Island start, HashSet<Island> visited) {
    int count = 1;
    visited.add(start);
    
    for (Bridge b : bridges.values()) {
      if (b.strength > 0) {
        if (b.i1 == start && !visited.contains(b.i2))
          count += dfs(b.i2, visited);
        else if (b.i2 == start && !visited.contains(b.i1))
          count += dfs(b.i1, visited);
      }
    }
    
    return count;
  }
  public int dfs(Island start) {
    return dfs(start, new HashSet<Island>());
  }
  
  public void calculateSum() {
    sum = 0;
    for (Island i: islands)
      sum += abs(i.remaining());
    
    if (sum == 0)
      win = dfs(islands.iterator().next());
    else
      win = -1;
  }
  
  public Island addIsland(int number, int x, int y) {
    // support -1 indexing lol idk why
    if (x < 0)
      x += w;
    if (y < 0)
      y += h;
    
    if (x >= 0 && x < w &&
        y >= 0 && y < h) {
      Island i = new Island(number, x, y);
      islands.add(i);
      calculateSum();
      return i;
    } else
      println("island was attempted to be made out of bounds at " + x + " " + y);
    return null;
  }
  
  public Island addIsland(int x, int y) {
    return addIsland(1, x, y);
  }
  
  public void addBridge(IslandPair ip, int strength) {
    if (bridges.containsKey(ip)) {
      Bridge existingBridge = bridges.get(ip);
      existingBridge.strengthen(strength);
    } else {
      potentialTest = ip;
      bridges.put(ip, new Bridge(ip, strength));
    }
    calculateSum();
  }
  
  public void addBridge(IslandPair ip) {
    addBridge(ip, 1);
  }
  
  // TODO: check collisions
  public IslandPair getBestIslandPair(int x, int y, boolean colBias) {
    if (islands.contains(new Island(x, y)))
      return null;
    
    Island closestLeft = null, closestRight = null, closestTop = null, closestBottom = null;
    
    for (Island i: islands) {
      if (i.y == y) { // if island is on the same row as target
        if (i.x < x) { // if island is to the left of target
          // if island is closer, woohoo new
          if (closestLeft == null || i.x > closestLeft.x)
            closestLeft = i;
        } else if (i.x > x) { // if island is to the right of target
          // if island is closer, woohoo new
          if (closestRight == null || i.x < closestRight.x)
            closestRight = i;
        }
      } else if (i.x == x) { // if island is on the same column as target
        if (i.y < y) { // if island is above target
          // if island is closer, woohoo new
          if (closestTop == null || i.y > closestTop.y)
            closestTop = i;
        } else if (i.y > y) { // if island is below target
          // if island is closer, woohoo new
          if (closestBottom == null || i.y < closestBottom.y)
            closestBottom = i;
        }
      }
    }
    
    // TODO: collision detection
    IslandPair closestHorizontal = null, closestVertical = null; // candidates
    if (closestLeft != null && closestRight != null) {
      closestHorizontal = new IslandPair(closestLeft, closestRight);
    }
    if (closestTop != null && closestBottom != null) {
      closestVertical = new IslandPair(closestTop, closestBottom);
    }
    
    if (closestHorizontal != null && closestVertical != null)
      return colBias ? closestVertical : closestHorizontal;
    else if (closestHorizontal != null)
      return closestHorizontal;
    else if (closestVertical != null)
      return closestVertical;
    else
      return null;
  }
  
  public void draw() {
    int boundsX = (w+1) * SQUARE_SIZE;
    int boundsY = (h+1) * SQUARE_SIZE;
    
    stroke(230);
    strokeWeight(1);
    fill(255);
    // draw bounding game rect
    rect(0, 0, boundsX, boundsY);
    
    strokeWeight(2);
    // draw vertical lines
    for (int x=0; x<this.w; x++) {
      line(x * SQUARE_SIZE + SQUARE_SIZE, SQUARE_SIZE/3, x * SQUARE_SIZE + SQUARE_SIZE, boundsY - SQUARE_SIZE/3);
    }
    // draw horizontal lines
    for (int y=0; y<this.h; y++) {
      line(SQUARE_SIZE/3, y * SQUARE_SIZE + SQUARE_SIZE, boundsX - SQUARE_SIZE/3, y * SQUARE_SIZE + SQUARE_SIZE);
    }
    
    pushMatrix();
    translate(SQUARE_SIZE, SQUARE_SIZE);
    for (Bridge b: bridges.values()) {
      b.draw();
    }
    
    // draw hovered island
    IslandPair best = board.getBestIslandPair(closestCol, closestRow, colBias);
    if (best != null) {
      strokeWeight(3);
      stroke(200);
      line(best.i1.x * SQUARE_SIZE, best.i1.y * SQUARE_SIZE, best.i2.x * SQUARE_SIZE, best.i2.y * SQUARE_SIZE);
    }
    
    for (Island i: islands) {
      i.draw();
    }
    
    if (DEBUG_MODE) {
      for (int i=0; i<this.w; i++) {
        for (int j=0; j<this.h; j++) {
          noStroke();
          fill(200);
          textAlign(LEFT, TOP);
          textSize(12);
          text(i, i*SQUARE_SIZE+10, j*SQUARE_SIZE);
          text(j, i*SQUARE_SIZE, j*SQUARE_SIZE+10);
          
          stroke(0);
          strokeWeight(5);
          point(i*SQUARE_SIZE, j*SQUARE_SIZE);
        }
      }
    }
    popMatrix();
  }
}

Board board;

int closestCol, closestRow;
boolean colBias; // 1 is biasing to column, 0 is biasing to row
public void mouseMoved() {
  //pushMatrix();
  //translate(20, 20);
  //point(mouseX, mouseY);
  //popMatrix();
  
  final int t = 20 + SQUARE_SIZE;
  
  int colDistance, rowDistance;
  
  // find closest row to mouse
  // if mouse is closer to left column, pick left
  if ((mouseX - t) % SQUARE_SIZE < SQUARE_SIZE/2) {
    closestCol = (mouseX - t) / SQUARE_SIZE;
    colDistance = (mouseX - t) % SQUARE_SIZE;
  } else { // if not, pick right
    closestCol = (mouseX - t) / SQUARE_SIZE + 1;
    colDistance = SQUARE_SIZE - (mouseX - t) % SQUARE_SIZE;
  }
  
  // find closest col to mouse
  // if mouse is closer to top row, pick top
  if ((mouseY - t) % SQUARE_SIZE < SQUARE_SIZE/2) {
    closestRow = (mouseY - t) / SQUARE_SIZE;
    rowDistance = (mouseY - t) % SQUARE_SIZE;
  } else { // if not, pick bottom
    closestRow = (mouseY - t) / SQUARE_SIZE + 1;
    rowDistance = SQUARE_SIZE - (mouseY - t) % SQUARE_SIZE;
  }
  
  colBias = colDistance < rowDistance;
}

public void mouseReleased() {
  // this better not be on an existing island is2g
  IslandPair best = board.getBestIslandPair(closestCol, closestRow, colBias);
  if (best != null) {
    if (mouseButton == LEFT) {
      board.addBridge(best);
    } else if (mouseButton == RIGHT) {
      board.addBridge(best, -1);
    }
  }
}

public void setup() {
  size(720, 720);
  textFont(createFont("IdealBold.ttf", 32));
  
  // id 8,618,892
  //board = new Board(7, 7);
  //Island i0 = board.addIsland(3, 0, 0);
  //Island i1 = board.addIsland(2, -1, 0);
  //Island i2 = board.addIsland(4, 1, 1);
  //Island i3 = board.addIsland(4, -2, 1);
  //Island i4 = board.addIsland(2, 2, 2);
  //Island i5 = board.addIsland(2, 1, 4);
  //Island i6 = board.addIsland(1, -1, -2);
  //Island i7 = board.addIsland(3, 0, -1);
  //Island i8 = board.addIsland(5, 2, -1);
  //Island i9 = board.addIsland(4, -2, -1);
  //board.addBridge(new IslandPair(i0, i1));
  //board.addBridge(new IslandPair(i1, i6));
  //board.addBridge(new IslandPair(i0, i7), 2);
  //board.addBridge(new IslandPair(i2, i3), 2);
  //board.addBridge(new IslandPair(i2, i5), 2);
  //board.addBridge(new IslandPair(i4, i8), 2);
  //board.addBridge(new IslandPair(i3, i9), 2);
  //board.addBridge(new IslandPair(i7, i8));
  //board.addBridge(new IslandPair(i8, i9), 2);
  
  // 7x7 normal, id 8,173,271
  //board = new Board(7, 7);
  //board.addIsland(4, 0, 0);
  //board.addIsland(3, 2, 0);
  //board.addIsland(1, 4, 0);
  //board.addIsland(2, 6, 0);
  //board.addIsland(5, 0, 2);
  //board.addIsland(5, 2, 2);
  //board.addIsland(2, -2, 2);
  //board.addIsland(2, -1, 3);
  //board.addIsland(2, 3, 4);
  //board.addIsland(3, -2, 4);
  //board.addIsland(3, 2, -2);
  //board.addIsland(3, -1, -2);
  //board.addIsland(3, 0, -1);
  //board.addIsland(2, -3, -1);
  
  // 10x10 hard, id 1,447,332
  board = new Board(10, 10);
  board.addIsland(3, 0, 0);
  board.addIsland(4, 2, 0);
  board.addIsland(5, 5, 0);
  board.addIsland(2, -2, 0);
  board.addIsland(2, 4, 1);
  board.addIsland(2, 0, 2);
  board.addIsland(4, -4, 2);
  board.addIsland(5, -2, 2);
  board.addIsland(3, 0, 4);
  board.addIsland(5, 2, 4);
  board.addIsland(3, 4, 4);
  board.addIsland(4, 6, 4);
  board.addIsland(2, -1, 4);
  board.addIsland(3, -2, 5);
  board.addIsland(5, 2, 6);
  board.addIsland(1, 4, 6);
  board.addIsland(2, -4, 7);
  board.addIsland(1, -2, 7);
  board.addIsland(2, 0, -2);
  board.addIsland(2, 3, -2);
  board.addIsland(6, 5, -2);
  board.addIsland(4, -1, -2);
  board.addIsland(3, 2, -1);
  board.addIsland(1, -2, -1);
}

public void draw() {
  background(255);
  
  pushMatrix();
  translate(20, 20);
  board.draw();
  
  // show cursor position
  if (DEBUG_MODE) {
    pushMatrix();
    translate(SQUARE_SIZE, SQUARE_SIZE);
    stroke(255,0,0);
    if (closestRow >= 0 && closestRow < 7 &&
        closestCol >= 0 && closestCol < 7)
      point(closestCol * SQUARE_SIZE, closestRow * SQUARE_SIZE);
    popMatrix();
  }
  popMatrix();
  
  if (DEBUG_MODE) {
    noStroke();
    if (board.win == board.islands.size()) fill(0, 200, 0); else fill(0);
    textSize(SQUARE_SIZE/2);
    textAlign(CENTER, TOP);
    text(board.win, 600, 20);
  } else {
    if (board.win == board.islands.size()) {
      noStroke();
      fill(0, 200, 0);
      textSize(SQUARE_SIZE/2);
      textAlign(CENTER, TOP);
      text("you win!!", 600, 20);
    }
  }
}
