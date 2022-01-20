#############################################################################
# Nome do Modulo: CTS00M23                                          Wagner  #
#                                                                           #
# Display da referencia do endereco de ocorrencia do servico       Fev/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################


database porto


{define a dec(10,0),
        b dec(2,0)
 MAIN
   prompt "servico " for a
   prompt " ano " for b
   call cts00m23(a,b)
 END MAIN
}

#----------------------------------------------------------------------
 function cts00m23(param)
#----------------------------------------------------------------------

 define param       record
    atdsrvnum       like datmmdtsrv.atdsrvnum,
    atdsrvano       like datmmdtsrv.atdsrvano
 end record

 define a_cts00m23    record
    lclidttxt         like datmlcl.lclidttxt,
    lgdtxt            char (65),
    lclbrrnom         like datmlcl.lclbrrnom,
    endzon            like datmlcl.endzon,
    cidnom            like datmlcl.cidnom,
    ufdcod            like datmlcl.ufdcod,
    lclrefptotxt      like datmlcl.lclrefptotxt,
    dddcod            like datmlcl.dddcod,
    lcltelnum         like datmlcl.lcltelnum,
    lclcttnom         like datmlcl.lclcttnom
 end record

 define ws            record
    lclrefptotxt1     char (50),
    lclrefptotxt2     char (50),
    lclrefptotxt3     char (50),
    lclrefptotxt4     char (50),
    lclrefptotxt5     char (50),
    confirma          char (01),
    sqlcod            integer
 end record



	initialize  a_cts00m23.*  to  null

	initialize  ws.*  to  null

 initialize a_cts00m23.*  to null
 initialize ws.*          to null

 open window w_cts00m23 at 11,19 with form "cts00m23"
     attribute(border, form line first, message line last - 1)

 #------------------------
 # Acessa local ocorrencia
 #------------------------
 call ctx04g00_local_reduzido(param.atdsrvnum,
                              param.atdsrvano, 1)
                    returning a_cts00m23.lclidttxt thru
                              a_cts00m23.lclcttnom, ws.sqlcod

 if ws.sqlcod                 <> 0       then
    initialize a_cts00m23.lclrefptotxt to null
 end if

 let ws.lclrefptotxt1 = a_cts00m23.lclrefptotxt[001,050]
 let ws.lclrefptotxt2 = a_cts00m23.lclrefptotxt[051,100]
 let ws.lclrefptotxt3 = a_cts00m23.lclrefptotxt[101,150]
 let ws.lclrefptotxt4 = a_cts00m23.lclrefptotxt[151,200]
 let ws.lclrefptotxt5 = a_cts00m23.lclrefptotxt[201,250]

 display by name ws.lclrefptotxt1
 display by name ws.lclrefptotxt2
 display by name ws.lclrefptotxt3
 display by name ws.lclrefptotxt4
 display by name ws.lclrefptotxt5

 message " (F17)Abandona"

 input by name ws.confirma without defaults
    after field confirma
       next field confirma

    on key (interrupt, control-c)
       exit input
 end input

 let int_flag = false
 close window w_cts00m23

end function
