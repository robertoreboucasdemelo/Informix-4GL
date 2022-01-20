#------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                  #
#..................................................................#
# Sistema        : Programa novo Cadastro de locais especiais      #
# Modulo         : ctc71m00                                        #
# Analista Resp. : Glauce Lima                                     #
# OSF            : 33553  - Cadastro de locais especiais           #
#..................................................................#
# Desenvolvimento: Fabrica de Software, Klaus Paiva                #
#..................................................................#
#                                                                  #
#                  * * *  ALTERACOES  * * *                        #
#                                                                  #
# Data        Autor Fabrica  Data   Alteracao                      #
# ----------  -------------  ------ -------------------------------#
# 31/03/2004  Helio          31/03  Ajustes - OSF 33979            #
# 02/03/2010  Adriano S     PSI 252891 Inclusao do padrao idx 4 e 5#
#---------------------------------------------------------------- -#

globals "/homedsa/projetos/geral/globals/ac_globl.4gl"

define m_cmd char(1000)
define m_flgAntProx   smallint
define m_numerrsql    integer
define m_flgSelCod    smallint
define m_flgSelDesc   smallint

function tela_ctc71m00()

define l_resp char(01)

  define l_flgSelciona smallint
  define l_c24fxolclcod like datkfxolcl.c24fxolclcod

  define l_datkfxolcl record
         c24fxolclcod like datkfxolcl.c24fxolclcod    ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_tel record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  let l_flgSelciona = false
  let m_flgSelCod   = false
  let m_flgSelDesc  = false

  initialize l_c24fxolclcod to null

  #let g_issk.empcod = 1
  #let g_issk.funmat = 6567
  #let g_issk.usrtip = "F"

  open window w_ctc71m00 at 4,2
  with form "ctc71m00"
        menu "Central 24 HS"

           command key("S") "Seleciona"
             "Seleciona Origem Codigo do local"
             initialize l_c24fxolclcod to null
             initialize l_datkfxolcl.* to null
             let m_flgSelCod   = false
             let m_flgSelDesc  = false
             call consulta_ctc71m00()
             returning l_flgSelciona  ,
                       l_datkfxolcl.* ,
                       l_c24fxolclcod

           command key("P") "Proximo"
             if m_flgSelDesc then
                let m_flgAntProx = 1
                call paginacao_ctc71m00()
                returning l_tel.*
                let l_datkfxolcl.c24fxolclcod = l_tel.c24fxolclcod
                let l_datkfxolcl.c24fxolcldes = l_tel.c24fxolcldes
                let l_datkfxolcl.lgdtip       = l_tel.lgdtip
                let l_datkfxolcl.lgdnom       = l_tel.lgdnom
                let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
                let l_datkfxolcl.lgdnum       = l_tel.lgdnum
                let l_datkfxolcl.lgdcep       = l_tel.lgdcep
                let l_datkfxolcl.lgdcepcmp    = l_tel.lgdcepcmp
                let l_datkfxolcl.brrnom       = l_tel.brrnom
                let l_datkfxolcl.cidnom       = l_tel.cidnom
                let l_datkfxolcl.ufdcod       = l_tel.ufdcod
                let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom
             else
        error "Opcao valida apenas quando consulta realizada por nome do local"
                next option "Seleciona"
             end if
           command key("A") "Anterior"
             if m_flgSelDesc then
                let m_flgAntProx = 2
                call paginacao_ctc71m00()
                returning l_tel.*

                let l_datkfxolcl.c24fxolclcod = l_tel.c24fxolclcod
                let l_datkfxolcl.c24fxolcldes = l_tel.c24fxolcldes
                let l_datkfxolcl.lgdtip       = l_tel.lgdtip
                let l_datkfxolcl.lgdnom       = l_tel.lgdnom
                let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
                let l_datkfxolcl.lgdnum       = l_tel.lgdnum
                let l_datkfxolcl.lgdcep       = l_tel.lgdcep
                let l_datkfxolcl.lgdcepcmp    = l_tel.lgdcepcmp
                let l_datkfxolcl.brrnom       = l_tel.brrnom
                let l_datkfxolcl.cidnom       = l_tel.cidnom
                let l_datkfxolcl.ufdcod       = l_tel.ufdcod
                let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom

             else
      error "Opcao valida apenas quando consulta realizada por nome do local"
                 next option "Seleciona"
             end if
           command key("M") "Modifica"
           if l_flgSelciona then
              call input_modifica_ctc71m00(l_datkfxolcl.*)
           else
              error "Selecione o codigo do local"
              next option "Seleciona"
           end if
           command key("I") "Incluir"
             call input_incluir_ctc71m00()
           command key("C") "Cancela"
             if l_c24fxolclcod is null then
                error "Selecione o codigo do local"
                next option "Seleciona"
             else
                while true
                  prompt "Confirma Cancelamento <Sim/Nao> ? "
                  for char l_resp
                  if upshift(l_resp) not matches "[SsNn]" then
                     continue while
                  end if
                  if upshift(l_resp) matches "[N]" then
                     exit while
                  else
                     call cancela_ctc71m00(l_c24fxolclcod)
                     exit while
                  end  if
                end while
             end if
           command key(f5)
             if l_c24fxolclcod is null then
                error "Nenhum local selecionado "
             else
                call ctc71m02(l_c24fxolclcod)
             end if
           command key("E") "Encerrar"
             exit menu
        end menu

        let int_flag = false

    close window w_ctc71m00
end function


function inisql_ctc71m00()

  #---------------Obs --------------------------------
  # Funcao iniciada no modulo ctg.4gl
  # No menu do modulo
  #---------------------------------------------------

  let m_cmd =  "select c24fxolclcod ,c24fxolcldes , lgdtip , lgdnom       ,",
               " lgdcmp      ,",
               "       lgdnum       , lgdcep , lgdcepcmp    , brrnom      ,",
               "       cidnom       , ufdcod , brrzonnom    , c24lclpdrcod,",
               "       lclltt       , lcllgt , canhordat from datkfxolcl  ",
               "where c24fxolclcod = ? "
      prepare pctc71m00001 from m_cmd
      declare cctc71m00001 cursor for pctc71m00001


  let m_cmd = "insert into datkfxolcl ",
              "(c24fxolclcod ,c24fxolcldes , lgdtip ,      lgdnom , lgdcmp ,",
              " lgdnum       , lgdcep      , lgdcepcmp       , brrnom      ,",
              " cidnom       , ufdcod      , brrzonnom       , c24lclpdrcod,",
              " lclltt       , lcllgt      , cadhordat       , cademp      ,",
              " cadmat       , cadusrtip   , atlhordat       , ",
              " atlemp       , atlmat      , atlusrtip)",
              " values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,",
              "         ?,?,?,?,?,?,?) "
      prepare pctc71m00002 from m_cmd


  let m_cmd = " update datkfxolcl set (c24fxolcldes , lgdtip      ,",
                                  "    lgdnom       , lgdcmp      ,",
                                  "    lgdnum       , lgdcep      ,",
                                  "    lgdcepcmp    , brrnom      ,",
                                  "    cidnom       , ufdcod      ,",
                                  "    brrzonnom    , c24lclpdrcod,",
                                  "    lclltt       , lcllgt      ,",
                                  "    cadhordat                  ,",
                                  "    atlhordat    , atlemp      ,",
                                  "    atlmat       , atlusrtip   ,",
                                  "    cademp       ,  cadmat     ,",
                                  "    cadusrtip    )        ",
                                  "  = (    ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?              ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?      ,    ?  ," ,
                                  "         ?              , " ,
                                  "         ?      ,    ?   )",
              " where c24fxolclcod = ? "
      prepare pctc71m00003 from m_cmd

      let m_cmd = " select max(c24fxolclcod) from datkfxolcl  "
      prepare pctc71m00004 from m_cmd
      declare cctc71m00004 cursor for pctc71m00004

  let m_cmd =  "select c24fxolclcod , c24fxolcldes , lgdtip , lgdnom       ,",
               "       lgdcmp       , lgdnum       , lgdcep , lgdcepcmp    ,",
               "       brrnom       , cidnom       , ufdcod , brrzonnom    ,",
               "       c24lclpdrcod , lclltt       , lcllgt ",
               "       c24fxolclcod from datkfxolcl " ,
               " where cidnom = ? ",
               "   and ufdcod = ? ",
               "   and c24fxolcldes matches ? ",
               " order by c24fxolclcod "
      prepare pctc71m00005 from m_cmd
      declare cctc71m00005 scroll cursor for pctc71m00005

  let m_cmd = " update datkfxolcl set (canhordat    , canemp      ,",
                                  "    canmat       , canusrtip)  ",
                                  " = (   ?         ,    ?        ,",
                                  "       ?         ,    ?        )",
              " where c24fxolclcod = ? "
      prepare pctc71m00006 from m_cmd

  let m_cmd =  "select c24fxolclcod , c24fxolcldes , lgdtip , lgdnom       ,",
               "       lgdcmp       , lgdnum       , lgdcep , lgdcepcmp    ,",
               "       brrnom       , cidnom       , ufdcod , brrzonnom    ,",
               "       c24lclpdrcod , lclltt       , lcllgt ",
               "       c24fxolclcod from datkfxolcl " ,
               " where c24fxolcldes matches ? "
      prepare pctc71m00007 from m_cmd
      declare cctc71m00007 scroll cursor for pctc71m00007

  let m_cmd = "select lgdtip, lgdnom,cidcod,brrcod from glaklgd ",
              " where lgdcep    = ? ",
              "   and lgdcepcmp = ? "
      prepare pctc71m00008 from m_cmd
      declare cctc71m00008 cursor for pctc71m00008

  let m_cmd = " select cidnom , ufdcod  from glakcid ",
              " where cidcod = ? "
      prepare pctc71m00009 from m_cmd
      declare cctc71m00009 cursor for pctc71m00009

  let m_cmd = "select brrnom from glakbrr ",
              " where cidcod = ? ",
              "   and brrcod = ? "
      prepare pctc71m00010 from m_cmd
      declare cctc71m00010 cursor for pctc71m00010

  let m_cmd = " select cidcod, cidnom , ufdcod  from glakcid ",
              " where ufdcod = ? " ,
              "   and cidnom = ? "
      prepare pctc71m00011 from m_cmd
      declare cctc71m00011 cursor for pctc71m00011

end function

function cancela_ctc71m00(l_datkfxolcl)
  define l_datkfxolcl like datkfxolcl.c24fxolclcod
  define l_atlhordata datetime year to second

  let l_atlhordata = current


  whenever error continue
  execute pctc71m00006 using l_atlhordata ,
                             g_issk.empcod,
                             g_issk.funmat,
                             g_issk.usrtip,
                             l_datkfxolcl
  whenever error stop
  if sqlca.sqlcode < 0 then
     error " Erro ",sqlca.sqlcode using "<<<<<<",
           sqlca.sqlerrd[2] using "<<<<"  ,
           " na execucao de cctc71m00006 " ,
           " comunique a Informatica "
  else
     error "Local Cancelado "
  end if

end function

function cts06g03_ctc71m00(l_datkfxolcl  ,
                           l_c24fxolclcod)

  define l_datkfxolcl record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_c24fxolclcod like datkfxolcl.c24fxolclcod

  define l_tel        record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  define l_lixo_cts06g03 record
         hist1  like datmservhist.c24srvdsc,
         hist2  like datmservhist.c24srvdsc,
         hist3  like datmservhist.c24srvdsc,
         hist4  like datmservhist.c24srvdsc,
         hist5  like datmservhist.c24srvdsc
    end record

  define l_data date
  define l_hora char(10)
  define l_lixo_lclidttxt like datmlcl.lclidttxt
  define l_lixo_ofnnumdig like sgokofi.ofnnumdig
  define l_lixo_clbrrnom  like datmlcl.lclbrrnom
  define l_lixo_retflg char (01)
  define l_flgerro smallint

  {
  initialize l_lixo_cts06g03.* to null
  initialize l_lixo_ofnnumdig to null
  initialize l_datkfxolcl.lgdnom to null
  initialize l_datkfxolcl.lgdcep to null
  initialize l_datkfxolcl.lclltt to null
  initialize l_datkfxolcl.c24lclpdrcod to null
  initialize l_datkfxolcl.cidnom to null
  initialize l_datkfxolcl.brrnom to null
  initialize l_datkfxolcl.brrzonnom to null
  initialize l_datkfxolcl.lgdtip to null
  initialize l_datkfxolcl.lgdnum to null
  initialize l_datkfxolcl.lgdcepcmp to null
  initialize l_datkfxolcl.lcllgt to null
  }


  if not l_flgerro then
     let l_tel.c24fxolclcod = l_c24fxolclcod
     let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
     let l_tel.lgdcep       = l_datkfxolcl.lgdcep
     let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
     let l_tel.cidnom       = l_datkfxolcl.cidnom
     let l_tel.ufdcod       = l_datkfxolcl.ufdcod
     let l_tel.lgdtip       = l_datkfxolcl.lgdtip
     let l_tel.lgdnom       = l_datkfxolcl.lgdnom
     let l_tel.lgdnum       = l_datkfxolcl.lgdnum
     let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
     let l_tel.brrnom       = l_datkfxolcl.brrnom
     let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom
     display by name l_tel.*
  end if

end function

function input_modifica_ctc71m00(l_datkfxolcl)

  define l_datkfxolcl record
         c24fxolclcod like datkfxolcl.c24fxolclcod    ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_tel record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  define l_glaklgd record
         lgdtip like glaklgd.lgdtip ,
         lgdnom like glaklgd.lgdnom ,
         cidcod like glaklgd.cidcod ,
         brrcod like glaklgd.brrcod
     end record

  define l_glakcid record
         cidcod like glakcid.cidcod,
         cidnom like glakcid.cidnom,
         ufdcod like glakcid.ufdcod
     end record

  define l_cts23g00 record
         result       char(30)                     ,
         mpacidcod    like datkmpacid.mpacidcod    ,
         lclltt       like datkfxolcl.lclltt       ,
         lcllgt       like datkfxolcl.lcllgt       ,
         mpacrglgdflg like datkmpacid.mpacrglgdflg ,
         gpsacngrpcod like datkmpacid.gpsacngrpcod
     end record

  define l_cts06g09 record
         lgdtip       like glaklgd.lgdtip          ,
         lgdnom       like glaklgd.lgdnom          ,
         brrnom       like datkfxolcl.brrnom       ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         lclltt       like datkfxolcl.lclltt       ,
         lcllgt       like datkfxolcl.lcllgt       ,
         c24lclpdrcod like datkfxolcl.c24lclpdrcod
     end record

  define l_cts06g05 record
         lgdtip       like glaklgd.lgdtip          ,
         lgdnom       like glaklgd.lgdnom          ,
         brrnom       like datkfxolcl.brrnom       ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         c24lclpdrcod like datkfxolcl.c24lclpdrcod
     end record

  define lr_ctx25g05  record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom,
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

  define l_ret_cts06g06 like glaklgd.lgdnom
  define l_ret_cts06g04 like glakcid.cidnom

  define l_glakbrr_brrnom like glakbrr.brrnom


  define l_c24fxolclcod like datkfxolcl.c24fxolclcod
  define l_atlhordata datetime year to second
  define l_flgerro smallint
  define l_auxcidcod like glakcid.cidcod
  define l_aux char(65)

  let l_atlhordata = current
  let l_flgerro = false

  initialize lr_ctx25g05.* to null

  let l_tel.lgdcep     = l_datkfxolcl.lgdcep
  let l_tel.lgdcepcmp  = l_datkfxolcl.lgdcepcmp
  let l_tel.cidnom     = l_datkfxolcl.cidnom
  let l_tel.ufdcod     = l_datkfxolcl.ufdcod
  let l_tel.lgdtip     = l_datkfxolcl.lgdtip
  let l_tel.lgdnom     = l_datkfxolcl.lgdnom
  let l_tel.lgdnum     = l_datkfxolcl.lgdnum
  let l_tel.lgdcmp     = l_datkfxolcl.lgdcmp
  let l_tel.brrnom     = l_datkfxolcl.brrnom
  let l_tel.brrzonnom  = l_datkfxolcl.brrzonnom


  input by name l_tel.lgdcep    ,
                l_tel.lgdcepcmp ,
                l_tel.cidnom    ,
                l_tel.ufdcod    ,
                l_tel.lgdtip    ,
                l_tel.lgdnom    ,
                l_tel.lgdnum    ,
                l_tel.lgdcmp    ,
                l_tel.brrnom    ,
                l_tel.brrzonnom

  without defaults

    on key (interrupt,control-c)
         initialize l_tel.* to null
         initialize l_datkfxolcl.* to null
         let int_flag = false
         exit input
         close window w_ctc71m00

    before field lgdcep
      display by name l_tel.lgdcep attribute(reverse)
    after field lgdcep
      display by name l_tel.lgdcep

    before field lgdcepcmp
      display by name l_tel.lgdcepcmp attribute(reverse)
    after field lgdcepcmp
      display by name l_tel.lgdcepcmp
      if l_tel.lgdcep is not null and
         l_tel.lgdcepcmp is not null then
         initialize l_glaklgd.* to null
         initialize l_ret_cts06g06 to null
         initialize l_glakcid.* to null
         whenever error continue
         open cctc71m00008 using l_tel.lgdcep ,
                                 l_tel.lgdcepcmp
         fetch cctc71m00008 into l_glaklgd.lgdtip,
                                 l_glaklgd.lgdnom,
                                 l_glaklgd.cidcod,
                                 l_glaklgd.brrcod
         whenever error stop
         if sqlca.sqlcode < 0 then
            error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
                   sqlca.sqlerrd[2] using "<<<<"           ,
                   " na leitura do prepare pctc71m00008 " ,
                   " comunique a Informatica "
         else
            if sqlca.sqlcode = 100 then
               error "Cep nao cadastrado "
               next field lgdcep
            else
               call cts06g06(l_glaklgd.lgdnom)
               returning l_ret_cts06g06
               whenever error continue
               open cctc71m00009 using l_glaklgd.cidcod
               whenever error stop
               fetch cctc71m00009 into l_glakcid.cidnom,
                                       l_glakcid.ufdcod
               if sqlca.sqlcode < 0 then
                  error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
                  sqlca.sqlerrd[2] using "<<<<"           ,
                  " na leitura do prepare pctc71m00009 " ,
                  " comunique a Informatica "
               else
                  if sqlca.sqlcode = 100 then
                  else
                     whenever error continue
                     open cctc71m00010 using l_glaklgd.cidcod ,
                                             l_glaklgd.brrcod
                     fetch cctc71m00010 into l_glakbrr_brrnom
                     whenever error stop
                     if sqlca.sqlcode < 0 then
                        error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
                        sqlca.sqlerrd[2] using "<<<<"           ,
                        " na leitura do prepare pctc71m00010 " ,
                        " comunique a Informatica "
                     else
                        if sqlca.sqlcode = 100 then
                        else
                           let l_tel.cidnom    = l_glakcid.cidnom
                           let l_tel.ufdcod    = l_glakcid.ufdcod
                           let l_tel.lgdtip    = l_glaklgd.lgdtip
                           let l_tel.lgdnom    = l_glaklgd.lgdnom
                           let l_tel.brrnom    = l_glakbrr_brrnom

                           display by name l_tel.cidnom ,
                                           l_tel.ufdcod ,
                                           l_tel.lgdtip ,
                                           l_tel.lgdnom ,
                                           l_tel.brrnom
                        end if
                     end if
                     close cctc71m00010
                  end if
               end if
              close cctc71m00009
            end if
         end if
      end if
      close cctc71m00008
    before field cidnom
      display by name l_tel.cidnom attribute(reverse)
    after  field cidnom
      display by name l_tel.cidnom

    before field ufdcod
      display by name l_tel.ufdcod attribute(reverse)
    after field ufdcod
      display by name l_tel.ufdcod
      initialize l_auxcidcod to null
      whenever error continue
      open cctc71m00011 using l_tel.ufdcod ,
                              l_tel.cidnom
      fetch cctc71m00011 into l_glakcid.cidcod,
                              l_glakcid.cidnom,
                              l_glakcid.ufdcod
      whenever error stop
      if sqlca.sqlcode < 0 then
         error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
         sqlca.sqlerrd[2] using "<<<<"           ,
         " na leitura do prepare pctc71m00011" ,
         " comunique a Informatica "
      else
         if sqlca.sqlcode = 100 then
            initialize l_ret_cts06g04 to null # cidnom
            call cts06g04(l_tel.cidnom ,
                          l_tel.ufdcod )
            returning l_auxcidcod    ,
                      l_ret_cts06g04 ,
                      l_tel.ufdcod

            if l_ret_cts06g04 is null then
               error "Cidade nao cadastrada "
               next field cidnom
            end if
         end if
      end if
      close cctc71m00011
    before field lgdtip
      display by name l_tel.lgdtip attribute(reverse)
    after field lgdtip
      display by name l_tel.lgdtip

    before field lgdnom
       display by name l_tel.lgdnom attribute(reverse)
    after field lgdnom
      display by name l_tel.lgdnom

    before field lgdnum
      display by name l_tel.lgdnum attribute(reverse)
    after field lgdnum
      display by name l_tel.lgdnum
      initialize l_cts23g00.* to null
      initialize l_cts06g09.* to null
      call cts23g00_inf_cidade(2,
                              "",
                              l_tel.cidnom ,
                              l_tel.ufdcod)
      returning l_cts23g00.*

      let l_datkfxolcl.lclltt  = l_cts23g00.lclltt
      let l_datkfxolcl.lcllgt  = l_cts23g00.lcllgt

      if l_cts23g00.mpacrglgdflg = "1" then

         # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
         if ctx25g05_rota_ativa() then

            initialize lr_ctx25g05.* to null
            call ctx25g05("C", # -> INPUT COMPLETO
                          "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                          l_tel.ufdcod,
                          l_tel.cidnom,
                          l_tel.lgdtip,
                          l_tel.lgdnom,
                          l_tel.lgdnum,
                          l_tel.brrnom,
                          "",
                          "",
                          "",
                          "",
                          "",
                          "")

                 returning lr_ctx25g05.lgdtip,
                           lr_ctx25g05.lgdnom,
                           lr_ctx25g05.lgdnum,
                           lr_ctx25g05.brrnom,
                           l_aux,
                           lr_ctx25g05.lgdcep,
                           lr_ctx25g05.lgdcepcmp,
                           lr_ctx25g05.lclltt,
                           lr_ctx25g05.lcllgt,
                           lr_ctx25g05.c24lclpdrcod,
                           lr_ctx25g05.ufdcod,
                           lr_ctx25g05.cidnom

           let l_datkfxolcl.lgdtip       = lr_ctx25g05.lgdtip
           let l_datkfxolcl.lgdnom       = lr_ctx25g05.lgdnom
           let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
           let l_datkfxolcl.lgdnum       = lr_ctx25g05.lgdnum
           let l_datkfxolcl.lgdcep       = lr_ctx25g05.lgdcep
           let l_datkfxolcl.lgdcepcmp    = lr_ctx25g05.lgdcepcmp
           let l_datkfxolcl.brrnom       = lr_ctx25g05.brrnom
           let l_datkfxolcl.cidnom       = lr_ctx25g05.cidnom
           let l_datkfxolcl.ufdcod       = lr_ctx25g05.ufdcod
           let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom
           let l_datkfxolcl.c24lclpdrcod = lr_ctx25g05.c24lclpdrcod

           let l_datkfxolcl.lclltt       = lr_ctx25g05.lclltt
           let l_datkfxolcl.lcllgt       = lr_ctx25g05.lcllgt

         else
             call cts06g09(l_tel.lgdtip,
                       l_tel.lgdnom,
                       l_tel.lgdnum,
                       l_tel.brrnom ,
                       l_cts23g00.mpacidcod)
             returning l_cts06g09.*

             let l_datkfxolcl.lgdtip       = l_cts06g09.lgdtip
             let l_datkfxolcl.lgdnom       = l_cts06g09.lgdnom
             let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
             let l_datkfxolcl.lgdnum       = l_tel.lgdnum
             let l_datkfxolcl.lgdcep       = l_cts06g09.lgdcep
             let l_datkfxolcl.lgdcepcmp    = l_cts06g09.lgdcepcmp
             let l_datkfxolcl.brrnom       = l_cts06g09.brrnom
             let l_datkfxolcl.cidnom       = l_tel.cidnom
             let l_datkfxolcl.ufdcod       = l_tel.ufdcod
             let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom
             let l_datkfxolcl.c24lclpdrcod = l_cts06g09.c24lclpdrcod

             let l_datkfxolcl.lclltt       = l_cts06g09.lclltt
             let l_datkfxolcl.lcllgt       = l_cts06g09.lcllgt

         end if

         display by name l_datkfxolcl.lgdtip       ,
                         l_datkfxolcl.lgdnom       ,
                         l_datkfxolcl.lgdcmp       ,
                         l_datkfxolcl.lgdnum       ,
                         l_datkfxolcl.lgdcep       ,
                         l_datkfxolcl.lgdcepcmp    ,
                         l_datkfxolcl.brrnom       ,
                         l_datkfxolcl.cidnom       ,
                         l_datkfxolcl.ufdcod       ,
                         l_datkfxolcl.brrzonnom
                         #l_datkfxolcl.c24lclpdrcod    #OSF 33979

      else

         let  int_flag = false
         initialize l_cts06g05.* to null

         call cts06g05(l_tel.lgdtip     ,
                       l_tel.lgdnom     ,
                       l_tel.lgdnum     ,
                       l_tel.brrnom     ,
                       l_glakcid.cidcod ,
                       l_tel.ufdcod)
         returning l_cts06g05.*

         let int_flag                  = false
         let l_datkfxolcl.lgdtip       = l_cts06g05.lgdtip
         let l_datkfxolcl.lgdnom       = l_cts06g05.lgdnom
         let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
         let l_datkfxolcl.lgdnum       = l_tel.lgdnum
         let l_datkfxolcl.lgdcep       = l_cts06g05.lgdcep
         let l_datkfxolcl.lgdcepcmp    = l_cts06g05.lgdcepcmp
         let l_datkfxolcl.brrnom       = l_cts06g05.brrnom
         let l_datkfxolcl.cidnom       = l_tel.cidnom
         let l_datkfxolcl.ufdcod       = l_tel.ufdcod
         let l_datkfxolcl.c24lclpdrcod = l_cts06g05.c24lclpdrcod


         if l_cts06g05.c24lclpdrcod <> 1 and
            l_cts06g05.c24lclpdrcod <> 2 and
            l_cts06g05.c24lclpdrcod <> 3 and 
            l_cts06g05.c24lclpdrcod <> 4 and # PSI 252891
            l_cts06g05.c24lclpdrcod <> 5 then
            error "Codigo de padronizacao invalido"
            next field lgdtip
         end if
      end if

      let l_tel.lgdtip    = ""
      let l_tel.lgdnom    = ""
      let l_tel.lgdcmp    = ""
      let l_tel.lgdnum    = ""
      let l_tel.lgdcep    = ""
      let l_tel.lgdcepcmp = ""
      let l_tel.brrnom    = ""
      let l_tel.cidnom    = ""
      let l_tel.ufdcod    = ""

      display by name l_tel.lgdtip   ,
                      l_tel.lgdnom   ,
                      l_tel.lgdcmp   ,
                      l_tel.lgdnum   ,
                      l_tel.lgdcep   ,
                      l_tel.lgdcepcmp,
                      l_tel.brrnom   ,
                      l_tel.cidnom   ,
                      l_tel.ufdcod


      let l_tel.lgdtip    = l_datkfxolcl.lgdtip
      let l_tel.lgdnom    = l_datkfxolcl.lgdnom
      let l_tel.lgdcmp    = l_datkfxolcl.lgdcmp
      let l_tel.lgdnum    = l_datkfxolcl.lgdnum
      let l_tel.lgdcep    = l_datkfxolcl.lgdcep
      let l_tel.lgdcepcmp = l_datkfxolcl.lgdcepcmp
      let l_tel.brrnom    = l_datkfxolcl.brrnom
      let l_tel.cidnom    = l_datkfxolcl.cidnom
      let l_tel.ufdcod    = l_datkfxolcl.ufdcod


      display by name l_tel.lgdtip    ,
                      l_tel.lgdnom    ,
                      l_tel.lgdcmp    ,
                      l_tel.lgdnum    ,
                      l_tel.lgdcep    ,
                      l_tel.lgdcepcmp ,
                      l_tel.brrnom    ,
                      l_tel.cidnom    ,
                      l_tel.ufdcod

    before field brrzonnom
      display by name l_tel.brrzonnom attribute(reverse)
    after field brrzonnom
      display by name l_tel.brrzonnom
      if l_tel.brrzonnom <> "NO" and
         l_tel.brrzonnom <> "LE" and
         l_tel.brrzonnom <> "OE" and
         l_tel.brrzonnom <> "SU" and
         l_tel.brrzonnom <> "CE" then
         error "Zona deve ser (NO)rte,(LE)este,(SU)l,ou (CE)ntral!"
         next field brrzonnom
      else
         whenever error continue
         execute pctc71m00003 using l_datkfxolcl.c24fxolcldes     ,
                                    l_tel.lgdtip           ,
                                    l_tel.lgdnom           ,
                                    l_tel.lgdcmp           ,
                                    l_tel.lgdnum           ,
                                    l_tel.lgdcep           ,
                                    l_tel.lgdcepcmp        ,
                                    l_tel.brrnom           ,
                                    l_tel.cidnom           ,
                                    l_tel.ufdcod           ,
                                    l_tel.brrzonnom        ,
                                    l_datkfxolcl.c24lclpdrcod,   #OSF-33979
                                    l_datkfxolcl.lclltt    ,
                                    l_datkfxolcl.lcllgt    ,
                                    l_atlhordata           ,
                                    l_atlhordata           ,
                                    g_issk.empcod          ,
                                    g_issk.funmat          ,
                                    g_issk.usrtip          ,
                                    g_issk.empcod          ,
                                    g_issk.funmat          ,
                                    g_issk.usrtip          ,
                                    l_datkfxolcl.c24fxolclcod
         whenever error stop
         if sqlca.sqlcode < 0 then
            error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
            sqlca.sqlerrd[2] using "<<<<"           ,
            " na execucao do prepare pctc71m00003 " ,
            " comunique a Informatica "
         else
            error "Alteracao efetuada com sucesso "
         end if
      end if

  end input

end function

function input_incluir_ctc71m00()

  define l_datkfxolcl record
         c24fxolclcod like datkfxolcl.c24fxolclcod    ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_tel         record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  define l_glaklgd record
         lgdtip like glaklgd.lgdtip ,
         lgdnom like glaklgd.lgdnom ,
         cidcod like glaklgd.cidcod ,
         brrcod like glaklgd.brrcod
     end record

  define l_glakcid record
         cidcod like glakcid.cidcod,
         cidnom like glakcid.cidnom,
         ufdcod like glakcid.ufdcod
     end record

  define l_cts23g00 record
         result       char(30)                     ,
         mpacidcod    like datkmpacid.mpacidcod    ,
         lclltt       like datkfxolcl.lclltt       ,
         lcllgt       like datkfxolcl.lcllgt       ,
         mpacrglgdflg like datkmpacid.mpacrglgdflg ,
         gpsacngrpcod like datkmpacid.gpsacngrpcod
     end record

  define l_cts06g09 record
         lgdtip       like glaklgd.lgdtip          ,
         lgdnom       like glaklgd.lgdnom          ,
         brrnom       like datkfxolcl.brrnom       ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         lclltt       like datkfxolcl.lclltt       ,
         lcllgt       like datkfxolcl.lcllgt       ,
         c24lclpdrcod like datkfxolcl.c24lclpdrcod
     end record

  define lr_ctx25g05  record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom,
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

  define l_cts06g05 record
         lgdtip       like glaklgd.lgdtip          ,
         lgdnom       like glaklgd.lgdnom          ,
         brrnom       like datkfxolcl.brrnom       ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         c24lclpdrcod like datkfxolcl.c24lclpdrcod
     end record

  define l_ret_cts06g06 like glaklgd.lgdnom
  define l_ret_cts06g04 like glakcid.cidnom

  define l_glakbrr_brrnom like glakbrr.brrnom

  define l_aux_c24fxolclcod like datkfxolcl.c24fxolclcod

  define l_c24fxolclcod like datkfxolcl.c24fxolclcod
  define l_atlhordata datetime year to second
  define l_flgerro smallint
  define l_auxcidcod like glakcid.cidcod
  define l_aux char(65)

  let l_atlhordata = current
  let l_flgerro = false

  initialize l_tel.* to null
  initialize l_datkfxolcl.* to null
  initialize lr_ctx25g05.* to null

  input by name l_tel.c24fxolclcod ,
                l_tel.c24fxolcldes ,
                l_tel.lgdcep       ,
                l_tel.lgdcepcmp    ,
                l_tel.cidnom       ,
                l_tel.ufdcod       ,
                l_tel.lgdtip       ,
                l_tel.lgdnom       ,
                l_tel.lgdnum       ,
                l_tel.lgdcmp       ,
                l_tel.brrnom       ,
                l_tel.brrzonnom


    on key (interrupt,control-c)
       let int_flag = false
       exit input
       close window w_ctc71m00

    before field c24fxolclcod
      display by name l_tel.c24fxolclcod attribute(reverse)
      whenever error continue
      open cctc71m00004
      fetch cctc71m00004 into l_aux_c24fxolclcod
      whenever error stop
      if sqlca.sqlcode < 0 then
         error " Erro ",sqlca.sqlcode using "<<<<<<",
               sqlca.sqlerrd[2] using "<<<<"  ,
               " na leitura de cctc71m00004 " ,
               " comunique a Informatica "
         exit input
      else
         if sqlca.sqlcode = 100 then
            let l_tel.c24fxolclcod = 1
         else
            let l_tel.c24fxolclcod = l_aux_c24fxolclcod + 1
         end if
         display by name l_tel.c24fxolclcod
         next field c24fxolcldes
      end if
    before field c24fxolcldes
      display by name l_tel.c24fxolcldes attribute(reverse)
    after field c24fxolcldes
      display by name l_tel.c24fxolcldes
      if l_tel.c24fxolcldes is null then
         error "Informe a descricao do local"
         next field c24fxolcldes
      end if

    before field lgdcep
      display by name l_tel.lgdcep attribute(reverse)
    after field lgdcep
      display by name l_tel.lgdcep

    before field lgdcepcmp
      display by name l_tel.lgdcepcmp attribute(reverse)
    after field lgdcepcmp
      display by name l_tel.lgdcepcmp

    if l_tel.lgdcep is not null and
       l_tel.lgdcepcmp is not null then
      initialize l_glaklgd.* to null
      initialize l_ret_cts06g06 to null
      initialize l_glakcid.* to null
      whenever error continue
      open cctc71m00008 using l_tel.lgdcep ,
                              l_tel.lgdcepcmp
      fetch cctc71m00008 into l_glaklgd.lgdtip,
                              l_glaklgd.lgdnom,
                              l_glaklgd.cidcod,
                              l_glaklgd.brrcod
      whenever error stop
      if sqlca.sqlcode < 0 then
         error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
                sqlca.sqlerrd[2] using "<<<<"           ,
                " na leitura do prepare pctc71m00008 " ,
                " comunique a Informatica "
         next field previous
      else
         if sqlca.sqlcode = 100 then
            close cctc71m00008
            error "Cep nao cadastrado "
            next field lgdcep
         else
            call cts06g06(l_glaklgd.lgdnom)
            returning l_ret_cts06g06
            whenever error continue
            open cctc71m00009 using l_glaklgd.cidcod
            whenever error stop
            fetch cctc71m00009 into l_glakcid.cidnom,
                                    l_glakcid.ufdcod
            if sqlca.sqlcode < 0 then
               error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
               sqlca.sqlerrd[2] using "<<<<"           ,
               " na leitura do prepare pctc71m00009 " ,
               " comunique a Informatica "
               next field previous
            else
               if sqlca.sqlcode = 100 then
               else
                  whenever error continue
                  open cctc71m00010 using l_glaklgd.cidcod ,
                                          l_glaklgd.brrcod
                  fetch cctc71m00010 into l_glakbrr_brrnom
                  whenever error stop
                  if sqlca.sqlcode < 0 then
                     error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
                     sqlca.sqlerrd[2] using "<<<<"           ,
                     " na leitura do prepare pctc71m00010 " ,
                     " comunique a Informatica "
                  else
                     if sqlca.sqlcode = 100 then
                     else
                        let l_tel.cidnom    = l_glakcid.cidnom
                        let l_tel.ufdcod    = l_glakcid.ufdcod
                        let l_tel.lgdtip    = l_glaklgd.lgdtip
                        let l_tel.lgdnom    = l_glaklgd.lgdnom
                        let l_tel.brrnom    = l_glakbrr_brrnom
                        display by name l_tel.cidnom ,
                                        l_tel.ufdcod ,
                                        l_tel.lgdtip ,
                                        l_tel.lgdnom ,
                                        l_tel.brrnom
                     end if
                  end if
                  close cctc71m00010
               end if
            end if
           close cctc71m00009
         end if
      end if
      close cctc71m00008
     end if
    before field cidnom
      display by name l_tel.cidnom attribute(reverse)
    after  field cidnom
      display by name l_tel.cidnom
    before field ufdcod
      display by name l_tel.ufdcod attribute(reverse)
    after field ufdcod
      initialize l_auxcidcod to null
      whenever error continue
      open cctc71m00011 using l_tel.ufdcod ,
                              l_tel.cidnom
      fetch cctc71m00011 into l_glakcid.cidcod,
                              l_glakcid.cidnom,
                              l_glakcid.ufdcod
      whenever error stop
      if sqlca.sqlcode < 0 then
         error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
         sqlca.sqlerrd[2] using "<<<<"           ,
         " na leitura do prepare pctc71m00011" ,
         " comunique a Informatica "
         next field previous
      else
         if sqlca.sqlcode = 100 then
            initialize l_ret_cts06g04 to null # cidnom
            call cts06g04(l_tel.cidnom ,
                          l_tel.ufdcod )
            returning l_auxcidcod    ,
                      l_ret_cts06g04 ,
                      l_tel.ufdcod

            if l_ret_cts06g04 is null then
               error "Cidade nao cadastrada "
               next field cidnom
            else
               let l_tel.cidnom     = l_ret_cts06g04
               let l_tel.ufdcod     = l_tel.ufdcod
               let l_glakcid.cidcod = l_auxcidcod  # EVANDRO
            end if
         end if
      end if
      close cctc71m00011
      display by name l_tel.ufdcod
      display by name l_tel.cidnom
    before field lgdtip
      display by name l_tel.lgdtip attribute(reverse)
    after field lgdtip
      display by name l_tel.lgdtip

    before field lgdnom
       display by name l_tel.lgdnom attribute(reverse)
    after field lgdnom
      display by name l_tel.lgdnom

    before field lgdnum
      display by name l_tel.lgdnum attribute(reverse)
    after field lgdnum
      display by name l_tel.lgdnum
      initialize l_cts23g00.* to null
      initialize l_cts06g09.* to null
      call cts23g00_inf_cidade(2,
                              "",
                              l_tel.cidnom ,
                              l_tel.ufdcod)
      returning l_cts23g00.*
      let l_datkfxolcl.lclltt = l_cts23g00.lclltt
      let l_datkfxolcl.lcllgt = l_cts23g00.lcllgt

      if l_cts23g00.mpacrglgdflg = "1" then

         # -> VERIFICA SE A ROTERIZACAO ESTA ATIVA
         if ctx25g05_rota_ativa() then

            initialize lr_ctx25g05.* to null
            call ctx25g05("C", # -> INPUT COMPLETO
                          "                 PESQUISA DE LOGRADOUROS/MAPAS - ROTERIZADO                 ",
                          l_tel.ufdcod,
                          l_tel.cidnom,
                          l_tel.lgdtip,
                          l_tel.lgdnom,
                          l_tel.lgdnum,
                          l_tel.brrnom,
                          "",
                          "",
                          "",
                          "",
                          "",
                          "")

                 returning lr_ctx25g05.lgdtip,
                           lr_ctx25g05.lgdnom,
                           lr_ctx25g05.lgdnum,
                           lr_ctx25g05.brrnom,
                           l_aux,
                           lr_ctx25g05.lgdcep,
                           lr_ctx25g05.lgdcepcmp,
                           lr_ctx25g05.lclltt,
                           lr_ctx25g05.lcllgt,
                           lr_ctx25g05.c24lclpdrcod,
                           lr_ctx25g05.ufdcod,
                           lr_ctx25g05.cidnom

           let l_datkfxolcl.lgdtip       = lr_ctx25g05.lgdtip
           let l_datkfxolcl.lgdnom       = lr_ctx25g05.lgdnom
           let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
           let l_datkfxolcl.lgdnum       = lr_ctx25g05.lgdnum
           let l_datkfxolcl.lgdcep       = lr_ctx25g05.lgdcep
           let l_datkfxolcl.lgdcepcmp    = lr_ctx25g05.lgdcepcmp
           let l_datkfxolcl.brrnom       = lr_ctx25g05.brrnom
           let l_datkfxolcl.cidnom       = lr_ctx25g05.cidnom
           let l_datkfxolcl.ufdcod       = lr_ctx25g05.ufdcod
           let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom
           let l_datkfxolcl.c24lclpdrcod = lr_ctx25g05.c24lclpdrcod

           let l_datkfxolcl.lclltt       = lr_ctx25g05.lclltt
           let l_datkfxolcl.lcllgt       = lr_ctx25g05.lcllgt

         else
             call cts06g09(l_tel.lgdtip,
                       l_tel.lgdnom,
                       l_tel.lgdnum,
                       l_tel.brrnom ,
                       l_cts23g00.mpacidcod)
             returning l_cts06g09.*

             let l_datkfxolcl.lgdtip       = l_cts06g09.lgdtip
             let l_datkfxolcl.lgdnom       = l_cts06g09.lgdnom
             let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
             let l_datkfxolcl.lgdnum       = l_tel.lgdnum
             let l_datkfxolcl.lgdcep       = l_cts06g09.lgdcep
             let l_datkfxolcl.lgdcepcmp    = l_cts06g09.lgdcepcmp
             let l_datkfxolcl.brrnom       = l_cts06g09.brrnom
             let l_datkfxolcl.cidnom       = l_tel.cidnom
             let l_datkfxolcl.ufdcod       = l_tel.ufdcod
             let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom
             let l_datkfxolcl.c24lclpdrcod = l_cts06g09.c24lclpdrcod

             let l_datkfxolcl.lclltt       = l_cts06g09.lclltt
             let l_datkfxolcl.lcllgt       = l_cts06g09.lcllgt

         end if

         let l_tel.lgdcep       = ""
         let l_tel.lgdcepcmp    = ""
         let l_tel.cidnom       = ""
         let l_tel.ufdcod       = ""
         let l_tel.lgdtip       = ""
         let l_tel.lgdnom       = ""
         let l_tel.lgdnum       = ""
         let l_tel.lgdcmp       = ""
         let l_tel.brrnom       = ""

         display by name l_tel.lgdcep       ,
                         l_tel.lgdcepcmp    ,
                         l_tel.cidnom       ,
                         l_tel.ufdcod       ,
                         l_tel.lgdtip       ,
                         l_tel.lgdnom       ,
                         l_tel.lgdnum       ,
                         l_tel.lgdcmp       ,
                         l_tel.brrnom

         let l_tel.lgdcep       = l_datkfxolcl.lgdcep
         let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
         let l_tel.cidnom       = l_datkfxolcl.cidnom
         let l_tel.ufdcod       = l_datkfxolcl.ufdcod
         let l_tel.lgdtip       = l_datkfxolcl.lgdtip
         let l_tel.lgdnom       = l_datkfxolcl.lgdnom
         let l_tel.lgdnum       = l_datkfxolcl.lgdnum
         let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
         let l_tel.brrnom       = l_datkfxolcl.brrnom

         display by name l_tel.lgdcep       ,
                         l_tel.lgdcepcmp    ,
                         l_tel.cidnom       ,
                         l_tel.ufdcod       ,
                         l_tel.lgdtip       ,
                         l_tel.lgdnom       ,
                         l_tel.lgdnum       ,
                         l_tel.lgdcmp       ,
                         l_tel.brrnom

      else
         let int_flag = false
         initialize l_cts06g05.* to null

         call cts06g05(l_tel.lgdtip     ,
                       l_tel.lgdnom     ,
                       l_tel.lgdnum     ,
                       l_tel.brrnom     ,
              #########l_glaklgd.cidcod ,
                       l_glakcid.cidcod ,   # Evandro / Ligia
                       l_tel.ufdcod)
         returning l_cts06g05.*

         let int_flag                  = false
         let l_datkfxolcl.lgdtip       = l_cts06g05.lgdtip
         let l_datkfxolcl.lgdnom       = l_cts06g05.lgdnom
         let l_datkfxolcl.lgdcmp       = l_tel.lgdcmp
         let l_datkfxolcl.lgdnum       = l_tel.lgdnum
         let l_datkfxolcl.lgdcep       = l_cts06g05.lgdcep
         let l_datkfxolcl.lgdcepcmp    = l_cts06g05.lgdcepcmp
         let l_datkfxolcl.brrnom       = l_cts06g05.brrnom
         let l_datkfxolcl.cidnom       = l_tel.cidnom
         let l_datkfxolcl.ufdcod       = l_tel.ufdcod
         let l_datkfxolcl.c24lclpdrcod = l_cts06g05.c24lclpdrcod

         let l_tel.lgdcep       = l_datkfxolcl.lgdcep
         let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
         let l_tel.cidnom       = l_datkfxolcl.cidnom
         let l_tel.ufdcod       = l_datkfxolcl.ufdcod
         let l_tel.lgdtip       = l_datkfxolcl.lgdtip
         let l_tel.lgdnom       = l_datkfxolcl.lgdnom
         let l_tel.lgdnum       = l_datkfxolcl.lgdnum
         let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
         let l_tel.brrnom       = l_datkfxolcl.brrnom

         if l_cts06g05.c24lclpdrcod <> 1 and
            l_cts06g05.c24lclpdrcod <> 2 and
            l_cts06g05.c24lclpdrcod <> 3 and
            l_cts06g05.c24lclpdrcod <> 4 and # PSI 252891
            l_cts06g05.c24lclpdrcod <> 5 then
            error "Codigo de padronizacao invalido"
            next field lgdtip
         else
            display by name l_tel.lgdcep       ,
                            l_tel.lgdcepcmp    ,
                            l_tel.cidnom       ,
                            l_tel.ufdcod       ,
                            l_tel.lgdtip       ,
                            l_tel.lgdnom       ,
                            l_tel.lgdnum       ,
                            l_tel.lgdcmp       ,
                            l_tel.brrnom
         end if
      end if

    before field brrzonnom
      display by name l_tel.brrzonnom attribute(reverse)
    after field brrzonnom
      display by name l_tel.brrzonnom
      if l_tel.brrzonnom <> "NO" and
         l_tel.brrzonnom <> "LE" and
         l_tel.brrzonnom <> "OE" and
         l_tel.brrzonnom <> "SU" and
         l_tel.brrzonnom <> "CE" then
         error "Zona deve ser (NO)rte,(LE)este,(SU)l,ou (CE)ntral!"
         next field brrzonnom
      else
         let l_datkfxolcl.brrzonnom    = l_tel.brrzonnom
         whenever error continue
         #OSF 33979 - alterar l_datkfxolcl p/ l_tel nos campos lgdtip,lgdnom
         #           ,lgdcmp,lgdnum,lgdcep,lgdcepcmp,brrnom,cidnom,ufdcod
         execute pctc71m00002 using l_tel.c24fxolclcod , l_tel.c24fxolcldes   ,
                         l_tel.lgdtip                  ,l_tel.lgdnom       ,
                         l_tel.lgdcmp                  ,l_tel.lgdnum       ,
                         l_tel.lgdcep                  ,l_tel.lgdcepcmp    ,
                         l_tel.brrnom                  ,l_tel.cidnom       ,
                         l_tel.ufdcod                  ,l_tel.brrzonnom,
                         l_datkfxolcl.c24lclpdrcod ,l_datkfxolcl.lclltt       ,
                         l_datkfxolcl.lcllgt       ,l_atlhordata              ,
                         g_issk.empcod             ,g_issk.funmat             ,
                         g_issk.usrtip             ,l_atlhordata              ,
                         g_issk.empcod             ,g_issk.funmat             ,
                         g_issk.usrtip
         whenever error stop
         if sqlca.sqlcode < 0 then
            error  " Erro ",sqlca.sqlcode using "<<<<<<"   ,
                   sqlca.sqlerrd[2] using "<<<<"           ,
                   " na execucao do prepare pctc71m00002 " ,
                   " comunique a Informatica "
         else
            error "Dados inseridos corretamente"
         end if
      end if

  end input

end function


function consulta_ctc71m00()
    define l_tel record
           c24fxolclcod like datkfxolcl.c24fxolclcod ,
           c24fxolcldes like datkfxolcl.c24fxolcldes ,
           lgdcep       like datkfxolcl.lgdcep       ,
           lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
           cidnom       like datkfxolcl.cidnom       ,
           ufdcod       like datkfxolcl.ufdcod       ,
           lgdtip       like datkfxolcl.lgdtip       ,
           lgdnom       like datkfxolcl.lgdnom       ,
           lgdnum       like datkfxolcl.lgdnum       ,
           lgdcmp       like datkfxolcl.lgdcmp       ,
           brrnom       like datkfxolcl.brrnom       ,
           brrzonnom    like datkfxolcl.brrzonnom
       end record

  define l_datkfxolcl record
         c24fxolclcod like datkfxolcl.c24fxolclcod    ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_flgSelciona smallint
  define l_flgerro     smallint

  let l_flgSelciona = false
  let l_flgerro     = false
  let m_flgSelCod   = false
  let m_flgSelDesc  = false

  initialize l_tel.* to null

  input by name l_tel.*
    before field c24fxolclcod
       display by name l_tel.c24fxolclcod attribute(reverse)
    after field c24fxolclcod
       display by name l_tel.c24fxolclcod
    before field c24fxolcldes
       display by name l_tel.c24fxolcldes attribute(reverse)
    after field c24fxolcldes
       display by name l_tel.c24fxolcldes
       if l_tel.c24fxolclcod is not null then
          initialize m_numerrsql to null
          call consulta_porcod_ctc71m00(l_tel.*)

          returning l_tel.*        ,
                    l_datkfxolcl.* ,
                    l_flgSelciona  ,
                    l_flgerro

          if l_flgerro then
             error " Erro ", m_numerrsql using "<<<<<<",
             sqlca.sqlerrd[2] using "<<<<"  ,
             " na leitura de cctc71m00001 " ,
             " comunique a Informatica "
          else
             if l_flgSelciona then
                display by name l_tel.*
             else
                if l_datkfxolcl.brrnom is null then
                    error "Local Cancelado"
                end if
             end if
          end if
          exit input
       else
          call consulta_pordesc_ctc71m00(l_tel.*)
          returning l_tel.*        ,
                    l_datkfxolcl.* ,
                    l_flgSelciona  ,
                    l_flgerro
          if l_flgerro then
             error " Erro ",m_numerrsql using "<<<<<<",
             sqlca.sqlerrd[2] using "<<<<"  ,
             " na leitura de cctc71m00007 " ,
             " comunique a Informatica "
          else
             if l_flgSelciona then
                display by name l_tel.*
                let m_flgSelDesc  = true
             end if
          end if
          exit input
       end if
  end input

  return l_flgSelciona  ,
         l_datkfxolcl.* ,
         l_tel.c24fxolclcod

end function

function consulta_porcod_ctc71m00(l_tel)
  define l_tel record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  define l_datkfxolcl record
         c24fxolclcod   like datkfxolcl.c24fxolclcod  ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_flgSelciona smallint
  define l_flgerro smallint

  let l_flgerro     = false
  let l_flgSelciona = false
  whenever error continue
  initialize l_datkfxolcl.* to null
  open cctc71m00001 using l_tel.c24fxolclcod
  fetch cctc71m00001 into l_datkfxolcl.*
  whenever error stop
  if sqlca.sqlcode < 0 then
     let m_numerrsql = sqlca.sqlcode
     let l_flgerro     = true
  else
     if sqlca.sqlcode <> 100 then
        let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
        let l_tel.lgdcep       = l_datkfxolcl.lgdcep
        let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
        let l_tel.cidnom       = l_datkfxolcl.cidnom
        let l_tel.ufdcod       = l_datkfxolcl.ufdcod
        let l_tel.lgdtip       = l_datkfxolcl.lgdtip
        let l_tel.lgdnom       = l_datkfxolcl.lgdnom
        let l_tel.lgdnum       = l_datkfxolcl.lgdnum
        let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
        let l_tel.brrnom       = l_datkfxolcl.brrnom
        let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom
        let l_flgSelciona = true
        let m_flgSelCod   = true
     end if
 end if
 close cctc71m00001

 return l_tel.*        ,
        l_datkfxolcl.* ,
        l_flgSelciona  ,
        l_flgerro

end function

function consulta_pordesc_ctc71m00(l_tel)
  define l_tel record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  define l_datkfxolcl record
         c24fxolclcod like datkfxolcl.c24fxolclcod    ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt        ,
         canhordat      like datkfxolcl.canhordat
     end record

  define l_flgSelciona smallint
  define l_flgerro     smallint

  let l_flgerro     = false
  let l_flgSelciona = false

  whenever error continue
  initialize l_datkfxolcl.* to null
  if l_tel.c24fxolcldes is not null then
     let l_tel.c24fxolcldes =  "*" clipped , l_tel.c24fxolcldes clipped , "*"
  end if
  open cctc71m00007 using l_tel.c24fxolcldes
  fetch cctc71m00007 into l_datkfxolcl.*
  whenever error stop
  if sqlca.sqlcode < 0 then
     let m_numerrsql = sqlca.sqlcode
     let l_flgerro     = true
  else
     if sqlca.sqlcode <> 100 then
        let l_tel.c24fxolclcod = l_datkfxolcl.c24fxolclcod
        let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
        let l_tel.lgdcep       = l_datkfxolcl.lgdcep
        let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
        let l_tel.cidnom       = l_datkfxolcl.cidnom
        let l_tel.ufdcod       = l_datkfxolcl.ufdcod
        let l_tel.lgdtip       = l_datkfxolcl.lgdtip
        let l_tel.lgdnom       = l_datkfxolcl.lgdnom
        let l_tel.lgdnum       = l_datkfxolcl.lgdnum
        let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
        let l_tel.brrnom       = l_datkfxolcl.brrnom
        let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom
        let l_flgSelciona = true
     else
        error "Nao foi encontrado local com esta descricao "
     end if
 end if

 return l_tel.*        ,
        l_datkfxolcl.* ,
        l_flgSelciona  ,
        l_flgerro

end function


function paginacao_ctc71m00()

    define l_tel record
           c24fxolclcod like datkfxolcl.c24fxolclcod ,
           c24fxolcldes like datkfxolcl.c24fxolcldes ,
           lgdcep       like datkfxolcl.lgdcep       ,
           lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
           cidnom       like datkfxolcl.cidnom       ,
           ufdcod       like datkfxolcl.ufdcod       ,
           lgdtip       like datkfxolcl.lgdtip       ,
           lgdnom       like datkfxolcl.lgdnom       ,
           lgdnum       like datkfxolcl.lgdnum       ,
           lgdcmp       like datkfxolcl.lgdcmp       ,
           brrnom       like datkfxolcl.brrnom       ,
           brrzonnom    like datkfxolcl.brrzonnom
       end record

  define l_datkfxolcl record
         c24fxolclcod   like datkfxolcl.c24fxolclcod  ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt
     end record

  define l_ret record
         c24fxolclcod   like datkfxolcl.c24fxolclcod  ,
         c24fxolcldes   like datkfxolcl.c24fxolcldes  ,
         lgdtip         like datkfxolcl.lgdtip        ,
         lgdnom         like datkfxolcl.lgdnom        ,
         lgdcmp         like datkfxolcl.lgdcmp        ,
         lgdnum         like datkfxolcl.lgdnum        ,
         lgdcep         like datkfxolcl.lgdcep        ,
         lgdcepcmp      like datkfxolcl.lgdcepcmp     ,
         brrnom         like datkfxolcl.brrnom        ,
         cidnom         like datkfxolcl.cidnom        ,
         ufdcod         like datkfxolcl.ufdcod        ,
         brrzonnom      like datkfxolcl.brrzonnom     ,
         c24lclpdrcod   like datkfxolcl.c24lclpdrcod  ,
         lclltt         like datkfxolcl.lclltt        ,
         lcllgt         like datkfxolcl.lcllgt
     end record

  define l_anttel     record
         c24fxolclcod like datkfxolcl.c24fxolclcod ,
         c24fxolcldes like datkfxolcl.c24fxolcldes ,
         lgdcep       like datkfxolcl.lgdcep       ,
         lgdcepcmp    like datkfxolcl.lgdcepcmp    ,
         cidnom       like datkfxolcl.cidnom       ,
         ufdcod       like datkfxolcl.ufdcod       ,
         lgdtip       like datkfxolcl.lgdtip       ,
         lgdnom       like datkfxolcl.lgdnom       ,
         lgdnum       like datkfxolcl.lgdnum       ,
         lgdcmp       like datkfxolcl.lgdcmp       ,
         brrnom       like datkfxolcl.brrnom       ,
         brrzonnom    like datkfxolcl.brrzonnom
     end record

  define l_descricao  like datkfxolcl.c24fxolcldes

  if m_flgAntProx = 1 then
     initialize l_datkfxolcl.* to null
     whenever error continue
     fetch relative + 1  cctc71m00007 into l_datkfxolcl.*
     whenever error stop
     if sqlca.sqlcode < 0 then
        error " Erro ",sqlca.sqlcode using "<<<<<<",
        sqlca.sqlerrd[2] using "<<<<"  ,
        " na execucao de cctc71m00005 " ,
        " comunique a Informatica "
     else
        if sqlca.sqlcode = 100 then
           error "Nao ha mais linhas nesta direcao"
           whenever error continue
           fetch current  cctc71m00007 into l_datkfxolcl.*
           whenever error stop
           if sqlca.sqlcode < 0 then
              error " Erro ",sqlca.sqlcode using "<<<<<<",
              sqlca.sqlerrd[2] using "<<<<"  ,
              " na execucao de cctc71m00005 " ,
              " comunique a Informatica "
           else
              if sqlca.sqlcode <> 100 then
                 let l_tel.c24fxolclcod = l_datkfxolcl.c24fxolclcod
                 let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
                 let l_tel.lgdcep       = l_datkfxolcl.lgdcep
                 let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
                 let l_tel.cidnom       = l_datkfxolcl.cidnom
                 let l_tel.ufdcod       = l_datkfxolcl.ufdcod
                 let l_tel.lgdtip       = l_datkfxolcl.lgdtip
                 let l_tel.lgdnom       = l_datkfxolcl.lgdnom
                 let l_tel.lgdnum       = l_datkfxolcl.lgdnum
                 let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
                 let l_tel.brrnom       = l_datkfxolcl.brrnom
                 let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom
              end if
           end if
        else
           let l_tel.c24fxolclcod = l_datkfxolcl.c24fxolclcod
           let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
           let l_tel.lgdcep       = l_datkfxolcl.lgdcep
           let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
           let l_tel.cidnom       = l_datkfxolcl.cidnom
           let l_tel.ufdcod       = l_datkfxolcl.ufdcod
           let l_tel.lgdtip       = l_datkfxolcl.lgdtip
           let l_tel.lgdnom       = l_datkfxolcl.lgdnom
           let l_tel.lgdnum       = l_datkfxolcl.lgdnum
           let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
           let l_tel.brrnom       = l_datkfxolcl.brrnom
           let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom


        end if
        display by name l_tel.*
     end if
  else
     initialize l_datkfxolcl.* to null
     whenever error continue
     fetch relative -1 cctc71m00007 into l_datkfxolcl.*
     whenever error stop
     if sqlca.sqlcode < 0 then
        error " Erro ",sqlca.sqlcode using "<<<<<<",
              sqlca.sqlerrd[2] using "<<<<"  ,
              " na execucao de cctc71m00005 " ,
              " comunique a Informatica "
     else
        if sqlca.sqlcode = 100 then
           error "Nao ha mais linhas nesta direcao"
           whenever error continue
           fetch current  cctc71m00007 into l_datkfxolcl.*
           whenever error stop
           if sqlca.sqlcode < 0 then
              error " Erro ",sqlca.sqlcode using "<<<<<<",
              sqlca.sqlerrd[2] using "<<<<"  ,
              " na leitura de cctc71m0007" ,
              " comunique a Informatica "
           else
              if sqlca.sqlcode <> 100 then
                 let l_tel.c24fxolclcod = l_datkfxolcl.c24fxolclcod
                 let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
                 let l_tel.lgdcep       = l_datkfxolcl.lgdcep
                 let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
                 let l_tel.cidnom       = l_datkfxolcl.cidnom
                 let l_tel.ufdcod       = l_datkfxolcl.ufdcod
                 let l_tel.lgdtip       = l_datkfxolcl.lgdtip
                 let l_tel.lgdnom       = l_datkfxolcl.lgdnom
                 let l_tel.lgdnum       = l_datkfxolcl.lgdnum
                 let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
                 let l_tel.brrnom       = l_datkfxolcl.brrnom
                 let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom
              end if
           end if
        else
           let l_tel.c24fxolclcod = l_datkfxolcl.c24fxolclcod
           let l_tel.c24fxolcldes = l_datkfxolcl.c24fxolcldes
           let l_tel.lgdcep       = l_datkfxolcl.lgdcep
           let l_tel.lgdcepcmp    = l_datkfxolcl.lgdcepcmp
           let l_tel.cidnom       = l_datkfxolcl.cidnom
           let l_tel.ufdcod       = l_datkfxolcl.ufdcod
           let l_tel.lgdtip       = l_datkfxolcl.lgdtip
           let l_tel.lgdnom       = l_datkfxolcl.lgdnom
           let l_tel.lgdnum       = l_datkfxolcl.lgdnum
           let l_tel.lgdcmp       = l_datkfxolcl.lgdcmp
           let l_tel.brrnom       = l_datkfxolcl.brrnom
           let l_tel.brrzonnom    = l_datkfxolcl.brrzonnom


        end if
        display by name l_tel.*
     end if
  end if
  return l_tel.*
end function


#--------------------------------------------------------------------------
#                            Fim de programa
#--------------------------------------------------------------------------
