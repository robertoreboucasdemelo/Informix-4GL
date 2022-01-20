#############################################################################
# Nome do Modulo: wdatc033                                                  #
#                                                                   Marcus  #
# Envio de mesnagens pager para viaturas                            Dez/01  #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#############################################################################
 
 database porto

#------------------------------------------------------------------------------
main
#------------------------------------------------------------------------------

 define param       record
    usrtip          char (1),
    webusrcod       char (06),
    sesnum          char (10),
    macsissgl       char (10)
 end record

 define wdatc033 	array[100] of record
   atdvclsgl            like datkveiculo.atdvclsgl,
   pgrnum               like datkveiculo.pgrnum
 end record


 define ws          record
   statusprc        dec  (1,0),
   sestblvardes1    char (256),
   sestblvardes2    char (256),
   sestblvardes3    char (256),
   sestblvardes4    char (256),
   sespcsprcnom     char (256),
   prgsgl           char (256),
   acsnivcod        dec  (1,0),
   webprscod        dec  (16,0)
 end record

 define padrao    char(2000)
 define arr_aux   smallint
 define arr_total smallint
 define comando   char(500)
 define sttsess   dec  (1,0)

#---------------------------------------------------------------------------
# Inicializa variaveis
#---------------------------------------------------------------------------

 initialize wdatc033     to null
 initialize ws.*         to null 
 initialize param.*         to null 
 initialize padrao    to null
 initialize arr_aux   to null
 initialize arr_total to null
 initialize comando   to null
 initialize sttsess   to null

 let param.usrtip     = arg_val(1)
 let param.webusrcod  = arg_val(2)
 let param.sesnum     = arg_val(3)
 let param.macsissgl  = arg_val(4)

 #------------------------------------------
 #  ABRE BANCO   (TESTE ou PRODUCAO)
 #------------------------------------------
 call fun_dba_abre_banco("CT24HS")
 set isolation to dirty read

 #---------------------------------------------
 #  CHECA STATUS DA SESSAO E RECEBE PARAMETROS
 #---------------------------------------------

 call wdatc002(param.*)
      returning ws.*

   if ws.statusprc <> 0 then
      display "NOSESS@@Por quest\365es de seguran\347a seu tempo de<BR> permanêncianesta página atingiu seu limite máximo.@@"
      exit program(0)
   end if

#------------------------------------------------------------------------------
# Preparacao das Consultas
#------------------------------------------------------------------------------

 let comando = "select datkveiculo.atdvclsgl, ",
               "       datkveiculo.pgrnum ",
               " from datkveiculo ",
               " where datkveiculo.pstcoddig = ? ",
               "   and atdvclsgl is not null ",
               "   and pgrnum is not null"

  prepare s_datkveiculo from comando
  declare c_datkveiculo cursor for s_datkveiculo

 let arr_aux = 1

 open c_datkveiculo using ws.webprscod

 foreach c_datkveiculo into wdatc033[arr_aux].atdvclsgl,
                            wdatc033[arr_aux].pgrnum

    let arr_aux = arr_aux + 1

 end foreach

 let arr_total = arr_aux - 1
 
 if arr_total > 0 then

    let padrao = "PADRAO@@2@@viatura@@Veículo@@0@@0@@" clipped
    let padrao = padrao clipped,"@@1@@@@" clipped
    let padrao = padrao clipped, "TODOS", "@@0@@0@@" clipped
    for arr_aux = 1 to arr_total
         let padrao = padrao clipped, wdatc033[arr_aux].atdvclsgl,"@@0@@",wdatc033[arr_aux].pgrnum,"@@" clipped
    end for
    display padrao clipped
    display "PADRAO@@1@@B@@C@@0@@Mensagem @@"
 else
    display "PADRAO@@1@@N@@C@@0@@Nenhuma viatura encontrada@@"
 end if 

 #------------------------------------
 # ATUALIZA TEMPO DE SESSAO DO USUARIO
 #------------------------------------

  call wdatc003(param.*,ws.*)
      returning sttsess

end main
