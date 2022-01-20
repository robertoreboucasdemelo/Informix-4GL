############################################################################
# Nome do Modulo: CTN19C01                                           Pedro #
#                                                                  Marcelo #
# Consulta Sucursais dos Convenios                                Nov/1995 #
############################################################################

database porto

define i smallint
define gm_seqpesquisa smallint

define  b_ctn19c00  record
        cvnnum      like datkscv.cvnnum    ,
        cvnnom      like iddkdominio.cpodes
end     record

#---------------------------------------------------------------
function ctn19c00( k_ctn19c00 )
#---------------------------------------------------------------
#
   define k_ctn19c00 record
     scvendcep   like  glaklgd.lgdcep
   end record



   open window w_ctn19c00 at 4,2 with form "ctn19c00"

   let gm_seqpesquisa = 0

   menu "SUCURSAIS"

   command key ("S") "Seleciona"  "Pesquisa tabela conforme criterios"
           message ""
           if k_ctn19c00.scvendcep is null     then
              error " Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              clear form
              call pesquisa_ctn19c00(k_ctn19c00.*)
              let  gm_seqpesquisa = 0
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima Regiao do Cep"
           message ""
           if k_ctn19c00.scvendcep is null     then
              error " Nenhum Cep Selecionado!"
              next option "Encerra"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn19c00(k_ctn19c00.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn19c00

end function  # ctn19c00

#-------------------------------------------------------------------
function pesquisa_ctn19c00(k_ctn19c00 )
#-------------------------------------------------------------------
   define k_ctn19c00 record
     scvendcep   like  glaklgd.lgdcep
   end record

   define a_ctn19c00 array[50] of record
      scvsucnom         like datkscv.scvsucnom ,
      scvsuccod         like datkscv.scvsuccod ,
      scvendlog         like datkscv.scvendlog ,
      scvendbrr         like datkscv.scvendbrr ,
      scvdddcod         like datkscv.scvdddcod ,
      scvtelnum         like datkscv.scvtelnum ,
      scvfaxnum         like datkscv.scvfaxnum ,
      scvendcep         like glaklgd.lgdcep    ,
      scvendcepcmp      like glaklgd.lgdcepcmp ,
      scvendcid         like datkscv.scvendcid ,
      scvufd            like datkscv.scvufd
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer
   define comando1     char (500)
   define comando2     char (100)


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	comando1  =  null
	let	comando2  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn19c00[w_pf1].*  to  null
	end	for

   input  by  name b_ctn19c00.cvnnum

      before field cvnnum
         display by name b_ctn19c00.cvnnum
            attribute (reverse)

      after field cvnnum
         display by name b_ctn19c00.cvnnum

         if b_ctn19c00.cvnnum   is null   then
            error " Codigo do Convenio deve ser informado !!"
            call ctn20c00()  returning  b_ctn19c00.cvnnum
            next field cvnnum
         else
             initialize b_ctn19c00.cvnnom  to null
             select cpodes
               into b_ctn19c00.cvnnom
               from datkdominio
              where cponom = "ligcvntip"      and
                    cpocod = b_ctn19c00.cvnnum

              if status = notfound   then
                 error " Convenio nao cadastrado !!"
                 call ctn20c00()  returning  b_ctn19c00.cvnnum
                 next field cvnnum
              else
                 display b_ctn19c00.cvnnom to cvnnom
              end if
          end if
   end input

   let int_flag = false

   while not int_flag
      let comando2 = " and datkscv.cvnnum = '", b_ctn19c00.cvnnum, "'"
      let comando1 =
       " select",
          " datkscv.scvsucnom,",
          " datkscv.scvsuccod,",
          " datkscv.scvendlog,",
          " datkscv.scvendbrr,",
          " datkscv.scvdddcod,",
          " datkscv.scvtelnum,",
          " datkscv.scvfaxnum,",
          " datkscv.scvendcep,",
          " datkscv.scvendcepcmp,",
          " datkscv.scvendcid,",
          " datkscv.scvufd ",
     " from     datkscv ",
     " where ",
          " datkscv.scvendcep     = ", k_ctn19c00.scvendcep ,
            comando2 clipped,
          " order by ",
             " scvendcep,",
             " scvsucnom "

      prepare comando_aux  from  comando1
      declare c_ctn19c00 cursor for comando_aux

      let i = 1

      foreach c_ctn19c00 into a_ctn19c00[i].*
         let i          = i + 1
         if i > 50 then
	    error " Limite de consulta excedido (50). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn19c00 to s_ctn19c00.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error " Nenhum registro localizado neste cep - Tente Proxima_regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn19c00

#-------------------------------------------------------------------
function proxreg_ctn19c00(k_ctn19c00 )
#-------------------------------------------------------------------
   define k_ctn19c00 record
     scvendcep   like  glaklgd.lgdcep
   end record

   define a_ctn19c00 array[50] of record
      scvsucnom         like datkscv.scvsucnom ,
      scvsuccod         like datkscv.scvsuccod ,
      scvendlog         like datkscv.scvendlog ,
      scvendbrr         like datkscv.scvendbrr ,
      scvdddcod         like datkscv.scvdddcod ,
      scvtelnum         like datkscv.scvtelnum ,
      scvfaxnum         like datkscv.scvfaxnum ,
      scvendcep         like glaklgd.lgdcep    ,
      scvendcepcmp      like glaklgd.lgdcepcmp ,
      scvendcid         like datkscv.scvendcid ,
      scvufd         like datkscv.scvufd
   end record

   define nro_lin_corr integer
   define scr_lin_corr integer
   define comando1     char (500)
   define comando2     char (100)
   define aux_cep      char (5)


	define	w_pf1	integer

	let	nro_lin_corr  =  null
	let	scr_lin_corr  =  null
	let	comando1  =  null
	let	comando2  =  null
	let	aux_cep  =  null

	for	w_pf1  =  1  to  50
		initialize  a_ctn19c00[w_pf1].*  to  null
	end	for

   let  aux_cep = k_ctn19c00.scvendcep

   if   gm_seqpesquisa   =   1  then
        if aux_cep[4,5]     =   "00"  then
           let  gm_seqpesquisa   =   2
        end if
   end if

   case gm_seqpesquisa
     when  1
       let  aux_cep[5,5] = "*"
     when  2
       let  aux_cep[4,5] = "* "
     when  3
       let  aux_cep[3,5] = "*  "
     when  4
       let  aux_cep[2,5] = "*   "
     otherwise
       error " Nao ha' nenhum registro localizado nesta regiao!"
       message " "
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep       attribute(reverse)

   let int_flag = false

   while not int_flag
      let comando2 = " and datkscv.cvnnum = '", b_ctn19c00.cvnnum, "'"
      let comando1 =
       " select",
          " datkscv.scvsucnom,",
          " datkscv.scvsuccod,",
          " datkscv.scvendlog,",
          " datkscv.scvendbrr,",
          " datkscv.scvdddcod,",
          " datkscv.scvtelnum,",
          " datkscv.scvfaxnum,",
          " datkscv.scvendcep,",
          " datkscv.scvendcepcmp,",
          " datkscv.scvendcid,",
          " datkscv.scvufd ",
     " from     datkscv ",
     " where ",
          " datkscv.scvendcep     matches   '", aux_cep , "'",
            comando2 clipped,
          " order by ",
             " scvendcep desc,",
             " scvsucnom "

      prepare comando_aux2 from  comando1
      declare prim_ctn19c00 cursor for comando_aux2

      let i = 1

      foreach prim_ctn19c00 into a_ctn19c00[i].*
         let i          = i + 1

         if i > 50 then
	    error " Limite de consulta excedido(50). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message ""
      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn19c00 to s_ctn19c00.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error " Nenhum registro localizado nesta regiao - Tente Proxima_regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn19c00 #Proxima  Regiao do Cep

