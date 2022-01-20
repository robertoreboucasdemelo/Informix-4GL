#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: ct24h                                                     #
# Modulo         : bdbsr099                                                  #
# Analista Resp. : Ruiz                                                      #
# PSI            : PSI 149969 - OSF 2917                                     #
#............................................................................#
# Liberacao      :   /04/2002                                                #
#............................................................................#
#                                                                            #
#                        ***ALTERACOES***                                    #
#                                                                            #
#  Data        Autor  Fabrica         Data           Alteracao               #
#  ----        --------------         ----           ---------               #
#  02/05/2002  Perola                                                        #
#----------------------------------------------------------------------------#
#  22/04/2003  FERNANDO - FSW                        RESOLUCAO 86            #
#-----------------------------------------------------------------------------#
#=============================================================================#
# Alterado : 23/07/2002 - Celso                                               #
#            Utilizacao da funcao fgckc811 para enderecamento de corretores   #
#            22/04/2003 - FERNANDO - FSW                                      #
#            RESOLUCAO 86                                                     #
#=============================================================================#
# Data       Autor Fabrica   PSI/OSF Alteracao                                #
# --------   --------------- ------- -----------------------------------------#
# 24/10/2003 Meta, Jefferson 168890  Adicionar o campo modalidade no          #
#                             27847  relatorio.                               #
#-----------------------------------------------------------------------------#
# 11/12/2003 Meta, James     168890  Correcao da sumarizacao da modalidade    #
#                             27847  no relatorio.                            #
#-----------------------------------------------------------------------------#
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 04/06/2007 Cristiane Silva    PSI207373 Atendimento clausulas 33,34,94      #
#-----------------------------------------------------------------------------#
# 17/08/2007 Klaus, Meta        PSI211915 Alteracao de sql para contemplar a  #
#                                         tabela rgfkmrsapccls                #
#-----------------------------------------------------------------------------#
# 18/03/2010 Beatriz Araujo     PSI219444 Buscar a descrição da clausula de   #
#                                         uma função do RE, e não acessar     #
#                                         direto a base deles                 #
#-----------------------------------------------------------------------------#

#-----------------------------------
#  Definicao de globals
#-----------------------------------

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------
#  Definicao de variaveis modulares
#-----------------------------------
  define name_file char(80)
  define ws_cctcod      like igbrrelcct.cctcod
  define ws_relviaqtd   like igbrrelcct.relviaqtd

  define m_path         char(100)

#-----------------------------------
#  Funcao main
#-----------------------------------
   main
    call fun_dba_abre_banco("CT24HS")

    set isolation to dirty read

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr099.log"

    call startlog(m_path)
    # PSI 185035 - Final

     call bdbsr099_create_tmp()
     call bdbsr099_sql()
     call bdbsr099()
   end main

#-----------------------------------
#  Funcao prepara SQL
#-----------------------------------
function bdbsr099_sql()

  define l_cmd    char(1000)
  define l_flg    char(01)

  let l_cmd = null
  let l_flg = null

  if l_flg = "S" then
     return
  else
     let l_flg = "S"
  end if

  let l_cmd = " select nom, corsus, atdsrvorg, atdsrvnum,atdsrvano, ",
              "    funmat, atddat, atdhor                           ",
              "    from  datmservico                                ",
              "    where atddat    = ?                              ",
              "      and atdsrvorg = 9                              "
  prepare pbdbsr099001 from l_cmd
  declare cbdbsr099001 cursor for pbdbsr099001

  let l_cmd = " select funnom from isskfunc                 ",
              "    where funmat = ?                         "
  prepare pbdbsr099002 from l_cmd
  declare cbdbsr099002 cursor for pbdbsr099002

  let l_cmd = " select succod, ramcod, aplnumdig, itmnumdig ",
              "    from datrservapol                        ",
              "    where atdsrvnum = ?                      ",
              "      and atdsrvano = ?                      "
  prepare pbdbsr099003 from l_cmd
  declare cbdbsr099003 cursor for pbdbsr099003

  let l_cmd = " select b.cornom",
              "    from gcaksusep a, gcakcorr b",
              "    where a.corsus = ?",
              "      and b.corsuspcp = a.corsuspcp"
  prepare pbdbsr099004 from l_cmd
  declare cbdbsr099004 cursor for pbdbsr099004

  let l_cmd = " select pgrnum from htlrust    ",
              "   where corsus = ?            ",
              "     and ustsit = 'A'          "
  prepare pbdbsr099005 from l_cmd
  declare cbdbsr099005 cursor for pbdbsr099005

  let l_cmd = " select viginc, vigfnl from abamapol ",
              "   where succod    = ?               ",
              "     and aplnumdig = ?               "
  prepare pbdbsr099006 from l_cmd
  declare cbdbsr099006 cursor for pbdbsr099006

  let l_cmd = " select clscod from abbmclaus                     ",
              "   where succod    = ?                            ",
              "     and aplnumdig = ?                            ",
              "     and itmnumdig = ?                            ",
              "     and dctnumseq = ?                            ",
              "     and clscod in('034','035','055','34A','35A','35R','033','33R') " ## PSI207373
  prepare pbdbsr099007 from l_cmd
  declare cbdbsr099007 cursor for pbdbsr099007

  let l_cmd = " select vclcoddig, vclanomdl, vcllicnum   ",
              "   from abbmveic                          ",
              "   where succod    = ?                    ",
              "     and aplnumdig = ?                    ",
              "     and itmnumdig = ?                    ",
              "     and dctnumseq = ?                    "
  prepare pbdbsr099008 from l_cmd
  declare cbdbsr099008 cursor for pbdbsr099008

  let l_cmd = " select max(dctnumseq) from  abbmveic  ",
              "  where succod    = ?                  ",
              "    and aplnumdig = ?                  ",
              "    and itmnumdig = ?                  "
  prepare pbdbsr099009 from l_cmd
  declare cbdbsr099009 cursor for pbdbsr099009

  let l_cmd = " select vclcoddig, vclanomdl, vcllicnum   ",
              "   from abbmveic                          ",
              "   where succod    = ?                    ",
              "     and aplnumdig = ?                    ",
              "     and itmnumdig = ?                    ",
              "     and dctnumseq = ?                    "
  prepare pbdbsr099010 from l_cmd
  declare cbdbsr099010 cursor for pbdbsr099010

  let l_cmd = " select sgrorg, sgrnumdig, rmemdlcod     ", #psi168890
              "   from rsamseguro                       ",
              "  where succod    = ?                    ",
              "    and ramcod    = ?                    ",
              "    and aplnumdig = ?                    "
  prepare pbdbsr099011 from l_cmd
  declare cbdbsr099011 cursor for pbdbsr099011

  let l_cmd = " select viginc, vigfnl from rsdmdocto  ",
              "   where sgrorg    =  ?                ",
              "     and sgrnumdig =  ?                ",
              "     and dctnumseq = 1                 "
  prepare pbdbsr099012 from l_cmd
  declare cbdbsr099012 cursor for pbdbsr099012

  let l_cmd = " select max(dctnumseq) from rsdmdocto  ",
              "   where sgrorg    = ?                 ",
              "     and sgrnumdig = ?                 ",
              "     and prpstt in(19,66,88)           "
  prepare pbdbsr099013 from l_cmd
  declare cbdbsr099013 cursor for pbdbsr099013

  let l_cmd = " select prporg, prpnumdig from rsdmdocto ",
              "   where sgrorg    = ?                   ",
              "     and sgrnumdig = ?                   ",
              "     and dctnumseq = ?                   "
  prepare pbdbsr099014 from l_cmd
  declare cbdbsr099014 cursor for pbdbsr099014

  let l_cmd = " select clscod from rsdmclaus            ",
              "   where prporg    = ?                   ",
              "     and prpnumdig = ?                   ",
              "     and lclnumseq = 1                   ",
              "     and clsstt    = 'A'                 "
  prepare pbdbsr099015 from l_cmd
  declare cbdbsr099015 cursor for pbdbsr099015

  let l_cmd = " select socntzcod from datmsrvre         ",
              "   where atdsrvnum = ?                   ",
              "     and atdsrvano = ?                   "
  prepare pbdbsr099016 from l_cmd
  declare cbdbsr099016 cursor for pbdbsr099016

  let l_cmd = " select socntzdes from datksocntz        ",
              "   where socntzcod = ?                   ",
              "     and socntzstt = 'A'                 "
  prepare pbdbsr099017 from l_cmd
  declare cbdbsr099017 cursor for pbdbsr099017

  let l_cmd = " select  clsatdqtd from datrramcls       ",
              "   where ramcod = ?                      ",
              "     and clscod = ?                      ",
              "     and rmemdlcod = ?                   "             #psi168890
  prepare pbdbsr099018 from l_cmd
  declare cbdbsr099018 cursor for pbdbsr099018

  let l_cmd = " select socntzcod, ntzatdqtd from datrsocntzsrvre   ",
              "    where ramcod = ?                                ",
              "      and clscod = ?                                ",
              "      and rmemdlcod = ?                             ", #psi168890
              " order by socntzcod                                 "
  prepare pbdbsr099019 from l_cmd
  declare cbdbsr099019 cursor for pbdbsr099019

  let l_cmd = " select a.succod, a.ramcod, a.aplnumdig, a.itmnumdig,  ",
              "  a.atdsrvnum, a.atdsrvano, b.nom, b.funmat, b.atddat, ",
              "  b.atdhor, b.corsus, b.atdsrvorg                      ",
              "  from datrservapol a, datmservico b                   ",
              "  where a.succod    = ?                                ",
              "    and a.ramcod    = ?                                ",
              "    and a.aplnumdig = ?                                ",
              "    and b.atdsrvnum = a.atdsrvnum                      ",
              "    and b.atdsrvano = a.atdsrvano                      ",
              "    and b.atddat   >= ?                                ",
              "    and b.atddat   <= ?                                ",
              "    and b.atdsrvorg = 9                                ",
              "  order by atdsrvano, atddat, atdsrvnum                "
  prepare pbdbsr099020 from l_cmd
  declare cbdbsr099020 cursor for pbdbsr099020

  let l_cmd = " select count(*) from tmp_bdbsr099  ",
              "   where succod    = ?              ",
              "     and ramcod    = ?              ",
              "     and aplnumdig = ?              ",
              "     and atdsrvnum = ?              ",
              "     and atdsrvano = ?              "
  prepare pbdbsr099021 from l_cmd
  declare cbdbsr099021 cursor for pbdbsr099021

  let l_cmd = " insert into tmp_bdbsr099(nom, corsus, atdsrvorg, atdsrvnum, ",
              "                          atdsrvano, funmat, atddat, atdhor, ",
              "                          funnom, succod, ramcod, aplnumdig, ",
              "                          itmnumdig, socntzcod, socntzdes,   ",
              "                          viginc, vigfnl                   ) ",
              " values(? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,? ,?  ) "
  prepare pbdbsr099022 from l_cmd

  let l_cmd = " select  nom, corsus,succod,ramcod,aplnumdig,itmnumdig, ",
              "         viginc,vigfnl                                  ",
              "  from tmp_bdbsr099                                     ",
              "  group by 5,1,2,7,8,3,4,6                              ",
              "  order by succod, ramcod, aplnumdig                    "
  prepare pbdbsr099023 from l_cmd
  declare cbdbsr099023 cursor for pbdbsr099023


  let l_cmd = " select atdsrvorg, atdsrvnum, atdsrvano, socntzcod,       ",
              "        socntzdes, funmat, funnom, atddat, atdhor         ",
              "  from  tmp_bdbsr099                                      ",
              "  where succod    = ?                                     ",
              "    and ramcod    = ?                                     ",
              "    and aplnumdig = ?                                     ",
              "    order by atdsrvano,atddat,atdsrvnum                   "
  prepare pbdbsr099024 from l_cmd
  declare cbdbsr099024 cursor for pbdbsr099024

  let l_cmd = " select unique socntzcod, socntzdes from  tmp_bdbsr099     ",
              "   where succod    = ?                                     ",
              "     and ramcod    = ?                                     ",
              "     and aplnumdig = ?                                     ",
              "  order by socntzcod                                       "
  prepare pbdbsr099025 from l_cmd
  declare cbdbsr099025 cursor for pbdbsr099025

  let l_cmd = " select count(*) from  tmp_bdbsr099                        ",
              "   where succod    = ?                                     ",
              "     and ramcod    = ?                                     ",
              "     and aplnumdig = ?                                     ",
              "     and socntzcod = ?                                     "
  prepare pbdbsr099026 from l_cmd
  declare cbdbsr099026 cursor for pbdbsr099026

  let l_cmd = " select rmemdlnom "
             ,"   from gtakmodal "
             ,"  where empcod = 1 "
             ,"    and ramcod = ? "
             ,"    and rmemdlcod = ? "

  prepare pbdbsr099027 from l_cmd
  declare cbdbsr099027 cursor for pbdbsr099027

  let l_cmd = " select ramnom, ramgrpcod "
             ,"   from gtakram "
             ,"  where empcod = 1 "
             ,"    and ramcod = ? "

  prepare pbdbsr099029 from l_cmd
  declare cbdbsr099029 cursor for pbdbsr099029

  let l_cmd = " select clsdes "
             ,"   from aackcls "
             ,"  where ramcod = ? "
             ,"    and clscod = ? "

  prepare pbdbsr099030 from l_cmd
  declare cbdbsr099030 cursor for pbdbsr099030

  let l_cmd = ' select clsdes '
             ,'   from rgfkclaus2 '
             ,'  where ramcod    = ? '
             ,'    and clscod    = ? '
             ,'    and rmemdlcod = ? '
             ,' union '
             ,' select clsdes '
             ,'   from rgfkmrsapccls '
             ,'  where ramcod    = ? '
             ,'    and clscod    = ? '
             ,'    and rmemdlcod = ? '
  
  prepare pbdbsr099031 from l_cmd
  declare cbdbsr099031 cursor for pbdbsr099031

end function

#-----------------------------------
#  Funcao principal - carrega dados
#-----------------------------------
function bdbsr099()

#--Definicao de Variaveis Locais

  define l_dataexec     date
  define l_dataproc     char(10)
  define l_horaexec     datetime hour to second

  define r_gcakfilial    record
         endlgd          like gcakfilial.endlgd
        ,endnum          like gcakfilial.endnum
        ,endcmp          like gcakfilial.endcmp
        ,endbrr          like gcakfilial.endbrr
        ,endcid          like gcakfilial.endcid
        ,endcep          like gcakfilial.endcep
        ,endcepcmp       like gcakfilial.endcepcmp
        ,endufd          like gcakfilial.endufd
        ,dddcod          like gcakfilial.dddcod
        ,teltxt          like gcakfilial.teltxt
        ,dddfax          like gcakfilial.dddfax
        ,factxt          like gcakfilial.factxt
        ,maides          like gcakfilial.maides
        ,crrdstcod       like gcaksusep.crrdstcod
        ,crrdstnum       like gcaksusep.crrdstnum
        ,crrdstsuc       like gcaksusep.crrdstsuc
        ,stt             smallint
  end record

  define r_bdbsr099  record
     succod        like datrservapol.succod,
     ramcod        like datrservapol.ramcod,
     rmemdlcod     like datrramcls.rmemdlcod,  #psi168890
     rmemdlnom     like gtakmodal.rmemdlnom,  #psi168890
     aplnumdig     like datrservapol.aplnumdig,
     nom           like datmservico.nom,
     corsus        like datmservico.corsus,
     cornom        like gcakcorr.cornom,
     dddcod        like gcakfilial.dddcod,
     teltxt        like gcakfilial.teltxt,
     factxt        like gcakfilial.factxt,
     pgrnum        dec (8,0)          ,
     vcldes        char(50),
     vclanomdl     like abbmveic.vclanomdl,
     vcllicnum     like abbmveic.vcllicnum,
     clscod        like abbmclaus.clscod,
     viginc        like abamapol.viginc,
     vigfnl        like abamapol.vigfnl,
     itmnumdig     like datrservapol.itmnumdig,
     clsatdqtd     like datrramcls.clsatdqtd
  end record
  define ws  record
     qtd           integer,
     qtd1          integer,
     qtdatd        integer,
     qtdatd1       integer,
     impr          integer,
     lidos         integer
  end record

  define l_nom          like  datmservico.nom
  define l_corsus       like  datmservico.corsus
  define l_atdsrvorg    like  datmservico.atdsrvorg
  define l_atdsrvnum    like  datmservico.atdsrvnum
  define l_atdsrvano    like  datmservico.atdsrvano
  define l_funmat       like  datmservico.funmat
  define l_atddat       like  datmservico.atddat
  define l_atdhor       like  datmservico.atdhor
  define l_funnom       like  isskfunc.funnom
  define l_succod       like  datrservapol.succod
  define l_ramcod       like  datrservapol.ramcod
  define l_aplnumdig    like  datrservapol.aplnumdig
  define l_itmnumdig    like  datrservapol.itmnumdig
  define l_socntzcod    like  datmsrvre.socntzcod
  define l_socntzdes    like  datksocntz.socntzdes
  define l_viginc       like  abamapol.viginc
  define l_vigfnl       like  abamapol.vigfnl

  define l_vclcoddig    like  abbmveic.vclcoddig
  define l_maxdctnumseq like  abbmveic.dctnumseq
  define l_sgrorg       like  rsamseguro.sgrorg
  define l_sgrnumdig    like  rsamseguro.sgrnumdig
  define l_prporg       like  rsdmdocto.prporg
  define l_prpnumdig    like  rsdmdocto.prpnumdig
  define name_dir       char(40)
  define l_count        integer
  define lslv_aplnumdig like  datrservapol.aplnumdig
  define l_email        char(500)

  define l_erro smallint  # psi168890

  define l_retorno   smallint
  
#--Inicilizacao de Variaveis
  initialize r_bdbsr099.* to null
  let  l_nom          = null
  let  l_corsus       = null
  let  l_atdsrvorg    = null
  let  l_atdsrvnum    = null
  let  l_atdsrvano    = null
  let  l_funmat       = null
  let  l_atddat       = null
  let  l_atdhor       = null
  let  l_funnom       = null
  let  l_succod       = null
  let  l_ramcod       = null
  let  l_aplnumdig    = null
  let  l_itmnumdig    = null
  let  l_socntzcod    = null
  let  l_socntzdes    = null
  let  l_viginc       = null
  let  l_vigfnl       = null

  let  l_count        = null
  let  lslv_aplnumdig = null
  let  l_vclcoddig    = null
  let  l_maxdctnumseq = null
  let  l_sgrorg       = null
  let  l_sgrnumdig    = null
  let  l_prporg       = null
  let  l_prpnumdig    = null
  let  l_dataexec     = null
  let  l_dataproc     = null
  let  l_horaexec     = null
  let  ws.qtd         = 0
  let  ws.qtd1        = 0

  let l_dataexec = today                  ##1
  let l_dataproc = arg_val(1)             ##2
  let l_horaexec = time                   ##3


  let l_erro = false # psi168890
  
#--Consistindo Data de Processamento
  if l_dataproc is null or l_dataproc = " " then
     if l_horaexec >= "17:00:00" and
        l_horaexec <= "23:59:00" then
        let l_dataproc = today
     else
         let l_dataproc = today - 1
     end if
  else
     if l_dataproc > today or
        length(l_dataproc) < 10  then
        display "***ERRO NO PARAMETRO: DATA INVALIDA!***", l_dataproc
        exit program
     end  if
  end if

#--Padrao UNICENTER
  #---------------------------------------------------------------
  # Define diretorios para relatorios e arquivos
  #---------------------------------------------------------------
  call f_path ("DBS", "ARQUIVO")
           returning name_dir

  if name_dir is null then
     let name_dir = "."
  end if

  let name_file = name_dir clipped,"/RDBS09901"
  #---------------------------------------------------------------
  # Define numero de vias e account dos relatorios
  #---------------------------------------------------------------
  call fgerc010("RDBS09901")
       returning  ws_cctcod,
                  ws_relviaqtd

  start report bdbsr099_rep to name_file

     ##Renata - retirar - perola aqui
     ##let l_dataproc = "04/04/2002"

  open    cbdbsr099001 using  l_dataproc
  foreach cbdbsr099001 into l_nom      ,l_corsus,l_atdsrvorg,l_atdsrvnum,
                            l_atdsrvano,l_funmat,l_atddat   ,l_atdhor

       open  cbdbsr099003 using l_atdsrvnum,l_atdsrvano
       fetch cbdbsr099003 into  l_succod   ,l_ramcod   ,l_aplnumdig,l_itmnumdig
       close cbdbsr099003

       if l_ramcod =  31 or
          l_ramcod = 531 then
          open cbdbsr099006 using l_succod,
                                  l_aplnumdig
          fetch cbdbsr099006 into l_viginc,  ##14
                                  l_vigfnl   ##14
          close cbdbsr099006
       else
          open  cbdbsr099011 using  l_succod, l_ramcod, l_aplnumdig

          whenever error continue
          fetch cbdbsr099011 into l_sgrorg, l_sgrnumdig, r_bdbsr099.rmemdlcod
          whenever error stop

          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> 100 then
                display 'Erro SELECT datmsrvacp(1) ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
                display "bdbsr099() / ",l_succod," / "
                                       ,l_ramcod," / "
                                       ,l_aplnumdig
                let l_erro = true
                exit foreach
             end if
          end if

          close cbdbsr099011

          open  cbdbsr099012 using l_sgrorg, l_sgrnumdig
          fetch cbdbsr099012 into  l_viginc, l_vigfnl
          close cbdbsr099012
       end if

       open    cbdbsr099020 using l_succod, l_ramcod, l_aplnumdig,
                                  l_viginc, l_vigfnl
       foreach cbdbsr099020 into l_succod   ,l_ramcod   ,l_aplnumdig,
                                 l_itmnumdig,l_atdsrvnum,l_atdsrvano,
                                 l_nom      ,l_funmat   ,l_atddat   ,l_atdhor,
                                 l_corsus   ,l_atdsrvorg

          open   cbdbsr099002 using l_funmat
          fetch  cbdbsr099002 into  l_funnom
          close  cbdbsr099002

          open  cbdbsr099016 using l_atdsrvnum, l_atdsrvano
          fetch cbdbsr099016 into l_socntzcod
          close cbdbsr099016

          if sqlca.sqlcode = 0 then
            open  cbdbsr099017 using l_socntzcod
            fetch cbdbsr099017 into  l_socntzdes
            close cbdbsr099017
          end if

          let l_count = 0
          open  cbdbsr099021 using l_succod   ,l_ramcod,
                                   l_aplnumdig,l_atdsrvnum,l_atdsrvano
          fetch cbdbsr099021 into l_count
          close cbdbsr099021
          if l_count = 0 then
             whenever error continue
             execute pbdbsr099022 using l_nom,
                                        l_corsus,
                                        l_atdsrvorg,
                                        l_atdsrvnum,
                                        l_atdsrvano,
                                        l_funmat,
                                        l_atddat,
                                        l_atdhor,
                                        l_funnom,
                                        l_succod,
                                        l_ramcod,
                                        l_aplnumdig,
                                        l_itmnumdig,
                                        l_socntzcod,
                                        l_socntzdes,
                                        l_viginc,
                                        l_vigfnl
             whenever error stop
             if sqlca.sqlcode <> 0 then
                display "Problema no insert da tabela tmp_bdbsr099 ",
                         sqlca.sqlcode
                sleep 2
                return
             end if
          else
             continue foreach
          end if
       end foreach
   end foreach

   if l_erro then
      exit program(1)
   end if

##Leitura da tabela temporaria
   initialize r_bdbsr099.* to null
   let ws.lidos   = 0
   let ws.qtdatd  = 0
   let ws.qtdatd1 = 0
   let ws.impr    = 0
   open    cbdbsr099023
   foreach cbdbsr099023 into r_bdbsr099.nom,
                             r_bdbsr099.corsus,
                             r_bdbsr099.succod,
                             r_bdbsr099.ramcod,
                             r_bdbsr099.aplnumdig,
                             r_bdbsr099.itmnumdig,
                             r_bdbsr099.viginc,
                             r_bdbsr099.vigfnl

       let ws.lidos = ws.lidos + 1
#------Busca o restante dos campos
       let r_bdbsr099.cornom = null
       let r_bdbsr099.dddcod = null
       let r_bdbsr099.teltxt = null
       let r_bdbsr099.factxt = null
       open  cbdbsr099004 using r_bdbsr099.corsus
       fetch cbdbsr099004 into  r_bdbsr099.cornom
       close cbdbsr099004

       #---> Utilizacao da nova funcao de comissoes p/ enderecamento
       initialize r_gcakfilial.* to null
       call fgckc811(r_bdbsr099.corsus)
            returning r_gcakfilial.*
       let r_bdbsr099.dddcod = r_gcakfilial.dddcod
       let r_bdbsr099.teltxt = r_gcakfilial.teltxt
       let r_bdbsr099.factxt = r_gcakfilial.factxt
       #------------------------------------------------------------

       let r_bdbsr099.pgrnum = null
       open  cbdbsr099005 using r_bdbsr099.corsus
       fetch cbdbsr099005 into  r_bdbsr099.pgrnum
       close cbdbsr099005
#---Ramo = 31
       if r_bdbsr099.ramcod =  31 or
          r_bdbsr099.ramcod = 531 then
          let r_bdbsr099.rmemdlcod = 0
          call f_funapol_ultima_situacao(r_bdbsr099.succod,
              r_bdbsr099.aplnumdig,r_bdbsr099.itmnumdig)
              returning g_funapol.*

          let r_bdbsr099.clscod = null
          open cbdbsr099007 using r_bdbsr099.succod,
                                  r_bdbsr099.aplnumdig,
                                  r_bdbsr099.itmnumdig,
                                  g_funapol.dctnumseq
          fetch cbdbsr099007 into r_bdbsr099.clscod
          close cbdbsr099007

          let l_vclcoddig = null
          let r_bdbsr099.vclanomdl = null
          let r_bdbsr099.vcllicnum = null
          open  cbdbsr099008 using r_bdbsr099.succod,
                                   r_bdbsr099.aplnumdig,
                                   r_bdbsr099.itmnumdig,
                                   g_funapol.dctnumseq
          fetch cbdbsr099008 into l_vclcoddig, r_bdbsr099.vclanomdl,
                                  r_bdbsr099.vcllicnum
          close cbdbsr099008
             if sqlca.sqlcode = 0 then
                call cts15g00(l_vclcoddig) returning r_bdbsr099.vcldes  ##10
             else
                let l_maxdctnumseq = null
                open cbdbsr099009 using r_bdbsr099.succod,
                                        r_bdbsr099.aplnumdig,
                                        r_bdbsr099.itmnumdig
                fetch cbdbsr099009 into l_maxdctnumseq
                close cbdbsr099009

                let l_vclcoddig          = null
                let r_bdbsr099.vclanomdl = null
                let r_bdbsr099.vcllicnum = null
                open  cbdbsr099010 using r_bdbsr099.succod,
                                         r_bdbsr099.aplnumdig,
                                         r_bdbsr099.itmnumdig,
                                         l_maxdctnumseq
                fetch cbdbsr099010 into l_vclcoddig, r_bdbsr099.vclanomdl,
                                        r_bdbsr099.vcllicnum
                close cbdbsr099010
                if sqlca.sqlcode = 0 then
                   let r_bdbsr099.vcldes = null
                   call cts15g00(l_vclcoddig) returning r_bdbsr099.vcldes
                else
                   let r_bdbsr099.vcldes    = " "
                   let r_bdbsr099.vclanomdl = " "
                   let r_bdbsr099.vcllicnum = " "
                end if
                close cbdbsr099010
             end if
#---Ramo <> 31
       else

          let l_sgrorg    = null
          let l_sgrnumdig = null
          open  cbdbsr099011 using r_bdbsr099.succod,
                                   r_bdbsr099.ramcod,
                                   r_bdbsr099.aplnumdig

#psi168890
          whenever error continue
          fetch cbdbsr099011 into l_sgrorg, l_sgrnumdig, r_bdbsr099.rmemdlcod
          whenever error stop

          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> 100 then
                display 'Erro SELECT datmsrvacp(2) ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
                display "bdbsr099() / ",l_sgrorg," / "
                                       ,l_sgrnumdig," / "
                                       ,r_bdbsr099.rmemdlcod
                let l_erro = true
                exit foreach
             end if
          end if
          close cbdbsr099011

          open cbdbsr099027 using r_bdbsr099.ramcod
                                 ,r_bdbsr099.rmemdlcod

          whenever error continue
          fetch cbdbsr099027 into r_bdbsr099.rmemdlnom
          whenever error continue


          if sqlca.sqlcode <> 0 and 
               sqlca.sqlcode <> notfound then
             
             display 'Erro SELECT datmsrvacp(3) ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
             display "bdbsr099() / ",r_bdbsr099.ramcod," / "
                                    ,r_bdbsr099.rmemdlcod

             let l_erro = true
             exit foreach
          end if

#fim psi168890

          let l_maxdctnumseq = null
          open  cbdbsr099013 using l_sgrorg, l_sgrnumdig
          fetch cbdbsr099013 into l_maxdctnumseq
          close cbdbsr099013

          let l_prporg = null
          let l_prpnumdig = null
          open  cbdbsr099014 using l_sgrorg, l_sgrnumdig, l_maxdctnumseq
          fetch cbdbsr099014 into l_prporg, l_prpnumdig
          close cbdbsr099014

          let r_bdbsr099.clscod = null
          open  cbdbsr099015 using l_prporg, l_prpnumdig
          fetch cbdbsr099015 into r_bdbsr099.clscod
          close cbdbsr099015

#---Veiculo-ano-placa = " "
          let r_bdbsr099.vcldes    = " "
          let r_bdbsr099.vclanomdl = " "
          let r_bdbsr099.vcllicnum = " "
       end if

       let r_bdbsr099.clsatdqtd = null
       open   cbdbsr099018 using r_bdbsr099.ramcod, r_bdbsr099.clscod ,
                                 r_bdbsr099.rmemdlcod  # Rodrigo - 3125737
                                                       #/PSI 168890
       whenever error continue
       fetch  cbdbsr099018 into  r_bdbsr099.clsatdqtd
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode < 0 then
             display 'Erro SELECT datmsrvacp(4) ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
             display "bdbsr099() / ",r_bdbsr099.ramcod," / "
                                    ,r_bdbsr099.clscod, " / ", r_bdbsr099.rmemdlcod

             let l_erro = true
             exit foreach

          end if
       end if

       close  cbdbsr099018
       if r_bdbsr099.clsatdqtd is null then # a pedido do EDU 27/06/02.
          let ws.qtdatd = ws.qtdatd + 1
          continue foreach
       end if
       select count(*) into ws.qtd
            from tmp_bdbsr099
           where succod    = r_bdbsr099.succod
             and ramcod    = r_bdbsr099.ramcod
             and aplnumdig = r_bdbsr099.aplnumdig
       if ws.qtd > 0 then
          if ws.qtd = r_bdbsr099.clsatdqtd or # a pedido do EDU 27/06/02.
             ws.qtd > r_bdbsr099.clsatdqtd then  # or
           #(r_bdbsr099.clsatdqtd - ws.qtd) = 1 then

             output to report bdbsr099_rep(l_dataexec, l_dataproc,l_horaexec,
                                           r_bdbsr099.*)
             let ws.impr = ws.impr + 1
         #if ws.qtd = r_bdbsr099.clsatdqtd then # a pedido do EDU 27/06/02.
         #   output to report bdbsr099_rep(l_dataexec, l_dataproc,l_horaexec,
         #                                 r_bdbsr099.*)
         #   let ws.impr = ws.impr + 1
          else
             let ws.qtdatd1 = ws.qtdatd1 + 1
          end if
       end if
   end foreach

   if l_erro then
      exit program(1)
   end if

   display "======== PROCESSANDO O DIA ", l_dataproc
   display "*** TOTAL LIDOS................",ws.lidos
   display "*** TOTAL IMPRESSOS............",ws.impr
   display "********* TOTAL DESPREZADOS **************"
   display "    Qtd.atd ramo/clscod = 0....",ws.qtdatd
   display "    Atd < qtd.atd..............",ws.qtdatd1

   finish report bdbsr099_rep

   let l_email = 'Quantidade_Atend_para_RE '
   let l_retorno = ctx22g00_envia_email("BDBSR099"
                                       ,l_email
                                       ,name_file)
   if l_retorno <> 0 then
      if l_retorno <> 99 then
         display "Erro ao enviar email(ctx22g00)-",name_file
      else
         display "Nao ha email cadastrado para o modulo BDBSR099 "
      end if
   end if

  #let  l_email = "mailx -r 'ct24hs.email@portoseguro.com.br'",
   #               " -s 'Quantidade_Atend_para_RE '",
   #               " 'carlos.ruiz@portoseguro.com.br'",
   #               " < ",name_file
   #run l_email
   #display "email - ", l_email

   #let  l_email = "mailx -r 'ct24hs.email@portoseguro.com.br'",
   #               " -s 'Quantidade_Atend_para_RE '",
   #               " 'Ferreira_Ulisses/spaulo_psocorro_controles@u23'",        ## PSI 168890
   #               " < ",name_file
   #run l_email
   #display "email - ", l_email

#------------------ Evandro - 04/12/2003 - INICIO...
#                  # Em producao a rotina abaixo foi incluida por
#                  # D0000039-Henrique
#                  # Incluido atraves do DIFF


   #let  l_email = "mailx -r 'ct24hs.email@portoseguro.com.br'",
   #               " -s 'Quantidade_Atend_para_RE '",
   #               " 'Correia_Lucio/spaulo_psocorro_comercial@u23'",
   #               " < ",name_file
   #run l_email
   #display "email - ", l_email

   #              # Em producao a rotina acima foi incluida por
   #               # D0000039-Henrique
   #               # Incluido atraves do DIFF
#------------------- Evandro - 04/12/2003 - ...TERMINO


   #let  l_email = "uuencode ", name_file clipped, " ",
   #                            name_file clipped, ".xls | remsh U07 ",
   #               "mailx -r 'ct24h.email@portoseguro.com.br'",
   #               " -s 'Quantidade_Atend_para_RE '",
   #               "carlos.ruiz@portoseguro.com.br"
   #run l_email

  #let  l_email = "uuencode ", name_file clipped, " ",
  #                            name_file clipped, ".xls | remsh U07 ",
  #               "mailx -r 'ct24h.email@portoseguro.com.br'",
  #               " -s 'Quantidade_Atend_para_RE '",
  #               "Ferreira_Ulisses/spaulo_psocorro_controles@u23" ## PSI 168890
  #run l_email
  #display "email - ", l_email
end function

function bdbsr099_create_tmp()

  whenever error continue
  create temp table tmp_bdbsr099 ( nom        char(40),
                                   corsus     char(06),
                                   atdsrvorg  smallint,
                                   atdsrvnum  decimal(10,0),
                                   atdsrvano  decimal(2,0),
                                   funmat     decimal(6,0),
                                   atddat     date,
                                   atdhor     datetime hour to minute,
                                   funnom     char(20),
                                   succod     decimal(2,0),
                                   ramcod     decimal(4,0),
                                   aplnumdig  decimal(9,0),
                                   itmnumdig  decimal(7,0),
                                   socntzcod  decimal(2,0),
                                   socntzdes  char(30),
                                   viginc     date,
                                   vigfnl     date        ) with no log

   whenever error stop
        if sqlca.sqlcode = 0 then
           create unique index tmp_idx on tmp_bdbsr099
                                       (succod, ramcod, aplnumdig, atdsrvnum,
                                        atdsrvano)
        end if
        if sqlca.sqlcode <> 0 and sqlca.sqlcode <> -310 then
           whenever error continue
            delete from tmp_bdbsr099
           whenever error stop
            if sqlca.sqlcode <> 0 then
              display "Problema na criacao da tabela temporaria: ",
                        sqlca.sqlcode
               sleep 2
           end if
        end if

end function

report  bdbsr099_rep(l_dataexec, l_dataproc, l_horaexec, r_bdbsr099)

#--Definicao de Variaveis Locais
     define l_dataexec      date
     define l_dataproc      date
     define l_horaexec      datetime hour to second

  define r_bdbsr099  record
     succod        like datrservapol.succod,
     ramcod        like datrservapol.ramcod,
     rmemdlcod     like datrramcls.rmemdlcod,  #psi168890
     rmemdlnom     like gtakmodal.rmemdlnom,  #psi168890
     aplnumdig     like datrservapol.aplnumdig,
     nom           like datmservico.nom,
     corsus        like datmservico.corsus,
     cornom        like gcakcorr.cornom,
     dddcod        like gcakfilial.dddcod,
     teltxt        like gcakfilial.teltxt,
     factxt        like gcakfilial.factxt,
     pgrnum        dec (8,0)          ,
     vcldes        char(50),
     vclanomdl     like abbmveic.vclanomdl,
     vcllicnum     like abbmveic.vcllicnum,
     clscod        like abbmclaus.clscod,
     viginc        like abamapol.viginc,
     vigfnl        like abamapol.vigfnl,
     itmnumdig     like datrservapol.itmnumdig,
     clsatdqtd     like datrramcls.clsatdqtd
  end record

  define r_bdbsr09901  record
     atdsrvorg     like datmservico.atdsrvorg,
     atdsrvnum     like datmservico.atdsrvnum,
     atdsrvano     like datmservico.atdsrvano,
     funmat        like datmservico.funmat,
     funnom        like isskfunc.funnom,
     atddat        like datmservico.atddat,
     atdhor        like datmservico.atdhor,
     vclanomdl     like abbmveic.vclanomdl,
     vcllicnum     like abbmveic.vcllicnum,
     vcldes        char(50),
     socntzcod     like datksocntz.socntzcod,
     socntzdes     like datksocntz.socntzdes,
     socntzcod2    like datrsocntzsrvre.socntzcod,
     socntzdes2    like datksocntz.socntzdes,
     ntzatdqtd     like datrsocntzsrvre.ntzatdqtd,
     codigo        like datksocntz.socntzcod,
     descricao     like datksocntz.socntzdes,
     quantidade    integer,
     soma          integer
  end record

## PSI 168890 - Inicio

   define lr_relat     record
         ramnom       like gtakram.ramnom,
         ramgrpcod    like gtakram.ramgrpcod,
         rmemdlnom    like gtakmodal.rmemdlnom,
         clsdes       like aackcls.clsdes
  end record

## PSI 168890 - Final

  output
        report to name_file
        left   margin 0
        top    margin 0
        bottom margin 0
        page   length 66

     format

       page header
       if pageno = 1 then
           print "OUTPUT JOBNAME=RDBS09901 FORMNAME = BRANCO"
           print "HEADER PAGE"
           print "JOBNAME=RDBS09901 - Relatorio - LISTA DE ATENDIMENTO DO RE"
#####      print "$DJDE$ JDL=XJ0001, JDE=XD0001, ",
           print "$DJDE$ JDL=XJ0000, JDE=XD0021, ",
                 "COPIES=",ws_relviaqtd using "&&", ", DEPT='",ws_cctcod using "&&&", "',  END;"
           print ASCII(12);
       else
           print "$DJDE$ C LIXOLIXO , ;"
           print "$DJDE$ C LIXOLIXO , ;"
           print "$DJDE$ C LIXOLIXO , ;"
           print "$DJDE$ C LIXOLIXO ,END;"
           print ascii(12);
       end if

       print column 072, 'DBS099-01'
       print column 064, 'DATA : ', today
       print column 064, 'HORA : ', l_horaexec
       print column 001, "QUANTIDADES DE ATENDIMENTO PARA RE :", l_dataproc,
             column 064, "PAG. : ",
             column 078, pageno using '&&&'
       print column 001, " "
       print column 001, "----------------------------------------",
             column 041, "----------------------------------------"
       print column 001, "DOCUMENTO:", r_bdbsr099.succod using "&&", "/",
                                       r_bdbsr099.ramcod using "&&&&", "/",
                                       r_bdbsr099.aplnumdig using "&&&&&&&&&" ,
             column 030, "SEGURADO:", r_bdbsr099.nom
       print column 001, "CORRETOR.:",r_bdbsr099.corsus," - ",r_bdbsr099.cornom
       print column 001, "TELEFONE.:", "(",r_bdbsr099.dddcod using "&&&",")",
                                       r_bdbsr099.teltxt[1,30],
             column 047, "FAX:", r_bdbsr099.factxt[1,15],
             column 067, "PAGER:", r_bdbsr099.pgrnum
       print column 001, "VEICULO.:", r_bdbsr099.vcldes[1,40],
             column 052, "ANO:",r_bdbsr099.vclanomdl,
             column 061, "PLACA:", r_bdbsr099.vcllicnum
       print column 001, "CLAUSULA.:", r_bdbsr099.clscod
       print column 001, " "
       print column 001, "ATENDIMENTOS REALIZADOS NO PERIODO DA VIGENCIA: ",
                         r_bdbsr099.viginc, " A ", r_bdbsr099.vigfnl
       print column 004, "SERVICO ",
             column 018, "NATUREZA",
             column 056, "ATENDIMENTO"
       print column 001, "----------------",
             column 018, "------------------------",
             column 043, "--------------------------------------"

       on every row
       skip to top of page
       open  cbdbsr099024 using  r_bdbsr099.succod, r_bdbsr099.ramcod,
                                 r_bdbsr099.aplnumdig
       foreach cbdbsr099024 into r_bdbsr09901.atdsrvorg,r_bdbsr09901.atdsrvnum,
                                 r_bdbsr09901.atdsrvano,r_bdbsr09901.socntzcod,
                                 r_bdbsr09901.socntzdes,r_bdbsr09901.funmat,
                                 r_bdbsr09901.funnom,r_bdbsr09901.atddat,
                                 r_bdbsr09901.atdhor

           print column 001, r_bdbsr09901.atdsrvorg using "&&", "/",
                             r_bdbsr09901.atdsrvnum using "&&&&&&&&&&", "-",
                             r_bdbsr09901.atdsrvano using "&&",
                 column 018, r_bdbsr09901.socntzcod using "&&", "-",
                             r_bdbsr09901.socntzdes[1,20],
                 column 043, r_bdbsr09901.funmat, "-",
                             r_bdbsr09901.funnom[1,12], ' ',
                             r_bdbsr09901.atddat, ' ',
                             r_bdbsr09901.atdhor
       end foreach
       print column 001, " "
       print column 001, "RESUMO DOS ATENDIMENTOS:"
       print column 004, "NATUREZA",
             column 031, "QTD.ATEND."
       print column 004, "-----------------------------",
             column 031, "----------"

       let r_bdbsr09901.soma = 0
       let r_bdbsr09901.codigo    = null
       let r_bdbsr09901.descricao = null

       open    cbdbsr099025 using r_bdbsr099.succod, r_bdbsr099.ramcod,
                                  r_bdbsr099.aplnumdig
       foreach cbdbsr099025 into r_bdbsr09901.codigo, r_bdbsr09901.descricao

          let r_bdbsr09901.quantidade = null
          open cbdbsr099026 using r_bdbsr099.succod   , r_bdbsr099.ramcod,
                                  r_bdbsr099.aplnumdig,r_bdbsr09901.codigo
          fetch cbdbsr099026 into r_bdbsr09901.quantidade
          close cbdbsr099026

          let r_bdbsr09901.soma = r_bdbsr09901.soma + r_bdbsr09901.quantidade

          print column 004,r_bdbsr09901.codigo using "&&", "-",
                column 007,r_bdbsr09901.descricao[1,24],
                column 034,r_bdbsr09901.quantidade using "&&&"
       end foreach

       print column 034,"---"
       print column 001,"TOTAL DE ATENDIMENTOS",
             column 034,r_bdbsr09901.soma using "&&&"
       print column 001, " "

## PSI 168890 - Inicio

       initialize  lr_relat   to null

       open  cbdbsr099029 using r_bdbsr099.ramcod
       whenever error continue
       fetch cbdbsr099029 into  lr_relat.ramnom, lr_relat.ramgrpcod
       whenever error stop
       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display 'Erro SELECT gtakram ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
             display "bdbsr099_rep() / ",r_bdbsr099.ramcod
             exit program(1)
          end if
       end if

       if lr_relat.ramgrpcod = 1 then
          open  cbdbsr099030 using r_bdbsr099.ramcod, r_bdbsr099.clscod
          whenever error continue
          fetch cbdbsr099030 into  lr_relat.clsdes
          whenever error stop
          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode <> notfound then
                display 'Erro SELECT aackcls ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
                display "bdbsr099_rep() / ",r_bdbsr099.ramcod, " / ", r_bdbsr099.clscod
                exit program(1)
             end if
          end if
       end if

       print column 001, "RAMO.......: ", r_bdbsr099.ramcod, " - ", lr_relat.ramnom

       open  cbdbsr099027 using r_bdbsr099.ramcod,
                                r_bdbsr099.rmemdlcod
       whenever error continue
       fetch cbdbsr099027 into  lr_relat.rmemdlnom
       whenever error stop

       if sqlca.sqlcode <> 0 then
          if sqlca.sqlcode <> notfound then
             display 'Erro SELECT gtakram ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
             display "bdbsr099_rep() / ",r_bdbsr099.ramcod,r_bdbsr099.rmemdlcod
             exit program(1)
          end if
       end if

       if lr_relat.ramgrpcod <> 1 then
       #============= 18/03/2010 PSI 219444 - Beatriz Araujo
           display "r_bdbsr099.ramcod,   : ",r_bdbsr099.ramcod   
           display "r_bdbsr099.rmemdlcod,: ",r_bdbsr099.rmemdlcod
           display "r_bdbsr099.clscod)   : ",r_bdbsr099.clscod   
           
           call cts17m11_descricaoclaure(r_bdbsr099.ramcod,
                                         r_bdbsr099.rmemdlcod,
                                         r_bdbsr099.clscod)
                returning lr_relat.clsdes
                
          display " lr_relat.clsdes     : ",lr_relat.clsdes   
          display "----------------------------------------------------------"

         ###open  cbdbsr099031 using r_bdbsr099.ramcod, r_bdbsr099.clscod, r_bdbsr099.rmemdlcod
         ###                        ,r_bdbsr099.ramcod, r_bdbsr099.clscod, r_bdbsr099.rmemdlcod
         ###whenever error continue
         ###fetch cbdbsr099031 into  lr_relat.clsdes
         ###whenever error stop
         ###
         ###if sqlca.sqlcode <> 0 then
         ###   if sqlca.sqlcode <> notfound then
         ###      display 'Erro SELECT rgfkclaus2 ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
         ###      display "bdbsr099_rep() / ",r_bdbsr099.ramcod, " / ", r_bdbsr099.clscod,
         ###              " / ", r_bdbsr099.rmemdlcod
         ###      exit program(1)
         ###   end if
         ###end if
       ###### Fim do PSI
       end if

       print column 001, "MODALIDADE.: ", r_bdbsr099.rmemdlcod, " - ", lr_relat.rmemdlnom
       print column 001, "CLAUSULA...: ", r_bdbsr099.clscod, " - ", lr_relat.clsdes
       print column 001, "QTD. ATEND.: ", r_bdbsr099.clsatdqtd
       print column 004, "NATUREZA",
             column 035, "QTD.ATEND."
       print column 004, "-----------------------------",
             column 031, "---------------"

       let r_bdbsr09901.socntzcod2 = null
       let r_bdbsr09901.ntzatdqtd  = null

       open   cbdbsr099019 using r_bdbsr099.ramcod, r_bdbsr099.clscod,r_bdbsr099.rmemdlcod
       foreach cbdbsr099019 into r_bdbsr09901.socntzcod2, r_bdbsr09901.ntzatdqtd

           let r_bdbsr09901.socntzdes2 = null

           open  cbdbsr099017 using r_bdbsr09901.socntzcod2
           whenever error continue
           fetch cbdbsr099017 into  r_bdbsr09901.socntzdes2
           whenever error stop

           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode <> notfound then
                 display 'Erro SELECT datksocntz ', sqlca.sqlcode ,' ',sqlca.sqlerrd[2]
                 display "bdbsr099_rep() / ",r_bdbsr09901.socntzcod2
                 exit program(1)
              end if
           end if

           close cbdbsr099017

           print column 004,r_bdbsr09901.socntzcod2 using "&&", "-",
                 column 007,r_bdbsr09901.socntzdes2[1,29],
                 column 034,r_bdbsr09901.ntzatdqtd using "&&&"

       end foreach

       print column 001, " "

## PSI 168890 - Final

       initialize r_bdbsr099.*, r_bdbsr09901.* to null

end report
