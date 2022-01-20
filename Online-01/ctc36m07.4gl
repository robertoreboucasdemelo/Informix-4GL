###########################################################################
# Nome do Modulo: CTC36M07                                        Marcelo #
#                                                                Gilberto #
#                                                                  Wagner #
# Consulta laudos de vistorias de veiculos                       Dez/1998 #
###########################################################################

database porto

#------------------------------------------------------------
function ctc36m07(k_ctc36m07)
#------------------------------------------------------------

   define k_ctc36m07   record
          socvstnum    like datmsocvst.socvstnum
   end record

   define ctc36m07     record
          socvstnum    like datmsocvst.socvstnum,
          socvstsit    like datmsocvst.socvstsit,
          sitdesc      char(20),
          socvsttip    like datmsocvst.socvsttip,
          tipdesc      char(11),
          atdvclsgl    like datkveiculo.atdvclsgl,
          socvclcod    like datmsocvst.socvclcod,
          vcldesc      char(58),
          vcllicnum    like datkveiculo.vcllicnum,
          socoprsitcod like datkveiculo.socoprsitcod,
          sitvcldesc   char(10),
          pstcoddig    like datkveiculo.pstcoddig,
          nomgrr       like dpaksocor.nomgrr,
          socvstdat    like datmsocvst.socvstdat,
          socvstlclcod like datmsocvst.socvstlclcod,
          socvstlclnom like datkvstlcl.socvstlclnom,
          socvstmotnom like datmsocvst.socvstmotnom,
          socvstfotqtd like datmsocvst.socvstfotqtd,
          atldat       like datmsocvst.atldat,
          funnom       like isskfunc.funnom
   end record

   define ws           record
          vclcoddig    like datkveiculo.vclcoddig,
          socvstlclsit like datkvstlcl.socvstlclsit,
          prssitcod    like dpaksocor.prssitcod,
          atlemp       like isskfunc.empcod,
          atlmat       like isskfunc.funmat,
          cademp       like isskfunc.empcod,
          cadmat       like isskfunc.funmat,
          resp         char(1)
   end record

   initialize ctc36m07.*   to null
   initialize ws.*         to null

   open window ctc36m07 at 04,02 with form "ctc36m07"

   select socvstnum,
          socvclcod,
          socvsttip,
          socvstsit,
          socvstdat,
          socvstlclcod,
          socvstmotnom,
          socvstfotqtd,
          atldat,
          atlemp,
          atlmat
     into ctc36m07.socvstnum,
          ctc36m07.socvclcod,
          ctc36m07.socvsttip,
          ctc36m07.socvstsit,
          ctc36m07.socvstdat,
          ctc36m07.socvstlclcod,
          ctc36m07.socvstmotnom,
          ctc36m07.socvstfotqtd,
          ctc36m07.atldat,
          ws.atlemp,
          ws.atlmat
     from datmsocvst
    where socvstnum = k_ctc36m07.socvstnum

   if sqlca.sqlcode = notfound   then
      error " Vistoria nao cadastrada!"
      initialize ctc36m07.*    to null
      initialize k_ctc36m07.*  to null
      return ctc36m07.*
     else
      select funnom
        into ctc36m07.funnom
        from isskfunc
       where isskfunc.empcod = ws.atlemp
         and isskfunc.funmat = ws.atlmat
   end if

   select cpodes
     into ctc36m07.sitdesc
     from iddkdominio
    where cponom = "socvstsit"
      and cpocod =  ctc36m07.socvstsit

   if sqlca.sqlcode <> 0 then
      let ctc36m07.sitdesc = "INVALIDO !!"
   end if

   select cpodes
     into ctc36m07.tipdesc
     from iddkdominio
    where cponom = "socvsttip"
      and cpocod =  ctc36m07.socvsttip

   if sqlca.sqlcode <> 0 then
      let ctc36m07.tipdesc = "INVALIDO !!"
   end if

   select atdvclsgl, pstcoddig, vclcoddig, vcllicnum, socoprsitcod
     into ctc36m07.atdvclsgl   , ctc36m07.pstcoddig,
          ws.vclcoddig         , ctc36m07.vcllicnum,
          ctc36m07.socoprsitcod
     from datkveiculo
    where datkveiculo.socvclcod = ctc36m07.socvclcod

   call cts15g00(ws.vclcoddig) returning ctc36m07.vcldesc

   select nomgrr, prssitcod
     into ctc36m07.nomgrr , ws.prssitcod
     from dpaksocor
    where dpaksocor.pstcoddig = ctc36m07.pstcoddig

   if sqlca.sqlcode <> 0    then
      let ctc36m07.nomgrr = "Prestador nao cadastrado!"
     else
      if ws.prssitcod <> "A"  then
         let ctc36m07.nomgrr = "Prestador INATIVO!"
      end if
   end if

   select socvstlclnom, socvstlclsit
     into ctc36m07.socvstlclnom, ws.socvstlclsit
     from datkvstlcl
    where socvstlclcod = ctc36m07.socvstlclcod

   case ctc36m07.socoprsitcod
        when 1  let ctc36m07.sitvcldesc = "ATIVO     "
        when 2  let ctc36m07.sitvcldesc = "BLOQUEADO "
        when 3  let ctc36m07.sitvcldesc = "INATIVO   "
   end case

   if sqlca.sqlcode = notfound   then
      let ctc36m07.socvstlclnom = " Codigo local vistoria nao cadastrado!"
     else
      if ws.socvstlclsit <> "A" then
         let ctc36m07.socvstlclnom = " Codigo local vistoria nao esta' ativo!"
      end if
   end if

   display by name  ctc36m07.socvstnum thru ctc36m07.funnom

   prompt " Enter para retornar " for ws.resp

   close window ctc36m07
   return

end function

