#define left 3
#define right 4
#define up 5
#define down 6
#define white 7
#define green 8
#define red 9
#define blue 10

int randnm = 0;
int difficulty = 0;
int seq[6];
int butt[6];
int count = 0;
bool com = true;
bool next = false;

void setup() {
  Serial.begin(9600);
  randomSeed(analogRead(0));
  pinMode(red, OUTPUT);
  pinMode(white, OUTPUT);
  pinMode(green, OUTPUT);
  pinMode(blue, OUTPUT);
  pinMode(left, INPUT);
  pinMode(right, INPUT);
  pinMode(up, INPUT);
  pinMode(down, INPUT);
}

void waitForRelease(int pin) {
  while (digitalRead(pin));
  delay(50);
}

void loop() {
  if (Serial.available()) {
    difficulty = Serial.read() - '0';
    next = true;

    while (difficulty >= 1 && difficulty <= 4 && next) {
      next = false;
      int delayTime = 1000;
      if (difficulty == 1) delayTime = 2000;
      else if (difficulty == 2) delayTime = 1500;
      else if (difficulty == 3) delayTime = 1000;
      else if (difficulty == 4) delayTime = 500;

      for (int i = 0; i < 6; i++) {
        randnm = random(7, 11);
        seq[i] = randnm;
        digitalWrite(randnm, HIGH);
        delay(delayTime);
        digitalWrite(randnm, LOW);
        delay(200);
      }

      count = 0;
      com = true;
      unsigned long startTime = millis();

      while (count < 6 && com) {
        if (millis() - startTime > 5000) {
          Serial.println("Timeout!");
          com = false;
          break;
        }

        if (digitalRead(left)) {
          butt[count] = 7;
          if (butt[count] != seq[count]) com = false;
          count++;
          waitForRelease(left);
          startTime = millis();
        } else if (digitalRead(right)) {
          butt[count] = 8;
          if (butt[count] != seq[count]) com = false;
          count++;
          waitForRelease(right);
          startTime = millis();
        } else if (digitalRead(up)) {
          butt[count] = 9;
          if (butt[count] != seq[count]) com = false;
          count++;
          waitForRelease(up);
          startTime = millis();
        } else if (digitalRead(down)) {
          butt[count] = 10;
          if (butt[count] != seq[count]) com = false;
          count++;
          waitForRelease(down);
          startTime = millis();
        }
      }

      Serial.print("Level ");
      Serial.print(difficulty);
      Serial.println(" result:");
      for (int i = 0; i < 6; i++) Serial.println(seq[i]);
      for (int i = 0; i < count; i++) Serial.println(butt[i]);

      if (com && count == 6) {
        Serial.println("correct");
        next = true;
        difficulty++;
        delay(1000);
      } else if (!com) {
        Serial.println("wrong!!");
      }
    }
  }
}
