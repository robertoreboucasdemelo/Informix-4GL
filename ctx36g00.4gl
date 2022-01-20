#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : CTX36G00                                                       #
# Programa   : Acerto do valor do serviço - SAPS                              #
#-----------------------------------------------------------------------------#
# Analista Resp. : Robert Lima - CDS                                          #
# PSI            : PSI-2012-22101PR                                           #
# Desenvolvedor  : Robert Lima - CDS                                          #
# DATA           : 07/12/2012                                                 #
#.............................................................................#
# Data        Autor      Alteracao                                            #
#                                                                             #
# ----------  ---------  -----------------------------------------------------#
#-----------------------------------------------------------------------------#

database porto

#----------------------------------------------
function ctx36g00_prepare()
#----------------------------------------------

 define l_sql    char(500)

 let l_sql = "SELECT atdsrvnum,     ",
             "       atdsrvano,     ",
             "       atdprscod      ",
             "  FROM datmservico    ",
             " WHERE atdsrvnum = ?  ",
             "   AND atdsrvano = ?  "
 prepare pctx36g00001 from l_sql
 declare cctx36g00001 cursor for pctx36g00001

 let l_sql = "SELECT prsokaflg      ",
             "  FROM dbsmsrvacr     ",
             " WHERE atdsrvnum = ?  ",
             "   AND atdsrvano = ?  "
 prepare pctx36g00002 from l_sql
 declare cctx36g00002 cursor for pctx36g00002

 let l_sql = "select socopgnum ",
              " from dbsmopgitm ",
             " where atdsrvnum = ? ",
               " and atdsrvano = ? "

  prepare pctx36g00003 from l_sql
  declare cctx36g00003 cursor for pctx36g00003

end function


#----------------------------------------------
function ctx36g00_acerto(l_ctx36g00)
#----------------------------------------------

 define l_ctx36g00 record
     atdsrvnum       like datmservico.atdsrvnum,
     atdsrvano       like datmservico.atdsrvano,
     vlracrct24      like dbsmsrvacr.incvlr
 end record

 define l_error record
     numerro smallint,
     menssagem char(100)
 end record

 define l_acerto record
     atdsrvnum       like datmservico.atdsrvnum,
     atdsrvano       like datmservico.atdsrvano,
     atdprscod       like datmservico.atdprscod,
     prsokaflg       like dbsmsrvacr.prsokaflg
 end record

 define l_pstacrptl smallint,
        l_socopgnum like dbsmopg.socopgnum

 initialize l_acerto.*, l_error.*, l_pstacrptl, l_socopgnum to null

 #display "Dentro da função"

 let l_error.numerro = 0
 let l_error.menssagem = "SUCESSO"

 #display "Antes do prepare"

 call ctx36g00_prepare()

 #display "Depois do prepare"

 #VALIDA SE O SERVIÇO É VÁLIDO
 whenever error continue

 #display "abrindo cursor cctx36g00001"


 open cctx36g00001 using l_ctx36g00.atdsrvnum,
                         l_ctx36g00.atdsrvano
 fetch cctx36g00001 into l_acerto.atdsrvnum,
                         l_acerto.atdsrvano,
                         l_acerto.atdprscod

 #display "fechando cursor cctx36g00001"

 if sqlca.sqlcode <> 0 then
    let l_error.numerro = sqlca.sqlcode

    if sqlca.sqlcode = notfound then
       let l_error.menssagem = "SERVICO NAO ENCONTRADO"
    else
       let l_error.menssagem = sqlca.sqlerrd[2]
    end if

    close cctx36g00001
    return l_error.numerro, l_error.menssagem
 end if

 close cctx36g00001

 whenever error stop

 #VALIDA SE VALOR É VALIDO
 if l_ctx36g00.vlracrct24<=0 then
    let l_error.numerro = 1
    let l_error.menssagem = "VALOR INVALIDO"
    return l_error.numerro, l_error.menssagem
 end if

 #VALIDA SE SERVIÇO JÁ FOI ACIONADO
 whenever error continue
 select distinct 1
   from datmsrvacp
  where atdsrvnum = l_ctx36g00.atdsrvnum
    and atdsrvano = l_ctx36g00.atdsrvano
    and atdetpcod in(3,4)

 #display "Depois de buscar a etapa"

 if sqlca.sqlcode <> 0 then

    let l_error.numerro = sqlca.sqlcode

    if sqlca.sqlcode = notfound then
       let l_error.menssagem = "SERVICO NAO ACIONADO"
    else
       let l_error.menssagem = sqlca.sqlerrd[2]
    end if

    return l_error.numerro, l_error.menssagem
 end if

 whenever error stop

 #VALIDA SE PRESTADOR ACERTA VALORES VIA PORTAL
 whenever error continue

 select 1
   from dpaksocor
  where pstcoddig = l_acerto.atdprscod
    and outciatxt like '%INTERNET%'

 #display "verificando se o prestador recebe pelo Portal"


 if  sqlca.sqlcode <> 0 then
     let l_pstacrptl = false
 else
     let l_pstacrptl = true
 end if

 # BURINI
 # BURINI    let l_error.numerro = sqlca.sqlcode
 # BURINI
 # BURINI    if sqlca.sqlcode = notfound then
 # BURINI       let l_error.menssagem = "PRESTADOR NÃO ACERTA VALORES VIA PORTAL"
 # BURINI    else
 # BURINI       let l_error.menssagem = sqlca.sqlerrd[2]
 # BURINI    end if
 # BURINI
 # BURINI    return l_error.numerro, l_error.menssagem
 # BURINI end if
 # BURINI
 # BURINI whenever error stop

 #display "abrindo cursor cctx36g00002"

 #VALIDA SE SERVIÇO JÁ ESTA NO ACERTO DE VALORES
 whenever error continue
 open cctx36g00002 using l_ctx36g00.atdsrvnum,
                         l_ctx36g00.atdsrvano
 fetch cctx36g00002 into l_acerto.prsokaflg

 #display "fechando cursor cctx36g00002"

 if sqlca.sqlcode <> 0 then
    let l_error.numerro = sqlca.sqlcode

    if sqlca.sqlcode <> notfound then
       let l_error.menssagem = sqlca.sqlerrd[2]
       close cctx36g00002
       return l_error.numerro, l_error.menssagem
    else
        #display "incluindo valor"
       call ctx36g00_incluir(l_ctx36g00.atdsrvnum, l_ctx36g00.atdsrvano, l_acerto.atdprscod, l_ctx36g00.vlracrct24)
            returning l_error.numerro, l_error.menssagem

       close cctx36g00002
       return l_error.numerro, l_error.menssagem
    end if
 end if

 close cctx36g00002
 whenever error stop

 if  l_pstacrptl then

     #VALIDA SE O SERVIÇO JÁ FOI ACERTADO E ENVIADO AO PORTO SOCORRO
     if l_acerto.prsokaflg = 'S' then
        let l_error.numerro = 0
        let l_error.menssagem = "SERVICO COM VALOR JA ACERTADO E ENVIADO A PORTO SEGURO"

        return l_error.numerro, l_error.menssagem
     end if

 else
     #display "abrindo cursor cctx36g00003"

     open cctx36g00003 using l_ctx36g00.atdsrvnum,
                             l_ctx36g00.atdsrvano
     fetch cctx36g00003 into l_socopgnum

     #display "fechando cursor cctx36g00003"

     if  l_socopgnum is not null and l_socopgnum <> " " then
         let l_error.numerro = 0
         let l_error.menssagem = "SERVICO JÁ VINCULADO A UMA OP."

         return l_error.numerro, l_error.menssagem
     end if
 end if

 #display "antes de alterar"

 call ctx36g00_alterar(l_ctx36g00.atdsrvnum, l_ctx36g00.atdsrvano, l_acerto.atdprscod, l_ctx36g00.vlracrct24)
     returning l_error.numerro, l_error.menssagem

 return l_error.numerro, l_error.menssagem

 #display "depois de alterar"

end function

#----------------------------------------------
function ctx36g00_incluir(l_ctx36g00)
#----------------------------------------------

 define l_ctx36g00 record
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     atdprscod    like datmservico.atdprscod,
     socopgitmvlr like dbsmopgitm.socopgitmvlr
 end record

 define l_error record
     numerro smallint,
     menssagem char(100)
 end record

 let l_error.numerro = 0
 let l_error.menssagem = "SUCESSO"

 let l_ctx36g00.socopgitmvlr = l_ctx36g00.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

 whenever error continue
        insert into dbsmsrvacr ( atdsrvnum,
                                 atdsrvano,
                                 caddat,
                                 cadhor,
                                 pstcoddig,
                                 prsokaflg,
                                 prsokadat,
                                 prsokahor,
                                 anlokaflg,
                                 anlokadat,
                                 anlokahor,
                                 autokaflg,
                                 autokadat,
                                 autokahor,
                                 socsrvvlracrsit,
                                 socsrvprbcod,
                                 incvlr,
                                 fnlvlr )
                        values ( l_ctx36g00.atdsrvnum,
                                 l_ctx36g00.atdsrvano,
                                 today,
                                 current,
                                 l_ctx36g00.atdprscod,
                                 "N",
                                 today,
                                 current,
                                 "N",
                                 today,
                                 current,
                                 "N",
                                 today,
                                 current,
                                 "A",
                                 0,
                                 l_ctx36g00.socopgitmvlr,
                                 0 )
 if sqlca.sqlcode <> 0 then
    let l_error.numerro = sqlca.sqlcode
    let l_error.menssagem = sqlca.sqlerrd[2]
 end if
 whenever error stop

 return l_error.numerro, l_error.menssagem

end function

#----------------------------------------------
function ctx36g00_alterar(l_ctx36g00)
#----------------------------------------------

 define l_ctx36g00 record
     atdsrvnum    like datmservico.atdsrvnum,
     atdsrvano    like datmservico.atdsrvano,
     atdprscod    like datmservico.atdprscod,
     socopgitmvlr like dbsmopgitm.socopgitmvlr
 end record

 define l_error record
     numerro smallint,
     menssagem char(100)
 end record

 let l_error.numerro = 0
 let l_error.menssagem = "SUCESSO"

 let l_ctx36g00.socopgitmvlr = l_ctx36g00.socopgitmvlr using "&&&&&&&&&&&&&&&.&&"

 whenever error continue

 update dbsmsrvacr set incvlr = l_ctx36g00.socopgitmvlr
  where atdsrvnum = l_ctx36g00.atdsrvnum
    and atdsrvano = l_ctx36g00.atdsrvano

  if sqlca.sqlcode <> 0 then
    let l_error.numerro = sqlca.sqlcode
    let l_error.menssagem = sqlca.sqlerrd[2]
 end if

 whenever error stop

 return l_error.numerro, l_error.menssagem
end function