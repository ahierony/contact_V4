class SensorHead extends EyeShape {

  PVector pos;
  float radius;
  color c;

  SensorHead(float _x, float _y, float _radius) {

    super(_x, _y, _radius);

    pos = new PVector(_x, _y);

    radius = _radius;

    c = color(242, 130, 130);
  }


  void display() {

    pushMatrix();
    translate(pos.x, pos.y);
    super.display(c);
    popMatrix();
  }

  boolean intersectsOuter(EyeShape c) {
    return super.intersectsOuter(c, pos.x, pos.y);
  }
}
