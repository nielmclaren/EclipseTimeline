
import java.util.Map;

class GyroReader {
  public final int MAX_READINGS = 100;
  public final int MAX_VALUE = 40;
  public final int NUM_GYROS = 3;

  private Serial _serial;
  private String _serialBuffer;
  private Map<Integer, ArrayList<Float>> _magnitudeHistoryMap;
  private Map<Integer, Float> _valueMap;
  
  GyroReader(Serial serial) {
    _serial = serial;
    _serialBuffer = "";
    _magnitudeHistoryMap = new HashMap<Integer, ArrayList<Float>>();
    _valueMap = new HashMap<Integer, Float>();

    for (int i = 0; i < NUM_GYROS; i++) {
      _valueMap.put(i, 0.);
      _magnitudeHistoryMap.put(i, new ArrayList<Float>());
    }
  }

  GyroReader update() {
    readData();
    return this;
  }

  int direction(int id) {
    float v = value(id);
    if (v == 0) {
      return 0;
    }
    return (int)(abs(v) / v);
  }

  float magnitude(int id) {
    float v = value(id);
    return abs(v);
  }

  float value(int id) {
    return _valueMap.get(id);
  }

  ArrayList<Float> magnitudeHistory(int id) {
    return _magnitudeHistoryMap.get(id);
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
    String[] parts = rawValue.split(":");
    if (parts.length < 2) {
      println("Failed to parse reading: " + rawValue);
      return;
    }

    int id = -1;
    try {
      id = Integer.parseInt(parts[0]);
    } catch (Exception e) {
      println("Failed to parse ID: " + rawValue);
      return;
    }

    float value = 0;
    try {
      value = Float.parseFloat(parts[1]);
    } 
    catch (Exception e) {
      println("Failed to parse: " + rawValue);
      return;
    }

    _valueMap.put(id, value);

    ArrayList<Float> magnitudeHistory = _magnitudeHistoryMap.get(id);
    magnitudeHistory.add(abs(value));
    if (magnitudeHistory.size() > MAX_READINGS) {
      magnitudeHistory.remove(0);
    }
  }
}