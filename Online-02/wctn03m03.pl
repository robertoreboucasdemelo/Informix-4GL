#! /usr/local/bin/perl 

 #----------------------------------------------------------------------------#
 #  Modulo...: wctn03m03.pl                                                   #
 #  Sistema..: Prestador On Line PSRONLINE                                    #
 #  Criacao..: Ago/2001                                                       #
 #  Autor....: Marcus                                                         #
 #                                                                            #
 #  Objetivo.: Mostra complemento de informacoes de um servico                #
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
 require "../../seweb/trs/wissc203.pl";     #--> Gera titulo
 require "../../seweb/trs/wissc204.pl";     #--> Gera list box
 require "../../seweb/trs/wissc205.pl";     #--> Gera check box
 require "../../seweb/trs/wissc206.pl";     #--> Gera radio box
 require "../../seweb/trs/wissc207.pl";     #--> Gera Texto/Input/Texto
 require "../../seweb/trs/wissc208.pl";     #--> Gera colunas/tabelas
 require "../../seweb/trs/wissc209.pl";     #--> Gera titulo com help
 require "../../seweb/trs/wissc210.pl";     #--> Gera cabecalho da pagina
 require "../../seweb/trs/wissc211.pl";     #--> Gera rodape da pagina
 require "../../seweb/trs/wissc212.pl";     #--> Gera tabela com varias linhas 
 require "../../seweb/trs/wissc216.pl";     #--> Gera linha com checkbox/listbox
 require "../../seweb/trs/wissc218.pl";     #--> Vetores de conversao            
 require "../../seweb/trs/wissc219.pl";     #--> Gera pagina de mensagem/erro  
 require "../../seweb/trs/wissc220.pl";     #--> Checa erro no programa 4GL/BD             
 require "../../seweb/trs/wissc225.pl";     #--> Gera colunas/tabelas para versao de impressao

 #-----------------------------------------------------------------------------
 # Definicao das variaveis 
 #-----------------------------------------------------------------------------
 my( $maq,
     $ambiente,
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
     $caddat,
     $cadhor,
     $acao,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,     
     @body,     
     @cabecalho,
     @rodape  
   );

$ambiente = "remsh aplweb01 -l runwww ";

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
#$cabec  = 'RECEBER SERVI?OS - COMPLEMENTO';
 $titgif = '/seweb/images/c_acesso.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';

 $webusrcod=param("webusrcod");
 $sesnum = param("sesnum");
 $macsissgl = param("macsissgl");
 $usrtip = param("usrtip");
 $atdsrvnum = param("atdsrvnum");
 $atdsrvano = param("atdsrvano");
 $caddat    = param("caddat");
 $cadhor    = param("cadhor");
 $acao      = param("acao");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$caddat,$cadhor,$acao;     

#if (!defined($padrao))
#   { &wissc219_mensagem($titgif,$cabec,"LOGIN","C?digo do padr?o n?o informado!"); }

 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvar.sh; wctn03m03.4gc $ARG 2>&1)";

 open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

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
           { &wissc219_mensagem($titgif,$cabec,"BACK","Padr?o n?o previsto!"); }
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
 $texto    = 'Consulte as informa?oes sobre o complemento de servi?o.';

 if ($acao == 1)
    {
      $cabec  = 'RECEBER SERVI?OS - COMPLEMENTO';
    }
 else
    {
      $cabec  = 'CONSULTAR SERVI?OS - COMPLEMENTO';
    }
 push @cabecalho, header,

 start_html(-'title'=>'Porto Seguro',
            -bgcolor=>'#FFFFFF'
           ),"\n",

 start_form(-method=>'POST',
            -name=>'wctn03m03',
            -action=>"/cgi-bin/ct24h/trs/wctn03m04.pl"),"\n",

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
      ),"\n",
hidden(-name=>'caddat',
       -value=>$caddat
      ),"\n",
hidden(-name=>'cadhor',
       -value=>$cadhor
      ),"\n",
hidden(-name=>'acao',
       -value=>$acao,
      ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------

 if ($acao == 1) {
    push @rodape, &wissc211_rodape("BACK","05"); }
 else {
    push @rodape, &wissc211_rodape("BACK",0); }

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
