class Collision {

  Collision() {
  }

  //--------------------------------------------------------------


  // RIPPLES AGAINST VEHICLE

  void checkVehiclesAgainstVehicleRipples() {

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      for (int j = 0; j < vehicles.size(); j++) {

        Vehicle o = vehicles.get(j);

        if (v != o) {

          if (o.inMotion) {

            if (o.trail.ripples != null) {

              for (int k = 0; k < o.trail.ripples.size(); k++) {

                VehicleRipple r = o.trail.ripples.get(k);

                Vec2 thisPosPix = box2d.getBodyPixelCoord(v.centerBoid.body);

                float d_pix = dist(thisPosPix.x, thisPosPix.y, r.x, r.y);

                if (d_pix < v.blobRadius + (r.radius)) {

                  r.opacity = 0;
                }
              }
            }
          }
        }
      }
    }
  }

  //--------------------------------------------------------------
  boolean readyToGiveBirth = false;

  // VEHICLE AGAINST VEHICLE

  void checkVehicleAgainstVehicle() {

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      for (int j = 0; j < vehicles.size(); j++) {

        Vehicle o = vehicles.get(j);

        if (v != o) {

          if (o.inMotion && !v.inMotion) {

            if (vehiclesAreTouching(o, v)) {

              if ( v.zone.getState() != v.zone.collisionState) {

                if (v.zone.collisionState.getReadyToSetState()) {

                  manageBirth(o, v);
                  switchVehicleFromBreathingToMoving(v);
                  //v.zone.setState(v.zone.collisionState);
                }
              }
            }
          } else if (!o.inMotion && v.inMotion) {

            if (vehiclesAreTouching(v, o)) {

              if ( o.zone.getState() != o.zone.collisionState) {

                if (o.zone.collisionState.getReadyToSetState()) {

                  manageBirth(v, o);
                  switchVehicleFromBreathingToMoving(v);
                  //o.zone.setState(o.zone.collisionState);
                }
              }
            }
          }
        }
      }
    }
  }

  void manageBirth(Vehicle vInMotion, Vehicle vBreathing) {

    giveVehicleBirth(vInMotion, vBreathing);

    Vec2 vehiclePosVecPixels = box2d.getBodyPixelCoord(vBreathing.centerBoid.body);
    vehiclePosVecPixels.subLocal(vBreathing.centerBoid.offset);
    Vec2 targetPosition = box2d.coordPixelsToWorld(vehiclePosVecPixels);

    vInMotion.centerBoid.status = "flee";
    vInMotion.centerBoid.flee(targetPosition);
  }

  boolean vehiclesAreTouching(Vehicle vInMotion, Vehicle vBreathing) {

    Vec2 vBreathingPos = box2d.getBodyPixelCoord(vBreathing.centerBoid.body);
    Vec2 vInMotionPos = box2d.getBodyPixelCoord(vInMotion.centerBoid.body);

    float d_pix = dist(vBreathingPos.x, vBreathingPos.y, vInMotionPos.x, vInMotionPos.y);

    if (d_pix < vInMotion.blobRadius + vBreathing.blobRadius) {

      return true;
    } else {

      return false;
    }
  }

  void giveVehicleBirth(Vehicle vInMotion, Vehicle vBreathing) {

    Vec2 vBreathingPos = box2d.getBodyPixelCoord(vBreathing.centerBoid.body);
    Vec2 vInMotionPos = box2d.getBodyPixelCoord(vInMotion.centerBoid.body);

    Vec2 velocity = vBreathingPos.sub(vInMotionPos);

    float len = velocity.length();
    len += 200; //50;
    velocity.normalize();
    velocity.mulLocal(len);

    Vec2 newVelocity = vBreathingPos.add(velocity);

    int vehicleColorNum = int(random(0, 360));

    Vehicle vehicle = new Vehicle(newVelocity.x, newVelocity.y, vehicleColorNum, true, "DYNAMIC", 0, player);

    vehicles.add(vehicle);
  }

  //--------------------------------------------------------------

  // RIPPLES AGAINST PLAYER

  void checkPlayerAgainstVehicleRipples() {

    for (int j = 0; j < vehicles.size(); j++) {

      Vehicle o = vehicles.get(j);

      if (o.inMotion) {

        if (o.trail.ripples != null) {

          for (int k = 0; k < o.trail.ripples.size(); k++) {

            VehicleRipple r = o.trail.ripples.get(k);

            Vec2 playerPosPix = box2d.getBodyPixelCoord(player.centerSphere.body);

            float d_pix = dist(playerPosPix.x, playerPosPix.y, r.x, r.y);

            if (d_pix < player.blobRadius + (r.radius)) {

              r.opacity = 0;
            }
          }
        }
      }
    }
  }

  //--------------------------------------------------------------


  // PLAYER AGAINST VEHICLES

  boolean checkPlayerAgainstVehicleInZone() { // called from player location

    int vNum = 0;

    boolean vehicleWasTouched = false;

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      for (VehicleSphere vs : v.spheres) {

        if (vs.wasTouched) {

          vNum = i;

          vs.wasTouched = false;

          if (v.isReadyForCollision) {

            //data.playerTouchedVehicle = true;

            if (isTrackingData) {
              data.trackPlayerTouchedVehicle(true);
            }

            println("player touched vehicle ");
            println(player.location.getState());

            vehicleWasTouched = true;

            
            //killVehicle(vNum);
            
            break;
          }
        }
      }
    }

    return vehicleWasTouched;
  }

  boolean checkPlayerAgainstVehicleInArea() { // called from player location

    boolean playerWasTouched = false;

    int vNum = 0;

    for (int i = 0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      for (VehicleSphere vs : v.spheres) {

        if (vs.wasTouched) {

          playerWasTouched = true;
          vNum = i;

          vs.wasTouched = false;

          if (player.location.getState() == player.location.pLocBreathingState) { // in player area

            //data.vehicleTouchedPlayer = true;
            
            if (isTrackingData) {
              data.trackVehicleTouchedPlayer(true);
            }

            playerWasTouched = true;

            killVehicle(vNum);
            break;
          }
        }
      }
    }

    return playerWasTouched;
  }

  //--------------------------------------------------------------

  void switchVehicleFromBreathingToMoving(Vehicle v) {

    v.location.setState(v.location.vInMovingState);
    v.zone.setState(v.zone.inMotionNoZoneState);

    // // vehicle is breathing zone / no motion
    v.inMotion = true;
    v.zone.isBreathing = true;
    bg.units[v.unitNum].containsVehicle = false;
    v.playerInDistanceZone = false;
    v.playerInBreathingZone = false;

    v.centerBoid.status = "flee";
  }

  //--------------------------------------------------------------


  void killVehicle(int vNum) {

    Vehicle v = vehicles.get(vNum);

    v.killBlob();
    vehicles.remove(vNum);
  }
}
