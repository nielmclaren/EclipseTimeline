
import controlP5.*;
import peasy.*;

ControlP5 cp5;
Slider lunarOrbitInclineInput;

float planetOrbitDist;
float apsidalPrecessionPeriod;
float moonMajorAxis;
float moonMinorAxis;
float sunRadius;
float planetRadius;
float moonRadius;
float lunarOrbitIncline;
float time;
FileNamer fileNamer;

PGraphics buffer;

color lineColor0 = color(83, 80, 230);
color lineColor1 = color(175, 209, 252);
color lineColor2 = color(17, 5, 78);

PeasyCam cam;

void setup() {
  size(800, 800, P3D);
  
  cp5 = new ControlP5(this);
  
  lunarOrbitInclineInput = cp5.addSlider("lunarOrbitInclineInput")
    .setRange(0, 30)
    .setValue(0)
    .setPosition(20, 20);

  sunRadius = 500;
  planetOrbitDist = 1800;
  apsidalPrecessionPeriod = 9;
  moonMajorAxis = 600;
  moonMinorAxis = 550;
  planetRadius = 100;
  moonRadius = 50;
  lunarOrbitIncline = radians(20);//radians(5.1);
  time = 0;
  fileNamer = new FileNamer("output/frame", "png");

  buffer = createGraphics(width, height, P3D);
  cam = new PeasyCam(this, buffer, 12000);
  
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
}

void draw() {
  buffer.beginDraw();
  setupLight(buffer);
  draw(buffer, time);
  buffer.endDraw();

  image(buffer, 0, 0);

  time += 0.001;
  while (time > 1) {
    time -= 1;
  }
}

void draw(PGraphics g, float t) {
  //setupCamera(g, t);
  drawBackground(g);
  drawSun(g, t);
  drawPlanetOrbit(g, t);
  drawSunPlanetLine(g, t);
  drawPlanet(g, t);
  drawMoonOrbit(g, t);
  drawMoon(g, t);
}

void setupLight(PGraphics g) {
  g.ambientLight(255, 255, 255);
  
  g.pushMatrix();
  g.translate(0, -1500, -2000);
  g.popMatrix();
}

void setupCamera(PGraphics g, float t) {
  PVector pos = getPlanetPosition(t);
  pos.mult(1.5);
  g.camera(pos.x, pos.y, pos.z, 0, 0, 0, 0, 1, 0);
}

void drawBackground(PGraphics g) {
  g.background(0);
}

void drawSun(PGraphics g, float t) {
  g.pushMatrix();
  g.pushStyle();
  
  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(1);
  g.sphereDetail(20);
  g.sphere(sunRadius);

  g.popStyle();
  g.popMatrix();
}

void drawPlanetOrbit(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);

  g.pushMatrix();
  g.pushStyle();
  
  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(1);
  g.ellipseMode(RADIUS);

  g.rotateX(PI/2);
  g.ellipse(0, 0, planetOrbitDist, planetOrbitDist);

  g.popStyle();
  g.popMatrix();
}

void drawSunPlanetLine(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);

  g.pushMatrix();
  g.pushStyle();
  
  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(1);

  g.line(0, 0, 0, planetPos.x, planetPos.y, planetPos.z);

  g.popStyle();
  g.popMatrix();
}

void drawPlanet(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);

  g.pushMatrix();
  g.translate(planetPos.x, planetPos.y, planetPos.z);

  g.pushStyle();
  g.noFill();
  g.stroke(lineColor1);

  g.sphereDetail(12);
  g.sphere(planetRadius);
  
  g.popStyle();
  g.popMatrix();
}

void drawMoonOrbit(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);

  float a = moonMajorAxis / 2;
  float b = moonMinorAxis / 2;
  float c = sqrt(a * a - b * b);

  g.pushMatrix();

  g.pushStyle();
  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(1);

  g.translate(planetPos.x, planetPos.y, planetPos.z);
  g.rotateX(PI/2);
  g.rotateX(lunarOrbitIncline);
  g.rotateZ(-t * 2 * PI);
  g.translate(c, 0);
  g.ellipse(0, 0, moonMajorAxis, moonMinorAxis);

  g.popStyle();

  g.popMatrix();
}

void drawMoon(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);
  PVector moonPos = getMoonPosition(t);
  
  g.pushMatrix();
  g.pushStyle();

  g.translate(moonPos.x, moonPos.y, moonPos.z);
  
  g.stroke(lineColor0);
  g.noFill();
  g.sphereDetail(8);
  g.sphere(moonRadius);
  
  g.popStyle();
  g.popMatrix();
}

float getPlanetRotation(float t) {
  return map(t, 0, 1, 0, 2 * PI);
}

float getMoonRotation(float t) {
  return map(t, 0, 1, 0, 12 * 2 * PI);
}

PVector getPlanetPosition(float t) {
  float rotation = getPlanetRotation(t);
  
  PVector pos = new PVector();
  pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, rotation);
  pos.y *= -1;
  return pos;
}

PVector getMoonPosition(float t) {
  float u = (t * apsidalPrecessionPeriod) % 1;
  return getMoonPosition(t, u);
}

PVector getMoonPosition(float t, float u) {
  PVector planetPos = getPlanetPosition(t);
  
  float a = moonMajorAxis / 2;
  float b = moonMinorAxis / 2;
  float c = sqrt(a * a - b * b);

  float x = c + a * cos(u * 2 * PI);
  float z = b * sin(u * 2 * PI);

  PVector pos = new PVector(
    x * cos(-t * 2 * PI) + z * sin(-t * 2 * PI),
    x * sin(-t * 2 * PI) - z * cos(-t * 2 * PI),
    0);

  pos = ThreeDee.rotateX(pos, lunarOrbitIncline);
  pos = ThreeDee.rotateX(pos, PI/2);
  pos = ThreeDee.translate(pos, planetPos.x, planetPos.y, planetPos.z);
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

  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    float t = (float)i / numFrames;
    buffer.beginDraw();
    setupLight(buffer);
    draw(buffer, t);
    buffer.endDraw();

    image(buffer, 0, 0);

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

void controlEvent(ControlEvent e) {
  if (e.isFrom(cp5.getController("lunarOrbitInclineInput"))) {
    float v = cp5.getController("lunarOrbitInclineInput").getValue();
    lunarOrbitIncline = radians(v);
  }  
}