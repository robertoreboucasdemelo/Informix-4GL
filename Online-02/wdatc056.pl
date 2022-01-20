#!/usr/bin/perl
#---------------------------------------------------------------------------#
#                     PORTO SEGURO CIA DE SEGUROS GERAIS                    #
#...........................................................................#
#  Sistema        : Central 24hs                                            #
#  Modulo         : wdatc056.pl                                             #
#                   Tela de entrada de dados para selecao de servicos       #
#                   bloqueados.                                             #
#  Analista Resp. : Carlos Zyon                                             #
#  PSI            : 177890                                                  #
#...........................................................................#
#  Desenvolvimento: FABRICA DE SOFTWARE - Rodrigo Santos                    #
#  Liberacao      :                                                         #
#...........................................................................#
#                     * * * A L T E R A C A O * * *                         #
#                                                                           #
#  Data         Autor Fabrica  Observacao                                   #
#  ----------   -------------  -------------------------------------------  #
#                                                                           #
#---------------------------------------------------------------------------#
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
 require "/webserver/cgi-bin/seweb/trs/wissc225.pl";     #--> Gera colunas/tabelas
                                            #    para versao de impressao

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

 $webusrcod = param("webusrcod");
 $sesnum    = param("sesnum");
 $macsissgl = param("macsissgl");
 $usrtip    = param("usrtip");

#$webusrcod = 'X';
#$sesnum    = '12345';
#$macsissgl = 'XXX';
#$usrtip    = '12';

 #-------------------------------
 # Montando parametros para o 4GL
 #-------------------------------
 push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl;

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $cabec  = 'SERVI�OS BLOQUEADOS';
 $titgif = '/auto/images/ramo_psocorro.gif';

 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvaru01.sh; /webserver/cgi-bin/ct24h/trs/wdatc057.4gc $ARG 2>&1)";

#open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
 open (PROG, "$prog |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

 #-----------------------------------------------------------------------------
 # Montando body variavel @body (parte central do fonte HTML)
 #-----------------------------------------------------------------------------
 while (<PROG>) {

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

    elsif ($REGISTRO[0] eq "PADRAO") {

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
           { &wissc219_mensagem($titgif,$cabec,"BACK","Padr�o n�o previsto!"); }

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
 $texto  = '';

 &cria_javascript;

 push @cabecalho, header(-'expires'=>'-1d',
                         -'pragma'=>'no-cache',
                         -'cache-control'=>'no-store'), "\n",

 start_html(-'title'=>'Porto Seguro',
            -script=>{-src=>'/geral/trs/wiasc007.js'},
            -bgcolor=>'#FFFFFF',
            -onload=>'inicioHtml()',
           ),"\n",

 start_form(-method=>'POST',
            -name=>'wdatc056',
            -action=>"/cgi-bin/ct24h/trs/wdatc058.pl",
            -onsubmit=>"return validaCampos()"
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
 push @rodape, &wissc211_rodape("",2);

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------

 push @html, @cabecalho;
 push @html, &cria_javascript;

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

  return "<script language='JavaScript'>

          function inicioHtml() {
            document.forms[0].de.focus();
          }

          function validaCampos() {

            if (!checaDataNula()        ||
                !checaIntervaloDeAte()  ||
                !checaIntervalo31Dias() ||
                !checaIntervado210Dias() ) {

               document.forms[0].de.value  = '';
               document.forms[0].ate.value = '';
               document.forms[0].de.focus();
               return false;

            }

            return true;

          }

          function checaDataNula() {

            if (document.forms[0].de.value == '' ||
                document.forms[0].de.value.length == 0) {
                alert ('Favor preencher a data inicial');
                return false;
            }

            if (!wiasc007_parseValidaData(document.forms[0].de.value)) {
               alert ('Data inicial inv�lida');
               return false;
            }

            if (document.forms[0].ate.value == '' ||
                document.forms[0].ate.value.length == 0) {
                alert ('Favor preencher a data final');
                return false;
            }

            if (!wiasc007_parseValidaData(document.forms[0].ate.value)) {
               alert ('Data final inv�lida');
               return false;
            }

            return true;

          }

          function checaIntervaloDeAte() {

            var dataInicial = document.forms[0].de.value.substring(6,10)
                            + document.forms[0].de.value.substring(3,5)
                            + document.forms[0].de.value.substring(0,2);

            var dataFinal = document.forms[0].ate.value.substring(6,10)
                          + document.forms[0].ate.value.substring(3,5)
                          + document.forms[0].ate.value.substring(0,2);

            if (parseInt(dataFinal) < parseInt(dataInicial)) {
               alert ('Data final n�o pode ser menor que data inicial');
               return false;
            }

            return true;

          }

          function checaIntervalo31Dias() {

            var dataInicial = document.forms[0].de.value.substring(6,10)
                            + document.forms[0].de.value.substring(3,5)
                            + document.forms[0].de.value.substring(0,2);

            var dataFinal = document.forms[0].ate.value.substring(6,10)
                          + document.forms[0].ate.value.substring(3,5)
                          + document.forms[0].ate.value.substring(0,2);

            if ((parseInt(dataFinal) - parseInt(dataInicial)) >= 31) {
               alert ('A diferen�a entre as datas n�o pode ser maior que 31 dias');
               return false;
            }

            return true;

          }

                  function checaIntervalo210Dias() {

            var dataInicial = (document.forms[0].de.value.substring(6,10) * 365)
                            + (document.forms[0].de.value.substring(3,5) * 30)
                            + (document.forms[0].de.value.substring(0,2) * 1);


	    var dataAtual = new Date();


            var ano = dataAtual.getYear();
	    var mes = dataAtual.getMonth();
	    var dia = dataAtual.getDate();

	    var dataAtualFormatada = (ano * 365)
                                   + (mes * 30)
                                   + (dia * 1);

	    if ((parseInt(dataAtualFormatada) - parseInt(dataInicial)) > 210) {
               alert ('Data inicial n�o pode ser anterior a 210 dias');
               return false;
            }

            return true;

          }

          </script>";

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

 # foreach $texto (keys (%ENV)) {
 #     print "$texto = $ENV{$texto}  <br>\n";
 # }

   foreach $texto (keys (%INC)) {
       print "$texto = $INC{$texto}  <br>\n";
   }

   exit(0);

}


