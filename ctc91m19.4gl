###########################################################################
# Nome do Modulo: ctc91m19                                    Marcos Goes #
#                                                                         #
# Consulta de Oficinas referenciadas Itau                        Out/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
# 09/05/2012   Silvia        PSI 2012-07408  Anatel - DDD/Telefone        #
#-------------------------------------------------------------------------#
###########################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

   define m_prep     smallint
   define m_errflg   char(1)
   define msg        char(80)
   define m_versao   integer

   define m_mens char(80)

   define a_ctc91m19a record
      filcidade         like datkitarefofn.cidnom
     ,filuf             like datkitarefofn.ufdsgl
     ,filbairro         like datkitarefofn.brrnom
     ,filzona           like datkitarefofn.endzonsgl
     ,filrazao          like datkitarefofn.sclraznom
     ,fillinha          like datkitarefofn.atdlintipdes 
   end record

   define a_ctc91m19b array[500] of record
      marca             char(1)
     ,itarefofncod      like datkitarefofn.itarefofncod
     ,sclraznom         like datkitarefofn.sclraznom   
     ,atdlintipdes      like datkitarefofn.atdlintipdes
     ,avades            like datkitarefofn.avades      
     ,endereco          char(66)    
     ,brrnom            like datkitarefofn.brrnom      
     ,cepnum            like datkitarefofn.cepnum      
     ,cepcplnum         like datkitarefofn.cepcplnum   
     ,atoofnflg         like datkitarefofn.atoofnflg   
     ,cidnom            like datkitarefofn.cidnom      
     ,ufdsgl            like datkitarefofn.ufdsgl      
     ,rgcflg            like datkitarefofn.rgcflg      
     ,cttnom            like datkitarefofn.cttnom      
     ,teldddnum         like datkitarefofn.teldddnum   
     ,telnum            like datkitarefofn.telnum      
     ,lotada            char(1)      
     ,horainicio        datetime hour to minute
     ,horafinal         datetime hour to minute
     ,atdsmndiades      like datkitarefofn.atdsmndiades
     ,h24rcbflg         like datkitarefofn.h24rcbflg   
   end record


#========================================================================
function ctc91m19_prepare()
#========================================================================
   define l_sql char(800)

   let l_sql = "SELECT itarefofncod, sclraznom, lgdtipdes, lgdnom, lgdnum, ",      
               "       cpldes, brrnom, cidnom, ufdsgl, cepnum, cepcplnum,  ",
               "       lcllttnum, lcllgnnum, cttnom, teldddnum, telnum,    ",
               "       endzonsgl       ",
               "FROM datkitarefofn     ",
               "WHERE itarefofncod = ? "
   prepare p_ctc91m19_002 from l_sql
   declare c_ctc91m19_002 cursor with hold for p_ctc91m19_002            

   let m_prep = true

#========================================================================
end function # Fim da ctc91m19_prepare
#========================================================================

#========================================================================
function ctc91m19_consulta_oficinas()
#========================================================================
   define l_sql char(1000)
   define l_sql1 char(100)
   define l_sql2 char(100)
   define l_sql3 char(300)
   define l_sql4 char(100)
   define l_sql5 char(100)
   define l_sql6 char(100)

   let l_sql1 = ""
   let l_sql2 = ""
   let l_sql3 = ""
   let l_sql4 = ""
   let l_sql5 = ""
   let l_sql6 = ""

   if a_ctc91m19a.filcidade is not null then
      let l_sql1 = " AND  cidnom LIKE '%", a_ctc91m19a.filcidade clipped, "%' "
   end if

   if a_ctc91m19a.filuf is not null then
      let l_sql2 = " AND  ufdsgl = '", a_ctc91m19a.filuf clipped, "' "
   end if
   
   if a_ctc91m19a.filrazao is not null then
      let l_sql3 = " AND (sclraznom LIKE '%", a_ctc91m19a.filrazao clipped, "%' ",
                   "   OR fannom LIKE '%", a_ctc91m19a.filrazao clipped, "%' ) "
   end if

   if a_ctc91m19a.fillinha is not null then
      let l_sql4 = " AND  atdlintipdes LIKE '%", a_ctc91m19a.fillinha clipped, "%' "
   end if

   if a_ctc91m19a.filbairro is not null then
      let l_sql5 = " AND  brrnom LIKE '%", a_ctc91m19a.filbairro clipped, "%' "
   end if

   if a_ctc91m19a.filzona is not null then
      let l_sql6 = " AND  endzonsgl = '", a_ctc91m19a.filzona clipped, "' "
   end if   

   let l_sql = "SELECT itarefofncod, sclraznom, atdlintipdes, avades,        ",
               "       lgdtipdes, lgdnom, lgdnum, cpldes, brrnom, endzonsgl, ",
               "       cidnom, ufdsgl, cepnum, cepcplnum, cttnom, teldddnum, ",
               "       telnum, atoofnflg, rgcflg, ltalibdat, ",
               "       atdinihor, atdfnlhor, atdsmndiades, h24rcbflg ",
               "FROM datkitarefofn    ",
               "WHERE atoofnflg = 'S' ",
               "AND  (ltalibdat IS NULL OR ltalibdat < today) ",
               l_sql1 clipped, " ",
               l_sql2 clipped, " ",
               l_sql3 clipped, " ",
               l_sql4 clipped, " ",
               l_sql5 clipped, " ",
               l_sql6 clipped, " ",
               "ORDER BY 1 "
   prepare p_ctc91m19_001 from l_sql
   declare c_ctc91m19_001 cursor with hold for p_ctc91m19_001
         
#========================================================================
end function # Fim da ctc91m19_consulta_oficinas
#========================================================================

#========================================================================
function ctc91m19()
#========================================================================
   define l_index       smallint
   define arr_aux       smallint
   define scr_aux       smallint
   define l_prox_arr    smallint
   define l_flg_ok      char(1)
   define l_count       smallint
   define l_count_apl   smallint
   define l_count_ico   smallint
   define l_acumul      smallint
   define l_loop        smallint

   define l_linha1      char(40)
   define l_linha2      char(40)
   define l_linha3      char(40)
   define l_linha4      char(40)
   
   define l_ret_cep     char(5)
   define l_ret_ddd     char(4)
   define l_ret_fone    char(9)  ## Anatel char(8)

   define lr_oficina record
      itarefofncod   like datkitarefofn.itarefofncod
     ,sclraznom      like datkitarefofn.sclraznom   
     ,atdlintipdes   like datkitarefofn.atdlintipdes
     ,avades         like datkitarefofn.avades      
     ,lgdtipdes      like datkitarefofn.lgdtipdes   
     ,lgdnom         like datkitarefofn.lgdnom      
     ,lgdnum         like datkitarefofn.lgdnum      
     ,cpldes         like datkitarefofn.cpldes      
     ,brrnom         like datkitarefofn.brrnom
     ,endzonsgl      like datkitarefofn.endzonsgl
     ,cidnom         like datkitarefofn.cidnom      
     ,ufdsgl         like datkitarefofn.ufdsgl      
     ,cepnum         like datkitarefofn.cepnum      
     ,cepcplnum      like datkitarefofn.cepcplnum
     ,cttnom         like datkitarefofn.cttnom   
     ,teldddnum      like datkitarefofn.teldddnum
     ,telnum         like datkitarefofn.telnum   
     ,atoofnflg      like datkitarefofn.atoofnflg   
     ,rgcflg         like datkitarefofn.rgcflg      
     ,ltalibdat      like datkitarefofn.ltalibdat   
     ,atdinihor      like datkitarefofn.atdinihor   
     ,atdfnlhor      like datkitarefofn.atdfnlhor   
     ,atdsmndiades   like datkitarefofn.atdsmndiades
     ,h24rcbflg      like datkitarefofn.h24rcbflg 
     ,lcllttnum      like datkitarefofn.lcllttnum
     ,lcllgnnum      like datkitarefofn.lcllgnnum 
   end record

   let int_flag = false

   let m_versao = 0

   if m_prep is null or
      m_prep = false then
      call ctc91m19_prepare()
   end if

   open window w_ctc91m19 at 2,2 with form 'ctc91m19'
      attribute(border, form line 1, message line last, comment line last - 1 )
      #attribute(form line first, message line first +20 ,comment line first +19)      

   while true
      message "                   (F17)Abandonar"

      initialize a_ctc91m19a.* to null
      input by name a_ctc91m19a.* without defaults
        #--------------------
         on key (interrupt, control-c)
        #--------------------
            let int_flag = true
            initialize lr_oficina.* to null
            exit input
            
        #--------------------
         before field filcidade
        #--------------------
            display by name a_ctc91m19a.filcidade attribute(reverse)

        #--------------------
         after field filcidade
        #--------------------
            display by name a_ctc91m19a.filcidade attribute(normal)

        #--------------------
         before field filuf
        #--------------------
            display by name a_ctc91m19a.filuf attribute(reverse)

        #--------------------
         after field filuf
        #--------------------
            if a_ctc91m19a.filuf = "SP" and
               a_ctc91m19a.filcidade = "SP" then
               let a_ctc91m19a.filcidade = "SAO PAULO"
            end if
            if a_ctc91m19a.filuf = "RJ" and
               a_ctc91m19a.filcidade = "RJ" then
               let a_ctc91m19a.filcidade = "RIO DE JANEIRO"
            end if        
            if a_ctc91m19a.filuf = "MG" and
               a_ctc91m19a.filcidade = "BH" then
               let a_ctc91m19a.filcidade = "BELO HORIZONTE"
            end if
            if a_ctc91m19a.filuf = "RS" and
               a_ctc91m19a.filcidade = "POA" then
               let a_ctc91m19a.filcidade = "PORTO ALEGRE"
            end if                          
            display by name a_ctc91m19a.filcidade attribute(normal)   
            display by name a_ctc91m19a.filuf attribute(normal)

        #--------------------
         before field filbairro
        #--------------------
            display by name a_ctc91m19a.filbairro attribute(reverse)

        #--------------------
         after field filbairro
        #--------------------
            display by name a_ctc91m19a.filbairro attribute(normal)
            
        #--------------------
         before field filzona
        #--------------------
            display by name a_ctc91m19a.filzona attribute(reverse)

        #--------------------
         after field filzona
        #--------------------
            display by name a_ctc91m19a.filzona attribute(normal)

        #--------------------
         before field filrazao
        #--------------------
            display by name a_ctc91m19a.filrazao attribute(reverse)

        #--------------------
         after field filrazao
        #--------------------
            display by name a_ctc91m19a.filrazao attribute(normal)

        #--------------------
         before field fillinha
        #--------------------
            display by name a_ctc91m19a.fillinha attribute(reverse)

        #--------------------
         after field fillinha
        #--------------------
            display by name a_ctc91m19a.fillinha attribute(normal)
                        
      end input

      if int_flag then
         let int_flag = false
         exit while
      end if

      initialize lr_oficina.* to null
      initialize a_ctc91m19b to null
      let l_index = 1

      call ctc91m19_consulta_oficinas()

      

      whenever error continue
      open c_ctc91m19_001
      whenever error stop
            

      foreach c_ctc91m19_001 into lr_oficina.itarefofncod   
                                 ,lr_oficina.sclraznom      
                                 ,lr_oficina.atdlintipdes   
                                 ,lr_oficina.avades         
                                 ,lr_oficina.lgdtipdes      
                                 ,lr_oficina.lgdnom         
                                 ,lr_oficina.lgdnum         
                                 ,lr_oficina.cpldes         
                                 ,lr_oficina.brrnom
                                 ,lr_oficina.endzonsgl         
                                 ,lr_oficina.cidnom         
                                 ,lr_oficina.ufdsgl         
                                 ,lr_oficina.cepnum         
                                 ,lr_oficina.cepcplnum 
                                 ,lr_oficina.cttnom 
                                 ,lr_oficina.teldddnum
                                 ,lr_oficina.telnum   
                                 ,lr_oficina.atoofnflg      
                                 ,lr_oficina.rgcflg         
                                 ,lr_oficina.ltalibdat      
                                 ,lr_oficina.atdinihor      
                                 ,lr_oficina.atdfnlhor      
                                 ,lr_oficina.atdsmndiades   
                                 ,lr_oficina.h24rcbflg                                                

         let a_ctc91m19b[l_index].marca             = null
         let a_ctc91m19b[l_index].itarefofncod      = lr_oficina.itarefofncod clipped
         let a_ctc91m19b[l_index].sclraznom         = lr_oficina.sclraznom clipped
         let a_ctc91m19b[l_index].atdlintipdes      = lr_oficina.atdlintipdes clipped  
         let a_ctc91m19b[l_index].avades            = lr_oficina.avades clipped
         let a_ctc91m19b[l_index].endereco          = lr_oficina.lgdtipdes clipped, " "
                                                     ,lr_oficina.lgdnom clipped, "; "
                                                     ,lr_oficina.lgdnum clipped, "; "
                                                     ,lr_oficina.cpldes clipped
         let a_ctc91m19b[l_index].brrnom            = lr_oficina.brrnom clipped   
         let a_ctc91m19b[l_index].cepnum            = lr_oficina.cepnum 
         let a_ctc91m19b[l_index].cepcplnum         = lr_oficina.cepcplnum    
         let a_ctc91m19b[l_index].atoofnflg         = lr_oficina.atoofnflg
         let a_ctc91m19b[l_index].cidnom            = lr_oficina.cidnom clipped   
         let a_ctc91m19b[l_index].ufdsgl            = lr_oficina.ufdsgl    
         let a_ctc91m19b[l_index].rgcflg            = lr_oficina.rgcflg    
         let a_ctc91m19b[l_index].cttnom            = lr_oficina.cttnom    
         let a_ctc91m19b[l_index].teldddnum         = lr_oficina.teldddnum    
         let a_ctc91m19b[l_index].telnum            = lr_oficina.telnum    
         let a_ctc91m19b[l_index].horainicio        = lr_oficina.atdinihor     
         let a_ctc91m19b[l_index].horafinal         = lr_oficina.atdfnlhor    
         let a_ctc91m19b[l_index].atdsmndiades      = lr_oficina.atdsmndiades    
         let a_ctc91m19b[l_index].h24rcbflg         = lr_oficina.h24rcbflg    
         
         if lr_oficina.ltalibdat is null or
            lr_oficina.ltalibdat < today then
            let a_ctc91m19b[l_index].lotada = "N"
         else
            let a_ctc91m19b[l_index].lotada = "S"
         end if
                                
         let l_index = l_index + 1     
         
         initialize lr_oficina.* to null

         if l_index > 500 then
            error " Limite excedido! Foram encontrados mais de 500 registros!"
            exit foreach
         end if

      end foreach

      close c_ctc91m19_001

      let arr_aux = l_index
      if arr_aux = 1  then
         error "Nenhum registro encontrado..."
         continue while
      end if

      message "  (F8)Selecionar   (F17)Voltar"

      call set_count(arr_aux - 1)
      input array a_ctc91m19b without defaults from s_ctc91m19b.*

        #--------------------
         before field marca
        #--------------------
            display a_ctc91m19b[arr_aux].sclraznom to s_ctc91m19b[scr_aux].sclraznom attribute(reverse)

        #--------------------
         after field marca
        #--------------------        
            let a_ctc91m19b[arr_aux].marca = null
            display a_ctc91m19b[arr_aux].marca to s_ctc91m19b[scr_aux].marca attribute(normal)
            display a_ctc91m19b[arr_aux].sclraznom to s_ctc91m19b[scr_aux].sclraznom attribute(normal)
            
            if fgl_lastkey() = fgl_keyval("down") or
               fgl_lastkey() = fgl_keyval("right") or
               fgl_lastkey() = fgl_keyval("enter") then
               if a_ctc91m19b[arr_aux + 1].itarefofncod is null then
                  next field marca
               end if
            end if

            if fgl_lastkey() = fgl_keyval("up") or
               fgl_lastkey() = fgl_keyval("left") then
               if arr_aux -1 <= 0 then
                  next field marca
               end if
            end if            

        #------------------
         before row
        #------------------
            let arr_aux = arr_curr()
            let scr_aux = scr_line()

        #--------------------
         before insert
        #--------------------
            next field marca
            #cancel insert

        #--------------------
         before delete
        #--------------------
            next field marca
            #cancel delete

        #--------------------
         on key (accept)
        #--------------------
            continue input

        #--------------------
         on key (interrupt, control-c)
        #--------------------
            let int_flag = false
            clear form
            exit input

        #--------------------
         on key (F8)
        #--------------------
            
            initialize lr_oficina.* to null
            
            whenever error continue
            open c_ctc91m19_002 using a_ctc91m19b[arr_aux].itarefofncod
            fetch c_ctc91m19_002 into lr_oficina.itarefofncod
                                     ,lr_oficina.sclraznom   
                                     ,lr_oficina.lgdtipdes   
                                     ,lr_oficina.lgdnom      
                                     ,lr_oficina.lgdnum      
                                     ,lr_oficina.cpldes      
                                     ,lr_oficina.brrnom      
                                     ,lr_oficina.cidnom      
                                     ,lr_oficina.ufdsgl      
                                     ,lr_oficina.cepnum      
                                     ,lr_oficina.cepcplnum  
                                     ,lr_oficina.lcllttnum
                                     ,lr_oficina.lcllgnnum 
                                     ,lr_oficina.cttnom
                                     ,lr_oficina.teldddnum
                                     ,lr_oficina.telnum
                                     ,lr_oficina.endzonsgl   
            whenever error stop
            close c_ctc91m19_002            
            
            let int_flag = true            
            exit input
                        
      end input
      
      if int_flag then
         let int_flag = false
         exit while
      end if

   end while

   let int_flag = false

   close window w_ctc91m19

   let l_ret_cep  = lr_oficina.cepnum using "&&&&&"   
   let l_ret_ddd  = lr_oficina.teldddnum using "<<<<"
   let l_ret_fone = lr_oficina.telnum using "<<<<<<<<<"  # Anatel

      
   return lr_oficina.itarefofncod
         ,lr_oficina.sclraznom 
         ,lr_oficina.lgdtipdes 
         ,lr_oficina.lgdnom    
         ,lr_oficina.lgdnum    
         ,lr_oficina.cpldes    
         ,lr_oficina.brrnom    
         ,lr_oficina.cidnom    
         ,lr_oficina.ufdsgl    
         ,l_ret_cep #lr_oficina.cepnum    Apenas para retornar no formato "00000"
         ,lr_oficina.cepcplnum 
         ,lr_oficina.lcllttnum
         ,lr_oficina.lcllgnnum 
         ,lr_oficina.cttnom
         ,l_ret_ddd
         ,l_ret_fone 
         ,lr_oficina.endzonsgl 
         

#========================================================================
end function # Fim da funcao ctc91m19()
#========================================================================

