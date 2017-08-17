import peasy.org.apache.commons.math.geometry.*;

class Cues {
  private Sim _sim;
  private CameraController _cam;
  private Renderer _renderer;
  private float _scale;

  Cues(Sim sim, PeasyCam[] cams, Renderer renderer) {
    _sim = sim;
    _cam = new CameraController(sim, cams);
    _renderer = renderer;
    _scale = 1;

    sceneDefault();
  }

  Cues scale(float v) {
    _scale = v;
    _cam.scale(v);
    return this;
  }

  Cues cue(String cueName) {
    switch (cueName) {
      case "intro":
        intro(2000);
        break;

      case "eclipse":
        introEclipse(2000);
        break;

      case "synodic":
        synodicMonth(2000);
        break;

      case "anomalistic":
        anomalisticMonth(2000);
        break;
        
      case "draconic":
        draconicMonth(2000);
        break;

      case "overhead":
        spmOverhead(2000);
        break;
        
      default:
    }
    return this;
  }

  Cues intro(long durationMs) {
    sceneDefault();
    spmExternalRotisserieView(durationMs);
    return this;
  }

  Cues introEclipse(long durationMs) {
    sceneDefault();
    _renderer.showPlanet(false);
    planetView(durationMs);
    return this;
  }

  Cues synodicMonth(long durationMs) {
    sceneDefault();
    _sim
      .moonMajorAxis(475)
      .moonMinorAxis(475)
      .lunarOrbitInclineRad(0);
    _renderer
      .showLunarApsides(false)
      .showSun(true)
      .showPlanetOrbit(true)
      .showSunPlanetLine(true);

    planetOverhead(durationMs);
    return this;
  }

  Cues anomalisticMonth(long durationMs) {
    sceneDefault();
    _sim
      .apsidalPrecessionPeriod(3)
      .lunarOrbitInclineRad(0);
    _renderer
      .showLunarApsides(true)
      .showSun(false)
      .showPlanetOrbit(false)
      .showSunPlanetLine(false);

    planetOverhead(durationMs);
    return this;
  }

  Cues draconicMonth(long durationMs) {
    sceneDefault();
    _renderer
      .showFlatMoonOrbit(true)
      .showLunarApsides(false)
      .showLunarNodes(true)
      .showSun(true)
      .showPlanetOrbit(true)
      .showSunPlanetLine(true);

    planetLunarNodesView(durationMs);
    return this;
  }

  Cues spmOverhead(long durationMs) {
    sceneDefault();
    _sim
      .lunarOrbitInclineRad(radians(20));
    _renderer
      .showLunarApsides(false)
      .showLunarNodes(false)
      .showFlatMoonOrbit(false)
      .showMoonOrbit(true)
      .showSun(true)
      .showPlanetOrbit(true)
      .showSunPlanetLine(true);

    spmOverheadView(durationMs);
    return this;
  }

  private Cues spmExternalRotisserieView(long durationMs) {
    _cam.spmExternalRotisserie(durationMs);
    return this;
  }

  private Cues spmExternalView(long durationMs) {
    CameraSetting setting = new CameraSetting()
      .pitch(radians(15))
      .roll(0)
      .dist(_sim.planetOrbitDist() * 2.2 * _scale);
    _cam.animateTo(setting, durationMs);
    return this;
  }

  private Cues spmSideView(long durationMs) {
    CameraSetting setting = new CameraSetting()
      .pitch(0)
      .roll(0)
      .dist(_sim.planetOrbitDist() * 2.2 * _scale);
    _cam.animateTo(setting, durationMs);
    return this;
  }

  private Cues spmOverheadView(long durationMs) {
    CameraSetting setting = new CameraSetting()
      .pitch(HALF_PI)
      .roll(0)
      .dist(_sim.planetOrbitDist() * 2.2 * _scale);
    _cam.animateTo(setting, durationMs);
    return this;
  }

  private Cues planetExternalView(long durationMs) {
    _cam.followPlanetExternal(durationMs);
    return this;
  }

  private Cues planetView(long durationMs) {
    _cam.followPlanet(durationMs);
    return this;
  }

  private Cues planetLunarNodesView(long durationMs) {
    _cam.followPlanetLunarNodes(durationMs);
    return this;
  }

  private Cues planetOverhead(long durationMs) {
    _cam.followPlanetOverhead(durationMs);
    return this;
  }

  private Cues planetOverheadRelativeToSun(long durationMs) {
    _cam.followPlanetOverheadRelativeToSun(durationMs);
    return this;
  }

  private Cues spmClean() {
    _renderer.showSunPlanetLine(false);
    return this;
  }

  private Cues sceneDefault() {
    _sim.reset();
    _renderer.reset();
    return this;
  }

  Cues update(float t) {
    _cam.update(t);
    return this;
  }
}