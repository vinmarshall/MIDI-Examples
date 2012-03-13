/*
 * MIDI Example Code - Control Change
 * Version 1.0
 *
 * This code will send Control Change (or PitchBend, or 
 * Aftertouch, etc...) messages based on the position of the 
 * potentiometer every time it's position changes.  This is just 
 * a simple demo designed to get you up and running with MIDI.  
 * The hardware setup for this demo code is edocumented in the 
 * github repository.
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

#define INTERVAL 50   // Timer interval
#define THRESHOLD 5   // Hysterisis threshold
#define CONTROLLER 11 // Choose a Controller ID - 
                      // http://www.somascape.org/midi/tech/spec.html#ctrlnums
#define CHANNEL 1     // MIDI Channel

SparkSoftLCD lcd = SparkSoftLCD(LCD_PIN); // Serial LCD
unsigned long intervalTimer;  // mark interval time
int pot;                      // Potentiometer reading
int lastPot;                  // Previous potentiometer reading
int value;                    // Control value

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
}

void loop() {

  /*
   * Execute once every timer interval
   */

  if (millis() - intervalTimer > INTERVAL) {

    /*
     * If the potentiometer has been changed by more than 
     * the threshold, send a MIDI message.
     */

    pot = analogRead(POT_PIN);  // Read the pot value 0-1024
    if (abs(lastPot - pot) > THRESHOLD) {
      value = pot / 8;          // Map to control value 0-127
      lcd.clear();              // Display what we're doing
      lcd.print("Controller: ");  
      lcd.print(CONTROLLER);
      lcd.cursorTo(2,1);
      lcd.print("Value: ");         
      lcd.print(value);

      // Send the MIDI Control Change Message
      MIDI.sendControlChange(CONTROLLER, value, CHANNEL);

      // OR - Send the MIDI pitch bend message
      // define value above as: unsigned int value
      // value = pot * 16;  // Map to pitch bend value 0-16383
      // MIDI.sendPitchBend(pitch, 1);

      /* Sending the same message back to back with the MIDI library (e.g. 
       * PitchBend, PitchBend, PitchBend, etc...) seems to generate invalid
       * MIDI messages after the first one.  This kludge intersperses a call
       * to the send method after each sendPitchBend message, which seems to
       * fix things.  Because it's an InvalidType, nothing actually gets sent
       * to the MIDI OUT.
       */
      MIDI.send(InvalidType, 0, 0, 0); 

      lastPot = pot;
    }
    intervalTimer = millis();   // reset timer for next interval
  }

}
