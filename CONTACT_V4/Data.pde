class Data {

  XML xml;

  DataScrollbar speedSlider;
  DataScrollbar drainSlider;
  DataScrollbar refillSlider;
  DataScrollbar separationDistSlider;
  DataScrollbar separationForceSlider;
  DataScrollbar populationSlider;
  DataScrollbar sensingRadiusSlider;
  DataScrollbar regenRateSlider;

  Data() {

    // (x, y, width, min, max, default)
    speedSlider = new DataScrollbar(20, 20, 200, 1, 10, 5);
    drainSlider = new DataScrollbar(20, 60, 200, 0.02, 1.0, 0.2);
    refillSlider = new DataScrollbar(20, 100, 200, 0.2, 5.0, 1.0);
    separationDistSlider = new DataScrollbar(20, 140, 200, 50, 300, 110);
    separationForceSlider = new DataScrollbar(20, 180, 200, 0.5, 10, 5);
    populationSlider = new DataScrollbar(20, 220, 200, 5, 100, 20);
    sensingRadiusSlider = new DataScrollbar(20, 260, 200, 100, 1200, 800);
    regenRateSlider = new DataScrollbar(20, 300, 200, 0.0, 5.0, 0.5);
    loadData();
  }

  void display() {

    speedSlider.update();
    speedSlider.display();
    drainSlider.update();
    drainSlider.display();
    refillSlider.update();
    refillSlider.display();
    separationDistSlider.update();
    separationDistSlider.display();
    separationForceSlider.update();
    separationForceSlider.display();
    populationSlider.update();
    populationSlider.display();
    sensingRadiusSlider.update();
    sensingRadiusSlider.display();
    regenRateSlider.update();
    regenRateSlider.display();

    fill(0);
    noStroke();
    textAlign(LEFT);
    text("Speed: " + nf(speedSlider.getPos(), 1, 1), 230, 30);
    text("Air Drain: " + nf(drainSlider.getPos(), 1, 2), 230, 70);
    text("Air Refill: " + nf(refillSlider.getPos(), 1, 1), 230, 110);
    text("Sep Distance: " + int(separationDistSlider.getPos()), 230, 150);
    text("Sep Force: " + nf(separationForceSlider.getPos(), 1, 1), 230, 190);
    text("Population: " + (int)populationSlider.getPos(), 230, 230);
    text("Sensing Radius: " + int(sensingRadiusSlider.getPos()), 230, 270);
    text("Regen Rate: " + nf(regenRateSlider.getPos(), 1, 2), 230, 310);
    //text("Agents alive: " + agents.size(), 20, 350);

    translate(width/2, height/2);

    for (int i = 0; i < environments.size(); i++) {
      Environment e = environments.get(i);

      float healthRatio =  e.v.membrane.energy / e.v.membrane.maxEnergy;
      fill(0);
      noStroke();
      textAlign(RIGHT);
      text("Env " + (i+1) + " Energy: " + int(e.v.membrane.energy) + " / " + int(e.v.membrane.maxEnergy), width/2 - 20, -height/2 + 30 + (i * 40));
      text("Env " + (i+1) + " Reproduction: " + nf(healthRatio * 100, 1, 1) + "%", width/2 - 20, -height/2 + 50 + (i * 40));
    }
  }

  void loadData() {
    xml = loadXML("data.xml");
    speedSlider.setPos(xml.getChild("speed").getFloatContent());
    drainSlider.setPos(xml.getChild("drain").getFloatContent());
    refillSlider.setPos(xml.getChild("refill").getFloatContent());
    separationDistSlider.setPos(xml.getChild("sepDist").getFloatContent());
    separationForceSlider.setPos(xml.getChild("sepForce").getFloatContent());
    populationSlider.setPos(xml.getChild("population").getIntContent());
    regenRateSlider.setPos(xml.getChild("regenRate").getFloatContent());
    sensingRadiusSlider.setPos(xml.getChild("sensingRadius").getFloatContent());
  }

  void saveData() {
    xml.getChild("speed").setFloatContent(speedSlider.getPos());
    xml.getChild("drain").setFloatContent(drainSlider.getPos());
    xml.getChild("refill").setFloatContent(refillSlider.getPos());
    xml.getChild("sepDist").setFloatContent(separationDistSlider.getPos());
    xml.getChild("sepForce").setFloatContent(separationForceSlider.getPos());
    xml.getChild("population").setIntContent((int)(populationSlider.getPos()));
    xml.getChild("regenRate").setFloatContent(regenRateSlider.getPos());
    xml.getChild("sensingRadius").setFloatContent(sensingRadiusSlider.getPos());
    saveXML(xml, "data/data.xml");
    println("settings saved");
  }
}
