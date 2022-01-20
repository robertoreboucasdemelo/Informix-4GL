###############################################################################
# Nome do Modulo: ctc21m00                                           Almeida  #
#                                                                             #
# cadastro dos procedimentos a serem tomados pelos atendentes        jan/1999 #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 19/07/1999  PSI 8533-2   Wagner       Incluir checagem das mensagens para   #
#                                       Cidade e UF.                          #
#-----------------------------------------------------------------------------#
# 20/10/1999               Gilberto     Alterar acesso ao cadastro de clausu- #
#                                       las (ramo 31).                        #
#-----------------------------------------------------------------------------#
# 09/01/2002               Raji         Alterar acesso ao cadastro de clausu- #
#                                       las para todos os ramos               #
#-=---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86                 #
#-----------------------------------------------------------------------------#
# 01/02/2005  CT 284947    Katiucia     Alterar acesso ao cadastro localizacao#
#-----------------------------------------------------------------------------#
# 03/03/2011             META, Helder  Incluir controle de Popoup para escolha#
#                                      da empresa, juntamente ao Procedimento #
#-----------------------------------------------------------------------------#
#                                                                             #
###############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_sql        char(1)
define m_data       date
define m_arr_count  smallint

define la_ctc21m00a array[500] of record 
    marca    char(1)
   ,empcod   like gabkemp.empcod
   ,empnom   like gabkemp.empnom
end record

define am_retorno array[500] of record
    empcod   like gabkemp.empcod 
end record 

define l_1 char(100)
define l_2 char(100)

#-------------------------------------------------------------------------------
 function ctc21m00_prepare()
#-------------------------------------------------------------------------------
define l_sql char(5000)


 let l_sql = ' select empcod, empnom   '
           , '   from gabkemp          '
           , '  order by empcod        '
 prepare p_ctc21m00_001 from l_sql
 declare c_ctc21m00_001 cursor for p_ctc21m00_001
 
let l_sql = ' insert into datrprcemp '
          , '  (prtcpointcod,empcod )' 
          , ' values ( ?,? )'
 
 prepare p_ctc21m00_002 from l_sql
 
let l_sql = ' select first 1 count(prtcpointcod)    '
          , '   from datrprcemp                     '
          , '  where prtcpointcod = ?               '
          , '    and empcod       = ?               '
 prepare p_ctc21m00_003 from l_sql
 declare c_ctc21m00_003 cursor for p_ctc21m00_003

let m_sql = 'S'

end function

#-------------------------------------------------------------------------------
 function ctc21m00()
#-------------------------------------------------------------------------------


 define d_ctc21m00   record
    viginc           date,
    viginchor        datetime hour to minute,
    vigfnl           date,
    vigfnlhor        datetime hour to minute
 end record

 define a_ctc21m00   array[50] of record
    prtcpointcod     like datmprtprc.prtcpointcod,
    prtcponom        like dattprt.prtcponom,
    sinal            char(02),
    prtprccntdes     like datmprtprc.prtprccntdes,
    prtcpointnom     like dattprt.prtcpointnom
 end record

 define ws           record
    tabnum           like itatvig.tabnum,
    prtprcnum        like datmprtprc.prtprcnum,
    viginchordat     like datmprtprc.viginchordat,
    vigfnlhordat     like datmprtprc.vigfnlhordat,
    prtprcexcflg     like datmprtprc.prtprcexcflg,
    horaatu          char(05),
    data1            char(10),
    data2            char(16),
    acao             char(01),
    count            integer,
    confirma         char(01),
    cabtxt           char(18)
 end record

 define arr_aux        integer
 define scr_aux        integer
 define ws_conta       integer
 define l_ret          smallint
 define l_idx          smallint
 
 define l_ctt     smallint
       ,l_numeric smallint
       ,l_alfa    smallint
  
define l_empcod       like dbsmopg.empcod
define l_empnom       like gabkemp.empnom
define l_aux_count    smallint
 
  let l_aux_count = 0
  let m_data = today
  let l_ctt     = 1
  let l_numeric = false 
  let l_alfa    = false
  let m_sql = 'N'

  if m_sql = 'N' then
     call ctc21m00_prepare()
  end if

 open window w_ctc21m00 at 6,2 with form "ctc21m00"
      attribute (form line 1)

 let int_flag  =  false
 let arr_aux   =  1

 while not int_flag

    initialize ws.*          to null
    initialize a_ctc21m00    to null
    initialize d_ctc21m00.*  to null
    clear form

    input by name  d_ctc21m00.viginc,
                   d_ctc21m00.viginchor,
                   d_ctc21m00.vigfnl,
                   d_ctc21m00.vigfnlhor  without defaults

    before field viginc
       display by name d_ctc21m00.viginc attribute (reverse)

    after  field viginc
       display by name d_ctc21m00.viginc

       if d_ctc21m00.viginc is null   then
          error " Data inicio de vigencia deve ser informada!"
          next field viginc
       end if

       if d_ctc21m00.viginc  <  today   then
          error " Data inicio de vigencia nao deve ser anterior data atual!"
          next field viginc
       end if

    before field viginchor
       display by name d_ctc21m00.viginchor attribute (reverse)

    after  field viginchor
       display by name d_ctc21m00.viginchor

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field viginc
       end if

       if d_ctc21m00.viginchor is null then
          error " Hora inicio de vigencia deve ser informado!"
          next field viginchor
       end if

       if d_ctc21m00.viginc = today   then
          let ws.horaatu  =  current hour to minute
          if d_ctc21m00.viginchor < current hour to minute  then
             error " Horario vig inicial nao deve ser menor que hora atual --> ", ws.horaatu
             next field viginchor
            end if
       end if

       let ws.data1  =  d_ctc21m00.viginc
       let ws.data2  =  ws.data1[7,10], "-",
                        ws.data1[4,5],  "-",
                        ws.data1[1,2],  " ",
                        d_ctc21m00.viginchor

       let ws.viginchordat  =  ws.data2

    before field vigfnl
       let d_ctc21m00.vigfnl = "31/12/2099"
       display by name d_ctc21m00.vigfnl  attribute (reverse)

    after  field vigfnl
       display by name d_ctc21m00.vigfnl

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field viginchor
       end if

       if d_ctc21m00.vigfnl is null then
          error " Data final de vigencia deve ser informada!"
          next field vigfnl
       end if

       if d_ctc21m00.vigfnl < d_ctc21m00.viginc then
         error " Final de vigencia nao deve ser menor que inicio de vigencia!"
          next field vigfnl
       end if

    before field vigfnlhor
       display by name d_ctc21m00.vigfnlhor attribute (reverse)

    after  field vigfnlhor
       display by name d_ctc21m00.vigfnlhor

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field vigfnl
       end if

       if d_ctc21m00.vigfnlhor is null then
          error " Hora final de vigencia deve ser informado!"
          next field vigfnlhor
       end if

       if d_ctc21m00.vigfnl = today   then
          let ws.horaatu  =  current hour to minute
          if d_ctc21m00.vigfnlhor < current hour to minute  then
             error " Horario vig final nao deve ser menor que hora atual --> ", ws.horaatu
             next field vigfnlhor
          end if
       end if

       if d_ctc21m00.viginc = d_ctc21m00.vigfnl then
          if d_ctc21m00.vigfnlhor < d_ctc21m00.viginchor then
             error " Hora final vigencia menor que hora inicial vigencia!"
             next field vigfnlhor
          end if
       end if

       let ws.data1  =  d_ctc21m00.vigfnl
       let ws.data2  =  ws.data1[7,10], "-",
                        ws.data1[4,5],  "-",
                        ws.data1[1,2],  " ",
                        d_ctc21m00.viginchor

       let ws.vigfnlhordat = ws.data2

       on key (interrupt)
          exit input

    end input

    if int_flag then
       exit while
    end if
 
    initialize l_ret to null

    call set_count(arr_aux - 1)
    let arr_aux = 1

    input array a_ctc21m00 without defaults from s_ctc21m00.*

       before row
          let arr_aux = arr_curr()
          let scr_aux = scr_line()

       before insert
          let ws.acao = "I"
          initialize a_ctc21m00[arr_aux].* to null

       before field prtcponom
          display a_ctc21m00[arr_aux].prtcponom to
                s_ctc21m00[scr_aux].prtcponom  attribute(reverse)

       after field prtcponom
          display a_ctc21m00[arr_aux].prtcponom to
                  s_ctc21m00[scr_aux].prtcponom

          if a_ctc21m00[arr_aux].prtcponom is null then
             error " Nome do campo deve ser informado!"
             call ctc21m04() returning a_ctc21m00[arr_aux].prtcpointcod,
                                       a_ctc21m00[arr_aux].prtcponom,
                                       a_ctc21m00[arr_aux].prtcpointnom
             next field prtcponom
          end if

          select prtcpointcod,
                 prtcpointnom,
                 prtcponom
            into a_ctc21m00[arr_aux].prtcpointcod,
                 a_ctc21m00[arr_aux].prtcpointnom,
                 a_ctc21m00[arr_aux].prtcponom
            from dattprt
           where prtcponom = a_ctc21m00[arr_aux].prtcponom

          if sqlca.sqlcode = notfound then
             error " Nome do campo nao cadastrado!"
             call ctc21m04() returning a_ctc21m00[arr_aux].prtcpointcod,
                                       a_ctc21m00[arr_aux].prtcponom,
                                       a_ctc21m00[arr_aux].prtcpointnom
             next field prtcponom
          end if

          for ws_conta = 1 to 50
              if a_ctc21m00[ws_conta].prtcponom is null then
                 exit for
              end if
              if a_ctc21m00[arr_aux].prtcponom = "CIDADE" or
                 a_ctc21m00[arr_aux].prtcponom = "UF" then
                 if a_ctc21m00[ws_conta].prtcponom <> "CIDADE"    and
                    a_ctc21m00[ws_conta].prtcponom <> "UF"    and
                    a_ctc21m00[ws_conta].prtcponom <> "GRUPO" and
                    a_ctc21m00[ws_conta].prtcponom <> "ASSUNTO" then
                    error " CIDADE ou UF nao podem participar desta pesquisa!"
                    next field prtcponom
                 end if
               else
                 if a_ctc21m00[arr_aux].prtcponom = "GRUPO" or
                    a_ctc21m00[arr_aux].prtcponom = "ASSUNTO" then
                    continue for
                  else
                    if a_ctc21m00[ws_conta].prtcponom = "CIDADE" or
                       a_ctc21m00[ws_conta].prtcponom = "UF" then
                       error " Este item nao pode participar da mesma pesquisa que CIDADE ou UF!"
                       next field prtcponom
                    end if
                 end if
              end if
          end for

       before field sinal
          display a_ctc21m00[arr_aux].sinal to
                  s_ctc21m00[scr_aux].sinal  attribute(reverse)

       after field sinal
          display a_ctc21m00[arr_aux].sinal to
                  s_ctc21m00[scr_aux].sinal

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field prtcponom
          end if

          if a_ctc21m00[arr_aux].sinal is null then
             error " Informe : (=)Regra ou (<>)Excessao!"
             next field sinal
          end if

          if a_ctc21m00[arr_aux].sinal <> "="   and
             a_ctc21m00[arr_aux].sinal <> "<>"  then
             error " Informe : (=)Regra ou (<>)Excessao!"
             next field sinal
          end if

       before field prtprccntdes
          display a_ctc21m00[arr_aux].prtprccntdes to
                  s_ctc21m00[scr_aux].prtprccntdes  attribute(reverse)

       after field prtprccntdes
          display a_ctc21m00[arr_aux].prtprccntdes to
                  s_ctc21m00[scr_aux].prtprccntdes

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field sinal
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "c24astagp" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                call ctn30c00() returning a_ctc21m00[arr_aux].prtprccntdes
                next field prtprccntdes
             else
                select *
                  from datkastagp
                 where c24astagp = a_ctc21m00[arr_aux].prtprccntdes

                if sqlca.sqlcode = notfound then
                   error " Conteudo nao cadastrado!"
                   call ctn30c00() returning a_ctc21m00[arr_aux].prtprccntdes
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "c24astcod" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                call ctn31c00() returning a_ctc21m00[arr_aux].prtprccntdes
                next field prtprccntdes
             else
                select *
                  from datkassunto
                 where c24astcod = a_ctc21m00[arr_aux].prtprccntdes

                if sqlca.sqlcode = notfound then
                   error " Conteudo nao cadastrado!"
                   call ctn31c00() returning a_ctc21m00[arr_aux].prtprccntdes
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "cvnnum"  then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                call ctn20c00() returning a_ctc21m00[arr_aux].prtprccntdes
                next field prtprccntdes
             else
                select *
                  from akckconvenio
                 where cvnnum = a_ctc21m00[arr_aux].prtprccntdes

                if sqlca.sqlcode = notfound then
                   error " Conteudo nao cadastrado!"
                   call ctn20c00() returning a_ctc21m00[arr_aux].prtprccntdes
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "ramcod"  then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                call ctn33c00() returning a_ctc21m00[arr_aux].prtprccntdes
                next field prtprccntdes
             else
                
             let l_numeric = false
             let l_alfa    = false
             
             for l_ctt = 1 to length(a_ctc21m00[arr_aux].prtprccntdes)    
                if a_ctc21m00[arr_aux].prtprccntdes[l_ctt] matches "[0-9]" then                                             
                   let l_numeric = true
                else                             
                   let l_alfa = true
                end if                           
             end for                             
                
                if l_alfa = true then 
                   error "POR FAVOR , DIGITE SOMENTE NUMEROS " 
                   next field prtprccntdes
                end if    
                
                select *
                  from gtakram
                 where ramcod = a_ctc21m00[arr_aux].prtprccntdes
                   and empcod = 1

                if sqlca.sqlcode = notfound then
                   error " Conteudo nao cadastrado!"
                   call ctn33c00() returning a_ctc21m00[arr_aux].prtprccntdes
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "succod" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                call ctn32c00() returning a_ctc21m00[arr_aux].prtprccntdes
                next field prtprccntdes
             else
                select *
                  from gabksuc
                 where succod = a_ctc21m00[arr_aux].prtprccntdes

                if sqlca.sqlcode = notfound then
                   error " Conteudo nao cadastrado!"
                   call ctn32c00() returning a_ctc21m00[arr_aux].prtprccntdes
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "clalclcod" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                call ctn34c00() returning a_ctc21m00[arr_aux].prtprccntdes
                next field prtprccntdes
             else
                # -- CT 284947 - Katiucia -- #
                let ws.tabnum = F_FUNGERAL_TABNUM("agekregiao"
                                                , d_ctc21m00.viginc)

                whenever error continue
                select *
                  from agekregiao
                 where tabnum    = ws.tabnum
                   and clalclcod = a_ctc21m00[arr_aux].prtprccntdes

                whenever error stop
                if sqlca.sqlcode = notfound then
                   error " Conteudo nao cadastrado!"
                   call ctn34c00() returning a_ctc21m00[arr_aux].prtprccntdes
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "cbtcod" then
             if a_ctc21m00[arr_aux].prtprccntdes <> 1 and
                a_ctc21m00[arr_aux].prtprccntdes <> 2 and
                a_ctc21m00[arr_aux].prtprccntdes <> 6 then
                error " Cobertura nao cadastrada!"
                next field prtprccntdes
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "clscod" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                next field prtprccntdes
             else
                let ws.tabnum = F_FUNGERAL_TABNUM("aackcls", d_ctc21m00.viginc)


             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "cidnom" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                next field prtprccntdes
              else
                #---------------------------------------------------------
                # Verifica se a cidade esta cadastrada
                #---------------------------------------------------------
                let ws_conta = 0
                select count(*)
                  into ws_conta
                  from glakcid
                  where cidnom = a_ctc21m00[arr_aux].prtprccntdes

                if ws_conta = 0  then
                   error " Cidade nao cadastrada!"
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "ufdcod" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                next field prtprccntdes
              else
                #---------------------------------------------------------
                # Verifica se UF esta cadastrada
                #---------------------------------------------------------
                let ws_conta = 0
                select count(*)
                  into ws_conta
                  from glakest
                 where ufdcod = a_ctc21m00[arr_aux].prtprccntdes

                if ws_conta = 0  then
                   error " Unidade federativa nao cadastrada!"
                   next field prtprccntdes
                end if
             end if
          end if

          if a_ctc21m00[arr_aux].prtcpointnom = "ctgtrfcod" then
             if a_ctc21m00[arr_aux].prtprccntdes is null then
                error " Conteudo deve ser informado!"
                next field prtprccntdes
             else
                let ws.tabnum = F_FUNGERAL_TABNUM("agekcateg",d_ctc21m00.viginc)

                select ctgtrfcod
                  from agekcateg
                 where tabnum    = ws.tabnum
                   and ramcod    = 531
                   and ctgtrfcod = a_ctc21m00[arr_aux].prtprccntdes

                if sqlca.sqlcode = notfound then
                   error " Categoria tarifaria nao cadastrada!"
                   next field prtprccntdes
                end if
             end if
          end if

          select prtprcnum
            from datmprtprc
           where datmprtprc.prtprcnum    = ws.prtprcnum
             and datmprtprc.prtcpointcod = a_ctc21m00[arr_aux].prtcpointcod
             and datmprtprc.prtprccntdes = a_ctc21m00[arr_aux].prtprccntdes

          if sqlca.sqlcode  =  0   then
             error " Campo/Conteudo ja' cadastrado para este procedimento!"
             next field prtcponom
          end if

       before delete
         let ws.acao  =  "D"

         if a_ctc21m00[arr_aux].prtcpointcod  is null   then
            continue input
         end if

       after row
          #------------------------------------------------------------------
          # Gera numero de procedimento apenas na primeira linha gravada
          #------------------------------------------------------------------
          if ws.acao  =  "I"   then

             if ws.prtprcnum  is null   then
                select max(prtprcnum)
                  into ws.prtprcnum
                  from datmprtprc

                if ws.prtprcnum is null then
                   let ws.prtprcnum = 1
                else
                   let ws.prtprcnum = ws.prtprcnum + 1
                end if
                let ws.cabtxt = "PROCEDIMENTO ", ws.prtprcnum  using "###&&"
                display by name ws.cabtxt  attribute(reverse)
             end if

             if a_ctc21m00[arr_aux].sinal  =  "="   then
                let ws.prtprcexcflg = "R"
             else
                let ws.prtprcexcflg = "E"
             end if

             insert into datmprtprc ( viginchordat,
                                      vigfnlhordat,
                                      prtcpointcod,
                                      prtprccntdes,
                                      prtprcnum,
                                      prtprcexcflg,
                                      prtprcsitcod
                                    )
                              values
                                    ( ws.viginchordat,
                                      ws.vigfnlhordat,
                                      a_ctc21m00[arr_aux].prtcpointcod,
                                      a_ctc21m00[arr_aux].prtprccntdes,
                                      ws.prtprcnum,
                                      ws.prtprcexcflg,
                                      "P"
                                    )
                       
             end if

       on key (accept)
          continue input

       on key (f8)
          if ws.prtprcnum  is null   then
             error " Texto so' deve ser cadastrado apos cadastramento de campo!"
          else
             call ctc21m06(0,0,ws.prtprcnum)
          end if

       on key (interrupt)
          if ws.prtprcnum  is not null   then
             let ws.count  =  0
             select count(*)
               into ws.count
               from datmprctxt
              where prtprcnum  =  ws.prtprcnum

             if ws.count  =  0   then
               call cts08g01("A","S", "","NENHUM TEXTO FOI CADASTRADO",
                                         "ABANDONA CADASTRAMENTO ?","")
                    returning ws.confirma
             else
               #Popup Empresas
               call ctc21m00_popup_empresa()
             
               call ctc21m00_conta_x()
                 returning m_arr_count  # numero de empresas escolhidas
 
               let l_idx = 1
                 
               for l_idx = 1 to m_arr_count
                   #carrega tabela Procedimento X Empresa
                   
                   open c_ctc21m00_003 using ws.prtprcnum
                                           , am_retorno[l_idx].empcod
                                       
                   fetch c_ctc21m00_003 into l_aux_count
                 
                   if l_aux_count = 0 then        
                      execute p_ctc21m00_002 using ws.prtprcnum            # procedimento
                                               , am_retorno[l_idx].empcod  # empresa
                   end if
               end for
             
               call cts08g01("A","S", "","CONCLUI O CADASTRAMENTO ?","","")
                    returning ws.confirma
             end if

             if ws.confirma  =  "S"   then
                exit input
             else
                continue input
             end if
          end if
          exit input

    end input

 end while

 let int_flag = false
 close window w_ctc21m00

end function   ###--- ctc21m00

#-------------------------------------------------------------------------------
 function ctc21m00_popup_empresa()
#-------------------------------------------------------------------------------
 
define l_empcod  like gabkemp.empcod
define l_empnom  like gabkemp.empnom
define i         smallint
define l_index   smallint
define l_x       smallint
define l_arrc    smallint
define l_tela    smallint

 
 initialize la_ctc21m00a, am_retorno to null
 
 initialize l_empcod
          , l_empnom to null
 
 let l_x     = 0
 let i       = 1
 let l_index = 1
 let l_arrc  = 0
 let l_tela  = 0
 
 #carregar array para input
 open c_ctc21m00_001
 foreach c_ctc21m00_001 into l_empcod, l_empnom
    let la_ctc21m00a[i].empcod = l_empcod
    let la_ctc21m00a[i].empnom = l_empnom
    let i = i + 1   
 end foreach
 
 open window w_ctc21m00a at 8,10 with form "ctc21m00a"
      attribute (border, form line 1)

 call set_count(i - 1)
 
 input array la_ctc21m00a without defaults from sa_ctc21m00a.* 
   
   #-----------------
    before row
   #-----------------
       let l_arrc = arr_curr()
       let l_tela = scr_line()
   
        if la_ctc21m00a[l_arrc].empcod is null then
            next field marca
         end if
   
   #-----------------
    after row
   #-----------------
      if (fgl_lastkey() = fgl_keyval("down")    or
          fgl_lastkey() = fgl_keyval("right")   or
          fgl_lastkey() = fgl_keyval("tab")     or
          fgl_lastkey() = fgl_keyval("return")) and
          l_arrc = arr_count()                 then 
          next field marca
         end if 
   
   #-------------------
    after field marca
   #-------------------
     if la_ctc21m00a[l_arrc].marca = 'X' then  
        let am_retorno[l_index].empcod = la_ctc21m00a[l_arrc].empcod
        
        let l_index = l_index + 1

     end if
     
     display la_ctc21m00a[l_arrc].marca  to sa_ctc21m00a[l_tela].marca
     
   #-----------------
    on key(interrupt)
   #-----------------
     error 'Aperte (F8) para confirmar!'
     
   #-----------------
    on key (F8)
   #-----------------
     let la_ctc21m00a[l_arrc].marca = get_fldbuf(marca)
     
     if la_ctc21m00a[l_arrc].marca = 'X' then
        let am_retorno[l_index].empcod = la_ctc21m00a[l_arrc].empcod
        let l_index = l_index + 1
     end if
     
     call ctc21m00_conta_x()
          returning l_x
          
     if l_x < 1 then
        error 'Selecione pelo menos uma empresa!'
     else
        #return 
        exit input
     end if
     
 end input

 close window w_ctc21m00a

end function

#==========================
 function ctc21m00_conta_x()
#==========================
define l_i     smallint
define l_conta smallint
  
  let l_conta = 0

  for l_i = 1 to arr_count()
      if la_ctc21m00a[l_i].marca = 'X' then
         let l_conta = l_conta + 1
      end if
  end for

 return l_conta
 
end function