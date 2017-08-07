import peasy.org.apache.commons.math.geometry.*;

class Cues {
  private Sim _sim;
  private CameraController _cam;
  private Renderer _renderer;

  Cues(Sim sim, PeasyCam cam, Renderer renderer) {
    _sim = sim;
    _cam = new CameraController(sim, cam);
    _renderer = renderer;
  }

  Cues semExternalView(long durationMs) {
    _cam.animateTo(new CameraSetting(-1, radians(15), _sim.planetOrbitDist() * 2.2), durationMs);
    return this;
  }

  Cues semSideView(long durationMs) {
    _cam.animateTo(new CameraSetting(-1, 0, _sim.planetOrbitDist() * 2.2), durationMs);
    return this;
  }

  Cues semOverhead(long durationMs) {
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

  Cues semClean() {
    _renderer.showSunPlanetLine(false);
    return this;
  }

  Cues update(float t) {
    _cam.update(t);
    return this;
  }
}