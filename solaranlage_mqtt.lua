-- Autor: Markus Hahnenkamm
-- Zur privaten, nicht kommeziellen Nutzung freigegeben.

--Modulname, mit welchem Funktionen angehängt werden
local SolarMQTT = {}

--Initialisierung des MQTT Moduls mit WIFI
--@onConnectFunc: Funktion welche nach erfolgreicher Verbindung zum Broker aufgerufen wird
function SolarMQTT.init(onConnectFunc)

    --WIFI Verbindung aufbauen
    wifi.setmode(wifi.STATION)
    wifi.sta.config("SSID","Passwort")                              
    wifi.sta.connect()
	
	--Im 1 Sekunden Takt auf erhaltene IP-Adresse prüfen
    tmr.alarm(1, 1000, 1, function() 
	
        if wifi.sta.getip()== nil then 
            print("Warte auf IP-Adresse ...") 
			
        else 
            tmr.stop(1)
            print("IP Adresse erhalten: "..wifi.sta.getip())
			
			--Verbindung zum MQTT Broker herstellen
            mqttClient = mqtt.Client("Solaranlage", 5, "", "")
			--Last Will Testament: MQTTTopicAn wird auf 0 gesetzt
            mqttClient:lwt(MQTTTopicAn, "0", 0, 0)
			--Bei Verbindung wird die übergebene Funktion ausgeführt
            mqttClient:on("connect", onConnectFunc )
			--Bei Verbindungsverlust wird eine Fehlernachricht ausgegeben und der Prozessor neu gestartet
            mqttClient:on("offline", function(con) print ("offline - restarting") node.restart() end)

			brokerIP = "192.168.178.20"
            print("Verbindungsaufbau zum Broker " .. brokerIP)
            mqttClient:connect( brokerIP, 1883, 0)
        end 
		
    end )
    
end

return SolarMQTT
