#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ............................................................................#
# Sistema.......: Radar / Porto Socorro                                       #
# Modulo........: ctd18g01.4gl                                                #
# Analista Resp.: Debora Vaz Paez                                             #
# PSI...........: 220710                                                      #
# Objetivo......: Criar um novo programa que ficara responsavel pelos acessos #
# a tabela de historico de socorrista                                         #
#.............................................................................#
# Desenvolvimento: Rafael Haas, META                                          #
# Liberacao......: 22/04/2008                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ----------------------------------- #
# 18/11/2010 Robert Lima(Araguia)CT 02086 Alterado o errorlog para display    #
#-----------------------------------------------------------------------------#

database porto

define m_prep_sql   smallint

#----------------------------------#
function ctd18g01_prepare()
#----------------------------------#

define l_sql  char(500)

   let l_sql = 'select srrcoddig              '
              ,',srrhstseq                    '
              ,',srrhsttxt                    '
              ,',caddat                       '
              ,',cademp                       '
              ,',cadmat                       '
              ,',cadusrtip                    '
              ,'from datmsrrhst               '
              ,'where srrcoddig = ?           '
              ,'order by caddat desc,srrhstseq '
   prepare pctd18g01001 from l_sql
   declare cctd18g01001 scroll cursor for pctd18g01001
   let l_sql =  'insert into datmsrrhst'
              , ' (srrcoddig   '
              , ' ,srrhstseq   '
              , ' ,srrhsttxt   '
              , ' ,caddat      '
              , ' ,cademp      '
              , ' ,cadmat      '
              , ' ,cadusrtip)  '
              , ' values (?,?,?,?,?,?,?)'
   prepare pctd18g01002 from l_sql
   let l_sql = 'select max(srrhstseq)'
              ,'  from datmsrrhst '
              ,'  where srrcoddig = ? '

   prepare pctd18g01003 from l_sql
   declare cctd18g01003 cursor for pctd18g01003
   let m_prep_sql = true
end function

#--------------------------------------------------#
function ctd18g01_consult_hist(l_srrcoddig, l_nro)
#--------------------------------------------------#
   define l_srrcoddig like datmsrrhst.srrcoddig
         ,l_nro       integer
   define l_msg       char(200)
   define lr_retorno record
                     erro       smallint
                    ,mensagem   char(200)
                    ,srrcoddig  like datmsrrhst.srrcoddig
                    ,srrhstseq  like datmsrrhst.srrhstseq
                    ,srrhsttxt  like datmsrrhst.srrhsttxt
                    ,caddat     like datmsrrhst.caddat
                    ,cademp     like datmsrrhst.cademp
                    ,cadmat     like datmsrrhst.cadmat
                    ,cadusrtip  like datmsrrhst.cadusrtip
                     end record
   initialize lr_retorno to null
   if l_srrcoddig is null then
      let lr_retorno.erro = 3
      let lr_retorno.mensagem = 'Parametro nulo'
      return lr_retorno.*
   end if
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g01_prepare()
   end if
   open cctd18g01001 using l_srrcoddig
   whenever error continue
   fetch relative l_nro cctd18g01001 into lr_retorno.srrcoddig
                                         ,lr_retorno.srrhstseq
                                         ,lr_retorno.srrhsttxt
                                         ,lr_retorno.caddat
                                         ,lr_retorno.cademp
                                         ,lr_retorno.cadmat
                                         ,lr_retorno.cadusrtip
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.erro = 2
         let lr_retorno.mensagem = 'socorrista nao encontrado'
      else
         let l_msg = 'erro SELECT cctd18g01001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
         display l_msg
         let l_msg = 'CCTD18G01 / ctd18g01_consult_hist() / ',lr_retorno.srrcoddig ,' / '
                                                             ,lr_retorno.srrhstseq ,' / '
                                                             ,lr_retorno.srrhsttxt ,' / '
                                                             ,lr_retorno.caddat ,' / '
                                                             ,lr_retorno.cademp ,' / '
                                                             ,lr_retorno.cadmat ,' / '
                                                             ,lr_retorno.cadusrtip
         display l_msg
         let lr_retorno.erro = 3
         let lr_retorno.mensagem = 'ERRO ', sqlca.sqlcode, ' em datmsrrhst'
      end if
   else
      let lr_retorno.erro = 1
   end if
   return lr_retorno.*
end function
#----------------------------------#
function ctd18g01_grava_hist(lr_param)
#----------------------------------#

   define l_msg  char(200)
   define l_coderro smallint
         ,l_srrhstseq  like  datmsrrhst.srrhstseq
   define lr_param record
         srrcoddig  like  datmsrrhst.srrcoddig
        ,srrhsttxt  like  datmsrrhst.srrhsttxt
        ,caddat     like  datmsrrhst.caddat
        ,cademp     like  datmsrrhst.cademp
        ,cadmat     like  datmsrrhst.cadmat
        ,cadusrtip  like  datmsrrhst.cadusrtip
   end record

   let l_coderro = 1
   let l_msg = null

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g01_prepare()
   end if
   call ctd18g01_max_seq_hist(lr_param.srrcoddig)
   returning l_coderro
            ,l_msg
            ,l_srrhstseq

   let l_srrhstseq = l_srrhstseq + 1
   whenever error continue
   execute pctd18g01002 using lr_param.srrcoddig
                             ,l_srrhstseq
                             ,lr_param.srrhsttxt
                             ,lr_param.caddat
                             ,lr_param.cademp
                             ,lr_param.cadmat
                             ,lr_param.cadusrtip
   whenever error stop

   if sqlca.sqlcode <> 0 then
      let l_msg = 'erro ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
      display l_msg
      let l_coderro = 3
      let l_msg     = 'ERRO ', sqlca.sqlcode, ' em datmsrrhst'
   else
      let l_coderro = 1
      let l_msg     = null
   end if
   return l_coderro
          ,l_msg	

end function

#------------------------------------------#
function ctd18g01_max_seq_hist(l_srrcoddig)
#------------------------------------------#
  define l_srrcoddig like datmsrrhst.srrcoddig
        ,l_srrhstseq like datmsrrhst.srrhstseq
        ,l_coderro smallint
        ,l_msg  char(200)
  if m_prep_sql is null or
      m_prep_sql <> true then
      call ctd18g01_prepare()
   end if

   let l_srrhstseq = 0
   let l_coderro = 1
   let l_msg = null
   whenever error continue
   open cctd18g01003 using l_srrcoddig
   fetch cctd18g01003 into l_srrhstseq

   if sqlca.sqlcode <> 0 and sqlca.sqlcode <> notfound then
      let l_coderro = 3
      let l_msg = 'ERRO ', sqlca.sqlcode, ' em datmsrrhst'
   else
      let l_coderro = 1
   end if

   if l_srrhstseq is null then
      let l_srrhstseq = 0
   end if

   return l_coderro ,l_msg ,l_srrhstseq
end function
