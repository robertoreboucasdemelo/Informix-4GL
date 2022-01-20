###############################################################################
# Nome do Modulo: CTB16M00                                            Marcelo #
#                                                                    Gilberto #
#                                                                      Wagner #
# Manutencao da analise dos servicos prestados                       Nov/1999 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 04/04/2000  PSI 10426-4  Wagner       Permitir mais de um evento de analise #
#                                       por servico.                          #
#-----------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
###############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-------------------------------------------------------------
 function ctb16m00()
#-------------------------------------------------------------

 define ws            record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record


 if not get_niv_mod(g_issk.prgsgl, "ctb16m00") then
    error " Modulo sem nivel de consulta e atualizacao!"
    return
 end if

 open window w_ctb16m00 at 06,02 with form "ctb16m00"
             attribute (form line first)

 let int_flag = false

 while true

    clear form

    initialize ws.*  to null

    input by name ws.atdsrvnum,
                  ws.atdsrvano without defaults

       before field atdsrvnum
              display by name ws.atdsrvnum attribute (reverse)

       after  field atdsrvnum
              display by name ws.atdsrvnum

              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 next field  atdsrvnum
              end if

              if ws.atdsrvnum  is null   then
                 error " Numero do servico deve ser informado!"
                 next field atdsrvnum
              end if

       before field atdsrvano
              display by name ws.atdsrvano attribute (reverse)

       after  field atdsrvano
              display by name ws.atdsrvano

              if fgl_lastkey() = fgl_keyval ("up")     or
                 fgl_lastkey() = fgl_keyval ("left")   then
                 next field  atdsrvnum
              end if

              if ws.atdsrvano  is null   then
                 error " Ano do servico deve ser informado!"
                 next field atdsrvano
              end if

              select atdsrvnum
                from datmservico
               where datmservico.atdsrvnum = ws.atdsrvnum
                 and datmservico.atdsrvano = ws.atdsrvano

              if sqlca.sqlcode = notfound   then
                 error " Servico nao encontrado!"
                 next field atdsrvano
              end if

              call ctb16m00_analise (ws.atdsrvnum, ws.atdsrvano, 0, 1)

       on key (interrupt)
          exit input

    end input

    if int_flag = true then
       exit while
    end if

 end while

 whenever error stop
 let int_flag = false
 message ""

 close window w_ctb16m00

 end function   #  ctb16m00


#------------------------------------------------------------
 function ctb16m00_analise(param)
#------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    c24evtcod         like datmsrvanlhst.c24evtcod,
    origem            smallint
 end record

 define d_ctb16m00    record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    atdprscod         like datmservico.atdprscod,
    nomgrr            like dpaksocor.nomgrr,
    c24evtcod         like datmsrvanlhst.c24evtcod,
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datmsrvanlhst.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24fsecod_ult     like datmsrvanlhst.c24fsecod,
    c24fsedes_ult     like datkfse.c24fsedes,
    caddat            like datmsrvanlhst.caddat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    c24fsecod         like datmsrvanlhst.c24fsecod,
    srvanlhstseq      like datmsrvanlhst.srvanlhstseq,
    socopgnum         like dbsmopg.socopgnum,
    socopgsitcod      like dbsmopg.socopgsitcod,
    funmat            like isskfunc.funmat,
    count             smallint,
    confirma          char (01)
 end record

 initialize d_ctb16m00.* to null
 initialize ws.*         to null

 let d_ctb16m00.atdsrvnum  =  param.atdsrvnum
 let d_ctb16m00.atdsrvano  =  param.atdsrvano
 let d_ctb16m00.c24evtcod  =  param.c24evtcod

 #------------------------------
 # VERIFICA SE O.P. JA' FOI PAGA
 #------------------------------
 initialize ws.socopgnum   to null
 select dbsmopg.socopgnum
   into ws.socopgnum, ws.socopgsitcod
   from dbsmopgitm, dbsmopg
  where dbsmopgitm.atdsrvnum = d_ctb16m00.atdsrvnum
    and dbsmopgitm.atdsrvano = d_ctb16m00.atdsrvano
    and dbsmopg.socopgnum    = dbsmopgitm.socopgnum
    and dbsmopg.socopgsitcod <> 8
    and dbsmopg.soctip       = 1    # P.Socorro

 if sqlca.sqlcode = 0    then
    if ws.socopgsitcod <> 8 then
       case ws.socopgsitcod
         when 6
           error " O.S. nao pode ser alterada, O.P. No. ", ws.socopgnum, "pronta p/emissao!"

         when 7
           error " O.S. ja' foi paga pela O.P. No. ", ws.socopgnum

         when 9
           error " O.S. aguardando batimento pela O.P. No. ", ws.socopgnum

         otherwise
           error " O.S. Ja' cadastrada na  O.P. No. ", ws.socopgnum
       end case
       prompt " " for ws.confirma
       return
    end if
 end if

 if param.origem <> 1 then
    open window w_ctb16m00 at 06,02 with form "ctb16m00"
                attribute (form line first)
 end if

 call ctb16m00_ler (d_ctb16m00.atdsrvnum,
                    d_ctb16m00.atdsrvano,
                    d_ctb16m00.c24evtcod)
         returning  d_ctb16m00.*

 display by name d_ctb16m00.*

 let int_flag = false

 input by name d_ctb16m00.c24evtcod,
               d_ctb16m00.c24fsecod  without defaults

    before field c24evtcod
           if param.c24evtcod is not null and
              param.c24evtcod <>  0       then
              initialize ws.c24fsecod to null
              next field c24fsecod
           end if
           display by name d_ctb16m00.c24evtcod attribute (reverse)
           initialize d_ctb16m00.c24fsecod_ult, d_ctb16m00.c24fsedes_ult,
                      d_ctb16m00.caddat       , d_ctb16m00.funnom    to null
           display by name d_ctb16m00.c24fsecod_ult
           display by name d_ctb16m00.c24fsedes_ult
           display by name d_ctb16m00.caddat
           display by name d_ctb16m00.funnom

    after  field c24evtcod
           display by name d_ctb16m00.c24evtcod

           if d_ctb16m00.c24evtcod  is null   then
              error " Codigo do evento deve ser informado!"
              call ctb14m01() returning d_ctb16m00.c24evtcod
              next field c24evtcod
           end if

           select c24evtrdzdes, c24fsecod
             into d_ctb16m00.c24evtrdzdes, ws.c24fsecod
             from datkevt
            where c24evtcod = d_ctb16m00.c24evtcod

           if sqlca.sqlcode <> 0 then
              error " Codigo do evento nao cadastrado !"
              next field c24evtcod
           end if

           let d_ctb16m00.c24fsecod = ws.c24fsecod
           display by name d_ctb16m00.c24evtrdzdes

           #----------------------------------
           # Verifica se evento ja' cadastrado
           #----------------------------------
           select max(srvanlhstseq)
             into ws.srvanlhstseq
             from datmsrvanlhst
            where datmsrvanlhst.atdsrvnum = d_ctb16m00.atdsrvnum
              and datmsrvanlhst.atdsrvano = d_ctb16m00.atdsrvano
              and datmsrvanlhst.c24evtcod = d_ctb16m00.c24evtcod

           if ws.srvanlhstseq is not null   and
              ws.srvanlhstseq   <>   0      then
              select c24fsecod, caddat, cadmat
                into d_ctb16m00.c24fsecod_ult, d_ctb16m00.caddat, ws.funmat
                from datmsrvanlhst
               where datmsrvanlhst.atdsrvnum    = d_ctb16m00.atdsrvnum
                 and datmsrvanlhst.atdsrvano    = d_ctb16m00.atdsrvano
                 and datmsrvanlhst.c24evtcod    = d_ctb16m00.c24evtcod
                 and datmsrvanlhst.srvanlhstseq = ws.srvanlhstseq

              select c24fsedes
                into d_ctb16m00.c24fsedes_ult
                from datkfse
                where datkfse.c24fsecod = d_ctb16m00.c24fsecod_ult

             select funnom
               into d_ctb16m00.funnom
               from isskfunc
              where isskfunc.empcod = 1
                and isskfunc.funmat = ws.funmat

             display by name d_ctb16m00.c24fsecod_ult
             display by name d_ctb16m00.c24fsedes_ult
             display by name d_ctb16m00.caddat
             display by name d_ctb16m00.funnom

           end if

    before field c24fsecod
           display by name d_ctb16m00.c24fsecod attribute (reverse)

    after  field c24fsecod
           display by name d_ctb16m00.c24fsecod

           if fgl_lastkey() = fgl_keyval ("up")     or
              fgl_lastkey() = fgl_keyval ("left")   then
              if param.c24evtcod is null or
                 param.c24evtcod = 0     then
                 next field c24evtcod
              end if
           end if

           if d_ctb16m00.c24fsecod  is null   then
              error " Codigo da fase do evento deve ser informada!"
              call ctb15m02() returning d_ctb16m00.c24fsecod
              next field c24fsecod
           end if

           if d_ctb16m00.c24fsecod_ult is not null             and
              d_ctb16m00.c24fsecod_ult = d_ctb16m00.c24fsecod  then
              error " Codigo da nova fase igual codigo da ultima fase!"
              next field c24fsecod
           end if

           select c24fsedes
             into d_ctb16m00.c24fsedes
             from datkfse
            where c24fsecod = d_ctb16m00.c24fsecod

           if sqlca.sqlcode <> 0 then
              error " Codigo da fase nao cadastrado !"
              next field c24fsecod
           end if

           display by name d_ctb16m00.c24fsedes

           # verifica autorizacao da fase
           if ws.c24fsecod is not null             and
              ws.c24fsecod = d_ctb16m00.c24fsecod  then
              # nao e' necessario teste
           else
              select count(*)
                into ws.count
                from datkfseatz
               where datkfseatz.c24fsecod = d_ctb16m00.c24fsecod

              if ws.count is not null  and
                 ws.count <> 0         then
                 select c24fsecod
                   from datkfseatz
                  where datkfseatz.c24fsecod = d_ctb16m00.c24fsecod
                    and datkfseatz.empcod    = g_issk.empcod
                    and datkfseatz.funmat    = g_issk.funmat

                 if sqlca.sqlcode = notfound then
                    error " Matricula nao autorizada para esta mudanca de fase!"
                    next field c24fsecod
                 end if
              end if
           end if

    on key (interrupt)
       exit input

 end input

 if int_flag  then
    error " Operacao cancelada!"
 else
    call cts08g01("C","S","","CONFIRA DADOS DESTA ANALISE ?","","")
         returning ws.confirma

    if ws.confirma = "S"  then
       call ctb00g01_anlsrv( d_ctb16m00.c24evtcod,
                             d_ctb16m00.c24fsecod,
                             d_ctb16m00.atdsrvnum,
                             d_ctb16m00.atdsrvano,
                             g_issk.funmat )

    end if
 end if

 whenever error stop
 let int_flag = false
 initialize d_ctb16m00.*  to null
 display by name d_ctb16m00.*
 message ""

 if param.origem <> 1 then
    close window w_ctb16m00
 end if

 end function   #  ctb16m00_analise


#---------------------------------------------------------
 function ctb16m00_ler(param)
#---------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    c24evtcod         like datmsrvanlhst.c24evtcod
 end record

 define d_ctb16m00    record
    atdsrvorg         like datmservico.atdsrvorg,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    atddat            like datmservico.atddat,
    atdhor            like datmservico.atdhor,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    atdprscod         like datmservico.atdprscod,
    nomgrr            like dpaksocor.nomgrr,
    c24evtcod         like datmsrvanlhst.c24evtcod,
    c24evtrdzdes      like datkevt.c24evtrdzdes,
    c24fsecod         like datmsrvanlhst.c24fsecod,
    c24fsedes         like datkfse.c24fsedes,
    c24fsecod_ult     like datmsrvanlhst.c24fsecod,
    c24fsedes_ult     like datkfse.c24fsedes,
    caddat            like datmsrvanlhst.caddat,
    funnom            like isskfunc.funnom
 end record

 define ws            record
    funmat            like isskfunc.funmat,
    srvanlhstseq      like datmsrvanlhst.srvanlhstseq
 end record

 initialize d_ctb16m00.*   to null
 initialize ws.*           to null

 select atdsrvnum,
        atdsrvano,
        atddat,
        atdhor,
        atdprscod,
        atdsrvorg
   into d_ctb16m00.atdsrvnum,
        d_ctb16m00.atdsrvano,
        d_ctb16m00.atddat,
        d_ctb16m00.atdhor,
        d_ctb16m00.atdprscod,
        d_ctb16m00.atdsrvorg
   from datmservico
  where datmservico.atdsrvnum = param.atdsrvnum
    and datmservico.atdsrvano = param.atdsrvano

 if sqlca.sqlcode = notfound   then
    error " Servico nao encontrado!"
    initialize d_ctb16m00.*    to null
 else
    select srvtipabvdes
      into d_ctb16m00.srvtipabvdes
      from datksrvtip
     where datksrvtip.atdsrvorg = d_ctb16m00.atdsrvorg

    select nomgrr
      into d_ctb16m00.nomgrr
      from dpaksocor
     where pstcoddig = d_ctb16m00.atdprscod

    select max(srvanlhstseq)
      into ws.srvanlhstseq
      from datmsrvanlhst
     where datmsrvanlhst.atdsrvnum = d_ctb16m00.atdsrvnum
       and datmsrvanlhst.atdsrvano = d_ctb16m00.atdsrvano
       and datmsrvanlhst.c24evtcod = param.c24evtcod

    if ws.srvanlhstseq is not null   and
       ws.srvanlhstseq   <>   0      then
       select c24evtcod,
              c24fsecod,
              caddat,
              cadmat
         into d_ctb16m00.c24evtcod,
              d_ctb16m00.c24fsecod_ult,
              d_ctb16m00.caddat,
              ws.funmat
         from datmsrvanlhst
        where datmsrvanlhst.atdsrvnum    = d_ctb16m00.atdsrvnum
          and datmsrvanlhst.atdsrvano    = d_ctb16m00.atdsrvano
          and datmsrvanlhst.c24evtcod    = param.c24evtcod
          and datmsrvanlhst.srvanlhstseq = ws.srvanlhstseq

       select c24evtrdzdes
         into d_ctb16m00.c24evtrdzdes
         from datkevt
        where c24evtcod = d_ctb16m00.c24evtcod

       select c24fsedes
         into d_ctb16m00.c24fsedes_ult
         from datkfse
        where datkfse.c24fsecod = d_ctb16m00.c24fsecod_ult

       select funnom
         into d_ctb16m00.funnom
         from isskfunc
        where isskfunc.empcod = 1
          and isskfunc.funmat = ws.funmat

    end if

 end if

 return d_ctb16m00.*

end function   # ctb16m00_ler

