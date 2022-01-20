#-----------------------------------------------------------------------------#
# Sistema    : Porto Socorro                                                  #
# Modulo     : ctc00m18                                                       #
# Programa   : ctc00m18 - Popup faixa salarial - Circular 380                 #
#-----------------------------------------------------------------------------#
# Analista Resp. : Robert Lima                                                #
# PSI            : 259136                                                     #
#                                                                             #
# Desenvolvedor  : Robert Lima                                                #
# DATA           : 19/07/2010                                                 #
#.............................................................................#
# Data        Autor      Alteracao                                            #
#                                                                             #
# ----------  ---------  -----------------------------------------------------#
#-----------------------------------------------------------------------------#


 database porto

#=============================
function ctc00m18(l_tipoFaixa)
#=============================

define l_tipoFaixa smallint

define ctc00m18_faixa record
  faixa_mensal   char(30),
  empcod         like gsakmenrenfxa.empcod,
  codseq         smallint
end record

case l_tipoFaixa
   when 1
        call ctc00m18_fxaren()
          returning ctc00m18_faixa.faixa_mensal,
                    ctc00m18_faixa.empcod      ,
                    ctc00m18_faixa.codseq
   when 2
        call ctc00m18_fxaptrliq()
          returning ctc00m18_faixa.faixa_mensal,
                    ctc00m18_faixa.empcod      ,
                    ctc00m18_faixa.codseq

   when 3
        call ctc00m18_anobrtoprrctdes()
          returning ctc00m18_faixa.faixa_mensal,
                    ctc00m18_faixa.empcod      ,
                    ctc00m18_faixa.codseq
end case

return ctc00m18_faixa.faixa_mensal,
       ctc00m18_faixa.empcod,
       ctc00m18_faixa.codseq


end function
#=============================
function ctc00m18_fxaren()
#=============================

 define ctc00m18_faixa ARRAY[5] OF RECORD
   faixa_mensal   char(30)
 end record
 define ctc00m18_fxacod ARRAY[5] of record
   empcod       like gsakmenrenfxa.empcod,
   renfxacod    like gsakmenrenfxa.renfxacod,
   renfxaincvlr like gsakmenrenfxa.renfxaincvlr,
   renfxafnlvlr like gsakmenrenfxa.renfxafnlvlr
 end record
 define l_indice       smallint
 open window w_popup_faixa_mensal AT 10,30 WITH FORM "ctc00m18"
        ATTRIBUTE (border, form line first)

 let l_indice = 1

 declare cctc00m18_faixa_001 cursor for
    select empcod,
           renfxacod,
           renfxaincvlr,
           renfxafnlvlr
      from gsakmenrenfxa
     where empcod = 1
 foreach cctc00m18_faixa_001 into ctc00m18_fxacod[l_indice].empcod,
                                  ctc00m18_fxacod[l_indice].renfxacod,
                                  ctc00m18_fxacod[l_indice].renfxaincvlr,
                                  ctc00m18_fxacod[l_indice].renfxafnlvlr
       let ctc00m18_faixa[l_indice].faixa_mensal = "De ",ctc00m18_fxacod[l_indice].renfxaincvlr
       let ctc00m18_faixa[l_indice].faixa_mensal = ctc00m18_faixa[l_indice].faixa_mensal clipped,
                                                   " ate ",ctc00m18_fxacod[l_indice].renfxafnlvlr
       let ctc00m18_faixa[l_indice].faixa_mensal = ctc00m18_faixa[l_indice].faixa_mensal clipped
       let l_indice = l_indice + 1
 end foreach
 call set_count(l_indice-1)
 display "     Faixa de Renda Mensal" to texto
 display ARRAY ctc00m18_faixa to s_ctc00m18_faixa.*
        on key(control-c)
                initialize l_indice to null
                exit display

        on key(F8)
                let l_indice = arr_curr()
                exit display
 end display
 close window w_popup_faixa_mensal
 if l_indice is null then
    return l_indice,l_indice,l_indice
 else
    return ctc00m18_faixa[l_indice].faixa_mensal,
           ctc00m18_fxacod[l_indice].empcod,
           ctc00m18_fxacod[l_indice].renfxacod
 end if

end function


#=============================
function ctc00m18_fxaptrliq()
#=============================

 define ctc00m18_faixa ARRAY[5] OF RECORD
   faixa_mensal   char(30)
 end record
 define ctc00m18_fxacod ARRAY[5] of record
   empcod          like gsakliqptrfxa.empcod,
   liqptrfxacod    like gsakliqptrfxa.liqptrfxacod,
   liqptrfxaincvlr like gsakliqptrfxa.liqptrfxaincvlr,
   liqptrfxafnlvlr like gsakliqptrfxa.liqptrfxafnlvlr
 end record
 define l_indice       smallint
 open window w_popup_faixa_mensal AT 10,30 WITH FORM "ctc00m18"
        ATTRIBUTE (border, form line first)

 let l_indice = 1

 declare cctc00m18_faixa_002 cursor for
    select empcod,
           liqptrfxacod,
           liqptrfxaincvlr,
           liqptrfxafnlvlr
      from gsakliqptrfxa
     where empcod = 1
 foreach cctc00m18_faixa_002 into ctc00m18_fxacod[l_indice].empcod,
                                  ctc00m18_fxacod[l_indice].liqptrfxacod,
                                  ctc00m18_fxacod[l_indice].liqptrfxaincvlr,
                                  ctc00m18_fxacod[l_indice].liqptrfxafnlvlr
       let ctc00m18_faixa[l_indice].faixa_mensal = "De ",ctc00m18_fxacod[l_indice].liqptrfxaincvlr
       let ctc00m18_faixa[l_indice].faixa_mensal = ctc00m18_faixa[l_indice].faixa_mensal clipped ,
                                                   " ate ",ctc00m18_fxacod[l_indice].liqptrfxafnlvlr
       let ctc00m18_faixa[l_indice].faixa_mensal = ctc00m18_faixa[l_indice].faixa_mensal clipped
       let l_indice = l_indice + 1
 end foreach
 call set_count(l_indice-1)
 display "      Patrimonio Liquido" to texto
 display ARRAY ctc00m18_faixa to s_ctc00m18_faixa.*
        on key(control-c)
                let l_indice = null
                exit display

        on key(F8)
                let l_indice = arr_curr()
                exit display
 end display
 close window w_popup_faixa_mensal
 if l_indice is null then
    return l_indice,l_indice,l_indice
 else
    return ctc00m18_faixa[l_indice].faixa_mensal,
           ctc00m18_fxacod[l_indice].empcod,
           ctc00m18_fxacod[l_indice].liqptrfxacod
 end if

end function

#=============================
function ctc00m18_anobrtoprrctdes()
#=============================

 define ctc00m18_faixa ARRAY[6] OF RECORD
   faixa_mensal   char(30)
 end record
 define l_indice smallint
 open window w_popup_faixa_mensal AT 10,30 WITH FORM "ctc00m18"
        ATTRIBUTE (border, form line first)

 let ctc00m18_faixa[1].faixa_mensal = "Sem Receita Bruta"
 let ctc00m18_faixa[2].faixa_mensal = "Ate 1.199.999"
 let ctc00m18_faixa[3].faixa_mensal = "De 1.200.000 ate 10.499.999"
 let ctc00m18_faixa[4].faixa_mensal = "De 10.500.000 ate 59.999.999"
 let ctc00m18_faixa[5].faixa_mensal = "Acima de 60.000.000"
 let ctc00m18_faixa[6].faixa_mensal = "Não desejo informar"
 call set_count(6)
 display "Receita operacional bruta anual" to texto
 display ARRAY ctc00m18_faixa to s_ctc00m18_faixa.*
        on key(control-c)
                initialize l_indice to null
                exit display

        on key(F8)
                let l_indice = arr_curr()
                exit display
 end display
 close window w_popup_faixa_mensal
 if l_indice is null then
    return l_indice,0,0
 else
    return ctc00m18_faixa[l_indice].faixa_mensal,
           l_indice,0
 end if

end function

#=============================
function ctc00m18_pep()
#=============================

 define ctc00m18_pep ARRAY[3] OF RECORD
   pep   char(22)
 end record
 define l_indice smallint
 open window w_popup_pep AT 10,30 WITH FORM "ctc00m18"
        ATTRIBUTE (border, form line first)

 let l_indice = 3
 let ctc00m18_pep[1].pep = "Sim"
 let ctc00m18_pep[2].pep = "Não"
 let ctc00m18_pep[3].pep = "Relacionamento próximo"
 call set_count(l_indice)
 display " Pessoa Exposta Politicamente" to texto
 display ARRAY ctc00m18_pep to s_ctc00m18_faixa.*
        on key(control-c)
                initialize l_indice to null
                exit display

        on key(F8)
                let l_indice = arr_curr()
                exit display
 end display
 close window w_popup_pep
 if l_indice is null then
    return l_indice
 else
    return ctc00m18_pep[l_indice].pep
 end if

end function
