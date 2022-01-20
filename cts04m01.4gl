#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: CT24H                                                     #
# Modulo         : cts04m01.4gl                                              #
#                  Mostrar vistorias para apolice                            #
# Analista Resp. : Ruiz                                                      #
# PSI/OSF        : 172.065 / 026166                                          #
#............................................................................#
# Desenvolvimento: Meta, Jefferson Schueroff                                 #
# Liberacao      : 15/09/2003                                                #
#............................................................................#
#                     * * *  ALTERACOES  * * *                               #
#                                                                            #
# Data      Autor Fabrica  PSI    Alteracao                                  #
# --------  -------------  ------ -------------------------------------------#
# 12/04/10  Carla Rampazzo 219444 Filtrar Vistoria para mostrar so as que se #
#                                 relacionam com Local de Risco / Bloco      #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


database porto

   define am_cts04m01 array[10] of record
          vistoria     char(13)
         ,sinvstnum    like datrligsinvst.sinvstnum
         ,sinvstano    like datrligsinvst.sinvstano
         ,lignum       like datmligacao.lignum
         ,ligdat       like datmligacao.ligdat
         ,lighorinc    like datmligacao.lighorinc
         ,c24solnom    like datmligacao.c24solnom
         ,c24soltipcod like datmligacao.c24soltipcod
         ,lclnumseq    like datmpedvist.lclnumseq
         ,rmerscseq    like datmpedvist.rmerscseq
   end record

   define am_cts04m01_aux array[10] of record
          vistoria     char(13)
         ,ligdat       like datmligacao.ligdat
         ,lighorinc    like datmligacao.lighorinc
         ,c24solnom    like datmligacao.c24solnom
         ,c24soltipdes like datksoltip.c24soltipdes
   end record

   define m_prepara_sql smallint

#---------------------------#
function cts04m01_prepara()
#---------------------------#
   define l_sql    char(500)

   let l_sql = " select a.sinvstnum||' - '||a.sinvstano, "
              ,"        a.sinvstnum, "
              ,"        a.sinvstano, "
              ,"        a.lignum, "
              ,"        b.ligdat, "
              ,"        b.lighorinc, "
              ,"        b.c24solnom, "
              ,"        b.c24soltipcod "
              ,"   from datrligsinvst a, datmligacao b, datrligapol c "
              ,"  where c.succod = ? "
              ,"    and c.ramcod = ? "
              ,"    and c.aplnumdig = ? "
              ,"    and c.itmnumdig = ? "
              ,"    and b.lignum = c.lignum "
              ,"    and b.c24astcod = 'V12' "
              ,"    and a.lignum = c.lignum "

   prepare p_cts04m01_001 from l_sql
   declare c_cts04m01_001 cursor for p_cts04m01_001

   let l_sql = " select c24soltipdes "
              ,"   from datksoltip "
              ,"  where c24soltipcod = ? "

   prepare p_cts04m01_002 from l_sql
   declare c_cts04m01_002 cursor for p_cts04m01_002


   let l_sql = " select lclnumseq "
              ,"       ,rmerscseq "
              ,"   from datmrsclcllig "
              ,"  where lignum = ? "
   prepare p_cts04m01_003 from l_sql
   declare c_cts04m01_003 cursor for p_cts04m01_003

   let m_prepara_sql = true

end function

#---------------------------#
function cts04m01(l_succod,
                  l_ramcod,
                  l_aplnumdig,
                  l_itmnumdig)
#---------------------------#

   define l_succod    like datrligapol.succod
         ,l_ramcod    like datrligapol.ramcod
         ,l_aplnumdig like datrligapol.aplnumdig
         ,l_itmnumdig like datrligapol.itmnumdig
         ,l_cont      smallint
         ,l_contador  smallint
         ,l_sinvstnum like datrligsinvst.sinvstnum
         ,l_sinvstano like datrligsinvst.sinvstano
         ,l_linha     smallint
         ,l_erro      smallint

   let l_cont = 1
   let l_erro = false
   let l_sinvstnum = null
   let l_sinvstano = null

   if m_prepara_sql is null or
      m_prepara_sql <> true then
      call cts04m01_prepara()
   end if

   open c_cts04m01_001 using l_succod,
                           l_ramcod,
                           l_aplnumdig,
                           l_itmnumdig

   foreach c_cts04m01_001 into am_cts04m01[l_cont].*

      initialize am_cts04m01[l_cont].lclnumseq
                ,am_cts04m01[l_cont].rmerscseq  to null

      ---> Despreza Vistorias que nao sao da mesma Seq. Local / Bloco
      open c_cts04m01_003 using am_cts04m01[l_cont].lignum
      fetch c_cts04m01_003 into am_cts04m01[l_cont].lclnumseq
			     ,am_cts04m01[l_cont].rmerscseq

      ---> Para os casos antigos (sem a Seq./Bloco) que nao tinham a informacao
      ---> mostra para qualquer documento

      if am_cts04m01[l_cont].lclnumseq is not null and
         am_cts04m01[l_cont].lclnumseq <> 0        then

         if am_cts04m01[l_cont].lclnumseq <> g_documento.lclnumseq or
            am_cts04m01[l_cont].rmerscseq <> g_documento.rmerscseq then
	    continue foreach
         end if
      end if


      open c_cts04m01_002 using am_cts04m01[l_cont].c24soltipcod

      whenever error continue
      fetch c_cts04m01_002 into am_cts04m01_aux[l_cont].c24soltipdes
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode <> 100 then
            error " Erro SELECT datksoltip: ",
                    sqlca.sqlcode," | ",sqlca.sqlerrd[2] sleep 2
            let l_erro = true
            exit foreach
         end if
      end if

      close c_cts04m01_002

      let l_cont = l_cont + 1

      if l_cont > 10 then
         exit foreach
      end if

   end foreach

   let l_cont = l_cont - 1

   if l_cont <= 0 then
      return l_sinvstnum, l_sinvstano
   end if

   open window w_cts04m01 at 09,04 with form "cts04m01"
        attribute(border)

   if l_erro then
      let int_flag = false
      close window w_cts04m01
      initialize l_sinvstnum, l_sinvstano to null
      return l_sinvstnum, l_sinvstano
   end if

   call set_count(l_cont)

   for l_contador = 1 to l_cont
      let am_cts04m01_aux[l_contador].vistoria  = am_cts04m01[l_contador].vistoria
      let am_cts04m01_aux[l_contador].ligdat    = am_cts04m01[l_contador].ligdat
      let am_cts04m01_aux[l_contador].lighorinc = am_cts04m01[l_contador].lighorinc
      let am_cts04m01_aux[l_contador].c24solnom = am_cts04m01[l_contador].c24solnom
   end for

   display array am_cts04m01_aux to s_cts04m01.*

      on key(f17,control-c,interrupt)

         let l_sinvstnum = null
         let l_sinvstano = null
         exit display

      on key(f8)

         let l_linha = arr_curr()

         let l_sinvstnum = am_cts04m01[l_linha].sinvstnum
         let l_sinvstano = am_cts04m01[l_linha].sinvstano
         exit display

   end display

   let int_flag = false

   close window w_cts04m01
   return l_sinvstnum, l_sinvstano

end function
