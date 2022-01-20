#.............................................................................#
#                           PORTO SEGURO - CENTRAL 24 HORAS                   #
#.............................................................................#
#                                                                             #
#  Modulo              : cts35m02                                             #
#  Analista Responsavel: Raji / Ruiz                                          #
#  PSI                 : 190764 - Contingencia Central 24 hs                  #
#                                                                             #
#.............................................................................#
#                                                                             #
#  Desenvolvimento     : Ogeda, Fabrica de Software - Alexandre Jahchan       #
#  Data                : 18/02/2005                                           #
#                                                                             #
#.............................................................................#
#                     * * * A L T E R A C A O * * *                           #
#                                                                             #
#  Data        Autor Fabrica    Alteracao                                     #
#  ----------  -------------    --------------------------------------------- #
#  18/02/2005  A. Jahchan                                                     #
#---------------------------------------------------------------------------- #
#  13/10/2006  Ruiz  psi 202720 Inclusao do produto Saude+Casa                #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

define m_primvez    char(01)

define mr_documento  record
       succod        like datrligapol.succod,      # Codigo Sucursal
       aplnumdig     like datrligapol.aplnumdig,   # Numero Apolice
       itmnumdig     like datrligapol.itmnumdig,   # Numero do Item
       edsnumref     like datrligapol.edsnumref,   # Numero do Endosso
       prporg        like datrligprp.prporg,       # Origem da Proposta
       prpnumdig     like datrligprp.prpnumdig,    # Numero da Proposta
       fcapacorg     like datrligpac.fcapacorg,    # Origem PAC
       fcapacnum     like datrligpac.fcapacnum,    # Numero PAC
       pcacarnum     like eccmpti.pcapticod,       # No. Cartao PortoCard
       pcaprpitm     like epcmitem.pcaprpitm,      # Item (Veiculo) PortoCard
       solnom        char (15),                    # Solicitante
       soltip        char (01),                    # Tipo Solicitante
       c24soltipcod  like datmligacao.c24soltipcod,# Tipo do Solicitante
       ramcod        like datrservapol.ramcod,     # Codigo Ramo
       lignum        like datmligacao.lignum,      # Numero da Ligacao
       c24astcod     like datkassunto.c24astcod,   # Assunto da Ligacao
       ligcvntip     like datmligacao.ligcvntip,   # Convenio Operacional
       atdsrvnum     like datmservico.atdsrvnum,   # Numero do Servico
       atdsrvano     like datmservico.atdsrvano,   # Ano do Servico
       sinramcod     like ssamsin.ramcod,          # Prd Parcial - Ramo sinistro
       sinano        like ssamsin.sinano,          # Prd Parcial - Ano sinistro
       sinnum        like ssamsin.sinnum,          # Prd Parcial - Num sinistro
       sinitmseq     like ssamitem.sinitmseq,      # Prd Parcial - Item p/ramo
       acao          char (03),                    # ALT, REC ou CAN
       atdsrvorg     like datksrvtip.atdsrvorg,    # Origem do tipo de Servico
       cndslcflg     like datkassunto.cndslcflg,   # Flag solicita condutor
       lclnumseq     like rsdmlocal.lclnumseq,     # Local de Risco
       vstnumdig     like datmvistoria.vstnumdig,  # numero da vistoria
       flgIS096      char (01)                  ,  # flag cobertura claus.096
       flgtransp     char (01)                  ,  # flag averbacao transporte
       apoio         char (01)                  ,  # flag atend. pelo apoio(S/N
       empcodatd     like datmligatd.apoemp     ,  # empresa do atendente
       funmatatd     like datmligatd.apomat     ,  # matricula do atendente
       usrtipatd     like datmligatd.apotip     ,  # tipo do atendente
       corsus        like gcaksusep.corsus      ,  #  /inicio psi172413 eduardo
       dddcod        like datmreclam.dddcod     ,  # codigo da area de discagem
       ctttel        like datmreclam.ctttel     ,  # numero do telefone
       funmat        like isskfunc.funmat       ,  # matricula do funcionario
       cgccpfnum     like gsakseg.cgccpfnum     ,  # numero do CGC(CNPJ)
       cgcord        like gsakseg.cgcord        ,  # filial do CGC(CNPJ)
       cgccpfdig     like gsakseg.cgccpfdig     ,  # digito do CGC(CNPJ) ou CPF
       atdprscod     like datmservico.atdprscod ,
       atdvclsgl     like datkveiculo.atdvclsgl ,
       srrcoddig     like datmservico.srrcoddig ,
       socvclcod     like datkveiculo.socvclcod ,
       dstqtd        dec(8,4)                   ,
       prvcalc       interval hour(2) to minute ,
       lclltt        like datmlcl.lclltt        ,
       lcllgt        like datmlcl.lcllgt        ,
       rcuccsmtvcod  like datrligrcuccsmtv.rcuccsmtvcod,    ## Codigo do Motivo
       c24paxnum     like datmligacao.c24paxnum ,           # Numero da P.A.
       averbacao     like datrligtrpavb.trpavbnum,          # PSI183431 Daniel
       crtsaunum     like datksegsau.crtsaunum,
       bnfnum        like datksegsau.bnfnum,
       ramgrpcod     like gtakram.ramgrpcod
end record

define mr_documento2 record
       doc_handle    integer
end record

define m_itaciacod   like datkitacia.itaciacod
define mr_ppt        record
       segnumdig     like gsakseg.segnumdig,
       cmnnumdig     like pptmcmn.cmnnumdig,
       endlgdtip     like rlaklocal.endlgdtip,
       endlgdnom     like rlaklocal.endlgdnom,
       endnum        like rlaklocal.endnum,
       ufdcod        like rlaklocal.ufdcod,
       endcmp        like rlaklocal.endcmp,
       endbrr        like rlaklocal.endbrr,
       endcid        like rlaklocal.endcid,
       endcep        like rlaklocal.endcep,
       endcepcmp     like rlaklocal.endcepcmp,
       edsstt        like rsdmdocto.edsstt,
       viginc        like rsdmdocto.viginc,
       vigfnl        like rsdmdocto.vigfnl,
       emsdat        like rsdmdocto.emsdat,
       corsus        like rsampcorre.corsus,
       pgtfrm        like rsdmdadcob.pgtfrm,
       mdacod        like gfakmda.mdacod,
       lclrsccod     like rlaklocal.lclrsccod
end record

define am_ppt        array[05] of record
       clscod        like aackcls.clscod,
       carencia      date
end record

#--------------------------------------------------------------------------
function cts35m02_prepare()
#--------------------------------------------------------------------------

   define l_cmd     char(3000)

   let l_cmd = " select srv.atddat "
              ,"       ,srv.atdhor "
              ,"       ,srv.atdsrvorg "
              ,"       ,srv.atdsrvnum "
              ,"       ,srv.atdsrvano "
              ,"       ,srv.vcllicnum "
              ,"       ,srv.nom "
              ,"       ,srv.ciaempcod "
              ,"   from datmservico srv "
              ," where srv.atddat between ? and ? "
              ,"   and srv.atdsrvorg <> 10 "	# vistoria previa
              ,"   and srv.atdsrvorg <> 08 "    # carro extra - sofia
              ,"   and not exists ( select atdsrvnum "
              ,"                       from datrservapol doc "
              ,"                    where doc.atdsrvnum = srv.atdsrvnum "
              ,"                      and doc.atdsrvano = srv.atdsrvano ) "

   prepare p_cts35m02_001 from l_cmd
   declare c_cts35m02_001 cursor for p_cts35m02_001

   let l_cmd = " select nom "
              ,"       ,vcllicnum "
              ,"       ,ciaempcod "
              ,"   from datmservico "
              ," where atdsrvnum = ? "
              ,"   and atdsrvano = ? "

   prepare p_cts35m02_002 from l_cmd
   declare c_cts35m02_002 cursor for p_cts35m02_002

   let l_cmd = " select ramcod "
              ,"       ,succod "
              ,"       ,aplnumdig "
              ,"       ,itmnumdig "
              ,"       ,cpfnum "
              ,"       ,cgcord "
              ,"       ,cpfdig "
              ,"   from datmcntsrv "
              ," where atdsrvnum = ? "
              ,"   and atdsrvano = ? "

   prepare p_cts35m02_003 from l_cmd
   declare c_cts35m02_003 cursor for p_cts35m02_003

   let l_cmd = " select ramcod "
              ,"       ,succod "
              ,"       ,aplnumdig "
              ,"       ,itmnumdig "
              ,"       ,cpfnum "
              ,"       ,cgcord "
              ,"       ,cpfdig "
              ,"   from datmcntsrv "
              ," where dstsrvnum = ? "
              ,"   and dstsrvano = ? "

   prepare p_cts35m02_004 from l_cmd
   declare c_cts35m02_004 cursor for p_cts35m02_004

end function
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
function cts35m02()
#--------------------------------------------------------------------------

   define a_cts35m02   array[500] of record
          atddat        like datmservico.atddat
         ,atdhor        like datmservico.atdhor
         ,assunto       like datmligacao.c24astcod
         ,ctg           char(1)
         ,servico       char(13)
         ,vcllicnum     like datmservico.vcllicnum
         ,empresa       char(05)
         ,nom           like datmservico.nom
   end record

   define l_cts35m02    record
          atdsrvorg     like datmservico.atdsrvorg
         ,atdsrvnum     like datmservico.atdsrvnum
         ,atdsrvano     like datmservico.atdsrvano
         ,prg           char (08)
   end record

   define l_datmcntsrv  record
          sindat        like datmcntsrv.sindat,
          sinhor        like datmcntsrv.sinhor,
          segnom        like datmcntsrv.segnom,
          ocrlcltelnum  like datmcntsrv.ocrlcltelnum,
          cpfnum        like datmcntsrv.cpfnum,
          cgcord        like datmcntsrv.cgcord,
          cpfdig        like datmcntsrv.cpfdig,
          vclchscod     like datmcntsrv.vclchscod,
          vcllicnum     like datmcntsrv.vcllicnum,
          sinavstip     like datmcntsrv.sinavstip,
          vcldes        like datmcntsrv.vcldes,
          vclcor        like datmcntsrv.vclcor,
          vclanomdl     like datmcntsrv.vclanomdl,
          funmat        like datmcntsrv.funmat
   end record

   define w_cts35m02    record
          datinc        date
         ,datfnl        date
         ,total         smallint
   end record

   define ws            record
          histerr       smallint,
          ano4          char(04),
          aplnumdig     like ssamavs.aplnumdig,
          data          date,
          hora2         datetime hour to minute,
          vclanofbc     like abbmveic.vclanofbc,
          vclchsnum     char (20),
          confirma      char (01),
          ciaempcod     like datmservico.ciaempcod
   end record

   define lr_param record
          apoio        char(1)
         ,empcodatd    like isskfunc.empcod
         ,funmatatd    like isskfunc.funmat
         ,usrtipcod    char(01)
         ,c24astcod    char(03)
         ,solnom       like datmligacao.c24solnom
         ,c24soltipcod like datmligacao.c24soltipcod
         ,c24paxnum    integer
   end record

   define d_cta00m01    record
          cpocod            like datkdominio.cpocod  ,
          cpodes            like datkdominio.cpodes  ,
          atdnum            like datmatd6523.atdnum,
          solnom            like datmligacao.c24solnom,
          flgavstransp      char (01),
          c24soltipcod      like datmligacao.c24soltipcod,
          c24soltipdes      char (40),
          corsus            like gcaksusep.corsus,   # PSI 172057
          cornom            like gcakcorr.cornom,    # PSI 172057
          ramcod            like gtakram.ramcod,
          flgcar            char(01),
          vcllicnum         like abbmveic.vcllicnum,
          succod            like gabksuc.succod,
          sucnom            like gabksuc.sucnom,
          aplnumdig         like abamdoc.aplnumdig,
          itmnumdig         like abbmveic.itmnumdig,
          etpctrnum         like rgemetpsgr.etpctrnum,
          ramnom            like gtakram.ramnom,
          segnom            char (40),
          pestip            char (01),
          cgccpfnum         like gsakseg.cgccpfnum,
          cgcord            like gsakseg.cgcord,
          cgccpfdig         like gsakseg.cgccpfdig,
          prporg            like datrligprp.prporg,
          prpnumdig         like datrligprp.prpnumdig,
          vp                char (01),
          vd                char (01),
          cp                char (01),
          semdocto          char (01),
          ies_ppt           char (01),
          ies_pss           char (01),
          transp            char (01),
          trpavbnum         like datrligtrpavb.trpavbnum,
          vclchsfnl         like abbmveic.vclchsfnl,
          sinramcod         like ssamsin.ramcod,
          sinnum            like ssamsin.sinnum,
          sinano            like ssamsin.sinano,
          sinvstnum         like ssamsin.sinvstnum,
          sinvstano         like ssamsin.sinvstano,
          sinautnum         like ssamsin.sinvstnum,
          sinautano         like ssamsin.sinvstano,
          flgauto           char (01),
          sinrenum          like ssamsin.sinvstnum,
          sinreano          like ssamsin.sinvstano,
          flgre             char (01),
          sinavsnum         like ssamsin.sinnum,
          sinavsano         like ssamsin.sinano,
          flgavs            char (01),
          obs               char (09)
   end record

   define lr_cts05g00     record
          segnom          like gsakseg.segnom       ,
          corsus          like datmservico.corsus   ,
          cornom          like datmservico.cornom   ,
          cvnnom          char (20)                 ,
          vclcoddig       like datmservico.vclcoddig,
          vcldes          like datmservico.vcldes   ,
          vclanomdl       like datmservico.vclanomdl,
          vcllicnum       like datmservico.vcllicnum,
          vclchsinc       like abbmveic.vclchsinc   ,
          vclchsfnl       like abbmveic.vclchsfnl   ,
          vclcordes       char (12)
   end record

   define l_i    smallint
         ,i      smallint
         ,l_lignum   like datmligacao.lignum
         ,l_count integer

   initialize l_cts35m02.*
             ,lr_cts05g00.*
             ,w_cts35m02.*
             ,ws.*
             ,lr_param.*
             ,d_cta00m01.*
             ,l_lignum
             ,l_count
             ,i             to null

   if m_primvez is null then
      let m_primvez = "N"
      call cts35m02_prepare()
   end if

   call cts40g03_data_hora_banco(2)
        returning ws.data, ws.hora2

   let w_cts35m02.datinc = ws.data
   let w_cts35m02.datfnl = ws.data
   let l_cts35m02.prg    = "cts35m02"

   open window w_cts35m02 at 04,02 with form "cts35m02"

   while true

   input by name w_cts35m02.datinc
                ,w_cts35m02.datfnl
                ,w_cts35m02.total without defaults

    after field datinc
       if w_cts35m02.datinc is null or
          w_cts35m02.datinc = "" then
          error "Preenchimento obrigatorio do campo data inicial!"
          next field datinc
       end if

    after field datfnl
       if w_cts35m02.datfnl is null or
          w_cts35m02.datfnl = "" then
          error "Preenchimento obrigatorio do campo data final!"
          next field datfnl
       end if

       if w_cts35m02.datinc > w_cts35m02.datfnl then
          error "Data inicial nao pode ser maior que a data final!"
          next field datfnl
       end if

      while true

        for l_i = 1 to 500
            initialize a_cts35m02[l_i].* to null
        end for

        let l_i = 1
        open c_cts35m02_001 using w_cts35m02.datinc
                              ,w_cts35m02.datfnl

        foreach c_cts35m02_001 into a_cts35m02[l_i].atddat
                                ,a_cts35m02[l_i].atdhor
                                ,l_cts35m02.atdsrvorg
                                ,l_cts35m02.atdsrvnum
                                ,l_cts35m02.atdsrvano
                                ,a_cts35m02[l_i].vcllicnum
                                ,a_cts35m02[l_i].nom
                                ,ws.ciaempcod
           let l_count = 0
           select count(*)
                into l_count
                from datrsrvsau
               where atdsrvnum = l_cts35m02.atdsrvnum
                 and atdsrvano = l_cts35m02.atdsrvano
           if l_count > 0 then
              # servico do saude+casa
              continue foreach
           end if
           select  min(lignum)
                into l_lignum
                from datmligacao
               where atdsrvnum = l_cts35m02.atdsrvnum
                 and atdsrvano = l_cts35m02.atdsrvano
           if sqlca.sqlcode <>  0 then
              continue foreach
           end if
           let l_count = 0
           select count(*)
               into l_count
               from datrligprp
              where lignum = l_lignum
           if l_count > 0 then
              continue foreach
           end if
           select c24astcod
              into a_cts35m02[l_i].assunto
              from datmligacao
             where lignum = l_lignum

           ----[ verifica se o servico e da contingencia ]------
           let a_cts35m02[l_i].ctg = null
           let l_count = 0
           select count(*)
              into l_count
              from datmcntsrv
             where dstsrvnum = l_cts35m02.atdsrvnum
               and dstsrvano = l_cts35m02.atdsrvano
           if l_count > 0 then
              let a_cts35m02[l_i].ctg = "*"
           end if

           ---------[ verifica a empresa do servico ]------------
           if ws.ciaempcod =  1   then
              let a_cts35m02[l_i].empresa = "Porto"
           end if
           if ws.ciaempcod =  35  then
              let a_cts35m02[l_i].empresa = "Azul"
           end if

           let a_cts35m02[l_i].servico =
                              f_fundigit_inttostr(l_cts35m02.atdsrvorg,2)
                        ,"/" ,f_fundigit_inttostr(l_cts35m02.atdsrvnum,7)
                        ,"-" ,f_fundigit_inttostr(l_cts35m02.atdsrvano,2)
           let l_i = l_i + 1

           if l_i = 500 then
              error "Numero de array maior que 500"
              exit foreach
           end if

         end foreach

         if not l_i > 1 then
            error "Nenhum documento para o periodo informado!"
         end if

         let w_cts35m02.total = l_i
         display by name w_cts35m02.total

         call set_count(l_i - 1)
         display array a_cts35m02 to s_cts35m02.*

         on key (F8)
            let i = arr_curr()

            initialize lr_param.*
                      ,d_cta00m01.*  to null

            let d_cta00m01.segnom    = a_cts35m02[i].nom
            let l_cts35m02.atdsrvorg = a_cts35m02[i].servico[01,02]
            let l_cts35m02.atdsrvnum = a_cts35m02[i].servico[04,10]
            let l_cts35m02.atdsrvano = a_cts35m02[i].servico[12,13]

            --[ Pesquisa tabela datmservico ]--
            open c_cts35m02_002 using l_cts35m02.atdsrvnum
                                  ,l_cts35m02.atdsrvano

            fetch c_cts35m02_002 into lr_param.solnom
                                  ,d_cta00m01.vcllicnum
                                  ,ws.ciaempcod
            close c_cts35m02_002
            --------------------------------------------

           #if ws.ciaempcod = 35 then  # silmara 22/07/02
           #   call cts08g01("A","N",
           #                 "Tela nao preparada para pesquisar ",
           #                 "Apolices da Azul Seguros","","")
           #        returning ws.confirma
           #   let int_flag = false
           #   exit display
           #end if

            --[ Pesquisa tabela datmcntsrv ]--
            open c_cts35m02_003 using l_cts35m02.atdsrvnum
                                  ,l_cts35m02.atdsrvano

            fetch c_cts35m02_003 into d_cta00m01.ramcod
                                  ,d_cta00m01.succod
                                  ,d_cta00m01.aplnumdig
                                  ,d_cta00m01.itmnumdig
                                  ,d_cta00m01.cgccpfnum
                                  ,d_cta00m01.cgcord
                                  ,d_cta00m01.cgccpfdig
            close c_cts35m02_003
            if d_cta00m01.ramcod is null then
               open c_cts35m02_004 using l_cts35m02.atdsrvnum
                                     ,l_cts35m02.atdsrvano

               fetch c_cts35m02_004 into d_cta00m01.ramcod
                                     ,d_cta00m01.succod
                                     ,d_cta00m01.aplnumdig
                                     ,d_cta00m01.itmnumdig
                                     ,d_cta00m01.cgccpfnum
                                     ,d_cta00m01.cgcord
                                     ,d_cta00m01.cgccpfdig
               close c_cts35m02_004
            end if
            -------------------------------------------

            let d_cta00m01.solnom = lr_param.solnom

            if d_cta00m01.cgcord > 0 then
               let d_cta00m01.pestip = "J"
            else
               let d_cta00m01.pestip = "F"
            end if
            if d_cta00m01.cgcord is null then
               let d_cta00m01.pestip = ""
            end if
            if ws.ciaempcod = 1 then
               call cta00m01_documento(lr_param.*
                                      ,d_cta00m01.*
                                      ,l_cts35m02.*)
                    returning mr_documento.*
                             ,mr_ppt.*
                             ,am_ppt[1].*
                             ,am_ppt[2].*
                             ,am_ppt[3].*
                             ,am_ppt[4].*
                             ,am_ppt[5].*
            end if
            if ws.ciaempcod = 35 then
               call cta00m07_principal (lr_param.apoio,
                                        lr_param.empcodatd,
                                        lr_param.funmatatd,
                                        lr_param.usrtipcod,
                                        lr_param.c24paxnum,
                                        d_cta00m01.solnom,
                                        d_cta00m01.segnom,
                                        d_cta00m01.vcllicnum,
                                        d_cta00m01.cgccpfnum,
                                        d_cta00m01.cgcord,
                                        d_cta00m01.cgccpfdig,
                                        d_cta00m01.pestip,
                                        l_cts35m02.atdsrvorg,
                                        l_cts35m02.atdsrvnum,
                                        l_cts35m02.atdsrvano,
                                        "cts35m02")
                   returning mr_documento.*,
                             mr_documento2.doc_handle
            end if
            
            if ws.ciaempcod = 84 then 
               call cta00m27(lr_param.apoio      , 
                             lr_param.empcodatd  , 
                             lr_param.funmatatd  , 
                             lr_param.usrtipcod  , 
                             g_c24paxnum        ) 
                  returning mr_documento.solnom       
                           ,mr_documento.soltip       
                           ,mr_documento.c24soltipcod 
                           ,mr_documento.ligcvntip    
                           ,m_itaciacod    
                           ,mr_documento.succod       
                           ,mr_documento.ramcod    
                           ,mr_documento.aplnumdig
                           ,mr_documento.itmnumdig
                           ,mr_documento.edsnumref
                           ,mr_documento.empcodatd    
                           ,mr_documento.funmatatd    
                           ,mr_documento.usrtipatd    
                           ,mr_documento.corsus       
                           ,mr_documento.dddcod       
                           ,mr_documento.ctttel       
                           ,mr_documento.funmat       
                           ,mr_documento.cgccpfnum    
                           ,mr_documento.cgcord       
                           ,mr_documento.cgccpfdig    
                           ,mr_documento.c24paxnum    
                           #,mr_documento.semdocto     
                                                                                                                                                
            end if                                                                                             
            
            if mr_documento.edsnumref is null then
               let mr_documento.edsnumref = 0
            end if

            if mr_documento.aplnumdig is not null and
               mr_documento.crtsaunum is null     then
               if a_cts35m02[i].assunto = "F10" then
                  ---------------[ dados do veiculo ]------------------------
                  call cts05g00(mr_documento.succod,
                                mr_documento.ramcod,
                                mr_documento.aplnumdig,
                                mr_documento.itmnumdig)
                      returning lr_cts05g00.segnom,
                                lr_cts05g00.corsus,
                                lr_cts05g00.cornom,
                                lr_cts05g00.cvnnom,
                                lr_cts05g00.vclcoddig,
                                lr_cts05g00.vcldes,
                                lr_cts05g00.vclanomdl,
                                lr_cts05g00.vcllicnum,
                                lr_cts05g00.vclchsinc,
                                lr_cts05g00.vclchsfnl,
                                lr_cts05g00.vclcordes
                  let ws.vclchsnum = lr_cts05g00.vclchsinc clipped,
                                     lr_cts05g00.vclchsfnl clipped
                  select vclanofbc
                    into ws.vclanofbc
                    from abbmveic
                   where succod    = mr_documento.succod      and
                         aplnumdig = mr_documento.aplnumdig   and
                         itmnumdig = mr_documento.itmnumdig   and
                         dctnumseq = (select max(dctnumseq)
                                     from abbmveic
                                    where succod    = mr_documento.succod    and
                                          aplnumdig = mr_documento.aplnumdig and
                                          itmnumdig = mr_documento.itmnumdig)
               end if
               begin work
               insert into datrservapol ( atdsrvnum ,
                                          atdsrvano ,
                                          succod    ,
                                          ramcod    ,
                                          aplnumdig ,
                                          itmnumdig ,
                                          edsnumref  )
                                 values ( l_cts35m02.atdsrvnum
                                         ,l_cts35m02.atdsrvano
                                         ,mr_documento.succod
                                         ,mr_documento.ramcod
                                         ,mr_documento.aplnumdig
                                         ,mr_documento.itmnumdig
                                         ,mr_documento.edsnumref  )
               if sqlca.sqlcode <> 0  then
                  error " Erro (", sqlca.sqlcode, ") na gravacao do",
                  " datrservapol - cts35m02. AVISE A INFORMATICA!"
                  rollback work
                  let int_flag = true
                  exit display
               end if
               call cts10g02_historico(l_cts35m02.atdsrvnum,
                                       l_cts35m02.atdsrvano,
                                       today               ,
                                       current hour to minute,
                                       g_issk.funmat       ,
                        "** DOCUMENTO ASSOCIADO APOS ATENDIMENTO **",
                        "","","","")
                   returning ws.histerr

               declare c_cts35m02_005 cursor for
                  select lignum
                     from datmligacao
                  where atdsrvnum = l_cts35m02.atdsrvnum
                    and atdsrvano = l_cts35m02.atdsrvano

               foreach c_cts35m02_005 into l_lignum
                  insert into datrligapol ( lignum   ,
                                            succod   ,
                                            ramcod   ,
                                            aplnumdig,
                                            itmnumdig,
                                            edsnumref )
                                   values ( l_lignum   ,
                                            mr_documento.succod   ,
                                            mr_documento.ramcod   ,
                                            mr_documento.aplnumdig,
                                            mr_documento.itmnumdig,
                                            mr_documento.edsnumref )

                  if sqlca.sqlcode <> 0  then
                     error " Erro (", sqlca.sqlcode, ") na gravacao do",
                     " datrligapol - cts35m02. AVISE A INFORMATICA!"
                     rollback work
                     let int_flag = true
                     exit display
                  end if
               end foreach
               --[ grava as tabelas do sinistro para furto/roubo ]--
               if a_cts35m02[i].assunto = "F10" then
                  select sinvstano
                     into ws.ano4
                     from datrsrvvstsin
                    where atdsrvnum = l_cts35m02.atdsrvnum
                      and atdsrvano = l_cts35m02.atdsrvano
                  if sqlca.sqlcode <> 0 then
                     error
                     "ATENCAO aviso sinistro nao localizado,datrsrvvstsin (",l_cts35m02.atdsrvnum, ")-cts35m02.AVISE INFO!"
                     rollback work
                     let int_flag = true
                     exit display
                  end if
                  select aplnumdig
                     into ws.aplnumdig
                     from ssamavs
                    where sinavsnum = l_cts35m02.atdsrvnum
                      and sinavsano = ws.ano4
                  if sqlca.sqlcode <> 0 then
                     error
                     "ATENCAO aviso sinistro nao localizado,ssamavs (", l_cts35m02.atdsrvnum,")-cts35m02.AVISE INFO!"
                     rollback work
                     let int_flag = true
                     exit display
                  end if
                  if ws.aplnumdig is null or
                     ws.aplnumdig =  0    then
                     update ssamavs
                       set (succod,
                            aplnumdig,
                            itmnumdig,
                            vclcoddig,
                            vclanofbc,
                            vcllicnum,
                            vclchsnum) =
                   (mr_documento.succod,
                            mr_documento.aplnumdig,
                            mr_documento.itmnumdig,
                            lr_cts05g00.vclcoddig,
                            ws.vclanofbc,
                            lr_cts05g00.vcllicnum,
                            ws.vclchsnum)
                        where sinavsnum = l_cts35m02.atdsrvnum
                          and sinavsano = ws.ano4
                     if sqlca.sqlcode <> 0  then
                        error " Erro (", sqlca.sqlcode, ") na gravacao do",
                        " ssamavs-apolice(cts35m02). AVISE A INFORMATICA!"
                        rollback work
                        let int_flag = true
                        exit display
                     end if
                  end if
               end if
               commit work
            else
               if mr_documento.crtsaunum is not null then
                  begin work
                  insert into datrsrvsau ( atdsrvnum ,
                                           atdsrvano ,
                                           succod    ,
                                           ramcod    ,
                                           aplnumdig ,
                                           crtnum    ,
                                           bnfnum   )
                                  values ( l_cts35m02.atdsrvnum
                                          ,l_cts35m02.atdsrvano
                                          ,mr_documento.succod
                                          ,mr_documento.ramcod
                                          ,mr_documento.aplnumdig
                                          ,mr_documento.crtsaunum
                                          ,mr_documento.bnfnum )
                  if sqlca.sqlcode <> 0  then
                     error " Erro (", sqlca.sqlcode, ") na gravacao do",
                     " datrsrvsau - cts35m02. AVISE A INFORMATICA!"
                     rollback work
                     let int_flag = true
                     exit display
                  end if
                  call cts10g02_historico(l_cts35m02.atdsrvnum,
                                          l_cts35m02.atdsrvano,
                                          today               ,
                                          current hour to minute,
                                          g_issk.funmat       ,
                           "** DOCUMENTO ASSOCIADO APOS ATENDIMENTO **",
                           "","","","")
                      returning ws.histerr
                  declare c_cts35m02_006 cursor for
                     select lignum
                        from datmligacao
                     where atdsrvnum = l_cts35m02.atdsrvnum
                       and atdsrvano = l_cts35m02.atdsrvano

                  foreach c_cts35m02_006 into l_lignum
                     insert into datrligsau  ( lignum   ,
                                               succod   ,
                                               ramcod   ,
                                               aplnumdig,
                                               crtnum   ,
                                               bnfnum    )
                                      values ( l_lignum   ,
                                               mr_documento.succod   ,
                                               mr_documento.ramcod   ,
                                               mr_documento.aplnumdig,
                                               mr_documento.crtsaunum,
                                               mr_documento.bnfnum    )

                     if sqlca.sqlcode <> 0  then
                        error " Erro (", sqlca.sqlcode, ") na gravacao do",
                        " datrligsau - cts35m02. AVISE A INFORMATICA!"
                        rollback work
                        let int_flag = true
                        exit display
                     end if
                  end foreach
                  commit work
               end if
            end if

            let int_flag = false
            exit display

         on key (F17,interrupt)
            let int_flag = true
            exit display

      end display

      if int_flag then
         let int_flag = false
         exit while
      end if

      end while

      on key (F17,interrupt)
         let int_flag = true
         exit input

   end input

   if int_flag then
      let int_flag = false
      exit while
   end if

   end while

   close window w_cts35m02

end function
#--------------------------------------------------------------------------

