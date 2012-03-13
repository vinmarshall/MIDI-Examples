/*
 * MIDI Example Code - Playing notes
 * Version 1.0
 *
 * This code will send Note On and Note Off messages on Channel 1
 * based on the position of the potentiometer when the button is
 * pressed.  This is just a simple demo designed to get you up and 
 * running with MIDI.  The hardware setup for this demo code is 
 * documented in the github repository.
 *
 * Check the repository for the most recent version of this code:
 * https://github.com/vinmarshall/MIDI-Examples
 *
 * Copyright (c) 2012 Vin Marshall (vlm@2552.com, www.2552.com)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.  
 */

#include <SparkSoftLCD.h>   // download from http://openmoco.org/node/153
#include <MIDI.h> // download from http://sourceforge.net/projects/arduinomidilib

#define BUTTON_PIN 2  // Pushbutton (MIDI Shield button D2)
#define LCD_PIN 5     // Serial LCD RX line
#define POT_PIN A0    // Potentiometer wiper (MIDI Shield knob A0)
#define CHANNEL 1     // MIDI Channel

SparkSoftLCD lcd = SparkSoftLCD(LCD_PIN); // Serial LCD
bool btnPressed;      // is button depressed?
bool lastBtnState;    // button debounce vars
unsigned long debounceTime;               // Used for debouncing
unsigned long debounceInterval = 50;      // switch debouncing time
bool notePlayed = false;  // flag set after button press and note is played
int note;             // note to be played

void setup() {
  // Serial LCD Setup
  pinMode(LCD_PIN, OUTPUT);
  delay(500);
  lcd.begin(9600);
  lcd.clear();
  lcd.cursor(0);  // hide cursor
  lcd.print("Waiting...");

  // MIDI Setup
  MIDI.begin(CHANNEL);

  // Other I/O Setup
  pinMode(BUTTON_PIN, INPUT);
  digitalWrite(BUTTON_PIN, HIGH);
}

void loop() {

  /*
   * Read Pushbutton State and debounce
   * Look at the Arduino switch debouncing tutorial for more information
   * http://arduino.cc/it/Tutorial/Debounce
   */

  // Read button state and mark time if it's changed
  bool btnReading = ! digitalRead(BUTTON_PIN);  // negate - button pulls low
  if (btnReading != lastBtnState) {
    debounceTime = millis();
  }

  // If the button has been in the same state for a suitable amount 
  // of time, then it has stabalized and we can use the reading
  if ((millis() - debounceTime) > debounceInterval) {
    btnPressed = btnReading;
  }

  lastBtnState = btnReading;  // Get ready for next pass through

  /*
   * If the button has just been pressed, play one note.  Read the 
   * analog value of the potentiometer to determine which note.
   * Then set a flag so we won't play another note until the next time
   * the button is pressed.
   */

  if (btnPressed && !notePlayed) {
    int potValue = analogRead(POT_PIN); // Read the pot value 0-1024
    note = potValue / 8;  // Map pot reading to a note 0-127
    lcd.clear();
    lcd.print("Note On: ");
    lcd.print(note);
    // Play the MIDI note.  Consider expanding this by adding another
    // potentiometer for attack / release velocity.
    MIDI.sendNoteOn(note, 64, CHANNEL);
    notePlayed = true;
  }

  /*
   * After the button is released, stop playing the note and reset the  
   * notePlayed flag so that we'll play another note after the next 
   * button press.
   */

  if (!btnPressed && notePlayed) {
    lcd.clear();
    lcd.print("Note Off: ");
    lcd.print(note);
    // Send the Note Off message to stop playing the note. 
    MIDI.sendNoteOff(note, 0, CHANNEL);
    notePlayed = false;
  }
}
