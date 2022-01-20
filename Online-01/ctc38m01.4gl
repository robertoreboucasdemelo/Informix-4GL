############################################################################
# Nome do Modulo: CTC38m01                                        Marcelo  #
#                                                                 Gilberto #
#                                                                 Wagner   #
# Impressao de laudos/vistorias                                   Jan/1999 #
############################################################################
#                       MANUTENCOES                                        #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86              #
#--------------------------------------------------------------------------#
# 31/12/2009  Amilton, Meta                      Projeto Succod Smallint   #
#--------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define ws_pipe        char(25)

#---------------------------------------------------------------
 function ctc38m01()
#---------------------------------------------------------------

 define d_ctc38m01     record
    atdvclsgl          like datkveiculo.atdvclsgl,
    vcldesc            char(58),
    socvstnum          like datmsocvst.socvstnum,
    socvstlautipcod    like datkvstlautip.socvstlautipcod,
    socvstlautipdes    like datkvstlautip.socvstlautipdes,
    nrvias             smallint
 end record

 define i_ctc38m01     record
    socvstitmgrpcod    like datrvstitmver.socvstitmgrpcod,
    socvstitmgrpdes    like datkvstitmgrp.socvstitmgrpdes,
    socvstitmcod       like datrvstitmver.socvstitmcod,
    socvstitmdes       like datkvstitm.socvstitmdes,
    socvstitmvercod    like datrvstitmver.socvstitmvercod,
    socvstitmverdes    like datkvstitmver.socvstitmverdes,
    socvstitmrevflg    like datrvstitmver.socvstitmrevflg
 end record

 define ws             record
    socvclcod          like datmsocvst.socvclcod,
    socvstnum          like datmsocvst.socvstnum,
    socvstsit          like datmsocvst.socvstsit,
    socvstorgdat       like datmsocvst.socvstorgdat,
    socvstitmgrpcod    like datrvstitmver.socvstitmgrpcod,
    socvstitmgrpdes    like datkvstitmgrp.socvstitmgrpdes,
    socvstlautipcod    like datkveiculo.socvstlautipcod,
    vclcoddig          like datkveiculo.vclcoddig,
    socvstitmcod       like datkvstitm.socvstitmcod,
    socvstlaunum       like datmvstlau.socvstlaunum,
    impr               char(08),
    ok                 integer
 end record

 define ws_linha       char(132)
 define ws_x           smallint

 open window ctc38m01 at 06,02 with form "ctc38m01"
             attribute (form line first)

 while true

   let int_flag = false

   input by name d_ctc38m01.atdvclsgl,       d_ctc38m01.socvstnum,
                 d_ctc38m01.socvstlautipcod, d_ctc38m01.nrvias without defaults

      before field atdvclsgl
             initialize d_ctc38m01 to null
             initialize  ws.*      to null
             display by name d_ctc38m01.*
             display by name d_ctc38m01.atdvclsgl    attribute (reverse)

      after  field atdvclsgl
             display by name d_ctc38m01.atdvclsgl

             if d_ctc38m01.atdvclsgl   is null   then
                next field socvstnum
             end if

             select vclcoddig, socvclcod, socvstlautipcod
               into ws.vclcoddig, ws.socvclcod, ws.socvstlautipcod
               from datkveiculo
              where datkveiculo.atdvclsgl = d_ctc38m01.atdvclsgl

             if sqlca.sqlcode <> 0    then
                error " Veiculo nao cadastrado!"
                next field atdvclsgl
             end if

             call cts15g00(ws.vclcoddig) returning d_ctc38m01.vcldesc
             display by name d_ctc38m01.vcldesc

             if ws.socvstlautipcod is null or
                ws.socvstlautipcod = 0   then
                error " Veiculo nao contem tipo de laudo no cadastro!"
                next field atdvclsgl
             end if

             exit input

      before field socvstnum
             initialize d_ctc38m01 to null
             initialize  ws.*      to null
             display by name d_ctc38m01.*
             display by name d_ctc38m01.socvstnum attribute (reverse)

      after  field socvstnum
             display by name d_ctc38m01.socvstnum

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field atdvclsgl
             end if

             if d_ctc38m01.socvstnum is null then
                next field socvstlautipcod
             end if

             select socvstnum,   socvstsit,
                    socvclcod,   socvstlautipcod,
                    socvstorgdat
               into ws.socvstnum, ws.socvstsit,
                    ws.socvclcod, ws.socvstlautipcod,
                    ws.socvstorgdat
               from datmsocvst
              where socvstnum = d_ctc38m01.socvstnum

             if sqlca.sqlcode <> 0   then
                error " Nro. da vistoria nao cadastrado!"
                next field socvstnum
             end if

             if ws.socvstsit <> 5 then
                error " Vistoria nao esta em situacao realizada, portanto nao pode ser impressa!"
                next field socvstnum
             end if

             select socvstlaunum
               into ws.socvstlaunum
               from datmvstlau
              where datmvstlau.socvstlautipcod = ws.socvstlautipcod
                and (datmvstlau.viginc <= ws.socvstorgdat and
                     datmvstlau.vigfnl >= ws.socvstorgdat)

             if sqlca.sqlcode <> 0    then
                error " Tipo de laudo desta vistoria nao encontrado!"
                next field socvstnum
             end if

             exit input

      before field socvstlautipcod
             display by name d_ctc38m01.*
             display by name d_ctc38m01.socvstlautipcod attribute (reverse)

      after  field socvstlautipcod
             display by name d_ctc38m01.socvstlautipcod

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field socvstnum
             end if

             if d_ctc38m01.socvstlautipcod is null  then
               error " Sigla, nro vistoria ou tipo de laudo deve ser informado!"
                next field socvstlautipcod
             end if

             select socvstlautipdes
               into d_ctc38m01.socvstlautipdes
               from datkvstlautip
              where socvstlautipcod = d_ctc38m01.socvstlautipcod

             if sqlca.sqlcode <> 0   then
                error " Tipo de laudo nao encontrado!"
                call ctc35m09()  returning d_ctc38m01.socvstlautipcod
                next field socvstlautipcod
             end if

             display by name d_ctc38m01.socvstlautipdes

             select socvstlaunum
               into ws.socvstlaunum
               from datmvstlau
              where datmvstlau.socvstlautipcod = d_ctc38m01.socvstlautipcod
                and (datmvstlau.viginc <= today and
                     datmvstlau.vigfnl >= today)

             if sqlca.sqlcode <> 0    then
                error " Tipo de laudo nao esta vigente ou nao possui itens!"
                next field socvstlautipcod
             end if

      before field nrvias
             display by name d_ctc38m01.nrvias attribute (reverse)

      after  field nrvias
             display by name d_ctc38m01.nrvias

             if fgl_lastkey() = fgl_keyval("left")   or
                fgl_lastkey() = fgl_keyval("up")     then
                next field socvstlautipcod
             end if

             if d_ctc38m01.nrvias is null then
                error " Este campo nao pode ser nulo !"
                next field nrvias
             end if

             if d_ctc38m01.nrvias >= 1   and
                d_ctc38m01.nrvias <= 10  then
               else
                error " Nr. de vias esta limitado de 1 a 10 "
                next field nrvias
             end if

             exit input

      on key (interrupt)
         exit input

   end input

   if int_flag  then
      let int_flag = false
      initialize d_ctc38m01.*   to null
      display by name d_ctc38m01.*
      message " Operacao cancelada!"  attribute(reverse)
      clear form
      close window ctc38m01
      return
   end if

   call fun_print_seleciona (g_issk.dptsgl,"")
        returning  ws.ok, ws.impr

   if ws.ok  =  0   then
      error " Departamento/Impressora nao cadastrada!"
     else
      if ws.impr  is null   then
         error " Uma impressora deve ser selecionada!"
        else
         if d_ctc38m01.nrvias is null then
            let d_ctc38m01.nrvias = 1
         end if
         let ws_pipe = "lp -sd ", ws.impr, " -n ",d_ctc38m01.nrvias using "##"
         exit while
      end if
   end if

 end while

 message " Aguarde, imprimindo..."  attribute(reverse)

 start report  rel_laudo

 if d_ctc38m01.atdvclsgl is not null then
    #---------------------------
    # LAUDO VISTORIA POR VEICULO
    #---------------------------
    initialize d_ctc38m01.socvstnum to null
    select socvstlaunum
      into ws.socvstlaunum
      from datmvstlau
     where datmvstlau.socvstlautipcod = ws.socvstlautipcod
       and (datmvstlau.viginc <= today and
            datmvstlau.vigfnl >= today )

    if sqlca.sqlcode = 0 then
       declare c_ctc38m01v cursor for
        select datrvstitmver.socvstitmgrpcod, datkvstitmgrp.socvstitmgrpdes,
               datrvstitmver.socvstitmcod,    datkvstitm.socvstitmdes,
               datrvstitmver.socvstitmvercod, datkvstitmver.socvstitmverdes,
               datrvstitmver.socvstitmrevflg
          from datrvstitmver, datkvstitmgrp, datkvstitm, datkvstitmver
         where datrvstitmver.socvstlaunum    = ws.socvstlaunum
           and datkvstitmgrp.socvstitmgrpcod = datrvstitmver.socvstitmgrpcod
           and datkvstitm.socvstitmcod       = datrvstitmver.socvstitmcod
           and datkvstitmver.socvstitmvercod = datrvstitmver.socvstitmvercod
      order by datrvstitmver.socvstitmgrpcod,
               datrvstitmver.socvstitmcod,
               datrvstitmver.socvstitmvercod

       let ws_linha = " "
       foreach c_ctc38m01v into i_ctc38m01.socvstitmgrpcod,
                                i_ctc38m01.socvstitmgrpdes,
                                i_ctc38m01.socvstitmcod,
                                i_ctc38m01.socvstitmdes,
                                i_ctc38m01.socvstitmvercod,
                                i_ctc38m01.socvstitmverdes,
                                i_ctc38m01.socvstitmrevflg

         if ws.socvstitmcod <> i_ctc38m01.socvstitmcod or
            ws.socvstitmcod is null                    then
            if ws.socvstitmcod is not null then
               output to report rel_laudo ( ws.socvclcod,
                                            d_ctc38m01.socvstnum,
                                            ws.socvstitmgrpcod,
                                            ws.socvstitmgrpdes,
                                            ws_linha )
            end if
            let ws_linha = " "
            let ws_linha[1,39]     =  i_ctc38m01.socvstitmcod using "##" ,"-",
                                      i_ctc38m01.socvstitmdes
            let ws_linha[40,55]    =  i_ctc38m01.socvstitmvercod using "##","-",
                                      i_ctc38m01.socvstitmverdes
            let ws.socvstitmcod    =  i_ctc38m01.socvstitmcod
            let ws.socvstitmgrpcod =  i_ctc38m01.socvstitmgrpcod
            let ws.socvstitmgrpdes =  i_ctc38m01.socvstitmgrpdes
           else
            for ws_x = 56 to 120 step 16
                if ws_linha[ws_x,ws_x+1] = "  " then
                   let ws_linha[ws_x,ws_x+15] = i_ctc38m01.socvstitmvercod using "##" ,"-",
                                                i_ctc38m01.socvstitmverdes
                   exit for
                end if
            end for
         end if

       end foreach
       output to report rel_laudo ( ws.socvclcod,
                                    d_ctc38m01.socvstnum,
                                    ws.socvstitmgrpcod,
                                    ws.socvstitmgrpdes,
                                    ws_linha )

    end if
   else
    if d_ctc38m01.socvstnum is not null then
       #--------------------------------
       # LAUDO VISTORIA POR NRO.VISTORIA
       #--------------------------------
       declare c_ctc38m01n cursor for
        select datmvstmvt.socvstitmgrpcod, datkvstitmgrp.socvstitmgrpdes,
               datmvstmvt.socvstitmcod,    datkvstitm.socvstitmdes,
               datmvstmvt.socvstitmvercod, datkvstitmver.socvstitmverdes
          from datmvstmvt, datkvstitmgrp, datkvstitm, datkvstitmver
         where datmvstmvt.socvstnum          = ws.socvstnum
           and datkvstitmgrp.socvstitmgrpcod = datmvstmvt.socvstitmgrpcod
           and datkvstitm.socvstitmcod       = datmvstmvt.socvstitmcod
           and datkvstitmver.socvstitmvercod = datmvstmvt.socvstitmvercod
      order by datmvstmvt.socvstitmgrpcod,
               datmvstmvt.socvstitmcod

       foreach c_ctc38m01n into i_ctc38m01.socvstitmgrpcod,
                                i_ctc38m01.socvstitmgrpdes,
                                i_ctc38m01.socvstitmcod,
                                i_ctc38m01.socvstitmdes,
                                i_ctc38m01.socvstitmvercod,
                                i_ctc38m01.socvstitmverdes

         select socvstitmrevflg
           into i_ctc38m01.socvstitmrevflg
           from datrvstitmver
          where datrvstitmver.socvstlaunum    = ws.socvstlaunum
            and datrvstitmver.socvstitmcod    = i_ctc38m01.socvstitmcod
            and datrvstitmver.socvstitmvercod = i_ctc38m01.socvstitmvercod

         if sqlca.sqlcode <> 0 then
            let i_ctc38m01.socvstitmrevflg = "N"
         end if

         let ws_linha = " "
         let ws_linha[1,39]  = i_ctc38m01.socvstitmcod using "##" ,"-",
                               i_ctc38m01.socvstitmdes
         let ws_linha[40,55] = i_ctc38m01.socvstitmvercod using "##","-",
                               i_ctc38m01.socvstitmverdes

         if i_ctc38m01.socvstitmrevflg = "S" then
            let ws_linha[57,75] = "ITEM DE RE-VISTORIA"
         end if

         output to report rel_laudo ( ws.socvclcod,
                                      d_ctc38m01.socvstnum,
                                      i_ctc38m01.socvstitmgrpcod,
                                      i_ctc38m01.socvstitmgrpdes,
                                      ws_linha )

       end foreach

      else
       #----------------------------------
       # LAUDO VISTORIA POR TIPO DE LAUDO
       #----------------------------------
       declare c_ctc38m01t cursor for
        select datrvstitmver.socvstitmgrpcod, datkvstitmgrp.socvstitmgrpdes,
               datrvstitmver.socvstitmcod,    datkvstitm.socvstitmdes,
               datrvstitmver.socvstitmvercod, datkvstitmver.socvstitmverdes,
               datrvstitmver.socvstitmrevflg
          from datrvstitmver, datkvstitmgrp, datkvstitm, datkvstitmver
         where datrvstitmver.socvstlaunum    = ws.socvstlaunum
           and datkvstitmgrp.socvstitmgrpcod = datrvstitmver.socvstitmgrpcod
           and datkvstitm.socvstitmcod       = datrvstitmver.socvstitmcod
           and datkvstitmver.socvstitmvercod = datrvstitmver.socvstitmvercod
      order by datrvstitmver.socvstitmgrpcod,
               datrvstitmver.socvstitmcod,
               datrvstitmver.socvstitmvercod

       let ws_linha = " "
       foreach c_ctc38m01t into i_ctc38m01.socvstitmgrpcod,
                                i_ctc38m01.socvstitmgrpdes,
                                i_ctc38m01.socvstitmcod,
                                i_ctc38m01.socvstitmdes,
                                i_ctc38m01.socvstitmvercod,
                                i_ctc38m01.socvstitmverdes,
                                i_ctc38m01.socvstitmrevflg

         if ws.socvstitmcod <> i_ctc38m01.socvstitmcod or
            ws.socvstitmcod is null                    then
            if ws.socvstitmcod is not null then
               output to report rel_laudo ( "",
                                            "",
                                            ws.socvstitmgrpcod,
                                            ws.socvstitmgrpdes,
                                            ws_linha )
            end if
            let ws_linha = " "
            let ws_linha[1,39]     =  i_ctc38m01.socvstitmcod using "##" ,"-",
                                      i_ctc38m01.socvstitmdes
            let ws_linha[40,55]    =  i_ctc38m01.socvstitmvercod using "##","-",
                                      i_ctc38m01.socvstitmverdes
            let ws.socvstitmcod    =  i_ctc38m01.socvstitmcod
            let ws.socvstitmgrpcod =  i_ctc38m01.socvstitmgrpcod
            let ws.socvstitmgrpdes =  i_ctc38m01.socvstitmgrpdes
           else
            for ws_x = 56 to 120 step 16
                if ws_linha[ws_x,ws_x+1] = "  " then
                   let ws_linha[ws_x,ws_x+15] = i_ctc38m01.socvstitmvercod using "##" ,"-",
                                                i_ctc38m01.socvstitmverdes
                   exit for
                end if
            end for
         end if

       end foreach
       output to report rel_laudo ( "",
                                    "",
                                    ws.socvstitmgrpcod,
                                    ws.socvstitmgrpdes,
                                    ws_linha )


    end if
 end if

 finish report rel_laudo

 close window ctc38m01

end function   ##-- ctc38m01


#---------------------------------------------------------------------------
 report rel_laudo( r_ctc38m01_socvclcod,
                   r_ctc38m01_socvstnum,
                   r_ctc38m01_socvstitmgrpcod,
                   r_ctc38m01_socvstitmgrpdes,
                   r_ctc38m01_linha)
#---------------------------------------------------------------------------

 define r_ctc38m01_socvclcod       like datmsocvst.socvclcod
 define r_ctc38m01_socvstnum       like datmsocvst.socvstnum
 define r_ctc38m01_socvstitmgrpcod like datrvstitmver.socvstitmgrpcod
 define r_ctc38m01_socvstitmgrpdes like datkvstitmgrp.socvstitmgrpdes
 define r_ctc38m01_linha           char(132)

 define r_ctc38m01     record
    socvsttip          like datmsocvst.socvsttip,
    socvstdat          like datmsocvst.socvstdat,
    socvstfotqtd       like datmsocvst.socvstfotqtd,
    atldat             like datmsocvst.atldat,
    atlemp             like datmsocvst.atlemp,
    atlmat             like datmsocvst.atlmat,
    funnom             like isskfunc.funnom,
    pstcoddig          like datkveiculo.pstcoddig,
    vclcoddig          like datkveiculo.vclcoddig,
    vclctfnom          like datkveiculo.vclctfnom,
    vclanofbc          like datkveiculo.vclanofbc,
    vclanomdl          like datkveiculo.vclanomdl,
    vcllicnum          like datkveiculo.vcllicnum,
    vclchsinc          like datkveiculo.vclchsinc,
    vclchsfnl          like datkveiculo.vclchsfnl,
    vclcorcod          like datkveiculo.vclcorcod,
    vclpnttip          like datkveiculo.vclpnttip,
    vclcmbcod          like datkveiculo.vclcmbcod,
    atdvclsgl          like datkveiculo.atdvclsgl,
    vclaqsnom          like datkveiculo.vclaqsnom,
    vclsgrseq          like datkvclsgr.vclsgrseq,
    sgdirbcod          like datkvclsgr.sgdirbcod,
    viginc             like datkvclsgr.viginc,
    vigfnl             like datkvclsgr.vigfnl,
    ramcod             like datkvclsgr.ramcod,
    succod             like datkvclsgr.succod,
    aplnumdig          like datkvclsgr.aplnumdig,
    itmnumdig          like datkvclsgr.itmnumdig,
    sgraplnum          like datkvclsgr.sgraplnum,
    vcldesc            char(58),
    nomgrr             like dpaksocor.nomgrr,
    sgdnom             like gcckcong.sgdnom,
    socvsttipdes       char(15),
    vclcordes          char(40),
    vclpntdes          char(40),
    vclcmbdes          char(40),
    chassi             char(20),
    linhavis           char(101),
    linhaseg           char(110),
    datavist           char(10),
    traco              char(132),
    descfas            char(11),
    socvstfasnum       like datmvstobs.socvstfasnum,
    caddat             like datmvstobs.caddat,
    socvstfasobsseq    like datmvstobs.socvstfasobsseq,
    cadmat             like datmvstobs.cadmat,
    blqobstxt          like datmvstobs.blqobstxt,
    socvstfasnumant    like datmvstobs.socvstfasnum,
    caddatant          like datmvstobs.caddat,
    privez             smallint
 end record

 define r_ctc38m01obs  array[300] of record
        blqobstxt      char(70)
 end record

 define arr_aux        smallint
 define ws2_x          smallint


 output report to  pipe  ws_pipe
    left   margin  00
    right  margin  132
    top    margin  01
    bottom margin  01
    page   length  66

 order by  r_ctc38m01_socvstitmgrpcod

 format

    first page header
       initialize r_ctc38m01.*   to null
       initialize r_ctc38m01obs  to null
       let r_ctc38m01.traco = "----------------------------------------------------------------------------------------------------------------------------------"
       if r_ctc38m01_socvclcod is null and
          r_ctc38m01_socvstnum is null then
          # LAUDO EM BRANCO
         else
          #---------------------------------------------------------
          # Acessa a vistoria
          #---------------------------------------------------------
          let r_ctc38m01.linhavis = " "
          if r_ctc38m01_socvstnum is not null then
             select socvsttip   , socvstdat,
                    socvstfotqtd, atldat,
                    atlemp      , atlmat
               into r_ctc38m01.socvsttip   , r_ctc38m01.socvstdat,
                    r_ctc38m01.socvstfotqtd, r_ctc38m01.atldat,
                    r_ctc38m01.atlemp      , r_ctc38m01.atlmat
               from datmsocvst
              where socvstnum = r_ctc38m01_socvstnum

              if r_ctc38m01.atldat > "01/01/1900" then
                 let r_ctc38m01.datavist = r_ctc38m01.atldat
              end if

              #-----------------------------------------------------
              # Nome do vistoriador
              #-----------------------------------------------------
              let r_ctc38m01.funnom = "NOME NAO ENCONTRADO!"
              select funnom
                into r_ctc38m01.funnom
                from isskfunc
               where isskfunc.empcod = r_ctc38m01.atlemp
                 and isskfunc.funmat = r_ctc38m01.atlmat

              let r_ctc38m01.funnom = upshift(r_ctc38m01.funnom)

              #-----------------------------------------------------
              # Tipo de vistoria
              #-----------------------------------------------------
              let r_ctc38m01.socvsttipdes = "NAO ENCONTRADO!"
              select cpodes
                into r_ctc38m01.socvsttipdes
                from iddkdominio
               where cponom = "socvsttip"
                 and cpocod =  r_ctc38m01.socvsttip

               let r_ctc38m01.linhavis[1,21]   = "NRO. VISTORIA : ",
                                                 r_ctc38m01_socvstnum using "#####"
               let r_ctc38m01.linhavis[29,48]  = "TIPO ",r_ctc38m01.socvsttipdes
               let r_ctc38m01.linhavis[49,74]  = "DATA VISTORIA : ",
                                                 r_ctc38m01.socvstdat
               let r_ctc38m01.linhavis[77,101] = "REALIZADA EM : ",
                                                 r_ctc38m01.datavist
            else

               let r_ctc38m01.linhavis[49,66]  = "DATA DA VISTORIA :"

          end if

          #---------------------------------------------------------
          # Acessa o veiculo
          #---------------------------------------------------------
          select pstcoddig, vclcoddig,
                 vclctfnom, vclanofbc,
                 vclanomdl, vcllicnum,
                 vclchsinc, vclchsfnl,
                 vclcorcod, vclpnttip,
                 vclcmbcod, atdvclsgl,
                 vclaqsnom
            into r_ctc38m01.pstcoddig, r_ctc38m01.vclcoddig,
                 r_ctc38m01.vclctfnom, r_ctc38m01.vclanofbc,
                 r_ctc38m01.vclanomdl, r_ctc38m01.vcllicnum,
                 r_ctc38m01.vclchsinc, r_ctc38m01.vclchsfnl,
                 r_ctc38m01.vclcorcod, r_ctc38m01.vclpnttip,
                 r_ctc38m01.vclcmbcod, r_ctc38m01.atdvclsgl,
                 r_ctc38m01.vclaqsnom
            from datkveiculo
           where datkveiculo.socvclcod = r_ctc38m01_socvclcod

          #---------------------------------------------------------
          # Dados do Veiculo
          #---------------------------------------------------------
          call cts15g00(r_ctc38m01.vclcoddig) returning r_ctc38m01.vcldesc

          #---------------------------------------------------------
          # Dados do prestador
          #---------------------------------------------------------
          let r_ctc38m01.nomgrr = "PRESTADOR NAO CADASTRADO!"
          select nomgrr
            into r_ctc38m01.nomgrr
            from dpaksocor
           where dpaksocor.pstcoddig = r_ctc38m01.pstcoddig

          #---------------------------------------------------------
          # Cor/Acabamento pintura/Combustivel/Chassi veiculo
          #---------------------------------------------------------
          let r_ctc38m01.vclcordes = "COR NAO CADASTRADA"
          select cpodes
            into r_ctc38m01.vclcordes
            from iddkdominio
           where cponom  =  "vclcorcod"
             and cpocod  =  r_ctc38m01.vclcorcod

          let r_ctc38m01.vclpntdes = "ACABAMENTO NAO CADASTRADO"
          select cpodes
            into r_ctc38m01.vclpntdes
            from iddkdominio
           where cponom  =  "vclpnttip"
             and cpocod  =  r_ctc38m01.vclpnttip

          let r_ctc38m01.vclcmbdes = "COMBUSTIVEL NAO CADASTRADO"
          select cpodes
            into r_ctc38m01.vclcmbdes
            from iddkdominio
           where cponom  =  "vclcmbcod"
             and cpocod  =  r_ctc38m01.vclcmbcod

          let r_ctc38m01.vclcordes = upshift(r_ctc38m01.vclcordes)
          let r_ctc38m01.vclpntdes = upshift(r_ctc38m01.vclpntdes)
          let r_ctc38m01.vclcmbdes = upshift(r_ctc38m01.vclcmbdes)

          let r_ctc38m01.chassi = r_ctc38m01.vclchsinc, r_ctc38m01.vclchsfnl
          if r_ctc38m01.vclchsinc  is null   and
             r_ctc38m01.vclchsfnl  is null   then
             initialize r_ctc38m01.chassi to null
          end if

          #---------------------------------------------------------
          # Seguro
          #---------------------------------------------------------
          select max(datkvclsgr.vclsgrseq)
            into r_ctc38m01.vclsgrseq
            from datkvclsgr
           where datkvclsgr.socvclcod = r_ctc38m01_socvclcod

          select viginc,    vigfnl,
                 sgdirbcod, ramcod,
                 succod,    aplnumdig,
                 itmnumdig, sgraplnum
           into  r_ctc38m01.viginc,    r_ctc38m01.vigfnl,
                 r_ctc38m01.sgdirbcod, r_ctc38m01.ramcod,
                 r_ctc38m01.succod,    r_ctc38m01.aplnumdig,
                 r_ctc38m01.itmnumdig, r_ctc38m01.sgraplnum
            from datkvclsgr
           where datkvclsgr.socvclcod = r_ctc38m01_socvclcod
             and datkvclsgr.vclsgrseq = r_ctc38m01.vclsgrseq

          if sqlca.sqlcode = 0 then
             let r_ctc38m01.sgdnom = "CIA SEGUROS NAO ENCONTRADA"
             select sgdnom
               into r_ctc38m01.sgdnom
               from gcckcong
              where gcckcong.sgdirbcod = r_ctc38m01.sgdirbcod

             let r_ctc38m01.linhaseg = r_ctc38m01.sgdirbcod using "####","-",
                                       r_ctc38m01.sgdnom

             let r_ctc38m01.linhaseg[36,45] = " Apolice.:"
             if r_ctc38m01.sgdirbcod  =  5886   then   #--> Porto Seguro
                let r_ctc38m01.linhaseg[47,71] = r_ctc38m01.ramcod using "####"," ",
                                                 r_ctc38m01.succod using "#####", " ", #using "##"," ", # Projeto Succod
                                                 r_ctc38m01.aplnumdig using "#########"," ",
                                                 r_ctc38m01.itmnumdig using "#######"
               else
                let r_ctc38m01.linhaseg[47,61] = r_ctc38m01.sgraplnum
             end if
             let r_ctc38m01.linhaseg[75,109] = " VIGENCIA : ",
                                               r_ctc38m01.viginc," a ",
                                               r_ctc38m01.vigfnl
            else
             initialize r_ctc38m01.linhaseg to null
          end if
       end if

       print column 001, "PORTO SEGURO CIA. DE SEGUROS GERAIS",
             column 103, "CTC38M01",
             column 115, "PAG.:    ", pageno using "###,##&"
       print column 115, "DATA: "   , today
       print column 040, "VISTORIA DE VEICULOS DE PRESTADORES DE SERVICOS - PORTO SOCORRO",
             column 115, "HORA:   " , time
       print column 045, r_ctc38m01.linhavis[1,48]
       print column 045, r_ctc38m01.linhavis[49,101]
       print column 001, r_ctc38m01.traco

       print column 001, "VISTORIADOR .....: ", r_ctc38m01.funnom,
             column 095, "QTDE FOTOS : ", r_ctc38m01.socvstfotqtd
             skip 1 line
       print column 001, "PRESTADOR .......: ", r_ctc38m01.pstcoddig using "######",
                                                " ", r_ctc38m01.nomgrr
             skip 1 line
       print column 001, "NOME CERTIFICADO : ", r_ctc38m01.vclctfnom
             skip 1 line
       print column 001, "NOME AQUISICAO ..: ", r_ctc38m01.vclaqsnom
             skip 1 line
       print column 001, "VEICULO .........: ", r_ctc38m01.atdvclsgl," ",
                                                r_ctc38m01_socvclcod using "###"," ",
                                                r_ctc38m01.vcldesc,
             column 095, "FAB./MOD. .: ", r_ctc38m01.vclanofbc," ",
                                          r_ctc38m01.vclanomdl
             skip 1 line
       print column 001, "PLACA ...........: ", r_ctc38m01.vcllicnum,
             column 060, "COR : ", r_ctc38m01.vclcordes clipped," ", r_ctc38m01.vclpntdes
             skip 1 line
       print column 001, "CHASSI ..........: ", r_ctc38m01.chassi,
             column 060, "COMBUSTIVEL : ", r_ctc38m01.vclcmbdes
             skip 1 line
       print column 001, "SEGURO ..........: ", r_ctc38m01.linhaseg
             skip 1 line


    page header
       print column 001, "PORTO SEGURO CIA. DE SEGUROS GERAIS",
             column 070, "CTC38M01",
             column 115, "PAG.:    ", pageno using "###,##&"
       print column 115, "DATA: "   , today
       print column 040, "VISTORIA DE VEICULOS DE PRESTADORES DE SERVICOS - PORTO SOCORRO",
             column 115, "HORA:   " , time
       print column 045, r_ctc38m01.linhavis[1,48]
       print column 045, r_ctc38m01.linhavis[49,101]
       print column 001, r_ctc38m01.traco
             skip 2 line


    before group of r_ctc38m01_socvstitmgrpcod
       need 05 lines
       print column 001, r_ctc38m01.traco
       print column 053, "GRUPO : ", r_ctc38m01_socvstitmgrpcod using "##","-",
                                     r_ctc38m01_socvstitmgrpdes
       print column 001, r_ctc38m01.traco
       skip 1 line


    after group of r_ctc38m01_socvstitmgrpcod
       skip 1 line


    on every row
       print column 001, r_ctc38m01_linha


    on last row
      skip 1 lines
      need 04 lines
      print column 001, r_ctc38m01.traco
      print column 053, "OBSERVACOES"
      print column 001, r_ctc38m01.traco
      skip 1 lines

      if r_ctc38m01_socvstnum is not null then
         declare c_ctc38m01r cursor for
          select socvstfasnum, caddat, socvstfasobsseq, cadmat, blqobstxt
            from datmvstobs
           where socvstnum = r_ctc38m01_socvstnum
           order by socvstfasnum desc, caddat asc , socvstfasobsseq asc

         let arr_aux      = 1
         let r_ctc38m01.privez    = true
         let r_ctc38m01.caddatant = "31/12/1899"

         foreach c_ctc38m01r into r_ctc38m01.socvstfasnum,    r_ctc38m01.caddat,
                                  r_ctc38m01.socvstfasobsseq, r_ctc38m01.cadmat,
                                  r_ctc38m01.blqobstxt

            if r_ctc38m01.caddatant <> r_ctc38m01.caddat or
               r_ctc38m01.socvstfasnum <> r_ctc38m01.socvstfasnumant then

               if r_ctc38m01.privez  =  true  then
                  let r_ctc38m01.privez = false
                 else
                  let arr_aux = arr_aux + 2
               end if

               select funnom
                 into r_ctc38m01.funnom
                 from isskfunc
                where isskfunc.funmat = r_ctc38m01.cadmat

               select cpodes
                 into r_ctc38m01.descfas
                 from iddkdominio
                where cponom = "socvstfasnum"
                  and cpocod =  r_ctc38m01.socvstfasnum

               if sqlca.sqlcode <> 0 then
                  let r_ctc38m01.descfas = "ERRO !!!  "
               end if

               let r_ctc38m01obs[arr_aux].blqobstxt =
                                       "Em: ",    r_ctc38m01.caddat clipped,
                                       "  Por: ", r_ctc38m01.funnom clipped,
                                       "      Fase: ", r_ctc38m01.socvstfasnum,
                                       " - ",r_ctc38m01.descfas

               let r_ctc38m01.caddatant = r_ctc38m01.caddat
               let r_ctc38m01.socvstfasnumant = r_ctc38m01.socvstfasnum
               let arr_aux      = arr_aux + 1
            end if

            let arr_aux = arr_aux + 1

            let r_ctc38m01obs[arr_aux].blqobstxt = r_ctc38m01.blqobstxt

         end foreach

         if arr_aux  >  1  then
            for ws2_x = 1 to arr_aux
               print column 020, r_ctc38m01obs[ws2_x].blqobstxt
            end for
         end if

      end if

end report   ##-- ctc38m01


