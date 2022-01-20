###########################################################################
# Nome do Modulo: ctc63m00                               Helder Oliveira  #
#                                                        Humberto Santos  #
# Cadastro de Menu                                               Jul/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
# Data         Autor         PSI             Descrição                    #
# -----------  ------------- -------------   ---------------------------- #
#                                                                         #
#-------------------------------------------------------------------------#
#                                                                         #
###########################################################################
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"


  define m_prep_ctc63m00  smallint
  define m_operacao       char(1)
  define m_errflg         char(1)
  define m_confirma       char(1)
  define m_data           date
  define m_aux_codigo     char(4)

  define a_ctc63m00 array[8000] of record
            codigo    char(4)
           ,sisdes    char(50)
           ,prgnom    like datkc24mnuacs.prgnom
  end record

  define r_ctc63m00 record
         atlemp     like datkitacia.atlemp
        ,atlmat     like datkitacia.atlmat
        ,atldat     like datkitacia.atldat
        ,funnom     like isskfunc.funnom
 end record

#==============================================================================
function ctc63m00_prepare()
#==============================================================================
 define l_sql char(5000)

 let l_sql =  '  select mnucod     '
             ,'       , sisdes    '
             ,'       , prgnom     '
             ,'    from datkc24mnuacs     '
             ,'  order by mnucod   '

 prepare pctc63m00001 from l_sql
 declare cctc63m00001 cursor for pctc63m00001


 let l_sql =   ' select 1      '
              ,'   from datrc24mnufun       '
              ,'  where mnucod  = ?  '
 prepare pctc63m00002 from l_sql
 declare cctc63m00002 cursor for pctc63m00002


 let l_sql =   '  insert into datkc24mnuacs (  mnucod,   '
                                       ,'      sisdes,   '
                                       ,'      prgnom,   '
                                       ,'      atlusrtip,'
                                       ,'      atlemp,   '
                                       ,'      atlmat,   '
                                       ,'      atldat )  '
                                       ,'   values(?,?,?,?,?,?,?)  '
 prepare pctc63m00003 from l_sql


 let l_sql =   '  update datkc24mnuacs  set     sisdes  = ?,      '
                                          ,'    prgnom   = ?,     '
                                          ,'    atlusrtip  = ?,   '
                                          ,'    atlemp     = ?,   '
                                          ,'    atlmat     = ?,   '
                                          ,'    atldat     = ?    '
                                          ,'   where mnucod   = ? '
 prepare pctc63m00004 from l_sql

 let l_sql =  'select count(sisdes )  '
             ,'from datkc24mnuacs           '
             ,'where sisdes  = ?      '
 prepare pctc63m00005 from l_sql
 declare cctc63m00005 cursor for pctc63m00005


 let l_sql =  'delete datkc24mnuacs      '
              ,'where mnucod  = ?  '
 prepare pctc63m00006 from l_sql

 let l_sql =  'select count(mnucod )   '
             ,'from datkc24mnuacs            '
             ,'where mnucod  = ?       '
 prepare pctc63m00007 from l_sql
 declare cctc63m00007 cursor for pctc63m00007

 let l_sql =  '  select sisdes     '
             ,'    from datkc24mnuacs    '
             ,' where mnucod  = ?  '

 prepare pctc63m00008 from l_sql
 declare cctc63m00008 cursor for pctc63m00008

 let l_sql = '   select atlemp              '
            ,'         ,atlmat              '
            ,'         ,atldat              '
            ,'     from datkc24mnuacs       '
            ,'    where mnucod  =  ?  '
 prepare pctc63m00010 from l_sql
 declare cctc63m00010 cursor for pctc63m00010

 let l_sql =  'select count(prgnom)    '
             ,'  from datkc24mnuacs       '
             ,' where prgnom  = ?      '
             ,'   and mnucod <> ?   '
 prepare pctc63m00011 from l_sql
 declare cctc63m00011 cursor for pctc63m00011

  let l_sql =  'select prgnom            '
             ,'from datkc24mnuacs           '
             ,'where mnucod  = ?      '
 prepare pctc63m00012 from l_sql
 declare cctc63m00012 cursor for pctc63m00012

 let l_sql = ' select funnom,       '
           , '        dptsgl,       '
           , '        rhmfunsitcod, '
           , '        empcod,       '
           , '        usrtip        '
             ,'      from isskfunc        '
           , '  where funmat = ?    '
 prepare pctc63m00013 from l_sql
 declare cctc63m00013 cursor for pctc63m00013
 let l_sql = " INSERT INTO datrc24mnufun (funmat,empcod,usrtip,mnucod,atlusrtip,atlemp,atlmat,atldat) "
           , " VALUES (?,?,?,?,?,?,?,?) "
 prepare pctc63m00014 from l_sql
 let l_sql = ' select mnucod         '
           , '   from datkc24mnuacs   '

 prepare pctc63m00015 from l_sql
 declare cctc63m00015 cursor for pctc63m00015

 let l_sql = ' select mnucod         '
           , '   from datrc24mnufun  '
           , '  where funmat = ?     '
           , '    and empcod = ?     '
           , '    and usrtip = ?     '
           , '    and mnucod = ?     '  
 prepare pctc63m00016 from l_sql
 declare cctc63m00016 cursor for pctc63m00016

 let l_sql = ' delete datrc24mnufun  '
           , '  where funmat = ?     '
 prepare pctc63m00017 from l_sql

 let m_prep_ctc63m00 = 1

end function

#==============================================================================
function ctc63m00()
#==============================================================================
  define l_index       smallint
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
  define l_tamanho     smallint
  define i             smallint
  define l_flag        smallint   #verifica se existe letras no campo codigo
  define l_flg         smallint   #verifica se foi up down
  define l_sisdes      char(50)
  define l_prox_arr    smallint
  define l_err         smallint
  define l_prgnom      like datkc24mnuacs.prgnom

  initialize a_ctc63m00 to null
  initialize r_ctc63m00.* to null
  let l_err = 0
  let int_flag = false
  let l_flg = 0
  let m_data = today


  if m_prep_ctc63m00 <> 1 or 
     m_prep_ctc63m00 is null then
    call ctc63m00_prepare()
  end if

  open window w_ctc63m00 at 6,2 with form 'ctc63m00'
             attribute(form line first, message line last,comment line last - 1, border)

  display 'CADASTRO DE MENU' at 1,29

  while true
    let l_index = 1

    whenever error continue
      open cctc63m00001
    whenever error stop

    foreach cctc63m00001 into a_ctc63m00[l_index].codigo,
                                a_ctc63m00[l_index].sisdes,
                                a_ctc63m00[l_index].prgnom

       let l_index = l_index + 1

       if l_index > 3000 then
          error " Limite excedido! Foram encontrados mais de 3000 Registros!"
          exit foreach
       end if

#    message "      (F1)-Inclui   (F2)-Exclui   (F5)-Associar Matricula   (F17)-Abandona  "
    message "(F1)Inclui (F2)Exclui (F5)Associar Matricula (F6)AcessoTotal (F17)Abandona"
    end foreach

    let arr_aux = l_index
    if arr_aux = 1  then
       error "Nao foi encontrado nenhum registro, inclua novos!"
    end if

    let m_errflg = "N"
    let l_flag = true

    call set_count(arr_aux - 1)
    input array a_ctc63m00 without defaults from sctc63m00.*

         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()

             if arr_aux <= arr_count()  then
                let m_operacao = "p"
             end if

             whenever error continue
             open cctc63m00008 using a_ctc63m00[arr_aux].codigo
             fetch cctc63m00008 into l_sisdes
             whenever error stop
             next field codigo

         #------------------
          before insert
         #------------------
              let m_operacao = 'i'
              initialize a_ctc63m00[arr_aux] to null
              display a_ctc63m00[arr_aux].codigo     to  sctc63m00[scr_aux].codigo

        #--------------------
         before field codigo
        #--------------------
               if m_operacao <> 'i' then
                   call ctc63m00_dados_alteracao(a_ctc63m00[arr_aux].codigo)
               end if

               if a_ctc63m00[arr_aux].codigo is null then
                  let m_operacao = 'i'
               else
                  display a_ctc63m00[arr_aux].* to sctc63m00[scr_aux].* attribute(reverse)
                  let m_aux_codigo = a_ctc63m00[arr_aux].codigo
               end if

        #--------------------
         after field codigo
        #--------------------
              display a_ctc63m00[arr_aux].* to sctc63m00[scr_aux].*
              
              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let a_ctc63m00[arr_aux].codigo = ''
                 display a_ctc63m00[arr_aux].codigo to sctc63m00[scr_aux].codigo

                 let l_flg = 1

                 let m_operacao = "p"
              else
                if a_ctc63m00[arr_aux].codigo is null then
                  if  m_operacao = 'i' then
                     error " Informe o codigo do Menu"
                     next field codigo
                  end if
                else
                  let l_tamanho = length(a_ctc63m00[arr_aux].codigo)
                  for i = 1 to l_tamanho
                     if a_ctc63m00[arr_aux].codigo[i] not matches'[0-9]' then
                       let l_flag = false
                     end if
                  end for

                  if l_flag = false then
                      error "O Codigo so pode conter Numeros"
                      let a_ctc63m00[arr_aux].codigo = null
                      let l_flag = true
                      next field codigo
                  end if

                  if m_operacao = 'i'then
                     whenever error continue
                        open cctc63m00007 using a_ctc63m00[arr_aux].codigo
                        fetch cctc63m00007 into l_count
                     whenever error stop

                     if l_count > 0 then
                        initialize a_ctc63m00[arr_aux] to null
                        error " Codigo de Menu ja cadastrado!"
                        close cctc63m00007
                        next field codigo
                     end if
                     if a_ctc63m00[arr_aux].sisdes is null then
                        next field  sisdes
                  end if
                   end if
                end if
              end if
              if a_ctc63m00[arr_aux].sisdes is not null then
                 let a_ctc63m00[arr_aux].codigo = m_aux_codigo
                 display a_ctc63m00[arr_aux].codigo to sctc63m00[scr_aux].codigo
              end if

        #-------------------------
          before field sisdes
        #-------------------------
                 display a_ctc63m00[arr_aux].sisdes to
                         sctc63m00[scr_aux].sisdes attribute(reverse)

                 if a_ctc63m00[arr_aux].codigo is null then
                    let a_ctc63m00[arr_aux].sisdes = null
                    display a_ctc63m00[arr_aux].sisdes to
                            sctc63m00[scr_aux].sisdes
                    next field codigo
                 end if


        #-------------------------
          after field sisdes
        #-------------------------
              display a_ctc63m00[arr_aux].sisdes to
                      sctc63m00[scr_aux].sisdes attribute(reverse)

            # Retirar espaços em branco a esqeurada e a direita
              let a_ctc63m00[arr_aux].sisdes = ctc91m00_trim(a_ctc63m00[arr_aux].sisdes)
              display a_ctc63m00[arr_aux].sisdes to
                      sctc63m00[scr_aux].sisdes
            # -

              if l_flg = 1 then
                 let l_prox_arr = arr_aux + 1

                 if a_ctc63m00[l_prox_arr].codigo is not null and
                    a_ctc63m00[l_prox_arr].sisdes is null then
                    let a_ctc63m00[l_prox_arr].codigo = null
                 end if
              end if

              let l_count = 0


              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then

                 let l_flg = 1

                 if m_operacao = "i" then
                    let a_ctc63m00[arr_aux].codigo    = null
                    let a_ctc63m00[arr_aux].sisdes = null
                    let a_ctc63m00[arr_aux].prgnom  = null
                    display a_ctc63m00[arr_aux].* to
                            sctc63m00[scr_aux].*
                    next field codigo        
                 else
                    let m_operacao = "p"
                 end if
              else
                if a_ctc63m00[arr_aux].sisdes is null then
                   if m_operacao <> " " then
                      error " Informe a descricao do Menu"
                      next field sisdes
                   end if
                else
                   if m_operacao = 'i' then
                      whenever error continue
                      open cctc63m00005 using a_ctc63m00[arr_aux].sisdes
                      fetch cctc63m00005 into l_count
                      whenever error stop
              
                      if l_count > 0 then
                        error "Este Menu ja foi cadastrado com outro codigo"
                        next field sisdes
                     end if
                   end if
                end if
             end if
             message "(F1)Inclui (F2)Exclui (F5)Associar Matricula (F6)AcessoTotal (F17)Abandona"
               
             
        #-------------------------
          before field prgnom
        #-------------------------
                 display a_ctc63m00[arr_aux].prgnom to
                         sctc63m00[scr_aux].prgnom attribute(reverse)

                 let l_prgnom = a_ctc63m00[arr_aux].prgnom

                 if a_ctc63m00[arr_aux].codigo is null then
                    let a_ctc63m00[arr_aux].prgnom = null
                    display a_ctc63m00[arr_aux].prgnom to
                            sctc63m00[scr_aux].prgnom
                    next field codigo
                 end if


        #-------------------------
          after field prgnom
        #-------------------------
              display a_ctc63m00[arr_aux].prgnom to
                      sctc63m00[scr_aux].prgnom

              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then

                 let l_flg = 1

                 if m_operacao = "i" then
                    let a_ctc63m00[arr_aux].codigo    = null
                    let a_ctc63m00[arr_aux].sisdes = null
                    let a_ctc63m00[arr_aux].prgnom  = null
                    display a_ctc63m00[arr_aux].* to
                            sctc63m00[scr_aux].*
                 else
                    let m_operacao = "p"
                    let a_ctc63m00[arr_aux].prgnom = l_prgnom
                 end if

                 next field codigo
              end if
              
              if a_ctc63m00[arr_aux].prgnom is null then
                if m_operacao <> " " then
                   error " Informe o Programa! "
                   next field prgnom
                end if
              end if
              message "(F1)Inclui (F2)Exclui (F5)Associar Matricula (F6)AcessoTotal (F17)Abandona"
                              
        #--------------------
          after row
        #--------------------
               whenever error continue

               case
                   when m_operacao = 'i'
                      call ctc63m00_insert_dados(arr_aux)

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc63m00_update_pergunta_altera(arr_aux, scr_aux) returning l_err
                      if l_err = 1 then
                         next field sisdes
                      end if
               end case

               if m_errflg = "S"  then
                  let int_flag = true
                  exit input
               end if

               whenever error stop

               let m_operacao = " "

        #--------------------
          before delete
        #--------------------
               let m_operacao = "d"

               initialize m_confirma to null
               
                  call cts08g01("A"
                               ,"S"
                               ,"CONFIRMA A REMOCAO"
                               ,"DO MENU ?"
                               ," "
                               ," " )
                      returning m_confirma
                  
                  if m_confirma = "S"  then
                     let m_errflg = "N"
                  
                     open cctc63m00002 using a_ctc63m00[arr_aux].codigo
                     fetch cctc63m00002
                     
                     if sqlca.sqlcode = 100 then
                        begin work
                     
                        whenever error continue
                        execute pctc63m00006 using a_ctc63m00[arr_aux].codigo
                     
                        if sqlca.sqlcode <> 0  then
                               error " Erro (", sqlca.sqlcode, ") na remocao do Menu!"
                     
                               let m_errflg = "S"
                               whenever error stop
                        end if
                     
                        whenever error stop
                        
                        if m_errflg = "S"  then
                           rollback work
                        else
                           error "Registro Apagado"
                           commit work
                        end if
                     else
                         if sqlca.sqlcode = 0 then
                            display a_ctc63m00[arr_aux].* to sctc63m00[scr_aux].*
                            error "Existem matriculas vinculadas a este menu! Remova-as primeiro."
                            exit input                   
                         else
                            error "Erro (",sqlca.sqlcode,") na selecao de dados datkc24mnuacs. Avise a Informatica"
                         end if 
                     end if
                  else
                     clear form
                     error " Remocao Cancelada!"
                     exit input
                  end if

               let m_operacao = " "
               initialize a_ctc63m00[arr_aux].*   to null
               display a_ctc63m00[arr_aux].* to sctc63m00[scr_aux].*

          #--------------------
            on key (F5)
          #--------------------
               if a_ctc63m00[arr_aux].codigo    is not null and
                  a_ctc63m00[arr_aux].sisdes is not null and
                  a_ctc63m00[arr_aux].prgnom  is not null then
                  call  ctc63m01_input_array(a_ctc63m00[arr_aux].codigo)
               end if

          #--------------------
            on key (F6)
          #--------------------
              open window w_ctc63m00_1 at 7,14 with form "ctc63m00a"
                attribute(form line first, message line last,comment line last - 1, border)
              message '          (F8)-Confirma     (F17)-Abandona'  
              menu "ACESSO TOTAL"
                command "Liberar"
                        " Liberar Acesso Total para uma Matricula"
                        message '          (F8)-Confirma     (F17)-Abandona' 
                        call ctc63m00_acesso_total(1)
                command "Excluir"
                        " Excluir todos os acessos de uma Matrícula"
                        message '          (F8)-Confirma     (F17)-Abandona' 
                        call ctc63m00_acesso_total(2)
                 command key (interrupt) "Voltar" 
                         " Retorna a tela anterior"
                         exit menu
             end menu       
             close window w_ctc63m00_1
             display a_ctc63m00[arr_aux].* to sctc63m00[scr_aux].* attribute(reverse)
             message "(F1)Inclui (F2)Exclui (F5)Associar Matricula (F6)AcessoTotal (F17)Abandona"
          #--------------------
            on key (accept)
          #--------------------
               continue input

          #--------------------
            on key (interrupt, control-c)
          #--------------------
              let int_flag = true
              exit input

       end input

       if int_flag  then
          let int_flag = false
          exit while
       end if

  end while

  let int_flag = false

 close window w_ctc63m00

end function

#==============================================================================
function ctc63m00_update_pergunta_altera(arr_aux, scr_aux)
#==============================================================================

  define arr_aux       smallint
  define scr_aux       smallint
  define l_sisdes   	 char(50)
  define l_count       smallint
  define l_err         smallint
  define l_prgnom      like datkc24mnuacs.prgnom

     whenever error continue
     open cctc63m00008 using a_ctc63m00[arr_aux].codigo
     fetch cctc63m00008 into l_sisdes
     whenever error stop

     if l_sisdes <> a_ctc63m00[arr_aux].sisdes  then
       whenever error continue
        open cctc63m00005 using a_ctc63m00[arr_aux].sisdes
        fetch cctc63m00005 into l_count
       whenever error stop
       if l_count > 0 then
          error "Este Menu ja foi cadastrada com outro codigo"
          let l_err = 1
          return l_err
       end if
     end if
     
     whenever error continue
       open cctc63m00012 using a_ctc63m00[arr_aux].codigo
       fetch cctc63m00012 into l_prgnom
     whenever error stop
     
     if l_prgnom <> a_ctc63m00[arr_aux].prgnom or
        l_sisdes <> a_ctc63m00[arr_aux].sisdes then
          let l_err = 0
          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DO MENU ?"
                       ," "
                       ," ")
            returning m_confirma

           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc63m00[arr_aux].sisdes = l_sisdes clipped
              let a_ctc63m00[arr_aux].prgnom = l_prgnom clipped
              display a_ctc63m00[arr_aux].sisdes to sctc63m00[scr_aux].sisdes
              display a_ctc63m00[arr_aux].prgnom to sctc63m00[scr_aux].prgnom
           end if
     end if

     if m_operacao = 'a' then

        begin work
        whenever error continue

          execute pctc63m00004 using   a_ctc63m00[arr_aux].sisdes
                                     , a_ctc63m00[arr_aux].prgnom
                                     , g_issk.usrtip
                                     , g_issk.empcod
                                     , g_issk.funmat
                                     , m_data
                                     , a_ctc63m00[arr_aux].codigo

          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "Menu Alterado com Sucesso!"
             commit work
          end if
    end if

return l_err

end function

#=======================================
function ctc63m00_insert_dados(arr_aux)
#=======================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint

begin work
  whenever error continue
  open cctc63m00007 using a_ctc63m00[arr_aux].codigo
  fetch cctc63m00007 into l_count
  whenever error stop

  if l_count = 0 then

     execute pctc63m00003 using a_ctc63m00[arr_aux].codigo
                                ,a_ctc63m00[arr_aux].sisdes
                                ,a_ctc63m00[arr_aux].prgnom
                                ,g_issk.usrtip
                                ,g_issk.empcod
                                ,g_issk.funmat
                                ,m_data
                                
     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "Menu Incluido com Sucesso!"
        commit work
    end if
  end if

end function

#==============================================================================
function ctc63m00_dados_alteracao(l_cod)
#==============================================================================
define l_cod char(4)

   initialize r_ctc63m00.* to null

   if m_prep_ctc63m00 <> 1 or 
      m_prep_ctc63m00 is null then
      call ctc63m00_prepare()
   end if
   whenever error continue
   open cctc63m00010 using l_cod
   fetch cctc63m00010 into  r_ctc63m00.atlemp
                           ,r_ctc63m00.atlmat
                           ,r_ctc63m00.atldat
   whenever error stop

    
   call ctc91m00_func(r_ctc63m00.atlemp, r_ctc63m00.atlmat)
        returning r_ctc63m00.funnom

   display by name  r_ctc63m00.atldat
                   ,r_ctc63m00.funnom

end function
#==============================================================================
function ctc63m00_acesso_total(l_param)
#==============================================================================
 define l_param smallint #1 - Libera acesso total / 2 - exclui acessos 
 define r_ctc63m00_total record
       funmat  like isskfunc.funmat
      ,funnom  like isskfunc.funnom
      ,dptsgl  like isskfunc.dptsgl
      ,stt     like isskfunc.rhmfunsitcod
      ,emp     like isskfunc.empcod
      ,tipo    like isskfunc.usrtip
 end record
define l_titulo char(38)
define l_mnucod   like datkc24mnuacs.mnucod
  if m_prep_ctc63m00 <> 1 or 
     m_prep_ctc63m00 is null then
    call ctc63m00_prepare()
  end if
 let l_titulo = ''
 initialize r_ctc63m00_total.* to null
 if l_param = 1 then 
    let l_titulo = "LIBERACAO DE ACESSO TOTAL DE MATRICULA"
 else
    let l_titulo = "  EXCLUSAO DE ACESSOS DA MATRICULA"
 end if 
 input by name r_ctc63m00_total.*
     #--------------------
      before field funmat 
     #--------------------
       display r_ctc63m00_total.funmat to funmat attribute(reverse)
       display l_titulo to titulo attribute(reverse)
     #--------------------
      after field funmat 
     #--------------------
        message '          (F8)-Confirma     (F17)-Abandona' 
        if r_ctc63m00_total.funmat is not null then
           open cctc63m00013 using r_ctc63m00_total.funmat  
           fetch cctc63m00013 into r_ctc63m00_total.funnom
                                 , r_ctc63m00_total.dptsgl
                                 , r_ctc63m00_total.stt
                                 , r_ctc63m00_total.emp
                                 , r_ctc63m00_total.tipo
            if sqlca.sqlcode = 100 then  
               error 'Matrícula não encontrada'
               next field funmat
            else
               if sqlca.sqlcode <> 0 then
                  error 'Erro (',sqlca.sqlcode,') na pesquisa da matricula (ctc63m00-isskfunc) Avise a Inf.'
                  exit input
               end if
            end if     
           display by name r_ctc63m00_total.*
           message '          (F8)-Confirma     (F17)-Abandona' 
           next field funmat 
        else
           error "Digite a Matrícula"
           message '          (F8)-Confirma     (F17)-Abandona' 
           next field funmat
        end if
     #--------------------
      on key (F8)
     #--------------------
        if r_ctc63m00_total.funmat  is null then
           error 'Digite uma Matricula'
           next field funmat
        end if       
        initialize m_confirma to null
        if l_param = 1 then       
           # LIBERAR ACESSO TOTAL
           call cts08g01("C"
                        ,"S"
                        ,"CONFIRMA A LIBERACAO TOTAL"
                        ,"DOS ACESSOS AOS MENUS PARA "
                        ,r_ctc63m00_total.funnom
                        ,"?" )
               returning m_confirma
           if m_confirma = "S"  then
              open cctc63m00015
              foreach cctc63m00015 into l_mnucod
                 open cctc63m00016 using r_ctc63m00_total.funmat
                                       , r_ctc63m00_total.emp
                                       , r_ctc63m00_total.tipo
                                       , l_mnucod
                 fetch cctc63m00016 
                 if sqlca.sqlcode = 100 then
                    whenever error continue
                     execute pctc63m00014 using r_ctc63m00_total.funmat
                                              , r_ctc63m00_total.emp
                                              , r_ctc63m00_total.tipo
                                              , l_mnucod
                                              , g_issk.usrtip         
                                              , g_issk.empcod
                                              , g_issk.funmat
                                              , m_data       
                    if sqlca.sqlcode <> 0 then 
                       error "Erro (",sqlca.sqlcode,") na insercao dos dados(datrc24mnufun)! Avise a inf!"
                    end if
                    whenever error stop
                 end if
              end foreach
              error 'Liberacao Total ao Acessos dos Menus Concluida' 
           else
              next field funmat
           end if
        else
          # EXCLUIR TODOS OS ACESSOS PARA ESSA MATRICULA
           call cts08g01("C"
                        ,"S"
                        ,"CONFIRMA A EXCLUSAO"
                        ,"DOS ACESSOS AOS MENUS PARA "
                        ,r_ctc63m00_total.funnom
                        ,"?" )
               returning m_confirma
           if m_confirma = "S"  then
              whenever error continue
                execute pctc63m00017 using r_ctc63m00_total.funmat     
                if sqlca.sqlcode <> 0 then 
                   error "Erro (",sqlca.sqlcode,") na exclusao dos dados(datrc24mnufun)! Avise a inf!"
                end if
              whenever error stop
              error 'Exclusao dos Acessos aos Menus Concluida' 
           else
              next field funmat
           end if        
        end if
     #--------------------
      on key (interrupt, control-c)
     #--------------------
      initialize r_ctc63m00_total.* to null
      let l_titulo = null
      display by name r_ctc63m00_total.*
      display l_titulo to titulo
      exit input
 end input
end function