
class EyeInner extends EyeShape {
  
  PVector pos;
  float radius;
  color c;

  EyeInner(float _x, float _y, float _radius) {

    super(_x, _y, _radius);
    
    pos = new PVector(_x, _y);

    radius = _radius;
  }

  void updateColor(color _c) {
    c = _c;
  }

  void display() {

    super.display(c);
  }
  
  void update(){
    
    super.update(pos);
    
  }
  
 
}
