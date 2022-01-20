###############################################################################
# Nome do Modulo: CTS06N01                                              Pedro #
#                                                                     Marcelo #
# Menu de historico da vistoria previa                               Jan/1995 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------
function cts06n01(k_cts06n01)
#------------------------------------

   define k_cts06n01  record
     atdsrvnum  like  datmservico.atdsrvnum,
     atdsrvano  like  datmservico.atdsrvano,
     vstnumdig  like  datmvistoria.vstnumdig,
     funmat     like  datmservico.funmat,
     data       like  datmservico.atddat,
     hora       like  datmservico.atdhor
   end record




   open window w_cts06n01 at 4,2 with form "cts06n01"
   display k_cts06n01.vstnumdig  to  vstnumdig
   display g_documento.atdnum to atdnum attribute (reverse)

   let int_flag = false

   menu "HISTORICO"
      command key ("I")           "Implementa"
                                  "Implementa dados no historico"
        call cts10m00(k_cts06n01.atdsrvnum, k_cts06n01.atdsrvano,
                      k_cts06n01.funmat   , k_cts06n01.data     ,
                      k_cts06n01.hora)
        clear form
        display k_cts06n01.vstnumdig  to  vstnumdig
        display g_documento.atdnum to atdnum attribute (reverse)
        next option "Encerra"

      command key ("C")           "Consulta"
                                  "Consulta historico ja' cadastrado"
        call cts10m01(k_cts06n01.atdsrvnum, k_cts06n01.atdsrvano)
        clear form
        display k_cts06n01.vstnumdig  to  vstnumdig
        display g_documento.atdnum to atdnum attribute (reverse)
        next option "Encerra"

      command key (interrupt,E)   "Encerra"    "Retorna ao menu anterior"
        exit menu
   end menu

   let int_flag = false

   close window w_cts06n01

end function # cts06n01
