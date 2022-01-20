#!/usr/bin/perl
#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24h / Porto Socorro                                 #
# Modulo         : wdatc070.pl                                                 #
#                  Parametros para a Consulta de Mensagens.                    #
#                  Portal de Negocios(Prestador On-line)->Mensagens->Historico #
# Analista Resp. : Carlos Zyon                                                 #
# PSI            : 187801                                                      #
#..............................................................................#
# Desenvolvimento: META, Adriana Schneider                                     #
# Data           : 06/10/2004                                                  #
#..............................................................................#
#                  * * *  ALTERACOES  * * *                                    #
#                                                                              #
# Data       Autor Fabrica PSI       Alteracao                                 #
# --------   ------------- ------    ------------------------------------------#
# 04/07/2007 Luiz, Meta    AS143650  Retirada do teste da identificacao do     #
#                                    ambiente                                  #
#------------------------------------------------------------------------------#

 use CGI ":all";
 use strict;
 use ARG4GL;

#-----------------------------------------------------------------------------
# INCLUSAO DAS SUBROTINAS QUE MONTAM CAMPOS, TEXTOS, BOTOES, ETC.
#-----------------------------------------------------------------------------
 require "/webserver/cgi-bin/seweb/trs/wissc203.pl";   #--> Gera titulo
 require "/webserver/cgi-bin/seweb/trs/wissc204.pl";   #--> LIST BOX
 require "/webserver/cgi-bin/seweb/trs/wissc206.pl";   #--> Gera RADIO BOX
 require "/webserver/cgi-bin/seweb/trs/wissc207.pl";   #--> Input Text
 require "/webserver/cgi-bin/seweb/trs/wissc208.pl";   #--> Gera colunas/tabelas
 require "/webserver/cgi-bin/seweb/trs/wissc209.pl";   #--> Gera titulos com help
 require "/webserver/cgi-bin/seweb/trs/wissc210.pl";   #--> Gera cabecalho da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc211.pl";   #--> Gera rodape da pagina
 require "/webserver/cgi-bin/seweb/trs/wissc212.pl";   #--> Gera linhas
 require "/webserver/cgi-bin/seweb/trs/wissc218.pl";   #--> Vetores de conversao
 require "/webserver/cgi-bin/seweb/trs/wissc219.pl";   #--> Exibi pagina de Erro
 require "/webserver/cgi-bin/seweb/trs/wissc220.pl";   #--> Checa erro no programa 4GL/BD
 require "/webserver/cgi-bin/seweb/trs/wissc225.pl";   #--> Gera colunas p versao impressao

#-----------------------------------------------------------------------------
# DEFINICAO DAS VARIAVEIS
#-----------------------------------------------------------------------------
 my (
    $usrtip,
    $webusrcod,
    $sesnum,
    $macsissgl,
    $prsmsgcod,
   #$ambiente,
    $cabec,
    $titgif,
    $texto,
    $ARG,
    $prog,
    @ARG,
    @REGISTRO,
    @trataerro,
    @html,
    @body,
    @retorno,
    @script,
    @header,
    @cabecalho,
    @rodape
 );

#-----------------------------------------------------------------------------
# CARREGANDO PARAMETROS RECEBIDOS
#-----------------------------------------------------------------------------
 $usrtip     = param("usrtip");
 $webusrcod  = param("webusrcod");
 $sesnum     = param("sesnum");
 $macsissgl  = param("macsissgl");
 $prsmsgcod  = param("prsmsgcod");


#-----------------------------------------------------------------------------
# DADOS DO CABECALHO
#-----------------------------------------------------------------------------
 $titgif = '/auto/images/ramo_psocorro.gif';
 $cabec  = 'CONSULTA DE MENSAGENS';
 $texto  = 'Para uma nova consulta clique em voltar.';

#---------------------------------------------
# PREPARA PARAMETROS A SEREM ENVIADOS AO '4GL'
#---------------------------------------------
 push @ARG,
      $usrtip,
      $webusrcod,
      $sesnum,
      $macsissgl,
      $prsmsgcod;


 $ARG = sprintf("'%s'",join('\' \'',@ARG));

#$ambiente = "remsh aplweb01 -l runwww ";

#-----------------------------------------------------------------------------
# EXECUTA PROGRAMA INFOMIX 4GL
#-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh ; /webserver/cgi-bin/ct24h/trs/wdatc071.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") ||
 open (PROG, "$prog |") ||
    die ("Não foi possível executar $prog: $!\n");

#-----------------------------------------------------------------------------
# TRATA RETORNO (DISPLAY) DO 4GL LINHA A LINHA, MONTANDO VARIAVEL '@RETORNO'
#-----------------------------------------------------------------------------
 while (<PROG>) {
    #--------------------------------------
    # Trata erro no programa/banco informix
    #--------------------------------------
    &wissc220_veriferro($_, $macsissgl);
    chomp;

    #--------------------------------------------------------------------------
    # TRATA DISPLAY'S GERADOS PELO PROGRAMA E CHAMA ROTINAS PADROES
    #--------------------------------------------------------------------------
    @REGISTRO = split '@@', $_;

    if ($REGISTRO[0] eq "NOSESS") {
       &wissc219_mensagem($titgif, $cabec, "LOGIN", $REGISTRO[1]);
    }
    elsif ($REGISTRO[0] eq "ERRO") {
       &wissc219_mensagem($titgif, $cabec, "BACK", $REGISTRO[1]);
    }
    elsif ($REGISTRO[0] eq "PADRAO") {
       if ($REGISTRO[1] == 1) {
          push @retorno, &wissc203_titulo(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 2) {
          push @retorno, &wissc204_listbox(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 4) {
          push @retorno, &wissc206_radiobox(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 5) {
          push @retorno, &wissc207_textoinputtexto(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 6) {
          push @retorno, &wissc208_coluna(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 7) {
          push @retorno, &wissc209_titulohelp(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 8) {
          push @retorno, &wissc212_linhas1(@REGISTRO);
       }
       elsif ($REGISTRO[1] == 10) {
          push @retorno, &wissc225_colunaimpressao(@REGISTRO);
       }
       else {
          &wissc219_mensagem($titgif, $cabec, "BACK",
                             "Padrão não previsto!($REGISTRO[1])");
       }
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
# MONTANDO PARTE INICIAL DO FONTE HTML
#-----------------------------------------------------------------------------
 push @header,

      header(-'expires'=>'-1',
             -'pragma'=>'no-cache',
             -'cache-control'=>'no-cache'), "\n",

      start_html(-'title'=>'Parâmetros para a Consulta de Mensagens',
                 -script=>{-src=>'/geral/trs/wiasc007.js'},
                 -script=>{-src=>'/geral/trs/wiasc029.js'},
                 -link=>{-rev=>'made',
                         -href=>'mailto:rafaelmoreira.gomes@portoseguro.com.br'},
                 -bgcolor=>'#FFFFFF'), "\n";

#-----------------------------------------------------------------------------
# MONTANDO CABECALHO
#-----------------------------------------------------------------------------
 push @cabecalho,
      &wissc210_cabecalho($titgif, $cabec, $texto);

#-----------------------------------------------------------------------------
# MONTANDO CORPO DO CODIGO HTML ("BODY")
#-----------------------------------------------------------------------------
 push @body,

      start_form(-method=>'POST',
                 -name=>'WDATC070'), "\n",

      hidden(-name=>'usrtip',
             -value=>$usrtip),"\n",

      hidden(-name=>'sesnum',
             -value=>$sesnum),"\n",

      hidden(-name=>'webusrcod',
             -value=>$webusrcod),"\n",

      hidden(-name=>'macsissgl',
             -value=>$macsissgl),"\n",

      hidden(-name=>'prsmsgdstsit',
             -value=>2),"\n",

      @retorno, "\n";

#-----------------------------------------------------------------------------
# MONTANDO RODAPE ("", 2) => apenas botões 'Consultar' e 'Limpar'
#-----------------------------------------------------------------------------
 push @rodape,
      &wissc211_rodape("BACK", 0);

#-----------------------------------------------------------------------------
# AGRUPA COMPONENTES DO HTML E ENVIA PARA O BROWSER
#-----------------------------------------------------------------------------
 push @html,
      @header,
      center(@cabecalho,
             @body,
             @rodape), "\n",
      end_html, "\n";

 print @html;

 exit(0);
