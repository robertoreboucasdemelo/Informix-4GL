#############################################################################
# Nome do Modulo: CTS00M12                                         Marcelo  #
#                                                                  Gilberto #
# Consulta informacoes sobre prestador acionado                    Ago/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 25/09/1998  PSI 6479-3   Gilberto     Exibir informacoes referentes ao    #
#                                       veiculo do prestador acionado.      #
#---------------------------------------------------------------------------#
# 02/09/2002  PSI 14179-8  Ruiz         Exibir inf. ref. a sinistro transp. #
#############################################################################

 database porto

#-----------------------------------------------------------
 function cts00m12(param)
#-----------------------------------------------------------

 define param       record
    atdsrvnum       like datmsrvacp.atdsrvnum,
    atdsrvano       like datmsrvacp.atdsrvano,
    atdsrvseq       like datmsrvacp.atdsrvseq
 end record

 define d_cts00m12  record
    pstcoddig       like datmsrvacp.pstcoddig,
    nomgrr          like dpaksocor.nomgrr,
    c24nomctt       like datmsrvacp.c24nomctt,
    atdvclsgl       like datkveiculo.atdvclsgl,
    socvclcod       like datmsrvacp.socvclcod,
    socvcldes       char (50),
    srrcoddig       like datmservico.srrcoddig,
    srrabvnom       like datksrr.srrabvnom
 end record

 define ws          record
    vclcoddig       like agbkveic.vclcoddig,
    atdmotnom       like datmservico.atdmotnom,
    atdsrvorg       like datmservico.atdsrvorg
 end record

 define l_resultado smallint,
        l_mensagem char(70),
        l_lcvextcod like datkavislocal.lcvextcod

 define prompt_key  char (01)


	let	prompt_key  =  null

	initialize  d_cts00m12.*  to  null

	initialize  ws.*  to  null

 let l_resultado = null
 let l_mensagem = null
 let l_lcvextcod = null

 if param.atdsrvnum  is null  or
    param.atdsrvano  is null  or
    param.atdsrvseq  is null  then
    error " Parametros invalidos! AVISE A INFORMATICA!"
    return
 end if

 initialize d_cts00m12.*   to null
 initialize ws.*           to null

 select pstcoddig,
        c24nomctt,
        socvclcod,
        atdvclsgl,
        atdmotnom,
        srrcoddig
   into d_cts00m12.pstcoddig,
        d_cts00m12.c24nomctt,
        d_cts00m12.socvclcod,
        d_cts00m12.atdvclsgl,
        ws.atdmotnom,
        d_cts00m12.srrcoddig
   from datmsrvacp
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdsrvseq = param.atdsrvseq

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode using "<<<<<<<<&", ") na localizacao",
          " do prestador. AVISE A INFORMATICA!"
    return
 end if
 if d_cts00m12.pstcoddig is null  then
    error " Nao houve acionamento de prestador!"
    return
 end if

 select atdsrvorg
   into ws.atdsrvorg
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 if d_cts00m12.socvclcod is not null  then
    select vclcoddig,
           atdvclsgl
      into ws.vclcoddig,
           d_cts00m12.atdvclsgl
      from datkveiculo
     where socvclcod  =  d_cts00m12.socvclcod

    if sqlca.sqlcode = 0  then
       call cts15g00(ws.vclcoddig)  returning d_cts00m12.socvcldes
    end if
 end if

 if ws.atdmotnom  is not null   and
    ws.atdmotnom  <>  "  "      then
    let d_cts00m12.srrabvnom  =  ws.atdmotnom
 else
    if d_cts00m12.srrcoddig  is not null   then
       if ws.atdsrvorg = 16 then # dados tabela sinistro de transportes
          select sinprsnom
              into d_cts00m12.srrabvnom
              from sstkprest
             where sinprscod = d_cts00m12.srrcoddig
       else
          if ws.atdsrvorg = 8 then
             call ctc18g00_dados_loja
                  (3,d_cts00m12.pstcoddig, d_cts00m12.srrcoddig)
                  returning l_resultado, l_mensagem, d_cts00m12.srrabvnom,
                            l_lcvextcod
          else
             select srrabvnom
               into d_cts00m12.srrabvnom
               from datksrr
              where srrcoddig = d_cts00m12.srrcoddig
          end if
       end if
    end if
 end if

 open window cts00m12 at 14,04 with form "cts00m12"
             attribute (form line first, border)

 let d_cts00m12.nomgrr = "** NAO CADASTRADO **"

 if ws.atdsrvorg = 16 then # dados tabela sinistro de transportes
    select sinprsnom
      into d_cts00m12.nomgrr
      from sstkprest
     where sinprscod = d_cts00m12.srrcoddig
 else

    if ws.atdsrvorg = 8 then
       call ctc30g00_dados_loca (3,d_cts00m12.pstcoddig)
           returning l_resultado, l_mensagem, d_cts00m12.nomgrr
    else
       select nomgrr
         into d_cts00m12.nomgrr
         from dpaksocor
        where pstcoddig = d_cts00m12.pstcoddig
    end if
 end if
 display by name d_cts00m12.pstcoddig, d_cts00m12.nomgrr,
                 d_cts00m12.c24nomctt, d_cts00m12.atdvclsgl,
                 d_cts00m12.socvclcod, d_cts00m12.socvcldes,
                 d_cts00m12.srrabvnom

 if ws.atdsrvorg = 8 then
    display l_lcvextcod to srrcoddig
 else
    display by name d_cts00m12.srrcoddig
 end if

 prompt "(F17) Abandona" for char prompt_key

 let int_flag = false
 close window cts00m12

end function  ###  cts00m12
