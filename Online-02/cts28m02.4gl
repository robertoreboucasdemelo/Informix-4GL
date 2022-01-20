###############################################################################
# Nome do Modulo: CTS28M02                                            Ruiz    #
# Acionamento dos prestadores de sinistro de transportes.            Out/2002 #
#-----------------------------------------------------------------------------#
#                         * * * A L T E R A C A O * * *                       #
# ........................................................................... #
# Data        Autor Fabrica   OSF/PSI       Alteracao                         #
# ----------  -------------  -------------  ----------------------------------#
# 27/01/2004  Sonia Sasaki   31631/177903   Inclusao F6 e execucao da funcao  #
#                                           cta11m00 (Motivos de recusa).     #
#                                                                             #
#                                                                             #
#-----------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"

#---------------------------------------------------------------
function cts28m02(param)
#---------------------------------------------------------------
   define param  record
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt
   end record
   define a_cts28m02   array[200] of record
          sinprsnom    like sstkprest.sinprsnom,
          sinprscod    like sstkprest.sinprscod,
          endlgd       like sstkprest.endlgd,
          endbrr       like sstkprest.endbrr,
          endcid       like sstkprest.endcid,
          endufd       like sstkprest.endufd,
          sinprstip    char (20)            ,
          dddcod       like sstkprest.dddcod,
          telnum       like sstkprest.telnum,
          cllddd       like sstkprest.cllddd,
          clltelnum    like sstkprest.clltelnum,
          calckm       dec (8,4),
          prssrvultdat like  sstkprest.prssrvultdat,
          obs1         char (50)    ,
          obs2         char (50)    ,
          obs3         char (50)    ,
          lclltt       like datmlcl.lclltt,
          lcllgt       like datmlcl.lcllgt,
          class        char (06),
          prssrvulthor like  sstkprest.prssrvulthor
   end record
   define a_cts28m02b array[200] of record
          sinprsnom    like sstkprest.sinprsnom,
          sinprscod    like sstkprest.sinprscod,
          endlgd       like sstkprest.endlgd,
          endbrr       like sstkprest.endbrr,
          endcid       like sstkprest.endcid,
          endufd       like sstkprest.endufd,
          sinprstip    char (20)            ,
          dddcod       like sstkprest.dddcod,
          telnum       like sstkprest.telnum,
          cllddd       like sstkprest.cllddd,
          clltelnum    like sstkprest.clltelnum,
          calckm       dec (8,4),
          prssrvultdat like  sstkprest.prssrvultdat,
          obs1         char (50)    ,
          obs2         char (50)    ,
          obs3         char (50)    ,
          lclltt       like datmfrtpos.lclltt,
          lcllgt       like datmfrtpos.lcllgt,
          class        char (06),
          prssrvulthor like  sstkprest.prssrvulthor
   end record
   define ws   record
          count        integer,
          sinavsnum    like sstmstpavs.sinavsnum,
          sintraprstip like sstkprest.sintraprstip,
          obs          like sstkprest.obs
   end record
   define w_tmp record
          revezamento  smallint,
          distancia    dec (8,4),
          nivel        smallint,
          codigo       like sstkprest.sinprscod,
          tipo         char (01),
          count        smallint
   end record

   define l_srvrcumtvcod  like datmsrvacp.srvrcumtvcod
         ,l_atdsrvorg     like datmservico.atdsrvorg

   define arr_aux      smallint
   define arr_aux1     smallint
   define arr_aux2     smallint
   define arr_aux3     smallint
   define scr_aux      smallint


	define	w_pf1	integer

	let	arr_aux  =  null
	let	arr_aux1  =  null
	let	arr_aux2  =  null
	let	arr_aux3  =  null
	let	scr_aux  =  null

	for	w_pf1  =  1  to  200
		initialize  a_cts28m02[w_pf1].*  to  null
	end	for

	for	w_pf1  =  1  to  200
		initialize  a_cts28m02b[w_pf1].*  to  null
	end	for

	initialize  ws.*  to  null

	initialize  w_tmp.*  to  null

   initialize ws.*     to null
   initialize w_tmp.*  to null

   open window w_cts28m02 at 05,02 with form "cts28m02"
        attribute(form line first, border)

   if g_documento.atdsrvnum is null then
      error "ATENCAO! Servico nao Cadastrado, AVISE INFO."
      let int_flag = false
      close window w_cts28m02
      return "",""
   end if
   select sinavsnum
     into ws.sinavsnum
     from datrligtrp
    where atdsrvnum = g_documento.atdsrvnum
      and atdsrvano = g_documento.atdsrvano

   call fsstc025(ws.sinavsnum)

   -------[ verifica se temporaria existe - criada funcao fsstc025]------
   select count(*)
          into w_tmp.count
          from tmp_transp
   if sqlca.sqlcode = notfound then
      error "ATENCAO! Tab.Temp nao gerada, AVISE INFO."
      let int_flag = false
      close window w_cts28m02
      return "",""
   end if
   if w_tmp.count    = 0      then
      error "ATENCAO! Tab.Temp esta vazia, AVISE INFO."
      let int_flag = false
      close window w_cts28m02
      return "",""
   end if
   ---------------------------------------------------------------------
   let arr_aux =  1
   declare c_cts28m02_001 cursor for
       select codigo,revezamento,nivel
          from tmp_transp
   foreach c_cts28m02_001 into a_cts28m02b[arr_aux].sinprscod,
                                 w_tmp.revezamento,
                                 w_tmp.nivel
       display "* a_cts28m02b[arr_aux].sinprscod = ",
                  a_cts28m02b[arr_aux].sinprscod," ",
                  w_tmp.revezamento," ",w_tmp.distancia," ",w_tmp.nivel

       select lclltt, lcllgt
              into a_cts28m02b[arr_aux].lclltt,
                   a_cts28m02b[arr_aux].lcllgt
              from sstkprest
             where sinprscod = a_cts28m02b[arr_aux].sinprscod
       if a_cts28m02b[arr_aux].lclltt is null or
          a_cts28m02b[arr_aux].lcllgt is null then
          continue foreach
       end if
       ------[calcula distancia entre o sinistro e o prestador]------
       initialize a_cts28m02b[arr_aux].calckm  to null
       call cts18g00(param.lclltt,param.lcllgt,
                     a_cts28m02b[arr_aux].lclltt,
                     a_cts28m02b[arr_aux].lcllgt)
           returning a_cts28m02b[arr_aux].calckm

       ------------[ grava a distancia calculada na tab.temp. ]----------
       update tmp_transp
          set distancia = a_cts28m02b[arr_aux].calckm
          where codigo  = a_cts28m02b[arr_aux].sinprscod

       let arr_aux = arr_aux + 1
       if arr_aux > 200   then
          error "Limite excedido. Pesquisa com mais de 300 prestadores!"
          exit foreach
       end if
   end foreach
   let arr_aux =  1
   declare c_cts28m02_002 cursor for
       select revezamento,
              distancia,
              nivel,
              codigo,
              tipo
          from tmp_transp
          order by revezamento,distancia,nivel

   foreach c_cts28m02_002 into w_tmp.revezamento,
                                  w_tmp.distancia  ,
                                  w_tmp.nivel      ,
                                  a_cts28m02[arr_aux].sinprscod,
                                  w_tmp.tipo
       select sintraprstip, sinprsnom   , endlgd      , endbrr      ,
              endcid      , endufd      , dddcod      , telnum      ,
              cllddd      , clltelnum   , prssrvultdat, obs         ,
              lclltt      , lcllgt      , prssrvulthor
         into ws.sintraprstip,
              a_cts28m02[arr_aux].sinprsnom, a_cts28m02[arr_aux].endlgd   ,
              a_cts28m02[arr_aux].endbrr   , a_cts28m02[arr_aux].endcid   ,
              a_cts28m02[arr_aux].endufd   , a_cts28m02[arr_aux].dddcod   ,
              a_cts28m02[arr_aux].telnum   , a_cts28m02[arr_aux].cllddd   ,
              a_cts28m02[arr_aux].clltelnum, a_cts28m02[arr_aux].prssrvultdat,
              ws.obs                       , a_cts28m02[arr_aux].lclltt   ,
              a_cts28m02[arr_aux].lcllgt   , a_cts28m02[arr_aux].prssrvulthor
          from sstkprest
         where sinprscod = a_cts28m02[arr_aux].sinprscod
       display "* a_cts28m02[arr_aux].sinprscod = ",
                  a_cts28m02[arr_aux].sinprscod," ",
                  w_tmp.revezamento," ",w_tmp.distancia," ",w_tmp.nivel

       if a_cts28m02[arr_aux].lclltt is null or
          a_cts28m02[arr_aux].lcllgt is null then
          continue foreach
       end if
       if w_tmp.distancia = 27.0000 then
          initialize w_tmp.distancia to null
       end if
       let a_cts28m02[arr_aux].calckm = w_tmp.distancia
       case w_tmp.nivel
          when 1    let a_cts28m02[arr_aux].class = "SENIOR"
          when 2    let a_cts28m02[arr_aux].class = "PLENO "
          when 3    let a_cts28m02[arr_aux].class = "JUNIOR"
          otherwise let a_cts28m02[arr_aux].class = null
       end case
       case ws.sintraprstip
          when "A"  let a_cts28m02[arr_aux].sinprstip = "AUDITOR"
          when "V"  let a_cts28m02[arr_aux].sinprstip = "VISTORIADOR EXTERNO"
          when "I"  let a_cts28m02[arr_aux].sinprstip = "INVESTIGADOR"
          when "S"  let a_cts28m02[arr_aux].sinprstip = "SOCORRISTA"
          when "X"  let a_cts28m02[arr_aux].sinprstip = "VIST./INVESTIGADOR"
          otherwise let a_cts28m02[arr_aux].sinprstip = "*** NAO PREVISTO ***"
       end case
       let a_cts28m02[arr_aux].obs1 = ws.obs[001,050]
       let a_cts28m02[arr_aux].obs2 = ws.obs[051,100]
       let a_cts28m02[arr_aux].obs3 = ws.obs[101,150]
       let arr_aux = arr_aux + 1
       if arr_aux > 200   then
          error "Limite excedido. Pesquisa com mais de 300 prestadores!"
          exit foreach
       end if
   end foreach
   if arr_aux > 1 then
      message " (F17)Abandona, (F6)Recusa, (F8)Seleciona"
      call set_count(arr_aux-1)

      display array a_cts28m02 to s_cts28m02.*
           on key (interrupt,control-c)
              let arr_aux = 1
              initialize a_cts28m02  to null
              exit display

	   on key (F6)
	      let arr_aux         = arr_curr()

	      whenever error continue
	         select atdsrvorg into l_atdsrvorg
		   from datmservico
	          where atdsrvnum = g_documento.atdsrvnum
		    and atdsrvano = g_documento.atdsrvano
              whenever error stop

	      if sqlca.sqlcode = 0 then
                 call cta11m00 ( l_atdsrvorg
                                ,g_documento.atdsrvnum
			        ,g_documento.atdsrvano
			        ,a_cts28m02[arr_aux].sinprscod
			        ,"S")
                      returning l_srvrcumtvcod
              else
                  if sqlca.sqlcode < 0 then
                     error "Erro ", sqlca.sqlcode using "<<<<<&",
			   " na selecao da tabela datmservico."
		  end if
	      end if

           on key (F8)
              let arr_aux         = arr_curr()
              let scr_aux         = scr_line()
              error " Prestador selecionada!"
              exit display
      end display
   else
      message " "
      error "Nenhum Prestador Localizado!"
      initialize a_cts28m02  to null
   end if

   let int_flag = false
   close window w_cts28m02
   return a_cts28m02[arr_aux].sinprscod,
          a_cts28m02[arr_aux].calckm

end function  #  cts28m02
