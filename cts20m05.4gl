 #############################################################################
 # Nome do Modulo: CTS20M05                                         Marcelo  #
 #                                                                  Gilberto #
 # Exibe dados referentes a conclusao do servico                    Abr/1997 #
 #############################################################################
 # Alteracoes:                                                               #
 #                                                                           #
 # DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
 #---------------------------------------------------------------------------#
 # 05/05/1999  PSI 7547-7   Gilberto     Substituicao da situacao pela ulti- #
 #                                       ma etapa do servico.                #
 #############################################################################

 database porto

#-----------------------------------------------------------
 function cts20m05(param)
#-----------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_cts20m05    record
    cnldat            like datmservico.cnldat,
    atdfnlhor         char (05),
    funnom            like isskfunc.funnom,
    atdetpcod         like datmsrvacp.atdetpcod,
    atdetpdes         like datketapa.atdetpdes,
    atdprscod         like dpaksocor.pstcoddig,
    nomgrr            like dpaksocor.nomgrr,
    cidufdprs         char (45),
    dddcod            like dpaksocor.dddcod,
    teltxt            like dpaksocor.teltxt,
    c24nomctt         like datmservico.c24nomctt,
    atdvclsgl         like datmservico.atdvclsgl,
    socvclcod         like datmservico.socvclcod,
    vcldes            char (56),
    srrcoddig         like datksrr.srrcoddig,
    srrabvnom         like datksrr.srrabvnom
 end record

 define ws            record
    endcidprs         like dpaksocor.endcid,
    endufdprs         like dpaksocor.endufd,
    c24opemat         like datmservico.c24opemat,
    atdfnlhor         like datmservico.atdfnlhor,
    atdfnlflg         like datmservico.atdfnlflg,
    atdmotnom         like datmservico.atdmotnom,
    vclcoddig         like agbkveic.vclcoddig
 end record

 define prompt_key    char (01)


 initialize d_cts20m05.*  to null
 initialize ws.*          to null

 let int_flag = false

 if param.atdsrvnum  is null   or
    param.atdsrvano  is null   then
    error " Servico nao informado. AVISE A INFORMATICA!"
    return
 end if

 #----------------------------------------------------------------
 # Busca dados e verifica se o servico foi acionado
 #----------------------------------------------------------------
 select atdprscod,
        atdmotnom,
        atdvclsgl,
        atdfnlflg,
        c24opemat,
        cnldat,
        atdfnlhor,
        socvclcod,
        srrcoddig,
        c24nomctt
   into d_cts20m05.atdprscod,
        ws.atdmotnom,
        d_cts20m05.atdvclsgl,
        ws.atdfnlflg,
        ws.c24opemat,
        d_cts20m05.cnldat,
        d_cts20m05.atdfnlhor,
        d_cts20m05.socvclcod,
        d_cts20m05.srrcoddig,
        d_cts20m05.c24nomctt
   from datmservico
  where atdsrvnum  =  param.atdsrvnum
    and atdsrvano  =  param.atdsrvano

 if sqlca.sqlcode = notfound  then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 if ws.atdfnlflg = "N"  then
    error " Servico nao teve acionamento de prestador!"
    return
 end if

 open window cts20m05 at 11,03 with form "cts20m05"
      attribute (form line 1, border)

 if ws.c24opemat is not null   then
    select funnom
      into d_cts20m05.funnom
      from isskfunc
     where empcod = 01
       and funmat = ws.c24opemat
 end if

 let d_cts20m05.funnom = upshift(d_cts20m05.funnom)

 if d_cts20m05.atdprscod  is not null   then
    select dpaksocor.nomgrr,
           dpaksocor.dddcod,
           dpaksocor.teltxt,
           dpaksocor.endcid,
           dpaksocor.endufd
      into d_cts20m05.nomgrr,
           d_cts20m05.dddcod,
           d_cts20m05.teltxt,
           ws.endcidprs,
           ws.endufdprs
      from dpaksocor
     where dpaksocor.pstcoddig = d_cts20m05.atdprscod

    let d_cts20m05.cidufdprs = ws.endcidprs clipped, " - ", ws.endufdprs

    #------------------------------------------------------------
    # Busca dados do veiculo do prestador
    #------------------------------------------------------------
    if d_cts20m05.socvclcod  is not null   then
       select vclcoddig,
              atdvclsgl
         into ws.vclcoddig,
              d_cts20m05.atdvclsgl
         from datkveiculo
        where socvclcod  =  d_cts20m05.socvclcod

       if sqlca.sqlcode  <>  0    then
          error " Veiculo nao encontrado. AVISE INFORMATICA!"
          return
       end if

       call cts15g00 (ws.vclcoddig)  returning d_cts20m05.vcldes
    end if
 end if

 if ws.atdmotnom  is not null   and
    ws.atdmotnom  <>  "  "      then
    let d_cts20m05.srrabvnom  =  ws.atdmotnom
 else
    if d_cts20m05.srrcoddig  is not null   then
       select srrabvnom
         into d_cts20m05.srrabvnom
         from datksrr
        where srrcoddig = d_cts20m05.srrcoddig
    end if
 end if

 select atdetpcod
   into d_cts20m05.atdetpcod
   from datmsrvacp
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and atdsrvseq = (select max(atdsrvseq)
                       from datmsrvacp
                      where atdsrvnum = param.atdsrvnum  and
                            atdsrvano = param.atdsrvano)

 if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na localizacao da etapa de acionamento. AVISE A INFORMATICA!"
    return
 else
    select atdetpdes
      into d_cts20m05.atdetpdes
      from datketapa
     where atdetpcod = d_cts20m05.atdetpcod
 end if

 display by name d_cts20m05.*

 prompt " (F17)Abandona" for char prompt_key

 close window cts20m05

end function  ###  cts20m05
