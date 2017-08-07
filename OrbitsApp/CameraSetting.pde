
class CameraSetting {
  private float _yaw;
  private float _pitch;
  private float _dist;
  private PVector _lookAt;

  CameraSetting() {
    _yaw = 0;
    _pitch = 0;
    _dist = 0;
    _lookAt = new PVector();
  }

  CameraSetting(float yaw, float pitch, float dist) {
    _yaw = yaw;
    _pitch = pitch;
    _dist = dist;
    _lookAt = new PVector();
  }

  CameraSetting(float yaw, float pitch, float dist, PVector lookAt) {
    _yaw = yaw;
    _pitch = pitch;
    _dist = dist;
    _lookAt = lookAt;
  }

  float yaw() {
    return _yaw;
  }

  float pitch() {
    return _pitch;
  }

  float dist() {
    return _dist;
  }

  PVector lookAt() {
    return _lookAt.copy();
  }
  
  CameraSetting clone() {
    return new CameraSetting(_yaw, _pitch, _dist, _lookAt.copy());
  }

  CameraSetting merged(CameraSetting v) {
    return new CameraSetting(
      _yaw >= 0 ? _yaw : v.yaw(),
      _pitch >= 0 ? _pitch : v.pitch(),
      _dist >= 0 ? _dist : v.dist(),
      v.lookAt());
  }
}