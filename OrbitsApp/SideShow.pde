
class SideShow {
  private int _id;
  private int _width;
  private int _height;

  private GyroReader _gyroReader;

  private PGraphics _renderBuffer;

  private Sim _sim;
  private Renderer _renderer;
  private Cues _cues;

  private String[] _sceneNames;

  private float _time;
  private float _lastDrawTime;

  private float _speed;
  private boolean _isPaused;

  SideShow(int id, int w, int h) {
    _id = id;
    _width = w;
    _height = h;

    _renderBuffer = createBuffer(w, h, P3D);

    float pw = 1920;
    float ph = 1080; 
    float cameraZ = (ph/2.0) / tan(PI*60.0/360.0);
    _renderBuffer.beginDraw();
    _renderBuffer.perspective(PI/3.0, pw/ph, cameraZ/10.0, cameraZ*10.0);
    _renderBuffer.endDraw();

    _sim = new Sim();

    PeasyCam renderCam = createCam(_renderBuffer);

    _renderer = new Renderer();
    _cues = new Cues(_sim, new PeasyCam[]{renderCam}, _renderer).scale(0.4);

    _time = 0;
    _lastDrawTime = 0;

    _speed = sqrt(0.002);
    _isPaused = false;
  }

  SideShow cue(String sceneName) {
    _cues.cue(sceneName);
    return this;
  }

  SideShow gyroReader(GyroReader v) {
    _gyroReader = v;
    return this;
  }

  SideShow isPaused(boolean v) {
    _isPaused = v;
    return this;
  }

  PGraphics renderBuffer() {
    return _renderBuffer;
  }

  SideShow sceneNames(String[] v) {
    _sceneNames = v;
    _cues.cue(_sceneNames[floor(random(_sceneNames.length))]);
    return this;
  }

  boolean update() {
    float v = map(_gyroReader.magnitude(_id), 0, gyroReader.MAX_VALUE, 0.0002, 0.5);
    _speed = -_gyroReader.direction(_id) * v * v;

    if (!_isPaused) {
      _cues.update(_time);
    }

    boolean drew = updateRenderBuffer();

    if (!_isPaused) {
      _time += _speed;
    }

    return drew;
  }

  boolean updateRenderBuffer() {
    boolean drew = false;
    _renderBuffer.beginDraw();
    _renderBuffer.background(0);
    _renderBuffer.blendMode(BLEND);
    if (abs(_speed) > 1 / _renderer.rangeStepsPerYear()) {
      // Draw quantized times when moving quickly.
      drew = _renderer.drawRange(_sim, _renderBuffer, _lastDrawTime, _time);
      if (drew) {
        _lastDrawTime = _renderer.lastDrawTime();
      }
    } else {
      // Draw the exact time when moving slowly.
      _renderer.draw(_sim, _renderBuffer, _time);
      _lastDrawTime = _time;
      drew = true;
    }
    _renderBuffer.endDraw();
    return drew;
  }
}