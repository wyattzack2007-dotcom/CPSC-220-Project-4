/**
 *      Author: Patrick Walter, Wyatt Zackowski
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
 
  private int damageAdder; //damage to be added when sword is equipped
  private int maxDurability; //Sword durability
  private int currentDurability; //Current durability
  PImage img; //sword image
  
  /**
   * Constructor: public Sword()
   *  Parameters: none
   * Description: Constructs a sword
   */
  public Sword()
  {
    damageAdder = 10;
    maxDurability = 25;
    currentDurability = maxDurability;
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
    maxDurability = data.getInt("maxDurability", 25);
    currentDurability = data.getInt("currentDurability", maxDurability);
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
  
  /**
   *      Method: public useOnAttack()
   *  Parameters: Player player
   *      Return: boolean
   * Description: Removes sword if broken
   */
  public boolean useOnAttack(Player player) {
    if (currentDurability <= 0) {
      // Sword is broken
      player.setDamage(player.getDamage() - damageAdder); // remove bonus
      player.removeInventoryItem(this);                   // optional
      return false;
    }
    
    currentDurability--;
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
    obj.setInt("maxDurability", maxDurability);
    obj.setInt("currentDurability", currentDurability);
    return obj;
  }
  
   /*
    Method: getCurrentDurability()
    Parameters: void
    Return: none
    Description: returns current durability
   */  
  public int getCurrentDurability() {
    return currentDurability;
  }
  
   /*
    Method: getCurrentDurability()
    Parameters: void
    Return: none
    Description: returns max durability
   */ 
  public int getMaxDurability() {
    return maxDurability;
  }
  
   /*
    Method: getCurrentDurability()
    Parameters: void
    Return: none
    Description: returns if sword is broken
   */ 
  public boolean isBroken() {
    return currentDurability <= 0;
  }
}
