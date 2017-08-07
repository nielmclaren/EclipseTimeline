
class Sim {
  private float _sunRadius;
  private float _planetOrbitDist;
  private float _planetRadius;
  private float _moonMajorAxis;
  private float _moonMinorAxis;
  private float _lunarOrbitInclineRad;
  private float _apsidalPrecessionPeriod;
  private float _moonRadius;

  private color _lineColor0 = color(83, 80, 230);
  private color _lineColor1 = color(175, 209, 252);
  private color _lineColor2 = color(17, 5, 78);

  Sim() {
    _sunRadius = 500;
    _planetOrbitDist = 1800;
    _planetRadius = 100;
    _moonMajorAxis = 600;
    _moonMinorAxis = 550;
    _lunarOrbitInclineRad = radians(20);//radians(5.1);
    _apsidalPrecessionPeriod = 9;
    _moonRadius = 50;
  }

  float sunRadius() {
    return _sunRadius;
  }

  Sim sunRadius(float v) {
    _sunRadius = v;
    return this;
  }

  float planetOrbitDist() {
    return _planetOrbitDist;
  }

  Sim planetOrbitDist(float v) {
    _planetOrbitDist = v;
    return sim;
  }

  float planetRadius() {
    return _planetRadius;
  }

  Sim planetRadius(float v) {
    _planetRadius = v;
    return this;
  }

  float moonMajorAxis() {
    return _moonMajorAxis;
  }

  Sim moonMajorAxis(float v) {
    _moonMajorAxis = v;
    return this;
  }

  float moonMinorAxis() {
    return _moonMinorAxis;
  }

  Sim moonMinorAxis(float v) {
    _moonMinorAxis = v;
    return this;
  }

  float lunarOrbitInclineRad() {
    return _lunarOrbitInclineRad;
  }

  Sim lunarOrbitInclineRad(float v) {
    _lunarOrbitInclineRad = v;
    return this;
  }

  float apsidalPrecessionPeriod() {
    return _apsidalPrecessionPeriod;
  }

  Sim apsidalPrecessionPeriod(float v) {
    _apsidalPrecessionPeriod = v;
    return this;
  }

  float moonRadius() {
    return _moonRadius;
  }

  Sim moonRadius(float v) {
    _moonRadius = v;
    return this;
  }

  float getPlanetRotation(float t) {
    return map(t, 0, 1, 0, 2 * PI);
  }

  float getMoonRotation(float t) {
    return map(t, 0, 1, 0, 12 * 2 * PI);
  }

  PVector getPlanetPosition(float t) {
    float rotation = getPlanetRotation(t);
    
    PVector pos = new PVector();
    pos = ThreeDee.translate(pos, _planetOrbitDist, 0, 0);
    pos = ThreeDee.rotateY(pos, rotation);
    pos.y *= -1;
    return pos;
  }

  PVector getMoonPosition(float t) {
    float u = (t * _apsidalPrecessionPeriod) % 1;
    return getMoonPosition(t, u);
  }

  PVector getMoonPosition(float t, float u) {
    PVector planetPos = getPlanetPosition(t);
    
    float a = _moonMajorAxis / 2;
    float b = _moonMinorAxis / 2;
    float c = sqrt(a * a - b * b);

    float x = c + a * cos(u * 2 * PI);
    float z = b * sin(u * 2 * PI);

    PVector pos = new PVector(
      x * cos(-t * 2 * PI) + z * sin(-t * 2 * PI),
      x * sin(-t * 2 * PI) - z * cos(-t * 2 * PI),
      0);

    pos = ThreeDee.rotateX(pos, _lunarOrbitInclineRad);
    pos = ThreeDee.rotateX(pos, PI/2);
    pos = ThreeDee.translate(pos, planetPos.x, planetPos.y, planetPos.z);
    return pos;
  }
}