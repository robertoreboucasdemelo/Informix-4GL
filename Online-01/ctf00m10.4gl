################################################################################
# Porto Seguro Cia Seguros Gerais                                      Nov/2010#
# .............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : ctf00m10                                                     #
# Analista Resp.: Carla Rampazzo                                               #
# PSI           :                                                              #
# Objetivo      : Localizar/Retornar Historico do Motivo da Visita (p/S67/S68) #
#                 Historico gravado em ct15m00                                 #
# .............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
# ----------  -------------- --------- ----------------------------------------#
#                                                                              #
################################################################################

database porto

#---------------------------------------------------------------------------
function ctf00m10_hst_prt(param)
#---------------------------------------------------------------------------

   define param             record
	  atdsrvnum         like datmservico.atdsrvnum
	 ,atdsrvano         like datmservico.atdsrvano
   end record


   define l_ret             record
	  codigo            smallint --> 0-OK / 1-Nao encontrado
         ,texto             char(140)
   end record


   define l_c24srvdsc       like datmservhist.c24srvdsc
         ,l_c24txtseq       like datmservhist.c24txtseq
         ,l_c24txtseqmax    like datmservhist.c24txtseq
	 ,l_linha1          char(70)
         ,l_linha2          char(70)


   let l_c24srvdsc    = null
   let l_c24txtseq    = null
   let l_c24txtseqmax = null
   let l_linha1       = null
   let l_linha2       = null
   let l_ret.codigo   = 1  
   let l_ret.texto    = null  



   #-------------------------------------------------------------
   --> Localiza no Historico do Servico a Mensagem para Prestador
   #-------------------------------------------------------------
   whenever error continue
   declare c_ctf00m10001 cursor for

      select c24srvdsc
            ,c24txtseq
        from datmservhist
       where atdsrvnum = param.atdsrvnum
         and atdsrvano = param.atdsrvano
       order by c24txtseq

   foreach c_ctf00m10001 into l_c24srvdsc
                             ,l_c24txtseq

      whenever error stop

      if sqlca.sqlcode <> 0   and
         sqlca.sqlcode <> 100 then
         error " Erro em c_ctf00m10001. Avise a informatica"
      end if

      #---------------------------------------------------------------------
      --> A mensagem sempre ocupara 2 linhas do historico
      --> mesmo que o atendente nao registre a 2a.linha, fica gravado um "."
      #---------------------------------------------------------------------

      if l_c24srvdsc = "Mensagem para Prestador:" then
	 let l_c24txtseqmax = l_c24txtseq + 2
         let l_ret.codigo   = 0  
      end if

      if l_c24txtseqmax is not null and 
         l_c24txtseqmax <> 0        then

         if l_c24txtseq = l_c24txtseqmax - 1 then
            let l_ret.texto = l_c24srvdsc

         end if

         if l_c24txtseq = l_c24txtseqmax then
            if l_c24srvdsc <> "." then
               let l_ret.texto = l_ret.texto clipped," " ,l_c24srvdsc
            end if
         end if

         if l_c24txtseq > l_c24txtseqmax then
            exit foreach
         end if
      end if
   end foreach

   return l_ret.*
   
end function  
