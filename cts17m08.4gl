#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema        : Central 24 horas                                            #
# Modulo         : cts17m08                                                    #
#                  Consultar Laudos Multiplos.                                 #
# Analista Resp. : Ligia Mattge                                                #
# PSI            : 189790                                                      #
#..............................................................................#
# Desenvolvimento: META, Marcos M.P.                                           #
# Data           : 08/04/2005                                                  #
#..............................................................................#
#                                                                              #
#                          * * *  ALTERACOES  * * *                            #
#                                                                              #
# Data       Autor Fabrica     Origem     Alteracao                            #
# ---------- ----------------- ---------- -------------------------------------#
# 06/06/2005 James, Meta       PSI 189790 Refazer a tela, obtendo os servicos  #
#                                         multiplos novamente.                 #
#------------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"


#=> FUNCAO PRINCIPAL DO MODULO - CONSULTA LAUDOS MULTIPLOS
#-------------------------------------------------------------------------------
function cts17m08_consultar_multiplos (lr_param)
#-------------------------------------------------------------------------------
   define lr_param          record
          atdsrvnum         like datmservico.atdsrvnum,
          atdsrvano         like datmservico.atdsrvano,
          acao              char(03)
   end record
   define lr_retorno        record
          stt               smallint,
          msg               char(100)
   end record
   define la_ret29g00 array[10] of record
          atdmltsrvnum      like datratdmltsrv.atdmltsrvnum,
          atdmltsrvano      like datratdmltsrv.atdmltsrvano,
          socntzdes         like datksocntz.socntzdes,
          espdes            like dbskesp.espdes,
          atddfttxt         like datmservico.atddfttxt
   end record
   define lr_ret10g06       record
          atdsrvorg         like datmservico.atdsrvorg,
          atddat            like datmservico.atddat
   end record
   define lr_ret20g00       record
          c24astcod         like datmligacao.c24astcod
   end record
   define la_tela array[10] of record
          servico           char(13),
          socntzdes         like datksocntz.socntzdes,
          espdes            like dbskesp.espdes,
          atddfttxt         like datmservico.atddfttxt,
          c24astcod         like datmligacao.c24astcod
   end record
   define l_i               smallint,
          l_i1              smallint,
          l_aux             char(50),
          l_continua        smallint,
          l_janela          smallint

#=> INICIALIZA VARIAVEIS LOCAIS
   let lr_retorno.stt       = 0
   let lr_retorno.msg       = " "
   initialize la_ret29g00,
              lr_ret10g06.*,
              lr_ret20g00.*,
              la_tela       to null

   let l_i                  = 0
   let l_i1                 = 0
   let l_continua           = true
   let l_janela             = false

   while l_continua

      #=> OBTEM OS SERVICOS MULTIPLOS
      if lr_param.acao ="RAD" then
         let l_i1 = 2
      else
         let l_i1 = 1
      end if

      call cts29g00_obter_multiplo  (l_i1,
                                     lr_param.atdsrvnum,
                                     lr_param.atdsrvano)
           returning lr_retorno.*,
                     la_ret29g00[1].*,
                     la_ret29g00[2].*,
                     la_ret29g00[3].*,
                     la_ret29g00[4].*,
                     la_ret29g00[5].*,
                     la_ret29g00[6].*,
                     la_ret29g00[7].*,
                     la_ret29g00[8].*,
                     la_ret29g00[9].*,
                     la_ret29g00[10].*

      if lr_retorno.stt = 3 then
         error lr_retorno.msg
         exit while
      end if
      #=> LOOPING DOS 'SERVICOS'
      let l_i = 0
      for l_i1 = 1 to 10
         if la_ret29g00[l_i1].atdmltsrvnum is null then
            continue for
         end if
         #=>   OBTER A ORIGEM DO SERVICO
         call cts10g06_dados_servicos (1,
                                       la_ret29g00[l_i1].atdmltsrvnum,
                                       la_ret29g00[l_i1].atdmltsrvano)
              returning lr_retorno.*,
                        lr_ret10g06.*
         if lr_retorno.stt = 3 then
            exit for
         end if
         #=>   VERIFICA A EXISTENCIA DE UMA LIGACAO DE COMPLEMENTO NO SERVICO
         call cts20g00_lig_compl (la_ret29g00[l_i1].atdmltsrvnum,
                                  la_ret29g00[l_i1].atdmltsrvano)
              returning lr_retorno.*,
                        lr_ret20g00.c24astcod
         if lr_retorno.stt = 3 then
            exit for
         end if
         #=>   MONTA ARRAY A SER EXIBIDO NA TELA
         let l_i = l_i + 1
         let la_tela[l_i].servico   =
                          lr_ret10g06.atdsrvorg using "&&", "/",
                          la_ret29g00[l_i1].atdmltsrvnum using "&&&&&&&", "-",
                          la_ret29g00[l_i1].atdmltsrvano using "&&"
         let la_tela[l_i].socntzdes = la_ret29g00[l_i1].socntzdes
         let la_tela[l_i].espdes    = la_ret29g00[l_i1].espdes
         let la_tela[l_i].atddfttxt = la_ret29g00[l_i1].atddfttxt
         let la_tela[l_i].c24astcod = lr_ret20g00.c24astcod
      end for
      if lr_retorno.stt = 3 then
         error lr_retorno.msg
         exit while
      end if
      if l_i = 0 then
         exit while
      end if
      if l_janela = false then
         #=> ABRE JANELA
         open window w_cts17m08 at 4,2 with form "cts17m08"
         let l_janela = true
      end if

      #if lr_param.acao = "CON" or lr_param.acao = "RAD" then  #ligia
         let l_aux = "(F8) Laudo"
      #else
      #   let l_aux = null
      #end if
      display l_aux to opcoes
      #=> EXIBE ARRAY
      call set_count(l_i)
      display array la_tela to s_cts17m08.*
         on key (f8)
            #if lr_param.acao = "CON" or lr_param.acao = "RAD" then  #ligia
               let l_i = arr_curr()
               let g_documento.atdsrvnum = la_tela[l_i].servico[4,10]
               let g_documento.atdsrvano = la_tela[l_i].servico[12,13]

               let g_documento.acao = 'CON'
	       if lr_param.acao = "RAD" then
                  let g_documento.acao = 'ALT'
               end if

               call cts17m00()

               let g_documento.atdsrvnum = lr_param.atdsrvnum
               let g_documento.atdsrvano = lr_param.atdsrvano

               let g_documento.acao = lr_param.acao
               exit display
            #end if

         on key (accept, interrupt, f17)
            let l_continua = false
            let int_flag = false
            exit display
      end display
   end while

   #=> FECHA JANELA
   if l_janela then
      close window w_cts17m08
   end if

end function
