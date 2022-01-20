############################################################################
# Nome do Modulo: CTB11M09                                        Gilberto #
#                                                                 Marcelo  #
# Batimento do lote de pagamentos (O.P. - Porto Socorro)          Dez/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 03/01/2000  PSI 9637-7   Wagner       Permitir a inclusao do nr.NF qdo.  #
#                                       OP for automatica.                 #
#                                                                          #
# 5/11/2003   PSI 177881   Aguinaldo (FSW) Enviar Fax com dados da OP a    #
#                                          prestadores nao adsivados       #
############################################################################
#..........................................................................#
#                           * * *  ALTERACOES  * * *                       #
# PSI       Autor            PSI         Alteracao                         #
# --------  ---------------  ----------  ----------------------------------#
# 06/12/04  Mariana,Meta     188220       Transmitir OP ao prestador       #
#                                        (incluir mais 1 parametro na chama#
#                                         da da funcao ctb11m17)           #
# 08/06/2009  Fabio Costa  PSI198404  Nao digitar numero NF nos itens em   #
#                                     ctb11m16, conferir PIS/INS. MUNICIPAL#
# 11/02/2010  Fabio Costa  PSI198404  Validacao dados tributarios OP Azul  #
#--------------------------------------------------------------------------#
database porto

#--------------------------------------------------------------------
function ctb11m09(param)
#--------------------------------------------------------------------
  define param       record
     socopgnum       like dbsmopgitm.socopgnum,
     modulo          char(08),     ## ctb04m00/01,ctb04m06,ctb11m00/01,ctb11m06
     pstcoddig       like dpaksocor.pstcoddig ,
     pestip          like dpaksocor.pestip    ,
     segnumdig       like dbsmopg.segnumdig
  end record

  define d_ctb11m09  record
     msgcab          char(39),
     socfattotvlr    like dbsmopg.socfattotvlr,
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgdifvlr    like dbsmopgitm.socopgitmvlr,
     socfatitmqtd    like dbsmopg.socfatitmqtd,
     socopgitmqtd    like dbsmopg.socfatitmqtd,
     socopgdifqtd    like dbsmopg.socfatitmqtd
  end record

  define ws          record
     socopgitmvlr    like dbsmopgitm.socopgitmvlr,
     socopgitmcst    like dbsmopgcst.socopgitmcst,
     socopgtotcst    like dbsmopgcst.socopgitmcst,
     socopgsitcod    like dbsmopg.socopgsitcod,
     socopgorgcod    like dbsmopg.socopgorgcod,
     quant           integer,
     pergunta        char(01),
     ciaempcod       like datmservico.ciaempcod,
     atdprscod			 like datmservico.atdprscod,
     socfatpgtdat		 like dbsmopg.socfatpgtdat
  end record

  define l_env      record
         qldgracod     like dpaksocor.qldgracod
        ,pstcoddig     like dbsmopg.pstcoddig
        ,socopgsitcod  like dbsmopg.socopgsitcod
  end record

  define l_ret record
         errcod  smallint,
         errmsg  char(80),
         pestip  like dpaksocor.pestip
  end record

  #CT: 644854
  define l_flagnfsnum smallint
  define l_atdsrvnum like dbsmopgitm.atdsrvnum
  ###

  define l_err integer, l_msg char(80), l_tipo char(02)

  initialize d_ctb11m09.*  to null
  initialize ws.*          to null
  initialize l_ret.* to null

  select socfatitmqtd, socfattotvlr, socopgorgcod
    into d_ctb11m09.socfatitmqtd,
         d_ctb11m09.socfattotvlr,
         ws.socopgorgcod
    from dbsmopg
   where socopgnum = param.socopgnum

  if sqlca.sqlcode <> 0   then
     error "Erro (",sqlca.sqlcode,") na leitura da O.P. AVISE A INFORMATICA!"
     sleep 4
     return
  end if

  if ws.socopgorgcod is null then
     let  ws.socopgorgcod  = 1    #--> OP DIGITADA
  end if

  # SOMA O VALOR DOS ITENS (SERVICOS)
  #----------------------------------
  declare c_ctb11m09itm  cursor for
    select i.socopgitmvlr, s.ciaempcod, s.atdprscod, o.socfatpgtdat
      from dbsmopgitm i, datmservico s, dbsmopg o
     where i.atdsrvnum = s.atdsrvnum
       and i.atdsrvano = s.atdsrvano
       and i.socopgnum = param.socopgnum
       and i.socopgnum = o.socopgnum
    order by socopgitmnum desc

  let d_ctb11m09.socopgitmvlr = 0.00
  let d_ctb11m09.socopgitmqtd = 0.00

  foreach c_ctb11m09itm into ws.socopgitmvlr, ws.ciaempcod, ws.atdprscod, ws.socfatpgtdat
     let d_ctb11m09.socopgitmqtd = d_ctb11m09.socopgitmqtd + 1
     let d_ctb11m09.socopgitmvlr = d_ctb11m09.socopgitmvlr + ws.socopgitmvlr
  end foreach

  # SOMA O VALOR DOS CUSTOS DOS ITENS
  #----------------------------------
  declare c_ctb11m09cst  cursor for
    select socopgitmcst
      from dbsmopgcst, dbsmopgitm
     where dbsmopgitm.socopgnum    =  param.socopgnum
       and dbsmopgitm.socopgnum    =  dbsmopgcst.socopgnum
       and dbsmopgitm.socopgitmnum =  dbsmopgcst.socopgitmnum

  let ws.socopgtotcst = 0.00

  foreach c_ctb11m09cst into ws.socopgitmcst
     let ws.socopgtotcst = ws.socopgtotcst + ws.socopgitmcst
  end foreach

  let d_ctb11m09.socopgitmvlr = d_ctb11m09.socopgitmvlr + ws.socopgtotcst


  # NAO EXISTEM ITENS DIGITADOS
  #----------------------------
  if d_ctb11m09.socopgitmqtd  =  0    then
     error " Batimento nao pode ser realizado! O.P. sem itens digitados!"
     return
  end if

  if param.modulo = "ctb04m06" or param.modulo = "ctb11m06" then

     # MOSTRA TELA E VERIFICA SE EXISTE DIVERGENCIA
     #---------------------------------------------
     open window w_ctb11m09 at 09,02 with form "ctb11m09"
          attribute(form line first)

     display by name d_ctb11m09.socfattotvlr
     display by name d_ctb11m09.socfatitmqtd
     display by name d_ctb11m09.socopgitmvlr
     display by name d_ctb11m09.socopgitmqtd

     let d_ctb11m09.msgcab =    "   O.P. COM QUANTIDADES/VALORES  OK   "

  end if

  if d_ctb11m09.socfattotvlr <> d_ctb11m09.socopgitmvlr    or
     d_ctb11m09.socfatitmqtd <> d_ctb11m09.socopgitmqtd    then
     let d_ctb11m09.msgcab = " *** ATENCAO, O.P. COM DIVERGENCIA ***"

     let d_ctb11m09.socopgdifvlr =
                    d_ctb11m09.socopgitmvlr - d_ctb11m09.socfattotvlr
     let d_ctb11m09.socopgdifqtd =
                    d_ctb11m09.socopgitmqtd - d_ctb11m09.socfatitmqtd

     if param.modulo = "ctb04m06" or param.modulo = "ctb11m06" then
        if d_ctb11m09.socfattotvlr <> d_ctb11m09.socopgitmvlr    then
           display by name d_ctb11m09.socopgdifvlr   attribute(reverse)
        end if
        if d_ctb11m09.socfatitmqtd <> d_ctb11m09.socopgitmqtd    then
           display by name d_ctb11m09.socopgdifqtd   attribute(reverse)
        end if
     end if
  end if

  if param.modulo = "ctb04m06" or param.modulo = "ctb11m06" then
     display by name d_ctb11m09.msgcab   attribute(reverse)
  end if

  # QUANDO FINAL DA DIGITACAO DA O.P., ATUALIZA SITUACAO
  #-----------------------------------------------------

  #CT: 644854
  initialize l_atdsrvnum to null
  initialize l_flagnfsnum to null
  call ctb11m09_verif_nfsnum(param.socopgnum)
       returning l_flagnfsnum, l_atdsrvnum

  if l_flagnfsnum = 0 then
      let ws.socopgsitcod = 6    #--> OK PARA EMISSAO

      if d_ctb11m09.socfattotvlr >= 50000 then
         if ws.ciaempcod = 1 or 
            ws.ciaempcod = 43 or
            ws.ciaempcod = 50 then
      	         call ctb02m09_gera_email_OP(param.socopgnum, d_ctb11m09.socfattotvlr,
      															         ws.atdprscod, ws.socfatpgtdat)
         end if																	
      end if

  else
      let ws.socopgsitcod = 9
  end if
  ###

  if d_ctb11m09.socfattotvlr <> d_ctb11m09.socopgitmvlr    then
     let ws.socopgsitcod = 4    #--> DIVERGENCIA DE VALOR
  end if

  if d_ctb11m09.socfatitmqtd <> d_ctb11m09.socopgitmqtd    then
     let ws.socopgsitcod = 3    #--> DIVERGENCIA DE QUANTIDADE
  end if

  # verifica cadastro para emissao da OP People, menos reembolso
  if param.segnumdig is null
     then

     # confirma pestip pois há evidência de favorecido de tipo diferente do prestador
     # exemplo: OP de empresa PJ com favorecido pessoa fisica
     call ctd20g04_dados_favop(2, param.socopgnum)
          returning l_ret.errcod, l_ret.errmsg, l_ret.pestip

     if l_ret.errcod is not null  and
        l_ret.errcod = 0          and
        l_ret.pestip is not null
        then
        let param.pestip = l_ret.pestip
     end if

     if param.pestip = 'J'
        then
        let l_tipo = 'IP'  # verifica inscr. municipal de prestador PJ
     else
        let l_tipo = 'PP'  # verifica num PIS de prestador PF
     end if

     call ctb00m06_confere_cadastro(l_tipo, 0, 0, param.pstcoddig)
          returning l_err, l_msg

     if l_err != 0
        then
        let l_msg = ' ', l_msg clipped, ', OP em status OK para batimento '
        let ws.socopgsitcod = 9    #--> OK PARA BATIMENTO
     end if

     error l_msg clipped
     sleep 1
  end if

  # validar informacoes tributarias para OP Azul Seguros antes de emitir
  initialize l_err, l_msg to null

  call ctb11m09_situacao(param.socopgnum, ws.socopgsitcod)

  if param.modulo = "ctb04m01" or param.modulo = "ctb11m01" then
     return
  end if

  ####PSI.: 177881   Aguinaldo   31/10/2003
  if ws.socopgsitcod = 6 then  # Ok para emissao
     whenever error continue
        select pstcoddig into l_env.pstcoddig
        from dbsmopg
        where socopgnum = param.socopgnum
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           error"Problemas no acesso a DBSMOPG *ctb11m09* .: ",sqlca.sqlcode
           return
        end if
     end if

     whenever error continue
       select qldgracod into l_env.qldgracod
          from dpaksocor
          where pstcoddig = l_env.pstcoddig
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode < 0 then
           error "Problemas no acesso a DPAKSOCOR *ctb11m09* .: ", sqlca.sqlcode
           return
        end if
     end if

     if l_env.qldgracod <> 1 then
        while true
             prompt "Deseja enviar os dados da OP ao prestador agora ? (S/N) "
                    for  char  ws.pergunta

             if ws.pergunta ='S' or ws.pergunta = 's' or
                ws.pergunta ='N' or ws.pergunta = 'n' then
                exit while
             end if
        end while

        if ws.pergunta ='S' or ws.pergunta = 's' then
           call ctb11m17(param.socopgnum,l_env.pstcoddig,'E','O')
        end if
     end if
  end if

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
           error " Existem itens sem numero de Documento Fiscal, verifique "
           sleep 2

           let ws.socopgsitcod = 9    #--> OK PARA BATIMENTO
           call ctb11m09_situacao(param.socopgnum, ws.socopgsitcod)

           # PSI 198404, NF digitada na capa da OP e nao nos itens
           # if ctb11m16(param.socopgnum) = "1" then
           #    let ws.socopgsitcod = 9    #--> OK PARA BATIMENTO
           #    call ctb11m09_situacao(param.socopgnum, ws.socopgsitcod)
           # end if
        end if



     end if
  end if

  if param.modulo = "ctb04m06" or param.modulo = "ctb11m06" then
    	close window w_ctb11m09
  end if

  close c_ctb11m09itm
  close c_ctb11m09cst
  let int_flag = false

end function    #--- ctb11m09

#----------------------------------------------------------
function ctb11m09_situacao(param2)
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
        update dbsmopg  set (socopgsitcod) =  (param2.socopgsitcod)
         where socopgnum  =  param2.socopgnum

        if sqlca.sqlcode <> 0   then
           error "Erro (",sqlca.sqlcode,") na gravacao da situacao da O.P.!"
           sleep 4
        end if
     else
        error " O.P. ja' cancelada!"
     end if
  commit work

end function  # ctb11m09_situacao

# CT: 644854
# Verifica se algum item da OP esta sem nota fiscal
#----------------------------------------------------------------
function ctb11m09_verif_nfsnum(l_param_socopgnum)
#----------------------------------------------------------------
  define l_flagnfsnum smallint
  define l_nfsnum like dbsmopgitm.nfsnum
  define l_atdsrvnum like dbsmopgitm.atdsrvnum
  define l_param_socopgnum like dbsmopgitm.socopgnum

  #CT: 644854
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
