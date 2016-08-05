/**
 * 
 */
#include "Arduino.h"
#include <ESP8266WiFi.h>
#include <DHT.h>
#include <Homie.h>

#define VOLTAGE_PIN A0
#define DHT_PIN D4
#define DHT_TYPE DHT22
#define TEMPERATURE_INTERVAL_SECONDS 10

HomieNode temperatureNode("temperature", "temperature");
HomieNode humidityNode("humidity", "humidity");
HomieNode batteryNode("battery", "voltage");

DHT dht(DHT_PIN, DHT_TYPE);
unsigned long lastTempTime = millis();

void reportVoltage()
{
    int voltageCount = analogRead(VOLTAGE_PIN);
    float voltage = 0.0055 * voltageCount;
    Homie.setNodeProperty(batteryNode, "voltage", String(voltage));
}

void reportSensorData()
{
  if( millis() - lastTempTime >= TEMPERATURE_INTERVAL_SECONDS * 1000UL ) {
    float temp = dht.readTemperature();
    float humidity = dht.readHumidity();

    if( ! isnan(temp) && ! isnan(humidity) ) {
      Homie.setNodeProperty(temperatureNode, "temperature", String(temp));
      Homie.setNodeProperty(humidityNode, "humidity", String(humidity));
      lastTempTime = millis();
    }
  }
}

void setupHandler()
{
  dht.begin();
  reportVoltage();
}

void loopHandler()
{
  reportSensorData();
}

void setup()
{
  Serial.begin(115200);

  Homie_setFirmware("solar-weather", "1.0.0");
  Homie_setBrand("clough42");

  Homie.setSetupFunction(setupHandler);
  Homie.setLoopFunction(loopHandler);
  Homie.setup();
}

void loop()
{
  Homie.loop();
}
