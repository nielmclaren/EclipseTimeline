
class CameraSetting {
  private float _yaw;
  private float _pitch;
  private float _dist;

  CameraSetting() {
    _yaw = 0;
    _pitch = 0;
    _dist = 0;
  }

  CameraSetting(float yaw, float pitch, float dist) {
    _yaw = yaw;
    _pitch = pitch;
    _dist = dist;
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
  
  CameraSetting clone() {
    return new CameraSetting(_yaw, _pitch, _dist);
  }
}