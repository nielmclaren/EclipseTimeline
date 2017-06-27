
import peasy.*;

PImage backgroundImage;
float orbitDist;
FileNamer fileNamer;

PeasyCam cam;

void setup() {
  size(800, 800, P3D);

  backgroundImage = loadImage("background.png");
  orbitDist = 220;
  fileNamer = new FileNamer("output/frame", "png");

  reset();
}

void reset() {
  cam = new PeasyCam(this, 1200);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);

  drawBackground();
}

void draw() {
  drawBackground();
  drawSun();
  drawMoonOrbit();
  drawPlanet();
  drawMoon();
}

void drawBackground() {
  background(backgroundImage);
}

void drawSun() {
  pushMatrix();
  translate(0, 0, 2000);
  pointLight(255, 255, 255, 0, 0, 0);
  popMatrix();
}

void drawMoonOrbit() {
  stroke(255);
  strokeWeight(2);
  noFill();
}

void drawPlanet() {
  noStroke();
  fill(68, 141, 122);

  pushMatrix();
  sphereDetail(36);
  sphere(40);
  popMatrix();
}

void drawMoon() {
  float sphereRadius = 5;
  
  pushStyle();
  noStroke();

  colorMode(HSB);
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < frameCount * 4; i++) {
    fill(140);

    float rotX = 0.1 * cos(map(i, 0, numFrames, 0, 20 * 2 * PI));
    float rotY = PI/2 + radians((float) i / 4);
    float rotZ = -radians((float) i / 1000);
    float translateX = map(i, 0, numFrames, 100, 300);

    PVector pos = new PVector();
    pos = ThreeDee.translate(pos, translateX, 0, 0);
    pos = ThreeDee.rotateZ(pos, rotZ);
    pos = ThreeDee.rotateY(pos, rotY);
    pos = ThreeDee.rotateX(pos, rotX);
    
    if (prevPos == null || prevPos.dist(pos) > sphereRadius * 2) {
      pushMatrix();
      rotateX(rotX);
      rotateY(rotY);
      rotateZ(rotZ);
      translate(translateX, 0, 0);
      
      sphereDetail(6);
      sphere(sphereRadius);
      
      popMatrix();
      
      prevPos = pos;
    }
  }
  popStyle();
}

void keyReleased() {
  switch (key) {
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