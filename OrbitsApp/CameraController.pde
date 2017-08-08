import peasy.org.apache.commons.math.geometry.*;

class CameraController {
  private final int FOLLOW_NONE = 0;
  private final int FOLLOW_PLANET_EXTERNAL = 1;
  private final int FOLLOW_PLANET_OVERHEAD = 2;
  private final int FOLLOW_PLANET_OVERHEAD_RELATIVE_TO_SUN = 3;
  private final int FOLLOW_PLANET_LUNAR_NODES_VIEW = 4;

  private Sim _sim;
  private PeasyCam _cam;

  private final PVector _center;

  private CameraSetting _current;
  private CameraSetting _start;
  private CameraSetting _target;

  private int _yawDirection;
  private float _durationMs;
  private long _startTime;

  private int _followMode;
  private boolean _isLockedOnPlanetOverhead;

  CameraController(Sim sim, PeasyCam cam) {
    _sim = sim;
    _cam = cam;

    _center = new PVector(0, 0, 0);

    _current = new CameraSetting();
    _start = null;
    _target = null;

    _yawDirection = 0;
    _durationMs = 0;
    _startTime = 0;

    _followMode = FOLLOW_NONE;
    _isLockedOnPlanetOverhead = false;
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
    _isLockedOnPlanetOverhead = false;
    return this;
  }

  CameraController followPlanetExternal(long durationMs) {
    if (_followMode != FOLLOW_PLANET_EXTERNAL) {
      _followMode = FOLLOW_PLANET_EXTERNAL;
      setInitialAnimationProperties(durationMs);
    }
    return this;
  }

  CameraController followPlanetLunarNodesView(long durationMs) {
    if (_followMode != FOLLOW_PLANET_LUNAR_NODES_VIEW) {
      _followMode = FOLLOW_PLANET_LUNAR_NODES_VIEW;
      setInitialAnimationProperties(durationMs);
    }
    return this;
  }

  CameraController followPlanetOverhead(long durationMs) {
    if (_followMode != FOLLOW_PLANET_OVERHEAD) {
      _followMode = FOLLOW_PLANET_OVERHEAD;
      setInitialAnimationProperties(durationMs);
    }
    return this;
  }

  CameraController followPlanetOverheadRelativeToSun(long durationMs) {
    if (_followMode != FOLLOW_PLANET_OVERHEAD_RELATIVE_TO_SUN) {
      _followMode = FOLLOW_PLANET_OVERHEAD_RELATIVE_TO_SUN;
      setInitialAnimationProperties(durationMs);
    }
    return this;
  }

  private void setInitialAnimationProperties(long durationMs) {
    _start = _current.clone();
    _yawDirection = _target == null ? 0 : getDirection(_start.yaw(), _target.yaw());
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
    _current = _current.merged(setting);
  }

  private CameraSetting getFollowCameraSetting(float t, int followMode) {
    switch (followMode) {
      case FOLLOW_PLANET_EXTERNAL:
        return getFollowPlanetExternalCameraSetting(t);
      case FOLLOW_PLANET_OVERHEAD:
        return getFollowPlanetOverheadCameraSetting(t);
      case FOLLOW_PLANET_OVERHEAD_RELATIVE_TO_SUN:
        return getFollowPlanetOverheadRelativeToSunCameraSetting(t);
      case FOLLOW_PLANET_LUNAR_NODES_VIEW:
        return getFollowPlanetLunarNodesViewCameraSetting(t);
      default:
        return new CameraSetting();
    }
  }

  private CameraSetting getFollowPlanetExternalCameraSetting(float t) {
    float planetRotation = normalizeAngle(HALF_PI + _sim.getPlanetRotation(t));
    return new CameraSetting()
      .yaw(planetRotation)
      .pitch(radians(15))
      .roll(0)
      .dist(_sim.planetOrbitDist() * 2.2)
      .lookAt(_center);
  }

  private CameraSetting getFollowPlanetOverheadCameraSetting(float t) {
    PVector planetPos = _sim.getPlanetPosition(t);
    float planetRotation = normalizeAngle(HALF_PI + _sim.getPlanetRotation(t));
    return new CameraSetting()
      .pitch(HALF_PI)
      .dist(_sim.moonMajorAxis() * 1.4)
      .lookAt(planetPos);
  }

  private CameraSetting getFollowPlanetOverheadRelativeToSunCameraSetting(float t) {
    PVector planetPos = _sim.getPlanetPosition(t);
    float planetRotation = HALF_PI + _sim.getPlanetRotation(t);
    return new CameraSetting()
      .yaw(planetRotation)
      .pitch(HALF_PI)
      .dist(_sim.moonMajorAxis() * 1.4)
      .lookAt(planetPos);
  }

  private CameraSetting getFollowPlanetLunarNodesViewCameraSetting(float t) {
    PVector planetPos = _sim.getPlanetPosition(t);
    return new CameraSetting()
      .yaw(2 * PI * 0.625)
      .pitch(radians(15))
      .roll(0)
      .dist(_sim.planetOrbitDist() * 1.2)
      .lookAt(planetPos);
  }

  private void updateAnimation() {
    float u = (millis() - _startTime) / _durationMs;
    if (u > 0.9999) {
      _current = _current.merged(_target);
      setCompletedAnimationProperties();
      _isLockedOnPlanetOverhead = isFollowPlanetOverhead();
    } else {
      if (_yawDirection == 0) {
        _yawDirection = getDirection(_start.yaw(), _target.yaw());
      }

      PVector lookAt;
      if (isFollowPlanetOverhead() && _isLockedOnPlanetOverhead) {
        lookAt = _target.lookAt();
      } else {
        lookAt = PVector.lerp(_start.lookAt(), _target.lookAt(), u);
      }

      _current = new CameraSetting()
        .yaw(_target.hasYaw() ? lerpAngle(_start.yaw(), _target.yaw(), u, _yawDirection) : _current.yaw())
        .pitch(_target.hasPitch() ? lerpAngle(_start.pitch(), _target.pitch(), u) : _current.pitch())
        .roll(_target.hasRoll() ? lerpAngle(_start.roll(), _target.roll(), u) : _current.roll())
        .dist(_target.hasDist() ? _start.dist() + u * (_target.dist() - _start.dist()) : _current.dist())
        .lookAt(lookAt);
    }
    updateCamera();
  }

  private boolean isFollowPlanetOverhead() {
    switch (_followMode) {
      case FOLLOW_PLANET_OVERHEAD:
      case FOLLOW_PLANET_OVERHEAD_RELATIVE_TO_SUN:
        return true;
      
      default:
        return false;
    }
  }

  private float lerpAngle(float a, float b, float amount) {
    return normalizeAngle(a + amount * getSignedAngleBetween(a, b));
  }

  private float lerpAngle(float a, float b, float amount, int direction) {
    return normalizeAngle(a + amount * getSignedAngleBetweenInDirection(a, b, direction));
  }

  private float normalizeAngle(float v) {
    while (v < 0) v += 2 * PI;
    return v % (2 * PI);
  }

  private void updateCamera() {
    Vector3D lookAt = toVector3D(_current.lookAt());
    Rotation rotation = new Rotation(RotationOrder.YXZ,
      _current.yaw(), _current.pitch(), _current.roll());
    _cam.setState(new CameraState(rotation, lookAt, _current.dist()), 0);
  }

  private Vector3D toVector3D(PVector v) {
    return new Vector3D(v.x, v.y, v.z);
  }

  private int getDirection(float a, float b) {
    float delta = getSignedAngleBetween(a, b);
    return floor(abs(delta) / delta);
  }

  private float getSignedAngleBetween(float a, float b) {
    float delta = b - a;
    if (abs(delta) > PI) {
      if (delta > 0) {
        return -2 * PI + delta;
      }
      return 2 * PI + delta;
    }
    return delta;
  }
  
  private float getSignedAngleBetweenInDirection(float a, float b, int direction) {
    if (b > a == direction > 0) {
      return b - a;
    }
    return direction * 2 * PI + b - a;
  }
}