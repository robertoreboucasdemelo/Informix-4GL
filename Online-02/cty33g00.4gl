#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty33g00.4gl                                               #
# Analista Resp : R.Fornax                                                   #
#                 Recupera Utilizacoes - Limites de Servico a Residencia     #
#............................................................................#
# Desenvolvimento: R.Fornax                                                  #
# Liberacao      : 08/02/2014                                                #
#............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define a_cty33g00 array[05] of record
       assistencia  char(25) ,
       qtd_uti      integer  ,
       qtd_lim      integer
end record

define a_array array[05] of record
       socntzcod like datksocntz.socntzcod
end record

#------------------------------------------------------------
function cty33g00_calcula_residencia(lr_param)
#------------------------------------------------------------

define lr_param record
    ramcod      smallint
   ,succod      like abbmitem.succod
   ,aplnumdig   like abbmitem.aplnumdig
   ,itmnumdig   like abbmitem.itmnumdig
   ,c24astcod   like datkassunto.c24astcod
   ,bnfnum      like datrsrvsau.bnfnum
   ,crtsaunum   like datksegsau.crtsaunum
   ,socntzcod   like datksocntz.socntzcod
   ,tipo        integer
end record

define lr_retorno  record
    flag_limite   char(1)
   ,resultado     integer
   ,mensagem      char(80)
   ,total_uti     integer
   ,total_lim     integer
   ,saldo         integer
   ,cabecalho     char(50)
   ,msg           char(50)
   ,acessa        char(01)
end record

define l_idx integer,
       l_for integer

initialize lr_retorno.* to null

let lr_retorno.total_uti   = 0
let lr_retorno.total_lim   = 0
let lr_retorno.saldo       = 0
let lr_retorno.acessa      = "N"


for l_idx  =  1  to  05
  initialize  a_cty33g00[l_idx].*, a_array[l_idx].*  to  null
end for

      let lr_retorno.msg = "         Digite <CTRL-C> Para Sair"

      if lr_param.tipo = 1 then
         case lr_param.c24astcod
            when "S60"

                if g_nova.perfil = 1 or    #Tradicional
                   g_nova.perfil = 4 then  #Mulher
                   let a_array[1].socntzcod      = 1
                   let a_cty33g00[1].assistencia = "LINHA BASICA"
                   let a_array[2].socntzcod      = 41
                   let a_cty33g00[2].assistencia = "KIT'S"
                   let l_for                     = 2
                else
                   let a_array[1].socntzcod      = 1
                   let a_cty33g00[1].assistencia = "LINHA BASICA"
                   let a_array[2].socntzcod      = 41
                   let a_cty33g00[2].assistencia = "KIT'S"
                   let a_array[3].socntzcod      = 206
                   let a_cty33g00[3].assistencia = "CONECTIVIDADE"
                   let a_array[4].socntzcod      = 207
                   let a_cty33g00[4].assistencia = "MUDANCA DE MOBILIARIO"
                   let l_for                     = 4
                end if


                for l_idx  =  1  to  l_for

                    call cty31g00_valida_envio_residencia(lr_param.ramcod          ,
                                                          lr_param.succod          ,
                                                          lr_param.aplnumdig       ,
                                                          lr_param.itmnumdig       ,
                                                          lr_param.c24astcod       ,
                                                          lr_param.bnfnum          ,
                                                          lr_param.crtsaunum       ,
                                                          a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim

                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if

                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim

                end for

             when "S63"

                let a_array[1].socntzcod      = 11
                let a_cty33g00[1].assistencia = "LINHA BRANCA"

                let a_array[2].socntzcod      = 28
                let a_cty33g00[2].assistencia = "AR CONDICIONADO"

                for l_idx  =  1  to  02

                    call cty31g00_valida_envio_residencia(lr_param.ramcod          ,
                                                          lr_param.succod          ,
                                                          lr_param.aplnumdig       ,
                                                          lr_param.itmnumdig       ,
                                                          lr_param.c24astcod       ,
                                                          lr_param.bnfnum          ,
                                                          lr_param.crtsaunum       ,
                                                          a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim

                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if

                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim

                end for

           when "S41"

                let a_array[1].socntzcod      = 1
                let a_cty33g00[1].assistencia = "LINHA BASICA/BRANCA"


                for l_idx  =  1  to  01

                    call cty31g00_valida_envio_guincho(lr_param.ramcod          ,
                                                       lr_param.succod          ,
                                                       lr_param.aplnumdig       ,
                                                       lr_param.itmnumdig       ,
                                                       lr_param.c24astcod       ,
                                                       a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim

                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if

                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim

                end for

            when "S42"

                let a_array[1].socntzcod      = 1
                let a_cty33g00[1].assistencia = "LINHA BASICA/BRANCA"


                for l_idx  =  1  to  01

                    call cty31g00_valida_envio_guincho(lr_param.ramcod          ,
                                                       lr_param.succod          ,
                                                       lr_param.aplnumdig       ,
                                                       lr_param.itmnumdig       ,
                                                       lr_param.c24astcod       ,
                                                       a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim

                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if
                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim
                end for
         end case
      else
      	 case lr_param.c24astcod
            when "S60"
                let a_array[1].socntzcod      = 1
                let a_cty33g00[1].assistencia = "LINHA BASICA"
                for l_idx  =  1  to  01
                    call cty34g00_valida_envio_residencia(lr_param.ramcod          ,
                                                          lr_param.succod          ,
                                                          lr_param.aplnumdig       ,
                                                          lr_param.itmnumdig       ,
                                                          lr_param.c24astcod       ,
                                                          lr_param.bnfnum          ,
                                                          lr_param.crtsaunum       ,
                                                          a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim
                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if
                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim
                end for
           when "S63"
                let a_array[1].socntzcod      = 11
                let a_cty33g00[1].assistencia = "LINHA BRANCA"
                for l_idx  =  1  to  01
                    call cty34g00_valida_envio_residencia(lr_param.ramcod          ,
                                                          lr_param.succod          ,
                                                          lr_param.aplnumdig       ,
                                                          lr_param.itmnumdig       ,
                                                          lr_param.c24astcod       ,
                                                          lr_param.bnfnum          ,
                                                          lr_param.crtsaunum       ,
                                                          a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim
                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if
                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim
                end for
           when "S41"
                let a_array[1].socntzcod      = 1
                let a_cty33g00[1].assistencia = "LINHA BASICA/BRANCA"
                for l_idx  =  1  to  01
                    call cty34g00_valida_envio_guincho(lr_param.ramcod          ,
                                                       lr_param.succod          ,
                                                       lr_param.aplnumdig       ,
                                                       lr_param.itmnumdig       ,
                                                       lr_param.c24astcod       ,
                                                       a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim
                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if
                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim
                end for
            when "S42"
                let a_array[1].socntzcod      = 1
                let a_cty33g00[1].assistencia = "LINHA BASICA/BRANCA"
                for l_idx  =  1  to  01
                    call cty34g00_valida_envio_guincho(lr_param.ramcod          ,
                                                       lr_param.succod          ,
                                                       lr_param.aplnumdig       ,
                                                       lr_param.itmnumdig       ,
                                                       lr_param.c24astcod       ,
                                                       a_array[l_idx].socntzcod )
                    returning lr_retorno.resultado
                             ,lr_retorno.mensagem
                             ,lr_retorno.flag_limite
                             ,a_cty33g00[l_idx].qtd_uti
                             ,a_cty33g00[l_idx].qtd_lim
                    if a_cty33g00[l_idx].qtd_lim = 0 then
                    	  initialize a_cty33g00[l_idx].* to null
                    	  continue for
                    else
                    	  let lr_retorno.acessa = "S"
                    end if
                    let lr_retorno.total_uti =  lr_retorno.total_uti +  a_cty33g00[l_idx].qtd_uti
                    let lr_retorno.total_lim =  lr_retorno.total_lim +  a_cty33g00[l_idx].qtd_lim
                end for
         end case

      end if
      let lr_retorno.saldo = lr_retorno.total_lim - lr_retorno.total_uti

      if lr_retorno.saldo < 1 then
        	let lr_retorno.cabecalho = "             LIMITES ESGOTADOS"
        	let lr_retorno.flag_limite   = "S"
      else
      	  let lr_retorno.cabecalho = "             LIMITES DISPONIVEIS"
      	  let lr_retorno.flag_limite   = "N"
      end if
      if lr_retorno.acessa = "N" then
         	let lr_retorno.flag_limite   = "S"
         	return lr_retorno.flag_limite
      end if
      open window cty33g00 at 07,17 with form "cty33g00"
     attribute (form line 1, border)

      display by name lr_retorno.cabecalho, lr_retorno.msg

      call set_count(l_idx - 1)

     display array a_cty33g00 to s_cty33g00.*

         on key (interrupt)
           exit display

      end display

      close window cty33g00

      return lr_retorno.flag_limite

end function