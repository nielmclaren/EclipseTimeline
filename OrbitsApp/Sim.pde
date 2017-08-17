
class Sim {
  private float _sunRadius;
  private float _planetOrbitDist;
  private float _planetRadius;
  private float _dayPeriod;
  private float _moonMajorAxis;
  private float _moonMinorAxis;
  private float _lunarOrbitInclineRad;
  private float _nodalPrecessionPeriod;
  private float _lunarOrbitPeriod;
  private float _apsidalPrecessionPeriod;
  private float _moonRadius;
  private float _sarosCycle;

  Sim() {
    _sunRadius = 330;
    _planetOrbitDist = 1800;
    _planetRadius = 100;
    _dayPeriod = 1. / 365.25;
    _moonMajorAxis = 500;
    _moonMinorAxis = 475;
    _lunarOrbitInclineRad = radians(20);//radians(5.1);
    _nodalPrecessionPeriod = 18.6;
    _lunarOrbitPeriod = 1. / 12;
    _apsidalPrecessionPeriod = 14.2;
    _moonRadius = 50;
    
    // Calculate from the synodic, anomalistic, and draconic months.
    _sarosCycle = 22.000000685733248;
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

  Sim nodalPrecessionPeriod(float v) {
    _nodalPrecessionPeriod = v;
    return this;
  }

  float nodalPrecessionPeriod() {
    return _nodalPrecessionPeriod;
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

  double sarosCycle() {
    return _sarosCycle;
  }

  float getPlanetRotation(float t) {
    return map(t % 1, 0, 1, 0, TWO_PI);
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
    float nodalPrecessionTime = t / _nodalPrecessionPeriod;
    
    float a = _moonMajorAxis / 2;
    float b = _moonMinorAxis / 2;
    float c = sqrt(a * a - b * b);

    PVector pos = new PVector(
      a * cos(lunarOrbitTime * 2 * PI),
      b * sin(lunarOrbitTime * 2 * PI),
      0);

    pos = ThreeDee.translate(pos, c, 0, 0);
    pos = ThreeDee.rotateZ(pos, -apsidalPrecessionTime * 2 * PI);
    pos = ThreeDee.rotateZ(pos, -nodalPrecessionTime * 2 * PI);
    pos = ThreeDee.rotateX(pos, _lunarOrbitInclineRad);
    pos = ThreeDee.rotateZ(pos, nodalPrecessionTime * 2 * PI);
    pos = ThreeDee.rotateZ(pos, HALF_PI);
    pos = ThreeDee.rotateX(pos, HALF_PI);
    pos = ThreeDee.translate(pos, planetPos.x, planetPos.y, planetPos.z);
    return pos;
  }

  float getStarMoonPolarDistance(float t) {
    PVector planetPos = getPlanetPosition(t);
    PVector moonPos = getMoonPosition(t);

    PVector planetToStar = PVector.sub(new PVector(0, 0, 0), planetPos);
    PVector planetToMoon = PVector.sub(moonPos, planetPos);
    return PVector.angleBetween(planetToStar, planetToMoon);
  }

  boolean isEclipse(float t) {
    return getStarMoonPolarDistance(t) < radians(5);
  }

  double getSiderealMonth() {
    return _lunarOrbitPeriod;
  }

  double getSynodicMonth() {
    return _lunarOrbitPeriod * (1 - _lunarOrbitPeriod);
  }

  double getAnomalisticMonth() {
    return _lunarOrbitPeriod - _lunarOrbitPeriod / _apsidalPrecessionPeriod;
  }

  double getDraconicMonth() {
    return _lunarOrbitPeriod - _lunarOrbitPeriod / _nodalPrecessionPeriod;
  }

  void printPotentialSarosCycles() {
    double maxError = 1./365.25/24 * 3;

    double apsidalPrecessionPeriod = 9.8;
    double nodalPrecessionPeriod = 18.6;

    for (int j = 0; j < 1000; j++) {
      double synodicMonth = getSynodicMonth();
      double anomalisticMonth = _lunarOrbitPeriod * (1 - 1 / apsidalPrecessionPeriod);//getAnomalisticMonth();
      double draconicMonth = _lunarOrbitPeriod * (1 - 1 / 18.6);//getDraconicMonth();

      int synodicCount = 1;
      int anomalisticCount = 1;
      int draconicCount = 1;

      for (int i = 0; i < 1000; i++) {
        double s = synodicMonth * synodicCount;
        double a = anomalisticMonth * anomalisticCount;
        double d = draconicMonth * draconicCount;
        if (a < s && a < d) {
          anomalisticCount++;
        } else if (d < s && d < a) {
          draconicCount++;
        } else {
          synodicCount++;
        }

        if (getError(s, a) < maxError && getError(s, d) < maxError && getError(a, d) < maxError) {
          if (s < 15) {
            break;
          }
          println(apsidalPrecessionPeriod, nodalPrecessionPeriod);
          println(">", s, a, d);
          println((s - java.lang.Math.floor(s)) * 365.25);
          println();
          break;
        }
      }

      if (j % 2 == 0) {
        apsidalPrecessionPeriod += 0.1;
      } else {
        nodalPrecessionPeriod += 0.1;
      }
    }
  }

  private double getError(double a, double b) {
    return java.lang.Math.abs(a - b);
  }
}