###############################################################################
# Nome do Modulo: CTB02M05                                           Wagner   #
#                                                                             #
# Consulta dados sobre favorecido (Ordem de pagamento Carro-Extra)   Out/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
###############################################################################

database porto

#--------------------------------------------------------------
 function ctb02m05(param)
#--------------------------------------------------------------

 define  param        record
         lcvcod       like datklocadora.lcvcod,
         aviestcod    like datkavislocal.aviestcod
 end record

 define  d_ctb02m05   record
         linha1       char (54),
         linha2       char (54),
         pgtopccod    like datklcvfav.pgtopccod,
         socpgtopcdes char(10),
         favnom       like datklcvfav.favnom,
         pestip       like datklcvfav.pestip,
         cgccpfnum    like datklcvfav.cgccpfnum,
         cgcord       like datklcvfav.cgcord,
         cgccpfdig    like datklcvfav.cgccpfdig,
         bcocod       like datklcvfav.bcocod,
         bcosgl       like gcdkbanco.bcosgl,
         bcoagnnum    like datklcvfav.bcoagnnum,
         bcoagndig    like datklcvfav.bcoagndig,
         bcoagnnom    like gcdkbancoage.bcoagnnom,
         bcoctatip    like datklcvfav.bcoctatip,
         bcoctatipdes char(10),
         bcoctanum    like datklcvfav.bcoctanum,
         bcoctadig    like datklcvfav.bcoctadig,
         confirma     char(1)
 end record

 define  ws           record
         nomrazsoc    like dpaksocor.nomrazsoc,
         nomgrr       like dpaksocor.nomgrr,
         lcvnom       like datklocadora.lcvnom,
         aviestnom    like datkavislocal.aviestnom,
         bcoagnnum    like gcdkbancoage.bcoagnnum
 end record

 initialize d_ctb02m05.*  to null
 initialize ws.*          to null
 let int_flag             =  false


 open window ctb02m05 at 10,19 with form "ctb02m05"
                         attribute (form line 1, border)

 input by name d_ctb02m05.confirma   without defaults

   before field confirma
          if param.lcvcod is not null then
             initialize ws.lcvnom, ws.aviestnom to null
             select lcvnom
               into ws.lcvnom
               from datklocadora
              where datklocadora.lcvcod = param.lcvcod

             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura da locadora!"
                sleep 5
                exit input
             end if

             select aviestnom
               into ws.aviestnom
               from datkavislocal
              where datkavislocal.lcvcod    = param.lcvcod
                and datkavislocal.aviestcod = param.aviestcod

             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura da loja!"
                sleep 5
                exit input
             end if

             let d_ctb02m05.linha1 = "Locadora....: ",ws.lcvnom
             let d_ctb02m05.linha2 = "Nome Loja...: ",ws.aviestnom

             select pestip   , cgccpfnum   , cgcord   ,
                    cgccpfdig, favnom      , bcocod   ,
                    bcoagnnum, bcoagndig   , bcoctanum,
                    bcoctadig, pgtopccod   , bcoctatip
               into d_ctb02m05.pestip      , d_ctb02m05.cgccpfnum,
                    d_ctb02m05.cgcord      , d_ctb02m05.cgccpfdig,
                    d_ctb02m05.favnom      , d_ctb02m05.bcocod,
                    d_ctb02m05.bcoagnnum   , d_ctb02m05.bcoagndig,
                    d_ctb02m05.bcoctanum   , d_ctb02m05.bcoctadig,
                    d_ctb02m05.pgtopccod   , d_ctb02m05.bcoctatip
               from datklcvfav
              where datklcvfav.lcvcod    = param.lcvcod
                and datklcvfav.aviestcod = param.aviestcod

             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura do favorecido!"
                sleep 5
                exit input
             end if
          end if

         select cpodes
           into d_ctb02m05.socpgtopcdes
           from iddkdominio
          where iddkdominio.cponom = "socpgtopccod"         and
                iddkdominio.cpocod = d_ctb02m05.pgtopccod

         if sqlca.sqlcode <> 0    then
             error " Erro (",sqlca.sqlcode,") na leitura opcao de pagamento!"
             sleep 5
             exit input
         end if

          case d_ctb02m05.bcoctatip
            when  1
                  let d_ctb02m05.bcoctatipdes = "C.CORRENTE"
            when  2
                  let d_ctb02m05.bcoctatipdes = "POUPANCA"
          end case

          if d_ctb02m05.bcocod   is not null   and
             d_ctb02m05.bcocod   <> 0          then
             select bcosgl
               into d_ctb02m05.bcosgl
               from gcdkbanco
              where gcdkbanco.bcocod = d_ctb02m05.bcocod

             if sqlca.sqlcode <> 0   then
                error " Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
                sleep 5
                exit input
             end if
          end if

          if d_ctb02m05.bcoagnnum   is not null   and
             d_ctb02m05.bcoagnnum   <>  0         then
             let ws.bcoagnnum = d_ctb02m05.bcoagnnum

             select bcoagnnom
               into d_ctb02m05.bcoagnnom
               from gcdkbancoage
              where gcdkbancoage.bcocod    = d_ctb02m05.bcocod     and
                    gcdkbancoage.bcoagnnum = ws.bcoagnnum
          end if

          display by name d_ctb02m05.*
          display by name d_ctb02m05.confirma   attribute (reverse)

   after  field confirma
          display by name d_ctb02m05.confirma

          if ((d_ctb02m05.confirma   is null)    or
              (d_ctb02m05.confirma   <> "S"      and
               d_ctb02m05.confirma   <> "N"))    then
             error " Confirma deve ser: (S)im ou (N)ao !"
             next field confirma
          end if

          if d_ctb02m05.confirma  =  "N"   then
             initialize d_ctb02m05.*   to null
          end if

   on key (interrupt)
      exit input

 end input

 if int_flag   then
    initialize d_ctb02m05.*   to null
 end if

close window ctb02m05

return  d_ctb02m05.pestip      , d_ctb02m05.cgccpfnum,
        d_ctb02m05.cgcord      , d_ctb02m05.cgccpfdig,
        d_ctb02m05.favnom      , d_ctb02m05.bcocod   ,
        d_ctb02m05.bcosgl      , d_ctb02m05.bcoagnnum,
        d_ctb02m05.bcoagndig   , d_ctb02m05.bcoagnnom,
        d_ctb02m05.bcoctanum   , d_ctb02m05.bcoctadig,
        d_ctb02m05.pgtopccod   , d_ctb02m05.socpgtopcdes,
        d_ctb02m05.bcoctatip   , d_ctb02m05.bcoctatipdes,
        d_ctb02m05.confirma

end function  #  ctb02m05
