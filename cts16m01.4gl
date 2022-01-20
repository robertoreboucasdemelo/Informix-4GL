#############################################################################
#function cts16m01_email()                                                  #
# Nome do Modulo: CTS16M01                                            Pedro #
#                                                                   Marcelo #
# Informa quem esta reclamando, alterando ou cancelando o servico  Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/10/1998  PSI 6895-0   Gilberto     Incluir novo codigo de complemento  #
#                                       (RET) para registrar retorno.       #
#---------------------------------------------------------------------------#
# 30/10/1998               Gilberto     Verificar data de conclusao antes   #
#                                       de registrar CANcelamento e/ou      #
#                                       REClamacao.                         #
#---------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00), passando parametros #
#                                       de registro via formulario.         #
#---------------------------------------------------------------------------#
# 21/10/1999  PSI 9118-9   Gilberto     Alterar funcao de gravacao da liga- #
#                                       cao (CTS10G00) para gravar as tabe- #
#                                       las de relacionamento.              #
#---------------------------------------------------------------------------#
# 07/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de  #
#                                       ligacoes x propostas.               #
#---------------------------------------------------------------------------#
# 13/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de      #
#                                       solicitante.                        #
#---------------------------------------------------------------------------#
# 23/06/2000  PSI 108650   Akio         Inclusao da funcao CTS10G03         #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#---------------------------------------------------------------------------#
# 29/05/2001  PSI 10865-0  Raji         Novos assuntos IND e CON para servi-#
#                                       cos.                                #
#---------------------------------------------------------------------------#
# 30/05/2001  PSI 11105-8  Marcus       Cancelamento Automatico de Servicos #
#                                       via MDT                             #
#---------------------------------------------------------------------------#
# 18/09/2001  PSI 13620    Ruiz         Cancelamento automatico de Servico  #
#                                       via INTERNET.                       #
#---------------------------------------------------------------------------#
# 19/03/2002  correio      Ruiz         abrir a tela com o cursor no campo  #
#                                       complemento.                        #
#---------------------------------------------------------------------------#
# 24/05/2002  PSI 15454-7  Wagner       Criar alerta para situacao RET      #
#---------------------------------------------------------------------------#
# 05/08/2002  PSI 15693-0  Ruiz         Enviar email via Send_email.        #
#---------------------------------------------------------------------------#
# 21/08/2002  PSI 15918-2  Wagner       Tratamento RET/COM para servicos RE #
#---------------------------------------------------------------------------#
# 23/05/2003  PSI 17218-9  Cesar Lucca  Cancelar servico, enviar msg via mdt#
#                                       e nao colocar a viatura em QRV.     #
#############################################################################
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI        Alteracao                             #
# ---------- ------------- ---------  --------------------------------------#
# 18/09/2003 Julianna,Meta PSI175552  Recebimento do parametro c24astcod    #
#                          OSF26077                                         #
#                                                                           #
# 21/10/2004 Daniel, Meta  PSI188514  Nas chamadas da funcao cto00m00       #
#                                     passar como parametro o numero 1      #
#---------------------------------------------------------------------------#
# 23/11/2004  Katiucia       CT 263281 Buscar assunto da ligacao            #
#---------------------------------------------------------------------------#
# 26/01/2006  Priscila     PSI198048  Desativar a opcao cancelamento do B14 #
#---------------------------------------------------------------------------#
# 03/02/2006  Priscila     Zeladoria  Buscar data e hora no banco de dados  #
#---------------------------------------------------------------------------#
# 25/09/2006  Ruiz         psi 202720 Buscar ligacao de apolice do Saude.   #
#---------------------------------------------------------------------------#
#...........................................................................#
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica PSI         Alteracao                            #
# ---------- ------------- ---------   -------------------------------------#
# 15/02/2007 Saulo,Meta    AS130087    Migracao para a versao 7.32          #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton,Meta   PSI 223689 Incluir tratamento de erro com       #
#                                      global ( Isolamento U01 )            #
#---------------------------------------------------------------------------#
# 03/11/2010 Carla Rampazzo PSI 000762 Tratamento para Help Desk Casa       #
#---------------------------------------------------------------------------#
# 26/02/2012 Celso Yamahaki CT121213035 Desbloqueio de viaturas quando o    #
#                                       assunto for CAN                     #
#---------------------------------------------------------------------------#
# 20-06-2013  PSI 11843   Kelly Lima    Programa Pomar - Alterar funcao     #
#                                       de insere_etapa para insere_etapa_mo#
#                                       tivo                                #  
#---------------------------------------------------------------------------#
# 22/07/2015 INTERA,Marcos SPR-2015-15533 Bloquear RETorno se Venda fechada.#
#---------------------------------------------------------------------------#
 globals  "/homedsa/projetos/geral/globals/glct.4gl"
 globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689


#----------------------------------------------------------------------
 function cts16m01(param)
#----------------------------------------------------------------------

 define param         record
    c24solnom         like datmligacao.c24solnom,
    c24soltipcod      like datmligacao.c24soltipcod,
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano,
    c24astcod         like datkassunto.c24astcod
 end record

 define l_assunto     like datkassunto.c24astcod

 define l_vndepacod   like datmvndepa.vndepacod   #=> SPR-2015-15533

 define d_cts16m01    record
    c24solnom         like datmligacao.c24solnom,
    c24soltipcod      like datmligacao.c24soltipcod,
    cmptip            char (03),
    msg               char (40)
 end record

 define ws              record
        prompt_key      char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        codigosql       integer                    ,
        tabname         like systables.tabname     ,
        msg             char(80)                ,
        c24soltipdes    like datksoltip.c24soltipdes,
        ligcvntip       like datmligacao.ligcvntip  ,
        succod          like datrligapol.succod     ,
        ramcod          like datrligapol.ramcod     ,
        aplnumdig       like datrligapol.aplnumdig  ,
        itmnumdig       like datrligapol.itmnumdig  ,
        edsnumref       like datrligapol.edsnumref  ,
        prporg          like datrligprp.prporg      ,
        prpnumdig       like datrligprp.prpnumdig   ,
        fcapacorg       like datrligpac.fcapacorg   ,
        fcapacnum       like datrligpac.fcapacnum   ,
        atdsrvorg       like datmservico.atdsrvorg  ,
        cnldat          like datmservico.cnldat     ,
        socvclcod       like datmservico.socvclcod  ,
        erroflg         integer                     ,
        atdetpcod       like datmsrvacp.atdetpcod   ,
        atdprscod       like datmservico.atdprscod  ,
        c24nomctt       like datmservico.c24nomctt  ,
        srrcoddig       like datmservico.srrcoddig  ,
        ins_etapa       integer                     ,
        retflg          dec (1,0)                   ,
        flgint          smallint                    ,
        atdetpseq       like datmsrvint.atdetpseq   ,
        mdtcod          like datkveiculo.mdtcod     ,
        ofnnumdig       like datmlcl.ofnnumdig      ,
        confirma        char (01)                   ,
        c24trxnum       like dammtrx.c24trxnum      ,
        ext             char (04)                   ,
        c24astcod_ret   like datmligacao.c24astcod  ,
        lintxt          like dammtrxtxt.c24trxtxt   ,# char(80)
        refatdsrvnum    like datmsrvjit.refatdsrvnum ,
        refatdsrvano    like datmsrvjit.refatdsrvnum,
        lignumjre       like datrligsinvst.lignum   ,
        c24astcodjre    like datmligacao.c24astcod  ,
        itaciacod       like datrligitaaplitm.itaciacod
 end record

 define hist            record
        c24txtseq       like datmservhist.c24txtseq,
        c24srvdsc       like datmservhist.c24srvdsc,
        c24funmat       like datmservhist.c24funmat,
        ligdat          like datmservhist.ligdat   ,
        lighorinc       like datmservhist.lighorinc,
        linha           char(3000)
 end record

 define wsh           record
        c24srvdsc       like datmservhist.c24srvdsc,
        ligdat          like datmservhist.ligdat   ,
        lighorinc       like datmservhist.lighorinc,
        atdsrvnum       like datmservico.atdsrvnum ,
        funnom          like isskfunc.funnom,
        ofnnumdig       like datmlcl.ofnnumdig,
        lclidttxt       like datmlcl.lclidttxt
 end record

 #CT121213035 Inicio
 define l_current record
        data like dattfrotalocal.cttdat,
        hora like dattfrotalocal.ctthor
 end record
 define l_sqlcacode integer
 #CT121213035 Fim
 
 #PSI 2013-11843 - Pomar (Cancelamento) - Inicio   
 define l_canmtvcod      like datmsrvacp.canmtvcod 
 define l_canmtvdsc      char(40)   
 #PSI 2013-11843 - Pomar (Cancelamento) - Fim   
 
 define comando         char(3200)

 define aux_ano4        char(04)
 define aux_jitre       char(01)
 define l_c24astcod     like datmligacao.c24astcod
 define l_or_c24astcod  like datmligacao.c24astcod
 define l_texto1        char(40)
 define l_texto2        char(40)

  define l_envio        smallint #psi175552

 define l_data            date,
        l_hora2           datetime hour to minute,
        l_hora1           datetime hour to second,
        l_resultado       smallint,
        l_pstcoddig       like datmsrvacp.pstcoddig,
        l_socvclcod       like datmsrvacp.socvclcod,  
        l_srrcoddig       like datmsrvacp.srrcoddig,
        l_envtipcod       like datmsrvacp.envtipcod,
        l_txttiptrx       char(20),
        l_mensagem        char(60)

 define l_tem_alerta  smallint

###################################
 define l_tem_s66 char(01)
 define l_tem_s67 char(01)
 define l_confirma char(01)

 define ret_cta02m15 record
        resultado    integer,
        mensagem     char(80)
 end record

 initialize ret_cta02m15.* to null
 initialize l_tem_s66      to null
 initialize l_tem_s67      to null
 initialize l_confirma     to null
 initialize l_pstcoddig    to null
 initialize l_envtipcod    to null
 initialize l_socvclcod    to null
 initialize l_srrcoddig    to null
 initialize l_txttiptrx    to null 
 initialize l_mensagem     to null
###################################


 initialize l_tem_alerta to null

 let	comando  =  null

 initialize  d_cts16m01.*  to  null

 initialize  ws.*  to  null

 initialize  hist.*  to  null

 initialize  wsh.*  to  null

 initialize aux_ano4 to null

 initialize l_assunto to null

 initialize ws.mdtcod to null  # viatura tem GPS

 let int_flag = false

 initialize d_cts16m01.*   to null
 initialize ws.*           to null
 initialize l_sqlcacode, l_current.* to null #CT121213035

 let d_cts16m01.c24solnom    = param.c24solnom
 let d_cts16m01.c24soltipcod = param.c24soltipcod

 let l_or_c24astcod = null

 let aux_jitre = "N"

 select cnldat,
        atdsrvorg,
        socvclcod,
        atdprscod,
        c24nomctt,
        srrcoddig
   into ws.cnldat,
        ws.atdsrvorg,
        ws.socvclcod,
        ws.atdprscod,
        ws.c24nomctt,
        ws.srrcoddig
   from datmservico
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano

  if ws.atdsrvorg = 8 then
     select pstcoddig into ws.atdprscod from datmsrvacp
        where atdsrvnum = param.atdsrvnum
          and atdsrvano = param.atdsrvano
          and atdsrvseq in (select max(atdsrvseq) from datmsrvacp
                              where atdsrvnum = param.atdsrvnum
                                and atdsrvano = param.atdsrvano
                                and pstcoddig is not null)
  end if

 #--------------------#
 # Verifica SE JIT-RE #
 #--------------------#
 select refatdsrvnum,
        refatdsrvano
   into ws.refatdsrvnum,
        ws.refatdsrvano
   from datmsrvjit
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 if sqlca.sqlcode = 0 then
    let aux_ano4 = "20" clipped, ws.refatdsrvano using "&&"

    select lignum into ws.lignumjre
      from datrligsinvst
     where sinvstnum = ws.refatdsrvnum
       and sinvstano = aux_ano4

    if sqlca.sqlcode = 0 then
       select c24astcod into ws.c24astcodjre
         from datmligacao
        where lignum = ws.lignumjre

       if ws.c24astcodjre = "V12" then
          let aux_jitre = "S"
       end if
    end if
 end if

 let d_cts16m01.msg = "ALT, CAN, REC, RET, CON ou IND"
 if ws.atdsrvorg = 11 or
    ws.atdsrvorg = 14 or
    ws.atdsrvorg = 18 then   #PSI198048
    let d_cts16m01.msg = "ALT, CON"
 end if
 if g_ppt.cmnnumdig is not null then
    let d_cts16m01.msg = "ALT, CAN, REC, RET ou CON"
 end if
 if aux_jitre = "S" then
    let d_cts16m01.msg = "ALT, CAN, REC ou CON"
 end if

 ---> S66-HDK-Telefonico ou S78-HDK Cortesia-Telefonico
 ---> Itau  R66-HDK-Telefonico ou R78-HDK Cortesia-Telefonico
 
 if param.c24astcod = "S66" or
    param.c24astcod = "S78" or
    param.c24astcod = "R66" or  	  
    param.c24astcod = "R78" then
    
    let d_cts16m01.msg = "ALT, CAN ou CON"
 end if

 open window cts16m01 at 11,24 with form "cts16m01"
      attribute(border, form line 1)

 while true
    display by name d_cts16m01.*


    input by name d_cts16m01.* without defaults

    before field c24solnom
       display by name d_cts16m01.c24solnom attribute (reverse)
       display by name d_cts16m01.c24soltipcod attribute (reverse)

       if d_cts16m01.c24solnom is not null then
          next field cmptip  # conforme correio do arnaldo 19/03/02.
       end if

    after  field c24solnom
       display by name d_cts16m01.c24solnom

       if  d_cts16m01.c24solnom  is null   or
           d_cts16m01.c24solnom  =  "  "   then
           error " Informe o nome do solicitante!"
           next field c24solnom
       end if

    before field c24soltipcod
       display by name d_cts16m01.c24soltipcod attribute (reverse)

    after  field c24soltipcod
       display by name d_cts16m01.c24soltipcod

       if  fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
             next field c24solnom
       end if

       if  d_cts16m01.c24soltipcod  is null   then
           error " Tipo do solicitante deve ser informado!"
           let d_cts16m01.c24soltipcod = cto00m00(1)
           next field c24soltipcod
       end if

       select c24soltipdes
         into ws.c24soltipdes
         from DATKSOLTIP
         where c24soltipcod = d_cts16m01.c24soltipcod

       if  sqlca.sqlcode = notfound  then
           error " Tipo de solicitante nao cadastrado!"
           let d_cts16m01.c24soltipcod = cto00m00(1)
           next field c24soltipcod
       end if

       display by name ws.c24soltipdes

    before field cmptip
       display by name d_cts16m01.cmptip  attribute (reverse)

    after  field cmptip
       display by name d_cts16m01.cmptip

       if  fgl_lastkey() = fgl_keyval("up")   or
           fgl_lastkey() = fgl_keyval("left") then
           next field c24soltipcod
       end if

       if  d_cts16m01.cmptip is null  then
           error " Informe o tipo do complemento!"
           next field cmptip
       else
          if aux_jitre = "S" then
             let d_cts16m01.msg = "ALT, CAN, REC ou CON"
             if  d_cts16m01.cmptip  <>  "ALT"  and
                 d_cts16m01.cmptip  <>  "CAN"  and
                 d_cts16m01.cmptip  <>  "REC"  and
                 d_cts16m01.cmptip  <>  "CON"  then
                 error " Tipo do complemento invalido!"
                 next field cmptip
             end if
          end if

          if ws.atdsrvorg = 11 or
             ws.atdsrvorg = 14 or
             ws.atdsrvorg = 18 then    #PSI198048

             # furto/roubo     ou laudo de vidros
             if d_cts16m01.cmptip  <>  "CON" and
                d_cts16m01.cmptip  <>  "ALT" then
                error " Tipo do complemento invalido para origem servico!"
                next field cmptip
             end if
          end if

          if g_ppt.cmnnumdig is not null and d_cts16m01.cmptip = "IND" then
             error " Tipo do complemento invalido para origem servico!"
             next field cmptip
          end if

          if  d_cts16m01.cmptip  <>  "ALT"  and
              d_cts16m01.cmptip  <>  "CAN"  and
              d_cts16m01.cmptip  <>  "REC"  and
              d_cts16m01.cmptip  <>  "JIT"  and
              d_cts16m01.cmptip  <>  "RET"  and
              d_cts16m01.cmptip  <>  "CON"  and
              d_cts16m01.cmptip  <>  "IND"  then
              error " Tipo do complemento invalido!"
              next field cmptip
          end if

          ---> S66-HDK-Telefonico ou S78-HDK Cortesia-Telefonico
          ---> Itau  R66-HDK-Telefonico ou R78-HDK Cortesia-Telefonico
          
          if param.c24astcod = "S66" or
             param.c24astcod = "S78" or
             param.c24astcod = "R66" or                
             param.c24astcod = "R78" then

             if d_cts16m01.cmptip <> "CAN" and
                d_cts16m01.cmptip <> "CON" and
                d_cts16m01.cmptip <> "ALT" then
                error " Tipo do complemento invalido!"
                next field cmptip
             end if

             if d_cts16m01.cmptip = "CAN" then

                call cts10g04_ultima_etapa(param.atdsrvnum
                                          ,param.atdsrvano)
                                 returning ws.atdetpcod

                if ws.atdetpcod = 5 then  ---> Cancelamento
                   error " Servico ja esta Cancelado. "
                   next field cmptip
                end if

		initialize l_texto1,l_texto2 to null

                let l_texto1 = "DESEJA REALMENTE CANCELAR O"

                if param.c24astcod = "S66" then
                   let l_texto2 = "ATENDIMENTO DO ASSUNTO 'S66' ?"
                end if
                
                if param.c24astcod = "S78" then     
                   let l_texto2 = "ATENDIMENTO DO ASSUNTO 'S78' ?"
                end if
                
                if param.c24astcod = "R66" then                       
                   let l_texto2 = "ATENDIMENTO DO ASSUNTO 'R66' ?"    
                end if                                                
                                                                      
                if param.c24astcod = "R78" then                       
                   let l_texto2 = "ATENDIMENTO DO ASSUNTO 'R78' ?"    
                end if      
                
               
                call cts08g01("A","S", ""
                              ,l_texto1
                              ,l_texto2
                              ,"" )
                     returning l_confirma

                if l_confirma = "N" then
                   next field cmptip
                end if
             end if
          end if
       end if

       #---------------------------------------------------------------------
       # Se data da conclusao e' anterior a dois dias, nao registrar CAN/REC
       #---------------------------------------------------------------------

       call cts40g03_data_hora_banco(2)
            returning l_data, l_hora2

       if g_issk.funmat <> 5048 then  # arnaldo 14/05/02. - ruiz

          if d_cts16m01.cmptip = "CAN"        and
             ws.cnldat < l_data - 5 units day  then
             error " Nao e' possivel cancelar servico concluido ",
                   " a mais de cinco dias!"
             next field cmptip
          end if
       end if

       #if  d_cts16m01.cmptip = "REC"        and
       #    ws.cnldat < l_data - 2 units day  then
       #    error " Nao e' possivel registrar reclamacao para ",
       #          " servico concluido a mais de dois dias!"
       #    next field cmptip
       #end if

       if d_cts16m01.cmptip = "RET"  then

          if ws.atdsrvorg <> 13      and    # Sinistro RE
             ws.atdsrvorg <> 9       then   # Socorro RE
             error " Retorno so' pode ser registrado para ",
                   " servicos de Socorro/Sinistro R.E.!"
             next field cmptip
          end if

          #--------------------------------
          # Verifica RET
          #--------------------------------
          declare c_ret cursor for
             select datmligacao.c24astcod
               from datmligacao
              where datmligacao.atdsrvnum  = param.atdsrvnum
                and datmligacao.atdsrvano  = param.atdsrvano
                and datmligacao.lignum    <> 0

          initialize ws.c24astcod_ret to null

          foreach c_ret into ws.c24astcod_ret
             if ws.c24astcod_ret = "RET"  then
                exit foreach
             end if
          end foreach
          if ws.c24astcod_ret = "RET"  then
             error " Nao pode ser efetuado um (RET)orno de um (RET)orno!"
             next field cmptip
          end if

          call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
               returning ws.atdetpcod
          if ws.atdetpcod <> 3 then
             error " Nao pode ser efetuado um (RET)orno de um servico ",
                   "sem acionamento!"
             next field cmptip
          end if

          #=> SPR-2015-15533 - NAO PERMITIR SE 'VIS TEC', 'VIS PREST' OU 'CANC'
          whenever error continue
          select e.vndepacod
            into l_vndepacod
            from datmsrvvnd v, datmvndepa e
           where v.atdsrvnum = param.atdsrvnum
             and v.atdsrvano = param.atdsrvano
             and e.atdsrvnum = v.atdsrvnum
             and e.atdsrvano = v.atdsrvano
             and e.vndepacod in (4, #=> VISITA TECNICA
                                 5, #=> VISITA PRESTADOR
                                 7) #=> CANCELADO
          whenever error stop
          if sqlca.sqlcode <= 0 then
             if sqlca.sqlcode < 0 then
                error "ERRO ", sqlca.sqlcode, " ", sqlca.sqlerrd[2],
                      " NO ACESSO A 'datmsrvvnd/datmvndepa'!!"
             else
                if l_vndepacod = 4 then
                   error "Servico fechado como VISITA TECNICA nao permite RET"
                else
                   if l_vndepacod = 5 then
                      error "Servico fechado como VISITA PRESTADOR nao",
                            " permite RET"
                   else
                      error "Servico fechado como CANCELADO nao permite RET"
                   end if
                end if
             end if
             next field cmptip
          end if
       end if

       if d_cts16m01.cmptip = "IND" then
          select ofnnumdig into ws.ofnnumdig
            from datmlcl
           where atdsrvnum = param.atdsrvnum
             and atdsrvano = param.atdsrvano
             and c24endtip = 2

          if ws.ofnnumdig is null or
             ws.ofnnumdig = 0 then
             error " Nao e' possivel registrar IND para",
                   " servico sem oficina! Utilize CON"
             next field cmptip
          end if
       end if

       on key (interrupt)
       exit input
    end input



    if int_flag = false  then
       let g_documento.acao = d_cts16m01.cmptip
       case d_cts16m01.cmptip
            when "ALT" error " Registre informacoes referentes a",
                             " alteracao no historico (F6)"
            when "CAN" error " Registre informacoes referentes ao",
                             " cancelamento no historico (F6)"
            when "REC" error " Registre informacoes referentes a",
                             " reclamacao no historico (F6)"
            when "RET" error " Registre informacoes referentes ao",
                             " retorno no historico (F6)"
            when "IND" error " Registre informacoes referentes a",
                             " oficina no historico (F6)"
            when "CON" error " Registre informacoes referentes a",
                             " consulta no historico (F6)"
            otherwise  error " Registre informacoes no historico (F6)!"
       end case

       #------------------------------------------------------------------------
       # Chamada das telas de servicos
       #------------------------------------------------------------------------
       let g_documento.solnom       = d_cts16m01.c24solnom
       let g_documento.c24soltipcod = d_cts16m01.c24soltipcod

       let g_documento.atdsrvnum = param.atdsrvnum
       let g_documento.atdsrvano = param.atdsrvano

       #-----------------------------------------------------------------------
       # Registra na ligacao do servico a alteracao, cancelamento, reclamacao
       #-----------------------------------------------------------------------
       let ws.lignum = cts20g00_servico(param.atdsrvnum, param.atdsrvano)

       let l_c24astcod = null
       select ligcvntip, c24astcod
         into ws.ligcvntip
             ,l_c24astcod
         from datmligacao
              where lignum = ws.lignum

       if sqlca.sqlcode = notfound  then
          error " Ligacao do servico nao encontrada. AVISE A INFORMATICA!"
          prompt "" for char ws.prompt_key
          exit while
       end if

       call cts20g01_docto(ws.lignum)
            returning ws.succod,
                      ws.ramcod,
                      ws.aplnumdig,
                      ws.itmnumdig,
                      ws.edsnumref,
                      ws.prporg,
                      ws.prpnumdig,
                      ws.fcapacorg,
                      ws.fcapacnum,
                      ws.itaciacod

       ---[psi202720 se ramo e null pesquisar se a ligacao e do saude ]----
       if ws.ramcod is null then
          call cts20g09_docto(2,ws.lignum)
                returning ws.succod   ,
                          ws.ramcod   ,
                          ws.aplnumdig,
                          g_documento.crtsaunum,
                          g_documento.bnfnum
       end if

       #------------------------------------------------------------------------
       # Busca numeracao ligacao / servico
       #------------------------------------------------------------------------

       if d_cts16m01.cmptip = "RET"  then

          if aux_jitre = "S" then
             call cts21m03(ws.refatdsrvnum, aux_ano4)
             exit while
          end if

          if  cts04g00('cts16m01') = false  then
              exit while
          end if

          update DATMSRVRE
             set atdsrvretflg = "S"
           where atdsrvnum = param.atdsrvnum
             and atdsrvano = param.atdsrvano

          if  sqlca.sqlcode  <>  0  then
              error " Erro (", sqlca.sqlcode, ") na atualizacao da",
                    " tabela DATMSRVRE. AVISE A INFORMATICA!"
              prompt "" for char ws.prompt_key
              exit while
          end if
       else
          begin work
          call cts10g03_numeracao( 1, "" )
                        returning ws.lignum   ,
                                  ws.atdsrvnum,
                                  ws.atdsrvano,
                                  ws.codigosql,
                                  ws.msg

          if  ws.codigosql = 0  then
              commit work
          else
              let ws.msg = "CTS16M01 - ",ws.msg
              call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
              rollback work
              prompt "" for char ws.prompt_key
              exit while
          end if

          ---> Decreto - 6523
          let g_lignum_dcr = ws.lignum

          if ws.atdsrvorg  = 14 then             # obter a nova ligacao para
             let g_documento.lignum = ws.lignum  # gravar datmsrvext(cts19m00).
          end if

          if aux_jitre = "S" then
             call cts21m03(ws.refatdsrvnum, aux_ano4)
          else
             if cts04g00('cts16m01') = false  then
                exit while
             end if
          end if

          begin work

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2

          call cts10g00_ligacao( ws.lignum              ,
                                 l_data                 ,
                                 l_hora2                ,
                                 d_cts16m01.c24soltipcod,
                                 d_cts16m01.c24solnom   ,
                                 d_cts16m01.cmptip      ,
                                 g_issk.funmat          ,
                                 ws.ligcvntip           ,
                                 g_c24paxnum            ,
                                 param.atdsrvnum        ,
                                 param.atdsrvano        ,
                                 "","","",""            ,
                                 ws.succod              ,
                                 ws.ramcod              ,
                                 ws.aplnumdig           ,
                                 ws.itmnumdig           ,
                                 ws.edsnumref           ,
                                 "","","",""            ,
                                 "","","",""            ,
                                 "","","","")
                       returning ws.tabname,
                                 ws.codigosql

          if  ws.codigosql  <>  0  then
              error " Erro (", ws.codigosql, ") na gravacao da",
                    " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
              rollback work
              prompt "" for char ws.prompt_key
              exit while
          end if

          if d_cts16m01.cmptip = "CAN"   then
             if ws.atdsrvorg =  1   or
                ws.atdsrvorg =  2   or
                ws.atdsrvorg =  4   or
                ws.atdsrvorg =  5   or
                ws.atdsrvorg =  6   or
                ws.atdsrvorg =  7   or
                ws.atdsrvorg =  3   or
                ##ws.atdsrvorg =  8   or #ligia - 30/05/11
                ws.atdsrvorg =  9   or
               (ws.atdsrvorg = 15  and aux_jitre = "S") or
                ws.atdsrvorg = 17   or
                ws.atdsrvorg = 14   then

                call cts10g04_ultima_etapa(param.atdsrvnum, param.atdsrvano)
                        returning ws.atdetpcod

                if ws.atdetpcod =  1 or ws.atdetpcod = 43 then
                   #PSI 2013-11843 - Pomar (Cancelamento) - Inicio
                   #call cts10g05_popup_motivo_cancelamento() 
                   #returning l_canmtvcod, l_canmtvdsc

                   call cts10g04_insere_etapa_motivo(param.atdsrvnum,
                                                     param.atdsrvano,
                                                     "5",
                                                     ws.atdprscod,
                                                     ws.c24nomctt,
                                                     ws.socvclcod,
                                                     ws.srrcoddig,
                                                     0) #Código motivo de cancelamento REMOCAO da POP UP Brunno
                        returning ws.ins_etapa
                   #PSI 2013-11843 - Pomar (Cancelamento) - Fim
                   
                   if  ws.ins_etapa  <>  0  then
                       error " Erro (", ws.ins_etapa, ") na gravacao da",
                             " etapa de cancelamento. AVISE A INFORMATICA!"
                       rollback work
                       prompt "" for char ws.prompt_key
                       exit while
                   end if

                   update datmservico
                   set atdfnlflg = "S"
                   where atdsrvnum = param.atdsrvnum and
                         atdsrvano = param.atdsrvano

                   if  sqlca.sqlcode  <>  0  then
                       error " Erro (", sqlca.sqlcode, ") na atualizacao",
                             " do servico. AVISE A INFORMATICA! "
                       rollback work
                       prompt "" for char ws.prompt_key
                       exit while
                   end if
                end if

                if ws.atdetpcod = 43 or
                   ws.atdetpcod = 4  or
                   ws.atdetpcod = 3 then

                   --->Se assunto S66 ou S78(telef.)-Insere Etapa 5-Cancelado
                   --->Se assunto R66 ou R78(telef.)-Insere Etapa 5-Cancelado
                   
                   if param.c24astcod = "S66" or
                      param.c24astcod = "S78" or
                      param.c24astcod = "R66" or    	
                      param.c24astcod = "R78" then  
                      

                      call cts10g04_insere_etapa(param.atdsrvnum
                                                ,param.atdsrvano
                                                ,"5"   --> Cancelado
                                                ,10573 --> Fixo p/ S66 e S78
                                                ,""
                                                ,""
                                                ,"")
                      returning ws.ins_etapa

                      if  ws.ins_etapa  <>  0  then
                          error " Erro (", ws.ins_etapa, ")na gravacao da",
                                " etapa de cancelamento.AVISE A INFORMATICA!"
                          rollback work
                          prompt "" for char ws.prompt_key
                          exit while
                      end if
                      
                   else
                   	
                      if ctx34g00_ver_acionamentoWEB(2) and ctx34g00_origem(param.atdsrvnum,param.atdsrvano) then
                      
                        # obtem informações do ultima etapa	
                        select envtipcod, pstcoddig, socvclcod, srrcoddig
                              into l_envtipcod, l_pstcoddig, l_socvclcod, l_srrcoddig
                          from datmsrvacp acp
                         where acp.atdsrvnum = param.atdsrvnum
                           and acp.atdsrvano = param.atdsrvano
                           and acp.atdsrvseq = (select max(acpmax.atdsrvseq)
                                                  from datmsrvacp acpmax
                                                 where acpmax.atdsrvnum = param.atdsrvnum
                                                   and acpmax.atdsrvano = param.atdsrvano )
                          
                        case l_envtipcod
                            when 0  # VOZ
                               let l_txttiptrx = 'VOZ'
                            when 1  # GPS
                               let l_txttiptrx = 'GPS'
                            when 2  # INTERNET
                               let l_txttiptrx = 'INTERNET'
                            when 3  # FAX
                               let l_txttiptrx = 'FAX'
                        end case
                      
                        call ctx34g02_conclusao_servico(param.atdsrvnum,
                                                        param.atdsrvano,
                                                        5,
                                                        l_pstcoddig,
                                                        l_socvclcod,
                                                        l_srrcoddig,
                                                        l_txttiptrx,
                                                        g_issk.usrtip,
                                                        g_issk.empcod,
                                                        g_issk.funmat,
                                                        'S')
                             returning l_resultado,
                                        l_mensagem
                      
                              error l_mensagem sleep 2
                              
                         if l_resultado <> 0 then
                            rollback work
                            prompt "" for char ws.prompt_key
                            exit while
                         else
                            call cts10g04_insere_etapa_completo(param.atdsrvnum     ,
                                                                   param.atdsrvano     ,
                                                                   5,
                                                                   l_pstcoddig,
                                                                   ws.c24nomctt,
                                                                   l_socvclcod,
                                                                   l_srrcoddig,
                                                                   0,           #Nao SincronizaAW
								   0) #Código motivo de cancelamento) #Código motivo de cancelamento l_canmtvcod REMOCAO da POP UP Brunno
                                 returning ws.ins_etapa
                         	
                         end if
                      	  
                      else
                         if ws.socvclcod is not null then # verifica se a
                            select mdtcod into ws.mdtcod
                              from datkveiculo
                              where socvclcod = ws.socvclcod
                         end if
                         
                         let ws.flgint  =   0
                         
                         select count(*) into ws.flgint   # verifica se o
                           from datmsrvintseqult       # e de internet
                          where atdsrvnum = param.atdsrvnum
                            and atdsrvano = param.atdsrvano
                         
                         if ws.mdtcod is not null or
                            ws.atdsrvorg = 14 or
                            ws.flgint > 0     then
                         
                            #Se for pela Internet
                            if ws.flgint > 0 then
                         
                               #Verifica se prestador está conectado no Portal Negócios
                               let l_resultado = fissc101_prestador_sessao_ativa(ws.atdprscod
                                                                            ,'PSRONLINE')
                         
                               #Prestador conectado
                               if l_resultado then

                            #PSI 2013-11843 - Pomar (Cancelamento) - Inicio
                            #Chama popup solicitando o motivo de cancelamento
                            #call cts10g05_popup_motivo_cancelamento() 
                            #returning l_canmtvcod, l_canmtvdsc
                            
                            call cts10g04_insere_etapa_motivo(param.atdsrvnum,
                                                              param.atdsrvano,
                                                              "5",
                                                              ws.atdprscod,
                                                              ws.c24nomctt,
                                                              ws.socvclcod,
                                                              ws.srrcoddig,
                                                              0) #Código motivo de cancelamento REMOCAO da POP UP Brunno
                            returning ws.ins_etapa
                            #PSI 2013-11843 - Pomar (Cancelamento) - Fim
                         
                                  if ws.ins_etapa  <>  0  then
                                     error " Erro (", ws.ins_etapa, ")na gravacao da",
                                                   " etapa de cancelamento.AVISE A INFORMATICA!"
                                     rollback work
                                     prompt "" for char ws.prompt_key
                                     exit while
                                  end if
                         
                                  if ws.flgint    >    0  then
                                     let ws.atdetpseq = null
                         
                                     select max (atdetpseq)
                                       into ws.atdetpseq
                                       from datmsrvint
                                      where atdsrvnum = param.atdsrvnum
                                        and atdsrvano = param.atdsrvano
                         
                                     if ws.atdetpseq is null then
                                        let ws.atdetpseq = 0
                                     end if
                         
                                     let ws.atdetpseq  =  ws.atdetpseq + 1
                         
                                     call cts40g03_data_hora_banco(1)
                                          returning l_data, l_hora1
                         
                                     insert into datmsrvint
                                                (atdsrvnum,
                                                 atdsrvano,
                                                 atdetpseq,
                                                 atdetpcod,
                                                 cadorg   ,
                                                 pstcoddig,
                                                 cademp   ,
                                                 cadusrtip,
                                                 cadmat   ,
                                                 caddat   ,
                                                 cadhor   ,
                                                 etpmtvcod,
                                                 srvobs   ,
                                                 atlemp   ,
                                                 atlmat   ,
                                                 atlusrtip,
                                                 atldat   ,
                                                 atlhor)
                                         values (param.atdsrvnum,
                                                 param.atdsrvano,
                                                 ws.atdetpseq,
                                                 3,   # etapa de cancelamento
                                                 "0", # origem porto
                                                 ws.atdprscod,
                                                 g_issk.empcod,
                                                 g_issk.usrtip,
                                                 g_issk.funmat,
                                                 l_data,
                                                 l_hora1,
                                                 1, #Kelly - Código do Motivo: Cancelado pelo cliente
                                                 "","","","","","" )
                         
                                     if sqlca.sqlcode <>  0  then
                                        error " Erro (",sqlca.sqlcode, ")na inclusao",
                                                      " tabela datmsrvint ",
                                                      " AVISE A INFORMATICA! "
                                        rollback work
                                        prompt "" for char ws.prompt_key
                                        exit while
                                     end if
                         
                                     update datmsrvintseqult
                                       set (atdetpcod,
                                            atdetpseq)
                                         = (3,
                                            ws.atdetpseq)  #atz ultima seq. do servico
                                       where atdsrvnum = param.atdsrvnum
                                         and atdsrvano = param.atdsrvano
                         
                                     if sqlca.sqlcode <>  0  then
                                        error " Erro (",sqlca.sqlcode, ")no update ",
                                                      " da tabela datmsrvintseqult.",
                                                      " AVISE A INFORMATICA! "
                                        rollback work
                                        prompt "" for char ws.prompt_key
                                        exit while
                                     end if
                                  end if
                               else
                                  error 'Prestador nao conectado no Portal de Negocios.'
                               end if
                            end if
                         
                            if ws.flgint    =    0  and
                               ws.atdsrvorg <>   14 then
			       
                               #PSI 2013-11843 - Pomar (Cancelamento) - Inicio
                               #Chama popup solicitando o motivo de cancelamento
                               #call cts10g05_popup_motivo_cancelamento() 
                               #     returning l_canmtvcod, l_canmtvdsc  
                         
                               call cts10g04_insere_etapa_motivo(param.atdsrvnum,
                                                                 param.atdsrvano,
                                                                 "5",
                                                                 ws.atdprscod,
                                                                 ws.c24nomctt,
                                                                 ws.socvclcod,
                                                                 ws.srrcoddig,
                                                                 0) #Código Motivo de Cancelamento REMOCAO da POP UP Brunno
                                   returning ws.ins_etapa
                               #PSI 2013-11843 - Pomar (Cancelamento) - Fim
                         
                               call cts00g02_env_msg_mdt(1, param.atdsrvnum,
                                                         param.atdsrvano,
                                                         "",
                                                         ws.socvclcod)
                                       returning ws.erroflg
                         
                               if ws.erroflg <>  0  then
                                  error " Erro (", ws.erroflg, ") no envio da",
                                        " mensagem de cancelamento.",
                                        " AVISE A INFORMATICA!"
                                  rollback work
                                  prompt "" for char ws.prompt_key
                                  exit while
                               end if
                               
                               #CT121213035 Início
                               
                               if ws.socvclcod is not null then
                                  call cts40g03_data_hora_banco(2)
                                     returning l_current.data,
                                               l_current.hora
                               
                                  call cts33g01_posfrota ( ws.socvclcod,
                                                 "S",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 "",
                                                 l_current.data,
                                                 l_current.hora,
                                                 "QRV",
                                                 "",
                                                 "" )
                                       returning l_sqlcacode
                                  if l_sqlcacode <> 0 then
                                     Display "erro: ", l_sqlcacode, " ao atualizar a posicao da frota!"
                                  end if
                               end if
                               #CT121213035 Fim
                      
                            end if
                         end if
                      end if
                   end if
                   
                   update datmservico
                   set atdfnlflg = "S"
                   where atdsrvnum = param.atdsrvnum and
                         atdsrvano = param.atdsrvano

                   if  sqlca.sqlcode  <>  0  then
                       error " Erro (",sqlca.sqlcode, ") na atualizacao",
                             " do servico. AVISE A INFORMATICA! "
                       rollback work
                       prompt "" for char ws.prompt_key
                       exit while
                   end if

                end if

             end if
          end if
          commit work
          call cts00g07_apos_grvlaudo(param.atdsrvnum,param.atdsrvano)
          if d_cts16m01.cmptip = "CAN" then
             call cts00m42_email_cancelamento(param.atdsrvnum,param.atdsrvano)
          end if
       end if

       case d_cts16m01.cmptip
          when "ALT"  error " Alteracao registrada com sucesso!"
          when "CAN"  error " Cancelamento registrado com sucesso!"
          when "REC"  error " Reclamacao registrada com sucesso!"
          when "RET"  error " Retorno registrado com sucesso!"
          when "CON"  error " Consulta registrado com sucesso!"
          when "IND"  error " Consulta oficina registrado com sucesso!"
       end case

       ###########################################################
       # Envio de correio indicacao de oficinas
       ###########################################################
       # MONTA HISTORICO
       if d_cts16m01.cmptip <> "CON" then
          error " Aguarde enviando e-mail ..."

          # -- CT 263281 - Katiucia -- #
          if param.c24astcod is null or
             param.c24astcod  = " "  then
             let param.c24astcod = l_c24astcod
          end if

          if d_cts16m01.cmptip = "IND" then
             let l_assunto = "IND"
          else
             let l_assunto = param.c24astcod
          end if

          if d_cts16m01.cmptip = "RET" then
             let l_assunto = "RET"
          else
             let l_assunto = param.c24astcod
          end if
          if d_cts16m01.cmptip = "REC" then
             let l_assunto = "REC"
          else
             let l_assunto = param.c24astcod
          end if
          call figrc072_setTratarIsolamento() -- > psi 223689

          call cts30m00(ws.ramcod,l_assunto,ws.ligcvntip,ws.succod,ws.aplnumdig,
                        ws.itmnumdig,ws.lignum,param.atdsrvnum,param.atdsrvano,ws.prporg,
                     ws.prpnumdig,d_cts16m01.c24solnom)
              returning l_envio        #psi175552
          error ""

          if g_isoAuto.sqlCodErr <> 0 then  -- > 223689
             error "Problemas na função cts30m00 ! Avise a Informatica !" sleep 2
             return
          end if        -- > 223689
       end if
    else
        error " Operacao cancelada!"
    end if

    initialize g_documento.acao     ,
               g_documento.atdsrvnum,
               g_documento.atdsrvano to null

    exit while
 end while

 let int_flag = false

 close window cts16m01

end function  ###  cts16m01


{
#-----------------------------------------------------------------
function cts16m01_email(param)
#-----------------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define l_lcvcod            like datmavisrent.lcvcod,
        l_aviestcod         like datmavisrent.aviestcod

 call cts36g00_dados_locacao(2, param.atdsrvnum, param.atdsrvano)
      returning l_lcvcod, l_aviestcod

 if g_documento.ciaempcod =  1 then
 call cts15m00_acionamento(param.atdsrvnum, param.atdsrvano
                           ,l_lcvcod, l_aviestcod, 3,'3')
 end if
 if g_documento.ciaempcod = 35 then
    call cts15m15_acionamento(param.atdsrvnum, param.atdsrvano
                             ,l_lcvcod, l_aviestcod, 3,'3')
 end if

end function

}
#----------------------------------------------------------------------
 function cts16m01_rec_serv_original(lr_param)
#----------------------------------------------------------------------

define lr_param record
   atdsrvnum    like datmservico.atdsrvnum,
   atdsrvano    like datmservico.atdsrvano
end record

define lr_retorno record
  c24astcod like datmligacao.c24astcod
end record

initialize lr_retorno.* to null

  select c24astcod
  into lr_retorno.c24astcod
  from datmligacao
  where lignum in (select min(lignum)
                   from  datmligacao
                   where atdsrvnum = lr_param.atdsrvnum
                   and   atdsrvano = lr_param.atdsrvano  )


  if sqlca.sqlcode <> 0 then
    error "Erro ao Recuperar o Servico Original, Erro: ", sqlca.sqlcode
  end if

  return lr_retorno.c24astcod

end function


#----------------------------------------------------------------------
 function cts16m01_rec_apolice(lr_param)
#----------------------------------------------------------------------

define lr_param record
   atdsrvnum    like datmservico.atdsrvnum,
   atdsrvano    like datmservico.atdsrvano,
   c24astcod    like datmligacao.c24astcod
end record

define lr_retorno record
  succod    like datrligapol.succod   ,
  ramcod    like datrligapol.ramcod   ,
  aplnumdig like datrligapol.aplnumdig,
  itmnumdig like datrligapol.itmnumdig,
  edsnumref like datrligapol.edsnumref,
  lignum    like datrligapol.lignum
end record

initialize lr_retorno.* to null

  select lignum
  into   lr_retorno.lignum
  from   datmligacao
  where  atdsrvnum = lr_param.atdsrvnum
  and    atdsrvano = lr_param.atdsrvano
  and    c24astcod = lr_param.c24astcod

  select succod    ,
         ramcod    ,
         aplnumdig ,
         itmnumdig ,
         edsnumref
  into lr_retorno.succod    ,
       lr_retorno.ramcod    ,
       lr_retorno.aplnumdig ,
       lr_retorno.itmnumdig ,
       lr_retorno.edsnumref
  from datrligapol
  where lignum = lr_retorno.lignum

  if sqlca.sqlcode <> 0 then
    error "Erro ao Recuperar Apolice,  Erro: ", sqlca.sqlcode
  end if

  return lr_retorno.succod   ,
         lr_retorno.ramcod   ,
         lr_retorno.aplnumdig,
         lr_retorno.itmnumdig,
         lr_retorno.edsnumref

end function
