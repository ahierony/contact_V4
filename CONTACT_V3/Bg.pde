class Bg {

  int unitTotal;
  int unitLength;

  Bg_Unit[] units;

  PVector pos;
  PVector origin;
  PVector unitOrigin;
  //PVector vel;
  float speed, maxSpeed;
  float accel;
  float friction;

  int deg = 0;

  //float bgX, bgY; //bgSize;

  int unitRow, unitCol;

  //int centerUnit;

  float wrapLimit_w;
  float wrapLimit_h;

  //chatgpt
  int[] arr = new int[25];


  // Constructor
  Bg(int _unitTotal) {

    pos = new PVector(width/2, height/2);
    origin = new PVector(0, 0);
    unitOrigin = new PVector(0, 0);

    unitTotal = _unitTotal;
    unitLength = (int)sqrt(unitTotal );

    units = new Bg_Unit[unitTotal];

    // amount of units in a row or col
    unitRow = int(unit_w * ((unitLength-1)/2));
    unitCol = int(unit_h * ((unitLength-1)/2));

    //bgSize = unit_w * unitLength;

    int val_w = int((rowLength - 1) * 0.5);
    int val_h = int((rowLength - 1) * 0.5);

    wrapLimit_w = (unit_w * val_w) + (unit_w * 0.5); // 2000  1600 + 400
    wrapLimit_h = (unit_h * val_h) + (unit_h * 0.5);

    createRandomPlacementOfElements();

    //for (int index =0; i<unitLength; index++) {


    int index = 0;
    for (int j=0; j<unitLength; j++) {
      for (int i=0; i<unitLength; i++) {

        if (arr[index] == 0 || arr[index] == 2) {
          units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
        } else {

          units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
        }
        index++;
      }
      
    }
    println("index ", index);
  }

  void createRandomPlacementOfElements() {

    // Initialize all values
    for (int i = 0; i < arr.length; i++) {
      arr[i] = -1;
    }

    // Place the value 2 at index 12
    arr[12] = 2;

    // Create an IntList with 16 zeros and 8 ones
    IntList pool = new IntList();
    for (int i = 0; i < 16; i++) pool.append(0);
    for (int i = 0; i < 8; i++) pool.append(1);

    // Randomly fill all other positions
    for (int i = 0; i < arr.length; i++) {
      if (i != 12) {
        int randIndex = int(random(pool.size()));
        arr[i] = pool.get(randIndex);
        pool.remove(randIndex);
      }
    }
  }



  //*******************************************************
  // UPDATE
  //*******************************************************
  void update(PVector vel) {

    for (int i=0; i<units.length; i++) {
      units[i].updatePos(vel);
    }

    /*
    int val_w = int((rowLength - 1) * 0.5);
     int val_h = int((rowLength - 1) * 0.5);
     
     wrapLimit_w = (unit_w * val_w) + (unit_w * 0.5); // 2000  1600 + 400
     wrapLimit_h = (unit_h * val_h) + (unit_h * 0.5);
     */

    for (int i=0; i<units.length; i++) {

      if (units[i].pos.x > wrapLimit_w) {
        units[i].pos.x = - wrapLimit_w;
        if (units[i].containsVehicle) units[i].wrapVehicle();
      } else if (units[i].pos.x < -wrapLimit_w) {
        units[i].pos.x = wrapLimit_w;
        if (units[i].containsVehicle) units[i].wrapVehicle();
      }

      if (units[i].pos.y > wrapLimit_h) {
        units[i].pos.y = -wrapLimit_h;
        if (units[i].containsVehicle) units[i].wrapVehicle();
      } else if (units[i].pos.y < -wrapLimit_h) {
        units[i].pos.y = wrapLimit_h;
        if (units[i].containsVehicle) units[i].wrapVehicle();
      }
    }
  }

  //*******************************************************
  // DISPLAY
  //*******************************************************
  void display(float worldScale) {

    pushMatrix();

    translate(width/2, height/2);

    scale(worldScale);

    rectMode(CENTER);

    noFill();
    strokeWeight(2);
    stroke(0, 0, 99);

    for (int i=0; i<units.length; i++) {
      units[i].display();
    }

    popMatrix();
  }
}
