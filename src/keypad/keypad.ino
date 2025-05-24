#include <Keyboard.h>

const uint8_t BUTTON_PINS[] = {9, 8, 7, 6};
const char KEYS[] = {'z', 'x', 'c', 'v'};
const uint8_t NUM_BUTTONS = 4;

const unsigned long DEBOUNCE_DELAY = 50;
unsigned long lastDebounceTime = 0;

bool currentState[NUM_BUTTONS];
bool lastState[NUM_BUTTONS];
bool stableState[NUM_BUTTONS];

void setup() {
  for(uint8_t i = 0; i < NUM_BUTTONS; i++) {
    pinMode(BUTTON_PINS[i], INPUT_PULLUP);
    currentState[i] = digitalRead(BUTTON_PINS[i]);
    lastState[i] = currentState[i];
    stableState[i] = currentState[i];
  }

  Keyboard.begin();
}

void loop() {
  bool stateChanged = false;

  for(uint8_t i = 0; i < NUM_BUTTONS; i++) {
    currentState[i] = digitalRead(BUTTON_PINS[i]);

    if(currentState[i] != lastState[i]) {
      stateChanged = true;
      lastDebounceTime = millis();
    }
    lastState[i] = currentState[i];
  }

  if((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
    for(uint8_t i = 0; i < NUM_BUTTONS; i++) {
      if(currentState[i] != stableState[i]) {
        stableState[i] = currentState[i];

        if(stableState[i] == LOW) {
          Keyboard.press(KEYS[i]);
        } else {
          Keyboard.release(KEYS[i]);
        }
      }
    }
  }

  checkCombo();
}

void checkCombo() {
  static bool comboActive = false;
  bool allPressed = true;

  for(uint8_t i = 0; i < NUM_BUTTONS; i++) {
    if(stableState[i] != LOW) {
      allPressed = false;
      break;
    }
  }

  if(allPressed && !comboActive) {
    comboActive = true;
    Keyboard.write(' ');
  }
  else if(!allPressed) {
    comboActive = false;
  }
}
