#############################################################################
# Nome do Modulo: CTS17M01                                         Wagner   #
#                                                                           #
# Verifica outros de RET para servico origenal                     Ago/2002 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/09/2012  Raul Biztalking         Retirar empresa 1 fixa p/ funcionario #
#############################################################################

 database porto
 define m_cts17m01_prep smallint
#-----------------------------------------------#
 function cts17m01_prepara()
#-----------------------------------------------#
 define l_sql_stmt   char(800)
 let l_sql_stmt = "select datmservico.atddat    , ",
                        " datmservico.atdhor    , ",
                        " datmservico.atdsrvnum , ",
                        " datmservico.atdsrvano , ",
                        " datmservico.funmat    , ",
                        " datmservico.c24solnom , ",
                        " datmservico.atdsrvorg , ",
                  "       datmservico.empcod      ",                      #Raul, Biz
              "  from datmsrvre, datmservico  ",
              " where datmsrvre.atdorgsrvnum  = ? ",
              "   and datmsrvre.atdorgsrvano  = ? ",
              "   and datmservico.atdsrvnum   =  datmsrvre.atdsrvnum ",
              "   and datmservico.atdsrvano   =  datmsrvre.atdsrvano ",
              " order by atddat desc, atdhor asc"
 prepare p_cts17m01_001  from l_sql_stmt
 declare c_cts17m01_001 cursor for p_cts17m01_001
 let l_sql_stmt = "select atdetpcod    ",
              "  from datmsrvacp   ",
              " where atdsrvnum = ?",
              "   and atdsrvano = ?",
              "   and atdsrvseq = (select max(atdsrvseq)",
                                  "  from datmsrvacp    ",
                                  " where atdsrvnum = ? ",
                                  "   and atdsrvano = ?)"
 prepare p_cts17m01_002 from l_sql_stmt
 declare c_cts17m01_002 cursor for p_cts17m01_002
 let l_sql_stmt = "select grlinf ",
                   " from datkgeral ",
                  " where grlchv = ? "
 prepare p_cts17m01_003 from l_sql_stmt
 declare c_cts17m01_003 cursor for p_cts17m01_003
 let l_sql_stmt = "select atddatprg, ",
                        " atdlibdat ",
                   " from datmservico ",
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "
 prepare p_cts17m01_004 from l_sql_stmt
 declare c_cts17m01_004 cursor for p_cts17m01_004
 let l_sql_stmt = "select atddatprg, ",
                        " atdlibdat  ",
                   " from datmsrvre, datmservico ",
                  " where atdorgsrvnum = ? ",
                    " and atdorgsrvano = ? ",
                    " and srvretmtvcod = 1 ",
                    " and datmservico.atdsrvnum = datmsrvre.atdsrvnum ",
                    " and datmservico.atdsrvano = datmsrvre.atdsrvano ",
                  " order by atddatprg desc, atdlibdat desc "
 prepare p_cts17m01_005 from l_sql_stmt
 declare c_cts17m01_005 cursor for p_cts17m01_005
 let m_cts17m01_prep = true
end function

#-----------------------------------------------------------------------------
 function cts17m01(param)
#-----------------------------------------------------------------------------
 define param        record
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano
 end record

 define a_cts17m01   array[50]  of record
    atddat           like datmservico.atddat,
    atdhor           like datmservico.atdhor,
    atdsrvorg        like datmservico.atdsrvorg,
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    srvtipabvdes     like datksrvtip.srvtipabvdes,
    atendente        char (10),
    c24solnom        like datmservico.c24solnom
 end record

 define ws           record
    funmat           like datmservico.funmat,
    atdetpcod        like datmsrvacp.atdetpcod,
    sql              char (700),
    empcod           like datmservico.empcod                          #Raul, Biz
 end record

 define arr_aux      smallint


#------------------------------------------------------------------------
# Limpa campos / Monta comandos SQL
#------------------------------------------------------------------------


	define	w_pf1	integer

	let	arr_aux  =  null

	for	w_pf1  =  1  to  50
		initialize  a_cts17m01[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

 initialize a_cts17m01   to null
 initialize ws.*         to null

 let arr_aux = 1

 if param.atdsrvnum  is null   and
    param.atdsrvano  is null   then
    return  a_cts17m01[arr_aux].atdsrvnum,
            a_cts17m01[arr_aux].atdsrvano
 end if

 let int_flag  = false

 message " Aguarde, pesquisando..." attribute (reverse)



 if m_cts17m01_prep is null or m_cts17m01_prep <> true then
    call cts17m01_prepara()
 end if

 #------------------------------------------------------------------------
 # Ler servicos conforme parametros
 #------------------------------------------------------------------------

 set isolation to dirty read

 open c_cts17m01_001 using param.atdsrvnum, param.atdsrvano

 foreach c_cts17m01_001 into  a_cts17m01[arr_aux].atddat,
                          a_cts17m01[arr_aux].atdhor,
                          a_cts17m01[arr_aux].atdsrvnum,
                          a_cts17m01[arr_aux].atdsrvano,
                          ws.funmat,
                          a_cts17m01[arr_aux].c24solnom,
                          a_cts17m01[arr_aux].atdsrvorg,
                          ws.empcod                                   #Raul, Biz

    if a_cts17m01[arr_aux].atdsrvorg =  9   or
       a_cts17m01[arr_aux].atdsrvorg = 13   then
    else
       continue foreach
    end if

    open  c_cts17m01_002 using a_cts17m01[arr_aux].atdsrvnum,
                             a_cts17m01[arr_aux].atdsrvano,
                             a_cts17m01[arr_aux].atdsrvnum,
                             a_cts17m01[arr_aux].atdsrvano
    fetch c_cts17m01_002 into  ws.atdetpcod
       if ws.atdetpcod = 5  or    ### Servico CANCELADO
          ws.atdetpcod = 6  then  ### Servico EXCLUIDO
          continue foreach
       end if
    close c_cts17m01_002

    initialize a_cts17m01[arr_aux].srvtipabvdes  to null
    select srvtipabvdes
      into a_cts17m01[arr_aux].srvtipabvdes
      from datksrvtip
     where atdsrvorg = a_cts17m01[arr_aux].atdsrvorg

    initialize a_cts17m01[arr_aux].atendente  to null
    select funnom
      into a_cts17m01[arr_aux].atendente
      from isskfunc
     where empcod = ws.empcod                                         #Raul, Biz
       and funmat = ws.funmat

    let a_cts17m01[arr_aux].atendente = upshift(a_cts17m01[arr_aux].atendente)

    let arr_aux = arr_aux + 1
    if arr_aux  >  50   then
       error " Limite excedido, pesquisa com mais de 50 servicos solicitados!"
       exit foreach
    end if

 end foreach

 message ""

#------------------------------------------------------------------------
# Exibe servicos solicitados
#------------------------------------------------------------------------
 call set_count(arr_aux-1)

 if arr_aux  >  1   then
    open window w_cts17m01 at 10,05 with form "cts17m01"
         attribute(form line 1, border, message line last - 1)

    message " (F17)Abandona, (F8)Seleciona"

    display array a_cts17m01 to s_cts17m01.*

       on key (interrupt)
          initialize a_cts17m01   to null
          let arr_aux = 1
          exit display

       on key (F8)
          let arr_aux = arr_curr()
          exit display

    end display

    close window  w_cts17m01
 else
    error " Nao existe servicos anteriores para pesquisa!"
    initialize a_cts17m01   to null
 end if

 let int_flag = false

 set isolation to committed read

 return a_cts17m01[arr_aux].atdsrvnum,
        a_cts17m01[arr_aux].atdsrvano

end function  ###  cts17m01

#--------------------------------------------------------------
function cts17m01_valida_prazo_retorno(param)
#--------------------------------------------------------------
   define param record
      atdsrvnum    like datmservico.atdsrvnum,
      atdsrvano    like datmservico.atdsrvano,
      srvretmtvcod like datmsrvre.srvretmtvcod
   end record

   define lretorno  record
      noprazoflg   char(1),
      mensagem1    char(40),
      mensagem2    char(40)
   end record

   define ws record
      atddatprg like datmservico.atddatprg,
      atdlibdat like datmservico.atdlibdat,
      grlchv    like datkgeral.grlchv,
      grlinf    like datkgeral.grlinf,
      clidat    date,
      limdat    date,
      numdiaret integer
   end record

   if m_cts17m01_prep is null or m_cts17m01_prep <> true then
      call cts17m01_prepara()
   end if

   let lretorno.noprazoflg = 'S'
   let lretorno.mensagem1  = ''
   let lretorno.mensagem2  = ''

   case param.srvretmtvcod
      when 1 # COMPLEMENTO
         # Busca data combinada com o cliente do servico original
         open c_cts17m01_004 using param.atdsrvnum, param.atdsrvano
         whenever error continue
         fetch c_cts17m01_004 into ws.atddatprg, ws.atdlibdat
         whenever error stop
         close c_cts17m01_004

         if ws.atddatprg is not null then
            let ws.clidat = ws.atddatprg
         else
            let ws.clidat = ws.atdlibdat
         end if

         # Obter a quantidade de dias que o sistema permite abertura de retorno por complemento
         let ws.grlchv = 'PSOLIMCOMRET'
         open c_cts17m01_003 using ws.grlchv
         whenever error continue
         fetch c_cts17m01_003 into ws.numdiaret
         whenever error stop
         if sqlca.sqlcode <> 0 then
            let ws.numdiaret = 20 # Caso nao encontre ou erro, carrega padrao 20 dias
         end if
         close c_cts17m01_003

         # Calcula a data limite para abertura
         let ws.limdat = ws.clidat + ws.numdiaret units day

         if ws.limdat < today then
            let lretorno.noprazoflg = 'N'
            let lretorno.mensagem1  = 'PECAS - LIMITE DE ', ws.numdiaret using "<<#", ' DIAS EXCEDIDO'
            let lretorno.mensagem2  = 'SERVICO ORIGINAL CONCLUIDO EM ', ws.clidat
         else
            let lretorno.noprazoflg = 'S'
            let lretorno.mensagem1   = ''
            let lretorno.mensagem2   = ''
         end if

      when 2 # GARANTIA
         # Busca data combinada com o cliente do ultimo retorno por complemento
         open c_cts17m01_005 using param.atdsrvnum, param.atdsrvano
         whenever error continue
         fetch c_cts17m01_005 into ws.atddatprg, ws.atdlibdat
         whenever error stop

         if sqlca.sqlcode = 0 then
            if ws.atddatprg is not null then
               let ws.clidat = ws.atddatprg
            else
               let ws.clidat = ws.atdlibdat
            end if
         else
            open c_cts17m01_004 using param.atdsrvnum, param.atdsrvano
            whenever error continue
            fetch c_cts17m01_004 into ws.atddatprg, ws.atdlibdat
            whenever error stop
            close c_cts17m01_004
            if ws.atddatprg is not null then
               let ws.clidat = ws.atddatprg
            else
               let ws.clidat = ws.atdlibdat
            end if
         end if
         close c_cts17m01_005

         # Obter a quantidade de dias que o sistema permite abertura de retorno por garantia
         let ws.grlchv = 'PSOLIMGARRET'
         open c_cts17m01_003 using ws.grlchv
         whenever error continue
         fetch c_cts17m01_003 into ws.numdiaret
         whenever error stop
         if sqlca.sqlcode <> 0 then
            let ws.numdiaret = 90 # Caso nao encontre ou erro, carrega padrao 90 dias
         end if
         close c_cts17m01_003

         # Calcula a data limite para abertura
         let ws.limdat = ws.clidat + ws.numdiaret units day

         if ws.limdat < today then
            let lretorno.noprazoflg = 'N'
            let lretorno.mensagem1  = 'GARANTIA DE ', ws.numdiaret using "<<#", ' DIAS EXCEDIDA'
            let lretorno.mensagem2  = 'SERVICO CONCLUIDO EM ', ws.clidat
         else
            let lretorno.noprazoflg = 'S'
            let lretorno.mensagem1  = ''
            let lretorno.mensagem2  = ''
         end if

   end case

   return lretorno.noprazoflg,
          lretorno.mensagem1,
          lretorno.mensagem2

end function