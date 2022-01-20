############################################################################
# Menu de Modulo: CTC24M04                                        Ruiz     #
# Historico  dos Procedimentos                                    Dez/2001 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 28/12/2001  PSI 144908   Ruiz         Historico p/ alteracao dos         #
#                                       procedimentos para convenios.      #
############################################################################

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------------
 function ctc24m04(par_ctc24m04)
#--------------------------------------------------------------------

   define par_ctc24m04 record
          cvnnum       like datktopcvn.cvnnum    ,
          cvntopcod    like datktopcvn.cvntopcod ,
          cvntopnom    like datktopcvn.cvntopnom
   end record
   define a_ctc24m04 array[300] of record
          atldat       like datmtopcvnhst.atldat,
          atlhor       like datmtopcvnhst.atlhor,
          funmat       like datmtopcvnhst.funmat,
          funnom       like isskfunc.funnom,
          cvntopseq    like datmtopcvnhst.cvntopseq
   end record
   define arr_aux      smallint
   define scr_aux      smallint
   define i            smallint
  
   define ws  record
          convenio     char(20),
          empcod       like isskfunc.empcod
   end record

   initialize a_ctc24m04   to null
   initialize ws.*         to null
   let arr_aux  =  1

   declare c_ctc24m04 cursor for
     select atldat,atlhor,funmat,empcod,cvntopseq
        from datmtopcvnhst
       where cvnnum    = par_ctc24m04.cvnnum   and
             cvntopcod = par_ctc24m04.cvntopcod 

   foreach c_ctc24m04 into a_ctc24m04[arr_aux].atldat,
                           a_ctc24m04[arr_aux].atlhor,
                           a_ctc24m04[arr_aux].funmat,
                           ws.empcod,
                           a_ctc24m04[arr_aux].cvntopseq
       let a_ctc24m04[arr_aux].funnom = "NAO ENCONTRADO"
       select funnom 
         into a_ctc24m04[arr_aux].funnom
         from isskfunc
        where empcod = ws.empcod
          and funmat = a_ctc24m04[arr_aux].funmat
       
       let arr_aux = arr_aux + 1
       if arr_aux > 300 then
           error " Limite excedido! Foram encontradas mais de 300",
                 " linhas de manutencao para o procedimento!"
           exit foreach
        end if
   end foreach
   call set_count(arr_aux-1)

   open window w_ctc24m04 at 06,02 with form "ctc24m04"
       attribute(form line first)

   if arr_aux   >   1  then
      select cpodes
         into ws.convenio
         from datkdominio
        where cponom = "ligcvntip"
          and cpocod = par_ctc24m04.cvnnum

      display par_ctc24m04.cvnnum    to cvnnum
      display ws.convenio            to convenio
      display par_ctc24m04.cvntopcod to cvntopcod
      display par_ctc24m04.cvntopnom to cvntopnom

      call set_count(arr_aux-1)

      display array  a_ctc24m04 to s_ctc24m04.*

        on key(interrupt)
           exit display

        on key(f8)
           let arr_aux = arr_curr()
           call ctc24m04_mostra_historico(par_ctc24m04.cvnnum,
                                          ws.convenio        ,
                                          par_ctc24m04.cvntopcod,
                                          par_ctc24m04.cvntopnom,
                                          a_ctc24m04[arr_aux].cvntopseq,
                                          a_ctc24m04[arr_aux].atldat,
                                          a_ctc24m04[arr_aux].atlhor,
                                          a_ctc24m04[arr_aux].funnom)  
      end display
   else
       error " Nao existe historico para o Convenio "
   end if
   let int_flag = false
   close window w_ctc24m04
 end function

#------------------------------------------------------------------------------
 function ctc24m04_mostra_historico(param)
#------------------------------------------------------------------------------
   define param  record
       cvnnum       like datktopcvn.cvnnum ,
       convenio     char (20)              ,
       cvntopcod    like datktopcvn.cvntopcod , 
       cvntopnom    like datktopcvn.cvntopnom ,
       cvntopseq    dec (3,0)                 ,
       atldat       like datmtopcvnhst.atldat,
       atlhor       like datmtopcvnhst.atlhor,
       funnom       like isskfunc.funnom             
   end record
   define a1_ctc24m04 array[300] of record
       cvntopdes      like datkdestopcvn.cvntopdes ,
       cvntopdesseq   like datkdestopcvn.cvntopdesseq
   end record
   define arr_aux    smallint
   define scr_aux    smallint
   define i          smallint

   initialize a1_ctc24m04  to null
   let arr_aux = 1
   let a1_ctc24m04[arr_aux].cvntopdes = 
             "Em: ",  param.atldat clipped, "  ",
             "As: ",  param.atlhor clipped, "  ",
             "Por: ", upshift(param.funnom clipped)
   let arr_aux = arr_aux + 2

   declare c1_ctc24m04 cursor for
        select cvntopdes, cvntopdesseq
           from datmdestopcvnhst         
          where cvnnum    = param.cvnnum    and
                cvntopcod = param.cvntopcod and
                cvntopseq = param.cvntopseq

   foreach c1_ctc24m04 into a1_ctc24m04[arr_aux].cvntopdes    ,
                            a1_ctc24m04[arr_aux].cvntopdesseq
     let arr_aux = arr_aux + 1
     if arr_aux > 300 then
        error " Limite excedido! Foram encontradas mais de 300",
              " linhas de procedimento!!"
        exit foreach
     end if
   end foreach

   open window w_ctc24m01 at 06,02 with form "ctc24m01"
        attribute(form line first)

   display param.cvnnum    to cvnnum
   display param.convenio  to convenio
   display param.cvntopcod to cvntopcod
   display param.cvntopnom to cvntopnom

   if arr_aux   >   1  then
      call set_count(arr_aux-1)
      display array  a1_ctc24m04 to s_ctc24m01.*
        on key(interrupt)
           exit display
      end display
   end if
   close window w_ctc24m01
 end function
