
import controlP5.*;
import peasy.*;
import processing.serial.*;

GyroReader gyroReader;

PGraphics backgroundBuffer;
PGraphics renderBuffer;
PGraphics fadeBuffer;
PGraphics compositeBuffer;
PGraphics longTermBuffer;

Sim sim;
Renderer renderer;
LongTermRenderer longTermRenderer;
Cues cues;

String[] sceneNames;
String selectedSceneName;

float time;
float lastDrawTime;
boolean isLongTermMode;
float longTermStartTime;

boolean useGyro;
final boolean initialUseGyro = true;
float speed;
final float initialSpeed = sqrt(0.002);
boolean isPaused;
int fadeAmount;
final int initialFadeAmount = 220;

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
  fullScreen(P3D);

  printArray(Serial.list());
  gyroReader = new GyroReader(new Serial(this, Serial.list()[1], 9600));

  backgroundBuffer = createBuffer(width, height, P3D);
  renderBuffer = createBuffer(width, height, P3D);
  fadeBuffer = createBuffer(width, height, P3D);
  fadeBuffer.beginDraw();
  fadeBuffer.blendMode(BLEND);
  fadeBuffer.noStroke();
  fadeBuffer.endDraw();
  compositeBuffer = createBuffer(width, height, P3D);
  longTermBuffer = createBuffer(width, height, P3D);

  background(0);

  sim = new Sim();
  PeasyCam backgroundCam = createCam(backgroundBuffer);
  PeasyCam renderCam = createCam(renderBuffer);
  PeasyCam longTermCam = createCam(longTermBuffer);

  renderer = new Renderer();
  longTermRenderer = new LongTermRenderer();
  cues = new Cues(sim, new PeasyCam[]{backgroundCam, renderCam, longTermCam}, renderer);

  sceneNames = new String[]{"overhead", "intro", "eclipse", "intro_synodic", "intro_anomalistic", "intro_draconic"};
  selectedSceneName = "";
  cueScene(sceneNames[0]);

  time = 0;
  lastDrawTime = 0;
  isLongTermMode = false;
  longTermStartTime = 0;

  useGyro = initialUseGyro;
  speed = initialSpeed;
  isPaused = false;
  fadeAmount = initialFadeAmount;
  
  cp5 = new ControlP5(this);
  
  setupInputs();

  spDeltaHistory = new ArrayList<Float>();
  spDeltaLogHistory = new ArrayList<Float>();
  spDeltaLogPower = 7;
  spDeltaHistoryMaxSize = 2000;
  spDeltaSparkline = new Sparkline(10, 0.85 * height, width * 0.25 - 20, 0.04 * height);
  spDeltaLogSparkline = new Sparkline(10, 0.9 * height, width * 0.25 - 20, 0.04 * height);
  gyroSparkline = new Sparkline(10, 0.95 * height, width * 0.25 - 20, 0.04 * height);

  fileNamer = new FileNamer("output/frame", "png");
}

PGraphics createBuffer(int w, int h, String mode) {
  PGraphics g = createGraphics(w, h, mode);
  g.beginDraw();
  g.background(0);
  g.endDraw();
  return g;
}

PeasyCam createCam(PGraphics buffer) {
  PeasyCam cam = new PeasyCam(this, buffer, 12000);
  cam.setActive(false);
  return cam;
}

void setupInputs() {
  float currY = 60;

  speedInput = cp5.addSlider("speedInput")
    .setRange(sqrt(0.0001), sqrt(0.5))
    .setValue(initialSpeed)
    .setPosition(20, currY);
  currY += 25;

  useGyroInput = cp5.addToggle("useGyroInput")
    .setValue(initialUseGyro)
    .setPosition(20, currY);
  currY += 45;

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

  if (isLongTermMode) {
    drawLongTermBuffer();
  } else {
    updateBackgroundBuffer();
    boolean drew = updateRenderBuffer();
    if (drew) {
      updateFadeBuffer();
      updateCompositeBuffer();
      drawCompositeBuffer();
    }
  }

  if (!isPaused) {
    updateSparklines();
  }

  blendMode(BLEND);
  text(frameRate + " fps", 20, 20);
  text(selectedSceneName, 20, 40);
  drawSparklines();

  if (!isPaused) {
    time += speed;
  }
}

void updateBackgroundBuffer() {
  backgroundBuffer.beginDraw();
  renderer.drawBackground(sim, backgroundBuffer);
  backgroundBuffer.endDraw();
}

boolean updateRenderBuffer() {
  boolean drew = false;
  renderBuffer.beginDraw();
  renderBuffer.background(0, 0);
  renderBuffer.blendMode(BLEND);
  if (abs(speed) > 1 / renderer.rangeStepsPerYear()) {
    // Draw quantized times when moving quickly.
    drew = renderer.drawRange(sim, renderBuffer, lastDrawTime, time);
    if (drew) {
      lastDrawTime = renderer.lastDrawTime();
    }
  } else {
    // Draw the exact time when moving slowly.
    renderer.draw(sim, renderBuffer, time);
    lastDrawTime = time;
    drew = true;
  }
  renderBuffer.endDraw();
  return drew;
}

void updateFadeBuffer() {
  fadeBuffer.beginDraw();
  fadeBuffer.fill(0, 255 - fadeAmount);
  fadeBuffer.rect(0, 0, width, height);
  fadeBuffer.endDraw();

  if (fadeAmount > 230) {
    // Correct the Processing bug where it never completely fades out.
    fadeBuffer.loadPixels();
    for (int i = 0; i < fadeBuffer.pixels.length; i++) {
      color pixel = fadeBuffer.pixels[i];
      fadeBuffer.pixels[i] = brightness(pixel) < 16 ? color(0) : pixel;
    }
    fadeBuffer.updatePixels();
  }

  fadeBuffer.beginDraw();
  fadeBuffer.image(renderBuffer, 0, 0);
  fadeBuffer.endDraw();
}

void updateCompositeBuffer() {
  compositeBuffer.beginDraw();
  compositeBuffer.blendMode(BLEND);
  compositeBuffer.image(backgroundBuffer, 0, 0);
  compositeBuffer.blendMode(ADD);
  compositeBuffer.image(fadeBuffer, 0, 0);
  compositeBuffer.endDraw();
}

void drawCompositeBuffer() {
  pushStyle();
  blendMode(BLEND);
  image(compositeBuffer, 0, 0);
  popStyle();
}

boolean drawLongTermBuffer() {
  float delta = time - lastDrawTime;
  if (delta == 0) {
    return false;
  }

  int rangeStepsPerYear = 600;
  int direction = (int)(abs(delta) / delta);
  float t = (float)ceil(lastDrawTime * rangeStepsPerYear) / rangeStepsPerYear;
  float maxX = width - 480;

  boolean drew = false;
  while ((t <= time) == (direction >= 0)) {
    float x = -(t - longTermStartTime) * 120;
    float y = 270 * floor(x / maxX);
    x = x % maxX;

    longTermBuffer.beginDraw();
    longTermBuffer.background(0, 0);
    longTermRenderer.draw(sim, longTermBuffer, t);
    longTermBuffer.endDraw();

    blendMode(ADD);
    image(longTermBuffer, x, y, 480, 270);

    drew = true;
    lastDrawTime = t;
    t += 1.0 / rangeStepsPerYear * direction;
  }

  return drew;
}

void updateSparklines() {
  spDeltaHistory.add(PI - sim.getStarMoonPolarDistance(time));
  spDeltaLogHistory.add(pow(PI - sim.getStarMoonPolarDistance(time), spDeltaLogPower));
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
    renderBuffer.beginDraw();
    renderer.draw(sim, renderBuffer, t);
    renderBuffer.endDraw();

    image(renderBuffer, 0, 0);

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
    case 'r':
      save(fileNamer.next());
      break;
    case 't':
      longTermBuffer.beginDraw();
      longTermBuffer.background(0);
      longTermBuffer.endDraw();
      isLongTermMode = !isLongTermMode;
      longTermStartTime = time;
      break;
  }
}

void controlEvent(ControlEvent e) {
  if (e.isFrom(cp5.getController("useGyroInput"))) {
    boolean v = cp5.getController("useGyroInput").getValue() != 0;
    useGyro = v;

    if (!useGyro && speedInput != null) {
      float speedValue = speedInput.getValue();
      speed = speedValue * speedValue;
    }
    println("Use gyro: " + useGyro);
  } else if (e.isFrom(cp5.getController("speedInput"))) {
    float v = cp5.getController("speedInput").getValue();
    speed = v * v;

    if (useGyroInput != null) {
      useGyroInput.setValue(false);
    }
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