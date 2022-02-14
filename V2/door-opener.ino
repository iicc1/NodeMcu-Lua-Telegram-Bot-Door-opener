#include "WiFi.h"
const char* ssid = "xxxxxx";
const char* password =  "xxxxx";

#include <WiFiClientSecure.h>
#include <UniversalTelegramBot.h> // https://github.com/witnessmenow/Universal-Arduino-Telegram-Bot
#include <ArduinoJson.h>
#define BOT_TOKEN "xxxxxxxx"
const unsigned long BOT_MTBS = 1000; // mean time between scan messages

WiFiClientSecure secured_client;
UniversalTelegramBot bot(BOT_TOKEN, secured_client);
unsigned long bot_lasttime; // last time messages' scan has been done

// Admin users
String admins[] = {"1111111", "22222222", "3333333", "444444444"};

// Digital pin that will trigger the relay
const int door_pin = 4; // GPIO4

void setup() {
  Serial.begin(115200);

  pinMode(door_pin, OUTPUT);    // Sets the digital pin as output
  digitalWrite(door_pin, LOW);  // Sets the digital pin off
  
  WiFi.begin(ssid, password);
  secured_client.setCACert(TELEGRAM_CERTIFICATE_ROOT); // Add root certificate for api.telegram.org
  // Wait until it connects to the WiFi
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to the WiFi network");
  Serial.println(WiFi.localIP());

  // The exact time is needed to perform the HTTPS requests
  Serial.print("Retrieving time: ");
  configTime(0, 0, "pool.ntp.org"); // Get UTC time via NTP
  time_t now = time(nullptr);
  while (now < 24 * 3600) {
    Serial.print(".");
    delay(100);
    now = time(nullptr);
  }
  Serial.println(now);
}

// Fetch new Telegram messages
void loop() {
  if (millis() - bot_lasttime > BOT_MTBS) {

    int numNewMessages = bot.getUpdates(bot.last_message_received + 1);

    while (numNewMessages){
      Serial.println("Message received");
      handleNewMessages(numNewMessages);
      numNewMessages = bot.getUpdates(bot.last_message_received + 1);
    }

    bot_lasttime = millis();
  }
}

// Process detected Telegram messages
void handleNewMessages(int numNewMessages) {
  for (int i = 0; i < numNewMessages; i++) {

    // Event triggered by an inline keyboard
    if (bot.messages[i].type == "callback_query" && bot.messages[i].text == "open door") {

      // If the user is admin, allow the bot usage
      if (isAdmin(bot.messages[i].from_id)) {
        bot.sendMessage(bot.messages[i].from_id, "Opening the door...", "");
        openDoor();
        bot.sendMessage(bot.messages[i].from_id, "Done!", "");
      }

    // Start command
    } else if (bot.messages[i].type == "message" && bot.messages[i].text == "/start") {

      // If the user is admin, allow the bot usage
      if (isAdmin(bot.messages[i].from_id)) {
        String keyboardJson = "[[{ \"text\" : \"Press to open the door\", \"callback_data\" : \"open door\" }]]";
        bot.sendMessageWithInlineKeyboard(bot.messages[i].from_id, "🛎 *Remote door opener*", "Markdown", keyboardJson);
      }      
    }
  }
}

// Check if the user is admin
boolean isAdmin(String user_id) {
  bool isAdmin = false;
  for (int j = 0; j < sizeof(admins)/sizeof(int); j++) {
    if (admins[j] == user_id) {
      return true;
    }
  }
  return false;
}

// Send a signal to open the electric door
void openDoor() {
  Serial.println("Opening door...");
  digitalWrite(door_pin, HIGH); // Sets the digital pin on
  delay(3000);
  digitalWrite(door_pin, LOW);  // Sets the digital pin off
  Serial.println("Done!");
}
