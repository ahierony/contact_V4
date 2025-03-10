class PlayerTrailMark {

  float radius;

  float x, y;
  float speed;
  color colorTrail;


 // float theta;

  PlayerTrailMark(PVector pos, float markSpeed) {

   
    x = pos.x;
    y = pos.y;

    speed = markSpeed;

    radius = 30;

  }

  //--------------------------------------------------------------


  void update(int markNum) {

    //updateOpacity(markNum);
  }

  //--------------------------------------------------------------


  void display() {
    /*
    fill(colorTrail, opacity);
     noStroke();
     */

    //println("colorTrail player ", colorTrail);
    
    //colorMode(RGB);

    pushMatrix();
    translate(x, y);
   // rotate(-theta);
    //stroke(colorTrail, player.saturation, player.blobBrightness);
    //stroke(0, 0, 99);
    noFill();
    circle (0, 0, radius);
    //line(-radius, 0, radius, 0);
    //line(0, -radius, 0, radius);
    popMatrix();
    
    
    //colorMode(HSB, 360, 100, 100);
  }
}
