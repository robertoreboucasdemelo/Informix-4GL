 #############################################################################
 # Nome do Modulo: ctn38c00                                         Gilberto #
 #                                                                   Marcelo #
 # Pesquisa cadastro de veiculos do Porto Socorro                   Set/1998 #
 #############################################################################
 # 31/05/2005 - CH5055635 - O array foi aumentado de 500 para 1200           #
################################################################################
# Alteracoes:                                                                  #
#                                                                              #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                              #
#------------------------------------------------------------------------------#
# 12/12/2006  PSI 205206   Priscila     Incluir empresa no filtro do veículo   #
################################################################################

 database porto

#------------------------------------------------------------
 function ctn38c00()
#------------------------------------------------------------

 define d_ctn38c00    record
    atdvclsglpsq      like datkveiculo.atdvclsgl,
    vcllicnumpsq      like datkveiculo.vcllicnum,
    soceqpcodpsq      like datkvcleqp.soceqpcod,
    soceqpabvpsq      like datkvcleqp.soceqpabv,
    pstcoddigpsq      like datkveiculo.pstcoddig,
    nomgrrpsq         like dpaksocor.nomgrr,
    socoprsitcodpsq   like datkveiculo.socoprsitcod,
    socoprsitdespsq   char (09),
    ciaempcod         like datrvclemp.ciaempcod,       #PSI 205206
    empsgl            like gabkemp.empsgl              #PSI 205206
 end record

 define a_ctn38c00    array[1200]  of  record
    socvclcod         like datkveiculo.socvclcod,
    vcldes            char (58),
    socoprsitdes      char (09),
    atdvclsgl         like datkveiculo.atdvclsgl,
    nomgrr            like dpaksocor.nomgrr,
    vcllicnum         like datkveiculo.vcllicnum,
    vclanofbc         like datkveiculo.vclanofbc,
    vclanomdl         like datkveiculo.vclanomdl
 end record

 define ws            record
    total             char(10),
    comando1          char(700),
    comando2          char(250),
    seleciona         char(01),
    vclcoddig         like datkveiculo.vclcoddig,
    socoprsitcod      like datkveiculo.socoprsitcod,
    pstcoddig         like datkveiculo.pstcoddig,
    vclmrcnom         like agbkmarca.vclmrcnom,
    vcltipnom         like agbktip.vcltipnom,
    vclmdlnom         like agbkveic.vclmdlnom,

    pestip            like dpaksocor.pestip,
    cgccpfnum         like dpaksocor.cgccpfnum,
    cgcord            like dpaksocor.cgcord,
    cgccpfdig         like dpaksocor.cgccpfdig
 end record

 define arr_aux       smallint,
        l_ret         smallint,
        l_mensagem    char(50)


 open window w_ctn38c00 at  06,02 with form "ctn38c00"
             attribute(form line first)

 while true

    initialize ws.*          to null
    initialize d_ctn38c00    to null
    display by name d_ctn38c00.*
    initialize a_ctn38c00    to null
    let int_flag = false
    let arr_aux  = 1

    input by name d_ctn38c00.atdvclsglpsq,
                  d_ctn38c00.vcllicnumpsq,
                  d_ctn38c00.soceqpcodpsq,
                  d_ctn38c00.pstcoddigpsq,
                  d_ctn38c00.socoprsitcodpsq,
                  d_ctn38c00.ciaempcod              #PSI 205206

       before field atdvclsglpsq
             display by name d_ctn38c00.atdvclsglpsq  attribute(reverse)

       after field atdvclsglpsq
             display by name d_ctn38c00.atdvclsglpsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field atdvclsglpsq
             end if

             if d_ctn38c00.atdvclsglpsq   is not null   then
                exit input
             end if

       before field vcllicnumpsq
             display by name d_ctn38c00.vcllicnumpsq  attribute(reverse)

       after field vcllicnumpsq
             display by name d_ctn38c00.vcllicnumpsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field atdvclsglpsq
             end if

             if d_ctn38c00.vcllicnumpsq   is not null   then
                if not srp1415(d_ctn38c00.vcllicnumpsq)  then
                   error " Placa invalida!"
                   next field vcllicnumpsq
                end if
                exit input
             end if

       before field soceqpcodpsq
             display by name d_ctn38c00.soceqpcodpsq  attribute(reverse)

       after field soceqpcodpsq
             display by name d_ctn38c00.soceqpcodpsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field vcllicnumpsq
             end if

             if d_ctn38c00.soceqpcodpsq   is not null   then
                select soceqpabv
                  into d_ctn38c00.soceqpabvpsq
                  from datkvcleqp
                 where datkvcleqp.soceqpcod = d_ctn38c00.soceqpcodpsq

                if sqlca.sqlcode  <>  0   then
                   error " Equipamento nao cadastrado!"
                   call ctn37c00()  returning  d_ctn38c00.soceqpcodpsq
                   next field soceqpcodpsq
                end if
                display by name d_ctn38c00.soceqpabvpsq
                exit input
             end if

       before field pstcoddigpsq
             display by name d_ctn38c00.pstcoddigpsq  attribute(reverse)

       after field pstcoddigpsq
             display by name d_ctn38c00.pstcoddigpsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field soceqpcodpsq
             end if

             if d_ctn38c00.pstcoddigpsq   is not null   then
                select nomgrr
                  into d_ctn38c00.nomgrrpsq
                  from dpaksocor
                 where dpaksocor.pstcoddig = d_ctn38c00.pstcoddigpsq

                if sqlca.sqlcode  <>  0   then
                   error " Prestador nao cadastrado!"
                   call ctb12m02("")  returning  d_ctn38c00.pstcoddigpsq,
                                                 ws.pestip,
                                                 ws.cgccpfnum,
                                                 ws.cgcord,
                                                 ws.cgccpfdig
                   next field pstcoddigpsq
                end if
                display by name d_ctn38c00.nomgrrpsq
                exit input
             end if

       before field socoprsitcodpsq
             display by name d_ctn38c00.socoprsitcodpsq  attribute(reverse)

       after field socoprsitcodpsq
             display by name d_ctn38c00.socoprsitcodpsq

             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field pstcoddigpsq
             end if

             #if d_ctn38c00.socoprsitcodpsq   is null   then
             #   error " Uma chave para pesquisa deve ser informada!"
             #   next field socoprsitcodpsq
             #else
             if d_ctn38c00.socoprsitcodpsq   is not null   then
                select cpodes
                  into d_ctn38c00.socoprsitdespsq
                  from iddkdominio
                 where iddkdominio.cponom  = "socoprsitcod"
                   and iddkdominio.cpocod  = d_ctn38c00.socoprsitcodpsq

                if sqlca.sqlcode  <>  0   then
                   error " Situacao nao cadastrada!"
                   next field socoprsitcodpsq
                end if
                display by name d_ctn38c00.socoprsitdespsq

                exit input
             end if
             
       #PSI 205206      
       before field ciaempcod
              display by name d_ctn38c00.ciaempcod  attribute(reverse)
       
       after field ciaempcod      
             display by name d_ctn38c00.ciaempcod
              
             if fgl_lastkey() = fgl_keyval("up")   or
                fgl_lastkey() = fgl_keyval("left") then
                next field socoprsitcodpsq
             end if

             if d_ctn38c00.ciaempcod  is not null   then
                call cty14g00_empresa(1, d_ctn38c00.ciaempcod)
                     returning l_ret,
                               l_mensagem,
                               d_ctn38c00.empsgl
                 if l_ret <> 1 then
                    error l_mensagem
                    next field ciaempcod
                 end if              
             end if

             if  d_ctn38c00.ciaempcod is null then
                error " Uma chave para pesquisa deve ser informada!"
                next field ciaempcod
             end if
             display by name d_ctn38c00.empsgl attribute (reverse)

             exit input

       on key (interrupt)
              exit input

    end input

    if int_flag   then
       exit while
    end if

    let ws.comando1 = " select ",
                      " datkveiculo.socvclcod,",
                      " datkveiculo.vclcoddig,",
                      " datkveiculo.atdvclsgl,",
                      " datkveiculo.vcllicnum,",
                      " datkveiculo.vclanofbc,",
                      " datkveiculo.vclanomdl,",
                      " datkveiculo.socoprsitcod,",
                      " datkveiculo.pstcoddig"
                      
    #-------------------------------------------------------------------
    # Monta condicao para pesquisa dos veiculos
    #-------------------------------------------------------------------
    if d_ctn38c00.atdvclsglpsq   is not null   then
       let ws.comando2 = "  from datkveiculo ",
                         " where atdvclsgl = ?     "
    end if

    if d_ctn38c00.vcllicnumpsq   is not null   then
       let ws.comando2 = "  from datkveiculo ",
                         " where vcllicnum = ?     "
    end if

    if d_ctn38c00.soceqpcodpsq   is not null   then
       let ws.comando2 = "  from datreqpvcl, datkveiculo ",
                         " where datreqpvcl.soceqpcod = ? ",
                         "   and datkveiculo.socvclcod = datreqpvcl.socvclcod",
                         " order by pstcoddig "
    end if

    if d_ctn38c00.pstcoddigpsq   is not null   then
       let ws.comando2 = "  from datkveiculo ",
                         " where pstcoddig = ? "
    end if

    if d_ctn38c00.socoprsitcodpsq  is not null   then
       let ws.comando2 = "  from datkveiculo ",
                         " where socoprsitcod = ? ",
                         " order by pstcoddig "
    end if
    
    #PSI 205206
    if d_ctn38c00.ciaempcod is not null then
       let ws.comando2 = "  from datkveiculo, datrvclemp ",
                         " where datrvclemp.ciaempcod = ? ",
                         "   and datkveiculo.socvclcod = datrvclemp.socvclcod "    
    end if

    let ws.comando1 = ws.comando1 clipped, " ", ws.comando2

    message " Aguarde, pesquisando..."  attribute(reverse)
    prepare comando_aux from ws.comando1
    declare c_ctn38c00  cursor for comando_aux

    if d_ctn38c00.atdvclsglpsq  is not null   then
       open c_ctn38c00  using d_ctn38c00.atdvclsglpsq
    end if

    if d_ctn38c00.vcllicnumpsq   is not null      then
       open c_ctn38c00  using d_ctn38c00.vcllicnumpsq
    end if

    if d_ctn38c00.soceqpcodpsq   is not null      then
       open c_ctn38c00  using d_ctn38c00.soceqpcodpsq
    end if

    if d_ctn38c00.pstcoddigpsq   is not null      then
       open c_ctn38c00  using d_ctn38c00.pstcoddigpsq
    end if

    if d_ctn38c00.socoprsitcodpsq   is not null   then
       open c_ctn38c00  using d_ctn38c00.socoprsitcodpsq
    end if

    #PSI 205206
    if d_ctn38c00.ciaempcod is not null then
       open c_ctn38c00 using d_ctn38c00.ciaempcod
    end if

    foreach  c_ctn38c00  into  a_ctn38c00[arr_aux].socvclcod,
                               ws.vclcoddig,
                               a_ctn38c00[arr_aux].atdvclsgl,
                               a_ctn38c00[arr_aux].vcllicnum,
                               a_ctn38c00[arr_aux].vclanofbc,
                               a_ctn38c00[arr_aux].vclanomdl,
                               ws.socoprsitcod,
                               ws.pstcoddig

       #----------------------------------------------------------------
       # Monta descricao do veiculo
       #----------------------------------------------------------------
       initialize ws.vclmrcnom  to null
       initialize ws.vcltipnom  to null
       initialize ws.vclmdlnom  to null
       initialize a_ctn38c00[arr_aux].vcldes  to null

       select vclmrcnom,
              vcltipnom,
              vclmdlnom
         into ws.vclmrcnom,
              ws.vcltipnom,
              ws.vclmdlnom
         from agbkveic, outer agbkmarca, outer agbktip
        where agbkveic.vclcoddig  = ws.vclcoddig
          and agbkmarca.vclmrccod = agbkveic.vclmrccod
          and agbktip.vclmrccod   = agbkveic.vclmrccod
          and agbktip.vcltipcod   = agbkveic.vcltipcod

       let a_ctn38c00[arr_aux].vcldes = ws.vclmrcnom clipped, " ",
                                        ws.vcltipnom clipped, " ",
                                        ws.vclmdlnom

       #----------------------------------------------------------------
       # Monta situacao do veiculo
       #----------------------------------------------------------------
       initialize a_ctn38c00[arr_aux].socoprsitdes  to null
       select cpodes
         into a_ctn38c00[arr_aux].socoprsitdes
         from iddkdominio
        where iddkdominio.cponom  = "socoprsitcod"
          and iddkdominio.cpocod  = ws.socoprsitcod

       #----------------------------------------------------------------
       # Monta nome do prestador
       #----------------------------------------------------------------
       select nomgrr
         into a_ctn38c00[arr_aux].nomgrr
         from dpaksocor
        where dpaksocor.pstcoddig = ws.pstcoddig

       let arr_aux = arr_aux + 1
       if arr_aux > 1200  then
          error " Limite excedido, pesquisa com mais de 1200 veiculos!"
          exit foreach
       end if

    end foreach

    if arr_aux  =  1   then
       error " Nao existem veiculos para pesquisa!"
    end if

    let ws.total = "Total: ", arr_aux - 1 using "&&&"
    display by name ws.total  attribute (reverse)
    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux-1)
    let ws.seleciona = "n"

    display array  a_ctn38c00 to s_ctn38c00.*
       on key (interrupt)
          initialize ws.total   to null
          initialize a_ctn38c00 to null
          display by name ws.total
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let ws.seleciona = "s"
          exit display
    end display

    if ws.seleciona = "s"  then
       exit while
    end if

    for arr_aux = 1 to 03
       clear s_ctn38c00[arr_aux].socvclcod
       clear s_ctn38c00[arr_aux].vcldes
       clear s_ctn38c00[arr_aux].socoprsitdes
       clear s_ctn38c00[arr_aux].atdvclsgl
       clear s_ctn38c00[arr_aux].nomgrr
       clear s_ctn38c00[arr_aux].vcllicnum
       clear s_ctn38c00[arr_aux].vclanofbc
       clear s_ctn38c00[arr_aux].vclanomdl
    end for

    close c_ctn38c00

 end while

 let int_flag = false
 close window  w_ctn38c00

 return a_ctn38c00[arr_aux].socvclcod

end function  #  ctn38c00
