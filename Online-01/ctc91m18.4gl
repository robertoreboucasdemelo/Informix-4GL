###########################################################################
# Nome do Modulo: ctc91m18                                   Marcos Goes  #
#                                                                         #
# Cadastro de Oficinas Referenciadas Itau                        Out/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"

   define  m_ctc91m18_sql  char(1)

   define m_prep     smallint
   define m_mens     char(80)

   define a_ctc91m18 record
       itarefofncod  like datkitarefofn.itarefofncod  
      ,cpjcpfnum     like datkitarefofn.cpjcpfnum     
      ,cpjordnum     like datkitarefofn.cpjordnum     
      ,cpjcpfdig     like datkitarefofn.cpjcpfdig     
      ,sclraznom     like datkitarefofn.sclraznom     
      ,fannom        like datkitarefofn.fannom        
      ,atoofnflg     like datkitarefofn.atoofnflg     
      ,itaofncod     like datkitarefofn.itaofncod     
      ,cdedat        like datkitarefofn.cdedat        
      ,vclcpdqtd     like datkitarefofn.vclcpdqtd     
      ,atdlintipdes  like datkitarefofn.atdlintipdes  
      ,avades        like datkitarefofn.avades        
      ,rgcflg        like datkitarefofn.rgcflg        
      ,h24rcbflg     like datkitarefofn.h24rcbflg     
      ,lotada        char(1)       
      ,ltalibdat     like datkitarefofn.ltalibdat     
      ,atldat        like datkitarefofn.atldat        
      ,atlfunnom     like isskfunc.funnom 
   end record

   define a_ctc91m18a record
       cepnum        like datkitarefofn.cepnum        
      ,cepcplnum     like datkitarefofn.cepcplnum     
      ,lcllttnum     like datkitarefofn.lcllttnum     
      ,lcllgnnum     like datkitarefofn.lcllgnnum     
      ,lgdtipdes     like datkitarefofn.lgdtipdes     
      ,lgdnom        like datkitarefofn.lgdnom        
      ,lgdnum        like datkitarefofn.lgdnum        
      ,cpldes        like datkitarefofn.cpldes        
      ,brrnom        like datkitarefofn.brrnom
      ,endzonsgl     like datkitarefofn.endzonsgl   
      ,cidnom        like datkitarefofn.cidnom        
      ,ufdsgl        like datkitarefofn.ufdsgl
      ,cttnom        like datkitarefofn.cttnom            
      ,teldddnum     like datkitarefofn.teldddnum     
      ,telnum        like datkitarefofn.telnum        
      ,faxdddnum     like datkitarefofn.faxdddnum     
      ,faxnum        like datkitarefofn.faxnum        
      ,ofnmaides     like datkitarefofn.ofnmaides         
      ,atdinihor     like datkitarefofn.atdinihor     
      ,atdfnlhor     like datkitarefofn.atdfnlhor
      ,horainicio    datetime hour to minute
      ,horafinal     datetime hour to minute  
      ,atdsmndiades  like datkitarefofn.atdsmndiades  
   end record   
   
   define a_titulo record 
      label1   char(80), 
      label2   char(80),
      label3   char(80),
      label4   char(80)
   end record
   
#===============================================================================
 function ctc91m18_prepare()
#===============================================================================

   define l_sql char(5000)

   let l_sql = "SELECT NVL(MAX(itarefofncod),0) + 1 ",
               "FROM datkitarefofn "
   prepare p_ctc91m18_001 from l_sql
   declare c_ctc91m18_001 cursor for p_ctc91m18_001

   let l_sql = " SELECT MIN(itarefofncod)  "
             , "   FROM datkitarefofn      "
             , "  WHERE itarefofncod  >  ? "
   prepare p_ctc91m18_002 from l_sql
   declare c_ctc91m18_002 cursor for p_ctc91m18_002

   let l_sql = " SELECT MAX(itarefofncod)  "
             , "   FROM datkitarefofn      "
             , "  WHERE itarefofncod  <  ? "
   prepare p_ctc91m18_003 from l_sql
   declare c_ctc91m18_003 cursor for p_ctc91m18_003


   let l_sql = "UPDATE datkitarefofn ",
               "SET cpjcpfnum    = ? ",
               "   ,cpjordnum    = ? ",
               "   ,cpjcpfdig    = ? ",
               "   ,sclraznom    = ? ",
               "   ,fannom       = ? ",
               "   ,atoofnflg    = ? ",
               "   ,itaofncod    = ? ",
               "   ,cdedat       = ? ",
               "   ,vclcpdqtd    = ? ",
               "   ,atdlintipdes = ? ",
               "   ,avades       = ? ",
               "   ,rgcflg       = ? ",
               "   ,h24rcbflg    = ? ",
               "   ,ltalibdat    = ? ",
               "   ,cepnum       = ? ",
               "   ,cepcplnum    = ? ",
               "   ,lcllttnum    = ? ",
               "   ,lcllgnnum    = ? ",
               "   ,lgdtipdes    = ? ",
               "   ,lgdnom       = ? ",
               "   ,lgdnum       = ? ",
               "   ,cpldes       = ? ",
               "   ,brrnom       = ? ",
               "   ,endzonsgl    = ? ",
               "   ,cidnom       = ? ",
               "   ,ufdsgl       = ? ",
               "   ,teldddnum    = ? ",
               "   ,telnum       = ? ",
               "   ,faxdddnum    = ? ",
               "   ,faxnum       = ? ",
               "   ,ofnmaides    = ? ",
               "   ,cttnom       = ? ",
               "   ,atdinihor    = ? ",
               "   ,atdfnlhor    = ? ",
               "   ,atdsmndiades = ? ",
               "   ,atlusrtipcod = ? ",
               "   ,atlempcod    = ? ",
               "   ,atlmatcod    = ? ",
               "   ,atldat       = today ",
               "WHERE itarefofncod  = ? "
   prepare p_ctc91m18_004 from l_sql

   let l_sql = "INSERT INTO datkitarefofn  "
              ," (itarefofncod, cpjcpfnum, cpjordnum, cpjcpfdig, sclraznom, fannom,      "
              ,"  atoofnflg, itaofncod, cdedat, vclcpdqtd, atdlintipdes, avades, rgcflg, "
              ,"  h24rcbflg, ltalibdat, cepnum, cepcplnum, lcllttnum, lcllgnnum,         "
              ,"  lgdtipdes, lgdnom, lgdnum, cpldes, brrnom, endzonsgl, cidnom, ufdsgl,  "
              ,"  teldddnum, telnum, faxdddnum, faxnum, ofnmaides, cttnom, atdinihor,    "
              ,"  atdfnlhor, atdsmndiades, atlusrtipcod, atlempcod, atlmatcod, atldat )  "
              ," VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, "
              ,"         ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,today)     "
   prepare p_ctc91m18_005 from l_sql

   let l_sql = "SELECT COUNT(*)     ",
               "FROM datkitarefofn  ",
               "WHERE itarefofncod = ? "
   prepare p_ctc91m18_006 from l_sql
   declare c_ctc91m18_006 cursor for p_ctc91m18_006

   let l_sql = "SELECT  itarefofncod, cpjcpfnum, cpjordnum, cpjcpfdig, sclraznom, fannom,  "
              ,"  atoofnflg, itaofncod, cdedat, vclcpdqtd, atdlintipdes, avades, rgcflg,   "
              ,"  h24rcbflg, ltalibdat, atldat, B.funnom, cepnum, cepcplnum, lcllttnum,    "
              ,"  lcllgnnum, lgdtipdes, lgdnom, lgdnum, cpldes, brrnom, endzonsgl, cidnom, "
              ,"  ufdsgl, teldddnum, telnum, faxdddnum, faxnum, ofnmaides, cttnom,         "
              ,"  atdinihor, atdfnlhor, atdsmndiades, atlusrtipcod, atlempcod, atlmatcod   "
              ,"FROM datkitarefofn A "
              ,"LEFT JOIN isskfunc B "
              ,"   ON A.atlusrtipcod = B.usrtip "
              ,"  AND A.atlempcod    = B.empcod "
              ,"  AND A.atlmatcod    = B.funmat "
              ,"WHERE itarefofncod = ? "
   prepare p_ctc91m18_008 from l_sql
   declare c_ctc91m18_008 cursor for p_ctc91m18_008

   let l_sql = "SELECT funnom    ",
               "FROM isskfunc    ",
               "WHERE funmat = ? ",
               "AND   empcod = ? ",
               "AND   usrtip = ? "
   prepare p_ctc91m18_009 from l_sql
   declare c_ctc91m18_009 cursor for p_ctc91m18_009

   let l_sql = "SELECT LGD.lgdtip "
              ,"      ,LGD.lgdnom "
              ,"      ,BRR.brrnom "
              #,"      ,LGD.cidcod "
              ,"      ,CID.cidnom "
              ,"      ,CID.ufdcod "
              ,"FROM glaklgd LGD  "
              ,"LEFT JOIN glakcid CID "
              ,"  ON CID.cidcod = LGD.cidcod  "
              ,"LEFT JOIN glakbrr BRR "
              ,"  ON BRR.brrcod = LGD.brrcod "
              ," AND BRR.cidcod = LGD.cidcod "
              ,"WHERE lgdcep    = ? "
              ,"  AND lgdcepcmp = ? "
   prepare p_ctc91m18_010 from l_sql
   declare c_ctc91m18_010 cursor for p_ctc91m18_010

   let l_sql = " SELECT mpacidcod     ",           
               "   FROM datkmpacid    ",           
               "  WHERE cidnom =    ? ",           
               "    and ufdcod =    ? "           
   prepare p_ctc91m18_013 from l_sql
   declare c_ctc91m18_013 cursor for p_ctc91m18_013

   let l_sql = "  SELECT mpabrrcod       ",
               "    FROM datkmpabrr      ",
               "   WHERE mpacidcod = ?   ",
               "     AND brrnom    = ?   "
   prepare p_ctc91m18_014 from l_sql
   declare c_ctc91m18_014 cursor for p_ctc91m18_014

   let l_sql = " SELECT mpalgdcod        ",
               "   FROM datkmpalgd       ",
               "  WHERE lgdnom =      ?  ",
               "    AND   lgdtip =    ?  ",
               "    AND   mpacidcod = ?  "
   prepare p_ctc91m18_015 from l_sql
   declare c_ctc91m18_015 cursor for p_ctc91m18_015

   let l_sql = " SELECT lgdcep     ",
               "      , lgdcepcmp  ",
               "   FROM glaklgd    ",
               "  WHERE lgdtip = ? ",
               "    AND lgdnom = ? ",
               "    AND cidcod = ? "
   prepare p_ctc91m18_016 from l_sql               
   declare c_ctc91m18_016 cursor for p_ctc91m18_016


   let l_sql = "SELECT  itarefofncod, cpjcpfnum, cpjordnum, cpjcpfdig, sclraznom, fannom,  "
              ,"  atoofnflg, itaofncod, cdedat, vclcpdqtd, atdlintipdes, avades, rgcflg,   "
              ,"  h24rcbflg, ltalibdat, atldat, B.funnom, cepnum, cepcplnum, lcllttnum,    "
              ,"  lcllgnnum, lgdtipdes, lgdnom, lgdnum, cpldes, brrnom, endzonsgl, cidnom, "
              ,"  ufdsgl, teldddnum, telnum, faxdddnum, faxnum, ofnmaides, cttnom,         "
              ,"  atdinihor, atdfnlhor, atdsmndiades, atlusrtipcod, atlempcod, atlmatcod   "
              ,"FROM datkitarefofn A "
              ,"LEFT JOIN isskfunc B "
              ,"   ON A.atlusrtipcod = B.usrtip "
              ,"  AND A.atlempcod    = B.empcod "
              ,"  AND A.atlmatcod    = B.funmat "
              ,"ORDER BY itarefofncod "
   prepare p_ctc91m18_020 from l_sql
   declare c_ctc91m18_020 cursor for p_ctc91m18_020


   let l_sql = "UPDATE datkitarefofn ",
               "SET cepnum       = ? ",
               "   ,cepcplnum    = ? ",
               "   ,lcllttnum    = ? ",
               "   ,lcllgnnum    = ? ",
               "   ,atldat       = today ",
               "WHERE itarefofncod  = ? "
   prepare p_ctc91m18_021 from l_sql
   
   let m_prep = true

#===============================================================================
end function # Fim da ctc91m18_prepare
#===============================================================================

#===============================================================================
 function ctc91m18()
#===============================================================================

   let int_flag = false
   initialize a_ctc91m18.*,
              a_ctc91m18a.*,
              a_titulo.*  to null

   if m_prep = false or
      m_prep is null then
      call ctc91m18_prepare()
   end if
   
   let a_titulo.label1 = "                                 DADOS GERAIS"
   let a_titulo.label2 = "                           INFORMACOES COMPLEMENTARES"
   let a_titulo.label3 = "                                   ENDERECO"
   let a_titulo.label4 = "                                   CONTATOS"
                                                                                          

# GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
#   let g_issk.funmat = 12559
#   let g_issk.empcod = 1
#   let g_issk.usrtip = 'F'
# GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO

   open window w_ctc91m18 at 4,2 with form "ctc91m18"
   attribute(form line first + 2, message line first +19 ,comment line first +18)

   display by name a_titulo.label1 attribute(reverse)    
   display by name a_titulo.label2 attribute(reverse)    
   
   menu "Oficinas"

      command key ("S") "Seleciona"
                        "Pesquisa Oficina pelo codigo"
         call ctc91m18_seleciona()
         if a_ctc91m18.itarefofncod is not null  then
            next option "Modifica"
         else
            error " Nenhuma Oficina selecionada!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"


      command key ("P") "Proximo"
                        "Mostra a proxima Oficina"
         call ctc91m18_proximo()
         message " (F17)Abandona"

      command key ("A") "Anterior"
                        "Mostra a Oficina anterior"
         call ctc91m18_anterior()
         message " (F17)Abandona"

      command key ("B") "Busca"
                        "Busca uma oficina determinada"
         call ctc91m19()
         returning a_ctc91m18.itarefofncod
                  ,a_ctc91m18.sclraznom
                  ,a_ctc91m18a.lgdtipdes
                  ,a_ctc91m18a.lgdnom
                  ,a_ctc91m18a.lgdnum
                  ,a_ctc91m18a.cpldes
                  ,a_ctc91m18a.brrnom
                  ,a_ctc91m18a.cidnom
                  ,a_ctc91m18a.ufdsgl
                  ,a_ctc91m18a.cepnum
                  ,a_ctc91m18a.cepcplnum
                  ,a_ctc91m18a.lcllttnum
                  ,a_ctc91m18a.lcllgnnum
                  ,a_ctc91m18a.cttnom
                  ,a_ctc91m18a.teldddnum
                  ,a_ctc91m18a.telnum   
                  ,a_ctc91m18a.endzonsgl
                        
         call ctc91m18_busca()
         if a_ctc91m18.itarefofncod is not null  then
            next option "Modifica"
         else
            error " Nenhuma Oficina selecionada!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"
         
      command key ("M") "Modifica"
                        "Modifica a Oficina selecionada"
         if not (a_ctc91m18.itarefofncod is null or a_ctc91m18.itarefofncod = " ") then
            call ctc91m18_input("c")
         else
            error " Nenhuma Oficina selecionada!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"

{
      command key ("L") "Lote"
                        "Lote de atualizacao"
         call ctc91m18_geocodificar_lote()
         next option "Seleciona"
         message " (F17)Abandona"
}         



      command key ("I") "Inclui"
                        "Inclui CAR"
         message " (F17)Abandona"         
         initialize a_ctc91m18.*,
                    a_ctc91m18a.* to null
         display by name a_ctc91m18.*
         call ctc91m18_input("i")
         next option "Modifica"



                  
      command key (interrupt,E) "Encerra"
                                "Retorna ao menu anterior"
         exit menu

   end menu

   close window w_ctc91m18

#===============================================================================
end function  # Fim da ctc91m18
#===============================================================================




#========================================================================
 function ctc91m18_proximo()
#========================================================================

   define l_cod like datkitarefofn.itarefofncod

   let int_flag = false

   if a_ctc91m18.itarefofncod = " " or
      a_ctc91m18.itarefofncod is null then
      let a_ctc91m18.itarefofncod = 0
   end if

   let l_cod = a_ctc91m18.itarefofncod

   whenever error continue
      open c_ctc91m18_002 using a_ctc91m18.itarefofncod
      fetch c_ctc91m18_002 into a_ctc91m18.itarefofncod
      close c_ctc91m18_002
   whenever error stop
   call ctc91m18_preenche_oficina()

   if a_ctc91m18.itarefofncod = " " or
      a_ctc91m18.sclraznom is null or
      a_ctc91m18.sclraznom = " " then
      let a_ctc91m18.itarefofncod = l_cod
      call ctc91m18_preenche_oficina()
      error " Nao existe proxima Oficina!"
   end if

#========================================================================
 end function  # Fim da funcao ctc91m18_proximo
#========================================================================

#========================================================================
 function ctc91m18_anterior()
#========================================================================
   define l_cod like datkitarefofn.itarefofncod

   let int_flag = false

   if a_ctc91m18.itarefofncod = " " or
      a_ctc91m18.itarefofncod is null then
      let a_ctc91m18.itarefofncod = 0
   end if

   let l_cod = a_ctc91m18.itarefofncod

   whenever error continue
      open c_ctc91m18_003 using a_ctc91m18.itarefofncod
      fetch c_ctc91m18_003 into a_ctc91m18.itarefofncod
      close c_ctc91m18_003
   whenever error stop
   call ctc91m18_preenche_oficina()

   if a_ctc91m18.itarefofncod = " " or
      a_ctc91m18.sclraznom is null or
      a_ctc91m18.sclraznom = " " then
      let a_ctc91m18.itarefofncod = l_cod
      call ctc91m18_preenche_oficina()
      error " Nao existe Oficina anterior!"
   end if

#========================================================================
 end function  # Fim da funcao ctc91m18_anterior
#========================================================================

#========================================================================
 function ctc91m18_seleciona()
#========================================================================
   define l_flg_ok char(1)
   define l_count  smallint

   let int_flag = false

   initialize a_ctc91m18.*,
              a_ctc91m18a.* to null
   
   display by name a_ctc91m18.*

   input by name a_ctc91m18.* without defaults

     #--------------------
      before field itarefofncod
     #--------------------
         display by name a_ctc91m18.itarefofncod attribute(reverse)

     #--------------------
      after field itarefofncod
     #--------------------
         call ctc91m18_preenche_oficina()

         display by name a_ctc91m18.itarefofncod attribute(normal)

         if a_ctc91m18.itarefofncod = " " or
            a_ctc91m18.sclraznom is null or
            a_ctc91m18.sclraznom = " " then

            call cts08g01("A", "N",
                          " ",
                          "OFICINA NAO ENCONTRADA.",
                          "DIGITE UM CODIGO VALIDO.",
                          " ")
            returning l_flg_ok

            initialize a_ctc91m18.*,
                       a_ctc91m18a.* to null
            display by name a_ctc91m18.*
            exit input
         end if

     #--------------------
      before field cpjcpfnum
     #--------------------
         exit input

     #--------------------
      on key (interrupt)
     #--------------------
         exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize a_ctc91m18.*,
                 a_ctc91m18a.* to null
      display by name a_ctc91m18.*
      error " Operacao cancelada!"
   end if

#========================================================================
 end function  # Fim da funcao ctc91m18_seleciona
#========================================================================

#========================================================================
 function ctc91m18_busca()
#========================================================================
   define l_flg_ok char(1)
   define l_count  smallint

   let int_flag = false

   call ctc91m18_preenche_oficina()

   display by name a_ctc91m18.itarefofncod attribute(normal)

   if a_ctc91m18.itarefofncod = " " or
      a_ctc91m18.sclraznom is null or
      a_ctc91m18.sclraznom = " " then

      call cts08g01("A", "N",
                    " ",
                    "OFICINA NAO ENCONTRADA.",
                    "SELECIONE UMA OFICINA VALIDA.",
                    " ")
      returning l_flg_ok

      initialize a_ctc91m18.*,
                 a_ctc91m18a.* to null
      display by name a_ctc91m18.*
   end if

#========================================================================
 end function  # Fim da funcao ctc91m18_busca
#========================================================================

#========================================================================
 function ctc91m18_input(lr_param)
#========================================================================

   define lr_param record
      operacao char(1)
   end record

   define l_operacao char(1)
   define l_count    smallint
   define l_temp     char(50)
   define l_brrcod   like glakbrr.brrcod
   define l_lgdcod   like glaklgd.lgdcod
   define l_digito_cpf like datkitarefofn.cpjcpfdig
   define l_tela_endereco smallint


   while true
  
      message " (F17)Abandona    (F8)Endereco"


      let l_tela_endereco = false
      
      if lr_param.operacao = " " or
         lr_param.operacao is null then
         let l_operacao = "c"
      else
         let l_operacao = lr_param.operacao
      end if

      input by name a_ctc91m18.*  without defaults # from s2_ctc91m18.*
     

        #--------------------
         before field itarefofncod
        #--------------------
            if l_operacao = "c" then
               next field next
            else
               display by name a_ctc91m18.itarefofncod attribute(reverse)
            end if

        #--------------------
         after field itarefofncod
        #--------------------
            if a_ctc91m18.itarefofncod = 0 or
               a_ctc91m18.itarefofncod = " " or
               a_ctc91m18.itarefofncod is null then

               whenever error continue
               open c_ctc91m18_001
               fetch c_ctc91m18_001 into a_ctc91m18.itarefofncod                    
               close c_ctc91m18_001
               whenever error stop

            end if

            display by name a_ctc91m18.itarefofncod attribute(normal)

            whenever error continue
            open c_ctc91m18_006 using a_ctc91m18.itarefofncod
            fetch c_ctc91m18_006 into l_count  
            close c_ctc91m18_006
            whenever error stop

            if l_count > 0 then
               error " Este codigo ja existe, escolha outro."
               next field itarefofncod
            end if


        #--------------------
         before field cpjcpfnum
        #--------------------
            display by name a_ctc91m18.cpjcpfnum attribute(reverse)
            
        #--------------------
         after field cpjcpfnum
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and
               fgl_lastkey() <> fgl_keyval("left") then               
               if a_ctc91m18.cpjcpfnum is null or
                  a_ctc91m18.cpjcpfnum = " " then
                  error " Preenchimento obrigatorio do CNPJ da Oficina."
                  next field cpjcpfnum
               end if
            end if
            
            display by name a_ctc91m18.cpjcpfnum attribute(normal)


        #--------------------
         before field cpjordnum
        #--------------------
            display by name a_ctc91m18.cpjordnum attribute(reverse)            
        #--------------------
         after field cpjordnum
        #--------------------
            if a_ctc91m18.cpjordnum is null or
               a_ctc91m18.cpjordnum = " " then
               let a_ctc91m18.cpjordnum = 1
            end if
            display by name a_ctc91m18.cpjordnum attribute(normal)


        #--------------------
         before field cpjcpfdig
        #--------------------
            display by name a_ctc91m18.cpjcpfdig attribute(reverse)            
        #--------------------
         after field cpjcpfdig
        #--------------------            
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.cpjcpfdig is null or
                  a_ctc91m18.cpjcpfdig = " " then
                  error " Preenchimento obrigatorio do digito do CNPJ."
                  next field cpjcpfdig
               end if
               
               let l_digito_cpf = 0
               call F_FUNDIGIT_DIGITOCGC(a_ctc91m18.cpjcpfnum,
                                         a_ctc91m18.cpjordnum   )
               returning l_digito_cpf
               
               if l_digito_cpf is null or
                  a_ctc91m18.cpjcpfdig <> l_digito_cpf then
                  #display "DIGITO: ", l_digito_cpf
                  error " Digito do CNPJ invalido."
                  next field cpjcpfdig
               end if
               
            end if
            
            display by name a_ctc91m18.cpjcpfdig attribute(normal)

        #--------------------
         before field sclraznom
        #--------------------
            display by name a_ctc91m18.sclraznom attribute(reverse)
        #--------------------
         after field sclraznom
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.sclraznom is null or
                  a_ctc91m18.sclraznom = " " then
                  error " Preenchimento obrigatorio da Razao Social da Oficina."
                  next field sclraznom
               end if
            end if
            display by name a_ctc91m18.sclraznom attribute(normal)


        #--------------------
         before field fannom
        #--------------------
            display by name a_ctc91m18.fannom attribute(reverse)        
        #--------------------
         after field fannom
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.fannom is null or
                  a_ctc91m18.fannom = " " then
                  error " Preenchimento obrigatorio do Nome Fantasia da Oficina."
                  next field fannom
               end if
            end if
            display by name a_ctc91m18.fannom attribute(normal)


        #--------------------
         before field atoofnflg
        #--------------------
            display by name a_ctc91m18.atoofnflg attribute(reverse)
        #--------------------
         after field atoofnflg
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.atoofnflg is null or
                  a_ctc91m18.atoofnflg = " " then
                  error " Preenchimento obrigatorio da situacao da Oficina."
                  next field atoofnflg
               end if
            end if
            
            let a_ctc91m18.atoofnflg = upshift(a_ctc91m18.atoofnflg)
            
            if a_ctc91m18.atoofnflg <> "S" and a_ctc91m18.atoofnflg <> "N" then               
               error " Preencha apenas S ou N."
               let a_ctc91m18.atoofnflg = " "
               next field atoofnflg
            end if
            
            display by name a_ctc91m18.atoofnflg attribute(normal)
        

        #--------------------
         before field itaofncod
        #--------------------
            display by name a_ctc91m18.itaofncod attribute(reverse)
        #--------------------
         after field itaofncod
        #--------------------
            display by name a_ctc91m18.itaofncod attribute(normal)


        #--------------------
         before field cdedat
        #--------------------
            display by name a_ctc91m18.cdedat attribute(reverse)
        #--------------------
         after field cdedat
        #--------------------
            display by name a_ctc91m18.cdedat attribute(normal)


        #--------------------
         before field vclcpdqtd
        #--------------------
            display by name a_ctc91m18.vclcpdqtd attribute(reverse)
        #--------------------
         after field vclcpdqtd
        #--------------------
            if a_ctc91m18.vclcpdqtd is null or
               a_ctc91m18.vclcpdqtd = " " then
               let a_ctc91m18.vclcpdqtd = 0
            end if        
            display by name a_ctc91m18.vclcpdqtd attribute(normal)


        #--------------------
         before field atdlintipdes
        #--------------------
            display by name a_ctc91m18.atdlintipdes attribute(reverse)        
        #--------------------
         after field atdlintipdes
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.atdlintipdes is null or
                  a_ctc91m18.atdlintipdes = " " then
                  error " Preenchimento obrigatorio dos Tipos / Linhas atendidas."
                  next field atdlintipdes
               end if
            end if
            display by name a_ctc91m18.atdlintipdes attribute(normal)

        #--------------------
         before field avades
        #--------------------
            display by name a_ctc91m18.avades attribute(reverse)        
        #--------------------
         after field avades
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.avades is null or
                  a_ctc91m18.avades = " " then
                  error " Preenchimento obrigatorio da Avaliacao da Oficina."
                  next field avades
               end if
            end if
            display by name a_ctc91m18.avades attribute(normal)
                        

        #--------------------
         before field rgcflg
        #--------------------
            display by name a_ctc91m18.rgcflg attribute(reverse)
        #--------------------
         after field rgcflg
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.rgcflg is null or
                  a_ctc91m18.rgcflg = " " then
                  error " Preenchimento obrigatorio da Regulacao de Imagem."
                  next field rgcflg
               end if
            end if
            
            let a_ctc91m18.rgcflg = upshift(a_ctc91m18.rgcflg)
            
            if a_ctc91m18.rgcflg <> "S" and a_ctc91m18.rgcflg <> "N" then               
               error " Preencha apenas S ou N."
               let a_ctc91m18.rgcflg = " "
               next field rgcflg
            end if
            
            display by name a_ctc91m18.rgcflg attribute(normal)

        #--------------------
         before field h24rcbflg
        #--------------------
            display by name a_ctc91m18.h24rcbflg attribute(reverse)
        #--------------------
         after field h24rcbflg
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.h24rcbflg is null or
                  a_ctc91m18.h24rcbflg = " " then
                  error " Preenchimento obrigatorio do Recebimento 24 horas."
                  next field h24rcbflg
               end if
            end if
            
            let a_ctc91m18.h24rcbflg = upshift(a_ctc91m18.h24rcbflg)
            
            if a_ctc91m18.h24rcbflg <> "S" and a_ctc91m18.h24rcbflg <> "N" then               
               error " Preencha apenas S ou N."
               let a_ctc91m18.h24rcbflg = " "
               next field h24rcbflg
            end if
            
            display by name a_ctc91m18.h24rcbflg attribute(normal)


        #--------------------
         before field lotada
        #--------------------
            display by name a_ctc91m18.lotada attribute(reverse)
        #--------------------
         after field lotada
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.lotada is null or
                  a_ctc91m18.lotada = " " then
                  error " Preenchimento obrigatorio da Lotacao da Oficina."
                  next field lotada
               end if
            end if
            
            let a_ctc91m18.lotada = upshift(a_ctc91m18.lotada)
            
            if a_ctc91m18.lotada <> "S" and a_ctc91m18.lotada <> "N" then               
               error " Preencha apenas S ou N."
               let a_ctc91m18.lotada = " "
               next field lotada
            end if
            
            display by name a_ctc91m18.lotada attribute(normal)

        #--------------------
         before field ltalibdat
        #--------------------
            if a_ctc91m18.lotada = "N" then
               let a_ctc91m18.ltalibdat = null
               display by name a_ctc91m18.ltalibdat attribute(normal)
               #next field cpjcpfnum  
               
               if l_operacao = "i" then
                  let l_tela_endereco = true
               else
                  if ctc91m18_modifica_oficina() then
                     let int_flag = true
                  end if
               end if           
               exit input
               
            end if               
            display by name a_ctc91m18.ltalibdat attribute(reverse)
            
        #--------------------
         after field ltalibdat
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18.ltalibdat is null or
                  a_ctc91m18.ltalibdat = " " then
                  error " Preenchimento obrigatorio da previsao de liberacao da Oficina."
                  next field ltalibdat               
               end if
               if a_ctc91m18.ltalibdat <= today then
                  error " A data de liberacao deve ser futura."
                  next field ltalibdat               
               end if
            end if
            
            display by name a_ctc91m18.ltalibdat attribute(normal)
                        
            
            if l_operacao = "i" then
               let l_tela_endereco = true
            else
               if ctc91m18_modifica_oficina() then
                  let int_flag = true
               end if
            end if           
            exit input
               
                        
               
        #--------------------
          on key (interrupt, control-c)
        #--------------------
          initialize a_ctc91m18.*,
                     a_ctc91m18a.* to null
          display by name a_ctc91m18.*
          let int_flag = true
          exit input

        #--------------------
         on key (F8)
        #--------------------
            display by name a_ctc91m18.itarefofncod attribute(normal)
            display by name a_ctc91m18.cpjcpfnum attribute(normal)
            display by name a_ctc91m18.cpjordnum attribute(normal)
            display by name a_ctc91m18.cpjcpfdig attribute(normal)
            display by name a_ctc91m18.sclraznom attribute(normal)
            display by name a_ctc91m18.fannom attribute(normal)
            display by name a_ctc91m18.atoofnflg attribute(normal)
            display by name a_ctc91m18.itaofncod attribute(normal)
            display by name a_ctc91m18.cdedat attribute(normal)
            display by name a_ctc91m18.vclcpdqtd attribute(normal)
            display by name a_ctc91m18.atdlintipdes attribute(normal)
            display by name a_ctc91m18.avades attribute(normal)
            display by name a_ctc91m18.rgcflg attribute(normal)
            display by name a_ctc91m18.h24rcbflg attribute(normal)
            display by name a_ctc91m18.lotada attribute(normal)
            display by name a_ctc91m18.ltalibdat attribute(normal)        
            let l_tela_endereco = true            
            exit input


      end input

      if l_tela_endereco then
         let l_tela_endereco = false
         call ctc91m18_input_endereco(l_operacao)
         
         if l_operacao = "c" then
            let int_flag = false
         else
            let int_flag = true
         end if
      end if

      if int_flag  then
         exit while
      end if

   end while

   let int_flag = false
   message " "

#========================================================================
 end function  # Fim da funcao ctc91m18_input
#========================================================================



#========================================================================
 function ctc91m18_input_endereco(lr_param)
#========================================================================

   define lr_param record
      operacao char(1)
   end record

   define l_operacao    char(1)
   define l_cepnum      like datkitarefofn.cepnum      
   define l_cepcplnum   like datkitarefofn.cepcplnum   
   define l_latilong    smallint
   define l_flg_ok      char(1)


   define l_geocodigo record
       cidcod like datkmpacid.mpacidcod,
       cidnom like datkmpacid.cidnom,
       ufdcod like datkmpacid.ufdcod,
       brrcod like datkmpabrr.mpabrrcod,
       brrnom like datkmpabrr.brrnom,
       logcod like datkmpalgd.mpalgdcod,
       logtip like datkmpalgd.lgdtip,
       lognom like datkmpalgd.lgdnom,
       lognum integer,
       lcllgt like datkmpalgdsgm.lcllgt,
       lclltt like datkmpalgdsgm.lclltt
   end record                     
   
   let l_operacao = lr_param.operacao



   open window w_ctc91m18a at 6,2 with form "ctc91m18a"
   attribute(form line first, message line first +17 ,comment line first +16)

   
   display by name a_titulo.label3 attribute(reverse)    
   display by name a_titulo.label4 attribute(reverse) 

   while true
   
      let l_latilong = 0
      message " (F17)Voltar"

      input by name a_ctc91m18a.*  without defaults # from s2_ctc91m18a.*


        #--------------------
         before field cepnum
        #--------------------
            display by name a_ctc91m18a.cepnum attribute(reverse)
            let l_cepnum = a_ctc91m18a.cepnum

        #--------------------
         after field cepnum
        #--------------------
            display by name a_ctc91m18a.cepnum attribute(normal)

        #--------------------
         before field cepcplnum
        #--------------------
            display by name a_ctc91m18a.cepcplnum attribute(reverse)
            let l_cepcplnum = a_ctc91m18a.cepcplnum
            
        #--------------------
         after field cepcplnum
        #--------------------
            display by name a_ctc91m18a.cepcplnum attribute(normal)
            
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m18a.cepnum    is not null   and
                  a_ctc91m18a.cepcplnum is not null   then
                  
                  if  l_operacao = "c"               and
                      l_cepnum = a_ctc91m18a.cepnum  and 
                      l_cepcplnum = a_ctc91m18a.cepcplnum  then
                      next field lgdtipdes
                  else                            
                     let a_ctc91m18a.lgdtipdes = null
                     let a_ctc91m18a.lgdnom = null   
                     let a_ctc91m18a.brrnom = null   
                     let a_ctc91m18a.cidnom = null   
                     let a_ctc91m18a.ufdsgl = null   
                     let a_ctc91m18a.lgdnum = null
                     
                     error "Pesquisando Endereco. Aguarde... "
                     whenever error continue
                     
                     open c_ctc91m18_010 using a_ctc91m18a.cepnum
                                              ,a_ctc91m18a.cepcplnum                                                    
                     fetch c_ctc91m18_010 into a_ctc91m18a.lgdtipdes
                                              ,a_ctc91m18a.lgdnom
                                              ,a_ctc91m18a.brrnom
                                              ,a_ctc91m18a.cidnom
                                              ,a_ctc91m18a.ufdsgl
                     close c_ctc91m18_010                                                                    
                     whenever error stop
                     
                     if sqlca.sqlcode = 100 or 
                        a_ctc91m18a.lgdnom = "" or
                        a_ctc91m18a.lgdnom is null then
                        error " CEP nao encontrado."
                        #next field cepnum
                     else
                        error 'Endereco encontrado.'
                     end if
                     
                     call cts06g06(a_ctc91m18a.lgdnom) returning a_ctc91m18a.lgdnom
                      
                  end if
              else
                if a_ctc91m18a.cepnum is not null then
                   error 'Digite o Complemento do CEP.'
                   next field cepcplnum
                end if
              end if
            end if
            
            let a_ctc91m18a.lcllttnum = ""
            let a_ctc91m18a.lcllgnnum = ""
            
            display by name a_ctc91m18a.cepnum   
                           ,a_ctc91m18a.cepcplnum
                           ,a_ctc91m18a.lgdtipdes
                           ,a_ctc91m18a.lgdnom   
                           ,a_ctc91m18a.brrnom   
                           ,a_ctc91m18a.cidnom   
                           ,a_ctc91m18a.ufdsgl   
                           ,a_ctc91m18a.lgdnum
                           ,a_ctc91m18a.lcllttnum
                           ,a_ctc91m18a.lcllgnnum


        #--------------------
         before field lcllttnum
        #--------------------              
            if l_latilong = 0 then
               if fgl_lastkey() = fgl_keyval("up") or     
                  fgl_lastkey() = fgl_keyval("left") then
                  next field cepnum
               else
                  next field lgdtipdes
               end if
            end if
            display by name a_ctc91m18a.lcllttnum attribute(reverse)

        #--------------------
         after field lcllttnum
        #--------------------            
            display by name a_ctc91m18a.lcllttnum attribute(normal)
            if fgl_lastkey() = fgl_keyval("up") or     
               fgl_lastkey() = fgl_keyval("left") then
               let a_ctc91m18a.lcllttnum = null
               let a_ctc91m18a.lcllgnnum = null
               next field cepnum
            end if
            next field lcllgnnum
           
        #--------------------
         before field lcllgnnum
        #--------------------              
            if l_latilong = 0 then
               if fgl_lastkey() = fgl_keyval("up") or     
                  fgl_lastkey() = fgl_keyval("left") then
                  next field cepnum
               else
                  next field lgdtipdes
               end if
            end if
            display by name a_ctc91m18a.lcllgnnum attribute(reverse)

        #--------------------
         after field lcllgnnum
        #--------------------    
            let l_latilong = 0        
            display by name a_ctc91m18a.lcllgnnum attribute(normal)
            if fgl_lastkey() = fgl_keyval("up") or     
               fgl_lastkey() = fgl_keyval("left") then
               let a_ctc91m18a.lcllttnum = null
               let a_ctc91m18a.lcllgnnum = null
               next field cepnum
            end if
            next field cttnom
                        

        #--------------------
         before field lgdtipdes
        #--------------------
            display by name a_ctc91m18a.lgdtipdes attribute(reverse)
        #--------------------
         after field lgdtipdes
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.lgdtipdes is null or
                  a_ctc91m18a.lgdtipdes = " " then
                  error " Preenchimento obrigatorio do Tipo de Logradouro"
                  next field lgdtipdes
               end if
            end if
            display by name a_ctc91m18a.lgdtipdes attribute(normal)


        #--------------------
         before field lgdnom
        #--------------------
            display by name a_ctc91m18a.lgdnom attribute(reverse)
        #--------------------
         after field lgdnom
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.lgdnom is null or
                  a_ctc91m18a.lgdnom = " " then
                  error " Preenchimento obrigatorio do Logradouro"
                  next field lgdnom
               end if
            end if
            display by name a_ctc91m18a.lgdnom attribute(normal)


        #--------------------
         before field lgdnum
        #--------------------
            display by name a_ctc91m18a.lgdnum attribute(reverse)
        #--------------------
         after field lgdnum
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.lgdnum is null or
                  a_ctc91m18a.lgdnum = " " then
                  error " Preenchimento obrigatorio do Numero do Logradouro"
                  next field lgdnum
               end if
            end if
            display by name a_ctc91m18a.lgdnum attribute(normal)


        #--------------------
         before field cpldes
        #--------------------
            display by name a_ctc91m18a.cpldes attribute(reverse)
        #--------------------
         after field cpldes
        #--------------------
            display by name a_ctc91m18a.cpldes attribute(normal)      


        #--------------------
         before field brrnom
        #--------------------
            display by name a_ctc91m18a.brrnom attribute(reverse)
        #--------------------
         after field brrnom
        #--------------------
            display by name a_ctc91m18a.brrnom attribute(normal) 

        #--------------------
         before field endzonsgl
        #--------------------
            display by name a_ctc91m18a.endzonsgl attribute(reverse)
        #--------------------
         after field endzonsgl
        #--------------------            
            if a_ctc91m18a.endzonsgl is not null then
               let a_ctc91m18a.endzonsgl = upshift(a_ctc91m18a.endzonsgl)
               
               if a_ctc91m18a.endzonsgl <> "CE" and                
                  a_ctc91m18a.endzonsgl <> "NO" and
                  a_ctc91m18a.endzonsgl <> "SU" and 
                  a_ctc91m18a.endzonsgl <> "LE" and 
                  a_ctc91m18a.endzonsgl <> "OE" then
                  error " Zona deve ser (CE)ntral, (NO)rte, (SU)l, (LE)ste ou (OE)ste."
                  let a_ctc91m18a.endzonsgl = null
                  next field endzonsgl
               end if
            end if
            
            display by name a_ctc91m18a.endzonsgl attribute(normal)


            
        #--------------------
         before field cidnom
        #--------------------
            display by name a_ctc91m18a.cidnom attribute(reverse)
        #--------------------
         after field cidnom
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.cidnom is null or
                  a_ctc91m18a.cidnom = " " then
                  error " Preenchimento obrigatorio da Cidade"
                  next field cidnom
               end if
            end if
            display by name a_ctc91m18a.cidnom attribute(normal)


        #--------------------
         before field ufdsgl
        #--------------------
            display by name a_ctc91m18a.ufdsgl attribute(reverse)
        #--------------------
         after field ufdsgl
        #--------------------
            display by name a_ctc91m18a.ufdsgl attribute(normal)
            
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.ufdsgl is null or
                  a_ctc91m18a.ufdsgl = " " then
                  error " Preenchimento obrigatorio da UF"
                  next field ufdsgl
               end if
            else
               next field cidnom
            end if            

            let l_geocodigo.cidcod = ""
            let l_geocodigo.cidnom = a_ctc91m18a.cidnom
            let l_geocodigo.ufdcod = a_ctc91m18a.ufdsgl
            let l_geocodigo.brrcod = ""         #l_brrcod
            let l_geocodigo.brrnom = a_ctc91m18a.brrnom
            let l_geocodigo.logcod = ""         #l_lgdcod
            let l_geocodigo.logtip = a_ctc91m18a.lgdtipdes
            let l_geocodigo.lognom = a_ctc91m18a.lgdnom
            let l_geocodigo.lognum = a_ctc91m18a.lgdnum
            let l_geocodigo.lcllgt = ""
            let l_geocodigo.lclltt = ""
            
            whenever error continue
            open  c_ctc91m18_013 using l_geocodigo.cidnom
                                     , l_geocodigo.ufdcod
            fetch  c_ctc91m18_013  into  l_geocodigo.cidcod 
            close c_ctc91m18_013
            whenever error stop
            
            whenever error continue
            open  c_ctc91m18_014 using l_geocodigo.cidcod
                                     , l_geocodigo.brrnom
            fetch  c_ctc91m18_014  into  l_geocodigo.brrcod
            close c_ctc91m18_014
            whenever error stop
            
            whenever error continue
            open  c_ctc91m18_015 using l_geocodigo.lognom 
                                     , l_geocodigo.logtip
                                     , l_geocodigo.cidcod  
            fetch  c_ctc91m18_015  into  l_geocodigo.logcod
            close c_ctc91m18_015
            whenever error stop
             
            # ---- BUSCAR LATITUDE / LONGITUDE ---- #
            call ctc91m14_geocodificar_endereco(l_geocodigo.*)
               returning l_geocodigo.*

            let l_cepnum    = null
            let l_cepcplnum = null        
            
            #display "BUSCA CEP"   
            #display "l_geocodigo.logtip: ", l_geocodigo.logtip
            #display "l_geocodigo.lognom: ", l_geocodigo.lognom
            #display "l_geocodigo.cidcod: ", l_geocodigo.cidcod
            
            whenever error continue
            open  c_ctc91m18_016 using l_geocodigo.logtip
                                     , l_geocodigo.lognom 
                                     , l_geocodigo.cidcod
            fetch c_ctc91m18_016 into l_cepnum    #a_ctc91m18a.cepnum
                                    , l_cepcplnum #a_ctc91m18a.cepcplnum
            close c_ctc91m18_016
            whenever error stop
            
            if l_cepnum is not null and 
               l_cepnum <> 0 then
               
               let a_ctc91m18a.cepnum = l_cepnum
               let a_ctc91m18a.cepcplnum = l_cepcplnum
            end if
                         
            display by name a_ctc91m18a.cepnum
                           ,a_ctc91m18a.cepcplnum            

            let a_ctc91m18a.lcllttnum = l_geocodigo.lclltt 
            let a_ctc91m18a.lcllgnnum = l_geocodigo.lcllgt            

            display by name a_ctc91m18a.lcllttnum                   
                           ,a_ctc91m18a.lcllgnnum attribute(normal)            

            if a_ctc91m18a.lcllttnum is null or
               a_ctc91m18a.lcllgnnum is null then
               error 'Latitude e Longitude nao encontrados! Confirme os dados.'
               let l_flg_ok = " "
               call cts08g01("C", "S",
                             " ",
                             "LATITUDE E LONGITUDE NAO ENCONTRADOS.",
                             "DESEJA PREENCHER MANUALMENTE?",
                             " ")
               returning l_flg_ok

               if l_flg_ok = "S" then
                  let l_latilong = 1
                  next field lcllttnum
               end if
   
            else
               error "Latitude e Longitude encontrados."
            end if 

        #--------------------
         before field cttnom
        #--------------------
            display by name a_ctc91m18a.cttnom attribute(reverse)
        #--------------------
         after field cttnom
        #--------------------
            display by name a_ctc91m18a.cttnom attribute(normal) 


        #--------------------
         before field teldddnum
        #--------------------
            display by name a_ctc91m18a.teldddnum attribute(reverse)
        #--------------------
         after field teldddnum
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.teldddnum is null or
                  a_ctc91m18a.teldddnum = " " or
                  a_ctc91m18a.teldddnum = 0 then
                  error " Preenchimento obrigatorio do DDD do Telefone"
                  next field teldddnum
               end if
            end if
            display by name a_ctc91m18a.teldddnum attribute(normal)
            

        #--------------------
         before field telnum
        #--------------------
            display by name a_ctc91m18a.telnum attribute(reverse)
        #--------------------
         after field telnum
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.telnum is null or
                  a_ctc91m18a.telnum = " " or
                  a_ctc91m18a.telnum = 0 then
                  error " Preenchimento obrigatorio do Telefone"
                  next field telnum
               end if
            end if
            display by name a_ctc91m18a.telnum attribute(normal)
            

        #--------------------
         before field faxdddnum
        #--------------------
            display by name a_ctc91m18a.faxdddnum attribute(reverse)
        #--------------------
         after field faxdddnum
        #--------------------
            display by name a_ctc91m18a.faxdddnum attribute(normal) 
            
            
        #--------------------
         before field faxnum
        #--------------------
            display by name a_ctc91m18a.faxnum attribute(reverse)
        #--------------------
         after field faxnum
        #--------------------
            display by name a_ctc91m18a.faxnum attribute(normal) 


        #--------------------
         before field ofnmaides
        #--------------------
            display by name a_ctc91m18a.ofnmaides attribute(reverse)
        #--------------------
         after field ofnmaides
        #--------------------
            display by name a_ctc91m18a.ofnmaides attribute(normal) 


        #--------------------
         before field horainicio
        #--------------------
            let a_ctc91m18a.horainicio = a_ctc91m18a.atdinihor
            display by name a_ctc91m18a.horainicio attribute(reverse)
        #--------------------
         after field horainicio
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.horainicio is null or
                  a_ctc91m18a.horainicio = " " then
                  error " Preenchimento obrigatorio da Hora Inicio do Atendimento"
                  next field horainicio
               end if
            end if
            let a_ctc91m18a.atdinihor = a_ctc91m18a.horainicio
            display by name a_ctc91m18a.horainicio attribute(normal)
            
            
        #--------------------
         before field horafinal
        #--------------------   
            let a_ctc91m18a.horafinal = a_ctc91m18a.atdfnlhor
            display by name a_ctc91m18a.horafinal attribute(reverse)
        #--------------------
         after field horafinal
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m18a.horafinal is null or
                  a_ctc91m18a.horafinal = " " then
                  error " Preenchimento obrigatorio da Hora Final do Atendimento"
                  next field horafinal
               end if
            end if
            let a_ctc91m18a.atdfnlhor = a_ctc91m18a.horafinal
            display by name a_ctc91m18a.horafinal attribute(normal)            


        #--------------------
         before field atdsmndiades
        #--------------------
            display by name a_ctc91m18a.atdsmndiades attribute(reverse)
        #--------------------
         after field atdsmndiades
        #--------------------
            display by name a_ctc91m18a.atdsmndiades attribute(normal) 

            if l_operacao = "i" then
               if ctc91m18_inclui_oficina() then
                  let int_flag = true
               end if
            else
               if ctc91m18_modifica_oficina() then
                  let int_flag = true
               end if
            end if           
            exit input

            
        #--------------------
          on key (interrupt, control-c)
        #--------------------
          let int_flag = true
          exit input
      
      end input

      if int_flag  then
         exit while
      end if

   end while

   close window w_ctc91m18a

#========================================================================
 end function  # Fim da funcao ctc91m18_input_endereco
#========================================================================


#========================================================================
 function ctc91m18_preenche_oficina()
#========================================================================             

   whenever error continue
   open c_ctc91m18_008 using a_ctc91m18.itarefofncod
   fetch c_ctc91m18_008 into a_ctc91m18.itarefofncod
                            ,a_ctc91m18.cpjcpfnum   
                            ,a_ctc91m18.cpjordnum   
                            ,a_ctc91m18.cpjcpfdig   
                            ,a_ctc91m18.sclraznom   
                            ,a_ctc91m18.fannom      
                            ,a_ctc91m18.atoofnflg   
                            ,a_ctc91m18.itaofncod   
                            ,a_ctc91m18.cdedat      
                            ,a_ctc91m18.vclcpdqtd   
                            ,a_ctc91m18.atdlintipdes
                            ,a_ctc91m18.avades      
                            ,a_ctc91m18.rgcflg      
                            ,a_ctc91m18.h24rcbflg   
                            ,a_ctc91m18.ltalibdat   
                            ,a_ctc91m18.atldat
                            ,a_ctc91m18.atlfunnom                            
                            ,a_ctc91m18a.cepnum      
                            ,a_ctc91m18a.cepcplnum   
                            ,a_ctc91m18a.lcllttnum   
                            ,a_ctc91m18a.lcllgnnum   
                            ,a_ctc91m18a.lgdtipdes   
                            ,a_ctc91m18a.lgdnom      
                            ,a_ctc91m18a.lgdnum      
                            ,a_ctc91m18a.cpldes      
                            ,a_ctc91m18a.brrnom
                            ,a_ctc91m18a.endzonsgl      
                            ,a_ctc91m18a.cidnom      
                            ,a_ctc91m18a.ufdsgl      
                            ,a_ctc91m18a.teldddnum   
                            ,a_ctc91m18a.telnum      
                            ,a_ctc91m18a.faxdddnum   
                            ,a_ctc91m18a.faxnum      
                            ,a_ctc91m18a.ofnmaides   
                            ,a_ctc91m18a.cttnom      
                            ,a_ctc91m18a.atdinihor   
                            ,a_ctc91m18a.atdfnlhor   
                            ,a_ctc91m18a.atdsmndiades
   close c_ctc91m18_008
   whenever error stop

   let a_ctc91m18.lotada = "N"
   if a_ctc91m18.ltalibdat is not null then  # Se a data de liberacao for passada
      if a_ctc91m18.ltalibdat < today then   # considerar que a Oficina ja esta liberada
         let a_ctc91m18.ltalibdat = null
      else
         let a_ctc91m18.lotada = "S"
      end if
   end if

   let a_ctc91m18a.horainicio = a_ctc91m18a.atdinihor
   let a_ctc91m18a.horafinal = a_ctc91m18a.atdfnlhor

   if a_ctc91m18.itarefofncod is null or
      a_ctc91m18.sclraznom = " " or
      a_ctc91m18.sclraznom is null then
      initialize a_ctc91m18.* to null
   end if

   display by name a_ctc91m18.*

#========================================================================
 end function  # Fim da funcao ctc91m18_preenche_oficina
#========================================================================

#========================================================================
 function ctc91m18_inclui_oficina()
#========================================================================
   define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA INCLUSAO",
                 "DA OFICINA?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      #display "a_ctc91m18.itarefofncod  : ", a_ctc91m18.itarefofncod 
      #display "a_ctc91m18.cpjcpfnum     : ", a_ctc91m18.cpjcpfnum    
      #display "a_ctc91m18.cpjordnum     : ", a_ctc91m18.cpjordnum    
      #display "a_ctc91m18.cpjcpfdig     : ", a_ctc91m18.cpjcpfdig    
      #display "a_ctc91m18.sclraznom     : ", a_ctc91m18.sclraznom    
      #display "a_ctc91m18.fannom        : ", a_ctc91m18.fannom       
      #display "a_ctc91m18.atoofnflg     : ", a_ctc91m18.atoofnflg    
      #display "a_ctc91m18.itaofncod     : ", a_ctc91m18.itaofncod    
      #display "a_ctc91m18.cdedat        : ", a_ctc91m18.cdedat       
      #display "a_ctc91m18.vclcpdqtd     : ", a_ctc91m18.vclcpdqtd    
      #display "a_ctc91m18.atdlintipdes  : ", a_ctc91m18.atdlintipdes 
      #display "a_ctc91m18.avades        : ", a_ctc91m18.avades       
      #display "a_ctc91m18.rgcflg        : ", a_ctc91m18.rgcflg       
      #display "a_ctc91m18.h24rcbflg     : ", a_ctc91m18.h24rcbflg    
      #display "a_ctc91m18.ltalibdat     : ", a_ctc91m18.ltalibdat    
      #display "a_ctc91m18a.cepnum       : ", a_ctc91m18a.cepnum      
      #display "a_ctc91m18a.cepcplnum    : ", a_ctc91m18a.cepcplnum   
      #display "a_ctc91m18a.lcllttnum    : ", a_ctc91m18a.lcllttnum   
      #display "a_ctc91m18a.lcllgnnum    : ", a_ctc91m18a.lcllgnnum   
      #display "a_ctc91m18a.lgdtipdes    : ", a_ctc91m18a.lgdtipdes   
      #display "a_ctc91m18a.lgdnom       : ", a_ctc91m18a.lgdnom      
      #display "a_ctc91m18a.lgdnum       : ", a_ctc91m18a.lgdnum      
      #display "a_ctc91m18a.cpldes       : ", a_ctc91m18a.cpldes      
      #display "a_ctc91m18a.brrnom       : ", a_ctc91m18a.brrnom      
      #display "a_ctc91m18a.cidnom       : ", a_ctc91m18a.cidnom      
      #display "a_ctc91m18a.ufdsgl       : ", a_ctc91m18a.ufdsgl      
      #display "a_ctc91m18a.teldddnum    : ", a_ctc91m18a.teldddnum   
      #display "a_ctc91m18a.telnum       : ", a_ctc91m18a.telnum      
      #display "a_ctc91m18a.faxdddnum    : ", a_ctc91m18a.faxdddnum   
      #display "a_ctc91m18a.faxnum       : ", a_ctc91m18a.faxnum      
      #display "a_ctc91m18a.ofnmaides    : ", a_ctc91m18a.ofnmaides   
      #display "a_ctc91m18a.cttnom       : ", a_ctc91m18a.cttnom      
      #display "a_ctc91m18a.atdinihor    : ", a_ctc91m18a.atdinihor   
      #display "a_ctc91m18a.atdfnlhor    : ", a_ctc91m18a.atdfnlhor   
      #display "a_ctc91m18a.atdsmndiades : ", a_ctc91m18a.atdsmndiades
      #display "g_issk.usrtip            : ", g_issk.usrtip           
      #display "g_issk.empcod            : ", g_issk.empcod           
      #display "g_issk.funmat            : ", g_issk.funmat           
      #display "-------------------------------------------"

      whenever error continue
      execute p_ctc91m18_005 using a_ctc91m18.itarefofncod
                                  ,a_ctc91m18.cpjcpfnum
                                  ,a_ctc91m18.cpjordnum
                                  ,a_ctc91m18.cpjcpfdig
                                  ,a_ctc91m18.sclraznom
                                  ,a_ctc91m18.fannom
                                  ,a_ctc91m18.atoofnflg
                                  ,a_ctc91m18.itaofncod
                                  ,a_ctc91m18.cdedat
                                  ,a_ctc91m18.vclcpdqtd
                                  ,a_ctc91m18.atdlintipdes
                                  ,a_ctc91m18.avades
                                  ,a_ctc91m18.rgcflg
                                  ,a_ctc91m18.h24rcbflg
                                  ,a_ctc91m18.ltalibdat
                                  ,a_ctc91m18a.cepnum
                                  ,a_ctc91m18a.cepcplnum
                                  ,a_ctc91m18a.lcllttnum
                                  ,a_ctc91m18a.lcllgnnum
                                  ,a_ctc91m18a.lgdtipdes
                                  ,a_ctc91m18a.lgdnom
                                  ,a_ctc91m18a.lgdnum
                                  ,a_ctc91m18a.cpldes
                                  ,a_ctc91m18a.brrnom
                                  ,a_ctc91m18a.endzonsgl
                                  ,a_ctc91m18a.cidnom
                                  ,a_ctc91m18a.ufdsgl
                                  ,a_ctc91m18a.teldddnum
                                  ,a_ctc91m18a.telnum
                                  ,a_ctc91m18a.faxdddnum
                                  ,a_ctc91m18a.faxnum
                                  ,a_ctc91m18a.ofnmaides                                                                                                                                                                                                                                              
                                  ,a_ctc91m18a.cttnom
                                  ,a_ctc91m18a.atdinihor
                                  ,a_ctc91m18a.atdfnlhor
                                  ,a_ctc91m18a.atdsmndiades
                                  ,g_issk.usrtip
                                  ,g_issk.empcod
                                  ,g_issk.funmat
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao incluir OFICINA. Tabela <datkitarefofn>."
         sleep 3
         return false
      end if

      error "Inclusao realizada com sucesso."
   else
      return false
   end if

   return true
#========================================================================
 end function  # Fim da funcao ctc91m18_inclui_oficina
#========================================================================

#========================================================================
 function ctc91m18_modifica_oficina()
#========================================================================
   define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA ALTERACAO",
                 "DA OFICINA SELECIONADA?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      display "a_ctc91m18.itarefofncod  : ", a_ctc91m18.itarefofncod 
      display "a_ctc91m18.cpjcpfnum     : ", a_ctc91m18.cpjcpfnum    
      display "a_ctc91m18.cpjordnum     : ", a_ctc91m18.cpjordnum    
      display "a_ctc91m18.cpjcpfdig     : ", a_ctc91m18.cpjcpfdig    
      display "a_ctc91m18.sclraznom     : ", a_ctc91m18.sclraznom    
      display "a_ctc91m18.fannom        : ", a_ctc91m18.fannom       
      display "a_ctc91m18.atoofnflg     : ", a_ctc91m18.atoofnflg    
      display "a_ctc91m18.itaofncod     : ", a_ctc91m18.itaofncod    
      display "a_ctc91m18.cdedat        : ", a_ctc91m18.cdedat       
      display "a_ctc91m18.vclcpdqtd     : ", a_ctc91m18.vclcpdqtd    
      display "a_ctc91m18.atdlintipdes  : ", a_ctc91m18.atdlintipdes 
      display "a_ctc91m18.avades        : ", a_ctc91m18.avades       
      display "a_ctc91m18.rgcflg        : ", a_ctc91m18.rgcflg       
      display "a_ctc91m18.h24rcbflg     : ", a_ctc91m18.h24rcbflg    
      display "a_ctc91m18.ltalibdat     : ", a_ctc91m18.ltalibdat    
      display "a_ctc91m18a.cepnum       : ", a_ctc91m18a.cepnum      
      display "a_ctc91m18a.cepcplnum    : ", a_ctc91m18a.cepcplnum   
      display "a_ctc91m18a.lcllttnum    : ", a_ctc91m18a.lcllttnum   
      display "a_ctc91m18a.lcllgnnum    : ", a_ctc91m18a.lcllgnnum   
      display "a_ctc91m18a.lgdtipdes    : ", a_ctc91m18a.lgdtipdes   
      display "a_ctc91m18a.lgdnom       : ", a_ctc91m18a.lgdnom      
      display "a_ctc91m18a.lgdnum       : ", a_ctc91m18a.lgdnum      
      display "a_ctc91m18a.cpldes       : ", a_ctc91m18a.cpldes      
      display "a_ctc91m18a.brrnom       : ", a_ctc91m18a.brrnom 
      display "a_ctc91m18a.endzonsgl    : ", a_ctc91m18a.endzonsgl      
      display "a_ctc91m18a.cidnom       : ", a_ctc91m18a.cidnom      
      display "a_ctc91m18a.ufdsgl       : ", a_ctc91m18a.ufdsgl      
      display "a_ctc91m18a.teldddnum    : ", a_ctc91m18a.teldddnum   
      display "a_ctc91m18a.telnum       : ", a_ctc91m18a.telnum      
      display "a_ctc91m18a.faxdddnum    : ", a_ctc91m18a.faxdddnum   
      display "a_ctc91m18a.faxnum       : ", a_ctc91m18a.faxnum      
      display "a_ctc91m18a.ofnmaides    : ", a_ctc91m18a.ofnmaides   
      display "a_ctc91m18a.cttnom       : ", a_ctc91m18a.cttnom      
      display "a_ctc91m18a.atdinihor    : ", a_ctc91m18a.atdinihor   
      display "a_ctc91m18a.atdfnlhor    : ", a_ctc91m18a.atdfnlhor   
      display "a_ctc91m18a.atdsmndiades : ", a_ctc91m18a.atdsmndiades
      display "g_issk.usrtip            : ", g_issk.usrtip           
      display "g_issk.empcod            : ", g_issk.empcod           
      display "g_issk.funmat            : ", g_issk.funmat           
      display "-------------------------------------------"

      whenever error continue                                    
      execute p_ctc91m18_004 using a_ctc91m18.cpjcpfnum          
                                  ,a_ctc91m18.cpjordnum          
                                  ,a_ctc91m18.cpjcpfdig          
                                  ,a_ctc91m18.sclraznom          
                                  ,a_ctc91m18.fannom             
                                  ,a_ctc91m18.atoofnflg          
                                  ,a_ctc91m18.itaofncod          
                                  ,a_ctc91m18.cdedat             
                                  ,a_ctc91m18.vclcpdqtd          
                                  ,a_ctc91m18.atdlintipdes       
                                  ,a_ctc91m18.avades             
                                  ,a_ctc91m18.rgcflg             
                                  ,a_ctc91m18.h24rcbflg          
                                  ,a_ctc91m18.ltalibdat          
                                  ,a_ctc91m18a.cepnum            
                                  ,a_ctc91m18a.cepcplnum         
                                  ,a_ctc91m18a.lcllttnum         
                                  ,a_ctc91m18a.lcllgnnum         
                                  ,a_ctc91m18a.lgdtipdes         
                                  ,a_ctc91m18a.lgdnom            
                                  ,a_ctc91m18a.lgdnum            
                                  ,a_ctc91m18a.cpldes            
                                  ,a_ctc91m18a.brrnom            
                                  ,a_ctc91m18a.endzonsgl         
                                  ,a_ctc91m18a.cidnom            
                                  ,a_ctc91m18a.ufdsgl            
                                  ,a_ctc91m18a.teldddnum         
                                  ,a_ctc91m18a.telnum            
                                  ,a_ctc91m18a.faxdddnum         
                                  ,a_ctc91m18a.faxnum            
                                  ,a_ctc91m18a.ofnmaides         
                                  ,a_ctc91m18a.cttnom            
                                  ,a_ctc91m18a.atdinihor         
                                  ,a_ctc91m18a.atdfnlhor         
                                  ,a_ctc91m18a.atdsmndiades      
                                  ,g_issk.usrtip                 
                                  ,g_issk.empcod                 
                                  ,g_issk.funmat                 
                                  ,a_ctc91m18.itarefofncod       
      whenever error stop                                        
                                                                 
      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao atualizar OFICINA. Tabela <datkitarefofn>."
         sleep 3
         return false
      end if

      error "Alteracao realizada com sucesso."
   else
      return false
   end if

   return true
#========================================================================
 end function  # Fim da funcao ctc91m18_modifica_oficina
#========================================================================


#========================================================================
 function ctc91m18_geocodificar_lote() 
#========================================================================

   define l_geocodigo record
       cidcod like datkmpacid.mpacidcod,
       cidnom like datkmpacid.cidnom,
       ufdcod like datkmpacid.ufdcod,
       brrcod like datkmpabrr.mpabrrcod,
       brrnom like datkmpabrr.brrnom,
       logcod like datkmpalgd.mpalgdcod,
       logtip like datkmpalgd.lgdtip,
       lognom like datkmpalgd.lgdnom,
       lognum integer,
       lcllgt like datkmpalgdsgm.lcllgt,
       lclltt like datkmpalgdsgm.lclltt
   end record  

   define l_cepnum      like datkitarefofn.cepnum      
   define l_cepcplnum   like datkitarefofn.cepcplnum  
   define l_ok          char(3) 
   
   initialize a_ctc91m18.* to null
   initialize a_ctc91m18a.* to null
   
   whenever error continue
   open c_ctc91m18_020
   whenever error stop
   
   foreach c_ctc91m18_020 into a_ctc91m18.itarefofncod
                              ,a_ctc91m18.cpjcpfnum   
                              ,a_ctc91m18.cpjordnum   
                              ,a_ctc91m18.cpjcpfdig   
                              ,a_ctc91m18.sclraznom   
                              ,a_ctc91m18.fannom      
                              ,a_ctc91m18.atoofnflg   
                              ,a_ctc91m18.itaofncod   
                              ,a_ctc91m18.cdedat      
                              ,a_ctc91m18.vclcpdqtd   
                              ,a_ctc91m18.atdlintipdes
                              ,a_ctc91m18.avades      
                              ,a_ctc91m18.rgcflg      
                              ,a_ctc91m18.h24rcbflg   
                              ,a_ctc91m18.ltalibdat   
                              ,a_ctc91m18.atldat
                              ,a_ctc91m18.atlfunnom                            
                              ,a_ctc91m18a.cepnum      
                              ,a_ctc91m18a.cepcplnum   
                              ,a_ctc91m18a.lcllttnum   
                              ,a_ctc91m18a.lcllgnnum   
                              ,a_ctc91m18a.lgdtipdes   
                              ,a_ctc91m18a.lgdnom      
                              ,a_ctc91m18a.lgdnum      
                              ,a_ctc91m18a.cpldes      
                              ,a_ctc91m18a.brrnom
                              ,a_ctc91m18a.endzonsgl      
                              ,a_ctc91m18a.cidnom      
                              ,a_ctc91m18a.ufdsgl      
                              ,a_ctc91m18a.teldddnum   
                              ,a_ctc91m18a.telnum      
                              ,a_ctc91m18a.faxdddnum   
                              ,a_ctc91m18a.faxnum      
                              ,a_ctc91m18a.ofnmaides   
                              ,a_ctc91m18a.cttnom      
                              ,a_ctc91m18a.atdinihor   
                              ,a_ctc91m18a.atdfnlhor   
                              ,a_ctc91m18a.atdsmndiades

      let l_geocodigo.cidcod = ""
      let l_geocodigo.cidnom = a_ctc91m18a.cidnom
      let l_geocodigo.ufdcod = a_ctc91m18a.ufdsgl
      let l_geocodigo.brrcod = ""         #l_brrcod
      let l_geocodigo.brrnom = a_ctc91m18a.brrnom
      let l_geocodigo.logcod = ""         #l_lgdcod
      let l_geocodigo.logtip = a_ctc91m18a.lgdtipdes
      let l_geocodigo.lognom = a_ctc91m18a.lgdnom
      let l_geocodigo.lognum = a_ctc91m18a.lgdnum
      let l_geocodigo.lcllgt = ""
      let l_geocodigo.lclltt = ""
      
      whenever error continue
      open  c_ctc91m18_013 using l_geocodigo.cidnom
                               , l_geocodigo.ufdcod
      fetch  c_ctc91m18_013  into  l_geocodigo.cidcod 
      close c_ctc91m18_013
      whenever error stop
      
      whenever error continue
      open  c_ctc91m18_014 using l_geocodigo.cidcod
                               , l_geocodigo.brrnom
      fetch  c_ctc91m18_014  into  l_geocodigo.brrcod
      close c_ctc91m18_014
      whenever error stop
      
      whenever error continue
      open  c_ctc91m18_015 using l_geocodigo.lognom 
                               , l_geocodigo.logtip
                               , l_geocodigo.cidcod  
      fetch  c_ctc91m18_015  into  l_geocodigo.logcod
      close c_ctc91m18_015
      whenever error stop
       
      # ---- BUSCAR LATITUDE / LONGITUDE ---- #
      call ctc91m14_geocodificar_endereco(l_geocodigo.*)
         returning l_geocodigo.*
      
      let l_cepnum    = null
      let l_cepcplnum = null        
      
      #display "BUSCA CEP"   
      #display "l_geocodigo.logtip: ", l_geocodigo.logtip
      #display "l_geocodigo.lognom: ", l_geocodigo.lognom
      #display "l_geocodigo.cidcod: ", l_geocodigo.cidcod
      
      whenever error continue
      open  c_ctc91m18_016 using l_geocodigo.logtip
                               , l_geocodigo.lognom 
                               , l_geocodigo.cidcod
      fetch c_ctc91m18_016 into l_cepnum    #a_ctc91m18a.cepnum
                              , l_cepcplnum #a_ctc91m18a.cepcplnum
      close c_ctc91m18_016
      whenever error stop
      
      if l_cepnum is not null and 
         l_cepnum <> 0 then
         
         let a_ctc91m18a.cepnum = l_cepnum
         let a_ctc91m18a.cepcplnum = l_cepcplnum
      end if
                   
      let a_ctc91m18a.lcllttnum = l_geocodigo.lclltt 
      let a_ctc91m18a.lcllgnnum = l_geocodigo.lcllgt            

                                                  
      let l_ok = "---"
                                                  
      if a_ctc91m18a.lcllttnum is not null and 
         a_ctc91m18a.lcllgnnum is not null then
         
         whenever error continue
         execute p_ctc91m18_021 using a_ctc91m18a.cepnum
                                     ,a_ctc91m18a.cepcplnum
                                     ,a_ctc91m18a.lcllttnum
                                     ,a_ctc91m18a.lcllgnnum
                                     ,a_ctc91m18.itarefofncod
         whenever error stop
         
         if sqlca.sqlcode <> 0 then
            let l_ok = "ERR"
            display "Erro (", sqlca.sqlcode clipped, ") ao atualizar OFICINA. Tabela <datkitarefofn>."
         else
            let l_ok = "OK"
         end if
      end if


      display "---------------------------------"
      display "OFICINA..: ", a_ctc91m18.itarefofncod clipped
      display "LATITUDE.: ", a_ctc91m18a.lcllttnum clipped
      display "LONGITUDE: ", a_ctc91m18a.lcllgnnum clipped
      display "CEP: ", a_ctc91m18a.cepnum clipped, "-", a_ctc91m18a.cepcplnum
      display "ATUALIZA.: ", l_ok 

   end foreach
   
   close c_ctc91m18_020
   
   
   





#========================================================================
 end function  # Fim da funcao ctc91m18_geocodificar_lote
#========================================================================
