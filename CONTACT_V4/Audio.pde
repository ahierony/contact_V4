class Audio {

  boolean[] vehicleBreathingAudioIsPlaying = new boolean[vehicles.size()];
  float[] vehicleBreathingAudioVolume = new float[vehicles.size()];

  boolean playerIsInZone;
  float playerInZoneVolume;
  boolean playerIsInContactWithVehicle;
  boolean gameIsOver;

  boolean checkIfplayerIsInContactWithVehicle;
  boolean checkIfGameIsOver;

  boolean printAudio = false;
  boolean printOSC = true;

  Audio() {

    for (int i=0; i < vehicleBreathingAudioIsPlaying.length; i++) {
      vehicleBreathingAudioIsPlaying[i] = true;
      vehicleBreathingAudioVolume[i] = 0;
    }

    checkIfplayerIsInContactWithVehicle = false;
    checkIfGameIsOver = false;

    //playerIsInsideVehicleZoneAudioIsPlaying = false;
  }

  void update() {

    // OSC initialization

    OscMessage[] osc_breathingVehicles_audioIsPlaying = new OscMessage[vehicles.size()];
    OscMessage[] osc_breathingVehicles_audioVolume = new OscMessage[vehicles.size()];

    for (int i = 0; i < vehicles.size(); i++) {
      osc_breathingVehicles_audioIsPlaying[i] = new OscMessage("/breathingVehicles" + i + "_audioIsPlaying");
      osc_breathingVehicles_audioVolume[i] = new OscMessage("/breathingVehicles" + i + "_audioVolume");
    }

    //

    OscMessage osc_player_isInsideVehicleZone = new OscMessage("/osc_player_isInsideVehicleZone");
    OscMessage osc_playerInVehicleZone_audioVolume = new OscMessage("/osc_playerInVehicleZone_audioVolume");

    // CUSTOM METHODS CALLS

    // check if player is inside a vehicle zone

    if (isPlayerInsideVehicleZone()) {

      // initiate sound of player in vehicle zone
      //--------------------------------------------------------------
      osc_player_isInsideVehicleZone.add(playerIsInZone);
      if (printOSC) oscP5.send(osc_player_isInsideVehicleZone, myRemoteLocation);

      // adjust volume
      //--------------------------------------------------------------

      playerInZoneVolume = setPlayerInVehicleZone_audioVolume(player.location.currentVehicle);

      osc_playerInVehicleZone_audioVolume.add(playerInZoneVolume);
      if (printOSC) oscP5.send(osc_playerInVehicleZone_audioVolume, myRemoteLocation);
      
      
    } else { // player is outside of vehicle zone

      playVehicles_audio();
      setVehicles_audioVolume();

      // is audio playing

      for (int i = 0; i < vehicles.size(); i++) {

        if (vehicleBreathingAudioIsPlaying[i]) {

          //if (printAudio) println("vehicle" + i + "_audio : ", vehicleBreathingAudioIsPlaying[i]);

          osc_breathingVehicles_audioIsPlaying[i].add(vehicleBreathingAudioIsPlaying[i]);
          if (printOSC) oscP5.send(osc_breathingVehicles_audioIsPlaying[i], myRemoteLocation);

          // set audio volume

          if (printAudio) println("vehicle" + i + "_audioVolume : ", vehicleBreathingAudioVolume[i]);

          osc_breathingVehicles_audioVolume[i].add(vehicleBreathingAudioVolume[i]);
          if (printOSC) oscP5.send(osc_breathingVehicles_audioVolume[i], myRemoteLocation);
        }
      }
    }
  } // update()


  // methods
  //--------------------------------------------------------------

  boolean isPlayerInsideVehicleZone() {

    if (player.location.getState() == player.location.pLocVehicleZoneState) {
      return true;
    } else {
      return false;
    }
  }

  //--------------------------------------------------------------

  void playVehicles_audio() {

    for (int i=0; i < vehicles.size(); i++) {
      Vehicle v = vehicles.get(i);

      if (v.location.getState() != v.location.vInDeadState) {

        vehicleBreathingAudioIsPlaying[i] = true;
      } else {

        vehicleBreathingAudioIsPlaying[i] = false;
      }
    }
  }

  //--------------------------------------------------------------

  void setVehicles_audioVolume() {

    float volMin = 0.0;
    float volMax = 10.0;

    for (int i=0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      if (vehicleBreathingAudioIsPlaying[i]) {

        float volume = map(v.zone.radius, v.zone.radiusMin, v.zone.distanceRadius, volMin, volMax);

        vehicleBreathingAudioVolume[i] = volume;
      }
    }
  }

  //--------------------------------------------------------------

  float setPlayerInVehicleZone_audioVolume(Vehicle v) {

    Vec2 playerPos = box2d.getBodyPixelCoord(player.centerSphere.body);
    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);

    float r_max = v.zone.distanceRadius;
    float r_min = v.zone.radiusMin;

    float dist = dist(playerPos.x, playerPos.y, vehiclePos.x, vehiclePos.y);

    if (r_max <= r_min) {
      r_max = r_min + 10;
    }
    float vol = map(dist, r_min, r_max, 0, 10);
    
    if (printAudio) println("player in vehicle zone volume ", vol);

    return vol;
  }

  //--------------------------------------------------------------

  void playerIsTouchingVehicle_playAudio() { // called from collision.checkPlayerAgainstVehicleInZone()

    OscMessage osc_playerContactWithVehicle = new OscMessage("/osc_playerContactWithVehicle");

    osc_playerContactWithVehicle.add(true);
    if (printOSC) oscP5.send(osc_playerContactWithVehicle, myRemoteLocation);
    
    if (printAudio) println("vehicle hit");
  }

  //--------------------------------------------------------------

  void gameOver_playAudio() { // called from main.draw(){

    OscMessage osc_gameOver = new OscMessage("/osc_gameOver");

    osc_gameOver.add(true);
    if (printOSC) oscP5.send(osc_gameOver, myRemoteLocation);
    
    if (printAudio) println("gameover");
  }
}
