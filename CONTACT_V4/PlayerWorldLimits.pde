class PlayerWorldLimits {

  PVector pos;
  float rect_w, rect_h;

  PlayerTrail trailLeft;
  PlayerTrail trailRight;

  PVector offset;

  int strokeWeightIncrease;
  ArrayList<Integer> offsets;
  ArrayList<Integer> strokeWeights;
  int offsetStrokeWeight;
  int offsetNum;

  float trailBox_wrapLimit_w;
  float trailBox_wrapLimit_h;



  PlayerWorldLimits(int _unitTotal, float unit_w, float unit_h) {

    offsets = new ArrayList<Integer>();
    strokeWeights = new ArrayList<Integer>();
    offsetNum = 0;

    offsetStrokeWeight = 1;
    strokeWeightIncrease = 5;

    pos = new PVector(0, 0);

    offset = new PVector(0, 0);

    //float unitSize = 0.1;

    rect_w = sqrt(_unitTotal) * unit_w;
    rect_h = sqrt(_unitTotal) * unit_h;

   
  }


  void display() {

    rectMode(CENTER);

    Vec2 playerPos = box2d.getBodyPixelCoord(player.centerSphere.body);
    //println("playerPos.x ", playerPos.x);
    
    colorMode(RGB);
    stroke(255);
    fill(0);
    strokeWeight(5);

    pushMatrix();

    //scale(worldScale);

    translate(playerPos.x, playerPos.y);

    //if (debugMode)

    noFill();
    stroke(255);
    rect(0, 0, rect_w, rect_h);

    //println("rect_w ", rect_w);
    //println("rect_h ", rect_h);

    //trailLeft.display();
    //trailRight.display();

    popMatrix();

    strokeWeight(1);
    colorMode(HSB, 360, 100, 100);
  }

}
