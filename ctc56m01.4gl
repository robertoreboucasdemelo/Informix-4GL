############################################################################
# Menu de Modulo: CTC56m01                                           Raji  #
#                                                                          #
# Manutencao dos Textos para Clausulas                            Mar/2002 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONS. DESCRICAO                              #
#--------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86              #
# 25/09/06   Ligia Mattge  PSI 202720 Implementando grupo/cartao saude     #
# 16/11/2006 Ligia Mattge  PSI 205206 ciaempcod                            #
############################################################################

globals  "/homedsa/projetos/geral/globals/glct.4gl"

 define wg_clslin  like datkclstxt.clslin

#--------------------------------------------------------------------
 function ctc56m01(par_operacao, par_ctc56m01)
#--------------------------------------------------------------------

  define par_operacao char(01)

  define par_ctc56m01 record
         ciaempcod    like datkclstxt.ciaempcod,
         ramcod       like datkclstxt.ramcod,
         rmemdlcod    like datkclstxt.rmemdlcod,
         clscod       like datkclstxt.clscod,
         ramgrpcod    like gtakram.ramgrpcod
  end record

  define a_ctc56m01 array[1000] of record
     clstxt      like datkclstxt.clstxt ,
     clslin      like datkclstxt.clslin
  end record

  define arr_aux    smallint
  define scr_aux    smallint
  define i          smallint

  define ws         record
     operacao       char(01)                   ,
     count          smallint                   ,
     clsdes         char(20)                   ,
     ramnom         char(20)                   ,
     clstxt         like datkclstxt.clstxt     ,
     erro           dec(01,0)                  ,
     clslin         like datkclstxt.clslin     ,
     confirma       char(1)                    ,
     arq            char(15)                   ,
     clslinseq      like datkclstxt.clslinseq
  end record


        define  w_pf1   integer

        let     arr_aux  =  null
        let     scr_aux  =  null
        let     i  =  null

        for     w_pf1  =  1  to  1000
                initialize  a_ctc56m01[w_pf1].*  to  null
        end     for

        initialize  ws.*  to  null

  initialize a_ctc56m01  to null
  initialize ws.*        to null

  select max(clslinseq)
         into ws.clslinseq
    from datkclstxt
   where clscod = par_ctc56m01.clscod
     and ramcod = par_ctc56m01.ramcod
     and rmemdlcod = par_ctc56m01.rmemdlcod
     and ciaempcod = par_ctc56m01.ciaempcod

  declare c_ctc56m01  cursor for
     select clstxt, clslin
       from datkclstxt
      where clscod    = par_ctc56m01.clscod
        and ramcod    = par_ctc56m01.ramcod
        and rmemdlcod = par_ctc56m01.rmemdlcod
        and ciaempcod = par_ctc56m01.ciaempcod
        and clslinseq = ws.clslinseq
     order by clslin

  let arr_aux = 1

  foreach c_ctc56m01 into a_ctc56m01[arr_aux].clstxt    ,
                          a_ctc56m01[arr_aux].clslin
     let arr_aux = arr_aux + 1
     if arr_aux > 1000 then
        error " Limite excedido! Foram encontradas mais de 1000",
              " linhas de procedimento!"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)

  open window w_ctc56m01 at 06,02 with form "ctc56m01"
       attribute(form line first,message line last -1)

  ### PSI 202720
  call ctc56m06_clsdes(par_ctc56m01.ciaempcod, par_ctc56m01.ramgrpcod, 
                       par_ctc56m01.ramcod, par_ctc56m01.clscod, 
                       par_ctc56m01.rmemdlcod) 
       returning ws.clsdes

  select ramnom
    into ws.ramnom
    from gtakram
   where ramcod = par_ctc56m01.ramcod
     and empcod = 1

  display par_ctc56m01.clscod    to clscod
  display ws.clsdes              to clsdes
  display par_ctc56m01.rmemdlcod to rmemdlcod
  display par_ctc56m01.ramcod    to ramcod
  display ws.ramnom              to ramnom

   while true
      let int_flag = false

      message "(F1)Inclui, (F2)Exclui"

      input array a_ctc56m01 without defaults from s_ctc56m01.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctc56m01[arr_aux].*  to null
               display    a_ctc56m01[arr_aux].*  to s_ctc56m01[scr_aux].*

            before field clstxt
               display a_ctc56m01[arr_aux].clstxt to
                       s_ctc56m01[scr_aux].clstxt attribute (reverse)

            after field clstxt
               display a_ctc56m01[arr_aux].clstxt to
                       s_ctc56m01[scr_aux].clstxt

               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  let ws.operacao = " "
               end if

               if a_ctc56m01[arr_aux].clstxt is null or
                  a_ctc56m01[arr_aux].clstxt =  "  " then
                  error " Texto em branco nao e' permitido!"
                  next field clstxt
               end if

               if ws.operacao = "i" then
                  select max(clslin)
                    into a_ctc56m01[arr_aux].clslin
                    from datkclstxt
                   where clscod    = par_ctc56m01.clscod
                     and clslinseq = ws.clslinseq

                  if sqlca.sqlcode = notfound then
                     let a_ctc56m01[arr_aux].clslin = 1
                  else
                     let a_ctc56m01[arr_aux].clslin =
                         a_ctc56m01[arr_aux].clslin + 1
                  end if
               end if

            on key (interrupt)
               exit input

      end input

      if int_flag    then
         exit while
      end if

   end while

   let int_flag = false
   close c_ctc56m01
   close window w_ctc56m01

   select max(clslinseq)
          into ws.clslinseq
     from datkclstxt
    where clscod    = par_ctc56m01.clscod
      and ramcod    = par_ctc56m01.ramcod
      and rmemdlcod = par_ctc56m01.rmemdlcod
      and ciaempcod = par_ctc56m01.ciaempcod

   if ws.clslinseq is null then
      let ws.clslinseq = 1
   else
      let ws.clslinseq = ws.clslinseq + 1
   end if

   call cts08g01("A",
                 "S",
                 "",
                 "Deseja gravar as alteracoes?",
                 "",
                 "")
        returning ws.confirma

   if ws.confirma = "S"  then
      begin work
          for i = 1 to 1000
              if a_ctc56m01[i].clstxt is null then
                 exit for
              end if
              insert into datkclstxt
                        ( atlemp, atlusrtip, atlmat, atldat, atlhor,
                          clscod, clslinseq, clstxt, clslin, ramcod,
                          rmemdlcod, clstxtstt, ciaempcod )
                 values ( g_issk.empcod,
                          g_issk.usrtip,
                          g_issk.funmat,
                          today,
                          current hour to minute,
                          par_ctc56m01.clscod,
                          ws.clslinseq,
                          a_ctc56m01[i].clstxt,
                          i,
                          par_ctc56m01.ramcod,
                          par_ctc56m01.rmemdlcod,
                          1, par_ctc56m01.ciaempcod )
          end for
      commit work
   end if
end function  ###  ctc56m01
