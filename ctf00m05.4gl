#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central de Atendimento                                    #
# Modulo.........: ctf00m05                                                  #
# Objetivo.......: Cadastro de novos corretores e consulta status            #
#                                                                            #
#                                                                            #
# Analista Resp. : Luiz Silva                                                #
# PSI            : 224499                                                    #
#............................................................................#
# Desenvolvimento: Eliane Ortiz, META                                        #
# Liberacao      : 04/08/2008                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# XX/XX/XXXX XXXXXX, META  XXXXXXXXX XXXXXXXXXX                              #
#----------------------------------------------------------------------------#

database porto

   define m_prep_ctf00m05  smallint


#----------------------------------------------------------
   function ctf00m05_prepare()
#----------------------------------------------------------

   define l_sql  char(500)

   let l_sql = 'select vigdat, vigincdat     '
              ,'  from dackcorsgm '
              ,' where corsus = ? '

   prepare pctf00m05001 from l_sql
   declare cctf00m05001 cursor for pctf00m05001
   
   let l_sql = 'insert into dackcorsgm( corsus   '
                               ,'     , caddat   '
                               ,'     , vigdat   '
                               ,'     , cadmat   '
                               ,'     , cademp   '
                               ,'     , cadtip   '
                               ,'     , atldat   '
                               ,'     , atlmat   '
                               ,'     , atlusrtip   '
                               ,'     , vigincdat ) '
              ,' values ( ?,?,?,?,?,?,today,?,?,?)  '
   
   prepare pctf00m05002 from l_sql
   
   let m_prep_ctf00m05 = true
   
   
end function


#----------------------------------------------------------
   function ctf00m05_status_corretor( l_corsus )
#----------------------------------------------------------

	define w_log char(60)
	
   define l_corsus like dackcorsgm.corsus   
   
   define lr_retorno record
                     stato   char(01) 
                   , errcod  smallint
                end record
   
   define l_msg    char(50)
        , l_vigdat like dackcorsgm.vigdat
        , l_vigincdat like dackcorsgm.vigincdat
   
   initialize lr_retorno to null
   
   let l_msg    = null
   let l_vigdat = null
   let l_vigincdat = null
   
   if m_prep_ctf00m05 is null or
      m_prep_ctf00m05 <> true then
      call ctf00m05_prepare()
   end if             

   let lr_retorno.errcod = 0
   
   open cctf00m05001 using l_corsus
   
   whenever error continue
   fetch cctf00m05001 into l_vigdat, l_vigincdat
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let l_msg = 'Data nao encontrada.'
         #call errorlog( l_msg )
         let lr_retorno.errcod = 1
         
      else
         let l_msg = 'Erro SELECT cctf00m05001 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
         #call errorlog( l_msg ) 
         let l_msg = 'CTF00M05 / ctf00m05_status_corretor() / ', l_corsus
         #call errorlog( l_msg )
         let lr_retorno.errcod = 2
      end if 
      let lr_retorno.stato  = null
      return lr_retorno. stato
           , lr_retorno.errcod
   end if

   if today >= l_vigincdat and today <= l_vigdat then
      let lr_retorno.stato = 'N'
   else
      let lr_retorno.stato = 'A'
   end if
   
   return lr_retorno.stato
        , lr_retorno.errcod

end function



#----------------------------------------------------------
   function ctf00m05_insere_corretor_compl( lr_param )
#----------------------------------------------------------

   define lr_param record
                   corsus like dackcorsgm.corsus
                 , caddat like dackcorsgm.caddat
                 , cadmat like dackcorsgm.cadmat
                 , cademp like dackcorsgm.cademp
                 , cadtip like dackcorsgm.cadtip
               end record
               
   define l_retorno   smallint
        , l_msg       char(50)
        , l_vigdatfnl like dackcorsgm.vigdat

        
   let l_retorno   = 0
   let l_msg       = null
   let l_vigdatfnl = null

   
   if m_prep_ctf00m05 is null or
      m_prep_ctf00m05 <> true then
      call ctf00m05_prepare()
   end if
   
   if lr_param.corsus is null then
      let l_retorno = 1
      return l_retorno
   end if
   
   let l_vigdatfnl = lr_param.caddat + 1 units year
   
   whenever error continue
   execute pctf00m05002 using lr_param.corsus
                            , lr_param.caddat
                            , l_vigdatfnl
                            , lr_param.cadmat
                            , lr_param.cademp	
                            , lr_param.cadtip
                            , lr_param.cadmat
                            , lr_param.cadtip
                            , lr_param.caddat
   whenever error stop
   
   if sqlca.sqlcode <> 0 then
      let l_msg = 'Erro INSERT pctf00m05002 / ', sqlca.sqlcode, ' | ', sqlca.sqlerrd[2]
      #call errorlog( l_msg )
      let l_msg = 'CTF00M05 / ctf00m05_insere_corretor_compl() / ', lr_param.corsus
                                                            ,' / ', lr_param.caddat
                                                            ,' / ', l_vigdatfnl    
                                                            ,' / ', lr_param.cadmat
                                                            ,' / ', lr_param.cademp
                                                            ,' / ', lr_param.cadtip
                                                            ,' / ', lr_param.caddat
      #call errorlog( l_msg )
      let l_retorno = 2
      return l_retorno
   end if
   
   return l_retorno

end function


