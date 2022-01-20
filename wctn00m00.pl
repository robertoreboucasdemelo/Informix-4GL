#! /usr/local/bin/perl
use CGI ":all";

#----------------------------------------------------
#  Montagem de tela dinamicamente
#----------------------------------------------------
# Programa              wctn00m00
# Versao 1.0                                 Nov/2000
#----------------------------------------------------
# Desenvolvido por      Marcio Akira Matsuda
#----------------------------------------------------
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
# 04/07/2007 Luiz, Meta    AS143650  Retirada do teste da identificacao do   #
#                                    ambiente                                #
#----------------------------------------------------------------------------#
$ambiente = "remsh aplweb01 -l runwww ";
#---------------------------------
# Extraindo data e hora de conexao
#---------------------------------
$hoje = `date '+%d/%m/%Y \340s %H:%Mh'`;
#--------------------------------
# Vetor associativo - alinhamento
#--------------------------------
%align = (C=>'center',
          L=>'left',
          R=>'right',
          T=>'top',
          B=>'bottom',
          M=>'middle');

#------------------------
# Vetor associativo - cor
#------------------------
%color = (0=>'#A8CDEC',
          1=>'#D7E7F1',
          2=>'#FFFFFF');

#----------------------------
# Recebendo parametros do cgi
#----------------------------

#$prestador = "2427";

$webusrcod=param("webusrcod");

$sesnum = param("sesnum");

$macsissgl = param("macsissgl");

$usrtip = param("usrtip");

#-------------------------------
# Montando parametros para o 4GL
#-------------------------------
#push @ARG,$prestador,$usrtip,$webusrcod,$sesnum,$macsissgl;
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl;

#------------------------------
# Colocando aspas nas variaveis
#------------------------------
$ARG = sprintf("'%s'",join('\' \'',@ARG));

#print header, start_html,$ARG;

$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvar.sh; wctn00m00.4gc $ARG)";
open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");
while (<PROG>) {
   #------------------------
   # Erro de sessao invalida
   #------------------------
   if ($_ =~ /^NOSESS@@\w+.*/) {
       @ERROR = split '@@',$_;
       &DisplayError;
   }
   #--------------------
   # Erro de no programa
   #--------------------
   if ($_ =~ /^ERRORS@@\w+.*/) {
       @ERROR = split '@@',$_;
       &DisplayError;
   }
   #------------------------------------------
   # Rotina quando existe mais de uma veiculo
   #------------------------------------------
   if ($_ =~ /^VIAT@@\w+.*/) {
       @VIAT = split '@@',$_;
       &Link;
   }
   #---------------------------------
   # Criacao dos campos do formulario
   #---------------------------------
   if ($_ =~ /^PADRAO@@\d.*/) {
       @DADOS = split '@@',$_;
       if ($DADOS[1] == 2) {
           &Lbox;
       }elsif ($DADOS[1] == 4){
               &RadBox;
       }elsif ($DADOS[1] == 5 || $DADOS[1] == 6) {
           &TextDispInput;
       }elsif ($DADOS[1] == 11 ) {
           &TextDispInputText;
       }elsif ($DADOS[1] == 7) {
           &Coluna;
       }
   }
}
#------------------
# Carregando titulo
#------------------
if ($ERROR[0] ne NOSESS && $ERROR[0] ne ERRORS && $VIAT[0] ne 'VIAT') {
    #-----------------------------------
    # Criando consistencia em JavaScript
    #-----------------------------------
    &Create_JavaScript;
    &OneCity;
    push @body,"\n",br(),"\n",br(),"\n",
          table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
               Tr(
                 td(submit(-name=>'btoSubmit',
                           -value=>' Continuar '),
                    reset(-name=>'  Limpar   ')
                   ),"\n",
                 ),"\n",
               );
}elsif ($VIAT[0] eq 'VIAT'){
        &MoreCity;
}else{
     $frase = ""
}
#---------------
# Montando botao
#---------------
if ($ERROR[0] eq NOSESS) {
    $voltar = a({-href=>'/prestador/trs/',-target=>'_top'},"\n",
                  img{-src=>'/corporat/images/bot_voltar.gif',-width=>'79',-height=>'15',border=>'0'}
               );
}else{
     $voltar = a({-href=>'JavaScript:history.back()'},"\n",
                   img{-src=>'/corporat/images/bot_voltar.gif',-width=>'79',-height=>'15',border=>'0'}
                );
}
#----------------
# Montando header
#----------------
&DadosHeader;
#-------------------------
# Montando trailler padrão
#-------------------------
&DadosTrail;
#------------------------------
# Agrupando componentes do HTML
#------------------------------
push  @header,"\n",center(
                         table({-border=>'0',-width=>'550',-cellspacing=>'1',-cellpadding=>'0'},"\n",
                                @body,@trailler
                              )
                         ),"\n",end_form,"\n",end_html;
print @header;
close(PROG);
exit 0;
#---------------------------------------------------------------------------
sub DadosHeader
#---------------------------------------------------------------------------
{
   push @header,header,
         start_html(-title=>'Posição da frota - Veiculos',-bgcolor=>'#FFFFFF',-script=>$JSCRIPT),
         start_form(-method=>'POST',-name=>'waemc031',-action=>'/cgi-bin/auto/trs/central002.pl',-onSubmit=>'return check_dados()'),br;
   if ($VIAT[0] ne 'VIAT') {
        push @header,"\n",
              hidden(-name=>'prestador',
                     -value=>$prestador,
                     -override=>1
                    ),"\n";
              hidden(-name=>'usrtip',
                     -value=>$usrtip
                    ),"\n",
              hidden(-name=>'webusrcod',
                     -value=>$webusrcod
                    ),"\n",
              hidden(-name=>'sesnum',
                     -value=>$sesnum
                    ),"\n",
   }
   push @header,"\n",
         center(
               table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'0'},"\n",
                    Tr(
                      td(img {-src=>'/corporat/images/logo_porto.gif',-width=>'173',-height=>'18',-alt=>'Porto Seguro'},
                         img {-src=>'/auto/images/ramo_psocorro.gif',-alt=>'Autom\363vel'}
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
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},b('POSIÇÃO DA FROTA'))
                        ),"\n",
                      ),"\n",
                    Tr(
                      td({-colspan=>'2',height=>'12'},'&nbsp;')
                      ),"\n",
                    Tr(
                      td(font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},'Clique no veículo para maiores detalhes.'))
                      ),"\n",
                    Tr(
                      td({-colspan=>'2',height=>'12'},'&nbsp;')
                      ),"\n",
                    )
               ),"\n";
}
#---------------------------------------------------------------------------
sub DadosTrail
#---------------------------------------------------------------------------
{
   push @trailler,"\n",br(),"\n",
         table({-border=>'0',-width=>'550',-cellspacing=>'1',-cellpadding=>'0'},"\n",
              Tr(
                td($voltar),"\n",
                td({-align=>'right',-valign=>'bottom'},"\n",
                     img {-src=>'/corporat/images/blue_box.gif',-width=>'36',-height=>'16'}
                  ),"\n"
                ),"\n",
              Tr(
                td({-align=>'right',-colspan=>'2'},"\n",
                     img {-src=>'/corporat/images/linha_azul.gif',-width=>'550',-height=>'1'}
                  ),"\n"
                ),"\n",
              ),"\n",br(),"\n";
}
#---------------------------------------------------------------------------
sub Lbox
#---------------------------------------------------------------------------
{
   #--------------------------------
   # Inicializando vetor associativo
   #--------------------------------
   &InicVetor;
   #-----------------------------
   # Carregando vetor associativo
   #-----------------------------
   for ($i=0, $def=0, $op=5; $op < $#DADOS ; $i++, $op=$op + 2) {
      $lista {$i} = uc($DADOS[$op]);
      if ($DADOS[$op + 1] == 1) {
          $def = $i;
      }
   };
   #-----------------------------------------------------
   # Carregando indices do vetor associativo em uma lista
   #-----------------------------------------------------
   @indice = keys %lista;
   #------------------------
   # Montando help do titulo
   #------------------------
   if ($DADOS[4] == 1) {
       $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                   font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},"\n",
                       a({-href=>"javascript:open_help('$DADOS[2]')"},$DADOS[3])
                       ),"\n"
                ),"\n"
   }else{
       $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                   font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},"\n",$DADOS[3]
                       ),"\n"
                ),"\n"
   };
   push @body,
         table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
              Tr($hlp,"\n",
                td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},"\n",
                     popup_menu(-name=>$DADOS[2],
                                -value=>[@indice],
                                -labels=>\%lista,
                                -default=>$def,
                                -override=>1
                               ),"\n"
                  ),"\n"
                ),"\n",
              );
}

#---------------------------------------------------------------------------
sub RadBox
#---------------------------------------------------------------------------
{
   #--------------------------------
   # Inicializando vetor associativo
   #--------------------------------
   &InicVetor;
   var $def = 0;
   $linha   = '';
   for ($cont=1, $i=0, $op=6; $op < $#DADOS ; $cont++, $i++, $op=$op + 3) {
      #-----------------------------
      # Carregando vetor associativo
      #-----------------------------
      if ($DADOS[2] eq 'tarifa') {
          #-------------------------------------------
          # Quando for tarifa coloca o nome como value
          #-------------------------------------------
          $lista {"$DADOS[$op]"} = $DADOS[$op];
      }else{
           #---------------------------------------
           # Demais coloca uma numeracao seguencial
           #---------------------------------------
           $lista {"$i"} = $DADOS[$op];
      }
      #-----------------------------------------------------
      # Carregando indices do vetor associativo em uma lista
      #-----------------------------------------------------
      @indice = keys %lista;
      #-------------------------
      # Indica campo selecionado
      #-------------------------
      if ($DADOS[2] eq 'tarifa') {
          $def = ($DADOS[$op + 1] == 1)?"$DADOS[$op]":'-';
      }else{
           $def = ($DADOS[$op + 1] == 1)?"$i":'-';
      }
      #----------------------
      # Indica opcao com help
      #----------------------
      if ($DADOS[$op + 2] == 1) {
          $linha .= a({-href=>"javascript:open_help_radio('$DADOS[2]','$i')"},
                        radio_group(-name=>$DADOS[2],
                                    -value=>[@indice],
                                    -labels=>\%lista ,
                                    -default=>$def
                                   )
                     );
      }else{
           $linha .= radio_group(-name=>$DADOS[2],
                                 -value=>[@indice],
                                 -labels=>\%lista,
                                 -default=>$def)
      }
      #--------------------------------
      # Inicializando vetor associativo
      #--------------------------------
      &InicVetor;
      #-------------------------
      # Indica numero de colunas
      #-------------------------
      if ($DADOS[3] > 1) {
          if ($DADOS[3] == $cont) {
              $linha .= br;
              $cont = 0;
          }
      }else{
           $linha .= br;
      }
   };
   #------------------------
   # Montando help do titulo
   #------------------------
   if ($DADOS[4] ne '') {
        if ($PERFIL[5] == 1) {
            $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                        font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},
                            a({-href=>"javascript:open_help('$PERFIL[2]')"},$DADOS[4])
                            )
                     );
        }else{
             $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$DADOS[4]
                             )
                      );
        }
   }

   if ($DADOS[4] eq '') {
        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                   Tr(
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$linha)
                       ),"\n",
                     ),"\n",
                   )
   }else{
        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                   Tr($hlp,
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$linha)
                       ),"\n",
                     ),"\n",
                   )
   }
}
#---------------------------------------------------------------------------
sub TextDispInput
#---------------------------------------------------------------------------
{
   if ($DADOS[1] == 5) {
        #-----------------------------------
        # Monta linha com todas as respostas
        #-----------------------------------
        for ($x=0,$i=2; $i <= $#DADOS; $i++) {
           if ($i == 2) {
               $tit = $DADOS[$i];
           }else{
                $x++;
                if (!defined ($DADOS[$i]) || $DADOS[$i] eq '') {
                     $DADOS[$i] = '&nbsp;';
                }
                if ($x == 1) {
                    $row = $DADOS[$i];
                }else{
                    $row = $row . br . $DADOS[$i];
                }
           }
        }
        push @body,"\n",
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
                   Tr(
                     td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},"\n",$tit
                              )
                       ),"\n",
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},"\n",
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},"\n",$row
                              )
                       ),"\n"
                     ),"\n"
                   )
   }else{
        #------------------------
        # Montando help do titulo
        #------------------------
        if ($DADOS[5] == 1) {
            $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                        font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},"\n",
                            a({-href=>"javascript:open_help('$DADOS[3]')"},ucfirst(lc($DADOS[4]))
                             )
                            )
                     )
        }else{
             $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},ucfirst(lc($DADOS[4]))
                             )
                      )
        };

        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
                   Tr($hlp,"\n",
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},"\n",
                          textfield(-name=>$DADOS[3],
                                    -size=>$DADOS[2],
                                    -maxLength=>$DADOS[2],
                                    -default=>$DADOS[6],
                                    -onChange=>'return maiuscula(this)'
                                   )
                       )
                     ),"\n",
                   )
   }
}




#---------------------------------------------------------------------------
sub TextDispInputText
#---------------------------------------------------------------------------
{
   if ($DADOS[1] == 5) {
        #-----------------------------------
        # Monta linha com todas as respostas
        #-----------------------------------
        for ($x=0,$i=2; $i <= $#DADOS; $i++) {
           if ($i == 2) {
               $tit = $DADOS[$i];
           }else{
                $x++;
                if (!defined ($DADOS[$i]) || $DADOS[$i] eq '') {
                     $DADOS[$i] = '&nbsp;';
                }
                if ($x == 1) {
                    $row = $DADOS[$i];
                }else{
                    $row = $row . br . $DADOS[$i];
                }
           }
        }
        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                   Tr(
                     td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$tit
                              )
                       ),
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$row
                              )
                       )
                     ),"\n",
                   )
   }else{
        #------------------------
        # Montando help do titulo
        #------------------------
        if ($DADOS[5] == 1) {
            $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                        font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},
                            a({-href=>"javascript:open_help('$DADOS[3]')"},ucfirst(lc($DADOS[4]))
                             )
                            )
                     )
        }else{
             $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},ucfirst(lc($DADOS[4]))
                             )
                      )
        };

        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                   Tr($hlp,
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},
                          textfield(-name=>$DADOS[3],
                                    -size=>$DADOS[2],
                                    -maxLength=>$DADOS[2],
                                    -default=>$DADOS[6],
                                    -onChange=>'return maiuscula(this)'
                                   ),
                                 font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$DADOS[7]
                                     ),
                       ),
                     ),"\n",
                   )
   }
}
#---------------------------------------------------------------------------
sub Coluna
#---------------------------------------------------------------------------
{
   #-------------------------------------------
   # Montando quantidade de colunas solicitadas
   #-------------------------------------------
   for ($i=1,$e=4,$a=5,$c=6,$f=7,$w=8,$av=9,$h=10,$t=11; $i <= $DADOS[2]; $i++,$e=$e+8,$a=$a+8,$c=$c+8,$f=$f+8,$w=$w+8,$av=$av+8,$h=$h+8,$t=$t+8) {
        if ($DADOS[$t] =~ /^\s+\s$/ || $DADOS[$t] eq '' || $DADOS[$t] eq ' ') {
             $DADOS[$t] = '&nbsp;';
        }
        #---------------------------
        # Carregando estilo desejado
        #---------------------------
        if ($DADOS[$e] eq 'B') {
            $est = b($DADOS[$t]);
        }elsif ($DADOS[$e] eq 'I') {
                $est = i($DADOS[$t]);
        }elsif ($DADOS[$e] eq 'N') {
                $est = $DADOS[$t];
        }
        if ($i == 1) {
            $row = td({-align=>$align{"$DADOS[$a]"},-valign=>$align{"$DADOS[$av]"},-bgcolor=>$color{"$DADOS[$c]"},-width=>$DADOS[$w],-height=>$DADOS[$h]},"\n",
                        font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$DADOS[$f]},$est
                            )
                     ),"\n"
        }else{
             $row = $row . td({-align=>$align{"$DADOS[$a]"},-valign=>$align{"$DADOS[$av]"},-bgcolor=>$color{"$DADOS[$c]"},-width=>$DADOS[$w],-height=>$DADOS[$h]},"\n",
                                font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$DADOS[$f]},$est
                                    )
                             ),"\n"
        }
   }
   push @body,
         table({-border=>$DADOS[3],-width=>'550',-cellpadding=>'0',-cellspacing=>'1',-align=>'center'},"\n",
              Tr($row),"\n",
              ),"\n";
}
#---------------------------------------------------------------------------
sub Link
#---------------------------------------------------------------------------
{
  $cid  = $VIAT[1];
  $cid  =~ tr / /+/;
  $ufd  = $nom_est{"$VIAT[2]"};
  $ufd  =~ tr / /+/;

  $link = a({-href=>sprintf('/cgi-bin/ct24h/trs/wctn00m01.pl?usrtip=%s&webusrcod=%d&sesnum=%d&macsissgl=%s&atdvclsgl=%s&',$usrtip,$webusrcod,$sesnum,$macsissgl,$VIAT[1])},$VIAT[1]);

  push @body,
        table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
             Tr(
               td({-align=>'center',-valign=>'middle',-bgcolor=>'#D7E7F1',-width=>'20%',-height=>'23'},
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'1'},
                        $link)
                 ),"\n",
               td({-align=>'center',-valign=>'middle',-bgcolor=>'#D7E7F1',-width=>'20%',-height=>'23'},
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'1'},$VIAT[2]),
                 ),"\n",
               td({-align=>'center',-valign=>'middle',-bgcolor=>'#D7E7F1',-width=>'20%',-height=>'23'},
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'1'},$VIAT[3]),
                 ),"\n",
               td({-align=>'center',-valign=>'middle',-bgcolor=>'#D7E7F1',-width=>'20%',-height=>'23'},
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'1'},$VIAT[4]),
                 ),"\n",
               td({-align=>'center',-valign=>'middle',-bgcolor=>'#D7E7F1',-width=>'20%',-height=>'23'},
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'1'},$VIAT[5]),
                 ),"\n",
               ),"\n",
             )
}
#---------------------------------------------------------------------------
sub OneCity
#---------------------------------------------------------------------------
{
   $frase = 'Não foi encontrada nenhuma veiculo para o prestador ', $prestador;
   unshift @body,
            table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                 Tr(
                   td({-colspan=>'2'},
                        font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},$frase)
                     ),"\n",
                   ),"\n",
                 Tr(
                   td({-colspan=>'2',height=>'12'},'&nbsp;')
                   ),"\n"
                 );
}
#---------------------------------------------------------------------------
sub MoreCity
#---------------------------------------------------------------------------
{
   unshift @body,
            table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                 Tr(
                   td({-align=>'center',-valign=>'middle',-bgcolor=>'#A8CDEC',-width=>'20%',-height=>'23'},
                        font({-face=>'Arial,Helvetica,Verdana',-size=>'2'},b('Veículo')
                            )
                     ),
                   td({-align=>'center',-valign=>'middle',-bgcolor=>'#A8CDEC',-width=>'20%',-height=>'23'},
                        font({-face=>'Arial,Helvetica,Verdana',-size=>'2'},b('Situação')
                            )
                     ),
                   td({-align=>'center',-valign=>'middle',-bgcolor=>'#A8CDEC',-width=>'20%',-height=>'23'},
                        font({-face=>'Arial,Helvetica,Verdana',-size=>'2'},b('Horário')
                            )
                     ),
                   td({-align=>'center',-valign=>'middle',-bgcolor=>'#A8CDEC',-width=>'20%',-height=>'23'},
                        font({-face=>'Arial,Helvetica,Verdana',-size=>'2'},b('Tempo')
                            )
                     ),
                   td({-align=>'center',-valign=>'middle',-bgcolor=>'#A8CDEC',-width=>'20%',-height=>'23'},
                        font({-face=>'Arial,Helvetica,Verdana',-size=>'2'},b('Local')
                            )
                     )
                   ),"\n",
                 );
}
#---------------------------------------------------------------------------
sub InicVetor
#---------------------------------------------------------------------------
{
   #--------------------------------
   # Inicializando vetor associativo
   #--------------------------------
   if (keys (%lista)) {
       @indice = keys %lista;
       foreach (@indice) {
          delete $lista{$_};
       }
   }
}
#---------------------------------------------------------------------------
sub Create_JavaScript
#---------------------------------------------------------------------------
{
if ($usrtip eq 'S') {
    $JSCRIPT=<<END;
    function open_help(campo,op) {
      janela = '';
      if (campo == 'susep') {
          janela = '/auto/trs/waemc065.html';
      }
      if (campo == 'bonclacod') {
          janela = '/auto/trs/waemc036.html';
      }
      if (campo == 'perflg') {
          janela = '/auto/trs/waemc084.html';
      }
      if (janela == '') {
          janela = '/auto/trs/waemc088.html';
      }
      if (navigator.appName.indexOf("Netscape") != -1)
          janela=window.open(janela,'help','height=300,width=200,screenX=50,screenY=50,toolbar=no,menubar=no,scrollbars=yes,resizable=no,status=yes');
      else
         janela=window.open(janela,'help','height=300,width=200,left=50,top=50,toolbar=no,menubar=no,scrollbars=yes,resizable=no,status=yes');
   };
   function check_dados(){
      if (!check_susep())           return (false);
      if (!check_veiculo())         return (false);
      if (!check_ano_fabricacao())  return (false);
      if (!check_ano_modelo())      return (false);
      if (!check_combustivel())     return (false);
      return (true);
   }
   function check_susep(){
      if (document.waemc031.susep.value == ""){
          alert("Favor informar a SUSEP");
          document.waemc031.susep.focus();
          return false
      }else
          return true
   }
   function check_veiculo(){
      if (document.waemc031.veiculo.value == ""){
          alert("Favor informar o veículo");
          document.waemc031.veiculo.focus();
          return false
      }else
          return true
   }
   function check_ano_modelo(){
      if (document.waemc031.vclanomod.value == ""){
          alert("Favor informar o ano modelo do veículo");
          document.waemc031.vclanomod.focus();
          return false
      }else
          return true
   }
   function check_ano_fabricacao(){
      var wdif  = "";
      var wamod = "";
      var wafbc = "";
      if (document.waemc031.vclanofbc.value == ""){
          alert("Favor informar o ano de fabricação do veículo");
          document.waemc031.vclanofbc.focus();
          return false
      }else
        wamod = document.waemc031.vclanomod.value
        wafbc = document.waemc031.vclanofbc.value
        if (wafbc > wamod){
            alert("Ano Modelo do veículo não pode ser maior que o Ano de fabricação");
            document.waemc031.vclanofbc.focus();
            return false
        }
        wdif = wamod - wafbc
        if (wdif > 1){
           alert("Ano modelo não pode ter mais que 1 ano de diferença do ano de fabricação do veículo");
           document.waemc031.vclanofbc.focus();
           return false
        }else
           return true
   }
   function check_combustivel(){
      if (document.waemc031.combustivel.options[document.waemc031.combustivel.selectedIndex].value == "0"){
          alert("Favor informar o tipo de combustível");
          document.waemc031.combustivel.focus();
          return false
      }else
          return true
   }
   function maiuscula(campo){
      campo.value=campo.value.toUpperCase()
   }
END
}else{
     $JSCRIPT=<<END;
     function open_help(campo,op) {
       janela = '';
       if (campo == 'bonclacod') {
           janela = '/auto/trs/waemc036.html';
       }
       if (campo == 'perflg') {
           janela = '/auto/trs/waemc084.html';
       }
       if (janela == '') {
           janela = '/auto/trs/waemc088.html';
       }
       if (navigator.appName.indexOf("Netscape") != -1)
           janela=window.open(janela,'help','height=300,width=200,screenX=50,screenY=50,toolbar=no,menubar=no,scrollbars=yes,resizable=no,status=yes');
       else
          janela=window.open(janela,'help','height=300,width=200,left=50,top=50,toolbar=no,menubar=no,scrollbars=yes,resizable=no,status=yes');
     }
     function check_dados(){
        if (!check_veiculo())         return (false);
        if (!check_ano_modelo())      return (false);
        if (!check_combustivel())     return (false);
        return (true);
     }
     function check_veiculo(){
        if (document.waemc031.veiculo.value == ""){
            alert("Favor informar o veículo");
            document.waemc031.veiculo.focus();
            return false
        }else
            return true
     }
     function check_ano_modelo(){
        if (document.waemc031.vclanomod.value == ""){
            alert("Favor informar o ano modelo do veículo");
            document.waemc031.vclanomod.focus();
            return false;
        }
        if (!CheckNumber(document.waemc031.vclanomod.value)){
            alert("Favor informar somente números no ano modelo do veículo");
            document.waemc031.vclanomod.focus();
            return false;
        }
        return true;
     }
     function check_combustivel(){
        if (document.waemc031.combustivel.options[document.waemc031.combustivel.selectedIndex].value == "0"){
            alert("Favor informar o tipo de combustível");
            document.waemc031.combustivel.focus();
            return false
        }else
            return true
     }
     function maiuscula(campo){
        campo.value=campo.value.toUpperCase()
     }
     function CheckNumber(vlr){
        var rstr = "0123456789";
        for (var cont=0; cont < vlr.length; cont++) {
             var tchar = vlr.charAt(cont);
             if (rstr.indexOf(tchar) == -1) {
                 return false;
             }
        };
        return true;
     }
END
}
}
#---------------------------------------------------------------------------
sub DisplayError
#---------------------------------------------------------------------------
{
   @body = ();
   push @body,
        table({-border=>'0',-width=>'550',-cellspacing=>'1',-cellpadding=>'0'},
             Tr(
               td({-align=>'center',-valign=>'middle'},
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'2'},$ERROR[1]
                        )
                 ),"\n",
               ),"\n",
             );
}
