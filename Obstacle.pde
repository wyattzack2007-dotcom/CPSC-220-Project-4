public class Obstacle extends WorldObject
{
  public Obstacle()
  {
    
  }  
  public void draw(float size)
  {
    fill(128, 128, 128);
    circle(size/2, size/2, size/1.6);
  }
  
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setString("className", "Obstacle");
    return obj;
  }
}
