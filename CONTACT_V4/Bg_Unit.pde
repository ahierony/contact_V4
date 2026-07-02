
class Bg_Unit {
  
  PApplet app;

  PVector pos;
  PVector posStatic;

  boolean containsVehicle = false;
  boolean doUpdateVehicle = false;

  boolean readyToCreateAgent;

  boolean overlap;
  color c;

  //Vehicle vehicle;
  Agent agent;
  Environment environment;

  int index;

  PVector randomPos;
  PVector basicPos;

  boolean containsAgent = false;
  boolean containsEnvironment = false;

  //PlayerTrail trailLeft;
  //PlayerTrail trailRight;

  // Constructor
  //Bg_Unit(float tempX, float tempY, boolean _containsVehicle, int _index) {
  Bg_Unit(float tempX, float tempY, boolean _containsAgent, boolean _containsEnvironment, int _index, PApplet app) {

    pos = new PVector(tempX, tempY);
    posStatic = new PVector(tempX, tempY);

    index = _index;

    //containsVehicle = _containsVehicle;

    if (_containsAgent) {
      containsAgent = true;
      containsVehicle = true;
      createAgent();
    }

    if (_containsEnvironment) {
      containsEnvironment = true;
      containsVehicle = true;
      createEnvironment(app);
    }

    /*

    if (containsVehicle) {

      if (index%2 == 0) {

        containsEnvironment = true;
        createEnvironment();

        //containsAgent = true;
        //createAgent();

        //createVehicle(true, "DYNAMIC"); // true
      } else {

        containsEnvironment = true;
        createEnvironment();
        //createVehicle(false, "STATIC"); // false
      }
     
    }
    
     */

    overlap = false;

    readyToCreateAgent = false;

    //Vec2 pPos = box2d.getBodyPixelCoord(player.centerSphere.body);

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

    //if (debugMode)
    rect(0, 0, unit_w, unit_h); // display grid
    //println("unit_w in rect ", unit_w);

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

  void createAgent() {

    float vehicleRadius_w = ((unit_w*.3)*0.5)*0.7;
    float vehicleRadius_h = ((unit_h*.3)*0.5)*0.7;
    int vehicleColorNum = int(random(0, 360)); // 0, 45, 90, 135, 180, 225, 270, 315

    PVector unitPos = new PVector(pos.x, pos.y);

    PVector offset = new PVector(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);
    unitPos.add(offset);

    float bufferW = unit_w * 0.1;
    float bufferH = unit_h * 0.1;
    PVector tempPos = new PVector(random(vehicleRadius_w + bufferW, unit_w-vehicleRadius_w - bufferW), random(vehicleRadius_h + bufferW, unit_h-vehicleRadius_h- bufferH));
    float sizeHalf_w = unit_w * 0.5;
    float sizeHalf_h = unit_h * 0.5;
    randomPos = new PVector(unitPos.x - sizeHalf_w + tempPos.x, unitPos.y - sizeHalf_h + tempPos.y);

    //PVector centerPos = new PVector(unitPos.x - sizeHalf_w, unitPos.y - sizeHalf_h);

    basicPos = PVector.sub(randomPos, unitPos);
    
    
     int agentIndex;
    if (agents.size() == 0) {
      agentIndex = 1;
    } else {
      agentIndex = agents.size();
    }
    //int agentIndex = agents.size() +1;
    println("agentIndex unit", agentIndex);
    agent = new Agent(randomPos.x, randomPos.y, vehicleColorNum, true, "DYNAMIC", index, player, agentIndex);
    agents.add(agent);
  }

  void createEnvironment(PApplet app) {

    float vehicleRadius_w = ((unit_w*.3)*0.5)*0.7;
    float vehicleRadius_h = ((unit_h*.3)*0.5)*0.7;
    
    
    int[] possibleColors = {0, 45, 90, 135, 180, 225, 270, 315};
    int randomCol = int(random(possibleColors.length));
    int vehicleColorNum = possibleColors[randomCol];
    //int vehicleColorNum = int(random(0, 360)); // 0, 45, 90, 135, 180, 225, 270, 315

    PVector unitPos = new PVector(pos.x, pos.y);

    PVector offset = new PVector(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);
    unitPos.add(offset);

    float bufferW = unit_w * 0.1;
    float bufferH = unit_h * 0.1;
    PVector tempPos = new PVector(random(vehicleRadius_w + bufferW, unit_w-vehicleRadius_w - bufferW), random(vehicleRadius_h + bufferW, unit_h-vehicleRadius_h- bufferH));
    float sizeHalf_w = unit_w * 0.5;
    float sizeHalf_h = unit_h * 0.5;
    randomPos = new PVector(unitPos.x - sizeHalf_w + tempPos.x, unitPos.y - sizeHalf_h + tempPos.y);

    //PVector centerPos = new PVector(unitPos.x, unitPos.y);

    basicPos = PVector.sub(randomPos, unitPos);
    
    
    int agentIndex;
    if (agents.size() == 0) {
      agentIndex = 1;
    } else {
      agentIndex = agents.size();
    }
    //int environmentIndex = environments.size() + 1;
    //println("environmentIndex ", environmentIndex);
    environment = new Environment(randomPos.x, randomPos.y, vehicleColorNum, false, "STATIC", index, player, agentIndex, app);
    environments.add(environment);
  }


  //--------------------------------------------------------------

  void wrapVehicle() {
    
    if (containsAgent) {
      agent.v.killBlob();
    } else if (containsEnvironment) {
      environment.v.killBlob();
    }

    PVector unitPos = new PVector(pos.x, pos.y);
    PVector offset = new PVector(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);
    unitPos.add(offset);
    unitPos.add(basicPos);

    Vec2 unitPosVecPixels = new Vec2(unitPos.x, unitPos.y);

    if (containsAgent) {
      agent.v.makeBlob(unitPosVecPixels);
    } else if (containsEnvironment) {
      environment.v.makeBlob(unitPosVecPixels);
      environment.updatePosition(unitPos.x, unitPos.y);
    }
  }
}
