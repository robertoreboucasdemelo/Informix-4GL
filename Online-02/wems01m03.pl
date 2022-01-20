#!/usr/bin/perl
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 04/07/2007 Luiz, Meta    AS143650  Retirada do teste da identificacao do   #
#                                    ambiente                                #
#----------------------------------------------------------------------------#
use CGI ":all";
#use strict;
use ARG4GL;

#-----------------------------------------------------------------------------
# Declara variaveis
#-----------------------------------------------------------------------------
my ( $maq,
    #$ambiente,
     $cabec,
     $titgif,
     $texto,
     @trataerro,
     @html,
     $reltip,
     $perini,
     $perter,
     $ramcod,
     $succod,
     $iptcod,
     $unocod,
     $tecmat,
     $pdtcod,
     $inpcod,
     $corgrpcod,
     $corsus,
     $cdngrlcod,
     $corhldcod,
     $aplflg,
     $prpflg,
     $orcflg
   );

#$ambiente = "remsh aplweb01 -l runwww ";

#-----------------------------------------------------------------------------
# Inclusao das subrotinas que montam campos, textos, botoes, etc.
#-----------------------------------------------------------------------------
require "/webserver/cgi-bin/seweb/trs/wissc210.pl";  #--> Gera cabecalho da pagina
require "/webserver/cgi-bin/seweb/trs/wissc211.pl";  #--> Gera rodape da pagina
require "/webserver/cgi-bin/seweb/trs/wissc219.pl";  #--> Mensagem padrao

$cabec = "RELATÓRIOS GERENCIAIS - CUSTOMIZADO";
$texto  = "Para montar o relatório conforme sua necessidade de visualização, selecione as opções abaixo e clique em continuar.";
#$titgif = "/seweb/images/c_acesso.gif";
$titgif = '/auto/images/emissao.gif';

$width{"0"} = 550;

&pega_param();

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
$args = "'$usrtip' '$usrcod' '$sesnum' '$empcod' 'wems01m03'";

$prog = "(cd /webserver/cgi-bin/ct24h/trs; . ../../setvardsa.sh; wems00g01.4gc $args 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

while (<PROG>) {
        chomp ;
        #- Trata saida do erro
        if (/^Program stopped/)
           {
            push @trataerro, $_;
            while (<PROG>)
              {
               push @trataerro, $_;
              }
            ARG4GL::exibe_erro(@trataerro,"");
            exit(0);
           }
        ##Fim tratamento
        split ("@@");

        if ($_[0] eq 'NOSESS') {
          &wissc219_mensagem($titgif,$cabec,"LOGIN3",$_[1]);
          exit (0);
        }
}
close (PROG);

&monta_combos();

push @html,
     header,
     start_html(-title=>'Porto Seguro',
                -BgColor=>"#FFFFFF",
               ),"\n",
     "<meta http-equiv='pragma' content='no-cache' http-equiv='Cache-Control' content='no-store'>",
     center(
     start_form(-method=>'POST',
                -name=>'wems01m01',
                -action=>'/cgi-bin/ct24h/trs/wems01m03.pl'
               ),"\n",
               &wissc210_cabecalho($titgif,$cabec,$texto),
     table({-border=>'0',-cellpadding=>'0', -cellspacing=>'1', -width=>'550'},
     Tr(
       td({-height=>'23', -width=>'30%', -bgcolor=>'#A8CDEC', -align=>'left'},
          font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
             'Tipo de relatório'
              )
         ),
       td({-height=>'23', -width=>'70%', -bgcolor=>'#D7E7F1', -align=>'left'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            "<input type='radio' name='reltip' value='DE/PARA' " .
            " OnClick='limpa(\"0\");document.forms[0].submit();' " .
            " $depara>De/Para",
            "<input type='radio' name='reltip' value='QUANTIDADES' " .
            " onClick='limpa(\"0\");document.forms[0].submit();'   " .
            " $qtd>Quantidades"
             )
         )
       ),
     Tr(
       td({-height=>'23', -width=>'30%', -bgcolor=>'#A8CDEC', -align=>'left'},
          font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
             'Coluna 1'
              )
         ),
       td({-height=>'23', -width=>'70%', -bgcolor=>'#D7E7F1', -align=>'left'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
             popup_menu  (-name=>'col1',
                          -value=>[sort (keys %pop1)],
                          -labels=>\%pop1,
                          -default=>'$col1',
                          -OnChange=>'limpa(\'1\');reload();'
                         )
             )
        )
      ),
    Tr(
      td({-height=>'23', -width=>'30%', -bgcolor=>'#A8CDEC', -align=>'left'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            'Coluna 2'
             )
        ),
      td({-height=>'23', -width=>'70%', -bgcolor=>'#D7E7F1', -align=>'left'},
        font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            popup_menu  (-name=>'col2',
                         -value=>[sort (keys %pop2)],
                         -labels=>\%pop2,
                         -default=>'$col2',
                         -OnChange=>'limpa(\'2\');reload();'
                        )
            )
        )
      ),
    Tr(
      td({-height=>'23', -width=>'30%', -bgcolor=>'#A8CDEC', -align=>'left'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            'Coluna 3'
             )
        ),
      td({-height=>'23', -width=>'70%', -bgcolor=>'#D7E7F1', -align=>'left'},
        font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            popup_menu  (-name=>'col3',
                         -value=>[sort (keys %pop3)],
                         -labels=>\%pop3,
                         -default=>'$col3'
                        )

            )
        )
      )
    ),
    br(),
    br(),
    table({-border=>'0', -cellspacing=>'0', -cellpadding=>'0', -width=>'550'},
    hidden(-name=>'sesnum', -value=>"$sesnum"),
    hidden(-name=>'usrtip', -value=>"$usrtip"),
    hidden(-name=>'usrcod', -value=>"$usrcod"),
    hidden(-name=>'empcod', -value=>"$empcod"),
    hidden(-name=>'perini', -value=>"$perini"),
    hidden(-name=>'perter', -value=>"$perter"),
    hidden(-name=>'ramcod', -value=>"$ramcod"),
    hidden(-name=>'succod', -value=>"$succod"),
    hidden(-name=>'iptcod', -value=>"$iptcod"),
    hidden(-name=>'unocod', -value=>"$unocod"),
    hidden(-name=>'tecmat', -value=>"$tecmat"),
    hidden(-name=>'pdtcod', -value=>"$pdtcod"),
    hidden(-name=>'inpcod', -value=>"$inpcod"),
    hidden(-name=>'corgrpcod', -value=>"$corgrpcod"),
    hidden(-name=>'corsus', -value=>"$corsus"),
    hidden(-name=>'cdngrlcod', -value=>"$cdngrlcod"),
    hidden(-name=>'corhldcod', -value=>"$corhldcod"),
    hidden(-name=>'aplflg', -value=>"$aplflg"),
    hidden(-name=>'prpflg', -value=>"$prpflg"),
    hidden(-name=>'orcflg', -value=>"$orcflg"),
    end_form(),
    Tr(
      td(
        submit(-value=>'Continuar', -name=>'Continuar',
               -onclick=>'return submet_prox()'),
        reset(-value=>'Limpar', -onclick=>'limpa(\'0\')')
        )
      )
    ),
    &wissc211_rodape("BACK",0),
    ),
    &JS,
    end_html();

print @html;
#-------------------------------------------------------------------------
sub JS() {
#-------------------------------------------------------------------------
$js = "
<SCRIPT LANGUAGE=JavaScript>
<!--
function submet_prox() {
  form1 = document.forms[0];

  if ('$reltip' == 'x') {
      alert ('Tipo de relatório é obrigatório.');
      return false;
  }

  if (form1.elements[2].value == '') {
      alert ('Coluna 1 é obrigatória !');
      form1.elements[2].focus();
      return false;
  }

  if ('$reltip' != 'QUANTIDADES') {
      if (form1.elements[3].value == '') {
          alert ('Coluna 2 é obrigatória !');
          form1.elements[3].focus();
          return false;
      }
  }

  loc ='wems01m01.pl?reltip=$reltip&col1=' + form1.elements[2].value +
       '&col2=' + form1.elements[3].value + '&col3=' + form1.elements[4].value +
       '&perini=$perini&perter=$perter&ramcod=$ramcod&succod=$succod' +
       '&iptcod=$iptcod&unocod=$unocod&tecmat=$tecmat&pdtcod=$pdtcod' +
       '&inpcod=$inpcod&corgrpcod=$corgrpcod&corsus=$corsus' +
       '&cdngrlcod=$cdngrlcod&corhldcod=$corhldcod' +
       '&aplflg=$aplflg&prpflg=$prpflg&orcflg=$orcflg' +
       '&sesnum=$sesnum&usrtip=$usrtip&usrcod=$usrcod&empcod=$empcod' ;

  location = loc;

  return true;
}

function limpa(campo) {
  form1 = document.forms[0];

  if (campo < 1) {
      form1.col1.value = '';
  }
  if (campo < 2) {
      form1.col2.value = '';
  }
  if (campo < 3) {
      form1.col3.value = '';
  }
}

function reload() {

if ('$reltip' != 'QUANTIDADES') {
    document.forms[0].submit();
}


}
-->
</SCRIPT>
";

return $js;
} # End sub
#-------------------------------------------------------------------------
sub pega_param() {
#-------------------------------------------------------------------------

$reltip    = param("reltip") ;

if (($reltip ne "QUANTIDADES" and $reltip ne "DE/PARA") ||
    ($reltip eq "QUANTIDADES")) {
    $qtd = "CHECKED";
}
if ($reltip eq "DE/PARA") {
    $depara = "CHECKED";
}

$col1      = param("col1");
$col2      = param("col2");
$col3      = param("col3");
$perini    = param("perini");
$perter    = param("perter");
$ramcod    = param("ramcod");
$succod    = param("succod");
$iptcod    = param("iptcod");
$unocod    = param("unocod");
$tecmat    = param("tecmat");
$pdtcod    = param("pdtcod");
$inpcod    = param("inpcod");
$corgrpcod = param("corgrpcod") ;
$corsus    = param("corsus");
$cdngrlcod = param("cdngrlcod");
$corhldcod = param("corhldcod");
$aplflg    = param("aplflg");
$prpflg    = param("prpflg");
$orcflg    = param("orcflg");


$sesnum    = param("sesnum");
$usrtip    = param("usrtip");
$usrcod    = param("usrcod");
$empcod    = param("empcod");

} # End sub

#-------------------------------------------------------------------------
sub monta_combos() {
#-------------------------------------------------------------------------

#$radiob{'DE/PARA'} = 'De/Para';
#$radiob{'QUANTIDADES'} = 'Quantidades';

if ($reltip eq "QUANTIDADES") {
    $pop1{''}   = "Selecione uma opção";
    $pop1{'01'} = 'Orçamento - Convecional';
    $pop1{'02'} = 'Orçamento - Internet';
    $pop1{'03'} = 'Orçamento - TODOS';

    $pop1{'11'} = 'Proposta - Convecional';
    $pop1{'12'} = 'Proposta - Internet';
    $pop1{'13'} = 'Proposta - PPW';
    $pop1{'14'} = 'Proposta - TODOS';

    $pop1{'21'} = 'Apólices - Convecional';
    $pop1{'22'} = 'Apólices - Internet';
    $pop1{'23'} = 'Apólices - PPW';
    $pop1{'24'} = 'Apólices - TODOS';

    %pop2 = %pop1;
    %pop3 = %pop2;

} else {

    $pop1{''}   = "Selecione uma opção";
    $pop1{'01'} = 'Orçamento - Convecional';
    $pop1{'02'} = 'Orçamento - Internet';
    $pop1{'03'} = 'Orçamento - TODOS';

    $pop1{'11'} = 'Proposta - Convecional';
    $pop1{'12'} = 'Proposta - Internet';
    $pop1{'13'} = 'Proposta - PPW';
    $pop1{'14'} = 'Proposta - TODOS';

    $pop1{'21'} = 'Apólices - Convecional';
    $pop1{'22'} = 'Apólices - Internet';
    $pop1{'23'} = 'Apólices - PPW';
    $pop1{'24'} = 'Apólices - TODOS';

    $pop2{''}   = "Selecione uma opção";
    $pop3{''}   = "Selecione uma opção";

    if ($col1 eq '') {
        return;
    }
    if ($col1 lt "10") {
        $pop2{'11'} = 'Proposta - Convecional';
        $pop2{'12'} = 'Proposta - Internet';
        $pop2{'13'} = 'Proposta - PPW';
        $pop2{'14'} = 'Proposta - TODOS';
    }
    if ($col1 lt "20") {
        $pop2{'21'} = 'Apólices - Convecional';
        $pop2{'22'} = 'Apólices - Internet';
        $pop2{'23'} = 'Apólices - PPW';
        $pop2{'24'} = 'Apólices - TODOS';
    }

    if ($col2 eq '') {
        return;
    }
    if ($col2 lt "20") {
        $pop3{'21'} = 'Apólices - Convecional';
        $pop3{'22'} = 'Apólices - Internet';
        $pop3{'23'} = 'Apólices - PPW';
        $pop3{'24'} = 'Apólices - TODOS';
    }
}

} # End sub
