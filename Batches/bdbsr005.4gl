#############################################################################
# Nome do Modulo: bdbsr005                                         Marcelo  #
#                                                                  Gilberto #
# Relatorio regional de acionamentos do Porto Socorro              Mai/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/1998  PSI 6523-4   Gilberto     Nao contabilizar servicos atendidos #
#                                       como particular (srvprlflg = "S")   #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Wagner       Adaptacao leitura tabela de etapas  #
#                                       para verificacao do servico.        #
#---------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#############################################################################
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 26/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch  #
#                              OSF036870  do Porto Socorro.                 #
#...........................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

 database porto

 define sql_select     char(500)

 define param          record
    relpamseq          like dgbmparam.relpamseq ,
    relsgl             like dgbmparam.relsgl    ,
    soldat             date                     ,
    solhor             char (08)                ,
    funmat             like isskfunc.funmat     ,
    funnom             like isskfunc.funnom     ,
    incdat             date                     ,
    fnldat             date                     ,
    ufdcod             like glakest.ufdcod
 end record

 define g_traco105     char(105)
 define g_traco132     char(132)
 define g_traco144     char(144)

 define ws_dirfisnom   like ibpkdirlog.dirfisnom
 define ws_pathrel01   char (60)
 define ws_pathrel02   char (60)

 define ws_cctcod01    like igbrrelcct.cctcod
 define ws_relviaqtd01 like igbrrelcct.relviaqtd
 define ws_cctcod02    like igbrrelcct.cctcod
 define ws_relviaqtd02 like igbrrelcct.relviaqtd

 define m_path         char(100)

 main

    call fun_dba_abre_banco("CT24HS") 

    # PSI 185035 - Inicio
    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr005.log"

    call startlog(m_path)
    # PSI 185035 - Final    

    set isolation to dirty read

    #---------------------------------------------------------------
    # Inicializacao das variaveis
    #---------------------------------------------------------------
    let g_traco105 = "----------------------------------------------------------------------------------------------------------"
    let g_traco132 = "------------------------------------------------------------------------------------------------------------------------------------"
    let g_traco144 = "-------------------------------------------------------------------------------------------------------------------------------------------------"

    #---------------------------------------------------------------
    # Criacao do banco WORK
    #---------------------------------------------------------------
    close database
    database work

    call DB_drop()

    call DB_create()

    close database
    call fun_dba_abre_banco("CT24HS") 

    call bdbsr005_init()

 end main


#---------------------------------------------------------------
 function bdbsr005_init()
#---------------------------------------------------------------

 define ws           record
    relpamtxt        like dgbmparam.relpamtxt ,
    solicit          smallint
 end record

 define arr_aux      smallint


 initialize param.*  to null
 initialize ws.*     to null

 #---------------------------------------------------------------
 # Verificacao da existencia de solicitacoes
 #---------------------------------------------------------------
 let ws.solicit = 0

 select count(*)
   into ws.solicit
   from dgbmparam
  where relsgl = 'RDBS005' # PSI 185035

 if ws.solicit = 0 then
    display "                      *** NAO HOUVE NENHUMA SOLICITACAO! ***"
    exit program
 end if

 let sql_select = "select relpamtxt             ",
                  "  from dgbmparam             ",
                  " where relsgl    = 'RDBS005' ", # PSI 185035
                  "   and relpamseq = ?         ",
                  "   and relpamtip = 2         "

 prepare sel_dgbmparam from sql_select
 declare c_dgbmparam cursor for sel_dgbmparam

 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DBS", "RELATO")
      returning ws_dirfisnom
      
 if ws_dirfisnom is null then
    let ws_dirfisnom = "."
 end if

 #---------------------------------------------------------------
 # Define numero de vias e account dos relatorios
 #---------------------------------------------------------------
 call fgerc010("RDBS00501")    # PSI 185035
      returning  ws_cctcod01,
		 ws_relviaqtd01

 call fgerc010("RDBS00502")    # PSI 185035
      returning  ws_cctcod02,
		 ws_relviaqtd02

 #---------------------------------------------------------------
 # Obtencao dos parametros
 #---------------------------------------------------------------
 declare c_param cursor with hold for
    select relsgl, relpamseq, relpamtxt
      from dgbmparam
     where relsgl    = 'RDBS005' # PSI 185035
       and relpamtip = 1

 foreach c_param into param.relsgl ,
                      param.relpamseq,
                      ws.relpamtxt

    #---------------------------------------------------------------
    # Definicao do nome do relatorio
    #---------------------------------------------------------------
    let ws_pathrel01 = ws_dirfisnom clipped, "/RDBS005" clipped,
                       param.relpamseq  using "&&"
    let ws_pathrel02 = ws_dirfisnom clipped, "/RDBS005" clipped,
                       param.relpamseq + 50  using "&&"

    let param.soldat = ws.relpamtxt[01,10]
    let param.solhor = ws.relpamtxt[11,18]
    let param.funmat = ws.relpamtxt[19,26]

    select funnom into param.funnom
      from isskfunc
     where funmat = param.funmat

    initialize ws.relpamtxt to null

    open  c_dgbmparam using param.relpamseq
    fetch c_dgbmparam into  ws.relpamtxt

    let param.incdat = ws.relpamtxt[01,10]
    let param.fnldat = ws.relpamtxt[12,21]
    let param.ufdcod = ws.relpamtxt[23,24]

    close c_dgbmparam
    call bdbsr005_main()

 end foreach

end function  ###  bdbsr005_init


#---------------------------------------------------------------
 function bdbsr005_main()
#---------------------------------------------------------------

 define d_bdbsr005   record
    pstcoddig        like dpaksocor.pstcoddig     ,
    nomgrr           like dpaksocor.nomgrr        ,
    endcid           like dpaksocor.endcid        ,
    endufd           like dpaksocor.endufd        ,
    endcep           like dpaksocor.endcep        ,
    atdregcod        like datkfxareg.atdregcod
 end record

 define servico      record
    atdprscod        like datmservico.atdprscod ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atdcstvlr        like datmservico.atdcstvlr ,
    atdfnlflg        like datmservico.atdfnlflg
 end record

 define ws           record
    ufdcod           like datmlcl.ufdcod,
    srvprlflg        like datmservico.srvprlflg
 end record

 initialize ws.*  to null

 declare c_prest cursor with hold for
    select pstcoddig,
           nomgrr,
           endcid,
           endufd,
           endcep
      from dpaksocor
     where pstcoddig  >  0
       and prssitcod  =  "A"

 foreach c_prest into d_bdbsr005.pstcoddig ,
                      d_bdbsr005.nomgrr    ,
                      d_bdbsr005.endcid    ,
                      d_bdbsr005.endufd    ,
                      d_bdbsr005.endcep

    if param.ufdcod is not null   and
       param.ufdcod <>     "  "   then
       if d_bdbsr005.endufd <> param.ufdcod  then
          continue foreach
       end if
    end if

    declare c_regiao cursor for
       select datkfxareg.atdregcod
         from datkfxareg
        where cepinc <= d_bdbsr005.endcep   and
              cepfnl >= d_bdbsr005.endcep

    open  c_regiao
    fetch c_regiao  into d_bdbsr005.atdregcod

       if d_bdbsr005.atdregcod is null then
          let d_bdbsr005.atdregcod = 0
       end if

       call DB_grava(d_bdbsr005.*)

       initialize d_bdbsr005.atdregcod    to null

    close c_regiao

 end foreach

 declare c_servico cursor for
    select datmservico.atdprscod,
           datmservico.atdsrvorg,
           datmservico.atdcstvlr,
           datmservico.atdfnlflg,
           datmlcl.ufdcod,
           datmservico.srvprlflg
      from datmservico, datmlcl
     where datmservico.atddat between param.incdat and param.fnldat
       and datmservico.atdsrvnum = datmlcl.atdsrvnum
       and datmservico.atdsrvano = datmlcl.atdsrvano
       and datmlcl.c24endtip     = 1

 start report  rep_prssrv  to  ws_pathrel01
 start report  rep_totais  to  ws_pathrel01
 start report  rep_naocad  to  ws_pathrel02

 foreach c_servico into  servico.atdprscod,
                         servico.atdsrvorg,
                         servico.atdcstvlr,
                         servico.atdfnlflg,
                         ws.ufdcod,
                         ws.srvprlflg

     if servico.atdprscod  is null or    # Nao contem codigo de prestador.
        servico.atdprscod  =  0    or    # Codigo de Prestador e' zero.
        servico.atdprscod  = "2"   or    # Servico Cancelado
        servico.atdsrvorg  = 10    or    # Vistoria Previa Domiciliar
        servico.atdsrvorg  = 11    or    # Aviso Furto/Roubo
        servico.atdsrvorg  = 12    or    # Servico de Apoio
        servico.atdsrvorg  =  8    then  # Reserva Carro Extra
        continue foreach
     end if

 #   if ( servico.atdfnlflg = "E" or servico.atdfnlflg = "L" ) and
 #        servico.atdprscod is null then
 #      continue foreach
 #   end if
     if servico.atdfnlflg = "S"   and    # todos servicos finalizados com
        servico.atdprscod is null then   # cod.prestador ok.
        continue foreach
     end if

     if ws.srvprlflg = "S"  then
        continue foreach
     end if

     if param.ufdcod is not null   and
        param.ufdcod <>     "  "   then
        if ws.ufdcod <> param.ufdcod  then
           continue foreach
        end if
     end if

     output to report rep_prssrv(servico.*)

 end foreach

 finish report  rep_prssrv
 finish report  rep_totais
 finish report  rep_naocad

#---------------------------------------------------------------
# Deleta solicitacao atendida
#---------------------------------------------------------------

 delete from dgbmparam
  where relsgl    = "RDBS005" # PSI 185035
    and relpamseq = param.relpamseq

end function   ###  bdbsr005_main


#---------------------------------------------------------------
 report rep_prssrv(par_bdbsr005)
#---------------------------------------------------------------

 define par_bdbsr005 record
    atdprscod        like datmservico.atdprscod ,
    atdsrvorg        like datmservico.atdsrvorg ,
    atdcstvlr        like datmservico.atdcstvlr ,
    atdfnlflg        like datmservico.atdfnlflg
 end record

 define r_bdbsr005   record
    pstcoddig        like dpaksocor.pstcoddig     ,
    nomgrr           like dpaksocor.nomgrr        ,
    endcid           like dpaksocor.endcid        ,
    endufd           like dpaksocor.endufd        ,
    endcep           like dpaksocor.endcep        ,
    atdregcod        like datkfxareg.atdregcod
 end record

 define contab       record
    atdsrvqtd        dec (06,0) ,
    pgosrvqtd        dec (06,0) ,
    totpgovlr        dec (11,2) ,
    minpgovlr        dec (11,2) ,
    maxpgovlr        dec (11,2)
 end record


 output
      left   margin  000
      right  margin  105
      top    margin  000
      bottom margin  000
      page   length  082

 order by  par_bdbsr005.atdprscod

 format

      #---------------------------------------------------------------
      # Localiza prestador na tabela WORK
      #---------------------------------------------------------------
      before group of par_bdbsr005.atdprscod

         let r_bdbsr005.nomgrr = "NAO CADASTRADO!"

         initialize r_bdbsr005.endcid       ,
                    r_bdbsr005.endufd       ,
                    r_bdbsr005.endcep to null

         let r_bdbsr005.atdregcod = 0
         let contab.atdsrvqtd     = 0
         let contab.pgosrvqtd     = 0
         let contab.totpgovlr     = 0
         let contab.maxpgovlr     = 0

         select nomgrr       ,
                endcid       ,
                endufd       ,
                endcep       ,
                atdregcod    ,
                atdsrvqtd    ,
                pgosrvqtd    ,
                totpgovlr    ,
                minpgovlr    ,
                maxpgovlr
           into r_bdbsr005.nomgrr       ,
                r_bdbsr005.endcid       ,
                r_bdbsr005.endufd       ,
                r_bdbsr005.endcep       ,
                r_bdbsr005.atdregcod    ,
                contab.atdsrvqtd ,
                contab.pgosrvqtd ,
                contab.totpgovlr ,
                contab.minpgovlr ,
                contab.maxpgovlr
           from work:datmprsreg
          where relpamseq = param.relpamseq  and
                pstcoddig = par_bdbsr005.atdprscod

         if sqlca.sqlcode <> 0 then
            display "Erro (",sqlca.sqlcode using "<<<<<<<&",") na localizacao do prestador ", par_bdbsr005.atdprscod," na tabela WORK!"
         end if

         let r_bdbsr005.pstcoddig = par_bdbsr005.atdprscod

      #---------------------------------------------------------------
      # Quebra de prestador - atualiza tabela WORK
      #---------------------------------------------------------------
      after  group of par_bdbsr005.atdprscod

         update work:datmprsreg set ( atdsrvqtd ,
                                      pgosrvqtd ,
                                      totpgovlr ,
                                      minpgovlr ,
                                      maxpgovlr )
                                  = ( contab.*  )
          where relpamseq = param.relpamseq   and
                pstcoddig = par_bdbsr005.atdprscod

         if sqlca.sqlcode <> 0 then
            display "Erro (", sqlca.sqlcode using "<<<<<<<&", ") na contabilizacao do prestador ", par_bdbsr005.atdprscod
         end if

      #---------------------------------------------------------------
      # Contabilizacao dos valores da tabela WORK
      #---------------------------------------------------------------
      on every row
         let contab.atdsrvqtd = contab.atdsrvqtd + 1

         if par_bdbsr005.atdcstvlr is not null then
            let contab.pgosrvqtd = contab.pgosrvqtd + 1
            let contab.totpgovlr = contab.totpgovlr + par_bdbsr005.atdcstvlr

            if par_bdbsr005.atdcstvlr > contab.maxpgovlr then
               let contab.maxpgovlr = par_bdbsr005.atdcstvlr
            end if
            if par_bdbsr005.atdcstvlr < contab.minpgovlr or
               contab.minpgovlr is null                  then
               let contab.minpgovlr = par_bdbsr005.atdcstvlr
            end if
         end if

      on last row

         declare c_work cursor with hold for
             select pstcoddig    ,
                    nomgrr       ,
                    endcid       ,
                    endufd       ,
                    endcep       ,
                    atdregcod    ,
                    atdsrvqtd    ,
                    pgosrvqtd    ,
                    totpgovlr    ,
                    minpgovlr    ,
                    maxpgovlr
               from work:datmprsreg
              where relpamseq = param.relpamseq

         foreach c_work into r_bdbsr005.pstcoddig    ,
                             r_bdbsr005.nomgrr       ,
                             r_bdbsr005.endcid       ,
                             r_bdbsr005.endufd       ,
                             r_bdbsr005.endcep       ,
                             r_bdbsr005.atdregcod    ,
                             contab.atdsrvqtd ,
                             contab.pgosrvqtd ,
                             contab.totpgovlr ,
                             contab.minpgovlr ,
                             contab.maxpgovlr
             output to report rep_totais( r_bdbsr005.*, contab.* )
         end foreach

end report  ###  rep_prssrv


#---------------------------------------------------------------
 report rep_totais(r_bdbsr005)
#---------------------------------------------------------------

 define r_bdbsr005   record
    pstcoddig        like dpaksocor.pstcoddig     ,
    nomgrr           like dpaksocor.nomgrr        ,
    endcid           like dpaksocor.endcid        ,
    endufd           like dpaksocor.endufd        ,
    endcep           like dpaksocor.endcep        ,
    atdregcod        like datkfxareg.atdregcod    ,
    atdsrvqtd        dec (06,0) ,
    pgosrvqtd        dec (06,0) ,
    totpgovlr        dec (11,2) ,
    minpgovlr        dec (11,2) ,
    maxpgovlr        dec (11,2)
 end record

 define total_cid    record
    atdsrvqtd        dec (06,0) ,
    pgosrvqtd        dec (06,0) ,
    totpgovlr        dec (11,2) ,
    medpgovlr        dec (11,2) ,
    minpgovlr        dec (11,2) ,
    maxpgovlr        dec (11,2)
 end record

 define total_reg    record
    atdsrvqtd        dec (06,0) ,
    pgosrvqtd        dec (06,0) ,
    totpgovlr        dec (11,2) ,
    medpgovlr        dec (11,2) ,
    minpgovlr        dec (11,2) ,
    maxpgovlr        dec (11,2)
 end record

 define total_grl    record
    atdsrvqtd        dec (06,0) ,
    pgosrvqtd        dec (06,0) ,
    totpgovlr        dec (11,2) ,
    medpgovlr        dec (11,2) ,
    minpgovlr        dec (11,2) ,
    maxpgovlr        dec (11,2)
 end record

 define a_regiao     array[100] of record
    atdregcod        like datkatdreg.atdregcod ,
    atdregdes        char(040)                 ,
    atdsrvqtd        dec (06,0)                ,
    medpgovlr        dec (11,2)                ,
    totpgovlr        dec (11,2)                ,
    regprsqtd        dec (05,0)
 end record

 define i            smallint

 define ws           record
    prcvlr           dec (04,2),
    medvlr           dec (13,2),
    atdregdes       like datkatdreg.atdregdes
 end record


   output
      left   margin  000
      right  margin  105
      top    margin  000
      bottom margin  000
      page   length  077

   order by  r_bdbsr005.atdregcod     asc ,
             r_bdbsr005.endcid        asc ,
             r_bdbsr005.endufd        asc ,
             r_bdbsr005.atdsrvqtd     desc,
             r_bdbsr005.pstcoddig     asc

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS00501 FORMNAME=BRANCO" # PSI 185035
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RELATORIO REGIONAL DE ACIONAMENTOS DO PORTO SOCORRO"

              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd01 using "&&", ", DEPT='", ws_cctcod01 using "&&&", "', END;"

              skip 5 lines
              print column 025, "_______________________________________________________________"
              print column 025, " SOLICITANTE  : ", param.funmat,
                                             " - ", param.funnom
              print column 025, " SOLICITADO EM: ", param.soldat,
                                            " AS ", param.solhor
              skip 1 line
              print column 025, " RELACAO DE ACIONAMENTOS NO PERIODO DE ",
                                param.incdat, " A ", param.fnldat
              print column 025, "_______________________________________________________________"
              print ascii(12)

              let total_grl.atdsrvqtd = 0
              let total_grl.pgosrvqtd = 0
              let total_grl.totpgovlr = 0
              let total_grl.medpgovlr = 0
              let total_grl.maxpgovlr = 0
              initialize total_grl.minpgovlr to null
              initialize a_regiao to null
              let i = 0
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 073, "RDBS005-01", # PSI 185035
                 column 087, "PAGINA : "  , pageno using "##,###,#&&"
           print column 004, "RELACAO REGIONAL DE ACIONAMENTOS NO PERIODO DE ", param.incdat, " A ", param.fnldat,
                 column 087, "DATA   : "  , today
           print column 087, "HORA   :   ", time
           skip 2 lines

      before group of r_bdbsr005.atdregcod

           if r_bdbsr005.atdregcod <> 0 then
              let total_reg.atdsrvqtd = 0
              let total_reg.pgosrvqtd = 0
              let total_reg.totpgovlr = 0
              let total_reg.medpgovlr = 0
              let total_reg.maxpgovlr = 0
              initialize total_reg.minpgovlr to null

              skip to top of page

              select atdregdes into ws.atdregdes
                from datkatdreg
               where atdregcod = r_bdbsr005.atdregcod

              let i = i + 1
              let a_regiao[i].atdregcod = r_bdbsr005.atdregcod
              let a_regiao[i].atdregdes = ws.atdregdes
              let a_regiao[i].regprsqtd = 0

              print column 001, "REGIAO: ", r_bdbsr005.atdregcod using "&&&",
                                     " - ", ws.atdregdes
              print column 001, g_traco105
              skip 1 line
           end if

      after  group of r_bdbsr005.atdregcod

           if r_bdbsr005.atdregcod <> 0 then
              if total_reg.pgosrvqtd = 0  then
                 let total_reg.medpgovlr = 0
              else
                 let total_reg.medpgovlr = total_reg.totpgovlr/total_reg.pgosrvqtd
              end if

              let total_grl.atdsrvqtd = total_grl.atdsrvqtd + total_reg.atdsrvqtd
              let total_grl.pgosrvqtd = total_grl.pgosrvqtd + total_reg.pgosrvqtd
              let total_grl.totpgovlr = total_grl.totpgovlr + total_reg.totpgovlr

              if total_grl.minpgovlr is null then
                 let total_grl.minpgovlr = total_reg.minpgovlr
              else
                 if total_reg.minpgovlr < total_grl.minpgovlr then
                    let total_grl.minpgovlr = total_reg.minpgovlr
                 end if
              end if

              if total_reg.maxpgovlr > total_grl.maxpgovlr then
                 let total_grl.maxpgovlr = total_reg.maxpgovlr
              end if

              if total_reg.minpgovlr is null then
                 let total_reg.minpgovlr = 0
              end if

              skip 1 line
              print column 001, g_traco105
              print column 009, "TOTAL DA REGIAO " ,
                    column 039, total_reg.atdsrvqtd    using "#####&"        ,
                    column 047, total_reg.totpgovlr    using "##,###,##&.&&" ,
                    column 062, total_reg.medpgovlr    using "##,###,##&.&&" ,
                    column 077, total_reg.minpgovlr    using "##,###,##&.&&" ,
                    column 092, total_reg.maxpgovlr    using "##,###,##&.&&"

              let a_regiao[i].atdsrvqtd = total_reg.atdsrvqtd
              let a_regiao[i].medpgovlr = total_reg.medpgovlr
              let a_regiao[i].totpgovlr = total_reg.totpgovlr
           end if

      before group of r_bdbsr005.endcid

           if r_bdbsr005.atdregcod <> 0 then
              let total_cid.atdsrvqtd = 0
              let total_cid.pgosrvqtd = 0
              let total_cid.totpgovlr = 0
              let total_cid.medpgovlr = 0
              let total_cid.maxpgovlr = 0
              initialize total_cid.minpgovlr to null

              skip 1 line
              need 5 lines
              print column 001, "CIDADE: ", r_bdbsr005.endcid clipped, " - ",
                                            r_bdbsr005.endufd
              skip 1 line
              print column 009, "CODIGO"      ,
                    column 017, "PRESTADOR"   ,
                    column 039, "QUANT."      ,
                    column 049, "VALOR TOTAL" ,
                    column 064, "VALOR MEDIO" ,
                    column 079, "MENOR VALOR" ,
                    column 094, "MAIOR VALOR"
              skip 1 line
           end if

      after  group of r_bdbsr005.endcid

           if r_bdbsr005.atdregcod <> 0 then
              if total_cid.pgosrvqtd = 0  then
                 let total_cid.medpgovlr = 0
              else
                 let total_cid.medpgovlr = total_cid.totpgovlr/total_cid.pgosrvqtd
              end if

              let total_reg.atdsrvqtd = total_reg.atdsrvqtd + total_cid.atdsrvqtd
              let total_reg.pgosrvqtd = total_reg.pgosrvqtd + total_cid.pgosrvqtd
              let total_reg.totpgovlr = total_reg.totpgovlr + total_cid.totpgovlr

              if total_reg.minpgovlr is null then
                 let total_reg.minpgovlr = total_cid.minpgovlr
              else
                 if total_cid.minpgovlr < total_reg.minpgovlr then
                    let total_reg.minpgovlr = total_cid.minpgovlr
                 end if
              end if

              if total_cid.maxpgovlr > total_reg.maxpgovlr then
                 let total_reg.maxpgovlr = total_cid.maxpgovlr
              end if

              if total_cid.minpgovlr is null then
                 let total_cid.minpgovlr = 0
              end if

              skip 1 line
              print column 001, g_traco105
              print column 009, "TOTAL DA CIDADE "                           ,
                    column 039, total_cid.atdsrvqtd    using "#####&"        ,
                    column 047, total_cid.totpgovlr    using "##,###,##&.&&" ,
                    column 062, total_cid.medpgovlr    using "##,###,##&.&&" ,
                    column 077, total_cid.minpgovlr    using "##,###,##&.&&" ,
                    column 092, total_cid.maxpgovlr    using "##,###,##&.&&"
           end if

      on every row

           if r_bdbsr005.atdregcod = 0 then
              output to report rep_naocad( r_bdbsr005.* )
           else
              if r_bdbsr005.pgosrvqtd = 0 then
                 let ws.medvlr  =  0
              else
                 let ws.medvlr  =  r_bdbsr005.totpgovlr / r_bdbsr005.pgosrvqtd
              end if

              let total_cid.atdsrvqtd = total_cid.atdsrvqtd + r_bdbsr005.atdsrvqtd
              let total_cid.pgosrvqtd = total_cid.pgosrvqtd + r_bdbsr005.pgosrvqtd
              let total_cid.totpgovlr = total_cid.totpgovlr + r_bdbsr005.totpgovlr

              if total_cid.minpgovlr is null then
                 let total_cid.minpgovlr = r_bdbsr005.minpgovlr
              else
                 if r_bdbsr005.minpgovlr < total_cid.minpgovlr then
                    let total_cid.minpgovlr = r_bdbsr005.minpgovlr
                 end if
              end if

              if r_bdbsr005.maxpgovlr > total_cid.maxpgovlr then
                 let total_cid.maxpgovlr = r_bdbsr005.maxpgovlr
              end if

              if r_bdbsr005.minpgovlr is null then
                 let r_bdbsr005.minpgovlr  =  0
              end if

              print column 009, r_bdbsr005.pstcoddig   using "&&&&&&"        ,
                    column 017, r_bdbsr005.nomgrr                            ,
                    column 039, r_bdbsr005.atdsrvqtd   using "#####&"        ,
                    column 047, r_bdbsr005.totpgovlr   using "##,###,##&.&&" ,
                    column 062, ws.medvlr              using "##,###,##&.&&" ,
                    column 077, r_bdbsr005.minpgovlr   using "##,###,##&.&&" ,
                    column 092, r_bdbsr005.maxpgovlr   using "##,###,##&.&&"

              let a_regiao[i].regprsqtd = a_regiao[i].regprsqtd + 1
           end if

      on last row
           skip to top of page
           let total_grl.medpgovlr = total_grl.totpgovlr/total_grl.pgosrvqtd
           print column 001, "COD."       ,
                 column 007, "REGIAO"     ,
                 column 050, "PREST."     ,
                 column 058, "SERVICOS"   ,
                 column 079, "CUSTO MEDIO",
                 column 095, "CUSTO TOTAL"
           print column 001, g_traco105
           for i = 1 to 100
               if a_regiao[i].atdregdes is null then
                  exit for
               end if
               let ws.prcvlr = 0
               let ws.prcvlr = a_regiao[i].atdsrvqtd / total_grl.atdsrvqtd * 100
               print column 001, a_regiao[i].atdregcod using "&&&"            ,
                     column 007, a_regiao[i].atdregdes                        ,
                     column 051, a_regiao[i].regprsqtd using "####&"          ,
                     column 059, a_regiao[i].atdsrvqtd using "###,##&"        ,
                                " (", ws.prcvlr        using "#&.&&"   , "%)" ,
                     column 077, a_regiao[i].medpgovlr using "##,###,##&.&&"  ,
                     column 093, a_regiao[i].totpgovlr using "##,###,##&.&&"
           end for
           print column 001, g_traco105
           print column 026, "TOTAL GERAL",
                 column 059, total_grl.atdsrvqtd using "###,##&"       ,
                 column 077, total_grl.medpgovlr using "##,###,##&.&&" ,
                 column 093, total_grl.totpgovlr using "##,###,##&.&&"

           print "$FIMREL$"

end report  ###  rep_totais


#---------------------------------------------------------------------------
 report rep_naocad(r_bdbsr005)
#---------------------------------------------------------------------------

 define r_bdbsr005   record
    pstcoddig        like dpaksocor.pstcoddig     ,
    nomgrr           like dpaksocor.nomgrr        ,
    endcid           char (035)                   ,
    endufd           like dpaksocor.endufd        ,
    endcep           like dpaksocor.endcep        ,
    atdregcod        like datkfxareg.atdregcod    ,
    atdsrvqtd        dec (06,0) ,
    pgosrvqtd        dec (06,0) ,
    totpgovlr        dec (11,2) ,
    minpgovlr        dec (11,2) ,
    maxpgovlr        dec (11,2)
 end record

 define ws           record
    qtd              dec (05,0),
    medvlr           dec (11,2)
 end record

   output
      left   margin  000
      right  margin  144
      top    margin  000
      bottom margin  000
      page   length  066

   order by  r_bdbsr005.endufd,
             r_bdbsr005.endcid

   format
      page header
           if pageno  =  1   then
              print "OUTPUT JOBNAME=DBS00502 FORMNAME=BRANCO"  # PSI 185035
              print "HEADER PAGE"
              print "       JOBNAME= CT24HS - RELATORIO DE PRESTADORES SEM FAIXA DEFINIDA"
              print "$DJDE$ JDL=XJ6530, JDE=XD6531, FORMS=XF6530, COPIES=",ws_relviaqtd02 using "&&", ", DEPT='", ws_cctcod02 using "&&&", "', END;"

              print ascii(12)
              let ws.qtd = 0
           else
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, ;"
              print "$DJDE$ C LIXOLIXO, END ;"
              print ascii(12)
           end if

           print column 112, "RDBS005-02",   # PSI 185035
                 column 126, "PAGINA : "  , pageno using "##,###,#&&"
           print column 042, "RELACAO DE PRESTADORES SEM FAIXA DEFINIDA" ,
                 column 126, "DATA   : "  , today
           print column 126, "HORA   :   ", time
           skip 2 lines
           print column 001, g_traco144
           print column 001, "CODIGO"      ,
                 column 009, "PRESTADOR"   ,
                 column 031, "CIDADE"      ,
                 column 068, "UF"          ,
                 column 072, "CEP"         ,
                 column 079, "QUANT."      ,
                 column 089, "VALOR TOTAL" ,
                 column 104, "VALOR MEDIO" ,
                 column 118, "MENOR VALOR" ,
                 column 133, "MAIOR VALOR"
           print column 001, g_traco144
           skip 1 line

      on every row
           let ws.qtd = ws.qtd + 1

           if r_bdbsr005.pgosrvqtd = 0 then
              let ws.medvlr  =  0
           else
              let ws.medvlr  =  r_bdbsr005.totpgovlr / r_bdbsr005.pgosrvqtd
           end if

           if r_bdbsr005.minpgovlr is null then
              let r_bdbsr005.minpgovlr = 0
           end if

           print column 001, r_bdbsr005.pstcoddig   using "&&&&&&"        ,
                 column 009, r_bdbsr005.nomgrr                            ,
                 column 031, r_bdbsr005.endcid                            ,
                 column 068, r_bdbsr005.endufd                            ,
                 column 072, r_bdbsr005.endcep                            ,
                 column 079, r_bdbsr005.atdsrvqtd   using "#####&"        ,
                 column 087, r_bdbsr005.totpgovlr   using "##,###,##&.&&" ,
                 column 102, ws.medvlr              using "##,###,##&.&&" ,
                 column 116, r_bdbsr005.minpgovlr   using "##,###,##&.&&" ,
                 column 131, r_bdbsr005.maxpgovlr   using "##,###,##&.&&"

      on last row
           print column 001, g_traco144
           print column 001, "TOTAL DE PRESTADORES SEM FAIXA DEFINIDA: " ,
                             ws.qtd using "<<,<<&"
           print "$FIMREL$"

end report  ###  rep_naocad

#---------------------------------------------------------------
 function DB_create()
#---------------------------------------------------------------

 whenever error continue

 create table DATMPRSREG
        ( relpamseq    dec  (05,0) ,
          pstcoddig    dec  (06,0) ,
          nomgrr       char (0020) ,
          endcid       char (0045) ,
          endufd       char (0002) ,
          endcep       char (0005) ,
          atdregcod    dec  (05,0) ,
          atdsrvqtd    dec  (06,0) ,
          pgosrvqtd    dec  (06,0) ,
          totpgovlr    dec  (11,2) ,
          minpgovlr    dec  (11,2) ,
          maxpgovlr    dec  (11,2) )

 whenever error stop

 if sqlca.sqlcode <> 0  then
    display "*** ERRO (", sqlca.sqlcode using "<<<<<<<&", ") na criacao da tabela! ***"
    exit program (1)
 end if

 whenever error continue

 create unique index NDX_PSTCODDIG
     on datmprsreg ( relpamseq, pstcoddig )

 whenever error stop

 if sqlca.sqlcode <> 0 then
    display "*** ERRO (", sqlca.sqlcode using "<<<<<<<&", ") na criacao do indice! ***"
    exit program (1)
 end if

end function  ###  DB_create

#---------------------------------------------------------------
 function DB_drop()
#---------------------------------------------------------------

 whenever error continue

 drop table DATMPRSREG

 whenever error stop

 if sqlca.sqlcode <> 0     and
    sqlca.sqlcode <> -206  then
    display "*** ERRO (", sqlca.sqlcode using "<<<<<<<&", ") na exclusao da tabela! ***"
    exit program (1)
 end if

end function  ###  DB_drop

#---------------------------------------------------------------
 function DB_grava(d_bdbsr005)
#---------------------------------------------------------------

 define d_bdbsr005   record
    pstcoddig        like dpaksocor.pstcoddig     ,
    nomgrr           like dpaksocor.nomgrr        ,
    endcid           like dpaksocor.endcid        ,
    endufd           like dpaksocor.endufd        ,
    endcep           like dpaksocor.endcep        ,
    atdregcod        like datkfxareg.atdregcod
 end record

 BEGIN WORK

 insert into work:datmprsreg
             ( relpamseq    ,
               pstcoddig    ,
               nomgrr       ,
               endcid       ,
               endufd       ,
               endcep       ,
               atdregcod    ,
               atdsrvqtd    ,
               pgosrvqtd    ,
               totpgovlr    ,
               maxpgovlr    )
      values ( param.relpamseq,
               d_bdbsr005.pstcoddig    ,
               d_bdbsr005.nomgrr       ,
               d_bdbsr005.endcid       ,
               d_bdbsr005.endufd       ,
               d_bdbsr005.endcep       ,
               d_bdbsr005.atdregcod    ,
               0, 0, 0, 0  )

 if sqlca.sqlcode <> 0 then
    ROLLBACK WORK
    display "*** Erro (", sqlca.sqlcode, ") na carga da tabela WORK! ***"
    exit program (1)
 else
    COMMIT WORK
 end if

end function  ###  DB_grava
