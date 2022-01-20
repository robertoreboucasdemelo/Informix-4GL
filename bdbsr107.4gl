#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR107                                                   #
# ANALISTA RESP..: RAJI DUENHAS JAHCHAN                                       #
# PSI/OSF........: PAS 20818                                                  #
#                  RELATORIO DIARIO DE DISPONIBILIDADE DOS SOCORRISTAS.       #                                                 #
# ........................................................................... #
# DESENVOLVIMENTO: SERGIO BURINI                                              #
# LIBERACAO......: 03/01/2007                                                 #
# ........................................................................... #
#                                                                             #
#                         * * * * ALTERACOES * * * *                          #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 23/01/2009 Burini          PSI 235750 Relatório de Disponibilidade de SRR   #
#-----------------------------------------------------------------------------#

database porto

define m_data  date,
       m_lidos integer,
       m_path  char(1000),
       m_path2 char(1000),
       m_path3 char(1000),
       m_path4 char(1000),
       m_data_c char(10)

define relat record
    datlimini    date,
    seqmin       integer,
    seqmax       integer,
    hint         smallint,
    hchr         char(8),
    hora         datetime hour to second,
    botao        char(3),
    cidcod       integer,
    nomgrr       like dpaksocor.nomgrr,
    atdvclsgl    like datkveiculo.atdvclsgl,
    vcllicnum    like datkveiculo.vcllicnum,
    cpodes       like iddkdominio.cpodes,
    pstcoddig    like dpaksocor.pstcoddig,
    mdtcod       like datkveiculo.mdtcod,
    mdtbotprgseq like datmmdtmvt.mdtbotprgseq,
    sedufdcod    like datmmdtmvt.ufdcod,
    sedcidnom    like datmmdtmvt.cidnom,
    sedufdcodpst like datmmdtmvt.ufdcod,
    sedcidnompst like datmmdtmvt.cidnom,
    ufdcod       like datmmdtmvt.ufdcod,
    cidnom       like datmmdtmvt.cidnom,
    ufpst        like datmmdtmvt.ufdcod,
    cidpst       like datmmdtmvt.cidnom,
    brrnom       like datmmdtmvt.brrnom,
    resultado    smallint,
    mensagem     char(060),
    socvclcod    like datkveiculo.socvclcod
end record

main

    call fun_dba_abre_banco("CT24HS")

    let m_data = arg_val(1)
    initialize relat.* to null
    let m_lidos = 0
    set isolation to dirty read 

    # FORMATA DATA
    if  m_data is null then
        let m_data = (today - 1 units day)
    end if

    let relat.datlimini = m_data - 1 units day

    call bdbsr107_busca_path()
    whenever error continue
    call bdbsr107()
    whenever error stop
    
   display "bdbsr107_FIM"
    

end main

#---------------------------#
 function bdbsr107_prepare()
#---------------------------#

     define l_sql char(1000)

     let l_sql = ' SELECT MIN(mdtmvtseq) ',
                   ' FROM datmmdtmvt ',
                  ' WHERE mdtmvtstt    = 2 ',
                    ' AND mdtmvttipcod = 2 ',
                    ' AND caddat       = ? ',
                    ' AND mdtbotprgseq IN (1,2,3,8,9,10,11,14,15,18) '
     prepare pc01 from l_sql
     declare cq01 cursor for pc01

     let l_sql = ' SELECT MAX(mdtmvtseq) ',
                   ' FROM datmmdtmvt ',
                  ' WHERE mdtmvtstt    = 2 ',
                    ' AND mdtmvttipcod = 2 ',
                    ' AND caddat       = ?  ',
                    ' AND mdtbotprgseq IN (1,2,3,8,9,10,11,14,15,18) '
     prepare pc02 from l_sql
     declare cq02 cursor for pc02

     let l_sql = "SELECT mdtbotprgseq, ",
                       " ufdcod, ",
                       " cidnom, ",
                       " brrnom ",
                  " FROM datmmdtmvt",
                 " WHERE mdtmvtseq = (SELECT max(mdtmvtseq) ",
                                      " FROM datmmdtmvt ",
                                     " WHERE mdtcod = ? ",
                                       " AND ((caddat = ? AND cadhor <= ?) OR (caddat < ?)) ",
                                       " AND mdtmvtstt    = 2 ",
                                       " AND mdtmvttipcod = 2 ",
                                       " AND mdtbotprgseq IN (1,2,3,8,9,10,11,14,15,18) ",
                                       " AND mdtmvtseq    > ? ",
                                       " AND mdtmvtseq    < ? )"
     prepare pc03 from l_sql
     declare cq03 cursor for pc03

     let l_sql = "SELECT nomgrr, ",
                       " endcid, ",
                       " endufd, ",
                       " atdvclsgl, ",
                       " vcllicnum, ",
                       " cpodes, ",
                       " datkveiculo.socvclcod, ",
                       " datkveiculo.pstcoddig, ",
                       " mdtcod ",
                  " FROM datkveiculo, ",
                       " dpaksocor, ",
                       " iddkdominio ",
                 " WHERE mdtcod                > 0 ",
                   " AND socoprsitcod          = 1 ",
                   " AND datkveiculo.pstcoddig = dpaksocor.pstcoddig ",
                   " AND iddkdominio.cponom    = 'socvcltip' ",
                   " AND iddkdominio.cpocod    = datkveiculo.socvcltip "
     prepare pc04 from l_sql
     declare cq04 cursor for pc04

     let l_sql = "select cpodes ",
                  " from iddkdominio ",
                 " where cponom = ? ",
                   " and cpocod = ? "

     prepare pc16 from l_sql
     declare cq16 cursor for pc16

 end function

#----------------------------#
 function bdbsr107_busca_path()
#----------------------------#

  define l_dataarq char(8)
  define l_data    date
  
  let l_data = today

  let l_dataarq = extend(l_data, year to year),
                  extend(l_data, month to month),
                  extend(l_data, day to day)

  let m_path  = null
  let m_path2 = null
  let m_path3 = null
  let m_path4 = null

  let m_path = f_path("DBS","LOG")

  if  m_path is null then
      let m_path = "."
  end if

  let m_path = m_path clipped,"/bdbsr107.log"

  call startlog(m_path)

  # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
  let m_path = f_path("DBS", "RELATO")

  if  m_path is null then
      let m_path = "."
  end if
  
  let m_data_c = m_data
  let m_path2 = m_path
  let m_path3 = m_path
  let m_path4 = m_path
  
  let m_path  = m_path  clipped, "/BDBSR107_" , m_data_c[7,10], m_data_c[4,5], m_data_c[1,2], ".xls"
  let m_path3 = m_path3 clipped, "/BDBSR107_", l_dataarq, ".txt" 
  let m_path2  = m_path2  clipped, "/BDBSR107_SEMROD" , m_data_c[7,10], m_data_c[4,5], m_data_c[1,2], ".xls"
  let m_path4 = m_path4 clipped, "/BDBSR107_SEMROD", l_dataarq, ".txt" 

end function

#------------------#
 function bdbsr107()
#------------------#

     call bdbsr107_prepare()
     
     # PROCESSO DE DISPONIBILIDADE VEICULO
     call cts40g03_exibe_info("I","BDBSR107")
     
     open  cq01 using relat.datlimini
     fetch cq01 into  relat.seqmin
     close cq01
     
     open  cq02 using m_data
     fetch cq02 into  relat.seqmax
     close cq02    
     
     open  cq04
     fetch cq04 into relat.nomgrr,
                     relat.cidpst,
                     relat.ufpst,
                     relat.atdvclsgl,
                     relat.vcllicnum,
                     relat.cpodes,
                     relat.socvclcod,
                     relat.pstcoddig,
                     relat.mdtcod
     
     case sqlca.sqlcode
          when 0
               call bdbsr107_relat()
          when 100
               display 'Argumentos de pesquisa nao encontrados.'
          otherwise
               display 'ERRO : ',sqlca.sqlcode
     end case
     
     call cts40g03_exibe_info("F","BDBSR107")

     call bdbsr107_envia_email()

 end function

#-------------------------#
 function bdbsr107_relat()
#-------------------------#

     start report rep_bdbsr107 to m_path
     start report rep_bdbsr107_txt to m_path3
     start report rep_bdbsr107b to m_path2
     start report rep_bdbsr107b_txt to m_path4

     foreach cq04 into relat.nomgrr,
                       relat.cidpst,
                       relat.ufpst,
                       relat.atdvclsgl,
                       relat.vcllicnum,
                       relat.cpodes,
                       relat.socvclcod,
                       relat.pstcoddig,
                       relat.mdtcod

         let m_lidos = m_lidos + 1

         output to report rep_bdbsr107()
         output to report rep_bdbsr107_txt()
         output to report rep_bdbsr107b()
         output to report rep_bdbsr107b_txt()

     end foreach

     finish report rep_bdbsr107
     finish report rep_bdbsr107_txt
     finish report rep_bdbsr107b
     finish report rep_bdbsr107b_txt
     
 end function

#-----------------------------#
function bdbsr107_envia_email()
#-----------------------------#

    define l_assunto     char(100),
           l_erro_envio  integer,
           l_comando     char(200)

    # DISPONIBILIDADE DE VEICULOS
    let l_comando    = null
    let l_erro_envio = null
    let l_assunto    = "Relatorio de Disponibilidade Veiculo dia: ",m_data using "dd/mm/yyyy"

    let l_comando = "gzip -f ", m_path

    run l_comando

    let m_path = m_path clipped, ".gz"

    let l_erro_envio = ctx22g00_envia_email("BDBSR107", l_assunto, m_path)

    if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
          display "Erro ao enviar email(ctx22g00) - ", m_path
       else
          display "Nao existe email cadastrado para o modulo - BDBSR107"
       end if
    end if
    
    let l_comando    = null
    let l_erro_envio = null
    let l_assunto    = "Relatorio de Disponibilidade Veiculo - SEM ROD -  dia: ",m_data using "dd/mm/yyyy"

    let l_comando = "gzip -f ", m_path2

    run l_comando

    let m_path2 = m_path2 clipped, ".gz"

    let l_erro_envio = ctx22g00_envia_email("BDBSR107", l_assunto, m_path2)

    if l_erro_envio <> 0 then
       if l_erro_envio <> 99 then
          display "Erro ao enviar email(ctx22g00) - ", m_path2
       else
          display "Nao existe email cadastrado para o modulo - BDBSR107"
       end if
    end if
    
    
    
end function

#-----------------------------------#
function bdbsr107_ver_tip_atv(param)
#-----------------------------------#

  define param record
      dominio      char(15),
      mdtbotprgseq like datmmdtmvt.mdtbotprgseq
  end record
  
  define lcpodes like iddkdominio.cpodes
  define l_retorno smallint
  
  open cq16 using param.dominio,
                  param.mdtbotprgseq
  fetch cq16 into lcpodes
                
  let l_retorno = sqlca.sqlcode
  
  close cq16
  
  return l_retorno
  
end function

#---------------------#
 report rep_bdbsr107()
#---------------------#

     define l_erro smallint
     define l_dominio char(20)     
     
     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    03

     format

        first page header

            print "UF SEDE",            ASCII(09),
                  "CIDADE SEDE",        ASCII(09),
                  "UF",                 ASCII(09),
                  "CIDADE",             ASCII(09),
                  "BAIRRO",             ASCII(09),
                  "PRESTADOR",          ASCII(09),
                  "UF SEDE PREST.",     ASCII(09),
                  "CIDADE SEDE PREST.", ASCII(09),
                  "VEICULO",            ASCII(09),
                  "SIGLA",              ASCII(09),
                  "PLACA",              ASCII(09),
                  "TIPO VEICULO",       ASCII(09),
                  "DATA",               ASCII(09),
                  "0h",                 ASCII(09),
                  "1h",                 ASCII(09),
                  "2h",                 ASCII(09),
                  "3h",                 ASCII(09),
                  "4h",                 ASCII(09),
                  "5h",                 ASCII(09),
                  "6h",                 ASCII(09),
                  "7h",                 ASCII(09),
                  "8h",                 ASCII(09),
                  "9h",                 ASCII(09),
                  "10h",                ASCII(09),
                  "11h",                ASCII(09),
                  "12h",                ASCII(09),
                  "13h",                ASCII(09),
                  "14h",                ASCII(09),
                  "15h",                ASCII(09),
                  "16h",                ASCII(09),
                  "17h",                ASCII(09),
                  "18h",                ASCII(09),
                  "19h",                ASCII(09),
                  "20h",                ASCII(09),
                  "21h",                ASCII(09),
                  "22h",                ASCII(09),
                  "23h",                ASCII(09)

        on every row

            for relat.hint = 1 to 24

                if  relat.hint <> 24 then
                    let relat.hchr = relat.hint using "&&", ":00:00"
                    let relat.hora = relat.hchr
                    let relat.hora = relat.hora - 1 units second
                else
                    let relat.hchr = "00:00:00"
                    let relat.hora = "23:59:59"
                end if

                let relat.botao = ""
                
                whenever error continue
                open cq03 using relat.mdtcod,
                                m_data,
                                relat.hora,
                                m_data,
                                relat.seqmin,
                                relat.seqmax

                

                fetch cq03 into relat.mdtbotprgseq,
                                relat.ufdcod,
                                relat.cidnom,
                                relat.brrnom

                if  sqlca.sqlcode = 100 then

                    let relat.mdtbotprgseq = 0
                else   
                    if sqlca.sqlcode <> 0 then
                        let l_erro = sqlca.sqlcode
                        display "Erro sqlca.sqlcode = ", l_erro, " n cursor cq03"
                    end if  
                end if
                
                close cq03
                whenever error stop

                if  relat.mdtbotprgseq is null then
                    let relat.mdtbotprgseq = 0
                end if
                
                #Verifica se atividade faz parte do primeiro dominio para setar 0
                let l_dominio = 'atvvcltip'
                call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                     returning l_erro
                     
                if l_erro = 0 then
                   let relat.botao = "0"
                else
                   #Verifica se atividade faz parte do segundo dominio para setar 1
                   
                   let l_dominio = 'atvvcltipum'
                   call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                        returning l_erro
                     
                   if l_erro = 0 then
                      let relat.botao = "1"
                   else
                     #Verifica se atividade faz parte do terceiro dominio para setar 2
                     let l_dominio = 'atvvcltipdois'
                     call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                          returning l_erro
                     
                     if l_erro = 0 then
                        let relat.botao = "2"
                     else
                        #Verifica se atividade faz parte do quarto dominio para setar 3
                        let l_dominio = 'atvvcltiptres'
                        call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                             returning l_erro
                   
                        if l_erro = 0 then
                           let relat.botao = "3"
                        else
                           let relat.botao = "0" #INDISPONIVEL - NÃO CADASTRADO EM UM DOMINIO               

                        end if
                     end if
                   end if  
                end if     
                           
                if  relat.hint = 1 then

                    let relat.sedufdcod = null
                    let relat.sedcidnom = null

                    # --> Busca o codigo da cidade
                    call cty10g00_obter_cidcod(relat.cidnom,
                                               relat.ufdcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o nome e o UF da cidade sede
                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnom,
                                   relat.sedufdcod

                    if  relat.sedcidnom is null then
                        let relat.sedufdcod = relat.ufdcod
                        let relat.sedcidnom = relat.cidnom
                    end if

                    # --> Busca a cidade sede prestador
                    call cty10g00_obter_cidcod(relat.cidpst,
                                               relat.ufpst)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnompst,
                                   relat.sedufdcodpst

                    if  relat.sedcidnompst is null then
                        let relat.sedufdcod = relat.ufpst
                        let relat.sedcidnom = relat.cidpst
                    end if

                    print relat.sedufdcod,            ASCII(09),
                          relat.sedcidnom clipped,    ASCII(09),
                          relat.ufdcod,               ASCII(09),
                          relat.cidnom    clipped,    ASCII(09),
                          relat.brrnom    clipped,    ASCII(09),
                          relat.nomgrr    clipped,    ASCII(09),
                          relat.sedufdcodpst,         ASCII(09),
                          relat.sedcidnompst clipped, ASCII(09),
                          relat.socvclcod    clipped, ASCII(09),
                          relat.atdvclsgl    clipped, ASCII(09),
                          relat.vcllicnum,            ASCII(09),
                          relat.cpodes       clipped, ASCII(09),
                          m_data             using "yyyy-mm-dd", ASCII(09);

                end if

                if  relat.hint = 24 then
                    print relat.botao
                else
                    print relat.botao, ASCII(09);
                end if
            end for

 end report


#---------------------#
 report rep_bdbsr107_txt()
#---------------------#

     define l_erro smallint
     define l_dominio char(20)     
     
     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    01

     format


        on every row

            for relat.hint = 1 to 24

                if  relat.hint <> 24 then
                    let relat.hchr = relat.hint using "&&", ":00:00"
                    let relat.hora = relat.hchr
                    let relat.hora = relat.hora - 1 units second
                else
                    let relat.hchr = "00:00:00"
                    let relat.hora = "23:59:59"
                end if

                let relat.botao = ""
                
                whenever error continue
                open cq03 using relat.mdtcod,
                                m_data,
                                relat.hora,
                                m_data,
                                relat.seqmin,
                                relat.seqmax

                

                fetch cq03 into relat.mdtbotprgseq,
                                relat.ufdcod,
                                relat.cidnom,
                                relat.brrnom

                if  sqlca.sqlcode = 100 then
 
                    let relat.mdtbotprgseq = 0
                else   
                    if sqlca.sqlcode <> 0 then
                        let l_erro = sqlca.sqlcode
                        display "Erro sqlca.sqlcode = ", l_erro, " n cursor cq03"
                    end if  
                end if
                
                close cq03
                whenever error stop

                if  relat.mdtbotprgseq is null then
                    let relat.mdtbotprgseq = 0
                end if
                
                #Verifica se atividade faz parte do primeiro dominio para setar 0
                let l_dominio = 'atvvcltip'
                call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                     returning l_erro
                     
                if l_erro = 0 then
                   let relat.botao = "0"
                else
                   #Verifica se atividade faz parte do segundo dominio para setar 1
                   let l_dominio = 'atvvcltipum'
                   call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                        returning l_erro
                     
                   if l_erro = 0 then
                      let relat.botao = "1"
                   else
                     #Verifica se atividade faz parte do terceiro dominio para setar 2
                     let l_dominio = 'atvvcltipdois'
                     call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                          returning l_erro
                     
                     if l_erro = 0 then
                        let relat.botao = "2"
                     else
                        #Verifica se atividade faz parte do quarto dominio para setar 3
                        let l_dominio = 'atvvcltiptres'
                        call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                             returning l_erro

                        if l_erro = 0 then
                           let relat.botao = "3"
                        else
                           let relat.botao = "0" #INDISPONIVEL - NÃO CADASTRADO EM UM DOMINIO               

                        end if
                     end if
                   end if  
                end if     
                           
                if  relat.hint = 1 then

                    let relat.sedufdcod = null
                    let relat.sedcidnom = null

                    # --> Busca o codigo da cidade
                    call cty10g00_obter_cidcod(relat.cidnom,
                                               relat.ufdcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o nome e o UF da cidade sede
                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnom,
                                   relat.sedufdcod

                    if  relat.sedcidnom is null then
                        let relat.sedufdcod = relat.ufdcod
                        let relat.sedcidnom = relat.cidnom
                    end if

                    # --> Busca a cidade sede prestador
                    call cty10g00_obter_cidcod(relat.cidpst,
                                               relat.ufpst)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnompst,
                                   relat.sedufdcodpst

                    if  relat.sedcidnompst is null then
                        let relat.sedufdcod = relat.ufpst
                        let relat.sedcidnom = relat.cidpst
                    end if

                    print relat.sedufdcod,            ASCII(09),
                          relat.sedcidnom clipped,    ASCII(09),
                          relat.ufdcod,               ASCII(09),
                          relat.cidnom    clipped,    ASCII(09),
                          relat.brrnom    clipped,    ASCII(09),
                          relat.nomgrr    clipped,    ASCII(09),
                          relat.sedufdcodpst,         ASCII(09),
                          relat.sedcidnompst clipped, ASCII(09),
                          relat.socvclcod    clipped, ASCII(09),
                          relat.atdvclsgl    clipped, ASCII(09),
                          relat.vcllicnum,            ASCII(09),
                          relat.cpodes       clipped, ASCII(09),
                          m_data             using "yyyy-mm-dd", ASCII(09);

                end if

                if  relat.hint = 24 then
                    print relat.botao
                else
                    print relat.botao, ASCII(09);
                end if
            end for

 end report   
 
#---------------------#
 report rep_bdbsr107b()
#---------------------#

     define l_erro smallint
     define l_dominio char(20)     
     
     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    03

     format

        first page header

            print "UF SEDE",            ASCII(09),
                  "CIDADE SEDE",        ASCII(09),
                  "UF",                 ASCII(09),
                  "CIDADE",             ASCII(09),
                  "BAIRRO",             ASCII(09),
                  "PRESTADOR",          ASCII(09),
                  "UF SEDE PREST.",     ASCII(09),
                  "CIDADE SEDE PREST.", ASCII(09),
                  "VEICULO",            ASCII(09),
                  "SIGLA",              ASCII(09),
                  "PLACA",              ASCII(09),
                  "TIPO VEICULO",       ASCII(09),
                  "DATA",               ASCII(09),
                  "0h",                 ASCII(09),
                  "1h",                 ASCII(09),
                  "2h",                 ASCII(09),
                  "3h",                 ASCII(09),
                  "4h",                 ASCII(09),
                  "5h",                 ASCII(09),
                  "6h",                 ASCII(09),
                  "7h",                 ASCII(09),
                  "8h",                 ASCII(09),
                  "9h",                 ASCII(09),
                  "10h",                ASCII(09),
                  "11h",                ASCII(09),
                  "12h",                ASCII(09),
                  "13h",                ASCII(09),
                  "14h",                ASCII(09),
                  "15h",                ASCII(09),
                  "16h",                ASCII(09),
                  "17h",                ASCII(09),
                  "18h",                ASCII(09),
                  "19h",                ASCII(09),
                  "20h",                ASCII(09),
                  "21h",                ASCII(09),
                  "22h",                ASCII(09),
                  "23h",                ASCII(09)

        on every row

            for relat.hint = 1 to 24

                if  relat.hint <> 24 then
                    let relat.hchr = relat.hint using "&&", ":00:00"
                    let relat.hora = relat.hchr
                    let relat.hora = relat.hora - 1 units second
                else
                    let relat.hchr = "00:00:00"
                    let relat.hora = "23:59:59"
                end if

                let relat.botao = ""
                
                whenever error continue
                open cq03 using relat.mdtcod,
                                m_data,
                                relat.hora,
                                m_data,
                                relat.seqmin,
                                relat.seqmax

                

                fetch cq03 into relat.mdtbotprgseq,
                                relat.ufdcod,
                                relat.cidnom,
                                relat.brrnom

                if  sqlca.sqlcode = 100 then
 
                    let relat.mdtbotprgseq = 0
                else   
                    if sqlca.sqlcode <> 0 then
                        let l_erro = sqlca.sqlcode
                        display "Erro sqlca.sqlcode = ", l_erro, " n cursor cq03"
                    end if  
                end if
                
                close cq03
                whenever error stop

                if  relat.mdtbotprgseq is null then
                    let relat.mdtbotprgseq = 0
                end if
                
                #Verifica se atividade faz parte do primeiro dominio para setar 0
                let l_dominio = 'atvvcltip'
                call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                     returning l_erro
                     
                if l_erro = 0 then
                   let relat.botao = "0"
                else
                   #Verifica se atividade faz parte do segundo dominio para setar 1
                   
                   if relat.mdtbotprgseq = 18 then
                      let relat.botao = "0"
                   else                   
                       let l_dominio = 'atvvcltipum'
                       call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                            returning l_erro
                         
                       if l_erro = 0 then
                          let relat.botao = "1"
                       else
                         #Verifica se atividade faz parte do terceiro dominio para setar 2
                         let l_dominio = 'atvvcltipdois'
                         call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                              returning l_erro
                         
                         if l_erro = 0 then
                            let relat.botao = "2"
                         else
                            #Verifica se atividade faz parte do quarto dominio para setar 3
                            let l_dominio = 'atvvcltiptres'
                            call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                                 returning l_erro
                       
                            if l_erro = 0 then
                               let relat.botao = "3"
                            else
                               let relat.botao = "0" #INDISPONIVEL - NÃO CADASTRADO EM UM DOMINIO               

                            end if
                         end if
                       end if  
                   end if        
                end if     
                           
                if  relat.hint = 1 then

                    let relat.sedufdcod = null
                    let relat.sedcidnom = null

                    # --> Busca o codigo da cidade
                    call cty10g00_obter_cidcod(relat.cidnom,
                                               relat.ufdcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o nome e o UF da cidade sede
                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnom,
                                   relat.sedufdcod

                    if  relat.sedcidnom is null then
                        let relat.sedufdcod = relat.ufdcod
                        let relat.sedcidnom = relat.cidnom
                    end if

                    # --> Busca a cidade sede prestador
                    call cty10g00_obter_cidcod(relat.cidpst,
                                               relat.ufpst)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnompst,
                                   relat.sedufdcodpst

                    if  relat.sedcidnompst is null then
                        let relat.sedufdcod = relat.ufpst
                        let relat.sedcidnom = relat.cidpst
                    end if

                    print relat.sedufdcod,            ASCII(09),
                          relat.sedcidnom clipped,    ASCII(09),
                          relat.ufdcod,               ASCII(09),
                          relat.cidnom    clipped,    ASCII(09),
                          relat.brrnom    clipped,    ASCII(09),
                          relat.nomgrr    clipped,    ASCII(09),
                          relat.sedufdcodpst,         ASCII(09),
                          relat.sedcidnompst clipped, ASCII(09),
                          relat.socvclcod    clipped, ASCII(09),
                          relat.atdvclsgl    clipped, ASCII(09),
                          relat.vcllicnum,            ASCII(09),
                          relat.cpodes       clipped, ASCII(09),
                          m_data             using "yyyy-mm-dd", ASCII(09);

                end if

                if  relat.hint = 24 then
                    print relat.botao
                else
                    print relat.botao, ASCII(09);
                end if
            end for

 end report


#---------------------#
 report rep_bdbsr107b_txt()
#---------------------#

     define l_erro smallint
     define l_dominio char(20)     
     
     output
        left   margin    00
        right  margin    00
        top    margin    00
        bottom margin    00
        page   length    01

     format


        on every row

            for relat.hint = 1 to 24

                if  relat.hint <> 24 then
                    let relat.hchr = relat.hint using "&&", ":00:00"
                    let relat.hora = relat.hchr
                    let relat.hora = relat.hora - 1 units second
                else
                    let relat.hchr = "00:00:00"
                    let relat.hora = "23:59:59"
                end if

                let relat.botao = ""
                
                whenever error continue
                open cq03 using relat.mdtcod,
                                m_data,
                                relat.hora,
                                m_data,
                                relat.seqmin,
                                relat.seqmax

                

                fetch cq03 into relat.mdtbotprgseq,
                                relat.ufdcod,
                                relat.cidnom,
                                relat.brrnom

                if  sqlca.sqlcode = 100 then

                    let relat.mdtbotprgseq = 0
                else   
                    if sqlca.sqlcode <> 0 then
                        let l_erro = sqlca.sqlcode
                        display "Erro sqlca.sqlcode = ", l_erro, " n cursor cq03"
                    end if  
                end if
                
                close cq03
                whenever error stop

                if  relat.mdtbotprgseq is null then
                    let relat.mdtbotprgseq = 0
                end if
                
                #Verifica se atividade faz parte do primeiro dominio para setar 0
                let l_dominio = 'atvvcltip'
                call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                     returning l_erro
                     
                if l_erro = 0 then
                   let relat.botao = "0"
                else
                   #Verifica se atividade faz parte do segundo dominio para setar 1
                   if relat.mdtbotprgseq = 18 then
                      let relat.botao = "0"
                   else   
                      let l_dominio = 'atvvcltipum'
                      call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                           returning l_erro
                        
                      if l_erro = 0 then
                         let relat.botao = "1"
                      else
                        #Verifica se atividade faz parte do terceiro dominio para setar 2
                        let l_dominio = 'atvvcltipdois'
                        call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                             returning l_erro
                        
                        if l_erro = 0 then
                           let relat.botao = "2"
                        else
                           #Verifica se atividade faz parte do quarto dominio para setar 3
                           let l_dominio = 'atvvcltiptres'
                           call bdbsr107_ver_tip_atv(l_dominio,relat.mdtbotprgseq)
                                returning l_erro
                      
                           if l_erro = 0 then
                              let relat.botao = "3"
                           else
                              let relat.botao = "0" #INDISPONIVEL - NÃO CADASTRADO EM UM DOMINIO               

                           end if
                        end if
                      end if  
                   end if        
                end if     
                           
                if  relat.hint = 1 then

                    let relat.sedufdcod = null
                    let relat.sedcidnom = null

                    # --> Busca o codigo da cidade
                    call cty10g00_obter_cidcod(relat.cidnom,
                                               relat.ufdcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o nome e o UF da cidade sede
                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnom,
                                   relat.sedufdcod

                    if  relat.sedcidnom is null then
                        let relat.sedufdcod = relat.ufdcod
                        let relat.sedcidnom = relat.cidnom
                    end if

                    # --> Busca a cidade sede prestador
                    call cty10g00_obter_cidcod(relat.cidpst,
                                               relat.ufpst)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    # --> Busca o codigo da cidade sede da cidade
                    call ctd01g00_obter_cidsedcod(1, relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.cidcod

                    call cty10g00_cidade_uf(relat.cidcod)
                         returning relat.resultado,
                                   relat.mensagem,
                                   relat.sedcidnompst,
                                   relat.sedufdcodpst

                    if  relat.sedcidnompst is null then
                        let relat.sedufdcod = relat.ufpst
                        let relat.sedcidnom = relat.cidpst
                    end if

                    print relat.sedufdcod,            ASCII(09),
                          relat.sedcidnom clipped,    ASCII(09),
                          relat.ufdcod,               ASCII(09),
                          relat.cidnom    clipped,    ASCII(09),
                          relat.brrnom    clipped,    ASCII(09),
                          relat.nomgrr    clipped,    ASCII(09),
                          relat.sedufdcodpst,         ASCII(09),
                          relat.sedcidnompst clipped, ASCII(09),
                          relat.socvclcod    clipped, ASCII(09),
                          relat.atdvclsgl    clipped, ASCII(09),
                          relat.vcllicnum,            ASCII(09),
                          relat.cpodes       clipped, ASCII(09),
                          m_data             using "yyyy-mm-dd", ASCII(09);

                end if

                if  relat.hint = 24 then
                    print relat.botao
                else
                    print relat.botao, ASCII(09);
                end if
            end for

 end report                                    