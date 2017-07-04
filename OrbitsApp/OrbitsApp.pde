
import peasy.*;

PImage backgroundImage;
float planetOrbitDist;
float moonOrbitDist;
float sunRadius;
float planetRadius;
float moonRadius;
float lunarOrbitIncline;
float time;
FileNamer fileNamer;

TextureSphere sun;
TextureSphere planet;
TextureSphere moon;

PeasyCam cam;

void setup() {
  size(800, 800, P3D);

  backgroundImage = loadImage("background.png");
  sunRadius = 500;
  planetOrbitDist = 1800;
  moonOrbitDist = 300;
  planetRadius = 100;
  moonRadius = 50;
  lunarOrbitIncline = radians(20);//radians(5.1);
  time = 0;
  fileNamer = new FileNamer("output/frame", "png");

  sun = new TextureSphere(loadImage("sunmap.jpg"), sunRadius);
  planet = new TextureSphere(loadImage("mars_1k_color.jpg"), planetRadius);
  moon = new TextureSphere(loadImage("moonmap2k.jpg"), moonRadius);
 /* 
  cam = new PeasyCam(this, 12000);
  
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
*/
}

void draw() {
  setupLight();
  
  draw(time);

  time += 0.001;
  while (time > 1) {
    time -= 1;
  }
}

void draw(float t) {
  setupCamera(t);
  drawBackground();
  drawSun();
  drawPlanet(t);
  drawMoonPath();
  drawMoon(t);
}

void setupLight() {
  ambientLight(64, 64, 64);
  
  pushMatrix();
  translate(0, -1500, -2000);
  pointLight(128, 128, 128, 0, 0, 0);
  popMatrix();
}

void setupCamera(float t) {
  PVector pos = getPlanetPosition(t);
  pos.mult(1.5);
  camera(pos.x, pos.y, pos.z, 0, 0, 0, 0, 1, 0);
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
    PVector pos = getPlanetPosition(u);
    
    if (prevPos == null || prevPos.dist(pos) > planetRadius * 2) {
      if (tDifference(t, u) < 0.05) {
        drawPlanet(u);
      }
      prevPos = pos;
    }
  }
}

void drawPlanet(float t) {
  pushStyle();
  
  pushMatrix();
  applyPlanetMatrix(t);
  planet.draw(g);

  noFill();
  stroke(255);
  rotateY(-getPlanetRotation(t));
  rotateX(lunarOrbitIncline);
  rotateX(PI/2);
  ellipse(0, 0, 2 * moonOrbitDist, 2 * moonOrbitDist);
  
  popMatrix();
  
  popStyle();
}

void drawMoonPath() {
  pushStyle();
  stroke(255);
  noFill();
  
  int numPoints = 1000;
  PVector prevPos = null;
  for (int i = 0; i <= numPoints; i++) {
    float t = (float)i / numPoints;
    PVector pos = getMoonPosition(t);
    if (prevPos != null) {
      line(pos.x, pos.y, pos.z, prevPos.x, prevPos.y, prevPos.z);
    }
    prevPos = pos;
  }

  popStyle();
}

void drawMoons(float t) {
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    PVector moonPos = getMoonPosition(u);
    if (prevPos == null || prevPos.dist(moonPos) > moonRadius * 2) {
      drawMoon(u);
      prevPos = moonPos;
    }
  }
}

void drawMoon(float t) {
  PVector planetPos = getPlanetPosition(t);
  PVector moonPos = getMoonPosition(t);
  
  pushStyle();
  
  stroke(255);
  noFill();
  line(planetPos.x, planetPos.y, planetPos.z, moonPos.x, moonPos.y, moonPos.z);

  pushMatrix();
  applyMoonMatrix(t);
  moon.draw(g);

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
}

float getPlanetRotation(float t) {
  return map(t, 0, 1, 0, 2 * PI);
}

float getMoonRotation(float t) {
  return map(t, 0, 1, 0, 12 * 2 * PI);
}

void applyPlanetMatrix(float t) {
  float rotation = getPlanetRotation(t);
  
  rotateY(rotation);
  translate(planetOrbitDist, 0);
}

void applyMoonMatrix(float t) {
  float planetRotation = getPlanetRotation(t);
  float moonRotation = getMoonRotation(t);
  
  rotateY(planetRotation);
  translate(planetOrbitDist, 0);
  rotateY(-planetRotation);
  rotateX(lunarOrbitIncline);
  rotateY(moonRotation);
  translate(moonOrbitDist, 0);
}

PVector getPlanetPosition(float t) {
  float rotation = getPlanetRotation(t);
  
  PVector pos = new PVector();
  pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, -rotation);
  pos.y *= -1;
  return pos;
}

PVector getMoonPosition(float t) {
  float planetRotation = getPlanetRotation(t);
  float moonRotation = getMoonRotation(t);
  
  PVector pos = new PVector();
  pos = ThreeDee.translate(pos, moonOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, -moonRotation);
  pos = ThreeDee.rotateX(pos, lunarOrbitIncline);
  pos = ThreeDee.rotateY(pos, planetRotation);
  pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, -planetRotation);
  pos.y *= -1;
  return pos;
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

  int numFrames = 300;
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
    case 'r':
      save(fileNamer.next());
      break;
  }
}