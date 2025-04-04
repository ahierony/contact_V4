
enum Pupil_keyboard
{
  INNER, OUTER, INBETWEEN;
};

class Eye {

  Eye otherEye;

  EyeInner eyeCenter;
  //EyeInner eyeStretch;
  EyeOuter eyeOuter;
  EyeOuter eyeLid;
  EyePupil pupil;
  //EyePupil closingPupil;
  SensorHead head;

  float eyeOuterRadius;
  float eyeOuterRadius_stretch;
  float eyeInnerRadius;
  float eyeSensorRadius;
  float headRadius;

  color eyeOuterColor;
  color eyeInnerColor;
  color pupilColor;

  float sensorX, sensorY;
  float psensorX, psensorY;

  PVector pupilOuter;
  boolean isStretching;

  float theta;
  float outerTheta;
  float blobTheta;

  float friction;

  PlayerSphere eyeOuterb2d;
  PlayerSphere eyeInnerb2d;

  Timer pushTimer;
  Timer calibrateTimer;

  boolean resetEye;
  boolean floatingEye;
  boolean firstCircleEye;
  boolean secondCircleEye;

  boolean movementApplied;

  String coltxt = "";

  color red = color(360, 100, 100);
  color black = color(0, 0, 0);
  color white = color(0, 0, 100);
  color grey = color(0, 0, 48);
  color blue = color(195, 58, 78);

  color fillColor;
  color strokeColor;

  boolean resetLungToMin;

  String pupilState;

  float d; // distance between center of pupil and head
  float d_head_inner;
  boolean movementCompleted;

  float eyeOuterRadiusMin;
  float eyeOuterRadiusMax;

  boolean inHeadLock;

  boolean calibrateSensor;

  float calibrateX;
  float calibrateY;

  Player player;

  float currentForce;

  PVector s;
  PVector e;

  boolean recordOriginalSensorAngle;
  float originalSensorAngle;

  // KEYBOARD CONTROLS
  float angle_k;
  float rotationSpeed_k;
  float speed_k, speedX_k, speedY_k;
  float theta_k;
  boolean readyToRotate_k;

  Pupil_keyboard pupil_keyboard;

  boolean inImpulse;

  //

  Eye(float _x, float _y, String _coltxt) {

    eyeOuterRadius = 50;
    eyeOuterRadius_stretch = eyeOuterRadius*2;
    eyeInnerRadius = 20;
    eyeSensorRadius = 14;
    headRadius = 5;
    theta = 0;

    eyeOuterColor = grey;
    eyeInnerColor = color(360);
    pupilColor = color(201, 30, 92);

    eyeOuter = new EyeOuter(0, 0, eyeOuterRadius);
    eyeLid = new EyeOuter(0, 0, eyeOuterRadius);
    eyeCenter = new EyeInner(0, 0, eyeInnerRadius);
    //eyeStretch = new EyeInner(0, 0, eyeInnerRadius); // 2nd circle to be removed
    pupil = new EyePupil(0, 0, eyeInnerRadius);
    //closingPupil = new EyePupil(0, 0, eyeInnerRadius);
    head = new SensorHead(0, 0, headRadius);

    pupilOuter = new PVector(0, 0);

    isStretching = false;

    Vec2 center = new Vec2(_x, _y);

    eyeOuterb2d = new PlayerSphere(center.x, center.y, eyeOuterRadius, "DYNAMIC", CATEGORY_PLAYER, MASK_PLAYER);
    eyeInnerb2d = new PlayerSphere(center.x, center.y, eyeInnerRadius, "DYNAMIC", CATEGORY_PLAYER, MASK_PLAYER);

    pushTimer = new Timer(1000);
    calibrateTimer = new Timer(3000);

    movementApplied = false;

    coltxt = _coltxt;

    resetEye = false;
    floatingEye = false;
    firstCircleEye = false;
    secondCircleEye = false;

    resetLungToMin = false;

    pupilState = "unlocked";

    movementCompleted = false;

    inHeadLock = false;

    //KEYBOARD
    rotationSpeed_k = 5;
    speed_k = 2;
    angle_k = 0;
    theta_k = radians(angle_k);
    readyToRotate_k = true;

    /*
    if (inputControls == InputControls.GAMEPAD) {
     calibrateSensor = true;
     calibrateX = 0;
     calibrateY = 0;
     calibrateTimer.start();
     }
     */

    currentForce = 0; //0;

    s = new PVector(0, 0);
    e = new PVector(0, 0);

    eyeOuterRadiusMax = eyeOuterRadius*2;

    psensorX = 2000;//1000
    psensorY = 2000;//1000

    sensorX = 0;
    sensorY = 0;

    recordOriginalSensorAngle = true;
  }

  //--------------------------------------------------------------


  void updateInputGamePad(float _x, float _y) {

    float gamePadRange = 1.3;

    float eyeDiameter = eyeOuterRadius*2;

    sensorX = map(_x, -gamePadRange, gamePadRange, -eyeDiameter, eyeDiameter);
    sensorY = map(_y, -gamePadRange, gamePadRange, -eyeDiameter, eyeDiameter);
    //
  }

  //--------------------------------------------------------------

  void updateJoystickInput(int _x, int _y) {


    //float sensorRange = 20;

    sensorX = map(_x, 0, 1023, -eyeOuterRadius, eyeOuterRadius);
    sensorY = map(_y, 0, 1023, -eyeOuterRadius, eyeOuterRadius);
  }

  //--------------------------------------------------------------

  void update(Player p) {


    player = p;


    if (inputControls == InputControls.KEYBOARD) {

      if (player.location.getState() == player.location.pLocVehicleZoneState) {

        applyPush_k();
      } else {

        setPupilState_k(); // if player is not in vehicle zone or has a vehicle in area
      }

      //
    } else if (inputControls == InputControls.JOYSTICKS) {

      head.pos.x = sensorX;
      head.pos.y = sensorY;

      if (player.location.getState() == player.location.pLocVehicleZoneState) {

        applyPush();
      } else {

        setPupilState(); // if player is not in vehicle zone or has a vehicle in area
      }
    }

    //

    pupil.updateColor(strokeColor);
    eyeLid.updateColor(fillColor, strokeColor);
  } // update

  //--------------------------------------------------------------

  void setPupilState() {

    s = s.set(sensorX, sensorY);
    e = e.set(eyeOuter.x, eyeOuter.y);

    float d = dist(s.x, s.y, eyeOuter.x, eyeOuter.y);

    if (!head.intersectsOuter(eyeCenter)) { // start acceleration

      if (pupilState == "unlocked") {

        pupilState = "locked";
      }


      if (d >= eyeOuter.radius/2) { // is head is outside eyeOuter radius

        s.sub(e);
        s.normalize();
        s.mult(eyeOuter.radius-eyeInnerRadius);
        s.add(e);
      }

      float h3 = sqrt(pupil.pos.x * pupil.pos.x + pupil.pos.y * pupil.pos.y);

      if (h3 > 0) {

        currentForce = map(h3, eyeCenter.radius, eyeOuterRadius*2 - eyeInnerRadius, 0, 1000000);

        float t = atan2(pupil.pos.y, pupil.pos.x);
        outerTheta = t;
      }
    } else if (head.intersectsOuter(eyeCenter)) { // head is in center of the eye


      if (pupilState == "locked") {

        pupilState = "unlocked";
      }

      setCurrentForce(0);
    }

    pupil.pos.x = s.x;
    pupil.pos.y = s.y;
  }

  //--------------------------------------------------------------

  void setPupilState_k() {

    if (pupil_keyboard == Pupil_keyboard.INBETWEEN) {
    } else if (pupil_keyboard == Pupil_keyboard.INNER) {

      if (pupilState == "locked") {

        pupilState = "unlocked";
      }

      setCurrentForce(0);
    } else if (pupil_keyboard == Pupil_keyboard.OUTER) {

      if (pupilState == "unlocked") {

        pupilState = "locked";
      }

      float h3 = sqrt(pupil.pos.x * pupil.pos.x + pupil.pos.y * pupil.pos.y);

      if (h3 > 0) {

        currentForce = map(h3, eyeCenter.radius, eyeOuterRadius*2 - eyeInnerRadius, 0, 1000000);

        float t = atan2(pupil.pos.y, pupil.pos.x);
        outerTheta = t;
      }
    }
  }

  //--------------------------------------------------------------

  void applyPush() {

    if (pupilState == "unlocked") {

      pupil.pos.x = sensorX;
      pupil.pos.y = sensorY;

      if (!pupil.intersectsInner(eyeOuter)) {

        pupilState = "locked";


        if(!player.engagedInImpulse){
          inImpulse = true;
          applyImpulse();
        }


        // lock pupil position
        pupil.pos.x = (eyeOuterRadius - eyeInnerRadius) * cos(theta);
        pupil.pos.y = (eyeOuterRadius - eyeInnerRadius) * sin(theta);

        pushTimer.start();
      }
    } else {

      if (pushTimer.isFinished()) {
        pupilState = "unlocked";
        //inImpulse = false;
      }
    }
  }

  //--------------------------------------------------------------

  void applyPush_k() {

    if (pupilState == "unlocked") {

      if (pupil_keyboard == Pupil_keyboard.OUTER) {

        pupilState = "locked";

        
        if(!player.engagedInImpulse){
          inImpulse = true;
          applyImpulse();
        }


        pushTimer.start();
      }
    } else {

      if (pushTimer.isFinished()) {
        pupilState = "unlocked";
        //inImpulse = false;
      }
    }
    
    
  }


  //--------------------------------------------------------------
  float getCurrentForce() {

    return currentForce;
  }

  //--------------------------------------------------------------
  void setCurrentForce(float cf) {

    currentForce = cf;
  }

  //--------------------------------------------------------------

  void applyImpulse() {

    theta = atan2(pupil.pos.y, pupil.pos.x);

    eyeOuterb2d.applyLinearImpulse(theta);
  }

  //--------------------------------------------------------------

  void resetEye() {

    movementApplied = false;
    movementCompleted = false;

    pupilState = "unlocked";
    eyeLid.h = eyeOuterRadiusMax;
  }

  //--------------------------------------------------------------

  void resetCalibration() {

    calibrateSensor = true;
  }

  //--------------------------------------------------------------

  void display(float t, color _strokeColor, color _fillColor) {

    strokeColor = _strokeColor;
    fillColor = _fillColor;

    blobTheta = t;

    pushMatrix();

    translate(eyeOuterb2d.posVecPixels.x, eyeOuterb2d.posVecPixels.y);

    if (debugMode) {

      eyeOuter.display();
      eyeCenter.display();

      if (pupilState == "locked") {

        stroke(360);
      }
      eyeLid.display();
      pupil.display();
      head.display();
    } else {
      fill(0, 0, 99);

      stroke(fillColor);
      circle(0, 0, 50);

      eyeLid.display();
      pupil.display();
    }

    if (inputControls == InputControls.KEYBOARD) {

      rotate(theta_k);
      stroke(strokeColor);
      line(0, 0, 0, 0 - eyeOuterRadius);
      noFill();
      circle(0, 0, pupil.radius);
    }

    popMatrix();
  }

  //--------------------------------------------------------------

  void rotateLine(String direction) {

    if (direction == "left") {
      angle_k -= rotationSpeed_k;
    } else if (direction == "right") {
      angle_k += rotationSpeed_k;
    }

    theta_k = radians(angle_k);
  }

  //--------------------------------------------------------------

  void movePupil_k(String direction) {

    speedX_k = -speed_k * cos(theta_k - radians(-90));
    speedY_k = -speed_k * sin(theta_k - radians(-90));

    if (direction == "up") {

      pupil_keyboard = Pupil_keyboard.INBETWEEN;

      if (!intersectsOuter()) {

        pupil_keyboard = Pupil_keyboard.OUTER;

        // lock pupil position
        pupil.pos.x = -(eyeOuterRadius - pupil.radius) * cos(theta_k - radians(-90));
        pupil.pos.y = -(eyeOuterRadius - pupil.radius) * sin(theta_k - radians(-90));
        //readyToRotate_k = true;
      } else {
        readyToRotate_k = false;
      }

      pupil.pos.x += speedX_k;
      pupil.pos.y += speedY_k;
    } else if (direction == "down") {

      pupil_keyboard = Pupil_keyboard.INBETWEEN;

      if (!intersectsInner()) {

        pupil_keyboard = Pupil_keyboard.INNER;

        // lock pupil position
        pupil.pos.x = 0;
        pupil.pos.y = 0;

        readyToRotate_k = true;
        
        inImpulse = false;
      } else {
        readyToRotate_k = false;
      }

      pupil.pos.x -= speedX_k;
      pupil.pos.y -= speedY_k;
    }

    //println("pupil keyboard ", pupil_keyboard);
  }


  //--------------------------------------------------------------

  boolean intersectsOuter() {

    float dist = dist(pupil.pos.x, pupil.pos.y, 0, 0 );
    dist += pupil.radius;

    if (dist <= eyeOuterRadius) {
      return true;
    } else {
      return false;
    }
  }

  //--------------------------------------------------------------

  boolean intersectsInner() {

    PVector outerEdge = new PVector(0, 0);

    outerEdge.x = -(eyeOuterRadius - pupil.radius) * cos(theta_k - radians(-90));
    outerEdge.y = -(eyeOuterRadius - pupil.radius) * sin(theta_k - radians(-90));

    float dist = dist(pupil.pos.x, pupil.pos.y, outerEdge.x, outerEdge.y);
    //dist += headRadius;
    dist += pupil.radius;

    if (dist <= eyeOuterRadius) {
      return true;
    } else {
      return false;
    }
  }
}
