#############################################################################
# Nome do Modulo: cts12m02                                         Marcelo  #
#                                                                  Gilberto #
#                                                                  Wagner   #
# Manutencao complemento do veiculo para RPT                       jul/1999 #
#############################################################################

 database porto


#--------------------------------------------------------------
 function cts12m02(param)
#--------------------------------------------------------------

 define param         record
    rptvclsitdsmflg   like datmrpt.rptvclsitdsmflg,
    rptvclsitestflg   like datmrpt.rptvclsitestflg,
    dddcod            like datmrpt.dddcod,
    telnum            like datmrpt.telnum
 end record

 define d_cts12m02    record
    rptvclsitdsmflg   like datmrpt.rptvclsitdsmflg,
    rptvclsitestflg   like datmrpt.rptvclsitestflg,
    dddcod            like datmrpt.dddcod,
    telnum            like datmrpt.telnum
 end record



	initialize  d_cts12m02.*  to  null

 let d_cts12m02.* = param.*

 let int_flag  =  false

 open window cts12m02 at 11,13 with form "cts12m02"
                         attribute (form line 1, border)

 input by name d_cts12m02.rptvclsitdsmflg,
               d_cts12m02.rptvclsitestflg,
               d_cts12m02.dddcod,
               d_cts12m02.telnum
       without defaults

      before field rptvclsitdsmflg
          display by name d_cts12m02.rptvclsitdsmflg    attribute (reverse)

      after  field rptvclsitdsmflg
          display by name d_cts12m02.rptvclsitdsmflg

          if ((d_cts12m02.rptvclsitdsmflg  is null)    or
              (d_cts12m02.rptvclsitdsmflg  <> "S"     and
               d_cts12m02.rptvclsitdsmflg  <> "N"))   then
             error " Favor informar se veiculo esta desmontado: (S)im ou (N)ao!"
             next field rptvclsitdsmflg
          end if

      before field rptvclsitestflg
          display by name d_cts12m02.rptvclsitestflg    attribute (reverse)

      after  field rptvclsitestflg
          display by name d_cts12m02.rptvclsitestflg

          if fgl_lastkey() = fgl_keyval("up")     or
             fgl_lastkey() = fgl_keyval("left")   then
             next field rptvclsitdsmflg
          end if

          if ((d_cts12m02.rptvclsitestflg  is null)    or
              (d_cts12m02.rptvclsitestflg  <> "S"     and
               d_cts12m02.rptvclsitestflg  <> "N"))   then
             error " Favor informar se havera cobranca de estadia: (S)im ou (N)ao!"
             next field rptvclsitestflg
          end if

      before field dddcod
          display by name d_cts12m02.dddcod  attribute (reverse)

      after  field dddcod
          display by name d_cts12m02.dddcod

          if fgl_lastkey() = fgl_keyval("up")    or
             fgl_lastkey() = fgl_keyval("left")  then
             next field rptvclsitestflg
          end if

       if d_cts12m02.dddcod is  null then
          error " DDD solicitante deve ser informado!"
          next field dddcod
       end if

      before field telnum
          display by name d_cts12m02.telnum  attribute (reverse)

      after  field telnum
          display by name d_cts12m02.telnum

         if fgl_lastkey() = fgl_keyval("up")    or
            fgl_lastkey() = fgl_keyval("left")  then
            next field dddcod
         end if

       if d_cts12m02.telnum is  null then
          error " Telefone solicitante deve ser informado!"
          next field telnum
       end if

       if d_cts12m02.telnum <= 9999999  then
          error " Telefone invalido! Informe novamente."
          next field telnum
       end if

       on key (interrupt)
          exit input

 end input

 close window cts12m02

 if int_flag = false then
    let param.* = d_cts12m02.*
 end if

 let int_flag = false

 return param.rptvclsitdsmflg,
        param.rptvclsitestflg,
        param.dddcod,
        param.telnum

end function  ###  cts12m02
