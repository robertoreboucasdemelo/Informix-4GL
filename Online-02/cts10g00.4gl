###############################################################################
# Nome do Modulo: CTS10G00                                           Marcelo  #
#                                                                    Gilberto #
# Funcoes genericas de gravacao das tabelas da Central 24 Horas      Ago/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 23/11/1998  PSI 7214-1   Gilberto     Gravar dados referentes a digitacao   #
#                                       via formulario.                       #
#-----------------------------------------------------------------------------#
# 20/08/1999  Pdm #30938   Gilberto     Colocado mensagem de erro para exi-   #
#                                       bir campo que houve erro -391         #
#-----------------------------------------------------------------------------#
# 20/10/1999  PSI 9118-9   Gilberto     Gravar tabelas de relacionamento de   #
#                                       servicos, vistorias e avisos.         #
#-----------------------------------------------------------------------------#
# 29/10/1999  PSI 9118-9   Gilberto     Criacao de funcao generica para       #
#                                       gravacao do historico da ligacao.     #
#-----------------------------------------------------------------------------#
# 01/12/1999  PSI 7263-0   Gilberto     Gravar tabela de relacionamento de    #
#                                       ligacoes x propostas.                 #
#-----------------------------------------------------------------------------#
# 15/02/2000  PSI 10079-0  Gilberto     Gravar campo C24SOLTIPCOD a partir    #
#                                       do campo C24SOLTIP, que sera' remo-   #
#                                       vido posteriormente.                  #
#-----------------------------------------------------------------------------#
# 02/03/2000  PSI 10079-0  Akio         Inclusao da tabela de tipos de        #
#                                       solicitante.                          #
#-----------------------------------------------------------------------------#
# 27/03/2000  PSI 10079-0  Akio         Atendimento da perda parcial          #
#-----------------------------------------------------------------------------#
# 23/06/2000  PSI 10865-0   Akio        A funcao passa a receber o numero     #
#                                       da ligacao                            #
#-----------------------------------------------------------------------------#
# 14/11/2002  PSI 15963-8  Ruiz         Grava relacionamento da ligacao com a #
#                                       fila de apoio.                        #
###############################################################################
#.......................................................................... #
#                  * * *  ALTERACOES  * * *                                 #
#                                                                           #
# Data       Autor Fabrica  PSI      Alteracao                              #
# ---------- -------------  -------- ---------------------------------------#
# 22/10/2003 Julianna,Meta PSI172413 Registrar no sistema todas as ligacoes #
#                          OSF027987 sem documento.                         #
# ---------- ------------- --------- ---------------------------------------#
# 16/12/2003 Paulo, Meta   PSI180475 1) Inserir o parametro (codigomotivo)  #
#                          OSF 30228    na funcao cts10g00_ligacao).        #
#                                    2) Gravar o relacionamento ligacao x   #
#                                       motivo.                             #
#---------------------------------------------------------------------------#
# 13/01/2004 ivone, Meta      PSI180475 alterar select da inclusao          #
#                             OSF030228                                     #
# 01/02/2005 Farias           CT5015000 Queda de tela, na tabela datrligapol#
#                                       o campo edsnumref não pode receber  #
#                                       nulo.                               #
#---------------------------------------------------------------------------#
#                         * * * Alteracoes * * *                            #
#                                                                           #
# Data        Autor Fabrica Origem     Alteracao                             #
# ----------  ------------- ---------  --------------------------------------#
# 09/08/2005  Paulo, Meta   PSI194212  Enviar e-mail com titulo:             #
#                                      Gravando atendimento sem assunto      #
# ----------  ------------- ---------  --------------------------------------#
# 02/02/2006  Priscila      Zeladoria  Buscar data e hora do banco de dados  #
# ----------  ------------- ---------  --------------------------------------#
# 23/09/2006  Ruiz          psi202720  Gravar tabelas do ramo Saude.         #
# ----------  ------------- ---------  --------------------------------------#
# 15/11/2006  Ruiz          psi205206  Gravar empresa na datmligacao.(Azul)  #
# ----------  ------------- ---------  --------------------------------------#
# 29/01/2008  Alinne, Meta             Inclusao de gravacao de dados de PSS  #
#----------------------------------------------------------------------------#
# 22/04/2010  Roberto Melo  PSI242853  Implementacao do PSS                  #
#----------------------------------------------------------------------------#
# 10/12/2010  Carla Rampazzo PSI 00762 Acerto de pgm tratar if de insert do  #
#                                      dartligapol e do datrligsau - HDK     #
##############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql   smallint #psi172413

#----------------------------#
 function cts10g00_prepara()
#----------------------------#
   define l_sqlstmt  char(900)

   let l_sqlstmt = ' insert into datrligcor (lignum,corsus,dctcomatdflg) ',
                   '  values(?,?,"S") '

   prepare p_cts10g00_001 from l_sqlstmt

   let l_sqlstmt = ' insert into datrligtel (lignum,dddcod,teltxt) ',
                   '  values(?,?,?) '

   prepare p_cts10g00_002 from l_sqlstmt

   let l_sqlstmt = ' insert into datrligmat (lignum,funmat,empcod,usrtip) ',
                   '  values(?,?,?,?) '

   prepare p_cts10g00_003 from l_sqlstmt

   let l_sqlstmt = ' insert into datrligcgccpf(lignum,cgccpfnum,cgcord,cgccpfdig,crtdvgflg) ',
                   '    values(?,?,?,?,?) '

   prepare p_cts10g00_004 from l_sqlstmt

   let l_sqlstmt = ' insert into datrligrcuccsmtv (lignum,rcuccsmtvcod,c24astcod) '
                                        ,' values (?,?,?) '

   prepare p_cts10g00_005 from l_sqlstmt

   let l_sqlstmt = ' insert into datrligsemapl(lignum    '
                                           ,' ,ligdcttip '
                                           ,' ,ligdctnum '
                                           ,' ,dctitm)   '
                       ,' values(?,?,?,?) '

   prepare p_cts10g00_006 from l_sqlstmt

   let l_sqlstmt = ' insert into igbmparam(relsgl     '
                                       ,' ,relpamseq  '
                                       ,' ,relpamtip  '
                                       ,' ,relpamtxt) '
                       ,' values(?,1,null,?) '

   prepare p_cts10g00_007 from l_sqlstmt

   let l_sqlstmt = ' update igbmparam '
                  ,'    set relpamtxt = ? '
                  ,'  where relsgl    = ? '
                  ,'    and relpamseq = 1 '
                  ,'    and relpamtip is null '

   prepare p_cts10g00_008 from l_sqlstmt

   let l_sqlstmt = ' select 1 '
                  ,'   from igbmparam '
                  ,'  where relsgl    = ? '
                  ,'    and relpamseq = 1 '
                  ,'    and relpamtip is null '

   prepare p_cts10g00_009 from l_sqlstmt
   declare c_cts10g00_001 cursor for p_cts10g00_009
   let l_sqlstmt = ' insert into datrcntlig(lignum     '
                                        ,' ,psscntcod) '
                                        ,' values(?,?) '
   prepare pcts10g00010 from l_sqlstmt
   let l_sqlstmt = ' select atdnum ',
                   ' from datratdlig ',
                   ' where lignum = ?'
   prepare pcts10g00011 from l_sqlstmt
   declare ccts10g00011 cursor for pcts10g00011
   let l_sqlstmt = " select count(*) from datratdlig a , datmligacao b ",
                   " where  a.lignum = b.lignum and ",
                   " b.c24astcod in ('SAP','KAP') and ",
                   " a.atdnum = ? "
   prepare pcts10g00012 from l_sqlstmt
   declare ccts10g00012 cursor for pcts10g00012
   let m_prep_sql = true

end function

#-------------------------------------------------------------------------------
 function cts10g00_ligacao (param)
#-------------------------------------------------------------------------------

 define param            record
        lignum           like datmligacao.lignum,
        ligdat           like datmligacao.ligdat,
        lighorinc        like datmligacao.lighorinc,
        c24soltipcod     like datksoltip.c24soltipcod,
        c24solnom        like datmligacao.c24solnom,
        c24astcod        like datmligacao.c24astcod,
        c24funmat        like datmligacao.c24funmat,
        ligcvntip        like datmligacao.ligcvntip,
        c24paxnum        like datmligacao.c24paxnum,
        atdsrvnum        like datrligsrv.atdsrvnum,
        atdsrvano        like datrligsrv.atdsrvano,
        sinvstnum        like datrligsinvst.sinvstnum,
        sinvstano        like datrligsinvst.sinvstano,
        sinavsnum        like datrligsinavs.sinavsnum,
        sinavsano        like datrligsinavs.sinavsano,
        succod           like datrligapol.succod,
        ramcod           like datrligapol.ramcod,
        aplnumdig        like datrligapol.aplnumdig,
        itmnumdig        like datrligapol.itmnumdig,
        edsnumref        like datrligapol.edsnumref,
        prporg           like datrligprp.prporg,
        prpnumdig        like datrligprp.prpnumdig,
        fcapacorg        like datrligpac.fcapacorg,
        fcapacnum        like datrligpac.fcapacnum,
        sinramcod        like ssamsin.ramcod    ,
        sinano           like ssamsin.sinano    ,
        sinnum           like ssamsin.sinnum    ,
        sinitmseq        like ssamitem.sinitmseq,
        caddat           like datmligfrm.caddat,
        cadhor           like datmligfrm.cadhor,
        cademp           like datmligfrm.cademp,
        cadmat           like datmligfrm.cadmat
                         end record

 define retorno          record
        tabname          char (30),
        sqlcode          integer
                         end record

 define ws               record
        c24soltip        like datmligacao.c24soltip,
        c24funmat        like datmligacao.c24funmat
                         end record

 define arr_aux          integer
 define wtot integer #ligia

 define l_relsgl like igbmparam.relsgl
 define l_dctitm smallint

 let arr_aux  = null
 let l_relsgl = null
 let l_dctitm = null

 initialize ws.*      to null
 initialize retorno.* to null

 if m_prep_sql is null or m_prep_sql <> true then  #psi172413
    call cts10g00_prepara()
 end if  #fim psi172413

 if param.c24funmat is null then
    let ws.c24funmat = g_issk.funmat
 else
    let ws.c24funmat = param.c24funmat
 end if
 --------------------------------------------------------------------
 # Quando a chamada e fora do online,alimentar a global para gravar
 # datmligacao.
 # Quando a chamada e via online a global empresa esta carregada.
 # Alteração para Azul Seguros - psi 205206 - 15/11/06.

 if g_documento.crtsaunum is not null and
    g_documento.crtsaunum <> 0        then
    let g_documento.ciaempcod = 50 # empresa Porto Saude
 end if

 if g_documento.ciaempcod is null or
    g_documento.ciaempcod =  0    then  # 01/03/07 Ruiz
    let g_documento.ciaempcod = 1 # empresa Porto Seguro
 end if



 --------------------------------------------------------------------


 while true

   select c24soltipdes[1,1]
     into ws.c24soltip
     from DATKSOLTIP
          where c24soltipcod = param.c24soltipcod

   if  sqlca.sqlcode = 0  then
       if  param.c24soltipcod > 2  then
           let ws.c24soltip = "O"
       end if
   else
       let ws.c24soltip = "O"
   end if

   let arr_aux = 1

 #------------------------------------------------------------------------------
 # Grava dados da ligacao
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   whenever error continue
   insert into DATMLIGACAO ( lignum      ,
                             ligdat      ,
                             lighorinc   ,
                             lighorfnl   ,
                             c24soltip   ,
                             c24soltipcod,
                             c24solnom   ,
                             c24astcod   ,
                             c24usrtip   ,
                             c24empcod   ,
                             c24funmat   ,
                             atdsrvnum   ,
                             atdsrvano   ,
                             ligcvntip   ,
                             c24paxnum   ,
                             ciaempcod   )
                    values ( param.lignum      ,
                             param.ligdat      ,
                             param.lighorinc   ,
                             param.lighorinc   ,
                             ws.c24soltip      ,
                             param.c24soltipcod,
                             param.c24solnom   ,
                             param.c24astcod   ,
                             g_issk.usrtip     ,
                             g_issk.empcod     ,
                             ws.c24funmat      ,
                             param.atdsrvnum   ,
                             param.atdsrvano   ,
                             param.ligcvntip   ,
                             param.c24paxnum   ,
                             g_documento.ciaempcod )

   if  sqlca.sqlcode <> 0  then
       let retorno.tabname = "DATMLIGACAO"
       let retorno.sqlcode = sqlca.sqlcode

       if sqlca.sqlcode = -391 or sqlca.sqlcode = -271 then
          let retorno.tabname = upshift(sqlca.sqlerrm)
       end if

       exit while
   end if


 #------------------------------------------------------------------------------
 # Grava dados do responsavel pela digitacao do formulario
 #------------------------------------------------------------------------------
 let retorno.sqlcode = 0
   if  param.caddat is not null  and
       param.cadhor is not null  and
       param.cademp is not null  and
       param.cadmat is not null  then

       insert into DATMLIGFRM ( lignum,
                                caddat,
                                cadhor,
                                cademp,
                                cadmat )
                       values ( param.lignum,
                                param.caddat,
                                param.cadhor,
                                param.cademp,
                                param.cadmat )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATMLIGFRM"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if


 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Ordem de Servico
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  param.atdsrvnum is not null  and
       param.atdsrvano is not null  then

       insert into DATRLIGSRV ( lignum   ,
                                atdsrvnum,
                                atdsrvano )
                       values ( param.lignum   ,
                                param.atdsrvnum,
                                param.atdsrvano )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGSRV"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if


 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Vistoria de Sinistro
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  param.sinvstnum is not null  and
       param.sinvstano is not null  then

       insert into DATRLIGSINVST ( lignum   ,
                                   ramcod   ,
                                   sinvstnum,
                                   sinvstano )
                          values ( param.lignum   ,
                                   param.ramcod   ,
                                   param.sinvstnum,
                                   param.sinvstano )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGSINVST"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if


 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Aviso de Sinistro
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  param.sinavsnum is not null  and
       param.sinavsano is not null  then

       insert into DATRLIGSINAVS ( lignum   ,
                                   sinavsnum,
                                   sinavsano )
                          values ( param.lignum   ,
                                   param.sinavsnum,
                                   param.sinavsano )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGSINAVS"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if

   #----------------------------------------------------------------------------
   # Sequencia do Local de Risco/ Bloco - So p/ Docto RE.
   #----------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if g_documento.lclnumseq is not null and
      g_documento.rmerscseq is not null then

      insert into datmrsclcllig (lignum
                                ,lclnumseq
                                ,rmerscseq )
                         values (param.lignum
                                ,g_documento.lclnumseq
                                ,g_documento.rmerscseq )

      if sqlca.sqlcode <> 0  then
         let retorno.tabname = "DATMRSCLCLLIG"
         let retorno.sqlcode = sqlca.sqlcode

         if sqlca.sqlcode = -391  then
            let retorno.tabname = upshift(sqlca.sqlerrm)
         end if

         exit while
      end if
   end if

 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Sinistro (Perda Parcial)
 #
 # OBS: Alem deste relacionamento, o relacionamento Ligacao x Apolice
 #      tambem e gravado para exibicao de todos os atendimentos.
 # ---: Este if precisa ficar antes da gravacao do documento apolice
 #      pois as globais de apolice tambem estao carregadas para
 #      este tipo de documento.
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  param.sinramcod is not null  and
       param.sinano    is not null  and
       param.sinnum    is not null  and
       param.sinitmseq is not null  then

       insert into DATRLIGSIN ( lignum   ,
                                ramcod   ,
                                sinano   ,
                                sinnum   ,
                                sinitmseq )
                       values ( param.lignum    ,
                                param.sinramcod ,
                                param.sinano    ,
                                param.sinnum    ,
                                param.sinitmseq  )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "datrligsin"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if

 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Apolice
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if (param.ramcod    is not null   and
       param.succod    is not null   and
       param.aplnumdig is not null   and
       param.itmnumdig is not null        ) and
      (g_documento.crtsaunum is null or
       g_documento.crtsaunum =  0         ) then

       if g_documento.ciaempcod = 84 then
          if param.edsnumref is null or
          	 param.edsnumref = 0     then
             call cts01g00_valida_endosso_itau(param.succod     ,
                                               param.ramcod     ,
                                               param.aplnumdig  )
             returning  param.edsnumref
          end if
       else
          if param.edsnumref is null then
             call cts01g00_valida_endosso(param.succod     ,
                                          param.ramcod     ,
                                          param.aplnumdig  )
             returning  param.edsnumref
          end if
       end if

       if g_documento.ciaempcod = 1 then

          let wtot = 0
          if param.ramcod = 31 or param.ramcod = 531 then
             select count(*) into wtot from abamapol
                    where succod = param.succod
                    and   aplnumdig = param.aplnumdig

          else
             select count(*) into wtot from rsamseguro
                    where succod = param.succod
                    and   ramcod = param.ramcod
                    and   aplnumdig = param.aplnumdig
          end if
       end if

       ##############################################################
       let retorno.sqlcode = 0
       insert into DATRLIGAPOL ( lignum   ,
                                 succod   ,
                                 ramcod   ,
                                 aplnumdig,
                                 itmnumdig,
                                 edsnumref )
                        values ( param.lignum   ,
                                 param.succod   ,
                                 param.ramcod   ,
                                 param.aplnumdig,
                                 param.itmnumdig,
                                 param.edsnumref )
       whenever error stop
       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGAPOL"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391 or sqlca.sqlcode = -271 then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if
   -------------[ grava relacionamento carta saude x ligacao ]--------------
   # utilizando a propia global para evitar alterações em mais 50 modulos
   # que chamam o cts10g00, inclusive modulos que utilizam MQ. Ruiz

   if g_documento.crtsaunum is not null and
      g_documento.crtsaunum <> 0        then
      insert into datrligsau  ( lignum   ,
                                succod   ,
                                ramcod   ,
                                aplnumdig,
                                bnfnum   ,
                                crtnum    )
                       values ( param.lignum   ,
                                param.succod   ,
                                param.ramcod   ,
                                param.aplnumdig,
                                g_documento.bnfnum,
                                g_documento.crtsaunum)
      whenever error stop
      if  sqlca.sqlcode <> 0  then
          let retorno.tabname = "DATRLIGSAU"
          let retorno.sqlcode = sqlca.sqlcode
          if  sqlca.sqlcode = -391 or sqlca.sqlcode = -271 then
              let retorno.tabname = upshift(sqlca.sqlerrm)
          end if
          exit while
      end if
   end if
 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Proposta
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  param.prporg    is not null  and
       param.prpnumdig is not null  then

       insert into DATRLIGPRP ( lignum   ,
                                prporg   ,
                                prpnumdig )
                       values ( param.lignum   ,
                                param.prporg   ,
                                param.prpnumdig )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGPRP"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if


 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x Ligacao Itau
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  g_documento.ciaempcod  = 84 and
       g_documento.itaciacod  is not null  then

       insert into DATRLIGITAAPLITM ( itaciacod      ,
                                      itaramcod      ,
                                      itaaplnum      ,
                                      aplseqnum      ,
                                      itaaplitmnum   ,
                                      lignum )
                             values ( g_documento.itaciacod ,
                                      param.ramcod          ,
                                      param.aplnumdig       ,
                                      param.edsnumref       ,
                                      param.itmnumdig       ,
                                      param.lignum   )


       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGITAAPLITM"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if


 #------------------------------------------------------------------------------
 # Grava dados do relacionamento Ligacao x P.A.C.
 #------------------------------------------------------------------------------
   let retorno.sqlcode = 0
   if  param.fcapacorg is not null  and
       param.fcapacnum is not null  then

       insert into DATRLIGPAC  ( lignum   ,
                                 fcapacorg,
                                 fcapacnum )
                        values ( param.lignum   ,
                                 param.fcapacorg,
                                 param.fcapacnum )

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGPAC"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if

   ### Grava dados do relacionamento Ligacao x Motivo

   let retorno.sqlcode = 0

   # DVP 80896 U10-Motivo, atribuido nulo para não gravar Motivo 0(Zero) da tabela datrligrcuccsmtv
   if param.c24astcod = "U10" then
      let g_documento.rcuccsmtvcod = null
   end if
   # # DVP 80896 U10-Motivo
   if param.lignum is not null             and
      g_documento.rcuccsmtvcod is not null and
      param.c24astcod is not null          then
      whenever error continue
      execute p_cts10g00_005 using param.lignum
                                ,g_documento.rcuccsmtvcod
                                ,param.c24astcod                            #psi180475  ivone
      whenever error stop
      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT datrligrcuccsmtv:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'CTS10G00 /cts10g00_ligacao() / ',param.lignum,'/'
                                               ,g_documento.rcuccsmtvcod,'/'
                                               ,param.c24astcod sleep 2      #psi180475  ivone

         let retorno.sqlcode = sqlca.sqlcode

         if sqlca.sqlcode = -391 then
            let retorno.tabname = upshift(sqlca.sqlerrm)
         else
            let retorno.tabname = "DATRLIGRCUCCSMTV"
         end if

         exit while
       end if
   end if

#----------------------------------------------------------------------
# Grava dados do relacionamento Ligacao x P.P.T.(PROTECAO PATRIMONIAL)
#----------------------------------------------------------------------
   #MARIANA
   let retorno.sqlcode = 0
   if g_ppt.cmnnumdig is not null and
      g_ppt.cmnnumdig > 0 then

       insert into DATRLIGPPT ( lignum   ,
                                cmnnumdig )
                       values ( param.lignum   ,
                                g_ppt.cmnnumdig)

       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATRLIGPPT"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if

#----------------------------------------------------------------------
# Grava dados do relacionamento Ligacao x APOIO
#----------------------------------------------------------------------
   # RUIZ/ruiz
   let retorno.sqlcode = 0
   if g_documento.funmatatd is not null and
      g_documento.funmatatd > 0 then
      insert into datmligatd ( lignum,
                               atdemp,
                               atdmat,
                               atdtip,
                               apoemp,
                               apomat,
                               apotip )
                  values     ( param.lignum,
                               g_issk.empcod,
                               g_issk.funmat,
                               g_issk.usrtip,
                               g_documento.empcodatd,
                               g_documento.funmatatd,
                               g_documento.usrtipatd)
       if  sqlca.sqlcode <> 0  then
           let retorno.tabname = "DATMLIGATD"
           let retorno.sqlcode = sqlca.sqlcode

           if  sqlca.sqlcode = -391  then
               let retorno.tabname = upshift(sqlca.sqlerrm)
           end if

           exit while
       end if
   end if
   let retorno.sqlcode = 0
   if g_documento.corsus is not null then  #psi172413
      whenever error continue
      execute p_cts10g00_001 using param.lignum,
                                 g_documento.corsus
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT datrligcor:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'Cts10g00_ligacao/ ',param.lignum,'/',
                                    g_documento.corsus     sleep 2

         if sqlca.sqlcode = -391  then
            let retorno.tabname = upshift(sqlca.sqlerrm)
         else
            let retorno.tabname = 'DATRLIGCOR'
         end if

         let retorno.sqlcode = sqlca.sqlcode

         exit while

      end if

   end if
   let retorno.sqlcode = 0
   if g_documento.dddcod is not null and g_documento.ctttel is not null then
      whenever error continue
      execute p_cts10g00_002 using param.lignum,
                                 g_documento.dddcod,
                                 g_documento.ctttel

      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT datrligtel:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'Cts10g00_ligacao/ ',param.lignum,'/',
                                    g_documento.dddcod,'/',
                                    g_documento.ctttel  sleep 2


         if sqlca.sqlcode = -391  then
            let retorno.tabname = upshift(sqlca.sqlerrm)
         else
            let retorno.tabname = 'DATRLIGTEL'
         end if

         let retorno.sqlcode = sqlca.sqlcode

         exit while

      end if

   end if
   let retorno.sqlcode = 0
   if g_documento.funmat is not null then
      whenever error continue
      execute p_cts10g00_003 using param.lignum,
                                 g_documento.funmat,
                                 g_issk.empcod,
                                 g_issk.usrtip

      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT datrligmat:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'Cts10g00_ligacao/ ',param.lignum,'/',
                                    g_documento.funmat,'/',
                                    g_issk.empcod,'/',
                                    g_issk.usrtip sleep 2
         if sqlca.sqlcode = -391  then
            let retorno.tabname = upshift(sqlca.sqlerrm)
         else
            let retorno.tabname = 'DATRLIGMAT'
         end if

         let retorno.sqlcode = sqlca.sqlcode

         exit while

      end if

   end if
   let retorno.sqlcode = 0
   if g_documento.cgccpfnum is not null then
      whenever error continue
      execute p_cts10g00_004 using param.lignum,
                                 g_documento.cgccpfnum,
                                 g_documento.cgcord,
                                 g_documento.cgccpfdig,
                                 g_crtdvgflg

      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT datrligcgccpf:',sqlca.sqlcode,'|',sqlca.sqlerrd[2] sleep 2
         error 'Cts10g00_ligacao/ ',param.lignum, '/',
                                    g_documento.cgccpfnum,'/',
                                    g_documento.cgcord,'/',
                                    g_documento.cgccpfdig,'/',
                                    g_crtdvgflg sleep 2

         if sqlca.sqlcode = -391  then
            let retorno.tabname = upshift(sqlca.sqlerrm)
         else
            let retorno.tabname = 'DATRLIGCGCCPF'
         end if

         let retorno.sqlcode = sqlca.sqlcode

         exit while

      end if

   end if    # fim psi172413


   #Gravacao de dados para PSS - Porto Seguro Servicos

   if g_documento.ciaempcod = 43  and # PSI 247936 Empresas 27
      g_pss.psscntcod is not null and
      g_pss.psscntcod <> 0        then
      whenever error continue
      execute pcts10g00010 using param.lignum
                                ,g_pss.psscntcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT pcts10g00010: ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2] sleep 2
         error 'cts10g00 / Cts10g00_ligacao()/ ',param.lignum
                                          ,' / ',g_pss.psscntcod sleep 2
         let retorno.sqlcode = sqlca.sqlcode
         exit while
      end if
   end if

    # Gravacao da Cobertura Provisoria e Vistoria Previa


   if g_cgccpf.ligdctnum is not null and  #Verifica se o Atendimento via VP ou CP
      g_cgccpf.ligdcttip is not null then

      whenever error continue
      execute p_cts10g00_006 using param.lignum
                                ,g_cgccpf.ligdcttip
                                ,g_cgccpf.ligdctnum
                                ,l_dctitm
      whenever error stop


      if sqlca.sqlcode <> 0 then
         error 'Erro INSERT p_cts10g00_006 ',sqlca.sqlcode,' | ',sqlca.sqlerrd[2] sleep 2
         error 'cts10g00 / Cts10g00_ligacao()/ ',param.lignum
                                          ,' / ',g_cgccpf.ligdcttip
                                          ,' / ',g_cgccpf.ligdctnum
                                          ,' / ',l_dctitm  sleep 2
         let retorno.sqlcode = sqlca.sqlcode
         exit while
      end if

      exit while

   end if


   exit while

 end while

 return retorno.*

 end function
#===============================================
function cts10g00_verifica_multiplo(l_param)
#===============================================
 define l_param record
       lignum like datmligacao.lignum
 end record
 define lr_retorno record
       coderro    smallint,
       mensagem   char(100)
 end record
 define l_atdnum like datmatd6523.atdnum
       ,l_count  smallint
 initialize lr_retorno.* to null
 let l_atdnum = null
 let l_count = 0
 if m_prep_sql is null or
    m_prep_sql = false then
    call cts10g00_prepara()
 end if
 whenever error continue
  open ccts10g00011 using l_param.lignum
  fetch ccts10g00011 into l_atdnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.coderro = sqlca.sqlcode
       let lr_retorno.mensagem = "Erro <",sqlca.sqlcode ,"> Ao buscar numero de atendimento. Avise a Informatica !"
       call errorlog(lr_retorno.mensagem)
       return lr_retorno.*
    else
       let lr_retorno.coderro = sqlca.sqlcode
       let lr_retorno.mensagem = "Erro <",sqlca.sqlcode ,"> Ao buscar numero de atendimento. Avise a Informatica !"
       call errorlog(lr_retorno.mensagem)
       return lr_retorno.*
    end if
 end if
 close ccts10g00011
 whenever error continue
  open  ccts10g00012 using l_atdnum
  fetch ccts10g00012 into l_count
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> 100 then
       let lr_retorno.coderro = sqlca.sqlcode
       let lr_retorno.mensagem = "Erro <",sqlca.sqlcode ,"> Ao buscar atendimentos multiplos. Avise a Informatica !"
       call errorlog(lr_retorno.mensagem)
       return lr_retorno.*
    end if
 end if
 close ccts10g00012
 if l_count > 0 then
    let lr_retorno.coderro = 1
 end if
 return lr_retorno.*
end function
