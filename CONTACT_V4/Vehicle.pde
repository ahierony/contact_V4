class Vehicle {

  ArrayList<VehicleSphere> spheres;
  ArrayList<Joint> joints;
  ArrayList<Joint> sideJoints;
  ArrayList<Vehicle> vehicles;

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

  Player player;

  boolean inPlayerDistanceArea;
  boolean inPlayerBreathingArea;
  boolean inOtherVehicleBreathingZone;
  boolean inOtherVehicleDistanceZone;
  boolean otherVehicleInDistanceZone;
  boolean otherVehicleInBreathingZone;
  boolean otherBreathingVehicleComingClose;

  boolean isReadyForCollision;
  boolean readyToUpdateDistanceZone;
  //

  // other vehicle test
  boolean distanceFinal;
  boolean breathingFinal;

  VehicleMembrane membrane;

  //AUDIO
  //boolean vehicleBreathingAudioIsPlaying;

  //--------------------------------------------------------------

  // Constructor
  Vehicle(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p) {

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
    if (!inMotion) {
      colorBreathing = color(colorWheelAngle, saturation, brightness, 100);
    }
    colorTrail = color(colorWheelAngle, saturation, brightness);
    colorWithinDistance = darkGrey;

    unitHalfSize = unit_w * 0.5;

    // Create the empty ArrayLists
    //spheres = new ArrayList<Sphere>();
    //spheres = new VehicleSphere[0];
    spheres = new ArrayList<VehicleSphere>();
    joints = new ArrayList<Joint>();
    sideJoints = new ArrayList<Joint>();
    vehicles = new ArrayList<Vehicle>();

    ellipseMode(RADIUS);

    breath = new Breath("vehicle");

    makeBlob(posVecPixels);

    blobRadius = radius + sphereRadius;

    zone = new VehicleZone(this);

    if (!inMotion) {
      isReadyForCollision = true;
      zone.isBreathing = true;
      membrane = new VehicleMembrane(x, y);
    } else {
      calibrateLungRadius = 0;
      lung = new VehicleLung(this);
      lung.previousRadius = lung.radiusMax;
    }

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

    location = new VehicleLocation(this, player, _inMotion);

    inPlayerDistanceArea = false;
    inPlayerBreathingArea = false;
    inOtherVehicleBreathingZone = false;
    inOtherVehicleDistanceZone = false;
    otherVehicleInDistanceZone = false;
    otherVehicleInBreathingZone = false;

    otherBreathingVehicleComingClose = false;

    colorAngleSwitchPlayer = 30; // 50; //45;
    colorAngleSwitchVehicle = 90; //5; //7; //15; //7;

    initialize();
  }

  //--------------------------------------------------------------

  void initialize() {

    if (inMotion) {
      zone.setState(zone.inMotionNoZoneState);
    } else {
      zone.setState(zone.emptyState);
    }
  }

  //--------------------------------------------------------------


  void run(ArrayList<Vehicle> vs) {

    vehicles = vs;

    if (location.getState() != location.vInDeadState) {

      update();

      display();
    } else {

      displayDeadVehicle();
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


      for (Vehicle v : vehicles) {

        if (v != this) {

          if (v.location.getState() == v.location.vInBreathingState) {

            checkIfInOtherVehicleZone(v);
          }
        }
      }


      location.update();

      lung.update();

      centerBoid.update();

      //println("vehicle lung state ", lung.getState());

      //checkRippleCount(); // vehicle stops moving and starts breathing // not in this version
    } else { // // VEHICLE IS NOT IN MOTION

      boolean otherVehicleAlreadyHasPlayerInDistanceZone = false;

      for (int i = 0; i < vehicles.size(); i++) {

        Vehicle v = vehicles.get(i);

        if (v != this) {

          if (v.playerInDistanceZone) {

            otherVehicleAlreadyHasPlayerInDistanceZone = true;
          }
        }
      }

      if (!otherVehicleAlreadyHasPlayerInDistanceZone) {

        checkIfPlayerInZone();
      }
      //checkIfOtherVehicleInZone();

      /*
      if (playerInDistanceZone && otherBreathingVehicleComingClose) {
       
       zone.setState(zone.holdState);
       
       } else {
       
       
       
       }
       */


      location.update();

      zone.update();

      if (zone.getState() == zone.fullState) {

        membrane.update(zone.radius);
      }



      posVecPixels.set(centerBoid.posVecPixels.x, centerBoid.posVecPixels.y);
    }
  }

  //--------------------------------------------------------------

  boolean checkOtherVehiclesAndPlayerDistanceZones() {

    if (location.getState() == location.vInMovingState) {

      if (!inOtherVehicleDistanceZone && !inPlayerDistanceArea) {

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

    float gravity = calculateGravity(colorWheelAngle, otherV.colorWheelAngle, 100000, colorAngleSwitchVehicle);

    Vec2 pos = centerBoid.body.getWorldCenter();
    Vec2 otherPos = otherV.centerBoid.body.getWorldCenter();

    float mass = centerBoid.body.m_mass;

    Vec2 force = calculateForce(pos, otherPos, gravity, mass);

    centerBoid.applyForce(force);
  }

  //--------------------------------------------------------------

  void applyZoneForceOnPlayer(Player player) { // 100000 / 300000

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

    if (d_pix < zoneRadius + p.blobRadius) {

      colorWithinDistance = colorBreathing;

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

    for (Vehicle otherV : vehicles) {

      if (otherV != this) {

        if (otherV.inMotion) {

          if (isOtherVehicleInZone(otherV, zone.distanceRadius)) {

            distanceFinal = true;

            if (isOtherVehicleInZone(otherV, zone.radius)) {

              breathingFinal = true;
            }
          }
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
  // DELETE VEHICLE
  // ********************************************************

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

      if ( zone.getState() == zone.fullState) {

        membrane.display(colorBreathing);
      } else {

        zone.display();
      }

      displayBlob();
    } else {

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

    translate(posVecPixels.x, posVecPixels.y);

    //if (showDistance) {
    // outer circle for checking distance

    strokeWeight(3);
    stroke(darkGrey);
    //fill(vehicle.darkGrey);
    noFill();
    //circle(0, 0, zone.distanceRadius);
    //}

    noFill();
    circle(0, 0, zone.radius);
    // repel / attract zone (breathing)

    //strokeWeight(1);
    //stroke(colorBreathing);
    stroke(darkGrey);

    //fill(vehicle.colorBreathing); // TEST
    noFill();
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

    centerBoid = new VehicleBoid(posVecPixels_.x, posVecPixels_.y, centerBoidRadius, bodyType, CATEGORY_VEHICLE, MASK_VEHICLE);
    // make body


    // Initialize all the points in a circle
    for (int i = 0; i <= totalPoints; i++) {

      // Look polar to cartesian coordinate transformation!
      float t = TWO_PI * (float)i/totalPoints;
      float x = posVecPixels_.x + radius * sin(t);
      float y = posVecPixels_.y + radius * cos(t);

      spheres.add(new VehicleSphere(x, y, sphereRadius, "DYNAMIC", CATEGORY_VEHICLE, MASK_VEHICLE));

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
