#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
# .............................................................................#
# Sistema       : CENTRAL 24 HS                                                #
# Modulo        : cts10g14                                                     #
# Analista Resp.: R.Fornax                                                     #
# PSI           :                                                              #
#               : Função para gravação do Aviso de Sinistro RE via MQ          #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 05/02/2013                                                  #
#..............................................................................#
# DATA		NOME		     PSI		DESCRICAO	       #
# ------------  -------------------- ------------------ ---------------------- #
# 25/09/2013	Samuel Rulli	     XXXXXXX		Ajuste tratativas Erro #
#..............................................................................#
database porto                                                          
                                                                        
globals  "/homedsa/projetos/geral/globals/glct.4gl"                     
                                                                        
define m_prepare  smallint                                              

#---------------------------------------------------------------------  
function cts10g14_prepare()                                             
#---------------------------------------------------------------------  

    define l_sql     char(2000)                        

                                                    

   let l_sql = " select sinramgrp ",                  
               " from gtakram     ",          
               " where empcod = ? ",              
               " and ramcod   = ? "                 

   prepare p_cts10g14_001  from l_sql               

   declare c_cts10g14_001  cursor for p_cts10g14_001

    let l_sql = " insert into datmpedvist ",
                "(sinvstnum,   ",
                " sinvstano,   ",
                " vstsolnom,   ",
                " vstsoltip,   ",
                " vstsoltipcod,",
                " sindat   ,   ",
                " sinhor   ,   ",
                " segnom   ,   ",
                " cornom   ,   ",
                " dddcod   ,   ",
                " teltxt   ,   ",
                " funmat   ,   ",
                " sinntzcod,   ",
                " lclrsccod,   ",
                " lclendflg,   ",
                " lgdtip   ,   ",
                " lgdnom   ,   ",
                " lgdnum   ,   ",
                " endufd   ,   ",
                " lgdnomcmp,   ",
                " endbrr   ,   ",
                " endcid   ,   ",
                " endcep   ,   ",
                " endcepcmp,   ",
                " endddd   ,   ",
                " teldes   ,   ",
                " lclcttnom,   ",
                " endrefpto,   ",
                " sinhst   ,   ",
                " sinobs   ,   ",
                " vstsolstt,   ",
                " sinvstdat,   ",
                " sinvsthor,   ",
                " rglvstflg,   ",
                " sinramgrp,   ",
                " lclnumseq,   ",
                " rmerscseq)   ",
                " values (?,?,?,?,?,?,?,?,?,?,",
                "         ?,?,?,?,?,?,?,?,?,?,",
                "         ?,?,?,?,?,?,?,?,?,?,",
                "         ?,?,?,?,?,?,?)      "
    prepare p_cts10g14_002  from l_sql 
    
    
    
    let l_sql = " insert into datrpedvistnatcob " , 
                " (sinvstnum , "                  , 
                "  sinvstano , "                  ,
                "  cbttip    , "                  ,   
                "  sinramgrp , "                  ,
                "  sinntzcod , "                  ,
                "  orcvlr    ) "                  ,   
                "  values (?,?,?,?,?,?)"         
    prepare p_cts10g14_003  from l_sql                           
                                
    
    let l_sql = " select count(*)     "  ,  
                " from datmpedvist    "  ,                                            
                " where sinvstnum = ? "  ,                 
                " and sinvstano   = ? "     
    prepare p_cts10g14_004  from l_sql
    declare c_cts10g14_004  cursor for p_cts10g14_004 
    
    
    let l_sql = " update datmpedvist set",
                " sindat    = ?,   ",  
                " sinhor    = ?,   ",
                " dddcod    = ?,   ",
                " teltxt    = ?,   ",
                " lclrsccod = ?,   ",
                " lclendflg = ?,   ",
                " lgdtip    = ?,   ",
                " lgdnom    = ?,   ",
                " lgdnum    = ?,   ",
                " endufd    = ?,   ",
                " lgdnomcmp = ?,   ",
                " endbrr    = ?,   ",
                " endcid    = ?,   ",
                " endcep    = ?,   ",
                " endcepcmp = ?,   ",
                " endddd    = ?,   ",
                " teldes    = ?,   ",
                " lclcttnom = ?,   ",
                " endrefpto = ?,   ",
                " sinhst    = ?,   ",
                " sinobs    = ?,   ",
                " sinvstdat = ?,   ",
                " sinvsthor = ?,   ",
                " rglvstflg = ?,   ",
                " lclnumseq = ?,   ",
                " rmerscseq = ?    ",
                " where sinvstnum = ? ",
                " and   sinvstano = ? "
    prepare p_cts10g14_005  from l_sql 	
                                         
    let l_sql = " update datrpedvistnatcob set  " ,                                                                                    
                "  cbttip    =? , "               ,                                                                               
                "  sinntzcod =? , "               ,                                         
                "  orcvlr    =?  "                ,                                         
                "  where sinvstnum = ? "          ,
                "  and   sinvstano = ? "                                                  
    prepare p_cts10g14_006  from l_sql                                                      
    	      
    
    let m_prepare = true 

end function        
#-----------------------------------------------------------------------------
 function cts10g14_recupera_grupo_ramo(lr_param)                                           
#-----------------------------------------------------------------------------

define lr_param record
  empcod like gtakram.empcod,
  ramcod like gtakram.ramcod 
end record

define lr_retorno record
  sinramgrp like gtakram.sinramgrp,
  erro      integer               ,     
  mensagem  char(70)
end record

initialize lr_retorno.* to null

 if m_prepare is null or   

   m_prepare <> true then 

   call cts10g14_prepare()

end if                    

 whenever error continue                                 

open c_cts10g14_001 using  lr_param.empcod     ,   
                           lr_param.ramcod                                       

fetch c_cts10g14_001  into lr_retorno.sinramgrp                                                                             

whenever error stop                                     

 if sqlca.sqlcode <> 0 then                                

    let lr_retorno.mensagem = "ERRO AO CONSULTAR O GRUPO DO RAMO"    

    let lr_retorno.erro = sqlca.sqlcode                                      

end if                                                      

 return lr_retorno.sinramgrp,
        lr_retorno.erro     ,
        lr_retorno.mensagem 

end function

#-----------------------------------------------------------------------------
function cts10g14_inclui_pedido_vistoria(lr_param)                               
#-----------------------------------------------------------------------------
                                                                              
define lr_param record                                                        
  sinvstnum     like datmpedvist.sinvstnum     ,   
  sinvstano     like datmpedvist.sinvstano     ,   
  vstsolnom     like datmpedvist.vstsolnom     ,   
  vstsoltip     like datmpedvist.vstsoltip     ,   
  vstsoltipcod  like datmpedvist.vstsoltipcod  ,
  sindat        like datmpedvist.sindat        ,   
  sinhor        like datmpedvist.sinhor        ,   
  segnom        like datmpedvist.segnom        ,   
  cornom        like datmpedvist.cornom        ,   
  dddcod        like datmpedvist.dddcod        ,   
  teltxt        like datmpedvist.teltxt        ,   
  funmat        like datmpedvist.funmat        ,   
  sinntzcod     like datmpedvist.sinntzcod     ,   
  lclrsccod     like datmpedvist.lclrsccod     ,   
  lclendflg     like datmpedvist.lclendflg     ,   
  lgdtip        like datmpedvist.lgdtip        ,   
  lgdnom        like datmpedvist.lgdnom        ,   
  lgdnum        like datmpedvist.lgdnum        ,   
  endufd        like datmpedvist.endufd        ,   
  lgdnomcmp     like datmpedvist.lgdnomcmp     ,   
  endbrr        like datmpedvist.endbrr        ,   
  endcid        like datmpedvist.endcid        ,   
  endcep        like datmpedvist.endcep        ,   
  endcepcmp     like datmpedvist.endcepcmp     ,   
  endddd        like datmpedvist.endddd        ,   
  teldes        like datmpedvist.teldes        ,   
  lclcttnom     like datmpedvist.lclcttnom     ,   
  endrefpto     like datmpedvist.endrefpto     ,   
  sinhst        like datmpedvist.sinhst        ,   
  sinobs        like datmpedvist.sinobs        ,   
  vstsolstt     like datmpedvist.vstsolstt     ,   
  sinvstdat     like datmpedvist.sinvstdat     ,   
  sinvsthor     like datmpedvist.sinvsthor     ,   
  rglvstflg     like datmpedvist.rglvstflg     ,   
  sinramgrp     like datmpedvist.sinramgrp     ,   
  lclnumseq     like datmpedvist.lclnumseq     ,   
  rmerscseq     like datmpedvist.rmerscseq                                        
end record                                                                    
                                                                              
define lr_retorno record                                                                                                
  erro      integer ,                                           
  mensagem  char(70)                                                          
end record                                                                    
                                                                              
initialize lr_retorno.* to null                                               
                                                                              
 if m_prepare is null or                                                     
   m_prepare <> true then                                                    
   call cts10g14_prepare()                                                   
 end if                       

 display " PARAMETROS sinvstnum ....:" , lr_param.sinvstnum
 display " PARAMETROS sinvstano ....:" , lr_param.sinvstano
 display " PARAMETROS vstsolnom ....:" , lr_param.vstsolnom
 display " PARAMETROS vstsoltip ....:" , lr_param.vstsoltip
 display " PARAMETROS segnom ....:" , lr_param.segnom   
 display " PARAMETROS funmat ....:" , lr_param.funmat   
 display " PARAMETROS sinntzcod ....:" , lr_param.sinntzcod
 display " PARAMETROS sinramgrp ....:" , lr_param.sinramgrp
 display " PARAMETROS sinvstdat ....:" , lr_param.sinvstdat

 whenever error continue                                           
 execute p_cts10g14_002 using lr_param.sinvstnum    ,          
                              lr_param.sinvstano    ,        
                              lr_param.vstsolnom    ,        
                              lr_param.vstsoltip    ,        
                              lr_param.vstsoltipcod ,        
                              lr_param.sindat       ,        
                              lr_param.sinhor       ,        
                              lr_param.segnom       ,        
                              lr_param.cornom       ,        
                              lr_param.dddcod       ,                                                                        
                              lr_param.teltxt       ,
                              lr_param.funmat       ,
                              lr_param.sinntzcod    ,
                              lr_param.lclrsccod    ,
                              lr_param.lclendflg    ,
                              lr_param.lgdtip       ,
                              lr_param.lgdnom       ,
                              lr_param.lgdnum       ,
                              lr_param.endufd       ,
                              lr_param.lgdnomcmp    ,
                              lr_param.endbrr       ,
                              lr_param.endcid       ,
                              lr_param.endcep       ,
                              lr_param.endcepcmp    ,
                              lr_param.endddd       ,
                              lr_param.teldes       ,
                              lr_param.lclcttnom    ,
                              lr_param.endrefpto    ,
                              lr_param.sinhst       ,
                              lr_param.sinobs       ,
                              lr_param.vstsolstt    ,
                              lr_param.sinvstdat    ,
                              lr_param.sinvsthor    ,
                              lr_param.rglvstflg    ,
                              lr_param.sinramgrp    ,
                              lr_param.lclnumseq    ,
                              lr_param.rmerscseq   
                                                         
 whenever error stop                                               
                                                                  
 if sqlca.sqlcode <> 0 then                                        
      let lr_retorno.mensagem = "ERRO AO INSERIR O PEDIDO DE VISTORIA"                                                  
      let lr_retorno.erro = sqlca.sqlcode                                                                         
 end if                                                              
                                                                              
 return lr_retorno.erro     ,                                                 
        lr_retorno.mensagem                                                   
                                                                              
end function

#----------------------------------------------------------------------------- 
 function cts10g14_inclui_cobertura_natureza(lr_param)                              
#----------------------------------------------------------------------------- 

define lr_param record
   sinvstnum   like datrpedvistnatcob.sinvstnum , 
   sinvstano   like datrpedvistnatcob.sinvstano ,
   cbttip      like datrpedvistnatcob.cbttip    ,
   sinramgrp   like datrpedvistnatcob.sinramgrp ,
   sinntzcod   like datrpedvistnatcob.sinntzcod ,
   orcvlr      like datrpedvistnatcob.orcvlr    
end record

define lr_retorno record                 
  erro      integer  ,      
  mensagem  char(70)                     
end record                               
                                         
initialize lr_retorno.* to null          
                                         
 if m_prepare is null or                 
   m_prepare <> true then                
   call cts10g14_prepare()               
 end if                                  
  
 whenever error continue                               
 execute p_cts10g14_003 using lr_param.sinvstnum  ,  
                              lr_param.sinvstano  ,  
                              lr_param.cbttip     ,  
                              lr_param.sinramgrp  ,  
                              lr_param.sinntzcod  ,  
                              lr_param.orcvlr      
                        
 whenever error stop                                                    
                                                                         
 if sqlca.sqlcode <> 0 then                                             
      let lr_retorno.mensagem = "ERRO AO INSERIR A COBERTURA X NATUREZA"  
      let lr_retorno.erro = sqlca.sqlcode                               
 end if                                                                 
                                                                         
 return lr_retorno.erro     ,                                           
        lr_retorno.mensagem                                             
                                                                           
end function                                                                               

#-----------------------------------------------------------------------------  
function cts10g14_xmlerro(lr_param)                                                
#-----------------------------------------------------------------------------  
                                                                                
   define lr_param   record                                                        
      servico char(100)  ,                                                     
      erro    smallint   ,                                                   
      msgerro char (1000)                                                   
   end record                                                                   
                                                                                
   define l_xml   char(2000)                                                    

   display "-----------------------------------------------------------"
   display "                   CTS10G14 - XMLERRO                      "
   display "-----------------------------------------------------------"
   display "servico.................:",lr_param.servico
   display "erro   .................:",lr_param.erro   
   display "msgerro.................:",lr_param.msgerro
   
   let l_xml  = null                                                            
                                                                                
   let l_xml = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",  
               "<RESPONSE>",                                                    
               "<SERVICO>"   ,lr_param.servico ,"</SERVICO>" ,             
               "<ERRO>",                                                        
               "<CODIGO>"    ,lr_param.erro using '<<<<',"</CODIGO>" ,  
               "<DESCRICAO>" ,lr_param.msgerro ,"</DESCRICAO>",             
               "</ERRO>",                                                       
               "</RESPONSE>"       
               
   display "l_xml  .................:",l_xml   
   display "-----------------------------------------------------------"
   display "                    FIM CTS10G14 - XMLERRO                 "
   display "-----------------------------------------------------------"

   return l_xml                                                                 
                                                                                
end function

#-----------------------------------------------------------------------------  
function cts10g14_sucesso_msg1(lr_param)                                                
#-----------------------------------------------------------------------------  
                                                                                
   define lr_param   record                                                        
      servico char(100)                ,                                                                                                 
      msg     char(1000)               ,
      lignum  like datmligacao.lignum  ,
      atdnum  like datratdlig.atdnum                                                        
   end record                                                                   
                                                                                
   define l_xml   char(2000)                                                    
                                                                                
   let l_xml  = null                                                            
                                                                                
   let l_xml = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",  
               "<RESPONSE>",                                                    
               "<SERVICO>"     ,lr_param.servico clipped ,"</SERVICO>" ,             
               "<SUCESSO>",                                                        
               "<LIGACAO>"     ,lr_param.lignum  clipped using '<<<<<<<<<<' ,"</LIGACAO>" ,  
               "<ATENDIMENTO>" , lr_param.atdnum clipped using '<<<<<<<<<<' ,"</ATENDIMENTO>",
               "<DESCRICAO>"   ,lr_param.msg clipped     ,"</DESCRICAO>",             
               "</SUCESSO>",                                                       
               "</RESPONSE>"                                                    
                                                                                
   return l_xml                                                                 
                                                                                
end function

#-----------------------------------------------------------------------------          
 function cts10g14_valida_documento(lr_param)                                
#-----------------------------------------------------------------------------                                                                                                                                                    
define lr_param record                                                               
   semdocto   char(01)                   ,
   succod     like datrligapol.succod    ,  
   ramcod     like datrservapol.ramcod   ,  
   aplnumdig  like datrligapol.aplnumdig ,  
   prporg     like datrligprp.prporg     ,    
   prpnumdig  like datrligprp.prpnumdig  ,                                     
   corsus     like datmservico.corsus    ,                                   
   dddcod     like datmreclam.dddcod     ,    
   ctttel     like datmreclam.ctttel     ,
   funmat     like isskfunc.funmat       ,
   usrtip     like isskusuario.usrtip    ,
   empcod     like isskusuario.empcod    ,
   cgccpfnum  like gsakseg.cgccpfnum     ,
   cgcord     like gsakseg.cgcord        ,
   cgccpfdig  like gsakseg.cgccpfdig     ,
   sinvstnum  like datmpedvist.sinvstnum , 
   sinvstano  like datmpedvist.sinvstano                                               
end record                                                                           
                                                                                     
define lr_retorno record                                                             
  erro      integer  ,                                                               
  mensagem  char(70)                                                                 
end record                                                                           
                                                                                     
initialize lr_retorno.* to null                                                      
                                                                                     
let lr_retorno.erro     = 0   
   display "-----------------------------------------------------------"
   display "                   CTS10G14 - VALIDA DOCUMENTO             "
   display "-----------------------------------------------------------"

if lr_param.sinvstnum is null or
   lr_param.sinvstano is null then
   let lr_retorno.erro     = 1                                         
   let lr_retorno.mensagem = "VISTORIA DE SINISTRO NULO!"  

   display " mensagem 1.................:",lr_retorno.mensagem clipped
     
   return lr_retorno.erro     ,   
          lr_retorno.mensagem     

end if


if lr_param.ramcod is null then
     
    let lr_retorno.erro = 1                                 
    let lr_retorno.mensagem = "RAMO NULO!"  
    
    display " mensagem 2.................:",lr_retorno.mensagem clipped
   
    return lr_retorno.erro     ,                            
           lr_retorno.mensagem                            

end if


if lr_param.semdocto = "S" then  
   if (lr_param.corsus    is null) and
      (lr_param.dddcod    is null  or   
       lr_param.ctttel    is null) and
      (lr_param.funmat    is null  or
       lr_param.usrtip    is null  or
       lr_param.empcod    is null) and
      (lr_param.cgccpfnum is null  or
       lr_param.cgcord    is null  or
       lr_param.cgccpfdig is null) then
      
          let lr_retorno.erro = 1
          let lr_retorno.mensagem = "PARAMETROS DO SEM DOCUMENTO NULOS!"  
          
          display " mensagem 3.................:",lr_retorno.mensagem clipped
    else    
    	  let g_documento.corsus    = lr_param.corsus 
    	  let g_documento.dddcod    = lr_param.dddcod
    	  let g_documento.ctttel    = lr_param.ctttel
    	  let g_documento.cgccpfnum = lr_param.cgccpfnum
    	  let g_documento.cgcord    = lr_param.cgcord   
    	  let g_documento.cgccpfdig = lr_param.cgccpfdig
    	    
    	  if lr_param.funmat is not null then
    	  	 let g_documento.funmat = lr_param.funmat
    	  end if 	 	    
    end if      
else            
                  
   if (lr_param.succod     is null   or                                                                               
       lr_param.aplnumdig  is null ) and
      (lr_param.prporg     is null   or   
       lr_param.prpnumdig  is null ) then                                    
         
         let lr_retorno.erro = 1                                             
         let lr_retorno.mensagem = "PARAMETROS DE APOLICE OU PROPOSTA NULO!" 
         
         display " mensagem 4.................:",lr_retorno.mensagem clipped
                     
   else
   	  
   	  let g_documento.succod     = lr_param.succod      
   	  let g_documento.aplnumdig  = lr_param.aplnumdig 
   	  let g_documento.prporg     = lr_param.prporg    
   	  let g_documento.prpnumdig  = lr_param.prpnumdig 
                                                                                                                            
   end if                                                                            
                                                                                                
end if    

let g_documento.ramcod  = lr_param.ramcod        
                                                                                               
 return lr_retorno.erro     ,                                                        
        lr_retorno.mensagem                                                          
                                                                                     
end function   


#----------------------------------------------------------------------------- 
 function cts10g14_recupera_pedido_aviso_re(lr_param)                              
#----------------------------------------------------------------------------- 

define lr_param record
   sinvstnum    like datmpedvist.sinvstnum      ,                                 
   sinvstano    like datmpedvist.sinvstano           
end record

define lr_retorno record                 
  erro       integer                    ,      
  mensagem   char(70)                   ,
  qtd        integer                    
end record                               
                                         
initialize lr_retorno.* to null          
                                        
 if m_prepare is null or                 
    m_prepare <> true then                
   call cts10g14_prepare()               
 end if                                  
 
 whenever error continue                               
 open c_cts10g14_004 using lr_param.sinvstnum   ,  
                           lr_param.sinvstano   
 fetch c_cts10g14_004 into lr_retorno.qtd  
                                                 
                                                                                 
 whenever error stop                                                                                                               
                                                                         
 if lr_retorno.qtd  = 0 then
 	  let sqlca.sqlcode = -1
 end if
 
 if sqlca.sqlcode <> 0 then                                             
      let lr_retorno.mensagem = "NUMERO DA VISTORIA NAO ENCONTRADO!"  
      let lr_retorno.erro = sqlca.sqlcode                               
 end if                                                                 
                                                                         
 return lr_retorno.erro       ,                                           
        lr_retorno.mensagem                                             
                                                                           
end function  


#-----------------------------------------------------------------------------                                                                               
function cts10g14_sucesso_msg2(lr_param)                                                         
#-----------------------------------------------------------------------------                   
                                                                                                 
   define lr_param   record                                                                      
      servico    char(100)                  ,                                                         
      msg        char(1000)                 ,                                                         
      lignum     like datmligacao.lignum    ,                                                         
      atdnum     like datratdlig.atdnum     ,
      atdsrvano  like datmservico.atdsrvano , 
      atdsrvnum  like datmservico.atdsrvnum                                                        
   end record                                                                                    
                                                                                                 
   define l_xml   char(2000)                                                                     
                                                                                                 
   let l_xml  = null                                                                             
                                                                                                 
   let l_xml = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>",                   
               "<RESPONSE>",                                                                     
               "<SERVICO>"     ,lr_param.servico clipped ,"</SERVICO>" ,                         
               "<SUCESSO>",                                                                      
               "<LIGACAO>"     ,lr_param.lignum  clipped using '<<<<<<<<<<' ,"</LIGACAO>" ,      
               "<ATENDIMENTO>" , lr_param.atdnum clipped using '<<<<<<<<<<' ,"</ATENDIMENTO>",   
               "<NUMERODOSERVICO>", lr_param.atdsrvnum clipped using '<<<<<<<<<<', "</NUMERODOSERVICO>",
               "<ANODOSERVICO>",    lr_param.atdsrvano clipped using '<<' ,        "</ANODOSERVICO>", 
               "<DESCRICAO>"   ,lr_param.msg clipped     ,"</DESCRICAO>",                        
               "</SUCESSO>",                                                                     
               "</RESPONSE>"                                                                     
                                                                                                 
   return l_xml                                                                                  
                                                                                                 
end function

#-----------------------------------------------------------------------------
 function cts10g14_altera_pedido_vistoria(lr_param)                               
#-----------------------------------------------------------------------------
                                                                              
define lr_param record                                                        
  sinvstnum     like datmpedvist.sinvstnum     ,  
  sinvstano     like datmpedvist.sinvstano     ,  
  sindat        like datmpedvist.sindat        ,  
  sinhor        like datmpedvist.sinhor        ,  
  dddcod        like datmpedvist.dddcod        ,  
  teltxt        like datmpedvist.teltxt        ,  
  lclrsccod     like datmpedvist.lclrsccod     ,  
  lclendflg     like datmpedvist.lclendflg     ,  
  lgdtip        like datmpedvist.lgdtip        ,  
  lgdnom        like datmpedvist.lgdnom        ,  
  lgdnum        like datmpedvist.lgdnum        ,  
  endufd        like datmpedvist.endufd        ,  
  lgdnomcmp     like datmpedvist.lgdnomcmp     ,  
  endbrr        like datmpedvist.endbrr        ,  
  endcid        like datmpedvist.endcid        ,  
  endcep        like datmpedvist.endcep        ,  
  endcepcmp     like datmpedvist.endcepcmp     ,  
  endddd        like datmpedvist.endddd        ,  
  teldes        like datmpedvist.teldes        ,  
  lclcttnom     like datmpedvist.lclcttnom     ,  
  endrefpto     like datmpedvist.endrefpto     ,  
  sinhst        like datmpedvist.sinhst        ,  
  sinobs        like datmpedvist.sinobs        ,  
  sinvstdat     like datmpedvist.sinvstdat     ,  
  sinvsthor     like datmpedvist.sinvsthor     ,  
  rglvstflg     like datmpedvist.rglvstflg     ,  
  lclnumseq     like datmpedvist.lclnumseq     ,  
  rmerscseq     like datmpedvist.rmerscseq                                     
end record                                                                    
                                                                              
define lr_retorno record                                                                                                
  erro      integer ,                                           
  mensagem  char(70)                                                          
end record                                                                    
                                                                              
initialize lr_retorno.* to null                                               
                                                                              
 if m_prepare is null or                                                     
   m_prepare <> true then                                                    
   call cts10g14_prepare()                                                   
 end if                                                                       
                                                                              
 whenever error continue                                           
 execute p_cts10g14_005 using lr_param.sindat       ,        
                              lr_param.sinhor       ,        
                              lr_param.dddcod       ,                                                                        
                              lr_param.teltxt       ,
                              lr_param.lclrsccod    ,
                              lr_param.lclendflg    ,
                              lr_param.lgdtip       ,
                              lr_param.lgdnom       ,
                              lr_param.lgdnum       ,
                              lr_param.endufd       ,
                              lr_param.lgdnomcmp    ,
                              lr_param.endbrr       ,
                              lr_param.endcid       ,
                              lr_param.endcep       ,
                              lr_param.endcepcmp    ,
                              lr_param.endddd       ,
                              lr_param.teldes       ,
                              lr_param.lclcttnom    ,
                              lr_param.endrefpto    ,
                              lr_param.sinhst       ,
                              lr_param.sinobs       ,
                              lr_param.sinvstdat    ,
                              lr_param.sinvsthor    ,
                              lr_param.rglvstflg    ,
                              lr_param.lclnumseq    ,
                              lr_param.rmerscseq    ,
                              lr_param.sinvstnum    ,    
                              lr_param.sinvstano                                 
 whenever error stop                                               
                                                                  
 if sqlca.sqlcode <> 0 then                                        
      let lr_retorno.mensagem = "ERRO AO ALTERAR O PEDIDO DE VISTORIA"                                                  
      let lr_retorno.erro = sqlca.sqlcode                                                                         
 end if                                                              
                                                                              
 return lr_retorno.erro     ,                                                 
        lr_retorno.mensagem                                                   
                                                                              
end function   

#-----------------------------------------------------------------------------                                                                                        
 function cts10g14_altera_cobertura_natureza(lr_param)                              
#-----------------------------------------------------------------------------      
                                                                                    
define lr_param record                                                              
   sinvstnum   like datrpedvistnatcob.sinvstnum ,                                   
   sinvstano   like datrpedvistnatcob.sinvstano ,                                   
   cbttip      like datrpedvistnatcob.cbttip    ,                                                            
   sinntzcod   like datrpedvistnatcob.sinntzcod ,                                   
   orcvlr      like datrpedvistnatcob.orcvlr                                        
end record                                                                          
                                                                                    
define lr_retorno record                                                            
  erro      integer  ,                                                              
  mensagem  char(70)                                                                
end record                                                                          
                                                                                    
initialize lr_retorno.* to null                                                     
                                                                                    
 if m_prepare is null or                                                            
   m_prepare <> true then                                                           
   call cts10g14_prepare()                                                          
 end if                                                                             
                                                                                    
 whenever error continue                                                            
 execute p_cts10g14_006 using lr_param.cbttip     ,                                                            
                              lr_param.sinntzcod  ,                                 
                              lr_param.orcvlr     ,
                              lr_param.sinvstnum  ,                                        
                              lr_param.sinvstano                                                       
 whenever error stop                                                              
                                                                                    
 if sqlca.sqlcode <> 0 then                                                         
      let lr_retorno.mensagem = "ERRO AO ALTERAR A COBERTURA X NATUREZA"            
      let lr_retorno.erro = sqlca.sqlcode                                           
 end if                                                                             
                                                                                    
 return lr_retorno.erro     ,                                                       
        lr_retorno.mensagem                                                         
                                                                                    
end function                                                                        
                                                                                    
