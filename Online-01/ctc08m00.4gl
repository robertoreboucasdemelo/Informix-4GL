############################################################################
# Nome do Modulo: CTC08M00                                          Carlos #
#                                                                          #
# Manutencao no Cadastro de Prestadores X Servicos                Out/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de manutencao em array na tabela dpatserv
# Gerado por: ct24h em: 18/10/94
#---------------------------------------------------------------

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function ctc08m00( k_ctc08m00 )
#---------------------------------------------------------------

   define k_ctc08m00 record
          pstcoddig  like dpatserv.pstcoddig,
          nomgrr     like dpaksocor.nomgrr
   end record

   define arr_aux        smallint
   define scr_aux        smallint
   define operacao_aux   char(1)
   define ws_count       smallint

   define a_ctc08m00 array[100] of record
      pstsrvtip      like dpatserv.pstsrvtip,
      pstsrvdes      like dpckserv.pstsrvdes,
      pstsrvctg      like dpatserv.pstsrvctg
   end record

   define l_prshstdes  char(2000),
          l_pstsrvctgant like dpatserv.pstsrvctg

   open window ctc08m00 at 6,2 with form "ctc08m00"
        attribute(form line first)

   display by name k_ctc08m00.*

   declare c_ctc08m00 cursor for
     select dpatserv.pstsrvtip,
            dpckserv.pstsrvdes,
            dpatserv.pstsrvctg
       from dpatserv, dpckserv
      where dpatserv.pstcoddig = k_ctc08m00.pstcoddig
        and dpckserv.pstsrvtip = dpatserv.pstsrvtip
      order by  dpatserv.pstsrvtip

   let int_flag = false

   while not int_flag
      let arr_aux = 1
      foreach c_ctc08m00 into a_ctc08m00[arr_aux].*
         let arr_aux = arr_aux + 1
         if arr_aux > 100 then
            error "Limite excedido. AVISE A INFORMATICA!"
            exit program
         end if
      end foreach

      call set_count(arr_aux-1)

      input array a_ctc08m00 without defaults from s_ctc08m00.*

      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         if arr_aux <= arr_count() then
            begin work
            let operacao_aux = "a"
            display a_ctc08m00[arr_aux].* to
                    s_ctc08m00[scr_aux].*
            next field pstsrvctg
         end if

      before insert
          let operacao_aux = "i"
          initialize
            a_ctc08m00[arr_aux].pstsrvtip,
            a_ctc08m00[arr_aux].pstsrvdes,
            a_ctc08m00[arr_aux].pstsrvctg
          like
            dpatserv.pstsrvtip,
            dpckserv.pstsrvdes,
            dpatserv.pstsrvctg

      before field pstsrvtip
         if operacao_aux = "a" then
	        next field pstsrvctg
         end if
         display a_ctc08m00[arr_aux].pstsrvtip to
	        s_ctc08m00[scr_aux].pstsrvtip attribute (reverse)

      after field pstsrvtip
         display a_ctc08m00[arr_aux].pstsrvtip to
             s_ctc08m00[scr_aux].pstsrvtip

         if a_ctc08m00[arr_aux].pstsrvtip is null or
            a_ctc08m00[arr_aux].pstsrvtip = " "   then
            error "Codigo do servico nao informado!"
	        call ctn06c03() returning  a_ctc08m00[arr_aux].pstsrvtip,
	                                   a_ctc08m00[arr_aux].pstsrvdes
            if a_ctc08m00[arr_aux].pstsrvtip  is null   then
               error "Tipo de Servico e' obrigatorio!"
               next field pstsrvtip
            end if
         else
            #---------------------------------------------------------
            # Verificacao de integridade da chave fkdpckserv
            #---------------------------------------------------------
            select pstsrvdes
              into a_ctc08m00[arr_aux].pstsrvdes
              from dpckserv
             where pstsrvtip = a_ctc08m00[arr_aux].pstsrvtip

            if status = notfound then
               error "Nao existe correspondente em servico!"
               call ctn06c03() returning  a_ctc08m00[arr_aux].pstsrvtip,
   	                                  a_ctc08m00[arr_aux].pstsrvdes
               if a_ctc08m00[arr_aux].pstsrvtip  is null   then
                  error "Tipo de Servico e' obrigatorio!"
                  next field pstsrvtip
               end if
            end if
         end if

         display a_ctc08m00[arr_aux].pstsrvtip to
                 s_ctc08m00[scr_aux].pstsrvtip
         display a_ctc08m00[arr_aux].pstsrvdes to
                 s_ctc08m00[scr_aux].pstsrvdes

         #---------------------------------------------------------
         # Verifica a existencia da linha a incluir
         #---------------------------------------------------------
         select * from dpatserv
          where pstcoddig = k_ctc08m00.pstcoddig
            and pstsrvtip = a_ctc08m00[arr_aux].pstsrvtip

         if status = 0        then
            error "Tipo de servico ja' cadastrado para este posto!"
            next field pstsrvtip
         end if

      before field pstsrvctg
         display a_ctc08m00[arr_aux].pstsrvctg to
    	    dpatserv[scr_aux].pstsrvctg attribute (reverse)
         let l_pstsrvctgant = a_ctc08m00[arr_aux].pstsrvctg

      after field pstsrvctg
         display a_ctc08m00[arr_aux].pstsrvctg to
            s_ctc08m00[scr_aux].pstsrvctg

         if a_ctc08m00[arr_aux].pstsrvctg  is null   or
            a_ctc08m00[arr_aux].pstsrvctg  =  "  "   then
            error "Qualidade deve ser: 1-Otimo, 2-Bom, 3-Regular, 4-Ruim"
            next field pstsrvctg
         else
            if a_ctc08m00[arr_aux].pstsrvctg  <>  1   and
               a_ctc08m00[arr_aux].pstsrvctg  <>  2   and
               a_ctc08m00[arr_aux].pstsrvctg  <>  3   and
               a_ctc08m00[arr_aux].pstsrvctg  <>  4   then
               error "Qualidade do servico invalida!"
               next field pstsrvctg
            end if
         end if

      on key (interrupt)
         exit input

      before delete
          if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
             exit input
          end if

          let ws_count = 0
          select count(*) into ws_count
            from dpatserv
           where pstcoddig = k_ctc08m00.pstcoddig
          if ws_count = 1   then
             error "Prestador deve possuir no minimo um servico cadastrado !!"
             exit input
          end if

         if not delete_dpatserv (k_ctc08m00.pstcoddig,
                                 a_ctc08m00[arr_aux].pstsrvtip ) then
    	    error "Remocao nao permitida, existe correspondente!"
            sleep 3
	        let int_flag = false
            exit input
         end if

         if operacao_aux = "a" then
            let l_prshstdes =
                "Tipo Servico [", a_ctc08m00[arr_aux].pstsrvtip using "<<<<&", " - ",
                a_ctc08m00[arr_aux].pstsrvdes clipped,"] excluido!"

            call ctc00m02_grava_hist(k_ctc08m00.pstcoddig,
                                     l_prshstdes,"A")
	        commit work
            let operacao_aux = " "
         end if

	     initialize a_ctc08m00[arr_aux].* to null
         let operacao_aux = "d"

	     display a_ctc08m00[arr_aux].* to
	         s_ctc08m00[scr_aux].*

      after row
         if a_ctc08m00[arr_aux].pstsrvtip is null then
            let operacao_aux = " "
            error "Tipo de servico nao selecionado!"
         end if

         case operacao_aux
	       when "a"
              update dpatserv
                 set pstsrvctg = a_ctc08m00[arr_aux].pstsrvctg
               where pstcoddig = k_ctc08m00.pstcoddig
                 and pstsrvtip = a_ctc08m00[arr_aux].pstsrvtip

              if  a_ctc08m00[arr_aux].pstsrvtip is not null and
                  a_ctc08m00[arr_aux].pstsrvctg <> l_pstsrvctgant then
                  let l_prshstdes =
                      "Qualidade do Tipo Servico [",
                      a_ctc08m00[arr_aux].pstsrvtip using "<<<<&", " - ",
                      a_ctc08m00[arr_aux].pstsrvdes clipped,"] alterada de [",
                      l_pstsrvctgant,"] para [", a_ctc08m00[arr_aux].pstsrvctg, "]."

                  call ctc00m02_grava_hist(k_ctc08m00.pstcoddig,
                                           l_prshstdes,"A")
              end if

              commit work

           when "i"
              insert into dpatserv ( pstcoddig ,
                        	         pstsrvtip ,
                         	         pstsrvctg )
              values  ( k_ctc08m00.pstcoddig,
               a_ctc08m00[arr_aux].pstsrvtip,
               a_ctc08m00[arr_aux].pstsrvctg)

              let l_prshstdes =
                  "Tipo Servico [", a_ctc08m00[arr_aux].pstsrvtip using "<<<<&", " - ",
                  a_ctc08m00[arr_aux].pstsrvdes clipped,"] incluido!"

              call ctc00m02_grava_hist(k_ctc08m00.pstcoddig,
                                       l_prshstdes,"I")
         end case

         let operacao_aux = " "

      end input

      if operacao_aux = "a" then
         rollback work
      end if
   end while

   let int_flag = false

   close window ctc08m00

end function  #  ctc08m00
