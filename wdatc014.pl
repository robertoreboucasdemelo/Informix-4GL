#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc014.pl                                                    #
#  Sistema..: Prestador OnLine                                               #
#  Criacao..: Ago/2001                                                       #
#  Autor....: Marcus                                                         #
#                                                                            #
#  Objetivo.: Programa principal de recebimento de Servicos pela Internet    #
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
#require "/webserver/cgi-bin/seweb/trs/wissc204.pl";     #--> Gera list box
#require "/webserver/cgi-bin/seweb/trs/wissc205.pl";     #--> Gera check box
#require "/webserver/cgi-bin/seweb/trs/wissc206.pl";     #--> Gera radio box
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
     $som,
     $teste,
     $tagsom,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape,
     $JSCRIPT,
     $webusrcod,
     $sesnum,
     $macsissgl,
     $usrtip
   );


#$ambiente = "remsh aplweb01 -l runwww ";

$webusrcod=param("webusrcod");

$sesnum = param("sesnum");

$macsissgl = param("macsissgl");

$usrtip = param("usrtip");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
#push @ARG,$prestador,$usrtip,$webusrcod,$sesnum,$macsissgl;
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl;

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $cabec  = 'RECEBER SERVIÇOS';
#$titgif = '/seweb/images/c_acesso.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';
#$tagsom = '<EMBED src="/ct24h/trs/MCITEST.WAV" width=0 height=0 autostart=true>';
 $tagsom = '<bgsound src="/ct24h/trs/MCITEST.WAV" loop="1">';
 $som    = 0;
 $teste = '';

#$padrao = param("padrao");
# if (!defined($padrao))
#   { &wissc219_mensagem($titgif,$cabec,"LOGIN","Código do padrão não informado!"); }

#push @ARG, $padrao;
 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc015.4gc $ARG 2>&1)";

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

    elsif ($REGISTRO[0] eq "SOM")
       { $som = 1; }

    elsif ($REGISTRO[0] eq "PADRAO")
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
 $texto    = 'Consulte os serviços pendentes. O sistema é atualizado a cada 30 segundos. Caso não clique sobre o serviço, automaticamente será repassado a outro prestador. Veja no final da tela se existem complementos de serviço.';

 if ($som == 1)
   {  $teste = 'window.focus();'; }

 &cria_javascript;

 push @cabecalho, header(-'expires'=>'-1d',
                         -'pragma'=>'no-cache',
                         -'cache-control'=>'no-store'), "\n",

 start_html(-'title'=>'Porto Seguro',
            -script=>$JSCRIPT,
            -onLoad=>'comeco();',
            -bgcolor=>'#FFFFFF',
           ),"\n",

 start_form(-method=>'POST'
           ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 push @rodape, &wissc211_rodape("",0);

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------

 push @html, @cabecalho;
 if ($som == 1)
  { push @html, $tagsom; }
 push @html,
 center(
        @body, @rodape
       ),"\n",

 end_form,"\n",
 end_html,"\n";

 print @html;

 exit(0);


#-----------------------------------------------------------------------------
 sub cria_javascript
#-----------------------------------------------------------------------------
{
 $JSCRIPT=<<END;
 function funcchama()
 {
   var myemis = "/webserver/cgi-bin/ct24h/trs/wdatc014.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl";
   location = myemis;

 }
 function comeco()
 {
   setTimeout("funcchama()",90000);
   $teste
 }

END
}
#-----------------------------------------------------------------------------
 sub debugar()
#-----------------------------------------------------------------------------
 {
   print "Content-type: text/html\n\n";
   print "*** PARAMETROS WISSC201.PL ***  <br>\n";

 # print "Padrao 0  = $REGISTRO[0]       <br>\n";
 # print "Padrao 1  = $REGISTRO[1]       <br>\n";
 # print "Padrao 2  = $REGISTRO[2]       <br>\n";
 # print "Padrao 3  = $REGISTRO[3]       <br>\n";
 # print "Padrao 4  = $REGISTRO[4]       <br>\n";
 # print "Padrao 5  = $REGISTRO[5]       <br>\n";
 # print "Padrao 6  = $REGISTRO[6]       <br>\n";
 # print "Padrao 7  = $REGISTRO[7]       <br>\n";
 # print "Padrao 8  = $REGISTRO[8]       <br>\n";

 # foreach $texto (keys (%ENV))
 #   {
 #     print "$texto = $ENV{$texto}  <br>\n";
 #   }

   foreach $texto (keys (%INC))
     {
       print "$texto = $INC{$texto}  <br>\n";
     }

   exit(0);
 }
