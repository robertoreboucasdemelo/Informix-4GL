#############################################################################
# Nome do Modulo: CTS38M00                                    Sergio Burini #
#                                                                           #
# Validações para Localização da Apolice - Azul Seguros.           Nov/2006 #
#############################################################################
# Alteracoes:                                                               #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 15/11/2006  psi 205206   SERGIO       Informacoes de Apol. Azul Seguros.  #
#---------------------------------------------------------------------------#
# 05/01/2010  Amilton                   Projeto sucursal smallint           #
#---------------------------------------------------------------------------#
# 19/03/2013               ISSAMU       Controle na chamada do prepare      #
#---------------------------------------------------------------------------#

database porto

 define mr_cts3800 record
       resultado       smallint,
       azlaplcod       integer,
       mensagem        char(50),
       xml             char(32000),
       doc_handle       integer
 end record
 define m_prepare smallint

#---------------------------#
 function cts38m00_prepare()
#---------------------------#

     define l_sql        char(2000)

     let l_sql = " SELECT a.azlaplcod     ",
                 "   FROM datkazlapl a    ",
                 "  WHERE a.succod = ?    ",
                 "    AND a.aplnumdig = ? ",
                 "    AND a.itmnumdig = ? ",
                 "    AND a.ramcod = ?    ",
                 "    AND a.edsnumdig IN (SELECT max(edsnumdig)            ",
                 "                          FROM datkazlapl b              ",
                 "                         WHERE a.succod    = b.succod    ",
                 "                           AND a.aplnumdig = b.aplnumdig ",
                 "                           AND a.itmnumdig = b.itmnumdig ",
                 "                           AND a.ramcod    = b.ramcod)   "

     prepare p_cts38m00_001 from l_sql
     declare c_cts38m00_001 cursor for p_cts38m00_001

     let l_sql = " SELECT a.azlaplcod ",
                   " FROM datkazlapl a" ,
                  " WHERE a.vcllicnum = ? ",
                   "  AND a.edsnumdig IN (SELECT max(edsnumdig) ",
                                          " FROM datkazlapl b ",
                                         " WHERE a.succod    = b.succod ",
                                           " AND a.aplnumdig = b.aplnumdig ",
                                           " AND a.itmnumdig = b.itmnumdig ",
                                           " AND a.ramcod    = b.ramcod) "

     prepare p_cts38m00_002 from l_sql
     declare c_cts38m00_002 cursor for p_cts38m00_002

     let l_sql = " SELECT a.azlaplcod ",
                   " FROM datkazlapl a",
                  " WHERE a.cgccpfnum = ? ",
                    " AND a.cgccpfdig = ? ",
                   "  AND a.edsnumdig IN (SELECT max(edsnumdig) ",
                                          " FROM datkazlapl b ",
                                         " WHERE a.succod    = b.succod ",
                                           " AND a.aplnumdig = b.aplnumdig ",
                                           " AND a.itmnumdig = b.itmnumdig ",
                                           " AND a.ramcod    = b.ramcod) "

     prepare p_cts38m00_003 from l_sql
     declare c_cts38m00_003 cursor for p_cts38m00_003

     let l_sql = " SELECT a.azlaplcod ",
                   " FROM datkazlapl a",
                  " WHERE a.cgccpfnum = ? ",
                    " AND a.cgcord    = ? ",
                    " AND a.cgccpfdig = ? ",
                   "  AND a.edsnumdig IN (SELECT max(edsnumdig) ",
                                          " FROM datkazlapl b ",
                                         " WHERE a.succod    = b.succod ",
                                           " AND a.aplnumdig = b.aplnumdig ",
                                           " AND a.itmnumdig = b.itmnumdig ",
                                           " AND a.ramcod    = b.ramcod) "

     prepare p_cts38m00_004 from l_sql
     declare c_cts38m00_004 cursor for p_cts38m00_004

     let l_sql = " SELECT a.azlaplcod ",
                   " FROM datkazlapl a",
                  " WHERE a.vclchsfnl = ? ",
                   "  AND a.edsnumdig IN (SELECT max(edsnumdig) ",
                                          " FROM datkazlapl b ",
                                         " WHERE a.succod    = b.succod ",
                                           " AND a.aplnumdig = b.aplnumdig ",
                                           " AND a.itmnumdig = b.itmnumdig ",
                                           " AND a.ramcod    = b.ramcod) "

     prepare p_cts38m00_005 from l_sql
     declare c_cts38m00_005 cursor for p_cts38m00_005

     let l_sql = " SELECT azlaplcod ",
                   " FROM datkazlapl ",
                  " WHERE prporg = ? ",
                    " AND prpnumdig = ? "

     prepare p_cts38m00_006 from l_sql
     declare c_cts38m00_006 cursor for p_cts38m00_006

     let l_sql = " SELECT a.azlaplcod      ",
                 "   FROM datkazlapl a     ",
                 "  WHERE a.succod = ?     ",
                 "    AND a.aplnumdig = ?  ",
                 "    AND a.edsnumdig IN (SELECT max(edsnumdig)            ",
                 "                          FROM datkazlapl b              ",
                 "                         WHERE a.succod    = b.succod    ",
                 "                           AND a.aplnumdig = b.aplnumdig ",
                 "                           AND a.itmnumdig = b.itmnumdig ",
                 "                           AND a.ramcod    = b.ramcod) "

     prepare p_cts38m00_007 from l_sql
     declare c_cts38m00_007 cursor for p_cts38m00_007

     let l_sql = " SELECT count(*) FROM datkazlapl ",
                 " WHERE segnom like ? "

     prepare p_cts38m00_008 from l_sql
     declare c_cts38m00_008 cursor for p_cts38m00_008

     let l_sql = " SELECT count(*) FROM datkazlapl ",
                  " WHERE cgccpfnum = ? ",
                    " AND cgccpfdig = ? "

     prepare p_cts38m00_009 from l_sql
     declare c_cts38m00_009 cursor for p_cts38m00_009

     let l_sql = "SELECT succod, aplnumdig, itmnumdig, ramcod "
                ,"FROM datmazlsinnumligrl A           "
                ,"INNER JOIN datmligacao B            "
                ,"  ON A.lignum = B.lignum            "
                ,"INNER JOIN datrligapol C            "
                ,"   ON B.lignum = C.lignum           "
                ,"WHERE A.azlsinnum = ?               "
                ,"  AND B.ciaempcod = 35              "
     prepare p_cts38m00_010 from l_sql
     declare c_cts38m00_010 cursor for p_cts38m00_010
 let m_prepare = true
 end function

################################################################################
# Validação para existencia de registro na base Azul filtrado por Apolice      #
#----------------------------------------------------------------------------- #
# Paramêtros de Entrada: - Codigo da Sucursal                                  #
#                        - Numero da Apolice                                   #
#       .                                                                      #
# Paramêtros de Saida:   - Codigo do Retorno da Busca                          #
#                        - Mensagem de adventencia                             #
################################################################################
#---------------------------------------#
 function cts38m00_dados_apolice(lr_par)
#---------------------------------------#

     define lr_par    record
            succod    smallint, #decimal(2,0), projeto succod
            aplnumdig decimal(9,0),
            itmnumdig like datrligapol.itmnumdig,
            ramcod    smallint
     end record

     define lr_cta38m00 record
            documento   char(30),
            itmnumdig   decimal(7,0),
            edsnumref   decimal(9,0),
            succod      smallint, #decimal(2,0), projeto succod
            ramcod      smallint,
            emsdat      date,
            viginc      date,
            vigfnl      date,
            segcod      integer,
            segnom      char(50),
            vcldes      char(25),
            corsus      char(06),
            situacao    char(10)
     end record

     define l_doc_handle integer

     initialize mr_cts3800.* to null
     initialize lr_cta38m00.* to null
     let l_doc_handle = null

     if not m_prepare then
        call cts38m00_prepare()
     end if

     if  lr_par.succod is not null and
         lr_par.aplnumdig is not null then

         open c_cts38m00_001 using lr_par.*

         whenever error continue
         fetch c_cts38m00_001 into  mr_cts3800.azlaplcod
         whenever error stop

         if  sqlca.sqlcode = 0 then

             let mr_cts3800.doc_handle=ctd02g00_agrupaXML(mr_cts3800.azlaplcod)

             call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                  returning lr_cta38m00.documento,
                            lr_cta38m00.itmnumdig,
                            lr_cta38m00.edsnumref,
                            lr_cta38m00.succod,
                            lr_cta38m00.ramcod,
                            lr_cta38m00.emsdat,
                            lr_cta38m00.viginc,
                            lr_cta38m00.vigfnl,
                            lr_cta38m00.segcod,
                            lr_cta38m00.segnom,
                            lr_cta38m00.vcldes,
                            lr_cta38m00.corsus,
                            lr_cta38m00.situacao

             let mr_cts3800.resultado = 1
             let mr_cts3800.mensagem  = 'Apolice encontrada.(apol.)'

         else
             if  sqlca.sqlcode = notfound then
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem  = "Apolice nao encontrada!(apol)"
             else
                 let mr_cts3800.resultado = sqlca.sqlcode
                 let mr_cts3800.mensagem  = 'Problema encontrado: Erro: ', sqlca.sqlcode
             end if
         end if
     else
         let mr_cts3800.resultado = 3
         let mr_cts3800.mensagem  = "Parametros nulos"
     end if

     return lr_cta38m00.documento,
            lr_cta38m00.itmnumdig,
            lr_cta38m00.edsnumref,
            lr_cta38m00.succod,
            lr_cta38m00.ramcod,
            lr_cta38m00.emsdat,
            lr_cta38m00.viginc,
            lr_cta38m00.vigfnl,
            lr_cta38m00.segcod,
            lr_cta38m00.segnom,
            lr_cta38m00.vcldes,
            lr_cta38m00.corsus,
            mr_cts3800.doc_handle,
            mr_cts3800.resultado,
            mr_cts3800.mensagem,
            lr_cta38m00.situacao

 end function

################################################################################
# Validação para existencia de registro na base Azul filtrado por Sinistro     #
#------------------------------------------------------------------------------#
# Paramêtros de Entrada: - Numero do Sinistro Azul                             #
#                                                                              #
# Paramêtros de Saida:   - Apolice                                             #
#                        - Codigo do Item da Apolice                           #
#                        - Codigo da Sucursal da Apolice                       #
#                        - Codigo do Ramo da Apolice                           #
#                        - Data de Emissão da Apolice                          #
#                        - Vigencia Inicial da Apolice                         #
#                        - Vigencia Final da Apolice                           #
#                        - Codido do Segurado                                  #
#                        - Nome do Segurado                                    #
#                        - Descrição do Veiculo                                #
#                        - SUSEP do Corretor                                   #
#                        - Codigo do Resultado da Busca                        #
################################################################################
#---------------------------------------#
function cts38m00_dados_sinistro(l_azlsinnum)
#---------------------------------------#
   define l_azlsinnum like datmazlsinnumligrl.azlsinnum
 define lr_chave record
        succod    smallint,
        aplnumdig decimal(9,0),
        itmnumdig like datrligapol.itmnumdig,
        ramcod    smallint
 end record
   define lr_cta38m00 record
      documento char(30),
      itmnumdig decimal(7,0),
      edsnumref decimal(9,0),
      succod    smallint,
      ramcod    smallint,
      emsdat    date,
      viginc    date,
      vigfnl    date,
      segcod    integer,
      segnom    char(50),
      vcldes    char(25),
      corsus    char(06),
      situacao  char(10)
   end record
   define l_doc_handle integer
   initialize mr_cts3800.* to null
   initialize lr_cta38m00.* to null
   initialize lr_chave.* to null
   let l_doc_handle = null
   if not m_prepare then
      call cts38m00_prepare()
   end if
   if l_azlsinnum is not null then
      open c_cts38m00_010 using l_azlsinnum
      whenever error continue
      fetch c_cts38m00_010 into lr_chave.succod
                               ,lr_chave.aplnumdig
                               ,lr_chave.itmnumdig
                               ,lr_chave.ramcod
      whenever error stop
      if sqlca.sqlcode = 0 then
         open c_cts38m00_001 using lr_chave.succod
                                  ,lr_chave.aplnumdig
                                  ,lr_chave.itmnumdig
                                  ,lr_chave.ramcod
         whenever error continue
         fetch c_cts38m00_001 into  mr_cts3800.azlaplcod
         whenever error stop
         if sqlca.sqlcode = 0 then
             let mr_cts3800.doc_handle=ctd02g00_agrupaXML(mr_cts3800.azlaplcod)
             call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                  returning lr_cta38m00.documento,
                            lr_cta38m00.itmnumdig,
                            lr_cta38m00.edsnumref,
                            lr_cta38m00.succod,
                            lr_cta38m00.ramcod,
                            lr_cta38m00.emsdat,
                            lr_cta38m00.viginc,
                            lr_cta38m00.vigfnl,
                            lr_cta38m00.segcod,
                            lr_cta38m00.segnom,
                            lr_cta38m00.vcldes,
                            lr_cta38m00.corsus,
                            lr_cta38m00.situacao
             let mr_cts3800.resultado = 1
             let mr_cts3800.mensagem  = 'Apolice encontrada.(sin0)'
         else
             if  sqlca.sqlcode = notfound then
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem  = "Apolice nao encontrada!(sin1)"
             else
                 let mr_cts3800.resultado = sqlca.sqlcode
                 let mr_cts3800.mensagem  = 'Problema encontrado: Erro: ', sqlca.sqlcode
             end if
         end if
      else
          if  sqlca.sqlcode = notfound then
              let mr_cts3800.resultado = 2
              let mr_cts3800.mensagem  = "Sinistro Azul nao encontrado!(sin2)"
          else
              let mr_cts3800.resultado = sqlca.sqlcode
              let mr_cts3800.mensagem  = 'Problema encontrado: Erro: ', sqlca.sqlcode
          end if
      end if
   else
       let mr_cts3800.resultado = 3
       let mr_cts3800.mensagem  = "Parametros nulos"
   end if
   return lr_cta38m00.documento,
          lr_cta38m00.itmnumdig,
          lr_cta38m00.edsnumref,
          lr_cta38m00.succod,
          lr_cta38m00.ramcod,
          lr_cta38m00.emsdat,
          lr_cta38m00.viginc,
          lr_cta38m00.vigfnl,
          lr_cta38m00.segcod,
          lr_cta38m00.segnom,
          lr_cta38m00.vcldes,
          lr_cta38m00.corsus,
          mr_cts3800.doc_handle,
          mr_cts3800.resultado,
          mr_cts3800.mensagem,
          lr_cta38m00.situacao
 end function
################################################################################
# Validação para existencia de registro na base Azul filtrado por Segurado     #
#------------------------------------------------------------------------------#
# Paramêtros de Entrada: - Codigo da Sucursal                                  #
#                        - Dez primeiros ou mais caracteres do nome do Segurado#
#       .                                                                      #
# Paramêtros de Saida:   - Apolice                                             #
#                        - Codigo do Item da Apolice                           #
#                        - Codigo da Sucursal da Apolice                       #
#                        - Codigo do Ramo da Apolice                           #
#                        - Data de Emissão da Apolice                          #
#                        - Vigencia Inicial da Apolice                         #
#                        - Vigencia Final da Apolice                           #
#                        - Codido do Segurado                                  #
#                        - Nome do Segurado                                    #
#                        - Descrição do Veiculo                                #
#                        - SUSEP do Corretor                                   #
#                        - Codigo do Resultado da Busca,                       #
################################################################################
#----------------------------------------#
 function cts38m00_dados_segurador(lr_par)
#----------------------------------------#

     define l_ind        smallint,
            l_arr_aux    smallint,
            l_segnom     char(40),
            l_doc_handle integer,
            l_contados   integer,
            l_sql        char(3000),
            l_command    char(1000)

     define lr_par     record
                           segnom    char(50)
                       end record

     define la_seg array[500] of record
                                    lixo      char(01),
                                    documento char(30),
                                    emsdat    date,
                                    viginc    date,
                                    vigfnl    date,
                                    segcod    integer,
                                    segnom    char(50),
                                    vcldes    char(25),
                                    corsus    char(06)
                                 end record

     define la_aux array[500] of record
                                      itmnumdig  decimal(7,0),
                                      edsnumref  decimal(9,0),
                                      succod     smallint, #decimal(2,0), projeto succod
                                      ramcod     smallint,
                                      doc_handle integer,
                                      situacao   char(10)
                                 end record

     define la_doc array[500] of record
                                     documento char(30)
                                 end record

     define lr_cta38m00 record
                            documento char(30),
                            itmnumdig decimal(7,0),
                            edsnumref decimal(9,0),
                            succod    smallint,#decimal(2,0), projeto succod
                            ramcod    smallint,
                            emsdat    date,
                            viginc    date,
                            vigfnl    date,
                            segcod    integer,
                            segnom    char(50),
                            vcldes    char(25),
                            corsus    char(06),
                            situacao  char(10)
                        end record

     initialize mr_cts3800.* to null
     initialize lr_cta38m00.* to null

     initialize la_doc  to null
     initialize la_seg  to null
     initialize la_aux  to null

     let l_contados = 0
     let mr_cts3800.resultado = 0

     if not m_prepare then
        call cts38m00_prepare()
     end if

     if  lr_par.segnom is not null then

         let lr_par.segnom = lr_par.segnom clipped, "%"
         open c_cts38m00_008 using lr_par.segnom
         fetch c_cts38m00_008 into l_contados
         close c_cts38m00_008

         if l_contados > 150 then
            call cts08g01 ("A","N",
                           "Mais de 150 registros selecionados.",
                           "Complemente o nome do segurado ou",
                           "pesquise de outra forma.", "")
                 returning mr_cts3800.mensagem

            return lr_cta38m00.documento,
                   lr_cta38m00.itmnumdig,
                   lr_cta38m00.edsnumref,
                   lr_cta38m00.succod,
                   lr_cta38m00.ramcod,
                   lr_cta38m00.emsdat,
                   lr_cta38m00.viginc,
                   lr_cta38m00.vigfnl,
                   lr_cta38m00.segcod,
                   lr_cta38m00.segnom,
                   lr_cta38m00.vcldes,
                   lr_cta38m00.corsus,
                   mr_cts3800.doc_handle,
                   mr_cts3800.resultado,
                   mr_cts3800.mensagem,
                   lr_cta38m00.situacao
         end if

         let l_sql = " SELECT a.segnom, a.azlaplcod ",
                       " FROM datkazlapl a",
                      " WHERE a.segnom like '", lr_par.segnom clipped,"%'",
                       "  AND a.edsnumdig IN (SELECT max(b.edsnumdig) ",
                                             "  FROM datkazlapl b ",
                                             " WHERE a.succod    = b.succod ",
                                             "  AND a.aplnumdig = b.aplnumdig ",
                                             "  AND a.itmnumdig = b.itmnumdig ",
                                             "  AND a.ramcod    = b.ramcod) "

         prepare pcts38m00_02 from l_sql
         declare ccts38m00_02 cursor for pcts38m00_02

         let l_ind = 1

         foreach ccts38m00_02 into l_segnom, mr_cts3800.azlaplcod

             let mr_cts3800.doc_handle =ctd02g00_agrupaXML(mr_cts3800.azlaplcod)

             call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                  returning lr_cta38m00.documento,
                            lr_cta38m00.itmnumdig,
                            lr_cta38m00.edsnumref,
                            lr_cta38m00.succod,
                            lr_cta38m00.ramcod,
                            lr_cta38m00.emsdat,
                            lr_cta38m00.viginc,
                            lr_cta38m00.vigfnl,
                            lr_cta38m00.segcod,
                            lr_cta38m00.segnom,
                            lr_cta38m00.vcldes,
                            lr_cta38m00.corsus,
                            lr_cta38m00.situacao

             let la_seg[l_ind].lixo         = null
             let la_doc[l_ind].documento    = lr_cta38m00.documento
             let la_seg[l_ind].documento    = lr_cta38m00.succod clipped, '.',
                                              lr_cta38m00.documento clipped,
                                              ' Item: ' clipped,
                                            lr_cta38m00.itmnumdig
             let la_aux[l_ind].succod     = lr_cta38m00.succod
             let la_aux[l_ind].edsnumref  = lr_cta38m00.edsnumref
             let la_seg[l_ind].emsdat     = lr_cta38m00.emsdat
             let la_seg[l_ind].viginc     = lr_cta38m00.viginc
             let la_seg[l_ind].vigfnl     = lr_cta38m00.vigfnl
             let la_seg[l_ind].segcod     = lr_cta38m00.segcod
             let la_seg[l_ind].segnom     = lr_cta38m00.segnom
             let la_seg[l_ind].vcldes     = lr_cta38m00.vcldes
             let la_seg[l_ind].corsus     = lr_cta38m00.corsus
             let la_aux[l_ind].ramcod     = lr_cta38m00.ramcod
             let la_aux[l_ind].doc_handle = mr_cts3800.doc_handle
             let la_aux[l_ind].itmnumdig  = lr_cta38m00.itmnumdig
             let la_aux[l_ind].situacao   = lr_cta38m00.situacao

             let l_ind = l_ind + 1

             if l_ind > 150 then
                exit foreach
             end if

         end foreach

         let l_ind = l_ind - 1

         if  sqlca.sqlcode = 0 then
             let int_flag = false

             if  l_ind > 1 then

                 open window cta00m11 at 4,2 with form "cta00m11"
                             attribute(form line first)

                 call set_count(l_ind)

                 message " (F17)Abandona, (F8)Seleciona"

                 display array la_seg to s_cta00m11.*
                     on key (interrupt)
                         let int_flag = true
                         exit display

                      on key (F8)
                         let l_arr_aux  = arr_curr()

                         let lr_cta38m00.documento = la_doc[l_arr_aux].documento
                         let lr_cta38m00.itmnumdig = la_aux[l_arr_aux].itmnumdig
                         let lr_cta38m00.edsnumref = la_aux[l_arr_aux].edsnumref
                         let lr_cta38m00.succod    = la_aux[l_arr_aux].succod
                         let lr_cta38m00.ramcod    = la_aux[l_arr_aux].ramcod
                         let lr_cta38m00.emsdat    = la_seg[l_arr_aux].emsdat
                         let lr_cta38m00.viginc    = la_seg[l_arr_aux].viginc
                         let lr_cta38m00.vigfnl    = la_seg[l_arr_aux].vigfnl
                         let lr_cta38m00.segcod    = la_seg[l_arr_aux].segcod
                         let lr_cta38m00.segnom    = la_seg[l_arr_aux].segnom
                         let lr_cta38m00.vcldes    = la_seg[l_arr_aux].vcldes
                         let lr_cta38m00.corsus    = la_seg[l_arr_aux].corsus
                         let mr_cts3800.doc_handle =la_aux[l_arr_aux].doc_handle
                         let lr_cta38m00.situacao  = la_aux[l_arr_aux].situacao
                         exit display

                 end display

                 close window cta00m11

                 if  not int_flag then
                     let mr_cts3800.resultado = 1
                     let mr_cts3800.mensagem = 'Apolice encontrada.'
                 else
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = 'Nenhum segurador com esse nome encontrado.'
                 end if
             else
                 if  l_ind = 1 then
                     let lr_cta38m00.documento = la_doc[1].documento
                     let lr_cta38m00.itmnumdig = la_aux[1].itmnumdig
                     let lr_cta38m00.edsnumref = la_aux[1].edsnumref
                     let lr_cta38m00.succod    = la_aux[1].succod
                     let lr_cta38m00.ramcod    = la_aux[1].ramcod
                     let lr_cta38m00.emsdat    = la_seg[1].emsdat
                     let lr_cta38m00.viginc    = la_seg[1].viginc
                     let lr_cta38m00.vigfnl    = la_seg[1].vigfnl
                     let lr_cta38m00.segcod    = la_seg[1].segcod
                     let lr_cta38m00.segnom    = la_seg[1].segnom
                     let lr_cta38m00.vcldes    = la_seg[1].vcldes
                     let lr_cta38m00.corsus    = la_seg[1].corsus
                     let mr_cts3800.doc_handle = la_aux[1].doc_handle
                     let lr_cta38m00.situacao  = la_aux[1].situacao
                     let mr_cts3800.resultado = 1
                 else
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = 'Nenhum segurador com esse nome encontrado.'
                 end if
             end if
         else
             if  sqlca.sqlcode = notfound then
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem = "Apolice nao cadastrada."
             else
                 let mr_cts3800.resultado = sqlca.sqlcode
                 let mr_cts3800.mensagem = "ERRO", sqlca.sqlcode
             end if
         end if
     else
         let mr_cts3800.resultado = 3
         let mr_cts3800.mensagem = "Parametros nulos."
     end if

     return lr_cta38m00.documento,
            lr_cta38m00.itmnumdig,
            lr_cta38m00.edsnumref,
            lr_cta38m00.succod,
            lr_cta38m00.ramcod,
            lr_cta38m00.emsdat,
            lr_cta38m00.viginc,
            lr_cta38m00.vigfnl,
            lr_cta38m00.segcod,
            lr_cta38m00.segnom,
            lr_cta38m00.vcldes,
            lr_cta38m00.corsus,
            mr_cts3800.doc_handle,
            mr_cts3800.resultado,
            mr_cts3800.mensagem,
            lr_cta38m00.situacao

 end function

################################################################################
# Validação para existencia de registro na base Azul filtrado por Placa        #
#------------------------------------------------------------------------------#
# Paramêtros de Entrada: - Codigo da Sucursal                                  #
#                        - Placa do Veiculo                                    #
#       .                                                                      #
# Paramêtros de Saida:   - Apolice                                             #
#                        - Codigo do Item da Apolice                           #
#                        - Codigo da Sucursal da Apolice                       #
#                        - Codigo do Ramo da Apolice                           #
#                        - Data de Emissão da Apolice                          #
#                        - Vigencia Inicial da Apolice                         #
#                        - Vigencia Final da Apolice                           #
#                        - Codido do Segurado                                  #
#                        - Nome do Segurado                                    #
#                        - Descrição do Veiculo                                #
#                        - SUSEP do Corretor                                   #
#                        - XML                                                 #
#                        - Codigo do Resultado da Busca,                       #
#                        - Mensagem de retorno para busca                      #
################################################################################
#-------------------------------------------#
 function cts38m00_dados_placa(l_par,l_tipo)
#-------------------------------------------#

     define l_par     char(07),
            l_tipo    char(01),
            l_ind     smallint,
            l_arr_aux smallint,
            i         smallint

     define lr_cta38m00 record
                            documento char(30),
                            itmnumdig decimal(7,0),
                            edsnumref decimal(9,0),
                            succod    smallint,#decimal(2,0), projeto succod
                            ramcod    smallint,
                            emsdat    date,
                            viginc    date,
                            vigfnl    date,
                            segcod    integer,
                            segnom    char(50),
                            vcldes    char(25),
                            corsus    char(06),
                            situacao  char(10)
                        end record

     define la_aux array[3000] of record
                                      emsdat     date,
                                      segcod     integer,
                                      vcldes     char(25),
                                      corsus     char(06),
                                      edsnumref  decimal(9,0),
                                      doc_handle integer,
                                      situacao   char(10)
                                 end record

     define la_placa array[3000] of record
                                      marca     char(01),
                                      succod    smallint, #decimal(2,0), projeto succod
                                      ramcod    smallint,
                                      aplnumdig decimal(9,0),
                                      itmnumdig decimal(7,0),
                                      viginc    date,
                                      vigfnl    date,
                                      segnom    char(50)
                                 end record

     if not m_prepare then
        call cts38m00_prepare()
     end if

     initialize lr_cta38m00.*,
                mr_cts3800.*,
                la_placa,
                la_aux to null

     let i = null

     if  l_par is not null then

         open c_cts38m00_002 using l_par

         whenever error continue
         fetch c_cts38m00_002 into  mr_cts3800.azlaplcod
         whenever error stop

         let l_ind = 0

         if  sqlca.sqlcode = 0 then

             foreach c_cts38m00_002 into  mr_cts3800.azlaplcod

                 let mr_cts3800.doc_handle = ctd02g00_agrupaXML(mr_cts3800.azlaplcod)
                 let l_ind = l_ind + 1

                 call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                      returning lr_cta38m00.documento,
                                lr_cta38m00.itmnumdig,
                                lr_cta38m00.edsnumref,
                                lr_cta38m00.succod,
                                lr_cta38m00.ramcod,
                                lr_cta38m00.emsdat,
                                lr_cta38m00.viginc,
                                lr_cta38m00.vigfnl,
                                lr_cta38m00.segcod,
                                lr_cta38m00.segnom,
                                lr_cta38m00.vcldes,
                                lr_cta38m00.corsus,
                                lr_cta38m00.situacao

                 let mr_cts3800.resultado = 1
                 let mr_cts3800.mensagem = "Apolice encontrada!"

                 let la_placa[l_ind].ramcod     = lr_cta38m00.ramcod
                 let la_placa[l_ind].succod     = lr_cta38m00.succod
                 let la_placa[l_ind].aplnumdig  = lr_cta38m00.documento
                 let la_placa[l_ind].itmnumdig  = lr_cta38m00.itmnumdig
                 let la_placa[l_ind].viginc     = lr_cta38m00.viginc
                 let la_placa[l_ind].vigfnl     = lr_cta38m00.vigfnl
                 let la_placa[l_ind].segnom     = lr_cta38m00.segnom
                 let la_aux[l_ind].emsdat       = lr_cta38m00.emsdat
                 let la_aux[l_ind].edsnumref    = lr_cta38m00.edsnumref
                 let la_aux[l_ind].segcod       = lr_cta38m00.segcod
                 let la_aux[l_ind].vcldes       = lr_cta38m00.vcldes
                 let la_aux[l_ind].corsus       = lr_cta38m00.corsus
                 let la_aux[l_ind].doc_handle   = mr_cts3800.doc_handle
                 let la_aux[l_ind].situacao     = lr_cta38m00.situacao

             end foreach

             if l_tipo = "B" then # programa batch(cts35m04)
                ---> Nilo - 230408 -Variavel se perdendo. for l_ind = 1 to l_ind
                for i =  1 to l_ind
                   if la_placa[l_ind].vigfnl >= today   then
                      let lr_cta38m00.documento = la_placa[l_ind].aplnumdig
                      let lr_cta38m00.itmnumdig = la_placa[l_ind].itmnumdig
                      let lr_cta38m00.succod    = la_placa[l_ind].succod
                      let lr_cta38m00.ramcod    = la_placa[l_ind].ramcod
                      let lr_cta38m00.segnom    = la_placa[l_ind].segnom
                      let lr_cta38m00.viginc    = la_placa[l_ind].viginc
                      let lr_cta38m00.vigfnl    = la_placa[l_ind].vigfnl
                      let lr_cta38m00.edsnumref = la_aux[l_ind].edsnumref
                      let lr_cta38m00.segcod    = la_aux[l_ind].segcod
                      let lr_cta38m00.emsdat    = la_aux[l_ind].emsdat
                      let lr_cta38m00.vcldes    = la_aux[l_ind].vcldes
                      let lr_cta38m00.corsus    = la_aux[l_ind].corsus
                      let mr_cts3800.doc_handle = la_aux[l_ind].doc_handle
                      let lr_cta38m00.situacao  = la_aux[l_ind].situacao
                      let mr_cts3800.resultado  = 1
                      let mr_cts3800.mensagem   = "Apolice encontrada!"
                      exit for
                   end if
                end for
                return lr_cta38m00.documento,
                       lr_cta38m00.itmnumdig,
                       lr_cta38m00.edsnumref,
                       lr_cta38m00.succod,
                       lr_cta38m00.ramcod,
                       lr_cta38m00.emsdat,
                       lr_cta38m00.viginc,
                       lr_cta38m00.vigfnl,
                       lr_cta38m00.segcod,
                       lr_cta38m00.segnom,
                       lr_cta38m00.vcldes,
                       lr_cta38m00.corsus,
                       mr_cts3800.doc_handle,
                       mr_cts3800.resultado,
                       mr_cts3800.mensagem,
                       lr_cta38m00.situacao
             end if

             if  l_ind > 1 then
                 let int_flag = false

							   open window cta00m02 at 07,02 with form "cta00m02" attribute(form line first)
                 {open window cta00m02 at 4,2 with form "cta00m02"
                             attribute(form line first)}

                 call set_count(l_ind)

                 display array la_placa to s_cta00m02.*

                     on key (interrupt)
                         let int_flag = true
                         exit display

                     on key (F8)
                       let l_arr_aux  = arr_curr()
                       let lr_cta38m00.documento = la_placa[l_arr_aux].aplnumdig
                       let lr_cta38m00.itmnumdig = la_placa[l_arr_aux].itmnumdig
                       let lr_cta38m00.succod    = la_placa[l_arr_aux].succod
                       let lr_cta38m00.ramcod    = la_placa[l_arr_aux].ramcod
                       let lr_cta38m00.segnom    = la_placa[l_arr_aux].segnom
                       let lr_cta38m00.viginc    = la_placa[l_arr_aux].viginc
                       let lr_cta38m00.vigfnl    = la_placa[l_arr_aux].vigfnl
                       let lr_cta38m00.edsnumref = la_aux[l_arr_aux].edsnumref
                       let lr_cta38m00.segcod    = la_aux[l_arr_aux].segcod
                       let lr_cta38m00.emsdat    = la_aux[l_arr_aux].emsdat
                       let lr_cta38m00.vcldes    = la_aux[l_arr_aux].vcldes
                       let lr_cta38m00.corsus    = la_aux[l_arr_aux].corsus
                       let mr_cts3800.doc_handle = la_aux[l_arr_aux].doc_handle
                       let lr_cta38m00.situacao  = la_aux[l_arr_aux].situacao
                       exit display
                 end display

                 close window cta00m02

                 if  not int_flag then
                     let mr_cts3800.resultado = 1
                     let mr_cts3800.mensagem = 'Apolice encontrada.'
                 else
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = 'Apolice nao cadastrada!'
                 end if
             else
                 if l_ind = 1 then
                     let lr_cta38m00.documento = la_placa[1].aplnumdig
                     let lr_cta38m00.itmnumdig = la_placa[1].itmnumdig
                     let lr_cta38m00.succod    = la_placa[1].succod
                     let lr_cta38m00.ramcod    = la_placa[1].ramcod
                     let lr_cta38m00.segnom    = la_placa[1].segnom
                     let lr_cta38m00.viginc    = la_placa[1].viginc
                     let lr_cta38m00.vigfnl    = la_placa[1].vigfnl
                     let lr_cta38m00.edsnumref = la_aux[1].edsnumref
                     let lr_cta38m00.segcod    = la_aux[1].segcod
                     let lr_cta38m00.emsdat    = la_aux[1].emsdat
                     let lr_cta38m00.vcldes    = la_aux[1].vcldes
                     let lr_cta38m00.corsus    = la_aux[1].corsus
                     let mr_cts3800.doc_handle = la_aux[1].doc_handle
                     let lr_cta38m00.situacao  = la_aux[1].situacao
                     let mr_cts3800.resultado = 1
                 else
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = 'Apolice nao cadastrada!'
                 end if
             end if
         else
            if  sqlca.sqlcode = notfound then
                let mr_cts3800.resultado = 2
                let mr_cts3800.mensagem = 'Apolice nao cadastrada!'
            end if
         end if
     else
         let mr_cts3800.resultado = 3
         let mr_cts3800.mensagem = 'Parametro nulo'
     end if

     return lr_cta38m00.documento,
            lr_cta38m00.itmnumdig,
            lr_cta38m00.edsnumref,
            lr_cta38m00.succod,
            lr_cta38m00.ramcod,
            lr_cta38m00.emsdat,
            lr_cta38m00.viginc,
            lr_cta38m00.vigfnl,
            lr_cta38m00.segcod,
            lr_cta38m00.segnom,
            lr_cta38m00.vcldes,
            lr_cta38m00.corsus,
            mr_cts3800.doc_handle,
            mr_cts3800.resultado,
            mr_cts3800.mensagem,
            lr_cta38m00.situacao

 end function

################################################################################
# Validação para existencia de registro na base AZUL filtrado por CPF/CGC      #
#----------------------------------------------------------------------------- #
# Paramêtros de Entrada: - Tipo: Tipo de pessoa (Fisica/Juridica)              #
#                        - CPF/CGC: Codigo do CPF ou CGC.                      #
#                        - Ordem do CGC: (Somente para pessoa Juridica)        #
#                        - Digito: Digito do CGC ou CPF                        #
#       .                                                                      #
# Paramêtros de Saida:   - Apolice                                             #
#                        - Codigo do Item da Apolice                           #
#                        - Codigo da Sucursal da Apolice                       #
#                        - Codigo do Ramo da Apolice                           #
#                        - Data de Emissão da Apolice                          #
#                        - Vigencia Inicial da Apolice                         #
#                        - Vigencia Final da Apolice                           #
#                        - Codido do Segurado                                  #
#                        - Nome do Segurado                                    #
#                        - Descrição do Veiculo                                #
#                        - SUSEP do Corretor                                   #
#                        - Codigo do Resultado da Busca,                       #
################################################################################
#-------------------------------------#
 function cts38m00_dados_cpfcgc(lr_par)
#-------------------------------------#

     define l_arr_aux smallint,
            l_ind     smallint,
            l_contados integer,
            i         smallint

     define lr_par record
                       tipo          char(01),
                       cgccpfnum     decimal(14,0),
                       cgcord        decimal(4,0),
                       cgccpfdig     decimal(2,0),
                       prg           char(01)
                   end record

     define lr_cta38m00 record
                            documento char(30),
                            itmnumdig decimal(7,0),
                            edsnumref decimal(9,0),
                            succod    smallint, #decimal(2,0), projeto succod
                            ramcod    smallint,
                            emsdat    date,
                            viginc    date,
                            vigfnl    date,
                            segcod    integer,
                            segnom    char(50),
                            vcldes    char(25),
                            corsus    char(06),
                            situacao  char(10)
                        end record

     define la_cpfcgc array[500] of record
                                      lixo      char(01),
                                      succod    smallint, #decimal(2,0), projeto succod
                                      ramcod    smallint,
                                      aplnumdig decimal(9,0),
                                      itmnumdig decimal(7,0),
                                      viginc    date,
                                      vigfnl    date,
                                      segnom    char(50)
                                 end record

     define la_aux array[500] of record
                                      emsdat     date,
                                      segcod     integer,
                                      vcldes     char(25),
                                      corsus     char(06),
                                      edsnumref  decimal(9,0),
                                      doc_handle integer,
                                      situacao   char(10)
                                 end record

     initialize la_aux to null
     initialize la_cpfcgc to null

     initialize lr_cta38m00.* to null
     initialize mr_cts3800.* to null

     let l_ind = 0
     let l_contados = 0
     let mr_cts3800.resultado = 0
     let i = null

     if not m_prepare then
        call cts38m00_prepare()
     end if

     if  lr_par.tipo is not null and
         lr_par.cgccpfnum is not null and
         lr_par.cgccpfdig is not null then

         if lr_par.prg  <> "B" then    # programas batch
            open c_cts38m00_009 using lr_par.cgccpfnum, lr_par.cgccpfdig
            fetch c_cts38m00_009 into l_contados
            close c_cts38m00_009

            if l_contados > 150 then
               call cts08g01 ("A","N",
                              "Mais de 150 registros selecionados.",
                              "Complemente o nome do segurado ou",
                              "pesquise de outra forma.", "")
                    returning mr_cts3800.mensagem

               return lr_cta38m00.documento,
                      lr_cta38m00.itmnumdig,
                      lr_cta38m00.edsnumref,
                      lr_cta38m00.succod,
                      lr_cta38m00.ramcod,
                      lr_cta38m00.emsdat,
                      lr_cta38m00.viginc,
                      lr_cta38m00.vigfnl,
                      lr_cta38m00.segcod,
                      lr_cta38m00.segnom,
                      lr_cta38m00.vcldes,
                      lr_cta38m00.corsus,
                      mr_cts3800.doc_handle,
                      mr_cts3800.resultado,
                      mr_cts3800.mensagem,
                      lr_cta38m00.situacao
            end if
         end if
         if  lr_par.tipo = 'F' then

             open c_cts38m00_003 using lr_par.cgccpfnum,
                                     lr_par.cgccpfdig

             whenever error continue
             fetch c_cts38m00_003 into  mr_cts3800.azlaplcod
             whenever error stop

             if  sqlca.sqlcode = 0 then

                 foreach c_cts38m00_003 into  mr_cts3800.azlaplcod
                     let l_ind = l_ind + 1

                     let mr_cts3800.doc_handle = ctd02g00_agrupaXML(mr_cts3800.azlaplcod)

                     call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                          returning lr_cta38m00.documento,
                                    lr_cta38m00.itmnumdig,
                                    lr_cta38m00.edsnumref,
                                    lr_cta38m00.succod,
                                    lr_cta38m00.ramcod,
                                    lr_cta38m00.emsdat,
                                    lr_cta38m00.viginc,
                                    lr_cta38m00.vigfnl,
                                    lr_cta38m00.segcod,
                                    lr_cta38m00.segnom,
                                    lr_cta38m00.vcldes,
                                    lr_cta38m00.corsus,
                                    lr_cta38m00.situacao

                     let la_cpfcgc[l_ind].succod    = lr_cta38m00.succod
                     let la_cpfcgc[l_ind].ramcod    = lr_cta38m00.ramcod
                     let la_cpfcgc[l_ind].aplnumdig = lr_cta38m00.documento
                     let la_cpfcgc[l_ind].itmnumdig = lr_cta38m00.itmnumdig
                     let la_cpfcgc[l_ind].viginc    = lr_cta38m00.viginc
                     let la_cpfcgc[l_ind].vigfnl    = lr_cta38m00.vigfnl
                     let la_cpfcgc[l_ind].segnom    = lr_cta38m00.segnom
                     let la_aux[l_ind].emsdat       = lr_cta38m00.emsdat
                     let la_aux[l_ind].edsnumref    = lr_cta38m00.edsnumref
                     let la_aux[l_ind].segcod       = lr_cta38m00.segcod
                     let la_aux[l_ind].vcldes       = lr_cta38m00.vcldes
                     let la_aux[l_ind].corsus       = lr_cta38m00.corsus
                     let la_aux[l_ind].doc_handle   = mr_cts3800.doc_handle
                     let la_aux[l_ind].situacao     = lr_cta38m00.situacao
                     let mr_cts3800.mensagem = "Apolice encontrada!(cgccpf)"

                 end foreach
             else
                 if  sqlca.sqlcode = notfound then
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = "Apolice nao cadastrada!(cgccpf)"
                 end if
             end if
         else
             open c_cts38m00_004 using lr_par.cgccpfnum,
                                     lr_par.cgcord,
                                     lr_par.cgccpfdig

             whenever error continue
             fetch c_cts38m00_004 into  mr_cts3800.azlaplcod
             whenever error stop

             if  sqlca.sqlcode = 0 then
                 let l_ind = 0

                 foreach c_cts38m00_004 into  mr_cts3800.azlaplcod
                     let l_ind = l_ind + 1

                     let mr_cts3800.doc_handle = ctd02g00_agrupaXML(mr_cts3800.azlaplcod)

                     call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                          returning lr_cta38m00.documento,
                                    lr_cta38m00.itmnumdig,
                                    lr_cta38m00.edsnumref,
                                    lr_cta38m00.succod,
                                    lr_cta38m00.ramcod,
                                    lr_cta38m00.emsdat,
                                    lr_cta38m00.viginc,
                                    lr_cta38m00.vigfnl,
                                    lr_cta38m00.segcod,
                                    lr_cta38m00.segnom,
                                    lr_cta38m00.vcldes,
                                    lr_cta38m00.corsus,
                                    lr_cta38m00.situacao

                     let la_cpfcgc[l_ind].succod     = lr_cta38m00.succod
                     let la_cpfcgc[l_ind].ramcod     = lr_cta38m00.ramcod
                     let la_cpfcgc[l_ind].aplnumdig  = lr_cta38m00.documento
                     let la_cpfcgc[l_ind].itmnumdig  = lr_cta38m00.itmnumdig
                     let la_cpfcgc[l_ind].viginc     = lr_cta38m00.viginc
                     let la_cpfcgc[l_ind].vigfnl     = lr_cta38m00.vigfnl
                     let la_cpfcgc[l_ind].segnom     = lr_cta38m00.segnom
                     let la_aux[l_ind].edsnumref     = lr_cta38m00.edsnumref
                     let la_aux[l_ind].emsdat        = lr_cta38m00.emsdat
                     let la_aux[l_ind].segcod        = lr_cta38m00.segcod
                     let la_aux[l_ind].vcldes        = lr_cta38m00.vcldes
                     let la_aux[l_ind].corsus        = lr_cta38m00.corsus
                     let la_aux[l_ind].doc_handle    = mr_cts3800.doc_handle
                     let la_aux[l_ind].situacao      = lr_cta38m00.situacao
                     let mr_cts3800.mensagem = "Apolice encontrada!"

                 end foreach
             else
                 if  sqlca.sqlcode = notfound then
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = "Apolice nao cadastrada!"
                 end if
             end if
         end if
         if lr_par.prg  =  "B"   then
            ---> Nilo - 230408 - Variavel se perdendo. for l_ind = 1 to l_ind
            for i = 1 to l_ind
                if la_cpfcgc[l_ind].vigfnl  >= today then
                   let lr_cta38m00.documento = la_cpfcgc[l_ind].aplnumdig
                   let lr_cta38m00.itmnumdig = la_cpfcgc[l_ind].itmnumdig
                   let lr_cta38m00.succod    = la_cpfcgc[l_ind].succod
                   let lr_cta38m00.ramcod    = la_cpfcgc[l_ind].ramcod
                   let lr_cta38m00.viginc    = la_cpfcgc[l_ind].viginc
                   let lr_cta38m00.vigfnl    = la_cpfcgc[l_ind].vigfnl
                   let lr_cta38m00.segnom    = la_cpfcgc[l_ind].segnom
                   let lr_cta38m00.vcldes    = la_aux[l_ind].vcldes
                   let lr_cta38m00.corsus    = la_aux[l_ind].corsus
                   let lr_cta38m00.segcod    = la_aux[l_ind].segcod
                   let lr_cta38m00.emsdat    = la_aux[l_ind].emsdat
                   let lr_cta38m00.edsnumref = la_aux[l_ind].edsnumref
                   let mr_cts3800.doc_handle = la_aux[l_ind].doc_handle
                   let lr_cta38m00.situacao  = la_aux[l_ind].situacao
                   let mr_cts3800.resultado  = 1
                   let mr_cts3800.mensagem   = "Apolice encontrada!"
                   exit for
                end if
            end for
            return lr_cta38m00.documento,
                   lr_cta38m00.itmnumdig,
                   lr_cta38m00.edsnumref,
                   lr_cta38m00.succod,
                   lr_cta38m00.ramcod,
                   lr_cta38m00.emsdat,
                   lr_cta38m00.viginc,
                   lr_cta38m00.vigfnl,
                   lr_cta38m00.segcod,
                   lr_cta38m00.segnom,
                   lr_cta38m00.vcldes,
                   lr_cta38m00.corsus,
                   mr_cts3800.doc_handle,
                   mr_cts3800.resultado,
                   mr_cts3800.mensagem,
                   lr_cta38m00.situacao
         end if
         if  l_ind > 1 then
             let int_flag = false

             open window cta00m02 at 07,02 with form "cta00m02" attribute(form line first)
             {open window cta00m02 at 4,2 with form "cta00m02"
                  attribute(form line first)}

             call set_count(l_ind)
             display array la_cpfcgc to s_cta00m02.*

                 on key (interrupt)
                     let int_flag = true
                     exit display

                 on key (F8)
                     let l_arr_aux  = arr_curr()

                     let lr_cta38m00.documento = la_cpfcgc[l_arr_aux].aplnumdig
                     let lr_cta38m00.itmnumdig = la_cpfcgc[l_arr_aux].itmnumdig
                     let lr_cta38m00.succod    = la_cpfcgc[l_arr_aux].succod
                     let lr_cta38m00.ramcod    = la_cpfcgc[l_arr_aux].ramcod
                     let lr_cta38m00.viginc    = la_cpfcgc[l_arr_aux].viginc
                     let lr_cta38m00.vigfnl    = la_cpfcgc[l_arr_aux].vigfnl
                     let lr_cta38m00.segnom    = la_cpfcgc[l_arr_aux].segnom
                     let lr_cta38m00.vcldes    = la_aux[l_arr_aux].vcldes
                     let lr_cta38m00.corsus    = la_aux[l_arr_aux].corsus
                     let lr_cta38m00.segcod    = la_aux[l_arr_aux].segcod
                     let lr_cta38m00.emsdat    = la_aux[l_arr_aux].emsdat
                     let lr_cta38m00.edsnumref = la_aux[l_arr_aux].edsnumref
                     let mr_cts3800.doc_handle = la_aux[l_arr_aux].doc_handle
                     let lr_cta38m00.situacao  = la_aux[l_arr_aux].situacao
                     let mr_cts3800.resultado = 1
                     exit display

             end display

             close window cta00m02

             if  not int_flag then
                 let mr_cts3800.resultado = 1
                 let mr_cts3800.mensagem = "Apolice Encontrada!"
             else
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem = "Nenhuma Apolice Selecionada!"
             end if
         else
             if  l_ind = 1 then

                 let lr_cta38m00.documento = la_cpfcgc[1].aplnumdig
                 let lr_cta38m00.itmnumdig = la_cpfcgc[1].itmnumdig
                 let lr_cta38m00.succod    = la_cpfcgc[1].succod
                 let lr_cta38m00.ramcod    = la_cpfcgc[1].ramcod
                 let lr_cta38m00.viginc    = la_cpfcgc[1].viginc
                 let lr_cta38m00.vigfnl    = la_cpfcgc[1].vigfnl
                 let lr_cta38m00.segnom    = la_cpfcgc[1].segnom
                 let lr_cta38m00.edsnumref = la_aux[1].edsnumref
                 let lr_cta38m00.emsdat    = la_aux[1].emsdat
                 let lr_cta38m00.vcldes    = la_aux[1].vcldes
                 let lr_cta38m00.corsus    = la_aux[1].corsus
                 let lr_cta38m00.segcod    = la_aux[1].segcod
                 let mr_cts3800.doc_handle = la_aux[1].doc_handle
                 let lr_cta38m00.situacao  = la_aux[1].situacao
                 let mr_cts3800.resultado = 1
                 let mr_cts3800.mensagem = "Apolice Encontrada!"
             else
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem = "Nenhuma Apolice Selecionada!"
             end if
         end if
     else
        let mr_cts3800.resultado = 3
        let mr_cts3800.mensagem = "Parametro nulo"
     end if

     return lr_cta38m00.documento,
            lr_cta38m00.itmnumdig,
            lr_cta38m00.edsnumref,
            lr_cta38m00.succod,
            lr_cta38m00.ramcod,
            lr_cta38m00.emsdat,
            lr_cta38m00.viginc,
            lr_cta38m00.vigfnl,
            lr_cta38m00.segcod,
            lr_cta38m00.segnom,
            lr_cta38m00.vcldes,
            lr_cta38m00.corsus,
            mr_cts3800.doc_handle,
            mr_cts3800.resultado,
            mr_cts3800.mensagem,
            lr_cta38m00.situacao

 end function

################################################################################
# Validação para existencia de registro na base da AZUL filtrado por Chassi    #
#----------------------------------------------------------------------------- #
# Paramêtros de Entrada: - Numero final do Chassis                             #
#       .                                                                      #
# Paramêtros de Saida:   - Apolice                                             #
#                        - Codigo do Item da Apolice                           #
#                        - Codigo da Sucursal da Apolice                       #
#                        - Codigo do Ramo da Apolice                           #
#                        - Data de Emissão da Apolice                          #
#                        - Vigencia Inicial da Apolice                         #
#                        - Vigencia Final da Apolice                           #
#                        - Codido do Segurado                                  #
#                        - Nome do Segurado                                    #
#                        - Descrição do Veiculo                                #
#                        - SUSEP do Corretor                                   #
################################################################################
#------------------------------------#
 function cts38m00_dados_chassi(l_par)
#------------------------------------#

     define l_par char(08),
            l_ind smallint,
            l_arr_aux smallint

     define lr_cta38m00 record
                            documento char(30),
                            itmnumdig decimal(7,0),
                            edsnumref decimal(9,0),
                            succod    smallint,#decimal(2,0), projeto succod
                            ramcod    smallint,
                            emsdat    date,
                            viginc    date,
                            vigfnl    date,
                            segcod    integer,
                            segnom    char(50),
                            vcldes    char(25),
                            corsus    char(06),
                            situacao  char(10)
                        end record

     define la_chassi array[500] of record
                                         marca      char(01),
                                         succod    smallint, #decimal(2,0), projeto succod
                                         ramcod    smallint,
                                         aplnumdig decimal(9,0),
                                         itmnumdig decimal(7,0),
                                         viginc    date,
                                         vigfnl    date,
                                         segnom    char(50)
                                    end record

     define la_aux array[500] of record
                                      emsdat     date,
                                      segcod     integer,
                                      vcldes     char(25),
                                      corsus     char(06),
                                      edsnumref  decimal(9,0),
                                      doc_handle integer,
                                      situacao   char(10)
                                 end record

     initialize la_chassi to null
     initialize la_aux to null
     initialize lr_cta38m00.* to null
     initialize mr_cts3800.* to null
     let mr_cts3800.resultado = 0

     if  l_par is not null then

         if not m_prepare then
            call cts38m00_prepare()
         end if

         open c_cts38m00_005 using l_par

         whenever error continue
         fetch c_cts38m00_005 into  mr_cts3800.xml
         whenever error stop

         let l_ind = 0

         if  sqlca.sqlcode = 0 then

             foreach c_cts38m00_005 into mr_cts3800.azlaplcod

                 let mr_cts3800.doc_handle = ctd02g00_agrupaXML(mr_cts3800.azlaplcod)

                 call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                      returning lr_cta38m00.documento,
                                lr_cta38m00.itmnumdig,
                                lr_cta38m00.edsnumref,
                                lr_cta38m00.succod,
                                lr_cta38m00.ramcod,
                                lr_cta38m00.emsdat,
                                lr_cta38m00.viginc,
                                lr_cta38m00.vigfnl,
                                lr_cta38m00.segcod,
                                lr_cta38m00.segnom,
                                lr_cta38m00.vcldes,
                                lr_cta38m00.corsus,
                                lr_cta38m00.situacao

                 let l_ind = l_ind + 1
                 let la_chassi[l_ind].succod     = lr_cta38m00.succod
                 let la_chassi[l_ind].ramcod     = lr_cta38m00.ramcod
                 let la_chassi[l_ind].aplnumdig  = lr_cta38m00.documento
                 let la_chassi[l_ind].itmnumdig  = lr_cta38m00.itmnumdig
                 let la_chassi[l_ind].viginc     = lr_cta38m00.viginc
                 let la_chassi[l_ind].vigfnl     = lr_cta38m00.vigfnl
                 let la_chassi[l_ind].segnom     = lr_cta38m00.segnom
                 let la_aux[l_ind].edsnumref     = lr_cta38m00.edsnumref
                 let la_aux[l_ind].emsdat        = lr_cta38m00.emsdat
                 let la_aux[l_ind].segcod        = lr_cta38m00.segcod
                 let la_aux[l_ind].vcldes        = lr_cta38m00.vcldes
                 let la_aux[l_ind].corsus        = lr_cta38m00.corsus
                 let la_aux[l_ind].doc_handle    = mr_cts3800.doc_handle
                 let la_aux[l_ind].situacao      = lr_cta38m00.situacao

             end foreach

             if  l_ind > 1 then

                 let int_flag = false

                 open window cta00m02 at 07,02 with form "cta00m02" attribute(form line first)
                 {open window cta00m02 at 4,2 with form "cta00m02"
                      attribute(form line first)}

                 call set_count(l_ind)
                 display array la_chassi to s_cta00m02.*

                     on key (interrupt)
                         let int_flag = true
                         exit display

                     on key (F8)
                      let l_arr_aux  = arr_curr()
                      let lr_cta38m00.documento = la_chassi[l_arr_aux].aplnumdig
                      let lr_cta38m00.itmnumdig = la_chassi[l_arr_aux].itmnumdig
                      let lr_cta38m00.succod    = la_chassi[l_arr_aux].succod
                      let lr_cta38m00.ramcod    = la_chassi[l_arr_aux].ramcod
                      let lr_cta38m00.viginc    = la_chassi[l_arr_aux].viginc
                      let lr_cta38m00.vigfnl    = la_chassi[l_arr_aux].vigfnl
                      let lr_cta38m00.segnom    = la_chassi[l_arr_aux].segnom
                      let lr_cta38m00.vcldes    = la_aux[l_arr_aux].vcldes
                      let lr_cta38m00.corsus    = la_aux[l_arr_aux].corsus
                      let lr_cta38m00.segcod    = la_aux[l_arr_aux].segcod
                      let lr_cta38m00.emsdat    = la_aux[l_arr_aux].emsdat
                      let lr_cta38m00.edsnumref = la_aux[l_arr_aux].edsnumref
                      let mr_cts3800.doc_handle = la_aux[l_arr_aux].doc_handle
                      let lr_cta38m00.situacao  = la_aux[l_arr_aux].situacao
                      let mr_cts3800.resultado = 1
                      exit display
                 end display

                 close window cta00m02

                 if  not int_flag then
                     let mr_cts3800.resultado = 1
                     let mr_cts3800.mensagem = "Apolice Encontrada!"
                 else
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = "Nenhuma Apolice Selecionada!"
                 end if

             else
                 if  l_ind = 1 then
                     let lr_cta38m00.documento = la_chassi[1].aplnumdig
                     let lr_cta38m00.itmnumdig = la_chassi[1].itmnumdig
                     let lr_cta38m00.succod    = la_chassi[1].succod
                     let lr_cta38m00.ramcod    = la_chassi[1].ramcod
                     let lr_cta38m00.viginc    = la_chassi[1].viginc
                     let lr_cta38m00.vigfnl    = la_chassi[1].vigfnl
                     let lr_cta38m00.segnom    = la_chassi[1].segnom
                     let lr_cta38m00.edsnumref = la_aux[1].edsnumref
                     let lr_cta38m00.emsdat    = la_aux[1].emsdat
                     let lr_cta38m00.vcldes    = la_aux[1].vcldes
                     let lr_cta38m00.corsus    = la_aux[1].corsus
                     let lr_cta38m00.segcod    = la_aux[1].segcod
                     let mr_cts3800.doc_handle = la_aux[1].doc_handle
                     let lr_cta38m00.situacao  = la_aux[1].situacao
                     let mr_cts3800.resultado = 1
                 else
                     let mr_cts3800.resultado = 2
                     let mr_cts3800.mensagem = "Apolice nao cadastrada!"
                 end if
             end if
         else
             if  sqlca.sqlcode = notfound then
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem = "Apolice nao cadastrada!"
             end if
         end if

     else
         let mr_cts3800.resultado = 3
         let mr_cts3800.mensagem = 'Parametros invalidos'
     end if

     return lr_cta38m00.documento,
            lr_cta38m00.itmnumdig,
            lr_cta38m00.edsnumref,
            lr_cta38m00.succod,
            lr_cta38m00.ramcod,
            lr_cta38m00.emsdat,
            lr_cta38m00.viginc,
            lr_cta38m00.vigfnl,
            lr_cta38m00.segcod,
            lr_cta38m00.segnom,
            lr_cta38m00.vcldes,
            lr_cta38m00.corsus,
            mr_cts3800.doc_handle,
            mr_cts3800.resultado,
            mr_cts3800.mensagem,
            lr_cta38m00.situacao

 end function

################################################################################
## Validação para existencia de registro na base da Azul filtrado por Proposta #
##---------------------------------------------------------------------------- #
## Paramêtros de Entrada: - Codigo da Sucursal
##                        - Numero da Apolice                                  #
##      .                                                                      #
## Paramêtros de Saida:   - Apolice                                            #
##                        - Codigo do Item da Apolice                          #
##                        - Codigo da Sucursal da Apolice                      #
##                        - Codigo do Ramo da Apolice                          #
##                        - Data de Emissão da Apolice                         #
##                        - Vigencia Inicial da Apolice                        #
##                        - Vigencia Final da Apolice                          #
##                        - Codido do Segurado                                 #
##                        - Nome do Segurado                                   #
##                        - Descrição do Veiculo                               #
##                        - SUSEP do Corretor                                  #
##                        - Codigo do Resultado da Busca,                      #
################################################################################
##---------------------------------------#
# function cts38m00_dados_proposta(lr_par)
##---------------------------------------#
#
#     define lr_par    record
#                          prporg    decimal(9,0),
#                          prpnumdig decimal(8,0)
#                      end record
#
#     define lr_cta38m00 record
#                            documento char(30),
#                            itmnumdig decimal(7,0),
#                            edsnumref decimal(9,0),
#                            succod    decimal(2,0),
#                            ramcod    smallint,
#                            emsdat    date,
#                            viginc    date,
#                            vigfnl    date,
#                            segcod    integer,
#                            segnom    char(50),
#                            vcldes    char(25),
#                            corsus    char(06),
#                            situacao  char(10)
#                        end record
#
#     define l_doc_handle integer
#
#     initialize mr_cts3800.* to null
#     initialize lr_cta38m00.* to null
#     let l_doc_handle = null
#
#     call cts38m00_prepare()
#
#     if  lr_par.prporg is not null and
#         lr_par.prpnumdig is not null then
#
#         open c_cts38m00_006 using lr_par.prporg,
#                                 lr_par.prpnumdig
#
#         whenever error continue
#         fetch c_cts38m00_006 into  mr_cts3800.azlaplcod
#         whenever error stop
#
#         if  sqlca.sqlcode = 0 then
#             let mr_cts3800.resultado = 1
#
#             let mr_cts3800.doc_handle = ctd02g00_agrupaXML(mr_cts3800.azlaplcod)
#
#             call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
#                  returning lr_cta38m00.documento,
#                            lr_cta38m00.itmnumdig,
#                            lr_cta38m00.edsnumref,
#                            lr_cta38m00.succod,
#                            lr_cta38m00.ramcod,
#                            lr_cta38m00.emsdat,
#                            lr_cta38m00.viginc,
#                            lr_cta38m00.vigfnl,
#                            lr_cta38m00.segcod,
#                            lr_cta38m00.segnom,
#                            lr_cta38m00.vcldes,
#                            lr_cta38m00.corsus,
#                            lr_cta38m00.situacao
#
#             let mr_cts3800.mensagem = 'Apolice encontrada.'
#         else
#             if  sqlca.sqlcode = notfound then
#                 let mr_cts3800.resultado = 2
#                 let mr_cts3800.mensagem = "Apolice nao encontrada!"
#             end if
#         end if
#     else
#         let mr_cts3800.resultado = 3
#         let mr_cts3800.mensagem = "Parametros nulos"
#     end if
#
#     return lr_cta38m00.documento,
#            lr_cta38m00.itmnumdig,
#            lr_cta38m00.edsnumref,
#            lr_cta38m00.succod,
#            lr_cta38m00.ramcod,
#            lr_cta38m00.emsdat,
#            lr_cta38m00.viginc,
#            lr_cta38m00.vigfnl,
#            lr_cta38m00.segcod,
#            lr_cta38m00.segnom,
#            lr_cta38m00.vcldes,
#            lr_cta38m00.corsus,
#            mr_cts3800.doc_handle,
#            mr_cts3800.resultado,
#            mr_cts3800.mensagem,
#            lr_cta38m00.situacao
#
# end function

################################################################################
# Extração dos dados do XML                                                    #
#----------------------------------------------------------------------------- #
# Paramêtros de Entrada: - Script XML                                          #
#       .                                                                      #
# Paramêtros de Saida:   - Apolice                                             #
#                        - Codigo do Item da Apolice                           #
#                        - Codigo da Sucursal da Apolice                       #
#                        - Codigo do Ramo da Apolice                           #
#                        - Data de Emissão da Apolice                          #
#                        - Vigencia Inicial da Apolice                         #
#                        - Vigencia Final da Apolice                           #
#                        - Codido do Segurado                                  #
#                        - Nome do Segurado                                    #
#                        - Descrição do Veiculo                                #
#                        - SUSEP do Corretor                                   #
################################################################################
#-----------------------------------------------#
 function cts38m00_extrai_dados_xml(l_doc_handle)
#-----------------------------------------------#

     define l_xml        char(32000),
            l_doc_handle integer,
            l_vel        char(25)

     define lr_cta38m00 record
                            documento char(30),
                            itmnumdig decimal(7,0),
                            edsnumref decimal(9,0),
                            succod    smallint,#decimal(2,0), projeto succod
                            ramcod    smallint,
                            emsdat    date,
                            viginc    date,
                            vigfnl    date,
                            segcod    integer,
                            segnom    char(50),
                            vcldes    char(25),
                            corsus    char(06),
                            situacao  char(10)
                        end record

     initialize lr_cta38m00.* to null
    #let l_doc_handle = null

    #let l_doc_handle = figrc011_parse(l_xml)

     let lr_cta38m00.documento = figrc011_xpath(l_doc_handle,"/APOLICE/APOLICE")
     let lr_cta38m00.itmnumdig = figrc011_xpath(l_doc_handle,"/APOLICE/ITEM")
     let lr_cta38m00.succod    = figrc011_xpath(l_doc_handle,"/APOLICE/SUCURSAL")
     let lr_cta38m00.edsnumref = figrc011_xpath(l_doc_handle,"/APOLICE/ENDOSSO")
     let lr_cta38m00.ramcod    = figrc011_xpath(l_doc_handle,"/APOLICE/RAMO")
     let lr_cta38m00.emsdat    = figrc011_xpath(l_doc_handle,"/APOLICE/EMISSAO")
     let lr_cta38m00.viginc    = figrc011_xpath(l_doc_handle,"/APOLICE/VIGENCIA/INICIAL")
     let lr_cta38m00.vigfnl    = figrc011_xpath(l_doc_handle,"/APOLICE/VIGENCIA/FINAL")
     let lr_cta38m00.segcod    = null
     let lr_cta38m00.segnom    = figrc011_xpath(l_doc_handle,"/APOLICE/SEGURADO/NOME")
     let lr_cta38m00.situacao  = figrc011_xpath(l_doc_handle,"/APOLICE/SITUACAO")
     #Concatena as informações do modelo do carro
     let l_vel = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/MARCA")
     let l_vel = l_vel clipped, ' ',figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/TIPO")
     let l_vel = l_vel clipped, ' ',figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/MODELO")
     let lr_cta38m00.vcldes    = l_vel

     let lr_cta38m00.corsus    = figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/SUSEP")

     return lr_cta38m00.documento,
            lr_cta38m00.itmnumdig,
            lr_cta38m00.edsnumref,
            lr_cta38m00.succod,
            lr_cta38m00.ramcod,
            lr_cta38m00.emsdat,
            lr_cta38m00.viginc,
            lr_cta38m00.vigfnl,
            lr_cta38m00.segcod,
            lr_cta38m00.segnom,
            lr_cta38m00.vcldes,
            lr_cta38m00.corsus,
            lr_cta38m00.situacao

 end function

#--------------------------------------------------#
 function cts38m00_extrai_dados_veicul(l_doc_handle)
#--------------------------------------------------#

     define l_doc_handle integer

     define lr_veicul record
                          vclmrcnom like agbkmarca.vclmrcnom,
                          vcltipnom like agbktip.vcltipnom,
                          vclmdlnom like agbkveic.vclmdlnom,
                          vclchs    char(20),
                          vcllicnum like abbmveic.vcllicnum,
                          vclanofbc like abbmveic.vclanofbc,
                          vclanomdl like abbmveic.vclanomdl
                      end record

     #initialize lr_veicul.* to null
     #
     #let l_doc_handle = figrc011_parse(l_xml)

     let lr_veicul.vclmrcnom = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/MARCA")
     let lr_veicul.vcltipnom = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/TIPO")
     let lr_veicul.vclmdlnom = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/MODELO")
     let lr_veicul.vclchs    = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/CHASSI")
     let lr_veicul.vcllicnum = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/PLACA")
     let lr_veicul.vclanofbc = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/ANO/FABRICACAO")
     let lr_veicul.vclanomdl = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/ANO/MODELO")

     return lr_veicul.vclmrcnom,
            lr_veicul.vcltipnom,
            lr_veicul.vclmdlnom,
            lr_veicul.vclchs,
            lr_veicul.vcllicnum,
            lr_veicul.vclanofbc,
            lr_veicul.vclanomdl

 end function

#----------------------------------------------#
 function cts38m00_extrai_situacao(l_doc_handle)
#----------------------------------------------#

     define l_doc_handle integer,
            l_situacao   char (15)

     let l_situacao = null
     #let l_doc_handle = figrc011_parse(l_xml)

     let l_situacao  = figrc011_xpath(l_doc_handle, "/APOLICE/SITUACAO")

     return l_situacao

 end function

#-----------------------------------------------#
 function cts38m00_extrai_dados_seg(l_doc_handle)
#-----------------------------------------------#
     define l_doc_handle integer

     define lr_seg record
                       segnom    like gsakseg.segnom,
                       segteltxt like gsakend.teltxt
                   end record

     initialize lr_seg.* to null

     #let l_doc_handle = figrc011_parse(l_xml)

     let lr_seg.segnom    = figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/NOME")
     let lr_seg.segteltxt = '(', figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/FONES/FONE/DDD"), ')'
     let lr_seg.segteltxt = lr_seg.segteltxt clipped, figrc011_xpath(l_doc_handle, "/APOLICE/SEGURADO/FONES/FONE/NUMERO")

     return lr_seg.segnom,
            lr_seg.segteltxt

 end function

#-------------------------------------------------#
 function cts38m00_extrai_dados_corr(l_doc_handle)
#-------------------------------------------------#

     define l_doc_handle integer

     define lr_corr record
                        cornom    like gcakcorr.cornom,
                        corsus    like gcaksusep.corsus,
                        corteltxt like gcakfilial.teltxt
                    end record

     initialize lr_corr.* to null

     #let l_doc_handle = figrc011_parse(l_xml)

     let lr_corr.cornom    = figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/NOME")
     let lr_corr.corsus    = figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/SUSEP")
     let lr_corr.corteltxt = '(', figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/FONES/FONE/DDD"), ')'
     let lr_corr.corteltxt = lr_corr.corteltxt clipped, figrc011_xpath(l_doc_handle, "/APOLICE/CORRETOR/FONES/FONE/NUMERO")

     return lr_corr.cornom,
            lr_corr.corsus,
            lr_corr.corteltxt

 end function

#------------------------------------------------#
 function cts38m00_extrai_categoria(l_doc_handle)
#------------------------------------------------#
     define l_doc_handle integer,
            l_ctgtrfcod  like abbmcasco.ctgtrfcod

     let l_ctgtrfcod = null

     #let l_doc_handle = figrc011_parse(l_xml)

     let l_ctgtrfcod    = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/CATEGORIATARIFARIA")

     return l_ctgtrfcod

 end function

#----------------------------------------------#
 function cts38m00_extrai_vigencia(l_doc_handle)
#----------------------------------------------#

     define l_doc_handle integer

     define lr_vig  record
                         viginc like abamapol.viginc,
                         vigfnl like abamapol.vigfnl
                    end record

     initialize lr_vig.* to null

     let lr_vig.viginc  = figrc011_xpath(l_doc_handle, "/APOLICE/VIGENCIA/INICIAL")
     let lr_vig.vigfnl  = figrc011_xpath(l_doc_handle, "/APOLICE/VIGENCIA/FINAL")

     return lr_vig.viginc,
            lr_vig.vigfnl

 end function

#------------------------------------------------#
 function cts38m00_extrai_emissao(l_doc_handle)
#------------------------------------------------#
     define l_doc_handle integer,
            l_emsdat     like abamapol.emsdat

     let l_emsdat = null

     #let l_doc_handle = figrc011_parse(l_xml)

     let l_emsdat    = figrc011_xpath(l_doc_handle, "/APOLICE/EMISSAO")

     return l_emsdat

 end function

#---------------------------------------------#
 function cts38m00_busca_itens_apolice(lr_par)
#---------------------------------------------#

     define lr_veic  record
           codigo    integer,
           marca     char(25),
           tipo      char(25),
           modelo    char(25),
           chassi    char(100),
           vcllicnum char(08),
           anofab    smallint,
           anomodelo char(25),
           categ     integer,
           automov   char(03),
           vcldes    char(50),
           vclchsfnl char(20)
      end record

     define lr_par    record
            succod    smallint, #decimal(2,0), projeto succod
            aplnumdig decimal(9,0)
     end record

     define la_item    array[501] of record
            itmnumdig  like abbmitem.itmnumdig,
            vcldes     char (25),
            vcllicnum  like abbmveic.vcllicnum,
            vclchsfnl  like abbmveic.vclchsfnl
     end record

     define la_aux     array[501] of record
            documento  char(30),
            edsnumref  decimal(9,0),
            succod     smallint, #decimal(2,0), projeto succod
            ramcod     smallint,
            emsdat     date,
            viginc     date,
            vigfnl     date,
            segcod     integer,
            segnom     char(50),
            corsus     char(06),
            doc_handle integer
     end record

     define lr_cta38m00 record
            documento   char(30),
            itmnumdig   decimal(7,0),
            edsnumref   decimal(9,0),
            succod      smallint, #decimal(2,0), projeto succod
            ramcod      smallint,
            emsdat      date,
            viginc      date,
            vigfnl      date,
            segcod      integer,
            segnom      char(50),
            corsus      char(06),
            situacao    char(10)
     end record

     define l_doc_handle integer,
            l_ind        smallint,
            l_arr_aux    smallint,
            l_aux        like abbmveic.vclchsfnl,
            l_aux2       smallint

     initialize lr_cta38m00.*,
                lr_veic.*,
                mr_cts3800.*,
                l_doc_handle,
                l_aux,
                l_aux2,
                l_arr_aux,
                l_ind,
                la_aux,
                la_item to null

     if not m_prepare then
        call cts38m00_prepare()
     end if

     open c_cts38m00_007 using lr_par.succod,
                               lr_par.aplnumdig

     whenever error continue
       fetch c_cts38m00_007 into mr_cts3800.azlaplcod
     whenever error stop

     if  sqlca.sqlcode = 0 then

         let l_ind = 0

         foreach c_cts38m00_007 into mr_cts3800.azlaplcod

             let l_ind = l_ind + 1

             let mr_cts3800.doc_handle = ctd02g00_agrupaXML(mr_cts3800.azlaplcod)

             call cts40g02_extraiDoXML(mr_cts3800.doc_handle,'VEICULO')
                  returning lr_veic.codigo,
                            lr_veic.marca,
                            lr_veic.tipo,
                            lr_veic.modelo,
                            lr_veic.chassi,
                            lr_veic.vcllicnum,
                            lr_veic.anofab,
                            lr_veic.anomodelo,
                            lr_veic.categ,
                            lr_veic.automov

             #BURINI#
             call cts38m00_extrai_dados_xml(mr_cts3800.doc_handle)
                  returning lr_cta38m00.documento,
                            lr_cta38m00.itmnumdig,
                            lr_cta38m00.edsnumref,
                            lr_cta38m00.succod,
                            lr_cta38m00.ramcod,
                            lr_cta38m00.emsdat,
                            lr_cta38m00.viginc,
                            lr_cta38m00.vigfnl,
                            lr_cta38m00.segcod,
                            lr_cta38m00.segnom,
                            lr_veic.vcldes,
                            lr_cta38m00.corsus,
                            lr_cta38m00.situacao

             #let l_aux2 = length(lr_veic.vclchsfnl)
             #
             #display 'CHASSI COMPLETO: ',lr_veic.vclchsfnl
             #let l_aux = lr_veic.vclchsfnl[12,20]
             #display 'CHASSI FINAL: ',l_aux

             #if  l_aux2 >= 8 then
                 let la_item[l_ind].vclchsfnl = lr_veic.chassi[12,20]
             #end if

             let la_item[l_ind].itmnumdig = lr_cta38m00.itmnumdig
             let la_item[l_ind].vcldes    = lr_veic.vcldes
             let la_item[l_ind].vcllicnum = lr_veic.vcllicnum
             let la_aux[l_ind].documento  = lr_cta38m00.documento
             let la_aux[l_ind].edsnumref  = lr_cta38m00.edsnumref
             let la_aux[l_ind].succod     = lr_cta38m00.succod
             let la_aux[l_ind].ramcod     = lr_cta38m00.ramcod
             let la_aux[l_ind].emsdat     = lr_cta38m00.emsdat
             let la_aux[l_ind].viginc     = lr_cta38m00.viginc
             let la_aux[l_ind].vigfnl     = lr_cta38m00.vigfnl
             let la_aux[l_ind].segcod     = lr_cta38m00.segcod
             let la_aux[l_ind].segnom     = lr_cta38m00.segnom
             let la_aux[l_ind].corsus     = lr_cta38m00.corsus
             let la_aux[l_ind].doc_handle = mr_cts3800.doc_handle

         end foreach

         if  l_ind > 1 then

             open window cta00m11 at 4,2 with form "cta00m13"
                         attribute(form line first,  border)

             call set_count(l_ind)

             message " (F17)Abandona, (F8)Seleciona"

             display array la_item to s_cta00m13.*
                 on key (interrupt)
                     let int_flag = true
                     exit display

                  on key (F8)
                     let l_arr_aux  = arr_curr()

                     let lr_cta38m00.documento = la_aux[l_ind].documento
                     let lr_cta38m00.itmnumdig = la_item[l_arr_aux].itmnumdig
                     let lr_cta38m00.edsnumref = la_aux[l_ind].edsnumref
                     let lr_cta38m00.succod    = la_aux[l_ind].succod
                     let lr_cta38m00.ramcod    = la_aux[l_ind].ramcod
                     let lr_cta38m00.emsdat    = la_aux[l_ind].emsdat
                     let lr_cta38m00.viginc    = la_aux[l_ind].viginc
                     let lr_cta38m00.vigfnl    = la_aux[l_ind].vigfnl
                     let lr_cta38m00.segcod    = la_aux[l_ind].segcod
                     let lr_cta38m00.segnom    = la_aux[l_ind].segnom
                     let lr_veic.vcldes        = la_item[l_ind].vcldes
                     let lr_cta38m00.corsus    = la_aux[l_ind].corsus
                     let mr_cts3800.doc_handle = la_aux[l_ind].doc_handle
                     exit display

             end display

             close window cta00m11

             if  not int_flag then
                 let mr_cts3800.resultado = 1
                 let mr_cts3800.mensagem = 'Apolice encontrada.'
             else
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem = 'Nenhum segurador com esse nome encontrado.'
             end if
         else
             if  l_ind = 1 then
                 let lr_cta38m00.documento = la_aux[1].documento
                 let lr_cta38m00.itmnumdig = la_item[1].itmnumdig
                 let lr_cta38m00.edsnumref = la_aux[1].edsnumref
                 let lr_cta38m00.succod    = la_aux[1].succod
                 let lr_cta38m00.ramcod    = la_aux[1].ramcod
                 let lr_cta38m00.emsdat    = la_aux[1].emsdat
                 let lr_cta38m00.viginc    = la_aux[1].viginc
                 let lr_cta38m00.vigfnl    = la_aux[1].vigfnl
                 let lr_cta38m00.segcod    = la_aux[1].segcod
                 let lr_cta38m00.segnom    = la_aux[1].segnom
                 let lr_veic.vcldes        = la_item[1].vcldes
                 let lr_cta38m00.corsus    = la_aux[1].corsus
                 let mr_cts3800.doc_handle = la_aux[1].doc_handle
             else
                 let mr_cts3800.resultado = 2
                 let mr_cts3800.mensagem = 'Nenhum segurador com esse nome encontrado.'
             end if
         end if
     else
         if  sqlca.sqlcode = notfound then
             let mr_cts3800.resultado = 2
             let mr_cts3800.mensagem = "Apolice nao cadastrada."
         else
             let mr_cts3800.resultado = sqlca.sqlcode
             let mr_cts3800.mensagem = "ERRO", sqlca.sqlcode
         end if
     end if

 return lr_cta38m00.documento,
        lr_cta38m00.itmnumdig,
        lr_cta38m00.edsnumref,
        lr_cta38m00.succod,
        lr_cta38m00.ramcod,
        lr_cta38m00.emsdat,
        lr_cta38m00.viginc,
        lr_cta38m00.vigfnl,
        lr_cta38m00.segcod,
        lr_cta38m00.segnom,
        lr_veic.vcldes,
        lr_cta38m00.corsus,
        mr_cts3800.doc_handle,
        mr_cts3800.resultado,
        mr_cts3800.mensagem,
        lr_cta38m00.situacao

 end function

#-----------------------------------------------------#
 function cts38m00_extrai_origemcalculo(l_doc_handle)
#-----------------------------------------------------#

     define l_doc_handle integer

     define lr_origem  record
            calculo char(5),
            descr    char(30)
     end record

     initialize lr_origem.* to null

     let lr_origem.calculo    = figrc011_xpath(l_doc_handle, "/APOLICE/ORIGEMCALCULO/CODIGO")
     let lr_origem.descr      = figrc011_xpath(l_doc_handle, "/APOLICE/ORIGEMCALCULO/DESCRICAO")

     return lr_origem.*

 end function

#------------------------------------------------#
 function cts38m00_extrai_classe_localizacao(l_doc_handle)
#------------------------------------------------#
     define l_doc_handle     integer
          , l_clalclcod      like abbmdoc.clalclcod

     let l_clalclcod = null

     let l_clalclcod    = figrc011_xpath(l_doc_handle, "/APOLICE/VEICULO/CLASSELOCALIZACAO/CODIGO")

     return l_clalclcod

 end function
 #-----------------------------------------------------#
  function cts38m00_extrai_proposta(l_doc_handle)
 #-----------------------------------------------------#
      define l_doc_handle integer
      define lr_origem  record
             prporg integer,
             prpnum integer
      end record
      initialize lr_origem.* to null
      let lr_origem.prporg    = figrc011_xpath(l_doc_handle, "/APOLICE/PROPOSTA/ORIGEM")
      let lr_origem.prpnum    = figrc011_xpath(l_doc_handle, "/APOLICE/PROPOSTA/NUMERO")
      return lr_origem.*
  end function