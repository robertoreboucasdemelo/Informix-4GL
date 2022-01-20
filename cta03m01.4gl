#############################################################################
# Menu de Modulo: cta03m01                                            Pedro #
#                                                                   Marcelo #
# Mostra Historico da Ligacao                                      Jan/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 09/02/2000  Probl.Ident  Gilberto     Correcao de casos onde dois funcio- #
#                                       narios digitam historico ao mesmo   #
#                                       tempo (data e hora).                #
# 27/08/2001  PSI          Paula        Possibilitar a consulta de historico#
#                          Fabrica      do sinistro - Perda Parcial         #
#                                       criacao da tab. temporaria          #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#...........................................................................#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor   Fabrica     Origem    Alteracao                        #
# ---------- ----------------- ----------  ---------------------------------#
# 18/03/2005 James, Meta       PSI 191094  Chamar a funcao cta00m06()       #
#---------------------------------------------------------------------------#
# 22/09/2006 Ruiz              PSI 202720  Inclusao de parametros na funcao#
#                                          cta01m12(cartao saude).         #
# 16/011/2006 Ligia            PSI 205206  ciaempcod
#--------------------------------------------------------------------------#

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define m_lignum like datmligacao.lignum

#---------------------------------------------------------------
 function cta03m01(k_cta03m01)
#---------------------------------------------------------------

 define k_cta03m01  record
    lignum          like datmlighist.lignum
 end record

 define w_hist          record
    ligdat          like datmlighist.ligdat    ,
    lighor          like datmlighist.lighorinc ,
    c24txtseq       like datmlighist.c24txtseq ,
    c24funmat       like datmlighist.c24funmat ,
    c24ligdsc       like datmlighist.c24ligdsc ,
    c24empcod       like datmlighist.c24empcod
 end record

 define w_ramcod    like datrligsin.ramcod
 define w_sinano    like sinrnsipnd.sinano
 define w_sinnum    like datrligsin.sinnum
 define w_sinitmseq like datrligsin.sinitmseq
 define w_sintfacod like datrligsin.sintfacod
 define w_nsinum    like sinrnsipnd.nsinum
 define w_funmat    like sinknota.funmat
 define w_caddat    like sinknota.caddat
 define w_cadhor    like sinknota.cadhor
 define w_lsiseq    like sinmlinhanota.lsiseq
 define w_lsides    like sinmlinhanota.lsides

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     w_ramcod  =  null
        let     w_sinano  =  null
        let     w_sinnum  =  null
        let     w_sinitmseq  =  null
        let     w_sintfacod  =  null
        let     w_nsinum  =  null
        let     w_funmat  =  null
        let     w_caddat  =  null
        let     w_cadhor  =  null
        let     w_lsiseq  =  null
        let     w_lsides  =  null
        let m_lignum = null

        initialize  w_hist.*  to  null

        let     w_ramcod  =  null
        let     w_sinano  =  null
        let     w_sinnum  =  null
        let     w_sinitmseq  =  null
        let     w_sintfacod  =  null
        let     w_nsinum  =  null
        let     w_funmat  =  null
        let     w_caddat  =  null
        let     w_cadhor  =  null
        let     w_lsiseq  =  null
        let     w_lsides  =  null

        initialize  w_hist.*  to  null

 whenever error continue
    create temp table temp_cta03m01
           (ligdat   date                   ,
            lighor   datetime hour to minute,
            seqhist  decimal(3,0)           ,
            funmat   decimal(6,0)           ,
            descrhist char(70)              ,
            c24empcod smallint)
            with no log
 whenever error stop

 if sqlca.sqlcode != 0 then
    if sqlca.sqlcode = -310 or
       sqlca.sqlcode = -958 then
       delete from temp_cta03m01
    else
       error "ERRO CreateTempTable temp_cta03m01 -> ",sqlca.sqlcode
       return
    end if
 else
    create index temp_cta03m01_idx
    on temp_cta03m01 (ligdat, lighor, seqhist)
                MESSAGE "" # By Robi
 end if

 let m_lignum = k_cta03m01.lignum

 select ramcod, sinano, sinnum, sinitmseq, sintfacod
 into w_ramcod, w_sinano, w_sinnum, w_sinitmseq, w_sintfacod
 from datrligsin
 where lignum = k_cta03m01.lignum

 declare c_cta03m01_001 cursor for
 select ligdat   , lighorinc,
        c24txtseq, c24funmat,
        c24ligdsc, c24empcod
 from datmlighist
 where lignum = k_cta03m01.lignum

 foreach c_cta03m01_001 into w_hist.ligdat   , w_hist.lighor   ,
                         w_hist.c24txtseq, w_hist.c24funmat,
                         w_hist.c24ligdsc, w_hist.c24empcod

     insert into temp_cta03m01
     values (w_hist.ligdat,
             w_hist.lighor,
             w_hist.c24txtseq,
             w_hist.c24funmat,
             w_hist.c24ligdsc,
             w_hist.c24empcod)
 end foreach

 if w_sintfacod is not null then
    declare c_cta03m01_002 cursor for
       select nsinum
          from sinrnsipnd
          where ramcod    = w_ramcod
            and sinano    = w_sinano
            and sinnum    = w_sinnum
            and sinitmseq = w_sinitmseq
            and sintfacod = w_sintfacod

    foreach c_cta03m01_002 into w_nsinum
       select funmat, caddat, cadhor
       into w_funmat, w_caddat, w_cadhor
       from sinknota
       where ramcod    = w_ramcod    and
             sinano    = w_sinano    and
             sinnum    = w_sinnum    and
             sinitmseq = w_sinitmseq and
             nsinum    = w_nsinum

       declare c_cta03m01_003 cursor for
         select lsiseq, lsides
         from sinmlinhanota
         where ramcod    = w_ramcod    and
               sinano    = w_sinano    and
               sinnum    = w_sinnum    and
               sinitmseq = w_sinitmseq and
               nsinum    = w_nsinum

       foreach c_cta03m01_003 into w_lsiseq,
                                 w_lsides

          if sqlca.sqlcode = 0 then
             if w_lsides[1] = "*" then
                continue foreach
             end if
             insert into temp_cta03m01
             values (w_caddat,
                     w_cadhor,
                     w_lsiseq,
                     w_funmat,
                     w_lsides)
          end if
       end foreach
       free c_cta03m01_003
    end foreach
 end if

 call f_carrega()

 whenever error continue
    drop table temp_cta03m01
 whenever error stop

 if sqlca.sqlcode <> 0 then
    error "Erro DropTable - temp_cta03m01 -> ",sqlca.sqlcode
 end if
end function  ###  cta03m01

#-----------------------------------------------------
 function f_carrega()
#-----------------------------------------------------

 define ws          record
    ligdat          like datmlighist.ligdat,
    lighor          like datmlighist.lighorinc,
    seqhist         like datmlighist.c24txtseq,
    funmat          like datmlighist.c24funmat,
    descrhist       like datmlighist.c24ligdsc,
    ligdatant       like datmlighist.ligdat,
    lighorant       like datmlighist.lighorinc,
    funmatant       like isskfunc.funmat,
    funnom          like isskfunc.funnom,
    dptsgl          like isskfunc.dptsgl,
    privez          smallint,
    prpflg          char(1),
    c24empcod       smallint
 end record

 define a_cta03m01 array[800] of record
    c24ligdsc      like datmlighist.c24ligdsc
 end record

 define arr_aux    smallint
 define scr_aux    smallint


        define  w_pf    integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


        define  w_pf1   integer

        let     arr_aux  =  null
        let     scr_aux  =  null
        let     w_pf  =  null

        for     w_pf1  =  1  to  800
                initialize  a_cta03m01[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

        let     arr_aux  =  null
        let     scr_aux  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        for     w_pf =  1  to  800
                initialize  a_cta03m01[w_pf].*  to  null
        end     for

 initialize ws.* to null

 let arr_aux      = 1
 let ws.privez    = true

 let ws.ligdatant = "31/12/1899"
 let ws.lighorant = "00:00"
 let ws.funmatant = 999999

 declare c_cta03m01_004 cursor for
 select * from temp_cta03m01
 order by ligdat, lighor, seqhist

 initialize a_cta03m01  to null

 foreach c_cta03m01_004 into ws.ligdat , ws.lighor,
                           ws.seqhist, ws.funmat,
                           ws.descrhist, ws.c24empcod


       if ws.ligdatant <> ws.ligdat     or
          ws.lighorant <> ws.lighor     or
          ws.funmatant <> ws.funmat   then

          if ws.privez  =  true  then
             let ws.privez = false
          else
             let arr_aux = arr_aux + 2
          end if

          if ws.c24empcod is null then
             select c24empcod
               into ws.c24empcod
               from datmligacao
              where lignum = m_lignum
          end if

          select funnom,dptsgl into ws.funnom,ws.dptsgl
            from isskfunc
           where empcod = ws.c24empcod
             and funmat = ws.funmat
          ## Portal WEB
          if  ws.funmat = 999999 or
              ws.funmat = 0 then
              let a_cta03m01[arr_aux].c24ligdsc =
                     "Em: ",  ws.ligdat clipped, "  ",
                     "As: ",  ws.lighor clipped, "  ",
                     "Por: PORTAL-WEB"
          else
             let a_cta03m01[arr_aux].c24ligdsc =
                    "Em: ",  ws.ligdat clipped, "  ",
                    "As: ",  ws.lighor clipped, "  ",
                    "Por: ", upshift(ws.funnom clipped)," - ",ws.dptsgl
          end if
          let ws.ligdatant = ws.ligdat
          let ws.lighorant = ws.lighor
          let ws.funmatant = ws.funmat
          let arr_aux      = arr_aux + 1
       end if

       let arr_aux = arr_aux + 1

       let a_cta03m01[arr_aux].c24ligdsc = ws.descrhist

       if arr_aux > 800  then
          error " Limite excedido, historico com mais de 800 linhas. AVISE A INFORMATICA!"
          sleep 5
          exit foreach
       end if

  end foreach

    if arr_aux  >  1  then
       call set_count(arr_aux)
       display array a_cta03m01 to s_cta03m00.*

          on key (F5)
             let g_monitor.horaini = current ## Flexvision
             call cta01m12_espelho(g_documento.ramcod
                                  ,g_documento.succod
                                  ,g_documento.aplnumdig
                                  ,g_documento.itmnumdig
                                  ,g_documento.prporg
                                  ,g_documento.prpnumdig
                                  ,g_documento.fcapacorg
                                  ,g_documento.fcapacnum
                                  ,g_documento.pcacarnum
                                  ,g_documento.pcaprpitm
                                  ,g_ppt.cmnnumdig
                                  ,g_documento.crtsaunum
                                  ,g_documento.bnfnum
                                  ,g_documento.ciaempcod) ##psi 205206

          on key (interrupt,control-c)
             exit display
       end display
    else
       error " Nenhum historico foi cadastrado para esta ligacao!"
       let int_flag =  true
    end if


 end function
