/****************************************************/
/*      Author: Bella Olmo                          */
/*      Course: CPSC 220                            */
/*  Instructor: Prof. Morales                       */
/*     Created: 2026-04-15                          */
/*         Due: 2026-05-10                          */
/*  Assignment: Project 4                           */
/*        File: Enemy.pde                           */
/* Description: The enemy the player must fight     */
/****************************************************/

class Enemy extends Actor {
  
  /**************************************************/
  /* Constructor: public Enemy()                    */
  /*  Parameters: Direction direction - The         */
  /*              direction to face                 */
  /* Description: Constructs a enemy in a new room  */
  /**************************************************/
  public Enemy(Direction direction) { 
    super(100, 4, direction); //100 health, 4 damage
  }
  
  /**************************************************/
  /* Constructor: public Enemy()                    */
  /*  Parameters: JSONObject object - How the       */
  /*              data is saved                     */
  /* Description: Constructs enemy from JSON data   */
  /**************************************************/
  public Enemy(JSONObject object) {
    super(object);
  }
  
  /**************************************************/
  /* Constructor: public serialize()                */
  /*  Parameters: JSONObject - JSON serialization   */
  /*              of the object                     */
  /* Description: Serializes the JSON object        */
  /**************************************************/
  public JSONObject serialize() {
    JSONObject object = super.serialize();
    object.setString("className", "Enemy");
    return object;
  }
  
  /**************************************************/
  /* Constructor: draw()                            */
  /*  Parameters: Void                              */
  /*      Return: Void                              */
  /* Description: Draws the enemy                   */
  /**************************************************/
  public void draw() {    
    //drawing enemy
    pushMatrix();
      ellipseMode(CENTER);
      rectMode(CENTER);
        
      push();
        noStroke();
        fill(100);
        ellipse(0,5,65,65); //outer circle
      pop();
      
      //base structure
      push();
        fill(255);
        ellipse(0,0,50,35); //head
        rect(0,20,7,20); //jaw middle
        rect(-10,20,7,20); //jaw left
        rect(10,20,7,20); //jaw right
      pop();
      
      //face features
      push();
        fill(0);
        ellipse(-10,-5,10,10); //left eye
        ellipse(10,-5,10,10); //right eye
      
        ellipse(0,5,3,5); //nose long
        ellipse(0,7,5,3); //nose bottom part
      pop();
    popMatrix();
    
    super.draw(); //draws healthbar
  }
  
  
  /*********************************************************/
  /*      Method: public getAction()                       */
  /*  Parameters: void                                     */
  /*      Return: Action - The selected action to perform  */
  /* Description: Selects an action to perform             */
  /*********************************************************/
  public Action getAction() {
    //attack
    for(Action atk : Action.values()) { //loops through list of actions
      if(atk.isAttack && getActionValidity(atk)) { //checks attack validity
      this.facing = atk.direction;
        return atk; //attacks if possible
      }
    }
      
      //movement array to randomize
      Action[] move = {
        Action.MOVE_NORTH,
        Action.MOVE_SOUTH,
        Action.MOVE_EAST,
        Action.MOVE_WEST
      };
      
      //movement randomization
      for(int i = 0; i < 4; i++) { 
        Action movement = move[(int)random(4)];
        if(getActionValidity(movement)) {
          this.facing = movement.direction; //change facing direction of enemy
          return movement; //move
        }
      }
    return null; //removes error
  }
}
