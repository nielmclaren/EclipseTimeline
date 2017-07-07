import peasy.*;

float planetOrbitDist;
float moonOrbitDist;
float sunRadius;
float planetRadius;
float moonRadius;
float lunarOrbitIncline;
float time;
FileNamer fileNamer;

PGraphics buffer;
FastBlurrer blurrer;

color lineColor0 = color(83, 80, 230);
color lineColor1 = color(175, 209, 252);
color lineColor2 = color(17, 5, 78);

PeasyCam cam;

void setup() {
  size(800, 800, P3D);

  sunRadius = 500;
  planetOrbitDist = 1800;
  moonOrbitDist = 300;
  planetRadius = 100;
  moonRadius = 50;
  lunarOrbitIncline = radians(20);//radians(5.1);
  time = 0;
  fileNamer = new FileNamer("output/frame", "png");

  buffer = createGraphics(width, height, P3D);
  blurrer = new FastBlurrer(width, height, 2);
/* 
  cam = new PeasyCam(this, 12000);
  
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
*/
}

void draw() {
  setupLight(g);
  
  draw(g, time);

  time += 0.001;
  while (time > 1) {
    time -= 1;
  }
}

void draw(PGraphics g, float t) {
  setupCamera(g, t);
  drawBackground(g);
  drawSun(g, t);
  drawPlanet(g, t);
  drawMoonOrbit(g, t);
  drawMoonOrbitTangent(g, t);
  drawMoon(g, t);
  drawMoonPath(g, t);
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
  
  g.rotateY(PI/2 + getPlanetRotation(t));
  
  g.ellipseMode(RADIUS);
  
  g.noFill();
  g.stroke(lineColor0, 128);
  g.strokeWeight(8);
  g.ellipse(0, 0, sunRadius, sunRadius);
  
  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(4);
  g.ellipse(0, 0, sunRadius, sunRadius);

  g.stroke(lineColor1);
  g.strokeWeight(3);
  g.line(-5000, 0, 5000, 0);

  g.popStyle();
  g.popMatrix();
}

void drawPlanets(PGraphics g, float t) {
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    PVector pos = getPlanetPosition(u);
    
    if (prevPos == null || prevPos.dist(pos) > planetRadius * 2) {
      if (tDifference(t, u) < 0.05) {
        drawPlanet(g, u);
      }
      prevPos = pos;
    }
  }
}

void drawPlanet(PGraphics g, float t) {
  g.pushMatrix();
  g.pushStyle();

  applyPlanetMatrix(g, t);
  g.noFill();
  g.stroke(lineColor1);
  g.sphereDetail(12);
  g.sphere(planetRadius);
  
  g.popStyle();
  g.popMatrix();
}

void drawMoonOrbit(PGraphics g, float t) {
  g.pushStyle();
  
  g.pushMatrix();
  applyPlanetMatrix(g, t);
  g.rotateY(-getPlanetRotation(t));
  g.rotateX(PI/2 + lunarOrbitIncline);

  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(3);
  g.ellipse(0, 0, 2 * moonOrbitDist, 2 * moonOrbitDist);
  
  g.popMatrix();

  g.popStyle();
}

void drawMoonOrbitTangent(PGraphics g, float t) {
  g.pushStyle();

  g.pushMatrix();
  applyPlanetMatrix(g, t);
  g.rotateY(-getPlanetRotation(t));
  g.rotateX(lunarOrbitIncline);
  g.rotateY(getPlanetRotation(t));
  g.rotateX(PI/2);
  g.rotateZ(PI/2);

  g.stroke(255, 0, 0);
  g.strokeWeight(4);
  g.line(0, 0, 0, moonOrbitDist);
  g.line(0, moonOrbitDist, -10000, moonOrbitDist);
  g.line(0, moonOrbitDist, 10000, moonOrbitDist);

  g.popMatrix();

  PVector pos = getPlanetPosition(t);
  g.line(0, 0, 0, pos.x, pos.y, pos.z);

  g.popStyle();
}

void drawMoonPath(PGraphics g, float t) {
  g.pushStyle();
  g.noFill();

  PVector planetPos = getPlanetPosition(t);
  
  int numPoints = 1000;
  PVector prevPos = null;
  for (int i = 0; i <= numPoints; i++) {
    float u = (float)i / numPoints;
    PVector pos = getMoonPosition(u);
    if (prevPos != null) {
      float factor = 1 - constrain(planetPos.dist(pos) / 5000, 0, 1);
      g.strokeWeight(1 + factor * 4);
      g.stroke(239, 58, 236, factor * 255);
      g.line(pos.x, pos.y, pos.z, prevPos.x, prevPos.y, prevPos.z);
    }
    prevPos = pos;
  }

  g.popStyle();
}

void drawMoons(PGraphics g, float t) {
  int numFrames = 10000;
  PVector prevPos = null;
  for (int i = 0; i < numFrames; i++) {
    float u = (float)i / numFrames;
    PVector moonPos = getMoonPosition(u);
    if (prevPos == null || prevPos.dist(moonPos) > moonRadius * 2) {
      drawMoon(g, u);
      prevPos = moonPos;
    }
  }
}

void drawMoon(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);
  PVector moonPos = getMoonPosition(t);
  
  g.pushMatrix();
  g.pushStyle();
  
  applyMoonMatrix(g, t);

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

void applyPlanetMatrix(PGraphics g, float t) {
  float rotation = getPlanetRotation(t);
  
  g.rotateY(rotation);
  g.translate(planetOrbitDist, 0);
}

void applyMoonMatrix(PGraphics g, float t) {
  float planetRotation = getPlanetRotation(t);
  float moonRotation = getMoonRotation(t);
  
  g.rotateY(planetRotation);
  g.translate(planetOrbitDist, 0);
  g.rotateY(-planetRotation);
  g.rotateX(lunarOrbitIncline);
  g.rotateY(moonRotation);
  g.translate(moonOrbitDist, 0);
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

PVector getNewMoonPosition(float t) {
  float planetRotation = getPlanetRotation(t);
  PVector pos = new PVector();
  pos = ThreeDee.rotateZ(pos, PI/2);
  pos = ThreeDee.rotateX(pos, PI/2 + lunarOrbitIncline);
  pos = ThreeDee.rotateY(pos, -planetRotation);
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

  setupLight(g);

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