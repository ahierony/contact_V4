class Agent {
  float air; // determines lung capacity
  float health = 100; // reduces on reproduction
  float maxHealth = 100;
  PVector position;
  PVector velocity;
  float maxAir = 100;
  float xoff, yoff;
  float maxSpeed = 5;
  //int reproductionCooldown = 0; // frames before agent can reproduce again
  boolean hasGivenBirth = false;
  Environment birthEnvironment = null;
  boolean triedReproduction = false;
  boolean bursted = false;

  int kickTimer = 0;
  PVector kickDir = new PVector(0, 0); // normalized direction of current jump
  float kickDecay = 0;
  //int tadpoleSuppression = 0; // frames when kicking for jump is off
  Environment trackedEnv = null; // locked in env to seek
  Environment avoidedEnv = null; // env the agent avoids until it refills elsewhere
  float noiseT = 0; //added for lung noise
  //float noiseOffset;


  Vehicle v; //ANDREW
  float lungSize; // ANDREW

  //static final int WANDER = 0, APPROACH = 1, LEAVE = 2;
  //int state = WANDER;
  int deathFade = 60; // fade-out countdown once agent is dead
  int agentHue;

  float lungH = 0, lungS = 0, lungB = 92; // starts as wander color
  float drainMultiplier = 1.0; // grows with each birth, parent burns air faster


  //--------------------------------------------------------------

  // ANDREW START
  Agent(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex, boolean vehicleStartState) {

    agentHue = _colorAngle;

    ellipseMode(RADIUS);
    //noiseOffset = random(1000);
    position = new PVector(x, y);
    //xoff = random(1000);
    //yoff = random(1000);
    velocity = PVector.random2D();
    air = maxAir;

    if (vehicleStartState) {
      agentState = AgentState.WANDER;
    } else {
      agentState = AgentState.LEAVE;
    }

    v = new Vehicle(x, y, _colorAngle, _inMotion, type_, unitNum_, p, vIndex, this, vehicleStartState);

    //ellipseMode(RADIUS);
  }

  //--------------------------------------------------------------

  void run(ArrayList<Agent> agents, ArrayList<Environment> environments) {

    v.run(agents, environments);

    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);
    position.set(vehiclePos.x, vehiclePos.y);

    lungSize = map(air, 0, maxAir, 15, 100); // shrinks as air disappears
  }
  // ANDREW ENDS

  //--------------------------------------------------------------

  boolean dead() {
    return air <= 0 || health <= 0;
  }

  //--------------------------------------------------------------

  // checks if the agent is currently inside an environment zone
  boolean checkInsideEnv(ArrayList<Environment> environments) {
    for (Environment e : environments) {
      if (e.contains(position)) {
      //if (e.containsSensing(position, config.sensingRadius)) {
        return true;
      }
    }
    return false;
  }

  //--------------------------------------------------------------

  // handles agent movement: frog-like kicks when normal, temporary wandering post-birth
  void applyMovement() {
    //if (tadpoleSuppression == 0) {
    kickTimer--;

    // schedule new jump every 50 to 100 frames
    if (kickTimer <= 0) {
      kickTimer = (int)random(50, 100);
      PVector forward = velocity.copy();
      if (forward.mag() < 0.1) forward = PVector.random2D();
      forward.normalize();
      forward.rotate(random(-0.5, 0.5));
      kickDir = PVector.mult(forward, 1.0);
      kickDecay = random(20, 60);

      //SOUND
      if (playSoundContactV4 && v.checkIfInPlayerArea(player.sensingMaxRadius)) {
        int randNum = int(random(5));

        SoundFile agentSound = agentSounds[randNum];
        agentSound.play();
        agentSound.amp(0.5);
      }
    }


    // gradual thrust for jump with exponentual decay
    // frame 1 big push, frame 2 smaller, frame 3 smaller, trails to zero
    if (kickDecay > 0) {
      float thisFrame = min(kickDecay, kickDecay * 0.18); // 18% of remaining thrust each turn
      velocity.add(PVector.mult(kickDir, thisFrame));
      kickDecay -= thisFrame;
      if (kickDecay < 0.5) kickDecay = 0;
      //ANDREW
      v.centerBoid.applyImpulseAnu(velocity);
    }
  }

  //--------------------------------------------------------------


  // scan for the best non-avoided env within sensing range, null if none
  Environment findBestEnv(ArrayList<Environment> environments, float sensingRadius) {
    float bestScore = -1;
    Environment best = null;
    for (Environment e : environments) {
      if (e == avoidedEnv) continue;
      float d = PVector.dist(position, e.position);
      //println("d ", d);
      //println("sensingRadius * 0.95 ", sensingRadius * 0.95);
      if (d < sensingRadius * 0.95) {
       // println("inside sensing radius");
        float score = (e.energy / e.maxEnergy) * (0.3 + 0.7 * colorMatch(agentHue, e.environmentHue));
        if (score > bestScore) {
          bestScore = score;
          best = e;
        }
      }
    }
    return best;
  }

  //--------------------------------------------------------------

  // three-agentState behavior: wander until env sensed in sensing radius, seek core and leave after visit
  void applyStateBehavior(ArrayList<Environment> environments, float sensingRadius, boolean insideAnyEnv) {
    if (agentState == AgentState.WANDER) {
      Environment best = findBestEnv(environments, sensingRadius);
      //println("best ", best);
      if (best != null) {
        trackedEnv = best;
        agentState = AgentState.APPROACH;
      }
    } else if (agentState == AgentState.APPROACH) {
      //println("trackedEnv ", trackedEnv);
      if (trackedEnv == null) {
        agentState = AgentState.WANDER;
        return;
      }
      // straight at the core
      PVector seekForce = PVector.sub(trackedEnv.position, position);
      float seekMag = insideAnyEnv ? 2.5 : 7.0;
      seekForce.setMag(seekMag);
      seekForce.mult(0.2 + 0.8 * colorMatch(agentHue, trackedEnv.environmentHue));
      velocity.add(seekForce);
      //Vec2 dir = new Vec2(trackedEnv.position.x, trackedEnv.position.y);
      //v.centerBoid.arrive(dir);
    } else if (agentState == AgentState.LEAVE) {

      if (avoidedEnv == null) {
        agentState = AgentState.WANDER;
        return;
      }

      // landed in another env's range while exiting, jump straight to approaching it
      Environment best = findBestEnv(environments, sensingRadius);
      if (best != null) {
        trackedEnv = best;
        agentState = AgentState.APPROACH;
        return;
      }

      float d = PVector.dist(position, avoidedEnv.position);
      if (d > sensingRadius * 1.5) {
        agentState = AgentState.WANDER;
        return;
      }
      PVector away = PVector.sub(position, avoidedEnv.position);
      if (away.mag() < 10) away = PVector.random2D();
      away.normalize();
      away.setMag(map(d, 0, sensingRadius * 1.5, 3.0, 0.3));
      velocity.add(away);
    }
  }

  //--------------------------------------------------------------

  // hard barrier: a wandering agent can never end a frame inside the avoided env's sensing ring
  void enforceAvoidBarrier(float sensingRadius) {
    if (agentState != AgentState.WANDER || avoidedEnv == null) return;
    float barrier = sensingRadius * 1.5; // keep-out zone extends past the sensing ring
    float d = PVector.dist(position, avoidedEnv.position);
    if (d < barrier) {
      PVector out = PVector.sub(position, avoidedEnv.position);
      if (out.mag() < 1) out = PVector.random2D();
      out.setMag(barrier); // place exactly on the barrier
      position = PVector.add(avoidedEnv.position, out);
      PVector toEnv = PVector.sub(avoidedEnv.position, position).normalize();
      float inward = velocity.dot(toEnv);
      if (inward > 0) velocity.sub(PVector.mult(toEnv, inward));
    }
  }

  //--------------------------------------------------------------

  // visit is over (birth attempted or turned away), we remember this env and exit the area
  void startLeaving(Environment e) {
    avoidedEnv = e;
    trackedEnv = null;
    agentState = AgentState.LEAVE;
  }

  //--------------------------------------------------------------

  // limits and dampens velocity: slower inside environemnts like moving through liquid, more viscous
  // what is this Anushcka?
  void applyDamping(boolean insideAnyEnv) {
    velocity.limit(maxSpeed * 3.5);
    velocity.mult(insideAnyEnv ? 0.55 : 0.72);
  }


  //--------------------------------------------------------------

  // pushes agent away from nearby agents to avoid flocking
  void applyPhysics(ArrayList<Agent> agents, float sepDist, float sepForce, boolean insideAnyEnv) {
    applyDamping(insideAnyEnv);
    //PVector sep = seperate(agents, sepDist, sepForce);
    //velocity.add(sep);
    //position.add(velocity);
    //v.centerBoid.applyImpulseAnu(velocity);
  }

  //--------------------------------------------------------------

  void update(SimConfig config, ArrayList<Agent> agents, ArrayList<Environment> environments) {
    //Vec2 pos;
    //pos = box2d.getBodyPixelCoord(v.centerBoid.body);
    //position.set(pos.x, pos.y);

    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);
    position.set(vehiclePos.x, vehiclePos.y);
    //tickCooldowns();
    boolean insideAnyEnv = checkInsideEnv(environments);
    applyMovement();
    applyStateBehavior(environments, config.sensingRadius, insideAnyEnv);
    //applyBirthBurst(environments); // LOOK INTO
    applyPhysics(agents, config.sepDist, config.sepForce, insideAnyEnv);
    //bounceEdges();
    //enforceAvoidBarrier(config.sensingRadius);
    air -= config.drainRate * drainMultiplier;
    if (air <= 0) println("agent dead");
    //updateReproductionFlags(environments); // LOOK INTO
    noiseT += 0.012;

    //println("state ", agentState);
  }

  //--------------------------------------------------------------

  void display() {
    /*
    Vec2 pos;
     pos = box2d.getBodyPixelCoord(v.centerBoid.body);
     
     drawAt(pos);
     */

    displayVehicle();
    displayLung();

    //updateColor();

    /*

     // DEBUG state ring: green = approaching, red = leaving, none = wandering
     
     if (agentState == AgentState.APPROACH) {
     noFill();
     stroke(120, 90, 90);
     strokeWeight(3);
     circle(pos.x, pos.y, 150);
     } else if (agentState == AgentState.LEAVE) {
     noFill();
     stroke(0, 90, 100);
     strokeWeight(3);
     circle(pos.x, pos.y, 150);
     }
     
    /*
     noFill();
     stroke(0, 90, 100);
     strokeWeight(5);
     circle(pos.x, pos.y, 150);
     */
  }

  // COLORS
  // Outer membrane: Hue shifts from green to orange as health deteriorates
  // Inner lung: hue shifts from blue to red, empty red, blue full
  /*
  void drawAt(float x, float y) {
   colorMode(HSB, 360, 100, 100);
   
   float memHue = map(health, 0, maxHealth, 25, 135); // orange at low health green at full
   float memSat = map(health, 0, maxHealth, 50, 75);
   float memBri = map(health, 0, maxHealth, 55, 90);
   strokeWeight(1.5);
   stroke(memHue, memSat + 8, memBri - 10);
   fill(memHue, memSat, memBri, 190);
   circle(x, y, 100);
   
   float lungSize = map(air, 0, maxAir, 4, 60); // shrinks as air disappears
   float lungHue = map(air, 0, maxAir, 355, 210);
   float lungSat = map(air, 0, maxAir, 72, 72);
   float lungBri = map(air, 0, maxAir, 88, 70);
   noStroke();
   fill(lungHue, lungSat, lungBri);
   circle(x, y, lungSize);
   
   colorMode(RGB, 255);
   }
   */

  // COLORS
  void displayVehicle() {

    // AGENT

    colorMode(HSB, 360, 100, 100);

    //float memSat = map(health, 0, maxHealth, 25, 75);
    //float memBri = map(health, 0, maxHealth, 45, 90);
    float memSat = 70;
    float memBri = 85;
    strokeWeight(1.5);
    float fade = dead() ? deathFade / 60.0 : 1;
    stroke(agentHue, memSat + 8, memBri - 10, 255 * fade);

    v.displayAgentBlob(agentHue, memSat, memBri, 190 * fade);
    //v.updateColorFromAgent(agentHue, memSat, memBri, 190 * fade);

    /*
    fill(agentHue, memSat, memBri, 190 * fade);
     circle(x, y, 100);
     */


    colorMode(RGB, 255);
  }

  void displayLung() {

    colorMode(HSB, 360, 100, 100);

    // LUNG

    float fade = dead() ? deathFade / 60.0 : 1;

    float lungHue, lungSat, lungBri;
    if (agentState == AgentState.APPROACH) {
      lungHue = 220;
      lungSat = 80;
      lungBri = 80; // blue: seeking a core
      //println("blue");
    } else if (agentState == AgentState.LEAVE) {
      lungHue = 6;
      lungSat = 65;
      lungBri = 85; // red: leaving
      //println("red");
    } else {
      lungHue = 130;
      lungSat = 60;
      lungBri = 70; // green: wandering
      //println("green");
    }

    //// target lung color for current state
    //float targetH, targetS, targetB;
    //if (state == APPROACH){
    //  targetH = 220; targetS = 75; targetB = 90; // blue: seeking a core
    //} else if (state == LEAVE){
    //  targetH = 0;   targetS = 80; targetB = 95; // red: leaving
    //} else {
    //  targetH = 130; targetS = 55; targetB = 80; // green: wandering
    //}

    //// ease displayed color toward target, 10% of the gap per frame
    //lungH = lerp(lungH, targetH, 0.1);
    //lungS = lerp(lungS, targetS, 0.1);
    //lungB = lerp(lungB, targetB, 0.1);


    float lungSize = constrain(map(air, 0, maxAir, 4, 80), 4, 80); // shrinks as air disappears


    v.lung.display(lungHue, lungSat, lungBri, 255 * fade, lungSize);

    /*
    noStroke();
     fill(lungHue, lungSat, lungBri, 255 * fade);
     circle(pos.x, pos.y, lungSize);
     endShape(CLOSE);
     */

    colorMode(RGB, 255);
  }
}
