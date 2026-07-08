class Data {

  XML xml;

  DataScrollbar speedSlider;
  DataScrollbar drainSlider;
  DataScrollbar refillSlider;
  DataScrollbar populationSlider;
  DataScrollbar sensingRadiusSlider;
  DataScrollbar regenRateSlider;
  DataScrollbar visitCostSlider;
  DataScrollbar birthCostSlider;
  DataScrollbar birthCooldownSlider;



  Data() {

    // (x, y, width, min, max, default)
    /*
    speedSlider = new DataScrollbar(20, 20, 200, 1, 10, 5);
     drainSlider = new DataScrollbar(20, 60, 200, 0.02, 1.0, 0.2);
     refillSlider = new DataScrollbar(20, 100, 200, 0.2, 5.0, 1.0);
     separationDistSlider = new DataScrollbar(20, 140, 200, 50, 300, 110);
     separationForceSlider = new DataScrollbar(20, 180, 200, 0.5, 10, 5);
     populationSlider = new DataScrollbar(20, 220, 200, 5, 100, 20);
     sensingRadiusSlider = new DataScrollbar(20, 260, 200, 1000, 3000, 1500);
     regenRateSlider = new DataScrollbar(20, 300, 200, 0.0, 5.0, 0.5);
     loadData();
     */

    speedSlider = new DataScrollbar(20, 20, 200, 1, 10, 5);
    drainSlider = new DataScrollbar(20, 60, 200, 0.02, 1.0, 0.2);
    refillSlider = new DataScrollbar(20, 100, 200, 0.2, 5.0, 1.0);
    populationSlider = new DataScrollbar(20, 140, 200, 5, 100, 20);
    sensingRadiusSlider = new DataScrollbar(20, 260, 200, 1000, 3000, 1500);
    regenRateSlider = new DataScrollbar(20, 220, 200, 0.0, 5.0, 0.5);
    visitCostSlider = new DataScrollbar(20, 260, 200, 0.0, 3.0, 0.5);
    birthCostSlider = new DataScrollbar(20, 300, 200, 0, 1000, 100);
    birthCooldownSlider = new DataScrollbar(20, 340, 200, 60, 900, 300);

    loadData();
  }

  // updates slider positions from mouse input and draws them with their labels
  void updateAndDrawSliders() {
    /*
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
     text("Agents alive: " + agents.size(), 20, 350);
     */

    speedSlider.update();
    speedSlider.display();
    drainSlider.update();
    drainSlider.display();
    refillSlider.update();
    refillSlider.display();
    populationSlider.update();
    populationSlider.display();
    sensingRadiusSlider.update();
    sensingRadiusSlider.display();
    regenRateSlider.update();
    regenRateSlider.display();
    visitCostSlider.update();
    visitCostSlider.display();
    birthCostSlider.update();
    birthCostSlider.display();
    birthCooldownSlider.update();
    birthCooldownSlider.display();

    fill(0);
    noStroke();
    textAlign(LEFT);
    text("Speed: " + nf(speedSlider.getPos(), 1, 1), 230, 30);
    text("Air Drain: " + nf(drainSlider.getPos(), 1, 2), 230, 70);
    text("Air Refill: " + nf(refillSlider.getPos(), 1, 1), 230, 110);
    text("Population: " + (int)populationSlider.getPos(), 230, 150);
    text("Sensing Radius: " + int(sensingRadiusSlider.getPos()), 230, 190);
    text("Regen Rate: " + nf(regenRateSlider.getPos(), 1, 2), 230, 230);
    text("Visit Cost: " + nf(visitCostSlider.getPos(), 1, 2), 230, 270);
    text("Birth Cost: " + int(birthCostSlider.getPos()), 230, 310);
    text("Birth Cooldown: " + int(birthCooldownSlider.getPos()), 230, 350);
    text("Agents alive: " + agents.size(), 20, 390);
  }

  // draws the environment stats text in the top right corner
  void drawEnvStats() {

    translate(width/2, height/2);

    for (int i = 0; i < environments.size(); i++) {
      Environment e = environments.get(i);
      float healthRatio = e.energy / e.maxEnergy;
      fill(255);
      noStroke();
      textAlign(RIGHT);
      text("Env " + (i+1) + " Energy: " + int(e.energy) + " / " + int(e.maxEnergy), width/2 - 20, -height/2 + 30 + (i * 60));
      text("Env " + (i+1) + " Reproduction: " + nf(healthRatio * 100, 1, 1) + "%", width/2 - 20, -height/2 + 50 + (i * 60));
      text("Env " + (i+1) + " Stage: " + e.getStageName(), width/2 - 20, -height/2 + 70 + (i * 60));
    }
  }


  void display() {

    updateAndDrawSliders();
    drawEnvStats();

    /*
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
     
     fill(126);
     noStroke();
     textAlign(LEFT);
     
     text("Speed: " + nf(speedSlider.getPos(), 1, 1), 230, 30);
     fill(0);
     text("Air Drain: " + nf(drainSlider.getPos(), 1, 2), 230, 70);
     fill(126);
     text("Air Refill: " + nf(refillSlider.getPos(), 1, 1), 230, 110);
     text("Sep Distance: " + int(separationDistSlider.getPos()), 230, 150);
     text("Sep Force: " + nf(separationForceSlider.getPos(), 1, 1), 230, 190);
     text("Population: " + (int)populationSlider.getPos(), 230, 230);
     fill(0);
     text("Sensing Radius: " + int(sensingRadiusSlider.getPos()), 230, 270);
     fill(126);
     text("Regen Rate: " + nf(regenRateSlider.getPos(), 1, 2), 230, 310);
     //text("Agents alive: " + agents.size(), 20, 350);
     */

    /*
    translate(width/2, height/2);
     
     for (int i = 0; i < environments.size(); i++) {
     Environment e = environments.get(i);
     
     float healthRatio =  e.energy / e.maxEnergy;
     fill(0);
     noStroke();
     textAlign(RIGHT);
     text("Env " + (i+1) + " Energy: " + int(e.energy) + " / " + int(e.maxEnergy), width/2 - 20, -height/2 + 30 + (i * 40));
     text("Env " + (i+1) + " Reproduction: " + nf(healthRatio * 100, 1, 1) + "%", width/2 - 20, -height/2 + 50 + (i * 40));
     }
     */
  }

  void loadData() {
    xml = loadXML("data.xml");
    speedSlider.setPos(xml.getChild("speed").getFloatContent());
    drainSlider.setPos(xml.getChild("drain").getFloatContent());
    refillSlider.setPos(xml.getChild("refill").getFloatContent());

    populationSlider.setPos(xml.getChild("population").getIntContent());
    regenRateSlider.setPos(xml.getChild("regenRate").getFloatContent());
    sensingRadiusSlider.setPos(xml.getChild("sensingRadius").getFloatContent());
    visitCostSlider.setPos(xml.getChild("visitCost").getFloatContent());
    birthCostSlider.setPos(xml.getChild("birthCost").getFloatContent());
    birthCooldownSlider.setPos(xml.getChild("birthCooldown").getFloatContent());
  }

  void saveData() {
    xml.getChild("speed").setFloatContent(speedSlider.getPos());
    xml.getChild("drain").setFloatContent(drainSlider.getPos());
    xml.getChild("refill").setFloatContent(refillSlider.getPos());

    xml.getChild("population").setIntContent((int)(populationSlider.getPos()));
    xml.getChild("regenRate").setFloatContent(regenRateSlider.getPos());
    xml.getChild("sensingRadius").setFloatContent(sensingRadiusSlider.getPos());
    xml.getChild("visitCost").setFloatContent(visitCostSlider.getPos());
    xml.getChild("birthCost").setFloatContent(birthCostSlider.getPos());
    xml.getChild("birthCooldown").setFloatContent(birthCooldownSlider.getPos());
    saveXML(xml, "data/data.xml");
    println("settings saved");
  }

  /*
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
   */
}
