class Audio {

  boolean[] vehicleBreathingAudioIsPlaying = new boolean[vehicles.size()];



  Audio() {

    for (int i=0; i < vehicleBreathingAudioIsPlaying.length; i++) {
      vehicleBreathingAudioIsPlaying[i] = true;
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
}
