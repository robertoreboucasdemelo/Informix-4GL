#############################################################################
# Nome do Modulo: CTS00M06                                            Pedro #
#                                                                   Marcelo #
# Localiza Laudo de Servico (RADIO)                                Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 26/04/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
#                                       ma etapa do servico.                #
#---------------------------------------------------------------------------#
# 09/12/1999               Gilberto     Fazer leitura "suja".               #
#---------------------------------------------------------------------------#
# 14/06/2000  PSI 10865-0  Ruiz         Alteracao do tamanho do campo       #
#                                       atdsrvnum de 6 p/ 10.               #
#                                       Troca do campo atdtip p/ atdsrvorg. #
#---------------------------------------------------------------------------#
# 08/05/2012 Ivan, BRQ PSI-2011-22603 Projeto alteracao cadastro de destino #
#---------------------------------------------------------------------------#
# 13/11/2012 Burini    PSI-2012-28815/EV Melhorias na tela de Acompanhamento#
#---------------------------------------------------------------------------#
# 15/05/2012 Alberto   PSI-2012-22101  SAPS Chamada cty27g00_pesq_prp       #
#                                      para Carrgegar Gloabais SAPS         #
#---------------------------------------------------------------------------#

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep smallint

function cts00m06_prepare()

define l_sql char(200)

let l_sql = null

let l_sql = "select sinntzdes      ",
                     "  from sgaknatur      ",
                     " where sinramgrp = '4'",
                     "   and sinntzcod = ?  "

   prepare p_cts00m06_001 from l_sql
   declare c_cts00m06_001 cursor for p_cts00m06_001
   let l_sql = 'select atdsrvorg, atdetpcod '
              ,'  from datmservico '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
   prepare p_cts00m06_003 from l_sql
   declare c_cts00m06_003 cursor for p_cts00m06_003
let m_prep = true
end function

#----------------------------------------------------------------------
 function cts00m06()
#----------------------------------------------------------------------

 define d_cts00m06    record
    atdsrvorg_a       like datmservico.atdsrvorg  ,
    atdsrvnum         like datmservico.atdsrvnum  ,
    atdsrvano         like datmservico.atdsrvano  ,
    atddat            like datmservico.atddat     ,
    atdsrvorg         like datmservico.atdsrvorg  ,
    srvtipabvdes      like datksrvtip.srvtipabvdes,
    vcllicnum         like datmservico.vcllicnum  ,
    nome              char (30),
    atdvclsgl         like datkveiculo.atdvclsgl  ,
    pstcoddig         like datkveiculo.pstcoddig  ,
    nomgrr            like dpaksocor.nomgrr,
    ciaempcod         like gabkemp.empcod,
    empnom            like gabkemp.empsgl
 end record

 define a_cts00m06    array[3000] of record
    servico2          char (13)                   ,
    nom               like datmservico.nom        ,
    atdetpdes         like datketapa.atdetpdes    ,
    srvtipdes         like datksrvtip.srvtipabvdes,
    vcldes            like datmservico.vcldes     ,
    vcllicnum2        like datmservico.vcllicnum
 end record

 define arr_aux       smallint
 define scr_aux       smallint
 define aux_ano4      char(04)

 define ws            record
    acao              char (03)                    ,
    nome              char (15)                    ,
    total             char (11)                    ,
    comando1          char (900)                   ,
    comando2          char (300)                   ,
    retflg            dec (1,0)                    ,
    atdsrvorg         like datmservico.atdsrvorg   ,
    atdsrvnum         like datmservico.atdsrvnum   ,
    atdsrvano         like datmservico.atdsrvano   ,
    socntzcod         like datmsrvre.socntzcod     ,
    sinntzcod         like datmsrvre.sinntzcod     ,
    atdetpcod         like datmsrvacp.atdetpcod    ,
    refatdsrvnum      like datmsrvjit.refatdsrvnum ,
    refatdsrvano      like datmsrvjit.refatdsrvano ,
    atdsrvseq         like datmservico.atdsrvseq   ,
    succod            like datrservapol.succod     ,
    ramcod            like datrservapol.ramcod     ,
    aplnumdig         like datrservapol.aplnumdig  ,
    itmnumdig         like datrservapol.itmnumdig  ,
    crtnum            like datrsrvsau.crtnum
 end record

 define	w_pf1	      integer,
        l_resultado smallint,
        l_mensagem  char(50),
        l_c24txtseq like datmservhist.c24txtseq,
        i           smallint

 define l_socvclcod like datkveiculo.socvclcod,
        l_socvclarr char(200)

 define l_sql char(200)


	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  3000
		initialize  a_cts00m06[w_pf1].*  to  null
	end	for

	initialize  d_cts00m06.*  to  null

	initialize  ws.*  to  null

 open window w_cts00m06 at 04,02 with form "cts00m06"
                        attribute(form line first)
 display "-" at 03,21

 while true

   clear form
   initialize ws.*          to null
   initialize a_cts00m06    to null
   initialize g_documento.* to null
   let int_flag = false
   let arr_aux  = 1
   input by name d_cts00m06.atdsrvnum,
                 d_cts00m06.atdsrvano,
                 d_cts00m06.atddat,
                 d_cts00m06.atdsrvorg,
                 d_cts00m06.vcllicnum,
                 d_cts00m06.nome,
                 d_cts00m06.atdvclsgl,
                 d_cts00m06.pstcoddig,
                 d_cts00m06.ciaempcod
      before field atdsrvnum
         display by name d_cts00m06.atdsrvnum  attribute (reverse)

      after  field atdsrvnum
         display by name d_cts00m06.atdsrvnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if d_cts00m06.atdsrvnum is null    then
            next field atddat
         end if

      before field atdsrvano
         display by name d_cts00m06.atdsrvano  attribute (reverse)

      after  field atdsrvano
         display by name d_cts00m06.atdsrvano

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field atdsrvnum
         end if

         if d_cts00m06.atdsrvano   is null      and
            d_cts00m06.atdsrvnum   is not null  then
            error " Informe o ano do servico!"
            next field atdsrvano
         end if

         if d_cts00m06.atdsrvano   is not null   and
            d_cts00m06.atdsrvnum   is null       then
            error " Informe o numero do servico!"
            next field atdsrvnum
         end if

          select atdsrvorg
            into d_cts00m06.atdsrvorg_a
            from datmservico
           where atdsrvnum = d_cts00m06.atdsrvnum
             and atdsrvano = d_cts00m06.atdsrvano

        #if d_cts00m06.atdsrvorg_a = 11 then
        #   error " Vistoria de sinistro deve ser consultada no modulo Vistoria!"
        #   next field atdsrvnum
        #end if

         if d_cts00m06.atdsrvorg_a  =  10    then
            error " Vistoria Previa deve ser consultada no modulo Vist_Previa!"
            next field atdsrvnum
         end if

         display "/" at 03,13
         display by name d_cts00m06.atdsrvorg_a

         if d_cts00m06.atdsrvnum  is not null   and
            d_cts00m06.atdsrvano  is not null   then
            exit input
         end if

      before field atddat
         display by name d_cts00m06.atddat    attribute (reverse)

         let d_cts00m06.atddat = today

      after  field atddat
         display by name d_cts00m06.atddat

         if d_cts00m06.atddat  is null   then
            error " Informe a data do atendimento do servico!"
            next field atddat
         end if

      before field atdsrvorg
         initialize d_cts00m06.srvtipabvdes to null
         display by name d_cts00m06.srvtipabvdes
         display by name d_cts00m06.atdsrvorg attribute (reverse)

      after  field atdsrvorg
         display by name d_cts00m06.atdsrvorg

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cts00m06.atdsrvorg to null
            display by name d_cts00m06.atdsrvorg
            next field atddat
         end if

         if d_cts00m06.atdsrvorg  is not null   then
            select srvtipabvdes
              into d_cts00m06.srvtipabvdes
              from datksrvtip
             where atdsrvorg = d_cts00m06.atdsrvorg

            if sqlca.sqlcode = notfound  then
               error " Tipo de servico nao cadastrado!"
               call cts00m09() returning d_cts00m06.atdsrvorg
               next field atdsrvorg
            end if
            display by name d_cts00m06.srvtipabvdes

               if d_cts00m06.atdsrvorg  =  10    then
               error " Vistoria Previa deve ser consultada no modulo Vist_Previa!"
               next field atdsrvorg
            end if
         end if

      before field vcllicnum
         display by name d_cts00m06.vcllicnum attribute (reverse)

      after field vcllicnum
         display by name d_cts00m06.vcllicnum

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cts00m06.vcllicnum  to null
            display by name d_cts00m06.vcllicnum
            next field atdsrvorg
         end if

         if d_cts00m06.vcllicnum  is not null   then
            initialize d_cts00m06.nome  to null
            display by name d_cts00m06.nome

            if not srp1415(d_cts00m06.vcllicnum)  then
               error " Placa invalida!"
               next field  vcllicnum
            end if
            exit input
         end if

      before field nome
         display by name d_cts00m06.nome    attribute (reverse)

      after field nome
         display by name d_cts00m06.nome

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cts00m06.nome  to null
            display by name d_cts00m06.nome
            next field vcllicnum
         end if

         initialize ws.nome to null
         if d_cts00m06.nome is not null then
            let ws.nome = d_cts00m06.nome clipped, "*"
            exit input
         #else
         #   if d_cts00m06.atdsrvorg  is null   then
         #      error " Informe: servico, tipo do servico, placa ou nome!"
         #      next field nome
         #   end if
         end if

      before field atdvclsgl
         display by name d_cts00m06.atdvclsgl attribute(reverse)

      after field atdvclsgl
         display by name d_cts00m06.atdvclsgl

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cts00m06.atdvclsgl to null
            display by name d_cts00m06.atdvclsgl
            next field nome
         end if

         if d_cts00m06.atdvclsgl is not null then
            let l_socvclarr = null
            declare cq_datkveiculo cursor for
             select socvclcod
               from datkveiculo
              where atdvclsgl = d_cts00m06.atdvclsgl
            foreach cq_datkveiculo into l_socvclcod
                if l_socvclarr is null then
                   let l_socvclarr = l_socvclcod clipped
                else
                   let l_socvclarr = l_socvclarr clipped, ",", l_socvclcod clipped
                end if
            end foreach
            if l_socvclarr is null then
               error " Sigla nao cadastrada!"
               next field atdvclsgl
            end if
         end if

      before field pstcoddig
         display by name d_cts00m06.pstcoddig attribute(reverse)

      after field pstcoddig
         display by name d_cts00m06.pstcoddig

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            initialize d_cts00m06.pstcoddig to null
            display by name d_cts00m06.pstcoddig
            next field atdvclsgl
         end if

         if d_cts00m06.pstcoddig is not null then
         #   error " Informe: servico, data, tipo servico, placa, nome, sigla veiculo ou prestador!"
         #   next field pstcoddig
         #else
            select nomgrr into d_cts00m06.nomgrr
              from dpaksocor
             where pstcoddig = d_cts00m06.pstcoddig
            if sqlca.sqlcode = 0 then
               display by name d_cts00m06.nomgrr
            else
               let d_cts00m06.nomgrr = null
               display by name d_cts00m06.nomgrr
               error " Prestador nao cadastrado!"
               next field pstcoddig
            end if
         end if
      after field ciaempcod
         if d_cts00m06.ciaempcod is null then
            call cty14g00_popup_empresa()
                 returning l_resultado, d_cts00m06.ciaempcod,
                           d_cts00m06.empnom

            display by name d_cts00m06.ciaempcod attribute (reverse)
            display by name d_cts00m06.empnom attribute (reverse)
         else

            ##if d_cts00m06.ciaempcod <> 1  and
            ##   d_cts00m06.ciaempcod <> 27  and
            ##   d_cts00m06.ciaempcod <> 35 and
            ##   d_cts00m06.ciaempcod <> 40 then
            ##   error "Informe a empresa: 1-Porto, 35-Azul ou 40-PortoSeg"
            ##   next field ciaempcod
            ##end if

            call cty14g00_empresa(1, d_cts00m06.ciaempcod)
                 returning l_resultado, l_mensagem,  d_cts00m06.empnom

            if l_resultado <> 1 then
               error l_mensagem
               next field ciaempcod
            end if
         end if

         if  d_cts00m06.ciaempcod is null then
             let d_cts00m06.empnom = 'TODAS'
         end if
         display by name d_cts00m06.ciaempcod attribute (reverse)
         display by name d_cts00m06.empnom attribute (reverse)
         if  d_cts00m06.atddat    is null and
             d_cts00m06.atdsrvano is null and
             d_cts00m06.atdsrvnum is null and
             d_cts00m06.atdsrvorg is null and
             d_cts00m06.vcllicnum is null and
             d_cts00m06.nome      is null and
             d_cts00m06.atdvclsgl is null and
             d_cts00m06.pstcoddig is null and
             d_cts00m06.ciaempcod is null then
             error " Informe: servico, data, tipo servico, placa, nome, sigla veiculo, prestador ou empresa!"
             next field atdsrvnum
         end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if


#------------------------------
# Select para identificar a empresa do servico
#------------------------------

let l_sql = "select ciaempcod ",
	     "  from datmservico ",
	     " where atdsrvnum = ? ",
	     "   and atdsrvano = ?  "

   prepare p_cts00m06_002 from l_sql
   declare c_cts00m06_002 cursor for p_cts00m06_002


      open c_cts00m06_002 using d_cts00m06.atdsrvnum,
                          d_cts00m06.atdsrvano

      fetch c_cts00m06_002 into g_documento.ciaempcod


      close c_cts00m06_002


#----------------------------------------------------------------------
# Definicao da condicao de pesquisa
#----------------------------------------------------------------------

   if d_cts00m06.atdsrvnum is not null then
      let ws.comando2 = " from datmservico ",
                       " where datmservico.atdsrvnum = ? ",
                       "   and datmservico.atdsrvano = ? "
   else
      if d_cts00m06.atdvclsgl is not null or
         d_cts00m06.pstcoddig is not null then
         let ws.comando2 = " from datmservico, datmsrvacp ",
                          " where datmservico.atdsrvnum = datmsrvacp.atdsrvnum ",
                          "   and datmservico.atdsrvano = datmsrvacp.atdsrvano ",
                          "   and datmsrvacp.atdetpdat = ? "
      else
         let ws.comando2 = " from datmservico ",
                          " where datmservico.atddat = ? "
      end if

      if d_cts00m06.atdsrvorg is not null then
         let ws.comando2 = ws.comando2 clipped,
                           " and datmservico.atdsrvorg = ? "
      else
         let ws.comando2 = ws.comando2 clipped,
                           " and datmservico.atdsrvorg <> 10 ",
                           " and datmservico.atdsrvorg <> 12 "
      end if

      if d_cts00m06.nome is not null then
         let ws.comando2 = ws.comando2 clipped,
                           " and datmservico.nom matches '", ws.nome, "'"
      else
         if d_cts00m06.vcllicnum is not null then
            let ws.comando2 = ws.comando2 clipped,
                              " and datmservico.vcllicnum = ? "
         else
            if d_cts00m06.atdvclsgl is not null then
               let ws.comando2 = ws.comando2 clipped,
                                 " and datmsrvacp.socvclcod in (?) "
            else
               if d_cts00m06.pstcoddig is not null then
                  let ws.comando2 = ws.comando2 clipped,
                                    " and datmsrvacp.pstcoddig = ? "
               end if
            end if
         end if
      end if
      if  d_cts00m06.ciaempcod is not null then
          let ws.comando2 = ws.comando2 clipped,
                  " and datmservico.ciaempcod = ? "
      end if
   end if

   let ws.comando1 = " select                 ",
                     " datmservico.atdsrvnum, ",
                     " datmservico.atdsrvano, ",
                     " datmservico.nom      , ",
                     " datmservico.vcldes   , ",
                     " datmservico.vcllicnum, ",
                     " datmservico.atdsrvorg  ",
                     ws.comando2 clipped


   set isolation to dirty read

   message " Aguarde, pesquisando..."  attribute(reverse)
   prepare sel_servico from ws.comando1
   declare c_cts00m06 cursor for sel_servico

#----------------------------------------------------------------------
# Preparacao dos comandos SQL
#----------------------------------------------------------------------
   let ws.comando1 = "select srvtipabvdes",
                     "  from datksrvtip  ",
                     " where atdsrvorg = ?  "

   prepare sel_datksrvtip  from ws.comando1
   declare c_datksrvtip cursor for sel_datksrvtip

   let ws.comando1 = "select socntzcod, sinntzcod",
                     "  from datmsrvre           ",
                     " where atdsrvnum = ?    and",
                     "       atdsrvano = ?       "

   prepare sel_datmsrvre from ws.comando1
   declare c_datmsrvre cursor for sel_datmsrvre

   let ws.comando1 = "select socntzdes    ",
                     "  from datksocntz   ",
                     " where socntzcod = ?"

   prepare sel_datksocntz from ws.comando1
   declare c_datksocntz cursor for sel_datksocntz









   let ws.comando1 = "select atdetpdes    ",
                     "  from datketapa    ",
                     " where atdetpcod = ?"

   prepare sel_datketapa from ws.comando1
   declare c_datketapa cursor for sel_datketapa

   let ws.comando1 = "select atdetpcod    ",
                     "  from datmsrvacp   ",
                     " where atdsrvnum = ?",
                     "   and atdsrvano = ?",
                     "   and atdsrvseq = (select max(atdsrvseq)",
                                         "  from datmsrvacp    ",
                                         " where atdsrvnum = ? ",
                                         "   and atdsrvano = ?)"

   prepare sel_datmsrvacp from ws.comando1
   declare c_datmsrvacp cursor for sel_datmsrvacp

   if d_cts00m06.atdsrvnum  is not null   then
      open c_cts00m06  using d_cts00m06.atdsrvnum, d_cts00m06.atdsrvano
   else
      if d_cts00m06.vcllicnum  is not null   then
         if d_cts00m06.atdsrvorg  is not null   then
            open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg,
                                   d_cts00m06.vcllicnum
         else
            open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.vcllicnum
         end if
      else
         if d_cts00m06.atdvclsgl is not null or
            d_cts00m06.pstcoddig is not null then
            if d_cts00m06.atdvclsgl is not null then
               if d_cts00m06.atdsrvorg  is not null   then
                  if  d_cts00m06.ciaempcod is not null then
                      open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg, l_socvclarr, d_cts00m06.ciaempcod
                  else
                      open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg, l_socvclarr
                  end if
               else
                  if  d_cts00m06.ciaempcod is not null then
                      open c_cts00m06  using d_cts00m06.atddat, l_socvclarr, d_cts00m06.ciaempcod
                  else
                      open c_cts00m06  using d_cts00m06.atddat, l_socvclarr
                  end if
               end if
            else
               if d_cts00m06.atdsrvorg  is not null   then
                  if  d_cts00m06.ciaempcod is not null then
                      open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg, d_cts00m06.pstcoddig, d_cts00m06.ciaempcod
                  else
                      open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg, d_cts00m06.pstcoddig
                  end if
               else
                  if  d_cts00m06.ciaempcod is not null then
                      open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.pstcoddig, d_cts00m06.ciaempcod
                  else
                      open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.pstcoddig
                  end if
               end if
            end if
         else
            if d_cts00m06.atdsrvorg  is not null   then
               if  d_cts00m06.ciaempcod is not null then
                   open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg, d_cts00m06.ciaempcod
               else
                   open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.atdsrvorg
               end if
            else
               if  d_cts00m06.ciaempcod is not null then
                   open c_cts00m06  using d_cts00m06.atddat, d_cts00m06.ciaempcod
               else
                   open c_cts00m06  using d_cts00m06.atddat
               end if
            end if
         end if
      end if
   end if

   foreach  c_cts00m06  into  ws.atdsrvnum                  ,
                              ws.atdsrvano                  ,
                              a_cts00m06[arr_aux].nom       ,
                              a_cts00m06[arr_aux].vcldes    ,
                              a_cts00m06[arr_aux].vcllicnum2,
                              ws.atdsrvorg

      let a_cts00m06[arr_aux].servico2 =  F_FUNDIGIT_INTTOSTR(ws.atdsrvorg,2),
                                     "/", F_FUNDIGIT_INTTOSTR(ws.atdsrvnum,7),
                                     "-", F_FUNDIGIT_INTTOSTR(ws.atdsrvano,2)

      open  c_datmsrvacp using ws.atdsrvnum, ws.atdsrvano,
                               ws.atdsrvnum, ws.atdsrvano
      fetch c_datmsrvacp into  ws.atdetpcod

      if sqlca.sqlcode = 0  then
         open  c_datketapa using ws.atdetpcod
         fetch c_datketapa into  a_cts00m06[arr_aux].atdetpdes
         close c_datketapa
      end if

      close c_datmsrvacp

      let a_cts00m06[arr_aux].srvtipdes = "NAO PREV."

      open  c_datksrvtip using ws.atdsrvorg
      fetch c_datksrvtip into  a_cts00m06[arr_aux].srvtipdes
      close c_datksrvtip

      if ws.atdsrvorg = 15   then
         whenever error continue
           select refatdsrvnum,
                  refatdsrvano
                into ws.refatdsrvnum,
                     ws.refatdsrvano
                from datmsrvjit
             where atdsrvnum = ws.atdsrvnum
               and atdsrvano = ws.atdsrvano

            let aux_ano4 = "20" clipped , ws.refatdsrvano using "&&"
            select sinvstnum from datmpedvist
             where sinvstnum = ws.refatdsrvnum
               and sinvstano = aux_ano4
         whenever error stop
         if sqlca.sqlcode <> notfound then
            let a_cts00m06[arr_aux].srvtipdes = "JIT-RE"
         end if
      end if

      if ws.atdsrvorg =  9   or
         ws.atdsrvorg =  13  then
         open  c_datmsrvre using ws.atdsrvnum, ws.atdsrvano
         fetch c_datmsrvre into  ws.socntzcod, ws.sinntzcod
         close c_datmsrvre

         if m_prep is null or
            m_prep <> " " then
            call cts00m06_prepare()
         end if
         if ws.socntzcod is not null  then
            open  c_datksocntz using ws.socntzcod
            fetch c_datksocntz into  a_cts00m06[arr_aux].vcldes
            close c_datksocntz
         else
            open  c_cts00m06_001 using ws.sinntzcod
            fetch c_cts00m06_001 into  a_cts00m06[arr_aux].vcldes
            close c_cts00m06_001
         end if
      end if

      let arr_aux = arr_aux + 1
      if arr_aux > 3000  then
         error " Limite excedido, pesquisa com mais de 3000 servicos!"
         exit foreach
      end if

   end foreach

   if arr_aux  =  1   then
      error " Nao existem servicos para pesquisa!"
   end if

   let ws.total = "Total: ", arr_aux - 1  using "&&&&"

   display by name ws.total attribute (reverse)
   if ctx34g00_ver_acionamentoWEB(2) then
      message " (F17)Abandona, (F8)Seleciona, (F9)Sincroniza AcionamentoWeb, (F7)Ligacoes"
   else
      message " (F17)Abandona, (F8)Seleciona, (F7)Ligacoes "
   end if

   call set_count(arr_aux-1)

   display array  a_cts00m06 to s_cts00m06.*
      on key(interrupt)
         initialize ws.total to null
         display by name ws.total
         exit display

      on key (F8)    ##--- Consulta laudo servico ---
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         let g_documento.atdsrvnum = a_cts00m06[arr_aux].servico2[04,10]
         let g_documento.atdsrvano = a_cts00m06[arr_aux].servico2[12,13]

         if not m_prep then
            call cts00m06_prepare()
         end if
         open c_cts00m06_003 using g_documento.atdsrvnum,
                                   g_documento.atdsrvano
         fetch c_cts00m06_003 into ws.atdsrvorg, ws.atdetpcod
         close c_cts00m06_003
         if ws.atdetpcod = 5 and ws.atdsrvorg = 8 then
            let g_documento.acao = 'CON'
         else
            let g_documento.acao = "ALT"
         end if
         call cty27g00_pesq_prp(g_documento.atdsrvnum,g_documento.atdsrvano) # Carrgegar Gloabais SAPS
         display a_cts00m06[arr_aux].servico2  to
                 s_cts00m06[scr_aux].servico2  attribute(reverse)

         call cts04g00('cts00m06') returning ws.retflg

         display a_cts00m06[arr_aux].servico2  to
                 s_cts00m06[scr_aux].servico2

      on key (F9)    ##--- Envia Servico para o AcionamentoWeb ---
         if ctx34g00_ver_acionamentoWEB(2) then
            let arr_aux = arr_curr()
            let scr_aux = scr_line()
            let g_documento.atdsrvnum = a_cts00m06[arr_aux].servico2[04,10]
            let g_documento.atdsrvano = a_cts00m06[arr_aux].servico2[12,13]

            display a_cts00m06[arr_aux].servico2  to
                    s_cts00m06[scr_aux].servico2  attribute(reverse)

            error 'Enviando Servico para o AcionamentoWeb...'

            
            call ctx34g02_apos_grvservico(g_documento.atdsrvnum,
                                          g_documento.atdsrvano)

            
            error ''

            display a_cts00m06[arr_aux].servico2  to
                    s_cts00m06[scr_aux].servico2
         end if

      on key (F7)    ##--- Consulta Ligações ---

         options comment line last

         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         let g_documento.atdsrvnum = a_cts00m06[arr_aux].servico2[04,10]
         let g_documento.atdsrvano = a_cts00m06[arr_aux].servico2[12,13]

         initialize g_documento.succod    to null
         initialize g_documento.ramcod    to null
         initialize g_documento.aplnumdig to null
         initialize g_documento.itmnumdig to null
         let ws.succod    = null
         let ws.ramcod    = null
         let ws.aplnumdig = null
         let ws.itmnumdig = null
         let ws.crtnum    = null

         select succod   ,
                ramcod   ,
                aplnumdig,
                itmnumdig
           into ws.succod   ,
                ws.ramcod   ,
                ws.aplnumdig,
                ws.itmnumdig
           from datrservapol
          where atdsrvnum = g_documento.atdsrvnum
            and atdsrvano = g_documento.atdsrvano

         if sqlca.sqlcode <> 0  then
            select succod  ,
                   ramcod  ,
                   aplnumdig ,
                   crtnum
              into ws.succod,
                   ws.ramcod,
                   ws.aplnumdig,
                   ws.crtnum
             from datrsrvsau
            where atdsrvnum = g_documento.atdsrvnum
              and atdsrvano = g_documento.atdsrvano
            if sqlca.sqlcode <> 0  then
               error " Nao e' possivel consultar ligacoes para servico sem documento informado!"
            end if
         else
#           call cta02m02(ws.succod, ws.ramcod, ws.aplnumdig, ws.itmnumdig, "", "", "", "")
            call cta02m02_consultar_ligacoes(ws.succod   , ws.ramcod,
                                             ws.aplnumdig, ws.itmnumdig,
                                             '', '',
                                             '', '',
                                             '', '',
                                             '', '',
                                             '', '',
                                             '', '',
                                             '', '',
                                             '', '',
                                             ws.crtnum,"","")
         end if

         options comment line 07

   end display

   for scr_aux = 1 to 4
      clear s_cts00m06[scr_aux].servico2
      clear s_cts00m06[scr_aux].srvtipdes
      clear s_cts00m06[scr_aux].nom
      clear s_cts00m06[scr_aux].atdetpdes
      clear s_cts00m06[scr_aux].vcldes
      clear s_cts00m06[scr_aux].vcllicnum2
   end for

 end while

 set isolation to committed read

 let int_flag = false
 close window w_cts00m06

end function  ###  cts00m06
