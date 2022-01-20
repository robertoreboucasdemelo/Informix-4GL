#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd20g04                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 198404                                                     #
#                  Modulo responsavel pelo acesso a tabela DBSMOPGFAV         #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#
database porto

define m_ctd20g04_prep smallint

#---------------------------#
function ctd20g04_prepare()
#---------------------------#
   define l_sql  char(1000)
   
   let l_sql = "select socopgfavnom, ",
                   "       cgccpfnum   , ",
                   "       cgcord      , ",
                   "       cgccpfdig   , ",
                   "       pestip      , ",
                   "       bcocod      , ",
                   "       bcoagnnum   , ",
                   "       bcoagndig   , ",
                   "       bcoctanum   , ",
                   "       bcoctadig   , ",
                   "       socpgtopccod  ",
                   "  from dbsmopgfav    ",
                   " where socopgnum = ? "
                         
   prepare pctd20g04001 from l_sql
   declare cctd20g04001 cursor with hold for pctd20g04001
   
   let m_ctd20g04_prep = true

end function

#-------------------------------------------------------#
function ctd20g04_dados_favop(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,socopgnum        like dbsmopgfav.socopgnum
   end record

   define lr_retorno       record
          socopgfavnom     like dbsmopgfav.socopgfavnom,
          cgccpfnum        like dbsmopgfav.cgccpfnum,
          cgcord           like dbsmopgfav.cgcord,
          cgccpfdig        like dbsmopgfav.cgccpfdig,
          pestip           like dbsmopgfav.pestip,
          bcocod           like dbsmopgfav.bcocod,
          bcoagnnum        like dbsmopgfav.bcoagnnum,
          bcoagndig        like dbsmopgfav.bcoagndig,
          bcoctanum        like dbsmopgfav.bcoctanum,
          bcoctadig        like dbsmopgfav.bcoctadig,
          socpgtopccod     like dbsmopgfav.socpgtopccod 
   end record

   define l_resultado   smallint,
          l_mensagem    char(60)

   if m_ctd20g04_prep is null or
      m_ctd20g04_prep <> true then
      call ctd20g04_prepare()
   end if  

   let l_resultado = 0
   let l_mensagem  = null
   initialize lr_retorno.* to null

   whenever error continue
   
   open  cctd20g04001 using lr_param.socopgnum
   fetch cctd20g04001 into  lr_retorno.*

   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2
         let l_mensagem = "Nao achou dados em dbsmopgfav "
      else
         let l_resultado = 3
         let l_mensagem = "Erro na selecao de dbsmopgfav ", sqlca.sqlcode
      end if
   end if

   close cctd20g04001

   if lr_param.nivel_retorno = 1 
      then
      return l_resultado, l_mensagem, 
             lr_retorno.socopgfavnom,
             lr_retorno.cgccpfnum   ,
             lr_retorno.cgcord      ,
             lr_retorno.cgccpfdig   ,
             lr_retorno.pestip      ,
             lr_retorno.bcocod      ,
             lr_retorno.bcoagnnum   ,
             lr_retorno.bcoagndig   ,
             lr_retorno.bcoctanum   ,
             lr_retorno.bcoctadig   ,
             lr_retorno.socpgtopccod
   end if
   
   if lr_param.nivel_retorno = 2
      then
      return l_resultado, l_mensagem, lr_retorno.pestip
   end if
   
end function

