#!/usr/bin/perl
#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc037.pl                                               #
#                  Opcoes iniciais para a pesquisa                           #
# Analista Resp. : Carlos Pessoto                                            #
# PSI            : 163759 -                                                  #
# OSF            : 5289   -                                                  #
#............................................................................#
# Desenvolvimento: Fabrica de Software - Ronaldo Marques                     #
# Liberacao      : 26/06/2003                                                #
#............................................................................#
#                          * * *  ALTERACOES  * * *                          #
#                                                                            #
# Data        Autor Fabrica  Data   Alteracao                                #
# ----------  -------------  ------ -----------------------------------------#
# 02/06/2003  R. Santos             Alteracao no layout das telas.           #
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
   $impressao,
   @impressao,
   @body,
   @cabecalho,
   @tela,
   @ARG,
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

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
push @ARG ,$parametros{usrtip},
           $parametros{webusrcod},
           $parametros{sesnum},
           $parametros{macsissgl},
           $parametros{dataini},
           $parametros{datafnl},
           $parametros{situacao};


#OSF 20370
if ($parametros{acao} == 2) {
   $cabec = "";
   $titgif = "/corporat/images/barra.gif";
   $texto = "";
} else {
   $cabec = "ORDENS DE PAGAMENTO";
   $titgif = "/auto/images/ramo_psocorro.gif";
   $texto  = "Para consultar as suas ordens de pagamento, clique sobre o número da OP.";
}

$ARG = sprintf("'%s'",join('\' \'',@ARG));

$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; DBMONEY=,; export DBMONEY;/webserver/cgi-bin/ct24h/trs/wdatc038.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

while (<PROG>) {
      chomp;

      split ('@@');

      if (@_[0] eq "PADRAO") {
          if (@_[1] == 1)
              { push @tela, &wissc203_titulo(@_); }
          elsif (@_[1] == 6)
              { push @tela, &wissc208_coluna(@_); }
          elsif (@_[1] == 10)
              { push @impressao, &wissc225_colunaimpressao(@_); }

      } elsif (@_[0] eq "ERRO") {
         &wissc219_mensagem($titgif,$cabec,$_[2],$_[1]);
         exit(0);
      }
}

close (PROG);

my $onload = "";
my @rodape ;
my $hoje;
push @rodape,
     &rodape_btn_imprimir();
if ($parametros{acao} == "2") {
    @tela = ();
    @rodape = ();
    push @tela , @impressao;
    $onload = "JavaScript:self.print()";
    push @rodape, rodape_fechar_impressao();

    $hoje = `date '+%d/%m/%Y \340s %H:%Mh'`;

    push @body,
         header,
         start_html(-title=>'Porto Seguro',
                    -bgcolor=>'#FFFFFF',
                    -onload=>"$onload"),
         center(
                 table({-border=>'0',-width=>'550',-cellpadding=>"0",-cellspacing=>"0"},
                      Tr(
                          td('&nbsp'),"\n",
                        ),
                      Tr(
                          td({-align=>'right'}, font({-face=>'Arial,Helvetica,Verdana',-size=>'1',-color=>'#000000'}, 'Em ',$hoje)
                            ),"\n",
                        ),
                      Tr(
                          td({-align=>'top'}, img{-src=>'/corporat/images/barra.gif',-width=>'550',-height=>'5'}
                            )
                        )
                      ),
                  table({-border=>'0'},
                      Tr(
                          td({-align=>'left',-valign=>'top'},
                              img {-src=>'/corporat/images/logo.gif'}
                            ),"\n",
                          td({-align=>'left',-valign=>'top'},
                             font({-face=>'Arial,Helvetica,Verdana',-size=>'3',-color=>'#000000'}, '<b>Porto Socorro</b>')
                            ),"\n",
                          td('&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp', '&nbsp',
                             '&nbsp', '&nbsp', '&nbsp', '&nbsp'
                            ),"\n",
                        ),
                      Tr(
                          td('&nbsp'),"\n",
                        )
                      )
               ),
          @tela,
          center(
                  table({-border=>'0',-width=>'550',-cellpadding=>"0",-cellspacing=>"0"},
                       Tr(
                          td('&nbsp'),"\n",
                         ),
                       Tr(
                           td('&nbsp'),"\n",
                         ),
                       Tr(
                         td({align=>'center'},
                            button(-name=>'fechar',
                                   -value=>'Fechar',
                                   -onClick=>'JavaScript:window.close();'
                                  )
                           ),"\n"
                         )
                       )
                );

} else {

  push @body,
       header,
       start_html(-title=>'Porto Seguro',
                  -bgcolor=>'#FFFFFF',
                  -onload=>"$onload"),
       center
       (
            &wissc210_cabecalho($titgif,$cabec,$texto),
            start_form(-action=>'dinamico',
                       -method=>'post',
                       -name=>'wdatc037'),
               @tela,
             @rodape,
           "<input type=hidden name=usrtip value='$parametros{usrtip}'>
            <input type=hidden name=webusrcod value='$parametros{webusrcod}'>
            <input type=hidden name=sesnum value='$parametros{sesnum}'>
            <input type=hidden name=macsissgl value='$parametros{macsissgl}'>",

            end_form()
       );
}

print @body;

print "
<script language=JavaScript>
<!--
function doImpressao() {

  var strPagina = 'wdatc037.pl?usrtip=$parametros{usrtip}&webusrcod=$parametros{webusrcod}&sesnum=$parametros{sesnum}&macsissgl=$parametros{macsissgl}&dataini=$parametros{dataini}&datafnl=$parametros{datafnl}&situacao=$parametros{situacao}&acao=2';

  var strNavparam = 'height=400,width=650,left=50,top=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';
  if (navigator.appName.indexOf('Netscape') != -1) {
      strNavparam = 'Impressao','height=400,width=650,screenX=50,screenY=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';
  }
  janela=window.open(strPagina,'Impressao',strNavparam);
}
-->
</script>
";

print end_html;

#-----------------------------------------------------------------------------
sub getParametros() {
#-----------------------------------------------------------------------------
    my (%paramTemp);

    foreach (param) {
        if (!exists($paramTemp{$_})) {
            $paramTemp{$_} = param($_);
        }
    }

    return %paramTemp;
}
#------------------------------------------------------------------------
sub rodape_btn_imprimir() {
#------------------------------------------------------------------------

return "
<br><br>
<table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><input type='button' name='btoSubmit' value='Nova Consulta' onClick='JavaScript:document.forms[0].action = \"wdatc036.pl\"; document.forms[0].submit();'> <input type='button' value='  Imprimir  ' onClick='JavaScript:doImpressao()'>
</td>
</tr>
</table>
 <br>
 <table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><a href='JavaScript:history.back()'><img border='0' width='79' height='15' src='/corporat/images/bot_voltar.gif'></a>
</td> <td valign='bottom' align='right'><img width='36' height='16' src='/corporat/images/blue_box.gif'></td>
</tr>
 <tr><td align='right' colspan='2'><img width='550' height='1' src='/corporat/images/linha_azul.gif'></td>
</tr>
</table>
 <br> ";
}

#------------------------------------------------------------------------
sub rodape_fechar_impressao() {
#------------------------------------------------------------------------

return "
  <br><br>
    <table border=1>
    <tr>
      <td align='center'><input type='button' name='fechar' value='Fechar' onClick='JavaScript:window.close();'></td>
    </tr>
    </table>
";

}
