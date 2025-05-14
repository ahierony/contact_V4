// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// ContactListener to listen for collisions!

import org.jbox2d.callbacks.ContactImpulse;
import org.jbox2d.callbacks.ContactListener;
import org.jbox2d.collision.Manifold;
import org.jbox2d.dynamics.contacts.Contact;

class CustomListener implements ContactListener {
  CustomListener() {
  }

  Fixture f1;
  Fixture f2;
  // Get both bodies
  Body b1;
  Body b2;
  // Get our objects that reference these bodies
  Object o1;
  Object o2;

  // This function is called when a new collision occurs
  void beginContact(Contact cp) {

    // TODO Auto-generated method stub
    // Get both fixtures
    f1 = cp.getFixtureA();
    f2 = cp.getFixtureB();
    // Get both bodies
    b1 = f1.getBody();
    b2 = f2.getBody();
    // Get our objects that reference these bodies
    o1 = b1.getUserData();
    o2 = b2.getUserData();
     
     // If object 1 is a Box, then object 2 must be a particle
     
     if (o1.getClass() == PlayerSphere.class && o2.getClass() == VehicleSphere.class) {
      PlayerSphere ps = (PlayerSphere) o1;
      
      VehicleSphere vs = (VehicleSphere) o2;
        
      vs.wasTouched = true; // vehicle was touched
      
      //println("vehicle was touched by player");
   
    } 
    // If object 2 is a Box, then object 1 must be a particle
    else if (o1.getClass() == VehicleSphere.class && o2.getClass() == PlayerSphere.class) {
      PlayerSphere ps = (PlayerSphere) o2;
      VehicleSphere vs = (VehicleSphere) o1;
        
      vs.wasTouched = true; // vehicle was touched
      
      //println("vehicle was touched by player");
      
    } 
    
  }


  void endContact(Contact cp) {
    
    
  }

  void preSolve(Contact contact, Manifold oldManifold) {
    // TODO Auto-generated method stub
  }

  void postSolve(Contact contact, ContactImpulse impulse) {
    // TODO Auto-generated method stub
  }
}
