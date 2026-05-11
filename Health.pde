/**
 *      Author: Patrick Walter
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Health.pde
 * Description: Handles the health interactable
                object
 */
public class Health extends Interactable {

  private int healthAdder; //damage to be added when sword is equipped
  
  /**
   * Constructor: public Health()
   *  Parameters: none
   * Description: Constructs a health item
   */
  public Health()
  {
    healthAdder = 10;
  }
  
  /**
   * Constructor: public Sword()
   *  Parameters: JSONObject data - saved sword data
   * Description: Constructs a sword based on save data
   */
  public Health(JSONObject data)
  {
    healthAdder = data.getInt("HealthAdder");
  }
  
  
  /**
   *      Method: public interact()
   *  Parameters: Player player - The player interacting with the object
   *      Return: boolean - Whether or not the interaction succeeded
   * Description: Attempts to interact with the object
   */
  public boolean interact(Player player)
  {
    player.updateHealth(healthAdder); //increase damage
    return true;
  }
  
  /*
    Method: draw()
    Parameters: float size, size of the grid
    Return: none
    Description: draws the sword in the room
   */  
  public void draw(float size)
  {
    fill(255, 0, 0);
    circle(size/2, size/2, size/1.6);
  }
  
    /**
   *      Method: public serialize()
   *  Parameters: void
   *      Return: JSONObject - A JSON serialization of the object
   * Description: Serializes the object to JSON
   */
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setString("className", "Health");
    obj.setInt("HealthAdder", healthAdder);
    return obj;
  }
  
}
