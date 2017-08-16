
class Renderer {
  private boolean _showFlatMoonOrbit;
  private boolean _showLunarApsides;
  private boolean _showLunarNodes;
  private boolean _showMoonOrbit;
  private boolean _showOrientationCues;
  private boolean _showPlanet;
  private boolean _showPlanetOrbit;
  private boolean _showSun;
  private boolean _showSunPlanetLine;
  private int _rangeStepsPerYear;
  private float _lastDrawTime;

  private TextureSphere _starField;

  private color _lineColor0 = color(83, 80, 230);
  private color _lineColor1 = color(175, 209, 252);
  private color _lineColor2 = color(17, 5, 78);

  Renderer() {
    _showFlatMoonOrbit = true;
    _showLunarApsides = true;
    _showLunarNodes = true;
    _showMoonOrbit = true;
    _showOrientationCues = true;
    _showPlanet = true;
    _showPlanetOrbit = true;
    _showSun = true;
    _showSunPlanetLine = true;

    _rangeStepsPerYear = 200;
    _lastDrawTime = 0;

    _starField = new TextureSphere(loadImage("starmap_4k.bmp"), 4000);
  }

  Renderer showFlatMoonOrbit(boolean v) {
    _showFlatMoonOrbit = v;
    return this;
  }

  Renderer showLunarApsides(boolean v) {
    _showLunarApsides = v;
    return this;
  }

  Renderer showLunarNodes(boolean v) {
    _showLunarNodes = v;
    return this;
  }

  Renderer showMoonOrbit(boolean v) {
    _showMoonOrbit = v;
    return this;
  }

  Renderer showOrientationCues(boolean v) {
    _showOrientationCues = v;
    return this;
  }

  Renderer showPlanet(boolean v) {
    _showPlanet = v;
    return this;
  }

  Renderer showPlanetOrbit(boolean v) {
    _showPlanetOrbit = v;
    return this;
  }

  Renderer showSun(boolean v) {
    _showSun = v;
    return this;
  }

  Renderer showSunPlanetLine(boolean v) {
    _showSunPlanetLine = v;
    return this;
  }

  float rangeStepsPerYear() {
    return _rangeStepsPerYear;
  }

  float lastDrawTime() {
    return _lastDrawTime;
  }

  void draw(Sim sim, PGraphics g, float t) {
    draw(sim, g, t, true);
  }

  void draw(Sim sim, PGraphics g, float t, boolean isFirstDraw) {
    if (isFirstDraw && _showOrientationCues) {
      drawOrientationCues(sim, g);
    }

    if (isFirstDraw && _showSun) {
      drawSun(sim, g, t);
    }

    if (isFirstDraw && _showPlanetOrbit) {
      drawPlanetOrbit(sim, g, t);
    }

    if (_showSunPlanetLine) {
      drawSunPlanetLine(sim, g, t);
    }

    if (_showPlanet) {
      drawPlanet(sim, g, t);
    }

    if (_showFlatMoonOrbit) {
      drawFlatMoonOrbit(sim, g, t);
    }

    if (_showMoonOrbit) {
      drawMoonOrbit(sim, g, t);
    }

    if (_showLunarApsides) {
      drawLunarApsides(sim, g, t);
    }

    if (_showLunarNodes) {
      drawLunarNodes(sim, g, t);
    }

    drawMoon(sim, g, t);
  }

  boolean drawRange(Sim sim, PGraphics g, float startTime, float endTime) {
    float delta = endTime - startTime;
    if (delta == 0) {
      return false;
    }

    int direction = (int)(abs(delta) / delta);
    float t = (float)ceil(startTime * _rangeStepsPerYear) / _rangeStepsPerYear;

    boolean drew = false;
    while ((t <= endTime) == (direction >= 0)) {
      draw(sim, g, t, !drew);
      drew = true;
      _lastDrawTime = t;
      t += 1.0 / _rangeStepsPerYear * direction;
    }
    return drew;
  }

  private void drawOrientationCues(Sim sim, PGraphics g) {
    buffer.pushStyle();
    buffer.tint(139, 24, 90);
    _starField.draw(buffer);
    buffer.popStyle();
  }

  private void drawSun(Sim sim, PGraphics g, float t) {
    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);
    g.sphereDetail(20);
    g.sphere(sim.sunRadius());

    g.popStyle();
    g.popMatrix();
  }

  private void drawPlanetOrbit(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);

    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);
    g.ellipseMode(RADIUS);

    g.rotateX(PI/2);
    g.ellipse(0, 0, sim.planetOrbitDist(), sim.planetOrbitDist());

    g.popStyle();
    g.popMatrix();
  }

  private void drawSunPlanetLine(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);

    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);

    g.line(0, 0, 0, planetPos.x, planetPos.y, planetPos.z);

    g.popStyle();
    g.popMatrix();
  }

  private void drawPlanet(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    float planetRotationTime = t / sim.dayPeriod();

    g.pushMatrix();
    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateY(planetRotationTime * 2 * PI);

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor1);

    g.sphereDetail(20);
    g.sphere(sim.planetRadius());
    
    g.popStyle();
    g.popMatrix();
  }

  private void drawFlatMoonOrbit(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    float apsidalPrecessionTime = t / sim.apsidalPrecessionPeriod();

    float a = sim.moonMajorAxis() / 2;
    float b = sim.moonMinorAxis() / 2;
    float c = sqrt(a * a - b * b);

    g.pushMatrix();

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(2);

    g.ellipseMode(CENTER);

    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateX(PI/2);
    g.rotateZ(-apsidalPrecessionTime * 2 * PI);
    g.translate(c, 0);
    g.ellipse(0, 0, sim.moonMajorAxis(), sim.moonMinorAxis());

    g.popStyle();

    g.popMatrix();
  }

  private void drawMoonOrbit(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    float apsidalPrecessionTime = t / sim.apsidalPrecessionPeriod();

    float a = sim.moonMajorAxis() / 2;
    float b = sim.moonMinorAxis() / 2;
    float c = sqrt(a * a - b * b);

    g.pushMatrix();

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(2);

    g.ellipseMode(CENTER);

    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateX(PI/2);

    g.pushMatrix();
    g.rotateX(sim.lunarOrbitInclineRad());
    g.rotateZ(-apsidalPrecessionTime * 2 * PI);
    g.translate(c, 0);
    g.ellipse(0, 0, sim.moonMajorAxis(), sim.moonMinorAxis());
    g.popMatrix();

    g.popStyle();

    g.popMatrix();
  }

  private void drawLunarApsides(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    float apsidalPrecessionTime = t / sim.apsidalPrecessionPeriod();

    float a = sim.moonMajorAxis() / 2;
    float b = sim.moonMinorAxis() / 2;
    float c = sqrt(a * a - b * b);

    g.pushMatrix();

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor0);
    g.strokeWeight(1);

    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateX(PI/2);
    g.rotateX(sim.lunarOrbitInclineRad());
    g.rotateZ(-apsidalPrecessionTime * 2 * PI);
    g.translate(c, 0);
    g.line(-sim.moonMajorAxis()/2, 0, sim.moonMajorAxis()/2, 0);

    g.popStyle();

    g.popMatrix();
  }

  private void drawLunarNodes(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    float apsidalPrecessionTime = t / sim.apsidalPrecessionPeriod();

    float a = sim.moonMajorAxis() / 2;
    float b = sim.moonMinorAxis() / 2;
    float c = sqrt(a * a - b * b);

    float cosine = cos(-apsidalPrecessionTime * 2 * PI);
    float sine = sin(-apsidalPrecessionTime * 2 * PI);

    // Quadratic formula.
    float qa = a * a * sine * sine + b * b * cosine * cosine;
    float qb = -2 * b * b * c * cosine;
    float qc = b * b * c * c - a * a * b * b;
    float x0 = (-qb + sqrt(qb * qb - 4 * qa * qc)) / (2 * qa);
    float x1 = (-qb - sqrt(qb * qb - 4 * qa * qc)) / (2 * qa);

    g.pushMatrix();

    g.pushStyle();
    g.noFill();
    g.stroke(_lineColor1);
    g.strokeWeight(1);

    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateX(PI/2);
    g.rotateX(sim.lunarOrbitInclineRad());
    g.line(x0, 0, x1, 0);

    // Ascending node.
    g.pushMatrix();
    g.translate(x0, 0);
    g.sphereDetail(20);
    g.sphere(10);
    g.popMatrix();

    // Descending node.
    g.pushMatrix();
    g.translate(x1, 0);
    g.sphereDetail(8);
    g.sphere(10);
    g.popMatrix();

    g.popStyle();

    g.popMatrix();
  }

  private void drawMoon(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    PVector moonPos = sim.getMoonPosition(t);
    
    g.pushMatrix();
    g.pushStyle();

    g.translate(moonPos.x, moonPos.y, moonPos.z);
    
    g.stroke(_lineColor0);
    g.noFill();
    g.sphereDetail(12);
    g.sphere(sim.moonRadius());
    
    g.popStyle();
    g.popMatrix();
  }
}