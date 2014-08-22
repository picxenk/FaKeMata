// Fa.Ke. Board 2 : FaKeMata
// by SeungBum Kim <picxenk@gmail.com>

boolean debugOn = false;

int toneOutPin = 0;
int ledPin = 1;
int key1Pin = 2;
int key2Pin = 3;
int key3Pin = 4;

int key1, key2, key3, key4;
int note;
int noteDuration = 100;
int noteDelay = 20;
int keyNumber = 0;
int noteTable[] = {0, 1047, 1175, 1319, 1397, 1568, 1760, 1976}; 

boolean repeatOn;
int noteSequence[8];
int seqIndex;
boolean keyInputReady;

void setup() {
  if (debugOn) {
    Serial.begin(9600);
  }
  
//  repeatOn = false;
//  for (int i=0; i<8; i++) {
//    noteSequence[i] = 0;
//  }
//  seqIndex = 0;
  
  pinMode(key1Pin, INPUT);
  pinMode(key2Pin, INPUT);
  pinMode(key3Pin, INPUT);
  pinMode(ledPin, OUTPUT);

  // old way to attach pull-up
  digitalWrite(key1Pin, HIGH);
  digitalWrite(key2Pin, HIGH);
  digitalWrite(key3Pin, HIGH);
  
  key1 = LOW;
  key2 = LOW;
  key3 = LOW;
}

/**********  MAIN CODE : READ ME FIRST **********/
void loop() {
  
//  if (repeatOn) {
//    delay(200);
//    for (seqIndex=0; seqIndex<8; seqIndex++) {
//      play_tone(noteTable[noteSequence[seqIndex]], 500);
//      delay(500);
//      noTone(toneOutPin);
//    }
//  } else {
    checkKeyStatus();
    if (key1 == HIGH && key2 == HIGH && key3 == HIGH) {
      keyInputReady = true;
      digitalWrite(ledPin, LOW);
//      if (seqIndex == 8) repeatOn = true;
    } else {
      digitalWrite(ledPin, HIGH);
      keyNumber = 7-(key3*4+key2*2+key1*1);
      play_tone(noteTable[keyNumber], noteDuration);
//      updateNoteSequence(keyNumber);

    }
//  }
}


/**********  DETAILS BELOW **********/
void checkKeyStatus() {
//  delay(20);
  key1 = digitalRead(key1Pin);
  key2 = digitalRead(key2Pin);
  key3 = digitalRead(key3Pin);
}

void updateNoteSequence(int number) {
  if (keyInputReady) {
    noteSequence[seqIndex] = number;
    seqIndex++;
    keyInputReady = false;
  }
}

void play_tone(int value, int duration) {
  tone(toneOutPin, value, duration);
  delay(noteDelay);
  noTone(toneOutPin);
}

