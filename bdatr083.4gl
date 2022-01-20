###############################################################################
# Nome do Modulo: BDATR083                                         Wagner     #
#                                                                             #
# Gera relatorio RPT's concluidas e envia por e-mail aos Estados   Mai/2000   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 13/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg   #
#                                       Exibicao do atdsrvnum (dec 10,0)      #
#-----------------------------------------------------------------------------#
# 22/04/2003               FERNANDO-FSW RESOLUCAO 86                          #
###############################################################################
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
#-----------------------------------------------------------------------------#
# 17/08/2007 Robson, Meta       AS146145  Alterado as palavras reservadas.    #
#-----------------------------------------------------------------------------#
# 29/10/2013  PSI-2013-23297            Alteração da utilização do sendmail   #
###############################################################################

 database porto

 define g_traco        char (80)
 define ws_incdat      date
 define ws_pathrel     char (60)
 define m_rel          smallint
 globals
   define g_ismqconn smallint
end globals

 main
    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    let m_rel = true
    call bdatr083()
 end main

#---------------------------------------------------------------
 function bdatr083()
#---------------------------------------------------------------

 define d_bdatr083    record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atddatprg         like datmservico.atddatprg,
    atdprscod         like datmservico.atdprscod,
    vcldes            like datmservico.vcldes,
    vclanomdl         like datmservico.vclanomdl,
    vcllicnum         like datmservico.vcllicnum,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    dddcod            like dpaksocor.dddcod,
    teltxt            like dpaksocor.teltxt,
    lclidttxt_ori     like datmlcl.lclidttxt,
    lgdtip_ori        like datmlcl.lgdtip,
    lgdnom_ori        like datmlcl.lgdnom,
    lgdnum_ori        like datmlcl.lgdnum,
    brrnom_ori        like datmlcl.brrnom,
    cidnom_ori        like datmlcl.cidnom,
    ufdcod_ori        like datmlcl.ufdcod,
    lclidttxt_des     like datmlcl.lclidttxt,
    lgdtip_des        like datmlcl.lgdtip,
    lgdnom_des        like datmlcl.lgdnom,
    lgdnum_des        like datmlcl.lgdnum,
    brrnom_des        like datmlcl.brrnom,
    cidnom_des        like datmlcl.cidnom,
    ufdcod_des        like datmlcl.ufdcod,
    ufdcod_email      like datmlcl.ufdcod
 end record

 define ws            record
    auxdat            char (10),
    c24endtip         like datmlcl.c24endtip,
    atdetpcod         like datmsrvacp.atdetpcod,
    dirfisnom         like ibpkdirlog.dirfisnom,
    count             smallint,
    comando           char (400)
 end record


 initialize d_bdatr083.*  to null
 initialize ws.*          to null
 let g_traco = "--------------------------------------------------------------------------------"


 #--------------------------------------------------------------------
 # Preparando SQL ETAPAS
 #--------------------------------------------------------------------
 let ws.comando  = "select atdetpcod    ",
                   "  from datmsrvacp   ",
                   " where atdsrvnum = ?",
                   "   and atdsrvano = ?",
                   "   and atdsrvseq = (select max(atdsrvseq)",
                                       "  from datmsrvacp    ",
                                       " where atdsrvnum = ? ",
                                       "   and atdsrvano = ?)"
 prepare sel_datmsrvacp from ws.comando
 declare c_datmsrvacp cursor for sel_datmsrvacp

 #---------------------------------------------------------------
 # Preparando SQL Endereco
 #---------------------------------------------------------------
 let ws.comando  = "select lclidttxt, lgdtip, ",
                   "       lgdnom   , lgdnum, ",
                   "       brrnom   , cidnom, ",
                   "       ufdcod             ",
                   "  from datmlcl            ",
                   " where atdsrvnum = ? ",
                   "   and atdsrvano = ? ",
                   "   and c24endtip = ? "
 prepare sel_datmlcl from ws.comando
 declare c_datmlcl cursor for sel_datmlcl

 #---------------------------------------------------------------
 # Preparando SQL E-mail
 #---------------------------------------------------------------
 let ws.comando  = "select count(*)     ",
                   "  from datmsucmai   ",
                   " where ufdcod    = ? "
 prepare sel_estado from ws.comando
 declare c_estado cursor for sel_estado

 #--------------------------------------------------------------------
 # Preparando SQL PRESTADOR
 #--------------------------------------------------------------------
 let ws.comando  = "select nomrazsoc, dddcod, teltxt ",
                   "  from dpaksocor     ",
                   " where pstcoddig = ? "
 prepare sel_dpaksocor from ws.comando
 declare c_dpaksocor cursor for sel_dpaksocor

 #--------------------------------------------------------------------
 # Define data parametro
 #--------------------------------------------------------------------
 let ws.auxdat = arg_val(1)

 if ws.auxdat is null       or
    ws.auxdat =  "  "       then
    if time >= "17:00"  and
       time <= "23:59"  then
       let ws.auxdat = today
    else
       let ws.auxdat = today - 1
    end if
 else
    if ws.auxdat > today       or
       length(ws.auxdat) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 let ws_incdat       = ws.auxdat


 #---------------------------------------------------------------
 # Define diretorios para relatorios e arquivos
 #---------------------------------------------------------------
 call f_path("DAT", "RELATO")
      returning ws.dirfisnom

 display 'Diretorio: ',ws.dirfisnom
 let ws_pathrel  = ws.dirfisnom clipped, "/RDAT08301.DOC"


 #---------------------------------------------------------------
 # Cursor principal
 #---------------------------------------------------------------
 declare c_bdatr083 cursor for
  select datmservico.atdsrvorg ,
         datmservico.atdsrvnum ,
         datmservico.atdsrvano ,
         datmservico.atddat    ,
         datmservico.atddatprg ,
         datmservico.atdprscod ,
         datmservico.vcldes    ,
         datmservico.vclanomdl ,
         datmservico.vcllicnum ,
         datrservapol.succod   ,
         datrservapol.ramcod   ,
         datrservapol.aplnumdig,
         datrservapol.itmnumdig
    from datmservico, outer datrservapol
   where datmservico.atddat       between ws_incdat - 20 and ws_incdat
     and datmservico.atdsrvorg    = 5
     and datrservapol.atdsrvnum   = datmservico.atdsrvnum
     and datrservapol.atdsrvano   = datmservico.atdsrvano


 start report bdatr083_rel

 foreach c_bdatr083  into  d_bdatr083.atdsrvorg,
                           d_bdatr083.atdsrvnum, d_bdatr083.atdsrvano,
                           d_bdatr083.atddat   , d_bdatr083.atddatprg,
                           d_bdatr083.atdprscod, d_bdatr083.vcldes   ,
                           d_bdatr083.vclanomdl, d_bdatr083.vcllicnum,
                           d_bdatr083.succod   , d_bdatr083.ramcod   ,
                           d_bdatr083.aplnumdig, d_bdatr083.itmnumdig

    if d_bdatr083.succod    is null  and
       d_bdatr083.aplnumdig is null  and
       d_bdatr083.itmnumdig is null  then
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica data chegada veiculo
    #------------------------------------------------------------
    if d_bdatr083.atddatprg is null then
       let d_bdatr083.atddatprg = d_bdatr083.atddat
    end if
    if d_bdatr083.atddatprg <> ws_incdat  then
       continue foreach
    end if

    #------------------------------------------------------------
    # Verifica etapa dos servicos
    #------------------------------------------------------------
    open  c_datmsrvacp using d_bdatr083.atdsrvnum, d_bdatr083.atdsrvano,
                             d_bdatr083.atdsrvnum, d_bdatr083.atdsrvano
    fetch c_datmsrvacp into  ws.atdetpcod
    close c_datmsrvacp

    if ws.atdetpcod <> 4      then   # somente servicos etapa concluida
       continue foreach
    end if

    #---------------------------------------------------------------
    # Busca LOCAL Origem
    #---------------------------------------------------------------
    let ws.c24endtip = 1   # Local origem
    open  c_datmlcl using  d_bdatr083.atdsrvnum,
                           d_bdatr083.atdsrvano,
                           ws.c24endtip
    fetch c_datmlcl into   d_bdatr083.lclidttxt_ori, d_bdatr083.lgdtip_ori,
                           d_bdatr083.lgdnom_ori   , d_bdatr083.lgdnum_ori,
                           d_bdatr083.brrnom_ori   , d_bdatr083.cidnom_ori,
                           d_bdatr083.ufdcod_ori
    close c_datmlcl

    #---------------------------------------------------------------
    # Busca LOCAL Destino
    #---------------------------------------------------------------
    let ws.c24endtip = 2   # Local destino
    open  c_datmlcl using  d_bdatr083.atdsrvnum,
                           d_bdatr083.atdsrvano,
                           ws.c24endtip
    fetch c_datmlcl into   d_bdatr083.lclidttxt_des, d_bdatr083.lgdtip_des,
                           d_bdatr083.lgdnom_des   , d_bdatr083.lgdnum_des,
                           d_bdatr083.brrnom_des   , d_bdatr083.cidnom_des,
                           d_bdatr083.ufdcod_des
    close c_datmlcl

    #------------------------------------------------------------
    # Verifica Estado
    #------------------------------------------------------------
    let d_bdatr083.ufdcod_email  = d_bdatr083.ufdcod_des
    open  c_estado using d_bdatr083.ufdcod_email
    fetch c_estado into  ws.count
    close c_estado
    display 'Cont: ',ws.count
    if ws.count is null    or
       ws.count = 0        then
       let d_bdatr083.ufdcod_email = "SP"
    end if

    #---------------------------------------------------------------
    # Busca nome prestador
    #---------------------------------------------------------------
    open  c_dpaksocor using d_bdatr083.atdprscod
    fetch c_dpaksocor into  d_bdatr083.nomrazsoc,
                            d_bdatr083.dddcod,
                            d_bdatr083.teltxt
    close c_dpaksocor

    output to report bdatr083_rel(d_bdatr083.*)

    initialize d_bdatr083.* to null

 end foreach

 finish report bdatr083_rel

end function #  bdatr083


#----------------------------------------------------------------------------#
 report bdatr083_rel(w_bdatr083)
#----------------------------------------------------------------------------#

 define w_bdatr083    record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atddatprg         like datmservico.atddatprg,
    atdprscod         like datmservico.atdprscod,
    vcldes            like datmservico.vcldes,
    vclanomdl         like datmservico.vclanomdl,
    vcllicnum         like datmservico.vcllicnum,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    dddcod            like dpaksocor.dddcod,
    teltxt            like dpaksocor.teltxt,
    lclidttxt_ori     like datmlcl.lclidttxt,
    lgdtip_ori        like datmlcl.lgdtip,
    lgdnom_ori        like datmlcl.lgdnom,
    lgdnum_ori        like datmlcl.lgdnum,
    brrnom_ori        like datmlcl.brrnom,
    cidnom_ori        like datmlcl.cidnom,
    ufdcod_ori        like datmlcl.ufdcod,
    lclidttxt_des     like datmlcl.lclidttxt,
    lgdtip_des        like datmlcl.lgdtip,
    lgdnom_des        like datmlcl.lgdnom,
    lgdnum_des        like datmlcl.lgdnum,
    brrnom_des        like datmlcl.brrnom,
    cidnom_des        like datmlcl.cidnom,
    ufdcod_des        like datmlcl.ufdcod,
    ufdcod_email      like datmlcl.ufdcod
 end record

 define ws            record
    maides            like datmsucmai.maides,
    sucmaistt         like datmsucmai.sucmaistt,
    comando           char (400)
 end record

 define  l_mail             record
      de                 char(500)   # De
     ,para               char(5000)  # Para
     ,cc                 char(500)   # cc
     ,cco                char(500)   # cco
     ,assunto            char(500)   # Assunto do e-mail
     ,mensagem           char(32766) # Nome do Anexo
     ,id_remetente       char(20)
     ,tipo               char(4)     #
 end  record
 define l_coderro  smallint
 define msg_erro char(500)
 define arr_aux       smallint


 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
    page   length  01

 order by  w_bdatr083.ufdcod_email

 format

     before group of w_bdatr083.ufdcod_email
        start report rel_uf to ws_pathrel

     on every row
        let m_rel = true
        output to report rel_uf(w_bdatr083.*)

     after  group of w_bdatr083.ufdcod_email
        finish report rel_uf
        declare c_email cursor for
         select maides, sucmaistt
           from datmsucmai
          where ufdcod    =  w_bdatr083.ufdcod_email
            and sucmaiseq <> 0

        foreach c_email into ws.maides, ws.sucmaistt
           if ws.sucmaistt = "A" then
             for arr_aux = 1 to 50
                 if ws.maides[arr_aux,arr_aux] = ","  then
                    let ws.maides[arr_aux,arr_aux] = "_"
                 end if
             end for
             #PSI-2013-23297 - Inicio
             let l_mail.de = ""
             let l_mail.para =  ws.maides
             let l_mail.cc = ""
             let l_mail.cco = ""
             let l_mail.assunto = "RPTs Concluidas de : ",ws_incdat
             let l_mail.mensagem = "<html><body><font face = Times New Roman>RPTs Concluidas de : ",ws_incdat
                                  ,"<br><br></font></body></html>"
             let l_mail.id_remetente = "CT24H"
             let l_mail.tipo = "html"
             display 'Mrel: ',m_rel
             if m_rel = true then
                  display "Arquivo: ",ws_pathrel

                  call figrc009_attach_file(ws_pathrel)
                  display "Arquivo anexado com sucesso"
             else
               let l_mail.mensagem = "Nao existem registros a serem processados."
             end if
            call figrc009_mail_send1 (l_mail.*)
              returning l_coderro,msg_erro
              display 'Coderro: ',l_coderro
              display 'Msgerro: ',msg_erro
             #PSI-2013-23297 - Fim 
          end if
        end foreach
    finish report rel_uf
end report  ###  bdatr083_rel


#----------------------------------------------------------------------------#
 report rel_uf(r_bdatr083)
#----------------------------------------------------------------------------#

 define r_bdatr083    record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atddatprg         like datmservico.atddatprg,
    atdprscod         like datmservico.atdprscod,
    vcldes            like datmservico.vcldes,
    vclanomdl         like datmservico.vclanomdl,
    vcllicnum         like datmservico.vcllicnum,
    succod            like datrservapol.succod,
    ramcod            like datrservapol.ramcod,
    aplnumdig         like datrservapol.aplnumdig,
    itmnumdig         like datrservapol.itmnumdig,
    nomrazsoc         like dpaksocor.nomrazsoc,
    dddcod            like dpaksocor.dddcod,
    teltxt            like dpaksocor.teltxt,
    lclidttxt_ori     like datmlcl.lclidttxt,
    lgdtip_ori        like datmlcl.lgdtip,
    lgdnom_ori        like datmlcl.lgdnom,
    lgdnum_ori        like datmlcl.lgdnum,
    brrnom_ori        like datmlcl.brrnom,
    cidnom_ori        like datmlcl.cidnom,
    ufdcod_ori        like datmlcl.ufdcod,
    lclidttxt_des     like datmlcl.lclidttxt,
    lgdtip_des        like datmlcl.lgdtip,
    lgdnom_des        like datmlcl.lgdnom,
    lgdnum_des        like datmlcl.lgdnum,
    brrnom_des        like datmlcl.brrnom,
    cidnom_des        like datmlcl.cidnom,
    ufdcod_des        like datmlcl.ufdcod,
    ufdcod_email      like datmlcl.ufdcod
 end record


 output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00

 format

      first page header
           print column 072, "DAT083-01"
           print column 062, "DATA   : ", today
           print column 062, "HORA   :   ", time
           print column 007, "RELATORIO DE RPTs CONCLUIDAS DE : ", ws_incdat
           skip 1 lines
           print column 001, g_traco
           skip 1 line


      on every row
           print column 001, "SERVICO.........: ",
                             r_bdatr083.atdsrvorg  using "&&",
                             "/", r_bdatr083.atdsrvnum  using "&&&&&&&",
                             "-", r_bdatr083.atdsrvano  using "&&"
           print column 001, "DOCUMENTO.......: ",
                             r_bdatr083.ramcod     using "&&&&"       ,"/",
                             r_bdatr083.succod     using "&&"         ,"/",
                             r_bdatr083.aplnumdig  using "<<<<<<<& &" ,"/",
                             r_bdatr083.itmnumdig  using "<<<<<& &"
           print column 001, "VEICULO.........: ",
                             r_bdatr083.vcldes
           print column 001, "      ANO/MODELO: ",
                             r_bdatr083.vclanomdl
           print column 001, "      PLACAS....: ",
                             r_bdatr083.vcllicnum
           print column 001, "LOCAL ORIGEM....: ",
                             r_bdatr083.lclidttxt_ori
           print column 001, "        ENDER. .: ",
                             r_bdatr083.lgdtip_ori clipped ," ",
                             r_bdatr083.lgdnom_ori clipped ," ",
                             r_bdatr083.lgdnum_ori
           print column 001, "        BAIRRO..: ",
                             r_bdatr083.brrnom_ori
           print column 001, "        CIDADE..: ",
                             r_bdatr083.cidnom_ori clipped ," ",
                             r_bdatr083.ufdcod_ori
           print column 001, "LOCAL DESTINO...: ",
                             r_bdatr083.lclidttxt_des
           print column 001, "        ENDER. .: ",
                             r_bdatr083.lgdtip_des clipped ," ",
                             r_bdatr083.lgdnom_des clipped ," ",
                             r_bdatr083.lgdnum_des
           print column 001, "        BAIRRO..: ",
                             r_bdatr083.brrnom_des
           print column 001, "        CIDADE..: ",
                             r_bdatr083.cidnom_des clipped ," ",
                             r_bdatr083.ufdcod_des
           print column 001, "PRESTADOR.......: ",
                             r_bdatr083.atdprscod using "&&&&#" , "-",
                             r_bdatr083.nomrazsoc[1,40]
           print column 001, "        TELEFONE: ",
                             r_bdatr083.dddcod clipped ," ",
                             r_bdatr083.teltxt
           print column 001, "DATA LIM.REMOCAO: ",
                             r_bdatr083.atddatprg
           skip 1 line

end report  ###  rel_uf

