
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
float prevTime;
float speed;
final float initialSpeed = sqrt(0.002);
boolean isPaused;
int fadeAmount;
final int initialFadeAmount = 240;

ControlP5 cp5;
Slider speedInput;
Slider fadeInput;
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
  prevTime = 0;
  speed = initialSpeed;
  isPaused = false;
  fadeAmount = initialFadeAmount;
  
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
    .setRange(sqrt(0.0001), sqrt(0.5))
    .setValue(initialSpeed)
    .setPosition(20, currY);
  currY += 25;

  fadeInput = cp5.addSlider("fadeInput")
    .setRange(0, 255)
    .setValue(initialFadeAmount)
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
  float lastDrawTime = -1;

  if (!isPaused) {
    cues.update(time);
  }

  buffer.beginDraw();
  buffer.background(0, 0);
  buffer.blendMode(ADD);
  if (speed > 1 / renderer.rangeStepsPerYear()) {
    // Draw quantized times when moving quickly.
    lastDrawTime = renderer.drawRange(sim, buffer, prevTime, time);
  } else {
    // Draw the exact time when moving slowly.
    renderer.draw(sim, buffer, time);
    lastDrawTime = time;
  }
  buffer.endDraw();

  if (lastDrawTime >= 0) {
    pushStyle();
    noStroke();
    fill(0, 255 - fadeAmount);
    rect(0, 0, width, height);
    popStyle();

    image(buffer, 0, 0);
  }

  if (!isPaused) {
    updateHistories();
  }

  text(frameRate + " fps", 20, 20);
  text(selectedSceneName, 20, 40);
  drawHistories();

  if (!isPaused) {
    time += speed;
  }

  if (lastDrawTime >= 0) {
    prevTime = lastDrawTime;
  }
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
    speed = v * v;
    println("Speed: " + speed);
  } else if (e.isFrom(cp5.getController("fadeInput"))) {
    float v = cp5.getController("fadeInput").getValue();
    fadeAmount = floor(v);
    println("Fade amount: " + fadeAmount);
  }  else if (e.isFrom(cp5.getController("lunarOrbitInclineInput"))) {
    float v = cp5.getController("lunarOrbitInclineInput").getValue();
    sim.lunarOrbitInclineRad(radians(v));
    println("Lunar orbit incline: " + v);
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