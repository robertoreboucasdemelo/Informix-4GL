#############################################################################
# Nome do Modulo: cts19m05                                         Ruiz     #
# Tela do cadastro de lojas                                        Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                         #
#  Analista Resp. : Henrique Pezella                 OSF : 9377             #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 26/11/2002       #
#  Objetivo       : Aprimoramento da clausula 71-Danos aos vidros atraves   #
#                   da clausula 75(contem clausula 71 + espelho retrovisor) #
#---------------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                        #
#                                                                           #
# Data       Autor Fabrica         PSI    Alteracoes                        #
# ---------- --------------------- ------ ----------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias Alterado caminho da global        #
#---------------------------------------------------------------------------#
# 09/05/2012   Silvia        PSI 2012-07408  Anatel - DDD/Telefone          #
#############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define m_cts19m05_prep smallint

 define d_cts19m05 record
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom
 end record

 define a_cts19m05 array[300] of record
        vdrrprempnom like adikvdrrpremp.vdrrprempnom,
        vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        endlgd       like adikvdrrpremp.endlgd     ,
        endlgdnum    like adikvdrrpremp.endlgdnum  ,
        brrnom       like adikvdrrpremp.brrnom   ,
        cidnom       like adikvdrrpremp.cidnom  ,
        ufdcod       like adikvdrrpremp.ufdcod ,
        dddcod       like adikvdrrpremp.dddcod  ,
        teltxt       like adikvdrrpremp.teltxt     ,
        calckm       dec  (8,4),
        horloja      char (52),
        atend        char (05),
        rspnom       like adikvdrrpremp.rspnom,
        faxnum       like adikvdrrpremp.faxnum,
        vdrrprempcod like adikvdrrpremp.vdrrprempcod,
        vdrrprempobs like adikvdrrpremp.vdrrprempobs,
        lclltt       like datmfrtpos.lclltt,
        lcllgt       like datmfrtpos.lcllgt
 end record

 define a_cts19m05b array[300] of record
        vdrrprempnom like adikvdrrpremp.vdrrprempnom,
        vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        endlgd       like adikvdrrpremp.endlgd     ,
        endlgdnum    like adikvdrrpremp.endlgdnum  ,
        brrnom       like adikvdrrpremp.brrnom   ,
        cidnom       like adikvdrrpremp.cidnom  ,
        ufdcod       like adikvdrrpremp.ufdcod ,
        dddcod       like adikvdrrpremp.dddcod  ,
        teltxt       like adikvdrrpremp.teltxt     ,
        calckm       dec  (8,4),
        horloja      char (52),
        atend        char (05),
        rspnom       like adikvdrrpremp.rspnom,
        faxnum       like adikvdrrpremp.faxnum,
        vdrrprempcod like adikvdrrpremp.vdrrprempcod,
        vdrrprempobs like adikvdrrpremp.vdrrprempobs,
        lclltt       like datmfrtpos.lclltt,
        lcllgt       like datmfrtpos.lcllgt
 end record

 define retorno record
        vdrrprempcod like adikvdrrpremp.vdrrprempcod,
        vdrrprempnom like adikvdrrpremp.vdrrprempnom,
        cidnom       like adikvdrrpremp.cidnom  ,
        ufdcod       like adikvdrrpremp.ufdcod ,
        dddcod       like adikvdrrpremp.dddcod  ,
        teltxt       like adikvdrrpremp.teltxt     ,
        vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        horloja      char (52),
        rspnom       like adikvdrrpremp.rspnom,
        segsexinchor like adikvdrrpremp.segsexinchor,
        segsexfnlhor like adikvdrrpremp.segsexfnlhor,
        sabinchor    like adikvdrrpremp.sabinchor,
        sabfnlhor    like adikvdrrpremp.sabfnlhor,
        atntip       like adikvdrrpremp.atntip
 end record

 define ws          record
        vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        vdrrprempnom like adikvdrrpremp.vdrrprempnom,
        vdrrprempcod like adikvdrrpremp.vdrrprempcod,
        endlgd       like adikvdrrpremp.endlgd     ,
        endlgdnum    like adikvdrrpremp.endlgdnum  ,
        brrnom       like adikvdrrpremp.brrnom   ,
        cidnom       like adikvdrrpremp.cidnom  ,
        ufdcod       like adikvdrrpremp.ufdcod ,
        dddcod       like adikvdrrpremp.dddcod  ,
        teltxt       like adikvdrrpremp.teltxt     ,
        segsexinchor like adikvdrrpremp.segsexinchor,
        segsexfnlhor like adikvdrrpremp.segsexfnlhor,
        sabinchor    like adikvdrrpremp.sabinchor,
        sabfnlhor    like adikvdrrpremp.sabfnlhor,
        rspnom       like adikvdrrpremp.rspnom,
        comando      char (800),
        atntip       dec  (1,0),
        vdrrprempstt like adikvdrrpremp.vdrrprempstt,
        confirma     char (01),
        kmpacaembu   dec  (8,4),
        kmmorumbi    dec  (8,4),
        sai          dec  (1,0)
 end record
 define arr_aux       smallint
 define arr_aux1      smallint
 define arr_aux2      smallint
 define arr_aux3      smallint
 define arr_aux4      smallint
 define arr_morumbi   smallint
 define arr_pacaembu  smallint

#main
#
#  call cts19m05(2,
#                "",
#                "",
#                "",
#                "ctg3",
#                "",
#                1311718,
#                6,
#                15023058)
#   returning retorno.*
#
#end main

#-------------------------#
function cts19m05_prepare()
#-------------------------#

  define l_sql char(600)

  let l_sql = " select vdrpbsavrfrqvlr, ",
                     " vdrvgaavrfrqvlr, ",
                     " vdresqavrfrqvlr, ",
                     " vdrdiravrfrqvlr, ",
                     " ocudiravrfrqvlr, ",
                     " ocuesqavrfrqvlr, ",
                     " vdrqbvavrfrqvlr, ",
                     " dirrtravrvlr, ",
                     " esqrtravrvlr, ",
                     " drtfrlvlr, ",
                     " esqfrlvlr, ",
                     " esqmlhfrlvlr, ",
                     " drtmlhfrlvlr, ",
                     " drtnblfrlvlr, ",
                     " esqnblfrlvlr, ",
                     " esqpscvlr, ",
                     " drtpscvlr, ",
                     " drtlntvlr, ",
                     " esqlntvlr  ",
                " from datmsrvext1 ",
               " where atdsrvnum = ? ",
                 " and atdsrvano = ? ",
                 " and lignum = ? "

  prepare p_cts19m05_001 from l_sql
  declare c_cts19m05_001 cursor for p_cts19m05_001

  let l_sql = " select srvprsetbtip ",
                " from sgokofi ",
               " where ofnnumdig = ? "

  prepare p_cts19m05_002 from l_sql
  declare c_cts19m05_002 cursor for p_cts19m05_002

  let l_sql = " select 1 ",
                " from adikvdrrprtip ",
               " where vdrrprgrpcod = ? ",
                 " and vdrrprempcod = ? ",
                 " and vrdrprtip = ? "

  prepare p_cts19m05_003 from l_sql
  declare c_cts19m05_003 cursor for p_cts19m05_003

  let l_sql = "select vdrrprgrpnom   ",
              "    from adikvdrrprgrp ",
              "   where vdrrprgrpcod = ? "

  prepare p_cts19m05_010 from l_sql
  declare c_cts19m05_010 cursor for p_cts19m05_010

  let m_cts19m05_prep = true

end function

#-------------------------------------------#
function cts19m05_itens_servico(lr_parametro)
#-------------------------------------------#

  define lr_parametro    record
         atdsrvnum       like datmsrvext1.atdsrvnum,
         atdsrvano       like datmsrvext1.atdsrvano,
         lignum          like datmsrvext1.lignum,
         vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
         vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
         vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
         vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
         ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
         ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
         vdrqbvavrfrqvlr like datmsrvext1.vdrqbvavrfrqvlr,
         dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
         esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
         drtfrlvlr       like datmsrvext1.drtfrlvlr,
         esqfrlvlr       like datmsrvext1.esqfrlvlr,
         esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
         drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
         drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
         esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
         esqpscvlr       like datmsrvext1.esqpscvlr,
         drtpscvlr       like datmsrvext1.drtpscvlr,
         drtlntvlr       like datmsrvext1.drtlntvlr,
         esqlntvlr       like datmsrvext1.esqlntvlr
  end record

  define lr_tem       record
         vidro        smallint,
         retrovisor   smallint,
         pisca        smallint,
         farol        smallint,
         farolmilha   smallint,
         farolneblina smallint,
         lanterna     smallint
  end record

  define l_status     integer

  initialize lr_tem to null

  let l_status = 0

  #display "PARAMETROS QUE ENTRARAM: cts19m05_itens_servico()"
  #display "atdsrvnum      : ", lr_parametro.atdsrvnum
  #display "atdsrvano      : ", lr_parametro.atdsrvano
  #display "lignum         : ", lr_parametro.lignum
  #display "vdrpbsavrfrqvlr: ", lr_parametro.vdrpbsavrfrqvlr
  #display "vdrvgaavrfrqvlr: ", lr_parametro.vdrvgaavrfrqvlr
  #display "vdresqavrfrqvlr: ", lr_parametro.vdresqavrfrqvlr
  #display "vdrdiravrfrqvlr: ", lr_parametro.vdrdiravrfrqvlr
  #display "ocudiravrfrqvlr: ", lr_parametro.ocudiravrfrqvlr
  #display "ocuesqavrfrqvlr: ", lr_parametro.ocuesqavrfrqvlr
  #display "vdrqbvavrfrqvlr: ", lr_parametro.vdrqbvavrfrqvlr
  #display "dirrtravrvlr   : ", lr_parametro.dirrtravrvlr
  #display "esqrtravrvlr   : ", lr_parametro.esqrtravrvlr
  #display "drtfrlvlr      : ", lr_parametro.drtfrlvlr
  #display "esqfrlvlr      : ", lr_parametro.esqfrlvlr
  #display "esqmlhfrlvlr   : ", lr_parametro.esqmlhfrlvlr
  #display "drtmlhfrlvlr   : ", lr_parametro.drtmlhfrlvlr
  #display "drtnblfrlvlr   : ", lr_parametro.drtnblfrlvlr
  #display "esqnblfrlvlr   : ", lr_parametro.esqnblfrlvlr
  #display "esqpscvlr      : ", lr_parametro.esqpscvlr
  #display "drtpscvlr      : ", lr_parametro.drtpscvlr
  #display "drtlntvlr      : ", lr_parametro.drtlntvlr
  #display "esqlntvlr      : ", lr_parametro.esqlntvlr
  #display " "

  if lr_parametro.atdsrvnum is not null and
     lr_parametro.atdsrvano is not null and
     lr_parametro.lignum    is not null then

     let lr_parametro.vdrpbsavrfrqvlr = null
     let lr_parametro.vdrvgaavrfrqvlr = null
     let lr_parametro.vdresqavrfrqvlr = null
     let lr_parametro.vdrdiravrfrqvlr = null
     let lr_parametro.ocudiravrfrqvlr = null
     let lr_parametro.ocuesqavrfrqvlr = null
     let lr_parametro.vdrqbvavrfrqvlr = null
     let lr_parametro.dirrtravrvlr    = null
     let lr_parametro.esqrtravrvlr    = null
     let lr_parametro.drtfrlvlr       = null
     let lr_parametro.esqfrlvlr       = null
     let lr_parametro.esqmlhfrlvlr    = null
     let lr_parametro.drtmlhfrlvlr    = null
     let lr_parametro.drtnblfrlvlr    = null
     let lr_parametro.esqnblfrlvlr    = null
     let lr_parametro.esqpscvlr       = null
     let lr_parametro.drtpscvlr       = null
     let lr_parametro.drtlntvlr       = null
     let lr_parametro.esqlntvlr       = null

     #------------------------------------------------------
     # BUSCA OS ITENS(VIDROS,RETROVISORES, FAROL) DO SERVICO
     #------------------------------------------------------
     open c_cts19m05_001 using lr_parametro.atdsrvnum,
                             lr_parametro.atdsrvano,
                             lr_parametro.lignum

     fetch c_cts19m05_001 into lr_parametro.vdrpbsavrfrqvlr, # PARA-BRISA
                             lr_parametro.vdrvgaavrfrqvlr, # VIDRO TRASEIRO
                             lr_parametro.vdresqavrfrqvlr, # LATERAL ESQ.
                             lr_parametro.vdrdiravrfrqvlr, # LATERAL DIR.
                             lr_parametro.ocudiravrfrqvlr, # OCULO DIR.
                             lr_parametro.ocuesqavrfrqvlr, # OCULO ESQ.
                             lr_parametro.vdrqbvavrfrqvlr, # QUEBRA VENTO
                             lr_parametro.dirrtravrvlr,    # RETROVISOR DIR.
                             lr_parametro.esqrtravrvlr,    # RETROVISOR ESQ.
                             lr_parametro.drtfrlvlr,       # FAROL DIR.
                             lr_parametro.esqfrlvlr,       # FAROL ESQ.
                             lr_parametro.esqmlhfrlvlr,    # FAROL MILHA ESQ.
                             lr_parametro.drtmlhfrlvlr,    # FAROL MILHA DIR.
                             lr_parametro.drtnblfrlvlr,    # FAROL NEBLINA DIR.
                             lr_parametro.esqnblfrlvlr,    # FAROL NEBLINA ESQ.
                             lr_parametro.esqpscvlr,       # PISCA ESQ.
                             lr_parametro.drtpscvlr,       # PISCA DIR.
                             lr_parametro.drtlntvlr,       # LANTERNA DIR.
                             lr_parametro.esqlntvlr        # LANTERNA ESQ.

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           error "SERVICO NAO ENCONTRADO(CTS19M05). AVISE A INFORMATICA !" sleep 5
        else
           error "Erro SELECT c_cts19m05_001 ", sqlca.sqlcode, "/", sqlca.sqlerrd[2]
           error "cts19m05_itens_srv() / ", lr_parametro.atdsrvnum, "/",
                                            lr_parametro.atdsrvano, "/",
                                            lr_parametro.lignum sleep 5
        end if
     end if

     let l_status = sqlca.sqlcode

     close c_cts19m05_001
  end if

   #display "PARAMETROS APOS BUSCA"
   #display "atdsrvnum      : ", lr_parametro.atdsrvnum
   #display "atdsrvano      : ", lr_parametro.atdsrvano
   #display "lignum         : ", lr_parametro.lignum
   #display "vdrpbsavrfrqvlr: ", lr_parametro.vdrpbsavrfrqvlr
   #display "vdrvgaavrfrqvlr: ", lr_parametro.vdrvgaavrfrqvlr
   #display "vdresqavrfrqvlr: ", lr_parametro.vdresqavrfrqvlr
   #display "vdrdiravrfrqvlr: ", lr_parametro.vdrdiravrfrqvlr
   #display "ocudiravrfrqvlr: ", lr_parametro.ocudiravrfrqvlr
   #display "ocuesqavrfrqvlr: ", lr_parametro.ocuesqavrfrqvlr
   #display "vdrqbvavrfrqvlr: ", lr_parametro.vdrqbvavrfrqvlr
   #display "dirrtravrvlr   : ", lr_parametro.dirrtravrvlr
   #display "esqrtravrvlr   : ", lr_parametro.esqrtravrvlr
   #display "drtfrlvlr      : ", lr_parametro.drtfrlvlr
   #display "esqfrlvlr      : ", lr_parametro.esqfrlvlr
   #display "esqmlhfrlvlr   : ", lr_parametro.esqmlhfrlvlr
   #display "drtmlhfrlvlr   : ", lr_parametro.drtmlhfrlvlr
   #display "drtnblfrlvlr   : ", lr_parametro.drtnblfrlvlr
   #display "esqnblfrlvlr   : ", lr_parametro.esqnblfrlvlr
   #display "esqpscvlr      : ", lr_parametro.esqpscvlr
   #display "drtpscvlr      : ", lr_parametro.drtpscvlr
   #display "drtlntvlr      : ", lr_parametro.drtlntvlr
   #display "esqlntvlr      : ", lr_parametro.esqlntvlr
   #display " "

  #display "l_status: ", l_status

  if lr_parametro.drtfrlvlr       <= 0 then
     let lr_parametro.drtfrlvlr = null
  end if

  if lr_parametro.esqfrlvlr       <= 0 then
     let lr_parametro.esqfrlvlr = null
  end if

  if lr_parametro.esqmlhfrlvlr    <= 0 then
     let lr_parametro.esqmlhfrlvlr = null
  end if

  if lr_parametro.drtmlhfrlvlr    <= 0 then
     let lr_parametro.drtmlhfrlvlr = null
  end if

  if lr_parametro.drtnblfrlvlr    <= 0 then
     let lr_parametro.drtnblfrlvlr = null
  end if

  if lr_parametro.esqnblfrlvlr    <= 0 then
     let lr_parametro.esqnblfrlvlr = null
  end if

  if lr_parametro.esqpscvlr       <= 0 then
     let lr_parametro.esqpscvlr = null
  end if

  if lr_parametro.drtpscvlr       <= 0 then
     let lr_parametro.drtpscvlr = null
  end if

  if lr_parametro.drtlntvlr       <= 0 then
     let lr_parametro.drtlntvlr = null
  end if

  if lr_parametro.esqlntvlr       <= 0 then
     let lr_parametro.esqlntvlr = null
  end if

  if l_status = 0 then
     #-----------------------------------------------------------
     # VERIFICA OS ITENS(VIDROS,RETROVISORES, FAROL) SELECIONADOS
     #-----------------------------------------------------------
     if lr_parametro.vdrpbsavrfrqvlr is not null or   # PARA-BRISA
        lr_parametro.vdrvgaavrfrqvlr is not null or   # VIDRO TRASEIRO
        lr_parametro.vdresqavrfrqvlr is not null or   # LATERAL ESQ.
        lr_parametro.vdrdiravrfrqvlr is not null or   # LATERAL DIR.
        lr_parametro.ocudiravrfrqvlr is not null or   # OCULO DIR.
        lr_parametro.ocuesqavrfrqvlr is not null or   # OCULO ESQ.
        lr_parametro.vdrqbvavrfrqvlr is not null then # QUEBRA VENTO
        let lr_tem.vidro = 1
     end if

     if lr_parametro.dirrtravrvlr is not null or   # RETROVISOR DIR.
        lr_parametro.esqrtravrvlr is not null then # RETROVISOR ESQ.
        let lr_tem.retrovisor = 2
     end if

     if lr_parametro.drtfrlvlr is not null or   # FAROL DIR.
        lr_parametro.esqfrlvlr is not null then # FAROL ESQ.
        let lr_tem.farol = 4
     end if

     if lr_parametro.esqmlhfrlvlr is not null or   # FAROL MILHA ESQ.
        lr_parametro.drtmlhfrlvlr is not null then # FAROL MILHA DIR.
        let lr_tem.farolmilha = 5
     end if

     if lr_parametro.drtnblfrlvlr is not null or   # FAROL NEBLINA DIR.
        lr_parametro.esqnblfrlvlr is not null then # FAROL NEBLINA ESQ.
        let lr_tem.farolneblina = 6
     end if

     if lr_parametro.esqpscvlr is not null or   # PISCA ESQ.
        lr_parametro.drtpscvlr is not null then # PISCA DIR.
        let lr_tem.pisca = 3
     end if

     if lr_parametro.drtlntvlr is not null or   # LANTERNA DIR.
        lr_parametro.esqlntvlr is not null then # LANTERNA ESQ.
        let lr_tem.lanterna = 7
     end if

  end if

   #display "lr_tem.vidro,      : ", lr_tem.vidro
   #display "lr_tem.retrovisor, : ", lr_tem.retrovisor
   #display "lr_tem.pisca,      : ", lr_tem.pisca
   #display "lr_tem.farol,      : ", lr_tem.farol
   #display "lr_tem.farolmilha, : ", lr_tem.farolmilha
   #display "lr_tem.farolneblina: ", lr_tem.farolneblina
   #display "lr_tem.lanterna    : ", lr_tem.lanterna

  return l_status,
         lr_tem.vidro,
         lr_tem.retrovisor,
         lr_tem.pisca,
         lr_tem.farol,
         lr_tem.farolmilha,
         lr_tem.farolneblina,
         lr_tem.lanterna

end function

#--------------------------------------#
function cts19m05_temp_table(l_operacao)
#--------------------------------------#

  define l_operacao smallint, # 1->CRIA TEMPORARIA  2->APAGA TEMPORARIA
         l_status   integer,
         l_sql      char(800)

  let l_status = null
  let l_sql    = null

  if l_operacao = 1 then
     whenever error continue
     create temp table tmp_oficinas
      (vdrrprempnom char(40),
       vdrrprgrpcod smallint,
       vdrrprgrpnom char(30),
       endlgd       char(40),
       endlgdnum    integer,
       brrnom       char(40),
       cidnom       char(45),
       ufdcod       char(02),
       dddcod       char(04),
       teltxt       char(40),
       calckm       decimal(8,4),
       horloja      char(52),
       atend        char(05),
       rspnom       char(40),
       faxnum       decimal(10,0), ## Anatel - decimal(8,0),
       vdrrprempcod smallint,
       vdrrprempobs char(80),
       lclltt       decimal(8,6),
       lcllgt       decimal(9,6),
       flglojofi    smallint) with no log
     whenever error stop

     if sqlca.sqlcode <> 0 then
        error "Erro: ", sqlca.sqlcode, " CREATE TEMP TABLE. MODULO: cts19m05.4gl" sleep 5
     else
        whenever error continue
        create index idx_oficina on tmp_oficinas(flglojofi, calckm)
        whenever error stop

        if sqlca.sqlcode <> 0 then
           error "Erro: ", sqlca.sqlcode, " CREATE INDEX. MODULO: cts19m05.4gl" sleep 5
        end if

     end if

     let l_status = sqlca.sqlcode

     if l_status = 0 then
       let l_sql = " select vdrrprempnom, ",
                          " vdrrprgrpcod, ",
                          " vdrrprgrpnom, ",
                          " endlgd, ",
                          " endlgdnum, ",
                          " brrnom, ",
                          " cidnom, ",
                          " ufdcod, ",
                          " dddcod, ",
                          " teltxt, ",
                          " calckm, ",
                          " horloja, ",
                          " atend, ",
                          " rspnom, ",
                          " faxnum, ",
                          " vdrrprempcod, ",
                          " vdrrprempobs, ",
                          " lclltt, ",
                          " lcllgt, ",
                          " flglojofi ",
                     " from tmp_oficinas ",
                    " order by calckm "

       prepare p_cts19m05_004 from l_sql
       declare c_cts19m05_004 cursor for p_cts19m05_004

       let l_sql = " insert into tmp_oficinas ",
                              " (vdrrprempnom, ",
                               " vdrrprgrpcod, ",
                               " vdrrprgrpnom, ",
                               " endlgd, ",
                               " endlgdnum, ",
                               " brrnom, ",
                               " cidnom, ",
                               " ufdcod, ",
                               " dddcod, ",
                               " teltxt, ",
                               " calckm, ",
                               " horloja, ",
                               " atend, ",
                               " rspnom, ",
                               " faxnum, ",
                               " vdrrprempcod, ",
                               " vdrrprempobs, ",
                               " lclltt, ",
                               " lcllgt, ",
                               " flglojofi) ",
                        " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) "

       prepare p_cts19m05_005 from l_sql

     end if

  else
     whenever error continue
     drop table tmp_oficinas
     whenever error stop

     if sqlca.sqlcode <> 0 then
        error "Erro: ", sqlca.sqlcode, " DROP TABLE. MODULO: cts19m05.4gl" sleep 5
     end if

     let l_status = sqlca.sqlcode

  end if

  return l_status

end function

#-----------------------#
 function cts19m05(param)
#-----------------------#

    define param           record
           vdrrprgrpcod    like adikvdrrprgrp.vdrrprgrpcod,
           vdrrprempcod    like adikvdrrpremp.vdrrprempcod,
           lclltt          like datmlcl.lclltt          ,
           lcllgt          like datmlcl.lcllgt          ,
           tela            char(04)                     ,
           alerta          char(01),
           atdsrvnum       like datmsrvext1.atdsrvnum,
           atdsrvano       like datmsrvext1.atdsrvano,
           lignum          like datmsrvext1.lignum,
           vdrpbsavrfrqvlr like datmsrvext1.vdrpbsavrfrqvlr,
           vdrvgaavrfrqvlr like datmsrvext1.vdrvgaavrfrqvlr,
           vdresqavrfrqvlr like datmsrvext1.vdresqavrfrqvlr,
           vdrdiravrfrqvlr like datmsrvext1.vdrdiravrfrqvlr,
           ocudiravrfrqvlr like datmsrvext1.ocudiravrfrqvlr,
           ocuesqavrfrqvlr like datmsrvext1.ocuesqavrfrqvlr,
           vdrqbvavrfrqvlr like datmsrvext1.vdrqbvavrfrqvlr,
           dirrtravrvlr    like datmsrvext1.dirrtravrvlr,
           esqrtravrvlr    like datmsrvext1.esqrtravrvlr,
           drtfrlvlr       like datmsrvext1.drtfrlvlr,
           esqfrlvlr       like datmsrvext1.esqfrlvlr,
           esqmlhfrlvlr    like datmsrvext1.esqmlhfrlvlr,
           drtmlhfrlvlr    like datmsrvext1.drtmlhfrlvlr,
           drtnblfrlvlr    like datmsrvext1.drtnblfrlvlr,
           esqnblfrlvlr    like datmsrvext1.esqnblfrlvlr,
           esqpscvlr       like datmsrvext1.esqpscvlr,
           drtpscvlr       like datmsrvext1.drtpscvlr,
           drtlntvlr       like datmsrvext1.drtlntvlr,
           esqlntvlr       like datmsrvext1.esqlntvlr
    end record

    define l_perimetro    decimal(8,4) ## Alberto
    define l_rede         integer    ## Alberto
    define l_msg1         char(30),
           l_msg2         char(30)

    define l_atendimento  integer,
           l_status       integer,
           l_sql_itens    char(100)


    define scr_aux     smallint
    define prompt_key char (01)

    define a_cts19m05b array[300] of record
        vdrrprempnom like adikvdrrpremp.vdrrprempnom,
        vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        endlgd       like adikvdrrpremp.endlgd     ,
        endlgdnum    like adikvdrrpremp.endlgdnum  ,
        brrnom       like adikvdrrpremp.brrnom   ,
        cidnom       like adikvdrrpremp.cidnom  ,
        ufdcod       like adikvdrrpremp.ufdcod ,
        dddcod       like adikvdrrpremp.dddcod  ,
        teltxt       like adikvdrrpremp.teltxt     ,
        calckm       dec  (8,4),
        horloja      char (52),
        atend        char (05),
        rspnom       like adikvdrrpremp.rspnom,
        faxnum       like adikvdrrpremp.faxnum,
        vdrrprempcod like adikvdrrpremp.vdrrprempcod,
        vdrrprempobs like adikvdrrpremp.vdrrprempobs,
        lclltt       like datmfrtpos.lclltt,
        lcllgt       like datmfrtpos.lcllgt
 end record

 define lr_tem       record
        vidro        smallint,
        retrovisor   smallint,
        pisca        smallint,
        farol        smallint,
        farolmilha   smallint,
        farolneblina smallint,
        lanterna     smallint
 end record

  define lr_cts19m05b record
        vdrrprempnom like adikvdrrpremp.vdrrprempnom,
        vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
        vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom,
        endlgd       like adikvdrrpremp.endlgd,
        endlgdnum    like adikvdrrpremp.endlgdnum,
        brrnom       like adikvdrrpremp.brrnom,
        cidnom       like adikvdrrpremp.cidnom,
        ufdcod       like adikvdrrpremp.ufdcod,
        dddcod       like adikvdrrpremp.dddcod,
        teltxt       like adikvdrrpremp.teltxt,
        calckm       decimal(8,4),
        horloja      char(52),
        atend        char(05),
        rspnom       like adikvdrrpremp.rspnom,
        faxnum       like adikvdrrpremp.faxnum,
        vdrrprempcod like adikvdrrpremp.vdrrprempcod,
        vdrrprempobs like adikvdrrpremp.vdrrprempobs,
        lclltt       like datmfrtpos.lclltt,
        lcllgt       like datmfrtpos.lcllgt
  end record

  define lr_limite record
         perimetro decimal(4,0),
         vidro     decimal(3,0),
         retro     decimal(3,0),
         farol     decimal(3,0)
  end record

  define l_ofnnumdig    like adikvdrrpremp.ofnnumdig,
         l_srvprsetbtip like sgokofi.srvprsetbtip,
         l_flgtipatend  smallint

 define l_vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod
       ,l_vdrrprgrpnom like adikvdrrprgrp.vdrrprgrpnom




    if m_cts19m05_prep is null or
       m_cts19m05_prep <> true then
       call cts19m05_prepare()
    end if

    let l_perimetro    = 0      ## Alberto
    let l_rede         = 0      ## Alberto
    let l_atendimento  = 1      ## Alberto
    let l_msg1         = null   ## Alberto
    let l_msg2         = null   ## Alberto
    let l_status       = null
    let l_sql_itens    = null
    let l_ofnnumdig    = null
    let l_srvprsetbtip = null

    if g_vdr_blindado = "S" then ## PSI 239.339 Clausula 77
       let l_atendimento  = 2
       let l_msg1 = "NA REDE,"
       let l_msg2 = "ATENDIMENTO SERA FORA DA REDE."
    end if

    let scr_aux        = null
    let prompt_key     = null
    let l_flgtipatend  = false

    initialize ws.*         to null
    initialize a_cts19m05   to null
    initialize a_cts19m05b  to null
    initialize lr_cts19m05b to null
    initialize lr_tem       to null

    let arr_aux  = 1

    # FUNCAO PARA OBTER OS LIMITES MAXIMOS DE UTILIZACAO DE CADA ITEM
    # (VIDROS, RETROVISORES E FAROIS) E O PERIMETRO
    initialize lr_limite to null
    call fsgoc365()
         returning lr_limite.perimetro,
                   lr_limite.vidro,
                   lr_limite.retro,
                   lr_limite.farol

    if lr_limite.perimetro is null then
       error "ERRO NA PARAMETRIZACAO DO PERIMETRO. MODULO CTS19M05 ! " sleep 5
       return "","","","","","","",
              "","","","","","","",""
    end if

    let l_perimetro = lr_limite.perimetro

    ##display "FUNCAO CTS19M05"
    ##display "param.vdrrprgrpcod   : ", param.vdrrprgrpcod
    ##display "param.vdrrprempcod   : ", param.vdrrprempcod
    ##display "param.lclltt         : ", param.lclltt
    ##display "param.lcllgt         : ", param.lcllgt
    ##display "param.tela           : ", param.tela
    ##display "param.alerta         : ", param.alerta
    ##display "param.atdsrvnum      : ", param.atdsrvnum
    ##display "param.atdsrvano      : ", param.atdsrvano
    ##display "param.lignum         : ", param.lignum
    ##display "param.vdrpbsavrfrqvlr: ", param.vdrpbsavrfrqvlr
    ##display "param.vdrvgaavrfrqvlr: ", param.vdrvgaavrfrqvlr
    ##display "param.vdresqavrfrqvlr: ", param.vdresqavrfrqvlr
    ##display "param.vdrdiravrfrqvlr: ", param.vdrdiravrfrqvlr
    ##display "param.ocudiravrfrqvlr: ", param.ocudiravrfrqvlr
    ##display "param.ocuesqavrfrqvlr: ", param.ocuesqavrfrqvlr
    ##display "param.vdrqbvavrfrqvlr: ", param.vdrqbvavrfrqvlr
    ##display "param.dirrtravrvlr   : ", param.dirrtravrvlr
    ##display "param.esqrtravrvlr   : ", param.esqrtravrvlr
    ##display "param.drtfrlvlr      : ", param.drtfrlvlr
    ##display "param.esqfrlvlr      : ", param.esqfrlvlr
    ##display "param.esqmlhfrlvlr   : ", param.esqmlhfrlvlr
    ##display "param.drtmlhfrlvlr   : ", param.drtmlhfrlvlr
    ##display "param.drtnblfrlvlr   : ", param.drtnblfrlvlr
    ##display "param.esqnblfrlvlr   : ", param.esqnblfrlvlr
    ##display "param.esqpscvlr      : ", param.esqpscvlr
    ##display "param.drtpscvlr      : ", param.drtpscvlr
    ##display "param.drtlntvlr      : ", param.drtlntvlr
    ##display "param.esqlntvlr      : ", param.esqlntvlr

    if param.vdrrprempcod is not null then

       call cts19m05_consulta(param.vdrrprgrpcod,
                              param.vdrrprempcod,
                              param.lclltt,
                              param.lcllgt,
                              param.tela,
                              param.alerta)

       if retorno.segsexinchor = "00:00" and
          retorno.segsexfnlhor = "00:00" and
          retorno.sabinchor    = "00:00" and
          retorno.sabfnlhor    = "00:00" then
          let retorno.segsexinchor = ws.segsexinchor
          let retorno.segsexfnlhor = ws.segsexfnlhor
          let retorno.sabinchor    = ws.sabinchor
          let retorno.sabfnlhor    = ws.sabfnlhor
       end if
       return retorno.*
    end if

    if param.tela = "ctg3" then

       let param.vdrpbsavrfrqvlr = null
       let param.vdrvgaavrfrqvlr = null
       let param.vdrdiravrfrqvlr = null
       let param.ocudiravrfrqvlr = null
       let param.vdrqbvavrfrqvlr = null
       let param.dirrtravrvlr    = null
       let param.drtfrlvlr       = null
       let param.drtmlhfrlvlr    = null
       let param.drtnblfrlvlr    = null
       let param.drtpscvlr       = null
       let param.drtlntvlr       = null

       call cts19m05_inf_itens()
            returning param.vdrpbsavrfrqvlr,
                      param.vdrvgaavrfrqvlr,
                      param.vdrdiravrfrqvlr,
                      param.ocudiravrfrqvlr,
                      param.vdrqbvavrfrqvlr,
                      param.dirrtravrvlr,
                      param.drtfrlvlr,
                      param.drtmlhfrlvlr,
                      param.drtnblfrlvlr,
                      param.drtpscvlr,
                      param.drtlntvlr

       if param.vdrpbsavrfrqvlr is null and
          param.vdrvgaavrfrqvlr is null and
          param.vdrdiravrfrqvlr is null and
          param.ocudiravrfrqvlr is null and
          param.vdrqbvavrfrqvlr is null and
          param.dirrtravrvlr    is null and
          param.drtfrlvlr       is null and
          param.drtmlhfrlvlr    is null and
          param.drtnblfrlvlr    is null and
          param.drtpscvlr       is null and
          param.drtlntvlr       is null then
          error "Nenhum item selecionado. Pesquisa cancelada !" sleep 3
          return "","","","","","","",
                 "","","","","","","",""
       end if
    end if


    # BUSCA OS ITENS DO SERVICO
    call cts19m05_itens_servico(param.atdsrvnum,
                                param.atdsrvano,
                                param.lignum,
                                param.vdrpbsavrfrqvlr,
                                param.vdrvgaavrfrqvlr,
                                param.vdresqavrfrqvlr,
                                param.vdrdiravrfrqvlr,
                                param.ocudiravrfrqvlr,
                                param.ocuesqavrfrqvlr,
                                param.vdrqbvavrfrqvlr,
                                param.dirrtravrvlr,
                                param.esqrtravrvlr,
                                param.drtfrlvlr,
                                param.esqfrlvlr,
                                param.esqmlhfrlvlr,
                                param.drtmlhfrlvlr,
                                param.drtnblfrlvlr,
                                param.esqnblfrlvlr,
                                param.esqpscvlr,
                                param.drtpscvlr,
                                param.drtlntvlr,
                                param.esqlntvlr)

         returning l_status,
                   lr_tem.vidro,
                   lr_tem.retrovisor,
                   lr_tem.pisca,
                   lr_tem.farol,
                   lr_tem.farolmilha,
                   lr_tem.farolneblina,
                   lr_tem.lanterna

    ##display "l_status,          : ", l_status
    ##display "lr_tem.vidro,      : ", lr_tem.vidro
    ##display "lr_tem.retrovisor, : ", lr_tem.retrovisor
    ##display "lr_tem.pisca,      : ", lr_tem.pisca
    ##display "lr_tem.farol,      : ", lr_tem.farol
    ##display "lr_tem.farolmilha, : ", lr_tem.farolmilha
    ##display "lr_tem.farolneblina: ", lr_tem.farolneblina
    ##display "lr_tem.lanterna    : ", lr_tem.lanterna

    if l_status <> 0 then
       return "","","","","","","",
              "","","","","","","",""
    end if

    let ws.comando = "select vdrrprempnom, endlgd, endlgdnum   ,",
                           " brrnom      , cidnom, ",
                           " ufdcod      , dddcod, ",
                           " teltxt      , faxnum, segsexinchor,",
                           " segsexfnlhor, sabinchor,",
                           " sabfnlhor   , rspnom      , atntip      ,",
                           " vdrrprempcod, vdrrprgrpcod, lclltt,lcllgt, ",
                           " vdrrprempstt, vdrrprempobs, ofnnumdig ",
                     "  from adikvdrrpremp ",
                     " where vdrrprgrpcod >= ? "

    prepare p_cts19m05_006 from ws.comando
    declare c_cts19m05_005 cursor for p_cts19m05_006

    open window w_cts19m05 at 07,02 with form "cts19m05"
      attribute(form line 1, border)

    if param.vdrrprgrpcod is null then
       let ws.vdrrprgrpcod = 0
    else
       let ws.vdrrprgrpcod = param.vdrrprgrpcod
    end if

    ## Alberto
    let l_rede = 0

    # CRIA A TABELA TEMPORARIA
    call cts19m05_temp_table(1)
         returning l_status

    if l_status <> 0 then
       return
    end if

    while l_atendimento <= 2

       # REMOVER
       #if l_atendimento = 1 then
       #   error "VAI PESQUISAR NA REDE" sleep 2
       #else
       #   error "VAI PESQUISAR FORA DA REDE" sleep 2
       #end if

       # REMOVER
       #error "GRUPO UTILIZADO: ", ws.vdrrprgrpcod sleep 2

       open c_cts19m05_005 using ws.vdrrprgrpcod
       foreach c_cts19m05_005 into lr_cts19m05b.vdrrprempnom,
                                   lr_cts19m05b.endlgd,
                                   lr_cts19m05b.endlgdnum,
                                   lr_cts19m05b.brrnom,
                                   lr_cts19m05b.cidnom,
                                   lr_cts19m05b.ufdcod,
                                   lr_cts19m05b.dddcod,
                                   lr_cts19m05b.teltxt,
                                   lr_cts19m05b.faxnum,
                                   ws.segsexinchor,
                                   ws.segsexfnlhor,
                                   ws.sabinchor,
                                   ws.sabfnlhor,
                                   lr_cts19m05b.rspnom,
                                   ws.atntip,
                                   lr_cts19m05b.vdrrprempcod,
                                   lr_cts19m05b.vdrrprgrpcod,
                                   lr_cts19m05b.lclltt,
                                   lr_cts19m05b.lcllgt,
                                   ws.vdrrprempstt,
                                   lr_cts19m05b.vdrrprempobs,
                                   l_ofnnumdig

          #-----------------------------------------------
          # VERIFICA SE A LOJA ATENDE O SERVICO SOLICITADO
          #-----------------------------------------------
          if lr_tem.vidro is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.vidro) then
                # REMOVER
                #display "DESPREZOU POIS NAO ATENDE VIDRO"
                continue foreach
             end if
          end if

          if lr_tem.retrovisor is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.retrovisor) then
                 # REMOVER
                 # display "DESPREZOU POIS NAO ATENDE RETRO"
                continue foreach
             end if
          end if

          if lr_tem.pisca is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.pisca) then
                 # REMOVER
                 # display "DESPREZOU POIS NAO ATENDE PISCA"
                continue foreach
             end if
          end if

          if lr_tem.farol is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.farol) then

                # REMOVER
                # display "DESPREZOU POIS NAO ATENDE FAROL"
                continue foreach
             end if
          end if

          if lr_tem.farolmilha is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.farolmilha) then
                # REMOVER
                #display "DESPREZOU POIS NAO ATENDE FAROL MILHA"

                continue foreach
             end if
          end if

          if lr_tem.farolneblina is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.farolneblina) then
                 # REMOVER
                 # display "DESPREZOU POIS NAO ATENDE FAROL NEBLINA"
                continue foreach
             end if
          end if

          if lr_tem.lanterna is not null then
             if not cts19m05_atende_item(lr_cts19m05b.vdrrprgrpcod,
                                         lr_cts19m05b.vdrrprempcod,
                                         lr_tem.lanterna) then
                 # REMOVER
                 # display "DESPREZOU POIS NAO ATENDE LANTERNA"

                continue foreach
             end if
          end if

          if ws.vdrrprempstt <> "A"  then
              # REMOVER
              #display "DESPREZOU POIS NAO ESTA ATIVA"

             continue foreach
          end if

          if l_atendimento <> ws.atntip then
              # REMOVER
              #display "DESPREZOU POIS TIPO ATYENDIMENTO DIFERE. DO TIPO PESQUISADO"

             continue foreach
          end if

          if lr_cts19m05b.lclltt is null or
             lr_cts19m05b.lcllgt is null then

              # REMOVER
              #display "DESPREZOU POIS LAT. LONG. NULAS"

             continue foreach
          end if

          if lr_cts19m05b.vdrrprgrpcod = 1  and
             g_esprtrflg = "S" then

              # REMOVER
              #display "DESPREZOU POIS GRUPO 1 e  g_esprtrflg = 'S'"

             continue foreach
          end if


          if l_vdrrprgrpcod = lr_cts19m05b.vdrrprgrpcod then
             let  lr_cts19m05b.vdrrprgrpnom = l_vdrrprgrpnom
          else

              whenever error continue
              open c_cts19m05_010 using lr_cts19m05b.vdrrprgrpcod
              fetch c_cts19m05_010 into lr_cts19m05b.vdrrprgrpnom
              whenever error stop

              let l_vdrrprgrpcod = lr_cts19m05b.vdrrprgrpcod
              let l_vdrrprgrpnom = lr_cts19m05b.vdrrprgrpnom


          end if

          if sqlca.sqlcode = notfound then
             let lr_cts19m05b.vdrrprgrpnom = "Prestador nao existe"
          end if

          let lr_cts19m05b.horloja = "seg a sex das ",
                                      ws.segsexinchor,
                                      " as ",
                                      ws.segsexfnlhor,
                                      " sab das ",
                                      ws.sabinchor,
                                      " as ",
                                      ws.sabfnlhor

            # qualquer alteracao neste campo, horloja, verificar o f8. ruiz

          if ws.atntip  =  1  then
             let lr_cts19m05b.atend = "REDE"
          else
             if ws.atntip = 2 then
                let lr_cts19m05b.atend = "FORA DA REDE"
             else
                if ws.atntip = 3 then
                   let lr_cts19m05b.atend = "AMBOS"
                end if
             end if
          end if

          #---------------------------------------------------------------
          # Calcula distancia entre local do servico e local do veiculo
          #---------------------------------------------------------------
          let lr_cts19m05b.calckm = null

          call cts18g00(param.lclltt,
                        param.lcllgt,
                        lr_cts19m05b.lclltt,
                        lr_cts19m05b.lcllgt)

              returning lr_cts19m05b.calckm

             if l_flgtipatend = false then
                if l_atendimento = 1 then #  PESQUISA NA REDE

                   if l_perimetro < lr_cts19m05b.calckm then
                     # REMOVER
                     #display "DESPREZOU POR PERIMETRO"
                     continue foreach
                   end if

                end if

             end if

          # VERIFICA SE A LOJA E OFICINA/LOJA OU SOMENTE LOJA
          if l_ofnnumdig is not null then
             let l_srvprsetbtip = null
             open c_cts19m05_002 using l_ofnnumdig
             fetch c_cts19m05_002 into l_srvprsetbtip # 2 = SOMENTE LOJA  3 = OFICINA/LOJA

             if l_srvprsetbtip is null then
                # REMOVER
                #display "DESPREZOU POIS NAO ENCONTROU l_srvprsetbtip"

                close c_cts19m05_002
                continue foreach
             end if

             close c_cts19m05_002
          else

             # REMOVER
             #display "DESPREZOU POIS NAO ENCONTROU OFNNUMDIG"
             continue foreach
          end if

          whenever error continue
          execute p_cts19m05_005 using lr_cts19m05b.vdrrprempnom,
                                     lr_cts19m05b.vdrrprgrpcod,
                                     lr_cts19m05b.vdrrprgrpnom,
                                     lr_cts19m05b.endlgd,
                                     lr_cts19m05b.endlgdnum,
                                     lr_cts19m05b.brrnom,
                                     lr_cts19m05b.cidnom,
                                     lr_cts19m05b.ufdcod,
                                     lr_cts19m05b.dddcod,
                                     lr_cts19m05b.teltxt,
                                     lr_cts19m05b.calckm,
                                     lr_cts19m05b.horloja,
                                     lr_cts19m05b.atend,
                                     lr_cts19m05b.rspnom,
                                     lr_cts19m05b.faxnum,
                                     lr_cts19m05b.vdrrprempcod,
                                     lr_cts19m05b.vdrrprempobs,
                                     lr_cts19m05b.lclltt,
                                     lr_cts19m05b.lcllgt,
                                     l_srvprsetbtip

          whenever error stop

          if sqlca.sqlcode <> 0 then
             error "Erro INSERT p_cts19m05_005 / ", sqlca.sqlcode, "/", sqlca.sqlerrd[2] sleep 5
             exit foreach
          end if

          let arr_aux = arr_aux + 1
          let l_rede  = l_rede  + 1

          if arr_aux > 300   then
             error "Limite excedido. Pesquisa com mais de 300 lojas!"
             exit foreach
          end if

       end foreach

       if l_flgtipatend = true then
          exit while
       end if

       #display "arr_aux: ", l_rede
       #display "l_rede: ", l_rede

       if arr_aux = 1 or
          arr_aux = 2 then ## PSI 239.339 Clausula 77
          if l_rede = 0 then
             if l_atendimento = 1 then ## Nao tem na rede, ira pesquisar fora da rede
                let l_msg1 = "NA REDE,"
                let l_msg2 = "ATENDIMENTO SERA FORA DA REDE."

                ##display "ANTES DE DAR A MENSAGEM - TELA DO FILTRO"
                ##display "lr_tem.pisca: ",        lr_tem.pisca
                ##display "lr_tem.farol: ",        lr_tem.farol
                ##display "lr_tem.farolmilha: ",   lr_tem.farolmilha
                ##display "lr_tem.farolneblina: ", lr_tem.farolneblina
                ##display "lr_tem.lanterna: ",     lr_tem.lanterna
                ##display ""

                # VERIFICA SE TEM ALGUM FAROL ESCOLHIDO
                if lr_tem.pisca        is not null or
                   lr_tem.farol        is not null or
                   lr_tem.farolmilha   is not null or
                   lr_tem.farolneblina is not null or
                   lr_tem.lanterna     is not null then
                   ##display ""
                   ##display "TELA DO FILTRO"
                   ##display "CLAUSULA 76"
                   ##display "TEM FAROL ESCOLHIDO"
                   ##display ""
                   let l_flgtipatend = true
                end if

             else
                ## Nao tem fora da rede tambem
                let l_msg1 = "FORA DA REDE."
                let l_msg2 = " "
             end if
          end if

          if l_rede = 0 then
             if l_flgtipatend = false then
                call cts08g01 ("A","N","",
                               "NAO EXISTEM LOJAS COM ATENDIMENTO ",
                               l_msg1,
                               l_msg2)

                returning ws.confirma
             end if

             if l_atendimento = 2 then
                exit while
             end if
          else
              exit while
          end if

       end if

       let l_atendimento = l_atendimento + 1

       if l_flgtipatend = true then
          #display "COLOCOU FIXO TIPO DE ATENDIMENTO = 1"
          let l_atendimento = 1
       end if

       #display "arr_aux: ", arr_aux

       if arr_aux  >  1  then
          exit while
       end if

    end while
       if arr_aux  >  1  then
          ## PSI 239.399 - Clausula 077 Vidros Blindados
          if g_vdr_blindado = "S" then #and
             #l_flgtipatend = false then
                {call cts08g01 ("A","N","",
                               "NAO EXISTEM LOJAS COM ATENDIMENTO ",
                               l_msg1,
                               l_msg2)}
                call cts08g01 ("A","N",
                               "INFORME LEVAR O VEIC ONDE BLINDOU E RE-",
                               "GISTRE DADOS DA LOJA NO HISTORICO.     ",
                               "EM 24H UTEIS SINISTRO AUTO FARA CONTATO",
                               "COM A LOJA PARA DEFINIR O ATENDIMENTO.")
                returning ws.confirma
          end if
          ## PSI 239.399 - Clausula 077 Vidros Blindados
          let arr_aux1 = 1

          open c_cts19m05_004
          foreach c_cts19m05_004 into a_cts19m05[arr_aux1].vdrrprempnom,
                                    a_cts19m05[arr_aux1].vdrrprgrpcod,
                                    a_cts19m05[arr_aux1].vdrrprgrpnom,
                                    a_cts19m05[arr_aux1].endlgd,
                                    a_cts19m05[arr_aux1].endlgdnum,
                                    a_cts19m05[arr_aux1].brrnom,
                                    a_cts19m05[arr_aux1].cidnom,
                                    a_cts19m05[arr_aux1].ufdcod,
                                    a_cts19m05[arr_aux1].dddcod,
                                    a_cts19m05[arr_aux1].teltxt,
                                    a_cts19m05[arr_aux1].calckm,
                                    a_cts19m05[arr_aux1].horloja,
                                    a_cts19m05[arr_aux1].atend,
                                    a_cts19m05[arr_aux1].rspnom,
                                    a_cts19m05[arr_aux1].faxnum,
                                    a_cts19m05[arr_aux1].vdrrprempcod,
                                    a_cts19m05[arr_aux1].vdrrprempobs,
                                    a_cts19m05[arr_aux1].lclltt,
                                    a_cts19m05[arr_aux1].lcllgt,
                                    arr_aux2

             let arr_aux1 = (arr_aux1 + 1)

          end foreach

          let arr_aux1 = (arr_aux1 - 1)

        message " (F17)Abandona, (F8)Seleciona"

        if param.tela  =  "ctg3"  then
           message " (F17)Abandona"
        end if

        call set_count(arr_aux)

        display array a_cts19m05 to s_cts19m05.*
           on key (interrupt,control-c)
              let arr_aux = 1
              initialize a_cts19m05  to null
              exit display

           on key (f8)

              if param.tela  <> "ctg3" or
                 param.tela is null  then

                 let arr_aux = arr_curr()
                 let scr_aux = scr_line()

                 select atntip into ws.atntip
                    from adikvdrrpremp
                   where vdrrprempcod = a_cts19m05[arr_aux].vdrrprempcod
                 if ws.atntip is null  then
                    let ws.atntip = 9
                 end if

                 let ws.segsexinchor = a_cts19m05[arr_aux].horloja[15,19]
                 let ws.segsexfnlhor = a_cts19m05[arr_aux].horloja[24,28]
                 let ws.sabinchor    = a_cts19m05[arr_aux].horloja[38,42]
                 let ws.sabfnlhor    = a_cts19m05[arr_aux].horloja[47,51]
                 error " Loja selecionada!"

                 exit display
              end if
        end display
     else
        message " "
        error "Nenhuma Loja localizada!" sleep 2
        initialize a_cts19m05  to null
     end if
     let int_flag = false
     close window w_cts19m05

      # APAGA A TABELA TEMPORARIA
      call cts19m05_temp_table(2)
           returning l_status

      if l_status <> 0 then
         return
      end if

     return a_cts19m05[arr_aux].vdrrprempcod,
            a_cts19m05[arr_aux].vdrrprempnom,
            a_cts19m05[arr_aux].cidnom      ,
            a_cts19m05[arr_aux].ufdcod      ,
            a_cts19m05[arr_aux].dddcod      ,
            a_cts19m05[arr_aux].teltxt      ,
            a_cts19m05[arr_aux].vdrrprgrpcod,
            a_cts19m05[arr_aux].vdrrprgrpnom,
            a_cts19m05[arr_aux].horloja     ,
            a_cts19m05[arr_aux].rspnom      ,
            ws.segsexinchor                 ,
            ws.segsexfnlhor                 ,
            ws.sabinchor                    ,
            ws.sabfnlhor                    ,
            ws.atntip

end function

#-------------------------------#
function cts19m05_consulta(param)
#-------------------------------#

  define param   record
         vdrrprgrpcod like adikvdrrprgrp.vdrrprgrpcod,
         vdrrprempcod like adikvdrrpremp.vdrrprempcod,
         lclltt       like datmlcl.lclltt          ,
         lcllgt       like datmlcl.lcllgt          ,
         tela         char (04)                    ,
         alerta       char (01)
  end record

  if param.tela is null then
    initialize ws.*         to null
    initialize a_cts19m05   to null
    initialize a_cts19m05b  to null
    let arr_aux  =  1

    let ws.comando = "select vdrrprempnom, endlgd      , endlgdnum   ,",
                           " brrnom      , cidnom      ,",
                           " ufdcod      , dddcod      ,",
                           " teltxt      , faxnum      , segsexinchor,",
                           " segsexfnlhor, sabinchor   ,",
                           " sabfnlhor   , rspnom      , atntip      ,",
                           " vdrrprempcod, vdrrprgrpcod, lclltt,lcllgt,",
                           " vdrrprempstt, vdrrprempobs ",
                      " from adikvdrrpremp ",
                     " where vdrrprgrpcod  = ? ",
                       " and vdrrprempcod  = ? "

    prepare p_cts19m05_007 from ws.comando
    declare c_cts19m05_006 cursor for p_cts19m05_007

    open window w_cts19m05 at 07,02 with form "cts19m05"
          attribute(form line 1,border)

    open c_cts19m05_006 using param.vdrrprgrpcod, param.vdrrprempcod

    foreach c_cts19m05_006 into a_cts19m05b[arr_aux].vdrrprempnom,
                                a_cts19m05b[arr_aux].endlgd,
                                a_cts19m05b[arr_aux].endlgdnum,
                                a_cts19m05b[arr_aux].brrnom,
                                a_cts19m05b[arr_aux].cidnom,
                                a_cts19m05b[arr_aux].ufdcod,
                                a_cts19m05b[arr_aux].dddcod,
                                a_cts19m05b[arr_aux].teltxt,
                                a_cts19m05b[arr_aux].faxnum,
                                ws.segsexinchor,
                                ws.segsexfnlhor,
                                ws.sabinchor,
                                ws.sabfnlhor,
                                a_cts19m05b[arr_aux].rspnom,
                                ws.atntip,
                                a_cts19m05b[arr_aux].vdrrprempcod,
                                a_cts19m05b[arr_aux].vdrrprgrpcod,
                                a_cts19m05b[arr_aux].lclltt,
                                a_cts19m05b[arr_aux].lcllgt,
                                ws.vdrrprempstt,
                                a_cts19m05b[arr_aux].vdrrprempobs


          # MOSTRAR AS LOJAS CANCELADAS DURANTE A CONSULTA
          # DATA: 19/12/2006 - LUCAS SCHEID
          # CHAMADO: 6123358
          #----------------------------------------
          ##if ws.vdrrprempstt <> "A"  then
          ##   continue foreach
          ##end if

          if a_cts19m05b[arr_aux].lclltt is null or
             a_cts19m05b[arr_aux].lcllgt is null then
             continue foreach
          end if

          if a_cts19m05b[arr_aux].vdrrprgrpcod =  1  and
             g_esprtrflg                       = "S" then

             continue foreach
          end if

          select vdrrprgrpnom
              into a_cts19m05b[arr_aux].vdrrprgrpnom
              from adikvdrrprgrp
             where vdrrprgrpcod  =  a_cts19m05b[arr_aux].vdrrprgrpcod
          if sqlca.sqlcode <>  0  then
             let a_cts19m05b[arr_aux].vdrrprgrpnom = "Prestador nao existe"
          end if

          let a_cts19m05b[arr_aux].horloja =
              "seg a sex das ",ws.segsexinchor," as ",ws.segsexfnlhor,
              " sab das ",ws.sabinchor," as ",ws.sabfnlhor

          if ws.atntip  =  1  then
             let a_cts19m05b[arr_aux].atend = "REDE"
          else
             if ws.atntip = 2 then
                let a_cts19m05b[arr_aux].atend = "FORA DA REDE"
             else
                if ws.atntip = 3 then
                   let a_cts19m05b[arr_aux].atend = "AMBOS"
                end if
             end if
          end if

          let arr_aux = arr_aux + 1

          if arr_aux > 300   then
             error "Limite excedido. Pesquisa com mais de 300 lojas!"
             exit foreach
          end if

    end foreach

    if arr_aux  >  1  then

       message " (F17)Abandona"
       call set_count(arr_aux-1)

       display array a_cts19m05b to s_cts19m05.*
          on key (interrupt,control-c)
             let arr_aux = 1
             initialize a_cts19m05b  to null
             exit display
       end display
    else
       message " "
       error "Nenhuma Loja localizada!" sleep 2
       initialize a_cts19m05b  to null
    end if
    let int_flag = false
    close window w_cts19m05
  else

    select vdrrprempcod,vdrrprempnom,cidnom   ,ufdcod   ,dddcod,teltxt,
           segsexinchor,segsexfnlhor,sabinchor,sabfnlhor,rspnom
      into retorno.vdrrprempcod,retorno.vdrrprempnom,
           retorno.cidnom      ,retorno.ufdcod   ,
           retorno.dddcod      ,retorno.teltxt,   ws.segsexinchor,
           ws.segsexfnlhor     ,ws.sabinchor  ,   ws.sabfnlhor,
           retorno.rspnom      ,retorno.atntip
      from adikvdrrpremp
     where vdrrprgrpcod = param.vdrrprgrpcod
       and vdrrprempcod = param.vdrrprempcod
     if sqlca.sqlcode =  0 then
        let retorno.horloja =
          "seg a sex das ",ws.segsexinchor," as ",ws.segsexfnlhor,
          " sab das ",ws.sabinchor," as ",ws.sabfnlhor

        select vdrrprgrpnom into retorno.vdrrprgrpnom
             from adikvdrrprgrp
            where vdrrprgrpcod = param.vdrrprgrpcod
        let retorno.vdrrprgrpcod = param.vdrrprgrpcod

     end if
  end if
 end function

#-----------------------------------------#
function cts19m05_atende_item(lr_parametro)
#-----------------------------------------#

  define lr_parametro  record
         vdrrprgrpcod  integer,
         vdrrprempcod  integer,
         item          smallint
  end record

  define l_atende smallint

  let l_atende = true

  open c_cts19m05_003 using lr_parametro.vdrrprgrpcod,
                          lr_parametro.vdrrprempcod,
                          lr_parametro.item
  fetch c_cts19m05_003

  if sqlca.sqlcode = notfound then
     let l_atende = false
  end if

  close c_cts19m05_003

  return l_atende

end function

#---------------------------#
function cts19m05_inf_itens()
#---------------------------#

  define lr_item      record
         parabrisa    char(01),
         traseiro     char(01),
         lateral      char(01),
         oculo        char(01),
         quebravento  char(01),
         retrovisor   char(01),
         farol        char(01),
         farolmilha   char(01),
         farolneblina char(01),
         pisca        char(01),
         lanterna     char(01)
  end record

  define l_resposta   char(01)

  let l_resposta = null

  initialize lr_item to null

  open window w_cts19m05b at 7,3 with form "cts19m05b"
     attribute(border, form line 1, prompt line last)

  input by name lr_item.parabrisa,
                lr_item.traseiro,
                lr_item.lateral,
                lr_item.oculo,
                lr_item.quebravento,
                lr_item.retrovisor,
                lr_item.farol,
                lr_item.farolmilha,
                lr_item.farolneblina,
                lr_item.pisca,
                lr_item.lanterna without defaults

     before field parabrisa
        display by name lr_item.parabrisa attribute(reverse)

     after field parabrisa
        display by name lr_item.parabrisa

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field parabrisa
        end if

        if not cts19m05_campo_valido(lr_item.parabrisa) then
           let lr_item.parabrisa = null
           next field parabrisa
        end if

     before field traseiro
        display by name lr_item.traseiro attribute(reverse)

     after field traseiro
        display by name lr_item.traseiro

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field parabrisa
        end if

        if not cts19m05_campo_valido(lr_item.traseiro) then
           let lr_item.traseiro = null
           next field traseiro
        end if

     before field lateral
        display by name lr_item.lateral attribute(reverse)
     after field lateral
        display by name lr_item.lateral

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field traseiro
        end if

        if not cts19m05_campo_valido(lr_item.lateral) then
           let lr_item.lateral = null
           next field lateral
        end if

     before field oculo
        display by name lr_item.oculo attribute(reverse)
     after field oculo
        display by name lr_item.oculo

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field lateral
        end if

        if not cts19m05_campo_valido(lr_item.oculo) then
           let lr_item.oculo = null
           next field oculo
        end if

     before field quebravento
        display by name lr_item.quebravento attribute(reverse)
     after field quebravento
        display by name lr_item.quebravento

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field oculo
        end if

        if not cts19m05_campo_valido(lr_item.quebravento) then
           let lr_item.quebravento = null
           next field quebravento
        end if

     before field retrovisor
        display by name lr_item.retrovisor attribute(reverse)
     after field retrovisor
        display by name lr_item.retrovisor

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field quebravento
        end if

        if not cts19m05_campo_valido(lr_item.retrovisor) then
           let lr_item.retrovisor = null
           next field retrovisor
        end if

     before field farol
        display by name lr_item.farol attribute(reverse)
     after field farol
        display by name lr_item.farol

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field retrovisor
        end if

        if not cts19m05_campo_valido(lr_item.farol) then
           let lr_item.farol = null
           next field farol
        end if

     before field farolmilha
        display by name lr_item.farolmilha attribute(reverse)
     after field farolmilha
        display by name lr_item.farolmilha

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field farol
        end if

        if not cts19m05_campo_valido(lr_item.farolmilha) then
           let lr_item.farolmilha = null
           next field farolmilha
        end if

     before field farolneblina
        display by name lr_item.farolneblina attribute(reverse)
     after field farolneblina
        display by name lr_item.farolneblina

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field farolmilha
        end if

        if not cts19m05_campo_valido(lr_item.farolneblina) then
           let lr_item.farolneblina = null
           next field farolneblina
        end if

     before field pisca
        display by name lr_item.pisca attribute(reverse)
     after field pisca
        display by name lr_item.pisca

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field farolneblina
        end if

        if not cts19m05_campo_valido(lr_item.pisca) then
           let lr_item.pisca = null
           next field pisca
        end if

     before field lanterna
        display by name lr_item.lanterna attribute(reverse)
     after field lanterna
        display by name lr_item.lanterna

        if fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") then
           next field pisca
        end if

        if not cts19m05_campo_valido(lr_item.lanterna) then
           let lr_item.lanterna = null
           next field lanterna
        end if

     on key(f17, control-c, interrupt)

        display by name lr_item.*

        if lr_item.parabrisa    is not null or
           lr_item.traseiro     is not null or
           lr_item.lateral      is not null or
           lr_item.oculo        is not null or
           lr_item.quebravento  is not null or
           lr_item.retrovisor   is not null or
           lr_item.farol        is not null or
           lr_item.farolmilha   is not null or
           lr_item.farolneblina is not null or
           lr_item.pisca        is not null or
           lr_item.lanterna     is not null then

           let l_resposta = "E"
           while l_resposta <> "S" and l_resposta <> "N"

              prompt "Confirma a escolha? (S ou N): " for l_resposta
              let l_resposta = upshift(l_resposta)

              if l_resposta is null or
                 l_resposta = " " then
                 let l_resposta = "E"
              end if

           end while

           if l_resposta = "N" then
              next field lanterna
           else
              exit input
           end if
        else
           initialize lr_item to null
           exit input
        end if

  end input

  if lr_item.parabrisa    is not null then
     let lr_item.parabrisa = "1"
  end if

  if lr_item.traseiro     is not null then
     let lr_item.traseiro = "1"
  end if

  if lr_item.lateral      is not null then
     let lr_item.lateral = "1"
  end if

  if lr_item.oculo        is not null then
     let lr_item.oculo = "1"
  end if

  if lr_item.quebravento  is not null then
     let lr_item.quebravento = "1"
  end if

  if lr_item.retrovisor   is not null then
     let lr_item.retrovisor = "1"
  end if

  if lr_item.farol        is not null then
     let lr_item.farol = "1"
  end if

  if lr_item.farolmilha   is not null then
     let lr_item.farolmilha = "1"
  end if

  if lr_item.farolneblina is not null then
     let lr_item.farolneblina = "1"
  end if

  if lr_item.pisca        is not null then
     let lr_item.pisca = "1"
  end if

  if lr_item.lanterna     is not null then
     let lr_item.lanterna = "1"
  end if

  close window w_cts19m05b
  let int_flag = false

  return lr_item.parabrisa,
         lr_item.traseiro,
         lr_item.lateral,
         lr_item.oculo,
         lr_item.quebravento,
         lr_item.retrovisor,
         lr_item.farol,
         lr_item.farolmilha,
         lr_item.farolneblina,
         lr_item.pisca,
         lr_item.lanterna

end function

#-------------------------------------#
function cts19m05_campo_valido(l_valor)
#-------------------------------------#

  define l_valor  char(01),
         l_valido smallint

  let l_valido = true

  if l_valor = " " then
     let l_valor = null
  end if

  if l_valor is not null then
     if l_valor <> "X" then
        error "Escolha marcando um X"
        let l_valido = false
     end if
  end if

  return l_valido

end function
