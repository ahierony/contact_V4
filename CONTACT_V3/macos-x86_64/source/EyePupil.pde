
class EyePupil extends EyeShape {

  PVector pos;
  float radius;
  color c;

  EyePupil(float _x, float _y, float _radius) {

    super(_x, _y, _radius);

    pos = new PVector(_x, _y);

    radius = _radius;
  }

  void updateColor(color _c) {

    c = _c;
  }

  void display() {

    pushMatrix();
    translate(pos.x, pos.y);
    super.display(c);
    popMatrix();
  }

  boolean intersectsInner(EyeShape c) {
    return super.intersectsInner(c, pos.x, pos.y);
  }

  boolean intersectsOuter(EyeShape c) {
    return super.intersectsOuter(c, pos.x, pos.y);
  }
}
