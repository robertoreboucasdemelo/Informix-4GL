###############################################################################
# Nome do Modulo : CTO00M01                                                Ruiz
# Pesquisa de Nome via fonetica                                        Abr/2000
###############################################################################

database porto

#-------------------------------------------------------
 function cto00m01(param)
#-------------------------------------------------------

   define param record
          apoio          char(01)
   end record
   define a_cto00m01     array[1000] of record
          funnom         like isskfunc.rhmfunnom,
          empcod         like isskfunc.empcod,
          funmat         like isskfunc.funmat
   end record

   define w_input        record
          nome           like isskfunc.rhmfunnom
   end record

   define ws             record
          prifoncod      like gsakseg.prifoncod,
          segfoncod      like gsakseg.segfoncod,
          terfoncod      like gsakseg.terfoncod,
          entrada        char(51)              ,
          saida          char(100)             ,
          comando        char(800)             ,
          comando_sql    char(600)             ,
          comando_sql1   char(600)             ,
          dptsgl         like isskfunc.dptsgl  ,
          funnom         like isskfunc.funnom
   end record
   define w_arr          smallint


 #------------------------------------------------------------------------------
 # Inicializacao de variaveis
 #------------------------------------------------------------------------------

	define	w_pf1	integer

	let	w_arr  =  null

	for	w_pf1  =  1  to  1000
		initialize  a_cto00m01[w_pf1].*  to  null
	end	for

	initialize  w_input.*  to  null

	initialize  ws.*  to  null

   initialize a_cto00m01,
              w_input   ,
              ws        ,
              w_arr       to null

 #------------------------------------------------------------------------------
 # Preparacao dos comandos SQL
 #------------------------------------------------------------------------------
   let ws.comando_sql = " select rhmfunnom,empcod,funmat ",
                       "  from isskfunc     where ",
                       "       prifoncod = ?   or ",
                       "       segfoncod = ?   or ",
                       "       terfoncod = ?      "
   prepare p_cto00m01_001 from ws.comando_sql
   declare c_cto00m01_001 cursor with hold for p_cto00m01_001

   let ws.comando_sql1= " select rhmfunnom,empcod,funmat ",
                       "  from isskfunc   where   "

   if param.apoio = "S" then
      open window cto00m01 at 08,10 with form "cto00m01a"
               attribute(form line 1,border)
   else
      open window cto00m01 at 08,10 with form "cto00m01"
               attribute(form line 1,border)
   end if

   message "<F17> Abandona   <F8> Seleciona"

   let int_flag = false
   let w_arr    = 1
   initialize a_cto00m01 to null

   while true

     input by name w_input.nome

       before field nome
         display by name w_input.nome attribute(reverse)

       after  field nome
         display by name w_input.nome

         if param.apoio is null then
            if w_input.nome   is null then
               error " Informe o nome a ser pesquisado! "
               next field nome
            end if
         end if

       on key(interrupt)
         exit input

     end input
     if  int_flag  then
         initialize a_cto00m01 to null
         exit while
     end if
     let w_arr = 1

     if param.apoio is null then
     initialize ws.prifoncod to null
     initialize ws.segfoncod to null
     initialize ws.terfoncod to null

     let ws.entrada = "1", w_input.nome

     call fonetica2(ws.entrada) returning ws.saida
     if ws.saida[1,3] = "100" then
        error   "Problema no servidor de fonetica, avisar o help desk"
        let ws.saida = "################################################"
        sleep 3
        exit program
     end if

     let ws.prifoncod = ws.saida[1,15]
     let ws.segfoncod = ws.saida[17,31]
     if ws.segfoncod is null or
        ws.segfoncod = " " then
        let ws.segfoncod = ws.prifoncod
     end if

     let ws.terfoncod = ws.saida[33,47]
     if ws.terfoncod is null or
        ws.terfoncod = " " then
        let ws.terfoncod = ws.prifoncod
     end if

     open c_cto00m01_001 using ws.prifoncod,
                           ws.segfoncod,
                           ws.terfoncod
     foreach c_cto00m01_001 into a_cto00m01[w_arr].funnom,
                             a_cto00m01[w_arr].empcod,
                             a_cto00m01[w_arr].funmat
       let w_arr = w_arr + 1
       if  w_arr > 20  then
           error " Lista muito grande. Informe mais dados do nome"
           exit foreach
       end if
     end foreach

     if w_arr  =  1  then
        let ws.comando = ws.comando_sql1 clipped , ' rhmfunnom matches ',
                        ' "*', w_input.nome clipped, '*" '
        prepare p_cto00m01_002 from ws.comando
        declare c_cto00m01_002 cursor with hold for p_cto00m01_002
        foreach c_cto00m01_002 into a_cto00m01[w_arr].funnom,
                                 a_cto00m01[w_arr].empcod,
                                 a_cto00m01[w_arr].funmat
           let w_arr = w_arr + 1
           if  w_arr > 20    then
               error " Lista muito grande. Informe mais dados do nome"
               exit foreach
           end if
        end foreach
     end if
     else
        declare c_cto00m01_003 cursor for
             select funnom,empcod,funmat
                   from isskfunc
                  where dptsgl       = "ct24hs"
                    and rhmfunsitcod = "A"
             order by 1
        foreach c_cto00m01_003 into a_cto00m01[w_arr].funnom,
                                     a_cto00m01[w_arr].empcod,
                                     a_cto00m01[w_arr].funmat
           if a_cto00m01[w_arr].funnom is null then
              continue foreach
           end if
           if w_input.nome is not null then
              call cto00m01_trata_nome(a_cto00m01[w_arr].funnom)
                             returning ws.funnom
              if ws.funnom <> w_input.nome then
                 continue foreach
              end if
           end if
           let w_arr = w_arr + 1
           if  w_arr > 1000  then
               error " Lista muito grande. Informe mais dados do nome"
               exit foreach
           end if
        end foreach
     end if

     if w_arr  =  1  then
        error " Nome nao encontrado. Informe mais dados do nome"
        continue while
     else
         call set_count(w_arr - 1)

         display array a_cto00m01 to s_cto00m01.*
            on key (interrupt,control-c)
               initialize a_cto00m01  to null
               exit display

            on key (f8)
               let w_arr = arr_curr()
               exit display
         end display

         if  int_flag  then   # control-c
             let int_flag = false
             continue while
         else
             exit while
         end if

     end if

   end while

   close window cto00m01

   let int_flag = false

   return a_cto00m01[w_arr].empcod,
          a_cto00m01[w_arr].funmat,
          a_cto00m01[w_arr].funnom

 end function

#------------------------------------------------------------------------------
function cto00m01_trata_nome(param)
#------------------------------------------------------------------------------
   define param record
      funnom like isskfunc.funnom
   end record
   define w_l smallint
   define w_funnom like isskfunc.funnom


	let	w_l  =  null
	let	w_funnom  =  null

   let w_l = 1
   while true
     if param.funnom[w_l] = "-" or
        param.funnom[w_l] = " " then
        exit while
     end if
     let w_funnom[w_l] = param.funnom[w_l]
     let w_l = w_l + 1
     if w_l > 20 then
        exit while
     end if
   end while

   return w_funnom
end function
#------------------------------------------------------------------------------

