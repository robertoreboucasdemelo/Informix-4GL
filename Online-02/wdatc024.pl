#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc024.pl                                                   #
#  Sistema..: Prestador On Line PSRONLINE                                    #
#  Criacao..: Ago/2001                                                       #
#  Autor....: Marcus                                                         #
#                                                                            #
#  Objetivo.: Receber a opcao do Laudo e monta form final de decisao         #
#----------------------------------------------------------------------------#
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 04/07/2007 Luiz, Meta    AS143650  Retirada do teste da identificacao do   #
#                                    ambiente                                #
#----------------------------------------------------------------------------#
 use CGI ":all";
 use strict;                #--> Obriga definicao explicita das variaveis
 use ARG4GL;                #--> Biblioteca erro no informix

 #-----------------------------------------------------------------------------
 # Inclusao das subrotinas que montam campos, textos, botoes, etc.
 #-----------------------------------------------------------------------------
 require "/webserver/cgi-bin/seweb/trs/wissc203.pl";     #--> Gera titulo
 require "/webserver/cgi-bin/seweb/trs/wissc204.pl";     #--> Gera list box
 require "/webserver/cgi-bin/seweb/trs/wissc205.pl";     #--> Gera check box
 require "/webserver/cgi-bin/seweb/trs/wissc206.pl";     #--> Gera radio box
 require "/webserver/cgi-bin/seweb/trs/wissc207.pl";     #--> Gera Texto/Input/Texto
 require "/webserver/cgi-bin/seweb/trs/wissc208.pl";     #--> Gera colunas/tabelas
 require "/webserver/cgi-bin/seweb/trs/wissc209.pl";     #--> Gera titulo com help
 require "/webserver/cgi-bin/seweb/trs/wissc210.pl";     #--> Gera cabecalho da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc211.pl";     #--> Gera rodape da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc212.pl";     #--> Gera tabela com varias linhas
 require "/webserver/cgi-bin/seweb/trs/wissc216.pl";     #--> Gera linha com checkbox/listbox
 require "/webserver/cgi-bin/seweb/trs/wissc218.pl";     #--> Vetores de conversao
 require "/webserver/cgi-bin/seweb/trs/wissc219.pl";     #--> Gera pagina de mensagem/erro
 require "/webserver/cgi-bin/seweb/trs/wissc220.pl";     #--> Checa erro no programa 4GL/BD
 require "/webserver/cgi-bin/seweb/trs/wissc225.pl";     #--> Gera colunas/tabelas para versao de impressao

 #-----------------------------------------------------------------------------
 # Definicao das variaveis
 #-----------------------------------------------------------------------------
 my( $maq,
    #$ambiente,
     $cabec,
     $titgif,
     $padrao,
     $texto,
     $prog,
     $line,
     $ARG,
     $webusrcod,
     $sesnum,
     $macsissgl,
     $usrtip,
     $atdsrvnum,
     $atdsrvano,
     $atdprvdat,
     $srvobs,
     $txivlr,
     $caddat,
     $cadhor,
     $acao,
     $action,
     $JSCRIPT,
     @botao,
     @botoes,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape  ,
     $hotel,
     $estado_htl,
     $cidade_htl,
     $bairro_htl,
     $endereco_htl,
     $referencia_htl,
     $contato,
     $telefone_htl,
     $diaria,
     $acomodacao,
     $obs,
     $flag,
     $nrquartos,
     $ciaempcod,
     $image,
     $nomeseg,
     @form,
     @script,
     @hidden,
     @texto,
     $load
   );


#$ambiente = "remsh aplweb01 -l runwww ";

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
#$cabec  = 'RECEBER SERVIÇOS';
 $titgif = '/seweb/images/c_acesso.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';

 $webusrcod=param("webusrcod");
 $sesnum = param("sesnum");
 $macsissgl = param("macsissgl");
 $usrtip = param("usrtip");
 $atdsrvnum = param("atdsrvnum");
 $atdsrvano = param("atdsrvano");
 $acao      = param("Acao");
 $flag      = param("flag");
 $hotel     = param("hotel");
 $estado_htl     = param("estado_htl");
 $cidade_htl     = param("cidade_htl");
 $bairro_htl     = param("bairro_htl");
 $endereco_htl   = param("endereco_htl");
 $referencia_htl = param("referencia_htl");
 $contato        = param("contato");
 $telefone_htl   = param("telefone_htl");
 $diaria         = param("diaria");
 $acomodacao     = param("acomodacao");
 $obs            = param("obs");
 $nrquartos      = param("nrquartos");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
if ($acao eq "Enviar") {
    push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$acao,$atdprvdat, $srvobs, $txivlr, $hotel, $estado_htl, $cidade_htl, $bairro_htl, $endereco_htl, $referencia_htl, $contato, $telefone_htl, $diaria, $acomodacao, $obs, $nrquartos;
}
else
{
    push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$acao;
}

$JSCRIPT=<<END;

function isNumeros(campo) {
   var nums = "0123456789";
   ret = true;

   for (i=0;i<campo.length;i++) {
        ret = false;
        var b = campo.charAt(i);
        for (a=0;a<nums.length;a++) {
	    if (b == nums.charAt(a)) {
	        ret = true;
	        break;
	    }
        }

        if (!ret) break;
   }

   return ret;
}
function func_atdprvdat()

{
  var atdprvdat = document.wdatc024.atdprvdat;
  var asitip = document.wdatc024.asitipcod;
  var macsissgl = document.wdatc024.macsissgl;


     if (atdprvdat.value == "") {
         alert("Informe a previsão de chegada!");
         atdprvdat.value = "";
         document.wdatc024.atdprvdat.focus();
         return false;
     }

     if (!isNumeros(atdprvdat.value)) {
        atdprvdat.value = "";
        alert("Digite somente números na previsão de chegada !");
        document.wdatc024.atdprvdat.focus();
        return false;
     }

     if (atdprvdat.value.length > 4) {
        atdprvdat.value = "";
        alert("Informe somente 4 números (HHmm) !");
        document.wdatc024.atdprvdat.focus();
        return false;
     }

  if (asitip.value != "5" && macsissgl.value != "PSRONLINE") {

     horpvt = document.wdatc024.atdhorpvt.value.substring(0,2) +
              document.wdatc024.atdhorpvt.value.substring(2,4);

     if (horpvt > 0 && atdprvdat.value > horpvt) {
         alert("Previsão informada superior a previsão do laudo.");
         atdprvdat.value = "";
         document.wdatc024.atdprvdat.focus();
         return false;
     }

     if ((horpvt == "0000" || horpvt == "") && atdprvdat.value > 20) {
         alert("Previsão de retorno não pode ultrapassar 20 minutos.");
         atdprvdat.value = "";
         document.wdatc024.atdprvdat.focus();
         return false;
     }

  }
     for (i = atdprvdat.value.length; i < 4; i++) {
         atdprvdat.value = "0" + atdprvdat.value;
     }

     atdprvdat.value = atdprvdat.value.substring(0,2) + ":" + atdprvdat.value.substring(2,4);
     return true;

}

function func_checa(x)
{
  var v_aux = '';
  var horpvt = '';
  var flag = 0;
  var srvobs = document.wdatc024.srvobs;
  var txivlr = document.wdatc024.txivlr;
  var asitip = document.wdatc024.asitipcod;

  if (x == 1)
    {


     }

  if (x == 2)
     {
       if (document.wdatc024.etpmtvcod.value == "     8" && document.wdatc024.srvobs.value.length == 0)
       {
        v_aux += "Informe o motivo da recusa!";
       }
     if (v_aux > "")
       {
        alert(v_aux);
        document.wdatc024.srvobs.focus();
        return false;
       }
     else
       { document.wdatc024.submit(); }
     }

  if ( x == 3 )
      {
       if (document.wdatc024.aerciacod.value == "" || document.wdatc024.adlpsgvlr.value == "" || document.wdatc024.crnpsgvlr.value == "" || document.wdatc024.totpsgvlr.value == "" || document.wdatc024.totpsgvlr.value == "" || document.wdatc024.arpembcod.value == "" || document.wdatc024.trpaersaidat.value == "" || document.wdatc024.trpaersaihor.value == "" || document.wdatc024.arpchecod.value == "" || document.wdatc024.trpaerchedat.value == "" || document.wdatc024.trpaerchehor.value == "" )
          {
            v_aux = "Informe os dados, os campos são de preenchimento obrigatório!";
            alert(v_aux);
            document.wdatc024.aerciacod.focus();
            return false;
           }

           dt1 = document.wdatc076.trpaerchedat.value.substring(6,10) +
                 document.wdatc076.trpaerchedat.value.substring(3, 5) +
                 document.wdatc076.trpaerchedat.value.substring(0, 2);

           dt2 = document.wdatc076.dtsaida.value.substring(6,10) +
                 document.wdatc076.dtsaida.value.substring(3, 5) +
                 document.wdatc076.dtsaida.value.substring(0, 2);

           if (document.wdatc076.voocnxseq.value > 1 ) {
               if (dt1 < dt2) {
                  alert("Data de saida nao confere com a data de saida anterior");
                  return false;
               }
           }
      }
  if ( x == 4 )
      {
        if (document.wdatc024.atdprvdat.value == "") {
            alert("Informe a previsão de chegada!");
            document.wdatc024.atdprvdat.value = "";
            document.wdatc024.atdprvdat.focus();
            return false;
        }

        if (document.wdatc024.asitipcod.value == "5") {
            flag = func_txivlr(0);
            return flag;
        }

      return true;

      }
}


function funcValidaEntrada(valEntrada) {
        if (valEntrada != "") {
            var strval  = "";
            var fltval  = 0;
            var strnum  = "0123456789,.";
            for (cont=0; cont < valEntrada.length; cont++) {
                strcar = valEntrada.charAt(cont);
                if (strnum.indexOf(strcar) != -1) {
                    if (strcar == ",") {
                        strcar = "."
                    }
                    strval = strval + strcar;
                }
            }
            fltval = parseFloat(strval);
            return fltval;
        }
}

function func_txivlr(msg) {

     if (msg != "0") { alert(msg); }

     if (document.wdatc024.txivlr.value == "NaN" ||
         document.wdatc024.txivlr.value  == "undefined") {
         alert("Digite apenas valores numéricos !");
         document.wdatc024.txivlr.value = "";
         document.wdatc024.txivlr.focus();
         return false;
     }

     if (document.wdatc024.txivlr.value == "" ||
         document.wdatc024.txivlr.value.substring(1,0) == "0") {
        alert("Informe o valor estimado do taxi!");
        document.wdatc024.txivlr.focus();
        return false;
     }

     document.wdatc024.txivlr.value = funcValidaEntrada(document.wdatc024.txivlr.value);

     if (document.wdatc024.txivlr.value > vltaxi) {
        alert("Valor informado superior a cobertura da apólice, entre em contato fone 3366-3055");
        //document.wdatc024.txivlr.value = "";
        //document.wdatc024.txivlr.focus();
     }

  return true;
}

function func_adlpsgvlr() {

    if (document.wdatc024.adlpsgvlr.value == "NaN" ||
        document.wdatc024.adlpsgvlr.value == "undefined" ||
        document.wdatc024.adlpsgvlr.value == "" ||
        document.wdatc024.adlpsgvlr.value == null ||
        document.wdatc024.adlpsgvlr.length == 0)  {
        alert("Informe o valor da passagem adulto!");
        document.wdatc024.adlpsgvlr.value = "";
        document.wdatc024.adlpsgvlr.focus();
        return false;
     }
    else {
       document.wdatc024.adlpsgvlr.value = funcValidaEntrada(document.wdatc024.adlpsgvlr.value);
       return true;
     }
}

function func_crnpsgvlr() {

    if (document.wdatc024.adlpsgvlr.value != ""  ) {

    if (document.wdatc024.crnpsgvlr.value == "NaN" ||
        document.wdatc024.crnpsgvlr.value == "undefined" ||
        document.wdatc024.crnpsgvlr.value == "" ||
        document.wdatc024.crnpsgvlr.value == null ||
        document.wdatc024.crnpsgvlr.length == 0)  {
        alert("Informe o valor da passagem de crianca!");
        document.wdatc024.crnpsgvlr.value = "";
        document.wdatc024.crnpsgvlr.focus();
        return false;
     }
    else {
       document.wdatc024.crnpsgvlr.value = funcValidaEntrada(document.wdatc024.crnpsgvlr.value);
       return true;
     }

     }
}
function func_totpsgvlr(msg) {

    if (msg != 0) { alert(msg);  }

    if (document.wdatc024.crnpsgvlr.value != ""  ) {

    if (document.wdatc024.totpsgvlr.value == "NaN" ||
        document.wdatc024.totpsgvlr.value == "undefined" ||
        document.wdatc024.totpsgvlr.value == "" ||
        document.wdatc024.totpsgvlr.value == null ||
        document.wdatc024.totpsgvlr.length == 0)  {
        alert("Informe o valor total da passagem!");
        document.wdatc024.totpsgvlr.value = "";
        document.wdatc024.totpsgvlr.focus();
        return false;
     }
    else {
       document.wdatc024.totpsgvlr.value = funcValidaEntrada(document.wdatc024.totpsgvlr.value);
       return true;
     }

     }
}

function func_saiHor() {

    if (document.wdatc024.trpaersaihor.value != "") {
        document.wdatc024.trpaersaihor.value =
                 func_val_hora(document.wdatc024.trpaersaihor.value);

        if (!horahoje(document.wdatc024.trpaersaidat.value,
                      document.wdatc024.trpaersaihor.value))   {
            document.wdatc024.trpaersaihor.value = "";
            document.wdatc024.trpaersaihor.focus();
             }
        else {
              document.wdatc024.trpaersaihor.value =
                    document.wdatc024.trpaersaihor.value.substring(0,2) + ":" +
                    document.wdatc024.trpaersaihor.value.substring(2,4);
            }
    }

}

function func_cheHor() {
    if (document.wdatc024.trpaersaihor.value != "") {
       document.wdatc024.trpaerchehor.value = func_val_hora(document.wdatc024.trpaerchehor.value);

       if ( !horDeMenorIgual()) {
           if (document.wdatc024.trpaersaidat.value ==
               document.wdatc024.trpaerchedat.value)  {
               document.wdatc024.trpaerchehor.value = "";
               document.wdatc024.trpaersaihor.focus();
               alert("Hora de chegada menor ou igual a hora de embarque");
           }
          else { document.wdatc024.trpaerchehor.value =
                 document.wdatc024.trpaerchehor.value.substring(0,2) + ":" +
                 document.wdatc024.trpaerchehor.value.substring(2,4);
            }
         }
       else { document.wdatc024.trpaerchehor.value =
              document.wdatc024.trpaerchehor.value.substring(0,2) + ":" +
              document.wdatc024.trpaerchehor.value.substring(2,4);
            }
    }
}

function func_val_hora(hora) {

 var hr= "00:00";
 var v_aux = "";

 if (!isNumeros(hora)) {
        v_aux += "Digite somente números na hora!";
     }

     if (hora.length > 4) {
        v_aux+= "Informe somente 4 números (HHmm) !";
     }

     if (v_aux > "")
       {
        alert(v_aux);
        return hora;
       }

     for (i = hora.length; i < 4; i++) {
         hora = "0" + hora;
     }

 return hora;
}

function func_saiDat() {

    document.wdatc024.trpaersaidat.value = func_val_data(document.wdatc024.trpaersaidat.value);
   if ( !datahoje()) {
       //document.wdatc024.trpaersaidat.value = "";
       document.wdatc024.trpaersaidat.focus();
   }

}

function func_cheDat() {

    document.wdatc024.trpaerchedat.value = func_val_data(document.wdatc024.trpaerchedat.value);
   if ( !datahoje()) {
       //document.wdatc024.trpaerchedat.value = "";
       document.wdatc024.trpaerchedat.focus();
   }
   else {
      if ( !datDeMenorIgual()) {
          document.wdatc024.trpaerchedat.value = "";
          document.wdatc024.trpaerchedat.focus();
      }
   }
}

function func_val_data(data) {

   if (data == "") {
      alert("Informe a data");
      return data;
   }
   else {
      if ( ! wiasc007_parseValidaData(data)) {
          alert("Data invalida, digite novamente!");
          data = "";
          return data;
      }
      else {
         data = wiasc007_formataData(data);
      }
   }


  return data;
}

function datDeMenorIgual() {
   datsai = document.wdatc024.trpaersaidat.value.substring(6,10) +
            document.wdatc024.trpaersaidat.value.substring(3, 5) +
            document.wdatc024.trpaersaidat.value.substring(0, 2);
   datche = document.wdatc024.trpaerchedat.value.substring(6,10) +
            document.wdatc024.trpaerchedat.value.substring(3, 5) +
            document.wdatc024.trpaerchedat.value.substring(0, 2);

   if (datsai <= datche) {
      return true;
   }
   else {
      alert("Data de saida maior que data de chegada");
      return false;
   }
}

function datahoje() {
   dathoj = document.wdatc024.hoje.value.substring(6,10) +
            document.wdatc024.hoje.value.substring(3, 5) +
            document.wdatc024.hoje.value.substring(0, 2);
   datsai = document.wdatc024.trpaersaidat.value.substring(6,10) +
            document.wdatc024.trpaersaidat.value.substring(3, 5) +
            document.wdatc024.trpaersaidat.value.substring(0, 2);
   datche = document.wdatc024.trpaerchedat.value.substring(6,10) +
            document.wdatc024.trpaerchedat.value.substring(3, 5) +
            document.wdatc024.trpaerchedat.value.substring(0, 2);

   if (datsai < dathoj || datche < dathoj)
      { alert("Data menor que a data de hoje");
        return false; }

   return true;
}

function horahoje(data, hora) {

   data   = data.substring(6,10) +
            data.substring(3, 5) +
            data.substring(0, 2);

   dathoj = document.wdatc024.hoje.value.substring(6,10) +
            document.wdatc024.hoje.value.substring(3, 5) +
            document.wdatc024.hoje.value.substring(0, 2);

   horhoj = document.wdatc024.hora.value.substring(0, 2) + document.wdatc024.hora.value.substring(2, 4);

  if (dathoj == data)  {
      if (hora <= horhoj)
         { alert("Hora menor que a hora de hoje");
           return false; }
  }

   return true;
}

function horDeMenorIgual() {
   horsai = document.wdatc024.trpaersaihor.value.substring(0, 2) +
            document.wdatc024.trpaersaihor.value.substring(3, 5);
   horche = document.wdatc024.trpaerchehor.value.substring(0, 2) +
            document.wdatc024.trpaerchehor.value.substring(3, 5);

       if (horsai < horche || horsai == horche) {
          return true;
       }
       else {
        return false; }
}
END

$ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 if ($acao eq 'Cotar' || $acao eq 'Com conexão' || $acao eq 'Cotar mais vôos')
     {
     $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc076.4gc $ARG 2>&1)"; }
 elsif ($acao eq 'Reservar' || $acao eq 'Emitir' || $acao eq 'Enviar')
     {
      $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc027.4gc $ARG 2>&1)"; }
 else
    {
       $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc025.4gc $ARG 2>&1)"; }

      #open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
       open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

 #-----------------------------------------------------------------------------
 # Montando body variavel @body (parte central do fonte HTML)
 #-----------------------------------------------------------------------------
 while (<PROG>)
   {
    #--------------------------------------------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------------------------------------------
    &wissc220_veriferro($_, $macsissgl);

    @REGISTRO = split '@@',$_;

    if ($REGISTRO[0] eq "NOSESS")
       { &wissc219_mensagem($titgif,$cabec,"LOGIN",$REGISTRO[1]); }

    elsif ($REGISTRO[0] eq "ERRO")
       { &wissc219_mensagem($titgif,$cabec,"BACK",$REGISTRO[1]); }

    if ($REGISTRO[0] eq "PADRAO")
       {
        if ($REGISTRO[1] == 1)
           { push @body, &wissc203_titulo(@REGISTRO); }

        elsif ($REGISTRO[1] == 2)
              { push @body, &wissc204_listbox(@REGISTRO); }

        elsif ($REGISTRO[1] == 3)
              { push @body, &wissc205_checkbox(@REGISTRO); }

        elsif ($REGISTRO[1] == 4)
              { push @body, &wissc206_radiobox(@REGISTRO); }

        elsif ($REGISTRO[1] == 5)
              { push @body, &wissc207_textoinputtexto(@REGISTRO); }

        elsif ($REGISTRO[1] == 6)
              { push @body, &wissc208_coluna(@REGISTRO); }

        elsif ($REGISTRO[1] == 7)
              { push @body, &wissc209_titulohelp(@REGISTRO); }

        elsif ($REGISTRO[1] == 8)
              { push @body, &wissc212_linhas1(@REGISTRO); }

        elsif ($REGISTRO[1] == 9)
              { push @body, &wissc216_checklistbox(@REGISTRO); }

        elsif ($REGISTRO[1] == 10)
              { push @body, &wissc225_colunaimpressao(@REGISTRO); }

        elsif ($REGISTRO[1] == 12)
              { $ciaempcod = $REGISTRO[2]; }

        else
           { &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!"); }
       }

     if ($REGISTRO[0] eq "PADRAO2") {  push @body, $REGISTRO[1]; }

     if ($REGISTRO[0] eq "BOTAO")
          { push @botao, submit(-name=>"Acao",-value=>$REGISTRO[1]);
       }
     if ($REGISTRO[0] eq "HIDDEN")
          { push @hidden, $REGISTRO[1];  }

     if ($REGISTRO[0] eq "DATA")
          { push @hidden, $REGISTRO[1]; }

     if ($REGISTRO[0] eq "TEXTO")
          { $texto =  $REGISTRO[1]; }
          ###{ push @texto, $REGISTRO[1]; }

     ##else { &wissc219_mensagem($titgif,$cabec,"BACK","Trata outro tipo de registro!"); }
   }

 close(PROG);

 push @body,
    "<script language='JavaScript'>",
        "function doImpressao() {",
            "var strPagina = '/webserver/cgi-bin/ct24h/trs/wdatc016.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&atdsrvnum=$atdsrvnum&atdsrvano=$atdsrvano&acao=2';",
            "var strNavparam = 'height=400,width=650,left=50,top=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
            "if (navigator.appName.indexOf('Netscape') != -1) {",
            "    strNavparam = 'Impressao','height=400,width=650,screenX=50,screenY=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
            "}",
            "janela=window.open(strPagina,'Impressao',strNavparam);",
        "}",
    "</script>";


 #-----------------------------------------------------------------------------
 # Montando cabecalho (parte inicial do fonte HTML)
 #-----------------------------------------------------------------------------
 if ($acao eq 'Aceitar')
    {
      $cabec  = 'RECEBER SERVIÇOS - ACEITAR';
      ##########$texto = 'Informe no campo "estimativa" a previsão de chegada ao QTR. Caso seja necessário incluir uma observação, utilize o campo "observações".';
      ##$texto = @texto;
      $action ='/webserver/cgi-bin/ct24h/trs/wdatc026.pl';
      push @form, start_html(-'title'=>'Porto Seguro',
                             -'script'=>$JSCRIPT,,
                             -bgcolor=>'#FFFFFF'),"\n";
    }
 elsif ($acao eq 'Cotar' || $acao eq 'Com conexão' || $acao eq 'Cotar mais vôos')
        {
          $cabec  = 'RECEBER SERVIÇOS - COTAR';
          $texto  = 'Informe os dados dos vôos disponíveis. ';
          $action ='/webserver/cgi-bin/ct24h/trs/wdatc076.pl';
          push @form, start_html(-'title'=>'Porto Seguro',
                                 -'script'=>$JSCRIPT,
                                 -bgcolor=>'#FFFFFF'),"\n",
     "<script language='JavaScript' src='/geral/trs/wiasc007.js'></script>";
        }
    elsif ($acao eq "Enviar")
           {
             $cabec  = 'RECEBER SERVIÇOS - ENVIAR';
             if ($flag  eq 'Enviar')
                 {
                  $action ='/webserver/cgi-bin/ct24h/trs/wdatc026.pl';
                  push @form, start_html(-'title'=>'Porto Seguro',
                                    -'script'=>$JSCRIPT,
                                    -onLoad=>'doImpressao();',
                              -'meta'=>{'http-equiv=Pragma content=no-cache'},
                              -bgcolor=>'#FFFFFF'),"\n";
                 }
             else { $action = '/j2ee/atendcentral/jdatc014.do';
                    push @form, start_html(-'title'=>'Porto Seguro',
                                    -'script'=>$JSCRIPT,
                                    -onLoad=>'doImpressao();',
                              -'meta'=>{'http-equiv=Pragma content=no-cache'},
                              -bgcolor=>'#FFFFFF'),"\n";
                  }
           }
    elsif ($acao eq "Reservar")
           {
             $cabec  = 'RECEBER SERVIÇOS - RESERVAR';
             $action = '/j2ee/atendcentral/jdatc014.do';
             push @form, start_html(-'title'=>'Porto Seguro',
                                    -'script'=>$JSCRIPT,
                                    -onLoad=>'doImpressao();',
                              -'meta'=>{'http-equiv=Pragma content=no-cache'},
                              -bgcolor=>'#FFFFFF'),"\n";
           }
    elsif ($acao eq "Emitir")
           {
             $cabec  = 'RECEBER SERVIÇOS - EMITIR';
             $action = '/j2ee/atendcentral/jdatc014.do';
             push @form, start_html(-'title'=>'Porto Seguro',
                                    -'script'=>$JSCRIPT,
                                    -onLoad=>'doImpressao();',
                              -'meta'=>{'http-equiv=Pragma content=no-cache'},
                              -bgcolor=>'#FFFFFF'),"\n";
           }
     else
        {
          $cabec  = 'RECEBER SERVIÇOS - RECUSAR';
          $texto = 'Selecione o motivo da recusa, e caso selecione a opção "outros" informe o motivo no campo observações.';
          $action ='/webserver/cgi-bin/ct24h/trs/wdatc028.pl';
          push @form, start_html(-'title'=>'Porto Seguro',
                                 -'script'=>$JSCRIPT,
                                 -bgcolor=>'#FFFFFF'),"\n";
        }

 push @cabecalho, header, @form;

 if ($acao eq 'Aceitar')
    { push @cabecalho,
      start_form(-method=>'POST',
                 -name=>'wdatc024',
                 -action=>$action,
                 -onsubmit=>'return func_checa(4)'),"\n";
    }
 elsif ($acao eq 'Cotar')
    { push @cabecalho,
      start_form(-method=>'POST',
                 -name=>'wdatc024',
                 -action=>$action,
                 -onsubmit=>'return func_checa(3)'),"\n";
    }
 elsif ($acao eq 'Reservar' || $acao eq 'Emitir')
    { push @cabecalho,
      start_form(-method=>'POST',
                 -name=>'wdatc024',
                 -action=>$action, "\n",
                 -onsubmit=>'return func_checa(3)'),"\n";
    }
 elsif ($acao eq 'Enviar')
    { push @cabecalho,
      start_form(-method=>'POST',
                 -name=>'wdatc024',
                 -action=>$action, "\n",
                 -onsubmit=>'return func_checa(1)'),"\n";
    }
 else
    { push @cabecalho,
      start_form(-method=>'POST',
                 -name=>'wdatc024',
                 -action=>$action,
                 -onsubmit=>'return func_checa(2)'),"\n";
    }
push @cabecalho,
hidden(-name=>'usrtip',
     -value=>$usrtip
    ),"\n",
hidden(-name=>'webusrcod',
       -value=>$webusrcod
      ),"\n",
hidden(-name=>'sesnum',
       -value=>$sesnum
      ),"\n",
hidden(-name=>'macsissgl',
       -value=>$macsissgl
      ),"\n",
hidden(-name=>'atdsrvnum',
       -value=>$atdsrvnum,
      ),"\n",
hidden(-name=>'atdsrvano',
       -value=>$atdsrvano,
      ),"\n",

@hidden;

#push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);
if ($ciaempcod == 1 || $ciaempcod == 40) {
    $image = "/corporat/images/logo_porto.gif";
    $nomeseg = "Porto Seguro";
} elsif ($ciaempcod == 35) {
    $image = "/corporat/images/logo_azul.gif";
    $nomeseg = "Azul";
}
   elsif ($ciaempcod == 84) {
    $image = "/corporat/images/logo_itau.gif";
    $nomeseg = "Itau";
}

push @cabecalho,
     center(
       table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'0'},"\n",
             Tr(
                td(img {-src=>$image,-width=>'173',-height=>'18',-alt=>$nomeseg},
                   img {-src=>$titgif,-alt=>'Porto Socorro'}
                  ),"\n",
                td({-align=>'right',-valign=>'bottom'},
                    img {-src=>'/corporat/images/blue_box.gif',-width=>'36',-height=>'16'}
                  ),"\n",
               ),"\n",
             Tr(
                td({-height=>'1',-colspan=>'2',-bgcolor=>'#000000'},
                     img {-src=>'/corporat/images/img_transp.gif',-width=>'550',-height=>'1'}
                  ),"\n",
               ),"\n",
             Tr(
                td(img {-src=>'/corporat/images/img_transp.gif',-width=>'180',-height=>'14',-border=>'0'},
                   font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},b($cabec))
                  ),"\n",
               ),"\n",

             Tr(
                td(img {-src=>'/corporat/images/img_transp.gif',-width=>'180',-height=>'14',-border=>'0'},
                  ),"\n",
               ),"\n",

             Tr(
                td({-align=>'left'},
                   font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},$texto),"\n"
                       ),"\n",
                  ),"\n",

            ),"\n",
           ),br,"\n";
#PSI 208264

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 if ($acao eq 'Aceitar'|| $acao eq 'Recusar')
    { push @rodape, &wissc211_rodape("BACK",3); }

 elsif ($acao eq  'Reservar' || $acao eq 'Emitir' || $acao eq "Enviar")
       { push @rodape, &wissc211_rodape("","05");}
 else
      {
        push @botoes, br(), "\n", br(), "\n",
        table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
        Tr(td(@botao, reset(-name=>' Limpar  '),
        "\n"), "\n"), "\n"), "\n";

        push @rodape, &wissc211_rodape("BACK",0);
      }

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------
 push @html, @cabecalho,
 center( @body, @botoes, @rodape),"\n",

 end_form,"\n",
 end_html,"\n";

 print @html;

 exit(0);


#-----------------------------------------------------------------------------
 sub debugar()
#-----------------------------------------------------------------------------
 {
   print "Content-type: text/html\n\n";
   print "*** PARAMETROS WISSC201.PL ***  <br>\n";

 # print "Padrao 0  = $REGISTRO[0]       <br>\n";
 # print "Padrao 1  = $REGISTRO[1]       <br>\n";
 # print "Padrao 2  = $REGISTRO[2]       <br>\n";
 # print "Padrao 3  = $REGISTRO[3]       <br>\n";
 # print "Padrao 4  = $REGISTRO[4]       <br>\n";
 # print "Padrao 5  = $REGISTRO[5]       <br>\n";
 # print "Padrao 6  = $REGISTRO[6]       <br>\n";
 # print "Padrao 7  = $REGISTRO[7]       <br>\n";
 # print "Padrao 8  = $REGISTRO[8]       <br>\n";

 # foreach $texto (keys (%ENV))
 #   {
 #     print "$texto = $ENV{$texto}  <br>\n";
 #   }

   foreach $texto (keys (%INC))
     {
       print "$texto = $INC{$texto}  <br>\n";
     }

   exit(0);
 }


