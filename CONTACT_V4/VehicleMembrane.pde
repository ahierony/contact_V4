class VehicleMembrane {

  float resolution = 260; // how many points in the circle
  float rad;
  float x = 1;
  float y = 1;

  float t = 0; // time passed
  float tChange = .02; // how quick time flies

  float nVal; // noise value
  float nInt = 1; // noise intensity
  float nAmp = 1; // noise amplitude

  boolean filled = true;

  PVector pos;

  VehicleMembrane(float x, float y) {

    noiseDetail(5);

    pos = new PVector(x, y);
  }

  void display(color col) {

    pushMatrix();
    translate(pos.x, pos.y);
    
    strokeWeight(1);

    if (filled) {
      noStroke();
      //stroke(0);
      fill(col);
    } else {
      noFill();
      stroke(0);
    }
    // original //nInt = map(mouseX, 0, width, 0.1, 30); // map mouseX to noise intensity
    // original //nAmp = map(mouseY, 0, height, 0.0, 1.0); // map mouseY to noise amplitude

    //nInt = map(mouseX, 0, width, 0.1, 5); // map mouseX to noise intensity
    //nAmp = map(mouseY, 0, height, 0.0, .2); // map mouseY to noise amplitude

    nInt = 0.0;
    nAmp = 1.0;

    beginShape();
    for (float a=0; a<=TWO_PI; a+=TWO_PI/resolution) {

      nVal = map(noise( cos(a)*nInt+1, sin(a)*nInt+1, t ), 0.0, 1.0, nAmp, 1.0); // map noise value to match the amplitude

      x = cos(a)*rad *nVal;
      y = sin(a)*rad *nVal;

      vertex(x, y);
    }
    endShape(CLOSE);

    t += tChange;

    popMatrix();
  }

  void update(float r) {

    rad = r;
  }
}
