############################################################################
# Menu de Modulo: CTC58m00                                           Raji  #
#                                                                          #
# Manutencao dos Textos para Assunto                              JUL/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONS. DESCRICAO                              #
#--------------------------------------------------------------------------#
############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function ctc58m00(par_ctc58m00)
#--------------------------------------------------------------------
  define par_ctc58m00 record
         c24astcod    like datkassunto.c24astcod
  end record

  define a_ctc58m00 array[300] of record
     c24asttxt      like datkasttxt.c24asttxt ,
     c24astlin      like datkasttxt.c24astlin
  end record

  define arr_aux    smallint
  define scr_aux    smallint
  define cnt_aux    smallint
  define i          smallint

  define ws         record
     operacao       char(1),
     confirma       char(1),
     c24astdes      like datkassunto.c24astdes ,
     c24asttxt      like datkasttxt.c24asttxt  ,
     c24astlin      like datkasttxt.c24astlin  ,
     arq            char(15)
  end record


	define	w_pf1	integer

	let	arr_aux  =  null
	let	scr_aux  =  null
	let	cnt_aux  =  null
	let	i  =  null

	for	w_pf1  =  1  to  300
		initialize  a_ctc58m00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

  initialize a_ctc58m00  to null
  initialize ws.*        to null

  declare c_ctc58m00  cursor for
     select c24asttxt, c24astlin
       from datkasttxt
      where c24astcod    = par_ctc58m00.c24astcod

  let arr_aux = 1

  foreach c_ctc58m00 into a_ctc58m00[arr_aux].c24asttxt    ,
                          a_ctc58m00[arr_aux].c24astlin
     let arr_aux = arr_aux + 1
     if arr_aux > 300 then
        error " Limite excedido! Foram encontradas mais de 300",
              " linhas de texto!"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)

  open window w_ctc58m00 at 06,02 with form "ctc58m00"
       attribute(form line first,message line last -1)

  select c24astdes
    into ws.c24astdes
    from datkassunto
   where c24astcod = par_ctc58m00.c24astcod


  display par_ctc58m00.c24astcod    to c24astcod
  display ws.c24astdes              to c24astdes

   while true
      let int_flag = false

      message "(F1)Inclui, (F2)Exclui"

      input array a_ctc58m00 without defaults from s_ctc58m00.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               let cnt_aux = arr_count()

               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctc58m00[arr_aux].*  to null
               display    a_ctc58m00[arr_aux].*  to s_ctc58m00[scr_aux].*

            before field c24asttxt
               display a_ctc58m00[arr_aux].c24asttxt to
                       s_ctc58m00[scr_aux].c24asttxt attribute (reverse)

            after field c24asttxt
               display a_ctc58m00[arr_aux].c24asttxt to
                       s_ctc58m00[scr_aux].c24asttxt

               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  let ws.operacao = " "
               end if

               if a_ctc58m00[arr_aux].c24asttxt is null or
                  a_ctc58m00[arr_aux].c24asttxt =  "  " then
                  error " Texto em branco nao e' permitido!"
                  next field c24asttxt
               end if

               if ws.operacao = "i" then
                  select max(c24astlin)
                    into a_ctc58m00[arr_aux].c24astlin
                    from datkasttxt
                   where c24astcod    = par_ctc58m00.c24astcod

                  if sqlca.sqlcode = notfound then
                     let a_ctc58m00[arr_aux].c24astlin = 1
                  else
                     let a_ctc58m00[arr_aux].c24astlin =
                         a_ctc58m00[arr_aux].c24astlin + 1
                  end if
               end if

            on key (interrupt)
               exit input

      end input

      if int_flag    then
         exit while
      end if

   end while

   let int_flag = false
   close c_ctc58m00
   close window w_ctc58m00

   call cts08g01("A",
                 "S",
                 "",
                 "Deseja gravar as alteracoes?",
                 "",
                 "")
        returning ws.confirma

   if ws.confirma = "S"  then
      begin work
          delete from datkasttxt
           where c24astcod = par_ctc58m00.c24astcod

          for i = 1 to cnt_aux
              if a_ctc58m00[i].c24asttxt is null then
                 exit for
              end if
              insert into datkasttxt
                        ( c24astcod, c24asttxt, c24astlin )
                 values ( par_ctc58m00.c24astcod,
                          a_ctc58m00[i].c24asttxt,
                          i                               )
          end for
      commit work
   end if
end function  ###  ctc58m00


#--------------------------------------------------------------------
 function ctc58m00_vis(par_ctc58m00)
#--------------------------------------------------------------------
  define par_ctc58m00 record
         c24astcod    like datkassunto.c24astcod
  end record

  define arr_aux smallint

  define a_ctc58m00 array[300] of record
     c24asttxt      like datkasttxt.c24asttxt ,
     c24astlin      like datkasttxt.c24astlin
  end record

  define ws         record
     c24astdes      like datkassunto.c24astdes ,
     arq            char(15)
  end record


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  300
		initialize  a_ctc58m00[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

  initialize a_ctc58m00  to null
  initialize ws.*        to null

  declare c_ctc58m00_vis  cursor for
     select c24asttxt, c24astlin
       from datkasttxt
      where c24astcod    = par_ctc58m00.c24astcod

  let arr_aux = 1

  foreach c_ctc58m00_vis into a_ctc58m00[arr_aux].c24asttxt    ,
                          a_ctc58m00[arr_aux].c24astlin
     let arr_aux = arr_aux + 1
     if arr_aux > 300 then
        error " Limite excedido! Foram encontradas mais de 300",
              " linhas de texto!"
        exit foreach
     end if
  end foreach

  if arr_aux = 1 then
     error " Nao existe texto para este assunto!"

  else

     call set_count(arr_aux-1)

     open window w_ctc58m00 at 06,02 with form "ctc58m00"
          attribute(form line first,message line last -1)

     select c24astdes
       into ws.c24astdes
       from datkassunto
      where c24astcod = par_ctc58m00.c24astcod


     display par_ctc58m00.c24astcod    to c24astcod
     display ws.c24astdes              to c24astdes

      while true
         let int_flag = false

         message "(F17) Encerra"

         display array a_ctc58m00 to s_ctc58m00.*

               on key (interrupt)
                  exit display

         end display

         if int_flag    then
            exit while
         end if

      end while

      let int_flag = false
      close window w_ctc58m00
  end if
  close c_ctc58m00_vis

end function
