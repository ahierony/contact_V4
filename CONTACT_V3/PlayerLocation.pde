interface PlayerLocationState {

  public boolean getReadyToSetState();
  public void setReadyToSetState(boolean rtss);

  void update();
}

class PlayerLocation {

  PlayerLocationState state;

  PlayerLocationState pLocMovingState;
  PlayerLocationState pLocBreathingState;
  PlayerLocationState pLocVehicleZoneState;

  Player player;

  Vehicle currentVehicle;

  boolean isHit;


  //--------------------------------------------------------------

  PlayerLocation(Player p) {

    player = p;

    pLocMovingState = new PLocMovingState(player);
    pLocBreathingState = new PLocBreathingState(player);
    pLocVehicleZoneState = new PLocVehicleZoneState(player);

    setState(pLocMovingState);

    isHit = false;
  }

  //--------------------------------------------------------------

  void setState(PlayerLocationState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  PlayerLocationState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {

    state.update();

    setLocationState();

    resetStates();
  }

  void resetStates() {

    if (getState() == pLocMovingState) {
      //
      pLocBreathingState.setReadyToSetState(true);
      pLocVehicleZoneState.setReadyToSetState(true);
      //
    } else if (getState() == pLocBreathingState) {
      //
      pLocMovingState.setReadyToSetState(true);
      pLocVehicleZoneState.setReadyToSetState(true);
      //
    } else if (getState() == pLocVehicleZoneState) {
      //
      pLocMovingState.setReadyToSetState(true);
      pLocBreathingState.setReadyToSetState(true);
      //
    }
  }

  void setLocationState() {

    boolean inVehicleDistanceZone = false;
    boolean inVehicleBreathingZone = false;

    for (Vehicle v : vehicles) {
      if (v.playerInDistanceZone) {
        inVehicleDistanceZone = true;
        if (v.playerInBreathingZone) {
          inVehicleBreathingZone = true;
          currentVehicle = v;
        }
      }
    }
    // ******************
    // IN SPACE MOVING
    // ******************

    if (getState() == pLocMovingState) {

      // check to see if player is still to transition into breathing
      // check to see if player is entering vehicle zone

      // check if player is in the zone to prevent body to go in static mode

      if (inVehicleBreathingZone) {
      //if (inVehicleDistanceZone) {

        if (pLocVehicleZoneState.getReadyToSetState()) {
          {

            setState(pLocVehicleZoneState);

            if (playSound) {
              data.trackPlayerInZone(true);
            }
          }
        }
      } else {

        // THIS CODE COMMENTED OUT FOR CONTACT V3 NO BREATHING STATE FOR PLAYER
        /*
        if (player.getLinearVelocity() <= player.minVel ) {
         
         if (pLocBreathingState.getReadyToSetState()) {
         player.jointSphere.body.setType(BodyType.STATIC);
         setState(pLocBreathingState);
         }
         }*/
      }



      // ******************
      // IN SPACE BREATHING
      // ******************
    } else if (getState() == pLocBreathingState) {

      // check to see if player is picking up speed and transition to moving
      if (player.lung.getState() != player.lung.emptyState && player.lockedEye == "both") {

        if (pLocMovingState.getReadyToSetState()) {
          player.jointSphere.body.setType(BodyType.DYNAMIC);
          setState(pLocMovingState);
          player.area.setState(player.area.notBreathingState);
        }
      }


      if (inVehicleBreathingZone) {

        if (pLocVehicleZoneState.getReadyToSetState()) {
          {
            player.jointSphere.body.setType(BodyType.DYNAMIC);
            setState(pLocVehicleZoneState);
          }
        }
      }
      // ******************
      // IN VEHICLE ZONE
      // ******************
    } else if (getState() == pLocVehicleZoneState) {

      // check to see if player is out of vehicle zone and moving

      if (isHit) {

        if (player.lung.getState() == player.lung.fullState) {

          setState(pLocMovingState);

          if (playSound) {
            data.trackPlayerInZone(false);
          }
        }
      } else {

        if (!inVehicleBreathingZone) {

          if (pLocMovingState.getReadyToSetState()) {

            setState(pLocMovingState);

            if (playSound) {
              data.trackPlayerInZone(false);
            }
          }
        }
      }
    }
  }


  //--------------------------------------------------------------

  void setLockedState() {
  }
}

// ********************************************************
// STATE CLASSES
// ********************************************************


// ********************************************************
// MOVING
// ********************************************************

class PLocMovingState implements PlayerLocationState {

  Player player;

  boolean readyToSetState;

  PLocMovingState(Player p) {

    readyToSetState = true;

    player = p;

    //player.area.isVisible = false;
    //player.area.isBreathing = false;
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      player.area.setState(player.area.notBreathingState);

      player.area.isVisible = false;
      player.area.isBreathing = false;

      setReadyToSetState(false);
    }

    setLungState();
  }

  void setLungState() {

    if (player.lung.breath.movement == "empty") {
      player.lung.setState(player.lung.emptyState);
    }

    if (player.lung.getState() != player.lung.emptyState) {

      if (player.lockedEye == "both") {

        player.lung.setState(player.lung.exhaleState);
      } else {

        player.lung.setState(player.lung.holdState);
      }
    }
  }
}

// ********************************************************
// BREATHING
// ********************************************************

class PLocBreathingState implements PlayerLocationState {

  boolean readyToSetState;

  Player player;

  boolean startReplenishing;
  boolean isReplenishing;
  //boolean updateCounter;
  //int counter;

  PLocBreathingState(Player p) {

    readyToSetState = true;

    player = p;

    startReplenishing = false;
    isReplenishing = false;
  }


  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }


  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      player.area.radius = player.area.radiusMin;

      player.breath.initialize();

      player.area.isVisible = true;
      player.area.isBreathing = true;

      setReadyToSetState(false);
    }

    if (player.area.isBreathing) {
      player.breath.breathe();
    }

    setLungState();

    if (collision.checkPlayerAgainstVehicleInArea()) {
      updateCollision();
    }

    if (player.readyToUpdateDistanceArea) {
      checkPlayerDistanceAreaAgainstVehiclesDistanceZone();
    }
    player.readyToUpdateDistanceArea = false;
  }

  //--------------------------------------------------------------

  void setLungState() {

    // println("player.lung.breath.movement ", player.lung.breath.movement);


    // lung is not full
    if (player.lung.getState() != player.lung.fullState) {


      if (player.lung.breath.movement == "full") {
        player.lung.setState(player.lung.fullState);
      }


      if (!player.vehicleInDistanceArea) {
        //
        lungInhaleWhenNoVehicleInArea();
        //
      } else { // there is a vehicle in player distance area

        // vehicle is in breathing area
        if (player.vehicleInBreathingArea) {
          player.lung.setState(player.lung.inhaleState);
        } else {

          if (player.lung.getState() != player.lung.emptyState) {

            player.lung.setState(player.lung.holdState);
          }
        }
      }
    }
  }

  //--------------------------------------------------------------

  void lungInhaleWhenNoVehicleInArea() {

    if (player.area.getState() == player.area.inhaleState) {
      //
      if (isReplenishing) {

        if (player.lung.breath.movement == "full") {
          player.lung.setState(player.lung.fullState);
          isReplenishing = false;
        } else {
          player.lung.setState(player.lung.inhaleState);
        }
      }
      //
    } else if (player.area.getState() == player.area.emptyState) {

      // initiate lung replenishment
      if (player.lung.getState() == player.lung.emptyState) {

        if (!startReplenishing) {
          startReplenishing = true;
          isReplenishing = true;
        }
      }
    } else if (player.area.getState() == player.area.fullState) {

      isReplenishing = false;
      startReplenishing = false;
    }
  }

  //--------------------------------------------------------------

  void updateCollision() {

    player.lung.setState(player.lung.emptyState);
    player.area.setState(player.area.emptyState);
  }


  void checkPlayerDistanceAreaAgainstVehiclesDistanceZone() {

    float playerAreaMinRadius = player.area.originalDistanceRadius * 0.6;

    Vec2 playerPosPix = box2d.getBodyPixelCoord(player.centerSphere.body);

    float playerAreaTempRadius = player.area.originalDistanceRadius;
    float offset = 10.0f;

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      if (!v.inMotion) {

        Vec2 vehiclePosPix = box2d.getBodyPixelCoord(v.centerBoid.body);

        float d_pix = dist(playerPosPix.x, playerPosPix.y, vehiclePosPix.x, vehiclePosPix.y);

        if (d_pix < v.zone.distanceRadius + playerAreaTempRadius + offset) {

          playerAreaTempRadius = d_pix - v.zone.distanceRadius - offset;
        }
      }
    }
    if (playerAreaTempRadius >= playerAreaMinRadius) {
      player.area.distanceRadius = playerAreaTempRadius;
    } else {
      player.area.distanceRadius = playerAreaMinRadius;
    }
  }
}

// ********************************************************
// IN VEHICLE ZONE
// ********************************************************

class PLocVehicleZoneState implements PlayerLocationState {

  boolean readyToSetState;
  Player player;

  PLocVehicleZoneState(Player p) {

    readyToSetState = true;

    player = p;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      setReadyToSetState(false);
    }

    player.lung.setState(player.lung.holdState);

    if (collision.checkPlayerAgainstVehicleInZone()) {
      //updateCollision();
      player.location.isHit = true;
    }

    if (player.location.isHit) {
      setLungState();
    }

    checkImpulseState();
  }

  void checkImpulseState() {

    if (player.rightEye.inImpulse || player.leftEye.inImpulse) {
      player.engagedInImpulse = true;
    } 
    
    if(player.leftEye.pupilState == "unlocked" && player.rightEye.pupilState == "unlocked"){
      player.leftEye.inImpulse = false;
      player.rightEye.inImpulse = false;
      player.engagedInImpulse = false;
    }
    
  }

  void setLungState() {

    if (player.lung.breath.movement == "full") {
      player.lung.setState(player.lung.fullState);
      player.location.isHit = false;
      player.location.setState(player.location.pLocMovingState);
    }

    if (player.lung.getState() != player.lung.fullState) {

      player.lung.setState(player.lung.inhaleState);
    }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
