-- https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en

print('Start')

wifi.setmode(wifi.STATION)
wifi.sta.config ( "YOURSSID" , "YOURPASS" )

status=(wifi.sta.status())
print(status)
out=4 						-- GPIO4
gpio.mode(out, gpio.OUTPUT)


dofile("server.lua")



