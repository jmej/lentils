import java.util.Arrays;
//get pd patch triggers to reset the measure counter if the trigger comes in after the fade behavior is done

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

String[] imageNames = {"yellow.svg", "blue.svg", "red.svg", "green.svg", "brown.svg", "orange.svg"};

PShape[] colors = new PShape[6];
int[] lentilSizes = {50, 100, 150}; //needs to be the 3 sizes of lentils in px

Lentil[][] lentils = new Lentil[6][10]; //each sub array will get filled with lentil instances
BgCircle[] bgCircles = new BgCircle[30];
int circleCounter = 0;

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

  //fullScreen(1);
  size (1920, 1080); // Size of background
  background (249,194,10); // Background color
  
  for (int i = 0; i < bgCircles.length; i++){ //prep the circles
    int c = int(random(5)+1);
    float circleSize = random(500)+500;
    float circleX = random(circleSize, width-circleSize);
    float circleY = random(circleSize, height-circleSize);
    bgCircles[i] = new BgCircle(c, int(circleSize), circleX, circleY, randomlySignedFloat(0.1, 2),randomlySignedFloat(0.1, 2), 0, false);
  }
  
  for (int c = 0; c < 6; c++){ //setup each color
    
    for (int i = 0; i < lentils[c].length; i++){
      lentils[c][i] = new Lentil(c, 100, width, height, randomlySignedFloat(5, 20), randomlySignedFloat(5, 20), 0);
    }
    String imageName = imageNames[c];
    colors[c] = loadShape(imageName);
  }
  frameRate(24);
}

public void podium(float arg) { //OSC triggers
  println("### plug event method. received a message /podium.");
  println(" 1 floats received: "+arg);
  
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
}
 
void draw (){
  background (screenRed,screenGreen,screenBlue); // Background color
  
  //background circles stuff
  Arrays.sort(bgCircles); // puts bgCircles into oldest to youngest order so newest circles get drawn on top
  
  //if (millis() - triggerTimer > 8000){ //if 5 seconds have passed since last trigger start attract mode
    for (int i = 0; i < bgCircles.length; i++){
      bgCircles[i].trigger = true;
      //if ((millis() - triggerTimer) < 15000){
      //  float timeSinceTrig = int(millis() - triggerTimer);
      //  bgCircles[i].age = int(map(timeSinceTrig, 8000, 15000, 180, 8)); //trick to fade circles back in
      //}else{
      bgCircles[i].age = 8;
      //}
      //triggerTimer = millis();
    }
    
  //}
  for (int i = 0; i < bgCircles.length; i++){
    if (bgCircles[i].trigger){
      bgCircles[i].move();
      bgCircles[i].display();
    }
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
    //circleCounter++;
    //int circleCount = circleCounter % bgCircles.length;
    //bgCircles[circleCount].trigger = true;
    //bgCircles[circleCount].x = newX;
    //bgCircles[circleCount].y = newY;
    //bgCircles[circleCount].age = 0;
   
    for (int i = 0; i < lentils[0].length; i++){
      float newXspeed = randomlySignedFloat(5, 20);
      float newYspeed = randomlySignedFloat(5, 20);
      lentils[lentilColor][i].lentilSize = int(random(150)+50);
      lentils[lentilColor][i].x = newX;
      lentils[lentilColor][i].y = newY;
      lentils[lentilColor][i].xspeed = newXspeed;
      lentils[lentilColor][i].yspeed = newYspeed;
      lentils[lentilColor][i].age = 0;
    }
    timers[lentilColor] = 0;
    //println("red trigger");
}

void keyPressed() {
  if (key == 'q') {
   retrigLentils(0);
   triggerTimer = millis();
  }
  if (key == 'w') {
   retrigLentils(1);
   triggerTimer = millis();
  }
  if (key == 'e') {
   retrigLentils(2);
   triggerTimer = millis();
  }
  if (key == 'r') {
   retrigLentils(3);
   triggerTimer = millis();
  }
  if (key == 't') {
   retrigLentils(4);
   triggerTimer = millis();
  }
  if (key == 'y') {
   retrigLentils(5);
   triggerTimer = millis();
  }
  
}


class Lentil {
  int lentilColor;
  int lentilSize;
  float x, y, xspeed, yspeed, oldx, oldy;
  int age;
  
  //constructor
  Lentil(int col, int lsize, float xpos, float ypos, float xsp, float ysp, int lage){
    lentilColor = col;
    lentilSize = lsize;
    x = xpos;
    y = ypos;
    xspeed = xsp;
    yspeed = ysp;
    age = lage;
    
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
    float displaySize = 0;
    //displaySize = map(age, 0, 30, lentilSize*2, lentilSize);
    if (age <= 2){
      displaySize = map(age, 0, 2, lentilSize*0.5, lentilSize*5);
    }
    if (age > 2){
      if (age < 8){
        displaySize = map(age, 3, 8, lentilSize*5, lentilSize);
      }else{ //if lentil is over a certain age
        displaySize = map(age, 8, 150, lentilSize, lentilSize*0.25);
      }
    }
    shape (colors[lentilColor], x-displaySize, y-displaySize, displaySize, displaySize);
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
    //if (age == 0){
    //  bgCircleColor = int(random(4))+1; //for random colors excluding yellow
    //}
    if (age < 180){ //~5 seconds
      noStroke();
      //float alpha = map(age, 0, 180, 255, 0);
      float currentSize = bgCircleSize;
      if (age < 3){
        currentSize = map(age, 0, 3, 0, bgCircleSize+(bgCircleSize/4)); //genie up
      }
      if (age > 3 && age < 8){
        currentSize = map(age, 3, 8, bgCircleSize+(bgCircleSize/4), bgCircleSize); //genie down
    }
      //color c = color(screenColors[bgCircleColor][0], screenColors[bgCircleColor][1], screenColors[bgCircleColor][2]);
      //fill(c, alpha);
      shape (colors[bgCircleColor], x-(currentSize*0.5), y-(currentSize*0.5), currentSize, currentSize);
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