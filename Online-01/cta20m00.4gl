#-----------------------------------------------------------------------------# # Porto Seguro Cia Seguros Gerais                                             # #.............................................................................# # Sistema........: Itau Residencia                                            # # Modulo.........: cta20m00                                                   # # Objetivo.......: Complemento Espelho do Itau                                # # Analista Resp. : JUNIOR  (FORNAX)                                           # # PSI            :                                                            # #.............................................................................# # Desenvolvimento: JUNIOR (FORNAX)                                            # # Liberacao      :   /  /                                                     # #.............................................................................# #                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#   /  /                                                                      #
#-----------------------------------------------------------------------------#                                                                                 database porto                                                                     
Globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_hostname  char(10)

define mr_tela record
     cgccpf           char(25)                              ,
     pestip           char(08)                              ,
     asiincdat        like datmitaaplitm.asiincdat          ,
     casfrqvlr        char(10)                              ,
     itaempasides     like datkitaempasi.itaempasides       ,
     itaprddes        like datkresitaprd.prddes             ,  
     itarsrcaogrtdes  like datkitarsrcaogar.itarsrcaogrtdes ,
     rsrcaogrtcod     like datkitarsrcaogar.rsrcaogrtcod    ,
     ubbcod           like datkubbvcltip.ubbcod             ,
     vcltipdes        like datkubbvcltip.vcltipdes          ,
     adniclhordat     date                                  ,      
     itaprpnum        like datmresitaapl.prpnum             ,
     vipsegflg        char(03)                              ,
     itaaplcanmtvcod  like datkitaaplcanmtv.itaaplcanmtvcod ,
     itaaplcanmtvdes  like datkitaaplcanmtv.itaaplcanmtvdes ,
     label2           char(75)                              ,
     seta             char(01)                              ,
     frtmdlcod        like datkitafrtmdl.frtmdlcod          ,
     frtmdldes        like datkitafrtmdl.frtmdldes          ,
     vndcnlcod        like datkitavndcnl.vndcnlcod          ,
     vndcnldes        like datkitavndcnl.vndcnldes                                         
end record     
                              
#------------------------------------------------------------------------------ 
function cta20m00()                                                             
#------------------------------------------------------------------------------ 

define lr_retorno record                                                 
   erro          integer   ,                 
   mensagem      char(50)                                        
end record                                                       

initialize lr_retorno.* ,
           mr_tela.*   to null
                  
     call cta20m00_carrega_campo()
             
     open window cta20m00 at 03,02 with form "cta20m00"     
          attribute(form line 1)                       
                                                                                                       
     input by name mr_tela.* without defaults    
     
     before field cgccpf
       call cta20m00_display()                                                       
       
       error ""    
                                                       
        on key (interrupt,control-c)                                                             
           exit input    
        
             
     end input                                            
                                                            
     close window cta20m00                                  
                                                            
     let int_flag = false                                   
     
                
end function


#------------------------------------------------------------------------------ 
function cta20m00_carrega_campo()
#------------------------------------------------------------------------------       

    let mr_tela.asiincdat       = g_doc_itau[1].asiincdat      
    let mr_tela.casfrqvlr       = g_doc_itau[1].casfrqvlr      
    let mr_tela.adniclhordat    = g_doc_itau[1].adniclhordat       
    let mr_tela.rsrcaogrtcod    = g_doc_itau[1].rsrcaogrtcod
    let mr_tela.ubbcod          = g_doc_itau[1].ubbcod 
    let mr_tela.itaprpnum       = g_doc_itau[1].itaprpnum          
    let mr_tela.itaaplcanmtvcod = g_doc_itau[1].itaaplcanmtvcod
    let mr_tela.frtmdlcod       = g_doc_itau[1].frtmdlcod
    let mr_tela.vndcnlcod       = g_doc_itau[1].vndcnlcod
    

     # Recupera Descricoes                                       
                                                                 
     call cty25g03_recupera_descricao(8,g_doc_itau[1].itaempasicod) 
     returning mr_tela.itaempasides    
     
     call cty25g03_recupera_descricao(2,g_doc_itau[1].itaprdcod)  
     returning mr_tela.itaprddes 
     
     call cto00m10_recupera_descricao(11,g_doc_itau[1].rsrcaogrtcod)   
     returning mr_tela.itarsrcaogrtdes   
     
     call cto00m10_recupera_descricao(12,g_doc_itau[1].itaaplcanmtvcod)              returning mr_tela.itaaplcanmtvdes                                                                                                                               call cto00m10_recupera_descricao(18,g_doc_itau[1].frtmdlcod)                    returning mr_tela.frtmdldes 
     
     call cto00m10_recupera_descricao(19,g_doc_itau[1].vndcnlcod)                    returning mr_tela.vndcnldes 

     # Formata Campo CGC/CPF
     
     if g_doc_itau[1].segcgcordnum is null or 
        g_doc_itau[1].segcgcordnum = 0     or
        g_doc_itau[1].segcgcordnum = " "   then
        
          let mr_tela.cgccpf = g_doc_itau[1].segcgccpfnum using "<<&&&&&&&", "-", g_doc_itau[1].segcgccpfdig using "&&"  
          let mr_tela.pestip = "FISICA"
     
     else
         
          let mr_tela.cgccpf = g_doc_itau[1].segcgccpfnum using "<<&&&&&&&", "/", g_doc_itau[1].segcgcordnum using "&&&&", "-", g_doc_itau[1].segcgccpfdig using "&&"   
          let mr_tela.pestip = "JURIDICA"  
                                  
     end if
     
     if g_doc_itau[1].vipsegflg = "N" then
        let mr_tela.vipsegflg = "NAO"
     else
        let mr_tela.vipsegflg = "SIM"
     end if 
                  
     #Se for Itau mostra garantia se for Unibanco desconsidera       
     #if g_doc_itau[1].ubbcod <> 0 then                                                                                 
                                  
     # Formata Label
     
     let mr_tela.label2 = "                            OUTRAS INFORMACOES" 
    
     
                    
end function     

#------------------------------------------------------------------------------     
function cta20m00_display()                                                  
#------------------------------------------------------------------------------    

   display by name mr_tela.cgccpf          
   display by name mr_tela.pestip          
   display by name mr_tela.asiincdat       
   display by name mr_tela.casfrqvlr       
   display by name mr_tela.itaempasides    
   display by name mr_tela.itaprddes       
   display by name mr_tela.rsrcaogrtcod 
   display by name mr_tela.itarsrcaogrtdes 
   display by name mr_tela.ubbcod          
   display by name mr_tela.adniclhordat    
   display by name mr_tela.itaprpnum       
   display by name mr_tela.vipsegflg       
   display by name mr_tela.itaaplcanmtvcod 
   display by name mr_tela.itaaplcanmtvdes 
   display by name mr_tela.label2 attribute(reverse)
   display by name mr_tela.seta            
   display by name mr_tela.frtmdlcod       
   display by name mr_tela.frtmdldes       
   display by name mr_tela.vndcnlcod       
   display by name mr_tela.vndcnldes       

end function
