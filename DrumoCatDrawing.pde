float width = 1280;
float height = 720;

// Cat Drawing
float centerX = width / 2;
float centerY = height / 2;

float bodyWidth = 215;
float bodyHeight = 235;
float footWidth = 130;
float footHeight = 50;
float headWidth = 180;
float headHeight = 180;
float eyeWidth = 50;
float irisWidth = 38;
float irisRadius = 12;  // Movement limit for irises
float mouthWidth = 20;
float mouthHeight = 20;
float armWidth = 50;
float armHeight = 120;

// Drumset Drawing
// Snare drum
float snareX = centerX + 70;
float snareY = centerY + 100;
float snareWidth = 80;
float snareHeight = 60;

// High tom
float highTomX = centerX + 20;
float highTomY = centerY + 70;
float highTomWidth = 80;
float highTomHeight = 50;

// Mid tom
float midTomX = centerX - 100;
float midTomY = centerY + 70;
float midTomWidth = 80;
float midTomHeight = 50;

// Floor tom
float floorTomX = centerX - 197;
float floorTomY = centerY + 110;
float floorTomWidth = 110;
float floorTomHeight = 120;

// Bass drum
float bassDrumX = centerX;  // The center of the ellipse
float bassDrumY = centerY + 200;
float bassWidth = 200;
float bassHeight = 200;

// Ride cymbal
float rideX = centerX - 150;
float rideY = centerY;
float cymbalWidth = 110;
float cymbalHeight = 30;

// Crash cymbal
float crashX = centerX + 140;
float crashY = centerY;

// Hi-hat
float hiHatX = centerX + 200;  // The center of the ellipse
float hiHatY = centerY + 60;

// Drum arm movement
float leftArmTargetX, leftArmTargetY;
float rightArmTargetX, rightArmTargetY;

// Snare drum
float armSnareX = centerX + 600;
float armSnareY = centerY - 500;

// Mid tom
float armMidTomX = centerX + 65;
float armMidTomY = centerY + 70;

// Floor tom
float armFloorTomX = centerX + 197;
float armFloorTomY = centerY + 250;

// High tom
float armHighTomX = centerX + 300;
float armHighTomY = centerY - 45;

// Ride cymbal
float armRideX = centerX - 197 + floorTomWidth / 2;
float armRideY = centerY + 110 + floorTomHeight / 2;

// Crash cymbal
float armCrashX = centerX - 70;
float armCrashY = centerY - 100;

// Hi-hat
float armHiHatX = centerX + 300;  // The center of the ellipse
float armHiHatY = centerY - 1500;

// Variables to control the hit indicator
float hitIndicatorX = 0;
float hitIndicatorY = 0;
float hitIndicatorSize = 0;
float hitFadeTime = 300; // Time in milliseconds for the indicator to fade out
float hitAlpha = 255;
boolean hitIndicatorActive = false;
int hitStartTime = 0;

// Declare variables to control the arm and leg positions
boolean leftArmHitting = false;
boolean rightArmHitting = false;

int leftArmLastHitTime = 0;
int rightArmLastHitTime = 0;
float snapBackDelay = 150;

float tailAngle = 0;  // Angle for tail swaying

color lightOrange = color(255, 165, 0); 
color darkOrange = color(255, 140, 0);  
color lightPink = color(255, 182, 193); 
color white = color(255);
color silver = color(192, 192, 192); 
color black = color(0);
color red = color(255, 0, 0); // Color for drums
color gold = color(207,181,59); // Color for cymbals
color wood = color(248, 223, 161);

// BG colors
color lightGray = color(88, 88, 88);
color darkGray = color(44, 44, 44);
color fontColor = color(194, 194, 194);

color[] rainbowColors = {
  color(255, 20, 147), // D - pink
  color(148, 0, 211),   // r - purple
  color(0, 0, 255),     // u - blue
  color(0, 255, 255), // m - light blue
  color(0, 255, 0),     // o - green
  color(255, 255, 0),   // C - yellow
  color(255, 127, 0),   // a - orange
  color(255, 0, 0)      // t - red
};

void drumoSet(){
  float centerX = width / 2;
  float centerY = height / 2;
  
  float bassWidth = 200;
  float bassHeight = 200;
  float midTomWidth = 80;
  float midTomHeight = 50;
  float highTomWidth = 80;
  float highTomHeight = 50;
  float floorTomWidth = 110;
  float floorTomHeight = 120;
  float snareWidth = 80;
  float snareHeight = 60;
  float cymbalWidth = 110;
  float cymbalHeight = 30;
  
  strokeWeight(2);
  
  // snare
  fill(red);
  rect(snareX, snareY, snareWidth, snareHeight);
  
  // mid tom
  fill(red);
  rect(midTomX, midTomY, midTomWidth, midTomHeight);
  
  // floor tom
  rect(floorTomX, floorTomY, floorTomWidth, floorTomHeight);
  
  // high tom
  fill(red);
  rect(highTomX, highTomY, highTomWidth, highTomHeight);

  // bass drum
  fill(wood); // outer rim
  ellipse(bassDrumX, bassDrumY, bassWidth, bassHeight);

  fill(red); // inner
  ellipse(bassDrumX, bassDrumY, bassWidth - 10, bassHeight - 10);

  // ride
  fill(gold);
  ellipse(rideX, rideY, cymbalWidth, cymbalHeight);
  
  // crash
  fill(gold);
  ellipse(crashX, crashY, cymbalWidth, cymbalHeight);
  
  // hi hat
  fill(gold);
  ellipse(hiHatX, hiHatY, cymbalWidth, cymbalHeight);
  
  // hardware
  strokeWeight(6);
  stroke(lightGray);
  
  // ride stand
  line(centerX - 150, centerY, centerX - 160, centerY + 40);
  line(centerX - 160, centerY + 40, centerX - 220, centerY + 60);
  line(centerX-185, centerY + 50, centerX-185, centerY + 250);
  line(centerX-185, centerY + 250, centerX-220, centerY + 270);
  line(centerX-185, centerY + 250, centerX-150, centerY + 270);
  
  // bass drum stand
  line(centerX-88, centerY + 250, centerX-108, centerY + 270);
  line(centerX+88, centerY + 250, centerX+108, centerY + 270);
  
  // floor tom stand
  line(centerX-158, centerY + 231, centerX-160, centerY + 252);
  
  // snare stand
  line(centerX + 110, centerY + 161, centerX + 110, centerY + 240);
  line(centerX+110, centerY + 240, centerX+85, centerY + 270);
  line(centerX+110, centerY + 240, centerX+135, centerY + 270);
  
  // crash stand
  line(centerX + 140, centerY, centerX + 150, centerY + 40);
  line(centerX + 150, centerY + 40, centerX + 210, centerY + 60);
  line(centerX+175, centerY + 50, centerX+175, centerY + 250);
  line(centerX+175, centerY + 250, centerX+210, centerY + 270);
  line(centerX+175, centerY + 250, centerX+140, centerY + 270);
  
  // hi hat stand
  line(centerX+200, centerY + 76, centerX+200, centerY + 250);
  line(centerX+200, centerY + 250, centerX+235, centerY + 270);
  line(centerX+200, centerY + 250, centerX+165, centerY + 270);
  line(centerX+200, centerY + 44, centerX+200, centerY);
}

void triggerHitIndicator(float hitX, float hitY) {
    hitIndicatorX = hitX;
    hitIndicatorY = hitY;
    hitIndicatorSize = 0;
    hitAlpha = 255;
    hitIndicatorActive = true;
    hitStartTime = millis();
}

void drawHitIndicator() {
  if (hitIndicatorActive) {
    
    int elapsedTime = millis() - hitStartTime;
    hitIndicatorSize = map(elapsedTime, 0, hitFadeTime, 0, 100);
    hitAlpha = map(elapsedTime, 0, hitFadeTime, 255, 0);

    noFill();
    stroke(rainbowWave(time), hitAlpha); 
    strokeWeight(4);
    ellipse(hitIndicatorX, hitIndicatorY, hitIndicatorSize, hitIndicatorSize); // Draw the expanding ring

    if (elapsedTime >= hitFadeTime) {
      hitIndicatorActive = false;
      hitIndicatorX = 0;
      hitIndicatorY = 0; 
    }
  }
}

void drumoCat(){
  float centerX = width / 2;
  float centerY = height / 2;

  float bodyWidth = 215;
  float bodyHeight = 235;
  float footWidth = 130;
  float footHeight = 50;
  float headWidth = 180;
  float headHeight = 180;
  float eyeWidth = 50;
  float irisWidth = 38;
  float irisRadius = 12;
  float mouthWidth = 20;
  float mouthHeight = 20;
  
  stroke(0);
  
  float tailSway = sin(time) * 20;
  fill(white);
  stroke(255);
  strokeWeight(8);
  bezier(centerX + 60, centerY + 60, 
         centerX + 60 + tailSway, centerY + 30, 
         centerX + 60 + tailSway, centerY - 70, 
         centerX + 60, centerY - 100);
  
  strokeWeight(2); 
  
  // body
  fill(white);
  ellipse(centerX, centerY + 90, bodyWidth, bodyHeight);
  
  // left foot
  strokeWeight(1.5);
  stroke(black);
  ellipse(centerX - 100, centerY + 200, footWidth, footHeight);
  
  // right foot
  ellipse(centerX + 100, centerY + 200, footWidth, footHeight);
  
  
  // head
  strokeWeight(8); 
  stroke(white);
  fill(white);
  ellipse(centerX, centerY - 100, headWidth, headHeight);
  
  // left ear
  fill(lightPink);
  triangle(centerX - 80, centerY - 140, centerX - 60, centerY - 195, centerX - 40, centerY - 170);
  
  // right ear
  triangle(centerX + 80, centerY - 140, centerX + 60, centerY - 195, centerX + 40, centerY - 170);
 
  strokeWeight(1.5);
  stroke(black);
  
   // Left eye
  fill(255);
  ellipse(centerX - 50, centerY - 70, eyeWidth, eyeWidth);

  // Right eye
  ellipse(centerX + 50, centerY - 70, eyeWidth, eyeWidth);

  // Calculate direction to the mouse for iris movement
  float angleLeftEye = atan2(mouseY - (centerY - 70), mouseX - (centerX - 50));
  float leftIrisX = constrain(centerX - 50 + cos(angleLeftEye) * irisRadius, centerX - 50 - irisRadius, centerX - 50 + irisRadius);
  float leftIrisY = constrain(centerY - 70 + sin(angleLeftEye) * irisRadius, centerY - 70 - irisRadius, centerY - 70 + irisRadius);

  float angleRightEye = atan2(mouseY - (centerY - 70), mouseX - (centerX + 50));
  float rightIrisX = constrain(centerX + 50 + cos(angleRightEye) * irisRadius, centerX + 50 - irisRadius, centerX + 50 + irisRadius);
  float rightIrisY = constrain(centerY - 70 + sin(angleRightEye) * irisRadius, centerY - 70 - irisRadius, centerY - 70 + irisRadius);

  // Left iris
  fill(0);
  ellipse(leftIrisX, leftIrisY, irisWidth, irisWidth);

  // Right iris
  ellipse(rightIrisX, rightIrisY, irisWidth, irisWidth);
  
  // mouth
  strokeWeight(1.5);
  noFill();
  arc(centerX - 10, centerY - 50, mouthWidth, mouthHeight, 0, PI); 
  arc(centerX + 10, centerY - 50, mouthWidth, mouthHeight, 0, PI);
}

void drumoArms() {
  stroke(black);
  strokeWeight(2);
  fill(white);
  
  float leftShoulderX = centerX - 65;
  float leftShoulderY = centerY + 40;
  
  float rightShoulderX = centerX + 65;
  float rightShoulderY = centerY + 40;

  // Left arm
  if (leftArmHitting) {
    // Calculate angle towards the target
    float angleLeftArm = atan2(leftArmTargetY - leftShoulderY, leftArmTargetX - leftShoulderX);
    
    // Extend the height of the arm when hitting
    float extendedArmHeight = armHeight * 1.5;

    pushMatrix();
    translate(leftShoulderX, leftShoulderY);
    rotate(angleLeftArm);
    arc(0, 0, armWidth, extendedArmHeight, 0, PI);
    popMatrix();
  } else if (millis() - leftArmLastHitTime < snapBackDelay) {
    // Snap back to resting position
    pushMatrix();
    translate(leftShoulderX, leftShoulderY);
    rotate(-PI / 6);
    arc(0, 0, armWidth, armHeight, 0, PI);
    popMatrix();
  } else {
    // Idle/Default position
    leftArmHitting = false;
    pushMatrix();
    translate(leftShoulderX, leftShoulderY);
    rotate(0);
    arc(0, 0, armWidth, armHeight, 0, PI);
    popMatrix();
  }

  // Right arm
  if (rightArmHitting) {
    // Calculate angle towards the target
    float angleRightArm = atan2(rightArmTargetY - rightShoulderY, rightArmTargetX - rightShoulderX);
    
    // Extend the height of the arm when hitting
    float extendedArmHeight = armHeight * 1.5;
    
    pushMatrix();
    translate(rightShoulderX, rightShoulderY);
    rotate(angleRightArm);
    arc(0, 0, armWidth, extendedArmHeight, 0, PI);
    popMatrix();
  } else if (millis() - rightArmLastHitTime < snapBackDelay) {
    pushMatrix();
    translate(rightShoulderX, rightShoulderY);
    rotate(PI / 6);
    arc(0, 0, armWidth, armHeight, 0, PI);
    popMatrix();
  } else {
    // Idle/Default position
    rightArmHitting = false;
    pushMatrix();
    translate(rightShoulderX, rightShoulderY);
    rotate(0);
    arc(0, 0, armWidth, armHeight, 0, PI);
    popMatrix();
  }
}

void checkTimers() {
  int currentTime = millis();

  // Reset the left arm after the hitDuration
  if (leftArmHitting && currentTime - leftArmLastHitTime > snapBackDelay) {
    leftArmHitting = false;
  }
  
  // Reset the right arm after the hitDuration
  if (rightArmHitting && currentTime - rightArmLastHitTime > snapBackDelay) {
    rightArmHitting = false;
  }
}

void animateArmHit(boolean isLeftArm, float targetX, float targetY) {
  if (isLeftArm) {
    leftArmHitting = true;
    leftArmLastHitTime = millis();  // Track the last time the left arm hit
    leftArmTargetX = targetX;
    leftArmTargetY = targetY;
  } else {
    rightArmHitting = true;
    rightArmLastHitTime = millis();  // Track the last time the right arm hit
    rightArmTargetX = targetX;
    rightArmTargetY = targetY;
  }
}

color rainbowWave(float t) {
  float r = 127 + 127 * sin(t);      // Red channel
  float g = 127 + 127 * sin(t + TWO_PI / 3);  // Green channel
  float b = 127 + 127 * sin(t + 2 * TWO_PI / 3);  // Blue channel
  return color(r, g, b);  // Return the color
}
