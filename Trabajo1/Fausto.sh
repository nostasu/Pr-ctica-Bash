#!/bin/bash

#Recibe órdenes creando los procesos y listas adecuadas

#Variables
linea_demonio=$(ps l | grep [D]emonio)
pid_demonio=$(echo $linea_demonio | cut -d " " -f3)

#Si el Demonio no está vivo lo crea
#Al leer/escribir en las listas hay que usar bloqueo para no coincidir con el Demonio
if [[ -z $linea_demonio ]]
  then
  #No existe, por tanto, reinicia todas las estructuras
  if [[ -f 'procesos' ]]
    then rm 'procesos'
  fi
  if [[ -f 'procesos_servicio' ]]
    then rm 'procesos_servicio'
  fi
  if [[ -f 'procesos_periodicos' ]]
    then rm 'procesos_periodicos'
  fi
  if [[ -f 'Biblia.txt' ]]
    then rm 'Biblia.txt'
  fi
  if [[ -f 'San Pedro' ]]
    then rm 'San Pedro'
  fi
  if [[ -f 'Apocalipsis' ]]
    then rm 'Apocalipsis'
  fi
  if [[ -d 'Infierno' ]]
  then
    if [ "$(ls Infierno)" ]
    then
      rm -rf Infierno
      else
        rmdir Infierno
    fi
  fi

  echo > procesos
  echo > procesos_servicio
  echo > procesos_periodicos
  echo > Biblia.txt
  echo > 'San Pedro'
  mkdir Infierno

  #Creamos el demonio
  nohup ./Demonio.sh > /dev/null &
  #Escribimos nacimiento en la biblia
  echo -e $(date +%T) '--------------- Génesis --------------\n'$(date +%T)' El demonio ha sido creado' > Biblia.txt
fi

case $1 in
  #menos c para indicar que se le estan pasando argumentos como comandos
  run)
    bash -c "$2" &
    #Usamos $! para obtener el pid del último proceso creado
    flock 'San Pedro' echo $! "'$2'" >> procesos
    echo $(date +%T) El proceso $! "'$2'" ha nacido. >> Biblia.txt

  ;;
  run-service)
    bash -c "$2" &
    flock 'San Pedro' echo $! "'$2'" >> procesos_servicio
    echo $(date +%T) El proceso $! "'$2'" ha nacido. >> Biblia.txt
  ;;
  run-periodic)
    bash -c "$3" &
    flock 'San Pedro' echo '0' $2 $! "'$3'" >> procesos_periodicos
    echo $(date +%T) El proceso $! "'$3'" ha nacido. >> Biblia.txt
  ;;
  list)
  awk {print} 'procesos'
  awk {print} 'procesos_servicio'
  awk {print} 'procesos_periodicos'
  ;;
 help)
  echo '-------------- Lista de comandos --------------'
  echo 'run            --> ./Fausto.sh run comando'
  echo 'run-service    --> ./Fausto.sh run-service comando'
  echo 'run-periodic   --> ./Fausto.sh run-periodic T comando'
  echo 'list           --> ./Fausto.sh list'
  echo 'help           --> ./Fausto.sh help'
  echo 'stop           --> ./Fausto.sh stop PID'
  echo 'end            --> ./Fausto.sh end'
  ;;
  stop)
  pid_procesos=$(awk '{if ($1=="'"$2"'") print $1}' procesos)
  pid_procesos_servicio=$(awk '{if ($1=="'"$2"'") print $1}' procesos_servicio)
  #El archivo procesos periodicos contiene la informacion del PID en la columnna 3. Por tanto con awk hacemos un if para comprobar que la primera coluna es la misma que el pid que nos pasan en la variable 2
  pid_procesos_periodicos=$(awk '{if ($3=="'"$2"'") print $3}' procesos_periodicos)
  if [[ $pid_procesos || $pid_procesos_servicio || $pid_procesos_periodicos ]]
  then
    > Infierno/"$2"
    else
    echo 'Introduzca un PID válido'
  fi

  ;;
  end)
  > Apocalipsis
  ;;
  *)
    echo Error, orden $1 no reconocida, consulte las órdenes disponibles con ./Fausto.sh help
  ;;
esac
