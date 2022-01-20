{----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                            #
#............................................................................#
# SISTEMA........: PORTO SOCORRO                                             #
# MODULO.........: CTC89M00.4GL                                              #
# ANALISTA RESP..: SERGIO BURINI                                             #
# PSI/OSF........:                                                           #
# OBJETIVO.......: CADASTRO DE CIDADES COM ALERTA DE SMS.                    #
#............................................................................#
# DESENVOLVIMENTO: SERGIO BURINI                                             #
# LIBERACAO......: 25/11/2009                                                #
#............................................................................}


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 database porto

 define mr_entrada record
     mpacidcod like datkmpacid.mpacidcod,
     cidnom    like datkmpacid.cidnom,
     ufdcod    like datkmpacid.ufdcod,
     tipcod    integer,
     destipsms char(30)
 end record

 define ma_cidades array[1000] of record
     aux        char(01),
     cidnomsms  like datkmpacid.cidnom,
     ufdcodsms  like datkmpacid.ufdcod,
     envsst     like datkmpacid.mpacidcod,
     descodsms  char(30)
 end record
 
 define ma_cidades_aux array[1000] of record
     mpacidcod  like datkmpacid.mpacidcod
 end record
 
 #define ma_cidades array[1000] of record
 #    envsst smallint
 #end record 
 
 define mr_orde record
     pri smallint,
     seg smallint,
     ter smallint
 end record
 

 define ws record
     mpacidcod like datkmpacid.mpacidcod
 end record

 define m_flagins smallint,
        m_arrcurr smallint,
        m_scrline smallint
        
 define m_ordenacao smallint
 
 define m_chave1  char(15),
        m_chave2  char(15),
        m_char    char(15)

#---------------------------#
 function ctc89m00_prepare()
#---------------------------#

     define l_sql char(1000)

     let m_chave1 = null
     let m_chave2 = null
     
     let m_chave1 = "CIDXSMS"
     
     let l_sql = "select mpacidcod ",
                 " from datkmpacid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "

     prepare pcctc89m00_01 from l_sql
     declare cqctc89m00_01 cursor for pcctc89m00_01

     let l_sql = "insert into dbsmsmsalrcid values (?,?,?,current)"

     prepare pcctc89m00_02 from l_sql

     let l_sql = "select cidnom, ",
                       " ufdcod ",
                  " from datkmpacid ",
                 " where mpacidcod = ? "

     prepare pcctc89m00_04 from l_sql
     declare cqctc89m00_04 cursor for pcctc89m00_04

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = 'tipcodsms' ",
                   " and cpocod = ? "

     prepare pcctc89m00_05 from l_sql
     declare cqctc89m00_05 cursor for pcctc89m00_05
     
     let l_sql = "select 1 ",                            
             " from dbsmsmsalrcid s, datkmpacid c ",
            " where s.mpacidcod = c.mpacidcod ",    
              " and cidnom = ? ",                  
              " and ufdcod = ? ",                  
              " and envstt = ? ",                  
              " and s.mpacidcod = c.mpacidcod"      

     prepare pcctc89m00_06 from l_sql
     declare cqctc89m00_06 cursor for pcctc89m00_06
     
     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = 'tipcodsms' ",
                   " and cpocod = ? "
     
     prepare pcctc89m00_07 from l_sql
     declare cqctc89m00_07 cursor for pcctc89m00_07     
     
     let l_sql = "select 1 ",
                  " from dbsmsmsalrcid s, datkmpacid c ",
                 " where s.mpacidcod = c.mpacidcod ",
                   " and envstt  = ? ",
                   " and s.mpacidcod = c.mpacidcod"    
     
     prepare pcctc89m00_08 from l_sql             
     declare cqctc89m00_08 cursor for pcctc89m00_08     
     
     let l_sql = "select 1 ",
                  " from dbsmsmsalrcid s, datkmpacid c ",
                 " where s.mpacidcod = c.mpacidcod ",
                   " and ufdcod  = ? ",
                   " and envstt  = ? ",
                   " and s.mpacidcod = c.mpacidcod" 
     
     prepare pcctc89m00_09 from l_sql             
     declare cqctc89m00_09 cursor for pcctc89m00_09
     
     let l_sql = "delete from dbsmsmsalrcid where envstt = ?"
     prepare pcctc89m00_10 from l_sql
     
     #let l_sql = "delete from dbsmsmsalrcid where ufdcod = ? and envstt = ?"
     #prepare pcctc89m00_11 from l_sql   
     #
     #let l_sql = "delete from dbsmsmsalrcid where ufdcod = ? and cidnom = ? and envstt = ?"
     #prepare pcctc89m00_12 from l_sql      
     
     let l_sql = "delete from dbsmsmsalrcid where envstt = ? ",
                 "   and mpacidcod in (select mpacidcod from datkmpacid",
                                     " where ufdcod  = ?)"
     
     prepare pcctc89m00_11 from l_sql   

     #let l_sql = "select 1 ",
     #             " from dbsmsmsalrcid ",
     #            " where mpacidcod    = ? ",
     #              " and envsst = ? "
     #
     #prepare pcctc89m00_13 from l_sql             
     #declare cqctc89m00_13 cursor for pcctc89m00_13     
     
     let l_sql = "select mpacidcod ",
                  " from datkmpacid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "
     
     prepare pcctc89m00_13 from l_sql             
     declare cqctc89m00_13 cursor for pcctc89m00_13      
     
     let l_sql = "select mpacidcod ",               
                  " from datkmpacid ",              
                 " where ufdcod = ? "               
                                                    
     prepare pcctc89m00_14 from l_sql               
     declare cqctc89m00_14 cursor for pcctc89m00_14 
     
     let l_sql = "insert into datkgeral values (?,'TODAS',current,current,?,?)"

     prepare pcctc89m00_15 from l_sql
     
     let l_sql = "delete from datkgeral where grlchv like ? "

     prepare pcctc89m00_16 from l_sql
     
     let l_sql = "select 1 ",               
                  " from datkgeral ",              
                 " where grlchv like ? "               
                                                    
     prepare pcctc89m00_17 from l_sql               
     declare cqctc89m00_17 cursor for pcctc89m00_17 
     
     let l_sql = "select grlchv ", 
                 "      ,grlinf ",
                 "      ,atldat ",
                 "      ,atlhor ",
                 "      ,atlemp ",
                 "      ,atlmat ",
                  " from datkgeral ",              
                 " where grlchv like 'CIDXSMS%' "               
                                                    
     prepare pcctc89m00_18 from l_sql               
     declare cqctc89m00_18 cursor for pcctc89m00_18 
     
     let l_sql = "delete from dbsmsmsalrcid where mpacidcod = ? and envstt = ? "
     
     prepare pcctc89m00_19 from l_sql
     
     let l_sql = "select cidnom ",
                 " from datkmpacid ",
                 " where mpacidcod = ? "

     prepare pcctc89m00_20 from l_sql
     declare cqctc89m00_20 cursor for pcctc89m00_20
     

 end function

#-------------------#
 function ctc89m00()
#-------------------#

     define l_sql       char(500),
            m_ordenacao smallint,
            m_curr      integer 
     
     if int_flag = true then
        let int_flag = false
     end if
     
     call ctc89m00_prepare()
     
     

     open window w_ctc89m00 at 4,2 with form 'ctc89m00'
       attribute(form line 1)
     
     let m_ordenacao = 0  
       
     while true

         call ctc89m00_ordena("N")
         
         call ctc89m00_carrega_array()

         display array ma_cidades to s_ctc89m00.*
             
             on key (F1)
                call ctc89m00_inclui()
                exit display
                
             on key (F2)
                let m_curr = arr_curr()

                if  ma_cidades[m_curr].cidnomsms is not null and
                    ma_cidades[m_curr].cidnomsms <> " " then
                
                    if  cts08g01("A","S","",
                                 "CONFIRMA A EXCLUSAO DO ALERTA DE",
                                 "SMS PARA ESSA CIDADE?","") = "S" then
                                 call ctc89m00_excluir()
                    end if
                else
                    error "Nao existem dados para serem exluidos"
                end if
                
                exit display                

             on key (f6)
                call ctc89m00_ordena("S")
                exit display
                
             on key (f17,control-c,interrupt)
                exit display
         
         end display 
         
         
         #input array ma_cidades without defaults from s_ctc89m00.*
         #
         #    before row
         #        let m_arrcurr = arr_curr()
         #        let m_scrline = scr_line()
         #
         #    after field aux
         #        
         #        if  not m_flagins then
         #            next row 
         #        end if
         #    
         #    after field cidnomsms
         #
         #        if  ma_cidades[m_arrcurr].cidnomsms is null or ma_cidades[m_arrcurr].cidnomsms = " " then
         #            call cts06g04(ma_cidades[m_arrcurr].cidnomsms, ma_cidades[m_arrcurr].ufdcodsms)
         #                returning ws.mpacidcod, ma_cidades[m_arrcurr].cidnomsms, ma_cidades[m_arrcurr].ufdcodsms
         #
         #            next field cidnomsms
         #        end if
         #
         #    after field ufdcodsms
         #
         #            if  ma_cidades[m_arrcurr].cidnomsms <> "TODAS" then
         #                display "BUSCANDO A CIDADE"
         #                open cqctc89m00_01 using ma_cidades[m_arrcurr].cidnomsms,
         #                                         ma_cidades[m_arrcurr].ufdcodsms
         #                fetch cqctc89m00_01 into ws.mpacidcod
         #                #display "Sqlcode = ", sqlca.sqlcode
         #                #display "CODIGO NA CIDADE = ", ws.mpacidcod
         #
         #                if  sqlca.sqlcode = notfound then
         #                    error "Cidade não encontrada."
         #                    let ma_cidades[m_arrcurr].cidnomsms = null
         #                    let ma_cidades[m_arrcurr].ufdcodsms = null
         #                    display ma_cidades[m_arrcurr].cidnomsms to s_ctc89m00[m_scrline].cidnomsms
         #                    display ma_cidades[m_arrcurr].ufdcodsms to s_ctc89m00[m_scrline].ufdcodsms
         #                    next field cidnom
         #                end if
         #            else
         #                let ws.mpacidcod = 0
         #            end if
         #
         #    before field descodsms
         #    
         #        let l_sql = " select cpocod, cpodes from iddkdominio "
         #                    ," where cponom = 'tipcodsms' "
         #    
         #        call ofgrc001_popup ( 8
         #                             ,12
         #                             ,"CONSULTA TIPO DE SMS"
         #                             ,"Codigo"
         #                             ,"Descricao"
         #                             ,"N"
         #                             ,l_sql
         #                             ,""
         #                             ,"D" )
         #             returning lr_aux.coderr
         #                      ,ma_tipo[m_arrcurr].tipcodsms
         #                      ,ma_cidades[m_arrcurr].descodsms
         #                      
         #             display ma_cidades[m_arrcurr].descodsms to s_ctc89m00[m_scrline].descodsms
         #
         #    after field descodsms
         #
         #        if  ma_cidades[m_arrcurr].descodsms is null or ma_cidades[m_arrcurr].descodsms = " " then
         #
         #            call ofgrc001_popup ( 8
         #                                 ,12
         #                                 ,"CONSULTA TIPO DE SMS"
         #                                 ,"Codigo"
         #                                 ,"Descricao"
         #                                 ,"N"
         #                                 ,l_sql
         #                                 ,""
         #                                 ,"D" )
         #                 returning lr_aux.coderr                   
         #                          ,ma_tipo[m_arrcurr].tipcodsms   
         #                          ,ma_cidades[m_arrcurr].descodsms
         #            next field descodsms
         #        end if
         #
         #    after input
         #
         #    display "lr_aux.coderr                    = ", lr_aux.coderr                   
         #    display "ma_tipo[m_arrcurr].tipcodsms    = ", ma_tipo[m_arrcurr].tipcodsms   
         #    display "ma_cidades[m_arrcurr].descodsms = ", ma_cidades[m_arrcurr].descodsms
         #
         #    execute pcctc89m00_02 using ws.mpacidcod,
         #                                ma_tipo[m_arrcurr].tipcodsms,
         #                                g_issk.funmat
         #
         #    before insert
         #        let m_flagins = true
         #        display "m_flagins = ", m_flagins
         #
         #        next field cidnomsms
         #
         #    after insert
         #        let m_flagins = false
         #        display "m_flagins = ", m_flagins
         #
         #    if int_flag then
         #       exit while
         #    end if
         #
         #end input
         
         
         
         
         
         
         
         #input by name mr_entrada.cidnom,
         #              mr_entrada.ufdcod,
         #              mr_entrada.tipcod
         #
         #    after field cidnom
         #
         #        if  mr_entrada.cidnom is null or mr_entrada.cidnom = " " then
         #            call cts06g04(mr_entrada.cidnom, mr_entrada.ufdcod)
         #                returning ws.mpacidcod, mr_entrada.cidnom, mr_entrada.ufdcod
         #
         #            next field cidnom
         #        end if
         #
         #    after field ufdcod
         #
         #            if  mr_entrada.cidnom <> "TODAS" then
         #                display "BUSCANDO A CIDADE"
         #                open cqctc89m00_01 using mr_entrada.cidnom,
         #                                         mr_entrada.ufdcod
         #                fetch cqctc89m00_01 into ws.mpacidcod
         #                display "Sqlcode = ", sqlca.sqlcode
         #                display "CODIGO NA CIDADE = ", ws.mpacidcod
         #
         #                if  sqlca.sqlcode = notfound then
         #                    error "Cidade não encontrada."
         #                    let mr_entrada.cidnom = null
         #                    let mr_entrada.ufdcod = null
         #                    display by name mr_entrada.cidnom,
         #                                    mr_entrada.ufdcod
         #                    next field cidnom
         #                end if
         #            else
         #                let ws.mpacidcod = 0
         #            end if
         #
         #    after field tipcod
         #
         #        if  mr_entrada.tipcod is null or mr_entrada.tipcod = " " then
         #
         #         let l_sql = " select cpocod, cpodes from iddkdominio "
         #                     ," where cponom = 'tipcodsms' "
         #
         #         call ofgrc001_popup ( 8
         #                              ,12
         #                              ,"CONSULTA TIPO DE SMS"
         #                              ,"Codigo"
         #                              ,"Descricao"
         #                              ,"N"
         #                              ,l_sql
         #                              ,""
         #                              ,"D" )
         #              returning lr_aux.coderr
         #                       ,mr_entrada.tipcod
         #                       ,lr_aux.descod
         #            next field tipcod
         #        end if
         #
         #    after input
         #
         #
         #        display "lr_aux.coderr      = ", lr_aux.coderr
         #        display "mr_entrada.tipcod = ", mr_entrada.tipcod
         #        display "lr_aux.descod      = ", lr_aux.descod
         #
         #        execute pcctc89m00_02 using ws.mpacidcod,
         #                                    mr_entrada.tipcod,
         #                                    g_issk.funmat
         #
         #    if  int_flag then
         #        exit input
         #    end if
         #
         #end input
         #
         #if  int_flag then
         #    exit while
         #end if
         
         if  int_flag then
             exit while
         end if
         
      end while

     close window w_ctc89m00

 end function

#----------------------------------#
 function ctc89m00_carrega_array()
#----------------------------------#

     define lr_aux record
         mpacidcod    like datkmpacid.mpacidcod,
         envsst integer
     end record
     
     define lr_datkgeral record
         grlchv like datkgeral.grlchv,
         grlinf like datkgeral.grlinf,
         atldat like datkgeral.atldat,
         atlhor like datkgeral.atlhor,
         atlemp like datkgeral.atlemp,
         atlmat like datkgeral.atlmat
     end record
         
     define l_ind  integer,
            l_sql  char(500)
     
     initialize mr_entrada.*,
                ws.*,
                ma_cidades,
                lr_aux,
                lr_datkgeral to null     

     let l_ind = 1

     display "(F1)Incluir (F2)Excluir (F6)Ordenar " to msgfun
     
     open cqctc89m00_18
     foreach cqctc89m00_18 into lr_datkgeral.grlchv
                               ,lr_datkgeral.grlinf
                               ,lr_datkgeral.atldat
                               ,lr_datkgeral.atlhor
                               ,lr_datkgeral.atlemp
                               ,lr_datkgeral.atlmat
     
         let m_char = lr_datkgeral.grlchv clipped
         
         let ma_cidades[l_ind].cidnomsms = lr_datkgeral.grlinf clipped
         
         let ma_cidades[l_ind].ufdcodsms = m_char[8,9]       
         
         let ma_cidades[l_ind].envsst = m_char[10,15] clipped
         
         open cqctc89m00_05 using ma_cidades[l_ind].envsst
         fetch cqctc89m00_05 into ma_cidades[l_ind].descodsms
         
         let l_ind = l_ind + 1

     end foreach
     
     let l_sql = "select c.cidnom, c.ufdcod, s.envstt, c.mpacidcod ",
                  " from dbsmsmsalrcid s, datkmpacid c ",
                 " where s.mpacidcod = c.mpacidcod ",
                 " order by ", mr_orde.pri, ",",
                               mr_orde.seg, ",",
                               mr_orde.ter

     prepare pcctc89m00_03 from l_sql
     declare cqctc89m00_03 cursor for pcctc89m00_03     

     open cqctc89m00_03
     foreach cqctc89m00_03 into ma_cidades[l_ind].cidnomsms,
                                ma_cidades[l_ind].ufdcodsms,
                                ma_cidades[l_ind].envsst,
                                ma_cidades_aux[l_ind].mpacidcod

         open cqctc89m00_05 using ma_cidades[l_ind].envsst
         fetch cqctc89m00_05 into ma_cidades[l_ind].descodsms
         
         let l_ind = l_ind + 1

     end foreach

     call set_count(l_ind)

     #exit display

 end function 

#--------------------------# 
 function ctc89m00_inclui()
#--------------------------# 
 
     define lr_aux record
         mpacidcod like datkmpacid.mpacidcod,
         coderr integer,
         descod char(100),
         txt1   char(002),
         txt2   char(025)
     end record 
     
     define lr_ctd01g00 record
         retorno    smallint,
         mensagem   char(100),
         cidsedcod  like datrcidsed.cidsedcod
     end record 
     
     define l_sql       char(500),
            l_cidsednom like datkmpacid.cidnom
     
     initialize lr_ctd01g00.* to null
     
     open window w_ctc89m00a at 9,24 with form 'ctc89m00a'
        attribute (form line 1, border, comment line last - 1)
        
     initialize mr_entrada.* to null
     
     input by name mr_entrada.cidnom,                                             
                   mr_entrada.ufdcod,                                             
                   mr_entrada.tipcod                                              
                                                                                  
         after field cidnom                                                       
                                                                                  
             if  mr_entrada.cidnom is null or mr_entrada.cidnom = " " then        
                 call cts06g04(mr_entrada.cidnom, mr_entrada.ufdcod)              
                     returning ws.mpacidcod, mr_entrada.cidnom, mr_entrada.ufdcod    
                                                                                  
                 next field cidnom                                                
             end if                                                               
                                                                                  
         after field ufdcod                                                       
                                                                                  
                 if  mr_entrada.cidnom <> "TODAS" then                            
                     if  mr_entrada.ufdcod = "TD" then
                         error "Operação não permitida."
                         next field cidnom
                     end if 
                                                
                     open cqctc89m00_01 using mr_entrada.cidnom,                  
                                              mr_entrada.ufdcod                   
                     fetch cqctc89m00_01 into ws.mpacidcod                              
                                                                                  
                     if  sqlca.sqlcode = notfound then                            
                         error "Cidade sede não encontrada."                           
                         let mr_entrada.cidnom = null                             
                         let mr_entrada.ufdcod = null                             
                         display by name mr_entrada.cidnom,                       
                                         mr_entrada.ufdcod                        
                         next field cidnom                                        
                     else
                         call ctd01g00_verifica_cidsed(1,ws.mpacidcod)
                             returning lr_ctd01g00.retorno,
                                       lr_ctd01g00.mensagem 
                         if lr_ctd01g00.retorno <> 1 then
                             call 	ctd01g00_obter_cidsedcod(1,ws.mpacidcod)
                                 returning lr_ctd01g00.retorno,           
                                           lr_ctd01g00.mensagem,
                                           lr_ctd01g00.cidsedcod
                             
                             if lr_ctd01g00.retorno = 1 then
                                 open cqctc89m00_20 using lr_ctd01g00.cidsedcod                 
                                 fetch cqctc89m00_20 into l_cidsednom
                                 
                                 error "Esta cidade nao e sede. Mas, faz parte de cidade sede ", l_cidsednom
                             else
                                 error "Esta cidade nao possui cidade sede" 
                             end if
                             next field cidnom   
                         end if
                     end if                                                       
                 else                                                             
                     let ws.mpacidcod = 0                                            
                 end if                                                           
                                                                                  
         after field tipcod                                                       
                                                                                  
             if  mr_entrada.tipcod is null or mr_entrada.tipcod = " " then        
                                                                                  
                 if fgl_lastkey() = fgl_keyval("up")   or                      
                    fgl_lastkey() = fgl_keyval("left") then
                    next field ufdcod
                 end if                    
                 
                 let l_sql = " select cpocod, cpodes from iddkdominio "
                             ," where cponom = 'tipcodsms' "           
                                                                       
                 call ofgrc001_popup ( 8                               
                                      ,12                              
                                      ,"CONSULTA TIPO DE SMS"          
                                      ,"Codigo"                        
                                      ,"Descricao"                     
                                      ,"N"                             
                                      ,l_sql                           
                                      ,""                              
                                      ,"D" )                           
                      returning lr_aux.coderr                          
                               ,mr_entrada.tipcod                      
                               ,mr_entrada.destipsms                   
                 next field tipcod                                  
                                  
             else
                 open cqctc89m00_07 using mr_entrada.tipcod
                 fetch cqctc89m00_07 into mr_entrada.destipsms
                 
                 if  sqlca.sqlcode = notfound then
                     error "Tipo de alerta SMS não cadastrado."
                     let mr_entrada.tipcod = ""
                     let mr_entrada.destipsms = ""
                     display by name mr_entrada.tipcod 
                     display by name mr_entrada.destipsms 
                     next field tipcod
                 end if
             end if                                                               
             
             display by name mr_entrada.destipsms 
             
                                                          
             if   ctc89m00_vrf_cid_cad(mr_entrada.cidnom,
                                       mr_entrada.ufdcod,
                                       mr_entrada.tipcod) then
                 error "Já existe o tipode SMS para essa cidade"
                 next field cidnom
             end if
             
             if  mr_entrada.cidnom = "TODAS" or mr_entrada.ufdcod = "TD" then
                 
                 if  mr_entrada.cidnom = "TODAS" and mr_entrada.ufdcod = "TD" then
                     
                     #open cqctc89m00_08 using mr_entrada.cidnom,
                     #                         mr_entrada.ufdcod 
                     #                         mr_entrada.tipcod
                     #fetch cqctc89m00_08 into lr_aux.coderr
                     
                     let m_chave2 = m_chave1 clipped, "TD", mr_entrada.tipcod using '<<<'
                     
                     open cqctc89m00_08 using mr_entrada.tipcod
                     fetch cqctc89m00_08 into lr_aux.coderr     
                     
                     if  sqlca.sqlcode = 0 then
                     
                         if  cts08g01("A","S","EXISTEM RELACIONAMENTOS ESPECIFICOS",
                                              "CADASTRADOS EM UM OU MAIS LOCAIS. ",
                                              "GOSTARIA DE EXCLUIR OS RELACIONAMENTOS ",
                                              "ANTERIORES PARA INCLUIR ESTE NOVO?") = "S" then
                             if cts08g01("A","S","",
                                         "TEM CERTEZA?","",
                                         "") = "S" then
                                 #call ctc89m00_excluir_relacionamentos("T")
                                 execute pcctc89m00_10 using mr_entrada.tipcod
                                 let m_char = m_chave1 clipped, "%", mr_entrada.tipcod using '<<<'
                                 execute pcctc89m00_16 using m_char
                             else
                                 next field cidnom
                             end if
                         else
                             next field cidnom
                         end if

                     end if
                     
                     let m_char = m_chave1 clipped, "%", mr_entrada.tipcod using '<<<'
                     open cqctc89m00_17 using m_char
                     fetch cqctc89m00_17 into lr_aux.coderr     
                     
                     if  sqlca.sqlcode = 0 then
                     
                         if  cts08g01("A","S","EXISTEM RELACIONAMENTOS ESPECIFICOS",
                                              "CADASTRADOS EM UM OU MAIS LOCAIS. ",
                                              "GOSTARIA DE EXCLUIR OS RELACIONAMENTOS ",
                                              "ANTERIORES PARA INCLUIR ESTE NOVO?") = "S" then
                             if cts08g01("A","S","",
                                         "TEM CERTEZA?","","") = "S" then
                                 #call ctc89m00_excluir_relacionamentos("T")
                                 execute pcctc89m00_10 using mr_entrada.tipcod
                                 let m_char = m_chave1 clipped, "%", mr_entrada.tipcod using '<<<'
                                 execute pcctc89m00_16 using m_char
                             else
                                 next field cidnom
                             end if
                         else
                             next field cidnom
                         end if

                     end if
                     
                 else
                     if  mr_entrada.cidnom = "TODAS" then
                         
                         #open cqctc89m00_09 using mr_entrada.cidnom,
                         #                         mr_entrada.ufdcod,
                         #                         mr_entrada.tipcod  
                         #fetch cqctc89m00_09 into lr_aux.coderr
                         let m_chave2 = m_chave1 clipped, mr_entrada.ufdcod clipped
                                       ,mr_entrada.tipcod using '<<<'
                                                               
                         open cqctc89m00_09 using mr_entrada.ufdcod,
                                                  mr_entrada.tipcod
                         fetch cqctc89m00_09 into lr_aux.coderr 
                         
                         if sqlca.sqlcode = 0 then
                                   
                             if  cts08g01("A","S","EXISTEM RELACIONAMENTOS GERAIS",          
                                                  "CADASTRADOS NESTA UF. ",                       
                                                  "GOSTARIA DE EXCLUIR OS RELACIONAMENTOS ",      
                                                  "ANTERIORES PARA INCLUIR ESTE NOVO?") = "S" then
                                 if cts08g01("A","S","",                                          
                                             "TEM CERTEZA?","",                                      
                                             "") = "S" then
                                     #call ctc89m00_excluir_relacionamentos("E")              
                                     #execute pcctc89m00_16 using m_chave2                    
                                     execute pcctc89m00_11 using mr_entrada.tipcod,           
                                                                 mr_entrada.ufdcod            
                                                                                              
                                 else                                                         
                                     next field cidnom                                        
                                 end if                                                       
                             else                                                             
                                 next field cidnom                                            
                             end if  
                         end if
                                                          
                         let m_char = m_chave1 clipped, "TD", mr_entrada.tipcod using '<<<'
                         open cqctc89m00_17 using m_char
                         fetch cqctc89m00_17 into lr_aux.coderr     
                         
                         if sqlca.sqlcode = 0 then
                             if  cts08g01("A","S","EXISTEM RELACIONAMENTOS GERAIS",          
                                                  "CADASTRADOS NESTA UF. ",                       
                                                  "GOSTARIA DE EXCLUIR OS RELACIONAMENTOS ",      
                                                  "ANTERIORES PARA INCLUIR ESTE NOVO?") = "S" then
                                 if cts08g01("A","S","",                                          
                                             "TEM CERTEZA?","",                                      
                                             "") = "S" then                 
                                     execute pcctc89m00_16 using m_char                                    
                                 else                                                         
                                     next field cidnom                                        
                                 end if                                                       
                             else                                                             
                                 next field cidnom                                            
                             end if  
                         end if
                     end if
                 end if
             else
                 
                 #let lr_aux.txt1 = "TD"
                 #let lr_aux.txt2 = "TODAS"
                 #
                 #open cqctc89m00_06 using lr_aux.txt2,
                 #                         lr_aux.txt1,                        
                 #                         mr_entrada.tipcod                   
                 #fetch cqctc89m00_06 into lr_aux.coderr     
                 
                 let m_chave2 = m_chave1 clipped, "TD", mr_entrada.tipcod using '<<<'
                                                       
                 open cqctc89m00_17 using m_chave2    
                 fetch cqctc89m00_17 into lr_aux.coderr
                 
                 if  sqlca.sqlcode = 0 then
                                                                                                                       
                     if  cts08g01("A","S","EXISTEM UM RELACIONAMENTO GERAL",              
                                          "",                                             
                                          "GOSTARIA DE EXCLUIR OS RELACIONAMENTOS ",      
                                          "ANTERIORES PARA INCLUIR ESTE NOVO?") = "S" then
                      
                         execute pcctc89m00_16 using m_chave2 
                         #open cqctc89m00_13 using lr_aux.txt2, 
                         #                         lr_aux.txt1
                         #foreach cqctc89m00_13 into lr_aux.mpacidcod 
                         #
                         #    execute pcctc89m00_11 using lr_aux.mpacidcod,
                         #                                mr_entrada.tipcod
                         #end foreach
                     else
                         next field cidnom
                     end if
                 else
                 
                     #open cqctc89m00_13 using lr_aux.txt2,                                 
                     #                         mr_entrada.ufdcod                 
                     #fetch cqctc89m00_13 into mr_entrada.mpacidcod            
                     
                     #open cqctc89m00_06 using lr_aux.txt2,     
                     #                         mr_entrada.ufdcod,
                     #                         mr_entrada.tipcod                        
                     #fetch cqctc89m00_06 into lr_aux.coderr                            
                     
                     let m_chave2 = m_chave1 clipped, mr_entrada.ufdcod clipped
                                   ,mr_entrada.tipcod using '<<<'
                                                                                
                     open cqctc89m00_17 using m_chave2     
                     fetch cqctc89m00_17 into lr_aux.coderr
                     
                     
                     if  sqlca.sqlcode = 0 then
                         if  cts08g01("A","S","EXISTEM RELACIONAMENTOS GERAIS",              
                                          "CADASTRADOS NESTA UF. ",                                             
                                          "GOSTARIA DE EXCLUIR OS RELACIONAMENTOS ",      
                                          "ANTERIORES PARA INCLUIR ESTE NOVO?") = "S" then
                             execute pcctc89m00_16 using m_chave2
                             #open cqctc89m00_14 using lr_aux.txt1
                             #foreach cqctc89m00_14 into lr_aux.mpacidcod
                             #
                             #execute pcctc89m00_11 using lr_aux.mpacidcod,
                             #                            mr_entrada.tipcod
                             #end foreach
                         else
                             next field cidnom
                         end if
                     end if
                 end if
             end if
         
         after input                                                              
                                                                  
             if  not int_flag then     
                 
                 if mr_entrada.cidnom = "TODAS" or mr_entrada.ufdcod = "TD" then
                     execute pcctc89m00_15 using m_chave2,                      
                                                 g_issk.empcod,
                                                 g_issk.funmat
                 else
                     open cqctc89m00_13 using mr_entrada.cidnom, 
                                              mr_entrada.ufdcod
                     fetch cqctc89m00_13 into mr_entrada.mpacidcod
                     
                     if sqlca.sqlcode = 0 then                                          
                                                                               
                         execute pcctc89m00_02 using mr_entrada.mpacidcod,    
                                                     mr_entrada.tipcod,    
                                                     g_issk.funmat
                     else                                                      
                         if sqlca.sqlcode = 100 then                           
                             error "Cidade não encontrada"                   
                         else                                                  
                             error "Erro cqctc89m00_13 ", sqlca.sqlcode        
                         end if                                                
                     end if                                                    
                     
                 end if
             end if                                                                                                                                  
                                                                                  
     end input
     
     let int_flag = false
     
     close window w_ctc89m00a                                                                                                                                          
 
 end function 

#------------------------------------#
 function ctc89m00_vrf_cid_cad(param)
#------------------------------------#
    
    define param record
        cidnom like datkmpacid.cidnom,
        ufdcod like datkmpacid.ufdcod,
        tipsms char(01)
    end record
    
    define l_status smallint,
           l_mpacidcod like datkmpacid.mpacidcod
    
    #if  param.cidnom = 0 then
    #    let ws.mpacidcod = param.cidnom
    #else
    #    open cqctc89m00_01 using param.cidnom,
    #                             param.ufdcod
    #    fetch cqctc89m00_01 into ws.mpacidcod
    #end if
    
    #if  sqlca.sqlcode <> 0 then
    #    error "Problemna na localização da cidade. cqctc89m00_01"
    #    return false
    #end if
    
    if param.cidnom = "TODAS" or param.ufdcod = "TD" then
        
        let m_char = m_chave1 clipped, param.ufdcod clipped, param.tipsms using '<<<' 
        open cqctc89m00_17 using m_char
        fetch cqctc89m00_17 into l_status
        
        if  sqlca.sqlcode = 0 then
            return true
        end if  
    else
        open cqctc89m00_06 using param.cidnom,
                                 param.ufdcod,
                                 param.tipsms
        fetch cqctc89m00_06 into l_status
        
        if  sqlca.sqlcode = 0 then
            return true
        end if
    end if
    
    return false
    
 end function 
 
 
#-------------------------------# 
 function ctc89m00_ordena(param)
#-------------------------------#
    
    define l_ord char(15),
           param char(01)
    
    
    
    if  m_ordenacao <> 0 then
        if  param = "S" then
        
        
            let m_ordenacao = m_ordenacao + 1
            
            if  m_ordenacao = 4 then
                let m_ordenacao = 1
            end if
            
            case m_ordenacao
               when 2
                    let mr_orde.pri = 2
                    let mr_orde.seg = 1
                    let mr_orde.ter = 3
               when 3
                    let mr_orde.pri = 3
                    let mr_orde.seg = 1
                    let mr_orde.ter = 2
               when 1
                    let mr_orde.pri = 1
                    let mr_orde.seg = 2
                    let mr_orde.ter = 3
               otherwise
               
            end case
        end if
    else
        let m_ordenacao = m_ordenacao + 1
        let mr_orde.pri = 1
        let mr_orde.seg = 2
        let mr_orde.ter = 3
    end if

    case m_ordenacao 
        when 1
            let l_ord = "CIDADE    "
        when 2
            let l_ord = "ESTADO    "
        when 3
            let l_ord = "TIPO DE AVISO"
    end case
    
    display l_ord to msgord attribute (reverse)
    
 end function
 
 
#------------------------------------------------# 
 function ctc89m00_excluir_relacionamentos(param)
#------------------------------------------------#
 
     define param char(1)
     
     case param
          when "T"
               execute pcctc89m00_10 using mr_entrada.tipcod
          when "E"
               
               open cqctc89m00_14 using mr_entrada.ufdcod        
               foreach cqctc89m00_14 into mr_entrada.mpacidcod  
                                                            
                   execute pcctc89m00_11 using mr_entrada.mpacidcod,
                                               mr_entrada.tipcod
               end foreach
               #execute pcctc89m00_11 using mr_entrada.ufdcod, mr_entrada.tipcod
          otherwise
               error "Opcao invalida"
     end case
 
end function
 
#---------------------------# 
 function ctc89m00_excluir()
#---------------------------#

     define l_curr integer,
            l_mpacidcod like datkmpacid.mpacidcod
     
     let l_mpacidcod = null
     let l_curr = arr_curr()
     
     if ma_cidades[l_curr].cidnomsms = "TODAS" or ma_cidades[l_curr].ufdcodsms = "TD" then
          let m_char = m_chave1 clipped, ma_cidades[l_curr].ufdcodsms clipped
                      ,ma_cidades[l_curr].envsst using '<<<'
          execute pcctc89m00_16 using m_char  
     
     else
         open cqctc89m00_13 using ma_cidades[l_curr].cidnomsms,
                                  ma_cidades[l_curr].ufdcodsms
         fetch cqctc89m00_13 into l_mpacidcod          
         
         if sqlca.sqlcode = 0 then
         
             execute pcctc89m00_19 using l_mpacidcod,
                                         ma_cidades[l_curr].envsst    
         else
             if sqlca.sqlcode = 100 then
                 error "Cidade não encontrada"
             else
                 error "Erro cqctc89m00_13 ", sqlca.sqlcode 
             end if
         end if
     
     end if                                        
     
     #execute pcctc89m00_12 using ma_cidades[l_curr].ufdcodsms,
     #                            ma_cidades[l_curr].cidnomsms,
     #                            ma_tipo[l_curr].envsst

 end function