
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

  pushMatrix();
  rotateX(PI/2);
  ellipseMode(RADIUS);
  ellipse(0, 0, orbitDist, orbitDist);
  popMatrix();
}

void drawPlanet() {
  noStroke();
  fill(68, 141, 122);

  pushMatrix();
  sphereDetail(18);
  sphere(120);
  popMatrix();
}

void drawMoon() {
  noStroke();
  fill(220, 63, 28);

  pushMatrix();
  rotateY(radians(frameCount));
  translate(orbitDist, 0);
  sphereDetail(12);
  sphere(20);
  popMatrix();
}

void keyReleased() {
  switch (key) {
    case 'e':
      reset();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}
