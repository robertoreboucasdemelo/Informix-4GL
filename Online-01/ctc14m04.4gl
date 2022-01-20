############################################################################
# Menu de Modulo: CTC14M04                                        Gilberto #
#                                                                  Marcelo #
# Manutencao no Relacionamento Assunto/Ramo                       Fev/1996 #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
############################################################################


globals "/homedsa/projetos/geral/globals/glct.4gl"

#------------------------------------------------------------------
 function ctc14m04(par_c24astcod, par_c24astagpdes, par_c24astdes)
#------------------------------------------------------------------

define par_c24astcod     like datkassunto.c24astcod
define par_c24astagpdes  like datkastagp.c24astagpdes
define par_c24astdes     like datkassunto.c24astdes

define a_ctc14m04 array[100] of record
   ramcod             like datrclassassunto.ramcod   ,
   ramnom             like gtakram.ramnom           ,
   astrgrcod          like datrclassassunto.astrgrcod,
   astrgrdes          char(08)
end record

define ws             record
  cont                dec(3,0)                    ,
  operacao            char(1)                     ,
  ramcod              like datrclassassunto.ramcod,
  assunto             char(80)
end record

define arr_aux        smallint
define scr_aux        smallint


options delete key F2

open window w_ctc14m04 at 6,2 with form "ctc14m04"
     attribute(form line first, comment line last - 2)

message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

let ws.assunto = par_c24astagpdes clipped, " ", par_c24astdes

display par_c24astcod  to  c24astcod  attribute(reverse)
display ws.assunto     to  c24astdes  attribute(reverse)

declare c_ctc14m04 cursor for
   select ramcod, astrgrcod
     from datrclassassunto
    where c24astcod  =  par_c24astcod

let arr_aux = 1
initialize a_ctc14m04  to null

foreach c_ctc14m04 into a_ctc14m04[arr_aux].ramcod   ,
                        a_ctc14m04[arr_aux].astrgrcod

   select ramnom
     into a_ctc14m04[arr_aux].ramnom
     from gtakram
    where ramcod = a_ctc14m04[arr_aux].ramcod
      and empcod = 1

   if a_ctc14m04[arr_aux].astrgrcod = 1    then
      let a_ctc14m04[arr_aux].astrgrdes = "REGRA"
   else
      if a_ctc14m04[arr_aux].astrgrcod = 2    then
         let a_ctc14m04[arr_aux].astrgrdes = "EXCECAO"
      end if
   end if

   let arr_aux = arr_aux + 1
   if arr_aux > 100   then
      error " Limite excedido, tabela c/ mais de 100 itens"
      exit foreach
   end if
end foreach

call set_count(arr_aux-1)

while true

   let int_flag = false

   input array a_ctc14m04 without defaults from s_ctc14m04.*

      before row
         let arr_aux = arr_curr()
         let scr_aux = scr_line()
         if arr_aux <= arr_count()  then
            let ws.operacao = "a"
            let ws.ramcod   =  a_ctc14m04[arr_aux].ramcod
         end if

      before insert
         let ws.operacao = "i"
         initialize  a_ctc14m04[arr_aux]  to null
         display a_ctc14m04[arr_aux].ramcod     to
                 s_ctc14m04[scr_aux].ramcod
         display a_ctc14m04[arr_aux].astrgrcod  to
                 s_ctc14m04[scr_aux].astrgrcod

      before field ramcod
         display a_ctc14m04[arr_aux].ramcod   to
                 s_ctc14m04[scr_aux].ramcod   attribute (reverse)

      after field ramcod
         display a_ctc14m04[arr_aux].ramcod   to
                 s_ctc14m04[scr_aux].ramcod

         if fgl_lastkey() = fgl_keyval("up")     or
            fgl_lastkey() = fgl_keyval("left")   then
            let ws.operacao = " "
         end if

         initialize a_ctc14m04[arr_aux].ramnom  to null
         if a_ctc14m04[arr_aux].ramcod     is null   then
            error " Ramo do assunto deve ser informado!"
            next field ramcod
         else
            select ramnom
              into a_ctc14m04[arr_aux].ramnom
              from gtakram
             where ramcod = a_ctc14m04[arr_aux].ramcod
               and empcod = 1

            if status = notfound   then
               error " Ramo nao cadastrado!"
               next field ramcod
            else
               display a_ctc14m04[arr_aux].ramnom to s_ctc14m04[scr_aux].ramnom
            end if
         end if

         if ws.operacao = "a"  then
            if ws.ramcod <> a_ctc14m04[arr_aux].ramcod    then
               error " Nao pode alterar ramo do assunto!"
               next field ramcod
            end if
         end if

         #---------------------------------------------------------
         # Verifica existencia ramo do assunto a incluir
         #---------------------------------------------------------
         if ws.operacao = "i"  then
             select  *
               from  datrclassassunto
               where c24astcod = par_c24astcod               and
                     ramcod    = a_ctc14m04[arr_aux].ramcod

            if status <> notfound then
               error " Ramo ja cadastrado p/ esse codigo de assunto!"
               next field ramcod
            end if
         end if

      before field astrgrcod
         display a_ctc14m04[arr_aux].astrgrcod  to
                 s_ctc14m04[scr_aux].astrgrcod attribute (reverse)

      after field astrgrcod
         display a_ctc14m04[arr_aux].astrgrcod to
                 s_ctc14m04[scr_aux].astrgrcod

         if fgl_lastkey() = fgl_keyval("up")   or
            fgl_lastkey() = fgl_keyval("left") then
            next field ramcod
         end if

         if a_ctc14m04[arr_aux].astrgrcod   is null  then
            error " Deve ser informado se ramo e' REGRA OU EXCECAO!"
            next field astrgrcod
         else
            if a_ctc14m04[arr_aux].astrgrcod  = 1   then
               let a_ctc14m04[arr_aux].astrgrdes = "REGRA"
               display a_ctc14m04[arr_aux].astrgrdes  to
                       s_ctc14m04[scr_aux].astrgrdes
            else
               if a_ctc14m04[arr_aux].astrgrcod  = 2   then
                  let a_ctc14m04[arr_aux].astrgrdes = "EXCECAO"
                  display a_ctc14m04[arr_aux].astrgrdes  to
                          s_ctc14m04[scr_aux].astrgrdes
               else
                  error " Informar (1)Regra ou (2)Excessao para o ramo!"
                  next field astrgrcod
               end if
            end if
         end if

         let ws.cont = 0
         select count(*)
           into ws.cont
           from datrclassassunto
          where c24astcod =  par_c24astcod                  and
                astrgrcod <> a_ctc14m04[arr_aux].astrgrcod

         if ws.cont > 0   then
            error " Deve haver SO' REGRA OU SO' EXCECAO!"
            next field astrgrcod
         end if

      on key (interrupt)
         exit input

      before delete
         let ws.operacao = "d"
         if a_ctc14m04[arr_aux].ramcod  is null   then
            continue input
         else
            if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?","","") = "N"  then
               exit input
            end if

            begin work
               delete from datrclassassunto
                   where c24astcod = par_c24astcod               and
                         ramcod    = a_ctc14m04[arr_aux].ramcod
            commit work

            initialize a_ctc14m04[arr_aux].* to null
            display    a_ctc14m04[scr_aux].* to s_ctc14m04[scr_aux].*
         end if

      after row
         begin work
            case ws.operacao
               when "i"
                  insert into datrclassassunto (c24astcod, ramcod   ,
                                                astrgrcod, funmat   ,
                                                atldat)
                              values           (par_c24astcod                ,
                                                a_ctc14m04[arr_aux].ramcod   ,
                                                a_ctc14m04[arr_aux].astrgrcod,
                                                g_issk.funmat                ,
                                                today)
               when "a"
                  update datrclassassunto set (astrgrcod)
                              =               (a_ctc14m04[arr_aux].astrgrcod)
                         where c24astcod = par_c24astcod                and
                               ramcod    = a_ctc14m04[arr_aux].ramcod
           end case
         commit work

         let ws.operacao = " "

   end input

   if int_flag       then
      exit while
   end if

end while

close c_ctc14m04
let int_flag = false

options delete key F40

close window w_ctc14m04

end function   ###------ ctc14m04
