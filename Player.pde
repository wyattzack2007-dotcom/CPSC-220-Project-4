/**
 *      Author: Prof. Morales, Patrick Walter
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Player.pde
 * Description: A user-controlled player actor
 */

class Player extends Actor {
  private char nextKey;
  private HashMap<Character, Boolean> debounce;
  private ArrayList<Interactable> inventory;
  private Sword equippedSword;
  PImage img;

  /**
   * Constructor: public Player()
   *  Parameters: Direction direction - The direction to face
   * Description: Constructs a player in a new room
   */

  public Player(Direction direction) {
    super(100, 10, direction);
    this.nextKey = '\0';
    inventory = new ArrayList<>();
    this.debounce = new HashMap<Character, Boolean>();
    img = loadImage("data/sword.png");
    this.equippedSword = null;
  }

  /**
   * Constructor: public Player()
   *  Parameters: JSONObject object - A JSON serialization of the player
   * Description: Constructs a player from JSON save data
   */

  public Player(JSONObject object) {
    super(object);
    this.nextKey = '\0';
    this.debounce = new HashMap<Character, Boolean>();
    img = loadImage("data/sword.png");
    inventory = new ArrayList<>();
    JSONArray inv = object.getJSONArray("Inventory");
    for (int i = 0; i < inv.size(); i++)
    {
      JSONObject item = inv.getJSONObject(i);
      if (item.getString("className").equals("Sword"))
      {
        Sword sword = new Sword(item);
        inventory.add(sword);
        equipSword(sword); 
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
    JSONArray inv = new JSONArray();
    object.setString("className", "Player");
    int i = 0;
    for (Interactable item : inventory)
    {
      inv.setJSONObject(i, item.serialize());
      i++;
    }
    object.setJSONArray("Inventory", inv);
    return object;
  }

  /**
   *      Method: public getAction()
   *  Parameters: void
   *      Return: Action - The selected action to perform
   * Description: Selects an action to perform
   */

  public Action getAction() {
    char currKey = this.nextKey;
    this.nextKey = '\0';
    Action action = null;

    // Convert key to action
    switch (currKey) {
    case 'W':
      this.facing = Direction.NORTH;
      action = Action.MOVE_NORTH;
      break;

    case 'S':
      this.facing = Direction.SOUTH;
      action = Action.MOVE_SOUTH;
      break;

    case 'D':
      this.facing = Direction.EAST;
      action = Action.MOVE_EAST;
      break;

    case 'A':
      this.facing = Direction.WEST;
      action = Action.MOVE_WEST;
      break;

    case ' ':
      switch (this.facing) {
      case NORTH:
        action = Action.ATTACK_NORTH;
        break;

      case SOUTH:
        action = Action.ATTACK_SOUTH;
        break;

      case EAST:
        action = Action.ATTACK_EAST;
        break;

      case WEST:
        action = Action.ATTACK_WEST;
        break;
      }

      break;
    }
    
    if (action != null && action.isAttack) {
      onAttack();
    }
    
    // Check if the action can be performed
    System.out.println(getActionValidity(action));
    return getActionValidity(action) ? action : null;
    
    
  }
  
    /**
   *      Method: public addInventoryItem()
   *  Parameters: Interactable item - equipable item
   *      Return: none
   * Description: adds equipable item to inventory if item is not already in it
   */
  public void addInventoryItem(Interactable item)
  {
    if(inventory.isEmpty() || inventory.stream().noneMatch(i -> i.getClass().equals(item.getClass())))
    {
      if (item instanceof Sword) {
      Sword sword = (Sword) item;
      inventory.add(sword);
      equipSword(sword);           // Auto-equip sword when picked up
      } 
      else if (!inventory.contains(item)) {
      inventory.add(item);
      }
    }
  }
  
    /**
   *      Method: public removeInventoryItem()
   *  Parameters: Interactable item - equipable item
   *      Return: none
   * Description: removes equipable item
   */
   public void removeInventoryItem(Interactable item) {
    inventory.remove(item);
    if (item == equippedSword) {
      equippedSword = null;
    }
  }
  
   /**
   *      Method: public equipSword()
   *  Parameters: Sword sword
   *      Return: none
   * Description: sets the equip sword variable
   */
  public void equipSword(Sword sword) {
    this.equippedSword = sword;
  }
  
   /**
   *      Method: public getEquippedSword()
   *  Parameters: void
   *      Return: equippedSword
   * Description: gets the value of equipped sword
   */
  public Sword getEquippedSword() {
    return equippedSword;
  }
  
  /**
   *      Method: public onAttack()
   *  Parameters: void
   *      Return: none
   * Description: determins if the attack was with a sword
   */
  public void onAttack() {
    if (equippedSword != null) {
      boolean success = equippedSword.useOnAttack(this);
      if (!success) {
        equippedSword = null; 
      }
    }
  }
  
  /**
   *      Method: public keyPressed()
   *  Parameters: void
   *      Return: void
   * Description: Handles key release events with debouncing
   */

  public void keyPressed() {
    // Convert to uppercase
    char pressed = Character.toUpperCase(key);

    if ("WASD ".indexOf(pressed) != -1 && !debounce.getOrDefault(pressed, false)) {
      debounce.put(pressed, true);
      nextKey = pressed;
    }
  }

  /**
   *      Method: public keyReleased()
   *  Parameters: void
   *      Return: void
   * Description: Handles key release events with debouncing
   */

  public void keyReleased() {
    // Convert to uppercase
    char released = Character.toUpperCase(key);

    if (debounce.getOrDefault(released, false)) {
      debounce.put(released, false);
    }
  }
  
    /*
    Method: draw()
    Parameters: float size, size of the grid
    Return: none
    Description: draws the Player
   */  
  public void draw(float size)
  {
    super.draw(size); //draw health bar
    translate(size/2, size/2); //center
    super.getRotation(); //rotate
     pushMatrix();
      ellipseMode(CENTER);
      rectMode(CENTER);
      
      noStroke();
      fill(100);
      ellipse(0,0,size/1.5,size/1.5); //outer circle
      
      //base structure
      fill(255);
      ellipse(0,0,size/2,size/2); //head
      
      //face features
      fill(0);
      ellipse(-10,0,size/10,size/10); //left eye
      ellipse(10,0,size/10,size/10); //right eye
      
      //hat
      rect(0,-size/4,size/2,size/5);
      
      
    popMatrix();
    drawItems(size); //draw any equiped items
  }
  
    /*
    Method: drawItems()
    Parameters: float size, size of the grid
    Return: none
    Description: draws any equipped items
   */  
  public void drawItems(float size)
  {
    //rotate item
    rotate(PI);
    //iterate through inventory
    for (Interactable item : inventory) 
    {
      //check if equipped item is a sword
      if (item instanceof Sword)
      {
        //draw it
        img.resize(0, (int)size/2);
        image(img, -size/2, -size/2);
      }

    }   
  }
  
}
