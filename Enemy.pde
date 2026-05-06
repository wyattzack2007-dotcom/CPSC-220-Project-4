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
  
  void draw()
  {
    super.draw();
  }
  
  public Action getAction()
  {
    return null;
  }
  
  public JSONObject serialize()
  {
    JSONObject obj = super.serialize();
    return obj;
  }
}
