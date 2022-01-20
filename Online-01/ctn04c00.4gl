############################################################################
# Nome do Modulo: CTN04C00                                        Marcelo  #
#                                                                 Gilberto #
# Consulta Reguladores de Sinistros de Transportes                Jun/1997 #
############################################################################

database porto

#---------------------------------------------------------------
 function ctn04c00()
#---------------------------------------------------------------

 define param      record
    ufdcod         like sstkprest.endufd,
    cidnom         like sstkprest.endcid
 end record

 define d_ctn04c00 record
    sinprscod      like sstkprest.sinprscod   ,
    sinprstip      char (20)                  ,
    sinprsnom      like sstkprest.sinprsnom   ,
    endlgd         like sstkprest.endlgd      ,
    endbrr         like sstkprest.endbrr      ,
    endcid         like sstkprest.endcid      ,
    endufd         like sstkprest.endufd      ,
    dddcod         like sstkprest.dddcod      ,
    telnum         like sstkprest.telnum      ,
    cllddd         like sstkprest.cllddd      ,
    clltelnum      like sstkprest.clltelnum   ,
    prssrvultdat   like sstkprest.prssrvultdat,
    obs1           char (50)                  ,
    obs2           char (50)                  ,
    obs3           char (50)
 end record

 define ws         record
    sinprscod      like sstkprest.sinprscod   ,
    sintraprstip   like sstkprest.sintraprstip,
    obs            like sstkprest.obs
 end record

 define prompt_key char (01)


	let	prompt_key  =  null

	initialize  param.*  to  null

	initialize  d_ctn04c00.*  to  null

	initialize  ws.*  to  null

 initialize d_ctn04c00.*  to null
 initialize param.*       to null
 initialize ws.*          to null

 let int_flag = false

 open window w_ctn04c00 at 06,02 with form "ctn04c00"
              attribute (form line 1)

 while true
    clear form

    input by name param.ufdcod,
                  param.cidnom  without defaults

       before field ufdcod
          display by name param.ufdcod attribute(reverse)

       after field ufdcod
          display by name param.ufdcod

          if param.ufdcod is null  then
             error "Informe a Unidade Federativa para pesquisa!"
             next field ufdcod
          end if

          select ufdcod from glakest
           where ufdcod = param.ufdcod

          if sqlca.sqlcode  =  notfound   then
             error "Unidade Federativa invalida!"
             next field ufdcod
          end if

       before field cidnom
          display by name param.cidnom attribute(reverse)

       after field cidnom
          display by name param.cidnom

       on key (interrupt)
          exit input

    end input

    if int_flag  then
       let int_flag = false
       exit while
    end if

    if param.cidnom is not null  and
       param.cidnom <> " "       then
       let param.cidnom = "*", param.cidnom clipped, "*"
    else
       let param.cidnom = "*"
    end if

    call ctn04c01(param.ufdcod, param.cidnom) returning ws.sinprscod

    if ws.sinprscod is null  then
       if int_flag = true  then
          error "Nenhum regulador selecionado!"
          let int_flag = false
       else
          error "Nao foi encontrado nenhum regulador!"
       end if
    else
       select sinprscod   ,
              sintraprstip,
              sinprsnom   ,
              endlgd      ,
              endbrr      ,
              endcid      ,
              endufd      ,
              dddcod      ,
              telnum      ,
              cllddd      ,
              clltelnum   ,
              prssrvultdat,
              obs
         into d_ctn04c00.sinprscod   ,
              ws.sintraprstip        ,
              d_ctn04c00.sinprsnom   ,
              d_ctn04c00.endlgd      ,
              d_ctn04c00.endbrr      ,
              d_ctn04c00.endcid      ,
              d_ctn04c00.endufd      ,
              d_ctn04c00.dddcod      ,
              d_ctn04c00.telnum      ,
              d_ctn04c00.cllddd      ,
              d_ctn04c00.clltelnum   ,
              d_ctn04c00.prssrvultdat,
              ws.obs
         from sstkprest
        where sinprscod = ws.sinprscod

       if sqlca.sqlcode <> 0  then
          error "Erro (", sqlca.sqlcode, ") na localizacao do regulador. AVISE A INFORMATICA!"
          return
       end if

       case ws.sintraprstip
          when "A"
             let d_ctn04c00.sinprstip = "AUDITOR"
          when "V"
             let d_ctn04c00.sinprstip = "VISTORIADOR EXTERNO"
          when "I"
             let d_ctn04c00.sinprstip = "INVESTIGADOR"
          when "S"
             let d_ctn04c00.sinprstip = "SOCORRISTA"
          when "X"
             let d_ctn04c00.sinprstip = "VIST./INVESTIGADOR"
          otherwise
             let d_ctn04c00.sinprstip = "*** NAO PREVISTO ***"
       end case

       let d_ctn04c00.obs1 = ws.obs[001,050]
       let d_ctn04c00.obs2 = ws.obs[051,100]
       let d_ctn04c00.obs3 = ws.obs[101,150]

       display by name d_ctn04c00.*

       prompt "" for char prompt_key
       let int_flag = false
    end if

    initialize param.*  to null

 end while

 close window w_ctn04c00

end function  #  ctn04c00
