#############################################################################
# Nome do Modulo: CTS00M08                                         Marcelo  #
#                                                                  Gilberto #
# Consulta transmissoes pendentes para fax, impressao remota e MDT Ago/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/10/1998  PSI 6966-3   Gilberto     Incluir novo codigo de status do    #
#                                       servidor VSI-Fax.                   #
#---------------------------------------------------------------------------#
# 15/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#---------------------------------------------------------------------------#
# 19/02/2001  PSI 12353-6  Raji         Inclusao gerenciamento de re-transmi#
#                                       ssoes p/ fax das oficinas.          #
#---------------------------------------------------------------------------#
# 09/11/2001  PSI 12596-9  Raji         Inclusao gerenciamento de re-transmi#
#                                       ssoes p/ fax Resenva carro extra    #
#############################################################################

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts00m08()
#------------------------------------------------------------

 define a_cts00m08   array[300] of record
    servico          char (13),
    trxenvdat        char (05),
    trxenvhor        like datmtrxfila.atdtrxhor,
    trxsitdes        char (30),
    espera           datetime hour to second,
    trxtipdes        char (08),
    atdprscod        like datmservico.atdprscod,
    nomgrr           char (20),
    destino          char (12),
    faxstttxt        char (48),
    trxtipcod        dec  (1,0),
    trxsitcod        dec  (2,0),
    atdtrxnum        like datmtrxfila.atdtrxnum,
    faxch1           like datmfax.faxch1,
    faxch2           like datmfax.faxch2,
    mdtmsgnum        like datmmdtmsg.mdtmsgnum,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define d_cts00m08   record
    trxpardat        like datmfax.faxenvdat
 end record

 define hist_cts00m08 record
    hist1            like datmservhist.c24srvdsc,
    hist2            like datmservhist.c24srvdsc,
    hist3            like datmservhist.c24srvdsc,
    hist4            like datmservhist.c24srvdsc,
    hist5            like datmservhist.c24srvdsc
 end record

 define ws           record
    cponom           like iddkdominio.cponom,
    faxch2           like datmfax.faxch2,
    nomgrr           like dpaksocor.nomgrr,
    atdvclsgl        like datmservico.atdvclsgl,
    socvclcod        like datmservico.socvclcod,
    dddcod           like dpaksocor.dddcod,
    faxnum           like dpaksocor.faxnum,
    atdsrvorg        like datmservico.atdsrvorg,
    horaatu          datetime hour to second,
    confirma         char (01),
    erroflg          char (01),
    privez           char (01),
    horaresul        char (09),
    faxchx           char (10),
    datachar         char (10),
    total            char (12),
    comando          char (200),
    faxsubcod        like datmtrxfila.faxsubcod,
    histerr          smallint,
    lcvresenvcod     like datklocadora.lcvresenvcod,
    lcvnom           like datkavislocal.aviestnom,
    locdddcod        like datkavislocal.dddcod,
    locfacnum        like datkavislocal.facnum,
    aviestnom        like datkavislocal.aviestnom,
    lojdddcod        like datkavislocal.dddcod,
    lojfacnum        like datkavislocal.facnum,
    lcvcod           like datmavisrent.lcvcod,
    aviestcod        like datkavislocal.aviestcod
 end record

 define arr_aux      smallint
 define scr_aux      smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  300
		initialize  a_cts00m08[w_pf1].*  to  null
	end	for

	initialize  d_cts00m08.*  to  null

	initialize  hist_cts00m08.*  to  null

	initialize  ws.*  to  null

 open window w_cts00m08 at  04,02 with form "cts00m08"
             attribute(form line first)

 initialize d_cts00m08.*  to null
 initialize ws.*          to null
 let ws.privez            = "N"

 #-------------------------------------------------------------
 # Prepara comandos SQL
 #-------------------------------------------------------------
 let ws.comando = "select cpodes from iddkdominio  ",
                  " where cponom = ? ",
                  "   and cpocod = ? "
 prepare p_cts00m08_001  from       ws.comando
 declare c_cts00m08_001 cursor for p_cts00m08_001

 let ws.comando = "select atdprscod,atdvclsgl,socvclcod,atdsrvorg ",
                  "  from datmservico      ",
                  " where atdsrvnum = ? ",
                  "   and atdsrvano = ? ",
                  "   and atdsoltip <> 'C'"
 prepare p_cts00m08_002  from       ws.comando
 declare c_cts00m08_002 cursor for p_cts00m08_002

 let ws.comando = "select nomgrr, dddcod, faxnum ",
                  "  from dpaksocor        ",
                  " where pstcoddig = ? "
 prepare p_cts00m08_003 from       ws.comando
 declare c_cts00m08_003  cursor for p_cts00m08_003

 let ws.comando = "select atdvclsgl ",
                  "  from datkveiculo      ",
                  " where socvclcod = ? "
 prepare p_cts00m08_004  from       ws.comando
 declare c_cts00m08_004 cursor for p_cts00m08_004

 let ws.comando = "select  faxstttxt, faxdat, faxhor ",
                  "  from gfxmfax",
                  " where faxsiscod = 'CT' ",
                  "   and faxsubcod = ? ",
                  "   and faxch1    = ? ",
                  "   and faxch2    = ? ",
                  " order by faxdat desc,",
                  "          faxhor desc "
 prepare p_cts00m08_005 from       ws.comando
 declare c_cts00m08_005 cursor for p_cts00m08_005

 let ws.comando = "select nomrazsoc, dddcod, faxnum ",
                  "  from gkpkpos        ",
                  " where pstcoddig = ? "
 prepare p_cts00m08_006 from       ws.comando
 declare c_cts00m08_006  cursor for p_cts00m08_006

 let ws.comando = "select ofnnumdig      ",
                  "  from datmlcl        ",
                  " where atdsrvnum = ?  ",
                  "   and atdsrvano = ?  ",
                  "   and c24endtip = 2  "
 prepare p_cts00m08_007 from       ws.comando
 declare c_cts00m08_007  cursor for p_cts00m08_007

 while true

   let int_flag = false

   input by name d_cts00m08.trxpardat   without defaults

      before field trxpardat
         display by name d_cts00m08.trxpardat   attribute (reverse)

         if ws.privez  =  "N"   then
            let ws.privez  =  "S"
            let d_cts00m08.trxpardat  =  today
            display by name d_cts00m08.trxpardat
            exit input
         end if

      after  field trxpardat
         display by name d_cts00m08.trxpardat

         if d_cts00m08.trxpardat  is null   then
            error " Data de transmissao deve ser informada!"
            next field trxpardat
         end if

         if d_cts00m08.trxpardat  >  today   then
            error " Data de transmissao nao deve ser maior que data atual!"
            next field trxpardat
         end if

      on key(interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if


   while true

     initialize a_cts00m08   to null
     initialize ws.*         to null
     let arr_aux       = 1
     #let ws.horaatu    = current

     select current
       into ws.horaatu
       from dual                # BUSCA DATA E HORA DO BANCO

     display ws.horaatu to relogio attribute(reverse)

     #-------------------------------------------------------------
     # Consulta impressao remota pendente
     #-------------------------------------------------------------
     let ws.cponom = "atdtrxsit"
     message " Aguarde, pesquisando..."  attribute(reverse)

     declare c_cts00m08_008  cursor for
       select atdtrxnum, atdtrxsit,
              atdtrxdat, atdtrxhor,
              atdsrvnum, atdsrvano
         from datmtrxfila
        where datmtrxfila.atdtrxdat  =  d_cts00m08.trxpardat
          and datmtrxfila.atdtrxsit  in (1,2)

     foreach c_cts00m08_008 into  a_cts00m08[arr_aux].atdtrxnum,
                                 a_cts00m08[arr_aux].trxsitcod,
                                 ws.datachar,
                                 a_cts00m08[arr_aux].trxenvhor,
                                 a_cts00m08[arr_aux].atdsrvnum,
                                 a_cts00m08[arr_aux].atdsrvano
        if a_cts00m08[arr_aux].atdsrvnum >  9999999  then
	   continue foreach
        end if

        let a_cts00m08[arr_aux].trxenvdat = ws.datachar[1,5]
        let a_cts00m08[arr_aux].trxtipcod = 1
        let a_cts00m08[arr_aux].trxtipdes = "PAGER"

        open  c_cts00m08_002  using  a_cts00m08[arr_aux].atdsrvnum,
                                    a_cts00m08[arr_aux].atdsrvano
        fetch c_cts00m08_002  into   a_cts00m08[arr_aux].atdprscod,
                                    ws.atdvclsgl,
                                    ws.socvclcod,
                                    ws.atdsrvorg
        close c_cts00m08_002

        let a_cts00m08[arr_aux].servico =
            F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),                  "/",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvnum,7), "-",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvano,2)

        open  c_cts00m08_001  using  ws.cponom,
                                    a_cts00m08[arr_aux].trxsitcod
        fetch c_cts00m08_001  into   a_cts00m08[arr_aux].trxsitdes
        close c_cts00m08_001

        let ws.horaresul = ws.horaatu - a_cts00m08[arr_aux].trxenvhor
        let a_cts00m08[arr_aux].espera = ws.horaresul[3,9]

        initialize a_cts00m08[arr_aux].nomgrr   to null
        initialize a_cts00m08[arr_aux].destino  to null

        if a_cts00m08[arr_aux].atdprscod  is not null   then
           open  c_cts00m08_003  using  a_cts00m08[arr_aux].atdprscod
           fetch c_cts00m08_003  into   ws.nomgrr,
                                     ws.dddcod,
                                     ws.faxnum
           close c_cts00m08_003

           let a_cts00m08[arr_aux].nomgrr = ws.nomgrr

           if ws.socvclcod  is not null   then
              open  c_cts00m08_004  using  ws.socvclcod
              fetch c_cts00m08_004  into   ws.atdvclsgl
              close c_cts00m08_004
           end if

           let a_cts00m08[arr_aux].destino = ws.atdvclsgl
        end if

        let arr_aux = arr_aux + 1
        if arr_aux > 50  then
           error " Limite excedido, pesquisa com mais de 50 impressoes remotas!"
           exit foreach
        end if

     end foreach

     #-------------------------------------------------------------
     # Consulta mensagem para MDT pendente
     #-------------------------------------------------------------
     let ws.cponom = "mdtmsgstt"

     declare c_cts00m08_009  cursor for
       select datmmdtmsg.mdtmsgnum,
              datmmdtmsg.mdtmsgstt,
              datmmdtlog.atldat,
              datmmdtlog.atlhor,
              datmmdtsrv.atdsrvnum,
              datmmdtsrv.atdsrvano
         from datmmdtmsg, datmmdtlog, datmmdtsrv
        where datmmdtmsg.mdtmsgstt  in (1,2,3,4)
          and datmmdtlog.mdtmsgnum  =  datmmdtmsg.mdtmsgnum
          and datmmdtlog.mdtlogseq  =  1
          and datmmdtsrv.mdtmsgnum  =  datmmdtmsg.mdtmsgnum

     foreach c_cts00m08_009 into  a_cts00m08[arr_aux].mdtmsgnum,
                                a_cts00m08[arr_aux].trxsitcod,
                                ws.datachar,
                                a_cts00m08[arr_aux].trxenvhor,
                                a_cts00m08[arr_aux].atdsrvnum,
                                a_cts00m08[arr_aux].atdsrvano
				
        if a_cts00m08[arr_aux].atdsrvnum >  9999999 then
	   continue foreach
        end if

        let a_cts00m08[arr_aux].trxenvdat = ws.datachar[1,5]
        let a_cts00m08[arr_aux].trxtipcod = 2
        let a_cts00m08[arr_aux].trxtipdes = "MDT"

        open  c_cts00m08_002  using  a_cts00m08[arr_aux].atdsrvnum,
                                    a_cts00m08[arr_aux].atdsrvano
        fetch c_cts00m08_002  into   a_cts00m08[arr_aux].atdprscod,
                                    ws.atdvclsgl,
                                    ws.socvclcod,
                                    ws.atdsrvorg
        close c_cts00m08_002

        let a_cts00m08[arr_aux].servico =
            F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),                  " ",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvnum,7), "-",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvano,2)

        open  c_cts00m08_001  using  ws.cponom,
                                    a_cts00m08[arr_aux].trxsitcod
        fetch c_cts00m08_001  into   a_cts00m08[arr_aux].trxsitdes
        close c_cts00m08_001

        let ws.horaresul = ws.horaatu - a_cts00m08[arr_aux].trxenvhor
        let a_cts00m08[arr_aux].espera = ws.horaresul[3,9]

        initialize a_cts00m08[arr_aux].nomgrr   to null
        initialize a_cts00m08[arr_aux].destino  to null

        if a_cts00m08[arr_aux].atdprscod  is not null   then
           open  c_cts00m08_003  using  a_cts00m08[arr_aux].atdprscod
           fetch c_cts00m08_003  into   ws.nomgrr,
                                     ws.dddcod,
                                     ws.faxnum
           close c_cts00m08_003

           let a_cts00m08[arr_aux].nomgrr = ws.nomgrr

           if ws.socvclcod  is not null   then
              open  c_cts00m08_004  using  ws.socvclcod
              fetch c_cts00m08_004  into   ws.atdvclsgl
              close c_cts00m08_004
           end if

           let a_cts00m08[arr_aux].destino = ws.atdvclsgl
        end if

        let arr_aux = arr_aux + 1
        if arr_aux > 50  then
           error " Limite excedido, pesquisa com mais de 50 mensagens para MDT!"
           exit foreach
        end if

     end foreach

     #-------------------------------------------------------------
     # Consulta fax pendente Prestador
     #-------------------------------------------------------------
     let ws.cponom = "faxenvsit"
     declare c_cts00m08_010 cursor for
        select faxenvsit, faxenvdat,
               faxenvhor, faxch1   ,
               faxch2   , faxsubcod
          from datmfax
         where datmfax.faxsiscod  =  "CT"
           and datmfax.faxsubcod  =  "PS"
           and datmfax.faxenvdat  =  d_cts00m08.trxpardat
           and datmfax.faxenvsit  in (1,3)

     foreach c_cts00m08_010 into  a_cts00m08[arr_aux].trxsitcod,
                             ws.datachar,
                             a_cts00m08[arr_aux].trxenvhor,
                             a_cts00m08[arr_aux].faxch1,
                             a_cts00m08[arr_aux].faxch2 ,
                             ws.faxsubcod

        let a_cts00m08[arr_aux].trxenvdat = ws.datachar[1,5]
        let a_cts00m08[arr_aux].trxtipcod = 3
        let a_cts00m08[arr_aux].trxtipdes = "FAX PST"

        let ws.faxchx       = a_cts00m08[arr_aux].faxch1 using "&&&&&&&&&&"
        let a_cts00m08[arr_aux].atdsrvnum = ws.faxchx[02,08] using "&&&&&&&"
        let a_cts00m08[arr_aux].atdsrvano = ws.faxchx[09,10] using "&&"

        open  c_cts00m08_002  using  a_cts00m08[arr_aux].atdsrvnum,
                                    a_cts00m08[arr_aux].atdsrvano
        fetch c_cts00m08_002  into   a_cts00m08[arr_aux].atdprscod,
                                    ws.atdvclsgl,
                                    ws.socvclcod,
                                    ws.atdsrvorg
        close c_cts00m08_002

        let a_cts00m08[arr_aux].servico =
            F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),                  " ",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvnum,7), "-",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvano,2)

        open  c_cts00m08_001  using  ws.cponom,
                                    a_cts00m08[arr_aux].trxsitcod
        fetch c_cts00m08_001  into   a_cts00m08[arr_aux].trxsitdes
        close c_cts00m08_001

        let ws.horaresul = ws.horaatu - a_cts00m08[arr_aux].trxenvhor
        let a_cts00m08[arr_aux].espera = ws.horaresul[3,9]

        #-------------------------------------------------------------
        # Consulta retorno do fax
        #-------------------------------------------------------------
        initialize a_cts00m08[arr_aux].faxstttxt   to null

        open  c_cts00m08_005  using  ws.faxsubcod,
                                a_cts00m08[arr_aux].faxch1,
                                a_cts00m08[arr_aux].faxch2
        fetch c_cts00m08_005  into   a_cts00m08[arr_aux].faxstttxt

        initialize a_cts00m08[arr_aux].nomgrr   to null
        initialize a_cts00m08[arr_aux].destino  to null

        if a_cts00m08[arr_aux].atdprscod  is not null   then
           open  c_cts00m08_003 using  a_cts00m08[arr_aux].atdprscod
           fetch c_cts00m08_003  into   ws.nomgrr,
                                     ws.dddcod,
                                     ws.faxnum
           close c_cts00m08_003

           let a_cts00m08[arr_aux].nomgrr  = ws.nomgrr
           let a_cts00m08[arr_aux].destino = ws.dddcod, ws.faxnum
        end if

        let arr_aux = arr_aux + 1
        if arr_aux > 300  then
          error " Limite excedido, pesquisa com mais de 300 transmissoes!"
           exit foreach
        end if

     end foreach

#     #-------------------------------------------------------------
#     # Consulta fax pendente Oficinas
#     #-------------------------------------------------------------
#     let ws.cponom = "faxenvsit"
#     declare c_datmfaxofn cursor for
#        select faxenvsit, faxenvdat,
#               faxenvhor, faxch1   ,
#               faxch2   , faxsubcod
#          from datmfax
#         where datmfax.faxsiscod  =  "CT"
#           and datmfax.faxsubcod  =  "OF"
#           and datmfax.faxenvdat  =  d_cts00m08.trxpardat
#           and datmfax.faxenvsit  in (1,3)
#
#     foreach c_datmfaxofn into  a_cts00m08[arr_aux].trxsitcod,
#                             ws.datachar,
#                             a_cts00m08[arr_aux].trxenvhor,
#                             a_cts00m08[arr_aux].faxch1,
#                             a_cts00m08[arr_aux].faxch2 ,
#                             ws.faxsubcod
#
#        let a_cts00m08[arr_aux].trxenvdat = ws.datachar[1,5]
#        let a_cts00m08[arr_aux].trxtipcod = 4
#        let a_cts00m08[arr_aux].trxtipdes = "FAX OFN"
#
#        let ws.faxchx       = a_cts00m08[arr_aux].faxch1 using "&&&&&&&&&&"
#        let a_cts00m08[arr_aux].atdsrvnum = ws.faxchx[02,08] using "&&&&&&&"
#        let a_cts00m08[arr_aux].atdsrvano = ws.faxchx[09,10] using "&&"
#
#        open  c_cts00m08_007  using  a_cts00m08[arr_aux].atdsrvnum,
#                                a_cts00m08[arr_aux].atdsrvano
#        fetch c_cts00m08_007  into   a_cts00m08[arr_aux].atdprscod
#        close c_cts00m08_007
#
#        let a_cts00m08[arr_aux].servico =
#            F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),                  " ",
#            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvnum,7), "-",
#            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvano,2)
#
#        open  c_cts00m08_001  using  ws.cponom,
#                                    a_cts00m08[arr_aux].trxsitcod
#        fetch c_cts00m08_001  into   a_cts00m08[arr_aux].trxsitdes
#        close c_cts00m08_001
#
#        let ws.horaresul = ws.horaatu - a_cts00m08[arr_aux].trxenvhor
#        let a_cts00m08[arr_aux].espera = ws.horaresul[3,9]
#
#        #-------------------------------------------------------------
#        # Consulta retorno do fax
#        #-------------------------------------------------------------
#        initialize a_cts00m08[arr_aux].faxstttxt   to null
#
#        open  c_cts00m08_005  using  ws.faxsubcod,
#                                a_cts00m08[arr_aux].faxch1,
#                                a_cts00m08[arr_aux].faxch2
#        fetch c_cts00m08_005  into   a_cts00m08[arr_aux].faxstttxt
#
#        initialize a_cts00m08[arr_aux].nomgrr   to null
#        initialize a_cts00m08[arr_aux].destino  to null
#
#        if a_cts00m08[arr_aux].atdprscod  is not null   then
#           open  c_cts00m08_006 using  a_cts00m08[arr_aux].atdprscod
#           fetch c_cts00m08_006  into   ws.nomgrr,
#                                   ws.dddcod,
#                                   ws.faxnum
#           close c_cts00m08_006
#
#           let a_cts00m08[arr_aux].nomgrr  = ws.nomgrr
#           let a_cts00m08[arr_aux].destino = ws.dddcod, ws.faxnum
#        end if
#
#        let arr_aux = arr_aux + 1
#        if arr_aux > 300  then
#          error " Limite excedido, pesquisa com mais de 300 transmissoes!"
#           exit foreach
#        end if
#
#     end foreach

     #-------------------------------------------------------------
     # Consulta fax pendente Carro Extra
     #-------------------------------------------------------------
     let ws.cponom = "faxenvsit"
     declare c_cts00m08_011 cursor for
        select faxenvsit, faxenvdat,
               faxenvhor, faxch1   ,
               faxch2   , faxsubcod
          from datmfax
         where datmfax.faxsiscod  =  "CT"
           and datmfax.faxsubcod  =  "RS"
           and datmfax.faxenvdat  =  d_cts00m08.trxpardat
           and datmfax.faxenvsit  in (1,3)

     foreach c_cts00m08_011 into  a_cts00m08[arr_aux].trxsitcod,
                             ws.datachar,
                             a_cts00m08[arr_aux].trxenvhor,
                             a_cts00m08[arr_aux].faxch1,
                             a_cts00m08[arr_aux].faxch2 ,
                             ws.faxsubcod

        let a_cts00m08[arr_aux].trxenvdat = ws.datachar[1,5]
        let a_cts00m08[arr_aux].trxtipcod = 5
        let a_cts00m08[arr_aux].trxtipdes = "FAX CXT"

        let ws.faxchx       = a_cts00m08[arr_aux].faxch1 using "&&&&&&&&&&"
        let a_cts00m08[arr_aux].atdsrvnum = ws.faxchx[02,08] using "&&&&&&&"
        let a_cts00m08[arr_aux].atdsrvano = ws.faxchx[09,10] using "&&"

        open  c_cts00m08_007  using  a_cts00m08[arr_aux].atdsrvnum,
                                a_cts00m08[arr_aux].atdsrvano
        fetch c_cts00m08_007  into   a_cts00m08[arr_aux].atdprscod
        close c_cts00m08_007

        let a_cts00m08[arr_aux].servico =
            F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),                  " ",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvnum,7), "-",
            F_FUNDIGIT_INTTOSTR(a_cts00m08[arr_aux].atdsrvano,2)

        open  c_cts00m08_001  using  ws.cponom,
                                    a_cts00m08[arr_aux].trxsitcod
        fetch c_cts00m08_001  into   a_cts00m08[arr_aux].trxsitdes
        close c_cts00m08_001

        let ws.horaresul = ws.horaatu - a_cts00m08[arr_aux].trxenvhor
        let a_cts00m08[arr_aux].espera = ws.horaresul[3,9]

        #-------------------------------------------------------------
        # Consulta retorno do fax
        #-------------------------------------------------------------
        initialize a_cts00m08[arr_aux].faxstttxt   to null

        open  c_cts00m08_005  using  ws.faxsubcod,
                                a_cts00m08[arr_aux].faxch1,
                                a_cts00m08[arr_aux].faxch2
        fetch c_cts00m08_005  into   a_cts00m08[arr_aux].faxstttxt

        initialize a_cts00m08[arr_aux].nomgrr   to null
        initialize a_cts00m08[arr_aux].destino  to null

        select datklocadora.lcvresenvcod,
               datklocadora.lcvnom      ,
               datklocadora.dddcod      ,
               datklocadora.facnum      ,
               datkavislocal.aviestnom  ,
               datkavislocal.dddcod     ,
               datkavislocal.facnum,
               datmavisrent.lcvcod,
               datkavislocal.aviestcod
          into ws.lcvresenvcod          ,
               ws.lcvnom                ,
               ws.locdddcod             ,
               ws.locfacnum             ,
               ws.aviestnom             ,
               ws.lojdddcod             ,
               ws.lojfacnum,
               ws.lcvcod,
               ws.aviestcod
          from datmavisrent, datkavislocal, datklocadora
         where datmavisrent.atdsrvnum  = a_cts00m08[arr_aux].atdsrvnum and
               datmavisrent.atdsrvano  = a_cts00m08[arr_aux].atdsrvano and
               datmavisrent.lcvcod     = datklocadora.lcvcod     and
               datkavislocal.lcvcod    = datmavisrent.lcvcod     and
               datkavislocal.aviestcod = datmavisrent.aviestcod

        case ws.lcvresenvcod
           when 1
             let ws.nomgrr  = ws.lcvnom
             let ws.dddcod  = ws.locdddcod
             let ws.faxnum  = ws.locfacnum
           when 2
             let ws.nomgrr  = ws.aviestnom
             let ws.dddcod  = ws.lojdddcod
             let ws.faxnum  = ws.lojfacnum
         end case

        let a_cts00m08[arr_aux].nomgrr  = ws.nomgrr
        let a_cts00m08[arr_aux].destino = ws.dddcod, ws.faxnum

        let arr_aux = arr_aux + 1
        if arr_aux > 300  then
          error " Limite excedido, pesquisa com mais de 300 transmissoes!"
           exit foreach
        end if

     end foreach

     let ws.total = "Total: ", arr_aux - 1  using "&&&"
     display by name ws.total  attribute(reverse)

     #-------------------------------------------------------------
     # Limpa tela
     #-------------------------------------------------------------
     if arr_aux  =  1   then
        for arr_aux = 1 to 3
            clear s_cts00m08[arr_aux].*
        end for
        error " Nao existe transmissao pendente !"
        exit while
     end if

     message " (F17)Abandona, (F6)Nova consulta, (F9)Cancela, (F10)Reenvio"
     call set_count(arr_aux-1)

     display array  a_cts00m08 to s_cts00m08.*

        on key (interrupt)
           let int_flag = true
           exit display

        on key (F6)    ##----- Nova consulta ("refresh") -----
           exit display

        on key (F9)    ##--- Cancelamento de envio ---
           let arr_aux = arr_curr()
           let scr_aux = scr_line()

           display a_cts00m08[arr_aux].servico  to
                   s_cts00m08[scr_aux].servico  attribute(reverse)

           call cts08g01("A","S","","CONFIRMA O CANCELAMENTO","DO ENVIO ?","")
                returning ws.confirma

           display a_cts00m08[arr_aux].servico  to
                   s_cts00m08[scr_aux].servico

           if ws.confirma = "S"   then
              #-------------------------------------------------------------
              # Cancela envio de pager (impressao remota)
              #-------------------------------------------------------------
              if a_cts00m08[arr_aux].trxtipcod  =  1   then
                 call cts00g01_remove(a_cts00m08[arr_aux].atdsrvnum,
                                      a_cts00m08[arr_aux].atdsrvano, 5)
              end if

              #-------------------------------------------------------------
              # Cancela envio de mensagem para MDT
              #-------------------------------------------------------------
              if a_cts00m08[arr_aux].trxtipcod  =  2   then
                 call cts00g03_sit_msg_mdt(a_cts00m08[arr_aux].mdtmsgnum, 5)
                      returning ws.erroflg
              end if

              #-------------------------------------------------------------
              # Cancela envio de fax Prestador
              #-------------------------------------------------------------
              if a_cts00m08[arr_aux].trxtipcod  =  3   then
                 call cts10g01_sit_fax( 4,
                                        "PS",
                                        a_cts00m08[arr_aux].faxch1,
                                        a_cts00m08[arr_aux].faxch2)
                 #----------------------------------------------------------
                 # Grava HISTORICO do servico
                 #----------------------------------------------------------
                 initialize hist_cts00m08.* to null
                 let hist_cts00m08.hist1 = "CANCELADO FAX PRESTADOR"
                 call cts10g02_historico( a_cts00m08[arr_aux].atdsrvnum ,
                                          a_cts00m08[arr_aux].atdsrvano ,
                                          today  ,
                                          ws.horaatu  ,
                                          g_issk.funmat,
                                          hist_cts00m08.*   )
                        returning ws.histerr

              end if

              #-------------------------------------------------------------
              # Cancela envio de fax Oficina
              #-------------------------------------------------------------
              if a_cts00m08[arr_aux].trxtipcod  =  4   then
                 call cts10g01_sit_fax( 4,
                                        "OF",
                                        a_cts00m08[arr_aux].faxch1,
                                        a_cts00m08[arr_aux].faxch2)
                 #----------------------------------------------------------
                 # Grava HISTORICO do servico
                 #----------------------------------------------------------
                 initialize hist_cts00m08.* to null
                 let hist_cts00m08.hist1 = "CANCELADO FAX OFICINA"
                 call cts10g02_historico( a_cts00m08[arr_aux].atdsrvnum ,
                                          a_cts00m08[arr_aux].atdsrvano ,
                                          today  ,
                                          ws.horaatu  ,
                                          g_issk.funmat,
                                          hist_cts00m08.*   )
                        returning ws.histerr

              end if

              #-------------------------------------------------------------
              # Cancela envio de fax carro extra
              #-------------------------------------------------------------
              if a_cts00m08[arr_aux].trxtipcod  =  5   then
                 call cts10g01_sit_fax( 4,
                                        "RS",
                                        a_cts00m08[arr_aux].faxch1,
                                        a_cts00m08[arr_aux].faxch2)
                 #----------------------------------------------------------
                 # Grava HISTORICO do servico
                 #----------------------------------------------------------
                 initialize hist_cts00m08.* to null
                 let hist_cts00m08.hist1 = "CANCELADO FAX CARRO EXTRA"
                 call cts10g02_historico( a_cts00m08[arr_aux].atdsrvnum ,
                                          a_cts00m08[arr_aux].atdsrvano ,
                                          today  ,
                                          ws.horaatu  ,
                                          g_issk.funmat,
                                          hist_cts00m08.*   )
                        returning ws.histerr

              end if

              exit display
           end if

        on key (F10)    ##--- Reenvio
           let arr_aux = arr_curr()
           let scr_aux = scr_line()

           if a_cts00m08[arr_aux].trxtipcod  <>  2   and
              a_cts00m08[arr_aux].trxtipcod  <>  3   and
              a_cts00m08[arr_aux].trxtipcod  <>  4   and
              a_cts00m08[arr_aux].trxtipcod  <>  5   then
              error " Reenvio disponivel apenas para fax e transmissao MDT!"
           else
              display a_cts00m08[arr_aux].servico  to
                      s_cts00m08[scr_aux].servico  attribute(reverse)

              call cts08g01("A","S","","CONFIRMA O REENVIO ?","","")
                   returning ws.confirma

              display a_cts00m08[arr_aux].servico  to
                      s_cts00m08[scr_aux].servico

              if ws.confirma  =  "S"   then
                 #-------------------------------------------------------------
                 # Reenvio de mensagem para MDT
                 #-------------------------------------------------------------
                 if a_cts00m08[arr_aux].trxtipcod  =  2   then
                    call cts00g03_sit_msg_mdt(a_cts00m08[arr_aux].mdtmsgnum, 2)
                         returning ws.erroflg
                    exit display
                 end if

                 #-------------------------------------------------------------
                 # Reenvio de mensagem para FAX Prestador
                 #-------------------------------------------------------------
                 if a_cts00m08[arr_aux].trxtipcod  =  3   then
                    if a_cts00m08[arr_aux].trxsitcod  <>  3   then
                       error " Reenvio apenas para fax com erro de envio!"
                    else
                       if a_cts00m08[arr_aux].atdprscod  is null   then
                          error " Servico nao possui prestador informado!"
                       else
                          call cts10g01_trx_fax(a_cts00m08[arr_aux].atdsrvnum,
                                                a_cts00m08[arr_aux].atdsrvano,
                                                2,
                                                "PS")
                               returning ws.erroflg
                          if  ws.erroflg  =  "N"   then
                              call cts00m14(a_cts00m08[arr_aux].atdsrvnum,
                                            a_cts00m08[arr_aux].atdsrvano,
                                            a_cts00m08[arr_aux].atdprscod,
                                            "F")
                          end if
                       end if
                    end if
                    #----------------------------------------------------------
                    # Grava HISTORICO do servico
                    #----------------------------------------------------------
                    initialize hist_cts00m08.* to null
                    let hist_cts00m08.hist1 = "REENVIO FAX PRESTADOR"
                    call cts10g02_historico( a_cts00m08[arr_aux].atdsrvnum ,
                                             a_cts00m08[arr_aux].atdsrvano ,
                                             today  ,
                                             ws.horaatu  ,
                                             g_issk.funmat,
                                             hist_cts00m08.*   )
                           returning ws.histerr

                 end if

                 #-------------------------------------------------------------
                 # Reenvio de mensagem para FAX OFICINA
                 #-------------------------------------------------------------
                 if a_cts00m08[arr_aux].trxtipcod  =  4   then
                    if a_cts00m08[arr_aux].trxsitcod  <>  3   then
                       error " Reenvio apenas para fax com erro de envio!"
                    else
                       if a_cts00m08[arr_aux].atdprscod  is null   then
                          error " Servico nao possui oficina informada!"
                       else
                          call cts10g01_trx_fax(a_cts00m08[arr_aux].atdsrvnum,
                                                a_cts00m08[arr_aux].atdsrvano,
                                                2,
                                                "OF")
                               returning ws.erroflg
                          if  ws.erroflg  =  "N"   then
                              call cts00m24(a_cts00m08[arr_aux].atdsrvnum,
                                            a_cts00m08[arr_aux].atdsrvano,
                                            a_cts00m08[arr_aux].atdprscod,
                                            "F")
                          end if
                       end if
                    end if
                    #----------------------------------------------------------
                    # Grava HISTORICO do servico
                    #----------------------------------------------------------
                    initialize hist_cts00m08.* to null
                    let hist_cts00m08.hist1 = "REENVIO FAX OFICINA"
                    call cts10g02_historico( a_cts00m08[arr_aux].atdsrvnum ,
                                             a_cts00m08[arr_aux].atdsrvano ,
                                             today  ,
                                             ws.horaatu  ,
                                             g_issk.funmat,
                                             hist_cts00m08.*   )
                           returning ws.histerr

                 end if

                 #-------------------------------------------------------------
                 # Reenvio de mensagem para FAX CARRO EXTRA
                 #-------------------------------------------------------------
                 if a_cts00m08[arr_aux].trxtipcod  =  5   then
                    if a_cts00m08[arr_aux].trxsitcod  <>  3   then
                       error " Reenvio apenas para fax com erro de envio!"
                    else
                       call cts10g01_trx_fax(a_cts00m08[arr_aux].atdsrvnum,
                                             a_cts00m08[arr_aux].atdsrvano,
                                             2,
                                             "RS")
                            returning ws.erroflg
                       if  ws.erroflg  =  "N"   then
                           #call cts15m03(a_cts00m08[arr_aux].atdsrvnum,
                           #              a_cts00m08[arr_aux].atdsrvano,
                           #              "F")
                           call cts15m00_acionamento
                                (a_cts00m08[arr_aux].atdsrvnum,
                                 a_cts00m08[arr_aux].atdsrvano,
                                 ws.lcvcod, ws.aviestcod,0,'')
                       end if
                    end if

                    #----------------------------------------------------------
                    # Grava HISTORICO do servico
                    #----------------------------------------------------------
                    initialize hist_cts00m08.* to null
                    let hist_cts00m08.hist1 = "REENVIO FAX CARRO EXTRA"
                    call cts10g02_historico( a_cts00m08[arr_aux].atdsrvnum ,
                                             a_cts00m08[arr_aux].atdsrvano ,
                                             today  ,
                                             ws.horaatu  ,
                                             g_issk.funmat,
                                             hist_cts00m08.*   )
                           returning ws.histerr

                 end if

              end if
           end if

     end display

     if int_flag = true then
        exit while
     end if

  end while

 end while

 let int_flag = false
 close window w_cts00m08

end function   ###--- cts00m08
