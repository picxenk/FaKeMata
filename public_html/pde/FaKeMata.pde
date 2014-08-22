Cell[][] board;
int cell_w_num = 0;
int cell_h_num = 0;
int cell_width = 15;
boolean running = false;
boolean random_init = false;
boolean aging = false;

void setup() {
  size(screenWidth, screenHeight);
  cell_w_num = int(width/cell_width);
  cell_h_num = int(height/cell_width);
  smooth();
  strokeWeight(0.2);
  stroke(0, 70);
  frameRate(15);

  initGOL(cell_w_num, cell_h_num, cell_width);
}

void draw() {
  background(255);
  if (running) stepGOL();
  drawGOL();
}

void keyPressed() {
  if (key == ENTER) {
    running = false;
    initGOL(cell_w_num, cell_h_num, cell_width);
  }

  if (key == 's') {
    if (running) running = false;
    else running = true;
  }

  if (key == ' ') {
    if (running) running = false;
    stepGOL();
  }
}

void initGOL(int w_num, int h_num, int cell_width) {
  board = new Cell[w_num][h_num];

  for (int i=0; i<w_num; i+=1) {
    for (int j=0; j<h_num; j+=1) {
      board[i][j] = new Cell(i, j, cell_width);
    }
  }

}

void stepGOL() {
  updateRule();

  for (int i=0; i<cell_w_num; i+=1) {
    for (int j=0; j<cell_h_num; j+=1) {
      board[i][j].step(board);
      
      if (ruleColor.length > 0) {
          if (ruleColor[0] == 2) board[i][j].randomColor();
          if (ruleColor[0] == 3) board[i][j].addRed();
          if (ruleColor[0] == 4) board[i][j].addGreen();
          if (ruleColor[0] == 5) board[i][j].addBlue();
      }
    }
  }
}

void updateRule() {
  String[] ruleB = {"C"};
  String[] ruleS = {"E", "C"};
  String[] ruleC = {};
  String[] codes = split(join(noteSequence, ","), "C,");
  if (codes.length == 3) {
      ruleB = split(codes[0], ",");
      ruleS = split(codes[1], ",");
      ruleC = split(codes[2], ",");
  } else {
      ruleC = split(codes[0], ",");
  }
  ruleBirth = [];
  ruleSurvive = [];
  ruleColor = [];
  for (int i=0; i<ruleB.length; i++) {
      ruleBirth.push(ruleMap[ruleB[i]]);
  }
  for (int i=0; i<ruleS.length; i++) {
      ruleSurvive.push(ruleMap[ruleS[i]]);
  }
  for (int i=0; i<ruleC.length; i++) {
      ruleColor.push(ruleMap[ruleC[i]]);
  }
  //println("--------");
  //println(ruleBirth);
  //println(ruleSurvive);
  //println(ruleColor);
}

void drawGOL() {
  for (int i=0; i<cell_w_num; i+=1) {
    for (int j=0; j<cell_h_num; j+=1) {
      board[i][j].show(0, 0);
    }
  }
}

class Cell {
  int ix, iy;
  int age;
  int cell_width;
  boolean alive;
  boolean alive_next;
  color cell_color, next_cell_color;

  Cell(int i, int j, int w) {
    age = 0;
    ix = i;
    iy = j;
    cell_width = w;
    cell_color = color(255);
    next_cell_color = color(0);
    if (random_init) alive = boolean(int(random(0, 2)));
    else alive = false;
    alive_next = false;

  }

  void show(int sx, int sy) {
    int xpos = sx + (ix*cell_width);
    int ypos = sy + (iy*cell_width);

    if (mousePressed) {
      if ((mouseX > xpos && mouseX < xpos+cell_width) && (mouseY > ypos && mouseY < ypos+cell_width)) {
//        if (alive) {
//          alive_next = false;
//          alive = false;
//        } else {
//          alive_next = true;
//          alive = true;
//        }
        alive_next = true;
        age = 0;
      }
    }

    deadOrAlive();
    fill(cell_color);
    rect(xpos, ypos, cell_width, cell_width);
  }


  void deadOrAlive() {
    if (alive) {
      //if (aging) cell_color = (min(30+age, 255), 100, 200, min(100+age, 255));
      //else cell_color = color(0, 0, 0);
      cell_color = next_cell_color;
    } else {
      cell_color = color(255, 255, 255);
      next_cell_color = color(0, 0, 0);
    }
    alive = alive_next;
  }

  void step(Cell[][] board) {
    int friends = countFriends(board);
    if (alive) {
      checkAliveCondition(friends);
    } else {
      age = 0;
      checkRebirthCondition(friends);
    }
  }

  int countFriends(Cell[][] board) {
    int count = 0;

    int il = ix-1;
    int ir = ix+1;
    int it = iy-1;
    int ib = iy+1;
    int w_end = board.length-1;
    int h_end = board[0].length-1;

    if (il<0) il = w_end;
    if (ir>w_end) ir = 0;
    if (it<0) it = h_end;
    if (ib>h_end) ib = 0;

    if (board[il][it].alive) count++;
    if (board[ix][it].alive) count++;
    if (board[ir][it].alive) count++;

    if (board[il][iy].alive) count++;
    if (board[ir][iy].alive) count++;

    if (board[il][ib].alive) count++;
    if (board[ix][ib].alive) count++;
    if (board[ir][ib].alive) count++;

    return count;
  }

  void checkAliveCondition(int friends) {
    //if (friends > 1 && friends < 4) {
    if (isInCondition(friends, ruleSurvive)) {
      alive_next = true;
      if (aging) age += 1;
    } else {
      alive_next = false;
      age = 0;
    }

    if (aging && age > 200) alive_next = false;
  }

  void checkRebirthCondition(int friends) {
    //if (friends == 3) alive_next = true;
    if (isInCondition(friends, ruleBirth)) alive_next = true;
  }

  boolean isInCondition(int number, int[] numbers) {
      for (int i=0; i<numbers.length; i++) {
          if (number == numbers[i]) return true;
      }
      return false;
  }

  void addRed() {
      if (alive) next_cell_color = color(red(cell_color)+random(20, 90), green(cell_color), blue(cell_color));
  }
  void addGreen() {
      if (alive) next_cell_color = color(red(cell_color), green(cell_color)+random(20, 90), blue(cell_color));
  }
  void addBlue() {
      if (alive) next_cell_color = color(red(cell_color), green(cell_color), blue(cell_color)+random(20, 90));
  }
  void randomColor() {
      if (alive) next_cell_color = color(random(0, 200), random(0, 200), random(0, 200));
  }

}
