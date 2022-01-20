{--------------------------------------------------------------------
Porto Seguro Cia Seguros Gerais
....................................................................
Sistema       : Central 24h
Modulo        : ctc14m07
Analista Resp.: Roberto Melo
PSI           :
Objetivo      : Manutencao do Relacionamento Assunto/Clausulas
....................................................................
Desenvolvimento: Amilton , META
Liberacao      :
....................................................................

                 * * * Alteracoes * * *

Data        Autor Fabrica  Origem    Alteracao
----------  -------------- --------- ------------------------------
----------------------------------------------------------------------}



globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prep smallint


function ctc14m07_prepare()

define l_sql char(1000)

   let l_sql = ' select clscod,ramcod  ',
               ' from datrastcls ',
               ' where c24astcod  =  ? '
   prepare pctc14m07001 from l_sql
   declare cctc14m07001 cursor for pctc14m07001

   let l_sql = ' select clsdes ',
               ' from aackcls  ',
               ' where tabnum = ? ',
               ' and ramcod = ?   ',
               ' and clscod = ?   '
   prepare pctc14m07002 from l_sql
   declare cctc14m07002 cursor for pctc14m07002


   let l_sql = "insert into datrastcls (c24astcod, ramcod,clscod,",
               "                        caddat,cadmat,",
               "                        cadempcod,cadusrtip)",
               " values (?,?,?,?,?,?,?)"
   prepare pctc14m07003 from l_sql



   let l_sql = " select clsdes     ",
               " from rgfkclaus2   ",
               " where ramcod  = ? ",
             # " and rmemdlcod in (0,1) ", # Alberto -> Tratado pelo Humberto chamado 131017607
               " and clscod    = ? "
   prepare pctc14m07004 from l_sql
   declare cctc14m07004 cursor for pctc14m07004


   let m_prep = true


end function

#------------------------------------------------------------------
 function ctc14m07(lr_param)
#------------------------------------------------------------------


 define lr_param record
        c24astcod     like datkassunto.c24astcod,
        c24astagpdes  like datkastagp.c24astagpdes,
        c24astdes     like datkassunto.c24astdes
 end record


 define a_ctc14m07 array[100] of record
        ramcod         like datrastcls.ramcod,
        clscod         like datrastcls.clscod,
        clsdes         like aackcls.clsdes
 end record

 define ws             record
   cont                dec(3,0)               ,
   operacao            char(1)                ,
   clscod              like datrastcls.clscod ,
   ramcod              like datrastcls.ramcod ,
   assunto             char(80)
 end record

 define arr_aux        smallint
 define scr_aux        smallint
 define l_data         date

 define lr_retorno record
       errocod smallint,
       msg     char(300)
 end record

 initialize lr_retorno.* to null


options delete key F2

open window w_ctc14m07 at 6,2 with form "ctc14m07"
     attribute(form line first, comment line last - 2)

message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

let ws.assunto = lr_param.c24astagpdes clipped, " ", lr_param.c24astdes

display lr_param.c24astcod  to  c24astcod  attribute(reverse)
display ws.assunto     to  c24astdes  attribute(reverse)

let arr_aux = 1
initialize a_ctc14m07  to null

 if m_prep = false or
    m_prep = " " then
    call ctc14m07_prepare()
 end if

let l_data = today

open cctc14m07001 using lr_param.c24astcod

foreach cctc14m07001 into a_ctc14m07[arr_aux].clscod,a_ctc14m07[arr_aux].ramcod

   call ctc14m07_descricao_clausula(a_ctc14m07[arr_aux].clscod,
                                    a_ctc14m07[arr_aux].ramcod )
       returning lr_retorno.errocod,
                 lr_retorno.msg,
                 a_ctc14m07[arr_aux].clsdes

   let arr_aux = arr_aux + 1
   if lr_retorno.errocod <> 0 then
      error lr_retorno.msg
      continue foreach
      #exit foreach
   end if

   #let arr_aux = arr_aux + 1
   if arr_aux > 100   then
      error " Limite excedido, tabela c/ mais de 100 itens"
      exit foreach
   end if
end foreach

call set_count(arr_aux-1)

while true

   let int_flag = false

   input array a_ctc14m07 without defaults from s_ctc14m07.*

      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()

      before insert
         let ws.operacao = "i"
         initialize  a_ctc14m07[arr_aux]  to null
         display a_ctc14m07[arr_aux].ramcod     to
                 s_ctc14m07[scr_aux].ramcod


      before field ramcod
         display a_ctc14m07[arr_aux].ramcod   to
                 s_ctc14m07[scr_aux].ramcod   attribute (reverse)

      after field ramcod

         display a_ctc14m07[arr_aux].ramcod   to
                 s_ctc14m07[scr_aux].ramcod


         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            let ws.operacao = " "
         else
            if a_ctc14m07[arr_aux].ramcod  is null   then
               error " Ramo do assunto deve ser informado!"
               next field ramcod
            end if
         end if

         if ws.operacao = "a"  then
            if ws.ramcod <> a_ctc14m07[arr_aux].ramcod    then
               error " Nao pode alterar ramo do assunto!"
               next field ramcod
            end if
         end if

      before field clscod
         display a_ctc14m07[arr_aux].clscod   to
                 s_ctc14m07[scr_aux].clscod   attribute (reverse)

      after field clscod
         display a_ctc14m07[arr_aux].clscod   to
                 s_ctc14m07[scr_aux].clscod

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            let ws.operacao = " "
            next field ramcod
         end if

         initialize a_ctc14m07[arr_aux].clsdes  to null
         if a_ctc14m07[arr_aux].clscod     is null   then
            error " clausula do assunto deve ser informada!"
            let a_ctc14m07[arr_aux].clsdes = null
            next field clscod
         else
            display a_ctc14m07[arr_aux].clsdes to s_ctc14m07[scr_aux].clsdes
            call ctc14m07_descricao_clausula(a_ctc14m07[arr_aux].clscod,
                                             a_ctc14m07[arr_aux].ramcod)
                 returning lr_retorno.errocod,lr_retorno.msg,
                           a_ctc14m07[arr_aux].clsdes

                 if lr_retorno.errocod <> 0 then
                    error lr_retorno.msg
                    next field clscod
                 else
                   display a_ctc14m07[arr_aux].clsdes to s_ctc14m07[scr_aux].clsdes
                 end if
         end if

         if ws.operacao = "a"  then
            if ws.clscod <> a_ctc14m07[arr_aux].clscod    then
               error " Nao pode alterar clausula do assunto!"
               next field clscod
            end if
         end if

         #---------------------------------------------------------
         # Verifica existencia ramo do assunto a incluir
         #---------------------------------------------------------
         if ws.operacao = "i"  then
             select  *
               from  datrastcls
               where c24astcod = lr_param.c24astcod         and
                     ramcod    = a_ctc14m07[arr_aux].ramcod and
                     clscod    = a_ctc14m07[arr_aux].clscod

            if status <> notfound then
               error " Clausula ja cadastrada para esse codigo de assunto e ramo!"
               let a_ctc14m07[arr_aux].clsdes = null
               next field clscod
            end if
         end if


      on key (interrupt)
         exit input

      before delete
         let ws.operacao = "d"
         if a_ctc14m07[arr_aux].clscod  is null   then
            continue input
         else
            if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
               exit input
            end if

            begin work
               delete from datrastcls
                   where c24astcod = lr_param.c24astcod               and
                         ramcod    = a_ctc14m07[arr_aux].ramcod       and
                         clscod    = a_ctc14m07[arr_aux].clscod
            commit work

            initialize a_ctc14m07[arr_aux].* to null
            display    a_ctc14m07[scr_aux].* to s_ctc14m07[scr_aux].*
         end if

      after row
         begin work
            case ws.operacao
               when "i"

                  whenever error continue

                  execute pctc14m07003 using lr_param.c24astcod,
                                             a_ctc14m07[arr_aux].ramcod,
                                             a_ctc14m07[arr_aux].clscod,
                                             l_data,g_issk.funmat,
                                             g_issk.empcod,g_issk.usrtip
                 whenever error stop

                 if sqlca.sqlcode <> 0 then
                    let lr_retorno.errocod = sqlca.sqlcode
                    let lr_retorno.msg  = "Erro <",lr_retorno.errocod ,"> ao inserir clausula ! Avise a informatica!"
                    call errorlog(lr_retorno.msg)
                    error lr_retorno.msg
                 end if

           end case
         commit work

         let ws.operacao = " "

   end input

   if int_flag       then
      exit while
   end if

end while

close cctc14m07001
let int_flag = false

options delete key F40

close window w_ctc14m07

end function

function ctc14m07_descricao_clausula(lr_param)

  define lr_param record
       clscod like datrastcls.clscod,
       ramcod like datrastcls.ramcod
  end record

  define  l_tabnum         like itatvig.tabnum

  define lr_retorno record
        errocod smallint,
        msg     char(400),
        clsdes  like aackcls.clsdes
  end record

  let l_tabnum = null
  initialize lr_retorno.* to null


  if m_prep = false  or
     m_prep = " " then
     call ctc14m07_prepare()
  end if

  if lr_param.ramcod = 531 or
     lr_param.ramcod = 31 then

     let l_tabnum = F_FUNGERAL_TABNUM("aackcls", today)

     whenever error stop
     open cctc14m07002 using l_tabnum,
                             lr_param.ramcod,
                             lr_param.clscod
     fetch cctc14m07002 into lr_retorno.clsdes
     whenever error continue

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
          let lr_retorno.errocod = sqlca.sqlcode
          let lr_retorno.msg  = "Clausula ",lr_param.clscod clipped, " nao encontrada para o ramo ",lr_param.ramcod clipped," na tabela aackcls"
          let lr_retorno.clsdes = "***** NÃO CADASTRADA *****"
          call errorlog(lr_retorno.msg)
        else
          let lr_retorno.errocod = sqlca.sqlcode
          let lr_retorno.msg  = "Erro <",lr_retorno.errocod ,"> na busca da descricao da clausula ! Avise a informatica!"
          call errorlog(lr_retorno.msg)
        end if
     end if
  else
     whenever error stop
     open cctc14m07004 using lr_param.ramcod,
                             lr_param.clscod
     fetch cctc14m07004 into lr_retorno.clsdes
     whenever error continue

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = 100 then
          let lr_retorno.errocod = sqlca.sqlcode
          let lr_retorno.msg  = "Clausula ",lr_param.clscod clipped, " nao encontrada para o ramo ",lr_param.ramcod clipped," na tabela rgfkclaus2"
          call errorlog(lr_retorno.msg)
        else
          let lr_retorno.errocod = sqlca.sqlcode
          let lr_retorno.msg  = "Erro <",lr_retorno.errocod ,"> na busca da descricao da clausula ! Avise a informatica!"
          call errorlog(lr_retorno.msg)
        end if
     end if
  end if

  return lr_retorno.*

end function

