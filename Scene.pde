/***************************************************************************************************************************/
/* Author: Prof. Morales, Wyatt Zackowski                                                                                  */
/* Course: CPSC 220                                                                                                        */
/* Instructor: Prof. Morales                                                                                               */
/* Created: 2026-04-15                                                                                                     */
/* Due: 2026-05-10                                                                                                         */
/* Assignment: Project 4                                                                                                   */
/* File: Scene.pde                                                                                                         */
/* Description: The game scene that handles each room and all objects within those rooms, including the player and enemies */
/***************************************************************************************************************************/

import java.util.LinkedList;

class Scene 
{
  private int roomWidth;
  private int roomHeight;
  private WorldObject[][] room;
  private Direction entry;
  private Player player;
  private LinkedList<Actor> enemies;
  private HashMap<WorldObject, Position> positions;
  private HashMap<Direction, Position> doors;
  
  /****************************************/
  /* Constructor: public Scene()          */
  /* Parameters: none                     */
  /* Return: none                         */
  /* Description: Start new room creation */
  /****************************************/
  public Scene() 
  {
    //Construct Player Object and send entry direction to reset
    player = new Player(Direction.NORTH);
    reset(Direction.NORTH);
  }
  
  /**********************************************/
  /* Constructor: public Scene(JSONObject data) */
  /* Parameters: JSONObject data                */
  /* Return: none                               */
  /* Description: For loading data from JSON    */
  /**********************************************/
  public Scene(JSONObject json)
  {
    //Gets room dimensions from the data JSON file
    roomWidth = json.getInt("roomWidth");
    roomHeight = json.getInt("roomHeight");
    
    //Creates new room with dimensions from data
    room = new WorldObject[roomWidth][roomHeight];
    
    //Gets player postion from the data file
    player = new Player(json.getJSONObject("player"));
    Position playerPos = new Position(json.getInt("playerX"), json.getInt("playerY"), this);
    
    //Gets the direction the player entered from data
    entry = Direction.valueOf(json.getString("entry"));
    
    //Adds player to the room
    room[playerPos.getX()][playerPos.getY()] = player;
    positions.put(player, playerPos);
    
    //Gets the positons of the doors from data and adds them to the room
    for (Direction d : doors.keySet()) 
    {
      //Get position
      Position doorPos = new Position(json.getInt("doorX"), json.getInt("doorY"), this);
      //Add to room
      doors.put(d, doorPos);
    }
  }
  
  /**************************************************************************************/
  /* Method: private reset()                                                            */
  /* Parameters: Direction entry - The direction from which the player entered the room */
  /* Return: void                                                                       */
  /* Description: Resets the room to a random state                                     */
  /**************************************************************************************/
  private void reset(Direction entry) 
  {
    if (entry == null) 
    {
      return;
    }
    //----------------------------\\
    // TODO: COMPLETE THIS METHOD \\
    //----------------------------\\
    
    //Parameters for the room
    roomWidth = 10;
    roomHeight = 10;
    room = new WorldObject[roomWidth][roomHeight];
    
    //Parameters for entities and interactables
    enemies = new LinkedList<Actor>();
    positions = new HashMap<WorldObject, Position>();
    doors = new HashMap<Direction, Position>();
    
    //Place a door on each side of the room
    doors.put(Direction.NORTH, new Position(roomWidth/2, 0, this));
    doors.put(Direction.EAST, new Position(roomWidth, roomHeight/2, this));
    doors.put(Direction.SOUTH, new Position(roomWidth/2, roomHeight, this));
    doors.put(Direction.WEST, new Position(0, roomHeight/2, this));
    
    //Identify location of entry door
    Position entryDoor = doors.get(entry.inverse());
    Position playerPos = new Position(entryDoor.getX(), entryDoor.getY(), this);
    
    //Place player at the door they entered through.
    room[playerPos.getX()][playerPos.getY()] = player;
    positions.put(player, playerPos);
  }
  
  /****************************************************/
  /* Method: public serialize()                       */
  /* Parameters: none                                 */
  /* Return: JSONObject                               */
  /* Description: Serializes the entire scene state   */
  /****************************************************/
  public JSONObject serialize() 
  {
    //Create JSONObject for Scene.pde
    JSONObject json = new JSONObject();

    //Add the room Parameters to the JSONObject
    json.setInt("roomWidth", this.roomWidth);
    json.setInt("roomHeight", this.roomHeight);
    json.setString("entry", this.entry.name());

    //Add player position to the JSONObject
    Position playerPos = this.positions.get(this.player);
    json.setInt("playerX", playerPos.getX());
    json.setInt("playerY", playerPos.getY());
    
    //Add door positions to the JSONObject with a for loop
    for (Direction d : this.doors.keySet()) 
    {
      //Add the positions of each door
      Position dPos = this.doors.get(d);
      json.setInt(d.name()+"doorX", dPos.getX());
      json.setInt(d.name()+"doorY", dPos.getY());
    }
    
    return json;
  }

  /***********************************************************************************************/
  /* Method: private updateActions()                                                             */
  /* Parameters: Actor actor - The actor whose actions will be updated to reflect their validity */
  /* Return: void                                                                                */
  /* Description: Updates an actor's list of valid actions                                       */
  /***********************************************************************************************/  
  private void updateActions(Actor actor) 
  {
    for (Action action: Action.values()) 
    {
      actor.setActionValidity(action, this.isActionValid(actor, action));
    }
  }

  /********************************************************************************************/
  /* Method: public tryTurn()                                                                 */
  /* Parameters: void                                                                         */
  /* Return: boolean - Whether or not the state of the scene should be saved                  */
  /* Description: Tries to execute a single turn of game logic for the player and all enemies */
  /********************************************************************************************/
  public boolean tryTurn() 
  {
    // If the player is dead, reset the room
    if (this.player == null || this.player.getHealth() == 0) 
    {
      Direction[] directions = Direction.values();
      Direction direction = directions[int(random(directions.length))];
      this.player = new Player(direction);
      this.reset(direction);
    }

    // Get the player's action
    Action action = this.player.getAction();

    // If no action was chosen, do nothing
    if (action == null) 
    {
      return false;
    }

    // If the player attacked or entered a new room, save the game
    Position door = this.doors.get(action.direction);
    boolean save = action.isAttack || door != null && door.equals(this.positions.get(this.player)) && this.enemies.size() == 0;

    // If the action failed, do nothing
    if (!this.tryAction(this.player, action)) 
    {
      return false;
    }

    for (int i = 0; i < this.enemies.size(); ++i) 
    {
      Actor enemy = this.enemies.get(i);

      // Remove dead enemies
      if (enemy.getHealth() == 0) 
      {
        this.enemies.remove(i--);
        continue;
      }

      // Get the enemy's action
      this.updateActions(enemy);
      action = enemy.getAction();

      if (this.tryAction(enemy, action) && action.isAttack) 
      {
        // If the player died, reset the room and save the game
        if (player.getHealth() == 0) 
        {
          Direction[] directions = Direction.values();
          Direction direction = directions[int(random(directions.length))];
          this.player = new Player(direction);
          this.reset(direction);
          return true;
        }

        // If the enemy attacked, save the game
        save = true;
      }
    }
    this.updateActions(this.player);
    return save;
  }

  /**********************************************************************************************************/
  /* Method: private tryAction()                                                                            */
  /* Parameters: Actor  actor  - The actor performing the action Action action - The action being performed */
  /* Return: boolean - Whether or not the action succeeded                                                  */
  /* Description: Tries to execute an action on behalf of an actor                                          */
  /**********************************************************************************************************/
  private boolean tryAction(Actor actor, Action action) 
  {
    if (!isActionValid(actor, action)) 
    {
      return false;
    }

    Position position = this.positions.get(actor);

    if (position == null) 
    {
      return false;
    }

    // Get the position of the cell being targeted
    int x = position.getX() + action.direction.x;
    int y = position.getY() + action.direction.y;

    // Check if the player can enter a new room
    if (!action.isAttack && actor == this.player && action.direction != this.entry.inverse() && this.enemies.size() == 0) 
    {
      Position door = this.doors.get(action.direction);

      if (door != null && door.equals(position)) 
      {
        this.reset(action.direction);
        return true;
      }
    }

    // Check if the actor is facing a wall
    if (x < 0 || x >= this.roomWidth || y < 0 || y >= this.roomHeight) 
    {
      return false;
    }

    // Check if the actor can attack
    if (action.isAttack) 
    {
      boolean isActionValid = this.room[x][y] instanceof Actor && (actor == this.player || this.room[x][y] == this.player);
      if (isActionValid) 
      {
        Actor enemy = (Actor)this.room[x][y];

        if (enemy.getHealth() > 0) 
        {
          enemy.updateHealth(-actor.getDamage());
        } 
        else 
        {
          this.room[x][y] = null;
        }
      }
      return isActionValid;
    }

    // Check if the actor can interact with an interactable object
    if (actor == this.player && this.room[x][y] instanceof Interactable) {
      Interactable interactable = (Interactable)this.room[x][y];

      if (!interactable.interact(this.player)) {
        return false;
      }
    } else if (this.room[x][y] != null) {
      return false;
    }

    // Check if the actor can move
    this.room[x][y] = actor;
    this.room[position.getX()][position.getY()] = null;
    position.move(action.direction);
    return true;
  }

  /***********************************************************************************************************/
  /* Method: private isActionValid()                                                                         */
  /* Parameters: Actor  actor  - The actor performing the action, Action action - The action being performed */
  /* Return: boolean - Whether or not the action is valid                                                    */
  /* Description: Determines if an actor's action would be valid                                             */
  /***********************************************************************************************************/
  private boolean isActionValid(Actor actor, Action action) 
  {
    if (actor == null || action == null || actor.getHealth() == 0) 
    {
      return false;
    }

    Position position = this.positions.get(actor);
    
    if (position == null) 
    {
      return false;
    }

    // Get the position of the cell being targeted
    int x = position.getX() + action.direction.x;
    int y = position.getY() + action.direction.y;

    // Check if the player can enter a new room
    if (!action.isAttack && actor == this.player && action.direction != this.entry.inverse() && this.enemies.size() == 0) 
    {
      Position door = this.doors.get(action.direction);

      if (door != null && door.equals(position)) 
      {
        return true;
      }
    }

    // Check if the actor is facing a wall
    if (x < 0 || x >= this.roomWidth || y < 0 || y >= this.roomHeight) 
    {
      return false;
    }

    // Check if the actor can attack
    if (action.isAttack) 
    {
      return this.room[x][y] instanceof Actor && (actor == this.player || this.room[x][y] == this.player);
    }

    // Check if the actor can move
    return this.room[x][y] == null || this.room[x][y] instanceof Interactable && actor == this.player;
  }

  /*************************************************************/
  /* Method: public getRoomWidth()                             */
  /* Parameters: void                                          */
  /* Return: int - The width of the room, in number of columns */
  /* Description: Returns the width of the room                */  
  /*************************************************************/
  public int getRoomWidth() 
  {
    return roomWidth;
  }

  /*************************************************************/
  /* Method: public getRoomHeight()                            */
  /* Parameters: void                                          */
  /* Return: int - The Height of the room, in number of rows   */
  /* Description: Returns the height of the room               */  
  /*************************************************************/
  public int getRoomHeight() 
  {
    return roomHeight;
  }

  /*************************************************************/
  /* Method: public keyPressed()                               */
  /* Parameters: void                                          */
  /* Return:void                                               */
  /* Description: Passes events of KeyPressed to the player    */  
  /*************************************************************/
  public void keyPressed() 
  {
    if (this.player != null) 
    {
      this.player.keyPressed();
    }
  }

  /*************************************************************/
  /* Method: public KeyReleased()                              */
  /* Parameters: void                                          */
  /* Return:void                                               */
  /* Description: Passes events of KeyReleased to the player   */  
  /*************************************************************/
  public void keyReleased() 
  {
    if (this.player != null) 
    {
      this.player.keyReleased();
    }
  }

  /********************************/
  /* Method: public draw()        */
  /* Parameters: void             */
  /* Return: void                 */
  /* Description: Draws the scene */
  /********************************/
  public void draw() 
  {
    //Determine the floor size
    float size = min((float)width / (this.roomWidth + 2), (float)height / (this.roomHeight + 2));

    //----------------------------\\
    // TODO: COMPLETE THIS METHOD \\
    //----------------------------\\
    
    //Center the entire grid
    float offsetX = (width - (roomWidth + 2) * size) / 2f;
    float offsetY = (height - (roomHeight + 2) * size) / 2f;
    
    //Nested for loop for room dimensions
    for (int x = 0; x < this.roomWidth; x++) 
    {
      for (int y = 0; y < this.roomHeight; y++) 
      {
        //Get tile positions 
        float tileX = offsetX + (x + 1) * size;
        float tileY = offsetY + (y + 1) * size;
        
        //Set draw parameters
        stroke(40);           
        strokeWeight(2);
    
        //Draw tiles
        rect(tileX, tileY, size, size);
      }
    }
    
    //Draw a door on each wall
    for (Direction d : doors.keySet()) 
    {
      //Get door positions
      float doorX = json.getInt("doorX");
      float doorY = json.getInt("doorY");
      
      //Set draw parameters
      fill(0);
      
      //Determines if the door should be drawn vertically or horizontally
      if(d == NORTH || d==SOUTH)
      {
        rect(doorX, doorY, 10,5);
      }
      else
      {
        rect(doorX, dooY, 5,10);
      }
    
  }
}
