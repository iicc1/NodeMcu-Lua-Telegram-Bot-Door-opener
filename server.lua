-- Server.lua
print("server.lua opened")

function opendoor()
 gpio.write(out,gpio.HIGH)
 print("Door opened!")
 tmr.delay(seconds*100)
 gpio.write(out,gpio.LOW)
 print("Closing door..")
end

server=net.createServer(net.TCP, 30)
tmr.delay(10000)

server:listen(80,function(c)
------------------------------

c:on("receive", function(c, pl) -- pl is the data of the client. In the first line we found the method and text after ip.
print("Data of the client")
print(pl)
print("Data of the client")
open=string.sub(pl,7,14) -- we take a part from the data
seconds=string.match(pl,"%d+") -- the seconds set in link
print("2--------------")
print(open)
print(seconds)
print("2--------------")


if open=="doorbell" then
 print("order received!")
 opendoor()
end

c:send('HTTP/1.1 200 OK\n\n')
c:send('<!DOCTYPE HTML>\n')
c:send('<html>\n')
c:send('<head><meta  content="text/html; charset=utf-8">\n')
c:send('<title>Doorbell</title></head>\n')
c:send('<body><h1>Doorbell remote opener</h1>\n')
c:send('<h3>AZUCAQUE</h3>\n')
c:send('<form action="" method="GET">\n') 
c:send('<fieldset>\n')
c:send('<input type="radio" name="doorbell" value="50000"/>Open door<br />\n')
c:send('<input type="submit" value="Send"/>\n')
c:send('</fieldset>\n')     
c:send('</form>\n')     
c:send('</body></html>\n')
c:on("sent",function(c) c:close() end)          
end)        
end)

