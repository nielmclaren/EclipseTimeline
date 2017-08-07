import peasy.org.apache.commons.math.geometry.*;

class CameraController {
  private final int FOLLOW_NONE = 0;
  private final int FOLLOW_PLANET_EXTERNAL = 1;

  private Sim _sim;
  private PeasyCam _cam;

  private final Vector3D _center;

  private CameraSetting _current;
  private CameraSetting _start;
  private CameraSetting _target;

  private float _durationMs;
  private long _startTime;

  private int _followMode;

  CameraController(Sim sim, PeasyCam cam) {
    _sim = sim;
    _cam = cam;

    _center = new Vector3D(0, 0, 0);

    _current = new CameraSetting();
    _start = null;
    _target = null;

    _durationMs = 0;
    _startTime = 0;

    _followMode = FOLLOW_NONE;
  }

  CameraController animateTo(CameraSetting setting, long durationMs) {
    if (durationMs > 0) {
      _target = setting;
      setInitialAnimationProperties(durationMs);
    } else {
      _current = _current.merged(setting);
      setCompletedAnimationProperties();
    }
    _followMode = FOLLOW_NONE;
    return this;
  }

  CameraController followPlanetExternal(long durationMs) {
    setInitialAnimationProperties(durationMs);
    _followMode = FOLLOW_PLANET_EXTERNAL;
    return this;
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
      _current = _target.merged(_current);
      setCompletedAnimationProperties();
    } else {
      _current = new CameraSetting(
        _target.yaw() >= 0 ? _start.yaw() + u * getAngleBetween(_start.yaw(), _target.yaw()) : _current.yaw(),
        _target.pitch() >= 0 ? _start.pitch() + u * getAngleBetween(_start.pitch(), _target.pitch()) : _current.pitch(),
        _target.dist() >= 0 ? _start.dist() + u * (_target.dist() - _start.dist()) : _current.dist());
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