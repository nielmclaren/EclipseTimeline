
class RangeRenderer {
  private final color _lineColor0 = color(83, 80, 230);
  private final color _lineColor1 = color(175, 209, 252);
  private final color _lineColor2 = color(17, 5, 78);

  RangeRenderer() {}

  void draw(Sim sim, PGraphics g, float startTime, float endTime, int numSteps) {
    for (int i = 0; i < numSteps; i++) {
      float t = map(i, 0, numSteps, startTime, endTime);

      g.pushMatrix();
      g.translate(-width + startTime * 1000, 0);
      draw(sim, g, t);
      g.popMatrix();
    }
  }

  private void draw(Sim sim, PGraphics g, float t) {
    //drawSun(sim, g, t);
    //drawPlanetOrbit(sim, g, t);
    drawSunPlanetLine(sim, g, t);
    drawPlanet(sim, g, t);
    //drawMoonOrbit(sim, g, t);
    drawMoon(sim, g, t);
  }

  private void drawSun(Sim sim, PGraphics g, float t) {
    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();
    g.stroke(faded(_lineColor0, 1));
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
    g.stroke(faded(_lineColor0, 4));
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
    g.stroke(faded(_lineColor0, 4));
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
    g.stroke(faded(_lineColor1, 4));

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
    g.stroke(faded(_lineColor0, 4));
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

  private void drawMoon(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    PVector moonPos = sim.getMoonPosition(t);
    
    g.pushMatrix();
    g.pushStyle();

    g.translate(moonPos.x, moonPos.y, moonPos.z);
    
    g.stroke(faded(_lineColor0, 4));
    g.noFill();
    g.sphereDetail(8);
    g.sphere(sim.moonRadius());
    
    g.popStyle();
    g.popMatrix();
  }

  private color faded(color v, int alpha) {
    pushStyle();
    colorMode(RGB);
    color result = color(red(v), green(v), blue(v), alpha);
    popStyle();
    return result;
  }
}