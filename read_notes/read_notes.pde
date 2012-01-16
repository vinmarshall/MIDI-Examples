/*
 * MIDI Example Code - Reading Incoming Notes
 * Version 1.0
 *
 * This code will read Note On and Note Off messages on Channel 1
 * arriving at the MIDI IN port.  This is just a simple demo designed 
 * to get you up and running with MIDI.  The hardware setup for this
 * demo code is documented in the github repository.
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

#define LCD_PIN 4     // Serial LCD RX line
#define CHANNEL 1     // MIDI Channel

SparkSoftLCD lcd = SparkSoftLCD(LCD_PIN);

void setup() {
  // Serial LCD Setup
  pinMode(LCD_PIN, OUTPUT);
  lcd.begin(9600);
  lcd.clear();
  lcd.cursor(0);  // hide cursor
  lcd.print("Waiting...");

  // MIDI Setup
  MIDI.begin(CHANNEL);
}

void loop() {
  if (MIDI.read(CHANNEL)) {   // Channel arg is optional
    switch(MIDI.getType()) {
      case NoteOn:
        {
          int note = MIDI.getData1();
          int velocity = MIDI.getData2();
          lcd.clear();
          lcd.cursorTo(1,1);
          lcd.print("Note On: ");
          lcd.print(note);
          lcd.cursorTo(2,1);
          lcd.print("Velocity: ");
          lcd.print(velocity);
          break;
        }
      case NoteOff:
        {
          int note = MIDI.getData1();
          int velocity = MIDI.getData2();
          lcd.clear();
          lcd.cursorTo(1,1);
          lcd.print("Note Off: ");
          lcd.print(note);
          lcd.cursorTo(2,1);
          lcd.print("Velocity: ");
          lcd.print(velocity);
          break;
        }
    }

    // We need this so that the MIDI OUT will parrot the data on MIDI IN
    // without errors.  See the comment about this in the Control Change
    // demo code.
    MIDI.send(InvalidType, 0, 0, 0);
  }

}


