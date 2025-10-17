
class Player {

  // A list to keep track of all the bodies and joints
  //PlayerSphere[] spheres;
  ArrayList<PlayerSphere> spheres;
  ArrayList<Joint> joints;
  // ArrayList<Joint> sideJoints;
  RevoluteJoint revoluteJoint;

  float centerSphereRadius;
  float sphereRadius;  // The radius of each body that makes up the skeletonadius;
  float radius;      // The radius of the entire blob
  int totalPoints; // How many points make up the blob

  Eye leftEye;
  Eye rightEye;
  PlayerSphere centerSphere;
  PlayerSphere jointSphere;

  Breath breath;

  float vehicleForce;
  int vehicleForceDirection;

  float len;
  float radiusBig, radiusSmall;

  boolean switchSides = true;

  // COLOR WHEEL
  int segmentCount = 8;
  int colorWheelRadius = 150;
  int colorWheelAngle = 180;

  boolean gettingMaxVelocityLength;
  float maxVelocityLength;

  float theta;

  float maxVelLength;

  boolean inVehicleDistanceZone;

  float blobRadius;
  float eyeRadius;

  boolean vehicleMoving;

  float unitHalf_w;
  float unitHalf_h;

  boolean enteredTheVehicleZone;

  boolean playerMoving;

  boolean vehicleInDistanceArea;
  boolean vehicleInBreathingArea;

  boolean playerTouchedVehicle;

  float blobBrightness;
  float eyeBrightness;
  boolean blobIsBright;

  float playerTheta;

  boolean eyesAreInverted;

  float breathingOffset;
  float distanceOffset;

  boolean isCruising;

  // SOUNDS
  boolean startZoneEnterSound;

  Timer calibrateEyesTimer;
  float calibrateLungRadius;
  boolean resetEyes;

  int brightness;
  int saturation;

  PlayerLung lung;
  PlayerArea area;
  PlayerLocation location;
  PlayerMotion motion;

  float minVel;

  String lockedEye;

  //float areaRadius;

  boolean readyToUpdateDistanceArea;

  float borderRadiusMin;
  float borderRadiusMax;

  //Track data
  boolean checkForVehiclesMovingInOutofPlayerArea;

  PlayerTrail trailLeft;
  PlayerTrail trailRight;

  boolean engagedInImpulse;

  color strokeColor;
  color fillColor;

  color leftEyeColor;
  color rightEyeColor;

  int left_minRangeX = 0;
  int left_maxRangeX = 1023;
  int left_minRangeY = 0;
  int left_maxRangeY = 1023;
  int right_minRangeX = 0;
  int right_maxRangeX = 1023;
  int right_minRangeY = 0;
  int right_maxRangeY = 1023;

  // ********************************************************
  // CONSTRUCTOR
  // ********************************************************

  Player() {

    unitHalf_w = unit_w * 0.5;
    unitHalf_h = unit_h * 0.5;
    readyToUpdateDistanceArea = true;

    borderRadiusMin = (unit_w*unitRowMax)*0.4;
    borderRadiusMax = (unit_w*unitRowMin) * 0.6;

    // Create the empty ArrayLists
    //spheres = new PlayerSphere[0];
    spheres = new ArrayList<PlayerSphere>();
    joints = new ArrayList<Joint>();
    //sideJoints = new ArrayList<Joint>();

    breath = new Breath("player");

    makeBlob();

    maxVelocityLength = 0;
    gettingMaxVelocityLength = false;

    maxVelLength = 0;

    inVehicleDistanceZone = false;

    vehicleMoving = false;

    blobRadius = radius + sphereRadius;

    //println("blobRadius ", blobRadius);

    enteredTheVehicleZone = false;

    playerMoving = false;

    playerTouchedVehicle = false;

    eyesAreInverted = false;

    blobBrightness = 100;
    eyeBrightness = 100;

    breathingOffset = 10;

    isCruising = false;

    // SOUNDS
    startZoneEnterSound = true;

    calibrateEyesTimer = new Timer(5000);
    calibrateLungRadius = 0;
    resetEyes = false;

    brightness = 100;
    saturation = 100;

    minVel = 10;

    lockedEye = "none";

    lung = new PlayerLung(this);
    area = new PlayerArea(this);
    location = new PlayerLocation(this);
    motion = new PlayerMotion(this);

    lung.previousRadius = lung.radiusMax;

    //track data
    checkForVehiclesMovingInOutofPlayerArea = true;

    Vec2 pPos = box2d.getBodyPixelCoord(centerSphere.body);
    trailLeft = new PlayerTrail(pPos.x, pPos.y);
    trailRight = new PlayerTrail(pPos.x, pPos.y);

    engagedInImpulse = false;
    //
  } // constructor

  // ********************************************************
  // UPDATE
  // ********************************************************

  void update(float _theta) {


    //println("player lung state ", player.lung.getState());

    playerTheta = _theta;


    updateEyeColor();

    // -------------------------------------

    /*
    if (!gamePadIsOn) {
     
     calibrateEyes();
     }
     */

    updateColorOnRotation(playerTheta);

    //setLockEyeState();

    setMotionState();

    location.update();


    leftEye.update(this);
    rightEye.update(this);

    setLockEyeState();

    centerSphere.update();

    for (int i=0; i < spheres.size(); i++) {
      //PlayerSphere sphere = spheres[i];
      PlayerSphere sphere = spheres.get(i);
      sphere.update();
    }


    lung.update();
    area.update();

    //areaRadius = area.radius;



    motion.update();



    if (location.getState() == location.pLocMovingState || location.getState() == location.pLocVehicleZoneState) {

      area.setState(area.notBreathingState);
    } else if (location.getState() == location.pLocBreathingState) {

      area.setAreaState();

      checkForVehicleInArea();
    }




    //updateTrail();
  } // update()

  // ********************************************************
  // DELETE PLAYER
  // ********************************************************

  void killBlob() {

    for (int i=0; i < spheres.size(); i++) {
      PlayerSphere sphere = spheres.get(i);
      sphere.killBody();
    }

    centerSphere.killBody();
    jointSphere.killBody();

    spheres.clear();
    joints.clear();
  }


  // ********************************************************
  // METHODS CALLED FROM UPDATE
  // ********************************************************
  /*
  void updateTrail() {
  /*
   Vec2 centerPos;
   centerPos = box2d.getBodyPixelCoord(centerSphere.body);
   trail.update(centerPos.x, centerPos.y, colorWheelAngle, 155);
   */  /*
    Vec2 leftPos;
   leftPos = box2d.getBodyPixelCoord(leftEye.eyeOuterb2d.body);
   trailLeft.update(leftPos.x, leftPos.y, getLinearVelocity());
   
   Vec2 rightPos;
   rightPos = box2d.getBodyPixelCoord(rightEye.eyeOuterb2d.body);
   trailRight.update(rightPos.x, rightPos.y, getLinearVelocity());
   }
   */

  //--------------------------------------------------------------
  /*
  void calibrateEyes() {
   
   if (!resetEyes) {
   calibrateEyesTimer.start();
   calibrateLungRadius = lung.radius;
   resetEyes = true;
   }
   
   if (calibrateEyesTimer.isFinished()) {
   if (calibrateLungRadius == lung.radius) {
   leftEye.resetCalibration();
   rightEye.resetCalibration();
   leftEye.resetEye();
   rightEye.resetEye();
   }
   resetEyes = false;
   }
   }
   */

  //--------------------------------------------------------------

  void updateColorOnRotation(float t) {

    int newAngle = int(degrees(t));

    colorWheelAngle = newAngle;

    // make sure angle is between 0-360
    if (newAngle < 0) {
      colorWheelAngle += 360;
    }

    theta = t;

    centerSphere.applyColorWheel(colorWheelAngle);
  }

  //--------------------------------------------------------------

  void setLockEyeState() {

    if (leftEye.pupilState == "locked" && rightEye.pupilState == "locked") {
      lockedEye = "both";
    } else if (leftEye.pupilState == "locked" && rightEye.pupilState == "unlocked") {
      lockedEye = "left";
    } else if (leftEye.pupilState == "unlocked" && rightEye.pupilState == "locked") {
      lockedEye = "right";
    } else if (leftEye.pupilState == "unlocked" && rightEye.pupilState == "unlocked") {
      lockedEye = "none";
    }
  }

  //--------------------------------------------------------------

  void setMotionState() {

    if (lung.getState() == lung.exhaleState) { // probably needs to be inverted: if accel than exhale and not the opposite

      motion.setState(motion.pMotionAccelState);
    } else {

      if (lockedEye == "none") {

        motion.setState(motion.pMotionStillState);
      } else {

        motion.setState(motion.pMotionRotateState);
      }
    }
  }

  //--------------------------------------------------------------

  float getLinearVelocity() {

    Vec2 velVec = centerSphere.body.getLinearVelocity();
    //float vel = velVec.lengthSquared();
    float vel = velVec.length();
    return  vel;
  }


  // ********************************************************
  // VEHICLE IN PLAYER AREA
  // ********************************************************

  void checkForVehicleInArea() {

    vehicleInDistanceArea = false;
    vehicleInBreathingArea = false;

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      if (v.inMotion) {

        if (v.inPlayerDistanceArea) {

          vehicleInDistanceArea = true;

          if (v.inPlayerBreathingArea) {
            vehicleInBreathingArea = true;

            if (playSound) {
              if (checkForVehiclesMovingInOutofPlayerArea) {
                data.trackVehicleInArea(true);
                checkForVehiclesMovingInOutofPlayerArea = false;
              }
            }
          }
        }
      }
    }

    if (!vehicleInDistanceArea) {
      vehicleInBreathingArea = false;

      if (playSound) {
        if (!checkForVehiclesMovingInOutofPlayerArea) {
          data.trackVehicleInArea(false);
          checkForVehiclesMovingInOutofPlayerArea = true;
        }
      }
    }
  }

  //--------------------------------------------------------------

  void updateAccelBoth() {

    rightEye.eyeOuterb2d.applyForce(rightEye.outerTheta, playerTheta, rightEye.getCurrentForce(), true, eyesAreInverted);
    leftEye.eyeOuterb2d.applyForce(leftEye.outerTheta, playerTheta, leftEye.getCurrentForce(), true, eyesAreInverted);
  }

  //--------------------------------------------------------------

  void updateAccel(Eye lockedEye) {

    lockedEye.eyeOuterb2d.applyForce(lockedEye.outerTheta, playerTheta, lockedEye.getCurrentForce(), false, eyesAreInverted);
  }

  //--------------------------------------------------------------

  void updateInVehicleDistanceZone() {

    // first entrance into zone
    if (!enteredTheVehicleZone) {

      enteredTheVehicleZone = true;

      if (leftEye.pupilState == "locked") {
        leftEye.resetEye();
      }

      if (rightEye.pupilState == "locked") {
        rightEye.resetEye();
      }
    }
    jointSphere.body.setType(BodyType.DYNAMIC);
  }


  //--------------------------------------------------------------

  void updateInputJoystick(int left_xAxis, int left_yAxis, int right_xAxis, int right_yAxis ) {
    /*
    left_minRangeX = 390;
     left_maxRangeX = 670;
     left_minRangeY = 370;
     left_maxRangeY = 570;
     right_minRangeX = 360;
     right_maxRangeX = 630;
     right_minRangeY = 360;
     right_maxRangeY = 650;
     */

    if (leftEye.coltxt == "red") {

      leftEye.updateJoystickInput(left_xAxis, left_yAxis, left_minRangeX, left_maxRangeX, left_minRangeY, left_maxRangeY);
      rightEye.updateJoystickInput(right_xAxis, right_yAxis, right_minRangeX, right_maxRangeX, right_minRangeY, right_maxRangeY);

      eyesAreInverted = false;
    } else if (leftEye.coltxt == "green") {

      leftEye.updateJoystickInput(right_xAxis, right_yAxis, right_minRangeX, right_maxRangeX, right_minRangeY, right_maxRangeY);
      rightEye.updateJoystickInput(left_xAxis, left_yAxis, left_minRangeX, left_maxRangeX, left_minRangeY, left_maxRangeY);

      eyesAreInverted = true;
    }
  }

  void updateInputGamePad(float yawLeft, float rollLeft, float yawRight, float rollRight) {

    if (leftEye.coltxt == "red") {

      leftEye.updateInputGamePad(yawLeft, rollLeft);
      rightEye.updateInputGamePad(yawRight, rollRight);

      eyesAreInverted = false;
    } else if (leftEye.coltxt == "green") {

      leftEye.updateInputGamePad(yawRight, rollRight);
      rightEye.updateInputGamePad(yawLeft, rollLeft);

      eyesAreInverted = true;
    }
  }
  /*
  void updateInputSensor(float yawLeft, float rollLeft, float pitchLeft, float yawRight, float rollRight, float pitchRight) {
   
   if (leftEye.coltxt == "red") {
   
   leftEye.updateInputSensor(yawLeft, rollLeft, pitchLeft);
   rightEye.updateInputSensor(yawRight, rollRight, pitchRight);
   
   eyesAreInverted = false;
   } else if (leftEye.coltxt == "green") {
   
   leftEye.updateInputSensor(yawRight, rollRight, pitchRight);
   rightEye.updateInputSensor(yawLeft, rollLeft, pitchRight);
   
   eyesAreInverted = true;
   }
   }
   */

  // ********************************************************
  // DISPLAY
  // ********************************************************

  void display() {

    //updateColor();

    // trailLeft.display();
    // trailRight.display();

    if (debugMode)
      displayBorderRadius();

    if (area.isVisible) {

      area.display();
    }

    displayBlob();

    lung.display();

    //displayJoints();

    //displaySpheres();

    displayEyes();
  }

  //--------------------------------------------------------------

  void displayBorderRadius() {

    Vec2 pos = box2d.getBodyPixelCoord(player.centerSphere.body);

    pushMatrix();

    translate(pos.x, pos.y);

    noFill();
    strokeWeight(2);
    stroke(0);
    //stroke(200);
    circle(0, 0, borderRadiusMin);
    circle(0, 0, borderRadiusMax);

    popMatrix();
  }

  //--------------------------------------------------------------

  void displayBlob() {

    int colorAngle = colorWheelAngle;


    if (lung.getState() == lung.exhaleState) {

      colorAngle = colorWheelAngle;
      colorAngle += 180;
      colorAngle %= 360;
    }


    int many = spheres.size()-1;

    Vec2 pos;

    beginShape();
    noFill();
    strokeWeight(sphereRadius*2);
    stroke(colorAngle, saturation, blobBrightness);
    fill(colorAngle, saturation, blobBrightness);

    pos = box2d.getBodyPixelCoord(spheres.get(many-1).body);
    //pos = box2d.getBodyPixelCoord(spheres[many - 1].body);
    pos.x = int(pos.x);
    pos.y = int(pos.y);

    curveVertex(pos.x, pos.y); // begin control point

    for (int i = 0; i <= many; i++) {

      Body b = spheres.get(i).body;
      //Body b = spheres[i].body;
      // We look at each body and get its screen position
      pos = box2d.getBodyPixelCoord(b);
      pos.x = int(pos.x);
      pos.y = int(pos.y);

      curveVertex(pos.x, pos.y);
    }

    pos = box2d.getBodyPixelCoord(spheres.get(1).body);
    //pos = box2d.getBodyPixelCoord(spheres[1].body);
    pos.x = int(pos.x);
    pos.y = int(pos.y);

    curveVertex(pos.x, pos.y);

    endShape(); // with or without cp,  not use CLOSE

    strokeWeight(2);
  }

  //--------------------------------------------------------------

  void updateEyeColor() {

    int oppositeColorAngle;

    strokeColor = color(colorWheelAngle, saturation, 25);
    fillColor = color(colorWheelAngle, saturation, blobBrightness);

    oppositeColorAngle = colorWheelAngle;

    oppositeColorAngle -= 180;

    if (oppositeColorAngle < 0) {
      oppositeColorAngle += 360;
    }

    if (lockedEye == "left") {

      leftEyeColor = color(oppositeColorAngle, saturation, blobBrightness);
      rightEyeColor = color(colorWheelAngle, saturation, blobBrightness);
    } else if (lockedEye == "right") {

      leftEyeColor = color(colorWheelAngle, saturation, blobBrightness);
      rightEyeColor = color(oppositeColorAngle, saturation, blobBrightness);
    } else if (lockedEye == "both" && player.location.getState() != player.location.pLocVehicleZoneState) {

      leftEyeColor = color(oppositeColorAngle, saturation, blobBrightness);
      rightEyeColor = color(oppositeColorAngle, saturation, blobBrightness);
    } else {

      leftEyeColor = color(colorWheelAngle, saturation, blobBrightness);
      rightEyeColor = color(colorWheelAngle, saturation, blobBrightness);
    }

    leftEye.updateColor(colorWheelAngle, strokeColor, leftEyeColor);
    rightEye.updateColor(colorWheelAngle, strokeColor, rightEyeColor);
  }

  //--------------------------------------------------------------

  void displayEyes() {

    leftEye.display();
    rightEye.display();
  }

  //--------------------------------------------------------------

  // Draw the skeleton as circles for bodies and lines for joints
  void displaySpheres() {

    centerSphere.display();

    for (int i=0; i < spheres.size(); i++) {
      PlayerSphere sphere = spheres.get(i);
      sphere.display();
    }
  }

  //--------------------------------------------------------------
  /*
  void displayJoints() {
   
   // Draw the outline
   stroke(126);
   strokeWeight(1);
   for (Joint j : joints) {
   Body a = j.getBodyA();
   Body b = j.getBodyB();
   Vec2 posa = box2d.getBodyPixelCoord(a);
   Vec2 posb = box2d.getBodyPixelCoord(b);
   line(posa.x, posa.y, posb.x, posb.y);
   }
   
   // Draw the outline
   stroke(126);
   strokeWeight(1);
   for (Joint j : sideJoints) {
   Body a = j.getBodyA();
   Body b = j.getBodyB();
   Vec2 posa = box2d.getBodyPixelCoord(a);
   Vec2 posb = box2d.getBodyPixelCoord(b);
   line(posa.x, posa.y, posb.x, posb.y);
   }
   }
   */
  // ********************************************************
  // CREATION
  // ********************************************************

  void makeBlob() {

    ConstantVolumeJointDef cvjd = new ConstantVolumeJointDef();

    // Where and how big is the blob
    Vec2 center = new Vec2(0, 0);
    radius = 100;
    totalPoints = 32;
    sphereRadius = 50; //25;
    centerSphereRadius = 50;

    // ****

    centerSphere = new PlayerSphere(center.x, center.y, centerSphereRadius, "DYNAMIC", CATEGORY_PLAYER, MASK_PLAYER);
    jointSphere = new PlayerSphere(center.x, center.y, centerSphereRadius, "DYNAMIC", CATEGORY_PLAYER, MASK_PLAYER);

    createRevoluteJoint(centerSphere.body, jointSphere.body);

    // make body

    // Initialize all the points in a circle
    for (int i = 0; i <= totalPoints; i++) {

      // Look polar to cartesian coordinate transformation!
      float t = TWO_PI * (float)i/totalPoints;
      float x = center.x + radius * sin(t);
      float y = center.y + radius * cos(t);

      if (i == 8) {
        rightEye = new Eye(x, y, "green");
        //spheres.add(new VehicleSphere(x, y, sphereRadius, "DYNAMIC", CATEGORY_VEHICLE, MASK_VEHICLE));
        spheres.add(rightEye.eyeOuterb2d);
        //spheres = (PlayerSphere[]) append(spheres, rightEye.eyeOuterb2d);
        // this is the free joint for fast and simple movement
        createDistanceJoints(rightEye.eyeInnerb2d.body, rightEye.eyeOuterb2d.body);

        cvjd.addBody(spheres.get(i).body);
      } else if (i == 24) {

        leftEye = new Eye(x, y, "red");
        spheres.add(leftEye.eyeOuterb2d);
        //spheres = (PlayerSphere[]) append(spheres, leftEye.eyeOuterb2d);
        // this is the free joint for fast and simple movement
        createDistanceJoints(leftEye.eyeInnerb2d.body, leftEye.eyeOuterb2d.body);

        cvjd.addBody(spheres.get(i).body);
      } else {

        spheres.add(new PlayerSphere(x, y, sphereRadius, "DYNAMIC", CATEGORY_PLAYER, MASK_PLAYER));
        //spheres = (PlayerSphere[]) append(spheres, new PlayerSphere(x, y, sphereRadius, "DYNAMIC", CATEGORY_PLAYER, MASK_PLAYER));

        cvjd.addBody(spheres.get(i).body);
      }

      // joints

      //if (i == 0 || i == 8 || i == 16 || i == 24 ) {


      //if (i == 8 || i == 24 ) {

      if (i == 0 || i == 4 || i == 8 || i == 12 || i == 16 || i == 20 || i == 24 || i == 28) {

        createDistanceJoints(spheres.get(spheres.size()-1).body, centerSphere.body);
      }
    }

    // These properties affect how springy the joint is
    // frequencyHz (1-5) rigid: 0
    // dampingRation (0-1 rigid: 1

    cvjd.frequencyHz = 0; //10;
    cvjd.dampingRatio = 0.1; // 0.9

    //cvjd.frequencyHz = 0;
    //cvjd.dampingRatio = 0.05;

    cvjd.collideConnected = false;
    box2d.createJoint(cvjd);
  }

  //--------------------------------------------------------------

  void createRevoluteJoint(Body bodyCenter, Body bodyJoint) {

    // Define joint as between two bodies
    RevoluteJointDef rjd = new RevoluteJointDef();

    rjd.initialize(bodyCenter, bodyJoint, bodyCenter.getWorldCenter());

    // Turning on a motor (optional)
    //rjd.motorSpeed = PI*2;       // how fast?
    rjd.maxMotorTorque = 1000.0; // how powerful?
    rjd.enableMotor = false;      // is it on?

    //rjd.enableLimit = true;
    rjd.maxMotorTorque = 100.0f;

    // There are many other properties you can set for a Revolute joint
    // For example, you can limit its angle between a minimum and a maximum
    // See box2d manual for more


    // Create the joint
    revoluteJoint = (RevoluteJoint) box2d.world.createJoint(rjd);
  }

  //--------------------------------------------------------------

  void createDistanceJoints(Body a, Body b) {

    DistanceJointDef djd = new DistanceJointDef();
    djd.bodyA = a;
    djd.bodyB = b;

    // Equilibrium length is distance between these bodies
    Vec2 apos = a.getWorldCenter();
    Vec2 bpos = b.getWorldCenter();
    float d = dist(apos.x, apos.y, bpos.x, bpos.y);
    djd.length = d;

    // These properties affect how springy the joint is
    // frequencyHz (1-5) rigid: 0
    // dampingRation (0-1 rigid: 1

    djd.frequencyHz = 0;
    djd.dampingRatio = 0.5;

    // original blob
    //djd.frequencyHz = 4; //0; // 5
    //djd.dampingRatio =  0.5; //1;//0.9;

    //shiffman blob
    //djd.frequencyHz = 10;
    //djd.dampingRatio = 0.9;


    // Make the joint.
    DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);
    joints.add(dj);
  }
}
