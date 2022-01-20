################################################################################
# Nome do Modulo: CTS18M07                                            Marcelo  #
#                                                                     Gilberto #
# Informacoes para abertura de aviso de sinistro                      Ago/1997 #
#------------------------------------------------------------------------------#
#                       MANUTENCOES                                            #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                  #
#------------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a     #
#                                         global                               #
#------------------------------------------------------------------------------#



globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

define  m_dtresol86    date
#------------------------------------------------------------------------
 function cts18m07(d_cts18m07)
#------------------------------------------------------------------------

 define d_cts18m07    record
    sinocrdat         like ssamavs.sinocrdat  ,
    sinocrhor         like ssamavs.sinocrhor  ,
    ramcod            like ssamavs.ramcod     ,
    subcod            like ssamavs.subcod     ,
    sinvstnum         like ssamsin.sinvstnum  ,
    sinvstano         like ssamsin.sinvstano  ,
    prporgpcp         like apbmitem.prporgpcp ,
    prpnumpcp         like apbmitem.prpnumpcp ,
    prporgidv         like ssamavs.prporgidv  ,
    prpnumidv         like ssamavs.prpnumidv  ,
    vcllicnum         like ssamavs.vcllicnum  ,
    c24astcod         like datmligacao.c24astcod
 end record

 define ws            record
    segnumdig         like gsakseg.segnumdig    ,
    prpnom            like gsakseg.segnom       ,
    succod            like datrligapol.succod   ,
    aplnumdig         like datrligapol.aplnumdig,
    itmnumdig         like datrligapol.itmnumdig,
    subnom            char (20)
 end record

 define l_host        like ibpkdbspace.srvnom #Saymon ambnovo
 define l_sql         char(500) #Saymon ambnovo
	initialize  ws.*  to  null

 open window w_cts18m07 at 08,13 with form "cts18m07"
             attribute(form line first, border, comment line last - 1)

 message " (F17)Abandona"

 initialize ws.*        to null

 input by name d_cts18m07.sinocrdat ,
               d_cts18m07.sinocrhor ,
               d_cts18m07.ramcod    ,
               d_cts18m07.subcod    ,
               d_cts18m07.sinvstnum ,
               d_cts18m07.sinvstano ,
               d_cts18m07.prporgpcp ,
               d_cts18m07.prpnumpcp ,
               d_cts18m07.vcllicnum   without defaults

    before field sinocrdat
       display by name d_cts18m07.sinocrdat attribute (reverse)

    after  field sinocrdat
       display by name d_cts18m07.sinocrdat

       if d_cts18m07.sinocrdat is null  then
          error " Data de ocorrencia do sinistro deve ser informada!"
          next field sinocrdat
       end if

      if d_cts18m07.sinocrdat > today  then
         error " Data de ocorrencia do sinistro nao pode ser maior que hoje!"
         next field sinocrdat
      end if

      if d_cts18m07.sinocrdat < today - 365 units day  then
         error " Data de ocorrencia do sinistro nao pode ser anterior a um ano!"
         next field sinocrdat
      end if

    before field sinocrhor
       display by name d_cts18m07.sinocrhor attribute (reverse)

    after  field sinocrhor
       display by name d_cts18m07.sinocrhor

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts18m07.sinocrhor is null  then
             error " Hora de ocorrencia do sinistro deve ser informada!"
             next field sinocrhor
          end if
       end if

    before field ramcod
       let d_cts18m07.ramcod = g_documento.ramcod
       if d_cts18m07.c24astcod  = "N11" then
          if g_documento.ramcod = 31 then
             let d_cts18m07.ramcod = 53
          else
             let d_cts18m07.ramcod = 553
          end if
       end if
       display by name d_cts18m07.ramcod  attribute (reverse)
       next field subcod

    after  field ramcod
       display by name d_cts18m07.ramcod

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts18m07.ramcod is null  then
             error " Ramo do documento deve ser informado!"
             next field ramcod
          end if
       end if

       if d_cts18m07.ramcod <> 31  and
          d_cts18m07.ramcod <> 53  and
          d_cts18m07.ramcod <> 531  and
          d_cts18m07.ramcod <> 553  then
          error " Ramo deve ser (31/531)Automovel ou (53/553)RCF!"
          next field ramcod
       else
          if d_cts18m07.c24astcod = "N10"  and
             (d_cts18m07.ramcod    =  53     or
              d_cts18m07.ramcod    =  553)   then
             error " Aviso de sinistro para segurado deve ser do Ramo (31/531)Automovel!"
             next field ramcod
          else
             if d_cts18m07.c24astcod = "N11"  and
                (d_cts18m07.ramcod    =  31    or
                 d_cts18m07.ramcod    =  531)  then
                error " Aviso de sinistro para terceiro deve ser do Ramo (53/553)RCF!"
                next field ramcod
             end if
          end if
       end if

    before field subcod
       if d_cts18m07.ramcod = 31   or
          d_cts18m07.ramcod = 531  then
          let d_cts18m07.subcod = 0
          display by name d_cts18m07.subcod  attribute (reverse)
          next field sinvstnum
       else
          let d_cts18m07.subcod = 2  # judite 25/07
          display by name d_cts18m07.subcod  attribute (reverse)
       end if

    after  field subcod
       display by name d_cts18m07.subcod

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts18m07.subcod is null  then
             error " Sub-ramo deve ser informado!"
             next field subcod
          else
             if d_cts18m07.subcod = 2  then
                display "DANOS MATERIAIS" to subnom
             else
                if d_cts18m07.subcod = 4  then
                   display "DANOS PESSOAIS" to subnom
                else
                   error " Sub-ramo deve ser (02)Danos Materiais ou (04)Danos Pessoais!"
                   next field subcod
                end if
             end if
          end if
       end if

    before field sinvstnum
       display by name d_cts18m07.sinvstnum  attribute (reverse)

    after  field sinvstnum
       display by name d_cts18m07.sinvstnum

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          if d_cts18m07.ramcod = 31   or
             d_cts18m07.ramcod = 531  then
             next field ramcod
          else
             next field subcod
          end if
       else
          if d_cts18m07.sinvstnum is null  then
             initialize d_cts18m07.sinvstano to null
             display by name d_cts18m07.sinvstano
             next field prporgpcp
          end if
       end if

    before field sinvstano
       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          if d_cts18m07.sinvstano is null  then
             next field sinvstnum
          end if
       else
          display by name d_cts18m07.sinvstano  attribute (reverse)
       end if

    after  field sinvstano
       display by name d_cts18m07.sinvstano

       if d_cts18m07.sinvstnum is not null  and
          d_cts18m07.sinvstano is not null  then
          declare c_cts18m07_001 cursor for
             select succod, aplnumdig, itmnumdig
               from ssamsin
              where sinvstnum = d_cts18m07.sinvstnum  and
                    sinvstano = d_cts18m07.sinvstano

          open  c_cts18m07_001
          fetch c_cts18m07_001 into ws.succod, ws.aplnumdig, ws.itmnumdig
          if sqlca.sqlcode <> 0  then
             error " Vistoria nao encontrada!"
             next field sinvstnum
          else
             if g_documento.succod    is not null  and
                g_documento.aplnumdig is not null  and
                g_documento.itmnumdig is not null  then
                if ws.succod    <> g_documento.succod     or
                   ws.aplnumdig <> g_documento.aplnumdig  or
                   ws.itmnumdig <> g_documento.itmnumdig  then
                   error " Vistoria nao pertence `a apolice informada!"
                   next field sinvstnum
                end if
             end if
          end if
          close c_cts18m07_001
       end if

    before field prporgpcp
       if g_documento.succod    is not null  and
          g_documento.aplnumdig is not null  and
          g_documento.itmnumdig is not null  then
          exit input
       else
          display by name d_cts18m07.prporgpcp  attribute (reverse)
       end if

    after  field prporgpcp
       display by name d_cts18m07.prporgpcp

       if fgl_lastkey() <> fgl_keyval("up")    and
          fgl_lastkey() <> fgl_keyval("left")  then
          if d_cts18m07.prporgpcp is null  then
             next field vcllicnum
          end if
       end if

    before field prpnumpcp
       display by name d_cts18m07.prpnumpcp  attribute (reverse)

    after  field prpnumpcp
       display by name d_cts18m07.prporgpcp

       if d_cts18m07.prpnumpcp is null      and
          d_cts18m07.prporgpcp is not null  then
          error " Numero da proposta deve ser informado!"
          next field prpnumpcp
       end if

       if d_cts18m07.prporgpcp is not null  and
          d_cts18m07.prpnumpcp is not null  then
          call figrc072_setTratarIsolamento()        --> 223689
          call cts18m08 (d_cts18m07.prporgpcp, d_cts18m07.prpnumpcp)
               returning d_cts18m07.prporgidv, d_cts18m07.prpnumidv
          if g_isoAuto.sqlCodErr <> 0 then --> 223689
             error "Função cts18m08 indisponivel no momento ! Avise a Informatica !" sleep 2
             exit input
          end if    --> 223689
          call figrc072_initGlbIsolamento() --> 223689

          if d_cts18m07.prporgidv is null  or
             d_cts18m07.prpnumidv is null  then
             display by name d_cts18m07.prpnumpcp
             next field prporgpcp
          else
                #------------Saymon---------------------#
                # Carrega host do banco de dados        #
                #---------------------------------------#
                #ambnovo
                if d_cts18m07.prporgpcp = 15  then
                  let l_host = fun_dba_servidor("ORCAMAUTO")
                else
                   let l_host = fun_dba_servidor("EMISAUTO")
                end if

                --> 223689
                if figrc072_checkGlbIsolamento(sqlca.sqlcode,
                      "cts18m07",
                      "cts18m07",
                      ""        ,
                      "","","","","","")  then
                  exit input
                end if  --> 223689

                let l_sql = 'select segnumdig '
                           ,'  from porto@',l_host clipped,':apbmitem '
                           ,' where prporgpcp = ? '
                           ,'   and prpnumpcp = ? '
                           ,'   and prporgidv = ? '
                           ,'   and prpnumidv = ? '

             prepare p_cts18m07_01 from l_sql
             declare c_cts18m07_01 cursor with hold for p_cts18m07_01

             open c_cts18m07_01 using d_cts18m07.prporgpcp
                                     ,d_cts18m07.prpnumpcp
                                     ,d_cts18m07.prporgidv
                                     ,d_cts18m07.prpnumidv
             fetch c_cts18m07_01 into ws.segnumdig
             let ws.prpnom =  "*** NAO CADASTRADO! ***"

             select segnom
               into ws.prpnom
               from gsakseg
              where segnumdig = ws.segnumdig

             display by name ws.prpnom
             exit input
          end if
       end if

    before field vcllicnum
       display by name d_cts18m07.vcllicnum  attribute (reverse)

    after  field vcllicnum
       display by name d_cts18m07.vcllicnum

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field prporgpcp
       end if

       if d_cts18m07.vcllicnum is null  then
          error " Placa do veiculo ou numero de proposta deve ser informada!"
          next field vcllicnum
       end if

    on key (interrupt)
       exit input

 end input

 close window  w_cts18m07

 return d_cts18m07.sinocrdat thru d_cts18m07.vcllicnum

end function  ###  cts18m07
