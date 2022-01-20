#-----------------------------------------------------------------------------#     
# Porto Seguro Cia Seguros Gerais                                             #     
#.............................................................................#     
# Sistema........: Auto e RE - Itau Seguros                                   #     
# Modulo.........: cta18m00                                                   #     
# Objetivo.......: Complemento Espelho do Itau                                #     
# Analista Resp. : Roberto Melo                                               #     
# PSI            :                                                            #     
#.............................................................................#     
# Desenvolvimento: Marcos Goes                                                #     
# Liberacao      : 08/09/2011                                                 #     
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 08/09/2011   Marcos Goes                Adaptacao dos campos do novo layout #
#                                         do Itau adicionados a global.       #
#-----------------------------------------------------------------------------#  
#18/04/2012  Silvia, Meta  PSI 2012-07408 Projeto Anatel - tel 9 digitos      #
#-----------------------------------------------------------------------------#  
                                                                                   
                                                                                   
database porto                                                                     
                                                                                   
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare   smallint 
define m_hostname  char(10)

define mr_tela record
     seglgdnom        like datmitaapl.seglgdnom   ,             
     seglgdnum        like datmitaapl.seglgdnum   ,
     segendcmpdes     like datmitaapl.segendcmpdes,
     segbrrnom        like datmitaapl.segbrrnom   ,
     segcepnum        char(05)                    ,
     segcepcmpnum     char(03)                    ,
     segcidnom        like datmitaapl.segcidnom   ,
     segufdsgl        like datmitaapl.segufdsgl   ,
     segresteldddnum  char(04)                    ,
     segrestelnum     like datmitaapl.segrestelnum, ## Anatel - char(08)                    ,
     rsclclcepnum     char(05)                    ,
     rcslclcepcmpnum  char(03)                    ,
     label1           char(75)                    ,                 
     seta             char(1)    
end record     
                 
                              
 
#------------------------------------------------------------------------------ 
function cta18m00()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                                                 
   erro          integer   ,                 
   mensagem      char(50)                                        
end record                                                       

initialize lr_retorno.* ,
           mr_tela.*   to null
                  
     call cta18m00_carrega_campo()
             
     open window cta18m00 at 03,02 with form "cta18m00"     
          attribute(form line 1)                       
                                                                                                       
     input by name mr_tela.* without defaults    
     
     before field seglgdnom
       call cta18m00_display()                                                       
       
       error ""    
                                                       
        on key (interrupt,control-c)                                                             
           exit input    
        
             
     end input                                            
                                                            
     close window cta18m00                                  
                                                            
     let int_flag = false                                   
     
                
end function


#------------------------------------------------------------------------------ 
function cta18m00_carrega_campo()
#------------------------------------------------------------------------------       
    
    let mr_tela.seglgdnom       = g_doc_itau[1].seglgdnom      
    let mr_tela.seglgdnum       = g_doc_itau[1].seglgdnum      
    let mr_tela.segendcmpdes    = g_doc_itau[1].segendcmpdes   
    let mr_tela.segbrrnom       = g_doc_itau[1].segbrrnom      
    let mr_tela.segcepnum       = g_doc_itau[1].segcepnum        using "&&&&&"     
    let mr_tela.segcepcmpnum    = g_doc_itau[1].segcepcmpnum     using "&&&"   
    let mr_tela.segcidnom       = g_doc_itau[1].segcidnom      
    let mr_tela.segufdsgl       = g_doc_itau[1].segufdsgl              
    let mr_tela.segresteldddnum = g_doc_itau[1].segresteldddnum  using "<&&&" 
    let mr_tela.segrestelnum    = g_doc_itau[1].segrestelnum     using "<&&&&&&&&"   
    let mr_tela.rsclclcepnum    = g_doc_itau[1].rsclclcepnum     using "&&&&&" 
    let mr_tela.rcslclcepcmpnum = g_doc_itau[1].rcslclcepcmpnum  using "&&&"   
                                  
     # Formata Label
     
     let mr_tela.label1 = "                           ENDERECO SEGURADO ITAU" 
     
                    
end function     

#------------------------------------------------------------------------------     
function cta18m00_display()                                                  
#------------------------------------------------------------------------------    

   display by name mr_tela.seglgdnom          
   display by name mr_tela.seglgdnum      
   display by name mr_tela.segendcmpdes   
   display by name mr_tela.segbrrnom      
   display by name mr_tela.segcepnum      
   display by name mr_tela.segcepcmpnum   
   display by name mr_tela.segcidnom         
   display by name mr_tela.segufdsgl      
   display by name mr_tela.segresteldddnum
   display by name mr_tela.segrestelnum   
   display by name mr_tela.rsclclcepnum   
   display by name mr_tela.rcslclcepcmpnum
   display by name mr_tela.label1 attribute(reverse)
   display by name mr_tela.seta   
   
end function
