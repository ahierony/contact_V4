class Vehicle {

  ArrayList<VehicleSphere> spheres;
  ArrayList<Joint> joints;
  ArrayList<Joint> sideJoints;

  //ArrayList<Vehicle> vehicles;
  ArrayList<Agent> agents;
  ArrayList<Environment> environments;

  Agent thisAgent;
  Environment thisEnvironment;

  VehicleZone zone;
  VehicleLocation location;
  VehicleLung lung;

  float calibrateLungRadius;

  float centerBoidRadius;
  float sphereRadius;  // The radius of each body that makes up the skeletonadius;
  float radius;      // The radius of the entire blob
  float blobRadius;
  int totalPoints; // How many points make up the blob


  float fadeValue;
  float originFadeValue;
  float fadeSpeed;

  Vec2 posVecPixels;
  Vec2 vPos;
  PVector pos;

  float unitHalfSize;

  int colorWheelAngle;

  color colorElement;
  color colorBreathing;
  color colorTrail;
  color colorWithinDistance;
  color darkGrey = color(0, 0, 19, 90);

  int maxVal = 0; //test angle

  int outcomingForceDirection;

  Breath breath;

  VehicleBoid centerBoid;

  boolean inMotion;

  ArrayList<PVector> history = new ArrayList<PVector>();
  int historyLength = 2000;

  String bodyType;

  int unitNum;

  boolean playerInBreathingZone;
  boolean playerInDistanceZone;

  boolean touchedPlayer;
  boolean vehicleTouchedPlayer;

  boolean touchedVehicle;

  int breathingOffset;

  boolean initialZoneGrowth;

  boolean zoneAgainstZones;

  boolean startedRipples;

  int brightness;
  int saturation;

  int colorAngleSwitchPlayer;
  int colorAngleSwitchVehicle;
  int baseSwitchPlayer;
  int baseSwitchVehicle;

  Player player;

  boolean inOtherVehicleBreathingZone;
  boolean inOtherVehicleDistanceZone;
  boolean otherVehicleInDistanceZone;
  boolean otherVehicleInBreathingZone;
  boolean otherBreathingVehicleComingClose;

  boolean inPlayerMaxRadius;
  boolean inPlayerMinRadius;

  boolean isReadyForCollision;
  boolean readyToUpdateDistanceZone;
  //

  // other vehicle test
  boolean distanceFinal;
  boolean breathingFinal;

  //VehicleMembrane membrane;

  boolean repellOther;
  boolean isColliding;

  int index;

  Vec2 deadPosition;

  //AUDIO
  //boolean vehicleBreathingAudioIsPlaying;

  //--------------------------------------------------------------

  // Constructor from Environment
  Vehicle(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, Environment thisE) {

    index = unitNum_;

    thisEnvironment = thisE;

    unitNum = unitNum_;

    inMotion = _inMotion;

    readyToUpdateDistanceZone = true;

    player = p;

    // the random color of the element: val between 0-360
    colorWheelAngle = _colorAngle;

    bodyType = type_;

    // Add the box to the box2d world
    posVecPixels = new Vec2(x, y);
    pos = new PVector(x, y);

    brightness = 100;
    saturation = 100;

    colorElement = color(colorWheelAngle, saturation, brightness);

    colorBreathing = color(colorWheelAngle, saturation, brightness, 100);

    colorTrail = color(colorWheelAngle, saturation, brightness);
    colorWithinDistance = darkGrey;

    unitHalfSize = unit_w * 0.5;

    // Create the empty ArrayLists
    //spheres = new ArrayList<Sphere>();
    //spheres = new VehicleSphere[0];
    spheres = new ArrayList<VehicleSphere>();
    joints = new ArrayList<Joint>();
    sideJoints = new ArrayList<Joint>();
    //vehicles = new ArrayList<Vehicle>();

    ellipseMode(RADIUS);

    breath = new Breath("vehicle");

    makeBlob(posVecPixels);

    blobRadius = radius + sphereRadius;

    location = new VehicleLocation(player, thisEnvironment);

    zone = new VehicleZone(this);
    isReadyForCollision = true;
    zone.isBreathing = true;
    //membrane = new VehicleMembrane(x, y, zone.radiusMax);

    playerInBreathingZone = false;
    playerInDistanceZone = false;

    touchedPlayer = false;
    vehicleTouchedPlayer = false;

    touchedVehicle = false;

    originFadeValue = 255.0;
    fadeValue = originFadeValue;
    fadeSpeed = 1; //5; // 0.5;

    breathingOffset = 10;

    initialZoneGrowth = false;
    zoneAgainstZones = true;

    vPos = box2d.getBodyPixelCoord(centerBoid.body);

    startedRipples = false;

    inOtherVehicleBreathingZone = false;
    inOtherVehicleDistanceZone = false;
    otherVehicleInDistanceZone = false;
    otherVehicleInBreathingZone = false;

    otherBreathingVehicleComingClose = false;

    baseSwitchPlayer = 30;
    baseSwitchVehicle = 360; // 90;
    colorAngleSwitchPlayer = baseSwitchPlayer; // 50; //45;
    colorAngleSwitchVehicle = baseSwitchVehicle; //90; //5; //7; //15; //7;

    repellOther = false;
    isColliding = false;

    initialize();
  }

  //--------------------------------------------------------------

  // Constructor from Agent
  Vehicle(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex, Agent thisA) {

    index = vIndex;

    thisAgent = thisA;

    unitNum = unitNum_;

    inMotion = _inMotion;

    readyToUpdateDistanceZone = true;

    player = p;

    // the random color of the element: val between 0-360
    colorWheelAngle = _colorAngle;

    bodyType = type_;

    // Add the box to the box2d world
    posVecPixels = new Vec2(x, y);
    pos = new PVector(x, y);

    brightness = 100;
    saturation = 100;

    colorElement = color(colorWheelAngle, saturation, brightness);

    colorTrail = color(colorWheelAngle, saturation, brightness);
    colorWithinDistance = darkGrey;

    unitHalfSize = unit_w * 0.5;

    // Create the empty ArrayLists
    //spheres = new ArrayList<Sphere>();
    //spheres = new VehicleSphere[0];
    spheres = new ArrayList<VehicleSphere>();
    joints = new ArrayList<Joint>();
    sideJoints = new ArrayList<Joint>();
    //vehicles = new ArrayList<Vehicle>();

    ellipseMode(RADIUS);

    breath = new Breath("vehicle");

    makeBlob(posVecPixels);

    blobRadius = radius + sphereRadius;

    location = new VehicleLocation(player, thisAgent);

    calibrateLungRadius = 0;
    lung = new VehicleLung(thisAgent);
    lung.previousRadius = lung.radiusMax;

    playerInBreathingZone = false;
    playerInDistanceZone = false;

    touchedPlayer = false;
    vehicleTouchedPlayer = false;

    touchedVehicle = false;

    originFadeValue = 255.0;
    fadeValue = originFadeValue;
    fadeSpeed = 1; //5; // 0.5;

    breathingOffset = 10;

    initialZoneGrowth = false;
    zoneAgainstZones = true;

    vPos = box2d.getBodyPixelCoord(centerBoid.body);

    startedRipples = false;



    inOtherVehicleBreathingZone = false;
    inOtherVehicleDistanceZone = false;
    otherVehicleInDistanceZone = false;
    otherVehicleInBreathingZone = false;

    otherBreathingVehicleComingClose = false;

    baseSwitchPlayer = 30;
    baseSwitchVehicle = 360; // 90;
    colorAngleSwitchPlayer = baseSwitchPlayer; // 50; //45;
    colorAngleSwitchVehicle = baseSwitchVehicle; //90; //5; //7; //15; //7;

    repellOther = false;

    initialize();
  }

  //--------------------------------------------------------------

  void initialize() {

    if (inMotion) {
      //zone.setState(zone.inMotionNoZoneState);
    } else {
      zone.setState(zone.fullState);
    }
  }


  //--------------------------------------------------------------


  //void run(ArrayList<Vehicle> vs) {
  void run(ArrayList<Agent> as, ArrayList<Environment> es) {

    agents = as;
    environments = es;

    //vehicles = vs;

    if (inMotion) {
      if (location.getState() != location.vInDeadState) {

        update();

        display();
      } else {

        displayDeadVehicle();
      }
    } else {
      update();
      display();
    }
  }



  // ********************************************************
  // UPDATE CODE
  // ********************************************************

  void update() {

    ellipseMode(RADIUS);

    if (inMotion) { // VEHICLE IS IN MOTION

      inOtherVehicleDistanceZone = false;
      inOtherVehicleBreathingZone = false;


      for (Environment e : environments) {

        checkIfInOtherVehicleZone(e.v);
      }

      location.update();

      lung.update();

      centerBoid.update();


      if (location.getState() == location.vInMovingState) {
        wrap();
      }


      /*
      if (location.getState() == location.vInMovingState) {
       
       if (lung.getState() == lung.emptyState) {
       
       
       die();
       }
       } else if (location.getState() == location.vInOtherVehicleZoneState) {
       
       
       //e.energy -= 0.5;
       //e.energy = max(e.energy, 0);
       }
       */


      //checkRippleCount(); // vehicle stops moving and starts breathing // not in this version
    } else { // // VEHICLE IS NOT IN MOTION


      boolean otherVehicleAlreadyHasPlayerInDistanceZone = false;

      for (Environment e : environments) {

        if (e.v != this) {

          if (e.v.playerInDistanceZone) {

            otherVehicleAlreadyHasPlayerInDistanceZone = true;
          }
        }
      }

      if (!otherVehicleAlreadyHasPlayerInDistanceZone) {

        checkIfPlayerInZone();
      }


      checkIfOtherVehicleInZone();

      /*
      if (playerInDistanceZone && otherBreathingVehicleComingClose) {
       
       zone.setState(zone.holdState);
       
       } else {
       
       
       
       }
       */


      location.update();

      zone.update();

      //if (zone.getState() == zone.fullState) {

      //thisEnvironment.update(agents, data.regenRateSlider.getPos());
      //}



      posVecPixels.set(centerBoid.posVecPixels.x, centerBoid.posVecPixels.y);

      // after collision with either vehicle or player, zone repells until nobody is in the zone
      if (repellOther) {

        if (!otherVehicleInBreathingZone && !playerInBreathingZone) {
          repellOther = false;
          isColliding = false;
          zone.setState(zone.fullState);
        }
      }
    } // VEHICLE IS NOT IN MOTION
  }

  //--------------------------------------------------------------

  void wrap() {

    Vec2 wrapPos = box2d.getBodyPixelCoord(centerBoid.body);
    Vec2 pPos = box2d.getBodyPixelCoord(player.centerSphere.body);

    if (wrapPos.x < pPos.x - player.worldLimits.rect_w/2 ||
      wrapPos.x > pPos.x + player.worldLimits.rect_w/2||
      wrapPos.y < pPos.y - player.worldLimits.rect_h/2||
      wrapPos.y > pPos.y + player.worldLimits.rect_h/2) {

      killBlob();

      PVector unitPos = new PVector(wrapPos.x, wrapPos.y);
      PVector playerPos = new PVector(pPos.x, pPos.y);

      if (wrapPos.x < pPos.x - player.worldLimits.rect_w/2) unitPos.x = pPos.x + player.worldLimits.rect_w/2;
      if (wrapPos.x > pPos.x + player.worldLimits.rect_w/2) unitPos.x = pPos.x - player.worldLimits.rect_w/2;
      if (wrapPos.y < pPos.y - player.worldLimits.rect_h/2) unitPos.y = pPos.y + player.worldLimits.rect_h/2;
      if (wrapPos.y > pPos.y + player.worldLimits.rect_h/2) unitPos.y = pPos.y - player.worldLimits.rect_h/2;

      Vec2 unitPosVecPixels = new Vec2(unitPos.x, unitPos.y);
      makeBlob(unitPosVecPixels);
    }
  }

  //--------------------------------------------------------------

  boolean checkOtherVehiclesAndPlayerDistanceZones() {

    if (location.getState() == location.vInMovingState) {

      if (!inOtherVehicleDistanceZone) {

        return true;
      } else {

        return false;
      }
    } else {

      return false;
    }
  }

  // ********************************************************
  // UPDATE COLOR
  // ********************************************************

  //--------------------------------------------------------------

  void updateColorNum() {

    int previousColorWheelAngle = colorWheelAngle;
    int newColorWheelAngle = colorWheelAngle;

    while (previousColorWheelAngle == newColorWheelAngle) {

      int vehicleColorNum = int(random(0, 360));
      /*
      int vehicleColorNum = int(random(0, 7));
       int[] colorNums = {0, 45, 90, 135, 180, 225, 270};
       newColorWheelAngle = colorNums[vehicleColorNum];
       */
      newColorWheelAngle = vehicleColorNum;
    }

    colorWheelAngle = newColorWheelAngle;
    updateWithRandomColor();
  }

  void updateWithRandomColor() {

    colorBreathing = color(colorWheelAngle, saturation, brightness, 100);
    colorTrail = color(colorWheelAngle, saturation, brightness);
  }

  // ********************************************************
  // APPLY FORCES
  // ********************************************************

  //--------------------------------------------------------------

  void applyZoneForceOnVehicle(Vehicle otherV) {

    if (otherV.repellOther) {
      colorAngleSwitchVehicle = 1;
    } else {
      colorAngleSwitchVehicle = baseSwitchVehicle;
    }

    float gravity = calculateGravity(colorWheelAngle, otherV.colorWheelAngle, 100000, colorAngleSwitchVehicle);

    Vec2 pos = centerBoid.body.getWorldCenter();
    Vec2 otherPos = otherV.centerBoid.body.getWorldCenter();

    float mass = centerBoid.body.m_mass;

    Vec2 force = calculateForce(pos, otherPos, gravity, mass);

    centerBoid.applyForce(force);
  }

  //--------------------------------------------------------------

  void applyZoneForceOnPlayer(Player player) { // 100000 / 300000


    if (repellOther) {
      colorAngleSwitchPlayer = 1;
    } else {
      colorAngleSwitchPlayer = baseSwitchPlayer;
    }

    float gravity = calculateGravity(player.colorWheelAngle, colorWheelAngle, 100000, colorAngleSwitchPlayer); // 100000 // 75000

    Vec2 pos = centerBoid.body.getWorldCenter();
    Vec2 playerPos = player.centerSphere.body.getWorldCenter();

    float mass = player.centerSphere.body.m_mass;

    Vec2 force = calculateForce(playerPos, pos, gravity, mass);

    player.centerSphere.applyForce(force);
  }

  //--------------------------------------------------------------

  float calculateGravity(int incomingColorAngle, int breathingColorAngle, int gravityVal, int _angleSwitch) {

    float gravity;

    // angle determining when to switch from repel to attract
    int angleSwitch = _angleSwitch;


    int angleDiff = abs(incomingColorAngle - breathingColorAngle);

    if (angleDiff > 180) {
      angleDiff = 360 - angleDiff;
    }

    if (angleDiff > angleSwitch) {
      //println("go away");
      outcomingForceDirection = -1;

      gravity = map(angleDiff, angleSwitch, 180, 0, gravityVal);
    } else {
      //println("come closer");
      outcomingForceDirection = 1;

      gravity = map(angleDiff, 0, angleSwitch, gravityVal, 0);
    }

    return gravity;
  }

  //--------------------------------------------------------------

  Vec2 calculateForce(Vec2 incomingPos, Vec2 pos, float gravity, float mass) {

    // Vector pointing from mover to attractor
    Vec2 force = pos.sub(incomingPos);

    float distance = force.length();
    // Keep force within bounds
    float d = constrain(distance, 1, 5);
    force.normalize();
    // Note the attractor's mass is 0 because it's fixed so can't use that
    float strength =  outcomingForceDirection * (gravity * 1 * mass) / (d * d); // Calculate gravitional force magnitude
    //float strength =  -1 * (localGravity * 1 * sphere.body.m_mass) / (d * d); // Calculate gravitional force magnitude
    force.mulLocal(strength);         // Get force vector --> magnitude * direction


    return force;
  }

  // ********************************************************
  // PLAYER IS IN VEHICLE ZONE
  // ********************************************************
  //--------------------------------------------------------------

  void checkIfPlayerInZone() {

    playerInDistanceZone = false;
    playerInBreathingZone = false;

    if (isPlayerInZone(player, zone.distanceRadius)) { // player is in distance zone

      playerInDistanceZone = true;

      // to make sure body type of revolute joint stays dynamic for attraction / repulsion

      if (isPlayerInZone(player, zone.radius)) { // player is in breathing zone

        playerInBreathingZone = true;
      } else {

        playerInBreathingZone = false;
      }
    } else { // player not in distance zone

      playerInDistanceZone = false;
    }

    if (!playerInDistanceZone) {
      playerInBreathingZone = false;
    }
  }


  boolean isPlayerInZone(Player p, float zoneRadius) {

    Vec2 vehiclePosPix = box2d.getBodyPixelCoord(centerBoid.body);
    ;
    Vec2 playerPosPix = box2d.getBodyPixelCoord(p.centerSphere.body);//b.centerBoid.body.getWorldCenter();

    float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, playerPosPix.x, playerPosPix.y);

    if (d_pix < zoneRadius + p.blobRadius) { //  - p.blobRadius

      colorWithinDistance = colorBreathing;

      if (d_pix < zoneRadius - p.blobRadius) {
        player.location.playerInLungRefillZone = true;
      } else {
        player.location.playerInLungRefillZone = false;
      }

      return true;
    } else {

      //colorWithinDistance = darkGrey;

      return false;
    }
  }

  // ********************************************************
  // VEHICLE IS IN OTHER VEHICLE ZONE
  // ********************************************************

  void checkIfInOtherVehicleZone(Vehicle otherV) {

    if (isInOtherVehicleZone(otherV, otherV.zone.distanceRadius)) {

      inOtherVehicleDistanceZone = true;

      if (isInOtherVehicleZone(otherV, otherV.zone.radius)) {

        inOtherVehicleBreathingZone = true;
        applyZoneForceOnVehicle(otherV); // apply succion/repel gravity between vehicle breathing and vehicle moving
        // membrane

        if (!otherV.repellOther) otherV.thisEnvironment.alterEnergy();
        thisAgent.refillAir(otherV.thisEnvironment);
      }
    }
  }

  //--------------------------------------------------------------

  boolean isInOtherVehicleZone(Vehicle otherV, float otherZoneRadius) {

    Vec2 vehiclePosPix = box2d.getBodyPixelCoord(centerBoid.body);

    Vec2 otherVehiclePosPix = box2d.getBodyPixelCoord(otherV.centerBoid.body);

    float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, otherVehiclePosPix.x, otherVehiclePosPix.y);

    if (d_pix < otherZoneRadius + blobRadius) {

      return true;
    } else {

      return false;
    }
  }

  // ********************************************************
  // VEHICLE IN PLAYER SENSING RADIUS
  // ********************************************************

  boolean checkIfInPlayerArea(float r) {

    if (isInPlayerArea(r)) {

      return true;
    } else {
      return false;
    }
  }


  //--------------------------------------------------------------
  /*
  boolean checkIfInPlayerMaxArea() {
   
   inPlayerMaxRadius = false;
   //inPlayerDistanceArea = false;
   //inPlayerBreathingArea = false;
   
   if (isInPlayerArea(player.sensingMaxRadius)) {
   
   inPlayerMaxRadius = true;
   } else {
   inPlayerMaxRadius = false;
   }
   
   return inPlayerMaxRadius;
   }
   */

  //--------------------------------------------------------------

  boolean isInPlayerArea(float radius) {

    Vec2 vehiclePosPix = box2d.getBodyPixelCoord(centerBoid.body);

    Vec2 playerPosPix = box2d.getBodyPixelCoord(player.centerSphere.body);

    float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, playerPosPix.x, playerPosPix.y);

    if (d_pix < radius + blobRadius) {

      return true;
    } else {

      return false;
    }
  }


  // ********************************************************
  // OTHER VEHICLE IS ZONE
  // ********************************************************

  void checkIfOtherVehicleInZone() {

    distanceFinal = false;
    breathingFinal = false;
    otherVehicleInDistanceZone = false;
    otherVehicleInBreathingZone = false;

    checkIfOtherVehicleIsInZoneRadius();

    if (distanceFinal) {

      otherVehicleInDistanceZone = true;

      if (breathingFinal) {

        otherVehicleInBreathingZone = true;
      }
    }
  }

  //--------------------------------------------------------------

  void checkIfOtherVehicleIsInZoneRadius() {

    for (Agent a : agents) {

      if (isOtherVehicleInZone(a.v, zone.distanceRadius)) {

        distanceFinal = true;

        if (isOtherVehicleInZone(a.v, zone.radius)) {

          breathingFinal = true;
        }
      }
    }
  }

  //--------------------------------------------------------------

  boolean isOtherVehicleInZone(Vehicle otherV, float zoneRadius) {

    Vec2 vehiclePosPix = box2d.getBodyPixelCoord(centerBoid.body);

    Vec2 otherVehiclePosPix = box2d.getBodyPixelCoord(otherV.centerBoid.body);

    float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, otherVehiclePosPix.x, otherVehiclePosPix.y);

    if (d_pix < zoneRadius + otherV.blobRadius) {

      return true;
    } else {

      return false;
    }
  }

  // ********************************************************
  // AFTER COLLISION
  // ********************************************************

  void collided() {

    repellOther = true;

    //println("collision!");
  }

  // ********************************************************
  // DELETE VEHICLE
  // ********************************************************
  /*
  void die() {
   
   killBlob();
   location.setState(location.vInDeadState);
   }
   */

  void die() {

    deadPosition = box2d.getBodyPixelCoord(centerBoid.body);
    location.setState(location.vInDeadState);

    println("deadposition.x ", deadPosition.x);
    killBlob();
  }

  void killBlob() {

    centerBoid.killBody();

    joints.clear();
    spheres.clear();

    /*
    for (int i=0; i < spheres.size(); i++) {
     VehicleSphere sphere = spheres.get(i);
     sphere.killBody();
     }
     */
  }





  // ********************************************************
  // DISPLAY
  // ********************************************************

  void display() {


    if (!inMotion) {

      //zone.display();
      //thisEnvironment.display(data.sensingRadiusSlider.getPos(), colorBreathing);
      thisEnvironment.display(data.sensingRadiusSlider.getPos());

      /*
      if ( zone.getState() == zone.fullState) {
       
       zone.display();
       membrane.display(data.sensingRadiusSlider.getPos());
       } else {
       
       zone.display();
       }
       */

      displayBlob();
    } else {

      displayBlob();

      lung.display();
    }

    //displaySpheres();
  }


  //--------------------------------------------------------------

  void displayBlob() {

    int many = spheres.size()-1;

    beginShape();
    noFill();
    strokeWeight(sphereRadius*2);
    fill(colorWheelAngle, saturation, brightness, fadeValue);
    stroke(colorWheelAngle, saturation, brightness, fadeValue);

    Vec2 pos;
    pos = box2d.getBodyPixelCoord(spheres.get(many-1).body);
    pos.x = int(pos.x);
    pos.y = int(pos.y);

    curveVertex(pos.x, pos.y); // begin control point

    for (int i = 0; i <= many; i++) {
      Body b = spheres.get(i).body;
      // We look at each body and get its screen position
      pos = box2d.getBodyPixelCoord(b);
      pos.x = int(pos.x);
      pos.y = int(pos.y);

      curveVertex(pos.x, pos.y);
    }

    pos = box2d.getBodyPixelCoord(spheres.get(1).body);
    pos.x = int(pos.x);
    pos.y = int(pos.y);

    curveVertex(pos.x, pos.y);

    endShape(); // with or without cp,  not use CLOSE

    strokeWeight(2);
  }

  //--------------------------------------------------------------

  // Draw the skeleton as circles for bodies and lines for joints
  void displaySpheres() {

    centerBoid.display();

    for (int i=0; i < spheres.size(); i++) {
      VehicleSphere sphere = spheres.get(i);
      sphere.display();
    }
  }

  //--------------------------------------------------------------

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

  //--------------------------------------------------------------

  void displayDeadVehicle() {

    ellipseMode(RADIUS);

    pushMatrix();

    //Vec2 pos = box2d.getBodyPixelCoord(centerBoid.body);

    translate(deadPosition.x, deadPosition.y);

    //if (showDistance) {
    // outer circle for checking distance

    strokeWeight(10);
    stroke(darkGrey);

    stroke(darkGrey);


    noFill();
    //fill(0, 255, 0);
    circle(0, 0, radius);

    popMatrix();
    strokeWeight(1);
  }


  // ********************************************************
  // CREATION
  // ********************************************************

  void makeBlob(Vec2 posVecPixels_) {

    ConstantVolumeJointDef cvjd = new ConstantVolumeJointDef();

    // Where and how big is the blob
    radius = 70;
    totalPoints = 32;
    sphereRadius = 35; //25;
    centerBoidRadius = 35;

    centerBoid = new VehicleBoid(posVecPixels_.x, posVecPixels_.y, centerBoidRadius, bodyType, CATEGORY_VEHICLE, MASK_VEHICLE, index+1);
    // make body


    // Initialize all the points in a circle
    for (int i = 0; i <= totalPoints; i++) {

      // Look polar to cartesian coordinate transformation!
      float t = TWO_PI * (float)i/totalPoints;
      float x = posVecPixels_.x + radius * sin(t);
      float y = posVecPixels_.y + radius * cos(t);

      spheres.add(new VehicleSphere(x, y, sphereRadius, "DYNAMIC", CATEGORY_VEHICLE, MASK_VEHICLE, index+1));

      cvjd.addBody(spheres.get(i).body);

      //if (i == 0 || i == 8 || i == 16 || i == 24 ) {
      if (i == 0 || i == 4 || i == 8 || i == 12 || i == 16 || i == 20 || i == 24 || i == 28) {

        //createJoints(spheres.get(i-1).body, spheres.get(i).body);
        //createDistanceJoints(spheres[spheres.length-1].body, centerSphere.body);
        createJoints(spheres.get(spheres.size()-1).body, centerBoid.body);
      }
    }

    cvjd.frequencyHz = 0;
    cvjd.dampingRatio = 0.1; // 0.5

    //cvjd.frequencyHz = 10;
    //cvjd.dampingRatio = 0.9;

    cvjd.collideConnected = false;
    box2d.createJoint(cvjd);
  }

  //--------------------------------------------------------------

  void createJoints(Body a, Body b) {

    DistanceJointDef djd = new DistanceJointDef();
    djd.bodyA = a;
    djd.bodyB = b;

    // Equilibrium length is distance between these bodies
    Vec2 apos = a.getWorldCenter();
    Vec2 bpos = b.getWorldCenter();
    float d = dist(apos.x, apos.y, bpos.x, bpos.y);
    djd.length = d;


    // These properties affect how springy the joint is
    djd.frequencyHz = 0;
    djd.dampingRatio = 0.1; // 0.5

    // These properties affect how springy the joint is
    // frequencyHz (1-5) rigid: 0
    // dampingRation (0-1 rigid: 1

    // original blob
    //djd.frequencyHz = 5;
    //djd.dampingRatio =  0.9;//0.9;

    // Make the joint.
    DistanceJoint dj = (DistanceJoint) box2d.world.createJoint(djd);
    joints.add(dj);
  }
}
