int visualizerX = 920;
int visualizerY = 420;
int visualizerWidth = 357;
int visualizerHeight = 298;

int controlX = 2;
int controlY = 320;
int controlWidth = 350;
int controlHeight = 398;

int visualizerMode = 1; // Default visualizer mode

void drawWaveformVisualizer() {
  float[] combinedBuffer = getCombinedAudioBuffer();
  noFill();

  for (int i = 0; i < combinedBuffer.length - 1; i++) {
    float x1 = map(i, 0, combinedBuffer.length, visualizerX, visualizerX + visualizerWidth);
    float y1 = map(combinedBuffer[i], -1, 1, visualizerY + visualizerHeight, visualizerY);
    float x2 = map(i + 1, 0, combinedBuffer.length, visualizerX, visualizerX + visualizerWidth);
    float y2 = map(combinedBuffer[i + 1], -1, 1, visualizerY + visualizerHeight, visualizerY);

    stroke(rainbowWave(time + PI / 2));
    line(x1, y1, x2, y2);
  }
}

void drawBarVisualizer() {
  int bars = 64;
  float[] combinedBuffer = getCombinedAudioBuffer();  // Use the combined audio buffer
  noStroke();

  for (int i = 0; i < bars; i++) {
    float x = map(i, 0, bars, width - 360, width - 5);  
    float h = map(combinedBuffer[i * (combinedBuffer.length / bars)], 0, 0.5, 0, height - 575);

    fill(rainbowWave(time + PI / 2));
    rect(x, height - 4, (width - 5 - (width - 360)) / bars, -h);
  }
}

void drawCircularVisualizer() {
  float[] combinedBuffer = getCombinedAudioBuffer();
  float radius = 100;
  int points = combinedBuffer.length;
  float angleStep = TWO_PI / points;
  noFill();

  beginShape();
  for (int i = 0; i < points; i++) {
    float angle = i * angleStep;
    float audioValue = combinedBuffer[i] * 60;

    float x = visualizerX + visualizerWidth / 2 + cos(angle) * (radius + audioValue);
    float y = visualizerY + visualizerHeight / 2 + sin(angle) * (radius + audioValue);

    stroke(rainbowWave(time + PI / 2));
    curveVertex(x, y);
  }
  endShape(CLOSE);
}

float[] getCombinedAudioBuffer() {
  int bufferSize = drumPlayers[0].bufferSize();
  float[] combinedBuffer = new float[bufferSize];
  int activePlayers = 0;

  // Add up buffers from all active players
  for (AudioPlayer player : drumPlayers) {
    if (player.isPlaying()) {
      for (int i = 0; i < bufferSize; i++) {
        combinedBuffer[i] += player.mix.get(i);  // Sum the buffer values
      }
      activePlayers++;
    }
  }

  // Average the combined buffer if there are active players
  if (activePlayers > 0) {
    for (int i = 0; i < bufferSize; i++) {
      combinedBuffer[i] /= activePlayers;  // Normalize the summed buffer
    }
  }
  
  return combinedBuffer;
}
