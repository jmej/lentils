import java.util.Arrays;
//get pd patch triggers to reset the measure counter if the trigger comes in after the fade behavior is done

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

String footer = "®/ ™ Trademarks © Mars, Incorporated 2017.";
PFont helvetica;

String[][] imageNames = {
                          {"yellow_200.png", "yellow_100.png", "yellow_150.png"},
                          {"blue_200.png", "blue_100.png", "blue_150.png"},
                          {"red_200.png", "red_100.png", "red_150.png"},
                          {"green_200.png", "green_100.png", "green_150.png"},
                          {"brown_200.png", "brown_100.png", "brown_150.png"},
                          {"orange_200.png", "orange_100.png", "orange_150.png"}
                        };

String[] attractImageNames = {"yellow_600.png", "blue_600.png", "red_600.png", "green_600.png", "brown_600.png", "orange_600.png"};
  
PImage[][] colors = new PImage[6][3];
PImage[] attractImages = new PImage[6];

Boolean[] theDrop = new Boolean[2];

int[] lentilSizes = {50, 100, 150}; //needs to be the sizes of lentils in px

Lentil[][] lentils = new Lentil[6][20]; //each sub array will get filled with lentil instances
BgCircle[] bgCircles = new BgCircle[5];

Lentil[] attractLentils = new Lentil[6];

int circleCounter = 0;
int lastCircleColor;
boolean[] triggers = new boolean[6];

int[] timers = new int[6];

int[][] screenColors =  {{249, 194, 10}, {38, 94, 172}, {193, 13, 11}, {37, 179, 75}, {120, 77, 41}, {225, 115, 37}};
int screenRed = 249;
int screenGreen = 194;
int screenBlue = 10;

long triggerTime = 0;
long triggerTimer = 0;
long beatCount = 0;

long screenTimer = 0; //30 fps means %900 gives 30 seconds

void setup (){
  oscP5 = new OscP5(this,12000);
  
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  oscP5.plug(this,"podium","/podium");

  fullScreen(1);
  //size (1920, 1080); // Size of background
  background (249,194,10); // Background color
  helvetica = loadFont("HelveticaNeue-Bold-24.vlw"); //tools - generate font to change size
  
  theDrop[0] = false;
  theDrop[1] = false;
  
  for (int i = 0; i < bgCircles.length; i++){ //prep the circles
    float circleSize = random(500)+500;
    float circleX = random(circleSize, width-circleSize);
    float circleY = random(circleSize, height-circleSize);
    bgCircles[i] = new BgCircle(i, int(circleSize), circleX, circleY, randomlySignedFloat(0.1, 2),randomlySignedFloat(0.1, 2), 0, false);
  }
  
  for (int i = 0; i < attractLentils.length; i++){ //prep the attract lentils
    attractLentils[i] = new Lentil(i, i, 500, 500, randomlySignedFloat(1, 3), randomlySignedFloat(1, 3));
  }
  
  for (int i=0; i < attractImages.length; i++){ //prep the attract images
    String imageName = attractImageNames[i];
    attractImages[i] = loadImage(imageName);
  }
  for (int c = 0; c < 6; c++){ //setup each color
    
    for (int i = 0; i < lentils[c].length; i++){
      lentils[c][i] = new Lentil(c, int((random(500)+300)), width, height, randomlySignedFloat(5, 20), randomlySignedFloat(5, 20));
    }
    
    for (int i = 0; i < 3; i++){
      String imageName = imageNames[c][i];
      colors[c][i] = loadImage(imageName);
      colors[c][i].resize(lentilSizes[i], lentilSizes[i]);
    }
  }
  frameRate(24);
}

public void podium(float arg) { //OSC triggers
  println("### plug event method. received a message /podium.");
  println(" 1 floats received: "+arg);
  resetAttract();
  if (arg == 0.0) {
   retrigLentils(0);
   triggerTimer = millis();
  }
  if (arg == 1.0) {
   retrigLentils(1);
   triggerTimer = millis();
  }
  if (arg == 2.0) {
   retrigLentils(2);
   triggerTimer = millis();
  }
  if (arg == 3.0) {
   retrigLentils(3);
   triggerTimer = millis();
  }
  if (arg == 4.0) {
   retrigLentils(4);
   triggerTimer = millis();
  }
  if (arg == 5.0) {
   retrigLentils(5);
   triggerTimer = millis();
  }
  if (arg == 10.0){
    beatCount++;
    triggerTimer = millis();
  }
  if (arg == 11.0){
    theDrop[0] = true;
  }
  if (arg == 12.0){
    theDrop[0] = false;
  }
  if (arg == 13.0){
    theDrop[1] = true;
  }
  if (arg == 14.0){
    theDrop[1] = false;
  }
}

void resetAttract(){
  for (int i = 0; i < attractLentils.length; i++){
    attractLentils[i].age = 0;
  }
}
 
void draw (){
  background (screenRed,screenGreen,screenBlue); // Background color
  
  Arrays.sort(bgCircles); // puts bgCircles into oldest to youngest order so newest circles get drawn on top
  
  if (millis() - triggerTimer > 8000){ //if some time has passed since last trigger start attract mode
    for (int i = 0; i < attractLentils.length; i++){
      if (attractLentils[i].age < 50){
        attractLentils[i].genieSize = map(attractLentils[i].age, 0, 50, 0, 200);
      }
      attractLentils[i].attractMove();
      attractLentils[i].attractDisplay();
    }
  }
  for (int i = 0; i < bgCircles.length; i++){
    if (bgCircles[i].trigger){
      bgCircles[i].move();
      bgCircles[i].display();
    }
  }
  //strobe mode
  
  if (theDrop[0]){
    background (screenRed,screenGreen,screenBlue); //how can this color stick until the next time theDrop[0] goes false?
  }
  
  if (theDrop[1]){
    int newColor = int(random(6));
    screenRed = screenColors[newColor][0];
    screenGreen = screenColors[newColor][1];
    screenBlue = screenColors[newColor][2];
    background (screenRed,screenGreen,screenBlue);
  }
  
  for (int t = 0; t < triggers.length; t++){
    if (triggers[t]){
      for (int i = 0; i < lentils[t].length; i++){
        lentils[t][i].move();
        lentils[t][i].display();
      }
      
      if (timers[t] == 80){ //length of frames lentils stay on screen
        //timers[t] = 0;
        //triggers[t] = false;
      }else{
        timers[t] ++;
      }
    }
      
  //println("redTimer is: "+timers[0]);
  }

  textFont(helvetica);
  fill(0);
  text(footer, width-(width*0.275), height-(height*0.01));
  screenTimer++;
  
}

float randomlySignedFloat(float a, float b){
  //takes an absolute value range and returns a float with a random sign
  if (random(1) > 0.5){
    return random(a, b)*1;
  }
  else {
    return random(a, b)*(-1);
  }
}

void retrigLentils(int lentilColor){
    int newColor = (lentilColor+1)%6;
    if ((lentilColor+1)%6 == lastCircleColor){ //make sure we aren't using the same circle color as last trigger
      newColor = (lentilColor+2)%6;
    }
    triggers[lentilColor] = true;
    float newX = random(lentilSizes[2], width - lentilSizes[2]); //random size 1 big lentil away from edges
    float newY = random(lentilSizes[2], height - lentilSizes[2]);
    circleCounter++;
    int circleCount = circleCounter % bgCircles.length;
    bgCircles[circleCount].trigger = true;
    bgCircles[circleCount].x = newX;
    bgCircles[circleCount].y = newY;
    bgCircles[circleCount].age = 0;
    bgCircles[circleCount].drawColor = newColor;
   
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
   triggerTimer = millis();
   resetAttract();
  }
  if (key == 'w') {
   retrigLentils(1);
   triggerTimer = millis();
   resetAttract();
  }
  if (key == 'e') {
   retrigLentils(2);
   triggerTimer = millis();
   resetAttract();
  }
  if (key == 'r') {
   retrigLentils(3);
   triggerTimer = millis();
   resetAttract();
  }
  if (key == 't') {
   retrigLentils(4);
   triggerTimer = millis();
   resetAttract();
  }
  if (key == 'y') {
   retrigLentils(5);
   triggerTimer = millis();
   resetAttract();
  }
  
}


class Lentil {
  int lentilColor;
  int lentilSize;
  float x, y, xspeed, yspeed, oldx, oldy;
  int age;
  float genieSize;
  
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
  
  void attractMove() {
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
    
    image (colors[lentilColor][lentilSize], x, y);
    oldx = x; //log our last lentil
    oldy = y;
  }
  
  void attractDisplay(){
    
    image (attractImages[lentilColor], x, y, genieSize, genieSize);
    oldx = x; //log our last lentil
    oldy = y;
    age++;
  }
}

class BgCircle implements Comparable<BgCircle>{
  int bgCircleColor;
  int bgCircleSize;
  float x, y, xspeed, yspeed, oldx, oldy;
  int age;
  boolean trigger;
  int drawColor;
  
  int compareTo(BgCircle o){ 
    int compareAge = o.age;
    return compareAge - this.age; //this will sort youngest to oldest
  }
  
  //constructor
  BgCircle(int col, int lsize, float xpos, float ypos, float xsp, float ysp, int iage, boolean trig){
    bgCircleColor = col;
    bgCircleSize = lsize;
    x = xpos;
    y = ypos;
    xspeed = xsp;
    yspeed = ysp;
    age = iage;
    trigger = trig;
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
    if (age > 30){
      screenRed = screenColors[bgCircleColor][0];
      screenGreen = screenColors[bgCircleColor][1];
      screenBlue = screenColors[bgCircleColor][2];
    }
    if (age < 180){ //~5 seconds
      noStroke();
      //float alpha = map(age, 0, 180, 255, 0);
      float currentSize = 0;
      currentSize = map(age, 0, 30, 0, width*2); //genie up
      color c = color(screenColors[bgCircleColor][0], screenColors[bgCircleColor][1], screenColors[bgCircleColor][2]);
      fill(c, 255);
      ellipse (x, y, currentSize, currentSize);
      oldx = x; //log our last circle
      oldy = y;
      age++;
    }else{
      trigger = false;
    }
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