###############################################################################
#------------------------------ ALTERACOES -----------------------------------#
# Data       Responsavel        Origem    Alteracao                           #
# ---------- ---------------    ------    -------------------------------     #
# 26/05/2014 Rodolfo Massini    ------    Alteracao na forma de envio de      #
#                                         e-mail (SENDMAIL para FIGRC009)     # 
# 05/09/2014 Rodolfo Massini    ------    Alteracao nome da funcao f_prepare  # 
###############################################################################

database porto

#-------------------------------
 function ctr00m00_f_prepare()
#-------------------------------

  define l_sql char(1000)
  let l_sql = "select vistoria.ofnnumdig, relacao.sinvstnum, ligacao.ligdat, ",
              "       ligacao.c24astcod, ligacao.c24usrtip, ligacao.c24empcod, ",
              "       ligacao.c24funmat ",
              "from datmligacao as ligacao, datrligsinvst as relacao, ",
              "     datmvstsin as vistoria ",
              "where ligacao.ligdat >= ? and ligacao.ligdat <= ? and ",
              "      ligacao.c24astcod in ('V10', 'V11') and ",
              "      ligacao.lignum = relacao.lignum and ",
              "      relacao.sinvstnum = vistoria.sinvstnum and ",
              "      relacao.sinvstano = vistoria.sinvstano ",
              "order by vistoria.ofnnumdig"

  prepare p_ctr00m00_001 from l_sql
  declare c_ctr00m00_001 cursor for p_ctr00m00_001
  let l_sql = "select nomrazsoc from gkpkpos where pstcoddig = ?"
  prepare pb02 from l_sql
  declare cb02 cursor for pb02

  let l_sql = "select ofnciaflg, ofncrdflg, ofncvnflg from sgokofi ",
              "where ofnnumdig = ?"
  prepare pb03 from l_sql
  declare cb03 cursor for pb03
  let l_sql = "select cpodes from iddkdominio where cponom = 'reloficinas'"
  prepare pb04 from l_sql
  declare cb04 cursor for pb04

end function

#-------------------------------
 function ctr00m00()
#-------------------------------
  define l_data_l like datmligacao.ligdat,   #data da ligacao
         l_vistor like datmvstsin.sinvstnum, #numero sinistro
         l_cod_of like datmvstsin.ofnnumdig, #codigo oficina
         l_nom_of like gkpkpos.nomrazsoc,    #nome oficina
         l_assunt like datmligacao.c24astcod,#assunto
         l_funmat like datmligacao.c24funmat,#matricula do atendente
         l_empcod like datmligacao.c24empcod,#empresa do atendente
         l_usrtip like datmligacao.c24usrtip,#tipo do atendente
         l_flg_oc char(1),                   #flag companhia
         l_flg_or char(1),                   #flag credenciada
         l_flg_ov char(1),                   #flag conveniada
         l_ofc_tp char(100),                 #classificacao oficina
         l_tmp_of like datmvstsin.ofnnumdig, #oficina temporaria
         l_dir    char(200),                 #diretorio do xls
         l_arq1   char(200),                 #arquivo xls
         l_arq2   char(200),                 #arquivo xls
         l_arq3   char(200),                 #arquivo xls
         l_emassu char(100),                 #assunto do email
         l_dest   char(1000),                #destinatarios do email
         l_opt_pe smallint,                  #codigo do periodo
         l_cpodes like iddkdominio.cpodes,   #email
         l_datas  record
           dataini date,
           datafim date
         end record

  initialize l_datas.* to null
  let l_dest   = null
  let l_opt_pe = null
  let l_tmp_of = 0
  let l_ofc_tp = "Privada"
  let l_dir    = '.'
  let l_arq1   = l_dir clipped, "/ligacoes_oficina_grupo.xls"
  let l_arq2   = l_dir clipped, "/ligacoes_oficina_bruto.xls"
  let l_arq3   = l_dir clipped, "/ligacoes_oficina_resumo.xls"

  call pop_periodo()
  returning l_opt_pe
  if l_opt_pe < 0 then
    return
  end if
  case
    when l_opt_pe = 0
      let l_datas.dataini = today - 1 units day
      let l_datas.datafim = l_datas.dataini
    when l_opt_pe = 1
      let l_datas.datafim = today - 1 units day
      let l_datas.dataini = l_datas.datafim - 1 units month
    otherwise
      call pop_datas()
      returning l_datas.*
  end case
  if l_datas.dataini is null or l_datas.datafim is null then
     error 'Informe a data de intervalo do relatorio.'
     return
  end if
  let l_emassu = "Ligacoes de vistorias de sinistro por oficina [",
                  l_datas.dataini clipped, " ate ", l_datas.datafim clipped, "]"
  set isolation to dirty read
  call ctr00m00_f_prepare()
  display "[Data inicio: ", l_datas.dataini, "][Data fim: ",
          l_datas.datafim, "]"

  foreach cb04 into l_cpodes
    if l_dest is null then
      let l_dest = l_cpodes
    else
      let l_dest = l_dest clipped, ",", l_cpodes
    end if
  end foreach
  open c_ctr00m00_001 using l_datas.dataini, l_datas.datafim
  start report r_imprime1 to l_arq1
  start report r_imprime2 to l_arq2
  start report r_imprime3 to l_arq3
  foreach c_ctr00m00_001 into l_cod_of, l_vistor, l_data_l, l_assunt, l_usrtip,
                    l_empcod, l_funmat
    if l_cod_of = l_tmp_of then
      output to report r_imprime1(l_cod_of, l_nom_of, l_vistor, l_data_l,
        l_assunt, l_ofc_tp, l_funmat, l_empcod, l_usrtip)
      output to report r_imprime2(l_cod_of, l_nom_of, l_vistor, l_data_l,
        l_assunt, l_ofc_tp, l_funmat, l_empcod, l_usrtip)
      output to report r_imprime3(l_cod_of, l_nom_of, l_ofc_tp, l_funmat)
      continue foreach
    end if
    open cb02 using l_cod_of
    fetch cb02 into l_nom_of
    open cb03 using l_cod_of
    fetch cb03 into l_flg_oc, l_flg_or, l_flg_ov
    let l_tmp_of = l_cod_of
    call set_tipo(l_flg_oc, l_flg_or, l_flg_ov)
    returning l_ofc_tp
    output to report r_imprime1(l_cod_of, l_nom_of, l_vistor, l_data_l,
      l_assunt, l_ofc_tp, l_funmat, l_empcod, l_usrtip)
    output to report r_imprime2(l_cod_of, l_nom_of, l_vistor, l_data_l,
      l_assunt, l_ofc_tp, l_funmat, l_empcod, l_usrtip)
    output to report r_imprime3(l_cod_of, l_nom_of, l_ofc_tp, l_funmat)
  end foreach
  finish report r_imprime1
  finish report r_imprime2
  finish report r_imprime3
  close cb02
  close cb03
  close c_ctr00m00_001

  call send_email(l_emassu, l_dest, ctr00m00_compact(l_arq1),
    ctr00m00_compact(l_arq2), ctr00m00_compact(l_arq3))

end function

#-------------------------------
 function ctr00m00_compact(l_arq)
#-------------------------------

  define l_comand char(100)
  define l_arq    char(500)
  let l_comand = "gzip -f ", l_arq
  run l_comand
  let l_arq    = l_arq clipped, ".gz"
  return l_arq

end function

#----------------------------------------------------------
 report r_imprime1(l_cod_of, l_nom_of, l_vistor, l_data_a, l_assunt, l_ofc_tp,
                   l_funmat, l_empcod, l_usrtip)
#----------------------------------------------------------
  define l_cod_of like datmvstsin.ofnnumdig,
         l_nom_of like gkpkpos.nomrazsoc,
         l_vistor like datmvstsin.sinvstnum,
         l_data_a like datmligacao.ligdat,
         l_assunt like datmligacao.c24astcod,
         l_funmat like datmligacao.c24funmat,
         l_empcod like datmligacao.c24empcod,
         l_usrtip like datmligacao.c24usrtip,
         l_matric char(10),
         l_ofc_tp char(100),
         l_qtd    integer
  output
    left   margin 000
    top    margin 000
    bottom margin 000
  order by l_cod_of
    format
      first page header
        print "<html><table><th>VISTORIA</th><th>DATA LIGACAO</th>",
              "<th>ASSUNTO</th><th>ATENDENTE</th>",
              "<tr><td colspan=4></td></tr>"
      on every row
        let l_qtd = l_qtd + 1
        let l_matric = l_usrtip clipped, l_empcod using '&&',
                       l_funmat using '&&&&&&'
        print "<tr><td align=center>", l_vistor clipped, "</td>",
              "<td align=center>", l_data_a clipped, "</td>",
              "<td align=center>", l_assunt clipped, "</td>",
              "<td align=center>", l_matric clipped, "</td>"
      before group of l_cod_of
        let l_qtd = 0
        print "<tr><td colspan=7><b>Oficina: ", l_cod_of clipped,
              " - ", l_nom_of clipped, " (", l_ofc_tp clipped,
              ")</b></td></tr>"
      after group of l_cod_of
        print "<tr><td colspan=2><b>Total de atendimentos: ", l_qtd,
              "</b></td></tr><tr><td colspan=4></td></tr>"
      on last row
        print "</table></html>"
end report

#----------------------------------------------------------
 report r_imprime2(l_cod_of, l_nom_of, l_vistor, l_data_a, l_assunt, l_ofc_tp,
                   l_funmat, l_empcod, l_usrtip)
#----------------------------------------------------------
  define l_cod_of like datmvstsin.ofnnumdig,
         l_nom_of like gkpkpos.nomrazsoc,
         l_vistor like datmvstsin.sinvstnum,
         l_data_a like datmligacao.ligdat,
         l_assunt like datmligacao.c24astcod,
         l_funmat like datmligacao.c24funmat,
         l_empcod like datmligacao.c24empcod,
         l_usrtip like datmligacao.c24usrtip,
         l_matric char(10),
         l_ofc_tp char(100),
         l_qtd    integer
  output
    left   margin 000
    top    margin 000
    bottom margin 000
  order by l_cod_of
    format
      first page header
        print "<html><table><th>COD. OFICINA</th><th>RAZAO SOCIAL</th>",
              "<th>VISTORIA</th><th>DATA LIGACAO</th><th>ASSUNTO</th>",
              "<th>CLASSIFICACAO</th><th>ATENDENTE</th>"
      on every row
        let l_matric = l_usrtip, l_empcod using '&&',
                       l_funmat using '&&&&&&'
        print "<tr><td align=center>", l_cod_of clipped, "</td>",
              "<td align=left>", l_nom_of clipped, "</td>",
              "<td align=center>", l_vistor clipped, "</td>",
              "<td align=center>", l_data_a clipped, "</td>",
              "<td align=center>", l_assunt clipped, "</td>",
              "<td align=center>", l_ofc_tp clipped, "</td>",
              "<td align=center>", l_matric clipped, "</td>"
end report

#----------------------------------------------------------
 report r_imprime3(l_cod_of, l_nom_of, l_ofc_tp, l_funmat)
#----------------------------------------------------------
  define l_cod_of like datmvstsin.ofnnumdig,
         l_nom_of like gkpkpos.nomrazsoc,
         l_funmat like datmligacao.c24funmat,
         l_ofc_tp char(100),
         l_qtd_ct integer,   #quantidade de atendimentos via central
         l_qtd_pt integer    #quantidade de atendimentos via portal
  output
    left   margin 000
    top    margin 000
    bottom margin 000
  order by l_cod_of
    format
      first page header
        print "<html><table><th>COD. OFICINA</th><th>RAZÃO SOCIAL</th>",
              "<th>CLASSIFICAÇÃO</th><th>ATDS. CENTRAL</th>",
              "<th>ATDS. PORTAL</th><th>TOTAL ATDS.</th>"
      on every row
        if l_funmat = 809365 then         #atendimento via portal
          let l_qtd_pt = l_qtd_pt + 1
        else
          let l_qtd_ct = l_qtd_ct + 1
        end if
      before group of l_cod_of
        let l_qtd_ct = 0
        let l_qtd_pt = 0
      after group of l_cod_of
        print "<tr><td align=center>", l_cod_of, "</td>",
              "<td align=left>", l_nom_of clipped, "</td>",
              "<td align=center>", l_ofc_tp clipped, "</td>",
              "<td align=center>",l_qtd_ct,"</td>",
              "<td align=center>",l_qtd_pt, "</td>",
              "<td align=center>",(l_qtd_ct + l_qtd_pt),"</td></tr>"
      on last row
        print "</table></html>"
end report

#----------------------------------------------------------
 function set_tipo(l_flg_oc, l_flg_or, l_flg_ov)
#----------------------------------------------------------

  define l_flg_oc, l_flg_or, l_flg_ov char(1),
         l_ofc_tp char(100)
  let l_ofc_tp = "Particular"
  if l_flg_oc = "S" then
    let l_ofc_tp = "Compania"
  end if
  if l_flg_or = "S" then
      let l_ofc_tp = "Credenciada"
  end if
  if l_flg_ov = "S" then
      let l_ofc_tp = "Conveniada"
  end if
  return l_ofc_tp
end function

#----------------------------------------------------------
 function send_email(l_assunto, l_des, l_arq1, l_arq2, l_arq3)
#----------------------------------------------------------

  define lr_mens        record
         sistema        char(10)
        ,remet          char(50)
        ,para           char(1000)
        ,cc             char(400)
        ,msg            char(400)
        ,subject        char(400)
  end record

  define l_assunto char(100), l_cmd char(1000), l_ret smallint,
         l_des char(500), l_arq1, l_arq2, l_arq3 char(200)
         
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
 
  define lr_anexo record
         anexo1    char (300)
        ,anexo2    char (300)
        ,anexo3    char (300)
  end record

  define l_anexo   char (300)
        ,l_retorno smallint

  initialize lr_mail
            ,l_anexo
            ,l_retorno
            ,lr_anexo
  to null
 
  ### RODOLFO MASSINI - FIM 

  initialize lr_mens.* to null
  let l_cmd = null
  let l_ret = null

  let lr_mens.subject = l_arq1 clipped, ',', l_arq2 clipped, ',',
                        l_arq2 clipped
  let lr_mens.msg = l_assunto
  let lr_mens.sistema = "CT24HS"
  let lr_mens.remet = "ct24hs.email@correioporto"
  let lr_mens.para = l_des

  display 'Enviando e-mail para: ', lr_mens.para clipped
  
  ### RODOLFO MASSINI - INICIO 
  #---> remover (comentar) forma de envio de e-mails anterior e inserir
  #     novo componente para envio de e-mails.
  #---> feito por Rodolfo Massini (F0113761) em maio/2013
  
  #let l_cmd = ' echo " "  | send_email.sh ',
  #            ' -a     ', lr_mens.para  clipped,
  #            ' -s    "', lr_mens.msg clipped, '" ',
  #            ' -f     ', lr_mens.subject clipped,
  #            ' -r     ', lr_mens.remet    clipped

  #run l_cmd returning l_ret
  
  let lr_mail.ass = lr_mens.msg clipped 
  let lr_mail.rem = lr_mens.remet clipped
  let lr_mail.des = lr_mens.para clipped
  let lr_mail.tip = "text"
  
  let lr_anexo.anexo1 = l_arq1 clipped
  let lr_anexo.anexo2 = l_arq2 clipped
  let lr_anexo.anexo3 = l_arq2 clipped
 
  call ctx22g00_envia_email_overload(lr_mail.*
                                    ,lr_anexo.*)
  returning l_retorno 
  
  let l_ret = l_retorno                                       
                                                
  ### RODOLFO MASSINI - FIM   
  
  
  if l_ret = 0  then
     let l_assunto = 'Email ', l_assunto clipped,' enviado com sucesso ',
                      current
  else
     let l_assunto = 'Email ', l_assunto clipped,' nao enviado ', current
  end if

  display l_assunto

end function

#----------------------------------------------------------
 function pop_periodo()
#----------------------------------------------------------

  define l_periodo smallint
  define l_periodos array[3] of record
    cod_per smallint,
    des_per char(50)
  end record
  initialize l_periodos to null
  let l_periodo             = 0
  let l_periodos[1].cod_per = 0;
  let l_periodos[1].des_per = "Diario";
  let l_periodos[2].cod_per = 1;
  let l_periodos[2].des_per = "Mensal";
  let l_periodos[3].cod_per = 2;
  let l_periodos[3].des_per = "Por intervalo";
  let int_flag = false
  open window w_periodo at 6, 26 with form 'ctr00m00'
    attribute(border, form line first)
    call set_count(3)
    display array l_periodos to sa_periodos.*
      on key(f8)
        let l_periodo = arr_curr();
        exit display
    end display
  close window w_periodo

  if int_flag then
    let int_flag = false
    return -1
  end if

  return l_periodos[l_periodo].cod_per

end function


#----------------------------------------------------------
 function pop_datas()
#----------------------------------------------------------

  define l_datas record
    dataini date,
    datafim date
  end record
  define l_difer integer

  let int_flag = false
  open window w_datas at 7, 26 with form 'ctr00m01'
    attribute(border, form line first)
    input by name l_datas.*
      before field datafim
        if l_datas.dataini is null then
          error 'Informe a data inicial.'
          next field dataini
        end if
        if l_datas.dataini > (today - 1 units day) then
          error 'Data inicial nao deve ser superior',
                ' a ontem.'
          next field dataini
        end if
      after field datafim
        let l_difer = l_datas.datafim - l_datas.dataini

        if l_datas.datafim is null then
          error 'Informe a data final.'
          next field datafim
        end if
        if l_datas.datafim < l_datas.dataini then
          error 'Data final nao deve ser inferior a ',
                'data inicial.'
          next field datafim
        end if
        if l_datas.datafim > (today - 1 units day) then
          error 'Data final nao deve ser superior',
                ' a ontem.'
          next field datafim
        end if
        if (l_difer > 31) then
          error 'Intervalo nao deve ser superior a um mes.'
          next field dataini
        end if
      if int_flag then
        let int_flag = false
        clear form
        initialize l_datas.* to null
        return
      end if
    end input
  close window w_datas
  return l_datas.*
end function
