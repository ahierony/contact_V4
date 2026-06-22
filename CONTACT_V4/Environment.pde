class Environment {

  Vehicle v;


  Environment(float x, float y, int _colorAngle, boolean _inMotion, String type_, int unitNum_, Player p, int vIndex) {

    v = new Vehicle(x, y, _colorAngle, _inMotion, type_, unitNum_, p, vIndex, this);
  }

  void run(ArrayList<Agent> agents, ArrayList<Environment> environments) {

    v.run(agents, environments);
  }

  
}
