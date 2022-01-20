#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd09g00                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI/OSF........: 211982                                                     #
#                  MODULO RESPONSA. PELO ACESSO A TABELA datmsrvorc           #
# ........................................................................... #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 19/09/2007 Luiz Alberto, Meta PSI211982 Inclusao das funcoes                #
#                                         ctd09g00_sel_orc, ctd09g00_alt_orc, #
#                                         ctd09g00_inc_orc                    #
# 26/09/2007 Perdices,     Meta PSI211982/lote 4                              #
#                                         Inclusao campo atznum na funcao -   #
#                                         ctd09g00_sel_orc                    #
#-----------------------------------------------------------------------------#

database porto

define m_ctd09g00_prep smallint

#---------------------------#
function ctd09g00_prepare()
#---------------------------#
   define l_sql_stmt  char(1000)
   
   let l_sql_stmt = "select orcvlr ",
                    " , atznum ", 
                    " , socntzcod ", 
                    " from datmsrvorc ",
                    " where atdsrvnum = ? ",
                      " and atdsrvano = ? "
   prepare pctd09g00001 from l_sql_stmt
   declare cctd09g00001 cursor for pctd09g00001   
   
   let l_sql_stmt = "update datmsrvorc set orcvlr = ? ",
                                    " where atdsrvnum = ? ",
                                      " and atdsrvano = ? "     
   prepare pctd09g00002 from l_sql_stmt                   

   let l_sql_stmt = "update datmsrvorc set atznum = ? ",
                                    " where atdsrvnum = ? ",
                                      " and atdsrvano = ? "     
   prepare pctd09g00004 from l_sql_stmt                   

   let l_sql_stmt = "update datmsrvorc set orcvlr = ?, ",
                                    "      atznum = ? ",
                                    " where atdsrvnum = ? ",
                                      " and atdsrvano = ? "     
   prepare pctd09g00005 from l_sql_stmt                   

   let l_sql_stmt = "insert into datmsrvorc (atdsrvnum ", 
                                          " ,atdsrvano ",  
                                          " ,orcvlr ", 
                                          " ,socntzcod ", 
                                          " ,rlzdat ", 
                                          " ,valdat ", 
                                          " ,atznum) ", 
                                 " values (?,?,?,?,?,?,?) "          
   prepare pctd09g00003 from l_sql_stmt                   

   let m_ctd09g00_prep = true
end function

#-------------------------------------------------------#
function ctd09g00_sel_orc(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmsrvorc.atdsrvnum     
         ,atdsrvano        like datmsrvorc.atdsrvano     
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)
         ,l_orcvlr         like datmsrvorc.orcvlr
         ,l_atznum         like datmsrvorc.atznum   
         ,l_socntzcod      like datmsrvorc.socntzcod

   if m_ctd09g00_prep is null or
      m_ctd09g00_prep <> true then
      call ctd09g00_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null
   let l_orcvlr    = null
   let l_atznum    = null
   let l_socntzcod = null

   open cctd09g00001 using lr_param.atdsrvnum
                          ,lr_param.atdsrvano
   
   whenever error continue
   fetch cctd09g00001 into l_orcvlr, l_atznum, l_socntzcod
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_resultado = 2                                  
         let l_mensagem = "Nao achou orcamento para este servico: ", lr_param.atdsrvnum, " / ", lr_param.atdsrvano
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a tabela datmsrvorc: ", sqlca.sqlcode
      end if
   end if

   if lr_param.nivel_retorno = 1 then
      return l_resultado
            ,l_mensagem
            ,l_orcvlr 
   end if
   
   if lr_param.nivel_retorno = 2 then
      return l_resultado
            ,l_mensagem
            ,l_orcvlr 
            ,l_atznum
   end if   

   if lr_param.nivel_retorno = 3 then
      return l_resultado
            ,l_mensagem
            ,l_atznum
   end if   

   if lr_param.nivel_retorno = 4 then
      return l_resultado
            ,l_mensagem
            ,l_socntzcod
            ,l_orcvlr
            ,l_atznum
   end if   

end function

#--------------------------------------------#
function ctd09g00_alt_orc(lr_param)
#--------------------------------------------#
   define lr_param         record
          nivel_retorno    smallint
         ,atdsrvnum        like datmsrvorc.atdsrvnum     
         ,atdsrvano        like datmsrvorc.atdsrvano     
         ,orcvlr           like datmsrvorc.orcvlr
         ,atznum           like datmsrvorc.atznum
         ,rlzdat           like datmsrvorc.rlzdat
         ,valdat           like datmsrvorc.valdat
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)

   if m_ctd09g00_prep is null or
      m_ctd09g00_prep <> true then
      call ctd09g00_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null

   if lr_param.nivel_retorno = 1 then
      whenever error continue
      execute pctd09g00002 using lr_param.orcvlr
                                ,lr_param.atdsrvnum   
                                ,lr_param.atdsrvano   
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         let l_resultado = 3
         let l_mensagem  = "Erro na atualizacao de datmsrvorc.orclvr: ", sqlca.sqlcode
      end if      
   
      return l_resultado, l_mensagem
   end if   

   if lr_param.nivel_retorno = 2 then
      whenever error continue
      execute pctd09g00005 using lr_param.orcvlr
                                ,lr_param.atznum
                                ,lr_param.atdsrvnum   
                                ,lr_param.atdsrvano   
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         let l_resultado = 3
         let l_mensagem  = "Erro na atualizacao de datmsrvorc.orclvr/atznum: ", sqlca.sqlcode
      end if      
   
      return l_resultado, l_mensagem
   end if   

end function

#---------------------------------------------#
function ctd09g00_inc_orc(lr_param)
#---------------------------------------------#
   define lr_param         record
          atdsrvnum        like datmsrvorc.atdsrvnum     
         ,atdsrvano        like datmsrvorc.atdsrvano     
         ,socntzcod        like datmsrvorc.socntzcod
         ,rlzdat           like datmsrvorc.rlzdat
         ,orcvlr           like datmsrvorc.orcvlr
         ,valdat           like datmsrvorc.valdat
         ,atznum           like datmsrvorc.atznum 
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)

   if m_ctd09g00_prep is null or
      m_ctd09g00_prep <> true then
      call ctd09g00_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null

   if lr_param.atdsrvnum  is null or lr_param.atdsrvano  is null or 
      lr_param.orcvlr     is null or lr_param.socntzcod  is null or
      lr_param.rlzdat     is null or lr_param.valdat     is null or
      lr_param.atznum     is null then
      let l_resultado = 3
      let l_mensagem = "Parametros nulos p/incluir orcamento"
   else
      whenever error continue
      execute pctd09g00003 using lr_param.atdsrvnum 
                                ,lr_param.atdsrvano    
                                ,lr_param.orcvlr    
                                ,lr_param.socntzcod 
                                ,lr_param.rlzdat
                                ,lr_param.valdat
                                ,lr_param.atznum
      whenever error stop
      
      if sqlca.sqlcode <> 0 then
         let l_resultado = 3
         let l_mensagem = "Erro na inclusao de datmsrvorc: ", sqlca.sqlcode
      end if
   end if

   return l_resultado, l_mensagem
end function

#-------------------------------------------------------#
function ctd09g00_sol_nr_atz(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          atdsrvnum        like datmsrvorc.atdsrvnum     
         ,atdsrvano        like datmsrvorc.atdsrvano     
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)
         ,l_atznum         like datmsrvorc.atznum

   let l_resultado = 1
   let l_mensagem  = null

   if m_ctd09g00_prep is null or
      m_ctd09g00_prep <> true then
      call ctd09g00_prepare()
   end if  

   call ctd09g00_sel_orc(3, lr_param.atdsrvnum, lr_param.atdsrvano)
        returning l_resultado, l_mensagem, l_atznum

   if l_resultado <> 1 then
      error l_mensagem 
      return
   end if

   open window t_atz at 15,20 with 04 rows, 40 columns    
        attribute (form line 1, prompt line 3, border)

   let l_resultado = 1
   let l_mensagem  = null

   while true
      prompt "INFORME NR. AUTORIZACAO: " for l_atznum 
      if l_atznum is not null then
         exit while
      end if
   end while

   whenever error continue
   execute pctd09g00004 using l_atznum
                             ,lr_param.atdsrvnum   
                             ,lr_param.atdsrvano   
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      let l_resultado = 3
      let l_mensagem  = "Erro na atualizacao de datmsrvorc.atznum: ", sqlca.sqlcode
   end if      

   close window t_atz
   return

end function

#-------------------------------------------------------#
function ctd09g00_con_nr_atz(lr_param)
#-------------------------------------------------------#
   define lr_param         record
          atdsrvnum        like datmsrvorc.atdsrvnum     
         ,atdsrvano        like datmsrvorc.atdsrvano     
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)
         ,l_char           char(1)
         ,l_atznum         like datmsrvorc.atznum

   let l_resultado = 1
   let l_mensagem  = null
   let l_char  = null
   let l_atznum  = null

   if m_ctd09g00_prep is null or
      m_ctd09g00_prep <> true then
      call ctd09g00_prepare()
   end if  

   call ctd09g00_sel_orc(3, lr_param.atdsrvnum, lr_param.atdsrvano)
        returning l_resultado, l_mensagem, l_atznum

   if l_resultado <> 1 then
      error l_mensagem 
      return
   end if

   open window c_atz at 11,25 with 03 rows, 40 columns    
        attribute (form line 1, prompt line 3, border)

   let l_resultado = 1
   let l_mensagem  = null

   display  "NR. DA AUTORIZACAO: ", l_atznum at 2,2
   prompt "" for l_char

   close window c_atz
   return

end function

#--------------------------------------------#
function ctd09g00_atu_atznum (lr_param)
#--------------------------------------------#
   define lr_param         record
          atdsrvnum        like datmsrvorc.atdsrvnum     
         ,atdsrvano        like datmsrvorc.atdsrvano     
         ,atznum           like datmsrvorc.atznum
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)

   if m_ctd09g00_prep is null or
      m_ctd09g00_prep <> true then
      call ctd09g00_prepare()
   end if  

   let l_resultado = 1
   let l_mensagem  = null

   whenever error continue
   execute pctd09g00004 using lr_param.atznum
                             ,lr_param.atdsrvnum   
                             ,lr_param.atdsrvano   
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      let l_resultado = 3
      let l_mensagem  = "Erro na atualizacao de datmsrvorc.atznum: ", sqlca.sqlcode
   end if      

   return l_resultado, l_mensagem

end function
