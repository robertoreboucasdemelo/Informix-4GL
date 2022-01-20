#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc048.pl                                                    #
#  Sistema..: Prestador OnLine                                               #
#  Criacao..: Mar/2003                                                       #
#  Autor....: Zyon                                                           #
#                                                                            #
#  Objetivo.: Relação de serviços não analisados para acerto de valores      #
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
#my ($ambiente,
my ($arg,
    $cabec,
    $jscript,
    $macsissgl,
    $maq,
    $prog,
    $sesnum,
    $texto,
    $titgif,
    $usrtip,
    $webusrcod,
    $atdsrvnum,
    $atdsrvano,
    $c24pbmgrpcod,
    $ufdcod,
    $combovar,
    $bottom,
    $voltar,
    @arg,
    @body,
    @cabecalho,
    @html,
    @registro,
    @rodape,
    @combo
   );

#$ambiente = "remsh aplweb01 -l runwww ";

$usrtip         = param("usrtip");
$webusrcod      = param("webusrcod");
$sesnum         = param("sesnum");
$macsissgl      = param("macsissgl");
$atdsrvnum      = param("atdsrvnum");
$atdsrvano      = param("atdsrvano");
$c24pbmgrpcod   = param("c24pbmgrpcod");
$ufdcod         = param("ufdcod");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @arg,
     $usrtip,
     $webusrcod,
     $sesnum,
     $macsissgl,
     $atdsrvnum,
     $atdsrvano,
     $c24pbmgrpcod,
     $ufdcod;

#-----------------------------------------------------------------------------
# Carregando parametros recebidos
#-----------------------------------------------------------------------------
$cabec  = 'ACERTO DE VALORES';
$titgif = '/auto/images/ramo_psocorro.gif';

$arg = sprintf("'%s'",join('\' \'',@arg));

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e trata os displays
#-----------------------------------------------------------------------------
$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc049.4gc $arg 2>&1)";

###push @body, $prog;

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

#-----------------------------------------------------------------------------
# Montando body variavel @body (parte central do fonte HTML)
#-----------------------------------------------------------------------------
###while (0>1) {

$combovar = 0;
while (<PROG>) {
    #--------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------
    &wissc220_veriferro($_, $macsissgl);
    chomp;

    @registro = split '@@',$_;

    if ($registro[0] eq "NOSESS") {
        &wissc219_mensagem($titgif,$cabec,"LOGIN",$registro[1]);
    } elsif ($registro[0] eq "ERRO") {
        &wissc219_mensagem($titgif,$cabec,"BACK" ,$registro[1]);
    }


    if ($registro[0] eq "ABRIRCOMBO") {
        $registro[0] =~ s/ABRIRCOMBO/PADRAO/;
        push @combo, @registro;
        $combovar = 1;
        next;
    }

    if ($registro[0] eq "FECHARCOMBO") {
        @registro = @combo;
        $combovar = 0;
    }

    if ($combovar) {
        push @combo, @registro;
        next;
    }

    if ($registro[0] eq "PADRAO") {
        if ($registro[1] == 1) {
            push @body, &wissc203_titulo(@registro);
        } elsif ($registro[1] == 2) {
            push @body, &wissc204_listbox(@registro);
        } elsif ($registro[1] == 3) {
            push @body, &wissc205_checkbox(@registro);
        } elsif ($registro[1] == 4) {
            push @body, &wissc206_radiobox(@registro);
        } elsif ($registro[1] == 5) {
            push @body, &wissc207_textoinputtexto(@registro);
        } elsif ($registro[1] == 6) {
            push @body, &wissc208_coluna(@registro);
        } elsif ($registro[1] == 7) {
            push @body, &wissc209_titulohelp(@registro);
        } elsif ($registro[1] == 8) {
            push @body, &wissc212_linhas1(@registro);
        } elsif ($registro[1] == 9) {
            push @body, &wissc216_checklistbox(@registro);
        } elsif ($registro[1] == 10) {
            push @body, &wissc225_colunaimpressao(@registro);
        } elsif ($registro[1] == 11) {
            push @body, &wissc229_tabela(@registro);
        } else {
            &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!");
        }
   } elsif ($registro[0] eq "HIDDEN") {
       push @body, $registro[1];
   } elsif ($registro[0] eq "TEXTO") {
       $texto = $registro[1];
   }
    else {
         $_ =~ s/\ //g;
         if ($_ ne "")
            {
            &wissc219_mensagem($titgif,$cabec,"BACK","Trata outro tipo de registro! <br><br>" . $_);
            }
         }
}

close(PROG);

#-----------------------------------------------------------------------------
# Montando cabecalho (parte inicial do fonte HTML)
#-----------------------------------------------------------------------------

$jscript=<<END;
    function funcValidaForm() {
        var v_aux = '';
        if (document.wdatc048.c24pbmcod.value < 0) {
            v_aux +="Escolha um detalhe de problema !\\n";
        }
        /*if (document.wdatc048.cidcod.value <= 0 ) {
            v_aux += "Escolha uma cidade de destino !\\n";
        }*/
        if (document.wdatc048.Q01.value == "undefined" ||
            document.wdatc048.Q02.value == "undefined" ||
            document.wdatc048.Q03.value == "undefined" ||
            document.wdatc048.Q04.value == "undefined" ||
            document.wdatc048.Q05.value == "undefined" ||
            document.wdatc048.Q06.value == "undefined" ||
            document.wdatc048.Q07.value == "undefined" ||
            document.wdatc048.Q08.value == "undefined" ||
            document.wdatc048.Q09.value == "undefined" ||
            document.wdatc048.Q10.value == "undefined" ||
            document.wdatc048.V01.value == "undefined" ||
            document.wdatc048.V02.value == "undefined" ||
            document.wdatc048.V03.value == "undefined" ||
            document.wdatc048.V04.value == "undefined" ||
            document.wdatc048.V05.value == "undefined" ||
            document.wdatc048.V06.value == "undefined" ||
            document.wdatc048.V07.value == "undefined" ||
            document.wdatc048.V08.value == "undefined" ||
            document.wdatc048.V09.value == "undefined" ||
            document.wdatc048.V10.value == "undefined") {
            v_aux += "Digite apenas valores numéricos !\\n";
        }
        if (document.wdatc048.Q99 != undefined){
            if (document.wdatc048.pdgelt[0].checked == false &&
                document.wdatc048.pdgelt[1].checked == false) {
                v_aux += "Informe se foi utilizado Pedágio Eletrônico Porto !\\n";
            } else {
                if (document.wdatc048.pdgelt[0].checked &&
                   (document.wdatc048.Q99.value == "" ||
                    document.wdatc048.V99.value == "" ||
                    document.wdatc048.Q99.value == "0,00" ||
                    document.wdatc048.V99.value == "0,00")) {
                    v_aux += "Informe a quantidade e valor do Pedágio Eletrônico Porto !\\n";
                }
            }
        }
        if (v_aux != "") {
            alert( v_aux );
            document.wdatc048.c24pbmcod.focus();
            return false;
        } else {
            document.wdatc048.submit();
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
    function funcValidaQ01() {document.wdatc048.Q01.value = funcValidaEntrada(document.wdatc048.Q01.value);}
    function funcValidaQ02() {document.wdatc048.Q02.value = funcValidaEntrada(document.wdatc048.Q02.value);}
    function funcValidaQ03() {document.wdatc048.Q03.value = funcValidaEntrada(document.wdatc048.Q03.value);}
    function funcValidaQ04() {document.wdatc048.Q04.value = funcValidaEntrada(document.wdatc048.Q04.value);}
    function funcValidaQ05() {document.wdatc048.Q05.value = funcValidaEntrada(document.wdatc048.Q05.value);}
    function funcValidaQ06() {document.wdatc048.Q06.value = funcValidaEntrada(document.wdatc048.Q06.value);}
    function funcValidaQ07() {document.wdatc048.Q07.value = funcValidaEntrada(document.wdatc048.Q07.value);}
    function funcValidaQ08() {document.wdatc048.Q08.value = funcValidaEntrada(document.wdatc048.Q08.value);}
    function funcValidaQ09() {document.wdatc048.Q09.value = funcValidaEntrada(document.wdatc048.Q09.value);}
    function funcValidaQ10() {document.wdatc048.Q10.value = funcValidaEntrada(document.wdatc048.Q10.value);}
    function funcValidaV01() {document.wdatc048.V01.value = funcValidaEntrada(document.wdatc048.V01.value);}
    function funcValidaV02() {document.wdatc048.V02.value = funcValidaEntrada(document.wdatc048.V02.value);}
    function funcValidaV03() {document.wdatc048.V03.value = funcValidaEntrada(document.wdatc048.V03.value);}
    function funcValidaV04() {document.wdatc048.V04.value = funcValidaEntrada(document.wdatc048.V04.value);}
    function funcValidaV05() {document.wdatc048.V05.value = funcValidaEntrada(document.wdatc048.V05.value);}
    function funcValidaV06() {document.wdatc048.V06.value = funcValidaEntrada(document.wdatc048.V06.value);}
    function funcValidaV07() {document.wdatc048.V07.value = funcValidaEntrada(document.wdatc048.V07.value);}
    function funcValidaV08() {document.wdatc048.V08.value = funcValidaEntrada(document.wdatc048.V08.value);}
    function funcValidaV09() {document.wdatc048.V09.value = funcValidaEntrada(document.wdatc048.V09.value);}
    function funcValidaV10() {document.wdatc048.V10.value = funcValidaEntrada(document.wdatc048.V10.value);}
    function funcValidaV99() {document.wdatc048.V99.value = funcValidaEntrada(document.wdatc048.V99.value);}

   function formatarVlrPri(campo) {
       var fim;
       var ret;
       var ini;

       var ind = campo.lastIndexOf(',');

       if (ind > 0) {
           fim = campo.substring(ind+1);
           ini = campo.substring(0,ind);
       } else {
           ini = campo;
	   fim = "";
       }
       var ini2 = "";
       for (i=0;i<ini.length;i++) {
            if (ini.charAt(i) == '.' ||
	        ini.charAt(i) == ',') {
	        continue;
	    }
	    ini2 += ini.charAt(i);
       }

       if (fim == "") {
           fim = "00";
       }
       if (ini2 == "") {
           ini2 = "0";
       }
       return new Array(ini2, fim);
   }

   function formatarValor(campo, milhar, moeda) {
     var ret = formatarVlrPri(campo);

     if (milhar != "undefined" && milhar ) {
     	var ini3 = "";
	var cont = 0;
	for (i=ret[0].length-1;i>=0;i--){

             if (cont == 3) {
	         ini3 = "." + ini3;
	         cont = 0;
	     }
	     ini3 = ret[0].charAt(i) + ini3;
             cont++;
        }
	ret[0] = ini3;
     }
     if (moeda && moeda != "") {
         ret[0] = moeda + " " + ret[0];
     }
     return ret[0] + "," + ret[1];
   }

   function formatarValorFloat(campo) {
     var ret = formatarVlrPri(campo);
     return parseFloat(ret[0] + "." + ret[1]);
   }

    function somenteNumeros(evnt) {
        if (evnt.keyCode != 44 && (evnt.keyCode < 48 || evnt.keyCode > 57)) {
            return false;
        }
    }

END

push @body,

     table({-border         =>'0',
            -width          =>'550',
            -cellpadding    =>'0',
            -cellspacing    =>'1'},"\n",

     Tr(td({-align          =>'center',
            -bgcolor        =>'#D7E7F1',
            -width          =>'71%',
            -height         =>'100'},"\n",

     textarea(-name         =>'historico',
              -rows         =>5,
              -cols         =>64,
              -wrap         =>'virtual'),
              ),"\n"
           ),"\n",
        ),"\n";

push @cabecalho,

     header(-'expires'      =>'-1d',
            -'pragma'       =>'no-cache',
            -'cache-control'=>'no-store'),

     start_html(-'title'    =>'Porto Seguro',
                -'script'   =>$jscript,
                -bgcolor    =>'#FFFFFF',
                -'meta'     =>{'http-equiv=Pragma content=no-cache'}),

     start_form(-method     =>'POST',
                -name       =>'wdatc048',
                -action     =>"/webserver/cgi-bin/ct24h/trs/wdatc050.pl",
                -onsubmit   =>'return funcValidaForm()'),

     hidden(-name   =>'usrtip',
            -value  =>$usrtip),

     hidden(-name   =>'webusrcod',
            -value  =>$webusrcod),

     hidden(-name   =>'sesnum',
            -value  =>$sesnum),

     hidden(-name   =>'macsissgl',
            -value  =>$macsissgl),

     hidden(-name   =>'atdsrvnum',
            -value  =>$atdsrvnum),

     hidden(-name   =>'atdsrvano',
            -value  =>$atdsrvano);

push @cabecalho,
     &wissc210_cabecalho($titgif,$cabec,$texto);

#-----------------------------------------------------------------------------
# Montando rodape variavel (parte final do fonte HTML)
#-----------------------------------------------------------------------------
#push @rodape, &wissc211_rodape("BACK",3);

$bottom = "<br><br><table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><input type='button' name='btoSubmit' value='  Enviar ' onclick=javascript:funcValidaForm();> <input type='reset' value=' Limpar  '></td></tr></table><br><table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><a href='JavaScript:history.back()'><img border='0' width='79' height='15' src='/corporat/images/bot_voltar.gif'></a></td> <td valign='bottom' align='right'><img width='36' height='16' src='/corporat/images/blue_box.gif'></td></tr><tr><td align='right' colspan='2'><img width='550' height='1' src='/corporat/images/linha_azul.gif'></td></tr></table><br>";

push @rodape, $bottom;

#-----------------------------------------------------------------------------
# Agrupa componentes do HTML e envia para o browser
#-----------------------------------------------------------------------------
push @html,
     @cabecalho,
     center(@body,@rodape),
     end_form,
     end_html;

print @html;

exit(0);

