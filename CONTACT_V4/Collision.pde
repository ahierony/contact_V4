class Collision {

  int agentsRemaining;

  int agentCount = 0;

  PApplet app;


  Collision(PApplet p) {

    app = p;

    agentsRemaining = agents.size();
  }

  //--------------------------------------------------------------



  //--------------------------------------------------------------
  boolean readyToGiveBirth = false;

  // VEHICLE AGAINST VEHICLE

  void checkVehicleAgainstVehicle() {

    for (int i = 0; i < agents.size(); i++) {

      Agent a = agents.get(i);

      for (int j = 0; j < environments.size(); j++) {

        Environment e = environments.get(j);

        //if (v != o) {

        //if (o.inMotion && !v.inMotion) {

        if (vehiclesAreTouching(e, a)) {

          if (!e.v.isColliding) {

            manageBirth(e, a);

            e.v.collided();

            e.v.isColliding = true;

            e.v.zone.setState(e.v.zone.collisionState);
            
            e.alterEnergyAfterGivingBirth();

            a.v.colorWheelAngle = selectRandomCol(e.v.colorWheelAngle);
          }


          /*
          if ( e.v.zone.getState() != e.v.zone.collisionState) {
           
           if (e.v.zone.collisionState.getReadyToSetState()) {
           
           manageBirth(e, a);
           
           e.v.collided();
           
           //println("collision!");
           
           //switchVehicleFromBreathingToMoving(v);
           e.v.zone.setState(e.v.zone.collisionState);
           }
           }
           */
        }
      }
    }
  }

  int selectRandomCol(int oppositeCol) {
    
    int currentCol = oppositeCol;
    int vehicleColorNum = currentCol;
    int[] possibleColors = {0, 45, 90, 135, 180, 225, 270, 315};
    int randomCol;

    while (currentCol == vehicleColorNum) {
      randomCol = int(random(possibleColors.length));
      vehicleColorNum = possibleColors[randomCol];
    }
    
    return vehicleColorNum;
  }


  void manageBirth(Environment envo, Agent agent) {

    giveVehicleBirth(envo, agent);

    Vec2 vehiclePosVecPixels = box2d.getBodyPixelCoord(envo.v.centerBoid.body);
    vehiclePosVecPixels.subLocal(envo.v.centerBoid.offset);
    Vec2 targetPosition = box2d.coordPixelsToWorld(vehiclePosVecPixels);

    //agent.v.centerBoid.status = "flee";
    //agent.v.centerBoid.flee(targetPosition);
  }

  //boolean vehiclesAreTouching(Vehicle vInMotion, Vehicle vBreathing) {
  boolean vehiclesAreTouching(Environment envo, Agent agent) {

    Vec2 envoPos = box2d.getBodyPixelCoord(envo.v.centerBoid.body);
    Vec2 agentPos = box2d.getBodyPixelCoord(agent.v.centerBoid.body);

    float d_pix = dist(envoPos.x, envoPos.y, agentPos.x, agentPos.y);

    if (d_pix < agent.v.blobRadius + envo.v.blobRadius) {

      return true;
    } else {

      return false;
    }
  }

  void giveVehicleBirth(Environment envo, Agent ag) {

    Vec2 envoPos = box2d.getBodyPixelCoord(envo.v.centerBoid.body);
    Vec2 agentPos = box2d.getBodyPixelCoord(ag.v.centerBoid.body);

    Vec2 velocity = envoPos.sub(agentPos);

    float len = velocity.length();
    len += 20; //50;
    velocity.normalize();
    velocity.mulLocal(len);

    Vec2 newVelocity = envoPos.add(velocity);
  
    int vehicleColorNum = selectRandomCol(envo.v.colorWheelAngle);

    /*
    int agentIndex;
     if (agents.size() == 0) {
     agentIndex = 1;
     } else {
     agentIndex = agents.size();
     }
     */
    int agentIndex = 1000 + agentCount;
    agentCount++;
    Agent agent = new Agent(newVelocity.x, newVelocity.y, vehicleColorNum, true, "DYNAMIC", 0, player, agentIndex);

    agents.add(agent);
  }

  //--------------------------------------------------------------


  // PLAYER AGAINST VEHICLES

  boolean checkPlayerAgainstVehicleInZone() { // called from player location

    boolean vehicleWasTouched = false;

    for (int i = 0; i < environments.size(); i++) {

      Environment e = environments.get(i);

      for (VehicleSphere vs : e.v.spheres) {

        if (vs.wasTouched) {

          vs.wasTouched = false;

          if (e.v.isReadyForCollision) {

            //println("player touched vehicle ");
            //println(player.location.getState());

            vehicleWasTouched = true;

            if (playSoundContactV4) {
              //p_touch_v_audio.play();
            }

            //killVehicle(vNum);
            e.v.collided();
            
            
            
            e.v.isReadyForCollision = false;
            
            //e.alterEnergyAfterTouchingPlayer(true);

            //vehicleRemaining--;

            //bgTrailBox.increaseStrokeWeight();

            //println("vehicles remaining ", vehicleRemaining);

            //println("player collided");

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
