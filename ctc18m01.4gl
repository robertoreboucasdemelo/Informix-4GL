#############################################################################
# Nome do Modulo: CTC18M01                                         Marcelo  #
#                                                                  Gilberto #
# Manutencao das clausulas atendidas por loja                      Nov/1998 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 20/10/1999               Gilberto     Alterar acesso ao cadastro de clau- #
#                                       sulas (ramo 31).                    #
#---------------------------------------------------------------------------#
# 08/05/2003               Aguinaldo    Adaptacao Resolucao 86              #
#---------------------------------------------------------------------------#
# 04/01/2007  PSI 205206   Lucas Scheid Possibilitar o cadastramento das    #
#                                       clausulas da Azul Seguros.          #
#---------------------------------------------------------------------------#
# 06/08/2008  PSI226300    Diomar, Meta Incluido gravacao do historico      #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

  define m_ctc18m01_prep smallint

#-------------------------#
function ctc18m01_prepare()
#-------------------------#

  define l_sql char(300)

  let l_sql = " select ramcod, ",
                     " clscod ",
                " from datrclauslocal ",
               " where lcvcod = ? ",
                 " and aviestcod = ? ",
               " order by 1, 2 "

  prepare pctc18m01001 from l_sql
  declare cctc18m01001 cursor for pctc18m01001

  let l_sql = " select clsdes ",
                " from aackcls ",
               " where tabnum = ? ",
                 " and ramcod = ? ",
                 " and clscod = ? "

  prepare pctc18m01002 from l_sql
  declare cctc18m01002 cursor for pctc18m01002

  let l_sql = " select grlinf[01,10] ",
                " from datkgeral ",
               " where grlchv = 'ct24resolucao86' "

  prepare pctc18m01003 from l_sql
  declare cctc18m01003 cursor for pctc18m01003

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "

  prepare pctc18m01004 from l_sql
  declare cctc18m01004 cursor for pctc18m01004

  let l_sql = " select 1 ",
                " from datrclauslocal ",
               " where lcvcod = ? ",
                 " and aviestcod = ? ",
                 " and ramcod = ? ",
                 " and clscod = ? "

  prepare pctc18m01005 from l_sql
  declare cctc18m01005 cursor for pctc18m01005

  let l_sql = " delete from datrclauslocal ",
                    " where lcvcod = ? ",
                      " and aviestcod = ? ",
                      " and ramcod = ? ",
                      " and clscod = ? "

  prepare pctc18m01006 from l_sql

  let l_sql = " update datkavislocal ",
                 " set(atldat,atlemp,atlmat)=(today, ?, ?) ",
               " where lcvcod = ? ",
                 " and aviestcod = ? "

  prepare pctc18m01007 from l_sql

  let l_sql = " insert into datrclauslocal ",
                         " (lcvcod, aviestcod, ramcod, clscod) ",
                  " values (?,?,?,?) "

  prepare pctc18m01008 from l_sql

  let m_ctc18m01_prep = true

end function

#----------------------#
function ctc18m01(param)
#----------------------#

 define param      record
    lcvcod         like datrclauslocal.lcvcod,
    aviestcod      like datrclauslocal.aviestcod
 end record

 define a_ctc18m01 array[100] of record
    ramcod         like datrclauslocal.ramcod,
    clscod         like datrclauslocal.clscod,
    clsdes         like aackcls.clsdes
 end record

 define arr_aux    smallint
 define scr_aux    smallint

 define ws         record
    tabnum         like itatvig.tabnum,
    clscod         like datrclauslocal.clscod,
    operacao       char (01)
 end record

 define l_dtres86    date
       ,l_mensagem   char(100)
       ,l_mensagem2  char(3000)
       ,l_aux        char(10)
       ,l_stt        smallint       
       
 if m_ctc18m01_prep is null or
    m_ctc18m01_prep <> true then
    call ctc18m01_prepare()
 end if

 let int_flag    = false
 let l_mensagem  = null
 let l_mensagem2 = null
 let l_aux       = null
 let l_stt       = null
 
 initialize ws.* to null

 for scr_aux = 1 to 100
    let a_ctc18m01[scr_aux].ramcod = null
    let a_ctc18m01[scr_aux].clscod = null
    let a_ctc18m01[scr_aux].clsdes = null
 end for

 let l_dtres86 = null
 let arr_aux   = null
 let scr_aux   = null

 let ws.tabnum = f_fungeral_tabnum("aackcls", today)

 # -> VERIFICA VIGENCIA DA RESOLUCAO 86
 open cctc18m01003
 fetch cctc18m01003 into l_dtres86
 close cctc18m01003

 open window ctc18m01 at 10,24 with form "ctc18m01"
    attribute (form line first, border)

 while not int_flag

    let arr_aux = 1
    let scr_aux = null

    # -> BUSCA O CODIGO DAS CLAUSULAS NA TABELA datrclauslocal
    open cctc18m01001 using param.lcvcod,
                            param.aviestcod
    foreach cctc18m01001 into a_ctc18m01[arr_aux].ramcod,
                              a_ctc18m01[arr_aux].clscod

       # -> BUSCA A DESCRICAO DA CLAUSULA
       let a_ctc18m01[arr_aux].clsdes = ctc18m01_dsc_claus(ws.tabnum,
                                          a_ctc18m01[arr_aux].ramcod,
                                          a_ctc18m01[arr_aux].clscod)
       let arr_aux = arr_aux + 1

       if arr_aux > 100 then
          error " Limite de consulta excedido. AVISE A INFORMATICA!" sleep 3
          exit foreach
       end if

    end foreach
    close cctc18m01001

    call set_count(arr_aux - 1)

    input array a_ctc18m01 without defaults from s_ctc18m01.*

    before row
       let arr_aux = arr_curr()
       let scr_aux = scr_line()

       if arr_aux <= arr_count() then
          let ws.operacao = "a"
          let ws.clscod = a_ctc18m01[arr_aux].clscod
       end if

    before insert
       let ws.operacao = "i"
       initialize a_ctc18m01[arr_aux].* to null

    before field ramcod
       if l_dtres86 <= today then
          let a_ctc18m01[arr_aux].ramcod = 531
       else
          let a_ctc18m01[arr_aux].ramcod = 31
       end if
       display a_ctc18m01[arr_aux].ramcod to
               s_ctc18m01[scr_aux].ramcod
       next field clscod

    before field clscod
       if ws.operacao = "a"  then
          display a_ctc18m01[arr_aux].ramcod  to
                  s_ctc18m01[scr_aux].ramcod  attribute (reverse)
          display a_ctc18m01[arr_aux].clscod  to
                  s_ctc18m01[scr_aux].clscod  attribute (reverse)
          display a_ctc18m01[arr_aux].clsdes  to
                  s_ctc18m01[scr_aux].clsdes  attribute (reverse)
       else
          display a_ctc18m01[arr_aux].clscod to
                  s_ctc18m01[scr_aux].clscod attribute (reverse)
       end if

    after field clscod
       display a_ctc18m01[arr_aux].clscod to
               s_ctc18m01[scr_aux].clscod

       if a_ctc18m01[arr_aux].clscod is null  then
          error " Clausula deve ser informada!"
          next field clscod
       end if

       if ws.operacao = "a"  then
          if ws.clscod <> a_ctc18m01[arr_aux].clscod  then
             error " Clausula nao pode ser alterada!"
             let a_ctc18m01[arr_aux].clscod = ws.clscod
             next field clscod
          end if
          display a_ctc18m01[arr_aux].ramcod  to
                  s_ctc18m01[scr_aux].ramcod
          display a_ctc18m01[arr_aux].clscod  to
                  s_ctc18m01[scr_aux].clscod
          display a_ctc18m01[arr_aux].clsdes  to
                  s_ctc18m01[scr_aux].clsdes
       end if

       # -> BUSCA A DESCRICAO DA CLAUSULA
       let a_ctc18m01[arr_aux].clsdes = ctc18m01_dsc_claus(ws.tabnum,
                                          a_ctc18m01[arr_aux].ramcod,
                                          a_ctc18m01[arr_aux].clscod)

       if a_ctc18m01[arr_aux].clsdes is null then
          error " Clausula nao cadastrada!"
          next field clscod
       end if

       if ws.operacao = "i"  then
          open cctc18m01005 using param.lcvcod,
                                  param.aviestcod,
                                  a_ctc18m01[arr_aux].ramcod,
                                  a_ctc18m01[arr_aux].clscod
          fetch cctc18m01005

          if sqlca.sqlcode = 0  then
             error " Clausula ja cadastrada para atendimento por esta loja!"
             close cctc18m01005
             next field clscod
          end if

          close cctc18m01005

       end if

       before delete
          let ws.operacao = "d"

          if a_ctc18m01[arr_aux].clscod is null   then
             continue input
          else
             if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
                exit input
             end if

             begin work

             whenever error continue
             execute pctc18m01006 using param.lcvcod,
                                        param.aviestcod,
                                        a_ctc18m01[arr_aux].ramcod,
                                        a_ctc18m01[arr_aux].clscod
             whenever error stop

             if sqlca.sqlcode <> 0  then
                rollback work
                error " Erro (", sqlca.sqlcode, ") na exclusao ",
                      "da clausula. AVISE A INFORMATICA! " sleep 3
                let int_flag = true
                exit input
             end if
             
             let l_mensagem  = "Excluida clausulas atendidas por loja [",
                 a_ctc18m01[arr_aux].ramcod,"|",a_ctc18m01[arr_aux].clscod,"] !"
             let l_aux = param.lcvcod using '<<<<<' ,"|",param.aviestcod using '<<<<'    
             let l_mensagem2 = "Delecao no cadastro de clausulas atendidas por loja. " clipped,
                 " Locadora/Loja : " clipped,param.lcvcod clipped,"-",param.aviestcod clipped
                                                 
             let l_stt = ctc18m01_grava_hist(l_aux                                                             
                                            ,l_mensagem2                                                        
                                            ,today                                                            
                                            ,l_mensagem)                                                      

             whenever error continue
             execute pctc18m01007 using g_issk.empcod,
                                        g_issk.funmat,
                                        param.lcvcod,
                                        param.aviestcod
             whenever error stop

             if sqlca.sqlcode <> 0  then
                rollback work
                error " Erro (", sqlca.sqlcode, ") na atualizacao ",
                      "da loja. AVISE A INFORMATICA!" sleep 3
                let int_flag = true
                exit input
             end if

             commit work

             initialize a_ctc18m01[arr_aux].* to null
             display a_ctc18m01[arr_aux].*    to s_ctc18m01[scr_aux].*

          end if

    on key (f17,control-c,interrupt)
       exit input

    after row
       if a_ctc18m01[arr_aux].ramcod is null  or
          a_ctc18m01[arr_aux].clscod is null  then
          error " Todos os dados devem ser informados!"
          initialize a_ctc18m01[arr_aux].* to null
          display a_ctc18m01[arr_aux].*    to s_ctc18m01[scr_aux].*
          next field ramcod
       end if

       if ws.operacao = "i"  then

          begin work

          whenever error continue
          execute pctc18m01008 using param.lcvcod,
                                     param.aviestcod,
                                     a_ctc18m01[arr_aux].ramcod,
                                     a_ctc18m01[arr_aux].clscod
          whenever error stop

          if sqlca.sqlcode <> 0 then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na inclusao ",
                   "da clausula para atendimento. AVISE A INFORMATICA!" sleep 3
             let int_flag = true
             exit input
          end if
          
          let l_mensagem  = "Incluida clausulas atendidas por loja [",a_ctc18m01[arr_aux].ramcod,"|",
                             a_ctc18m01[arr_aux].clscod,"] !"
          let l_mensagem2 = "Inclusao no cadastro de clausulas atendidas por loja ",
             " Locadora/Loja : " clipped,param.lcvcod clipped,"-",param.aviestcod clipped
          let l_aux = param.lcvcod using '<<<<<' ,"|",param.aviestcod using '<<<<'
          let l_stt = ctc18m01_grava_hist(l_aux
                                         ,l_mensagem2
                                         ,today
                                         ,l_mensagem)
          
          whenever error continue
          execute pctc18m01007 using g_issk.empcod,
                                     g_issk.funmat,
                                     param.lcvcod,
                                     param.aviestcod
          whenever error stop

          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na atualizacao ",
                   "da loja. AVISE A INFORMATICA!" sleep 3
             let int_flag = true
             exit input
          end if

          commit work

          display a_ctc18m01[arr_aux].* to s_ctc18m01[scr_aux].*
       end if

       let ws.operacao = " "
    end input

    if int_flag  then
       exit while
    end if

 end while

 close window ctc18m01
 let int_flag = false

end function

#---------------------------------------#
function ctc18m01_dsc_claus(lr_parametro)
#---------------------------------------#

  define lr_parametro record
         tabnum       like aackcls.tabnum,
         ramcod       like aackcls.ramcod,
         clscod       like aackcls.clscod
  end record

  define l_clsdes     like aackcls.clsdes,
         l_grlchv     like datkgeral.grlchv

  # -> INICIALIZACAO DAS VARIAVEIS
  let l_clsdes = null
  let l_grlchv = null

  # -> BUSCA A DESCRICAO DA CLAUSULA NA BASE DA PORTO (aackcls)
  open cctc18m01002 using lr_parametro.tabnum,
                          lr_parametro.ramcod,
                          lr_parametro.clscod
  fetch cctc18m01002 into l_clsdes

  if sqlca.sqlcode = notfound then
     # -> BUSCA A DESCRICAO DA CLAUSULA NA BASE DA AZUL (datkgeral)

     # -> MONTA A CHAVE DE PESQUISA
     let l_grlchv = null
     let l_grlchv = "CLS.AZUL.", lr_parametro.clscod

     open cctc18m01004 using l_grlchv
     fetch cctc18m01004 into l_clsdes

     if sqlca.sqlcode = notfound then
        let l_clsdes = null
     end if
     close cctc18m01004

  end if

  close cctc18m01002

  return l_clsdes

end function

#------------------------------------------------
function ctc18m01_grava_hist(lr_param,l_mensagem)
#------------------------------------------------

   define lr_param record
          codigo     char(10)
         ,mensagem   char(100)
         ,data       date
          end record

   define lr_retorno record
          stt       smallint         
         ,msg       char(50)
          end record

   define l_mensagem  char(3000)
         ,l_stt       smallint
         ,l_erro      smallint
         ,l_path      char(100)

   let l_stt  = true
   let l_path = null

   initialize lr_retorno to null

   call ctb85g01_grava_hist(3
                           ,lr_param.codigo
                           ,l_mensagem
                           ,lr_param.data
                           ,g_issk.empcod
                           ,g_issk.funmat
                           ,g_issk.usrtip)
      returning lr_retorno.stt
               ,lr_retorno.msg

   if lr_retorno.stt = 0 then

        call ctb85g01_mtcorpo_email_html('CTC18M00',
		                         lr_param.data,
		                         current hour to minute,
		                         g_issk.empcod,
		                         g_issk.usrtip,
		                         g_issk.funmat,
		                         lr_param.mensagem,     
		                         l_mensagem)
		returning l_erro

      if l_erro  <> 0 then
         error 'Erro no envio do e-mail' sleep 2
         let l_stt = false
      else
         let l_stt = true
      end if
      
   else
      error 'Erro na gravacao do historico' sleep 2
      let l_stt = false
   end if

   return l_stt

end function

