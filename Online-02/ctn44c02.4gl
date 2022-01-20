#############################################################################
# Nome do Modulo: ctn44c02                                             Raji #
#                                                                           #
# Consulta logradouro dos dados recebidos dos MDT's                Ago/2002 #
#---------------------------------------------------------------------------#
# Alteracao - 06/08/2004 - Mariana (Meta) - OSF 38253                       #
#             Alterar funcao p/ contemplar as informacoes de uf, cidade  e  #
#             bairro                                                        #
# 13/07/2007 Ligia Mattge PSI 2108383 retornando parametros                 #
# 15/01/2010 Fabio Costa  PSI 246174  Funcao ctn44c02_endereco              #
#############################################################################
database porto

define  m_prep    char(01)

#----------------------------------------------------------------
function ctn44c02_prepare()
#----------------------------------------------------------------
define l_comando      char(800)

   let l_comando  = " select cidnom, ufdcod "
                   ,"   from datkmpacid "
                   ,"  where mpacidcod = ? "
   prepare pctn44c02001 from l_comando
   declare cctn44c02001 cursor for pctn44c02001
   let l_comando = " select brrnom "
                  ,"   from datkmpabrr "
                  ,"  where mpabrrcod = ? "

   prepare pctn44c02002 from l_comando
   declare cctn44c02002 cursor for pctn44c02002
   let l_comando = " select lgdtip, lgdnom "
                  ,"   from datkmpalgd "
                  ,"  where mpalgdcod = ? "
   prepare pctn44c02003 from l_comando
   declare cctn44c02003 cursor for pctn44c02003

   let l_comando =  " select mpacidcod, mpabrrcod, mpalgdcod, mpalgdincnum, mpalgdfnlnum ",
                    "  from datkmpalgdsgm ",
                    " where lclltt >= ? and lclltt <= ? ",
                    "   and lcllgt >= ? and lcllgt <= ? "
 prepare pctn44c02004 from l_comando
 declare cctn44c02004 cursor for pctn44c02004
 let m_prep = "S"
end function

#----------------------------------------------------------------
function ctn44c02(p_ctn44c02)
#----------------------------------------------------------------
 define p_ctn44c02 record
    lclltt              like datmlcl.lclltt,
    lcllgt              like datmlcl.lcllgt
 end record

 define ws record
    comando             char(300),
    fim                 integer,

    lcllttmin           like datmlcl.lclltt,
    lcllttmax           like datmlcl.lclltt,
    lcllgtmin           like datmlcl.lcllgt,
    lcllgtmax           like datmlcl.lcllgt,
    mpacidcod           like datkmpacid.mpacidcod,
    mpabrrcod           like datkmpabrr.mpabrrcod,
    mpalgdcod           like datkmpalgdsgm.mpalgdcod,
    ufdcod              like datkmpacid.ufdcod,
    cidnom              like datkmpacid.cidnom,
    brrnom              like datkmpabrr.brrnom,
    lgdnom              like datkmpalgd.lgdnom,
    lgdtip              like datkmpalgd.lgdtip,
    mpalgdincnum        like datkmpalgdsgm.mpalgdincnum,
    mpalgdfnlnum        like datkmpalgdsgm.mpalgdfnlnum,

    msgtxt1             char(40),
    msgtxt2             char(40),
    msgtxt3             char(40),
    msgtxt4             char(40),
    ret                 char(1)
 end record

 define l_vezes smallint

 if m_prep is null then
    call ctn44c02_prepare()
 end if

 initialize  ws.*  to  null


 let ws.fim       = 1
 let ws.lcllttmin = p_ctn44c02.lclltt
 let ws.lcllttmax = p_ctn44c02.lclltt
 let ws.lcllgtmin = p_ctn44c02.lcllgt
 let ws.lcllgtmax = p_ctn44c02.lcllgt
 let l_vezes = 0

 while ws.fim = 1
    whenever error continue
    open cctn44c02004 using ws.lcllttmin,
                            ws.lcllttmax,
                            ws.lcllgtmin,
                            ws.lcllgtmax

    fetch cctn44c02004 into ws.mpacidcod,
			    ws.mpabrrcod,
			    ws.mpalgdcod,
                            ws.mpalgdincnum,
                            ws.mpalgdfnlnum
    whenever error stop
    if ws.mpalgdcod is not null or l_vezes = 100 then
       let ws.fim = 0
    end if
    close cctn44c02004
    let l_vezes = l_vezes + 1

    let ws.lcllttmin = ws.lcllttmin - 0.0001
    let ws.lcllttmax = ws.lcllttmax + 0.0001
    let ws.lcllgtmin = ws.lcllgtmin - 0.0001
    let ws.lcllgtmax = ws.lcllgtmax + 0.0001
 end while

 if ws.mpacidcod is null then
    display 'Nao achou o endereco no mapa para: ', p_ctn44c02.lclltt, ' ',
            p_ctn44c02.lcllgt
    return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
 end if
 whenever error continue
 open cctn44c02001 using ws.mpacidcod
 fetch cctn44c02001 into ws.cidnom
                       , ws.ufdcod
 whenever error stop
 if sqlca.sqlcode < 0 then
    display "Erro de acesso a tabela datkmpacid ",
          "Erro :", sqlca.sqlcode, "ISAM :",sqlca.sqlerrd[2]
    return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
 else
    if sqlca.sqlcode = notfound then
       display "Registro nao encontrado na tabela datkmpacid "
       return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
    end if
 end if
 whenever error continue
 open cctn44c02002 using ws.mpabrrcod
 fetch cctn44c02002 into ws.brrnom
 whenever error stop
 if sqlca.sqlcode < 0 then
    display "Erro no acesso a tabela datkmpabrr ",
          "Erro :", sqlca.sqlcode, "ISAM :",sqlca.sqlerrd[2]
    return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
 else
    if sqlca.sqlcode = notfound then
       #display "Registro nao encontrado na tabela datkmpabrr "
       #return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
    end if
 end if

 whenever error continue
 open cctn44c02003 using ws.mpalgdcod
 fetch cctn44c02003 into ws.lgdtip
                       , ws.lgdnom
 whenever error stop
 if sqlca.sqlcode < 0 then
     display "Erro no acesso a tabela datkmpalgd ",
          "Erro :", sqlca.sqlcode, "ISAM :",sqlca.sqlerrd[2]
     return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
 else
    if sqlca.sqlcode = notfound then
       display "Registro nao encontrado na tabela datkmpalgd "
       return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4
    end if
 end if

 let ws.msgtxt1  = "*** LOCAL DA TRANSMISSAO ***"
 let ws.msgtxt2  = "UF-Cidade: ", ws.ufdcod clipped,
                             "-", ws.cidnom
 let ws.msgtxt3  = "Bairro   : ", ws.brrnom
 let ws.msgtxt4  = ws.lgdtip clipped, " ",
                   ws.lgdnom clipped, " ",
                   ws.mpalgdincnum using "<<<<<&",   " a ",
                   ws.mpalgdfnlnum using "<<<<<&"
 let ws.msgtxt2[40] = '.'
 let ws.msgtxt3[40] = '.'
 let ws.msgtxt4[40] = '.'
 return ws.msgtxt1, ws.msgtxt2, ws.msgtxt3, ws.msgtxt4

 #call cts08g01("A", "", ws.msgtxt1,ws.msgtxt2,ws.msgtxt3, ws.msgtxt4)
 #     returning ws.ret
end function

#----------------------------------------------------------------
function ctn44c02_endereco(p_ctn44c02)
#----------------------------------------------------------------

  define p_ctn44c02 record
         lclltt  like datmlcl.lclltt ,
         lcllgt  like datmlcl.lcllgt
  end record

  define l_ctn44c02 record
         comando       char(300)                       ,
         fim           integer                         ,
         lcllttmin     like datmlcl.lclltt             ,
         lcllttmax     like datmlcl.lclltt             ,
         lcllgtmin     like datmlcl.lcllgt             ,
         lcllgtmax     like datmlcl.lcllgt             ,
         mpacidcod     like datkmpacid.mpacidcod       ,
         mpabrrcod     like datkmpabrr.mpabrrcod       ,
         mpalgdcod     like datkmpalgdsgm.mpalgdcod    ,
         ufdcod        like datkmpacid.ufdcod          ,
         cidnom        like datkmpacid.cidnom          ,
         brrnom        like datkmpabrr.brrnom          ,
         lgdnom        like datkmpalgd.lgdnom          ,
         lgdtip        like datkmpalgd.lgdtip          ,
         mpalgdincnum  like datkmpalgdsgm.mpalgdincnum ,
         mpalgdfnlnum  like datkmpalgdsgm.mpalgdfnlnum ,
         lgdnum        decimal(6,0)
  end record

  define l_vezes smallint

  if m_prep is null then
     call ctn44c02_prepare()
  end if

  initialize l_ctn44c02.* to null

  let l_ctn44c02.fim       = 1
  let l_ctn44c02.lcllttmin = p_ctn44c02.lclltt
  let l_ctn44c02.lcllttmax = p_ctn44c02.lclltt
  let l_ctn44c02.lcllgtmin = p_ctn44c02.lcllgt
  let l_ctn44c02.lcllgtmax = p_ctn44c02.lcllgt
  let l_vezes = 0

  while l_ctn44c02.fim = 1

     whenever error continue
     open cctn44c02004 using l_ctn44c02.lcllttmin,
                             l_ctn44c02.lcllttmax,
                             l_ctn44c02.lcllgtmin,
                             l_ctn44c02.lcllgtmax

     fetch cctn44c02004 into l_ctn44c02.mpacidcod,
                             l_ctn44c02.mpabrrcod,
                             l_ctn44c02.mpalgdcod,
                             l_ctn44c02.mpalgdincnum,
                             l_ctn44c02.mpalgdfnlnum
     whenever error stop
     if l_ctn44c02.mpalgdcod is not null or l_vezes = 100
        then
        let l_ctn44c02.fim = 0
     end if
     close cctn44c02004
     let l_vezes = l_vezes + 1
     let l_ctn44c02.lcllttmin = l_ctn44c02.lcllttmin - 0.0001
     let l_ctn44c02.lcllttmax = l_ctn44c02.lcllttmax + 0.0001
     let l_ctn44c02.lcllgtmin = l_ctn44c02.lcllgtmin - 0.0001
     let l_ctn44c02.lcllgtmax = l_ctn44c02.lcllgtmax + 0.0001
  end while
  if l_ctn44c02.mpacidcod is null   # nao achou segmento de endereco
     then
     display 'CTN44C02 - Erro busca DATKMPALGDSGM X/Y: ',
             p_ctn44c02.lclltt, ' | ', p_ctn44c02.lcllgt
     return l_ctn44c02.ufdcod, l_ctn44c02.cidnom,
            l_ctn44c02.lgdtip, l_ctn44c02.lgdnom,
            l_ctn44c02.brrnom, l_ctn44c02.lgdnum
  end if
  # calcular a media entre o intervalo, aproximar do numero real do local
  let l_ctn44c02.lgdnum =
      (l_ctn44c02.mpalgdincnum + l_ctn44c02.mpalgdfnlnum) / 2
  whenever error continue
  open cctn44c02001 using l_ctn44c02.mpacidcod
  fetch cctn44c02001 into l_ctn44c02.cidnom, l_ctn44c02.ufdcod
  whenever error stop
  if sqlca.sqlcode != 0
     then
     display 'CTN44C02 - Erro busca DATKMPACID ', sqlca.sqlcode,
             ' X/Y: ', p_ctn44c02.lclltt, ' | ', p_ctn44c02.lcllgt
     return l_ctn44c02.ufdcod, l_ctn44c02.cidnom,
            l_ctn44c02.lgdtip, l_ctn44c02.lgdnom,
            l_ctn44c02.brrnom, l_ctn44c02.lgdnum
  end if

  whenever error continue
  open cctn44c02002 using l_ctn44c02.mpabrrcod
  fetch cctn44c02002 into l_ctn44c02.brrnom
  whenever error stop
  if sqlca.sqlcode != 0
     then
     display 'CTN44C02 - Erro busca DATKMPABRR ', sqlca.sqlcode,
             ' X/Y: ', p_ctn44c02.lclltt, ' | ', p_ctn44c02.lcllgt
     return l_ctn44c02.ufdcod, l_ctn44c02.cidnom,
            l_ctn44c02.lgdtip, l_ctn44c02.lgdnom,
            l_ctn44c02.brrnom, l_ctn44c02.lgdnum
  end if

  whenever error continue
  open cctn44c02003 using l_ctn44c02.mpalgdcod
  fetch cctn44c02003 into l_ctn44c02.lgdtip, l_ctn44c02.lgdnom
  whenever error stop

  if sqlca.sqlcode != 0
     then
     display 'CTN44C02 - Erro busca DATKMPALGD ', sqlca.sqlcode,
             ' X/Y: ', p_ctn44c02.lclltt, ' | ', p_ctn44c02.lcllgt
     return l_ctn44c02.ufdcod, l_ctn44c02.cidnom,
            l_ctn44c02.lgdtip, l_ctn44c02.lgdnom,
            l_ctn44c02.brrnom, l_ctn44c02.lgdnum
  end if
  return l_ctn44c02.ufdcod, l_ctn44c02.cidnom,
         l_ctn44c02.lgdtip, l_ctn44c02.lgdnom,
         l_ctn44c02.brrnom, l_ctn44c02.lgdnum

end function
