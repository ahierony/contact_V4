class Environment {

  Vehicle v;

  int stages;
  int currentStage;
  
  int index;

  // sound
  SoundFile[] environmentsBaseSounds;
  SoundFile[] environmentsMuffledSounds;
  SoundFile currentEnvironmentSound;


  Environment(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex, PApplet app) {
    
    index = vIndex + 1;

    v = new Vehicle(x, y, _colorAngle, _inMotion, type_, unitNum_, p, vIndex, this);

    currentStage = 1;
    stages = 5;

    if (playSoundContactV4) {

      //setupSounds(app);
    }
  }

  void run(ArrayList<Agent> agents, ArrayList<Environment> environments) {

    v.run(agents, environments);

    if (playSoundContactV4) {

      //updateSounds();
    }
  }

  void setupSounds(PApplet app) {

    environmentsBaseSounds = new SoundFile[stages];
      
    environmentsBaseSounds[0] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "A.mp3");
    environmentsBaseSounds[1] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "B.mp3");
    environmentsBaseSounds[2] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "C.mp3");
    environmentsBaseSounds[3] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "D.mp3");
    environmentsBaseSounds[4] = new SoundFile(app, "../../MUSIC/Environments_Base/environment_base_" + index + "E.mp3");
    
    environmentsMuffledSounds = new SoundFile[stages];
      
    environmentsMuffledSounds[0] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "A.mp3");
    environmentsMuffledSounds[1] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "B.mp3");
    environmentsMuffledSounds[2] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "C.mp3");
    environmentsMuffledSounds[3] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "D.mp3");
    environmentsMuffledSounds[4] = new SoundFile(app, "../../MUSIC/Environments_Muffled/environment_muffled_" + index + "E.mp3");

    

    currentEnvironmentSound = environmentsBaseSounds[currentStage];

    currentWorldSound.amp(0.5);
    //currentWorldSound.play();
    //currentWorldSound.loop();
  }

  void updateSounds() {
  }
}
