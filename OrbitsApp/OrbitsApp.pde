
import controlP5.*;
import peasy.*;

Sim sim;
PeasyCam cam;
Renderer renderer;
float time;

ControlP5 cp5;
Slider lunarOrbitInclineInput;

FileNamer fileNamer;

PGraphics buffer;

void setup() {
  size(800, 800, P3D);

  sim = new Sim();
  renderer = new Renderer();
  time = 0;
  
  cp5 = new ControlP5(this);
  
  lunarOrbitInclineInput = cp5.addSlider("lunarOrbitInclineInput")
    .setRange(0, 30)
    .setValue(20)
    .setPosition(20, 20);

  fileNamer = new FileNamer("output/frame", "png");

  buffer = createGraphics(width, height, P3D);
  cam = new PeasyCam(this, buffer, 12000);

  cam.setMinimumDistance(500);
  cam.setMaximumDistance(5000);
}

void draw() {
  buffer.beginDraw();
  setupLight(buffer);
  renderer.draw(sim, buffer, time);
  buffer.endDraw();

  image(buffer, 0, 0);

  time += 0.001;
  while (time > 1) {
    time -= 1;
  }
}

void setupLight(PGraphics g) {
  g.ambientLight(255, 255, 255);
  
  g.pushMatrix();
  g.translate(0, -1500, -2000);
  g.popMatrix();
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    float t = (float)i / numFrames;
    buffer.beginDraw();
    setupLight(buffer);
    renderer.draw(sim, buffer, t);
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
    sim.lunarOrbitInclineRad(radians(v));
  }  
}