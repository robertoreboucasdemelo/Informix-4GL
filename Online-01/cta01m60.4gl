#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m60.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Recupera Clientes                                          #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 18/12/2007                                                #
#............................................................................#


globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"

define  m_prepare  smallint

define mr_array array[500] of record
       cgccpf    like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pesnom    like gsakpes.pesnom    ,
       pestip    like gsakpes.pestip
end record

define a_cta01m60 array[500] of record
       cgccpf  char(20)            ,
       segnom  like gsakseg.segnom
end record


#------------------------------------------------------------------------------
function cta01m60_sql_cliente()
#------------------------------------------------------------------------------
define l_sql  char(200)
    
    let l_sql = " select * from cta01m60_temp"  ,
                " order by pesnom "
    prepare pcta01m60001 from l_sql
    declare ccta01m60001 cursor for pcta01m60001
    
    return
end function

#------------------------------------------------------------------------------
function cta01m60_cria_temp()
#------------------------------------------------------------------------------
 call cta01m60_drop_temp()
 
 whenever error continue
      create temp table cta01m60_temp (pesnom    char(70)
                                      ,cgccpfnum decimal(12,0)
                                      ,cgcord    decimal(4,0)
                                      ,cgccpfdig decimal(2,0)
                                      ,pestip    char(1) ) with no log
 create unique index idx_tmpcta01m60 on cta01m60_temp (cgccpfnum)
  
  whenever error stop
    if sqlca.sqlcode <> 0  then
	    if sqlca.sqlcode = -310 or
	       sqlca.sqlcode = -958 then
	           call cta01m60_drop_temp()
	    end if
	    return false
    end if
     
    return true
end function

#------------------------------------------------------------------------------
function cta01m60_drop_temp()
#------------------------------------------------------------------------------
    whenever error continue
        drop table cta01m60_temp
    whenever error stop
    
    return
end function

#------------------------------------------------------------------------------
function cta01m60_prep_temp()
#------------------------------------------------------------------------------
    define w_ins char(1000)
    
    let w_ins = 'insert into cta01m60_temp'
	     , ' values(?,?,?,?,?)'
    prepare p_insert from w_ins

end function
#------------------------------------------------------------------------------
function cta01m60_formata_cgccpf(l_param)
#------------------------------------------------------------------------------

define l_param record
   cgccpfnum like gsakpes.cgccpfnum    ,
   cgcord    like gsakpes.cgcord       ,
   cgccpfdig like gsakpes.cgccpfdig
end record

define l_cgccpf char(12)
define l_format char(20)


    let l_cgccpf = l_param.cgccpfnum using '&&&&&&<<<<<<'
    let l_cgccpf = l_cgccpf[4,6],".",l_cgccpf[7,9],".",l_cgccpf[10,12]

    if l_param.cgcord is null or
       l_param.cgcord = 0     then
          let l_format =  l_cgccpf clipped ,"-", l_param.cgccpfdig using '&&'
    else
          let l_format =  l_cgccpf clipped ,"/", l_param.cgcord using '&&&&' ,"-", l_param.cgccpfdig using '&&'
    end if

    return l_format

end function

#------------------------------------------------------------------------------
function cta01m60_rec_cliente(lr_param)
#------------------------------------------------------------------------------
define lr_param record
       pesnom      like gsakpes.pesnom   ,
       pestip      like gsakpes.pestip   ,
       cgccpfnum   like gsakpes.cgccpfnum,
       cgcord      like gsakpes.cgcord   ,
       cgccpfdig   like gsakpes.cgccpfdig
end record

define lr_cta01m60 record
       pesnom      like gsakpes.pesnom     ,
       cgccpfnum   like gsakpes.cgccpfnum  ,
       cgcord      like gsakpes.cgcord     ,
       cgccpfdig   like gsakpes.cgccpfdig  ,
       pestip      like gsakpes.pestip
end record

define ws record
       sqlcode integer,
       qtd smallint
end record

define lr_retorno record
       erro      smallint              ,
       mens      char(50)              ,
       cgccpf    like gsakpes.cgccpfnum,
       cgcord    like gsakpes.cgcord   ,
       cgccpfdig like gsakpes.cgccpfdig,
       pesnom    like gsakpes.pesnom   ,
       pestip    like gsakpes.pestip
end record

define l_index integer


initialize lr_retorno.*  ,
           lr_cta01m60.* ,
           ws.* to null
let lr_retorno.erro = 0
for     l_index  =  1  to  500
        initialize  a_cta01m60[l_index].* to  null
        initialize  mr_array[l_index].*   to  null
end  for

let l_index = 0

  if lr_param.pesnom is not null then

    if not cta01m60_cria_temp() then
        let ws.sqlcode = 1
        error  "Erro na Criacao da Tabela Temporaria!"
    else
        let ws.sqlcode = 0
    end if
    if ws.sqlcode = 0 then
        
        # Recupera todos os Clientes e insere na Temporaria
        call cta01m60_carrega_cliente(lr_param.pesnom, lr_param.pestip)
        
        # Recupera a Quantidade de Clientes
        let ws.qtd = cta01m60_conta_cliente()
        
        if ws.qtd > 500 then
           error  " Mais de 500 registros selecionados,",
                  " complemente o nome do segurado! (",ws.qtd,")reg"
           let lr_retorno.erro = 2
           return  lr_retorno.cgccpf    ,
                   lr_retorno.cgcord    ,
                   lr_retorno.cgccpfdig ,
                   lr_retorno.pesnom    ,
                   lr_retorno.pestip    ,
                   lr_retorno.erro
        end if
        
        # Recupera os Dados dos Clientes
        call cta01m60_sql_cliente()
        
        if ws.qtd > 1 then
             
             open ccta01m60001
             foreach ccta01m60001 into lr_cta01m60.*
              
                let l_index = l_index + 1
                let mr_array[l_index].pesnom    = lr_cta01m60.pesnom
                let mr_array[l_index].cgccpf    = lr_cta01m60.cgccpfnum
                let mr_array[l_index].cgcord    = lr_cta01m60.cgcord
                let mr_array[l_index].cgccpfdig = lr_cta01m60.cgccpfdig
                let mr_array[l_index].pestip    = lr_cta01m60.pestip
                let a_cta01m60[l_index].segnom = lr_cta01m60.pesnom
                let a_cta01m60[l_index].cgccpf = cta01m60_formata_cgccpf(lr_cta01m60.cgccpfnum,
                                                                         lr_cta01m60.cgcord   ,
                                                                         lr_cta01m60.cgccpfdig)
             end foreach
             
             message ""
             
             open window cta01m60 at 04,02 with form "cta01m60"
                                   attribute(form line 1)
             
             message "                        (F8)Seleciona (F17)Abandona"
             
             call set_count(l_index)
             display array a_cta01m60 to s_cta01m60.*
             
             on key (interrupt)
                 let lr_retorno.erro = 1
                 exit display
             
             on key(f8)
             
             let l_index  = arr_curr()
             let lr_retorno.cgccpf    = mr_array[l_index].cgccpf
             let lr_retorno.cgcord    = mr_array[l_index].cgcord
             let lr_retorno.cgccpfdig = mr_array[l_index].cgccpfdig
             let lr_retorno.pesnom    = mr_array[l_index].pesnom
             let lr_retorno.pestip    = mr_array[l_index].pestip
             exit display
             
             end display
             
             close window cta01m60
        
        else
                open ccta01m60001
                fetch ccta01m60001 into lr_cta01m60.*
                let lr_retorno.cgccpf    = lr_cta01m60.cgccpfnum
                let lr_retorno.cgcord    = lr_cta01m60.cgcord
                let lr_retorno.cgccpfdig = lr_cta01m60.cgccpfdig
                let lr_retorno.pesnom    = lr_cta01m60.pesnom
                let lr_retorno.pestip    = lr_cta01m60.pestip
                
                close ccta01m60001
                message ""
        end if
     end if
  else
        
        if lr_param.cgcord is null then
           let lr_param.cgcord = 0
        end if
        
         call cty15g00_busca_cliente_cgccpf(lr_param.cgccpfnum ,
                                            lr_param.cgcord    ,
                                            lr_param.cgccpfdig ,
                                            lr_param.pestip    )
         returning ws.sqlcode, ws.qtd
         
         let lr_retorno.cgccpf    = g_a_cliente[1].cgccpfnum
         let lr_retorno.cgcord    = g_a_cliente[1].cgcord
         let lr_retorno.cgccpfdig = g_a_cliente[1].cgccpfdig
         let lr_retorno.pesnom    = g_a_cliente[1].pesnom
         let lr_retorno.pestip    = g_a_cliente[1].pestip
  
  end if
   
   return  lr_retorno.cgccpf    ,
           lr_retorno.cgcord    ,
           lr_retorno.cgccpfdig ,
           lr_retorno.pesnom    ,
           lr_retorno.pestip    ,
           lr_retorno.erro

end function

#------------------------------------------------------------------------------
function cta01m60_busca_cliente_gsakseg(lr_param)
#------------------------------------------------------------------------------
define lr_param record
     segnom  char (60)
end record

define lr_retorno record
   cgccpfnum like gsakpes.cgccpfnum ,
   pesnom    like gsakpes.pesnom    ,
   cgcord    like gsakpes.cgcord    ,
   cgccpfdig like gsakpes.cgccpfdig ,
   pestip    like gsakseg.pestip
end record

define l_sql     char(500)

initialize lr_retorno.* to null
  let l_sql =  " select distinct(cgccpfnum)      "
              ,"      ,segnom         "
              ,"      ,cgcord         "
              ,"      ,cgccpfdig      "
              ,"      ,pestip         "
              ," from gsakseg         "
              ," where segnom matches '", lr_param.segnom clipped, "*'"
  prepare p_gsakseg from l_sql
  declare c_gsakseg cursor with hold for p_gsakseg
  
  open c_gsakseg
  foreach c_gsakseg into  lr_retorno.cgccpfnum
                         ,lr_retorno.pesnom
                         ,lr_retorno.cgcord
                         ,lr_retorno.cgccpfdig
                         ,lr_retorno.pestip
   
   if lr_retorno.cgccpfnum <> 0 and
      lr_retorno.cgccpfnum is not null then
         whenever error continue
         execute p_insert using  lr_retorno.pesnom
                                ,lr_retorno.cgccpfnum
                                ,lr_retorno.cgcord
                                ,lr_retorno.cgccpfdig
                                ,lr_retorno.pestip
         whenever error stop
   end if
  
  end foreach
end function

#------------------------------------------------------------------------
function cta01m60_busca_cliente_azul(lr_param)
#------------------------------------------------------------------------

define lr_param record
     segnom  char (60)
end record

define lr_retorno record
   cgccpfnum like gsakpes.cgccpfnum ,
   pesnom    like gsakpes.pesnom    ,
   cgcord    like gsakpes.cgcord    ,
   cgccpfdig like gsakpes.cgccpfdig ,
   pestip    like gsakpes.pestip
end record

define l_sql     char(500)
initialize lr_retorno.* to null
  
  let l_sql =  " select distinct(cgccpfnum)      "
              ,"      ,segnom         "
              ,"      ,cgcord         "
              ,"      ,cgccpfdig      "
              ,"      ,pestip         "
              ," from datkazlapl         "
              ," where segnom matches '", lr_param.segnom clipped, "*'"
  prepare p_datkazlapl from l_sql
  declare c_datkazlapl cursor with hold for p_datkazlapl
  
  open c_datkazlapl
  foreach c_datkazlapl into  lr_retorno.cgccpfnum
                            ,lr_retorno.pesnom
                            ,lr_retorno.cgcord
                            ,lr_retorno.cgccpfdig
                            ,lr_retorno.pestip
    
    if lr_retorno.cgccpfnum <> 0 and
       lr_retorno.cgccpfnum is not null then
         whenever error continue
         execute p_insert using  lr_retorno.pesnom
                                ,lr_retorno.cgccpfnum
                                ,lr_retorno.cgcord
                                ,lr_retorno.cgccpfdig
                                ,lr_retorno.pestip
         whenever error stop
    end if
  
  end foreach
end function

#------------------------------------------------------------------------
function cta01m60_busca_cliente_saude(lr_param)
#------------------------------------------------------------------------

define lr_param record
     segnom  char (60)
end record

define lr_retorno record
   cgccpfnum like gsakpes.cgccpfnum ,
   pesnom    like gsakpes.pesnom    ,
   cgcord    like gsakpes.cgcord    ,
   cgccpfdig like gsakpes.cgccpfdig
end record

define l_sql     char(500)
initialize lr_retorno.* to null
  
  let l_sql =  " select distinct(cgccpfnum)      "
              ,"      ,segnom         "
              ,"      ,cgcord         "
              ,"      ,cgccpfdig      "
              ," from datksegsau      "
              ," where segnom matches '", lr_param.segnom clipped, "*'"
  prepare p_datksegsau from l_sql
  declare c_datksegsau cursor with hold for p_datksegsau
  
  open c_datksegsau
  foreach c_datksegsau into  lr_retorno.cgccpfnum
                            ,lr_retorno.pesnom
                            ,lr_retorno.cgcord
                            ,lr_retorno.cgccpfdig
   
   if lr_retorno.cgccpfnum <> 0 and
      lr_retorno.cgccpfnum is not null then
         whenever error continue
         execute p_insert using  lr_retorno.pesnom
                                ,lr_retorno.cgccpfnum
                                ,lr_retorno.cgcord
                                ,lr_retorno.cgccpfdig
                                ,""
         whenever error stop
   end if
  
  end foreach
end function

#------------------------------------------------------------------------
function cta01m60_busca_cliente_cartao(lr_param)
#------------------------------------------------------------------------
define lr_param record
     segnom  char (60)
end record

define lr_retorno record
   cgccpfnum like gsakpes.cgccpfnum ,
   pesnom    like gsakpes.pesnom    ,
   cgcord    like gsakpes.cgcord    ,
   cgccpfdig like gsakpes.cgccpfdig ,
   pestip    like gsakpes.pestip
end record

define l_sql     char(500)

define l_cgccpfnumdig char(18)
initialize lr_retorno.* to null

let l_cgccpfnumdig = null
  let l_sql =  " select a.cgccpfnumdig  "
              ,"      , a.crdprpnom     "
              ,"      , a.pestipcod     "
              ," from fsckprpcrd a, fscmcntprs b "
              ," where a.cgccpfnumdig = b.cgccpfnumdig "
              ," and a.crdprpnom matches '", lr_param.segnom clipped, "*'"
              ," and b.ttlstt[1,1]  = 'A' "
  prepare p_fsckprpcrd from l_sql  
  declare c_fsckprpcrd cursor with hold for p_fsckprpcrd
  
  open c_fsckprpcrd
  foreach c_fsckprpcrd into  l_cgccpfnumdig
                            ,lr_retorno.pesnom
                            ,lr_retorno.pestip
       
       call ffpfc073_desmembra_cgccpf(l_cgccpfnumdig)
       returning  lr_retorno.cgccpfnum,
                  lr_retorno.cgccpfdig
       
       let lr_retorno.cgcord = 0
    
    if lr_retorno.cgccpfnum <> 0 and
       lr_retorno.cgccpfnum is not null then
         
         whenever error continue
         execute p_insert using  lr_retorno.pesnom
                                ,lr_retorno.cgccpfnum
                                ,lr_retorno.cgcord
                                ,lr_retorno.cgccpfdig
                                ,lr_retorno.pestip
         whenever error stop
     
     end if
  end foreach
end function

#------------------------------------------------------------------------       
function cta01m60_busca_cliente_itau(lr_param)                                 
#------------------------------------------------------------------------       
                                                                                
define lr_param record                                                          
     segnom  char (60)                                                          
end record                                                                      
                                                                                
define lr_retorno record                                                        
   cgccpfnum like gsakpes.cgccpfnum ,                                           
   pesnom    like gsakpes.pesnom    ,                                           
   cgcord    like gsakpes.cgcord    ,                                           
   cgccpfdig like gsakpes.cgccpfdig ,
   pestip    like gsakpes.pestip                                                  
end record                                                                      
                                                                                
define l_sql     char(500)                                                      
initialize lr_retorno.* to null                                                 
                                                                                
  let l_sql =  " select distinct(segcgccpfnum) "                              
              ,"      ,segnom                  "                                         
              ,"      ,segcgcordnum            "                                         
              ,"      ,segcgccpfdig            " 
              ,"      ,pestipcod               "                                       
              ," from datmitaapl               "                                         
              ," where segnom matches '", lr_param.segnom clipped, "*'"         
  prepare p_datmitaapl from l_sql                                               
  declare c_datmitaapl cursor with hold for p_datmitaapl                       
                                                                                
  open c_datmitaapl                                                            
  foreach c_datmitaapl into  lr_retorno.cgccpfnum                               
                            ,lr_retorno.pesnom                                  
                            ,lr_retorno.cgcord                                  
                            ,lr_retorno.cgccpfdig 
                            ,lr_retorno.pestip                              
                                                                                
   if lr_retorno.cgccpfnum <> 0 and                                             
      lr_retorno.cgccpfnum is not null then                                     
         whenever error continue                                                
         execute p_insert using  lr_retorno.pesnom                              
                                ,lr_retorno.cgccpfnum                           
                                ,lr_retorno.cgcord                              
                                ,lr_retorno.cgccpfdig                           
                                ,lr_retorno.pestip                                              
         whenever error stop                                                    
   end if                                                                       
                                                                                
  end foreach                                                                   
end function                                                                    

#------------------------------------------------------------------------------
function cta01m60_carrega_cliente(lr_param)
#------------------------------------------------------------------------------

define lr_param record
    pesnom      like gsakpes.pesnom   ,
    pestip      like gsakpes.pestip
end record

define ws record
       sqlcode integer,
       qtd smallint
end record

define l_index integer

initialize ws.* to null

let l_index = null

    call cta01m60_prep_temp()

    message " Aguarde, pesquisando Base de Clientes Unificados..." attribute (reverse)

    # Carrego os Dados dos Clientes - gsakpes
    call osgtf550_busca_cliente_por_fonetica(lr_param.pesnom,
                                             lr_param.pestip,
                                             "U")
    returning ws.*
    if ws.qtd > 0 then
         
         for l_index  =  1  to ws.qtd
         
         if ga_gsakpes[l_index].cgccpfnum <> 0 and
            ga_gsakpes[l_index].cgccpfnum is not null then
            
            whenever error continue
            execute p_insert using  ga_gsakpes[l_index].pesnom
                                   ,ga_gsakpes[l_index].cgccpfnum
                                   ,ga_gsakpes[l_index].cgcord
                                   ,ga_gsakpes[l_index].cgccpfdig
                                   ,ga_gsakpes[l_index].pestip
            whenever error stop
         end if
        end for
    end if
    
    message " Aguarde, pesquisando Base de Segurados..." attribute (reverse)
    
    # Carrego os Dados dos Segurados - gsakseg
    call cta01m60_busca_cliente_gsakseg(lr_param.pesnom)   
    message " Aguarde, pesquisando Base de Segurados da Azul..." attribute (reverse)
    
    # Carrego os Dados dos Segurados da Azul - datkazlapl
    call cta01m60_busca_cliente_azul(lr_param.pesnom)
    message " Aguarde, pesquisando Base do Saude..." attribute (reverse)
    
    # Carrego os Dados dos Clientes do Saude
    call cta01m60_busca_cliente_saude(lr_param.pesnom)
    message " Aguarde, pesquisando Base do Cartao Visa..." attribute (reverse)
    
    # Carrego os Dados dos Clientes do Itau                                   
    call cta01m60_busca_cliente_itau(lr_param.pesnom)                         
    message " Aguarde, pesquisando Base do Itau..." attribute (reverse) 

    # Carrego os Dados dos Clientes do Itau RE
    call cta01m60_busca_cliente_itau_re(lr_param.pesnom)
    message " Aguarde, pesquisando Base do Itau RE..." attribute (reverse) 
       
    # Carrego os Dados dos Clientes do Cartao Visa
    call cta01m60_busca_cliente_cartao(lr_param.pesnom)
    
    return
end function

#------------------------------------------------------------------------------
function cta01m60_conta_cliente()
#------------------------------------------------------------------------------

define l_qtd integer

let l_qtd = null

   select count(*)
   into l_qtd
   from cta01m60_temp
   return l_qtd

end function

#------------------------------------------------------------------------       
function cta01m60_busca_cliente_itau_re(lr_param)                        
#------------------------------------------------------------------------       
                                                                                
define lr_param record                                                          
     segnom  char (60)                                                          
end record                                                                      
                                                                                
define lr_retorno record                                                        
       segcpjcpfnum like datmresitaapl.segcpjcpfnum ,                                  segnom       like datmresitaapl.segnom    ,                                     cpjordnum    like datmresitaapl.cpjordnum    ,                                  cpjcpfdignum like datmresitaapl.cpjcpfdignum ,
       pestipcod like datmresitaapl.pestipcod                                   end record                                                                      
                                           
define lr_retorno_aux record
       cgccpfnum like gsakpes.cgccpfnum ,
       pesnom    like gsakpes.pesnom    ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    like gsakpes.pestip
end record

define l_sql     char(500)                                                      
initialize lr_retorno.* to null                                                 
                                                                                
  let l_sql =  " select distinct(segcpjcpfnum) "                              
              ,"      ,segnom                  "                                         
              ,"      ,cpjordnum            "                                         
              ,"      ,cpjcpfdignum            " 
              ,"      ,pestipcod               "                                       
              ," from datmresitaapl               "                                         
              ," where segnom matches '", lr_param.segnom clipped, "*'"         
  prepare p_datmresitaapl from l_sql                                          
  declare c_datmresitaapl cursor with hold for p_datmresitaapl             
                                                                                
  open c_datmresitaapl                                                        
  foreach c_datmresitaapl into  lr_retorno.segcpjcpfnum                                                        ,lr_retorno.segnom                                                              ,lr_retorno.cpjordnum                                                           ,lr_retorno.cpjcpfdignum 
                               ,lr_retorno.pestipcod                           
                                                                                
   if lr_retorno.segcpjcpfnum <> 0 and                                         
      lr_retorno.segcpjcpfnum is not null then                                  
      let lr_retorno_aux.pesnom    = lr_retorno.segnom
      let lr_retorno_aux.cgccpfnum = lr_retorno.segcpjcpfnum
      let lr_retorno_aux.cgcord    = lr_retorno.cpjordnum
      let lr_retorno_aux.cgccpfdig = lr_retorno.cpjcpfdignum
      let lr_retorno_aux.pestip    = lr_retorno.pestipcod
      whenever error continue                                                
      execute p_insert using  lr_retorno_aux.pesnom                            
                             ,lr_retorno_aux.cgccpfnum                         
                             ,lr_retorno_aux.cgcord                            
                             ,lr_retorno_aux.cgccpfdig                         
                             ,lr_retorno_aux.pestip                                    
      whenever error stop                                                    
   end if                                                                       
                                                                                
  end foreach                                                                   
end function                                                                    

#------------------------------------------------------------------------------
















