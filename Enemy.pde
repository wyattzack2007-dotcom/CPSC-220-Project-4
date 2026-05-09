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
  
  public JSONObject serialize() {
    JSONObject object = super.serialize();
    object.setString("className", "Enemy");
    return object;
  }
}
