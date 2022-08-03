// 測定しながらMstickCの画面下を押したら，においを照射するプログラム


#include <M5StickC.h>
#include "MAX30100_PulseOximeter.h"
#include "xbm.h"

int SMELLPIN = 26;
int outputOdor;
char serial_data;


PulseOximeter pox;
uint8_t Heart_rate = 0;
uint8_t Spo2 = 0;

void setup()
{
  M5.begin();
  M5.Lcd.setRotation(0);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setCursor(0, 0);
  M5.Lcd.setTextSize(2);

  Serial.begin(9600);

  if (!pox.begin())
  {
    M5.Lcd.println("FAILED");
    for (;;)
      ;
  }
  else
  {
    M5.Lcd.println("SUCCESS");
  }

  pinMode(SMELLPIN, OUTPUT);
  outputOdor = LOW;

  delay(10);
}

void loop()
{
  M5.update(); // 本体のボタン状態更新
  pox.update(); // update pulse oximeter

  Heart_rate = (int)pox.getHeartRate();
  Spo2 = pox.getSpO2();

  if (M5.BtnA.wasPressed())
  {
    if (outputOdor == HIGH) outputOdor = LOW;
    else     outputOdor = HIGH;
  }




  digitalWrite(SMELLPIN, outputOdor);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setCursor(0, 0);
  M5.Lcd.setTextSize(1); M5.Lcd.setTextColor(GREEN);
  M5.Lcd.printf("Odor\n");
  M5.Lcd.setTextSize(3); M5.Lcd.setTextColor(WHITE);
  if (outputOdor == HIGH) M5.Lcd.printf("ON\n");
  else M5.Lcd.printf("OFF\n");

  M5.Lcd.setTextSize(1); M5.Lcd.setTextColor(GREEN);
  M5.Lcd.print("HR:   ");
  M5.Lcd.setTextSize(3); M5.Lcd.setTextColor(WHITE);
  M5.Lcd.println(Heart_rate);

  M5.Lcd.setTextSize(1); M5.Lcd.setTextColor(GREEN);
  M5.Lcd.print("SPO2: ");
  M5.Lcd.setTextSize(3); M5.Lcd.setTextColor(WHITE);
  M5.Lcd.println(Spo2);

  if (Serial.available() > 0) {
    serial_data = Serial.read();
    if (serial_data == '1') {
      outputOdor = HIGH;
    }
    if (serial_data == '0') {
      outputOdor = LOW;
    }
  }
  else {
    serial_data = 'N';
  }
  M5.Lcd.setTextSize(1); M5.Lcd.setTextColor(GREEN);
  M5.Lcd.printf("Serial Read\n");
  M5.Lcd.setTextSize(3); M5.Lcd.setTextColor(WHITE);
  M5.Lcd.println(serial_data);



  delay(100);
}
