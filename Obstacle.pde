/**
 *      Author: Patrick Walter, 
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Obstacle.pde
 * Description: Handles the obstacle
 */

public class Obstacle extends WorldObject
{
  /**
   * Constructor: public Player()
   *  Parameters: none
   * Description: Constructs an obstacle
   */
  public Obstacle()
  {
    
  }
  
  /*
    Method: draw()
    Parameters: float size - size of grid
    Return: none
    Description: draws the obstacle
   */
  public void draw(float size)
  {
    fill(128, 128, 128);
    circle(size/2, size/2, size/1.6);
  }
  
    /**
   *      Method: public serialize()
   *  Parameters: void
   *      Return: JSONObject - A JSON serialization of the object
   * Description: Serializes the object to JSON
   */
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setString("className", "Obstacle");
    return obj;
  }
}
