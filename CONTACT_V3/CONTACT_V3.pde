//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//

// needed libraries
import processing.serial.*;
import processing.core.*; // registerMethod
import java.lang.reflect.*;

import shiffman.box2d.*;

import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;

//*************** OSCP5 SOUND ***************************************

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

//*******************************************************************


// A reference to our box2d world
Box2DProcessing box2d;

// A list we'll use to track fixed objects
//ArrayList<Boundary> boundaries;

boolean newData;

// Draw creature design or skeleton?
boolean skeleton;

// BOX2D COLLISION FILTERING
final short CATEGORY_PLAYER = 0x0001;  // 0000000000000001 in binary
final short CATEGORY_VEHICLE = 0x0002; // 0000000000000010 in binary

final short MASK_PLAYER = CATEGORY_VEHICLE; //CATEGORY_VEHICLE | CATEGORY_SCENERY; // or ~CATEGORY_PLAYER
final short MASK_VEHICLE = CATEGORY_PLAYER; //CATEGORY_PLAYER | CATEGORY_SCENERY; // or ~CATEGORY_MONSTER


/*********************************************************************
 * NOTE: the X,Y,Z axes fixed to sensor. See data sheet for details. *
 * Here's a diagram from Adafruit forum: https://bit.ly/2stiKgB.     *
 *********************************************************************/

// Euler angles from both SENSORS (in DEGREES): in test setup, 1=left, 2=right.
/*
float pitch1 = 0.0;  // sensor 1 rotation about X axis
 float roll1  = 0.0;  // sensor 1 rotation about Y axis
 float yaw1   = 0.0;  // sensor 1 rotation about Z axis
 float pitch2 = 0.0;  // sensor 2 rotation about X axis
 float roll2  = 0.0;  // sensor 2 rotation about Y axis
 float yaw2   = 0.0;  // sensor 2 rotation about Z axis
 */

int incoming_leftJoystick_xAxis;
int incoming_leftJoystick_yAxis;
int incoming_rightJoystick_xAxis;
int incoming_rightJoystick_yAxis;

Serial port;
Player player;

// ********************** keyboard control ****************************************************
/*
boolean right_isUp, right_isDown, right_isLeft, right_isRight;
 boolean left_isUp, left_isDown, left_isLeft, left_isRight;
 boolean disableInput;
 */

// ********************** sensor control ****************************************************

// * GAMEPAD
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
// * GAMEPAD

// use gamepad as input device
//boolean gamePadIsOn;

ControlIO control;
Configuration config;
ControlDevice gpad;

float leftStickXpos = 0.0;
float leftStickYpos = 0.0;
float rightStickXpos = 0.0;
float rightStickYpos = 0.0;

float scaleValue = 0.1;
float minScale = 0.2;
float maxScale = 0.7;

// * GAMEPAD

// KEYBOARD CONTROL
boolean rightEyeLeft;
boolean rightEyeRight;
boolean leftEyeLeft;
boolean leftEyeRight;
boolean rightEyeUp;
boolean rightEyeDown;
boolean leftEyeUp;
boolean leftEyeDown;

Bg bg;

// ********************** STAGE, SCALE AND BORDER SIZE ****************************************************

//int unitSize = 800; //360;//240; //800;//240;//160;//800;

float unit_w; //2000;
float unit_h;

//float borderRadiusMax;

int rowLength;
int unitRowMin;
int unitRowMax;

float worldScale;

// ********************** STAGE, SCALE AND BORDER SIZE ****************************************************

int unitTotal;

int deg = 0;

float originAngle = 180;

PVector previousM = new PVector(0, 0);
PVector currentM = new PVector(0, 0);
PVector vel = new PVector(0, 0);

float previousAngle = 0;
float currentAngle = 0;
float avel = 0;

ArrayList<Vehicle> vehicles;

Vec2 playerCenterSpherePosVecPixels;
float mainTheta;

String angleDirection;

int count = 0;

boolean readyToSwitchSides = true;
boolean isSwitchingSides = false;

Collision collision;
Data data;

boolean debugMode;
boolean protoSticks;
boolean showDistance;

int backgroundColorNum;
color backgroundColor;
Timer backgroundTimer;
int backgroundCount;
int backgroundCountBeginning;
int  backgroundSaturation;
int backgroundBrightness;

// SCREEN GRAD FOR DOCUMENTATION

Timer screenGrabTimer;
boolean screengrab;

boolean playSound;


// TRAIL
BgTrailBox bgTrailBox;

enum InputControls
{
  KEYBOARD, JOYSTICKS, GAMEPAD;
};

InputControls inputControls;

// SVG
import processing.svg.*;
boolean recordSVG = false;
;

void setup() {

  size(1024, 768, JAVA2D); // 800, 800 // 1440, 900
  //fullScreen(2);

  //*********************************************************************
  //gamePadIsOn = false;
  inputControls = InputControls.JOYSTICKS; //KEYBOARD; //JOYSTICKS;
  //protoSticks = false;
  debugMode = false;
  screengrab = false;
  showDistance = true;
  playSound = false; // enables sound
  //*********************************************************************

  if (screengrab) {
    screenGrabTimer = new Timer(5000);
    screenGrabTimer.start();
  }

  frameRate(30);

  //*************** OSCP5 SOUND ***************************************

  oscP5 = new OscP5(this, 12000);
  //myRemoteLocation = new NetAddress("104.39.248.119", 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  //*******************************************************************

  colorMode(HSB, 360, 100, 100);

  int rowLength;

  if (debugMode) {
    rowLength = 3;
    setUnitSize(rowLength * 1000, rowLength * 1000, rowLength, 0.5); // float _unitSize, int _unitRow, float _worldScale
  } else {
    rowLength = 5;
    setUnitSize(rowLength * 1000, rowLength * 1000, rowLength, 0.5); // float _unitSize, int _unitRow, float _worldScale
  }

  collision = new Collision();
  data = new Data();

  setupDeviceMode();
  setupb2d();

  unitTotal = int(pow(rowLength, 2));

  // Make a new player
  playerCenterSpherePosVecPixels = new Vec2(0, 0);
  player = new Player();


  bgTrailBox = new BgTrailBox(unitTotal, unit_w, unit_h);

  vehicles = new ArrayList<Vehicle>();
  bg = new Bg(unitTotal);



  setBackgroundTimer();

  println("vehicles.size() ", vehicles.size());

  rightEyeLeft = false;
  rightEyeRight = false;
  leftEyeLeft = false;
  leftEyeRight = false;
  rightEyeUp = false;
  rightEyeDown = false;
  leftEyeUp = false;
  leftEyeDown = false;
} // setup

//--------------------------------------------------------------

void setUnitSize(float _unit_w, float _unit_h, int _rowLength, float _worldScale) {

  unit_w = _unit_w; //2000;
  unit_h = _unit_h;
  rowLength = _rowLength;
  unitRowMax = rowLength;
  unitRowMin = 3;
  //playerBorderRadiusMin = (unit_size*unitRowMax)*0.4;
  //playerBorderRadiusMax = (unit_size*unitRowMin) * 0.6;
  worldScale = _worldScale;
}

//--------------------------------------------------------------

void setupb2d() {

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.world.setGravity( new Vec2( 0.0, 0.0 ) );

  // Add a listener to listen for collisions!
  box2d.world.setContactListener(new CustomListener());
}

//--------------------------------------------------------------
void setBackgroundTimer() {

  backgroundCountBeginning = 0;
  backgroundCount = backgroundCountBeginning;
  backgroundSaturation = 75;
  backgroundBrightness = 75;
  backgroundColor = color(backgroundCount, backgroundSaturation, backgroundBrightness);
  backgroundTimer = new Timer(2000);
  backgroundTimer.start();
}
//--------------------------------------------------------------
void resetContact() {

  //player.killBlob();
  player = null;

  //vehicles.get(0).killBlob();
  //vehicles.get(1).killBlob();

  /*
  for (int i=0; i < vehicles.size(); i++) {
   Vehicle v = vehicles.get(i);
   //v.killBlob();
   }
   vehicles.clear();
   */

  box2d = null;
  vehicles.clear();
  collision = null;
  data = null;

  for (int i=0; i < bg.units.length; i++) {
    bg.units[i] = null;
  }

  bg = null;


  //recordSVG = true;


  bgTrailBox = null;


  //**********************

  setupb2d();

  previousM = new PVector(0, 0);
  currentM = new PVector(0, 0);
  vel = new PVector(0, 0);

  //
  playerCenterSpherePosVecPixels = new Vec2(0, 0);
  player = new Player();
  //

  bgTrailBox = new BgTrailBox(unitTotal, unit_w, unit_h);
  //
  vehicles = new ArrayList<Vehicle>();
  bg = new Bg(unitTotal);
  collision = new Collision();
  data = new Data();


  setBackgroundTimer();
}
//--------------------------------------------------------------

void draw() {

  // TRAIL RECORDING STARTS

  if (player.lung.getState() == player.lung.emptyState) {
    recordSVG = true;
  }

  if (recordSVG) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(SVG, "../SVG/frame-####.svg");
  }

  // TRAIL RECORDING ENDS

  if (screengrab) {

    if (screenGrabTimer.isFinished()) {
      saveFrame();
      screenGrabTimer.start();
    }
  }

  if (updateDeviceMode()) {

    if (backgroundTimer.isFinished()) {

      backgroundTimer.start();
      if (backgroundCount <= 360) {
        backgroundCount++;
      } else {
        backgroundCount = 0;
      }

      backgroundColor = color(backgroundCount, backgroundSaturation, backgroundBrightness);
    }

    // ************************************************
    // calculate background velocity
    // ************************************************

    playerCenterSpherePosVecPixels = box2d.getBodyPixelCoord(player.centerSphere.body);

    currentM.set(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);

    if (previousM.x == 0 && previousM.y == 0) {
    } else {
      vel = PVector.sub(currentM, previousM);
      vel.mult(-1);
    }

    bg.update(vel);
    bgTrailBox.update(vel);

    previousM.set(playerCenterSpherePosVecPixels.x, playerCenterSpherePosVecPixels.y);

    // ************************************************
    // calculate position of spheres
    // ************************************************

    Vec2 centerPos = box2d.getBodyPixelCoord(player.centerSphere.body);

    Vec2 leftEyePos = box2d.getBodyPixelCoord(player.leftEye.eyeInnerb2d.body);
    //Vec2 rightEyePos = box2d.getBodyPixelCoord(player.rightEye.eyeInnerb2d.body);

    leftEyePos = leftEyePos.sub(centerPos);
    PVector lPos = new PVector(leftEyePos.x, leftEyePos.y);

    // calculate angle
    // ************************************************

    float left_theta = lPos.heading();
    //float right_theta = rPos.heading();

    mainTheta = left_theta;

    if (player.lung.isBreathing) {

      if (player.leftEye.pupilState == "unlocked" && player.rightEye.pupilState == "unlocked") {

        updatePlayerEyeSides(mainTheta);
      }
    }

    player.update(mainTheta);

    // DISPLAY

    background(backgroundColor);
    //background(0, 0, 19);


    //if (!recordSVG) {

      bg.display(worldScale);

      box2d.step();

      pushMatrix();

      translate(width/2, height/2);

      scale(worldScale);

      pushMatrix();

      translate(-playerCenterSpherePosVecPixels.x, -playerCenterSpherePosVecPixels.y);

      collision.checkVehiclesAgainstVehicleRipples();
      collision.checkPlayerAgainstVehicleRipples();
      collision.checkVehicleAgainstVehicle();

      if (player.area.isVisible) {

        player.display();

        for (Vehicle v : vehicles) {

          if (!v.inMotion) {
            v.run(vehicles);
          } else {
            v.run(vehicles);
          }
        }
      } else { // recordSVG

        for (Vehicle v : vehicles) {
          if (!v.inMotion) {
            v.run(vehicles);
          } else {
            v.run(vehicles);
          }
        }

        player.display();
      }

      removeVehicles();

      popMatrix();

      popMatrix();

      if (debugMode && !recordSVG) {
        drawFrameRate();
      } else {
        drawFrame();
        noCursor();
      }
   // } else 
    if (recordSVG) {

      // TRAILS START

      pushMatrix();

      translate(width/2, height/2);

      bgTrailBox.display(worldScale);

      popMatrix();

      // TRAILS END
    }

    if (playSound) {
      trackData();
    }
  }

  // TRAIL RECORDING STARTS

  if (recordSVG) {
    endRecord();
    recordSVG = false;

    resetContact();
  }

  if (inputControls == InputControls.KEYBOARD) {

    // RIGHT
    if (rightEyeLeft) {
      if (player.rightEye.readyToRotate_k)player.rightEye.rotateLine("left");
    }
    if (rightEyeRight) {
      if (player.rightEye.readyToRotate_k)player.rightEye.rotateLine("right");
    }
    if (rightEyeUp) {
      player.rightEye.movePupil_k("up");
    }
    if (rightEyeDown) {
      player.rightEye.movePupil_k("down");
    }

    // LEFT
    if (leftEyeLeft) {
      if (player.leftEye.readyToRotate_k)player.leftEye.rotateLine("left");
    }
    if (leftEyeRight) {
      if (player.leftEye.readyToRotate_k)player.leftEye.rotateLine("right");
    }
    if (leftEyeUp) {
      player.leftEye.movePupil_k("up");
    }
    if (leftEyeDown) {
      player.leftEye.movePupil_k("down");
    }
  }

  // TRAIL RECORDING ENDS

  //println("vehicle size ", vehicles.size());
} // draw

//*************** DATA TRACKING ***************************************

void trackData() {

  String player_movement;
  String player_rotation;
  int player_color;
  String player_direction_vertical;
  String player_direction_horizontal;
  float player_speed;
  String player_area_breathing;
  float player_area_radius;
  String player_lung_breathing;
  float player_lung_radius;
  boolean vehicle_in_area;
  boolean vehicle_touch_player;
  boolean player_in_zone;
  boolean player_touch_vehicle;
  float player_transitions_in_zone;

  //


  boolean printVals = false;
  boolean printOSCs = true;


  // ************* OSC *************
  OscMessage osc_player_movement = new OscMessage("/player_movement");
  OscMessage osc_player_rotation = new OscMessage("/player_rotation");
  OscMessage osc_player_color = new OscMessage("/player_color");
  OscMessage osc_player_direction_vertical = new OscMessage("/player_direction_vertical");
  OscMessage osc_player_direction_horizontal = new OscMessage("/player_direction_horizontal");
  OscMessage osc_player_speed = new OscMessage("/player_speed");
  OscMessage osc_player_area_breathing = new OscMessage("/player_area_breathing");
  OscMessage osc_player_area_radius = new OscMessage("/player_area_radius");
  OscMessage osc_player_lung_breathing = new OscMessage("/player_lung_breathing");
  OscMessage osc_player_lung_radius = new OscMessage("/player_lung_radius");

  //OscMessage osc_player_transitions_in_zone = new OscMessage("/player_transitions_in_zone");


  //println("");

  //**** MOVEMENT ****
  player_movement = data.trackPlayerMovement();
  osc_player_movement.add(player_movement);
  if (printVals) println("player movement: ", player_movement);
  if (printOSCs) oscP5.send(osc_player_movement, myRemoteLocation);
  //
  //**** ROTATION ****
  player_rotation = data.trackPlayerRotation();
  osc_player_rotation.add(player_rotation);
  if (printVals) println("player rotation: ", player_rotation);
  if (printOSCs) oscP5.send(osc_player_rotation, myRemoteLocation);
  //
  //**** COLOR ****
  player_color = data.trackPlayerColor();
  osc_player_color.add(player_color);
  if (printVals) println("player color : ", player_color);
  if (printOSCs) oscP5.send(osc_player_color, myRemoteLocation);
  //
  //**** SPEED ****
  player_speed = data.trackPlayerSpeed();
  osc_player_speed.add(player_speed);
  if (printVals) println("player speed : ", player_speed);
  if (printOSCs) oscP5.send(osc_player_speed, myRemoteLocation);
  //
  //**** LUNG BREATHING ****
  player_lung_breathing = data.trackPlayerLungBreathing();
  osc_player_lung_breathing.add(player_lung_breathing);
  if (printVals)println("player lung breathing ", player_lung_breathing);
  if (printOSCs) oscP5.send(osc_player_lung_breathing, myRemoteLocation);
  //
  //**** LUNG RADIUS ****
  player_lung_radius = data.trackPlayerLungRadius();
  osc_player_lung_radius.add(player_lung_radius);
  if (printVals)println("player lung radius ", player_lung_radius);
  if (printOSCs) oscP5.send(osc_player_lung_radius, myRemoteLocation);

  /*
  //**** PLAYER IN ZONE ****
   player_in_zone = data.trackPlayerInZone();
   osc_player_in_zone.add(player_in_zone);
   //println("player in zone: ", player_in_zone);
   if (printOSCs) oscP5.send(osc_player_in_zone, myRemoteLocation);
   */

  //if (player.location.getState() == player.location.pLocVehicleZoneState || data.playerTouchedVehicle) {
  /*
    //**** PLAYER TRANSITIONS IN ZONE ****
   player_transitions_in_zone = data.trackPlayerTransitionsInZone();
   osc_player_transitions_in_zone.add(player_transitions_in_zone);
   //println("player transitions in zone: ", player_transitions_in_zone);
   if (player_transitions_in_zone > 0 && player_transitions_in_zone < player.blobRadius * 2) {
   println("player transitions in zone: ", player_transitions_in_zone);
   if (printOSCs) oscP5.send(osc_player_transitions_in_zone, myRemoteLocation);
   }
   */
  //
  //**** PLAYER IN ZONE ****


  /*
    player_in_zone = data.trackPlayerInZone();
   osc_player_in_zone.add(player_in_zone);
   println("player in zone: ", player_in_zone);
   if (printOSCs) oscP5.send(osc_player_in_zone, myRemoteLocation);
   */
  //
  /*
    //**** PLAYER TOUCH VEHICLE ****
   player_touch_vehicle = data.trackPlayerTouchVehicle();
   osc_player_touch_vehicle.add(player_touch_vehicle);
   if (player_touch_vehicle) println("vehicle touched player: ", player_touch_vehicle);
   if (printOSCs) oscP5.send(osc_player_touch_vehicle, myRemoteLocation);
   */
  //
  //} else if (player.location.getState() == player.location.pLocBreathingState || data.vehicleTouchedPlayer) {
  if (player.location.getState() == player.location.pLocBreathingState) {
    //
    //**** AREA BREATHING ****
    player_area_breathing =  data.trackPlayerAreaBreathing();
    osc_player_area_breathing.add(player_area_breathing);
    if (printVals) println("player area breathing: ", player_area_breathing);
    if (printOSCs) oscP5.send(osc_player_area_breathing, myRemoteLocation);
    //
    //**** AREA RADIUS ****
    player_area_radius =  data.trackPlayerAreaRadius();
    osc_player_area_radius.add(player_area_radius);
    if (printVals) println("player area radius: ", player_area_radius);
    if (printOSCs) oscP5.send(osc_player_area_radius, myRemoteLocation);
    //
    /*
    //**** VEHICLE IN AREA ****
     vehicle_in_area = data.trackVehicleInArea();
     osc_vehicle_in_area.add(vehicle_in_area);
     if (printVals) println("vehicle in area: ", vehicle_in_area);
     if (printOSCs) oscP5.send(osc_vehicle_in_area, myRemoteLocation);
     //
     //**** VEHICLE TOUCH PLAYER ****
     vehicle_touch_player = data.trackVehicleTouchPlayer();
     osc_vehicle_touch_player.add(vehicle_touch_player);
     if (vehicle_touch_player) println("vehicle touched player: ", vehicle_touch_player);
     if (printOSCs) oscP5.send(osc_vehicle_touch_player, myRemoteLocation);
     */
    //
  } else if (player.location.getState() == player.location.pLocMovingState) {
    //**** DIRECTION VERTICAL ****
    player_direction_vertical =  data.trackPlayerDirectionVertical();
    osc_player_direction_vertical.add(player_direction_vertical);
    if (printVals) println("player direction vertical: ", player_direction_vertical);
    if (printOSCs) oscP5.send(osc_player_direction_vertical, myRemoteLocation);
    //
    //**** DIRECTION HORIZONTAL ****
    player_direction_horizontal =  data.trackPlayerDirectionHorizontal();
    osc_player_direction_horizontal.add(player_direction_horizontal);
    if (printVals) println("player direction horizontal: ", player_direction_horizontal);
    if (printOSCs) oscP5.send(osc_player_direction_horizontal, myRemoteLocation);
  }

  //println("");
}

//*************** OSCP5 SOUND ***************************************

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

//--------------------------------------------------------------

void removeVehicles() {

  for (int i = vehicles.size()-1; i >= 0; i--) {
    Vehicle v = vehicles.get(i);

    if (v.inMotion) {

      if (v.trail.ripples.size() > 0) {

        v.startedRipples = true;

        // Particles that leave the screen, we delete them
        // (note they have to be deleted from both the box2d world and our list

        for (int j = v.trail.ripples.size()-1; j >= 0; j--) {
          VehicleRipple r = v.trail.ripples.get(j);

          if (r.opacity == 0) {
            v.trail.ripples.remove(j);
          }
        }
      }
    }
  }
}

//--------------------------------------------------------------

void createVehicleCopy(Vehicle v) {

  Vec2 playerPos = box2d.getBodyPixelCoord(player.centerSphere.body);
  Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);

  Vec2 velocity = playerPos.sub(vehiclePos);

  float len = velocity.length();
  len += 200; //50;
  velocity.normalize();
  velocity.mulLocal(len);


  Vec2 newVelocity = playerPos.add(velocity);

  //float vehicleRadius = ((unit_size*.3)*0.5)*0.7;
  int vehicleColorNum = int(random(0, 360));

  Vehicle vehicle = new Vehicle(newVelocity.x, newVelocity.y, vehicleColorNum, true, "DYNAMIC", 0, player);

  vehicles.add(vehicle);
}

//--------------------------------------------------------------

void updatePlayerEyeSides(float mainTheta) {

  int playerAngle = int(degrees(mainTheta));

  while (playerAngle < -180) {
    mainTheta += radians(360);
  }

  while (playerAngle > 180) {
    mainTheta -= radians(360);
  }

  if (playerAngle < -95 && playerAngle > -180 || playerAngle > 95 && playerAngle < 180) {


    if (player.leftEye.coltxt == "green") {
      player.leftEye.coltxt = "red";
    }
  } else if (playerAngle > -85 && playerAngle < 85) {

    if (player.leftEye.coltxt == "red") {
      player.leftEye.coltxt = "green";
    }
  }
}

//--------------------------------------------------------------

void keyPressed() {

  //if (inputControls != InputControls.KEYBOARD) {

  if (key == '2') {

    if (worldScale < maxScale) {

      worldScale += scaleValue;
    }
  } else if (key == '1') {

    if (worldScale > minScale) {

      worldScale -= scaleValue;
    }
  }
  //} else if (key == ' ') {
  /*
    if (!gamePadIsOn) {
   player.leftEye.calibrateSensor = true;
   player.rightEye.calibrateSensor = true;
   player.leftEye.resetEye();
   player.rightEye.resetEye();
   } else if (screengrab) {
   
   saveFrame();
   }
   */
  //  }
  if (inputControls == InputControls.KEYBOARD) {

    switch(keyCode) {
    case LEFT:
      rightEyeLeft = true;
      break;
    case RIGHT:
      rightEyeRight = true;
      break;
    case UP:
      rightEyeUp = true;
      break;
    case DOWN:
      rightEyeDown = true;
      break;
    }

    switch(key) {
    case 'a':
      leftEyeLeft = true;
      break;
    case 'd':
      leftEyeRight = true;
      break;
    case 'w':
      leftEyeUp = true;
      break;
    case 's':
      leftEyeDown = true;
      break;
    }
  }
}

void keyReleased() {

  if (inputControls == InputControls.KEYBOARD) {

    switch(keyCode) {
    case LEFT:
      rightEyeLeft = false;
      break;
    case RIGHT:
      rightEyeRight = false;
      break;
    case UP:
      rightEyeUp = false;
      break;
    case DOWN:
      rightEyeDown = false;
      break;
    }

    switch(key) {
    case 'a':
      leftEyeLeft = false;
      break;
    case 'd':
      leftEyeRight = false;
      break;
    case 'w':
      leftEyeUp = false;
      break;
    case 's':
      leftEyeDown = false;
      break;
    }
  }
}
//--------------------------------------------------------------
/*
void useKeyLeft() {
 
 switch(key) {
 case 'a':
 if (player.leftEye.readyToRotate_k)player.leftEye.rotateLine("left");
 break;
 case 'd':
 if (player.leftEye.readyToRotate_k)player.leftEye.rotateLine("right");
 break;
 }
 }
 
 void useKeyRight() {
 
 switch(keyCode) {
 case LEFT:
 if (player.rightEye.readyToRotate_k)player.rightEye.rotateLine("left");
 break;
 case RIGHT:
 if (player.rightEye.readyToRotate_k)player.rightEye.rotateLine("right");
 break;
 case UP:
 // player.rightEye.movePupil("forward");
 break;
 case DOWN:
 // player.rightEye.movePupil("backward");
 break;
 }
 }
 */
//--------------------------------------------------------------

void drawFrameRate() {
  fill(255);
  textSize(14);
  text(frameRate, 15, 30);
}

//--------------------------------------------------------------

// Monitor serial ports and extract data from string
void serialEvent(Serial port)

{

  newData = false;

  //println("into serial event");

  try {

    String incoming = port.readStringUntil('\n');

    if (incoming != null)
    {

      incoming = trim(incoming);

      // break up the decimal and new line reading
      int[] vals = int(splitTokens(incoming, ","));

      // we assign to variables
      incoming_leftJoystick_xAxis = vals[0];
      incoming_leftJoystick_yAxis = vals[1];
      incoming_rightJoystick_xAxis = vals[2];
      incoming_rightJoystick_yAxis = vals[3];

      newData = true;
    }
  }
  catch (Exception e) {

    println("Initialization exception");
  }
}

//--------------------------------------------------------------

public void getUserInput() {

  leftStickXpos = gpad.getSlider("LeftStickX").getValue();
  leftStickYpos = gpad.getSlider("LeftStickY").getValue();

  rightStickXpos = gpad.getSlider("RightStickX").getValue();
  rightStickYpos = gpad.getSlider("RightStickY").getValue();
}

//--------------------------------------------------------------

void setupDeviceMode() {

  switch (inputControls) {

  case JOYSTICKS:

    newData = false;

    // Serial port setup.
    printArray(Serial.list());

    port = new Serial(this, Serial.list()[2], 9600);

    port.bufferUntil('\n');

    break;

  case GAMEPAD:

    // * GAMEPAD
    control = ControlIO.getInstance(this);
    // Find a gamepad that matches the configuration file. To match with any
    // connected device remove the call to filter.
    //gpad = control.filter(GCP.GAMEPAD).getMatchedDevice("xbox_gamepad_two_sticks");
    gpad = control.filter(GCP.GAMEPAD).getMatchedDevice("PS4 controller");
    if (gpad == null) {
      println("No suitable device configured");
      System.exit(-1); // End the program NOW!
    }

    break;

  case KEYBOARD:

    break;
  }
}



//--------------------------------------------------------------

boolean updateDeviceMode() {

  switch (inputControls) {

  case JOYSTICKS:

    if (newData) {

      player.updateInputJoystick(incoming_leftJoystick_xAxis,
        incoming_leftJoystick_yAxis,
        incoming_rightJoystick_xAxis,
        incoming_rightJoystick_yAxis);

      newData = false;

      return true;
    } else {

      return false;
    }

  case GAMEPAD:

    getUserInput(); // Poll the input device

    player.updateInputGamePad(leftStickXpos, leftStickYpos, rightStickXpos, rightStickYpos);

    return true;

  case KEYBOARD:

    return true;

  default:

    return true;
  }
}

//--------------------------------------------------------------

void drawFrame() {
  noFill();
  stroke(0);
  rectMode(CORNER);

  rectMode(CORNER);
  rect(0, 0, width, height);

  pushMatrix();
  translate(width-50, height-150);
  rotate(radians(90));
  drawCorner();
  popMatrix();

  pushMatrix();
  translate(width-150, 50);
  rotate(radians(0));
  drawCorner();
  popMatrix();

  pushMatrix();
  translate(50, 150);
  rotate(radians(-90));
  drawCorner();
  popMatrix();

  pushMatrix();
  translate(150, height-50);
  rotate(radians(-180));
  drawCorner();
  popMatrix();
}

//--------------------------------------------------------------

void drawCorner() {
  if (screengrab) {
    fill(360);
    noStroke();
  } else {
    fill(0);
    stroke(0);
  }
  pushMatrix();
  translate(-150, -150);
  beginShape();
  vertex(100, 100);
  bezierVertex(300, 100, 300, 250, 300, 300);
  vertex(300, 300);
  vertex(300, 100);
  vertex(100, 100);
  endShape();
  popMatrix();
}

// Use a keypress so thousands of files aren't created
void mousePressed() {

  recordSVG = true;
}
