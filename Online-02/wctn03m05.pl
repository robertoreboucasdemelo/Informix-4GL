#! /usr/local/bin/perl 

 #----------------------------------------------------------------------------#
 #  Modulo...: wctn03m05.pl                                                   #
 #  Sistema..: Prestador On Line PSRONLINE                                    #
 #  Criacao..: Ago/2001                                                       #
 #  Autor....: Marcus                                                         #
 #                                                                            #
 #  Objetivo.: Programa para testar subrotinas padroes em PERL                #
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
     $atdetpseq,
     $acao,
     $JSCRIPT,
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
#$cabec  = 'RECEBER SERVI�OS';
 $titgif = '/seweb/images/c_acesso.gif';
 $titgif = '/auto/images/ramo_psocorro.gif';

 $webusrcod=param("webusrcod");
 $sesnum = param("sesnum");
 $macsissgl = param("macsissgl");
 $usrtip = param("usrtip");
 $atdsrvnum = param("atdsrvnum");
 $atdsrvano = param("atdsrvano");
 $atdetpseq = param("atdetpseq");
 $acao      = param("Acao");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdsrvnum,$atdsrvano,$atdetpseq,$acao;     

$JSCRIPT=<<END;
function func_checa(x)
{
  var v_aux = '';
  if (x == 1)
    {
     if (document.wctn03m05.atdprvdat.value.length != 5)
       {
        v_aux += "Informe a previs�o de chegada!";
       }   
     else
       { if (document.wctn03m05.atdprvdat.value == "00:00")
           { v_aux += "Informe a previs\343o estimada de chegada!";}
       }

     if (v_aux > "")
       {
        alert(v_aux);
        document.wctn03m05.atdprvdat.focus();
        return false;
       }
     else
       { document.wctn03m05.submit(); }
     }
   else
     {
       if (document.wctn03m05.etpmtvcod.value == "     8" && document.wctn03m05.srvobs.value.length == 0)
       {
        v_aux += "Informe o motivo da recusa!";
       }
     if (v_aux > "")
       {
        alert(v_aux);
        document.wctn03m05.srvobs.focus();
        return false;
       }
     else
       { document.wctn03m05.submit(); }
     }

}

END

$ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvar.sh; wctn03m05.4gc $ARG 2>&1)";

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
 if ($acao eq 'Aceitar ')
    { $texto = 'Informe no campo "estimativa" a previs�o de chegada ao QTR. Caso seja necess�rio incluir uma observa��o, utilize o campo "observa��es".';
      $cabec  = 'RECEBER SERVI�OS - ACEITAR';
    }
 else
    {
      $texto = 'Selecione o motivo da recusa, e caso selecione a op��o "outros" informe o motivo no campo observa��es.';
      $cabec  = 'RECEBER SERVI�OS - RECUSAR';
    }

 push @cabecalho, header,

 start_html(-'title'=>'Porto Seguro',
            -'script'=>$JSCRIPT,
            -bgcolor=>'#FFFFFF'
           ),"\n";

 if ($acao eq 'Aceitar ')
    { push @cabecalho,
      start_form(-method=>'POST',
            -name=>'wctn03m05',
            -action=>'/cgi-bin/ct24h/trs/wctn03m06.pl', 
            -onsubmit=>'return func_checa(1)'),"\n"
    }
 else
    { push @cabecalho,   
 start_form(-method=>'POST',
            -name=>'wctn03m05',
            -action=>'/cgi-bin/ct24h/trs/wctn03m07.pl',
            -onsubmit=>'return func_checa(2)'),"\n"
    }

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
      ),"\n",
hidden(-name=>'atdsrvnum',
       -value=>$atdsrvnum,
      ),"\n",
hidden(-name=>'atdsrvano',
       -value=>$atdsrvano,
      ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 push @rodape, &wissc211_rodape("BACK",3);

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
