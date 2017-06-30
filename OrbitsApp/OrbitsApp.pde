
import peasy.*;

PImage backgroundImage;
float planetOrbitDist;
float moonOrbitDist;
float planetRadius;
float moonRadius;
float lunarOrbitIncline;
float time;
FileNamer fileNamer;

PeasyCam cam;


void setup() {
  size(800, 800, P3D);

  backgroundImage = loadImage("background.png");
  planetOrbitDist = 180;
  moonOrbitDist = 30;
  planetRadius = 10;
  moonRadius = 5;
  lunarOrbitIncline = radians(20);//radians(5.1);
  time = 0;
  fileNamer = new FileNamer("output/frame", "png");

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
  fill(255, 192, 0);
  
  pushMatrix();
  sphereDetail(32);
  sphere(40);
  popMatrix();
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
  noStroke();
  fill(68, 141, 122);
  
  float rotation = getPlanetRotation(t);

  pushMatrix();
  rotateY(rotation);
  translate(planetOrbitDist, 0);
  rotateY(-rotation);
  rotateX(lunarOrbitIncline);
  
  sphereDetail(32);
  sphere(planetRadius);
/*
  pushMatrix();
  rotateX(PI/2);
  stroke(128, 128, 0);
  noFill();
  ellipseMode(RADIUS);
  ellipse(0, 0, moonOrbitDist, moonOrbitDist);
  popMatrix();
*/
  rotateY(PI/2);
  stroke(255, 0, 0);
  line(0, -planetRadius * 2, 0, planetRadius * 2);
  
  popMatrix();
}

void drawMoons(float t) {
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    float planetRotation = getPlanetRotation(u);
    float moonRotation = getMoonRotation(u);
    
    PVector pos = new PVector();
    pos = ThreeDee.translate(pos, moonOrbitDist, 0, 0);
    pos = ThreeDee.rotateY(pos, moonRotation);
    pos = ThreeDee.rotateX(pos, lunarOrbitIncline);
    pos = ThreeDee.rotateY(pos, -planetRotation);
    pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
    pos = ThreeDee.rotateY(pos, planetRotation);
    
    if (prevPos == null || prevPos.dist(pos) > moonRadius * 2) {
      if (tDifference(t, u) < 0.05) {
        drawMoon(u);
      }
      prevPos = pos;
    }
  }
}

void drawMoon(float t) {
  noStroke();
  fill(128);

  float planetRotation = getPlanetRotation(t);
  float moonRotation = getMoonRotation(t);

  pushMatrix();
  rotateY(planetRotation);
  translate(planetOrbitDist, 0);
  rotateY(-planetRotation);
  rotateX(lunarOrbitIncline);
  rotateY(moonRotation);
  translate(moonOrbitDist, 0);

  sphereDetail(32);
  sphere(moonRadius);

  popMatrix();
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