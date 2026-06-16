class Collision {

  int vehicleRemaining;


  Collision() {

    vehicleRemaining = vehicles.size();
  }

  //--------------------------------------------------------------


 
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
                  
                  v.collided();
                  
                  println("collision!");
                  
                  //switchVehicleFromBreathingToMoving(v);
                  v.zone.setState(v.zone.collisionState);
                }
              }
            }
          } else if (!o.inMotion && v.inMotion) {

            if (vehiclesAreTouching(v, o)) {

              if ( o.zone.getState() != o.zone.collisionState) {

                if (o.zone.collisionState.getReadyToSetState()) {

                  manageBirth(v, o);
                  
                  o.collided();
                  
                  //switchVehicleFromBreathingToMoving(v);
                  o.zone.setState(o.zone.collisionState);
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
    
    int vehicleIndex = vehicles.size();
    Vehicle vehicle = new Vehicle(newVelocity.x, newVelocity.y, vehicleColorNum, true, "DYNAMIC", 0, player, vehicleIndex);

    vehicles.add(vehicle);
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

            //println("player touched vehicle ");
            //println(player.location.getState());

            vehicleWasTouched = true;

            if (playSoundContactV1) {
              p_touch_v_audio.play();
            }

            //killVehicle(vNum);
            v.collided();

            vehicleRemaining--;

            //bgTrailBox.increaseStrokeWeight();

            //println("vehicles remaining ", vehicleRemaining);
            
            println("player collided");

            //v.playerInDistanceZone = false;
            //player.location.setState(player.location.pLocMovingState);

            break;
          }
        }
      }
    }

    return vehicleWasTouched;
  }

  //--------------------------------------------------------------

}
