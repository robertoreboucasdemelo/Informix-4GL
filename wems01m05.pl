#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: wissc230.pl                                                    #
#  Sistema..: Informatica - seguranca web                                    #
#  Criacao..: Abr/2002                                                       #
#  Autor....: Marcelo                                                        #
#                                                                            #
#  Objetivo.: Teste das bibliotecas para montagem de graficos                #
#----------------------------------------------------------------------------#
#----------------------------------------------------------------------------#

 use CGI ":all";
 use GD::Graph::pie3d;        #--> Biblioteca grafico de pizza
 use GD::Graph::bars3d;       #--> Biblioteca grafico de barras
 use GD::Graph::linespoints;  #--> Biblioteca grafico de linhas
 use GD::Graph::mixed;        #--> Biblioteca grafico de barras
#use strict;                  #--> Obriga definicao explicita das variaveis


 #-----------------------------------------------------------------------------
 # Definicao das variaveis
 #-----------------------------------------------------------------------------
 my(
     $TITULO,
     $COLDSCY,
     $COLDSCX,
     $COLVLR1,
     $COLVLR2,
     $COLVLR3,
     $COLVLR4,
     $X_LABEL,
     $Y_LABEL,

     @DSCY,
     @DSCX,
     @VLR1,
     @VLR2,
     @VLR3,
     @VLR4
   );

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $grafico   = param("grafico");
 $TITULO    = param("TITULO");
 $COLDSCY   = param("COLDSCY");
 @DSCY      = split '\|',$COLDSCY;
 $COLDSCX   = param("COLDSCX");
 @DSCX      = split '\|',$COLDSCX;
 $COLVLR1   = param("COLVLR1");
 @VLR1      = split '\|',$COLVLR1;
 $COLVLR2   = param("COLVLR2");
 @VLR2      = split '\|',$COLVLR2;
 $COLVLR3   = param("COLVLR3");
 @VLR3      = split '\|',$COLVLR3;
 $COLVLR4   = param("COLVLR4");
 @VLR4      = split '\|',$COLVLR4;
 $X_LABEL   = param("X_LABEL");
 $Y_LABEL   = param("Y_LABEL");


 if ( $grafico eq "barra" )
    { graficoBarra(); }

 elsif ( $grafico eq "pizza" )
    { graficoPizza(); }

 elsif ( $grafico eq "linha" )
    { graficoLinha(); }


#-----------------------------------------------------------------------------
 sub graficoPizza()
#-----------------------------------------------------------------------------
{
 my $q     = new CGI;
 my $graph = new GD::Graph::pie3d( 400, 400 );

 my @data      = ([@VLR1], [@VLR1]);
 #my @data      = ([@DESCRICAO], [@VALOR]);

 $graph->set(
              title           => $TITULO,
             '3d'             => 0,
              long_ticks      => 5,
#              y_max_value     => 1000,
#              y_min_value     => 0,
#              y_tick_number   => 10,
#              y_label_skip    => 0,
#              bar_spacing     => 20,
              types           => [ "bars", "linespoints" ]
            );

 $graph->set_legend( @DSCY );
 #$graph->set_legend( @DESCRICAO );

 my $gd_image = $graph->plot( \@data );

 print $q->header( -type => "image/png", -expires => "-1d" );

 binmode STDOUT;

 print $gd_image->png;
# exit(0);

}


#-----------------------------------------------------------------------------
 sub graficoBarra()
#-----------------------------------------------------------------------------
{
 my $q     = new CGI;
 my $graph = new GD::Graph::bars3d( 530, 300 );

 my @data      = ([@DSCX], [@VLR1], [@VLR2], [@VLR3], [@VLR4]);

 $graph->set(
              title           => $TITULO,
              x_label         => $Y_LABEL,
              y_label         => $X_LABEL,
              long_ticks      => 10,
#              y_max_value     => 300,
#              y_min_value     => 0,
#              y_tick_number   => 10,
#              y_label_skip    => 0,
#              bar_spacing     => 20,
              types           => [ "bars", "linespoints" ]
            );

 $graph->set_legend( @DSCY );

 my $gd_image = $graph->plot( \@data );

 print $q->header( -type => "image/png", -expires => "-1d" );

 binmode STDOUT;

 print $gd_image->png;
 exit(0);

}



#-----------------------------------------------------------------------------
 sub graficoLinha()
#-----------------------------------------------------------------------------
{
 my $q     = new CGI;
 my $graph = new GD::Graph::linespoints( 530, 300 );

 my @data      = ([@DSCX], [@VLR1], [@VLR2], [@VLR3], [@VLR4]);

 $graph->set(
              title           => $TITULO,
            # 3d              => 0
              x_label         => $Y_LABEL,
              y_label         => $X_LABEL,
              long_ticks      => 10,
#              y_max_value     => 30,
#              y_min_value     => 0,
#              y_tick_number   => 10,
#              y_label_skip    => 10,
#              bar_spacing     => 100,
              types           => [ "bars", "linespoints" ]
            );

 $graph->set_legend( @DSCY );

 my $gd_image = $graph->plot( \@data );

 print $q->header( -type => "image/png", -expires => "-1d" );

 binmode STDOUT;

 print $gd_image->png;
 exit(0);

}


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
