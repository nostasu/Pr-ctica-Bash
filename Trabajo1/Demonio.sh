#!/bin/bash

#Variables
linea_demonio=$(ps l | grep [D]emonio)
pid_demonio=$(echo $linea_demonio | cut -d " " -f3)
#Funcion
function matar_proceso_y_descendientes(){
#proporcionada por el ED
    pid_padre=$1
    pids=$(pstree -p $pid_padre | grep -o -E '[0-9]+')
    pids=$(echo $pids | tr '\n' ' ')
    kill -SIGTERM $pids
}

  until [ -f "Apocalipsis" ]
  do
    sleep 1
#   -Lee las listas y revive los procesos cuando sea necaario dejando entradas en la biblia
  #Lista procesos
  for pid in $(awk '{print $1}' procesos)
    do
    if [[ "$(ls Infierno)" ]]
      then
        #Comprobamos si en infierno esta el mismo
        existe=$(ls Infierno | grep "$pid")
        if [ "$existe" ]
          then
          #Encuentra una coincidencia, procedemos a borrar todo su árbol de procesos, su entrada en la lista, el fichero correspondiente en Infierno, ademas, creamos entrada en la biblia.
          #Primero, guardamos el argumento para poder almacenarlo en la biblia
          # Con awk extraemos la fila entera que contiene el pid, luego lo cortarmos y con -f2- le indicamos que queremos desde f2 hasta el final del archivo lo cual nos da el comando
          command_line=$(awk '{if ($1=="'"$pid"'") print $0}' procesos | cut -d ' ' -f2-)
          flock 'San Pedro' sed -i "/$pid/d" procesos
          rm Infierno/$pid
          echo $(date +%T) El proceso $pid $command_line ha terminado. >> Biblia.txt
          matar_proceso_y_descendientes "$pid"
        fi
    else
      #No se encuentra en el infierno, por tanto, comprobamos si sigue en ejecucion
      echo "No se encuentra en el infierno"
      ejecucion=$(ps | grep "$pid")
      if [ "$ejecucion" ]
        then
          echo "esta en ejecucion, no hacemos nada"
          else
          #No esta en ejecucion, lo borramos y anotamos su entrada en la biblia
          command=$(awk '{if ($1=="'"$pid"'") print $0}' procesos | cut -d ' ' -f2-)
          comando_sin_comillas=$(echo "$command" | tr -d "'")
          flock 'San Pedro' sed -i "/$pid/d" procesos
          echo $(date +%T) El proceso $pid $command ha terminado. >> Biblia.txt
      fi
    fi
  done

  #Lista procesos_servicio
  for pid in $(awk '{print $1}' procesos_servicio)
    do
    if [[ "$(ls Infierno)" ]]
      then
        #Comprobamos si en infierno esta el mismo
        existe=$(ls Infierno | grep "$pid")
        if [ "$existe" ]
          then
          #Encuentra una coincidencia, procedemos a borrar todo su árbol de procesos, su entrada en la lista, el fichero correspondiente en Infierno, ademas, creamos entrada en la biblia.
          #Primero, guardamos el argumento para poder almacenarlo en la biblia
          # Con awk extraemos la fila entera que contiene el pid, luego lo cortarmos y con -f2- le indicamos que queremos desde f2 hasta el final del archivo lo cual nos da el comando
          command_line=$(awk '{if ($1=="'"$pid"'") print $0}' procesos_servicio | cut -d ' ' -f2-)
          flock 'San Pedro' sed -i "/$pid/d" procesos_servicio
          rm Infierno/$pid
          echo $(date +%T) El proceso $pid $command_line ha terminado. >> Biblia.txt
          matar_proceso_y_descendientes "$pid"
        fi
    else
      #No se encuentra en el infierno, por tanto, comprobamos si sigue en ejecucion
      ejecucion=$(ps | grep "$pid")
      if [ "$ejecucion" ]
        then
          echo "esta en ejecucion, no hacemos nada"
          else
          #No esta en ejecucion, resucitamos al proceso y lo agregamos a la biblia
          command=$(awk '{if ($1=="'"$pid"'") print $0}' procesos_servicio | cut -d ' ' -f2-)
          comando_sin_comillas=$(echo "$command" | tr -d "'")
          #Borramos el anterior de la lista de procesos y lo creamos
          flock 'San Pedro' sed -i "/$pid/d" procesos_servicio
          bash -c "$comando_sin_comillas" &
          flock 'San Pedro' echo $! $command >> procesos_servicio
          #Ponemos el nuevo proceso creado en la lista de procesos
          echo $(date +%T) El proceso $pid $command resucita con pid $! >> Biblia.txt
      fi
    fi
  done

      #Lista procesos_periodicos
  for pid in $(awk '{print $3}' procesos_periodicos)
    do
    #Primero, guardamos el argumento para poder almacenarlo en la biblia
    # Con awk extraemos la fila entera que contiene el pid, luego lo cortarmos y con -f2- le indicamos que queremos desde f2 hasta el final del archivo lo cual nos da el comando
    command=$(awk '{if ($3=="'"$pid"'") print $0}' procesos_periodicos | cut -d ' ' -f4-)
    comando_sin_comillas=$(echo "$command" | tr -d "'")
    if [[ "$(ls Infierno)" ]]
      then
        #Comprobamos si en infierno esta el mismo
        existe=$(ls Infierno | grep "$pid")
        if [ "$existe" ]
          then
          #Encuentra una coincidencia, procedemos a borrar todo su árbol de procesos, su entrada en la lista, el fichero correspondiente en Infierno, ademas, creamos entrada en la biblia.
          flock 'San Pedro' sed -i "/$pid/d" procesos_periodicos
          rm Infierno/$pid
          echo $(date +%T) El proceso $pid $command ha terminado. >> Biblia.txt
          matar_proceso_y_descendientes "$pid"
        fi
    else
      #No se encuentra en el infierno, por tanto, incrementamos el contador de tiempo en todos
      tiempo=$(awk '{if ($3=="'"$pid"'") print $1}' procesos_periodicos )
      tiempo_total=$(awk '{if ($3=="'"$pid"'") print $2}' procesos_periodicos )
      nuevo_tiempo=$((tiempo+1))
      #Explicacion detallada, usamos -i para que sobreescriba el mismo fichero , primero buscamos la linea del pid indicando que es el inicio de la linea con ^, todo ello del archivo de procesos periodicos
      flock 'San Pedro' sed -i "/$pid/ s/^$tiempo /$nuevo_tiempo /g" procesos_periodicos
      ejecucion=$(ps | grep "$pid")
      if [ "$ejecucion" ]
        then
          echo "esta en ejecucion, no hacemos nada, solo el incrementar contador que ya esta incrementado"
         else
          #No esta en ejecucion
          echo "No esta en ejecucion, miramos el tiempo y lo volvemos a lanzar"
          if [[ $nuevo_tiempo -ge $tiempo_total ]]
          then
            echo "Resucitar"
            #Borramos el anterior de la lista de procesos y lo creamos
            flock 'San Pedro' sed -i "/$pid/d" procesos_periodicos
            bash -c "$comando_sin_comillas" &
            flock 'San Pedro' echo '0' $tiempo_total $! $command >> procesos_periodicos
            echo $(date +%T) El proceso $pid $command se ha reencarnado en el pid $! >> Biblia.txt
          fi
      fi
    fi
  done

done
#Apocalipsis: termino todos los procesos y limpio todo dejando sólo Fausto, el Demonio y la Biblia
echo $(date +%T) '--------------- Apocalipsis --------------' >> Biblia.txt
  #Lista procesos
  for pid in $(awk '{print $1}' procesos)
    do
      #Para cada pid que exista, matamos el todo el arbol de procesos
      flock 'San Pedro' sed -i "/$pid/d" procesos
      echo $(date +%T) El proceso $pid ha terminado. >> Biblia.txt
      matar_proceso_y_descendientes "$pid"
  done

  #Lista procesos servicio
  for pid in $(awk '{print $1}' procesos_servicio)
    do
      #Para cada pid que exista, matamos el todo el arbol de procesos
      flock 'San Pedro' sed -i "/$pid/d" procesos_servicio
      echo $(date +%T) El proceso $pid ha terminado. >> Biblia.txt
      matar_proceso_y_descendientes "$pid"
  done

      #Lista procesos periodicos
  for pid in $(awk '{print $3}' procesos_periodicos)
    do
      #Para cada pid que exista, matamos el todo el arbol de procesos
      flock 'San Pedro' sed -i "/$pid/d" procesos_periodicos
      echo $(date +%T) El proceso $pid ha terminado. >> Biblia.txt
      matar_proceso_y_descendientes "$pid"
  done
    #Eliminamos todos archivos menos fausto demonio y biblia
  rm 'procesos'
  rm 'procesos_servicio'
  rm 'procesos_periodicos'
  rm 'San Pedro'
  rm 'Apocalipsis'
  if [[ -d 'Infierno' ]]
  then
    if [ "$(ls Infierno)" ]
    then
      rm -rf Infierno
      else
        rmdir Infierno
    fi
  fi
  ;;

  #Por último, el Demonio se mata a si mismo
  kill $pid_demonio
