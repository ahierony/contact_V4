class PlayerSphere {

  int cB, mB, gI;
  Body body;

  float w, h;
  Vec2 posVecPixels;
  float bodyRadius; 
  color col;

  PlayerSphere(float _x, float _y, float _r, String type, int categoryBits, int maskBits) {

    bodyRadius = _r;
    cB = categoryBits;
    mB = maskBits;

    posVecPixels = new Vec2(_x, _y);  
    w = _r;
    h = _r;

    create(type);

    body.setUserData(this);

    col = color(175, 126);
  }

  Body create(String type) {
    // Make each individual body
    BodyDef bd = new BodyDef();
    if (type == "DYNAMIC") {
      bd.type = BodyType.DYNAMIC;
    } else if (type == "STATIC") {
      bd.type = BodyType.STATIC;
    }

    bd.position.set(box2d.coordPixelsToWorld(posVecPixels.x, posVecPixels.y));

    /*
    bd.linearDamping = 1f;
     bd.angularDamping = 0.3f;
     */
    bd.linearDamping = 1.0f;
    bd.angularDamping = 0.3f;

    body = box2d.createBody(bd);

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(bodyRadius);
    Vec2 offset = new Vec2(0, 0);
    offset = box2d.vectorPixelsToWorld(offset);
    cs.m_p.set(offset.x, offset.y);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = cs;

    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.1;
    fd.restitution = 0.1;

    // for collision avoidance
    fd.filter.categoryBits = cB; // who you are
    //fd.filter.categoryBits = CATEGORY_PLAYER;
    fd.filter.maskBits = mB; // who you collide with

    //fd.filter.groupIndex = GROUP_BLOB_SPHERES;

    //fd.filter.groupIndex = gI;

    // Finalize the body
    body.createFixture(fd);

    //body.createFixture(cs, 1.0);


    return body;
  }

  void update() {
    posVecPixels = box2d.getBodyPixelCoord(body);
  }


  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }


  void display() {
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(posVecPixels.x, posVecPixels.y);
    rotate(a);
    noFill();
    circle(0, 0, bodyRadius);
    popMatrix();
  }

  float velFriction(float origin, float dest, float coeff) {
    return (dest-origin)/coeff;
  }

  void applyColorWheel(int colorWheelAngle) {
    col = color(colorWheelAngle, 100, 100);
  }


  void applyLinearImpulse(float theta) {

    float t = theta;
    t *= -1;

    float mag = 100000;

    float dx = mag * cos(t);
    float dy = mag * sin(t);

    body.applyLinearImpulse( new Vec2(dx, dy), body.getPosition(), true);
  }


  void applyForce(float theta, float playerTheta, float force, boolean bothEyesLocked, boolean eyesAreInverted) {

    float t;

    if (!bothEyesLocked) {

      t = (-theta) + playerTheta;

      if (!eyesAreInverted) {
        t *= -1;
      }
    } else {

      t = theta;
      t *= -1;
    }

    float dx = force * cos(t);
    float dy = force * sin(t);


    body.applyForce( new Vec2(dx, dy), body.getWorldCenter());
  }

  void applyForce(Vec2 v) {
    body.applyForce(v, body.getWorldCenter());
  }


  // Change color when hit
  void change() {

    col = color(0, 100, 100);
  }
}
