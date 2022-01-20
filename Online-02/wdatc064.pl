#!/usr/bin/perl
#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc064.pl                                               #
#                  Disponibilizar informacoes sobre servicos bloqueados no   #
#                  portal de negocios                                        #
# Analista Resp. : Carlos Zyon                                               #
# PSI            : 177890 -                                                  #
# OSF            : 29521  -                                                  #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Alexandre Figueiredo                #
# Liberacao      :                                                           #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 04/07/2007 Luiz, Meta    AS143650  Retirada do teste da identificacao do   #
#                                    ambiente                                #
#----------------------------------------------------------------------------#

use CGI ":all";
use strict;
use ARG4GL;

#-----------------------------------------------------------------------------
# Declara variaveis
#-----------------------------------------------------------------------------

my (
   $maq,
  #$ambiente,
   $cabec,
   $texto,
   $titgif,
   $ARG,
   $prog,
   @body,
   @corpo,
   @adicionais,
   @ARG,
   @REGISTRO,
   @impressao,
   @telaImpr,
   %parametros
   );

#$ambiente = "remsh aplweb01 -l runwww ";

#-----------------------------------------------------------------------------
# Inclusao das subrotinas que montam campos, textos, botoes, etc.
#-----------------------------------------------------------------------------
require "/webserver/cgi-bin/seweb/trs/wissc203.pl";     #--> Gera titulo
require "/webserver/cgi-bin/seweb/trs/wissc207.pl";     #--> Gera Texto/Input/Texto
require "/webserver/cgi-bin/seweb/trs/wissc208.pl";     #--> Gera Coluna
require "/webserver/cgi-bin/seweb/trs/wissc209.pl";     #--> Gera titulo com help
require "/webserver/cgi-bin/seweb/trs/wissc210.pl";     #--> Gera cabecalho da pagina
require "/webserver/cgi-bin/seweb/trs/wissc211.pl";     #--> Gera rodape da pagina
require "/webserver/cgi-bin/seweb/trs/wissc212.pl";     #--> Gera tabela com varias linhas
require "/webserver/cgi-bin/seweb/trs/wissc218.pl";     #--> Vetores de conversao
require "/webserver/cgi-bin/seweb/trs/wissc219.pl";     #--> Gera pagina de mensagem/erro
require "/webserver/cgi-bin/seweb/trs/wissc220.pl";     #--> Checa erro no programa 4GL/BD
require "/webserver/cgi-bin/seweb/trs/wissc225.pl";     #--> Gera colunas/tabelas
					   #--> para versa o de impressao

#-----------------------------------------------------------------------------
# Carrega parametros recebidos e de padroes
#-----------------------------------------------------------------------------
%parametros = &getParametros();

if ($parametros{modulo} eq 'wdatc061') {
   $cabec = "SERVIÇOS EM ANÁLISE";
}

if ($parametros{modulo} eq 'wdatc063') {
   $cabec = "SERVIÇOS ANALISADOS";
}

$titgif = "/auto/images/ramo_psocorro.gif";

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
#my ($servnum, $servano) = split('-', $parametros{numserv});

push @ARG ,$parametros{usrtip},
	   $parametros{webusrcod},
	   $parametros{sesnum},
	   $parametros{macsissgl},
#          $servnum,
#          $servano,
	   $parametros{atdsrvnum},
	   $parametros{atdsrvano},
	   $parametros{acao};

#OSF 20370
if ($parametros{acao} eq '2') {
  $texto  = "";
} else {
  $texto  = "Informações detalhadas sobre o serviço.";
}

print @ARG;

$ARG = sprintf("'%s'",join('\' \'',@ARG));

$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; DBMONEY=,;export DBMONEY;/webserver/cgi-bin/ct24h/trs/wdatc017.4gc $ARG 2>&1; wdatc065.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

while (<PROG>) {
    #--------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------
    &wissc220_veriferro($_, $parametros{macsissgl});
    chomp;

      @REGISTRO = split ('@@');

      if ($REGISTRO[0] eq "PADRAO") {
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
	      { push @telaImpr  , &wissc225_colunaimpressao(@REGISTRO); }

      } elsif ($REGISTRO[0] eq "IMPOK") {
	push @impressao,
	    "<input type='button' name='btnImp' value='Imprimir' onclick='doImpressao()'>",
	    "<script language='JavaScript'>",
		"function doImpressao() {",

		   #"var strPagina = '/cgi-bin/ct24h/trs/wdatc041.pl?usrtip=$parametros{usrtip}&webusrcod=$parametros{webusrcod}&sesnum=$parametros{sesnum}&macsissgl=$parametros{macsissgl}&atdsrvnum=$servnum&atdsrvano=$servano&acao=2';",

		    "var strPagina = '/cgi-bin/ct24h/trs/wdatc041.pl?usrtip=$parametros{usrtip}&webusrcod=$parametros{webusrcod}&sesnum=$parametros{sesnum}&macsissgl=$parametros{macsissgl}&atdsrvnum=$parametros{atdsrvnum}&atdsrvano=$parametros{atdsrvano}&acao=2';",
		    "var strNavparam = 'height=400,width=650,left=50,top=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
		    "if (navigator.appName.indexOf('Netscape') != -1) {",
		    "    strNavparam = 'Impressao','height=400,width=650,screenX=50,screenY=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
		    "}",
		    "janela=window.open(strPagina,'Impressao',strNavparam);",
		"}",
	    "</script>";

      } elsif ($REGISTRO[0] eq "ERRO") {
	  &wissc219_mensagem($titgif,$cabec,$_[2],$_[1]);
	  exit(0);

      } elsif ($REGISTRO[0] eq "NOSESS") {
	  &wissc219_mensagem($titgif,$cabec,"LOGIN",$REGISTRO[1]);
	  exit(0);

      } elsif ($REGISTRO[0] eq "ADICIONAIS") {
	  push @adicionais, montar_adicionais_linha(@REGISTRO);
      }
    else {
	 $_ =~ s/\ //g;
	 if ($_ ne "")
	    {
	    #&wissc219_mensagem($titgif,$cabec,"BACK","Trata outro tipo de registro! <br><br>" . $_);
	    }
	 }
}
close (PROG);

my (@rodape);

#-----------------------------------------------------------------------------
# Montando rodape variavel (parte final do fonte HTML)
#-----------------------------------------------------------------------------
push @rodape, &wissc211_rodape("BACK",0);

print header,
      start_html(-title=>'Porto Seguro',
		 -bgcolor=>'#FFFFFF'),
      center
      (
	start_form(-action=>'wdatc039.pl',
		   -method=>'post',
		   -name=>'wdatc041'),
	 &wissc210_cabecalho($titgif,$cabec,$texto),
	    @body,
	 @rodape,
	end_form
      ),
      end_html;

#-----------------------------------------------------------------------------
sub getParametros() {
#-----------------------------------------------------------------------------
    my (%paramTemp);

    foreach (param) {
	if (!exists($paramTemp{$_})) {
	    $paramTemp{$_} = param($_);
	}
#        print $_ . "=>" . $paramTemp{$_} . br();
    }
    return %paramTemp;
}

#------------------------------------------------------------------------
sub rodape_btn_imprimir() {
#------------------------------------------------------------------------

my (@impr) = @_;

return "
 <br>
 <br>
 <input type=hidden name=sesnum value='$parametros{sesnum}'>
 <input type=hidden name=webusrcod value='$parametros{webusrcod}'>
 <input type=hidden name=usrtip value='$parametros{usrtip}'>
 <input type=hidden name=macsissgl value='$parametros{macsissgl}'>
 <input type=hidden name=numop value='$parametros{numop}'>
 <input type=hidden name=situacao value='$parametros{situacao}'>
 <input type=hidden name=dataent value='$parametros{dataent}'>
 <input type=hidden name=datapgt value='$parametros{datapgt}'>
 <input type=hidden name=datanfs value='$parametros{datanfs}'>
 <input type=hidden name=qtdserv value='$parametros{qtdserv}'>
 <input type=hidden name=vlrtot value='$parametros{vlrtot}'>
 <table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><input type='submit' name='btoSubmit' onClick='JavaScript:document.forms[0].action = \"wdatc036.pl\";document.forms[0].submit();' value='Nova Consulta'>@impr
</td></tr></table>
<br>
<table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><a href='J
avaScript:history.back()'><img border='0' width='79' height='15' src='/corporat/
images/bot_voltar.gif'></a></td> <td valign='bottom' align='right'><img width='3
6' height='16' src='/corporat/images/blue_box.gif'></td></tr> <tr><td align='rig
ht' colspan='2'><img width='550' height='1' src='/corporat/images/linha_azul.gif
'></td>
</tr>
</table>
";

}