#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
# ........................................................................... #
# Sistema........: CENTRAL 24HS                                               #
# Modulo.........: ctc17m00                                                   #
# Analista Resp..: Ligia Mattge                                               #
# PSI/OSF........: 191108                                                     #
#                  Modulo de manutencao de Vias Emergenciais                  #
# ........................................................................... #
# Desenvolvimento: Vinicius, Meta                                             #
# Liberacao......: 17/05/2005                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * Alteracoes * * *                            #
#                                                                             #
# Data       Autor Fabrica   Origem     Alteracao                             #
# ---------- --------------  ---------- ------------------------------------- #
# 20/01/2006 Priscila                   Cadastro vias emergenciais            #
#                                       (10 posicoes para campo emeviades)    #
#-----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

 define m_prep_sql     smallint
 define mr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record

#-------------------------
function ctc17m00_prepare()
#-------------------------
 define l_sql   char(900)
 
 let l_sql = " select 1 "
            ,"   from datkemevia "
            ,"  where emeviacod = ? "
 prepare pctc17m00001 from l_sql
 declare cctc17m00001 cursor for pctc17m00001
 
 let l_sql = " select emeviacod "
            ,"   from datkemevia "
            ," order by emeviacod "
 prepare pctc17m00002 from l_sql
 declare cctc17m00002 cursor for pctc17m00002
 
 let l_sql = " select emeviades, emeviapri, emeviasit, caddat, "
            ,"        cademp, cadmat, atldat, atlemp, atlmat "
            ,"   from datkemevia "
            ,"  where emeviacod = ? "
 prepare pctc17m00003 from l_sql
 declare cctc17m00003 cursor for pctc17m00003
 
 let l_sql = " select emeviacod "
            ,"   from datkemevia "
            ,"  where emeviacod > ? "
            ," order by emeviacod "
 prepare pctc17m00004 from l_sql
 declare cctc17m00004 cursor for pctc17m00004

 let l_sql = " select emeviacod "
            ,"   from datkemevia "
            ,"  where emeviacod < ? "
            ," order by emeviacod desc "
 prepare pctc17m00005 from l_sql
 declare cctc17m00005 cursor for pctc17m00005
 
 let l_sql = " update datkemevia set emeviades = ?, "
            ,"                       emeviapri = ?, "
            ,"                       emeviasit = ?, "
            ,"                       atldat    = today, "
            ,"                       atlemp    = ?, "
            ,"                       atlmat    = ? "
            ,"  where emeviacod = ? "
 prepare pctc17m00006 from l_sql
 
 let l_sql = " select max(emeviacod) "
            ,"   from datkemevia "
 prepare pctc17m00007 from l_sql
 declare cctc17m00007 cursor for pctc17m00007
 
 let l_sql = " insert into datkemevia "
            ,"             (emeviacod, emeviades, emeviapri, emeviasit, caddat, "
            ,"              cademp, cadmat, atldat, atlemp, atlmat) values "
            ,"             (?,?,?,?,current,?,?,current,?,?) "
 prepare pctc17m00008 from l_sql
 
 let l_sql = " delete from datkemevia "
            ,"  where emeviacod= ? "
 prepare pctc17m00009 from l_sql
 
 let m_prep_sql = true
  
end function

#-----------------
function ctc17m00()
#-----------------

 open window w_ctc17m00 at 4,2 with form 'ctc17m00'

 if m_prep_sql is null or
    m_prep_sql <> true then
    call ctc17m00_prepare()
 end if

 initialize mr_datkemevia to null
 
 menu "VIAS EMERGENCIAIS"
    command key ('I') 'Incluir' 'Incluir vias emergenciais'
       call ctc17m00_incluir()
       initialize mr_datkemevia to null
       display by name mr_datkemevia.*

    command key ('S') 'Selecionar' 'Seleciona uma via emergencial'
       call ctc17m00_selecionar() returning mr_datkemevia.*
       if mr_datkemevia.emeviacod is not null then
          next option "Proximo"
       end if
    
    command key ('P') 'Proximo' 'Exibir a proxima via emergencial'
       if mr_datkemevia.emeviacod is not null then
          call ctc17m00_proximo(mr_datkemevia.emeviacod) returning mr_datkemevia.*
       else
          error "Via emergencial deve ser selecionada" 
       end if
       
    command key ('A') 'Anterior' 'Exibir a via emergencial anterior'
       if mr_datkemevia.emeviacod is not null then
          call ctc17m00_anterior(mr_datkemevia.emeviacod) returning mr_datkemevia.*
       else
          error "Via emergencial deve ser selecionada" 
       end if

    command key ('M') 'Modificar' 'Modificar a via emergencial'
       if mr_datkemevia.emeviacod is not null then
          call ctc17m00_modificar(mr_datkemevia.*) returning mr_datkemevia.*
       else
          error "Via emergencial deve ser selecionada" 
       end if

    command key ('E') 'Excluir' 'Excluir a via emergencial'
       if mr_datkemevia.emeviacod is not null then
          if ctc17m00_excluir(mr_datkemevia.emeviacod) then
             initialize mr_datkemevia to null
             display by name mr_datkemevia.*
             next option "Selecionar"
          end if
       else
          error "Via emergencial deve ser selecionada"
       end if

    command key ('D') 'Departamentos' 'Manutencao dos departamentos da via'
       if mr_datkemevia.emeviacod is not null then
          call ctc17m01(mr_datkemevia.emeviacod, mr_datkemevia.emeviades)
       else
          error "Via emergencial deve ser selecionada" 
       end if

    command key ('N') 'eNcerrar' 'Voltar ao menu anterior'
       exit menu
 end menu

 close window w_ctc17m00
 let int_flag = false
 
end function

#----------------------------
function ctc17m00_selecionar()
#----------------------------
 define l_emeviacod    like datkemevia.emeviacod,
        l_qtd_depto    smallint
 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record

 initialize lr_datkemevia to null
 let l_emeviacod = null 
 
 display by name lr_datkemevia.*
 
 input l_emeviacod without defaults from emeviacod
     on key (interrupt, control-c, f17)
        let int_flag = true
        let l_emeviacod = null
        exit input
     
     before field emeviacod
        display l_emeviacod to emeviacod attribute(reverse)
        
     after field emeviacod
        display l_emeviacod to emeviacod 
        
        if l_emeviacod is not null then
           open cctc17m00001 using l_emeviacod
           whenever error continue
           fetch cctc17m00001
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = notfound then
                 error "Via emergencial nao cadastrada" 
                 next field emeviacod
              else
                 error 'Erro SELECT cctc17m00001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
                 error 'CTC17M00 / ctc17m00_selecionar() / ', l_emeviacod  sleep 2
                 let l_emeviacod = null
                 exit input
              end if
           end if
        else
           open cctc17m00002
           whenever error continue
           fetch cctc17m00002 into l_emeviacod
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = notfound then
                 error "Nenhuma via emergencial foi encontrada"
              else
                 error 'Erro SELECT cctc17m00002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
                 error 'CTC17M00 / ctc17m00_selecionar() ' sleep 2
              end if
           end if
           exit input
        end if
 end input

 if l_emeviacod is not null then
    call ctc17m00_mostra(l_emeviacod) returning lr_datkemevia.*
 else
    let int_flag = false
 end if

 return lr_datkemevia.*
 
end function

#-------------------------
function ctc17m00_modificar(lr_datkemevia)
#-------------------------
 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record
 define l_emeviacod    like datkemevia.emeviacod,
        l_cancelou     smallint,
        l_char         char(1),
        l_resultado    smallint, 
        l_mensagem     char(60)

 
 let l_emeviacod = lr_datkemevia.emeviacod
 
 call ctc17m00_input("M", lr_datkemevia.*) returning l_cancelou, lr_datkemevia.*
 
 if l_cancelou then
    call ctc17m00_mostra(l_emeviacod) returning lr_datkemevia.*
 else
    whenever error continue
    execute pctc17m00006 using lr_datkemevia.emeviades, lr_datkemevia.emeviapri,
                               lr_datkemevia.emeviasit, g_issk.empcod,
                               g_issk.funmat, lr_datkemevia.emeviacod
    whenever error stop
    
    if sqlca.sqlcode <> 0 then
       error 'Erro UPDATE pctc17m00006 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
       error 'CTC17M00 / ctc17m00_modificar() / ', lr_datkemevia.emeviades, ' / ',
                                                   lr_datkemevia.emeviapri, ' / ',
                                                   lr_datkemevia.emeviasit, ' / ',
                                                   g_issk.empcod, ' / ',
                                                   g_issk.funmat, ' / ',
                                                   lr_datkemevia.emeviacod sleep 2
       initialize lr_datkemevia to null
    else
       let lr_datkemevia.atldat = today
       call cty08g00_nome_func(g_issk.empcod, g_issk.funmat, "F") returning
                               l_resultado, l_mensagem, lr_datkemevia.funnomatl
                               
       if l_resultado <> 1 then
         error l_mensagem sleep 2
       end if
       display by name lr_datkemevia.atldat, lr_datkemevia.funnomatl
       prompt "Alteracao efetuada com sucesso, tecle <ENTER>" for char l_char
       
    end if
 end if

 return lr_datkemevia.*

end function

#-----------------------------------
function ctc17m00_input(l_operacao, lr_datkemevia)
#-----------------------------------
 define l_operacao    char(1), ## A - Alteracao, I - Inclusao
        l_emeviacod   like datkemevia.emeviacod,
        l_cancelou    smallint,
        l_qtd_depto   smallint,
        l_i           smallint,
        l_aux         char(1)

 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record
      
 let l_cancelou = false
 
 if l_operacao = "M" then
    display by name lr_datkemevia.*
 end if
 
 input by name lr_datkemevia.emeviades, 
               lr_datkemevia.emeviapri, 
               lr_datkemevia.emeviasit  without defaults
               
    before field emeviades               
       display by name lr_datkemevia.emeviades attribute(reverse)
    
    after field emeviades    
       display by name lr_datkemevia.emeviades
       if lr_datkemevia.emeviades is null then
          next field emeviades
       end if

       #Priscila - 20/01/06
       #o campo emeviades podera ter apenas 10 caracteres(mesmo sendo 20 na 
       # tabela) pois o valor cadastrado, sera utilizado para pesquisa na 
       # tela cts06g03 e lá teremos apenas 10 posicoes de caracteres
       # nao diminui o tamanho em tela, pois os antigos deverao continuar
       # sendo exibidos
       for l_i = 11 to 20
           let l_aux = lr_datkemevia.emeviades[l_i]
           display "emeviades[", l_i, "]:", l_aux                        
           if lr_datkemevia.emeviades[l_i] is not null and 
              lr_datkemevia.emeviades[l_i] <> " " then
              error "Descricao via emergencial deve ter ate 10 caracteres!!"
              next field emeviades
           end if
       end for


    before field emeviapri
       display by name lr_datkemevia.emeviapri attribute(reverse)
       
    after field emeviapri
       display by name lr_datkemevia.emeviapri 
       
       if (fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") or
           fgl_lastkey() = fgl_keyval("previous")) then
          next field previous
       end if
       if lr_datkemevia.emeviapri is null then
          next field emeviapri
       end if
       
       case lr_datkemevia.emeviapri
          when 1
             let lr_datkemevia.emeviaprides = 'Alta'
          when 2
             let lr_datkemevia.emeviaprides = 'Media'
          when 3
             let lr_datkemevia.emeviaprides = 'Baixa'
          otherwise
             error "Prioridade de atendimento somente 01 - Alta, 02 - Media ou 03 - Baixa" 
             next field emeviapri
       end case
       display by name lr_datkemevia.emeviaprides
       
    before field emeviasit 
       display by name lr_datkemevia.emeviasit attribute(reverse)
       
    after field emeviasit
       display by name lr_datkemevia.emeviasit
       if (fgl_lastkey() = fgl_keyval("up") or
           fgl_lastkey() = fgl_keyval("left") or
           fgl_lastkey() = fgl_keyval("previous")) then
          next field previous
       end if

       if lr_datkemevia.emeviasit is null then
          next field emeviasit
       end if
       
       case lr_datkemevia.emeviasit
          when "A"
             let lr_datkemevia.emeviasitdes = 'Ativa'
          when "C"
             let lr_datkemevia.emeviasitdes = 'Cancelada'
          otherwise
             error "Situacao somente A - Ativa ou C - Cancelada"
             next field emeviasit
       end case  
       display by name lr_datkemevia.emeviasitdes  

    on key(interrupt, control-c, f17)
       let int_flag = true
       exit input
 end input

 if int_flag then
    let int_flag = false
    let l_cancelou = true
    initialize lr_datkemevia to null
 end if
 
 return l_cancelou, lr_datkemevia.*
 
end function

#-------------------------
function ctc17m00_incluir()
#-------------------------
 define l_emeviacod    like datkemevia.emeviacod,
        l_cancelou     smallint,
        l_char         char(1),
        l_today        date,
        l_resultado    smallint,
        l_mensagem     char(60)  
        
 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record
 
 initialize lr_datkemevia to null
 display by name lr_datkemevia.*
 let l_today = today
 
 open cctc17m00007
 whenever error continue
 fetch cctc17m00007 into l_emeviacod
 whenever error stop
 
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let l_emeviacod = 1
    else
       error 'Erro SELECT cctc17m00007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
       error 'CTC17M00 / ctc17m00_incluir() ' sleep 2
       initialize lr_datkemevia to null        
       display by name lr_datkemevia.*
       return
    end if
 end if
 
 if l_emeviacod is null or l_emeviacod = 0 then
    let l_emeviacod = 1
 else
    let l_emeviacod = l_emeviacod + 1
 end if
 
 call ctc17m00_input("I", lr_datkemevia.*) returning l_cancelou, lr_datkemevia.*
 
 if not l_cancelou then
    whenever error continue
    execute pctc17m00008 using l_emeviacod, lr_datkemevia.emeviades, lr_datkemevia.emeviapri,
                               lr_datkemevia.emeviasit, g_issk.empcod, g_issk.funmat,
                               g_issk.empcod, g_issk.funmat
    whenever error stop
    if sqlca.sqlcode <> 0 then
          error 'Erro INSERT pctc17m00008 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTC17M00 / ctc17m00_incluir() / ', l_emeviacod, ' / ',
                                                    lr_datkemevia.emeviades, ' / ',
                                                    lr_datkemevia.emeviapri, ' / ',
                                                    lr_datkemevia.emeviasit, ' / ',
                                                    g_issk.empcod, ' / ',
                                                    g_issk.funmat, ' / ',
                                                    g_issk.empcod, g_issk.funmat sleep 2
          initialize lr_datkemevia to null
          display by name lr_datkemevia.*
    else
       display l_emeviacod to emeviacod 
       call cty08g00_nome_func(g_issk.empcod, g_issk.funmat, "F") returning    
                               l_resultado, l_mensagem,lr_datkemevia.funnomatl  
       
       let lr_datkemevia.funnomcad = lr_datkemevia.funnomatl 
                                                             
       display l_today         to caddat                      
       display l_today         to atldat                      
       display by name lr_datkemevia.funnomatl                                       
       display by name lr_datkemevia.funnomcad               
       
       prompt "Inclusao efetuada com sucesso, tecle <ENTER>" for char l_char
       
       call ctc17m01(l_emeviacod, lr_datkemevia.emeviades)
    end if  
 end if

end function

#------------------------------------
function ctc17m00_excluir(l_emeviacod)
#------------------------------------
 define l_emeviacod  like datkemevia.emeviacod,
        l_qtd_depto  smallint,
        l_opc        char(1),
        l_retorno    smallint,
        l_resultado  smallint,
        l_mensagem   char(60)
 
 let l_opc = null
 let l_retorno = false
 call ctc17m01_qtd_depto(l_emeviacod) returning l_resultado,
                                                l_mensagem,
                                                l_qtd_depto
 if l_resultado <> 1 then
    error l_resultado sleep 2
 end if

 if l_qtd_depto > 0 then
    error "Existem departamentos relacionados a esta via"
 else
    while true
       prompt "Confirma exclusao S/N? " for l_opc
       let l_opc = upshift(l_opc)
       
       if l_opc = "S" or l_opc = "N" or int_flag and 
          l_opc is not null then
          exit while
       end if
    end while
    
    if l_opc = "S" and not int_flag then
       whenever error continue
       execute pctc17m00009 using l_emeviacod
       whenever error stop
       
       if sqlca.sqlcode <> 0 then
          error 'Erro delete pctc17m00009 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
          error 'CTC17M00 / ctc17m00_excluir() ' sleep 2
          let l_retorno = false
       else
          let l_retorno = true
       end if
    else
       let int_flag = false
       let l_retorno = false
    end if
 end if

 return l_retorno

end function

#-------------------------
function ctc17m00_proximo(l_emeviacod)
#-------------------------
 define l_emeviacod   like datkemevia.emeviacod
 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record
 
 initialize lr_datkemevia to null

 open cctc17m00004 using l_emeviacod
 
 whenever error continue
 fetch cctc17m00004 into l_emeviacod
 whenever error stop
 
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error "Voce esta no ultimo registro"
    else
       error 'Erro SELECT cctc17m00004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
       error 'CTC17M00 / ctc17m00_proximo() / ', l_emeviacod sleep 2
       let l_emeviacod = null
    end if
 end if

 if l_emeviacod is not null then
    call ctc17m00_mostra(l_emeviacod) returning lr_datkemevia.*
 end if

 return lr_datkemevia.*

end function

#--------------------------
function ctc17m00_anterior(l_emeviacod)
#--------------------------
 define l_emeviacod    like datkemevia.emeviacod
 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record
 
 initialize lr_datkemevia to null
 
 open cctc17m00005 using l_emeviacod
 
 whenever error continue
 fetch cctc17m00005 into l_emeviacod
 whenever error stop
 
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error "Voce esta no primeiro registro"
    else
       error 'Erro SELECT cctc17m00005 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
       error 'CTC17M00 / ctc17m00_anterior() / ', l_emeviacod sleep 2
       let l_emeviacod = null
    end if
 end if
 
 if l_emeviacod is not null then
    call ctc17m00_mostra(l_emeviacod) returning lr_datkemevia.*
 end if

 return lr_datkemevia.*

end function

#-----------------------------------
function ctc17m00_mostra(l_emeviacod)
#-----------------------------------
 define l_emeviacod    like datkemevia.emeviacod

 define lr_datkemevia  record
        emeviacod      like datkemevia.emeviacod
       ,emeviades      like datkemevia.emeviades
       ,emeviapri      like datkemevia.emeviapri
       ,emeviaprides   char(05)
       ,emeviasit      like datkemevia.emeviasit
       ,emeviasitdes   char(09)
       ,caddat         like datkemevia.caddat
       ,funnomcad      char(20)
       ,atldat         like datkemevia.atldat
       ,funnomatl      char(20)
       ,obs            char(55)
 end record
 define l_cademp       like datkemevia.cademp,
        l_cadmat       like datkemevia.cadmat,
        l_atlemp       like datkemevia.atlemp,
        l_atlmat       like datkemevia.atlmat,
        l_resultado    smallint,  
        l_mensagem     char(60),
        l_qtd_depto    smallint
 
 let lr_datkemevia.emeviacod = l_emeviacod
 let l_qtd_depto = null
 
 open cctc17m00003 using l_emeviacod
 
 whenever error continue
 fetch cctc17m00003 into lr_datkemevia.emeviades,
                         lr_datkemevia.emeviapri,
                         lr_datkemevia.emeviasit,
                         lr_datkemevia.caddat,
                         l_cademp,
                         l_cadmat,
                         lr_datkemevia.atldat,
                         l_atlemp,
                         l_atlmat
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       error 'Erro SELECT cctc17m00003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]  sleep 2
       error 'CTC17M00 / ctc17m00_mostra() / ', l_emeviacod sleep 2
       initialize lr_datkemevia to null
       return lr_datkemevia.*
    end if 
 end if 
 
 case lr_datkemevia.emeviapri
    when 1
       let lr_datkemevia.emeviaprides = "Alta"
    when 2
       let lr_datkemevia.emeviaprides = "Media"
    when 3
       let lr_datkemevia.emeviaprides = "Baixa"
 end case

 case lr_datkemevia.emeviasit
    when "A"
       let lr_datkemevia.emeviasitdes = "Ativa"
    when "C"
       let lr_datkemevia.emeviasitdes = "Cancelada"
 end case

 call cty08g00_nome_func(l_cademp, l_cadmat, "F") returning
                         l_resultado, l_mensagem, lr_datkemevia.funnomcad
                         
 if l_resultado <> 1 then
   error l_mensagem sleep 2
 end if
 
 call cty08g00_nome_func(l_atlemp, l_atlmat, "F") returning
                         l_resultado, l_mensagem, lr_datkemevia.funnomatl

 call ctc17m01_qtd_depto(lr_datkemevia.emeviacod) returning l_resultado,
                                                            l_mensagem,
                                                            l_qtd_depto
 if l_resultado <> 1 then
    error l_resultado sleep 2
 end if
 
 if l_qtd_depto = 0 then
    let lr_datkemevia.obs = "NAO EXISTE(M) DEPARTAMENTO(S) PARA ESTA VIA EMEGENCIAL"
 else
    let lr_datkemevia.obs = "EXISTE(M) ", l_qtd_depto using "<<<<<"
    let lr_datkemevia.obs = lr_datkemevia.obs clipped, " DEPARTAMENTO(S) PARA ESTA VIA EMEGENCIAL"
 end if
 
 display by name lr_datkemevia.*
 
 return lr_datkemevia.*

end function
