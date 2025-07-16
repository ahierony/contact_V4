class Audio {

  boolean[] vehicleBreathingAudioIsPlaying = new boolean[vehicles.size()];
  float[] vehicleBreathingAudioVolume = new float[vehicles.size()];



  Audio() {

    for (int i=0; i < vehicleBreathingAudioIsPlaying.length; i++) {
      vehicleBreathingAudioIsPlaying[i] = true;
      vehicleBreathingAudioVolume[i] = 0;
    }
  }


  void playVehicleAudio() {

    for (int i=0; i < vehicles.size(); i++) {
      Vehicle v = vehicles.get(i);

      if (v.location.getState() != v.location.vInDeadState) {

        vehicleBreathingAudioIsPlaying[i] = true;
      } else {

        vehicleBreathingAudioIsPlaying[i] = false;
      }
    }
  }

  void getVehicleAudioVol() {

    float volMin = 0.0;
    float volMax = 10.0;

    for (int i=0; i < vehicles.size(); i++) {
      Vehicle v = vehicles.get(i);

      float volume = map(v.zone.radius, v.zone.radiusMin, v.zone.distanceRadius, volMin, volMax);
      vehicleBreathingAudioVolume[i] = volume;
      //println("vehicle ", i, " radius ", vehicleBreathingAudioVolume[i]);
    }
    
    println("");
  }
}
