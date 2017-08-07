
class CameraSetting {
  private boolean _hasYaw;
  private boolean _hasPitch;
  private boolean _hasRoll;
  private boolean _hasDist;
  private float _yaw;
  private float _pitch;
  private float _roll;
  private float _dist;
  private PVector _lookAt;

  CameraSetting() {
    _hasYaw = false;
    _hasPitch = false;
    _hasRoll = false;
    _hasDist = false;
    _yaw = 0;
    _pitch = 0;
    _roll = 0;
    _dist = 0;
    _lookAt = new PVector();
  }

  boolean hasYaw() {
    return _hasYaw;
  }

  boolean hasPitch() {
    return _hasPitch;
  }

  boolean hasRoll() {
    return _hasRoll;
  }

  boolean hasDist() {
    return _hasDist;
  }

  CameraSetting yaw(float v) {
    _hasYaw = true;
    _yaw = v;
    return this;
  }

  float yaw() {
    return _yaw;
  }

  CameraSetting pitch(float v) {
    _hasPitch = true;
    _pitch = v;
    return this;
  }

  float pitch() {
    return _pitch;
  }

  CameraSetting roll(float v) {
    _hasRoll = true;
    _roll = v;
    return this;
  }

  float roll() {
    return _roll;
  }

  CameraSetting dist(float v) {
    _hasDist = true;
    _dist = v;
    return this;
  }

  float dist() {
    return _dist;
  }

  CameraSetting lookAt(PVector v) {
    _lookAt = v.copy();
    return this;
  }

  PVector lookAt() {
    return _lookAt.copy();
  }
  
  CameraSetting clone() {
    CameraSetting setting = new CameraSetting();
    setting._hasYaw = _hasYaw;
    setting._hasPitch = _hasPitch;
    setting._hasRoll = _hasRoll;
    setting._hasDist = _hasDist;
    setting._yaw = _yaw;
    setting._pitch = _pitch;
    setting._roll = _roll;
    setting._dist = _dist;
    setting._lookAt = _lookAt;
    return setting;
  }

  CameraSetting merged(CameraSetting v) {
    CameraSetting setting = clone();
    if (v.hasYaw()) {
      setting.yaw(v.yaw());
    }
    if (v.hasPitch()) {
      setting.pitch(v.pitch());
    }
    if (v.hasRoll()) {
      setting.roll(v.roll());
    }
    if (v.hasDist()) {
      setting.dist(v.dist());
    }
    setting.lookAt(v.lookAt());
    return setting;
  }
}