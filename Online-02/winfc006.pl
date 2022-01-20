#!/usr/bin/perl
#----------------------------------------------------------------------------#
#  Modulo...: winfc006.pl                                                    #
#  Sistema..: infochuva                                                      #
#  Criacao..: Dez/2001                                                       #
#  Autor....: Raji                                                           #
#                                                                            #
#  Objetivo.: Pontos de Alagamento                                           #
##############################################################################
# Alteracoes:                                                                #
#                                                                            #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#----------------------------------------------------------------------------#
# 12/03/2002  AS 2713-8    Marcus       Alteracao para utiLizacao mapas Apon #
#                                       tador caso possua o mesmo.           #
# 26/02/2004  OSF 32794    Perkins(FSW) Inibido a rotina para ignorar as     #
#				         linhas do arquivo texto, iniciadas   #
#                                       pela literal "ID", pois, a parceria  #
#                                       entre a Porto e o Apontador foi      #
#                                       cancelada.                           #
#----------------------------------------------------------------------------#
#----------------------------------------------------------------------------#
 use CGI ":all";
 use strict;                #--> Obriga definicao explicita das variaveis
 use ARG4GL;                #--> Biblioteca erro no informix

 #-----------------------------------------------------------------------------
 # Definicao das variaveis
 #-----------------------------------------------------------------------------
 my( $hoje,
     $dir_ref,
     $horacheia,
     $maq,
     $lixo,
     $mensagem,
     @FIELDS,
     $registro,
     $tipo,
     $tamanho,
     $conteudo,
     $template,
     $texto,
     @body,
     @header,
     %param,
     $ruasalagadas,
     $qtd_alaga
    );

 $dir_ref = "\/infochuva\/trs\/";

 %param  = ( "local"         => "<b>Local:</b>&nbsp;",
             "referencia"    => "<b>Refer&ecirc;ncia:</b>&nbsp;",
             "sentido"       => "<b>Sentido:</b>&nbsp;",
             "inicio"        => "<b>In&iacute;cio:</b>&nbsp;",
             "fim"           => "<b>Fim:</b>&nbsp;",
             "obs"           => "<b>Obs:</b>&nbsp;",
             "linha"         => "<br><b><hr size=1 color=#000000></b>",
             "link"          => '<a href="#" onClick="AbrirMapa(\'http://www.apontador.com.br/ext/portoseguro/bussola/mapachuva.php3?alag_id=',
             "fimlink"       => "','','status=yes,menubar=no,scrollbars=yes,width=790,height=600')\" class=alagamento>Ver mapa</a>"
#           "link"          => "<a href=http://www.apontador.com.br/ext/portoseguro/bussola/mapachuva.php3?alag_id=",
#            "fimlink"       => " class=alagamento><b>Ver mapa</b></a>"
            );

#---------------------------------
$hoje = `date '+%d/%m/%Y \340s %H:%Mh'`;
#----------------------
$horacheia = `date '+%H'`;
$qtd_alaga = 0;

# Carregando arquivo de entrada
($maq,$lixo) = split(" ",`hostname`);
if ($maq eq 'u07') {
    $mensagem = `cat infochuva.txt`;
}else{
    $mensagem = `remsh aplweb01 -l runwww \"(cat /webserver/cgi-bin/infochuva/trs/infochuva.txt)\"`;
}
#----------------------

$ruasalagadas  = "";

@FIELDS = split ("\n", $mensagem);
foreach (@FIELDS)
   {
       $registro = substr ($_, 0, 2);
       if ($registro eq "ra"){
          $tipo = substr ($_,2, 2);
          if ($tipo eq "99"){
             $tamanho = length $_;
             if ( $tamanho > 7 ) {
                $conteudo =  substr ($_,4, $tamanho);
                if (substr ($conteudo,0,3) eq "ID:") {
		  ## Perkins 26/02/2004 - Incluido a linha conf. OSF 32794
		  $conteudo = "";
		  ## Perkins 26/02/2004 - Inibido conf. OSF 32794
                  ##  if ( substr ($conteudo,3, $tamanho) eq " 0!") {
                  ##     #--sem mapa, nao remover ID
                  ##     $conteudo =~ s/ID: 0!//;
                  ##  }
                  ##  else {
                  ##       $conteudo =~ s/ID: /$param{"link"}/;
                  ##       $conteudo =~ s/!/$param{"fimlink"}/;
                  ##       $conteudo = $conteudo . "<br>";
                  ##  }
                }
                elsif (substr ($conteudo,0,1) eq "-") {
                       if ( $qtd_alaga > 0) {
                           $conteudo = $param{"linha"};
                       }
                       else {
                            $conteudo = "";
                       }
                       $qtd_alaga++;
                }
                else {
                     $conteudo =~ s/Local:/$param{"local"}/;
                     $conteudo =~ s/Refer\352ncia/$param{"referencia"}/;
                     $conteudo =~ s/Sentido:/$param{"sentido"}/;
                     $conteudo =~ s/In\355cio:/$param{"inicio"}/;
                     $conteudo =~ s/Obs:/$param{"obs"}/;
                     $conteudo = $conteudo . "<br>";
                }
             }
             else {
                   $conteudo = $param{"linha"};
             }
             $ruasalagadas = $ruasalagadas . $conteudo;
          }
       }
   }

&entra();
exit(0);

 sub entra()
 {
  #----------------------------------------------------------------------------
  # Abre o HTML criado pelo PORTO.COM
  #----------------------------------------------------------------------------
  if($maq eq 'u07')
    {
     $template = "/webserver/htdocs" . $dir_ref . 'alagamento.html';
    }
  else
    {
     $template = '/html/infochuva/trs/alagamento.html';
    }

  print "Content-type: text/html\n\n";

  if ( open(FT,$template) )
     {
      while(<FT>)
        {
                 s/\@alagamento\@/$ruasalagadas/;
                 print $_;
                }
      close(FT);
     }
  else
     {
      $texto = 'N‚o foi possivel abrir o arquivo: '.$template;
      print $texto;
     }
 }
