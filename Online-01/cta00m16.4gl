#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m16.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
#                 Funcao unica para chamar programas                         #
#............................................................................#
# Desenvolvimento: Ligia Mattge                                              #
# Liberacao      : 04/06/2007                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor   Fabrica     Origem     Alteracao                        #
# ---------- ----------------- ---------- -----------------------------------#
# 29/02/2008 Amilton, Meta      psi219967   Alterada a função chama_prog     #
#                                            a montagem do arqval referente  #
#                                            ao programa "cta02m00u11"       #
#----------------------------------------------------------------------------#
# 18/10/2008 Carla Rampazzo  PSI 230650 Passar p/ "ctg18" o campo atdnum     #
#----------------------------------------------------------------------------#
# 01/04/2010 Carla Rampazzo  PSI 219444 Receber os novos parametros lclnumseq#
#                                       e rmerscseq                          #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------#
 function cta00m16_chama_prog(lr_param)
#-----------------------------------#

   define lr_param  record
          prog         char(11),                     # Nome do programa 4gc
          ramcod       like datrservapol.ramcod,     # Codigo Ramo
          succod       like datrligapol.succod,      # Codigo Sucursal
          aplnumdig    like datrligapol.aplnumdig,   # Numero Apolice
          itmnumdig    like datrligapol.itmnumdig,   # Numero do Item
          edsnumref    like datrligapol.edsnumref,   # Numero do Endosso
          ligcvntip    like datmligacao.ligcvntip,   # Convenio Operacional
          prporg       like datrligprp.prporg,       # Origem da Proposta
          prpnumdig    like datrligprp.prpnumdig,    # Numero da Proposta
          solnom       char (15),                    # Solicitante
          ciaempcod    like datmligacao.ciaempcod,   # Empresa
          grupo        like gtakram.ramgrpcod,       # Grupo do Ramo
          c24soltipcod like datmligacao.c24soltipcod,# Tipo do Solicitante
          corsus       like gcaksusep.corsus,        # Susep dp Corretor
          atdnum       like datmatd6523.atdnum,      # Nro.Atendimento Atual
          lclnumseq    like datmsrvre.lclnumseq,     # Seq. Local de Risco
          rmerscseq    like datmsrvre.rmerscseq,     # Seq. Bloco do Condominio
          itaciacod    like datmitaapl.itaciacod     # Codigo da Companhia Itau   
   end record

   define l_resultado     smallint
          ,l_arg_val_fixos char(600)
          ,l_funmat char(6)
          ,l_horlig char(8)
          ,l_prog   char(10)

   let l_resultado     = null
   let l_funmat        = null
   let l_horlig        = null
   let l_prog          = null
   let l_arg_val_fixos = null

   if g_monitor.horaini is null or
      g_monitor.horaini = " "   then
      let g_monitor.horaini = current
   end if   
   
   if  lr_param.prog = "ctg18" then
       let l_prog    = "ctg18"
       let l_arg_val_fixos =
       "' ", g_issk.succod         using "<<<<<<<&",     " ' ",
       " '", g_issk.funmat         using "<<<<<<<&",     " ' ",
       "' ", g_issk.funnom         clipped,              " ' ",
       " '", g_issk.dptsgl         clipped,              " ' ",
       " '", g_issk.dpttip         clipped,              " ' ",
       " '", g_issk.dptcod         using "<<<<<<&",      " ' ",
       " '", g_issk.sissgl         clipped,              " ' ",
       " '", g_issk.acsnivcod      using "<<<<<&",       " ' ",
       " '", "Central24h",                               " ' ",
       " '", g_issk.usrtip         clipped,              " ' ",
       " '", g_issk.empcod         using "<<<<<<<<&",    " ' ",
       " '", g_issk.iptcod         using "<<<<<<<<&",    " ' ",
       " '", g_issk.usrcod         clipped,              " ' ",
       " '", g_issk.maqsgl         clipped,              " ' ",
       " '", lr_param.ramcod       using "<<<<<<<<<&",   " ' ",
       " '", lr_param.succod       using "<<<<<<<<<&",   " ' ",
       " '", lr_param.aplnumdig    using "<<<<<<<<<&",   " ' ",
       " '", lr_param.itmnumdig    using "<<<<<<<<<&",   " ' ",
       " '", lr_param.edsnumref    using "<<<<<<<<<&",   " ' ",
       " '", lr_param.ligcvntip    using "<<<<<<<<<&",   " ' ",
       " '", lr_param.prporg       using "<<<<<<<<<&",   " ' ",
       " '", lr_param.prpnumdig    using "<<<<<<<<<&",   " ' ",
       " '", lr_param.solnom       clipped,              " ' ",
       " '", lr_param.ciaempcod    using "<<&",          " ' ",
       " '", lr_param.grupo        using "<<&",          " ' ",
       " '", lr_param.c24soltipcod using "<&",           " ' ",
       " '", lr_param.corsus       clipped,              " ' ",
       " '", g_monitor.horaini     clipped,              " ' ",
       " '", lr_param.atdnum       using "<<<<<<<<<&",   " ' ",
       " '", lr_param.lclnumseq    using "<<<&",         " ' ",
       " '", lr_param.rmerscseq    using "<<<<&",        " ' ",
       " '", lr_param.itaciacod    using "<<<<&&",       " ' "     
       
   else
      if lr_param.prog = "cta02m00u11" then
          let l_prog   = "sct"
          let l_funmat = lr_param.solnom [1,6]
          let l_horlig = lr_param.solnom [7,14]
          let l_arg_val_fixos =
           "' ", g_issk.succod         using "<<<<<<<&",     "'  ",
           " '", g_issk.funmat         using "<<<<<<<&",     " ' ",
           "' ", g_issk.funnom         clipped,              "  '",
           " '", g_issk.dptsgl         clipped,              " ' ",
           " '", g_issk.dpttip         clipped,              " ' ",
           " '", g_issk.dptcod         using "<<<<<<&",      " ' ",
           " '", g_issk.sissgl         clipped,              " ' ",
           " '  ", g_issk.acsnivcod    using "<<<<<&",       " ' ",
           " '"  , "sct",                             " '",
           " '", g_issk.usrtip         clipped,              " ' ",
           " '", g_issk.empcod         using "<<<<<<<<&",    " ' ",
           " '", g_issk.iptcod         using "<<<<<<<<&",    " ' ",
           " '", g_issk.usrcod         clipped,              " ' ",
           " '", g_issk.maqsgl         clipped,              " ' ",
           " '", "ct24hs",                                   " '",
           " '", l_funmat              clipped,              " ' ",
           " '", l_horlig              clipped,              " ' ",
           " '", lr_param.succod       using "<<<<<<<<<&",   " ' ",
           " '", lr_param.ramcod       using "<<<<<<<<<&",   " ' ",
           " '", lr_param.aplnumdig    using "<<<<<<<<<&",   " ' ",
           " '", lr_param.itmnumdig    using "<<<<<<<<<&",   " ' "
      end if
   end if
      
   call roda_prog(l_prog, l_arg_val_fixos, 1)
        returning l_resultado    

   return l_resultado

end function
