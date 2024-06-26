# LFA - Universitat de Barcelona 
# M.Mateo - Script análisis melódico
#
# M. Mateo Octubre 22: no tratar "z" en melodía
# M. Mateo Enero 23: panel para ficheros y tratamiento margen (modif. de Darío)
clearinfo
# #########################################################################
# Definición de directorios de trabajo
# datos: Corpus a analizar f0 : datos pitch,  f0r : datos pitch a revisar
# #########################################################################
form AMH: Extracción datos tonales -F0- (v3)
comment a) Directorio de los archivos del corpus (sonido+textgrid)
  text dirdatos 
  comment b) Directorio de los ficheros de salida, con los datos tonales
  text dirf0 
comment c) Directorio de las alertas
  text dirf0r 
comment Indique el porcentaje mínimo de variación tonal que se considera
  real porcentaje_mínimo 10    
endform
# ##################################################
# Borramos fichero análisis melódico por si alguna ejecución quedó a medias y grabamos cabecera
# #######################################33 
#textgrid$ = selected$("TextGrid")
cabecera = 0
# ####################################
# Creamos lista de ficheros a procesar
# ###################################
#
Create Strings as file list... list 'dirdatos$'\*.TextGrid
numberOfFiles = Get number of strings
#
for ifile to numberOfFiles
   select Strings list
   sonido$ = Get string... ifile
   Read from file... 'dirdatos$'\'sonido$'
   textgrid$= selected$("TextGrid")
   fichero$ = selected$("TextGrid")
   call cabecera 'fichero$' 'dirf0$' 'dirf0r$'
# Generamos el fichero de pitch a partir de fichero original
# en función de si se ha informado que la voz era masculina (m) o 
# femenina (f)
cabecera= cabecera + 1
select TextGrid 'textgrid$'
n = Get number of intervals... 1
# ###########################################
# Buscamos información de si la voz es femenina o masculina
# ########################################## 
voz$ =""
for i to n
      silaba$ = Get label of interval... 1 i
      if i = 1 or i = n
          if silaba$ = "f" or silaba$ = "F"
                voz$ ="f"
             else 
                  if silaba$ = "m" or silaba$ = "M" 
                     voz$ ="m"
            endif
       endif
    endif
endfor
# ########################################################################
# Validamos que está informado tipo de voz
# ########################################################################

if voz$=""
   exit Textgrid no correcto, falta informar si la voz es masculina (m) o femenina (f)
endif 
# #######################################################
#  Creación fichero pitch
# #######################################################
Read from file... 'dirdatos$'\'textgrid$'.wav
select Sound 'textgrid$'
if voz$ = "f"
To Pitch (ac)... 0.02 90 15 yes 0.03 0.25 0.01 0.35 0.14 600
else
To Pitch (ac)... 0.02 40 15 yes 0.03 0.25 0.01 0.35 0.14 350
endif
pitch = selected ("Pitch")
select TextGrid 'textgrid$'
n = Get number of intervals... 1
# ###########################################
# Bucle principal para cada sílaba informada (*)
# ########################################## 
for i to n
      silaba$ = Get label of interval... 1 i
      if (silaba$ <> "" and silaba$ <> "f" and silaba$ <> "m" and silaba$ <> "F" and silaba$ <> "M" and silaba$ <> "z" and silaba$ <> "Z")   
         ti = Get starting point... 1 i
         ti$ = fixed$ (ti, 8)
         tf = Get end point... 1 i
         tf$ = fixed$ (tf, 8)
         select pitch
             
# ############################# 
# Inicializamos las variables
# #############################
         i$ = fixed$ (i, 0)        
         grabo= 0
         grabo$ = fixed$ (grabo, 0)
         control = 0
         control$ = fixed$ (control, 0)
         f0_i = 0
         f0_i$ = fixed$ (f0_i, 0)
         f0_ib = 0
         f0_ib$ = fixed$ (f0_ib, 0)
         f0_ibus = 0
         f0_ibus$ = fixed$ (f0_ibus, 0)
         f0_f = 0
         f0_f$ = fixed$ (f0_f, 0)
         f0_fb = 0
         f0_fb$ = fixed$ (f0_fb, 0)
         f0_fbus = 0
         f0_fbus$ = fixed$ (f0_fbus, 0)
         f0 = 0
         f0$ = fixed$ (f0, 0)
         min_f0 = 0
         min_f0$ = fixed$ (min_f0, 0)
         max_f0 = 0
         max_f0$ = fixed$ (max_f0, 0)
         fi_margen_menor = 0
      fi_margen_menor$ = fixed$ (fi_margen_menor, 0)
      fi_margen_mayor = 0
      fi_margen_mayor$ = fixed$ (fi_margen_mayor, 0)
      ff_margen_menor = 0
      ff_margen_menor$ = fixed$ (fi_margen_menor, 0)
      ff_margen_mayor = 0
      ff_margen_mayor$ = fixed$ (ff_margen_mayor, 0)
      fmin_margen_menor = 0
      fmin_margen_menor$ = fixed$ (fmin_margen_menor, 0)
      fmin_margen_mayor = 0
      fmin_margen_mayor$ = fixed$ (fmin_margen_mayor, 0)
      fmax_margen_menor = 0
      fmax_margen_menor$ = fixed$ (fmax_margen_menor, 0)
      fmax_margen_mayor = 0
      fmax_margen_mayor$ = fixed$ (fmax_margen_mayor, 0)
# ############################
# Variables para información de seguimiento (puts)
# en ejecución normal : N
# ###########################
         imprimir$ = "N"
         imprimirtodo$ = "N"       
         sigo$ ="N"
#
#
#
# Asignamos valor 0,si sistema no ha podido asignar inicial y final.
# Intentamos buscar el primero informado, si lo encontramos, lo informamos. 
# Convertimos los valores a enteros.
# Los valores se informarán manualmente.
#        
#
         f0 = Get mean... ti tf Hertz
         f0$ = fixed$ (f0, 0)
            if f0$ = "--undefined--"  
	       f0$="0"
            endif 
	 min_f0 = Get minimum... ti tf Hertz Parabolic
         min_f0$ = fixed$ (min_f0, 0)
            if min_f0$ = "--undefined--"   
	    min_f0$ = "0"
            endif
         max_f0 = Get maximum... ti tf Hertz Parabolic
         max_f0$ = fixed$ (max_f0, 0)
            if max_f0$ = "--undefined--"
	    max_f0$ = "0"
            endif
# ######################################################
# Si no hay información de pitch en el segmento tonal,
# no realizamos la búsqueda
# #######################################################
         if f0$ = "0" and min_f0$ = "0" and max_f0$ = "0"
              f0_i$ = "0"
              f0_f$ = "0"
            else
                f0_i = Get value at time... ti Hertz Linear
                f0_i$ = fixed$ (f0_i, 0)
	       if f0_i$ ="--undefined--"   	    
            	  f0_i$ = "0"
           	  call primero 'ti$' 'tf$' 'f0_i$'
            	  f0_i = f0_ib
	    	  f0_i$ = fixed$ (f0_i, 0)
	             if f0_i$ = "--undefined--"   	    
                     f0_i$ = "0"	
                     endif    
	      endif
         	f0_f = Get value at time... tf Hertz Linear
         	f0_f$ = fixed$ (f0_f, 0)
              if f0_f$ = "--undefined--"
	     	f0_f$ = "0"
	    	call ultimo 'ti$' 'tf$' 'f0_f$'
            	f0_f = f0_fb
            	f0_f$ = fixed$ (f0_f, 0)
                   if f0_f$ = "--undefined--"
           	f0_f$ = "0"
	            endif
              endif
        endif         
#
# ########################
#   Valores para seguimiento, según variable imprimir, se pueden añadir más condiciones   
# #########################      
#      
 if imprimir$ = "S" and i=30
    echo Valores :
        printline grabacion : 'grabo$'
        printline i : 'i$'
        printline sílaba : 'silaba$'
        printline inicio : 'ti$'
        printline fin : 'tf$'
        printline f0_i: 'f0_i$'
        printline f0_ibuscado : 'f0_ibus$'
        printline f0_fbuscado : 'f0_fbus$'
        printline f0_f : 'f0_f$'
        printline f0 : 'f0$'
        printline min_f0 : 'min_f0$'
        printline max_f0 : 'max_f0$'
        printline fi_margen_menor : 'fi_margen_menor$'
        printline fi_margen_mayor : 'fi_margen_mayor$'
        printline ff_margen_menor : 'ff_margen_menor$'
        printline ff_margen_mayor : 'ff_margen_mayor$'
        printline fmin_margen_menor : 'fmin_margen_menor$'
        printline fmin_margen_mayor : 'fmin_margen_mayor$'
        printline fmax_margen_menor : 'fmax_margen_menor$'
        printline fmax_margen_mayor : 'fmax_margen_mayor$'
   endif
#
# Si alguno de los valores está a 0 (el sistema no ha podido calcular)imprimiremos directamente.
# Los valores se informarán manualmente en el fichero resultado  (***)
# 
      if f0_i$ ="0" or f0_f$ ="0" or f0$ ="0" or min_f0$ ="0" or max_f0$ ="0"
              grabo$ = "8"
      else     
# 
# (1) Validación de valores extremos 
#   90 y 550 --> female
#   60 y 350 --> male
#  para generar alerta en fichero de revisión
#
     if (voz$ = "f" and ((f0_i > 550 or f0_f > 550 or f0 > 550 or min_f0 > 550 or max_f0 > 550) or (f0_i < 90 or f0_f < 90 or f0 < 90 or min_f0 < 90 or max_f0 < 90)))
        control$ ="1"
     endif
     if (voz$ = "m" and ((f0_i > 350 or f0_f > 350 or f0 > 350 or min_f0 > 350 or max_f0 > 350) or (f0_i < 60 or f0_f < 60 or f0 < 60 or min_f0 < 60 or max_f0 < 60)))
       control$ ="1"
     endif
#
#
#
# (2) Asignamos los márgenes inferior y superior -actualmente 10%- 
#
        fi_margen_menor = f0_i * ((100 - porcentaje_mínimo)/100)
        fi_margen_menor$ = fixed$ (fi_margen_menor, 0)
        fi_margen_mayor = f0_i  * ((100 + porcentaje_mínimo)/100)
        fi_margen_mayor$ = fixed$ (fi_margen_mayor, 0)
        ff_margen_menor = f0_f * ((100 - porcentaje_mínimo)/100)
        ff_margen_menor$ = fixed$ (ff_margen_menor, 0)
        ff_margen_mayor = f0_f * ((100 + porcentaje_mínimo)/100)
        ff_margen_mayor$ = fixed$ (ff_margen_mayor, 0)
        fmin_margen_menor = min_f0 * ((100 - porcentaje_mínimo)/100)
        fmin_margen_menor$ = fixed$ (fmin_margen_menor, 0)
        fmin_margen_mayor = min_f0 * ((100 + porcentaje_mínimo)/100)
        fmin_margen_mayor$ = fixed$ (fmin_margen_mayor, 0)
        fmax_margen_menor = max_f0 * ((100 - porcentaje_mínimo)/100)
        fmax_margen_menor$ = fixed$ (fmax_margen_menor, 0)
        fmax_margen_mayor = max_f0 * ((100 + porcentaje_mínimo)/100) 
        fmax_margen_mayor$ = fixed$ (fmax_margen_mayor, 0)
#
# (3) Realizamos las verificaciones para decidir qué valores  grabaremos.
#
#

     	 if (('f0_f$' >= 'fi_margen_menor$' and 'f0_f$' <= 'fi_margen_mayor$') and (('max_f0$' >= 'fi_margen_menor$') and ('max_f0$' <= 'fi_margen_mayor$')) and (('min_f0$' >= 'fi_margen_menor$') and ('min_f0$' <= 'fi_margen_mayor$')))
          grabo$ = "1"
        endif
        if ('min_f0$' <= 'fi_margen_menor$') and ('f0_f$' >= 'fmin_margen_menor$') and ('f0_f$' <= 'fmin_margen_mayor$')
          grabo$ = "2"
        endif
        if ('max_f0$'>= 'fi_margen_mayor$') and ('f0_f$' >= 'fmax_margen_menor$') and ('f0_f$' <= 'fmax_margen_mayor$')
          grabo$ = "3"
        endif
        if (('f0_f$' <= 'fmin_margen_menor$' ) or ('f0_f$' >= 'fmin_margen_mayor$')) and ('min_f0$' <= 'fi_margen_menor$')
          grabo$ = "4"
          control$="1"
        endif
        if ('max_f0$' >= 'fi_margen_mayor$')  and (('f0_f$' <= 'fmax_margen_menor$') or ('f0_f$' >= 'fmax_margen_mayor$'))
          grabo$ = "5"
          control$ = "1"
                  endif
#
#
# ########################
#   Valores para seguimiento, según variable imprimir, se pueden añadir más condiciones   
# #########################
  if imprimirtodo$ = "S" and i=10
    echo Valores :
        printline grabacion : 'grabo$'
        printline control : 'control$'
        printline i : 'i$'
        printline sílaba : 'silaba$'
        printline inicio : 'ti$'
        printline fin : 'tf$'
        printline f0_i: 'f0_i$'
        printline f0_ibuscado : 'f0_ibus$'
        printline f0_fbuscado : 'f0_fbus$'
        printline f0_f : 'f0_f$'
        printline f0 : 'f0$'
        printline min_f0 : 'min_f0$'
        printline max_f0 : 'max_f0$'
         printline fi_margen_menor : 'fi_margen_menor$'
          printline fi_margen_mayor : 'fi_margen_mayor$'
          printline ff_margen_menor : 'ff_margen_menor$'
          printline ff_margen_mayor : 'ff_margen_mayor$'
          printline fmin_margen_menor : 'fmin_margen_menor$'
          printline fmin_margen_mayor : 'fmin_margen_mayor$'
          printline fmax_margen_menor : 'fmax_margen_menor$'
          printline fmax_margen_mayor : 'fmax_margen_mayor$'
   endif
# ######################################################
# Fin verificación de lo que tenemos que grabar (***)
# ######################################################
#
      endif
#
# #######################
# LLamada al procedimiento de grabación de cada sílaba en el fichero,
# después volvemos a seleccionar textgrid, porque se
# desselecciona en el proceso
# ################################
#
  call grabacion  'silaba$' 'f0_i$' 'f0_f$' 'f0$' 'min_f0$' 'max_f0$' 'grabo$' 'fichero$' 'dirf0$' 'dirf0r$'
select TextGrid 'textgrid$'
# #################################
# Fin bucle de cada sílaba (**)
# ##############################################
#
  endif
endfor
endfor
# 
# ###############################################################################################
# 
# Grabación del fichero con todos los datos informados
#
# Valor 8 cuando no se ha podido obtener algún dato y se graba a 0
# Además de grabar el fichero normal con el dato a 0, lo grabamos en el directorio "Revisar", 
# en el que quedarán todos los enunciados con análisis incompleto.
#
# ###############################################################################################
#
procedure grabacion .silaba$ .f0_i$ .f0_f$ .f0$ .min_f0$ .max_f0$ .grabo$ .fichero$ .dirf0$ .dirf0r$
#
#
#
        if grabo$="8" or grabo$="0"
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$',22,0,0'newline$'
           fileappend "'dirf0r$'\'fichero$'.txt"
                ... 'silaba$',0'newline$'
                       endif   
	if grabo$="1" and control$ = "0"
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0:0',0,0'newline$'
                       endif
        if grabo$="2" and control$ = "0"
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'*,'min_f0$:0',0,0'newline$'
                       endif
        if grabo$="3" and control$ = "0"
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'*,'max_f0$:0',0,0'newline$'
                      endif
        if grabo$="4" and control$ = "0"
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'*,'min_f0$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'**,'f0_f$:0',0,0'newline$'
                      endif
        if grabo$="5" and control$ = "0"
           fileappend "'dirf0$'\'fichero$'.txt"
               ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
               ... 'silaba$'*,'max_f0$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
               ... 'silaba$'**,'f0_f$:0',0,0'newline$'
                      endif
# ############################################################################################
#  Grabamos fila en el fichero de datos a revisar si está activada la variable
#  de control de valores extremos.         
# ############################################################################################   
	if grabo$="1" and control$ = "1"
           fileappend "'dirf0r$'\'fichero$'.txt"
                ... 'silaba$',999'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0:0',0,0'newline$'
                       endif
        if grabo$="2" and control$ = "1"
           fileappend "'dirf0r$'\'fichero$'.txt"
                ... 'silaba$',999'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'*,'min_f0$:0',0,0'newline$'
                       endif
        if grabo$="3" and control$ = "1"
          fileappend "'dirf0r$'\'fichero$'.txt"
                ... 'silaba$',999'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'*,'max_f0$:0',0,0'newline$'
                      endif
        if grabo$="4" and control$ = "1"
           fileappend "'dirf0r$'\'fichero$'.txt"
                ... 'silaba$',3'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'*,'min_f0$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
                ... 'silaba$'**,'f0_f$:0',0,0'newline$'
                      endif
        if grabo$="5" and control$ = "1"
           fileappend "'dirf0r$'\'fichero$'.txt"
                ... 'silaba$',3'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
               ... 'silaba$','f0_i$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
               ... 'silaba$'*,'max_f0$:0',0,0'newline$'
           fileappend "'dirf0$'\'fichero$'.txt"
               ... 'silaba$'**,'f0_f$:0',0,0'newline$'
                      endif    																
endproc
#
# ##################################################### 
# Buscamos primer valor informado del segmento tonal
# ######################################################
procedure primero .ti$ .tf$ .f0_i$
if sigo$ = "S"
echo Valores
printline entro búsqueda primero
endif 
#
#
#
        numberOfTimeSteps = ('tf$' - 'ti$') / 0.001
        step = 1
        repeat
	tmin = 'ti$' + (step - 1) * 0.001
        tmax = tmin + 0.001
	f0_ib= Get mean... tmin tmax Hertz
	f0_ibus$ = fixed$ (f0_ib, 0)
        if f0_ibus$ = "--undefined--"   	    
            f0_ibus$ = "0" 
        endif 
        step = step + 1
        until ('f0_ibus$' > 0) or (step = numberOfTimeSteps)
#
#
endproc
# ############################################################
# Buscamos último valor informado del segmento tonal
# #############################################################
procedure ultimo .ti$ .tf$ .f0_f$
if sigo$ = "Z"
echo Valores
printline entro búsqueda último
endif 

        numberOfTimeSteps = ('tf$' - 'ti$') / 0.001
        step = 1
        repeat
        tmin = 'tf$' - (step * 0.001)
        tmax = tmin + 0.001
        f0_fb= Get mean... tmin tmax Hertz
        f0_fbus$ = fixed$ (f0_fb, 0)
          if f0_fbus$ = "--undefined--"   	    
            f0_fbus$ = "0" 
          endif 
        step = step + 1
        until ('f0_fbus$' > 0) or (step = numberOfTimeSteps)
endproc
procedure cabecera .fichero$ .dirf0$ .dirf0r$
deleteFile ("'dirf0$'\'fichero$'.txt")
deleteFile ("'dirf0r$'\'fichero$'.txt")
   fileappend "'dirf0$'\'fichero$'.txt"
                ... Segmento,HZ,Perc,CE'newline$'
endproc