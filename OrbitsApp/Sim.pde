
class Sim {
  private float _sunRadius;
  private float _planetOrbitDist;
  private float _planetRadius;
  private float _dayPeriod;
  private float _moonMajorAxis;
  private float _moonMinorAxis;
  private float _lunarOrbitInclineRad;
  private float _lunarOrbitPeriod;
  private float _apsidalPrecessionPeriod;
  private float _moonRadius;

  Sim() {
    _sunRadius = 330;
    _planetOrbitDist = 1800;
    _planetRadius = 100;
    _dayPeriod = 1. / 365.25;
    _moonMajorAxis = 600;
    _moonMinorAxis = 550;
    _lunarOrbitInclineRad = radians(20);//radians(5.1);
    _lunarOrbitPeriod = 1. / 12;
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

  float dayPeriod() {
    return _dayPeriod;
  }

  Sim dayPeriod(float v) {
    _dayPeriod = v;
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

  float lunarOrbitPeriod() {
    return _lunarOrbitPeriod;
  }

  Sim lunarOrbitPeriod(float v) {
    _lunarOrbitPeriod = v;
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
    return map(t % 1, 0, 1, 0, 2 * PI);
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
    float lunarOrbitTime = t / _lunarOrbitPeriod;
    return getMoonPosition(t, lunarOrbitTime);
  }

  PVector getMoonPosition(float t, float lunarOrbitTime) {
    PVector planetPos = getPlanetPosition(t);
    float apsidalPrecessionTime = t / _apsidalPrecessionPeriod;
    
    float a = _moonMajorAxis / 2;
    float b = _moonMinorAxis / 2;
    float c = sqrt(a * a - b * b);

    PVector pos = new PVector(
      a * cos(lunarOrbitTime * 2 * PI),
      b * sin(lunarOrbitTime * 2 * PI),
      0);

    pos = ThreeDee.translate(pos, c, 0, 0);
    pos = ThreeDee.rotateZ(pos, -apsidalPrecessionTime * 2 * PI);
    pos = ThreeDee.rotateX(pos, _lunarOrbitInclineRad);
    pos = ThreeDee.rotateX(pos, PI/2);
    pos = ThreeDee.translate(pos, planetPos.x, planetPos.y, planetPos.z);
    return pos;
  }

  float getStarPlanetPolarDistance(float t) {
    PVector planetPos = getPlanetPosition(t);
    PVector moonPos = getMoonPosition(t);

    PVector planetToStar = PVector.sub(new PVector(0, 0, 0), planetPos);
    PVector planetToMoon = PVector.sub(moonPos, planetPos);
    return PVector.angleBetween(planetToStar, planetToMoon);
  }
}