public class Enemy extends Actor
{
  public Enemy(int health, int damage, Direction facing)
  {
    super(health, damage, facing);
  }
  
  public Enemy(JSONObject obj)
  {
    super(obj);
  }
  
  void draw(float size)
  {
    super.draw(size);
    fill(100, 102, 0);
    circle(size/2, size/2, size/1.6);
  }
  
  public Action getAction()
  {
    
    //attack
    for(Action atk : Action.values()) { //loops through list of actions
      if(atk.isAttack && getActionValidity(atk)) { //checks attack validity
      System.out.println("test");
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
  
  public JSONObject serialize() {
    JSONObject object = super.serialize();
    object.setString("className", "Enemy");
    return object;
  }
}
