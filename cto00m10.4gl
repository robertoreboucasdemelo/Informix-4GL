#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cto00m10                                                   #
# Objetivo.......: Popup Generica Itau                                        #
# Analista Resp. : Roberto Melo                                               #
# PSI            :                                                            #
#.............................................................................#
# Desenvolvimento: Roberto Melo                                               #
# Liberacao      : 24/01/2010                                                 #
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 08/09/2011   Marcos Goes                Adaptacao dos campos do novo layout #
#                                         do Itau adicionados a global.       #
#-----------------------------------------------------------------------------#
# 13/05/2015 Roberto                      PJ                                 #
#-----------------------------------------------------------------------------#

#----------------------------------#
function cto00m10_popup(lr_param)
#----------------------------------#

define lr_param record
  tipo  smallint
end record

define lr_array array[500] of record
  codigo    char(10) ,
  descricao char(50)
end record

define lr_retorno record
  sql       char(500)
end record

define l_index smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].* to  null
end  for

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql = "select itaciacod, itaciades from datkitacia where itaciacod <> 9999 order by 1"
         when 2
            let lr_retorno.sql = "select itaempasicod, itaempasides from datkitaempasi where itaempasicod <> 9999 order by 1"
         when 3
            let lr_retorno.sql = "select itaprdcod, itaprddes from datkitaprd where itaprdcod <> 9999 order by 1"
         when 4
            let lr_retorno.sql = "select itarsrcaosrvcod, itarsrcaosrvdes from datkitarsrcaosrv where itarsrcaosrvcod <> 9999 order by 1"
         when 5
            let lr_retorno.sql = "select itasgrplncod, itasgrplndes from datkitasgrpln where itasgrplncod <> 9999 order by 1"
         when 6
            let lr_retorno.sql = "select itaasisrvcod, itaasisrvdes from datkitaasisrv where itaasisrvcod <> 9999 order by 1"
         when 7
            let lr_retorno.sql = "select itaclisgmcod, itaclisgmdes from datkitaclisgm where itaclisgmcod <> 9999 order by 1"
         when 8
            let lr_retorno.sql = "select itacliscocod, itacliscodes from datkitaclisco where itacliscocod <> 9999 order by 1"
         when 9
            let lr_retorno.sql = "select itavclcrgtipcod, itavclcrgtipdes from datkitavclcrgtip where itavclcrgtipcod <> 9999 order by 1"
         when 10
            let lr_retorno.sql = "select itaramcod, itaramdes from datkitaram where itaramcod <> 9999 order by 1"
         when 11
            let lr_retorno.sql = "select rsrcaogrtcod, '[' || itarsrcaogrtcod || '] ' || itarsrcaogrtdes from datkitarsrcaogar where rsrcaogrtcod <> 9999 order by 1"
         when 12
            let lr_retorno.sql = "select itaaplcanmtvcod, itaaplcanmtvdes from datkitaaplcanmtv where itaaplcanmtvcod <> 9999 order by 1"
         when 13
            let lr_retorno.sql = "select itaasiplncod, itaasiplndes from datkitaasipln where itaasiplncod <> 9999 order by 1"
         when 14
            let lr_retorno.sql = "select itacbtcod, itacbtdes from datkitacbt where itacbtcod <> 9999 order by 1"
         when 15
            let lr_retorno.sql = "select ubbcod, vcltipdes from datkubbvcltip where ubbcod <> 9999 order by 1"
         when 16
            let lr_retorno.sql = "select socntzcod, socntzdes from datksocntz order by socntzdes"
         when 17
            let lr_retorno.sql = "select c24astcod, c24astdes from datkassunto where c24astagp in ",
                                    "(select c24astagp from datkastagp where ciaempcod = 84) ",
                                 "order by 1 "
         when 18
            let lr_retorno.sql = "SELECT frtmdlcod, frtmdldes FROM datkitafrtmdl ORDER BY 1 "
         when 19
            let lr_retorno.sql = "SELECT vndcnlcod, vndcnldes FROM datkitavndcnl ORDER BY 1 "
         when 20
            let lr_retorno.sql = "SELECT vcltipcod, vcltipdes FROM datkitavcltip ORDER BY 1 "
         when 21
            let lr_retorno.sql = "SELECT itaasitipflg,srvdes from datkresitasrv order by 1"
         when 22
            let lr_retorno.sql = "SELECT grpcod,desnom from datkresitagrp order by 1"
         when 23
            let lr_retorno.sql = "SELECT plncod,plndes from datkresitapln order by 1"
         when 24
            let lr_retorno.sql = "SELECT prdcod,prddes from datkresitaprd order by 1"
         when 25   
            let lr_retorno.sql = "SELECT c24pbmgrpcod, c24pbmgrpdes from datkpbmgrp where c24pbmgrpstt = 'A' order by 2" 
         when 26
            let lr_retorno.sql = "SELECT asitipcod, asitipdes from datkasitip where asitipstt = 'A' order by 2 "    
         when 27 
            let lr_retorno.sql = "SELECT asimtvcod, asimtvdes from datkasimtv where asimtvsit = 'A' order by 2 " 
         when 28
            let lr_retorno.sql = "SELECT sgmasttipflg, sgmdes from datkresitaclisgm order by 1 " 
               
            
                          
     end case

     let l_index = 1

     prepare pcto00m10001 from lr_retorno.sql
     declare ccto00m10001 cursor for pcto00m10001

     open ccto00m10001
     foreach ccto00m10001 into lr_array[l_index].codigo   ,
                               lr_array[l_index].descricao

           let l_index = l_index + 1

           if l_index > 500 then
              message "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window cto00m10 at 10,27 with form "cto00m10"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_cto00m10.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display

     close window cto00m10

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao

end function

#----------------------------------------------#
function cto00m10_recupera_descricao(lr_param)
#----------------------------------------------#

define lr_param record
  tipo   smallint,
  codigo char(10)
end record

define lr_retorno record
  sql       char(500),
  descricao char(50)
end record

initialize lr_retorno.* to null


     case lr_param.tipo
         when 1
            let lr_retorno.sql = "select itaciades from datkitacia where itaciacod = ?"
         when 2
            let lr_retorno.sql = "select itaempasides from datkitaempasi where itaempasicod = ?"
         when 3
            let lr_retorno.sql = "select itaprddes from datkitaprd where itaprdcod = ?"
         when 4
            let lr_retorno.sql = "select itarsrcaosrvdes from datkitarsrcaosrv where itarsrcaosrvcod = ?"
         when 5
            let lr_retorno.sql = "select itasgrplndes from datkitasgrpln where itasgrplncod = ?"
         when 6
            let lr_retorno.sql = "select itaasisrvdes from datkitaasisrv where itaasisrvcod = ?"
         when 7
            let lr_retorno.sql = "select itaclisgmdes from datkitaclisgm where itaclisgmcod = ?"
         when 8
            let lr_retorno.sql = "select itacliscodes from datkitaclisco where itacliscocod = ? "
         when 9
            let lr_retorno.sql = "select itavclcrgtipdes from datkitavclcrgtip where itavclcrgtipcod = ?"
         when 10
            let lr_retorno.sql = "select itaramdes from datkitaram where itaramcod = ?"
         when 11
            let lr_retorno.sql = "select itarsrcaogrtdes from datkitarsrcaogar where rsrcaogrtcod = ?"
         when 12
            let lr_retorno.sql = "select itaaplcanmtvdes from datkitaaplcanmtv where itaaplcanmtvcod = ?"
         when 13
            let lr_retorno.sql = "select itaasiplndes from datkitaasipln where itaasiplncod = ?"
         when 14
            let lr_retorno.sql = "select itacbtdes from datkitacbt where itacbtcod = ?"
         when 15
            let lr_retorno.sql = "select vcltipdes from datkubbvcltip where ubbcod = ? "

         when 17
            let lr_retorno.sql = "select c24astdes from datkassunto where c24astagp in ",
                                 "(select c24astagp from datkastagp where ciaempcod = 84) ",
                                 "and c24astcod = ? "
         when 18
            let lr_retorno.sql = "SELECT frtmdldes FROM datkitafrtmdl WHERE frtmdlcod = ? "
         when 19
            let lr_retorno.sql = "SELECT vndcnldes FROM datkitavndcnl WHERE vndcnlcod = ? "
         when 20
            let lr_retorno.sql = "SELECT vcltipdes FROM datkitavcltip WHERE vcltipcod = ? "
         when 25
            let lr_retorno.sql = "SELECT c24pbmgrpdes from datkpbmgrp where c24pbmgrpstt = 'A' and c24pbmgrpcod = ? " 
         when 26
            let lr_retorno.sql = "SELECT asitipdes from datkasitip where asitipstt = 'A' and asitipcod = ? "
         when 27
            let lr_retorno.sql = "SELECT asimtvdes from datkasimtv where asimtvsit = 'A' and asimtvcod = ? "  
                

     end case


     prepare pcto00m10002 from lr_retorno.sql
     declare ccto00m10002 cursor for pcto00m10002

     open ccto00m10002 using lr_param.codigo
     whenever error continue
     fetch ccto00m10002 into lr_retorno.descricao
     whenever error stop
     if sqlca.sqlcode = notfound  then
        error "Codigo Inexistente"
     else
       if sqlca.sqlcode <> 0  then
          error "Erro ao Recuperar a Descricao ", sqlca.sqlcode
       end if
     end if
     close ccto00m10002


    return lr_retorno.descricao

end function

#----------------------------------#
function cto00m10_popup_1(lr_param)
#----------------------------------#

define lr_param record
  tipo1  smallint ,
  tipo2  char(10)
end record

define lr_array array[500] of record
  codigo    char(10) ,
  descricao char(50)
end record

define lr_retorno record
  sql       char(500)
end record

define l_index smallint

for  l_index  =  1  to  500
   initialize  lr_array[l_index].* to  null
end  for

initialize lr_retorno.* to null


     case lr_param.tipo1
         when 1
            let lr_retorno.sql = "SELECT plncod,plndes from datkresitapln where prdcod = ? order by 1"
     end case

     let l_index = 1

     prepare pcto00m10003 from lr_retorno.sql
     declare ccto00m10003 cursor for pcto00m10003

     open ccto00m10003 using lr_param.tipo2 
     foreach ccto00m10003 into lr_array[l_index].codigo   ,
                               lr_array[l_index].descricao

           let l_index = l_index + 1

           if l_index > 500 then
              message "Limite excedido. Foram Encontrados mais de 500 Registros!"
              exit foreach
           end if

     end foreach

     open window cto00m10 at 10,27 with form "cto00m10"
        attribute (border,form line 1)

     message " (F17)Abandona, (F8)Seleciona"
     call set_count(l_index-1)

     display array lr_array to s_cto00m10.*

        on key (interrupt,control-c)
           initialize lr_array to null
           let l_index = 1
           exit display

        on key (f8)
           let l_index = arr_curr()
           exit display
     end display

     close window cto00m10

     let int_flag = false

     return lr_array[l_index].codigo,
            lr_array[l_index].descricao

end function

