/***************************************************************************************************************************/
/* Author: Wyatt Zackowski                                                                                  */
/* Course: CPSC 220                                                                                                        */
/* Instructor: Prof. Morales                                                                                               */
/* Created: 2026-04-15                                                                                                     */
/* Due: 2026-05-10                                                                                                         */
/* Assignment: Project 4                                                                                                   */
/* File: Scene.pde                                                                                                         */
/* Description: adds obstacles to the  */
/***************************************************************************************************************************/

//Load Rock image to a variable
PImage img = loadImage("an-8-bit-retro-styled-pixel-art-illustration-of-a-dark-stone-rock-formation-free-png.webp");

abstract class Obstacle extends WorldObject
{
  public void obstacle()
  {}
  
  //Add the obstacle to the JSONObject
  public JSONObject serialize()
  {
    JSONObject obj = new JSONObject();
    obj.setString("Obstacle", "Rock");
    return obj;
  }
  
  //Add the rock to the screen
  public void draw() 
  {
    push();                        
    imageMode(CENTER);
    image(img, 0, 0, 2, 2);    
    pop();                     
  }
}
