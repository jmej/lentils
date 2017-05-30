PShape redLentil;

void setup() {
  size(640, 360);
  // The file "bot1.svg" must be in the data folder
  // of the current sketch to load successfully
  redLentil = loadShape("red.svg");
} 

void draw(){
  background(102);
  shape(redLentil, 110, 90, 100, 100);  // Draw at coordinate (110, 90) at size 100 x 100
  shape(redLentil, 280, 40);            // Draw at coordinate (280, 40) at the default size
}