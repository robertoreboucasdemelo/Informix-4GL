###########################################################################
# Nome do Modulo: ctc40m00                                Helder Oliveira #
#                                                                         #
# Cadastro de dominios                                           Ago/2011 #
###########################################################################
#                             ALTERACOES                                  #
#                             ----------                                  #
#   DATA         Analista               DESCRICAO                         #
#-------------------------------------------------------------------------#
# 12/08/2011   Helder, Meta             Reconstrucao do modulo atendendo  #
#                                        somente a tabela datkdominio     #
#                                        devido iddkdominio comportar     #
#                                        apenas 99 dominios. Reconstrucao #
#                                        para aumentar tambem ausabilidade#
#                                        do cadastro.                     #
#-------------------------------------------------------------------------#
###########################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_ctc40m00_prep smallint
define m_aux_codigo    char(4)
define m_operacao      char(1)
define m_errflg        char(1)
define m_confirma      char(1)
define m_data          date
define m_tabela        char(11)
define d_ctc40m00 record
       cponom like datkdominio.cponom
end record

 define a_ctc40m00    array[1000] of record
        cpocod        char(4)
       ,cpodes        char(50)
       ,atlult        like datkdominio.atlult
 end record
#==========================================================================
 function ctc40m00_prepare()
#==========================================================================
define l_sql char(5000)

   let l_sql = null

   let l_sql = ' SELECT cpocod      '
             , '      , cpodes      '
             , '      , atlult      '
             , '   FROM ',m_tabela
             , '  WHERE cponom = ?  '
             , '  ORDER BY cpocod   '
   prepare p_ctc40m00_001 from l_sql
   declare c_ctc40m00_001 cursor for p_ctc40m00_001
   let l_sql = ' SELECT cpodes      '
             , '   FROM ',m_tabela
             , '  WHERE cpocod = ?  '
             , '    AND cponom = ?  '
   prepare p_ctc40m00_002 from l_sql
   declare c_ctc40m00_002 cursor for p_ctc40m00_002
   let l_sql = ' SELECT count(cpocod) '
             , '   FROM ',m_tabela
             , '  WHERE cpocod = ?    '
             , '    AND cponom = ?  '
   prepare p_ctc40m00_003 from l_sql
   declare c_ctc40m00_003 cursor for p_ctc40m00_003
   let l_sql = ' SELECT count(cpodes) '
             , '   FROM ',m_tabela
             , '  WHERE cpodes = ?    '
             , '    AND cponom = ?  '
   prepare p_ctc40m00_004 from l_sql
   declare c_ctc40m00_004 cursor for p_ctc40m00_004
   let l_sql = ' INSERT INTO ',m_tabela
             , '  (cponom, cpocod, cpodes, atlult)  '
             , '  VALUES (?,?,?,?)                 '
   prepare p_ctc40m00_005 from l_sql
   let l_sql = ' UPDATE ',m_tabela
             , '    SET (cpodes, atlult) = (?,?) '
             , '  WHERE cponom = ?               '
             , '    AND cpocod = ?               '
   prepare p_ctc40m00_006 from l_sql
    let l_sql = ' DELETE ',m_tabela
             , '   WHERE cponom = ?   '
             , '     AND cpocod = ?   '
   prepare p_ctc40m00_007 from l_sql
   let l_sql = ' SELECT count(cpocod) '
              ,'   FROM ',m_tabela
              ,'  WHERE cponom = ?    '
   prepare p_ctc40m00_008 from l_sql
   declare c_ctc40m00_008 cursor for p_ctc40m00_008

   let m_ctc40m00_prep = true

 end function


#==========================================================================
 function ctc40m00()
#==========================================================================
 define ws            record
    sql               char (500),
    cpocod            char(4),
    cpocod1           char(4),
    cpodes            char(50),
    errflg            char (01),
    operacao          char (01),
    confirma          char (01)
 end record
 define l_index       smallint
 define arr_aux       smallint
 define scr_aux       smallint
 define l_count       smallint
 define l_tamanho     smallint
 define i             smallint
 define l_flag        smallint   #verifica se existe letras no campo codigo
 define l_flg         smallint   #verifica se foi up down
 define l_descricao   char(50)
 define l_prox_arr    smallint
 define l_err         smallint

 define l_cponom      like datkdominio.cponom
 define l_dominio     char(100)
 define l_cpocod      char(4)

 define l_conta_usuar smallint

 define l_countdat    int

 define l_texto       char(70)

 let l_err = 0
 let int_flag = false
 let l_flg = 0
 initialize ws.*       to null

 open window ctc40m00 at 06,02 with form "ctc40m00"
      attribute (form line first, message line last, comment line last - 1)

 message " (F17)Abandona"

 while not int_flag
    clear form

    input by name d_ctc40m00.cponom without defaults
       before field cponom
          display by name d_ctc40m00.cponom attribute (reverse)

       after  field cponom
          display by name d_ctc40m00.cponom
          let l_dominio = d_ctc40m00.cponom
          if d_ctc40m00.cponom is null then
             error " Informe a chave de dominio a ser pesquisada!"
             next field cponom
          end if

       on key (interrupt, control-c)
          let int_flag = true
          exit input
    end input

    if int_flag then
       exit while
    end if

    while true
       message " Aguarde, pesquisando..." attribute (reverse)

       initialize a_ctc40m00  to null

       call ctc40m00_busca_datk(d_ctc40m00.cponom)
            returning m_tabela
       call ctc40m00_prepare()

       open c_ctc40m00_001 using d_ctc40m00.cponom

       let arr_aux = 1

       foreach c_ctc40m00_001 into a_ctc40m00[arr_aux].cpocod,
                                   a_ctc40m00[arr_aux].cpodes,
                                   a_ctc40m00[arr_aux].atlult

          let arr_aux = arr_aux + 1

          if arr_aux > 1000  then
             error " Limite excedido! Foram encontrados mais de 1000 dominios!"
             exit foreach
          end if

       end foreach

       if arr_aux = 1  then
          message ""
          if cts08g01("C","S",
                      "NAO FOI ENCONTRADO NENHUM DOMINIO",
                      "PARA CHAVE INFORMADA!",
                      "",
                      "INICIA INCLUSAO DE DOMINIO?") = "N"  then
             exit while
          end if
       end if

       message "(F17)Abandona (F1)Inclui (F2)Exclui (F5)Seleciona (F8)Dados Atualizacao"

       call set_count(arr_aux - 1)

       input array a_ctc40m00 without defaults from s_ctc40m00.*
         #------------------
          before row
         #------------------
             let arr_aux = arr_curr()
             let scr_aux = scr_line()

             if arr_aux <= arr_count()  then
                let m_operacao = "p"
             end if
             whenever error continue
             open c_ctc40m00_002 using a_ctc40m00[arr_aux].cpocod,
                                       d_ctc40m00.cponom
             fetch c_ctc40m00_002 into l_descricao
             whenever error stop

         #------------------
          before insert
         #------------------
              let m_operacao = 'i'
              initialize a_ctc40m00[arr_aux] to null
              display a_ctc40m00[arr_aux].cpocod     to
                      s_ctc40m00[scr_aux].cpocod

         #--------------------
          before field cpocod
         #--------------------
               if a_ctc40m00[arr_aux].cpocod is null then
                  let m_operacao = 'i'
               else
                  display a_ctc40m00[arr_aux].cpocod to s_ctc40m00[scr_aux].cpocod attribute(reverse)
                  display a_ctc40m00[arr_aux].cpodes to s_ctc40m00[scr_aux].cpodes attribute(reverse)
                  let m_aux_codigo = a_ctc40m00[arr_aux].cpocod
               end if

         #--------------------
          after field cpocod
         #--------------------
              display a_ctc40m00[arr_aux].cpocod to s_ctc40m00[scr_aux].cpocod
              display a_ctc40m00[arr_aux].cpodes to s_ctc40m00[scr_aux].cpodes

              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let a_ctc40m00[arr_aux].cpocod = ''
                 display a_ctc40m00[arr_aux].cpocod to s_ctc40m00[scr_aux].cpocod
                 let l_flg = 1
                 let m_operacao = "p"
              else
                if a_ctc40m00[arr_aux].cpocod is null then
                  if  m_operacao = 'i' then
                     error " Informe o codigo do dominio"
                     next field cpocod
                  end if
                else
                  if m_operacao = 'i'then
                     let l_tamanho = length(a_ctc40m00[arr_aux].cpocod)
                     for i = 1 to l_tamanho
                        if a_ctc40m00[arr_aux].cpocod[i] not matches'[0-9]' then
                          let l_flag = false
                        end if
                     end for
                     if l_flag = false then
                         error "O Codigo So Pode Conter Numeros"
                         let a_ctc40m00[arr_aux].cpocod = null
                         let l_flag = true
                         next field cpocod
                     end if

                     whenever error continue
                        open c_ctc40m00_003 using a_ctc40m00[arr_aux].cpocod,
                                                  d_ctc40m00.cponom
                        fetch c_ctc40m00_003 into l_count
                     whenever error stop
                     if l_count > 0 then
                        initialize a_ctc40m00[arr_aux] to null
                        error " Codigo do dominio ja cadastrado!"
                        close c_ctc40m00_003
                        next field cpocod
                     end if
                     if a_ctc40m00[arr_aux].cpodes is null then
                        next field  cpodes
                     end if
                  end if
                end if
              end if
              if a_ctc40m00[arr_aux].cpodes is not null then
                 let a_ctc40m00[arr_aux].cpocod = m_aux_codigo
                 display a_ctc40m00[arr_aux].cpocod to s_ctc40m00[scr_aux].cpocod
              end if

        #-------------------------
          before field cpodes
        #-------------------------
                 display a_ctc40m00[arr_aux].cpodes to
                         s_ctc40m00[scr_aux].cpodes attribute(reverse)

                 if a_ctc40m00[arr_aux].cpocod is null then
                    let a_ctc40m00[arr_aux].cpodes = null
                    display a_ctc40m00[arr_aux].cpodes to
                            s_ctc40m00[scr_aux].cpodes
                    next field cpocod
                 end if
        #-------------------------
          after field cpodes
        #-------------------------
              display a_ctc40m00[arr_aux].cpodes to
                      s_ctc40m00[scr_aux].cpodes
              if l_flg = 1 then
                 let l_prox_arr = arr_aux + 1
                 if a_ctc40m00[l_prox_arr].cpocod is not null and
                    a_ctc40m00[l_prox_arr].cpodes is null then
                    let a_ctc40m00[l_prox_arr].cpocod = null
                 end if
              end if
              let l_count = 0
              if fgl_lastkey() = fgl_keyval("up")     or
                 fgl_lastkey() = fgl_keyval("left")   then
                 let l_flg = 1
                 if m_operacao = 'i' then
                    let a_ctc40m00[arr_aux].cpocod = ''
                    let a_ctc40m00[arr_aux].cpodes = ''
                    display a_ctc40m00[arr_aux].cpocod to s_ctc40m00[scr_aux].cpocod attribute(reverse)
                    display a_ctc40m00[arr_aux].cpodes to s_ctc40m00[scr_aux].cpodes
                    next field cpocod
                 end if
              end if
              if a_ctc40m00[arr_aux].cpodes is null then
                if m_operacao <> " " then
                   error " Informe a descricao do dominio"
                   next field cpodes
                end if
              else
                 if m_operacao = 'i' then
                    whenever error continue
                    open c_ctc40m00_004 using a_ctc40m00[arr_aux].cpodes,
                                              d_ctc40m00.cponom
                    fetch c_ctc40m00_004 into l_count
                    whenever error stop
                    if l_count > 0 then
                      error "Este dominio ja foi cadastrado com outro codigo"
                      next field cpodes
                   end if

                   ################################################################################
                   if d_ctc40m00.cponom[1,4] = "web_" then
                      let  l_cponom = d_ctc40m00.cponom[1,5]

                      let ws.sql = 'select count(*) from datkdominio ',
                        ' where cpodes = "' , a_ctc40m00[arr_aux].cpodes clipped, '"',
                        ' and   cponom matches "', l_cponom clipped, '*" '

                      prepare s_con_iddkdominio from ws.sql
                      declare c_con_iddkdominio cursor for s_con_iddkdominio

                      open  c_con_iddkdominio
                      fetch c_con_iddkdominio into l_conta_usuar
                      close c_con_iddkdominio

                      let ws.sql = "select cponom,cpocod from datkdominio",
                        " where cpodes = '" , a_ctc40m00[arr_aux].cpodes clipped, "'",
                        " and   cponom matches '", l_cponom clipped, "*'"

                      prepare s_show_iddkdominio from ws.sql
                      declare c_show_iddkdominio cursor for s_show_iddkdominio

                      open  c_show_iddkdominio
                      fetch c_show_iddkdominio into l_dominio,l_cpocod
                      close c_show_iddkdominio

                      if l_conta_usuar >= 1 then
                         error " Usuario já cadastrado no DOMINIO ",
                                 l_dominio clipped," com o CODIGO  ",l_cpocod
                         next field cpodes
                      end if
                   end if
                  ################################################################################
                 end if
              end if
              message "(F17)Abandona (F1)Inclui (F2)Exclui (F5)Seleciona (F8)Dados Atualizacao"
        #--------------------
          after row
        #--------------------
               whenever error continue

               case
                   when m_operacao = 'i'
                      call ctc40m00_insert_dados(arr_aux)

                   when m_operacao = 'p'
                      let l_err = 0
                      call ctc40m00_update_pergunta_altera(arr_aux, scr_aux) returning l_err
                      if l_err = 1 then
                         next field cpodes
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
                            ,"DO DOMINIO ?"
                            ," "
                            ," " )
                   returning m_confirma
               if m_confirma = "S"  then
                  let m_errflg = "N"
                  # VERIFICA SE EXISTE REGISTRO NO DOMINIO
                  if d_ctc40m00.cponom = 'datkdominio' then
                     whenever error continue
                      open c_ctc40m00_008 using a_ctc40m00[arr_aux].cpodes
                      fetch c_ctc40m00_008 into l_count
                     whenever error stop

                     if l_count > 0 then
                        clear form
                        call cts08g01("A"
                            ,""
                            ,"NAO E POSSIVEL EXCLUIR UM DOMINIO"
                            ,"COM REGISTROS VINCULADOS"
                            ," "
                            ,"APAGUE OS REGISTROS DO DOMINIO PRIMEIRO!" )
                        returning m_confirma
                        let d_ctc40m00.cponom = a_ctc40m00[arr_aux].cpodes
                        display by name d_ctc40m00.cponom attribute (reverse)
                        let int_flag = true
                        exit input
                     end if
                   end if

                   begin work

                   whenever error continue
                    execute p_ctc40m00_007 using d_ctc40m00.cponom,
                                                 a_ctc40m00[arr_aux].cpocod

                    if sqlca.sqlcode <> 0  then
                       error " Erro (", sqlca.sqlcode, ") na remocao do dominio!"

                       let m_errflg = "S"
                       whenever error stop
                    end if

                    whenever error stop
                    if m_errflg = "S"  then
                       rollback work
                    else
                       commit work
                    end if
               else
                  clear form
                  error " Remocao Cancelada!"
                  exit input
               end if

               let m_operacao = " "
               initialize a_ctc40m00[arr_aux].*   to null
               display a_ctc40m00[arr_aux].* to s_ctc40m00[scr_aux].*

          #--------------------
            on key (accept)
          #--------------------
               continue input
          #--------------------
            on key (F5)
          #--------------------
               let d_ctc40m00.cponom = a_ctc40m00[arr_aux].cpodes
               display by name d_ctc40m00.cponom attribute (reverse)
               let int_flag = true
               exit input

          #--------------------
            on key (F8)
          #--------------------
             let arr_aux = arr_curr()
             call ctc40m01(a_ctc40m00[arr_aux].atlult)
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
 end while

 let int_flag = false

 close window ctc40m00
end function

#==========================================================================
function ctc40m00_insert_dados(arr_aux)
#==========================================================================
  define arr_aux       smallint
  define scr_aux       smallint
  define l_count       smallint
 let a_ctc40m00[arr_aux].atlult = f_fungeral_atlult()
begin work
  whenever error continue
     open c_ctc40m00_003 using a_ctc40m00[arr_aux].cpocod,
                               d_ctc40m00.cponom
     fetch c_ctc40m00_003 into l_count
  whenever error stop
  if l_count = 0 then
     execute p_ctc40m00_005 using d_ctc40m00.cponom,
                                  a_ctc40m00[arr_aux].cpocod,
                                  a_ctc40m00[arr_aux].cpodes,
                                  a_ctc40m00[arr_aux].atlult
     if sqlca.sqlcode <> 0  then
        error " Erro (", sqlca.sqlcode, ") na insercao de dados"
        let m_errflg = "S"
        rollback work
    else
        error "Dominio Incluido Com Sucesso!"
        commit work
    end if
  end if
end function

#==========================================================================
function ctc40m00_update_pergunta_altera(arr_aux, scr_aux)
#==========================================================================
define arr_aux       smallint
define scr_aux       smallint
define l_descricao   char(50)
define l_count       smallint
define l_err         smallint
  let a_ctc40m00[arr_aux].atlult = f_fungeral_atlult()
  whenever error continue
   open c_ctc40m00_002 using a_ctc40m00[arr_aux].cpocod,
                             d_ctc40m00.cponom
   fetch c_ctc40m00_002 into l_descricao
  whenever error stop
  if l_descricao <> a_ctc40m00[arr_aux].cpodes  then
       open c_ctc40m00_004 using a_ctc40m00[arr_aux].cpodes,
                                 d_ctc40m00.cponom
       fetch c_ctc40m00_004 into l_count
       if l_count > 0 then
          error "Este dominio ja foi cadastrado com outro codigo"
          let l_err = 1
          return l_err
       else
          let l_err = 0
          call cts08g01("A","S"
                       ,"CONFIRMA ALTERACAO"
                       ,"DO DOMINIO ?"
                       ," "
                       ," ")
            returning m_confirma
           if m_confirma = "S" then
              let m_operacao = 'a'
           else
              let a_ctc40m00[arr_aux].cpodes = l_descricao clipped
              display a_ctc40m00[arr_aux].cpodes to s_ctc40m00[scr_aux].cpodes
           end if
        end if
     end if
     if m_operacao = 'a' then
        begin work
        whenever error continue
          execute p_ctc40m00_006 using a_ctc40m00[arr_aux].cpodes,
                                       a_ctc40m00[arr_aux].atlult,
                                       d_ctc40m00.cponom,
                                       a_ctc40m00[arr_aux].cpocod
          if sqlca.sqlcode <> 0  then
             rollback work
             error " Erro (", sqlca.sqlcode, ") na insercao de dados"
             let m_errflg = "S"
          else
             error "Dominio Alterado Com Sucesso!"
             commit work
          end if
    end if
return l_err
end function
#==========================================================================
 function ctc40m00_busca_datk(p_cponom)
#==========================================================================
# Esta funcao busca na iddkdominio pela chave 'datkdominio'
# e verifica se os campos pertencentes a esta chave devem ser
# gravados na datkdominio ou na iddkdominio.
#
   define p_cponom like datkdominio.cponom
   define l_count int

   let l_count = 0

   select count(*)
     into l_count
     from datkdominio
    where cponom = p_cponom

   if l_count = 0 then
     select count(*)
       into l_count
       from iddkdominio
       where cponom = p_cponom
     if l_count <> 0 then
      return 'iddkdominio'
     end if

   end if

   return 'datkdominio'

end function