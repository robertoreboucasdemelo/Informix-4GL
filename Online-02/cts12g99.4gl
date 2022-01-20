#---------------------------------------------------------------------    #
# Porto Seguro Cia Seguros Gerais                                         #
# ....................................................................    #
# Sistema       : Central 24h                                             #
# Modulo        : cts12g99                                                #
# Analista Resp.: Alberto Rodrigues                                       #
# PSI           : 219444                                                  #
# Objetivo      : Natureza RE                                             #
#.....................................................................    #
# Desenvolvimento: Amilton , META                                         #
# Liberacao      :                                                        #
#.....................................................................    #
#                                                                         #
#                  * * * Alteracoes * * *                                 #
#                                                                         #
# Data        Autor Fabrica  Origem    Alteracao                          #
# ----------  -------------- --------- ------------------------------     #
# 03/11/2010  Carla Rampazzo PSI 00762 Tratamento para Help Desk Casa     #
#-------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/framg001.4gl"


define mr_servicos   array[500] of record
       socntzcod     like datksocntz.socntzcod
      ,socntzdes     char(50)
      ,ageatdqtd     integer
      ,atdqtd        like rgfrclsemrsrv.atdqtd
      ,utlatdqtd     integer
      ,vl_mercado    like rgfrclsemrsrv.mrccst
end record


define mr_clausulas  array[20] of record
       clscod        like rsdmclaus.clscod
      ,limite        like rgfmrmeclsftr.clsindmaxlmt
      ,utllmi        decimal(15,5)
      ,agelmi        decimal(15,5)
      ,ageatdqtd     integer
      ,clsatdqtd     like rgfmrmeclsftr.clsatdqtd
      ,utlatdqtd     integer
end record


define t_cts12g99    array[500] of record
       socntzcod     like datksocntz.socntzcod
      ,socntzdes     char(50)
      ,vrlqtd        char(10)
      ,tipo          char(1)
end record

define m_prep smallint

#--------------------------------------------------------------------------
function cts12g99_prepare()
#--------------------------------------------------------------------------

   define l_sql char(1000)

   let l_sql = null

   let l_sql = "select count(*) ",
               " from datrgrpntz a, datksocntz b , datrempgrp c ",
               " where a.socntzcod = b.socntzcod ",
               " and  a.socntzgrpcod = c.socntzgrpcod ",
               " and b.socntzstt    = 'A'",
               " and c.empcod = ? ",
               " and c.c24astcod = ?" ,
               " and b.socntzcod = ?"
   prepare pcts12g99001 from l_sql
   declare ccts12g99001 cursor for pcts12g99001

   let l_sql = "select Count(*) ",
                        "  from datksocntz          ",
                        " where socntzstt = 'A'     ",
                        " and socntzgrpcod = ? ",
                        " and socntzcod = ? "
   prepare pcts12g99002 from l_sql
   declare ccts12g99002 cursor for pcts12g99002

   let l_sql = "select b.socntzcod,b.socntzcod,b.socntzdes,0,0,70,'03',0,0 ",
               " from datrgrpntz a, datksocntz b , datrempgrp c ",
               " where a.socntzcod = b.socntzcod ",
               " and  a.socntzgrpcod = c.socntzgrpcod ",
               " and b.socntzstt    = 'A'",
               " and c.empcod = ? ",
               " and c.c24astcod = ?",
               " order by b.socntzdes"
   prepare pcts12g99003 from l_sql
   declare ccts12g99003 cursor for pcts12g99003

   #----------------------------------------------
   --> Buscar Naturezas Cadastradas para Help Desk
   #----------------------------------------------
   let l_sql = " select cpodes "
                ," from datkdominio "
               ," where cponom = 'natureza_hdk' "
   prepare pcts12g99004 from l_sql
   declare ccts12g99004 cursor for pcts12g99004

  let m_prep = true

end function


#--------------------------------------------------------------------------
function cts12g99(lr_param)
#--------------------------------------------------------------------------

   define lr_param     record
          succod       like datrservapol.succod
         ,ramcod       like datrservapol.ramcod
         ,aplnumdig    like datrservapol.aplnumdig
         ,prporg       like datrligprp.prporg
         ,prpnumdig    like datrligprp.prpnumdig
         ,lclnumseq    like rsdmlocal.lclnumseq
         ,rmerscseq    like datmsrvre.rmerscseq
         ,c24astcod    like datkassunto.c24astcod
         ,socntzgrpcod like datrgrpntz.socntzgrpcod
   end record

   define lr_retorno   record
          sqlcode      integer
         ,msgerro      char(500)
         ,socntzcod    like datksocntz.socntzcod
   end record

   define lr_saldo decimal(15,5)

   initialize lr_retorno.* to null


   if g_saldo_re.saldo is null then

      call cts12g99_verifica_saldo(lr_param.succod
                                  ,lr_param.ramcod
                                  ,lr_param.aplnumdig
                                  ,lr_param.prporg
                                  ,lr_param.prpnumdig
                                  ,lr_param.lclnumseq
                                  ,lr_param.rmerscseq
                                  ,lr_param.c24astcod)
                         returning lr_retorno.sqlcode
                                  ,lr_retorno.msgerro

      if lr_retorno.sqlcode = 0 then

         call cts12g99_carrega_tela(lr_param.succod
                                   ,lr_param.ramcod
                                   ,lr_param.aplnumdig
                                   ,lr_param.prporg
                                   ,lr_param.prpnumdig
                                   ,lr_param.lclnumseq
                                   ,lr_param.rmerscseq
                                   ,lr_param.c24astcod
                                   ,lr_param.socntzgrpcod)
                          returning lr_retorno.socntzcod
      end if
   else
      call cts12g99_carrega_tela(lr_param.succod
                                ,lr_param.ramcod
                                ,lr_param.aplnumdig
                                ,lr_param.prporg
                                ,lr_param.prpnumdig
                                ,lr_param.lclnumseq
                                ,lr_param.rmerscseq
                                ,lr_param.c24astcod
                                ,lr_param.socntzgrpcod)
                       returning lr_retorno.socntzcod
   end if

   return lr_retorno.socntzcod

end function

#--------------------------------------------------------------------------
function cts12g99_verifica_natureza(lr_param)
#--------------------------------------------------------------------------

   define lr_param       record
          socntzcod      like datksocntz.socntzcod
         ,c24astcod      like datkassunto.c24astcod
         ,socntzgrpcod   like datrgrpntz.socntzgrpcod
   end record

   define lr_retorno record
          erro    integer
         ,msgerro char(1000)
         ,count   smallint
   end record


   initialize lr_retorno.* to null

   if m_prep = false or
      m_prep = " " then
      call cts12g99_prepare()
   end if

   whenever error continue
   open ccts12g99001 using g_documento.ciaempcod
                          ,lr_param.c24astcod
                          ,lr_param.socntzcod
   fetch ccts12g99001 into lr_retorno.count

   whenever error stop

   if sqlca.sqlcode <> 0 then

      if sqlca.sqlcode = 100 then

         let lr_retorno.erro = sqlca.sqlcode
         let lr_retorno.msgerro = "Natureza (",lr_param.socntzcod clipped
                                 ,"não cadastrada para esse assunto"

         call errorlog(lr_retorno.msgerro)
      else

         let lr_retorno.erro = sqlca.sqlcode
         let lr_retorno.msgerro = " Erro (", lr_retorno.erro clipped ,
                                  " ao tentar localizar natureza DATREMPGRP !"

         call errorlog(lr_retorno.msgerro)
       end if
   end if

   if lr_param.socntzgrpcod is not null and
      lr_retorno.count > 0 then

      whenever error continue
      open  ccts12g99002 using lr_param.socntzgrpcod,
                               lr_param.socntzcod


      fetch ccts12g99002 into lr_retorno.count
      whenever error stop

      if sqlca.sqlcode <> 0 then

         if sqlca.sqlcode = 100 then

            let lr_retorno.erro = sqlca.sqlcode
            let lr_retorno.msgerro = "Natureza (",lr_param.socntzcod clipped ,
                                     "não cadastrada para esse assunto"

            call errorlog(lr_retorno.msgerro)
         else

            let lr_retorno.erro = sqlca.sqlcode
            let lr_retorno.msgerro = " Erro (", lr_retorno.erro clipped ,
                                     " ao tentar localizar natureza DATREMPGRP!"

            call errorlog(lr_retorno.msgerro)
         end if
      end if
   end if

   if lr_retorno.count > 0 then
      let lr_retorno.count = true
   else
      let lr_retorno.count = false
   end if


   return lr_retorno.count

end function

#--------------------------------------------------------------------------
function cts12g99_carrega_tela(lr_param)
#--------------------------------------------------------------------------

   define lr_param     record
          succod       like datrservapol.succod
         ,ramcod       like datrservapol.ramcod
         ,aplnumdig    like datrservapol.aplnumdig
         ,prporg       like datrligprp.prporg
         ,prpnumdig    like datrligprp.prpnumdig
         ,lclnumseq    like rsdmlocal.lclnumseq
         ,rmerscseq    like datmsrvre.rmerscseq
         ,c24astcod    like datkassunto.c24astcod
         ,socntzgrpcod like datrgrpntz.socntzgrpcod
   end record


   define lr_retorno record
          socntzcod like datksocntz.socntzcod
         ,coderro   smallint
         ,msg       char(120)
   end record


   define l_index    integer
         ,l_index2   integer
         ,arr_aux    integer
         ,l_status   smallint
         ,l_natureza smallint
         ,l_assunto  like datkassunto.c24astcod
         ,l_cont     smallint
         ,l_cpodes   char(50)


   let l_index    = 0
   let l_index2   = 0
   let arr_aux    = 0
   let l_status   = false
   let l_natureza = null
   let l_assunto  = null
   let l_cont     = null
   let l_cpodes   = null

   initialize lr_retorno.* to null


   --> inicializando array da tela
   for l_index = 1 to 500
       initialize  t_cts12g99[l_index].* to  null
   end for

   --> inicializando array modular de naturezas
   for l_index = 1 to 500
       initialize  mr_servicos[l_index].* to  null
   end for


   #--------------------------------------------------------------
   --> Carrega globais para modular so com as naturezas do assunto
   #--------------------------------------------------------------
   for l_index = 1 to g_naturezas_re.qtd_eve

      #-----------------------------------------------------
      --> Verifica se a Natureza foi relacionado ao  Assunto
      #-----------------------------------------------------
      call cts12g99_verifica_natureza(ga_framg001_serv[l_index].socntzcod
                                     ,lr_param.c24astcod
                                     ,lr_param.socntzgrpcod)
                            returning l_status

      if l_status = true then

         #---------------------------------------------------------
         --> Verifica se Clausula da direito ao Help Desk - Dominio
         #---------------------------------------------------------
         let l_cont = 0
         open ccts12g99004

         foreach ccts12g99004 into l_cpodes

            let l_assunto  = l_cpodes[10,12]
            let l_natureza = l_cpodes[24,26]

            if lr_param.c24astcod = l_assunto then

               if ga_framg001_serv[l_index].socntzcod = l_natureza then

                  let l_cont = l_cont + 1
                  exit foreach
               else
                  continue foreach
               end if

            else
               continue foreach
            end if
         end foreach

         if lr_param.c24astcod = "S66" or
            lr_param.c24astcod = "S67" or
            lr_param.c24astcod = "S68" or
            lr_param.c24astcod = "S78" then

            if l_cont = 0 then
               continue for
            end if

         else
            if l_cont = 1 then
               continue for
            end if
         end if


         let l_index2 = l_index2 + 1

         let mr_servicos[l_index2].socntzcod  = ga_framg001_serv[l_index].socntzcod
         let mr_servicos[l_index2].socntzdes  = ga_framg001_serv[l_index].rmrsrvdes
         let mr_servicos[l_index2].atdqtd     = ga_framg001_serv[l_index].atdqtd

         let mr_servicos[l_index2].ageatdqtd  = ga_framg001_serv[l_index].ageatdqtd
         let mr_servicos[l_index2].utlatdqtd  = ga_framg001_serv[l_index].utlatdqtd
         let mr_servicos[l_index2].vl_mercado = ga_framg001_serv[l_index].mrccst
      end if
   end for

   #--------------------------------------------
   --> Carrega o array de tela montando o saldo.
   #--------------------------------------------
   for l_index = 1 to l_index2

      let t_cts12g99[l_index].socntzcod = mr_servicos[l_index].socntzcod
      let t_cts12g99[l_index].socntzdes = mr_servicos[l_index].socntzdes

      if mr_servicos[l_index].vl_mercado is not null and
         mr_servicos[l_index].vl_mercado <> 0 then
         let t_cts12g99[l_index].tipo   = "V"
         let t_cts12g99[l_index].vrlqtd =  mr_servicos[l_index].vl_mercado
                                           using "#####&.&&"
      else
         let t_cts12g99[l_index].tipo   = "Q"
         let t_cts12g99[l_index].vrlqtd =  mr_servicos[l_index].atdqtd - (
                                           mr_servicos[l_index].utlatdqtd +
                                           mr_servicos[l_index].ageatdqtd )
                                           using "######-#&"
      end if
   end for


   #--------------
   --> Abre a tela
   #--------------
   open window w_cts12g99 at 07,4 with form "cts12g99"
              attribute(form line 1, border)

   let int_flag = false

   message "           (F1)Tela de Extrato          (F8)Seleciona"

   display by name g_saldo_re.saldo
   display by name g_saldo_re.limite


   call set_count(l_index - 1)

   display array t_cts12g99 to s_cts12g99.*

      on key (F1)

         #-------------------------
         --> Extrato de Utilizacoes
         #-------------------------
         call  framc216(false
                       ,g_documento.succod
                       ,g_documento.ramcod
                       ,g_documento.aplnumdig
                       ,g_documento.prporg
                       ,g_documento.prpnumdig
                       ,g_documento.lclnumseq
                       ,g_documento.rmerscseq)
              returning lr_retorno.coderro
                       ,lr_retorno.msg


      on key (F8)

         let arr_aux = arr_curr()

         if t_cts12g99[arr_aux].tipo = "V" then

            if g_saldo_re.saldo > 0 then
               let lr_retorno.socntzcod = t_cts12g99[arr_aux].socntzcod
               let g_saldo_re.utiliz = t_cts12g99[arr_aux].vrlqtd
            else
               error "QUANTIDADE DE SERVIÇOS JÁ ESGOTADOS PARA A NATUREZA SELECIONADA" sleep 2
            end if
            exit display

         else
            if t_cts12g99[arr_aux].vrlqtd > 0 then
               let lr_retorno.socntzcod = t_cts12g99[arr_aux].socntzcod
            else
               error "QUANTIDADE DE SERVIÇOS JÁ ESGOTADOS PARA A NATUREZA SELECIONADA" sleep 2
            end if
            exit display
         end if

      on key (interrupt,control-c,f17)
            exit display

   end display

   close window  w_cts12g99

   let int_flag = false

   return lr_retorno.socntzcod

end function


#--------------------------------------------------------------------------
function cts12g99_verifica_saldo(lr_param)
#--------------------------------------------------------------------------

   define lr_param     record
          succod       like datrservapol.succod
         ,ramcod       like datrservapol.ramcod
         ,aplnumdig    like datrservapol.aplnumdig
         ,prporg       like datrligprp.prporg
         ,prpnumdig    like datrligprp.prpnumdig
         ,lclnumseq    like rsdmlocal.lclnumseq
         ,rmerscseq    like datmsrvre.rmerscseq
         ,c24astcod    like datkassunto.c24astcod
   end record

   define lr_retorno   record
          sqlcode      integer
         ,msgerro      char(500)
         ,socntzcod    like datksocntz.socntzcod
   end record


   define l_limite    decimal(15,5)
         ,l_saldo     integer
         ,l_util      decimal(15,5)
         ,l_index     integer
         ,l_index2    integer
         ,l_index3    integer
         ,l_index4    integer
         ,l_null      char(1)
         ,l_status    smallint
         ,l_flag      smallint


   let l_status               = false
   let l_limite               = 0
   let l_saldo                = 0
   let l_util                 = 0
   let l_index                = 0
   let g_naturezas_re.qtd_eve = 0
   let g_naturezas_re.qtd_cls = 0
   let g_saldo_re.saldo       = 0
   let g_saldo_re.utiliz      = 0
   let g_saldo_re.qtde        = false
   let l_null                 = null
   let l_index2               = 0
   let l_flag                 = false
   let l_index3               = 0
   let l_index4               = 0

   #-----------------------------------
   --> Controle de Limites p/ Help Desk
   #-----------------------------------
   let g_hdk.sld_re           = "N"
   let g_hdk.usa_re           = "N"
   let g_hdk.qtd_lmt          = 0
   let g_hdk.qtd_utz          = 0


   initialize lr_retorno.* to null

   --> inicializando array modular de naturezas
   for l_index  =  1  to  500
       initialize  mr_servicos[l_index].* to  null
   end for


   {if g_issk.funmat = 4792   or  --> Karla Santos teste na aplaceite
      g_issk.funmat = 12435  or  --> Humberto
      let l_flag = true
   end if}

   #---------------
   --> Função do RE
   #---------------
   call framo242_sel_servemerg_re(l_flag
                                 ,lr_param.succod
                                 ,lr_param.ramcod
                                 ,lr_param.aplnumdig
                                 ,lr_param.prporg
                                 ,lr_param.prpnumdig
                                 ,lr_param.lclnumseq
                                 ,lr_param.rmerscseq)
                        returning lr_retorno.sqlcode
                                 ,lr_retorno.msgerro
                                 ,g_naturezas_re.qtd_cls
                                 ,g_naturezas_re.qtd_eve

   if l_flag = true then
      display "g_naturezas_re.qtd_cls = ",g_naturezas_re.qtd_cls
      display "g_naturezas_re.qtd_eve = ",g_naturezas_re.qtd_eve
      display "lr_retorno.sqlcode = ",lr_retorno.sqlcode
      display "lr_retorno.msgerro = ",lr_retorno.msgerro
   end if

   if lr_retorno.sqlcode <> 0 then
      error lr_retorno.msgerro sleep 3
      return lr_retorno.sqlcode,lr_retorno.msgerro
   end if

   #-----------------
   --> Montando Saldo
   #-----------------
   for l_index = 1 to g_naturezas_re.qtd_cls

      { display "ga_framg001_cls[l_index].clsindmaxlmt = "
               ,ga_framg001_cls[l_index].clsindmaxlmt}

       let l_limite = l_limite + ga_framg001_cls[l_index].clsindmaxlmt
       let l_util   = l_util   + ga_framg001_cls[l_index].utllmi
                               + ga_framg001_cls[l_index].agelmi
   end for

   let g_saldo_re.saldo  = l_limite - l_util
   let g_saldo_re.limite = l_limite

   if l_flag = true then
      display "g_saldo_re.saldo  = ",g_saldo_re.saldo
      display "g_saldo_re.limite = ",g_saldo_re.limite
   end if

   #------------------------------------
   --> verifica se Ainda ha Saldo de LMI
   #------------------------------------
   if g_saldo_re.saldo is not null and
      g_saldo_re.saldo >  0        then

      let g_hdk.sld_re = "S"
   end if

   #---------------------------------------------------
   --> Verifica se alguma natureza tem saldo disponivel
   #---------------------------------------------------
   for l_index = 1 to g_naturezas_re.qtd_eve

      if l_flag = true then
         display "ga_framg001_serv[",l_index,"].socntzcod  = "
                 ,ga_framg001_serv[l_index].socntzcod

         display "ga_framg001_serv[",l_index,"].rmrsrvdes  = "
                 ,ga_framg001_serv[l_index].rmrsrvdes

         display "ga_framg001_serv[",l_index,"].atdqtd     = "
                 ,ga_framg001_serv[l_index].atdqtd

         display "ga_framg001_serv[",l_index,"].ageatdqtd  = "
                 ,ga_framg001_serv[l_index].ageatdqtd

         display "ga_framg001_serv[",l_index,"].utlatdqtd  = "
                 ,ga_framg001_serv[l_index].utlatdqtd

         display "ga_framg001_serv[",l_index,"].mrccst     = "
                 ,ga_framg001_serv[l_index].mrccst
         display "ga_framg001_cls[",l_index,"].clsatdqtd  = "
                 ,ga_framg001_cls[l_index].clsatdqtd
         display "ga_framg001_cls[",l_index,"].ageatdqtd  = "
                 ,ga_framg001_cls[l_index].ageatdqtd
         display "ga_framg001_cls[",l_index,"].utlatdqtd  = "
                 ,ga_framg001_cls[l_index].utlatdqtd
      end if

      #----------------------------------------------------
      --> Verifica se a Natureza foi relacionada ao Assunto
      #----------------------------------------------------
      call cts12g99_verifica_natureza(ga_framg001_serv[l_index].socntzcod
                                     ,lr_param.c24astcod
                                     ,l_null)
                            returning l_status

      if l_status = true then

         let l_index2 = l_index2 + 1

         let mr_servicos[l_index2].socntzcod = ga_framg001_serv[l_index].socntzcod
         let mr_servicos[l_index2].socntzdes = ga_framg001_serv[l_index].rmrsrvdes
         let mr_servicos[l_index2].atdqtd    = ga_framg001_serv[l_index].atdqtd

         let mr_servicos[l_index2].ageatdqtd = ga_framg001_serv[l_index].ageatdqtd
         let mr_servicos[l_index2].utlatdqtd = ga_framg001_serv[l_index].utlatdqtd
         let mr_servicos[l_index2].vl_mercado= ga_framg001_serv[l_index].mrccst
      end if
   end for


   if l_index2 = 0 then
      if lr_param.c24astcod = "S67" or
         lr_param.c24astcod = "S66" then
         let lr_retorno.sqlcode = 0
      else
         let lr_retorno.sqlcode = 999
         let lr_retorno.msgerro = "Nenhuma Natureza associada ao Assunto. "
      end if

      return lr_retorno.sqlcode,lr_retorno.msgerro
   end if

#---------------------------------
--> Montando Saldo por Clausula
#---------------------------------

   for l_index = 1 to g_naturezas_re.qtd_cls
      if ga_framg001_cls[l_index].clsatdqtd is not null and
         ga_framg001_cls[l_index].clsatdqtd <> 0  then
         let l_index3 = l_index3 + 1
         let mr_clausulas[l_index3].clsatdqtd = ga_framg001_cls[l_index].clsatdqtd
         let mr_clausulas[l_index3].ageatdqtd = ga_framg001_cls[l_index].ageatdqtd
         let mr_clausulas[l_index3].utlatdqtd = ga_framg001_cls[l_index].utlatdqtd
      end if
   end for
   if ga_framg001_cls[l_index3].clsatdqtd is null or
      ga_framg001_cls[l_index3].clsatdqtd = 0  then
      #---------------------------------------
      --> Apura se Ha Quantidade Disponivel
      #---------------------------------------
          for l_index = 1 to l_index2

             if mr_servicos[l_index].vl_mercado is null or
                mr_servicos[l_index].vl_mercado =  0    then

                let l_saldo =  mr_servicos[l_index].atdqtd - (
                               mr_servicos[l_index].utlatdqtd +
                               mr_servicos[l_index].ageatdqtd )

                if l_saldo > 0 then
                   let g_saldo_re.qtde = true
                end if
             end if
          end for
   else
         for l_index = 1 to l_index3
           let l_saldo = ga_framg001_cls[l_index].clsatdqtd - (
                         ga_framg001_cls[l_index].utlatdqtd +
                         ga_framg001_cls[l_index].ageatdqtd )

            if l_saldo > 0 then
               let g_saldo_re.qtde = true
            end if
         end for
   end if
   if lr_retorno.sqlcode is null then
      let lr_retorno.sqlcode = 0
   end if

   #--------------------------------------------------------------------
   --> Assunto eh de Help Desk entao Apura LMI ou Quantidade da Natureza
   #--------------------------------------------------------------------
   if lr_param.c24astcod = "S67" or
      lr_param.c24astcod = "S66" then

      call cts12g99_limite_hdk(lr_param.c24astcod
                              ,g_naturezas_re.qtd_eve)
   end if

   return lr_retorno.sqlcode,lr_retorno.msgerro

end function


#--------------------------------------------------------------------------
function cts12g99_limite_hdk(lr_param)
#--------------------------------------------------------------------------

   define lr_param     record
          c24astcod    like datkassunto.c24astcod
	 ,index        integer
   end record


   define l_index2     integer
         ,l_cont       smallint
         ,l_natureza   smallint
         ,l_assunto    like datkassunto.c24astcod
         ,l_cpodes     char(50)

   let l_natureza = null
   let l_assunto  = null
   let l_cpodes   = null
   let l_index2   = 0
   let l_cont     = 0
   let l_cont     = 0


   let g_hdk.sld_re  = "N"
   let g_hdk.usa_re  = "N"
   let g_hdk.qtd_lmt = 0
   let g_hdk.qtd_utz = 0

   #-------------------------------------------------
   --> Le Todos os Servicos Carregados para o Assunto
   #-------------------------------------------------
   for l_index2 = 1 to lr_param.index


      #--------------------------------------------------------
      --> Verifica se Assunto da direito ao Help Desk - Dominio
      #--------------------------------------------------------
      let l_cont = 0

      open ccts12g99004
      foreach ccts12g99004 into l_cpodes

         let l_assunto  = l_cpodes[10,12]
         let l_natureza = l_cpodes[24,26]

         if lr_param.c24astcod = l_assunto then

            if mr_servicos[l_index2].socntzcod = l_natureza then
               let l_cont = l_cont + 1
               exit foreach
            else
               continue foreach
            end if
         else
            continue foreach
         end if
      end foreach

      if l_cont = 0 then
         continue for

      else
         #------------------------------------
	 --> verifica se Ainda ha Saldo de LMI
         #------------------------------------
         if g_saldo_re.saldo is not null and
            g_saldo_re.saldo >  0        then

            let g_hdk.sld_re = "S"
         end if

         #-------------------------------------------------------------
         --> Define se a Natureza de Help Desk eh por LMI ou Quantidade
         #-------------------------------------------------------------
         if mr_servicos[l_index2].vl_mercado is not null and
            mr_servicos[l_index2].vl_mercado <> 0        then

            let g_hdk.usa_re  = "S"
            let g_hdk.qtd_lmt = 0
            let g_hdk.qtd_utz = 0
         else

            let g_hdk.usa_re  = "N"
            let g_hdk.qtd_lmt = mr_servicos[l_index2].atdqtd
            let g_hdk.qtd_utz = mr_servicos[l_index2].ageatdqtd
                              + mr_servicos[l_index2].utlatdqtd
         end if
      end if
   end for
end function
