#include <Arduino.h>

void setup()
{
    Serial.begin(9600);
    while (!Serial) delay(1);
    Serial.println("Resetter " __DATE__ " " __TIME__);

    digitalWrite(12, HIGH);
    pinMode(12, OUTPUT);
    digitalWrite(12, LOW);
    pinMode(13, OUTPUT);
}

void loop()
{
    if (Serial.available() && Serial.read() == 'r')
    {
        Serial.println("Resetting");
        digitalWrite(12, LOW);
        digitalWrite(13, HIGH);
        delay(500);
        digitalWrite(12, HIGH);
        digitalWrite(13, LOW);
    }

    delay(10);
}
