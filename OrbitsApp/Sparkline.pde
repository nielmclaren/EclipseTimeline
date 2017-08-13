
class Sparkline {
  private float _x;
  private float _y;
  private float _width;
  private float _height;
  
  Sparkline(float x, float y, float width, float height) {
    _x = x;
    _y = y;
    _width = width;
    _height = height;
  }

  void draw(PGraphics g, ArrayList<Float> data, int numValues, float minValue, float maxValue) {
    g.pushStyle();

    g.fill(32);
    g.stroke(128);
    g.strokeWeight(1);
    g.rect(_x, _y, _width, _height);

    g.noStroke();
    g.fill(255);

    float w = _width / numValues;
    for (int i = 0; i < data.size(); i++) {
      float x = _width - w * data.size() + w * i;
      float h = map(data.get(i), minValue, maxValue, 0, _height);
      g.rect(_x + x, _y + _height - h, w, h);
    }

    g.popStyle();
  }
}