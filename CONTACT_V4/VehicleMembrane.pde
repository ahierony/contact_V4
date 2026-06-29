class VehicleMembrane {
  /*
  PVector position;
  float radius;
  boolean coreOccupied;
  float energy = 5000;
  float maxEnergy = 5000;
  float noiseT = 0;
  float noiseOffset;
  boolean birthBurst = false;
  int burstTimer = 0;
    */
  VehicleMembrane(float x, float y, float r) {
    /*
    position = new PVector(x, y);
    radius = r;
    noiseOffset = random(1000);
    */
  }
  
  /*

  boolean contains(PVector agentPos) {
    return PVector.dist(position, agentPos) < radius;
  }
  boolean containsCore(PVector agentPos) {
    return PVector.dist(position, agentPos) < (radius/4);
  }
  boolean containsSensing(PVector agentPos, float sensingRadius) {
    return PVector.dist(position, agentPos) < sensingRadius;
  }

  void update(ArrayList<Agent> agents, float regenRate) {
    if (burstTimer > 0) burstTimer--;
    else birthBurst = false; // burst event expires after burstTimer frames
    energy = min(energy + regenRate, maxEnergy); // energy regeneration each frame
    // coreOccupied stays true as long as the reproducing parent is still inside
    // once parent leaves, slot opens for next reproduction
    boolean parentStillInside = false;
    for (Agent a : agents) {
      if (a.hasGivenBirth && contains(a.position)) {
        parentStillInside = true;
        break;
      }
    }
    if (!parentStillInside) coreOccupied = false;
  }

  void triggerBirthBurst() {
    birthBurst = true;
    burstTimer = 120;
  }
  
  void updatePosition(float x, float y){
    
    position.set(x, y);
  }

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

    /*
    noStroke();
     fill(hue, 70, 80);
     colorMode(RGB, 255);
     circle(position.x, position.y, (radius/4) * 2);
     
  }
  */
}
