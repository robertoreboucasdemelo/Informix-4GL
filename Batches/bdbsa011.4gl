#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: Ponto Socorro                                              #
# Modulo.........: bdbsa011                                                   #
# Analista Resp..: Beatriz Araujo                                             #
# Descricao......: Consulta imposto das OP pagas pelo SAP                     #
# ........................................................................... #
# Desenvolvimento: Robson Ruas                                                #
# Liberacao......: 07/02/2013                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/ffpgc371.4gl" 
globals "/homedsa/projetos/geral/globals/ffpgc361.4gl"

 define  m_dir1         char(030)   
        ,m_path         char(100)   
        ,m_assunto      char(100)   
        ,m_ret          integer  
        ,m_dat_processo date    
  
 define mr_bdbsa011 record
       socopgnum        like dbsmopg.socopgnum
      ,pstcoddig        like dbsmopg.pstcoddig
      ,socfatentdat     like dbsmopg.socfatentdat
      ,socfatpgtdat     like dbsmopg.socfatpgtdat
      ,empcod           like dbsmopg.empcod
      ,cctcod           like dbsmopg.cctcod
      ,pestip           like dbsmopg.pestip
      ,cgccpfnum        like dbsmopg.cgccpfnum
      ,cgcord           like dbsmopg.cgcord
      ,cgccpfdig        like dbsmopg.cgccpfdig
      ,funmat           like dbsmopg.funmat
      ,socpgtdoctip     like dbsmopg.socpgtdoctip
      ,socopgorgcod     like dbsmopg.socopgorgcod
      ,socopgsitcod     like dbsmopg.socopgsitcod
      ,succod           like dbsmopg.succod
      ,finsispgtordnum  like dbsmopg.finsispgtordnum
 end record
   
 
 define mr_socirfvlr    like dbsmopgtrb.socirfvlr
       ,mr_socissvlr    like dbsmopgtrb.socissvlr
       ,mr_insretvlr    like dbsmopgtrb.insretvlr
       ,mr_pisretvlr    like dbsmopgtrb.pisretvlr
       ,mr_cofretvlr    like dbsmopgtrb.cofretvlr
       ,mr_cslretvlr    like dbsmopgtrb.cslretvlr
       ,m_status        integer
       ,m_cnpjcpf       char(20)
   
main

 initialize m_path, m_dir1, m_ret to null

  call fun_dba_abre_banco("CT24HS")
  
  call bdbsa011_prepare() 
  
  
  let m_dir1 = f_path("DBS", "RELATO")                        
  if m_dir1 is null then                                      
     let m_dir1 = "."                                        
  end if                                                      
                                                              
  let m_path  = m_dir1 clipped, "/BDBSA011.xls"               
  
  set isolation to dirty read
  call bdbsa011()
  
  # enviar e-mail do resumo da emissao do dia                              
  let m_assunto = 'Resumo da emissao de O.P. Porto Socorro - '             
                 , today using "dd/mm/yyyy"                                
                                                                           
  let m_ret = ctx22g00_envia_email("BDBSA011", m_assunto, m_path)    
                                                                           
  if m_ret != 0 then                                                       
     if m_ret != 99 then                                                   
        display "Erro ao enviar email(BDBSA011) - ", m_path               
     else                                                                  
        display "Nao ha email cadastrado para o modulo "                   
     end if                                                                
  end if                                                                   
end main



#=============================================================================
function bdbsa011_prepare()
#=============================================================================

  define l_sql char(3000)

  let l_sql =  "select  socopgnum        "   
              ,"       ,pstcoddig        "   
              ,"       ,socfatentdat     "   
              ,"       ,socfatpgtdat     "   
              ,"       ,empcod           "   
              ,"       ,cctcod           "   
              ,"       ,pestip           "   
              ,"       ,cgccpfnum        "   
              ,"       ,cgcord           "   
              ,"       ,cgccpfdig        "   
              ,"       ,funmat           "   
              ,"       ,socpgtdoctip     "   
              ,"       ,socopgorgcod     "   
              ,"       ,socopgsitcod     " 
              ,"       ,succod           "
              ,"       ,finsispgtordnum  "
              ,"  from dbsmopg           "   
              ," where socopgsitcod = 7  "   
              ,"   and socfatpgtdat = ?  " 
              ,"   and empcod not in (84,35)"
   prepare pbdbsa011001 from l_sql             
   declare cbdbsa011001 cursor for pbdbsa011001
   
   
   let l_sql = "select socirfvlr,socissvlr,insretvlr, "
              ,"       pisretvlr,cofretvlr,cslretvlr  "
              ,"  from dbsmopgtrb    "
              ," where socopgnum = ? "
   prepare pbdbsa011002 from l_sql               
   declare cbdbsa011002 cursor for pbdbsa011002
                             
   let l_sql =  "update dbsmopgtrb     "
               ,"   set  socirfvlr = ?  "
               ,"       ,socissvlr = ?  "
               ,"       ,insretvlr = ?  "
               ,"       ,pisretvlr = ?  "
               ,"       ,cofretvlr = ?  "
               ,"       ,cslretvlr = ?  "
               ," where socopgnum = ?  "
               ,"   and empcod    = ?  "
               ,"   and succod    = ?  "
   prepare pbdbsa011003 from l_sql
   
   let l_sql =  "insert into dbsmopgtrb( socopgnum     "
               ,"                       ,empcod        "
               ,"                       ,succod        "
               ,"                       ,prstip        "
               ,"                       ,soctrbbasvlr  "
               ,"                       ,socirfvlr     "
               ,"                       ,socissvlr     "
               ,"                       ,insretvlr     "
               ,"                       ,pisretvlr     "
               ,"                       ,cofretvlr     "
               ,"                       ,cslretvlr)    "
               ,"                values (?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?             "
               ,"                       ,?)            "
   prepare pbdbsa011004 from l_sql

end function 


#=============================================================================
function  bdbsa011()
#=============================================================================

   define l_dat_processo   date 
   define l_empcod         char(04)
   define l_ind_tributavel char(1)
   
   initialize l_dat_processo,
              l_empcod,
              m_status, 
              l_ind_tributavel to null 
   
   let m_dat_processo = arg_val(1)
   
   if (m_dat_processo is null   or                                   
       m_dat_processo =  " "  ) then                                
       let m_dat_processo = today 
   end if   
   
   display "Data de Processamento: ", m_dat_processo    
   display "diretorio ", m_dir1                                                   
   
    
   call bdbsa011_initialize() 
                                                     
   start report bdbsa011_relat to m_path
   
    
   open cbdbsa011001 using    m_dat_processo
   foreach cbdbsa011001 into  mr_bdbsa011.socopgnum     
                              ,mr_bdbsa011.pstcoddig     
                              ,mr_bdbsa011.socfatentdat  
                              ,mr_bdbsa011.socfatpgtdat  
                              ,mr_bdbsa011.empcod        
                              ,mr_bdbsa011.cctcod        
                              ,mr_bdbsa011.pestip        
                              ,mr_bdbsa011.cgccpfnum     
                              ,mr_bdbsa011.cgcord        
                              ,mr_bdbsa011.cgccpfdig     
                              ,mr_bdbsa011.funmat        
                              ,mr_bdbsa011.socpgtdoctip  
                              ,mr_bdbsa011.socopgorgcod  
                              ,mr_bdbsa011.socopgsitcod  
                              ,mr_bdbsa011.succod
                              ,mr_bdbsa011.finsispgtordnum
                              
      if mr_bdbsa011.pestip = "J" then                                
         let m_cnpjcpf = mr_bdbsa011.cgccpfnum using '&&&&&&&&', "/" ,
                         mr_bdbsa011.cgcord     using '&&&&',"-" ,    
                         mr_bdbsa011.cgccpfdig using '&&'             
      else                                                            
                                                                      
       let  m_cnpjcpf = mr_bdbsa011.cgccpfnum using '&&&&&&&&&',      
                         "-",                                         
                        mr_bdbsa011.cgccpfdig using '&&'              
      end if                                                          
      
      open  cbdbsa011002 using  mr_bdbsa011.socopgnum
      fetch cbdbsa011002 into mr_socirfvlr, mr_socissvlr, mr_insretvlr,
                              mr_pisretvlr, mr_cofretvlr, mr_cslretvlr
      
      let m_status = sqlca.sqlcode
      
      if mr_socirfvlr > 0 or mr_socissvlr > 0 or
         mr_insretvlr > 0 or mr_pisretvlr > 0 or
         mr_cofretvlr > 0 or mr_cslretvlr > 0 then
         
         call bdbsa011_initialize()
         continue foreach
      end if

                
      
      let gr_aci_req_head.id_integracao   = "295PTSOC"              
      let gr_295_req_v1.codigo_origem      = "11"     #Codigo Origem       
      let gr_295_req_v1.empresa            =  mr_bdbsa011.empcod           #Empresa                            
      let gr_295_req_v1.ref_documento      =  mr_bdbsa011.socopgnum        #Nro de referencia documento        
      
      # função que verifica o imposto
      call ffpgc376_cons_op_por_ref()
      
      call bdbsa011_log()
      
      output to report bdbsa011_relat( mr_bdbsa011.socopgnum           
                                      ,mr_bdbsa011.socfatentdat
                                      ,mr_bdbsa011.socfatpgtdat
                                      ,mr_bdbsa011.empcod      
                                      ,m_cnpjcpf    )
      
      
      if m_status = 0 then
         whenever error continue
         execute pbdbsa011003 using gr_295_det_doc_v1.vlr_ir         
                                    ,gr_295_det_doc_v1.vlr_iss        
                                    ,gr_295_det_doc_v1.vlr_inss       
                                    ,gr_295_det_doc_v1.vlr_pis        
                                    ,gr_295_det_doc_v1.vlr_cofins     
                                    ,gr_295_det_doc_v1.vlr_csll       
                                    ,mr_bdbsa011.socopgnum          
                                    ,mr_bdbsa011.empcod             
                                    ,mr_bdbsa011.succod             
         whenever error stop                                      
         if sqlca.sqlcode <> 0 then                               
            display "Erro na atualizacao (cursor pbdbsa011003): ", 
                    sqlca.sqlcode, " ", sqlca.sqlerrd[2]          
         end if  
      else
         whenever error continue
         execute pbdbsa011004 using  mr_bdbsa011.socopgnum    
                                      ,mr_bdbsa011.empcod       
                                      ,mr_bdbsa011.succod       
                                      ,"P"  
                                      ,gr_295_det_doc_v1.vlr_brt_doc  
                                      ,gr_295_det_doc_v1.vlr_ir       
                                      ,gr_295_det_doc_v1.vlr_iss      
                                      ,gr_295_det_doc_v1.vlr_inss     
                                      ,gr_295_det_doc_v1.vlr_pis      
                                      ,gr_295_det_doc_v1.vlr_cofins   
                                      ,gr_295_det_doc_v1.vlr_csll
         whenever error stop                                      
         if sqlca.sqlcode <> 0 then                               
            display "Erro na inclusao (cursor pbdbsa011004): ",     
                    sqlca.sqlcode, " ", sqlca.sqlerrd[2]          
         end if  
      end if  
      
      call bdbsa011_initialize()
      
   end foreach 
   
   finish report bdbsa011_relat
   
end function 



#=============================================================================
function bdbsa011_initialize()
#=============================================================================

   initialize gr_295_req_v1.*            
             ,gr_295_cab_doc_v1.*                             
             ,gr_295_det_doc_v1.*                             
             ,gr_aci_req_head.*  
             ,ga_295_itm_doc_v1
             ,gr_aci_res_head.*
             ,gr_aci_req_head.*
             ,mr_bdbsa011.*  to null 
      
    initialize  mr_socirfvlr ,mr_socissvlr
               ,mr_insretvlr ,mr_pisretvlr
               ,mr_cofretvlr ,mr_cslretvlr
               ,m_cnpjcpf, m_status to null
      
end function




#=============================================================================
function bdbsa011_log()
#=============================================================================

 
   display ""   
   display "Retorno da Query cbdbsa011001"                                      
   display "mr_bdbsa011.socopgnum     ",mr_bdbsa011.socopgnum                                      
   display "mr_bdbsa011.pstcoddig     ",mr_bdbsa011.pstcoddig                                      
   display "mr_bdbsa011.socfatentdat  ",mr_bdbsa011.socfatentdat                                   
   display "mr_bdbsa011.socfatpgtdat  ",mr_bdbsa011.socfatpgtdat                                   
   display "mr_bdbsa011.empcod        ",mr_bdbsa011.empcod                                         
   display "mr_bdbsa011.cctcod        ",mr_bdbsa011.cctcod                                         
   display "mr_bdbsa011.pestip        ",mr_bdbsa011.pestip                                         
   display "mr_bdbsa011.cgccpfnum     ",mr_bdbsa011.cgccpfnum                                      
   display "mr_bdbsa011.cgcord        ",mr_bdbsa011.cgcord                                         
   display "mr_bdbsa011.cgccpfdig     ",mr_bdbsa011.cgccpfdig                                      
   display "mr_bdbsa011.funmat        ",mr_bdbsa011.funmat                                         
   display "mr_bdbsa011.socpgtdoctip  ",mr_bdbsa011.socpgtdoctip                                   
   display "mr_bdbsa011.socopgorgcod  ",mr_bdbsa011.socopgorgcod                                   
   display "mr_bdbsa011.socopgsitcod  ",mr_bdbsa011.socopgsitcod                                   
   display "mr_bdbsa011.succod        ",mr_bdbsa011.succod                                         
   display "============================================="
   display ""   
   
   #Entrada da fucao api295v1_cons_op_por_ref
   display "============================================="
   display " Entrada da ffpgc376_cons_op_por_ref"
   display "gr_295_req_v1.codigo_origem        : ", gr_295_req_v1.codigo_origem     
   display "gr_295_req_v1.empresa              : ", gr_295_req_v1.empresa           
   display "gr_295_req_v1.ref_documento        : ", gr_295_req_v1.ref_documento     
   display ""    
   display "Retorno da funcao ffpgc376_cons_op_por_ref "
   display "gr_aci_res_head.codigo_retorno     : ",gr_aci_res_head.codigo_retorno  # Codigo de retorno da integracao.            
   display "gr_aci_res_head.mensagem           : ",gr_aci_res_head.mensagem        # Mensagem de retorno da integracao.          
   display "gr_aci_res_head.tipo_erro          : ",gr_aci_res_head.tipo_erro       # Tipo de erro, caso ocorra.                  
   display "gr_aci_res_head.track_number       : ",gr_aci_res_head.track_number    # Numero de rastreio para integr assincronas.
   display "gr_295_cab_doc_v1.empresa          : ",gr_295_cab_doc_v1.empresa            
   display "gr_295_cab_doc_v1.codigo_origem    : ",gr_295_cab_doc_v1.codigo_origem      
   display "gr_295_cab_doc_v1.ref_documento    : ",gr_295_cab_doc_v1.ref_documento      
   display "gr_295_cab_doc_v1.documento_sap    : ",gr_295_cab_doc_v1.documento_sap  #relatório    
   display "gr_295_det_doc_v1.dat_fat          : ",gr_295_det_doc_v1.dat_fat            
   display "gr_295_det_doc_v1.num_nf           : ",gr_295_det_doc_v1.num_nf             
   display "gr_295_det_doc_v1.emp_cto_cst      : ",gr_295_det_doc_v1.emp_cto_cst        
   display "gr_295_det_doc_v1.vlr_brt_doc      : ",gr_295_det_doc_v1.vlr_brt_doc    #reltório      
   display "gr_295_det_doc_v1.dat_canc         : ",gr_295_det_doc_v1.dat_canc           
   display "gr_295_det_doc_v1.mtv_canc         : ",gr_295_det_doc_v1.mtv_canc           
   display "gr_295_det_doc_v1.cpf_cnpj_fnc     : ",gr_295_det_doc_v1.cpf_cnpj_fnc       
   display "gr_295_det_doc_v1.ord_cnpj_fnc     : ",gr_295_det_doc_v1.ord_cnpj_fnc       
   display "gr_295_det_doc_v1.dig_cpf_cnpj_fnc : ",gr_295_det_doc_v1.dig_cpf_cnpj_fnc   
   display "gr_295_det_doc_v1.cpf_cnpj_bfc     : ",gr_295_det_doc_v1.cpf_cnpj_bfc       
   display "gr_295_det_doc_v1.ord_cnpj_bfc     : ",gr_295_det_doc_v1.ord_cnpj_bfc       
   display "gr_295_det_doc_v1.dig_cpf_cnpj_bfc : ",gr_295_det_doc_v1.dig_cpf_cnpj_bfc   
   display "gr_295_det_doc_v1.vlr_ir           : ",gr_295_det_doc_v1.vlr_ir             
   display "gr_295_det_doc_v1.vlr_inss         : ",gr_295_det_doc_v1.vlr_inss           
   display "gr_295_det_doc_v1.vlr_iss          : ",gr_295_det_doc_v1.vlr_iss            
   display "gr_295_det_doc_v1.vlr_pis          : ",gr_295_det_doc_v1.vlr_pis            
   display "gr_295_det_doc_v1.vlr_cofins       : ",gr_295_det_doc_v1.vlr_cofins         
   display "gr_295_det_doc_v1.vlr_csll         : ",gr_295_det_doc_v1.vlr_csll           
   display "gr_295_det_doc_v1.matricula        : ",gr_295_det_doc_v1.matricula          
   display "gr_295_det_doc_v1.emp_mat          : ",gr_295_det_doc_v1.emp_mat            
   display "gr_295_det_doc_v1.tip_mat          : ",gr_295_det_doc_v1.tip_mat            
   display "gr_295_det_doc_v1.mat_canc         : ",gr_295_det_doc_v1.mat_canc           
   display "gr_295_det_doc_v1.emp_canc         : ",gr_295_det_doc_v1.emp_canc           
   display "gr_295_det_doc_v1.tip_mat_canc     : ",gr_295_det_doc_v1.tip_mat_canc 
   display "ga_295_itm_doc_v1.sit_documento    : ", ga_295_itm_doc_v1[1].sit_documento
   display "============================================="
   
   
end function






#=============================================================================
report bdbsa011_relat(lr_parametro)
#=============================================================================
                                                               
    define lr_parametro       record                           
            socopgnum               char(06),                  
            socfatentdat            date    ,                  
            socfatpgtdat            date    ,                  
            empcod                  char(50),
            cnpjcpf                 char(20)
    end record                                                 

  output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header

        print   "Numero OP",      ASCII(09), 
                "Data Entrada",   ASCII(09),
                "Data Pagamento", ASCII(09),
                "Empresa",        ASCII(09),
                "CNPJ/CPF",       ASCII(09),
                "ERRO CODIGO" ,   ASCII(09),
                "MSG ERRO" ,      ASCII(09);

        skip 1 line

     on every row

        print   lr_parametro.socopgnum,           ASCII(09), 
                lr_parametro.socfatentdat,        ASCII(09),
                lr_parametro.socfatpgtdat,        ASCII(09),
                lr_parametro.empcod,              ASCII(09),
                lr_parametro.cnpjcpf,             ASCII(09),
                gr_aci_res_head.codigo_retorno,   ASCII(09),
                gr_aci_res_head.mensagem,         ASCII(09);

        skip 1 line

end report

