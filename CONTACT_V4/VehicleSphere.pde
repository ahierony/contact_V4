class VehicleSphere {

  int cB, mB, gI;
  Body body;

  float w, h;
  Vec2 posVecPixels;
  float bodyRadius; 
  
  color red = color(255, 0, 0);
  color green = color(0, 255, 0);
  color blue = color(0, 0, 255);
  color col;

  boolean wasTouched;
  
  VehicleSphere(float _x, float _y, float _r, String type, int categoryBits, int maskBits) {

    bodyRadius = _r;
    cB = categoryBits;
    mB = maskBits;
  
    posVecPixels = new Vec2(_x, _y);  
    w = _r;
    h = _r;

    wasTouched = false;
  
    makeBody(type);

    col = color(175, 126);
  }

  void makeBody(String type) {
    // Make each individual body
    BodyDef bd = new BodyDef();
    if (type == "DYNAMIC") {
      bd.type = BodyType.DYNAMIC;
    } else if (type == "STATIC") {
      bd.type = BodyType.STATIC;
    }

    bd.fixedRotation = true; // no rotation!
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
    fd.filter.categoryBits = cB;
    fd.filter.maskBits = mB;

    // Finalize the body
    body.createFixture(fd);

    body.setUserData(this);
    
    body.setLinearDamping(0.5f);

  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }


  void display() {
    // Get its angle of rotation
    float a = body.getAngle();
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    fill(col);
     circle(0, 0, bodyRadius);
    popMatrix();
  }

  float velFriction(float origin, float dest, float coeff) {
    return (dest-origin)/coeff;
  }

  void applyLinearVelocity(Vec2 vel) {
    body.setLinearVelocity(vel);
  }

  void applyForce(Vec2 v) {
    body.applyForce(v, body.getWorldCenter());
  }

  // Change color when hit
  void change() {
    col = color(0, 100, 100);
  }
}
