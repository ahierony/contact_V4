class PlayerTrail {

  ArrayList<PlayerTrailMark> marks;

  PVector markPos;
  PVector previousMarkPos;
  int markFrameCount;

  int markCount;
  int maxMarks;

  PlayerTrail(float x, float y) {

    marks = new ArrayList<PlayerTrailMark>();

    markPos = new PVector(x, y);
    previousMarkPos = new PVector(x, y);
    markFrameCount = 0;

    //maxMarks = int(random(13, 50)); // FOR TESTING
    maxMarks = int(random(100, 150));

    markCount = 0;
  }

  //--------------------------------------------------------------

  void update(float x, float y) {

    //updateMarks();

    //removeMarks();

    addMarks(x, y);
  }

  //--------------------------------------------------------------

  void display() {

    /*
    for (PlayerTrailMark m : marks) {
     if (m != null) {
     
     m.display();
     
     }
     }
     */
     
    colorMode(RGB);
    strokeWeight(2);
    stroke(255);
    

    for (int i= 0; i < marks.size(); i++) {
      PlayerTrailMark m = marks.get(i);

      if (m != null) {

        if (i > 0) {
          PlayerTrailMark pm = marks.get(i-1);
          if (pm != null) {
            //stroke(0, 0, 99);
            //stroke(0, 0, 99);
            
            
             // so that no lines get drawn when the bgTrailBox wraps
            float d = dist(pm.x, pm.y, m.x, m.y); 

            if (d < bg.wrapLimit_w)

              line(pm.x, pm.y, m.x, m.y);
          }
        }

        m.display();
      }
    }
    
    strokeWeight(1);
    colorMode(HSB, 360, 100, 100);
  }


  //--------------------------------------------------------------
  /*
  void updateMarks() {
   
   for (PlayerTrailMark m : marks) {
   if (m != null) {
   m.update(marks.size()-1);
   }
   }
   }
   */

  //--------------------------------------------------------------

  void addMarks(float x, float y) {

    int count;

    previousMarkPos.set(markPos.x, markPos.y);
    markPos.set(x, y);

    float dist = dist(markPos.x, markPos.y, previousMarkPos.x, previousMarkPos.y);

    markFrameCount++;

    count = markFrameCount % 30;

    if (count == 0) {

      float markSpeed = map(dist, 5, 20, 0.2, 2);
      marks.add(new PlayerTrailMark(markPos, markSpeed));
      markCount++;
    }
  }
}
