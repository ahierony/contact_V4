
class Bg_Unit {

  PVector pos;
  PVector posStatic;

  boolean containsVehicle = false;
  boolean doUpdateVehicle = false;

  boolean readyToCreateAgent;

  boolean overlap;
  color c;

  Vehicle vehicle;

  int index;

  PVector randomPos;
  PVector basicPos;

  //PlayerTrail trailLeft;
  //PlayerTrail trailRight;

  // Constructor
  Bg_Unit(float tempX, float tempY, boolean _containsVehicle, int _index) {

    pos = new PVector(tempX, tempY);
    posStatic = new PVector(tempX, tempY);

    index = _index;

    containsVehicle = _containsVehicle;

    if (containsVehicle) {

      if (index%2 == 0) {

        createVehicle(false, "DYNAMIC"); // true
      } else {

        createVehicle(false, "DYNAMIC"); // false
      }
    }

    overlap = false;

    readyToCreateAgent = false;

    Vec2 pPos = box2d.getBodyPixelCoord(player.centerSphere.body);
    //trailLeft = new PlayerTrail(pPos.x, pPos.y);
    //trailRight = new PlayerTrail(pPos.x, pPos.y);
  }

  //--------------------------------------------------------------

  void display() {

    ellipseMode(RADIUS);
    rectMode(CENTER);

    pushMatrix();
    translate(pos.x, pos.y);

    //trailLeft.display();
    //trailRight.display();

    noFill();

    stroke(126);

    if (debugMode)
      rect(0, 0, unit_w, unit_h);

    popMatrix();
  }

  //--------------------------------------------------------------

  void updatePos(PVector vel) {

    pos.add(vel);

    //updateTrail();
  }

  //--------------------------------------------------------------
  /*
  void updateTrail() {
  /*
   Vec2 centerPos;
   centerPos = box2d.getBodyPixelCoord(centerSphere.body);
   trail.update(centerPos.x, centerPos.y, colorWheelAngle, 155);
   */
  /*
    Vec2 leftPos;
   leftPos = box2d.getBodyPixelCoord(player.leftEye.eyeOuterb2d.body);
   trailLeft.update(leftPos.x, leftPos.y);
   
   Vec2 rightPos;
   rightPos = box2d.getBodyPixelCoord(player.rightEye.eyeOuterb2d.body);
   trailRight.update(rightPos.x, rightPos.y);
   }
   */


  // CODE FOR VEHICLE ********************************************

  void createVehicle(boolean inMotion, String type) {

    float vehicleRadius_w = ((unit_w*.3)*0.5)*0.7;
    float vehicleRadius_h = ((unit_h*.3)*0.5)*0.7;
    int vehicleColorNum = int(random(0, 360)); // 0, 45, 90, 135, 180, 225, 270, 315
    /*
    int vehicleColorNum = int(random(0, 7));
     int[] colorNums = {0, 45, 90, 135, 180, 225, 270};
     vehicleColorNum = colorNums[vehicleColorNum];
     */

    PVector unitPos = new PVector(pos.x, pos.y);

    PVector offset = new PVector(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);
    unitPos.add(offset);


    PVector tempPos = new PVector(random(vehicleRadius_w, unit_w-vehicleRadius_w), random(vehicleRadius_h, unit_h-vehicleRadius_h));
    float sizeHalf_w = unit_w * 0.5;
    float sizeHalf_h = unit_h * 0.5;
    randomPos = new PVector(unitPos.x - sizeHalf_w + tempPos.x, unitPos.y - sizeHalf_h + tempPos.y);

    basicPos = PVector.sub(randomPos, unitPos);

    vehicle = new Vehicle(randomPos.x, randomPos.y, vehicleColorNum, inMotion, type, index, player);
    vehicles.add(vehicle);
  }

  //--------------------------------------------------------------

  void wrapVehicle() {

    PVector unitPos = new PVector(pos.x, pos.y);
    PVector offset = new PVector(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);
    unitPos.add(offset);
    unitPos.add(basicPos);

    Vec2 unitPosVecPixels = new Vec2(unitPos.x, unitPos.y);

    if (vehicle.location.getState() != vehicle.location.vInDeadState) {

      vehicle.killBlob();

      vehicle.makeBlob(unitPosVecPixels);

      vehicle.initialize();
    } else {
      
      vehicle.posVecPixels.set(unitPos.x, unitPos.y);
    }
  }
}
