class Environment {

  PVector position;
  float radius;
  boolean coreOccupied; // true while a parent is reproducing
  float energy = 5000;
  float maxEnergy = 5000;
  float noiseT = 0;
  float noiseOffset;
  boolean birthBurst = false;
  int burstTimer = 0;

  PApplet parentApp;

  Vehicle v;

  int stages;
  int currentStage;
  int stagePlaying;

  int index;

  // sound
  SoundFile[] baseSounds;
  SoundFile[] muffledSounds;
  //SoundFile currentSound;

  int environmentHue;

  //--------------------------------------------------------------

  Environment(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex, PApplet app) {

    parentApp = app;
    
    environmentHue = _colorAngle;

    position = new PVector(x, y);
    //radius = r;
    noiseOffset = random(1000);

    if (fullScale) {
      radius = unit_w * 0.3; //unit_w * 0.35;
    } else {
      radius = unit_w * 0.7;
    }

    index = vIndex; //vIndex + 1;

    v = new Vehicle(x, y, _colorAngle, _inMotion, type_, unitNum_, p, this);

    currentStage = 1;
    stages = 5;

    if (playSoundContactV4) {

      setupSounds(app);
    }
  }

  //--------------------------------------------------------------

  void run(ArrayList<Agent> agents, ArrayList<Environment> environments) {

    v.run(agents, environments);

    currentStage = getStageNum();
    //stagePlaying = currentStage;

    if (playSoundContactV4) {

      updateSounds();
    }
  }

  //--------------------------------------------------------------

  void setupSounds(PApplet app) {

    baseSounds = new SoundFile[stages];

    baseSounds[0] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "A.mp3");
    baseSounds[1] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "B.mp3");
    baseSounds[2] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "C.mp3");
    baseSounds[3] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "D.mp3");
    baseSounds[4] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "E.mp3");

    muffledSounds = new SoundFile[stages];

    muffledSounds[0] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "A.mp3");
    muffledSounds[1] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "B.mp3");
    muffledSounds[2] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "C.mp3");
    muffledSounds[3] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "D.mp3");
    muffledSounds[4] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "E.mp3");

    //currentSound = baseSounds[stagePlaying];
    baseSounds[stagePlaying].pause();
  }

  //--------------------------------------------------------------

  void updateSounds() {


    if (v.playerInDistanceZone) { // update stage sound

      if (stagePlaying != currentStage) {
        baseSounds[stagePlaying].pause();
        stagePlaying = currentStage;
      }
      //currentSound = baseSounds[stagePlaying];

      if (v.playerInBreathingZone) {  // update stage sound

        if (stagePlaying != currentStage) {
          muffledSounds[stagePlaying].pause();
          stagePlaying = currentStage;
        }

        float d;

        if (baseSounds[stagePlaying].isPlaying()) { // turn off

          baseSounds[stagePlaying].pause();
          d = baseSounds[stagePlaying].position();
        } else {

          d = 0;
        }

        if (!muffledSounds[stagePlaying].isPlaying()) { //turn on

          //println("play environment sound");

          muffledSounds[stagePlaying].amp(0.5);
          muffledSounds[stagePlaying].cue(d);
          muffledSounds[stagePlaying].play();
          muffledSounds[stagePlaying].loop();
        }
      } else { // not in breathing zone

        float dm;

        if (muffledSounds[stagePlaying].isPlaying()) { // turn off

          muffledSounds[stagePlaying].pause();
          dm = muffledSounds[stagePlaying].position();
        } else { // muffled sound wasn't playing
          dm = 0;
          /*
          if (!baseSounds[stagePlaying].isPlaying()) {
           
           
           Env env1;
           env1 = new Env(parentApp);
           env1.play(baseSounds[stagePlaying], 0, 0, .2, 5);
           }
           */
        }


        if (!baseSounds[stagePlaying].isPlaying()) { // turn on

          //println("play environment sound");

          baseSounds[stagePlaying].amp(0.5);
          baseSounds[stagePlaying].cue(dm);
          baseSounds[stagePlaying].play();
          baseSounds[stagePlaying].loop();
        }
      }
    } else { // not in distance zone

      if (stagePlaying != currentStage) {
        baseSounds[stagePlaying].pause();
        stagePlaying = currentStage;
      }

      if (baseSounds[stagePlaying].isPlaying()) { // turn off

        baseSounds[stagePlaying].pause();
      }

      //println("stop environment sound");
    }
  }

  //--------------------------------------------------------------

  boolean contains(PVector agentPos) { // full zone where air refill happen
    return PVector.dist(position, agentPos) < radius;
  }
  boolean containsCore(PVector agentPos) { // inner zone for birth
    return PVector.dist(position, agentPos) < 50; // radius matches core visual size
  }

  boolean containsSensing(PVector agentPos, float sensingRadius) { // outer sensing ring
    return PVector.dist(position, agentPos) < sensingRadius;
  }


  //--------------------------------------------------------------
  /*
  // counts down the birth burst timer and turns off the burst when it expires
   void tickBurstTimer() {
   if (burstTimer > 0) {
   burstTimer--;
   } else {
   birthBurst = false;
   }
   }
   
   //--------------------------------------------------------------
   
   // adds regen energy each frame up to the max
   void regenerateEnergy(float regenRate) {
   energy = min(energy + regenRate, maxEnergy);
   }
   
   //--------------------------------------------------------------
   
   // checks if the reproducing parent is still inside, keeps core locked until they leave
   void checkCoreOccupied(ArrayList<Agent> agents) {
   boolean parentStillInside = false;
   for (Agent a : agents) {
   if (a.hasGivenBirth && contains(a.position)) {
   parentStillInside = true;
   break;
   }
   }
   if (!parentStillInside) coreOccupied = false;
   }*/

  //--------------------------------------------------------------

  String getStageName() {
    float h = energy / maxEnergy;
    if (h > 0.8) return "0";
    else if (h > 0.6) return "1";
    else if (h > 0.4) return "2";
    else if (h > 0.2) return "3";
    else return "4";
  }

  //

  //--------------------------------------------------------------

  int getStageNum() {
    float h = energy / maxEnergy;
    if (h > 0.8) return 0;
    else if (h > 0.6) return 1;
    else if (h > 0.4) return 2;
    else if (h > 0.2) return 3;
    else return 4;
  }

  //--------------------------------------------------------------
  /*
  void updatedCore(ArrayList<Agent> agents, float regenRate) {
   tickBurstTimer();
   regenerateEnergy(regenRate);
   // coreOccupied stays true as long as the reproducing parent is still inside
   // once parent leaves, slot opens for next reproduction
   checkCoreOccupied(agents);
   }
   
   //--------------------------------------------------------------
  /*
   void triggerBirthBurst() {
   birthBurst = true;
   burstTimer = 120;
   }
   */
  //--------------------------------------------------------------

  // 5 different stages for environements
  float[] getStageValues(float healthRatio) {
    // {nAmp, nInt, displayRadiusMultiplier, resolution, stageSpeed}
    float[] s1, s2;
    float t;
    // stage 1
    if (healthRatio > 0.8) {
      return new float[]{
        0.01, 1.5, 1.0, 80, 0.01};
    } else if (healthRatio > 0.6) { // stage 2
      s1 = new float[]{0.05, 2.5, 1.0, 100, 0.015};
      s2 = new float[]{0.01, 1.5, 1.0, 80, 0.01};
      t = (healthRatio - 0.6) / 0.2;
    } else if (healthRatio > 0.4) { // stage 3
      s1 = new float[]{0.12, 3.5, 1.0, 120, 0.02};
      s2 = new float[]{0.05, 2.5, 1.0, 100, 0.015};
      t = (healthRatio - 0.4) / 0.2;
    } else if (healthRatio > 0.2) { // stage 4
      s1 = new float[]{0.25, 5.0, 0.99, 160, 0.03};
      s2 = new float[]{0.12, 3.5, 1.0, 120, 0.02};
      t = (healthRatio - 0.2) / 0.2;
    } else { // stage 5
      s1 = new float[]{0.45, 7.0, 0.99, 200, 0.05};
      s2 = new float[]{0.25, 5.0, 0.99, 160, 0.03};
      t = healthRatio / 0.2;
    }

    return new float[]{
      lerp(s1[0], s2[0], t),
      lerp(s1[1], s2[1], t),
      lerp(s1[2], s2[2], t),
      lerp(s1[3], s2[3], t),
      lerp(s1[4], s2[4], t)
    };
  }

  //--------------------------------------------------------------

  float[] getMembraneColor(float healthRatio) {
    float decay = 1.0 - pow(healthRatio, 3.0);
    float sat = map(decay, 0, 1, 80, 60); // vivid when healthy, slight washed out when dying
    float bri = 85;
    return new float[]{environmentHue, sat, bri};
  }

  //--------------------------------------------------------------
  /*
  // draws the solid circle at the centre when reproduction happens
   void drawCore(float healthRatio) {
   float[] col = getMembraneColor(healthRatio);
   float hue = col[0];
   float sat = col[1];
   float bri = col[2];
   colorMode(HSB, 360, 100, 100);
   noStroke();
   fill(hue, sat + 15, max(bri + 10, 35));
   colorMode(RGB, 255);
   circle(position.x, position.y, 100); // same size as agent
   }
   */
  //--------------------------------------------------------------

  // draws the outer ring showing how far agents can detect this environment
  void drawSensingRing(float sensingRadius) {
    strokeWeight(3);
    colorMode(RGB, 255);
    noFill();
    //stroke(150, 180);
    stroke(0);
    circle(position.x, position.y, sensingRadius);
    strokeWeight(1);
  }

  //--------------------------------------------------------------
  /*
  // Environemnt is teal when healthy and purple when depleted
   void draw(float sensingRadius) {
   drawSensingRing(sensingRadius);
   float healthRatio = energy / maxEnergy;
   drawMembrane(healthRatio);
   drawCore(healthRatio);
   }
   */

  //--------------------------------------------------------------

  // ANDREW

  void updatePosition(float x, float y) {

    position.set(x, y);
  }

  //--------------------------------------------------------------

  // Environemnt is teal when healthy and purple when depleted
  void display(float sensingRadius) {
    if (displaySensingRadii) drawSensingRing(sensingRadius);

    float healthRatio = energy / maxEnergy;
    drawMembrane(healthRatio);
    //drawCore(healthRatio);
  }

  //--------------------------------------------------------------

  // draws the wobbly noisy membrane using current stage values
  void drawMembrane(float healthRatio) {
    float[] sv = getStageValues(healthRatio);
    float nAmp = sv[0]; // how far the membrane distorts outward/inward
    float nInt = sv[1]; // how many spikes around the ring
    float displayRadius = radius * sv[2]; // slightly smaller when dying
    float resolution = sv[3]; // how many points draw the shape
    float stageSpeed = sv[4]; // how fast the membrane animates

    float[] col = getMembraneColor(healthRatio);
    float hue = col[0];
    float sat = col[1];
    float bri = col[2];

    colorMode(HSB, 360, 100, 100);
    strokeWeight(1.2);
    stroke(hue, sat + 8, bri - 12);
    fill(hue, sat, bri, 150);
    beginShape();
    for (float a = 0; a <= TWO_PI; a += TWO_PI / resolution) {
      float nVal = 1.0 + map(noise(cos(a) * nInt + noiseOffset, sin(a) * nInt + noiseOffset + 500, noiseT), 0.0, 1.0, -nAmp, nAmp);
      float x = position.x + cos(a) * displayRadius * nVal;
      float y = position.y + sin(a) * displayRadius * nVal;
      vertex(x, y);
    }
    endShape(CLOSE);
    noiseT += stageSpeed;
  }

  //--------------------------------------------------------------

  void alterEnergy() {

    energy -= 5; //0.5;
    energy = max(energy, 0);
  }


  void alterEnergyAfterGivingBirth() {

    if (random(1) < (energy / maxEnergy)) {
      //coreOccupied = true;
      energy -= 50;
      energy = max(energy, 0);
      //a.hasGivenBirth = true;
      //a.birthEnvironment = e;
      //Agent child = a.reproduce(e);
      //agents.add(child);
      //a.reproductionCooldown = 300;
      //e.triggerBirthBurst();
    }
  }

  void alterEnergyAfterTouchingPlayer(boolean playerContact) {

    float energyAmount = 5000;

    //println("energy before ", energy);

    if (playerContact) {
      //println("increase energy ");
      energyAmount *= 1;

      if (random(1) < (energy / maxEnergy)) {

        energy += energyAmount;
        energy = max(energy, 1);
      }
    } else {
      //println("decrease energy ");
      energyAmount *= -1;

      if (random(1) < (energy / maxEnergy)) {

        energy += energyAmount;
        energy = max(energy, 0);
      }
    }



    //println("energy after ", energy);
  }

  /*
  void display(float sensingRadius, color colorBreathing ) {
   strokeWeight(3);
   noFill();
   stroke(0, 97, 0);
   circle(position.x, position.y, sensingRadius * 2);
   float healthRatio = energy / maxEnergy;
   // membrane wobbles more as health drops
   float nAmp = map(healthRatio, 0, 1, 0.15, 0.0);
   float nInt = 3.5;
   float resolution = 80;
   
   float hue = map(healthRatio, 0, 1, 360, 240);
   //colorMode(HSB, 360, 100, 100);
   //strokeWeight(0.8);
   
   stroke(hue, 60, 75);
   //fill(hue, 50, 95, 60);
   fill(colorBreathing);
   beginShape();
   for (float a = 0; a <= TWO_PI; a += TWO_PI / resolution) {
   float nVal = 1.0 + map(noise(cos(a) * nInt + noiseOffset, sin(a) * nInt + noiseOffset, noiseT), 0.0, 1.0, -nAmp, nAmp);
   float x = position.x + cos(a) * radius * nVal;
   float y = position.y + sin(a) * radius * nVal;
   vertex(x, y);
   }
   endShape(CLOSE);
   noiseT += 0.02;
   */

  /*
    noStroke();
   fill(hue, 70, 80);
   colorMode(RGB, 255);
   circle(position.x, position.y, (radius/4) * 2);
   
   }*/
  //}
}
