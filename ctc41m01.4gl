############################################################################
# Nome do Modulo: ctc41m01                                        Marcelo  #
#                                                                 Gilberto #
# Transfere MDT's de controladora                                 Jan/1999 #
############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
 function ctc41m01(param)
#----------------------------------------------------------------

 define param          record
    mdtctrcod1         like datkmdtctr.mdtctrcod
 end record

 define d_ctc41m01     record
    mdtctrcod2         like datkmdtctr.mdtctrcod,
    mdtctrqtd2         smallint,
    mdtctrqtd3         smallint
 end record

 define ws             record
    mdtctrqtd1         smallint,
    mdtcod             like datkmdt.mdtcod,
    cont               smallint,
    today              date,
    comando            char (250)
 end record



 initialize ws.*          to null
 initialize d_ctc41m01.*  to null
 let ws.today  =  today
 let int_flag  =  false

 let ws.comando = " update datkmdt set (atldat, atlemp, atlmat, mdtctrcod) ",
                                 " =  (?,?,?,?)  ",
                     "where mdtcod = ? "
 prepare  upd_datkmdt  from ws.comando

 select count(*)
   into ws.mdtctrqtd1
   from datkmdt
  where datkmdt.mdtctrcod = param.mdtctrcod1

 if ws.mdtctrqtd1  =  0   then
    error " Controladora nao possui MDT cadastrados!"
    return
 end if


 open window ctc41m01 at 06,02 with form "ctc41m01"
             attribute (form line first)

 select count(*)
   into ws.mdtctrqtd1
   from datkmdt
  where datkmdt.mdtctrcod = param.mdtctrcod1

 display by name param.mdtctrcod1  attribute(reverse)
 display by name ws.mdtctrqtd1     attribute(reverse)

 input by name d_ctc41m01.mdtctrcod2,
               d_ctc41m01.mdtctrqtd3   without defaults

    before field mdtctrcod2
           display by name d_ctc41m01.mdtctrcod2    attribute (reverse)

    after  field mdtctrcod2
           display by name d_ctc41m01.mdtctrcod2

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field  mdtctrcod2
         end if

         if d_ctc41m01.mdtctrcod2  is null    then
            error " Controladora deve ser informada!"
            next field  mdtctrcod2
         end if

         if d_ctc41m01.mdtctrcod2  =  param.mdtctrcod1   then
            error " Controladora atual e de destino nao devem ser iguais!"
            next field  mdtctrcod2
         end if

         select mdtctrcod
           from datkmdtctr
          where datkmdtctr.mdtctrcod = d_ctc41m01.mdtctrcod2

         if sqlca.sqlcode  =  notfound   then
            error " Controladora nao cadastrada!"
            next field mdtctrcod2
         end if

         select count(*)
           into d_ctc41m01.mdtctrqtd2
           from datkmdt
          where datkmdt.mdtctrcod = d_ctc41m01.mdtctrcod2

         display by name d_ctc41m01.mdtctrqtd2   attribute(reverse)

    before field mdtctrqtd3
         display by name d_ctc41m01.mdtctrqtd3    attribute (reverse)

    after  field mdtctrqtd3
         display by name d_ctc41m01.mdtctrqtd3

         if fgl_lastkey() = fgl_keyval ("up")     or
            fgl_lastkey() = fgl_keyval ("left")   then
            next field  mdtctrqtd3
         end if

         if d_ctc41m01.mdtctrqtd3  is null    then
            error " Quantidade de MDT's deve ser informada!"
            next field  mdtctrqtd3
         end if

         if d_ctc41m01.mdtctrqtd3  =  0   then
            error " Quantidade de MDT's nao deve ser zero!"
            next field  mdtctrqtd3
         end if

         if d_ctc41m01.mdtctrqtd3  >  ws.mdtctrqtd1   then
            error " Quantidade de MDT's nao deve ser maior que quantidade de origem!"
            next field  mdtctrqtd3
         end if

         if d_ctc41m01.mdtctrqtd3  >  200   then
            error " Quantidade de MDT's nao deve ser maior que 200!"
            next field  mdtctrqtd3
         end if

    on key (interrupt)
       exit input

 end input

 if not int_flag   then

    message " Aguarde, transferindo..."  attribute(reverse)
    let ws.cont  =  1

    declare c_ctc41m01  cursor with hold for
       select mdtcod
         from datkmdt
        where mdtctrcod  =  param.mdtctrcod1

    foreach c_ctc41m01  into  ws.mdtcod

       begin work

          execute upd_datkmdt  using  ws.today,
                                      g_issk.empcod,
                                      g_issk.funmat,
                                      d_ctc41m01.mdtctrcod2,
                                      ws.mdtcod

          if sqlca.sqlcode  <>  0   then
             error " Erro (",sqlca.sqlcode,") na gravacao da transferencia!"
             rollback work
             exit foreach
          end if

       commit work

       let ws.cont =  ws.cont + 1
       if ws.cont  >  d_ctc41m01.mdtctrqtd3   then
         exit foreach
       end if

    end foreach

 end if

 let int_flag = false
 close window ctc41m01
 return

end function  ###-- ctc41m01


