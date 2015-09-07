-- Autor: Markus Hahnenkamm
-- Zur privaten, nicht kommeziellen Nutzung freigegeben.


--Laden der DS18B20 und MQTT(WIFI) Libs
dslib=require("solaranlage_ds18b20")
mqttlib=require("solaranlage_mqtt")

--Topics für MQTT
MQTTTopic = "/openHAB/Solaranlage"
MQTTTopicAn = MQTTTopic .. "/An"
MQTTTopicHigh = MQTTTopic .. "/High"
MQTTTopicLow = MQTTTopic .. "/Low"

--OW Pin für DS18B20
pin = 4
addrHigh = string.char(40,2,169,170,3,0,0,230)
addrLow = string.char(0x28,0x9E,0x81,0xAA,3,0,0,0xEC)
--OW am Pin Initialisieren
dslib.init(pin)

--Durchwechseln in der Interruptschleife
count=0
--MQTT mit WIfi initialisieren
--Funktion übergeben, welche bei erfolgreicher Verbindung zum Broker aufgerufen wird
mqttlib.init(function(con)
	--alle 2,5ms einen Topic publishen, da ansonsten bei aufeinanderfolgenden Publishes ein Systemfehler auftritt
    tmr.alarm(0, 2500, 1, function()
	
		--Gerät noch an
		if(count ==0) then  
			print("MQTT publish An \"1\"")
            mqttClient:publish( MQTTTopicAn, "1", 0, 1 )
			
		--Beide Temperaturen erfassen und TempHigh Publishen
		elseif (count ==1)  then   
            tempHigh = dslib.readTemperature(pin,addrHigh,1)
            tempLow = dslib.readTemperature(pin,addrLow,1)
            print(string.format("MQTT publish TempHigh %d",tempHigh))
            mqttClient:publish( MQTTTopicHigh, string.format("%d",tempHigh),0, 1 )
        
		--TempLow Publishen
		elseif (count==2) then
            print(string.format("MQTT publish TempLow %d",tempLow))
            mqttClient:publish( MQTTTopicLow, string.format("%d",tempLow),0, 1 )
			--Rücksetzen der Variable
            count = -1
		end
		
		--Inkrementieren der Zählvariable
		count = count + 1
    end)
end)