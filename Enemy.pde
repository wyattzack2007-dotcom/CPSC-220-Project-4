/**
 *      Author: Patrick Walter, 
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Enemy.pde
 * Description: Handles the Enemy
 */
public class Enemy extends Actor
{
  public Action lastAction; //last movement action for ai
  
  /**
   * Constructor: public Enemy()
   *  Parameters: int health - the health of the enemy, int damage - The damage of the enemy, Direction direction - The direction to face
   * Description: Constructs an enemy in a new room
   */
  public Enemy(int health, int damage, Direction facing)
  {
    super(health, damage, facing);
  }
  
  /**
   * Constructor: public Enemy()
   * Parameters: JSONObject obj - Saved Enemy information
   * Description: Constructs an enemy in a new room based on save data
   */
  public Enemy(JSONObject obj)
  {
    super(obj);
  }

  /**
   *      Method: public getAction()
   *  Parameters: none
   *      Return: Action atk/movement - the action of the enemy
   * Description: Gets enemy Action
   */
  public Action getAction()
  {
    
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
     
      Action movement;
      
      //loop while we don't have a valid action
      while (true)
      {
        int weight = (int)random(2); //weight for continuing in set direction
        if (weight == 1 && lastAction != null && !lastAction.isAttack)
        {
          movement = lastAction; //move in last direction
        }
        else
        {
           movement = move[(int)random(4)]; //choose random direction
           lastAction = movement; //set new last direction
        }
          if(getActionValidity(movement)) {
            this.facing = movement.direction; //change facing direction of enemy
            return movement; //move
        }
      }
  }
  
    /**
   *      Method: public serialize()
   *  Parameters: void
   *      Return: JSONObject - A JSON serialization of the object
   * Description: Serializes the object to JSON
   */
  public JSONObject serialize() {
    JSONObject object = super.serialize();
    object.setString("className", "Enemy"); //save class name
    return object;
  }
  
  /*
    Method: draw()
    Parameters: float size, size of the grid
    Return: none
    Description: draws the enemy
   */  
  void draw(float size)
  {
    super.draw(size); //draw health bar
    
    //center drawing
    translate(size/2, size/2);
    
    //rotate
    super.getRotation();
    
    //Create eye shape
    fill(255, 255, 255);
    circle(0, 0, size/1.6);
    fill(255, 0, 0);
    ellipse(0, size/5, size/2, size/5); 
    fill(0, 0, 0);
    ellipse(0, size/4, size/5, size/7);
  }
    
}
