################################################################################
# Porto Seguro Cia Seguros Gerais                                      Nov/2010#
# .............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : cty05g08                                                     #
# Analista Resp.: Amilton Pinto                                                #
# PSI           :                                                              #
# Objetivo      : Busca de Servico pelo portal de voz      #
# .............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
# ----------  -------------- --------- ----------------------------------------#
#                                                                              #
################################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"

database porto
    
define m_cty05g08_prepare smallint 
define m_xml char(32766)
define m_erro record 
       servico char(300),
       coderro smallint, 
       mens    char(4000)
end record

define m_servico array[30] of record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano,
    segnom    like gsakseg.segnom,       
    socntzdes like datksocntz.socntzdes, 
    c24pbmdes like datkpbm.c24pbmdes,    
    data      like datmservico.atddat,   
    hora      like datmservico.atdhor    
end record       

define m_qtd_servico array[30] of record
    atdsrvnum like datmservico.atdsrvnum,
    atdsrvano like datmservico.atdsrvano
end record       

                               

function cty05g08_prepare()

define l_sql char(2000)
    
 let l_sql = " select segnumdig ",             
             " from abbmdoc     ",                                        
             " where succod    =  ?  and ",
             "       aplnumdig =  ?  and ",
             "       itmnumdig =  ?  and ",
             "       dctnumseq =  ? "

 prepare pcty05g08001 from l_sql                           
 declare ccty05g08001 cursor with hold for pcty05g08001
 
 let l_sql = " select segnom ",
             " from gsakseg ",
             " where gsakseg.segnumdig  =  ? "
 
 prepare pcty05g08002 from l_sql                           
 declare ccty05g08002 cursor with hold for pcty05g08002
 
 let l_sql = " select socntzcod ",
             " from datmsrvre ",
             " where atdsrvnum = ?  and ",
             " atdsrvano = ? "

 prepare pcty05g08003 from l_sql                                        
 declare ccty05g08003 cursor with hold for pcty05g08003

 let l_sql = " select socntzdes ",
             " from datksocntz  ",
             " where socntzcod = ? "
 prepare pcty05g08004 from l_sql                                                     
 declare ccty05g08004 cursor with hold for pcty05g08004
 
 let l_sql = " select atddfttxt,atddatprg,atdhorprg, ",   
             " atddat,atdhor ",
             " from datmservico  " ,                       
             " where atdsrvnum   = ? ",
             " and atdsrvano    = ? "                          
 
 prepare pcty05g08005 from l_sql                                                                  
 declare ccty05g08005 cursor with hold for pcty05g08005
 
 let l_sql = " select abbmveic.succod,",
             " abbmveic.aplnumdig, ",
             " abbmveic.itmnumdig, ",             
             " max(abbmveic.dctnumseq), ",
             " abamapol.vigfnl ",
             " from  abbmveic ",
             "      ,abamapol ",
             " where abbmveic.vcllicnum = ? ",
             "   and abamapol.succod    = abbmveic.succod ",
             "   and abamapol.aplnumdig = abbmveic.aplnumdig ",                    
             " group by abbmveic.succod, abbmveic.aplnumdig, ",
             " abbmveic.itmnumdig,abamapol.vigfnl",
             " order by 5 desc "

 prepare pcty05g08006 from l_sql              
 declare ccty05g08006 cursor with hold for pcty05g08006 

 let l_sql = " select etpnumdig,aplstt,viginc,vigfnl ", 
             " from  abamapol ",
             " where abamapol.succod    = ? ",
             " and   abamapol.aplnumdig = ? "
 prepare pcty05g08007 from l_sql              
 declare ccty05g08007 cursor with hold for pcty05g08007 
 
 let l_sql = " select b.atdsrvnum,b.atdsrvano,a.lignum ",
             " from datrligapol a , datmligacao b ",
             " where ",
             " a.lignum = b.lignum and ",
             " a.succod = ? and ",
             " a.ramcod = ? and ",                                                                     
             " a.aplnumdig = ? and  ",                                               
             " a.itmnumdig = ? and  ",                                                    
             " b.c24astcod in ('S60','S63','S62','S64')"             
 prepare pcty05g08008 from l_sql              
 declare ccty05g08008 cursor with hold for pcty05g08008
 
 let l_sql = " select b.atdsrvnum, b.atdsrvano "   ,                
                " from datrservapol a, datmservico b ",
                " where b.atdsrvnum   =  a.atdsrvnum ",
                " and   b.atdsrvano   =  a.atdsrvano ",
                " and a.succod     =  ? ",
                " and a.ramcod     =  ? ",
                " and a.aplnumdig  =  ? ",
                " and a.itmnumdig  =  ? ",
                " and a.edsnumref >=  0 ",
                " and b.atdsrvorg  = 9   "
 prepare pcty05g08010 from l_sql              
 declare ccty05g08010 cursor with hold for pcty05g08010
 
 
 let l_sql = " select b.atdsrvnum, b.atdsrvano "     ,
            " from datrsrvsau a, datmservico b   "   ,
            " where b.atdsrvnum   =  a.atdsrvnum "   ,
            " and   b.atdsrvano   =  a.atdsrvano "   ,
            " and a.crtnum   =  ? ",
            " and b.atdsrvorg  =  9 "
prepare pcty05g08011 from l_sql                          
declare ccty05g08011 cursor with hold for pcty05g08011 

let l_sql = " select c.atdsrvnum, c.atdsrvano "    ,            
            " from datrligcgccpf a, "               ,
            " datmligacao b, "                      ,
            " datmservico c "                       ,
            " where a.lignum = b.lignum "           ,
            " and b.atdsrvnum = c.atdsrvnum "       ,
            " and b.atdsrvano = c.atdsrvano "       ,
            " and a.cgccpfnum = ? "                 ,
            " and a.cgcord = ? "                    ,
            " and cgccpfdig = ? "                   ,
            " and b.ciaempcod = 40 "                ,
            " and a.crtdvgflg = 'S' "                 ,
            " and b.c24astcod in ('O58','O60','O63')"
prepare pcty05g08012 from l_sql                          
declare ccty05g08012 cursor with hold for pcty05g08012

let l_sql = " select  sgrorg   , sgrnumdig,",                 
            "          rmemdlcod, subcod   ",                        
            "  from  rsamseguro            ",                
            "  where succod    = ? and     ",
            "        ramcod    = ? and     ",
            "        aplnumdig = ?         "
prepare pcty05g08013 from l_sql                          
declare ccty05g08013 cursor with hold for pcty05g08013

let l_sql = " select  segnumdig ",
            " from  rsdmdocto  "  ,                                                                                                   
            " where sgrorg    = ? ",
            " and   sgrnumdig = ? ",
            " and   dctnumseq = (select max(dctnumseq) ",
                               " from  rsdmdocto ",
                               " where sgrorg     = ? ",
                               " and   sgrnumdig  = ? ",
                               " and   prpstt     in (19,65,66,88))" 
prepare pcty05g08014 from l_sql                                                          
declare ccty05g08014 cursor  with hold for pcty05g08014   


let l_sql = " select ciaempcod ",
            " from datmligacao ",
            " where lignum = ? "
prepare pcty05g08015 from l_sql              
declare ccty05g08015 cursor  with hold for pcty05g08015


let l_sql = " select succod "   ,
            ",ramcod "          ,
            ",aplnumdig "       ,
            ",itmnumdig "       ,
            ",edsnumdig "       ,
            " from datkazlapl " ,
            " where cgccpfnum = ? "
prepare p_cty05g08_016  from l_sql
declare c_cty05g08_016  cursor  with hold for p_cty05g08_016

let l_sql = " select b.atdsrvnum, b.atdsrvano, "   ,
            " b.atddat, b.atdsrvorg           "   ,
            " from datrservapol a, datmservico b ",
            " where b.atdsrvnum   =  a.atdsrvnum ",
            " and   b.atdsrvano   =  a.atdsrvano ",
            " and a.succod     =  ? ",
            " and a.ramcod     =  ? ",
            " and a.aplnumdig  =  ? ",
            " and a.itmnumdig  =  ? ",
            " and a.edsnumref >=  0 "
prepare p_cty05g08_017  from l_sql
declare c_cty05g08_017  cursor  with hold for p_cty05g08_017

let l_sql = " select b.atdsrvnum, b.atdsrvano, "  ,
            " b.atddat, b.atdsrvorg            "  ,
            " from datrservapol a, datmservico b ",
            " where b.atdsrvnum   =  a.atdsrvnum ",
            " and   b.atdsrvano   =  a.atdsrvano ",
            " and a.succod     =  ? ",
            " and a.ramcod     =  ? ",
            " and a.aplnumdig  =  ? ",
            " and a.itmnumdig  =  ? ",
            " and a.edsnumref >=  0 ",
            " and b.atdsrvorg  =  9 "
prepare p_cty05g08_018  from l_sql
declare c_cty05g08_018  cursor  with hold for p_cty05g08_018

let l_sql = " select succod "   ,
            ",ramcod "          ,
            ",aplnumdig "       ,
            ",crtsaunum "       ,
            ",crtstt    "       ,
            ",bnfnum    "       ,
            " from datksegsau " ,
            " where cgccpfnum = ? "
prepare p_cty05g08_019  from l_sql
declare c_cty05g08_019  cursor  with hold for p_cty05g08_019

let l_sql = " select b.atdsrvnum, b.atdsrvano, "     ,
            " b.atddat, b.atdsrvorg            "     ,
            " from datrsrvsau a, datmservico b   "   ,
            " where b.atdsrvnum   =  a.atdsrvnum "   ,
            " and   b.atdsrvano   =  a.atdsrvano "   ,
            " and a.crtnum   =  ? ",
            " and b.atdsrvorg  =  9 "
prepare p_cty05g08_020 from l_sql
declare c_cty05g08_020 cursor  with hold for p_cty05g08_020

let l_sql = " select b.atdsrvnum, b.atdsrvano,   "   ,
            " b.atddat, b.atdsrvorg              "   ,
            " from datrsrvsau a, datmservico b   "   ,
            " where b.atdsrvnum   =  a.atdsrvnum "   ,
            " and   b.atdsrvano   =  a.atdsrvano "   ,
            " and a.crtnum   =  ? "
prepare p_cty05g08_021 from l_sql
declare c_cty05g08_021 cursor  with hold for p_cty05g08_021

let l_sql = " select cpodes "    ,
            " from iddkdominio  "   ,
            " where cpocod = ? "   ,
            " and   cponom = 'sitprod' "
prepare pcty05g08_022 from l_sql
declare ccty05g08_022 cursor  with hold for pcty05g08_022

let l_sql = " select c.atdsrvnum, c.atdsrvano, "    ,
            " c.atddat, c.atdsrvorg            "    ,
            " from datrligcgccpf a, "               ,
            " datmligacao b, "                      ,
            " datmservico c "                       ,
            " where a.lignum = b.lignum "           ,
            " and b.atdsrvnum = c.atdsrvnum "       ,
            " and b.atdsrvano = c.atdsrvano "       ,
            " and a.cgccpfnum = ? "                 ,
            " and a.cgcord = ? "                    ,
            " and cgccpfdig = ? "                   ,
            " and b.ciaempcod = 40 "                ,
            " and b.c24astcod not in ('CON','ALT','REC','CAN','RET','IND')"
prepare pcty05g08_023 from l_sql
declare ccty05g08_023 cursor  with hold for pcty05g08_023



let l_sql = " select b.atdsrvnum, b.atdsrvano,    ",                           
            " b.atddat, b.atdsrvorg               ",                           
            " from datrservapol a, datmservico b, ",                           
            " datrligitaaplitm c, datmligacao d   ",                           
            " where b.atdsrvnum   =  a.atdsrvnum  ",                           
            " and   b.atdsrvano   =  a.atdsrvano  ",                           
            " and   b.atdsrvnum   =  d.atdsrvnum  ",                           
            " and   b.atdsrvano   =  d.atdsrvano  ",                           
            " and   d.lignum = c.lignum           ",                                        
            " and a.succod     =  ? ",                                         
            " and a.ramcod     =  ? ",                                         
            " and a.aplnumdig  =  ? ",                                         
            " and a.itmnumdig  =  ? ",                                         
            " and a.edsnumref >=  0 ",                                         
            " and c.itaciacod  =  ? ",                                                                              
            " and d.c24astcod not in ('CON','ALT','REC','CAN','RET','IND') "   
prepare p_cty05g08_024  from l_sql
declare c_cty05g08_024  cursor  with hold for p_cty05g08_024

let l_sql = " select b.atdsrvnum, b.atdsrvano,    ", 
            " b.atddat, b.atdsrvorg               ", 
            " from datrservapol a, datmservico b, ", 
            " datrligitaaplitm c, datmligacao d   ", 
            " where b.atdsrvnum   =  a.atdsrvnum  ", 
            " and   b.atdsrvano   =  a.atdsrvano  ", 
            " and   b.atdsrvnum   =  d.atdsrvnum  ",
            " and   b.atdsrvano   =  d.atdsrvano  ",
            " and   d.lignum = c.lignum           ",     
            " and a.succod     =  ? ",               
            " and a.ramcod     =  ? ",               
            " and a.aplnumdig  =  ? ",               
            " and a.itmnumdig  =  ? ",               
            " and a.edsnumref >=  0 ",               
            " and c.itaciacod  =  ? ",
            " and b.atdsrvorg  =  9 ",  
            " and d.c24astcod not in ('CON','ALT','REC','CAN','RET','IND') "         
prepare p_cty05g08_025  from l_sql                   
declare c_cty05g08_025  cursor  with hold for p_cty05g08_025   

let l_sql = " select cidnom,ufdcod ",                 
            " from datmlcl ",                 
            " where ",
            " atdsrvnum   =  ?  ", 
            " and   atdsrvano = ? ",
            " and c24endtip = 1"               
prepare p_cty05g08_026  from l_sql                   
declare c_cty05g08_026  cursor with hold for p_cty05g08_026 
 
let l_sql = " select c24astcod ",                 
            " from datmligacao ",                         
            " where ",                                 
            " lignum = ? "                                
prepare p_cty05g08_027  from l_sql                     
declare c_cty05g08_027  cursor with hold for p_cty05g08_027

let l_sql = " select pesnom from gsakpes   ",
            " where  ",                 
            " pestip = ? ",
            " and cgccpfnum = ? ",
            " and cgcord = ? ",
            " and cgccpfdig =  ?"
prepare p_cty05g08_030  from l_sql                                     
declare c_cty05g08_030  cursor with hold for p_cty05g08_030     

let l_sql = "select c24astcod from datmligacao ",
            " where  ",
            " lignum = ? "

prepare p_cty05g08_031  from l_sql                                                 
declare c_cty05g08_031  cursor with hold for p_cty05g08_031 

let l_sql = "select atdsrvnum,atdsrvano from datmsrvre ",           
            " where  ",                                     
            " atdorgsrvnum = ? and ",
            " atdorgsrvano = ? "                                                                                                

prepare p_cty05g08_032  from l_sql                          
declare c_cty05g08_032  cursor with hold for p_cty05g08_032

let l_sql = "select socntzcod from datmsrvre ",             
            " where  ",                                    
            " atdsrvnum = ? and ",                      
            " atdsrvano = ? "                           
                                                           
prepare p_cty05g08_033  from l_sql                         
declare c_cty05g08_033  cursor with hold for p_cty05g08_033

let l_sql = "select socntzgrpcod from datksocntz ",             
            " where  ",                                                 
            " socntzcod = ? "
                                                            
prepare p_cty05g08_034  from l_sql                          
declare c_cty05g08_034  cursor with hold for p_cty05g08_034


let l_sql = "select socntzgrpdes from datksocntzgrp ",             
            " where  ",                                                  
            " socntzgrpcod = ? "                                                                         
prepare p_cty05g08_035  from l_sql                                       
declare c_cty05g08_035  cursor with hold for p_cty05g08_035

let l_sql = " select count(*) from datmservico a,datmligacao b ",
            " where ",
            " a.atdsrvnum = b.atdsrvnum and ",
            " a.atdsrvano = b.atdsrvano and ",            
            " a.atdsrvnum = ? ", 
            " and b.ligdat >= today - 90 ",
            #" and a.atdsrvano = ? ",
            " and b.c24astcod in ('S60','S62','S63','S64') "

prepare p_cty05g08_036  from l_sql                                                   
declare c_cty05g08_036  cursor with hold for p_cty05g08_036

let l_sql = " select count(*) from datmservico a,datmligacao b ",
            " where ",                                          
            " a.atdsrvnum = b.atdsrvnum and ",                  
            " a.atdsrvano = b.atdsrvano and ",                  
            " a.atdsrvnum = ? ",                                
            " and a.atdsrvano = ? ",                           
            " and b.c24astcod in ('S60','S62','S63','S64') "    
                                                                
prepare p_cty05g08_037  from l_sql                              
declare c_cty05g08_037  cursor with hold for p_cty05g08_037

let l_sql = " select a.atdsrvnum,a.atdsrvano from datmservico a,datmligacao b ",
            " where ",                                          
            " a.atdsrvnum = b.atdsrvnum and ",                  
            " a.atdsrvano = b.atdsrvano and ",                  
            " a.atdsrvnum = ? ",                                
            " and b.ligdat >= today - 90 ",                                
            " and b.c24astcod in ('S60','S62','S63','S64') "    
                                                                
prepare p_cty05g08_038  from l_sql                              
declare c_cty05g08_038  cursor with hold for p_cty05g08_038     



              
                     
let  m_cty05g08_prepare = true 
 
end function  

function cty05g08_prepare_temp()

    define l_comando char(400)
              
    let l_comando = "select * from " ,
                    "cty05g08_temp "        

    prepare pcty05g08009 from l_comando
    declare ccty05g08009 cursor for pcty05g08009
                    
    return 0 
    
end function 
  
#-----------------------------------------------------------------------------
function cty05g08_busca_servico(lr_param)
#-----------------------------------------------------------------------------

   define lr_param     record
          atdsrvnum  like datmservico.atdsrvnum,
          atdsrvano  like datmservico.atdsrvano,
          tp_retorno smallint 
   end record

   define l_lignum    like datmligacao.lignum,
          l_segnumdig like gsakseg.segnumdig,
          l_socntzcod like datksocntz.socntzcod,
          l_atddat    like datmservico.atddat,   
          l_atdhor    like datmservico.atdhor, 
          l_atddatprg like datmservico.atddatprg,
          l_atdhorprg like datmservico.atdhorprg,
          l_linha     integer,
          l_data      date,  
          l_hora      datetime hour to minute,
          l_status    smallint,
          l_msg       char(80),
          l_ciaempcod like datmligacao.ciaempcod,
          l_index     integer,
          l_qtde_servico integer
                           


          
   
   define lr_documento record
         ligcvntip                 like datmligacao.ligcvntip,    # Convenio Operacional
         ramcod                    like datrligapol.ramcod,       # Codigo de Ramo
         succod                    like datrligapol.succod,       # Codigo Sucursal   
         aplnumdig                 like datrligapol.aplnumdig,    # Numero Apolice    
         itmnumdig                 like datrligapol.itmnumdig,    # Numero do Item    
         edsnumref                 like datrligapol.edsnumref,    # Numero do Endosso 
         prporg                    like datrligprp.prporg,        # Origem da Proposta
         prpnumdig                 like datrligprp.prpnumdig,     # Numero da Proposta
         fcapacorg                 like datrligpac.fcapacorg,     # Origem PAC        
         fcapacnum                 like datrligpac.fcapacnum,     # Numero PAC                
         bnfnum                    like datksegsau.bnfnum,        # 
         crtsaunum                 like datksegsau.crtsaunum,     # 
         cmnnumdig                 like pptmcmn.cmnnumdig,        #       
         corsus                    like gcaksusep.corsus       ,  # Codigo de Susep
         dddcod                    like datmreclam.dddcod      ,  # Codigo da area de discagem
         ctttel                    like datmreclam.ctttel      ,  # numero do telefone        
         funmat                    like isskfunc.funmat        ,  # matricula do funcionario  
         cgccpfnum                 like gsakseg.cgccpfnum      ,  # numero do CGC(CNPJ)       
         cgcord                    like gsakseg.cgcord         ,  # filial do CGC(CNPJ)       
         cgccpfdig                 like gsakseg.cgccpfdig      ,  # digito do CGC(CNPJ) ou CPF
         crtdvgflg                 like datrligcgccpf.crtdvgflg,
         pss_ligdcttip             like datrligsemapl.ligdcttip, 
         pss_ligdctnum             like datrligsemapl.ligdctnum, 
         pss_dctitm                like datrligsemapl.dctitm   ,
         pss_psscntcod             like kspmcntrsm.psscntcod   ,                               
         cgccpf_ligdctnum          like datrligsemapl.ligdctnum,
         cgccpf_ligdcttip          like datrligsemapl.ligdcttip,
         itaciacod                 like datkitacia.itaciacod
     end record   
     
     define lr_funapol record  
        resultado char(01)      
       ,dctnumseq decimal(04)   
       ,vclsitatu decimal(04)   
       ,autsitatu decimal(04)   
       ,dmtsitatu decimal(04)   
       ,dpssitatu decimal(04)   
       ,appsitatu decimal(04)   
       ,vidsitatu decimal(04)   
     end record  
     
     define lr_retorno record       
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         segnom    like gsakseg.segnom,
         socntzdes like datksocntz.socntzdes,
         c24pbmdes like datkpbm.c24pbmdes,
         data      like datmservico.atddat,
         hora      like datmservico.atdhor  
     end record  
     
     define lr_re record 
            sgrorg       like rsdmdocto.sgrorg,
            sgrnumdig    like rsdmdocto.sgrnumdig 
     end record 
     
     define lr_azul record     
            resultado  smallint , 
            mensagem   char(30) , 
            doc_handle integer  ,
            segnom    like gsakseg.segnom,
            segteltxt like gsakend.teltxt                                       
     end record                          
     
     define lr_cta01m60 record                
           cgccpf     like gsakpes.cgccpfnum ,
           cgcord     like gsakpes.cgcord    ,
           cgccpfdig  like gsakpes.cgccpfdig ,
           pesnom     like gsakpes.pesnom    ,
           pestip     like gsakpes.pestip     
     end record                                                                    
                          
    define l_atdetpcod like datmsrvacp.atdetpcod  
    define l_assunto   like datmligacao.c24astcod
    define l_existe    smallint            
    
    initialize lr_retorno.* to null 
    initialize lr_documento.* to null 
    initialize lr_funapol.* to null 
    initialize lr_re.* to null
    initialize lr_azul.* to null     
    initialize lr_cta01m60.* to null   
    
          
    
    let l_lignum    = null 
    let l_segnumdig = null
    let l_socntzcod = null
    let l_atddat    = null
    let l_atdhor    = null
    let l_atddatprg = null
    let l_atdhorprg = null
    let m_xml       = null
    let l_status    = null       
    let l_msg       = null
    let l_ciaempcod = null  
    let l_atdetpcod = null 
    let l_assunto   = null 
    let l_existe    = null
    let l_index     = 0  
    let l_qtde_servico = 0 
    
                                       
    for l_linha = 1 to 30                      
        initialize m_servico[l_linha].* to null
    end for
    
    let l_linha = 0                                     
    
    call cts40g03_data_hora_banco(2) 
        returning l_data, l_hora
            
    
   display "496 - lr_param.atdsrvnum = ",lr_param.atdsrvnum      
   display "497 - lr_param.atdsrvano = ",lr_param.atdsrvano
   
   let lr_retorno.atdsrvnum = lr_param.atdsrvnum      
   let lr_retorno.atdsrvano = lr_param.atdsrvano      
   
   display "m_cty05g08_prepare = ",m_cty05g08_prepare
   if m_cty05g08_prepare is null or
      m_cty05g08_prepare <> true then
     call cty05g08_prepare()
   end if    
   
   
   call cty05g08_verifica_servico(lr_param.atdsrvnum,
                                  lr_param.atdsrvano)
        returning l_existe
    
    
   display "l_existe = ",l_existe
   
         
   if l_existe = false then
      let m_erro.servico = "IDENTIFICA CLIENTE"                       
      let m_erro.coderro = 2                                          
      let m_erro.mens    = "SERVICO NAO LOCALIZADO"  
      call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
           returning m_xml                                            
      return m_xml                                                    
   end if  
      
   
   if lr_param.atdsrvano is null then    
      call cty05g08_pesquisa_servicos(lr_param.atdsrvnum) 
           returning l_qtde_servico   
   else 
       let l_qtde_servico = 1 
       let m_qtd_servico[1].atdsrvnum = lr_param.atdsrvnum
       let m_qtd_servico[1].atdsrvano = lr_param.atdsrvano
   
   end if    
         
         
   
      if l_qtde_servico = 0 then 
         let m_erro.servico = "IDENTIFICA CLIENTE"                       
         let m_erro.coderro = 2                                          
         let m_erro.mens    = "SERVICO NAO LOCALIZADO"  
         call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
              returning m_xml                                            
         return m_xml 
      else          
   
      for l_index = 1 to l_qtde_servico 
          
          display "m_qtd_servico[l_index].atdsrvano = ", m_qtd_servico[l_index].atdsrvano
          
          let lr_param.atdsrvnum = m_qtd_servico[l_index].atdsrvnum
          let lr_param.atdsrvano = m_qtd_servico[l_index].atdsrvano             
          let lr_retorno.atdsrvnum = lr_param.atdsrvnum
          let lr_retorno.atdsrvano = lr_param.atdsrvano   
          
          
               
      call cty05g08_existe_retorno(lr_param.atdsrvnum,lr_param.atdsrvano)
           returning l_existe
           
      display "585 l_existe = ", l_existe  
      display "656 l_linha = ", l_linha  
           
      if l_existe  = true then 
         let m_erro.servico = "IDENTIFICA CLIENTE"
         let m_erro.coderro = 2
         let m_erro.mens    = "JA EXISTE UM RETORNO PARA ESTE SERVICO "             
         call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
              returning m_xml         
         return m_xml     
      end if          
      
      call cts10g04_ultima_etapa(lr_param.atdsrvnum,lr_param.atdsrvano)
           returning l_atdetpcod 
              
      display "514 - l_atdetpcod =",l_atdetpcod 
      
      if l_atdetpcod = 5 then 
         let m_erro.servico = "IDENTIFICA CLIENTE"
         let m_erro.coderro = 2
         let m_erro.mens    = "ESTE SERVIÇO ESTA CANCELADO "             
         call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
              returning m_xml         
         return m_xml      
      else 
         if l_atdetpcod <> 3 then 
           let m_erro.servico = "IDENTIFICA CLIENTE"
           let m_erro.coderro = 2
           let m_erro.mens    = "SERVIÇO AINDA NAO FOI ACIONADO"             
           call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
                returning m_xml                  
           return m_xml                 
         end if 
      end if          
         
      # Busca ligacao 
      let l_lignum = cts20g00_servico(lr_param.atdsrvnum, lr_param.atdsrvano)
      display "510 - l_lignum = ",l_lignum
      
      # Busca dados da ligacao 
      call cts20g01_docto_tot(l_lignum)
         returning lr_documento.ligcvntip,
                   lr_documento.succod,
                   lr_documento.ramcod,
                   lr_documento.aplnumdig,
                   lr_documento.itmnumdig,
                   lr_documento.edsnumref,
                   lr_documento.prporg,
                   lr_documento.prpnumdig,
                   lr_documento.fcapacorg,
                   lr_documento.fcapacnum,
                   lr_documento.bnfnum,
                   lr_documento.crtsaunum,
                   lr_documento.cmnnumdig,
                   lr_documento.corsus,
                   lr_documento.dddcod,
                   lr_documento.ctttel,
                   lr_documento.funmat,
                   lr_documento.cgccpfnum,
                   lr_documento.cgcord,
                   lr_documento.cgccpfdig,
                   lr_documento.crtdvgflg,
                   lr_documento.pss_ligdcttip,
                   lr_documento.pss_ligdctnum,
                   lr_documento.pss_dctitm,
                   lr_documento.pss_psscntcod,
                   lr_documento.cgccpf_ligdcttip,
                   lr_documento.cgccpf_ligdctnum,
                   lr_documento.itaciacod  
      
       
       display "544 - lr_documento.aplnumdig = ",lr_documento.aplnumdig
       display "545 - lr_documento.succod = ",lr_documento.succod
       display "546 - lr_documento.itmnumdig = ",lr_documento.itmnumdig
                            
       if lr_documento.aplnumdig is null then
          let m_erro.servico = "IDENTIFICA CLIENTE"                        
          let m_erro.coderro = 2                                              
          let m_erro.mens    = "NÃO E POSSIVEL AGENDAR RETORNO SEM UM DOCUMENTO EMITIDO"    
          call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)    
               returning m_xml                                                
          return m_xml                                                                 
       end if             
                            
                            
                            
       
       open  c_cty05g08_031 using l_lignum 
       whenever error continue 
       fetch c_cty05g08_031 into l_assunto 
       whenever error stop 
       
       if l_assunto = 'RET' then 
          let m_erro.servico = "IDENTIFICA CLIENTE"                        
          let m_erro.coderro = 2                                          
          let m_erro.mens    = "NÃO E POSSIVEL AGENDAR RETORNO DE RETORNO"  
          call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
               returning m_xml                                            
          return m_xml                                                    
       end if     
       
       if lr_documento.aplnumdig is not null then 
                 
          display "550 - lr_documento.ramcod = ",lr_documento.ramcod       
                       
          open ccty05g08015 using l_lignum
          
          whenever error continue   
          fetch ccty05g08015 into l_ciaempcod 
          whenever error stop
          
          display "557 - sqlca.sqlcode = ",sqlca.sqlcode
          if sqlca.sqlcode <> 0 then           
             display " Erro ao buscar empresa "
          end if      
          
          close ccty05g08015    
             
          display "561 - l_ciaempcod = ",l_ciaempcod
          display "562 - l_lignum = ",l_lignum
          
          
          
          if lr_documento.ramcod = 31 or 
             lr_documento.ramcod = 531 then                  
             
             display "569 - l_ciaempcod = ",l_ciaempcod
             case  l_ciaempcod
             
             when 1 
             
                call cty05g01_ultsit_apolice(lr_documento.succod,
                                             lr_documento.aplnumdig,
                                             lr_documento.itmnumdig)
                    returning lr_funapol.*
                    display "lr_funapol.dctnumseq = ",lr_funapol.dctnumseq
                                             
                
                open ccty05g08001 using lr_documento.succod,  
                                        lr_documento.aplnumdig,
                                        lr_documento.itmnumdig,
                                        lr_funapol.dctnumseq   
                whenever error continue  
                fetch ccty05g08001 into l_segnumdig
                whenever error stop
                display " l_segnumdig = ",l_segnumdig
                
                if sqlca.sqlcode <> 0 then 
                
                end if 
                
                close ccty05g08001 
                
               
                open  ccty05g08002 using l_segnumdig
                whenever error continue
                fetch ccty05g08002 into lr_retorno.segnom                
                whenever error stop 
                
                display "Porto lr_retorno.segnom = ",lr_retorno.segnom
                
                if sqlca.sqlcode <> 0 then 
                
                end if  
                
                close ccty05g08002                   
             
             otherwise 
                  let m_erro.servico = "IDENTIFICA CLIENTE"                         
                  let m_erro.coderro = 100                                          
                  let m_erro.mens    = "NAO FOI POSSIVEL LOCALIZAR O SERVICO"             
                  call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)  
                      returning m_xml                                             
                                                                                  
                  return m_xml                                                    
             end case 
          else 
            
            display "RE"
            
            open ccty05g08013 using lr_documento.succod,
                                    lr_documento.ramcod,
                                    lr_documento.aplnumdig       
            whenever error continue   
            fetch ccty05g08013 into lr_re.sgrorg,
                                    lr_re.sgrnumdig         
            whenever error stop 
            
            close ccty05g08013
            display "lr_re.sgrorg,   = ",lr_re.sgrorg
            display "lr_re.sgrnumdig = ",lr_re.sgrnumdig
                     
           
            
            open ccty05g08014 using lr_re.sgrorg,  
                                    lr_re.sgrnumdig,
                                    lr_re.sgrorg,                                    
                                    lr_re.sgrnumdig                                                                  
            whenever error continue 
            fetch ccty05g08014 into l_segnumdig
            whenever error stop
            
            if sqlca.sqlcode <> 0 then 
               display "495 sqlca.sqlcode = ",sqlca.sqlcode
            end if   
            
            close ccty05g08014
            display "l_segnumdig = ",l_segnumdig
            
                                 
            open  ccty05g08002 using l_segnumdig     
          
            whenever error continue
            fetch ccty05g08002 into lr_retorno.segnom
            whenever error stop                         
            
            display "RE lr_retorno.segnom = ",lr_retorno.segnom
            close ccty05g08002                                      
          end if 
       end if 
       
       if lr_documento.crtsaunum is not null then 
       
          call cta01m15_sel_datksegsau(5,       
                          lr_documento.crtsaunum,
                          "",                   
                          "",                   
                          "")                   
                   returning l_status,          
                             l_msg,             
                             lr_retorno.segnom     
          
          display "RE lr_retorno.segnom = ",lr_retorno.segnom
       end if 
       
       if lr_documento.crtdvgflg  = 'S' and 
          lr_documento.cgccpfnum  is not null then 
          
          if  lr_documento.cgcord = 0 then 
              let lr_cta01m60.pestip = 'F'
          else 
              let lr_cta01m60.pestip = 'J'   
          end if            
          
          
          
          open c_cty05g08_030  using lr_cta01m60.pestip    ,                                         
                                     lr_documento.cgccpfnum ,
                                     lr_documento.cgcord    ,
                                     lr_documento.cgccpfdig 
          whenever error continue 
          fetch c_cty05g08_030 into lr_cta01m60.pesnom
          whenever error stop 
          
          if sqlca.sqlcode <> 0 then 
             display "Erro na linha 710 ao buscar segurado "
          end if                  
            
          close c_cty05g08_030
                   
          let lr_retorno.segnom = lr_cta01m60.pesnom
                   
          display "cartao lr_retorno.segnom = ",lr_retorno.segnom
       
       end if 
       
         
                                 
             
                               
          open ccty05g08003 using lr_param.atdsrvnum,
                                 lr_param.atdsrvano
          whenever error continue
          fetch ccty05g08003 into l_socntzcod
          whenever error stop 
          
          if sqlca.sqlcode = 0 then 
                                
            open ccty05g08004 using l_socntzcod                                    
            whenever error continue 
            fetch ccty05g08004 into lr_retorno.socntzdes
            whenever error stop 
            
            close ccty05g08004                         
          else 
          
          end if   
          
          close ccty05g08003
          
          display "lr_retorno.socntzdes = ",lr_retorno.socntzdes
          
          
          open ccty05g08005  using lr_param.atdsrvnum,
                                   lr_param.atdsrvano
          whenever error continue  
          fetch ccty05g08005 into lr_retorno.c24pbmdes,
                                  l_atddatprg,
                                  l_atdhorprg,
                                  l_atddat,
                                  l_atdhor
                                  
                                                     
          whenever error stop 
          
          if sqlca.sqlcode <> 0 then 
          
          end if 
              
          close ccty05g08005   
                 
          if l_atddatprg is null then 
             let lr_retorno.data = l_atddat
             let lr_retorno.hora = l_atdhor
          else
            let lr_retorno.data = l_atddatprg
            let lr_retorno.hora = l_atdhorprg    
          end if            
       end for
    end if        
    #let m_servico[l_linha].atdsrvnum  = lr_retorno.atdsrvnum
    #let m_servico[l_linha].atdsrvano  = lr_retorno.atdsrvano
    #let m_servico[l_linha].segnom     = lr_retorno.segnom   
    #let m_servico[l_linha].socntzdes  = lr_retorno.socntzdes
    #let m_servico[l_linha].c24pbmdes  = lr_retorno.c24pbmdes
    #let m_servico[l_linha].data       = lr_retorno.data     
    #let m_servico[l_linha].hora       = lr_retorno.hora     
    
    display "return atdsrvnum =",lr_retorno.atdsrvnum 
    display "return atdsrvano =",lr_retorno.atdsrvano 
    display "return segnom    =",lr_retorno.segnom    
    display "return socntzdes =",lr_retorno.socntzdes 
    display "return c24pbmdes =",lr_retorno.c24pbmdes 
    display "return data      =",lr_retorno.data      
    display "return hora      =",lr_retorno.hora   
    
    
    
    
    display "l_data = ",l_data
    display " lr_param.tp_retorno = ", lr_param.tp_retorno
    
    
    
    
     if l_data > (lr_retorno.data + lr_param.tp_retorno) or 
        lr_retorno.data is null then 
       display "632 entrei"
       let m_servico[l_linha].atdsrvnum  = null
       let m_servico[l_linha].atdsrvano  = null
       let m_servico[l_linha].segnom     = null
       let m_servico[l_linha].socntzdes  = null
       let m_servico[l_linha].c24pbmdes  = null
       let m_servico[l_linha].data       = null
       let m_servico[l_linha].hora       = null  
       let l_linha = 0    
    else 
      display "642 - entrei"
      let l_linha = 1    
      let m_servico[l_linha].atdsrvnum  = lr_retorno.atdsrvnum
      let m_servico[l_linha].atdsrvano  = lr_retorno.atdsrvano
      let m_servico[l_linha].segnom     = lr_retorno.segnom   
      let m_servico[l_linha].socntzdes  = lr_retorno.socntzdes
      let m_servico[l_linha].c24pbmdes  = lr_retorno.c24pbmdes
      let m_servico[l_linha].data       = lr_retorno.data     
      let m_servico[l_linha].hora       = lr_retorno.hora             
    end if
        
    let m_xml       = null    
    display "linha = ", l_linha
    if l_linha = 0 then                                               
      let m_erro.servico = "IDENTIFICA CLIENTE"                       
      let m_erro.coderro = 100                                        
      let m_erro.mens    = "NAO LOCALIZOU NENHUM SERVICO"             
      call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
           returning m_xml                                            
    else                                                                  
       call cty05g08_gera_xml_retorno(l_linha)
            returning m_xml
    end if        
    
    display  "Saindo prepare = ",m_cty05g08_prepare
       
    return m_xml
    
end function    

function cty05g08_busca_servico_por_placa(lr_param)


   define lr_param record 
        vcllicnum like abbmveic.vcllicnum,
        tp_retorno smallint         
   end record  
                                                
                                             
   define lr_retorno record                  
       atdsrvnum like datmservico.atdsrvnum, 
       atdsrvano like datmservico.atdsrvano, 
       segnom    like gsakseg.segnom,        
       socntzdes like datksocntz.socntzdes,  
       c24pbmdes like datkpbm.c24pbmdes,         
       data      like datmservico.atddat,    
       hora      like datmservico.atdhor     
   end record                                
     
   define l_lignum    like datmligacao.lignum,   
          l_segnumdig like gsakseg.segnumdig,    
          l_socntzcod like datksocntz.socntzcod, 
          l_atddat    like datmservico.atddat,   
          l_atdhor    like datmservico.atdhor,   
          l_atddatprg like datmservico.atddatprg,
          l_atdhorprg like datmservico.atdhorprg,
          l_data      date,  
          l_hora      datetime hour to minute,
          l_linha     integer  
   
   
   define d_abbmveic record            
    succod    like abbmveic.succod,    
    aplnumdig like abbmveic.aplnumdig, 
    itmnumdig like abbmveic.itmnumdig, 
    dctnumseq like abbmveic.dctnumseq,
    vigfnl    like abamapol.vigfnl  
   end record                                                                                                                
   
   define lr_servico record                   
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         lignum    like datmligacao.lignum,   
         atddat    like datmservico.atddat,   
         atdhor    like datmservico.atdhor,          
         c24pbmdes like datkpbm.c24pbmdes,           
         atddatprg like datmservico.atddatprg,       
         atdhorprg like datmservico.atdhorprg        
   end record 
   
   define lr_documento_azul  record
       succod        like datrligapol.succod,      # Codigo Sucursal
       aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
       itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
       edsnumref     like datrligapol.edsnumref,   # Numero do Endosso       
       ramcod        like datrservapol.ramcod,     # Codigo aamo       
       corsus        char(06)                   ,         
       viginc        date,
       vigfnl        date,
       segcod        integer,
       segnom        char(50),
       vcldes        char(25),
       resultado     smallint,
       emsdat        date,
       doc_handle    integer,
       mensagem      char(50),
       situacao      char(10)
   end record
   
   define l_ramo like datrligapol.ramcod
   define l_atdetpcod like datmsrvacp.atdetpcod  
   define l_assunto   like datmligacao.c24astcod
   define l_existe    smallint            

         
   
   initialize lr_retorno.* to null     
   initialize lr_servico.* to null
   initialize lr_documento_azul.* to null 
   initialize d_abbmveic.* to null
   let l_lignum    = null           
   let l_segnumdig = null           
   let l_socntzcod = null           
   let l_atddat    = null           
   let l_atdhor    = null           
   let l_atddatprg = null           
   let l_atdhorprg = null              
   let l_data      = null 
   let l_hora      = null 
   let m_xml       = null
   let l_ramo      = null 
   let l_atdetpcod = null 
   let l_assunto   = null 
   let l_existe    = null
   
   for l_linha = 1 to 30 
       initialize m_servico[l_linha].* to null     
   end for
      
   let l_linha = 0
   
   
       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if      

   call cts40g03_data_hora_banco(2) 
        returning l_data, l_hora
                             
 
  
  open ccty05g08006 using  lr_param.vcllicnum  
     
  whenever error continue
  fetch ccty05g08006 into d_abbmveic.succod,    
                          d_abbmveic.aplnumdig,
                          d_abbmveic.itmnumdig,
                          d_abbmveic.dctnumseq,
                          d_abbmveic.vigfnl 
 
  whenever error stop  
 
 display "sqlca.sqlcode = ",sqlca.sqlcode
 if sqlca.sqlcode = 100 then 
       display "teste"
       let m_erro.servico = "IDENTIFICA CLIENTE"
       let m_erro.coderro = 100
       let m_erro.mens    = "NAO FOI LOCALIZADO NENHUM DOCUMENTO"         
       call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
           returning m_xml 
           
       return m_xml       
 end if    
 
 close ccty05g08006                 
                    
 
      display "d_abbmveic.succod,    = ",d_abbmveic.succod
      display "d_abbmveic.aplnumdig, = ",d_abbmveic.aplnumdig
      display "d_abbmveic.itmnumdig, = ",d_abbmveic.itmnumdig
      display "d_abbmveic.dctnumseq  = ",d_abbmveic.dctnumseq  
                              
      
      let l_ramo = 531        
       
      open ccty05g08008 using d_abbmveic.succod,
                              l_ramo,
                              d_abbmveic.aplnumdig,
                              d_abbmveic.itmnumdig
                              
         
      foreach ccty05g08008 into lr_servico.atdsrvnum,
                                lr_servico.atdsrvano,
                                lr_servico.lignum 
         
         
         display "lr_servico.atdsrvnum = ",lr_servico.atdsrvnum
         display "lr_servico.atdsrvano = ",lr_servico.atdsrvano
         display "lr_servico.lignum     = ",lr_servico.lignum    
      
         call cty05g08_existe_retorno(lr_servico.atdsrvnum,lr_servico.atdsrvano) 
              returning l_existe                                             
                                                                             
         display "585 l_existe = ", l_existe                                 
         
                                                                             
         if l_existe  = true then                                            
            continue foreach
            #let m_erro.servico = "IDENTIFICA CLIENTE"                        
            #let m_erro.coderro = 2                                           
            #let m_erro.mens    = "JA EXISTE UM RETORNO PARA ESTE SERVICO "   
            #call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens) 
            #     returning m_xml                                             
            #return m_xml                                                     
         end if                               
         
         
         
         call cts10g04_ultima_etapa(lr_servico.atdsrvnum,lr_servico.atdsrvano)
           returning l_atdetpcod 
              
         display "514 - l_atdetpcod =",l_atdetpcod 
         
         if l_atdetpcod = 5 then 
            let m_erro.servico = "IDENTIFICA CLIENTE"
            let m_erro.coderro = 2
            let m_erro.mens    = "ESTE SERVIÇO ESTA CANCELADO "             
            call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
                 returning m_xml         
            return m_xml      
         else 
            if l_atdetpcod <> 3 then 
              let m_erro.servico = "IDENTIFICA CLIENTE"
              let m_erro.coderro = 2
              let m_erro.mens    = "SERVIÇO AINDA NAO FOI ACIONADO"             
              call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
                   returning m_xml                  
              return m_xml                 
            end if 
         end if          
       
          open ccty05g08005  using lr_servico.atdsrvnum,
                                   lr_servico.atdsrvano
          whenever error continue
          fetch ccty05g08005 into  lr_servico.c24pbmdes,
                                   lr_servico.atddatprg,
                                   lr_servico.atdhorprg,
                                   lr_servico.atddat,
                                   lr_servico.atdhor                                                                                             
          whenever error stop 
          
          close ccty05g08005
                              
          if lr_servico.atddatprg is null then         
             if l_data > (lr_servico.atddat + lr_param.tp_retorno) then 
                continue foreach
             end if
          else                                                                 
            if l_data > (lr_servico.atddatprg + lr_param.tp_retorno) then               
               continue foreach                
            end if    
          end if       
          
          let l_linha = l_linha + 1                                            
          display "1228 l_linha = ", l_linha                                   
          
          
          let m_servico[l_linha].c24pbmdes = lr_servico.c24pbmdes
          
          display "lr_servico.c24pbmdes = ",lr_servico.c24pbmdes
          display "lr_servico.atddatprg = ",lr_servico.atddatprg
          display "lr_servico.atdhorprg = ",lr_servico.atdhorprg
          display "lr_servico.atddat    = ",lr_servico.atddat   
          display "lr_servico.atdhor    = ",lr_servico.atdhor    
                                                                   
          #if lr_servico.atddatprg is null then         
          #   if l_data > (lr_servico.atddat + lr_param.tp_retorno) then 
          #      continue foreach
          #   end if
          #else                                                                 
          #  if l_data > (lr_servico.atddatprg + lr_param.tp_retorno) then               
          #     continue foreach                
          #  end if    
          #end if       
          
           
          open ccty05g08001 using d_abbmveic.succod,  
                                  d_abbmveic.aplnumdig,
                                  d_abbmveic.itmnumdig,
                                  d_abbmveic.dctnumseq   
          whenever error continue
          fetch ccty05g08001 into l_segnumdig
          whenever error stop
          display " l_segnumdig = ",l_segnumdig
          
          if sqlca.sqlcode <> 0 then 
          
          end if 
      
          close ccty05g08001
          
          
          open  ccty05g08002 using l_segnumdig
          whenever error continue 
          fetch ccty05g08002 into m_servico[l_linha].segnom                
          whenever error stop           
          display "469 - lr_retorno.segnom = ",m_servico[l_linha].segnom
          
          if sqlca.sqlcode <> 0 then 
          
          end if                      
           
          close ccty05g08002                                                                 
         
          let m_servico[l_linha].atdsrvnum = lr_servico.atdsrvnum
          let m_servico[l_linha].atdsrvano = lr_servico.atdsrvano
          
                               
          open ccty05g08003 using m_servico[l_linha].atdsrvnum,
                                  m_servico[l_linha].atdsrvano
          whenever error continue
          fetch ccty05g08003 into l_socntzcod
          whenever error stop 
          
          if sqlca.sqlcode = 0 then 
                                
            open ccty05g08004 using l_socntzcod                                    
            whenever error continue 
            fetch ccty05g08004 into m_servico[l_linha].socntzdes
            whenever error stop 
            
            close ccty05g08004                        
          else 
          
          end if   
          
          close ccty05g08003
          
          display "491 lr_retorno.socntzdes = ",m_servico[l_linha].socntzdes         
          
          if lr_servico.atddatprg is null then         
             let m_servico[l_linha].data = lr_servico.atddat
             let m_servico[l_linha].hora = lr_servico.atdhor
          else
            let m_servico[l_linha].data = lr_servico.atddatprg
            let m_servico[l_linha].hora = lr_servico.atdhorprg    
          end if    
                                                                                         
      end foreach   
                 
 if l_linha = 0 then 
   let m_erro.servico = "IDENTIFICA CLIENTE"
   let m_erro.coderro = 100
   let m_erro.mens    = "NAO LOCALIZOU NENHUM SERVICO"         
   call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
        returning m_xml 
 else 
   call cty05g08_gera_xml_retorno(l_linha)
        returning m_xml 
 end if        
      
 return m_xml      
   
 
end function         

function cty05g08_busca_servico_por_cpf(lr_param)

   define lr_param record          
         cgccpfnum like gsakpes.cgccpfnum,
         cgcord    like gsakpes.cgcord   ,
         cgccpfdig like gsakpes.cgccpfdig,         
         pestip       like gsakpes.pestip,
         tp_retorno   smallint   
   end record 
   
   define lr_cgccpf record 
         cgccpfnum like gsakpes.cgccpfnum,
         cgcord    like gsakpes.cgcord   ,
         cgccpfdig like gsakpes.cgccpfdig,
         pestip    like gsakpes.pestip
   end record
   
   define lr_retorno record 
       coderro  smallint,
       mens     char(300)
   end record
   
   define lr_cty05g08 record
       produto     char(30)                   ,
       cod_produto smallint                   ,
       succod      like datrligapol.succod    ,
       ramcod      like datrligapol.ramcod    ,
       aplnumdig   like datrligapol.aplnumdig ,
       itmnumdig   like datrligapol.itmnumdig ,
       crtsaunum   like datksegsau.crtsaunum  ,
       bnfnum      like datksegsau.bnfnum     ,
       situacao    char(30)                   ,
       qtdsrv      integer                    ,
       qtdsrvre    integer                    ,
       viginc      date                       ,
       vigfnl      date                       ,
       vig         smallint                   ,
       documento   char(110)                  ,
       permissao   char(1)                    ,
       prporg      like datrligprp.prporg     ,
       prpnumdig   like datrligprp.prpnumdig  ,
       sitdoc      char(70)                   ,
       pesnom      like gsakpes.pesnom        ,
       itaciacod   like datkitacia.itaciacod    
    end record
    
    define lr_servico record                   
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         lignum    like datmligacao.lignum,   
         atddat    like datmservico.atddat,   
         atdhor    like datmservico.atdhor,          
         c24pbmdes like datkpbm.c24pbmdes,           
         atddatprg like datmservico.atddatprg,       
         atdhorprg like datmservico.atdhorprg        
    end record
    
    define l_lignum    like datmligacao.lignum,             
          l_socntzcod like datksocntz.socntzcod, 
          l_atddat    like datmservico.atddat,   
          l_atdhor    like datmservico.atdhor,   
          l_atddatprg like datmservico.atddatprg,
          l_atdhorprg like datmservico.atdhorprg,
          l_data      date,  
          l_hora      datetime hour to minute,
          l_linha     integer, 
          l_qtde      integer,
          l_index     integer,
          l_atdetpcod like datmsrvacp.atdetpcod,
          l_existe    smallint,   
          l_exit      smallint
                                   
   initialize lr_cgccpf.* to null
   initialize lr_retorno.* to null
   initialize lr_cty05g08.* to null
   initialize lr_servico.* to null
   let l_atdetpcod = null
   let l_existe = false
   let l_exit   = false 
   
   let lr_retorno.coderro = 0 
   let l_qtde = 0 
   let l_index = 0 
   let m_xml = null 
   
   for l_linha = 1 to 30                      
       initialize m_servico[l_linha].* to null
   end for                                    
   
   let l_linha = 0                             
                                                                                                 
    if m_cty05g08_prepare is null or
       m_cty05g08_prepare <> true then
         call cty05g08_prepare()
    end if                                       
   
   call cts40g03_data_hora_banco(2)            
        returning l_data, l_hora                                    
   
   
   
   display "1210 - antes cty05g08_busca_produtos "
   call cty05g08_busca_produtos(lr_param.cgccpfnum,       
                                lr_param.cgcord   ,       
                                lr_param.cgccpfdig,       
                                lr_param.pestip)       
        returning lr_retorno.*                    
   display "retorno 1216 "          
   
   display "1218 - lr_retorno.coderro = ",lr_retorno.coderro
   if lr_retorno.coderro <> 0 then 
      let m_erro.servico = "IDENTIFICA CLIENTE"
      let m_erro.coderro = lr_retorno.coderro
      let m_erro.mens    = lr_retorno.mens         
      call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
           returning m_xml 
   else 
   
        call cty05g08_prepare_temp()
              returning lr_retorno.coderro              
              
         
        open ccty05g08009
        
        let l_exit = false  
        foreach ccty05g08009 into lr_cty05g08.*                 
                         
           let l_exit = true               
           display "1235 - lr_cty05g08.cod_produto = ",lr_cty05g08.cod_produto
           
           if lr_cty05g08.cod_produto = 1 or 
              lr_cty05g08.cod_produto = 2 or 
              lr_cty05g08.cod_produto = 12 or 
              lr_cty05g08.cod_produto = 13 or 
              lr_cty05g08.cod_produto = 99 then
                                                                                   
              display " lr_cty05g08.succod,   = ",lr_cty05g08.succod
              display " lr_cty05g08.ramcod,   = ",lr_cty05g08.ramcod
              display " lr_cty05g08.aplnumdig,= ",lr_cty05g08.aplnumdig
              display " lr_cty05g08.itmnumdig = ",lr_cty05g08.itmnumdig 
              
              
              if lr_cty05g08.ramcod <> 531 and  
                 lr_cty05g08.ramcod <> 31  then                  
                 let lr_cty05g08.itmnumdig = 0                             
              end if    
              
                display " lr_cty05g08.succod,   = ",lr_cty05g08.succod   
                display " lr_cty05g08.ramcod,   = ",lr_cty05g08.ramcod   
                display " lr_cty05g08.aplnumdig,= ",lr_cty05g08.aplnumdig
                display " lr_cty05g08.itmnumdig = ",lr_cty05g08.itmnumdig
              
              
              display "teste ccty05g08008  " #lr_cty05g08.ramcod,   
              open ccty05g08008 using lr_cty05g08.succod,
                                      lr_cty05g08.ramcod,                           
                                      lr_cty05g08.aplnumdig,
                                      lr_cty05g08.itmnumdig
             
              foreach ccty05g08008 into lr_servico.atdsrvnum,
                                        lr_servico.atdsrvano,
                                        lr_servico.lignum 
                                        
                  display "lr_servico.atdsrvnum = ",lr_servico.atdsrvnum
                  display "lr_servico.atdsrvano = ",lr_servico.atdsrvano
                  
                  
                  call cty05g08_existe_retorno(lr_servico.atdsrvnum,lr_servico.atdsrvano)
                       returning l_existe
        
                  display "1339 - l_existe = ", l_existe       
                  display "1389 - l_linha = ", l_linha                         
                  if l_existe  = true then
                     continue foreach
                     #l_linha = 0 then 
                     #let m_erro.servico = "IDENTIFICA CLIENTE"
                     #let m_erro.coderro = 2
                     #let m_erro.mens    = "JÁ EXISTE UM RETORNO PARA ESTE SERVICO "             
                     #call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
                     #     returning m_xml         
                     #return m_xml     
                  end if          
                  
                                        
                 call cts10g04_ultima_etapa(lr_servico.atdsrvnum,lr_servico.atdsrvano)
                      returning l_atdetpcod 
           
                      display "l_atdetpcod = ",l_atdetpcod
                      if l_atdetpcod <> 3 then                           
                          continue foreach
                       end if                                                              
                  
                  display "1254 lr_servico.atdsrvnum = ",lr_servico.atdsrvnum
                  display "1255 lr_servico.atdsrvano = ",lr_servico.atdsrvano
                  display "1256 lr_servico.lignum     = ",lr_servico.lignum    
                                       
                   
                   open ccty05g08005  using lr_servico.atdsrvnum,
                                            lr_servico.atdsrvano
                   whenever error continue
                   fetch ccty05g08005 into  lr_servico.c24pbmdes,
                                            lr_servico.atddatprg,
                                            lr_servico.atdhorprg,
                                            lr_servico.atddat,
                                            lr_servico.atdhor                                                                                             
                   whenever error stop 
                   
                   close ccty05g08005 
                   
                   if lr_servico.atddatprg is null then         
                      if l_data > (lr_servico.atddat + lr_param.tp_retorno) then 
                         continue foreach
                      end if
                   else                                                                 
                     if l_data > (lr_servico.atddatprg + lr_param.tp_retorno) then 
                        continue foreach                
                     end if    
                   end if       
                   
                   let l_linha = l_linha + 1
                   let m_servico[l_linha].segnom = lr_cty05g08.pesnom    
                   
                   display "1281 - lr_retorno.segnom = ",m_servico[l_linha].segnom
                                                                                    
                   let m_servico[l_linha].c24pbmdes = lr_servico.c24pbmdes
                   
                   let m_servico[l_linha].atdsrvnum = lr_servico.atdsrvnum
                   let m_servico[l_linha].atdsrvano = lr_servico.atdsrvano
                   
                                        
                   open ccty05g08003 using m_servico[l_linha].atdsrvnum,
                                           m_servico[l_linha].atdsrvano
                   whenever error continue
                   fetch ccty05g08003 into l_socntzcod
                   whenever error stop 
                   
                   if sqlca.sqlcode = 0 then 
                                       
                     open ccty05g08004 using l_socntzcod                                    
                     whenever error continue  
                     fetch ccty05g08004 into m_servico[l_linha].socntzdes
                     whenever error stop 
                     close ccty05g08004                         
                   else 
                   
                   end if   
                   
                   close ccty05g08003 
                   
                   display "1303 lr_retorno.socntzdes = ",m_servico[l_linha].socntzdes         
                   
                   if lr_servico.atddatprg is null then         
                      let m_servico[l_linha].data = lr_servico.atddat
                      let m_servico[l_linha].hora = lr_servico.atdhor
                   else
                     let m_servico[l_linha].data = lr_servico.atddatprg
                     let m_servico[l_linha].hora = lr_servico.atdhorprg    
                   end if                                                                                        
              end foreach
              
              display "sqlca.sqlcode = ",sqlca.sqlcode
              
           end if 
           
           case lr_cty05g08.cod_produto
           
               when 98  # Saude                                
                                       
                      open ccty05g08011 using lr_cty05g08.crtsaunum
                      
                      foreach ccty05g08011 into lr_servico.atdsrvnum,
                                                lr_servico.atdsrvano                                                                              
                      
                          
                          
                          display "1326 lr_servico.atdsrvnum = ",lr_servico.atdsrvnum
                          display "1327 lr_servico.atdsrvano = ",lr_servico.atdsrvano
                          display "1328 lr_servico.lignum     = ",lr_servico.lignum    
                                               
                            
                           open ccty05g08005  using lr_servico.atdsrvnum,
                                                    lr_servico.atdsrvano
                           whenever error continue
                           fetch ccty05g08005 into  lr_servico.c24pbmdes,
                                                    lr_servico.atddatprg,
                                                    lr_servico.atdhorprg,
                                                    lr_servico.atddat,
                                                    lr_servico.atdhor                                                                                             
                           whenever error stop 
                           
                           close ccty05g08005
                           
                           let m_servico[l_linha].c24pbmdes = lr_servico.c24pbmdes
                                                
                          
                           if lr_servico.atddatprg is null then         
                              if l_data > (lr_servico.atddat + lr_param.tp_retorno) then 
                                 continue foreach
                              end if
                           else                                                                 
                             if l_data > (lr_servico.atddatprg + lr_param.tp_retorno) then 
                                continue foreach                
                             end if    
                           end if       
                           
                           let l_linha = l_linha + 1
                           let m_servico[l_linha].segnom = lr_cty05g08.pesnom    
                   
                           display "1356 - lr_retorno.segnom = ",m_servico[l_linha].segnom    
                                                                                            
                           
                           let m_servico[l_linha].atdsrvnum = lr_servico.atdsrvnum
                           let m_servico[l_linha].atdsrvano = lr_servico.atdsrvano
                           
                                                
                           open ccty05g08003 using m_servico[l_linha].atdsrvnum,
                                                   m_servico[l_linha].atdsrvano
                           whenever error continue
                           fetch ccty05g08003 into l_socntzcod
                           whenever error stop 
                           
                           if sqlca.sqlcode = 0 then 
                                                 
                             open ccty05g08004 using l_socntzcod  
                             whenever error continue                                   
                             fetch ccty05g08004 into m_servico[l_linha].socntzdes
                             whenever error stop    
                             close ccty05g08004                     
                           else 
                           
                           end if 
                           
                           close ccty05g08003   
                           
                           display "1377 lr_retorno.socntzdes = ",m_servico[l_linha].socntzdes         
                           
                           if lr_servico.atddatprg is null then         
                              let m_servico[l_linha].data = lr_servico.atddat
                              let m_servico[l_linha].hora = lr_servico.atdhor
                           else
                             let m_servico[l_linha].data = lr_servico.atddatprg
                             let m_servico[l_linha].hora = lr_servico.atdhorprg    
                           end if                  
                         
                      end foreach
                     
             
               when 97  # Cartao                
                                                                                 
        
                       
                      open ccty05g08012 using lr_cgccpf.cgccpfnum  ,
                                              lr_cgccpf.cgcord     ,
                                              lr_cgccpf.cgccpfdig  
                                             
                      foreach ccty05g08012 into lr_servico.atdsrvnum,
                                                lr_servico.atdsrvano
                        
                       
                          
                          display "1403 lr_servico.atdsrvnum = ",lr_servico.atdsrvnum
                          display "1404 lr_servico.atdsrvano = ",lr_servico.atdsrvano
                          display "1405 lr_servico.lignum     = ",lr_servico.lignum    
                                               
                            
                           open ccty05g08005  using lr_servico.atdsrvnum,
                                                    lr_servico.atdsrvano
                           whenever error continue
                           fetch ccty05g08005 into  lr_servico.c24pbmdes,
                                                    lr_servico.atddatprg,
                                                    lr_servico.atdhorprg,
                                                    lr_servico.atddat,
                                                    lr_servico.atdhor                                                                                             
                           whenever error stop                                                                                                             
                           
                           close ccty05g08005
                           
                           if lr_servico.atddatprg is null then         
                              if l_data > (lr_servico.atddat + lr_param.tp_retorno) then 
                                 continue foreach
                              end if
                           else                                                                 
                             if l_data > (lr_servico.atddatprg + lr_param.tp_retorno) then 
                                continue foreach                
                             end if    
                           end if       
                           
                           let l_linha = l_linha + 1                           
                           let m_servico[l_linha].c24pbmdes = lr_servico.c24pbmdes
                           let m_servico[l_linha].segnom = lr_cty05g08.pesnom    
                           
                   
                           display "1432 - lr_retorno.segnom = ",m_servico[l_linha].segnom    
                                                                                            
                           
                           let m_servico[l_linha].atdsrvnum = lr_servico.atdsrvnum
                           let m_servico[l_linha].atdsrvano = lr_servico.atdsrvano
                           
                                                
                           open ccty05g08003 using m_servico[l_linha].atdsrvnum,
                                                   m_servico[l_linha].atdsrvano
                           whenever error continue
                           fetch ccty05g08003 into l_socntzcod
                           whenever error stop 
                           
                           if sqlca.sqlcode = 0 then 
                                                 
                             open ccty05g08004 using l_socntzcod  
                             whenever error continue                                  
                             fetch ccty05g08004 into m_servico[l_linha].socntzdes
                             whenever error stop   
                             close ccty05g08004                      
                           else 
                           
                           end if   
                           
                           close ccty05g08003
                           
                           display "1453 - lr_retorno.socntzdes = ",m_servico[l_linha].socntzdes         
                           
                           if lr_servico.atddatprg is null then         
                              let m_servico[l_linha].data = lr_servico.atddat
                              let m_servico[l_linha].hora = lr_servico.atdhor
                           else
                             let m_servico[l_linha].data = lr_servico.atddatprg
                             let m_servico[l_linha].hora = lr_servico.atdhorprg    
                           end if                  
                         
                      end foreach 
                                                                  
                #otherwise # Outros
                #     let a_cta01m62[arr_aux].documento = lr_cta01m62.documento
           end case                 
        end foreach        
   end if   
     
     
   if l_linha = 0 then       
      if l_exit = false then                
         let m_erro.servico = "IDENTIFICA CLIENTE"
         let m_erro.coderro = 100
         let m_erro.mens    = "NAO LOCALIZOU NENHUM CLIENTE"         
         call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
              returning m_xml          
      else                            
         let m_erro.servico = "IDENTIFICA CLIENTE"
         let m_erro.coderro = 100
         let m_erro.mens    = "NAO LOCALIZOU NENHUM SERVICO"         
         call ctf00m06_xmlerro(m_erro.servico,m_erro.coderro,m_erro.mens)
              returning m_xml 
      end if         
   else 
      call cty05g08_gera_xml_retorno(l_linha)
           returning m_xml 
   end if        
      
 return m_xml         
           
end function          
      

function cty05g08_gera_xml_retorno(lr_param)

    define lr_param record 
           qtde    integer 
    end record 
    
    define l_xml char(32766)
    define l_index integer 
    
    let l_xml = null 
    let l_index = 1 
    display "1499 - lr_param.qtde = ",lr_param.qtde
    
        
    let l_xml = "<?xml version='1.0' encoding='ISO-8859-1' standalone='yes'?>"
    let l_xml = l_xml clipped, "<RESPONSE><SERVICOS>" 
                                                       
    for l_index = 1 to lr_param.qtde                                          
          let l_xml = l_xml clipped,"<IDENTIFICACAOSERVICO>"             
          let l_xml = l_xml clipped,"<NUMEROSERVICO>",m_servico[l_index].atdsrvnum clipped,"</NUMEROSERVICO>"             
          let l_xml = l_xml clipped,"<ANOSERVICO>",   m_servico[l_index].atdsrvano clipped,"</ANOSERVICO>"   
          let l_xml = l_xml clipped,"<NOME>",m_servico[l_index].segnom clipped,   "</NOME>"
          let l_xml = l_xml clipped,"<NATUREZA>",m_servico[l_index].socntzdes clipped,"</NATUREZA>"
          let l_xml = l_xml clipped,"<PROBLEMA>",m_servico[l_index].c24pbmdes clipped,"</PROBLEMA>"
          let l_xml = l_xml clipped,"<DATA>",m_servico[l_index].data clipped,     "</DATA>"
          let l_xml = l_xml clipped,"<HORA>",m_servico[l_index].hora clipped,     "</HORA>"
          let l_xml = l_xml clipped,"</IDENTIFICACAOSERVICO>"            
    end for
    
    
    let l_xml = l_xml clipped        
    let l_xml = l_xml clipped, "</SERVICOS></RESPONSE>"          
    
    return l_xml
    
end function
 
 
#=============================================================================== 
function cty05g08_formataCpf(pestip,cgccpfnumdig)                                
#=============================================================================== 
                                                                                    
    define pestip char(01)                                                          
    define cgccpfnumdig char(14)                                                                          
    define tam int                                                                  
    let tam =  length(cgccpfnumdig)                                             
                                                                                
    #-- No caso de Pessoa Física retorna cgcord igual a zero                    
    #-------------------------------------------------------                    
    if (pestip = 'F') then                                                      
          return cgccpfnumdig[1 , tam - 2] , 0 , cgccpfnumdig[tam - 1 , tam ]   
    else                                                                        
          return cgccpfnumdig[1 , tam - 6],                                     
                 cgccpfnumdig[tam - 5 , tam - 2],                               
                 cgccpfnumdig[tam - 1 , tam ]                                   
    end if                                                                      
                                                                                
end function   

#------------------------------------------------------------------------------
function cty05g08_busca_produtos(lr_param)
#------------------------------------------------------------------------------

  define lr_param record
         cgccpfnum like gsakpes.cgccpfnum    ,
         cgcord    like gsakpes.cgcord       ,
         cgccpfdig like gsakpes.cgccpfdig    ,       
         pestip    char(1)
  end record

  define lr_retorno record 
         coderro  smallint,
         mens     char(300)
  end record        


  define ws record
         erro smallint ,
         sair smallint
  end record

  define l_resultado smallint

  initialize lr_retorno.* to null
  initialize ws.*        to null

  let ws.erro      = 0
  let l_resultado  = null
  let lr_retorno.coderro = 0     
  
  if not cty05g08_cria_temp() then
      let ws.erro = 1
      display  "Erro na Criacao da Tabela Temporaria!"
  end if  
    
  call cty05g08_prep_temp()  

  if ws.erro = 0  then      

      # Recupero os Dados do Auto/Re/Diversos            
      call cty05g08_rec_doc_geral(lr_param.cgccpfnum ,
                                  lr_param.cgcord    ,
                                  lr_param.cgccpfdig ,
                                  lr_param.pestip    )                              
      # Recupero os Dados do Saude      
      call cty05g08_rec_saude(lr_param.cgccpfnum)      
      
      # Recupero os Dados do Cartao Visa      
      #call cty05g08_rec_cartao(lr_param.cgccpfnum ,
      #                         lr_param.cgcord    ,
      #                         lr_param.cgccpfdig ,
      #                         lr_param.pestip    )                  
  end if
      
      # Verifico se cliente tem produtos
      let l_resultado = cty05g08_conta_negocio()
      
      if l_resultado = 1 then                      
          let lr_retorno.coderro = 100 
          let lr_retorno.mens = "Cliente nao possui nenhum produto cadastrado"
      end if  
      
      return lr_retorno.*
end function

function cty05g08_rec_doc_geral(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    char(1)
end record


define lr_cty05g08 record
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnumdig   like datrligapol.itmnumdig  ,
       edsnumdig   like datrligapol.edsnumref
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       doc_handle integer  ,
       viginc     date     ,
       vigfnl     date
end record


define lr_temp record
       cont1       integer   ,
       cont2       integer   ,
       produto     char(30)  ,
       cod_produto smallint  ,
       crtsaunum   char(18)  ,
       bnfnum      char(20)  ,
       situacao    char(15)  ,
       viginc      date      ,
       vigfnl      date      ,
       vig         smallint  ,
       documento   char(110) ,
       permissao   char(1)   ,
       sitdoc      char(70)  ,
       pesnom      char(70)
end record

define lr_cta01m60 record                
      cgccpf     like gsakpes.cgccpfnum ,
      cgcord     like gsakpes.cgcord    ,
      cgccpfdig  like gsakpes.cgccpfdig ,
      pesnom     like gsakpes.pesnom    ,
      pestip     like gsakpes.pestip     
end record  



define l_qtd integer
define l_array integer


initialize lr_retorno.* to null
initialize lr_temp.*    to null
initialize lr_cta01m60.* to null

let l_qtd = null
let l_array = null

let lr_temp.cont1 = 0
let lr_temp.cont2 = 0
       
       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        
       
                     
       call osgtf550_pesquisa_negocios_cpfcnpj(lr_param.cgccpfnum,
                                               lr_param.cgcord   ,
                                               lr_param.cgccpfdig,
                                               lr_param.pestip   )
       returning lr_retorno.resultado, l_qtd
      
       display "l_qtd = ",l_qtd
       
       if l_qtd is not null and
          l_qtd > 0          then
          
           for l_array = 1 to l_qtd                                                       
             
              call cty05g08_prepare()
              
             display "l_array = ",l_array
              {# Recupera a situacao do documento
              open ccty05g08_022 using g_a_gsakdocngcseg[l_array].docsitcod
              whenever error continue       
              fetch ccty05g08_022  into lr_temp.situacao
                            
              whenever error stop
              close ccty05g08_022
              
              case g_a_gsakdocngcseg[l_array].docsitcod
                 when 1
                   let lr_temp.situacao = lr_temp.situacao[1,5]
                 when 2
                   let lr_temp.situacao = lr_temp.situacao[1,9]
              end case
              
              if g_a_gsakdocngcseg[l_array].docsitcod = 0 then
                 let lr_temp.situacao = "VENCIDO"
              end if
              
              if sqlca.sqlcode <> 0  then
                 error "Erro ao recuperar a situacao do documento"
              end if
              
              # Verifica se o documento e vigente
              if g_a_gsakdocngcseg[l_array].viginc  <= today and
                 g_a_gsakdocngcseg[l_array].vigfnl  >= today then
                   
                   if g_a_gsakdocngcseg[l_array].docsitcod = 1 then
                       let lr_temp.vig = 0
                   else
                       let lr_temp.vig = 1
                   end if
              
              else
                   let lr_temp.vig = 1
                   if g_a_gsakdocngcseg[l_array].docsitcod = 1 then
                        let lr_temp.situacao = "VENCIDO"
                   end if
              end if
              }
              # Se for Auto, RE, Transporte ou Fianca recupero a quantidade de serviços
              if g_a_gsakdocngcseg[l_array].unfprdcod = 1  or
                 g_a_gsakdocngcseg[l_array].unfprdcod = 2  or
                 g_a_gsakdocngcseg[l_array].unfprdcod = 12 or
                 g_a_gsakdocngcseg[l_array].unfprdcod = 13 then
                 
                 let lr_cty05g08.succod    = g_a_gsakdocngcseg[l_array].doc1
                 let lr_cty05g08.ramcod    = g_a_gsakdocngcseg[l_array].doc2
                 let lr_cty05g08.aplnumdig = g_a_gsakdocngcseg[l_array].doc3
                 let lr_cty05g08.itmnumdig = g_a_gsakdocngcseg[l_array].doc4
                 
                 ## Recupera a quantidade de servicos
                 #display "1830 - Conta servico"
                 #call cty05g08_conta_servico(lr_cty05g08.succod    ,
                 #                            lr_cty05g08.ramcod    ,
                 #                            lr_cty05g08.aplnumdig ,
                 #                            lr_cty05g08.itmnumdig ,
                 #                            "","","","","")
                 #returning lr_temp.cont1, lr_temp.cont2
              else
                  let lr_temp.cont1 =  0
                  let lr_temp.cont2 =  0
              end if
              
              # Recupera o Numero do Cliente (pesnum)              
              let lr_temp.cod_produto = g_a_gsakdocngcseg[l_array].unfprdcod
              let lr_temp.viginc      = g_a_gsakdocngcseg[l_array].viginc
              let lr_temp.vigfnl      = g_a_gsakdocngcseg[l_array].vigfnl                                                        
                 
              if lr_param.pestip = 'F' then 
                  let lr_cta01m60.cgcord = 0 
              else 
                  let lr_cta01m60.cgcord = lr_param.cgcord 
              end if     
              
               
              open c_cty05g08_030  using lr_param.pestip    ,
                                         lr_param.cgccpfnum ,
                                         lr_cta01m60.cgcord    ,
                                         lr_param.cgccpfdig 
              whenever error continue
              fetch c_cty05g08_030 into lr_cta01m60.pesnom
              whenever error stop 
                           
              if sqlca.sqlcode <> 0 then 
                 display "Erro na linha 1784 ao buscar segurado "
              end if    
              
              close c_cty05g08_030                          
              # Insiro os dados na tabela temporaria
              call cty05g08_ins_temp(lr_temp.produto       ,
                                     lr_temp.cod_produto   ,
                                     lr_cty05g08.succod    ,
                                     lr_cty05g08.ramcod    ,
                                     lr_cty05g08.aplnumdig ,
                                     lr_cty05g08.itmnumdig ,
                                     lr_temp.crtsaunum     ,
                                     lr_temp.bnfnum        ,
                                     lr_temp.situacao      ,
                                     lr_temp.cont1         ,
                                     lr_temp.cont2         ,
                                     lr_temp.viginc        ,
                                     lr_temp.vigfnl        ,
                                     lr_temp.vig           ,
                                     lr_temp.documento     ,
                                     lr_temp.permissao     ,
                                     ""                    ,
                                     ""                    ,
                                     lr_temp.sitdoc        ,
                                     lr_cta01m60.pesnom    ,
                                     ""                    )
          end for
       end if    
    return
    

end function


#------------------------------------------------------------------------------
function cty05g08_rec_azul(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum


define lr_cty05g08 record
       succod      like datrligapol.succod     ,
       ramcod      like datrligapol.ramcod     ,
       aplnumdig   like datrligapol.aplnumdig  ,
       itmnumdig   like datrligapol.itmnumdig  ,
       edsnumdig   like datrligapol.edsnumref
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       doc_handle integer  ,
       viginc     date     ,
       vigfnl     date
end record


define lr_temp record
       cont1       integer   ,
       cont2       integer   ,
       produto     char(30)  ,
       cod_produto smallint  ,
       crtsaunum   char(18)  ,
       bnfnum      char(20)  ,
       situacao    char(15)  ,
       viginc      date      ,
       vigfnl      date      ,
       vig         smallint  ,
       documento   char(110) ,
       permissao   char(1)   
end record

define lr_seg record
    segnom    like gsakseg.segnom,
    segteltxt like gsakend.teltxt
end record


initialize lr_retorno.* to null
initialize lr_temp.*    to null
initialize lr_seg.*    to null



       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        



let lr_temp.cod_produto = 99
    
    open c_cty05g08_016 using lr_param_cgccpfnum
    foreach c_cty05g08_016 into   lr_cty05g08.*
      
      call cts42g00_doc_handle(lr_cty05g08.*)
      returning lr_retorno.resultado,
                lr_retorno.mensagem,
                lr_retorno.doc_handle

      call cts38m00_extrai_vigencia(lr_retorno.doc_handle)
           returning lr_retorno.viginc,
                     lr_retorno.vigfnl

      call cts38m00_extrai_situacao(lr_retorno.doc_handle)
           returning lr_temp.situacao
           
      call cts38m00_extrai_dados_seg(lr_retorno.doc_handle)
           returning lr_seg.segnom,   
                     lr_seg.segteltxt
           

      if lr_retorno.viginc <= today and
         lr_retorno.vigfnl >= today then

           if lr_temp.situacao = "ATIVO" or
              lr_temp.situacao = "ATIVA" then
               let lr_temp.vig = 0
           else
               let lr_temp.vig = 1
           end if
      else
           let lr_temp.vig = 1
           let lr_temp.situacao = "VENCIDO"
      end if

      # Recupera a quantidade de servicos
      call cty05g08_conta_servico(lr_cty05g08.succod    ,
                                  lr_cty05g08.ramcod    ,
                                  lr_cty05g08.aplnumdig ,
                                  lr_cty05g08.itmnumdig ,
                                  "","","","","")
      returning lr_temp.cont1, lr_temp.cont2
      
      let lr_temp.viginc = lr_retorno.viginc
      let lr_temp.vigfnl = lr_retorno.vigfnl
      
      # Insiro na tabela temporaria
      call cty05g08_ins_temp(lr_temp.produto       ,
                             lr_temp.cod_produto   ,
                             lr_cty05g08.succod    ,
                             lr_cty05g08.ramcod    ,
                             lr_cty05g08.aplnumdig ,
                             lr_cty05g08.itmnumdig ,
                             lr_temp.crtsaunum     ,
                             lr_temp.bnfnum        ,
                             lr_temp.situacao      ,
                             lr_temp.cont1         ,
                             lr_temp.cont2         ,
                             lr_temp.viginc        ,
                             lr_temp.vigfnl        ,
                             lr_temp.vig           ,
                             lr_temp.documento     ,
                             lr_temp.permissao     ,
                             ""                    ,
                             ""                    ,
                             ""                    ,
                             lr_seg.segnom         ,
                             ""                    )
    end foreach

    return

end function

#------------------------------------------------------------------------------
function cty05g08_cria_temp()
#------------------------------------------------------------------------------

 call cty05g08_drop_temp()

 whenever error continue
      create temp table cty05g08_temp(produto      char(30)     ,
                                      cod_produto  smallint     ,
                                      succod       smallint     ,   #decimal(2,0) ,  #projeto succod
                                      ramcod       smallint     ,
                                      aplmundig    decimal(9,0) ,
                                      itmnumdig    decimal(7,0) ,
                                      crtsaunum    char(18)     ,
                                      bnfnum       char(20)     ,
		                                  situacao     char(30)     ,
	                                    qtdsrv       decimal(5,0) ,
                                      qtdsrvre     decimal(5,0) ,
                                      viginc       date         ,
                                      vigfnl       date         ,
                                      vig          smallint     ,
                                      documento    char(110)    ,
                                      permissao    char(1)      ,
                                      prporg       decimal(2,0) ,
                                      prpnumdig    decimal(8,0) ,
                                      sitdoc       char(70)     ,
                                      pesnom       char(70)      ,
                                      itaciacod    smallint     ) with no log
  whenever error stop

  if sqlca.sqlcode <> 0  then

	 display "sqlca.sqlcode = ",sqlca.sqlcode
	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cty05g08_drop_temp()
	  end if

	 return false

  end if

  return true

end function

#------------------------------------------------------------------------------
function cty05g08_drop_temp()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cty05g08_temp
    whenever error stop

    return

end function

#------------------------------------------------------------------------------
function cty05g08_prep_temp()
#------------------------------------------------------------------------------

    define w_ins char(1000)

    let w_ins = 'insert into cty05g08_temp'
	     , ' values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
    prepare p_cty05g08_028 from w_ins
    
end function

#------------------------------------------------------------------------------
function cty05g08_ins_temp(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       produto     char(30)                      ,
       cod_produto smallint                      ,
       succod      like datrligapol.succod       ,
       ramcod      like datrligapol.ramcod       ,
       aplnumdig   like datrligapol.aplnumdig    ,
       itmnumdig   like datrligapol.itmnumdig    ,
       crtsaunum   char(18)                      ,
       bnfnum      char(20)                      ,
       situacao    char(15)                      ,
       cont1       integer                       ,
       cont2       integer                       ,
       viginc      date                          ,
       vigfnl      date                          ,
       vig         smallint                      ,
       documento   char(110)                     ,
       permissao   char(1)                       ,
       prporg      like gcamproponente.prporg    ,
       prpnumdig   like gcamproponente.prpnumdig ,
       sitdoc      char(70)                      ,
       pesnom      like gsakpes.pesnom           ,
       itaciacod   like datkitacia.itaciacod 
end record

       whenever error continue
       execute p_cty05g08_028 using lr_param.produto       ,
                              lr_param.cod_produto   ,
                              lr_param.succod        ,
                              lr_param.ramcod        ,
                              lr_param.aplnumdig     ,
                              lr_param.itmnumdig     ,
                              lr_param.crtsaunum     ,
                              lr_param.bnfnum        ,
                              lr_param.situacao      ,
                              lr_param.cont1         ,
                              lr_param.cont2         ,
                              lr_param.viginc        ,
                              lr_param.vigfnl        ,
                              lr_param.vig           ,
                              lr_param.documento     ,
                              lr_param.permissao     ,
                              lr_param.prporg        ,
                              lr_param.prpnumdig     ,
                              lr_param.sitdoc        ,
                              lr_param.pesnom        ,
                              lr_param.itaciacod
       whenever error stop              
       
end function

function cty05g08_conta_negocio()
#------------------------------------------------------------------------------
define l_sql char(200)
define l_qtd integer
define l_resultado smallint

let l_qtd = null
let l_resultado = null

      let l_sql = " select count(*) " ,
                  " from cty05g08_temp "
      prepare pcty05g08_029 from l_sql
      declare ccty05g08_029 cursor with hold for pcty05g08_029
      
      open ccty05g08_029
      whenever error continue
      fetch ccty05g08_029 into l_qtd      
      whenever error stop
            
      if l_qtd > 0 then
         let l_resultado = 0
      else
         let l_resultado = 1
      end if
   
   return l_resultado

end function

#------------------------------------------------------------------------------
function cty05g08_rec_saude(lr_param_cgccpfnum)
#------------------------------------------------------------------------------

define lr_param_cgccpfnum like gsakpes.cgccpfnum

define lr_cty05g08 record
       succod      like datksegsau.succod     ,
       ramcod      like datksegsau.ramcod     ,
       aplnumdig   like datksegsau.aplnumdig  ,
       crtsaunum   like datksegsau.crtsaunum  ,
       crtstt      like datksegsau.crtstt     ,
       bnfnum      like datksegsau.bnfnum
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       doc_handle integer  ,
       viginc     date     ,
       vigfnl     date
end record


define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       itmnumdig   decimal(7,0) ,
       situacao    char(15)     ,
       vig         smallint     ,
       documento   char(110)    ,
       permissao   char(1)      ,
       segnom      char(70)
end record

define l_status   smallint,
       l_msg      char(80)
       
let l_status  = null
let l_msg     = null



initialize lr_retorno.* to null
initialize lr_temp.*    to null

let lr_temp.cod_produto = 98
let l_status  = null
let l_msg     = null

       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        

    open c_cty05g08_019 using lr_param_cgccpfnum
    foreach c_cty05g08_019 into   lr_cty05g08.*

       if lr_cty05g08.crtstt = 'A' then
           let lr_temp.situacao = "ATIVO"
           let lr_temp.vig = 0
       else
           let lr_temp.situacao = "CANCELADO"
           let lr_temp.vig = 1
       end if

       call cta01m15_sel_datksegsau(5,
                       lr_cty05g08.crtsaunum,
                       "",
                       "",
                       "")
                returning l_status,
                          l_msg,
                          lr_temp.segnom
       
       # Recupera a quantidade de servicos
       call cty05g08_conta_servico("","","","",
                                   lr_cty05g08.crtsaunum,
                                   "","","","")
       returning lr_temp.cont1, lr_temp.cont2
              
       # Insiro na tabela temporaria
       call cty05g08_ins_temp(lr_temp.produto       ,
                              lr_temp.cod_produto   ,
                              lr_cty05g08.succod    ,
                              lr_cty05g08.ramcod    ,
                              lr_cty05g08.aplnumdig ,
                              lr_temp.itmnumdig     ,
                              lr_cty05g08.crtsaunum ,
                              lr_cty05g08.bnfnum    ,
                              lr_temp.situacao      ,
                              lr_temp.cont1         ,
                              lr_temp.cont2         ,
                              ""                    ,
                              ""                    ,
                              lr_temp.vig           ,
                              lr_temp.documento     ,
                              lr_temp.permissao     ,
                              ""                    ,
                              ""                    ,
                              ""                    ,
                              lr_temp.segnom        ,
                              ""                    )
    end foreach

    return

end function

#------------------------------------------------------------------------------
function cty05g08_rec_cartao(lr_param)
#------------------------------------------------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    char(1)
end record

define lr_cty05g08 record
       cgccpfnumdig char(18)
end record

define lr_retorno record
       resultado  smallint ,
       mensagem   char(30) ,
       qtd        integer
end record


define lr_temp record
       cont1       integer      ,
       cont2       integer      ,
       produto     char(30)     ,
       cod_produto smallint     ,
       itmnumdig   decimal(7,0) ,
       situacao    char(15)     ,
       vig         smallint     ,
       documento   char(110)    ,
       permissao   char(1)
end record  

define lr_cta01m60 record                
      cgccpf     like gsakpes.cgccpfnum ,
      cgcord     like gsakpes.cgcord    ,
      cgccpfdig  like gsakpes.cgccpfdig ,
      pesnom     like gsakpes.pesnom    ,
      pestip     like gsakpes.pestip     
end record  

define ws record                                                            
       segnom            char (60)
end record                                                                          

initialize lr_retorno.* to null
initialize lr_temp.*    to null
initialize lr_cta01m60.* to null
initialize ws.* to null

       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        


let lr_temp.cod_produto = 97


     
     let lr_cty05g08.cgccpfnumdig = ffpfc073_formata_cgccpf(lr_param.cgccpfnum,
                                                            lr_param.cgcord   ,
                                                            lr_param.cgccpfdig)
     
      
      if lr_param.pestip = 'F' then 
         let lr_cta01m60.cgcord = 0 
      else 
         let lr_cta01m60.cgcord = lr_param.cgcord 
      end if     
            
                                         
      open c_cty05g08_030  using lr_param.pestip    ,           
                                 lr_param.cgccpfnum ,           
                                 lr_cta01m60.cgcord ,           
                                 lr_param.cgccpfdig             
      whenever error continue
      fetch c_cty05g08_030 into lr_cta01m60.pesnom              
      whenever error stop                                       
                                                                
      if sqlca.sqlcode <> 0 then                                
         display "Erro na linha 2295 ao buscar segurado "       
      end if
      
      close c_cty05g08_030                                                    
      
     call ffpfc073_qtd_prop(lr_cty05g08.cgccpfnumdig ,
                            lr_param.pestip           )
     returning lr_retorno.mensagem ,
               lr_retorno.resultado,
               lr_retorno.qtd
               
                       
        let lr_retorno.qtd = 1        
     if lr_retorno.qtd > 0 then
           let lr_temp.situacao = "ATIVO"
           let lr_temp.vig = 0           
            # Recupera a Quantidade de Servicos
            call cty05g08_conta_servico("","","","","",
                                        lr_param.cgccpfnum ,
                                        lr_param.cgcord    ,
                                        lr_param.cgccpfdig ,
                                        "" )
            returning lr_temp.cont1, lr_temp.cont2                      
            
            # Insiro na tabela temporaria
            call cty05g08_ins_temp(lr_temp.produto       ,
                                   lr_temp.cod_produto   ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   lr_temp.situacao      ,
                                   lr_temp.cont1         ,
                                   lr_temp.cont2         ,
                                   ""                    ,
                                   ""                    ,
                                   lr_temp.vig           ,
                                   lr_temp.documento     ,
                                   lr_temp.permissao     ,
                                   ""                    ,
                                   ""                    ,
                                   ""                    ,
                                   lr_cta01m60.pesnom    ,
                                   ""                    )

     end if

    return


end function


#---------------------------------------------------------------------
function cty05g08_conta_servico(lr_param)
#---------------------------------------------------------------------

define lr_param record
    succod    like datrligapol.succod    ,
    ramcod    like datrligapol.ramcod    ,
    aplnumdig like datrligapol.aplnumdig ,
    itmnumdig like datrligapol.itmnumdig ,
    crtsaunum like datksegsau.crtsaunum  ,
    cgccpfnum like gsakpes.cgccpfnum     ,
    cgcord    like gsakpes.cgcord        ,
    cgccpfdig like gsakpes.cgccpfdig     ,
    itaciacod like datkitacia.itaciacod
end record

define lr_retorno record
       cont1 integer ,
       cont2 integer
end record

define ws record
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano,
     atddat    date                      ,
     atdsrvorg like datmservico.atdsrvorg,
     inidat    date                      ,
     fimdat    date
end record

define l_result smallint

initialize ws.* to null
let l_result = null

let lr_retorno.cont1 = 0
let lr_retorno.cont2 = 0


       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        



    # Porto, Azul ou Itau

    if lr_param.aplnumdig is not null then
            
         # Itau
         
         if lr_param.itaciacod is not null then
            
            open c_cty05g08_024 using lr_param.succod   ,                        
                                      lr_param.ramcod   ,                        
                                      lr_param.aplnumdig,                        
                                      lr_param.itmnumdig,
                                      lr_param.itaciacod                         
            foreach c_cty05g08_024 into ws.atdsrvnum,                            
                                        ws.atdsrvano,                            
                                        ws.atddat   ,                            
                                        ws.atdsrvorg                             
               
                                                                  
               let lr_retorno.cont1 = lr_retorno.cont1 + 1        
                                                                  
            end foreach                                           
            
            open c_cty05g08_025 using lr_param.succod     ,                      
                                      lr_param.ramcod     ,                        
                                      lr_param.aplnumdig  ,                        
                                      lr_param.itmnumdig  ,
                                      lr_param.itaciacod                         
            foreach c_cty05g08_025 into ws.atdsrvnum,                          
                                        ws.atdsrvano,                            
                                        ws.atddat   ,                            
                                        ws.atdsrvorg                                                                                                                                                                  
                                                                               
             let lr_retorno.cont2 = lr_retorno.cont2 + 1                       
            end foreach                                                                 
               
         else  
            
            # Porto e Azul
            
            open c_cty05g08_017 using lr_param.succod   ,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig
            foreach c_cty05g08_017 into ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atddat   ,
                                        ws.atdsrvorg                        
               
               let lr_retorno.cont1 = lr_retorno.cont1 + 1
            
            end foreach
            
            open c_cty05g08_018 using lr_param.succod   ,
                                      lr_param.ramcod   ,
                                      lr_param.aplnumdig,
                                      lr_param.itmnumdig
            foreach c_cty05g08_018 into ws.atdsrvnum,
                                        ws.atdsrvano,
                                        ws.atddat   ,
                                        ws.atdsrvorg             

             let lr_retorno.cont2 = lr_retorno.cont2 + 1
            end foreach
         end if
     else
          
          # Saude
          if lr_param.crtsaunum is not null then
                 open c_cty05g08_020 using lr_param.crtsaunum
                 foreach c_cty05g08_020 into ws.atdsrvnum,
                                           ws.atdsrvano,
                                           ws.atddat   ,
                                           ws.atdsrvorg
                    
                    let lr_retorno.cont1 = lr_retorno.cont1 + 1
                 end foreach
                 
                 open c_cty05g08_021 using lr_param.crtsaunum
                 foreach c_cty05g08_021 into ws.atdsrvnum,
                                           ws.atdsrvano,
                                           ws.atddat   ,
                                           ws.atdsrvorg
                    

                    let lr_retorno.cont2 = lr_retorno.cont2 + 1
                 end foreach
          else
               
               # Cartao
               open ccty05g08_023 using lr_param.cgccpfnum ,
                                       lr_param.cgcord    ,
                                       lr_param.cgccpfdig
               foreach ccty05g08_023 into ws.atdsrvnum,
                                         ws.atdsrvano,
                                         ws.atddat   ,
                                         ws.atdsrvorg                                                                   
                       
                       let lr_retorno.cont1 = lr_retorno.cont1 + 1
               
               end foreach
               
               if lr_retorno.cont1 is not null then
                    let lr_retorno.cont2 = lr_retorno.cont1
               end if
          
          end if
      end if
      
      if lr_retorno.cont1 is null then
         let lr_retorno.cont1 = 0
      end if
      
      if lr_retorno.cont2 is null then
         let lr_retorno.cont2 = 0
      end if
    
    return lr_retorno.*

end function  

function cty05g08_busca_cidade_por_servico(lr_param)

  define lr_param     record                   
         atdsrvnum  like datmservico.atdsrvnum,
         atdsrvano  like datmservico.atdsrvano
  end record                                   
                               
  define lr_retorno record
         cidnom        like glakcid.cidnom         ,
         ufdcod        like glakcid.ufdcod         
  end record 
  
  initialize lr_retorno.* to null
  
       if m_cty05g08_prepare is null or
          m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        
  
  
  
 
  open c_cty05g08_026 using lr_param.atdsrvnum,
                            lr_param.atdsrvano
  whenever error continue   
  fetch c_cty05g08_026 into lr_retorno.cidnom,
                            lr_retorno.ufdcod
    
  whenever error stop 
  
  close c_cty05g08_026
  
  return lr_retorno.*
  
end function  

function cty05g08_busca_grupo(lr_param)
     
  define lr_param     record                          
         atdsrvnum  like datmservico.atdsrvnum,                                    
         atdsrvano  like datmservico.atdsrvano        
  end record                                          
                                                      
  define lr_retorno record                           
         socntzdes     like datksocntz.socntzdes,    
         socntzcod     like datksocntz.socntzcod,  
         socntzgrpcod  like datksocntzgrp.socntzgrpcod,
         socntzgrpdes  like datksocntzgrp.socntzgrpdes
  end record 
  
  define l_lignum    like datmligacao.lignum,
         l_c24astcod like datmligacao.c24astcod                                       
                                                     
  initialize lr_retorno.* to null                    
                                                     
       if m_cty05g08_prepare is null or
         m_cty05g08_prepare <> true then
         call cty05g08_prepare()
       end if        
      
  #let l_lignum = cts20g00_servico(lr_param.atdsrvnum, lr_param.atdsrvano)
  #
  # 
  #open c_cty05g08_027 using l_lignum
  #whenever error continue
  #fetch c_cty05g08_027 into l_c24astcod
  #whenever error stop 
  
  close c_cty05g08_027
  
  open c_cty05g08_033 using lr_param.atdsrvnum,
                           lr_param.atdsrvano
  whenever error continue 
  fetch c_cty05g08_033 into lr_retorno.socntzcod                            
  whenever error stop
  
  open c_cty05g08_034 using lr_retorno.socntzcod
                              
  whenever error continue 
  fetch c_cty05g08_034 into lr_retorno.socntzgrpcod
                              
  whenever error stop
  
  open c_cty05g08_035 using lr_retorno.socntzgrpcod
                              
  whenever error continue 
  fetch c_cty05g08_035 into lr_retorno.socntzgrpdes
                              
  whenever error stop
  
  
  
  
  #if l_c24astcod = "S63" then     
  #   let lr_retorno.socntzdes = "LINHA BRANCA"
  #else 
  #   let lr_retorno.socntzdes = "PLANO BASICO"   
  #end if    
  
  
  return lr_retorno.socntzgrpdes,lr_retorno.socntzgrpcod 
  
end function   

function cty05g08_existe_retorno(lr_param)

define lr_param record 
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano 
end record 

define lr_retorno record 
     atdsrvnum like datmservico.atdsrvnum,
     atdsrvano like datmservico.atdsrvano 
end record 

define l_atdetpcod like datmsrvacp.atdetpcod  

define l_count integer
      ,l_retorno smallint 
      
      
let l_retorno = false 
let l_count = 0      


open c_cty05g08_032 using lr_param.atdsrvnum,
                          lr_param.atdsrvano
whenever error continue 
foreach c_cty05g08_032 into lr_retorno.atdsrvnum,
                            lr_retorno.atdsrvano

         display "lr_retorno.atdsrvnum = ",lr_retorno.atdsrvnum                           
         display "lr_retorno.atdsrvano = ",lr_retorno.atdsrvano
   
   call cts10g04_ultima_etapa(lr_retorno.atdsrvnum,lr_retorno.atdsrvano) 
        returning l_atdetpcod
        
   display "l_atdetpcod = ",l_atdetpcod
   
        
        
   if l_atdetpcod <> 5 then 
      let l_count = l_count + 1       
   end if   
     
end foreach

display "l_count = ",l_count  

if l_count > 0 then 
   let l_retorno = true 
end if    

return l_retorno

end function 

function cty05g08_verifica_servico(lr_param)

define lr_param     record                          
       atdsrvnum  like datmservico.atdsrvnum,       
       atdsrvano  like datmservico.atdsrvano        
end record 

define l_count integer,
       l_retorno smallint 
       
let l_count = 0
let l_retorno = false    

if m_cty05g08_prepare is null or
   m_cty05g08_prepare <> true then
   call cty05g08_prepare()
end if        
        
if lr_param.atdsrvano is not null then 
   open c_cty05g08_037 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   whenever error continue 
     fetch c_cty05g08_037 into l_count 
   whenever error stop       
else                                                                                  
   open c_cty05g08_036 using lr_param.atdsrvnum                          
   
   whenever error continue 
    fetch c_cty05g08_036 into l_count 
   whenever error stop          
end if    
                          








if l_count > 0 then 
   let l_retorno = true 
end if 

return l_retorno

end function 

function cty05g08_pesquisa_servicos(lr_param)

   define lr_param record 
          atdsrvnum like datmservico.atdsrvnum 
   end record  
   
   define l_atdsrvnum like datmservico.atdsrvnum 
         ,l_atdsrvano like datmservico.atdsrvano
         ,l_index     integer 
   
   
   for l_index = 1 to 30 
      initialize m_qtd_servico[l_index].* to null 
   end for   
   
   if m_cty05g08_prepare is null or
      m_cty05g08_prepare <> true then
      call cty05g08_prepare()
   end if  
               
   let l_index = 0 
   open c_cty05g08_038 using lr_param.atdsrvnum
   whenever error continue 
      foreach c_cty05g08_038 into l_atdsrvnum,l_atdsrvano                        
         let l_index = l_index + 1 
         let m_qtd_servico[l_index].atdsrvnum = l_atdsrvnum
         let m_qtd_servico[l_index].atdsrvano = l_atdsrvano                  
      end foreach   
   whenever error stop                               
   close c_cty05g08_038        
  
  
  return l_index
  
end function



