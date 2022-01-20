#!/usr/bin/perl
#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Ct24h                                                     #
# Modulo         : wdatc036.pl                                               #
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
   @body,
   @ARG,
   %parametros
   );

#$ambiente = "remsh aplweb01 -l runwww ";

#-----------------------------------------------------------------------------
# Inclusao das subrotinas que montam campos, textos, botoes, etc.
#-----------------------------------------------------------------------------
require "/webserver/cgi-bin/seweb/trs/wissc210.pl";  #--> Gera cabecalho da pagina
require "/webserver/cgi-bin/seweb/trs/wissc211.pl";  #--> Gera rodape da pagina
require "/webserver/cgi-bin/seweb/trs/wissc219.pl";  #--> Gera pagina de mensagem/erro

#-----------------------------------------------------------------------------
# Carrega parametros recebidos e de padroes
#-----------------------------------------------------------------------------
%parametros = &getParametros();

#OSF 20370
#$cabec = "CONSULTA ORDENS DE PAGAMENTO";
$cabec = "ORDENS DE PAGAMENTO";

$texto  = "";
$titgif = "/auto/images/ramo_psocorro.gif";

#-----------------------------------------------------------------------------
# Executa programa Infomix 4GL e tratar os displays
#-----------------------------------------------------------------------------
push @ARG ,$parametros{usrtip},
           $parametros{webusrcod},
           $parametros{sesnum},
           $parametros{macsissgl};

$ARG = sprintf("'%s'",join('\' \'',@ARG));

$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc037.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

while (<PROG>) {
      chomp;

      split ('@@');

      if (@_[0] eq "ERRO") {
         &wissc219_mensagem($titgif,$cabec,$_[2],$_[1]);
         exit(0);
      }
}

close (PROG);


push @body,
     header,
      start_html(-title=>'Porto Seguro', -BGCOLOR=>'#FFFFFF', -script=>&js),
      "<script language='JavaScript' src='/geral/trs/wiasc007.js'></script>",
      center
      (
         &wissc210_cabecalho($titgif,$cabec,$texto),
           start_form(-action=>'wdatc037.pl',
                      -method=>'post',
                      -name=>'wdatc036',
                      -onSubmit=>'return checa_dados()'),
              &montar_pagina() ,
              &wissc211_rodape('','1'),
           end_form()
      ),
      end_html;

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

    return %paramTemp;
}
#-----------------------------------------------------------------------------
sub montar_pagina() {
#-----------------------------------------------------------------------------
(my $corpo) ;

$corpo = "
<table cellspacing=1 cellpadding=0 border=0 width=550>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           De
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           <input type=text name=dataini size=10 maxlength=10 onBlur='this.value=wiasc007_formataData(this.value)'> (Ex: dd/mm/aaaa)
       </font>
   </td>
</tr>
<tr>
   <td width=30% height=23 bgcolor=#A8CDEC align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           Até
       </font>
   </td>
   <td width=70% height=23 bgcolor=#D7E7F1 align=left>
       <font face='ARIAL,HELVETICA,VERDANA' size=1>
           <input type=text name=datafnl size=10 maxlength=10 onBlur='this.value=wiasc007_formataData(this.value)'> (Ex: dd/mm/aaaa)
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
           <select name=situacao size=1>
               <option value='0'>Selecione uma opção</option>
               <option value='1'>Todas</option>
               <option value='2'>A Faturar</option>
               <option value='3'>Pagas</option>
           </select>
       </font>
   </td>
</tr>
</table>
<input type=hidden name=usrtip value='$parametros{usrtip}'>
<input type=hidden name=webusrcod value='$parametros{webusrcod}'>
<input type=hidden name=sesnum value='$parametros{sesnum}'>
<input type=hidden name=macsissgl value='$parametros{macsissgl}'>
";

return $corpo;
}
#--------------------------------------------------------------------------
sub js() {
#--------------------------------------------------------------------------
return "
function checa_dados() {
     var form1 = document.forms[0];
     if (!wiasc007_parseValidaData( form1.dataini.value )) {
         alert ('Data inicial inválida !');
         form1.dataini.focus();
         form1.dataini.select();
         return false;
     }
     if (!wiasc007_parseValidaData( form1.datafnl.value )) {
         alert ('Data final inválida !');
         form1.datafnl.focus();
         form1.datafnl.select();
         return false;
     }
     if (form1.situacao.value == 0) {
         alert ('Selecione a situação !');
         form1.situacao.focus();
         return false;
     }


     var ini = parseInt(form1.dataini.value.substring(6,10) +
                        form1.dataini.value.substring(3,5)  +
                        form1.dataini.value.substring(0,2));

     var fnl = parseInt(form1.datafnl.value.substring(6,10) +
                        form1.datafnl.value.substring(3,5)  +
                        form1.datafnl.value.substring(0,2));

     if (ini > fnl) {
         alert ('Data final não pode ser menor que inicial !');
         return false;
     }
     return true;
}
";
}
