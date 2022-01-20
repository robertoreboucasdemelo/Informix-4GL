###############################################################################
# Nome do Modulo: CTS06M02                                              Pedro #
#                                                                     Marcelo #
# Localiza Vistoria Previa Domiciliar                                Jan/1995 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 01/04/2001  Natal        Ruiz         desprezar as VP canceladas.           #
#-----------------------------------------------------------------------------#

 database porto

##globals  "/homedsa/fontes/ct24h/producao/glct.4gl"
globals  "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------
 function cts06m02(p_cts06m02)
#------------------------------------------------------------

 define p_cts06m02    record
    exec              char(01),
    corlignum         like dacmligass.corlignum  ,
    corligitmseq      like dacmligass.corligitmseq
 end record

 define d_cts06m02    record
    vstdat            like datmvistoria.vstdat,
    succod            like datmvistoria.succod,
    placa             like datmvistoria.vcllicnum,
    susep             like datmvistoria.corsus
 end record

 define a_cts06m02 array[1500] of record
    vstdat2           char(05),
    vstnumdig         like datmvistoria.vstnumdig,
    corsus            like datmvistoria.corsus   ,
    veiculo           char(40),
    vcllicnum         like datmvistoria.vcllicnum
 end record

 define ws            record
    comando1          char(400),
    comando2          char(120),
    vstdat            char(10),
    vclmrcnom         like agbkmarca.vclmrcnom,
    vclmdlnom         like agbkveic.vclmdlnom,
    vcltipnom         like agbktip.vcltipnom,
    total             char(10),
    sucnom            like gabksuc.sucnom,
    count             smallint,
    atdsrvnum         like datmvstcanc.atdsrvnum,
    atdsrvano         like datmvstcanc.atdsrvano
 end record

 define arr_aux       smallint
 define scr_aux       smallint



	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  1500 
		initialize  a_cts06m02[w_pf1].*  to  null
	end	for

	initialize  d_cts06m02.*  to  null

	initialize  ws.*  to  null

 open window w_cts06m02 at  06,02 with form "cts06m02"
             attribute(form line first)

 while true

   initialize ws.*        to null
   initialize a_cts06m02  to null
   let int_flag = false
   let arr_aux  = 1
   display by name ws.sucnom

   input by name d_cts06m02.*

      before field vstdat
         display by name d_cts06m02.vstdat    attribute (reverse)

         let d_cts06m02.vstdat = today

      after field vstdat
         display by name d_cts06m02.vstdat

         if d_cts06m02.vstdat  is null   then
            error " Data de realizacao da vistoria previa deve ser informada!"
            next field vstdat
         end if

      before field succod
         display by name d_cts06m02.succod    attribute (reverse)

         let d_cts06m02.succod = g_issk.succod

         select sucnom  into  ws.sucnom
           from gabksuc
          where succod = d_cts06m02.succod
          display by name ws.sucnom

      after field succod
         display by name d_cts06m02.succod

         if d_cts06m02.succod  is null   then
            error " Sucursal deve ser informada!"
            next field succod
         end if

         select sucnom  into  ws.sucnom
           from gabksuc
          where succod = d_cts06m02.succod
          display by name ws.sucnom

         if g_issk.dptsgl  <>  "desenv"   then
            if d_cts06m02.succod  <>  g_issk.succod   then
####           if d_cts06m02.succod = 2 and  g_issk.succod = 1 then
####              # CHAMADO 300845 - Henrique - 05/06/2003
####              # Permitido acesso a sucursal Rio pela Ct24h
####           else
####              error "Nao devem ser consultadas vistorias de outra sucursal!"
####              next field succod
####           end if
            end if
         end if

      before field placa
         display by name d_cts06m02.placa attribute (reverse)

      after field placa
         display by name d_cts06m02.placa

         if d_cts06m02.placa  is not null   then
            exit input
         end if

      before field susep
         display by name d_cts06m02.susep    attribute (reverse)

      after field susep
         display by name d_cts06m02.susep

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   #-------------------------------------------
   # Consulta as vistorias marcadas
   #-------------------------------------------
   if d_cts06m02.placa  is not null   then
      let ws.comando2 = " from datmvistoria ",
                        " where ",
                        " datmvistoria.succod    = ? and ",
                        " datmvistoria.vstdat    = ? and ",
                        " datmvistoria.vcllicnum = ? "
   else
      if d_cts06m02.susep  is not null   then
         let ws.comando2 = " from datmvistoria ",
                           " where ",
                           " datmvistoria.succod = ? and ",
                           " datmvistoria.vstdat = ? and ",
                           " datmvistoria.corsus = ? "
      else
         let ws.comando2 = " from datmvistoria ",
                           " where ",
                           " datmvistoria.succod = ? and ",
                           " datmvistoria.vstdat = ? "
      end if
   end if

  let ws.comando1 = " select vstdat, vstnumdig, corsus, vclmrcnom, vclmdlnom, vcltipnom, vcllicnum,atdsrvnum,atdsrvano ", ws.comando2  clipped, " order by vstnumdig"

   prepare comando_aux from ws.comando1
   declare c_cts06m02 cursor for comando_aux
   if d_cts06m02.placa  is not null   then
      open c_cts06m02  using  d_cts06m02.succod,
                              d_cts06m02.vstdat,
                              d_cts06m02.placa
   else
      if d_cts06m02.susep  is not null   then
         open c_cts06m02  using  d_cts06m02.succod,
                                 d_cts06m02.vstdat,
                                 d_cts06m02.susep
      else
         open c_cts06m02  using  d_cts06m02.succod,
                                 d_cts06m02.vstdat
      end if
   end if

   foreach  c_cts06m02  into  ws.vstdat                    ,
                              a_cts06m02[arr_aux].vstnumdig,
                              a_cts06m02[arr_aux].corsus   ,
                              ws.vclmrcnom,
                              ws.vclmdlnom,
                              ws.vcltipnom,
                              a_cts06m02[arr_aux].vcllicnum,
                              ws.atdsrvnum,
                              ws.atdsrvano
       let ws.count = 0
       select count(*)         --[despreza vistoria cancelada - ruiz]
             into ws.count
             from datmvstcanc
            where atdsrvnum = ws.atdsrvnum
              and atdsrvano = ws.atdsrvano
       if ws.count > 0 then
          continue foreach
       end if
       let a_cts06m02[arr_aux].vstdat2 = ws.vstdat[1,5]

       let a_cts06m02[arr_aux].veiculo = ws.vclmrcnom clipped, " ",
                                         ws.vcltipnom clipped, " ",
                                         ws.vclmdlnom clipped
       let arr_aux = arr_aux + 1
       if arr_aux > 1500  then
          error " Limite excedido! Foram encontradas mais de 1500 marcacoes!"
          exit foreach
       end if
   end foreach

   let ws.total = "Total: ", arr_aux - 1 using "&&&"
   display by name ws.total  attribute (reverse)

   if arr_aux  >  1   then
      message " (F17)Abandona, (F8)Seleciona"
      call set_count(arr_aux-1)

      display array  a_cts06m02 to s_cts06m02.*
         on key(interrupt)
            initialize ws.total to null
            display by name ws.total
            exit display

         on key(f8)
            let arr_aux = arr_curr()
            error " Selecione e tecle ENTER!"
            if  p_cts06m02.exec = "N"  then
                call cts06m00("N",a_cts06m02[arr_aux].vstnumdig,"","")
            else
                call cts06m00("A",
                              a_cts06m02[arr_aux].vstnumdig,
                              p_cts06m02.corlignum         ,
                              p_cts06m02.corligitmseq       )
            end if
      end display

      for scr_aux = 1 to 10
         clear s_cts06m02[scr_aux].vstdat2
         clear s_cts06m02[scr_aux].vstnumdig
         clear s_cts06m02[scr_aux].corsus
         clear s_cts06m02[scr_aux].veiculo
         clear s_cts06m02[scr_aux].vcllicnum
      end for
   else
      error " Nao existem vistorias programadas para pesquisa!"
   end if
   close c_cts06m02

 end while

 let int_flag = false
 close window  w_cts06m02

end function  ###  cts06m02


##------------------------------------------------------------
# function cts04g00()
##------------------------------------------------------------
#
#error " Funcao (cts04g00) nao disponivel. AVISE INFORMATICA!"
#
#end function  ###  cts04g00

