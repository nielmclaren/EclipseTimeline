
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

  float lunarOrbitInclineRad() {
    return _lunarOrbitInclineRad;
  }

  Sim lunarOrbitInclineRad(float v) {
    _lunarOrbitInclineRad = v;
    return this;
  }

  void draw(PGraphics g, float t) {
    drawBackground(g);
    drawSun(g, t);
    drawPlanetOrbit(g, t);
    drawSunPlanetLine(g, t);
    drawPlanet(g, t);
    drawMoonOrbit(g, t);
    drawMoon(g, t);
  }

  private void drawBackground(PGraphics g) {
    g.background(0);
  }

  private void drawSun(PGraphics g, float t) {
    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);
    g.sphereDetail(20);
    g.sphere(_sunRadius);

    g.popStyle();
    g.popMatrix();
  }

  private void drawPlanetOrbit(PGraphics g, float t) {
    PVector planetPos = getPlanetPosition(t);

    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);
    g.ellipseMode(RADIUS);

    g.rotateX(PI/2);
    g.ellipse(0, 0, _planetOrbitDist, _planetOrbitDist);

    g.popStyle();
    g.popMatrix();
  }

  private void drawSunPlanetLine(PGraphics g, float t) {
    PVector planetPos = getPlanetPosition(t);

    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);

    g.line(0, 0, 0, planetPos.x, planetPos.y, planetPos.z);

    g.popStyle();
    g.popMatrix();
  }

  private void drawPlanet(PGraphics g, float t) {
    PVector planetPos = getPlanetPosition(t);

    g.pushMatrix();
    g.translate(planetPos.x, planetPos.y, planetPos.z);

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor1);

    g.sphereDetail(12);
    g.sphere(_planetRadius);
    
    g.popStyle();
    g.popMatrix();
  }

  private void drawMoonOrbit(PGraphics g, float t) {
    PVector planetPos = getPlanetPosition(t);

    float a = _moonMajorAxis / 2;
    float b = _moonMinorAxis / 2;
    float c = sqrt(a * a - b * b);

    g.pushMatrix();

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);

    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateX(PI/2);
    g.rotateX(_lunarOrbitInclineRad);
    g.rotateZ(-t * 2 * PI);
    g.translate(c, 0);
    g.ellipse(0, 0, _moonMajorAxis, _moonMinorAxis);

    g.popStyle();

    g.popMatrix();
  }

  private void drawMoon(PGraphics g, float t) {
    PVector planetPos = getPlanetPosition(t);
    PVector moonPos = getMoonPosition(t);
    
    g.pushMatrix();
    g.pushStyle();

    g.translate(moonPos.x, moonPos.y, moonPos.z);
    
    g.stroke(_lineColor0);
    g.noFill();
    g.sphereDetail(8);
    g.sphere(_moonRadius);
    
    g.popStyle();
    g.popMatrix();
  }

  private float getPlanetRotation(float t) {
    return map(t, 0, 1, 0, 2 * PI);
  }

  private float getMoonRotation(float t) {
    return map(t, 0, 1, 0, 12 * 2 * PI);
  }

  private PVector getPlanetPosition(float t) {
    float rotation = getPlanetRotation(t);
    
    PVector pos = new PVector();
    pos = ThreeDee.translate(pos, _planetOrbitDist, 0, 0);
    pos = ThreeDee.rotateY(pos, rotation);
    pos.y *= -1;
    return pos;
  }

  private PVector getMoonPosition(float t) {
    float u = (t * _apsidalPrecessionPeriod) % 1;
    return getMoonPosition(t, u);
  }

  private PVector getMoonPosition(float t, float u) {
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