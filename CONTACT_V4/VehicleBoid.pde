
class VehicleBoid {

  // We need to keep track of a Body and a radius
  Body body;
  float radius;

  float x, y;

  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  float wandertheta;

  color red;
  color green;
  color blue;
  color col;

  float player_threat_buffer = 600;
  float player_threat_radius;
  float player_arrive_radius;

  Vec2 posVecPixels;
  Vec2 boidPosition;
  Vec2 boidPositionVecPixelsRelativeToTarget;
  Vec2 targetPosition;

  Vec2 offset;

  String bodyType;
  int categoryBits, maskBits;

  String status, previousStatus;

  boolean applyingImpulse;

  float playerVehicleDistance;
  float previousVelocityLength;

  Vehicle vehicle;

  VehicleBoid(float _x, float _y, float _r, String _type, int _categoryBits, int _maskBits) {

    radius = _r;
    bodyType = _type;
    categoryBits = _categoryBits;
    maskBits = _maskBits;

    posVecPixels = new Vec2(_x, _y);
    boidPosition = new Vec2(0, 0);
    targetPosition = new Vec2(0, 0);
    offset = new Vec2(0, 0);

    makeBody(posVecPixels, bodyType, categoryBits, maskBits);

    maxspeed = 50;
    maxforce = 20;

    red = color(0, 99, 99);
    green = color(119, 99, 99);
    blue = color(239, 99, 99);

    wandertheta = 0.2;

    col = color(0, 0, 48);

    status = "";
    previousStatus = "";

    applyingImpulse = false;

    player_threat_radius = player_threat_buffer;
  }


  // Method to update position
  void update() {

    posVecPixels = box2d.getBodyPixelCoord(body);
    //player_arrive_radius = borderRadius - 20;
  }


  // called from vehicleLocation > VInMovingState
  void isMoving() {

    offset = box2d.getBodyPixelCoord(player.centerSphere.body);

    // player position in pixels
    Vec2 playerPosVecPixels = box2d.getBodyPixelCoord(player.centerSphere.body);

    playerPosVecPixels.subLocal(offset);

    targetPosition = box2d.coordPixelsToWorld(playerPosVecPixels);

    // CALCULATE BOID POSITION

    // boid position in pixels
    Vec2 boidPosPixels = new Vec2(posVecPixels.x, posVecPixels.y);

    boidPosPixels.subLocal(offset);

    boidPositionVecPixelsRelativeToTarget = new Vec2(boidPosPixels.x, boidPosPixels.y);

    boidPosition = box2d.coordPixelsToWorld(boidPosPixels);

    separate(vehicles);

    playerVehicleDistance = dist(boidPosPixels.x, boidPosPixels.y, playerPosVecPixels.x, playerPosVecPixels.y);

    float playerOffset = radius * 5;

    if (player.location.getState() == player.location.pLocMovingState) {

      if (playerVehicleDistance > player.borderRadiusMin - playerOffset) {
        status = "arrive";
        arrive(targetPosition);
        //col = blue;
      } else if (playerVehicleDistance <= player_threat_radius) {

        status = "flee";
        flee(targetPosition);
        //col = red;
      }
    }

    if (playerVehicleDistance <= player.borderRadiusMax - playerOffset && playerVehicleDistance > player_threat_radius) { // happens in all player states
      status = "wander";
      wander();
      //col = green;
    }

    /*
    if (playerVehicleDistance <= player_threat_radius) {
     
     if (player.location.getState() != player.location.pLocBreathingState) {
     
     status = "flee";
     flee(targetPosition);
     //col = red;
     }
     } else if (playerVehicleDistance > borderRadiusMax - (radius * 5)) { // REVISE
     
     status = "arrive";
     arrive(targetPosition);
     //col = blue;
     } else if (playerVehicleDistance <= player_arrive_radius - (radius * 2) && playerVehicleDistance > player_threat_radius) {
     status = "wander";
     wander();
     //col = green;
     }
     */

    previousStatus = status;
  }

  // Separation
  // Method checks for nearby boids and steers away
  void separate (ArrayList<Vehicle> vehicles) {

    float desiredseparation = box2d.scalarPixelsToWorld(300);

    Vec2 steer = new Vec2(0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    Vec2 locA = body.getWorldCenter();
    for (Vehicle other : vehicles) {
      Vec2 locB = other.centerBoid.body.getWorldCenter();
      float d = dist(locA.x, locA.y, locB.x, locB.y);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        Vec2 diff = locA.sub(locB);
        diff.normalize();
        diff.mulLocal(1.0/d);        // Weight by distance
        steer.addLocal(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.mulLocal(1.0/count);
    }

    // As long as the vector is greater than 0
    if (steer.length() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mulLocal(maxspeed);
      Vec2 vel = body.getLinearVelocity();
      steer.subLocal(vel);
      float len = steer.length();
      if (len > maxforce) {
        steer.normalize();
        steer.mulLocal(maxforce);
      }

      applyImpulse(steer);
    }
  }

  void wander() {
    float wanderR = box2d.scalarPixelsToWorld(50);         // Radius for our "wander circle"
    float wanderD = box2d.scalarPixelsToWorld(200);         // Distance for our "wander circle"
    float change = 0.3;


    wandertheta += random(-change, change);     // Randomly change wander theta

    Vec2 velocity = body.getLinearVelocity();
    Vec2 circlepos = new Vec2(velocity.x, velocity.y);

    circlepos.normalize();            // Normalize to get heading
    circlepos.mulLocal(wanderD);          // Multiply by distance
    circlepos.addLocal(boidPosition);               // Make it relative to boid's position

    float h = atan2(velocity.y, velocity.x);

    Vec2 circleOffSet = new Vec2(wanderR*cos(wandertheta+h), wanderR*sin(wandertheta+h));

    Vec2 target = circlepos.add(circleOffSet);

    Vec2 desiredVelocity = target.sub(boidPosition);

    seek(desiredVelocity);
  }


  void applyForce(Vec2 v) {
    body.applyForce(v, body.getWorldCenter());
  }


  void applyImpulse(Vec2 steer) {

    applyingImpulse = true;

    float speed = random(30000, 50000);

    Vec2 boidSpeed = new Vec2(steer.x, steer.y);
    boidSpeed.normalize();
    boidSpeed.mulLocal(speed);

    body.applyLinearImpulse( boidSpeed, body.getPosition(), true);
  }


  void arrive(Vec2 target) {
    Vec2 desiredVelocity = new Vec2(0, 0);
    desiredVelocity = target.sub(boidPosition);
    seek(desiredVelocity);
  }

  void flee(Vec2 target) {

    Vec2 desiredVelocity = new Vec2(0, 0);
    desiredVelocity = boidPosition.sub(target);
    seek(desiredVelocity);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  void seek(Vec2 desired) {

    Vec2 steer = new Vec2(0, 0);

    // If the magnitude of desired equals 0, skip out of here
    // (We could optimize this to check if x and y are 0 to avoid mag() square root
    if (desired.length() == 0) steer.set(0, 0);


    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mulLocal(maxspeed);
    // Steering = Desired minus Velocity

    Vec2 vel = body.getLinearVelocity();
    steer = desired.sub(vel);
    steer.normalize();
    steer.mulLocal(maxforce);

    Vec2 velocity = body.getLinearVelocity();

    float impulseFrequency = 50.0;

    if (status == "flee" || status == "arrive") {

      applyImpulse(steer);
    } else {

      if (velocity.length() <= impulseFrequency) {

        applyImpulse(steer);

        previousVelocityLength = velocity.length();
      }
    }
  }

  void display() {
    // We look at each body and get its screen position
    //Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(posVecPixels.x, posVecPixels.y);
    rotate(-a);
    fill(col);
    stroke(255);
    strokeWeight(2);
    circle(0, 0, radius);
    //  add a line so we can see the rotation
    line(0, 0, radius, 0);
    popMatrix();
  }

  // A method just to draw the circle associated with wandering
  void drawWanderStuff(PVector position, PVector circle, PVector target, float rad) {
    stroke(255);
    noFill();
    ellipseMode(RADIUS);
    ellipse(circle.x, circle.y, rad, rad);
    ellipse(target.x, target.y, 2, 2);
    line(position.x, position.y, circle.x, circle.y);
    line(circle.x, circle.y, target.x, target.y);
    line(position.x, position.y, target.x, target.y);
  }

  void makeBody(Vec2 posVecPixels, String _type, int _categoryBits, int _maskBits) {

    // Define a body
    BodyDef bd = new BodyDef();
    //bd.type = BodyType.DYNAMIC;
    if (_type == "DYNAMIC") {
      bd.type = BodyType.DYNAMIC;
    } else if (_type == "STATIC") {
      bd.type = BodyType.STATIC;
    }

    // Set its position
    bd.position = box2d.coordPixelsToWorld(posVecPixels);
    bd.fixedRotation = true; // no rotation!
    body = box2d.world.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(radius);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;

    fd.filter.categoryBits = _categoryBits;
    fd.filter.maskBits = _maskBits;
    // Parameters that affect physics

    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    body.createFixture(fd);

    body.setUserData(this);

    body.setLinearDamping(0.5f);
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }
}
