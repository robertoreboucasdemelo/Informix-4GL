#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m61.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Recupera Clientes por Placa                                #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 07/01/2008                                                #
#............................................................................#
#                     * * *  ALTERACOES * * *                                #
#                                                                            #
# 29/12/2009 Patricia W.                      Projeto SUCCOD - Smallint      #
#............................................................................#


globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"

define  m_prepare  smallint

define mr_array array[150] of record
       cgccpf    like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pesnom    like gsakpes.pesnom    ,
       pestip    like gsakpes.pestip    ,
       viginc    date                   ,
       vigfnl    date
end record

define a_cta01m61 array[150] of record
       seta    char(1)             ,
       cgccpf  char(20)            ,
       segnom  like gsakseg.segnom
end record

#-----------------------------------------------------------------------------
function cta01m61_prepare()
#-----------------------------------------------------------------------------
define l_sql    char(500)

let l_sql = null

 let l_sql = "select grlinf[01,10] " ,
             "from datkgeral "       ,
             "where grlchv=? "
 prepare pcta01m61001 from l_sql
 declare ccta01m61001 cursor for pcta01m61001

 let l_sql = "select succod, "        ,
             "aplnumdig, "            ,
             "itmnumdig, "            ,
             "max(dctnumseq) "        ,
             "from  abbmveic "        ,
             "where vcllicnum = ? "   ,
             "group by 1,2,3"
 prepare pcta01m61002 from l_sql
 declare ccta01m61002 cursor for pcta01m61002

 let l_sql = "select etpnumdig, "     ,
             "aplstt , "              ,
             "viginc , "              ,
             "vigfnl   "              ,
             "from  abamapol "        ,
             "where succod = ? "      ,
             "and aplnumdig = ? "
 prepare pcta01m61003 from l_sql
 declare ccta01m61003 cursor for pcta01m61003

 let l_sql = "select emsdat "          ,
             "from abamdoc "           ,
             "where succod  = ? "      ,
             "and aplnumdig = ? "      ,
             "and edsnumdig = ? "
 prepare pcta01m61004 from l_sql
 declare ccta01m61004 cursor for pcta01m61004

 let l_sql = "select segnom "         ,
             "from gsakseg "          ,
             "where segnumdig = ? "
 prepare pcta01m61005 from l_sql
 declare ccta01m61005 cursor for pcta01m61005

 let l_sql = " select a.azlaplcod ",
               " from datkazlapl a" ,
              " where a.vcllicnum = ? ",
               "  and a.edsnumdig in (select max(edsnumdig) ",
                                      " from datkazlapl b ",
                                     " where a.succod    = b.succod ",
                                       " and a.aplnumdig = b.aplnumdig ",
                                       " and a.itmnumdig = b.itmnumdig ",
                                       " and a.ramcod    = b.ramcod) "
 prepare pcta01m61010 from l_sql
 declare ccta01m61010 cursor for pcta01m61010

 let l_sql = " select cgccpfnum ,",
             "        cgcord    ,",
             "        cgccpfdig ,",
             "        segnom    ,",
             "        pestip    ",
             " from datkazlapl " ,
             " where azlaplcod = ? "
 prepare pcta01m61011 from l_sql
 declare ccta01m61011 cursor for pcta01m61011

 let l_sql = " select a.cgccpfnum, ",
             "        a.cgcord   , ",
             "        a.cgccpfdig, ",
             "        a.segnom   , ",
             "        a.pestip     ",
             " from datkazlapl a   ",
             " where a.succod = ?  ",
             " and a.aplnumdig = ? ",
             " and a.itmnumdig = ? ",
             " and a.ramcod = ?    ",
             " and a.edsnumdig in (select max(edsnumdig) "             ,
                                      " from datkazlapl b "            ,
                                      " where a.succod    = b.succod " ,
                                      " and a.aplnumdig = b.aplnumdig ",
                                      " and a.itmnumdig = b.itmnumdig ",
                                      " and a.ramcod    = b.ramcod) "
 prepare pcta01m61012 from l_sql
 declare ccta01m61012 cursor for pcta01m61012


 let m_prepare = true

end function

#------------------------------------------------------------------------------
function cta01m61_cria_temp()
#------------------------------------------------------------------------------

 call cta01m61_drop_temp()

 whenever error continue
      create temp table cta01m61_temp(succod     smallint      ,
                                      ramcod     smallint      ,
                                      segnumdig  decimal(8,0)  ,
		                                aplnumdig  decimal(9,0)  ,
         	                          itmnumdig  decimal(7,0)  ,
	                                   viginc     date          ,
                                      vigfnl     date          ,
				                          segnom     char(50)      ,
				                          aplstt     char(1)       ,
				                          ciaempcod  decimal(2,0)  ,
				                          itaciacod  smallint      ) with no log
  create unique index idx_tmpcta01m6101 on cta01m61_temp(segnumdig)
  whenever error stop

     if sqlca.sqlcode <> 0  then
	     if sqlca.sqlcode = -310 or
	        sqlca.sqlcode = -958 then
	        call cta01m61_drop_temp()
	     end if

	    return false
     end if

     return true

end function

#------------------------------------------------------------------------------
function cta01m61_drop_temp()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cta01m61_temp
    whenever error stop

    return

end function

#------------------------------------------------------------------------------
function cta01m61_prep_temp()
#------------------------------------------------------------------------------
    define w_ins char(1000)

    let w_ins = 'insert into cta01m61_temp'
	     , ' values(?,?,?,?,?,?,?,?,?,?,?)'
    prepare p_insert from w_ins

end function

#------------------------------------------------------------------------------
function cta01m61_cria_temp2()
#------------------------------------------------------------------------------

 call cta01m61_drop_temp2()

 whenever error continue
      create temp table cta01m61_temp2(pesnom     char(70)      ,
                                       cgccpfnum  decimal(12,0) ,
                                       cgcord     decimal(04,0) ,
		                                 cgccpfdig  decimal(02,0) ,
         	                           pestip     char(01)      ,
	                                    viginc     date          ,
                                       vigfnl     date ) with no log
  create unique index idx_tmpcta01m6102 on cta01m61_temp2(cgccpfnum)

  whenever error stop

    if sqlca.sqlcode <> 0  then
	     if sqlca.sqlcode = -310 or
	        sqlca.sqlcode = -958 then
	            call cta01m61_drop_temp2()
	     end if

	    return false

    end if

    return true

end function

#------------------------------------------------------------------------------
function cta01m61_drop_temp2()
#------------------------------------------------------------------------------

    whenever error continue
        drop table cta01m61_temp2
    whenever error stop

    return

end function

#------------------------------------------------------------------------------
function cta01m61_prep_temp2()
#------------------------------------------------------------------------------
    define w_ins char(1000)

    let w_ins = 'insert into cta01m61_temp2'
	     , ' values(?,?,?,?,?,?,?)'
    prepare p_insert2 from w_ins

end function

#------------------------------------------------------------------------------
function cta01m61_conta_cliente()
#------------------------------------------------------------------------------
  define l_sql char(100)

  let l_sql = " select count(*) "    ,
              " from cta01m61_temp "
  prepare pcta01m61006 from l_sql
  declare ccta01m61006 cursor for pcta01m61006

  return
end function

#------------------------------------------------------------------------------
function cta01m61_filtra_cliente()
#------------------------------------------------------------------------------

  define l_sql char(100)

  let l_sql = " select count(*) "    ,
              " from cta01m61_temp2 "
  prepare pcta01m61008 from l_sql
  declare ccta01m61008 cursor for pcta01m61008

  return

end function

#------------------------------------------------------------------------------
function cta01m61_rec_dados()
#------------------------------------------------------------------------------

  define l_sql char(100)
  let l_sql = " select * "            ,
              " from cta01m61_temp "  ,
              " order by vigfnl desc  "
  prepare pcta01m61007 from l_sql
  declare ccta01m61007 cursor for pcta01m61007

  return

end function

#------------------------------------------------------------------------------
function cta01m61_filtra_dados()
#------------------------------------------------------------------------------
  define l_sql char(100)

  let l_sql = " select * "            ,
              " from cta01m61_temp2 "  ,
              " order by vigfnl desc  "
  prepare pcta01m61009 from l_sql
  declare ccta01m61009 cursor for pcta01m61009

  return

end function

#------------------------------------------------------------------------------
function cta01m61_rec_cliente_placa(lr_param)
#------------------------------------------------------------------------------

define lr_param record
    vcllicnum   like abbmveic.vcllicnum
end record

define lr_cta01m61  record
 succod    like abbmveic.succod      ,
 ramcod    like gtakram.ramcod       ,
 segnumdig like abbmdoc.segnumdig    ,
 aplnumdig like abbmveic.aplnumdig   ,
 itmnumdig like abbmveic.itmnumdig   ,
 viginc    like abamapol.viginc      ,
 vigfnl    like abamapol.vigfnl      ,
 segnom    like gsakseg.segnom       ,
 aplstt    like abamapol.aplstt      ,
 ciaempcod smallint                  ,
 itaciacod like datkitacia.itaciacod
end record

define lr_cta01m61_temp record
  pesnom    like gsakpes.pesnom    ,
  cgccpfnum like gsakpes.cgccpfnum ,
  cgcord    like gsakpes.cgcord    ,
  cgccpfdig like gsakpes.cgccpfdig ,
  pestip    like gsakpes.pestip    ,
  viginc    date                   ,
  vigfnl    date
end record

define ws record
  dtresol    date                 ,
  emsdat     like abamdoc.emsdat  ,
  grlchv     char(17)             ,
  pesnum     like gsakpes.pesnum  ,
  obs        char(70)
end record

define lr_retorno record
  erro      smallint              ,
  mens      char(50)              ,
  cgccpf    like gsakpes.cgccpfnum,
  cgcord    like gsakpes.cgcord   ,
  cgccpfdig like gsakpes.cgccpfdig,
  pestip    like gsakpes.pestip   ,
  pesnom    like gsakpes.pesnom
end record

define l_index   integer
define arr_aux   integer
define l_cont    integer

initialize ws.*             ,
           lr_retorno.*     ,
           lr_cta01m61.*    ,
           lr_cta01m61_temp.* to null

for     l_index  =  1  to  150
        initialize  a_cta01m61[l_index].* to  null
        initialize  mr_array[l_index].*   to  null
end  for


let l_cont  = null
let arr_aux = 0

let ws.grlchv = "ct24resolucao86"

 if m_prepare is null or
    m_prepare <> true then
    call cta01m61_prepare()
 end if

    message " Aguarde, pesquisando..." attribute (reverse)

    while true
    let arr_aux = 0

    if not cta01m61_cria_temp2() then
        let lr_retorno.erro = 1
        let lr_retorno.mens = "Erro na Criacao da Tabela Temporaria!"
        exit while
    end if

    call cta01m61_prep_temp2()

    # Recupero a Data de Mudanca dos Ramos

        open ccta01m61001 using ws.grlchv

        whenever error continue
        fetch ccta01m61001  into ws.dtresol
        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              let lr_retorno.mens = "Data da Resolucao nao Encontrada !"
           else
              let lr_retorno.mens = "Erro SELECT ccta01m61001 (", sqlca.sqlcode, "),(", sqlca.sqlerrd[2], ")" sleep 3
           end if

           let lr_retorno.erro = 1
           exit while
        end if

        close ccta01m61001

        # Recupera Placas Porto
        call cta01m61_rec_licenca(lr_param.vcllicnum,
                                  ws.dtresol        )
        returning lr_retorno.erro,
                  lr_retorno.mens

        if lr_retorno.erro = 1 then
            exit while
        end if

        # Recupera Placas Azul
        call cta01m61_rec_licenca_azul(lr_param.vcllicnum)

        # Recupera Placas Itau
        call cta01m61_rec_licenca_itau(lr_param.vcllicnum)


        call cta01m61_conta_cliente()

        open ccta01m61006

        whenever error continue
        fetch ccta01m61006  into l_cont
        close ccta01m61006

        whenever error stop

        if l_cont > 0 then

             call cta01m61_rec_dados()

             open ccta01m61007
             foreach ccta01m61007 into lr_cta01m61.*

               if lr_cta01m61.ciaempcod = 1 then

                     call osgtf550_busca_pesnum_por_unfclisegcod(lr_cta01m61.segnumdig)
                     returning lr_retorno.erro,
                               ws.pesnum

                     if lr_retorno.erro = 0     then
                          call osgtf550_busca_cliente_por_pesnum(ws.pesnum)
                          returning lr_retorno.erro
                     end if

                     let lr_cta01m61_temp.pesnom     = gr_gsakpes.pesnom
                     let lr_cta01m61_temp.cgccpfnum  = gr_gsakpes.cgccpfnum
                     let lr_cta01m61_temp.cgcord     = gr_gsakpes.cgcord
                     let lr_cta01m61_temp.cgccpfdig  = gr_gsakpes.cgccpfdig
                     let lr_cta01m61_temp.pestip     = gr_gsakpes.pestip
                     let lr_cta01m61_temp.viginc     = lr_cta01m61.viginc
                     let lr_cta01m61_temp.vigfnl     = lr_cta01m61.vigfnl
               else
                     if lr_cta01m61.ciaempcod = 84 then # Itau

                        call cta01m61_rec_dados_itau(lr_cta01m61.itaciacod,
                                                     lr_cta01m61.ramcod   ,
                                                     lr_cta01m61.aplnumdig,
                                                     lr_cta01m61.segnumdig,
                                                     lr_cta01m61.itmnumdig )
                        returning lr_retorno.erro              ,
                                  lr_cta01m61_temp.cgccpfnum   ,
                                  lr_cta01m61_temp.cgcord      ,
                                  lr_cta01m61_temp.cgccpfdig   ,
                                  lr_cta01m61_temp.pesnom      ,
                                  lr_cta01m61_temp.pestip


                     else

                        # Azul

                        call cta01m61_rec_dados_azul(lr_cta01m61.aplnumdig)
                        returning lr_retorno.erro              ,
                                  lr_cta01m61_temp.cgccpfnum   ,
                                  lr_cta01m61_temp.cgcord      ,
                                  lr_cta01m61_temp.cgccpfdig   ,
                                  lr_cta01m61_temp.pesnom      ,
                                  lr_cta01m61_temp.pestip
                     end if

                     let lr_cta01m61_temp.viginc  = lr_cta01m61.viginc
                     let lr_cta01m61_temp.vigfnl  = lr_cta01m61.vigfnl


               end if

               if lr_retorno.erro = 0 then

                   let arr_aux = arr_aux + 1
                   whenever error continue
                   execute p_insert2 using lr_cta01m61_temp.pesnom      ,
                                           lr_cta01m61_temp.cgccpfnum   ,
                                           lr_cta01m61_temp.cgcord      ,
                                           lr_cta01m61_temp.cgccpfdig   ,
                                           lr_cta01m61_temp.pestip      ,
                                           lr_cta01m61_temp.viginc      ,
                                           lr_cta01m61_temp.vigfnl
                   whenever error stop
               end if
             end foreach

              if arr_aux = 0 then
                  let lr_retorno.erro = 2
                  let lr_retorno.mens = "Nenhuma apolice foi selecionada!"
              else
                  let lr_retorno.erro = 0
              end if

             exit while

         else
                if l_cont = 0 then
                    let lr_retorno.erro = 2
                    let lr_retorno.mens = "Nenhuma apolice foi selecionada!"
                else
                    let lr_retorno.erro = 0
                end if

               exit while
         end if
    end while

        message " "

          if lr_retorno.erro = 0 then

            let arr_aux = 0

            call cta01m61_filtra_cliente()

            open ccta01m61008

            whenever error continue
            fetch ccta01m61008  into l_cont
            close ccta01m61008

            whenever error stop

            if l_cont > 0 then

                 call cta01m61_filtra_dados()

                 open ccta01m61009

                 foreach ccta01m61009 into lr_cta01m61_temp.*

                     let arr_aux = arr_aux + 1
                     let mr_array[arr_aux].pesnom    = lr_cta01m61_temp.pesnom
                     let mr_array[arr_aux].cgccpf    = lr_cta01m61_temp.cgccpfnum
                     let mr_array[arr_aux].cgcord    = lr_cta01m61_temp.cgcord
                     let mr_array[arr_aux].cgccpfdig = lr_cta01m61_temp.cgccpfdig
                     let mr_array[arr_aux].pestip    = lr_cta01m61_temp.pestip
                     let mr_array[arr_aux].viginc    = lr_cta01m61_temp.viginc
                     let mr_array[arr_aux].vigfnl    = lr_cta01m61_temp.vigfnl
                     let a_cta01m61[arr_aux].segnom = lr_cta01m61_temp.pesnom
                     let a_cta01m61[arr_aux].cgccpf = cta01m60_formata_cgccpf(lr_cta01m61_temp.cgccpfnum,
                                                                              lr_cta01m61_temp.cgcord   ,
                                                                              lr_cta01m61_temp.cgccpfdig)
                 end foreach
             end if

             if arr_aux > 1 then

                       open window cta01m61 at 03,02 with form "cta01m61"
                                             attribute(form line 1)

                       let ws.obs = "                         (F8)Seleciona (F17)Abandona"

                       display by name ws.obs

                       call set_count(arr_aux)

                       options insert   key F40
                       options delete   key F35
                       options next     key F30
                       options previous key F25

                       input array a_cta01m61 without defaults from s_cta01m61.*

                          before field seta
                           let arr_aux  = arr_curr()
                           display by name mr_array[arr_aux].viginc
                           display by name mr_array[arr_aux].vigfnl

                          after field seta
                           if  fgl_lastkey() <> fgl_keyval("up")   and
                               fgl_lastkey() <> fgl_keyval("left") then
                                    if a_cta01m61[arr_aux + 1 ].cgccpf is null then
                                          next field seta
                                    end if
                           end if

                          on key (interrupt)
                              let lr_retorno.erro = 1
                              exit input

                          on key(f8)

                          let arr_aux  = arr_curr()
                          let lr_retorno.cgccpf    = mr_array[arr_aux].cgccpf
                          let lr_retorno.cgcord    = mr_array[arr_aux].cgcord
                          let lr_retorno.cgccpfdig = mr_array[arr_aux].cgccpfdig
                          let lr_retorno.pestip    = mr_array[arr_aux].pestip
                          let lr_retorno.pesnom    = mr_array[arr_aux].pesnom

                           exit input

                       end input

                       close window cta01m61
           else
                  let lr_retorno.cgccpf    = mr_array[1].cgccpf
                  let lr_retorno.cgcord    = mr_array[1].cgcord
                  let lr_retorno.cgccpfdig = mr_array[1].cgccpfdig
                  let lr_retorno.pestip    = mr_array[1].pestip
                  let lr_retorno.pesnom    = mr_array[1].pesnom
           end if
        end if

        return lr_retorno.*

end function

#--------------------------------------------------------------------------
	function cta01m61_rec_licenca(lr_param)
#--------------------------------------------------------------------------

define lr_param record
       vcllicnum  like abbmveic.vcllicnum ,
       dtresol    date
end record

define ws record
  emsdat     like abamdoc.emsdat    ,
  edsnumdig  like abamdoc.edsnumdig
end record

define lr_abamapol record
 etpnumdig like abamapol.etpnumdig,
 aplstt    like abamapol.aplstt   ,
 viginc    like abamapol.viginc   ,
 vigfnl    like abamapol.vigfnl
end record

define lr_abbmveic record
 succod    like abbmveic.succod,
 aplnumdig like abbmveic.aplnumdig,
 itmnumdig like abbmveic.itmnumdig,
 dctnumseq like abbmveic.dctnumseq
end record

define lr_cta01m61  record
 succod    like abbmveic.succod      ,
 ramcod    like gtakram.ramcod       ,
 segnumdig like abbmdoc.segnumdig    ,
 aplnumdig like abbmveic.aplnumdig   ,
 itmnumdig like abbmveic.itmnumdig   ,
 viginc    like abamapol.viginc      ,
 vigfnl    like abamapol.vigfnl      ,
 segnom    like gsakseg.segnom       ,
 aplstt    like abamapol.aplstt      ,
 ciaempcod integer                   ,
 itaciacod like datkitacia.itaciacod
end record

define lr_retorno record
       erro  smallint ,
       mens  char(50)
end record

define arr_aux integer

define l_data  date

define l_hora  datetime hour to minute

while true

   initialize lr_abbmveic.* to null
   initialize lr_abamapol.* to null
   initialize lr_cta01m61.* to null
   initialize lr_retorno.*  to null
   initialize ws.*         to null

   let arr_aux        = 0
   let ws.edsnumdig   = 0
   let lr_retorno.erro = 0

   if m_prepare is null or
      m_prepare <> true then
      call cta01m61_prepare()
   end if

   if not cta01m61_cria_temp() then
       let lr_retorno.erro = 1
       let lr_retorno.mens = "Erro na Criacao da Tabela Temporaria!"
       exit while
   end if

   call cta01m61_prep_temp()

   call cts40g03_data_hora_banco(2)
   returning l_data,
             l_hora

   open ccta01m61002 using lr_param.vcllicnum

   foreach ccta01m61002 into   lr_abbmveic.*

      let arr_aux = arr_aux + 1

      if arr_aux > 200 then
         let arr_aux = 200
         let lr_retorno.mens = " Limite excedido, existem mais de 200 veiculos c/ a mesma licenca!"
         let lr_retorno.erro = 1
         exit while
      end if

      call F_FUNAPOL_ULTIMA_SITUACAO (lr_abbmveic.succod,
                                      lr_abbmveic.aplnumdig,
                                      lr_abbmveic.itmnumdig)
                                      returning g_funapol.*

        if g_funapol.resultado = "O"   then

           open ccta01m61003 using lr_abbmveic.succod,
                                   lr_abbmveic.aplnumdig

           whenever error continue
           fetch ccta01m61003 into lr_abamapol.*
           close ccta01m61003
           whenever error stop

           open ccta01m61004 using lr_abbmveic.succod    ,
                                   lr_abbmveic.aplnumdig ,
                                   ws.edsnumdig

           whenever error continue
           fetch ccta01m61004 into ws.emsdat
           close ccta01m61004

           whenever error stop
           if ws.emsdat >= lr_param.dtresol then
              let lr_cta01m61.ramcod = 531
           else
              let lr_cta01m61.ramcod = 31
           end if

           open ccta01m61005 using lr_abamapol.etpnumdig

           whenever error continue
           fetch ccta01m61005 into lr_cta01m61.segnom
           close ccta01m61005

           whenever error stop

           let lr_cta01m61.succod     = lr_abbmveic.succod
           let lr_cta01m61.aplnumdig  = lr_abbmveic.aplnumdig
           let lr_cta01m61.itmnumdig  = lr_abbmveic.itmnumdig
           let lr_cta01m61.segnumdig  = lr_abamapol.etpnumdig
           let lr_cta01m61.viginc     = lr_abamapol.viginc
           let lr_cta01m61.vigfnl     = lr_abamapol.vigfnl
           let lr_cta01m61.aplstt     = lr_abamapol.aplstt
           let lr_cta01m61.ciaempcod  = 1

           whenever error continue
           execute p_insert using lr_cta01m61.*
           whenever error stop

        end if
    end foreach

    exit while

end while

  return lr_retorno.*

end function

#--------------------------------------------------------------------------
function cta01m61_rec_cliente_apolice(lr_param)
#--------------------------------------------------------------------------

define lr_param record
  succod    like gabksuc.succod          ,
  ramcod    like gtakram.ramcod          ,
  aplnumdig like abamdoc.aplnumdig       ,
  itmnumdig like abbmveic.itmnumdig      ,
  ramsgl    char(15)                     ,
  itaciacod like datmitaapl.itaciacod
end record

define lr_cta01m61 record
  erro      smallint                      ,
  mens      char(70)                      ,
  emsdat    like abamdoc.emsdat           ,
  aplstt    like abamapol.aplstt          ,
  vigfnl    like abamapol.vigfnl          ,
  segnumdig like abbmdoc.segnumdig        ,
  pesnum    like gsakpes.pesnum           ,
  sgrorg    like rsamseguro.sgrorg        ,
  sgrnumdig like rsamseguro.sgrnumdig     ,
  prporg    like rsdmdocto.prporg         ,
  prpnumdig like rsdmdocto.prpnumdig      ,
  edsnumref like rsdmdocto.edsnumdig
end record


define lr_retorno record
       erro      smallint              ,
       mens      char(70)              ,
       cgccpfnum like gsakpes.cgccpfnum,
       cgcord    like gsakpes.cgcord   ,
       cgccpfdig like gsakpes.cgccpfdig,
       pesnom    like gsakpes.pesnom   ,
       pestip    like gsakpes.pestip
end record

initialize lr_cta01m61.*,
           lr_retorno.*   to null

   # Recupero as Apolices da Porto


  if lr_param.ramcod = 31  or
     lr_param.ramcod = 531 then

      # Obter Dados da Apolice de Auto
      call cty05g00_dados_apolice(lr_param.succod
                                 ,lr_param.aplnumdig)
      returning lr_cta01m61.erro        ,
                lr_cta01m61.mens        ,
                lr_cta01m61.emsdat      ,
                lr_cta01m61.aplstt      ,
                lr_cta01m61.vigfnl      ,
                lr_cta01m61.segnumdig

        if lr_cta01m61.erro = 1 then

              call osgtf550_busca_pesnum_por_unfclisegcod(lr_cta01m61.segnumdig)
              returning lr_retorno.erro,
                        lr_cta01m61.pesnum

              if lr_retorno.erro = 0     then
                   call osgtf550_busca_cliente_por_pesnum(lr_cta01m61.pesnum)
                   returning lr_retorno.erro
              end if

              if lr_retorno.erro = 0 then
                  let lr_retorno.cgccpfnum = gr_gsakpes.cgccpfnum
                  let lr_retorno.cgcord    = gr_gsakpes.cgcord
                  let lr_retorno.cgccpfdig = gr_gsakpes.cgccpfdig
                  let lr_retorno.pesnom    = gr_gsakpes.pesnom
                  let lr_retorno.pestip    = gr_gsakpes.pestip
              end if
        end if
   else

       # Obter dados apolice RE
       call cty06g00_dados_apolice(lr_param.succod
                                  ,lr_param.ramcod
                                  ,lr_param.aplnumdig
                                  ,lr_param.ramsgl)
       returning lr_cta01m61.erro      ,
                 lr_cta01m61.mens      ,
                 lr_cta01m61.sgrorg    ,
                 lr_cta01m61.sgrnumdig ,
                 lr_cta01m61.vigfnl    ,
                 lr_cta01m61.aplstt    ,
                 lr_cta01m61.prporg    ,
                 lr_cta01m61.prpnumdig ,
                 lr_cta01m61.segnumdig ,
                 lr_cta01m61.edsnumref

        if lr_cta01m61.erro = 1 then

              call osgtf550_busca_pesnum_por_unfclisegcod(lr_cta01m61.segnumdig)
              returning lr_retorno.erro,
                        lr_cta01m61.pesnum

              if lr_retorno.erro = 0     then
                   call osgtf550_busca_cliente_por_pesnum(lr_cta01m61.pesnum)
                   returning lr_retorno.erro
              end if

              if lr_retorno.erro = 0 then
                  let lr_retorno.cgccpfnum = gr_gsakpes.cgccpfnum
                  let lr_retorno.cgcord    = gr_gsakpes.cgcord
                  let lr_retorno.cgccpfdig = gr_gsakpes.cgccpfdig
                  let lr_retorno.pesnom    = gr_gsakpes.pesnom
                  let lr_retorno.pestip    = gr_gsakpes.pestip
              end if
         end if
   end if

   # Recupero as Apolices da Azul
   if lr_retorno.cgccpfnum is null then
        call cta01m61_rec_apolice_azul(lr_param.succod   ,
                                       lr_param.aplnumdig,
                                       lr_param.itmnumdig,
                                       lr_param.ramcod)
        returning lr_retorno.erro      ,
                  lr_retorno.cgccpfnum ,
                  lr_retorno.cgcord    ,
                  lr_retorno.cgccpfdig ,
                  lr_retorno.pesnom    ,
                  lr_retorno.pestip
   end if

   # Recupero as Apolices do Itau
   if lr_retorno.cgccpfnum is null then
        call cta01m61_rec_apolice_itau(lr_param.itaciacod,
                                       lr_param.ramcod   ,
                                       lr_param.aplnumdig,
                                       lr_param.itmnumdig)
        returning lr_retorno.erro      ,
                  lr_retorno.cgccpfnum ,
                  lr_retorno.cgcord    ,
                  lr_retorno.cgccpfdig ,
                  lr_retorno.pesnom    ,
                  lr_retorno.pestip
   end if

   if lr_retorno.cgccpfnum is null then
      let lr_retorno.mens = "Dados da Apolice nao Encontrada"
      let lr_retorno.erro = 1
   else
      let lr_retorno.erro = 0
   end if

   return lr_retorno.*
end function

#--------------------------------------------------------------------------
function cta01m61_rec_licenca_azul(lr_param)
#--------------------------------------------------------------------------

define lr_param record
    vcllicnum   like abbmveic.vcllicnum
end record

define lr_retorno record
   azlaplcod  integer                   ,
   doc_handle integer                   ,
   documento  char(30)                  ,
   itmnumdig  decimal(7,0)              ,
   edsnumref  decimal(9,0)              ,
   succod     like datrligapol.succod   ,
   ramcod     smallint                  ,
   emsdat     date                      ,
   viginc     date                      ,
   vigfnl     date                      ,
   segcod     integer                   ,
   segnom     char(50)                  ,
   vcldes     char(25)                  ,
   corsus     char(06)                  ,
   situacao   char(10)                  ,
   ciaempcod  integer                   ,
   itaciacod  like datkitacia.itaciacod
end record

define l_index integer

initialize lr_retorno.* to null


if m_prepare is null or
   m_prepare <> true then
    call cta01m61_prepare()
end if

     let l_index = 0

     open ccta01m61010 using lr_param.vcllicnum

     foreach ccta01m61010 into  lr_retorno.azlaplcod

        let lr_retorno.doc_handle = ctd02g00_agrupaXML(lr_retorno.azlaplcod)
        let l_index = l_index - 1

        call cts38m00_extrai_dados_xml(lr_retorno.doc_handle)
             returning lr_retorno.documento,
                       lr_retorno.itmnumdig,
                       lr_retorno.edsnumref,
                       lr_retorno.succod,
                       lr_retorno.ramcod,
                       lr_retorno.emsdat,
                       lr_retorno.viginc,
                       lr_retorno.vigfnl,
                       lr_retorno.segcod,
                       lr_retorno.segnom,
                       lr_retorno.vcldes,
                       lr_retorno.corsus,
                       lr_retorno.situacao

         let lr_retorno.ciaempcod = 35

         whenever error continue
         execute p_insert using lr_retorno.succod   ,
                                lr_retorno.ramcod   ,
                                l_index             ,
                                lr_retorno.azlaplcod,
                                lr_retorno.itmnumdig,
                                lr_retorno.viginc   ,
                                lr_retorno.vigfnl   ,
                                lr_retorno.segnom   ,
                                lr_retorno.situacao ,
                                lr_retorno.ciaempcod,
                                lr_retorno.itaciacod
         whenever error stop

      end foreach

      return

end function

#--------------------------------------------------------------------------
function cta01m61_rec_licenca_itau(lr_param)
#--------------------------------------------------------------------------

define lr_param record
    autplcnum   like datmitaaplitm.autplcnum
end record

define lr_retorno record
   itaciacod       like datmitaapl.itaciacod          ,
   itaramcod       like datmitaapl.itaramcod          ,
   itaaplnum       like datmitaapl.itaaplnum          ,
   aplseqnum       like datmitaapl.aplseqnum          ,
   itaaplitmnum    like datmitaaplitm.itaaplitmnum    ,
   succod          like datmitaapl.succod             ,
   ciaempcod       integer                            ,
   segnom          like datmitaapl.segnom             ,
   pestipcod       like datmitaapl.pestipcod          ,
   segcgccpfnum    like datmitaapl.segcgccpfnum       ,
   segcgcordnum    like datmitaapl.segcgcordnum       ,
   segcgccpfdig    like datmitaapl.segcgccpfdig       ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat    ,
   itaaplvigfnldat like datmitaapl.itaaplvigfnldat    ,
   itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod ,
   situacao        char(10)                           ,
   erro            integer                            ,
   mensagem        char(50)
end record

initialize lr_retorno.* to null


if m_prepare is null or
   m_prepare <> true then
    call cta01m61_prepare()
end if


     # Pesquisa Apolice por Placa

     call cty22g00_rec_apolice_por_placa(lr_param.autplcnum)
     returning lr_retorno.itaciacod     ,
               lr_retorno.itaramcod     ,
               lr_retorno.itaaplnum     ,
               lr_retorno.aplseqnum     ,
               lr_retorno.itaaplitmnum  ,
               lr_retorno.succod        ,
               lr_retorno.erro          ,
               lr_retorno.mensagem

     let lr_retorno.ciaempcod = 84

     if lr_retorno.erro = 0 then

        # Recupera Dados do Itau

        call cty22g00_rec_cgc_cpf_itau(lr_retorno.itaciacod    ,
                                       lr_retorno.itaramcod    ,
                                       lr_retorno.itaaplnum    ,
                                       lr_retorno.aplseqnum    ,
                                       lr_retorno.itaaplitmnum )
        returning lr_retorno.segnom          ,
                  lr_retorno.pestipcod       ,
                  lr_retorno.segcgccpfnum    ,
                  lr_retorno.segcgcordnum    ,
                  lr_retorno.segcgccpfdig    ,
                  lr_retorno.itaaplvigincdat ,
                  lr_retorno.itaaplvigfnldat ,
                  lr_retorno.itaaplcanmtvcod ,
                  lr_retorno.erro            ,
                  lr_retorno.mensagem

     end if

     if lr_retorno.erro = 0 then

        # Verifica Situação do Documento

        if lr_retorno.itaaplvigincdat <= today and
           lr_retorno.itaaplvigfnldat  >= today then
              if lr_retorno.itaaplcanmtvcod is null then
                   let lr_retorno.situacao = "ATIVA"
              else
                   let lr_retorno.situacao = "CANCELADA"
              end if
        else
              let lr_retorno.situacao = "VENCIDA"
        end if

        whenever error continue
        execute p_insert using lr_retorno.succod          ,
                               lr_retorno.itaramcod       ,
                               lr_retorno.aplseqnum       ,
                               lr_retorno.itaaplnum       ,
                               lr_retorno.itaaplitmnum    ,
                               lr_retorno.itaaplvigincdat ,
                               lr_retorno.itaaplvigfnldat ,
                               lr_retorno.segnom          ,
                               lr_retorno.situacao        ,
                               lr_retorno.ciaempcod       ,
                               lr_retorno.itaciacod
        whenever error stop

     end if

     return

end function


#--------------------------------------------------------------------------
function cta01m61_rec_dados_azul(lr_param)
#--------------------------------------------------------------------------

define lr_param record
  azlaplcod integer
end record

define lr_retorno record
  erro      integer                ,
  cgccpfnum like gsakpes.cgccpfnum ,
  cgcord    like gsakpes.cgcord    ,
  cgccpfdig like gsakpes.cgccpfdig ,
  pesnom    like gsakpes.pesnom    ,
  pestip    like gsakpes.pestip
end record

initialize lr_retorno.* to null

if m_prepare is null or
   m_prepare <> true then
    call cta01m61_prepare()
end if

   open ccta01m61011 using lr_param.azlaplcod
   whenever error continue
   fetch ccta01m61011  into lr_retorno.cgccpfnum ,
                            lr_retorno.cgcord    ,
                            lr_retorno.cgccpfdig ,
                            lr_retorno.pesnom    ,
                            lr_retorno.pestip
   whenever error stop

   if sqlca.sqlcode <> 0  then
      let lr_retorno.erro = 1
   else
      let lr_retorno.erro = 0
   end if

   close ccta01m61011

   return lr_retorno.*

end function

#--------------------------------------------------------------------------
function cta01m61_rec_dados_itau(lr_param)
#--------------------------------------------------------------------------

define lr_param record
   itaciacod       like datmitaapl.itaciacod       ,
   itaramcod       like datmitaapl.itaramcod       ,
   itaaplnum       like datmitaapl.itaaplnum       ,
   aplseqnum       like datmitaapl.aplseqnum       ,
   itaaplitmnum    like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
   segnom          like datmitaapl.segnom             ,
   pestipcod       like datmitaapl.pestipcod          ,
   segcgccpfnum    like datmitaapl.segcgccpfnum       ,
   segcgcordnum    like datmitaapl.segcgcordnum       ,
   segcgccpfdig    like datmitaapl.segcgccpfdig       ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat    ,
   itaaplvigfnldat like datmitaapl.itaaplvigfnldat    ,
   itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod ,
   erro            integer                            ,
   mensagem        char(50)
end record

initialize lr_retorno.* to null


if m_prepare is null or
   m_prepare <> true then
    call cta01m61_prepare()
end if

    # Recupera Dados do Itau

    call cty22g00_rec_cgc_cpf_itau(lr_param.itaciacod    ,
                                   lr_param.itaramcod    ,
                                   lr_param.itaaplnum    ,
                                   lr_param.aplseqnum    ,
                                   lr_param.itaaplitmnum )
    returning lr_retorno.segnom          ,
              lr_retorno.pestipcod       ,
              lr_retorno.segcgccpfnum    ,
              lr_retorno.segcgcordnum    ,
              lr_retorno.segcgccpfdig    ,
              lr_retorno.itaaplvigincdat ,
              lr_retorno.itaaplvigfnldat ,
              lr_retorno.itaaplcanmtvcod ,
              lr_retorno.erro            ,
              lr_retorno.mensagem

    if lr_retorno.erro <> 0 then
          let lr_retorno.erro = 1
    end if

   return lr_retorno.erro           ,
          lr_retorno.segcgccpfnum   ,
          lr_retorno.segcgcordnum   ,
          lr_retorno.segcgccpfdig   ,
          lr_retorno.segnom         ,
          lr_retorno.pestipcod

end function


#--------------------------------------------------------------------------
function cta01m61_rec_apolice_azul(lr_param)
#--------------------------------------------------------------------------

define lr_param record
   succod     like datkazlapl.succod,
   aplnumdig  like datkazlapl.aplnumdig,
   itmnumdig  like datkazlapl.itmnumdig,
   ramcod     like datkazlapl.ramcod
end record

define lr_retorno record
  erro      integer                ,
  cgccpfnum like gsakpes.cgccpfnum ,
  cgcord    like gsakpes.cgcord    ,
  cgccpfdig like gsakpes.cgccpfdig ,
  pesnom    like gsakpes.pesnom    ,
  pestip    like gsakpes.pestip
end record

initialize lr_retorno.* to null
if m_prepare is null or
   m_prepare <> true then
    call cta01m61_prepare()
end if

     open ccta01m61012 using lr_param.*
     whenever error continue
     fetch ccta01m61012 into  lr_retorno.cgccpfnum ,
                              lr_retorno.cgcord    ,
                              lr_retorno.cgccpfdig ,
                              lr_retorno.pesnom    ,
                              lr_retorno.pestip
     whenever error stop

     if sqlca.sqlcode <> 0  then
         let lr_retorno.erro = 1
     else
         let lr_retorno.erro = 0
     end if

     close ccta01m61012

     return lr_retorno.*

end function

#--------------------------------------------------------------------------
function cta01m61_rec_apolice_itau(lr_param)
#--------------------------------------------------------------------------

define lr_param record
   itaciacod       like datmitaapl.itaciacod       ,
   itaramcod       like datmitaapl.itaramcod       ,
   itaaplnum       like datmitaapl.itaaplnum       ,
   itaaplitmnum    like datmitaaplitm.itaaplitmnum
end record

define lr_retorno record
   aplseqnum       like datmitaapl.aplseqnum          ,
   segnom          like datmitaapl.segnom             ,
   pestipcod       like datmitaapl.pestipcod          ,
   segcgccpfnum    like datmitaapl.segcgccpfnum       ,
   segcgcordnum    like datmitaapl.segcgcordnum       ,
   segcgccpfdig    like datmitaapl.segcgccpfdig       ,
   itaaplvigincdat like datmitaapl.itaaplvigincdat    ,
   itaaplvigfnldat like datmitaapl.itaaplvigfnldat    ,
   itaaplcanmtvcod like datmitaaplitm.itaaplcanmtvcod ,
   erro            integer                            ,
   mensagem        char(50)
end record

initialize lr_retorno.* to null
let lr_retorno.erro = 0

     # Verifica a Ultima Sequencia da Apolice

     call cty22g00_rec_ult_sequencia(lr_param.itaciacod,
                                     lr_param.itaramcod,
                                     lr_param.itaaplnum)
     returning lr_retorno.aplseqnum,
               lr_retorno.erro     ,
               lr_retorno.mensagem

     if lr_retorno.erro = 0 then

          call cta01m61_rec_dados_itau(lr_param.itaciacod  ,
                                       lr_param.itaramcod  ,
                                       lr_param.itaaplnum  ,
                                       lr_retorno.aplseqnum,
                                       lr_param.itaaplitmnum)
          returning lr_retorno.erro           ,
                    lr_retorno.segcgccpfnum   ,
                    lr_retorno.segcgcordnum   ,
                    lr_retorno.segcgccpfdig   ,
                    lr_retorno.segnom         ,
                    lr_retorno.pestipcod

     end if

     return lr_retorno.erro          ,
            lr_retorno.segcgccpfnum  ,
            lr_retorno.segcgcordnum  ,
            lr_retorno.segcgccpfdig  ,
            lr_retorno.segnom        ,
            lr_retorno.pestipcod

end function