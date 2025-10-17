class Breath {

  float theta;
  float aVelocity;
  float standardAVelocity;
  // float breathingIn;
  // float breathingOut;
  //boolean exhale;
  boolean isBreathing;
  Timer timer;
  float originalAmplitude;
  float amplitude;
  float amplitudeAdjusted;

  float radius;
  float previousRadius;

  float radiusMin, radiusMax;

  //boolean isReadyToBeSwitched;

  String parent;

  String movement;
  String direction;

  boolean reset;

  Breath(String p) {

    parent = p;

    standardAVelocity = 0.025;  //0.025;

    if (parent == "vehicle") {

      standardAVelocity = 0.0125;  //0.025;
    } else if (parent == "player") {

      standardAVelocity = 0.025;  //0.025;
    }

    aVelocity = standardAVelocity;

    timer = new Timer(1000);
    isBreathing = true;

    radiusMin = 100;
    radiusMax = 300;

    amplitude = radiusMin;
    amplitudeAdjusted = radiusMax - radiusMin;

    radius = amplitude;
    previousRadius = 0;

    initialize();

    //isReadyToBeSwitched = false;
  }

  //--------------------------------------------------------------

  void initialize() {

    theta = radians(530);
    movement = "empty";
    direction = "inhale";
  }

  //--------------------------------------------------------------

  void setEmpty() {

    theta = radians(530);
    radius = radiusMin;
    movement = "empty";
    direction = "inhale";

    theta = radians(175);
   // radius = amplitude * cos(theta);
   // radius += amplitudeAdjusted;
  }

  /*
    void setEmpty(){
   
   theta = radians(175);
   movement = "empty";
   radius = amplitude * cos(theta);
   radius += amplitudeAdjusted;
   
   }
   
   */

  //--------------------------------------------------------------

  void resetTimer() {

    isBreathing = true;
    theta = radians(190);

    int randomTime = int(random(0, 2000)); // between .5 and 1 second pause
    timer = new Timer(randomTime);

    aVelocity *= -1;
  }

  //--------------------------------------------------------------

  void breathe() {
      
    if (timer.isFinished() && !isBreathing) {

      resetTimer();
    }

    if (isBreathing) {

      radius = amplitude * cos(theta);
      theta += aVelocity;

      if (radius < -(amplitude-1)) {

        isBreathing = false;
        // start pause between breathings
        timer.start();
      } 

      // adjust radius based on max min values
      radius += amplitudeAdjusted;

      if (radius < (radiusMin+2)) {

        movement = "empty";
      } else if (radius > (radiusMax-2)) {

        movement = "full";
      } else {

        movement = "breathing";

        if (previousRadius <= radius) {

          direction = "inhale";
        } else {

          direction = "exhale";
        }
      }

      previousRadius = radius;
    }
  }
}
