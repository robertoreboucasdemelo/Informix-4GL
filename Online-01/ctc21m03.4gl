###############################################################################
# Nome do Modulo: ctc21m03                                           Almeida  #
#                                                                             #
# Simulacao dos procedimentos a serem tomados pelos atendentes       mai/1998 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 19/07/1999  PSI 8533-2   Wagner       Incluir checagem das mensagens para   #
#                                       Cidade e UF.                          #
#-----------------------------------------------------------------------------#
# 20/10/1999               Gilberto     Alterar acesso ao cadastro de clausu- #
#                                       las (ramo 31).                        #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
###############################################################################
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data       Autor Fabrica PSI       Alteracao                                #
# --------   ------------- --------  -----------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.               #
#-----------------------------------------------------------------------------#


 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define a_datmprtprc array[50] of record
   prtprcnum         like datmprtprc.prtprcnum
 end record

 define w_arr        integer

#------------------------------------------------------------
 function ctc21m03()
#------------------------------------------------------------

 define d_ctc21m03   record
    viginc           date,
    viginchor        datetime hour to minute,
    c24astcod        like datkassunto.c24astcod,
    ramcod           like gtakram.ramcod,
    succod           like abamapol.succod,
    aplnumdig        like abamapol.aplnumdig,
    itmnumdig        like abbmitem.itmnumdig
 end record

 define a_ctc21m03_1 array[50] of record
    prtcpointcod     like datmprtprc.prtcpointcod,
    prtcponom        like dattprt.prtcponom,
    sinal            char(02),
    prtprccntdes     like datmprtprc.prtprccntdes,
    prtcpointnom     like dattprt.prtcpointnom
 end record

 define a_ctc21m03_2 array[100] of record
   prctxtseq         like datmprctxt.prctxtseq,
   prctxt            like datmprctxt.prctxt,
   prtprcnum         like datmprctxt.prtprcnum
 end record

 define ws           record
   comando           char(650),
   prtprcnum         like datmprtprc.prtprcnum,
   prtprcexcflg      like datmprtprc.prtprcexcflg,
   cvnnum            like abamapol.cvnnum,
   ramcod            like gtakram.ramcod,
   succod            like abamapol.succod,
   clalclcod         like apbmitem.clalclcod,
   c24astagp         like datkassunto.c24astagp,
   ctgtrfcod         like apbmcasco.ctgtrfcod,
   cbtcod            like apbmcasco.cbtcod,
   c24astcod         like datkassunto.c24astcod,
   clscod            like abbmclaus.clscod,
   cidnom            like datmlcl.cidnom,
   ufdcod            like datmlcl.ufdcod,
   primeiro          char(01),
   tabnum            like itatvig.tabnum,
   data1             char(10),
   dataref           char(16)
 end record

 define w_arr_l      integer
 define w_scr_l      integer
 define w_arr_x      integer
 define ws_conta     integer

 initialize ws.*  to null
 

 let ws.comando = " select prtprcnum, prtprcexcflg ",
                    " from datmprtprc, dattprt ",
                    "where dattprt.prtcpointnom     = ? ",
                      "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                      "and datmprtprc.prtprccntdes <> ? ",
                      "and viginchordat            <= ? ",
                      "and vigfnlhordat            >= ? ",
                      "and datmprtprc.prtprcsitcod in ('A','P') ",
                      "and datmprtprc.prtprcexcflg  = 'E' ",
                  " union ",
                 " select prtprcnum, prtprcexcflg ",
                    " from datmprtprc, dattprt ",
                    "where dattprt.prtcpointnom     = ? ",
                      "and datmprtprc.prtcpointcod  = dattprt.prtcpointcod ",
                      "and datmprtprc.prtprccntdes  = ? ",
                      "and viginchordat            <= ? ",
                      "and vigfnlhordat            >= ? ",
                      "and datmprtprc.prtprcsitcod in ('A','P') ",
                      "and datmprtprc.prtprcexcflg  = 'R' "
 prepare  s_datmprtprc_r from ws.comando
 declare  c_datmprtprc_r cursor with hold for s_datmprtprc_r

 #--------------------------------------------------------------------
 # Criando tabela temporaria atender os agrupamentos
 #--------------------------------------------------------------------
 whenever error continue
 create temp table ctc21m03 (prtprcnum smallint)  with no log
 if sqlca.sqlcode = -310 or
    sqlca.sqlcode = -958 then
    delete from ctc21m03
 end if

 #--------------------------------------------------------------------
 # Criando indice para a tabela temporaria
 #--------------------------------------------------------------------
 create index ctc21m03_idx on ctc21m03(prtprcnum)
 whenever error stop


 open window w_ctc21m03 at 6,2 with form "ctc21m03"
      attribute (form line 1)

 while not int_flag

   initialize d_ctc21m03.*  to null
   initialize a_ctc21m03_1  to null
   initialize a_ctc21m03_2  to null
   initialize a_datmprtprc  to null
   initialize ws.*          to null
   let w_arr    =  1
   let w_arr_l  =  1
   let w_arr_x  =  1

   input by name d_ctc21m03.viginc,
                 d_ctc21m03.viginchor,
                 d_ctc21m03.c24astcod,
                 d_ctc21m03.ramcod,
                 d_ctc21m03.succod,
                 d_ctc21m03.aplnumdig,
                 d_ctc21m03.itmnumdig  without defaults

     before field viginc
            display by name d_ctc21m03.viginc  attribute (reverse)

     after  field viginc
            display by name d_ctc21m03.viginc

            if d_ctc21m03.viginc  is null   then
               error " Data de referencia deve ser informada!"
               next field viginc
            end if

     before field viginchor
            display by name d_ctc21m03.viginchor attribute (reverse)

     after  field viginchor
            display by name d_ctc21m03.viginchor

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field viginc
            end if

            if d_ctc21m03.viginchor is null then
                error " Hora de referencia deve ser informada!"
                next field viginchor
            end if

            let ws.data1    =  d_ctc21m03.viginc
            let ws.dataref  =  ws.data1[7,10], "-",
                               ws.data1[4,5],  "-",
                               ws.data1[1,2],  " ",
                               d_ctc21m03.viginchor

     before field c24astcod
            display by name d_ctc21m03.c24astcod  attribute (reverse)

     after  field c24astcod
            display by name d_ctc21m03.c24astcod

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field viginchor
            end if

            if d_ctc21m03.c24astcod  is null   then
               initialize d_ctc21m03.ramcod     to null
               initialize d_ctc21m03.succod     to null
               initialize d_ctc21m03.aplnumdig  to null
               initialize d_ctc21m03.itmnumdig  to null

               display by name d_ctc21m03.ramcod
               display by name d_ctc21m03.succod
               display by name d_ctc21m03.aplnumdig
               display by name d_ctc21m03.itmnumdig
               exit input
            end if

            select c24astcod
              from datkassunto
             where c24astcod  =  d_ctc21m03.c24astcod

            if sqlca.sqlcode  <>  0   then
               error " Codigo de assunto nao cadastrado!"
               next field c24astcod
            end if

     before field ramcod
            display by name d_ctc21m03.ramcod  attribute (reverse)

     after  field ramcod
            display by name d_ctc21m03.ramcod

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field c24astcod
            end if

             if d_ctc21m03.ramcod  is null   then
                 error " Ramo deve ser informado!"
                 next field ramcod
             end if

            select ramcod
              from gtakram
             where ramcod = d_ctc21m03.ramcod
               and empcod = 1

            if sqlca.sqlcode  =  notfound   then
               error " Ramo nao cadastrado!"
               next field ramcod
            end if

             if d_ctc21m03.ramcod  is not null   and
                d_ctc21m03.ramcod  <>  31        and 
                d_ctc21m03.ramcod  <>  531        then
                initialize d_ctc21m03.itmnumdig  to null
                display by name d_ctc21m03.itmnumdig
            end if

     before field succod
            display by name d_ctc21m03.succod  attribute (reverse)

     after  field succod
            display by name d_ctc21m03.succod

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field ramcod
            end if

            if d_ctc21m03.succod  is null   then
               error " Codigo da sucursal deve ser informado!"
               next field succod
            end if

            select succod
              from gabksuc
             where succod = d_ctc21m03.succod

            if sqlca.sqlcode  =  notfound   then
               error " Sucursal nao cadastrada!"
               next field succod
            end if

    before field aplnumdig
            display by name d_ctc21m03.aplnumdig  attribute (reverse)

     after  field aplnumdig
            display by name d_ctc21m03.aplnumdig

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field succod
            end if

            if d_ctc21m03.aplnumdig  is null   then
               error " Numero da apolice deve ser informado!"
               next field aplnumdig
            end if

            #-----------------------------------------------------------
            # Consulta apolice de Automovel
            #-----------------------------------------------------------
            if d_ctc21m03.ramcod  =  31   or  
               d_ctc21m03.ramcod  =  531   then
               select aplnumdig
                 from abamapol
                where succod    = d_ctc21m03.succod
                  and aplnumdig = d_ctc21m03.aplnumdig

               if sqlca.sqlcode  =  notfound   then
                  error " Apolice nao cadastrada!"
                  next field aplnumdig
               end if
            end if

            #-----------------------------------------------------------
            # Consulta apolice de Ramos Elementares
            #-----------------------------------------------------------
            if d_ctc21m03.ramcod  <>  31   and  
               d_ctc21m03.ramcod  <>  531   then
               select sgrnumdig
                 from rsamseguro
                where succod    = d_ctc21m03.succod
                  and ramcod    = d_ctc21m03.ramcod
                  and aplnumdig = d_ctc21m03.aplnumdig

               if sqlca.sqlcode  =  notfound   then
                  error " Apolice nao cadastrada!"
                  next field aplnumdig
               end if

               call cts14g00(d_ctc21m03.c24astcod,
                             d_ctc21m03.ramcod,
                             d_ctc21m03.succod,
                             d_ctc21m03.aplnumdig,
                             d_ctc21m03.itmnumdig,
                             "","",
                             "S",
                             ws.dataref)
               exit input
            end if

     before field itmnumdig
            display by name d_ctc21m03.itmnumdig  attribute (reverse)

     after  field itmnumdig
            display by name d_ctc21m03.itmnumdig

            if fgl_lastkey() = fgl_keyval ("up")     or
               fgl_lastkey() = fgl_keyval ("left")   then
               next field aplnumdig
            end if

            if d_ctc21m03.itmnumdig  is null   then
               error " Numero do item da apolice deve ser informado!"
               next field itmnumdig
            end if

            select itmnumdig
              from abbmitem
             where succod    = d_ctc21m03.succod
               and aplnumdig = d_ctc21m03.aplnumdig
               and itmnumdig = d_ctc21m03.itmnumdig

            if sqlca.sqlcode  =  notfound   then
               error " Item nao cadastrado!"
               next field itmnumdig
            end if

            call cts14g00(d_ctc21m03.c24astcod,
                          d_ctc21m03.ramcod,
                          d_ctc21m03.succod,
                          d_ctc21m03.aplnumdig,
                          d_ctc21m03.itmnumdig,
                          "","",
                          "S",
                          ws.dataref)

     on key (interrupt)
        exit input

   end input

   if int_flag   then
      exit while
   else
      if d_ctc21m03.aplnumdig  is not null   then
         continue while
      end if
   end if

   initialize a_ctc21m03_1  to null

   input array a_ctc21m03_1 without defaults from s_ctc21m03_1.*

      before row
         let w_arr_l = arr_curr()
         let w_scr_l = scr_line()

      before insert
         initialize a_ctc21m03_1[w_arr_l].* to null

      before field prtcponom
         display a_ctc21m03_1[w_arr_l].prtcponom to
                 s_ctc21m03_1[w_scr_l].prtcponom  attribute(reverse)

      after field prtcponom
         display a_ctc21m03_1[w_arr_l].prtcponom to
                 s_ctc21m03_1[w_scr_l].prtcponom

         if a_ctc21m03_1[w_arr_l].prtcponom is null then
            error " Nome do campo deve ser informado!"
            call ctc21m04() returning a_ctc21m03_1[w_arr_l].prtcpointcod,
                                      a_ctc21m03_1[w_arr_l].prtcponom,
                                      a_ctc21m03_1[w_arr_l].prtcpointnom
            next field prtcponom
         end if

         select prtcpointcod,
                prtcpointnom,
                prtcponom
           into a_ctc21m03_1[w_arr_l].prtcpointcod,
                a_ctc21m03_1[w_arr_l].prtcpointnom,
                a_ctc21m03_1[w_arr_l].prtcponom
           from dattprt
          where prtcponom = a_ctc21m03_1[w_arr_l].prtcponom

        if sqlca.sqlcode = notfound then
            error " Nome do campo nao cadastrado!"
            call ctc21m04() returning a_ctc21m03_1[w_arr_l].prtcpointcod,
                                      a_ctc21m03_1[w_arr_l].prtcponom,
                                      a_ctc21m03_1[w_arr_l].prtcpointnom
            next field prtcponom
        end if

        for ws_conta = 1 to 50
            if a_ctc21m03_1[ws_conta].prtcpointnom is null then
               exit for
            end if
            if a_ctc21m03_1[w_arr_l].prtcpointnom = "cidnom" or
               a_ctc21m03_1[w_arr_l].prtcpointnom = "ufdcod" then
               if a_ctc21m03_1[ws_conta].prtcpointnom <> "cidnom"    and
                  a_ctc21m03_1[ws_conta].prtcpointnom <> "ufdcod"    and
                  a_ctc21m03_1[ws_conta].prtcpointnom <> "c24astagp" and
                  a_ctc21m03_1[ws_conta].prtcpointnom <> "c24astcod" then
                  error " CIDADE ou UF nao podem participar desta pesquisa!"
                  next field prtcponom
               end if
             else
               if a_ctc21m03_1[w_arr_l].prtcpointnom = "c24astagp" or
                  a_ctc21m03_1[w_arr_l].prtcpointnom = "c24astcod" then
                  continue for
                else
                  if a_ctc21m03_1[ws_conta].prtcpointnom = "cidnom" or
                     a_ctc21m03_1[ws_conta].prtcpointnom = "ufdcod" then
                     error " Este item nao pode participar da mesma pesquisa que CIDADE ou UF!"
                     next field prtcponom
                  end if
               end if
            end if
        end for

      before field sinal
         display a_ctc21m03_1[w_arr_l].sinal to
                 s_ctc21m03_1[w_scr_l].sinal  attribute(reverse)

      after field sinal
         display a_ctc21m03_1[w_arr_l].sinal to
                 s_ctc21m03_1[w_scr_l].sinal

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field prtcponom
         end if

         if a_ctc21m03_1[w_arr_l].sinal is null then
            error " Informe : (=)Regra ou (<>)Excessao!"
            next field sinal
         end if

         if a_ctc21m03_1[w_arr_l].sinal <> "="   and
            a_ctc21m03_1[w_arr_l].sinal <> "<>"  then
            error " Informe : (=)Regra ou (<>)Excessao!"
            next field sinal
         end if

      before field prtprccntdes
         display a_ctc21m03_1[w_arr_l].prtprccntdes to
                 s_ctc21m03_1[w_scr_l].prtprccntdes  attribute(reverse)

      after field prtprccntdes
         display a_ctc21m03_1[w_arr_l].prtprccntdes to
                 s_ctc21m03_1[w_scr_l].prtprccntdes

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field sinal
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "c24astagp" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
              error " Conteudo deve ser informado!"
               call ctn30c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
               next field prtprccntdes
            else
               select *
                 from datkastagp
                where c24astagp = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                  error " Conteudo nao cadastrado!"
                  call ctn30c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
                  next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "c24astcod" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               call ctn31c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
               next field prtprccntdes
            else
               select *
                 from datkassunto
                where c24astcod = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                  error " Conteudo nao cadastrado!"
                 call ctn31c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
                  next field prtprccntdes
                end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "cvnnum"  then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               call ctn20c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
               next field prtprccntdes
            else
               select *
                 from akckconvenio
                where cvnnum = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                  error " Conteudo nao cadastrado!"
                  call ctn20c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
                  next field prtprccntdes
               end if
            end if
         end if

        if a_ctc21m03_1[w_arr_l].prtcpointnom = "ramcod"  then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               call ctn33c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
               next field prtprccntdes
            else
               select *
                 from gtakram
                where ramcod = a_ctc21m03_1[w_arr_l].prtprccntdes
                  and empcod = 1

               if sqlca.sqlcode = notfound then
                  error " Conteudo nao cadastrado!"
                  call ctn33c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
                  next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "succod" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
              error " Conteudo deve ser informado!"
               call ctn32c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
               next field prtprccntdes
            else
               select *
                 from gabksuc
                where succod = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                  error " Conteudo nao cadastrado!"
                  call ctn32c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
                  next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "clalclcod" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               call ctn34c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
               next field prtprccntdes
            else
               select *
                 from agekregiao
               where clalclcod = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                  error " Conteudo nao cadastrado!"
                  call ctn34c00() returning a_ctc21m03_1[w_arr_l].prtprccntdes
                  next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "cbtcod" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes <> 1 and
               a_ctc21m03_1[w_arr_l].prtprccntdes <> 2 and
               a_ctc21m03_1[w_arr_l].prtprccntdes <> 6 then
               error " Cobertura nao cadastrada!"
               next field prtprccntdes
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "clscod" then
             if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
              error " Conteudo deve ser informado!"
                next field prtprccntdes
            else
               let ws.tabnum = F_FUNGERAL_TABNUM("aackcls", d_ctc21m03.viginc)

               select clscod from aackcls
                where tabnum = ws.tabnum
                  and ramcod = 531
                  and clscod = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                   error " Clausula nao cadastrada!"
                 next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "ctgtrfcod" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               next field prtprccntdes
            else
               let ws.tabnum = F_FUNGERAL_TABNUM("agekcateg", d_ctc21m03.viginc)

               select ctgtrfcod
                 from agekcateg
                where tabnum    = ws.tabnum
                  and ramcod    = 531
                  and ctgtrfcod = a_ctc21m03_1[w_arr_l].prtprccntdes

               if sqlca.sqlcode = notfound then
                  error " Categoria tarifaria nao cadastrada!"
                  next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "cidnom" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               next field prtprccntdes
             else
               #---------------------------------------------------------
               # Verifica se a cidade esta cadastrada
               #---------------------------------------------------------
               let ws_conta = 0
               select count(*)
                 into ws_conta
                 from glakcid
                 where cidnom = a_ctc21m03_1[w_arr_l].prtprccntdes

               if ws_conta = 0  then
                  error " Cidade nao cadastrada!"
                  next field prtprccntdes
               end if
            end if
         end if

         if a_ctc21m03_1[w_arr_l].prtcpointnom = "ufdcod" then
            if a_ctc21m03_1[w_arr_l].prtprccntdes is null then
               error " Conteudo deve ser informado!"
               next field prtprccntdes
             else
               #---------------------------------------------------------
               # Verifica se UF esta cadastrada
               #---------------------------------------------------------
               let ws_conta = 0
               select count(*)
                 into ws_conta
                 from glakest
                where ufdcod = a_ctc21m03_1[w_arr_l].prtprccntdes

               if ws_conta = 0  then
                  error " Unidade federativa nao cadastrada!"
                  next field prtprccntdes
               end if
            end if
         end if

      on key (interrupt)
         display a_ctc21m03_1[w_arr_l].* to  s_ctc21m03_1[w_scr_l].*
         exit input

   end input

   if w_arr_l  =  1   then
      let int_flag = false
      continue while
   end if

   call set_count(w_arr_l - 1)

   for i = 1  to  w_arr_l

     case a_ctc21m03_1[i].prtcpointnom
        when "cvnnum"      let ws.cvnnum     =  a_ctc21m03_1[i].prtprccntdes
        when "ramcod"      let ws.ramcod     =  a_ctc21m03_1[i].prtprccntdes
        when "succod"      let ws.succod     =  a_ctc21m03_1[i].prtprccntdes
        when "clscod"      let ws.clscod     =  a_ctc21m03_1[i].prtprccntdes
        when "clalclcod"   let ws.clalclcod  =  a_ctc21m03_1[i].prtprccntdes
        when "c24astagp"   let ws.c24astagp  =  a_ctc21m03_1[i].prtprccntdes
        when "ctgtrfcod"   let ws.ctgtrfcod  =  a_ctc21m03_1[i].prtprccntdes
        when "cbtcod"      let ws.cbtcod     =  a_ctc21m03_1[i].prtprccntdes
        when "c24astcod"   let ws.c24astcod  =  a_ctc21m03_1[i].prtprccntdes
        when "cidnom"      let ws.cidnom     =  a_ctc21m03_1[i].prtprccntdes
        when "ufdcod"      let ws.ufdcod     =  a_ctc21m03_1[i].prtprccntdes
        otherwise
     end case

     open c_datmprtprc_r using a_ctc21m03_1[i].prtcpointnom,
                               a_ctc21m03_1[i].prtprccntdes,
                               ws.dataref,
                               ws.dataref,
                               a_ctc21m03_1[i].prtcpointnom,
                               a_ctc21m03_1[i].prtprccntdes,
                               ws.dataref,
                               ws.dataref

     foreach c_datmprtprc_r into ws.prtprcnum,
                                 ws.prtprcexcflg

        if a_ctc21m03_1[i].sinal  =  "="   then
           if ws.prtprcexcflg  <>  "R"  then
              continue foreach
           end if
        else
           if ws.prtprcexcflg  <>  "E"  then
              continue foreach
           end if
        end if

        call ctc21m03_monta_tabela(ws.prtprcnum,
                                   ws.cvnnum,
                                   ws.ramcod,
                                   ws.succod,
                                   ws.clalclcod,
                                   ws.c24astagp,
                                   ws.ctgtrfcod,
                                   ws.cbtcod,
                                   ws.c24astcod,
                                   ws.clscod,
                                   ws.cidnom,
                                   ws.ufdcod,
                                   "S",
                                   ws.dataref)
     end foreach

   end for

   if w_arr  =  1   then
      error " Nenhum procedimento cadastrado para esta simulacao!"
      let int_flag = false
      clear form
      continue while
   end if

   let w_arr = w_arr - 1

   for i = 1  to  w_arr

     if i > 1 then
        let a_ctc21m03_2[w_arr_x].prctxt =
            "-----------------------------------------------------------------------------------"
        let w_arr_x = w_arr_x + 1
     end if

     declare c_datmprctxt cursor for
       select prctxtseq, prctxt, prtprcnum
         from datmprctxt
       where prtprcnum = a_datmprtprc[i].prtprcnum

     let ws.primeiro = "S"

     foreach c_datmprctxt into a_ctc21m03_2[w_arr_x].*

       if ws.primeiro = "S" then
         let ws.primeiro = "N"
       else
          let a_ctc21m03_2[w_arr_x].prtprcnum = "   "
       end if

       let w_arr_x = w_arr_x + 1
       if w_arr_x  >  100   then
          error " Limite excedido. Simulacao c/ mais de 100 linhas de procedimento!"
          exit foreach
       end if

     end foreach

   end for

   call set_count(w_arr_x - 1)

   display array a_ctc21m03_2 to s_ctc21m03_2.*

     on key (f8)
        let w_arr_x = arr_curr()
        if a_ctc21m03_2[w_arr_x].prtprcnum   is null   or
           a_ctc21m03_2[w_arr_x].prtprcnum   = "  "    then
           error " Conferencia disponivel apenas na primeira linha do texto!"
        else
           call cts14g01(a_ctc21m03_2[w_arr_x].prtprcnum)
        end if

     on key (interrupt)
        clear form
        let int_flag = false
        exit display

   end display

 end while

 let int_flag = false
 close window w_ctc21m03

end function  ###--- ctc21m03


#---------------------------------------------------------------------
 function ctc21m03_monta_tabela(param)
#---------------------------------------------------------------------

 define param     record
   prtprcnum      like datmprtprc.prtprcnum,
   cvnnum         like abamapol.cvnnum,
   ramcod         like gtakram.ramcod,
   succod         like abamapol.succod,
   clalclcod      like apbmitem.clalclcod,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like apbmcasco.ctgtrfcod,
   cbtcod         like apbmcasco.cbtcod,
   c24astcod      like datkassunto.c24astcod,
   clscod         like abbmclaus.clscod,
   cidnom         like datmlcl.cidnom,
   ufdcod         like datmlcl.ufdcod,
   smlflg         char(01),
   dt_hoje        datetime year to minute
 end record

 define w_count   smallint


 #--------------------------------------------------------------------
 # Verifica se ja' atendeu a um campo anterior (ja' inserida)
 #--------------------------------------------------------------------
 let w_count = 0

 select count(*)
   into w_count
   from ctc21m03
  where prtprcnum = param.prtprcnum

 if w_count > 0 then
    return
 end if

 #--------------------------------------------------------------------
 # Verifica se existe condicao apenas para um campo
 #--------------------------------------------------------------------
 let w_count = 0

 select count(*)
   into w_count
   from datmprtprc
  where prtprcnum  =  param.prtprcnum

 if w_count  >  1   then
    call ctc21m03_valida_agrupamento(param.prtprcnum,
                                     param.cvnnum,
                                     param.ramcod,
                                     param.succod,
                                     param.clalclcod,
                                     param.c24astagp,
                                     param.ctgtrfcod,
                                     param.cbtcod,
                                     param.c24astcod,
                                     param.clscod,
                                     param.cidnom,
                                     param.ufdcod,
                                     param.smlflg,
                                     param.dt_hoje)
 else
    let a_datmprtprc[w_arr].prtprcnum  = param.prtprcnum
    let w_arr = w_arr + 1
 end if

end function    ###--- ctc21m03_monta_tabela


#---------------------------------------------------------------------
 function ctc21m03_valida_agrupamento (param)
#---------------------------------------------------------------------

 define param     record
   prtprcnum      like datmprtprc.prtprcnum,
   cvnnum         like abamapol.cvnnum,
   ramcod         like gtakram.ramcod,
   succod         like abamapol.succod,
   clalclcod      like apbmitem.clalclcod,
   c24astagp      like datkassunto.c24astagp,
   ctgtrfcod      like apbmcasco.ctgtrfcod,
   cbtcod         like apbmcasco.cbtcod,
   c24astcod      like datkassunto.c24astcod,
   clscod         like abbmclaus.clscod,
   cidnom         like datmlcl.cidnom,
   ufdcod         like datmlcl.ufdcod,
   smlflg         char(01),
   dt_hoje        datetime year to minute
 end record

 define ws        record
   prtcpointnom   like dattprt.prtcpointnom,
   alfa           char(20)
 end record


 initialize  ws.*   to null

 declare c_datmprtprc cursor for
   select dattprt.prtcpointnom
     from datmprtprc, dattprt
    where datmprtprc.prtprcnum     =  param.prtprcnum
      and datmprtprc.prtcpointcod  =  dattprt.prtcpointcod

 foreach c_datmprtprc into ws.prtcpointnom

    case ws.prtcpointnom
       when  "cvnnum"       let ws.alfa  =  param.cvnnum
       when  "ramcod"       let ws.alfa  =  param.ramcod
       when  "succod"       let ws.alfa  =  param.succod
       when  "clscod"       let ws.alfa  =  param.clscod
       when  "clalclcod"    let ws.alfa  =  param.clalclcod
       when  "c24astagp"    let ws.alfa  =  param.c24astagp
       when  "ctgtrfcod"    let ws.alfa  =  param.ctgtrfcod
       when  "cbtcod"       let ws.alfa  =  param.cbtcod
       when  "c24astcod"    let ws.alfa  =  param.c24astcod
       when  "cidnom"       let ws.alfa  =  param.cidnom
       when  "ufdcod"       let ws.alfa  =  param.ufdcod
       otherwise            let ws.alfa  =  "      "
    end case

    if param.smlflg  =  "S"   then

      select datmprtprc.prtprcnum
        from datmprtprc, dattprt
       where datmprtprc.prtprcnum     =  param.prtprcnum
         and dattprt.prtcpointnom     =  ws.prtcpointnom
         and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
         and datmprtprc.prtprccntdes  =  ws.alfa
         and viginchordat            <=  param.dt_hoje
         and vigfnlhordat            >=  param.dt_hoje
         and datmprtprc.prtprcsitcod in  ("A","P")
         and datmprtprc.prtprcexcflg  =  "R"

      if sqlca.sqlcode  =  notfound   then

         declare c_datmprtprc1  cursor for
           select datmprtprc.prtprcnum
             from datmprtprc, dattprt
            where datmprtprc.prtprcnum    =   param.prtprcnum
              and dattprt.prtcpointnom    =   ws.prtcpointnom
              and dattprt.prtcpointcod    =   datmprtprc.prtcpointcod
              and datmprtprc.prtprccntdes <>  ws.alfa
              and viginchordat            <=  param.dt_hoje
              and vigfnlhordat            >=  param.dt_hoje
              and datmprtprc.prtprcsitcod in  ("A","P")
              and datmprtprc.prtprcexcflg  =  "E"

         open   c_datmprtprc1
         fetch  c_datmprtprc1

         if sqlca.sqlcode = notfound then
            return
         else
            select datmprtprc.prtprcnum
              from datmprtprc, dattprt
             where datmprtprc.prtprcnum     =  param.prtprcnum
               and dattprt.prtcpointnom     =  ws.prtcpointnom
               and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
               and datmprtprc.prtprccntdes  =  ws.alfa
               and viginchordat            <=  param.dt_hoje
               and vigfnlhordat            >=  param.dt_hoje
               and datmprtprc.prtprcsitcod in  ("A","P")
               and datmprtprc.prtprcexcflg  =  "E"

             if sqlca.sqlcode <> notfound then
                return
             end if
          end if

      end if
    else

      select datmprtprc.prtprcnum
        from datmprtprc, dattprt
       where datmprtprc.prtprcnum     =  param.prtprcnum
         and dattprt.prtcpointnom     =  ws.prtcpointnom
         and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
         and datmprtprc.prtprccntdes  =  ws.alfa
         and viginchordat            <=  param.dt_hoje
         and vigfnlhordat            >=  param.dt_hoje
         and datmprtprc.prtprcsitcod  =  "A"
         and datmprtprc.prtprcexcflg  =  "R"

      if sqlca.sqlcode  =  notfound   then

         declare c_datmprtprc2  cursor for
         select datmprtprc.prtprcnum
           from datmprtprc,dattprt
          where datmprtprc.prtprcnum     =  param.prtprcnum
            and dattprt.prtcpointnom     =  ws.prtcpointnom
            and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
            and datmprtprc.prtprccntdes  <> ws.alfa
            and viginchordat             <= param.dt_hoje
            and vigfnlhordat             >= param.dt_hoje
            and datmprtprc.prtprcsitcod  =  "A"
            and datmprtprc.prtprcexcflg  =  "E"

         open   c_datmprtprc2
         fetch  c_datmprtprc2

         if sqlca.sqlcode = notfound then
            return
         else
           select datmprtprc.prtprcnum
             from datmprtprc, dattprt
            where datmprtprc.prtprcnum     =  param.prtprcnum
              and dattprt.prtcpointnom     =  ws.prtcpointnom
              and dattprt.prtcpointcod     =  datmprtprc.prtcpointcod
              and datmprtprc.prtprccntdes  =  ws.alfa
              and viginchordat             <= param.dt_hoje
              and vigfnlhordat             >= param.dt_hoje
              and datmprtprc.prtprcsitcod  =  "A"
              and datmprtprc.prtprcexcflg  =  "E"

           if sqlca.sqlcode <> notfound then
              return
           end if
         end if

      end if

   end if

 end foreach

 #--------------------------------------------------------------------
 # Insere na tabela para exibir o texto
 #--------------------------------------------------------------------
 let a_datmprtprc[w_arr].prtprcnum  =  param.prtprcnum
 let w_arr = w_arr + 1
 insert into ctc21m03(prtprcnum) values (param.prtprcnum)

 end function   ###--- ctc21m03_valida_agrupamento

