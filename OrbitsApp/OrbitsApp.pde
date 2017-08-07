
import controlP5.*;
import peasy.*;

PGraphics buffer;

Sim sim;
PeasyCam cam;
Renderer renderer;
Cues cues;

float time;

ControlP5 cp5;
Slider lunarOrbitInclineInput;

FileNamer fileNamer;


void setup() {
  size(800, 800, P3D);

  buffer = createGraphics(width, height, P3D);

  sim = new Sim();
  cam = new PeasyCam(this, buffer, 12000);
  cam.setActive(false);
  renderer = new Renderer();
  cues = new Cues(sim, cam, renderer);
  cues.semExternalView(2000);

  time = 0;
  
  cp5 = new ControlP5(this);
  
  lunarOrbitInclineInput = cp5.addSlider("lunarOrbitInclineInput")
    .setRange(0, 30)
    .setValue(20)
    .setPosition(20, 20);

  fileNamer = new FileNamer("output/frame", "png");
}

void draw() {
  cues.update(time);

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
    case '1':
      cues.semExternalView(2000);
      break;
    case '2':
      cues.semOverhead(2000);
      break;
    case '3':
      cues.planetExternal(2000);
      break;
    case '4':
      cues.planetOverhead(2000);
      break;
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