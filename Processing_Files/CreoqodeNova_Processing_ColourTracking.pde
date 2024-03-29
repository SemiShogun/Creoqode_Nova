import processing.video.*;
import processing.serial.*;

Serial arduinoPort;

Capture video;

color trackColor;
float threshold;

int errorX;
int errorY;

void setup() {
  size(640, 360);

  String[] cameras = Capture.list();
  
  System.out.println(cameras[0]);

  printArray(cameras.length);
  
  // Cameras defines all the cameras connected to this pc, therefore cameras[0] is set
  video = new Capture(this, cameras[0]);
  video.start();

  trackColor = color(255, 0, 0);

  arduinoPort = new Serial(this, "COM4", 9600);
  arduinoPort.bufferUntil('\n');
}

void draw() {

  video.loadPixels();
  image(video, 0, 0);

  threshold = 40; //You can change this value depending on the accuracy required

  int avgX = 0;
  int avgY = 0;

  int count = 0;

  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {

      int loc = x + y * video.width;
      color currentColor = video.pixels[loc];

      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);

      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);
      float d = distSq(r1, g1, b1, r2, g2, b2);

      if (d < threshold*threshold) {
        stroke(255);
        strokeWeight(1);
        point(x, y);
        avgX += x;
        avgY += y;
        count++;
      }
    }
  }

  if (count > 0) {
    avgX = avgX / count;
    avgY = avgY / count;

    // Draw a circle at the average position of the tracked colour
    fill(255);
    strokeWeight(4.0);
    stroke(0);
    ellipse(avgX, avgY, 24, 24);

    errorX = avgX/4;
    errorY = avgY/2;

    arduinoPort.write(errorX);
    arduinoPort.write(errorY);
  }
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
  return d;
}

void captureEvent(Capture video) {
  video.read();
}

void mousePressed() {
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
}
