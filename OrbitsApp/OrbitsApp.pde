
import controlP5.*;
import peasy.*;
import processing.serial.*;

GyroReader gyroReader;

PGraphics buffer;

Sim sim;
PeasyCam cam;
Renderer renderer;
Cues cues;

String[] sceneNames;
String selectedSceneName;

float time;
float prevTime;
boolean useGyro;
final boolean initialUseGyro = true;
float speed;
final float initialSpeed = sqrt(0.002);
boolean isPaused;
int fadeAmount;
final int initialFadeAmount = 240;

ArrayList<Float> spDeltaHistory;
ArrayList<Float> spDeltaLogHistory;
float spDeltaLogPower;
int spDeltaHistoryMaxSize;

ControlP5 cp5;
Toggle useGyroInput;
Slider speedInput;
Slider fadeInput;
Slider lunarOrbitInclineInput;
Sparkline spDeltaSparkline;
Sparkline spDeltaLogSparkline;
Sparkline gyroSparkline;

FileNamer fileNamer;


void setup() {
  size(800, 800, P3D);

  printArray(Serial.list());
  gyroReader = new GyroReader(new Serial(this, Serial.list()[1], 9600));

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
  isPaused = false;
  fadeAmount = initialFadeAmount;
  
  cp5 = new ControlP5(this);
  
  setupInputs();

  spDeltaHistory = new ArrayList<Float>();
  spDeltaLogHistory = new ArrayList<Float>();
  spDeltaLogPower = 7;
  spDeltaHistoryMaxSize = 2000;
  spDeltaSparkline = new Sparkline(10, 0.7 * height, width - 20, 0.08 * height);
  spDeltaLogSparkline = new Sparkline(10, 0.8 * height, width - 20, 0.08 * height);
  gyroSparkline = new Sparkline(10, 0.9 * height, width - 20, 0.08 * height);

  fileNamer = new FileNamer("output/frame", "png");
}

void setupInputs() {
  float currY = 60;

  useGyroInput = cp5.addToggle("useGyroInput")
    .setValue(initialUseGyro)
    .setPosition(20, currY);
  currY += 45;

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
  if (useGyro) {
    float v = map(gyroReader.magnitude(), 0, gyroReader.MAX_VALUE, 0.0002, 0.5);
    speed = gyroReader.direction() * v * v;
  }

  if (!isPaused) {
    cues.update(time);
  }

  boolean drew = false;
  buffer.beginDraw();
  buffer.background(0, 0);
  buffer.blendMode(ADD);
  if (abs(speed) > 1 / renderer.rangeStepsPerYear()) {
    // Draw quantized times when moving quickly.
    drew = renderer.drawRange(sim, buffer, prevTime, time);
    if (drew) {
      prevTime = renderer.lastDrawTime();
    }
  } else {
    // Draw the exact time when moving slowly.
    renderer.draw(sim, buffer, time);
    prevTime = time;
    drew = true;
  }
  buffer.endDraw();

  if (drew) {
    pushStyle();
    noStroke();
    fill(0, 255 - fadeAmount);
    rect(0, 0, width, height);
    popStyle();

    image(buffer, 0, 0);
  }

  if (!isPaused) {
    updateSparklines();
  }

  text(frameRate + " fps", 20, 20);
  text(selectedSceneName, 20, 40);
  drawSparklines();

  if (!isPaused) {
    time += speed;
  }
}

void updateSparklines() {
  spDeltaHistory.add(PI - sim.getStarPlanetPolarDistance(time));
  spDeltaLogHistory.add(pow(PI - sim.getStarPlanetPolarDistance(time), spDeltaLogPower));
  if (spDeltaHistory.size() > spDeltaHistoryMaxSize) {
    spDeltaHistory.remove(0);
  }
  if (spDeltaLogHistory.size() > spDeltaHistoryMaxSize) {
    spDeltaLogHistory.remove(0);
  }
  gyroReader.update();
}

void drawSparklines() {
  spDeltaSparkline.draw(g, spDeltaHistory, spDeltaHistoryMaxSize, 0, PI);
  spDeltaLogSparkline.draw(g, spDeltaLogHistory, spDeltaHistoryMaxSize, 0, pow(PI, spDeltaLogPower));
  gyroSparkline.draw(g, gyroReader.magnitudeHistory(), gyroReader.MAX_READINGS, 0, gyroReader.MAX_VALUE);
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
  if (e.isFrom(cp5.getController("useGyroInput"))) {
    boolean v = cp5.getController("useGyroInput").getValue() != 0;
    useGyro = v;

    if (!useGyro) {
      float speedValue = cp5.getController("speedInput").getValue();
      speed = speedValue * speedValue;
    }

    println("Use gyro: " + useGyro);
  } else if (e.isFrom(cp5.getController("speedInput"))) {
    float v = cp5.getController("speedInput").getValue();
    speed = v * v;

    useGyroInput.setValue(false);
    useGyro = false;

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