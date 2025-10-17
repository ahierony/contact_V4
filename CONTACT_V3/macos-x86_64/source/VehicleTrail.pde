class VehicleTrail {

  ArrayList<VehicleRipple> ripples;

  PVector ripplePos;
  PVector previousRipplePos;
  int rippleFrameCount;

  int rippleCount;
  int maxRipples;

  VehicleTrail(float x, float y) {

    ripples = new ArrayList<VehicleRipple>();

    ripplePos = new PVector(x, y);
    previousRipplePos = new PVector(x, y);
    rippleFrameCount = 0;
    
    //maxRipples = int(random(13, 50)); // FOR TESTING
    maxRipples = int(random(100, 150));

    rippleCount = 0;
  }
  
  //--------------------------------------------------------------

  void update() {

    updateRipples();

    removeRipples();
    
  }
  
  //--------------------------------------------------------------

  void display() {

    for (VehicleRipple r : ripples) {
      if (r != null) {

        r.display();
      }
    }
  }
  
  //--------------------------------------------------------------

  void removeRipples(){
    
    for (int i= 0; i < ripples.size(); i++) {

      VehicleRipple r = ripples.get(i);

      if (r.opacity <=0) {
        ripples.remove(i);
      }
    }
  }
  
  //--------------------------------------------------------------
  
  void updateRipples(){
    
    for (VehicleRipple r : ripples) {
      if (r != null) {
        r.update(ripples.size()-1);
      }
    }
  }
  
   //--------------------------------------------------------------
  
  void addRipples(float x, float y, color colorTrail, float opacityStart){
    
    if (opacityStart > 0) {
      int count;

      previousRipplePos.set(ripplePos.x, ripplePos.y);
      ripplePos.set(x, y);

      float dist = dist(ripplePos.x, ripplePos.y, previousRipplePos.x, previousRipplePos.y);

      rippleFrameCount++;

      count = rippleFrameCount % 30;

      if (count == 0) {

        float rippleSpeed = map(dist, 5, 20, 0.2, 2);
        ripples.add(new VehicleRipple(ripplePos, rippleSpeed, colorTrail, opacityStart));
        rippleCount++;
      }
    }
    
  }
  
}
