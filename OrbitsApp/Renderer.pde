
class Renderer {
  private boolean _showLunarApsides;
  private boolean _showPlanetOrbit;
  private boolean _showSun;
  private boolean _showSunPlanetLine;

  private color _lineColor0 = color(83, 80, 230);
  private color _lineColor1 = color(175, 209, 252);
  private color _lineColor2 = color(17, 5, 78);

  Renderer() {
    _showLunarApsides = true;
    _showPlanetOrbit = true;
    _showSun = true;
    _showSunPlanetLine = true;
  }

  Renderer showLunarApsides(boolean v) {
    _showLunarApsides = v;
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

  void draw(Sim sim, PGraphics g, float t) {
    drawBackground(sim, g);
    drawSun(sim, g, t);

    if (_showPlanetOrbit) {
      drawPlanetOrbit(sim, g, t);
    }

    if (_showSunPlanetLine) {
      drawSunPlanetLine(sim, g, t);
    }

    drawPlanet(sim, g, t);
    drawMoonOrbit(sim, g, t);

    if (_showLunarApsides) {
      drawLunarApsides(sim, g, t);
    }

    drawMoon(sim, g, t);
  }

  private void drawBackground(Sim sim, PGraphics g) {
    g.background(0);
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

    g.sphereDetail(12);
    g.sphere(sim.planetRadius());
    
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
    g.strokeWeight(1);

    g.translate(planetPos.x, planetPos.y, planetPos.z);
    g.rotateX(PI/2);
    g.rotateX(sim.lunarOrbitInclineRad());
    g.rotateZ(-apsidalPrecessionTime * 2 * PI);
    g.translate(c, 0);
    g.ellipse(0, 0, sim.moonMajorAxis(), sim.moonMinorAxis());

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

  private void drawMoon(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    PVector moonPos = sim.getMoonPosition(t);
    
    g.pushMatrix();
    g.pushStyle();

    g.translate(moonPos.x, moonPos.y, moonPos.z);
    
    g.stroke(_lineColor0);
    g.noFill();
    g.sphereDetail(8);
    g.sphere(sim.moonRadius());
    
    g.popStyle();
    g.popMatrix();
  }
}