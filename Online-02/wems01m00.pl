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
     $args,
     $perini,
     $perter,
     $perfnl,
     $suc,
     $data,
     $ramo,
     $succod,
     $iptcod,
     $unocod,
     $pdtcod,
     $inpcod,
     $grpcod,
     $hldcod,
     $concod,
     $susep,
     $prog,
     $line,
     $optramos,
     $optsuc,
     $optreg,
     $optund,
     $optpdt,
     $optinp,
     $optgrp,
     $opthld,
     $optcon,
     $aplflg,
     $prpflg,
     $orcflg,
     $susepconf,
     $cabec,
     $titgif,
     $texto,
     @trataerro,
     @rodape,
     @html,
     @cabecalho);

#$ambiente = "remsh aplweb01 -l runwww ";


#-----------------------------------------------------------------------------
# Inclusao das subrotinas que montam campos, textos, botoes, etc.
#-----------------------------------------------------------------------------
require "/webserver/cgi-bin/seweb/trs/wissc210.pl";  #--> Gera cabecalho da pagina
require "/webserver/cgi-bin/seweb/trs/wissc211.pl";  #--> Gera rodape da pagina
require "/webserver/cgi-bin/seweb/trs/wissc219.pl";  #--> Mensagem padrao
#-----------------------------------------------------------------------------
# Chama parametros
#-----------------------------------------------------------------------------
&parametros;

$cabec = "RELATÓRIOS GERENCIAIS";
$texto  = "Para consultar as informações da emissão, selecione as opções e o tipo de documento que deseja visualizar e clique em continuar.";
$titgif = '/auto/images/emissao.gif';

$width{"0"} = 550;

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
$args = "'$usrtip' '$usrcod' '$sesnum' '$empcod' '$ramo' '$succod' " .
        "'$iptcod' '$unocod' '$vicitrcod' '$pdtcod' '$inpcod' '$tecmat' " .
        "'$grpcod' '$concod' '$hldcod' '$susep'";

#print header,  $args;

$prog = "(cd /webserver/cgi-bin/ct24h/trs; . ../../setvardsa.sh; wems01m00.4gc $args 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

while ($line=<PROG>) {
        chomp $line;
        #- Trata saida do erro
        if ($line =~ /^Program stopped/)
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
        split ("@@",  $line);

        if ($_[0] eq 'RAMO') {
            $optramos = "$optramos $_[1]";
        } elsif ($_[0] eq 'SUC') {
            $optsuc = "$optsuc $_[1]";
        } elsif ($_[0] eq 'REG') {
            $optreg = "$optreg $_[1]";
        } elsif ($_[0] eq 'UNO') {
            $optund = "$optund $_[1]";
        } elsif ($_[0] eq 'INST'){
            $optinst = "$optinst $_[1]";
        } elsif ($_[0] eq 'PDT') {
            $optpdt = "$optpdt $_[1]";
        } elsif ($_[0] eq 'INP') {
            $optinp = "$optinp $_[1]";
        } elsif ($_[0] eq 'TEC') {
            $opttec = "$opttec $_[1]";
        } elsif ($_[0] eq 'GRP') {
            $optgrp = "$optgrp $_[1]";
        } elsif ($_[0] eq 'CON') {
            $optcon = "$optcon $_[1]";
        } elsif ($_[0] eq 'HLD') {
            $opthld = "$opthld $_[1]";
#        } elsif ($_[0] eq 'SUSEP') {
#            $susep = $_[1];
#            $susepconf = $_[2];
        } elsif ($_[0] eq 'NIVEL') {
            $nivel = $_[1];
        } elsif ($_[0] eq 'NOSESS') {
          &wissc219_mensagem($titgif,$cabec,"LOGIN3",$_[1]);
          exit (0);
        }
}
close (PROG);

if ($optsuc ne '')
{
  push @optsuc,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Sucursal"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
       "<SELECT NAME='suc' size='1' OnChange='chama(this)'>
            $optsuc
        </SELECT> "
      )
    );
    $limpa = "$limpa
              form1.suc.value = '';";

    $atribui = "$atribui
                form2.succod.value = form1.suc.value; ";

}
if ($optreg ne '')
{
  push @optreg,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
       font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            "Regional"
           )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $optreg
      )
    );
    $limpa = "$limpa
              form1.reg.value = '';";
    $atribui = "$atribui
                form2.iptcod.value = form1.reg.value; ";
}
if ($optund ne '')
{
  push @optund,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Unidade"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
        $optund
      )
    );
    $limpa = "$limpa
              form1.uno.value = '';";
    $atribui = "$atribui
                form2.unocod.value = form1.uno.value; ";
}
if ($optinst ne '')
{
  push @optinst,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Instrutor"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
        $optinst
      )
    );
    $limpa = "$limpa
              form1.inst.value = '';";
    $atribui = "$atribui
                form2.vicitrcod.value = form1.inst.value; ";
}
if ($optpdt ne '')
{
  push @optpdt,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Produtor"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $optpdt
      )
    );
    $limpa = "$limpa
              form1.pdt.value = '';";
    $atribui = "$atribui
                form2.pdtcod.value = form1.pdt.value; ";
}
if ($optinp ne '')
{
  push @optinp,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Inspetor"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $optinp
      )
    );
    $limpa = "$limpa
              form1.inp.value = '';";
    $atribui = "$atribui
              form2.inpcod.value = form1.inp.value;";
}
if ($opttec ne '')
{
  push @opttec,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Técnico"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $opttec
      )
    );
    $limpa = "$limpa
              form1.tec.value = '';";
    $atribui = "$atribui
               form2.tecmat.value = form1.tec.value; ";
}
if ($optgrp ne '')
{
  push @optgrp,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Grupo de SUSEP"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $optgrp
      )
    );
    $limpa = "$limpa
              form1.grp.value = '';";
    $atribui = "$atribui
              form2.corgrpcod.value = form1.grp.value; ";
}
if ($optcon ne '')
{
  push @optcon,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Consolidados"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $optcon
      )
    );
    $limpa = "$limpa
              form1.con.value = '';";
    $atribui = "$atribui
                form2.cdngrlcod.value = form1.con.value; ";
}
if ($opthld ne '')
{
  push @opthld,
  Tr(
    td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
      font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
           "Holding"
          )
      ),
    td({-bgcolor=>'#D7E7F1', -align=>'left'},
          $opthld
      )
    );
    $limpa = "$limpa
              form1.hld.value = '';";
    $atribui = "$atribui
                form2.corhldcod.value = form1.hld.value; ";
}

push @rodape, &wissc211_rodape("BACK",0);

push @cabecalho,
     header,
     start_html(-title=>'Porto Seguro',
                -BgColor=>"#FFFFFF"
               ),"\n",
     start_form(-method=>'POST',
                -name=>'wems01m00',
                -action=>'wems01m00.pl'
               ),"\n",
               &wissc210_cabecalho($titgif,$cabec,$texto);

push @html, @cabecalho, center(
table({-width=>'548', -border=>'0', -cellpadding=>'0', -cellspacing=>'0'},
    Tr(
      td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'center'},
        font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'2'},
            b("Dados do relatório")
            )
        )
      )
    ),
table({-width=>'550', -border=>'0', -cellpadding=>'0', -cellspacing=>'1'},
    Tr(
       td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
              "Visualizar"
             )
         ),
      td({-bgcolor=>'#D7E7F1', -height=>'23', -align=>'left', -width=>'70%'},
        font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
            checkbox(-name=>'aplflg',
                     -value=>'S',
                     -label=>"Apólices",
                     -checked=>$aplflg),
            checkbox(-name=>'prpflg',
                     -value=>'S',
                     -label=>"Propostas",
                     -checked=>$prpflg),
            checkbox(-name=>'orcflg',
                     -value=>'S',
                     -label=>"Orçamento",
                     -checked=>$orcflg)
            )
        )
      ),
     Tr(
       td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
              "Data inicial"
             )
         ),
       td({-bgcolor=>'#D7E7F1', -align=>'left'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
          textfield( -size=>'10',
                     -maxlength=>'10',
                     -name=>'perini',
                     -value=>"$perini",
                     -onBlur=>"if(!dt(this)) this.focus();" ),
                 "(Ex. dd/mm/aaaa)"
             )
         )
       ),
     Tr(
       td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
              "Data final"
             )
         ),
       td({-bgcolor=>'#D7E7F1', -align=>'left'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
          textfield( -size=>'10',
                     -maxlength=>'10',
                     -name=>'perter',
                     -value=>"$perfnl",
                     -onBlur=>"if(!dt(this)) this.focus();" ),
                     "(Ex. dd/mm/aaaa)"
             )
         )
       ),
     Tr(
       td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
              "Ramo"
             )
         ),
       td({-bgcolor=>'#D7E7F1', -align=>'left'},
          "<SELECT NAME='ramo' size='1' OnChange='chama(this)'>
              $optramos
           </SELECT>"
         )
       ),
     @optsuc,
     @optreg,
     @optund,
     @optinst,
     @optpdt,
     @optinp,
     @optcon,
     @opthld,
     @optgrp,
     @opttec,
     Tr(
       td({-bgcolor=>'#A8CDEC', -height=>'23', -align=>'left', -width=>'30%'},
         font({-face=>'ARIAL,HELVETICA,VERDANA', -size=>'1'},
              "Susep"
             )
         ),
       td({-bgcolor=>'#D7E7F1', -align=>'left'},
         textfield (-name=>'susep',
                    -value=>"$susep",
                    -maxlength=>'6',
                    -size=>'7')
         )
       )
    ),
    hidden(-name=>'sesnum',    -value=>"$sesnum"),
    hidden(-name=>'usrtip',    -value=>"$usrtip"),
    hidden(-name=>'empcod',    -value=>"$empcod"),
    hidden(-name=>'usrcod',    -value=>"$usrcod"),
end_form(),
table({-width=>'550', -border=>'0', -cellpadding=>'0', -cellspacing=>'1'},
     Tr(
       td({-height=>'23'},
         br(), br()
         )
       ),
     Tr(
       td(
           start_form(-method=>'POST',
                      -action=>'wems01m01.pl',
                      -name=>'wems01m00_1'),
           hidden(-name=>'perini',    -value=>''),
           hidden(-name=>'perter',    -value=>''),
           hidden(-name=>'ramcod',    -value=>''),
           hidden(-name=>'succod',    -value=>''),
           hidden(-name=>'iptcod',    -value=>''),
           hidden(-name=>'unocod',    -value=>''),
           hidden(-name=>'vicitrcod', -value=>''),
           hidden(-name=>'pdtcod',    -value=>''),
           hidden(-name=>'inpcod',    -value=>''),
           hidden(-name=>'tecmat',    -value=>''),
           hidden(-name=>'corgrpcod', -value=>''),
           hidden(-name=>'cdngrlcod', -value=>''),
           hidden(-name=>'corhldcod', -value=>''),
           hidden(-name=>'corsus',    -value=>''),
           hidden(-name=>'aplflg',    -value=>''),
           hidden(-name=>'prpflg',    -value=>''),
           hidden(-name=>'orcflg',    -value=>''),
           hidden(-name=>'sesnum',    -value=>"$sesnum"),
           hidden(-name=>'usrtip',    -value=>"$usrtip"),
           hidden(-name=>'empcod',    -value=>"$empcod"),
           hidden(-name=>'usrcod',    -value=>"$usrcod"),
           hidden(-name=>'reltip',    -value=>'RESUMO'),
           submit(-value=>'Continuar',
                  -onclick=>'return valida();'),
           reset(-value=>'Limpar', onclick=>'limpa_form1();')
         )
       )
     ),
  &JS,
  @rodape);


print @html;

#-----------------------------------------------------------------------
sub parametros() {
#-----------------------------------------------------------------------

$perini    = param("perini");
$perfnl    = param("perter");
$suc       = param("suc");
$ramo      = param("ramo");
$succod    = param("suc") ;
$iptcod    = param("reg") ;
$unocod    = param("uno") ;
$vicitrcod = param("inst");
$pdtcod    = param("pdt") ;
$inpcod    = param("inp") ;
$tecmat    = param("tec") ;
$grpcod    = param("grp") ;
$concod    = param("con") ;
$hldcod    = param("hld") ;
$susep     = param("susep");
$aplflg    = 'checked' if param("aplflg") ;
$prpflg    = 'checked' if param("prpflg") ;
$orcflg    = 'checked' if param("orcflg") ;
$susepconf = '';

$usrtip    = param("usrtip");
$empcod    = param("empcod");
$usrcod    = param("usrcod");
$sesnum    = param("sesnum");

$data = `date '+%Y%m%d'`;
chomp $data;

}
#-----------------------------------------------------------------------
sub JS() {
#-----------------------------------------------------------------------

return "

<script language=JavaScript>

form1 = document.forms[0];
form2 = document.forms[1];

function chama(campo) {
    if ($nivel <= 5 || $nivel == 6)
        if (campo.name == 'grp')
            return;

    if ($nivel == 7 || $nivel >= 8)
        if (campo.name == 'tec')
            return;

    var ret = false;
    for (i=0;i<form1.elements.length;i++)
    {
         if (form1.elements[i].type == 'select-one') {
             if (ret == true)  {
                 form1.elements[i].value = '';
             }

             if (form1.elements[i].name == campo.name)  {
                 ret = true;
             }
         }
    }

    form1.submit();
}
function limpa_form1() {

form1.perini.value = '';
form1.perter.value = '';
form1.ramo.value = '';

// Variavel tem acumulada os combos montados a serem limpos
$limpa

form1.susep.value  = '';
form1.aplflg.checked = false;
form1.prpflg.checked = false;
form1.orcflg.checked = false;

}

function limpa_form2() {

form2.perini.value = '';
form2.perter.value = '';
form2.ramcod.value = '';
form2.succod.value = '';
form2.corgrpcod.value = '';
form2.vicitrcod.value = '';
form2.corhldcod.value = '';
form2.cdngrlcod.value = '';
form2.unocod.value = '';
form2.pdtcod.value = '';
form2.inpcod.value = '';
form2.iptcod.value = '';
form2.tecmat.value = '';
form2.corsus.value = '';
form2.aplflg.value = '';
form2.prpflg.value = '';
form2.orcflg.value = '';
}

function atribui_forms() {

form2.perini.value = form1.perini.value;
form2.perter.value = form1.perter.value;
form2.ramcod.value = form1.ramo.value;

// Variavel que acumula os combos montados a serem atribuidos

$atribui

form2.corsus.value = form1.susep.value;

if (form1.aplflg.checked) {
    form2.aplflg.value = form1.aplflg.value;
}
if (form1.prpflg.checked) {
    form2.prpflg.value = form1.prpflg.value;
}
if (form1.orcflg.checked) {
    form2.orcflg.value = form1.orcflg.value;
}

}

function valida() {

if (form1.susep.value != '') {
    if (form1.perini.value == '') {
        alert ('Campo Obrigatório');
        form1.perini.focus();
        return false;
    } else {
      if (form1.perter.value == '') {
          alert ('Campo Obrigatório');
          form1.perter.focus();
          return false;
      }
    }
//    if (form1.susep.value != '$susepconf') {
//        form1.submit();
//        return false;
//    }
} else {
  if (form1.perini.value == '') {
      alert ('Campo Obrigatório');
      form1.perini.focus();
      return false;
  }
  if (form1.perter.value == '') {
      alert ('Campo Obrigatório');
      form1.perter.focus();
      return false;
  }
  if (!form1.aplflg.checked && !form1.prpflg.checked && !form1.orcflg.checked) {
     alert ('Infome pelo menos um documento a ser visualisado !');
     return false;
  }

}

if (dt(form1.perini) == false){
    form1.perini.focus();
    form1.perini.select();
    return false;
}
if (dt(form1.perter) == false) {
    form1.perter.focus();
    form1.perter.select();
    return false;
}

dataini = form1.perini.value.substring(6, 10) +
          form1.perini.value.substring(3, 5)  +
          form1.perini.value.substring(0, 2);

datafnl = form1.perter.value.substring(6, 10) +
          form1.perter.value.substring(3, 5)  +
          form1.perter.value.substring(0, 2);

if (dataini > $data) {
    alert ('Data inicial maior que hoje ! ');
    form1.perini.focus();
    form1.perini.select();
    return false;
}

if (parseInt(datafnl) < parseInt(dataini)) {
    alert ('Data final menor que a inicial ! ');
    form1.perter.focus();
    form1.perter.select();
    return false;
}

limpa_form2();
atribui_forms();

return true;

}

function dt(campo) {
  if (campo.value == '')
     return true;

  if (campo.value.length == 10) {
      dia = campo.value.substring(0, 2);
      mes = campo.value.substring(3, 5);
      ano = campo.value.substring(6, 10);
  } else {
      if (campo.value.length == 8) {
          dia = campo.value.substring(0, 2);
          mes = campo.value.substring(2, 4);
          ano = campo.value.substring(4, 8);
      } else {
        if (campo.value.length == 6) {
            dia = campo.value.substring(0, 2);
            mes = campo.value.substring(2, 4);
            ano = campo.value.substring(4, 6);

            if (ano < 30) {
               ano = '20' + ano;
            } else {
               ano = '19' + ano;
            }
        } else {
            mens();
            return false;
        }
      }
  }

  if (dia == 0  ||
      mes == 0) {
      mens();
      return false;
  }
  if (dia > 31  ||
      mes > 12) {
      mens();
      return false;
  }
  if ((mes == 4  ||
       mes == 6  ||
       mes == 9  ||
       mes == 11 )  &&
      (dia > 30)) {
       mens();
       return false;
  }
  if (bisexto(ano)){
      maxdia = 29;
  } else {
      maxdia = 28;
  }
  if (mes == 2  &&
      dia > maxdia) {
      mens();
      return false;
  }
  campo.value = dia + '/' + mes + '/' + ano;
  return true;

}

function bisexto(ano2) {
  div = ano2 / 4;
  div2 = parseInt(div) * 4;

  if (ano  == div2) {
      return true;
  } else {
      return false;
  }
}

function mens() {
   alert ('Data Invalida');
}

</script>

";

} # -- End Sub
