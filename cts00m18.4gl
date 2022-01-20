###############################################################################
# Nome do Modulo: CTS00M18                                           Marcelo  #
#                                                                    Gilberto #
# Retorno do prestador para execucao do servico                      Out/1998 #
###############################################################################

 database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"
#---------------------------------------------------------
 function cts00m18(param)
#---------------------------------------------------------

 define param         record
    atdsrvnum         like datmservico.atdsrvnum,
    atdsrvano         like datmservico.atdsrvano
 end record

 define d_cts00m18    record
    atdsrvretflg      like datmsrvre.atdsrvretflg,
    atdsrvretctt      char (30)
 end record

 define ws            record
    atdsrvseq         like datmsrvacp.atdsrvseq,
    pstcoddig         like datmsrvacp.pstcoddig,
    atdmotnom         like datmsrvacp.atdmotnom,
    srrcoddig         like datmsrvacp.srrcoddig,
    socvclcod         like datmsrvacp.socvclcod,
    c24srvdsc         like datmservhist.c24srvdsc
 end record

 define w_retorno     smallint


	let	w_retorno  =  null

	initialize  d_cts00m18.*  to  null

	initialize  ws.*  to  null

 initialize d_cts00m18.*  to null
 initialize ws.*          to null


 open window cts00m18 at 12,14 with form "cts00m18"
                      attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona "

 let int_flag   =  false

 if param.atdsrvnum  is null   or
    param.atdsrvano  is null   then
    error " Servico nao encontrado. AVISE A INFORMATICA!"
    return
 end if

 let d_cts00m18.atdsrvretflg = "N"

 input by name d_cts00m18.atdsrvretflg,
               d_cts00m18.atdsrvretctt without defaults

   before field atdsrvretflg
      display by name d_cts00m18.atdsrvretflg attribute (reverse)

   after field atdsrvretflg
      display by name d_cts00m18.atdsrvretflg

      if d_cts00m18.atdsrvretflg is null  then
         error " Retorno foi informado ? (S)im ou (N)ao"
         next field atdsrvretflg
      end if

      if d_cts00m18.atdsrvretflg  <>  "S"  and
         d_cts00m18.atdsrvretflg  <>  "N"  then
         error " Retorno informado deve ser (S)im ou (N)ao!"
         next field atdsrvretflg
      end if

      if d_cts00m18.atdsrvretflg = "N"  then
         exit input
      end if

   before field atdsrvretctt
      display by name d_cts00m18.atdsrvretctt  attribute (reverse)

   after field atdsrvretctt
      if fgl_lastkey() = fgl_keyval("up")   or
         fgl_lastkey() = fgl_keyval("left") then
         display by name d_cts00m18.atdsrvretctt
         next field atdsrvretflg
      end if

      if d_cts00m18.atdsrvretctt is null  or
         d_cts00m18.atdsrvretctt  = "  "  then
         error " Nome a quem foi dado o retorno deve ser informado!"
         next field atdsrvretctt
      end if

   on key (interrupt)
      exit input

 end input

 if not int_flag  then
    if d_cts00m18.atdsrvretflg = "N"  then
       let ws.c24srvdsc = "RETORNO NAO INFORMADO."
    else
       #begin work
        call cts10g04_insere_etapa(param.atdsrvnum,
                                   param.atdsrvano,
                                   10,
                                   ws.pstcoddig,
                                   d_cts00m18.atdsrvretctt,
                                   ws.socvclcod,
                                   ws.srrcoddig,
                                   " ",
                                   " ")returning w_retorno

       if w_retorno <> 0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao da etapa de acompanhamento. AVISE A INFORMATICA!"
          #rollback work
          close window cts00m18
          return
       end if

       update datmsrvre set atdsrvretflg = "N"
        where atdsrvnum = param.atdsrvnum  and
              atdsrvano = param.atdsrvano

       if sqlca.sqlcode <> 0  then
          error " Erro (", sqlca.sqlcode, ") na gravacao do retorno. AVISE A INFORMATICA!"
          #rollback work
          close window cts00m18
          return
       end if

       #commit work

       let ws.c24srvdsc = "RETORNO INFORMADO PARA ", d_cts00m18.atdsrvretctt
    end if

    call cts00m18_historico(param.atdsrvnum, param.atdsrvano, ws.c24srvdsc)
 end if

 let int_flag = false
 close window cts00m18

end function  ###  cts00m18


#--------------------------------------------------------------------
 function cts00m18_historico(param)
#--------------------------------------------------------------------

 define param  record
    atdsrvnum  like datmservico.atdsrvnum ,
    atdsrvano  like datmservico.atdsrvano ,
    c24srvdsc  like datmservhist.c24srvdsc
 end record

 define ws     record
    c24txtseq  like datmservhist.c24txtseq
 end record

 define l_ret       smallint,
        l_mensagem  char(60),
        l_lighorinc    like datmservhist.lighorinc

 initialize  ws.*  to  null
 let l_lighorinc = null
 initialize ws.c24txtseq to null

 #BURINI#    select max (c24txtseq)
 #BURINI#      into ws.c24txtseq
 #BURINI#      from datmservhist
 #BURINI#     where atdsrvnum = param.atdsrvnum and
 #BURINI#           atdsrvano = param.atdsrvano
 #BURINI#
 #BURINI#    if ws.c24txtseq is null then
 #BURINI#       let ws.c24txtseq = 0
 #BURINI#    end if
 #BURINI#
 #BURINI# let ws.c24txtseq = ws.c24txtseq + 1
 #BURINI#
 #BURINI# insert into datmservhist ( atdsrvnum ,
 #BURINI#                            atdsrvano ,
 #BURINI#                            c24txtseq ,
 #BURINI#                            c24funmat ,
 #BURINI#                            ligdat    ,
 #BURINI#                            lighorinc ,
 #BURINI#                            c24srvdsc )
 #BURINI#             values       ( param.atdsrvnum ,
 #BURINI#                            param.atdsrvano ,
 #BURINI#                            ws.c24txtseq    ,
 #BURINI#                            g_issk.funmat   ,
 #BURINI#                            today           ,
 #BURINI#                            current         ,
 #BURINI#                            param.c24srvdsc )

	let l_lighorinc = current
  call ctd07g01_ins_datmservhist(param.atdsrvnum,
                                 param.atdsrvano,
                                 g_issk.funmat,
                                 param.c24srvdsc,
                                 today,
                                 l_lighorinc,
                                 g_issk.empcod,
                                 g_issk.usrtip)
       returning l_ret,
                 l_mensagem
  if l_ret <> 1 then
     error l_mensagem, " - CTS00M18 - AVISE A INFORMATICA! "
     return
  end if

end function  ###  cts00m18_historico
