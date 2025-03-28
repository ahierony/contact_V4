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

  int centerUnit;

  float wrapLimit_w;
  float wrapLimit_h;


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

    // POSITION UNITS
    int index = 0;
    for (int j=0; j<unitLength; j++) {
      for (int i=0; i<unitLength; i++) {

        //println("i ", i);

        // 0 NODES
        //units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);

        // 8 NODES
        /*
         if (i == 1 && j == 1) {
         units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);
         println(index);
         } else {
         units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), true, index);
         }
         */


        if (debugMode) {

          /*
          // 2 NODES
           // conditional logic to set amount of elements in the grid (1 element at position 0:0)
           if (i == 0 && j == 0 || i == 0 && j == 1) {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
           }
           */


          // three by three grid with only middle empty

          if (i == 1 && j == 1) {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
            //println(index);
          } else {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
          }

          /*
           // four corners only
           
           if ((i == 0 && j == 0) || (i == 2 && j == 0) || (i == 0 && j == 2) || (i == 2 && j == 2)) {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
           //println(index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
           }
           
           */

          // 1 NODE

          // conditional logic to set amount of elements in the grid (1 element at position 0:0)
          /*
          if (i == 0 && j == 0) {
           units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), true, index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);
           }
           */


          /*
           if (i == 2 && j == 2) {
           units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);
           println(index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), true, index);
           }
           */
        } else { // debug mode false

          // three by three grid with only middle empty

          if (i == 1 && j == 1) {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
            //println(index);
          } else {
            units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
          }

          /*
          // four corners only
           
           if ((i == 0 && j == 0) || (i == 2 && j == 0) || (i == 0 && j == 2) || (i == 2 && j == 2)) {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
           //println(index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
           }
           */

          // 24 NODES

          /*
          if (i == 0 && j == 0 || i == 0 && j == 1) {
           units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), true, index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);
           }
           */


          // full grid with half / half
          /*
          if (i == 2 && j == 2) {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), false, index);
           //println(index);
           } else {
           units[index] = new Bg_Unit((unitOrigin.x - unitRow)+(i*unit_w), (unitOrigin.y - unitCol)+(j*unit_h), true, index);
           }
           */
        }


        // 2 NODES
        /*
        // conditional logic to set amount of elements in the grid (1 element at position 0:0)
         if (i == 0 && j == 0 || i == 0 && j == 1) {
         units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), true, index);
         } else {
         units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);
         }
         */


        // 1 NODE
        /*
        // conditional logic to set amount of elements in the grid (1 element at position 0:0)
         if (i == 0 && j == 0) {
         units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), true, index);
         } else {
         units[index] = new Bg_Unit((unitOrigin.x - unitNum)+(i*unit_size), (unitOrigin.y - unitNum)+(j*unit_size), false, index);
         }
         */

        index++;
      }
    }

    centerUnit = 7;
  }



  //*******************************************************
  // UPDATE
  //*******************************************************
  void update(PVector vel) {

    for (int i=0; i<units.length; i++) {
      units[i].updatePos(vel);
    }

    int val_w = int((rowLength - 1) * 0.5);
    int val_h = int((rowLength - 1) * 0.5);

    wrapLimit_w = (unit_w * val_w) + (unit_w * 0.5); // 2000  1600 + 400
    wrapLimit_h = (unit_h * val_h) + (unit_h * 0.5);

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
