class PlayerLungBreathe {

  float theta;
  float aVelocity;

  float originalAmplitude;
  float amplitude;
  float amplitudeAdjusted;

  float radius;

  float radiusMin, radiusMax;

  String movement;
  String currentM;
  
 
  PlayerLungBreathe() {

    aVelocity = 0.01;     //0.025;

    radiusMin = 100;
    radiusMax = 300;

    amplitude = radiusMin;
    amplitudeAdjusted = radiusMax - radiusMin;

    radius = amplitude;
      
    currentM = "full";
    movement = "full";
  }  

  void setExhale() {
    
    aVelocity = 0.003; // this for lisbon show IHCI// to test with keyboard 0.003// best for contact v3: 0.005;
    
    currentM = "exhale";
    
    aVelocity = abs(aVelocity);
    
    aVelocity *= 1;
      
  }
  
  void setInhale() {
    
    aVelocity = 0.025;
    
    currentM = "inhale";
    
    aVelocity = abs(aVelocity);
    
    aVelocity *= -1;
      
  }
  
  void setEmpty(){
    
    theta = radians(175);
    movement = "empty";
    radius = amplitude * cos(theta);
    radius += amplitudeAdjusted;
    
  }

  void breathe() {
    
    theta = abs(theta);
    
    radius = amplitude * cos(theta);
    
    theta += aVelocity;
    
    radius += amplitudeAdjusted;
    
    if (radius < (radiusMin+1)) {
       
      movement = "empty";
       
    } else if (radius > (radiusMax-1)) {
      
      
      movement = "full";

      
    } else {
      
      movement = currentM;
    
    }
    
    radius = constrain(radius, radiusMin, radiusMax);

  }
}
