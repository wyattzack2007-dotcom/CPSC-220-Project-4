/**
 *      Author: Patrick Walter
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Sword.pde
 * Description: Handles the sword interactable
                object
 */
public class Sword extends Interactable {
  
  public int durability;
  private int damageAdder; //damage to be added when sword is equipped
  PImage img; //sword image
  
  /**
   * Constructor: public Sword()
   *  Parameters: none
   * Description: Constructs a sword
   */
  public Sword()
  {
    damageAdder = 10;
    durability = 50;
    img = loadImage("data/sword.png");
  }
  
  /**
   * Constructor: public Sword()
   *  Parameters: JSONObject data - saved sword data
   * Description: Constructs a sword based on save data
   */
  public Sword(JSONObject data)
  {
    damageAdder = data.getInt("DamageAdder");
  }
  
  
  /**
   *      Method: public interact()
   *  Parameters: Player player - The player interacting with the object
   *      Return: boolean - Whether or not the interaction succeeded
   * Description: Attempts to interact with the object
   */
  public boolean interact(Player player)
  {
    int currDamage = player.getDamage(); //get current player damage
    player.setDamage(currDamage+damageAdder); //increase damage
    player.addInventoryItem(this); //add sword to inventory to be displayed
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
    img.resize(0, (int)size);
    image(img, 0, 0);
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
    obj.setString("className", "Sword");
    obj.setInt("DamageAdder", damageAdder);
    return obj;
  }
  
}
