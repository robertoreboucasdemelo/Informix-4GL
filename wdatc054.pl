#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc052.pl                                                    #
#  Sistema..: Prestador OnLine                                               #
#  Criacao..: Maio/2003                                                      #
#  Autor....: Rodrigo Santos                                                 #
#                                                                            #
#  Objetivo.: Mostrar os servicos recebido pela internet                     #
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
#require "/webserver/cgi-bin/seweb/trs/wissc205.pl";     #--> Gera check box
 require "/webserver/cgi-bin/seweb/trs/wissc206.pl";     #--> Gera radio box
 require "/webserver/cgi-bin/seweb/trs/wissc207.pl";     #--> Gera Texto/Input/Texto
 require "/webserver/cgi-bin/seweb/trs/wissc208.pl";     #--> Gera colunas/tabelas
 require "/webserver/cgi-bin/seweb/trs/wissc209.pl";     #--> Gera titulo com help
 require "/webserver/cgi-bin/seweb/trs/wissc210.pl";     #--> Gera cabecalho da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc211.pl";     #--> Gera rodape da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc212.pl";     #--> Gera tabela com varias linhas
#require "/webserver/cgi-bin/seweb/trs/wissc216.pl";     #--> Gera linha com checkbox/listbox
 require "/webserver/cgi-bin/seweb/trs/wissc218.pl";     #--> Vetores de conversao
 require "/webserver/cgi-bin/seweb/trs/wissc219.pl";     #--> Gera pagina de mensagem/erro
 require "/webserver/cgi-bin/seweb/trs/wissc220.pl";     #--> Checa erro no programa 4GL/BD
 require "/webserver/cgi-bin/seweb/trs/wissc225.pl";     #--> Gera colunas/tabelas para versao de impressao

 #-----------------------------------------------------------------------------
 # Definicao das variaveis
 #-----------------------------------------------------------------------------
 my( $maq,
    #$ambiente,
     $cabec,
     $titgif,
     $padrao,
     $texto,
     $prog,
     $line,
     $ARG,
     $macsissgl,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape,
     $webusrcod,
     $sesnum,
     $macsissgl,
     $usrtip,
     $de,
     $ate,
     $consulta,
     $srvorg,
     $status,
     $JSCRIPT,
     $q
   );

#$ambiente = "remsh aplweb01 -l runwww ";

$webusrcod=param("webusrcod");
$sesnum = param("sesnum");
$macsissgl = param("macsissgl");
$usrtip = param("usrtip");
$de = param("de");
$ate = param("ate");
$consulta = param("consulta");
$srvorg = param("srvorg");
$status = param("status");


#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$de,$ate,$consulta,$srvorg,$status;

$JSCRIPT=<<END;
<script language="JavaScript">
<!--
function func_checa()
{
  if (!document.forms[0].consulta[0].checked &&
      !document.forms[0].consulta[1].checked) {
     alert ("Favor informar o tipo de consulta !");
     return false;
  }

  if (document.forms[0].de.value == "") {
     alert ("Favor informar a data inicial !");
     return false;
  }

  if (document.forms[0].ate.value == "") {
     alert ("Favor informar a data final !");
     return false;
  }

  return true;
}
//-->
</script>
END

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $cabec  = 'SERVIÇOS RECEBIDOS';
 $titgif = '/seweb/images/c_acesso.gif';
#$titgif = '/carlos/sc/atend_vida_prev.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';

 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc055.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
 open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

 #-----------------------------------------------------------------------------
 # Montando body variavel @body (parte central do fonte HTML)
 #-----------------------------------------------------------------------------
 while (<PROG>)
   {
    #--------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------
    &wissc220_veriferro($_, $macsissgl);
    chomp;

    @REGISTRO = split '@@',$_;

    if ($REGISTRO[0] eq "NOSESS")
       { &wissc219_mensagem($titgif,$cabec,"LOGIN",$REGISTRO[1]); }

    elsif ($REGISTRO[0] eq "ERRO")
       { &wissc219_mensagem($titgif,$cabec,"BACK",$REGISTRO[1]); }

    if ($REGISTRO[0] eq "PADRAO")
       {
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
              { push @body, &wissc225_colunaimpressao(@REGISTRO); }

        else
           { &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!"); }
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
 $texto    = 'Caso queira consultar informações mais detalhadas, clique sobre o número do serviço.';

 push @cabecalho, header(-'expires'=>'-1d',
                         -'pragma'=>'no-cache',
                         -'cache-control'=>'no-store'), "\n",

 start_html(-'title'=>'Porto Seguro',
            -bgcolor=>'#FFFFFF',
            -script=>{-language=>'JavaScript1.2',
                      -src=>'/ct24h/trs/wdatc036.js' }
           ),"\n",

 $JSCRIPT,

 start_form(-method=>'POST',
            -name=>'wdatc052',
            -action=>"/cgi-bin/ct24h/trs/wdatc054.pl",
            -onsubmit=>"return func_checa()"
           ),"\n",

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
       ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 push @rodape, &wissc211_rodape("BACK","0");

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------
 push @html, @cabecalho,
 center(
        @body, @rodape
       ),"\n",

 end_form,"\n",
 end_html,"\n";

 print @html;

 exit(0);


#-----------------------------------------------------------------------------
 sub debugar()
#-----------------------------------------------------------------------------
 {
   print "Content-type: text/html\n\n";

   print "REGISTRO  = $REGISTRO[10]   <br>\n";

 # exit(0);
 }
