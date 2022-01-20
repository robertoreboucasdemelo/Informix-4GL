############################################################################
# Menu de Modulo: CTC23M01                                        Gilberto #
#                                                                  Marcelo #
# Manutencao na Agenda de telefones (telefones)                   Fev/1996 #
############################################################################

database porto

globals  "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------------
function ctc23m01(par_operacao, par_pescod, par_pesnom, par_pesobs)
#---------------------------------------------------------------------
  define par_operacao char(01)
  define par_pescod   like datkpesagetel.pescod
  define par_pesnom   like datkpesagetel.pesnom
  define par_pesobs   like datkpesagetel.pesobs

  define a_ctc23m01   array[09] of record
     teltipcod        like datkagendatel.teltipcod ,
     teltipdes        char(09)                     ,
     dddcod           like datkagendatel.dddcod    ,
     telnum           like datkagendatel.telnum    ,
     rmlnum           like datkagendatel.rmlnum    ,
     bipnum           like datkagendatel.bipnum
  end record

  define ws           record
     operacao         char(01)                     ,
     teltipcod        like datkagendatel.teltipcod ,
     telnum           like datkagendatel.telnum    ,
     prxcod           like datkagendatel.pescod    ,
     count            dec(2,0)
  end record

  define arr_aux      integer
  define scr_aux      integer


  declare c_ctc23m01  cursor for
     select teltipcod, dddcod, telnum, rmlnum, bipnum
      from datkagendatel
     where pescod = par_pescod

  initialize a_ctc23m01  to null
  initialize ws.*        to null
  let arr_aux = 1

  foreach c_ctc23m01 into a_ctc23m01[arr_aux].teltipcod ,
                          a_ctc23m01[arr_aux].dddcod    ,
                          a_ctc23m01[arr_aux].telnum    ,
                          a_ctc23m01[arr_aux].rmlnum    ,
                          a_ctc23m01[arr_aux].bipnum

     call tipo_ctc23m01(a_ctc23m01[arr_aux].teltipcod)
          returning a_ctc23m01[arr_aux].teltipdes

     let arr_aux = arr_aux + 1
     if arr_aux > 09 then
        error " Limite excedido, nome com mais de 09 telefones"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)

  options comment line last - 1

  open window w_ctc23m01 at 06,2 with form "ctc23m01"
       attribute(form line first)

  message " (F17)Abandona, (F1)Inclui, (F2)Exclui"

  display par_pescod  to  pescod
  display par_pesnom  to  pesnom
  display par_pesobs  to  pesobs

   while true
      let int_flag = false

      input array a_ctc23m01 without defaults from s_ctc23m01.*
         before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
                  let ws.teltipcod = a_ctc23m01[arr_aux].teltipcod
                  let ws.telnum    = a_ctc23m01[arr_aux].telnum
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctc23m01[arr_aux].*  to null
               display a_ctc23m01[arr_aux].* to s_ctc23m01[scr_aux].*

            before field teltipcod
               display a_ctc23m01[arr_aux].teltipcod to
                       s_ctc23m01[scr_aux].teltipcod attribute (reverse)

            after field teltipcod
               display a_ctc23m01[arr_aux].teltipcod to
                       s_ctc23m01[scr_aux].teltipcod

               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  let ws.operacao = " "
               end if

               if ((a_ctc23m01[arr_aux].teltipcod is null)  or
                   (a_ctc23m01[arr_aux].teltipcod <> 1      and
                    a_ctc23m01[arr_aux].teltipcod <> 2      and
                    a_ctc23m01[arr_aux].teltipcod <> 3      and
                    a_ctc23m01[arr_aux].teltipcod <> 4))    then
                  error "Tipo deve ser: (1)Telefone, (2)Fax, (3)Bip, (4)Celular"
                  next field teltipcod
               end if

               call tipo_ctc23m01(a_ctc23m01[arr_aux].teltipcod)
                    returning a_ctc23m01[arr_aux].teltipdes
               display a_ctc23m01[arr_aux].teltipdes to
                       s_ctc23m01[scr_aux].teltipdes

            before field dddcod
               display a_ctc23m01[arr_aux].dddcod  to
                       s_ctc23m01[scr_aux].dddcod  attribute (reverse)

            after field dddcod
               display a_ctc23m01[arr_aux].dddcod  to
                       s_ctc23m01[scr_aux].dddcod

               if fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field teltipcod
               end if

               if a_ctc23m01[arr_aux].dddcod   is null  or
                  a_ctc23m01[arr_aux].dddcod   =  "  "  or
                  a_ctc23m01[arr_aux].dddcod   = "0000" or
                  a_ctc23m01[arr_aux].dddcod   = "000"  then
                  error " Codigo do DDD deve ser informado !!"
                  next field dddcod
               end if

            before field telnum
               display a_ctc23m01[arr_aux].telnum  to
                       s_ctc23m01[scr_aux].telnum  attribute (reverse)

            after field telnum
               display a_ctc23m01[arr_aux].telnum  to
                       s_ctc23m01[scr_aux].telnum

               if fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field dddcod
               end if

               if a_ctc23m01[arr_aux].telnum   is null  or
                  a_ctc23m01[arr_aux].telnum   = 0000   then
                  error " Numero do telefone deve ser informado !!"
                  next field telnum
               else
                  if a_ctc23m01[arr_aux].telnum  < 99999   then
                     error " Telefone com menos de 6 numeros !!"
                     next field telnum
                  end if
               end if

               #-----------------------------------------------
               # Verifica se este telefone ja foi cadastrado
               #-----------------------------------------------
               if ws.operacao = "i"  then
                  select * from datkagendatel
                   where pescod = par_pescod                  and
                         telnum = a_ctc23m01[arr_aux].telnum

                  if status <> notfound then
                     error " Telefone ja' cadastrado !!"
                     next field telnum
                  end if
               end if

            before field rmlnum
               display a_ctc23m01[arr_aux].rmlnum  to
                       s_ctc23m01[scr_aux].rmlnum  attribute (reverse)

            after field rmlnum
               display a_ctc23m01[arr_aux].rmlnum  to
                       s_ctc23m01[scr_aux].rmlnum

            before field bipnum
               display a_ctc23m01[arr_aux].bipnum  to
                       s_ctc23m01[scr_aux].bipnum  attribute (reverse)

            after field bipnum
               display a_ctc23m01[arr_aux].bipnum  to
                       s_ctc23m01[scr_aux].bipnum

               if a_ctc23m01[arr_aux].teltipcod = 3   and
                 (a_ctc23m01[arr_aux].bipnum is null  or
                  a_ctc23m01[arr_aux].bipnum = 0   )  then
                  error "E' obrigatorio o codigo do BIP!"
                  next field bipnum
               end if

               if fgl_lastkey() = fgl_keyval("up")   or
                  fgl_lastkey() = fgl_keyval("left") then
                  next field rmlnum
               end if

               if a_ctc23m01[arr_aux].bipnum  =  0000   then
                  error " Codigo do Bip nao deve ser zeros !!"
                  next field bipnum
               else
                  if a_ctc23m01[arr_aux].bipnum  >  0000   and
                     a_ctc23m01[arr_aux].teltipcod <> 3    then
                     error " Tipo de telefone nao permite codigo de BIP !!"
                     next field bipnum
                  end if
               end if

            on key (interrupt)
               exit input

            before delete
               let ws.count = 0
               select count(*)  into  ws.count
                 from datkagendatel
                where pescod  =  par_pescod

               if ws.count =  1   then
                  error " Deve ser removido o nome da agenda !!"
                  exit input
               end if

               let ws.operacao = "d"
               if a_ctc23m01[arr_aux].telnum  is null   then
                  continue input
               else
                  begin work
                     delete from datkagendatel
                            where pescod  = par_pescod                 and
                                  telnum  = a_ctc23m01[arr_aux].telnum
                  commit work

                  initialize a_ctc23m01[arr_aux].* to null
                  display a_ctc23m01[arr_aux].* to s_ctc23m01[scr_aux].*
               end if

            after row
               begin work

               case ws.operacao
                  when "i"
                     if par_operacao = "i"   then  #--> qdo inclui nome
                        initialize par_operacao  to null
                        call nome_ctc23m01(par_pesnom, par_pesobs)
                             returning par_pescod
                        if par_pescod  is null   then
                           exit input
                        end if
                     end if

                     insert into datkagendatel
                            (pescod, teltipcod, dddcod, telnum, rmlnum, bipnum)
                            values
                                 (par_pescod                   ,
                                  a_ctc23m01[arr_aux].teltipcod,
                                  a_ctc23m01[arr_aux].dddcod   ,
                                  a_ctc23m01[arr_aux].telnum   ,
                                  a_ctc23m01[arr_aux].rmlnum   ,
                                  a_ctc23m01[arr_aux].bipnum)
                  when "a"
                     update datkagendatel  set
                                 (teltipcod, dddcod, telnum, rmlnum, bipnum)
                            =    (a_ctc23m01[arr_aux].teltipcod,
                                  a_ctc23m01[arr_aux].dddcod   ,
                                  a_ctc23m01[arr_aux].telnum   ,
                                  a_ctc23m01[arr_aux].rmlnum   ,
                                  a_ctc23m01[arr_aux].bipnum)
                         where pescod    =  par_pescod   and
                               teltipcod =  ws.teltipcod and
                               telnum    =  ws.telnum
               end case

               commit work
               let ws.operacao = " "
      end input

      if int_flag    then
         exit while
      end if

   end while

   let int_flag = false
   close c_ctc23m01
   options comment line last
   close window w_ctc23m01

end function

#---------------------------------------------------------------
function nome_ctc23m01(par_pesnom, par_pesobs)
#---------------------------------------------------------------
  define par_pesnom   like datkpesagetel.pesnom
  define par_pesobs   like datkpesagetel.pesobs
  define ret_pescod   like datkpesagetel.pescod

  define ws_prxcod    like datkpesagetel.pescod
  define ws_resp      char(01)


  select max(pescod) into ws_prxcod
    from datkpesagetel

  if ws_prxcod  is null   then
    let ret_pescod = 1
  else
    let ret_pescod = ws_prxcod + 1
  end if

  insert into datkpesagetel
              (pescod, pesnom, pesobs)
       values
              (ret_pescod, par_pesnom, par_pesobs)

  if status <> 0   then
     error " Erro na inclusao do nome na agenda, AVISE INFORMATICA "
     rollback work
     initialize ret_pescod  to null
  else
     display ret_pescod  to  pescod  attribute (reverse)
     error "Verifique o codigo do registro e tecle ENTER!"
     prompt "" for char ws_resp
  end if

  return ret_pescod

end function  #  nome_ctc23m01

#---------------------------------------------------------------
 function tipo_ctc23m01(par_teltipcod)
#---------------------------------------------------------------
   define par_teltipcod  like datkagendatel.teltipcod
   define ret_teltipdes  char(09)

   case par_teltipcod
        when  1
           let ret_teltipdes = "TELEFONE"
        when  2
           let ret_teltipdes = "FAX"
        when  3
           let ret_teltipdes = "BIP"
        when  4
           let ret_teltipdes = "CELULAR"
        otherwise
           let ret_teltipdes = "N/PREVISTO"
   end case

   return ret_teltipdes

end function  #  tipo_ctc23m01

