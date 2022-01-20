#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc046.pl                                                    #
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
    @arg,
    @body,
    @cabecalho,
    @html,
    @registro,
    @rodape
   );

#$ambiente = "remsh aplweb01 -l runwww ";

$usrtip     = param("usrtip");
$webusrcod  = param("webusrcod");
$sesnum     = param("sesnum");
$macsissgl  = param("macsissgl");
$atdsrvnum  = param("atdsrvnum");
$atdsrvano  = param("atdsrvano");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @arg,
     $usrtip,
     $webusrcod,
     $sesnum,
     $macsissgl,
     $atdsrvnum,
     $atdsrvano;

#-----------------------------------------------------------------------------
# Carregando parametros recebidos
#-----------------------------------------------------------------------------
$cabec  = 'ACERTO DE VALORES';
$titgif = '/auto/images/ramo_psocorro.gif';

$arg = sprintf("'%s'",join('\' \'',@arg));

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e trata os displays
#-----------------------------------------------------------------------------
$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc047.4gc $arg 2>&1)";

#####push @body, $prog;

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

#-----------------------------------------------------------------------------
# Montando body variavel @body (parte central do fonte HTML)
#-----------------------------------------------------------------------------

#####while (0>1) {
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
    function func_checa() {
        var v_aux = '';
        if (document.wdatc046.c24pbmgrpcod.value < 0) {
            v_aux +="Escolha um grupo de problema !\\n";
        }
        if (document.wdatc046.ufdcod.value == "") {
            v_aux += "Escolha uma UF de destino !\\n";
        }
        if (v_aux != "") {
            alert( v_aux );
            document.wdatc046.c24pbmgrpcod.focus();
            return false;
        } else {
            document.wdatc046.submit();
        }
    }
END

push @cabecalho,

     header(-'expires'      =>'-1d',
            -'pragma'       =>'no-cache',
            -'cache-control'=>'no-store'),

     start_html(-'title'    =>'Porto Seguro',
                -'script'   =>$jscript,
                -bgcolor    =>'#FFFFFF',
                -'meta'     =>{'http-equiv=Pragma content=no-cache'}),

     start_form(-method     =>'POST',
                -name       =>'wdatc046',
                -action     =>"/webserver/cgi-bin/ct24h/trs/wdatc048.pl",
                -onsubmit   =>'return func_checa( )'),

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
push @rodape, &wissc211_rodape("BACK",1);

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

