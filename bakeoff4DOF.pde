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

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

void scaffoldControlLogic()
{
  float btnSize = inchToPix(.5f);
  float spacing = inchToPix(.1f);
  float startX = width - inchToPix(1.5f);
  float startY = inchToPix(1.0f);

  // ===== BUTTONS =====
  drawButton("↑", startX, startY);
  if (mousePressed && overButton(startX, startY, btnSize))
    logoY -= inchToPix(.02f);

  drawButton("↓", startX, startY + btnSize + spacing);
  if (mousePressed && overButton(startX, startY + btnSize + spacing, btnSize))
    logoY += inchToPix(.02f);

  drawButton("←", startX - btnSize - spacing, startY + btnSize/2);
  if (mousePressed && overButton(startX - btnSize - spacing, startY + btnSize/2, btnSize))
    logoX -= inchToPix(.02f);

  drawButton("→", startX + btnSize + spacing, startY + btnSize/2);
  if (mousePressed && overButton(startX + btnSize + spacing, startY + btnSize/2, btnSize))
    logoX += inchToPix(.02f);

  drawButton("+", startX, startY + 2*(btnSize + spacing));
  if (mousePressed && overButton(startX, startY + 2*(btnSize + spacing), btnSize))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f));

  drawButton("-", startX, startY + 3*(btnSize + spacing));
  if (mousePressed && overButton(startX, startY + 3*(btnSize + spacing), btnSize))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f));

  drawButton("CW", startX - btnSize - spacing, startY + 2*(btnSize + spacing));
  if (mousePressed && overButton(startX - btnSize - spacing, startY + 2*(btnSize + spacing), btnSize))
    logoRotation++;

  drawButton("CCW", startX + btnSize + spacing, startY + 2*(btnSize + spacing));
  if (mousePressed && overButton(startX + btnSize + spacing, startY + 2*(btnSize + spacing), btnSize))
    logoRotation--;

  // ===== TARGET INFO =====
  Destination d = destinations.get(trialIndex);

  float dx = d.x - logoX;
  float dy = d.y - logoY;
  float dz = d.z - logoZ;
  float rotDiff = (float)calculateDifferenceBetweenAngles(d.rotation, logoRotation);

  boolean closeDist = dist(d.x, d.y, logoX, logoY) < inchToPix(.05f);
  boolean closeZ = abs(dz) < inchToPix(.1f);
  boolean closeRot = rotDiff <= 5;

  float textX = width - inchToPix(.2f);
  float textY = startY + 5*(btnSize);

  textAlign(RIGHT);

  // ===== DIRECTION (POSITION) =====
  fill(255);
  String dirX = abs(dx) > inchToPix(.01f) ? (dx > 0 ? "→" : "←") : "";
  String dirY = abs(dy) > inchToPix(.01f) ? (dy > 0 ? "↓" : "↑") : "";
  text("Move: " + dirX + " " + dirY, textX, textY);

  // ===== SIZE INSTRUCTION =====
  textY += inchToPix(.3f);
  String sizeInstr = "";
  if (!closeZ)
    sizeInstr = dz > 0 ? "Increase Size (+)" : "Decrease Size (-)";
  else
    sizeInstr = "Size OK";

  text(sizeInstr, textX, textY);

  // ===== ROTATION INSTRUCTION =====
  textY += inchToPix(.3f);
  String rotInstr = "";
  if (!closeRot)
  {
    float diff = d.rotation - logoRotation;
    diff = (diff + 360) % 360;
    rotInstr = (diff > 180) ? "Rotate CCW" : "Rotate CW";
  }
  else
    rotInstr = "Rotation OK";

  text(rotInstr, textX, textY);

  // ===== STATUS FEEDBACK =====
  textY += inchToPix(.4f);

  fill(closeDist ? color(0,255,0) : 255);
  text("COOR CLOSE", textX, textY);

  textY += inchToPix(.3f);
  fill(closeZ ? color(0,255,0) : 255);
  text("SIZE CLOSE", textX, textY);

  textY += inchToPix(.3f);
  fill(closeRot ? color(0,255,0) : 255);
  text("ROT CLOSE", textX, textY);
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
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

void drawButton(String label, float x, float y)
{
  float size = inchToPix(.5f);

  fill(100);
  rect(x, y, size, size);

  fill(255);
  textAlign(CENTER, CENTER);
  text(label, x, y);
}

boolean overButton(float x, float y, float size)
{
  return mouseX > x - size/2 && mouseX < x + size/2 &&
         mouseY > y - size/2 && mouseY < y + size/2;
}
