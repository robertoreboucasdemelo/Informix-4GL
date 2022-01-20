#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema        : PORTO SOCORRO                                              #
# Modulo         : bdbsr011                                                   #
#                  Relatorio de Pagtos dos guinchos efetuados                 #
#                  ao prestador CAPEL(sinistro )                              #
# Analista Resp. : Wagner Agostinho                                           #
# AS             : 147273 - Osf 1759                                          #
#.............................................................................#
# Desenvolvimento: Fabrica de Software, Benilda JMonteiro                     #
# Liberacao      : <14/02/2002>                                               #
#.............................................................................#
#------------------- HISTORICO DA MANUTENCAO ---------------------------------#
#            *  *  *  A L T E R A C O E S  *  *  *                            #
#            -------------------------------------                            #
# PSI       Autor               Data           Alteracao        Liberacao     #
# ------    -----------------   --------       ----------       ----------    #
# Correio   Wagner              27/02/02       Modificacoes solicitadas por   #
#                                              Onilia.                        #
#-----------------------------------------------------------------------------#
#           FERNANDO - FSW      22/04/2003     RESOLUCAO 86                   #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 29/06/2004 Marcio, Meta      PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
# ---------- --------------------- ------ ------------------------------------#
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# 03/02/2016 ElianeK,Fornax     Retirada da var global g_ismqconn             #
###############################################################################

database porto

define m_lid       integer
      ,m_des       integer
      ,m_imp       integer
      ,m_grv       integer
      ,ws_pathrel  char (30)
      ,ws_flgcab   integer
      ,ws_run      char (400)

 define m_dados      record
       Aatdsrvnum    like datmservico.atdsrvnum
      ,Aatdsrvano    like datmservico.atdsrvano
      ,Aatdcstvlr    like datmservico.atdcstvlr
      ,Avcllicnum    like datmservico.vcllicnum
      ,Aatddat       like datmservico.atddat
      ,Asocvclcod    like datmservico.socvclcod
      ,Asrrcoddig    like datmservico.srrcoddig
      ,Avcldes       like datmservico.vcldes
      ,Acorsus       like datmservico.corsus
      ,Acornom       like datmservico.cornom
      ,Bsocopgnum    like dbsmopgitm.socopgnum
      ,Csocopgsitcod like dbsmopg.socopgsitcod
      ,Dsindat       like datmservicocmp.sindat
      ,Esuccod       like datrservapol.succod
      ,Eramcod       like datrservapol.ramcod
      ,Eaplnumdig    like datrservapol.aplnumdig
      ,Eitmnumdig    like datrservapol.itmnumdig
      ,Flclidttxt    like datmlcl.lclidttxt
      ,Gatdvclsgl    like datkveiculo.atdvclsgl
      ,Hsrrabvnom    like datksrr.srrabvnom
      ,Sramcod       like ssamsin.ramcod
      ,Ssinano       like ssamsin.sinano
      ,Ssinnum       like ssamsin.sinnum
 end record


 define m_datini    date
 define m_datfim    date

 define m_path      char(100)

main
   define m_hora     datetime year to second
   define m_data     date
   define m_ret      smallint

   let m_datini = null
   let m_datfim = null

   let m_datini = arg_val(1)
   let m_datfim = arg_val(2)

   let m_lid   =  0
   let m_des   =  0
   let m_imp   =  0
   let m_hora  =  null

    call fun_dba_abre_banco("CT24HS")

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr011.log"

    call startlog(m_path)

    let m_path = f_path("DBS","ARQUIVO")
    if m_path is null then
       let m_path = "."
    end if

    # PSI 185035 - Final

   let ws_pathrel = m_path clipped,"/QDBS01101.txt"

   set isolation to dirty read

   if  m_datini is null then
       let m_datini = "01/08/2001"
       let m_datfim = "31/01/2002"
   end if

   let m_hora = current
   display "Extracao  bdbsr011 : ", m_datini, " a ", m_datfim
   display "Inicio    bdbsr011 em...: ", m_hora

   start report  bdbsr011_rel to ws_pathrel

   call bdbsr011_prepares()

   call bdbsr011()

   finish report bdbsr011_rel

    let ws_run = "Relacao servicos guinchos Capel"
    let m_ret = ctx22g00_envia_email("BDBSR011",
                                      ws_run,
                                      ws_pathrel)
    if m_ret <> 0 then
       if m_ret <> 99 then
          display "Erro ao enviar email(ctx22g00) - ",ws_pathrel
       else
          display "Nao existe email cadastrado para este modulo - BDBSR011"
       end if
    end if

   #------------------------------------------------------------------
   # E-MAIL PORTO SOCORRO
   #------------------------------------------------------------------
   #let ws_run =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
   #              " -s 'Relacao servicos guinchos Capel' ",
   #              "agostinho_wagner/spaulo_info_sistemas@u55 < ",
   #              ws_pathrel clipped
   #run ws_run

   let m_hora = current
   let m_des = m_lid - m_imp

   display "    Total Lidos.......:", m_lid
   display "    Total Desprezados.:", m_des
   display "    Total Impresso....:", m_imp
   display "Fim do bdbsr011 em...: ", m_hora
   display "==============================================================="

end main

#----------------------------------------------------------------
function bdbsr011_prepares()
#----------------------------------------------------------------

 define l_sel   char(500)

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

   let l_sel = null

   let l_sel = "select B.socopgnum from dbsmopgitm B"
              ," where B.atdsrvnum  = ?  "
              ,"   and B.atdsrvano  = ?  "
   prepare pbdbsr011002 from l_sel
   declare cbdbsr011002 cursor for pbdbsr011002

   let l_sel = "select C.socopgsitcod from dbsmopg C"
              ," where C.socopgnum  = ?  "
   prepare pbdbsr011003 from l_sel
   declare cbdbsr011003 cursor for pbdbsr011003

   let l_sel = "select D.sindat  from datmservicocmp D"
              ," where D.atdsrvnum  = ? "
              ,"   and D.atdsrvano  = ? "
   prepare pbdbsr011004 from l_sel
   declare cbdbsr011004 cursor for pbdbsr011004


   let l_sel = "select E.succod, E.aplnumdig, E.ramcod, E.itmnumdig "
              ,"  from datrservapol E"
              ," where E.atdsrvnum  = ? "
              ,"   and E.atdsrvano  = ? "
   prepare pbdbsr011005 from l_sel
   declare cbdbsr011005 cursor for pbdbsr011005

   let l_sel = "select F.lclidttxt "
              ,"  from datmlcl F   "
              ," where F.atdsrvnum = ? "
              ,"   and F.atdsrvano = ? "
              ,"   and F.c24endtip = 2 "
   prepare pbdbsr011006 from l_sel
   declare cbdbsr011006 cursor for pbdbsr011006

 end function

function bdbsr011()

   let m_lid = 0
   let m_imp = 0

   declare cbdbsr011001 cursor with hold  for
      select A.atdsrvnum, A.atdsrvano, A.atdcstvlr, A.vcllicnum, A.atddat,
             A.socvclcod, A.srrcoddig, A.vcldes   , A.corsus    ,A.cornom
        from datmservico A
       where A.atddat between m_datini and m_datfim
         and A.atdsrvorg in (1,4)         # 1-socorro 4-rem.sinistro
         and A.asitipcod = 1              # Guincho
         and A.atdprscod = 6113
         and A.atdcstvlr is not null

   initialize  m_dados.*  to  null
   foreach cbdbsr011001 into m_dados.Aatdsrvnum ,m_dados.Aatdsrvano
                            ,m_dados.Aatdcstvlr ,m_dados.Avcllicnum
                            ,m_dados.Aatddat    ,m_dados.Asocvclcod
                            ,m_dados.Asrrcoddig ,m_dados.Avcldes
                            ,m_dados.Acorsus    ,m_dados.Acornom

      let m_lid = m_lid + 1

      let   m_dados.Bsocopgnum = null
      open  cbdbsr011002 using m_dados.Aatdsrvnum, m_dados.Aatdsrvano
      fetch cbdbsr011002 into  m_dados.Bsocopgnum
      if  status = notfound then
          close cbdbsr011002
          continue foreach
      end if
      close cbdbsr011002

      let   m_dados.Csocopgsitcod =  null
      open  cbdbsr011003 using m_dados.Bsocopgnum
      fetch cbdbsr011003 into  m_dados.Csocopgsitcod
      close cbdbsr011003
      if  m_dados.Csocopgsitcod <> 7 then
          continue foreach
      end if

      let   m_dados.Dsindat  =  null
      open  cbdbsr011004 using m_dados.Aatdsrvnum, m_dados.Aatdsrvano
      fetch cbdbsr011004 into  m_dados.Dsindat
      close cbdbsr011004

      let   m_dados.Esuccod =  null
      let   m_dados.Eramcod =  null
      let   m_dados.Eaplnumdig =  null
      let   m_dados.Eitmnumdig =  null
      open  cbdbsr011005 using m_dados.Aatdsrvnum, m_dados.Aatdsrvano
      fetch cbdbsr011005 into  m_dados.Esuccod,    m_dados.Eaplnumdig
                              ,m_dados.Eramcod,    m_dados.Eitmnumdig
      close cbdbsr011005


      if  m_dados.Esuccod    is null and
          m_dados.Eaplnumdig is null and
          m_dados.Eitmnumdig is null then
          continue foreach
      end if

      if  m_dados.Dsindat    is null then
          let  m_dados.Dsindat  = m_dados.Aatddat
      end if

      let  m_dados.Sramcod     =  null
      let  m_dados.Ssinano     =  null
      let  m_dados.Ssinnum     =  null
      call osauc040_sinistro(m_dados.Eramcod   , m_dados.Esuccod
                            ,m_dados.Eaplnumdig, m_dados.Eitmnumdig
                            ,m_dados.Dsindat   , m_dados.Aatddat,   "S")
           returning m_dados.Sramcod, m_dados.Ssinano, m_dados.Ssinnum

      if m_dados.Ssinano is null   and
         m_dados.Ssinnum is null   then
         continue foreach
      end if

      initialize  m_dados.Gatdvclsgl to null
      select atdvclsgl
        into m_dados.Gatdvclsgl
        from datkveiculo
       where socvclcod = m_dados.Asocvclcod

      initialize  m_dados.Hsrrabvnom to null
      select srrabvnom
        into m_dados.Hsrrabvnom
        from datksrr
       where srrcoddig = m_dados.Asrrcoddig

      initialize  m_dados.Flclidttxt to null
      open  cbdbsr011006 using m_dados.Aatdsrvnum, m_dados.Aatdsrvano
      fetch cbdbsr011006 into m_dados.Flclidttxt
      close cbdbsr011006

      let m_imp = m_imp + 1
      output to report bdbsr011_rel()

   end foreach
   close cbdbsr011001

end function
#----------------------------------------------------------------

#---------------------------------------------------------------------------
report bdbsr011_rel()
#---------------------------------------------------------------------------

 output
      left   margin  000
      right  margin  160
      top    margin  000
      bottom margin  000
      page   length  066

   format

      on every row
         if ws_flgcab = 0 then
            let ws_flgcab = 1
            print column 001, "Nro_Sinistro",      "|"
                            , "Dt_Ocorr.",         "|"
                            , "Nro_Laudo",         "|"
                            , "Guincho",           "|"
                            , "Motorista",         "|"
                            , "Corretor",          "|"
                            , "Veiculo_segurado",  "|"
                            , "Licenca",           "|"
                            , "Oficina_destino",   "|"
                            , "Valor_pago",        "|"
                            , ascii(13)
         end if

         print column 001, m_dados.Sramcod using "&&&&" ,         "/",
                           m_dados.Ssinano,                       "/",
                           m_dados.Ssinnum using "<<<<<<<<<&",    "|",
                           m_dados.Dsindat,                       "|",
                           m_dados.Aatdsrvnum using "#######",    "-",
                           m_dados.Aatdsrvano using "&&",         "|",
                           m_dados.Gatdvclsgl clipped,            "|",
                           m_dados.Hsrrabvnom clipped,            "|",
                           m_dados.Acorsus clipped,               "-",
                           m_dados.Acornom clipped,               "|",
                           m_dados.Avcldes clipped,               "|",
                           m_dados.Avcllicnum clipped,            "|",
                           m_dados.Flclidttxt clipped,            "|",
                           m_dados.Aatdcstvlr using "###,##&.&&", "|",
                           ascii(13)

end report   ###
