import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 10; //WILL BE MODIFIED FOR THE BAKEOFF
 //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 1.0f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

// added interaction state
boolean draggingLogo = false;
boolean draggingRotateHandle = false;
boolean draggingResizeHandle = false;

float dragOffsetX = 0;
float dragOffsetY = 0;
float rotateStartMouseAngle = 0;
float rotateStartLogoRotation = 0;
float resizeStartLocalExtent = 0;
float resizeStartLogoZ = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  println("creating "+trialCount + " targets");
  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();
  
  //Test square in the top left corner. Should be 1 x 1 inch
  //rect(inchToPix(0.5), inchToPix(0.5), inchToPix(1), inchToPix(1));

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    
    rotate(radians(d.rotation)); //rotate around the origin of the Ddestination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW NEW CONTROLS=================
  fill(255);
  scaffoldControlLogic();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//new control design:
//-drag square itself to move
//-drag rotation handle to rotate
//-drag resize handle to scale
void scaffoldControlLogic()
{
  float handleRadius = inchToPix(.18f);

  PVector rotateHandle = getRotateHandlePosition();
  PVector resizeHandle = getResizeHandlePosition();

  // connector line to rotation handle
  stroke(220);
  strokeWeight(2f);
  line(logoX, logoY - logoZ/2, rotateHandle.x, rotateHandle.y);

  // rotation handle
  noStroke();
  fill(255, 180, 0);
  ellipse(rotateHandle.x, rotateHandle.y, handleRadius*2, handleRadius*2);
  fill(0);
  textSize(inchToPix(.18f));
  text("R", rotateHandle.x, rotateHandle.y + 1);

  // resize handle
  noStroke();
  fill(0, 220, 120);
  ellipse(resizeHandle.x, resizeHandle.y, handleRadius*2, handleRadius*2);
  fill(0);
  text("Z", resizeHandle.x, resizeHandle.y + 1);

  // small label
  fill(255);
  textSize(inchToPix(.2f));
  text("Drag square = move   Drag R = rotate   Drag Z = resize", width/2, height - inchToPix(.35f));
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }

  float handleRadius = inchToPix(.18f);
  PVector rotateHandle = getRotateHandlePosition();
  PVector resizeHandle = getResizeHandlePosition();

  if (dist(mouseX, mouseY, rotateHandle.x, rotateHandle.y) < handleRadius)
  {
    draggingRotateHandle = true;
    rotateStartMouseAngle = degrees(atan2(mouseY - logoY, mouseX - logoX));
    rotateStartLogoRotation = logoRotation;
    return;
  }

  if (dist(mouseX, mouseY, resizeHandle.x, resizeHandle.y) < handleRadius)
  {
    draggingResizeHandle = true;
    PVector local = screenToLogoLocal(mouseX, mouseY);
    resizeStartLocalExtent = max(abs(local.x), abs(local.y));
    resizeStartLogoZ = logoZ;
    return;
  }

  if (pointInsideLogoSquare(mouseX, mouseY))
  {
    draggingLogo = true;
    dragOffsetX = mouseX - logoX;
    dragOffsetY = mouseY - logoY;
    return;
  }
}

void mouseDragged()
{
  if (draggingLogo)
  {
    logoX = mouseX - dragOffsetX;
    logoY = mouseY - dragOffsetY;
  }
  else if (draggingRotateHandle)
  {
    float currentMouseAngle = degrees(atan2(mouseY - logoY, mouseX - logoX));
    logoRotation = rotateStartLogoRotation + (currentMouseAngle - rotateStartMouseAngle);
  }
  else if (draggingResizeHandle)
  {
    PVector local = screenToLogoLocal(mouseX, mouseY);
    float currentExtent = max(abs(local.x), abs(local.y));
    float delta = currentExtent - resizeStartLocalExtent;
    logoZ = constrain(resizeStartLogoZ + 2*delta, .01, inchToPix(4f)); //leave min and max alone!
  }
}

void mouseReleased()
{
  draggingLogo = false;
  draggingRotateHandle = false;
  draggingResizeHandle = false;

  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

// helper: convert screen point into square-local coordinates
PVector screenToLogoLocal(float sx, float sy)
{
  float dx = sx - logoX;
  float dy = sy - logoY;
  float a = radians(-logoRotation);
  float localX = dx*cos(a) - dy*sin(a);
  float localY = dx*sin(a) + dy*cos(a);
  return new PVector(localX, localY);
}

// helper: is pointer inside rotated square
boolean pointInsideLogoSquare(float sx, float sy)
{
  PVector local = screenToLogoLocal(sx, sy);
  return abs(local.x) <= logoZ/2 && abs(local.y) <= logoZ/2;
}

// helper: rotation handle position
PVector getRotateHandlePosition()
{
  float offset = logoZ/2 + inchToPix(.45f);
  float a = radians(logoRotation - 90);
  return new PVector(logoX + cos(a)*offset, logoY + sin(a)*offset);
}

// helper: resize handle position (square corner)
PVector getResizeHandlePosition()
{
  float localX = logoZ/2;
  float localY = logoZ/2;
  float a = radians(logoRotation);
  float sx = logoX + localX*cos(a) - localY*sin(a);
  float sy = logoY + localX*sin(a) + localY*cos(a);
  return new PVector(sx, sy);
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
