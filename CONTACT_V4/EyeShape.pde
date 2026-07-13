class EyeShape {

  float radius;
  PVector pos;

  EyeShape(float _x, float _y, float _radius) {

    radius = _radius;

    pos = new PVector(_x, _y);
  }

  void update(PVector _pos) {

    pos.set(_pos.x, _pos.y);
  }


  void display(color c) {

    ellipseMode(RADIUS);

    if (debugMode) {
      strokeWeight(2);
      noFill();
      stroke(255);
    } else {

      noStroke();
      fill(c);
    }

    circle(pos.x, pos.y, radius);
  }

  boolean intersectsInner(EyeShape c, float pupilX, float pupilY) {

    float dist = dist(pupilX, pupilY, c.pos.x, c.pos.y);
    dist += radius;

    if (dist <= c.radius) { // used to be < and not <=
      return true;
    } else {
      return false;
    }
  }

  boolean intersectsOuter(EyeShape c, float pupilX, float pupilY) {

    float dist = dist(pupilX, pupilY, c.pos.x, c.pos.y);

    if (dist < c.radius + radius) {
      return true;
    } else {
      return false;
    }
  }
}
