
import peasy.*;

float planetRadius;
float moonRadius;
float moonOrbitDist;
float moonOrbitIncline;
float time;

FileNamer fileNamer;

color lineColor0 = color(83, 80, 230);
color lineColor1 = color(175, 209, 252);
color lineColor2 = color(37, 25, 158);

PeasyCam cam;

void setup() {
  size(800, 800, P3D);

  planetRadius = 80;
  moonRadius = 25;
  moonOrbitDist = 300;
  moonOrbitIncline = radians(20);
  time = 0;

  fileNamer = new FileNamer("output/frame", "png");

  cam = new PeasyCam(this, 800);
  
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
}

void draw() {
  draw(g, time);

  time = normalizeTime(time + 0.001);
}

void draw(PGraphics g, float t) {
  int numInclines = 9;
  float maxIncline = radians(30);

  drawBackground(g);
  drawPlanet(g, t);

  g.blendMode(ADD);

  drawMoonOrbit(g, 0, 0, lineColor1);
  drawMoonOrbitNodes(g, 0, 0, lineColor1);
  drawMoonOrbit(g, maxIncline, 0, lineColor2);
  drawMoonOrbitNodes(g, maxIncline, 0, lineColor2);
  drawMoon(g, 0, t, fadeColor(lineColor1, 0.75));
  drawMoon(g, maxIncline, t, lineColor1);

  for (int i = 1; i < numInclines; i++) {
    float incline = map(i, 0, numInclines, 0, maxIncline);
    float u = normalizeTime(t + 0.02 * i);
    color lineColor = fadeColor(lineColor2, 1 - (float)i / numInclines);
    color moonColor = fadeColor(lineColor0, 1 - (float)i / numInclines);
    drawMoonOrbit(g, incline, u, lineColor);
  }
}

color fadeColor(color a, float amount) {
  color b = color(red(a), green(a), blue(a), 0);
  return lerpColor(a, b, amount);
}

void drawBackground(PGraphics g) {
  g.background(0);
}

void drawPlanet(PGraphics g, float t) {
  g.pushStyle();
  g.noFill();
  g.stroke(lineColor0);

  g.pushMatrix();

  g.sphereDetail(20);
  g.sphere(planetRadius);

  g.popMatrix();

  g.popStyle();
}

void drawMoonOrbit(PGraphics g, float incline, float t, color lineColor) {
  g.pushStyle();
  g.ellipseMode(RADIUS);

  g.pushMatrix();
  g.rotateX(PI/2);
  g.rotateY(incline);

  g.noFill();
  g.stroke(lineColor);
  g.ellipse(0, 0, moonOrbitDist, moonOrbitDist);

  g.popMatrix();

  g.popStyle();
}

void drawMoonOrbitNodes(PGraphics g, float incline, float t, color lineColor) {
  g.pushStyle();
  g.ellipseMode(RADIUS);

  g.pushMatrix();

  g.noFill();
  g.stroke(lineColor);
  drawPlanetToMoonLine(g, incline, 0.00);
  drawPlanetToMoonLine(g, incline, 0.25);
  drawPlanetToMoonLine(g, incline, 0.50);
  drawPlanetToMoonLine(g, incline, 0.75);

  g.popMatrix();

  g.popStyle();
}

void drawPlanetToMoonLine(PGraphics g, float incline, float t) {
  PVector planetPos = new PVector();
  PVector moonPos = getMoonPosition(incline, t);
  PVector planetEdge = PVector.mult(moonPos, planetRadius / moonPos.mag());
  g.line(planetEdge.x, planetEdge.y, planetEdge.z, moonPos.x, moonPos.y, moonPos.z);
}

void drawMoon(PGraphics g, float incline, float t, color lineColor) {
  PVector moonPos = getMoonPosition(incline, t);

  g.pushStyle();
  g.noFill();
  g.stroke(lineColor);

  g.pushMatrix();
  g.translate(moonPos.x, moonPos.y, moonPos.z);

  g.sphereDetail(12);
  g.sphere(moonRadius);

  g.popMatrix();

  g.popStyle();
}

PVector getMoonPosition(float incline, float t) {
  float a = map(t, 0, 1, 0, 2 * PI);
  PVector result = new PVector(moonOrbitDist, 0);
  result = ThreeDee.rotateY(result, a);
  result = ThreeDee.rotateZ(result, incline);
  return result;
}

float normalizeTime(float t) {
  while (t < 0) {
    t++;
  }
  while (t >= 1) {
    t--;
  }
  return t;
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");
  
  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    draw(g, (float)i / numFrames);
    save(frameNamer.next());
  }
}

void keyReleased() {
  switch (key) {
    case 'a':
      saveAnimation();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}