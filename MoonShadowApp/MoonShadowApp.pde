
PImage earthImage;
PVector startPoint;
PVector endPoint;
float time;

FileNamer fileNamer;

boolean isPaused;

color lineColor0 = color(83, 80, 230);
color lineColor1 = color(175, 209, 252);
color lineColor2 = color(17, 5, 78);
color lineColor3 = color(62, 60, 129);

void setup() {
  size(800, 800, P3D);

  earthImage = loadImage("smallearth.png");
  time = 0;

  fileNamer = new FileNamer("output/frame", "png");

  isPaused = false;

  resetPoints();
}

void draw() {
  draw(g, time);

  if (!isPaused) {
    time += 0.02;
    while (time > 1) {
      resetPoints();
      time -= 1;
    }
  }
}

void draw(PGraphics g, float t) {
  float outerRadius = 40;
  float innerRadius = 10;
  PVector pos = PVector.add(PVector.mult(PVector.sub(endPoint, startPoint), t), startPoint);
  
  g.pushStyle();
  
  g.background(255);
  g.image(earthImage, 0, 0);
  
  g.fill(255, 64);
  g.rect(0, 0, width, height);
  
  g.stroke(0, 64);
  g.strokeWeight(8);
  g.line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);

  g.stroke(0);
  g.strokeWeight(2);
  g.line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);

  g.noStroke();
  g.fill(0, 64);
  g.ellipse(pos.x, pos.y, outerRadius, outerRadius);
  
  g.fill(0);
  g.ellipse(pos.x, pos.y, innerRadius, innerRadius);

  g.popStyle();
}

void resetPoints() {
  startPoint = new PVector(0, random(height));
  endPoint = new PVector(width, random(height));
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  g.background(0);

  int numIterations = 20;
  int numFrames = 30;
  for (int i = 0; i < numIterations; i++) {
    resetPoints();
    for (int j = 0; j < numFrames; j++) {
      draw(g, (float)j / numFrames);
      g.save(frameNamer.next());
    }
  }
}

void keyReleased() {
  switch (key) {
    case ' ':
      isPaused = !isPaused;
      break;
    case 'a':
      saveAnimation();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}