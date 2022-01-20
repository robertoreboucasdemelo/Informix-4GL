#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd19g03                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DATMAVISRENT       #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd19g03_prep smallint

#---------------------------#
function ctd19g03_prepare()
#---------------------------#
   define l_sql_stmt  char(300)
   
   let l_sql_stmt = " select avialgmtv, avioccdat, slcsuccod, ",
                    "        slccctcod, aviprvent ",
                    " from datmavisrent ",
                    " where datmavisrent.atdsrvnum = ? ",
                    "   and datmavisrent.atdsrvano = ? "
   prepare pctd19g03001 from l_sql_stmt
   declare cctd19g03001 cursor for pctd19g03001   
   
   let m_ctd19g03_prep = true

end function

#-------------------------------------------------------#
function ctd19g03_dados_rent(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmavisrent.atdsrvnum
         ,atdsrvano        like datmavisrent.atdsrvano
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   define lr_retorno  record
          avialgmtv   like datmavisrent.avialgmtv, 
          avioccdat   like datmavisrent.avioccdat,  
          slcsuccod   like datmavisrent.slcsuccod,
          slccctcod   like datmavisrent.slccctcod, 
          aviprvent   like datmavisrent.aviprvent  
          end record

   if m_ctd19g03_prep is null or
      m_ctd19g03_prep <> true then
      call ctd19g03_prepare()
   end if  

   let l_resultado = null
   let l_mensagem  = null
   initialize lr_retorno.* to null

   open cctd19g03001 using lr_param.atdsrvnum, lr_param.atdsrvano
   
   whenever error continue
   fetch cctd19g03001 into lr_retorno.*
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2                                  
         let l_mensagem = "Nao achou dados em datmavisrent"
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a datmavisrent ", sqlca.sqlcode
      end if
   end if

   close cctd19g03001

   if lr_param.nivel_retorno = 1 then
      return l_resultado,
             l_mensagem,
             lr_retorno.avialgmtv,
             lr_retorno.avioccdat,
             lr_retorno.slcsuccod,
             lr_retorno.slccctcod,
             lr_retorno.aviprvent
   end if

end function

