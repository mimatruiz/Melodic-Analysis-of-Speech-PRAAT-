# LFA - Universitat de Barcelona 
# Miguel Mateo
# Análisis melódico - obtención curva estándar
#
# 
#
clearinfo
#
# #########################################################################
# Definición de directorios de trabajo
# f0 : datos pitch, ce : datos curva estándar
# #########################################################################
tipof$ ="txt"
form AMH: Estandarización curva melódica (v1)
comment a) Directorio de los archivos con los datos tonales (S/AMH_Extraccion)
  text dirf0 
  comment b) Directorio de los ficheros con la curva estandarizada.
  text dirce 
endform

#

Create Strings as file list... list 'dirf0$'/*.*
numberOfFiles = Get number of strings
#
#
for ifile to numberOfFiles
if ifile = 3
echo valores 
printline fichero entrada : 'fichero$'
printline fichero salida : 'fichero_sal$'
printline dirce : 'dirce$'
endif
# ################
# Inicialización de variables
i = 0
hz = 0
perc = 0
percant = 0
ce = 0
ceant = 0
#
  select Strings list
  fichero$ = Get string... ifile
  Read Table from comma-separated file... 'dirf0$'\'fichero$'
  numberOfRows = Get number of rows
  call calculo 'tipof$' 'dirce$' 'dirf0$' 'fichero$'
#
#
#
endfor
#
procedure calculo .tipof$ .dirce$ .dirf0$ .fichero$
# Bucle de cáluclo de % y curva estándar
#
   for i to numberOfRows
     hz = Get value... i HZ
     hz$ = fixed$(hz, 0)
     perc = Get value... i Perc
     perc$ = fixed$(perc, 1)
     ce = Get value... i CE
     ce$ = fixed$(ce, 0)
          if i = 1
                 perc = 100
                 perc$ = fixed$ (perc, 1)
                 ce = 100
                 ce$ = fixed$(ce, 0)
                 Set numeric value... i Perc 'perc$'
                 Set numeric value... i CE 'ce$'
                 percant$ = fixed$ (perc, 1)
                 ceant$ = fixed$(ce, 0)
                 hzant$ = fixed$(hz, 0)
         else
                  perc = (('hz$'/'hzant$') * 100) - (100)
                  perc$ = fixed$ (perc, 0)
                  ce = ('perc$'*'ceant$'/100) + 'ceant$'
                  ce$ = fixed$ (ce, 0)
                  Set numeric value... i Perc 'perc$'
                  Set numeric value... i CE 'ce$'

                  percant$ = fixed$(perc, 1)
                  ceant$ = fixed$(ce, 0)
                  hzant$ = fixed$(hz, 0)

								
        endif
  endfor
fichero_sal$ = selected$("Table")  
Write to table file... 'dirce$'\'fichero_sal$'.txt
endproc
    
