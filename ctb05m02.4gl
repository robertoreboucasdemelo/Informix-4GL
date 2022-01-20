###############################################################################
# Nome do Modulo: CTB05M02                                           Wagner   #
#                                                                             #
# Consulta ordem de pagamento por (numero/ numero de O.S.)           Mar/2002 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel    #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb05m02(param)
#-----------------------------------------------------------

 define param       record
    socopgnum       like dbsmopg.socopgnum
 end record

 define d_ctb05m02  record
    socopgnumc      like dbsmopg.socopgnum,
    atdsrvnum       like dbsmopgitm.atdsrvnum,
    atdsrvano       like dbsmopgitm.atdsrvano,
    socopgnum       like dbsmopg.socopgnum,
    socopgfasdes    char(30),
    socopgsitdes    char(30),
    favtipcab       char(14),
    favtipcod       char(08),
    favtipnom       char(40),
    socfatentdat    like dbsmopg.socfatentdat,
    socfatpgtdat    like dbsmopg.socfatpgtdat,
    socfatitmqtd    like dbsmopg.socfatitmqtd,
    socfattotvlr    like dbsmopg.socfattotvlr,
    tippesdes       char(08),
    cgccpfnum       like dbsmopg.cgccpfnum,
    cgcord          like dbsmopg.cgcord,
    cgccpfdig       like dbsmopg.cgccpfdig,
    socpgtopcdes    char(10),
    pgtdstdes       like fpgkpgtdst.pgtdstdes,
    socopgfavnom    like dbsmopgfav.socopgfavnom,
    bcocod          like dbsmopgfav.bcocod,
    bcosgl          like gcdkbanco.bcosgl,
    bcoagnnum       like dbsmopgfav.bcoagnnum,
    bcoagndig       like dbsmopgfav.bcoagndig,
    bcoctanum       like dbsmopgfav.bcoctanum,
    bcoctadig       like dbsmopgfav.bcoctadig
 end record

 define ws          record
    atdsrvorg       like datmservico.atdsrvorg,
    pestip          like dbsmopg.pestip,
    pstcoddig       like dbsmopg.pstcoddig,
    corsus          like dbsmopg.corsus,
    segnumdig       like dbsmopg.segnumdig,
    socpgtopccod    like dbsmopgfav.socpgtopccod,
    pgtdstcod       like dbsmopg.pgtdstcod,
    socopgsitcod    like dbsmopg.socopgsitcod,
    socopgfascod    like dbsmopgfas.socopgfascod,
    cponom          like iddkdominio.cponom,
    soctip          like dbsmopg.soctip,
    retorno         smallint,
    mensagem        char(60)
 end record

 define prompt_key  char (01)

 open window ctb05m02 at 06,02 with form "ctb05m02"
             attribute (form line first)

 while true

   let int_flag = false
   initialize ws.*          to null
   initialize d_ctb05m02.*  to null
   display by name d_ctb05m02.*
   display by name ws.atdsrvorg

   if param.socopgnum  is not null    then
      let d_ctb05m02.socopgnumc = param.socopgnum
      let d_ctb05m02.socopgnum  = param.socopgnum
   end if

   input by name d_ctb05m02.socopgnumc,
                 d_ctb05m02.atdsrvnum,
                 d_ctb05m02.atdsrvano  without defaults

      before field socopgnumc
             if param.socopgnum  is not null    then
                exit input
             end if
             display by name d_ctb05m02.socopgnumc    attribute (reverse)

             initialize d_ctb05m02.atdsrvnum  to null
             initialize d_ctb05m02.atdsrvano  to null
             display by name d_ctb05m02.atdsrvnum
             display by name d_ctb05m02.atdsrvano

      after  field socopgnumc
             display by name d_ctb05m02.socopgnumc

             initialize d_ctb05m02.socopgnum   to null

             if d_ctb05m02.socopgnumc  is not null   then
                select socopgnum, soctip
                  into d_ctb05m02.socopgnum, ws.soctip
                  from dbsmopg
                 where socopgnum = d_ctb05m02.socopgnumc

                if sqlca.sqlcode <> 0   then
                   error " O.P. nao cadastrada!"
                   next field socopgnumc
                end if

                if ws.soctip <> 3 then
                   error " Esta OP nao pertence a pagamento do RE!"
                   next field socopgnumc
                end if

                exit input
             end if

      before field atdsrvnum
             display by name d_ctb05m02.atdsrvnum      attribute (reverse)

      after  field atdsrvnum
             display by name d_ctb05m02.atdsrvnum

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field socopgnumc
             end if

             initialize d_ctb05m02.socopgnum   to null

             if d_ctb05m02.socopgnumc  is null   and
                d_ctb05m02.atdsrvnum   is null   then
                error " Numero da O.P. ou numero da O.S. deve ser informado!"
                next field atdsrvnum
             end if

             if d_ctb05m02.atdsrvnum  is null   then
                initialize d_ctb05m02.atdsrvano   to null
                display by name d_ctb05m02.atdsrvano
                next field socopgnumc
             end if

      before field atdsrvano
             display by name d_ctb05m02.atdsrvano attribute (reverse)

      after  field atdsrvano
             display by name d_ctb05m02.atdsrvano

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdsrvnum
             end if

             if d_ctb05m02.atdsrvano  is null   then
                error " Ano da O.S. deve ser informado!"
                next field atdsrvnum
             end if

             initialize d_ctb05m02.socopgnum to null
             initialize ws.socopgsitcod      to null

             call ctb05m05 (d_ctb05m02.atdsrvnum, d_ctb05m02.atdsrvano)
                  returning d_ctb05m02.socopgnum

             if d_ctb05m02.socopgnum is null  then
                next field atdsrvnum
             end if

             select atdsrvorg
               into ws.atdsrvorg
               from datmservico
              where atdsrvnum = d_ctb05m02.atdsrvnum
                and atdsrvano = d_ctb05m02.atdsrvano

             display by name ws.atdsrvorg

             select soctip
               into ws.soctip
               from dbsmopg
              where socopgnum = d_ctb05m02.socopgnum

             if sqlca.sqlcode <> 0   then
                error " O.P. nao encontrada!"
                next field atdsrvnum
             end if

             if ws.soctip <> 3 then
                error " Este servico nao pertence a pagamento do RE!"
                next field atdsrvnum
             end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   # MONTA DADOS DA O.P.
   #--------------------
   select dbsmopg.pstcoddig      , dbsmopg.corsus,
          dbsmopg.segnumdig      , dbsmopg.pestip,
          dbsmopg.socfatentdat   , dbsmopg.socfatpgtdat,
          dbsmopg.socfatitmqtd   , dbsmopg.socfattotvlr,
          dbsmopg.cgccpfnum      , dbsmopg.cgcord,
          dbsmopg.cgccpfdig      , dbsmopgfav.socpgtopccod,
          dbsmopg.pgtdstcod      , dbsmopg.socopgsitcod,
          dbsmopgfav.socopgfavnom, dbsmopgfav.bcocod,
          dbsmopgfav.bcoagnnum   , dbsmopgfav.bcoagndig,
          dbsmopgfav.bcoctanum   , dbsmopgfav.bcoctadig
     into ws.pstcoddig           , ws.corsus,
          ws.segnumdig           , ws.pestip,
          d_ctb05m02.socfatentdat, d_ctb05m02.socfatpgtdat,
          d_ctb05m02.socfatitmqtd, d_ctb05m02.socfattotvlr,
          d_ctb05m02.cgccpfnum   , d_ctb05m02.cgcord,
          d_ctb05m02.cgccpfdig   , ws.socpgtopccod,
          ws.pgtdstcod           , ws.socopgsitcod,
          d_ctb05m02.socopgfavnom, d_ctb05m02.bcocod,
          d_ctb05m02.bcoagnnum   , d_ctb05m02.bcoagndig,
          d_ctb05m02.bcoctanum   , d_ctb05m02.bcoctadig
     from dbsmopg, outer dbsmopgfav
    where dbsmopg.socopgnum    = d_ctb05m02.socopgnum   and
          dbsmopgfav.socopgnum = dbsmopg.socopgnum

   # BUSCA SITUACAO/FASE ATUAL DA O.P.
   #----------------------------------
   initialize  ws.socopgfascod          to null
   initialize  d_ctb05m02.socopgsitdes  to null
   initialize  d_ctb05m02.socopgfasdes  to null

   select cpodes
     into d_ctb05m02.socopgsitdes
     from iddkdominio
    where iddkdominio.cponom = "socopgsitcod"     and
          iddkdominio.cpocod = ws.socopgsitcod

   if sqlca.sqlcode <> 0    then
      error "Erro (",sqlca.sqlcode,") na leitura da descricao da situacao!"
      sleep 4
   end if

   # PSI 221074 - BURINI
   call cts50g00_sel_max_etapa(d_ctb05m02.socopgnum)
        returning ws.retorno,     
                  ws.mensagem,    
                  ws.socopgfascod
        
   if ws.retorno <> 1    then
      error "Erro (",sqlca.sqlcode,") na leitura da fase da O.P.!"
      sleep 4
   end if

   if ws.socopgfascod  is not null   then
      select cpodes
        into d_ctb05m02.socopgfasdes
        from iddkdominio
       where cponom = "socopgfascod"     and
             cpocod = ws.socopgfascod

      if sqlca.sqlcode <> 0    then
         error "Erro (",sqlca.sqlcode,") na leitura da descricao da fase!"
         sleep 4
      end if
   end if

   case ws.pestip
      when "F" let d_ctb05m02.tippesdes = "FISICA"
      when "J" let d_ctb05m02.tippesdes = "JURIDICA"
   end case

   # BUSCA DESTINO DA O.P.
   #----------------------
   if ws.pgtdstcod  is not null   then
      select pgtdstdes
        into d_ctb05m02.pgtdstdes
        from fpgkpgtdst
       where pgtdstcod = ws.pgtdstcod

      if sqlca.sqlcode <> 0   then
         error "Erro (",sqlca.sqlcode,") na leitura do destino!"
         sleep 4
      end if
   end if

   if d_ctb05m02.bcocod  is not null   then
      select bcosgl
        into d_ctb05m02.bcosgl
        from gcdkbanco
       where gcdkbanco.bcocod = d_ctb05m02.bcocod

      if sqlca.sqlcode <> 0   then
         error "Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
         sleep 4
      end if
   end if

   # MONTA OPCAO DE PAGAMENTO
   #-------------------------
   if ws.socpgtopccod  is not null   then
      select cpodes
        into d_ctb05m02.socpgtopcdes
        from iddkdominio
       where iddkdominio.cponom = "socpgtopccod"     and
             iddkdominio.cpocod = ws.socpgtopccod

      if sqlca.sqlcode <> 0    then
         error "Erro (",sqlca.sqlcode,") na leitura da opcao de pagamento!"
         sleep 4
      end if
   end if

   # MONTA FAVORECIDO DA O.P.
   #-------------------------
   if ws.pstcoddig   is not null    then
      let d_ctb05m02.favtipcod = ws.pstcoddig  using "&&&&&&"
      let d_ctb05m02.favtipcab = "Prestador....:"
      select nomrazsoc
        into d_ctb05m02.favtipnom
        from dpaksocor
       where dpaksocor.pstcoddig = ws.pstcoddig

      if sqlca.sqlcode <> 0    then
         error " Erro (",sqlca.sqlcode,") na leitura do prestador!"
         sleep 4
      end if
   else
     if ws.corsus      is not null    then
        let d_ctb05m02.favtipcod = ws.corsus
        let d_ctb05m02.favtipcab = "Corretor.....:"
        select cornom
          into d_ctb05m02.favtipnom
          from gcaksusep, gcakcorr
         where gcaksusep.corsus     = ws.corsus      and
               gcakcorr.corsuspcp   = gcaksusep.corsuspcp

        if sqlca.sqlcode <> 0    then
           error " Erro (",sqlca.sqlcode,") na leitura do corretor!"
           sleep 4
        end if
     else
       let d_ctb05m02.favtipcod = ws.segnumdig  using  "&&&&&&&&"
       let d_ctb05m02.favtipcab = "Segurado.....:"
       select segnom
         into d_ctb05m02.favtipnom
         from gsakseg
        where gsakseg.segnumdig  =  ws.segnumdig

       if sqlca.sqlcode <> 0    then
          error " Erro (",sqlca.sqlcode,") na leitura do segurado!"
          sleep 4
       end if
     end if
   end if

   display by name d_ctb05m02.*

   display by name d_ctb05m02.socopgnum      attribute(reverse)
   display by name d_ctb05m02.socopgfasdes   attribute(reverse)
   display by name d_ctb05m02.socopgsitdes   attribute(reverse)
   display by name d_ctb05m02.socfatpgtdat   attribute(reverse)
   display by name d_ctb05m02.socpgtopcdes   attribute(reverse)

   prompt " (F17)Abandona" for char prompt_key

   if param.socopgnum   is not null   then
      initialize param.socopgnum  to null
      exit while
   end if

end while

let int_flag = false
close window ctb05m02

end function  ###  ctb05m02
