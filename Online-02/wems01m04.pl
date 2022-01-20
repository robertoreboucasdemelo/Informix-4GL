#!/usr/local/bin/perl

 #----------------------------------------------------------------------------#
 #  Modulo...: wissc230.pl                                                    #
 #  Sistema..: Informatica - seguranca web                                    #
 #  Criacao..: Abr/2002                                                       #
 #  Autor....: Marcelo                                                        #
 #                                                                            #
 #  Objetivo.: Teste das bibliotecas para montagem de graficos                #
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
 use GD::Graph::pie3d;        #--> Biblioteca grafico de pizza 
 use GD::Graph::bars3d;       #--> Biblioteca grafico de barras
 use GD::Graph::linespoints;  #--> Biblioteca grafico de linhas
 use GD::Graph::mixed;        #--> Biblioteca grafico de barras
#use strict;                  #--> Obriga definicao explicita das variaveis
 use ARG4GL;


 #-----------------------------------------------------------------------------
 # Inclusao das subrotinas que montam campos, textos, botoes, etc.
 #-----------------------------------------------------------------------------
 require "../../seweb/trs/wissc203.pl";   #--> Gera titulo
 #require "../../seweb/trs/wissc204.pl";   #--> Gera list box
 #require "../../seweb/trs/wissc205.pl";   #--> Gera check box
 #require "../../seweb/trs/wissc206.pl";   #--> Gera radio box
 #require "../../seweb/trs/wissc207.pl";   #--> Gera Texto/Input/Texto
 #require "../../seweb/trs/wissc208.pl";   #--> Gera colunas/tabelas
 #require "../../seweb/trs/wissc209.pl";   #--> Gera titulo com help
 require "../../seweb/trs/wissc210.pl";   #--> Gera cabecalho da pagina
 require "../../seweb/trs/wissc211.pl";   #--> Gera rodape da pagina
 #require "../../seweb/trs/wissc212.pl";   #--> Gera tabela com varias linhas 
 #require "../../seweb/trs/wissc216.pl";   #--> Gera linha com checkbox/listbox
 require "../../seweb/trs/wissc218.pl";   #--> Vetores de conversao            
 require "../../seweb/trs/wissc219.pl";   #--> Gera pagina de mensagem/erro  
 require "../../seweb/trs/wissc220.pl";   #--> Checa erro no programa 4GL/BD 
 #require "../../seweb/trs/wissc225.pl";   #--> Gera versao para impressao      
 #require "../../seweb/trs/wissc229.pl";   #--> Monta tags table    


 #-----------------------------------------------------------------------------
 # Definicao das variaveis 
 #-----------------------------------------------------------------------------
 my( $maq,
     $ambiente,
     $cabec,
     $titgif,
     $padrao,
     $texto, 
     $line, 
     @REGISTRO,
     @DESCRICAO, 

     $TITULO,
     $COLDSCY,
     $COLDSCX,
     $COLVLR1, 
     $COLVLR2, 
     $COLVLR3, 
     $COLVLR4, 
     $X_LABEL,
     $Y_LABEL,

     @html,     
     @body,     
     @cabecalho,
     @rodape  
   );

$ambiente = "remsh aplweb01 -l runwww ";

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $grafico   = param("grafico");
 $TITULO    = param("TITULO");
 $COLDSCY   = param("COLDSCY");
 $COLDSCX   = param("COLDSCX");
 $COLVLR1   = param("COLVLR1");
 $COLVLR2   = param("COLVLR2");
 $COLVLR3   = param("COLVLR3");
 $COLVLR4   = param("COLVLR4");
 $X_LABEL   = param("X_LABEL");
 $Y_LABEL   = param("Y_LABEL");
 $sesnum    = param("sesnum");
 $usrcod    = param("usrcod");
 $usrtip    = param("usrtip");
 $empcod    = param("empcod");

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $cabec  = 'RELATÓRIOS GERENCIAIS - GRÁFICOS';
 $titgif = '/auto/images/emissao.gif';


 #----------------------------------------------------------------------------- 
 # Executa programa Infomix 4GL Sessao 
 #----------------------------------------------------------------------------- 
 $args = "'$usrtip' '$usrcod' '$sesnum' '$empcod' 'wems01m03'";
 
 $prog = "(cd /webserver/cgi-bin/ct24h/trs; . ../../setvardsa.sh; wems00g01.4gc $args 2>&1)";
 
 open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
 
 while (<PROG>) {
         chomp ;
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
         split ("@@");
 
         if ($_[0] eq 'NOSESS') {
           &wissc219_mensagem($titgif,$cabec,"LOGIN3",$_[1]);
           exit (0);
         }
 } 
 close (PROG);

 #debugar();

 #-----------------------------------------------------------------------------
 # Montando cabecalho (parte inicial do fonte HTML)
 #-----------------------------------------------------------------------------
 $texto  = '';

 push @cabecalho, header(-'cache-control'=>'no-store',
                         -'pragma'=>'no-cache',
                         -'expires'=>'-1d'
                        ),

 start_html(-'title'=>'Porto Seguro',
            -bgcolor=>'#FFFFFF'
           ),"\n",

 start_form(-method=>'POST',
            -name=>'wissc230',
           ),"\n";

 push @cabecalho, &wissc210_cabecalho($titgif,$cabec,$texto);

 #-----------------------------------------------------------------------------
 # Montando rodape variavel (parte final do fonte HTML)
 #-----------------------------------------------------------------------------
 push @rodape, &wissc211_rodape('','');

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------
 push @body, "<IMG SRC='/cgi-bin/ct24h/trs/wems01m05.pl?grafico=$grafico&TITULO=$TITULO&COLDSCY=$COLDSCY&COLDSCX=$COLDSCX&COLVLR1=$COLVLR1&COLVLR2=$COLVLR2&COLVLR3=$COLVLR3&COLVLR4=$COLVLR4&X_LABEL=$X_LABEL&Y_LABEL=$Y_LABEL'>";
 push @html, @cabecalho,
 center(
        table({-border=>'0',-width=>$width{"0"},-cellspacing=>'0',-cellpadding=>'0'},"\n",
               @body, @rodape, 
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
   print "*** PARAMETROS WISSC230.PL ***  <br>\n";

   print "VLR1 =  @VLR1  <br>\n";
   print "VLR2 =  @VLR2  <br>\n";
   print "VLR3 =  @VLR3  <br>\n";
   print "VLR4 =  @VLR4  <br>\n";
   print "DSCX =  @DSCX  <br>\n";
   print "DSCY =  @DSCY  <br>\n";

   exit(0);
 }
