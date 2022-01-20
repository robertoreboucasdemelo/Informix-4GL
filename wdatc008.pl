#!/usr/bin/perl

 #----------------------------------------------------------------------------#
 #  Modulo...: wdatc008.pl                                                    #
 #  Sistema..: Prestador OnLine                                               #
 #  Criacao..: Out/2001                                                       #
 #  Autor....: Marcus                                                         #
 #                                                                            #
 #  Objetivo.: Tela de sinais da viatura                                      #
 #----------------------------------------------------------------------------#
 # Alteracoes:                                                                #
 #                                                                            #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
 # 06/12/2002  PSI 150550   Zyon         Implementação da versão de impressão #
 # 22/11/2012  12113414     Issamu       Remoção do aviso para os Prestadores #
 #----------------------------------------------------------------------------#

 use CGI ":all";
 use strict;                #--> Obriga definicao explicita das variaveis
 use ARG4GL;                #--> Biblioteca erro no informix

 #-----------------------------------------------------------------------------
 # Inclusao das subrotinas que montam campos, textos, botoes, etc.
 #-----------------------------------------------------------------------------
 require "/webserver/cgi-bin/seweb/trs/wissc203.pl";     #--> Gera titulo
 require "/webserver/cgi-bin/seweb/trs/wissc207.pl";     #--> Gera Texto/Input/Texto
 require "/webserver/cgi-bin/seweb/trs/wissc208.pl";     #--> Gera colunas/tabelas
 require "/webserver/cgi-bin/seweb/trs/wissc209.pl";     #--> Gera titulo com help
 require "/webserver/cgi-bin/seweb/trs/wissc210.pl";     #--> Gera cabecalho da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc211.pl";     #--> Gera rodape da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc212.pl";     #--> Gera tabela com varias linhas
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
     $atdvclsgl,
     $ARG,
     $macsissgl,
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
     $usrtip,
     $inicio,
     $tot_sinais,
     @impressao,
     @botoes,
     $acao,
     $funcao
   );


 #-----------------------------------------------------------------------------
 # Identifica o ambiente - producao ou teste
 #-----------------------------------------------------------------------------
# ($maq) = split(" ",`hostname`);
# if ($maq eq 'u07')
#    { $ambiente = "remsh u28 -l corpt "; }
# else
#    { $ambiente = "remsh aplweb01 -l runwww "; }

$atdvclsgl =param("atdvclsgl");

$webusrcod=param("webusrcod");

$sesnum = param("sesnum");

$macsissgl = param("macsissgl");

$usrtip = param("usrtip");

$inicio = param("inicio");

$acao = param("acao");

$tot_sinais = -1;

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdvclsgl,$inicio,$acao;

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $cabec  = 'POSIÇÃO DA FROTA - SINAIS';
 $titgif = '/seweb/images/c_acesso.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';

 if ($acao == 2) {
    $texto  = '';
    $funcao = 'JavaScript:self.print();';
 } else {
    $texto  = 'Clique na sequência do movimento para detalhamento';
    $funcao = '';
 }

 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc009.4gc $ARG 2>&1)";

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
              { $tot_sinais = $tot_sinais + 1;
                push @body, &wissc208_coluna(@REGISTRO); }

        elsif ($REGISTRO[1] == 7)
              { push @body, &wissc209_titulohelp(@REGISTRO); }

        elsif ($REGISTRO[1] == 8)
              { push @body, &wissc212_linhas1(@REGISTRO); }

        elsif ($REGISTRO[1] == 9)
              { push @body, &wissc216_checklistbox(@REGISTRO); }

        elsif ($REGISTRO[1] == 10)
              { $tot_sinais = $tot_sinais + 1;
                push @body, &wissc225_colunaimpressao(@REGISTRO); }

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

 push @cabecalho, header,

 start_html(-'title'=>'Porto Seguro',
            -onLoad=>$funcao,
            -bgcolor=>'#FFFFFF',
            -'meta'=>{'http-equiv=Pragma content=no-cache'},
           ),"\n",

 start_form(-method=>'POST',
            -name=>'wdatc008',
            -action=>"/cgi-bin/ct24h/trs/$inicio"),"\n",

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
 hidden(-name=>'acao',
        -value=>$acao
       ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 if ($acao != 2) {
    push @impressao,
        "<input type='button' name='btnImp' value='Imprimir' onclick='doImpressao()'>",
        "<script language='JavaScript'>",
            "function doImpressao() {",
                "var strPagina = '/cgi-bin/ct24h/trs/wdatc008.pl?atdvclsgl=$atdvclsgl&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&usrtip=$usrtip&inicio=$inicio&acao=2';",
                "var strNavparam = 'height=400,width=650,left=50,top=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
                "if (navigator.appName.indexOf('Netscape') != -1) {",
                "    strNavparam = 'Impressao','height=400,width=650,screenX=50,screenY=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
                "}",
                "janela=window.open(strPagina,'Impressao',strNavparam);",
            "}",
        "</script>";
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
 if ($tot_sinais > 0) {
     if ($acao != 2) {
         push @rodape, &wissc211_rodape("BACK",0);
     } else {
         push @rodape, &wissc211_rodape("","00");
     }
  } else {
    push @rodape, &wissc211_rodape("BACK","05");
    @botoes=();
 }

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------
 push @html, @cabecalho;
 push @html,
 center(@body, @botoes, @rodape),"\n",
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
