###############################################################################
# Nome do Modulo: CTA06M00                                           Akio     #
#                                                                    Wagner   #
# Exibe dados de sinistros do atendimento a perda parcial            Mar/2000 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 03/05/2000  Sofia        Akio         Inclusao de identificador de regis-   #
#                                       tro de pendencia para assunto U10     #
#-----------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03           #
#-----------------------------------------------------------------------------#
# 17/08/2001  PSI 127337   Ruiz         Gravar o codigo da pendencia na tabela#
#                                       datrligsin.                           #
#-----------------------------------------------------------------------------#
# 04/09/2001  PSI 132349   Raji         Inclusao de endereco e telefone da ofi#
#                                       cina do processo.                     #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#-----------------------------------------------------------------------------#
# 23/12/2005  Priscila Staingel   PSI 197335  Inclusao alerta divisao sinistro#
#-----------------------------------------------------------------------------#
# 01/02/2006  Priscila Staingel   Zeladoria   Buscar data e hora do banco de  #
#                                             dados                           #
#-----------------------------------------------------------------------------#
#                     * * * A L T E R A C A O * * *                           #
#  Analista Resp. : Eliane Lopes                     OSF : 26816              #
#  Por            : FABRICA DE SOFTWARE, Katiucia    Data: 25/09/2003         #
#  Objetivo       : Ajustes para receber novas informacoes                    #
#-----------------------------------------------------------------------------#
# 21/12/2006  Priscila         CT         Chamar funcao especifica para       #
#                                         insercao em datmlighist             #
#-----------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32          #
#                                                                             #
#-----------------------------------------------------------------------------#
# 30/12/2008 Priscila                      Exibir mensagem de erro retornada  #
#                                          por ctd25g00                       #
#-----------------------------------------------------------------------------#
###############################################################################


globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint

#----------------------------------------------#
 function cta06m00_prepare()
#----------------------------------------------#
define l_sql char(500)
 let l_sql =  "select c24txtseq,       ",
              "       c24ligdsc        ",
              "  from datmlighist      ",
              "       where lignum = ? "
 prepare pcta06m00m00001  from l_sql
 declare ccta06m00m00001  cursor for pcta06m00m00001
 let l_sql =  " select ramcod   ,  ",
              "        sinano   ,  ",
              "        sinnum   ,  ",
              "        sinitmseq   ",
              " from datrligsin    ",
              " where lignum = ?   "
 prepare pcta06m00m00002  from l_sql
 declare ccta06m00m00002  cursor for pcta06m00m00002
 let m_prepare = true

end function

#-------------------------------------------------------------------------------
 function cta06m00()
#-------------------------------------------------------------------------------

 define f_fsauc580   record
        segnumdig    like gsakseg.segnumdig,      # Codigo Segurado
        segnom       like gsakseg.segnom,         # Nome Segurado
        vcldes       char(30),                    # Descricao Veiculo
        vcllicnum    like abbmveic.vcllicnum,     # Placa do Veiculo
        ofnnumdig    like ssamvalores.ofnnumdig,  # Codigo da Oficina
        nomrazsoc    like gkpkpos.nomrazsoc,      # Nome da Oficina
        tipofic      char(15),                    # Tipo de Oficina-Cred/Conv
        prdtip       char(7),                     # Tipo de Perda
        situacao     char(20),                    # Descricao da Situacao
        sinntzcod    like ssamitem.sinntzcod,     # Codigo da Natureza
        natureza     char(20),                    # Descricao da Natureza
        orrdat       like ssamsin.orrdat,         # Data da Ocorrencia
        avsdat       like ssamsin.avsdat,         # Data de Aviso
        abertdat     like ssamsin.avsdat,         # Data de Abertura
        anllibdat    like ssamitem.anllibdat,     # Data da liberacao
        anllibtip    like ssamitem.anllibtip,     # Codigo de liberacao
        liberacao    char(20)               ,     # Descricao da liberacao
        apvtotvlr    like ssamitem.apvtotvlr,     # Valor faturamento
        frqvlr       like ssamitem.frqvlr,        # Valor franquia
        succod       like gabksuc.succod          # sucursal oficina ou sinistro
 end record

 define a_cta06m00   array[01] of record
        branco       char(01)
 end record

 define ws           record
        msgm         char(01)                  ,
        lignum       like datmligacao.lignum   ,
        atdsrvnum    like datmservico.atdsrvnum,
        atdsrvano    like datmservico.atdsrvano,
        codigosql    integer                   ,
        tabname      like systables.tabname    ,
        msg          char(80)               ,
        sintfacod    like sgkktarefa.sintfacod , # Codigo da tarefa
        sintfades    like sgkktarefa.sintfades , # Descricao da tarefa
        confirma     char (01)                 ,
        endlgd       like gkpkpos.endlgd       ,
        endbrr       like gkpkpos.endbrr       ,
        endcid       like gkpkpos.endcid       ,
        endufd       like gkpkpos.endufd       ,
        telnum1      like gkpkpos.telnum1      ,
        telnum2      like gkpkpos.telnum2      ,
        ofnendtxt    char(70)                  ,
        ofntelnum    char(50)                  ,
        sucnom       like gabksuc.sucnom
 end record

 define w_sintfapndregemp like saamsintfapnd.sintfapndregemp
 define w_sintfapndregmat like saamsintfapnd.sintfapndregmat
 define w_anleqpcod       like saamsintfapnd.anleqpcod

 define w_c24txtseq       like datmlighist.c24txtseq
 define w_c24ligdsc       like datmlighist.c24ligdsc

 define w_datatu     date
 define w_horatu     datetime hour to minute
 define w_msg        char(70)
 define w_flag       integer
 define w_acao       char(01)
 define w_f9         smallint

 define w_empcod     like saamfila.empcod
 define w_ananum     like saamfila.funmat
 define w_eqpcod     like saamfila.anleqpcod
 define w_dptsgl     like saamfila.dptsgl
 define w_ananom     like isskfunc.funnom
 define w_usrtip     like isskfunc.usrtip
 define w_paxnum     like saampespax.paxnum

 define w_qtdfranquia  smallint
 define w_errdescr     char(100)
 define l_msg_pri  char(100)

	define	w_pf1	integer

	let	w_sintfapndregemp  =  null
	let	w_sintfapndregmat  =  null
	let	w_anleqpcod  =  null
	let	w_c24txtseq  =  null
	let	w_c24ligdsc  =  null
	let	w_datatu  =  null
	let	w_horatu  =  null
	let	w_msg  =  null
	let	w_flag  =  null
	let	w_acao  =  null
	let	w_f9  =  null

	for	w_pf1  =  1  to  1
		initialize  a_cta06m00[w_pf1].*  to  null
	end	for

	initialize  f_fsauc580.*  to  null

	initialize  ws.*  to  null

 let w_f9 = false

 call cts40g03_data_hora_banco(2)
      returning w_datatu, w_horatu
 let int_flag = false


 open window win_cta06m00 at 04,02 with form "cta06m00"
      attribute(form line 1)


 while true

 #------------------------------------------------------------------------------
 # Busca numeracao ligacao / Grava ligacao
 #------------------------------------------------------------------------------

   begin work

   call cts10g03_numeracao( 1, "" )
        returning ws.lignum   ,
                  ws.atdsrvnum,
                  ws.atdsrvano,
                  ws.codigosql,
                  ws.msg

   if  ws.codigosql = 0  then
       call cts10g00_ligacao ( ws.lignum,
                               w_datatu,
                               w_horatu,
                               g_documento.c24soltipcod,
                               g_documento.solnom,
                               g_documento.c24astcod,
                               g_issk.funmat,
                               g_documento.ligcvntip,
                               g_c24paxnum,
                               "", "", "", "", "", "",
                               g_documento.succod   ,
                               g_documento.ramcod   ,
                               g_documento.aplnumdig,
                               g_documento.itmnumdig,
                               g_documento.edsnumref,
                               "", "", "", "",
                               g_documento.sinramcod,
                               g_documento.sinano   ,
                               g_documento.sinnum   ,
                               g_documento.sinitmseq,
                               "", "", "", "" )
            returning ws.tabname,
                      ws.codigosql

       if  ws.codigosql <> 0  then
           error " Erro (", ws.codigosql, ") na gravacao da",
                 " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.msgm
           exit while
       end if
   else
       let ws.msg = "CTS06M00 - ",ws.msg
       call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
       rollback work
       prompt "" for char ws.msgm
       exit while
   end if
   # Psi 230669 inicio
     if (g_documento.atdnum is not null and
         g_documento.atdnum <> 0 ) then

           let l_msg_pri = "PRI - cta06m00 - chamando ctd25g00"
           call errorlog(l_msg_pri)

           call ctd25g00_insere_atendimento(g_documento.atdnum,ws.lignum)
           returning ws.codigosql,ws.tabname
           if  ws.codigosql <> 0  then
               let ws.tabname = "CTS06M00 - ",ws.tabname
               error ws.tabname sleep 3
               rollback work
               prompt "" for char ws.msgm
               exit while
           end if
     end if
   # Psi 230669 Fim

   commit work


   let g_documento.lignum = ws.lignum


 #------------------------------------------------------------------------------
 # Exibe dados do sinistro
 #------------------------------------------------------------------------------
   call fsauc580( g_documento.sinramcod,
                  g_documento.sinano   ,
                  g_documento.sinnum   ,
                  g_documento.sinitmseq )
        returning f_fsauc580.*
   select sucnom
         into ws.sucnom
         from gabksuc
        where succod = f_fsauc580.succod

 #------------------------------------------------------------------------------
 # Carrega as informacoes da oficina
 #------------------------------------------------------------------------------
   select endlgd,
          endbrr,
          endcid,
          endufd,
          telnum1,
          telnum2
          into ws.endlgd,
               ws.endbrr,
               ws.endcid,
               ws.endufd,
               ws.telnum1,
               ws.telnum2
     from gkpkpos
    where pstcoddig = f_fsauc580.ofnnumdig

   if sqlca.sqlcode = 0 then
      let ws.ofnendtxt = ws.endlgd clipped, " / ",
                         ws.endbrr clipped, " / ",
                         ws.endcid clipped, " / ",
                         ws.endufd
      let ws.ofntelnum = ws.telnum1, " / ", ws.telnum2
   end if

   display by name g_documento.sinramcod
   display by name g_documento.sinano
   display by name g_documento.sinnum
   display by name g_documento.sinitmseq
  #display by name f_fsauc580.*
   display by name f_fsauc580.segnumdig thru f_fsauc580.frqvlr

   display ws.ofnendtxt to ofnendtxt
   display ws.ofntelnum to ofntelnum

   display "Reclam..:" to reclamante
   if  g_documento.sinramcod =  31  or
       g_documento.sinramcod = 531  then
       display "SEGURADO"  to tiporeclam
   else
       display "TERCEIRO"  to tiporeclam
   end if

   # -- OSF 26816 - Fabrica de Software, Katiucia -- #
   display f_fsauc580.prdtip to prdtipcab   attribute(reverse)
   display by name ws.sucnom                attribute(reverse)
   display by name g_documento.solnom       attribute(reverse)

 # inibir o IF conforme solicitacao da Teresinha, 25/05/06
 # apresentar o analista para perda TOTAL e PARCIAL.
 # if f_fsauc580.prdtip = "TOTAL" then
      call fsaac016_fil_rsp_u10 ( g_documento.sinramcod
                                 ,g_documento.sinano
                                 ,g_documento.sinnum
                                 ,g_documento.sinitmseq )
           returning w_empcod
                    ,w_ananum
                    ,w_eqpcod
                    ,w_dptsgl

      # ------------------------------------ #
      # ACESSAR NOME DO ANALISTA EM ISSKFUNC #
      # ------------------------------------ #
      initialize w_ananom to null
      initialize w_usrtip to null
      initialize w_ananom to null
      initialize w_paxnum to null

      select funnom
            ,usrtip
        into w_ananom
            ,w_usrtip
        from isskfunc
       where empcod = w_empcod
         and funmat = w_ananum

      if sqlca.sqlcode = 0 then
         call fssaa051_psqpax ( w_empcod
                               ,w_ananum
                               ,w_usrtip )
              returning w_paxnum
      end if

      display w_ananom to ananom  attribute(reverse)
      display w_paxnum to paxnum  attribute(reverse)
 # end if

   message "(F17)Abandona  (F5)Espelho  (F6)Hist  (F7)Vist  ",
           "(F8)Doc  (F9)Pend  (F10)Pagto "


 #------------------------------------------------------------------------------
 # Exibe dados adicionais do sinistro / grava pendencias
 #------------------------------------------------------------------------------

 #PSI197335
 #Exibir alerta de divisao de sinistro
 let w_qtdfranquia = 0
 let w_flag = 0
 initialize w_errdescr to null
 call fsvpc611_qtdfranquias( g_documento.sinramcod,
                             g_documento.sinano   ,
                             g_documento.sinnum   ,
                             g_documento.sinitmseq )
      returning w_qtdfranquia,
                w_flag,
                w_errdescr

 if w_flag <> 0 then
    error  w_errdescr
 else
    if w_qtdfranquia > 1 then
       #exibe alerta
      call cts08g01("I", "", "ESTA VISTORIA POSSUI DIVISAO DE SINISTRO.",
                     "PROCURE O SINISTRO AUTO.", "", "")
           returning w_flag
    end if
 end if

   display array a_cta06m00 to s_cta06m00.*
     on key(f5)##   call cta01m00()

         call cta01m12_espelho(g_documento.ramcod,
                            g_documento.succod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.prporg,
                            g_documento.prpnumdig,
                            g_documento.fcapacorg,
                            g_documento.fcapacnum,
                            g_documento.pcacarnum,
                            g_documento.pcaprpitm,
                            g_ppt.cmnnumdig,
                            g_documento.crtsaunum,
                            g_documento.bnfnum,
                            g_documento.ciaempcod)

		## MESSAGE "" # By Robi
                  message "(F17)Abandona  (F5)Espelho  (F6)Hist  (F7)Vist  ",
	                  "(F8)Doc  (F9)Pend  (F10)Pagto "

     on key(f6)   call cta03n00( g_documento.lignum   ,
                                 g_issk.funmat        ,
                                 w_datatu             ,
                                 w_horatu              )

     on key(f7)   call fsauc550( g_documento.sinramcod,
                                 g_documento.sinano   ,
                                 g_documento.sinnum   ,
                                 g_documento.sinitmseq )
                       returning w_flag

                  if  w_flag = false  then
                      error " Vistoria de sinistro nao realizada ate o momento "
                  end if

     on key(f8)   call fsauc560( g_documento.sinramcod,
                                 g_documento.sinano   ,
                                 g_documento.sinnum   ,
                                 g_documento.sinitmseq )
                       returning w_flag

                  if  w_flag = false  then
                      error " Nao ha nenhum documento pendente no momento "
                  end if

     on key(f9)   if  w_f9   then
                      error " Pendencia ja incluida! "
                  else
                      call fsaac026_tfa() returning ws.sintfacod,
                                                    ws.sintfades
                      if ws.sintfacod is not null then
                         if cts08g01( "A", "S",
                                   "","CONFIRMA INCLUSAO DE PENDENCIA ?",
                                   "",""                        ) = "S"  then
                            begin work
                            call fsaua595( g_documento.sinramcod,
                                          g_documento.sinano   ,
                                          g_documento.sinnum   ,
                                          g_documento.sinitmseq,
                                          135                  ,
                                          ws.sintfacod         ,
                                          g_issk.empcod        ,
                                          g_issk.funmat        ,
                                          w_sintfapndregemp    ,
                                          w_sintfapndregmat    ,
                                          w_anleqpcod           )
                                returning w_flag,
                                          w_acao
                            if  w_flag = 0     then
                                update DATRLIGSIN
                                set (ligsinpndflg,sintfacod)
                                  = ("S"         ,ws.sintfacod)
                                    where lignum = g_documento.lignum

                                if  sqlca.sqlcode = 0  then
                                   #let w_f9 = true
                                   #let w_msg = " Pendencia incluida! "
                                    let w_c24ligdsc = ws.sintfacod," - ",
                                                      ws.sintfades
                                    #call cts10g00_historico(1,
                                    #                     g_documento.lignum,
                                    #                     g_issk.funmat,
                                    #                     w_datatu,
                                    #                     w_horatu,
                                    #                     w_c24ligdsc)
                                    #    returning ws.tabname, ws.codigosql
                                    call ctd06g01_ins_datmlighist(g_documento.lignum,
                                                                  g_issk.funmat,
                                                                  w_c24ligdsc,
                                                                  w_datatu,
                                                                  w_horatu,
                                                                  g_issk.usrtip,
                                                                  g_issk.empcod  )
                                         returning ws.codigosql,  #retorno
                                                   ws.tabname   #mensagem
                                    #if ws.codigosql  =   0  then
                                    if ws.codigosql = 1 then
                                       let w_f9 = true
                                       let w_msg = " Pendencia incluida! "
                                       commit work
                                    else
                                       let w_msg = " Erro (", ws.codigosql, ")",
                                                   " na gravacao da tabela ",
                                                   " ws.tabname clipped,",
                                                   " AVISE A INFORMATICA!"
                                       rollback work
                                    end if
                                else
                                    let w_msg=" Erro na inclusao da pendencia!",
                                              " Erro (", sqlca.sqlcode, ") na",
                                              " atualizacao da tabela DATRLIGSIN."
                                    rollback work
                                end if
                            else
                                let w_msg = " Erro na inclusao da pendencia!",
                                            " Erro ", w_flag using "<<&"
                                rollback work
                            end if
                            error w_msg clipped
                         else
                            error "Inclusao de pendencia cancelada! "
                         end if
                      else
                        error "Inclusao de pendencia cancelada!!! "
                      end if
                  end if
                  sleep 2
                  error ""

     on key(f10)  call fsauc570( g_documento.sinramcod,
                                 g_documento.sinano   ,
                                 g_documento.sinnum   ,
                                 g_documento.sinitmseq )
                       returning w_flag

                  if  w_flag = false  then
                      error " Nao ha nenhum pagamento programado no momento "
                  end if

     on key(interrupt)
        if  cts08g01( "A", "S",
                      "","CONFIRMA CONCLUSAO ?",
                      "",""                     ) = "S"  then
            exit display
        end if

   end display


 #------------------------------------------------------------------------------
 # Abre tela de historico
 #------------------------------------------------------------------------------
   if not w_f9   then
      error " Registre as informacoes no historico!"
      call cta03n00( g_documento.lignum,
                     g_issk.funmat     ,
                     w_datatu          ,
                     w_horatu           )

   end if
 #------------------------------------------------------------------------------
 # Replica historico da Central no sinistro
 #------------------------------------------------------------------------------
   call cta06m00_replica_nota(g_documento.lignum)
   exit while
 end while

 close window  win_cta06m00
 let int_flag = false


end function  #  cta06m00
#----------------------------------------------#
function cta06m00_replica_nota(lr_param)
#----------------------------------------------#

define lr_param record
   lignum     like datmligacao.lignum
end record

define lr_retorno record
  sinramcod  like ssamsin.ramcod       ,
  sinano     like ssamsin.sinano       ,
  sinnum     like ssamsin.sinnum       ,
  sinitmseq  like ssamitem.sinitmseq   ,
  c24txtseq  like datmlighist.c24txtseq,
  c24ligdsc  like datmlighist.c24ligdsc,
  flag       smallint                  ,
  erro       smallint
end record

  initialize lr_retorno.* to null
  if m_prepare is null or
     m_prepare <> true then
     call cta06m00_prepare()
  end if
  let lr_retorno.flag = false
  let lr_retorno.erro = 0
  if g_documento.sinramcod is not null and
     g_documento.sinano    is not null and
     g_documento.sinnum    is not null and
     g_documento.sinitmseq is not null then
     let lr_retorno.sinramcod = g_documento.sinramcod
     let lr_retorno.sinano    = g_documento.sinano
     let lr_retorno.sinnum    = g_documento.sinnum
     let lr_retorno.sinitmseq = g_documento.sinitmseq
  else
     call cta06m00_recupera_sinistro(lr_param.lignum)
     returning lr_retorno.sinramcod ,
               lr_retorno.sinano    ,
               lr_retorno.sinnum    ,
               lr_retorno.sinitmseq ,
               lr_retorno.erro
  end if
  if lr_retorno.erro = 0 then
      error " Aguarde, gravando historico do sinistro!"
      begin work
      open ccta06m00m00001 using lr_param.lignum
      foreach ccta06m00m00001 into lr_retorno.c24txtseq,
                                   lr_retorno.c24ligdsc
          call fsaua590( lr_retorno.sinramcod  ,
                         lr_retorno.sinano     ,
                         lr_retorno.sinnum     ,
                         lr_retorno.sinitmseq  ,
                         g_issk.empcod         ,
                         g_issk.funmat         ,
                         lr_retorno.c24txtseq  ,
                         lr_retorno.c24ligdsc  )
               returning lr_retorno.flag
          if  lr_retorno.flag = true  then
              exit foreach
          end if
      end foreach
      if  lr_retorno.flag  then
          error " Erro na Gravacao do Historico do Sinistro !"
          rollback work
      else
          error " Replicacao de Notas Efetuada com Sucesso!"
          commit work
      end if
      sleep 2
      error ""
  end if
end function
#----------------------------------------------#
function cta06m00_recupera_sinistro(lr_param)
#----------------------------------------------#

define lr_param record
     lignum     like datmligacao.lignum
end record

define lr_retorno record
     sinramcod  like ssamsin.ramcod    ,
     sinano     like ssamsin.sinano    ,
     sinnum     like ssamsin.sinnum    ,
     sinitmseq  like ssamitem.sinitmseq,
     erro       smallint
end record

    initialize lr_retorno.* to null
    if m_prepare is null or
       m_prepare <> true then
       call cta06m00_prepare()
    end if
    let lr_retorno.erro = 0

    open ccta06m00m00002  using lr_param.lignum
    whenever error continue
    fetch ccta06m00m00002 into lr_retorno.sinramcod,
                               lr_retorno.sinano   ,
                               lr_retorno.sinnum   ,
                               lr_retorno.sinitmseq
    whenever error stop
    if sqlca.sqlcode <> 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao do sinistro. AVISE A INFORMATICA!"
       let lr_retorno.erro = 1
    end if

    close ccta06m00m00002
    return lr_retorno.sinramcod ,
           lr_retorno.sinano    ,
           lr_retorno.sinnum    ,
           lr_retorno.sinitmseq ,
           lr_retorno.erro

end function
