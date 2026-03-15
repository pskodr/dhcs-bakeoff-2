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
  text("CCW", inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation--;

  text("CW", width-inchToPix(.4f), inchToPix(.4f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
    logoRotation++;

  text("-", inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f));

  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f));

  text("left", inchToPix(.4f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    logoY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    logoY+=inchToPix(.02f);
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
