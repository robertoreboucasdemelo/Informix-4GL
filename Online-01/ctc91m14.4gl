###########################################################################
# Nome do Modulo: ctc91m14                               Helder Oliveira  #
#                                                                         #
# Cadastro de C.A.R                                              Mar/2011 #
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

   define  m_ctc91m14_sql  char(1)

   define m_prep     smallint
   define m_mens     char(80)

   define a_ctc91m14 record
       atdcencod    like datkrpdatdcen.atdcencod
      ,atdcennom    like datkrpdatdcen.atdcennom
      ,atoflg       like datkrpdatdcen.atoflg
      ,rspusrtip    like datkrpdatdcen.rspusrtip
      ,rspempcod    like datkrpdatdcen.rspempcod
      ,rspfunmat    like datkrpdatdcen.rspfunmat
      ,rspfunnom    like isskfunc.funnom
      ,cepnum       like datkrpdatdcen.cepnum
      ,cepcmpnum    like datkrpdatdcen.cepcmpnum
      ,lgdtipdes    like datkrpdatdcen.lgdtipdes
      ,lgdnom       like datkrpdatdcen.lgdnom
      ,lgdnum       like datkrpdatdcen.lgdnum
      ,endcmpdes    like datkrpdatdcen.endcmpdes
      ,brrnom       like datkrpdatdcen.brrnom
      ,cidnom       like datkrpdatdcen.cidnom
      ,endufdsgl    like datkrpdatdcen.endufdsgl
      ,atdcenltt    like datkrpdatdcen.atdcenltt
      ,atdcenlgt    like datkrpdatdcen.atdcenlgt      
      ,teldddnum    like datkrpdatdcen.teldddnum
      ,telnum       like datkrpdatdcen.telnum
      ,faxdddnum    like datkrpdatdcen.faxdddnum
      ,faxnum       like datkrpdatdcen.faxnum
      ,atdinchor    like datkrpdatdcen.atdinchor
      ,atdfnlhor    like datkrpdatdcen.atdfnlhor
      ,atdsemdiades like datkrpdatdcen.atdsemdiades
      ,atldat       like datkrpdatdcen.atldat
      ,atlfunnom    like isskfunc.funnom 
   end record
   
   define a_titulo record 
      label1   char(100), 
      label2   char(100),
      label3   char(100)
   end record
   
#===============================================================================
 function ctc91m14_prepare()
#===============================================================================

   define l_sql char(5000)

   let l_sql = "SELECT NVL(MAX(atdcencod),0) + 1 ",
               "FROM datkrpdatdcen "
   prepare p_ctc91m14_001 from l_sql
   declare c_ctc91m14_001 cursor for p_ctc91m14_001

 let l_sql = " select min(atdcencod)  "
           , "   from datkrpdatdcen   "
           , "  where atdcencod  >  ? "
 prepare p_ctc91m14_002 from l_sql
 declare c_ctc91m14_002 cursor for p_ctc91m14_002

   let l_sql = " select max(atdcencod)  "
             , "   from datkrpdatdcen   "
             , "  where atdcencod  <  ? "
   prepare p_ctc91m14_003 from l_sql
   declare c_ctc91m14_003 cursor for p_ctc91m14_003


   let l_sql = "UPDATE datkrpdatdcen ",
               "SET atdcennom    = ? ",
               "   ,atoflg       = ? ",
               "   ,rspusrtip    = ? ",
               "   ,rspempcod    = ? ",
               "   ,rspfunmat    = ? ",
               "   ,lgdtipdes    = ? ",
               "   ,lgdnom       = ? ",
               "   ,lgdnum       = ? ",
               "   ,endcmpdes    = ? ",
               "   ,brrnom       = ? ",
               "   ,cidnom       = ? ",
               "   ,endufdsgl    = ? ",
               "   ,cepnum       = ? ",
               "   ,cepcmpnum    = ? ",
               "   ,atdcenltt    = ? ",
               "   ,atdcenlgt    = ? ",
               "   ,teldddnum    = ? ",
               "   ,telnum       = ? ",
               "   ,faxdddnum    = ? ",
               "   ,faxnum       = ? ",
               "   ,atdinchor    = ? ",
               "   ,atdfnlhor    = ? ",
               "   ,atdsemdiades = ? ",
               "   ,atlusrtip    = ? ",
               "   ,atlemp       = ? ",
               "   ,atlmat       = ? ",
               "   ,atldat       = today ",
               "WHERE atdcencod  = ? "
   prepare p_ctc91m14_004 from l_sql

   let l_sql = "INSERT INTO datkrpdatdcen ",
               "(atdcencod, atdcennom, atoflg, rspusrtip, rspempcod, rspfunmat, lgdtipdes, lgdnom, ",
               " lgdnum, endcmpdes, brrnom, cidnom, endufdsgl, cepnum, cepcmpnum, atdcenltt,  ",
               " atdcenlgt, teldddnum, telnum, faxdddnum, faxnum, atdinchor, atdfnlhor,  ",
               " atdsemdiades, atlusrtip, atlemp, atlmat, atldat) ",
               "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,today)  "
   prepare p_ctc91m14_005 from l_sql

   let l_sql = "SELECT COUNT(*)     ",
               "FROM datkrpdatdcen  ",
               "WHERE atdcencod = ? "
   prepare p_ctc91m14_006 from l_sql
   declare c_ctc91m14_006 cursor for p_ctc91m14_006

   let l_sql = "SELECT  atdcencod   ,atdcennom   ,atoflg      ,rspusrtip   ,rspempcod   ,rspfunmat ",
               "       ,C.funnom    ,lgdtipdes   ,lgdnom      ,lgdnum      ,endcmpdes ",
               "       ,brrnom      ,cidnom      ,endufdsgl   ,cepnum      ,cepcmpnum ",
               "       ,teldddnum   ,telnum      ,faxdddnum   ,faxnum      ,atdcenltt ",
               "       ,atdcenlgt   ,atdinchor   ,atdfnlhor   ,atdsemdiades ",
               "       ,atldat      ,B.funnom ",
               "FROM datkrpdatdcen A ",
               "LEFT JOIN isskfunc B ",
               "   ON A.atlusrtip = B.usrtip ",
               "  AND A.atlemp    = B.empcod ",
               "  AND A.atlmat    = B.funmat ",
               "LEFT JOIN isskfunc C ",
               "   ON A.rspusrtip = C.usrtip ",
               "  AND A.rspempcod = C.empcod ",
               "  AND A.rspfunmat = C.funmat ",
               "WHERE atdcencod = ? "
   prepare p_ctc91m14_008 from l_sql
   declare c_ctc91m14_008 cursor for p_ctc91m14_008

   let l_sql = "SELECT funnom    ",
               "FROM isskfunc    ",
               "WHERE funmat = ? ",
               "AND   empcod = ? ",
               "AND   usrtip = ? "
   prepare p_ctc91m14_009 from l_sql
   declare c_ctc91m14_009 cursor for p_ctc91m14_009


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
   prepare p_ctc91m14_010 from l_sql
   declare c_ctc91m14_010 cursor for p_ctc91m14_010
   
   let l_sql = "SELECT cidnom   , ",
              "        ufdcod     ",
              "  FROM  glakcid    ",
              " WHERE  cidcod = ? "
   prepare p_ctc91m14_011 from l_sql
   declare c_ctc91m14_011 cursor for p_ctc91m14_011
 
   let l_sql = "SELECT brrnom        ",
              "   FROM glakbrr       ",
              "  WHERE cidcod    = ? ",
              "    AND brrcod    = ? "
   prepare p_ctc91m14_012 from l_sql
   declare c_ctc91m14_012 cursor for p_ctc91m14_012

   let l_sql = " SELECT mpacidcod     ",           
               "   FROM datkmpacid    ",           
               "  WHERE cidnom =    ? ",           
               "    and ufdcod =    ? "           
   prepare p_ctc91m14_013 from l_sql
   declare c_ctc91m14_013 cursor for p_ctc91m14_013

   let l_sql = "  SELECT mpabrrcod       ",
               "    FROM datkmpabrr      ",
               "   WHERE mpacidcod = ?   ",
               "     AND brrnom    = ?   "
   prepare p_ctc91m14_014 from l_sql
   declare c_ctc91m14_014 cursor for p_ctc91m14_014

   let l_sql = " SELECT mpalgdcod        ",
               "   FROM datkmpalgd       ",
               "  WHERE lgdnom =      ?  ",
               "    AND   lgdtip =    ?  ",
               "    AND   mpacidcod = ?  "
   prepare p_ctc91m14_015 from l_sql
   declare c_ctc91m14_015 cursor for p_ctc91m14_015

   let l_sql = " SELECT lgdcep     ",
               "      , lgdcepcmp  ",
               "   FROM glaklgd    ",
               "  WHERE lgdtip = ? ",
               "    AND lgdnom = ? ",
               "    AND cidcod = ? "
   prepare p_ctc91m14_016 from l_sql               
   declare c_ctc91m14_016 cursor for p_ctc91m14_016
   
   let m_prep = true

#===============================================================================
end function # Fim da ctc91m14_prepare
#===============================================================================

#===============================================================================
 function ctc91m14()
#===============================================================================

   let int_flag = false
   initialize a_ctc91m14.*,
              a_titulo.*  to null

   if m_prep = false or
      m_prep is null then
      call ctc91m14_prepare()
   end if
   
   let a_titulo.label1 = "                          RESPONSAVEL"     
   let a_titulo.label2 = "                            ENDERECO"        
   let a_titulo.label3 = "                            CONTATOS"        
                                                                                          

# GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO
#   let g_issk.funmat = 12559
#   let g_issk.empcod = 1
#   let g_issk.usrtip = 'F'
# GLOBAIS --- COMENTAR QUANDO FOR PARA PRODUCAO

   open window w_ctc91m14 at 4,2 with form "ctc91m14"

   display by name a_titulo.label1 attribute(reverse)    
   display by name a_titulo.label2 attribute(reverse)    
   display by name a_titulo.label3 attribute(reverse)    
   
   menu "C.A.R."

      command key ("S") "Seleciona"
                        "Pesquisa CAR conforme criterios"
         call ctc91m14_seleciona()
         if a_ctc91m14.atdcencod is not null  then
            next option "Proximo"
         else
            error " Nenhum CAR selecionado!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"


      command key ("P") "Proximo"
                        "Mostra o proximo CAR"
         call ctc91m14_proximo()
         message " (F17)Abandona"

      command key ("A") "Anterior"
                        "Mostra o CAR anterior"
         call ctc91m14_anterior()
         message " (F17)Abandona"


      command key ("M") "Modifica"
                        "Modifica o CAR selecionado"
         if not (a_ctc91m14.atdcencod is null or a_ctc91m14.atdcencod = " ") then
            call ctc91m14_input("c")
         else
            error " Nenhum CAR selecionado!"
            next option "Seleciona"
         end if
         message " (F17)Abandona"


      command key ("I") "Inclui"
                        "Inclui CAR"
         message " (F17)Abandona"
         initialize a_ctc91m14.* to null
         display by name a_ctc91m14.*
         call ctc91m14_input("i")
         next option "Modifica"



      command key (interrupt,E) "Encerra"
                                "Retorna ao menu anterior"
         exit menu

   end menu

   close window w_ctc91m14

#===============================================================================
end function  # Fim da ctc91m14
#===============================================================================




#========================================================================
 function ctc91m14_proximo()
#========================================================================

   define l_cod like datkrpdatdcen.atdcencod

   let int_flag = false

   if a_ctc91m14.atdcencod = " " or
      a_ctc91m14.atdcencod is null then
      let a_ctc91m14.atdcencod = 0
   end if

   let l_cod = a_ctc91m14.atdcencod

   whenever error continue
      open c_ctc91m14_002 using a_ctc91m14.atdcencod
      fetch c_ctc91m14_002 into a_ctc91m14.atdcencod
      close c_ctc91m14_002
   whenever error stop
   call ctc91m14_preenche_car()

   if a_ctc91m14.atdcencod = " " or
      a_ctc91m14.atdcennom is null or
      a_ctc91m14.atdcennom = " " then
      let a_ctc91m14.atdcencod = l_cod
      call ctc91m14_preenche_car()
      error " Nao existe CAR nesta direcao!"
   end if

#========================================================================
 end function  # Fim da funcao ctc91m14_proximo
#========================================================================

#========================================================================
 function ctc91m14_anterior()
#========================================================================
   define l_cod like datkrpdatdcen.atdcencod

   let int_flag = false

   if a_ctc91m14.atdcencod = " " or
      a_ctc91m14.atdcencod is null then
      let a_ctc91m14.atdcencod = 0
   end if

   let l_cod = a_ctc91m14.atdcencod

   whenever error continue
      open c_ctc91m14_003 using a_ctc91m14.atdcencod
      fetch c_ctc91m14_003 into a_ctc91m14.atdcencod
      close c_ctc91m14_003
   whenever error stop
   call ctc91m14_preenche_car()

   if a_ctc91m14.atdcencod = " " or
      a_ctc91m14.atdcennom is null or
      a_ctc91m14.atdcennom = " " then
      let a_ctc91m14.atdcencod = l_cod
      call ctc91m14_preenche_car()
      error " Nao existe CAR nesta direcao!"
   end if

#========================================================================
 end function  # Fim da funcao ctc91m14_anterior
#========================================================================

#========================================================================
 function ctc91m14_seleciona()
#========================================================================
   define l_flg_ok char(1)
   define l_count  smallint

   let int_flag = false

   initialize a_ctc91m14.* to null
   display by name a_ctc91m14.*

   input by name a_ctc91m14.* without defaults

     #--------------------
      before field atdcencod
     #--------------------
         display by name a_ctc91m14.atdcencod attribute(reverse)

     #--------------------
      after field atdcencod
     #--------------------
         call ctc91m14_preenche_car()

         display by name a_ctc91m14.atdcencod attribute(normal)

         if a_ctc91m14.atdcencod = " " or
            a_ctc91m14.atdcennom is null or
            a_ctc91m14.atdcennom = " " then

            call cts08g01("A", "N",
                          " ",
                          "CAR NAO ENCONTRADO",
                          "DIGITE UM CODIGO DE CAR VALIDO.",
                          " ")
            returning l_flg_ok

            initialize a_ctc91m14.* to null
            display by name a_ctc91m14.*
            exit input
         end if

     #--------------------
      before field atdcennom
     #--------------------
         exit input

     #--------------------
      on key (interrupt)
     #--------------------
         exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize a_ctc91m14.* to null
      display by name a_ctc91m14.*
      error " Operacao cancelada!"
   end if

#========================================================================
 end function  # Fim da funcao ctc91m14_seleciona
#========================================================================

#========================================================================
 function ctc91m14_input(lr_param)
#========================================================================

   define lr_param record
      operacao char(1)
   end record

   define l_flg_ok   char(1)
   define l_operacao char(1)
   define l_count    smallint
   define l_temp     char(50)
   define l_cidcod   like glakcid.cidcod
   define l_brrcod   like glakbrr.brrcod
   define l_lgdcod   like glaklgd.lgdcod
   define l_cepnum   like  datkrpdatdcen.cepnum       
   define l_cepcmpnum like datkrpdatdcen.cepcmpnum    
   define l_latilong    smallint


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

   while true
   
      let l_latilong = 0
      message " (F17)Abandona"

      if lr_param.operacao = " " or
         lr_param.operacao is null then
         let l_operacao = "c"
      else
         let l_operacao = lr_param.operacao
      end if

      input by name a_ctc91m14.*  without defaults # from s2_ctc91m14.*
     

        #--------------------
         before field atdcencod
        #--------------------
            if l_operacao = "c" then
               next field next
            else
               display by name a_ctc91m14.atdcencod attribute(reverse)
            end if

        #--------------------
         after field atdcencod
        #--------------------
            if a_ctc91m14.atdcencod = 0 or
               a_ctc91m14.atdcencod = " " or
               a_ctc91m14.atdcencod is null then

               whenever error continue
               open c_ctc91m14_001
               fetch c_ctc91m14_001 into a_ctc91m14.atdcencod
               whenever error stop

            end if

            display by name a_ctc91m14.atdcencod attribute(normal)

            whenever error continue
            open c_ctc91m14_006 using a_ctc91m14.atdcencod
            fetch c_ctc91m14_006 into l_count
            whenever error stop

            if l_count > 0 then
               error " Este codigo ja existe, escolha outro."
               next field atdcencod
            end if

        #--------------------
         before field atdcennom
        #--------------------
            display by name a_ctc91m14.atdcennom attribute(reverse)
        #--------------------
         after field atdcennom
        #--------------------
            if a_ctc91m14.atdcennom is null or
               a_ctc91m14.atdcennom = " " then
               error " Preenchimento obrigatorio do Nome do CAR."
               next field atdcennom
            end if
            display by name a_ctc91m14.atdcennom attribute(normal)

        #--------------------
         before field atoflg
        #--------------------
            display by name a_ctc91m14.atoflg attribute(reverse)
            
        #--------------------
         after field atoflg
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up") and     
               fgl_lastkey() <> fgl_keyval("left") then          
               if a_ctc91m14.atoflg is null or
                  a_ctc91m14.atoflg = " " then
                  error " Preenchimento obrigatorio. CAR ativo? (S/N)"
                  next field atoflg
               end if
            end if
            
            let a_ctc91m14.atoflg = upshift(a_ctc91m14.atoflg)
            
            if a_ctc91m14.atoflg <> "S" and a_ctc91m14.atoflg <> "N" then               
               error " Preencha apenas S ou N."
               let a_ctc91m14.atoflg = " "
               next field atoflg
            end if
            
            display by name a_ctc91m14.atoflg attribute(normal)



        #--------------------
         before field rspusrtip
        #--------------------
            display by name a_ctc91m14.rspusrtip attribute(reverse)
        #--------------------
         after field rspusrtip
        #--------------------
            if a_ctc91m14.rspusrtip is null or
               a_ctc91m14.rspusrtip = " " then
               error " Preenchimento obrigatorio do Tipo de Usuario do Responsavel."
               next field rspusrtip
            end if
            display by name a_ctc91m14.rspusrtip attribute(normal)


        #--------------------
         before field rspempcod
        #--------------------
            display by name a_ctc91m14.rspempcod attribute(reverse)
        #--------------------
         after field rspempcod
        #--------------------
            if a_ctc91m14.rspempcod = 0 or
               a_ctc91m14.rspempcod is null or
               a_ctc91m14.rspempcod = " " then
               error " Preenchimento obrigatorio do Codigo da Empresa do Responsavel."
               next field rspempcod
            end if
            display by name a_ctc91m14.rspempcod attribute(normal)


        #--------------------
         before field rspfunmat
        #--------------------
            display by name a_ctc91m14.rspfunmat attribute(reverse)
        
        #--------------------
         after field rspfunmat
        #--------------------
            if a_ctc91m14.rspfunmat = 0 or
               a_ctc91m14.rspfunmat is null or
               a_ctc91m14.rspfunmat = " " then
               error " Preenchimento obrigatorio da Matricula do Responsavel."
               next field rspfunmat
            end if
            display by name a_ctc91m14.rspfunmat attribute(normal)
            
            let a_ctc91m14.rspfunnom = null
            
            whenever error continue
            open c_ctc91m14_009 using a_ctc91m14.rspfunmat
                                     ,a_ctc91m14.rspempcod
                                     ,a_ctc91m14.rspusrtip
            fetch c_ctc91m14_009 into a_ctc91m14.rspfunnom
            whenever error stop            
            
            display by name a_ctc91m14.rspfunnom
            
            if a_ctc91m14.rspfunnom is null or
               a_ctc91m14.rspfunnom = " " then
               error " Funcionario nao encontrado. Corrija os dados."
               next field rspusrtip
            end if

        #--------------------
         before field cepnum
        #--------------------
            display by name a_ctc91m14.cepnum attribute(reverse)
            let l_cepnum = a_ctc91m14.cepnum

        #--------------------
         after field cepnum
        #--------------------
            display by name a_ctc91m14.cepnum attribute(normal)

        #--------------------
         before field cepcmpnum
        #--------------------
            display by name a_ctc91m14.cepcmpnum attribute(reverse)
            let l_cepcmpnum = a_ctc91m14.cepcmpnum
            
        #--------------------
         after field cepcmpnum
        #--------------------
            display by name a_ctc91m14.cepcmpnum attribute(normal)
            
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.cepnum    is not null   and
                  a_ctc91m14.cepcmpnum is not null   then
                  
                  if  l_operacao = "c"              and
                      l_cepnum = a_ctc91m14.cepnum  and 
                      l_cepcmpnum = a_ctc91m14.cepcmpnum  then
                      next field lgdtipdes
                  else                 
                     let a_ctc91m14.lgdtipdes = null
                     let a_ctc91m14.lgdnom = null   
                     let a_ctc91m14.brrnom = null   
                     let a_ctc91m14.cidnom = null   
                     let a_ctc91m14.endufdsgl = null   
                     let a_ctc91m14.lgdnum = null
                                        
                     error "Pesquisando Endereco. Aguarde... " 
                     whenever error continue
                     
                     open c_ctc91m14_010 using a_ctc91m14.cepnum
                                              ,a_ctc91m14.cepcmpnum                                                    
                     fetch c_ctc91m14_010 into a_ctc91m14.lgdtipdes
                                              ,a_ctc91m14.lgdnom
                                              ,a_ctc91m14.brrnom
                                              ,a_ctc91m14.cidnom
                                              ,a_ctc91m14.endufdsgl
                     close c_ctc91m14_010
                     whenever error stop
                     
                     if sqlca.sqlcode = 100 or 
                        a_ctc91m14.lgdnom = "" or
                        a_ctc91m14.lgdnom is null then
                        error " CEP nao encontrado."
                        #next field cepnum
                     else
                        error 'Endereco encontrado.'
                     end if
                                                               
                     call cts06g06(a_ctc91m14.lgdnom)  returning a_ctc91m14.lgdnom
                     
                  end if
              else
                if a_ctc91m14.cepnum is not null then
                   error 'Digite o Complemento do CEP.'
                   next field cepcmpnum
                end if
              end if
            end if
            
            let a_ctc91m14.atdcenltt = ""
            let a_ctc91m14.atdcenlgt = ""          
            
            display by name a_ctc91m14.cepnum   
                           ,a_ctc91m14.cepcmpnum
                           ,a_ctc91m14.lgdtipdes
                           ,a_ctc91m14.lgdnom   
                           ,a_ctc91m14.cidnom   
                           ,a_ctc91m14.endufdsgl
                           ,a_ctc91m14.brrnom   
                           ,a_ctc91m14.lgdnum   
                           ,a_ctc91m14.atdcenltt
                           ,a_ctc91m14.atdcenlgt
                           
                           
        #--------------------
         before field atdcenltt
        #--------------------              
            if l_latilong = 0 then
               if fgl_lastkey() = fgl_keyval("up") or     
                  fgl_lastkey() = fgl_keyval("left") then
                  next field cepnum
               else
                  next field lgdtipdes
               end if
            end if
            display by name a_ctc91m14.atdcenltt attribute(reverse)

        #--------------------
         after field atdcenltt
        #--------------------            
            display by name a_ctc91m14.atdcenltt attribute(normal)
            if fgl_lastkey() = fgl_keyval("up") or     
               fgl_lastkey() = fgl_keyval("left") then
               let a_ctc91m14.atdcenltt = null
               let a_ctc91m14.atdcenlgt = null
               next field cepnum
            end if
            next field atdcenlgt
           
        #--------------------
         before field atdcenlgt
        #--------------------              
            if l_latilong = 0 then
               if fgl_lastkey() = fgl_keyval("up") or     
                  fgl_lastkey() = fgl_keyval("left") then
                  next field cepnum
               else
                  next field lgdtipdes
               end if
            end if
            display by name a_ctc91m14.atdcenlgt attribute(reverse)

        #--------------------
         after field atdcenlgt
        #--------------------    
            let l_latilong = 0        
            display by name a_ctc91m14.atdcenlgt attribute(normal)
            if fgl_lastkey() = fgl_keyval("up") or     
               fgl_lastkey() = fgl_keyval("left") then
               let a_ctc91m14.atdcenltt = null
               let a_ctc91m14.atdcenlgt = null
               next field cepnum
            end if
            next field teldddnum

            
        #--------------------
         before field lgdtipdes
        #--------------------
            display by name a_ctc91m14.lgdtipdes attribute(reverse)
        #--------------------
         after field lgdtipdes
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.lgdtipdes is null or
                  a_ctc91m14.lgdtipdes = " " then
                  error " Preenchimento obrigatorio do Tipo de Logradouro."
                  next field lgdtipdes
               end if        
            end if
            display by name a_ctc91m14.lgdtipdes attribute(normal)


        #--------------------
         before field lgdnom
        #--------------------
            display by name a_ctc91m14.lgdnom attribute(reverse)
        #--------------------
         after field lgdnom
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.lgdnom is null or
                  a_ctc91m14.lgdnom = " " then
                  error " Preenchimento obrigatorio do Nome de Logradouro."
                  next field lgdnom
               end if           
            end if
            display by name a_ctc91m14.lgdnom attribute(normal)


        #--------------------
         before field lgdnum
        #--------------------
            display by name a_ctc91m14.lgdnum attribute(reverse)
        #--------------------
         after field lgdnum
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.lgdnum is null or
                  a_ctc91m14.lgdnum = " " then
                  error " Preenchimento obrigatorio do Numero do Endereco."
                  next field lgdnum
               end if           
            end if
            display by name a_ctc91m14.lgdnum attribute(normal)

        #--------------------
         before field endcmpdes
        #--------------------
            display by name a_ctc91m14.endcmpdes attribute(reverse)
        #--------------------
         after field endcmpdes
        #--------------------
            display by name a_ctc91m14.endcmpdes attribute(normal)

        #--------------------
         before field brrnom
        #--------------------
            display by name a_ctc91m14.brrnom attribute(reverse)
        #--------------------
         after field brrnom
        #--------------------
            display by name a_ctc91m14.brrnom attribute(normal)

        #--------------------
         before field cidnom
        #--------------------
            display by name a_ctc91m14.cidnom attribute(reverse)
        #--------------------
         after field cidnom
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.cidnom is null or
                  a_ctc91m14.cidnom = " " then
                  error " Preenchimento obrigatorio da Cidade."
                  next field cidnom
               end if            
            end if
            display by name a_ctc91m14.cidnom attribute(normal)

        #--------------------
         before field endufdsgl
        #--------------------
            display by name a_ctc91m14.endufdsgl attribute(reverse)
        #--------------------
         after field endufdsgl
        #--------------------
            display by name a_ctc91m14.endufdsgl attribute(normal)
            
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.endufdsgl is null or
                  a_ctc91m14.endufdsgl = " " then
                  error " Preenchimento obrigatorio da UF."
                  next field endufdsgl
               end if          
            else
               next field cidnom
            end if  

            let l_geocodigo.cidcod = ""
            let l_geocodigo.cidnom = a_ctc91m14.cidnom
            let l_geocodigo.ufdcod = a_ctc91m14.endufdsgl
            let l_geocodigo.brrcod = ""         #l_brrcod
            let l_geocodigo.brrnom = a_ctc91m14.brrnom
            let l_geocodigo.logcod = ""         #l_lgdcod
            let l_geocodigo.logtip = a_ctc91m14.lgdtipdes
            let l_geocodigo.lognom = a_ctc91m14.lgdnom
            let l_geocodigo.lognum = a_ctc91m14.lgdnum
            let l_geocodigo.lcllgt = ""
            let l_geocodigo.lclltt = ""
            
            whenever error continue
            open  c_ctc91m14_013 using l_geocodigo.cidnom
                                     , l_geocodigo.ufdcod
            fetch  c_ctc91m14_013  into  l_geocodigo.cidcod 
            close c_ctc91m14_013
            whenever error stop
            
            whenever error continue
            open  c_ctc91m14_014 using l_geocodigo.cidcod
                                     , l_geocodigo.brrnom
            fetch  c_ctc91m14_014  into  l_geocodigo.brrcod
            close c_ctc91m14_014
            whenever error stop
            
            whenever error continue
            open  c_ctc91m14_015 using l_geocodigo.lognom 
                                     , l_geocodigo.logtip
                                     , l_geocodigo.cidcod  
            fetch  c_ctc91m14_015  into  l_geocodigo.logcod
            close c_ctc91m14_015
            whenever error stop
             
            # ---- BUSCAR LATITUDE / LONGITUDE ---- #
            call ctc91m14_geocodificar_endereco(l_geocodigo.*)
               returning l_geocodigo.*
                              
            let l_cepnum    = null
            let l_cepcmpnum = null  
                
            #display "BUSCA CEP"   
            #display "l_geocodigo.logtip: ", l_geocodigo.logtip
            #display "l_geocodigo.lognom: ", l_geocodigo.lognom
            #display "l_geocodigo.cidcod: ", l_geocodigo.cidcod
            
            whenever error continue
            open  c_ctc91m14_016 using l_geocodigo.logtip
                                     , l_geocodigo.lognom 
                                     , l_geocodigo.cidcod
            fetch c_ctc91m14_016 into l_cepnum    #a_ctc91m18a.cepnum
                                    , l_cepcmpnum #a_ctc91m18a.cepcplnum
            close c_ctc91m14_016
            whenever error stop
            
            if l_cepnum is not null and 
               l_cepnum <> 0 then
               
               let a_ctc91m14.cepnum = l_cepnum
               let a_ctc91m14.cepcmpnum = l_cepcmpnum
            end if
                         
            display by name a_ctc91m14.cepnum
                           ,a_ctc91m14.cepcmpnum            

            let a_ctc91m14.atdcenltt = l_geocodigo.lclltt 
            let a_ctc91m14.atdcenlgt = l_geocodigo.lcllgt            
                           
            display by name a_ctc91m14.atdcenltt                   
                           ,a_ctc91m14.atdcenlgt attribute(normal)            

            if a_ctc91m14.atdcenltt is null or
               a_ctc91m14.atdcenlgt is null then
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
                  next field atdcenltt
               end if
   
            else
               error "Latitude e Longitude encontrados."
            end if       
            next field teldddnum
                          
        #--------------------
         before field teldddnum
        #--------------------
            display by name a_ctc91m14.teldddnum attribute(reverse)

        #--------------------
         after field teldddnum
        #--------------------
           if fgl_lastkey() <> fgl_keyval("up")    and
              fgl_lastkey() <> fgl_keyval("left")  then
              if a_ctc91m14.teldddnum is null or
                 a_ctc91m14.teldddnum = " " then
                 error " Preenchimento obrigatorio do DDD/Telefone."
                 next field teldddnum
              end if                
           else
             display by name a_ctc91m14.teldddnum attribute(normal)
             next field endufdsgl
           end if
           
           display by name a_ctc91m14.teldddnum attribute(normal)
           

        #--------------------
         before field telnum
        #--------------------
            display by name a_ctc91m14.telnum attribute(reverse)
        #--------------------
         after field telnum
        #--------------------
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if a_ctc91m14.telnum is null or
                a_ctc91m14.telnum = " " then
                error " Preenchimento obrigatorio do DDD/Telefone."
                next field telnum
             end if             
          end if
         display by name a_ctc91m14.telnum attribute(normal)

        #--------------------
         before field faxdddnum
        #--------------------
            display by name a_ctc91m14.faxdddnum attribute(reverse)
        #--------------------
         after field faxdddnum
        #--------------------
            display by name a_ctc91m14.faxdddnum attribute(normal)

        #--------------------
         before field faxnum
        #--------------------
            display by name a_ctc91m14.faxnum attribute(reverse)
        #--------------------
         after field faxnum
        #--------------------
            display by name a_ctc91m14.faxnum attribute(normal)

        #--------------------
         before field atdinchor
        #--------------------
            display by name a_ctc91m14.atdinchor attribute(reverse)
        #--------------------
         after field atdinchor
        #--------------------
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if a_ctc91m14.atdinchor is null or
                a_ctc91m14.atdinchor = " " then
                error " Preenchimento obrigatorio da Hora Inicio do Atendimento."
                next field atdinchor
             end if       
          end if
          display by name a_ctc91m14.atdinchor attribute(normal)

        #--------------------
         before field atdfnlhor
        #--------------------
            display by name a_ctc91m14.atdfnlhor attribute(reverse)
        #--------------------
         after field atdfnlhor
        #--------------------
          if fgl_lastkey() <> fgl_keyval("up")    and
             fgl_lastkey() <> fgl_keyval("left")  then
             if a_ctc91m14.atdfnlhor is null or
                a_ctc91m14.atdfnlhor = " " then
                error " Preenchimento obrigatorio da Hora Final do Atendimento."
                next field atdfnlhor
             end if             
          end if
          display by name a_ctc91m14.atdfnlhor attribute(normal)

        #--------------------
         before field atdsemdiades
        #--------------------
            display by name a_ctc91m14.atdsemdiades attribute(reverse)
        #--------------------
         after field atdsemdiades
        #--------------------
            if fgl_lastkey() <> fgl_keyval("up")    and
               fgl_lastkey() <> fgl_keyval("left")  then
               if a_ctc91m14.atdsemdiades is null or
                  a_ctc91m14.atdsemdiades = " " then
                  error " Preenchimento obrigatorio dos dias da semana de Atendimento."
                  next field atdsemdiades
               end if          
               display by name a_ctc91m14.atdsemdiades attribute(normal)
               
               if l_operacao = "c" then
                  if ctc91m14_modifica_car() then
                     let int_flag = true
                  end if
                  exit input
               else
                  if ctc91m14_inclui_car() then
                     let int_flag = true
                  end if
                  exit input
               end if
           end if
           display by name a_ctc91m14.atdsemdiades attribute(normal)
               
        #--------------------
          on key (interrupt, control-c)
        #--------------------
          initialize a_ctc91m14.* to null
          display by name a_ctc91m14.*
          let int_flag = true
          exit input

      end input


      if int_flag  then
         exit while
      end if

   end while

   let int_flag = false
   message " "

#========================================================================
 end function  # Fim da funcao ctc91m14_input
#========================================================================


#========================================================================
 function ctc91m14_preenche_car()
#========================================================================

   whenever error continue
   open c_ctc91m14_008 using a_ctc91m14.atdcencod
   fetch c_ctc91m14_008 into a_ctc91m14.atdcencod
                            ,a_ctc91m14.atdcennom
                            ,a_ctc91m14.atoflg
                            ,a_ctc91m14.rspusrtip
                            ,a_ctc91m14.rspempcod
                            ,a_ctc91m14.rspfunmat
                            ,a_ctc91m14.rspfunnom
                            ,a_ctc91m14.lgdtipdes
                            ,a_ctc91m14.lgdnom
                            ,a_ctc91m14.lgdnum
                            ,a_ctc91m14.endcmpdes
                            ,a_ctc91m14.brrnom
                            ,a_ctc91m14.cidnom
                            ,a_ctc91m14.endufdsgl
                            ,a_ctc91m14.cepnum
                            ,a_ctc91m14.cepcmpnum
                            ,a_ctc91m14.teldddnum
                            ,a_ctc91m14.telnum
                            ,a_ctc91m14.faxdddnum
                            ,a_ctc91m14.faxnum
                            ,a_ctc91m14.atdcenltt
                            ,a_ctc91m14.atdcenlgt
                            ,a_ctc91m14.atdinchor
                            ,a_ctc91m14.atdfnlhor
                            ,a_ctc91m14.atdsemdiades
                            ,a_ctc91m14.atldat
                            ,a_ctc91m14.atlfunnom
   whenever error stop



   if a_ctc91m14.atdcencod is null or
      a_ctc91m14.atdcennom = " " or
      a_ctc91m14.atdcennom is null then
      initialize a_ctc91m14.* to null
   end if

   display by name a_ctc91m14.*

#========================================================================
 end function  # Fim da funcao ctc91m14_preenche_car
#========================================================================

#========================================================================
 function ctc91m14_inclui_car()
#========================================================================
   define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA INCLUSAO",
                 "DO CAR?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      whenever error continue
      execute p_ctc91m14_005 using a_ctc91m14.atdcencod
                                  ,a_ctc91m14.atdcennom
                                  ,a_ctc91m14.atoflg
                                  ,a_ctc91m14.rspusrtip
                                  ,a_ctc91m14.rspempcod
                                  ,a_ctc91m14.rspfunmat
                                  ,a_ctc91m14.lgdtipdes
                                  ,a_ctc91m14.lgdnom
                                  ,a_ctc91m14.lgdnum
                                  ,a_ctc91m14.endcmpdes
                                  ,a_ctc91m14.brrnom
                                  ,a_ctc91m14.cidnom
                                  ,a_ctc91m14.endufdsgl
                                  ,a_ctc91m14.cepnum
                                  ,a_ctc91m14.cepcmpnum
                                  ,a_ctc91m14.atdcenltt
                                  ,a_ctc91m14.atdcenlgt
                                  ,a_ctc91m14.teldddnum
                                  ,a_ctc91m14.telnum
                                  ,a_ctc91m14.faxdddnum
                                  ,a_ctc91m14.faxnum
                                  ,a_ctc91m14.atdinchor
                                  ,a_ctc91m14.atdfnlhor
                                  ,a_ctc91m14.atdsemdiades
                                  ,g_issk.usrtip
                                  ,g_issk.empcod
                                  ,g_issk.funmat
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao incluir CAR. Tabela <datkrpdatdcen>."
         sleep 3
         return false
      end if

      error "Inclusao realizada com sucesso."
   else
      return false
   end if

   return true
#========================================================================
 end function  # Fim da funcao ctc91m14_inclui_car
#========================================================================

#========================================================================
 function ctc91m14_modifica_car()
#========================================================================
   define l_flg_ok char(1)

   call cts08g01("C", "S",
                 " ",
                 "CONFIRMA ALTERACAO",
                 "DO CAR SELECIONADO?",
                 " ")
   returning l_flg_ok

   if l_flg_ok = "S" then

      error "Aguarde..."

      whenever error continue
      execute p_ctc91m14_004 using a_ctc91m14.atdcennom
                                  ,a_ctc91m14.atoflg
                                  ,a_ctc91m14.rspusrtip
                                  ,a_ctc91m14.rspempcod
                                  ,a_ctc91m14.rspfunmat
                                  ,a_ctc91m14.lgdtipdes
                                  ,a_ctc91m14.lgdnom
                                  ,a_ctc91m14.lgdnum
                                  ,a_ctc91m14.endcmpdes
                                  ,a_ctc91m14.brrnom
                                  ,a_ctc91m14.cidnom
                                  ,a_ctc91m14.endufdsgl
                                  ,a_ctc91m14.cepnum
                                  ,a_ctc91m14.cepcmpnum
                                  ,a_ctc91m14.atdcenltt
                                  ,a_ctc91m14.atdcenlgt
                                  ,a_ctc91m14.teldddnum
                                  ,a_ctc91m14.telnum
                                  ,a_ctc91m14.faxdddnum
                                  ,a_ctc91m14.faxnum
                                  ,a_ctc91m14.atdinchor
                                  ,a_ctc91m14.atdfnlhor
                                  ,a_ctc91m14.atdsemdiades
                                  ,g_issk.usrtip
                                  ,g_issk.empcod
                                  ,g_issk.funmat
                                  ,a_ctc91m14.atdcencod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode clipped, ") ao atualizar CAR. Tabela <datkrpdatdcen>."
         sleep 3
         return false
      end if

      error "Alteracao realizada com sucesso."
   else
      return false
   end if

   return true
#========================================================================
 end function  # Fim da funcao ctc91m14_modifica_car
#========================================================================

#========================================================================
 function ctc91m14_geocodificar_endereco(l_geocodigo) 
#========================================================================
# Indicacao de Roberto Melo para replicar essa funcao do modulo ctx32g00,
# pois fica inviavel adiciona-lo na formacao devido quantidade de modulos que puxa.


 define l_select     char(1500)
    
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
    
    #------ pesquisa de ltt e lgt ------#
    if l_geocodigo.cidcod is not null then
       if l_geocodigo.logcod is not null then
          let l_select = "SELECT lcllgt,       ",
                         "       lclltt        ",
                         "  FROM datkmpalgdsgm ",
                         " WHERE mpacidcod = ? ",
                         "   AND mpalgdcod = ? "
        
             if l_geocodigo.lognum is not null then
                 let l_select = l_select clipped, 
                                " AND mpalgdincnum <= ? ",
                                " AND mpalgdfnlnum >= ? "
                          
                 prepare p_ctc91m14_geo from l_select
                 declare c_ctc91m14_geo cursor for p_ctc91m14_geo
                   
                 open c_ctc91m14_geo using l_geocodigo.cidcod,
                                           l_geocodigo.logcod,
                                           l_geocodigo.lognum,
                                           l_geocodigo.lognum
             
                 fetch c_ctc91m14_geo into l_geocodigo.lcllgt,
                                           l_geocodigo.lclltt
              else
                   
                 let l_select = l_select clipped, 
                 " and mpalgdsgmseq = 1 "  
             
                 prepare p_ctc91m14_geo2 from l_select
                 declare c_ctc91m14_geo2 cursor for p_ctc91m14_geo2
                   
                 open c_ctc91m14_geo2 using l_geocodigo.cidcod,
                                            l_geocodigo.logcod
             
                 fetch c_ctc91m14_geo2 into l_geocodigo.lcllgt,
                                            l_geocodigo.lclltt
             
             end if  
                
       else
    
           if l_geocodigo.brrcod is not null then
              let l_select = "SELECT lcllgt,       ",
                             "       lclltt        ",
                             "  FROM datkmpabrr    ",
                             " WHERE mpacidcod = ? ",
                             "   AND mpabrrcod = ? "
           
              prepare p_ctc91m14_geo3 from l_select
              declare c_ctc91m14_geo3 cursor for p_ctc91m14_geo3
                 
              open c_ctc91m14_geo3 using l_geocodigo.cidcod,
                                         l_geocodigo.brrcod
          
              fetch c_ctc91m14_geo3 into l_geocodigo.lcllgt,
                                         l_geocodigo.lclltt
         
           else
              let l_select = "SELECT lcllgt,       ",
                             "       lclltt        ",
                             "  FROM datkmpacid    ",
                             " WHERE mpacidcod = ? "
                 
              prepare p_ctc91m14_geo4 from l_select
              declare c_ctc91m14_geo4 cursor for p_ctc91m14_geo4
                
              open c_ctc91m14_geo4 using l_geocodigo.cidcod
                                    
              fetch c_ctc91m14_geo4 into l_geocodigo.lcllgt,
                                         l_geocodigo.lclltt
           end if
       end if
    else
      return l_geocodigo.*
    end if
      
    return l_geocodigo.*
#========================================================================
 end function  # Fim da funcao ctc91m14_geocodificar_endereco
#========================================================================
