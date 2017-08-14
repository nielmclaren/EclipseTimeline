
import controlP5.*;
import peasy.*;

PGraphics buffer;

Sim sim;
PeasyCam cam;
Renderer renderer;
Cues cues;

String[] sceneNames;
String selectedSceneName;

float time;
float speed;
boolean isPaused;

ControlP5 cp5;
Slider speedInput;
Slider lunarOrbitInclineInput;

ArrayList<Float> spDeltaHistory;
ArrayList<Float> spDeltaLogHistory;
float spDeltaLogPower;
int spDeltaHistoryMaxSize;
Sparkline spDeltaSparkline;
Sparkline spDeltaLogSparkline;

FileNamer fileNamer;


void setup() {
  size(800, 800, P3D);

  buffer = createGraphics(width, height, P3D);
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();

  background(0);

  sim = new Sim();
  cam = new PeasyCam(this, buffer, 12000);
  cam.setActive(false);
  renderer = new Renderer();
  cues = new Cues(sim, cam, renderer);

  sceneNames = new String[]{"overhead", "intro", "intro_synodic", "intro_anomalistic", "intro_draconic"};
  selectedSceneName = "";
  cueScene(sceneNames[0]);

  time = 0;
  speed = 0.002;
  isPaused = false;
  
  cp5 = new ControlP5(this);
  
  setupInputs();

  spDeltaHistory = new ArrayList<Float>();
  spDeltaLogHistory = new ArrayList<Float>();
  spDeltaLogPower = 7;
  spDeltaHistoryMaxSize = 2000;
  spDeltaSparkline = new Sparkline(10, 0.8 * height, width - 20, 0.08 * height);
  spDeltaLogSparkline = new Sparkline(10, 0.9 * height, width - 20, 0.08 * height);

  fileNamer = new FileNamer("output/frame", "png");
}

void setupInputs() {
  float currY = 60;

  speedInput = cp5.addSlider("speedInput")
    .setRange(0.0001, 0.05)
    .setValue(0.002)
    .setPosition(20, currY);
  currY += 25;

  lunarOrbitInclineInput = cp5.addSlider("lunarOrbitInclineInput")
    .setRange(0, 30)
    .setValue(20)
    .setPosition(20, currY);
  currY += 25;
  
  for (int i = 0; i < sceneNames.length; i++) {
    cp5.addButton(sceneNames[i])
      .setPosition(20, currY)
      .setWidth(120);
    currY += 25;
  }
}

void draw() {
  if (!isPaused) {
    cues.update(time);
  }

  pushStyle();
  noStroke();
  fill(0, map(speed, 0.0001, 0.05, 255, 2));
  rect(0, 0, width, height);
  popStyle();

  updateBuffer(time);
  image(buffer, 0, 0);

  if (!isPaused) {
    updateHistories();
  }

  text(frameRate + " fps", 20, 20);
  text(selectedSceneName, 20, 40);
  drawHistories();

  if (!isPaused) {
    time += speed;
  }
}

void updateBuffer(float t) {
  PGraphics g = buffer;
  g.beginDraw();
  g.background(0, 0);
  renderer.draw(sim, g, t);
  g.endDraw();
}

void updateHistories() {
  spDeltaHistory.add(PI - sim.getStarPlanetPolarDistance(time));
  spDeltaLogHistory.add(pow(PI - sim.getStarPlanetPolarDistance(time), spDeltaLogPower));
  if (spDeltaHistory.size() > spDeltaHistoryMaxSize) {
    spDeltaHistory.remove(0);
  }
  if (spDeltaLogHistory.size() > spDeltaHistoryMaxSize) {
    spDeltaLogHistory.remove(0);
  }
}

void drawHistories() {
  spDeltaSparkline.draw(g, spDeltaHistory, spDeltaHistoryMaxSize, 0, PI);
  spDeltaLogSparkline.draw(g, spDeltaLogHistory, spDeltaHistoryMaxSize, 0, pow(PI, spDeltaLogPower));
}

void saveAnimation() {
  FileNamer animationNamer = new FileNamer("output/anim", "/");
  FileNamer frameNamer = new FileNamer(animationNamer.next() + "frame", "png");

  int numFrames = 300;
  for (int i = 0; i < numFrames; i++) {
    float t = (float)i / numFrames;
    buffer.beginDraw();
    renderer.draw(sim, buffer, t);
    buffer.endDraw();

    image(buffer, 0, 0);

    save(frameNamer.next());
  }
}

void keyReleased() {
  int keyNum = key - '0';
  if (keyNum >= 0 && keyNum < 10 && keyNum < sceneNames.length) {
    cueScene(sceneNames[keyNum]);
  }

  switch (key) {
    case ' ':
      isPaused = !isPaused;
      break;
    case 'a':
      saveAnimation();
      break;
    case 'b':
      buffer.beginDraw();
      buffer.background(0);
      buffer.endDraw();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}

void controlEvent(ControlEvent e) {
  if (e.isFrom(cp5.getController("speedInput"))) {
    float v = cp5.getController("speedInput").getValue();
    speed = v;
  }  else if (e.isFrom(cp5.getController("lunarOrbitInclineInput"))) {
    float v = cp5.getController("lunarOrbitInclineInput").getValue();
    sim.lunarOrbitInclineRad(radians(v));
  }  

  for (int i = 0; i < sceneNames.length; i++) {
    if (e.isFrom(cp5.getController(sceneNames[i]))) {
      cueScene(sceneNames[i]);
    }
  }
}

void cueScene(String sceneName) {
  cues.cue(sceneName);
  selectedSceneName = sceneName;
}