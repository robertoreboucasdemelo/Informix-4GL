#############################################################################
# Nome do Modulo: CTN27C01                                          Marcelo #
#                                                                  Gilberto #
# Espelho do retorno do fax                                        Set/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/10/1998  PSI 6966-3   Gilberto     Incluir novo codigo de status do    #
#                                       servidor VSI-Fax.                   #
#############################################################################

database porto

#-----------------------------------------------------------
 function ctn27c01(par)
#-----------------------------------------------------------

 define  par           record
    faxsiscod          like datmfax.faxsiscod   ,
    faxsubcod          like datmfax.faxsubcod   ,
    faxch1             like datmfax.faxch1      ,
    faxch2             like datmfax.faxch2      ,
    faxenvdat          like datmfax.faxenvdat   ,
    faxenvhor          like datmfax.faxenvhor
 end record

 define  d_ctn27c01    record
    faxsubdsc          char(11)                 ,
    telnum             like gfxmfax.telnum      ,
    faxdstdes          like gfxmfax.faxdstdes   ,
    faxdat             like gfxmfax.faxdat      ,
    faxhor             like gfxmfax.faxhor      ,
    faxtrxtmp          like gfxmfax.faxtrxtmp   ,
    faxpagtotqtd       like gfxmfax.faxpagtotqtd,
    faxtrxpagqtd       like gfxmfax.faxtrxpagqtd,
    faxsttcod          like gfxmfax.faxsttcod   ,
    faxstttxt          char (60)                ,
    faxrdsqtd          like gfxmfax.faxrdsqtd   ,
    faxidecod          like gfxmfax.faxidecod
 end record

 define prompt_key     char (01)



	let	prompt_key  =  null

	initialize  d_ctn27c01.*  to  null

 let int_flag  = false
 initialize d_ctn27c01.*    to null

 #--------------------------------------------------------------------
 #  LE TABELA DE RETORNO DO FAX
 #--------------------------------------------------------------------
 select telnum      , faxdstdes   , faxtrxtmp  ,
        faxpagtotqtd, faxtrxpagqtd, faxsttcod  ,
        faxstttxt   , faxrdsqtd   , faxidecod  ,
        faxdat      , faxhor
   into d_ctn27c01.telnum      , d_ctn27c01.faxdstdes   ,
        d_ctn27c01.faxtrxtmp   , d_ctn27c01.faxpagtotqtd,
        d_ctn27c01.faxtrxpagqtd, d_ctn27c01.faxsttcod   ,
        d_ctn27c01.faxstttxt   , d_ctn27c01.faxrdsqtd   ,
        d_ctn27c01.faxidecod   , d_ctn27c01.faxdat      ,
        d_ctn27c01.faxhor
   from gfxmfax
  where faxsiscod  =  par.faxsiscod   and
        faxsubcod  =  par.faxsubcod   and
        faxch1     =  par.faxch1      and
        faxch2     =  par.faxch2

 if sqlca.sqlcode  =  NOTFOUND   then
    error "Nao existe retorno para o fax selecionado !"
    return
 else
    if sqlca.sqlcode  <  0   then
       error "Erro (", sqlca.sqlcode, ") na leitura dos dados do fax."
    end if
 end if


 open window ctn27c01 at 08,02 with form "ctn27c01"
             attribute (form line 1)

 if d_ctn27c01.faxsttcod = 0     or    ###  Transmissao OK (GS-Fax)
    d_ctn27c01.faxsttcod = 5000  then  ###  Transmissao OK (VSI-Fax)
    let d_ctn27c01.faxstttxt = " FAX ENVIADO OK!"
 end if

 case par.faxsubcod
    when "RC" let d_ctn27c01.faxsubdsc = "RECLAMACAO"
    when "RS" let d_ctn27c01.faxsubdsc = "RESERVA"
    when "FU" let d_ctn27c01.faxsubdsc = "FURTO"
    when "AL" let d_ctn27c01.faxsubdsc = "ALARME"
    when "PS" let d_ctn27c01.faxsubdsc = "P.SOCORRO"
    when "VD" let d_ctn27c01.faxsubdsc = "VIDROS"
    otherwise let d_ctn27c01.faxsubdsc = "NAO PREVISTO"
 end case

 display by name d_ctn27c01.*
 display by name par.faxch1, par.faxenvdat, par.faxenvhor
 prompt " (F17)Abandona" for char prompt_key

 close window ctn27c01
 let int_flag  = false

end function # ctn27c01
