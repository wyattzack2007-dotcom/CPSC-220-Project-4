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
  private WorldObject[][] room; //save done
  private Direction entry; //save
  private Player player;
  private LinkedList<Actor> enemies;
  private HashMap<WorldObject, Position> positions;
  private HashMap<Direction, Position> doors; //save

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
    doors.put(Direction.NORTH, new Position(1, 1, this));
    
    reset(entry);
  }
  public Scene(JSONObject data)
  {
    positions = new HashMap<>();
    doors = new HashMap<>();
    enemies = new LinkedList<>();
    loadRoom(data.getJSONArray("Room"));
    entry = Direction.valueOf(data.getString("Entry"));
    loadDoors(data.getJSONObject("Doors"));
  }
  
  private void loadRoom(JSONArray data)
  {
    String dataType;
    JSONArray firstRow = data.getJSONArray(0);
    roomWidth = data.size();
    roomHeight = firstRow.size();
    room = new WorldObject[roomWidth][roomHeight];
    for (int i = 0; i < data.size(); i++)
    {
      JSONArray row = data.getJSONArray(i);
      for (int j = 0; j < row.size(); j++)
      {
        if (row.isNull(j))
          continue;      
        JSONObject obj = row.getJSONObject(j);
        WorldObject worldObj = null;
        if (obj.isNull("className"))
           continue;
        dataType = obj.getString("className");
        if (dataType.equals("Player"))
        {
          worldObj = new Player(obj);
          player = (Player)worldObj;
        }
        if (dataType.equals("Enemy"))
          worldObj = new Enemy(obj);
        room[i][j] = worldObj;
        System.out.println(i + " " + j);
        positions.put(worldObj, new Position(i, j, this));
        System.out.println(positions.get(worldObj).getX() + " " + positions.get(worldObj).getY());
       }
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
  
 
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setJSONArray("Room", serializeRoom());
    obj.setString("Entry", entry.name());
    obj.setJSONObject("Doors", serializeDoors());
    return obj;
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
  
  private JSONArray serializeRoom()
  {
    JSONArray master = new JSONArray();
    for (int i = 0; i < room.length; i++)
    {   
      JSONArray row = new JSONArray();
      for (int j = 0; j < room[i].length; j++)
      {
        if (room[i][j] != null)
        {
          JSONObject roomSpace = room[i][j].serialize();
          row.setJSONObject(j, roomSpace);
        }
        else
          row.setJSONObject(j, null);
      }
      master.setJSONArray(i, row);
    }
    return master;
    
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
    Position playerPos = positions.get(player);
    System.out.println(playerPos.getX());
    roomWidth = 10;
    roomHeight = 10;
    room = new WorldObject[roomWidth][roomHeight];
    positions = new HashMap<>();
    switch (entry)
    {
      case NORTH:
        playerPos = new Position(playerPos.getX(), roomHeight-1, this);
        break;
      case SOUTH:
        playerPos = new Position(playerPos.getX(), 0 , this);
        break;
      case EAST:
        playerPos = new Position(0, playerPos.getY(), this);
        break;
      case WEST:
        playerPos = new Position(roomWidth-1, playerPos.getY(), this);
        break;
    }
    positions.put(player, playerPos);
    newEntities(positions);
    enemies = addEnemies(positions);
    initializeRoom();
  }
  
  private void initializeRoom()
  {
    positions.forEach((obj, pos) -> {
      if (obj instanceof Player)
        room[pos.getX()][pos.getY()] = obj;
    });
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
    Enemy enemy = new Enemy(2, 2, Direction.NORTH);
    objMap.put(enemy, new Position(2, 2, this));
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
      return true;
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
        rect(tileX, tileY, size, size);
      }
    }
    
    //Draw a door on each wall
 
  }
}
