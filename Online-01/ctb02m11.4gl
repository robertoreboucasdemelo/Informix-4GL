#--------------------------------------------------------------------------#
# Nome de Modulo: CTB02M11                                        Wagner   #
#                                                                          #
# Exibe totais (qtde/valor) por Motivo (carro-extra)              Out/2000 #
#--------------------------------------------------------------------------#
# Alteracoes:                                                              #
#                                                                          #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                          #
#--------------------------------------------------------------------------#
# 16/03/2004  Teresinha S. OSF 33367 Acrescentar ocoorrencia no array      #
# -------------------------------------------------------------------------#
database porto

#--------------------------------------------------------------------
 function ctb02m11(param)
#--------------------------------------------------------------------

  define param        record
     socopgnum        like dbsmopgitm.socopgnum
  end record

  define ws           record
     socopgitmvlr     like dbsmopgitm.socopgitmvlr,
     avialgmtv        like datmavisrent.avialgmtv ,
     aviprvent        like datmavisrent.aviprvent ,
     socopgdscvlr     like dbsmopg.socopgdscvlr,
     socpgtdsctip     like dbsmopg.socpgtdsctip,
     socopgitmcst     like dbsmopgcst.socopgitmcst,
     c24utidiaqtd     like dbsmopgitm.c24utidiaqtd,
     c24pagdiaqtd     like dbsmopgitm.c24utidiaqtd,
     atdsrvnum        like dbsmopgitm.atdsrvnum,
     atdsrvano        like dbsmopgitm.atdsrvano,
     aviprodiaqtd     like datmprorrog.aviprodiaqtd,
     aviprodiaqtd_tot like datmprorrog.aviprodiaqtd,
     c24utidiaqtd_pro like dbsmopgitm.c24utidiaqtd,
     valor	      decimal(15,2),
     desconto         decimal(15,2),
     ciaempcod        like datmservico.ciaempcod
  end record

  define d_ctb02m11   record
     totvlr           dec (15,5),
#     acerto           char(30),
     dscvlr           dec (15,5),
     liqvlr           dec (15,5),
     basvlr           like dbsmopgtrb.soctrbbasvlr,
     irfvlr           like dbsmopgtrb.socirfvlr,
     issvlr           like dbsmopgtrb.socissvlr,
     inssvlr          like dbsmopgtrb.insretvlr
  end record

  define a_ctb02m11   array[100] of record
     avialgmtv        like datmavisrent.avialgmtv,
     avimtvdes        char (30),
     acmqtd           dec(6,0),
     acmtot           dec(15,5),
     acmcst           dec(15,5),
     acmvlr           dec(15,5)
  end record

  define arr_aux      integer
  define arr_auxmax   integer
  define scr_aux      smallint
  define sql_comando  char(300)

  define l_desconto decimal(15,2)


  open window w_ctb02m11 at 08,02 with form "ctb02m11"
       attribute(form line first)

  initialize a_ctb02m11   to null
  initialize d_ctb02m11.* to null
  initialize ws.*         to null
  let l_desconto = 0.00

  message " Aguarde, pesquisando... "  attribute(reverse)

-------------------------------------------------
  select ciaempcod into ws.ciaempcod
    from datmservico srv, dbsmopgitm itm
   where itm.atdsrvnum = srv.atdsrvnum
     and itm.atdsrvano = srv.atdsrvano
     and itm.socopgnum = param.socopgnum
     and itm.socopgitmnum = ( select min(itmnin.socopgitmnum)
                                from dbsmopgitm itmnin
                               where itmnin.socopgnum = param.socopgnum)

  
  call ctb02m11_comando(ws.ciaempcod)
    returning sql_comando
  
  prepare sctb02m11000 from sql_comando
  declare cctb02m11000 cursor for sctb02m11000

  let arr_aux = 1
  foreach cctb02m11000 into a_ctb02m11[arr_aux].avimtvdes,
                            a_ctb02m11[arr_aux].avialgmtv
  
    let a_ctb02m11[arr_aux].acmqtd = 00
    let a_ctb02m11[arr_aux].acmtot = 00.00
    let a_ctb02m11[arr_aux].acmcst = 00.00
    let a_ctb02m11[arr_aux].acmvlr = 00.00
    
    let arr_aux = arr_aux + 1
    
    if arr_aux = 100 then
       exit foreach
    end if
  end foreach
  
  # Linha de totais
  let a_ctb02m11[arr_aux].avimtvdes = "TOTAL ................."
  let a_ctb02m11[arr_aux].avialgmtv = 999
  let a_ctb02m11[arr_aux].acmqtd = 00
  let a_ctb02m11[arr_aux].acmtot = 00.00
  let a_ctb02m11[arr_aux].acmcst = 00.00
  let a_ctb02m11[arr_aux].acmvlr = 00.00
  
  let arr_auxmax = arr_aux

-------------------------------------------------

  select sum(dbsmopgitm.socopgitmvlr), sum(dbsmopgcst.socopgitmcst)
    into d_ctb02m11.liqvlr, d_ctb02m11.dscvlr
    from dbsmopgitm, outer dbsmopgcst
   where dbsmopgitm.socopgnum    = param.socopgnum
     and dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum
     and dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

#PSI197858 - inicio
#  declare cctb02m11001 cursor for
#  select dscvlr
#  from dbsropgdsc
#  where socopgnum = param.socopgnum
#  and dsctipcod = 4

#  open cctb02m11001 using param.socopgnum

#  fetch cctb02m11001 into ws.valor
#  let d_ctb02m11.acerto  = "Ac.Contabil..:",
#                            ws.valor using "#####,###,##&.&&"

#  close cctb02m11001

  declare cctb02m11002 cursor for
  select sum(dsc.dscvlr), opg.socfattotvlr
  from dbsropgdsc dsc, dbsmopg opg
  where dsc.socopgnum = opg.socopgnum
  and dsc.socopgnum = param.socopgnum
  group by opg.socfattotvlr

whenever error continue
  open cctb02m11002 using param.socopgnum
  fetch cctb02m11002 into ws.desconto, ws.valor

whenever error stop
  if ws.desconto is null or ws.desconto = 0.00 then
  	select socopgdscvlr
  	into l_desconto
  	from dbsmopg
  	where socopgnum = param.socopgnum

  	if l_desconto is not null or l_desconto > 0.00 then
  		let d_ctb02m11.dscvlr = l_desconto
  	else
  		let d_ctb02m11.dscvlr = 0.00
  	end if
  else
  	let d_ctb02m11.dscvlr = ws.desconto
  end if

  close cctb02m11002
#PSI197858 - fim

#  let d_ctb02m11.totvlr =  d_ctb02m11.liqvlr + (d_ctb02m11.dscvlr * (-1))


   let d_ctb02m11.liqvlr =  ws.valor - ws.desconto

   let d_ctb02m11.totvlr = ws.valor

  #------------------------------------------------------
  # MONTA ITENS DA ORDEM DE PAGAMENTO
  #------------------------------------------------------
  declare c_ctb02m11  cursor for
    select dbsmopgitm.socopgitmvlr,
           dbsmopgitm.c24utidiaqtd,
           dbsmopgitm.c24pagdiaqtd,
           dbsmopgitm.atdsrvnum,
           dbsmopgitm.atdsrvano,
           datmavisrent.avialgmtv,
           datmavisrent.aviprvent,
           dbsmopgcst.socopgitmcst
      from dbsmopgitm, datmavisrent, outer dbsmopgcst
     where dbsmopgitm.socopgnum    = param.socopgnum
       and datmavisrent.atdsrvnum  = dbsmopgitm.atdsrvnum
       and datmavisrent.atdsrvano  = dbsmopgitm.atdsrvano
       and dbsmopgcst.socopgnum    = dbsmopgitm.socopgnum
       and dbsmopgcst.socopgitmnum = dbsmopgitm.socopgitmnum

  foreach c_ctb02m11 into ws.socopgitmvlr,
                          ws.c24utidiaqtd,
                          ws.c24pagdiaqtd,
                          ws.atdsrvnum,
                          ws.atdsrvano,
                          ws.avialgmtv,
                          ws.aviprvent,
                          ws.socopgitmcst

     let arr_aux = ws.avialgmtv

     if ws.socopgitmcst is null then
        let  ws.socopgitmcst = 0
     end if

     if ws.avialgmtv <> 4 then               # reserva sinistro
        #----------------------------
        # Verifica se tem prorrogacao
        #----------------------------
        select sum(aviprodiaqtd)
          into ws.aviprodiaqtd_tot
          from datmprorrog
          where atdsrvnum = ws.atdsrvnum
            and atdsrvano = ws.atdsrvano
            and cctcod    is not null
            and aviprostt = "A"

        if ws.aviprodiaqtd_tot is null then
           let ws.aviprodiaqtd_tot = 0
        end if

        if ws.aviprodiaqtd_tot = 0 then
           let a_ctb02m11[arr_aux].avialgmtv = ws.avialgmtv
           let a_ctb02m11[arr_aux].acmqtd    = a_ctb02m11[arr_aux].acmqtd + 1
           let a_ctb02m11[arr_aux].acmcst    = a_ctb02m11[arr_aux].acmcst +
                                               ws.socopgitmcst
           let a_ctb02m11[arr_aux].acmvlr    = a_ctb02m11[arr_aux].acmvlr +
                                               ws.socopgitmvlr
           let a_ctb02m11[arr_aux].acmtot    = a_ctb02m11[arr_aux].acmvlr +
                                              (a_ctb02m11[arr_aux].acmcst *(-1))
        else
           #----------------------------------
           # Tem reserva com prorrogacao
           #----------------------------------
           let a_ctb02m11[arr_aux].avialgmtv = ws.avialgmtv
           let a_ctb02m11[arr_aux].acmqtd    = a_ctb02m11[arr_aux].acmqtd + 1
           let a_ctb02m11[arr_aux].acmcst    = a_ctb02m11[arr_aux].acmcst +
                                                (ws.socopgitmcst  /
                                                 ws.c24pagdiaqtd  *
                                                 ws.aviprvent)
           let a_ctb02m11[arr_aux].acmvlr    = a_ctb02m11[arr_aux].acmvlr +
                                                (ws.socopgitmvlr  /
                                                 ws.c24pagdiaqtd  *
                                                 ws.aviprvent)
           let a_ctb02m11[arr_aux].acmtot    = a_ctb02m11[arr_aux].acmvlr +
                                              (a_ctb02m11[arr_aux].acmcst *(-1))

           let ws.avialgmtv        = 4  #  Acumula prorrogacoes no total Depto
           let arr_aux             = ws.avialgmtv
           let ws.c24utidiaqtd_pro = ws.c24pagdiaqtd - ws.aviprvent
           let a_ctb02m11[arr_aux].avialgmtv = ws.avialgmtv
           let a_ctb02m11[arr_aux].acmcst    = a_ctb02m11[arr_aux].acmcst +
                                                (ws.socopgitmcst  /
                                                 ws.c24pagdiaqtd  *
                                                 ws.c24utidiaqtd_pro)
           let a_ctb02m11[arr_aux].acmvlr    = a_ctb02m11[arr_aux].acmvlr +
                                                (ws.socopgitmvlr  /
                                                 ws.c24pagdiaqtd  *
                                                 ws.c24utidiaqtd_pro)
           let a_ctb02m11[arr_aux].acmtot    = a_ctb02m11[arr_aux].acmvlr +
                                              (a_ctb02m11[arr_aux].acmcst *(-1))
        end if
     else
        let a_ctb02m11[arr_aux].avialgmtv = ws.avialgmtv
        let a_ctb02m11[arr_aux].acmqtd    = a_ctb02m11[arr_aux].acmqtd + 1
        let a_ctb02m11[arr_aux].acmcst    = a_ctb02m11[arr_aux].acmcst +
                                            ws.socopgitmcst
        let a_ctb02m11[arr_aux].acmvlr    = a_ctb02m11[arr_aux].acmvlr +
                                            ws.socopgitmvlr
        let a_ctb02m11[arr_aux].acmtot    = a_ctb02m11[arr_aux].acmvlr +
                                           (a_ctb02m11[arr_aux].acmcst * (-1))

     end if



     #------------------------------------------------------
     # TOTAIS DA O.P.
     #------------------------------------------------------
     let a_ctb02m11[arr_auxmax].acmqtd = a_ctb02m11[arr_auxmax].acmqtd + 1
     let a_ctb02m11[arr_auxmax].acmcst = a_ctb02m11[arr_auxmax].acmcst + ws.socopgitmcst
     let a_ctb02m11[arr_auxmax].acmvlr = a_ctb02m11[arr_auxmax].acmvlr + ws.socopgitmvlr
     let a_ctb02m11[arr_auxmax].acmtot = a_ctb02m11[arr_auxmax].acmvlr +
                                (a_ctb02m11[arr_auxmax].acmcst * (-1))

  end foreach


  let d_ctb02m11.irfvlr = 0.00
  let d_ctb02m11.issvlr = 0.00
  let d_ctb02m11.inssvlr = 0.00

  display by name d_ctb02m11.*

  display "NAO TRIBUTADO!" at 02,59
  display "NAO TRIBUTADO!" at 03,59
  display "NAO TRIBUTADO!" at 04,59
  display "NAO TRIBUTADO!" at 05,59

  call set_count(arr_auxmax)
  message " (F17)Abandona, (F7)Reservas/C.Custo, (F8)Seleciona, (F9)Descontos "

  display array a_ctb02m11 to s_ctb02m11.*
     on key (interrupt,control-c)
        exit display

     on key (F7)
        call ctb02m17(param.socopgnum)

     on key (F8)
        let arr_aux = arr_curr()
        if a_ctb02m11[arr_aux].acmqtd  is not null   and
           a_ctb02m11[arr_aux].acmqtd  >  00         and
           arr_aux                     <  arr_auxmax then
           call ctb02m10(param.socopgnum, a_ctb02m11[arr_aux].avialgmtv,
                         "","","")
        end if

    on key (F9)
    	call ctc81m00(param.socopgnum)

  end display

  let int_flag = false
  close c_ctb02m11
  close window w_ctb02m11

end function  ###  ctb02m11

#----------------------------------
function ctb02m11_comando(param)
#---------------------------------

  define param record
     ciaempcod   like datmservico.ciaempcod
  end record

 define lr_retorno record
    comando   char(300),
    avialgmtv like datmavisrent.avialgmtv   
 end record
 
 
 case param.ciaempcod
    when 84
       let lr_retorno.comando   = "select itarsrcaomtvdes,",
                                  "       itarsrcaomtvcod ",                                  
                                  "  from datkitarsrcaomtv"   
    otherwise 
       whenever error continue 
          select cpodes
            into lr_retorno.avialgmtv      																																															
          from iddkdominio 
           where cpocod = param.ciaempcod  
             and cponom = 'avialgmtv_empresa'
          
          if sqlca.sqlcode <> 0 then
             let lr_retorno.avialgmtv = 'avialgmtv'       
          end if 
       whenever error stop  
        	
        let lr_retorno.comando = " select cpodes, cpocod ",
                                  "  from datkdominio "   ,           
                                "  where cponom = '",lr_retorno.avialgmtv,"'"
        
  end case
 
 
  
return lr_retorno.comando
 
end function
