############################################################################
# Nome do Modulo: CTN03C01                                           Pedro #
#                                                                          #
# Consulta Distritos Policiais e Batalhoes por Cep                Out/1994 #
############################################################################

#---------------------------------------------------------------
# Modulo de consulta na tabela dpakbat
# Gerado por: ct24h em: 24/10/94
#---------------------------------------------------------------

database porto

define i              smallint
define gm_seqpesquisa smallint

define b_ctn03c01  record
   battip          like dpakbat.battip
end record

#---------------------------------------------------------------
function ctn03c01( k_ctn03c01 )
#---------------------------------------------------------------
#

   define k_ctn03c01 record
     endcep   like  glaklgd.lgdcep
   end record



   open window w_ctn03c01 at 4,2 with form "ctn03c01"

   let gm_seqpesquisa = 0

   menu "D.POLICIAL/BATALHOES"

   command key ("S") "Seleciona"  "Pesquisa tabela conforme criterios"
           message ""
           if k_ctn03c01.endcep is null     then
              error "Nenhum logradouro foi selecionado!"
              next option "Encerra"
           else
              clear form
              call pesquisa_ctn03c01(k_ctn03c01.*)
              let  gm_seqpesquisa = 0
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key ("P") "Proxima_regiao" "Pesquisa Proxima Regiao do Cep"
           message ""
           if k_ctn03c01.endcep is null     then
              error "Nenhum Cep Selecionado!"
              next option "Encerra"
           else
              let  gm_seqpesquisa = gm_seqpesquisa + 1
              call proxreg_ctn03c01(k_ctn03c01.*)
              if  i  >  1   then
                  next option "Encerra"
              else
                  next option "Proxima_regiao"
              end if
           end if

   command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
           exit menu
   end menu

   close window w_ctn03c01

end function  # ctn03c01

#-------------------------------------------------------------------
function pesquisa_ctn03c01(k_ctn03c01 )
#-------------------------------------------------------------------
   define k_ctn03c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn03c01 array[100] of record
      batnom         like dpakbat.batnom   ,
      batnum         like dpakbat.batnum   ,
      endlgd         like dpakbat.endlgd   ,
      endbrr         like dpakbat.endbrr   ,
      dddcod         like dpakbat.dddcod   ,
      teltxt         like dpakbat.teltxt   ,
      endcep         like glaklgd.lgdcep   ,
      endcepcmp      like glaklgd.lgdcepcmp,
      tipo           char (10)             ,
      endcid         like dpakbat.endcid   ,
      endufd         like dpakbat.endufd
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

	for	w_pf1  =  1  to  100
		initialize  a_ctn03c01[w_pf1].*  to  null
	end	for

   input  by  name b_ctn03c01.battip

      before field battip
         display by name b_ctn03c01.battip
            attribute (reverse)

      after field battip
         display by name b_ctn03c01.battip

         case b_ctn03c01.battip
              when "D"
                display "D.policial"  to nometipo
              when "B"
                display "Batalhoes"   to nometipo
              otherwise
                let b_ctn03c01.battip = " "
         end case

   end input

   let int_flag = false

   while not int_flag
      if b_ctn03c01.battip   =   "B"  or
         b_ctn03c01.battip   =   "D"  then
         let comando2 = " and dpakbat.battip = '", b_ctn03c01.battip, "'"
      else
         initialize comando2 to null
      end if

      let comando1 =
       " select",
          " dpakbat.batnom,",
          " dpakbat.batnum,",
          " dpakbat.endlgd,",
          " dpakbat.endbrr,",
          " dpakbat.dddcod,",
          " dpakbat.teltxt,",
          " dpakbat.endcep,",
          " dpakbat.endcepcmp,",
          " dpakbat.battip,",
          " dpakbat.endcid,",
          " dpakbat.endufd ",
     " from     dpakbat ",
     " where ",
          " dpakbat.endcep     = ", k_ctn03c01.endcep ,
            comando2 clipped,
          " order by ",
             " battip,",
             " endcep,",
             " batnom "

      prepare p_ctn03c01_001  from  comando1
      declare c_ctn03c01_001 cursor for p_ctn03c01_001

      let i = 1

      foreach c_ctn03c01_001 into a_ctn03c01[i].*
         if a_ctn03c01[i].tipo   = "B"  then
            let a_ctn03c01[i].tipo   = "Batalhao"
         else
            let a_ctn03c01[i].tipo   = "D.policial"
         end if

         let i          = i + 1

         if i > 100 then
	    error "Limite de consulta excedido (100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn03c01 to s_ctn03c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error "Nenhum registro localizado neste cep - Tente Proxima_regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  ctn03c01

#-------------------------------------------------------------------
function proxreg_ctn03c01(k_ctn03c01 )
#-------------------------------------------------------------------
   define k_ctn03c01 record
     endcep   like  glaklgd.lgdcep
   end record

   define a_ctn03c01 array[100] of record
      batnom         like dpakbat.batnom   ,
      batnum         like dpakbat.batnum   ,
      endlgd         like dpakbat.endlgd   ,
      endbrr         like dpakbat.endbrr   ,
      dddcod         like dpakbat.dddcod   ,
      teltxt         like dpakbat.teltxt   ,
      endcep         like glaklgd.lgdcep   ,
      endcepcmp      like glaklgd.lgdcepcmp,
      tipo           char (10)             ,
      endcid         like dpakbat.endcid   ,
      endufd         like dpakbat.endufd
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

	for	w_pf1  =  1  to  100
		initialize  a_ctn03c01[w_pf1].*  to  null
	end	for

   let  aux_cep = k_ctn03c01.endcep

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
       error "Nao ha' nenhum registro localizado nesta regiao!"
       message " "
       return
   end case

   message " Aguarde, pesquisando... ", aux_cep       attribute(reverse)

   let int_flag = false

   while not int_flag
      if b_ctn03c01.battip   =   "B"  or
         b_ctn03c01.battip   =   "D"  then
         let comando2 = " and dpakbat.battip = '", b_ctn03c01.battip, "'"
      else
         initialize comando2 to null
      end if

      let comando1 =
       " select",
          " dpakbat.batnom,",
          " dpakbat.batnum,",
          " dpakbat.endlgd,",
          " dpakbat.endbrr,",
          " dpakbat.dddcod,",
          " dpakbat.teltxt,",
          " dpakbat.endcep,",
          " dpakbat.endcepcmp,",
          " dpakbat.battip,",
          " dpakbat.endcid,",
          " dpakbat.endufd ",
     " from     dpakbat ",
     " where ",
          " dpakbat.endcep     matches   '", aux_cep , "'",
            comando2 clipped,
          " order by ",
             " battip,",
             " endcep desc,",
             " batnom "

      prepare p_ctn03c01_002 from  comando1
      declare c_ctn03c01_002 cursor for p_ctn03c01_002

      let i = 1

      foreach c_ctn03c01_002 into a_ctn03c01[i].*
         if a_ctn03c01[i].tipo   = "B"  then
            let a_ctn03c01[i].tipo   = "Batalhao"
         else
            let a_ctn03c01[i].tipo   = "D.policial"
         end if

         let i          = i + 1

         if i > 100 then
	    error "Limite de consulta excedido(100). Avise a informatica!"
	    exit foreach
         end if
      end foreach

      message ""
      if  i  >  1  then
          call set_count(i-1)
          display array a_ctn03c01 to s_ctn03c01.*
             on key (interrupt,control-m)
                exit display
          end display
      else
          error "Nenhum registro localizado nesta regiao - Tente Proxima_regiao!"
          let int_flag =  true
      end if
   end while

   let int_flag = false

end function  #  proxreg_ctn03c01 #Proxima  Regiao do Cep

