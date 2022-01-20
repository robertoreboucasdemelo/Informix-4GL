#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc93m02                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00287/EV                                           #
# Objetivo......: Tela de cadastro do historico de de/para de origens         #
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao......: 16/01/2012                                                 #
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
 function ctc93m02_prepare()
#----------------------------------
   define l_sql char(300)

   let l_sql = "select srvtipabvdes",  
               " from datksrvtip   ",
               "where atdsrvorg = ?"

   prepare pctc93m02001 from l_sql
   declare cctc93m02001 cursor for pctc93m02001
   
   let l_sql = "select atdsrvorg   , ",
               "       regcadhordat, ",
               "       cadhsttxt   , ",
               "       cadusrtip   , ",
               "       cademp      , ",
               "       cadmat        ",
               "  from datkdcrorghst ",
               " where atdsrvorg = ? ", 
               "   and c24astcod = ? ",
               " order by regcadhordat desc"
   prepare pctc93m02002 from l_sql
   declare cctc93m02002 cursor for pctc93m02002
   
   
   let l_sql = "select c24astdes  ",          
               " from datkassunto ",          
               "where c24astcod = ?"           
                                               
   prepare pctc93m02003 from l_sql             
   declare cctc93m02003 cursor for pctc93m02003
    
   
   let m_prep_sql = true

end function

#---------------------------------------------------------------
 function ctc93m02(l_atdsrvorg,l_c24astcod)
#---------------------------------------------------------------
   define l_atdsrvorg   like datkdcrorghst.atdsrvorg,
          l_c24astcod   like datkdcrorghst.c24astcod,
          l_descricao   char(50),
          l_c24astdes   like datkassunto.c24astdes

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc93m02_prepare()
   end if

   open cctc93m02001 using l_atdsrvorg
   
   whenever error continue
   fetch cctc93m02001 into l_descricao
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         error 'Codigo nao encontrado'  sleep 2
      else
         error 'Erro SELECT cctc93m02001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
         error 'Historico / ctc93m02() / ', l_atdsrvorg  sleep 2
      end if

      return   
   end if
   
  if l_c24astcod <> 'ZZZ' then
      open cctc93m02003 using l_c24astcod
      
      whenever error continue
      fetch cctc93m02003 into l_c24astdes
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = notfound then
            error 'Codigo de assunto nao encontrado'  sleep 2
         else
            error 'Erro SELECT cctc93m02003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
            error 'Historico / ctc93m02() / ', l_atdsrvorg  sleep 2
         end if
     
         return   
      end if
  else
    let l_c24astdes = "INDIFERENTE"
  end if  

   options
      insert key control-h
     ,delete key control-j

   open window ctc93m02 at 04,02 with form "ctc93m02"

   display l_atdsrvorg    to atdsrvorg
   display l_descricao    to descricao
   display l_c24astcod    to c24astcod
   display l_c24astdes    to c24astdes

   menu "HISTORICO"
        command key ("I") "Implementa" "Insere um novo item de ctc93m02 para a atdsrvorg selecionada"
           call ctc93m02_implementa(l_atdsrvorg,l_c24astcod)
           display l_atdsrvorg    to atdsrvorg   
           display l_descricao    to descricao 
           display l_c24astcod    to c24astcod
           display l_c24astdes    to c24astdes

        command key ("C") "Consulta" "Consulta ctc93m02 da atdsrvorg selecionada"
           call ctc93m02_consulta(l_atdsrvorg,l_c24astcod)
           display l_atdsrvorg    to atdsrvorg   
           display l_descricao    to descricao
           display l_c24astcod    to c24astcod
           display l_c24astdes    to c24astdes

        command key ("E") "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window ctc93m02
   let int_flag = false

   options
      insert key f1
     ,delete key f2

end function

#--------------------------------------
 function ctc93m02_implementa(l_atdsrvorg,l_c24astcod)
#--------------------------------------
    define l_atdsrvorg   like datkdcrorghst.atdsrvorg 
    define l_c24astcod   like datkdcrorghst.c24astcod 

    define l_datahora datetime year to fraction

    define al_ctc93m02  array[200] of record
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
      call ctc93m02_prepare()
   end if
    
    initialize al_ctc93m02  to  null

    while true
      input array al_ctc93m02 without defaults from s_ctc93m02.*

         before row
            let l_arr_aux = arr_curr()
            let l_scr_aux = scr_line()
  
         before field texto
            display al_ctc93m02[l_arr_aux].texto to s_ctc93m02[l_scr_aux].texto attribute (reverse)
  
         after field texto
            display al_ctc93m02[l_arr_aux].texto to s_ctc93m02[l_scr_aux].texto
  
            if fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("up")   then
               error " Alteracoes e/ou correcoes nao sao permitidas!"
               next field texto
            end if
  
            if al_ctc93m02[l_arr_aux].texto is null or
               al_ctc93m02[l_arr_aux].texto =  " "  then
               error "Informe o Complemento"
               next field texto
            end if
  
       after row
  
            let al_ctc93m02[l_arr_aux].texto = get_fldbuf(texto)
  
            if al_ctc93m02[l_arr_aux].texto is null  or
               al_ctc93m02[l_arr_aux].texto =  "  "  then
                next field texto
             else  
               
               begin work
               let l_datahora = current
               whenever error continue  
               insert into datkdcrorghst values (l_atdsrvorg,
                                                 l_c24astcod,
                                                 l_datahora,
                                                 al_ctc93m02[l_arr_aux].texto,
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
 function ctc93m02_consulta(l_atdsrvorg,l_c24astcod)
#--------------------------------------
   define l_atdsrvorg   like datkdcrorghst.atdsrvorg
   define l_c24astcod   like datkdcrorghst.c24astcod 
 
   define lr_ctc93m02 record
       erro         smallint
      ,mensagem     char(200)
      ,atdsrvorg    like datkdcrorghst.atdsrvorg   
      ,regcadhordat like datkdcrorghst.regcadhordat
      ,cadhsttxt    like datkdcrorghst.cadhsttxt   
      ,cadusrtip    like datkdcrorghst.cadusrtip   
      ,cademp       like datkdcrorghst.cademp      
      ,cadmat       like datkdcrorghst.cadmat      
   end record

   
   define al_ctc93m02  array[200] of record
          texto          char(80)
   end record

   define lr_retorno_c   record
        erro           smallint
       ,mensagem       char(60)
       ,funnom         like isskfunc.funnom
   end record

   define l_data_antes   datetime year to minute      
   define l_cadmat_antes like datkdcrorghst.cadmat
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
      call ctc93m02_prepare()
   end if
   
   initialize al_ctc93m02  to  null
   
   open cctc93m02002 using l_atdsrvorg,l_c24astcod
   
   foreach cctc93m02002 into lr_ctc93m02.atdsrvorg   ,
                             lr_ctc93m02.regcadhordat,
                             lr_ctc93m02.cadhsttxt   ,
                             lr_ctc93m02.cadusrtip   ,
                             lr_ctc93m02.cademp      ,
                             lr_ctc93m02.cadmat 
              
       let l_x = l_x + 1 
          
       let l_data_agora = lr_ctc93m02.regcadhordat
       
       call cty08g00_nome_func(lr_ctc93m02.cademp
                              ,lr_ctc93m02.cadmat
                              ,lr_ctc93m02.cadusrtip)
          returning lr_retorno_c.erro
                   ,lr_retorno_c.mensagem
                   ,lr_retorno_c.funnom
       
       if l_data_antes is null                    or
          l_data_antes   <> l_data_agora or
          l_cadmat_antes <> lr_ctc93m02.cadmat then
       
          if l_data_antes is not null then
             let al_ctc93m02[l_aux_linha].texto = null
       
             let l_aux_linha = l_aux_linha + 1
             if l_aux_linha > 200 then
                continue foreach
             end if
          end if
          
          let l_data = l_data_agora
          let l_hora = l_data_agora
          
          let al_ctc93m02[l_aux_linha].texto = "Em: "  , l_data," ",l_hora
                                              ," Por: ", lr_retorno_c.funnom
          let l_aux_linha = l_aux_linha + 1
          if l_aux_linha > 200 then
              continue foreach
          end if
       end if
       
       let al_ctc93m02[l_aux_linha].texto = lr_ctc93m02.cadhsttxt
       let l_aux_linha = l_aux_linha + 1
       if l_aux_linha > 200 then
           continue foreach
       end if
       
       let l_data_antes   = lr_ctc93m02.regcadhordat
       let l_cadmat_antes = lr_ctc93m02.cadmat
       
       initialize lr_ctc93m02.* to null
   end foreach
   if l_aux_linha > 200 then
      error 'Numero de registros excedeu o limite'
   end if

   let l_aux_linha = l_aux_linha - 1

   if l_aux_linha = 0 then
      error 'Nenhum registro encontrado'
   else
      #display by name lr_ctc93m02.atdsrvorg

      call set_count(l_aux_linha)

      display array al_ctc93m02 to s_ctc93m02.*

         on key(f2,control-c,interrupt)
            exit display

      end display
   end if

   clear form

end function

#------------------------------------------------------------
 function ctc93m02_contabil()
#------------------------------------------------------------

define a_ctc40m00  record      
    movimento char(50) 
 end record  

 let a_ctc40m00.movimento = ""


open window hist_cont at 04,02 with form "hist_cont"
display by name a_ctc40m00.*
menu "Historio"
 
 command key ("S") "Inclui"
                   "Inclui ctc93m02 de/para de contabilizacao"
                   message " "
                   
 command key ("P") "Consulta"
                   "Consulta ctc93m02 de/para de contabilizacao"
                   message " " 
 
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

  close window hist_cont
  
end function
