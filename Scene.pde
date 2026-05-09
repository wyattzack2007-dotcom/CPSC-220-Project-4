/**
 *      Author: Prof. Morales
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Scene.pde
 * Description: The game scene that handles each room
 *              and all objects within those rooms,
 *              including the player and enemies
 */

import java.util.LinkedList;
import java.util.Iterator;

class Scene {
  private int roomWidth;
  private int roomHeight;
  private WorldObject[][] room; 
  private Direction entry; 
  private Player player;
  private LinkedList<Actor> enemies;
  private HashMap<WorldObject, Position> positions;
  private HashMap<Direction, Position> doors;
  
  private int enemyDensity;
  private int obstacleDensity;
  private int interactableDensity;

  public Scene()
  {
    roomWidth = 10;
    roomHeight = 10;
    
    positions = new HashMap<>();
    doors = new HashMap<>();
    
    player = new Player(Direction.NORTH);
    room = new WorldObject[roomWidth][roomHeight];
    entry = Direction.NORTH;
    
    positions.put(player, new Position(5, 5, this));
    
    
    reset(entry);
  }
  
  private void addDoors()
  {
    doors.put(Direction.NORTH, new Position((int)random(roomWidth),0, this));
    doors.put(Direction.WEST, new Position(0, (int)random(roomHeight), this)); 
    doors.put(Direction.SOUTH, new Position((int)random(roomWidth), roomHeight-1, this));
    doors.put(Direction.EAST, new Position(roomWidth-1, (int)random(roomHeight), this));
  }
  
  public Scene(JSONObject data)
  {
    roomWidth = data.getInt("RoomWidth");
    roomHeight = data.getInt("RoomHeight");
    room = new WorldObject[roomWidth][roomHeight];
 
    entry = Direction.valueOf(data.getString("Entry"));
    
    positions = new HashMap<>();
    doors = new HashMap<>();
    enemies = new LinkedList<>();
    
    loadPositions(data.getJSONObject("Positions"));
    loadDoors(data.getJSONObject("Doors"));
    loadRoom();
  }
 
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setInt("RoomWidth", roomWidth);
    obj.setInt("RoomHeight", roomHeight);
    obj.setString("Entry", entry.name());
    obj.setJSONObject("Doors", serializeDoors());
    obj.setJSONObject("Positions", serializePositions());
    return obj;
  }
  
  private JSONObject serializePositions()
  {
    JSONObject worldObjects = new JSONObject();
    JSONArray objects = new JSONArray();
    JSONArray objPos = new JSONArray();
    if (positions.equals(null))
      return null;
     positions.forEach((obj, pos) -> {
       objects.append(obj.serialize());
       objPos.append(pos.serialize());
     });
     worldObjects.setJSONArray("WorldObjects", objects);
     worldObjects.setJSONArray("ObjectPositions", objPos);
     return worldObjects;
  }
  
  private JSONObject serializeDoors()
  {
    JSONObject doorMap = new JSONObject();
    if (doors.equals(null))
      return null;
    doors.forEach((dir, pos) -> {
      doorMap.setJSONObject(dir.name(), pos.serialize());
    });    
    return doorMap;
  }
  
   private void loadPositions(JSONObject data)
  {
    String dataType;
    Position objPos;
    JSONObject JSONObj;
    WorldObject worldObj = null;
    JSONArray objects = data.getJSONArray("WorldObjects"); 
    JSONArray objPositions = data.getJSONArray("ObjectPositions");
    for (int i = 0; i < objects.size(); i++)
    {
      JSONObj = objects.getJSONObject(i);
      dataType = JSONObj.getString("className");
      if (dataType.equals("Player"))
      {
        worldObj = new Player(JSONObj);
        player = (Player)worldObj;
      }
      if (dataType.equals("Enemy"))
      {
        worldObj = new Enemy(JSONObj);
        enemies.add((Enemy)worldObj);
      }
      objPos = new Position(objPositions.getJSONObject(i), this);
      positions.put(worldObj, objPos);
    } 
   }
  
  private void loadDoors(JSONObject data)
  {
    Iterator<String> keys = data.keyIterator();
    while(keys.hasNext())
    {
      String key = keys.next();
      Position pos = new Position(data.getJSONObject(key), this);
      doors.put(Direction.valueOf(key), pos);
    }
  }
  
  private void loadRoom()
  {
     positions.forEach((obj, pos) -> {
       room[pos.getX()][pos.getY()] = obj;
     });
  }

  /**
   *      Method: private reset()
   *  Parameters: Direction entry - The direction from which
   *                                the player entered the room
   *      Return: void
   * Description: Resets the room to a random state
   */

  private void reset(Direction entry) {  
    if (entry == null)
      return;
    this.entry = player.facing;
    roomHeight = (int)random(5,15);
    roomWidth = (int)random(5,15);
    room = new WorldObject[roomWidth][roomHeight];
    positions = new HashMap<>();
    addDoors();
    Position newPlayerPos = doors.get(player.facing.inverse());
    newPlayerPos = newPlayerPos.clone();
    positions.put(player, newPlayerPos);
    newEntities(positions);
    enemies = addEnemies(positions);
    loadRoom();
  }
  

  
  private LinkedList<Actor> addEnemies(HashMap<WorldObject, Position> roomObjects)
  {
    LinkedList<Actor> enemies = new LinkedList<>();
    roomObjects.forEach((obj, pos) -> {
      if (obj instanceof Enemy) 
        enemies.add((Actor)obj);
    });
    return enemies;
  }
  
  private void newEntities(HashMap<WorldObject, Position> objMap)
  {
    int randomX;
    int randomY;
    enemyDensity = 1;
    obstacleDensity = 4;
    interactableDensity = 3;
    for (int i = 0; i < enemyDensity; i++)
    {
      randomX = (int)random(roomWidth);
      randomY = (int)random(roomHeight);
      Enemy enemy = new Enemy(5, 5, Direction.NORTH);
      objMap.put(enemy, new Position(randomX, randomY, this));
    }
    
    
    
  }
  

  /**
   *      Method: private updateActions()
   *  Parameters: Actor actor - The actor whose actions will be
   *                            updated to reflect their validity
   *      Return: void
   * Description: Updates an actor's list of valid actions
   */

  private void updateActions(Actor actor) {
    for (Action action: Action.values()) {
      actor.setActionValidity(action, this.isActionValid(actor, action));
    }
  }

  /**
   *      Method: public tryTurn()
   *  Parameters: void
   *      Return: boolean - Whether or not the state of
   *                        the scene should be saved
   * Description: Tries to execute a single turn of game
   *              logic for the player and all enemies
   */

  public boolean tryTurn() {
    // If the player is dead, reset the room    
    if (this.player == null || this.player.getHealth() == 0) {
      Direction[] directions = Direction.values();
      Direction direction = directions[int(random(directions.length))];
      this.player = new Player(direction);
      this.reset(direction);
    }
    

    // Get the player's action
    Action action = this.player.getAction();

    // If no action was chosen, do nothing
    if (action == null) {
      return false;
    }

    // If the player attacked or entered a new room, save the game
    Position door = this.doors.get(action.direction);
    boolean save = action.isAttack || door != null && door.equals(this.positions.get(this.player)) && this.enemies.size() == 0;
    

    // If the action failed, do nothing
    if (!this.tryAction(this.player, action)) {
      return false;
    }

    for (int i = 0; i < this.enemies.size(); ++i) {
      Actor enemy = this.enemies.get(i);

      // Remove dead enemies
      if (enemy.getHealth() == 0) {
        this.enemies.remove(i--);
        continue;
      }

      // Get the enemy's action
      this.updateActions(enemy);
      action = enemy.getAction();

      if (this.tryAction(enemy, action) && action.isAttack) {
        // If the player died, reset the room and save the game
        if (player.getHealth() == 0) {
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

  /**
   *      Method: private tryAction()
   *  Parameters: Actor  actor  - The actor performing the action
   *              Action action - The action being performed
   *      Return: boolean - Whether or not the action succeeded
   * Description: Tries to execute an action on behalf of an actor
   */

  private boolean tryAction(Actor actor, Action action) {
    if (!isActionValid(actor, action)) {
      return false;
    }
    
    Position position = this.positions.get(actor);


    if (position == null) {
      return false;
    }

    // Get the position of the cell being targeted
    int x = position.getX() + action.direction.x;
    int y = position.getY() + action.direction.y;

    // Check if the player can enter a new room
    if (!action.isAttack && actor == this.player && action.direction != this.entry.inverse() && this.enemies.size() == 0) {
      Position door = this.doors.get(action.direction);
      if (door != null && door.equals(position)) {
        this.reset(action.direction);
        return true;
      }
    }

    // Check if the actor is facing a wall
    if (x < 0 || x >= this.roomWidth || y < 0 || y >= this.roomHeight) {
      return false;
    }

    // Check if the actor can attack
    if (action.isAttack) {
      boolean isActionValid = this.room[x][y] instanceof Actor && (actor == this.player || this.room[x][y] == this.player);

      if (isActionValid) {
        Actor enemy = (Actor)this.room[x][y];

        if (enemy.getHealth() > 0) {
          enemy.updateHealth(-actor.getDamage());
        } else {
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

  /**
   *      Method: private isActionValid()
   *  Parameters: Actor  actor  - The actor performing the action
   *              Action action - The action being performed
   *      Return: boolean - Whether or not the action is valid
   * Description: Determines if an actor's action would be valid
   */

  private boolean isActionValid(Actor actor, Action action) {
    if (actor == null || action == null || actor.getHealth() == 0) {
      return false;
    }
    Position position = this.positions.get(actor);

    if (position == null) {
      return false;
    }

    // Get the position of the cell being targeted
    int x = position.getX() + action.direction.x;
    int y = position.getY() + action.direction.y;

    // Check if the player can enter a new room
    if (!action.isAttack && actor == this.player && action.direction != this.entry.inverse() && this.enemies.size() == 0) {
      Position door = this.doors.get(action.direction);

      if (door != null && door.equals(position)) {
        return true;
      }
    }
    
    // Check if the actor is facing a wall
    if (x < 0 || x >= this.roomWidth || y < 0 || y >= this.roomHeight) {
      return false;
    }
    // Check if the actor can attack
    if (action.isAttack) {
      return this.room[x][y] instanceof Actor && (actor == this.player || this.room[x][y] == this.player);
    }

    // Check if the actor can move
    return this.room[x][y] == null || this.room[x][y] instanceof Interactable && actor == this.player;
  }

  /**
   *      Method: public getRoomWidth()
   *  Parameters: void
   *      Return: int - The width of the room, in number of columns
   * Description: Returns the width of the room
   */

  public int getRoomWidth() {
    return roomWidth;
  }

  /**
   *      Method: public getRoomHeight()
   *  Parameters: void
   *      Return: int - The height of the room, in number of rows
   * Description: Returns the height of the room
   */

  public int getRoomHeight() {
    return roomHeight;
  }

  /**
   *      Method: public keyPressed()
   *  Parameters: void
   *      Return: void
   * Description: Passes key press events to the player
   */

  public void keyPressed() {
    if (this.player != null) {
      this.player.keyPressed();
    }
  }

  /**
   *      Method: public keyReleased()
   *  Parameters: void
   *      Return: void
   * Description: Passes key release events to the player
   */

  public void keyReleased() {
    if (this.player != null) {
      this.player.keyReleased();
    }
  }

  /**
   *      Method: public draw()
   *  Parameters: void
   *      Return: void
   * Description: Draws the scene
   */

  public void draw() {
    // Determine the floor size
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
        if ((x % 2 == 0 && y % 2 == 1) || (x % 2 == 1 && y % 2 == 0))
          fill(153);
        else
          fill(255);
        strokeWeight(2);
    
        //Draw tiles
        push();
        translate(tileX, tileY);
        rect(0, 0, size, size);
        if (room[x][y] != null)
        {
          room[x][y].draw(size);
        }
        pop();
        
      }
    }
    drawDoors(offsetX, offsetY, size);
  }
  
  private void drawDoors(float offsetX, float offsetY, float size)
  {
    doors.forEach((dir, pos) -> {
      int x = pos.getX();
      int y = pos.getY();
      float positionX = offsetX + (x+1) * size;
      float positionY = offsetY + (y+1)* size;
      push();
      if (dir == entry.inverse())
        fill (255, 0, 0);
      else
        fill (0, 255, 0);
      translate(positionX, positionY);
      switch(dir)
      {
        case NORTH:
          rect(0, -size, size, size);
          break;
        case SOUTH:
          rect(0, size, size ,size);
          break;
        case EAST:
          rect(size, 0, size, size);
          break;
        case WEST:
          rect(-size, 0, size, size);
          break;
      }
      pop();
      
    });    
    
  }
  
}
