
class EyeOuter extends EyeShape {

  float x, y, radius, w, h;
  color fillColor, strokeColor;
  float theta;

  EyeOuter(float _x, float _y, float _radius) {

    super(_x, _y, _radius);

    x = _x;
    y = _y;
    radius = _radius;
    w = _radius*2;
    h = _radius*2;
  }

  void updateColor(color _fill, color _stroke) {
    fillColor = _fill;
    strokeColor = _stroke;
  }

  void setTheta(float _theta) {
    theta = _theta;
  }

  void display() {

    pushMatrix();

    rotate(theta + radians(90));
   
    stroke(strokeColor);
    strokeWeight(2);
    if(debugMode){
      noFill();
      line(x, y-radius, x, y + radius);
    } else {
      fill(fillColor);
    }
    ellipseMode(CENTER);
    ellipse(x, y, w, h);


    popMatrix();
  }
}
