#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24HS                                               #
# Modulo.........: cts00m37                                                   #
# Analista Resp..: Ligia Mattge                                               #
# PSI/OSF........: 190.489                                                    #
#                  Modulo responsavel pela escolha do filtro utilizado na tela#
#                  do Radio.                                                  #
# ........................................................................... #
# Desenvolvimento: Meta, Lucas Scheid                                         #
# Liberacao......: 27/01/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 07/11/200  Ligia Mattge    PSI 195138 Filtrar por Cidade e flag dos nao     #
#                                       acionados                             #
#-----------------------------------------------------------------------------#
# 13/04/06   Priscila        Psi 198714 Filtrar por cidade e flag dos nao     #
#                                       acionados para tipos de assistencia   #
#-----------------------------------------------------------------------------#


database porto

#-----------------------------------#
function cts00m37_filtro(l_pesq_tip)
#-----------------------------------#

  define l_mensagem      char(80),
         l_descricao     char(30),
         l_uf_nom        char(30),
         l_pesq_tip      char(03),
         l_resultado     smallint,
         l_cidcod        like glakcid.cidcod

  define lr_retorno      record
         filtro_cod      smallint,
         uf_cod          char(02),
         filtro_resumo   char(01),
         cidnom          like glakcid.cidnom,
         flag            smallint
  end record

  initialize lr_retorno.* to null

  let lr_retorno.filtro_resumo = 'N'
  let l_resultado              = null
  let l_mensagem               = null
  let l_descricao              = null
  let l_uf_nom                 = null
  let l_cidcod                 = null

  open window w_cts00m37 at 8,30 with form 'cts00m37'
     attribute(border, form line 1)

  if l_pesq_tip = 'tpa' then
      display 'Filtro por Tipo de Assistencia' to titulo
      display 'Tp.Assistencia: ' to campo
      display 'Cidade:' to ncid         ##PSI198714
  else
      display 'Filtro por Grupo Natureza' to titulo
      display 'Grupo:' to campo
      display 'Cidade:' to ncid
  end if

  input lr_retorno.filtro_cod, lr_retorno.uf_cod, lr_retorno.cidnom, lr_retorno.flag without defaults from filtro_cod, uf_cod, cidnom, flag

     before field filtro_cod
        display by name lr_retorno.filtro_cod attribute(reverse)

     after field filtro_cod
        display by name lr_retorno.filtro_cod

        if lr_retorno.filtro_cod is null then
           if l_pesq_tip = 'tpa' then
              let lr_retorno.filtro_cod = ctn25c00(0)
           else
              call ctx24g00_popup_grupo()
                   returning l_resultado, lr_retorno.filtro_cod
           end if
        end if

        if lr_retorno.filtro_cod is null then
           next field uf_cod
        end if

        if l_pesq_tip = 'tpa' then
           call ctn25c00_descricao(lr_retorno.filtro_cod)
                returning l_resultado, l_mensagem, l_descricao
        else
           call ctx24g00_descricao(lr_retorno.filtro_cod)
                returning l_resultado, l_mensagem, l_descricao
        end if

        if l_resultado <> 1 then
           error l_mensagem
           next field filtro_cod
        end if

        display by name lr_retorno.filtro_cod
        display l_descricao to descricao

     before field uf_cod

        display by name lr_retorno.uf_cod attribute(reverse)

     after field uf_cod

        display by name lr_retorno.uf_cod

        if lr_retorno.uf_cod is not null then
           call cty12g00_ufdcod(lr_retorno.uf_cod)
                returning l_resultado, l_mensagem, l_uf_nom
             if l_resultado <> 1 then
                error l_mensagem
                next field uf_cod
             end if
        end if
     before field cidnom
        #if l_pesq_tip = 'tpa' then
        #   exit input
        #end if

        display by name lr_retorno.cidnom attribute(reverse)

     after field cidnom
        display by name lr_retorno.cidnom

        if lr_retorno.cidnom is not null then
           call cty10g00_obter_cidcod (lr_retorno.cidnom, lr_retorno.uf_cod)
                returning l_resultado, l_mensagem, l_cidcod

           ## se nao achou a cidade informada
           if l_resultado <> 0 then
              call cts06g04(lr_retorno.cidnom, lr_retorno.uf_cod)
                    returning l_cidcod, lr_retorno.cidnom, lr_retorno.uf_cod
              next field uf_cod
           end if
        end if

     on key(F5)
        message 'Aguarde, pesquisando ...' attribute (reverse)
        call cts00m38_resumo(l_pesq_tip)
             returning lr_retorno.filtro_cod, lr_retorno.uf_cod

        if lr_retorno.filtro_cod is null then
           next field filtro_cod
        end if

        let lr_retorno.filtro_resumo = 'S'
        let lr_retorno.flag = 3 #psi 195138

        exit input

     on key(f17, control-c, interrupt)
        exit input

  end input

  close window w_cts00m37

  return lr_retorno.*

end function
