class Audio {

  boolean[] vehicleBreathingAudioIsPlaying = new boolean[vehicles.size()];
  float[] vehicleBreathingAudioVolume = new float[vehicles.size()];

  boolean playerIsInZone;



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
}
