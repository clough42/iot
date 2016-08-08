/**
 * Solar-powered weather sensor
 *
 * Uses Homie-ESP8266 framework to connect to the network and MQTT, read a
 * DHT sensor, report data and then deep sleep until the next reading.
 */

#include "Arduino.h"
#include <ESP8266WiFi.h>
#include <DHT.h>
#include <Homie.h>

#define VOLTAGE_PIN A0
#define DHT_PIN D4
#define DHT_TYPE DHT22
#define DEEP_SLEEP_SECONDS 300

HomieNode tempCNode("tempC", "celsius");
HomieNode tempFNode("tempF", "fahrenheit");
HomieNode humidityNode("humidity", "humidity");
HomieNode batteryNode("battery", "voltage");

DHT dht(DHT_PIN, DHT_TYPE);
bool tempReported = false;

/**
 * Report the batter voltage.
 */
void reportVoltage()
{
    int voltageCount = analogRead(VOLTAGE_PIN);
    float voltage = 0.0055 * voltageCount;
    Homie.setNodeProperty(batteryNode, "voltage", String(voltage));
}

/**
 * Read the DHT sensor and report the data.  Keep trying on subsequent calls
 * until we successfully report.
 */
void reportSensorData()
{
  if( !tempReported ) {
    Serial.println("Attempting to read temperature");

    float tempC = dht.readTemperature();
    float tempF = dht.readTemperature(true);
    float humidity = dht.readHumidity();

    if( ! isnan(tempC) && ! isnan(tempF) && ! isnan(humidity) ) {
      Homie.setNodeProperty(tempCNode, "tempC", String(tempC));
      Homie.setNodeProperty(tempFNode, "tempF", String(tempF));
      Homie.setNodeProperty(humidityNode, "humidity", String(humidity));
      tempReported = true;

      // disconnect MQTT, which will trigger deep sleep when complete
      Serial.println("Temp reported successfully; disconnecting");
      Homie.disconnectMqtt();
    }
  }
}

/**
 * Called once when Homie is connected and ready.
 */
void setupHandler()
{
  dht.begin();
  reportVoltage();
}

/**
 * Looped when homie is connected and ready.
 */
void loopHandler()
{
  reportSensorData();
}

/**
 * Called when Homie transitions between states
 */
void eventHandler(HomieEvent event) {
  switch(event) {
    case HOMIE_MQTT_DISCONNECTED:
      ESP.deepSleep(DEEP_SLEEP_SECONDS * 1000000);
      delay(100); // allow deep sleep to occur
      break;
  }
}

void setup()
{
  Serial.begin(115200);

  Homie_setFirmware("solar-weather", "1.0.0");
  Homie_setBrand("clough42");

  Homie.disableResetTrigger();
  Homie.setSetupFunction(setupHandler);
  Homie.setLoopFunction(loopHandler);
  Homie.onEvent(eventHandler);
  Homie.setup();
}

void loop()
{
  Homie.loop();
}
