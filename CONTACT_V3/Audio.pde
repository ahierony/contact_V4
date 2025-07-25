class Audio {

  boolean[] vehicleBreathingAudioIsPlaying = new boolean[vehicles.size()];
  float[] vehicleBreathingAudioVolume = new float[vehicles.size()];

  boolean playerIsInZone;
  float playerInZoneVolume;

  Audio() {

    for (int i=0; i < vehicleBreathingAudioIsPlaying.length; i++) {
      vehicleBreathingAudioIsPlaying[i] = true;
      vehicleBreathingAudioVolume[i] = 0;
    }

    //playerIsInsideVehicleZoneAudioIsPlaying = false;
  }

  void update() {

    isPlayerInsideVehicleZone();
    
    playVehicleAudio();
    setVehicleAudioVol();
    
    if(playerIsInZone){
      playerInZoneVolume = trackPlayerDistanceFromVehicle(player.location.currentVehicle);
    } else {
      playerInZoneVolume = 0;
    }
  }

  // methods
  //--------------------------------------------------------------

  void isPlayerInsideVehicleZone() {

    if (player.location.getState() == player.location.pLocVehicleZoneState) {
        
      playerIsInZone = true;
    } else {
      playerIsInZone = false;
    }
  }

  //--------------------------------------------------------------

  void playVehicleAudio() {

    for (int i=0; i < vehicles.size(); i++) {
      Vehicle v = vehicles.get(i);

      if (playerIsInZone) {

        vehicleBreathingAudioIsPlaying[i] = false;
      } else {

        if (v.location.getState() != v.location.vInDeadState) {

          vehicleBreathingAudioIsPlaying[i] = true;
        } else {

          vehicleBreathingAudioIsPlaying[i] = false;
        }
      }
    }
  }

  //--------------------------------------------------------------

  void setVehicleAudioVol() {

    float volMin = 0.0;
    float volMax = 10.0;

    for (int i=0; i < vehicles.size(); i++) {

      Vehicle v = vehicles.get(i);

      if (vehicleBreathingAudioIsPlaying[i]) {

        float volume = map(v.zone.radius, v.zone.radiusMin, v.zone.distanceRadius, volMin, volMax);
        //println("v.zone.radius ", v.zone.radius);
        //println("");

        vehicleBreathingAudioVolume[i] = volume;
      } else {
        vehicleBreathingAudioVolume[i] = 0.0;
      }
      //println("vehicle ", i, " radius ", vehicleBreathingAudioVolume[i]);
    }
  }
  
  float trackPlayerDistanceFromVehicle(Vehicle v){
    
    Vec2 playerPos = box2d.getBodyPixelCoord(player.centerSphere.body);
    Vec2 vehiclePos = box2d.getBodyPixelCoord(v.centerBoid.body);
    
    float r_max = v.zone.distanceRadius;
    float r_min = v.zone.radiusMin;
    
    float dist = dist(playerPos.x, playerPos.y , vehiclePos.x, vehiclePos.y);
    
    float vol = map(dist, r_min, r_max, 0, 10);
       
    return vol;
    
  }
}
