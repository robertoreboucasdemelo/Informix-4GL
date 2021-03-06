#------------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                       #
#..............................................................................#
#  Sistema        : CT24h                                                      #
#  Modulo         : CTB11M17.4gl                                               #
#                 : Direciona e imprime OP de servico para prestador           #
#  Analista Resp. : Carlos Zyon                                                #
#  PSI            : 177881  OSF.28070                                          #
#..............................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE, Aguinaldo Costa                       #
#  Liberacao      : 31/10/2003                                                 #
#..............................................................................#
#                     * * * A L T E R A C A O * * *                            #
#                                                                              #
#  Data         Autor Fabrica      OSF      Observacao                         #
#  ----------   -------------    -------    ---------------------------------  #
#  30/01/2004   Luciano Galvani   31690     Acrescentar texto no final do fax  #
#  03/12/2004   Helio (Meta)      188220    incluir opcao para destino para ema#
#  22/06/2006   Priscila         PSI197858  incluir opcao para destino celular #
#                                           SMS                                #
#  07/07/2008	 Andre Oliveira   PSI25243    Altera��o do sql 'Recupera dados # 
#                                           dos itens da OP' do prepare        #
#                                           pctb11m17002. Altera��o da extens�o#
#                                           do arquivo enviado por e-mail, de  #
#                                           '.txt' para '.doc'.                #
#  02/08/2011   Celso Yamahaki              Inclusao de dados das empresas para#
#                                           os Prestadores emitirem as Notas   #
#                                           Fiscais                            #
#  29/08/2011   Celso Yamahaki              Correcao do cnpj da Porto Seguro   #
#                                                                              #
#  26/05/2014   Rodolfo Massini             Alteracao na forma de envio de     #
#                                           e-mail (SENDMAIL para FIGRC009)    # 
#                                                                              #
#------------------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_wsgpipe      char(500)
define m_wsgfax       char(003)
define m_prep         char(001)
define m_prsmsgtxt    like dpakprsmsgtxt.prsmsgtxt
define m_crnpgtetgdat like dbsmcrnpgtetg.crnpgtetgdat

define m_rel array[500] of record
    atdsrvano    like dbsmopgitm.atdsrvano,
    socopgitmvlr like dbsmopgitm.socopgitmvlr,
    atdsrvnum    like dbsmopgitm.atdsrvnum,
    vcllicnum    like datmservico.vcllicnum
end record

define m_dbsmopg record
    pstcoddig    like dbsmopg.pstcoddig,
    socfatitmqtd like dbsmopg.socfatitmqtd,
    socfattotvlr like dbsmopg.socfattotvlr
end record

define m_i smallint

#--------------------------------------------------------------
function ctb11m17_prep()
#--------------------------------------------------------------

    define l_sql char(600)

    #--------------------------------------------------------------
    # Recupera dados para Header/Trailer
    #--------------------------------------------------------------
    let l_sql = "select pstcoddig,    ",
                "       socfatitmqtd, ",
                "       socfattotvlr  ",
                "  from dbsmopg       ",
                " where socopgnum = ? "
    prepare pctb11m17001 from l_sql
    declare cctb11m17001 cursor for pctb11m17001

    #--------------------------------------------------------------
    # Recupera dados dos itens da OP
    #--------------------------------------------------------------
    let l_sql = "select c.atdsrvnum,"
		,"     c.atdsrvano,"
		,"     c.socopgitmvlr +"
		,"  	nvl((select sum(socopgitmcst)"
		,"      from dbsmopgcst "
		,"      where socopgnum = c.socopgnum"
		,"      and socopgitmnum = c.socopgitmnum"
		,"      group by socopgnum),0)"
		," from dbsmopgitm c"
		," where socopgnum = ?"
		
    prepare pctb11m17002 from l_sql   
    declare cctb11m17002 cursor for pctb11m17002
                                      
   
    #--------------------------------------------------------------
    # Recupera informacoes do veiculo
    #--------------------------------------------------------------
    let l_sql = "select vcllicnum     ",
                "  from datmservico   ",
                " where atdsrvnum = ? ",
                "   and atdsrvano = ? "
    prepare pctb11m17003 from l_sql
    declare cctb11m17003 cursor for pctb11m17003

    #--------------------------------------------------------------
    # Recupera dados do prestador
    #--------------------------------------------------------------
    let l_sql = "select nomgrr,       ",
                "       dddcod,       ",
                "       faxnum,       ",
                "       crnpgtcod,    ",
                "       maides,       ",
                "       celdddnum,    ",
                "       celtelnum     ",
                "  from dpaksocor     ",
                " where pstcoddig = ? "
    prepare pctb11m17005 from l_sql
    declare cctb11m17005 cursor for pctb11m17005

    #--------------------------------------------------------------
    # Recupera mensagem de fax armazenada no codigo fixo 1
    #--------------------------------------------------------------
    let l_sql = " select prsmsgtxt     ",
                "   from dpakprsmsgtxt ",
                "  where prsmsgcod = 1 "
    prepare pctb11m17006 from l_sql
    declare cctb11m17006 cursor for pctb11m17006

    #--------------------------------------------------------------
    # Recupera as pr�ximas datas de cronograma
    #--------------------------------------------------------------
    let l_sql = " select crnpgtetgdat         ",
                "   from dbsmcrnpgtetg        ",
                "  where crnpgtetgdat > today ",
                "    and crnpgtcod = ?        "
    prepare pctb11m17007 from l_sql
    declare cctb11m17007 cursor for pctb11m17007

    #--------------------------------------------------------------
    # Recupera o email do remetente
    #--------------------------------------------------------------
    let l_sql = " select relpamtxt           ",
                "   from igbmparam           ",
                "  where relsgl = 'CTB11M17' ",
                "    and relpamseq = 1       ",
                "    and relpamtip = 1       "
    prepare pctb11m17008 from l_sql
    declare cctb11m17008 cursor for pctb11m17008

    let l_sql = "select distinct ciaempcod ",
                 " from dbsmopgitm a, ",
                      " datmservico b ",
                " where a.socopgnum = ? ",
                  " and a.atdsrvnum = b.atdsrvnum ",
                  " and a.atdsrvano = b.atdsrvano "
    prepare pctb11m17009 from l_sql
    declare cctb11m17009 cursor for pctb11m17009
    
    let l_sql = "insert into dbsmenvmsgsms (smsenvcod,",
                                       " dddcel, ",
                                       " celnum, ",
                                       " msgtxt, ",
                                       " incdat, ",
                                       " envstt) ",
                               " values (?,?,?,?,?,?)"
    prepare pctb11m17010 from l_sql 
    
    let l_sql = " select 1 ",
                  " from dbsmenvmsgsms ",
                 " where smsenvcod = ? "
    
    prepare pctb11m17011 from l_sql
    declare cctb11m17011 cursor for pctb11m17011

    let m_prep = 'S'

end function #--> ctb11m17_prep

#--------------------------------------------------------------
function ctb11m17(param)
#--------------------------------------------------------------

    define param record
        socopgnum like dbsmopg.socopgnum,
        pstcoddig like dpaksocor.pstcoddig,
        destino   char(01), #(E)mail (I)mpressora (F)ax  #PSI 188220 ou SMS #PSI 197858
        aplicacao char(01)  #(B)atch (O)nline            #PSI 188220
    end record

    define l_ctb11m17 record
        destino   char (01),
        aplicacao char (01),
        envdes    char (10),
        nomgrr    like dpaksocor.nomgrr,
        dddcod    like dpaksocor.dddcod,
        faxnum    like dpaksocor.faxnum,
        faxch1    like gfxmfax.faxch1,
        faxch2    like gfxmfax.faxch2,
        crnpgtcod like dpaksocor.crnpgtcod,
        maides    like dpaksocor.maides,
        celdddnum like dpaksocor.celdddnum,
        celtelnum like dpaksocor.celtelnum
    end record

    define l_ws record
        dddcod    like dpaksocor.dddcod,
        faxnum    like dpaksocor.faxnum,
        faxtxt    char (12),
        impflg    smallint,
        impnom    char (08),
        envflg    dec (1,0),
        confirma  char (01),
        comando   char(1000),
        retorno   smallint,
        remetente like igbmparam.relpamtxt
    end record

    #PSI 197858 - estrutura para tratar mensagem SMS
    define lr_saida       record
         result             smallint             # 1=Ok 2=Notfound 3-Erro Sql
        ,oprcod             like pcckceltelopr.oprcod
        ,oprnom             like pcckceltelopr.oprnom
        ,opratvflg          like pcckceltelopr.opratvflg
        ,msgerr             char(80)
    end record
    define lr_rotsms      record
        errcod             integer,
        msgerr             char(20)
    end record
    
    define l_msgsms       char(143)
    define l_aux          smallint
    define l_smsenvcod    like dbsmenvmsgsms.smsenvcod
    define l_cur          like dbsmenvmsgsms.incdat   
    

    ### RODOLFO MASSINI - INICIO 
    #---> Variaves para:
    #     remover (comentar) forma de envio de e-mails anterior e inserir
    #     novo componente para envio de e-mails.
    #---> feito por Rodolfo Massini (F0113761) em maio/2013
 
    define lr_mail record       
           rem char(50),        
           des char(250),       
           ccp char(250),       
           cco char(250),       
           ass char(500),       
           msg char(32000),     
           idr char(20),        
           tip char(4)          
    end record 
    
define lr_anexo_email record
       anexo1    char(300)
      ,anexo2    char(300)
      ,anexo3    char(300)
end record 
 
    define l_retorno smallint

    initialize lr_mail
              ,lr_anexo_email
              ,l_retorno
    to null
 
    ### RODOLFO MASSINI - FIM     
    
    initialize l_ctb11m17.* to null
    initialize l_ws.*       to null
    initialize lr_saida.*   to null
    initialize lr_rotsms.*  to null

    let int_flag             = false
    let l_ws.envflg          = true

    let l_ctb11m17.destino   = param.destino
    let l_ctb11m17.aplicacao = param.aplicacao

    #---------------------------------------------------------------------------
    # Define tipo do servidor de fax a ser utilizado (GSF)GS-Fax / (VSI) VSI-Fax
    #---------------------------------------------------------------------------
    let m_wsgfax = "VSI"

    if m_prep = 'S' then
        # ok
    else
        call ctb11m17_prep()
    end if

    whenever error continue
    open cctb11m17005 using param.pstcoddig
    fetch cctb11m17005 into l_ctb11m17.nomgrr,
                            l_ctb11m17.dddcod,
                            l_ctb11m17.faxnum,
                            l_ctb11m17.crnpgtcod,
                            l_ctb11m17.maides,
                            l_ctb11m17.celdddnum,
                            l_ctb11m17.celtelnum
    whenever error stop

    if sqlca.sqlcode <> 0 then
        error "Problemas ao selecionar Dados do prestador (CTB11M17005)--> Erro.: ",
              sqlca.sqlcode,"/",sqlca.sqlerrd[2]
        return
    end if

    # Aplicacao = (O)nline
    if l_ctb11m17.aplicacao = "O" then

        open window ctb11m17 at 12,08 with form "ctb11m17"
                    attribute (form line 1, border)

        display by name  l_ctb11m17.nomgrr

        input by name l_ctb11m17.destino,
                      l_ctb11m17.maides,
                      l_ctb11m17.dddcod,
                      l_ctb11m17.faxnum,
                      l_ctb11m17.celdddnum,                       #PSI 197858
                      l_ctb11m17.celtelnum  without defaults

            before field destino
                display by name l_ctb11m17.destino attribute (reverse)

            after field destino
                display by name l_ctb11m17.destino

                case l_ctb11m17.destino
                    when "F"
                        let l_ctb11m17.envdes = "FAX"
                    when "I"
                        let l_ctb11m17.envdes = "IMPRESSORA"
                    when "E"
                        let l_ctb11m17.envdes = "E-MAIL"
                    when "S"
                        let l_ctb11m17.envdes = "SMS"           #PSI 197858
                    otherwise
                        error " destino OP de servico para (E)mail, (I)mpressora, (F)ax ou (S)MS!"
                        next field destino
                end case

                display by name l_ctb11m17.envdes

                initialize  m_wsgpipe, l_ws.impflg, l_ws.impnom  to null

                # Destino = (I)mpressora
                if l_ctb11m17.destino = "I" then

                    call fun_print_seleciona (g_issk.dptsgl, "")
                         returning  l_ws.impflg,
                                    l_ws.impnom

                    if l_ws.impflg = false then
                        error " Departamento/Impressora nao cadastrada!"
                        next field destino
                    end if

                    if l_ws.impnom is null then
                        error " Uma impressora deve ser selecionada!"
                        next field destino
                    end if

                end if

                # Destino = (F)ax
                if l_ctb11m17.destino = "F" then
                    if g_hostname = "u07"  then
                        if g_issk.dptsgl = "desenv" or
                           g_issk.dptsgl = "fabsfw" or
                           g_issk.funmat = 5048     or
                           g_issk.funmat = 6080     then
                            # OK fax pode ser enviado para esta matricula
                        else
                            error " Fax so' pode ser enviado no ambiente de producao!"
                            next field destino
                        end if
                    end if
                end if

            before field maides
                display by name l_ctb11m17.maides attribute(reverse)
                if l_ctb11m17.destino <> "E" then
                   next field dddcod
                end if

            after field maides
                display by name l_ctb11m17.maides

                if fgl_lastkey() = fgl_keyval("up")   or
                   fgl_lastkey() = fgl_keyval("left") then
                    next field destino
                end if

                # Destino = (E)mail
                if l_ctb11m17.destino = "E" then
                    if l_ctb11m17.maides is null or
                       l_ctb11m17.maides = " "   then
                        error "E-mail do prestador deve ser informado!"
                        next field maides
                    end if
                end if
                exit input

            before field dddcod
                display by name l_ctb11m17.dddcod attribute (reverse)
                if l_ctb11m17.destino <> "F" then
                   next field celdddnum
                end if

            after field dddcod
                display by name l_ctb11m17.dddcod

                if fgl_lastkey() = fgl_keyval("up")   or
                   fgl_lastkey() = fgl_keyval("left") then
                    next field destino
                end if

                if l_ctb11m17.dddcod is null or
                   l_ctb11m17.dddcod = "  "  then
                    error " Codigo do DDD deve ser informado!"
                    next field dddcod
                end if

                if l_ctb11m17.dddcod = "0   " or
                   l_ctb11m17.dddcod = "00  " or
                   l_ctb11m17.dddcod = "000 " or
                   l_ctb11m17.dddcod = "0000" then
                    error " Codigo do DDD invalido!"
                    next field dddcod
                end if

            before field faxnum
                display by name l_ctb11m17.faxnum attribute (reverse)

            after field faxnum
                display by name l_ctb11m17.faxnum

                if fgl_lastkey() = fgl_keyval("up")   or
                   fgl_lastkey() = fgl_keyval("left") then
                    next field dddcod
                end if

                if l_ctb11m17.faxnum is null or
                   l_ctb11m17.faxnum = 000   then
                    error " Numero do fax deve ser informado!"
                    next field faxnum
                else
                    if l_ctb11m17.faxnum <= 99999 then
                        error " Numero do fax invalido!"
                        next field faxnum
                    end if
                end if
                exit input

            #PSI 197858
            before field celdddnum
                display by name l_ctb11m17.celdddnum attribute (reverse)
                if l_ctb11m17.destino <> "S" then
                   #caso tenha chegado ate esse campo e nao e envio de SMS
                   # so pode ser via impressora, entao pode sair do input
                   exit input
                end if

            after field celdddnum
                display by name l_ctb11m17.celdddnum

                if fgl_lastkey() = fgl_keyval("up")   or
                   fgl_lastkey() = fgl_keyval("left") then
                    next field destino
                end if

                if l_ctb11m17.celdddnum is null or
                   l_ctb11m17.celdddnum = "  "  then
                    error " Codigo do DDD deve ser informado!"
                    next field celdddnum
                end if

                if l_ctb11m17.celdddnum = "0   " or
                   l_ctb11m17.celdddnum = "00  " or
                   l_ctb11m17.celdddnum = "000 " then
                    error " Codigo do DDD invalido!"
                    next field celdddnum
                end if

            before field celtelnum
                display by name l_ctb11m17.celtelnum attribute (reverse)

            after field celtelnum
                display by name l_ctb11m17.celtelnum

                if fgl_lastkey() = fgl_keyval("up")   or
                   fgl_lastkey() = fgl_keyval("left") then
                    next field celdddnum
                end if

                if l_ctb11m17.celtelnum is null or
                   l_ctb11m17.celtelnum = 000   then
                    error " Numero do celular deve ser informado!"
                    next field celtelnum
                end if

                #verificar se SMS pode ser enviado para o celular selecionado
                #Hoje a fun��o envia SMS apenas para celulares da VIVO
                call fpccc016_obterOperadora(l_ctb11m17.celdddnum, l_ctb11m17.celtelnum)
                     returning lr_saida.*

                if lr_saida.result <> 1 then
                   error lr_saida.msgerr sleep 2
                   next field destino
                end if
                if lr_saida.result = 1 and lr_saida.opratvflg = "N" then
                   error "O servi�o SMS da CIA n�o encaminha mensagem para esta Operadora " sleep 2
                   next field destino
                end if

            on key (interrupt)
                exit input

        end input

    else # Aplicacao = (B)atch
        #PSI 197858
        # Quando aplicacao e Batch o destino � sempre e-mail
        # Se nao  houver email cadastrado, envia fax e se n�o tiver tenta enviar SMS
        if l_ctb11m17.maides is null or
           l_ctb11m17.maides = " "   then
           if l_ctb11m17.faxnum is null then
              if l_ctb11m17.celtelnum is null then
                 #nao enviar, pois n�o tem nem e-mail, nem fax e nem celular cadastrado
                 let int_flag = true
              else
                 #verificar se SMS pode ser enviado para o celular selecionado
                 #Hoje a fun��o envia SMS apenas para celulares da VIVO
                 call fpccc016_obterOperadora(l_ctb11m17.celdddnum, l_ctb11m17.celtelnum)
                      returning lr_saida.*

                 if lr_saida.result <> 1 or
                    (lr_saida.result = 1 and lr_saida.opratvflg = "N") then
                    #error "O servi�o SMS da CIA n�o encaminha mensagem para esta Operadora " sleep 2
                    let int_flag = true
                 else
                    #enviar mensagem SMS
                    let l_ctb11m17.destino = "S"
                 end if
              end if
            else
              #enviar FAX
              let l_ctb11m17.destino = "F"
            end if
        end if

    end if

    # Se nao houve interrupcao
    if not int_flag then

        # Se for (B)atch gera o arquivo no diretorio padrao
        if l_ctb11m17.aplicacao = "B" then
            let m_wsgpipe = f_path("DBS","ARQUIVO")
            if m_wsgpipe is null then
                let m_wsgpipe = "."
            end if
        else # Se for (O)nline gera o arquivo no diretorio atual
            let m_wsgpipe = "."
        end if

        let m_wsgpipe = m_wsgpipe clipped,
                        "/OP",
                        param.socopgnum using "&&&&&&&&",
                        ".DOC"

        # Se flag de envio ok
        if l_ws.envflg = true  then

            if m_prep = 'S' then
                # ok
            else
                call ctb11m17_prep()
            end if

            whenever error continue
            open cctb11m17001 using param.socopgnum
            fetch cctb11m17001 into m_dbsmopg.pstcoddig,
                                    m_dbsmopg.socfatitmqtd,
                                    m_dbsmopg.socfattotvlr
            whenever error stop

            if sqlca.sqlcode <> 0 then
                error "Problemas ao selecionar dados da OP (CTB11M17001)--> Erro.: ",
                      sqlca.sqlcode,"/",sqlca.sqlerrd[2]
                # Aplicacao = (O)nline
                if l_ctb11m17.aplicacao = "O" then
                    close window ctb11m17
                    let int_flag = false
                end if
                return
            end if

            close cctb11m17001

            #PSI 197858
            #mensagem enviada via FAX e e-mail contem uma lista com todos os servicos da OP
            #mensagem via SMS n�o � possivel enviar todos esses dados, pois tem limite de 143 carac.
            #caso seja SMS enviar mensagem com numero do OP , itens e valor
            if l_ctb11m17.destino = "S" then
               let l_msgsms = "PORTO SEGURO: a OP ", param.socopgnum, " esta disponivel para ",
                              "cobranca com ",
                               m_dbsmopg.socfatitmqtd using "<<<<<&",
                              " itens e com valor total de R$",
                               m_dbsmopg.socfattotvlr using "<,<<<,<<&.&&"
               #enviar mensagem SMS ao segurado
               
               #call figrc007_sms_send1 (l_ctb11m17.celdddnum,
               #                         l_ctb11m17.celtelnum,
               #                         l_msgsms,
               #                         lr_rotsms.sissgl,
               #                         lr_rotsms.prioridade ,
               #                         lr_rotsms.expiracao       )
               #             returning lr_rotsms.errcod,
               #                       lr_rotsms.msgerr
               
               let l_smsenvcod = "OP" clipped, param.socopgnum using "<<<<<<<<<&"
               let l_cur = current                                                                             
               open cctb11m17011 using l_smsenvcod 
               fetch cctb11m17011 into l_aux
               
               
               if  sqlca.sqlcode = notfound then
                   
                   whenever error continue                   
                   execute pctb11m17010 using l_smsenvcod,
                                              l_ctb11m17.celdddnum,
                                              l_ctb11m17.celtelnum,
                                              l_msgsms,            
                                              l_cur,
                                              "A"
                   
                   if  sqlca.sqlcode <> 0 then
                       display 'Erro : ', sqlca.sqlcode clipped, " Tabela de Envio de SMS"
                       display "l_smsenvcod          : ", l_smsenvcod
                       display "l_ctb11m17.celdddnum : ", l_ctb11m17.celdddnum 
                       display "l_ctb11m17.celtelnum : ", l_ctb11m17.celtelnum
                       display "l_msgsms             : ", l_msgsms 
                       display "l_cur                : ", l_cur      
                   end if
                   whenever error stop
               end if             
               
               if lr_rotsms.errcod <> 0 then
                  #error "Problemas ao tentar enviar mensagem SMS ao segurado:",lr_rotsms.msgerr
               else
                  #error "Mensagem SMS enviada ao segurado" sleep 2
               end if
            else
                #se n�o � mensagem SMS segue fluxo para envio e-mail, fax ou impressora
                # buscar os itens e montar mensagem
                let m_i = 1
                open cctb11m17002 using param.socopgnum
                foreach cctb11m17002 into m_rel[m_i].atdsrvnum,
                                          m_rel[m_i].atdsrvano,
                                          m_rel[m_i].socopgitmvlr
                                       
                
                
                    whenever error continue
                    open cctb11m17003 using m_rel[m_i].atdsrvnum,
                                            m_rel[m_i].atdsrvano
                    fetch cctb11m17003 into m_rel[m_i].vcllicnum
                    whenever error stop

                    if sqlca.sqlcode <> 0 then
                        error "Problemas ao selecionar dados do veiculo (CTB11M17003)--> Erro.: ",
                              sqlca.sqlcode,"/",sqlca.sqlerrd[2]
                        # Aplicacao = (O)nline
                        if l_ctb11m17.aplicacao = "O" then
                            close window ctb11m17
                            let int_flag = false
                        end if
                        return
                    end if

                    let m_i = m_i + 1

                    if m_i > 499 then
                        error "Excedeu o limte de 500 linhas"
                        exit foreach
                    end if

                end foreach

                start report rep_op to m_wsgpipe

                output to report rep_op(param.socopgnum,
                                        param.pstcoddig,
                                        l_ctb11m17.dddcod,
                                        l_ctb11m17.faxnum,
                                        l_ctb11m17.destino,
                                        l_ctb11m17.nomgrr,
                                        l_ctb11m17.faxch1,
                                        l_ctb11m17.faxch2,
                                        l_ctb11m17.crnpgtcod)

                finish report  rep_op

                # Destino = (E)mail
                if l_ctb11m17.destino = "E" then

                    # Recupera o remetente parametrizado
                    whenever error continue
                    open  cctb11m17008
                    fetch cctb11m17008 into l_ws.remetente
                    whenever error stop

                    if sqlca.sqlcode <> 0 then
                        error "Problemas ao selecionar email remetente (CTB11M17008)--> Erro.: ",
                              sqlca.sqlcode,"/",sqlca.sqlerrd[2]
                        # Aplicacao = (O)nline
                        if l_ctb11m17.aplicacao = "O" then
                            close window ctb11m17
                            let int_flag = false
                        end if
                        return
                    end if

                    if l_ws.remetente is null or
                       l_ws.remetente = "" then
                        let l_ws.remetente = "porto.socorro@porto-seguro.com.br"
                    end if
                    
                    ### RODOLFO MASSINI - INICIO 
                    #---> remover (comentar) forma de envio de e-mails anterior e inserir
                    #     novo componente para envio de e-mails.
                    #---> feito por Rodolfo Massini (F0113761) em maio/2013
                      
                    #let l_ws.comando = ' echo "CTB11M17" | send_email.sh ',
                    #                   ' -a     ', l_ctb11m17.maides clipped,
                    #                   ' -s "OP ', param.socopgnum clipped, '" ',
                    #                   ' -f     ', m_wsgpipe clipped,
                    #                   ' -r     ', l_ws.remetente
                             
                    let l_ws.comando = null
                             
                    let lr_mail.ass = "OP ", param.socopgnum clipped
                    let lr_mail.msg = "CTB11M17"     
                    let lr_mail.rem = l_ws.remetente clipped
                    let lr_mail.des = l_ctb11m17.maides clipped
                    let lr_mail.tip = "text"
                    let lr_anexo_email.anexo1 = m_wsgpipe clipped
                    
                    call ctx22g00_envia_email_anexos(lr_mail.*
                                                      ,lr_anexo_email.*)
                    returning l_retorno                                        
                                         
                    let  l_ws.retorno = l_retorno
                                               
                    ### RODOLFO MASSINI - FIM 

                end if

                # Destino = (F)ax
                if l_ctb11m17.destino = "F" then

                    call cts10g01_enviofax(param.socopgnum,1,"","PS",g_issk.funmat)
                                 returning l_ws.envflg,
                                           l_ctb11m17.faxch1,
                                           l_ctb11m17.faxch2
                    if m_wsgfax = "GSF" then
                        if g_hostname = "u07" then
                            let l_ws.impnom = "tstclfax"
                        else
                            let l_ws.impnom = "ptsocfax"
                        end if
                        let m_wsgpipe = "lp -sd ",l_ws.impnom
                    else
                        let l_ws.faxtxt = cts02g01_fax(l_ctb11m17.dddcod,l_ctb11m17.faxnum)
                        let l_ws.comando = "cat ",
                                          m_wsgpipe clipped,
                                          "|",
                                          "vfxCTPS ",
                                          l_ws.faxtxt clipped,
                                          " ",
                                          ascii 34,
                                          l_ctb11m17.nomgrr clipped,
                                          ascii 34,
                                          " ",
                                          l_ctb11m17.faxch1 using "&&&&&&&&&&",
                                          " ",
                                          l_ctb11m17.faxch2 using "&&&&&&&&&&"
                    end if

                end if

                # Destino = (I)mpressora
                if l_ctb11m17.destino = "I" then
                    let l_ws.comando = "lp -sd ",
                                       l_ws.impnom clipped,
                                       " ",
                                       m_wsgpipe clipped
                end if

                ### RODOLFO MASSINI - INICIO 
                #---> remover (comentar) forma de envio de e-mails anterior e inserir
                #     nova forma de envio de e-mails.
                #---> feito por Rodolfo Massini (F0113761) em maio/2013
                      
                #run l_ws.comando returning l_ws.retorno                       
                 
                if l_ws.comando is not null then
                   run l_ws.comando returning l_ws.retorno
                end if
                                                                    
                ### RODOLFO MASSINI - FIM 
                               
                if l_ws.retorno <> 0 then
                    if l_ctb11m17.aplicacao = "O" then
                        let l_ws.confirma = cts08g01("A","S","OCORREU UM PROBLEMA NO",
                                                     "ENVIO DOS DADOS!","",
                                                     "*** TENTE NOVAMENTE ***")
                    else
                        display "Erro ao enviar dados da OP (ctb11m17) - ", m_wsgpipe clipped
                    end if
                else
                    if l_ctb11m17.aplicacao = "O" then
                        let l_ws.comando = "rm ",m_wsgpipe
                        run l_ws.comando
                    end if

                end if
            end if
        else
            if l_ctb11m17.aplicacao = "O" then
                call cts08g01 ("A", "S", "OCORREU UM PROBLEMA NO",
                               "ENVIO DO FAX!","",
                               "*** TENTE NOVAMENTE ***")
                returning l_ws.confirma
            else
                display "Erro ao enviar fax(ctb11m17) - ", param.socopgnum clipped
            end if
        end if
    else
        if l_ctb11m17.aplicacao = "O" then
            error " ATENCAO !!! FAX NAO SERA' ENVIADO!"
            call cts08g01("A","N","","FAX DA ORDEM DE PAGAMENTO",
                          "*** NAO SERA' ENVIADO ***","")
            returning l_ws.confirma
        else
            display "Erro ao enviar fax(ctb11m17) - ", param.socopgnum clipped
        end if
    end if

    let int_flag = false

    if l_ctb11m17.aplicacao = "O" then
        close window ctb11m17
        let int_flag = false
    end if

end function  ###  ctb11m17

#---------------------------------------------------------------------------
report rep_op (l_ctb11m17)
#---------------------------------------------------------------------------

    define l_ctb11m17 record
        socopgnum like dbsmopg.socopgnum,
        pstcoddig like dpaksocor.pstcoddig,
        dddcod    like dpaksocor.dddcod,
        faxnum    dec  (8,0),
        destino   char (01),
        nomgrr    char (24),
        faxch1    like gfxmfax.faxch1,
        faxch2    like gfxmfax.faxch2,
        crnpgtcod like dpaksocor.crnpgtcod
    end record

    define l_w         smallint,
           l_ciacodemp smallint

    output
        left   margin  00
        right  margin  80
        top    margin  00
        bottom margin  00
        page   length  58
    format

    on every row

        # Destino = (F)ax
        if l_ctb11m17.destino = "F" then

            if m_wsgfax = "GSF" then

                #----------------------------------------
                # Checa caracteres invalidos para o GSFAX
                #----------------------------------------
                call cts02g00(l_ctb11m17.nomgrr) returning l_ctb11m17.nomgrr

                # Codigo DDD
                if l_ctb11m17.dddcod > 99 then
                    print column 001, l_ctb11m17.dddcod using "&&&&";
                else
                    print column 001, l_ctb11m17.dddcod using "&&&";
                end if

                # Numero do Fax
                if l_ctb11m17.faxnum > 9999999 then
                    print column 001, l_ctb11m17.faxnum using "&&&&&&&&";
                else
                    if l_ctb11m17.faxnum > 999999 then
                        print column 001, l_ctb11m17.faxnum using "&&&&&&&";
                    else
                        print column 001, l_ctb11m17.faxnum using "&&&&&&";
                    end if
                end if

                print column 001                        ,
                "@"                                     , # Delimitador
                l_ctb11m17.nomgrr                       , # Destinatario Cx pos
                "*CTPS"                                 , # Sistema/Subsistema
                l_ctb11m17.faxch1    using "&&&&&&&&&&" , # No./Ano Servico
                l_ctb11m17.faxch2    using "&&&&&&&&&&" , # Sequencia
                "@"                                     , # Delimitador
                l_ctb11m17.nomgrr                       , # Destinat.(Informix)
                "@"                                     , # Delimitador
                "CENTRAL 24 HORAS"                      , # Quem esta enviando
                "@"                                     , # Delimitador
                "132PORTO.TIF"                          , # Arquivo Logotipo
                "@"                                     , # Delimitador
                "semcapa"                                 # Nao tem cover page

            end if

            if m_wsgfax = "VSI"  then

		open cctb11m17009 using l_ctb11m17.socopgnum
		fetch cctb11m17009 into l_ciacodemp

                case l_ciacodemp
                	when 1
                		#FORMATACAO PARA 132 COLUNAS
                		#print column 001, ascii 27, "&k2S";    # Caracteres
                		#print             ascii 27, "(s7b";    # de controle
                		#print             ascii 27, "(s4102T"; # para 132
                		#print             ascii 27, "&l08D";   # colunas

                		print             ascii 27, "&l00E";    # Logo no topo
                		print column 001, "@+IMAGE[porto.tif;x=0cm;y=0cm]"

                		skip 8 lines
                		print "+-----------+ Dados Porto Seguro para Emiss�o da Nota Fiscal +--------------+"
                		print "| Porto Seguro Cia de Seguros Gerais            CNPJ:61.198.164/0001-60     |"
                		print "| Av. Rio Branco, 1489 - Campos Eliseos - Sao Paulo/SP - CEP 01205-905      |"
                		print "| Inscri��o Municipal: Deixar em branco ou Isento (se houver campo na nota) |"
                		print "| Inscri��o Estadual: 108.377.122.112   (se houver campo na nota)           |"
                		print "+---------------------------------------------------------------------------+"


                	when 35
                		print             ascii 27, "&l00E";    # Logo no topo
                		print column 001, "@+IMAGE[azul.tif;x=0cm;y=0cm]"
                		skip 8 lines
                		print "+-----------+ Dados Azul Seguro para Emiss�o da Nota Fiscal +---------------+"
                		print "| Azul Cia. de Seguros Gerais                   CNPJ:33.448.150/0002-00     |"
                		print "| Av. Paulista, 463 - 16� andar - Centro - Sao Paulo/SP - CEP 01311-907     |"
                		print "| Inscri��o Municipal: 11.73.29.0-3 (Se houver o campo na nota fiscal)      |"
                		print "| Inscri��o Estadual: Deixar em branco ou Isento (se houver campo na nota)  |"
                		print "+---------------------------------------------------------------------------+"

                	when 84
                	  print column 001, "ITA� SEGUROS AUTO E RESID�NCIA"
                	  skip 8 lines
                		print "+---+ Dados Ita� Seguros Auto e Resid�ncia p/ Emiss�o da Nota Fiscal +------+"
                		print "| Itau Seguros de Auto e Resid�ncia             CNPJ:08.816.067/0001-00     |"
                		print "| Av. Eusebio Matoso, 1375 - Butant� - S�o Paulo/SP - CEP 05423-905         |"
                		print "| Inscri��o Municipal: 11.73.29.0-3 (Se Houver Campo na Nota Fiscal)	       |"
                		print "| Inscri��o Estadual: Deixar em branco ou Isento (se houver campo na nota)  |"
                		print "+---------------------------------------------------------------------------+"

                	otherwise
                		error "Empresa nao encontrada"
                		sleep 3
                end case

                skip 1 lines

            end if

        end if
        
        if l_ctb11m17.destino  <>  "F" then
          open cctb11m17009 using l_ctb11m17.socopgnum
		      fetch cctb11m17009 into l_ciacodemp
          
             case l_ciacodemp
             	
          
             	when 1
             	  print "+---------+ Dados Porto Seguro para Emiss�o da Nota Fiscal +------------+"
                print "| Porto Seguro Cia de Seguros Gerais            CNPJ:61.198.164/0001-60 |"
                print "| Av. Rio Branco, 1489 - Campos Eliseos - Sao Paulo/SP - CEP 01205-905  |"
                print "| Inscri��o Municipal: Deixar em branco ou Isento                       |"
                print "| Inscri��o Estadual: 108.377.122.112   (se houver campo na nota)       |"
                print "+-----------------------------------------------------------------------+"
          
             	when 35
             		
             		print "+---------+ Dados Azul Seguro para Emiss�o da Nota Fiscal +-------------+"
             		print "| Azul Cia. de Seguros Gerais                 CNPJ:33.448.150/0002-00   |"
             		print "| Av. Paulista, 463 - 16� andar - Centro - Sao Paulo/SP - CEP 01311-907 |"
             		print "| Inscri��o Municipal: 11.73.29.0-3 (Se houver o campo na nota fiscal)  |"
             		print "| Insc. Estadual: Deixar em branco ou Isento (se houver campo na nota)  |"
             		print "+-----------------------------------------------------------------------+"
          
             	when 84
             	  
             	  print "+--+ Dados Ita� Seguros Auto e Resid�ncia p/ Emiss�o da Nota Fiscal +---+"
                print "| Itau Seguros de Auto e Resid�ncia             CNPJ:08.816.067/0001-00 |"
                print "| Av. Eusebio Matoso, 1375 - Butant� - S�o Paulo/SP - CEP 05423-905     |"
                print "| Inscri��o Municipal: 36.36.59.5-5 (Se Houver Campo na Nota Fiscal)    |"
                print "| Inscri��o Estadual: 148.873.273.117 (Se houver campo na Nota Fiscal)  |"
                print "+-----------------------------------------------------------------------+"
          
             	otherwise
             		error "Empresa nao encontrada"
             		sleep 3
             end case
        end if
           skip 1 lines

        # Destino = (I)mpressora
        if l_ctb11m17.destino  =  "I" then
            print column 001, "Enviar para: ",
                              l_ctb11m17.nomgrr,
                              "    Fax: ",
                              "(",
                              l_ctb11m17.dddcod,
                              ")",
                              l_ctb11m17.faxnum
        end if

        print column 001,"Prestador: ", l_ctb11m17.pstcoddig,
                                        " - ",
                                        l_ctb11m17.nomgrr

        print column 001,"Numero da OP: ", l_ctb11m17.socopgnum

        skip 1 line
        print column 001,"Sinistro/Processo	Placa Veiculo    Valor Liberado"

        if m_i > 1 then
            let l_w = m_i - 1
            for m_i = 1 to l_w
                print column 001, m_rel[m_i].atdsrvnum,"-",m_rel[m_i].atdsrvano using "&&",
                      column 027, m_rel[m_i].vcllicnum,
                      column 042, m_rel[m_i].socopgitmvlr using "#,###,##&.&&"
            end for
        end if

        skip 1 line
        print column 001, "Itens da OP: ", m_dbsmopg.socfatitmqtd
        print column 001, "Valor Liberado: ", m_dbsmopg.socfattotvlr using "#,###,##&.&&"
        skip 1 line

        # Imprime mensagem com codigo 1
        let m_prsmsgtxt = ""
        let l_w = 0

        open cctb11m17006
        foreach cctb11m17006 into m_prsmsgtxt
            let l_w = l_w + 1
            if l_w > 500 then
                exit foreach
            else
                print column 001, m_prsmsgtxt
            end if
        end foreach

        # Imprimir as proximas datas de cronograma
        skip 1 line
        print column 001, "As proximas datas de fechamento do seu cronograma sao:"

        let m_prsmsgtxt = ""
        let l_w = 0

        open cctb11m17007 using l_ctb11m17.crnpgtcod
        foreach cctb11m17007 into m_crnpgtetgdat
            let l_w = l_w + 1
            if l_w > 3 then
	            exit foreach
            else
	            print column 001, m_crnpgtetgdat
            end if
        end foreach

        if l_w = 0 then
            print column 001, "Datas nao disponiveis."
        end if

        skip 1 line

end report  ###  rep_op

