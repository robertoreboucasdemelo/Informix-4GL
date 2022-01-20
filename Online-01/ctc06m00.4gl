 ############################################################################
 # Nome do Modulo: CTC06M00                                        Marcelo  #
 #                                                                 Gilberto #
 # Manutencao no Cadastro de Servicos                              Set/1994 #
 ############################################################################

 #----------------------------------------------------------------
 # Modulo de manutencao em array na tabela dpckserv
 # Gerado por: evida em: 14/09/94
 #----------------------------------------------------------------

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc06m00()
#----------------------------------------------------------------

   define arr_aux integer
   define scr_aux integer
   define operacao_aux char(1)
   define ws_confirma  char(1)

   define a_ctc06m00 array[100] of record
      pstsrvtip like dpckserv.pstsrvtip,
      pstsrvdes like dpckserv.pstsrvdes
   end record

   if not get_niv_mod(g_issk.prgsgl, "ctc06m00") then
      error "Modulo sem nivel de consulta e atualizacao!"
      return
   end if

   options comment line last - 1

   open window ctc06m00 at 6,2 with form "ctc06m00"
        attribute (form line first)

   message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

   declare c_ctc06m00 cursor for
      select pstsrvtip,
             pstsrvdes
        from dpckserv
       order by pstsrvtip

   let int_flag = false

   while not int_flag
      let arr_aux = 1
      foreach c_ctc06m00 into a_ctc06m00[arr_aux].*
         let arr_aux = arr_aux + 1
         if arr_aux > 100 then
            error "Limite de consulta excedido (100), AVISE A INFORMATICA!"
            exit program
         end if
      end foreach

      call set_count(arr_aux-1)

      input array a_ctc06m00 without defaults from dpckserv.*
      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         if arr_aux <= arr_count() then
            begin work
            let operacao_aux = "a"
            declare u_ctc06m00 cursor for
               select pstsrvtip,
       	              pstsrvdes
                 from dpckserv
                where pstsrvtip = a_ctc06m00[arr_aux].pstsrvtip
            for update
            open u_ctc06m00
            fetch u_ctc06m00 into a_ctc06m00[arr_aux].*
	    display a_ctc06m00[arr_aux].* to dpckserv[scr_aux].*
            next field pstsrvdes
         end if

      before insert
         let operacao_aux = "i"
         initialize a_ctc06m00[arr_aux].pstsrvtip,
                    a_ctc06m00[arr_aux].pstsrvdes
               like dpckserv.pstsrvtip,
                    dpckserv.pstsrvdes

      before field pstsrvtip
         if operacao_aux = "a" then
	    next field pstsrvdes
         end if
         display a_ctc06m00[arr_aux].pstsrvtip to
        	   dpckserv[scr_aux].pstsrvtip attribute (reverse)

      after field pstsrvtip
         display a_ctc06m00[arr_aux].pstsrvtip to
                   dpckserv[scr_aux].pstsrvtip

         #---------------------------------------------------------
         # Verifica existencia da linha a incluir
         #---------------------------------------------------------
         select * from dpckserv
          where pstsrvtip = a_ctc06m00[arr_aux].pstsrvtip

         if sqlca.sqlcode <> NOTFOUND then
            error "Tipo de servico ja' cadastrado!"
            next field pstsrvtip
         end if

      before field pstsrvdes
         display a_ctc06m00[arr_aux].pstsrvdes to
    	           dpckserv[scr_aux].pstsrvdes attribute (reverse)

      after field pstsrvdes
         display a_ctc06m00[arr_aux].pstsrvdes to
                   dpckserv[scr_aux].pstsrvdes

      on key (interrupt)
         exit input

      before delete
         call cts08g01("A","S","","CONFIRMA A EXCLUSAO","DO REGISTRO ?","")
              returning ws_confirma

         if ws_confirma = "N" then
            exit input
         end if
         if not delete_dpckserv ( a_ctc06m00[arr_aux].pstsrvtip ) then
	    let int_flag = false
            exit input
         end if
         if operacao_aux = "a" then
	    commit work
            let operacao_aux = " "
         end if
	 initialize a_ctc06m00[arr_aux].* to null
	 display a_ctc06m00[arr_aux].* to dpckserv[scr_aux].*

      after row
         if a_ctc06m00[arr_aux].pstsrvtip is null then
            let operacao_aux = " "
            error "Tipo de servico nao selecionado!"
         end if

         case operacao_aux
	 when "a"
            update dpckserv set
	       pstsrvdes = a_ctc06m00[arr_aux].pstsrvdes
            where current of u_ctc06m00
            commit work
         when "i"
            insert into dpckserv ( pstsrvtip, pstsrvdes )
            values ( a_ctc06m00[arr_aux].pstsrvtip ,
                     a_ctc06m00[arr_aux].pstsrvdes )

         end case
         let operacao_aux = " "
      end input
      if operacao_aux = "a" then
         rollback work
      end if
   end while
   let int_flag = false
   options comment line last
   close window ctc06m00

end function  #  ctc06m00
