#----------------------------------------------------------------------------# 
# Porto Seguro Cia Seguros Gerais                                            # 
#............................................................................# 
# Sistema........: Auto e RE - Itau Seguros                                  # 
# Modulo.........: cta00m28                                                  # 
# Objetivo.......: Lista de Segurados Itau                                   # 
# Analista Resp. : Roberto Melo                                              # 
# PSI            :                                                           # 
#............................................................................# 
# Desenvolvimento: Roberto Melo                                              # 
# Liberacao      : 31/01/2010                                                # 
#............................................................................# 


database porto                                        
                                                      
globals "/homedsa/projetos/geral/globals/glct.4gl"    
                                                      
define m_prepare  smallint 

define mr_array array[500] of record         
       seta              smallint                        ,             
       segnom            like datmitaapl.segnom          ,           
       itaaplvigincdat   like datmitaapl.itaaplvigincdat ,
       itaaplvigfnldat   like datmitaapl.itaaplvigfnldat ,
       autplcnum         like datmitaaplitm.autplcnum         
end record

define mr_array_aux array[500] of record      
       sitdoc            char(10)                        ,
       adniclhordat      date                            ,
       documento         char(20)                        ,      
       veiculo           char(50)                                
end record  

define mr_retorno array[500] of record                        
       itaciacod     like datmitaapl.itaciacod       ,    
       itaramcod     like datmitaapl.itaramcod       ,  
       itaaplnum     like datmitaapl.itaaplnum       ,  
       aplseqnum     like datmitaapl.aplseqnum       ,  
       itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
       succod        like datmitaapl.succod          ,
       cgccpfnum     like datkitavippes.cgccpfnum    ,  
       cgccpford     like datkitavippes.cgccpford    ,
       cgccpfdig     like datkitavippes.cgccpfdig   
end record                                                       

define m_index   integer
define m_segnom  like datmitaapl.segnom    
define m_pesnom  like datkitavippes.pesnom                                             
                              
#------------------------------------------------------------------------------                            
function cta00m28_prepare()                                                     
#------------------------------------------------------------------------------ 

define l_sql char(1000)                                          
                                                                           
   
   let l_sql = " select itaaplitmnum, " ,     
               "         autplcnum  , " ,     
               "         autfbrnom  , " ,     
               "         autlnhnom  , " ,     
               "         autmodnom  , " ,
               "   itaaplcanmtvcod    " ,      
               " from datmitaaplitm "   ,                    
               " where itaciacod = ? "  ,             
               " and   itaramcod = ? "  ,             
               " and   itaaplnum = ? "  ,             
               " and   aplseqnum = ? "  ,
               " order by itaaplitmnum "                    
   prepare p_cta00m28_002  from l_sql                
   declare c_cta00m28_002  cursor for p_cta00m28_002  
   
   
   let l_sql = " select a.itaciacod  ,                    ",    
               "        a.itaramcod  ,                    ",    
               "        a.itaaplnum  ,                    ",    
               "        a.aplseqnum  ,                    ",   
               "        a.succod     ,                    ", 
               "  a.itaaplvigincdat  ,                    ",    
               "  a.itaaplvigfnldat  ,                    ",    
               "     a.adniclhordat  ,                    ",    
               "          a.segnom                        ",
               " from datmitaapl a                        ",    
               " where a.pestipcod    = ?                 ",      
               " and   a.segcgccpfnum = ?                 ",
               " and   a.segcgcordnum = ?                 ",
               " and   a.segcgccpfdig = ?                 ",
               " and a.aplseqnum =(select max(b.aplseqnum)",    
               " from datmitaapl b                        ",       
               " where a.itaciacod = b.itaciacod          ",   
               " and   a.itaramcod = b.itaramcod          ",   
               " and   a.itaaplnum = b.itaaplnum)         ",                  
               " order by a.segnom, a.itaaplvigfnldat desc"     
   prepare p_cta00m28_003  from l_sql                         
   declare c_cta00m28_003  cursor for p_cta00m28_003  
   
   let l_sql = " select cgccpfnum ,   ", 
               "        cgccpford ,   ", 
               "        cgccpfdig ,   ", 
               "        pesnom        ", 
               " from datkitavippes   ", 
               " where cgccpfnum = ?  ", 
               " and   cgccpford = ?  ",
               " and   cgccpfdig = ?  ",
               " and   pestipcod = ?  ", 
               " order by pesnom      "  
   prepare p_cta00m28_005  from l_sql                       
   declare c_cta00m28_005  cursor for p_cta00m28_005  
   
   let l_sql = " select b.itaciacod,       ",            
               "        b.itaramcod,       ",            
               "        b.itaaplnum,       ",            
               "        b.aplseqnum,       ",             
               "        a.succod,          ",  
               "        a.itaaplvigincdat, ",
               "        a.itaaplvigfnldat, ",
               "        a.adniclhordat,    ",
               "        a.segnom           ",
               " from datmitaapl a  ,      ",            
               "      datmitaaplitm b      ",            
               " where a.itaciacod  = b.itaciacod ", 
               " and   a.itaramcod  = b.itaramcod ", 
               " and   a.itaaplnum  = b.itaaplnum ", 
               " and   a.aplseqnum  = b.aplseqnum ", 
               " and   b.autplcnum  = ?           ", 
               " and   a.aplseqnum  =(select max(c.aplseqnum)", 
               " from datmitaapl c                           ", 
               " where a.itaciacod = c.itaciacod             ", 
               " and   a.itaramcod = c.itaramcod             ", 
               " and   a.itaaplnum = c.itaaplnum)            ",
               " order by a.itaaplvigfnldat desc             "        
   prepare p_cta00m28_006  from l_sql                 
   declare c_cta00m28_006  cursor for p_cta00m28_006  
   
   let l_sql = " select itaaplitmnum, " ,           
               "         autplcnum  , " ,           
               "         autfbrnom  , " ,           
               "         autlnhnom  , " ,           
               "         autmodnom  , " ,           
               "   itaaplcanmtvcod    " ,           
               " from datmitaaplitm "   ,           
               " where itaciacod = ? "  ,           
               " and   itaramcod = ? "  ,           
               " and   itaaplnum = ? "  ,           
               " and   aplseqnum = ? "  , 
               " and   autplcnum = ? "  ,          
               " order by itaaplitmnum "            
   prepare p_cta00m28_007  from l_sql               
   declare c_cta00m28_007  cursor for p_cta00m28_007
   
                                                                                                                            
   let m_prepare = true                                
                                                                
end function   


#------------------------------------------------------------------------------      
function cta00m28_prepare1()                                                          
#------------------------------------------------------------------------------      
                                                                                     
define l_sql char(1000)                                                              
                                                                                     
   let l_sql = " select a.itaciacod  ,                      ",                           
               "        a.itaramcod  ,                      ",                           
               "        a.itaaplnum  ,                      ",                           
               "        a.aplseqnum  ,                      ", 
               "        a.succod     ,                      ",                          
               "  a.itaaplvigincdat  ,                      ",                           
               "  a.itaaplvigfnldat  ,                      ",                           
               "     a.adniclhordat  ,                      ",                           
               "          a.segnom                          ",                         
               " from datmitaapl a                          ",                           
               " where a.segnom matches '", m_segnom ,"'    ",                           
               " and a.aplseqnum = (select max(b.aplseqnum) ",                           
               " from datmitaapl b                          ",                           
               " where a.itaciacod = b.itaciacod            ",
               " and   a.itaramcod = b.itaramcod            ",
               " and   a.itaaplnum = b.itaaplnum)           ",
               " order by a.segnom, a.itaaplvigfnldat desc  "                            
   prepare p_cta00m28_001  from l_sql                                                
   declare c_cta00m28_001  cursor for p_cta00m28_001                                 

end function

#------------------------------------------------------------------------------    
function cta00m28_prepare2()                                                       
#------------------------------------------------------------------------------    
                                                                                   
define l_sql char(1000)                                                            
                                                                                   
   let l_sql = " select cgccpfnum ,                      ",                     
               "        cgccpford ,                      ",                     
               "        cgccpfdig ,                      ",                                         
               "        pesnom                           ",                                       
               " from datkitavippes                      ",                     
               " where pesnom matches '", m_pesnom ,"'   ",                                      
               " order by pesnom                         "                      
   prepare p_cta00m28_004  from l_sql                                              
   declare c_cta00m28_004  cursor for p_cta00m28_004                              
                                                                                   
end function                                                                       


#------------------------------------------------------------------------------                                                 
function cta00m28_rec_apolice_por_nome(lr_param)                                                    
#------------------------------------------------------------------------------

define lr_param record   
   segnom        like datmitaapl.segnom                     
end record   

define lr_retorno record
   itaciacod     like datmitaapl.itaciacod       ,     
   itaramcod     like datmitaapl.itaramcod       ,     
   itaaplnum     like datmitaapl.itaaplnum       ,     
   aplseqnum     like datmitaapl.aplseqnum       ,     
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,  
   succod        like datmitaapl.succod          , 
   erro          integer                         ,       
   mensagem      char(50)                                
end record

define lr_aux record                              
   itaciacod        like datmitaapl.itaciacod          ,        
   itaramcod        like datmitaapl.itaramcod          ,        
   itaaplnum        like datmitaapl.itaaplnum          ,        
   aplseqnum        like datmitaapl.aplseqnum          ,        
   itaaplitmnum     like datmitaaplitm.itaaplitmnum    ,  
   succod           like datmitaapl.succod             , 
   segnom           like datmitaapl.segnom             , 
   itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod ,       
   itaaplvigincdat  like datmitaapl.itaaplvigincdat    ,        
   itaaplvigfnldat  like datmitaapl.itaaplvigfnldat    ,
   adniclhordat     date                               ,
   autplcnum        like datmitaaplitm.autplcnum       ,
   autfbrnom        like datmitaaplitm.autfbrnom       ,
   autlnhnom        like datmitaaplitm.autlnhnom       ,
   autmodnom        like datmitaaplitm.autmodnom        
end record                                                        



initialize lr_retorno.*,
           lr_aux.*    to null

let m_segnom = null

for  m_index  =  1  to  500                  
   initialize  mr_array[m_index].*     ,
               mr_array_aux[m_index].* ,
               mr_retorno[m_index].*   to null
end  for                                     

let m_segnom = lr_param.segnom clipped , "*"  

if m_prepare is null or        
   m_prepare <> true then      
   call cta00m28_prepare()     
end if 

call cta00m28_prepare1()      

let lr_retorno.erro = 0 
   
   let m_index = 0  
     
   # Recupera a Lista de Segurados por Nome
   
   open c_cta00m28_001 
                          
   foreach c_cta00m28_001 into lr_aux.itaciacod      ,   
                               lr_aux.itaramcod      ,                     
                               lr_aux.itaaplnum      ,
                               lr_aux.aplseqnum      , 
                               lr_aux.succod         ,                    
                               lr_aux.itaaplvigincdat,
                               lr_aux.itaaplvigfnldat,
                               lr_aux.adniclhordat   ,
                               lr_aux.segnom         
                                                     
      
            # Recupera os Itens de cada Segurado
           
            open c_cta00m28_002 using  lr_aux.itaciacod , 
                                       lr_aux.itaramcod ,
                                       lr_aux.itaaplnum ,
                                       lr_aux.aplseqnum 
            
            foreach c_cta00m28_002 into lr_aux.itaaplitmnum  ,
                                        lr_aux.autplcnum     ,
                                        lr_aux.autfbrnom     ,
                                        lr_aux.autlnhnom     ,
                                        lr_aux.autmodnom     ,
                                        lr_aux.itaaplcanmtvcod       
                                     
                  if m_index = 0 then
                     let m_index = 1
                  end if
                  
                  # Carrega os Dados 
                                                                                      
                  let mr_array[m_index].segnom           = lr_aux.segnom           
                  let mr_array[m_index].itaaplvigincdat  = lr_aux.itaaplvigincdat
                  let mr_array[m_index].itaaplvigfnldat  = lr_aux.itaaplvigfnldat
                  let mr_array[m_index].autplcnum        = lr_aux.autplcnum     
                  let mr_retorno[m_index].itaciacod      = lr_aux.itaciacod                 
                  let mr_retorno[m_index].itaramcod      = lr_aux.itaramcod   
                  let mr_retorno[m_index].itaaplnum      = lr_aux.itaaplnum   
                  let mr_retorno[m_index].aplseqnum      = lr_aux.aplseqnum   
                  let mr_retorno[m_index].itaaplitmnum   = lr_aux.itaaplitmnum
                  let mr_retorno[m_index].succod         = lr_aux.succod
                  let mr_array_aux[m_index].adniclhordat = lr_aux.adniclhordat        
                                  
                  let mr_array_aux[m_index].documento    = lr_aux.itaciacod    using '<&&'       ,".",   
                                                           lr_aux.itaramcod    using '<<<<&'     ,".",
                                                           lr_aux.itaaplnum    using '<<<&&&&&&' ,".",
                                                           lr_aux.aplseqnum    using '<<<&&'     ,".",
                                                           lr_aux.itaaplitmnum using '<<<&&'  
                                                           
                  let mr_array_aux[m_index].veiculo      = lr_aux.autfbrnom clipped, " ",
                                                           lr_aux.autlnhnom clipped, " ",
                                                           lr_aux.autmodnom clipped 
                      
                  
                  if lr_aux.itaaplvigincdat <= today and           
                     lr_aux.itaaplvigfnldat  >= today then                                                                       
                        
                        if lr_aux.itaaplcanmtvcod is null then
                           let mr_array_aux[m_index].sitdoc = "ATIVA"
                        else
                           let mr_array_aux[m_index].sitdoc = "CANCELADA"      
                        end if    
                  else      
                        let mr_array_aux[m_index].sitdoc = "VENCIDA"
                  end if   
                  
                                                                                                             
                   let m_index = m_index + 1                                                
                                                                                            
                   if m_index > 500 then                                                                         
                      message "Limite excedido. Foram Encontrados mais de 500 Itens!"                             
                      exit foreach                                                          
                   end if                                                                   
            end foreach      
            
            if m_index > 500 then                                                   
               exit foreach                                                        
            end if                                                                                                                                   
   
   end foreach
   
   if m_index > 2 then
       call cta00m28_display()
       returning lr_retorno.itaciacod    ,   
                 lr_retorno.itaramcod    ,
                 lr_retorno.itaaplnum    ,
                 lr_retorno.aplseqnum    ,
                 lr_retorno.itaaplitmnum ,
                 lr_retorno.succod    
             
       if lr_retorno.itaaplnum is null then
          let lr_retorno.erro     = 1   
       end if
   else
       
        if m_index = 0 then 
           let lr_retorno.erro       = 1   
           let lr_retorno.mensagem   = "Nome do Segurado nao Encontrado!"
        else  
           let lr_retorno.itaciacod    =  mr_retorno[m_index - 1].itaciacod     
           let lr_retorno.itaramcod    =  mr_retorno[m_index - 1].itaramcod     
           let lr_retorno.itaaplnum    =  mr_retorno[m_index - 1].itaaplnum     
           let lr_retorno.aplseqnum    =  mr_retorno[m_index - 1].aplseqnum     
           let lr_retorno.itaaplitmnum =  mr_retorno[m_index - 1].itaaplitmnum 
           let lr_retorno.succod       =  mr_retorno[m_index - 1].succod 
        end if                               
   end if   
        
   return lr_retorno.itaciacod    ,
          lr_retorno.itaramcod    ,
          lr_retorno.itaaplnum    ,
          lr_retorno.aplseqnum    ,
          lr_retorno.itaaplitmnum , 
          lr_retorno.succod       ,
          lr_retorno.erro         ,   
          lr_retorno.mensagem       
                                                                  
end function

#------------------------------------------------------------------------------ 
function cta00m28_display()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                                         
   itaciacod     like datmitaapl.itaciacod       ,               
   itaramcod     like datmitaapl.itaramcod       ,               
   itaaplnum     like datmitaapl.itaaplnum       ,               
   aplseqnum     like datmitaapl.aplseqnum       ,               
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,
   succod        like datmitaapl.succod          
end record

define scr_aux smallint         

initialize lr_retorno.* to null
                                                       
      open window cta00m28 at 4,2 with form "cta00m28"     
         attribute (border,form line 1)                      
                                                             
      message " (F17)Abandona, (F8)Seleciona"                
      call set_count(m_index-1)  
      
      options insert   key F40 
      options delete   key F35 
      options next     key F30 
      options previous key F25 
                                                             
      input array  mr_array  without defaults from s_cta00m28.* 
                                                                                
      
      #------------------         
       before row                 
      #------------------         
          let m_index = arr_curr()   
          let scr_aux = scr_line()
      
      #------------------    
       before field seta                                                          
      #------------------    
       display mr_array[m_index].* to s_cta00m28[scr_aux].* attribute(reverse)                                                                          
           
       display by name mr_array_aux[m_index].documento                                     
       display by name mr_array_aux[m_index].sitdoc                                        
       display by name mr_array_aux[m_index].veiculo   
       display by name mr_array_aux[m_index].adniclhordat
       
      #------------------                                                                                
       after field seta                                                           
      #------------------   
       if  fgl_lastkey() <> fgl_keyval("up")   and                               
           fgl_lastkey() <> fgl_keyval("left") then                              
                if mr_array[m_index + 1 ].segnom is null then                 
                      next field seta                                            
                end if                                                           
       end if                                                                    
      
       display mr_array[m_index].* to s_cta00m28[scr_aux].*  
                                                             
         on key (interrupt,control-c)                        
            initialize mr_array to null                      
            let m_index = null
            exit input                                     
                                                             
         on key (f8)                                         
            let m_index = arr_curr()     
                       
            let lr_retorno.itaciacod      = mr_retorno[m_index].itaciacod       
            let lr_retorno.itaramcod      = mr_retorno[m_index].itaramcod    
            let lr_retorno.itaaplnum      = mr_retorno[m_index].itaaplnum    
            let lr_retorno.aplseqnum      = mr_retorno[m_index].aplseqnum    
            let lr_retorno.itaaplitmnum   = mr_retorno[m_index].itaaplitmnum 
            let lr_retorno.succod         = mr_retorno[m_index].succod
                        
            exit input                                
      end input                                           
                                                             
      close window cta00m28                                  
                                                             
      let int_flag = false                                   
      
         
      return lr_retorno.itaciacod    ,  
             lr_retorno.itaramcod    ,
             lr_retorno.itaaplnum    ,
             lr_retorno.aplseqnum    ,
             lr_retorno.itaaplitmnum ,
             lr_retorno.succod
                 
end function

#------------------------------------------------------------------------------ 
function cta00m28_display_vip()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                                         
   cgccpfnum     like datkitavippes.cgccpfnum      ,              
   cgccpford     like datkitavippes.cgccpford      ,              
   cgccpfdig     like datkitavippes.cgccpfdig      
end record

define scr_aux smallint         

initialize lr_retorno.* to null
                                                       
      open window cta00m28 at 4,2 with form "cta00m28"     
         attribute (border,form line 1)                      
                                                             
      message " (F17)Abandona, (F8)Seleciona"                
      call set_count(m_index-1)  
      
      options insert   key F40 
      options delete   key F35 
      options next     key F30 
      options previous key F25 
                                                             
      input array  mr_array  without defaults from s_cta00m28.* 
                                                                                
      
      #------------------         
       before row                 
      #------------------         
          let m_index = arr_curr()   
          let scr_aux = scr_line()
      
      #------------------    
       before field seta                                                          
      #------------------    
       display mr_array[m_index].* to s_cta00m28[scr_aux].* attribute(reverse)                                                                          
           
       display by name mr_array_aux[m_index].documento                                     
       display by name mr_array_aux[m_index].sitdoc                                        
       display by name mr_array_aux[m_index].veiculo   
       display by name mr_array_aux[m_index].adniclhordat
       
      #------------------                                                                                
       after field seta                                                           
      #------------------   
       if  fgl_lastkey() <> fgl_keyval("up")   and                               
           fgl_lastkey() <> fgl_keyval("left") then                              
                if mr_array[m_index + 1 ].segnom is null then                 
                      next field seta                                            
                end if                                                           
       end if                                                                    
      
       display mr_array[m_index].* to s_cta00m28[scr_aux].*  
                                                             
         on key (interrupt,control-c)                        
            initialize mr_array to null                      
            let m_index = null
            exit input                                     
                                                             
         on key (f8)                                         
            let m_index = arr_curr()     
                       
            let lr_retorno.cgccpfnum     = mr_retorno[m_index].cgccpfnum      
            let lr_retorno.cgccpford     = mr_retorno[m_index].cgccpford   
            let lr_retorno.cgccpfdig     = mr_retorno[m_index].cgccpfdig  
                        
            exit input                                
      end input                                           
                                                             
      close window cta00m28                                  
                                                             
      let int_flag = false                                   
      
         
      return lr_retorno.cgccpfnum  ,  
             lr_retorno.cgccpford  ,
             lr_retorno.cgccpfdig  
             
                           
end function

#------------------------------------------------------------------------------                         
function cta00m28_rec_apolice_por_cgccpf(lr_param)                                                              
#------------------------------------------------------------------------------                               
                                                                                                              
define lr_param record                                                                                  
  pestipcod     like datmitaapl.pestipcod     , 
  segcgccpfnum  like datmitaapl.segcgccpfnum  , 
  segcgcordnum  like datmitaapl.segcgcordnum  , 
  segcgccpfdig  like datmitaapl.segcgccpfdig                                                             
end record                                                                                              
                                                                                                        
define lr_retorno record                                                                                
   itaciacod     like datmitaapl.itaciacod       ,                                                      
   itaramcod     like datmitaapl.itaramcod       ,                                                      
   itaaplnum     like datmitaapl.itaaplnum       ,                                                      
   aplseqnum     like datmitaapl.aplseqnum       ,                                                      
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,   
   succod        like datmitaapl.succod          ,                                            
   erro          integer                         ,                                                      
   mensagem      char(50)                                                                               
end record                                                                                              
                                                                                                        
define lr_aux record                                                                                    
   itaciacod        like datmitaapl.itaciacod          ,                                                   
   itaramcod        like datmitaapl.itaramcod          ,                                                   
   itaaplnum        like datmitaapl.itaaplnum          ,                                                   
   aplseqnum        like datmitaapl.aplseqnum          ,                                                   
   itaaplitmnum     like datmitaaplitm.itaaplitmnum    , 
   succod           like datmitaapl.succod             ,                                            
   segnom           like datmitaapl.segnom             , 
   itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod ,                                                 
   itaaplvigincdat  like datmitaapl.itaaplvigincdat ,                                                   
   itaaplvigfnldat  like datmitaapl.itaaplvigfnldat ,                                                   
   adniclhordat     date                            ,                                                   
   autplcnum        like datmitaaplitm.autplcnum    ,                                                   
   autfbrnom        like datmitaaplitm.autfbrnom    ,                                                   
   autlnhnom        like datmitaaplitm.autlnhnom    ,                                                   
   autmodnom        like datmitaaplitm.autmodnom                                                        
end record                                                                                              
                                                                                                        
                                                                                                        
                                                                                                        
initialize lr_retorno.*,                                                                                
           lr_aux.*    to null                                                                          
                                                                                                        
let m_segnom = null                                                                                     
                                                                                                        
for  m_index  =  1  to  500                                                                             
   initialize  mr_array[m_index].*     ,                                                                
               mr_array_aux[m_index].* ,                                                                
               mr_retorno[m_index].*   to null                                                          
end  for                                                                                                
                                                                                                                                                                   
                                                                                                        
if m_prepare is null or                                                                                 
   m_prepare <> true then                                                                               
   call cta00m28_prepare()                                                                              
end if                                                                                                  
                                                                                                        
let lr_retorno.erro = 0                                                                                 
                                                                                                        
   let m_index = 0      
   
   if lr_param.pestipcod = "F" then
      let lr_param.segcgcordnum = 0
   end if                                                                                
                                                                                                        
   # Recupera a Lista de Segurados por CGC/CPF                                                            
                                                                                                        
   open c_cta00m28_003 using lr_param.pestipcod     ,  
                             lr_param.segcgccpfnum  ,
                             lr_param.segcgcordnum  ,
                             lr_param.segcgccpfdig 
                                                                                     
                                                                                                        
   foreach c_cta00m28_003 into lr_aux.itaciacod      ,                                                  
                               lr_aux.itaramcod      ,                                                  
                               lr_aux.itaaplnum      ,                                                  
                               lr_aux.aplseqnum      ,  
                               lr_aux.succod         ,                                                
                               lr_aux.itaaplvigincdat,                                                  
                               lr_aux.itaaplvigfnldat,                                                  
                               lr_aux.adniclhordat   ,                                                  
                               lr_aux.segnom         
                                                                                    
                                                                                                        
            # Recupera os Itens de cada Segurado                                                        
                                                                                                        
            open c_cta00m28_002 using  lr_aux.itaciacod ,                                               
                                       lr_aux.itaramcod ,                                               
                                       lr_aux.itaaplnum ,                                               
                                       lr_aux.aplseqnum                                                 
                                                                                                        
            foreach c_cta00m28_002 into lr_aux.itaaplitmnum  ,                                          
                                        lr_aux.autplcnum     ,                                          
                                        lr_aux.autfbrnom     ,                                          
                                        lr_aux.autlnhnom     ,                                          
                                        lr_aux.autmodnom     ,
                                        lr_aux.itaaplcanmtvcod                                                
                                                                                                        
                   if m_index = 0 then  
                      let m_index = 1   
                   end if               
                  
                  # Carrega os Dados                                                                    
                                                                                                        
                  let mr_array[m_index].segnom           = lr_aux.segnom                                
                  let mr_array[m_index].itaaplvigincdat  = lr_aux.itaaplvigincdat                       
                  let mr_array[m_index].itaaplvigfnldat  = lr_aux.itaaplvigfnldat                       
                  let mr_array[m_index].autplcnum        = lr_aux.autplcnum                             
                  let mr_retorno[m_index].itaciacod      = lr_aux.itaciacod                             
                  let mr_retorno[m_index].itaramcod      = lr_aux.itaramcod                             
                  let mr_retorno[m_index].itaaplnum      = lr_aux.itaaplnum                             
                  let mr_retorno[m_index].aplseqnum      = lr_aux.aplseqnum                             
                  let mr_retorno[m_index].itaaplitmnum   = lr_aux.itaaplitmnum 
                  let mr_retorno[m_index].succod         = lr_aux.succod                         
                  let mr_array_aux[m_index].adniclhordat = lr_aux.adniclhordat                          
                                                                                                        
                  let mr_array_aux[m_index].documento    = lr_aux.itaciacod    using '<&&'       ,".",  
                                                           lr_aux.itaramcod    using '<<<<&'     ,".",  
                                                           lr_aux.itaaplnum    using '<<<&&&&&&' ,".",  
                                                           lr_aux.aplseqnum    using '<<<&&'     ,".",  
                                                           lr_aux.itaaplitmnum using '<<<&&'            
                                                                                                        
                  let mr_array_aux[m_index].veiculo      = lr_aux.autfbrnom clipped, " ",               
                                                           lr_aux.autlnhnom clipped, " ",               
                                                           lr_aux.autmodnom clipped                     
                                                                                                        
                                                                                                        
                  if lr_aux.itaaplvigincdat <= today and                                                
                     lr_aux.itaaplvigfnldat  >= today then                                              
                       
                       if lr_aux.itaaplcanmtvcod is null then           
                          let mr_array_aux[m_index].sitdoc = "ATIVA"    
                       else                                             
                          let mr_array_aux[m_index].sitdoc = "CANCELADA"
                       end if                                                                               
                  else                                                                                  
                        let mr_array_aux[m_index].sitdoc = "VENCIDA"                                    
                  end if                                                                                
                                                                                                        
                                                                                                        
                   let m_index = m_index + 1                                                            
                                                                                                        
                   if m_index > 500 then                                                                
                      message "Limite excedido. Foram Encontrados mais de 500 Itens!"                   
                      exit foreach                                                                      
                   end if                                                                               
            end foreach                                                                                 
                                                                                                        
            if m_index > 500 then                                                                       
               exit foreach                                                                             
            end if                                                                                      
                                                                                                        
   end foreach                                                                                          
                                                                                                        
   if m_index > 2 then                                                                                  
       call cta00m28_display()                                                                          
       returning lr_retorno.itaciacod    ,                                                              
                 lr_retorno.itaramcod    ,                                                              
                 lr_retorno.itaaplnum    ,                                                              
                 lr_retorno.aplseqnum    ,                                                              
                 lr_retorno.itaaplitmnum ,
                 lr_retorno.succod                                                             
                                                                                                        
       if lr_retorno.itaaplnum is null then                                                             
          let lr_retorno.erro     = 1                                                                   
       end if                                                                                           
   else                                                                                                 
                                                                                                        
        if m_index = 0 then                                                      
           let lr_retorno.erro       = 1                                         
           let lr_retorno.mensagem   = "Segurado nao Encontrado!"        
        else                                                                     
           let lr_retorno.itaciacod    =  mr_retorno[m_index - 1].itaciacod                                
           let lr_retorno.itaramcod    =  mr_retorno[m_index - 1].itaramcod                                
           let lr_retorno.itaaplnum    =  mr_retorno[m_index - 1].itaaplnum                                
           let lr_retorno.aplseqnum    =  mr_retorno[m_index - 1].aplseqnum                                
           let lr_retorno.itaaplitmnum =  mr_retorno[m_index - 1].itaaplitmnum 
           let lr_retorno.succod       =  mr_retorno[m_index - 1].succod                            
        end if                                                                                                                                                                   
   
   end if                                                                                               
                                                                                                                                                                                                                
                                                                                                        
   return lr_retorno.itaciacod    ,                                                                     
          lr_retorno.itaramcod    ,                                                                     
          lr_retorno.itaaplnum    ,                                                                     
          lr_retorno.aplseqnum    ,                                                                     
          lr_retorno.itaaplitmnum , 
          lr_retorno.succod       ,                                                                    
          lr_retorno.erro         ,                                                                     
          lr_retorno.mensagem                                                                           
                                                                                                        
end function               

#------------------------------------------------------------------------------                                                                                                      
function cta00m28_rec_apolice_por_nome_vip(lr_param)                                                        
#------------------------------------------------------------------------------                         
                                                                                                        
define lr_param record                                                                                  
   pesnom         like datkitavippes.pesnom                                                                 
end record                                                                                              
                                                                                                        
define lr_retorno record                                                                                
   cgccpfnum     like datkitavippes.cgccpfnum      ,                                                      
   cgccpford     like datkitavippes.cgccpford      ,                                                      
   cgccpfdig     like datkitavippes.cgccpfdig      ,  
   pesnom        like datkitavippes.pesnom         ,                                                                                                          
   erro          integer                           ,                                                      
   mensagem      char(50)                                                                               
end record                                                                                              
                                                                                                                                                                                                                
                                                                                                        
initialize lr_retorno.*  to null                                                                          
                                                                                                        
let m_pesnom = null                                                                                     
                                                                                                        
for  m_index  =  1  to  500                                                                             
   initialize  mr_array[m_index].*     ,                                                                
               mr_array_aux[m_index].* ,                                                                
               mr_retorno[m_index].*   to null                                                          
end  for                                                                                                
                                                                                                        
let m_pesnom = lr_param.pesnom clipped , "*"                                                            
                                                                                                        
if m_prepare is null or                                                                                 
   m_prepare <> true then                                                                               
   call cta00m28_prepare()                                                                              
end if                                                                                                  
                                                                                                        
call cta00m28_prepare2()                                                                                
                                                                                                        
let lr_retorno.erro = 0                                                                                 
                                                                                                        
   let m_index = 0                                                                                      
                                                                                                        
   # Recupera a Lista de Clientes VIP por Nome                                                             
                                                                                                        
   open c_cta00m28_004                                                                                  
                                                                                                        
   foreach c_cta00m28_004 into lr_retorno.cgccpfnum        ,                                                  
                               lr_retorno.cgccpford        ,                                                  
                               lr_retorno.cgccpfdig        ,                                                                                    
                               lr_retorno.pesnom                                                            
                                                                              
                                                                                                                                                                             
                                                                                                                                             
      if m_index = 0 then                                                                   
         let m_index = 1                                                                    
      end if                                                                                
                                                                                            
      # Carrega os Dados                                                                    
                                                                                            
      let mr_array[m_index].segnom           = lr_retorno.pesnom                                                                      
      let mr_array[m_index].autplcnum        = "VIP"         
      
      let mr_retorno[m_index].cgccpfnum      = lr_retorno.cgccpfnum   
      let mr_retorno[m_index].cgccpford      = lr_retorno.cgccpford  
      let mr_retorno[m_index].cgccpfdig      = lr_retorno.cgccpfdig  
                                              
      let  mr_array_aux[m_index].documento = cta01m60_formata_cgccpf(lr_retorno.cgccpfnum  ,                          
                                                                     lr_retorno.cgccpford  ,                          
                                                                     lr_retorno.cgccpfdig)                            

                                                                                                                                                                                
       let m_index = m_index + 1                                                            
                                                                                            
       if m_index > 500 then                                                                
          message "Limite excedido. Foram Encontrados mais de 500 Itens!"                   
          exit foreach                                                                      
       end if                                                                               
                                                                          
                                                                                                                                                                          
   end foreach                                                                                          
                                                                                                        
   if m_index > 2 then                                                                                  
       call cta00m28_display_vip()                                                                          
       returning lr_retorno.cgccpfnum      ,                                                              
                 lr_retorno.cgccpford      ,                                                              
                 lr_retorno.cgccpfdig                                                      
                                                                                                                                                                                                                                                    
       if lr_retorno.cgccpfnum is null then                                                             
          let lr_retorno.erro = 1                                                                   
       end if                                                                                           
   else                                                                                                 
                                                                                                        
        if m_index = 0 then                                                                             
           let lr_retorno.erro       = 1                                                                
           let lr_retorno.mensagem   = "Nome do Segurado nao Encontrado!"                               
        else                                                                                            
           let lr_retorno.cgccpfnum  =  mr_retorno[m_index - 1].cgccpfnum                             
           let lr_retorno.cgccpford  =  mr_retorno[m_index - 1].cgccpford                             
           let lr_retorno.cgccpfdig  =  mr_retorno[m_index - 1].cgccpfdig                                                                     
        end if                                                                                          
   end if                                                                                               
                                                                                                        
   return lr_retorno.cgccpfnum     ,                                                                     
          lr_retorno.cgccpford     ,                                                                     
          lr_retorno.cgccpfdig     ,                                                                                                                                                                                                                                                                                    
          lr_retorno.erro          ,                                                                     
          lr_retorno.mensagem                                                                           
                                                                                                        
end function   

#------------------------------------------------------------------------------                                                                                                        
function cta00m28_rec_apolice_por_cgccpf_vip(lr_param)                                                                                                                                                  
#------------------------------------------------------------------------------               
                                                                                              
define lr_param record                                                                        
   cgccpfnum     like datkitavippes.cgccpfnum      , 
   cgccpford     like datkitavippes.cgccpford      , 
   cgccpfdig     like datkitavippes.cgccpfdig      , 
   pestipcod     like datkitavippes.pestipcod                                                     
end record                                                                                    
                                                                                              
define lr_retorno record                                                                      
   cgccpfnum     like datkitavippes.cgccpfnum      ,                                          
   cgccpford     like datkitavippes.cgccpford      ,                                          
   cgccpfdig     like datkitavippes.cgccpfdig      ,                                          
   pesnom        like datkitavippes.pesnom         ,                                          
   erro          integer                           ,                                          
   mensagem      char(50)                                                                     
end record                                                                                    
                                                                                              
                                                                                              
initialize lr_retorno.*  to null                                                              
                                                                                              
let m_pesnom = null                                                                           
                                                                                              
for  m_index  =  1  to  500                                                                   
   initialize  mr_array[m_index].*     ,                                                      
               mr_array_aux[m_index].* ,                                                      
               mr_retorno[m_index].*   to null                                                
end  for                                                                                      
                                                                                                                                         
                                                                                              
if m_prepare is null or                                                                       
   m_prepare <> true then                                                                     
   call cta00m28_prepare()                                                                    
end if                                                                                        
                                                                                                                                                        
                                                                                              
let lr_retorno.erro = 0                                                                       
                                                                                              
   let m_index = 0                                                                            
                                                                                              
   if lr_param.pestipcod = "F" then
      let lr_param.cgccpford = 0
   end if   
   
   
   # Recupera a Lista de Clientes VIP por CGC/CPF                                              
                                                                                              
   open c_cta00m28_005 using  lr_param.cgccpfnum , 
                              lr_param.cgccpford ,
                              lr_param.cgccpfdig ,
                              lr_param.pestipcod                                                                      
                                                                                              
   foreach c_cta00m28_005 into lr_retorno.cgccpfnum        ,                                  
                               lr_retorno.cgccpford        ,                                  
                               lr_retorno.cgccpfdig        ,                                  
                               lr_retorno.pesnom                                              
                                                                                              
                                                                                              
                                                                                              
      if m_index = 0 then                                                                     
         let m_index = 1                                                                      
      end if                                                                                  
                                                                                              
      # Carrega os Dados                                                                      
                                                                                              
      let mr_array[m_index].segnom           = lr_retorno.pesnom                              
      let mr_array[m_index].autplcnum        = "VIP"                                          
                                                                                              
      let mr_retorno[m_index].cgccpfnum      = lr_retorno.cgccpfnum                           
      let mr_retorno[m_index].cgccpford      = lr_retorno.cgccpford                           
      let mr_retorno[m_index].cgccpfdig      = lr_retorno.cgccpfdig                           
                                                                                              
      let  mr_array_aux[m_index].documento = cta01m60_formata_cgccpf(lr_retorno.cgccpfnum  ,  
                                                                     lr_retorno.cgccpford  ,  
                                                                     lr_retorno.cgccpfdig)    
                                                                                              
                                                                                              
       let m_index = m_index + 1                                                              
                                                                                              
       if m_index > 500 then                                                                  
          message "Limite excedido. Foram Encontrados mais de 500 Itens!"                     
          exit foreach                                                                        
       end if                                                                                 
                                                                                              
                                                                                              
   end foreach                                                                                
                                                                                              
   if m_index > 2 then                                                                        
       call cta00m28_display_vip()                                                            
       returning lr_retorno.cgccpfnum      ,                                                  
                 lr_retorno.cgccpford      ,                                                  
                 lr_retorno.cgccpfdig                                                         
                                                                                              
       if lr_retorno.cgccpfnum is null then                                                   
          let lr_retorno.erro = 1                                                             
       end if                                                                                 
   else                                                                                       
                                                                                              
        if m_index = 0 then                                                                   
           let lr_retorno.erro       = 1                                                      
           let lr_retorno.mensagem   = "Segurado nao Encontrado!"                     
        else                                                                                  
           let lr_retorno.cgccpfnum  =  mr_retorno[m_index - 1].cgccpfnum                     
           let lr_retorno.cgccpford  =  mr_retorno[m_index - 1].cgccpford                     
           let lr_retorno.cgccpfdig  =  mr_retorno[m_index - 1].cgccpfdig                     
        end if                                                                                
   end if                                                                                     
                                                                                              
   return lr_retorno.cgccpfnum     ,                                                          
          lr_retorno.cgccpford     ,                                                          
          lr_retorno.cgccpfdig     ,                                                          
          lr_retorno.erro          ,                                                          
          lr_retorno.mensagem                                                                 
                                                                                              
end function            

#------------------------------------------------------------------------------                                                                                                      
function cta00m28_rec_apolice_por_placa(lr_param)                                                               
#------------------------------------------------------------------------------                                
                                                                                                               
define lr_param record                                                                                                 
   autplcnum     like datmitaaplitm.autplcnum                                                                          
end record                                                                                                             
                                                                                                               
define lr_retorno record                                                                                       
   itaciacod     like datmitaapl.itaciacod       ,                                                             
   itaramcod     like datmitaapl.itaramcod       ,                                                             
   itaaplnum     like datmitaapl.itaaplnum       ,                                                             
   aplseqnum     like datmitaapl.aplseqnum       ,                                                             
   itaaplitmnum  like datmitaaplitm.itaaplitmnum ,                                                             
   succod        like datmitaapl.succod          ,                                                             
   erro          integer                         ,                                                             
   mensagem      char(50)                                                                                      
end record                                                                                                     
                                                                                                               
define lr_aux record                                                                                           
   itaciacod        like datmitaapl.itaciacod          ,                                                       
   itaramcod        like datmitaapl.itaramcod          ,                                                       
   itaaplnum        like datmitaapl.itaaplnum          ,                                                       
   aplseqnum        like datmitaapl.aplseqnum          ,                                                       
   itaaplitmnum     like datmitaaplitm.itaaplitmnum    ,                                                       
   succod           like datmitaapl.succod             ,                                                       
   segnom           like datmitaapl.segnom             ,                                                       
   itaaplcanmtvcod  like datmitaaplitm.itaaplcanmtvcod ,                                                       
   itaaplvigincdat  like datmitaapl.itaaplvigincdat    ,                                                       
   itaaplvigfnldat  like datmitaapl.itaaplvigfnldat    ,                                                       
   adniclhordat     date                               ,                                                       
   autplcnum        like datmitaaplitm.autplcnum       ,                                                       
   autfbrnom        like datmitaaplitm.autfbrnom       ,                                                       
   autlnhnom        like datmitaaplitm.autlnhnom       ,                                                       
   autmodnom        like datmitaaplitm.autmodnom                                                               
end record                                                                                                     
                                                                                                               
                                                                                                               
                                                                                                               
initialize lr_retorno.*,                                                                                       
           lr_aux.*    to null                                                                                 
                                                                                                               
let m_segnom = null                                                                                            
                                                                                                               
for  m_index  =  1  to  500                                                                                    
   initialize  mr_array[m_index].*     ,                                                                       
               mr_array_aux[m_index].* ,                                                                       
               mr_retorno[m_index].*   to null                                                                 
end  for                                                                                                       
                                                                                                                                                                       
                                                                                                               
if m_prepare is null or                                                                                        
   m_prepare <> true then                                                                                      
   call cta00m28_prepare()                                                                                     
end if                                                                                                         
                                                                                                                                                                                               
                                                                                                               
let lr_retorno.erro = 0                                                                                        
                                                                                                               
   let m_index = 0                                                                                             
                                                                                                               
   # Recupera a Lista de Clientes por Placa                                                                    
                                                                                                               
   open c_cta00m28_006 using lr_param.autplcnum
                                                                                                                  
                                                                                                               
   foreach c_cta00m28_006 into lr_aux.itaciacod      ,                                                         
                               lr_aux.itaramcod      ,                                                         
                               lr_aux.itaaplnum      ,                                                         
                               lr_aux.aplseqnum      ,                                                         
                               lr_aux.succod         ,                                                         
                               lr_aux.itaaplvigincdat,                                                         
                               lr_aux.itaaplvigfnldat,                                                         
                               lr_aux.adniclhordat   ,                                                         
                               lr_aux.segnom                                                                   
                                                                                                               
                                                                                                               
            # Recupera os Itens de cada Placa                                                               
                                                                                                               
            open c_cta00m28_007 using  lr_aux.itaciacod ,                                                      
                                       lr_aux.itaramcod ,                                                      
                                       lr_aux.itaaplnum ,                                                      
                                       lr_aux.aplseqnum ,
                                       lr_param.autplcnum                                                       
                                                                                                               
            foreach c_cta00m28_007 into lr_aux.itaaplitmnum  ,                                                 
                                        lr_aux.autplcnum     ,                                                 
                                        lr_aux.autfbrnom     ,                                                 
                                        lr_aux.autlnhnom     ,                                                 
                                        lr_aux.autmodnom     ,                                                 
                                        lr_aux.itaaplcanmtvcod                                                 
                                                                                                               
                  if m_index = 0 then                                                                          
                     let m_index = 1                                                                           
                  end if                                                                                       
                                                                                                               
                  # Carrega os Dados                                                                           
                                                                                                               
                  let mr_array[m_index].segnom           = lr_aux.segnom                                       
                  let mr_array[m_index].itaaplvigincdat  = lr_aux.itaaplvigincdat                              
                  let mr_array[m_index].itaaplvigfnldat  = lr_aux.itaaplvigfnldat                              
                  let mr_array[m_index].autplcnum        = lr_aux.autplcnum                                    
                  let mr_retorno[m_index].itaciacod      = lr_aux.itaciacod                                    
                  let mr_retorno[m_index].itaramcod      = lr_aux.itaramcod                                    
                  let mr_retorno[m_index].itaaplnum      = lr_aux.itaaplnum                                    
                  let mr_retorno[m_index].aplseqnum      = lr_aux.aplseqnum                                    
                  let mr_retorno[m_index].itaaplitmnum   = lr_aux.itaaplitmnum                                 
                  let mr_retorno[m_index].succod         = lr_aux.succod                                       
                  let mr_array_aux[m_index].adniclhordat = lr_aux.adniclhordat                                 
                                                                                                               
                  let mr_array_aux[m_index].documento    = lr_aux.itaciacod    using '<&&'       ,".",         
                                                           lr_aux.itaramcod    using '<<<<&'     ,".",         
                                                           lr_aux.itaaplnum    using '<<<&&&&&&' ,".",         
                                                           lr_aux.aplseqnum    using '<<<&&'     ,".",         
                                                           lr_aux.itaaplitmnum using '<<<&&'                   
                                                                                                               
                  let mr_array_aux[m_index].veiculo      = lr_aux.autfbrnom clipped, " ",                      
                                                           lr_aux.autlnhnom clipped, " ",                      
                                                           lr_aux.autmodnom clipped                            
                                                                                                               
                                                                                                               
                  if lr_aux.itaaplvigincdat <= today and                                                       
                     lr_aux.itaaplvigfnldat  >= today then                                                     
                                                                                                               
                        if lr_aux.itaaplcanmtvcod is null then                                                 
                           let mr_array_aux[m_index].sitdoc = "ATIVA"                                          
                        else                                                                                   
                           let mr_array_aux[m_index].sitdoc = "CANCELADA"                                      
                        end if                                                                                 
                  else                                                                                         
                        let mr_array_aux[m_index].sitdoc = "VENCIDA"                                           
                  end if                                                                                       
                                                                                                               
                                                                                                               
                   let m_index = m_index + 1                                                                   
                                                                                                               
                   if m_index > 500 then                                                                       
                      message "Limite excedido. Foram Encontrados mais de 500 Itens!"                          
                      exit foreach                                                                             
                   end if                                                                                      
            end foreach                                                                                        
                                                                                                               
            if m_index > 500 then                                                                              
               exit foreach                                                                                    
            end if                                                                                             
                                                                                                               
   end foreach                                                                                                 
                                                                                                               
   if m_index > 2 then                                                                                         
       call cta00m28_display()                                                                                 
       returning lr_retorno.itaciacod    ,                                                                     
                 lr_retorno.itaramcod    ,                                                                     
                 lr_retorno.itaaplnum    ,                                                                     
                 lr_retorno.aplseqnum    ,                                                                     
                 lr_retorno.itaaplitmnum ,                                                                     
                 lr_retorno.succod                                                                             
                                                                                                               
       if lr_retorno.itaaplnum is null then                                                                    
          let lr_retorno.erro     = 1                                                                          
       end if                                                                                                  
   else                                                                                                        
                                                                                                               
        if m_index = 0 then                                                                                    
           let lr_retorno.erro       = 1                                                                       
           let lr_retorno.mensagem   = "Placa do Veiculo nao Encontrada!"                                     
        else                                                                                                   
           let lr_retorno.itaciacod    =  mr_retorno[m_index - 1].itaciacod                                    
           let lr_retorno.itaramcod    =  mr_retorno[m_index - 1].itaramcod                                    
           let lr_retorno.itaaplnum    =  mr_retorno[m_index - 1].itaaplnum                                    
           let lr_retorno.aplseqnum    =  mr_retorno[m_index - 1].aplseqnum                                    
           let lr_retorno.itaaplitmnum =  mr_retorno[m_index - 1].itaaplitmnum                                 
           let lr_retorno.succod       =  mr_retorno[m_index - 1].succod                                       
        end if                                                                                                 
   end if                                                                                                      
                                                                                                               
   return lr_retorno.itaciacod    ,                                                                            
          lr_retorno.itaramcod    ,                                                                            
          lr_retorno.itaaplnum    ,                                                                            
          lr_retorno.aplseqnum    ,                                                                            
          lr_retorno.itaaplitmnum ,                                                                            
          lr_retorno.succod       ,                                                                            
          lr_retorno.erro         ,                                                                            
          lr_retorno.mensagem                                                                                  
                                                                                                               
end function                                                                                                   
                                                                                                               