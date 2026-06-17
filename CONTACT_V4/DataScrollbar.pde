class DataScrollbar
{


  float xpos, ypos, swidth;
  float minVal, maxVal, pos;
  boolean locked;
  float barWidth = 10;
  int loose = 4;
  float newPos;

  DataScrollbar(float x, float y, float w, float min, float max, float start) {
    xpos = x;
    ypos = y;
    swidth = w;
    minVal = min;
    maxVal = max;
    pos = map(start, min, max, 0, w);
    newPos = pos;
  }

  void update() {
    if (mousePressed && mouseX > xpos && mouseX < xpos + swidth &&
      mouseY > ypos - 8 && mouseY < ypos + 8) {
      newPos = constrain(mouseX - xpos, 0, swidth);
    }
    pos = pos + (newPos - pos) / loose;
  }

  float getPos() {
    return map(pos, 0, swidth, minVal, maxVal);
  }

  void setPos(float value) {
    pos = map(value, minVal, maxVal, 0, swidth);
    newPos = pos;
  }

  void display() {
    stroke(150);
    strokeWeight(2);
    line(xpos, ypos, xpos + swidth, ypos);
    fill(50);
    noStroke();
    rect(xpos + pos - barWidth/2, ypos - 8, barWidth, 16, 3);
  }
}
