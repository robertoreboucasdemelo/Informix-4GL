###############################################################################
# Nome do Modulo: CTS05M01                                           Pedro    #
#                                                                    Marcelo  #
# Informa senha sistema de alarme a distancia                        Set/1995 #
###############################################################################

database porto


globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
function cts05m01(d_cts05m01)
#--------------------------------------------------------------

 define  d_cts05m01   record
    vcllicnum         like datmservico.vcllicnum,
    vclchsfnl         like abbmveic.vclchsfnl   ,
    vicsnh            like datmservicocmp.vicsnh
 end record

 define  ws           record
    disbaxnum         like adbmbaixa.disbaxnum,
    cabec             char(43),
    confirma          char(01)
 end record




	initialize  ws.*  to  null

 let int_flag     =  false
 initialize ws.*  to null

 if d_cts05m01.vcllicnum  is not null   and
    d_cts05m01.vcllicnum  <> "    "     then
    whenever error continue

    select max(adbmitem.disbaxnum)
      into ws.disbaxnum
      from adbmbaixa, adbmitem
     where adbmbaixa.vcllicnum = d_cts05m01.vcllicnum   and
           adbmitem.disbaxtip  = adbmbaixa.disbaxtip    and
           adbmitem.vstmaqcod  = adbmbaixa.vstmaqcod    and
           adbmitem.disbaxnum  = adbmbaixa.disbaxnum    and
           adbmitem.discoddig  = 981

    whenever error stop

    if sqlca.sqlcode <> 0     and
       sqlca.sqlcode <> 100   then
       error " Informacoes sobre  ALARME  nao disponiveis no momento!"
       call cts08g01("A","N","","INFORMACOES SOBRE ALARME NAO","",
                                "ESTAO DISPONIVEIS NO MOMENTO")
            returning ws.confirma
       return d_cts05m01.vicsnh
    end if
 end if

 if ws.disbaxnum  is null   or
    ws.disbaxnum  =  0      then
    if d_cts05m01.vclchsfnl  is not null   and
       d_cts05m01.vclchsfnl  <> "    "     then
       whenever error continue

       select max(adbmitem.disbaxnum)
         into ws.disbaxnum
         from adbmbaixa, adbmitem
        where adbmbaixa.vclchsfnl = d_cts05m01.vclchsfnl   and
              adbmitem.disbaxtip  = adbmbaixa.disbaxtip    and
              adbmitem.vstmaqcod  = adbmbaixa.vstmaqcod    and
              adbmitem.disbaxnum  = adbmbaixa.disbaxnum    and
              adbmitem.discoddig  = 981

       whenever error stop

       if sqlca.sqlcode <> 0     and
          sqlca.sqlcode <> 100   then
          error " Informacoes sobre  ALARME  nao disponiveis no momento!"
          call cts08g01("A","N","","INFORMACOES SOBRE ALARME NAO","",
                                   "ESTAO DISPONIVEIS NO MOMENTO")
               returning ws.confirma
          return d_cts05m01.vicsnh
       end if
    end if
 end if

 if ws.disbaxnum  is null   or
    ws.disbaxnum  =  0      then
    return d_cts05m01.vicsnh
 end if


 open window cts05m01 at 11,15 with form "cts05m01"
                         attribute (form line 1, border)

 let ws.cabec =  " VEICULO COM SISTEMA DE ALARME A DISTANCIA"
 display by name ws.cabec
 display by name d_cts05m01.vcllicnum

 input by name d_cts05m01.vicsnh
        without defaults

   before field vicsnh
          display by name d_cts05m01.vicsnh      attribute (reverse)
          error " Caso a senha seja desconhecida, pressione (F17)Abandona!"

   after  field vicsnh
          display by name d_cts05m01.vicsnh

          if d_cts05m01.vicsnh  is null   then
             error " Caso a senha seja desconhecida, pressione (F17)Abandona!"
             next field vicsnh
          end if
          error ""

   on key (interrupt)
      exit input

 end input

 close window cts05m01
 let int_flag = false
 return d_cts05m01.vicsnh

end function  #  cts05m01
