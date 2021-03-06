##############################################################################
# Nome do Modulo: cts06g07                                         Marcelo   #
#                                                                  Gilberto  #
# Funcoes genericas de gravacao da tabela de locais                Mar/1999  #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#--------------------------------------------------------------------------- #
# 19/09/2000  PSI 11253-4  Ruiz         Gravar codigo da oficina do destino  #
#                                       na tabela DATMLCL                    #
##############################################################################
#                    * * * Alteracoes * * *                                  #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 16/05/2005 Robson Carmo,Meta PSI191108  Receber codigo da via emergencial. #
#                                         Incluir/Alterar o codigo da via    #
#                                         emergencial.                       #
#----------------------------------------------------------------------------#
# 20/06/2007 M Federicce       PSI209694  Incluir historico da indexacao     #
#                                         (cts06g07_historico_indexacao)     #
#----------------------------------------------------------------------------#
# 02/07/2008  Carla Rampazzo              g_origem identifica quem chama:    #
#                                         "IFX"/null=Informix / "WEB"=Portal #
#----------------------------------------------------------------------------#
# 21/10/2015  Eliane Kawachiya, Fornax    Retirar os carcteres /,\,| do param#
#                                         lclrefptotxt, substitui por branco #
#----------------------------------------------------------------------------#
# 29/10/2015  Eliane, Fornax              Tratar erro de 21/10/2015 - clipped#
#----------------------------------------------------------------------------#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts06g07_prep smallint

#-------------------------#
function cts06g07_prepare()
#-------------------------#
 define l_sql char(1000)

 let l_sql = ' insert into datmlcl(atdsrvnum '
                               ,' ,atdsrvano '
                               ,' ,c24endtip '
                               ,' ,lclidttxt '
                               ,' ,lgdtip '
                               ,' ,lgdnom '
                               ,' ,lgdnum '
                               ,' ,lclbrrnom '
                               ,' ,brrnom '
                               ,' ,cidnom '
                               ,' ,ufdcod '
                               ,' ,lclrefptotxt '
                               ,' ,endzon '
                               ,' ,lgdcep '
                               ,' ,lgdcepcmp '
                               ,' ,lclltt '
                               ,' ,lcllgt '
                               ,' ,dddcod '
                               ,' ,lcltelnum '
                               ,' ,lclcttnom '
                               ,' ,c24lclpdrcod '
                               ,' ,ofnnumdig '
                               ,' ,emeviacod '
                               ,' ,celteldddcod '
                               ,' ,celtelnum '
                               ,' ,endcmp )'
            ,' values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) '
 prepare pcts06g07001 from l_sql
 let l_sql = ' update datmlcl set (lclidttxt '
                               ,' ,lgdtip  '
                               ,' ,lgdnom  '
                               ,' ,lgdnum  '
                               ,' ,lclbrrnom '
                               ,' ,brrnom '
                               ,' ,cidnom '
                               ,' ,ufdcod '
                               ,' ,lclrefptotxt '
                               ,' ,endzon '
                               ,' ,lgdcep '
                               ,' ,lgdcepcmp '
                               ,' ,lclltt '
                               ,' ,lcllgt '
                               ,' ,dddcod '
                               ,' ,lcltelnum '
                               ,' ,lclcttnom '
                               ,' ,c24lclpdrcod '
                               ,' ,ofnnumdig '
                               ,' ,emeviacod '
                               ,' ,celteldddcod '
                               ,' ,celtelnum '
                               ,' ,endcmp ) = '
                               ,' (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) '
                         ,' where atdsrvnum  =  ? '
                           ,' and atdsrvano  =  ? '
                           ,' and c24endtip  =  ? '
 prepare pcts06g07002 from l_sql
 let m_cts06g07_prep = true

end function
#----------------------------------------------------------------------------
 function cts06g07_local (param)
#----------------------------------------------------------------------------

 define param      record
    operacao       char (01),
    atdsrvnum      like datmlcl.atdsrvnum,
    atdsrvano      like datmlcl.atdsrvano,
    c24endtip      like datmlcl.c24endtip,
    lclidttxt      like datmlcl.lclidttxt,
    lgdtip         like datmlcl.lgdtip,
    lgdnom         like datmlcl.lgdnom,
    lgdnum         like datmlcl.lgdnum,
    lclbrrnom      like datmlcl.lclbrrnom,
    brrnom         like datmlcl.brrnom,
    cidnom         like datmlcl.cidnom,
    ufdcod         like datmlcl.ufdcod,
    lclrefptotxt   like datmlcl.lclrefptotxt,
    endzon         like datmlcl.endzon,
    lgdcep         like datmlcl.lgdcep,
    lgdcepcmp      like datmlcl.lgdcepcmp,
    lclltt         like datmlcl.lclltt,
    lcllgt         like datmlcl.lcllgt,
    dddcod         like datmlcl.dddcod,
    lcltelnum      like datmlcl.lcltelnum,
    lclcttnom      like datmlcl.lclcttnom,
    c24lclpdrcod   like datmlcl.c24lclpdrcod,
    ofnnumdig      like datmlcl.ofnnumdig,
    emeviacod      like datmlcl.emeviacod,
    celteldddcod   like datmlcl.celteldddcod,
    celtelnum      like datmlcl.celtelnum,
    endcmp         like datmlcl.endcmp
 end record

 define ws         record
    sqlcode        integer
 end record
 define lr_retorno record
     resultado  integer ,
     mensagem   char(50),
     segnumdig  like abbmdoc.segnumdig
 end record

#chamado 602475
 define i                     integer
 define l_tam                 integer
 define l_lclrefptotxt        varchar(250,0)
#fim


 if m_cts06g07_prep is null or
    m_cts06g07_prep <> true then
    call cts06g07_prepare()
 end if

 initialize ws.*, lr_retorno.*   to null

#---------------------------------------------
# chamado 602475 - alterado por Eliane/Fornax
#     Retirado os caracteres /,\,| por branco
#       para nao truncar  msg gps
#---------------------------------------------
  let i = 1
  let l_tam = length(param.lclrefptotxt)
  let l_lclrefptotxt = null
  while i <= l_tam
      if ( (param.lclrefptotxt[i,i] = "/") OR
	 (param.lclrefptotxt[i,i] = ascii(92) ) OR       #"\"
         (param.lclrefptotxt[i,i] = "|") )   then
          let l_lclrefptotxt = l_lclrefptotxt, " "
    else
       let l_lclrefptotxt = l_lclrefptotxt, param.lclrefptotxt[i,i]
    end if
   let i = i+1
  end while
  let param.lclrefptotxt = l_lclrefptotxt

#--------Fim chamado 602475-------------------
 if param.operacao  is null   then
    if g_origem is null   or
       g_origem =  "IFX"  then
       error " Tipo de operacao nao informado. AVISE A INFORMATICA!"
    end if
    return ws.sqlcode
 end if

 if param.operacao  <>  "I"   and
    param.operacao  <>  "M"   and
    param.operacao  <>  "D"   then
    if g_origem is null   or
       g_origem =  "IFX"  then
       error " Tipo de operacao (",param.operacao,") incorreto. AVISE A INFORMATICA!"
    end if
    return ws.sqlcode
 end if

 if param.atdsrvnum  is null   or
    param.atdsrvano  is null   then
    if g_origem is null   or
       g_origem =  "IFX"  then
       error " Numero do servico nao informado. AVISE A INFORMATICA!"
    end if
    return ws.sqlcode
 end if

 #----------------------------------------------------------------------
 # Grava dados do local
 #----------------------------------------------------------------------
  whenever error continue

 if param.c24endtip = 1  then # 1-origem , 2-destino
    initialize param.ofnnumdig to null
 end if
 if  (param.brrnom is not null and param.brrnom <> " ") and
     (param.lclbrrnom is null or param.lclbrrnom = " ") then
     let param.lclbrrnom = param.brrnom
 end if
 if  (param.brrnom is null or param.brrnom = " ") and
     (param.lclbrrnom is not null and param.lclbrrnom <> " ") then
     let param.brrnom = param.lclbrrnom
 end if

 if param.lclbrrnom is null then
 	  let param.lclbrrnom = '.'
 end if
 if param.operacao  =  "I"   then
    execute pcts06g07001 using  param.atdsrvnum
                               ,param.atdsrvano
                               ,param.c24endtip
                               ,param.lclidttxt
                               ,param.lgdtip
                               ,param.lgdnom
                               ,param.lgdnum
                               ,param.lclbrrnom
                               ,param.brrnom
                               ,param.cidnom
                               ,param.ufdcod
                               ,param.lclrefptotxt
                               ,param.endzon
                               ,param.lgdcep
                               ,param.lgdcepcmp
                               ,param.lclltt
                               ,param.lcllgt
                               ,param.dddcod
                               ,param.lcltelnum
                               ,param.lclcttnom
                               ,param.c24lclpdrcod
                               ,param.ofnnumdig
                               ,param.emeviacod
                               ,param.celteldddcod
                               ,param.celtelnum
                               ,param.endcmp
    if sqlca.sqlcode  <>  0   then
       let ws.sqlcode = sqlca.sqlcode
       return ws.sqlcode
    end if
 end if


 if param.operacao  =  "D"   then
    select c24lclpdrcod
      from datmlcl
     where atdsrvnum  =  param.atdsrvnum
       and atdsrvano  =  param.atdsrvano
       and c24endtip  =  param.c24endtip

    if sqlca.sqlcode = 0  then
       delete from datmlcl
        where atdsrvnum  =  param.atdsrvnum  and
              atdsrvano  =  param.atdsrvano  and
              c24endtip  =  param.c24endtip
    else
       let ws.sqlcode = 0
       return ws.sqlcode
    end if
 end if

 if param.operacao  =  "M"   then
    execute pcts06g07002 using param.lclidttxt
                              ,param.lgdtip
                              ,param.lgdnom
                              ,param.lgdnum
                              ,param.lclbrrnom
                              ,param.brrnom
                              ,param.cidnom
                              ,param.ufdcod
                              ,param.lclrefptotxt
                              ,param.endzon
                              ,param.lgdcep
                              ,param.lgdcepcmp
                              ,param.lclltt
                              ,param.lcllgt
                              ,param.dddcod
                              ,param.lcltelnum
                              ,param.lclcttnom
                              ,param.c24lclpdrcod
                              ,param.ofnnumdig
                              ,param.emeviacod
                              ,param.celteldddcod
                              ,param.celtelnum
                              ,param.endcmp
                              ,param.atdsrvnum
                              ,param.atdsrvano
                              ,param.c24endtip
 end if

 if sqlca.sqlcode  <>  0   then
    let ws.sqlcode = sqlca.sqlcode
    return ws.sqlcode
 end if

 whenever error stop

 let ws.sqlcode = sqlca.sqlcode

 if param.c24endtip = 1 then # endereco origem
     call cts06g07_historico_indexacao (param.atdsrvnum
				      , param.atdsrvano
                                      , param.lgdtip
                                      , param.lgdnom
                                      , param.lgdnum
                                      , param.brrnom
                                      , param.cidnom
                                      , param.ufdcod
                                      , param.c24lclpdrcod)
 end if

 if param.c24endtip = 1    and
 	  param.operacao  = "I" then


 	  if g_documento.ciaempcod = 84 then

       if g_documento.ramcod = 31 then
           #--------------------------------------------------------
           # Grava Endereco Indexado Itau Auto
           #--------------------------------------------------------

           call cts52m00_grava_endereco_itau(g_doc_itau[1].itaciacod
                                            ,g_doc_itau[1].itaramcod
                                            ,g_doc_itau[1].itaaplnum
                                            ,g_doc_itau[1].aplseqnum
                                            ,param.lclltt
                                            ,param.lcllgt
                                            ,param.lgdtip
                                            ,param.lgdnom
                                            ,param.brrnom
                                            ,param.lclbrrnom
                                            ,param.lgdcep
                                            ,param.lgdcepcmp
                                            ,param.c24lclpdrcod      )
        else
        	 #--------------------------------------------------------
        	 # Grava Endereco Indexado Itau RE
        	 #--------------------------------------------------------
        	 call cts55m00_grava_endereco_itau(g_doc_itau[1].itaciacod
        	                                  ,g_doc_itau[1].itaramcod
        	                                  ,g_doc_itau[1].itaaplnum
        	                                  ,g_doc_itau[1].aplseqnum
        	                                  ,param.lclltt
        	                                  ,param.lcllgt
        	                                  ,param.lgdtip
        	                                  ,param.lgdnom
        	                                  ,param.brrnom
        	                                  ,param.lclbrrnom
        	                                  ,param.lgdcep
        	                                  ,param.lgdcepcmp
        	                                  ,param.c24lclpdrcod      )
        end if

    end if


    if g_documento.ciaempcod = 35 then

    	#--------------------------------------------------------
      # Grava Endereco Indexado Azul
      #--------------------------------------------------------

       call cts53m00_grava_endereco_azul(g_indexado.azlaplcod
                                        ,param.lclltt
                                        ,param.lcllgt
                                        ,param.lgdtip
                                        ,param.lgdnom
                                        ,param.brrnom
                                        ,param.lclbrrnom
                                        ,param.lgdcep
                                        ,param.lgdcepcmp
                                        ,param.c24lclpdrcod      )

    end if


    if g_documento.ciaempcod = 01 then
       #--------------------------------------------------------
       # Grava Endereco Indexado Porto RE
       #--------------------------------------------------------
       if g_rsc_re.lclrsccod is not null and
          g_rsc_re.lclrsccod <> 0       then
          call cts56m00_grava_endereco_porto_re(g_rsc_re.lclrsccod
                                               ,param.lclltt
                                               ,param.lcllgt)
       end if
       if g_documento.ramcod = 31  or
        	g_documento.ramcod = 531 then
          #--------------------------------------------------------
          # Grava Endereco Indexado Porto Auto
          #--------------------------------------------------------
          call cty05g00_segnumdig(g_documento.succod    ,
                                  g_documento.aplnumdig ,
                                  g_documento.itmnumdig ,
                                  g_funapol.dctnumseq   ,
                                  g_documento.prporg    ,
                                  g_documento.prpnumdig )
          returning lr_retorno.resultado,
                    lr_retorno.mensagem ,
                    lr_retorno.segnumdig
          call cts56m00_grava_endereco_porto_auto(lr_retorno.segnumdig,
                                                  param.lclltt        ,
                                                  param.lcllgt        )
       end if
    end if
 end if


 return ws.sqlcode

 end function  ###  cts06g07_local

#-----------------------------------------------------------
 function cts06g07_historico_indexacao(param)
#-----------------------------------------------------------

 define param record
    atdsrvnum          like datmsrvidxhst.atdsrvnum,
    atdsrvano          like datmsrvidxhst.atdsrvano,
    lgdtip             like datmsrvidxhst.lgdtip,
    lgdnom             like datmsrvidxhst.lgdnom,
    lgdnum             like datmsrvidxhst.lgdnum,
    brrnom             like datmsrvidxhst.brrnom,
    cidnom             like datmsrvidxhst.cidnom,
    ufdcod             like datmsrvidxhst.ufdcod,
    c24lclpdrcod       like datmsrvidxhst.c24lclpdrcod
 end record

 define l_srvidxseq    like datmsrvidxhst.srvidxseq
 define l_lgdtip       like datmsrvidxhst.lgdtip
 define l_lgdnom       like datmsrvidxhst.lgdnom
 define l_lgdnum       like datmsrvidxhst.lgdnum
 define l_brrnom       like datmsrvidxhst.brrnom
 define l_cidnom       like datmsrvidxhst.cidnom
 define l_ufdcod       like datmsrvidxhst.ufdcod
 define l_c24lclpdrcod like datmsrvidxhst.c24lclpdrcod

 initialize l_srvidxseq,
            l_lgdtip,
            l_lgdnom,
            l_lgdnum,
            l_brrnom,
            l_cidnom,
            l_ufdcod,
            l_c24lclpdrcod to null

 whenever error continue

 select   srvidxseq,
          lgdtip,
          lgdnom,
          lgdnum,
          brrnom,
          cidnom,
          ufdcod,
          c24lclpdrcod
     into l_srvidxseq,
          l_lgdtip,
          l_lgdnom,
          l_lgdnum,
          l_brrnom,
          l_cidnom,
          l_ufdcod,
          l_c24lclpdrcod
     from datmsrvidxhst
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
      and srvidxseq = ( select max(srvidxseq)
                          from datmsrvidxhst
                         where atdsrvnum = param.atdsrvnum
                           and atdsrvano = param.atdsrvano )

 if l_srvidxseq is null then
    let l_srvidxseq = 1
 else
    if param.lgdtip       <> l_lgdtip or
       param.lgdnom       <> l_lgdnom or
       param.lgdnum       <> l_lgdnum or
       param.brrnom       <> l_brrnom or
       param.cidnom       <> l_cidnom or
       param.ufdcod       <> l_ufdcod or
       param.c24lclpdrcod <> l_c24lclpdrcod then
          let l_srvidxseq = l_srvidxseq + 1
    else
        let l_srvidxseq = null
    end if
 end if

 if l_srvidxseq is not null then
     insert into datmsrvidxhst ( atdsrvnum,
                                 atdsrvano,
                                 srvidxseq,
                                 atddat,
                                 atdhor,
                                 funmat,
                                 empcod,
                                 usrtip,
                                 lgdtip,
                                 lgdnom,
                                 lgdnum,
                                 brrnom,
                                 cidnom,
                                 ufdcod,
                                 c24lclpdrcod )
                        values ( param.atdsrvnum,
                                 param.atdsrvano,
                                 l_srvidxseq,
                                 today,
                                 current hour to second,
                                 g_issk.funmat,
                                 g_issk.empcod,
                                 g_issk.usrtip,
                                 param.lgdtip,
                                 param.lgdnom,
                                 param.lgdnum,
                                 param.brrnom,
                                 param.cidnom,
                                 param.ufdcod,
                                 param.c24lclpdrcod )
     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na inclusao do historico da indexacao!"
        sleep 3
     end if
 end if
 whenever error stop

end function
