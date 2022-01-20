############################################################################
# Menu de Modulo: CTC24M01                                        Marcelo  #
#                                                                 Gilberto #
# Manutencao dos Procedimentos                                    Mar/1996 #
############################################################################
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONS. DESCRICAO                              #
#--------------------------------------------------------------------------#
# 24/04/2000  Correio      Akio     Array aumentado p/ 300 ocorrencias     #
#--------------------------------------------------------------------------#
# 02/01/2002  PSI 144908   Ruiz     Guardar historico da alteracao.        #
# 05/08/2008  Correio      Nilo     Array aumentado p/ 500 ocorrencias     #
############################################################################
#..........................................................................#
#                  * * *  ALTERACOES  * * *                                #
#                                                                          #
# Data       Autor Fabrica PSI       Alteracao                             #
# --------   ------------- --------  --------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.            #
#--------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

 define wg_cvntopdesseq  like datkdestopcvn.cvntopdesseq

#--------------------------------------------------------------------
 function ctc24m01(par_operacao, par_ctc24m01)
#--------------------------------------------------------------------
  define par_operacao char(01)

  define par_ctc24m01 record
         cvnnum       like datktopcvn.cvnnum    ,
         cvntopcod    like datktopcvn.cvntopcod ,
         cvntopnom    like datktopcvn.cvntopnom
  end record

  define a_ctc24m01 array[500] of record
     cvntopdes      like datkdestopcvn.cvntopdes ,
     cvntopdesseq   like datkdestopcvn.cvntopdesseq
  end record

  define arr_aux    smallint
  define scr_aux    smallint
  define i          smallint

  define ws           record
     operacao         char(01)                     ,
     cont             smallint                     ,
     convenio         char(20)                     ,
     cvntopdes        like datkdestopcvn.cvntopdes ,
     erro             dec(01,0)                    ,
     cvntopdesseq     like datkdestopcvn.cvntopdesseq,
     flghst           dec(01,0),
     arq              char(15)
  end record

  declare c_ctc24m01  cursor for
     select cvntopdes, cvntopdesseq
       from datkdestopcvn
      where cvnnum    = par_ctc24m01.cvnnum    and
            cvntopcod = par_ctc24m01.cvntopcod

  initialize a_ctc24m01  to null
  initialize ws.*        to null

  let arr_aux = 1

  foreach c_ctc24m01 into a_ctc24m01[arr_aux].cvntopdes    ,
                          a_ctc24m01[arr_aux].cvntopdesseq
     let arr_aux = arr_aux + 1
     if arr_aux > 500 then
        error " Limite excedido! Foram encontradas mais de 500",
              " linhas de procedimento!"
        exit foreach
     end if
  end foreach

  call set_count(arr_aux-1)

  open window w_ctc24m01 at 06,02 with form "ctc24m01"
       attribute(form line first,message line last -1)

  select cpodes
    into ws.convenio
    from datkdominio
   where cponom = "ligcvntip"
     and cpocod = par_ctc24m01.cvnnum

  display par_ctc24m01.cvnnum    to cvnnum
  display ws.convenio            to convenio
  display par_ctc24m01.cvntopcod to cvntopcod
  display par_ctc24m01.cvntopnom to cvntopnom

  if par_operacao = "a" then
     whenever error continue
       create temp table tmptopcvn
          (cvnnum       smallint,
           cvntopcod    decimal(2,0),
           cvntopdesseq smallint,
           cvntopdes    char(70)) with no log
     whenever error stop
     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode  = -310 or
           sqlca.sqlcode  = -958 then  # tabela ja existe
           delete from tmptopcvn
        else
           error "ERRO CreateTempTable tmptopcvn -> ",sqlca.sqlcode
           close window w_ctc24m01
           return
        end if
     end if
     let ws.arq = g_issk.funmat using "&&&&&&",g_issk.maqsgl clipped
     if g_issk.funmat = 601566 then
        display "** ws.arq = ", ws.arq
     end if
     unload to ws.arq
        select * from datkdestopcvn
           where cvnnum    = par_ctc24m01.cvnnum and
                 cvntopcod = par_ctc24m01.cvntopcod

     load from ws.arq
        insert into tmptopcvn

     let ws.flghst = 1
     if g_issk.funmat = 601566 then
        display "** carreguei a temp "
     end if
  end if

   while true
      let int_flag = false

      message "(F1)Inclui, (F2)Exclui"

      input array a_ctc24m01 without defaults from s_ctc24m01.*
            before row
               let arr_aux = arr_curr()
               let scr_aux = scr_line()
               if arr_aux <= arr_count()  then
                  let ws.operacao = "a"
               end if

            before insert
               let ws.operacao = "i"
               initialize a_ctc24m01[arr_aux].*  to null
               display    a_ctc24m01[arr_aux].*  to s_ctc24m01[scr_aux].*

            before field cvntopdes
               display a_ctc24m01[arr_aux].cvntopdes to
                       s_ctc24m01[scr_aux].cvntopdes attribute (reverse)

            after field cvntopdes
               display a_ctc24m01[arr_aux].cvntopdes to
                       s_ctc24m01[scr_aux].cvntopdes

               if fgl_lastkey() = fgl_keyval("up")    or
                  fgl_lastkey() = fgl_keyval("left")  then
                  let ws.operacao = " "
               end if

               if a_ctc24m01[arr_aux].cvntopdes is null or
                  a_ctc24m01[arr_aux].cvntopdes =  "  " then
                  error " Procedimento em branco nao e' permitido!"
                  next field cvntopdes
               end if

               if ws.operacao = "i" then
                  select max(cvntopdesseq)
                    into a_ctc24m01[arr_aux].cvntopdesseq
                    from datkdestopcvn
                   where cvnnum    = par_ctc24m01.cvnnum    and
                         cvntopcod = par_ctc24m01.cvntopcod

                  if sqlca.sqlcode = notfound then
                     let a_ctc24m01[arr_aux].cvntopdesseq = 1
                  else
                     let a_ctc24m01[arr_aux].cvntopdesseq =
                         a_ctc24m01[arr_aux].cvntopdesseq + 1
                  end if
               end if

            on key (interrupt)
               exit input

            before delete
               let ws.cont = 0
               select count(*)  into  ws.cont
                 from datkdestopcvn
                where cvnnum    = par_ctc24m01.cvnnum and
                      cvntopcod = par_ctc24m01.cvntopcod

               if ws.cont =  1   then
                  error "O procedimento nao pode ser removido! Remova o topico."
                  exit input
               end if

               let ws.operacao = "d"
               if a_ctc24m01[arr_aux].cvntopdes is null then
                  continue input
               else
                  if cts08g01("A","S","","CONFIRMA A EXCLUSAO ?",
                               "","") = "N"  then
                     exit input
                  end if
                  begin work
                    delete from datkdestopcvn
                           where cvnnum       = par_ctc24m01.cvnnum        and
                                 cvntopcod    = par_ctc24m01.cvntopcod     and
                                 cvntopdesseq = a_ctc24m01[arr_aux].cvntopdesseq
                  commit work

                  initialize a_ctc24m01[arr_aux].* to null
                  display    a_ctc24m01[arr_aux].* to s_ctc24m01[scr_aux].*
               end if

            after row
               begin work

               case ws.operacao
                  when "i"
                     if par_operacao = "i"   then  #--> qdo inclui nome
                        initialize par_operacao  to null
                        call nome_ctc24m01 ( par_ctc24m01.cvnnum    ,
                                             par_ctc24m01.cvntopnom )
                             returning par_ctc24m01.cvntopcod
                        if par_ctc24m01.cvntopcod  is null   then
                           exit input
                        end if
                     end if

                     select max(cvntopdesseq)
                       into a_ctc24m01[arr_aux].cvntopdesseq
                       from datkdestopcvn
                      where cvnnum    = par_ctc24m01.cvnnum    and
                            cvntopcod = par_ctc24m01.cvntopcod

                     if a_ctc24m01[arr_aux].cvntopdesseq is null then
                        let a_ctc24m01[arr_aux].cvntopdesseq = 1
                     else
                        let a_ctc24m01[arr_aux].cvntopdesseq =
                            a_ctc24m01[arr_aux].cvntopdesseq + 1
                     end if

                     insert into datkdestopcvn
                            ( cvnnum, cvntopcod, cvntopdes, cvntopdesseq )
                     values ( par_ctc24m01.cvnnum              ,
                              par_ctc24m01.cvntopcod           ,
                              a_ctc24m01[arr_aux].cvntopdes    ,
                              a_ctc24m01[arr_aux].cvntopdesseq )

                  when "a"
                     update datkdestopcvn set
                            ( cvntopdes ) = ( a_ctc24m01[arr_aux].cvntopdes )
                      where cvnnum        =  par_ctc24m01.cvnnum       and
                            cvntopcod     =  par_ctc24m01.cvntopcod    and
                            cvntopdesseq  =  a_ctc24m01[arr_aux].cvntopdesseq
               end case

               commit work
               let ws.operacao = " "
      end input

      if int_flag    then
         exit while
      end if

   end while

   let int_flag = false
   close c_ctc24m01
   close window w_ctc24m01

  #for i = 1 to 10
  #  display i," ",a_ctc24m01[i].cvntopdesseq," ",a_ctc24m01[i].cvntopdes
  #end for

   select max(cvntopdesseq)
      into ws.cvntopdesseq
      from datkdestopcvn
     where cvnnum    = par_ctc24m01.cvnnum    and
           cvntopcod = par_ctc24m01.cvntopcod
   if g_issk.funmat = 601566 then
      display "par_operacao = ", par_operacao
      display "ws.operacao  = ", ws.operacao
      display "ws.flghst    = ", ws.flghst
   end if  
   if ws.flghst       =  1    then          #checa se houve alteracao de proced.
      begin work
      call ctc24m01_grava_historico(par_ctc24m01.cvnnum,
                                    par_ctc24m01.cvntopcod)
               returning ws.erro
      if g_issk.funmat = 601566 then
         display "***** sai do historico - ", ws.erro
      end if
      if ws.erro  <> 0  then
         error " Erro na inclusao do historico-",ws.erro,"!!",
               " AVISE A INFORMATICA "
         rollback work
      else   
         delete from datkdestopcvn
             where cvnnum    = par_ctc24m01.cvnnum        and
                   cvntopcod = par_ctc24m01.cvntopcod
          for i = 1 to 500
              if a_ctc24m01[i].cvntopdes is null then 
                 exit for
              end if         
              if g_issk.funmat = 601566 then
                 display "i = ", i," ",a_ctc24m01[i].cvntopdes
              end if
              insert into datkdestopcvn
                        ( cvnnum, cvntopcod, cvntopdes, cvntopdesseq )
                 values ( par_ctc24m01.cvnnum    ,
                          par_ctc24m01.cvntopcod ,
                          a_ctc24m01[i].cvntopdes,
                          i )
          end for
          commit work
      end if
   end if
end function  ###  ctc24m01

#---------------------------------------------------------------
 function ctc24m01_grava_historico(param)                    
#---------------------------------------------------------------
  define param  record
         cvnnum    like datmtopcvnhst.cvnnum,
         cvntopcod like datmtopcvnhst.cvntopcod
  end record
  define ws     record
         cvntopseq    like datmtopcvnhst.cvntopseq,
         cvntopdesseq like datkdestopcvn.cvntopdesseq,
         cvntopdes    like datkdestopcvn.cvntopdes,
         erro         dec(1,0)
  end record
  let ws.erro = 0   

  select max(cvntopseq)
      into ws.cvntopseq
      from datmtopcvnhst
     where cvnnum    = param.cvnnum
       and cvntopcod = param.cvntopcod

  if ws.cvntopseq  is null then
     let ws.cvntopseq  = 1
  else
     let ws.cvntopseq  = ws.cvntopseq  + 1
  end if
  insert into datmtopcvnhst
           (cvnnum,cvntopcod,cvntopseq,empcod,usrtip,funmat,atldat,atlhor)
    values (param.cvnnum,
            param.cvntopcod,
            ws.cvntopseq,
            g_issk.empcod,
            g_issk.usrtip,
            g_issk.funmat,
            today        ,
            current      )
  if sqlca.sqlcode <> 0   then
     let ws.erro = 1
  else    
     declare c_ctc24m01a  cursor for
         select cvntopdesseq,cvntopdes
         from tmptopcvn
        where cvnnum    = param.cvnnum    and
              cvntopcod = param.cvntopcod

     foreach c_ctc24m01a into ws.cvntopdesseq, 
                              ws.cvntopdes    
         insert into datmdestopcvnhst
                  (cvnnum,cvntopcod,cvntopseq,cvntopdesseq,cvntopdes)
           values (param.cvnnum,
                   param.cvntopcod,
                   ws.cvntopseq,
                   ws.cvntopdesseq,
                   ws.cvntopdes)
          if sqlca.sqlcode <> 0   then
             let ws.erro = 2
             exit foreach
          end if
          if ws.cvntopdesseq = wg_cvntopdesseq then
             exit foreach
          end if
     end foreach
  end if
  return ws.erro
 end function
#---------------------------------------------------------------
 function nome_ctc24m01(par_cvnnum, par_cvntopnom)
#---------------------------------------------------------------
  define par_cvnnum    like datktopcvn.cvnnum
  define par_cvntopnom like datktopcvn.cvntopnom

  define ret_cvntopcod like datktopcvn.cvntopcod

  define ws_resp       char(01)

  select max(cvntopcod)
    into ret_cvntopcod
    from datktopcvn
   where cvnnum = par_cvnnum

  if ret_cvntopcod is null then
    let ret_cvntopcod = 1
  else
    let ret_cvntopcod = ret_cvntopcod + 1
  end if

  insert into datktopcvn ( cvnnum,     cvntopcod,     cvntopnom     )
                  values ( par_cvnnum, ret_cvntopcod, par_cvntopnom )

  if sqlca.sqlcode <> 0   then
     error " Erro na inclusao do topico! AVISE A INFORMATICA "
     rollback work
     initialize ret_cvntopcod to null
  else
     display ret_cvntopcod to cvntopcod
  end if

  return ret_cvntopcod

end function  ###  nome_ctc24m01
