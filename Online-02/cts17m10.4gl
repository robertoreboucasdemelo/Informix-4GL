#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
# .............................................................................#
# Sistema........: CT24HS                                                      #
# Modulo.........: cts17m10                                                    #
# Analista Resp..: Amilton                                                     #
# PSI/OSF........:                                                             #
#                  Funcao de retorno de clausulas por ramo                     #
#                  (retirada do modulo cts17m00 e criada separadamente)        #
# .............................................................................#
# Desenvolvimento: Raul, BIZ                                                   #
# Liberacao......: 02/01/2013                                                  #
#..............................................................................#
#                       * * *  ALTERACOES  * * *                               #
#                                                                              #
# Data        Autor Fabrica PSI         Alteracao                              #
# ----------  ------------- ------      ---------------------------------------#
#                                                                              #
#------------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"
globals "/homedsa/projetos/geral/globals/framg001.4gl"

#-------------------------------------------------------------------------------
 function cts17m10_clausulas(param,lr_dados,lr_cts17m00)
#-------------------------------------------------------------------------------
   define param        record
          succod       like datrservapol.succod
         ,ramcod       like datrservapol.ramcod
         ,aplnumdig    like datrservapol.aplnumdig
         ,itmnumdig    like datrservapol.aplnumdig
   end record

   define lr_dados     record
          plncod       like datksegsau.plncod
   end record

   define l_wk         record
          prporg       like rsdmdocto.prporg
         ,prpnumdig    like rsdmdocto.prpnumdig
   end record

   define ws           record
          clscod       like rsdmclaus.clscod
         ,clscodant    like rsdmclaus.clscod
         ,rsdclscod    like rsdmclaus.clscod
         ,datclscod    like datrsocntzsrvre.clscod
         ,sgrorg       like rsdmdocto.sgrorg
         ,sgrnumdig    like rsdmdocto.sgrnumdig
         ,prporg       like rsdmdocto.prporg
         ,prpnumdig    like rsdmdocto.prpnumdig
   end record

   define lr_cts17m00   record
          lgdtxt       char (65)
         ,brrnom       like datmlcl.brrnom
         ,cidnom       like datmlcl.cidnom
         ,ufdcod       like datmlcl.ufdcod
         ,lgdnum       like datmlcl.lgdnum
         ,lgdcep       like datmlcl.lgdcep
         ,lgdcepcmp    like datmlcl.lgdcepcmp
         ,lclrefptotxt like datmlcl.lclrefptotxt
   end record

   define a_cts17m00   array[2] of record
          lgdtxt       char (65)
         ,lgdnum       like datmlcl.lgdnum
         ,brrnom       like datmlcl.brrnom
         ,cidnom       like datmlcl.cidnom
         ,ufdcod       like datmlcl.ufdcod
         ,lgdcep       like datmlcl.lgdcep
         ,lgdcepcmp    like datmlcl.lgdcepcmp
         ,lclrefptotxt like datmlcl.lclrefptotxt
   end record


   define w_cts17m00   record
          clscod       like datrsocntzsrvre.clscod
   end record

   define l_rmemdlcod  like datrsocntzsrvre.rmemdlcod
         ,l_erro              smallint

   define l_sql_stmt   char(500)

   initialize ws.*
             ,l_wk.*
             ,a_cts17m00 to null

   let a_cts17m00[1].lgdtxt       = lr_cts17m00.lgdtxt
   let a_cts17m00[1].lgdnum       = lr_cts17m00.lgdnum
   let a_cts17m00[1].brrnom       = lr_cts17m00.brrnom
   let a_cts17m00[1].cidnom       = lr_cts17m00.cidnom
   let a_cts17m00[1].ufdcod       = lr_cts17m00.ufdcod
   let a_cts17m00[1].lgdcep       = lr_cts17m00.lgdcep
   let a_cts17m00[1].lgdcepcmp    = lr_cts17m00.lgdcepcmp
   let a_cts17m00[1].lclrefptotxt = lr_cts17m00.lclrefptotxt
   let l_sql_stmt =  "  select sgrorg,         "
                    ,"         sgrnumdig,      "
                    ,"         rmemdlcod       "
                    ,"    from rsamseguro      "
                    ,"   where succod    = ?   "
                    ,"     and ramcod    = ?   "
                    ,"     and aplnumdig = ?   "

   prepare p_cts17m10_001 from l_sql_stmt
   declare c_cts17m10_001 cursor for p_cts17m10_001

   if g_ppt.cmnnumdig is not null then

      let w_cts17m00.clscod       = g_a_pptcls[1].clscod
      let a_cts17m00[1].lgdtxt    = g_ppt.endlgdtip clipped, " ",
                                    g_ppt.endlgdnom clipped, " ",
                                    g_ppt.endnum
      let a_cts17m00[1].brrnom    = g_ppt.endbrr
      let a_cts17m00[1].cidnom    = g_ppt.endcid
      let a_cts17m00[1].ufdcod    = g_ppt.ufdcod
      let a_cts17m00[1].lgdnum    = g_ppt.endnum
      let a_cts17m00[1].lgdcep    = g_ppt.endcep
      let a_cts17m00[1].lgdcepcmp = g_ppt.endcepcmp
      if a_cts17m00[1].lclrefptotxt is null  then
         let a_cts17m00[1].lclrefptotxt = g_ppt.endcmp
      end if

      return ws.clscod
   end if

   #---------------------[ psi 202720-saude ruiz ]-----------------
   if g_documento.crtsaunum is not null then    # Saude
      let w_cts17m00.clscod = lr_dados.plncod
      return ws.clscod
   end if
   #----------------------------[ fim ]----------------------------

   if g_documento.succod    is not null  and
      g_documento.ramcod    is not null  and
      g_documento.aplnumdig is not null  then
      if g_documento.ramcod = 31     or
         g_documento.ramcod = 531  then

         let l_rmemdlcod = 0

         call f_funapol_ultima_situacao(param.succod,
                                        param.aplnumdig,
                                        param.itmnumdig)
                              returning g_funapol.*

        declare c_cts17m00_012 cursor for
        select clscod
          from abbmclaus
         where succod    = param.succod
           and aplnumdig = param.aplnumdig
           and itmnumdig = param.itmnumdig
           and dctnumseq = g_funapol.dctnumseq
           and clscod in ("033","33R","034","035","34A","35A","35R",
           "044","44R","046","46R","047","47R","048","48R","095")

         foreach c_cts17m00_012 into ws.clscod

            if ws.clscod <> "034" and
               ws.clscod <> "071" then
                let ws.clscodant = ws.clscod
            end if

            if ws.clscod = "034" or
               ws.clscod = "071" then

             if cta13m00_verifica_clausula(param.succod        ,
                                           param.aplnumdig     ,
                                           param.itmnumdig     ,
                                           g_funapol.dctnumseq ,
                                           ws.clscod           ) then

                let ws.clscod = ws.clscodant

                continue foreach
             end if
            end if

            exit foreach
         end foreach

      else
         #---------------------------------------------------------
         # Ramos Elementares
         #---------------------------------------------------------
         open c_cts17m10_001 using  g_documento.succod
                                   ,g_documento.ramcod
                                   ,g_documento.aplnumdig
         whenever error continue
         fetch c_cts17m10_001 into  ws.sgrorg
                                   ,ws.sgrnumdig
                                   ,l_rmemdlcod
         whenever error stop

         if sqlca.sqlcode = 0   then
            #---------------------------------------------------------
            # Procura situacao da apolice/endosso
            #---------------------------------------------------------
            select prporg    , prpnumdig
              into ws.prporg , ws.prpnumdig
              from rsdmdocto
             where sgrorg    = ws.sgrorg
               and sgrnumdig = ws.sgrnumdig
               and dctnumseq = (select max(dctnumseq)
                                  from rsdmdocto
                                 where sgrorg     = ws.sgrorg
                                   and sgrnumdig  = ws.sgrnumdig
                                   and prpstt     in (19,65,66,88))

            if sqlca.sqlcode = 0   then
               declare c_cts17m10_003 cursor for
                select clscod
                  from rsdmclaus
                 where prporg     = ws.prporg
                   and prpnumdig  = ws.prpnumdig
                   and lclnumseq  = 1
                   and clsstt     = "A"

               let ws.clscod = 0

               foreach c_cts17m10_003  into  ws.rsdclscod
                  let ws.datclscod = ws.rsdclscod
                  case
                     when g_documento.ramcod =  11 or
                          g_documento.ramcod = 111
                          if (ws.datclscod = 13 or ws.datclscod = "13R") then
                             let ws.clscod = ws.datclscod
                          end if

                     when g_documento.ramcod =   44 or
                          g_documento.ramcod =  118
                          if (ws.datclscod = 20      or ws.datclscod = "20R")   or
                              ws.datclscod = 21      or
                              ws.datclscod = 22      or
                              ws.datclscod = 23      or
                             (ws.datclscod = 24      or ws.datclscod = "24C"  or ws.datclscod = "24R") or
                              ws.datclscod = 30      or ws.datclscod = 55     or
                             (ws.datclscod = 31      or ws.datclscod = "31R" or
                              ws.datclscod = "31C" ) or
                             (ws.datclscod = 56      or ws.datclscod = "56R" or
                              ws.datclscod = "56C")  or
                             (ws.datclscod = 32      or ws.datclscod = 57     or
                              ws.datclscod = "32R"   or ws.datclscod = "57R") or
                             (ws.datclscod = 36      or ws.datclscod = "36R") or
                             (ws.datclscod = 38      or ws.datclscod = "38R") or
                             (ws.datclscod = 40      or ws.datclscod = 48)    or
                             (ws.datclscod = 59      or ws.datclscod = "59R") or
                             (ws.datclscod = 60      or ws.datclscod = "60R") or
                             (ws.datclscod = 61      or ws.datclscod = "61R") or
                             (ws.datclscod = 85      or ws.datclscod = "85R") or
                              ws.datclscod = 76      or ws.datclscod = 41     then

                             #inclusao da cls 36/36R-a pedido Judite-08/05/07
                             if ws.datclscod > ws.clscod  then
                                let ws.clscod = ws.datclscod
                             end if
                          end if

                     when g_documento.ramcod =   45 or
                          g_documento.ramcod =  114
                          if (ws.datclscod =   08   or ws.datclscod = "08C"   or
                              ws.datclscod = "8C"   or ws.datclscod = "08R"   or
                              ws.datclscod = "8R" ) or
                             (ws.datclscod =   10   or ws.datclscod = "10R")  or
                             (ws.datclscod =   11   or ws.datclscod = "11R")  or
                             (ws.datclscod =   12   or ws.datclscod = "12C"   or ws.datclscod = "12R") or
                             (ws.datclscod =   13   or ws.datclscod = "13R")  or
                             (ws.datclscod =   28   or ws.datclscod = "28R")  or
                             (ws.datclscod =   29   or ws.datclscod = "29R")  or
                              ws.datclscod =   30   or ws.datclscod = 55      or
                              ws.datclscod = "30R"  or ws.datclscod = "56R"   or
                             (ws.datclscod =   31   or ws.datclscod = 56      or
                              ws.datclscod = "31C"  or ws.datclscod = "56C"   or
                              ws.datclscod = "31R") or
                             (ws.datclscod =   32   or ws.datclscod = 57      or
                              ws.datclscod = "32R"  or ws.datclscod = "57R" ) or
                             (ws.datclscod =   39   or ws.datclscod = "39R")  or
                             (ws.datclscod =   38   or ws.datclscod = "38R")  or
                             (ws.datclscod =   40   or ws.datclscod = "40R")  or
                             (ws.datclscod =   56   or ws.datclscod = "56R")  or
                             (ws.datclscod =   77   or ws.datclscod = "77R")  or
                             (ws.datclscod =   78   or ws.datclscod = "78R")  or
                             (ws.datclscod =   79   or ws.datclscod = "79R" or ws.datclscod = "79C") or
                             (ws.datclscod =   80   or ws.datclscod = "80R")  or
                             (ws.datclscod =   81   or ws.datclscod = 82 or ws.datclscod =   "82R") or
                             (ws.datclscod =   83   or ws.datclscod = "83R" or ws.datclscod = "83C") or
                             (ws.datclscod =   84   or ws.datclscod = "84R" ) or
                             (ws.datclscod =   102   or ws.datclscod = 103 ) or
                             (ws.datclscod =   104   or ws.datclscod = 104 ) or
                             (ws.datclscod =   106   or ws.datclscod = 107 ) or
                             (ws.datclscod =   108 or ws.datclscod =  '80L') or
                             (ws.datclscod =  '80C' or ws.datclscod = "84C" )or
                              ws.datclscod = 90     or ws.datclscod = 91     or
                              ws.datclscod = 92     or ws.datclscod = 93     or
                              ws.datclscod = 94     or ws.datclscod = 95     or
                              ws.datclscod = 96     or ws.datclscod = 105    then
                             #inclusao da cls 40/40R-a pedido Neia-07/05/07
                             if ws.datclscod > ws.clscod  then
                                let ws.clscod = ws.datclscod
                             end if
                          end if
                     when g_documento.ramcod =   46 or
                          g_documento.ramcod =  746
                          if ws.datclscod = 30      or
                            (ws.datclscod = 31      or ws.datclscod = "31C"  or ws.datclscod = "31R") or
                            (ws.datclscod = 32      or ws.datclscod = "32R") then
                             if ws.datclscod > ws.clscod  then
                                let ws.clscod = ws.datclscod
                             end if
                          end if
                     when g_documento.ramcod = 47
                        if (ws.datclscod = 10 or ws.datclscod = "10R") or
                           (ws.datclscod = 13 or ws.datclscod = "13R") then
                           if ws.datclscod > ws.clscod  then
                              let ws.clscod = ws.datclscod
                           end if
                        end if
                  end case
               end foreach


               if ws.clscod = 0  then
                  initialize ws.clscod to null
               end if
            end if
         else
            if sqlca.sqlcode < 0 then
               error 'Erro SELECT c_cts17m10_001: ' ,sqlca.sqlcode
               let l_erro = true
            end if
         end if
      end if
   end if

   let l_wk.prporg    = ws.prporg
   let l_wk.prpnumdig = ws.prpnumdig

   return l_erro
         ,l_wk.prporg
         ,l_wk.prpnumdig
         ,l_rmemdlcod
         ,ws.clscod
         ,a_cts17m00[1].lgdtxt
         ,a_cts17m00[1].brrnom
         ,a_cts17m00[1].cidnom
         ,a_cts17m00[1].ufdcod
         ,a_cts17m00[1].lgdnum
         ,a_cts17m00[1].lgdcep
         ,a_cts17m00[1].lgdcepcmp
         ,a_cts17m00[1].lclrefptotxt

end function  ###  cts17m10_clausulas
