#include <Arduino.h>

#define VERT_PIN 39
#define HORZ_PIN 36
#define SEL_PIN 17

#define LED_RED_PIN 27
#define LED_BLUE_PIN 12
#define LED_YELLOW_PIN 14
#define LED_GREEN_PIN 13

bool isLedVermelho = false;
bool isLedAzul = false;
bool isLedAmarelo = false;
bool isLedVerde = false;

bool isPress = true;

String input = "";

void setup()
{
    Serial.begin(115200);
    pinMode(VERT_PIN, INPUT);
    pinMode(HORZ_PIN, INPUT);
    pinMode(SEL_PIN, INPUT_PULLUP);

    pinMode(LED_RED_PIN, OUTPUT);
    pinMode(LED_BLUE_PIN, OUTPUT);
    pinMode(LED_YELLOW_PIN, OUTPUT);
    pinMode(LED_GREEN_PIN, OUTPUT);

    randomSeed(analogRead(0));
    delay(3000);
}

void loop()
{

    while (Serial.available())
    {
        char carac = (char)Serial.read();
        if (carac != '\n')
        {
            input += carac;
        }
        else
        {
            int dly = 150;

            if (input == "END")
            {
                gameOver();
            }
            else if (input == "LED 0")
            {
                piscaLed(LED_RED_PIN, dly);
            }
            else if (input == "LED 1")
            {
                piscaLed(LED_BLUE_PIN, dly);
            }
            else if (input == "LED 2")
            {
                piscaLed(LED_YELLOW_PIN, dly);
            }
            else if (input == "LED 3")
            {
                piscaLed(LED_GREEN_PIN, dly);
            }
            else
            {
                digitalWrite(LED_RED_PIN, LOW);
                digitalWrite(LED_BLUE_PIN, LOW);
                digitalWrite(LED_YELLOW_PIN, LOW);
                digitalWrite(LED_GREEN_PIN, LOW);
            }

            input = "";
        }
    }

    int horizontal = analogRead(HORZ_PIN);
    int vertical = analogRead(VERT_PIN);
    bool selPressed = digitalRead(SEL_PIN) == HIGH;

    // Botão
    if (selPressed == 1)
    {
        if (isPress)
        {
            Serial.write("btnStart\n");
        }
        isPress = false;
    }
    else
    {
        isPress = true;
    }

    // Amarelo
    if (vertical < 1900)
    {
        isLedAmarelo = false;
    }
    else if (vertical > 2050)
    {
        if (!isLedAmarelo)
        {
            isLedAmarelo = true;
            Serial.write("ledAmarelo\n");
        }
    }

    // Verde
    if (horizontal < 1900)
    {
        isLedVerde = false;
    }
    else if (horizontal > 2050)
    {
        if (!isLedVerde)
        {
            isLedVerde = true;
            Serial.write("ledVerde\n");
        }
    }

    // Vermelho
    if (vertical > 1800)
    {
        isLedVermelho = false;
    }
    else if (vertical < 1650)
    {
        if (!isLedVermelho)
        {
            isLedVermelho = true;
            Serial.write("ledVermelho\n");
        }
    }

    // Azul
    if (horizontal > 1800)
    {
        isLedAzul = false;
    }
    else if (horizontal < 1650)
    {
        if (!isLedAzul)
        {
            isLedAzul = true;
            Serial.write("ledAzul\n");
        }
    }

    delay(5);
}

void piscaLed(int led, int dly)
{
    digitalWrite(led, HIGH);
    delay(dly);
    digitalWrite(led, LOW);
    delay(dly);
}

void gameOver()
{
    digitalWrite(LED_RED_PIN, HIGH);
    digitalWrite(LED_BLUE_PIN, HIGH);
    digitalWrite(LED_YELLOW_PIN, HIGH);
    digitalWrite(LED_GREEN_PIN, HIGH);

    delay(1000);

    digitalWrite(LED_RED_PIN, LOW);
    digitalWrite(LED_BLUE_PIN, LOW);
    digitalWrite(LED_YELLOW_PIN, LOW);
    digitalWrite(LED_GREEN_PIN, LOW);

    int dly = 75;
    for (int i = 0; i < 4; i++)
    {
        piscaLed(LED_RED_PIN, dly);
        piscaLed(LED_YELLOW_PIN, dly);
        piscaLed(LED_BLUE_PIN, dly);
        piscaLed(LED_GREEN_PIN, dly);
    }
}
