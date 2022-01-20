#############################################################################
# Nome do Modulo: CTA01M11                                         Marcelo  #
#                                                                  Gilberto #
# Janela para exibicao/confirmacao de mensagem                     Nov/1997 #
#############################################################################
#---------------------------------------------------------------------------#
# 30/09/2015 Alberto-Fornax ST-2015-00089 Tarifa 09/2015                    #
#---------------------------------------------------------------------------#

 database porto
 
 globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------------------------
 function cta01m11(param)
#-----------------------------------------------------------------------------

 define param        record
    ofnnumdig        like datmlcl.ofnnumdig
 end record

 define d_cta01m11   record
    cabtxt           char (74),
    confirma         char (01),
    nomrazsoc        like gkpkpos.nomrazsoc,
    pstcoddig        like gkpkpos.pstcoddig,
    endlgd           like gkpkpos.endlgd,
    endbrr           like gkpkpos.endbrr,
    endcid           like gkpkpos.endcid,
    endufd           like gkpkpos.endufd,
    dddcod           like gkpkpos.dddcod,
    telnum1          like gkpkpos.telnum1,
    alerta1          char(74),  
    alerta2          char(74)   
 end record

 define ws           record
    confirma         char (01)
 end record


 initialize  d_cta01m11.*  to  null

 initialize  ws.*  to  null

 open window w_cta01m11 at 9,4 with form "cta01m11"
                        attribute(border, form line first, message line last - 1)

 # let d_cta01m11.cabtxt = "DOCUMENTO POSSUI BENEFICIO NA OFICINA/CONCESSIONARIA REVENDA"
 let d_cta01m11.cabtxt = "REVENDA PRODUTORA / PRIORIZAR A INDICACAO"

 let d_cta01m11.cabtxt = cta01m11_center(d_cta01m11.cabtxt)
 
 call cta13m00_valida_fabricacao(g_documento.succod     
                                ,g_documento.aplnumdig  
                                ,g_documento.itmnumdig  
                                ,g_funapol.dctnumseq
                                ,2)   
 returning d_cta01m11.alerta1, d_cta01m11.alerta2    
 
 let d_cta01m11.alerta1 = cta01m11_center(d_cta01m11.alerta1)
 let d_cta01m11.alerta2 = cta01m11_center(d_cta01m11.alerta2)
                    

 select nomrazsoc,
        pstcoddig,
        endlgd,
        endbrr,
        endcid,
        endufd,
        dddcod,
        telnum1
        into d_cta01m11.nomrazsoc,
             d_cta01m11.pstcoddig,
             d_cta01m11.endlgd,
             d_cta01m11.endbrr,
             d_cta01m11.endcid,
             d_cta01m11.endufd,
             d_cta01m11.dddcod,
             d_cta01m11.telnum1
   from gkpkpos
  where pstcoddig = param.ofnnumdig

 display by name d_cta01m11.cabtxt  attribute (reverse)
 
 if d_cta01m11.alerta1 is null or
 	  d_cta01m11.alerta1 = ' '   then
    display by name d_cta01m11.alerta1 
    display by name d_cta01m11.alerta2 
 else
 	  display by name d_cta01m11.alerta1 attribute (reverse)
    display by name d_cta01m11.alerta2 attribute (reverse)
 end if
 
 display by name d_cta01m11.nomrazsoc,
                 d_cta01m11.pstcoddig,
                 d_cta01m11.endlgd,
                 d_cta01m11.endbrr,
                 d_cta01m11.endcid,
                 d_cta01m11.endufd,
                 d_cta01m11.dddcod,
                 d_cta01m11.telnum1

 let ws.confirma = "N"

 message " (F17)Abandona"
 input by name d_cta01m11.confirma without defaults
    after field confirma
       next field confirma

    on key (interrupt, control-c)
       exit input
 end input

 let int_flag = false
 close window w_cta01m11

end function  ###  cta01m11

#-----------------------------------------------------------------------------
 function cta01m11_center(param)
#-----------------------------------------------------------------------------

 define param        record
    lintxt           char (74)
 end record

 define i            smallint
 define tamanho      dec (2,0)


	let	i  =  null
	let	tamanho  =  null

 let tamanho = (74 - length(param.lintxt))/2

 for i = 1 to tamanho
    let param.lintxt = " ", param.lintxt clipped
 end for

 return param.lintxt

end function  ###  cta01m11_center
