
class GyroReader {
  public final int MAX_READINGS = 100;
  public final int MAX_VALUE = 40;

  private Serial _serial;
  private String _serialBuffer;
  private ArrayList<Float> _magnitudeHistory;
  private float _value;
  
  GyroReader(Serial serial) {
    _serial = serial;
    _serialBuffer = "";
    _magnitudeHistory = new ArrayList<Float>();
    _value = 0;
  }

  GyroReader update() {
    readData();
    return this;
  }

  int direction() {
    if (_value == 0) {
      return 0;
    }
    return (int)(abs(_value) / _value);
  }

  float magnitude() {
    return abs(_value);
  }

  float value() {
    return _value;
  }

  ArrayList<Float> magnitudeHistory() {
    return _magnitudeHistory;
  }

  private void readData() {
    while (_serial.available() > 0) {
      char c = (char)_serial.read();
      if (c == ';') {
        handleReading(_serialBuffer);
        _serialBuffer = "";
      } else {
        _serialBuffer += c;
      }
    }
  }

  private void handleReading(String rawValue) {
    try {
      _value = Float.parseFloat(rawValue);
    } 
    catch (Exception e) {
      println("Failed to parse: " + rawValue);
    }

    _magnitudeHistory.add(abs(_value));
    if (_magnitudeHistory.size() > MAX_READINGS) {
      _magnitudeHistory.remove(0);
    }
  }
}