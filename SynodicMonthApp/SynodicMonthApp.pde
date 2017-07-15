import peasy.*;

float planetOrbitDist;
float moonOrbitDist;
float sunRadius;
float planetRadius;
float moonRadius;
int numMonthsPerYear;
float time;
FileNamer fileNamer;

color lineColor0 = color(83, 80, 230);
color lineColor1 = color(175, 209, 252);
color lineColor2 = color(57, 45, 118);

PeasyCam cam;

void setup() {
  size(800, 800, P3D);

  sunRadius = 400;
  planetOrbitDist = 1500;
  moonOrbitDist = 600;
  planetRadius = 200;
  moonRadius = 100;
  numMonthsPerYear = 12;
  time = 0;
  fileNamer = new FileNamer("output/frame", "png");
/*
  cam = new PeasyCam(this, 12000);
  
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
*/
}

void draw() {
  g.blendMode(ADD);
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
  drawSynodicProgress(g, t);
  drawMoon(g, t);
}

void setupLight(PGraphics g) {
  g.ambientLight(255, 255, 255);
  
  g.pushMatrix();
  g.translate(0, -1500, -2000);
  g.popMatrix();
}

void setupCamera(PGraphics g, float t) {
  g.camera(0, -4500, 0, 0, 0, 0, 0, 0, 1);
}

void drawBackground(PGraphics g) {
  g.background(0);
}

void drawSun(PGraphics g, float t) {
  g.pushMatrix();
  g.pushStyle();
  
  g.noFill();
  g.stroke(lineColor0);
  g.sphereDetail(32);
  g.sphere(sunRadius);

  g.popStyle();
  g.popMatrix();
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
  g.rotateX(PI/2);

  g.noFill();
  g.stroke(lineColor0);
  g.strokeWeight(3);
  g.ellipseMode(RADIUS);
  g.ellipse(0, 0, moonOrbitDist, moonOrbitDist);
  
  g.popMatrix();

  g.popStyle();
}

void drawSynodicProgress(PGraphics g, float t) {
  float offset = 100;
  PVector planetPos = getPlanetPosition(t);
  PVector moonPos = getMoonPosition(t);
  float prevNewMoonTime = getPrevNewMoonTime(t);
  PVector prevNewMoonPos = getMoonPosition(t, prevNewMoonTime);
  PVector prevNewMoonRel = PVector.sub(prevNewMoonPos, planetPos);
  PVector prevNewMoonOuter = PVector.add(planetPos, PVector.mult(prevNewMoonRel, (prevNewMoonRel.mag() + 2 * offset) / prevNewMoonRel.mag()));

  g.pushStyle();

  g.pushMatrix();

  g.noFill();
  g.stroke(lineColor2);
  g.line(0, 0, 0, planetPos.x, planetPos.y, planetPos.z);
  g.line(planetPos.x, planetPos.y, planetPos.z, moonPos.x, moonPos.y, moonPos.z);

  g.stroke(lineColor1);
  g.line(planetPos.x, planetPos.y, planetPos.z, prevNewMoonPos.x, prevNewMoonPos.y, prevNewMoonPos.z);

  PVector prevPos = null;
  for (float u = prevNewMoonTime; u < t + 0.5; u += 0.0001) {
    PVector pos = getMoonPosition(t, u);
    if (prevPos != null) {
      PVector rel = PVector.sub(pos, planetPos);
      PVector prevRel = PVector.sub(prevPos, planetPos);
      PVector prevPosOuter = PVector.add(planetPos, PVector.mult(prevRel, (prevRel.mag() + offset) / prevRel.mag()));
      PVector posOuter = PVector.add(planetPos, PVector.mult(rel, (rel.mag() + offset) / rel.mag()));
      
      g.stroke(lineColor2);
      g.strokeWeight(30);
      g.line(prevPosOuter.x, prevPosOuter.y, prevPosOuter.z, posOuter.x, posOuter.y, posOuter.z);
    }
    prevPos = pos;
  }
  
  prevPos = null;
  for (float u = prevNewMoonTime; u < t + 0.5; u += 0.001) {
    PVector pos = getMoonPosition(t, u);
    if (prevPos != null) {
      g.stroke(lineColor1);
      g.strokeWeight(1);
      g.line(prevPos.x, prevPos.y, prevPos.z, pos.x, pos.y, pos.z);
    }
    prevPos = pos;
  }
  
  g.noFill();
  g.stroke(lineColor1);
  g.strokeWeight(2);
  g.line(planetPos.x, planetPos.y, planetPos.z, prevNewMoonOuter.x, prevNewMoonOuter.y, prevNewMoonOuter.z);

  g.popMatrix();

  g.popStyle();
}

void drawMoon(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);
  PVector moonPos = getMoonPosition(t);
  
  g.pushMatrix();
  g.pushStyle();
  
  applyMoonMatrix(g, t);

  g.stroke(lineColor1);
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
  return map(t, 0, 1, 0, numMonthsPerYear * 2 * PI);
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
  g.rotateY(-moonRotation);
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
  return getMoonPosition(t, t);
}

PVector getMoonPosition(float t, float u) {
  float planetRotation = getPlanetRotation(t);
  float moonRotation = getMoonRotation(u);
  
  PVector pos = new PVector();
  pos = ThreeDee.translate(pos, moonOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, moonRotation);
  pos = ThreeDee.rotateY(pos, planetRotation);
  pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, -planetRotation);
  pos.y *= -1;
  return pos;
}

float getPrevNewMoonTime(float t) {
  int k = numMonthsPerYear + 1;
  return (float)floor(k * (t + 0.5)) / k;
}

float normalizeTime(float t) {
  while (t < 0) t++;
  while (t >= 1) t--;
  return t;
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  g.blendMode(ADD);

  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    float t = (float)i / numFrames;
    setupLight(g);
    draw(g, t);

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