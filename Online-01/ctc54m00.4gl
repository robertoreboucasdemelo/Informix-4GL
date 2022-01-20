#############################################################################
# Nome do Modulo: ctc54m00                                            Raji  #
#                                                                           #
# Cadastro Destino R.P.T.                                          Mai/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 13/08/2009  PSI 244236   Burini       Inclusão do Sub-Dairro              #
#############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function ctc54m00()
#-----------------------------------------------------------

 define d_ctc54m00 record
    prdptvcod      like datkptv.prdptvcod
 end record

 define a_ctc54m00 array[100] of record
    prdptvcod      like datkptv.prdptvcod,
    cidnom         like glakcid.cidnom,
    brrnom         like datmlcl.brrnom,
    ufdcod         like glakest.ufdcod,
    c24ptvstt      like datkptv.c24ptvstt,
    sttdes         char(10),
    pcpptvflg      char(1)
 end record

 define e_ctc54m00 record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig       ,
    celteldddcod      like datmlcl.celteldddcod    ,    
    celtelnum         like datmlcl.celtelnum       ,
    endcmp            like datmlcl.endcmp 
 end record

 define hist_ctc54m00 record
    hist1             like datmservhist.c24srvdsc,
    hist2             like datmservhist.c24srvdsc,
    hist3             like datmservhist.c24srvdsc,
    hist4             like datmservhist.c24srvdsc,
    hist5             like datmservhist.c24srvdsc
 end record

 define ws            record
    retflg            char(1),
    cadflg            char(1)
 end record

 define arr_aux       smallint                  ,
        aux_today     char (10)                 ,
        aux_hora      char (05),
        l_emeviacod   like datkemevia.emeviacod


        define  w_pf1   integer

        let     arr_aux  =  null
        let     aux_today  =  null
        let     aux_hora  =  null
        let l_emeviacod   = null

        for     w_pf1  =  1  to  100
                initialize  a_ctc54m00[w_pf1].*  to  null
        end     for

        initialize  d_ctc54m00.*  to  null

        initialize  e_ctc54m00.*  to  null

        initialize  hist_ctc54m00.*  to  null

        initialize  ws.*  to  null

 initialize d_ctc54m00.*  to null
 initialize e_ctc54m00.*  to null
 initialize ws.*          to null
 initialize a_ctc54m00    to null

 open window ctc54m00 at 08,03 with form "ctc54m00"
      attribute(border, form line 1, message line last, comment line last - 1)

 let int_flag     = true
 while int_flag

    let arr_aux      = 1
    let int_flag     = false
    let aux_today    = today
    let aux_hora     = current hour to minute

    message " Aguarde, pesquisando..." attribute (reverse)

    declare c_datkptv cursor for
       select prdptvcod,
              cidnom,
              lclbrrnom,
              ufdcod,
              c24ptvstt,
              pcpptvflg
         from datkptv
        order by ufdcod, cidnom

    foreach c_datkptv into a_ctc54m00[arr_aux].prdptvcod,
                           a_ctc54m00[arr_aux].cidnom,
                           a_ctc54m00[arr_aux].brrnom,
                           a_ctc54m00[arr_aux].ufdcod,
                           a_ctc54m00[arr_aux].c24ptvstt,
                           a_ctc54m00[arr_aux].pcpptvflg

       if a_ctc54m00[arr_aux].c24ptvstt = 1 Then
          let a_ctc54m00[arr_aux].sttdes = "Ativo"
       else
          let a_ctc54m00[arr_aux].sttdes = "Cancelado"
       end if

       let arr_aux = arr_aux + 1

       if arr_aux > 100  then
          error " Limite excedido! Foram encontradas mais de 100 cidades para a pesquisa!"
          exit foreach
       end if
    end foreach

    message " (F6)Inclui,(F7)Seleciona,(F8)Cancela/Ativa,(F9)Padrao,(F17)Abandona "

    #if arr_aux > 1  then
       call set_count(arr_aux-1)

       display array a_ctc54m00 to s_ctc54m00.*
          on key (interrupt,control-c)
             initialize d_ctc54m00.* to null

             let int_flag = false
             let ws.cadflg = "N"
             exit display

          on key (F6)
             let arr_aux = arr_curr()
             let d_ctc54m00.prdptvcod = 0

             let int_flag = true
             let ws.cadflg = "S"
             exit display

          on key (F7)
             let arr_aux = arr_curr()
             let d_ctc54m00.prdptvcod = a_ctc54m00[arr_aux].prdptvcod

             let int_flag = true
             let ws.cadflg = "S"
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let d_ctc54m00.prdptvcod = a_ctc54m00[arr_aux].prdptvcod

             if a_ctc54m00[arr_aux].c24ptvstt = 1 then
                update datkptv set c24ptvstt = 2
                       where prdptvcod = d_ctc54m00.prdptvcod
             else
                update datkptv set c24ptvstt = 1
                       where prdptvcod = d_ctc54m00.prdptvcod
             end if

             let int_flag = true
             let ws.cadflg = "N"
             exit display

          on key (F9)
             let arr_aux = arr_curr()
             let d_ctc54m00.prdptvcod = a_ctc54m00[arr_aux].prdptvcod

             if a_ctc54m00[arr_aux].pcpptvflg = "S" then
                update datkptv set pcpptvflg = "N"
                       where prdptvcod = d_ctc54m00.prdptvcod
             else
                update datkptv set pcpptvflg = "S"
                       where prdptvcod = d_ctc54m00.prdptvcod
             end if

             let int_flag = true
             let ws.cadflg = "N"
             exit display
       end display

    if int_flag = true and ws.cadflg = "S" then
       #--------------------------------------------------------------
       # Informacoes do Endereco do Patio
       #--------------------------------------------------------------
        initialize e_ctc54m00.* to null

        select lclidttxt,
               lgdtip,
               lgdnom,
               lgdnum,
               lclbrrnom,
               cidnom,
               ufdcod,
               lclrefptotxt,
               endzon,
               lgdcep,
               lgdcepcmp,
               dddcod,
               lcltelnum,
               lclcttnom
          into e_ctc54m00.lclidttxt,
               e_ctc54m00.lgdtip,
               e_ctc54m00.lgdnom,
               e_ctc54m00.lgdnum,
               e_ctc54m00.lclbrrnom,
               e_ctc54m00.cidnom,
               e_ctc54m00.ufdcod,
               e_ctc54m00.lclrefptotxt,
               e_ctc54m00.endzon,
               e_ctc54m00.lgdcep,
               e_ctc54m00.lgdcepcmp,
               e_ctc54m00.dddcod,
               e_ctc54m00.lcltelnum,
               e_ctc54m00.lclcttnom
          from datkptv
         where prdptvcod = d_ctc54m00.prdptvcod
       
       initialize g_documento.* to null
       call cts06g03(1,
                     4,
                     0,
                     aux_today,
                     aux_hora,
                     e_ctc54m00.lclidttxt,
                     e_ctc54m00.cidnom,
                     e_ctc54m00.ufdcod,
                     e_ctc54m00.brrnom,
                     e_ctc54m00.lclbrrnom,
                     e_ctc54m00.endzon,
                     e_ctc54m00.lgdtip,
                     e_ctc54m00.lgdnom,
                     e_ctc54m00.lgdnum,
                     e_ctc54m00.lgdcep,
                     e_ctc54m00.lgdcepcmp,
                     e_ctc54m00.lclltt,
                     e_ctc54m00.lcllgt,
                     e_ctc54m00.lclrefptotxt,
                     e_ctc54m00.lclcttnom,
                     e_ctc54m00.dddcod,
                     e_ctc54m00.lcltelnum,
                     e_ctc54m00.c24lclpdrcod,
                     e_ctc54m00.ofnnumdig,
                     e_ctc54m00.celteldddcod,    
                     e_ctc54m00.celtelnum, 
                     e_ctc54m00.endcmp,
                     hist_ctc54m00.*,
                     "")
           returning e_ctc54m00.lclidttxt,
                     e_ctc54m00.cidnom,
                     e_ctc54m00.ufdcod,
                     e_ctc54m00.brrnom,
                     e_ctc54m00.lclbrrnom,
                     e_ctc54m00.endzon,
                     e_ctc54m00.lgdtip,
                     e_ctc54m00.lgdnom,
                     e_ctc54m00.lgdnum,
                     e_ctc54m00.lgdcep,
                     e_ctc54m00.lgdcepcmp,
                     e_ctc54m00.lclltt,
                     e_ctc54m00.lcllgt,
                     e_ctc54m00.lclrefptotxt,
                     e_ctc54m00.lclcttnom,
                     e_ctc54m00.dddcod,
                     e_ctc54m00.lcltelnum,
                     e_ctc54m00.c24lclpdrcod,
                     e_ctc54m00.ofnnumdig,
                     e_ctc54m00.celteldddcod,  
                     e_ctc54m00.celtelnum,
                     e_ctc54m00.endcmp,
                     ws.retflg,
                     hist_ctc54m00.*,
                     l_emeviacod

        let int_flag = true
        if ws.retflg = "S" then
           # Grava Local do patio
           if d_ctc54m00.prdptvcod = 0 then
              insert into datkptv (prdptvcod,
                                   lclidttxt,
                                   cidnom,
                                   ufdcod,
                                   lclbrrnom,
                                   endzon,
                                   lgdtip,
                                   lgdnom,
                                   lgdnum,
                                   lgdcep,
                                   lgdcepcmp,
                                   lclrefptotxt,
                                   lclcttnom,
                                   dddcod,
                                   lcltelnum,
                                   lclltt,
                                   lcllgt,
                                   c24lclpdrcod,
                                   c24ptvstt,
                                   pcpptvflg)
                         values   (0,
                                   e_ctc54m00.lclidttxt,
                                   e_ctc54m00.cidnom,
                                   e_ctc54m00.ufdcod,
                                   e_ctc54m00.lclbrrnom,
                                   e_ctc54m00.endzon,
                                   e_ctc54m00.lgdtip,
                                   e_ctc54m00.lgdnom,
                                   e_ctc54m00.lgdnum,
                                   e_ctc54m00.lgdcep,
                                   e_ctc54m00.lgdcepcmp,
                                   e_ctc54m00.lclrefptotxt,
                                   e_ctc54m00.lclcttnom,
                                   e_ctc54m00.dddcod,
                                   e_ctc54m00.lcltelnum,
                                   e_ctc54m00.lclltt,
                                   e_ctc54m00.lcllgt,
                                   e_ctc54m00.c24lclpdrcod,
                                   1,
                                   "S")
           else
              update datkptv set (lclidttxt,
                                  cidnom,
                                  ufdcod,
                                  lclbrrnom,
                                  endzon,
                                  lgdtip,
                                  lgdnom,
                                  lgdnum,
                                  lgdcep,
                                  lgdcepcmp,
                                  lclrefptotxt,
                                  lclcttnom,
                                  dddcod,
                                  lcltelnum,
                                  lclltt,
                                  lcllgt,
                                  c24lclpdrcod)
                                = (e_ctc54m00.lclidttxt,
                                   e_ctc54m00.cidnom,
                                   e_ctc54m00.ufdcod,
                                   e_ctc54m00.lclbrrnom,
                                   e_ctc54m00.endzon,
                                   e_ctc54m00.lgdtip,
                                   e_ctc54m00.lgdnom,
                                   e_ctc54m00.lgdnum,
                                   e_ctc54m00.lgdcep,
                                   e_ctc54m00.lgdcepcmp,
                                   e_ctc54m00.lclrefptotxt,
                                   e_ctc54m00.lclcttnom,
                                   e_ctc54m00.dddcod,
                                   e_ctc54m00.lcltelnum,
                                   e_ctc54m00.lclltt,
                                   e_ctc54m00.lcllgt,
                                   e_ctc54m00.c24lclpdrcod)
               where prdptvcod = d_ctc54m00.prdptvcod
           end if
        end if

     end if

 end while

 error ""
 close window ctc54m00

 let int_flag = false

 return
end function  ###  ctc54m00



#-----------------------------------------------------------
 function ctc54m00_patio(param)
#-----------------------------------------------------------

 define param      record
    cidnom         like glakcid.cidnom,
    ufdcod         like glakest.ufdcod
 end record

 define d_ctc54m00 record
    prdptvcod      like datkptv.prdptvcod
 end record

 define a_ctc54m00 array[100] of record
    prdptvcod      like datkptv.prdptvcod,
    cidnom         like glakcid.cidnom,
    brrnom         like datmlcl.brrnom,
    ufdcod         like glakest.ufdcod,
    c24ptvstt      like datkptv.c24ptvstt,
    sttdes         char(10),
    pcpptvflg      char(1)
 end record

 define e_ctc54m00 record
    operacao          char (01)                    ,
    lclidttxt         like datmlcl.lclidttxt       ,
    lgdtxt            char (65)                    ,
    lgdtip            like datmlcl.lgdtip          ,
    lgdnom            like datmlcl.lgdnom          ,
    lgdnum            like datmlcl.lgdnum          ,
    brrnom            like datmlcl.brrnom          ,
    lclbrrnom         like datmlcl.lclbrrnom       ,
    endzon            like datmlcl.endzon          ,
    cidnom            like datmlcl.cidnom          ,
    ufdcod            like datmlcl.ufdcod          ,
    lgdcep            like datmlcl.lgdcep          ,
    lgdcepcmp         like datmlcl.lgdcepcmp       ,
    lclltt            like datmlcl.lclltt          ,
    lcllgt            like datmlcl.lcllgt          ,
    dddcod            like datmlcl.dddcod          ,
    lcltelnum         like datmlcl.lcltelnum       ,
    lclcttnom         like datmlcl.lclcttnom       ,
    lclrefptotxt      like datmlcl.lclrefptotxt    ,
    c24lclpdrcod      like datmlcl.c24lclpdrcod    ,
    ofnnumdig         like sgokofi.ofnnumdig
 end record

 define ws            record
    retflg            char(1),
    comando           char(300)
 end record

 define arr_aux       smallint                  ,
        aux_flg       smallint                  ,
        aux_count     smallint



        define  w_pf1   integer

        let     arr_aux  =  null
        let     aux_flg  =  null
        let     aux_count  =  null

        for     w_pf1  =  1  to  100
                initialize  a_ctc54m00[w_pf1].*  to  null
        end     for

        initialize  d_ctc54m00.*  to  null

        initialize  e_ctc54m00.*  to  null

        initialize  ws.*  to  null

 initialize d_ctc54m00.*  to null
 initialize e_ctc54m00.*  to null
 initialize ws.*          to null
 initialize a_ctc54m00    to null

 open window ctc54m00 at 08,03 with form "ctc54m00"
      attribute(border, form line 1, message line last, comment line last - 1)

 let int_flag     = true
 while int_flag

    let arr_aux      = 1
    let int_flag     = false

    message " Aguarde, pesquisando..." attribute (reverse)

    let ws.comando = "select prdptvcod,  ",
                     "       cidnom,     ",
                     "       lclbrrnom,  ",
                     "       ufdcod,     ",
                     "       c24ptvstt,  ",
                     "       pcpptvflg   ",
                     "  from datkptv     "

    if param.ufdcod is null then
       let ws.comando = ws.comando clipped,
                      " where c24ptvstt = 1 "
       let aux_flg = 3
    else
       select count(*)
              into aux_count
         from datkptv
        where cidnom = param.cidnom
          and ufdcod = param.ufdcod

       if aux_count = 0 then
          let ws.comando = ws.comando clipped,
                           " where ufdcod    = ?   ",
                           "   and c24ptvstt = 1   "
          let aux_flg = 0
       else
          let ws.comando = ws.comando clipped,
                           " where pcpptvflg = 'S' ",
                           "   and cidnom = ?      ",
                           "   and ufdcod = ?      ",
                           "   and c24ptvstt = 1   "
          let aux_flg = 1
       end if
    end if
    let ws.comando = ws.comando clipped,
                   " order by ufdcod, cidnom"

    prepare sel_datkptv from ws.comando
    declare c_datkptv_01 cursor for sel_datkptv

    if aux_flg = 1 then
       open    c_datkptv_01 using param.cidnom,
                                  param.ufdcod
    else
       if aux_flg = 0 then
          open    c_datkptv_01 using param.ufdcod
       end if
    end if

    foreach c_datkptv_01 into a_ctc54m00[arr_aux].prdptvcod,
                              a_ctc54m00[arr_aux].cidnom,
                              a_ctc54m00[arr_aux].brrnom,
                              a_ctc54m00[arr_aux].ufdcod,
                              a_ctc54m00[arr_aux].c24ptvstt,
                              a_ctc54m00[arr_aux].pcpptvflg

       if a_ctc54m00[arr_aux].c24ptvstt = 1 Then
          let a_ctc54m00[arr_aux].sttdes = "Ativo"
       else
          let a_ctc54m00[arr_aux].sttdes = "Cancelado"
       end if

       let arr_aux = arr_aux + 1

       if arr_aux > 100  then
          error " Limite excedido! Foram encontradas mais de 100 cidades para a pesquisa!"
          exit foreach
       end if
    end foreach

    message " (F8)Seleciona, (F17)Abandona "

    if arr_aux > 2  then
       call set_count(arr_aux-1)

       display array a_ctc54m00 to s_ctc54m00.*

          on key (interrupt,control-c)
             initialize d_ctc54m00.* to null

             let int_flag = false
             exit display

          on key (F8)
             let arr_aux = arr_curr()
             let d_ctc54m00.prdptvcod = a_ctc54m00[arr_aux].prdptvcod

             let int_flag = true
             exit display

       end display
    else
       if arr_aux = 2  then
          let d_ctc54m00.prdptvcod = a_ctc54m00[1].prdptvcod
          let int_flag = true
       end if
    end if

    if int_flag = true then
       #--------------------------------------------------------------
       # Informacoes do Endereco do Patio
       #--------------------------------------------------------------
        initialize e_ctc54m00.* to null

        select lclidttxt,
               lgdtip,
               lgdnom,
               lgdnum,
               lclbrrnom,
               cidnom,
               ufdcod,
               lclrefptotxt,
               endzon,
               lgdcep,
               lgdcepcmp,
               dddcod,
               lcltelnum,
               lclcttnom,
               lclltt,
               lcllgt,
               c24lclpdrcod
          into e_ctc54m00.lclidttxt,
               e_ctc54m00.lgdtip,
               e_ctc54m00.lgdnom,
               e_ctc54m00.lgdnum,
               e_ctc54m00.brrnom,
               e_ctc54m00.cidnom,
               e_ctc54m00.ufdcod,
               e_ctc54m00.lclrefptotxt,
               e_ctc54m00.endzon,
               e_ctc54m00.lgdcep,
               e_ctc54m00.lgdcepcmp,
               e_ctc54m00.dddcod,
               e_ctc54m00.lcltelnum,
               e_ctc54m00.lclcttnom,
               e_ctc54m00.lclltt,
               e_ctc54m00.lcllgt,
               e_ctc54m00.c24lclpdrcod
          from datkptv
         where prdptvcod = d_ctc54m00.prdptvcod

        let int_flag = false

     end if

 end while

 error ""
 close window ctc54m00

 return e_ctc54m00.lclidttxt,
        e_ctc54m00.lgdtip,
        e_ctc54m00.lgdnom,
        e_ctc54m00.lgdnum,
        e_ctc54m00.lclbrrnom,
        e_ctc54m00.cidnom,
        e_ctc54m00.ufdcod,
        e_ctc54m00.lclrefptotxt,
        e_ctc54m00.endzon,
        e_ctc54m00.lgdcep,
        e_ctc54m00.lgdcepcmp,
        e_ctc54m00.dddcod,
        e_ctc54m00.lcltelnum,
        e_ctc54m00.lclcttnom,
        e_ctc54m00.lclltt,
        e_ctc54m00.lcllgt,
        e_ctc54m00.c24lclpdrcod

end function  ###  ctc54m00
