###########################################################################
# Nome do Modulo: ctc40m01                                       Marcelo  #
#                                                                Gilberto #
# Cadastro de dominios                                           Mar/1999 #
###########################################################################

 database porto

#------------------------------------------------------------
 function ctc40m01(param)
#------------------------------------------------------------

 define param         record
    atlult            like iddkdominio.atlult
 end record

 define d_ctc40m01    record
    atldat            char (10),
    atlhor            char (05),
    atlemp            like isskfunc.empcod,
    atlmat            like isskfunc.funmat,
    atlfunnom         like isskfunc.funnom
 end record

 define ws            record
    sql               char (100)
 end record

 define prompt_key    char (01)

 let int_flag = false

 initialize d_ctc40m01.*  to null

 open window ctc40m01 at 13,25 with form "ctc40m01"
                      attribute (border, form line first, message line last - 1)

 let ws.sql = "select funnom from isskfunc",
              " where empcod = ? and funmat = ?"
 prepare sel_isskfunc from ws.sql
 declare c_isskfunc cursor with hold for sel_isskfunc

 let d_ctc40m01.atldat = param.atlult[5,6],"/",
                         param.atlult[3,4],"/",
                         param.atlult[1,2]

 let d_ctc40m01.atlhor = param.atlult[7,8],":",
                         param.atlult[9,10] 

 let d_ctc40m01.atlemp = param.atlult[12,13]
 let d_ctc40m01.atlmat = param.atlult[14,19]

 let d_ctc40m01.atlfunnom = "*** NAO CADASTRADO ***"

 open  c_isskfunc using d_ctc40m01.atlemp,
                        d_ctc40m01.atlmat
 fetch c_isskfunc into  d_ctc40m01.atlfunnom
 close c_isskfunc

 let d_ctc40m01.atlfunnom = upshift(d_ctc40m01.atlfunnom)

 display by name d_ctc40m01.*

 message " (F17)Abandona"
 prompt "" for char prompt_key

 let int_flag = false

 close window ctc40m01

 end function  ###  ctc40m01
