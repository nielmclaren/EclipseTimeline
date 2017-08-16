
import controlP5.*;
import peasy.*;
import processing.serial.*;

GyroReader gyroReader;

PGraphics backgroundBuffer;
PGraphics renderBuffer;
PGraphics fadeBuffer;

Sim sim;
PeasyCam backgroundCam;
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

  background(0);

  sim = new Sim();
  backgroundCam = new PeasyCam(this, backgroundBuffer, 12000);
  backgroundCam.setActive(false);
  cam = new PeasyCam(this, renderBuffer, 12000);
  cam.setActive(false);
  renderer = new Renderer();
  cues = new Cues(sim, new PeasyCam[]{backgroundCam, cam}, renderer);

  sceneNames = new String[]{"eclipse", "overhead", "intro", "intro_synodic", "intro_anomalistic", "intro_draconic"};
  selectedSceneName = "";
  cueScene(sceneNames[0]);

  time = 0;
  prevTime = 0;
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

  updateBackgroundBuffer();
  boolean drew = updateRenderBuffer();
  updateFadeBuffer(drew);

  if (drew) {
    blendMode(BLEND);
    image(backgroundBuffer, 0, 0);
    blendMode(ADD);
    image(fadeBuffer, 0, 0);
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
    drew = renderer.drawRange(sim, renderBuffer, prevTime, time);
    if (drew) {
      prevTime = renderer.lastDrawTime();
    }
  } else {
    // Draw the exact time when moving slowly.
    renderer.draw(sim, renderBuffer, time);
    prevTime = time;
    drew = true;
  }
  renderBuffer.endDraw();
  return drew;
}

void updateFadeBuffer(boolean drew) {
  if (drew) {
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