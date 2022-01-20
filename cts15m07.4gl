###############################################################################
# Nome do Modulo: CTS15M07                                           Marcelo  #
#                                                                    Gilberto #
# Informa dados para locacao de carro extra por motivo de sinistro   Mai/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 29/01/2001  PSI 115592   Wagner       Acesso funcao ossaa009 p/verificar a  #
#                                       real posicao do segurado caso mtv = 3 #
#-----------------------------------------------------------------------------#
# 21/11/2001  PSI 136425   Wagner       Modificacoes para capturar sinistro   #
#                                       acesso a funcao ossaa009_vistoria.    #
#-----------------------------------------------------------------------------#
# 09/09/2002  Correio      Wagner       Modificacoes para capturar sinistro   #
#                                       acesso a funcao ossaa009_vistoria.    #
#-----------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 #
#-----------------------------------------------------------------------------#
# 03/03/2004  OSF 32875    Helio        Informa dados para locacao carro extra#
#-----------------------------------------------------------------------------#
# 02/04/2004  CT 176540    Teresinha S. Inibir tratamentos do ws.dtentvcl     #
###############################################################################
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 20/12/2004  Marcio - Meta    PSI187887  Incluir novo parametro na chamada #
#                                         da funcao ossaa009_vistorias().   #
#---------------------------------------------------------------------------#
# 16/12/2006  Ruiz             psi205206  Incluir motivo de locacao 3 para  #
#                                         Azul.                             #
#---------------------------------------------------------------------------#


globals  "/homedsa/projetos/geral/globals/glct.4gl"
#--------------------------------------------------------------
 function cts15m07(d_cts15m07)
#--------------------------------------------------------------

 define d_cts15m07     record
    succod             like datrservapol.succod,       #OSF 32875
    aplnumdig          like datrservapol.aplnumdig,
    itmnumdig          like datrservapol.itmnumdig,
    succod_ter         like datrservapol.succod,
    aplnumdig_ter      like datrservapol.aplnumdig,
    itmnumdig_ter      like datrservapol.itmnumdig,
    vclchsinc_ter      like abbmveic.vclchsinc,
    vclchsfnl_ter      like abbmveic.vclchsfnl,
    vcllicnum_ter      like abbmveic.vcllicnum,        #OSF 32875
    avioccdat          like datmavisrent.avioccdat,
    ofnnom             like datmavisrent.ofnnom,
    dddcod             like datmavisrent.dddcod,
    telnum             like datmavisrent.telnum,
    avialgmtv          like datmavisrent.avialgmtv,
    clscod             like abbmclaus.clscod
 end record

 define ws             record
    dtentvcl           date,                   # DATA ENTREGA VEICULO
    mens               char (75),
    sinnum             like ssamsin.sinnum,
    flgerr             smallint,
    flgopc             char(1),
    confirma           char(1)
 end record

 define l_sinvstano    like ssamsin.sinvstano,
        l_sinvstnum    like ssamsin.sinvstnum

	initialize  ws.*  to  null

 let int_flag =  false
 initialize ws.* to null

 open window cts15m07 at 12,19 with form "cts15m07"
                      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 input by name d_cts15m07.avioccdat,
               d_cts15m07.ofnnom,
               d_cts15m07.dddcod,
               d_cts15m07.telnum  without defaults

    before field avioccdat
       if (d_cts15m07.avialgmtv = 3  or
	   d_cts15m07.avialgmtv = 6) and
           g_documento.ciaempcod <> 35 then   #OSF 32875

          call ossaa009_vistorias(d_cts15m07.succod   ,
                                  d_cts15m07.aplnumdig,
                                  d_cts15m07.itmnumdig,
				  d_cts15m07.succod_ter,     #OSF 32875
				  d_cts15m07.aplnumdig_ter,
				  d_cts15m07.itmnumdig_ter,
				  d_cts15m07.vclchsinc_ter,
				  d_cts15m07.vclchsfnl_ter,
				  d_cts15m07.vcllicnum_ter,
				  d_cts15m07.avialgmtv,      #OSF 32875
				  'M')
                        returning d_cts15m07.avioccdat,
                                  ws.mens             ,
                                  d_cts15m07.telnum   ,
                                  ws.dtentvcl         , # DATA ENTREGA VEICULO
                                  ws.flgerr           ,
                                  l_sinvstano         ,
                                  l_sinvstnum
          if ws.flgerr =  0     then
             let d_cts15m07.ofnnom  =  ws.mens clipped
             display by name d_cts15m07.avioccdat
             display by name d_cts15m07.ofnnom
             display by name d_cts15m07.telnum
             #--------------------------------
             # Verifica ultima opcao
             #--------------------------------
	     if d_cts15m07.avialgmtv  <> 6  and
                g_documento.ciaempcod <> 35 then  #OSF 32875
                call ossaa009_ultima_opc( d_cts15m07.succod,
                                          d_cts15m07.aplnumdig,
                                          d_cts15m07.itmnumdig,
                                          g_documento.prporg,
                                          g_documento.prpnumdig,
                                          d_cts15m07.avioccdat )
                                returning ws.flgopc
                if ws.flgopc is not null     and
                   ws.flgopc  = "F"          then


                   call cts08g01("Q",
                                 "S",
                                 "SEGURADO JA OPTOU POR DESCONTO NA ",
                                 "PARTICIPACAO EM CASO DE SINISTRO, ",
                                 "DESEJA TROCAR BENEFICIO ? ",
                                 "")
                         returning ws.confirma

                   if ws.confirma = "N" then
                      initialize d_cts15m07.avioccdat, d_cts15m07.ofnnom,
                                 d_cts15m07.dddcod   , d_cts15m07.telnum to null
                      exit input
                   end if
                end if
	     end if
             prompt " (enter) para continuar " for ws.confirma
             exit input
          else
             if ws.mens is null then
                initialize d_cts15m07.avioccdat, d_cts15m07.ofnnom,
                           d_cts15m07.dddcod   , d_cts15m07.telnum to null
                exit input
             else
                error "ATENCAO : ", ws.mens clipped
                initialize d_cts15m07.ofnnom to null
		                if d_cts15m07.avialgmtv = 3 and
                       g_documento.ciaempcod <> 35  then #OSF 32875
		                               #if  d_cts15m07.clscod[1,2] = '26' then
                                   #    call cts08g01("A","S"," ",
	                                 #                  "NAO SERA' POSSIVEL PROSSEGUIR A RESERVA",
		                	             #                  "POR MOTIVO 3-BENEFICIO OFICINA, DESEJA ",
		                	             #                  "REVERTER PARA O MOTIVO 1-SINISTRO. ?")
                                   #         returning ws.confirma
                                   #else
                                   #   if  d_cts15m07.clscod = '033' or
                                   #       d_cts15m07.clscod = '33R' then
                                          call cts08g01("A","S"," ",
	                                                      "NAO SERA POSSIVEL PROSSEGUIR A RESERVA",
		                	                                  "POR MOTIVO 3-BENEFICIO OFICINA, DESEJA ",
		                	                                  "REVERTER PARA O MOTIVO 5-PARTICULAR?")
                                               returning ws.confirma
                                   #   else
		                               #       call cts08g01("A","N"," ",
		                		           #                     "NAO SERA' POSSIVEL PROSSEGUIR A RESERVA",
		                		           #                     "POR MOTIVO 3-BENEFICIO OFICINA " ,
		                		           #                     "SEM CLAUSULA 26/80  " )
                                   #           returning ws.confirma
                                   #   end if
                                   #end if
		                else
                                   if g_documento.ciaempcod <> 35 then
                                      call cts08g01("A","S"," ",
                                                 "NAO SERA POSSIVEL PROSSEGUIR A RESERVA",
                                                 "POR MOTIVO 6-TERC.SEG PORTO, DESEJA ",
                                                 "REVERTER PARA O MOTIVO 5-PARTICULAR?")
                                       returning ws.confirma
                                   else
                                      let ws.confirma = "N"
                   end if
		end if
                    if ws.confirma = "N" then
                       initialize d_cts15m07.avioccdat, d_cts15m07.ofnnom,
                               d_cts15m07.dddcod   , d_cts15m07.telnum to null
                       exit input
                    else
		                   if d_cts15m07.avialgmtv = 3 then  #OSF 32875
		                      # if  d_cts15m07.clscod[1,2]= '26' then
                          #     let d_cts15m07.avialgmtv = 1
                          # else
			                        let d_cts15m07.avialgmtv = 5
                          # end if
		                   else
		                      let d_cts15m07.avialgmtv = 5
		                   end if
                    end if
             end if
          end if

       end if
       display by name d_cts15m07.avioccdat attribute (reverse)

    after  field avioccdat
       display by name d_cts15m07.avioccdat

       if d_cts15m07.avioccdat is null  then
          error " Informe a DATA DE OCORRENCIA do sinistro!"
          next field avioccdat
       end if

       if d_cts15m07.avioccdat > today  then
          error " Data de ocorrencia nao pode ser maior que hoje!"
          next field avioccdat
       end if

       if d_cts15m07.avioccdat < today - 365 units day  then
          error " Data de ocorrencia nao pode ser anterior a um ano!"
          next field avioccdat
       end if

       declare c_cts15m07_001 cursor for
        select sinnum
          from ssamsin
         where succod    = d_cts15m07.succod     and
               ramcod    in (31,531)              and
               aplnumdig = d_cts15m07.aplnumdig  and
               itmnumdig = d_cts15m07.itmnumdig  and
               orrdat    = d_cts15m07.avioccdat

       open  c_cts15m07_001
       fetch c_cts15m07_001 into ws.sinnum
       if sqlca.sqlcode = notfound  then
          error " Sinistro nao encontrado nesta data! Confirme com o solicitante."
       end if
       close c_cts15m07_001

    before field ofnnom
       display by name d_cts15m07.ofnnom  attribute (reverse)

    after  field ofnnom
       display by name d_cts15m07.ofnnom

    before field dddcod
       display by name d_cts15m07.dddcod  attribute (reverse)

    after  field dddcod
       display by name d_cts15m07.dddcod

    before field telnum
       display by name d_cts15m07.telnum  attribute (reverse)

    after  field telnum
       display by name d_cts15m07.telnum

       if (d_cts15m07.dddcod is not null and d_cts15m07.telnum is     null) or
          (d_cts15m07.dddcod is     null and d_cts15m07.telnum is not null) then
          error " Telefone da oficina incompleto! Informe novamente."
          next field dddcod
       end if

       if d_cts15m07.telnum <= 99999  then
          error " Telefone invalido! Informe novamente."
          next field telnum
       end if

    on key (interrupt)
       initialize d_cts15m07.* to null
       exit input
 end input

close window cts15m07
let int_flag = false
return d_cts15m07.avioccdat, d_cts15m07.ofnnom,
       d_cts15m07.dddcod   , d_cts15m07.telnum,
       d_cts15m07.avialgmtv, ws.dtentvcl

end function  #  cts15m07
