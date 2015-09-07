-- Autor: Markus Hahnenkamm
-- Zur privaten, nicht kommeziellen Nutzung freigegeben.

--Modulname, mit welchem Funktionen angehängt werden
local SolarDS18B20 = {}

--Einrichten des Pins
function SolarDS18B20.init(pin)
    ow.setup(pin)
end

--Liest die Temperatur eines Sensors eines
--@pin Einzulesender Pin
--@address Adresse des Sensors
--@power Power-Modus für den Pin
function SolarDS18B20.readTemperature(pin,address,power)

    if (address == nil) then
      print("No address")
      return nil
    end

    -- Keine CRC Prüfung der Adresse

    --DS18B20
    if ((address:byte(1) == 0x10) or (address:byte(1) == 0x28)) then

        --Temperaturwandlung anstoßen    
        ow.reset(pin)               --Bus Initialisieren
        ow.select(pin, address)     --Chip auswählen
        ow.write(pin, 0x44, power)  --Trigger Conversion Kommando

        --Abwarten auf Wandlungsfertigstellung
        timer.delay(750000)         --750ms Conversion Time  - Besser auf Wandlungsfertigstellung abfragen

        --Ergebnis einlesen
        ow.reset(pin)               --Bus Initialisieren
        ow.select(pin, address)     --Chip auswählen
        ow.write(pin,0xBE,1)        --Read Scratchpad Kommando
		
        --Einlesen
        data = nil
        data = string.char(ow.read(pin))
        for i = 1, 8 do
            data = data .. string.char(ow.read(pin))
        end

		--CRC Prüfung der empfangenen Daten
        crc = ow.crc8(string.sub(data,1,8)) 
        if(crc ~= data:byte(9)) then
            print("CRC Failed")
            print(data:byte(1,9))                
            print("CRC="..crc)
            return nil
        end
        
        t = (data:byte(1) + data:byte(2) * 256) * 625

        return t
        
    else
        print("Geraetefamilie unbekannt")
        return nil
    end
end

return SolarDS18B20
