############################################################################
# Nome do Modulo: CTB02M09                                        Wagner   #
#                                                                          #
# Batimento do lote de pagamentos (O.P. - Carro-Extra)            Nov/2000 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 18/07/06   Junior, Meta  AS112372      Migracao de versao do 4gl.        #
# 08/06/2009  Fabio Costa  PSI198404  Nao digitar numero NF nos itens em   #
#                                     ctb11m16, conferir PIS/INS. MUNICIPAL#
# 11/02/2010  Fabio Costa  PSI198404  Validacao dados tributarios OP Azul  #
#--------------------------------------------------------------------------#

database porto

#--------------------------------------------------------------------
function ctb02m09(param)
#--------------------------------------------------------------------
  define param record
         socopgnum  like dbsmopgitm.socopgnum ,
         lcvcod     like datklcvfav.lcvcod    ,
         aviestcod  like datklcvfav.aviestcod ,
         segnumdig  like dbsmopg.segnumdig
  end record

  define d_ctb02m09  record
     msgcab          char(39),
     socopgitmqtd    like dbsmopg.socfatitmqtd,
     socfatitmqtd    like dbsmopg.socfatitmqtd,
     socopgdifqtd    like dbsmopg.socfatitmqtd,
     socopgitmtot    like dbsmopgcst.socopgitmcst,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socfattotvlr    like dbsmopg.socfattotvlr,
     socopgdifvlr    like dbsmopgitm.socopgitmvlr
  end record

  define ws          record
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     socopgtotcst    like dbsmopgcst.socopgitmcst,
     socopgsitcod    like dbsmopg.socopgsitcod,
     socopgorgcod    like dbsmopg.socopgorgcod,
     quant           integer ,
     pergunta        char(01),
     ciaempcod       like datmservico.ciaempcod,
     atdprscod			 like datmservico.atdprscod,
     socfatpgtdat		 like dbsmopg.socfatpgtdat
  end record

  define l_err integer ,
         l_msg char(80),
         l_flagnfsnum smallint,
         l_atdsrvnum  like dbsmopgitm.atdsrvnum

  initialize d_ctb02m09.*  to null
  initialize ws.*          to null

  select socfatitmqtd, socfattotvlr
    into d_ctb02m09.socfatitmqtd,
         d_ctb02m09.socfattotvlr
    from dbsmopg
   where socopgnum = param.socopgnum

  if sqlca.sqlcode <> 0   then
     error "Erro (",sqlca.sqlcode,") na leitura da O.P. AVISE A INFORMATICA!"
     sleep 4
     return
  end if

  # SOMA O VALOR DOS ITENS (SERVICOS)
  #----------------------------------
  declare c_ctb02m09itm  cursor for
    select i.socopgitmvlr, s.ciaempcod, s.atdprscod, o.socfatpgtdat
      from dbsmopgitm i, datmservico s, dbsmopg o
     where i.atdsrvnum = s.atdsrvnum
       and i.atdsrvano = s.atdsrvano
       and i.socopgnum = param.socopgnum
       and i.socopgnum = o.socopgnum
    order by socopgitmnum desc

  let d_ctb02m09.socopgitmtot = 0.00
  let d_ctb02m09.socopgitmcst = 0.00
  let d_ctb02m09.socopgitmvlr = 0.00
  let d_ctb02m09.socopgitmqtd = 0.00

  foreach c_ctb02m09itm into ws.socopgitmvlr, ws.ciaempcod, ws.atdprscod, ws.socfatpgtdat
     let d_ctb02m09.socopgitmqtd = d_ctb02m09.socopgitmqtd + 1
     let d_ctb02m09.socopgitmvlr = d_ctb02m09.socopgitmvlr + ws.socopgitmvlr
  end foreach

  # SOMA O VALOR DOS CUSTOS DOS ITENS
  #----------------------------------
  declare c_ctb02m09cst  cursor for
    select socopgitmcst
      from dbsmopgcst, dbsmopgitm
     where dbsmopgitm.socopgnum    =  param.socopgnum
       and dbsmopgitm.socopgnum    =  dbsmopgcst.socopgnum
       and dbsmopgitm.socopgitmnum =  dbsmopgcst.socopgitmnum

  let ws.socopgitmcst = 0.00

  foreach c_ctb02m09cst into ws.socopgitmcst
     let d_ctb02m09.socopgitmcst = d_ctb02m09.socopgitmcst + ws.socopgitmcst
  end foreach

  let d_ctb02m09.socopgitmtot = d_ctb02m09.socopgitmvlr +
                               (d_ctb02m09.socopgitmcst * (-1))

  # NAO EXISTEM ITENS DIGITADOS
  #----------------------------
  if d_ctb02m09.socopgitmqtd  =  0    then
     error " Batimento nao pode ser realizado! O.P. sem itens digitados!"
     return
  end if

  # MOSTRA TELA E VERIFICA SE EXISTE DIVERGENCIA
  #---------------------------------------------
  open window w_ctb02m09 at 09,02 with form "ctb02m09"
       attribute(form line first)

  display by name d_ctb02m09.socopgitmqtd
  display by name d_ctb02m09.socopgitmtot
  display by name d_ctb02m09.socopgitmcst
  display by name d_ctb02m09.socopgitmvlr
  display by name d_ctb02m09.socfattotvlr
  display by name d_ctb02m09.socfatitmqtd

  let d_ctb02m09.msgcab =    "   O.P. COM QUANTIDADES/VALORES  OK   "

  if d_ctb02m09.socfattotvlr <> d_ctb02m09.socopgitmvlr    or
     d_ctb02m09.socfatitmqtd <> d_ctb02m09.socopgitmqtd    then
     let d_ctb02m09.msgcab = " *** ATENCAO, O.P. COM DIVERGENCIA ***"

     let d_ctb02m09.socopgdifvlr =
                    d_ctb02m09.socfattotvlr - d_ctb02m09.socopgitmvlr
     let d_ctb02m09.socopgdifqtd =
                    d_ctb02m09.socfatitmqtd - d_ctb02m09.socopgitmqtd

     if d_ctb02m09.socfattotvlr <> d_ctb02m09.socopgitmvlr    then
        display by name d_ctb02m09.socopgdifvlr   attribute(reverse)
     end if

     if d_ctb02m09.socfatitmqtd <> d_ctb02m09.socopgitmqtd    then
        display by name d_ctb02m09.socopgdifqtd   attribute(reverse)
     end if
  end if
  display by name d_ctb02m09.msgcab   attribute(reverse)

  # QUANDO FINAL DA DIGITACAO DA O.P., ATUALIZA SITUACAO
  #-----------------------------------------------------
  initialize l_atdsrvnum to null
  initialize l_flagnfsnum to null
  call ctb02m09_verif_nfsnum(param.socopgnum)
       returning l_flagnfsnum, l_atdsrvnum

  if l_flagnfsnum = 0
      then
      let ws.socopgsitcod = 6    #--> OK PARA EMISSAO

      if d_ctb02m09.socfattotvlr >= 50000 then
         if ws.ciaempcod = 1 or 
            ws.ciaempcod = 43 or
            ws.ciaempcod = 50 then
      				call ctb02m09_gera_email_OP(param.socopgnum, d_ctb02m09.socfattotvlr,
         																	ws.atdprscod, ws.socfatpgtdat)
         end if																	
      end if

  else
      let ws.socopgsitcod = 9
  end if

  if d_ctb02m09.socfattotvlr <> d_ctb02m09.socopgitmvlr    then
     let ws.socopgsitcod = 4    #--> DIVERGENCIA DE VALOR
  end if

  if d_ctb02m09.socfatitmqtd <> d_ctb02m09.socopgitmqtd    then
     let ws.socopgsitcod = 3    #--> DIVERGENCIA DE QUANTIDADE
  end if

  # verifica cadastro para emissao da OP People, menos reembolso
  if param.segnumdig is null
     then
     call ctb00m06_confere_cadastro('IF', param.lcvcod, param.aviestcod, 0)
          returning l_err, l_msg

     if l_err != 0
        then
        let l_msg = l_msg clipped, ', OP em status OK para batimento'
        let ws.socopgsitcod = 9    #--> OK PARA BATIMENTO
     end if

     error l_msg clipped
     sleep 1
  end if

  # validar informacoes tributarias para OP Azul Seguros antes de emitir
  initialize l_err, l_msg to null


  call ctb02m09_situacao(param.socopgnum, ws.socopgsitcod)

  prompt " <Enter> / <Control+C> Abandona "  for  char  ws.pergunta

  if ws.socopgorgcod     =  2   then    #--> OP Automatica
     if ws.socopgsitcod  =  6   then    #--> OK PARA EMISSAO
        select count(*)
          into ws.quant
          from dbsmopgitm
         where socopgnum  = param.socopgnum
           and nfsnum     is null

        if ws.quant is not null  and
           ws.quant > 0
           then
           error " Existem itens sem número de Documento Fiscal, verifique "
           sleep 2
           let ws.socopgsitcod = 9    #--> OK PARA BATIMENTO
           call ctb02m09_situacao(param.socopgnum, ws.socopgsitcod)

           # PSI 198404, NF digitada na capa da OP e nao nos itens
           # if ctb11m16(param.socopgnum) = "1" then
           #    let ws.socopgsitcod = 9    #--> OK PARA BATIMENTO
           #    call ctb02m09_situacao(param.socopgnum, ws.socopgsitcod)
           # end if
        end if



     end if
  end if

  close window w_ctb02m09
  close c_ctb02m09itm
  close c_ctb02m09cst
  let int_flag = false

end function    #--- ctb02m09

#----------------------------------------------------------
function ctb02m09_situacao(param2)
#----------------------------------------------------------

  define param2      record
     socopgnum       like dbsmopg.socopgnum,
     socopgsitcod    like dbsmopg.socopgsitcod
  end record

  begin work
     select socopgsitcod
       from dbsmopg
      where socopgnum    = param2.socopgnum
        and socopgsitcod = 8

     if sqlca.sqlcode = notfound  then
        update dbsmopg  set (socopgsitcod) = (param2.socopgsitcod)
         where socopgnum  =  param2.socopgnum

        if sqlca.sqlcode <> 0   then
           error "Erro (",sqlca.sqlcode,") na gravacao da situacao da O.P.!"
           sleep 4
        end if
     else
        error " O.P. ja' cancelada!"
     end if
  commit work

end function  # ctb02m09_situacao

# Verifica se algum item da OP esta sem nota fiscal
#----------------------------------------------------------------
function ctb02m09_verif_nfsnum(l_param_socopgnum)
#----------------------------------------------------------------
  define l_flagnfsnum smallint
  define l_nfsnum like dbsmopgitm.nfsnum
  define l_atdsrvnum like dbsmopgitm.atdsrvnum
  define l_param_socopgnum like dbsmopgitm.socopgnum

  declare c_verif_nfsnum cursor for
        select nfsnum, atdsrvnum
          from dbsmopgitm
         where socopgnum = l_param_socopgnum

  initialize l_nfsnum, l_atdsrvnum to null
  let l_flagnfsnum = 0

  foreach c_verif_nfsnum into l_nfsnum, l_atdsrvnum

      if l_nfsnum = 0 or
         l_nfsnum is null
         then
         let l_flagnfsnum = 1
         return l_flagnfsnum, l_atdsrvnum
      end if

  end foreach

  return l_flagnfsnum, l_atdsrvnum

end function


###-------------------------------------------####
function ctb02m09_gera_email_OP(lr_param)
###-------------------------------------------####


define lr_param record
			socopgnum			like dbsmopg.socopgnum,
			socfattotvlr	like dbsmopg.socfattotvlr,
			atdprscod			like datmservico.atdprscod,
			socfatpgtdat	like dbsmopg.socfatpgtdat
end record

define mensagem record
			assunto				char(100),
			emaildest			char(50),
			corpo					char(800)
end record

define l_retorno		smallint

# Atribuição das variáveis para composição do e-mail
let mensagem.emaildest = 'ctb02m09'
let mensagem.assunto = "Ordem de Pagamento superior a RS 50.000,00"
let mensagem.corpo = ASCII(13), ASCII(13),
							"Foi gerada uma Ordem de Pagamento com valor maior ou igual a RS 50,000.00.",
							ASCII(13), ASCII(13),
							"Ordem de pagamento numero...........: ",
							lr_param.socopgnum, ASCII(13),
							"Codigo do Prestador........................:  ",
							lr_param.atdprscod, ASCII(13),
							"Data de Pagamento.........................:     ",
							lr_param.socfatpgtdat, ASCII(13),
							"Valor da Ordem de Pagamento.........:     RS    ",
							lr_param.socfattotvlr using "###,###,##&.&&"



# Envia por e-mail informações referentes a Ordem de Pagamento
  call ctx22g00_mail_corpo(mensagem.emaildest, mensagem.assunto, mensagem.corpo)
       returning l_retorno

	if l_retorno = 0 then
		display "Mensagem enviada com sucesso!"
	else
		display "Erro no envio do e-mail!"
	end if


end function