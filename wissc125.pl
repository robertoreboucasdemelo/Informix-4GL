#! /usr/local/bin/perl
 #----------------------------------------------------------------------------#
 #  Modulo...: wissc125.pl                                                    #
 #  Sistema..: Informatica - Seguranca web                                    #
 #  Criacao..: Jan/2001                                                       #
 #  Autor....: Estela/Marcelo                                                 #
 #                                                                            #
 #  Objetivo.: Abre novo browser para exibir help sobre os niveis de acesso   #
 #             de um sistema                                                  #
 #----------------------------------------------------------------------------#
 #----------------------------------------------------------------------------#
 
 use CGI ":all"; 

 #-----------------------------------------------------------------------------
 # Carregando parametros recebidos
 #-----------------------------------------------------------------------------
 $usrtip = param("usrtip");
 if (!defined($usrtip))
    {$usrtip = '';}
 
 $webusrcod = param("webusrcod");
 if (!defined($webusrcod))
    {$webusrcod = '';}
 
 $sesnum = param("sesnum");
 if (!defined($sesnum))
    {$sesnum = '';}
 
 $macsissgl = param("macsissgl");      
 if (!defined($macsissgl))
    {$macsissgl = '';}
 
 $sissgl = param("sissgl");      
 if (!defined($sissgl))
    {$sissgl = '';}


 #-----------------------------------------------------------------------------
 # Gera codigo em javascript para abrir novo browser
 #-----------------------------------------------------------------------------
  print <<"INICIO_MSG";

  <html>
  <head>

  <script language="JavaScript">
  <!--

  function func_wissc125_pagina()
  {
   pagina = "/cgi-bin/seweb/trs/wissc126.pl?usrtip=$usrtip&webusrcod=$webusrcod&sesnum=$sesnum&macsissgl=$macsissgl&sissgl=$sissgl";

   window.history.back(-1);

   if (navigator.appName.indexOf("Netscape") != -1)
       window.open(pagina,'window_erro','height=350,width=490,screenX=10,screenY=10,toolbar=0,menubar=no,scrollbars=yes,resizable=no,status=no');
   else
       window.open(pagina,'window_erro','height=350,width=490,left=10,top=10,toolbar=0,menubar=no,scrollbars=yes,resizable=no,status=no');
  }
  func_wissc125_pagina();

  //-->
  </script>

  </head>
  </html>

INICIO_MSG

 exit(0);
