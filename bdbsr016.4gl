###############################################################################
# Nome do Modulo: bdbsr016                                           Wagner   #
# Lista reclamacoes                                                  Set/2002 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
# ---------- ----------------- ---------- ------------------------------------#
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 28/06/2004 Bruno Gama, Meta  PSI185035  Padronizar o processamento Batch    #
#                              OSF036870  do Porto Socorro.                   #
#.............................................................................#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 JUNIOR (Meta)      Melhorias incluida funcao fun_dba_abre_banco. #
# ---------- --------------------- ------ ------------------------------------#
# 05/10/2006 Priscila              202720 implementar cartao saude            #
# ---------- --------------------- ------ ------------------------------------#
# 14/02/2007 Fabiano, Meta      AS 130087 Migracao para a versao 7.32         #
#                                                                             #
# 03/02/2016              ElianeK,Fornax  Retirada da var global g_ismqconn   #
###############################################################################

database porto

define m_path   char(100)

main

  let m_path = f_path("DBS","LOG")
  if m_path is null then
     let m_path = "."
  end if
  let m_path = m_path clipped,"/bdbsr016.log"

  call startlog(m_path)

  call fun_dba_abre_banco("CT24HS")
  call bdbsr016()
end main

#--------------------------------------------------------------------
 function bdbsr016()
#--------------------------------------------------------------------

 define ws           record
    c24astcod        like datmligacao.c24astcod   ,
    c24astdes        char (50)                    ,
    succod           like datrligapol.succod      ,
    ramcod           like datrligapol.ramcod      ,
    aplnumdig        like datrligapol.aplnumdig   ,
    itmnumdig        like datrligapol.itmnumdig   ,
    crtnum           like datksegsau.crtsaunum    ,          #PSI 202720
    atdsrvorg        like datmservico.atdsrvorg   ,
    atdsrvnum        like datmservico.atdsrvnum   ,
    atdsrvano        like datmservico.atdsrvano   ,
    pstcoddig        like datmsrvacp.pstcoddig,
    nomepst          char (50),
    srrcoddig        like datmsrvacp.srrcoddig,
    nomesoc          char (50),
    rclrlzdat        like datmsitrecl.rclrlzdat   ,
    rclrlzdat_a      like datmsitrecl.rclrlzdat   ,
    c24rclsitcod     like datmsitrecl.c24rclsitcod,
    rclsitdes        char (20)                    ,
    lignum           like datmligacao.lignum      ,
    rodar            char (400)                   ,
    argparam         char(10)                     ,
    datparam         date                         ,
    datini           date                         ,
    datter           date
 end record

 define sql_comando  char (900)

 define l_comando   char(30)
 define l_retorno   smallint
 define l_mensagem    char(80)                                #PSI 202720
 define l_tpdocto     char(15)                                #PSI 202720

 let l_mensagem = null                                    #PSI 202720
 let l_tpdocto = null                                     #PSI 202720

#--------------------------------------------------------------------
# Cursor para obtencao da ultima situacao da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select c24rclsitcod,",
                   "       rclrlzdat    ",
                   "  from datmsitrecl  ",
                   " where lignum = ?   ",
                   "   and c24rclsitcod = (select max(c24rclsitcod)",
                                          "  from datmsitrecl",
                                          " where lignum = ?)"
 prepare select_sitrecl from sql_comando
 declare c_bdbsr016_sitrecl cursor with hold for select_sitrecl

#--------------------------------------------------------------------
# Cursor para obtencao dos dados adicionais da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select datmligacao.c24astcod, ",
                   "       datmreclam.atdsrvnum , ",
                   "       datmreclam.atdsrvano   ",
                   "  from datmligacao, datmreclam",
                   " where datmligacao.lignum = ? ",
                   "   and datmreclam.lignum = datmligacao.lignum"
 prepare select_ligrecl from sql_comando
 declare c_bdbsr016_ligrecl cursor with hold for select_ligrecl

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do assunto da reclamacao
#--------------------------------------------------------------------
 let sql_comando = "select c24astdes from datkassunto",
                   " where c24astcod = ? "
 prepare select_assunto from sql_comando
 declare c_bdbsr016_assunto cursor with hold for select_assunto

#--------------------------------------------------------------------
# Cursor para obtencao da descricao do codigo de situacao
#--------------------------------------------------------------------
 let sql_comando = "select cpodes from iddkdominio",
                   " where cponom = 'c24rclsitcod'",
                   "   and cpocod = ?"
 prepare select_dominio from sql_comando
 declare c_bdbsr016_dominio cursor with hold for select_dominio

#--------------------------------------------------------------------
# Cursor para obtencao da apolice do reclamante
#--------------------------------------------------------------------
 let sql_comando = "select succod   , ",
                   "       ramcod   , ",
                   "       aplnumdig, ",
                   "       itmnumdig  ",
                   "  from datrligapol",
                   " where lignum = ? "
 prepare select_ligapol from sql_comando
 declare c_bdbsr016_ligapol cursor with hold for select_ligapol

#--------------------------------------------------------------------
# Inicializacao das variaveis
#--------------------------------------------------------------------
 initialize ws.*          to null

 create temp table tbtemp
    ( c24astcod     char (04),
      c24astdes     char (50),
      succod        decimal(4,0),
      ramcod        decimal(4,0),
      aplnumdig     decimal(10,0),
      itmnumdig     decimal(9,0),
      crtnum        char(18),        #PSI 202720
      atdsrvorg     smallint,
      atdsrvnum     decimal (10,0),
      atdsrvano     decimal (3,0),
      pstcoddig     decimal (8,0),
      nomepst       char (50),
      srrcoddig     decimal (5,0),
      nomesoc       char (50),
      rclrlzdat     date,
      rclrlzdat_a   date,
      c24rclsitcod  integer,
      rclsitdes     char(20)) with no log

# Carrega parametros
let ws.argparam = arg_val(1)
if ws.argparam = "          " then
   let ws.argparam = TODAY
end if
let ws.argparam = "01/",  ws.argparam[4,10]
let ws.datini = ws.argparam
let ws.datini = ws.datini - 1 units month
let ws.datter = ws.datini + 1 units month - 1 units day

 declare c_bdbsr016 cursor for
  select lignum, rclrlzdat
    from datmsitrecl
   where rclrlzdat between ws.datini and ws.datter
     and c24rclsitcod = 0
   order by lignum

 foreach c_bdbsr016  into ws.lignum , ws.rclrlzdat

    #-----------------------------
    # servico/assunto
    #-----------------------------
    open  c_bdbsr016_ligrecl  using  ws.lignum
    fetch c_bdbsr016_ligrecl  into   ws.c24astcod,
                                     ws.atdsrvnum,
                                     ws.atdsrvano
    close c_bdbsr016_ligrecl

    if ws.c24astcod[1,3] <> "W02"  and
       ws.c24astcod[1,3] <> "W04"  and
       ws.c24astcod[1,3] <> "W05"  and
       ws.c24astcod[1,3] <> "W06"  and
       ws.c24astcod[1,3] <> "W08"  and
       ws.c24astcod[1,3] <> "W14"  and
       ws.c24astcod[1,3] <> "W15"  then
       continue foreach
    end if

    #-----------------------------
    # descricao do assunto
    #-----------------------------
    open  c_bdbsr016_assunto  using  ws.c24astcod
    fetch c_bdbsr016_assunto  into   ws.c24astdes
    close c_bdbsr016_assunto

    if ws.atdsrvnum is not null then
       #-----------------------------
       # Origem do srv
       #-----------------------------
       select atdsrvorg
         into ws.atdsrvorg
         from datmservico
        where datmservico.atdsrvnum = ws.atdsrvnum
          and datmservico.atdsrvano = ws.atdsrvano

       #-----------------------------
       # prestador/motorista
       #-----------------------------
       declare c_pst cursor for
        select pstcoddig, srrcoddig
          from datmsrvacp
         where atdsrvnum = ws.atdsrvnum
           and atdsrvano = ws.atdsrvano
           and atdetpcod  in (3,4)
           and pstcoddig is not null

        foreach c_pst into ws.pstcoddig, ws.srrcoddig
           exit foreach
        end foreach
    else
       initialize ws.atdsrvnum, ws.atdsrvano,
                  ws.atdsrvorg, ws.pstcoddig,
                  ws.srrcoddig      to null
    end if

    #-----------------------------
    # Ultima situacao
    #-----------------------------
    open  c_bdbsr016_sitrecl using ws.lignum, ws.lignum
    fetch c_bdbsr016_sitrecl into  ws.c24rclsitcod, ws.rclrlzdat_a
    close c_bdbsr016_sitrecl

    #-----------------------------
    # descricao do situacao
    #-----------------------------
    open  c_bdbsr016_dominio  using  ws.c24rclsitcod
    fetch c_bdbsr016_dominio  into   ws.rclsitdes
    close c_bdbsr016_dominio

    #PSI 202720 - inicio
    #-----------------------------
    # apolice
    #-----------------------------
    #open  c_bdbsr016_ligapol using  ws.lignum
    #fetch c_bdbsr016_ligapol  into  ws.succod,   ws.ramcod,
    #                                ws.aplnumdig,ws.itmnumdig
    #close c_bdbsr016_ligapol
    #-----------------------------
    # Buscar tipo documento
    #-----------------------------
    call cts20g11_identifica_tpdocto(ws.atdsrvnum,
                                     ws.atdsrvano)
         returning l_tpdocto
    if l_tpdocto = "APOLICE" then
       #se documento e apolice - pode ser apolice AUTO ou RE
       # entao buscar ramo na tabela de apolices
       call cts20g13_obter_apolice(ws.atdsrvnum,
                                   ws.atdsrvano)
            returning l_retorno,
                      l_mensagem,
                      ws.aplnumdig,
                      ws.succod,
                      ws.ramcod,
                      ws.itmnumdig
       if l_retorno <> 1 then
          #erro ao obter apolice auto ou RE
          continue foreach
       end if
    else
       if l_tpdocto = "SAUDE" then
          #se documento saude - é do cartao saude, entao buscar dados na
          # tabela de apolices do saude
          call cts20g10_cartao(2,
                               ws.atdsrvnum,
                               ws.atdsrvano)
               returning l_retorno,
                         l_mensagem,
                         ws.succod,
                         ws.ramcod,
                         ws.aplnumdig,
                         ws.crtnum
          if l_retorno <> 1 then
             #erro ao obter apolice do saude
             continue foreach
          end if
       end if
    end if
    #PSI 202720 - fim

    #-----------------------------
    # Nome prestador + nome socorrista
    #-----------------------------
    select nomrazsoc into ws.nomepst
      from dpaksocor
     where pstcoddig = ws.pstcoddig

    select srrnom into ws.nomesoc
      from datksrr
     where srrcoddig = ws.srrcoddig

    insert into tbtemp values ( ws.c24astcod,
                                ws.c24astdes,
                                ws.succod,
                                ws.ramcod,
                                ws.aplnumdig,
                                ws.itmnumdig,
                                ws.crtnum,          #PSI 202720
                                ws.atdsrvorg,
                                ws.atdsrvnum,
                                ws.atdsrvano,
                                ws.pstcoddig,
                                ws.nomepst,
                                ws.srrcoddig,
                                ws.nomesoc,
                                ws.rclrlzdat,
                                ws.rclrlzdat_a,
                                ws.c24rclsitcod,
                                ws.rclsitdes)
 end foreach

 let m_path = f_path("DBS","ARQUIVO")
 if m_path is null then
    let m_path = "."
 end if

 let m_path = m_path clipped,"/recllist.txt"

 unload to m_path select * from tbtemp

 #------------------------------------------------------------------
 # E-MAIL PORTO SOCORRO
 #------------------------------------------------------------------
 #let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
 #              " -s 'Reclamacoes_mes' ",
 #              "raji_jahchan/spaulo_info_sistemas@u55 < /adat/recllist.txt"
 #run ws.rodar
 #
 #let ws.rodar =  "mailx -r 'Socorro_Porto/spaulo_psocorro_controles@u23'",
 #              " -s 'Reclamacoes_mes' ",
 #              "ponso_wilson/spaulo_psocorro_controles@u23 < /adat/recllist.txt"
 #run ws.rodar

  let l_comando = "Reclamacoes_mes"
  let l_retorno = ctx22g00_envia_email("BDBSR016",
                                        l_comando,
                                        m_path)
  if l_retorno <> 0 then
     if l_retorno <> 99 then
        display "Erro ao enviar email(ctx22g00)-",m_path
     else
        display "Nao foi encontrado email para o modulo BDBSR016 "
     end if
  end if


end function
