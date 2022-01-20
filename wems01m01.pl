#!/usr/bin/perl
##############################################################################
#  Modulo...: wems01m01.pl                                                   #
#  Sistema..: Relatorios gerenciais - Portonet                               #
#  Criacao..: Set/2001                                                       #
#  Autor....: Raji                                                           #
#                                                                            #
#  Objetivo.: Gera relatorio resumo de emissao/orcamento                     #
##############################################################################
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 04/07/2007 Luiz, Meta    AS143650  Retirada do teste da identificacao do   #
#                                    ambiente                                #
#----------------------------------------------------------------------------#

 use CGI ":all";
#use strict;                #--> Obriga definicao explicita das variaveis
 use ARG4GL;                #--> Biblioteca erro no informix

 #-----------------------------------------------------------------------------
 # Inclusao das subrotinas que montam campos, textos, botoes, etc.
 #-----------------------------------------------------------------------------
 require "/webserver/cgi-bin/seweb/trs/wissc203.pl";     #--> Gera titulo
#require "/webserver/cgi-bin/seweb/trs/wissc204.pl";     #--> Gera list box
#require "/webserver/cgi-bin/seweb/trs/wissc205.pl";     #--> Gera check box
#require "/webserver/cgi-bin/seweb/trs/wissc206.pl";     #--> Gera radio box
#require "/webserver/cgi-bin/seweb/trs/wissc207.pl";     #--> Gera Texto/Input/Texto
 require "/webserver/cgi-bin/seweb/trs/wissc208.pl";     #--> Gera colunas/tabelas
 require "/webserver/cgi-bin/seweb/trs/wissc209.pl";     #--> Gera titulo com help
 require "/webserver/cgi-bin/seweb/trs/wissc210.pl";     #--> Gera cabecalho da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc211.pl";     #--> Gera rodape da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc212.pl";     #--> Gera tabela com varias linhas
#require "/webserver/cgi-bin/seweb/trs/wissc216.pl";     #--> Gera linha com checkbox/listbox
 require "/webserver/cgi-bin/seweb/trs/wissc218.pl";     #--> Vetores de conversao
 require "/webserver/cgi-bin/seweb/trs/wissc219.pl";     #--> Gera pagina de mensagem/erro
 require "/webserver/cgi-bin/seweb/trs/wissc229.pl";     #--> Tabela

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
     $orcflg,

     $autoflg,
     $reflg,

     $col1,
     $col2,
     $col3,

     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape
   );


#$ambiente = "remsh aplweb01 -l runwww ";

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $cabec  = 'RELATÓRIOS GERENCIAIS';
 $titgif = '/auto/images/emissao.gif';

 $reltip = param("reltip");
 $perini = param("perini");
 $perter = param("perter");
 $ramcod = param("ramcod");
 $succod = param("succod");
 $iptcod = param("iptcod");
 $unocod = param("unocod");
 $tecmat = param("tecmat");
 $pdtcod = param("pdtcod");
 $inpcod = param("inpcod");
 $corgrpcod = param("corgrpcod");
 $corsus = param("corsus");
 $cdngrlcod = param("cdngrlcod");
 $corhldcod = param("corhldcod");
 $aplflg = param("aplflg");
 $prpflg = param("prpflg");
 $orcflg = param("orcflg");

 $autoflg = param("autoflg");
 $reflg   = param("reflg");

 $col1 = param("col1");
 $col2 = param("col2");
 $col3 = param("col3");

 $usrtip = param("usrtip");
 $usrcod = param("usrcod");
 $sesnum = param("sesnum");
 $empcod = param("empcod");

 push @ARG, $usrtip, $usrcod, $sesnum, $empcod
          , $reltip, $perini, $perter, $ramcod,    $succod, $iptcod, $unocod
          , $tecmat, $pdtcod, $inpcod, $corgrpcod, $corsus, $cdngrlcod
          , $corhldcod, $aplflg, $prpflg, $orcflg, $col1, $col2, $col3
          , $autoflg, $reflg ;
 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #print header;
 #print $ARG;

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvardsa.sh; wems01m01.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

 #-----------------------------------------------------------------------------
 # Montando body variavel @body (parte central do fonte HTML)
 #-----------------------------------------------------------------------------
 $width{"0"} = 860;

# print header, "ANTES DO WHILE DO PROG" . br();
 while (<PROG>)
   {
    #--------------------------------------------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------------------------------------------
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

    @REGISTRO = split '@@',$_;

    if ($REGISTRO[0] eq "TAMANHO")
       { $width{"0"} = $REGISTRO[1];
         next; }

    if ($REGISTRO[0] eq "TITULO")
       { $cabec = $REGISTRO[1];
         next; }

    if ($REGISTRO[0] eq "TEXTO")
       { $texto = $REGISTRO[1];
         next; }

    if ($REGISTRO[0] eq "NOSESS")
       { &wissc219_mensagem($titgif,$cabec,"LOGIN3",$REGISTRO[1]); }

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

        elsif ($REGISTRO[1] == 11)
              { push @body, &wissc229_tabela(@REGISTRO); }

        else
           { &wissc219_mensagem($titgif,$cabec,"BACK","Padrão não previsto!"); }
       }
    else
       { &wissc219_mensagem($titgif,$cabec,"BACK","Trata outro tipo de registro!"); }
   }

 close(PROG);

 #-----------------------------------------------------------------------------
 # Montando cabecalho (parte inicial do fonte HTML)
 #-----------------------------------------------------------------------------
# $texto    = 'Esta operação é de responsabilidade exclusiva do administrador, não cabendo a Porto Seguro nenhuma responsabilidade pelo uso indevido deste recurso.<br><br> Caso você queira, a qualquer momento, liberar o acesso ao Site para um novo usuário, você poderá fazê-lo preenchendo os campos abaixo, e para concluir clique em "Enviar".<br><br> Para obter informações sobre os níveis de acesso do perfil, clique sobre "Níveis".';

 push @cabecalho, header,

 start_html(-'title'=>'Porto Seguro',
            -bgcolor=>'#FFFFFF',
            -script=>&js,
           ),"\n",

 start_form(-method=>'POST',
            -name=>'wissc201',
           ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 push @rodape, &wissc211_rodape("BACK",0);

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------
 push @html, @cabecalho,
 center(
        table({-border=>'0',-width=>'550',-cellspacing=>'0',-cellpadding=>'0'},"\n",
               @body, @rodape
             ),"\n"
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
   print "*** PARAMETROS .PL ***  <br>\n";

   print "REGISTRO = @REGISTRO    <br>\n";


 #  exit(0);
 }
#-----------------------------------------------------------------------------
sub js() {
#-----------------------------------------------------------------------------

return "
function open_help(arq, id)
     {
       if (navigator.appName == 'Microsoft Internet Explorer')
          {
            window.open(arq,id,'left=50,top=50,toolbar=no,menubar=no,height=500,width=600,status=no,resizable=yes,scrollbars=1');
          }
       else
          {
            window.open(arq,id,'screenX=50,screenY=50,toolbar=no,menubar=no,height=500,width=600,status=no,resizable=yes,scrollbars=1');
          }
     }

";
}
