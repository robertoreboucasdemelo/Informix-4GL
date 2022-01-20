#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Porto Socorro                                              #
# Modulo        : ctb00g04                                                   #
# Analista Resp.: Carlos Zyon                                                #
# PSI           : 187143                                                     #
#                 Mostrar conteudo da tabela temporaria.                     #
#                                                                            #
#............................................................................#
# Desenvolvimento: Robson Inocencio, META                                    #
# Liberacao      : 27/08/2004                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql smallint

#--------------------------#
function ctb00g04_prepare()
#--------------------------#
 define l_sql char(100)

 let l_sql = ' select linha '
              ,' from tmpctb00g04 '
 prepare pctb00g04001 from l_sql
 declare cctb00g04001 cursor for pctb00g04001

 let m_prep_sql = true
 
end function

#------------------#
function ctb00g04()
#------------------#
 define al_ctb00g04 array[1000] of record
    linha char(75)
 end record

 define l_i smallint

 if m_prep_sql is null or 
    m_prep_sql <> true then
    call ctb00g04_prepare()
 end if

 initialize al_ctb00g04 to null
 let l_i = 1

 open cctb00g04001
 
 foreach cctb00g04001 into al_ctb00g04[l_i].linha

    let l_i = l_i + 1

    if l_i > 1000 then
       error ' Limite de array excedido ' sleep 2
       exit foreach
    end if

 end foreach
 close cctb00g04001

 if l_i = 1 then
    error ' Nao existem totais para o servico ' sleep 2
 else

    open window w_ctb00g04 at 06,02 with form "ctb00g04"
         attribute (form line 1)

    let l_i = l_i - 1
    call set_count(l_i)

    message '(CTR-C/F17) Abandona'

    display array al_ctb00g04 to s_ctb00g04.*
   
       on key(f17, control-c,interrupt)
          exit display
   
    end display
 end if
 if int_flag then
    let int_flag = false
 end if

 if l_i <> 1 then
    close window w_ctb00g04
 end if

end function
