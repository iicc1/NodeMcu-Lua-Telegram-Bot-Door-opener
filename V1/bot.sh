#!/bin/bash
# By iicc | https://github.com/iicc1 | t.me/iicc1
# ----------------------------------------------- #
URL="https://api.telegram.org/bot$(cat token)"
NODE='http://192.168.xxx.xxx/?doorbell=50000'    # Place here the local ip of the nodemcu web server
URL_MSG=$URL'/sendMessage'
URL_EDI=$URL'/editMessageText'
URL_ACT=$URL'/sendChatAction'
inline_keyboard=''
UPD_URL=$URL'/getUpdates?offset='
OFFSET=0
ALLOWED='["message", "callback_query"]'
ADMIN=$(cat admin)
VECES=$(cat times)
P=$(cat dotIcon)

if [ ! -f "users" ]; then
  touch users
fi


send() {
	res=$(curl -s "$URL_MSG" -d "chat_id=$1" -d "text=$2" -d "parse_mode=markdown" -d "reply_markup=$inline_keyboard")
}

edit() {
	res=$(curl -s "$URL_EDI" -d "chat_id=$1" -d "message_id=$2" -d "text=$3" -d "parse_mode=markdown" -d "reply_markup=$inline_keyboard")
}

send_action() {
	res=$(curl -s "$ACTION_URL" -F "chat_id=$1" -F "action=$2")
}

process_ring() {
	MESSAGE=$(grep -o '\["result",0,"message","text"\].*' update | cut -d'"' -f8)
	MESSAGE_ID=$(grep -o '\["result",0,"message","message_id"\].*' update | cut -d' ' -f2)
	CHAT_ID=$(grep -o '\["result",0,"message","chat","id"\].*' update | cut -d']' -f2 | tr -d "\t")
	USER_NAME=$(grep -o '"message","from","first_name".*' update | cut -d'"' -f8)	
	LEN=${#CHAT_ID}
	
	if [ "$LEN" == "0" ]; then
		echo $(($(cat times)+1)) > times
		CHAT_ID=$(grep -o '\["result",0,"callback_query","from","id"\].*' update | cut -d']' -f2 | tr -d "\t")
		MESSAGE_ID=$(grep -o '\["result",0,"callback_query","message","message_id"\].*' update | cut -d']' -f2 | tr -d "\t")
		CALLBACK='1'
	else 
		CALLBACK='0'
	fi
	
	echo $ADMIN | grep $CHAT_ID > /dev/null
	if [ $? == 1 ]; then
		send "$CHAT_ID" "$USER_NAME, eres un *usuario no autorizado*"	
		exit
	else
		VECES=$(cat times)
		if [ "$CALLBACK" == "1" ]; then	
			curl -s "$NODE"&
			edit "$CHAT_ID" "$MESSAGE_ID" "_Abriendo puerta_"
	
			edit "$CHAT_ID" "$MESSAGE_ID" "_Abriendo puerta ._"
			
			edit "$CHAT_ID" "$MESSAGE_ID" "_Abriendo puerta .._"
		
			edit "$CHAT_ID" "$MESSAGE_ID" "_Abriendo puerta ..._"
		
			edit "$CHAT_ID" "$MESSAGE_ID" "*Puerta abierta!!*"
			sleep 0.5
			inline_keyboard='{"inline_keyboard":[[{"text":"Presiona para abrir la puerta","callback_data":"botonPulsado"}]]}'
			edit "$CHAT_ID" "$MESSAGE_ID" "*Apertura de puerta automática*
		
$P Usuario autorizado: _SÍ_
$P Veces abierta la puerta: $VECES
$P [Haz click aquí]($NODE) para abir desde el navegador."
		else
			if [ "$MESSAGE" != "/start" ]; then
				exit
			fi
			
			grep $CHAT_ID users > /dev/null
			if [ $? == 1 ]; then
				echo $CHAT_ID >> users
				send "$CHAT_ID" "*Bienvenido* $USER_NAME al bot de apertura de puerta."
			fi
			inline_keyboard='{"inline_keyboard":[[{"text":"Presiona para abrir la puerta","callback_data":"botonPulsado"}]]}'
			send "$CHAT_ID" "*Apertura de puerta automática*
		
$P Usuario autorizado: _SÍ_
$P Veces abierta la puerta: $VECES
$P [Haz click aquí]($NODE) para abir desde el navegador."
		fi	
	fi
}


while true
do 
	UPDATE=$(curl -s "${UPD_URL}${OFFSET}" -d "limit=10" -d "allowed_updates=$ALLOWED" | ./JSON.sh/JSON.sh -s)
	OFFSET=$(echo "$UPDATE" | egrep '\["result",0,"update_id"\]' | cut -f 2)
	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		echo "$UPDATE" > update
		process_ring&
	fi
done
