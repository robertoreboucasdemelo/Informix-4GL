################################################################################
# Porto Seguro Cia Seguros Gerais                                      DEZ/2010#
# .............................................................................#
# Sistema       : Central 24h                                                  #
# Modulo        : cty20g00                                                     #
# Analista Resp.: Carla Rampazzo                                               #
# PSI           :                                                              #
# Objetivo      : Permitir Alteracao na Mensagem enviada ao Prestador quando   #
#                 houver o envio do Help Desk Casa Visita (S67 / S68)          #
# .............................................................................#
#                                                                              #
#                  * * * Alteracoes * * *                                      #
#                                                                              #
# Data        Autor Fabrica  Origem    Alteracao                               #
# ----------  -------------- --------- ----------------------------------------#
#                                                                              #
################################################################################


globals  "/homedsa/projetos/geral/globals/glct.4gl"

database porto

#---------------------------------------------------------------------------
function cty20g00_hst_prt(param)
#---------------------------------------------------------------------------

   define param             record
	  atdsrvnum         like datmservico.atdsrvnum
	 ,atdsrvano         like datmservico.atdsrvano
   end record


   define l_ret             record
	  codigo            smallint --> 0-OK / 1-Nao encontrado
         ,mensagem          char(140)
   end record


   define l_cty20g00        record
	  texto1            char(70)
         ,texto2            char(70)
         ,c24txtseq1        like datmservhist.c24txtseq
         ,c24txtseq2        like datmservhist.c24txtseq
         ,c24txtseq3        like datmservhist.c24txtseq
   end record


   define l_c24srvdsc       like datmservhist.c24srvdsc
         ,l_c24txtseq       like datmservhist.c24txtseq
         ,l_c24txtseqmax    like datmservhist.c24txtseq
         ,l_atdetpcod       like datmservico.atdetpcod
         ,l_data            date
         ,l_hora            datetime hour to minute
         ,l_cont            smallint
         ,l_texto           char(70)
	 ,l_texto1          char(70)
         ,l_texto2          char(70)

   let l_c24srvdsc    = null
   let l_c24txtseq    = null
   let l_c24txtseqmax = null
   let l_data         = null
   let l_hora         = null
   let l_atdetpcod    = null
   let l_texto        = null
   let l_texto1       = null
   let l_texto2       = null
   let l_cont         = 0
   let l_ret.codigo   = 1
   let l_ret.mensagem = "Nao ha mensagem para Prestador."

   initialize l_cty20g00.* to null



   #--------------------------------------------------------------
   --> Verifica se ha Mensagem com Motivo de Visita para Prestador
   #--------------------------------------------------------------
   whenever error continue
   declare c_cty20g00001 cursor for

      select c24srvdsc
            ,c24txtseq
        from datmservhist
       where atdsrvnum = param.atdsrvnum
         and atdsrvano = param.atdsrvano
       order by c24txtseq

   foreach c_cty20g00001 into l_c24srvdsc
                             ,l_c24txtseq

      whenever error stop

      if sqlca.sqlcode <> 0   and
         sqlca.sqlcode <> 100 then
         error " Erro em c_cty20g00001. Avise a informatica"
      end if

      #---------------------------------------------------------------------
      --> A mensagem sempre ocupara 2 linhas do historico
      --> mesmo que o atendente nao registre a 2a.linha, fica gravado um "."
      #---------------------------------------------------------------------

      if l_c24srvdsc = "Mensagem para Prestador:" then

	 let l_c24txtseqmax         = l_c24txtseq + 2
         let l_ret.codigo           = 0
	 let l_cty20g00.c24txtseq1  = l_c24txtseq
	 let l_cty20g00.c24txtseq2  = l_c24txtseq + 1
	 let l_cty20g00.c24txtseq3  = l_c24txtseq + 2

      end if

      if l_c24txtseqmax is not null and
         l_c24txtseqmax <> 0        then

         if l_c24txtseq = l_c24txtseqmax - 1 then
            let l_ret.mensagem  = l_c24srvdsc
            let l_texto1        = l_c24srvdsc
         end if

         if l_c24txtseq = l_c24txtseqmax then

            let l_texto2 = l_c24srvdsc

            if l_c24srvdsc <> "." then
               let l_ret.mensagem = l_ret.mensagem," " ,l_c24srvdsc
            end if
         end if

         if l_c24txtseq > l_c24txtseqmax then
            exit foreach
         end if
      end if
   end foreach

   #---------------------------------
   --> Nao ha Mensagem para Prestador
   #---------------------------------
   if l_ret.codigo = 1 then
      return l_ret.*
   end if


   #--------------------------------------
   --> Verifica se Etapa permite alteracao
   #--------------------------------------
   whenever error continue
   select atdetpcod
     into l_atdetpcod
     from datmservico
    where atdsrvnum = param.atdsrvnum
      and atdsrvano = param.atdsrvano
   whenever error stop

   if sqlca.sqlcode <> 0 then
      error " Nao localizou etapa-cty20g00. Avise a informatica."
   end if

   if l_atdetpcod =  3 or
      l_atdetpcod =  4 then

      let l_ret.codigo   = 1
      let l_ret.mensagem = "Mensagem ja enviada ao prestador. Consulte o historico."
      return l_ret.*
   end if


   call cts40g03_data_hora_banco(2)
        returning l_data, l_hora


   #------------------------------------------------
   --> Abre Tela para Editar a Mensagem do Prestador
   #------------------------------------------------

   open window cta15m00a at 12,05 with form "cta15m00a"
        attribute (form line 1, border)

   input by name l_cty20g00.texto1
                ,l_cty20g00.texto2

      before field texto1
         let l_cty20g00.texto1 = l_texto1
	 let l_cty20g00.texto2 = l_texto2

         display by name l_cty20g00.texto2
         display by name l_cty20g00.texto1 attribute (reverse)


      after field texto1
         display by name l_cty20g00.texto1

         if l_cty20g00.texto1 is null or
            l_cty20g00.texto1 =  " "  then
            error " Informe o motivo da visita. "
            next field texto1
         end if


      before field texto2
         display by name l_cty20g00.texto2 attribute (reverse)

      after field texto2
         display by name l_cty20g00.texto2

      on key (interrupt)

         if l_cty20g00.texto1 is null or
            l_cty20g00.texto1 =  " "  then
            error " O motivo da visita deve ser informado. "
            next field texto1
         end if
         exit input
    end input

    let int_flag = false


    #-----------------------------------------------
    --> Alterar a mensagem do Prestador no Historico
    #-----------------------------------------------
    let l_c24txtseq = 0

    begin work
    for l_cont = 1 to 3

       if l_cont = 1 then
          let l_texto     = "Mensagem para Prestador: "
          let l_c24txtseq = l_cty20g00.c24txtseq1
       else
          if l_cont = 2 then
             let l_texto     = l_cty20g00.texto1
             let l_c24txtseq = l_cty20g00.c24txtseq2
          else
             if l_cty20g00.texto2 is null or
                l_cty20g00.texto2 =  " "  then
                let l_cty20g00.texto2 = "."
             end if
             let l_texto     = l_cty20g00.texto2
             let l_c24txtseq = l_cty20g00.c24txtseq3
          end if
       end if

       whenever error continue
       update datmservhist set (c24srvdsc
                               ,c24funmat
                               ,c24empcod
                               ,ligdat
                               ,lighorinc)
                             = (l_texto
                               ,g_issk.funmat
                               ,g_issk.empcod
                               ,l_data
                               ,l_hora )
              where atdsrvnum = param.atdsrvnum
                and atdsrvano = param.atdsrvano
                and c24txtseq = l_c24txtseq
       whenever error stop

       if sqlca.sqlcode <> 0 then
          error " Erro ao atualizar datmservhist-cty20g00. Avise a informatica."
       else
          call cts00g07_apos_grvhist(param.atdsrvnum,
                                     param.atdsrvano,
                                     l_c24txtseq,2)
       end if
    end for
    commit work

    close window cta15m00a

    return l_ret.*

end function
