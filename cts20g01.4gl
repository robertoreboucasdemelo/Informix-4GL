#############################################################################
# Nome do Modulo: CTS20G01                                         Marcelo  #
#                                                                  Gilberto #
# Funcoes genericas de acesso a tabelas da Central 24 Horas        Set/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 21/11/2006  psi 205206   Ruiz         retornar empresa da ligacao/servico #
#                                       (empresa Azul)                      #
#############################################################################

 database porto

#----------------------------------------------------------------------------
 function cts20g01_prepare()
#----------------------------------------------------------------------------

 define ws           record
    sql              char (3000)
 end record



	initialize  ws.*  to  null

 let ws.sql = "select datmligacao.lignum,        ",
              "       datrligapol.succod,        ",
              "       datrligapol.ramcod,        ",
              "       datrligapol.aplnumdig,     ",
              "       datrligapol.itmnumdig,     ",
              "       datrligapol.edsnumref,     ",
              "       datrligprp.prporg,         ",
              "       datrligprp.prpnumdig,      ",
              "       datrligpac.fcapacorg,      ",
              "       datrligpac.fcapacnum,      ",
              "       datrligitaaplitm.itaciacod ", 
              "  from datmligacao,               ",
              " outer datrligapol, outer datrligprp, outer datrligpac, outer datrligitaaplitm",
              " where datmligacao.lignum       = ?",
              "   and datrligapol.lignum       = datmligacao.lignum",
              "   and datrligprp.lignum        = datmligacao.lignum",
              "   and datrligpac.lignum        = datmligacao.lignum",
              "   and datrligitaaplitm.lignum  = datmligacao.lignum"
 prepare p_cts20g01_001 from ws.sql
 declare c_cts20g01_001 cursor with hold for p_cts20g01_001


 let ws.sql = "select datmligacao.ligcvntip,     ",     ## g_documento.ligcvntip
              "       datrligapol.succod,        ",     ## g_documento.succod
              "       datrligapol.ramcod,        ",     ## g_documento.ramcod
              "       datrligapol.aplnumdig,     ",     ## g_documento.aplnumdig
              "       datrligapol.itmnumdig,     ",     ## g_documento.itmnumdig
              "       datrligapol.edsnumref,     ",     ## g_documento.edsnumref
              "       datrligprp.prporg,         ",     ## g_documento.prporg
              "       datrligprp.prpnumdig,      ",     ## g_documento.prpnumdig
              "       datrligpac.fcapacorg,      ",     ## g_documento.fcapacorg
              "       datrligpac.fcapacnum,      ",     ## g_documento.fcapacnum
              "       datrligsau.bnfnum,         ",     ## g_documento.bnfnum
              "       datrligsau.crtnum,         ",     ## g_documento.crtsaunum
              "       datrligppt.cmnnumdig,      ",     ## g_ppt.cmnnumdig
              "       datrligcor.corsus,         ",     ## g_documento.corsus
              "       datrligtel.dddcod,         ",     ## g_documento.dddcod
              "       datrligtel.teltxt,         ",     ## g_documento.ctttel
              "       datrligmat.funmat,         ",     ## g_documento.funmat
              "       datrligcgccpf.cgccpfnum,   ",     ## g_documento.cgccpfnum
              "       datrligcgccpf.cgcord,      ",     ## g_documento.cgcord
              "       datrligcgccpf.cgccpfdig,   ",     ## g_documento.cgccpfdig
              "       datrligcgccpf.crtdvgflg,   ",     ## g_crtdvgflg
              "       datrligsemapl.ligdcttip,   ",     ## g_pss.ligdcttip
              "       datrligsemapl.ligdctnum,   ",     ## g_pss.ligdctnum
              "       datrligsemapl.dctitm,      ",     ## g_pss.dctitm
              "       datrcntlig.psscntcod,      ",     ## g_pss.psscntcod
              "       datrligsemapl.ligdcttip,   ",     ## g_cgccpf.ligdcttip
              "       datrligsemapl.ligdctnum,   ",     ## g_cgccpf.ligdctnum
              "       datrligitaaplitm.itaciacod ",     ## g_documento.itaciacod        
              "  from datmligacao,            ",
              "       outer datrligapol,      ",
              "       outer datrligprp,       ",
              "       outer datrligpac,       ",
              "       outer datrligsau,       ",
              "       outer datrligppt,       ",
              "       outer datrligcor,       ",
              "       outer datrligtel,       ",
              "       outer datrligmat,       ",
              "       outer datrligcgccpf,    ",
              "       outer datrligsemapl,    ",
              "       outer datrcntlig,       ",
              "       outer datrligitaaplitm  ",
              " where datmligacao.lignum = ?                        ",
              "   and datrligapol.lignum = datmligacao.lignum       ",
              "   and datrligprp.lignum  = datmligacao.lignum       ",
              "   and datrligpac.lignum  = datmligacao.lignum       ",
              "   and datrligsau.lignum  = datmligacao.lignum       ",
              "   and datrligppt.lignum  = datmligacao.lignum       ",
              "   and datrligcor.lignum  = datmligacao.lignum       ",
              "   and datrligtel.lignum  = datmligacao.lignum       ",
              "   and datrligmat.lignum  = datmligacao.lignum       ",
              "   and datrligcgccpf.lignum     = datmligacao.lignum ",
              "   and datrligsemapl.lignum     = datmligacao.lignum ",
              "   and datrcntlig.lignum        = datmligacao.lignum ",
              "   and datrligitaaplitm.lignum  = datmligacao.lignum "   
 prepare p_cts20g01_002 from ws.sql
 declare c_cts20g01_002 cursor with hold for p_cts20g01_002

end function  ###  cts20g01_prepare

#----------------------------------------------------------------------------
 function cts20g01_docto(param)
#----------------------------------------------------------------------------

 define param        record
    lignum           like datmligacao.lignum
 end record

 define ws           record
    succod           like datrligapol.succod,
    ramcod           like datrligapol.ramcod,
    aplnumdig        like datrligapol.aplnumdig,
    itmnumdig        like datrligapol.itmnumdig,
    edsnumref        like datrligapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapacorg        like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum,
    itaciacod        like datrligitaaplitm.itaciacod
 end record


 initialize ws.*      to null

 if param.lignum is null  then
    error " Parametro invalido! AVISE A INFORMATICA!"
    return ws.*
 end if

 whenever error continue
    open  c_cts20g01_001 using param.lignum
    if status <> 0 then
       call cts20g01_prepare()
       open  c_cts20g01_001 using param.lignum
    end if
 whenever error stop

 fetch c_cts20g01_001 into  param.lignum,
                        ws.succod,
                        ws.ramcod,
                        ws.aplnumdig,
                        ws.itmnumdig,
                        ws.edsnumref,
                        ws.prporg,
                        ws.prpnumdig,
                        ws.fcapacorg,
                        ws.fcapacnum,
                        ws.itaciacod 
 close c_cts20g01_001
 if ws.aplnumdig is null  then # atendimento sem documento
    select ramcod
         into ws.ramcod
         from datrservapol a, datmligacao b
        where b.lignum    = param.lignum
          and a.atdsrvnum = b.atdsrvnum
          and a.atdsrvano = b.atdsrvano
 end if

 return ws.*

end function  ###  cts20g01_docto
#----------------------------------------------------------------------------
function cts20g01_ciaempcod_docto(param)
#----------------------------------------------------------------------------
  define param record
         lignum     like datmligacao.lignum,
         atdsrvnum  like datmservico.atdsrvnum,
         atdsrvano  like datmservico.atdsrvano
  end record
  define ws record
         ciaempcod  like datmligacao.ciaempcod
  end record

  initialize ws.*      to null
  if param.lignum    is null  and
     param.atdsrvnum is null and
     param.atdsrvano is null then
     error " Parametro invalido! AVISE A INFORMATICA!"
     return ws.*
  end if

  if param.lignum is not null then
     select ciaempcod
         into ws.ciaempcod
         from datmligacao
        where lignum = param.lignum
  end if
  if param.atdsrvnum is not null and
     param.atdsrvano is not null then
     select ciaempcod
         into ws.ciaempcod
         from datmservico
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
  end if
  return ws.*
end function

#----------------------------------------------------------------------------
 function cts20g01_docto_tot(param)
#----------------------------------------------------------------------------

 define param        record
    lignum           like datmligacao.lignum
 end record

 define ws           record
    ligcvntip        like datmligacao.ligcvntip,
    succod           like datrligapol.succod,
    ramcod           like datrligapol.ramcod,
    aplnumdig        like datrligapol.aplnumdig,
    itmnumdig        like datrligapol.itmnumdig,
    edsnumref        like datrligapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapacorg        like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum,
    bnfnum           like datrligsau.bnfnum,
    crtsaunum        like datrligsau.crtnum,
    cmnnumdig        like datrligppt.cmnnumdig,
    corsus           like datrligcor.corsus,
    dddcod           like datrligtel.dddcod,
    ctttel           like datrligtel.teltxt,
    funmat           like datrligmat.funmat,
    cgccpfnum        like datrligcgccpf.cgccpfnum,
    cgcord           like datrligcgccpf.cgcord,
    cgccpfdig        like datrligcgccpf.cgccpfdig,
    g_crtdvgflg      like datrligcgccpf.crtdvgflg,
    pss_ligdcttip    like datrligsemapl.ligdcttip,
    pss_ligdctnum    like datrligsemapl.ligdctnum,
    pss_dctitm       like datrligsemapl.dctitm,
    pss_psscntcod    like datrcntlig.psscntcod,
    cgccpf_ligdcttip like datrligsemapl.ligdcttip,
    cgccpf_ligdctnum like datrligsemapl.ligdctnum,
    itaciacod        like datrligitaaplitm.itaciacod     
 end record

 initialize ws.*      to null

 if param.lignum is null  then
    error " Parametro invalido! AVISE A INFORMATICA!"
    return ws.*
 end if

 whenever error continue
    open  c_cts20g01_002 using param.lignum
    if status <> 0 then       
       call cts20g02_prepare()
       call cts20g01_prepare()
       open  c_cts20g01_002 using param.lignum       
    end if
 whenever error stop

 fetch c_cts20g01_002 into ws.ligcvntip,
                       ws.succod,
                       ws.ramcod,
                       ws.aplnumdig,
                       ws.itmnumdig,
                       ws.edsnumref,
                       ws.prporg,
                       ws.prpnumdig,
                       ws.fcapacorg,
                       ws.fcapacnum,
                       ws.bnfnum,
                       ws.crtsaunum,
                       ws.cmnnumdig,
                       ws.corsus,
                       ws.dddcod,
                       ws.ctttel,
                       ws.funmat,
                       ws.cgccpfnum,
                       ws.cgcord,
                       ws.cgccpfdig,
                       ws.g_crtdvgflg,
                       ws.pss_ligdcttip,
                       ws.pss_ligdctnum,
                       ws.pss_dctitm,
                       ws.pss_psscntcod,
                       ws.cgccpf_ligdcttip,
                       ws.cgccpf_ligdctnum,
                       ws.itaciacod         
 close c_cts20g01_002

 return ws.*

end function  ###  cts20g01_docto_tot
