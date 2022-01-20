###############################################################################
# Nome do Modulo: CTS50G00                                           Sergio   #
#                                                                    Burini   #
# Funções de acesso a tabela de fases da OP (DBSMOPGFAS): PSI 221074 Mar/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#

database porto

#---------------------------#
function cts50g00_prepare()
#---------------------------#

   define l_sql char(500)

   let l_sql = " insert into dbsmopgfas (socopgnum,  ",
                                       " socopgfascod, ",
                                       " socopgfasdat, ",
                                       " socopgfashor, ",
                                       " funmat) ",
                              " values  (?, ",
                                       " ?, ",
                                       " today, ",
                                       " current hour to minute, ",
                                       " ?) "                     
   prepare pcts50g00_01 from l_sql

   let l_sql = "delete from dbsmopgfas ",
               " where socopgnum = ? "
   prepare pcts50g00_02 from l_sql


   let l_sql = " select max(socopgfascod) ",
                 " from dbsmopgfas ",
                " where socopgnum = ? "
   prepare pcts50g00_03 from l_sql
   declare ccts50g00_03 cursor for pcts50g00_03

   let l_sql = " select 1 ",
                 " from dbsmopgfas ",
                " where socopgnum    = ? ",
                  " and socopgfascod = ? "
   prepare pcts50g00_04 from l_sql
   declare ccts50g00_04 cursor for pcts50g00_04

   let l_sql = " update dbsmopgfas ",
                  " set socopgfasdat = today, ",
                      " socopgfashor = current, ",
                      " funmat       = ? ",
                " where socopgnum    = ? ",
                  " and socopgfascod = ? "
   prepare pcts50g00_05 from l_sql

end function

#----------------------------------------#
function cts50g00_insere_etapa(lr_param)
#----------------------------------------#

   define lr_param record
                       socopgnum     like dbsmopgfas.socopgnum,
                       socopgfascod  like dbsmopgfas.socopgfascod,
                       funmat        like dbsmopgfas.funmat
                   end record

   define lr_retorno record
                         retorno   smallint,
                         mensagem  char(60)
                     end record

   call cts50g00_prepare()

   initialize lr_retorno.* to null

   whenever error continue
   execute pcts50g00_01 using lr_param.socopgnum,
                              lr_param.socopgfascod,
                              lr_param.funmat
   whenever error stop

   if  sqlca.sqlcode = 0 then
       let lr_retorno.retorno = 1
       let lr_retorno.mensagem = "Inclusao realizada com sucesso."
   else
       let lr_retorno.retorno = 2
       let lr_retorno.mensagem = "ERRO: ", sqlca.sqlcode, " na inclusao da Fase da OP."
   end if

   return lr_retorno.*

end function

#----------------------------------------#
function cts50g00_delete_etapa(lr_param)
#----------------------------------------#

   define lr_param record
                       socopgnum     like dbsmopgfas.socopgnum
                   end record

   define lr_retorno record
                         retorno   smallint,
                         mensagem  char(60)
                     end record

   call cts50g00_prepare()

   initialize lr_retorno.* to null

   whenever error continue
   execute pcts50g00_02 using lr_param.socopgnum
   whenever error stop

   if  sqlca.sqlcode = 0 then
       let lr_retorno.retorno = 1
       let lr_retorno.mensagem = "Exclusao realizada com sucesso."
   else
       let lr_retorno.retorno = 2
       let lr_retorno.mensagem = "ERRO:", sqlca.sqlcode, " na exclusao da Fase da OP."
   end if

   return lr_retorno.*

end function

#----------------------------------------#
function cts50g00_sel_max_etapa(lr_param)
#----------------------------------------#

   define lr_param record
                       socopgnum     like dbsmopgfas.socopgnum
                   end record

   define lr_retorno record
                         retorno      smallint,
                         mensagem     char(60),
                         socopgfascod like dbsmopgfas.socopgfascod
                     end record

   call cts50g00_prepare()

   initialize lr_retorno.* to null

   open ccts50g00_03 using lr_param.socopgnum
   whenever error continue
   fetch ccts50g00_03 into lr_retorno.socopgfascod
   whenever error stop
   
   case sqlca.sqlcode
        when 0
             let lr_retorno.retorno = 1
             let lr_retorno.mensagem = "Operacao realizada com sucesso."
        when 100
             let lr_retorno.retorno = 2
             let lr_retorno.mensagem = "Registro nao encontrado."
        otherwise
             let lr_retorno.retorno = 3
             let lr_retorno.mensagem = "ERRO:", sqlca.sqlcode, " SELECT MAX FASE (cts50g00)"
   end case

   return lr_retorno.*

end function

#-------------------------------------#
function cts50g00_sel_etapa(lr_param)
#-------------------------------------#

   define lr_param record
                       socopgnum     like dbsmopgfas.socopgnum,
                       socopgfascod  like dbsmopgfas.socopgfascod
                   end record

   define lr_retorno record
                         retorno   smallint,
                         mensagem  char(60)
                     end record

   define l_aux smallint

   call cts50g00_prepare()

   initialize lr_retorno.* to null

   open ccts50g00_04 using lr_param.socopgnum,
                           lr_param.socopgfascod
   whenever error continue
   fetch ccts50g00_04 into l_aux
   whenever error stop
   
   case sqlca.sqlcode
        when 0
             let lr_retorno.retorno = 1
             let lr_retorno.mensagem = "Registro encontrado com sucesso."
        when 100
             let lr_retorno.retorno = 2
             let lr_retorno.mensagem = "Registro nao encontrado."
        otherwise
             let lr_retorno.retorno = 3
             let lr_retorno.mensagem = "ERRO:", sqlca.sqlcode, " SELECT MAX FASE (cts50g00)"
   end case

   return lr_retorno.*

end function

#---------------------------------------------#
function cts50g00_insere_etapa_auto(lr_param)
#---------------------------------------------#

   define lr_param record
                       socopgnum     like dbsmopgfas.socopgnum,
                       funmat        like dbsmopgfas.funmat
                   end record

   define lr_retorno  record
                           retorno   smallint,
                           mensagem  char(60)
                       end record

   define l_retorno   smallint

   define l_ind  smallint,
          l_erro smallint

   call cts50g00_prepare()

   initialize lr_retorno.* to null
   let l_erro = false

   for l_ind = 1 to 3
       call cts50g00_insere_etapa(lr_param.socopgnum,
                                  l_ind,
                                  lr_param.funmat)
            returning l_retorno,
                      lr_retorno.mensagem

            if  l_retorno <> 1 then
                let l_erro = true
                exit for
            end if

   end for

   if  l_erro = false then
       let lr_retorno.retorno = 1
       let lr_retorno.mensagem = "Inclusao realizada com sucesso."
   else
       let lr_retorno.retorno = 2
   end if

   return lr_retorno.*

end function

#------------------------------------------#
function cts50g00_atualiza_etapa(lr_param)
#------------------------------------------#

   define lr_param record
                       socopgnum     like dbsmopgfas.socopgnum,
                       socopgfascod  like dbsmopgfas.socopgfascod,
                       funmat        like dbsmopgfas.funmat
                   end record

   define lr_retorno record
                         retorno   smallint,
                         mensagem  char(60)
                     end record

   call cts50g00_prepare()

   initialize lr_retorno.* to null

   whenever error continue
   execute pcts50g00_05 using lr_param.funmat,
                              lr_param.socopgnum,
                              lr_param.socopgfascod
   whenever error stop

   if  sqlca.sqlcode = 0 then
       let lr_retorno.retorno = 1
       let lr_retorno.mensagem = "Atualizacao realizada com sucesso."
   else
       let lr_retorno.retorno = 2
       let lr_retorno.mensagem = "ERRO:", sqlca.sqlcode, " na atualizacao da Fase da OP."
   end if

   return lr_retorno.*

end function
