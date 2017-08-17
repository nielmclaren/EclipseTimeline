
import controlP5.*;
import peasy.*;
import processing.serial.*;

GyroReader gyroReader;

int mainWidth;
int mainHeight;
int sideWidth;
int sideHeight;
int sparklineHeight;
int sparklineSpacing;
int sideSpacing;

PGraphics backgroundBuffer;
PGraphics renderBuffer;
PGraphics fadeBuffer;
PGraphics compositeBuffer;
PGraphics longTermRenderBuffer;
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

SideShow topRightShow;
SideShow midRightShow;

Map<Integer, ArrayList<Float>> spDeltaHistoryMap;
Map<Integer, ArrayList<Float>> spDeltaLogHistoryMap;
float spDeltaLogPower;
int spDeltaHistoryMaxSize;

ControlP5 cp5;
Toggle useGyroInput;
Slider speedInput;
Slider fadeInput;
Slider lunarOrbitInclineInput;
Sparkline[] spDeltaSparklines;
Sparkline[] spDeltaLogSparklines;
Sparkline[] gyroSparklines;

FileNamer fileNamer;


void setup() {
  fullScreen(P3D);

  Palette.lineColor0 = color(83, 80, 230);
  Palette.lineColor1 = color(175, 209, 252);
  Palette.lineColor2 = color(17, 5, 78);
  Palette.lineColor3 = color(139, 24, 90);

  mainWidth = floor(width * 0.7);
  mainHeight = floor(height);
  sideWidth = floor(width * 0.3);
  sideHeight = floor(height * 1/3);
  sparklineHeight = 50;
  sparklineSpacing = 4;
  sideSpacing = 15;

  printArray(Serial.list());
  gyroReader = new GyroReader(new Serial(this, Serial.list()[1], 9600));

  backgroundBuffer = createBuffer(mainWidth, mainHeight, P3D);
  renderBuffer = createBuffer(mainWidth, mainHeight, P3D);
  fadeBuffer = createBuffer(mainWidth, mainHeight, P3D);
  fadeBuffer.beginDraw();
  fadeBuffer.blendMode(BLEND);
  fadeBuffer.noStroke();
  fadeBuffer.endDraw();
  compositeBuffer = createBuffer(mainWidth, mainHeight, P3D);
  longTermRenderBuffer = createBuffer(mainWidth, mainHeight, P3D);
  longTermBuffer = createBuffer(mainWidth, mainHeight, P3D);

  background(0);

  sim = new Sim();

  PeasyCam backgroundCam = createCam(backgroundBuffer);
  PeasyCam renderCam = createCam(renderBuffer);
  PeasyCam longTermRenderCam = createCam(longTermRenderBuffer);
  PeasyCam longTermCam = createCam(longTermBuffer);

  renderer = new Renderer();
  longTermRenderer = new LongTermRenderer();
  cues = new Cues(sim, new PeasyCam[]{backgroundCam, renderCam, longTermRenderCam, longTermCam}, renderer);

  sceneNames = new String[]{"intro", "eclipse", "overhead", "synodic", "anomalistic", "draconic"};
  selectedSceneName = "";
  cueScene("intro");

  time = 0;
  lastDrawTime = 0;
  isLongTermMode = false;
  longTermStartTime = 0;

  useGyro = initialUseGyro;
  speed = initialSpeed;
  isPaused = false;
  fadeAmount = initialFadeAmount;

  String[] sideBarSceneNames = new String[]{"intro", "eclipse", "intro_draconic"};
  topRightShow = new SideShow(1, sideWidth, sideHeight).gyroReader(gyroReader).sceneNames(sideBarSceneNames).cue("eclipse");
  midRightShow = new SideShow(2, sideWidth, sideHeight).gyroReader(gyroReader).sceneNames(sideBarSceneNames).cue("draconic");

  cp5 = new ControlP5(this);
  
  setupInputs();

  spDeltaHistoryMap = new HashMap<Integer, ArrayList<Float>>();
  spDeltaLogHistoryMap = new HashMap<Integer, ArrayList<Float>>();
  spDeltaLogPower = 7;
  spDeltaHistoryMaxSize = 2000;

  for (int i = 0; i < gyroReader.NUM_GYROS; i++) {
    spDeltaHistoryMap.put(i, new ArrayList<Float>());
    spDeltaLogHistoryMap.put(i, new ArrayList<Float>());
  }

  float x = width - sideWidth;
  float h = (sideHeight + 3 * sparklineHeight + 3 * sparklineSpacing + sideSpacing);

  spDeltaSparklines = new Sparkline[3];
  spDeltaLogSparklines = new Sparkline[3];
  gyroSparklines = new Sparkline[3];

  spDeltaSparklines[0] = new Sparkline(5, height - 3 * (sparklineHeight + sparklineSpacing), sideWidth, sparklineHeight);
  spDeltaLogSparklines[0] = new Sparkline(5, height - 2 * (sparklineHeight + sparklineSpacing), sideWidth, sparklineHeight);
  gyroSparklines[0] = new Sparkline(5, height - (sparklineHeight + sparklineSpacing), sideWidth, sparklineHeight);

  spDeltaSparklines[1] = new Sparkline(x, sideHeight + sparklineSpacing, sideWidth, sparklineHeight);
  spDeltaLogSparklines[1] = new Sparkline(x, sideHeight + 2 * sparklineSpacing + sparklineHeight, sideWidth, sparklineHeight);
  gyroSparklines[1] = new Sparkline(x, sideHeight + 3 * sparklineSpacing + 2 * sparklineHeight, sideWidth, sparklineHeight);

  spDeltaSparklines[2] = new Sparkline(x, h + sideHeight + sparklineSpacing, sideWidth, sparklineHeight);
  spDeltaLogSparklines[2] = new Sparkline(x, h + sideHeight + 2 * sparklineSpacing + sparklineHeight, sideWidth, sparklineHeight);
  gyroSparklines[2] = new Sparkline(x, h + sideHeight + 3 * sparklineSpacing + 2 * sparklineHeight, sideWidth, sparklineHeight);

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
    float v = map(gyroReader.magnitude(0), 0, gyroReader.MAX_VALUE, 0.0002, 0.5);
    speed = -gyroReader.direction(0) * v * v;
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
    topRightShow.update();
    midRightShow.update();
  }

  drawSideBar();

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
  fadeBuffer.rect(0, 0, fadeBuffer.width, fadeBuffer.height);
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

  int frameWidth = 160;
  int frameHeight = 135;

  int rangeStepsPerYear = 600;
  int direction = (int)(abs(delta) / delta);
  float t = (float)ceil(lastDrawTime * rangeStepsPerYear) / rangeStepsPerYear;
  float maxX = mainWidth - frameWidth;

  boolean drew = false;
  while ((t <= time) == (direction >= 0)) {
    float x = (t - longTermStartTime) * (maxX / (float)sim.sarosCycle());
    float y = frameHeight * floor(x / maxX);
    x = x % maxX;

    longTermRenderBuffer.beginDraw();
    longTermRenderBuffer.background(0, 0);
    longTermRenderer.draw(sim, longTermRenderBuffer, t);
    longTermRenderBuffer.endDraw();

    blendMode(ADD);
    image(longTermRenderBuffer, x, y, frameWidth, frameHeight);
    blendMode(BLEND);

    drew = true;
    lastDrawTime = t;
    t += 1.0 / rangeStepsPerYear * direction;
  }


  return drew;
}

void drawSideBar() {
  float x = width - sideWidth;
  float h = (sideHeight + 3 * sparklineHeight + 3 * sparklineSpacing + sideSpacing);

  image(topRightShow.renderBuffer(), x, h * 0);
  image(midRightShow.renderBuffer(), x, h * 1);

  noFill();
  stroke(Palette.lineColor2);
  strokeWeight(2);
  rect(x, h * 0, sideWidth, sideHeight);
  rect(x, h * 1, sideWidth, sideHeight);
}

void updateSparklines() {
  for (int i = 0; i < gyroReader.NUM_GYROS; i++) {
    ArrayList<Float> spDeltaHistory = spDeltaHistoryMap.get(i);
    ArrayList<Float> spDeltaLogHistory = spDeltaLogHistoryMap.get(i);

    float dist = 0;
    if (i == 0) {
      dist = sim.getStarMoonPolarDistance(time);
    } else if (i == 1) {
      dist = topRightShow.getStarMoonPolarDistance();
    } else {
      dist = midRightShow.getStarMoonPolarDistance();
    }

    spDeltaHistory.add(dist);
    if (spDeltaHistory.size() > spDeltaHistoryMaxSize) {
      spDeltaHistory.remove(0);
    }

    spDeltaLogHistory.add(pow(PI - dist, spDeltaLogPower));
    if (spDeltaLogHistory.size() > spDeltaHistoryMaxSize) {
      spDeltaLogHistory.remove(0);
    }
  }

  gyroReader.update();
}

void drawSparklines() {
  for (int i = 0; i < gyroSparklines.length; i++) {
    spDeltaSparklines[i].draw(g, spDeltaHistoryMap.get(i), spDeltaHistoryMaxSize, 0, PI);
    spDeltaLogSparklines[i].draw(g, spDeltaLogHistoryMap.get(i), spDeltaHistoryMaxSize, 0, pow(PI, spDeltaLogPower));
    gyroSparklines[i].draw(g, gyroReader.magnitudeHistory(i), gyroReader.MAX_READINGS, 0, gyroReader.MAX_VALUE);
  }
}

void initLongTermMode() {
  cueScene("overhead");
  background(0);
  longTermRenderBuffer.beginDraw();
  longTermRenderBuffer.background(0);
  longTermRenderBuffer.endDraw();
  longTermBuffer.beginDraw();
  longTermBuffer.background(0);
  longTermBuffer.endDraw();
}

void cueScene(String sceneName) {
  cues.cue(sceneName);
  selectedSceneName = sceneName;
}

void keyReleased() {
  int keyNum = key - '0';
  if (keyNum >= 0 && keyNum < 10 && keyNum < sceneNames.length) {
    cueScene(sceneNames[keyNum]);
  }

  switch (key) {
    case ' ':
      isPaused = !isPaused;
      topRightShow.isPaused(isPaused);
      midRightShow.isPaused(isPaused);
      break;
    case 'r':
      save(fileNamer.next());
      break;
    case 't':
      isLongTermMode = !isLongTermMode;
      longTermStartTime = time;
      if (isLongTermMode) {
        initLongTermMode();
      }
      println("Long term mode:", isLongTermMode);
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