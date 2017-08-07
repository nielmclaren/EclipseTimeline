import peasy.org.apache.commons.math.geometry.*;

class Cues {
  private Sim _sim;
  private CameraController _cam;
  private Renderer _renderer;

  Cues(Sim sim, PeasyCam cam, Renderer renderer) {
    _sim = sim;
    _cam = new CameraController(sim, cam);
    _renderer = renderer;

    sceneDefault();
  }

  Cues cue(String cueName) {
    switch (cueName) {
      case "intro":
        intro(2000);
        break;

      case "intro_synodic":
        introSynodicMonth(2000);
        break;

      case "intro_anomalistic":
        introAnomalisticMonth(2000);
        break;
        
      case "intro_draconic":
        introDraconicMonth(2000);
        break;
        
      default:
    }
    return this;
  }

  Cues intro(long durationMs) {
    sceneDefault();
    spmExternalView(durationMs);
    return this;
  }

  Cues introSynodicMonth(long durationMs) {
    _sim
      .moonMajorAxis(550)
      .moonMinorAxis(550)
      .lunarOrbitInclineRad(0);
    _renderer
      .showSun(true)
      .showPlanetOrbit(true)
      .showSunPlanetLine(true);

    planetOverhead(durationMs);
    return this;
  }

  Cues introAnomalisticMonth(long durationMs) {
    _sim
      .apsidalPrecessionPeriod(9)
      .moonMajorAxis(600)
      .moonMinorAxis(550)
      .lunarOrbitInclineRad(0);
    _renderer
      .showLunarApsides(true)
      .showSun(false)
      .showPlanetOrbit(false)
      .showSunPlanetLine(true);

    planetOverhead(durationMs);
    return this;
  }

  Cues introDraconicMonth(long durationMs) {
    _sim
      .moonMajorAxis(600)
      .moonMinorAxis(550)
      .lunarOrbitInclineRad(0);
    _renderer
      .showSun(true)
      .showPlanetOrbit(true)
      .showSunPlanetLine(true);

    planetOverhead(durationMs);
    return this;
  }

  Cues spmExternalView(long durationMs) {
    _cam.animateTo(new CameraSetting(-1, radians(15), _sim.planetOrbitDist() * 2.2), durationMs);
    return this;
  }

  Cues spmSideView(long durationMs) {
    _cam.animateTo(new CameraSetting(-1, 0, _sim.planetOrbitDist() * 2.2), durationMs);
    return this;
  }

  Cues spmOverhead(long durationMs) {
    _cam.animateTo(new CameraSetting(-1, HALF_PI, _sim.planetOrbitDist() * 2.2), durationMs);
    return this;
  }

  Cues planetExternal(long durationMs) {
    _cam.followPlanetExternal(durationMs);
    return this;
  }

  Cues planetOverhead(long durationMs) {
    _cam.followPlanetOverhead(durationMs);
    return this;
  }

  Cues spmClean() {
    _renderer.showSunPlanetLine(false);
    return this;
  }

  Cues sceneDefault() {
    _sim
      .sunRadius(500)
      .planetOrbitDist(1800)
      .planetRadius(100)
      .dayPeriod(1. / 5)//365.25)
      .moonMajorAxis(550)
      .moonMinorAxis(550)
      .lunarOrbitInclineRad(radians(5.1))
      .lunarOrbitPeriod(1. / 12)
      .apsidalPrecessionPeriod(9)
      .moonRadius(50);
    _renderer
      .showLunarApsides(false)
      .showPlanetOrbit(true)
      .showSun(true)
      .showSunPlanetLine(false);
    return this;
  }

  Cues update(float t) {
    _cam.update(t);
    return this;
  }
}