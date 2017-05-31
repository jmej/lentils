
//make a circle appear with each lentil trigger and float around. maybe try genie (up) animation on the circle
//try making the circles fade out before not being drawn anymore - maybe they're fading the whole time they're on screen
//get pd patch triggers to reset the measure counter if the trigger comes in after the fade behavior is done

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

Lentil[][] lentils = new Lentil[6][10]; //each sub array will get filled with lentil instances
bgCircle[][] bgCircles = new bgCircle[6][10];

boolean[] triggers = new boolean[6];
boolean[] circleTriggers = new boolean[32];

int[] timers = new int[6];

int[][] screenColors =  {{249, 194, 10}, {38, 94, 172}, {193, 13, 11}, {37, 179, 75}, {120, 77, 41}, {225, 115, 37}};
int screenRed = 249;
int screenGreen = 194;
int screenBlue = 10;

long triggerTime = 0;
long triggerTimer = 0;
long beatCount = 0;
long circlesToDraw = 0;
long screenTimer = 0; //30 fps means %900 gives 30 seconds

void setup (){
  oscP5 = new OscP5(this,12000);
  
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  oscP5.plug(this,"podium","/podium");
  
  bg = loadImage("m_backgrounds1.jpg");
  fullScreen(1);
  //size (1920, 1080); // Size of background
  background (249,194,10); // Background color
  
  for (int c = 0; c < 6; c++){ //setup each color
    
    for (int i = 0; i < lentils[c].length; i++){
      float circleSize = random(500)+500;
      float circleX = random(circleSize, width-circleSize);
      float circleY = random(circleSize, height-circleSize);
    lentils[c][i] = new Lentil(c, int((random(500)+300)), width, height, randomlySignedFloat(5, 20), randomlySignedFloat(5, 20));
      bgCircles[c][i] = new bgCircle(c, int(circleSize), circleX, circleY, randomlySignedFloat(0.1, 2),randomlySignedFloat(0.1, 2));
    }
    
    for (int i = 0; i < 3; i++){
      String imageName = imageNames[c][i];
      colors[c][i] = loadImage(imageName);
    }
  }
  frameRate(24);
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
    beatCount++;
    triggerTimer = millis();
  }
}
 
void draw (){
  background (screenRed,screenGreen,screenBlue); // Background color
  //background(bg);
  println("circles = "+circlesToDraw);
  circlesToDraw = beatCount % 32; //draw up to 32 circles
  //if (circlesToDraw > 16){
  //  circlesToDraw = 8; //max background circles
    
  //  int newScreenColor = int(random(5)); //change the screen color every 4 bars of triggers
  //  screenRed = screenColors[newScreenColor][0];
  //  screenGreen = screenColors[newScreenColor][1];
  //  screenBlue = screenColors[newScreenColor][2];
  //}
  
  if ((millis() - triggerTimer) > 4000){ //stop drawing circles if 4 seconds have passed since last trigger - but immediately draw 8
    circlesToDraw = 0;
    beatCount = 0;
    for (int i = 0; i < circleTriggers.length; i++){ 
      circleTriggers[i] = false;
      if (i < 8){ //attract mode
        int cColor = (i % 5)+1; //avoids yellow (assuming bg is yellow)
        int cNum = i % 10;
        bgCircles[cColor][cNum].move();
        bgCircles[cColor][cNum].display();
      }
    }
  }

    
  for (int i = 0; i < circleTriggers.length; i++){ //setup a trigger for every increment that has happened
    if (i < circlesToDraw){
      circleTriggers[i] = true;
    }
  }
  
  if (circlesToDraw > 16){
    for (int i=0; i < circlesToDraw-16; i++){
      circleTriggers[i] = false; //stop drawing circles sequentially after 16 are on screen
    }
  }
  
  if (circlesToDraw < 16){
    for (int i=0; i < circlesToDraw; i++){
      circleTriggers[i+16] = false; //stop drawing circles above 16 sequentially
    }
  }
  
  for (int t = 0; t < circleTriggers.length; t++){
    if (circleTriggers[t]){
      int cColor = (t % 5)+1; //avoids yellow (assuming bg is yellow)
      int cNum = t % 10;
      bgCircles[cColor][cNum].move();
      bgCircles[cColor][cNum].display();
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

float randomlySignedFloat(float a, float b){
  //takes an absolute value range and returns a float with a random sign
  if (random(1) > 0.5){
    return random(a, b)*1;
  }
  else {
    return random(a, b)* (-1);
  }
}

void retrigLentils(int lentilColor){
   triggers[lentilColor] = true;
    float newX = random(lentilSizes[2], width - lentilSizes[2]); //random size 1 big lentil away from edges
    float newY = random(lentilSizes[2], height - lentilSizes[2]);

    for (int i = 0; i < lentils[0].length; i++){
      float newXspeed = randomlySignedFloat(5, 20);
      float newYspeed = randomlySignedFloat(5, 20);
      lentils[lentilColor][i].lentilSize = int(random(3));
      lentils[lentilColor][i].x = newX;
      lentils[lentilColor][i].y = newY;
      lentils[lentilColor][i].xspeed = newXspeed;
      lentils[lentilColor][i].yspeed = newYspeed;
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