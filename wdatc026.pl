#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wdatc026.pl                                                    #
#  Sistema..: Prestador On Line PSRONLINE                                    #
#  Criacao..: Set/2001                                                       #
#  Autor....: Marcus                                                         #
#                                                                            #
#  Objetivo.: Conclusao Servico - Tela de confirmacao quando aceito          #
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
     $webusrcod,
     $sesnum,
     $macsissgl,
     $usrtip,
     $atdsrvnum,
     $atdsrvano,
     $atdprvdat,
     $srvobs,
     $txivlr,
     $acao,
     $ciaempcod,
     $image,
     $nomeseg,
     @ARG,
     @trataerro,
     @REGISTRO,
     @html,
     @body,
     @cabecalho,
     @rodape,
     $hotel,
     $estado_htl,
     $cidade_htl,
     $bairro_htl,
     $endereco_htl,
     $referencia_htl,
     $contato,
     $telefone_htl,
     $diaria,
     $acomodacao,
     $obs,
     $hpdqrtqtd
   );

#$ambiente = "remsh aplweb01 -l runwww ";

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $cabec  = 'RECEBER SERVIÇOS - CONFIRMAÇÃO';
 $titgif = '/seweb/images/c_acesso.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';

 $webusrcod=param("webusrcod");
 $sesnum = param("sesnum");
 $macsissgl = param("macsissgl");
 $usrtip = param("usrtip");
 $atdsrvnum = param("atdsrvnum");
 $atdsrvano = param("atdsrvano");
 $atdprvdat = param("atdprvdat");
 $srvobs    = param("srvobs");
 $txivlr    = param("txivlr");
 $hotel     = param("hotel");
 $estado_htl     = param("estado_htl");
 $cidade_htl     = param("cidade_htl");
 $bairro_htl     = param("bairro_htl");
 $endereco_htl   = param("endereco_htl");
 $referencia_htl = param("referencia_htl");
 $contato        = param("contato");
 $telefone_htl   = param("telefone_htl");
 $diaria         = param("diaria");
 $acomodacao     = param("acomodacao");
 $obs            = param("obs");
 $hpdqrtqtd      = param("hpdqrtqtd");
 $acao           = param("Acao");

 if ($atdprvdat eq "") { $atdprvdat = "00:00" } ;
 if ($srvobs eq "") { $srvobs = "." } ;
 if ($txivlr eq "") { $txivlr = "0" } ;
 if ($acao eq "") { $acao = "X" } ;

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$acao,$atdprvdat,$srvobs,$txivlr, $hotel, $estado_htl, $cidade_htl, $bairro_htl, $endereco_htl, $referencia_htl, $contato, $telefone_htl, $diaria, $acomodacao, $obs, $hpdqrtqtd ;

#if (!defined($padrao))
#   { &wissc219_mensagem($titgif,$cabec,"LOGIN","Código do padrão não informado!"); }

 $ARG = sprintf("'%s'",join('\' \'',@ARG));
#print header, start_html,$ARG;

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc027.4gc $ARG 2>&1)";

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
       ###{ next; }

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

        elsif ($REGISTRO[1] == 12)
              { $ciaempcod = $REGISTRO[2]; }

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

 push @body,
    "<script language='JavaScript'>",
        "function doImpressao() {",
            "var strPagina = '/webserver/cgi-bin/ct24h/trs/wdatc016.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&atdsrvnum=$atdsrvnum&atdsrvano=$atdsrvano&acao=2';",
            "var strNavparam = 'height=400,width=650,left=50,top=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
            "if (navigator.appName.indexOf('Netscape') != -1) {",
            "    strNavparam = 'Impressao','height=400,width=650,screenX=50,screenY=50,toolbar=yes,menubar=no,scrollbars=yes,resizable=no,status=yes,replace=true';",
            "}",
            "janela=window.open(strPagina,'Impressao',strNavparam);",
        "}",
    "</script>";

 #-----------------------------------------------------------------------------
 # Montando cabecalho (parte inicial do fonte HTML)
 #-----------------------------------------------------------------------------
 $texto    = '';

 push @cabecalho, header,

 start_html(-'title'=>'Porto Seguro',
            -onLoad=>'doImpressao();',
            -'meta'=>{'http-equiv=Pragma content=no-cache'},
            -bgcolor=>'#FFFFFF'
           ),"\n",

 start_form(-method=>'POST',
            -name=>'wdatc026',
            -action=>'/j2ee/atendcentral/jdatc014.do'
            ############-action=>'/webserver/cgi-bin/ct24h/trs/wdatc014.pl'
           ),"\n";

 push @cabecalho,

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

##push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);
#PSI 208264
if ($ciaempcod == 1 || $ciaempcod == 40) {
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

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 push @rodape, &wissc211_rodape("","05");

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
