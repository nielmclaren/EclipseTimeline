
import peasy.*;

float planetRadius;
float moonRadius;
float moonMajorAxis;
float moonMinorAxis;
float apsidalPrecessionPeriod;
float time;

PFont labelFont;

FileNamer fileNamer;

color lineColor0 = color(83, 80, 230);
color lineColor1 = color(175, 209, 252);
color lineColor2 = color(17, 5, 78);

boolean isPaused;

void setup() {
  size(800, 800, P3D);

  planetRadius = 80;
  moonRadius = 25;
  moonMajorAxis = 480;
  moonMinorAxis = 470;
  apsidalPrecessionPeriod = 9;
  time = 0;

  labelFont = createFont("Arial", 22);
  
  fileNamer = new FileNamer("output/frame", "png");

  isPaused = false;
}

void draw() {
  g.pushMatrix();
  g.translate(width/2, height/2);
  draw(g, time);
  g.popMatrix();

  if (!isPaused) {
    time += 0.001;
    while (time > 1) {
      time -= 1;
    }
  }
}

void draw(PGraphics g, float t) {
  drawBackground(g);
  drawSiderealProgress(g, t);
  drawAnomalisticProgress(g, t);
  drawPlanet(g, t);
  drawMoonOrbit(g, t);
  drawMoonPositions(g, t);
  drawMoon(g, t);
}

void drawBackground(PGraphics g) {
  g.background(0);
}

void drawPlanet(PGraphics g, float t) {
  g.pushStyle();

  g.pushMatrix();
  g.rotateX(PI/2);
  g.rotateZ(radians(12));
  g.rotateY(t * 10 * 2 * PI);

  g.noFill();
  g.stroke(lineColor0);
  g.sphereDetail(24);
  g.sphere(planetRadius);

  g.popMatrix();

  g.popStyle();
}

void drawMoonOrbit(PGraphics g, float t) {
  g.pushStyle();
  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(2);

  int numFrames = 100;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    float v = ((float)i + 1) / numFrames;
    PVector moonPos = getMoonPosition(t, u);
    PVector nextMoonPos = getMoonPosition(t, v);
    g.line(moonPos.x, moonPos.y, nextMoonPos.x, nextMoonPos.y);
  }
  
  g.popStyle();
}

void drawMoonPositions(PGraphics g, float t) {
  g.pushMatrix();
  g.translate(0, 0, 1);
  
  PVector apogee = getMoonPosition(t, 0);
  PVector perigee = getMoonPosition(t, 0.5);

  PVector apogeeStart = PVector.mult(apogee, planetRadius / apogee.mag());
  PVector perigeeStart = PVector.mult(perigee, planetRadius / perigee.mag());
  PVector perigeeEnd = PVector.mult(perigee, (perigee.mag() - moonRadius) / perigee.mag());
  
  g.pushStyle();
  g.noFill();
  g.stroke(lineColor1);
  g.strokeWeight(1);
  
  g.line(apogeeStart.x, apogeeStart.y, apogee.x, apogee.y);
  g.line(perigeeStart.x, perigeeStart.y, perigeeEnd.x, perigeeEnd.y);
  
  g.ellipseMode(RADIUS);
  g.ellipse(perigee.x, perigee.y, moonRadius, moonRadius);

  g.noStroke();
  g.fill(lineColor1);
  g.textFont(labelFont);
  
  String apogeeLabel = "APOGEE";
  float apogeeLabelWidth = g.textWidth(apogeeLabel);
  PVector apogeeLabelPos = apogee.copy();
  apogeeLabelPos.mult((apogee.mag() + apogeeLabelWidth/2 + 10) / apogee.mag());
  
  String perigeeLabel = "PERIGEE";
  float perigeeLabelWidth = g.textWidth(perigeeLabel);
  PVector perigeeLabelPos = perigee.copy();
  perigeeLabelPos.mult((perigee.mag() + perigeeLabelWidth/2 + moonRadius + 10) / perigee.mag());

  g.text(apogeeLabel, apogeeLabelPos.x - apogeeLabelWidth/2, apogeeLabelPos.y);
  g.text(perigeeLabel, perigeeLabelPos.x - perigeeLabelWidth/2, perigeeLabelPos.y);

  g.popMatrix();
  g.popStyle();
}

void drawSiderealProgress(PGraphics g, float t) {
}

void drawAnomalisticProgress(PGraphics g, float t) {
  g.pushStyle();
  g.noFill();
  
  float offset = 40;
  float prevPerigeeTime = getPrevPerigeeTime(t);
  PVector prevPerigeePos = getPrevPerigeePos(t);
  PVector prevPerigeeEnd = PVector.mult(prevPerigeePos, (prevPerigeePos.mag() + 2 * offset) / prevPerigeePos.mag());

  PVector prevPos = null;
  for (float u = prevPerigeeTime; u < t; u += 0.0001) {
    PVector pos = getMoonPosition(u);
    if (prevPos != null) {
      PVector prevPosEnd = PVector.mult(prevPos, (prevPos.mag() + offset) / prevPos.mag());
      PVector posEnd = PVector.mult(pos, (pos.mag() + offset) / pos.mag());
      
      g.stroke(lineColor2);
      g.strokeWeight(2 * offset);
      g.line(prevPosEnd.x, prevPosEnd.y, posEnd.x, posEnd.y);
    }
    prevPos = pos;
  }
  
  prevPos = null;
  for (float u = prevPerigeeTime; u < t; u += 0.001) {
    PVector pos = getMoonPosition(u);
    if (prevPos != null) {
      g.stroke(lineColor1);
      g.strokeWeight(2);
      g.line(prevPos.x, prevPos.y, pos.x, pos.y);
    }
    prevPos = pos;
  }
  
  g.noFill();
  g.stroke(lineColor1);
  g.strokeWeight(2);
  g.line(0, 0, prevPerigeeEnd.x, prevPerigeeEnd.y);

  g.popStyle();
}

void drawMoon(PGraphics g, float t) {
  PVector moonPos = getMoonPosition(t);

  g.pushStyle();
  
  g.pushMatrix();
  g.translate(moonPos.x, moonPos.y);
  g.rotateX(PI/2);
  g.rotateY(t * 10 * 2 * PI);

  g.noFill();
  g.stroke(lineColor1);
  g.strokeWeight(0.5);
  g.sphereDetail(16);
  g.sphere(moonRadius);

  g.popMatrix();

  g.popStyle();
}

float getPrevPerigeeTime(float t) {
  float u = (t * apsidalPrecessionPeriod) % 1;
  float delta = u > 0.5 ? u - 0.5 : 0.5 + u;
  return t - delta / apsidalPrecessionPeriod; 
}

PVector getPrevPerigeePos(float t) {
  return getMoonPosition(getPrevPerigeeTime(t));
}

PVector getMoonPosition(float t) {
  float u = t * apsidalPrecessionPeriod;
  return getMoonPosition(t, u);
}

PVector getMoonPosition(float t, float u) {
  float a = moonMajorAxis / 2;
  float b = moonMinorAxis / 2;
  float c = sqrt(a * a - b * b);
  
  float x = c + a * cos(u * 2 * PI);
  float y = b * sin(u * 2 * PI);

  return new PVector(
    x * cos(t * 2 * PI) + y * sin(t * 2 * PI),
    x * sin(t * 2 * PI) - y * cos(t * 2 * PI));
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  g.pushMatrix();
  g.translate(width/2, height/2);
  
  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    draw(g, (float)i / numFrames);
    save(frameNamer.next());
  }
  
  g.popMatrix();
}

void keyReleased() {
  switch (key) {
    case ' ':
      isPaused = !isPaused;
      break;
    case 'a':
      saveAnimation();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}