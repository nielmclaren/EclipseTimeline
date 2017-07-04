
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

PGraphics buffer;

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

  buffer = createGraphics(width, height, P3D);
  
 /* 
  cam = new PeasyCam(this, 12000);
  
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
*/
}

void draw() {
  buffer.beginDraw();
  setupLight(buffer);
  
  draw(buffer, time);

  time += 0.001;
  while (time > 1) {
    time -= 1;
  }

  buffer.endDraw();
  image(buffer, width/4, height/4, width/2, height/2);
}

void draw(PGraphics g, float t) {
  setupCamera(g, t);
  drawBackground(g);
  drawSun(g);
  drawPlanet(g, t);
  drawMoonPath(g);
  drawMoon(g, t);
}

void setupLight(PGraphics g) {
  g.ambientLight(64, 64, 64);
  
  g.pushMatrix();
  g.translate(0, -1500, -2000);
  g.pointLight(128, 128, 128, 0, 0, 0);
  g.popMatrix();
}

void setupCamera(PGraphics g, float t) {
  PVector pos = getPlanetPosition(t);
  pos.mult(1.5);
  g.camera(pos.x, pos.y, pos.z, 0, 0, 0, 0, 1, 0);
}

void drawBackground(PGraphics g) {
  g.background(backgroundImage);
}

void drawSun(PGraphics g) {
  sun.draw(g);
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
  g.pushStyle();
  
  g.pushMatrix();
  applyPlanetMatrix(g, t);
  planet.draw(g);

  g.noFill();
  g.stroke(255);
  g.rotateY(-getPlanetRotation(t));
  g.rotateX(lunarOrbitIncline);
  g.rotateX(PI/2);
  g.ellipse(0, 0, 2 * moonOrbitDist, 2 * moonOrbitDist);
  
  g.popMatrix();
  
  g.popStyle();
}

void drawMoonPath(PGraphics g) {
  g.pushStyle();
  g.stroke(255);
  g.noFill();
  
  int numPoints = 1000;
  PVector prevPos = null;
  for (int i = 0; i <= numPoints; i++) {
    float t = (float)i / numPoints;
    PVector pos = getMoonPosition(t);
    if (prevPos != null) {
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
  
  g.pushStyle();
  
  g.stroke(255);
  g.noFill();
  g.line(planetPos.x, planetPos.y, planetPos.z, moonPos.x, moonPos.y, moonPos.z);

  g.pushMatrix();
  applyMoonMatrix(g, t);
  moon.draw(g);

  g.popMatrix();
  g.popStyle();
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