
class LongTermRenderer {
  private color _lineColor0 = color(83, 80, 230);
  private color _lineColor1 = color(175, 209, 252);
  private color _lineColor2 = color(17, 5, 78);
  private color _lineColor3 = color(139, 24, 90);

  LongTermRenderer() {
  }

  void draw(Sim sim, PGraphics g, float t) {
    drawSun(sim, g, t);
    drawPlanetOrbit(sim, g, t);
    drawSunPlanetLine(sim, g, t);
    drawPlanet(sim, g, t);
    drawMoon(sim, g, t);
  }

  private void drawSun(Sim sim, PGraphics g, float t) {
    g.pushMatrix();
    g.pushStyle();
    g.noFill();
    g.strokeWeight(1);

    if (sim.isEclipse(t)) {
      g.stroke(transpare(_lineColor3, 192));
    } else {
      g.stroke(transpare(_lineColor3, 12));
    }

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
    g.stroke(transpare(_lineColor0, 64));
    g.strokeWeight(1);
    g.ellipseMode(RADIUS);

    g.rotateX(HALF_PI);
    g.ellipse(0, 0, sim.planetOrbitDist(), sim.planetOrbitDist());

    g.popStyle();
    g.popMatrix();
  }

  private void drawSunPlanetLine(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);

    g.pushMatrix();
    g.pushStyle();
    
    g.noFill();

    if (sim.isEclipse(t)) {
      g.stroke(transpare(_lineColor1, 128));
      g.strokeWeight(16);
    } else {
      g.stroke(transpare(_lineColor3, 32));
      g.strokeWeight(1);
    }

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

    if (sim.isEclipse(t)) {
      g.stroke(transpare(_lineColor0, 240));
    } else {
      g.stroke(transpare(_lineColor0, 16));
    }

    g.sphereDetail(20);
    g.sphere(sim.planetRadius());
    
    g.popStyle();
    g.popMatrix();
  }

  private void drawMoon(Sim sim, PGraphics g, float t) {
    PVector planetPos = sim.getPlanetPosition(t);
    PVector moonPos = sim.getMoonPosition(t);
    
    g.pushMatrix();
    g.pushStyle();
    g.noFill();

    g.translate(moonPos.x, moonPos.y, moonPos.z);
    
    if (sim.isEclipse(t)) {
      g.stroke(transpare(_lineColor1, 240));
    } else {
      g.stroke(transpare(_lineColor1, 16));
    }

    g.sphereDetail(12);
    g.sphere(sim.moonRadius());
    
    g.popStyle();
    g.popMatrix();
  }

  private color transpare(color c, float a) {
    return color(red(c), green(c), blue(c), a);
  }
}