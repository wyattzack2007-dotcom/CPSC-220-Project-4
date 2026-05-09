public class Sword extends Interactable {
  private int damageAdder;
  PImage img;
  public Sword()
  {
    damageAdder = 10;
    img = loadImage("data/sword.png");
  }
  public Sword(JSONObject data)
  {
    damageAdder = data.getInt("DamageAdder");
  }
  
  public boolean interact(Player player)
  {
    int currDamage = player.getDamage();
    player.setDamage(currDamage+damageAdder);
    player.addInventoryItem(this);
    return true;
  }
  
  public void draw(float size)
  {
    img.resize(0, (int)size);
    image(img, 0, 0);
  }
  
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setString("className", "Sword");
    obj.setInt("DamageAdder", damageAdder);
    return obj;
  }
  
}
