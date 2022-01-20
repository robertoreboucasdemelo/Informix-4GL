###############################################################################
# Nome do Modulo: CTB12M01                                           Marcelo  #
#                                                                    Gilberto #
# Consulta ordem de pagamento por (numero/ numero de O.S.)           Fev/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 30/05/2000  PSI 10866-9  Wagner       Adaptacao nova numeracao servico.     #
#-----------------------------------------------------------------------------#
# 05/12/2000  PSI 10631-3  Wagner       Consistencia OP Porto-Socorro (soctip)#
#-----------------------------------------------------------------------------#
# 20/03/2008  PSI 221074   Burini       Fases da OP - Registro Responsavel    #
###############################################################################

database porto

#-----------------------------------------------------------
 function ctb12m01(param)
#-----------------------------------------------------------

 define param       record
    socopgnum       like dbsmopg.socopgnum
 end record

 define d_ctb12m01  record
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
    mensagem        char(50)
 end record

 define prompt_key  char (01)

 open window ctb12m01 at 06,02 with form "ctb12m01"
             attribute (form line first)

 while true

   let int_flag = false
   initialize ws.*          to null
   initialize d_ctb12m01.*  to null
   display by name d_ctb12m01.*
   display by name ws.atdsrvorg

   if param.socopgnum  is not null    then
      let d_ctb12m01.socopgnumc = param.socopgnum
      let d_ctb12m01.socopgnum  = param.socopgnum
   end if

   input by name d_ctb12m01.socopgnumc,
                 d_ctb12m01.atdsrvnum,
                 d_ctb12m01.atdsrvano  without defaults

      before field socopgnumc
             if param.socopgnum  is not null    then
                exit input
             end if
             display by name d_ctb12m01.socopgnumc    attribute (reverse)

             initialize d_ctb12m01.atdsrvnum  to null
             initialize d_ctb12m01.atdsrvano  to null
             display by name d_ctb12m01.atdsrvnum
             display by name d_ctb12m01.atdsrvano

      after  field socopgnumc
             display by name d_ctb12m01.socopgnumc

             initialize d_ctb12m01.socopgnum   to null

             if d_ctb12m01.socopgnumc  is not null   then
                select socopgnum, soctip
                  into d_ctb12m01.socopgnum, ws.soctip
                  from dbsmopg
                 where socopgnum = d_ctb12m01.socopgnumc

                if sqlca.sqlcode <> 0   then
                   error " O.P. nao cadastrada!"
                   next field socopgnumc
                end if

                if ws.soctip <> 1 then
                   error " Esta OP nao pertence a pagamento Porto Socorro!"
                   next field socopgnumc
                end if

                exit input
             end if

      before field atdsrvnum
             display by name d_ctb12m01.atdsrvnum      attribute (reverse)

      after  field atdsrvnum
             display by name d_ctb12m01.atdsrvnum

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field socopgnumc
             end if

             initialize d_ctb12m01.socopgnum   to null

             if d_ctb12m01.socopgnumc  is null   and
                d_ctb12m01.atdsrvnum   is null   then
                error " Numero da O.P. ou numero da O.S. deve ser informado!"
                next field atdsrvnum
             end if

             if d_ctb12m01.atdsrvnum  is null   then
                initialize d_ctb12m01.atdsrvano   to null
                display by name d_ctb12m01.atdsrvano
                next field socopgnumc
             end if

      before field atdsrvano
             display by name d_ctb12m01.atdsrvano attribute (reverse)

      after  field atdsrvano
             display by name d_ctb12m01.atdsrvano

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdsrvnum
             end if

             if d_ctb12m01.atdsrvano  is null   then
                error " Ano da O.S. deve ser informado!"
                next field atdsrvnum
             end if

             initialize d_ctb12m01.socopgnum to null
             initialize ws.socopgsitcod      to null

             call ctb12m05 (d_ctb12m01.atdsrvnum, d_ctb12m01.atdsrvano)
                  returning d_ctb12m01.socopgnum

             if d_ctb12m01.socopgnum is null  then
                next field atdsrvnum
             end if

             select atdsrvorg
               into ws.atdsrvorg
               from datmservico
              where atdsrvnum = d_ctb12m01.atdsrvnum
                and atdsrvano = d_ctb12m01.atdsrvano

             display by name ws.atdsrvorg

             select soctip
               into ws.soctip
               from dbsmopg
              where socopgnum = d_ctb12m01.socopgnum

             if sqlca.sqlcode <> 0   then
                error " O.P. nao encontrada!"
                next field atdsrvnum
             end if

             if ws.soctip <> 1 then
                error " Este servico nao pertence a pagamento Porto Socorro!"
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
          d_ctb12m01.socfatentdat, d_ctb12m01.socfatpgtdat,
          d_ctb12m01.socfatitmqtd, d_ctb12m01.socfattotvlr,
          d_ctb12m01.cgccpfnum   , d_ctb12m01.cgcord,
          d_ctb12m01.cgccpfdig   , ws.socpgtopccod,
          ws.pgtdstcod           , ws.socopgsitcod,
          d_ctb12m01.socopgfavnom, d_ctb12m01.bcocod,
          d_ctb12m01.bcoagnnum   , d_ctb12m01.bcoagndig,
          d_ctb12m01.bcoctanum   , d_ctb12m01.bcoctadig
     from dbsmopg, outer dbsmopgfav
    where dbsmopg.socopgnum    = d_ctb12m01.socopgnum   and
          dbsmopgfav.socopgnum = dbsmopg.socopgnum

   # BUSCA SITUACAO/FASE ATUAL DA O.P.
   #----------------------------------
   initialize  ws.socopgfascod          to null
   initialize  d_ctb12m01.socopgsitdes  to null
   initialize  d_ctb12m01.socopgfasdes  to null

   select cpodes
     into d_ctb12m01.socopgsitdes
     from iddkdominio
    where iddkdominio.cponom = "socopgsitcod"     and
          iddkdominio.cpocod = ws.socopgsitcod

   if sqlca.sqlcode <> 0    then
      error "Erro (",sqlca.sqlcode,") na leitura da descricao da situacao!"
      sleep 4
   end if
   
   # PSI 221074 - BURINI
   call cts50g00_sel_max_etapa(d_ctb12m01.socopgnum)
        returning ws.retorno,
                  ws.mensagem,
                  ws.socopgfascod    

   if ws.retorno <> 1    then
      error ws.mensagem
      sleep 4
   end if

   if ws.socopgfascod  is not null   then
      select cpodes
        into d_ctb12m01.socopgfasdes
        from iddkdominio
       where cponom = "socopgfascod"     and
             cpocod = ws.socopgfascod

      if sqlca.sqlcode <> 0    then
         error "Erro (",sqlca.sqlcode,") na leitura da descricao da fase!"
         sleep 4
      end if
   end if

   case ws.pestip
      when "F" let d_ctb12m01.tippesdes = "FISICA"
      when "J" let d_ctb12m01.tippesdes = "JURIDICA"
   end case

   # BUSCA DESTINO DA O.P.
   #----------------------
   if ws.pgtdstcod  is not null   then
      select pgtdstdes
        into d_ctb12m01.pgtdstdes
        from fpgkpgtdst
       where pgtdstcod = ws.pgtdstcod

      if sqlca.sqlcode <> 0   then
         error "Erro (",sqlca.sqlcode,") na leitura do destino!"
         sleep 4
      end if
   end if

   if d_ctb12m01.bcocod  is not null   then
      select bcosgl
        into d_ctb12m01.bcosgl
        from gcdkbanco
       where gcdkbanco.bcocod = d_ctb12m01.bcocod

      if sqlca.sqlcode <> 0   then
         error "Erro (",sqlca.sqlcode,") na leitura do nome do banco!"
         sleep 4
      end if
   end if

   # MONTA OPCAO DE PAGAMENTO
   #-------------------------
   if ws.socpgtopccod  is not null   then
      select cpodes
        into d_ctb12m01.socpgtopcdes
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
      let d_ctb12m01.favtipcod = ws.pstcoddig  using "&&&&&&"
      let d_ctb12m01.favtipcab = "Prestador....:"
      select nomrazsoc
        into d_ctb12m01.favtipnom
        from dpaksocor
       where dpaksocor.pstcoddig = ws.pstcoddig

      if sqlca.sqlcode <> 0    then
         error " Erro (",sqlca.sqlcode,") na leitura do prestador!"
         sleep 4
      end if
   else
     if ws.corsus      is not null    then
        let d_ctb12m01.favtipcod = ws.corsus
        let d_ctb12m01.favtipcab = "Corretor.....:"
        select cornom
          into d_ctb12m01.favtipnom
          from gcaksusep, gcakcorr
         where gcaksusep.corsus     = ws.corsus      and
               gcakcorr.corsuspcp   = gcaksusep.corsuspcp 

        if sqlca.sqlcode <> 0    then
           error " Erro (",sqlca.sqlcode,") na leitura do corretor!"
           sleep 4
        end if
     else
       let d_ctb12m01.favtipcod = ws.segnumdig  using  "&&&&&&&&"
       let d_ctb12m01.favtipcab = "Segurado.....:"
       select segnom
         into d_ctb12m01.favtipnom
         from gsakseg
        where gsakseg.segnumdig  =  ws.segnumdig

       if sqlca.sqlcode <> 0    then
          error " Erro (",sqlca.sqlcode,") na leitura do segurado!"
          sleep 4
       end if
     end if
   end if

   display by name d_ctb12m01.*

   display by name d_ctb12m01.socopgnum      attribute(reverse)
   display by name d_ctb12m01.socopgfasdes   attribute(reverse)
   display by name d_ctb12m01.socopgsitdes   attribute(reverse)
   display by name d_ctb12m01.socfatpgtdat   attribute(reverse)
   display by name d_ctb12m01.socpgtopcdes   attribute(reverse)

   prompt " (F17)Abandona" for char prompt_key

   if param.socopgnum   is not null   then
      initialize param.socopgnum  to null
      exit while
   end if

end while

let int_flag = false
close window ctb12m01

end function  ###  ctb12m01
