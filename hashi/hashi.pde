import java.util.HashSet;

import java.net.http.*;
import java.net.URI;

final boolean DEBUG_MODE = false;
final boolean CRUTCH_MODE = false;
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
  
  public void draw(boolean highlighted) {
    stroke(0);
    strokeWeight(3);
    if (highlighted)
      fill(230);
    else
      fill(255);
    circle(this.x * SQUARE_SIZE, this.y * SQUARE_SIZE, SQUARE_SIZE * 0.8);
    
    textSize(SQUARE_SIZE/2);
    textAlign(CENTER, CENTER);
    fill(0);
    text(CRUTCH_MODE ? remaining() : number, this.x * SQUARE_SIZE, this.y * SQUARE_SIZE-6);
  }
  public void draw() {
    draw(false);
  }
  
  public String toString() {
    return "(" + x + ", " + y + ")";
  }
}

boolean rangeOverlap(int start1, int stop1, int start2, int stop2) {
  return (start1 < start2 && stop1 > stop2) ||
         (start2 < start1 && stop2 > stop1);
}

class IslandPair {
  Island i1, i2;
  
  public IslandPair(Island i1, Island i2) {
    this.i1 = i1;
    this.i2 = i2;
  }
  
  public boolean collides(Bridge b) {
    return rangeOverlap(i1.x, i2.x, b.i1.x, b.i2.x) &&
           rangeOverlap(i1.y, i2.y, b.i1.y, b.i2.y);
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
    
    if (sum == 0 && islands.size() > 0)
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
      bridges.put(ip, new Bridge(ip, strength));
    }
    calculateSum();
  }
  public void addBridge(IslandPair ip) {
    addBridge(ip, 1);
  }
  
  // for click-style entry
  public IslandPair getBestIslandPair(int x, int y, boolean colBias) {
    Island closestLeft = null, closestRight = null, closestTop = null, closestBottom = null;
    
    for (Island other: islands) {
      if (other.y == y) { // if island is on the same row as target
        if (other.x < x) { // if island is to the left of target
          // if island is closer, woohoo new
          if (closestLeft == null || other.x > closestLeft.x)
            closestLeft = other;
        } else if (other.x > x) { // if island is to the right of target
          // if island is closer, woohoo new
          if (closestRight == null || other.x < closestRight.x)
            closestRight = other;
        }
      } else if (other.x == x) { // if island is on the same column as target
        if (other.y < y) { // if island is above target
          // if island is closer, woohoo new
          if (closestTop == null || other.y > closestTop.y)
            closestTop = other;
        } else if (other.y > y) { // if island is below target
          // if island is closer, woohoo new
          if (closestBottom == null || other.y < closestBottom.y)
            closestBottom = other;
        }
      }
    }
    
    IslandPair closestHorizontal = null, closestVertical = null; // candidates
    if (closestLeft != null && closestRight != null) {
      closestHorizontal = new IslandPair(closestLeft, closestRight);
      
      boolean valid = true;
      for (Bridge b: bridges.values())
        if (b.strength > 0 && closestHorizontal.collides(b))
          valid = false;
      
      if (!valid) closestHorizontal = null;
    }
    if (closestTop != null && closestBottom != null) {
      closestVertical = new IslandPair(closestTop, closestBottom);
      
      boolean valid = true;
      for (Bridge b: bridges.values())
        if (b.strength > 0 && closestVertical.collides(b))
          valid = false;
      
      if (!valid) closestVertical = null;
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
  // for drag-style entry
  public IslandPair getBestIslandPair(Island i, int direction) {
    Island closest = null;

    for (Island other: islands) {
      // locate the actual island, i is just a temp fake island
      if (other.equals(i))
        i = other;

      switch (direction) {
      case 0: // LEFT
        if (other.y == i.y && other.x < i.x) { // if island is on the left as target
          // if island is closer, woohoo new
          if (closest == null || other.x > closest.x)
            closest = other;
        }
        break;
      case 1: // RIGHT
        if (other.y == i.y && other.x > i.x) { // if island is on the left as target
          // if island is closer, woohoo new
          if (closest == null || other.x < closest.x)
            closest = other;
        }
        break;
      case 2: // UP
        if (other.x == i.x && other.y < i.y) { // if island is on the left as target
          // if island is closer, woohoo new
          if (closest == null || other.y > closest.y)
            closest = other;
        }
        break;
      case 3: // DOWN
        if (other.x == i.x && other.y > i.y) { // if island is on the left as target
          // if island is closer, woohoo new
          if (closest == null || other.y < closest.y)
            closest = other;
        }
        break;
      }
    }

    if (closest != null) {
      IslandPair closestPair = new IslandPair(i, closest);

      boolean valid = true;
      for (Bridge b: bridges.values())
        if (b.strength > 0 && closestPair.collides(b))
          valid = false;
      
      if (valid)
        return closestPair;
    }
    
    return null;
  }

  public void reset() {
    bridges.clear();
    calculateSum();
  }
  public void hardReset() {
    islands.clear();
    reset();
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
    
    if (mousePressed) { // draw dragged bridge
      Island i = new Island(closestCol, closestRow);
      if (board.islands.contains(i)) {
        IslandPair best = board.getBestIslandPair(i, direction);
        if (best != null) {
          if (mouseButton == LEFT) {
            strokeWeight(3);
            stroke(200);
            line(best.i1.x * SQUARE_SIZE, best.i1.y * SQUARE_SIZE, best.i2.x * SQUARE_SIZE, best.i2.y * SQUARE_SIZE);
          } else if (mouseButton == RIGHT) {
            strokeWeight(12);
            stroke(200);
            line(best.i1.x * SQUARE_SIZE, best.i1.y * SQUARE_SIZE, best.i2.x * SQUARE_SIZE, best.i2.y * SQUARE_SIZE);
            strokeWeight(4);
            stroke(255);
            line(best.i1.x * SQUARE_SIZE, best.i1.y * SQUARE_SIZE, best.i2.x * SQUARE_SIZE, best.i2.y * SQUARE_SIZE);
          }
        }
      }
    } else { // draw hovered bridge
      if (!board.islands.contains(new Island(closestCol, closestRow))) {
        IslandPair best = board.getBestIslandPair(closestCol, closestRow, colBias);
        if (best != null) {
          strokeWeight(3);
          stroke(200);
          line(best.i1.x * SQUARE_SIZE, best.i1.y * SQUARE_SIZE, best.i2.x * SQUARE_SIZE, best.i2.y * SQUARE_SIZE);
        }
      }
    }
    
    for (Island i: islands) {
      if (mousePressed && i.x == closestCol && i.y == closestRow)
        i.draw(true);
      else
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

class BBox {
  int x1, y1, x2, y2;

  public BBox(int x1, int y1, int x2, int y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }

  public int width() {
    return this.x2 - this.x1;
  }
  public int height() {
    return this.y2 - this.y1;
  }

  public boolean enclose(int x, int y) {
    return x >= x1 && x <= x2 && y >= y1 && y <= y2;
  }
}
abstract class Widget {
  BBox bounds;

  public Widget(BBox bounds) {
    this.bounds = bounds;
  }

  public void mouseMoved() {}
  public void mouseClicked() {}
  public void mouseWheel(MouseEvent event) {}
  public void keyPressed() {}
  public void draw() {}
}
class Option {
  String key, value;
  public Option(String key, String value) {
    this.key = key;
    this.value = value;
  }
}
class ComboBox extends Widget {
  Option[] options;
  int selected;

  private boolean hover;

  public ComboBox(int x, int y, int w, int h, Option[] options) {
    super(new BBox(x, y, x+w, y+h));
    this.options = options;
    this.selected = 0;
  }
  public ComboBox(int x, int y, int w, Option[] options) {
    this(x, y, w, 30, options);
  }

  public void mouseMoved() {
    hover = this.bounds.enclose(mouseX, mouseY);
  }

  public void mouseWheel(MouseEvent event) {
    if (this.bounds.enclose(mouseX, mouseY)) {
      selected += event.getCount();
      
      selected %= options.length;
      if (selected < 0) selected += options.length;
    }
  }

  public void draw() {
    strokeWeight(1);
    if (hover)
      stroke(100);
    else
      stroke(200);
    fill(255);
    rect(this.bounds.x1, this.bounds.y1, this.bounds.width(), this.bounds.height());

    fill(0);
    textSize(20);
    textAlign(LEFT, CENTER);
    text(options[selected].value, this.bounds.x1, this.bounds.y1, this.bounds.width(), this.bounds.height());

    noStroke();
    fill(255);
    rect(this.bounds.x2 - this.bounds.height(), this.bounds.y1+1, this.bounds.height()-1, this.bounds.height()-2);

    noStroke();
    fill(0);
    triangle(this.bounds.x2 - this.bounds.height(), this.bounds.y1+1,
             this.bounds.x2-1, this.bounds.y1+1,
             this.bounds.x2 - this.bounds.height()/2, this.bounds.y2-1);
  }
}
interface EventListener {
  public void onClick();
}
class Button extends Widget {
  String text;
  EventListener onClick;
  boolean hover;

  Button(String text, int x, int y, int w, int h, EventListener onClick) {
    super(new BBox(x, y, x+w, y+h));
    this.text = text;
    this.onClick = onClick;
  }
  Button(String text, int x, int y, EventListener onClick) {
    this(text, x, y, 100, 30, onClick);
  }
  Button(String text, int x, int y) {
    this(text, x, y, null);
  }

  void addOnClick(EventListener onClick) {
    this.onClick = onClick;
  }

  public void mouseMoved() {
    hover = this.bounds.enclose(mouseX, mouseY);
  }
  public void mouseClicked() {
    if (this.bounds.enclose(mouseX, mouseY))
      this.onClick.onClick();
  }

  public void draw() {
    strokeWeight(1);
    if (hover)
      stroke(100);
    else
      stroke(200);
    fill(255);
    rect(this.bounds.x1, this.bounds.y1, this.bounds.width(), this.bounds.height(), 5);

    fill(0);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(text, this.bounds.x1, this.bounds.y1, this.bounds.width(), this.bounds.height());
  }
}

Board board;
ArrayList<Widget> widgets;

int closestCol, closestRow;
boolean colBias; // 1 is biasing to column, 0 is biasing to row
int direction = -1;

public void mouseMoved() {
  //pushMatrix();
  //translate(20, 20);
  //point(mouseX, mouseY);
  //popMatrix();

  for (Widget w : widgets) {
    w.mouseMoved();
  }
  
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

public void mouseDragged() {
  final int t = 20 + SQUARE_SIZE;
  int originX = closestCol * SQUARE_SIZE + t;
  int originY = closestRow * SQUARE_SIZE + t;

  float deltaX = mouseX - originX;
  float deltaY = mouseY - originY;

  if (abs(deltaX) > abs(deltaY)) {
    if (deltaX < 0)
      direction = 0;
    else
      direction = 1;
  } else {
    if (deltaY < 0)
      direction = 2;
    else
      direction = 3;
  }
}

public void mouseClicked() {
  for (Widget w : widgets) {
    w.mouseClicked();
  }

  if (!board.islands.contains(new Island(closestCol, closestRow))) {
    IslandPair best = board.getBestIslandPair(closestCol, closestRow, colBias);
    if (best != null) {
      if (mouseButton == LEFT) {
        board.addBridge(best);
      } else if (mouseButton == RIGHT) {
        board.addBridge(best, -1);
      }
    }
  }
}

public void mouseReleased() {
  Island origin = new Island(closestCol, closestRow);

  if (board.islands.contains(new Island(closestCol, closestRow))) {
    IslandPair best = board.getBestIslandPair(new Island(closestCol, closestRow), direction);
    if (best != null) {
      if (mouseButton == LEFT) {
        board.addBridge(best);
      } else if (mouseButton == RIGHT) {
        board.addBridge(best, -1);
      }
    }
  }
}

public void mouseWheel(MouseEvent event) {
  for (Widget w : widgets) {
    w.mouseWheel(event);
  }
}

public void setup() {
  size(720, 720);
  textFont(createFont("IdealBold.ttf", 32));
  
  // id 8,618,892
  // board = new Board(7, 7);
  // Island i0 = board.addIsland(3, 0, 0);
  // Island i1 = board.addIsland(2, -1, 0);
  // Island i2 = board.addIsland(4, 1, 1);
  // Island i3 = board.addIsland(4, -2, 1);
  // Island i4 = board.addIsland(2, 2, 2);
  // Island i5 = board.addIsland(2, 1, 4);
  // Island i6 = board.addIsland(1, -1, -2);
  // Island i7 = board.addIsland(3, 0, -1);
  // Island i8 = board.addIsland(5, 2, -1);
  // Island i9 = board.addIsland(4, -2, -1);
  // board.addBridge(new IslandPair(i0, i1));
  // board.addBridge(new IslandPair(i1, i6));
  // board.addBridge(new IslandPair(i0, i7), 2);
  // board.addBridge(new IslandPair(i2, i3), 2);
  // board.addBridge(new IslandPair(i2, i5), 2);
  // board.addBridge(new IslandPair(i4, i8), 2);
  // board.addBridge(new IslandPair(i3, i9), 2);
  // board.addBridge(new IslandPair(i7, i8));
  // board.addBridge(new IslandPair(i8, i9), 2);
  
  // 7x7 normal, id 8,173,271
  // board = new Board(7, 7);
  // board.addIsland(4, 0, 0);
  // board.addIsland(3, 2, 0);
  // board.addIsland(1, 4, 0);
  // board.addIsland(2, 6, 0);
  // board.addIsland(5, 0, 2);
  // board.addIsland(5, 2, 2);
  // board.addIsland(2, -2, 2);
  // board.addIsland(2, -1, 3);
  // board.addIsland(2, 3, 4);
  // board.addIsland(3, -2, 4);
  // board.addIsland(3, 2, -2);
  // board.addIsland(3, -1, -2);
  // board.addIsland(3, 0, -1);
  // board.addIsland(2, -3, -1);
  
  // 10x10 normal, id 9,985,396
  board = new Board(10, 10);
  board.addIsland(4, 1, 0);
  board.addIsland(6, 3, 0);
  board.addIsland(4, -1, 0);
  board.addIsland(2, 0, 2);
  board.addIsland(4, 1, 3);
  board.addIsland(7, 3, 3);
  board.addIsland(4, -1, 3);
  board.addIsland(2, 5, 4);
  board.addIsland(3, 7, 4);
  board.addIsland(5, 0, 5);
  board.addIsland(1, 2, 5);
  board.addIsland(1, 1, 6);
  board.addIsland(6, 3, 6);
  board.addIsland(4, -3, 6);
  board.addIsland(3, -1, 6);
  board.addIsland(5, 0, -3);
  board.addIsland(2, 2, -3);
  board.addIsland(2, 4, -2);
  board.addIsland(4, -3, -2);
  board.addIsland(2, 0, -1);
  board.addIsland(5, 3, -1);
  board.addIsland(4, -1, -1);
  
  widgets = new ArrayList<Widget>();
  
  Option[] options = new Option[] {
    new Option("1", "7x7 Normal Hashi"),
    new Option("2", "7x7 Hard Hashi"),
    new Option("15", "7x7 Dense Hashi"),
    new Option("3", "10x10 Easy Hashi"),
    new Option("4", "10x10 Normal Hashi"),
    new Option("5", "10x10 Hard Hashi"),
    new Option("16", "10x10 Dense Hashi"),
    new Option("6", "15x15 Easy Hashi"),
    new Option("7", "15x15 Normal Hashi"),
    new Option("8", "15x15 Hard Hashi"),
    new Option("17", "15x15 Dense Hashi"),
    new Option("9", "25x25 Easy Hashi"),
    new Option("10", "25x25 Normal Hashi"),
    new Option("11", "25x25 Hard Hashi"),
    new Option("18", "25x25 Dense Hashi")
  };
  widgets.add(new ComboBox(5, 600, 300, options));
  
  widgets.add(new Button("click me", 320, 600, new EventListener() {
    public void onClick() {
      board.hardReset();
    }
  }));
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
      textAlign(LEFT, TOP);
      text("you win!!", 600, 20);
    }
  }

  for (Widget w : widgets) {
    w.draw();
  }
}
