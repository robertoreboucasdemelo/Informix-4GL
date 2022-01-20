#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cta02m07                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI           : 188425                                              #
# Objetivo      : Verifica se o assunto necessita exibir o ultimo con #
#                 dutor (cta02m07_condutor)                           #
#                 Eliminar/Criar tabela tmpcondutor                   #
#                (cta02m07_eliminar_tmp / cta02m07_criar_tmp          #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 28/10/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#
globals '/homedsa/projetos/geral/globals/glct.4gl'


#-----------------------------------#
function cta02m07_condutor(lr_param)
#-----------------------------------#

define lr_param             record
       cndslcflg            like datkassunto.cndslcflg
      ,succod               like abamapol.succod
      ,aplnumdig            like abamapol.aplnumdig
      ,itmnumdig            like abbmdoc.itmnumdig
      ,dctnumseq            like abbmdoc.dctnumseq
                            end record

define l_result             smallint
      ,l_mensagem           char(50)
      ,l_status             smallint
      ,l_mens               char(50)
   if lr_param.cndslcflg is null or
      lr_param.succod    is null or
      lr_param.aplnumdig is null or
      lr_param.itmnumdig is null or
      lr_param.dctnumseq is null then
      error "Parametros incorretos,(cta02m07_condutor())"
      let l_mensagem = "Parametros incorretos,(cta02m07_condutor())"
      sleep 1
      return 2, l_mensagem
   end if
   if lr_param.cndslcflg = 'N' then
      let l_result = 1
      let l_mensagem = null
      return l_result, l_mensagem
   end if
   call cty05g00_cls018(lr_param.succod   , lr_param.aplnumdig
                       ,lr_param.itmnumdig, lr_param.dctnumseq)

        returning l_result, l_mensagem
   if l_result = 1 then
      call cta02m07_criar_tmp() returning l_status, l_mens
      if l_status = 1 then
         call cta07m00(lr_param.succod, lr_param.aplnumdig
                      ,lr_param.itmnumdig,'I')
      end if
   end if

   return l_result, l_mensagem
end function

#------------------------------#
function cta02m07_eliminar_tmp()
#------------------------------#
define l_status          smallint
      ,l_mens            char(50)

   whenever error continue
   select 1
     from tmpcondutor
   whenever error stop
   if sqlca.sqlcode >= 0   or
      sqlca.sqlcode = -284 then
      whenever error continue
      drop table tmpcondutor
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let l_status = 3
         let l_mens   = "Erro no DROP da tabela TMPCONDUTOR ", sqlca.sqlcode, '/'
                                                             , sqlca.sqlerrd[2],'/'
                                                             , 'cta02m07_eliminar_tmp()'
         return l_status, l_mens
      end if
   else
      if sqlca.sqlcode <> - 206 then
         let l_status = 3
         let l_mens   = "Erro SELECT tabela TMPCONDUTOR ", sqlca.sqlcode, '/'
                                                         , sqlca.sqlerrd[2],'/'
                                                         , 'cta02m07_eliminar_tmp()'
         return l_status, l_mens
      end if
   end if
   let l_status = 1
   return l_status, l_mens
end function

#-----------------------------#
function cta02m07_criar_tmp()
#-----------------------------#
define l_status        smallint
      ,l_mens          char(50)

   whenever error continue
   create temp table tmpcondutor(flgcondutor      char(01) ,
                                 ctcdtnom         char(50) ,
                                 ctcgccpfnum      dec(12,0),
                                 ctcgccpfdig      dec(02,0)) with no log
   whenever error stop
   if sqlca.sqlcode = -310 or
      sqlca.sqlcode = -958 then
      whenever error continue
      delete from tmpcondutor
      whenever error stop
      if sqlca.sqlcode <> 0 then
         let l_status = 3
         let l_mens = "Erro DELETE TMPCONDUTOR ", sqlca.sqlcode , '/'
                                                , sqlca.sqlerrd[2],'/'
                                                ,"cta02m07_criar_tmp() "
         return l_status, l_mens
      end if
   end if

   let l_status = 1
   return l_status, l_mens
end function
