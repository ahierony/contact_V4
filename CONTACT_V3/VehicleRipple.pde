class VehicleRipple { 

  float radius;
  
  float x, y;
  float speed;
  color colorTrail;
  
  int count;
  
  float opacity;
  int opacityCount;

  VehicleRipple(PVector pos, float rippleSpeed, color ct, float _opacityStart) {

    x = pos.x;
    y = pos.y;
    
    opacity = _opacityStart;
    
    speed = rippleSpeed;
    
    radius = 105;
    
    colorTrail = ct;
    
    opacityCount = 0;
    count = 0;
    
    
  }

//--------------------------------------------------------------


  void update(int rippleNum) {
    
    int opacityPace;
    
    if(rippleNum < 2){
      opacityPace = 2;
    } else {
      opacityPace = rippleNum;
    }
    
    opacityCount++;
    
    count = opacityCount % opacityPace;
    
    if(count == 0){
      
      opacity -= rippleNum/3;
    }

    radius += speed;
   
    if (opacity<=0) {
      opacity=0;
      radius=0;
    }
  }

//--------------------------------------------------------------


  void display() {

    fill(colorTrail, opacity);
    noStroke();
    circle (x, y, radius);
  }
}
