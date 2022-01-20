#! /usr/local/bin/perl
use CGI ":all";

#----------------------------------------------------
#
#----------------------------------------------------
# Programa              wctn01m00
# Versao 1.1                                 Nov/2000
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

$atdvclsgl = param("atdvclsgl");

$webusrcod=param("webusrcod");

$sesnum = param("sesnum");

$macsissgl = param("macsissgl");

$usrtip = param("usrtip");

#------------------------------
# Colocando aspas nas variaveis
#------------------------------
push @ARG,$usrtip,$webusrcod,$sesnum,$macsissgl,$atdvclsgl;
$ARG = sprintf("'%s'",join('\' \'',@ARG));

#print header, start_html,$ARG;

#----------------------------
# Dados recebidos do informix
#----------------------------
$prog = "(cd /webserver/cgi-bin/ct24h/trs ; . ../../setvar.sh; wctn01m00.4gc $ARG)";
open (PROG, "$ambiente\"$prog\" |") || die ("Nao foi possivel executar $prog: $!\n");
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
   #---------------------------------
   # Criacao dos campos do formulario
   #---------------------------------
   if ($_ =~ /^PADRAO@@\d.*/) {
       @DADOS = split '@@',$_;
       if ($DADOS[1] == 2) {
           &Lbox;
       }elsif ($DADOS[1] == 3) {
               &ChkBox;
       }elsif ($DADOS[1] == 5 || $DADOS[1] == 6) {
               &TextDispInput;
       }elsif ($DADOS[1] == 7) {
               &Coluna;
       }
   }
}
#---------------------------------------
# Montando botao de voltar conforme erro
#---------------------------------------
if ($ERROR[0] eq NOSESS) {
    $voltar = a({-href=>'/prestador/trs/',-target=>'_top'},
                  img{-src=>'/corporat/images/bot_voltar.gif',-width=>'79',-height=>'15',border=>'0'}
               );
}else{
     $voltar = a({-href=>'JavaScript:history.back()'},
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
         start_html(-title=>$titulo,-bgcolor=>'#FFFFFF',-script=>$JSCRIPT),br,
        #start_form(-method=>'POST',-name=>'wctn01m00',-action=>"/cgi-bin/ct24h/trs/wctn01m01.pl",-onSubmit=>'return check_dados()'),br,

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
         hidden(-name=>'atdvclsgl',
                        -value=>$atdvclsgl
               ),"\n";
   push @header,
         center(
               table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'0'},
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
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},b('POSIÇÃO DA FROTA - SINAIS'))
                        ),"\n",
                      ),"\n",
                    Tr(
                      td({-colspan=>'2',height=>'12'},'&nbsp;'),"\n",
                      ),"\n",
                    Tr(
                      td(font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#6484BF'},'Clique na sequência do movimento para detalhamento.')
                        ),"\n",
                      ),"\n",
                    Tr(
                      td({-colspan=>'2',height=>'12'},'&nbsp;'),"\n",
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
                  ),"\n",
                ),"\n",
              Tr(
                td({-align=>'right',-colspan=>'2'},"\n",
                     img {-src=>'/corporat/images/linha_azul.gif',-width=>'550',-height=>'1'}
                  ),"\n",
                ),"\n",
              ),"\n",br();
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
        $lista {ucfirst($DADOS[$op])} = ucfirst($DADOS[$op]);
        if ($DADOS[$op + 1] == 1) {
            $def = ucfirst($DADOS[$op]);
        }
   };
   #-----------------------------------------------------
   # Carregando indices do vetor associativo em uma lista
   #-----------------------------------------------------
   @indice = sort(keys %lista);
   @sort = sort{$a <=> $b} @indice;
   #------------------------
   # Montando help do titulo
   #------------------------
   if ($DADOS[4] == 1) {
       $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                   font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},"\n",
                       a({-href=>"javascript:open_help('$DADOS[2]')"},$DADOS[3])
                       )
                )
   }else{
       $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                   font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$DADOS[3]
                       )
                )
   };
   push @body,
         table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
              Tr($hlp,"\n",
                td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},"\n",
                     popup_menu(-name=>$DADOS[2],
                                -value=>[@sort],
                                -labels=>\%lista,
                                -default=>$def,
                                -override=>1
                               )
                  ),"\n",
                ),"\n",
              );
}
#---------------------------------------------------------------------------
sub ChkBox
#---------------------------------------------------------------------------
{
   $linha = '';
   for ($cont=1, $i=6, $op=7; $op < $#DADOS ; $cont++, $i=$i + 4, $op=$op + 4) {
      #-------------------------
      # Indica campo selecionado
      #-------------------------
      $def = ($DADOS[$op + 1] == 1)?$DADOS[$i]:'';
      #----------------------
      # Indica campo com help
      #----------------------
      if ($DADOS[$op + 2] == 1) {
          $linha .= checkbox(-name=>$DADOS[2],
                             -value=>$DADOS[$i],
                             -label=>"",
                             -checked=>$def
                            );
          $linha .= a({-href=>"javascript:open_help('$DADOS[$i]')"},ucfirst(lc($DADOS[$op])))
      }else {
            $linha .= checkbox(-name=>$DADOS[2],
                               -value=>$DADOS[$i],
                               -label=>ucfirst(lc($DADOS[$op])),
                               -checked=>$def
                              )
      }

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
      if ($DADOS[5] == 1) {
          $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                      font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},
                          a({-href=>"javascript:open_help('$DADOS[2]')"},ucfirst(lc($DADOS[4])))
                          )
                   )
      }else{
          $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},
                      font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},ucfirst(lc($DADOS[4]))
                          )
                   )
      }
   }
   if ($DADOS[4] eq '') {
        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},
                   Tr(
                     td({-colspan=>'2',-align=>'left',-bgcolor=>'#D7E7F1',-height=>'23'},
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
        push @body,
              table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'1'},"\n",
                   Tr(
                     td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$tit
                              )
                       ),"\n",
                     td({-align=>'left',-bgcolor=>'#D7E7F1',-width=>'71%',-height=>'23'},"\n",
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},$row
                              )
                       ),"\n",
                     ),"\n",
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
                     ),"\n"
        }else{
             $hlp = td({-align=>'left',-bgcolor=>'#A8CDEC',-width=>'29%',-height=>'23'},"\n",
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'1'},ucfirst(lc($DADOS[4]))
                             )
                      ),"\n"
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
                       ),"\n",
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
            if ($DADOS[$t] =~ /\d/){
                $row = td({-align=>$align{"$DADOS[$a]"},-valign=>$align{"$DADOS[$av]"},-bgcolor=>$color{"$DADOS[$c]"},-width=>$DADOS[$w],-height=>$DADOS[$h]},"\n",
                            font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$DADOS[$f]},
                               #a({-href=>sprintf('/cgi-bin/ct24h/trs/wctn01m01.pl')},$est)
                                a({-href=>sprintf('/cgi-bin/ct24h/trs/wctn01m01.pl?usrtip=%s&webusrcod=%d&sesnum=%d&macsissgl=%s&mdtmvtcod=%d&',$usrtip,$webusrcod,$sesnum,$macsissgl,$est)},$est)
                                )
                         ),"\n"
            }else{
                 $row = td({-align=>$align{"$DADOS[$a]"},-valign=>$align{"$DADOS[$av]"},-bgcolor=>$color{"$DADOS[$c]"},-width=>$DADOS[$w],-height=>$DADOS[$h]},"\n",
                             font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$DADOS[$f]},$est
                                 )
                          ),"\n"
            }
        }else{
             $row = $row . td({-align=>$align{"$DADOS[$a]"},-valign=>$align{"$DADOS[$av]"},-bgcolor=>$color{"$DADOS[$c]"},-width=>$DADOS[$w],-height=>$DADOS[$h]},"\n",
                                font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$DADOS[$f]},$est
                                    )
                             ),"\n"
        }
   }
   push @body,
         table({-border=>$DADOS[3],-width=>'550',-cellpadding=>'1',-cellspacing=>'1',-align=>'center'},"\n",
              Tr($row),"\n",
              ),"\n";
}
#---------------------------------------------------------------------------
sub Create_JavaScript
#---------------------------------------------------------------------------
{
   $JSCRIPT=<<END;
   function check_dados(){
      if (!check_solicitacao()) return (false);
      return (true);
   }
   function check_solicitacao(){
      if (!document.waemc003.segvia[0].checked &&
          !document.waemc003.segvia[1].checked &&
          !document.waemc003.segvia[2].checked &&
          !document.waemc003.segvia[3].checked) {
           alert ("Antes de continuar o processo é necessário selecionar o produto desejado.");
           document.waemc003.segvia[0].focus();
           document.waemc003.segvia[0].select();
           return false;
      }
      return true;
   }
END
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
sub DisplayError
#---------------------------------------------------------------------------
{
   @body = ();
   push @body,br(),br(),
        table({-border=>'0',-width=>'550',-cellpadding=>'0',-cellspacing=>'0'},
             Tr(
               td({-align=>'center',-valign=>'middle'},"\n",
                    font({-face=>'Arial,Helvetica,Verdana',-size=>'1'},$ERROR[1]
                        )
                 ),"\n",
               ),"\n",
             Tr(
               td({height=>'30'},'&nbsp;')
               ),"\n",
             );
}
