 ############################################################################
 # Nome do Modulo: CTC02M00                                           Pedro #
 #                                                                          #
 # Manutencao no Cadastro de Guinchos                              Set/1994 #
 ############################################################################

 #----------------------------------------------------------------
 # Modulo de manutencao em array na tabela dpckguincho
 # Gerado por: ct24h em: 14/09/94
 #----------------------------------------------------------------

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function ctc02m00()
#---------------------------------------------------------------

   define arr_aux integer
   define scr_aux integer
   define operacao_aux char(1)
   define ws_confirma  char(1)

   define a_ctc02m00 array[100] of record
      gchtip like dpckguincho.gchtip,
      gchdes like dpckguincho.gchdes
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer

   if not get_niv_mod(g_issk.prgsgl, "ctc02m00") then
      error "Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   options comment line last - 2

   open window ctc02m00 at 6,2 with form "ctc02m00"
        attribute (form line first)

   message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

   declare c_ctc02m00 cursor for
      select
         gchtip,
         gchdes
      from dpckguincho
      order by
	 gchtip,
	 gchdes

   let int_flag = false

   while not int_flag
      let arr_aux = 1
      foreach c_ctc02m00 into a_ctc02m00[arr_aux].*
         let arr_aux = arr_aux + 1
         if arr_aux > 100 then
            error "Limite de manutencao excedido (100), AVISE A INFORMATICA!"
            sleep 5
            exit program
         end if
      end foreach

      call set_count(arr_aux-1)

      input array a_ctc02m00 without defaults from dpckguincho.*
      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         if arr_aux <= arr_count() then
            begin work
            let operacao_aux = "a"
            declare u_ctc02m00 cursor for
            select
	       gchtip,
	       gchdes
            from dpckguincho
            where
               gchtip = a_ctc02m00[arr_aux].gchtip
            for update
            open u_ctc02m00
            fetch u_ctc02m00 into a_ctc02m00[arr_aux].*
	    display a_ctc02m00[arr_aux].* to
	       dpckguincho[scr_aux].*
            next field gchdes
         end if

      before insert
         let operacao_aux = "i"
         initialize
            a_ctc02m00[arr_aux].gchtip,
            a_ctc02m00[arr_aux].gchdes
         like
            dpckguincho.gchtip,
            dpckguincho.gchdes

      before field gchtip
         if operacao_aux = "a" then
	    next field gchdes
         end if
         display a_ctc02m00[arr_aux].gchtip to
	    dpckguincho[scr_aux].gchtip
            attribute (reverse)

      after field gchtip
         display a_ctc02m00[arr_aux].gchtip to
            dpckguincho[scr_aux].gchtip

         #---------------------------------------------------------
         # Verifica existencia da linha a incluir
         #---------------------------------------------------------
         select * from dpckguincho
         where
            gchtip = a_ctc02m00[arr_aux].gchtip

         if status <> notfound then
            error "Tipo de guincho ja' cadastrado!"
            next field gchtip
         end if

      before field gchdes
         display a_ctc02m00[arr_aux].gchdes to
	    dpckguincho[scr_aux].gchdes
            attribute (reverse)

      after field gchdes
         display a_ctc02m00[arr_aux].gchdes to
            dpckguincho[scr_aux].gchdes

      on key (interrupt)
         exit input

      before delete
         call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
              returning ws_confirma

         if ws_confirma = "N" then
            exit input
         end if
         if not delete_dpckguincho (
            a_ctc02m00[arr_aux].gchtip ) then
	    error "Remocao nao permitida!"
	    let int_flag = false
            exit input
         end if
         if operacao_aux = "a" then
	    commit work
            let operacao_aux = " "
         end if
	 initialize a_ctc02m00[arr_aux].* to null
	 display a_ctc02m00[arr_aux].* to
	    dpckguincho[scr_aux].*

      after row
         if a_ctc02m00[arr_aux].gchtip is null then
            let operacao_aux = " "
            error "Tipo de guincho nao selecionado!"
         end if

         case operacao_aux
	 when "a"
            update dpckguincho set
	       gchdes = a_ctc02m00[arr_aux].gchdes
            where current of u_ctc02m00

            commit work

         when "i"
            insert into dpckguincho (
                        	     gchtip,
	                             gchdes
                                    )
                        values      (
                                     a_ctc02m00[arr_aux].gchtip,
                                     a_ctc02m00[arr_aux].gchdes
                                    )
         end case

         let operacao_aux = " "
      end input

      if operacao_aux = "a" then
         rollback work
      end if
   end while

   let int_flag = false
   options comment line last
   close window ctc02m00

end function  #  ctc02m00
