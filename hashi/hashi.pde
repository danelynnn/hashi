final boolean DEBUG_MODE = true;
final boolean CHEATING_MODE = true;
final int SQUARE_SIZE = 50;

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
  
  public void draw() {
    stroke(0);
    strokeWeight(3);
    fill(255);
    circle(this.x * SQUARE_SIZE, this.y * SQUARE_SIZE, SQUARE_SIZE * 0.8);
    
    textSize(SQUARE_SIZE/2);
    textAlign(CENTER, CENTER);
    fill(0);
    text(CHEATING_MODE ? remaining() : number, this.x * SQUARE_SIZE, this.y * SQUARE_SIZE-3);
  }
}

class Bridge {
  Island i1, i2;
  int strength;
  
  public Bridge(Island i1, Island i2, int strength) {
    this.i1 = i1;
    this.i2 = i2;
    this.strength = strength;
    this.i1.bridges += strength;
    this.i2.bridges += strength;
  }
  
  public Bridge(Island i1, Island i2) {
    this(i1, i2, 1);
  }
  
  public void strengthen() {
    if (strength < 2) {
      strength++;
      this.i1.bridges++;
      this.i2.bridges++;
    } else {
      strength = 0;
      this.i1.bridges -= 2;
      this.i2.bridges -= 2;
    }
  }
  
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

class Board {
  ArrayList<Island> islands;
  ArrayList<Bridge> bridges;
  int w, h;
  int sum;
  
  public Board(int w, int h) {
    this.w = w;
    this.h = h;
    
    islands = new ArrayList<Island>();
    bridges = new ArrayList<Bridge>();
  }
  
  public void calculateSum() {
    this.sum = 0;
    for (Island i: board.islands)
      sum += abs(i.remaining());
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
  
  public void addBridge(Island i1, Island i2) {
    for (Bridge b: bridges) {
      if (b.i1 == i1 && b.i2 == i2) {
        b.strengthen();
        calculateSum();
        return;
      }
    }
    bridges.add(new Bridge(i1, i2));
    calculateSum();
  }
  
  public void addBridge(Island i1, Island i2, int strength) {
    bridges.add(new Bridge(i1, i2, strength));
    calculateSum();
  }
  
  public void makeBestBridge(int x, int y, boolean colBias) {
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
          if (closestTop == null || i.y > closestTop.x)
            closestTop = i;
        } else if (i.y > y) { // if island is below target
          // if island is closer, woohoo new
          if (closestBottom == null || i.x < closestBottom.x)
            closestBottom = i;
        }
      }
    }
    
    if (closestLeft != null && closestRight != null) { // if there's a valid horizontal bridge
      if (closestTop != null && closestBottom != null) { // if there's also a valid vertical bridge
        if (colBias) // tiebreaker
          addBridge(closestTop, closestBottom); // add the vertical bridge
        else
          addBridge(closestLeft, closestRight); // add the horizontal bridge
      } else {
        addBridge(closestLeft, closestRight); // add the horizontal bridge
      }
    } else if (closestTop != null && closestBottom != null) { // if there's a valid vertical bridge
      addBridge(closestTop, closestBottom);
    }
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
      line(x * SQUARE_SIZE + SQUARE_SIZE, SQUARE_SIZE/2, x * SQUARE_SIZE + SQUARE_SIZE, boundsY - SQUARE_SIZE/2);
    }
    // draw horizontal lines
    for (int y=0; y<this.h; y++) {
      line(SQUARE_SIZE/2, y * SQUARE_SIZE + SQUARE_SIZE, boundsX - SQUARE_SIZE/2, y * SQUARE_SIZE + SQUARE_SIZE);
    }
    
    pushMatrix();
    translate(SQUARE_SIZE, SQUARE_SIZE);
    for (Bridge b: bridges) {
      b.draw();
    }
    for (Island i: islands) {
      i.draw();
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
  board.makeBestBridge(closestCol, closestRow, colBias);
}

public void setup() {
  // id 8,618,892
  board = new Board(7, 7);
  Island i0 = board.addIsland(3, 0, 0);
  Island i1 = board.addIsland(2, -1, 0);
  Island i2 = board.addIsland(4, 1, 1);
  Island i3 = board.addIsland(4, -2, 1);
  Island i4 = board.addIsland(2, 2, 2);
  Island i5 = board.addIsland(2, 1, 4);
  Island i6 = board.addIsland(1, -1, -2);
  Island i7 = board.addIsland(3, 0, -1);
  Island i8 = board.addIsland(5, 2, -1);
  Island i9 = board.addIsland(4, -2, -1);
  //board.addBridge(i0, i1);
  //board.addBridge(i1, i6);
  //board.addBridge(i0, i7, 2);
  //board.addBridge(i2, i3, 2);
  //board.addBridge(i2, i5, 2);
  //board.addBridge(i4, i8, 2);
  //board.addBridge(i3, i9, 2);
  //board.addBridge(i7, i8);
  //board.addBridge(i8, i9, 2);
  
  // id 8,618,892
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
  
  size(720, 720);
}

public void draw() {
  background(255);
  
  pushMatrix();
  translate(20, 20);
  board.draw();
  
  pushMatrix();
  translate(SQUARE_SIZE, SQUARE_SIZE);
  point(closestCol * SQUARE_SIZE, closestRow * SQUARE_SIZE);
  popMatrix();
  popMatrix();
  
  textAlign(CENTER, TOP);
  text(board.sum, 600, 20);
}
