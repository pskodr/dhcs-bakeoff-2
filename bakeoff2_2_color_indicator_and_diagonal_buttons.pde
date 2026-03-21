import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0;
float border = 0;
int trialCount = 10;
int trialIndex = 0;
int errorCount = 0;
float errorPenalty = 1.0f;
int startTime = 0;
int finishTime = 0;
boolean userDone = false;

final int screenPPI = 72;

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
  size(800, 600);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f)));
  textAlign(CENTER);
  rectMode(CENTER);
  
  border = inchToPix(2f);

  println("creating "+trialCount + " targets");
  for (int i=0; i<trialCount; i++)
  {
    Destination d = new Destination();
    d.x = random(border, width-border);
    d.y = random(border, height-border);
    d.rotation = random(0, 360);
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f);
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations);
}

void draw() {

  background(40);
  fill(200);
  noStroke();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  for (int i=trialIndex; i<trialCount; i++)
  {
    pushMatrix();
    Destination d = destinations.get(i);
    translate(d.x, d.y);
    rotate(radians(d.rotation));

    noFill();
    strokeWeight(3f);

    if (trialIndex==i)
    {
      if (isAligned(d))
        stroke(0,255,0,192); // GREEN
      else
        stroke(255,0,0,192); // RED
    }
    else
      stroke(128,128,128,128);

    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  pushMatrix();
  translate(logoX, logoY);
  rotate(radians(logoRotation));
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  fill(255);
  scaffoldControlLogic();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//silent alignment check (no printing)
boolean isAligned(Destination d)
{
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f);
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f);

  return closeDist && closeRotation && closeZ;
}

void scaffoldControlLogic()
{
  // All buttons positioned relative to lower right corner
  float rightEdge = width;
  float bottomEdge = height;
  
  // 3x3 directional grid
  // Row 1 (top): UL, up, UR
  text("UL", rightEdge - inchToPix(2.4f), bottomEdge - inchToPix(2.4f));
  if (mousePressed && dist(rightEdge - inchToPix(2.4f), bottomEdge - inchToPix(2.4f), mouseX, mouseY)<inchToPix(.4f)) {
    logoX-=inchToPix(.02f);
    logoY-=inchToPix(.02f);
  }

  text("up", rightEdge - inchToPix(1.6f), bottomEdge - inchToPix(2.4f));
  if (mousePressed && dist(rightEdge - inchToPix(1.6f), bottomEdge - inchToPix(2.4f), mouseX, mouseY)<inchToPix(.4f))
    logoY-=inchToPix(.02f);

  text("UR", rightEdge - inchToPix(.8f), bottomEdge - inchToPix(2.4f));
  if (mousePressed && dist(rightEdge - inchToPix(.8f), bottomEdge - inchToPix(2.4f), mouseX, mouseY)<inchToPix(.4f)) {
    logoX+=inchToPix(.02f);
    logoY-=inchToPix(.02f);
  }

  // Row 2 (middle): left, CENTER (rotation/size), right
  text("left", rightEdge - inchToPix(2.4f), bottomEdge - inchToPix(1.6f));
  if (mousePressed && dist(rightEdge - inchToPix(2.4f), bottomEdge - inchToPix(1.6f), mouseX, mouseY)<inchToPix(.4f))
    logoX-=inchToPix(.02f);

  // CENTER BUTTONS - rotation on top row, size on bottom row
  textSize(inchToPix(.2f));
  
  // Rotation: CCW and CW side by side
  text("CCW", rightEdge - inchToPix(1.9f), bottomEdge - inchToPix(1.8f));
  if (mousePressed && dist(rightEdge - inchToPix(1.9f), bottomEdge - inchToPix(1.8f), mouseX, mouseY)<inchToPix(.3f))
    logoRotation--;

  text("CW", rightEdge - inchToPix(1.3f), bottomEdge - inchToPix(1.8f));
  if (mousePressed && dist(rightEdge - inchToPix(1.3f), bottomEdge - inchToPix(1.8f), mouseX, mouseY)<inchToPix(.3f))
    logoRotation++;

  // Size: - and + side by side
  text("-", rightEdge - inchToPix(1.9f), bottomEdge - inchToPix(1.4f));
  if (mousePressed && dist(rightEdge - inchToPix(1.9f), bottomEdge - inchToPix(1.4f), mouseX, mouseY)<inchToPix(.3f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f));

  text("+", rightEdge - inchToPix(1.3f), bottomEdge - inchToPix(1.4f));
  if (mousePressed && dist(rightEdge - inchToPix(1.3f), bottomEdge - inchToPix(1.4f), mouseX, mouseY)<inchToPix(.3f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f));
  
  textSize(inchToPix(.3f));

  text("right", rightEdge - inchToPix(.8f), bottomEdge - inchToPix(1.6f));
  if (mousePressed && dist(rightEdge - inchToPix(.8f), bottomEdge - inchToPix(1.6f), mouseX, mouseY)<inchToPix(.4f))
    logoX+=inchToPix(.02f);

  // Row 3 (bottom): DL, down, DR
  text("DL", rightEdge - inchToPix(2.4f), bottomEdge - inchToPix(.8f));
  if (mousePressed && dist(rightEdge - inchToPix(2.4f), bottomEdge - inchToPix(.8f), mouseX, mouseY)<inchToPix(.4f)) {
    logoX-=inchToPix(.02f);
    logoY+=inchToPix(.02f);
  }

  text("down", rightEdge - inchToPix(1.6f), bottomEdge - inchToPix(.8f));
  if (mousePressed && dist(rightEdge - inchToPix(1.6f), bottomEdge - inchToPix(.8f), mouseX, mouseY)<inchToPix(.4f))
    logoY+=inchToPix(.02f);

  text("DR", rightEdge - inchToPix(.8f), bottomEdge - inchToPix(.8f));
  if (mousePressed && dist(rightEdge - inchToPix(.8f), bottomEdge - inchToPix(.8f), mouseX, mouseY)<inchToPix(.4f)) {
    logoX+=inchToPix(.02f);
    logoY+=inchToPix(.02f);
  }
}

void mousePressed()
{
  if (startTime == 0)
  {
    startTime = millis();
    println("time started!");
  }
}

void mouseReleased()
{
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f);
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f);  

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

float inchToPix(float inch)
{
  return inch*screenPPI;
}
