###############################################################################
# Nome do Modulo: CTO00M04                                           Ruiz     #
#                                                                    Akio     #
# Mostra o cadastro de assuntos por agrupamento                      Abr/2000 #
###############################################################################

database porto

#-----------------------------#
function cto00m04(lr_parametro)
#-----------------------------#

  define lr_parametro record
         codagrup     smallint,
         pgm          char(08)
  end record

  define lr_dados     record
         corasspndflg like dackass.corasspndflg,
         corassagpcod like dackass.corassagpcod,
         codagrup     smallint,
         atdexbflg    like dackass.atdexbflg
  end record

  define al_cto00m04  array[500] of record
         corasscod    like dackass.corasscod,
         corassdes    like dackass.corassdes
  end record

  define l_contador   smallint,
         l_sql        char(200)

  initialize lr_dados, al_cto00m04 to null

  let l_contador = 1

  if lr_parametro.codagrup is null then

     let l_sql = " select corasscod, ",
                        " corassdes, ",
                        " corasspndflg, ",
                        " corassagpcod, ",
                        " atdexbflg ",
                   " from dackass ",
                  " where corassagpcod > 0 ",
                  " order by 2 "
  else
     if lr_parametro.pgm = "cte02m00" then
        let lr_dados.codagrup = 1
     else
        let lr_dados.codagrup = lr_parametro.codagrup
     end if

     let l_sql = " select corasscod, ",
                        " corassdes, ",
                        " corasspndflg, ",
                        " corassagpcod, ",
                        " atdexbflg ",
                   " from dackass ",
                  " where corassagpcod in (", lr_dados.codagrup, ",", lr_parametro.codagrup, ")",
                  " order by 2 "
  end if

  prepare pcto00m04001 from l_sql
  declare ccto00m04001 cursor for pcto00m04001

  open window cto00m04 at 10,30 with form "cto00m04"
     attribute(form line 1, border)

  open ccto00m04001

  foreach ccto00m04001 into al_cto00m04[l_contador].corasscod,
                            al_cto00m04[l_contador].corassdes,
                            lr_dados.corasspndflg,
                            lr_dados.corassagpcod,
                            lr_dados.atdexbflg

     if lr_dados.atdexbflg = "N" or
        lr_dados.atdexbflg is null then
        continue foreach
     end if

     # --PENDENCIA, SO MOSTRA O ASSUNTO COM FLAG = "S"
     if lr_parametro.pgm = "cte02m00" then

        if lr_dados.corasspndflg = "N" and
           lr_dados.corassagpcod <> 1 then
           continue foreach
        end if

     end if

     let l_contador = l_contador + 1

  end foreach

  message "     (F17)Abandona   (F8)Seleciona"

  let l_contador = l_contador - 1

  call set_count(l_contador)

  display array al_cto00m04 to s_cto00m04.*

     on key (f17, interrupt, control-c)
        initialize al_cto00m04 to null
        exit display

     on key (F8)
        let l_contador = arr_curr()
        exit display

  end display

  close window cto00m04

  let int_flag = false

  return al_cto00m04[l_contador].corasscod,
         al_cto00m04[l_contador].corassdes

end function
