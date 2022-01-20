#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc076.pl                                                    #
#  Sistema..: Prestador On Line PSRONLINE                                    #
#  Criacao..: Mar/2006                                                       #
#  Autor....: Ligia Mattge                                                   #
#                                                                            #
#  Objetivo.: Preencher informacoes da passagem aerea                        #
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
require "/webserver/cgi-bin/seweb/trs/wissc229.pl";     #--> Gera tabela

#-----------------------------------------------------------------------------
# Definicao das variaveis
#-----------------------------------------------------------------------------
my(  $maq,
    #$ambiente,
     $cabec,
     $titgif,
     $padrao,
     $texto,
     $prog,
     $line,
     $opc,
     $ARG,
     $webusrcod,
     $sesnum,
     $macsissgl,
     $usrtip,
     $atdsrvnum,
     $atdsrvano,
     $acao,
     $funcao,
     $programa,
     $JSCRIPT,
     @botao,
     @botoes,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape,
     @impressao,
     @hidden,
     $atdprvdat,
     $srvobs,
     $txivlr,
     $aerciacod,
     $trpaervoonum,
     $trpaerptanum,
     $trpaerlzdnum,
     $adlpsgvlr,
     $crnpsgvlr,
     $totpsgvlr,
     $ufdcodemb,
     $arpembcod,
     $trpaersaidat,
     $trpaersaihor,
     $ufdcodche,
     $arpchecod,
     $trpaerchedat,
     $trpaerchehor,
     $vooopc,
     $voocnxseq
  );

#$ambiente = "remsh aplweb01 -l runwww ";

#-----------------------------------------------------------------------------
# Carregando parametros recebidos
#-----------------------------------------------------------------------------

$titgif = '/seweb/images/c_acesso.gif';
$titgif = '/auto/images/ramo_psocorro.gif';

$webusrcod = param("webusrcod");
$sesnum    = param("sesnum");
$macsissgl = param("macsissgl");
$usrtip    = param("usrtip");
$atdsrvnum = param("atdsrvnum");
$atdsrvano = param("atdsrvano");
$acao      = param("Acao");
$atdprvdat = param("atdprvdat");
$srvobs    = param("srvobs");
$txivlr    = param("txivlr");
$aerciacod     = param("aerciacod");
$trpaervoonum  = param("trpaervoonum");
$trpaerptanum  = param("trpaerptanum");
$trpaerlzdnum  = param("trpaerlzdnum");
$adlpsgvlr  = param("adlpsgvlr");
$crnpsgvlr  = param("crnpsgvlr");
$totpsgvlr  = param("totpsgvlr");
$ufdcodemb  = param("ufdcodemb");
$arpembcod  = param("arpembcod");
$trpaersaidat  = param("trpaersaidat");
$trpaersaihor  = param("trpaersaihor");
$ufdcodche  = param("ufdcodche");
$arpchecod  = param("arpchecod");
$trpaerchedat  = param("trpaerchedat");
$trpaerchehor  = param("trpaerchehor");
$vooopc        = param("vooopc");
$voocnxseq     = param("voocnxseq");

if ($txivlr eq "") { $txivlr = "0" } ;
if ($acao eq "") { $acao = "X" } ;

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
function func_checa()
{
  var v_aux = '';
  if (document.wdatc076.aerciacod.value == "" || document.wdatc076.adlpsgvlr.value == "" || document.wdatc076.crnpsgvlr.value == "" || document.wdatc076.totpsgvlr.value == "" || document.wdatc076.totpsgvlr.value == "" || document.wdatc076.arpembcod.value == "" || document.wdatc076.trpaersaidat.value == "" || document.wdatc076.trpaersaihor.value == "" || document.wdatc076.arpchecod.value == "" || document.wdatc076.trpaerchedat.value == "" || document.wdatc076.trpaerchehor.value == "" )
          {
            v_aux = "Informe os dados. Todos os campos são de preenchimento obrigatório!";
            alert(v_aux);
            document.wdatc076.aerciacod.focus();
            return false;
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


function func_adlpsgvlr() {

    if (document.wdatc076.adlpsgvlr.value == "NaN" ||
        document.wdatc076.adlpsgvlr.value == "undefined" ||
        document.wdatc076.adlpsgvlr.value == "" ||
        document.wdatc076.adlpsgvlr.value == null ||
        document.wdatc076.adlpsgvlr.length == 0)  {
        alert("Informe o valor da passagem adulto!");
        document.wdatc076.adlpsgvlr.value = "";
        document.wdatc076.adlpsgvlr.focus();
        return false;
     }
    else {
       document.wdatc076.adlpsgvlr.value = funcValidaEntrada(document.wdatc076.adlpsgvlr.value);
       return true;
     }
}

function func_crnpsgvlr() {

    if (document.wdatc076.adlpsgvlr.value != "" ) {

    if (document.wdatc076.crnpsgvlr.value == "NaN" ||
        document.wdatc076.crnpsgvlr.value == "undefined" ||
        document.wdatc076.crnpsgvlr.value == "" ||
        document.wdatc076.crnpsgvlr.value == null ||
        document.wdatc076.crnpsgvlr.length == 0)  {
        alert("Informe o valor da passagem de crianca!");
        document.wdatc076.crnpsgvlr.value = "";
        document.wdatc076.crnpsgvlr.focus();
        return false;
     }
    else {
       document.wdatc076.crnpsgvlr.value = funcValidaEntrada(document.wdatc076.crnpsgvlr.value);
       return true;
     }
     }
}
function func_totpsgvlr() {

    if (document.wdatc076.crnpsgvlr.value != "" ) {

    if (document.wdatc076.totpsgvlr.value == "NaN" ||
        document.wdatc076.totpsgvlr.value == "undefined" ||
        document.wdatc076.totpsgvlr.value == "" ||
        document.wdatc076.totpsgvlr.value == null ||
        document.wdatc076.totpsgvlr.length == 0)  {
        alert("Informe o valor total da passagem!");
        document.wdatc076.totpsgvlr.value = "";
        document.wdatc076.totpsgvlr.focus();
        return false;
     }
    else {
       document.wdatc076.totpsgvlr.value = funcValidaEntrada(document.wdatc076.totpsgvlr.value);
       return true;
     }

     }
}

function func_saiDat() {
    document.wdatc076.trpaersaidat.value = func_val_data(document.wdatc076.trpaersaidat.value);

   if ( !datahoje()) {
       document.wdatc076.trpaersaidat.value = document.wdatc076.dtchegada.value;
       document.wdatc076.trpaersaidat.focus();
       return false;
   }

   dt1 = document.wdatc076.trpaersaidat.value.substring(6,10) +
         document.wdatc076.trpaersaidat.value.substring(3, 5) +
         document.wdatc076.trpaersaidat.value.substring(0, 2);

   dt2 = document.wdatc076.dtchegada.value.substring(6,10) +
         document.wdatc076.dtchegada.value.substring(3, 5) +
         document.wdatc076.dtchegada.value.substring(0, 2);

   if (document.wdatc076.voocnxseq.value > 1 ) {
       if (dt1 < dt2) {
          alert("Data de embarque nao confere com a data da chegada anterior");
          document.wdatc076.trpaersaidat.value =
                   document.wdatc076.dtchegada.value;
          document.wdatc076.trpaersaidat.focus();
          return false;
       }
   }

   return true;

}

function func_saiHor() {
    document.wdatc076.trpaersaihor.value = func_val_hora(document.wdatc076.trpaersaihor.value);
   if (!horahoje(document.wdatc076.trpaersaidat.value,
                 document.wdatc076.trpaersaihor.value))
      { document.wdatc076.trpaersaihor.value = "";
        return false; }
   else {
         document.wdatc076.trpaersaihor.value =
                  document.wdatc076.trpaersaihor.value.substring(0,2) + ":" +
                  document.wdatc076.trpaersaihor.value.substring(2,4);
       }

   dt1 = document.wdatc076.trpaersaidat.value.substring(6,10) +
         document.wdatc076.trpaersaidat.value.substring(3, 5) +
         document.wdatc076.trpaersaidat.value.substring(0, 2);

   hr1 = document.wdatc076.trpaersaihor.value.substring(0,2) +
         document.wdatc076.trpaersaihor.value.substring(2,4);

   dt2 = document.wdatc076.dtchegada.value.substring(6,10) +
         document.wdatc076.dtchegada.value.substring(3, 5) +
         document.wdatc076.dtchegada.value.substring(0, 2);

   hr2 = document.wdatc076.hrchegada.value.substring(0,2) +
         document.wdatc076.hrchegada.value.substring(2,4);

   if (dt1 == dt2) {
       if (hr1 <= hr2 && document.wdatc076.voocnxseq.value > 1) {
          alert("Hora de embarque nao confere com a hora da chegada anterior");
          document.wdatc076.trpaersaihor.value = "";
          document.wdatc076.trpaersaihor.focus();
          return false;
          }
          else { return true;  }
   }
   else { return true;  }

   return false;
}

function func_cheDat() {
    document.wdatc076.trpaerchedat.value = func_val_data(document.wdatc076.trpaerchedat.value);

   if ( !datahoje()) {
       document.wdatc076.trpaerchedat.value = "";
       document.wdatc076.trpaerchedat.focus();
   }
   else {
      if ( !datDeMenorIgual()) {
          document.wdatc076.trpaerchedat.value = "";
          document.wdatc076.trpaerchedat.focus();
      }
   }
}

function func_cheHor() {
    document.wdatc076.trpaerchehor.value = func_val_hora(document.wdatc076.trpaerchehor.value);

   if ( !horDeMenorIgual()) {
       if (document.wdatc076.trpaersaidat.value ==
           document.wdatc076.trpaerchedat.value)  {
           document.wdatc076.trpaerchehor.value = "";
           alert("Hora de chegada menor ou igual a hora de embarque");
           document.wdatc076.trpaerchehor.focus();
       }
       else {
            document.wdatc076.trpaerchehor.value =
                  document.wdatc076.trpaerchehor.value.substring(0,2) + ":" +
                  document.wdatc076.trpaerchehor.value.substring(2,4);
           }
     }
   else {
         document.wdatc076.trpaerchehor.value =
                  document.wdatc076.trpaerchehor.value.substring(0,2) + ":" +
                  document.wdatc076.trpaerchehor.value.substring(2,4);
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
        hora = "";
        return hora;
       }

     for (i = hora.length; i < 4; i++) {
         hora = "0" + hora;
     }

 return hora;
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
 //     else {
  //       data = wiasc007_formataData(data);
   //   }
   }

         data = wiasc007_formataData(data);

  return data;
}

function datDeMenorIgual() {
   datsai = document.wdatc076.trpaersaidat.value.substring(6,10) +
            document.wdatc076.trpaersaidat.value.substring(3, 5) +
            document.wdatc076.trpaersaidat.value.substring(0, 2);
   datche = document.wdatc076.trpaerchedat.value.substring(6,10) +
            document.wdatc076.trpaerchedat.value.substring(3, 5) +
            document.wdatc076.trpaerchedat.value.substring(0, 2);

   if (datsai <= datche) {
      return true;
   }
   else {
      alert("Data de saida maior que data de chegada");
      return false;
   }
}

function datahoje() {
   dathoj = document.wdatc076.hoje.value.substring(6,10) +
            document.wdatc076.hoje.value.substring(3, 5) +
            document.wdatc076.hoje.value.substring(0, 2);
   datsai = document.wdatc076.trpaersaidat.value.substring(6,10) +
            document.wdatc076.trpaersaidat.value.substring(3, 5) +
            document.wdatc076.trpaersaidat.value.substring(0, 2);
   datche = document.wdatc076.trpaerchedat.value.substring(6,10) +
            document.wdatc076.trpaerchedat.value.substring(3, 5) +
            document.wdatc076.trpaerchedat.value.substring(0, 2);

   if (datsai < dathoj || datche < dathoj)
      { alert("Data menor que a data de hoje");
        return false; }

   return true;
}

function horahoje(data, hora) {

   data   = data.substring(6,10) +
            data.substring(3, 5) +
            data.substring(0, 2);
   dathoj = document.wdatc076.hoje.value.substring(6,10) +
            document.wdatc076.hoje.value.substring(3, 5) +
            document.wdatc076.hoje.value.substring(0, 2);

   horhoj = document.wdatc076.hora.value.substring(0, 2) + document.wdatc076.hora.value.substring(2, 4);

  if (dathoj == data)  {
      if (hora < horhoj)
         { alert("Hora menor que a hora de hoje");
           return false; }
  }

   return true;
}

function horDeMenorIgual() {
   horsai = document.wdatc076.trpaersaihor.value.substring(0, 2) +
            document.wdatc076.trpaersaihor.value.substring(3, 5);
   horche = document.wdatc076.trpaerchehor.value.substring(0, 2) +
            document.wdatc076.trpaerchehor.value.substring(2, 4);

       if (horsai <= horche || horsai == horche) {
          return true;
       }
       else { return false; }
}
END

# Montando parametros para o 4GL
#-------------------------------

   push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,
          $acao, $atdprvdat,$srvobs,$txivlr,
          $aerciacod, $trpaervoonum, $trpaerptanum, $trpaerlzdnum,
          $adlpsgvlr, $crnpsgvlr, $totpsgvlr,  $arpembcod, $trpaersaidat,
          $trpaersaihor, $arpchecod , $trpaerchedat, $trpaerchehor,
          $vooopc, $voocnxseq;

#-------------------------------
$ARG = sprintf("'%s'",join('\' \'',@ARG));

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
if ($acao eq "Enviar") {
    $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc027.4gc $ARG 2>&1)"; }
else {
    $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc076.4gc $ARG 2>&1)"; }

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

#-----------------------------------------------------------------------------
# Montando body variavel @body (parte central do fonte HTML)
#-----------------------------------------------------------------------------
while (<PROG>)
   {
    #--------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------
    &wissc220_veriferro($_, $macsissgl);
    chomp;

    @REGISTRO = split '@@',$_;
    if    ($REGISTRO[0] eq "NOSESS") { &wissc219_mensagem($titgif,$cabec,"LOGIN",$REGISTRO[1]); }
    elsif ($REGISTRO[0] eq "ERRO"  ) { &wissc219_mensagem($titgif,$cabec,"BACK", $REGISTRO[1]); }
    if ($REGISTRO[0] eq "PADRAO") {
        if    ($REGISTRO[1] ==  1) { push @body, &wissc203_titulo(@REGISTRO); }
        elsif ($REGISTRO[1] ==  2) { push @body, &wissc204_listbox(@REGISTRO); }
        elsif ($REGISTRO[1] ==  3) { push @body, &wissc205_checkbox(@REGISTRO); }
        elsif ($REGISTRO[1] ==  4) { push @body, &wissc206_radiobox(@REGISTRO); }
        elsif ($REGISTRO[1] ==  5) { push @body, &wissc207_textoinputtexto(@REGISTRO); }
        elsif ($REGISTRO[1] ==  6) { push @body, &wissc208_coluna(@REGISTRO); }
        elsif ($REGISTRO[1] ==  7) { push @body, &wissc209_titulohelp(@REGISTRO); }
        elsif ($REGISTRO[1] ==  8) { push @body, &wissc212_linhas1(@REGISTRO); }
        elsif ($REGISTRO[1] ==  9) { push @body, &wissc216_checklistbox(@REGISTRO); }
        elsif ($REGISTRO[1] == 10) { push @body, &wissc225_colunaimpressao(@REGISTRO); }
        elsif ($REGISTRO[1] == 11) { push @body, &wissc229_tabela(@REGISTRO); }
        else  { &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!"); }

   }

   if ($REGISTRO[0] eq "PADRAO2") {  push @body, $REGISTRO[1]; }

   if ($REGISTRO[0] eq "BOTAO")
          { $vooopc = $REGISTRO[2];
            $voocnxseq = $REGISTRO[3];
            push @botao, submit(-name=>"Acao",-value=>$REGISTRO[1]); }

   if ($REGISTRO[0] eq "HIDDEN")
          { push @hidden, $REGISTRO[1]; }
   if ($REGISTRO[0] eq "DATA")
          { push @hidden, $REGISTRO[1]; }

         ##$_ =~ s/\ //g;
         ##if ($_ ne "")
            ##{
            ##&wissc219_mensagem($titgif,$cabec,"BACK","Trata12 outro tipo de registro! <br><br>" . $_);
            ##}
}

close(PROG);

push @body,
    "<script language='JavaScript'>",
        "function doImpressao() {",
            "var strPagina = '/cgi-bin/ct24h/trs/wdatc016.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&atdsrvnum=$atdsrvnum&atdsrvano=$atdsrvano&acao=2';",
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

if ($acao eq 'Enviar')
   {
     $texto = '';
     push @cabecalho, header,
          start_html(-'title'=>'Porto Seguro',
                     ##-onLoad=>'doImpressao();',
                     -'meta'=>{'http-equiv=Pragma content=no-cache'},
                     -bgcolor=>'#FFFFFF'
                    ),"\n",
          start_form(-method=>'POST',
                     -name=>'wdatc076',
                     -action=>'/j2ee/atendcentral/jdatc014.do'
                     ),"\n";
    }
else
   {

      $cabec  = 'RECEBER SERVIÇOS - COTAR';
      $funcao = '';
      $texto  = 'Informe os dados dos vôos disponíveis.';
      ###$texto  = 'Informe os dados dos vôos disponíveis. Você pode cotar até 3 opções de vôo e até 3 conexões para cada opção de vôo:';

      push @cabecalho, header,

      start_html(-'title'=>'Porto Seguro',
                 -'script'=>$JSCRIPT,
                 -onLoad=>$funcao,
                 -bgcolor=>'#FFFFFF',
                ),"\n",
        "<script language='JavaScript' src='/geral/trs/wiasc007.js'></script>";

      push @cabecalho, start_form(-method=>'POST',
                 -name=>'wdatc076',
                 -onsubmit=>'return func_checa()',"\n",
                 -action=>"/cgi-bin/ct24h/trs/wdatc076.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&atdsrvnum=$atdsrvnum&atdsrvano=$atdsrvano&vooopc=$vooopc&voocnxseq=$voocnxseq"

                 ###-action=>"/cgi-bin/ct24h/trs/wdatc076.pl?usrtip=%s&webusrcod=%d&sesnum=%d&macsissgl=%s&atdsrvnum=%d&atdsrvano=%d&vooopc=%s&voocnxseq=%s&,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$vooopc,$voocnxseq"
                 ), "\n";

   }

push @cabecalho, hidden(-name=>'usrtip',
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
       -value=>$atdsrvnum
      ),"\n",

hidden(-name=>'atdsrvano',
       -value=>$atdsrvano
      ),"\n",

@hidden;

push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

#-----------------------------------------------------------------------------
# Montando rodape variavel (parte final do fonte HTML)
#-----------------------------------------------------------------------------
if ($acao eq 'Enviar')
   { push @rodape, &wissc211_rodape("","05");  }
else
   {
     push @botoes, br(), "\n", br(), "\n",
         table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
         Tr(td(@botao, reset(-name=>' Limpar  '), "\n"), "\n"), "\n"), "\n";
     push @rodape, &wissc211_rodape("BACK",0);
   }

#-----------------------------------------------------------------------------
# Agrupa componentes do HTML e envia para o browser
#-----------------------------------------------------------------------------

push @html, @cabecalho,
center(@body, @botoes, @rodape),"\n",
end_form,"\n",
end_html,"\n";
print @html;
exit(0);

#-----------------------------------------------------------------------------
sub debugar() {
    print "Content-type: text/html\n\n";
    print "*** PARAMETROS WISSC201.PL ***  <br>\n";
    foreach $texto (keys (%INC)) { print "$texto = $INC{$texto}  <br>\n"; }
    exit(0);
}
