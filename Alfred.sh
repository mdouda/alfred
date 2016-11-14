channel="#channel" 		### Canal donde vive el bot
directory="./irc" 		### ./irc
domain="freejolitos.com"	### e.g. freejolitos.com
serv="$directory/SERVERNAME" 	### Variable para alojar el directorio por servidor
chat="$serv/$channel/in" 	### File handle a donde escribe el bot
password="123456" 		### Pass del robot y de ident. con NickServ
port="6667" 			### Puerto de conexion al servidor

ii -i $directory -s $domain -p $port -n Alfred -k $password -f Alfred &

echo "/j NickServ identify $password" > $serv/in
sleep 1
echo "/j $channel" > $serv/in
sleep 2

tail -fn0 $serv/$channel/out | \
while read line
do
	echo "$line" | grep "has joined"
  if [ $? = 0 ]
	then
		recados=$(ls recados)
		usuario=$(echo $line | awk -F '[(@]' '{print $2}')
		echo "Hola, $usuario" > $chat
		echo "$recados" | grep $usuario
		if [ $? = 0 ]
		then
			echo "Hay recados para usted, $usuario:" > $chat
			COUNT=1
			while read p  
			do
				COUNT=[ $COUNT + 1 ]
				sed -n "${COUNT}p" recados/$usuario | awk -F '[%]' '{ print $3 " dijo: " $2 }' > $chat
			done < recados/$usuario
			rm recados/$usuario


		fi
	fi

	echo "$line" | grep "!Alfred "
	if [ $? = 0 ]
	then
		case $(echo $line | cut -d'!' -f2- | awk '{ print $2 }') in
			hola )
				echo "Hola, buen hombre" > $chat
				;;
			di )
				echo "$line" | cut -d'!' -f2- | cut -d ' ' -f3- > $chat
				;;
			fortuna )
				echo $(fortune) > $chat
				;;
			!dile )
				usr=$(echo "$line" | awk -F '[()]' '{ print $2 }')
				msg=$(echo "$line" | awk -F '[()]' '{ print $3 }')
				from=$(echo "$line" | awk -F '[<>]' '{ print $2 }')
				echo "$usr%$msg%$from" >> recados/$usr
				echo "El recado para $usr ha sido guardado." > $chat 
				;;

			ayuda )
				echo "Soy un robot tonto hecho en bash basado en el programa ii" > $chat
				echo "El programa ii tiene licencia GNU/GPL2.0 al igual que yo" > $chat
				echo "Tengo disponibles los siguientes comandos:" > $chat
				echo "hola__________________________Hola" > $chat
				echo "di____________________________Hazme decir algo" > $chat
				echo "fortuna_______________________Decir una frase aleatoria" > $chat
				echo "dile (usuario)________________Paso el recado cuando se conecte" > $chat
				echo "ayuda_________________________Mostrar este mensaje" > $chat
				;;
			* )
				echo "No lo entendi, buen hombre" > $chat
				;;
		esac
	fi
done
