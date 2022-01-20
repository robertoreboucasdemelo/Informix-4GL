#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc016.pl                                                    #
#  Sistema..: Prestador On Line PSRONLINE                                    #
#  Criacao..: Ago/2001                                                       #
#  Autor....: Ruiz/Raji/Wagner/Marcus                                        #
#                                                                            #
#  Objetivo.: Laudo do servico                                               #
#----------------------------------------------------------------------------#
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
# 11/12/2002  PSI 150550   Zyon         Implementação da versão de impressão #
# 03/07/2003  CT   99813   Zyon         Acerto   da informacao de retorno.   #
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
     $botao,
     $JSCRIPT,
     $flag,
     $ciaempcod,
     $image,
     $nomeseg,
     @botoes,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape,
     @impressao,
     @action,
     @form
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
$acao      = param("acao");

# Montando parametros para o 4GL
#-------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$acao;

$JSCRIPT=<<END;

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

function func_diaria(ciaempcod, vldiaria) {

    if (document.laudo.diaria.value == "NaN" ||
        document.laudo.diaria.value  == "undefined") {
        alert("Digite apenas valores numericos !");
        document.laudo.diaria.value = "";
        document.laudo.diaria.focus();
        return false;
    }

    if (document.laudo.diaria.value == "" ||
        document.laudo.diaria.value == null ||
        document.laudo.diaria.value == "0" ||
        document.laudo.diaria.value == "0.00" ||
        document.laudo.diaria.value < 1 ||
        document.laudo.diaria.length == 0 ||
        document.laudo.diaria.value.substring(1,0) == "0") {
       alert("Informe o valor da diaria!");
       document.laudo.diaria.focus();
       return false;
    }

    if (ciaempcod == 1) {
        msg = "LIMITE DE 7 DIARIAS E " + vldiaria + ",00 AO DIA"
        alert(msg);
     }
    if (ciaempcod == 35) {
        msg = "LIMITE DE 2 DIARIAS DE NO MAXIMO " + vldiaria + ",00 AO DIA LIMITADO A 5 PESSOAS"
        alert(msg);
     }
    if (ciaempcod == 84) {
        msg = "LIMITE DE 2 DIARIAS DE NO MAXIMO " + vldiaria + ",00"
        alert(msg);
     }
    document.laudo.diaria.value =
             funcValidaEntrada(document.laudo.diaria.value);
    return true;
}
function func_checa() {

    if (document.laudo.hotel.value == "" || document.laudo.endereco_htl.value == "" || document.laudo.bairro_htl.value == "" || document.laudo.estado_htl.value == "" || document.laudo.cidade_htl.value == "" || document.laudo.telefone_htl.value == "" || document.laudo.contato.value == "" || document.laudo.diaria.value == "" || document.laudo.acomodacao.value == "" )
          {
            alert("Informe os dados, os campos são de preenchimento obrigatório!");
            document.laudo.hotel.focus();
            return false;
           }

    else { return true; }

    return false;
}

END

#-------------------------------
$ARG = sprintf("'%s'",join('\' \'',@ARG));

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------

if ($macsissgl eq "LCVONLINE" || $macsissgl eq "RLCONLINE") {
    $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc077.4gc $ARG 2>&1)"; }
else {
    $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc017.4gc $ARG 2>&1)"; }

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

#-----------------------------------------------------------------------------
# Montando body variavel @body (parte central do fonte HTML)
#-----------------------------------------------------------------------------
while (<PROG>) {
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
        elsif ($REGISTRO[1] == 12) { $ciaempcod = $REGISTRO[2]; }
        else  { &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!"); }
    }

    elsif ($REGISTRO[0] eq "PADRAO2") {
           push @body, $REGISTRO[1];
        }
    elsif ($REGISTRO[0] eq "IMPOK") {
        $flag = "Enviar";
        push @impressao,
            "<input type='button' name='btnImp' value='Imprimir' onclick='doImpressao()'>",
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

    } elsif ($REGISTRO[0] eq "BOTAO")
          {
            $botao = $REGISTRO[1];
            $programa= $REGISTRO[2];

            if ($botao eq "Aceitar") {
                $texto  = 'Verifique a possibilidade de aceitar este atendimento e clique no botão "aceitar", em caso de recusa clique no botão "recusar".'; }
            elsif ($botao eq "Cotar") {
                    $texto  = 'Verifique a possibilidade de cotar este atendimento e clique no botão "cotar", em caso de recusa clique no botão "recusar".'; }
            elsif ($botao eq "Emitir") {
                    $texto  = 'Verifique a possibilidade de solicitar a emissao  e clique no botão "Emitir", em caso de recusa clique no botão "recusar".'; }
            elsif ($botao eq "Reservar") {
                    $texto  = 'Verifique a possibilidade de reservar este atendimento e clique no botão "reservar", em caso de recusa clique no botão "recusar".'; }
       }
    else {
         $_ =~ s/\ //g;
         if ($_ ne "")
            {
            &wissc219_mensagem($titgif,$cabec,"BACK","Trata outro tipo de registro! <br><br>$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$acao " . $_);
            }
         }
}

close(PROG);

#-----------------------------------------------------------------------------
# Montando cabecalho (parte inicial do fonte HTML)
#-----------------------------------------------------------------------------
if ($acao == 1) {
    $cabec  = 'RECEBER SERVIÇOS - LAUDO';
    $funcao = '';
} elsif ($acao == 2) {
    $cabec  = 'SERVIÇOS - LAUDO';
    $texto  = '';
    $funcao = 'JavaScript:self.print();';
} else {
    $cabec  = 'CONSULTAR SERVIÇOS - LAUDO';
    $texto  = 'Consulte informações detalhadas sobre este serviço.';
    $funcao = '';
}

###push @action, "/cgi-bin/ct24h/trs/", $programa, "?usrtip=%s&webusrcod=%d&sesnum=%d&macsissgl=%satdsrvnum=%d&atdsrvano=%d&,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano" ;

###push @action, $programa, "?usrtip=%s&webusrcod=%d&sesnum=%d&macsissgl=%satdsrvnum=%d&atdsrvano=%d&,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano" ;

push @cabecalho, header,

start_html(-'title'=>'Porto Seguro',
           -'script'=>$JSCRIPT,
           -onLoad=>$funcao,
           -bgcolor=>'#FFFFFF',
          ),"\n",

start_form(-method=>'POST',
           -name=>'laudo',
           -onsubmit=>'return func_checa()',
           -action=>"/cgi-bin/ct24h/trs/wdatc024.pl?usrtip=%s&webusrcod=%d&sesnum=%d&macsissgl=%satdsrvnum=%d&atdsrvano=%d&flag=%s,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$flag"
           ), "\n",

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
       -value=>$atdsrvnum
      ),"\n",

hidden(-name=>'atdsrvano',
       -value=>$atdsrvano
       ),"\n";

###push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);
#PSI 208264
if ($ciaempcod == 1) {
    $image = "/corporat/images/logo_porto.gif";
    $nomeseg = "Porto Seguro";
} elsif ($ciaempcod == 35) {
    $image = "/corporat/images/logo_azul.gif";
    $nomeseg = "Azul";
}elsif ($ciaempcod == 84) {
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

if ($acao == 1) {
    push @botoes,
        br(),
        "\n",
        br(),
        "\n",
        table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
        Tr(td(submit(-name=>'Acao',-value=>$botao),
              submit(-name=>'Acao',-value=>'Recusar'),
        "\n"),
        "\n"),
        "\n"),
        "\n";
} elsif ($acao != 2) {
    push @botoes,
        br(),
        "\n",
        br(),
        "\n",
        table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
        Tr(td(@impressao,
        "\n"),
        "\n"),
        "\n"),
        "\n";
}

#-----------------------------------------------------------------------------
# Montando rodape variavel (parte final do fonte HTML)
#-----------------------------------------------------------------------------
if ($acao != 2) {
    push @rodape, &wissc211_rodape("BACK",0);
} else {
    push @rodape, &wissc211_rodape("",0);
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
