# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Pronto Socorro                                            #
# Modulo.........: ctc11g00                                                  #
# Objetivo.......: Manter inforamcoes de assistencia passageiro - aviao      #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#----------------------------------------------------------------------------#

database porto

 define m_prep_sql smallint

#--------------------------
function ctc11g00_prepare()
#--------------------------

 define l_sql char(1000)

 let l_sql = ' select trpaersaidat, trpaersaihor, '
            ,' trpaerchedat, trpaerchehor from datmtrppsgaer '
            ,' where atdsrvnum = ? '
            ,' and atdsrvano = ? '
            ,' and vooopc = ? '
            ,' and voocnxseq = ? '

 prepare pctc11g00001 from l_sql
 declare cctc11g00001 cursor for pctc11g00001

 let l_sql = ' select max(vooopc) from datmtrppsgaer '
            ,' where atdsrvnum = ? '
            ,' and atdsrvano = ? '

 prepare pctc11g00005 from l_sql
 declare cctc11g00005 cursor for pctc11g00005

 let l_sql = ' select max(voocnxseq) from datmtrppsgaer '
            ,' where atdsrvnum = ? '
            ,' and atdsrvano = ? '
            ,' and vooopc = ? '

 prepare pctc11g00006 from l_sql
 declare cctc11g00006 cursor for pctc11g00006

 let l_sql = ' select max(voocnxseq) from datmtrppsgaer '
            ,' where atdsrvnum = ? '
            ,' and atdsrvano = ? '

 prepare pctc11g00002 from l_sql
 declare cctc11g00002 cursor for pctc11g00002

 let l_sql = ' select max(vooopc) from datmtrppsgaer '
            ,' where atdsrvnum = ? '
            ,' and atdsrvano = ? '

 prepare pctc11g00003 from l_sql
 declare cctc11g00003 cursor for pctc11g00003

 let l_sql = ' insert into datmtrppsgaer '
            ,'(atdsrvnum, atdsrvano, voocnxseq, arpembcod, trpaersaidat, '
            ,' trpaersaihor, arpchecod, trpaerchedat, trpaerchehor, '
            ,' trpaervoonum, trpaerlzdnum, trpaerptanum, '
            ,' aerciacod, escvoo, vooopc, adlpsgvlr, crnpsgvlr, totpsgvlr, '
            ,' trpaerempnom ) '
           , ' values (?,?,?,?,?,?,?,?,?,?,?,?,?,"",?,?,?,?,?) '
 prepare pctc11g00004 from l_sql

 let m_prep_sql = true

end function


#------------------------------------
function ctc11g00_aviao(lr_param)
#------------------------------------
  define lr_param record
    atdsrvnum       like datmtrppsgaer.atdsrvnum,
    atdsrvano       like datmtrppsgaer.atdsrvano,
    acao            char(20),
    aerciacod       like datmtrppsgaer.aerciacod,
    trpaervoonum    like datmtrppsgaer.trpaervoonum,
    trpaerptanum    like datmtrppsgaer.trpaerptanum,
    trpaerlzdnum    like datmtrppsgaer.trpaerlzdnum,
    adlpsgvlr       like datmtrppsgaer.adlpsgvlr,
    crnpsgvlr       like datmtrppsgaer.crnpsgvlr,
    totpsgvlr       like datmtrppsgaer.totpsgvlr,
    arpembcod       like datmtrppsgaer.arpembcod,
    trpaersaidat    like datmtrppsgaer.trpaersaidat,
    trpaersaihor    like datmtrppsgaer.trpaersaihor,
    arpchecod       like datmtrppsgaer.arpchecod,
    trpaerchedat    like datmtrppsgaer.trpaerchedat,
    trpaerchehor    like datmtrppsgaer.trpaerchehor,
    atdetpcod       like datmsrvacp.atdetpcod,
    vooopc          like datmtrppsgaer.vooopc,
    voocnxseq       like datmtrppsgaer.voocnxseq
 end record

 define l_vooopc    like datmtrppsgaer.vooopc
 define l_voocnxseq like datmtrppsgaer.voocnxseq
 define l_resultado smallint
 define l_msg       char(50) 

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc11g00_prepare()
 end if

 let l_vooopc    = null
 let l_voocnxseq = null
 let l_msg = null

 whenever error continue

 if lr_param.atdetpcod = 43 then 
    let lr_param.atdetpcod = 13 
 else  
    if lr_param.atdetpcod = 13 then  

       call ctc11g00_ins_datmtrppsgaer
            (lr_param.atdsrvnum, lr_param.atdsrvano, lr_param.voocnxseq,
             lr_param.vooopc, lr_param.aerciacod, lr_param.trpaervoonum,
             lr_param.trpaerptanum,
             lr_param.trpaerlzdnum, lr_param.adlpsgvlr, lr_param.crnpsgvlr,
             lr_param.totpsgvlr, lr_param.arpembcod, lr_param.trpaersaidat,
             lr_param.trpaersaihor, lr_param.arpchecod, lr_param.trpaerchedat,
             lr_param.trpaerchehor)
             returning l_resultado

       if l_resultado = 0 then
          let lr_param.atdetpcod = 14
       end if
    else  
       if lr_param.atdetpcod = 44 then  
          let lr_param.atdetpcod = 46 
       end if 
       if lr_param.atdetpcod = 45 then 
          let lr_param.atdetpcod = 47
       end if 
    end if 
 end if 

 return lr_param.atdetpcod

end function

function ctc11g00_ins_datmtrppsgaer(lr_param)

  define lr_param record
    atdsrvnum       like datmtrppsgaer.atdsrvnum,
    atdsrvano       like datmtrppsgaer.atdsrvano,
    voocnxseq       like datmtrppsgaer.voocnxseq,
    vooopc          like datmtrppsgaer.vooopc,
    aerciacod       like datmtrppsgaer.aerciacod,
    trpaervoonum    like datmtrppsgaer.trpaervoonum,
    trpaerptanum    like datmtrppsgaer.trpaerptanum,
    trpaerlzdnum    like datmtrppsgaer.trpaerlzdnum,
    adlpsgvlr       like datmtrppsgaer.adlpsgvlr,
    crnpsgvlr       like datmtrppsgaer.crnpsgvlr,
    totpsgvlr       like datmtrppsgaer.totpsgvlr,
    arpembcod       like datmtrppsgaer.arpembcod,
    trpaersaidat    like datmtrppsgaer.trpaersaidat,
    trpaersaihor    like datmtrppsgaer.trpaersaihor,
    arpchecod       like datmtrppsgaer.arpchecod,
    trpaerchedat    like datmtrppsgaer.trpaerchedat,
    trpaerchehor    like datmtrppsgaer.trpaerchehor
 end record

 define l_resultado  smallint
 define l_msg        char(70)
 define l_aercianom  like datkciaaer.aercianom

   let l_resultado  = null
   let l_msg = null
   let l_aercianom = null

   call ctc10g00_dados_cia (1, lr_param.aerciacod)
        returning l_resultado, l_msg, l_aercianom

   if lr_param.atdsrvnum is null then
      display "ERRO@@atdsrvnum ", lr_param.atdsrvnum,"@@"
   end if
   if lr_param.atdsrvano is null then
      display "ERRO@@atdsrvano ", lr_param.atdsrvano,"@@"
   end if
   if lr_param.voocnxseq is null then
      display "ERRO@@voocnxseq ", lr_param.voocnxseq,"@@"
   end if
   if lr_param.arpembcod is null then
      display "ERRO@@arpembcod ", lr_param.arpembcod,"@@"
   end if
   if lr_param.trpaersaidat is null then
      display "ERRO@@trpaersaidat ", lr_param.trpaersaidat,"@@"
   end if
   if lr_param.trpaersaihor is null then
      display "ERRO@@trpaersaihor ", lr_param.trpaersaihor,"@@"
   end if
   if lr_param.arpchecod is null then
      display "ERRO@@arpchecod ", lr_param.arpchecod,"@@"
   end if
   if lr_param.trpaerchedat is null then
      display "ERRO@@trpaerchedat ", lr_param.trpaerchedat,"@@"
   end if
   if lr_param.trpaerchehor is null then
      display "ERRO@@trpaerchehor ", lr_param.trpaerchehor,"@@"
   end if
   if l_aercianom is null then
      display "ERRO@@trpaerempnom ", l_aercianom,"@@"
   end if
   if lr_param.aerciacod is null then
      display "ERRO@@aerciacod ", lr_param.aerciacod,"@@"
   end if
   if lr_param.vooopc is null then
      display "ERRO@@vooopc ", lr_param.vooopc,"@@"
   end if

   whenever error continue
   execute pctc11g00004 using
           lr_param.atdsrvnum, lr_param.atdsrvano, lr_param.voocnxseq, 
           lr_param.arpembcod, lr_param.trpaersaidat, lr_param.trpaersaihor,
           lr_param.arpchecod, lr_param.trpaerchedat, lr_param.trpaerchehor,
           lr_param.trpaervoonum, lr_param.trpaerlzdnum, lr_param.trpaerptanum,
           lr_param.aerciacod, lr_param.vooopc, 
           lr_param.adlpsgvlr, lr_param.crnpsgvlr, lr_param.totpsgvlr,
           l_aercianom
   whenever error stop

   if sqlca.sqlcode <> 0 then
     let l_msg = "ERRO@@Erro inserindo voo ", sqlca.sqlcode,"@@"
     display l_msg
   end if

   return sqlca.sqlcode

end function

function ctc11g00_ver_par(lr_param)

   define lr_param     record
          atdsrvnum    like datmservico.atdsrvnum,
          atdsrvano    like datmservico.atdsrvano,
          acao         char(15),
          vooopc       like datmtrppsgaer.vooopc
          end record

   define l_vooopc     like datmtrppsgaer.vooopc,
          l_vooopc_ant like datmtrppsgaer.vooopc,
          l_voocnxseq  like datmtrppsgaer.voocnxseq,
          l_voocnxseq_ant  like datmtrppsgaer.voocnxseq,
          l_msg            char(50)

   let l_vooopc = 0
   let l_vooopc_ant = 0
   let l_voocnxseq = 0
   let l_voocnxseq_ant = 0
          
   whenever error continue

   select unique atdsrvnum from datmtrppsgaer
    where atdsrvnum = lr_param.atdsrvnum
      and atdsrvano = lr_param.atdsrvano

   if sqlca.sqlcode = notfound then
      let l_vooopc = 1
      let l_voocnxseq = 1
      return l_vooopc, l_voocnxseq
   end if

    select max(vooopc) into l_vooopc from datmtrppsgaer
     where atdsrvnum = lr_param.atdsrvnum
       and atdsrvano = lr_param.atdsrvano

    if lr_param.vooopc is null then ##incluindo nova opcao apos cotar 1a x.
       let l_vooopc = l_vooopc + 1   
       let l_voocnxseq= 1
       return l_vooopc, l_voocnxseq
    end if

    select max(voocnxseq) into l_voocnxseq from datmtrppsgaer
     where atdsrvnum = lr_param.atdsrvnum
       and atdsrvano = lr_param.atdsrvano
       and vooopc    = l_vooopc

    if lr_param.acao = 'Cotar' then
       let l_vooopc = l_vooopc + 1
       let l_voocnxseq = 1
       return l_vooopc, l_voocnxseq
    end if

    if lr_param.acao = 'Com conexão' then
       let l_voocnxseq = l_voocnxseq + 1

       #if l_voocnxseq = 4 then
       #   display "ERRO@@O limite de conexões foi excedido. Caso seja necess\341rio, por favor entrar em contato atrav\351s do telefone (11) 3366 3055@@" 
       #   exit program
       #end if

       return l_vooopc, l_voocnxseq

    end if

    if lr_param.acao = 'Cotar mais vôos' then
       let l_vooopc = l_vooopc + 1
       let l_voocnxseq = 1

       #if l_vooopc = 4 then
       #   display "ERRO@@O limite de opções de vôo foi excedido. Caso seja necess\341rio, por favor entrar em contato atrav\351s do telefone (11) 3366 3055@@" 
       #   exit program
       #end if
    end if

    if lr_param.acao = 'Enviar' then
       let l_vooopc = l_vooopc + 1
       let l_voocnxseq = 1
       return l_vooopc, l_voocnxseq
    end if

    return l_vooopc, l_voocnxseq

end function

function ctc11g00_obter_dados(lr_param)

   define lr_param      record
          nivel_retorno smallint,
          atdsrvnum     like datmservico.atdsrvnum,
          atdsrvano     like datmservico.atdsrvano
          end record

   define  l_vooopc       like datmtrppsgaer.vooopc,
           l_voocnxseq    like datmtrppsgaer.voocnxseq,
           l_trpaersaidat like datmtrppsgaer.trpaersaidat,
           l_trpaersaihor like datmtrppsgaer.trpaersaihor,
           l_trpaerchedat like datmtrppsgaer.trpaerchedat,
           l_trpaerchehor like datmtrppsgaer.trpaerchehor

   let l_vooopc       = null
   let l_voocnxseq    = null
   let l_trpaersaidat = null
   let l_trpaersaihor = null
   let l_trpaerchedat = null
   let l_trpaerchehor = null

   open cctc11g00005 using lr_param.atdsrvnum, lr_param.atdsrvano
   fetch cctc11g00005 into l_vooopc
   close cctc11g00005

   open cctc11g00006 using lr_param.atdsrvnum, lr_param.atdsrvano, l_vooopc
   fetch cctc11g00006 into l_voocnxseq
   close cctc11g00006
  
   open cctc11g00001 using lr_param.atdsrvnum, lr_param.atdsrvano, 
                           l_vooopc, l_voocnxseq

   fetch cctc11g00001 into l_trpaersaidat, l_trpaersaihor,
                           l_trpaerchedat, l_trpaerchehor
   close cctc11g00001

   if lr_param.nivel_retorno = 1 then
      return l_trpaersaidat, l_trpaersaihor, l_trpaerchedat, l_trpaerchehor     
   end if

end function
