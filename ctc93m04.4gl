#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc93m04                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00289/EV                                           #
# Objetivo......: Tela de cadastro do historico de de/para de motivos         #
#.............................................................................#
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

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql       smallint

#----------------------------------
 function ctc93m04_prepare()
#----------------------------------
   define l_sql char(300)

   let l_sql = "select cpodes                      ",
               "  from iddkdominio                 ",
               " where cponom = 'avialgmtv_empresa'",
               "   and cpocod =? "
   prepare pctc93m04001 from l_sql
   declare cctc93m04001 cursor for pctc93m04001
               
   let l_sql = "select cpodes     ",
               "  from iddkdominio",
               " where cponom = ?",
               "   and cpocod =? "
   prepare pctc93m04002 from l_sql
   declare cctc93m04002 cursor for pctc93m04002
   
   let l_sql = "select atdsrvorg   , ",
               "       ciaempcod   , ",
               "       avialgmtv   , ",
               "       regcadhordat, ",
               "       cadhsttxt   , ",
               "       cadusrtip   , ",
               "       cademp      , ",
               "       cadmat        ",
               "  from datkalgmtvhst ",
               " where atdsrvorg = ? ",
               "   and ciaempcod = ? ",
               "   and avialgmtv = ? ",
               " order by regcadhordat desc"
   prepare pctc93m04003 from l_sql
   declare cctc93m04003 cursor for pctc93m04003
   
   
   let m_prep_sql = true

end function

#---------------------------------------------------------------
 function ctc93m04(param)
#---------------------------------------------------------------
   define param         record
         atdsrvorg      like  datkalgmtvhst.atdsrvorg   ,
         srvtipabvdes   like  datksrvtip.srvtipabvdes,
         avialgmtv      like  datkalgmtvhst.avialgmtv   ,
         avialgmtvdes   like  iddkdominio.cponom,
         ciaempcod      like  datkalgmtvhst.ciaempcod   ,
         empsgl         like  gabkemp.empsgl      
     end record
     
   define l_cpodes_emp  like iddkdominio.cpodes 
   define l_cpodes      like iddkdominio.cpodes

   
   options
      insert key control-h
     ,delete key control-j

   open window ctc93m04 at 04,02 with form "ctc93m04"
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc93m04_prepare()
   end if
   
   display param.srvtipabvdes     to srvtipabvdes 
   display param.empsgl       to empsgl    
   display param.avialgmtvdes   to avialgmtvdes

   menu "HISTORICO"
        command key ("I") "Implementa" "Insere um novo item de historico para o motivo selecionado"
           call ctc93m04_implementa(param.atdsrvorg,param.avialgmtv,param.ciaempcod)
           display param.srvtipabvdes     to srvtipabvdes  
           display param.empsgl           to empsgl    
           display param.avialgmtvdes     to avialgmtvdes
           
           

        command key ("C") "Consulta" "Consulta historico do motivo selecionado"
           call ctc93m04_consulta(param.atdsrvorg,param.avialgmtv,param.ciaempcod)
           display param.srvtipabvdes     to srvtipabvdes  
           display param.empsgl           to empsgl    
           display param.avialgmtvdes     to avialgmtvdes
           

        command key ("E") "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window ctc93m04
   let int_flag = false

   options
      insert key f1
     ,delete key f2

end function

#--------------------------------------
 function ctc93m04_implementa(param)
#--------------------------------------
    define param         record
         atdsrvorg      like  datkalgmtvhst.atdsrvorg   ,
         avialgmtv      like  datkalgmtvhst.avialgmtv   ,
         ciaempcod      like  datkalgmtvhst.ciaempcod   
     end record
     
   define l_cpodes_emp  like iddkdominio.cpodes 
   define l_cpodes      like iddkdominio.cpodes

    define l_datahora datetime year to fraction
    
    define al_ctc93m04  array[200] of record
           texto          char(80)
    end record

    define lr_retorno_i record
        erro         smallint
       ,mensagem     char(60)
       ,funnom       like isskfunc.funnom
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
      call ctc93m04_prepare()
   end if
    
    initialize al_ctc93m04  to  null

    call cty08g00_nome_func(g_issk.empcod,
                            g_issk.funmat,
                            g_issk.usrtip)

       returning lr_retorno_i.erro,
                 lr_retorno_i.mensagem,
                 lr_retorno_i.funnom

    while true
      input array al_ctc93m04 without defaults from s_ctc93m04.*

         before row
            let l_arr_aux = arr_curr()
            let l_scr_aux = scr_line()
  
         before field texto
            display al_ctc93m04[l_arr_aux].texto to s_ctc93m04[l_scr_aux].texto attribute (reverse)
  
         after field texto
            display al_ctc93m04[l_arr_aux].texto to s_ctc93m04[l_scr_aux].texto
  
            if fgl_lastkey() = fgl_keyval("left") or
               fgl_lastkey() = fgl_keyval("up")   then
               error " Alteracoes e/ou correcoes nao sao permitidas!"
               next field texto
            end if
  
            if al_ctc93m04[l_arr_aux].texto is null or
               al_ctc93m04[l_arr_aux].texto =  " "  then
               error "Informe o Complemento"
               next field texto
            end if
  
       after row
  
            let al_ctc93m04[l_arr_aux].texto = get_fldbuf(texto)
  
            if al_ctc93m04[l_arr_aux].texto is null  or
               al_ctc93m04[l_arr_aux].texto =  "  "  then
                next field texto
             else  
  
               begin work
               
               let l_datahora = current
              whenever error continue  
               insert into datkalgmtvhst values (param.atdsrvorg, 
                                                 param.ciaempcod,
                                                 param.avialgmtv,
                                                 l_datahora,
                                                 al_ctc93m04[l_arr_aux].texto,
                                                 g_issk.usrtip,
                                                 g_issk.empcod,
                                                 g_issk.funmat) 
               if sqlca.sqlcode = 0 then       
                  commit work
               else
                   error 'Erro na gravacao do historico' sleep 2
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

    #display '            '  at 19,02
    clear form

end function

#--------------------------------------
 function ctc93m04_consulta(param)
#--------------------------------------
   define param         record
         atdsrvorg      like  datkalgmtvhst.atdsrvorg   ,
         avialgmtv      like  datkalgmtvhst.avialgmtv   ,
         ciaempcod      like  datkalgmtvhst.ciaempcod   
     end record
     
   define l_cpodes_emp  like iddkdominio.cpodes 
   define l_cpodes      like iddkdominio.cpodes

   define lr_ctc93m04 record
       erro         smallint
      ,mensagem     char(200)
      ,atdsrvorg    like datkalgmtvhst.atdsrvorg   
      ,ciaempcod    like datkalgmtvhst.ciaempcod   
      ,avialgmtv    like datkalgmtvhst.avialgmtv   
      ,regcadhordat like datkalgmtvhst.regcadhordat
      ,cadhsttxt    like datkalgmtvhst.cadhsttxt   
      ,cadusrtip    like datkalgmtvhst.cadusrtip   
      ,cademp       like datkalgmtvhst.cademp      
      ,cadmat       like datkalgmtvhst.cadmat      
   end record

   
   define al_ctc93m04  array[200] of record
          texto          char(80)
   end record

   define lr_retorno_c   record
        erro           smallint
       ,mensagem       char(60)
       ,funnom         like isskfunc.funnom
   end record

   define l_data_antes   datetime year to minute      
   define l_data_agora   datetime year to minute 
   define l_cadmat_antes like datkalgmtvhst.cadmat
   define l_aux_linha    smallint
   define l_x            smallint
   define l_data         date                      
   define l_hora         datetime hour to minute  
    
   let l_data_antes   = null
   let l_cadmat_antes = null
   let l_aux_linha    = 1
   let l_x            = 0

   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc93m04_prepare()
   end if
   
   initialize al_ctc93m04  to  null
    
    
   open cctc93m04003 using param.atdsrvorg, 
                           param.ciaempcod,
                           param.avialgmtv
   
   foreach cctc93m04003 into lr_ctc93m04.atdsrvorg   ,
                             lr_ctc93m04.ciaempcod   ,
                             lr_ctc93m04.avialgmtv   ,
                             lr_ctc93m04.regcadhordat,
                             lr_ctc93m04.cadhsttxt   ,
                             lr_ctc93m04.cadusrtip   ,
                             lr_ctc93m04.cademp      ,
                             lr_ctc93m04.cadmat      
              
       let l_x = l_x + 1 
          
      
      call cty08g00_nome_func(lr_ctc93m04.cademp
                             ,lr_ctc93m04.cadmat
                             ,lr_ctc93m04.cadusrtip)
         returning lr_retorno_c.erro
                  ,lr_retorno_c.mensagem
                  ,lr_retorno_c.funnom

      let l_data_agora = lr_ctc93m04.regcadhordat
      if l_data_antes is null                    or
         l_data_antes   <> l_data_agora or
         l_cadmat_antes <> lr_ctc93m04.cadmat then

         if l_data_antes is not null then
            let al_ctc93m04[l_aux_linha].texto = null

            let l_aux_linha = l_aux_linha + 1
            if l_aux_linha > 200 then
               continue foreach
            end if
         end if

         let l_data = l_data_agora 
         let l_hora = l_data_agora 
         
         let al_ctc93m04[l_aux_linha].texto = "Em: "  ,l_data," ",l_hora 
                                             ," Por: ", lr_retorno_c.funnom
         let l_aux_linha = l_aux_linha + 1
         if l_aux_linha > 200 then
            continue foreach
         end if
      end if

      let al_ctc93m04[l_aux_linha].texto = lr_ctc93m04.cadhsttxt
      let l_aux_linha = l_aux_linha + 1
      if l_aux_linha > 200 then
         continue foreach
      end if

      let l_data_antes   = lr_ctc93m04.regcadhordat
      let l_cadmat_antes = lr_ctc93m04.cadmat

      initialize lr_ctc93m04.* to null
   end foreach

   if l_aux_linha > 200 then
      error 'Numero de registros excedeu o limite'
   end if

   let l_aux_linha = l_aux_linha - 1

   if l_aux_linha = 0 then
      error 'Nenhum registro encontrado'
   else
      #display by name lr_ctc93m04.avialgmtv

      call set_count(l_aux_linha)

      display array al_ctc93m04 to s_ctc93m04.*

         on key(f2,control-c,interrupt)
            exit display

      end display
   end if

   clear form

end function