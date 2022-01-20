###############################################################################
# Nome do Modulo: CTS18M02                                           Marcelo  #
#                                                                    Gilberto #
# Localiza aviso de sinistro                                         Ago/1997 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 30/08/2001  PSI 132306    Ruiz        Permitir a consulta atraves do        #
#                                       sistema de atendimento.(cta00m01)     #
#-----------------------------------------------------------------------------#
# 03/03/2006  Zeladoria     Priscila    Buscar data e hora do banco de dados  #
#-----------------------------------------------------------------------------#
# 01/10/2008 Amilton, Meta     Psi 223689 Incluir tratamento de erro com a    #
#                                         global                              #
#-----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/figrc072.4gl" --> 223689

database porto

#------------------------------------------------------------
 function cts18m02(param)
#------------------------------------------------------------

 define param    record
    pgm          char (08)
 end record
 define d_cts18m02    record
    sinavsdat         like ssamavs.avsdat      ,
    sinavsnum         like ssamavs.sinavsnum   ,
    sinavsano         like ssamavs.sinavsano   ,
    placa             like ssamavs.vcllicnum   ,
    totqtd            char (10)
 end record

 define a_cts18m02 array[600] of record
    avsdat            like ssamavs.avsdat      ,
    avsnum            like ssamavs.sinavsnum   ,
    avsano            like ssamavs.sinavsano   ,
    rclnom            like ssamavs.sinrclnom   ,
    vcllicnum         like ssamavs.vcllicnum
 end record

 define retorno  record
    avsnum            like ssamavs.sinavsnum   ,
    avsano            like ssamavs.sinavsano
 end record

 define ws            record
    totqtd            smallint
 end record

 define arr_aux       smallint

 define sql_select    char (200)
 define sql_condition char (200)

 define l_existe      smallint

 define l_data        date,
        l_hora2       datetime hour to minute,
        l_ano         datetime year to year

	define	w_pf1	integer

	let	arr_aux  =  null
	let	sql_select  =  null
	let	sql_condition  =  null

	for	w_pf1  =  1  to  600
		initialize  a_cts18m02[w_pf1].*  to  null
	end	for

	initialize  d_cts18m02.*  to  null

	initialize  retorno.*  to  null

	initialize  ws.*  to  null
		
	

 open window w_cts18m02 at 06,02 with form "cts18m02"
            attribute(form line first)

while true

   initialize d_cts18m02.totqtd  to null
   initialize a_cts18m02         to null

   let int_flag  = false
   let arr_aux   = 1
   let ws.totqtd = 0

   display by name d_cts18m02.totqtd

   input by name d_cts18m02.sinavsdat,
                 d_cts18m02.sinavsnum,
                 d_cts18m02.sinavsano,
                 d_cts18m02.placa

      before field sinavsdat
         initialize d_cts18m02.sinavsdat  to null

         display by name d_cts18m02.sinavsdat attribute (reverse)
         call cts40g03_data_hora_banco(2)
              returning l_data, l_hora2
         let d_cts18m02.sinavsdat = l_data

      after  field sinavsdat
         display by name d_cts18m02.sinavsdat

         if d_cts18m02.sinavsdat is null  then
            error " Informe a data para pesquisa!"
            next field sinavsdat
         end if

      before field sinavsnum
         display by name d_cts18m02.sinavsnum attribute (reverse)

      after  field sinavsnum
         display by name d_cts18m02.sinavsnum
         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinavsdat
         else
            if d_cts18m02.sinavsnum is null  then
               initialize d_cts18m02.sinavsano to null
               display by name d_cts18m02.sinavsano
               next field placa
            end if
         end if

      before field sinavsano
         display by name d_cts18m02.sinavsano attribute (reverse)

      after  field sinavsano
         display by name d_cts18m02.sinavsano

         if fgl_lastkey() <> fgl_keyval("up")    and
            fgl_lastkey() <> fgl_keyval("left")  then
            if d_cts18m02.sinavsano is null  then
               error " Ano do aviso de sinistro deve ser informado!"
               next field sinavsano
            else
               call cts40g03_data_hora_banco(2)
                 returning l_data, l_hora2
               ##if d_cts18m02.sinavsano > current year to year  or
               let l_ano = l_data using "yyyy"
               if d_cts18m02.sinavsano > l_ano or
                  d_cts18m02.sinavsano < "1990"                then
                  error " Ano do aviso de sinistro invalido!"
                  next field sinavsano
               else
                  initialize d_cts18m02.placa to null
                  display by name d_cts18m02.placa
                  exit input
               end if
            end if
         end if

      before field placa
         display by name d_cts18m02.placa attribute (reverse)

      after  field placa
         display by name d_cts18m02.placa

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field sinavsnum
         else
            if d_cts18m02.sinavsdat is null  and
               d_cts18m02.sinavsnum is null  and
               d_cts18m02.placa     is null  then
               error " Informe uma chave para pesquisa!"
               next field sinavsdat
            end if
         end if

      on key (interrupt)
         exit input

   end input

   if int_flag   then
      exit while
   end if

   message " Aguarde, pesquisando... "  attribute (reverse)

   if d_cts18m02.sinavsnum is not null  and
      d_cts18m02.sinavsano is not null  then
      let sql_condition = "where sinavsnum = ?  and",
                          "      sinavsano = ?     "
   else
      if d_cts18m02.placa is not null  then
         let sql_condition = "where vcllicnum = ? "
      else
         let sql_condition = "where avsdat = ? "
      end if
   end if

   let sql_select = "select avsdat   , sinavsnum, sinavsano,",
                    "       sinrclnom, vcllicnum            ",
                    "  from ssamavs ", sql_condition clipped ,
                    " order by sinavsano, sinavsnum         "

   prepare p_cts18m02_001 from sql_select
   declare c_cts18m02_001 cursor for p_cts18m02_001

   if d_cts18m02.sinavsnum is not null  and
      d_cts18m02.sinavsano is not null  then
      open c_cts18m02_001  using d_cts18m02.sinavsnum, d_cts18m02.sinavsano
   else
      if d_cts18m02.placa is not null  then
         open c_cts18m02_001  using d_cts18m02.placa
      else
         open c_cts18m02_001  using d_cts18m02.sinavsdat
      end if
   end if

   foreach  c_cts18m02_001  into  a_cts18m02[arr_aux].avsdat,
                              a_cts18m02[arr_aux].avsnum,
                              a_cts18m02[arr_aux].avsano,
                              a_cts18m02[arr_aux].rclnom,
                              a_cts18m02[arr_aux].vcllicnum
      let l_existe = 0
      select count(*)
      into   l_existe
      from   datrligsinavs
      where  sinavsnum  = a_cts18m02[arr_aux].avsnum
      and    sinavsano  = a_cts18m02[arr_aux].avsano
      if l_existe = 0 then
	 continue foreach
      end if


      let ws.totqtd = ws.totqtd + 1

      let arr_aux   = arr_aux + 1

      if arr_aux > 600  then
         error "Limite excedido. Foram encontrados mais de 600 avisos de sinistro!"
         exit foreach
      end if
   end foreach

   if arr_aux > 1  then
      message " (F17)Abandona, (F8)Seleciona"

      call set_count(arr_aux - 1)

      let d_cts18m02.totqtd = "Total: ", ws.totqtd using "&&&"
      display by name d_cts18m02.totqtd  attribute (reverse)

      display array  a_cts18m02 to s_cts18m02.*
         on key (interrupt)
            exit display

         on key (F8)
            let arr_aux = arr_curr()
            if param.pgm  = "cta00m01"  then
               let retorno.avsnum = a_cts18m02[arr_aux].avsnum
               let retorno.avsano = a_cts18m02[arr_aux].avsano
               exit display
            end if
            error " Selecione e tecle ENTER!"
            call figrc072_setTratarIsolamento()        --> 223689
            call cts18m00(a_cts18m02[arr_aux].avsnum,
                          a_cts18m02[arr_aux].avsano)
            if g_isoAuto.sqlCodErr <> 0 then --> 223689
             error "Função cts18m00 indisponivel no momento ! Avise a Informatica !" sleep 2
             exit while
          end if    --> 223689
      end display

      for arr_aux = 1 to 11
         clear s_cts18m02[arr_aux].avsdat
         clear s_cts18m02[arr_aux].avsnum
         clear s_cts18m02[arr_aux].avsano
         clear s_cts18m02[arr_aux].rclnom
         clear s_cts18m02[arr_aux].vcllicnum
      end for
   else
      error " Nao foi encontrado nenhum aviso de sinistro",
            " com o criterio informado!"
   end if
   if param.pgm  =  "cta00m01"   and
      retorno.avsnum is not null then
      exit while
   end if
end while

let int_flag = false
close window  w_cts18m02
if param.pgm = "cta00m01" then
   return retorno.avsnum,
          retorno.avsano
end if
end function  ###  cts18m02
