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
  numMonthsPerYear = 3;
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
  //drawSun(g, t);
  //drawPlanet(g, t);

  //drawMoonOrbit(g, t);
  drawSynodicProgress(g, t);
  //drawMoon(g, t);

  //drawMoonOrbit(g, normalizeTime(t + 1./3));
  drawSynodicProgress(g, normalizeTime(t + 1./3));
  //drawMoon(g, normalizeTime(t + 1./3));

  //drawMoonOrbit(g, normalizeTime(t + 2./3));
  drawSynodicProgress(g, normalizeTime(t + 2./3));
  //drawMoon(g, normalizeTime(t + 2./3));

  drawRandomShit(g, t);
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
  g.strokeWeight(1);
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
/*
  g.noFill();
  g.stroke(lineColor2);
  drawLine(g, new PVector(), planetPos);
  drawLine(g, planetPos, moonPos);

  g.stroke(lineColor0);
  drawLine(g, planetPos, prevNewMoonPos);
/*
  PVector prevPos = null;
  for (float u = prevNewMoonTime; u < t; u += 0.0001) {
    PVector pos = getMoonPosition(t, u);
    if (prevPos != null) {
      PVector rel = PVector.sub(pos, planetPos);
      PVector prevRel = PVector.sub(prevPos, planetPos);
      PVector prevPosOuter = PVector.add(planetPos, PVector.mult(prevRel, (prevRel.mag() + offset) / prevRel.mag()));
      PVector posOuter = PVector.add(planetPos, PVector.mult(rel, (rel.mag() + offset) / rel.mag()));
      
      g.stroke(lineColor2);
      g.strokeWeight(30);
      drawLine(g, prevPosOuter, posOuter);
    }
    prevPos = pos;
  }
  
  prevPos = null;
  for (float u = prevNewMoonTime; u < t; u += 0.001) {
    PVector pos = getMoonPosition(t, u);
    if (prevPos != null) {
      g.stroke(lineColor1);
      g.strokeWeight(1);
      drawLine(g, prevPos, pos);
    }
    prevPos = pos;
  }

  g.noFill();
  g.stroke(lineColor1);
  g.strokeWeight(2);
  drawLine(g, planetPos, prevNewMoonOuter);
 */ 
  g.popMatrix();

  g.popStyle();
}

void drawMoon(PGraphics g, float t) {
  PVector planetPos = getPlanetPosition(t);
  PVector moonPos = getMoonPosition(t);
  
  g.pushMatrix();
  g.pushStyle();
  
  applyMoonMatrix(g, t);

  g.stroke(lineColor2);
  g.noFill();
  g.sphereDetail(16);
  g.sphere(moonRadius);
  
  g.popStyle();
  g.popMatrix();
}

void drawRandomShit(PGraphics g, float t) {
  float t0 = t;
  float t1 = normalizeTime(t + 1./3);
  float t2 = normalizeTime(t + 2./3);
  PVector moonPos0 = getMoonPosition(t0);
  PVector moonPos1 = getMoonPosition(t1);
  PVector moonPos2 = getMoonPosition(t2);

  PVector newMoonPos0 = getNewMoonPosition(t0);
  PVector newMoonPos1 = getNewMoonPosition(t1);
  PVector newMoonPos2 = getNewMoonPosition(t2);

  PVector prevNewMoonPos0 = getPrevNewMoonPosition(t0);
  PVector prevNewMoonPos1 = getPrevNewMoonPosition(t1);
  PVector prevNewMoonPos2 = getPrevNewMoonPosition(t2);

  g.pushStyle();

  g.fill(red(lineColor2), green(lineColor2), blue(lineColor2), 64);
  g.stroke(lineColor0);
  drawTriangle(g, moonPos0, moonPos1, moonPos2);
  drawTriangle(g, prevNewMoonPos0, prevNewMoonPos1, prevNewMoonPos2);

  g.fill(red(lineColor0), green(lineColor0), blue(lineColor0), 64);
  g.stroke(lineColor1);
  drawTriangle(g, newMoonPos0, newMoonPos1, newMoonPos2);

  g.popStyle();
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
  g.rotateY(-moonRotation - PI);
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
  pos = ThreeDee.rotateY(pos, moonRotation + PI);
  pos = ThreeDee.rotateY(pos, planetRotation);
  pos = ThreeDee.translate(pos, planetOrbitDist, 0, 0);
  pos = ThreeDee.rotateY(pos, -planetRotation);
  pos.y *= -1;
  return pos;
}

float getPrevNewMoonTime(float t) {
  int k = numMonthsPerYear + 1;
  return normalizeTime(0.5 + (float)floor(k * (t - 0.5)) / k);
}

PVector getPrevNewMoonPosition(float t) {
  return getMoonPosition(t, getPrevNewMoonTime(t));
}

PVector getNewMoonPosition(float t) {
  PVector result = getPlanetPosition(t);
  result.mult((result.mag() - moonOrbitDist) / result.mag());
  return result;
}

float normalizeTime(float t) {
  while (t < 0) t++;
  while (t >= 1) t--;
  return t;
}

void drawLine(PGraphics g, PVector p0, PVector p1) {
  g.line(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z);
}

void drawTriangle(PGraphics g, PVector p, PVector q, PVector r) {
  g.beginShape();
  g.vertex(p.x, p.y, p.z);
  g.vertex(q.x, q.y, q.z);
  g.vertex(r.x, r.y, r.z);
  g.vertex(p.x, p.y, p.z);
  g.endShape();
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  g.blendMode(ADD);

  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    float t = (float)i / numFrames;
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