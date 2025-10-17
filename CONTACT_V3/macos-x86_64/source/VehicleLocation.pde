interface VehicleLocationState {

  public boolean getReadyToSetState();
  public void setReadyToSetState(boolean rtss);

  void update();
}

class VehicleLocation {

  VehicleLocationState state;

  VehicleLocationState vInMovingState;
  VehicleLocationState vInBreathingState;
  VehicleLocationState vInPlayerAreaState;
  VehicleLocationState vInOtherVehicleZoneState;
  VehicleLocationState vInDeadState;

  Vehicle vehicle;
  Player player;

  //--------------------------------------------------------------

  VehicleLocation(Vehicle v, Player p, boolean _inMotion) {

    vehicle = v;
    player = p;

    vInMovingState = new VInMovingState(vehicle, player);
    vInBreathingState = new VInBreathingState(vehicle);
    vInPlayerAreaState = new VInPlayerAreaState(vehicle);
    vInOtherVehicleZoneState = new VInOtherVehicleZoneState(vehicle);
    vInDeadState = new VInDeadState(vehicle);

    if (_inMotion) {
      setState(vInMovingState);
    } else {
      setState(vInBreathingState);
    }
  }

  //--------------------------------------------------------------

  void setState(VehicleLocationState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  VehicleLocationState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {

    state.update();

    setLocationState();

    resetStates();
  }

  void resetStates() {

    if (getState() == vInMovingState) {
      //
      vInBreathingState.setReadyToSetState(true);
      vInPlayerAreaState.setReadyToSetState(true);
      vInOtherVehicleZoneState.setReadyToSetState(true);
      //
    } else if (getState() == vInBreathingState) {
      //
      vInMovingState.setReadyToSetState(true);
      vInPlayerAreaState.setReadyToSetState(true);
      vInOtherVehicleZoneState.setReadyToSetState(true);
      //
    } else if (getState() == vInPlayerAreaState) {
      //
      vInMovingState.setReadyToSetState(true);
      vInBreathingState.setReadyToSetState(true);
      vInOtherVehicleZoneState.setReadyToSetState(true);
      //
    } else if (getState() == vInOtherVehicleZoneState) {
      //
      vInMovingState.setReadyToSetState(true);
      vInPlayerAreaState.setReadyToSetState(true);
      vInOtherVehicleZoneState.setReadyToSetState(true);
    }
  }

  //--------------------------------------------------------------

  void setLocationState() {


    if (getState() == vInMovingState) { // vehicle is moving
      // ******************
      // MOVING
      // ******************

      if (!vehicle.inMotion) { // vehicle is now breathing // vehicle stopped moving and is breathing

        if (vInBreathingState.getReadyToSetState()) {

          setState(vInBreathingState); // changing state to breathing
        }
      } else { // is in motion

        if (vehicle.inPlayerBreathingArea) { // vehicle is moving and is entering Player's area

          if (vInPlayerAreaState.getReadyToSetState()) {

            setState(vInPlayerAreaState); // changing state to player's area
          }
        } else if (vehicle.inOtherVehicleBreathingZone) { // vehicle is moving and is entering another vehicle's zone

          if (vInOtherVehicleZoneState.getReadyToSetState()) {

            setState(vInOtherVehicleZoneState); // changing state to player's area
          }
        }
      }
    } else if (getState() == vInBreathingState) {

      // ******************
      // BREATHING
      // ******************
    } else if (getState() == vInPlayerAreaState) { // in player's area

      // ******************
      // IN PLAYER AREA
      // ******************

      if (!vehicle.inPlayerBreathingArea) { // is out of player area

        if (vInMovingState.getReadyToSetState()) {

          setState(vInMovingState); // changing state to moving
        }
      }
    } else if (getState() == vInOtherVehicleZoneState) {

      // ******************
      // IN OTHER VEHICLE ZONE
      // ******************

      if (!vehicle.inOtherVehicleBreathingZone) {

        if (vInMovingState.getReadyToSetState()) {

          setState(vInMovingState); // changing state to moving
        }
      }
    }
  }


  //--------------------------------------------------------------

  void setLockedState() {
  }
} // playerLock class



// ********************************************************
// STATE CLASSES
// ********************************************************

class VInMovingState implements VehicleLocationState {

  boolean readyToSetState;

  Vehicle vehicle;
  Player player;

  VInMovingState(Vehicle v, Player p) {

    vehicle = v;
    player = p;

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      setReadyToSetState(false);
    }

    vehicle.centerBoid.isMoving();

    addTrailRipples();
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }

  void addTrailRipples() {
    Vec2 boidPos;
    boidPos = box2d.getBodyPixelCoord(vehicle.centerBoid.body);
    vehicle.trail.addRipples(boidPos.x, boidPos.y, vehicle.colorTrail, vehicle.fadeValue-100);
  }
}

// ********************************************************

class VInBreathingState implements VehicleLocationState {

  boolean readyToSetState;

  Vehicle vehicle;

  Timer timer;
  int randomTime;

  float vehicleZoneTempRadius;

  VInBreathingState(Vehicle v) {

    vehicle = v;

    readyToSetState = true;

    randomTime = int(random(500, 5000)); // between .5 and 3 second pause
    timer = new Timer(randomTime);

    timer.start();
  }

  //--------------------------------------------------------------

  void update() {


    if (readyToSetState) {

      if (timer.isFinished()) {

        setReadyToSetState(false);
      }
    } else {

      if (vehicle.isPlayerInZone(player, vehicle.zone.radius)) { // player is in breathing zone

        vehicle.applyZoneForceOnPlayer(player);
      }

      if (vehicle.zone.isBreathing) {
        vehicle.breath.breathe();
      }

      if (vehicle.readyToUpdateDistanceZone) {

        if (vehicle.zone.getState() == vehicle.zone.emptyState) {

          updateVehicleRadius();
        }

        vehicle.readyToUpdateDistanceZone = false;
      }
    }
  }

  void updateVehicleRadius() {

    vehicleZoneTempRadius = vehicle.zone.originalRadiusMax;

    Vec2 playerPosPix = box2d.getBodyPixelCoord(player.centerSphere.body);
    Vec2 vehiclePosPix = box2d.getBodyPixelCoord(vehicle.centerBoid.body);

    if (player.location.getState() == player.location.pLocBreathingState) {
      checkVehicleZoneAgainstDistance(vehiclePosPix, playerPosPix, player.area.distanceRadius);
    }

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      if (!v.inMotion && vehicle != v) {

        Vec2 otherVehiclePosPix = box2d.getBodyPixelCoord(v.centerBoid.body);

        vehicleZoneTempRadius = checkVehicleZoneAgainstDistance(vehiclePosPix, otherVehiclePosPix, v.zone.distanceRadius);
      }
    }


    //vehicle.zone.distanceRadius = vehicleZoneTempRadius;


    if (vehicleZoneTempRadius > vehicle.zone.radiusMin) {
      vehicle.zone.distanceRadius = vehicleZoneTempRadius;
    } else {
      vehicle.zone.distanceRadius = vehicle.zone.radiusMin;
    }
  }


  float checkVehicleZoneAgainstDistance(Vec2 vehiclePosPix, Vec2 otherPosPix, float otherRadius) {

    float offset = 10.0f;

    float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, otherPosPix.x, otherPosPix.y);

    if (d_pix < otherRadius + vehicleZoneTempRadius + offset) {

      vehicleZoneTempRadius = d_pix - otherRadius - offset;
    }

    return vehicleZoneTempRadius;
  }


  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class VInPlayerAreaState implements VehicleLocationState {

  boolean readyToSetState;

  Vehicle vehicle;

  VInPlayerAreaState(Vehicle v) {

    vehicle = v;

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      setReadyToSetState(false);
    }

    vehicle.applyAreaForceOnVehicle(player);
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class VInOtherVehicleZoneState implements VehicleLocationState {

  boolean readyToSetState;

  Vehicle vehicle;

  VInOtherVehicleZoneState(Vehicle v) {

    vehicle = v;

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {


    if (readyToSetState) {

      setReadyToSetState(false);
    }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
// ********************************************************

class VInDeadState implements VehicleLocationState {

  boolean readyToSetState;

  Vehicle vehicle;

  VInDeadState(Vehicle v) {

    vehicle = v;

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {


    if (readyToSetState) {

      setReadyToSetState(false);
    }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
