Cell[][] board;
int cell_w_num = 0;
int cell_h_num = 0;
int cell_width = 15;
boolean running = false;
boolean random_init = false;
boolean aging = false;

void setup() {
  size(screenWidth, screenHeight);
  cell_w_num = screenWidth/cell_width;
  cell_h_num = screenHeight/cell_width;
  smooth();
  strokeWeight(2);
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
  for (int i=0; i<cell_w_num; i+=1) {
    for (int j=0; j<cell_h_num; j+=1) {
      board[i][j].step(board);
    }
  }
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

  Cell(int i, int j, int w) {
    age = 0;
    ix = i;
    iy = j;
    cell_width = w;
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
    rect(xpos, ypos, cell_width, cell_width);
  }

  void deadOrAlive() {
    if (alive) {
      if (aging) fill(min(30+age, 255), 100, 200, min(100+age, 255));
      else fill(0, 0, 0);
    } else {
      fill(255, 255, 255);
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
    if (friends > 1 && friends < 4) {
      alive_next = true;
      if (aging) age += 1;
    } else {
      alive_next = false;
      age = 0;
    }

    if (aging && age > 200) alive_next = false;
  }

  void checkRebirthCondition(int friends) {
    if (friends == 3) alive_next = true;
  }

}
