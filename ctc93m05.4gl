#-----------------------------------------------------------------------------#
# Porto Seguro Cia de Seguros                                                 #
#.............................................................................#
# Sistema.......: Porto Socorro                                               #
# Modulo........: ctc93m05                                                    #
# Analista Resp.: Beatriz Araujo                                              #
# PSI...........: PSI-2012-00287/EV                                           #
# Objetivo......: Tela de cadastro de contabilizacao                          #
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
database porto
 
globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_ctc93m05_prep smallint

#-------------------------#
function ctc93m05_prepare()
#-------------------------#

  define l_sql char(10000)
  
   let l_sql = "Select cpodes     ",                  
               "  from iddkdominio",                  
               " where cponom = ?",                   
               "   and cpocod =? "                    
   prepare pctc93m05001 from l_sql                 
   declare cctc93m05001 cursor for pctc93m05001 
   
   let l_sql = "select empsgl     ",            
               "  from gabkemp    ",            
               " where empcod = ? "             
   prepare pctc93m05002 from l_sql              
   declare cctc93m05002 cursor for pctc93m05002 
   
   
   let l_sql = "select itaasiplntipdes ",            
               "  from datkasttip    ",            
               " where itaasiplntipcod = ? "             
   prepare pctc93m05003 from l_sql              
   declare cctc93m05003 cursor for pctc93m05003
   
   
   let l_sql = "select c24astagpdes ",            
               "  from datkastagp    ",            
               " where c24astagp = ? "             
   prepare pctc93m05004 from l_sql              
   declare cctc93m05004 cursor for pctc93m05004
   
   
   let l_sql = "select a.ctbevnpamcod,",
                "      a.srvpovevncod,",   
                "      a.srvajsevncod,",  
                "      a.srvbxaevncod,",  
                "      a.srvpgtevncod,",  # colocar o evento de pagamento
                "      a.atopamflg   ,",  
                "      a.atldat      ,",  
                "      a.atlusrtip   ,",
                "      a.atlemp      ,",
                "      a.atlmat       ",
                " from dbskctbevnpam a ",
                "where a.empcod       = ? ",
                "  and a.pcpsgrramcod = ? ",
                "  and a.pcpsgrmdlcod = ? ",
                "  and a.ctbsgrramcod = ? ",
                "  and a.ctbsgrmdlcod = ? ",
                "  and a.pgoclsflg    = ? ",
                "  and a.clscod       = ? ", # colcoar a clausula que foi digitada
                "  and a.srvdcrcod    = ? ",
                "  and a.itaasstipcod = ? ",
                "  and a.bemcod       = ? ",
                "  and a.srvatdctecod = ? ",
                "  and a.c24astagp    = ? ",
                "  and a.c24astcod    = ? ", # colocar o assunto 
                "  and a.ctbevnpamcod    = (select max(b.ctbevnpamcod) ",
                                            " from dbskctbevnpam b ",
                                            "where b.empcod       = a.empcod        ",
                                            "  and b.pcpsgrramcod = a.pcpsgrramcod  ",
                                            "  and b.pcpsgrmdlcod = a.pcpsgrmdlcod  ",
                                            "  and b.ctbsgrramcod = a.ctbsgrramcod  ",
                                            "  and b.ctbsgrmdlcod = a.ctbsgrmdlcod  ",
                                            "  and b.pgoclsflg    = a.pgoclsflg     ",
                                            "  and b.clscod       = a.clscod        ", # colcoar a clausula que foi digitada
                                            "  and b.srvdcrcod    = a.srvdcrcod     ",
                                            "  and b.itaasstipcod = a.itaasstipcod  ",
                                            "  and b.bemcod       = a.bemcod        ",
                                            "  and b.srvatdctecod = a.srvatdctecod  ",
                                            "  and b.c24astagp    = a.c24astagp     ",
                                            "  and b.c24astcod    = a.c24astcod)" # colocar o assunto
   prepare pctc93m05005 from l_sql              
   declare cctc93m05005 cursor for pctc93m05005
    
   let l_sql = "select max(ctbevnpamcod) ",
               "  from dbskctbevnpam "
               
   prepare pctc93m05006 from l_sql              
   declare cctc93m05006 cursor for pctc93m05006
   
   
   let l_sql = " insert into dbskctbevnpam                                ",
               "       (ctbevnpamcod,empcod,pcpsgrramcod,pcpsgrmdlcod,    ",
               "        ctbsgrramcod,ctbsgrmdlcod,pgoclsflg,srvdcrcod,    ",
               "        itaasstipcod,bemcod,srvatdctecod,c24astagp,       ",
               "        srvpovevncod,srvajsevncod,srvbxaevncod,atopamflg, ",
               "        atlusrtip,atlemp,atlmat,atldat,clscod,c24astcod,srvpgtevncod )",
               " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
               
   prepare pctc93m05007 from l_sql 
   
   
   let l_sql = " update dbskctbevnpam set(atopamflg) = ('C') ",
                 "where empcod       = ? ",
                 "  and pcpsgrramcod = ? ",
                 "  and pcpsgrmdlcod = ? ",
                 "  and ctbsgrramcod = ? ",
                 "  and ctbsgrmdlcod = ? ",
                 "  and pgoclsflg    = ? ",
                 "  and clscod       = ? ",
                 "  and srvdcrcod    = ? ",
                 "  and itaasstipcod = ? ",
                 "  and bemcod       = ? ",
                 "  and srvatdctecod = ? ",
                 "  and c24astagp    = ? ",
                 "  and c24astcod    = ? "
               
   prepare pctc93m05008 from l_sql              
   
   let l_sql = "select ctbevnpamcod, ",
                "      srvpovevncod, ",   
                "      srvajsevncod, ",  
                "      srvbxaevncod, ",  
                "      srvpgtevncod, ",
                "      atopamflg   , ",  
                "      atldat      , ",  
                "      atlusrtip   , ",
                "      atlemp      , ",
                "      atlmat        ",
                " from dbskctbevnpam ",
               "where empcod       = ? ",
               "  and pcpsgrramcod = ? ",
               "  and pcpsgrmdlcod = ? ",
               "  and ctbsgrramcod = ? ",
               "  and ctbsgrmdlcod = ? ",
               "  and pgoclsflg    = ? ",
               "  and clscod       = ? ",
               "  and srvdcrcod    = ? ",
               "  and itaasstipcod = ? ",
               "  and bemcod       = ? ",
               "  and srvatdctecod = ? ",
               "  and c24astagp    = ? ",
               "  and c24astcod    = ? ",
               " order by ctbevnpamcod "
               
   prepare pctc93m05009 from l_sql              
   declare cctc93m05009 cursor for pctc93m05009
   
   let l_sql = "select c24astdes ",            
               "  from datkassunto    ",            
               " where c24astcod = ? " 
                           
   prepare pctc93m05010 from l_sql              
   declare cctc93m05010 cursor for pctc93m05010
   
   let l_sql = "select srvpovevncod, ",   
                "      srvajsevncod, ",  
                "      srvbxaevncod, ",  
                "      srvpgtevncod, ",
                "      atopamflg   , ",  
                "      atldat      , ",  
                "      atlusrtip   , ",
                "      atlemp      , ",
                "      atlmat      , ",
                "      empcod      , ",
                "      pcpsgrramcod, ",
                "      pcpsgrmdlcod, ",
                "      ctbsgrramcod, ",
                "      ctbsgrmdlcod, ",
                "      pgoclsflg   , ",
                "      clscod      , ",
                "      srvdcrcod   , ",
                "      itaasstipcod, ",
                "      bemcod      , ",
                "      srvatdctecod, ",
                "      c24astagp   , ",
                "      c24astcod     ",
                " from dbskctbevnpam ", 
               "where ctbevnpamcod = ? "
               
   prepare pctc93m05011 from l_sql              
   declare cctc93m05011 cursor for pctc93m05011 
   
  let m_ctc93m05_prep = true

end function

#------------------------------------------------------------
 function ctc93m05()
#------------------------------------------------------------

define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(200)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record  

define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod

initialize d_ctc93m05.* to null
  
   if not get_niv_mod(g_issk.prgsgl, "ctc93m05") then
      error " Modulo sem nivel de consulta e atualizacao!"
      return
   end if
  
  
open window ctc93m05 at 04,02 with form "ctc93m05"

display by name d_ctc93m05.empcod         ,
                d_ctc93m05.empsgl         ,
                d_ctc93m05.pcpsgrramcod   ,
                d_ctc93m05.pcpsgrmdlcod   ,
                d_ctc93m05.ctbsgrramcod   ,
                d_ctc93m05.ctbsgrmdlcod   ,
                d_ctc93m05.pgoclsflg      ,
                d_ctc93m05.clscod         ,
                d_ctc93m05.srvdcrcod      ,
                d_ctc93m05.srvdcrdes      ,
                d_ctc93m05.itaasstipcod   ,
                d_ctc93m05.itaasiplntipdes,
                d_ctc93m05.bemcod         ,
                d_ctc93m05.bemdes         ,
                d_ctc93m05.srvatdctecod   ,
                d_ctc93m05.srvatdctedes   ,
                d_ctc93m05.c24astagp      ,
                d_ctc93m05.c24astagpdes   ,
                d_ctc93m05.c24astcod      ,
                d_ctc93m05.c24astdes      ,
                d_ctc93m05.srvpovevncod   ,
                d_ctc93m05.srvajsevncod   ,
                d_ctc93m05.srvbxaevncod   , 
                d_ctc93m05.srvpgtevncod   , 
                d_ctc93m05.atopamflg 
menu "Contabilizacao"
   
   before menu
     hide option all
     if g_issk.acsnivcod >= g_issk.acsnivcns  then
        show option "Seleciona", "Proximo" , "Anterior", "Historico"
     end if
     if g_issk.acsnivcod >= g_issk.acsnivatl  then
        show option "Seleciona", "Proximo", "Anterior",
                     "Inclui" ,"Modifica" ,"Historico"
     end if
     
     show option "Encerra"
  command key ("S") "Seleciona"
                   "Seleciona de/para contabilizacao"
                   call ctc93m05_seleciona(d_ctc93m05.*) 
                        returning d_ctc93m05.*,l_ctbevnpamcod
                   if d_ctc93m05.empcod  is not null  then
                      message ""
                      next option "Proximo"
                   else
                      error " Nenhum cadastro selecionado!"
                      message ""
                      next option "Seleciona"
                   end if
                   
                   
 command key ("P") "Proximo"
                   "Proximo de/para contabilizacao"
                   call ctc93m05_proximo(d_ctc93m05.*,l_ctbevnpamcod)
                   error "Funcao nao implementada"
                   message " " 
 
 command key ("A") "Anterior"
                   "Anterior de/para contabilizacao"
                   call ctc93m05_anterior(d_ctc93m05.*,l_ctbevnpamcod)
                   error "Funcao nao implementada"
                   message " "
                   
 command key ("I") "Inclui"
                   "Cadastra de/para contabilizacao"
                   call ctc93m05_inclui(d_ctc93m05.*) returning d_ctc93m05.*
                   message ""
                   next option "Seleciona"
                
 command key ("M") "Modifica"
                   "Modifica de/para contabilizacao"
                   if d_ctc93m05.empcod  is not null  then
                      call ctc93m05_modifica(d_ctc93m05.*)
                           returning d_ctc93m05.*
                      next option "Seleciona"
                   else
                      error " Nenhuma parametrizacao selecionada!"
                      message ""
                      next option "Seleciona"
                   end if
                   message " "
                   
 command key ("H") "Historico"
                   "Historico de/para contabilizacao"
                   call ctc93m05_historico(d_ctc93m05.*)
   
 command key (interrupt,E) "Encerra"
                   "Retorna ao menu anterior"
          exit menu
 end menu

  close window ctc93m05
  
end function

#------------------------------------------------------------
 function ctc93m05_seleciona(d_ctc93m05)
#------------------------------------------------------------

 define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record 
 
 define lr_retorno record
    erro           smallint,
    ciaempcod      like datkalgmtv.ciaempcod,
    empnom         like gabkemp.empnom
 end record 
 
 define l_cponom like iddkdominio.cponom
 
 define l_ctbevnpamcod   like dbskctbevnpam.ctbevnpamcod  
 
 
 if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if

 let int_flag = false
 initialize d_ctc93m05.*  to null
 clear form

 input by name d_ctc93m05.empcod,          
               d_ctc93m05.pcpsgrramcod,    
               d_ctc93m05.pcpsgrmdlcod,    
               d_ctc93m05.ctbsgrramcod,    
               d_ctc93m05.ctbsgrmdlcod,    
               d_ctc93m05.clscod,       
               d_ctc93m05.pgoclsflg,
               d_ctc93m05.srvdcrcod,       
               d_ctc93m05.itaasstipcod, 
               d_ctc93m05.bemcod,          
               d_ctc93m05.srvatdctecod,    
               d_ctc93m05.c24astagp,
               d_ctc93m05.c24astcod 
         
        # Empresa
        before field empcod
            display by name d_ctc93m05.empcod attribute (reverse)
        
        after  field empcod
            display by name d_ctc93m05.empcod 
            if d_ctc93m05.empcod  is null   then
               error " Empresa deve ser informada!"
               call cty14g00_popup_empresa()  
                returning lr_retorno.erro, 
                          lr_retorno.ciaempcod, 
                          lr_retorno.empnom  
               let d_ctc93m05.empcod =  lr_retorno.ciaempcod            
               next field empcod
            end if
           
            open cctc93m05002 using  d_ctc93m05.empcod  
                                                  
            fetch cctc93m05002 into d_ctc93m05.empsgl   
            
            close cctc93m05002
            if sqlca.sqlcode  =  notfound   then
               error " Empresa nao cadastrada!"
               next field empcod
            end if
            display by name d_ctc93m05.empsgl
        
        # ramo Principal
        before field pcpsgrramcod
            display by name d_ctc93m05.pcpsgrramcod attribute (reverse)
        
        after  field pcpsgrramcod
             if fgl_lastkey() <> fgl_keyval("up")   and 
                fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.pcpsgrramcod
               if d_ctc93m05.pcpsgrramcod  is null   then
                  error " Ramo principal deve ser informado!"           
                  next field pcpsgrramcod
               end if
             end if 
        
        # Modalidade Principal
        before field pcpsgrmdlcod
            display by name d_ctc93m05.pcpsgrmdlcod attribute (reverse)
        
        after  field pcpsgrmdlcod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.pcpsgrmdlcod
               if d_ctc93m05.pcpsgrmdlcod  is null   then
                  error " Modalidade principal deve ser informado!"           
                  next field pcpsgrmdlcod
               end if
            end if 
            
        # Ramo Contabil
        before field ctbsgrramcod
            display by name d_ctc93m05.ctbsgrramcod attribute (reverse)
        
        after  field ctbsgrramcod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.ctbsgrramcod
               if d_ctc93m05.ctbsgrramcod  is null   then
                  error " Ramo Contabil deve ser informado!"           
                  next field ctbsgrramcod
               end if
            end if 
        
        # Modalidade Contabil
        before field ctbsgrmdlcod
            display by name d_ctc93m05.ctbsgrmdlcod attribute (reverse)
        
        after  field ctbsgrmdlcod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.ctbsgrmdlcod
               if d_ctc93m05.ctbsgrmdlcod  is null   then
                  error " Modalidade Contabil deve ser informado!"           
                  next field ctbsgrmdlcod
               end if
            end if 
        
        # clausula do servico
         before field clscod
            error " Caso a clausula do servico nao seja necessaria coloque '0'"                                      
            display by name d_ctc93m05.clscod attribute (reverse)
        
        after  field clscod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               
               display by name d_ctc93m05.clscod 
               
               if d_ctc93m05.clscod is null then
                  error " Caso a clausula do servico nao seja necessaria coloque '0'"           
                  next field clscod
               end if   
            end if 
        
        
        #Clausula Paga?
        before field pgoclsflg
            error "Digite apenas S-Sim, N-Nao, B-Beneficio"
            display by name d_ctc93m05.pgoclsflg attribute (reverse)
        
        after  field pgoclsflg
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.pgoclsflg 
               if d_ctc93m05.pgoclsflg  is null   then
                  error " Clausula Paga deve ser informada!"           
                  next field pgoclsflg
               end if
               
               if d_ctc93m05.pgoclsflg <> 'S' and 
                  d_ctc93m05.pgoclsflg <> 'N' and 
                  d_ctc93m05.pgoclsflg <> 'B' then 
                  error "Digite apenas S-Sim, N-Nao, B-Beneficio"
                  next field pgoclsflg
               end if    
            end if 
        
        # Decorrencia do servico
        before field srvdcrcod                                       
            display by name d_ctc93m05.srvdcrcod attribute (reverse)   
                                                                    
        after  field srvdcrcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvdcrcod
               
               if d_ctc93m05.srvdcrcod  is null   then
                   error " Decorrencia do Servico deve ser informada!"
                   call ctn36c00("Decorrencia do Servico", "decservico")
                        returning  d_ctc93m05.srvdcrcod
                   next field srvdcrcod
                end if
                
                let l_cponom = "decservico"
                  
                open cctc93m05001  using l_cponom,d_ctc93m05.srvdcrcod
                fetch cctc93m05001 into d_ctc93m05.srvdcrdes 
                close cctc93m05001
                if sqlca.sqlcode  =  notfound   then
                   error " Decorrencia do Servico nao cadastrada!"
                   call ctn36c00("Decorrencia do Servico", "decservico")
                        returning  d_ctc93m05.srvdcrcod
                   next field srvdcrcod
                end if
                display by name d_ctc93m05.srvdcrdes
            end if 
            
        # Para quem os ervico foi prestado
        before field itaasstipcod                                       
            display by name d_ctc93m05.itaasstipcod attribute (reverse)   
                                                                    
        after  field itaasstipcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.itaasstipcod 
               
               if d_ctc93m05.itaasstipcod  is null   then
                   error " Para quem o servico foi prestado deve ser informado!"
                   call ctx35g00_popup()
                        returning  d_ctc93m05.itaasstipcod,
                                   d_ctc93m05.itaasiplntipdes
                   next field itaasstipcod
                end if
                
                if d_ctc93m05.itaasstipcod <> 2 and 
                   d_ctc93m05.itaasstipcod <> 9 and
                   d_ctc93m05.itaasstipcod <> 3 then
                   error " Para quem o servico foi prestado esta invalido!"
                   next field itaasstipcod
                end if 
                
                open cctc93m05003 using d_ctc93m05.itaasstipcod
                fetch cctc93m05003 into d_ctc93m05.itaasiplntipdes
                close cctc93m05003
                
                display by name d_ctc93m05.itaasiplntipdes
            end if      
            
        # bem atendido   
        before field bemcod                                       
            display by name d_ctc93m05.bemcod attribute (reverse)   
                                                                    
        after  field bemcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.bemcod 
               
               if d_ctc93m05.bemcod  is null   then
                   error " Bem atendido deve ser informado!"
                   call ctn36c00("Bem atendido", "bemAtendido")
                        returning  d_ctc93m05.bemcod
                   next field bemcod
                end if
                
                let l_cponom = "bemAtendido"
                  
                open cctc93m05001  using l_cponom,d_ctc93m05.bemcod
                fetch cctc93m05001 into d_ctc93m05.bemdes 
                close cctc93m05001
                
                if sqlca.sqlcode  =  notfound   then
                   error " Bem atendido nao cadastrado!"
                   call ctn36c00("Bem atendido", "bemAtendido")
                        returning  d_ctc93m05.bemcod
                   next field bemcod
                end if
                display by name d_ctc93m05.bemdes
            end if  
            
         # Carteira do servico   
        before field srvatdctecod                                       
            display by name d_ctc93m05.srvatdctecod attribute (reverse)   
                                                                    
        after  field srvatdctecod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvatdctecod
               
               if d_ctc93m05.srvatdctecod  is null   then
                   error " Carteira deve ser informada!"
                   call ctn36c00("Carteira", "carteiraServico")
                        returning  d_ctc93m05.srvatdctecod
                   next field srvatdctecod
                end if
                
                let l_cponom = "carteiraServico" 
                  
                open cctc93m05001  using l_cponom,d_ctc93m05.srvatdctecod
                fetch cctc93m05001 into d_ctc93m05.srvatdctedes 
                close cctc93m05001
                if sqlca.sqlcode  =  notfound   then
                   error " Carteira nao cadastrado!"
                   call ctn36c00("Carteira", "carteiraServico")
                        returning  d_ctc93m05.srvatdctecod
                   next field srvatdctecod
                end if
                display by name d_ctc93m05.srvatdctedes 
            end if
        
        # Grupo de Assunto   
        before field c24astagp 
            error " Caso o grupo de assunto nao seja necessario coloque 'ZZZ'"                                      
            display by name d_ctc93m05.c24astagp attribute (reverse)   
                                                                    
        after  field c24astagp                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.c24astagp
               
               if d_ctc93m05.c24astagp  is null   then
                   error " Caso o grupo de assunto nao seja necessario coloque 'ZZZ'"
                   next field c24astagp
               else
                  if d_ctc93m05.c24astagp = 'ZZZ' then
                     let d_ctc93m05.c24astagpdes = "Indiferende"
                  else
                     open cctc93m05004 using d_ctc93m05.c24astagp
                     fetch cctc93m05004 into d_ctc93m05.c24astagpdes
                     if sqlca.sqlcode  =  notfound   then
                        error 'Grupo de assunto informado nao esta cadastrado!' sleep 2
                        next field c24astagp
                     end if
                     close cctc93m05004
                  end if 
               end if
               display by name d_ctc93m05.c24astagpdes   
            end if    
        
        
        # Grupo de Assunto   
        before field c24astcod 
            error " Caso o assunto nao seja necessario coloque 'ZZZ'"                                      
            display by name d_ctc93m05.c24astcod attribute (reverse)   
                                                                    
        after  field c24astcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.c24astcod
               
               if d_ctc93m05.c24astcod  is null   then
                   error " Caso assunto nao seja necessario coloque 'ZZZ'"
                   next field c24astcod
               else
                  if d_ctc93m05.c24astcod = 'ZZZ' then
                     let d_ctc93m05.c24astdes = "Indiferende"
                  else
                     open cctc93m05010 using d_ctc93m05.c24astcod
                     fetch cctc93m05010 into d_ctc93m05.c24astdes
                     if sqlca.sqlcode  =  notfound   then
                        error 'Assunto informado nao esta cadastrado!' sleep 2
                        next field c24astcod
                     end if
                     close cctc93m05010
                  end if 
               end if
               display by name d_ctc93m05.c24astdes   
            end if 
        
        call ctc93m05_ler('s',d_ctc93m05.*)   
             returning d_ctc93m05.*,l_ctbevnpamcod
        
        if d_ctc93m05.empcod  is not null   then
           call ctc93m05_display(d_ctc93m05.*)
        else
           error " Parametrizacao nao encontrada!"
           clear form
           initialize d_ctc93m05.*    to null
           next field empcod
        end if
        
    on key (interrupt)
        exit input
 end input

 return d_ctc93m05.*,l_ctbevnpamcod

end function  ###  ctc93m05_seleciona

#------------------------------------------------------------
 function ctc93m05_proximo(d_ctc93m05,l_ctbevnpamcod)
#------------------------------------------------------------
define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record 

 define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod
 
    
    let l_ctbevnpamcod = l_ctbevnpamcod +1
 
 
    open cctc93m05011 using l_ctbevnpamcod
    fetch cctc93m05011 into d_ctc93m05.srvpovevncod,
                            d_ctc93m05.srvajsevncod,
                            d_ctc93m05.srvbxaevncod,
                            d_ctc93m05.srvpgtevncod,
                            d_ctc93m05.atopamflg   ,
                            d_ctc93m05.atldat      ,
                            d_ctc93m05.atlusrtip   ,
                            d_ctc93m05.atlemp      ,
                            d_ctc93m05.atlmat      ,
                            d_ctc93m05.empcod      ,
                            d_ctc93m05.pcpsgrramcod,
                            d_ctc93m05.pcpsgrmdlcod,
                            d_ctc93m05.ctbsgrramcod,
                            d_ctc93m05.ctbsgrmdlcod,
                            d_ctc93m05.pgoclsflg   ,
                            d_ctc93m05.clscod      ,
                            d_ctc93m05.srvdcrcod   ,
                            d_ctc93m05.itaasstipcod,
                            d_ctc93m05.bemcod      ,
                            d_ctc93m05.srvatdctecod,
                            d_ctc93m05.c24astagp   ,
                            d_ctc93m05.c24astcod   
    
    
  call ctc93m05_ler('s',d_ctc93m05.*)   
             returning d_ctc93m05.*,l_ctbevnpamcod
        
  if d_ctc93m05.empcod  is not null   then
     call ctc93m05_display(d_ctc93m05.*)
  else
     error " Proxima parametrizacao nao encontrada!"
  end if  
  
end function

#------------------------------------------------------------
 function ctc93m05_anterior(d_ctc93m05,l_ctbevnpamcod)
#------------------------------------------------------------

define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record 
 
 define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod
 

    if l_ctbevnpamcod = 1 then
       error " Nao existe parametrizacao nesta direcao!"
    else
       let l_ctbevnpamcod = l_ctbevnpamcod -1
    
       open cctc93m05011 using l_ctbevnpamcod
       fetch cctc93m05011 into d_ctc93m05.srvpovevncod,
                               d_ctc93m05.srvajsevncod,
                               d_ctc93m05.srvbxaevncod,
                               d_ctc93m05.srvpgtevncod,
                               d_ctc93m05.atopamflg   ,
                               d_ctc93m05.atldat      ,
                               d_ctc93m05.atlusrtip   ,
                               d_ctc93m05.atlemp      ,
                               d_ctc93m05.atlmat      ,
                               d_ctc93m05.empcod      ,
                               d_ctc93m05.pcpsgrramcod,
                               d_ctc93m05.pcpsgrmdlcod,
                               d_ctc93m05.ctbsgrramcod,
                               d_ctc93m05.ctbsgrmdlcod,
                               d_ctc93m05.pgoclsflg   ,
                               d_ctc93m05.clscod      ,
                               d_ctc93m05.srvdcrcod   ,
                               d_ctc93m05.itaasstipcod,
                               d_ctc93m05.bemcod      ,
                               d_ctc93m05.srvatdctecod,
                               d_ctc93m05.c24astagp   ,
                               d_ctc93m05.c24astcod   
       
       
       call ctc93m05_ler('s',d_ctc93m05.*)   
                  returning d_ctc93m05.*,l_ctbevnpamcod
             
       if d_ctc93m05.empcod  is not null   then
          call ctc93m05_display(d_ctc93m05.*)
       else
          error " Parametrizacao anterior nao encontrada!"
       end if  
    end if 
    
end function


#---------------------------------------------------------
 function ctc93m05_ler(param,d_ctc93m05)
#---------------------------------------------------------
 
  define param         record
    operacao          char (01)
  end record
 
 define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record  
      
 define l_erro         smallint 
 define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod           
 define l_cponom       like iddkdominio.cponom
 
          
 if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if
    display "d_ctc93m05.empcod      : ",d_ctc93m05.empcod      
    display "d_ctc93m05.pcpsgrramcod: ",d_ctc93m05.pcpsgrramcod
    display "d_ctc93m05.pcpsgrmdlcod: ",d_ctc93m05.pcpsgrmdlcod
    display "d_ctc93m05.ctbsgrramcod: ",d_ctc93m05.ctbsgrramcod
    display "d_ctc93m05.ctbsgrmdlcod: ",d_ctc93m05.ctbsgrmdlcod
    display "d_ctc93m05.pgoclsflg   : ",d_ctc93m05.pgoclsflg   
    display "d_ctc93m05.clscod      : ",d_ctc93m05.clscod      
    display "d_ctc93m05.srvdcrcod   : ",d_ctc93m05.srvdcrcod   
    display "d_ctc93m05.itaasstipcod: ",d_ctc93m05.itaasstipcod
    display "d_ctc93m05.bemcod      : ",d_ctc93m05.bemcod      
    display "d_ctc93m05.srvatdctecod: ",d_ctc93m05.srvatdctecod
    display "d_ctc93m05.c24astagp   : ",d_ctc93m05.c24astagp   
    display "d_ctc93m05.c24astcod   : ",d_ctc93m05.c24astcod   

     
     
    open cctc93m05005 using  d_ctc93m05.empcod      ,
                             d_ctc93m05.pcpsgrramcod,
                             d_ctc93m05.pcpsgrmdlcod,
                             d_ctc93m05.ctbsgrramcod,
                             d_ctc93m05.ctbsgrmdlcod,
                             d_ctc93m05.pgoclsflg   ,
                             d_ctc93m05.clscod      ,
                             d_ctc93m05.srvdcrcod   ,
                             d_ctc93m05.itaasstipcod,
                             d_ctc93m05.bemcod      ,
                             d_ctc93m05.srvatdctecod,
                             d_ctc93m05.c24astagp   ,
                             d_ctc93m05.c24astcod   
                             
    fetch cctc93m05005 into  l_ctbevnpamcod,
                             d_ctc93m05.srvpovevncod,
                             d_ctc93m05.srvajsevncod,
                             d_ctc93m05.srvbxaevncod,
                             d_ctc93m05.srvpgtevncod,
                             d_ctc93m05.atopamflg   ,
                             d_ctc93m05.atldat      ,
                             d_ctc93m05.atlusrtip   ,       
                             d_ctc93m05.atlemp      , 
                             d_ctc93m05.atlmat    
    if sqlca.sqlcode  <> 0 and param.operacao <> 'i'  then                       
       initialize d_ctc93m05.* to null 
    end if 
    
    let l_erro =  sqlca.sqlcode
    
    # Nome da Empresa
    open cctc93m05002 using  d_ctc93m05.empcod  
    fetch cctc93m05002 into d_ctc93m05.empsgl   
    close cctc93m05002
    
    
    # Nome da Decorencia do servico
    let l_cponom = "decservico"
    open cctc93m05001  using l_cponom,d_ctc93m05.srvdcrcod
    fetch cctc93m05001 into d_ctc93m05.srvdcrdes 
    close cctc93m05001
    
    
    # Nome da Bem atendido
    let l_cponom = "bemAtendido"
    open cctc93m05001  using l_cponom,d_ctc93m05.bemcod
    fetch cctc93m05001 into d_ctc93m05.bemdes 
    close cctc93m05001
    
    
    # Nome da Cateira do Serviço
    let l_cponom = "carteiraServico"
    open cctc93m05001  using l_cponom,d_ctc93m05.srvatdctecod
    fetch cctc93m05001 into d_ctc93m05.srvatdctedes
    close cctc93m05001
    
    # Nome da Para quem os ervico foi prestado
    open cctc93m05003 using d_ctc93m05.itaasstipcod
    fetch cctc93m05003 into d_ctc93m05.itaasiplntipdes
    close cctc93m05003
    
    
    
    if d_ctc93m05.c24astagp = 'ZZZ' then
       let d_ctc93m05.c24astagpdes = 'Indiferente'
    else
       open cctc93m05004 using d_ctc93m05.c24astagp
       fetch cctc93m05004 into d_ctc93m05.c24astagpdes
    end if
        
        
    if d_ctc93m05.c24astcod = 'ZZZ' then
       let d_ctc93m05.c24astdes = 'Indiferente'
    else
       open cctc93m05010 using d_ctc93m05.c24astcod
       fetch cctc93m05010 into d_ctc93m05.c24astdes
    end if    
     
    
  case param.operacao  
  
  when "s"
         return d_ctc93m05.*,l_ctbevnpamcod 
  when "i"
         return d_ctc93m05.*,l_erro 
  
  otherwise
         return d_ctc93m05.*
  
  end case
   
   
 end function ### ctc93m05_ler
 
 
 
 #---------------------------------------------------------
 function ctc93m05_display(d_ctc93m05)
#---------------------------------------------------------

define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       , 
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record     
 
 define funnom like isskfunc.funnom
 
 if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if
 
  display by name d_ctc93m05.empcod       
  display by name d_ctc93m05.empsgl         
  display by name d_ctc93m05.pcpsgrramcod   
  display by name d_ctc93m05.pcpsgrmdlcod   
  display by name d_ctc93m05.ctbsgrramcod   
  display by name d_ctc93m05.ctbsgrmdlcod   
  display by name d_ctc93m05.pgoclsflg      
  display by name d_ctc93m05.clscod       
  display by name d_ctc93m05.srvdcrcod      
  display by name d_ctc93m05.srvdcrdes      
  display by name d_ctc93m05.itaasstipcod   
  display by name d_ctc93m05.itaasiplntipdes
  display by name d_ctc93m05.bemcod         
  display by name d_ctc93m05.bemdes         
  display by name d_ctc93m05.srvatdctecod   
  display by name d_ctc93m05.srvatdctedes   
  display by name d_ctc93m05.c24astagp      
  display by name d_ctc93m05.c24astagpdes   
  display by name d_ctc93m05.c24astcod      
  display by name d_ctc93m05.c24astdes      
  display by name d_ctc93m05.srvpovevncod   
  display by name d_ctc93m05.srvajsevncod   
  display by name d_ctc93m05.srvbxaevncod   
  display by name d_ctc93m05.srvpgtevncod      
  display by name d_ctc93m05.atopamflg      
  
  
  call ctc93m01_func(d_ctc93m05.atlemp,  
                     d_ctc93m05.atlmat,     
                     d_ctc93m05.atlusrtip)     
  
  returning funnom 
  
  display by name funnom         
  
 
end function  ###  ctc93m05_display

#------------------------------------------------------------
 function ctc93m05_inclui(d_ctc93m05)
#------------------------------------------------------------


define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record    
 
 define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod
 
 define lr_retorno record
    erro           smallint,
    ciaempcod      like datkalgmtv.ciaempcod,
    empnom         like gabkemp.empnom
 end record 
 
 define l_cponom like iddkdominio.cponom 


if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if
 
 clear form
  
  input by name d_ctc93m05.empcod      ,          
                d_ctc93m05.pcpsgrramcod,    
                d_ctc93m05.pcpsgrmdlcod,    
                d_ctc93m05.ctbsgrramcod,    
                d_ctc93m05.ctbsgrmdlcod,    
                d_ctc93m05.clscod    ,       
                d_ctc93m05.pgoclsflg   ,
                d_ctc93m05.srvdcrcod   ,       
                d_ctc93m05.itaasstipcod, 
                d_ctc93m05.bemcod      ,          
                d_ctc93m05.srvatdctecod,    
                d_ctc93m05.c24astagp   ,
                d_ctc93m05.c24astcod 
                
                
     # Empresa
        before field empcod
            display by name d_ctc93m05.empcod attribute (reverse)
        
        after  field empcod
            display by name d_ctc93m05.empcod 
            if d_ctc93m05.empcod  is null   then
               error " Empresa deve ser informada!"
               call cty14g00_popup_empresa()  
                returning lr_retorno.erro, 
                          lr_retorno.ciaempcod, 
                          lr_retorno.empnom  
               let d_ctc93m05.empcod =  lr_retorno.ciaempcod            
               next field empcod
            end if
           
            open cctc93m05002 using  d_ctc93m05.empcod  
                                                  
            fetch cctc93m05002 into d_ctc93m05.empsgl   
            
            close cctc93m05002
            if sqlca.sqlcode  =  notfound   then
               error " Empresa nao cadastrada!"
               next field empcod
            end if
            display by name d_ctc93m05.empsgl
        display "d_ctc93m05.empcod: ",d_ctc93m05.empcod 
        
        # ramo Principal
        before field pcpsgrramcod
            display by name d_ctc93m05.pcpsgrramcod attribute (reverse)
        
        after  field pcpsgrramcod
             if fgl_lastkey() <> fgl_keyval("up")   and 
                fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.pcpsgrramcod
               if d_ctc93m05.pcpsgrramcod  is null   then
                  error " Ramo principal deve ser informado!"           
                  next field pcpsgrramcod
               end if
             end if 
        
        # Modalidade Principal
        before field pcpsgrmdlcod
            display by name d_ctc93m05.pcpsgrmdlcod attribute (reverse)
        
        after  field pcpsgrmdlcod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.pcpsgrmdlcod
               if d_ctc93m05.pcpsgrmdlcod  is null   then
                  error " Modalidade principal deve ser informado!"           
                  next field pcpsgrmdlcod
               end if
            end if 
            
        # Ramo Contabil
        before field ctbsgrramcod
            display by name d_ctc93m05.ctbsgrramcod attribute (reverse)
        
        after  field ctbsgrramcod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.ctbsgrramcod
               if d_ctc93m05.ctbsgrramcod  is null   then
                  error " Ramo Contabil deve ser informado!"           
                  next field ctbsgrramcod
               end if
            end if 
        
        # Modalidade Contabil
        before field ctbsgrmdlcod
            display by name d_ctc93m05.ctbsgrmdlcod attribute (reverse)
        
        after  field ctbsgrmdlcod
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.ctbsgrmdlcod
               if d_ctc93m05.ctbsgrmdlcod  is null   then
                  error " Modalidade Contabil deve ser informado!"           
                  next field ctbsgrmdlcod
               end if
            end if 
        
        # clausula do servico
        before field clscod
           error " Caso a clausula do servico nao seja necessaria coloque '0'"                                      
           display by name d_ctc93m05.clscod attribute (reverse)
        
        after  field clscod
           if fgl_lastkey() <> fgl_keyval("up")   and 
              fgl_lastkey() <> fgl_keyval("left") then 
              
              display by name d_ctc93m05.clscod 
              
              if d_ctc93m05.clscod is null then
                 error " Caso a clausula do servico nao seja necessaria coloque '0'"           
                 next field clscod
              end if   
           end if 
        
        #Clausula Paga?
        before field pgoclsflg
            error "Digite apenas S-Sim, N-Nao, B-Beneficio"
            display by name d_ctc93m05.pgoclsflg attribute (reverse)
        
        after  field pgoclsflg
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.pgoclsflg 
               if d_ctc93m05.pgoclsflg  is null   then
                  error " Clausula Paga deve ser informada!"           
                  next field pgoclsflg
               end if
               
               if d_ctc93m05.pgoclsflg <> 'S' and 
                  d_ctc93m05.pgoclsflg <> 'N' and 
                  d_ctc93m05.pgoclsflg <> 'B' then 
                  error "Digite apenas S-Sim, N-Nao, B-Beneficio"
                  next field pgoclsflg
               end if    
            end if 
        
        # Decorrencia do servico
        before field srvdcrcod                                       
            display by name d_ctc93m05.srvdcrcod attribute (reverse)   
                                                                    
        after  field srvdcrcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvdcrcod
               
               if d_ctc93m05.srvdcrcod  is null   then
                   error " Decorrencia do Servico deve ser informada!"
                   call ctn36c00("Decorrencia do Servico", "decservico")
                        returning  d_ctc93m05.srvdcrcod
                   next field srvdcrcod
                end if
                
                let l_cponom = "decservico"
                  
                open cctc93m05001  using l_cponom,d_ctc93m05.srvdcrcod
                fetch cctc93m05001 into d_ctc93m05.srvdcrdes 
                close cctc93m05001
                if sqlca.sqlcode  =  notfound   then
                   error " Decorrencia do Servico nao cadastrada!"
                   call ctn36c00("Decorrencia do Servico", "decservico")
                        returning  d_ctc93m05.srvdcrcod
                   next field srvdcrcod
                end if
                display by name d_ctc93m05.srvdcrdes
            end if 
            
        # Para quem os ervico foi prestado
        before field itaasstipcod                                       
            display by name d_ctc93m05.itaasstipcod attribute (reverse)   
                                                                    
        after  field itaasstipcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.itaasstipcod 
               
               if d_ctc93m05.itaasstipcod  is null   then
                   error " Para quem o servico foi prestado deve ser informado!"
                   call ctx35g00_popup()
                        returning  d_ctc93m05.itaasstipcod,
                                   d_ctc93m05.itaasiplntipdes
                   next field itaasstipcod
                end if
                
                if d_ctc93m05.itaasstipcod <> 2 and 
                   d_ctc93m05.itaasstipcod <> 9 and 
                   d_ctc93m05.itaasstipcod <> 3 then
                   error " Para quem o servico foi prestado esta invalido!"
                   next field itaasstipcod
                end if 
                
                open cctc93m05003 using d_ctc93m05.itaasstipcod
                fetch cctc93m05003 into d_ctc93m05.itaasiplntipdes
                close cctc93m05003
                
                display by name d_ctc93m05.itaasiplntipdes
            end if      
            
        # bem atendido   
        before field bemcod                                       
            display by name d_ctc93m05.bemcod attribute (reverse)   
                                                                    
        after  field bemcod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.bemcod 
               
               if d_ctc93m05.bemcod  is null   then
                   error " Bem atendido deve ser informado!"
                   call ctn36c00("Bem atendido", "bemAtendido")
                        returning  d_ctc93m05.bemcod
                   next field bemcod
                end if
                
                let l_cponom = "bemAtendido"
                  
                open cctc93m05001  using l_cponom,d_ctc93m05.bemcod
                fetch cctc93m05001 into d_ctc93m05.bemdes 
                close cctc93m05001
                
                if sqlca.sqlcode  =  notfound   then
                   error " Bem atendido nao cadastrado!"
                   call ctn36c00("Bem atendido", "bemAtendido")
                        returning  d_ctc93m05.bemcod
                   next field bemcod
                end if
                display by name d_ctc93m05.bemdes
            end if  
            
         # Carteira do servico   
        before field srvatdctecod                                       
            display by name d_ctc93m05.srvatdctecod attribute (reverse)   
                                                                    
        after  field srvatdctecod                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvatdctecod
               
               if d_ctc93m05.srvatdctecod  is null   then
                   error " Carteira deve ser informada!"
                   call ctn36c00("Carteira", "carteiraServico")
                        returning  d_ctc93m05.srvatdctecod
                   next field srvatdctecod
                end if
                
                let l_cponom = "carteiraServico"
                  
                open cctc93m05001  using l_cponom,d_ctc93m05.srvatdctecod
                fetch cctc93m05001 into d_ctc93m05.srvatdctedes 
                close cctc93m05001
                if sqlca.sqlcode  =  notfound   then
                   error " Carteira nao cadastrado!"
                   call ctn36c00("Carteira", "carteiraServico")
                        returning  d_ctc93m05.srvatdctecod
                   next field srvatdctecod
                end if
                display by name d_ctc93m05.srvatdctedes 
            end if
        
        # Grupo de Assunto   
        before field c24astagp 
            error " Caso o grupo de assunto nao seja necessario coloque 'ZZZ'"                                      
            display by name d_ctc93m05.c24astagp attribute (reverse)   
                                                                    
        after  field c24astagp                                       
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.c24astagp
               
               if d_ctc93m05.c24astagp  is null   then
                   error " Caso o grupo de assunto nao seja necessario coloque 'ZZZ'"
                   next field c24astagp
               else
                  if d_ctc93m05.c24astagp = 'ZZZ' then
                     let d_ctc93m05.c24astagpdes = "Indiferende"
                  else
                     open cctc93m05004 using d_ctc93m05.c24astagp
                     fetch cctc93m05004 into d_ctc93m05.c24astagpdes
                     if sqlca.sqlcode  =  notfound   then
                        error 'Grupo de assunto informado nao esta cadastrado!' sleep 2
                        next field c24astagp
                     end if
                     close cctc93m05004
                  end if 
               end if
               display by name d_ctc93m05.c24astagpdes
               
            end if
  
        # Grupo de Assunto                                                                                        
        before field c24astcod                                                                             
            error " Caso o assunto nao seja necessario coloque 'ZZZ'"                                      
            display by name d_ctc93m05.c24astcod attribute (reverse)                                       
                                                                                                           
        after  field c24astcod                                                                             
            if fgl_lastkey() <> fgl_keyval("up")   and                                                     
               fgl_lastkey() <> fgl_keyval("left") then                                                    
               display by name d_ctc93m05.c24astcod                                                        
                                                                                                           
               if d_ctc93m05.c24astcod  is null   then                                                     
                   error " Caso assunto nao seja necessario coloque 'ZZZ'"                                 
                   next field c24astcod                                                                    
               else                                                                                        
                  if d_ctc93m05.c24astcod = 'ZZZ' then                                                     
                     let d_ctc93m05.c24astdes = "Indiferende"                                              
                  else                                                                                     
                     open cctc93m05010 using d_ctc93m05.c24astcod                                          
                     fetch cctc93m05010 into d_ctc93m05.c24astdes                                          
                     if sqlca.sqlcode  =  notfound   then                                                  
                        error 'Assunto informado nao esta cadastrado!' sleep 2                             
                        next field c24astcod                                                               
                     end if                                                                                
                     close cctc93m05010                                                                    
                  end if                                                                                   
               end if                                                                                      
               display by name d_ctc93m05.c24astdes 
               
               call ctc93m05_ler('i',d_ctc93m05.*)   
                    returning d_ctc93m05.*,lr_retorno.erro
               
               if d_ctc93m05.empcod  is not null and lr_retorno.erro = 0 then
                  call ctc93m05_display(d_ctc93m05.*)
                  error " Parametrizacao Já cadastrada encontrada!"
                  next field empcod
               else
                  call ctc93m05_input(d_ctc93m05.*)    
                       returning d_ctc93m05.*   
               end if                                                       
            end if                                                                                         
  
   on key (interrupt)
        exit input
 end input
   
 if int_flag = false then  
    whenever error continue
       open cctc93m05006 
       fetch cctc93m05006 into l_ctbevnpamcod
       
       if sqlca.sqlcode = notfound then
          let l_ctbevnpamcod = 1
       else
          if sqlca.sqlcode <> 0 then
             error "ERRO: ",sqlca.sqlcode," ao buscar a sequencia do cadastro!" 
             let  l_ctbevnpamcod = 0
          end if  
       end if 
       
       if l_ctbevnpamcod is null then
          let l_ctbevnpamcod = 1  
       end if 
       
       close cctc93m05006
    whenever error stop
    
     let d_ctc93m05.atldat = today
     
    if l_ctbevnpamcod <> 0 then
        let l_ctbevnpamcod = l_ctbevnpamcod + 1
        
        whenever error continue
           execute pctc93m05007 using l_ctbevnpamcod            ,      
                                      d_ctc93m05.empcod         ,     
                                      d_ctc93m05.pcpsgrramcod   ,          
                                      d_ctc93m05.pcpsgrmdlcod   ,    
                                      d_ctc93m05.ctbsgrramcod   ,                   
                                      d_ctc93m05.ctbsgrmdlcod   ,
                                      d_ctc93m05.pgoclsflg      ,
                                      d_ctc93m05.srvdcrcod      ,
                                      d_ctc93m05.itaasstipcod   ,
                                      d_ctc93m05.bemcod         ,
                                      d_ctc93m05.srvatdctecod   ,
                                      d_ctc93m05.c24astagp      ,
                                      d_ctc93m05.srvpovevncod   ,
                                      d_ctc93m05.srvajsevncod   ,
                                      d_ctc93m05.srvbxaevncod   ,
                                      d_ctc93m05.atopamflg      ,
                                      g_issk.usrtip             , 
                                      g_issk.empcod             , 
                                      g_issk.funmat             ,
                                      d_ctc93m05.atldat         ,
                                      d_ctc93m05.clscod         ,
                                      d_ctc93m05.c24astcod      ,
                                      d_ctc93m05.srvpgtevncod   
                                       
           if sqlca.sqlcode <> 0 then
              error "Inclusao nao realizada ERRO: ",sqlca.sqlcode
           else
              error "Inclusão efetuada com sucesso!"
           end if
        whenever error stop
    end if 
    
    call ctc93m05_ler('s',d_ctc93m05.*)
            returning d_ctc93m05.*,l_ctbevnpamcod
    
    call ctc93m05_display(d_ctc93m05.*)
      
 end if 
 
    return d_ctc93m05.*
 
end function  ###  ctc93m05_inclui

#------------------------------------------------------------
 function ctc93m05_modifica(d_ctc93m05)
#------------------------------------------------------------

 define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record 
  
 define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod
 
if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if
 
  call ctc93m05_display(d_ctc93m05.*)  
  
  call ctc93m05_input(d_ctc93m05.*)    
      returning d_ctc93m05.*             
   
 whenever error continue
    open cctc93m05006 
    fetch cctc93m05006 into l_ctbevnpamcod
    
    if sqlca.sqlcode = notfound then
       let l_ctbevnpamcod = 1
    else
       if sqlca.sqlcode <> 0 then
          error "ERRO: ",sqlca.sqlcode," ao buscar a sequencia do cadastro!" 
          let  l_ctbevnpamcod = 0
       end if  
    end if 
    
    close cctc93m05006
 whenever error stop

  let d_ctc93m05.atldat = today
  
 if l_ctbevnpamcod <> 0 then

      whenever error continue
      execute pctc93m05008 using d_ctc93m05.empcod      ,
                                 d_ctc93m05.pcpsgrramcod,
                                 d_ctc93m05.pcpsgrmdlcod,
                                 d_ctc93m05.ctbsgrramcod,
                                 d_ctc93m05.ctbsgrmdlcod,
                                 d_ctc93m05.pgoclsflg   ,
                                 d_ctc93m05.clscod      ,
                                 d_ctc93m05.srvdcrcod   ,
                                 d_ctc93m05.itaasstipcod,
                                 d_ctc93m05.bemcod      ,
                                 d_ctc93m05.srvatdctecod,
                                 d_ctc93m05.c24astagp   ,
                                 d_ctc93m05.c24astcod 
        
         if sqlca.sqlcode <> 0 then
           error "Atualizacao de cancelamento nao realizada ERRO: ",sqlca.sqlcode
        end if
      whenever error stop
     let l_ctbevnpamcod = l_ctbevnpamcod + 1
     
     whenever error continue
        execute pctc93m05007 using l_ctbevnpamcod            ,      
                                   d_ctc93m05.empcod         ,     
                                   d_ctc93m05.pcpsgrramcod   ,          
                                   d_ctc93m05.pcpsgrmdlcod   ,    
                                   d_ctc93m05.ctbsgrramcod   ,                   
                                   d_ctc93m05.ctbsgrmdlcod   ,
                                   d_ctc93m05.pgoclsflg      ,
                                   d_ctc93m05.srvdcrcod      ,
                                   d_ctc93m05.itaasstipcod   ,
                                   d_ctc93m05.bemcod         ,
                                   d_ctc93m05.srvatdctecod   ,
                                   d_ctc93m05.c24astagp      ,
                                   d_ctc93m05.srvpovevncod   ,
                                   d_ctc93m05.srvajsevncod   ,
                                   d_ctc93m05.srvbxaevncod   ,
                                   d_ctc93m05.atopamflg      ,
                                   g_issk.usrtip             , 
                                   g_issk.empcod             , 
                                   g_issk.funmat             ,
                                   d_ctc93m05.atldat         ,
                                   d_ctc93m05.clscod         ,
                                   d_ctc93m05.c24astcod      ,
                                   d_ctc93m05.srvpgtevncod       
                                    
        if sqlca.sqlcode <> 0 then
           error "Atualizacao nao realizada ERRO: ",sqlca.sqlcode
        else
           error "Atualizacao efetuada com sucesso!"
        end if
     whenever error stop
 end if 
 
 call ctc93m05_ler('s',d_ctc93m05.*)
         returning d_ctc93m05.*,l_ctbevnpamcod
 
 call ctc93m05_display(d_ctc93m05.*)

  return d_ctc93m05.*
  
end function  ###  ctc93m05_modifica


#------------------------------------------------------------
 function ctc93m05_input(d_ctc93m05)
#------------------------------------------------------------
 
  define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       , 
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record 
 
 
 
 if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if

 let int_flag = false
 
    input by name d_ctc93m05.srvpovevncod,
                  d_ctc93m05.srvajsevncod,
                  d_ctc93m05.srvbxaevncod,
                  d_ctc93m05.srvpgtevncod,
                  d_ctc93m05.atopamflg    without defaults
       
        # Evento de Provisao
        before field srvpovevncod
            display by name d_ctc93m05.srvpovevncod attribute (reverse)
        
        after  field srvpovevncod
             if fgl_lastkey() <> fgl_keyval("up")   and 
                fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvpovevncod
               if d_ctc93m05.srvpovevncod  is null   then
                  error " Evento de Provisao deve ser informado!"           
                  next field srvpovevncod
               end if
             end if  
         
         # Evento de Ajuste
        before field srvajsevncod
            display by name d_ctc93m05.srvajsevncod attribute (reverse)
        
        after  field srvajsevncod
             if fgl_lastkey() <> fgl_keyval("up")   and 
                fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvajsevncod
               if d_ctc93m05.srvajsevncod  is null   then
                  error " Evento de Ajuste deve ser informado!"           
                  next field srvajsevncod
               end if
             end if  
             
        # Evento de Baixa
        before field srvbxaevncod
            display by name d_ctc93m05.srvbxaevncod attribute (reverse)
        
        after  field srvbxaevncod
             if fgl_lastkey() <> fgl_keyval("up")   and 
                fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvbxaevncod
               if d_ctc93m05.srvbxaevncod  is null   then
                  error " Evento de Baixa deve ser informado!"           
                  next field srvbxaevncod
               end if
             end if      
        
        
        # Evento de Pagamento
        before field srvpgtevncod
            display by name d_ctc93m05.srvpgtevncod attribute (reverse)
        
        after  field srvpgtevncod
             if fgl_lastkey() <> fgl_keyval("up")   and 
                fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.srvpgtevncod
               if d_ctc93m05.srvpgtevncod  is null   then
                  error " Evento de Pagamento deve ser informado!"           
                  next field srvpgtevncod
               end if
             end if
        
         
         #Status cadastro
        before field atopamflg
            error "Digite apenas A - Ativo, C - Cancelado"
            display by name d_ctc93m05.atopamflg attribute (reverse)
        
        after  field atopamflg
            if fgl_lastkey() <> fgl_keyval("up")   and 
               fgl_lastkey() <> fgl_keyval("left") then 
               display by name d_ctc93m05.atopamflg 
               if d_ctc93m05.atopamflg  is null   then
                  error " Status do cadastro deve ser informado!"           
                  next field atopamflg
               end if
               
               if d_ctc93m05.atopamflg <> 'A' and 
                  d_ctc93m05.atopamflg <> 'C' then 
                  error "Digite apenas A - Ativo, C - Cancelado"
                  next field atopamflg
               end if    
            end if 
          
    on key (interrupt)
        exit input
 end input

 return d_ctc93m05.*

end function  ###  ctc93m05_input



#------------------------------------------------------------
 function ctc93m05_historico(d_ctc93m05)
#------------------------------------------------------------

define d_ctc93m05  record      
   empcod           like dbskctbevnpam.empcod       , 
   empsgl           like gabkemp.empsgl             , 
   pcpsgrramcod     like dbskctbevnpam.pcpsgrramcod , 
   pcpsgrmdlcod     like dbskctbevnpam.pcpsgrmdlcod , 
   ctbsgrramcod     like dbskctbevnpam.ctbsgrramcod , 
   ctbsgrmdlcod     like dbskctbevnpam.ctbsgrmdlcod , 
   pgoclsflg        like dbskctbevnpam.pgoclsflg    ,
   clscod           like dbskctbevnpam.clscod       ,
   srvdcrcod        like dbskctbevnpam.srvdcrcod    , 
   srvdcrdes        char(50)                        ,
   itaasstipcod     like dbskctbevnpam.itaasstipcod , 
   itaasiplntipdes  like datkasttip.itaasiplntipdes , 
   bemcod           like dbskctbevnpam.bemcod       , 
   bemdes           char(50)                        ,
   srvatdctecod     like dbskctbevnpam.srvatdctecod , 
   srvatdctedes     char(200)                       ,
   c24astagp        like dbskctbevnpam.c24astagp    , 
   c24astagpdes     like datkastagp.c24astagpdes    , 
   c24astcod        like datkassunto.c24astcod      , 
   c24astdes        like datkassunto.c24astdes      , 
   srvpovevncod     like dbskctbevnpam.srvpovevncod , 
   srvajsevncod     like dbskctbevnpam.srvajsevncod , 
   srvbxaevncod     like dbskctbevnpam.srvbxaevncod , 
   srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
   atopamflg        like dbskctbevnpam.atopamflg    , 
   atldat           like dbskctbevnpam.atldat       ,
   atlusrtip        like dbskctbevnpam.atlusrtip    ,
   atlemp           like dbskctbevnpam.atlemp       , 
   atlmat           like dbskctbevnpam.atlmat        
 end record 
 
 
 define d_ctc93m05_ant record  
    ctbevnpamcod     like dbskctbevnpam.ctbevnpamcod ,
    srvpovevncod     like dbskctbevnpam.srvpovevncod ,   
    srvajsevncod     like dbskctbevnpam.srvajsevncod ,   
    srvbxaevncod     like dbskctbevnpam.srvbxaevncod ,   
    srvpgtevncod     like dbskctbevnpam.srvpgtevncod , 
    atopamflg        like dbskctbevnpam.atopamflg    ,   
    atldat           like dbskctbevnpam.atldat       ,   
    atlusrtip        like dbskctbevnpam.atlusrtip    , 
    atlemp           like dbskctbevnpam.atlemp       , 
    atlmat           like dbskctbevnpam.atlmat              
 end record 
 
 define al_ctc93m05a  array[200] of record
          texto       char(80)
 end record 
 
 
 define l_ctbevnpamcod like dbskctbevnpam.ctbevnpamcod
 define l_aux_linha smallint
 define funnom like isskfunc.funnom
 
 
if m_ctc93m05_prep is null or
    m_ctc93m05_prep <> true then
    call ctc93m05_prepare()
 end if
 
 initialize al_ctc93m05a  to  null  
 initialize d_ctc93m05_ant.* to null
 
 let l_aux_linha = 0 
     
 whenever error continue
    
    open cctc93m05009 using  d_ctc93m05.empcod      ,
                             d_ctc93m05.pcpsgrramcod,
                             d_ctc93m05.pcpsgrmdlcod,
                             d_ctc93m05.ctbsgrramcod,
                             d_ctc93m05.ctbsgrmdlcod,
                             d_ctc93m05.pgoclsflg   ,
                             d_ctc93m05.clscod      ,
                             d_ctc93m05.srvdcrcod   ,
                             d_ctc93m05.itaasstipcod,
                             d_ctc93m05.bemcod      ,
                             d_ctc93m05.srvatdctecod,
                             d_ctc93m05.c24astagp   ,
                             d_ctc93m05.c24astcod  
                             
    foreach cctc93m05009 into  l_ctbevnpamcod         ,
                               d_ctc93m05.srvpovevncod,
                               d_ctc93m05.srvajsevncod,
                               d_ctc93m05.srvbxaevncod,
                               d_ctc93m05.srvpgtevncod,
                               d_ctc93m05.atopamflg   ,
                               d_ctc93m05.atldat      ,
                               d_ctc93m05.atlusrtip ,       
                               d_ctc93m05.atlemp    , 
                               d_ctc93m05.atlmat    
          
       if l_aux_linha = 0 then
       
         let d_ctc93m05_ant.ctbevnpamcod = l_ctbevnpamcod
         let d_ctc93m05_ant.srvpovevncod = d_ctc93m05.srvpovevncod
         let d_ctc93m05_ant.srvajsevncod = d_ctc93m05.srvajsevncod
         let d_ctc93m05_ant.srvbxaevncod = d_ctc93m05.srvbxaevncod
         let d_ctc93m05_ant.atopamflg    = d_ctc93m05.atopamflg   
         let d_ctc93m05_ant.atldat       = d_ctc93m05.atldat      
         let d_ctc93m05_ant.atlusrtip    = d_ctc93m05.atlusrtip   
         let d_ctc93m05_ant.atlemp       = d_ctc93m05.atlemp      
         let d_ctc93m05_ant.atlmat       = d_ctc93m05.atlmat      
         
         let l_aux_linha = l_aux_linha + 1
         continue foreach
       end if 
       
       
       call ctc93m01_func(d_ctc93m05.atlemp,  
                          d_ctc93m05.atlmat,     
                          d_ctc93m05.atlusrtip)     
            returning funnom 
       
        if (d_ctc93m05.atldat <> d_ctc93m05_ant.atldat  or 
            d_ctc93m05.atlmat <> d_ctc93m05_ant.atlmat) or
            l_aux_linha = 1 then
           
           if l_aux_linha <> 1 then
              let l_aux_linha = l_aux_linha + 2
           end if
              
           let al_ctc93m05a[l_aux_linha].texto = '	Aletrado(s) por [',funnom clipped,'] em [',d_ctc93m05.atldat,'] :'
           let l_aux_linha = l_aux_linha + 1  
        end if 
       
       if (d_ctc93m05_ant.srvpovevncod is null     and d_ctc93m05.srvpovevncod is not null) or
          (d_ctc93m05_ant.srvpovevncod is not null and d_ctc93m05.srvpovevncod is null)     or
          (d_ctc93m05_ant.srvpovevncod              <> d_ctc93m05.srvpovevncod)             then
          
          let l_aux_linha = l_aux_linha + 1
          
          let al_ctc93m05a[l_aux_linha].texto = 'Evento provisionamento alterado de [',d_ctc93m05_ant.srvpovevncod clipped,']',
          ' para [',d_ctc93m05.srvpovevncod clipped,']'
       
       end if 
       
       if (d_ctc93m05_ant.srvajsevncod is null     and d_ctc93m05.srvajsevncod is not null) or
          (d_ctc93m05_ant.srvajsevncod is not null and d_ctc93m05.srvajsevncod is null)     or
          (d_ctc93m05_ant.srvajsevncod              <> d_ctc93m05.srvajsevncod)             then
          
          let l_aux_linha = l_aux_linha + 1
       
          let al_ctc93m05a[l_aux_linha].texto = 'Evento ajuste alterado de [',d_ctc93m05_ant.srvajsevncod clipped,']',
          ' para [',d_ctc93m05.srvajsevncod clipped,']'
       
       end if 
       
       if (d_ctc93m05_ant.srvbxaevncod is null     and d_ctc93m05.srvbxaevncod is not null) or
          (d_ctc93m05_ant.srvbxaevncod is not null and d_ctc93m05.srvbxaevncod is null)     or
          (d_ctc93m05_ant.srvbxaevncod              <> d_ctc93m05.srvbxaevncod)             then
          
          let l_aux_linha = l_aux_linha + 1
       
          let al_ctc93m05a[l_aux_linha].texto = 'Evento baixa alterado de [',d_ctc93m05_ant.srvbxaevncod clipped,']',
          ' para [',d_ctc93m05.srvbxaevncod clipped,']'
       
       end if 
       
       if (d_ctc93m05_ant.srvpgtevncod is null     and d_ctc93m05.srvpgtevncod is not null) or
          (d_ctc93m05_ant.srvpgtevncod is not null and d_ctc93m05.srvpgtevncod is null)     or
          (d_ctc93m05_ant.srvpgtevncod              <> d_ctc93m05.srvpgtevncod)             then
          
          let l_aux_linha = l_aux_linha + 1
       
          let al_ctc93m05a[l_aux_linha].texto = 'Evento pagamento alterado de [',d_ctc93m05_ant.srvpgtevncod clipped,']',
          ' para [',d_ctc93m05.srvpgtevncod clipped,']'
       
       end if
       
       if (d_ctc93m05_ant.atopamflg is null     and d_ctc93m05.atopamflg is not null) or
          (d_ctc93m05_ant.atopamflg is not null and d_ctc93m05.atopamflg is null)     or
          (d_ctc93m05_ant.atopamflg              <> d_ctc93m05.atopamflg)             then
          
          let l_aux_linha = l_aux_linha + 1
       
          let al_ctc93m05a[l_aux_linha].texto = 'Status do cadastro alterado de [',d_ctc93m05_ant.atopamflg,']',
          ' para [',d_ctc93m05.atopamflg,']'
       
       end if  
       
       if (d_ctc93m05_ant.srvpovevncod = d_ctc93m05.srvpovevncod) and
          (d_ctc93m05_ant.srvajsevncod = d_ctc93m05.srvajsevncod) and
          (d_ctc93m05_ant.srvbxaevncod = d_ctc93m05.srvbxaevncod) and
          (d_ctc93m05_ant.srvpgtevncod = d_ctc93m05.srvpgtevncod) and
          (d_ctc93m05_ant.atopamflg = d_ctc93m05.atopamflg)       and
          (d_ctc93m05.atopamflg = 'C')                            then 
         
          let l_aux_linha = l_aux_linha + 1
       
          let al_ctc93m05a[l_aux_linha].texto = 'Status do cadastro alterado de [A] para [C]'
       
       end if 
            
      
      let d_ctc93m05_ant.ctbevnpamcod = l_ctbevnpamcod
      let d_ctc93m05_ant.srvpovevncod = d_ctc93m05.srvpovevncod
      let d_ctc93m05_ant.srvajsevncod = d_ctc93m05.srvajsevncod
      let d_ctc93m05_ant.srvbxaevncod = d_ctc93m05.srvbxaevncod
      let d_ctc93m05_ant.atopamflg    = d_ctc93m05.atopamflg   
      let d_ctc93m05_ant.atldat       = d_ctc93m05.atldat      
      let d_ctc93m05_ant.atlusrtip    = d_ctc93m05.atlusrtip   
      let d_ctc93m05_ant.atlemp       = d_ctc93m05.atlemp      
      let d_ctc93m05_ant.atlmat       = d_ctc93m05.atlmat   
         
    end foreach   
    
 whenever error stop
  
  if l_aux_linha = 0 then
      error 'Nenhum registro encontrado'
  else
     
     open window ctc93m05a at 05,07 with form "ctc93m05a" attribute(form line first, border)
     
     call set_count(l_aux_linha)

     display array al_ctc93m05a to s_ctc93m05a.*

        on key(f2,control-c,interrupt)
           exit display

     end display
     
     close window ctc93m05a
     
  end if
   
end function  ###  ctc93m05_historico