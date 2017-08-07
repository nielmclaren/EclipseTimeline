import peasy.org.apache.commons.math.geometry.*;

class Cues {
  private final int FOLLOW_NONE = 0;
  private final int FOLLOW_PLANET_EXTERNAL = 1;

  private PApplet _p;
  private Sim _sim;
  private PeasyCam _cam;
  private Renderer _renderer;

  private final Vector3D _center;

  private CameraSetting _current;
  private CameraSetting _start;
  private CameraSetting _target;

  private float _durationMs;
  private long _startTime;

  private int _followMode;

  Cues(Sim sim, PeasyCam cam, Renderer renderer) {
    _sim = sim;
    _cam = cam;
    _renderer = renderer;

    _center = new Vector3D(0, 0, 0);

    _current = new CameraSetting();
    _start = null;
    _target = null;

    _durationMs = 0;
    _startTime = 0;

    _followMode = FOLLOW_NONE;
  }

  Cues semExternalView() {
    return semExternalView(0);
  }

  Cues semExternalView(long durationMs) {
    animateTo(new CameraSetting(0, radians(15), _sim.planetOrbitDist() * 2.2), durationMs);
    _followMode = FOLLOW_NONE;
    return this;
  }

  Cues semSideView(long durationMs) {
    animateTo(new CameraSetting(0, 0, _sim.planetOrbitDist() * 2.2), durationMs);
    _followMode = FOLLOW_NONE;
    return this;
  }

  Cues planetExternal(long durationMs) {
    _followMode = FOLLOW_PLANET_EXTERNAL;
    setInitialAnimationProperties(durationMs);
    return this;
  }

  Cues semClean() {
    _renderer.showSunPlanetLine(false);
    return this;
  }

  private void animateTo(CameraSetting setting, long durationMs) {
    if (durationMs > 0) {
      _target = setting;
      setInitialAnimationProperties(durationMs);
    } else {
      _current = setting;
      setCompletedAnimationProperties();
    }
  }

  private void setInitialAnimationProperties(long durationMs) {
    _start = _current.clone();
    _durationMs = durationMs;
    _startTime = millis();
  }

  private void setCompletedAnimationProperties() {
    _start = null;
    _target = null;
    _durationMs = 0;
    _startTime = 0;
  }

  public void update(float t) {
    if (_followMode != FOLLOW_NONE) {
      if (_durationMs > 0) {
        updateFollowTarget(t, _followMode);
        updateAnimation();
      } else {
        updateFollow(t, _followMode);
        updateCamera();
      }
    }
    if (_durationMs > 0) {
      updateAnimation();
    }
  }

  private void updateFollowTarget(float t, int followMode) {
    CameraSetting setting = getFollowCameraSetting(t, followMode);
    _target = setting;
  }

  private void updateFollow(float t, int followMode) {
    CameraSetting setting = getFollowCameraSetting(t, followMode);
    _current = setting;
  }

  private CameraSetting getFollowCameraSetting(float t, int followMode) {
    switch (followMode) {
      case FOLLOW_PLANET_EXTERNAL:
        return new CameraSetting(
          PI/2 + _sim.getPlanetRotation(t),
          radians(15),
          _sim.planetOrbitDist() * 2.2);
      default:
        return new CameraSetting();
    }
  }

  private void updateAnimation() {
    float u = (millis() - _startTime) / _durationMs;
    if (u > 0.99) {
      _current = _target.clone();
      setCompletedAnimationProperties();
    } else {
      _current = new CameraSetting(
        _start.yaw() + u * getAngleBetween(_start.yaw(), _target.yaw()),
        _start.pitch() + u * getAngleBetween(_start.pitch(), _target.pitch()),
        _start.dist() + u * (_target.dist() - _start.dist()));
    }
    updateCamera();
  }

  private void updateCamera() {
    _cam.setState(new CameraState(
      new Rotation(RotationOrder.YXZ, _current.yaw(), _current.pitch(), 0),
      _center, _current.dist()), 0);
  }

  private float getAngleBetween(float a, float b) {
    float delta = b - a;
    if (abs(delta) > PI) {
      if (delta > 0) {
        return -2 * PI + delta;
      }
      return 2 * PI + delta;
    }
    return delta;
  }
}