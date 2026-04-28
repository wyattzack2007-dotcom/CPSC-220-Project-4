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
  /* Description: Constructs a enemy in a new room  */
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
  
  public void draw() {
    super.draw(); 
    
    //draw enemy
  }
  
  public Action getAction() {
    
  }
}
