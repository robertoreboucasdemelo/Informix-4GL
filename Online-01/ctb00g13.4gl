###############################################################################
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema       : Ct24h                                                       #
# Modulo        : ctb00g13                                                    #
# Analista Resp.: Sergio Burini                                               #
# PSI           : 237248                                                      #
# Objetivo      : Consultar os seguros do veiculo                             #
#.............................................................................#
# Desenvolvimento: Helio (Meta)                                               #
# Liberacao      :                                                            #
#.............................................................................#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
#                                                                             #
###############################################################################

database porto

define m_prep   char(01) 

define lr_ctb00g1302    record
   succodveic           like abbmveic.succod
  ,aplnumdigveic        like abbmveic.aplnumdig
  ,itmnumdigveic        like abbmveic.itmnumdig
  ,succoddoc            like abbmdoc.succod
  ,aplnumdigdoc         like abbmdoc.aplnumdig
  ,itmnumdigdoc         like abbmdoc.itmnumdig
  ,result               char(01)
  ,dctnumseq            like abbmdoc.dctnumseq
  ,vclsitatu            like abbmitem.vclsitatu
  ,autsitatu            like abbmitem.autsitatu
  ,dmtsitatu            like abbmitem.dmtsitatu
  ,dpssitatu            like abbmitem.dpssitatu
  ,appsitatu            like abbmitem.appsitatu
  ,vidsitatu            like abbmitem.vidsitatu

end record 

define lr_ctb00g1303    record
   coderro              integer                   #Cod. erro 0-OK/<>0-Erro
  ,msgerro              char(50)                  #Mensagem erro 
  ,valordm              like abbmcobertura.imsvlr #Valor da cobertura DM 
  ,valordp              like abbmcobertura.imsvlr #Valor da cobertura DP 
  ,valorinv             like abbmapp.imsinvvlr
  ,valormor             like abbmapp.imsmorvlr 
  ,rcostt               smallint
  ,qualificado          char(01)
end record 

define m_datvigini         like abbmdoc.viginc
define m_datvigfim         like abbmdoc.viginc

#------------------------------------------------------------------------------
function ctb00g13_prepare() 
#------------------------------------------------------------------------------

define l_sql     char(1000) 

   let l_sql = " select succod, aplnumdig, itmnumdig "
	      ,"   from abbmveic                     "
	      ,"  where vcllicnum = ?                " 
   prepare pctb00g13001 from l_sql
   declare cctb00g13001 cursor for pctb00g13001 

   let l_sql = " select succod, aplnumdig, itmnumdig "
	      ,"   from abbmdoc         "
	      ,"  where succod    = ?   "
	      ,"    and aplnumdig = ?   "
	      ,"    and itmnumdig = ?   "
	      ,"    and itmstt    = 'A' "
	      ,"    and ((viginc   <= ? and vigfnl   >= ?) "
	      ,"     or  (viginc   <= ? and vigfnl   >= ?)) "
	      ,"    and dctnumseq = ?   "
   prepare pctb00g13002 from l_sql
   declare cctb00g13002 cursor for pctb00g13002 

   let l_sql = " select imsvlr        "
	      ,"   from abbmcobertura "
	      ,"  where succod = ?    "
	      ,"    and aplnumdig = ? "
	      ,"    and itmnumdig = ? "
	      ,"    and dctnumseq = ? "
	      ,"    and cbtsgl = ?    " 
   prepare pctb00g13003 from l_sql
   declare cctb00g13003 cursor for pctb00g13003 
   
   # ALTERADO BURINI
   let l_sql = "select succod, ", 
                     " aplnumdig, ",
                     " itmnumdig ",       
                " from abbmveic ",                                
               " where vclchsfnl = ? "
   prepare pctb00g13004 from l_sql                 
   declare cctb00g13004 cursor for pctb00g13004    
   
   let l_sql = "select imsinvvlr, ",                           
                     " imsmorvlr ",                                                                               
                " from abbmapp ",                             
               " where succod    = ? ",    
                 " and aplnumdig = ? ",    
                 " and itmnumdig = ? ",    
                 " and dctnumseq = ? "
   prepare pctb00g13005 from l_sql                 
   declare cctb00g13005 cursor for pctb00g13005    
   
   let l_sql = "select 1 ",
                " from abbmclaus ",
               " where succod    = ? ",
                 " and aplnumdig = ? ",
                 " and itmnumdig = ? ",
                 " and dctnumseq = ? ",
                 " and clscod    = '111' "
   prepare pctb00g13006 from l_sql                 
   declare cctb00g13006 cursor for pctb00g13006  
   
   let l_sql = " select socvcltip ", 
                " from datkveiculo ",
               " where vcllicnum = ? "
   prepare pctb00g13007 from l_sql                 
   declare cctb00g13007 cursor for pctb00g13007   

   let m_prep = "S" 

end function #ctb00g13_prepare

#------------------------------------------------------------------------------
function ctb00g13(param) 
#------------------------------------------------------------------------------

define param    record
   vcllicnum            like abbmveic.vcllicnum    #Placa do veiculo
  ,vclchsfnl            like abbmveic.vclchsfnl
  ,socvcltip            like datkveiculo.socvcltip
  ,datini               like abbmdoc.viginc
  ,datfim               like abbmdoc.viginc
end record 

define l_imsvlr         like abbmcobertura.imsvlr #Valor da cobertura DM/DP             
       
   initialize lr_ctb00g1302 to null

   let m_datvigini = param.datini
   let m_datvigfim = param.datfim
   
   let lr_ctb00g1303.coderro   = 0   
   let lr_ctb00g1303.msgerro   = ""
   let lr_ctb00g1303.valordm   = 0 
   let lr_ctb00g1303.valordp   = 0
   let lr_ctb00g1303.valorinv = 0                                
   let lr_ctb00g1303.valormor = 0   

   if m_prep is null or
      m_prep = ""    then
      call ctb00g13_prepare() 
   end if 

   let lr_ctb00g1303.qualificado = "N"
   let lr_ctb00g1303.msgerro = "Irregular "

   display "BUSCANDO SEGURO DO AUTO"
   display "BUSCANDO ATRAVES DA PLACA : ", param.vcllicnum 
   
   # BUSCA DADOS DA APOLICE ATRAVES DA PLACA DO VEICULO
   open cctb00g13001 using param.vcllicnum
   fetch cctb00g13001 into lr_ctb00g1302.succodveic,   
                           lr_ctb00g1302.aplnumdigveic,
                           lr_ctb00g1302.itmnumdigveic
   
   if  sqlca.sqlcode <> 0 then
       if  sqlca.sqlcode = 100 then

           display "BUSCADO ATRAVES DO CHASSI : ", param.vclchsfnl
           
           # BUSCA DADOS DA APOLICE ATRAVES DO CHASSI DO VEICULO
           open cctb00g13004 using param.vclchsfnl
           fetch cctb00g13004 into lr_ctb00g1302.succodveic,   
                                   lr_ctb00g1302.aplnumdigveic,
                                   lr_ctb00g1302.itmnumdigveic  
                                   
           
           if  sqlca.sqlcode <> 0 then                                                                              
               let lr_ctb00g1303.coderro = sqlca.sqlcode                                                            
               let lr_ctb00g1303.msgerro = "Erro ao selecionar Dados Apolice cctb00g13005(ctb00g13):"                          
           else                                                                                          
               foreach cctb00g13004 into lr_ctb00g1302.succodveic,      
                                         lr_ctb00g1302.aplnumdigveic,   
                                         lr_ctb00g1302.itmnumdigveic    
                   
                   call ctb00g13_dados_apolice()
                   
                   if param.socvcltip = 3 then
                      if lr_ctb00g1303.valordm  >= 100000.00 or                                     # VALOR DM
                         lr_ctb00g1303.valordp  >= 100000.00 or                                     # VALOR DP
                         lr_ctb00g1303.valorinv >=  50000.00 or                                     # VALOR INVALIDEZ  + APP
                         lr_ctb00g1303.valormor >=  50000.00 or                                     # VALOR MORTE      + APP
                        (lr_ctb00g1303.rcostt  = true and lr_ctb00g1303.valordm >= 100000.00) then  # CLAUSULA 111 - SE POSSUIR ASSUME O VALOR DO DM
                         display "APOLICE REGULAR!!!"
                         let lr_ctb00g1303.qualificado = "S"
                         let lr_ctb00g1303.msgerro = "Regular "
                         exit foreach
                      end if
                   else
                      if lr_ctb00g1303.valordm  >= 100000.00 or
                         lr_ctb00g1303.valordp  >= 100000.00 or
                         lr_ctb00g1303.valorinv >=  30000.00 or
                         lr_ctb00g1303.valormor >=  30000.00 then
                         display "APOLICE REGULAR!!!"
                         let lr_ctb00g1303.qualificado = "S"
                         let lr_ctb00g1303.msgerro = "Regular "
                         exit foreach
                      end if
                   end if
                                          
               end foreach  
           end if                                            
       else
           let lr_ctb00g1303.coderro = sqlca.sqlcode                                           
           let lr_ctb00g1303.msgerro = "Erro ao selecionar Dados Aplolice cctb00g13001(ctb00g13):" 
       end if
   else        
       foreach cctb00g13001 into lr_ctb00g1302.succodveic,   
                                 lr_ctb00g1302.aplnumdigveic,
                                 lr_ctb00g1302.itmnumdigveic
           
           call ctb00g13_dados_apolice()
           
           if param.socvcltip = 3 then
              if lr_ctb00g1303.valordm  >= 150000.00 or                                     # VALOR DM
                 lr_ctb00g1303.valordp  >= 150000.00 or                                     # VALOR DP
                 lr_ctb00g1303.valorinv >=  50000.00 or                                     # VALOR INVALIDEZ  + APP
                 lr_ctb00g1303.valormor >=  50000.00 or                                     # VALOR MORTE      + APP
                (lr_ctb00g1303.rcostt  = true and lr_ctb00g1303.valordm >= 150000.00) then  # CLAUSULA 111 - SE POSSUIR ASSUME O VALOR DO DM
                 display "APOLICE REGULAR!!!"
                 let lr_ctb00g1303.qualificado = "S"
                 let lr_ctb00g1303.msgerro = "Regular "
                 exit foreach
              end if
           else
              if lr_ctb00g1303.valordm  >= 100000.00 or
                 lr_ctb00g1303.valordp  >= 100000.00 or
                 lr_ctb00g1303.valorinv >=  30000.00 or
                 lr_ctb00g1303.valormor >=  30000.00 then
                 display "APOLICE REGULAR!!!"
                 let lr_ctb00g1303.qualificado = "S"
                 let lr_ctb00g1303.msgerro = "Regular "
                 exit foreach
              end if
           end if  
                    
       end foreach  
   end if        
    
   display "lr_ctb00g1303.qualificado = ", lr_ctb00g1303.qualificado
   
   return lr_ctb00g1303.coderro,
          lr_ctb00g1303.msgerro,
          lr_ctb00g1303.qualificado  

end function 

#---------------------------------#
 function ctb00g13_dados_apolice()
#---------------------------------#
    
    define l_cbtsgl         char(02),
           l_valordp        like abbmcobertura.imsvlr,
           l_valordm        like abbmcobertura.imsvlr,
           l_valorinv       like abbmapp.imsinvvlr,
           l_valormor       like abbmapp.imsmorvlr,
           l_rcostt         smallint,
           l_status         smallint
    
    define lr_aux   record
                        coderro integer  #Cod. erro 0-OK/<>0-Erro
                       ,msgerro char(50) #Mensagem erro 
                    end record    

    let lr_ctb00g1303.valordp  = 0
    let lr_ctb00g1303.valordm  = 0
    let lr_ctb00g1303.valorinv = 0
    let lr_ctb00g1303.valormor = 0

    let l_rcostt   = false    
    
    let l_cbtsgl = "" 
    
    display "antes F_FUNAPOL_ULTIMA_SITUACAO"                            
    display 'lr_ctb00g1302.succodveic    = ', lr_ctb00g1302.succodveic   
    display 'lr_ctb00g1302.aplnumdigveic = ', lr_ctb00g1302.aplnumdigveic
    display 'lr_ctb00g1302.itmnumdigveic = ', lr_ctb00g1302.itmnumdigveic

    #RECUPERA ULTIMA SITUACAO DA APOLICE                                                         
    call f_funapol_ultima_situacao(lr_ctb00g1302.succodveic,                                     
                                   lr_ctb00g1302.aplnumdigveic,                                  
                                   lr_ctb00g1302.itmnumdigveic)                                  
         returning lr_ctb00g1302.result                                                          
                  ,lr_ctb00g1302.dctnumseq                                                       
                  ,lr_ctb00g1302.vclsitatu                                                       
                  ,lr_ctb00g1302.autsitatu                                                       
                  ,lr_ctb00g1302.dmtsitatu                                                       
                  ,lr_ctb00g1302.dpssitatu                                                       
                  ,lr_ctb00g1302.appsitatu                                                       
                  ,lr_ctb00g1302.vidsitatu                                                       
                                                                                                 
    display "depois F_FUNAPOL_ULTIMA_SITUACAO"  
    display 'lr_ctb00g1302.result    ', lr_ctb00g1302.result   
    display 'lr_ctb00g1302.dctnumseq ', lr_ctb00g1302.dctnumseq
    display 'lr_ctb00g1302.vclsitatu ', lr_ctb00g1302.vclsitatu
    display 'lr_ctb00g1302.autsitatu ', lr_ctb00g1302.autsitatu
    display 'lr_ctb00g1302.dmtsitatu ', lr_ctb00g1302.dmtsitatu
    display 'lr_ctb00g1302.dpssitatu ', lr_ctb00g1302.dpssitatu
    display 'lr_ctb00g1302.appsitatu ', lr_ctb00g1302.appsitatu
    display 'lr_ctb00g1302.vidsitatu ', lr_ctb00g1302.vidsitatu

    #SE NAO ENCONTROU REGISTRO, RETORNA                                                          
    if  lr_ctb00g1302.result <> "O"  then                                                         
        let lr_aux.coderro = 2
        let lr_aux.msgerro = "Situação da Apolice invalida. SQLCA=", sqlca.sqlcode
        
        let lr_ctb00g1303.valordp  = 0
        let lr_ctb00g1303.valordm  = 0
        let lr_ctb00g1303.valorinv = 0
        let lr_ctb00g1303.valormor = 0
                                      
        display lr_aux.msgerro        
        return                                                                                              
    end if                                                                                       
                                                                                                 
    if  sqlca.sqlcode <> 0 then                                                                   
        let lr_aux.coderro = 2
        let lr_aux.msgerro = "Erro ao selecionar funapol_ultima_situacao (ctb00g13). SQLCA=",  sqlca.sqlcode
         
        let lr_ctb00g1303.valordp  = 0
        let lr_ctb00g1303.valordm  = 0
        let lr_ctb00g1303.valorinv = 0
        let lr_ctb00g1303.valormor = 0
                                      
        display lr_aux.msgerro        
        return                                                                              
    end if                                                                                       

    display 'antes Cctb00g13002           '
    display 'lr_ctb00g1302.succodveic    = ', lr_ctb00g1302.succodveic   
    display 'lr_ctb00g1302.aplnumdigveic = ', lr_ctb00g1302.aplnumdigveic 
    display 'lr_ctb00g1302.itmnumdigveic = ', lr_ctb00g1302.itmnumdigveic 
    display 'lr_ctb00g1302.dctnumseq     = ', lr_ctb00g1302.dctnumseq     

    whenever error continue                                                                      
    open cctb00g13002 using lr_ctb00g1302.succodveic,                                            
                            lr_ctb00g1302.aplnumdigveic,                                         
                            lr_ctb00g1302.itmnumdigveic,                                         
                            m_datvigini,
                            m_datvigini,
                            m_datvigfim,
                            m_datvigfim,                                                                                           
                            lr_ctb00g1302.dctnumseq                                              
    fetch cctb00g13002 into lr_ctb00g1302.succoddoc,                                             
                            lr_ctb00g1302.aplnumdigdoc,                                          
                            lr_ctb00g1302.itmnumdigdoc 
                            
    display 'lr_ctb00g1302.succoddoc    = ', lr_ctb00g1302.succoddoc                           
    display 'lr_ctb00g1302.aplnumdigdoc = ', lr_ctb00g1302.aplnumdigdoc                       
    display 'lr_ctb00g1302.itmnumdigdoc = ', lr_ctb00g1302.itmnumdigdoc                       
                                                                  
    whenever error stop                                                                          
    if  sqlca.sqlcode <> 0 then                                                                   
        if  sqlca.sqlcode = 100 then                                                               
            let lr_aux.coderro = 1
            let lr_aux.msgerro = "Apolice nao encontrada. SQLCA= ", sqlca.sqlcode
            
            let lr_ctb00g1303.valordp  = 0 
            let lr_ctb00g1303.valordm  = 0
            let lr_ctb00g1303.valorinv = 0
            let lr_ctb00g1303.valormor = 0
            
            display lr_aux.msgerro
            return                                                                     
        else                                                                                      
            if  sqlca.sqlcode <> 0 then                                                                   
                let lr_aux.coderro = 2
                let lr_aux.msgerro = "Erro ao selecionar abbmdoc(ctb00g13). SQLCA=", sqlca.sqlcode
                
                let lr_ctb00g1303.valordp  = 0 
                let lr_ctb00g1303.valordm  = 0
                let lr_ctb00g1303.valorinv = 0
                let lr_ctb00g1303.valormor = 0
                
                display lr_aux.msgerro
                return                                                            
            end if                                                                           
        end if                                                                                    
    end if     

    let l_cbtsgl = "DM"                                                                                    
                                                                                                 
    #Recupera o valor da cobertura RCF-DM                                                                                 
    display 'lr_ctb00g1302.succoddoc     = ', lr_ctb00g1302.succoddoc  
    display 'lr_ctb00g1302.aplnumdigdoc  = ', lr_ctb00g1302.aplnumdigdoc
    display 'lr_ctb00g1302.itmnumdigdoc  = ', lr_ctb00g1302.itmnumdigdoc
    display 'lr_ctb00g1302.dmtsitatu     = ', lr_ctb00g1302.dmtsitatu    
    display 'l_cbtsgl                    = ', l_cbtsgl                                                                                          
                                                                                                 
    whenever error continue                                                                      
    open cctb00g13003 using lr_ctb00g1302.succoddoc,                                             
                            lr_ctb00g1302.aplnumdigdoc,                                          
                            lr_ctb00g1302.itmnumdigdoc,                                          
                            lr_ctb00g1302.dmtsitatu,                                             
                            l_cbtsgl                                                             
    fetch cctb00g13003 into lr_ctb00g1303.valordm                                                            
    whenever  error  stop                                                                        
    
    display 'l_valordm                   = ', l_valordm
    
    if sqlca.sqlcode <> 0 then                                                                   
       if sqlca.sqlcode = notfound then                                                          
          let lr_ctb00g1303.valordm = 0                                                          
       else                                                                                      
          let lr_aux.coderro = 2                         
          let lr_aux.msgerro = "Erro ao selecionar abbmcobertura (ctb00g13). SQLCA=", sqlca.sqlcode  
                                                         
          let lr_ctb00g1303.valordp  = 0
          let lr_ctb00g1303.valordm  = 0
          let lr_ctb00g1303.valorinv = 0
          let lr_ctb00g1303.valormor = 0
                                        
          display lr_aux.msgerro        
          return                                                                                                                         
       end if                                                                                    
    end if                                                                                       
                                                                                                 
    #Recupera o valor da cobertura RCF-DP                                                                                                                                                 
    let l_cbtsgl = "DP"                                                                          
    
    whenever error continue                                                                      
    open cctb00g13003 using lr_ctb00g1302.succoddoc,                                             
                            lr_ctb00g1302.aplnumdigdoc,                                          
                            lr_ctb00g1302.itmnumdigdoc,                                          
                            lr_ctb00g1302.dpssitatu,                                             
                            l_cbtsgl                                                             
    fetch cctb00g13003 into lr_ctb00g1303.valordp 
    
    display 'l_valordp                   = ', l_valordp
                                                               
    whenever  error  stop                                                                        
    if sqlca.sqlcode <> 0 then                                                                   
       if sqlca.sqlcode = notfound then                                                          
          let lr_ctb00g1303.valordp = 0                                                          
       else                                                                                      
          let lr_aux.coderro = 2                         
          let lr_aux.msgerro = "Erro ao selecionar abbmcobertura (ctb00g13). SQLCA=", sqlca.sqlcode
                                                         
          let lr_ctb00g1303.valordp  = 0
          let lr_ctb00g1303.valordm  = 0
          let lr_ctb00g1303.valorinv = 0
          let lr_ctb00g1303.valormor = 0
                                        
          display lr_aux.msgerro        
          return                                                                                               
       end if                                                                                    
    end if      
    
    
    # ALTERACAO BONIFICAÇÃO - BURINI - INICIO
    #------------------------------------------------#
    # APP (Morte, invalidez e despesas hospitalares) #
    #------------------------------------------------#                                                                                     
    open cctb00g13005 using lr_ctb00g1302.succoddoc,   
                            lr_ctb00g1302.aplnumdigdoc,
                            lr_ctb00g1302.itmnumdigdoc,
                            lr_ctb00g1302.dpssitatu   
    fetch cctb00g13005 into lr_ctb00g1303.valorinv,
                            lr_ctb00g1303.valormor        
    
    
    display "lr_ctb00g1303.valorinv = ", lr_ctb00g1303.valorinv
    display "lr_ctb00g1303.valormor = ", lr_ctb00g1303.valormor
    
    
    
    
    
    if sqlca.sqlcode <> 0 then                                                                   
       if sqlca.sqlcode = notfound then                                                          
          let l_valorinv = 0 
          let l_valormor = 0                             
       else                                                                                      
          let lr_aux.coderro = 2                         
          let lr_aux.msgerro = "Erro ao selecionar APP (ctb00g13). SQLCA=", sqlca.sqlcode
                                                         
          let lr_ctb00g1303.valordp  = 0
          let lr_ctb00g1303.valordm  = 0
          let lr_ctb00g1303.valorinv = 0
          let lr_ctb00g1303.valormor = 0
                                        
          display lr_aux.msgerro        
          return                                                                                                  
       end if                                                                                    
    end if     

    #-----------------------------------------------#
    # Busca clausula 111 - Cobertura RC Operacional #
    #-----------------------------------------------#
    open cctb00g13006 using lr_ctb00g1302.succoddoc,   
                            lr_ctb00g1302.aplnumdigdoc,
                            lr_ctb00g1302.itmnumdigdoc,
                            lr_ctb00g1302.dpssitatu 
    fetch cctb00g13006 into l_status 
    
    if  sqlca.sqlcode = 0 then
        let l_rcostt = true
    else
        let l_rcostt = false
    end if
    
end function 
