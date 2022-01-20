#############################################################################
# Nome do Modulo: CTN01N00                                         Marcelo  #
#                                                                  Gilberto #
# Menu de Consulta de Prestadores                                  Abr/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 27/09/2000  PSI 10475-2  Wagner       Mudanca no paramantro de para       #
#                                       receber atdsrvnum e atdsrvano.      #
#---------------------------------------------------------------------------#
# 19/03/2002  PSI 15000-2  Marcus       Consulta de prestadores Porto Socor #
#                                       ro por coordenadas (Mapa)           #
#---------------------------------------------------------------------------#
# 24/08/2005 James, Meta     PSI 192015 Chamar funcao para Locais Condicoes #
#                                       do veiculo (ctc61m02)               #
#############################################################################
# 21/10/2010 Alberto Rodrigues          Correcao de ^M                      #
#---------------------------------------------------------------------------#
database porto

#--------------------------------------------------------------------------
 function ctn01n00(par)
#--------------------------------------------------------------------------
define par         record
  ufdcod           like glakcid.ufdcod,
  cidnom           like glakcid.cidnom,
  brrnom           like glakbrr.brrnom,
  lgdnom           like glaklgd.lgdnom,
  lclltt           like datmlcl.lclltt,
  lcllgt           like datmlcl.lcllgt,
  atdsrvnum        like datmservico.atdsrvnum,
  atdsrvano        like datmservico.atdsrvano
end record

define k_ctn01n00  record
       endcep      like glaklgd.lgdcep,
       endcepcmp   like glaklgd.lgdcepcmp,
       lclltt      like datmlcl.lclltt,
       lcllgt      like datmlcl.lcllgt,
       ufdcod      like glakcid.ufdcod,
       cidnom      like glakcid.cidnom
end    record

define d_ctn01n00  record
       pstcoddig   like dpaksocor.pstcoddig
end    record

define l_tmp_flg   smallint
define l_lixo      char(1)


	initialize  k_ctn01n00.*  to  null

	initialize  d_ctn01n00.*  to  null

   let int_flag = false

   open window w_ctn01n00 at 4,2 with 20 rows,78 columns

   display "---------------------------------------------------------------",
           "-----ctn01n00--" at 3,1

   call ctc61m02(par.atdsrvnum,par.atdsrvano,"A")

   let l_tmp_flg = ctc61m02_criatmp(2,
                                    par.atdsrvnum,
                                    par.atdsrvano)

   if l_tmp_flg = 1 then
      error "Problemas com temporaria ! <Avise a Informatica>."
   end if

   menu "PRESTADORES"

     command key ("M") "Mapa"
                 "Consulta prestadores por MAPA"
          if par.atdsrvnum     is null     then


             if ctx25g05_rota_ativa() then
                call ctx25g05("C",
                              "INFORME O LOGRADOURO PARA PESQUISA DE PRESTADOR",
                              "", "", "", "", "", "",
                              "", "", "", "", "", "")
                    returning l_lixo, l_lixo, l_lixo, l_lixo,
                              l_lixo, l_lixo, l_lixo,
                              k_ctn01n00.lclltt,
                              k_ctn01n00.lcllgt,
                              l_lixo,
                              k_ctn01n00.ufdcod,
                              k_ctn01n00.cidnom
             else
                #com paramentro 1 para consulta prestador
                call ctn46c00(1)
                     returning k_ctn01n00.lclltt,
                               k_ctn01n00.lcllgt,
                               k_ctn01n00.ufdcod,
                               k_ctn01n00.cidnom
             end if

             call ctn06c09(1,
                           "",
                           "",
                           k_ctn01n00.lclltt,
                           k_ctn01n00.lcllgt,
                           k_ctn01n00.ufdcod,
                           k_ctn01n00.cidnom)
                  returning d_ctn01n00.pstcoddig
          else
             call ctn06c09(2,
                           par.atdsrvnum,
                           par.atdsrvano,
                           par.lclltt,
                           par.lcllgt,
                           par.ufdcod,
                           par.cidnom )
                 returning d_ctn01n00.pstcoddig
          end if
          exit menu

     command key ("N") "Nome"
                 "Consulta prestadores por NOME DE GUERRA ou RAZAO SOCIAL"
          call ctn24c00()  returning d_ctn01n00.pstcoddig
          exit menu

     command key ("C") "Cep"
                 "Consulta prestadores por CEP"
          call ctn00c02 (par.ufdcod, par.cidnom, par.brrnom, par.lgdnom)
               returning k_ctn01n00.endcep, k_ctn01n00.endcepcmp

          if k_ctn01n00.endcep is null     then
             error "Nenhum criterio foi selecionado!"
          else
             call ctn06c04(k_ctn01n00.endcep) returning d_ctn01n00.pstcoddig
          end if
          exit menu

     command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
       exit menu

     clear screen
   end menu

   let int_flag = false
   close window w_ctn01n00
   return  d_ctn01n00.pstcoddig

end function  # ctn01n00
