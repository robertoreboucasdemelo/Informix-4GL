############################################################################
# Nome do Modulo: CTC36M04                                        Gilberto #
#                                                                 Marcelo  #
#                                                                 Wagner   #
# Batimento dos itens de vistoria                                 Dez/1998 #
############################################################################
#..........................................................................#
#                  * * *  ALTERACOES  * * *                                #
#                                                                          #
# Data       Autor Fabrica PSI       Alteracao                             #
# --------   ------------- --------  --------------------------------------#
# 18/07/06   Adriano, Meta Migracao  Migracao de versao do 4gl.            #
#--------------------------------------------------------------------------#

database porto

#--------------------------------------------------------------------
function ctc36m04(param)
#--------------------------------------------------------------------
  define param       record
     socvstnum       like datmvstmvt.socvstnum,
     atlemp          like datmsocvst.atlemp,
     atlmat          like datmsocvst.atlmat
  end record

  define d_ctc36m04  record
     msgcab          char(39),
     totqtdver       dec(5,0),
     totqtddig       dec(5,0),
     totqtddif       dec(5,0)
  end record

  define ws          record
     socvstlautipcod like datmsocvst.socvstlautipcod,
     socvstlaunum    like datmvstlau.socvstlaunum,
     totqtdver       dec(5,0),
     conta           dec(5,0),
     carac1          char(01)
  end record


  initialize d_ctc36m04.*  to null
  initialize ws.*          to null


  # CARREGA DADOS DA VISTORIA
  #--------------------------
  select socvstlautipcod into ws.socvstlautipcod
    from datmsocvst
   where socvstnum = param.socvstnum

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura da vistoria! "
     return
  end if

  select socvstlaunum into ws.socvstlaunum
    from datmvstlau
   where datmvstlau.socvstlautipcod = ws.socvstlautipcod
     and (datmvstlau.viginc <= today and
          datmvstlau.vigfnl >= today)

  if sqlca.sqlcode <> 0    then
     error " Erro (",sqlca.sqlcode,") na leitura do tipo de laudo! "
     return
  end if

  # SOMA ITENS DE VERIFICACAO DO LAUDO
  #-----------------------------------
  declare c_ctc36m04ver  cursor for
   select socvstitmcod, count(*)
     from datrvstitmver
    where datrvstitmver.socvstlaunum = ws.socvstlaunum
    group by socvstitmcod

  let d_ctc36m04.totqtdver  = 0

  foreach c_ctc36m04ver into ws.totqtdver, ws.conta
     let d_ctc36m04.totqtdver = d_ctc36m04.totqtdver + 1
  end foreach

  # SOMA ITENS DIGITADOS NA VISTORIA
  #---------------------------------
  let d_ctc36m04.totqtddig  = 0

  select count(*) into d_ctc36m04.totqtddig
    from datmvstmvt
   where datmvstmvt.socvstnum = param.socvstnum

  # NAO EXISTEM ITENS DIGITADOS
  #----------------------------
  if d_ctc36m04.totqtddig  =  0    then
     error " Batimento nao pode ser realizado! vistoria sem itens digitados!"
     return
  end if

  # MOSTRA TELA E VERIFICA SE EXISTE DIVERGENCIA
  #---------------------------------------------
  open window w_ctc36m04 at 09,02 with form "ctc36m04"
       attribute(form line first)

  let d_ctc36m04.totqtddif  = d_ctc36m04.totqtdver - d_ctc36m04.totqtddig

  display by name d_ctc36m04.totqtdver
  display by name d_ctc36m04.totqtddig
  display by name d_ctc36m04.totqtddif

  let d_ctc36m04.msgcab =    "** VISTORIA COM QUANTIDADES OK !!! ** "

  if d_ctc36m04.totqtddif <> 0 then
     let d_ctc36m04.msgcab = " * ATENCAO, VISTORIA COM DIVERGENCIA *"
    else
     begin work
       update datmsocvst set socvstsit = 4,
                             atldat    = today,
                             atlemp    = param.atlemp,
                             atlmat    = param.atlmat
       where datmsocvst.socvstnum = param.socvstnum

      if sqlca.sqlcode <>  0  then
         error " Erro (",sqlca.sqlcode,") na alteracao da vistoria!"
         rollback work
         sleep 4
         return
      end if

     commit work
  end if

  display by name d_ctc36m04.msgcab   attribute(reverse)

  prompt " (F17)Abandona     "  for  char  ws.carac1

  close window w_ctc36m04
  let int_flag = false

end function    #--- ctc36m04
