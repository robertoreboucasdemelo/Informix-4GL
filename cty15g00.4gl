#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty15g00.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
# PSI           : 211354                                                     #
#                 Obter dados dos Clientes e Segurados pelo CGC/CPF          #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a   #
#                                         global                             #
#............................................................................#


database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

define m_prep_sql      smallint
define m_prep2_sql     smallint
define m_index_venc    integer
define m_possui_cartao smallint

define m_dctoarray_venc  array [2000] of record
   succod          like abamapol.succod    ,
   ramcod          like rsamseguro.ramcod  ,
   aplnumdig       like abamapol.aplnumdig ,
   itmnumdig       like abbmdoc.itmnumdig  ,
   dctnumseq       like abbmdoc.dctnumseq  ,
   aplqtditm       smallint                ,
   segnumdig       like gsakseg.segnumdig  ,
   prporg          like rsdmdocto.prporg   ,
   prpnumdig       like rsdmdocto.prpnumdig
end record
#---------------------------------------------------------------------
function cty15g00_prepare()
#---------------------------------------------------------------------

define l_sql     char(2000)

      let l_sql = ' select count(*) '
                 ,'   from gsakseg '
                 ,'  where cgccpfnum  =  ? '
                 ,'    and pestip     =  ? '
      prepare p_cty15g00_001  from l_sql
      declare c_cty15g00_001  cursor for p_cty15g00_001
      
      let l_sql = ' select count(*) '
                 ,'   from datkazlapl '
                 ,'  where cgccpfnum  =  ? '
                 ,'    and pestip     =  ? '
      prepare pcty15g00002  from l_sql
      declare ccty15g00002  cursor for pcty15g00002
      
      let l_sql = ' select count(*) '
                 ,'   from datksegsau '
                 ,'  where cgccpfnum  =  ? '
      prepare pcty15g00003  from l_sql
      declare ccty15g00003  cursor for pcty15g00003
      
      let l_sql = " select cgccpfnum "   ,
                  ",cgcord "             ,
                  ",cgccpfdig "          ,
                  ",segnom "             ,
                  ",segnumdig "          ,
                  ",pestip    "          ,
                  " from gsakseg "       ,
                  " where cgccpfnum = ? ",
                  " and cgcord = ? "     ,
                  " and cgccpfdig = ? "  ,
                  " and pestip = ? "
      prepare pcty15g00004  from l_sql
      declare ccty15g00004  cursor for pcty15g00004
      
      let l_sql = " select cgccpfnum "   ,
                  ",cgcord "             ,
                  ",cgccpfdig "          ,
                  ",segnom "             ,
                  ",pestip "             ,
                  " from datkazlapl "    ,
                  " where cgccpfnum = ? ",
                  " and cgcord = ? "     ,
                  " and cgccpfdig = ? "  ,
                  " and pestip = ? "
      prepare pcty15g00005  from l_sql
      declare ccty15g00005  cursor for pcty15g00005
      
      let l_sql = " select cgccpfnum "   ,
                  ",cgcord "             ,
                  ",cgccpfdig "          ,
                  ",segnom "             ,
                  " from datksegsau "    ,
                  " where cgccpfnum = ? ",
                  " and cgcord = ? "     ,
                  " and cgccpfdig = ? "
      prepare pcty15g00006 from l_sql
      declare ccty15g00006 cursor for pcty15g00006
      
      let l_sql = "select cpodes      ",                   
                  " from datkdominio  ",                   
                  " where cponom  = ? ",                   
                  " order by cpocod   "                    
      prepare pcty15g00008 from l_sql              
      declare ccty15g00008 cursor for pcty15g00008
      
      let l_sql = " select segcgccpfnum    , ",        
                  "        segcgcordnum    , ",        
                  "        segcgccpfdig    , ", 
                  "        segnom          , ",
                  "        pestipcod         ",    
                  " from datmitaapl          ",        
                  " where segcgccpfnum  = ?  ",        
                  " and   segcgcordnum  = ?  ",        
                  " and   segcgccpfdig  = ?  ",
                  " and   pestipcod     = ?  "                         
      prepare pcty15g00009 from l_sql              
      declare ccty15g00009 cursor for pcty15g00009 
      
       let l_sql = " select segcpjcpfnum   , ",        
                  "        cpjordnum       , ",        
                  "        cpjcpfdignum    , ", 
                  "        segnom          , ",
                  "        pestipcod         ",    
                  " from datmresitaapl       ",        
                  " where segcpjcpfnum  = ?  ",        
                  " and   cpjordnum     = ?  ",        
                  " and   cpjcpfdignum  = ?  ",
                  " and   pestipcod     = ?  "                         
      prepare pcty15g00010 from l_sql              
      declare ccty15g00010 cursor for pcty15g00010 
      
               
      let m_prep_sql = true

end function

#---------------------------------------------------------------------
function cty15g00_prepare2()
#---------------------------------------------------------------------
      define l_sql     char(2000)

      let l_sql = " select a.crdprpnom, a.pestipcod "       ,
                  " from fsckprpcrd a, fscmcntprs b "       ,
                  " where a.cgccpfnumdig = b.cgccpfnumdig " ,
                  " and a.cgccpfnumdig = ? "                ,
                  " and b.ttlstt[1,1]  = 'A'"
      prepare pcty15g00007 from l_sql
      declare ccty15g00007 cursor for pcty15g00007
      
      if figrc072_checkGlbIsolamento(sqlca.sqlcode        ,
                                     "cty15g00"           ,
                                     "cty15g00_prepare2"   ,
                                     "ccty15g00007"       ,
                                     "","","","","","")  then
         return
      end if
      
      let m_prep2_sql = true

end function

#---------------------------------------------------------------------------
function cty15g00_conta_cliente_cgccpf(lr_param)
#---------------------------------------------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    like gsakpes.pestip
end record

define lr_retorno record
       qtd integer     ,
       sqlcode smallint,
       mensagem char(50)
end record

define l_cty15g00_cgccpfnumdig char(18)

initialize lr_retorno.* to null


let l_cty15g00_cgccpfnumdig = null
  
   if m_prep_sql is null or
      m_prep_sql <> true then
      call cty15g00_prepare()
   end if
  
   if lr_param.cgcord is null then
      let lr_param.cgcord = 0
   end if
   
    message " Aguarde, pesquisando..." attribute (reverse)
   
   # Recupero pela gsakpes
   call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                       lr_param.cgcord    ,
                                       lr_param.cgccpfdig ,
                                       lr_param.pestip    )
   returning lr_retorno.sqlcode, lr_retorno.qtd
   
   # Recupero pela gsakseg
   if lr_retorno.qtd = 0 then
       open c_cty15g00_001 using lr_param.cgccpfnum,
                                 lr_param.pestip
       
       whenever error continue
       fetch c_cty15g00_001 into lr_retorno.qtd
       whenever error stop
       
       if sqlca.sqlcode <> 0 then
          let lr_retorno.qtd = 0
       end if
       
       close c_cty15g00_001
   end if
    
    # Recupero pela datkazlapl - Azul
    if lr_retorno.qtd = 0 then    
        open ccty15g00002 using lr_param.cgccpfnum,
                                lr_param.pestip
        
        whenever error continue
        fetch ccty15g00002 into lr_retorno.qtd
        whenever error stop
        
        if sqlca.sqlcode <> 0 then
           let lr_retorno.qtd = 0
        end if
        
        close ccty15g00002
    end if
    
    # Recupero pela datksegsau - Saude
    
    if lr_retorno.qtd = 0 then
        open ccty15g00003 using lr_param.cgccpfnum
       
        whenever error continue
        fetch ccty15g00003 into lr_retorno.qtd
        whenever error stop
        
        if sqlca.sqlcode <> 0 then
           let lr_retorno.qtd = 0
        end if
        
        close ccty15g00003
    end if
    
    # Recupero pelo Cartao Visa
    if lr_retorno.qtd = 0 then
        let l_cty15g00_cgccpfnumdig = ffpfc073_formata_cgccpf(lr_param.cgccpfnum ,
                                                              lr_param.cgcord    ,
                                                              lr_param.cgccpfdig )
         call figrc072_setTratarIsolamento()
        
         call ffpfc073_qtd_prop(l_cty15g00_cgccpfnumdig ,
                                lr_param.pestip           )
         returning lr_retorno.mensagem ,
                   lr_retorno.sqlcode,
                   lr_retorno.qtd
    end if
    
    # Recupero pela Proposta
    if lr_retorno.qtd = 0 then
      
       call figrc072_setTratarIsolamento()
     
       call fpacc280_rec_qtd_cgccpf_proposta(lr_param.cgccpfnum)
          returning lr_retorno.qtd
    end if
    
    # Recupero pela Vistoria
    if lr_retorno.qtd = 0 then
       let lr_retorno.qtd = fvpic012_rec_qtd_cgccpf_vistoria(lr_param.cgccpfnum)
    end if
    
    # Recupero pela Cobertura
    if lr_retorno.qtd = 0 then
       let lr_retorno.qtd = fvpic012_rec_qtd_cgccpf_cobertura(lr_param.cgccpfnum)
    end if
    
    
    # Recupero pelo Itau
    if lr_retorno.qtd = 0 then
      let lr_retorno.qtd = cty22g00_qtd_cgc_cpf(lr_param.cgccpfnum ,
                                                lr_param.cgcord    ,
                                                lr_param.cgccpfdig )
    end if
   
   return lr_retorno.qtd

end function

#---------------------------------------------------------------------------
function cty15g00_conta_cliente_nome(lr_param)
#---------------------------------------------------------------------------

define lr_param record
  segnom char(50),
  pestip char(01)
end record

define lr_retorno record
  sqlcode integer ,
  qtd integer
end record

initialize lr_retorno.* to null

 message " Aguarde, pesquisando Base de Clientes Unificados..." attribute (reverse)
 
 #-- Obter quantidade de segurados com o mesmo nome --#
 call osgtf550_conta_cliente_por_fonetica(lr_param.segnom,lr_param.pestip)
 returning lr_retorno.sqlcode   ,
           lr_retorno.qtd
 
 # Obter a quantidade de segurados atraves da gsakseg (Segurados)
 if lr_retorno.qtd  = 0 or
    lr_retorno.qtd  is null then
      
      message " Aguarde, pesquisando Base de Segurados..." attribute (reverse)
      
      call cty15g00_conta_cliente_gsakseg(lr_param.segnom)
      returning lr_retorno.sqlcode   ,
                lr_retorno.qtd
 end if
 
 # Obter a quantidade de segurados da Azul Seguros
 if lr_retorno.qtd  = 0 or
    lr_retorno.qtd  is null then
      
      message " Aguarde, pesquisando Base de Segurados da Azul..." attribute (reverse)
      
      call cty15g00_conta_cliente_azul(lr_param.segnom)
      returning lr_retorno.sqlcode   ,
                lr_retorno.qtd
 end if
 
 # Obter a quantidade de segurados da Itau Seguros                                      
 if lr_retorno.qtd  = 0 or                                                              
    lr_retorno.qtd  is null then                                                        
                                                                                        
      message " Aguarde, pesquisando Base de Segurados da Itau..." attribute (reverse)  
                                                                                    
      call cty15g00_conta_cliente_itau(lr_param.segnom)                                 
      returning lr_retorno.qtd                                                          
 end if                                                                                 
 
  # Obter a quantidade de Clientes do Saude
 if lr_retorno.qtd = 0 or
    lr_retorno.qtd  is null then
 
      message " Aguarde, pesquisando Base do Saude..." attribute (reverse)
 
      call cty15g00_conta_cliente_saude(lr_param.segnom)
      returning lr_retorno.sqlcode   ,
                lr_retorno.qtd
 end if
 
  # Obter a quantidade de Clientes do Cartao Visa
  if lr_retorno.qtd = 0 or
     lr_retorno.qtd  is null then
      
       message " Aguarde, pesquisando Base do Cartao Visa..." attribute (reverse)
      
       call cty15g00_conta_cliente_cartao(lr_param.segnom)
       returning lr_retorno.sqlcode   ,
                 lr_retorno.qtd
  end if
  
  return lr_retorno.sqlcode   ,
         lr_retorno.qtd

end function

#----------------------------------------------#
function cty15g00_conta_cliente_gsakseg(lr_param)
#----------------------------------------------#
define lr_param record
     segnom  char (60)
end record

define l_qtd integer

let l_qtd = null

    let lr_param.segnom = lr_param.segnom clipped , "*"

     whenever error continue

     select count(*)
       into l_qtd
       from gsakseg
       where segnom matches lr_param.segnom
     
     whenever error stop
     
     if sqlca.sqlcode < 0 then
     
        let l_qtd = null
     
        return sqlca.sqlcode
              ,l_qtd
     end if
   
   return sqlca.sqlcode
         ,l_qtd

end function

#--------------------------------------------#
function cty15g00_conta_cliente_azul(lr_param)
#--------------------------------------------#
define lr_param record
     segnom  char (60)
end record

define l_qtd integer

let l_qtd = null

    let lr_param.segnom = lr_param.segnom clipped , "*"

     whenever error continue
     
     select count(*)
     into l_qtd
     from datkazlapl
     where segnom matches lr_param.segnom
     
     whenever error stop

     if sqlca.sqlcode < 0 then
        let l_qtd = null
        return sqlca.sqlcode
              ,l_qtd
     end if

   return sqlca.sqlcode
         ,l_qtd

end function

#--------------------------------------------#                               
function cty15g00_conta_cliente_itau(lr_param)                               
#--------------------------------------------#                               
define lr_param record                                                       
     segnom  char (60)                                                       
end record                                                                   
                                                                             
define l_qtd integer                                                         
                                                                             
let l_qtd = null                                                             
                                                                              
   let l_qtd = cty22g00_qtd_nome(lr_param.segnom)
                                                                              
   return  l_qtd                                                              
                                                                             
end function                                                                 

#--------------------------------------------#
function cty15g00_conta_cliente_saude(lr_param)
#--------------------------------------------#

define lr_param record
     segnom  char (60)
end record

define l_qtd integer

let l_qtd = null
 
    let lr_param.segnom = lr_param.segnom clipped , "*"
   
     whenever error continue
   
     select count(*)
       into l_qtd
       from datksegsau
       where segnom matches lr_param.segnom
     
     whenever error stop
     
     if sqlca.sqlcode < 0 then
        let l_qtd = null
       
        return sqlca.sqlcode
              ,l_qtd
     end if
  
   return sqlca.sqlcode
         ,l_qtd

end function

#----------------------------------------------#
function cty15g00_conta_cliente_cartao(lr_param)
#----------------------------------------------#

define lr_param record
     segnom  char (60)
end record

define l_qtd integer

let l_qtd = null
   
    let lr_param.segnom = lr_param.segnom clipped , "*"
   
     whenever error continue
   
     select count(*)
     into l_qtd
     from fsckprpcrd a, fscmcntprs b
     where a.cgccpfnumdig = b.cgccpfnumdig
     and a.crdprpnom matches lr_param.segnom
     and b.ttlstt[1,1]  = 'A'
    
     whenever error stop
     if sqlca.sqlcode < 0 then
        
        let l_qtd = null
        return sqlca.sqlcode
              ,l_qtd
     end if
   
   return sqlca.sqlcode
         ,l_qtd

end function


#-----------------------------------------------#
function cty15g00_busca_cliente_cgccpf(lr_param)
#-----------------------------------------------#

define lr_param record
   cgccpfnum   like gsakpes.cgccpfnum,
   cgcord      like gsakpes.cgcord   ,
   cgccpfdig   like gsakpes.cgccpfdig,
   pestip      like gsakpes.pestip
end record

define lr_retorno record
   sqlcode integer,
   qtd integer
end record

initialize lr_retorno.* to null

    # Recupera pela gsakpes
    call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                        lr_param.cgcord    ,
                                        lr_param.cgccpfdig ,
                                        lr_param.pestip    )
    returning lr_retorno.sqlcode, lr_retorno.qtd
   
     # Recupera pela gsakseg
     if lr_retorno.qtd is null or
        lr_retorno.qtd = 0     then
        call cty15g00_busca_cliente_cgccpf_gsakseg (lr_param.cgccpfnum ,
                                                    lr_param.cgcord    ,
                                                    lr_param.cgccpfdig ,
                                                    lr_param.pestip    )
        returning lr_retorno.sqlcode, lr_retorno.qtd
     end if
   
    # Recupera pela Azul
    if lr_retorno.qtd is null or
       lr_retorno.qtd = 0     then
       call cty15g00_busca_cliente_cgccpf_azul (lr_param.cgccpfnum ,
                                                lr_param.cgcord    ,
                                                lr_param.cgccpfdig ,
                                                lr_param.pestip    )
       returning lr_retorno.sqlcode, lr_retorno.qtd
    end if
    
    # Recupera pela Itau                                              
    if lr_retorno.qtd is null or                                      
       lr_retorno.qtd = 0     then                                    
       call cty15g00_busca_cliente_cgccpf_itau (lr_param.cgccpfnum ,  
                                                lr_param.cgcord    ,  
                                                lr_param.cgccpfdig ,  
                                                lr_param.pestip    )  
       returning lr_retorno.sqlcode, lr_retorno.qtd                   
    end if                                                            
      
    # Recupera pela Itau re
    if lr_retorno.qtd is null or                                        
       lr_retorno.qtd = 0     then                                      
       call cty15g00_busca_cliente_cgccpf_itau_re (lr_param.cgccpfnum ,    
                                                   lr_param.cgcord    ,    
                                                   lr_param.cgccpfdig ,    
                                                   lr_param.pestip    )    
       returning lr_retorno.sqlcode, lr_retorno.qtd                     
    end if                                                            
    
    # Recupera pelo Saude
    if lr_retorno.qtd is null or
       lr_retorno.qtd = 0     then
       call cty15g00_busca_cliente_cgccpf_saude (lr_param.cgccpfnum ,
                                                 lr_param.cgcord    ,
                                                 lr_param.cgccpfdig )
       returning lr_retorno.sqlcode, lr_retorno.qtd
    end if
    
    # Recupera pelo Cartao
    if lr_retorno.qtd is null or
       lr_retorno.qtd = 0     then
       call figrc072_setTratarIsolamento()
       call cty15g00_busca_cliente_cgccpf_cartao (lr_param.cgccpfnum ,
                                                  lr_param.cgcord    ,
                                                  lr_param.cgccpfdig )
       returning lr_retorno.sqlcode, lr_retorno.qtd
    end if
    
    # Recupera pela Vistoria
    if lr_retorno.qtd is null or
       lr_retorno.qtd = 0     then
       call cty15g00_busca_cliente_cgccpf_vistoria (lr_param.cgccpfnum ,
                                                    lr_param.cgcord    ,
                                                    lr_param.cgccpfdig )
       returning lr_retorno.sqlcode, lr_retorno.qtd
    end if
   
    # Recupera pela Cobertura
    if lr_retorno.qtd is null or
       lr_retorno.qtd = 0     then
       call cty15g00_busca_cliente_cgccpf_cobertura (lr_param.cgccpfnum ,
                                                    lr_param.cgcord    ,
                                                    lr_param.cgccpfdig )
       returning lr_retorno.sqlcode, lr_retorno.qtd
    end if
    
    # Recupera pela Proposta
    if lr_retorno.qtd is null or
       lr_retorno.qtd = 0     then
       call cty15g00_busca_cliente_cgccpf_proposta (lr_param.cgccpfnum ,
                                                    lr_param.cgcord    ,
                                                    lr_param.cgccpfdig )
       returning lr_retorno.sqlcode, lr_retorno.qtd
    end if
    
    return lr_retorno.sqlcode,
           lr_retorno.qtd

end function

#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_gsakseg(lr_param)
#------------------------------------------------------------------------------
define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig,
        pestip    like gsakpes.pestip
end record

define l_qtd smallint

let l_qtd = null

if m_prep_sql is null or
   m_prep_sql <> true then
   call cty15g00_prepare()
end if

    open ccty15g00004 using  lr_param.cgccpfnum
                            ,lr_param.cgcord
                            ,lr_param.cgccpfdig
                            ,lr_param.pestip
    whenever error continue
    fetch ccty15g00004 into  g_a_cliente[1].cgccpfnum
                            ,g_a_cliente[1].cgcord
                            ,g_a_cliente[1].cgccpfdig
                            ,g_a_cliente[1].pesnom
                            ,g_a_cliente[1].pesnum
                            ,g_a_cliente[1].pestip
    whenever error stop

    if sqlca.sqlcode = notfound  then
       let l_qtd = 0
    else
       let l_qtd = 1
    end if

    close ccty15g00004

return sqlca.sqlcode,
       l_qtd

end function

#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_azul(lr_param)
#------------------------------------------------------------------------------

define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig,
        pestip    like gsakpes.pestip
end record

define l_qtd smallint

let l_qtd = null

if m_prep_sql is null or
   m_prep_sql <> true then
   call cty15g00_prepare()
end if
    
    open ccty15g00005 using  lr_param.cgccpfnum
                            ,lr_param.cgcord
                            ,lr_param.cgccpfdig
                            ,lr_param.pestip
    whenever error continue
    fetch ccty15g00005 into  g_a_cliente[1].cgccpfnum
                            ,g_a_cliente[1].cgcord
                            ,g_a_cliente[1].cgccpfdig
                            ,g_a_cliente[1].pesnom
                            ,g_a_cliente[1].pestip
    whenever error stop
    
    if sqlca.sqlcode = notfound  then
       let l_qtd = 0
    else
       let l_qtd = 1
    end if
    
    close ccty15g00005

return sqlca.sqlcode,
       l_qtd
end function

#------------------------------------------------------------------------------               
function cty15g00_busca_cliente_cgccpf_itau(lr_param)                                         
#------------------------------------------------------------------------------               
                                                                                              
define lr_param record                                                                        
        cgccpfnum like gsakpes.cgccpfnum,                                                     
        cgcord    like gsakpes.cgcord   ,                                                     
        cgccpfdig like gsakpes.cgccpfdig,                                                     
        pestip    like gsakpes.pestip                                                         
end record                                                                                    
                                                                                              
define l_qtd smallint                                                                         
                                                                                              
let l_qtd = null                                                                              
                                                                                              
if m_prep_sql is null or                                                                      
   m_prep_sql <> true then                                                                    
   call cty15g00_prepare()                                                                    
end if                                                                                        
                                                                                              
    open ccty15g00009 using  lr_param.cgccpfnum                                               
                            ,lr_param.cgcord                                                  
                            ,lr_param.cgccpfdig                                               
                            ,lr_param.pestip                                                  
    whenever error continue                                                                   
    fetch ccty15g00009 into  g_a_cliente[1].cgccpfnum                                         
                            ,g_a_cliente[1].cgcord                                            
                            ,g_a_cliente[1].cgccpfdig                                         
                            ,g_a_cliente[1].pesnom                                            
                            ,g_a_cliente[1].pestip                                            
    whenever error stop                                                                       
                                                                                              
    if sqlca.sqlcode = notfound  then                                                         
       let l_qtd = 0                                                                          
    else                                                                                      
       let l_qtd = 1                                                                          
    end if                                                                                    
                                                                                              
    close ccty15g00009                                                                       
                                                                                              
return sqlca.sqlcode,                                                                         
       l_qtd                                                                                  

end function                                                                                  


#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_saude(lr_param)
#------------------------------------------------------------------------------

define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig
end record

define l_qtd smallint

let l_qtd = null

if m_prep_sql is null or
   m_prep_sql <> true then
   call cty15g00_prepare()
end if
    
    open ccty15g00006 using  lr_param.cgccpfnum
                            ,lr_param.cgcord
                            ,lr_param.cgccpfdig
    whenever error continue
    fetch ccty15g00006 into  g_a_cliente[1].cgccpfnum
                            ,g_a_cliente[1].cgcord
                            ,g_a_cliente[1].cgccpfdig
                            ,g_a_cliente[1].pesnom
    whenever error stop
    
    if sqlca.sqlcode = notfound  then
       let l_qtd = 0
    else
       let l_qtd = 1
    end if
    
    close ccty15g00006

return sqlca.sqlcode,
       l_qtd

end function

#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_cartao(lr_param)
#------------------------------------------------------------------------------
define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig
end record

define l_qtd smallint
define l_cgccpfnumdig char(18)

let l_qtd          = null
let l_cgccpfnumdig = null

call figrc072_initGlbIsolamento()

if m_prep2_sql is null or
   m_prep2_sql <> true then

   call cty15g00_prepare2()
   
   if figrc072_getErro() then
         return sqlca.sqlcode,
                l_qtd
   end if
end if

    let l_cgccpfnumdig = ffpfc073_formata_cgccpf(lr_param.cgccpfnum ,
                                                 lr_param.cgcord    ,
                                                 lr_param.cgccpfdig )
    
    open ccty15g00007 using  l_cgccpfnumdig
    whenever error continue
    fetch ccty15g00007 into g_a_cliente[1].pesnom,
                            g_a_cliente[1].pestip
    whenever error stop
    
    if sqlca.sqlcode = notfound  then
       let l_qtd = 0
    else
       let l_qtd = 1
       let g_a_cliente[1].cgccpfnum = lr_param.cgccpfnum
       let g_a_cliente[1].cgcord    = lr_param.cgcord
       let g_a_cliente[1].cgccpfdig = lr_param.cgccpfdig
    end if
    
    close ccty15g00007

return sqlca.sqlcode,
       l_qtd

end function

#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_vistoria(lr_param)
#------------------------------------------------------------------------------
define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig
end record

define l_qtd smallint

let l_qtd = null

    call fvpic012_busca_cliente_vistoria(lr_param.cgccpfnum
                                        ,lr_param.cgcord
                                        ,lr_param.cgccpfdig)
    returning  g_a_cliente[1].cgccpfnum
              ,g_a_cliente[1].cgcord
              ,g_a_cliente[1].cgccpfdig
              ,g_a_cliente[1].pesnom
              ,g_a_cliente[1].pestip
              ,l_qtd

    if l_qtd = 0 then
       let sqlca.sqlcode = null
    end if

return sqlca.sqlcode,
       l_qtd

end function

#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_cobertura(lr_param)
#------------------------------------------------------------------------------
define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig
end record

define l_qtd smallint

let l_qtd = null

    call fvpic012_busca_cliente_cobertura(lr_param.cgccpfnum
                                         ,lr_param.cgcord
                                         ,lr_param.cgccpfdig)
    returning  g_a_cliente[1].cgccpfnum
              ,g_a_cliente[1].cgcord
              ,g_a_cliente[1].cgccpfdig
              ,g_a_cliente[1].pesnom
              ,g_a_cliente[1].pestip
              ,l_qtd

    if l_qtd = 0 then
       let sqlca.sqlcode = null
    end if

return sqlca.sqlcode,
       l_qtd

end function

#------------------------------------------------------------------------------
function cty15g00_busca_cliente_cgccpf_proposta(lr_param)
#------------------------------------------------------------------------------

define lr_param record
        cgccpfnum like gsakpes.cgccpfnum,
        cgcord    like gsakpes.cgcord   ,
        cgccpfdig like gsakpes.cgccpfdig
end record

define l_qtd smallint
let l_qtd = null

    call figrc072_setTratarIsolamento()

    call fpacc280_busca_cliente_proposta(lr_param.cgccpfnum
                                        ,lr_param.cgcord
                                        ,lr_param.cgccpfdig)
    returning  g_a_cliente[1].cgccpfnum
              ,g_a_cliente[1].cgcord
              ,g_a_cliente[1].cgccpfdig
              ,g_a_cliente[1].pesnom
              ,g_a_cliente[1].pestip
              ,l_qtd
     
     if g_isoAuto.sqlCodErr <> 0 then
          error "Problemas na função fpacc280_busca_cliente_cgccpf_proposta ! Avise a Informatica !" sleep 2
          return g_isoAuto.sqlCodErr,l_qtd
     end if
   
     if l_qtd = 0 then
       let sqlca.sqlcode = null
     end if

return sqlca.sqlcode,
       l_qtd

end function
#------------------------------------------------------------------------------
function cty15g00_qtd_segurado(lr_param)
#------------------------------------------------------------------------------

define lr_param record
   pesnom    like gsakpes.pesnom    ,
   cgccpfnum like gsakpes.cgccpfnum ,
   cgcord    like gsakpes.cgcord    ,
   cgccpfdig like gsakpes.cgccpfdig ,
   pestip    like gsakpes.pestip
end record

define lr_retorno record
       sqlcode integer ,
       qtd integer
end record

initialize lr_retorno.* to null

if m_prep_sql is null or
   m_prep_sql <> true then
   call cty15g00_prepare()
end if

  if lr_param.pesnom is not null then
        
        message " Aguarde, pesquisando Base de Clientes Unificados..." attribute (reverse)
       
        #-- Obter quantidade de segurados com o mesmo nome --#
        call osgtf550_conta_cliente_por_fonetica(lr_param.pesnom,lr_param.pestip)
        returning lr_retorno.sqlcode   ,
                  lr_retorno.qtd
        
        # Obter a quantidade de segurados atraves da gsakseg (Segurados)
        if lr_retorno.qtd  = 0     or
           lr_retorno.qtd  > 150   or
           lr_retorno.qtd  is null then
          
             message " Aguarde, pesquisando Base de Segurados..." attribute (reverse)
           
             call cty15g00_conta_cliente_gsakseg(lr_param.pesnom)
             returning lr_retorno.sqlcode   ,
                       lr_retorno.qtd
        end if
  else
       
        message " Aguarde, pesquisando..." attribute (reverse)
        
        # Recupero pela gsakpes
        if lr_param.cgcord is null then
           let  lr_param.cgcord = 0
        end if
        
        call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                            lr_param.cgcord    ,
                                            lr_param.cgccpfdig ,
                                            lr_param.pestip    )
        returning lr_retorno.sqlcode, lr_retorno.qtd
        
        # Recupero pela gsakseg
        if lr_retorno.qtd = 0 then
            
            open c_cty15g00_001 using lr_param.cgccpfnum,
                                    lr_param.pestip
            
            whenever error continue
            fetch c_cty15g00_001 into lr_retorno.qtd
            whenever error stop
            
            if sqlca.sqlcode <> 0 then
               let lr_retorno.qtd = 0
            end if
            
            close c_cty15g00_001
        
        end if
  end if
 
  return lr_retorno.sqlcode   ,
         lr_retorno.qtd

end function

#------------------------------------------------------------------------------
function cty15g00_pesquisa_auto_re(lr_param)
#------------------------------------------------------------------------------

define lr_param      record
   ramcod       like rsamseguro.ramcod,
   segnom       like gsakseg.segnom   ,
   cgccpfnum    like gsakseg.cgccpfnum,
   cgcord       like gsakseg.cgcord   ,
   cgccpfdig    like gsakseg.cgccpfdig,
   pestip       like gsakseg.pestip
end record

define ws         record
   segnumdig      like gsakseg.segnumdig,
   segnom         char (60)             ,
   comando        char (300)            ,
   emsdat         like abamdoc.emsdat
end record

define m_dtresol86 date

define lr_aux record
   p_fon     char(20),
   s_fon     char(20),
   t_fon     char(20),
   qtd_reg   smallint,
   gsakseg   smallint,
   pesq_fon  smallint,
   sqlcode   smallint,
   aux_qtd   smallint,
   prod      smallint,
   auxramcod like rsamseguro.ramcod
end record

define l_index  smallint
define l_index2 smallint
initialize ws.*,
           lr_aux.* to null

let lr_aux.pesq_fon = true
let lr_aux.gsakseg  = false
let lr_aux.qtd_reg  = 0
let l_index         = 0
let l_index2        = 0
let lr_aux.aux_qtd  = 0
let lr_aux.auxramcod  = lr_param.ramcod
let int_flag     =  false
let g_index      =  0
let m_index_venc = 0

initialize g_dctoarray     ,
           m_dctoarray_venc   to null

   if lr_param.segnom is not null then
      
      call osgtf550_conta_cliente_por_fonetica(lr_param.segnom ,
                                               lr_param.pestip )
           returning lr_aux.sqlcode,lr_aux.qtd_reg
      
      if lr_aux.qtd_reg = 0 or
         lr_aux.qtd_reg is null then
         
         let lr_aux.pesq_fon = false
         let lr_aux.gsakseg  = true
         let ws.segnom  = lr_param.segnom clipped, "*"
         let ws.comando = " select segnumdig ",
                            " from gsakseg ",
                           " where segnom matches '", ws.segnom clipped, "'"
      else
          
          call osgtf550_busca_cliente_por_fonetica(lr_param.segnom ,
                                                   lr_param.pestip ,
                                                   "U")
                          returning  lr_aux.sqlcode, l_index
      end if
      
      if lr_aux.pesq_fon = true then
         
         if lr_aux.qtd_reg > 150 then
            let lr_aux.gsakseg  = true
            let ws.segnom  = lr_param.segnom clipped, "*"
            let ws.comando = " select segnumdig ",
                               " from gsakseg ",
                              " where segnom matches '", ws.segnom clipped, "'"
         end if
      
      end if
   else
      
      if lr_param.cgccpfnum  is not null   then
       
       if lr_param.cgcord is null then
          let  lr_param.cgcord = 0
       end if
         
         call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                             lr_param.cgcord    ,
                                             lr_param.cgccpfdig ,
                                             lr_param.pestip    )
         returning lr_aux.sqlcode,lr_aux.qtd_reg
         if lr_aux.qtd_reg = 0 then
            let lr_aux.gsakseg  = true
            let ws.comando = " select segnumdig ",
                               " from gsakseg ",
                              " where cgccpfnum = ? ",
                                " and pestip = ? "
         end if
      
      else
         error " Parametro invalido, AVISE INFORMATICA!"
         return
      end if
   end if

   #---------------------------------------------------------------
   # Pesquisa por nome parcial
   #---------------------------------------------------------------
   message " Aguarde, pesquisando..."  attribute(reverse)
   
   if lr_aux.gsakseg = false then
      
      if lr_param.segnom is not null then
         let lr_aux.qtd_reg = l_index
         let l_index   = null
      end if
      
      if lr_param.segnom is not null then
               
               for l_index  =  1  to  lr_aux.qtd_reg
                 
                 call osgtf550_lista_unfclisegcod_por_pesnum(ga_gsakpes[l_index].pesnum ,lr_aux.prod)
                 returning lr_aux.sqlcode,lr_aux.aux_qtd
                  
                     for l_index2  =  1  to  lr_aux.aux_qtd
                       
                       if g_a_gsakdocngcseg[l_index2].unfclisegcod <> 0 then
                              call cty15g00_por_codigo(lr_param.ramcod, g_a_gsakdocngcseg[l_index2].unfclisegcod )
                       end if
                       
                       if int_flag or
                          g_index >= 150 then
                          exit for
                       end if
                     
                     end for
                    
                     if lr_param.ramcod <> 531 and
                        lr_param.ramcod <> 31  and
                        g_index         <  150 then
                           call cty15g00_completa_vencido()
                     end if
               end for
       end if
   
       if lr_param.cgccpfnum is not null then
              
                for l_index  =  1  to  lr_aux.qtd_reg
               
                  call osgtf550_lista_unfclisegcod_por_pesnum(g_a_cliente[l_index].pesnum ,lr_aux.prod)
                  returning lr_aux.sqlcode,lr_aux.aux_qtd
                 
                      for l_index2  =  1  to  lr_aux.aux_qtd
                       
                         # Função para Verificacao dos produtos na Gsakseg
                         if not cty15g00_verifica_produto(g_a_gsakdocngcseg[l_index2].unfprdcod) then
                            continue for
                         end if
                      
                        if g_a_gsakdocngcseg[l_index2].unfclisegcod <> 0 then
                              call cty15g00_por_codigo(lr_param.ramcod, g_a_gsakdocngcseg[l_index2].unfclisegcod )
                        end if
                     
                        if int_flag or
                           g_index >= 150 then
                           exit for
                        end if
                      
                      end for
                     
                      if lr_param.ramcod <> 531 and
                         lr_param.ramcod <> 31  and
                         g_index         <  150 then
                            call cty15g00_completa_vencido()
                      end if
                end for
        end if
   else
      
      prepare sel_gsakseg      from ws.comando
      declare c_gsakseg  cursor for sel_gsakseg
      
      if lr_param.segnom  is not null   then
         open c_gsakseg
      else
         open c_gsakseg  using  lr_param.cgccpfnum, lr_param.pestip
      end if
      
      foreach c_gsakseg into ws.segnumdig
        
         call cty15g00_por_codigo(lr_param.ramcod, ws.segnumdig)
        
         if int_flag or
            g_index >= 150 then
            exit foreach
         end if
      
      end foreach
      close c_gsakseg
   end if
   
   message " "
   
    #if g_index <> 0 then
      
       # Apolice de Auto
      
       if lr_param.ramcod  = 31  or
          lr_param.ramcod  = 531 then
        
#---------------------------Anderson---------------------------
          let g_a_cliente[1].cgccpfnum = lr_param.cgccpfnum
          let g_a_cliente[1].cgcord    = lr_param.cgcord
          let g_a_cliente[1].cgccpfdig = lr_param.cgccpfdig
          let g_a_cliente[1].pestip    = lr_param.pestip 
#---------------------------------------------------------------
       
          call cta00m11()
        
          if g_documento.aplnumdig is not null and
             g_documento.succod    is not null then
          
             select grlinf[01,10] into m_dtresol86
             from  datkgeral
             where grlchv='ct24resolucao86'
             select emsdat into ws.emsdat
             from  abamdoc
             where succod    = g_documento.succod
             and   aplnumdig = g_documento.aplnumdig
             and   edsnumdig = 0
            
             if ws.emsdat >= m_dtresol86 then
                let g_documento.ramcod = 531
             else
                let g_documento.ramcod = 31
             end if
          
          end if
       else
          if g_index <> 0 then
             # Apolice de RE
             if lr_param.ramcod  is not null   then
   	            let g_documento.ramcod = lr_aux.auxramcod
                call cta00m14()
             end if
          end if
       end if
    #end if
 
    return g_documento.ramcod   ,
           g_documento.succod   ,
           g_documento.aplnumdig,
           g_documento.itmnumdig

end function

#----------------------------------------------------
 function cty15g00_por_codigo(lr_param)
#----------------------------------------------------
 
 define lr_param   record
    ramcod         like rsamseguro.ramcod,
    segnumdig      like gsakseg.segnumdig
 end record
 
 define d_cty15g00_re    record
   succod          like rsamseguro.succod   ,
   aplnumdig       like rsamseguro.aplnumdig,
   ramcod          like rsamseguro.ramcod   ,
   prporg          like rsdmdocto.prporg    ,
   prpnumdig       like rsdmdocto.prpnumdig ,
   dctnumseq       like rsdmdocto.dctnumseq ,
   vigfnl          like rsdmdocto.vigfnl
 end record
 
 define d_cty15g00_auto  record
    succod         like abbmitem.succod,
    aplnumdig      like abbmitem.aplnumdig,
    itmnumdig      like abbmitem.itmnumdig,
    dctnumseq      like abbmdoc.dctnumseq
 end record
 
 define ws         record
    sql            char (500),
    sgrorg         like rsdmdocto.sgrorg,
    sgrnumdig      like rsdmdocto.sgrnumdig,
    succodant      like rsamseguro.succod,
    aplnumant      like rsamseguro.aplnumdig,
    sgrnumant      like rsdmdocto.sgrnumdig,
    itmqtd         smallint
 end record
 
 initialize d_cty15g00_auto.*  to null
 initialize d_cty15g00_re.*    to null
 initialize ws.*               to null
 
 if lr_param.ramcod = 31 or
    lr_param.ramcod = 531 then
    
    let ws.sql = "select count(distinct itmnumdig)",
                 "  from abbmdoc           ",
                 " where succod    = ?  and",
                 "       aplnumdig = ?  and",
                 "       segnumdig = ?     "
    prepare sel_abbmdoc from ws.sql
    declare c_abbmdoc cursor for sel_abbmdoc
    
    let ws.sql = "select count(*)          ",
                 "  from abbmitem          ",
                 " where succod    = ?  and",
                 "       aplnumdig = ?     "
    prepare sel_abbmitem from ws.sql
    declare c_abbmitem cursor for sel_abbmitem
    
    let ws.sql = "select unique itmnumdig          ",
                 "  from abbmdoc, agdktip          ",
                 " where abbmdoc.succod    = ?  and",
                 "       abbmdoc.aplnumdig = ?  and",
                 "       abbmdoc.segnumdig = ?  and",
                 "       abbmdoc.edstip    = agdktip.edstip  and",
                 "       agdktip.edsoprcod = 1     ",
                 " group by itmnumdig              "
    prepare sel_itmnumdig from ws.sql
    declare c_itmnumdig cursor for sel_itmnumdig
    
    let ws.sql = "select max(dctnumseq)    ",
                 "  from abbmdoc           ",
                 " where succod    = ?  and",
                 "       aplnumdig = ?  and",
                 "       segnumdig = ?     "
    prepare sel_dctnumseq from ws.sql
    declare c_dctnumseq cursor for sel_dctnumseq
   
    declare c_automovel cursor for
       select unique succod,
              aplnumdig
         from abbmdoc
        where abbmdoc.segnumdig  = lr_param.segnumdig     and
              abbmdoc.vigfnl    >= today - 60
    union
       select succod,
              aplnumdig
         from abamapol
        where abamapol.etpnumdig = lr_param.segnumdig     and
              abamapol.vigfnl   >= today - 60
    
    foreach c_automovel into d_cty15g00_auto.succod,
                             d_cty15g00_auto.aplnumdig
       let g_index = g_index + 1
       if g_index > 150  then
          let g_index = 150
          error " Limite excedido. Foram encontrados mais de 150 documentos!"
          exit foreach
       end if
      
       let ws.itmqtd = 0
       open  c_abbmdoc using d_cty15g00_auto.succod,
                             d_cty15g00_auto.aplnumdig,
                             lr_param.segnumdig
       fetch c_abbmdoc into  ws.itmqtd
       close c_abbmdoc
      
       if ws.itmqtd = 0  then
          open  c_abbmitem using d_cty15g00_auto.succod,
                                 d_cty15g00_auto.aplnumdig
          fetch c_abbmitem into  ws.itmqtd
          close c_abbmitem
         
          let g_dctoarray[g_index].succod    = d_cty15g00_auto.succod
          let g_dctoarray[g_index].aplnumdig = d_cty15g00_auto.aplnumdig
          let g_dctoarray[g_index].itmnumdig = 0
          let g_dctoarray[g_index].dctnumseq = 1
          let g_dctoarray[g_index].aplqtditm = ws.itmqtd
       else
          
          if ws.itmqtd = 1  then
             let ws.itmqtd = 0
             open  c_itmnumdig  using  d_cty15g00_auto.succod,
                                       d_cty15g00_auto.aplnumdig,
                                       lr_param.segnumdig
             fetch c_itmnumdig  into   d_cty15g00_auto.itmnumdig
             close c_itmnumdig
             
             call f_funapol_ultima_situacao (d_cty15g00_auto.succod,
                                             d_cty15g00_auto.aplnumdig,
                                             d_cty15g00_auto.itmnumdig)
                                   returning g_funapol.*
             let g_dctoarray[g_index].succod    = d_cty15g00_auto.succod
             let g_dctoarray[g_index].aplnumdig = d_cty15g00_auto.aplnumdig
             let g_dctoarray[g_index].itmnumdig = d_cty15g00_auto.itmnumdig
             let g_dctoarray[g_index].dctnumseq = g_funapol.dctnumseq
             let g_dctoarray[g_index].aplqtditm = 0
          else
             
             open  c_dctnumseq using d_cty15g00_auto.succod,
                                     d_cty15g00_auto.aplnumdig,
                                     lr_param.segnumdig
             fetch c_dctnumseq into  d_cty15g00_auto.dctnumseq
             close c_dctnumseq
             
             let g_dctoarray[g_index].succod    = d_cty15g00_auto.succod
             let g_dctoarray[g_index].aplnumdig = d_cty15g00_auto.aplnumdig
             let g_dctoarray[g_index].itmnumdig = d_cty15g00_auto.itmnumdig
             let g_dctoarray[g_index].itmnumdig = 0
             let g_dctoarray[g_index].dctnumseq = d_cty15g00_auto.dctnumseq
             let g_dctoarray[g_index].aplqtditm = ws.itmqtd
          end if
       end if
       
       if int_flag  then
          error " Operacao cancelada!"
          exit foreach
       end if
    end foreach
 else
   
    if lr_param.ramcod is not null  then
      
       declare c_ramos cursor for
          select rsdmdocto.prporg    ,
                 rsdmdocto.prpnumdig ,
                 rsdmdocto.sgrorg    ,
                 rsdmdocto.sgrnumdig ,
                 rsdmdocto.dctnumseq ,
                 rsdmdocto.vigfnl    ,
                 rsamseguro.succod   ,
                 rsamseguro.aplnumdig,
                 rsamseguro.ramcod
            from rsdmdocto, rsamseguro
           where rsdmdocto.segnumdig   = lr_param.segnumdig         and
                 rsdmdocto.edsstt     <> "C"                     and
                 rsamseguro.sgrorg     = rsdmdocto.sgrorg        and
                 rsamseguro.sgrnumdig  = rsdmdocto.sgrnumdig     and
                 rsamseguro.aplnumdig <> 0
           order by succod, aplnumdig, sgrnumdig
       
       foreach c_ramos into   d_cty15g00_re.prporg   ,
                              d_cty15g00_re.prpnumdig,
                              ws.sgrorg              ,
                              ws.sgrnumdig           ,
                              d_cty15g00_re.dctnumseq,
                              d_cty15g00_re.vigfnl   ,
                              d_cty15g00_re.succod   ,
                              d_cty15g00_re.aplnumdig,
                              d_cty15g00_re.ramcod
       
        if d_cty15g00_re.succod     =  ws.succodant   and
           d_cty15g00_re.aplnumdig  =  ws.aplnumant   and
           ws.sgrnumdig             =  ws.sgrnumant   then
           continue foreach
        end if
        
        if d_cty15g00_re.vigfnl < today then
               let m_index_venc = m_index_venc + 1
               let ws.sgrnumant = ws.sgrnumdig
               let ws.succodant = d_cty15g00_re.succod
               let ws.aplnumant = d_cty15g00_re.aplnumdig
               let m_dctoarray_venc[m_index_venc].succod    = d_cty15g00_re.succod
               let m_dctoarray_venc[m_index_venc].aplnumdig = d_cty15g00_re.aplnumdig
               let m_dctoarray_venc[m_index_venc].ramcod    = d_cty15g00_re.ramcod
               let m_dctoarray_venc[m_index_venc].prporg    = d_cty15g00_re.prporg
               let m_dctoarray_venc[m_index_venc].prpnumdig = d_cty15g00_re.prpnumdig
               let m_dctoarray_venc[m_index_venc].segnumdig = lr_param.segnumdig
        else
              let g_index = g_index + 1
             
              if g_index > 150 then
                 let g_index = 150
                 error " Limite excedido. Foram encontrados mais de 150 documentos!" sleep 2
                 exit foreach
              end if
             
              let ws.sgrnumant = ws.sgrnumdig
              let ws.succodant = d_cty15g00_re.succod
              let ws.aplnumant = d_cty15g00_re.aplnumdig
              let g_dctoarray[g_index].succod    = d_cty15g00_re.succod
              let g_dctoarray[g_index].aplnumdig = d_cty15g00_re.aplnumdig
              let g_dctoarray[g_index].ramcod    = d_cty15g00_re.ramcod
              let g_dctoarray[g_index].prporg    = d_cty15g00_re.prporg
              let g_dctoarray[g_index].prpnumdig = d_cty15g00_re.prpnumdig
              let g_dctoarray[g_index].segnumdig = lr_param.segnumdig
        end if
        
        if int_flag  then
           error " Operacao cancelada!"
           exit foreach
        end if
       
       end foreach
    end if
 end if

end function

#-----------------------------------------#
function cty15g00_obter_codgeral(lr_param)
#-----------------------------------------#

define lr_param record
       segnumdig  like gsakseg.segnumdig
      ,cgccpfnum  like gsakseg.cgccpfnum
      ,cgcord     like gsakseg.cgcord
      ,cgccpfdig  like gsakseg.cgccpfdig
end record

define lr_retorno record
       resultado  smallint
      ,mensagem   char(60)
      ,codgeral   like gsakseg.segnumdig
      ,segnom     like gsakseg.segnom
end record

define l_pestip like gsakseg.pestip,
       l_aux_qtd smallint          ,
       l_qtd_reg smallint          ,
       l_sqlcode smallint          ,
       l_index   smallint

initialize lr_retorno.* to null

let lr_retorno.resultado = 1
let l_pestip  = null
let l_aux_qtd = null
let l_qtd_reg = null
let l_sqlcode = null
let l_index   = null
  
   if lr_param.segnumdig is not null then
      
      call osgtf550_lista_unfclisegcod_por_pesnum(lr_param.segnumdig,1)
      returning l_sqlcode,l_aux_qtd
     
      if l_sqlcode <> 0 or
         l_aux_qtd = 0 then
          
           let lr_retorno.resultado = 2
           let lr_retorno.mensagem  = "Codigo geral do segurado nao encontrado"
      else
           let lr_retorno.codgeral = g_a_gsakdocngcseg[1].unfclisegcod
      end if
   else
    
     if lr_param.cgcord = 0 then
        let l_pestip = "F"
     else
        let l_pestip = "J"
     end if
     
     call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                         lr_param.cgcord    ,
                                         lr_param.cgccpfdig ,
                                         l_pestip    )
     returning l_sqlcode,l_aux_qtd
     
     if l_sqlcode <> 0 or
        l_aux_qtd = 0 then
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem  = "Dados do segurado nao encontrado"
     else
          for l_index  =  1  to  l_aux_qtd
             
             call osgtf550_lista_unfclisegcod_por_pesnum(ga_gsakpes[l_index].pesnum ,1)
             returning l_sqlcode,l_qtd_reg
              
               if l_sqlcode <> 0 or
                  l_aux_qtd = 0 then
                     let lr_retorno.resultado = 2
                     let lr_retorno.mensagem  = "Codigo Geral do segurado nao encontrado"
                     exit for
               else
                   let lr_retorno.codgeral = g_a_gsakdocngcseg[1].unfclisegcod
                   let lr_retorno.segnom   = g_a_cliente[l_index].pesnom
               end if
          
          end for
     end if
   end if
   
   return lr_retorno.*

end function

#-----------------------------------------#
function cty15g00_completa_vencido()
#-----------------------------------------#

define l_index integer

let l_index = 0

       for l_index  =  1  to  m_index_venc
         
         let g_index = g_index + 1
         
         if g_index > 150 then
            let g_index = 150
            error " Limite excedido. Foram encontrados mais de 150 documentos!" sleep 2
            exit for
         end if
        
        let g_dctoarray[g_index].succod    = m_dctoarray_venc[l_index].succod
         let g_dctoarray[g_index].aplnumdig = m_dctoarray_venc[l_index].aplnumdig
         let g_dctoarray[g_index].ramcod    = m_dctoarray_venc[l_index].ramcod
         let g_dctoarray[g_index].prporg    = m_dctoarray_venc[l_index].prporg
         let g_dctoarray[g_index].prpnumdig = m_dctoarray_venc[l_index].prpnumdig
         let g_dctoarray[g_index].segnumdig = m_dctoarray_venc[l_index].segnumdig
       end for
end function

#---------------------------------------------
function cty15g00_verifica_produto(lr_param)
#---------------------------------------------

  define lr_param record
         unfprdcod like gsakdocngcseg.unfprdcod
  end record
  define l_retorno smallint

  let l_retorno = true

  if lr_param.unfprdcod <> 1  and  # Auto
     lr_param.unfprdcod <> 2  and  # RE
     lr_param.unfprdcod <> 3  and  # Vida Clube
     lr_param.unfprdcod <> 7  and  # Protecao patrimonial
     lr_param.unfprdcod <> 10 and  # Vida Grupo
     lr_param.unfprdcod <> 12 and  # Transportes
     lr_param.unfprdcod <> 13 and  # Fianca
     lr_param.unfprdcod <> 14 and  # Transportes Monitorados
     lr_param.unfprdcod <> 15 and  # DAF
     lr_param.unfprdcod <> 16 and  # Vida individual
     lr_param.unfprdcod <> 17 and  # Vida API
     lr_param.unfprdcod <> 18 then # GPS  
     let l_retorno = false
  end if
 
  return l_retorno

end function

#---------------------------------------------
function cty15g00_verifica_documento(lr_param)
#---------------------------------------------

   define lr_param record 
       succod        like abamapol.succod
      ,ramcod        like rsamseguro.ramcod
      ,aplnumdig     like abamapol.aplnumdig
      ,itmnumdig     like abbmdoc.itmnumdig
      ,cgccpfnum     like gsakseg.cgccpfnum    
      ,cgcord        like gsakseg.cgcord       
      ,cgccpfdig     like gsakseg.cgccpfdig     
   end record

   define lr_retorno record
       resultado smallint
      ,mensagem  char(70)
      ,qtd       integer
      ,unfprdcod like gsakdocngcseg.unfprdcod           
   end record

   define lr_ramo record
       ramnom    char(30)
      ,ramsgl    char(15)
   end record

   define lr_cgccpf record
       cgccpfnum  like gsakpes.cgccpfnum
      ,cgcord     like gsakpes.cgcord   
      ,cgccpfdig  like gsakpes.cgccpfdig
      ,pestip     like gsakpes.pestip   
      ,pesnom     like gsakpes.pesnom
   end record
   
   define l_retorno smallint
   define l_array   integer

   initialize lr_retorno.* to null
   initialize lr_ramo.* to null
   initialize lr_cgccpf.* to null

   let l_retorno = false
   
   # Se for Cartao
   
   if g_documento.ciaempcod = 40 then
   
      if lr_param.cgccpfnum is null or 
         lr_param.cgcord    is null or
         lr_param.cgccpfdig is null then
         
         return l_retorno         
      
      else     
         if lr_param.cgcord = 0 then
            let lr_cgccpf.pestip = "F"   
         else
            let lr_cgccpf.pestip = "J"   
         end if 
      
      end if
      
      let lr_cgccpf.cgccpfnum = lr_param.cgccpfnum
      let lr_cgccpf.cgcord    = lr_param.cgcord   
      let lr_cgccpf.cgccpfdig = lr_param.cgccpfdig
       
   else
    
        if lr_param.succod    is null or   
           lr_param.ramcod    is null or
           lr_param.aplnumdig is null then 
        
           return l_retorno
        
        end if 
           
        if lr_param.itmnumdig is null or
           lr_param.itmnumdig = 0     then
           
           # Produto RE 
           let lr_retorno.unfprdcod = 2
        else
           
           # Produto Auto  
           let lr_retorno.unfprdcod = 1     
        end if
        
        
        
        # Recupera a descricao do ramo
        call cty10g00_descricao_ramo(lr_param.ramcod,1)
        returning lr_retorno.resultado
                 ,lr_retorno.mensagem
                 ,lr_ramo.ramnom
                 ,lr_ramo.ramsgl
                 
        
        
        # Recupera o CPF/CNPJ do segurado
        call cta01m61_rec_cliente_apolice(lr_param.succod
                                         ,lr_param.ramcod
                                         ,lr_param.aplnumdig
                                         ,lr_param.itmnumdig
                                         ,lr_ramo.ramsgl    
                                         ,"")
        returning lr_retorno.resultado
                 ,lr_retorno.mensagem 
                 ,lr_cgccpf.cgccpfnum 
                 ,lr_cgccpf.cgcord    
                 ,lr_cgccpf.cgccpfdig 
                 ,lr_cgccpf.pesnom    
                 ,lr_cgccpf.pestip
        
        
                 
        if lr_cgccpf.cgccpfnum is null or
           lr_cgccpf.cgccpfnum = 0 then
           return l_retorno
        end if            
   
   end if 
   
   
   # Recupera os produtos do segurado
   call osgtf550_pesquisa_negocios_cpfcnpj(lr_cgccpf.cgccpfnum
                                          ,lr_cgccpf.cgcord
                                          ,lr_cgccpf.cgccpfdig
                                          ,lr_cgccpf.pestip) 
   returning lr_retorno.resultado
            ,lr_retorno.qtd

   
   if lr_retorno.qtd is not null and
      lr_retorno.qtd > 0 then
      
      for l_array = 1 to lr_retorno.qtd

         # Verifica se o documento esta vigente
         if g_a_gsakdocngcseg[l_array].viginc  <= today and
            g_a_gsakdocngcseg[l_array].vigfnl  >= today and
            g_a_gsakdocngcseg[l_array].docsitcod = 1 then
           
            
            if g_documento.ciaempcod = 40 then
               
               if g_a_gsakdocngcseg[l_array].unfprdcod = 1 or
                  g_a_gsakdocngcseg[l_array].unfprdcod = 2 then
                               
                   let l_retorno = true 
                    exit for            
               end if
            
            else
               
               if lr_retorno.unfprdcod = 1 and                    # Se seguro AUTO
                  g_a_gsakdocngcseg[l_array].unfprdcod = 2 then # e encontrou um outro RE
               
                  let l_retorno = true
                  exit for
               end if
               
               if lr_retorno.unfprdcod = 2 and                    # Se seguro RE
                  g_a_gsakdocngcseg[l_array].unfprdcod = 1 then # e encontrou um outro AUTO
                
                  let l_retorno = true
                  exit for
               end if 
            
            end if    
         
         end if

      end for
      
   end if
   

   # Se Entrou com Cartão desconsiderar rotina abaixo
   
   if g_documento.ciaempcod <> 40 then
   
       initialize lr_retorno.* to null
        
       # Verifica se o segurado possui o cartao
       
       call cty15g00_busca_cliente_cgccpf_cartao(lr_cgccpf.cgccpfnum
                                                ,lr_cgccpf.cgcord
                                                ,lr_cgccpf.cgccpfdig)
       returning lr_retorno.resultado
                ,lr_retorno.qtd
                
       if lr_retorno.qtd is not null and
          lr_retorno.qtd > 0 then
            let m_possui_cartao = true  
            let l_retorno = true
       end if
       
   end if
   
   return l_retorno

end function

#------------------------------------------------          
function cty15g00_verifica_assunto_doc(lr_param)          
#------------------------------------------------     

define lr_param record                     
    succod        like abamapol.succod     
   ,ramcod        like rsamseguro.ramcod   
   ,aplnumdig     like abamapol.aplnumdig  
   ,itmnumdig     like abbmdoc.itmnumdig 
   ,cgccpfnum     like gsakseg.cgccpfnum 
   ,cgcord        like gsakseg.cgcord    
   ,cgccpfdig     like gsakseg.cgccpfdig 
   ,c24astcod     like datmligacao.c24astcod  
end record                                 

define lr_retorno record                       
   c24astcod like datkassunto.c24astcod    ,    
   cponom    like datkdominio.cponom       ,    
   permissao smallint                      ,
   confirma  char(1)                       ,
   ok        smallint                                                           
end record


initialize lr_retorno.* to null

let lr_retorno.cponom    = "assunto_documento"         
let lr_retorno.permissao = false  
let lr_retorno.ok        = true  
let m_possui_cartao      = false                     
                                                       
    if m_prep_sql is null or                            
       m_prep_sql <> true then                          
       call cty15g00_prepare()                         
    end if                                             

    # Verifica se o Assunto tem Permissão para o Cruzamento de Documentos 
    open ccty15g00008 using lr_retorno.cponom             
    foreach ccty15g00008 into lr_retorno.c24astcod        
                                                             
       if lr_param.c24astcod = lr_retorno.c24astcod then  
          let lr_retorno.permissao = true                    
          exit foreach                                       
       end if                                                
                                                                                              
    end foreach                                              
    
    if lr_retorno.permissao then 
    
        if cty15g00_verifica_documento(lr_param.succod          
                                      ,lr_param.ramcod          
                                      ,lr_param.aplnumdig       
                                      ,lr_param.itmnumdig
                                      ,lr_param.cgccpfnum
                                      ,lr_param.cgcord   
                                      ,lr_param.cgccpfdig) then 
    
           let lr_retorno.confirma = cts08g01('C','S',
                                              'ESTE CLIENTE TEM OUTROS',
                                              'SEGUROS ATIVOS.' ,
                                              'JA FOI VERIFICADO',
                                              'SE HA COBERTURA?')     
           
           if lr_retorno.confirma = "N" then
              
              call cts08g01("A", "N",                              
                            " ",                                   
                            "CLIENTE COM OUTROS SEGUROS ATIVOS.",  
                            "CONSULTE (F1) - CLIENTES!",           
                            " ")                                   
              returning lr_retorno.confirma   
              
              let lr_retorno.ok = false
                                           
           end if
        
        end if
    
    end if
    
    
    if g_documento.ciaempcod <> 40 then                                                        
                                                                                               
        # Verifica se o segurado possui o cartao                                               
                                                                                               
        if m_possui_cartao then                                                                
                                                                                               
           let lr_retorno.confirma = cts08g01('C','S',                                         
                                              'INDICAR PARA O SEGURADO A POSSIBILIDADE',          
                                              'DA CONTRATACAO DO SERVICO PELA CENTRAL ',      
                                              'PORTO FAZ - 3003 7378 OU TRANSFIRA PARA',           
                                              'O RAMAL 20021')                           
                                                                                               
           if lr_retorno.confirma = "N" then                                                   
              let lr_retorno.ok = false                                                        
           else                                                                                
              let lr_retorno.ok = true                                                         
           end if                                                                              
        end if                                                                                 
                                                                                               
    end if                                                                                     
    
    return lr_retorno.ok
    
end function     

#------------------------------------------------------------------------------               
function cty15g00_busca_cliente_cgccpf_itau_re(lr_param)                                         
#------------------------------------------------------------------------------               
                                                                                              
define lr_param record                                                                        
        cgccpfnum like gsakpes.cgccpfnum,                                                     
        cgcord    like gsakpes.cgcord   ,                                                     
        cgccpfdig like gsakpes.cgccpfdig,                                                     
        pestip    like gsakpes.pestip                                                         
end record                                                                                    
                                                                                              
define l_qtd smallint                                                                         
                                                                                              
let l_qtd = null                                                                              
                                                                                              
if m_prep_sql is null or                                                                      
   m_prep_sql <> true then                                                                    
   call cty15g00_prepare()                                                                    
end if                                                                                        
                                                                                              
    open ccty15g00010 using  lr_param.cgccpfnum                                               
                            ,lr_param.cgcord                                                  
                            ,lr_param.cgccpfdig                                               
                            ,lr_param.pestip                                                  
    whenever error continue                                                                   
    fetch ccty15g00010 into  g_a_cliente[1].cgccpfnum                                         
                            ,g_a_cliente[1].cgcord                                            
                            ,g_a_cliente[1].cgccpfdig                                         
                            ,g_a_cliente[1].pesnom                                            
                            ,g_a_cliente[1].pestip                                            
    whenever error stop                                                                       
                                                                                              
    if sqlca.sqlcode = notfound  then                                                         
       let l_qtd = 0                                                                          
    else                                                                                      
       let l_qtd = 1                                                                          
    end if                                                                                    
                                                                                              
    close ccty15g00010                                                                       
                                                                                              
return sqlca.sqlcode,                                                                         
       l_qtd                                                                                  

end function                                                                                  





