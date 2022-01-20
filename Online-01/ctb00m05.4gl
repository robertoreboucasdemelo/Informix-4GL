#############################################################################
# Nome do Modulo: CTB00M05                                         Marcelo  #
#                                                                  Gilberto #
# Acerto de laudo em branco para pagto. de locacoes                Out/1996 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 10/12/1999  PSI 7263-0   Gilberto     Verificar se apolice foi emitida    #
#                                       para a proposta informada no ato da #
#                                       reserva do veiculo.                 #
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################


 globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_dtresol86   date 
#---------------------------------------------------------------
 function ctb00m05(param)
#---------------------------------------------------------------

 define param         record
    atddat            like datmservico.atddat,
    prporg            like datrligprp.prporg,
    prpnumdig         like datrligprp.prpnumdig
 end record

 define d_ctb00m05    record
    succod            like datrligapol.succod    ,
    ramcod            like datrligapol.ramcod    ,
    aplnumdig         like datrligapol.aplnumdig ,
    itmnumdig         like datrligapol.itmnumdig
 end record

 define a_ctb00m05    array[20] of record
    edsnumdig         like abamdoc.edsnumdig ,
    edstipdes         char (25)              ,
    edssttdes         char (09)              ,
    viginc            like abbmdoc.viginc    ,
    cpotxt            char (01)              ,
    vigfnl            like abbmdoc.vigfnl
 end record

 define arr_aux       smallint

 define retorno       record
    succod            like datrligapol.succod    ,
    ramcod            like datrligapol.ramcod    ,
    aplnumdig         like datrligapol.aplnumdig ,
    itmnumdig         like datrligapol.itmnumdig ,
    edsnumref         like datrligapol.edsnumref
 end record

 define ws            record
    itmqtd            smallint,
    sucnom            like gabksuc.sucnom,
    edstip            like abbmdoc.edstip,
    edsstt            like abamdoc.edsstt,
    dctnumseq         like abamdoc.dctnumseq,
    itmnumdig         like abbmdoc.itmnumdig
 end record

 define sql           char (200)

 initialize d_ctb00m05.*  to null
 initialize a_ctb00m05    to null

 let sql = "select viginc, vigfnl  ,",
           "       edstip, itmnumdig",
           "  from abbmdoc          ",
           " where succod    = ? and",
           "       aplnumdig = ? and",
           "       dctnumseq = ?    "

 prepare sel_abbmdoc from sql
 declare c_abbmdoc cursor for sel_abbmdoc

 let sql = "select edstipdes     ",
           "  from agdktip       ",
           " where edstip = ?    "

 prepare sel_agdktip from sql
 declare c_agdktip cursor for sel_agdktip

 open window ctb00m05 at 10,06 with form "ctb00m05"
             attribute(border,form line 1, comment line last - 1)

 display by name param.*

#select grlinf[01,10] into m_dtresol86
#   from datkgeral
#   where grlchv='ct24resolucao86'

#if m_dtresol86 <= today then
#   let d_ctb00m05.ramcod = 531
#   let retorno.ramcod    = 531
#else
#   let d_ctb00m05.ramcod = 31
#   let retorno.ramcod    = 31
#end if


 call cta00m03(param.prporg, param.prpnumdig)
      returning d_ctb00m05.succod,
                d_ctb00m05.ramcod,
                d_ctb00m05.aplnumdig,
                d_ctb00m05.itmnumdig

 if d_ctb00m05.aplnumdig is not null  then
    let d_ctb00m05.aplnumdig = (d_ctb00m05.aplnumdig - (d_ctb00m05.aplnumdig mod 10))/10
 end if

 if d_ctb00m05.itmnumdig is not null  then
    let d_ctb00m05.itmnumdig = (d_ctb00m05.itmnumdig - (d_ctb00m05.itmnumdig mod 10))/10
 end if

 message " (F17)Abandona"

 input by name d_ctb00m05.*  without defaults

    before field succod
       display by name d_ctb00m05.succod  attribute (reverse)

    after  field succod
       display by name d_ctb00m05.succod

       if d_ctb00m05.succod is null  then
          let d_ctb00m05.succod = 01
          display by name d_ctb00m05.succod
       end if

       select succod from gabksuc
        where succod = d_ctb00m05.succod

       if sqlca.sqlcode = notfound  then
          error " Sucursal nao cadastrada!"
          call c24geral11() returning d_ctb00m05.succod, ws.sucnom
          next field succod
       end if

       let retorno.succod = d_ctb00m05.succod

    before field aplnumdig
       display by name d_ctb00m05.aplnumdig attribute (reverse)

    after  field aplnumdig
       display by name d_ctb00m05.aplnumdig

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field succod
       end if

       if d_ctb00m05.aplnumdig is null  then
          error " Numero da APOLICE deve ser informado!"
          next field aplnumdig
       else
          if d_ctb00m05.succod  is null  then
             error " Sucursal deve ser informada!"
             next field succod
          end if

          initialize retorno.aplnumdig to null

          call F_FUNDIGIT_DIGAPOL (d_ctb00m05.succod, 
                                   d_ctb00m05.ramcod,
                                   d_ctb00m05.aplnumdig)
               returning retorno.aplnumdig

          if retorno.aplnumdig is null  then
             error " Problemas no digito da apolice. AVISE A INFORMATICA!"
             next field aplnumdig
          end if

          select succod from abamapol
           where succod    = d_ctb00m05.succod     and
                 aplnumdig = retorno.aplnumdig

          if sqlca.sqlcode = notfound  then
             error " Apolice de automovel nao cadastrada!"
             next field aplnumdig
          end if

          let d_ctb00m05.aplnumdig = retorno.aplnumdig
          let retorno.ramcod = d_ctb00m05.ramcod
       end if

    before field itmnumdig
       display by name d_ctb00m05.itmnumdig attribute (reverse)

    after  field itmnumdig
       display by name d_ctb00m05.itmnumdig

       if fgl_lastkey() = fgl_keyval("up")    or
          fgl_lastkey() = fgl_keyval("left")  then
          next field aplnumdig
       end if

       let g_index                        =  1
       let g_dctoarray[g_index].succod    =  d_ctb00m05.succod
       let g_dctoarray[g_index].aplnumdig =  d_ctb00m05.aplnumdig

       if d_ctb00m05.itmnumdig  is null   then
          call cta00m13 (d_ctb00m05.succod, retorno.aplnumdig)
               returning d_ctb00m05.itmnumdig

          if d_ctb00m05.itmnumdig   is null   then
             error " Nenhum item foi selecionado!"
             next field  itmnumdig
          else
             display by name d_ctb00m05.itmnumdig
          end if
       end if

       call F_FUNDIGIT_DIGITO11 (d_ctb00m05.itmnumdig)
                       returning retorno.itmnumdig


       if retorno.itmnumdig  is null   then
          error " Problemas no digito do item. AVISE A INFORMATICA!"
          next field itmnumdig
       end if

       let ws.itmqtd = 0

       select count(distinct itmnumdig)
         into ws.itmqtd
         from abbmitem
        where abbmitem.succod    = d_ctb00m05.succod    and
              abbmitem.aplnumdig = retorno.aplnumdig    and
              abbmitem.itmnumdig = retorno.itmnumdig

       if ws.itmqtd = 0 then
          error " Item nao existe neste documento!"
          next field itmnumdig
       end if

       let d_ctb00m05.itmnumdig = retorno.itmnumdig

       display by name d_ctb00m05.*

    on key (interrupt)
       initialize retorno.* to null
       exit input

 end input

 let arr_aux = 1

 declare c_ctb00m05 cursor for
    select edsnumdig, edsstt, dctnumseq
      from abamdoc
     where succod    = retorno.succod      and
           aplnumdig = retorno.aplnumdig

 foreach c_ctb00m05 into a_ctb00m05[arr_aux].edsnumdig,
                         ws.edsstt,
                         ws.dctnumseq

    open  c_abbmdoc using d_ctb00m05.succod,
                          d_ctb00m05.aplnumdig,
                          ws.dctnumseq
    fetch c_abbmdoc into  a_ctb00m05[arr_aux].viginc,
                          a_ctb00m05[arr_aux].vigfnl,
                          ws.edstip, ws.itmnumdig
    close c_abbmdoc

    if ws.itmnumdig <> d_ctb00m05.itmnumdig  then
       continue foreach
    end if

    let a_ctb00m05[arr_aux].edstipdes = "*** NAO CADASTRADO ***"

    open  c_agdktip using ws.edstip
    fetch c_agdktip into  a_ctb00m05[arr_aux].edstipdes
    close c_agdktip

    if ws.edsstt = "A"  then
       let a_ctb00m05[arr_aux].edssttdes = "ATIVO"
    else
       let a_ctb00m05[arr_aux].edssttdes = "CANCELADO"
    end if

    let a_ctb00m05[arr_aux].cpotxt = "a"

    let arr_aux = arr_aux + 1

    if arr_aux > 20  then
       error " Limite excedido. AVISE A INFORMATICA!"
       exit foreach
    end if
 end foreach

 if arr_aux  =  1   then
    error "Nenhum endosso foi encontrado!"
    message " (F17)Abandona"
 else
    message " (F17)Abandona, (F8)Seleciona"
    call set_count(arr_aux-1)

    display array  a_ctb00m05 to s_ctb00m05.*
       on key (interrupt)
          initialize a_ctb00m05 to null
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          let retorno.edsnumref = a_ctb00m05[arr_aux].edsnumdig
          exit display
    end display

    let int_flag = false
 end if

 close window ctb00m05

 return retorno.*

end function  ###  ctb00m05
