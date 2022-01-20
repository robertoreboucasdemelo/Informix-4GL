#############################################################################
# Nome do Modulo: cts26m05                                         Pedro    #
#                                                                  Marcelo  #
# Informacoes para Entrada via Formulario (Sistema Fora do Ar)     Jan/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 05/07/2000  PSI 10865-0  Akio         Substituicao do atdtip p/ atdsrvorg #
#                                       Exibicao do atdsrvnum (dec 10,0)    #
#############################################################################


 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
 function cts26m05(par_atdsrvorg)
#-----------------------------------------------------------

 define par_atdsrvorg like datmservico.atdsrvorg

 define d_cts26m05   record
    atddat           like datmservico.atddat   ,
    atdhor           like datmservico.atdhor   ,
    funmat           like datmservico.funmat   ,
    atdfunnom        like isskfunc.funnom      ,
    cnldat           like datmservico.cnldat   ,
    atdfnlhor        like datmservico.atdfnlhor,
    c24opemat        like datmservico.c24opemat,
    cnlfunnom        like isskfunc.funnom      ,
    pstcoddig        like dpaksocor.pstcoddig  ,
    nomgrr           like dpaksocor.nomgrr     ,
    confirma         char(01)
 end record



	initialize  d_cts26m05.*  to  null

 let int_flag  =  false
 initialize d_cts26m05.*  to null

 open window cts26m05 at 11,32 with form "cts26m05"
                         attribute (border, form line 1)

 input by name d_cts26m05.atddat   , d_cts26m05.atdhor,
               d_cts26m05.funmat   , d_cts26m05.cnldat,
               d_cts26m05.atdfnlhor, d_cts26m05.c24opemat,
               d_cts26m05.pstcoddig, d_cts26m05.confirma

   before field atddat
      display by name d_cts26m05.atddat    attribute (reverse)

   after field atddat
      display by name d_cts26m05.atddat

      if d_cts26m05.atddat is null   then
         error " Data de atendimento deve ser informada!"
         next field atddat
      end if

      if d_cts26m05.atddat > today   then
         error " Data de atendimento nao pode ser maior que hoje!"
         next field atddat
      end if

      if d_cts26m05.atddat < today - 90 units day  then
         error " Data de atendimento nao pode ser anterior a 90 dias!"
         next field atddat
      end if

   before field atdhor
      display by name d_cts26m05.atdhor attribute (reverse)

   after field atdhor
      display by name d_cts26m05.atdhor

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         next field atddat
      end if

      if d_cts26m05.atdhor is null     or
         d_cts26m05.atdhor = "  "      then
         error " Hora do atendimento deve ser informada!"
         next field atdhor
      end if

      if d_cts26m05.atdhor = "00:00"   then
         error " Hora do atendimento deve ser informada!"
         next field atdhor
      end if

   before field funmat
      display by name d_cts26m05.funmat    attribute (reverse)

   after field funmat
      display by name d_cts26m05.funmat

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if d_cts26m05.funmat   is null   then
            error " Matricula do atendente deve ser informada!"
            next field funmat
         end if

         select funnom
           into d_cts26m05.atdfunnom
           from isskfunc
          where empcod = g_issk.empcod and
                funmat = d_cts26m05.funmat

         if sqlca.sqlcode = notfound   then
            error " Matricula do atendente nao cadastrada!"
            next field funmat
         else
            let d_cts26m05.atdfunnom = upshift(d_cts26m05.atdfunnom)
         end if
         display by name d_cts26m05.atdfunnom
      end if

   before field cnldat
      display by name d_cts26m05.cnldat    attribute (reverse)

   after field cnldat
      display by name d_cts26m05.cnldat

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         next field funmat
      end if

      if d_cts26m05.cnldat is null   then
         error " Data de acionamento deve ser informada!"
         next field cnldat
      end if

      if d_cts26m05.cnldat > today   then
         error " Data de acionamento nao pode ser maior que hoje!"
         next field cnldat
      end if

      if d_cts26m05.cnldat < d_cts26m05.atddat  then
         error " Data de acionamento nao pode ser anterior a data do atendimento!"
         next field cnldat
      end if

   before field atdfnlhor
      display by name d_cts26m05.atdfnlhor attribute (reverse)

   after field atdfnlhor
      display by name d_cts26m05.atdfnlhor

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         next field cnldat
      end if

      if d_cts26m05.atdfnlhor is null     or
         d_cts26m05.atdfnlhor = "  "      then
         error " Hora do acionamento deve ser informada!"
         next field atdfnlhor
      end if

      if d_cts26m05.atdfnlhor = "00:00"   then
         error " Hora do acionamento deve ser informada!"
         next field atdfnlhor
      end if

      if d_cts26m05.atddat = d_cts26m05.cnldat     and
         d_cts26m05.atdhor > d_cts26m05.atdfnlhor  then
         error " Hora do acionamento nao deve ser anterior a hora do atendimento!"
         next field atdfnlhor
      end if

   before field c24opemat
      display by name d_cts26m05.c24opemat attribute (reverse)

   after field c24opemat
      display by name d_cts26m05.c24opemat

      if fgl_lastkey() <> fgl_keyval("up")   and
         fgl_lastkey() <> fgl_keyval("left") then
         if d_cts26m05.c24opemat is null   then
            error " Matricula do operador deve ser informada!"
            next field c24opemat
         end if

         select funnom
           into d_cts26m05.cnlfunnom
           from isskfunc
          where empcod = g_issk.empcod and
                funmat = d_cts26m05.c24opemat

         if sqlca.sqlcode = notfound   then
            error " Matricula do operador nao cadastrada!"
            next field c24opemat
         else
            let d_cts26m05.cnlfunnom = upshift(d_cts26m05.cnlfunnom)
         end if
         display by name d_cts26m05.cnlfunnom
      end if

   before field pstcoddig
      if par_atdsrvorg = 8  then
         next field confirma
      else
         display by name d_cts26m05.pstcoddig attribute (reverse)
      end if

   after field pstcoddig
      display by name d_cts26m05.pstcoddig

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         next field c24opemat
      else
         if d_cts26m05.pstcoddig is null   then
            error " Codigo do prestador que realizou servico deve ser informado!"
            next field pstcoddig
         end if

         select nomgrr
           into d_cts26m05.nomgrr
           from dpaksocor
          where pstcoddig = d_cts26m05.pstcoddig

         if sqlca.sqlcode = NOTFOUND   then
            error " Prestador nao cadastrado!"
            next field pstcoddig
         end if
         display by name d_cts26m05.nomgrr
      end if

   before field confirma
      display by name d_cts26m05.confirma       attribute (reverse)

   after field confirma
      display by name d_cts26m05.confirma

      if fgl_lastkey() = fgl_keyval("up")    or
         fgl_lastkey() = fgl_keyval("left")  then
         if par_atdsrvorg = 8  then
            next field funmat
         else
            next field pstcoddig
         end if
      end if

      if d_cts26m05.confirma is null  then
         error " Confirme os dados digitados!"
         next field confirma
      end if

      if d_cts26m05.confirma <> "S"  and
         d_cts26m05.confirma <> "N"  then
         error " Confirma dados: (S)im ou (N)ao!"
         next field confirma
      end if

      if d_cts26m05.confirma = "N"  then
         initialize d_cts26m05.* to null
         exit input
      end if

   on key (interrupt)
      initialize d_cts26m05.* to null
      exit input

 end input

 let int_flag = false
 close window cts26m05

 return d_cts26m05.atddat   ,
        d_cts26m05.atdhor   ,
        d_cts26m05.funmat   ,
        d_cts26m05.cnldat   ,
        d_cts26m05.atdfnlhor,
        d_cts26m05.c24opemat,
        d_cts26m05.pstcoddig

end function  ###  cts26m05
