#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        : Central 24 horas                             #
#  Modulo         : cta05m00.4gl                                 #
#                   Acompanhamento de reclamacoes                #
#  Analista Resp. : Marcelo                                      #
#  PSI            :                                              #
#................................................................#
#  Desenvolvimento:                                              #
#  Liberacao      : Jul/1997                                     #
#................................................................#
#                     * * *  ALTERACOES  * * *                   #
#                                                                #
#  Data         Autor Fabrica         Alteracao                  #
#  ----------   -------------------   -------------------------- #
#  21/03/2001   Wagner                PSI 12801-5 Adaptacao novos#
#                                     codigo de etapa            #
#  26/03/2001   Wagner                PSI 12768-0 Incluir manut. #
#                                     bloqueio pgto.srv.         #
#  30/10/2001   Wagner                Aumentar de 60 p/90 dias a #
#                                     pesquisa.                  #
#  01/03/2002   Wagner                Incluir dptsgl psocor nas  #
#                                     pesquisas.                 #
#  19/11/2002   Ruiz                  PSI 16510-7 Envio de email #
#                                     assunto reclamacao.        #
#  22/04/2003   Aguinaldo Costa       PSI.168920  Resolucao 86   #
#  25/08/2003   Marcio Hashiguti      PSI 172405 / OSF 25186     #
#                                     Alterar assunto X11 p/ W00 #
#----------------------------------------------------------------#
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI       Alteracao                              #
# ---------- ------------- --------- ---------------------------------------#
# 18/09/2003 Jeffeson,Meta PSI175552 Inibir as linhas 963-1128 e 1138-1142  #
#                          OSF26077  Na funcao cta05m00_email chamar afuncao#
#                                    cts30m00                               #
# 21/09/2006 Ligia Mattge  PSI 202720 Implementar cartao/grupo Saude        #
#---------------------------------------------------------------------------#
# 15/11/2006 RUiz          PSI 205206 Implementar Azul Seguros.             #
# 01/10/2008 Amilton,Meta   PSI 223689  Incluir tratamento de erro com      #
#                                       global ( Isolamento U01 )           #
#---------------------------------------------------------------------------#
# 24/11/2008 Priscila Staingel 230650  Nao utilizar a 1 posicao do assunto  #
#                                      como sendo o agrupamento, buscar cod #
#                                      agrupamento.                         #
#---------------------------------------------------------------------------#
# 15/12/2008 Priscila Staingel 234583  Melhoria na navegacao                #
#---------------------------------------------------------------------------#
# 11/10/2010 Carla Rampazzo PSI 260606 Tratar Fluxo de Reclamacao p/PSS(107)#
#---------------------------------------------------------------------------#
# 14/02/2011 Carla Rampazzo PSI        Fluxo de Reclamacao p/ PortoSeg(518) #
#---------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

define m_atdsrvnum like datmservico.atdsrvnum, #psi175552
       m_atdsrvano like datmservico.atdsrvano

#--------------------------------------------------------------------
 function cta05m00()
#--------------------------------------------------------------------

 define d_cta05m00   record
    rcldat           like datmsitrecl.rclrlzdat   ,
    rclsitcod        like datmsitrecl.c24rclsitcod,
    rclsitdsc        char (15)                    ,
    rclastcod        like datmligacao.c24astcod   ,
    rcllignum        like datmsitrecl.lignum      ,
    totqtd           char (12)                    ,
    agora            datetime hour to second
 end record

 define ws           record
    errflg           smallint                     ,
    totqtd           smallint                     ,
    rclfnldat        like datmsitrecl.rclrlzdat   ,
    rclfnlhor        like datmsitrecl.rclrlzhor   ,
    rclrlzhor        char (08)                    ,
    rclsitcod        like datmsitrecl.c24rclsitcod,
    c24astcod        like datmligacao.c24astcod   ,
    c24astagp        like datkassunto.c24astagp   ,     ##psi230650
    c24rclsitcod     like datmsitrecl.c24rclsitcod,
    c24evtcod_rcl    like datkevt.c24evtcod       ,
    atdsrvnum_rcl    like datmservico.atdsrvnum   ,
    atdsrvano_rcl    like datmservico.atdsrvano   ,
    atdsrvorg_rcl    like datmservico.atdsrvorg   ,
    succod           like datrligapol.succod      ,
    ramcod           like datrligapol.ramcod      ,
    aplnumdig        like datrligapol.aplnumdig   ,
    itmnumdig        like datrligapol.itmnumdig   ,
    edsnumref        like datrligapol.edsnumref,
    prporg           like datrligprp.prporg,
    prpnumdig        like datrligprp.prpnumdig,
    fcapacorg        like datrligpac.fcapacorg,
    fcapacnum        like datrligpac.fcapacnum,
    crtsaunum        like datrligsau.crtnum,
    confirma         char (01)                    ,
    flgitm           smallint,
    itaciacod        like datrligitaaplitm.itaciacod
 end record

 define a_cta05m00   array[300] of record
    lignum           like datmligacao.lignum      ,
    servico          char (13),
    rclrlzdat        like datmsitrecl.rclrlzdat   ,
    rclrlzhor        char (05)                    ,
    dddcod           like datmreclam.dddcod       ,
    ctttel           like datmreclam.ctttel       ,
    cttnom           like datmreclam.cttnom       ,
    c24astcod        like datmligacao.c24astcod   ,
    c24astdes        char (40)                    ,
    c24rclsitcod     like datmsitrecl.c24rclsitcod,
    rclsitdes        char (15)                    ,
    pndtmp           interval hour(04) to minute
 end record

 define arr_aux      smallint
 define scr_aux      smallint

 define sql_comando  char (900)
 define l_c24astagp_inf  like datkassunto.c24astagp #psi 230650 - agrupamento do assunto informado para realizar a pesquisa
 define l_c24astagp  like datkassunto.c24astagp #psi230650 - agrupamento do assunto da ligacao localizada

#--------------------------------------------------------------------
# Cursor para obtencao da ultima situacao da reclamacao
#--------------------------------------------------------------------

	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	sql_comando  =  null

 let sql_comando = "select c24rclsitcod,",
                   "       rclrlzdat   ,",
                   "       rclrlzhor    ",
                   "  from datmsitrecl  ",
                   " where lignum = ?   ",
                   "   and c24rclsitcod = (select max(c24rclsitcod)",
                                          "  from datmsitrecl",
                                          " where lignum = ?)"

 prepare select_sitrecl from sql_comando
 declare c_cta05m00_sitrecl cursor with hold for select_sitrecl

#--------------------------------------------------------------------
# Cursor para obtencao dos dados adicionais da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select datmligacao.ligdat   , ",
                   "       datmligacao.lighorinc, ",
                   "       datmreclam.dddcod    , ",
                   "       datmreclam.ctttel    , ",
                   "       datmreclam.cttnom    , ",
                   "       datmligacao.c24astcod, ",
                   "       datmreclam.atdsrvnum , ",
                   "       datmreclam.atdsrvano   ",
                   "  from datmligacao, datmreclam",
                   " where datmligacao.lignum = ? ",
                   "   and datmreclam.lignum = datmligacao.lignum"

 prepare select_ligrecl from sql_comando
 declare c_cta05m00_ligrecl cursor with hold for select_ligrecl

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do assunto da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select c24astdes from datkassunto",
                   " where c24astcod = ? "

 prepare select_assunto from sql_comando
 declare c_cta05m00_assunto cursor with hold for select_assunto

#--------------------------------------------------------------------
# PSI 230650 - buscar agrupamento
#--------------------------------------------------------------------
 let sql_comando = "select c24astagp from datkassunto",
                   " where c24astcod = ? "

 prepare select_c24astagp from sql_comando
 declare c_cta05m00_c24astagp cursor with hold for select_c24astagp

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do codigo de situacao
#--------------------------------------------------------------------
 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24rclsitcod'",
                   "   and cpocod = ?"

 prepare select_dominio from sql_comando
 declare c_cta05m00_dominio cursor with hold for select_dominio

 let sql_comando = "select atdsrvorg                               ",
		   "  from datmservico                             ",
		   " where datmservico.atdsrvnum = ? ",
		   "   and datmservico.atdsrvano = ? "
 prepare select_origem from sql_comando
 declare c_cta05m00_origem cursor for select_origem

 open window w_cta05m00 at 06,02 with form "cta05m00"
             attribute(form line 1)

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 for	w_pf1  =  1  to  300
   initialize  a_cta05m00[w_pf1].*  to  null
 end	for

 initialize  d_cta05m00.*  to  null
 initialize  ws.*  to  null
 initialize a_cta05m00    to null
 initialize ws.*          to null

 let l_c24astagp     = null           #psi230650
 let l_c24astagp_inf = null           #psi230650

#----------------------------------------------------------------------
# Input dos dados utilizados para localizacao de pendencia
#----------------------------------------------------------------------

 while true
    let int_flag             = false
    let d_cta05m00.agora     = current
    let d_cta05m00.totqtd    = null

    clear form
    display by name d_cta05m00.*

    input by name d_cta05m00.rcldat   ,
                  d_cta05m00.rclsitcod,
                  d_cta05m00.rclastcod,
                  d_cta05m00.rcllignum  without defaults

       before field rcldat
          #PSI 234583
          if weekday(today) = 1  then
             let d_cta05m00.rcldat = today - 3 units day
          else
             let d_cta05m00.rcldat = today - 1 units day
          end if
          display by name d_cta05m00.rcldat  attribute (reverse)

       after  field rcldat
          if fgl_lastkey() = fgl_keyval("down")  then
             display by name d_cta05m00.rcldat
             next field rcllignum
          end if

          if d_cta05m00.rcldat is null  then
             let d_cta05m00.rcldat = today
          end if

          if d_cta05m00.rcldat < today - 1 units year  then
             error " Nao deve ser informada data anterior a 12 meses!"
             next field rcldat
          end if

          display by name d_cta05m00.rcldat

       before field rclsitcod
          let d_cta05m00.rclsitcod = 0        #PSI234583
          display by name d_cta05m00.rclsitcod  attribute (reverse)

       after  field rclsitcod
          display by name d_cta05m00.rclsitcod

          if d_cta05m00.rclsitcod is null  or
             d_cta05m00.rclsitcod =  " "   then
             let d_cta05m00.rclsitdsc = "TODOS"
          else
             if d_cta05m00.rclsitcod >= 1    and
                d_cta05m00.rclsitcod <= 4    then
                next field rclsitcod
             end if
             open  c_cta05m00_dominio  using  d_cta05m00.rclsitcod
             fetch c_cta05m00_dominio  into   d_cta05m00.rclsitdsc
             if sqlca.sqlcode = notfound  then
                error " Situacao invalida!"
                call cta05m01() returning d_cta05m00.rclsitcod
                next field rclsitcod
             end if
             close c_cta05m00_dominio
          end if

          display by name d_cta05m00.rclsitdsc

       before field rclastcod
          if g_issk.dptsgl = "ct24hs" or
             g_issk.dptsgl = "psocor" or
             g_issk.dptsgl = "dsvatd" or
             g_issk.dptsgl = "tlprod" or
             g_issk.dptsgl = "desenv" or
             g_issk.dptsgl = "riojan" or
            (g_issk.funmat =  68787   or g_issk.funmat = 68822) then
               let d_cta05m00.rclastcod = "W"      #PSI234583
               display by name d_cta05m00.rclastcod  attribute (reverse)
          else
             if g_issk.dptsgl = "cobrca" then
                let d_cta05m00.rclastcod = "423"
                display by name d_cta05m00.rclastcod
             else
                let d_cta05m00.rclastcod = "X"
                display by name d_cta05m00.rclastcod
                exit input
             end if
          end if

       after  field rclastcod
          display by name d_cta05m00.rclastcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field rclsitcod
          end if

          if d_cta05m00.rclastcod is not null  then
             #PSI 230650 - se foi informada apenas a 1 posição, e considerado que o agrupamento foi informado
             if length(d_cta05m00.rclastcod) = 1 then
                let l_c24astagp_inf = d_cta05m00.rclastcod
             else
                #validar se assunto informado e valido
                open  c_cta05m00_assunto  using  d_cta05m00.rclastcod
                fetch c_cta05m00_assunto
                if sqlca.sqlcode = notfound  then
                   error " Codigo de assunto invalido!"
                   next field rclastcod
                end if
                close c_cta05m00_assunto

                #PSI 230650 - buscar agrupamento do assunto informado
         	    open c_cta05m00_c24astagp using d_cta05m00.rclastcod
         	    fetch c_cta05m00_c24astagp into l_c24astagp_inf
         	    close c_cta05m00_c24astagp


         	    # Se for Agrupamento Itau
         	    if l_c24astagp_inf = "ISA" then
         	       let l_c24astagp_inf = "I"
         	    end if

             end if

             # verificar se é um dos assuntos que podem ser visualizados
             # na tela de pendencia
             if l_c24astagp_inf            <>  "W"   and
                l_c24astagp_inf            <>  "X"   and
                l_c24astagp_inf            <>  "K"   and
                l_c24astagp_inf            <>  "I"   and
                d_cta05m00.rclastcod       <>  "SUG" and
                d_cta05m00.rclastcod       <>  "Z00" and
                d_cta05m00.rclastcod       <>  "K00" and
                d_cta05m00.rclastcod       <>  "K99" and
                d_cta05m00.rclastcod       <>  "I99" and
                d_cta05m00.rclastcod       <>  "I98" and
                d_cta05m00.rclastcod       <>  "ISU" and
                d_cta05m00.rclastcod       <>  "423" and
                d_cta05m00.rclastcod       <>  "107" and
                d_cta05m00.rclastcod       <>  "518" and
                d_cta05m00.rclastcod       <>  "PSU" and
                d_cta05m00.rclastcod       <>  "KSU" then

                error "Informe: W/X/SUG/Z00(PORTO), K(AZUL), I(ITAU), P/107(PSS) ou 518(PortoSeg) "
                next field rclastcod
             end if

          end if

          exit input

       before field rcllignum
          display by name d_cta05m00.rcllignum  attribute (reverse)

       after  field rcllignum
          display by name d_cta05m00.rcllignum

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field rcldat
          else
             if d_cta05m00.rcllignum is null  then
                error " Numero da reclamacao deve ser informado!"
                next field rcllignum
             end if
          end if

       on key (interrupt)
          let int_flag = true
          exit input

    end input

    if int_flag = true  then
       let arr_aux = 1
       initialize a_cta05m00[arr_aux].* to null
       exit while
    end if

    while TRUE

      message " Aguarde, pesquisando..."  attribute(reverse)

      let ws.totqtd = 0
      let arr_aux   = 1

      if d_cta05m00.rcllignum is not null  then
         let sql_comando  = "select distinct lignum from datmsitrecl",
                            " where lignum = ?        and  ",
                            "       c24rclsitcod = 0       "

      else
         let sql_comando  = "select distinct lignum from datmsitrecl",
                            " where rclrlzdat >= ?    and  ",
                            "       c24rclsitcod = 0       "

      end if
      prepare select_main  from sql_comando
      declare c_cta05m00 cursor with hold for select_main

#----------------------------------------------------------------------
# Busca de ligacoes conforme critérios informados
#----------------------------------------------------------------------
      if d_cta05m00.rcllignum is not null  then
         #se numero de ligacao foi informado, busca ligacao
         # para a situação 0
         open c_cta05m00  using  d_cta05m00.rcllignum
      else
         #se numero da ligacao não foi informada, busca ligacoes
         # para data maior ou igual a informada e situação 0
         open c_cta05m00  using  d_cta05m00.rcldat
      end if

      foreach c_cta05m00  into   a_cta05m00[arr_aux].lignum

         #busca data/hora e ultima situação da pendencia
         open  c_cta05m00_sitrecl  using  a_cta05m00[arr_aux].lignum,
                                          a_cta05m00[arr_aux].lignum
         fetch c_cta05m00_sitrecl  into   a_cta05m00[arr_aux].c24rclsitcod,
                                          ws.rclfnldat, ws.rclfnlhor
         close c_cta05m00_sitrecl

         if d_cta05m00.rcllignum  is null   then
            #se situação foi informada
            # e a situação da ligacao localizada é diferente da situação informada
            # despreza ligacao
            if d_cta05m00.rclsitcod                is not null           and
               a_cta05m00[arr_aux].c24rclsitcod <> d_cta05m00.rclsitcod  then
               initialize a_cta05m00[arr_aux].* to null
               continue foreach
            end if
         end if

         open  c_cta05m00_ligrecl  using  a_cta05m00[arr_aux].lignum
         fetch c_cta05m00_ligrecl  into   a_cta05m00[arr_aux].rclrlzdat,
                                          ws.rclrlzhor                 ,
                                          a_cta05m00[arr_aux].dddcod   ,
                                          a_cta05m00[arr_aux].ctttel   ,
                                          a_cta05m00[arr_aux].cttnom   ,
                                          a_cta05m00[arr_aux].c24astcod,
                                          ws.atdsrvnum_rcl             ,
                                          ws.atdsrvano_rcl
         close c_cta05m00_ligrecl

         initialize a_cta05m00[arr_aux].servico to null
         if ws.atdsrvnum_rcl is not null then


	         open c_cta05m00_origem using ws.atdsrvnum_rcl,
					                          ws.atdsrvano_rcl

	         fetch c_cta05m00_origem into ws.atdsrvorg_rcl

            let a_cta05m00[arr_aux].servico =
                                  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg_rcl,2),
                          "/"  ,  F_FUNDIGIT_INTTOSTR(ws.atdsrvnum_rcl,7),
                          "-"  ,  F_FUNDIGIT_INTTOSTR(ws.atdsrvano_rcl,2)

            initialize ws.atdsrvnum_rcl, ws.atdsrvano_rcl,
                       ws.atdsrvorg_rcl  to null
         end if

         let m_atdsrvnum = ws.atdsrvnum_rcl
         let m_atdsrvano = ws.atdsrvano_rcl

         #PSI 230650
         #busca agrupamento do assunto da ligacao capturada

         open c_cta05m00_c24astagp using a_cta05m00[arr_aux].c24astcod
         fetch c_cta05m00_c24astagp into l_c24astagp
         close c_cta05m00_c24astagp

         #se foi informado apenas 1 posição para localizar assunto
         if d_cta05m00.rclastcod is not null  then
            if length(d_cta05m00.rclastcod) = 1  then
               #validar se agrupamento do assunto da ligação capturada é igual
               # ao agrupamento informado para pesquisa

               # Se for Agrupamento Itau
               if l_c24astagp = "ISA" then
                  let l_c24astagp = "I"
               end if

               if l_c24astagp <> l_c24astagp_inf then
                  initialize a_cta05m00[arr_aux].* to null
                  continue foreach
               end if
            else
               #valida que assunto da ligacao capturada é igual ao assunto informado
               if a_cta05m00[arr_aux].c24astcod <> d_cta05m00.rclastcod  then
                  initialize a_cta05m00[arr_aux].* to null
                  continue foreach
               end if

            end if
         end if

         if g_issk.dptsgl = "ct24hs" or
            g_issk.dptsgl = "psocor" or
            g_issk.dptsgl = "dsvatd" or
            g_issk.dptsgl = "desenv" or
            g_issk.dptsgl = "cobrca" or
            g_issk.dptsgl = "tlprod" or
            g_issk.dptsgl = "riojan" and
           (g_issk.funmat =  68787   or g_issk.funmat = 68822) then
            # Usuarios OK
         else
            #PSI 230650
            #se não for usuario valido, nao poderá ver assuntos do agrupamento W,K e I
            if l_c24astagp = "W"  or
               l_c24astagp = "K"  or
               l_c24astagp = "I"  then
               initialize a_cta05m00[arr_aux].* to null
               continue foreach
            end if
         end if

         let a_cta05m00[arr_aux].rclrlzhor = ws.rclrlzhor[1,5]

         open  c_cta05m00_assunto  using  a_cta05m00[arr_aux].c24astcod
         fetch c_cta05m00_assunto  into   a_cta05m00[arr_aux].c24astdes
         close c_cta05m00_assunto

         open  c_cta05m00_dominio  using  a_cta05m00[arr_aux].c24rclsitcod
         fetch c_cta05m00_dominio  into   a_cta05m00[arr_aux].rclsitdes
         close c_cta05m00_dominio

         if a_cta05m00[arr_aux].c24rclsitcod >= 20  then
            call cta05m00_espera(a_cta05m00[arr_aux].rclrlzdat,
                                 a_cta05m00[arr_aux].rclrlzhor,
                                 ws.rclfnldat, ws.rclfnlhor)
                       returning a_cta05m00[arr_aux].pndtmp
         else
            call cta05m00_espera(a_cta05m00[arr_aux].rclrlzdat,
                                 a_cta05m00[arr_aux].rclrlzhor,"","")
                       returning a_cta05m00[arr_aux].pndtmp
         end if

         let ws.totqtd = ws.totqtd + 1

         let arr_aux = arr_aux + 1
         if arr_aux  >  300   then
            error " Limite excedido. Foram encontradas mais de 300 reclamacoes!"
            exit foreach
         end if

      end foreach

#----------------------------------------------------------------------
# Exibe lista de ligações localizadas
#----------------------------------------------------------------------
      let d_cta05m00.totqtd = "Total..: ", ws.totqtd using "&&&"
      display by name d_cta05m00.totqtd  attribute(reverse)

      if arr_aux = 1  then
         message ""
         error " Nao existem reclamacoes para a pesquisa!"
         let int_flag = true
         exit while
      else
         call set_count(arr_aux-1)

         message " (F17)Abandona, (F6)Nova consulta, (F8)Seleciona"

         options insert  key  F35,
                 delete  key  F36,
                 comment line 08

         let ws.errflg = false

         input array a_cta05m00 without defaults from s_cta05m00.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()

               display a_cta05m00[arr_aux].lignum     to
                       s_cta05m00[scr_aux].lignum     attribute(reverse)

               display a_cta05m00[arr_aux].c24astcod  to
                       s_cta05m00[scr_aux].c24astcod  attribute(reverse)

               display a_cta05m00[arr_aux].c24astdes  to
                       s_cta05m00[scr_aux].c24astdes  attribute(reverse)

               display a_cta05m00[arr_aux].c24rclsitcod  to
                       s_cta05m00[scr_aux].c24rclsitcod  attribute(reverse)

               display a_cta05m00[arr_aux].rclsitdes  to
                       s_cta05m00[scr_aux].rclsitdes  attribute(reverse)

            before field c24astcod
               if a_cta05m00[arr_aux].c24astcod    is null  and
                  a_cta05m00[arr_aux].c24rclsitcod is null  then
                  let int_flag = false
                  exit input
               end if

               #PSI 230650
               #busca agrupamento do assunto da ligacao capturada
               open c_cta05m00_c24astagp using a_cta05m00[arr_aux].c24astcod
               fetch c_cta05m00_c24astagp into ws.c24astagp
               close c_cta05m00_c24astagp

               if g_issk.dptsgl = "ct24hs" or
                  g_issk.dptsgl = "psocor" or
                  g_issk.dptsgl = "dsvatd" or
                  g_issk.dptsgl = "desenv" or
                  g_issk.dptsgl = "cobrca" or
                  g_issk.dptsgl = "tlprod" or
                  g_issk.dptsgl = "riojan" and
                 (g_issk.funmat =  68787   or g_issk.funmat = 68822) then
                  if ws.errflg = false  then
                     let ws.c24astcod = a_cta05m00[arr_aux].c24astcod
                  else
                     let ws.errflg = false
                  end if

                  display a_cta05m00[arr_aux].c24astcod to
                          s_cta05m00[scr_aux].c24astcod attribute (reverse)
               else
                  display a_cta05m00[arr_aux].c24astcod to
                          s_cta05m00[scr_aux].c24astcod
                  next field c24rclsitcod
               end if


            after  field c24astcod
               display a_cta05m00[arr_aux].c24astcod to
                       s_cta05m00[scr_aux].c24astcod attribute(reverse)

               if fgl_lastkey() = fgl_keyval("down")  then
                  if a_cta05m00[arr_aux + 1].c24astcod is null  then
                     error " Nao ha' mais reclamacoes nesta direcao!"
                     next field c24astcod
                  end if
               end if

               if a_cta05m00[arr_aux].c24astcod is null  or
                  a_cta05m00[arr_aux].c24astcod =  "  "  then
                  error " Codigo da reclamacao e' item obrigatorio!"
                  let ws.errflg = true

                  case ws.c24astagp
                      when "K"
                         call cta02m04("K")
                         returning a_cta05m00[arr_aux].c24astcod,
                                   a_cta05m00[arr_aux].c24astdes

                      when "1"
                         call cta02m04("1")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "5"
                         call cta02m04("5")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "W"
                         call cta02m04("W")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "ISA"
                         call cta02m04("ISA")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                     when "PSA"
                        call cta02m04("PSA")
                        returning a_cta05m00[arr_aux].c24astcod
                                 ,a_cta05m00[arr_aux].c24astdes

                      otherwise
                         if ws.c24astcod[1,3] = "423" then
                            let a_cta05m00[arr_aux].c24astcod = 423
                         end if

                  end case

                  next field c24astcod
               end if

               if a_cta05m00[arr_aux].c24astcod <> ws.c24astcod  and
                  a_cta05m00[arr_aux].c24rclsitcod >= 20         then
                  error " Reclamacao ja' solucionada nao pode ser alterada!"
                  let a_cta05m00[arr_aux].c24astcod = ws.c24astcod
                  next field c24astcod
               end if

               if length(a_cta05m00[arr_aux].c24astcod) < 3  then
                  error " Codigo de reclamacao invalido!"
                  let ws.errflg = true

                  case ws.c24astagp
                      when "K"
                         call cta02m04("K")
                         returning a_cta05m00[arr_aux].c24astcod,
                                   a_cta05m00[arr_aux].c24astdes

                      when "1"
                         call cta02m04("1")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "5"
                         call cta02m04("5")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "W"
                         call cta02m04("W")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "ISA"
                         call cta02m04("ISA")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "PSA"
                         call cta02m04("PSA")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes


                  end case

                  next field c24astcod
               end if

               open  c_cta05m00_assunto  using  a_cta05m00[arr_aux].c24astcod
               fetch c_cta05m00_assunto  into   a_cta05m00[arr_aux].c24astdes
               if sqlca.sqlcode = notfound  then
                  error " Codigo de reclamacao invalido!"
                  let ws.errflg = true

                  case ws.c24astagp
                      when "K"
                         call cta02m04("K")
                         returning a_cta05m00[arr_aux].c24astcod,
                                   a_cta05m00[arr_aux].c24astdes

                      when "1"
                         call cta02m04("1")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "5"
                         call cta02m04("5")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "W"
                         call cta02m04("W")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "ISA"
                         call cta02m04("ISA")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                      when "PSA"
                         call cta02m04("PSA")
                         returning a_cta05m00[arr_aux].c24astcod
                                  ,a_cta05m00[arr_aux].c24astdes

                  end case

                  next field c24astcod
               else
                  if ws.c24astagp                       <> "W"    and
                     ws.c24astagp                       <> "X"    and
                     a_cta05m00[arr_aux].c24astcod[1,3] <> "423"  and
                     a_cta05m00[arr_aux].c24astcod[1,3] <> "107"  and
                     a_cta05m00[arr_aux].c24astcod[1,3] <> "518"  and
                     ws.c24astagp                       <> "ISA"  and
                     a_cta05m00[arr_aux].c24astcod[1,3] <> "PSA"  and
                     ws.c24astagp                       <> "K"    then

                     error " Codigo de reclamacao invalido!"
                     let ws.errflg = true

                     case ws.c24astagp
                         when "K"
                            call cta02m04("K")
                            returning a_cta05m00[arr_aux].c24astcod,
                                      a_cta05m00[arr_aux].c24astdes

                         when "1"
                            call cta02m04("1")
                            returning a_cta05m00[arr_aux].c24astcod
                                     ,a_cta05m00[arr_aux].c24astdes

                         when "5"
                            call cta02m04("5")
                            returning a_cta05m00[arr_aux].c24astcod
                                     ,a_cta05m00[arr_aux].c24astdes

                         when "W"
                            call cta02m04("W")
                            returning a_cta05m00[arr_aux].c24astcod
                                     ,a_cta05m00[arr_aux].c24astdes

                         when "ISA"
                            call cta02m04("ISA")
                            returning a_cta05m00[arr_aux].c24astcod
                                     ,a_cta05m00[arr_aux].c24astdes

                            when "PSA"
                               call cta02m04("PSA")
                               returning a_cta05m00[arr_aux].c24astcod
                                        ,a_cta05m00[arr_aux].c24astdes

                     end case

                     next field c24astcod

                  else
                     display a_cta05m00[arr_aux].c24astdes to
                             s_cta05m00[scr_aux].c24astdes attribute(reverse)
                  end if
               end if
               close c_cta05m00_assunto

            before field c24rclsitcod
               if ws.errflg = false  then
                  let ws.c24rclsitcod = a_cta05m00[arr_aux].c24rclsitcod
               else
                  let ws.errflg = false
               end if

               display a_cta05m00[arr_aux].c24rclsitcod to
                       s_cta05m00[scr_aux].c24rclsitcod attribute (reverse)

            after  field c24rclsitcod
               display a_cta05m00[arr_aux].c24rclsitcod to
                       s_cta05m00[scr_aux].c24rclsitcod attribute(reverse)

               if a_cta05m00[arr_aux].c24rclsitcod >= 1     and
                  a_cta05m00[arr_aux].c24rclsitcod <= 4     then
                  next field c24rclsitcod
               end if

               if a_cta05m00[arr_aux].c24rclsitcod is null  then
                  error " Codigo da situacao da reclamacao e' item obrigatorio!"
                  let ws.errflg = true
                  call cta05m01() returning a_cta05m00[arr_aux].c24rclsitcod
                  next field c24rclsitcod
               end if

               if fgl_lastkey() = fgl_keyval("down")  then
                  if a_cta05m00[arr_aux + 1].c24rclsitcod is null  then
                     error " Nao ha' mais reclamacoes nesta direcao!"
                     next field c24rclsitcod
                  end if
               end if

               if ws.c24rclsitcod <> a_cta05m00[arr_aux].c24rclsitcod  then
                  open c_cta05m00_dominio using a_cta05m00[arr_aux].c24rclsitcod
                  fetch c_cta05m00_dominio into a_cta05m00[arr_aux].rclsitdes
                  if sqlca.sqlcode = notfound  then
                     error " Situacao invalida!"
                     let a_cta05m00[arr_aux].c24rclsitcod = ws.c24rclsitcod
                     next field c24rclsitcod
                  end if
                  close c_cta05m00_dominio

                  if ws.c24rclsitcod >= 20 then
                     error " Reclamacao concluida nao pode ser alterada!"
                     let a_cta05m00[arr_aux].c24rclsitcod = ws.c24rclsitcod
                     next field c24rclsitcod
                  end if

                  if a_cta05m00[arr_aux].c24rclsitcod < ws.c24rclsitcod  then
                     error " Situacao informada nao pode ser inferior a situacao atual!"
                     let a_cta05m00[arr_aux].c24rclsitcod = ws.c24rclsitcod
                     next field c24rclsitcod
                  end if

                  if ws.c24rclsitcod = 0                   and
                     a_cta05m00[arr_aux].c24rclsitcod > 10  then
                     error " Situacao informada nao confere com codigo da proxima etapa!"
                     let a_cta05m00[arr_aux].c24rclsitcod = ws.c24rclsitcod
                     next field c24rclsitcod
                  end if

                  if ws.c24rclsitcod = 10                   and
                     a_cta05m00[arr_aux].c24rclsitcod < 10  then
                     error " Situacao informada nao confere com codigo da proxima etapa!"
                     let a_cta05m00[arr_aux].c24rclsitcod = ws.c24rclsitcod
                     next field c24rclsitcod
                  end if

                  display a_cta05m00[arr_aux].rclsitdes to
                          s_cta05m00[scr_aux].rclsitdes attribute(reverse)
               end if

            after row
               if ws.c24astcod <> a_cta05m00[arr_aux].c24astcod  then
                 #-------------------------------------------------------
                 # Pesquisa se reclamacao esta relacionada a algum evento
                 #-------------------------------------------------------
                 initialize ws.confirma     , ws.atdsrvnum_rcl,
                            ws.atdsrvano_rcl, ws.atdsrvorg_rcl,
                            ws.c24evtcod_rcl  to null

                 select c24evtcod
                   into ws.c24evtcod_rcl
                   from datkevt
                  where c24astcod = a_cta05m00[arr_aux].c24astcod
                 if sqlca.sqlcode = notfound then
                    initialize ws.c24evtcod_rcl  to null
                 end if

                 let ws.flgitm = 0
                 if ws.c24evtcod_rcl is not null  then
                    #----------------------------
                    # Verifica servico referencia
                    #----------------------------
                    select atdsrvnum, atdsrvano
                      into ws.atdsrvnum_rcl, ws.atdsrvano_rcl
                      from datmreclam
                     where lignum = a_cta05m00[arr_aux].lignum

                    if ws.atdsrvnum_rcl is null and
                       ws.atdsrvnum_rcl is null then

                       ### PSI 272720
                       ## Obter apolice do auto/re
                       call cts20g01_docto(a_cta05m00[arr_aux].lignum)
                            returning ws.succod, ws.ramcod, ws.aplnumdig,
                                      ws.itmnumdig, ws.edsnumref, ws.prporg,
                                      ws.prpnumdig, ws.fcapacorg, ws.fcapacnum,
                                      ws.itaciacod

                       ## Obter o cartao saude
                       if ws.aplnumdig is null then
                          call cts20g09_docto(1,a_cta05m00[arr_aux].lignum)
                               returning ws.crtsaunum
                       end if

                       if (ws.succod    is not null and
                           ws.ramcod    is not null and
                           ws.aplnumdig is not null) or
                           ws.crtsaunum is not null then
                          while true
                            call cts16g00(ws.succod   , ws.ramcod   ,
                                          ws.aplnumdig, ws.itmnumdig,
                                          "", "", 90, ws.crtsaunum)
                                returning ws.atdsrvnum_rcl,
                                          ws.atdsrvano_rcl,
                                          ws.atdsrvorg_rcl

                            if ws.atdsrvnum_rcl is null or
                               ws.atdsrvano_rcl is null then
                               if a_cta05m00[arr_aux].c24astcod <> "W00"  and
                                  a_cta05m00[arr_aux].c24astcod <> "107"  and
                                  a_cta05m00[arr_aux].c24astcod <> "518"  and
                                  a_cta05m00[arr_aux].c24astcod <> "I99"  and
                                  a_cta05m00[arr_aux].c24astcod <> "K00"  then

                                  call cts08g01("A","S",
                                        "PARA ESTE TIPO DE RECLAMACAO E'",
                                        "NECESSARIO INFORMAR O NRO.DO SERVICO.",
                                        " ","PESQUISA NOVAMENTE?")
                                      returning ws.confirma
                                  if ws.confirma = "N" then

                                     let ws.flgitm = 0
                                     initialize ws.atdsrvnum_rcl,
                                                ws.atdsrvano_rcl,
                                                ws.atdsrvorg_rcl to null
                                     exit while
                                  end if
                               else
                                  exit while
                               end if
                            else
                               exit while
                            end if
                          end while
                       end if
                    end if
                 end if

                 if ws.flgitm = 0 then
                    if ws.c24evtcod_rcl is not null and
                       ws.atdsrvnum_rcl is not null and
                       ws.atdsrvano_rcl is not null then
                       call ctb00g01_anlsrv( ws.c24evtcod_rcl,
                                             "",
                                             ws.atdsrvnum_rcl,
                                             ws.atdsrvano_rcl,
                                             g_issk.funmat)

                       update datmreclam set atdsrvnum = ws.atdsrvnum_rcl,
                                             atdsrvano = ws.atdsrvano_rcl
                              where lignum = a_cta05m00[arr_aux].lignum
                    end if

                    update datmligacao
                       set c24astcod = a_cta05m00[arr_aux].c24astcod
                     where lignum    = a_cta05m00[arr_aux].lignum

                    if ws.c24astcod  = "W00" or
                       ws.c24astcod  = "107" or
                       ws.c24astcod  = "518" or
                       ws.c24astcod  = "I99" or
                       ws.c24astcod  = "K00" then

                       call cta05m00_email(a_cta05m00[arr_aux].c24astcod,
                                           a_cta05m00[arr_aux].lignum)
                    end if
                 else
                    let a_cta05m00[arr_aux].c24astcod = ws.c24astcod
                    open  c_cta05m00_assunto using a_cta05m00[arr_aux].c24astcod
                    fetch c_cta05m00_assunto into  a_cta05m00[arr_aux].c24astdes
                    close c_cta05m00_assunto
                 end if
               end if

               if ws.c24rclsitcod <> a_cta05m00[arr_aux].c24rclsitcod  then
                  insert into datmsitrecl (lignum, c24rclsitcod, funmat,
                                           rclrlzdat, rclrlzhor, c24astcod)
                                   values (a_cta05m00[arr_aux].lignum,
                                           a_cta05m00[arr_aux].c24rclsitcod,
                                           g_issk.funmat, today, current,
                                           a_cta05m00[arr_aux].c24astcod)
               end if

               initialize ws.c24astcod    to null
               initialize ws.c24rclsitcod to null

               display a_cta05m00[arr_aux].lignum     to
                       s_cta05m00[scr_aux].lignum

               display a_cta05m00[arr_aux].c24astcod  to
                       s_cta05m00[scr_aux].c24astcod

               display a_cta05m00[arr_aux].c24astdes  to
                       s_cta05m00[scr_aux].c24astdes

               display a_cta05m00[arr_aux].c24rclsitcod  to
                       s_cta05m00[scr_aux].c24rclsitcod

               display a_cta05m00[arr_aux].rclsitdes  to
                       s_cta05m00[scr_aux].rclsitdes

            on key (interrupt)
               let int_flag = true
               #apaga dados de pesquisa carregado para fazer outra pesquisa
               initialize  d_cta05m00.*  to  null  #PSI234583
               initialize a_cta05m00 to null
               let arr_aux = arr_curr()
               exit input

            on key (F6)
               let d_cta05m00.agora  =  current
               display by name d_cta05m00.agora  attribute(reverse)
               let int_flag = false
               exit input

            on key (F8)

               if a_cta05m00[arr_aux].lignum  is not null   then
                  let arr_aux = arr_curr()
                  let scr_aux = scr_line()

                  options comment line last
                  call cta05m04(a_cta05m00[arr_aux].lignum, 1)
                  options comment line 08

                  display a_cta05m00[arr_aux].*  to
                          s_cta05m00[scr_aux].*
               else
                  error " Reclamacao nao selecionada!"
               end if

         end input

         options comment line last
      end if

      if int_flag = true  then
         exit while
      end if

    end while

 end while

 let int_flag = false
 close window w_cta05m00

end function  ##-- cta05m00


#-----------------------------------------------------------
 function cta05m00_espera(param)
#-----------------------------------------------------------

 define param        record
    rclrlzdat        like datmsitrecl.rclrlzdat,
    rclrlzhor        char (05),
    rclfnldat        like datmsitrecl.rclrlzdat,
    rclfnlhor        char (08)
 end record

 define ws           record
    incdat           date,
    fnldat           date,
    resdat           integer,
    time             char (05),
    chrhor           char (07),
    inchor           interval hour(05) to minute,
    fnlhor           interval hour(05) to minute,
    reshor           interval hour(06) to minute
 end record



	initialize  ws.*  to  null

 let ws.incdat = param.rclrlzdat
 if param.rclfnldat is null  or
    param.rclfnldat < param.rclrlzdat  then
    let ws.fnldat = today
 else
    let ws.fnldat = param.rclfnldat
 end if

 let ws.inchor = param.rclrlzhor
 if param.rclfnlhor is null  then
    let ws.time = time
 else
    let ws.time = param.rclfnlhor[1,5]
 end if

 let ws.fnlhor = ws.time

 let ws.resdat = (ws.fnldat - ws.incdat) * 24
 let ws.reshor = (ws.fnlhor - ws.inchor)

 let ws.chrhor = ws.resdat using "###&" , ":00"
 let ws.reshor = ws.reshor + ws.chrhor

 return ws.reshor

end function  ###  cta05m00_espera
#------------------------------------------------------------------------------
 function cta05m00_email(param)
#------------------------------------------------------------------------------
    define param record
         c24astcod   like datkassunto.c24astcod,
         lignum      like datmligacao.lignum
    end record

    define ws record
         succod      like datrligapol.succod,
         ramcod      like datrligapol.ramcod,
         aplnumdig   like datrligapol.aplnumdig,
         itmnumdig   like datrligapol.itmnumdig,
         crtsaunum   like datrligsau.crtnum,
         bnfnum      like datrligsau.bnfnum
    end record

    define l_par   smallint,
           l_flag  smallint
    define l_nulo  char(001)

    initialize  ws.*  to  null



    ## obtem cartao saude
    call cts20g09_docto(2, param.lignum)
         returning ws.succod, ws.ramcod, ws.aplnumdig, ws.crtsaunum,
                   ws.bnfnum

    ## se a ligacao nao e do ramo saude
    if ws.crtsaunum is null then
       select succod,
              ramcod,
              aplnumdig,
              itmnumdig
         into ws.succod,
              ws.ramcod,
              ws.aplnumdig,
              ws.itmnumdig
         from datrligapol
        where lignum = param.lignum
    end if

    if ws.aplnumdig is not null then

       let l_par = 0
       let l_nulo = null

       call figrc072_setTratarIsolamento() -- > psi 223689


       call cts30m00(ws.ramcod,
                     param.c24astcod,
                     l_par,
                     ws.succod,
                     ws.aplnumdig,
                     ws.itmnumdig,
                     param.lignum,
                     m_atdsrvnum,
                     m_atdsrvano,
                     l_nulo,
                     l_nulo,
                     g_documento.solnom)
            returning  l_flag

       if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
          error "Problemas na função cts30m00 ! Avise a Informatica !" sleep 2
          return
       end if        -- > 223689


    end if

end function
