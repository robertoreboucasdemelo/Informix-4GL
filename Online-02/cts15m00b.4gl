#############################################################################
# Nome do Modulo: CTS15M00B                                        Roberto  #
#                                                                  Mar/2007 #
# Valida o Usuario e Senha do Funcionario  QDO MOTIVO FOR 5 = PARTICULAR    #
#############################################################################

database porto


#----------------------------------------------------------------------
function cts15m00b()
#----------------------------------------------------------------------

define d_cts15m00b1 record

   empcod like datkfun.empcod  ,
   funmat like datkfun.funmat  ,
   funsnh like datkfun.funsnh

end record

define d_cts15m00b2 record

   funnom like isskfunc.funnom ,
   empsgl like gabkemp.empsgl

end record

define ret record

   erro smallint ,
   mens char(100)

end record

define l_cont smallint


let l_cont = null


initialize d_cts15m00b1.* to null

initialize d_cts15m00b2.* to null

initialize ret.* to null

open window cts15m00b at 13,14 with form "cts15m00b"
                      attribute (form line 1, border, comment line last - 1)

message " (F17)Abandona"

display by name d_cts15m00b1.*



    input by name d_cts15m00b1.empcod,
                  d_cts15m00b1.funmat,
                  d_cts15m00b1.funsnh without defaults


before field empcod
          display by name d_cts15m00b1.empcod attribute (reverse)

after  field empcod


          if d_cts15m00b1.empcod is null  then
             error " Informe o codigo da empresa!"
             next field empcod
          end if

          select empsgl
          into d_cts15m00b2.empsgl
          from gabkemp
          where empcod = d_cts15m00b1.empcod

          if sqlca.sqlcode <> 0  then
             error " Empresa nao cadastrada!"
             next field empcod
          end if

          display by name  d_cts15m00b2.empsgl


before field funmat
          display by name d_cts15m00b1.funmat attribute (reverse)

after  field funmat

          display by name d_cts15m00b1.funmat

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field empcod
          end if

          if d_cts15m00b1.funmat is null  then
             error " Informe a Matricula do Funcionario!"
             next field funmat
          end if

          select funnom
          into d_cts15m00b2.funnom
          from isskfunc
          where funmat = d_cts15m00b1.funmat
          and   empcod = d_cts15m00b1.empcod

          if sqlca.sqlcode <> 0  then
             error " Funcionario nao cadastrado!"
             next field funmat
          end if

          display by name d_cts15m00b2.funnom

after field funsnh


          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field funmat
          end if

          if d_cts15m00b1.funsnh is null  then
             error " Informe a Senha!"
             next field funsnh
          end if

          select count(*)
          into l_cont
          from datkfun
          where empcod = d_cts15m00b1.empcod
          and   funmat = d_cts15m00b1.funmat
          and   funsnh = d_cts15m00b1.funsnh



          if l_cont = 0  then
             error " Senha Incorreta!"
             let d_cts15m00b1.funsnh = null
             next field empcod
          else
               let ret.erro = 0
               let ret.mens = "ATENDIMENTO LIBERADO POR : EMPRESA : ", d_cts15m00b1.empcod using "&&"," MATRICULA : "
                           , d_cts15m00b1.funmat using "&&&&&&"," - "
                           , d_cts15m00b2.funnom
          end if


          on key (interrupt)
             let ret.erro = 1
             let ret.mens = ""
             exit input



       end input


  close window cts15m00b

  return ret.*,d_cts15m00b1.empcod,d_cts15m00b1.funmat

end function


