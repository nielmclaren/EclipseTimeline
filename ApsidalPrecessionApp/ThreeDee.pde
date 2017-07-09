
static class ThreeDee {
  static PVector rotateX(PVector v, float amount) {
    float c = cos(amount);
    float s = sin(amount);
    float[][] data = { { 1, 0, 0 }, { 0, c, -s }, { 0, s, c } };
    return mult(v, data);
  }

  static PVector rotateY(PVector v, float amount) {
    float c = cos(amount);
    float s = sin(amount);
    float[][] data = { { c, 0, s }, { 0, 1, 0 }, { -s, 0, c } };
    return mult(v, data);
  }

  static PVector rotateZ(PVector v, float amount) {
    float c = cos(amount);
    float s = sin(amount);
    float[][] data = { { c, -s, 0 }, { s, c, 0 }, { 0, 0, 1 } };
    return mult(v, data);
  }

  static PVector translate(PVector v, float x, float y, float z) {
    return new PVector(v.x + x, v.y + y, v.z + z);
  }

  private static PVector mult(PVector v3, float[][] m3x3) {
    PVector v = v3;
    float[][] m = m3x3;
    return new PVector(
      m[0][0] * v.x + m[1][0] * v.y + m[2][0] * v.z,
      m[0][1] * v.x + m[1][1] * v.y + m[2][1] * v.z,
      m[0][2] * v.x + m[1][2] * v.y + m[2][2] * v.z);
    /*
    return new PVector(
      m[0][0] * v.x + m[0][1] * v.y + m[0][2] * v.z,
      m[1][0] * v.x + m[1][1] * v.y + m[1][2] * v.z,
      m[2][0] * v.x + m[2][1] * v.y + m[2][2] * v.z);
    */
  }
}