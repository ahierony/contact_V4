class Data {

  String p_movement;
  float p_speed;

  String p_rotation;

  float pX;
  float pY;

  String p_area;
  String p_lung;

  float p_area_transition;
  Boolean p_area_vehicleIsInside;
  Boolean p_area_isTouching;

  float p_vehicleZone_transition;
  Boolean p_vehicleZone_isInside;
  Boolean p_vehicleZone_isTouching;

  int p_color;
  int p_prevColor;

  int trackColorDiff;
  int trackSpeedDiff;

  boolean readyForEvent;

  boolean p_canEnterZone;

  Data() {

    //*************** DATA TRACKING ***************************************


    p_movement = "";
    p_rotation = "";

    p_area = "empty";

    p_area_transition = 0.0;
    p_area_vehicleIsInside = false;
    p_area_isTouching = false;

    p_vehicleZone_transition = 0.0;
    p_vehicleZone_isInside = false;
    p_vehicleZone_isTouching = false;

    p_color = 0;
    p_prevColor = 0;

    p_speed = 0;


    trackColorDiff = 0;
    trackSpeedDiff = 0;

    readyForEvent = false;

    p_canEnterZone = false; // trackPlayerInZone
  }

  //--------------------------------------------------------------
  String trackPlayerMovement() {

    if (player.jointSphere.body.getType() == BodyType.DYNAMIC) {

      if (player.lockedEye == "both") {
        p_movement = "accel";
      } else {
        p_movement = "deccel";
      }
    } else if (player.jointSphere.body.getType() == BodyType.STATIC) {

      p_movement = "still";
    }

    return p_movement;
  }

  //--------------------------------------------------------------

  String trackPlayerRotation() {

    if (player.lockedEye == "left") {
      p_rotation = "left";
    } else if (player.lockedEye == "right") {
      p_rotation = "right";
    } else if (player.lockedEye == "none") {
      p_color = int(degrees(player.playerTheta));
      trackColorDiff++;
      if (trackColorDiff == 50) { // the value determines how fast p_movement switches from rotation to still
        if (p_color == p_prevColor) {
          p_rotation = "still";
        }
        trackColorDiff = 0;
      }
      p_prevColor = p_color;
    }

    return p_rotation;
  }

  //--------------------------------------------------------------

  int trackPlayerColor() {

    int p_color = player.colorWheelAngle;

    return p_color;
  }

  //--------------------------------------------------------------

  String trackPlayerDirectionHorizontal() {

    String p_direction;

    Vec2 pos = box2d.getBodyPixelCoord(player.centerSphere.body);

    if (pos.x > pX) {

      p_direction = "right";
    } else if (pos.x < pX) {

      p_direction = "left";
    } else {

      p_direction = "straight";
    }

    pX = pos.x;

    return p_direction;
  }

  //--------------------------------------------------------------

  String trackPlayerDirectionVertical() {

    String p_direction;
    Vec2 pos = box2d.getBodyPixelCoord(player.centerSphere.body);

    if (pos.y > pY) {

      p_direction = "down";
    } else if (pos.y < pY) {

      p_direction = "up";
    } else {

      p_direction = "straight";
    }

    pY = pos.y;

    return p_direction;
  }

  //--------------------------------------------------------------

  float trackPlayerSpeed() {

    float s = player.getLinearVelocity();

    return s;
  }
  //--------------------------------------------------------------

  String trackPlayerAreaBreathing() {

    String p_areaIsBreathing;

    if (player.area.getState() == player.area.exhaleState) {
      p_areaIsBreathing = "exhale";
    } else if (player.area.getState() == player.area.inhaleState) {
      p_areaIsBreathing = "inhale";
    } else {
      p_areaIsBreathing = "still";
    }

    return p_areaIsBreathing;
  }
  //--------------------------------------------------------------

  float trackPlayerAreaRadius() {

    float area_radius = player.area.radius;

    return area_radius;
  }

  //--------------------------------------------------------------

  String trackPlayerLungBreathing() {

    String p_lung;

    if (player.lung.getState() == player.lung.exhaleState) {
      p_lung = "exhale";
      readyForEvent = true;
    } else if (player.lung.getState() == player.lung.inhaleState) {
      p_lung = "inhale";
      readyForEvent = true;
    } else if (player.lung.getState() == player.lung.emptyState && readyForEvent) {
      p_lung = "empty";
      readyForEvent = false;
    } else if (player.lung.getState() == player.lung.fullState && readyForEvent) {
      p_lung = "full";
      readyForEvent = false;
    } else if (player.lung.getState() == player.lung.holdState) {
      p_lung = "hold";
      readyForEvent = true;
    } else {
      p_lung = "";
    }

    return p_lung;
  }


  //--------------------------------------------------------------

  float trackPlayerLungRadius() {

    float lung_radius = player.lung.radius;

    return lung_radius;
  }

  //--------------------------------------------------------------

  void trackPlayerTouchedVehicle(boolean isTouching) { // called from playerlocation

    OscMessage osc_player_touch_vehicle = new OscMessage("/player_touch_vehicle");

    osc_player_touch_vehicle.add(isTouching);
    //println("player in zone: ", isTouching);
    oscP5.send(osc_player_touch_vehicle, myRemoteLocation);
  }

  void trackPlayerInZone(boolean isEntering) { // called from playerlocation

    OscMessage osc_player_in_zone = new OscMessage("/player_in_zone");

    osc_player_in_zone.add(isEntering);
    //println("player in zone: ", isEntering);
    oscP5.send(osc_player_in_zone, myRemoteLocation);
  }


  //--------------------------------------------------------------

  float trackPlayerTransitionsInZone() {

    Vec2 vehiclePosPix = box2d.getBodyPixelCoord(player.location.currentVehicle.centerBoid.body);
    Vec2 playerPosPix = box2d.getBodyPixelCoord(player.centerSphere.body);

    float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, playerPosPix.x, playerPosPix.y);

    //println("d_pix ", d_pix);

    float p_inZoneTransition = (player.location.currentVehicle.zone.radius + player.blobRadius) - d_pix;

    return p_inZoneTransition;
  }


  //--------------------------------------------------------------

  void trackVehicleTouchedPlayer(boolean isTouching) { // called from player

    OscMessage osc_vehicle_touch_player = new OscMessage("/vehicle_touch_player");

    osc_vehicle_touch_player.add(isTouching);
    println("vehicle_touch_player: ", isTouching);
    oscP5.send(osc_vehicle_touch_player, myRemoteLocation);
  }

  void trackVehicleInArea(boolean isEntering) { // called from player

    OscMessage osc_vehicle_in_area = new OscMessage("/vehicle_in_area");

    osc_vehicle_in_area.add(isEntering);
    println("vehicle_in_area: ", isEntering);
    oscP5.send(osc_vehicle_in_area, myRemoteLocation);
  }


}
