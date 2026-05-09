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
    return null;
  }
  
  public JSONObject serialize() {
    JSONObject object = super.serialize();
    object.setString("className", "Enemy");
    return object;
  }
}
