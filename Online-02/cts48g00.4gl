#############################################################################
# Nome do Modulo: CTS48G00                                        Burini    #
# Atualização de Endereço Roteirizado de Prestadores              Ago/2007  #
#...........................................................................#
#                                                                           #
#                  * * * Alteracoes * * *                                   #
#                                                                           #
# Data        Autor Fabrica   Origem     Alteracao                          #
# ----------  --------------  ---------  ---------------------------------- #
# 02/03/2010  Adriano Santos  PSI 252891 Inclusao do padrao idx 4 e 5       #
#############################################################################

database porto

 globals "/homedsa/projetos/geral/globals/glct.4gl"

  define am_enderecos array[200] of record
         tipendtxt    char(73),
         brrnom       like datkmpabrr.brrnom,
         cep          char(08),
         codigo       integer,
         tipoend      char(50),
         lgdtip       char(20),
         lgdnom       char(60)
  end record

  define am_exibicao  array[200] of record
         tipendtxt    char(73),
         brrnom       like datkmpabrr.brrnom,
         cep          char(08),
         codigo       integer,
         tipoend      char(50),
         lgdtip       char(20),
         lgdnom       char(60)
  end record

 define mr_record record
                      pstcoddig like dpaksocor.pstcoddig,
                      nomgrr    like dpaksocor.nomgrr,
                      endlgd    like dpaksocor.endlgd,
                      pstobs    like dpaksocor.pstobs,
                      endbrr    like dpaksocor.endbrr,
                      endcid    like dpaksocor.endcid,
                      endufd    like dpaksocor.endufd
                  end record

 define mr_aux    record
                      lgdtip        char(10),
                      lgdcep        like glaklgd.lgdcep,
                      lgdcepcmp     like glaklgd.lgdcepcmp,
                      c24lclpdrcod  like datmlcl.c24lclpdrcod,
                      cidcod        like glakcid.cidcod,
                      lclltt        like datmlcl.lclltt,
                      lcllgt        like datmlcl.lcllgt,
                      lgdnum        like datmlcl.lgdnum
                  end record


 define m_qtd_end       smallint,
        m_ctx25g05_prep smallint,
        m_num           char(75)

main
    defer interrupt
    call cts47g00()
end main

#---------------------------#
 function cts47g00_prepare()
#---------------------------#

     define l_sql char(500)

     let l_sql = " select pstcoddig, ",
                        " nomgrr, ",
                        " endlgd, ",
                        " pstobs, ",
                        " endbrr, ",
                        " endcid, ",
                        " endufd ",
                   " from dpaksocor  a, ",
                        " datkmpacid b ",
                  " where prssitcod = 'A' ",
                    " and a.lclltt is null ",
                    " and a.lcllgt is null ",
                    " and b.mpacrglgdflg > 0 ",
                    #" and a.c24lclpdrcod = 1 ",
                    " and a.endufd = b.ufdcod ",
                    " and a.endcid = b.cidnom "

     prepare prcts47g00_01 from l_sql
     declare cqcts47g00_01 cursor for prcts47g00_01

     let l_sql = "select lgdtip ",
                  " from glaklgdtip ",
                 " where (lgdtip = ? or lgddsc = ?)"

     prepare prcts47g00_02 from l_sql
     declare cqcts47g00_02 cursor for prcts47g00_02

     let l_sql = "select cidcod ",
                  " from glakcid ",
                 " where cidnom = ? ",
                   " and ufdcod = ? "

     prepare prcts47g00_03 from l_sql
     declare cqcts47g00_03 cursor for prcts47g00_03

  let l_sql = " select 1",
                " from glakest ",
               " where ufdcod = ? "
  
  prepare pctx25g05001 from l_sql
  declare cctx25g05001 cursor for pctx25g05001

  let l_sql = " select 1 ",
                " from glakcid ",
               " where cidnom = ? ",
                 " and ufdcod = ? "

  prepare pctx25g05002 from l_sql
  declare cctx25g05002 cursor for pctx25g05002

  let l_sql = " select 1 ",
                " from datkmpacid ",
               " where cidnom = ? ",
                 " and ufdcod = ? "

  prepare pctx25g05003 from l_sql
  declare cctx25g05003 cursor for pctx25g05003

  let l_sql = " select grlinf ",
                " from datkgeral ",
               " where grlchv = ? "

  prepare pctx25g05004 from l_sql
  declare cctx25g05004 cursor for pctx25g05004

  let l_sql = " select lclltt, ",
                     " lcllgt ",
                " from datkmpacid ",
               " where ufdcod = ? ",
                 " and cidnom = ? "

  prepare pctx25g05005 from l_sql
  declare cctx25g05005 cursor for pctx25g05005

  let l_sql = " update datkgeral ",
                " set (grlinf) = (?) ",
               " where grlchv = ? "

  prepare pctx25g05006 from l_sql

  let l_sql = " update dpaksocor ",
                 " set c24lclpdrcod = ?, ",
                     " lclltt       = ?, ",
                     " lcllgt       = ?, ",
                     " lgdtip       = ?, ",
                     " lgdnum       = ?, ",
                     " endlgd       = ?, ",
                     " c24lclpdrcod = ? ",
               " where pstcoddig = ? "

  prepare pctx25g05007 from l_sql

 end function

#------------------#
 function cts47g00()
#------------------#

     define l_flag smallint

     initialize mr_aux.* , mr_record.*, l_flag to null

     call cts47g00_prepare()

     open cqcts47g00_01
     fetch cqcts47g00_01 into mr_record.pstcoddig,
                              mr_record.nomgrr,
                              mr_record.endlgd,
                              mr_record.pstobs,
                              mr_record.endbrr,
                              mr_record.endcid,
                              mr_record.endufd

     case sqlca.sqlcode
        when 0

            open window w_cts47g00 at 2,2 with form "cts48g00" attribute (border)

            foreach cqcts47g00_01 into mr_record.pstcoddig,
                                       mr_record.nomgrr,
                                       mr_record.endlgd,
                                       mr_record.pstobs,
                                       mr_record.endbrr,
                                       mr_record.endcid,
                                       mr_record.endufd

                    
                    if  cts48g00_verif_lock() then
                        continue foreach
                    else
                        call cts48g00_lock()
                    end if
                    
                    if  sqlca.sqlcode <> 0 then
                        if  sqlca.sqlcode = notfound then
                            continue foreach
                        else
                            display 'ERRO : ', sqlca.sqlcode, ' CI '
                        end if
                    end if

                    call cts48g00_val_tiplgd(mr_record.endlgd)
                         returning mr_aux.lgdtip,
                                   mr_record.endlgd

                    display by name mr_record.pstcoddig attribute(reverse) 
                    display by name mr_record.nomgrr    attribute(reverse)
                    display by name mr_record.endlgd    attribute(reverse)
                    display by name mr_record.endbrr    attribute(reverse)
                    display by name mr_record.endcid    attribute(reverse)
                    display by name mr_record.endufd    attribute(reverse)

                    #open cqcts47g00_03 using mr_record.endcid,
                    #                         mr_record.endufd
                    #
                    #fetch cqcts47g00_03 into mr_aux.cidcod

                    call cts48g00_numero_end(mr_record.endlgd)
                         returning mr_record.endlgd,
                                   mr_aux.lgdnum
                    
                    call ctx25g05a("P",                                                  
                                   "                       ROTEIRIZACAO DE ENDERECO",    
                                   mr_record.endufd,                                     
                                   mr_record.endcid,                                     
                                   mr_aux.lgdtip,                                        
                                   mr_record.endlgd,                                     
                                   mr_record.pstobs,                                     
                                   mr_aux.lgdnum,                                        
                                   mr_record.endbrr,                                     
                                   "",                                                   
                                   "",                                                   
                                   "",                                                   
                                   "",
                                   "")
                        returning mr_aux.lgdtip,           
                                  mr_record.endlgd,        
                                  mr_record.pstobs,        
                                  mr_aux.lgdnum,           
                                  mr_record.endbrr,        
                                  mr_aux.lgdcep,           
                                  mr_aux.lgdcepcmp,        
                                  mr_aux.lclltt,           
                                  mr_aux.lcllgt,           
                                  mr_aux.c24lclpdrcod,     
                                  mr_record.endufd,        
                                  mr_record.endcid,        
                                  l_flag                   

                if  not l_flag then
                    call cts48g00_del_lock() 
                    exit foreach
                else
                    if  mr_aux.lclltt is null or
                        mr_aux.lcllgt is null then
                        call cts48g00_del_lock()
                        continue foreach
                    else
                        execute pctx25g05007 using mr_aux.c24lclpdrcod,
                                                   mr_aux.lclltt,
                                                   mr_aux.lcllgt,
                                                   mr_aux.lgdtip,
                                                   mr_aux.lgdnum,
                                                   mr_record.endlgd,
                                                   mr_aux.c24lclpdrcod,
                                                   mr_record.pstcoddig
                        call cts48g00_del_lock()
                    end if
                end if
                
            end foreach

            close window w_cts47g00

        when 100
           display 'Nenhum Prestador Selecionado.'
        otherwise
           display 'ERRO', sqlca.sqlcode, ' AVISE A INFORMATICA.'
     end case

 end function

#--------------------------------------#
 function cts48g00_val_tiplgd(l_endlgd)
#--------------------------------------#

     define l_ind, l_ind2, l_length integer,
            l_endlgd, l_lgdnom char(100),
            l_tiplgd char(10)

     initialize l_tiplgd to null

     let l_ind    = 0
     let l_length = 0

     let l_length = length(l_endlgd)

     for l_ind = 1 to l_length
         if  l_endlgd[l_ind] <> " " and
             l_endlgd[l_ind] <> "." and
             l_endlgd[l_ind] <> ":" then
             let l_tiplgd = l_tiplgd clipped, l_endlgd[l_ind]
         else
             exit for
         end if
     end for

     for l_ind2 = l_ind to l_length
         if  l_endlgd[l_ind2] <> " " and
             l_endlgd[l_ind2] <> "." and
             l_endlgd[l_ind2] <> ":" then
             let l_lgdnom = l_endlgd[l_ind2, l_length]
             exit for
         else
             continue for
         end if
     end for

     open cqcts47g00_02 using l_tiplgd,
                              l_tiplgd

     fetch cqcts47g00_02 into l_tiplgd

     return l_tiplgd,
            l_lgdnom

 end function

#------------------------------#
function ctx25g05a(lr_parametro)
#------------------------------#

  define lr_parametro   record
         tipo_input     char(01),
         titulo_janela  char(74),
         ufdcod         like datkmpacid.ufdcod,
         cidnom         like datkmpacid.cidnom,
         lgdtip         like datkmpalgd.lgdtip,
         lgdnom         like datkmpalgd.lgdnom,
         pstobs         like dpaksocor.pstobs,
         lgdnum         like datmlcl.lgdnum,
         brrnom         like datmlcl.brrnom,
         lgdcep         like datmlcl.lgdcep,
         lgdcepcmp      like datmlcl.lgdcepcmp,
         lclltt         like datmlcl.lclltt,
         lcllgt         like datmlcl.lcllgt,
         c24lclpdrcod   like datmlcl.c24lclpdrcod
  end record

  define lr_retorno   record
         lgdtip       like datkmpalgd.lgdtip,
         lgdnom       like datkmpalgd.lgdnom,
         pstobs       like dpaksocor.pstobs,
         lgdnum       like datmlcl.lgdnum,
         brrnom       like datmlcl.brrnom,
         lgdcep       like datmlcl.lgdcep,
         lgdcepcmp    like datmlcl.lgdcepcmp,
         lclltt       like datmlcl.lclltt,
         lcllgt       like datmlcl.lcllgt,
         c24lclpdrcod like datmlcl.c24lclpdrcod,
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom
  end record

  define lr_input     record
         ufdcod       like datkmpacid.ufdcod,
         cidnom       like datkmpacid.cidnom,
         lgdnom       like datkmpalgd.lgdnom,
         lgdnum       like datmlcl.lgdnum,
         pstobs       like dpaksocor.pstobs
  end record

  define l_status     integer,
         l_msg        char(80),
         l_cep        char(08),
         l_prim_vez   smallint,
         l_i          smallint,
         l_sede       smallint,
         l_notindexed smallint,
         l_flag       smallint

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  let l_status    = null
  let l_msg       = null
  let l_cep       = null
  let l_i         = null
  let m_qtd_end   = 0
  let l_prim_vez  = true
  let l_sede      = false
  let l_notindexed = false

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

  # -> CRIA A TABELA TEMPORARIA PARA ORDENACAO DOS LOGRADOUROS
  call ctx25g05_cria_temp()

  for l_i = 1 to 200
      let am_exibicao[l_i].tipendtxt = null
      let am_exibicao[l_i].brrnom    = null
      let am_exibicao[l_i].cep       = null
      let am_exibicao[l_i].codigo    = null
      let am_exibicao[l_i].tipoend   = null
      let am_exibicao[l_i].lgdtip    = null
      let am_exibicao[l_i].lgdnom    = null

      let am_enderecos[l_i].tipendtxt = null
      let am_enderecos[l_i].brrnom    = null
      let am_enderecos[l_i].cep       = null
      let am_enderecos[l_i].codigo    = null
      let am_enderecos[l_i].tipoend   = null
      let am_enderecos[l_i].lgdtip    = null
      let am_enderecos[l_i].lgdnom    = null
  end for

  initialize  lr_retorno.*  to  null
  initialize  lr_input.*  to  null
  
  if m_ctx25g05_prep is null or
     m_ctx25g05_prep <> true then
     call ctx25g05_prepare()
  end if  

  let lr_retorno.c24lclpdrcod  = 01  # -->  01 - Fora do padrao
  let lr_retorno.lgdtip        = lr_parametro.lgdtip
  let lr_retorno.lgdnom        = lr_parametro.lgdnom
  let lr_retorno.brrnom        = lr_parametro.brrnom
  let lr_input.lgdnom          = lr_parametro.lgdnom
  let lr_input.lgdnum          = lr_parametro.lgdnum
  let lr_input.ufdcod          = lr_parametro.ufdcod
  let lr_input.cidnom          = lr_parametro.cidnom

  if lr_input.lgdnom = "AC"  or
     lr_input.lgdnom = "A C" or
     lr_input.lgdnom = "A/C" then
     let lr_input.lgdnom = "A COMBINAR"
  end if

  if lr_input.lgdnum = 0 then
     let lr_input.lgdnum = null
  end if

  open window w_ctx25g05 at 09,02 with form "ctx25g05a"
     attribute(form line first, border)

  display by name lr_parametro.titulo_janela
  
  display lr_parametro.lgdtip to lgdtip_input
  display lr_parametro.lgdnum to lgdnum_input
  display lr_parametro.brrnom to brrnom_input
  display lr_parametro.pstobs to pstobs_input

  while true

     let l_flag = true

     input lr_input.ufdcod,
           lr_input.cidnom,
           lr_input.lgdnom,
           lr_input.pstobs,
           lr_input.lgdnum without defaults from ufdcod_input,
                                                 cidnom_input,
                                                 lgdnom_input,
                                                 pstobs_input,
                                                 lgdnum_input
        # -> UF
        before field ufdcod_input

           if lr_parametro.tipo_input = "P" then # -> PARCIAL(apenas logradouro e numeracao)
              next field lgdnom_input
           end if

           # -> SE FOR A PRIMEIRA PESQUISA E OS CAMPOS ESTIVEREM PREENCHIDOS
           # -> PESQUISA DIRETO, CASO CONTRARIO, PERMITE ALTERACAO
           if l_prim_vez and
              lr_input.ufdcod is not null and
              lr_input.cidnom is not null and
              lr_input.lgdnom is not null then
              let l_prim_vez = false
              exit input
           end if

           let l_prim_vez = false

           display lr_input.ufdcod to ufdcod_input attribute(reverse)

        after field ufdcod_input
           display lr_input.ufdcod to ufdcod_input

           if lr_input.ufdcod is null or
              lr_input.ufdcod = " " then
              let lr_input.ufdcod = "SP"
              display lr_input.ufdcod to ufdcod_input
           end if

           # -> VALIDA UF
           if not ctx25g05_existe_uf(lr_input.ufdcod) then
              error " Codigo de UF nao cadastrado!"
              next field ufdcod_input
           end if

        # -> CIDADE
        before field cidnom_input
           display lr_input.cidnom to cidnom_input attribute(reverse)

        after field cidnom_input
           display lr_input.cidnom to cidnom_input

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field ufdcod_input
           end if

           if lr_input.cidnom is null or
              lr_input.cidnom = " " then
              let lr_input.cidnom = "SAO PAULO"
              display lr_input.cidnom to cidnom_input
           end if

           # -> VALIDA CIDADE NO GUIA POSTAL
           if not ctx25g05_existe_cid(1, # GUIA POSTAL
                                      lr_input.ufdcod,
                                      lr_input.cidnom) then
              error " Cidade nao cadastrada!"

              call cts06g04(lr_input.cidnom,
                            lr_input.ufdcod)

                   returning l_status,
                             lr_input.cidnom,
                             lr_input.ufdcod

              display lr_input.cidnom to cidnom_input
              display lr_input.ufdcod to ufdcod_input
           end if

           # -> VALIDA CIDADE NO CADASTRO DE MAPAS
           if not ctx25g05_existe_cid(2, # CADASTRO DE MAPAS
                                      lr_input.ufdcod,
                                      lr_input.cidnom) then
              error " Cidade nao cadastrada na base de mapas!"
              next field cidnom_input
           end if

        # -> LOGRADOURO
        before field lgdnom_input
           display lr_input.lgdnom to lgdnom_input  attribute(reverse)

        after field lgdnom_input
           display lr_input.lgdnom to lgdnom_input

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              if lr_parametro.tipo_input = "P" then # -> PARCIAL(apenas logradouro e numeracao)
                 next field lgdnom_input
              else
                 next field cidnom_input
              end if
           end if

           if lr_input.lgdnom is null or
              lr_input.lgdnom = " " then
              error " Logradouro deve ser informado!"
              next field lgdnom_input
           end if

           if lr_input.lgdnom = "AC"  or
              lr_input.lgdnom = "A C" or
              lr_input.lgdnom = "A/C" then
              let lr_input.lgdnom = "A COMBINAR"
              display lr_input.lgdnom to lgdnom_input
           end if

           if lr_input.lgdnom = "CENTRO" then
              if cts08g01("A","S","DESEJA UTILIZAR O PONTO CENTRAL",
                          "DA CIDADE INFORMADA ?","","") = "S" then
                 let l_sede = true
                 exit input
              end if
           end if

        # -> NUMERO DO LOGRADOURO
        before field lgdnum_input
           display lr_input.lgdnum to lgdnum_input attribute(reverse)

        after field lgdnum_input
           display lr_input.lgdnum to lgdnum_input

           if fgl_lastkey() = fgl_keyval("up")   or
              fgl_lastkey() = fgl_keyval("left") then
              next field lgdnom_input
           end if

           if lr_input.lgdnum = 0 then
              let lr_input.lgdnum = null
           end if

        on key (f17, control-c, interrupt)
           if lr_parametro.c24lclpdrcod = 3 or
              lr_parametro.c24lclpdrcod = 4 or   # PSI 252891
              lr_parametro.c24lclpdrcod = 5 then # End recebido ja indexado por rua
              if cts08g01("A","S","MANTER INDEXACAO ANTERIOR?",
                                  "","","") = "S" then
                 let int_flag = true
                 exit input
              else
                 let int_flag = false
                 if cts08g01("A","S","","MANTER LAUDO SEM INDEXACAO?",
                                     "","") = "S" then
                    let l_notindexed = true
                    let lr_retorno.c24lclpdrcod = 1
                    open cctx25g05005 using lr_input.ufdcod,
                                            lr_input.cidnom
                    fetch cctx25g05005 into lr_retorno.lclltt,
                                            lr_retorno.lcllgt
                    close cctx25g05005

                    let lr_retorno.ufdcod = lr_input.ufdcod
                    let lr_retorno.cidnom = lr_input.cidnom
                    let lr_retorno.lgdtip = lr_parametro.lgdtip
                    let lr_retorno.lgdnom = lr_input.lgdnom
                    let lr_retorno.lgdnum = lr_input.lgdnum
                    let lr_retorno.brrnom = lr_parametro.brrnom

                    exit input
                 else
                    next field ufdcod_input
                 end if
              end if
           else
              if cts08g01("A","S","DESEJA IR PARA O ",
                                "PROXIMO PRESTADOR SEM ROTEIRIZACAO",
                                   " ",
                                       "CONFIRMA ?") = "N" then
                 let int_flag = true
                 let l_flag = false
                 exit while
              else
                 let int_flag = false
                 exit while
              end if
           end if


     end input

     if int_flag or l_notindexed then
        exit while
     end if

     if l_sede = true then
        open cctx25g05005 using lr_input.ufdcod,
                                lr_input.cidnom
        fetch cctx25g05005 into lr_retorno.lclltt,
                                lr_retorno.lcllgt
        close cctx25g05005

        let lr_retorno.c24lclpdrcod = 1
        let lr_retorno.lgdtip       = "SEDE"
        let lr_retorno.lgdnom       = "CENTRO"
        let lr_retorno.brrnom       = "CENTRO"

        exit while
     else  

        call ctx25g05_pesquisa(lr_parametro.lgdtip,
                               lr_input.lgdnom,
                               lr_input.lgdnum,
                               lr_parametro.brrnom,
                               lr_input.ufdcod,
                               lr_input.cidnom)

             returning l_status,
                       lr_retorno.lclltt,
                       lr_retorno.lcllgt,
                       lr_retorno.lgdtip,
                       lr_retorno.lgdnom,
                       lr_retorno.brrnom,
                       l_cep,
                       lr_retorno.c24lclpdrcod

        if l_status <> 0 then
           error "Erro ao chamar a funcao ctx25g05_pesquisa() " sleep 2
        end if

        if lr_retorno.c24lclpdrcod = 3 then # -> USUARIO ESCOLHEU UM ENDERECO
           exit while
        end if
     end if
  end while

  close window w_ctx25g05

  if int_flag then
     # SE USUARIO CANCELAR TELA, MANTER A INFORMACAO DOS PARAMETROS
     let lr_retorno.ufdcod       = lr_parametro.ufdcod
     let lr_retorno.cidnom       = lr_parametro.cidnom
     let lr_retorno.lgdtip       = lr_parametro.lgdtip
     let lr_retorno.lgdnom       = lr_parametro.lgdnom
     let lr_retorno.lgdnum       = lr_parametro.lgdnum
     let lr_retorno.brrnom       = lr_parametro.brrnom
     let lr_retorno.lgdcep       = lr_parametro.lgdcep
     let lr_retorno.lgdcepcmp    = lr_parametro.lgdcepcmp
     let lr_retorno.lclltt       = lr_parametro.lclltt
     let lr_retorno.lcllgt       = lr_parametro.lcllgt
     let lr_retorno.c24lclpdrcod = lr_parametro.c24lclpdrcod

     if lr_retorno.c24lclpdrcod is null then
        let lr_retorno.c24lclpdrcod = 1
     end if

  else
     # -> NUMERO DO LOGRADOURO, UF E CIDADE
     let lr_retorno.lgdnum       = lr_input.lgdnum
     let lr_retorno.ufdcod       = lr_input.ufdcod
     let lr_retorno.cidnom       = lr_input.cidnom

     # -> SE O BAIRRO DO MAPA NAO EXISTIR, MANTEM O BAIRRO RECEBIDO NO PARAMETRO
     if lr_retorno.brrnom is null or
        lr_parametro.brrnom =  " " then
        let lr_retorno.brrnom = lr_parametro.brrnom
     end if

  end if

  let int_flag = false

  # -> APAGA A TABELA TEMPORARIA
  call ctx25g05_drop_temp()

  return lr_retorno.lgdtip,
         lr_retorno.lgdnom,
         lr_retorno.pstobs,
         lr_retorno.lgdnum,
         lr_retorno.brrnom,
         lr_retorno.lgdcep,
         lr_retorno.lgdcepcmp,
         lr_retorno.lclltt,
         lr_retorno.lcllgt,
         lr_retorno.c24lclpdrcod,
         lr_retorno.ufdcod,
         lr_retorno.cidnom,
         l_flag

end function                                                                                   

#--------------------------------------#
 function cts48g00_numero_end(l_lgdnom)
#--------------------------------------#

     define l_lgdnom like datkmpalgd.lgdnom,
            l_lgdnum char(25),
            l_ind    smallint,
            l_ind2   smallint,
            l_aux    smallint,
            l_bu     char(01)
             
     display 'L_LGDNOM CTS48G00_NUMERO_END : ', l_lgdnom
     
     let l_lgdnom = cts48g00_retira_virg(l_lgdnom)
     
     let l_ind = length(l_lgdnom)
     
     for l_ind2 = 1 to l_ind
         
         let l_aux = (l_ind - (l_ind2 - 1))
         
         if  l_aux > 0 then
             if  l_lgdnom[l_aux] = " " or 
                 l_lgdnom[l_aux] = "," then
                 if  l_lgdnom[l_aux] = "," then
                     let l_lgdnom[l_aux] = " "
                 end if
                 exit for
             end if
         end if
     end for
     
     let l_lgdnum = l_lgdnom[l_aux + 1, l_ind]
     
     if  not cts48g00_verif_num(l_lgdnum) then
         let l_lgdnum = ""
     else
         let l_lgdnom = l_lgdnom[1,l_aux]
     end if

     return l_lgdnom,
            l_lgdnum

 end function
 
#----------------------------------#
 function cts48g00_verif_num(l_num)
#----------------------------------# 

     define l_num    char(25),
            l_num2   char(25),
            l_lenght smallint,
            l_ind    smallint,
            l_ok     smallint

     initialize l_num2 to null
     
     let l_lenght = length(l_num)
     let l_ok     = true

     for l_ind = 1 to l_lenght
         let l_num2 = l_num2 clipped, l_num[l_ind]
     end for
     
     let l_lenght = length(l_num2)
     
     for l_ind = 1 to l_lenght
         if  l_num2[l_ind] = 0 or
             l_num2[l_ind] = 1 or
             l_num2[l_ind] = 2 or
             l_num2[l_ind] = 3 or
             l_num2[l_ind] = 4 or
             l_num2[l_ind] = 5 or
             l_num2[l_ind] = 6 or
             l_num2[l_ind] = 7 or
             l_num2[l_ind] = 8 or
             l_num2[l_ind] = 9 then
             continue for  
         else   
             let l_ok = false
             exit for
         end if 
     end for
     
     return l_ok

 end function

#---------------------------------------# 
 function cts48g00_retira_virg(l_lgdnom) 
#---------------------------------------# 
 
     define l_lgdnom like datkmpalgd.lgdnom,
            l_length smallint,
            l_ind    smallint
     
     let l_length = length(l_lgdnom)
     
     for l_ind = 1 to l_length
         if  l_lgdnom[l_ind] = "," then
             let l_lgdnom[l_ind] = " "
         end if
     end for
     
     return l_lgdnom
     
 end function 
 
#------------------------------#
 function cts48g00_verif_lock()
#------------------------------# 
 
     whenever error continue
       select distinct 1 
         from igbmparam
        where relsgl    = 'CTS48G00'
          and relpamtxt = mr_record.pstcoddig 
     whenever error stop
     
     if  sqlca.sqlcode = 0 then
         return true
     else
         
         whenever error continue
           select distinct 1
             from dpaksocor
            where pstcoddig = mr_record.pstcoddig
              and lclltt is null
              and lcllgt is null
         whenever error stop
         
         if  sqlca.sqlcode = 0 then
             return false
         else
             return true
         end if   
     end if
     
 end function
 
#------------------------#
 function cts48g00_lock()
#------------------------# 
 
     let m_num = 0
     
     whenever error continue
       select max(relpamseq)
         into m_num
         from igbmparam 
        where relsgl = 'CTS48G00'
     whenever error stop
     
     if  m_num is null or m_num = " " then
         let m_num = 1
     else
         let m_num = m_num + 1
     end if

     display 'm_num: ', m_num
     
     whenever error continue
       insert into igbmparam values ('CTS48G00',
                                     m_num,
                                     "",
                                     mr_record.pstcoddig)
     whenever error stop
     
     if  sqlca.sqlcode <> 0 then
         display 'PROBLEMA NO CADASTRO DE PARAMETROS.'
         sleep 2
     end if
     
 end function
 
 
#----------------------------#
 function cts48g00_del_lock()
#----------------------------# 

     whenever error continue
       delete from igbmparam 
        where relsgl    = 'CTS48G00'
          and relpamtxt = mr_record.pstcoddig
     whenever error stop
     
     display 'sqlca.sqlcode : ', sqlca.sqlcode
     
     if  sqlca.sqlcode <> 0 then
         display 'PROBLEMA NA EXCLUSAO DE PARAMETROS.'
         sleep 2
     end if
     
 end function 