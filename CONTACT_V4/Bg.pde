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
  color[] randomCols = new color[arr.length];

  //--------------------------------------------------------------
  // Constructor
  Bg(int _unitTotal, PApplet app) {

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

    //createRandomPlacementOfElements2();
    if (fullScale) {
      createCustomLayout();
      assignUniqueColorsToEnvironments();
      assignUniqueColorsToAgents();
    }

    int index = 0;
    for (int j=0; j<unitLength; j++) {
      for (int i=0; i<unitLength; i++) {

        // CUSTOM NODES FULL LAYOUT
        if (fullScale) {
          if (arr[index] == 0) {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, true, index, app, randomCols[index]);
          } else if (arr[index] == 1) {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, false, index, app, randomCols[index]);
          } else {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, false, index, app, randomCols[index]);
          }
        } else {

          // 2 NODES
          int[] possibleColors = {0, 45, 90, 135, 180, 225, 270, 315};
          int randomCol = int(random(possibleColors.length));
          int vehicleColorNum = possibleColors[randomCol];

          // conditional logic to set amount of elements in the grid (1 element at position 0:0)
          if (i == 0 && j == 0) {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, true, index, app, vehicleColorNum);
          } else if (i == 0 && j == 1 ) {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, false, index, app, vehicleColorNum);
          } else {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, false, index, app, vehicleColorNum);
          }
        }



        // RANDOM NODES
        /*
        if (arr[index] == 0) {
         units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, true, index);
         } else if (arr[index] == 1) {
         units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, false, index);
         } else {
         units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, false, index);
         }
         */

        // 1 NODE
        /*
        // conditional logic to set amount of elements in the grid (1 element at position 0:0)
         if (i == 0 && j == 0) {
         units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
         } else {
         units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
         }
         */


        index++;
      }
    }
  }
  //--------------------------------------------------------------

  void createCustomLayout() {

    // Initialize all values
    for (int i = 0; i < arr.length; i++) {
      arr[i] = -1;
    }

    // Place the value 2 at index 12
    arr[12] = 2;

    // Create an IntList with 4 zeros and 8 ones and 8 threes
    IntList pool = new IntList();
    for (int i = 0; i < 8; i++) pool.append(1);
    for (int i = 0; i < 8; i++) pool.append(3);

    int beginningIndex = int(random(3));

    for (int i = beginningIndex; i < arr.length; i+=3) {
      if (i != 12) {
        arr[i] = 0;
      }
    }

    // Randomly fill all other positions
    for (int i = 0; i < arr.length; i++) {
      if (arr[i] == -1) {
        int randIndex = int(random(pool.size()));
        arr[i] = pool.get(randIndex);
        pool.remove(randIndex);
      }
    }
  }


  void assignUniqueColorsToEnvironments() {

    int[] possibleColors = {0, 45, 90, 135, 180, 225, 270, 315};
    IntList pool = new IntList();
    for (int i = 0; i < 8; i++) pool.append(possibleColors[i]);

    for (int i = 0; i < randomCols.length; i++) {
      randomCols[i] = -1;
    }

    for (int i = 0; i < arr.length; i++) {
      if (arr[i] == 0) {

        int randIndex = int(random(pool.size()));
        randomCols[i] = pool.get(randIndex);
        pool.remove(randIndex);
      }
    }
    
    //println(randomCols);

  }
  
    void assignUniqueColorsToAgents() {

    int[] possibleColors = {0, 45, 90, 135, 180, 225, 270, 315};
    IntList pool = new IntList();
    for (int i = 0; i < 8; i++) pool.append(possibleColors[i]);
    
    /*
    for (int i = 0; i < randomCols.length; i++) {
      randomCols[i] = -1;
    }
    */

    for (int i = 0; i < arr.length; i++) {
      if (arr[i] == 1) {

        int randIndex = int(random(pool.size()));
        randomCols[i] = pool.get(randIndex);
        pool.remove(randIndex);
      }
    }
    
    println(randomCols);

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
