class Agent {

  Vehicle v;

  float air; // determines lung capacity
  float lungSize;
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

  //


  Agent(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex) {

    position = new PVector(x, y);
    xoff = random(1000);
    yoff = random(1000);
    velocity = PVector.random2D();
    air = maxAir;

    v = new Vehicle(x, y, _colorAngle, _inMotion, type_, unitNum_, p, vIndex, this);
    ellipseMode(RADIUS);
  }

  void run(ArrayList<Agent> agents, ArrayList<Environment> environments) {

    v.run(agents, environments);
  }


  //--------------------------------------------------------------

  void update(float drainRate, ArrayList<Agent> agents, ArrayList<Environment> environments, float sepDist, float sepForce, float sensingRadius) {

    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);
    position.set(vehiclePos.x, vehiclePos.y);

    lungSize = map(air, 0, maxAir, 4, 60); // shrinks as air disappears


    if (reproductionCooldown > 0) reproductionCooldown--;
    if (burstSeekSuppression > 0) burstSeekSuppression--;
    if (tadpoleSuppression > 0) tadpoleSuppression--;


    boolean insideAnyEnv = false;
    for (Environment e : environments) {
      if (e.v.membrane.contains(position)) insideAnyEnv = true;
    }


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

    // once drifting agent is far enough from the dying env, stop drifting
    if (driftingOut && driftingFrom != null) {
      float distFromDead = PVector.dist(position, driftingFrom.v.membrane.position);
      if (distFromDead > sensingRadius * 1.5) { // 1.5* radius for clean margin
        driftingOut = false;
        driftingFrom = null;
      }
    }

    for (Environment e : environments) {

      if (e.v.membrane.containsSensing(position, sensingRadius)) {
        println("inside");
      } else {
        println("outisde");
      }
    }

    // only seek an environment when air is below 70%
    //if (air < maxAir * 0.9) { // 0.7

    //if (air < maxAir * 0.7 && burstSeekSuppression == 0 && !driftingOut) {
    Environment nearest = nearestInRange(environments, sensingRadius);
    if (nearest != null) {
      //println("inside an enviroment");
      PVector toEnv = PVector.sub(nearest.v.membrane.position, position);
      float distToEnv = toEnv.mag();
      float nearestHealth = nearest.v.membrane.energy / nearest.v.membrane.maxEnergy;

      if (distToEnv < nearest.v.membrane.radius * 0.7) {
        // to avoid getting stuck at the core
        if (reproductionCooldown > 0 && velocity.mag() < 0.5) {
          PVector nudge = PVector.sub(position, nearest.v.pos);
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
      } else if (distToEnv < nearest.v.membrane.radius * 1.1) {
        toEnv.setMag(nearest.v.membrane.radius * 0.9); // just inside edge
        PVector target = PVector.add(position, toEnv);
        PVector seekForce = PVector.sub(target, position);
        float urgency = map(air, 0, maxAir * 0.5, 1.5, 0.0); // more desperate for air, stronger pull
        float proximity = map(distToEnv, nearest.v.membrane.radius * 0.7, nearest.v.membrane.radius * 1.1, 0.3, 1.0); // weaker seek force if inside the env already
        float seekMag = insideAnyEnv ? 2.5 : 7.0;
        seekForce.setMag(seekMag * proximity);
        seekForce.mult(urgency);
        velocity.add(seekForce);
      } else {
        toEnv.setMag(nearest.v.membrane.radius * 0.9);
        PVector target = PVector.add(position, toEnv);
        PVector seekForce = PVector.sub(target, position);
        float urgency = map(air, 0, maxAir * 0.5, 1.5, 0.0);
        float seekMag = insideAnyEnv ? 2.5 : 7.0;
        seekForce.setMag(seekMag);
        seekForce.mult(urgency);
        velocity.add(seekForce);
      }
    }
    //println("outside an enviroment");
    //}



    // push agent away from dying env if it decided to leave
    if (driftingOut && driftingFrom != null) {
      PVector driftOut = PVector.sub(position, driftingFrom.v.membrane.position); // vector pointing away from env
      driftOut.normalize();
      float driftStrength = map(driftingFrom.v.membrane.energy / driftingFrom.v.membrane.maxEnergy, 0, 0.4, 2.5, 0.0); // stops pushing at 40% health
      driftOut.setMag(driftStrength);
      velocity.add(driftOut);
    }
    // when birth happens all agents get pushed outside the env with a burst
    for (Environment e : environments) {
      float distFromCenter = PVector.dist(position, e.v.membrane.position);
      if (e.v.membrane.birthBurst && !bursted && distFromCenter < e.v.membrane.radius) {
        PVector repel = PVector.sub(position, e.v.membrane.position);
        repel.normalize();
        float kickStrength = map(distFromCenter, 0, e.v.membrane.radius, 200, 150);
        repel.setMag(kickStrength);
        velocity.add(repel);
        bursted = true;
        burstSeekSuppression = 480;
        tadpoleSuppression = 60; // brief wander after birth to avoid sudden conflicts of pull and push
        kickDecay = 0;
      }
      if (!e.v.membrane.birthBurst) bursted = false;
    }

    // inside environments agents move slower, more viscous
    velocity.limit(maxSpeed * 3.5);
    velocity.mult(insideAnyEnv ? 0.55 : 0.72);

    PVector sep = seperate(agents, sepDist, sepForce);
    velocity.add(sep);

    //position.add(velocity);

    v.centerBoid.applyImpulseAnu(velocity);

    air -= drainRate;
    //if (air <= 0) v.lung.setState(v.lung.emptyState);
    //if (air <= 0) println("agent dead");



    /*
    // reset reproduction attempt flag once agent leaves core
     boolean inAnyCore = false;
     for (Environment e : environments) {
     if (e.v.membrane.containsCore(position)) inAnyCore = true;
     }
     if (!inAnyCore) triedReproduction = false;
     
     // clear birth tracking once agent has left the environment
     if (hasGivenBirth && birthEnvironment != null && !birthEnvironment.v.membrane.contains(position)) {
     hasGivenBirth = false;
     birthEnvironment = null;
     }
     */
  } // update


  //--------------------------------------------------------------

  boolean dead() {

    return air <= 0 || health <= 0;
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
    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);
    position.set(vehiclePos.x, vehiclePos.y);

    if (trackedEnv != null) {

      println("position.x ", position.x);
      println("trackedEnv.v.pos ", trackedEnv.v.pos);

      float d = PVector.dist(position, trackedEnv.v.pos);
      if (d > sensingRadius * 1.12) trackedEnv = null; // agent must travel further out before switching from seeking force
    }
    if (trackedEnv == null) {
      for (Environment e : environments) {
        Vec2 envoPos = box2d.getBodyPixelCoord(e.v.centerBoid.body);
        PVector envoPPos = new PVector(envoPos.x, envoPos.y);
        float d = PVector.dist(position, envoPPos);
        println("d ", d);
        println("sensingRadius ", sensingRadius);
        if (d < sensingRadius * 0.95) {
          if (trackedEnv == null || e.v.membrane.energy > trackedEnv.v.membrane.energy) { // prefer healthier env
            trackedEnv = e;
          }
        }
      }
    }
    return trackedEnv;
  }

  //--------------------------------------------------------------

  // Parent pays 20 to reproduce
  // child spawns nearby with health scaled to env it was born in
  // born in poor environment results in starting with bad health
  /*
  Agent reproduce(Environment e) {
   health -= 20;
   health = max(health, 0);
   float offsetX = random(-30, 30);
   float offsetY = random(-30, 30);
   Agent child = new Agent(position.x + offsetX, position.y + offsetY);
   float envHealth = e.v.membrane.energy / e.v.membrane.maxEnergy;
   child.air = map(envHealth, 0, 1, 20, 100);
   child.reproductionCooldown = 300;
   child.health = health;
   child.tadpoleSuppression = 360;
   return child;
   }
   */

  //--------------------------------------------------------------

  // agents wrap at canvas edges, so we draw a ghost copy on the opposite side
  /*
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
   */

  //--------------------------------------------------------------

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
   
   
   float lungHue = map(air, 0, maxAir, 355, 210);
   float lungSat = map(air, 0, maxAir, 72, 72);
   float lungBri = map(air, 0, maxAir, 88, 70);
   noStroke();
   fill(lungHue, lungSat, lungBri);
   circle(x, y, lungSize);
   
   colorMode(RGB, 255);
   }
   */



  //--------------------------------------------------------------
}
