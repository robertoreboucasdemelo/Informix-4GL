###############################################################################
# Nome do Modulo: CTA01M01                                           Marcelo  #
#                                                                    Gilberto #
# Consulta acessorios da apolice                                     Jul/1997 #
###############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------------------
 function cta01m01()
#------------------------------------------------------------------------------

 define a_cta01m01 array[30] of record
    asstip         like abcmaces.asstip,
    asscod         like abcmaces.asscoddig,
    assnom         like agckaces.assnom,
    assimsvlr      like abcmdoc.imsvlr,
    assimstax      like abcmdoc.imstax,
    assfrqvlr      like abcmdoc.frqvlr
 end record

 define arr_aux      smallint,
        l_azlaplcod  integer,
        l_resultado  smallint,
        l_qtd        smallint,
        l_i          smallint,
        l_mensagem   char(80),
        l_aux_char   char(200),
        l_doc_handle integer


 define ws         record
    assnum         like abcmaces.assnum,
    asscoddig      like abcmaces.asscoddig,
    sitseqorg      like abcmdoc.sitseqorg
 end record

 define  w_pf1   integer

 let arr_aux      = null
 let l_azlaplcod  = null
 let l_resultado  = null
 let l_mensagem   = null
 let l_doc_handle = null
 let l_aux_char   = null
 let l_qtd        = 0
 let l_i          = 0

 for     w_pf1  =  1  to  30
         initialize  a_cta01m01[w_pf1].*  to  null
 end     for

 initialize  ws.*  to  null

 let int_flag = false

 initialize ws.* to null
 initialize a_cta01m01 to null

 if g_documento.ciaempcod = 35 then # -> AZUL SEGURADORA
    # -> BUSCA O CODIGO DA APOLICE
    call ctd02g01_azlaplcod(g_documento.succod,
                            g_documento.ramcod,
                            g_documento.aplnumdig,
                            g_documento.itmnumdig,
                            g_documento.edsnumref)

         returning l_resultado,
                   l_mensagem,
                   l_azlaplcod

    if l_resultado <> 1 then
       error l_mensagem
       sleep 4
       return
    end if

    if l_azlaplcod is not null then
       # -> BUSCA OS DADOS DO XML DA APOLICE
       let l_doc_handle = ctd02g00_agrupaXML(l_azlaplcod)

       # -> BUSCA A QUANTIDADE TOTAL DE ACESSORIOS
       let l_qtd = figrc011_xpath(l_doc_handle,
           "count(/APOLICE/VEICULO/ACESSORIOS)")

       display "Quantidade de acessorios: ", l_qtd

       for l_i = 1 to l_qtd

          if l_i > 30 then
             error "Limite do array superado! cta01m01.4gl" sleep 3
             exit for
          end if

          # -> CODIGO DO ACESSORIO
          let l_aux_char = '/APOLICE/VEICULO/ACESSORIOS[',
                           l_i using "<<<<&", ']/CODIGO'
          let a_cta01m01[l_i].asstip = figrc011_xpath(l_doc_handle,
                                                      l_aux_char)

          if a_cta01m01[l_i].asstip is null or
             a_cta01m01[l_i].asstip = " " then
             let l_qtd = 0
             exit for
          end if

          # -> DESCRICAO DO ACESSORIO
          let l_aux_char = '/APOLICE/VEICULO/ACESSORIOS[',
                           l_i using "<<<<&", ']/DESCRICAO'
          let a_cta01m01[l_i].assnom = figrc011_xpath(l_doc_handle,
                                                      l_aux_char)
          # -> VALOR DO IS
          let l_aux_char = '/APOLICE/VEICULO/ACESSORIOS[',
                           l_i using "<<<<&", ']/IS'
          let a_cta01m01[l_i].assimsvlr = figrc011_xpath(l_doc_handle,
                                                         l_aux_char)
          # -> VALOR TAXA
          let l_aux_char = '/APOLICE/VEICULO/ACESSORIOS[',
                           l_i using "<<<<&", ']/TAXA'
          let a_cta01m01[l_i].assimstax = figrc011_xpath(l_doc_handle,
                                                         l_aux_char)
          # -> VALOR FRANQUIA
          let l_aux_char = '/APOLICE/VEICULO/ACESSORIOS[',
                           l_i using "<<<<&", ']/FRANQUIA'
          let a_cta01m01[l_i].assfrqvlr = figrc011_xpath(l_doc_handle,
                                                         l_aux_char)
       end for

       # -> RECEBE O TAMANHO DO ARRAY
       let arr_aux = l_qtd

    else
       error "AZLAPLCOD esta nulo! cta01m01.4gl" sleep 4
    end if

 else
    declare c_abcmaces cursor for
       select asstip, assnum, asscoddig
         from abcmaces
        where succod    = g_documento.succod     and
              aplnumdig = g_documento.aplnumdig  and
              itmnumdig = g_documento.itmnumdig

    let arr_aux = 1

    foreach c_abcmaces into a_cta01m01[arr_aux].asstip,
                            ws.assnum, ws.asscoddig

       select sitseqorg into ws.sitseqorg
         from abcmdoc
        where succod    = g_documento.succod     and
              aplnumdig = g_documento.aplnumdig  and
              itmnumdig = g_documento.itmnumdig  and
              assnum    = ws.assnum              and
              assstt   <> "C"                    and
              dctnumseq = (select max(dctnumseq)
                             from abcmdoc
                            where succod     =  g_documento.succod     and
                                  aplnumdig  =  g_documento.aplnumdig  and
                                  itmnumdig  =  g_documento.itmnumdig  and
                                  assnum     =  ws.assnum              and
                                  dctnumseq <=  g_funapol.dctnumseq )

       if sqlca.sqlcode <> notfound then
          select imsvlr, imstax, frqvlr
            into a_cta01m01[arr_aux].assimsvlr,
                 a_cta01m01[arr_aux].assimstax,
                 a_cta01m01[arr_aux].assfrqvlr
            from abcmdoc
           where succod    = g_documento.succod     and
                 aplnumdig = g_documento.aplnumdig  and
                 itmnumdig = g_documento.itmnumdig  and
                 assnum    = ws.assnum              and
                 dctnumseq = ws.sitseqorg

          if sqlca.sqlcode = notfound  then
             continue foreach
          else
             select assnom
               into a_cta01m01[arr_aux].assnom
               from agckaces
              where asstip    = a_cta01m01[arr_aux].asstip  and
                    asscoddig = ws.asscoddig

             let arr_aux = arr_aux + 1
          end if
       end if
    end foreach

    let arr_aux = arr_aux - 1

 end if

 if arr_aux > 0  then
    open window w_cta01m01 at 07,02 with form "cta01m01"
       attributes(form line first)

    message " (F17)Abandona "
    call set_count(arr_aux)

    display array a_cta01m01 to s_cta01m01.*
       on key (interrupt)
          exit display
    end display

    close window w_cta01m01
    let int_flag = false
 else
    error " Documento nao tem cobertura de acessorios!"
 end if

end function
