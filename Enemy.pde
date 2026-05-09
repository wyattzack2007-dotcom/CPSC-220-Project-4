public class Enemy extends Actor
{
  public Action lastAction;
  public Enemy(int health, int damage, Direction facing)
  {
    super(health, damage, facing);
  }
  
  public Enemy(JSONObject obj)
  {
    super(obj);
  }

  
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
      while (true)
      {
        int weight = (int)random(2);
        System.out.println("stuck");
        if (weight == 1 && lastAction != null && !lastAction.isAttack)
        {
          movement = lastAction;
        }
        else
        {
           movement = move[(int)random(4)];
           System.out.println(movement);
           lastAction = movement;
        }
          if(getActionValidity(movement)) {
            this.facing = movement.direction; //change facing direction of enemy
            return movement; //move
        }
      }
  }
  
  public JSONObject serialize() {
    JSONObject object = super.serialize();
    object.setString("className", "Enemy");
    return object;
  }
  
    
  void draw(float size)
  {
    super.draw(size);
    translate(size/2, size/2);
    getRotation();
    fill(255, 255, 255);
    circle(0, 0, size/1.6);
    fill(255, 0, 0);
    ellipse(0, size/5, size/2, size/5); 
    fill(0, 0, 0);
    ellipse(0, size/4, size/5, size/7);
  }
  
  private void getRotation()
  {
    switch(facing)
    {
      case NORTH:
        rotate(PI);
        break;
      case EAST:
        rotate(3*PI/2);
        break;
      case WEST:
       rotate(PI/2);
       break;
    }
  }
  
}
