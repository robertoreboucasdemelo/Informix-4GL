###############################################################################
# Nome do Modulo: CTS06G08                                           Marcelo  #
#                                                                    Gilberto #
# Funcoes Genericas - Consulta de endereco padronizada               Mar/1999 #
###############################################################################
# 13/08/2009   Sergio Burini  PSI 244236  Inclusão do Sub-Dairro              #
###############################################################################

 database porto

#-----------------------------------------------------------
 function cts06g08(param)
#-----------------------------------------------------------

 define param        record
    atdsrvnum        like datmlcl.atdsrvnum,
    atdsrvano        like datmlcl.atdsrvano,
    c24endtip        like datmlcl.c24endtip
 end record

 define d_cts06g08   record
    lclidttxt        like datmlcl.lclidttxt,
    lgdtxt           char (80),
    lclbrrnom        like datmlcl.lclbrrnom,
    endzon           like datmlcl.endzon,
    cidnom           like datmlcl.cidnom,
    ufdcod           like datmlcl.ufdcod,
    lgdcep           like datmlcl.lgdcep,
    lgdcepcmp        like datmlcl.lgdcepcmp,
    dddcod           like datmlcl.dddcod,
    lcltelnum        like datmlcl.lcltelnum,
    lclcttnom        like datmlcl.lclcttnom,
    lclrefptotxt     like datmlcl.lclrefptotxt
 end record

 define ws           record
    cabtxt           char (68),
    cpodes           like iddkdominio.cpodes,
    lgdtip           like datmlcl.lgdtip,
    lgdnom           like datmlcl.lgdnom,
    lgdnum           like datmlcl.lgdnum,
    brrnom           like datmlcl.brrnom,
    c24lclpdrcod     like datmlcl.c24lclpdrcod,
    sqlcode          integer,
    endcmp           like datmlcl.endcmp
 end record

 define arr_aux      smallint
 define prompt_key   char (01)


 initialize ws.*         to null
 initialize d_cts06g08.* to null

 #---------------------------------------------------------------------
 # Verifica tipo de local a ser informado
 #---------------------------------------------------------------------
 if param.c24endtip is null   then
    error " Tipo do local nao informado. AVISE A INFORMATICA!"
    return
 end if

 select cpodes
   into ws.cpodes
   from iddkdominio
  where iddkdominio.cponom  =  "c24endtip"
    and iddkdominio.cpocod  =  param.c24endtip

 if sqlca.sqlcode  <>  0    then
    error " Tipo do local (", param.c24endtip  using "<<<<&",
          ") nao cadastrado. AVISE A INFORMATICA!"
    return
 end if

 let ws.cabtxt  =  "                 Informacoes do local de ", downshift(ws.cpodes)

 #--------------------------------------------------------------------
 # Busca informacoes do local (conforme parametro)
 #--------------------------------------------------------------------
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              param.c24endtip)
                    returning d_cts06g08.lclidttxt   ,
                              ws.lgdtip              ,
                              ws.lgdnom              ,
                              ws.lgdnum              ,
                              d_cts06g08.lclbrrnom   ,
                              ws.brrnom              ,
                              d_cts06g08.cidnom      ,
                              d_cts06g08.ufdcod      ,
                              d_cts06g08.lclrefptotxt,
                              d_cts06g08.endzon      ,
                              d_cts06g08.lgdcep      ,
                              d_cts06g08.lgdcepcmp   ,
                              d_cts06g08.dddcod      ,
                              d_cts06g08.lcltelnum   ,
                              d_cts06g08.lclcttnom   ,
                              ws.c24lclpdrcod        ,
                              ws.sqlcode             ,
                              ws.endcmp 

 if ws.sqlcode  <>  0   then
    if param.c24endtip  =  1   then    #--> Local da ocorrencia
       error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura local codigo ",
             param.c24endtip using "<<<<&", ". AVISE A INFORMATICA!"
       return
    else
       if ws.sqlcode  <>  100   then
          error " Erro (", ws.sqlcode using "<<<<<&", ") na leitura local codigo ",
                param.c24endtip using "<<<<&", ". AVISE A INFORMATICA!"
          return
       end if
    end if
 end if

 if ws.sqlcode  =  100   then
    error " Nao foi informado destino para este servico!"
 else
    let d_cts06g08.lgdtxt = ws.lgdtip clipped, " ",
                            ws.lgdnom clipped, " ",
                            ws.lgdnum using "<<<<#", " ",
                            ws.endcmp clipped 

    # PSI 244589 - Inclusão de Sub-Bairro - Burini
    call cts06g10_monta_brr_subbrr(ws.brrnom,
                                   d_cts06g08.lclbrrnom)
         returning d_cts06g08.lclbrrnom                                                                   

    open window cts06g08 at 11,04 with form "cts06g08"
                attribute(border,form line 1)

    display by name ws.cabtxt
    display by name d_cts06g08.*

    prompt " (F17)Abandona" for char prompt_key
    close window cts06g08
 end if

end function    ###--- cts06g08
