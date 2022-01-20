#! /usr/local/bin/perl
 #----------------------------------------------------------------------------#
 #  Modulo...: wissc126.pl                                                    #
 #  Sistema..: Informatica - seguranca web                                    #
 #  Criacao..: Jan/2001                                                       #
 #  Autor....: Estela/Marcelo                                                 #
 #                                                                            #
 #  Objetivo.: Monta/exibe help sobre os niveis de acesso de um sistema       #
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

 #-----------------------------------------------------------------------------
 # Inclui  subrotinas 
 #-----------------------------------------------------------------------------
 require "wissc218.pl";     #--> Vetores de conversao         


$ambiente = "remsh aplweb01 -l runwww ";

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $usrtip = param("usrtip");
 if (!defined($usrtip))
    {&pagina_erro("Parâmetro tipo usuário n\343o informado!");}
 
 $webusrcod = param("webusrcod");
 if (!defined($webusrcod))
    {&pagina_erro("Código do usuário n\343o informado!");}
 
 $sesnum = param("sesnum");
 if (!defined($sesnum))
    {&pagina_erro("Parâmetro sessao corretor n\343o informado!");}
 
 $macsissgl = param("macsissgl");      
 if (!defined($macsissgl))
    {&pagina_erro("Parâmetro sigla macro sistema n\343o informada!");}
 
 $sissgl = param("sissgl");      
 if (!defined($sissgl))
    {&pagina_erro("Parâmetro sigla sistema n\343o informada!");}

 push @ARG, $usrtip,    
            $webusrcod, 
            $sesnum,    
            $macsissgl, 
            $sissgl;

 $ARG = sprintf("'%s'",join('\' \'',@ARG));

 #-----------------------------------------------------------------------------
 # Executa programa Infomix 4GL e tratar os displays
 #-----------------------------------------------------------------------------
 $prog = "(cd /webserver/cgi-bin/seweb/trs ; . ../../setvardsa.sh; wissc127.4gc $ARG)";

 open (PROG, "$ambiente\"$prog\" |") || die ("N\343o foi poss\355vel executar $prog: $!\n");

 #-----------------------------------------------------------------------------
 # Montando body variavel @body (parte central do fonte HTML)
 #-----------------------------------------------------------------------------
 while (<PROG>) 
   {
    @REGISTRO = split '@@',$_;

    if ($REGISTRO[0] eq "NOSESS")
       { &pagina_erro($REGISTRO[1]); }
 
    elsif ($REGISTRO[0] eq "ERRO")
       { &pagina_erro($REGISTRO[1]); }

    if ($REGISTRO[0] eq "PADRAO")
       {
        if ($REGISTRO[1] == 1)
           { &monta_titulo(@REGISTRO); }

        elsif ($REGISTRO[1] == 6)
              { &monta_tabela(@REGISTRO); }

        else
           { &pagina_erro("Padrão não previsto!"); }
       }
    else
       { &pagina_erro("Problemas no tipo do registro!"); }
   }

 close(PROG);

 #-----------------------------------------------------------------------------
 # Montando cabecalho da pagina
 #-----------------------------------------------------------------------------
 $texto = "Lembre-se que, ao atribuir um nível de acesso, o usuário terá acesso<br>automaticamente aos níveis inferiores.";

 push @cabecalho, header,

 start_html(-title=>'Porto Seguro',-bgcolor=>'#FFFFe0'),"\n",
 start_form(-method=>'POST',-name=>'wissc126'),"\n";

 push @cabecalho,

 center(
    table({-border=>'0',-width=>'440',-cellpadding=>'0',-cellspacing=>'0'},"\n",
          Tr(
             td({-align=>'left'},
                b(font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2',-color=>'#000000'},$texto)),"\n"
                    ),"\n",
               ),"\n",
         ),"\n",
       ),"\n",
 br();

 #-----------------------------------------------------------------------------
 # Montando rodape da pagina
 #-----------------------------------------------------------------------------
 push @rodape, br(),"\n",
  table({-border=>'0',-width=>'440',-cellpadding=>'0',-cellspacing=>'1'},"\n",
         Tr(
            td({-align=>'center'},"\n",
               submit(-name=>'btoSubmit',
                      -value=>'Fechar',
                      -OnClick=>'window.close()'),"\n"
              ),"\n"
            ),"\n",
         ),"\n";

 #-----------------------------------------------------------------------------
 # Agrupa componentes do HTML e envia para o browser
 #-----------------------------------------------------------------------------
 push @html, @cabecalho,
 center(
        table({-border=>'1',-width=>'440',-cellspacing=>'0',-cellpadding=>'0'},
               @body, @rodape
             ),"\n"
       ),"\n",

 end_form,"\n",
 end_html,"\n";

 print @html;

 exit(0);


#----------------------------------------------------------------------------
 sub monta_tabela()
#----------------------------------------------------------------------------
 {
   local(@PADRAO) = @_;   

   #-------------------------------------------------------------------------
   # Montando quantidade de colunas solicitadas
   #-------------------------------------------------------------------------
   for ($i=1,$e=3,$a=4,$c=5,$f=6,$w=7,$t=8,$k=9,; $i <= $PADRAO[2]; $i++,$e=$e+7,$a=$a+7,$c=$c+7,$f=$f+7,$w=$w+7,$t=$t+7,$k=$k+7)
    {
      if (!defined ($PADRAO[$t]) || $PADRAO[$t] eq '')
         {
           $PADRAO[$t] = '&nbsp;';
         }

     #-------------------------------------------------------------------
     # Carregando estilo desejado
     #-------------------------------------------------------------------
     if ($PADRAO[$e] eq 'B')
        { $est = b($PADRAO[$t]); }
     elsif ($PADRAO[$e] eq 'I')
        { $est = i($PADRAO[$t]); }
     elsif ($PADRAO[$e] eq 'N')
        { $est = $PADRAO[$t]; }

     if ($i == 1)
        {
          if ($PADRAO[$k] ne '')
             { 
               $row = td({-align=>$align{"$PADRAO[$a]"},-bgcolor=>$color{"$PADRAO[$c]"},-width=>$PADRAO[$w],-height=>'23'},
                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$PADRAO[$f]},
                              a({-href=>"$PADRAO[$k]"},$est
                               ),"\n"
                             ),"\n"
                        ),"\n"
             }
          else
             {
               $row = td({-align=>$align{"$PADRAO[$a]"},-bgcolor=>$color{"$PADRAO[$c]"},-width=>$PADRAO[$w],-height=>'23'},

                         font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$PADRAO[$f]},$est
                             ),"\n"
                        ),"\n"
             }
        }
     else
        {
          if ($PADRAO[$k] ne '')
             {
               $row = $row . td({-align=>$align{"$PADRAO[$a]"},-bgcolor=>$color{"$PADRAO[$c]"},-width=>$PADRAO[$w],-height=>'23'},
                                font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$PADRAO[$f]},
                                     a({-href=>"$PADRAO[$k]"},$est
                                      ),"\n"
                                    ),"\n"
                               ),"\n"
             }
          else
             {
               $row = $row . td({-align=>$align{"$PADRAO[$a]"},-bgcolor=>$color{"$PADRAO[$c]"},-width=>$PADRAO[$w],-height=>'23'},
                                font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>$PADRAO[$f]},$est
                                    ),"\n"
                                ),"\n"
             }
        }
    }

   push @body,
     table({-border=>'1',-width=>'440',-cellpadding=>'0',-cellspacing=>'0'},
           Tr($row),"\n",
             ),"\n";
 }


#----------------------------------------------------------------------------
 sub monta_titulo()
#----------------------------------------------------------------------------
 {
   local(@PADRAO) = @_;

   #-------------------------------------------------------------------------
   # Carregando alinhamento desejado
   #-------------------------------------------------------------------------
   if ($PADRAO[3] eq 'R')
      { $align = 'right'; }
   elsif ($PADRAO[3] eq 'L')
      { $align = 'left'; }
   else
      { $align = 'center'; }

   #-------------------------------------------------------------------------
   # Carregando cor desejada
   #-------------------------------------------------------------------------
   $cor = $color{"$PADRAO[4]"};

   for ($i=5; $i <= $#PADRAO; $i++)
      {
        if ($i == 5)
           { $row = $PADRAO[$i]; }
        else
           { $row = $row . br . $PADRAO[$i]; }
      }

   if ($PADRAO[2] eq 'B')
      {
        push @body,
              table({-border=>'1',-width=>'440',-cellpadding=>'0',-cellspacing=>'0'},
                   Tr(
                     td({-align=>$align,-bgcolor=>$cor,-height=>'23'},
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2'},
                          b($row)
                              )
                       )
                     ),"\n",
                   );
      }
   elsif ($PADRAO[2] eq 'I')
         {
           push @body,
             table({-border=>'1',-width=>'440',-cellpadding=>'0',-cellspacing=>'0'},
                   Tr(
                     td({-align=>$align,-bgcolor=>$cor,-height=>'23'},
                          font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2'},
                          i($row)
                              )
                       )
                     ),"\n",
                   );
         }
   else
      {
        push @body,
          table({-border=>'1',-width=>'440',-cellpadding=>'0',-cellspacing=>'0'},
               Tr(
                 td({-align=>$align,-bgcolor=>$cor,-height=>'23'},
                      font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2'},$row
                          )
                    )
                 ),"\n",
               );
      }
 }


#-----------------------------------------------------------------------------
 sub pagina_erro()
#-----------------------------------------------------------------------------
 {
   local($msgtxt) = @_;

   push @cabecalho, header,

   start_html(-title=>'Porto Seguro',-bgcolor=>'#FFFFe0'),"\n",
   start_form(-method=>'POST',-name=>'wissc126'),"\n";
 
   push @body,
    br(),"\n",br(),"\n",
    table({-border=>'0',-width=>'440',-cellpadding=>'0',-cellspacing=>'0'},"\n",
           Tr(
              td({-align=>'center',-height=>'23'},"\n",
                 font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'3'},"\n",
                      b('ATENÇÃO!')
                     ),"\n",br(),br()
                ),"\n"
             ),"\n",
           Tr(
              td({-align=>'center',-height=>'23'},"\n",
                 font({-face=>'ARIAL,HELVETICA,VERDANA',-size=>'2'},"\n",
                      $msgtxt
                     ),"\n", br(), br(), br(),
                ),"\n"
             ),"\n",
           Tr(
              td({-align=>'center'},"\n",
                 submit(-name=>'btoSubmit',
                        -value=>'Fechar',
                        -OnClick=>'window.close()'),"\n"
                ),"\n"
             ),"\n",
         ),"\n";

   push @html, @cabecalho,

   center( @body ),"\n",
   end_form,"\n",
   end_html,"\n";

   print @html;

   exit(0);
 }


#-----------------------------------------------------------------------------
 sub debugar()
#-----------------------------------------------------------------------------
 {
   print "Content-type: text/html\n\n";
   print "*** PARAMETROS WISSC126.PL *** <br>\n";
   print "Usrtip     = $usrtip           <br>\n";
   print "Webusrcod  = $webusrcod        <br>\n";
   print "Sesnum     = $sesnum           <br>\n";
   print "Macsissgl  = $macsissgl        <br>\n";
   print "Sissgl     = $sissgl           <br>\n";
   print "Line       = $_                <br>\n";
   print "Registro0  = $REGISTRO[0]      <br>\n";
   print "Registro1  = $REGISTRO[1]      <br>\n";
   print "Registro2  = $REGISTRO[2]      <br>\n";
   print "Registro3  = $REGISTRO[3]      <br>\n";
   print "Registro4  = $REGISTRO[4]      <br>\n";
   print "Registro5  = $REGISTRO[5]      <br>\n";

   exit(0);
 }
