###############################################################################
# Nome do Modulo: cta01m53                                           Marcelo  #
#                                                                    Gilberto #
# Pesquisa Placa do Veiculo                                          Jan/1996 #
###############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
 function  cta01m53(par_vcllicnum)
#---------------------------------------------------------------

define par_vcllicnum like epcmitem.vcllicnum
define ret_pcapticod like eccmpti.pcapticod

define a_cta01m53 array [50] of record
       pcaclinom    like eccmcli.pcaclinom     ,
       cartao       dec(19,0)                  ,
       veiculo      char(40)                   ,
       cor          char(12)                   ,
       vclanomdl    like eccmitem.vclanomdl    ,
       vcllicnum    like epcmitem.vcllicnum    ,
       pcapticod    like eccmpti.pcapticod
end record

define ws           record
       pcaprpnum    like epcmproposta.pcaprpnum,
       vclcoddig    like epcmitem.vclcoddig    ,
       vclcorcod    like epcmitem.vclcorcod    ,
       veiculo      char(40)                   ,
       cor          char(12)                   ,
       vclanomdl    like eccmitem.vclanomdl    ,
       vcllicnum    like epcmitem.vcllicnum
end record

define arr_aux       integer
define aux_pcaclicod dec(19,0)


	define	w_pf1	integer

	let	ret_pcapticod  =  null
	let	arr_aux  =  null
	let	aux_pcaclicod  =  null

	for	w_pf1  =  1  to  50
		initialize  a_cta01m53[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

    let arr_aux = 1
    initialize a_cta01m53    to null
    initialize ws.*          to null
    initialize ret_pcapticod to null

#--------------------------------------------------------#
#          Pesquisa por placa (dados do cartao)          #
#--------------------------------------------------------#

    declare   c_cta01m53_001  cursor for
       select pcaprpnum,
              vclcoddig,
              vcllicnum,
              vclcorcod,
              vclanomdl
         from epcmitem
        where vcllicnum = par_vcllicnum

    foreach   c_cta01m53_001  into ws.pcaprpnum, ws.vclcoddig,
                            ws.vcllicnum, ws.vclcorcod,
                            ws.vclanomdl
       select pcaclicod
         into aux_pcaclicod
         from eccmcli
         where pcaprpnum = ws.pcaprpnum

       call cpcgeral7(ws.vclcoddig) returning ws.veiculo

       select cpodes
         into ws.cor
         from iddkdominio
        where cponom = "vclcorcod"
          and cpocod = ws.vclcorcod

       if sqlca.sqlcode = notfound    then
          let ws.cor = "N/CADASTRADO"
       end if

       #--------------------------------------------------------#
       #   Procura todos os cartoes que possuem placa igual     #
       #--------------------------------------------------------#
       declare c_cta01m53_002  cursor for
         select pcaclinom, pcapticod
           from eccmcli     , eccmcta   , eccmpti
          where eccmcli.pcaclicod      = aux_pcaclicod               and
             #  eccmpti.pcaptitip      = 1                           and
                eccmcli.pcaclicod      = eccmcta.pcaclicod           and
                eccmpti.pcactacod      = eccmcta.pcactacod

       foreach c_cta01m53_002 into a_cta01m53[arr_aux].pcaclinom,
                             a_cta01m53[arr_aux].pcapticod

          let a_cta01m53[arr_aux].veiculo   = ws.veiculo
          let a_cta01m53[arr_aux].cor       = ws.cor
          let a_cta01m53[arr_aux].vclanomdl = ws.vclanomdl
          let a_cta01m53[arr_aux].vcllicnum = ws.vcllicnum
          let a_cta01m53[arr_aux].cartao    = a_cta01m53[arr_aux].pcapticod

          let arr_aux = arr_aux + 1
          if arr_aux  >  50   then
             error " Pesquisa com mais de 50 itens !!"
             continue foreach
          end if

       end foreach

    end foreach

#--------------------------------------------------------#
#    Se mais de um item for encontrado, exibe POP-UP     #
#--------------------------------------------------------#
    if arr_aux = 2 then
       let ret_pcapticod = a_cta01m53[arr_aux - 1].pcapticod
    end if

    if arr_aux > 2 then
       open window cta01m53 at 4,2 with form "cta01m53"
            attribute(form line 1)

       message " (F17)Abandona, (F8)Seleciona"
       call set_count(arr_aux-1)

       display array a_cta01m53 to s_cta01m53.*
          on key (interrupt,control-c)
             initialize a_cta01m53 to null
             exit display

          on key (f8)
             let arr_aux = arr_curr()
             let ret_pcapticod = a_cta01m53[arr_aux].pcapticod
             exit display
       end display

       close window  cta01m53
    end if

    return  ret_pcapticod

end function # cta01m53

