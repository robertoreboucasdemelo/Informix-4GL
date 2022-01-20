###############################################################################
# Nome do Modulo: CTA02M14                                           Ruiz     #
# Pesquisa sinistro para apolice                                     Fev/2001 #
# este modulo e chamdo pelo prog. do agendamento osvom005(marcelo fornachari).#
###############################################################################

globals '/homedsa/projetos/geral/globals/glct.4gl'

{
main
   define ws_1 like ssamavs.sinavsnum
   define ws_2 like ssamavs.sinavsano
   call cta02m14(26,31,34) returning ws_1, ws_2
   display ws_1,"-",ws_2
end main
}
#------------------------------------------------------------------------------
function cta02m14(param)
#------------------------------------------------------------------------------

 define param      record
     succod        like datrligapol.succod,
     ramcod        like datrligapol.ramcod,
     aplnumdig     like datrligapol.aplnumdig
 end record
 define parametros record
     sinavsnum  like ssamavs.sinavsnum,
     sinavsano  like ssamavs.sinavsano
 end record
 define a_cta02m14 array[50]  of record
     sinavsnum like ssamavs.sinavsnum,
     sinavsano like ssamavs.sinavsano,
     sinocrdat like ssamavs.sinocrdat,
     sinrclnom like ssamavs.sinrclnom,
     sinbemdes like ssamavs.sinbemdes
 end record

 define ws record
    ligdat     like datmligacao.ligdat,
    sinavsnum  like ssamavs.sinavsnum,
    sinavsano  like ssamavs.sinavsano,
    sinavsnum1 like ssamavs.sinavsnum,
    sinavsano1 like ssamavs.sinavsano,
    confirma   char(01)
 end record

 define arr_aux integer

 initialize ws.*         to null
 initialize parametros.* to null

 let int_flag = false
 let arr_aux  = 0

 message " Aguarde, pesquisando..." attribute (reverse)

 let ws.ligdat    =  today - 20 units day

 declare c_sinavsnum cursor for
    select c.sinavsnum,c.sinavsano
       from datrligapol a,datmligacao b, datrligsinavs c
      where a.succod     = param.succod
        and a.ramcod     = param.ramcod
        and a.aplnumdig  = param.aplnumdig
        and a.lignum     = b.lignum
        and b.c24astcod  = "N11"
        and a.lignum     = c.lignum
        and b.ligdat    >= ws.ligdat
        and b.ligdat    <= today

 foreach c_sinavsnum into ws.sinavsnum,ws.sinavsano
     let arr_aux = arr_aux + 1
     if arr_aux > 50  then
        let arr_aux = 50
        error " Limite excedido, existem mais de 50 sinistros p/ apolice!"
     end if
     let a_cta02m14[arr_aux].sinavsnum = ws.sinavsnum
     let a_cta02m14[arr_aux].sinavsano = ws.sinavsano
     select sinocrdat,sinrclnom,sinbemdes
          into a_cta02m14[arr_aux].sinocrdat,
               a_cta02m14[arr_aux].sinrclnom,
               a_cta02m14[arr_aux].sinbemdes
          from ssamavs
         where sinavsnum = ws.sinavsnum
           and sinavsano = ws.sinavsano

 end foreach

 message " "

 if arr_aux > 0 then
    open window cta02m14 at 09,02 with form "cta02m14"
           attribute(form line first)

    message " (F17)Abandona, (F8)Seleciona"

    call set_count(arr_aux)

    display array a_cta02m14 to s_cta02m14.*
      on key (F8)
         let arr_aux              = arr_curr()
         let parametros.sinavsnum = a_cta02m14[arr_aux].sinavsnum
         let parametros.sinavsano = a_cta02m14[arr_aux].sinavsano
         exit display

      on key (interrupt)
         let int_flag = false
         initialize parametros.* to null
         exit display
    end display

    close window cta02m14
 else
    if arr_aux <> 0 then
       let parametros.sinavsnum = a_cta02m14[arr_aux].sinavsnum
       let parametros.sinavsano = a_cta02m14[arr_aux].sinavsano
    end if
 end if

 if parametros.sinavsnum = 0 or
    parametros.sinavsnum is null  then
    call cts08g01("A","N","","VERIFICAR O NUMERO DO AVISO DE",
                  "SINISTRO PARA PROSSEGUIR!","")
          returning ws.confirma
    call cta02m12() returning ws.sinavsnum1,ws.sinavsano1
    select sinavsnum,sinavsano
           into ws.sinavsnum,ws.sinavsano
           from ssamavs
          where sinavsnum = ws.sinavsnum1
            and sinavsano = ws.sinavsano1
    if sqlca.sqlcode <> 0  then
       initialize parametros.* to null
       call cts08g01("A","N","","HA NECESSIDADE DE PREENCHER",
                           "O AVISO DE SINISTRO !","")
       returning ws.confirma
    else
       let parametros.sinavsnum = ws.sinavsnum1
       let parametros.sinavsano = ws.sinavsano1
    end if
 end if
 let int_flag = false
 return parametros.*

end function #---- fim cta02m14

