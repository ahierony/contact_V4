class BgTrailBox {

  PVector pos;
  float rect_w, rect_h;

  PlayerTrail trailLeft;
  PlayerTrail trailRight;


  PVector offset;


  BgTrailBox(int _unitTotal, float unit_w, float unit_h) {

    pos = new PVector(0, 0);

    offset = new PVector(0, 0);
    
    //float unitSize = 0.1;

    rect_w = sqrt(_unitTotal) * unit_w;
    rect_h = sqrt(_unitTotal) * unit_h;

    //println("rectSize ", rectSize);


    //rectMode(CENTER);

    Vec2 playerPos = box2d.getBodyPixelCoord(player.centerSphere.body);

    trailLeft = new PlayerTrail(playerPos.x, playerPos.y);
    trailRight = new PlayerTrail(playerPos.x, playerPos.y);
  }


  void display(float worldScale) {
    
     rectMode(CENTER);

    //Vec2 playerPos = box2d.getBodyPixelCoord(player.centerSphere.body);
    //println("playerPos.x ", playerPos.x);
    
    colorMode(RGB);
    stroke(255);
    fill(0);
    strokeWeight(2);
    
    pushMatrix();
    
    scale(worldScale);

    translate(pos.x, pos.y);

    

    //if (debugMode)
    noFill();
    stroke(255);
    rect(0, 0, rect_w, rect_h);

    trailLeft.display();
    trailRight.display();

    popMatrix();

    strokeWeight(1);
    colorMode(HSB, 360, 100, 100);
  }



  void update(PVector vel) {

    pos.add(vel);

    Vec2 leftEyePos = box2d.getBodyPixelCoord(player.leftEye.eyeOuterb2d.body);
    Vec2 rightEyePos = box2d.getBodyPixelCoord(player.rightEye.eyeOuterb2d.body);

    PVector leftEyesPosPVec = new PVector(leftEyePos.x, leftEyePos.y);
    PVector rightEyePosPVec = new PVector(rightEyePos.x, rightEyePos.y);


    if (pos.x > bg.wrapLimit_w) {
      pos.x = - bg.wrapLimit_w;
      offset.x += bg.wrapLimit_w*2;
    } else if (pos.x < -bg.wrapLimit_w) {
      pos.x = bg.wrapLimit_w;
      offset.x -= bg.wrapLimit_w*2;
    }

    if (pos.y > bg.wrapLimit_h) {
      pos.y = -bg.wrapLimit_h;
      offset.y += bg.wrapLimit_h*2;
    } else if (pos.y < -bg.wrapLimit_h) {
      pos.y = bg.wrapLimit_h;
      offset.y -= bg.wrapLimit_h*2;
    }


    leftEyesPosPVec.add(offset);
    rightEyePosPVec.add(offset);

    updateTrail(leftEyesPosPVec, rightEyePosPVec);
  }

  void updateTrail(PVector _leftEyePos, PVector _rightEyePos) {

    trailLeft.update(_leftEyePos.x, _leftEyePos.y);
    trailRight.update(_rightEyePos.x, _rightEyePos.y);
  }
}
