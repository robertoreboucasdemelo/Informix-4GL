#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc98m01                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PR-2012-00808                                               #
# Objetivo......: Tela de cadastro do historico de valor referencia e peca    #
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao......: 26/09/2012                                                 #
#.............................................................................#
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- ------    -----------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql       smallint

#----------------------------------
 function ctc98m01_prepare()
#----------------------------------
   define l_sql char(300)

   let l_sql = "select socntzdes",  
               " from datksocntz   ",
               "where socntzcod = ?"

   prepare pctc98m01001 from l_sql
   declare cctc98m01001 cursor for pctc98m01001
   
   let l_sql = "select socntzcod   , ",
               "       empcod      , ",
               "       regcadhordat, ",
               "       hsttxt      , ",
               "       cadusrtip   , ",
               "       cademp      , ",
               "       cadmat        ",
               "  from dpampecrefvlrhst ",
               " where socntzcod = ? ", 
               "   and empcod = ? ",
               " order by regcadhordat desc"
   prepare pctc98m01002 from l_sql
   declare cctc98m01002 cursor for pctc98m01002
   
   
   let l_sql = "select empsgl  ",          
               " from gabkemp ",          
               "where empcod = ?"           
                                               
   prepare pctc98m01003 from l_sql             
   declare cctc98m01003 cursor for pctc98m01003
    
   
   let m_prep_sql = true

end function

#---------------------------------------------------------------
 function ctc98m01(l_socntzcod,l_empcod)
#---------------------------------------------------------------
   define l_socntzcod   like dpampecrefvlrhst.socntzcod,
          l_empcod      like dpampecrefvlrhst.empcod,
          l_socntzdes   like datksocntz.socntzdes,
          l_empsgl      like gabkemp.empsgl

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc98m01_prepare()
   end if

   open cctc98m01001 using l_socntzcod
   
   whenever error continue
   fetch cctc98m01001 into l_socntzdes
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Codigo nao encontrado'  sleep 2
      else
         error 'Erro SELECT cctc98m01001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
         error 'Historico / ctc98m01() / ', l_socntzcod  sleep 2
      end if

      return   
   end if
   
   open cctc98m01003 using l_empcod
   
   whenever error continue
   fetch cctc98m01003 into l_empsgl
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Codigo de assunto nao encontrado'  sleep 2
      else
         error 'Erro SELECT cctc98m01003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
         error 'Historico / ctc98m01() / ', l_empcod  sleep 2
      end if
   
      return   
   end if
  
   options
      insert key control-h
     ,delete key control-j

   open window ctc98m01 at 04,02 with form "ctc98m01"

   display l_socntzcod    to socntzcod      
   display l_socntzdes    to socntzdes         
   display l_empcod       to empcod         
   display l_empsgl       to empsgl            

   menu "HISTORICO"
        command key ("I") "Implementa" "Insere um novo item no historico"
           call ctc98m01_implementa(l_socntzcod,l_empcod)
           display l_socntzcod    to socntzcod   
           display l_socntzdes    to socntzdes 
           display l_empcod       to empcod    
           display l_empsgl       to empsgl    

        command key ("C") "Consulta" "Consulta historico"
           call ctc98m01_consulta(l_socntzcod,l_empcod)
           display l_socntzcod    to socntzcod   
           display l_socntzdes    to socntzdes 
           display l_empcod       to empcod    
           display l_empsgl       to empsgl    

        command key ("E") "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window ctc98m01
   let int_flag = false

   options
      insert key f1
     ,delete key f2

end function

#--------------------------------------
 function ctc98m01_implementa(l_socntzcod,l_empcod)
#--------------------------------------
    define l_socntzcod   like dpampecrefvlrhst.socntzcod,
           l_empcod      like dpampecrefvlrhst.empcod    

    define l_datahora datetime year to fraction

    define al_ctc98m01  array[200] of record
           texto          char(80)
    end record

    define l_arr_aux    smallint
    define l_scr_aux    smallint
    define l_srrhstseq  smallint
    define l_mensagem   char(70)
    define l_coderro    smallint
    define l_msg        char(100)
          ,l_resp       char(01)

    let l_arr_aux = null
    let l_scr_aux = null
    let l_srrhstseq = null
    let l_mensagem  = null
    let l_resp      = null

    if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc98m01_prepare()
   end if
    
    initialize al_ctc98m01  to  null

    while true
      input array al_ctc98m01 without defaults from s_ctc98m01.*

         before row
            let l_arr_aux = arr_curr()
            let l_scr_aux = scr_line()
  
         before field texto
            display al_ctc98m01[l_arr_aux].texto to s_ctc98m01[l_scr_aux].texto attribute (reverse)
  
         after field texto
            display al_ctc98m01[l_arr_aux].texto to s_ctc98m01[l_scr_aux].texto
  
            if fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("up")   then
               error " Alteracoes e/ou correcoes nao sao permitidas!"
               next field texto
            end if
  
            if al_ctc98m01[l_arr_aux].texto is null or
               al_ctc98m01[l_arr_aux].texto =  " "  then
               error "Informe o Complemento"
               next field texto
            end if
  
       after row
  
            let al_ctc98m01[l_arr_aux].texto = get_fldbuf(texto)
  
            if al_ctc98m01[l_arr_aux].texto is null  or
               al_ctc98m01[l_arr_aux].texto =  "  "  then
                next field texto
             else  
               
               begin work
               let l_datahora = current
               whenever error continue  
               insert into dpampecrefvlrhst values (l_socntzcod,
                                                    l_empcod,
                                                    l_datahora,
                                                    al_ctc98m01[l_arr_aux].texto,
                                                    g_issk.usrtip,
                                                    g_issk.empcod,
                                                    g_issk.funmat) 
               if sqlca.sqlcode = 0 then       
                  commit work
               else
                   error 'Erro na gravacao do historico:',sqlca.sqlcode sleep 2
                  rollback work 
               end if
               whenever error stop  
            end if
  
       on key(f17,control-c,interrupt)
          exit input
  
      end input

      if int_flag  then
	 let int_flag = false
         exit while
      end if

    end while

    display '            '  at 19,02
    clear form

end function

#--------------------------------------
 function ctc98m01_consulta(l_socntzcod,l_empcod)
#--------------------------------------
   define l_socntzcod   like dpampecrefvlrhst.socntzcod,
           l_empcod     like dpampecrefvlrhst.empcod   
 
   define lr_ctc98m01 record
       erro         smallint
      ,mensagem     char(200)
      ,socntzcod    like dpampecrefvlrhst.socntzcod 
      ,empcod       like dpampecrefvlrhst.empcod   
      ,regcadhordat like dpampecrefvlrhst.regcadhordat
      ,hsttxt       like dpampecrefvlrhst.hsttxt   
      ,cadusrtip    like dpampecrefvlrhst.cadusrtip   
      ,cademp       like dpampecrefvlrhst.cademp      
      ,cadmat       like dpampecrefvlrhst.cadmat      
   end record

   
   define al_ctc98m01  array[200] of record
          texto          char(80)
   end record

   define lr_retorno_c   record
        erro           smallint
       ,mensagem       char(60)
       ,funnom         like isskfunc.funnom
   end record

   define l_data_antes   datetime year to minute      
   define l_cadmat_antes like dpampecrefvlrhst.cadmat
   define l_data_agora   datetime year to minute 
   define l_data         date
   define l_hora         datetime hour to minute     
   define l_aux_linha    smallint
   define l_x            smallint

   let l_data_antes   = null
   let l_cadmat_antes = null
   let l_aux_linha    = 1
   let l_x            = 0

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc98m01_prepare()
   end if
   
   initialize al_ctc98m01  to  null
   
   open cctc98m01002 using l_socntzcod,l_empcod
   
   foreach cctc98m01002 into lr_ctc98m01.socntzcod   ,
                             lr_ctc98m01.empcod      ,
                             lr_ctc98m01.regcadhordat,
                             lr_ctc98m01.hsttxt      ,
                             lr_ctc98m01.cadusrtip   ,
                             lr_ctc98m01.cademp      ,   
                             lr_ctc98m01.cadmat      
                                           
       let l_x = l_x + 1 
          
       let l_data_agora = lr_ctc98m01.regcadhordat
       
       call cty08g00_nome_func(lr_ctc98m01.cademp
                              ,lr_ctc98m01.cadmat
                              ,lr_ctc98m01.cadusrtip)
          returning lr_retorno_c.erro
                   ,lr_retorno_c.mensagem
                   ,lr_retorno_c.funnom
       
       if l_data_antes is null                    or
          l_data_antes   <> l_data_agora or
          l_cadmat_antes <> lr_ctc98m01.cadmat then
       
          if l_data_antes is not null then
             let al_ctc98m01[l_aux_linha].texto = null
       
             let l_aux_linha = l_aux_linha + 1
             if l_aux_linha > 200 then
                continue foreach
             end if
          end if
          
          let l_data = l_data_agora
          let l_hora = l_data_agora
          
          let al_ctc98m01[l_aux_linha].texto = "Em: "  , l_data," ",l_hora
                                              ," Por: ", lr_retorno_c.funnom
          let l_aux_linha = l_aux_linha + 1
          if l_aux_linha > 200 then
              continue foreach
          end if
       end if
       
       let al_ctc98m01[l_aux_linha].texto = lr_ctc98m01.hsttxt
       let l_aux_linha = l_aux_linha + 1
       if l_aux_linha > 200 then
           continue foreach
       end if
       
       let l_data_antes   = lr_ctc98m01.regcadhordat
       let l_cadmat_antes = lr_ctc98m01.cadmat
       
       initialize lr_ctc98m01.* to null
   end foreach
   if l_aux_linha > 200 then
      error 'Numero de registros excedeu o limite'
   end if

   let l_aux_linha = l_aux_linha - 1

   if l_aux_linha = 0 then
      error 'Nenhum registro encontrado'
   else
      #display by name lr_ctc98m01.atdsrvorg

      call set_count(l_aux_linha)

      display array al_ctc98m01 to s_ctc98m01.*

         on key(f2,control-c,interrupt)
            exit display

      end display
   end if

   clear form

end function