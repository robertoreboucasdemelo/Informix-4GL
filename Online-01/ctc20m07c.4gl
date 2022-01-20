#---------------------------------------------------------
function ctc20m07c_motivo(l_cabec)
#---------------------------------------------------------

 define linha1       char(120),
        l_cabec        char(40),
        l_confirma     char(01),
        l_sql   char(200)

 let linha1 = null

 open window w_ctc20m07c at 10,20 with form "ctc20m07c"
                         attribute (form line 1, border, comment line last - 1)

 display l_cabec to cabtxt attribute (reverse)

 input by name linha1 without defaults


     before field linha1
        display by name linha1


     after field linha1
        display  by name linha1

        if linha1 is null then
          error " Motivo da penalidade deve ser informado"
          next field linha1
       else
          #let l_plemtvtxt = a_ctc20m07c.linha1,a_ctc20m07c.linha2, a_ctc20m07c.linha3
          exit input
       end if

    #before field linha2
    #    display a_ctc20m07c.linha2   to
    #            s_ctc20m07c.linha2   attribute (reverse)
    #
    #
    # after field linha2
    #    display a_ctc20m07c.linha2   to
    #            s_ctc20m07c.linha2
    #
    #before field linha3
    #    display a_ctc20m07c.linha3   to
    #            s_ctc20m07c.linha3   attribute (reverse)
    #
    #
    # after field linha3
    #    display a_ctc20m07c.linha3   to
    #            s_ctc20m07c.linha3
    #
    #    error " Selecione F8 para Salvar ou F17 para retornar"
    #    next field linha3

    on key (interrupt,control-c)
          if linha1 is null then
             error " Motivo da penalidade deve ser informado"
             next field linha1
          end if

 end input


 close window w_ctc20m07c

 return linha1

end function   # ctc20m07a_func
