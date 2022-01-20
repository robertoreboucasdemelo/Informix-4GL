#!/usr/bin/perl
#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc039.pl                                               #
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
# 02/06/2003  R. Santos             Alteracao no layout da tela.             #
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
   $ciaempcod,
   $image01,
   $image02,
   $nomeseg,
   $infoseg,
   $space,
   @body,
   @ARG,
   @telaImpr,
   @protocolo,
   @tela,
   %parametros,
   $hoje,
   $flagassina,
   $flagaceite,
   $flagoptant,
   %ass_iss,
   $def_iss,
   @lst_iss,
   $concordo,
   $optante,
   @REGISTRO,
   $comunicado,
   $JSCRIPT_POP
   );

#$ambiente = "remsh aplweb01 -l runwww ";

#-----------------------------------------------------------------------------
# Inclusao das subrotinas que montam campos, textos, botoes, etc.
#-----------------------------------------------------------------------------
require "/webserver/cgi-bin/seweb/trs/wissc203.pl";     #--> Gera titulo
require "/webserver/cgi-bin/seweb/trs/wissc204.pl";     #--> Gera LIst Box
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

#OSF 20370
#$cabec = "CONSULTA ORDENS DE PAGAMENTO";
$cabec = "ORDENS DE PAGAMENTO";

#OSF 20370
#$texto  = "Caso queira consultar informações mais detalhadas, clique sobre o número do serviço";
if ($parametros{etapa} == 2) {
   $texto  = '';
} else {
   $texto  = "Para consultar informações mais detalhadas, clique sobre o número do serviço.";
}

$titgif = "/auto/images/ramo_psocorro.gif";
$flagassina = "N";
$flagaceite = "N";
$flagoptant = "N";
@lst_iss = ();
%ass_iss = ();
$def_iss = '';

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
push @ARG ,$parametros{usrtip},
           $parametros{webusrcod},
           $parametros{sesnum},
           $parametros{macsissgl},
           $parametros{numop},
           $parametros{codorigem},
           $parametros{acao},
           $parametros{dataent},
           $parametros{datapgt},
           $parametros{datanfs},
           $parametros{qtdserv},
           $parametros{vlrtot},
           $parametros{etapa};

if ($parametros{etapa} == 3) {
   push @ARG ,$parametros{optante},
              $parametros{aliquotaiss};
}

$ARG = sprintf("'%s'",join('\' \'',@ARG));

# print header,start_html,'debug Jose Luis no ramal 6494\n' . $ARG,end_html;
# exit 0;

# $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvardsa.sh; DBMONEY=,;export DBMONEY;wdatc040.4gc $ARG 2>&1)";
$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; DBMONEY=,;export DBMONEY;/webserver/cgi-bin/ct24h/trs/wdatc040.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

while (<PROG>) {

      @REGISTRO = split '@@',$_;

      if ($REGISTRO[0] eq "ERRO") {
         &wissc219_mensagem($titgif,$cabec,$REGISTRO[2],$REGISTRO[1]);
         exit(0);
      } elsif ($REGISTRO[0] eq "PROTOCOLO") {
         push @protocolo, &montar_protocolo(@REGISTRO);
      } elsif ($REGISTRO[0] eq "PERSON") {
         if  ($REGISTRO[1] == 1) {
             $flagassina = $REGISTRO[2];
             $flagaceite = $REGISTRO[3];
             $flagoptant = $REGISTRO[4];
             $def_iss    = $REGISTRO[5];
             $def_iss    =~ s/,/./;

         } elsif ($REGISTRO[1] == 2) {
             push @lst_iss, $REGISTRO[3];
             $ass_iss {$REGISTRO[3]} = $REGISTRO[2];
         }
      } elsif ($REGISTRO[0] eq "PADRAO") {
         if  ($REGISTRO[1] == 6)
              { push @tela, &wissc208_coluna(@REGISTRO); }
         elsif ($REGISTRO[1] == 2)
              { push @tela, &wissc204_listbox(@REGISTRO); }
         elsif ($REGISTRO[1] == 10)
              { push @telaImpr  , &wissc225_colunaimpressao(@REGISTRO); }
         elsif ($REGISTRO[1] == 12)
              { $ciaempcod = $REGISTRO[2];
                    if  ($ciaempcod == 1) {
                        $image01 = '/corporat/images/logo_porto.gif';
                        $image02 = '/corporat/images/logo.gif';
                        #$nomeseg = 'PORTO SEGURO';
                        #$infoseg = '
                        #       CIA DE SEGUROS GERAIS <br />
                        #       Al. Barao de Piracicaba, 740 - Terreo <br />
                        #       CEP 01216-012 - São Paulo - SP <br />
                        #       Fone: (11) 3366-7567 <br />
                        #       Fax:  (11) 3366-8627 <br />
                        #       ';
                        #$space = '';
                    } elsif ($ciaempcod == 35) {
                        $image01 = '/corporat/images/logo_azul.gif';
                        $image02 = '/corporat/images/azullogo.gif';
                        #$nomeseg = 'AZUL';
                        #$infoseg = '
                        #       CIA DE SEGUROS GERAIS <br />
                        #       CNPJ: 33.448.150/0002-00 <br />
                        #       Inscrição Municipal: 11.73.29.0-3 <br />
                        #       Fone: (11) 3366-7567 <br />
                        #       ';
                        #$space = td('&nbsp','&nbsp'),'\n';
                    } elsif ($ciaempcod == 84) {
                        $image01 = '/corporat/images/logo_itau.gif';
                        $image02 = '/corporat/images/logoitau.gif';
                        #$nomeseg = '    ';
                        #$infoseg = '
                        #       SEGUROS DE AUTO E RESIDÊNCIA <br />
                        #       CNPJ: 08.816.067/0001-00 <br />
                        #       Inscrição Municipal: 11.73.29.0-3 <br />
                        #       Fone: (11) 3366-7567 <br />
                        #       ';
                        #$space = td('&nbsp','&nbsp'),'\n';
                    }
              }
      }

}

close (PROG);

my (@rodape, @cabecalho, $load, $newacao);

if ($parametros{etapa} == 2) {
   $newacao = 4;
   $texto = '';
} else {
   $newacao = $parametros{acao};
   push @rodape, &rodape_btn_imprimir();
}

@tela = &montar_pagina(@tela), @rodape;

#OSF 20370
#if ($parametros{acao} != 2) {
#    push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);
#} else {
#    push @cabecalho, &wissc210_cabecalho($titgif,$cabec,"");
#}

#PSI 208264
if ($newacao != 2) {
   if ($newacao != 4) {
      $texto = "";
   }
}

push @cabecalho, br(),"\n",
   center(
     table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'0'},"\n",
           Tr(
              td(img {-src=>$image01,-width=>'173',-height=>'18',-alt=>$nomeseg},
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

if ($newacao == 2) {
    @tela = ();
    push @tela, @telaImpr;
    @rodape = ();
    push @rodape , &wissc211_rodape("","");
    $load = "JavaScript:self.print();";
    $hoje = `date '+%d/%m/%Y \340s %H:%Mh'`;

    push @body,
         header,
         start_html(-title=>'Porto Seguro',
                    -bgcolor=>'#FFFFFF',
                    -onload=>"$load"),
         center(
                 table({-border=>'0',-width=>'550',-cellpadding=>"1",-cellspacing=>"1"},
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
                        ),"\n",
                      ),
                 table({-border=>'0'},
                      Tr(
                          $space,
                          td({-align=>'left',-valign=>'bottom'},
                              img {-src=>$image02},
                            ),"\n",
                          td({-align=>'left',-valign=>'top'},
                             font({-face=>'Arial,Helvetica,Verdana',-size=>'3',-
color=>'#000000'}, '<b>Porto Socorro</b>')
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

} elsif ($newacao == 3) {
    @tela = ();
    push @tela, @protocolo;
    @rodape = ();
    $load = "JavaScript:self.print();";
    @cabecalho = ();
}

if ($newacao != 2 && $newacao != 4) {

   push @body,
        header,
        start_html(-title=>'Porto Seguro',
                   -bgcolor=>'#FFFFFF',
                   -onload=>$load,
                   -script=>&java_script()),
        @cabecalho,
        center
        (
          start_form(-action=>'dinamico',
                     -method=>'post',
                     -name=>'wdatc039'),
          @tela,
          &setarcamposHidden,
          @rodape,
          end_form()
        ),
        end_html;
}

if ($newacao == 4) {

   if ($flagaceite eq 'N') {$concordo =0;} else {$concordo =1;}
   if ($flagoptant eq 'N') {$optante =0;} else {$optante =1;}

   $comunicado = &getComunicado;

   push @body,
        header,
        start_html(-title=>'Porto Seguro',
                   -bgcolor=>'#FFFFFF',
                   -script=>&java_script_pop()),
        @cabecalho,

        center
        (
           table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'0'},"\n",
              Tr(
                 td({-align=>'center'},
                    font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'3',-color=>'#FF0000'},'ATENÇÃO'),"\n"
                 ),
              ),"\n",
              Tr(
                 td({-align=>'left'},
                    font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},'<b>Prezado(a) Prestador(a).'),"\n"
                 ),
              ),"\n",
              Tr(
                 td({-align=>'left'},
                    font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},$comunicado),"\n"
                 ),
              ),
           ),br,"\n",

           start_form(-action=>'/cgi-bin/ct24h/trs/wdatc039.pl',
                      -method=>'post',
                      -name=>'wdatc039',
                      -onSubmit=>'return check_dados()'),

            &setarcamposHidden,

table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
Tr(
td({-align=>'left', -width=>'550', -colspan=>'3'},
                  font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},
                     checkbox(-name=>'concordo',
                              -label=>'Li e concordo',
                              -value=>'Sim',
                              -checked=>$concordo,
                              -override=>1
                  )),"\n"
)),
Tr(
td({-align=>'left', -width=>'550', -colspan=>'3'},
img {-src=>'/corporat/images/linha_azul.gif',-width=>'550',-height=>'1'}
)),
Tr(
td({-align=>'left', -width=>'120'},

                  font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},
                     checkbox(-name=>'optante',
                              -label=>'Optante simples',
                              -value=>'Sim',
                              -checked=>$optante,
                              -override=>1
                  )),"\n"
),
td({-align=>'left', -width=>'310'},

                  font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},
                       popup_menu(-name=>'aliquotaiss',
                                  -value=>[@lst_iss],
                                  -labels=>\%ass_iss,
                                  -default=>$def_iss,
                                  -override=>1
                  )),"\n"
),
td({-align=>'left', -width=>'120'},
      submit(-value=>'Prosseguir')
))),
          &rodape_fechar,
        ),
        end_form,"\n",
        end_html;
}
print @body;


#-----------------------------------------------------------------------------
sub getParametros() {
#-----------------------------------------------------------------------------
    my (%paramTemp);

    foreach (param) {
        if (!exists($paramTemp{$_})) {
            $paramTemp{$_} = param($_);
        }
    }
    if (!exists($paramTemp{etapa})) {
       $paramTemp{etapa} = 1;
    }

    return %paramTemp;
}
#-----------------------------------------------------------------------------
sub montar_pagina() {
#-----------------------------------------------------------------------------
(my @linhas) = @_;

return "
<table cellspacing=0 cellpadding=0 border=0 width=548>
<tr>
   <td width=100% height=23 bgcolor=#A8CDEC align=center>
      <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Ordem de pagamento</b>
      </font>
   </td>
</tr>
<table cellspacing=1 cellpadding=0 border=0 width=550>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           Número da OP
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{numop}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           Situação
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{situacao}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Data de entrega da OP
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{dataent}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Data de pagamento da OP
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{datapgt}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Data de emissão da NF
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{datanfs}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Quantidade de serviços
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{qtdserv}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Valor total
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{vlrtot}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Descontos
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{dsctot}
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
          Valor Pago
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           $parametros{vlrpago}
       </font>
   </td>
</tr>
</table>
@linhas
";
}
#------------------------------------------------------------------------
sub setarcamposHidden() {
#------------------------------------------------------------------------
return "
<input type=hidden name=usrtip value='$parametros{usrtip}'>
<input type=hidden name=webusrcod value='$parametros{webusrcod}'>
<input type=hidden name=sesnum value='$parametros{sesnum}'>
<input type=hidden name=macsissgl value='$parametros{macsissgl}'>
<input type=hidden name=dataini value='$parametros{dataini}'>
<input type=hidden name=datafnl value='$parametros{datafnl}'>
<input type=hidden name=situacao value='$parametros{situacao_slv}'>
<input type=hidden name=numop value='$parametros{numop}'>
<input type=hidden name=codorigem value='$parametros{codorigem}'>
<input type=hidden name=acao value='$parametros{acao}'>
<input type=hidden name=dataent value='$parametros{dataent}'>
<input type=hidden name=datapgt value='$parametros{datapgt}'>
<input type=hidden name=datanfs value='$parametros{datanfs}'>
<input type=hidden name=datanfsqtdserv value='$parametros{datanfsqtdserv}'>
<input type=hidden name=vlrtot value='$parametros{vlrtot}'>
<input type=hidden name=dsctot value='$parametros{dsctot}'>
<input type=hidden name=vlrpago value='$parametros{vlrpago}'>
<input type=hidden name=etapa value='$parametros{etapa}'>
<input type=hidden name=flagassina value='$flagassina'>
<input type=hidden name=flagaceite value='$flagaceite'>
<input type=hidden name=infissalq value=''>
";
}

#------------------------------------------------------------------------
sub rodape_btn_imprimir() {
#------------------------------------------------------------------------

return "
 <br>
 <br>
 <table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><input type='button' name='btoSubmit' value='Nova Consulta' onClick='JavaScript:document.forms[0].action = \"wdatc036.pl\";document.forms[0].submit();'> <input type='button' value='Dados Para Envio De Nota' onClick='imprimirProtOp(\"3\")'> <input type='button' value='Imprimir OP' onClick='imprimirProtOp(\"2\");' >
</tr></table>

<br>

<table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td><a href='JavaScript:history.back()'><img border='0' width='79' height='15' src='/corporat/images/bot_voltar.gif'></a></td> <td valign='bottom' align='right'><img width='36' height='16' src='/corporat/images/blue_box.gif'></td></tr> <tr><td align='right' colspan='2'><img width='550' height='1' src='/corporat/images/linha_azul.gif'></td>
</tr>

</table>
";

}
#-----------------------------------------------------------------------------
sub java_script() {
#-----------------------------------------------------------------------------
return "
//----------------------------------------------------------------------------
function imprimirProtOp(acao) {
//----------------------------------------------------------------------------
  var codorigem = document.forms[0].origem.value;

  document.forms[0].acao.value = acao;

  if (acao == 2 && document.forms[0].origem.value == '0') {
         alert ('Selecione uma origem para impressão !');
         document.forms[0].origem.focus();
         document.forms[0].origem.select();
         return;
  }

  if (document.forms[0].etapa.value == 1) {
     var vetapa = 1;
     if ( document.forms[0].flagassina.value == 'S' ) {
        vetapa = 2;
     }

     var strPagina = '/cgi-bin/ct24h/trs/wdatc039.pl?usrtip=$parametros{usrtip}&webusrcod=$parametros{webusrcod}&sesnum=$parametros{sesnum}&macsissgl=$parametros{macsissgl}&numop=$parametros{numop}&dataent=$parametros{dataent}&datapgt=$parametros{datapgt}&datanfs=$parametros{datanfs}&qtdserv=$parametros{qtdserv}&vlrtot=$parametros{vlrtot}&optante=$optante&codorigem=' + codorigem + '&acao=' + acao + '&etapa=' + vetapa + '&aliquotaiss=' + document.forms[0].infissalq.value;


     var strNavparam = 'height=400,width=650,left=50,top=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';
     if (navigator.appName.indexOf('Netscape') != -1) {
         strNavparam = 'Impressao','height=400,width=650,screenX=50,screenY=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';
     }
     janela=window.open(strPagina,'Impressao',strNavparam).focus();
  } else {
     document.forms[0].action = \"/cgi-bin/ct24h/trs/wdatc039.pl\"
     document.forms[0].submit();
     return;
  }
}

";
}

sub java_script_pop() {
#-----------------------------------------------------------------------------
return "
function check_dados() {
//----------------------------------------------------------------------------

   if (!document.forms[0].concordo.checked ) {
      alert ('Obrigatorio concordar' );
      document.forms[0].concordo.focus;
      return (false);
   }
   if (document.forms[0].optante.checked ) {
      document.forms[0].optante.value = 'Sim';

      idx_iss = document.forms[0].aliquotaiss.selectedIndex;
      if (document.forms[0].aliquotaiss.options[idx_iss].value == '0' ) {
         alert ('Selecione uma aliquota' );
         return (false);
      }
      document.forms[0].infissalq.value = document.forms[0].aliquotaiss.options[idx_iss].value;

   } else {
      document.forms[0].optante.value = 'Nao';
      document.forms[0].infissalq.value = 0;
   }
   document.forms[0].etapa.value = '3';

   return true;
}
";
}

#-----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub montar_protocolo() {
#----------------------------------------------------------------------------
my ($lixo, $codPrest, $cgc, $razSoc, $tipPrest, $crnPrest, $tipPagnt, $totServ,
    $totRel, $nomrazEmp, $cnpjSuc, $endSuc, $brrSuc, $inscSuc, $inscEmp, $nomatvpri, $dataent, $tel) = @_;

if ($tipPagnt == "3")
{
   $tel = '3668'
}else{ $tel = '3667'}

return "
<br>
<br>
<br>
<table cellspacing=0 cellpaddinng=0 border=1 width=550>
<tr>
  <td width=165 align=left valign=top>
   <table cellspacing=0 cellpaddinng=0 border=0 width=100%>
   <!-- <td width=101 align=left valign=top> -->
   <td width=40 align=left valign=top>
   <!--  <img src='/ct24h/images/logoPorto.jpg' width=100 height=128> -->
         <img src=$image02>
   </td>
   <td width=229 align=left valign=top>
     <font face='ARIAL,HELVETICA,VERDANA' size=1>
        <b>
           $nomeseg<br />
        </b>
     </font>
     <font face='ARIAL,HELVETICA,VERDANA' size=1>
        <b>
           $infoseg
        </b>
     </font>
    </table>

  </td>
  <td width=385 align=center>
    <font face='ARIAL,HELVETICA,VERDANA' size=2>
      <b>
        Dados para preenchimento e envio da Nota Fiscal
      </b>
    </font>
  </td>
</tr>
</table>
<table cellspacing=0 cellpadding=0 border=1 width=550>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Código do prestador:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>$codPrest</b>
             </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>CNPJ/CPF:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>$cgc</b>
                     </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Razão Social:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
                <b>$razSoc</b>
                     </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Tipo Prestador:</b>
     </font>
   </td>
   <td align=left  width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>$tipPrest</b>
                     </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Cronograma:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>$crnPrest</b>
                     </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Tipo Pagamento:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>$tipPagnt</b>
                     </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>

<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Data da entrega:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
            <font face='ARIAL,HELVETICA,VERDANA' size=2>
               <b>$dataent</b>
          </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Data de pagamento:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
            <font face='ARIAL,HELVETICA,VERDANA' size=2>
              <b>&nbsp;</b>
            </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Qtde. total de serviços:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
                <b>$totServ</b>
              </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Quantidade de relações:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
                <b>$totRel</b>
              </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Preenchido por:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
             <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>&nbsp;</b>
         </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
</table>
<table cellspacing=0 cellpaddinng=0 border=1 width=550>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
      <font face='ARIAL,HELVETICA,VERDANA' size=3>
         <b><i>Emitir nota fiscal para :</i></b>
       </font>

   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $nomrazEmp
     </font>
   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $cnpjSuc
     </font>
   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $endSuc
     </font>
   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $brrSuc
     </font>
   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $inscEmp
     </font>
   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $inscSuc
     </font>
   </td>
</tr>
</table>
<table cellspacing=0 cellpaddinng=0 border=1 width=550>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
      <font face='ARIAL,HELVETICA,VERDANA' size=3>
         <b><i>No campo descricão de serviço de sua nota fiscal, preencher:</i></b>
       </font>

   </td>
</tr>
<tr>
   <td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        $nomatvpri - Conforme OP numero N° $parametros{numop}
     </font>
   </td>
</tr>
</table>
         <table cellspacing=0 cellpaddinng=0 border=1 width=550>
         <tr><td align=left width=30% height=20 valign=middle bordercolor=FFFFFF>
         <font face='ARIAL,HELVETICA,VERDANA' size=3>
         <b><i>
         Lembramos que, apesar de preencher a NF conforme instruções acima, o pagamento continua sendo realizado pela Matriz. Portanto, os lotes e as NF´s devem ser enviados para o endereço abaixo:
         </i></b><br />
         </font>
         <font face='ARIAL,HELVETICA,VERDANA' size=2 color='red'>
         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Caixa postal: 13818 CEP - 01216-970<br /><br />
         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;À PORTO SEGURO CIA DE SEGUROS GERAIS<br />
         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RUA GUAIANASES, 1227 - CEP: 01204-001<br />
         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; CAMPOS ELÍSIOS - SÃO PAULO - SP<br />
         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;A/C DEPARTAMENTO PORTO SOCORRO<br />
         </font>
         </td></tr>
         </table>
<table cellspacing=0 cellpadding=0 border=0 width=550>
<tr>
   <td align=left walign=left idth=100% height=30 valign=bottom>
      <font face='ARIAL,HELVETICA,VERDANA' size=2'>
         <b><i>PARA USO EXCLUSIVO DO PORTO SOCORRO :</i></b>
         </font>
   </td>
</tr>
</table>
<table cellspacing=0 cellpaddinng=0 border=1 width=550>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Número do protocolo:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
                 <font face='ARIAL,HELVETICA,VERDANA' size=2>
                    <b>$parametros{numop}</b>
                 </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Data de recebimento:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
                 <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>&nbsp;</b>
         </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<tr>
   <td align=left width=30% height=25 valign=middle bordercolor=FFFFFF>
     <font face='ARIAL,HELVETICA,VERDANA' size=2>
        <b>Protocolado por:</b>
     </font>
   </td>
   <td align=left width=60% valign=middle bordercolor=FFFFFF>
      <table cellspacing=0 cellpadding=0 border=1 width=100% valign=middle>
         <tr>
             <td height=20 width=100%>
                  <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b>&nbsp;</b>
         </font>
             </td>
         </tr>
      </table>
   </td>
   <td width=10% bordercolor=FFFFFF>&nbsp;</td>
</tr>
<table cellspacing=0 cellpadding=0 border=0 width=550>
<tr>
   <td align=left width=100%  height=30 valign=bottom>
        <font face='ARIAL,HELVETICA,VERDANA' size=2>
            <b><i>OBSERVAÇÕES:</i></b>
         </font>
    </td>
</tr>
<tr>
    <td align=left width=100%>
        <font face='ARIAL,HELVETICA,VERDANA' size=2>
         - Preenchimento em 2(duas) vias.<br />
         - Em caso de dúvida, entrar em contato através do telefone (11) 3366-$tel.<br />
        </font>
    </td>
</tr>
</table>
";
}
#------------------------------------------------------------------------
sub rodape_fechar() {
#------------------------------------------------------------------------

return "
<br>
<table cellpadding='0' width='550' cellspacing='0' border='0'><tr><td align='left'>
  <input type='button' name='fechar' value='Fechar' onClick='JavaScript:window.close();' >
</td> <td valign='bottom' align='right'><img width='36' height='16' src='/corporat/images/blue_box.gif'></td></tr> <tr><td align='right' colspan='2'><img width='550' height='1' src='/corporat/images/linha_azul.gif'></td>
</tr>
</table>
";

}

#------------------------------------------------------------------------
sub getComunicado() {
#------------------------------------------------------------------------

return "
    <br/>
    <p>&nbsp;&nbsp;&nbsp;&nbsp;
A empresa prestadora de serviços deve informar se está <i>regularmente inscrita no Regime Especial Unificado de Arrecadação de Tributos e Contribuições das Microempresas e das Empresas de Pequeno Porte <b>Simples Nacional</b></i> ( regime tributário previsto na Lei Complementar nº123, de 2006, aplicável às Microempresas e às Empresas de Pequeno Porte), assumindo compromisso de comunicar o eventual desenquadramento nesta condição e ciente de que a falsidade na prestação destas informações sujeitará o responsável às penalidades previstas na legislação.</p>
    <p>&nbsp;&nbsp;&nbsp;&nbsp;
Qualquer duvida com relação o Simples Nacional, favor entrar em contato com o seu contador.</p>
    <p>&nbsp;&nbsp;&nbsp;&nbsp;<b>
Após concordar com comunicado acima, caso sua empresa seja optante pelo SIMPLES NACIONAL, selecione a opção 'optante pelo simples' e, então, em 'prosseguir'. Caso sua empresa não seja optante pela modalidade, clique diretamente em 'prosseguir'.
    </b></p>
    <br/>
    <br/>
" ;
}
