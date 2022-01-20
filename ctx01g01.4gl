#############################################################################
# Nome do Modulo: CTX01G01                                         Marcelo  #
#                                                                  Gilberto #
# Verifica se apolice possui clausula Carro Extra vigente          Mar/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 29/10/1998  PSI 6903-5   Gilberto     Incluir clausula 80 (Carro Extra p/ #
#                                       taxistas), nos moldes da claus. 26  #
# 25/05/2011 Ligia - Fornax Nova funcao ctx01g01_claus_novo para considerar #
#                           todas as clausulas de carro-extra               #
#---------------------------------------------------------------------------#
# 10/07/2013 Gabriel, Fornax  Alteracao da funcao ctx01g01_claus_novo para  #
#                             tratar o problema P13070041 onde há ao mesmo  #
#                             tempo uma clausula 47 e uma clausula 26 para  #
#                             a mesma apólice.                              #
#############################################################################

database porto

#------------------------------------------------------------------
 function ctx01g01_claus(param)
#------------------------------------------------------------------

 define param        record
    succod           like abbmitem.succod      ,
    aplnumdig        like abbmitem.aplnumdig   ,
    itmnumdig        like abbmitem.itmnumdig   ,
    vigcls           date                      ,
    privez           smallint
 end record

 define d_ctx01g01   record
    clscod           like abbmclaus.clscod     ,
    viginc           like abbmclaus.viginc     ,
    vigfnl           like abbmclaus.vigfnl
 end record
--

	initialize  d_ctx01g01.*  to  null

 initialize d_ctx01g01.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  or
    param.vigcls    is null  then
    return d_ctx01g01.*
 end if

 if param.privez = true  then
    call ctx01g01_prepare()
 end if

 call ctx01g01_select(param.succod   , param.aplnumdig,
                      param.itmnumdig, param.vigcls   )
            returning d_ctx01g01.*
 return d_ctx01g01.*

end function  ###  ctx01g01


#------------------------------------------------------------------
 function ctx01g01_prepare()
#------------------------------------------------------------------

 define sql  char (400)


	let	sql  =  null

 let sql = "select clscod, dctnumseq,        ",
           "       viginc, vigfnl            ",
           "  from abbmclaus                 ",
           " where succod     =  ?    and    ",
           "       aplnumdig  =  ?    and    ",
           "       itmnumdig  =  ?    and    ",
           #"       viginc     <= ?    and    ",
           #"       vigfnl     >= ?    and    ",
           "       (clscod[1,2] in ('26','80') or",
           "       clscod in ('033','33R'))",--varani
           " order by dctnumseq desc         "

 prepare p_ctx01g01_001  from sql
 declare c_ctx01g01_001  cursor with hold for p_ctx01g01_001

 ## sql para atender a nova regra
 let sql = "select clscod, dctnumseq,        ",
           "       viginc, vigfnl            ",
           "  from abbmclaus                 ",
           " where succod     =  ?    and    ",
           "       aplnumdig  =  ?    and    ",
           "       itmnumdig  =  ?    and    ",
           "    ( clscod[1,2] in ('26','80','33','35','46','47') or ",
           "         clscod in ('033','034','035','044','44R','046','047','048','48R')) ",
           " order by dctnumseq desc         "

 prepare p_ctx01g01_006  from sql
 declare c_ctx01g01_006  cursor with hold for p_ctx01g01_006


 let sql = "select edstip, viginc       ",
           "  from abbmdoc              ",
           " where succod     =  ?  and ",
           "       aplnumdig  =  ?  and ",
           "       itmnumdig  =  ?  and ",
           "       dctnumseq  =  ?      "

 prepare p_ctx01g01_002  from sql
 declare c_ctx01g01_002  cursor with hold for p_ctx01g01_002

 let sql = "select edsoprcod ",
           "  from agdktip   ",
           " where edstip = ?"

 prepare p_ctx01g01_003 from sql
 declare c_ctx01g01_003 cursor with hold for p_ctx01g01_003

 let sql = "select edsstt, edsquecan  ",
           "  from abamdoc            ",
           " where succod    = ?   and",
           "       aplnumdig = ?   and",
           "       dctnumseq = ?      "

 prepare p_ctx01g01_004 from sql
 declare c_ctx01g01_004 cursor with hold for p_ctx01g01_004

 let sql = "select dctnumseq from abamdoc",
           " where succod    = ?   and",
           "       aplnumdig = ?   and",
           "       edsnumdig = ?      "

 prepare p_ctx01g01_005 from sql
 declare c_ctx01g01_005 cursor with hold for p_ctx01g01_005

end function  ###  ctx01g01_prepare


#------------------------------------------------------------------
 function ctx01g01_select(param)
#------------------------------------------------------------------

 define param        record
    succod           like abbmitem.succod      ,
    aplnumdig        like abbmitem.aplnumdig   ,
    itmnumdig        like abbmitem.itmnumdig   ,
    vigcls           date
 end record

 define d_ctx01g01   record
    clscod           like abbmclaus.clscod     ,
    viginc           like abbmclaus.viginc     ,
    vigfnl           like abbmclaus.vigfnl
 end record

 define ws           record
    dctnumseq        like abbmclaus.dctnumseq  ,
    edstip           like abbmdoc.edstip       ,
    edsoprcod        like agdktip.edsoprcod    ,
    edsstt           like abamdoc.edsstt       ,
    edsquecan        like abamdoc.edsquecan    ,
    dctnumcan        like abamdoc.dctnumseq    ,
    viginc           like abbmclaus.viginc
 end record



	initialize  d_ctx01g01.*  to  null

	initialize  ws.*  to  null

 initialize d_ctx01g01.*  to null
 initialize ws.*          to null

 open    c_ctx01g01_001  using param.succod   , param.aplnumdig, param.itmnumdig
                              ##param.vigcls   , param.vigcls
 foreach c_ctx01g01_001  into  d_ctx01g01.clscod,
                              ws.dctnumseq     ,
                              d_ctx01g01.viginc,
                              d_ctx01g01.vigfnl


#------------------------------------------------------------------
# Verifica status do endosso: (A)tivo ou (C)ancelado
#------------------------------------------------------------------
    open  c_ctx01g01_004 using param.succod, param.aplnumdig, ws.dctnumseq
    fetch c_ctx01g01_004 into  ws.edsstt, ws.edsquecan
    close c_ctx01g01_004

    if ws.edsstt = "C"  then
       open  c_ctx01g01_005 using param.succod, param.aplnumdig, ws.edsquecan
       fetch c_ctx01g01_005 into  ws.dctnumcan
       close c_ctx01g01_005

#------------------------------------------------------------------
# Se cancelado, vig.final igual a vig.inicial do endosso cancelamento
#------------------------------------------------------------------
       initialize ws.viginc  to null

       open  c_ctx01g01_002 using param.succod   , param.aplnumdig,
                           param.itmnumdig, ws.dctnumcan
       fetch c_ctx01g01_002 into  ws.edstip, ws.viginc
       close c_ctx01g01_002

       if ws.viginc - 1 units day >= param.vigcls  then
          let d_ctx01g01.vigfnl = ws.viginc - 1 units day
       else
          initialize d_ctx01g01.* to null
          continue foreach
       end if
    end if

    initialize ws.edstip  to null

#------------------------------------------------------------------
# Verifica se endosso nao e' um endosso de cancelamento
#------------------------------------------------------------------
    open  c_ctx01g01_002 using param.succod   , param.aplnumdig,
                        param.itmnumdig, ws.dctnumseq
    fetch c_ctx01g01_002 into  ws.edstip, ws.viginc
    close c_ctx01g01_002

    open  c_ctx01g01_003  using ws.edstip
    fetch c_ctx01g01_003  into  ws.edsoprcod
    close c_ctx01g01_003

    if ws.edsoprcod <> 1  then  ###  1-Emiss.Normal/2-Cancelamento/3-Reativacao
       initialize d_ctx01g01.* to null
       continue foreach
    else
       exit foreach
    end if
 end foreach

 return d_ctx01g01.*

end function  ###  ctx01g01_select

#------------------------------------------------------------------
 function ctx01g01_claus_novo(param, l_motivo)
#------------------------------------------------------------------

 define param        record
    succod           like abbmitem.succod      ,
    aplnumdig        like abbmitem.aplnumdig   ,
    itmnumdig        like abbmitem.itmnumdig   ,
    vigcls           date                      ,
    privez           smallint
 end record
 define l_motivo     like datmavisrent.avialgmtv

 define d_ctx01g01   record
    clscod           like abbmclaus.clscod,
    viginc           like abbmclaus.viginc,
    vigfnl           like abbmclaus.vigfnl
 end record

 initialize d_ctx01g01.*  to null

 if param.succod    is null  or
    param.aplnumdig is null  or
    param.itmnumdig is null  or
    param.vigcls    is null  then
    return d_ctx01g01.*
 end if

 if param.privez = true  then
    call ctx01g01_prepare()
 end if

 call ctx01g01_select_novo(param.succod   , param.aplnumdig,
                      param.itmnumdig, param.vigcls, l_motivo)
      returning d_ctx01g01.*

 return d_ctx01g01.*

end function  ###  ctx01g01_claus_novo

#------------------------------------------------------------------
 function ctx01g01_select_novo(param, l_motivo)
#------------------------------------------------------------------

 define param        record
    succod           like abbmitem.succod      ,
    aplnumdig        like abbmitem.aplnumdig   ,
    itmnumdig        like abbmitem.itmnumdig   ,
    vigcls           date
 end record

 define d_ctx01g01   record
    clscod           like abbmclaus.clscod     ,
    viginc           like abbmclaus.viginc     ,
    vigfnl           like abbmclaus.vigfnl
 end record

 define ws           record
    dctnumseq        like abbmclaus.dctnumseq  ,
    edstip           like abbmdoc.edstip       ,
    edsoprcod        like agdktip.edsoprcod    ,
    edsstt           like abamdoc.edsstt       ,
    edsquecan        like abamdoc.edsquecan    ,
    dctnumcan        like abamdoc.dctnumseq    ,
    viginc           like abbmclaus.viginc
 end record

 define l_motivo     like datmavisrent.avialgmtv


	initialize  d_ctx01g01.*  to  null

	initialize  ws.*  to  null

 initialize d_ctx01g01.*  to null
 initialize ws.*          to null

 open    c_ctx01g01_006 using param.succod, param.aplnumdig, param.itmnumdig
 foreach c_ctx01g01_006 into d_ctx01g01.clscod,
                             ws.dctnumseq,
                             d_ctx01g01.viginc,
                             d_ctx01g01.vigfnl

 if d_ctx01g01.clscod = "034" then
    if cta13m00_verifica_clausula(param.succod        ,
                                  param.aplnumdig     ,
                                  param.itmnumdig     ,
                                  ws.dctnumseq ,
                                  d_ctx01g01.clscod           ) then
       continue foreach
    end if
 end if



#------------------------------------------------------------------
# Verifica status do endosso: (A)tivo ou (C)ancelado
#------------------------------------------------------------------
    open  c_ctx01g01_004 using param.succod, param.aplnumdig, ws.dctnumseq
    fetch c_ctx01g01_004 into  ws.edsstt, ws.edsquecan
    close c_ctx01g01_004


    if ws.edsstt = "C"  then
       open  c_ctx01g01_005 using param.succod, param.aplnumdig, ws.edsquecan
       fetch c_ctx01g01_005 into  ws.dctnumcan
       close c_ctx01g01_005

#------------------------------------------------------------------
# Se cancelado, vig.final igual a vig.inicial do endosso cancelamento
#------------------------------------------------------------------
       initialize ws.viginc  to null

       open  c_ctx01g01_002 using param.succod   , param.aplnumdig,
                           param.itmnumdig, ws.dctnumcan
       fetch c_ctx01g01_002 into  ws.edstip, ws.viginc
       close c_ctx01g01_002

       if ws.viginc - 1 units day >= param.vigcls  then
          let d_ctx01g01.vigfnl = ws.viginc - 1 units day
       else
          initialize d_ctx01g01.* to null
          continue foreach
       end if
    end if

    initialize ws.edstip  to null

#------------------------------------------------------------------
# Verifica se endosso nao e' um endosso de cancelamento
#------------------------------------------------------------------
    open  c_ctx01g01_002 using param.succod   , param.aplnumdig,
                        param.itmnumdig, ws.dctnumseq
    fetch c_ctx01g01_002 into  ws.edstip, ws.viginc
    close c_ctx01g01_002

    open  c_ctx01g01_003  using ws.edstip
    fetch c_ctx01g01_003  into  ws.edsoprcod
    close c_ctx01g01_003

    if l_motivo <> 1 then
    	continue foreach
    end if
    if ws.edsoprcod <> 1  then  ###  1-Emiss.Normal/2-Cancelamento/3-Reativacao
       initialize d_ctx01g01.* to null
       continue foreach
    else
       exit foreach
    end if
 end foreach


 return d_ctx01g01.*

end function  ###  ctx01g01_select_novo
