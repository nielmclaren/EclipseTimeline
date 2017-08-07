import peasy.org.apache.commons.math.geometry.*;

class Cues {
  private final int FOLLOW_NONE = 0;
  private final int FOLLOW_PLANET_EXTERNAL = 1;

  private PApplet _p;
  private Sim _sim;
  private PeasyCam _cam;
  private Renderer _renderer;

  private final Vector3D _center;

  private float _yaw;
  private float _pitch;
  private float _dist;

  private float _startYaw;
  private float _startPitch;
  private float _startDist;

  private float _targetYaw;
  private float _targetPitch;
  private float _targetDist;

  private float _durationMs;
  private long _startTime;

  private int _followMode;

  Cues(Sim sim, PeasyCam cam, Renderer renderer) {
    _sim = sim;
    _cam = cam;
    _renderer = renderer;

    _center = new Vector3D(0, 0, 0);

    _yaw = 0;
    _pitch = 0;
    _dist = 0;

    _startYaw = 0;
    _startPitch = 0;
    _startDist = 0;

    _targetYaw = 0;
    _targetPitch = 0;
    _targetDist = 0;

    _durationMs = 0;
    _startTime = 0;

    _followMode = FOLLOW_NONE;
  }

  Cues semExternalView() {
    return semExternalView(0);
  }

  Cues semExternalView(long durationMs) {
    if (durationMs > 0) {
      _startYaw = _yaw;
      _startPitch = _pitch;
      _startDist = _dist;

      _targetYaw = 0;
      _targetPitch = radians(15);
      _targetDist = _sim.planetOrbitDist() * 2.2;

      _durationMs = durationMs;
      _startTime = millis();
    } else {
      _yaw = 0;
      _pitch = radians(15);
      _dist = _sim.planetOrbitDist() * 2.2;

      _durationMs = 0;
      _startTime = 0;
    }
    _followMode = FOLLOW_NONE;
    return this;
  }

  Cues semSideView(long durationMs) {
    if (durationMs > 0) {
      _startYaw = _yaw;
      _startPitch = _pitch;
      _startDist = _dist;

      _targetYaw = 0;
      _targetPitch = 0;
      _targetDist = _sim.planetOrbitDist() * 2.2;

      _durationMs = durationMs;
      _startTime = millis();
    } else {
      _yaw = 0;
      _pitch = radians(15);
      _dist = _sim.planetOrbitDist() * 2.2;

      _durationMs = 0;
      _startTime = 0;
    }
    _followMode = FOLLOW_NONE;
    return this;
  }

  Cues planetExternal(long durationMs) {
    _followMode = FOLLOW_PLANET_EXTERNAL;

    _startYaw = _yaw;
    _startPitch = _pitch;
    _startDist = _dist;

    _durationMs = durationMs;
    _startTime = millis();

    return this;
  }

  Cues semClean() {
    _renderer.showSunPlanetLine(false);
    return this;
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
    _targetYaw = setting.yaw();
    _targetPitch = setting.pitch();
    _targetDist = setting.dist();
  }

  private void updateFollow(float t, int followMode) {
    CameraSetting setting = getFollowCameraSetting(t, followMode);
    _yaw = setting.yaw();
    _pitch = setting.pitch();
    _dist = setting.dist();
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
      _yaw = _targetYaw;
      _pitch = _targetPitch;
      _dist = _targetDist;

      _startYaw = 0;
      _startPitch = 0;
      _startDist = 0;

      _targetYaw = 0;
      _targetPitch = 0;
      _targetDist = 0;

      _durationMs = 0;
      _startTime = 0;
    } else {
      _yaw = _startYaw + u * getAngleBetween(_startYaw, _targetYaw);
      _pitch = _startPitch + u * getAngleBetween(_startPitch, _targetPitch);
      _dist = _startDist + u * (_targetDist - _startDist);
    }
    updateCamera();
  }

  private void updateCamera() {
    _cam.setState(new CameraState(new Rotation(RotationOrder.YXZ, _yaw, _pitch, 0), _center, _dist), 0);
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