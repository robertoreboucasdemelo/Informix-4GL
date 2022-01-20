#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS                                           #
# MODULO.........: cts12g02                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........:                                                            #
#-----------------------------------------------------------------------------#
#                  MODULO RESPONSAVEL POR OBTER GRUPO DA NATUREZA             #
#                  ATRAVES DA EMPRESA/ASSUNTO/NATUREZA                        #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 22/02/2008                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA      ORIGEM     ALTERACAO                          #
# ---------- --------------     ---------- -----------------------------------#
#-----------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"  

define m_cts12g02_prep smallint

#---------------------------#
function cts12g02_prepare()
#---------------------------#

   define l_sql_stmt  char(1000)

   let l_sql_stmt = " select 1, '', b.srvabrprsinfflg, b.srvacthorqtd, ",
                    "        b.atmacnatchorqtd, b.cliavsenvhorqtd ",
                    " from datrempgrp a, datrgrpntz b ",
                    " where a.socntzgrpcod = b.socntzgrpcod ",
                    " and a.empcod = ? ",
                    " and a.c24astcod =  ? ",
                    " and b.socntzcod =  ? "

   prepare pcts12g02001 from l_sql_stmt
   declare ccts12g02001 cursor for pcts12g02001   

   let m_cts12g02_prep = true

end function

#------- Obtem os parametros da natureza/empresa/assunto/grupo natureza ------#
function cts12g02_param(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          nivel_retorno    smallint
         ,empcod           like datrempgrp.empcod
         ,c24astcod        like datrempgrp.c24astcod
         ,socntzcod        like datrgrpntz.socntzcod
   end record  

   define lr_retorno       record 
          resultado        smallint
         ,mensagem         char(60)
         ,srvabrprsinfflg  like datrgrpntz.srvabrprsinfflg
         ,srvacthorqtd     like datrgrpntz.srvacthorqtd  
         ,atmacnatchorqtd  like datrgrpntz.atmacnatchorqtd
         ,cliavsenvhorqtd  like datrgrpntz.cliavsenvhorqtd
   end record  

   if m_cts12g02_prep is null or
      m_cts12g02_prep <> true then
      call cts12g02_prepare()
   end if  

   initialize lr_retorno.* to null

   open ccts12g02001 using lr_param.empcod
                          ,lr_param.c24astcod
                          ,lr_param.socntzcod

   whenever error continue
   fetch ccts12g02001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem = "Parametros nao encontrados em ccts12g02001"
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem = "Erro em ccts12g02001: ", sqlca.sqlcode
      end if
   end if   

   close ccts12g02001

   case lr_param.nivel_retorno
        when (1)
             return lr_retorno.resultado,
                    lr_retorno.mensagem,
                    lr_retorno.atmacnatchorqtd
   end case

end function
