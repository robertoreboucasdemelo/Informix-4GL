#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc050.pl                                                    #
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

my ($cabec,
    $jscript,
    $texto,
    $titgif,
    @body,
    @cabecalho,
    @html,
    @rodape,
   #$ambiente,
    $arg,
    $macsissgl,
    $maq,
    $prog,
    $sesnum,
    $usrtip,
    $webusrcod,
    $atdsrvnum,
    $atdsrvano,
    $c24pbmcod,
    $cidcod,
    $C01, $C02, $C03, $C04, $C05, $C06, $C07, $C08, $C09, $C10,
    $Q01, $Q02, $Q03, $Q04, $Q05, $Q06, $Q07, $Q08, $Q09, $Q10,
    $V01, $V02, $V03, $V04, $V05, $V06, $V07, $V08, $V09, $V10,
    $Q99, $V99,
    $historico,
    @arg,
    @registro,
    $renavam, $quilometragem
   );

#$ambiente = "remsh aplweb01 -l runwww ";

$usrtip     = param("usrtip");
$webusrcod  = param("webusrcod");
$sesnum     = param("sesnum");
$macsissgl  = param("macsissgl");
$atdsrvnum  = param("atdsrvnum");
$atdsrvano  = param("atdsrvano");
$c24pbmcod  = param("c24pbmcod");
$cidcod     = param("cidcod");
$C01        = param("C01");
$C02        = param("C02");
$C03        = param("C03");
$C04        = param("C04");
$C05        = param("C05");
$C06        = param("C06");
$C07        = param("C07");
$C08        = param("C08");
$C09        = param("C09");
$C10        = param("C10");
$Q01        = param("Q01");
$Q02        = param("Q02");
$Q03        = param("Q03");
$Q04        = param("Q04");
$Q05        = param("Q05");
$Q06        = param("Q06");
$Q07        = param("Q07");
$Q08        = param("Q08");
$Q09        = param("Q09");
$Q10        = param("Q10");
$V01        = param("V01");
$V02        = param("V02");
$V03        = param("V03");
$V04        = param("V04");
$V05        = param("V05");
$V06        = param("V06");
$V07        = param("V07");
$V08        = param("V08");
$V09        = param("V09");
$V10        = param("V10");
$renavam    = param("renavam");
$quilometragem = param("quilometragem");

#Variaveis do Pedagio Eletronico
$Q99        = param("Q99");
$V99        = param("V99");

$V01 =~ s/,/#/;
$V01 =~ s/\./,/g;
$V01 =~ s/#/\./;

$V02 =~ s/,/#/;
$V02 =~ s/\./,/g;
$V02 =~ s/#/\./;

$V03 =~ s/,/#/;
$V03 =~ s/\./,/g;
$V03 =~ s/#/\./;

$V04 =~ s/,/#/;
$V04 =~ s/\./,/g;
$V04 =~ s/#/\./;

$V05 =~ s/,/#/;
$V05 =~ s/\./,/g;
$V05 =~ s/#/\./;

$V06 =~ s/,/#/;
$V06 =~ s/\./,/g;
$V06 =~ s/#/\./;

$V07 =~ s/,/#/;
$V07 =~ s/\./,/g;
$V07 =~ s/#/\./;

$V08 =~ s/,/#/;
$V08 =~ s/\./,/g;
$V08 =~ s/#/\./;

$V09 =~ s/,/#/;
$V09 =~ s/\./,/g;
$V09 =~ s/#/\./;

$V10 =~ s/,/#/;
$V10 =~ s/\./,/g;
$V10 =~ s/#/\./;

$V99 =~ s/,/#/;
$V99 =~ s/\./,/g;
$V99 =~ s/#/\./;

$Q01 =~ s/,/#/;
$Q01 =~ s/\./,/g;
$Q01 =~ s/#/\./;

$Q02 =~ s/,/#/;
$Q02 =~ s/\./,/g;
$Q02 =~ s/#/\./;

$Q03 =~ s/,/#/;
$Q03 =~ s/\./,/g;
$Q03 =~ s/#/\./;

$Q04 =~ s/,/#/;
$Q04 =~ s/\./,/g;
$Q04 =~ s/#/\./;

$Q05 =~ s/,/#/;
$Q05 =~ s/\./,/g;
$Q05 =~ s/#/\./;

$Q06 =~ s/,/#/;
$Q06 =~ s/\./,/g;
$Q06 =~ s/#/\./;

$Q07 =~ s/,/#/;
$Q07 =~ s/\./,/g;
$Q07 =~ s/#/\./;

$Q08 =~ s/,/#/;
$Q08 =~ s/\./,/g;
$Q08 =~ s/#/\./;

$Q09 =~ s/,/#/;
$Q09 =~ s/\./,/g;
$Q09 =~ s/#/\./;

$Q10 =~ s/,/#/;
$Q10 =~ s/\./,/g;
$Q10 =~ s/#/\./;

$Q99 =~ s/,/#/;
$Q99 =~ s/\./,/g;
$Q99 =~ s/#/\./;

#print header, 'Valor: ', $V01;
#exit(0);

$historico  = param("historico");
$historico =~ s/\t//g;
$historico =~ s/\n//g;
$historico =~ s/\r//g;
$historico =~ s/\f//g;
$historico =~ s/\a//g;
$historico =~ s/\e//g;
$historico =~ s/\033//g;
$historico =~ s/\x1B//g;
$historico =~ s/\x{263a}//g;
$historico =~ s/\c[//g;
$historico =~ s/\l//g;
$historico =~ s/\u//g;
$historico =~ s/\L//g;
$historico =~ s/\U//g;
$historico =~ s/\E//g;
$historico =~ s/\Q//g;
$historico =~ s/\t//g;

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
     $c24pbmcod,
     $cidcod,
     $C01, $C02, $C03, $C04, $C05, $C06, $C07, $C08, $C09, $C10,
     $Q01, $Q02, $Q03, $Q04, $Q05, $Q06, $Q07, $Q08, $Q09, $Q10,
     $V01, $V02, $V03, $V04, $V05, $V06, $V07, $V08, $V09, $V10,
     $Q99, $V99,
     $historico,
     $renavam, $quilometragem;

#----------------------------------------
# Rodando o 4gc
#----------------------------------------

$cabec  = 'ACERTO DE VALORES';
$titgif = '/auto/images/ramo_psocorro.gif';

$arg = sprintf("'%s'",join('\' \'',@arg));

$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc051.4gc $arg 2>&1)";

#####push @body,$prog;

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

#-----------------------------------------------------------------------------
# Rodando o 4gc
#-----------------------------------------------------------------------------

while (<PROG>) {
    chomp;
    @registro = split '@@',$_;
}
close(PROG);

if ($registro[0] ne "") {
     print redirect("/webserver/cgi-bin/ct24h/trs/wdatc044.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&atdsrvnum=$atdsrvnum&atdsrvano=$atdsrvano");
} else {
     print redirect("/webserver/cgi-bin/ct24h/trs/wdatc044.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&atdsrvnum=$atdsrvnum&atdsrvano=$atdsrvano");
}
exit(0);

###push @body, $prog;
### #-----------------------------------------------------------------------------
### # Montando body variavel @body (parte central do fonte HTML)
### #-----------------------------------------------------------------------------
###
### while (<PROG>) {
###     #--------------------------------------------------------------------------
###     # Trata erro no programa/banco informix
###     #--------------------------------------------------------------------------
###
###     &wissc220_veriferro($_, $macsissgl);
###
###     @registro = split '@@',$_;
###
###     if ($registro[0] eq "NOSESS") {
###         &wissc219_mensagem($titgif,$cabec,"LOGIN",$registro[1]);
###     } elsif ($registro[0] eq "ERRO") {
###         &wissc219_mensagem($titgif,$cabec,"BACK" ,$registro[1]);
###     }
###
###     if ($registro[0] eq "PADRAO") {
###         if ($registro[1] == 1) {
###             push @body, &wissc203_titulo(@registro);
###         } elsif ($registro[1] == 2) {
###             push @body, &wissc204_listbox(@registro);
###         } elsif ($registro[1] == 3) {
###             push @body, &wissc205_checkbox(@registro);
###         } elsif ($registro[1] == 4) {
###             push @body, &wissc206_radiobox(@registro);
###         } elsif ($registro[1] == 5) {
###             push @body, &wissc207_textoinputtexto(@registro);
###         } elsif ($registro[1] == 6) {
###             push @body, &wissc208_coluna(@registro);
###         } elsif ($registro[1] == 7) {
###             push @body, &wissc209_titulohelp(@registro);
###         } elsif ($registro[1] == 8) {
###             push @body, &wissc212_linhas1(@registro);
###         } elsif ($registro[1] == 9) {
###             push @body, &wissc216_checklistbox(@registro);
###         } elsif ($registro[1] == 10) {
###             push @body, &wissc225_colunaimpressao(@registro);
###         } elsif ($registro[1] == 11) {
###             push @body, &wissc229_tabela(@registro);
###         } else {
###             &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!");
###         }
###    } else {
###        &wissc219_mensagem($titgif,$cabec,"BACK","Trata outro tipo de registro!");
###    }
### }
###
### close(PROG);
###
### #-----------------------------------------------------------------------------
### # Montando cabecalho (parte inicial do fonte HTML)
### #-----------------------------------------------------------------------------
### $texto = 'INFO INFO INFO INFO INFO INFO INFO INFO INFO INFO ';
###
### push @cabecalho,
###
###      header(-'expires'=>'-1d',
###             -'pragma'=>'no-cache',
###             -'cache-control'=>'no-store'),
###
###      start_html(-'title'=>'Porto Seguro',
###                 -bgcolor=>'#FFFFFF',
###                 -'meta'=>{'http-equiv=Pragma content=no-cache'}),
###
###      start_form(-method=>'POST',
###                 -name=>'wdatc050',
###                 -action=>"/webserver/cgi-bin/ct24h/trs/wdatc052.pl"),
###
###      hidden(-name=>'usrtip',
###             -value=>$usrtip),
###
###      hidden(-name=>'webusrcod',
###             -value=>$webusrcod),
###
###      hidden(-name=>'sesnum',
###             -value=>$sesnum),
###
###      hidden(-name=>'macsissgl',
###             -value=>$macsissgl);
###
### push @cabecalho,
###      &wissc210_cabecalho($titgif,$cabec,$texto);
###
### #-----------------------------------------------------------------------------
### # Montando rodape variavel (parte final do fonte HTML)
### #-----------------------------------------------------------------------------
### push @rodape,
###      &wissc211_rodape("BACK",1);
###
### #-----------------------------------------------------------------------------
### # Agrupa componentes do HTML e envia para o browser
### #-----------------------------------------------------------------------------
### push @html,
###      @cabecalho,
###      center(@body,@rodape),
###      end_form,
###      end_html;
###
### print @html;
### exit(0);
