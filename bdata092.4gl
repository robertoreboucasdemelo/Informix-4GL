#------------------------------------------------------------------------#
#                                                                        #
#   bdata092 ->  Emite 2 Relatorios gerando 2 arquivos .TXT que serao    #
#                enviados via e-mail.                                    #
#                                                                        #
#   Objetivo ->  1-Relatorio: Seleciona todos veiculos c/ MDT apontando  #
#                Posicao da Frota.                                       #
#                                                                        #
#                2-Relatorio: Seleciona todos Botoes/Sinais das viaturas #
#                do prestador sempre pegando com a data de hoje e 1 hora #
#                anterior a hora atual.                                  #
#                                                                        #
#   Data    :22/11/00                                                    #
#                                                                        #
#........................................................................#
#                                                                        #
#                  * * * Alteracoes * * *                                #
#                                                                        #
# Data        Autor Fabrica  Origem    Alteracao                         #
# ----------  -------------- --------- ----------------------------------#
# 10/09/2005  Julianna, Meta Melhorias Melhorias de performance          #
# 08/03/2010  Adriano Santos CT10029839Retirar emails com padrao antigo  #
#------------------------------------------------------------------------#

database porto

define ws_array array [04] of record
       socvcllcltip      like  datmfrtpos.socvcllcltip,
       ufdcod            like  datmfrtpos.ufdcod,
       cidnom            like  datmfrtpos.cidnom,
       brrnom            like  datmfrtpos.brrnom,
       lclltt            like  datmfrtpos.lclltt,
       lcllgt            like  datmfrtpos.lcllgt,
       endzon            like  datmfrtpos.endzon,
       atldat            like  datmfrtpos.atldat,
       atlhor            like  datmfrtpos.atlhor
end record

main
   call fun_dba_abre_banco('CT24HS')
   
   set isolation to dirty read
   display 'Inicio: ' run "date"
   call bdata092()
   display 'Fim: ' run "date"
end main

#-------------------------------------------------------------------------
function bdata092()
#-------------------------------------------------------------------------

   define r_datkveiculo     record
          socvclcod         like  datkveiculo.socvclcod,
          pstcoddig         like  datkveiculo.pstcoddig,
          atdvclsgl         like  datkveiculo.atdvclsgl,
          mdtcod            like  datkveiculo.mdtcod
   end record

   define r_dpaksocor       record
          maides            like  dpaksocor.maides
   end record

   define r_dattfrotalocal  record
          cttdat            like  dattfrotalocal.cttdat,
          ctthor            like  dattfrotalocal.ctthor,
          c24atvcod         like  dattfrotalocal.c24atvcod,
          atdsrvnum         like  dattfrotalocal.atdsrvnum,
          atdsrvano         like  dattfrotalocal.atdsrvano,
          srrcoddig         like  dattfrotalocal.srrcoddig
   end record

   define r_datksrr         record
          srrabvnom         like  datksrr.srrabvnom
   end record

   define r_datmmdtmvt      record
          mdtmvtseq         like  datmmdtmvt.mdtmvtseq,
          caddat            like  datmmdtmvt.caddat,
          cadhor            like  datmmdtmvt.cadhor,
          mdtcod            like  datmmdtmvt.mdtcod,
          mdtmvttipcod      like  datmmdtmvt.mdtmvttipcod,
          mdtbotprgseq      like  datmmdtmvt.mdtbotprgseq,
          mdtmvtdigcnt      like  datmmdtmvt.mdtmvtdigcnt,
          ufdcod            like  datmmdtmvt.ufdcod,
          cidnom            like  datmmdtmvt.cidnom,
          brrnom            like  datmmdtmvt.brrnom,
          endzon            like  datmmdtmvt.endzon,
          lclltt            like  datmmdtmvt.lclltt,
          lcllgt            like  datmmdtmvt.lcllgt,
          mdtmvtdircod      like  datmmdtmvt.mdtmvtdircod,
          mdtmvtvlc         like  datmmdtmvt.mdtmvtvlc,
          mdtmvtstt         like  datmmdtmvt.mdtmvtstt
   end record

   define w_comando       char(300)
   define w_comando2      char(400)
   define w_dat_pro       date
   define ws_path         char(60)
   define ws_path2        char(60)
   define ws_saipath      char(40)
   define ws_sairela      char(20)
   define s               integer
   define w_hora          datetime hour to minute
   define w_hora1         datetime hour to minute
   define w_hora2         char(09)
   define w_hora3         char(09)

   let w_hora = current
   let w_hora1 = w_hora - 1 units hour
   let w_hora2 = w_hora1
   let w_hora2[4,5] = "00"
   let w_hora2[6,8] = ":00"
   let w_hora3 = w_hora1
   let w_hora3[4,5] = "59"
   let w_hora3[6,8] = ":59"

   let w_dat_pro = today

   display 'PROCESSANDO DAS ', w_hora2, ' AS ',w_hora3

   #display 'PROCESSANDO HORA INICIAL: ', w_hora2
   #display 'PROCESSANDO HORA FINAL  : ', w_hora3
   display 'PROCESSANDO PERIODO DE ',  w_dat_pro

   let ws_sairela = "/rdat09201"
   call f_path("DAT","RELATO") returning ws_saipath
   let ws_path = ws_saipath clipped,ws_sairela
   let ws_sairela = "/rdat09202"
   let ws_path2 = ws_saipath clipped, ws_sairela

   start report r_rdat09201 to ws_path
   start report r_rdat09202 to ws_path2

#-----------------#
#     PREPARE     #
#-----------------#

   let w_comando = " select maides       ",
                   " from dpaksocor      ",
                   " where pstcoddig = ? "
   prepare s_dpaksocor from w_comando
   declare c_dpaksocor cursor for s_dpaksocor

   let w_comando = " select cttdat, ctthor, ",
                   " c24atvcod, atdsrvnum,  ",
                   " atdsrvano, srrcoddig   ",
                   " from dattfrotalocal    ",
                   " where socvclcod = ?    "
   prepare s_dattfrotalocal from w_comando
   declare c_dattfrotalocal cursor for s_dattfrotalocal

   let w_comando = " select srrabvnom    ",
                   " from datksrr        ",
                   " where srrcoddig = ? "
   prepare s_datksrr from w_comando
   declare c_datksrr cursor for s_datksrr

   declare c_datkveiculo cursor for
           select socvclcod, pstcoddig,
                  atdvclsgl, mdtcod
                  from datkveiculo
   foreach c_datkveiculo into r_datkveiculo.socvclcod,
                              r_datkveiculo.pstcoddig,
                              r_datkveiculo.atdvclsgl,
                              r_datkveiculo.mdtcod

           if r_datkveiculo.mdtcod is null then
              continue foreach
           end if

           open  c_dpaksocor using r_datkveiculo.pstcoddig
           fetch c_dpaksocor into  r_dpaksocor.maides

           if sqlca.sqlcode <> 0 then
              continue foreach
           end if

           open  c_dattfrotalocal using r_datkveiculo.socvclcod
           fetch c_dattfrotalocal into  r_dattfrotalocal.cttdat,
                                        r_dattfrotalocal.ctthor,
                                        r_dattfrotalocal.c24atvcod,
                                        r_dattfrotalocal.atdsrvnum,
                                        r_dattfrotalocal.atdsrvano,
                                        r_dattfrotalocal.srrcoddig

           if sqlca.sqlcode <> 0 then
              continue foreach
           end if

           open  c_datksrr using r_dattfrotalocal.srrcoddig
           fetch c_datksrr into  r_datksrr.srrabvnom

           if sqlca.sqlcode <> 0 then
              continue foreach
           end if

           declare c_datmfrtpos cursor for
                   select socvcllcltip, ufdcod,
                   cidnom, brrnom, lclltt,
                   lcllgt, endzon, atldat, atlhor
                   from datmfrtpos
                   where socvclcod = r_datkveiculo.socvclcod
                   order by socvcllcltip

           let s = 1
           foreach c_datmfrtpos into ws_array[s].socvcllcltip,
                                     ws_array[s].ufdcod,
                                     ws_array[s].cidnom,
                                     ws_array[s].brrnom,
                                     ws_array[s].lclltt,
                                     ws_array[s].lcllgt,
                                     ws_array[s].endzon,
                                     ws_array[s].atldat,
                                     ws_array[s].atlhor
                 if ws_array[s].socvcllcltip <> 1 and
                    ws_array[s].socvcllcltip <> 2 and
                    ws_array[s].socvcllcltip <> 3 then
                    continue foreach
                 end if

                 declare c_datmmdtmvt cursor for
                 select mdtmvtseq, caddat, cadhor,
                        mdtcod, mdtmvttipcod, mdtbotprgseq,
                        mdtmvtdigcnt, ufdcod, cidnom,
                        brrnom, endzon, lclltt, lcllgt,
                        mdtmvtdircod, mdtmvtvlc, mdtmvtstt
                        from datmmdtmvt
                        where mdtcod = r_datkveiculo.mdtcod
                        and   caddat = w_dat_pro
                        and   cadhor between w_hora2 and w_hora3
                 foreach c_datmmdtmvt into r_datmmdtmvt.mdtmvtseq,
                                           r_datmmdtmvt.caddat,
                                           r_datmmdtmvt.cadhor,
                                           r_datmmdtmvt.mdtcod,
                                           r_datmmdtmvt.mdtmvttipcod,
                                           r_datmmdtmvt.mdtbotprgseq,
                                           r_datmmdtmvt.mdtmvtdigcnt,
                                           r_datmmdtmvt.ufdcod,
                                           r_datmmdtmvt.cidnom,
                                           r_datmmdtmvt.brrnom,
                                           r_datmmdtmvt.endzon,
                                           r_datmmdtmvt.lclltt,
                                           r_datmmdtmvt.lcllgt,
                                           r_datmmdtmvt.mdtmvtdircod,
                                           r_datmmdtmvt.mdtmvtvlc,
                                           r_datmmdtmvt.mdtmvtstt

                       output to report r_rdat09202(r_datkveiculo.atdvclsgl,
                                                    r_datkveiculo.mdtcod,
                                                    r_datmmdtmvt.mdtmvtseq,
                                                    r_datmmdtmvt.caddat,
                                                    r_datmmdtmvt.cadhor,
                                                    r_datmmdtmvt.mdtmvttipcod,
                                                    r_datmmdtmvt.mdtbotprgseq,
                                                    r_datmmdtmvt.mdtmvtdigcnt,
                                                    r_datmmdtmvt.ufdcod,
                                                    r_datmmdtmvt.cidnom,
                                                    r_datmmdtmvt.brrnom,
                                                    r_datmmdtmvt.endzon,
                                                    r_datmmdtmvt.lclltt,
                                                    r_datmmdtmvt.lcllgt,
                                                    r_datmmdtmvt.mdtmvtdircod,
                                                    r_datmmdtmvt.mdtmvtvlc,
                                                    r_datmmdtmvt.mdtmvtstt)
                 end foreach
                 initialize r_datmmdtmvt.mdtmvtseq    to null
                 initialize r_datmmdtmvt.caddat       to null
                 initialize r_datmmdtmvt.cadhor       to null
                 initialize r_datmmdtmvt.mdtmvttipcod to null
                 initialize r_datmmdtmvt.mdtbotprgseq to null
                 initialize r_datmmdtmvt.mdtmvtdigcnt to null
                 initialize r_datmmdtmvt.ufdcod       to null
                 initialize r_datmmdtmvt.cidnom       to null
                 initialize r_datmmdtmvt.brrnom       to null
                 initialize r_datmmdtmvt.endzon       to null
                 initialize r_datmmdtmvt.lclltt       to null
                 initialize r_datmmdtmvt.lcllgt       to null
                 initialize r_datmmdtmvt.mdtmvtdircod to null
                 initialize r_datmmdtmvt.mdtmvtvlc    to null
                 initialize r_datmmdtmvt.mdtmvtstt    to null

                 let s = s +1
           end foreach
           output to report r_rdat09201(r_datkveiculo.atdvclsgl,
                                        r_datkveiculo.mdtcod,
                                        r_dattfrotalocal.c24atvcod,
                                        r_dattfrotalocal.cttdat,
                                        r_dattfrotalocal.ctthor,
                                        r_dattfrotalocal.atdsrvnum,
                                        r_dattfrotalocal.atdsrvano,
                                        r_dattfrotalocal.srrcoddig,
                                        r_datksrr.srrabvnom)

           initialize r_dpaksocor.maides         to null
           initialize r_dattfrotalocal.cttdat    to null
           initialize r_dattfrotalocal.ctthor    to null
           initialize r_dattfrotalocal.c24atvcod to null
           initialize r_dattfrotalocal.atdsrvnum to null
           initialize r_dattfrotalocal.atdsrvano to null
           initialize r_dattfrotalocal.srrcoddig to null
           initialize r_datksrr.srrabvnom        to null
           initialize ws_array[s].socvcllcltip   to null
           initialize ws_array[s].ufdcod         to null
           initialize ws_array[s].cidnom         to null
           initialize ws_array[s].brrnom         to null
           initialize ws_array[s].lclltt         to null
           initialize ws_array[s].lcllgt         to null
           initialize ws_array[s].endzon         to null
           initialize ws_array[s].atldat         to null
           initialize ws_array[s].atlhor         to null
   end foreach
   initialize r_datkveiculo.socvclcod to null
   initialize r_datkveiculo.pstcoddig to null
   initialize r_datkveiculo.atdvclsgl to null
   initialize r_datkveiculo.mdtcod    to null

   finish report r_rdat09201
   finish report r_rdat09202

   # GERA E-MAIL
{
   if r_dpaksocor.maides is null then
      let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
                       " -s 'Relatorio de apontar a",
                       " posicao da frota (",today,")'",
                       " oriente_eduardo/spaulo_psocorro_controles@u23 < ",
                         ws_path clipped
      run w_comando2

      let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
                       " -s 'Relatorio de apontar os",
                       " Botoes/Sinais das viaturas da CT24HS (",today,")' ",
                       " oriente_eduardo/spaulo_psocorro_controles@u23 < ",
                         ws_path2 clipped

      run w_comando2
   else
      let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
                       " -s 'Relatorio de apontar a",
                       " posicao da frota (",today,")'",
                       " r_dpaksocor.maides < ",
                         ws_path clipped
      run w_comando2

      let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
                       " -s 'Relatorio de apontar os",
                       " Botoes/Sinais das viaturas da CT24HS (",today,")' ",
                       " r_dpaksocor.maides < ",
                         ws_path2 clipped
      run w_comando2
   end if
}

#-----------Teste mail------

   #let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
   #                 " -s 'Relatorio de apontar a posicao da frota (",today,")'",
   #                 " oriente_eduardo/spaulo_psocorro_controles@u23 < ",
   #                   ws_path clipped
   #run w_comando2
   #
   #let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
   #                 " -s 'Relatorio de apontar os",
   #                 " Botoes/Sinais das viaturas da CT24HS (",today,")' ",
   #                 " oriente_eduardo/spaulo_psocorro_controles@u23 < ",
   #                   ws_path2 clipped
   #run w_comando2

#  let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
#                   " -s 'Relatorio de apontar a posicao da frota (",today,")'",
#                   " costa_marcus/spaulo_info_sistemas@u55 < ",
#                     ws_path clipped
#  run w_comando2

#  let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
#                   " -s 'Relatorio de apontar os",
#                   " Botoes/Sinais das viaturas da CT24HS (",today,")' ",
#                   " costa_marcus/spaulo_info_sistemas@u55 < ",
#                     ws_path2 clipped
#  run w_comando2

   #let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
   #                 " -s 'Relatorio de apontar a posicao da frota (",today,")'",
   #                 " bayarri_gustavo/spaulo_info_sistemas@u55 < ",
   #                   ws_path clipped
   #run w_comando2
   #
   #let w_comando2 = " mailx -r 'danubio_ct24h/spaulo_info_sistemas@portoseguro.com.br'",
   #                 " -s 'Relatorio de apontar os",
   #                 " Botoes/Sinais das viaturas da CT24HS (",today,")' ",
   #                 " bayarri_gustavo/spaulo_info_sistemas@u55 < ",
   #                   ws_path2 clipped
   #run w_comando2

end function

#-----------------------------------------------------------------------
report r_rdat09201(r)
#-----------------------------------------------------------------------

define r record
       atdvclsgl     like datkveiculo.atdvclsgl,
       mdtcod        like datkveiculo.mdtcod,
       c24atvcod     like dattfrotalocal.c24atvcod,
       cttdat        like dattfrotalocal.cttdat,
       ctthor        like dattfrotalocal.ctthor,
       atdsrvnum     like dattfrotalocal.atdsrvnum,
       atdsrvano     like dattfrotalocal.atdsrvano,
       srrcoddig     like dattfrotalocal.srrcoddig,
       srrabvnom     like datksrr.srrabvnom
end record

define s             smallint
define w_for         char(426)

            output

                 page length   01
                 left margin   00
                 top margin    00
                 bottom margin 00

                 format

                 on every row

#----Saida de dados----

                 for s = 1 to 3
                   let w_for = w_for clipped ,
                               ws_array[s].ufdcod,"|",
                               ws_array[s].cidnom,"|",
                               ws_array[s].brrnom,"|",
                               ws_array[s].lclltt using "-&&&&&&&&.&&&&&&","|",
                               ws_array[s].lcllgt using "-&&&&&&&&&.&&&&&&","|",
                               ws_array[s].atldat,"|",
                               ws_array[s].atlhor,"|"

                 end for

                 let w_for = w_for clipped

                 print r.atdvclsgl,          "|",
                       r.mdtcod,             "|",
                       r.c24atvcod,          "|",
                       r.cttdat,             "|",
                       r.ctthor,             "|",
                       r.atdsrvnum           using "&&&&&&&&&&","|",
                       r.atdsrvano           using "&&", "|",
                       r.srrcoddig           using "&&&&&&&&","|",
                       r.srrabvnom,          "|",
                       w_for

     end report

#-----------------------------------------------------------------------
report r_rdat09202(r)
#-----------------------------------------------------------------------

define r record
       atdvclsgl          like    datkveiculo.atdvclsgl,
       mdtcod             like    datkveiculo.mdtcod,
       mdtmvtseq          like    datmmdtmvt.mdtmvtseq,
       caddat             like    datmmdtmvt.caddat,
       cadhor             like    datmmdtmvt.cadhor,
       mdtmvttipcod       like    datmmdtmvt.mdtmvttipcod,
       mdtbotprgseq       like    datmmdtmvt.mdtbotprgseq,
       mdtmvtdigcnt       like    datmmdtmvt.mdtmvtdigcnt,
       ufdcod             like    datmmdtmvt.ufdcod,
       cidnom             like    datmmdtmvt.cidnom,
       brrnom             like    datmmdtmvt.brrnom,
       endzon             like    datmmdtmvt.endzon,
       lclltt             like    datmmdtmvt.lclltt,
       lcllgt             like    datmmdtmvt.lcllgt,
       mdtmvtdircod       like    datmmdtmvt.mdtmvtdircod,
       mdtmvtvlc          like    datmmdtmvt.mdtmvtvlc,
       mdtmvtstt          like    datmmdtmvt.mdtmvtstt
end record

            output

                 page length   01
                 left margin   00
                 top margin    00
                 bottom margin 00

                 format

                    on every row

#----Saida de dados----

                         print r.atdvclsgl,    "|",
                               r.mdtcod,       "|",
                               r.mdtmvtseq,    "|",
                               r.caddat,       "|",
                               r.cadhor,       "|",
                               r.mdtmvttipcod, "|",
                               r.mdtbotprgseq, "|",
                               r.mdtmvtdigcnt  using "&&&&&&","|",
                               r.ufdcod,       "|",
                               r.cidnom,       "|",
                               r.brrnom,       "|",
                               r.endzon,       "|",
                               r.lclltt        using "-&&&&&&&&.&&&&&&","|",
                               r.lcllgt        using "-&&&&&&&&&.&&&&&&","|",
                               r.mdtmvtdircod, "|",
                               r.mdtmvtvlc     using "&&&&.&","|",
                               r.mdtmvtstt,    "|"
     end report

