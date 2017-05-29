
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

String[][] imageNames = {
                          {"yellow_200.png", "yellow_100.png", "yellow_150.png"},
                          {"blue_200.png", "blue_100.png", "blue_150.png"},
                          {"red_200.png", "red_100.png", "red_150.png"},
                          {"green_200.png", "green_100.png", "green_150.png"},
                          {"brown_200.png", "brown_100.png", "brown_150.png"},
                          {"orange_200.png", "orange_100.png", "orange_150.png"}
                        };

PImage[][] colors = new PImage[6][3];
PImage bg;
int[] lentilSizes = {50, 100, 150}; //needs to be the 3 sizes of lentils in px

int circlesToDraw = 0;

Lentil[][] lentils = new Lentil[6][10]; //each sub array will get filled with lentil instances
bgCircle[][] bgCircles = new bgCircle[6][10];

boolean[] triggers = new boolean[6];
boolean[] circleTriggers = new boolean[20];

int[] timers = new int[6];

int[][] screenColors =  {{249, 194, 10}, {38, 94, 172}, {193, 13, 11}, {37, 179, 75}, {120, 77, 41}, {225, 115, 37}};
int screenRed = 249;
int screenGreen = 194;
int screenBlue = 10;

long triggerTime = 0;
long triggerTimer = 0;

long screenTimer = 0; //30 fps means %900 gives 30 seconds

void setup (){
  oscP5 = new OscP5(this,12000);
  
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  oscP5.plug(this,"podium","/podium");
  
  bg = loadImage("m_backgrounds1.jpg");
  size (1920, 1080); // Size of background
  background (249,194,10); // Background color
  
  for (int c = 0; c < 6; c++){ //setup each color
    
    for (int i = 0; i < lentils[c].length; i++){
      lentils[c][i] = new Lentil(c, int((random(500)+300)), width, height, random(20), random(20));
      bgCircles[c][i] = new bgCircle(c, int((random(500)+300)), width-500, height-500, random(10), random(10));
    }
    
    for (int i = 0; i < 3; i++){
      String imageName = imageNames[c][i];
      colors[c][i] = loadImage(imageName);
    }
  }
  frameRate(30);
}

public void podium(float arg) { //OSC triggers
  println("### plug event method. received a message /podium.");
  println(" 1 floats received: "+arg);
  
  if (arg == 0.0) {
   retrigLentils(0);
  }
  if (arg == 1.0) {
   retrigLentils(1);
  }
  if (arg == 2.0) {
   retrigLentils(2);
  }
  if (arg == 3.0) {
   retrigLentils(3);
  }
  if (arg == 4.0) {
   retrigLentils(4);
  }
  if (arg == 5.0) {
   retrigLentils(5);
  }
  if (arg == 10.0){
    circlesToDraw++;
    triggerTimer = millis();
  }
}
 
void draw (){
  background (screenRed,screenGreen,screenBlue); // Background color
  //background(bg);
  println("circles = "+circlesToDraw);
  if (circlesToDraw > 5){
    circlesToDraw = 5; //max background circles
  }
  if ((screenTimer % 300) == 0){ //change screen color every 30 seconds
        int newScreenColor = int(random(5));
        screenRed = screenColors[newScreenColor][0];
        screenGreen = screenColors[newScreenColor][1];
        screenBlue = screenColors[newScreenColor][2];
  }
  
  for (int t = 0; t < circleTriggers.length; t++){ //NOT WORKING YET
    if (circleTriggers[t]){
      for (int c = 0; c < 6; c++){
        for (int i = 0; i < bgCircles[c].length; i++){
          bgCircles[c][i].move();
          bgCircles[c][i].display();
        }
      }
    }
  }
  for (int t = 0; t < triggers.length; t++){
    if (triggers[t]){
      for (int i = 0; i < lentils[t].length; i++){
        lentils[t][i].move();
        lentils[t][i].display();
      }
      
      if (timers[t] == 80){ //length of time lentils stay on screen
        //timers[t] = 0;
        //triggers[t] = false;
      }else{
        timers[t] ++;
      }
    }
      
  //println("redTimer is: "+timers[0]);
  }
  
  screenTimer++;
  
}

void retrigLentils(int lentilColor){
   triggers[lentilColor] = true;
    float newX = random(width);
    float newY = random(height);
    for (int i = 0; i < lentils[0].length; i++){
      lentils[lentilColor][i].lentilSize = int(random(3));
      lentils[lentilColor][i].x = newX - lentilSizes[lentils[lentilColor][i].lentilSize]; //retrigger all the lentils
      lentils[lentilColor][i].y = newY - lentilSizes[lentils[lentilColor][i].lentilSize];
      lentils[lentilColor][i].xspeed = random(-30, 30); // how do we eliminate the low numbers - maybe using abs?
      lentils[lentilColor][i].yspeed = random(-30, 30);
    }
    timers[lentilColor] = 0;
    //println("red trigger");
}

void keyPressed() {
  if (key == 'q') {
   retrigLentils(0);
  }
  if (key == 'w') {
   retrigLentils(1);
  }
  if (key == 'e') {
   retrigLentils(2);
  }
  if (key == 'r') {
   retrigLentils(3);
  }
  if (key == 't') {
   retrigLentils(4);
  }
  if (key == 'y') {
   retrigLentils(5);
  }
  
}


class Lentil {
  int lentilColor;
  int lentilSize;
  float x, y, xspeed, yspeed, oldx, oldy;
  
  //constructor
  Lentil(int col, int lsize, float xpos, float ypos, float xsp, float ysp){
    lentilColor = col;
    lentilSize = lsize;
    x = xpos;
    y = ypos;
    xspeed = xsp;
    yspeed = ysp;
    
  }
  void move() {
    y += yspeed;
    x += xspeed;
    //if ((y > (height - 80)) || (y < 80/2)) { //bouncing logic
    //  yspeed *= -1;
    //}
    //if ((x > (width - 80)) || (x <80/2)) {
    //  xspeed *= -1;
    //}
  }    
  void display(){
    
    image (colors[lentilColor][lentilSize], x, y);
    oldx = x; //log our last lentil
    oldy = y;
  }
}

class bgCircle {
  int bgCircleColor;
  int bgCircleSize;
  float x, y, xspeed, yspeed, oldx, oldy;
  
  //constructor
  bgCircle(int col, int lsize, float xpos, float ypos, float xsp, float ysp){
    bgCircleColor = col;
    bgCircleSize = lsize;
    x = xpos;
    y = ypos;
    xspeed = xsp;
    yspeed = ysp;
    
  }
  void move() {
    y += yspeed;
    x += xspeed;
    if ((y > (height - 80)) || (y < 80/2)) { //bouncing logic
      yspeed *= -1;
    }
    if ((x > (width - 80)) || (x <80/2)) {
      xspeed *= -1;
    }
  }    
  void display(){
    noStroke();
    color c = color(screenColors[bgCircleColor][0], screenColors[bgCircleColor][1], screenColors[bgCircleColor][2]);
    fill(c);
    ellipse (x, y, bgCircleSize, bgCircleSize);
    oldx = x; //log our last circle
    oldy = y;
  }
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
   * be used for double posting but is not required.
  */  
  if(theOscMessage.isPlugged()==false) {
  /* print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message.");
  println("### addrpattern\t"+theOscMessage.addrPattern());
  println("### typetag\t"+theOscMessage.typetag());
  }
}