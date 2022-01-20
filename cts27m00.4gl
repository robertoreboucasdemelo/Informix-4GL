################################################################################
# Nome do Modulo: cts27m00                                            Ruiz     #
# Laudo de Averbacao de transportes no Ct24hs.                        Mai/2002 #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920  Resolucao 86                     #
# 10/05/2004  Leandro             CT-207365   Alterar select p/ trazer seq 1   #
#------------------------------------------------------------------------------#
# 07/02/2006  Priscila    Zeladoria   Buscar data e hora do banco de dados     #
#------------------------------------------------------------------------------#
# 21/12/2006 Priscila          CT          Chamar funcao especifica para       #
#                                          insercao em datmlighist             #
#------------------------------------------------------------------------------#
# 15/02/2007 Fabiano, Meta    AS 130087  Migracao para a versao 7.32           #
# 29/02/2008 Amilton, Meta      psi219967   incluir retorno na chamada da      #
#                                            função cta00m16_chama_prog e      #
#                                            validar o retorno                 #
#------------------------------------------------------------------------------#
# 18/10/2008 Carla Rampazzo  PSI 230650 Passar p/ "ctg18" o campo atdnum       #
#------------------------------------------------------------------------------#
# 18/03/2010 Carla Rampazzo  PSI 219444 Passar p/ "ctg18" os campos            #
#                                       lclnumseq / rmerscseq (RE)             #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


define  m_dtresol86          date
#-------------------------------------------------------------------------------
 function cts27m00(param)
#-------------------------------------------------------------------------------
   define param           record
          numero          dec(06,0),
          tela            char(08)
   end record
   define ws              record
          promptq          char(01)                   ,
          retorno         smallint                   ,
          lignum          like datmligacao.lignum    ,
          atdsrvnum       like datmservico.atdsrvnum ,
          atdsrvano       like datmservico.atdsrvano ,
          codigosql       integer                    ,
          tabname         like systables.tabname     ,
          msg             char(80)                   ,
          comando         char (900)                 ,
          grlchv          like datkgeral.grlchv      ,
          grlinf          like datkgeral.grlinf      ,
          contador        integer                    ,
          sgrorg          like rsamseguro.sgrorg     ,
          sgrnumdig       like rsamseguro.sgrnumdig  ,
          segnumdig       like rsdmdocto.segnumdig   ,
          cgccpfnum       like gsakseg.cgccpfnum     ,
          cgcord          like gsakseg.cgcord        ,
          cgccpfdig       like gsakseg.cgccpfdig     ,
          data            char(10)                   ,
          hora            char(05)                   ,
          param           char(100)                  ,
          flgcontinua     char(01)                   ,
          sissgl          like ibpmsistprog.sissgl   ,
          ret             integer                    ,
          c24txtseq       like datmlighist.c24txtseq ,
          c24funmat       like datmlighist.c24funmat ,
          c24ligdsc       like datmlighist.c24ligdsc ,
          ligdat          like datmlighist.ligdat    ,
          lighorinc       like datmlighist.lighorinc ,
          confirma        char (1),
          succod          like datrligapol.succod,
          ramcod          like datrligapol.ramcod,
          aplnumdig       like datrligapol.aplnumdig,
          itmnumdig       like datrligapol.itmnumdig,
          edsnumref       like datrligapol.edsnumref,
          prporg          like datrligprp.prporg,
          prpnumdig       like datrligprp.prpnumdig,
          c24astcod       like datmligacao.c24astcod
   end record

   define a_historico  array[100] of record
          lignum          like datmlighist.lignum
   end record
   define retorno  record
          numero          dec(06,0),
          continua        char(1)
   end record
   define arr_aux    smallint
   define l_ramsgl   char(15)
   define l_status       smallint # PSI219967  Amilton Fim

   define l_data     date,
          l_hora2    datetime hour to minute,
          l_ret      smallint,
          l_mensagem char(50),
          l_maquina  char(03)

	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  100
		initialize  a_historico[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

	initialize  retorno.*  to  null

        initialize ws.*  to null
        initialize l_status to null


 select grlinf[01,10] into m_dtresol86
    from datkgeral
    where grlchv='ct24resolucao86'

   let ws.succod     =  g_documento.succod
   let ws.ramcod     =  g_documento.ramcod
   let ws.aplnumdig  =  g_documento.aplnumdig
   let ws.itmnumdig  =  g_documento.itmnumdig
   let ws.edsnumref  =  g_documento.edsnumref
   let ws.prporg     =  g_documento.prporg
   let ws.prpnumdig  =  g_documento.prpnumdig
   let ws.c24astcod  =  g_documento.c24astcod

   let l_maquina = g_issk.maqsgl

   let arr_aux  =  1
   while true
      initialize a_historico[arr_aux].lignum to null
      let arr_aux  =  arr_aux + 1
      if  arr_aux  >  100 then
          let arr_aux = 0
          exit while
      end if
   end while

   let ws.grlchv = "avtr", g_issk.funmat using "&&&&&&",
                           g_issk.empcod using "&&",
                           l_maquina clipped
   select count(*)
       into ws.contador
       from datkgeral
      where grlchv = ws.grlchv
   if ws.contador > 0  then
      delete from datkgeral
         where grlchv = ws.grlchv
   end if
   if param.numero is null then
      if ws.succod    is not null and
         ws.ramcod    is not null and
         ws.aplnumdig is not null then
         select  sgrorg   ,sgrnumdig
           into  ws.sgrorg,ws.sgrnumdig
           from  rsamseguro
           where succod    = ws.succod     and
                 ramcod    = ws.ramcod     and
                 aplnumdig = ws.aplnumdig
         if status = notfound   then
            error "Apolice nao encontrada, AVISE INFORMATICA"
            sleep 2
            return
         end if
	 whenever error continue
         select  unique ramsgl
           into  l_ramsgl
           from  gtakram
           where ramcod = ws.ramcod
         whenever error stop
	 if sqlca.sqlcode <> 0 then
	    if sqlca.sqlcode < 0 then
	       error "Erro no acesso a tabela gtakram !"
		     ,sqlca.sqlcode, "|",sqlca.sqlerrd[2]
               sleep 2
               return
            else
               error "Sigla do ramo nao encontrada, AVISE INFORMATICA"
               sleep 2
               return
            end if
         end if
	 if l_ramsgl = "TRANSP" then
	    whenever error continue
            select  segnumdig
              into  ws.segnumdig
              from  rsdmdocto
              where sgrorg    = ws.sgrorg      and
                    sgrnumdig = ws.sgrnumdig   and
                    dctnumseq = 1
            whenever error stop
         else
	    whenever error continue
            select  segnumdig
              into  ws.segnumdig
              from  rsdmdocto
              where sgrorg    = ws.sgrorg      and
                    sgrnumdig = ws.sgrnumdig   and
		    dctnumseq = (select max(dctnumseq)
				  from  rsdmdocto
				  where sgrorg    = ws.sgrorg    and
				        sgrnumdig = ws.sgrnumdig and
				        prpstt in (19,65,66,88))
            whenever error stop
	 end if
	 if sqlca.sqlcode <> 0 then
	    if sqlca.sqlcode < 0 then
	       error "Erro no acesso a tabela rsdmdocto !"
		     ,sqlca.sqlcode, "|",sqlca.sqlerrd[2]
               sleep 2
               return
            else
               error "Documento nao encontrado, AVISE INFORMATICA"
               sleep 2
               return
            end if
         end if
         select cgccpfnum,
                cgcord,
                cgccpfdig
           into ws.cgccpfnum,
                ws.cgcord,
                ws.cgccpfdig
           from gsakseg
          where segnumdig = ws.segnumdig
         if status = notfound   then
            error "Segurado  nao encontrado, AVISE INFORMATICA"
            sleep 2
            return
         end if
      end if
   else
      declare c_datrligtrpavb cursor for
         select lignum
            into ws.lignum
            from datrligtrpavb
           where trpavbnum = param.numero
      open c_datrligtrpavb
      fetch c_datrligtrpavb into ws.lignum
      if sqlca.sqlcode <> 0 then
         error "Numero de Averbacao nao existe!"
         sleep 2
         close  c_datrligtrpavb
         return
      end if
      close  c_datrligtrpavb
      select succod,
             ramcod,
             aplnumdig,
             itmnumdig,
             edsnumref
        into g_documento.succod,
             g_documento.ramcod,
             g_documento.aplnumdig,
             g_documento.itmnumdig,
             g_documento.edsnumref
        from datrligapol
       where lignum = ws.lignum
      if sqlca.sqlcode <> 0 then
         error "Nao existe relacionamto com apolice!"
         sleep 2
         return
      end if
      if param.tela = "cta00m01" then
         #call cta01m20()
         call cta00m16_chama_prog("ctg18", g_documento.ramcod,
                                           g_documento.succod,
                                           g_documento.aplnumdig,
                                           g_documento.itmnumdig,
                                           g_documento.edsnumref,
                                           g_documento.ligcvntip,
                                           g_documento.prporg,
                                           g_documento.prpnumdig,
                                           g_documento.solnom,
                                           g_documento.ciaempcod,
                                           g_documento.ramgrpcod,
                                           g_documento.c24soltipcod,
                                           g_documento.corsus,
                                           g_documento.atdnum,
                                           g_documento.lclnumseq,
                                           g_documento.rmerscseq,
                                           g_documento.itaciacod)
                                    returning l_status# PSI219967 Amilton inicio
                      if l_status = -1 then
                         error "Espelho da apolice nao disponivel no momento" sleep 2
                      end if # PSI219967  Amilton Fim
      end if
      let ws.c24astcod = "CON"
   end if
   if ws.c24astcod is null then
      let ws.c24astcod = "T10"
   end if
   call cts40g03_data_hora_banco(2)
      returning l_data, l_hora2
   let ws.data = l_data
   let ws.hora = l_hora2
   if g_issk.funmat = 601566 then
      display "antes do roda_prog ws.succod   =  ", ws.succod
      display "                   ws.ramcod   =  ", ws.ramcod
      display "                   ws.aplnumdig=  ", ws.aplnumdig
      display "                   ws.itmnumdig=  ", ws.itmnumdig
      display "                   ws.prporg   =  ", ws.prporg
      display "                   ws.prpnumdig=  ", ws.prpnumdig
      display "                   ws.edsnumref=  ", ws.edsnumref
   end if

   while true
        let ws.param[01,01] = "1"
        if  ws.flgcontinua = "S" then
            let ws.param[02,07] = retorno.numero
        else
            let ws.param[02,07] = param.numero
        end if
        let ws.param[08,13] = g_issk.funmat
        let ws.param[14,25] = ws.cgccpfnum
        let ws.param[26,29] = ws.cgcord
        let ws.param[30,31] = ws.cgccpfdig
        let ws.param[32,39] = ws.segnumdig
        let ws.param[40,54] = g_documento.solnom
        let ws.param[55,56] = g_issk.empcod
        let ws.param[57,59] = l_maquina
        let ws.param[60,60] = ws.flgcontinua
        let ws.param[61,62] = ws.succod

        if m_dtresol86 <= l_data then
           let ws.param[63,66] = ws.ramcod
           let ws.param[67,75] = ws.aplnumdig
           let ws.param[76,77] = ws.sgrorg
           let ws.param[78,86] = ws.sgrnumdig
        else
           let ws.param[63,64] = ws.ramcod
           let ws.param[65,73] = ws.aplnumdig
           let ws.param[74,75] = ws.sgrorg
           let ws.param[76,84] = ws.sgrnumdig
        end if


        let ws.sissgl =  "Sonega_TR"
        let ws.comando = ""
             ,g_issk.succod     , " "    #-> Sucursal
             ,g_issk.funmat     , " "    #-> Matricula do funcionario
         ,"'",g_issk.funnom,"'" , " "    #-> Nome do funcionario
             ,g_issk.dptsgl     , " "    #-> Sigla do departamento
             ,g_issk.dpttip     , " "    #-> Tipo do departamento
             ,g_issk.dptcod     , " "    #-> Codigo do departamento
             ,g_issk.sissgl     , " "    #-> Sigla sistema
             ,1                 , " "    #-> Nivel de acesso
             ,ws.sissgl         , " "    #-> Sigla programa - "Consultas"
             ,g_issk.usrtip     , " "    #-> Tipo de usuario
             ,g_issk.empcod     , " "    #-> Codigo da empresa
             ,g_issk.iptcod     , " "
             ,g_issk.usrcod     , " "    #-> Codigo do usuario
             ,l_maquina , " "    #-> Sigla da maquina
             ,"'",ws.param      , "'"
        if g_issk.funmat = 601566 then
           display "---------WS.COMANDO-----------------"
           display  ws.comando
           display "---------WS.PARAM-------------------"
           display ws.param
        end if

        call roda_prog("trasta02" ,ws.comando,1) # e necessario estar cadastrado
             returning ws.ret                   # na tabela ibpkprog.

        display "ws.ret", ws.ret

        if ws.ret = -1 then
           error "Sistema nao disponivel no momento"
           sleep 2
           exit while
        end if
        select grlinf
            into ws.grlinf
            from datkgeral
           where grlchv = ws.grlchv
        if sqlca.sqlcode <> notfound then
           delete from datkgeral
                 where grlchv = ws.grlchv
        end if
        if g_issk.funmat = 601566 then
           display "--------RETORNO DO TRANSP - ws.grlinf-----------"
           display ws.grlinf
        end if
        if param.numero is not null then   # consulta
           let ws.grlinf[01,06] = param.numero
           let ws.grlinf[07,07] = "N"
        end if
        let retorno.numero   = ws.grlinf[01,06]
        let retorno.continua = ws.grlinf[07,07]
        if retorno.numero is null or
           retorno.numero = 000000     then
           call cts08g01("C","S","","ABANDONA O PREENCHIMENTO DO LAUDO ?","","")
                   returning ws.confirma
           if ws.confirma  =  "S"   then
              exit while
           else
              continue while
           end if
        end if
        if ws.grlinf[08,08] = "A" then
           call  cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
           if m_dtresol86 <= l_data then
              let ws.succod    = ws.grlinf[09,10]
              let ws.ramcod    = ws.grlinf[11,14]
              let ws.aplnumdig = ws.grlinf[15,22]
              let ws.itmnumdig = 0
              let ws.edsnumref = ws.grlinf[23,30]
           else
              let ws.succod    = ws.grlinf[09,10]
              let ws.ramcod    = ws.grlinf[11,12]
              let ws.aplnumdig = ws.grlinf[13,21]
              let ws.itmnumdig = 0
              let ws.edsnumref = ws.grlinf[22,30]
           end if
        else
           let ws.prporg    = ws.grlinf[09,10]
           let ws.prpnumdig = ws.grlinf[13,21]
        end if
        if g_issk.funmat = 601566 then
           display "ws.succod   =  ", ws.succod
           display "ws.ramcod   =  ", ws.ramcod
           display "ws.aplnumdig=  ", ws.aplnumdig
           display "ws.itmnumdig=  ", ws.itmnumdig
           display "ws.prporg   =  ", ws.prporg
           display "ws.prpnumdig=  ", ws.prpnumdig
           display "ws.edsnumref=  ", ws.edsnumref
        end if
        if param.tela = "cta00m01" then
           let g_documento.succod     = ws.succod
           let g_documento.ramcod     = ws.ramcod
           let g_documento.aplnumdig  = ws.aplnumdig
           let g_documento.itmnumdig  = ws.itmnumdig
           let g_documento.edsnumref  = ws.edsnumref
           let g_documento.prporg     = ws.prporg
           let g_documento.prpnumdig  = ws.prpnumdig
        end if
        #-----------------------------------------------------------------------
        # Busca numeracao ligacao
        #-----------------------------------------------------------------------
        begin work

        call cts10g03_numeracao( 1, "" )
             returning ws.lignum   ,
                       ws.atdsrvnum,
                       ws.atdsrvano,
                       ws.codigosql,
                       ws.msg
        if  ws.codigosql <> 0  then
            let ws.msg = "CTS27M00 - ",ws.msg
            call ctx13g00(ws.codigosql,"DATKGERAL",ws.msg)
            rollback work
            prompt "" for char ws.promptq
            exit while
        end if
        #-----------------------------------------------------------------------
        # Grava dados da ligacao
        #-----------------------------------------------------------------------
        call cts10g00_ligacao ( ws.lignum               ,
                                ws.data                 ,
                                ws.hora                 ,
                                g_documento.c24soltipcod,
                                g_documento.solnom      ,
                                ws.c24astcod            ,
                                g_issk.funmat           ,
                                g_documento.ligcvntip   ,
                                g_c24paxnum             ,
                                "","", "","", "",""     ,
                                ws.succod               ,
                                ws.ramcod               ,
                                ws.aplnumdig            ,
                                ws.itmnumdig            ,
                                ws.edsnumref            ,
                                ws.prporg               ,
                                ws.prpnumdig            ,
                                g_documento.fcapacorg   ,
                                g_documento.fcapacnum   ,
                                "","","",""             ,
                                "", "", "", ""           )
             returning ws.tabname,
                       ws.codigosql
        if  ws.codigosql  <>  0  then
            error " Erro (", ws.codigosql, ") na gravacao da",
                  " tabela ", ws.tabname clipped, ". AVISE A INFORMATICA!"
            rollback work
            prompt "" for char ws.promptq
            exit while
        end if
        insert into datrligtrpavb
                 (lignum,trpavbnum)
          values (ws.lignum,retorno.numero)
        if sqlca.sqlcode <> 0 then
           error " Erro (", sqlca.sqlcode, ") na gravacao da",
                 " tabela DATRLIGTRPAVB. AVISE A INFORMATICA!"
           rollback work
           prompt "" for char ws.promptq
           exit while
        end if
        let g_documento.lignum = ws.lignum
        commit work

        let arr_aux = arr_aux + 1
        let a_historico[arr_aux].lignum = ws.lignum

        if retorno.continua = "S" then
           let ws.flgcontinua = "S"
        else
           exit while
        end if
   end while

   let arr_aux = 1
   while true
      if a_historico[arr_aux].lignum is null then
         exit while
      end if
      if a_historico[1].lignum <> 0        then
         let ws.lignum  =  a_historico[1].lignum
         error " Registre as informacoes no historico!"
         let g_documento.acao = "INC"
         call cta03n00(ws.lignum, g_issk.funmat, ws.data, ws.hora)
         let a_historico[1].lignum = 0
         let arr_aux = arr_aux + 1
         continue while
      end if
      declare  c_historico cursor for
        select lignum,
               c24txtseq,
               c24funmat,
               c24ligdsc,
               ligdat,
               lighorinc
           from datmlighist
          where lignum = ws.lignum
      foreach c_historico into ws.lignum,
                               ws.c24txtseq,
                               ws.c24funmat,
                               ws.c24ligdsc,
                               ws.ligdat,
                               ws.lighorinc
      #Priscila - chamar funcao para insercao
      #   insert into datmlighist ( lignum             ,
      #                             c24txtseq          ,
      #                             c24funmat          ,
      #                             c24ligdsc          ,
      #                             lighorinc          ,
      #                             ligdat             )
      #                    values ( a_historico[arr_aux].lignum,
      #                             ws.c24txtseq,
      #                             ws.c24funmat,
      #                             ws.c24ligdsc,
      #                             ws.lighorinc,
      #                             ws.ligdat         )
          call ctd06g01_ins_datmlighist(a_historico[arr_aux].lignum,
                                        ws.c24funmat,
                                        ws.c24ligdsc,
                                        ws.ligdat,
                                        ws.lighorinc,
                                        g_issk.usrtip,
                                        g_issk.empcod )
               returning l_ret,
                         l_mensagem
          if l_ret <> 1 then
             error l_mensagem
          end if
      end foreach
      let arr_aux = arr_aux + 1
   end while
 end function  ###  cts27m00
