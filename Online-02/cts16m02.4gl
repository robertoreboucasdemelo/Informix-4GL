#############################################################################
# Nome do Modulo: CTS16M02                                            Ruiz  #
#                                                                  Fev/2002 #
# Registra ligacao para alteracao/consulta/cancelamento/retorno de          #
# sinistros de re/auto/aviso.                                               #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#---------------------------------------------------------------------------#
#                                                                           #
#                   * * * Alteracoes * * *                                  #
#                                                                           #
# Data       Autor  Fabrica  Origem    Alteracao                            #
# ---------- ------ -------  -------   -------------------------------------#
# 21/10/2004 Daniel, Meta    PSI188514 Nas chamadas da funcao cto00m00      #
#                                      passar como parametro o numero 1     #
#---------------------------------------------------------------------------#
# 03/02/2006 Priscila     Zeladoria    Buscar data e hora no banco de dados #
#---------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a  #
#                                         global                            #
#---------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

#----------------------------------------------------------------------------
 function cts16m02(param)
#----------------------------------------------------------------------------
   define param    record
     c24solnom     like datmligacao.c24solnom,
     c24soltipcod  like datmligacao.c24soltipcod,
     sinvstnum     like datrligsinvst.sinvstnum,
     sinvstano     like datrligsinvst.sinvstano,
     sinavsnum     like datrligsinavs.sinavsnum,
     sinavsano     like datrligsinavs.sinavsano,
     c24astcod     like datmligacao.c24astcod
   end record
   define d_cts16m02    record
      c24solnom         like datmligacao.c24solnom,
      c24soltipcod      like datmligacao.c24soltipcod,
      cmptip            char (03),
      texto             char (25)
   end record
   define hist            record
      c24txtseq         like datmservhist.c24txtseq,
      c24srvdsc         like datmservhist.c24srvdsc,
      c24funmat         like datmservhist.c24funmat,
      ligdat            like datmservhist.ligdat   ,
      lighorinc         like datmservhist.lighorinc,
      linha             char(3000)
   end record
   define ws            record
        pergunta        char(01)                   ,
        retorno         smallint                   ,
        lignum          like datmligacao.lignum    ,
        atdsrvnum       like datmservico.atdsrvnum ,
        atdsrvano       like datmservico.atdsrvano ,
        sqlcode         integer                    ,
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
        itaciacod       like datrligitaaplitm.itaciacod 
   end record
   define comando       char(3200)

   define l_data           date,
          l_hora2          datetime hour to minute


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	comando  =  null
	let	l_data  =  null
	let	l_hora2  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  d_cts16m02.*  to  null

	initialize  hist.*  to  null

	initialize  ws.*  to  null

	let	comando  =  null

	initialize  d_cts16m02.*  to  null

	initialize  hist.*  to  null

	initialize  ws.*  to  null

   let int_flag = false

   initialize d_cts16m02.*   to null
   initialize ws.*           to null

   let d_cts16m02.c24solnom    = param.c24solnom
   let d_cts16m02.c24soltipcod = param.c24soltipcod
   open window cts16m02 at 11,24 with form "cts16m02"
      attribute(border, form line 1)

   if param.c24astcod = "N10" or param.c24astcod = "N11" then
      let d_cts16m02.texto = "ALT, CON "
   else
      if param.c24astcod = "V12" then
         let d_cts16m02.texto = "ALT, CON, CAN, REC "
      else
         let d_cts16m02.texto = "ALT, CON, RET, CAN, REC "
      end if
   end if
   while true
     display by name d_cts16m02.*

     input by name d_cts16m02.* without defaults

       before field c24solnom
         display by name d_cts16m02.c24solnom attribute (reverse)
         display by name d_cts16m02.c24soltipcod attribute (reverse)
         next field cmptip

       after  field c24solnom
         display by name d_cts16m02.c24solnom

         if  d_cts16m02.c24solnom  is null   or
             d_cts16m02.c24solnom  =  "  "   then
             error " Informe o nome do solicitante!"
             next field c24solnom
         end if

       before field c24soltipcod
         display by name d_cts16m02.c24soltipcod attribute (reverse)

       after  field c24soltipcod
         display by name d_cts16m02.c24soltipcod

         if  fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field c24solnom
         end if

         if  d_cts16m02.c24soltipcod  is null   then
             error " Tipo do solicitante deve ser informado!"
             let d_cts16m02.c24soltipcod = cto00m00(1)
             next field c24soltipcod
         end if

         select c24soltipdes
           into ws.c24soltipdes
           from DATKSOLTIP
                where c24soltipcod = d_cts16m02.c24soltipcod

         if  sqlca.sqlcode = notfound  then
             error " Tipo de solicitante nao cadastrado!"
             let d_cts16m02.c24soltipcod = cto00m00(1)
             next field c24soltipcod
         end if

         display by name ws.c24soltipdes

       before field cmptip
         display by name d_cts16m02.cmptip  attribute (reverse)

       after  field cmptip
         display by name d_cts16m02.cmptip

        #if  fgl_lastkey() = fgl_keyval("up")   or
        #    fgl_lastkey() = fgl_keyval("left") then
        #    next field c24soltipcod
        #end if
         if  d_cts16m02.cmptip is null  then
             error " Informe o tipo do complemento!"
             next field cmptip
         else
             if param.c24astcod = "N10" or
                param.c24astcod = "N11" then
                if d_cts16m02.cmptip  <>  "ALT"  and
                   d_cts16m02.cmptip  <>  "CON"  then
                   error " Tipo do complemento invalido!"
                   next field cmptip
                end if
             end if
             if param.c24astcod = "V12" then
                if d_cts16m02.cmptip  <>  "ALT"  and
                   d_cts16m02.cmptip  <>  "CON"  and
                   d_cts16m02.cmptip  <>  "CAN"  and
                   d_cts16m02.cmptip  <>  "REC"  then
                   error " Tipo do complemento invalido!"
                   next field cmptip
                end if
             end if
             if d_cts16m02.cmptip  <>  "ALT"  and
                d_cts16m02.cmptip  <>  "CON"  and
                d_cts16m02.cmptip  <>  "RET"  and
                d_cts16m02.cmptip  <>  "CAN"  and
                d_cts16m02.cmptip  <>  "REC"  then
                error " Tipo do complemento invalido!"
                next field cmptip
             end if
         end if

       on key (interrupt)
          exit input

     end input
     if  int_flag = false  then
         let g_documento.acao = d_cts16m02.cmptip
         case d_cts16m02.cmptip
              when "ALT" error " Registre informacoes referentes a",
                               " alteracao no historico (F6)"
              when "CAN" error " Registre informacoes referentes ao",
                               " cancelamento no historico (F6)"
              when "REC" error " Registre informacoes referentes a",
                               " reclamacao no historico (F6)"
              when "RET" error " Registre informacoes referentes ao",
                               " retorno no historico (F6)"
              when "CON" error " Registre informacoes referentes a",
                               " consulta no historico (F6)"
              otherwise  error " Registre informacoes no historico (F6)!"
         end case
         if param.sinvstnum is not null then
            let ws.lignum = cts20g00_sinvst(param.sinvstnum, param.sinvstano,2)
         end if
         if param.sinavsnum is not null then
            let ws.lignum = cts20g00_sinavs(param.sinavsnum, param.sinavsano)
         end if
         select ligcvntip
           into ws.ligcvntip
           from DATMLIGACAo
                where lignum = ws.lignum

         if sqlca.sqlcode = notfound  then
            error " Ligacao do sinistro nao encontrada. AVISE A INFORMATICA!"
            prompt "" for char ws.pergunta
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
                        
         if ws.ramcod is null then
            if param.sinvstnum is not null then
               if ws.lignum is not null then
                  select ramcod
                     into ws.ramcod
                     from datrligsinvst
                    where lignum=ws.lignum
               end if
            end if
         end if
       #------------------------------------------------------------------------
       # Busca numeracao ligacao
       #------------------------------------------------------------------------
         begin work

         call cts10g03_numeracao( 1, "" )
              returning ws.lignum   ,
                        ws.atdsrvnum,
                        ws.atdsrvano,
                        ws.sqlcode  ,
                        ws.msg

         ---> Decreto - 6523
         let g_lignum_dcr = ws.lignum

         if  ws.sqlcode = 0  then
             commit work
         else
             let ws.msg = "CTS16M02 - ",ws.msg
             call ctx13g00(ws.sqlcode,"DATKGERAL",ws.msg)
             rollback work
             prompt "" for char ws.pergunta
             ---> Decreto - 6523
             let g_lignum_dcr = null
             exit while
         end if
         if param.sinvstnum is not null then
            let param.sinavsnum = null
            let param.sinavsano = null
           #if ws.ramcod = 31 then
            if param.c24astcod = "V12" then
               call cts21m03(param.sinvstnum,param.sinvstano)
            else
               call cts14m01(param.sinvstnum,param.sinvstano)
            end if
         end if
         if param.sinavsnum is not null then
            call figrc072_setTratarIsolamento()        --> 223689
            call cts18m00(param.sinavsnum,param.sinavsano)
            if g_isoAuto.sqlCodErr <> 0 then --> 223689
               error "Problemas na função cts18m00 ! Avise a Informatica !" sleep 2
               ---> Decreto - 6523
               let g_lignum_dcr = null

               exit while
            end if    --> 223689
            let param.sinvstnum = null
            let param.sinvstano = null
         end if
         begin work
         call cts40g03_data_hora_banco(2)
             returning l_data, l_hora2
         call cts10g00_ligacao (ws.lignum             ,
                                l_data                ,
                                l_hora2               ,
                                d_cts16m02.c24soltipcod,
                                d_cts16m02.c24solnom  ,
                                d_cts16m02.cmptip     ,
                                g_issk.funmat         ,
                                ws.ligcvntip ,
                                g_c24paxnum           ,
                                "","",
                                param.sinvstnum       ,
                                param.sinvstano       ,
                                param.sinavsnum  ,
                                param.sinavsano  ,
                                ws.succod             ,
                                ws.ramcod             ,
                                ws.aplnumdig          ,
                                ws.itmnumdig          ,
                                ws.edsnumref          ,
                                ws.prporg             ,
                                ws.prpnumdig          ,
                                "",""                 ,
                                "","","","",
                                "", "", "", ""        )
                      returning  ws.tabname, ws.sqlcode
         if  ws.sqlcode  <>  0  then
             error " Erro (", ws.sqlcode, ") na gravacao da",
                   " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
             rollback work
             prompt "" for char ws.pergunta
             ---> Decreto - 6523
             let g_lignum_dcr = null
             exit while
         end if
         commit work
     else
         error "Operacao cancelada !!"
     end if
     exit while
   end while
   let int_flag = false
   close window cts16m02
 end function
