import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import controlP5.*;
import themidibus.*;

MidiBus myBus;
Minim minim;

AudioPlayer kick, snare, tom1, tom2, tom3, openHH, closedHH, crash, ride, bell, song, metronome;
AudioPlayer[] drumPlayers;

ControlP5 cp5;
String[] mp3Files;
DropdownList fileList;
String selectedFile = "";

boolean sliderClicked = false;
float previousPlaybackValue = 0;
float playbackVolume = 0.5;

float time = 0.0;  // Time variable for animating the colors

AudioInput in;
int recordingCount = 0;
AudioRecorder recorder;
boolean isRecording = false;


ArrayList<MidiEvent> recordedEvents = new ArrayList<MidiEvent>();
int recordingStartTime = 0;
int currentEventIndex = 0;

String[] sequenceFiles;
ArrayList<MidiEvent> sequenceEvents = new ArrayList<MidiEvent>();
DropdownList sequenceFileList;
String selectedSequenceFile = "";
boolean isSequencePlaying = false;
int sequencePlaybackStartTime = 0;

ArrayList<Integer> tapTimes = new ArrayList<Integer>();
int lastTapTime = 0;
float tappedBPM = 0;

int metronomeInterval = 60000; // Default to 1 beat per minute
int lastMetronomeTime = 0;
boolean metronomePlaying = false;

ArrayList<String> consoleText = new ArrayList<String>();
String latestMessage = "Welcome to DrumoCat!";


class MidiEvent {
  int pitch;
  int velocity;
  int timestamp;
  
  MidiEvent(int p, int v, int t) {
    pitch = p;
    velocity = v;
    timestamp = t;
  }
}

void setup() {
  size(1280, 720);
  
  cp5 = new ControlP5(this);
  
  minim = new Minim(this);  // Initialise Minim library
  
  kick = minim.loadFile("drum_sounds/kick.wav");
  snare = minim.loadFile("drum_sounds/snare.wav");
  tom1 = minim.loadFile("drum_sounds/tom1.wav");
  tom2 = minim.loadFile("drum_sounds/tom2.wav");
  tom3 = minim.loadFile("drum_sounds/tom3.wav");
  openHH = minim.loadFile("drum_sounds/open-hh.wav");
  closedHH = minim.loadFile("drum_sounds/closed-hh.wav");
  crash = minim.loadFile("drum_sounds/crash.wav");
  ride = minim.loadFile("drum_sounds/ride.wav");
  bell = minim.loadFile("drum_sounds/bell.wav");
  
  drumPlayers = new AudioPlayer[]{kick, snare, tom1, tom2, tom3, openHH, closedHH, crash, ride, bell};
  
  metronome = minim.loadFile("drum_sounds/metronome.wav");
  
  // Initialise MIDI connection
  MidiReceiver receiver = new MidiReceiver();
  MidiBus.list(); // List all available MIDI devices in the console
  myBus = new MidiBus(receiver, "Alesis Nitro", "Alesis Nitro");
  
  in = minim.getLineIn(Minim.STEREO, 2048); // For Windows, Go to Control Panel > Hardware and Sound > Sound > Recording > Set Stereo Mix as Default Device
  
  // ControlP5 Elements
  cp5.addButton("Play")
     .setPosition(270, 50)
     .setSize(60, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray);

   cp5.addSlider("Playback")
   .setPosition(345, 60)
   .setSize(600, 20)
   .setRange(0, 0)
   .setValue(0)
   .setColorBackground(darkGray)
   .setColorLabel(color(white));

  cp5.addSlider("Volume")
   .setPosition(1010, 60)
   .setSize(200, 20)
   .setRange(0, 1)    // Slider range from 0.0 to 1.0
   .setValue(playbackVolume)    // Set default volume to 50%
   .setColorLabel(color(white))
   .setColorForeground(lightGray)
   .setColorBackground(darkGray);
  
  cp5.addButton("Record")
   .setPosition(65, 100)   
   .setSize(60, 30)
   .setColorBackground(color(50, 200, 50))
   .setColorActive(lightGray);

  cp5.addButton("Stop")
   .setPosition(165, 100) 
   .setSize(60, 30)
   .setColorBackground(color(200, 50, 50))
   .setColorActive(color(150, 30, 30));
  
  // Initialise dropdown list for MP3 files
  fileList = cp5.addDropdownList("Select Audio")
                .setPosition(30, 50)
                .setSize(200, 100)
                .setBarHeight(30)
                .setItemHeight(20)
                .setHeight(120)
                .setWidth(220)
                .setColorBackground(darkGray)
                .setColorForeground(lightGray)
                .close();
   
   refreshFileList();
   
   cp5.addButton("Play Sequence")
     .setPosition(510, 100)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray);
     
   cp5.addButton("Stop Sequence")
     .setPosition(650, 100)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray);

  sequenceFileList = cp5.addDropdownList("Select Sequence")
     .setPosition(270, 100)
     .setSize(200, 100)
     .setBarHeight(30)
     .setItemHeight(20)
     .setHeight(120)
     .setWidth(220)
     .setColorBackground(darkGray)
     .setColorForeground(lightGray)
     .close();

  refreshSequenceFileList();
  
  cp5.addButton("Refresh Sequence List")
     .setPosition(790, 100)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray);
   
  cp5.addButton("Sine")
     .setPosition(60, 360)
     .setSize(80, 30)
     .setLabel("Sine")
     .setColorBackground(darkGray)
     .setColorActive(lightGray);
     
  cp5.addButton("Bar")
     .setPosition(140, 360)
     .setSize(80, 30)
     .setLabel("Bar")
     .setColorBackground(darkGray)
     .setColorActive(lightGray);
     
  cp5.addButton("Radial")
     .setPosition(220, 360)
     .setSize(80, 30)
     .setLabel("Radial")
     .setColorBackground(darkGray)
     .setColorActive(lightGray);
  
  cp5.addSlider("Pan")
     .setPosition(controlX + 30, controlY + 100)
     .setSize(280, 20)
     .setRange(-1.0, 1.0) // Pan left (-1) to right (1)
     .setValue(0.0) // Default is centered
     .setColorForeground(lightGray)
     .setColorBackground(darkGray);

  cp5.addLabel("Visualizer Type")
     .setPosition(150, 340)
     .setColor(color(255));
     
  cp5.addButton("Trim Intro")
     .setPosition(controlX + 190, controlY + 190)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray);
  
  cp5.addButton("Quantize")
     .setPosition(controlX + 190, controlY + 240)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("Quantize");
     
  cp5.addTextfield("QuantizeBPM")
     .setPosition(controlX + 30, controlY + 240)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("Current BPM");
  
  cp5.addButton("TapBPM")
     .setPosition(controlX + 190, controlY + 140)
     .setSize(60, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("BPM Tapper");;
  
  cp5.addTextlabel("TappedBPMLabel")
     .setPosition(controlX + 255, controlY + 145)
     .setSize(60, 30)
     .setColorValue(white)
     .setText("Tapped BPM:");
  
  cp5.addTextlabel("TappedBPMValue")
     .setPosition(controlX + 255, controlY + 155)
     .setSize(60, 30)
     .setColorValue(white) 
     .setText("0");
  
  cp5.addTextfield("AdjustBPM")
     .setPosition(controlX + 30, controlY + 290)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("Set BPM");
  
  cp5.addButton("ApplyAdjustBPM")
     .setPosition(controlX + 190, controlY + 290)
     .setSize(120, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("Change BPM");
   
  cp5.addButton("saveButton")
     .setLabel("Save Sequence")
     .setPosition(120, 660)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setSize(100, 30);
     
  cp5.addButton("getCurrentBPMButton") 
     .setLabel("Current BPM")  
     .setPosition(controlX + 30, controlY + 190) 
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setSize(60, 30);  

  cp5.addTextlabel("bpmLabel")  
     .setPosition(controlX + 95, controlY + 200)  
     .setSize(120, 30) 
     .setText("Current BPM: 0")  
     .setColor(white);
   
  cp5.addTextfield("Metronome")
     .setPosition(controlX + 30, controlY + 140)
     .setSize(60, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("Metronome BPM");
     
  cp5.addButton("MetronomeStart")
     .setPosition(controlX + 100, controlY + 140)
     .setSize(60, 30)
     .setColorBackground(darkGray)
     .setColorActive(lightGray)
     .setLabel("Start");
}

void draw(){
  background(black);
  
  noFill();
  stroke(rainbowWave(time + PI / 2));
  strokeWeight(5);
  rect(920, 152, 357, 268);
  displayInstructions(); 

  // Draw the top bar
  noFill();
  stroke(rainbowWave(time + PI / 2));  
  strokeWeight(5);
  rect(2, 2, width-4, 150);
  
  displayInstructions(); 
  
  noFill();
  textSize(11);
  displayConsole();
  
  cp5.getController("Playback").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Playback").setColorActive(rainbowWave(time + PI / 2));
  cp5.getController("Volume").setColorActive(rainbowWave(time + PI / 2));
  cp5.getController("Play").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Record").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Stop").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Play Sequence").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Stop Sequence").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Refresh Sequence List").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Sine").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Bar").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Radial").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("TapBPM").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Quantize").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("MetronomeStart").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("getCurrentBPMButton").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("saveButton").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Trim Intro").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("ApplyAdjustBPM").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("Pan").setColorActive(rainbowWave(time + PI / 2));
  cp5.getController("Metronome").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("AdjustBPM").setColorForeground(rainbowWave(time + PI / 2));
  cp5.getController("QuantizeBPM").setColorForeground(rainbowWave(time + PI / 2));

  if (isRecording) {
        fill(255, 0, 0);  // Red color to show recording
        cp5.getController("Record").setColorBackground(color(255, 0, 0));  // Change button color to red
    } else {
        cp5.getController("Record").setColorBackground(darkGray);  // Revert to original button color
    }
    
  if (metronomePlaying) {
        fill(255, 0, 0);  // Red color to show recording
        cp5.getController("MetronomeStart").setColorBackground(color(255, 0, 0));  // Change button color to red
    } else {
        cp5.getController("MetronomeStart").setColorBackground(darkGray);  // Revert to original button color
    }


   //Check if a song is playing, then update the playback slider
  if (song != null && song.isPlaying() && !sliderClicked) {
    float currentTime = song.position();  // Get current playback time
    ((Slider)cp5.getController("Playback")).setRange(0, song.length());  // Update slider range
    ((Slider)cp5.getController("Playback")).setValue(currentTime);         // Update slider value  
  }
  
  // Display each letter of "DrumoCat" in different colors
  textSize(28);
  textAlign(CENTER, CENTER);
  
  String word = "DRUMOCAT";
  float letterSpacing = 16;  // Space between letters
  float startX = width / 2 - (word.length() * letterSpacing) / 2;  // Centering the text
  
  // Loop through each letter and apply corresponding color
  for (int i = 0; i < word.length(); i++) {
    fill(rainbowColors[i]);  // Set the color for each letter
    text(word.charAt(i), startX + i * letterSpacing, 30);  // Draw each letter
  }

  noFill();
  rect(controlX, controlY, controlWidth, controlHeight);

  noFill();
  rect(visualizerX, visualizerY, visualizerWidth, visualizerHeight);
  
  checkTimers();
  time += 0.05;
  
  drumoCat();
  drumoSet();
  drumoArms();
  
  if (hitIndicatorActive) {
    drawHitIndicator();
  }
  
  updateSequencePlayback();
  
    if (visualizerMode == 1) {
      drawWaveformVisualizer(); // Waveform visualizer
    } else if (visualizerMode == 2) {
      drawBarVisualizer(); // Bar visualizer (improved version)
    } else if (visualizerMode == 3) {
      drawCircularVisualizer(); // Circular visualizer (fixed version)
    }
    
  if (metronomePlaying) {
    if (millis() - lastMetronomeTime >= metronomeInterval) {
      metronome.rewind();
      metronome.play();
      lastMetronomeTime = millis();
    }
  }
  

}

public class MidiReceiver { 
  // This function is called when a MIDI note is received
  void noteOn(int channel, int pitch, int velocity) {
    if (velocity != 0){
      consolePrintln("Note On, Channel: " + channel + " Pitch: " + pitch + " Velocity: " + velocity);
      
      // Record the event (if recording)
      if (isRecording) {
        int currentTime = millis();  // Get the current time in milliseconds
        int timeDiff = currentTime - recordingStartTime;  // Calculate time difference from the start of recording
        recordedEvents.add(new MidiEvent(pitch, velocity, timeDiff));  // Store the event
      }
      
      // Handle playing the corresponding drum sound
      playDrumSound(pitch, velocity);
    }
  }
}

void playDrumSound(int pitch, int velocity){
// Map velocity (0-127) to amplitude (0.0 to 1.0)
float volume = map(velocity, 0, 100, 0, 1.0);
float gain = volume * 20 - 20;
  
  // Play corresponding drum sound with dynamic velocity
  switch (pitch) {
    case 36: // Kick drum
      kick.rewind();
      kick.play();
      kick.setGain(gain);
      triggerHitIndicator(centerX, centerY + 200);
      break;
    case 38:  // Snare drum
      snare.rewind();
      snare.play();
      snare.setGain(gain);
      animateArmHit(false, armSnareX, armSnareY);
      triggerHitIndicator(snareX + 60, snareY);
      break;
    case 48:  // High tom 
      tom1.rewind();
      tom1.play();
      tom1.setGain(gain);
      animateArmHit(false, armHighTomX, armHighTomY);
      triggerHitIndicator(highTomX + 50, highTomY);
      break;
    case 45:  // Mid tom
      tom2.rewind();
      tom2.play();
      tom2.setGain(gain);
      animateArmHit(true, armMidTomX, armMidTomY);
      triggerHitIndicator(midTomX + 30, midTomY);
      break;
    case 43:  // Floor tom
      tom3.rewind();
      tom3.play();
      tom3.setGain(gain);
      animateArmHit(true, armFloorTomX, armFloorTomY);
      triggerHitIndicator(floorTomX + 100, floorTomY);
      break;
    case 51:  // Ride cymbal
      ride.rewind();
      ride.play();
      ride.setGain(gain);
      animateArmHit(true, armRideX, armRideY);
      triggerHitIndicator(rideX, rideY);
      break;
    case 49:  // Crash cymbal
      crash.rewind();
      crash.play();
      crash.setGain(gain);
      animateArmHit(false, armCrashX, armCrashY);
      triggerHitIndicator(crashX, crashY);
      break;
    case 42:  // Closed hi-hat
      closedHH.rewind();
      closedHH.play();
      closedHH.setGain(gain);
      animateArmHit(false, armHiHatX, armHiHatY);
      triggerHitIndicator(hiHatX - 30, hiHatY);
      break;
    case 46:  // Open hi-hat
      openHH.rewind();
      openHH.play();
      openHH.setGain(gain);
      animateArmHit(false, armHiHatX, armHiHatY);
      triggerHitIndicator(hiHatX - 30, hiHatY);
      break;
    case 40: // Bell/Tambourine
      bell.rewind();
      bell.play();
      bell.setGain(gain);
      break;
    default:
      consolePrintln("No sound mapped for this pitch");
  }
}

void keyPressed() {
  int pitch = 0;
  
  // Map keys to drum sounds (pitches)
  switch (key) {
    case 'Q':
    case 'q':
      pitch = 36;  // Kick drum
      break;
    case 'W':
    case 'w':
      pitch = 38;  // Snare drum
      break;
    case 'E':
    case 'e':
      pitch = 48;  // High tom
      break;
    case 'R':
    case 'r':
      pitch = 45;  // Mid tom
      break;
    case 'T':
    case 't':
      pitch = 43;  // Floor tom
      break;
    case 'Y':
    case 'y':
      pitch = 51;  // Ride cymbal
      break;
    case 'U':
    case 'u':
      pitch = 49;  // Crash cymbal
      break;
    case 'I':
    case 'i':
      pitch = 42;  // Closed hi-hat
      break;
    case 'O':
    case 'o':
      pitch = 46;  // Open hi-hat
      break;
    case 'P':
    case 'p':
      pitch = 40;  // Bell
      break;
    default:
      return;
  }

  int velocity = 50;
  
  // Play the corresponding drum sound
  playDrumSound(pitch, velocity);
  
  // Record the event (if recording)
  if (isRecording) {
    int currentTime = millis();
    int timeDiff = currentTime - recordingStartTime;
    recordedEvents.add(new MidiEvent(pitch, velocity, timeDiff));
  }
}

void mousePressed() {
  // Check if mouse is pressed on the Playback slider
  var playbackSlider = (Slider) cp5.getController("Playback");
  if (playbackSlider.isMouseOver()) { // Check if mouse is over the slider
    sliderClicked = true; // Set the flag to true when clicking the slider
  }
}

void mouseReleased() {
  // Reset the sliderClicked flag when mouse is released
  sliderClicked = false; 
}

void controlEvent(ControlEvent event) {
  if (event.isFrom("Volume")) {
    float volume = event.getValue(); // Get the current value of the slider
    if (song != null) {
      float gain = (volume == 0) ? -80 : map(volume, 0, 1, -40, 0); 
      song.setGain(gain); // Adjust the song's gain
      playbackVolume = volume; // Keep track of the playback volume
    }
  }
  
  // Only jump if the slider is clicked
  if (event.isFrom("Playback") && sliderClicked) {
    float newTime = event.getValue();
    if (song != null && newTime != previousPlaybackValue) { // Only jump if the value has changed
      song.cue(int(newTime)); // Jump to the selected time
      previousPlaybackValue = newTime; // Store the current value
    }
  }
  
  if (event.isFrom("Select Audio")) {
    
    // Handling Dropdown Menu
    int selectedIndex = int(event.getValue());
    selectedFile = mp3Files[selectedIndex];
    consolePrintln("Selected Song: " + selectedFile);
    
    // Load the selected MP3 file for playback
    if (song != null && song.isPlaying()) {
      song.close();
    }
    song = minim.loadFile("songs/" + selectedFile);
    float gain = (playbackVolume == 0) ? -80 : map(playbackVolume, 0, 1, -40, 0);
    song.setGain(gain);
  }
  
  // Handle the Record button click
  if (event.isFrom("Record")) {
    startRecording();  // Call the startRecording function
  }

  // Handle the Stop button click
  if (event.isFrom("Stop")) {
    stopRecording();   // Call the stopRecording function
  }

  if (event.isFrom("Select Sequence")) {
    int selectedIndex = int(event.getValue());
    selectedSequenceFile = sequenceFiles[selectedIndex];
    consolePrintln("Selected Sequence: " + selectedSequenceFile);
    loadSequenceFile(selectedSequenceFile);
  }
  
    
  if (event.isFrom("Play Sequence")) {
    playSequence();
  }
  
  if (event.isFrom("Stop Sequence")) {
    stopSequence();
  }
  
  if (event.isFrom("Refresh Sequence List")) {
    refreshSequenceFileList();
  }

  
  if (event.isFrom("Pan")) {
    float pan = event.getValue();
    for (AudioPlayer player : drumPlayers) {
      player.setPan(pan);
    }
}
  
  if (event.isFrom("Trim Intro")) {
    trimIntro();
  }

  if (event.isFrom("Quantize")) {
          String targetBPMText = cp5.get(Textfield.class, "QuantizeBPM").getText();
          float targetBPM = float(targetBPMText);
          quantizeSequenceBPM(targetBPM);
      }
  
  if (event.isFrom("TapBPM")) {
          registerTap();
      }
  
  if (event.isFrom("ApplyAdjustBPM")) {
      String adjustBPMText = cp5.get(Textfield.class, "AdjustBPM").getText();
      float adjustBPM = float(adjustBPMText);
      adjustSequenceBPM(adjustBPM);
  }
  
  if (event.isFrom("saveButton")) {
      saveSequenceEvents();
      refreshSequenceFileList();
    }
    
  if (event.isFrom("getCurrentBPMButton")) {
      float currentBPM = calculateCurrentBPM();  // Get the current BPM
      cp5.get(Textlabel.class, "bpmLabel").setText("Current BPM: " + currentBPM);  // Update the text of the label to show the BPM
    }
  
  if (event.isFrom("MetronomeStart")) {
    if (!metronomePlaying) {
      String bpmText = cp5.get(Textfield.class, "Metronome").getText();
      float bpm = float(bpmText);
      metronomeInterval = int(60000 / bpm); // Calculate interval in milliseconds
      metronomePlaying = true;
      lastMetronomeTime = millis();
    } else {
      metronomePlaying = false;
    }
  }
  
  if (event.isFrom("Sine")) {
      visualizerMode = 1;
    }
    
    if (event.isFrom("Bar")) {
      visualizerMode = 2;
    }
    
    if (event.isFrom("Radial")) {
      visualizerMode = 3;
    }
}

void startRecording() {
  if (!isRecording) {
    consolePrintln("Recording MIDI events started...");
    recordedEvents.clear();  // Clear previous recordings
    recordingStartTime = millis();  // Mark the time when recording starts
    isRecording = true;
  } else {
    consolePrintln("Already recording...");
  }
}

void stopRecording() {
  if (isRecording) {
    consolePrintln("MIDI event recording stopped. " + recordedEvents.size() + " events recorded.");
    isRecording = false;
    // save the recorded events to a txt file
    saveRecordedEvents();
    refreshSequenceFileList();
  } else {
    consolePrintln("Not currently recording...");
  }
}

void saveRecordedEvents() {
  // Ensure the "recordings" folder exists
  File recordingsFolder = new File(sketchPath("recordings"));
  if (!recordingsFolder.exists()) {
    recordingsFolder.mkdir();  // Create the folder if it doesn't exist
  }
  
  // Find the next available filename by checking existing files
  int fileNumber = 1;
  String filename;
  File file;
  do {
    filename = "recordings/recording" + fileNumber + ".txt";
    file = new File(sketchPath(filename));
    fileNumber++;
  } while (file.exists());  // Increment the file number until a file does not exist
  
  // Save the recorded events to the new file
  PrintWriter output = createWriter(filename);
  for (MidiEvent event : recordedEvents) {
    output.println(event.pitch + "," + event.velocity + "," + event.timestamp);
  }
  output.flush();
  output.close();
  
  consolePrintln("Recorded events saved to " + filename);
}

void refreshFileList() {
    // Clear existing items in the dropdown
    fileList.clear();
  
    // Get all .mp3 and .wav files in the songs folder
    File folder = new File(sketchPath("songs"));
    mp3Files = folder.list((dir, name) -> 
        name.toLowerCase().endsWith(".mp3") || name.toLowerCase().endsWith(".wav"));
  
    // Populate dropdown with the updated audio files
    for (int i = 0; i < mp3Files.length; i++) {
        fileList.addItem(mp3Files[i], i);
    }
}

// Function to refresh available sequence files (e.g. .txt files)
void refreshSequenceFileList() {
  sequenceFileList.clear();
  
  File folder = new File(sketchPath("recordings"));
  sequenceFiles = folder.list((dir, name) -> name.toLowerCase().endsWith(".txt"));

  for (int i = 0; i < sequenceFiles.length; i++) {
    sequenceFileList.addItem(sequenceFiles[i], i);
  }
}

// Function to load the selected sequence file into memory
void loadSequenceFile(String filename) {
  String[] lines = loadStrings("recordings/" + filename);
  sequenceEvents.clear();

  for (String line : lines) {
    String[] parts = line.split(",");
    if (parts.length == 3) {
      int pitch = int(parts[0]);
      int velocity = int(parts[1]);
      int timestamp = int(parts[2]);
      sequenceEvents.add(new MidiEvent(pitch, velocity, timestamp));
    }
  }

  consolePrintln("Loaded " + sequenceEvents.size() + " events from " + filename);
}

// Function to play the sequence from start
void playSequence() {
  if (sequenceEvents.isEmpty()) {
    consolePrintln("No sequence loaded.");
    return;
  }

  isSequencePlaying = true;
  sequencePlaybackStartTime = millis();
  currentEventIndex = 0;
}

void updateSequencePlayback() {
  if (!isSequencePlaying || currentEventIndex >= sequenceEvents.size()) {
    return;
  }

  int currentTime = millis() - sequencePlaybackStartTime;

  // Play the current event if the current time has reached the event's timestamp
  MidiEvent event = sequenceEvents.get(currentEventIndex);
  if (currentTime >= event.timestamp) {
    playDrumSound(event.pitch, event.velocity);
    currentEventIndex++;
  }

  // Automatically stop playback if all events have been played
  if (currentEventIndex >= sequenceEvents.size()) {
    isSequencePlaying = false;
    consolePrintln("Sequence playback finished.");
  }
}

void trimIntro() {
  if (sequenceEvents.size() > 0) {
    int firstTimestamp = sequenceEvents.get(0).timestamp;  // Capture the first timestamp
    for (MidiEvent event : sequenceEvents) {
      event.timestamp -= firstTimestamp;  // Adjust each timestamp
    }
    consolePrintln("Intro trimmed. First event aligned to 0 ms.");

  } else {
    consolePrintln("No events loaded to trim intro.");
  }
}

void saveSequenceEvents() {
  // Ensure the "recordings" folder exists
  File recordingsFolder = new File(sketchPath("recordings"));
  if (!recordingsFolder.exists()) {
    recordingsFolder.mkdir();  // Create the folder if it doesn't exist
  }
  
  // Find the next available filename by checking existing files
  int fileNumber = 1;
  String filename;
  File file;
  do {
    filename = "recordings/transformed_sequence" + fileNumber + ".txt";
    file = new File(sketchPath(filename));
    fileNumber++;
  } while (file.exists());  // Increment until a unique filename is found
  
  // Prepare the lines for saving
  String[] lines = new String[sequenceEvents.size()];
  for (int i = 0; i < sequenceEvents.size(); i++) {
    MidiEvent event = sequenceEvents.get(i);
    lines[i] = event.pitch + "," + event.velocity + "," + event.timestamp;
  }

  // Save the file with the determined unique filename
  saveStrings(filename, lines);
  consolePrintln("Transformed sequence saved as " + filename);
}

void Play() {
    if (song != null) {
        float gain = (playbackVolume == 0) ? -80 : map(playbackVolume, 0, 1, -40, 0);
        song.setGain(gain);
        if (!song.isPlaying()) {
          song.play(); // Play the song
          consolePrintln("Playing: " + selectedFile);
        } else {
          song.pause(); // Pause the song
          consolePrintln("Paused: " + selectedFile);  
        }
        if (song.position() == song.length()){
          song.rewind();
        }
      }
}

void stopSequence() {
    if (isSequencePlaying) {
        isSequencePlaying = false;
        currentEventIndex = 0; // Reset event index
        consolePrintln("Sequence playback stopped.");
    } else {
        consolePrintln("No sequence is currently playing.");
    }
}

void registerTap() {
    int currentTime = millis();

    // Clear taps if a significant time has passed (for fresh tapping)
    if (tapTimes.size() > 0 && (currentTime - tapTimes.get(tapTimes.size() - 1)) > 2000) {
        tapTimes.clear();
        consolePrintln("Tap sequence reset.");
    }

    // Record the current tap time
    tapTimes.add(currentTime);

    // If there are at least two taps, calculate intervals and BPM
    if (tapTimes.size() > 1) {
        ArrayList<Integer> intervals = new ArrayList<Integer>();
        for (int i = 1; i < tapTimes.size(); i++) {
            int interval = tapTimes.get(i) - tapTimes.get(i - 1);
            intervals.add(interval);
        }

        // Calculate average interval
        float averageInterval = 0;
        for (int interval : intervals) {
            averageInterval += interval;
        }
        averageInterval /= intervals.size();

        // Convert interval to BPM
        tappedBPM = 60000 / averageInterval;
        
        // Update display and round to nearest whole number
        cp5.get(Textlabel.class, "TappedBPMValue").setText("" + round(tappedBPM));
    }

    // Keep only the latest few taps to avoid drift
    if (tapTimes.size() > 60) {
        tapTimes.remove(0);
    }
}

void quantizeSequenceBPM(float targetBPM) {
    // Calculate the duration of one quarter note (1/4 note) in milliseconds at the target BPM
    float quarterNoteMs = 60000.0 / targetBPM; // 1/4 note duration in ms

    consolePrintln("Quarter note duration for target BPM (" + targetBPM + "): " + quarterNoteMs + " ms");

    // Quantize each event timestamp to the nearest multiple of the quarter note duration
    for (MidiEvent event : sequenceEvents) {
        int originalTimestamp = event.timestamp;
        
        // Calculate the nearest multiple of quarterNoteMs
        int quantizedTimestamp = Math.round(originalTimestamp / quarterNoteMs) * Math.round(quarterNoteMs); // Round both parts
        
        event.timestamp = quantizedTimestamp;
    }

    consolePrintln("Sequence quantized to BPM: " + targetBPM);
}


void adjustSequenceBPM(float targetBPM) {
    if (targetBPM <= 0) {
        consolePrintln("Invalid target BPM. It must be greater than 0.");
        return;
    }
    
    float currentBPM = calculateCurrentBPM();
    if (currentBPM <= 0) {
        consolePrintln("Could not determine the current BPM from the sequence.");
        return;
    }
    
    // Round the BPM ratio for a more accurate adjustment
    float bpmRatio = currentBPM / targetBPM; // Reverse the ratio direction

    // Adjust the timestamps of each event based on the BPM ratio
    for (MidiEvent event : sequenceEvents) {
        event.timestamp = Math.round(event.timestamp * bpmRatio); // Round the timestamp
    }
    
    consolePrintln("Sequence successfully adjusted from " + Math.round(currentBPM) + " BPM to " + Math.round(targetBPM) + " BPM.");
}

float calculateCurrentBPM() {
    if (sequenceEvents.size() < 2) {
        consolePrintln("Not enough events to determine BPM.");
        return 0;
    }

    // Initialize minimum interval with a large number
    int minInterval = Integer.MAX_VALUE;

    // Find the smallest interval between consecutive timestamps in the sequence
    for (int i = 1; i < sequenceEvents.size(); i++) {
        int interval = sequenceEvents.get(i).timestamp - sequenceEvents.get(i - 1).timestamp;
        
        // Update minInterval if a smaller interval is found
        if (interval > 0 && interval < minInterval) {
            minInterval = interval;
        }
    }

    // If no valid interval is found, return 0
    if (minInterval == Integer.MAX_VALUE) {
        consolePrintln("No valid intervals found in the sequence.");
        return 0;
    }

    // Calculate BPM: 60,000 ms per minute divided by the minimum interval length
    return Math.round(60000.0 / minInterval); // Round the BPM calculation
}

void displayConsole() {
    float consoleX = 2;
    float consoleY = 200;
    float consoleWidth = 350;
    float consoleHeight = 80;
    
    strokeWeight(5);
    rect(consoleX, consoleY, consoleWidth, consoleHeight);

    fill(255); 
    text(latestMessage, consoleX + 170, consoleY + consoleHeight / 2 + 5);  // Adjust text position
}

void consolePrintln(String message) {
    latestMessage = message;  // Update to show only the newest message
}

void displayInstructions() {
    float textX = 930;  
    float textY = 116;  
    float textBoxWidth = 340;  
    textSize(12);  
    
    String instructions = "Instructions:\n" +
                      "- Click Record to capture your drumming and click Stop to save\n" +
                      "- Use the MP3 player to play along with songs\n" +
                      "- Select Sequence to load previous recordings, and click Play to hear them\n" +
                      "- Click Refresh Sequence List to update (delete recordings via file explorer in /recordings)\n" +
                      "- Press Trim Intro to remove unwanted silence at the start\n" +
                      "- Find BPM of recording then Click Quantize to snap notes to the beat (4/4 time signature and up to 1/4 notes only)\n" +
                      "- Press Current BPM to check the tempo after trimming and quantizing\n" +
                      "- Set BPM to adjust the tempo to match your style\n" +
                      "- Save Sequence to store your modified recording\n\n" +
                      "Enjoy making music\n" +
                      "!";

    fill(255);  
    text(instructions, textX, textY, textBoxWidth, 340);
}
