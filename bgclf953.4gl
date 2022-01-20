#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema.......:                                                              #
# Modulo........: bgclf953                                                     #
# Analista Resp.:                                                              #
# PSI...........:                                                              #
# Objetivo......:                                                              #
#..............................................................................#
# Desenvolvimento: Vicente Pereira4 23/01/2012                                 #
# Liberacao......:                                                             #
#..............................................................................#
#                                                                              #
#                   * * * Alteracoes * * *                                     #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 16/09/2014 Raji              Zeladoria  Ajuste na geracao de log             #
#------------------------------------------------------------------------------#
# 02/12/2015 Josiane Almeida   Rejeição   Ajuste para que não sejam enviadas   #
#                               BCP       tags vazias de endereco              #
#                                                                              #
#------------------------------------------------------------------------------#

globals "/fontes/controle_ct24h/ct24h_geral/sg_glob5.4gl"

define m_flag_item      smallint
define m_flag_doc       smallint
define m_flag_aux       smallint
define m_log            char(100)

#------------------------------------------------------------------------------#
function bgclf953_gera_xml_crm()
#------------------------------------------------------------------------------#

define l_xml         char(32766)
define l_xml_pes     char(32766)
define l_xml_doc     char(32766)
define l_xml_item    char(32766)


define l_filamq	      char(50)

define lr_ret       record
       errcod       integer
      ,errdes       char(50)
      ,mensagemRet   char(32766)
end record

define l_path       char(1000)
      ,l_i          smallint
      ,l_y          smallint
      ,l_x          integer
      ,l_z          integer
      ,l_m          integer
      ,l_data       datetime year to second
      ,l_data2      datetime year to day
      ,l_dt_aux     char(20)
      ,l_log        char(3000)
      ,l_log_aux    char(3000)

   initialize lr_ret.* to null
   
   let m_flag_item = 0
   let m_flag_doc  = 0
   let m_flag_aux  = 0
   let l_xml_pes  = "" clipped
   let l_xml_doc  = "" clipped
   let l_xml_item = "" clipped
   let l_filamq   = "BCPCRMSOA01D"
   
   let l_data = current
   
   
   let m_log = f_path('DBS','LOG')
   if m_log is null or
      m_log = ' '   then
      let m_log = '.'
   end if
 
   let m_log = m_log  clipped, '/bgclf953.log'
 
   call startlog(m_log)
   
   let l_xml = '<?xml version="1.0" encoding="UTF-8"?>'
   
   let l_xml = l_xml clipped 
   ,'<tns:adicionarPessoaProdutoRequest' 
   ,' xmlns:tns="http://www.portoseguro.com.br/pessoaProduto/integration/PessoaProdutoIntegrationServiceABCS/V1_1/"' 
   ,' xmlns:tns1="http://www.portoseguro.com.br/ebo/PessoaProdutoEBO/V1_1"' 
   ,' xmlns:tns2="http://www.portoseguro.com.br/ebo/Common/V1_0"' 
   ,' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
   
   let l_xml = l_xml clipped 
               ,'<tns1:codigoOrigemMovimento>'
               , gr_grupo_origem.mvtorgcod using '<<'
               ,'</tns1:codigoOrigemMovimento>'
   
   let l_xml = l_xml clipped 
               ,'<tns1:grupoXML>', gr_grupo_origem.xmlgrp clipped
               ,'</tns1:grupoXML>'
   
   
   let l_dt_aux = l_data
   let l_dt_aux = l_dt_aux[1,10],'T',l_dt_aux[12,19]
   let l_xml = l_xml clipped 
               ,'<tns1:dataHoraMoviento>',l_dt_aux clipped ,'</tns1:dataHoraMoviento>'
   
   let l_log = l_xml clipped
   
   let l_xml = l_xml clipped 
               ,'<tns1:pessoaProdutoEBO>'
               
   let l_xml = l_xml clipped 
               ,'<tns1:id>',gr_pessoa.id using '<<<<<<<<<<' ,'</tns1:id>'
   
   let gr_pessoa.nome = figrc005_conv_acento(gr_pessoa.nome,1,7)
   let l_xml = l_xml clipped 
               ,'<tns1:nome>', gr_pessoa.nome clipped ,'</tns1:nome>'
   
   let gr_pessoa.fonetica = figrc005_conv_acento(gr_pessoa.fonetica,1,7)
   let l_xml = l_xml clipped 
               ,'<tns1:fonetica>' ,gr_pessoa.fonetica clipped ,'</tns1:fonetica>'
   
   let gr_pessoa.primnome = figrc005_conv_acento(gr_pessoa.primnome,1,7)
   let l_xml = l_xml clipped 
               ,'<tns1:primeiroNome>' ,gr_pessoa.primnome clipped ,'</tns1:primeiroNome>'
   
   
   let l_xml = l_xml clipped 
               ,'<tns1:cpfCnpj>'
               
   let l_xml = l_xml clipped 
               ,'<tns2:numeroCnpjCpf>' ,gr_pessoa.cpfcnpjnum using '<<<<<<<<<<<<'
               ,'</tns2:numeroCnpjCpf>' 
   
   let l_xml = l_xml clipped 
               ,'<tns2:ordemCnpj>' ,gr_pessoa.cnpjordem using '<<<<'
               ,'</tns2:ordemCnpj>' 
   
   let l_xml = l_xml clipped 
   # Vinicius Morais - 29/05/12 - Correcao para mostrar digito 00 de cpf/cnpj
               ,'<tns2:digitoCnpjCpf>' ,gr_pessoa.cpfcnpjdig
               ,'</tns2:digitoCnpjCpf>' 
   
   let l_log = l_log clipped, " CPF: ", gr_pessoa.cpfcnpjnum using '<<<<<<<<<<<<'
                                      , " / ", gr_pessoa.cnpjordem using '<<<<'
                                      , " - ", gr_pessoa.cpfcnpjdig
   
   let l_xml = l_xml clipped ,'</tns1:cpfCnpj>'
   
   let gr_pessoa.rne = figrc005_conv_acento(gr_pessoa.rne,1,7) ,gr_pessoa.rne
   let l_xml = l_xml clipped 
               ,'<tns1:rne>', gr_pessoa.rne clipped ,'</tns1:rne>'
   
   let l_xml = l_xml clipped 
            ,'<tns1:cpfCnpjRel>' , gr_pessoa.tiprel using '<<<' , '</tns1:cpfCnpjRel>'
   
   
   let l_data = null
   if gr_pessoa.dtinirelac is not null and 
      gr_pessoa.dtinirelac <> " " then
      call bgclf953_formata_data(gr_pessoa.dtinirelac)
      returning l_data
      let l_dt_aux = l_data
      let l_dt_aux = l_dt_aux[1,10],'T',l_dt_aux[12,19] 
   else
      let l_dt_aux = l_data
   end if
   let l_xml = l_xml clipped 
            ,'<tns1:dtIniRelac>' , l_dt_aux , '</tns1:dtIniRelac>'
   
   let l_xml = l_xml clipped 
            ,'<tns1:titularDoc>' , gr_pessoa.titulardoc , '</tns1:titularDoc>'

   let l_xml = l_xml clipped 
             ,'<tns1:grauRelac>' , gr_pessoa.graurelac using '<<' , '</tns1:grauRelac>'

   let gr_pessoa.mae = figrc005_conv_acento(gr_pessoa.mae,1,7)
   let l_xml = l_xml clipped 
             ,'<tns1:mae>' , gr_pessoa.mae clipped, '</tns1:mae>'

   let gr_pessoa.pai = figrc005_conv_acento(gr_pessoa.pai,1,7)
   let l_xml = l_xml clipped 
             ,'<tns1:pai>' , gr_pessoa.pai clipped, '</tns1:pai>'
             
   let l_xml = l_xml clipped 
             ,'<tns1:papel>' , gr_pessoa.papel using '<<' , '</tns1:papel>'

   let l_xml = l_xml clipped 
             ,'<tns1:origem>' , gr_pessoa.origem using '<<' , '</tns1:origem>'

   let l_xml = l_xml clipped 
             ,'<tns1:tipoPessoa>' , gr_pessoa.tippess , '</tns1:tipoPessoa>'

   let l_xml = l_xml clipped 
             ,'<tns1:tipoPrestador>' , gr_pessoa.presttip using '<<' , '</tns1:tipoPrestador>'

   let l_xml = l_xml clipped 
             ,'<tns1:tipoEmpresa>' , gr_pessoa.empretip using '<<' , '</tns1:tipoEmpresa>'

   let l_xml = l_xml clipped 
             ,'<tns1:sexo>' , gr_pessoa.sexo , '</tns1:sexo>'

   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtabertura is not null and 
      gr_pessoa.dtabertura <> " " then
      call bgclf953_formata_data(gr_pessoa.dtabertura)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtAbertura>' , l_dt_aux , '</tns1:dtAbertura>'


   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtinicio is not null and 
      gr_pessoa.dtinicio <> " " then
      call bgclf953_formata_data(gr_pessoa.dtinicio)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtInicio>' , l_dt_aux , '</tns1:dtInicio>'


   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtfinal is not null and
      gr_pessoa.dtfinal <> " " then
      call bgclf953_formata_data(gr_pessoa.dtfinal)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtFinal>' , l_dt_aux , '</tns1:dtFinal>'


   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.nascimento is not null and 
      gr_pessoa.nascimento <> " " then
      call bgclf953_formata_data(gr_pessoa.nascimento)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:nascimento>' , l_dt_aux , '</tns1:nascimento>'

   let l_xml = l_xml clipped 
             ,'<tns1:estCivil>' , gr_pessoa.estcivil using '&<' , '</tns1:estCivil>'

   let l_xml = l_xml clipped 
             ,'<tns1:estrcargo>' , gr_pessoa.estrcargo using '<<<', '</tns1:estrcargo>'

   let l_xml = l_xml clipped 
            ,'<tns1:cargo>' , gr_pessoa.cargo clipped , '</tns1:cargo>'

   let l_xml = l_xml clipped 
             ,'<tns1:cbo>' , gr_pessoa.cbo using '<<<<<<' , '</tns1:cbo>'

   let l_xml = l_xml clipped 
             ,'<tns1:cnae>' , gr_pessoa.cnae clipped, '</tns1:cnae>'

   let l_xml = l_xml clipped 
             ,'<tns1:situacao>' , gr_pessoa.situacao , '</tns1:situacao>'

   let l_xml = l_xml clipped 
            ,'<tns1:codEmpresa>' , gr_pessoa.codemp using '<<<<' , '</tns1:codEmpresa>'

   let l_xml = l_xml clipped 
            ,'<tns1:fxRendaCod>' , gr_pessoa.fxrendacod , '</tns1:fxRendaCod>'

   
#############################
#PessoaEmail
   let l_i = 0
   for l_i = 1 to 5
      if gr_pes_emails[l_i].emailtip is null or
         gr_pes_emails[l_i].emailtip = 0  then
         exit for
      end if
      
      let l_xml = l_xml clipped 
                ,'<tns1:emailPessoa>'
      
      
      let l_xml = l_xml clipped 
                   ,'<tns1:emailTip>' , gr_pes_emails[l_i].emailtip using '<<<<<', '</tns1:emailTip>'
      
      let l_xml = l_xml clipped 
                   ,'<tns1:email>' , gr_pes_emails[l_i].email clipped, '</tns1:email>'
      
      let l_xml = l_xml clipped 
                   ,'<tns1:emailFlgOpt>' , gr_pes_emails[l_i].emailflgopt , '</tns1:emailFlgOpt>'
      
      
      let l_dt_aux = null
      let l_data2  = null
      if gr_pes_emails[l_i].emaildtflgopt is not null and 
         gr_pes_emails[l_i].emaildtflgopt <> " " then
         call bgclf953_formata_data(gr_pes_emails[l_i].emaildtflgopt)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      else
         let l_dt_aux = l_data2
      end if
      let l_xml = l_xml clipped 
                   ,'<tns1:emailDtFlgOpt>' , l_dt_aux , '</tns1:emailDtFlgOpt>'
      
      let l_xml = l_xml clipped 
                ,'</tns1:emailPessoa>'
                
   end for
   ###########################PessoaEmail


   ##########################Endereco Pessoa
   let l_i = 0
   for l_i = 1 to 5

      #if gr_pes_logradouros[l_i].logradtip is null or
      #   gr_pes_logradouros[l_i].logradtip = 0  then
      #   exit for
      #end if
      
      if gr_pes_logradouros[l_i].lograd is null then
         exit for      
      end if
      
      let l_xml = l_xml clipped 
                ,'<tns1:enderecoPessoa>'
      
      ####################################enderecoCompleto
      let l_xml = l_xml clipped 
                   ,'<tns1:enderecoCompleto>'
   
      let l_xml = l_xml clipped 
                ,'<tns2:tipoLogradouro>' ,gr_pes_logradouros[l_i].logradtip clipped, '</tns2:tipoLogradouro>'

   
      let gr_pes_logradouros[l_i].lograd = figrc005_conv_acento(gr_pes_logradouros[l_i].lograd,1,7)
      let l_xml = l_xml clipped 
                ,'<tns2:logradouro>' , gr_pes_logradouros[l_i].lograd clipped, '</tns2:logradouro>'

      let l_xml = l_xml clipped 
                ,'<tns2:numeroLogradouro>' , gr_pes_logradouros[l_i].logradnum clipped, '</tns2:numeroLogradouro>'

      let gr_pes_logradouros[l_i].logradcompl = figrc005_conv_acento(gr_pes_logradouros[l_i].logradcompl,1,7)
      let l_xml = l_xml clipped 
               ,'<tns2:complemento>', gr_pes_logradouros[l_i].logradcompl clipped,'</tns2:complemento>'
   
      let l_xml = l_xml clipped 
                ,'<tns2:cep>' , gr_pes_logradouros[l_i].cep using '<<<<<' , '</tns2:cep>'

      let l_xml = l_xml clipped 
                ,'<tns2:complementoCep>' , gr_pes_logradouros[l_i].cepcompl, '</tns2:complementoCep>'

   
      let gr_pes_logradouros[l_i].bairro = figrc005_conv_acento(gr_pes_logradouros[l_i].bairro,1,7)
      let l_xml = l_xml clipped 
                ,'<tns2:bairro>' , gr_pes_logradouros[l_i].bairro clipped, '</tns2:bairro>'

   
      let gr_pes_logradouros[l_i].cidade = figrc005_conv_acento(gr_pes_logradouros[l_i].cidade,1,7)
      let l_xml = l_xml clipped 
                ,'<tns2:cidade>', gr_pes_logradouros[l_i].cidade clipped, '</tns2:cidade>'

      let l_xml = l_xml clipped 
                ,'<tns2:uf>' , gr_pes_logradouros[l_i].uf clipped, '</tns2:uf>'

      let l_xml = l_xml clipped ,'</tns1:enderecoCompleto>'
      ####################################enderecoCompleto
      
      
      let l_xml = l_xml clipped 
                ,'<tns1:siglPais>' , gr_pes_logradouros[l_i].siglpais clipped, '</tns1:siglPais>'
                
      let l_xml = l_xml clipped 
                ,'<tns1:finalidLogr>' ,gr_pes_logradouros[l_i].finalidlogr using '<<', '</tns1:finalidLogr>'
      
      let l_xml = l_xml clipped 
                ,'<tns1:latitude>' ,gr_pes_logradouros[l_i].latitude using '<<<<<<', '</tns1:latitude>'

      let l_xml = l_xml clipped 
                ,'<tns1:longitude>' ,gr_pes_logradouros[l_i].longitude using '<<<<<<', '</tns1:longitude>'

      let l_xml = l_xml clipped 
                ,'<tns1:enderFlgOpt>' , gr_pes_logradouros[l_i].enderflgopt , '</tns1:enderFlgOpt>'

      let l_dt_aux = null
      let l_data2  = null
      if gr_pes_logradouros[l_i].enderdtflgopt is not null and 
         gr_pes_logradouros[l_i].enderdtflgopt <> " " then
         call bgclf953_formata_data(gr_pes_logradouros[l_i].enderdtflgopt)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      else
         let l_dt_aux = l_data2
      end if
      let l_xml = l_xml clipped 
                ,'<tns1:enderDtFlgOpt>' , l_dt_aux , '</tns1:enderDtFlgOpt>'
      
      let l_xml = l_xml clipped ,'</tns1:enderecoPessoa>'
   end for
   ##########################Endereco Pessoa
 
   ##########################Contato Pessoa  
   let l_i = 0
   for l_i = 1 to 5

      if gr_pes_contatos[l_i].fonetip is null or 
         gr_pes_contatos[l_i].fonetip = 0 then
            exit for
      end if
      
      let l_xml = l_xml clipped ,'<tns1:contatoPessoa>' 
       
      let l_xml = l_xml clipped 
                   ,'<tns1:foneTip>' ,gr_pes_contatos[l_i].fonetip using '<<<<<' , '</tns1:foneTip>'
   
      let l_xml = l_xml clipped 
                   ,'<tns1:foneDDI>' ,gr_pes_contatos[l_i].foneddi using '<<<<<', '</tns1:foneDDI>'
   
      let l_xml = l_xml clipped 
                   ,'<tns1:foneDDD>' ,gr_pes_contatos[l_i].foneddd using '<<<<<', '</tns1:foneDDD>'
   
      let l_xml = l_xml clipped 
                   ,'<tns1:foneNum>' ,gr_pes_contatos[l_i].fonenum using '<<<<<<<<', '</tns1:foneNum>'
   
      let l_xml = l_xml clipped 
                   ,'<tns1:foneFlgOpt>' ,gr_pes_contatos[l_i].foneflgopt , '</tns1:foneFlgOpt>'
   
      
      let l_dt_aux = null
      let l_data   = null
      if gr_pes_contatos[l_i].fonedtflgopt is not null and 
         gr_pes_contatos[l_i].fonedtflgopt <> " " then
         call bgclf953_formata_data(gr_pes_contatos[l_i].fonedtflgopt)
            returning l_data
         let l_dt_aux = l_data
         let l_dt_aux = l_dt_aux[1,10],'T',l_dt_aux[12,19]
      else
         let l_dt_aux = l_data
      end if
      let l_xml = l_xml clipped 
                   ,'<tns1:foneDtFlgOpt>' ,l_dt_aux , '</tns1:foneDtFlgOpt>'
   
      let l_xml = l_xml clipped 
                   ,'<tns1:tpComunic>' ,gr_pes_contatos[l_i].tpcomunic using '<<', '</tns1:tpComunic>'
   
      let l_xml = l_xml clipped 
                   ,'<tns1:twitter>' ,gr_pes_contatos[l_i].twitter clipped, '</tns1:twitter>'
   
      let l_xml = l_xml clipped  , '</tns1:contatoPessoa>'   
   end for
   ##########################Contato Pessoa  
   
   let l_xml = l_xml clipped 
            ,'<tns1:pessMatr>' , gr_pessoa.pessmatr clipped, '</tns1:pessMatr>'

   let l_xml = l_xml clipped 
            ,'<tns1:codPrestOrigem>' , gr_pessoa.codprestorigem using '<<<<<<<<', '</tns1:codPrestOrigem>'

   let l_xml = l_xml clipped 
            ,'<tns1:susepPrinc>' , gr_pessoa.susepprinc clipped, '</tns1:susepPrinc>'

   let l_xml = l_xml clipped ,'<tns1:deficFlag>' 
      let l_xml = l_xml clipped 
            ,'<tns2:flagOpcao>' , gr_pessoa.deficflag ,'</tns2:flagOpcao>'
   let l_xml = l_xml clipped ,'</tns1:deficFlag>'
            
   let l_xml = l_xml clipped 
            ,'<tns1:deficTip>' , gr_pessoa.defictip , '</tns1:deficTip>'

   let l_xml = l_xml clipped 
            ,'<tns1:flagPep>' , gr_pessoa.flagpep , '</tns1:flagPep>'

   let l_xml = l_xml clipped 
             ,'<tns1:cargoPep>' , gr_pessoa.cargopep using '<<<<<<', '</tns1:cargoPep>'

   let l_xml = l_xml clipped 
             ,'<tns1:cpfNumPep>' , gr_pessoa.cpfnumpep using '<<<<<<<<<<<<', '</tns1:cpfNumPep>'

   let l_xml = l_xml clipped 
             ,'<tns1:cpfOrdemPep>' , gr_pessoa.cpfordpep using '<<<<', '</tns1:cpfOrdemPep>'

   let l_xml = l_xml clipped 
             ,'<tns1:cpfDigPep>' , gr_pessoa.cpfdigpep using '<<', '</tns1:cpfDigPep>'

   let l_xml = l_xml clipped 
             ,'<tns1:relacTipPep>' , gr_pessoa.relactippep using '<<<', '</tns1:relacTipPep>'

   let l_xml = l_xml clipped 
             ,'<tns1:faturamentoPJ>' , gr_pessoa.faturampj using '<<', '</tns1:faturamentoPJ>'

   let l_xml = l_xml clipped 
             ,'<tns1:patrimonioLiquidoPJ>' , gr_pessoa.patrlqpj using '<<', '</tns1:patrimonioLiquidoPJ>'

   let l_xml = l_xml clipped ,'<tns1:flgEstrang>' 
      let l_xml = l_xml clipped 
            ,'<tns2:flagOpcao>', gr_pessoa.flgestrang ,'</tns2:flagOpcao>'
   let l_xml = l_xml clipped ,'</tns1:flgEstrang>'

   let l_xml = l_xml clipped 
             ,'<tns1:tipClassif>' , gr_pessoa.tipclassif , '</tns1:tipClassif>'

   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtclassif is not null and 
      gr_pessoa.dtclassif <> " " then
      call bgclf953_formata_data(gr_pessoa.dtclassif)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtClassif>' , l_dt_aux , '</tns1:dtClassif>'
   
   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtinclusao is not null and 
      gr_pessoa.dtinclusao <> " " then
      call bgclf953_formata_data(gr_pessoa.dtinclusao)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtInclusao>' , l_dt_aux , '</tns1:dtInclusao>'

   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtalteracao is not null and 
      gr_pessoa.dtalteracao <> " " then
      call bgclf953_formata_data(gr_pessoa.dtalteracao)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtAlteracao>' , l_dt_aux , '</tns1:dtAlteracao>'

   let l_xml = l_xml clipped 
             ,'<tns1:grphHold>' , gr_pessoa.grphhold using '<<<<<<<<<<', '</tns1:grphHold>'

   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtgrphhold is not null and 
      gr_pessoa.dtgrphhold <> " " then
      call bgclf953_formata_data(gr_pessoa.dtgrphhold)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtgrphHold>' , l_dt_aux , '</tns1:dtgrphHold>'
   
   let l_xml = l_xml clipped 
             ,'<tns1:flgportal>' 
      let l_xml = l_xml clipped 
            ,'<tns2:flagOpcao>', gr_pessoa.flgportal ,'</tns2:flagOpcao>'
   let l_xml = l_xml clipped 
            ,'</tns1:flgportal>'

   let l_dt_aux = null
   let l_data2  = null
   if gr_pessoa.dtflgportal is not null and 
      gr_pessoa.dtflgportal <> " " then
      call bgclf953_formata_data(gr_pessoa.dtflgportal)
         returning l_data2
      let l_dt_aux = l_data2
      let l_dt_aux = l_dt_aux[1,10]
   else
      let l_dt_aux = l_data2
   end if
   let l_xml = l_xml clipped 
             ,'<tns1:dtFlgPortal>' , l_dt_aux , '</tns1:dtFlgPortal>'

   let l_xml = l_xml clipped 
             ,'<tns1:vincPrestCNPJ>' , gr_pessoa.vincprestcnpj using '<<<<<<<<<<<<', '</tns1:vincPrestCNPJ>'

   let l_xml = l_xml clipped 
             ,'<tns1:vincPrestOrdem>' , gr_pessoa.vincprestordem using '<<<<', '</tns1:vincPrestOrdem>'

   let l_xml = l_xml clipped 
             ,'<tns1:vincPrestDig>' , gr_pessoa.vincprestdig using '<<', '</tns1:vincPrestDig>'
 
   
   let l_log = l_log clipped, " CNPJ: ", gr_pessoa.vincprestcnpj using '<<<<<<<<<<<<'
                                      , " / ", gr_pessoa.vincprestordem using '<<<<'
                                      , " - ", gr_pessoa.vincprestdig
   
   let l_log_aux = l_log
   
   let l_xml = l_xml clipped 
             ,'<tns1:bucflag>' , gr_pessoa.bucflag , '</tns1:bucflag>'


   let l_xml_pes = l_xml

   #############################Documento
   let l_i = 0
   for l_i = 1 to 5
   
      if gr_documentos[l_i].empcod is null or 
         gr_documentos[l_i].empcod = "" then
         if l_i = 1 then
            #Error log
         end if
         exit for
      end if
      
      let l_xml_doc = l_xml_pes clipped ,'<tns1:documento>'
      
      let m_flag_doc = 1 
      ##Dados do Documento
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:empCod>' , gr_documentos[l_i].empcod  using '<<<<' , '</tns1:empCod>'
   
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:status>' , gr_documentos[l_i].status using '<<<<<', '</tns1:status>'
   
      
      let l_dt_aux = null
      let l_data2  = null
      if gr_documentos[l_i].dtatustt is not null and 
         gr_documentos[l_i].dtatustt <> " " then
         call bgclf953_formata_data(gr_documentos[l_i].dtatustt)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      end if
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:dtAtuStatus>' ,l_dt_aux  , '</tns1:dtAtuStatus>'
   
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:cnpjNumColet>' , gr_documentos[l_i].cnpjnumcolet using '<<<<<<<<<<<<'
                , '</tns1:cnpjNumColet>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:cnpjOrdColet>' , gr_documentos[l_i].cnpjordcolet using '<<<<'
                , '</tns1:cnpjOrdColet>'
                
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:cnpjDigColet>' , gr_documentos[l_i].cnpjdigcolet using '<<'
                , '</tns1:cnpjDigColet>'
      
      let l_xml_doc = l_xml_doc clipped 
             ,'<tns1:papel>' , gr_documentos[l_i].papel using '<<' , '</tns1:papel>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:cpfNumVinc>' , gr_documentos[l_i].cpfnumvinc using '<<<<<<<<<<<<'
                , '</tns1:cpfNumVinc>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:cpfDigVinc>' , gr_documentos[l_i].cpfdigvinc using '<<'
                , '</tns1:cpfDigVinc>'
      
      
      
      let l_x = 0
      for l_x = 1 to 50
         if gr_doc_prod[l_x].doccod is null then
            exit for
         else
            if gr_doc_prod[l_x].doccod = l_i then
               let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:prodCod>' 
                         , gr_doc_prod[l_x].prodcod using '<<<<'
                         , '</tns1:prodCod>'
               
               let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:chave>' ,gr_doc_prod[l_x].chave clipped
                         ,'</tns1:chave>'
               
               let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:contratoorigem>' 
                         , gr_doc_prod[l_x].contratoorigem clipped
                         , '</tns1:contratoorigem>'
            end if
         end if
      end for 
      
      
      
      ############################################## EndrecoDocumento
      let l_x = 0
      for l_x = 1 to 50
         if gr_logradouros[l_x].doccod is null then
            exit for
         end if
         if gr_logradouros[l_x].doccod = l_i then
            let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:enderecoDocumento>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:enderecoCompleto>'
                   
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:tipoLogradouro>' ,gr_logradouros[l_x].logradtip clipped, '</tns2:tipoLogradouro>'
               
               let gr_logradouros[l_x].lograd = figrc005_conv_acento(gr_logradouros[l_x].lograd,1,7)
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:logradouro>' , gr_logradouros[l_x].lograd clipped, '</tns2:logradouro>'
            
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:numeroLogradouro>' ,gr_logradouros[l_x].logradnum clipped, '</tns2:numeroLogradouro>'
               
               let gr_logradouros[l_x].logradcomplnum = figrc005_conv_acento(gr_logradouros[l_x].logradcomplnum,1,7)
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:complemento>' , gr_logradouros[l_x].logradcomplnum clipped, '</tns2:complemento>'
               
               let gr_logradouros[l_x].logradbrr = figrc005_conv_acento(gr_logradouros[l_x].logradbrr,1,7)
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:bairro>' , gr_logradouros[l_x].logradbrr clipped, '</tns2:bairro>'
            
               let gr_logradouros[l_x].logradcid = figrc005_conv_acento(gr_logradouros[l_x].logradcid,1,7)
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:cidade>' , gr_logradouros[l_x].logradcid clipped, '</tns2:cidade>'
            
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:uf>' , gr_logradouros[l_x].lograduf , '</tns2:uf>'
            
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:cep>' , gr_logradouros[l_x].logradcep using '<<<<<', '</tns2:cep>'
            
               let l_xml_doc = l_xml_doc clipped 
                      ,'<tns2:complementoCep>' , gr_logradouros[l_x].logradcmpcep using '<<<', '</tns2:complementoCep>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'</tns1:enderecoCompleto>'
            
            ###############
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:siglPais>' , gr_logradouros[l_x].siglpais clipped, '</tns1:siglPais>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:finalidLogr>' , gr_logradouros[l_x].finalidlogr using '<<', '</tns1:finalidLogr>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:latitude>' , gr_logradouros[l_x].latitude , '</tns1:latitude>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:longitude>' , gr_logradouros[l_x].longitude , '</tns1:longitude>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:enderFlgOpt>' , gr_logradouros[l_x].enderflgopt , '</tns1:enderFlgOpt>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_logradouros[l_x].enderdtflgopt is not null and 
               gr_logradouros[l_x].enderdtflgopt <> " " then
               call bgclf953_formata_data(gr_logradouros[l_x].enderdtflgopt)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:enderDtFlgOpt>' , l_dt_aux , '</tns1:enderDtFlgOpt>'
         
            let l_xml_doc = l_xml_doc clipped ,'</tns1:enderecoDocumento>'
         end if
      end for ##l_x
      ########################################### EndrecoDocumento
      
      #################################### ContatoDocumento
      let l_y = 0
      for l_y = 1 to 50
      
         if gr_doc_contatos[l_y].doccod is null then
            exit for
         end if
         if gr_doc_contatos[l_y].doccod = l_i then
            let l_xml_doc = l_xml_doc clipped ,'<tns1:contatoDocumento>'
            
            let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:foneTip>' , gr_doc_contatos[l_y].fonetip , '</tns1:foneTip>'
            
            let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:foneDDI>' , gr_doc_contatos[l_y].foneddi using '<<<<<' 
                         ,'</tns1:foneDDI>'
            
            let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:foneDDD>' , gr_doc_contatos[l_y].foneddd using '<<<<<' 
                         ,'</tns1:foneDDD>'
            
            let l_xml_doc = l_xml_doc clipped 
                         ,'<tns1:foneNum>' , gr_doc_contatos[l_y].fonenum using '<<<<<<<<' 
                         ,'</tns1:foneNum>'
            
            let l_xml_doc = l_xml_doc clipped ,'</tns1:contatoDocumento>'
         end if   
      end for ##l_y
      #################################### ContatoDocumento
      
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:foneFlgOpt>' , gr_documentos[l_i].foneflgopt 
                ,'</tns1:foneFlgOpt>'
         
      let l_dt_aux = null
      let l_data   = null
      if gr_documentos[l_i].fonedtflgopt is not null and 
         gr_documentos[l_i].fonedtflgopt <> " " then
         call bgclf953_formata_data(gr_documentos[l_i].fonedtflgopt)
            returning l_data
         let l_dt_aux = l_data
         let l_dt_aux = l_dt_aux[1,10],'T',l_dt_aux[12,19]   
      end if
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:foneDtFlgOpt>' , l_dt_aux , '</tns1:foneDtFlgOpt>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:susep>' , gr_documentos[l_i].susep , '</tns1:susep>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:copartSusep>' , gr_documentos[l_i].copartsusep
                ,'</tns1:copartSusep>'
      
      let l_dt_aux = null
      let l_data2  = null
      if gr_documentos[l_i].inivig is not null and 
         gr_documentos[l_i].inivig <> " " then
         call bgclf953_formata_data(gr_documentos[l_i].inivig)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      end if
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:iniVig>' , l_dt_aux , '</tns1:iniVig>'
      
      let l_dt_aux = null
      let l_data2  = null
      if gr_documentos[l_i].fnlvig is not null and 
         gr_documentos[l_i].fnlvig <> " " then
         call bgclf953_formata_data(gr_documentos[l_i].fnlvig)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      end if
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:fnlVig>' , l_dt_aux , '</tns1:fnlVig>'
      
      let l_dt_aux = null
      let l_data2  = null
      if gr_documentos[l_i].dtemiss is not null and 
         gr_documentos[l_i].dtemiss <> " " then
         call bgclf953_formata_data(gr_documentos[l_i].dtemiss)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      end if
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:dtEmiss>' , l_dt_aux , '</tns1:dtEmiss>'
      
      #################################### EmailDocumento
      let l_z = 0
      for l_z = 1 to 50
         if gr_doc_emails[l_z].doccod is null then
            exit for
         end if
         if gr_doc_emails[l_z].doccod = l_i then
            let l_xml_doc = l_xml_doc clipped ,'<tns1:emailDocumento>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:emailTip>' , gr_doc_emails[l_z].emailtip using '<<<<<' , '</tns1:emailTip>'
            
            let l_xml_doc = l_xml_doc clipped 
                   ,'<tns1:email>'
                   ,gr_doc_emails[l_z].email  clipped , '</tns1:email>'
            
            let l_xml_doc = l_xml_doc clipped ,'</tns1:emailDocumento>'
         end if
      end for ##l_z
      #################################### EmailDocumento
      
      let l_xml_doc = l_xml_doc clipped 
             ,'<tns1:emailFlgOpt>' , gr_documentos[l_i].emailflgopt , '</tns1:emailFlgOpt>'
      
      let l_dt_aux = null
      let l_data2  = null
      if gr_documentos[l_i].emaildtflgopt is not null and 
         gr_documentos[l_i].emaildtflgopt <> " " then
         call bgclf953_formata_data(gr_documentos[l_i].emaildtflgopt)
            returning l_data2
         let l_dt_aux = l_data2
         let l_dt_aux = l_dt_aux[1,10]
      end if
      let l_xml_doc = l_xml_doc clipped 
             ,'<tns1:emailDtFlgOpt>' , l_dt_aux , '</tns1:emailDtFlgOpt>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:origemPrp>' , gr_documentos[l_i].origemprp using '<<' , '</tns1:origemPrp>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:numPrp>' , gr_documentos[l_i].numprp using '<<<<<<<<' , '</tns1:numPrp>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:segCod>' , gr_documentos[l_i].segcod using '<<<<<<<<<<<<<<<<', '</tns1:segCod>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:canalVend>' , gr_documentos[l_i].canalvend using '<<' , '</tns1:canalVend>'
      
      let l_xml_doc = l_xml_doc clipped 
                ,'<tns1:bucflag>' , gr_documentos[l_i].bucflag , '</tns1:bucflag>'
      
      #let l_xml_doc = l_xml_doc clipped ,'<tns1:item>'
      
      
      ############################################## Item 
      let l_m = 0
      for l_m = 1 to 100
         let l_xml_item = l_xml_doc clipped 
                
         if gr_item[l_m].doccod is null then
            exit for
         end if
         
         if gr_item[l_m].doccod = l_i then
            let m_flag_item = 1
            
            let l_xml_item = l_xml_item clipped ,'<tns1:item>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:numero>' , gr_item[l_m].numero using '<<<<<<<<<<<<' , '</tns1:numero>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:status>' , gr_item[l_m].status using '<<<<<', '</tns1:status>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:alterTip>' , gr_item[l_m].altertip using '<<', '</tns1:alterTip>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:alterNum>' , gr_item[l_m].alternum using '<<<<<<<<<', '</tns1:alterNum>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_item[l_m].dtatustt is not null and 
               gr_item[l_m].dtatustt <> " " then
               call bgclf953_formata_data(gr_item[l_m].dtatustt)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:dtAtuStatus>' , l_dt_aux , '</tns1:dtAtuStatus>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:vlrRecebto>' , gr_item[l_m].vlrrecebto , '</tns1:vlrRecebto>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:tipVlrRecebto>' , gr_item[l_m].tipvlrrecebto , '</tns1:tipVlrRecebto>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_item[l_m].inivig is not null and 
               gr_item[l_m].inivig <> " " then
               call bgclf953_formata_data(gr_item[l_m].inivig)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:iniVig>' , l_dt_aux , '</tns1:iniVig>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_item[l_m].fnlvig is not null and 
               gr_item[l_m].fnlvig <> " " then
               call bgclf953_formata_data(gr_item[l_m].fnlvig)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:fnlVig>' , l_dt_aux ,'</tns1:fnlVig>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_item[l_m].dtemiss is not null and 
               gr_item[l_m].dtemiss <> " " then
               call bgclf953_formata_data(gr_item[l_m].dtemiss)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:dtEmiss>' , l_dt_aux , '</tns1:dtEmiss>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:formaPagto>' , gr_item[l_m].formapagto using '<<', '</tns1:formaPagto>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:vlrContratado>' , gr_item[l_m].vlrcontratado , '</tns1:vlrContratado>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:vlrTotalContratado>' , gr_item[l_m].vlrttcontratado , '</tns1:vlrTotalContratado>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:origemPrp>' , gr_item[l_m].origemprp using '<<', '</tns1:origemPrp>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:numPrp>' , gr_item[l_m].numprp using '<<<<<<<<', '</tns1:numPrp>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:ordemRS>' , gr_item[l_m].ordemrs using '<<', '</tns1:ordemRS>'
                   
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:numRS>' , gr_item[l_m].numrs using '<<<<<<<<<', '</tns1:numRS>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_item[l_m].dtavisosinistro is not null and 
               gr_item[l_m].dtavisosinistro <> " " then
               call bgclf953_formata_data(gr_item[l_m].dtavisosinistro)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:dtAvisoSinistro>' , l_dt_aux , '</tns1:dtAvisoSinistro>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:edsTip>' , gr_item[l_m].edstip , '</tns1:edsTip>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:sinistrTip>' , gr_item[l_m].sinistrtip using '<<', '</tns1:sinistrTip>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:numSinistro>' , gr_item[l_m].sinistrnum using '<<<<<<<<<<<<<<<<', '</tns1:numSinistro>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:placa>' ,gr_item[l_m].placa , '</tns1:placa>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:chassi>' ,gr_item[l_m].chassi , '</tns1:chassi>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:anoFabr>' , gr_item[l_m].anofabr using '<<<<', '</tns1:anoFabr>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:anoModel>' , gr_item[l_m].anomodel using '<<<<', '</tns1:anoModel>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:marca>' ,gr_item[l_m].marca clipped, '</tns1:marca>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:tipo>' ,gr_item[l_m].tipo clipped, '</tns1:tipo>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:modelo>' ,gr_item[l_m].modelo clipped, '</tns1:modelo>'
            
            
            ################################## Endereco item
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:enderecoItem>' clipped
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:enderecoCompleto>' clipped
            
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:tipoLogradouro>' ,gr_item[l_m].logradtip clipped, '</tns2:tipoLogradouro>'
               
               let gr_item[l_m].lograd = figrc005_conv_acento(gr_item[l_m].lograd,1,7)
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:logradouro>' ,gr_item[l_m].lograd clipped, '</tns2:logradouro>'
               
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:numeroLogradouro>' , gr_item[l_m].logradnum clipped, '</tns2:numeroLogradouro>'
               
               let gr_item[l_m].logradcomplnum = figrc005_conv_acento(gr_item[l_m].logradcomplnum,1,7)
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:complemento>' ,gr_item[l_m].logradcomplnum clipped, '</tns2:complemento>'
               
               let gr_item[l_m].logradbrr = figrc005_conv_acento(gr_item[l_m].logradbrr,1,7)
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:bairro>' ,gr_item[l_m].logradbrr clipped, '</tns2:bairro>'
               
               let gr_item[l_m].logradcid = figrc005_conv_acento(gr_item[l_m].logradcid,1,7)
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:cidade>' ,gr_item[l_m].logradcid clipped, '</tns2:cidade>'
               
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:uf>' , gr_item[l_m].lograduf , '</tns2:uf>'
               
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:cep>' , gr_item[l_m].logradcep using '<<<<<' , '</tns2:cep>'
               
               let l_xml_item = l_xml_item clipped 
                      ,'<tns2:complementoCep>' , gr_item[l_m].logradcmpcep using '<<<<<', '</tns2:complementoCep>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'</tns1:enderecoCompleto>' clipped
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:siglPais>' , gr_item[l_m].siglpais , '</tns1:siglPais>'
            
            let gr_item[l_m].finalidlogr = figrc005_conv_acento(gr_item[l_m].finalidlogr,1,7)
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:finalidLogr>' ,gr_item[l_m].finalidlogr using '<<<<<', '</tns1:finalidLogr>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:latitude>' ,gr_item[l_m].latitude , '</tns1:latitude>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:longitude>' ,gr_item[l_m].longitude , '</tns1:longitude>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:enderFlgOpt>' , gr_item[l_m].enderflgopt , '</tns1:enderFlgOpt>'
            
            let l_dt_aux = null
            let l_data2  = null
            if gr_item[l_m].enderdtflgopt is not null and 
               gr_item[l_m].enderdtflgopt <> " " then
               call bgclf953_formata_data(gr_item[l_m].enderdtflgopt)
                  returning l_data2
               let l_dt_aux = l_data2
               let l_dt_aux = l_dt_aux[1,10]
            end if
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:enderDtFlgOpt>' , l_dt_aux , '</tns1:enderDtFlgOpt>'
            
            
            let l_xml_item = l_xml_item clipped 
                   ,'</tns1:enderecoItem>' clipped
            ################################## Endereco item
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:contrchave>' , gr_item[l_m].contrchave clipped, '</tns1:contrchave>'
            
            let l_xml_item = l_xml_item clipped 
                   ,'<tns1:tipocontrchave>' , gr_item[l_m].tipocontrchave using '<<', '</tns1:tipocontrchave>'
         
            let l_xml_item = l_xml_item clipped ,'</tns1:item>' clipped
         end if
         
         if m_flag_item = 1 then
            let m_flag_aux = 1
            call bgclf953_rodape_xml(l_xml_item)
               returning l_xml_item
               
            display l_xml_item clipped
            call figrc006_enviar_pseudo_mq(l_filamq
                                          ,l_xml_item
                                          ,online())
              returning lr_ret.errcod
                        ,lr_ret.errdes
                        ,lr_ret.mensagemRet
               
               let l_log = l_log_aux
               let l_log = l_log clipped, "Retorno FilaMQ: ",lr_ret.errcod
               call errorlog(l_log clipped)
            if lr_ret.errcod <> 0 then 
               let l_log = lr_ret.errdes
               call errorlog(l_log clipped)
               
               let l_log = lr_ret.mensagemRet
               call errorlog(l_log clipped)
               return lr_ret.*
            else                                
               display "XML enviado com sucesso"
               return lr_ret.*
            end if                              
            
            let m_flag_item = 0
         end if
      end for  ##l_m - Item
      #let l_xml_doc = l_xml_doc clipped ,'</tns1:item>' clipped
      ############################################## Item 
      
      let l_xml_doc = l_xml_doc clipped ,'</tns1:documento>'
   end for # l_i - Documento
   #############################Documento
   
   if m_flag_doc < 1 then
      let l_xml_pes = l_xml_pes clipped 
                  ,'</tns1:pessoaProdutoEBO>'
   else
      let l_xml_pes = l_xml_doc clipped 
                  ,'</tns1:pessoaProdutoEBO>'
   end if
   ####################################### PessoaProdutoEBO
               
   let l_xml = l_xml_pes clipped 
               ,'</tns:adicionarPessoaProdutoRequest>'
   ###################################### AdicionarPessoaProdutoRequest
   
   if m_flag_aux < 1 then
      display l_xml clipped
      call figrc006_enviar_pseudo_mq(l_filamq
                                    ,l_xml
                                    ,online())
         returning lr_ret.errcod
                  ,lr_ret.errdes
                  ,lr_ret.mensagemRet
      
      if lr_ret.errcod <> 0 then
         display lr_ret.errdes
         let l_log = lr_ret.errdes
         call errorlog(l_log clipped)
               
         let l_log = lr_ret.mensagemRet
         call errorlog(l_log clipped)
         return lr_ret.*
      else
         display "XML enviado com sucesso"
         return lr_ret.*
      end if
      
   end if
   
#------------------------------------------------------------------------------#
end function #bgclf953_gera_xml_crm
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
function bgclf953_rodape_xml(l_xml)
#------------------------------------------------------------------------------#
   define l_xml         char(32766)
   
   #let l_xml = l_xml clipped ,'</tns1:item>'
   let l_xml = l_xml clipped ,'</tns1:documento>'
   let l_xml = l_xml clipped ,'</tns1:pessoaProdutoEBO>'
   let l_xml = l_xml clipped ,'</tns:adicionarPessoaProdutoRequest>'
      
   return l_xml
#------------------------------------------------------------------------------#
end function
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
function bgclf953_formata_data(l_param)
#------------------------------------------------------------------------------#
   define l_param     date
   
   define lr_ret       datetime year to second
   define l_aux       char(19)
   define l_mes       datetime month to month
   define l_ano       datetime year to year
   define l_dia       datetime day to day
   
   let l_aux = ""
   let l_ano = l_param
   let l_mes = l_param
   let l_dia = l_param
   let l_aux = l_ano ,'-', l_mes ,'-', l_dia, ' 00:00:00'
   let lr_ret = l_aux
   
   return lr_ret
#------------------------------------------------------------------------------#
end function
#------------------------------------------------------------------------------#
