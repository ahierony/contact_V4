class PlayerTrail {

  ArrayList<PlayerTrailMark> marks;

  PVector markPos;
  PVector previousMarkPos;
  int markFrameCount;

  int markCount;
  int maxMarks;

  int previouseMainAngle;
  int currentMainAngle;
  
  int trailStrokeWeight;

  PlayerTrail(float x, float y) {
    
    trailStrokeWeight = 1;

    marks = new ArrayList<PlayerTrailMark>();

    markPos = new PVector(x, y);
    previousMarkPos = new PVector(x, y);
    markFrameCount = 0;

    //maxMarks = int(random(13, 50)); // FOR TESTING
    maxMarks = int(random(100, 150));

    markCount = 0;

    previousMarkPos = new PVector(0, 0);
    markPos = new PVector(0, 0);
  }

  //--------------------------------------------------------------

  void update(float x, float y, float pVel, float mainTheta) {

    currentMainAngle = int(degrees(mainTheta));

    int mainAngleDiff = abs(currentMainAngle - previouseMainAngle);

    markPos.set(x, y);

    //float dist = dist(markPos.x, markPos.y, previousMarkPos.x, previousMarkPos.y);

    float a = PVector.angleBetween(markPos, previousMarkPos);

    //float a = atan2(markPos.y-previousMarkPos.y, markPos.x-previousMarkPos.x);

    float angle = degrees(a);
    angle = abs(angle);


    int count;
    markFrameCount++;
    count = markFrameCount % 15;


    //if(dist > 1 || angle > 1){

    if (angle > 1) {
      addMarks();
    } else if (mainAngleDiff > 1) {

      addMarks();
    } else if (count == 0) {

      addMarks();
      markCount++;
    }


    /*
    if(pVel > 5){
     addMarks(x, y);
     }
     */

    previouseMainAngle = currentMainAngle;
  }

  //--------------------------------------------------------------

  void addMarks() {

    //int count;

    previousMarkPos.set(markPos.x, markPos.y);
    //markPos.set(x, y);

    //float dist = dist(markPos.x, markPos.y, previousMarkPos.x, previousMarkPos.y);

    //markFrameCount++;

    //count = markFrameCount % 30;

    //if (count == 0) {

    //float markSpeed = map(dist, 5, 20, 0.2, 2);
    marks.add(new PlayerTrailMark(markPos));
    //markCount++;
    //}
  }

  //--------------------------------------------------------------

  void display() {

    colorMode(RGB);
    
    for (int i= 0; i < marks.size(); i++) {
      PlayerTrailMark m = marks.get(i);
        
        
      if (bgTrailBox.offsets.size() > 0) {

        int offsetVal = bgTrailBox.offsets.get(bgTrailBox.offsetNum-1);
        int offsetWeight = bgTrailBox.strokeWeights.get(bgTrailBox.offsetNum-1);
       
        if (i == offsetVal) {
   
          trailStrokeWeight = offsetWeight;
        }
        
      }
      
      if (m != null) {

        if (i > 0) {
          PlayerTrailMark pm = marks.get(i-1);
          if (pm != null) {
            //stroke(0, 0, 99);
            //stroke(0, 0, 99);


            // so that no lines get drawn when the bgTrailBox wraps
            float d = dist(pm.x, pm.y, m.x, m.y);

            if (d < bg.wrapLimit_w) {
              
              strokeWeight(trailStrokeWeight);
              stroke(255);

              line(pm.x, pm.y, m.x, m.y);
            } else {
            }
          }
        }

        m.display();
      }
    }
    
    trailStrokeWeight = 1;

    strokeWeight(trailStrokeWeight);
    colorMode(HSB, 360, 100, 100);
  }
}
