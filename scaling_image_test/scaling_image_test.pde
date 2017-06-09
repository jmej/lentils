/**
 * Load and Display 
 * 
 * Images can be loaded and displayed to the screen at their actual size
 * or any other size. 
 */
int lentilSize = 1;
PImage redLentil;  // Declare variable "a" of type PImage

void setup() {
  size(1024, 768);
  // The image file must be in the data folder of the current sketch 
  // to load successfully
  redLentil = loadImage("blue_600.png");  // Load the image into the program  
}

void draw() {
  background(102);
  if (lentilSize < 600){
  // Displays the image at its actual size at point (0,0)
  // Displays the image at point (0, height/2) at half of its size
  for (int i = 0; i < 5; i++){
    image(redLentil, width/(i+1), height/(i+1), lentilSize, lentilSize);
  }
  lentilSize += 10;
  }else{
    lentilSize = 0;
  }
}