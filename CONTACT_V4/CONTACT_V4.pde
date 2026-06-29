//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//

// needed libraries
import processing.serial.*;
import processing.core.*; // registerMethod
import java.lang.reflect.*;

import shiffman.box2d.*;

import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;


// A reference to our box2d world
Box2DProcessing box2d;

// A list we'll use to track fixed objects
//ArrayList<Boundary> boundaries;

boolean newData;

// Draw creature design or skeleton?
boolean skeleton;

// DATA & SCROLLBAR
boolean showvalues = true;
boolean scrollbar = false;
Data data;

// BOX2D COLLISION FILTERING
final short CATEGORY_PLAYER = 0x0001;  // 0000000000000001 in binary
final short CATEGORY_VEHICLE = 0x0001; //0x0002; // 0000000000000010 in binary

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

SimConfig config;

// ********************** keyboard control ****************************************************
/*
boolean right_isUp, right_isDown, right_isLeft, right_isRight;
 boolean left_isUp, left_isDown, left_isLeft, left_isRight;
 boolean disableInput;
 */

// ********************** sensor control ****************************************************
/*
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
 
 // * GAMEPAD
 */

float scaleValue = 0.1;
float minScale = 0.2;
float maxScale = 0.7;

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

int unitSize;

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

//ArrayList<Vehicle> vehicles;
ArrayList<Agent> agents;
ArrayList<Environment> environments;

Vec2 playerCenterSpherePosVecPixels;
float mainTheta;

String angleDirection;

int count = 0;

boolean readyToSwitchSides = true;
boolean isSwitchingSides = false;

Collision collision;

int stages;
int currentStage;

//*********************************************************************
// AUDIO
//*********************************************************************

// contact v4 sound

import processing.sound.*;
boolean playSoundContactV4;

SoundFile[] agentSounds;
SoundFile[] worldSounds;
SoundFile[] eventSounds;

SoundFile currentWorldSound;

/*
SoundFile eye_push;
 
 SoundFile[] backgroundSounds;
 boolean switchBackgroundSound;
 SoundFile currentBackgroundSound;
 
 SoundFile p_enter_v_zone_audio;
 SoundFile p_touch_v_audio;
 */

//


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

boolean fullScale;

//PlayerWorldLimits playerWorldLimits;

// TRAIL
BgTrailBox bgTrailBox;

enum InputControls
{
  KEYBOARD, JOYSTICKS; //, GAMEPAD;
};

InputControls inputControls;

// SVG
import processing.svg.*;
boolean recordSVG = false;

int fadeAnimationCounter;

void setup() {

  size(1024, 768, JAVA2D); // 800, 800 // 1440, 900
  //fullScreen(2);
  pixelDensity(1);


  //*********************************************************************
  //gamePadIsOn = false;
  inputControls = InputControls.KEYBOARD; //KEYBOARD; //JOYSTICKS;
  //protoSticks = false;
  debugMode = false;
  screengrab = false;
  showDistance = false;
  playSoundContactV4 = false;
  fullScale = false;
  //playSound = false; // enables sound // current sound until Woohun updates
  //audioIsPlaying = false; // new sound by woohun not ready yet
  //*********************************************************************

  if (screengrab) {
    screenGrabTimer = new Timer(5000);
    screenGrabTimer.start();
  }

  frameRate(30);

  stages = 5;
  currentStage = 2;

  //*************** OSCP5 SOUND ***************************************

  //oscP5 = new OscP5(this, 12000);
  //myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  //*******************************************************************
  // contact v4 sounds

  if (playSoundContactV4)
    setupSounds();

  //*******************************************************************



  colorMode(HSB, 360, 100, 100);

  int rowLength;
  if (fullScale) {
    unitSize = 900; // 900; //600; // 1200 is contact v3 size //750; // 600 x 5 // 1000 x 3  > to create more density but preserve smaller frame
  } else {
    unitSize = 600;
  }
  if (debugMode) {
    rowLength = 3;
    setUnitSize(rowLength * unitSize, rowLength * unitSize, rowLength, 0.5); // float _unitSize, int _unitRow, float _worldScale (0.5)
  } else {
    if (fullScale) {
      rowLength = 5; //5;
    } else {
      rowLength = 3;
    }
    setUnitSize(rowLength * unitSize, rowLength * unitSize, rowLength, 0.2); // float _unitSize, int _unitRow, float _worldScale (0.5)
  }

  // unitSize > rowLength * unitSize = unit_w/unit_h  > rect_w = sqrt(_unitTotal) * unit_w
  // 600      > 5 * 600                               >   5 * 3000

  if (inputControls == InputControls.JOYSTICKS) setupDeviceMode();
  setupb2d();

  unitTotal = int(pow(rowLength, 2));

  /*
  println("rowLength ", rowLength);
   println("unitTotal ", unitTotal);
   
   println("unit_w ", unit_w);
   println("unit_h ", unit_h);
   */

  // Make a new player
  playerCenterSpherePosVecPixels = new Vec2(0, 0);
  player = new Player();

  environments = new ArrayList<Environment>();
  agents = new ArrayList<Agent>();
  //vehicles = new ArrayList<Vehicle>();
  bg = new Bg(unitTotal, this);

  collision = new Collision(this);

  bgTrailBox = new BgTrailBox(unitTotal, unit_w, unit_h);

  //playerWorldLimits = new PlayerWorldLimits(unitTotal, unit_w, unit_h);

  setBackgroundTimer();

  //println("vehicles.size() ", vehicles.size());

  rightEyeLeft = false;
  rightEyeRight = false;
  leftEyeLeft = false;
  leftEyeRight = false;
  rightEyeUp = false;
  rightEyeDown = false;
  leftEyeUp = false;
  leftEyeDown = false;

  fadeAnimationCounter = 0;
    
  config = new SimConfig();
  data = new Data();
} // setup

//--------------------------------------------------------------

// contact v4 sounds

void setupSounds() {
  /*
  SoundFile[] agentSounds;
   SoundFile[][] environmentsBaseSounds;
   SoundFile[][] environmentsMuffledSounds;
   SoundFile[] worldSounds;
   SoundFile[] eventSounds;
   */

  worldSounds = new SoundFile[stages];

  worldSounds[0] = new SoundFile(this, "../../MUSIC/World/world_A.mp3");
  worldSounds[1] = new SoundFile(this, "../../MUSIC/World/world_B.mp3");
  worldSounds[2] = new SoundFile(this, "../../MUSIC/World/world_C.mp3");
  worldSounds[3] = new SoundFile(this, "../../MUSIC/World/world_D.mp3");
  worldSounds[4] = new SoundFile(this, "../../MUSIC/World/world_E.mp3");

  currentWorldSound = worldSounds[currentStage];

  agentSounds = new SoundFile[5];

  agentSounds[0] = new SoundFile(this, "../../MUSIC/Agent_Sounds/agent_A.mp3");
  agentSounds[1] = new SoundFile(this, "../../MUSIC/Agent_Sounds/agent_B.mp3");
  agentSounds[2] = new SoundFile(this, "../../MUSIC/Agent_Sounds/agent_C.mp3");
  agentSounds[3] = new SoundFile(this, "../../MUSIC/Agent_Sounds/agent_D.mp3");
  agentSounds[4] = new SoundFile(this, "../../MUSIC/Agent_Sounds/agent_E.mp3");

  currentWorldSound.amp(0.5);
  //currentWorldSound.play();
  //currentWorldSound.loop();


  //worldSounds = new SoundFile[stages];




  /*
  backgroundSounds = new SoundFile[9];
   
   for (int i=0; i < backgroundSounds.length; i++) {
   backgroundSounds[i] = new SoundFile(this, "../../SOUNDS/background" + i + ".mp3");
   }
   
   int randomBackgroundSound = int(random(0, backgroundSounds.length));
   //println("randomBackgroundSound ", randomBackgroundSound);
   currentBackgroundSound = backgroundSounds[randomBackgroundSound];
   currentBackgroundSound.amp(0.5);
   currentBackgroundSound.play();
   switchBackgroundSound = true;
   
   p_touch_v_audio = new SoundFile(this, "../../SOUNDS/p_touch_v.mp3");
   p_touch_v_audio.amp(1.0);
   */
}

//--------------------------------------------------------------

void updateSounds() {

  /*

   if (!currentBackgroundSound.isPlaying()) {
   
   if (switchBackgroundSound) {
   
   int randomBackgroundSound = int(random(0, backgroundSounds.length));
   currentBackgroundSound = backgroundSounds[randomBackgroundSound];
   switchBackgroundSound = false;
   currentBackgroundSound.play();
   }
   } else {
   switchBackgroundSound = true;
   }
   */
}

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


  player = null;

  box2d = null;
  agents.clear();
  environments.clear();
  //vehicles.clear();
  collision = null;

  for (int i=0; i < bg.units.length; i++) {
    bg.units[i] = null;
  }

  bg = null;
  bgTrailBox = null;
  //playerWorldLimits = null;

  fadeAnimationCounter = 0;

  //**********************

  setupb2d();

  previousM = new PVector(0, 0);
  currentM = new PVector(0, 0);
  vel = new PVector(0, 0);

  playerCenterSpherePosVecPixels = new Vec2(0, 0);
  player = new Player();

  environments = new ArrayList<Environment>();
  agents = new ArrayList<Agent>();
  //vehicles = new ArrayList<Vehicle>();
  bg = new Bg(unitTotal, this);
  collision = new Collision(this);

  bgTrailBox = new BgTrailBox(unitTotal, unit_w, unit_h);
  //playerWorldLimits = new PlayerWorldLimits(unitTotal, unit_w, unit_h);

  setBackgroundTimer();
}
//--------------------------------------------------------------
void draw() {

  updateConfig();

  // TRAIL RECORDING STARTS
  /*
  if (player.lung.getState() == player.lung.emptyState) {
   
   if (fadeAnimationIsOver()) {
   
   recordSVG = true;
   }
   }
   */

  if (playSoundContactV4)
    updateSounds();

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

    bgTrailBox.update(vel, mainTheta);
    //playerWorldLimits.update(vel, mainTheta);

    if (player.lung.isBreathing) {

      if (player.leftEye.pupilState == "unlocked" && player.rightEye.pupilState == "unlocked") {

        updatePlayerEyeSides(mainTheta);
      }
    }

    player.update(mainTheta);

    // DISPLAY

    background(backgroundColor);
    //background(0, 0, 19);

    if (!recordSVG) {

      bg.display(worldScale);

      box2d.step();

      pushMatrix();

      translate(width/2, height/2);

      scale(worldScale);

      pushMatrix();

      translate(-playerCenterSpherePosVecPixels.x, -playerCenterSpherePosVecPixels.y);

      //collision.checkVehiclesAgainstVehicleRipples();
      //collision.checkPlayerAgainstVehicleRipples();
      collision.checkVehicleAgainstVehicle();

      for (Agent a : agents) {

        a.run(agents, environments);
        if (a.v.location.getState() == a.v.location.vInMovingState) {
          a.maxSpeed = config.maxSpeed;
          a.update(config, agents, environments);
          //a.update(data.drainSlider.getPos(), agents, environments, data.separationDistSlider.getPos(), data.separationForceSlider.getPos(), data.sensingRadiusSlider.getPos());
        }
        if (a.dead()) {
          if (a.v.location.getState() == a.v.location.vInMovingState) {
            a.v.die();
          }
        }
      }

      for (Environment e : environments) {

        e.run(agents, environments);
      }

      player.display();


      popMatrix();

      popMatrix();

      if (!recordSVG) {
        if (debugMode) {
          drawFrameRate();
        } else {
          drawFrame();
          //drawFrameRate();
          showRemainingAgentsNum();
          //noCursor();
        }
      }

      pushMatrix();

      translate(width/2, height/2);

      //bgTrailBox.display(worldScale);
      //playerWorldLimits.display(worldScale);

      popMatrix();
    } else {

      //if (recordSVG) {

      // TRAILS START

      pushMatrix();

      translate(width/2, height/2);

      bgTrailBox.display(worldScale);

      popMatrix();
    } // TRAILS END

    /*
      
     pushMatrix();
     
     translate(width/2, height/2);
     
     bgTrailBox.display(worldScale);
     
     popMatrix();
     */
  }

  // TRAILS START
  /*
    pushMatrix();
   
   translate(width/2, height/2);
   
   bgTrailBox.display(worldScale);
   
   popMatrix();
   */

  // TRAILS END


  // TRAIL RECORDING STARTS

  if (recordSVG) {
    endRecord();
    recordSVG = false;

    resetContact();



    //audio.gameOver_playAudio();
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
  //if (player.lung.getState() == player.lung.emptyState) {

  /*
  if (player.lung.breath.movement == "empty" || collision.agentsRemaining == 0) {
   
   if (fadeAnimationIsOver()) {
   
   recordSVG = true;
   }
   }
   */

  if (scrollbar) data.display();
} // draw



//--------------------------------------------------------------

boolean fadeAnimationIsOver() {

  //colorMode(RGB);

  fadeAnimationCounter += 5;

  fill(0, 99, 0, fadeAnimationCounter);
  rectMode(CORNER);
  rect(0, 0, width, height);

  if (fadeAnimationCounter == 255 ) {

    return true;
  } else {

    return false;
  }
}

//--------------------------------------------------------------
/*
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
 */
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
    } else if (worldScale <= minScale) {
      //println("worldScale ", worldScale);

      worldScale -= .01;
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
    case ' ':
      println("dataSaved");
      data.saveData();
      break;
    }
  }

  switch(key) {
  case ' ':
    println("dataSaved");
    data.saveData();
    break;
  case '-':
    println("dataSaved");
    scrollbar = !scrollbar;
    break;
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


void drawFrameRate() {
  fill(255);
  textSize(14);
  text(frameRate, 15, 30);
}

//--------------------------------------------------------------
void showRemainingAgentsNum() {
  fill(255);
  textSize(18);
  //int len = vehicles.size();
  //String numTxt = str(len);
  text(collision.agentsRemaining, width-50, 30);
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
// GAMEPAD
/*
public void getUserInput() {
 
 leftStickXpos = gpad.getSlider("LeftStickX").getValue();
 leftStickYpos = gpad.getSlider("LeftStickY").getValue();
 
 rightStickXpos = gpad.getSlider("RightStickX").getValue();
 rightStickYpos = gpad.getSlider("RightStickY").getValue();
 }
 */
//--------------------------------------------------------------

void setupDeviceMode() {

  //switch (inputControls) {

  //case JOYSTICKS:

  newData = false;

  // Serial port setup.
  printArray(Serial.list());

  port = new Serial(this, Serial.list()[2], 9600);

  port.bufferUntil('\n');

  //break;
  /*
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
   */

  //break;
  //}
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
    /*
  case GAMEPAD:
     
     getUserInput(); // Poll the input device
     
     player.updateInputGamePad(leftStickXpos, leftStickYpos, rightStickXpos, rightStickYpos);
     
     return true;
     */
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

  //recordSVG = true;
}

// pulls current slider values into the config object each frame
void updateConfig() {
  config.maxSpeed = data.speedSlider.getPos();
  config.drainRate = data.drainSlider.getPos();
  config.refillRate = data.refillSlider.getPos();
  config.sepDist = data.separationDistSlider.getPos();
  config.sepForce = data.separationForceSlider.getPos();
  config.sensingRadius = data.sensingRadiusSlider.getPos();
  config.regenRate = data.regenRateSlider.getPos();
  
  println("config.maxSpeed ", config.maxSpeed);
}

// ADDED HELPERS

// add up all environment ratios and average them out
float avgEnvironmentHealth(){
  float total = 0;
  for (Environment e: environments) {
    total += e.energy / e.maxEnergy;
  }
  return total / environments.size();
}

//--------------------------------------------------------------

// draws background color based on average environment health
void drawBackground(float avgHealth){
  colorMode(HSB, 360, 100, 100);
  float hue;
  int stage;
  
  if (avgHealth > 0.90){
    hue = 210; // Blue
    stage = 1;
  } else if (avgHealth > 0.70){
    float t = map(avgHealth, 0.70, 0.90, 0.0, 1.0);
    hue = lerp(150, 210, t); // Blue to bluish-green to green
    stage = 2;
  } else if (avgHealth > 0.50){
    float t = map(avgHealth, 0.50, 0.70, 0.0, 1.0);
    hue = lerp(45, 150, t); // Green to yellow to yellowish orange
    stage = 3;
  } else if (avgHealth > 0.21){
    float t = map(avgHealth, 0.21, 0.50, 0.0, 1.0);
    hue = lerp(0, 45, t); // Orange to red
    stage = 4;
  } else {
    float t = map(avgHealth, 0.12, 0.21, 0.0, 1.0);
    hue = lerp(270, 360, t); // Red to violet to bluish-violet
    stage = 5;
  }
  
  background(hue, 65, 70);
  colorMode(RGB, 255);
  
  fill(0, 150);
  noStroke();
  textAlign(LEFT);
  textSize(13);
  text("BG Stage: " + stage + "  AvgHealth: " + nf(avgHealth, 1, 2), 20, 380);
}

//--------------------------------------------------------------
/*
// updates each environment's core logic and draws it
void updateEnvironments(){
  for (Environment e: environments){
    e.updatedCore(agents, config.regenRate);
    e.draw(config.sensingRadius);
  }
}
*/

//--------------------------------------------------------------

// holds all simulation parameters in one place instead of passing them around individually
class SimConfig {
  float drainRate; // how fast agents lose air
  float refillRate; // how fast agents refill air inside an env
  float sepDist; // how close agents get before pushing apart
  float sepForce; // strength of that push
  float sensingRadius; // how far agents can detect environments
  float regenRate; // how fast environments recover energy
  float maxSpeed; // max agent speed
}
