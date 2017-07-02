
import peasy.*;

PImage backgroundImage;
float planetOrbitDist;
float moonOrbitDist;
float planetRadius;
float moonRadius;
float lunarOrbitIncline;
float time;
FileNamer fileNamer;

TextureSphere sun;

PeasyCam cam;


void setup() {
  size(800, 800, P3D);

  backgroundImage = loadImage("broadcastbg.jpg");
  planetOrbitDist = 180;
  moonOrbitDist = 30;
  planetRadius = 10;
  moonRadius = 5;
  lunarOrbitIncline = radians(20);//radians(5.1);
  time = 0;
  fileNamer = new FileNamer("output/frame", "png");

  sun = new TextureSphere();

  reset();
}

void reset() {
  cam = new PeasyCam(this, 1200);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
}

void draw() {
  setupLight();
  draw(time);

  time += 0.002;
  while (time > 1) {
    time -= 1;
  }
}

void draw(float t) {
  drawBackground();
  drawSun();
  drawPlanets(t);
  drawMoons(t);
}

void setupLight() {
  pushMatrix();
  translate(0, -1500, 2000);
  pointLight(255, 255, 255, 0, 0, 0);
  popMatrix();
}

void drawBackground() {
  background(backgroundImage);
}

void drawSun() {
  sun.draw(g);
}

void drawPlanets(float t) {
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    float rotation = getPlanetRotation(u);
    
    PVector pos = new PVector();
    pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
    pos = ThreeDee.rotateY(pos, rotation);
    
    if (prevPos == null || prevPos.dist(pos) > planetRadius * 2) {
      if (tDifference(t, u) < 0.05) {
        drawPlanet(u);
      }
      prevPos = pos;
    }
  }
}

void drawPlanet(float t) {
  float rotation = getPlanetRotation(t);

  pushStyle();
  
  pushMatrix();
  rotateY(rotation);
  translate(planetOrbitDist, 0);
  rotateY(-rotation);
  rotateX(lunarOrbitIncline);
  
  noStroke();
  fill(68, 141, 122);
  sphereDetail(32);
  sphere(planetRadius);
/*
  pushMatrix();
  rotateX(PI/2);
  stroke(255, 0, 255);
  noFill();
  ellipseMode(RADIUS);
  ellipse(0, 0, moonOrbitDist, moonOrbitDist);
  popMatrix();
*/
  rotateY(PI/2);
  stroke(255, 0, 0);
  strokeWeight(2);
  //line(0, -planetRadius * 2, 0, planetRadius * 2);
  
  popMatrix();
  
  popStyle();
}

void drawMoons(float t) {
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    float planetRotation = getPlanetRotation(u);
    float moonRotation = getMoonRotation(u);
    
    PVector planetPos = new PVector();
    planetPos = ThreeDee.rotateY(planetPos, -planetRotation);
    planetPos = ThreeDee.translate(planetPos, planetOrbitDist, 0, 0);
    planetPos = ThreeDee.rotateY(planetPos, planetRotation);
    
    PVector moonPos = new PVector();
    moonPos = ThreeDee.translate(moonPos, moonOrbitDist, 0, 0);
    moonPos = ThreeDee.rotateY(moonPos, moonRotation);
    moonPos = ThreeDee.rotateX(moonPos, lunarOrbitIncline);
    moonPos = ThreeDee.rotateY(moonPos, -planetRotation);
    moonPos = ThreeDee.translate(moonPos, planetOrbitDist, 0, 0);
    moonPos = ThreeDee.rotateY(moonPos, planetRotation);
    
    if (prevPos == null || prevPos.dist(moonPos) > moonRadius * 2) {
      if (tDifference(t, u) < 0.05) {
        drawMoon(u);
      }
      prevPos = moonPos;
    }
  }
}

void drawMoon(float t) {
  float planetRotation = getPlanetRotation(t);
  float moonRotation = getMoonRotation(t);

  pushStyle();

  pushMatrix();
  rotateY(planetRotation);
  translate(planetOrbitDist, 0);
  rotateY(-planetRotation);
  rotateX(lunarOrbitIncline);
  rotateY(moonRotation);
  translate(moonOrbitDist, 0);

  noStroke();
  fill(255);
  sphereDetail(32);
  sphere(moonRadius);
  
  rotateY(PI/2);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(0, -moonRadius * 2, 0, moonRadius * 2);

  popMatrix();
  popStyle();
}

void drawLineThrough(PVector p, PVector q) {
  PVector delta = PVector.sub(p, q);
  PVector dir = PVector.sub(p, q);
  dir.normalize();
  
  PVector pDir = p.copy().normalize();
  float length = map(pDir.dot(dir), -1, 1, delta.mag(), delta.mag() + 50);
  
  dir.mult(length);

  PVector a = PVector.add(p, dir);
  PVector b = PVector.sub(p, dir);

  pushStyle();

  stroke(255);
  strokeWeight(2);
  //line(p.x, p.y, p.z, q.x, -q.y, q.z);
  //line(p.x, p.y, p.z, a.x, -a.y, a.z);
  //line(p.x, p.y, p.z, b.x, -b.y, b.z);
  line(p.x, p.y, p.z, q.x, -q.y, q.z);
  
  popStyle();
}

float getPlanetRotation(float t) {
  return map(t, 0, 1, 0, 2 * PI);
}

float getMoonRotation(float t) {
  return map(t, 0, 1, 0, 12 * 2 * PI);
}

float tDifference(float t, float u) {
  float d = abs(t - u);
  if (d > 0.5) {
    if (t > u) {
      d = 1 - t + u;
    } else {
      d = 1 - u + t;
    }
  }
  return d;
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  setupLight();

  int numFrames = 100;
  for (int i = 0; i < numFrames; i++) {
    draw((float)i / numFrames);
    save(frameNamer.next());
  }
}

void keyReleased() {
  switch (key) {
    case 'a':
      saveAnimation();
      break;
    case 'b':
      drawBackground();
      break;
    case 'e':
      reset();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}