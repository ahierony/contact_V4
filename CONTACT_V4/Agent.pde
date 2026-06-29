class Agent {
  float air; // determines lung capacity
  float health = 100; // reduces on reproduction
  float maxHealth = 100;
  PVector position;
  PVector velocity;
  float maxAir = 100;
  float xoff, yoff;
  float maxSpeed = 5;
  int reproductionCooldown = 0; // frames before agent can reproduce again
  boolean hasGivenBirth = false;
  Environment birthEnvironment = null;
  boolean triedReproduction = false;
  boolean bursted = false;
  int burstSeekSuppression = 0; // frames where agent ignore seeking force urge post-birth
  boolean driftingOut = false; // true when healthy agent leaves dying env
  Environment driftingFrom = null;
  int kickTimer = 0;
  PVector kickDir = new PVector(0, 0); // normalized direction of current jump
  float kickDecay = 0;
  int tadpoleSuppression = 0; // frames when kicking for jump is off
  Environment trackedEnv = null; // locked in env to seek

  // ANDREW START
  Vehicle v;
  float lungSize;
  // ANDREW ENDS

  // ANDREW START

  // ANDREW ENDS


  //--------------------------------------------------------------

  // ANDREW START
  Agent(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex) {

    position = new PVector(x, y);
    xoff = random(1000);
    yoff = random(1000);
    velocity = PVector.random2D();
    air = maxAir;

    v = new Vehicle(x, y, _colorAngle, _inMotion, type_, unitNum_, p, vIndex, this);
    ellipseMode(RADIUS);
  }

  //--------------------------------------------------------------

  void run(ArrayList<Agent> agents, ArrayList<Environment> environments) {

    v.run(agents, environments);

    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);
    position.set(vehiclePos.x, vehiclePos.y);

    lungSize = map(air, 0, maxAir, 4, 60); // shrinks as air disappears
  }
  // ANDREW ENDS

  //--------------------------------------------------------------

  boolean dead() {
    return air <= 0 || health <= 0;
  }

  //--------------------------------------------------------------

  // count down all timer flags each frame
  void tickCooldowns() {
    if (reproductionCooldown > 0) reproductionCooldown--;
    if (burstSeekSuppression > 0) burstSeekSuppression--;
    if (tadpoleSuppression > 0) tadpoleSuppression--;
  }

  //--------------------------------------------------------------

  // checks if the agent is currently inside an environment zone
  boolean checkInsideEnv(ArrayList<Environment> environments) {
    for (Environment e : environments) {
      if (e.contains(position)) {
        return true;
      }
    }
    return false;
  }

  //--------------------------------------------------------------

  // handles agent movement: frog-like kicks when normal, temporary wandering post-birth
  void applyMovement() {
    if (tadpoleSuppression == 0) {
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
          agentSound.play(1);
        }
      }

      // gradual thrust for jump with exponentual decay
      // frame 1 big push, frame 2 smaller, frame 3 smaller, trails to zero
      if (kickDecay > 0) {
        float thisFrame = min(kickDecay, kickDecay * 0.18); // 18% of remaining thrust each turn
        velocity.add(PVector.mult(kickDir, thisFrame));
        kickDecay -= thisFrame;
        if (kickDecay < 0.5) kickDecay = 0;
      }
    } else {
      // kick is ignored post-birth during the env burst
      // Perlin noise for smooth wandering
      float wx = map(noise(xoff), 0, 1, -0.4, 0.4);
      float wy = map(noise(yoff), 0, 1, -0.4, 0.4);
      xoff += 0.01;
      yoff += 0.01;
      velocity.add(new PVector(wx, wy));
    }
  }

  //--------------------------------------------------------------

  // steers agent towards nearest environment when air drops below 70%
  void applySeekForce(ArrayList<Environment> environments, float sensingRadius, boolean insideAnyEnv) {
    if (air >= maxAir * 0.7 || burstSeekSuppression > 0 || driftingOut) {
      return;
    }
    Environment nearest = nearestInRange(environments, sensingRadius);
    if (nearest == null) {
      return;
    }
    PVector toEnv = PVector.sub(nearest.position, position);
    float distToEnv = toEnv.mag();
    float nearestHealth = nearest.energy / nearest.maxEnergy;

    if (distToEnv < nearest.radius * 0.7) {
      // to avoid getting stuck at the core
      // agent can get stuck at the centre because seek force is the weakest there
      // if it is barely moving, we give it a small push away from the core
      if (reproductionCooldown > 0 && velocity.mag() < 0.5) {
        PVector nudge = PVector.sub(position, nearest.position);
        if (nudge.mag() < 10) nudge = PVector.random2D(); // to close to the centre pick random direction
        nudge.setMag(1.2);
        velocity.add(nudge);
      }
      // healthy agent in a dying environment drifts to search for healthier env
      float agentHealthRatio = health / maxHealth;
      if (agentHealthRatio > 0.6 && nearestHealth < 0.4) {
        driftingOut = true;
        driftingFrom = nearest;
      }
      // slow down an aim for the boundary during seeking
    } else if (distToEnv < nearest.radius * 1.1) {
      toEnv.setMag(nearest.radius * 0.9); // just inside edge
      PVector target = PVector.add(position, toEnv);
      PVector seekForce = PVector.sub(target, position);
      float urgency = map(air, 0, maxAir * 0.5, 1.5, 0.0); // more desperate for air, stronger pull
      float proximity = map(distToEnv, nearest.radius * 0.7, nearest.radius * 1.1, 0.3, 1.0); // weaker seek force if inside the env already
      float seekMag = insideAnyEnv ? 2.5 : 7.0;
      seekForce.setMag(seekMag * proximity);
      seekForce.mult(urgency);
      velocity.add(seekForce);
    } else {
      // if far away full seek force towards env
      toEnv.setMag(nearest.radius * 0.9);
      PVector target = PVector.add(position, toEnv);
      PVector seekForce = PVector.sub(target, position);
      float urgency = map(air, 0, maxAir * 0.5, 1.5, 0.0);
      float seekMag = insideAnyEnv ? 2.5 : 7.0;
      seekForce.setMag(seekMag);
      seekForce.mult(urgency);
      velocity.add(seekForce);
    }
  }

  //--------------------------------------------------------------
  // if agent decided to leave a dying env, push it away until it is far enough to stop
  void applyDriftForce(float sensingRadius) {
    if (!driftingOut || driftingFrom == null) {
      return;
    }
    float distFromDead = PVector.dist(position, driftingFrom.position);
    if (distFromDead > sensingRadius * 1.5) { // 1.5* radius for clean margin
      driftingOut = false;
      driftingFrom = null;
      return;
    }
    // push away from the dying env, force fades out as env recovers past 40% health
    PVector driftOut = PVector.sub(position, driftingFrom.position); // vector pointing away from env
    driftOut.normalize();
    float driftStrength = map(driftingFrom.energy / driftingFrom.maxEnergy, 0, 0.4, 2.5, 0.0); // stops pushing at 40% health
    driftOut.setMag(driftStrength);
    velocity.add(driftOut);
  }

  //--------------------------------------------------------------

  // when birth happens all agents get pushed outside the env with a burst
  void applyBirthBurst(ArrayList<Environment> environments) {
    for (Environment e : environments) {
      float distFromCenter = PVector.dist(position, e.position);
      if (e.birthBurst && !bursted && distFromCenter < e.radius) {
        // push agent away from the env centre, stronger the closer it is
        PVector repel = PVector.sub(position, e.position);
        repel.normalize();
        float kickStrength = map(distFromCenter, 0, e.radius, 200, 150);
        repel.setMag(kickStrength);
        velocity.add(repel);
        bursted = true;
        burstSeekSuppression = 480; // stop seeking for a while after being blasted
        tadpoleSuppression = 60; // brief wander after birth to avoid sudden conflicts of pull and push
        kickDecay = 0;
      }
      if (!e.birthBurst) bursted = false;
    }
  }

  //--------------------------------------------------------------

  // limits and dampens velocity: slower inside environemnts like moving through liquid, more viscous
  void applyDamping(boolean insideAnyEnv) {
    velocity.limit(maxSpeed * 3.5);
    velocity.mult(insideAnyEnv ? 0.55 : 0.72);
  }

  //--------------------------------------------------------------

  // pushes agent away from nearby agents to avoid flocking
  void applyPhysics(ArrayList<Agent> agents, float sepDist, float sepForce, boolean insideAnyEnv) {
    applyDamping(insideAnyEnv);
    PVector sep = seperate(agents, sepDist, sepForce);
    velocity.add(sep);
    //position.add(velocity);
    v.centerBoid.applyImpulseAnu(velocity);
  }

  //--------------------------------------------------------------

  // resets reproduction flag once agent leaves the core
  // clears birth tracking once agent has left the environment
  void updateReproductionFlags(ArrayList<Environment> environments) {
    boolean inAnyCore = false;
    for (Environment e : environments) {
      if (e.containsCore(position)) inAnyCore = true;
    }
    if (!inAnyCore) triedReproduction = false;

    // clear birth tracking once agent has left the environment
    if (hasGivenBirth && birthEnvironment != null && !birthEnvironment.contains(position)) {
      hasGivenBirth = false;
      birthEnvironment = null;
    }
  }

  //--------------------------------------------------------------

  // wraps agent to opposite side when it goes off the canvas edge
  void wrapEdges() {
    if (position.x > width/2)  position.x = -width/2;
    if (position.x < -width/2) position.x = width/2;
    if (position.y > height/2)  position.y = -height/2;
    if (position.y < -height/2) position.y = height/2;
  }

  //--------------------------------------------------------------

  void update(SimConfig config, ArrayList<Agent> agents, ArrayList<Environment> environments) {
    tickCooldowns();
    boolean insideAnyEnv = checkInsideEnv(environments);
    applyMovement();
    applySeekForce(environments, config.sensingRadius, insideAnyEnv);
    applyDriftForce(config.sensingRadius);
    applyBirthBurst(environments);
    applyPhysics(agents, config.sepDist, config.sepForce, insideAnyEnv);
    wrapEdges();
    air -= config.drainRate;
    if (air <= 0) println("agent dead");
    updateReproductionFlags(environments);
  }

  //--------------------------------------------------------------

  // push agents away from neighbors with desiredSeparation distance
  PVector seperate(ArrayList<Agent> agents, float desiredSeparation, float maxSepForce) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Agent other : agents) {
      float d = PVector.dist(position, other.position);
      if (other != this && d < desiredSeparation) {
        PVector diff = PVector.sub(position, other.position);
        float overlap = desiredSeparation - d;
        diff.normalize();
        diff.mult(overlap / desiredSeparation);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.limit(0.8);
    }
    return sum;
  }

  //--------------------------------------------------------------

  Environment nearestInRange(ArrayList<Environment> environments, float sensingRadius) {
    if (trackedEnv != null) {
      float d = PVector.dist(position, trackedEnv.position);
      if (d > sensingRadius * 1.12) trackedEnv = null; // agent must travel further out before switching from seeking force
    }
    if (trackedEnv == null) {
      for (Environment e : environments) {
        float d = PVector.dist(position, e.position);
        if (d < sensingRadius * 0.95) {
          if (trackedEnv == null || e.energy > trackedEnv.energy) { // prefer healthier env
            trackedEnv = e;
          }
        }
      }
    }
    return trackedEnv;
  }

  //--------------------------------------------------------------
  /*
  // Parent pays 20 to reproduce
   // child spawns nearby with health scaled to env it was born in
   // born in poor environment results in starting with bad health
   Agent reproduce(Environment e) {
   health -= 20;
   health = max(health, 0);
   float offsetX = random(-30, 30);
   float offsetY = random(-30, 30);
   Agent child = new Agent(position.x + offsetX, position.y + offsetY);
   float envHealth = e.energy / e.maxEnergy;
   child.air = map(envHealth, 0, 1, 20, 100);
   child.reproductionCooldown = 300;
   child.health = health;
   child.tadpoleSuppression = 360;
   return child;
   }
   */

  //--------------------------------------------------------------

  // agents wrap at canvas edges, so we draw a ghost copy on the opposite side
  void draw() {
    drawAt(position.x, position.y);
    float ghostX = position.x;
    float ghostY = position.y;
    if (position.x > width/2 - 60)  ghostX = position.x - width;
    if (position.x < -width/2 + 60) ghostX = position.x + width;
    if (position.y > height/2 - 60)  ghostY = position.y - height;
    if (position.y < -height/2 + 60) ghostY = position.y + height;
    if (ghostX != position.x || ghostY != position.y) {
      drawAt(ghostX, ghostY);
    }
  }

  //--------------------------------------------------------------

  // COLORS
  // Outer membrane: Hue shifts from green to orange as health deteriorates
  // Inner lung: hue shifts from blue to red, empty red, blue full
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
}
