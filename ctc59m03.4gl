#----------------------------------------------------------------#
# PORTO SEGURO CIA DE SEGUROS GERAIS                             #
#................................................................#
#  Sistema        :                                              #
#  Modulo         : CTC59M03.4gl                                 #
#                   Regulador de servicos por quota VERIFICACAO  #
#  Analista Resp. : Raji                                         #
#  PSI            :                                              #
#................................................................#
#  Desenvolvimento:                                              #
#  Liberacao      : jul/2002                                     #
#................................................................#
#                     * * *  ALTERACOES  * * *                   #
#                                                                #
#  Data         Autor Fabrica     Alteracao                      #
#  ----------   ----------------  ------------------------------ #
#  27/05/2004   Marcio Hashiguti  CT-213365 - incluir whenever   #
#                                 error continue e whenever error#
#                                 stop                           #
#  13/01/2006   Priscila Staingel PSI 197416 confirmar se servico#
#                                 imediato caso seja servico re e#
#                                 tenha quota para a hora atual  #
#  19/10/2006   Ligia Mattge      calcula hora/data inicial para #
#                                 consulta (+3h) PSI 202363      #
#  10/11/2006   Priscila Staingel AS - Chamar funcao para validar#
#                                 se cidade e cidade sede        #
#----------------------------------------------------------------#
# 07/07/2008 Andre Oliveira       Inclusao da funcao 'regulador' #
#                                 'ctc59m03_regulador' no modulo.#
#----------------------------------------------------------------#
 
globals '/homedsa/projetos/geral/globals/glct.4gl'
 
define m_prep_sql smallint

#--------------------------------------------------------------
 function ctc59m03(p_ctc59m03)
#--------------------------------------------------------------
 define p_ctc59m03   record
    cidnom           like glakcid.cidnom,
    ufdcod           like glakcid.ufdcod,
    atdsrvorg        like datmsrvrgl.atdsrvorg,
    srvrglcod        like datmsrvrgl.srvrglcod,
    rgldat           like datmsrvrgl.rgldat,
    rglhor           char(5)
 end record

 define ret record
    rgldat           like datmsrvrgl.rgldat,
    rglhor           like datmsrvrgl.rglhor
 end record

 define ws record
    cotqtd           like datmsrvrgl.cotqtd,
    utlqtd           like datmsrvrgl.utlqtd,
    cont             smallint,
    srvrglcod        like datmsrvrgl.srvrglcod,
    cidcod           like glakcid.cidcod,
    cidsedcod        like glakcid.cidcod,
    horstr           char(5),
    hora             like datmsrvrgl.rglhor,
    socntrzgrpcod    like datksocntzgrp.socntzgrpcod,

    agdhor           like datmsrvrgl.rglhor,
    agddat           like datmsrvrgl.rgldat,
    popup            char(6000),
    seldes           char(20),
    selnum           smallint,
    rgldatmax        like datmsrvrgl.rgldat,

    datymd           datetime year to day,
    dathor           datetime year to minute,
    strdathor        char(20),
    
    agdlimqtd        like datksrvtip.agdlimqtd
 end record
 
 define a_ctc59m03  array[200] of record
      agdhor           like datmsrvrgl.rglhor,
      agddat           like datmsrvrgl.rgldat
 end record

 define l_ret                  smallint      #AS 10/11
 define l_mensagem             smallint  #AS 10/11
 define l_cidcod          like glakcid.cidcod
 define l_atdhrrfxahorqtd like datracncid.atdhrrfxahorqtd
 define l_agddatprog      like datmsrvrgl.rgldat 
 define l_agdhorprog      char(5)
 define l_agdminprog      char(5)
 define  w_pf1            integer

	initialize  ret.*  to  null

	initialize  ws.*  to  null

 initialize ret.* to null
 initialize ws.* to null 
 
 for     w_pf1  =  1  to  200
         initialize  a_ctc59m03[w_pf1].*  to  null
 end     for
 
 let l_cidcod          = null  
 let l_atdhrrfxahorqtd = null  
 let l_agddatprog = null
 let l_agdhorprog = null
 let l_agdminprog = null
 
 #Priscila AS 10/11
 # Verifica se a cidade esta cadastrada
 #declare c_glakcid cursor for
 #   select cidcod
 #     from glakcid
 #    where cidnom = p_ctc59m03.cidnom
 #      and ufdcod = p_ctc59m03.ufdcod
 #
 # open  c_glakcid
 # fetch c_glakcid  into  ws.cidcod
 
 call cty10g00_obter_cidcod(p_ctc59m03.cidnom, p_ctc59m03.ufdcod)
      returning l_ret, l_mensagem, ws.cidcod     
 

 # Verifica se a cidade e atendida por uma cidade sede
 #whenever error continue              #CT-213365
 #select cidsedcod
 #       into ws.cidsedcod
 #  from datrcidsed
 # where cidcod = ws.cidcod
 #whenever error stop                  #CT-213365
 #if sqlca.sqlcode <> 0 then
 #   let ws.cidsedcod = ws.cidcod
 #end if
 
 
 call ctd01g00_obter_cidsedcod(1, ws.cidcod)
      returning l_ret, l_mensagem, ws.cidsedcod          
      
 ## Jorge Modena     
 if l_ret <> 1 then    
    let l_cidcod = 0
 else
    let l_cidcod = ws.cidsedcod
 end if  


 # Se RE Busca grupo de natureza
 let ws.srvrglcod = p_ctc59m03.srvrglcod
 if p_ctc59m03.atdsrvorg = 9 then
    select socntzgrpcod
           into ws.srvrglcod
      from datksocntz
     where socntzcod = p_ctc59m03.srvrglcod
    if sqlca.sqlcode <> 0 then
       let ws.srvrglcod = p_ctc59m03.srvrglcod
    end if

 end if
 
 #whenever error continue
  # Identifica quantidade de horas que dever? ser exibida na faixa horaria
 if (l_cidcod <> 0) then 	
	 select atdhrrfxahorqtd
	        into l_atdhrrfxahorqtd
	    from datkatmacnprt , datracncid
	   where datkatmacnprt.atmacnprtcod = datracncid.atmacnprtcod
	      and datkatmacnprt.atdsrvorg = p_ctc59m03.atdsrvorg
	      and datkatmacnprt.atmacnprtcod = ( select max (atmacnprtcod)
	                                           from  datkatmacnprt
	                                             where atdsrvorg = p_ctc59m03.atdsrvorg)
	     and datracncid.cidcod = l_cidcod
 end if 
 
 if sqlca.sqlcode <> 0 or l_cidcod = 0 then
 	select grlinf 
 	  into l_atdhrrfxahorqtd
 	  from datkgeral 	       
          where grlchv = 'PSOQTDHRFXPROG'
 end if
 #whenever error stop
  
  if sqlca.sqlcode <> 0 then
       error "Erro consultar Quantidade Hora Faixa Horaria"
       let l_atdhrrfxahorqtd = 0
  end if

 # calcula hora/data inicial para consulta (+2h)
 let ws.datymd    = p_ctc59m03.rgldat
 let ws.strdathor = ws.datymd, " ", p_ctc59m03.rglhor
 let ws.dathor    = ws.strdathor

 ## apresentar agenda com acrecimo de +2h para RE e +1h para AUTO - Solicitacao pelo Nicola 14/01/2015
 ## PSI 202363
 if p_ctc59m03.atdsrvorg <> 9 then   
    let ws.dathor    = ws.dathor + 60 units minute
 else
    let ws.dathor    = ws.dathor + 2 units hour
 end if

 let ws.strdathor = ws.dathor
 let ws.datymd    = ws.strdathor[1,10]
 let p_ctc59m03.rgldat = ws.datymd
 let p_ctc59m03.rglhor = ws.strdathor[12,17]

 # calcula limite de dias para agendamento
 select agdlimqtd into ws.agdlimqtd
   from datksrvtip 
  where atdsrvorg = p_ctc59m03.atdsrvorg
  if sqlca.sqlcode <> 0 then
     let ws.agdlimqtd = 8
  end if
  let ws.rgldatmax =  p_ctc59m03.rgldat + ws.agdlimqtd units day

 # Calcula hora cheia
 #let ws.horstr = p_ctc59m03.rglhor[1,2], ":00"
 #let ws.hora   = ws.horstr
 
 #Calcula hora quebrada 
 let  ws.horstr   = p_ctc59m03.rglhor[4,5]
 
 if ws.horstr <= 30 and (ws.horstr > 0 or ws.horstr = 00 ) then
    let ws.horstr = p_ctc59m03.rglhor[1,2], ":30"    
 else
    let ws.horstr = p_ctc59m03.rglhor[1,2] + 1  using "&&"
    
    if ws.horstr >= 24 then
       let ws.horstr = "0", ws.horstr - 24
       let p_ctc59m03.rgldat = p_ctc59m03.rgldat + 1 units day   
    end if
    let ws.horstr = ws.horstr[1,2],":00"
 end if
 
 let ws.hora   = ws.horstr clipped

 set lock mode to not wait

 declare c_ctc59m03 cursor for
    select rgldat, rglhor
      from datmsrvrgl
     where cidcod = ws.cidsedcod
       and atdsrvorg = p_ctc59m03.atdsrvorg
       and srvrglcod = ws.srvrglcod
       and (rgldat > p_ctc59m03.rgldat
            ##or (rgldat = p_ctc59m03.rgldat and rglhor >  ws.hora))
            or (rgldat = p_ctc59m03.rgldat and rglhor >= ws.hora)) 
       and rgldat < ws.rgldatmax
       and cotqtd > utlqtd
    order by rgldat, rglhor
    
     

 let ws.popup = ""
 let ws.cont = 0
 let w_pf1 = 1
                                   
 foreach c_ctc59m03 into ws.agddat,
                         ws.agdhor
    #armazenar data e hora retornada da agenda/regulador                     
    let a_ctc59m03[w_pf1].agddat = ws.agddat
    let a_ctc59m03[w_pf1].agdhor = ws.agdhor   
    
    #Jorge Modena
    if l_atdhrrfxahorqtd = 0 then                     
	    if ws.cont = 0 then
	       let ws.popup = ws.popup clipped,
	                      ws.agddat," ",ws.agdhor
	    else
	       let ws.popup = ws.popup clipped, "|",
	                      ws.agddat," ",ws.agdhor
	    end if
    else
        let l_agdhorprog = ws.agdhor
        let l_agdminprog = ws.agdhor
        let l_agdhorprog = l_agdhorprog[1,2] + l_atdhrrfxahorqtd  using "&&"
    
    
        if l_agdhorprog >= 24 then
           let l_agdhorprog = l_agdhorprog - 24
           if l_agdhorprog < 10 then
               let l_agdhorprog = "0", l_agdhorprog 
           end if 
                      
           let l_agddatprog = ws.agddat + 1 units day  
           let l_agdhorprog = l_agdhorprog[1,2],":", l_agdminprog[4,5] 
       
           if ws.cont = 0 then
	           let ws.popup = ws.popup clipped,
	                      "Entre ",ws.agddat using "dd/MM/yy" ," ",ws.agdhor, " e ", l_agdhorprog,  " de ",  l_agddatprog using "dd/MM" clipped
           else 
	           let ws.popup = ws.popup clipped, "|",
		               "Entre ",ws.agddat using "dd/MM/yy" ," ",ws.agdhor, " e ", l_agdhorprog,  " de ",  l_agddatprog using "dd/MM" clipped
           end if
        else
            let l_agdhorprog = l_agdhorprog[1,2],":", l_agdminprog[4,5] 
            let l_agddatprog = ws.agddat clipped
        
            if ws.cont = 0 then
	           let ws.popup = ws.popup clipped,
	                      ws.agddat using "dd/MM/yy"," entre ", ws.agdhor, " e ", l_agdhorprog clipped
	    else       
	           let ws.popup = ws.popup clipped, "|",
		                       ws.agddat using "dd/MM/yy"," entre ", ws.agdhor, " e ", l_agdhorprog clipped
            end if		                      
    
        end if
    
    
    end if     

    if ws.cont > 168  then
       exit foreach
    end if
    let ws.cont = ws.cont + 1
    let w_pf1 = w_pf1 + 1
    
 end foreach 

 if  ws.cont > 0 then
    call ctx14g01("Agenda Disponivel",ws.popup)
         returning ws.selnum,
                   ws.seldes
              
    let w_pf1 = ws.selnum
    if w_pf1 <> 0 then
       let ret.rgldat = a_ctc59m03[w_pf1].agddat
       let ret.rglhor = a_ctc59m03[w_pf1].agdhor
    else
       let ret.rgldat = null
       let ret.rglhor = null  
       #error "Nao foi selecionado nenhum horario disponivel!"
    end if
    #let ret.rgldat = ws.seldes[1,10]
    #let ret.rglhor = ws.seldes[12,16]
 else       
   let ret.rgldat = null
   let ret.rglhor = "00:00"    
   error "Nao existe agenda disponivel!"
 end if

 set lock mode to wait

 return ret.*

end function  #  ctc59m03

function ctc59m03_prepare()

 define l_sql char(1000)
 let l_sql = 'select socntzgrpcod ',
             'from datksocntz     ',
             'where socntzcod = ? '

 prepare pctc59m03004 from l_sql
 declare cctc59m03004 cursor for pctc59m03004

 let l_sql = 'select rgldat, rglhor, cotqtd, utlqtd ',
             'from datmsrvrgl                       ',
             'where cidcod = ?                      ',
             '  and atdsrvorg = ?                   ',
             '  and srvrglcod = ?                   ',
             '  and (rgldat = ? and rglhor = ?)     '

 prepare pctc59m03001 from l_sql
 declare cctc59m03001 cursor for pctc59m03001

 #let l_sql = 'select cidsedcod ',
 #            'from datrcidsed  ',
 #            'where cidcod = ? '
 #prepare pctc59m03003 from l_sql
 #declare cctc59m03003 cursor for pctc59m03003
 
 ## identificar 
 

 let m_prep_sql = true

end function

function ctc59m03_quota_imediato (param)

 define param record
    cidcod           like datmsrvrgl.cidcod,
    atdsrvorg        like datmsrvrgl.atdsrvorg,
    srvrglcod        like datmsrvrgl.srvrglcod,
    data             like datmsrvrgl.rgldat,
    hora             char(5)
 end record

 define l_sql  char(500)
 define l_cidsedcod    like glakcid.cidcod,
        l_horstr         char(5),
        l_hora           like datmsrvrgl.rglhor,
        l_cotqtd         like datmsrvrgl.cotqtd,
        l_utlqtd         like datmsrvrgl.utlqtd

 define l_ret     smallint   #AS 10/11
 define l_mensagem char(50)  #AS 10/11

 let l_cotqtd = 0
 let l_utlqtd = 0

 if m_prep_sql = false then
    call ctc59m03_prepare()
 end if

# #ligia 24/10
# if param.cidcod is null  then
#    if param.cidnom is null and 
#       param.ufdcod is null then
#       error " Falta parametros em ctc59m03_quota_imediato!!!!"
#       return 0
#    else
#       #Busca codigo cidade caso venha apenas nome cidade e sigla estado
#       let l_sql = 'select cidcod    ',
#                   'from glakcid     ',
#                   'where cidnom = ? ',
#                   '  and ufdcod = ? '
#       prepare pctc59m03002 from l_sql
#       declare cctc59m03002 cursor for pctc59m03002
#
#       open cctc59m03002 using param.cidnom,
#                               param.ufdcod
#
#       whenever error continue
#       fetch cctc59m03002 into param.cidcod
#
#       whenever error stop
#   end if
# end if


 #Priscila - AS - 10/11/06
 # Verifica se a cidade e atendida por uma cidade sede
 #open cctc59m03003 using param.cidcod
 #fetch cctc59m03003 into l_cidsedcod
 #if sqlca.sqlcode <> 0 then
 call ctd01g00_obter_cidsedcod(1, param.cidcod)
      returning l_ret, l_mensagem, l_cidsedcod
 if l_ret <> 1 then
    let l_cidsedcod = param.cidcod
 end if
 

 #Busca grupo para natureza
 open cctc59m03004 using param.srvrglcod
 fetch cctc59m03004 into param.srvrglcod

 #calcula hora cheia atual
 #let l_horstr = param.hora[1,2], ":00"
 #let l_hora = l_horstr
 
 #Calcula hora quebrada
 let  l_horstr   = param.hora[4,5]
 
 if l_horstr >= 30 and l_horstr > 0 then
    let l_horstr = param.hora[1,2], ":30"    
 else
    let l_horstr = param.hora[1,2]
    let l_horstr = l_horstr[1,2],":00"    
 end if
 
 let l_hora = l_horstr

 #Busca se tem cota para hora imediata
 open cctc59m03001 using l_cidsedcod,
                         param.atdsrvorg,
                         param.srvrglcod,
                         param.data,
                         l_hora

 fetch cctc59m03001 into param.data,
                         param.hora,
                         l_cotqtd,
                         l_utlqtd
 
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       #caso nao tenha nada cadastrado - permite que seja imediato
       return 1
    end if
    if g_origem <> "WEB" then
          display "Erro ",  sqlca.sqlcode, " ao buscar quota para servico imediato."
    end if
    return 0
 else
    if l_utlqtd >= l_cotqtd then
       return 0
    end if
 end if

 return 1

end function

#-------------------------------------
 function ctc59m03_regulador(param)
#-------------------------------------
# Para abater regulador quando servico for cancelado
 define param      record
    atdsrvnum      like datmservico.atdsrvnum,
    atdsrvano      like datmservico.atdsrvano
 end record

 define rgl_cts00m02   record
    cidnom           like glakcid.cidnom,
    ufdcod           like glakcid.ufdcod,
    atdsrvorg        like datmsrvrgl.atdsrvorg,
    srvrglcod        like datmsrvrgl.srvrglcod,
    rgldat           like datmsrvrgl.rgldat,
    rglhor           char(5)
 end record

 define ws record
    utlqtd           like datmsrvrgl.utlqtd,
    cont             smallint,
    srvrglcod        like datmsrvrgl.srvrglcod,
    cidcod           like glakcid.cidcod,
    cidsedcod        like glakcid.cidcod,
    horstr           char(5),
    hora             like datmsrvrgl.rglhor,
    socntrzgrpcod    like datksocntzgrp.socntzgrpcod,
    atddat           like datmservico.atddat,
    atdhor           like datmservico.atdhor,
    atddatprg        like datmservico.atddatprg,
    atdhorprg        like datmservico.atdhorprg,
    atdlibdat        like datmservico.atdlibdat,
    atdlibhor        like datmservico.atdlibhor,
    succod           like datrservapol.succod,
    ramcod           like datrservapol.ramcod,
    aplnumdig        like datrservapol.aplnumdig,
    itmnumdig        like datrservapol.itmnumdig,
    atdfnlflg        like datmservico.atdfnlflg,
    abater_cota      char (1),
    atdsrvnum        like datmservico.atdsrvnum,
    atdsrvano        like datmservico.atdsrvano,
    socntzgrpcod     like datksocntz.socntzgrpcod,
    regsocntzcod      like datmsrvre.socntzcod,
    regsocntzgrpcod   like datksocntz.socntzgrpcod
 end record

 define lret              integer
 define w_hora_cotac      char(10)
 define w_etapa           like datmsrvacp.atdetpcod
 define l_retorno         smallint     #AS 10/11
 define l_mensagem        smallint     #AS 10/11



 define lr_endereco  record
        lclidttxt    like datmlcl.lclidttxt,
        lgdtip       like datmlcl.lgdtip,
        lgdnom       like datmlcl.lgdnom,
        lgdnum       like datmlcl.lgdnum,
        lclbrrnom    like datmlcl.lclbrrnom,
        brrnom       like datmlcl.brrnom,
        cidnom       like datmlcl.cidnom,
        ufdcod       like datmlcl.ufdcod,
        lclrefptotxt like datmlcl.lclrefptotxt,
        endzon       like datmlcl.endzon,
        lgdcep       like datmlcl.lgdcep,
        lgdcepcmp    like datmlcl.lgdcepcmp,
        dddcod       like datmlcl.dddcod,
        lcltelnum    like datmlcl.lcltelnum,
        lclcttnom    like datmlcl.lclcttnom,
        c24lclpdrcod like datmlcl.c24lclpdrcod,
        sqlcode      integer,
        endcmp       like datmlcl.endcmp
 end record

 define lr_outro_end record
        lclidttxt    like datmlcl.lclidttxt,
        lgdtip       like datmlcl.lgdtip,
        lgdnom       like datmlcl.lgdnom,
        lgdnum       like datmlcl.lgdnum,
        lclbrrnom    like datmlcl.lclbrrnom,
        brrnom       like datmlcl.brrnom,
        cidnom       like datmlcl.cidnom,
        ufdcod       like datmlcl.ufdcod,
        lclrefptotxt like datmlcl.lclrefptotxt,
        endzon       like datmlcl.endzon,
        lgdcep       like datmlcl.lgdcep,
        lgdcepcmp    like datmlcl.lgdcepcmp,
        dddcod       like datmlcl.dddcod,
        lcltelnum    like datmlcl.lcltelnum,
        lclcttnom    like datmlcl.lclcttnom,
        c24lclpdrcod like datmlcl.c24lclpdrcod,
        sqlcode      integer,
        endcmp       like datmlcl.endcmp
 end record
  

        let     lret  =  null
        let     w_hora_cotac  =  null

        initialize  rgl_cts00m02.*  to  null

        initialize  ws.*  to  null

 initialize ws.* to null
 initialize rgl_cts00m02.* to null

 initialize lr_endereco.*  to null
 initialize lr_outro_end.* to null
 



 ## Busca informacoes do servico

 #local
 select cidnom, ufdcod
        into rgl_cts00m02.cidnom, rgl_cts00m02.ufdcod
   from datmlcl
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano
    and c24endtip = 1

 #origem / data
 select atdsrvorg,
        atddat,
        atdhor,
        atddatprg,
        atdhorprg
        into rgl_cts00m02.atdsrvorg,
             ws.atddat,
             ws.atdhor,
             ws.atddatprg,
             ws.atdhorprg
   from datmservico
  where atdsrvnum = param.atdsrvnum
    and atdsrvano = param.atdsrvano

 if ws.atddatprg is not null  then
    let rgl_cts00m02.rgldat = ws.atddatprg
    let rgl_cts00m02.rglhor = ws.atdhorprg
 else
    let rgl_cts00m02.rgldat = ws.atddat
    let rgl_cts00m02.rglhor = ws.atdhor

    let w_hora_cotac = rgl_cts00m02.rglhor
    let w_hora_cotac = w_hora_cotac[1,2], ":00"
    let rgl_cts00m02.rglhor = w_hora_cotac

 end if

 #tipo de servico
 if rgl_cts00m02.atdsrvorg = 9 then
    select socntzcod
           into rgl_cts00m02.srvrglcod
      from datmsrvre
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano

    let ws.srvrglcod  = ''
    select socntzgrpcod into ws.srvrglcod
           from datksocntz
           where socntzcod = rgl_cts00m02.srvrglcod
 else
    select asitipcod
           into rgl_cts00m02.srvrglcod
      from datmservico
     where atdsrvnum = param.atdsrvnum
       and atdsrvano = param.atdsrvano
 end if


 ## Obter o endereco de ocorrencia do servico
 call ctx04g00_local_completo(param.atdsrvnum,
                              param.atdsrvano,
                              1)
      returning lr_endereco.*

 let ws.succod = null
 let ws.ramcod = null
 let ws.aplnumdig = null
 let ws.itmnumdig = null

 select succod, ramcod, aplnumdig, itmnumdig
    into ws.succod, ws.ramcod, ws.aplnumdig, ws.itmnumdig
    from datrservapol
   where atdsrvnum = param.atdsrvnum
     and atdsrvano = param.atdsrvano

 declare cursor1 cursor for
 select atdlibdat, atdlibhor, atddatprg, atdhorprg,
        datmservico.atdsrvnum, datmservico.atdsrvano, socntzcod
        from datrservapol, datmservico, datmsrvre
      where datrservapol.ramcod     =  ws.ramcod
        and datrservapol.succod     =  ws.succod
        and datrservapol.aplnumdig  =  ws.aplnumdig
        and datrservapol.itmnumdig  =  ws.itmnumdig
        and datmservico.atdsrvnum   =  datrservapol.atdsrvnum
        and datmservico.atdsrvano   =  datrservapol.atdsrvano
        and datmsrvre.atdsrvnum   =  datrservapol.atdsrvnum
        and datmsrvre.atdsrvano   =  datrservapol.atdsrvano
        and atdsrvorg = rgl_cts00m02.atdsrvorg

 let ws.atdlibdat = null
 let ws.atdlibhor = null
 let ws.atddatprg = null
 let ws.atdhorprg = null
 let ws.atdsrvnum = null
 let ws.atdsrvano = null
 let ws.atdfnlflg = null
 let ws.abater_cota = "S"

 foreach cursor1 into ws.atdlibdat, ws.atdlibhor, ws.atddatprg, ws.atdhorprg,
                      ws.atdsrvnum, ws.atdsrvano, ws.regsocntzcod

         if param.atdsrvnum  = ws.atdsrvnum and
            param.atdsrvano = ws.atdsrvano  then
            continue foreach
         end if

         let ws.regsocntzgrpcod = ''
         select socntzgrpcod into ws.regsocntzgrpcod
                from datksocntz
                where socntzcod = ws.regsocntzcod

         ## se os servicos forem da linha branca ou plano basico
         if ws.srvrglcod <> ws.regsocntzgrpcod then
            continue foreach
         end if

         let w_etapa = null
         call cts10g04_ultima_etapa (ws.atdsrvnum, ws.atdsrvano)
              returning w_etapa

         # se estiver cancelado
         if w_etapa = 5 then
            continue foreach
         end if

         ##se tiver algum servico na mesma data/hora da cota
         ##nao abater cota

         let w_hora_cotac = ws.atdlibhor
         let w_hora_cotac = w_hora_cotac[1,2], ":00"
         let ws.atdlibhor = w_hora_cotac

         #if (ws.atddatprg is not null and
         #    ws.atddatprg = rgl_cts00m02.rgldat and
         #    ws.atdhorprg = rgl_cts00m02.rglhor) or
         #   (ws.atddatprg is null and
         #    ws.atdlibdat = rgl_cts00m02.rgldat and
         #    ws.atdlibhor = rgl_cts00m02.rglhor) then
         #    display "ws.atddatprg       : ",ws.atddatprg       
         #    display "rgl_cts00m02.rgldat: ",rgl_cts00m02.rgldat
         #    display "ws.atdhorprg       : ",ws.atdhorprg       
         #    display "rgl_cts00m02.rglhor: ",rgl_cts00m02.rglhor
         #    display "ws.atdlibdat       : ",ws.atdlibdat       
         #    display "ws.atdlibhor       : ",ws.atdlibhor       
         #    display "ws.atdsrvnum       : ",ws.atdsrvnum
         #    display "ws.atdsrvano       : ",ws.atdsrvano
         #   let ws.abater_cota = "N"
         #end if

        ## Obter o endereco de ocorrencia do outro servico
        call ctx04g00_local_completo(ws.atdsrvnum, ws.atdsrvano, 1)
                 returning lr_outro_end.*

        if lr_endereco.lgdnom <> lr_outro_end.lgdnom or
           lr_endereco.lgdnum <> lr_outro_end.lgdnum or
           lr_endereco.brrnom <> lr_outro_end.brrnom or
           lr_endereco.cidnom <> lr_outro_end.cidnom or
           lr_endereco.ufdcod <> lr_outro_end.ufdcod or
           lr_endereco.lgdcep <> lr_outro_end.lgdcep then
           let ws.abater_cota = "S"
           exit foreach
        end if

 end foreach

 if ws.abater_cota = "N" then
    return 0
 end if
 
 # Calcula hora cheia
 #let ws.horstr = rgl_cts00m02.rglhor[1,2], ":00"
 #let ws.hora   = ws.horstr
 
 #Calcula hora quebrada
 let  ws.horstr   = rgl_cts00m02.rglhor[4,5]
 
 if ws.horstr >= 30 and ws.horstr > 0 then
    let ws.horstr = rgl_cts00m02.rglhor[1,2], ":30"    
 else
    let ws.horstr = rgl_cts00m02.rglhor[1,2]
    let ws.horstr = ws.horstr[1,2],":00"
 end if

 let ws.hora   = ws.horstr

 # Verifica se a cidade esta cadastrada
 declare c_glakcid cursor for
    select cidcod
      from glakcid
     where cidnom = rgl_cts00m02.cidnom
       and ufdcod = rgl_cts00m02.ufdcod

 open  c_glakcid
 fetch c_glakcid  into  ws.cidcod

 # Verifica se a cidade e atendida por uma cidade sede
 #Priscila - AS - 10/11/06
 #select cidsedcod
 #       into ws.cidsedcod
 #  from datrcidsed
 # where cidcod = ws.cidcod
 #if sqlca.sqlcode <> 0 then
 #   let ws.cidsedcod = ws.cidcod
 #end if
 call ctd01g00_obter_cidsedcod(1, ws.cidcod)
      returning l_retorno, l_mensagem, ws.cidsedcod
 

 # Se RE Busca grupo de natureza
 let ws.srvrglcod = rgl_cts00m02.srvrglcod
 if rgl_cts00m02.atdsrvorg = 9 then
    select socntzgrpcod
           into ws.srvrglcod
      from datksocntz
     where socntzcod = rgl_cts00m02.srvrglcod
    if sqlca.sqlcode <> 0 then
       let ws.srvrglcod = rgl_cts00m02.srvrglcod
    end if
 end if

 whenever error continue
 set lock mode to not wait

 let ws.cont = 1
 while true
    let ws.cont = ws.cont + 1

    # Busca registro do regulador
    select utlqtd
           into ws.utlqtd
      from datmsrvrgl
     where cidcod = ws.cidsedcod
       and rgldat = rgl_cts00m02.rgldat
       and rglhor = ws.hora
       and atdsrvorg = rgl_cts00m02.atdsrvorg
       and srvrglcod = ws.srvrglcod

    ## se qtd utilizada esta zerada, nao abater mais cota para nao ficar < 0
    ## nos casos que nao houve a reserva e o cadastro da cota foi feito depois
    if ws.utlqtd = 0 then
       exit while
    end if

    if sqlca.sqlcode = 0 then
       let ws.cont = 1
       while true
          let ws.cont = ws.cont + 1

          update datmsrvrgl
             set utlqtd = utlqtd - 1
           where cidcod = ws.cidsedcod
             and rgldat = rgl_cts00m02.rgldat
             and rglhor = ws.hora
             and atdsrvorg = rgl_cts00m02.atdsrvorg
             and srvrglcod = ws.srvrglcod

          if  sqlca.sqlcode = -243 or
              sqlca.sqlcode = -245 or
              sqlca.sqlcode = -246 then
              if  ws.cont < 11  then
                  sleep 1
                  continue while
              else
                if g_origem <> "WEB" then
                  Error " Selecao do Regulador do servico travado!"
                end if
              end if
          end if
          exit while
       end while
    else
       if  sqlca.sqlcode = -243 or
           sqlca.sqlcode = -245 or
           sqlca.sqlcode = -246 then
           if  ws.cont < 11  then
               sleep 1
               continue while
           else
                if g_origem <> "WEB" then
                  Error " Selecao do Regulador do servico travado!"
                end if
           end if
       end if
    end if
    exit while
 end while

 set lock mode to wait
 whenever error stop

 let lret = sqlca.sqlcode

 return lret
end function  # ctc59m03_regulador


#--------------------------------------------------------------
 function ctc59m03_reserva(p_ctc59m03)
#--------------------------------------------------------------
 define p_ctc59m03   record
    cidnom           like glakcid.cidnom,
    ufdcod           like glakcid.ufdcod,
    atdsrvorg        like datmsrvrgl.atdsrvorg,
    srvrglcod        like datmsrvrgl.srvrglcod,
    rgldat           like datmsrvrgl.rgldat,
    rglhor           char(5)
 end record

 define ws record
    cotqtd           like datmsrvrgl.cotqtd,
    utlqtd           like datmsrvrgl.utlqtd,
    cont             smallint,
    srvrglcod        like datmsrvrgl.srvrglcod,
    cidcod           like glakcid.cidcod,
    cidsedcod        like glakcid.cidcod,
    horstr           char(5),
    hora             like datmsrvrgl.rglhor,
    socntrzgrpcod    like datksocntzgrp.socntzgrpcod
 end record

 define l_ret smallint       #AS 10/11
 define l_mensagem smallint  #AS 10/11

 initialize ws.* to null

 call cty10g00_obter_cidcod(p_ctc59m03.cidnom, p_ctc59m03.ufdcod)
      returning l_ret, l_mensagem, ws.cidcod

 call ctd01g00_obter_cidsedcod(1, ws.cidcod)
      returning l_ret, l_mensagem, ws.cidsedcod

 # Se RE Busca grupo de natureza
 let ws.srvrglcod = p_ctc59m03.srvrglcod
 if p_ctc59m03.atdsrvorg = 9 and 
    g_origem <> "WEB"        then
    select socntzgrpcod
           into ws.srvrglcod
      from datksocntz
     where socntzcod = p_ctc59m03.srvrglcod
    if sqlca.sqlcode <> 0 then
       let ws.srvrglcod = p_ctc59m03.srvrglcod
    end if
 end if

 # Calcula hora cheia
 let ws.horstr = p_ctc59m03.rglhor[1,2], ":00"
 let ws.hora   = ws.horstr

 whenever error continue
 set lock mode to not wait

 let ws.cont = 1
 while true
    let ws.cont = ws.cont + 1

    # Busca registro do regulador
    select utlqtd           
      into ws.utlqtd   
      from datmsrvrgl       
     where cidcod = ws.cidsedcod
       and rgldat = p_ctc59m03.rgldat
       and rglhor = ws.hora 
       and atdsrvorg = p_ctc59m03.atdsrvorg
       and srvrglcod = ws.srvrglcod
       and cotqtd > utlqtd  

    if sqlca.sqlcode = 0 then
       let ws.cont = 1
       while true
          let ws.cont = ws.cont + 1

          update datmsrvrgl
             set utlqtd = utlqtd + 1
           where cidcod = ws.cidsedcod
             and rgldat = p_ctc59m03.rgldat
             and rglhor = ws.hora
             and atdsrvorg = p_ctc59m03.atdsrvorg
             and srvrglcod = ws.srvrglcod
             and cotqtd > utlqtd

          if  sqlca.sqlcode = -243 or
              sqlca.sqlcode = -245 or
              sqlca.sqlcode = -246 then
              if  ws.cont < 11  then
                  sleep 1
                  continue while
              else
                if g_origem <> "WEB" then
                  Error " Selecao do Regulador do servico travado!"
                end if
              end if
          end if
          exit while
       end while
    else
       if  sqlca.sqlcode = -243 or
           sqlca.sqlcode = -245 or
           sqlca.sqlcode = -246 then
           if  ws.cont < 11  then
               sleep 1
               continue while
           else
                if g_origem <> "WEB" then
                  Error " Selecao do Regulador do servico travado!"
                end if
           end if
       end if
    end if
    exit while
 end while

 if sqlca.sqlerrd[3] = 0 then
    let l_ret = 100
 else
    let l_ret = sqlca.sqlcode
 end if

 set lock mode to wait
 whenever error stop

 return l_ret

end function  #  ctc59m03_reserva
