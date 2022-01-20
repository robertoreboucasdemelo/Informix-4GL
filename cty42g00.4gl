#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty42g00                                                    #
# Objetivo.......: Modulo de Contigencia Online                                #
# Analista Resp. : Humberto Benedito                                           #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 01/05/2015                                                  #
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"
#globals "/projetos/fornax/D0609511/central/contigencia/glct.4gl"

database porto

define mr_param record
	ciaempcod  like datmcntsrv.ciaempcod ,
	succod     like datmcntsrv.succod    ,
	ramcod     like datmcntsrv.ramcod    ,
	aplnumdig  like datmcntsrv.aplnumdig ,
	itmnumdig  like datmcntsrv.itmnumdig ,
	cgccpfnum  like datmcntsrv.cpfnum    ,
	cgcord     like datmcntsrv.cgcord    ,
	cpfdig     like datmcntsrv.cpfdig    ,
	vcllicnum  like datmcntsrv.vcllicnum
end record

define m_prepare smallint

#----------------------------------------------#
 function cty42g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = ' select count(*)         '
          ,   ' from datmcntsrv         '
          ,   ' where prcflg     = "N"  '
          ,   ' and   ciaempcod  = ?    '
          ,   ' and   succod     = ?    '
          ,   ' and   ramcod     = ?    '
          ,   ' and   aplnumdig  = ?    '
          ,   ' and   itmnumdig  = ?    '
  prepare pcty42g00001 from l_sql
  declare ccty42g00001 cursor for pcty42g00001

  let l_sql = ' select count(*)         '
          ,   ' from datmcntsrv         '
          ,   ' where prcflg   = "N"    '
          ,   ' and   ciaempcod  = ?    '
          ,   ' and   vcllicnum  = ?    '
  prepare pcty42g00002 from l_sql
  declare ccty42g00002 cursor for pcty42g00002

  let l_sql = ' select count(*)         '
          ,   ' from datmcntsrv         '
          ,   ' where prcflg     = "N"  '
          ,   ' and   ciaempcod  = ?    '
          ,   ' and   cpfnum     = ?    '
          ,   ' and   cgcord     = ?    '
          ,   ' and   cpfdig     = ?    '
  prepare pcty42g00003 from l_sql
  declare ccty42g00003 cursor for pcty42g00003

  let l_sql = ' select cpodes                  '
           ,  ' from datkdominio               '
           ,  ' where cponom = ?               '
           ,  ' and   cpocod = ?               '
  prepare pcty42g00004 from l_sql
  declare ccty42g00004 cursor for pcty42g00004

  let l_sql = ' update datkdominio     '
           ,  ' set   cpodes = ?       '
           ,  ' where cponom = ?       '
           ,  ' and   cpocod = ?       '
  prepare pcty42g00005 from l_sql

  let l_sql = ' select count(*)         '
          ,   ' from datmcntsrv         '
          ,   ' where prcflg  = "S"     '
          ,   ' and   seqreg  = ?       '
  prepare pcty42g00006 from l_sql
  declare ccty42g00006 cursor for pcty42g00006

  let m_prepare = true

end function

#----------------------------------------------#
 function cty42g00(lr_param)
#----------------------------------------------#

define lr_param record
	ciaempcod  like datmcntsrv.ciaempcod ,
	succod     like datmcntsrv.succod    ,
	ramcod     like datmcntsrv.ramcod    ,
	aplnumdig  like datmcntsrv.aplnumdig ,
	itmnumdig  like datmcntsrv.itmnumdig ,
	cgccpfnum  like datmcntsrv.cpfnum    ,
	cgcord     like datmcntsrv.cgcord    ,
	cpfdig     like datmcntsrv.cpfdig    ,
	vcllicnum  like datmcntsrv.vcllicnum
end record

define lr_retorno record
    qtd integer
end record

initialize lr_retorno.*, g_contigencia.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty42g00_prepare()
    end if

    let mr_param.ciaempcod  = lr_param.ciaempcod
    let mr_param.succod     = lr_param.succod
    let mr_param.ramcod     = lr_param.ramcod
    let mr_param.aplnumdig  = lr_param.aplnumdig
    let mr_param.itmnumdig  = lr_param.itmnumdig
    let mr_param.cgccpfnum  = lr_param.cgccpfnum
    let mr_param.cgcord     = lr_param.cgcord
    let mr_param.cpfdig     = lr_param.cpfdig
    let mr_param.vcllicnum  = lr_param.vcllicnum

    #--------------------------------------------------------
    # Valida Permissao para Acessar Automaticamente
    #--------------------------------------------------------
    if not cty42g00_acessa() then
       return
    end if

    #--------------------------------------------------------
    # Verifica Por Placa
    #--------------------------------------------------------

    if cty42g00_verifica_placa(mr_param.ciaempcod,
    	                         mr_param.vcllicnum) then

    	  #--------------------------------------------------------
    	  # Carrega Globais por Placa
        #--------------------------------------------------------
        call cty42g00_carrega_placa()

        #--------------------------------------------------------
        # Chama Processo de Contigencia
        #--------------------------------------------------------
        call cts35m00()

        return

  	end if

    #--------------------------------------------------------
    # Verifica por CGC/CPF
    #--------------------------------------------------------

    if cty42g00_verifica_cpf(mr_param.ciaempcod ,
    	                       mr_param.cgccpfnum ,
    	                       mr_param.cgcord    ,
    	                       mr_param.cpfdig    ) then

       #--------------------------------------------------------
       # Carrega Globais por CGC/CPF
       #--------------------------------------------------------
       call cty42g00_carrega_cpf()


       #--------------------------------------------------------
       # Chama Processo de Contigencia
       #--------------------------------------------------------
       call cts35m00()

       return

    end if

    #--------------------------------------------------------
    # Verifica por Apolice
    #--------------------------------------------------------

    if cty42g00_verifica_apolice(mr_param.ciaempcod ,
    	                           mr_param.succod    ,
    	                           mr_param.ramcod    ,
    	                           mr_param.aplnumdig ,
    	                           mr_param.itmnumdig ) then

        #--------------------------------------------------------
        # Carrega Globais por Apolice
        #--------------------------------------------------------
        call cty42g00_carrega_apolice()


        #--------------------------------------------------------
        # Chama Processo de Contigencia
        #--------------------------------------------------------
        call cts35m00()

        return

  	end if



end function

#----------------------------------------------#
 function cty42g00_verifica_apolice(lr_param)
#----------------------------------------------#

define lr_param record
	ciaempcod  like datmcntsrv.ciaempcod ,
	succod     like datmcntsrv.succod    ,
	ramcod     like datmcntsrv.ramcod    ,
	aplnumdig  like datmcntsrv.aplnumdig ,
	itmnumdig  like datmcntsrv.itmnumdig
end record

define lr_retorno record
  cont smallint
end record


initialize lr_retorno.* to null

    if lr_param.itmnumdig is null then
       let lr_param.itmnumdig = 0
    end if

    if lr_param.ciaempcod is not null and
       lr_param.succod    is not null and
       lr_param.ramcod    is not null and
       lr_param.aplnumdig is not null and
       lr_param.itmnumdig is not null then

       #--------------------------------------------------------
       # Verifica por Apolice
       #--------------------------------------------------------

       open ccty42g00001 using  lr_param.ciaempcod ,
                                lr_param.succod    ,
                                lr_param.ramcod    ,
                                lr_param.aplnumdig ,
                                lr_param.itmnumdig

       whenever error continue
       fetch ccty42g00001 into lr_retorno.cont
       whenever error stop

       if lr_retorno.cont > 0 then
       	 return true
       end if

    end if

    return false


end function

#----------------------------------------------#
 function cty42g00_verifica_placa(lr_param)
#----------------------------------------------#

define lr_param record
	ciaempcod  like datmcntsrv.ciaempcod ,
	vcllicnum  like datmcntsrv.vcllicnum
end record

define lr_retorno record
  cont smallint
end record


initialize lr_retorno.* to null

    if lr_param.ciaempcod is not null and
    	 lr_param.vcllicnum is not null then

       #--------------------------------------------------------
       # Verifica Por Placa
       #--------------------------------------------------------

       open ccty42g00002 using lr_param.ciaempcod,
                               lr_param.vcllicnum
       whenever error continue
       fetch ccty42g00002 into lr_retorno.cont
       whenever error stop

       if lr_retorno.cont > 0 then
       	 return true
       end if

    end if

    return false


end function

#----------------------------------------------#
 function cty42g00_verifica_cpf(lr_param)
#----------------------------------------------#

define lr_param record
	ciaempcod  like datmcntsrv.ciaempcod ,
	cgccpfnum  like datmcntsrv.cpfnum    ,
	cgcord     like datmcntsrv.cgcord    ,
	cpfdig     like datmcntsrv.cpfdig
end record

define lr_retorno record
  cont smallint
end record


initialize lr_retorno.* to null


    if lr_param.ciaempcod is not null and
       lr_param.cgccpfnum is not null and
       lr_param.cgcord    is not null and
       lr_param.cpfdig    is not null then

       #--------------------------------------------------------
       # Verifica por CGC/CPF
       #--------------------------------------------------------

       open ccty42g00003 using  lr_param.ciaempcod ,
                                lr_param.cgccpfnum ,
                                lr_param.cgcord    ,
                                lr_param.cpfdig

       whenever error continue
       fetch ccty42g00003 into lr_retorno.cont
       whenever error stop

       if lr_retorno.cont > 0 then
       	 return true
       end if

    end if

    return false


end function

#----------------------------------------------#
 function cty42g00_prepara(lr_param)
#----------------------------------------------#

define lr_param record
	versao integer
end record

define lr_retorno record
	cmd char(5000)
end record

initialize lr_retorno.* to null

	 case g_contigencia.tipo
	 	 when 1
	 	    let lr_retorno.cmd = cty42g00_online_placa(lr_param.versao)
	 	 when 2
	 	    let lr_retorno.cmd = cty42g00_online_cgc_cpf(lr_param.versao)
	 	 when 3
	 	    let lr_retorno.cmd = cty42g00_online_apolice(lr_param.versao)
	 end case

	 return lr_retorno.cmd

end function

#----------------------------------------------#
 function cty42g00_online_placa(lr_param)
#----------------------------------------------#

define lr_param record
	versao integer
end record

define lr_retorno record
	cmd char(5000)
end record

initialize lr_retorno.* to null

    if lr_param.versao = 0 then
     let lr_retorno.cmd = "select seqreg "
                         ," ,seqregcnt "
                         ," ,atdsrvorg "
                         ," ,atdsrvnum "
                         ," ,atdsrvano "
                         ," ,srvtipabvdes "
                         ," ,atdnom "
                         ," ,funmat "
                         ," ,asitipabvdes "
                         ," ,c24solnom "
                         ," ,vcldes "
                         ," ,vclanomdl "
                         ," ,vclcor "
                         ," ,vcllicnum "
                         ," ,vclcamtip "
                         ," ,vclcrgflg "
                         ," ,vclcrgpso "
                         ," ,atddfttxt "
                         ," ,segnom "
                         ," ,aplnumdig "
                         ," ,cpfnum "
                         ," ,ocrufdcod "
                         ," ,ocrcidnom "
                         ," ,ocrbrrnom "
                         ," ,ocrlgdnom "
                         ," ,ocrendcmp "
                         ," ,ocrlclcttnom "
                         ," ,ocrlcltelnum "
                         ," ,ocrlclrefptotxt "
                         ," ,dsttipflg "
                         ," ,dstufdcod "
                         ," ,dstcidnom "
                         ," ,dstbrrnom "
                         ," ,dstlgdnom "
                         ," ,rmcacpflg "
                         ," ,obstxt "
                         ," ,srrcoddig "
                         ," ,srrabvnom "
                         ," ,atdvclsgl "
                         ," ,atdprscod "
                         ," ,nomgrr "
                         ," ,atddat "
                         ," ,atdhor "
                         ," ,acndat "
                         ," ,acnhor "
                         ," ,acnprv "
                         ," ,c24openom "
                         ," ,c24opemat "
                         ," ,pasnom1 "
                         ," ,pasida1 "
                         ," ,pasnom2 "
                         ," ,pasida2 "
                         ," ,pasnom3 "
                         ," ,pasida3 "
                         ," ,pasnom4 "
                         ," ,pasida4 "
                         ," ,pasnom5 "
                         ," ,pasida5 "
                         ," ,atldat "
                         ," ,atlhor "
                         ," ,atlmat "
                         ," ,atlnom "
                         ," ,cnlflg "
                         ," ,cnldat "
                         ," ,cnlhor "
                         ," ,cnlmat "
                         ," ,cnlnom "
                         ," ,socntzcod "
                         ," ,c24astcod "
                         ," ,atdorgsrvnum "
                         ," ,atdorgsrvano "
                         ," ,srvtip "
                         ," ,acnifmflg "
                         ," ,dstsrvnum "
                         ," ,dstsrvano "
                         ," ,prcflg "
                         ," ,ramcod "
                         ," ,succod "
                         ," ,itmnumdig "
                         ," ,ocrlcldddcod "
                         ," ,cpfdig "
                         ," ,cgcord "
                         ," ,ocrendzoncod "
                         ," ,dstendzoncod "
                         ," ,sindat       "
                         ," ,sinhor       "
                         ," ,bocnum       "
                         ," ,boclcldes    "
                         ," ,sinavstip    "
                         ," ,vclchscod    "
                         ," ,obscmptxt    "
                         ," ,crtsaunum    "
                         ," ,ciaempcod    "
                         ," ,atdnum       "
                         ,"  from datmcntsrv   "
                         ,"  where prcflg = 'N' "
                         ,"  and   vcllicnum  = '", g_contigencia.vcllicnum clipped, "'"
                         ,"  order by atdprscod, seqreg "
  else
       let lr_retorno.cmd = "select seqreg "
                           ," ,seqregcnt "
                           ," ,atdsrvorg "
                           ," ,atdsrvnum "
                           ," ,atdsrvano "
                           ," ,srvtipabvdes "
                           ," ,atdnom "
                           ," ,funmat "
                           ," ,asitipabvdes "
                           ," ,c24solnom "
                           ," ,vcldes "
                           ," ,vclanomdl "
                           ," ,vclcor "
                           ," ,vcllicnum "
                           ," ,vclcamtip "
                           ," ,vclcrgflg "
                           ," ,vclcrgpso "
                           ," ,atddfttxt "
                           ," ,segnom "
                           ," ,aplnumdig "
                           ," ,cpfnum "
                           ," ,ocrufdcod "
                           ," ,ocrcidnom "
                           ," ,ocrbrrnom "
                           ," ,ocrlgdnom "
                           ," ,ocrendcmp "
                           ," ,ocrlclcttnom "
                           ," ,ocrlcltelnum "
                           ," ,ocrlclrefptotxt "
                           ," ,dsttipflg "
                           ," ,dstufdcod "
                           ," ,dstcidnom "
                           ," ,dstbrrnom "
                           ," ,dstlgdnom "
                           ," ,rmcacpflg "
                           ," ,obstxt "
                           ," ,srrcoddig "
                           ," ,srrabvnom "
                           ," ,atdvclsgl "
                           ," ,atdprscod "
                           ," ,nomgrr "
                           ," ,atddat "
                           ," ,atdhor "
                           ," ,acndat "
                           ," ,acnhor "
                           ," ,acnprv "
                           ," ,c24openom "
                           ," ,c24opemat "
                           ," ,pasnom1 "
                           ," ,pasida1 "
                           ," ,pasnom2 "
                           ," ,pasida2 "
                           ," ,pasnom3 "
                           ," ,pasida3 "
                           ," ,pasnom4 "
                           ," ,pasida4 "
                           ," ,pasnom5 "
                           ," ,pasida5 "
                           ," ,atldat "
                           ," ,atlhor "
                           ," ,atlmat "
                           ," ,atlnom "
                           ," ,cnlflg "
                           ," ,cnldat "
                           ," ,cnlhor "
                           ," ,cnlmat "
                           ," ,cnlnom "
                           ," ,socntzcod "
                           ," ,c24astcod "
                           ," ,atdorgsrvnum "
                           ," ,atdorgsrvano "
                           ," ,srvtip "
                           ," ,acnifmflg "
                           ," ,dstsrvnum "
                           ," ,dstsrvano "
                           ," ,prcflg "
                           ," ,ramcod "
                           ," ,succod "
                           ," ,itmnumdig "
                           ," ,ocrlcldddcod "
                           ," ,cpfdig "
                           ," ,cgcord "
                           ," ,ocrendzoncod "
                           ," ,dstendzoncod "
                           ," ,sindat       "
                           ," ,sinhor       "
                           ," ,bocnum       "
                           ," ,boclcldes    "
                           ," ,sinavstip    "
                           ," ,vclchscod    "
                           ," ,obscmptxt    "
                           ," ,crtsaunum    "
                           ," ,ciaempcod    "
                           ," ,atdnum       "
                           ," ,ocrlcllttnum "
                           ," ,ocrlcllgnnum "
                           ," ,ocrlclidxtipcod "
                           ," ,dstlcllttnum "
                           ," ,dstlcllgnnum "
                           ," ,dstlclidxtipcod "
                           ," ,vclmoddigcod "
                           ," ,empcod "
                           ," ,h24ctloprempcod "
                           ," ,usrtipcod "
                           ,"  from datmcntsrv "
                           ,"  where prcflg = 'N' "
                           ,"  and   vcllicnum  = '", g_contigencia.vcllicnum clipped, "'"
                           ,"  order by atdprscod, seqreg "

  end if

  return lr_retorno.cmd

end function

#----------------------------------------------#
 function cty42g00_online_cgc_cpf(lr_param)
#----------------------------------------------#

define lr_param record
	versao integer
end record

define lr_retorno record
	cmd char(5000)
end record

initialize lr_retorno.* to null

    if lr_param.versao = 0 then
     let lr_retorno.cmd = "select seqreg "
                         ," ,seqregcnt "
                         ," ,atdsrvorg "
                         ," ,atdsrvnum "
                         ," ,atdsrvano "
                         ," ,srvtipabvdes "
                         ," ,atdnom "
                         ," ,funmat "
                         ," ,asitipabvdes "
                         ," ,c24solnom "
                         ," ,vcldes "
                         ," ,vclanomdl "
                         ," ,vclcor "
                         ," ,vcllicnum "
                         ," ,vclcamtip "
                         ," ,vclcrgflg "
                         ," ,vclcrgpso "
                         ," ,atddfttxt "
                         ," ,segnom "
                         ," ,aplnumdig "
                         ," ,cpfnum "
                         ," ,ocrufdcod "
                         ," ,ocrcidnom "
                         ," ,ocrbrrnom "
                         ," ,ocrlgdnom "
                         ," ,ocrendcmp "
                         ," ,ocrlclcttnom "
                         ," ,ocrlcltelnum "
                         ," ,ocrlclrefptotxt "
                         ," ,dsttipflg "
                         ," ,dstufdcod "
                         ," ,dstcidnom "
                         ," ,dstbrrnom "
                         ," ,dstlgdnom "
                         ," ,rmcacpflg "
                         ," ,obstxt "
                         ," ,srrcoddig "
                         ," ,srrabvnom "
                         ," ,atdvclsgl "
                         ," ,atdprscod "
                         ," ,nomgrr "
                         ," ,atddat "
                         ," ,atdhor "
                         ," ,acndat "
                         ," ,acnhor "
                         ," ,acnprv "
                         ," ,c24openom "
                         ," ,c24opemat "
                         ," ,pasnom1 "
                         ," ,pasida1 "
                         ," ,pasnom2 "
                         ," ,pasida2 "
                         ," ,pasnom3 "
                         ," ,pasida3 "
                         ," ,pasnom4 "
                         ," ,pasida4 "
                         ," ,pasnom5 "
                         ," ,pasida5 "
                         ," ,atldat "
                         ," ,atlhor "
                         ," ,atlmat "
                         ," ,atlnom "
                         ," ,cnlflg "
                         ," ,cnldat "
                         ," ,cnlhor "
                         ," ,cnlmat "
                         ," ,cnlnom "
                         ," ,socntzcod "
                         ," ,c24astcod "
                         ," ,atdorgsrvnum "
                         ," ,atdorgsrvano "
                         ," ,srvtip "
                         ," ,acnifmflg "
                         ," ,dstsrvnum "
                         ," ,dstsrvano "
                         ," ,prcflg "
                         ," ,ramcod "
                         ," ,succod "
                         ," ,itmnumdig "
                         ," ,ocrlcldddcod "
                         ," ,cpfdig "
                         ," ,cgcord "
                         ," ,ocrendzoncod "
                         ," ,dstendzoncod "
                         ," ,sindat       "
                         ," ,sinhor       "
                         ," ,bocnum       "
                         ," ,boclcldes    "
                         ," ,sinavstip    "
                         ," ,vclchscod    "
                         ," ,obscmptxt    "
                         ," ,crtsaunum    "
                         ," ,ciaempcod    "
                         ," ,atdnum       "
                         ,"  from datmcntsrv   "
                         ,"  where prcflg = 'N' "
                         ,"  and   cpfnum =     ", g_contigencia.cgccpfnum
                         ,"  and   cgcord =     ", g_contigencia.cgcord
                         ,"  and   cpfdig =     ", g_contigencia.cpfdig
                         ,"  order by atdprscod, seqreg "
  else
       let lr_retorno.cmd = "select seqreg "
                           ," ,seqregcnt "
                           ," ,atdsrvorg "
                           ," ,atdsrvnum "
                           ," ,atdsrvano "
                           ," ,srvtipabvdes "
                           ," ,atdnom "
                           ," ,funmat "
                           ," ,asitipabvdes "
                           ," ,c24solnom "
                           ," ,vcldes "
                           ," ,vclanomdl "
                           ," ,vclcor "
                           ," ,vcllicnum "
                           ," ,vclcamtip "
                           ," ,vclcrgflg "
                           ," ,vclcrgpso "
                           ," ,atddfttxt "
                           ," ,segnom "
                           ," ,aplnumdig "
                           ," ,cpfnum "
                           ," ,ocrufdcod "
                           ," ,ocrcidnom "
                           ," ,ocrbrrnom "
                           ," ,ocrlgdnom "
                           ," ,ocrendcmp "
                           ," ,ocrlclcttnom "
                           ," ,ocrlcltelnum "
                           ," ,ocrlclrefptotxt "
                           ," ,dsttipflg "
                           ," ,dstufdcod "
                           ," ,dstcidnom "
                           ," ,dstbrrnom "
                           ," ,dstlgdnom "
                           ," ,rmcacpflg "
                           ," ,obstxt "
                           ," ,srrcoddig "
                           ," ,srrabvnom "
                           ," ,atdvclsgl "
                           ," ,atdprscod "
                           ," ,nomgrr "
                           ," ,atddat "
                           ," ,atdhor "
                           ," ,acndat "
                           ," ,acnhor "
                           ," ,acnprv "
                           ," ,c24openom "
                           ," ,c24opemat "
                           ," ,pasnom1 "
                           ," ,pasida1 "
                           ," ,pasnom2 "
                           ," ,pasida2 "
                           ," ,pasnom3 "
                           ," ,pasida3 "
                           ," ,pasnom4 "
                           ," ,pasida4 "
                           ," ,pasnom5 "
                           ," ,pasida5 "
                           ," ,atldat "
                           ," ,atlhor "
                           ," ,atlmat "
                           ," ,atlnom "
                           ," ,cnlflg "
                           ," ,cnldat "
                           ," ,cnlhor "
                           ," ,cnlmat "
                           ," ,cnlnom "
                           ," ,socntzcod "
                           ," ,c24astcod "
                           ," ,atdorgsrvnum "
                           ," ,atdorgsrvano "
                           ," ,srvtip "
                           ," ,acnifmflg "
                           ," ,dstsrvnum "
                           ," ,dstsrvano "
                           ," ,prcflg "
                           ," ,ramcod "
                           ," ,succod "
                           ," ,itmnumdig "
                           ," ,ocrlcldddcod "
                           ," ,cpfdig "
                           ," ,cgcord "
                           ," ,ocrendzoncod "
                           ," ,dstendzoncod "
                           ," ,sindat       "
                           ," ,sinhor       "
                           ," ,bocnum       "
                           ," ,boclcldes    "
                           ," ,sinavstip    "
                           ," ,vclchscod    "
                           ," ,obscmptxt    "
                           ," ,crtsaunum    "
                           ," ,ciaempcod    "
                           ," ,atdnum       "
                           ," ,ocrlcllttnum "
                           ," ,ocrlcllgnnum "
                           ," ,ocrlclidxtipcod "
                           ," ,dstlcllttnum "
                           ," ,dstlcllgnnum "
                           ," ,dstlclidxtipcod "
                           ," ,vclmoddigcod "
                           ," ,empcod "
                           ," ,h24ctloprempcod "
                           ," ,usrtipcod "
                           ,"  from datmcntsrv "
                           ,"  where prcflg = 'N' "
                           ,"  and   cpfnum =     ", g_contigencia.cgccpfnum
                           ,"  and   cgcord =     ", g_contigencia.cgcord
                           ,"  and   cpfdig =     ", g_contigencia.cpfdig
                           ,"  order by atdprscod, seqreg "

  end if

  return lr_retorno.cmd

end function

#----------------------------------------------#
 function cty42g00_online_apolice(lr_param)
#----------------------------------------------#

define lr_param record
	versao integer
end record

define lr_retorno record
	cmd char(5000)
end record

initialize lr_retorno.* to null

    if lr_param.versao = 0 then
     let lr_retorno.cmd = "select seqreg "
                         ," ,seqregcnt "
                         ," ,atdsrvorg "
                         ," ,atdsrvnum "
                         ," ,atdsrvano "
                         ," ,srvtipabvdes "
                         ," ,atdnom "
                         ," ,funmat "
                         ," ,asitipabvdes "
                         ," ,c24solnom "
                         ," ,vcldes "
                         ," ,vclanomdl "
                         ," ,vclcor "
                         ," ,vcllicnum "
                         ," ,vclcamtip "
                         ," ,vclcrgflg "
                         ," ,vclcrgpso "
                         ," ,atddfttxt "
                         ," ,segnom "
                         ," ,aplnumdig "
                         ," ,cpfnum "
                         ," ,ocrufdcod "
                         ," ,ocrcidnom "
                         ," ,ocrbrrnom "
                         ," ,ocrlgdnom "
                         ," ,ocrendcmp "
                         ," ,ocrlclcttnom "
                         ," ,ocrlcltelnum "
                         ," ,ocrlclrefptotxt "
                         ," ,dsttipflg "
                         ," ,dstufdcod "
                         ," ,dstcidnom "
                         ," ,dstbrrnom "
                         ," ,dstlgdnom "
                         ," ,rmcacpflg "
                         ," ,obstxt "
                         ," ,srrcoddig "
                         ," ,srrabvnom "
                         ," ,atdvclsgl "
                         ," ,atdprscod "
                         ," ,nomgrr "
                         ," ,atddat "
                         ," ,atdhor "
                         ," ,acndat "
                         ," ,acnhor "
                         ," ,acnprv "
                         ," ,c24openom "
                         ," ,c24opemat "
                         ," ,pasnom1 "
                         ," ,pasida1 "
                         ," ,pasnom2 "
                         ," ,pasida2 "
                         ," ,pasnom3 "
                         ," ,pasida3 "
                         ," ,pasnom4 "
                         ," ,pasida4 "
                         ," ,pasnom5 "
                         ," ,pasida5 "
                         ," ,atldat "
                         ," ,atlhor "
                         ," ,atlmat "
                         ," ,atlnom "
                         ," ,cnlflg "
                         ," ,cnldat "
                         ," ,cnlhor "
                         ," ,cnlmat "
                         ," ,cnlnom "
                         ," ,socntzcod "
                         ," ,c24astcod "
                         ," ,atdorgsrvnum "
                         ," ,atdorgsrvano "
                         ," ,srvtip "
                         ," ,acnifmflg "
                         ," ,dstsrvnum "
                         ," ,dstsrvano "
                         ," ,prcflg "
                         ," ,ramcod "
                         ," ,succod "
                         ," ,itmnumdig "
                         ," ,ocrlcldddcod "
                         ," ,cpfdig "
                         ," ,cgcord "
                         ," ,ocrendzoncod "
                         ," ,dstendzoncod "
                         ," ,sindat       "
                         ," ,sinhor       "
                         ," ,bocnum       "
                         ," ,boclcldes    "
                         ," ,sinavstip    "
                         ," ,vclchscod    "
                         ," ,obscmptxt    "
                         ," ,crtsaunum    "
                         ," ,ciaempcod    "
                         ," ,atdnum       "
                         ,"  from datmcntsrv   "
                         ,"  where prcflg = 'N' "
                         ,"  and   succod    =     ", g_contigencia.succod
                         ,"  and   ramcod    =     ", g_contigencia.ramcod
                         ,"  and   aplnumdig =     ", g_contigencia.aplnumdig
                         ,"  and   itmnumdig =     ", g_contigencia.itmnumdig
                         ,"  order by atdprscod, seqreg "
  else
       let lr_retorno.cmd = "select seqreg "
                           ," ,seqregcnt "
                           ," ,atdsrvorg "
                           ," ,atdsrvnum "
                           ," ,atdsrvano "
                           ," ,srvtipabvdes "
                           ," ,atdnom "
                           ," ,funmat "
                           ," ,asitipabvdes "
                           ," ,c24solnom "
                           ," ,vcldes "
                           ," ,vclanomdl "
                           ," ,vclcor "
                           ," ,vcllicnum "
                           ," ,vclcamtip "
                           ," ,vclcrgflg "
                           ," ,vclcrgpso "
                           ," ,atddfttxt "
                           ," ,segnom "
                           ," ,aplnumdig "
                           ," ,cpfnum "
                           ," ,ocrufdcod "
                           ," ,ocrcidnom "
                           ," ,ocrbrrnom "
                           ," ,ocrlgdnom "
                           ," ,ocrendcmp "
                           ," ,ocrlclcttnom "
                           ," ,ocrlcltelnum "
                           ," ,ocrlclrefptotxt "
                           ," ,dsttipflg "
                           ," ,dstufdcod "
                           ," ,dstcidnom "
                           ," ,dstbrrnom "
                           ," ,dstlgdnom "
                           ," ,rmcacpflg "
                           ," ,obstxt "
                           ," ,srrcoddig "
                           ," ,srrabvnom "
                           ," ,atdvclsgl "
                           ," ,atdprscod "
                           ," ,nomgrr "
                           ," ,atddat "
                           ," ,atdhor "
                           ," ,acndat "
                           ," ,acnhor "
                           ," ,acnprv "
                           ," ,c24openom "
                           ," ,c24opemat "
                           ," ,pasnom1 "
                           ," ,pasida1 "
                           ," ,pasnom2 "
                           ," ,pasida2 "
                           ," ,pasnom3 "
                           ," ,pasida3 "
                           ," ,pasnom4 "
                           ," ,pasida4 "
                           ," ,pasnom5 "
                           ," ,pasida5 "
                           ," ,atldat "
                           ," ,atlhor "
                           ," ,atlmat "
                           ," ,atlnom "
                           ," ,cnlflg "
                           ," ,cnldat "
                           ," ,cnlhor "
                           ," ,cnlmat "
                           ," ,cnlnom "
                           ," ,socntzcod "
                           ," ,c24astcod "
                           ," ,atdorgsrvnum "
                           ," ,atdorgsrvano "
                           ," ,srvtip "
                           ," ,acnifmflg "
                           ," ,dstsrvnum "
                           ," ,dstsrvano "
                           ," ,prcflg "
                           ," ,ramcod "
                           ," ,succod "
                           ," ,itmnumdig "
                           ," ,ocrlcldddcod "
                           ," ,cpfdig "
                           ," ,cgcord "
                           ," ,ocrendzoncod "
                           ," ,dstendzoncod "
                           ," ,sindat       "
                           ," ,sinhor       "
                           ," ,bocnum       "
                           ," ,boclcldes    "
                           ," ,sinavstip    "
                           ," ,vclchscod    "
                           ," ,obscmptxt    "
                           ," ,crtsaunum    "
                           ," ,ciaempcod    "
                           ," ,atdnum       "
                           ," ,ocrlcllttnum "
                           ," ,ocrlcllgnnum "
                           ," ,ocrlclidxtipcod "
                           ," ,dstlcllttnum "
                           ," ,dstlcllgnnum "
                           ," ,dstlclidxtipcod "
                           ," ,vclmoddigcod "
                           ," ,empcod "
                           ," ,h24ctloprempcod "
                           ," ,usrtipcod "
                           ,"  from datmcntsrv "
                           ,"  where prcflg = 'N' "
                           ,"  and   succod    =     ", g_contigencia.succod
                           ,"  and   ramcod    =     ", g_contigencia.ramcod
                           ,"  and   aplnumdig =     ", g_contigencia.aplnumdig
                           ,"  and   itmnumdig =     ", g_contigencia.itmnumdig
                           ,"  order by atdprscod, seqreg "

  end if

  return lr_retorno.cmd

end function


#----------------------------------------------#
 function cty42g00_valida()
#----------------------------------------------#


   if not g_contigencia.flag and
   	  not g_contigencia.aut  then
       return false
   end if

   return true

end function

#----------------------------------------------#
 function cty42g00_online()
#----------------------------------------------#


   if g_contigencia.flag then
       return true
   end if

   return false

end function

#----------------------------------------------#
 function cty42g00_automatico()
#----------------------------------------------#


   if g_contigencia.aut then
       return true
   end if

   return false

end function

#----------------------------------------------#
 function cty42g00_acessa()
#----------------------------------------------#

define lr_retorno record
   cpodes	 like datkdominio.cpodes ,
   cponom  like datkdominio.cponom ,
   cpocod  like datkdominio.cpocod
end record

    if m_prepare is null or
       m_prepare <> true then
       call cty42g00_prepare()
    end if

    initialize lr_retorno.* to null

    let lr_retorno.cponom = "cty42g00_flag"
    let lr_retorno.cpocod = 1

   #--------------------------------------------------------
   # Valida Se a Processa Automaticamente
   #--------------------------------------------------------

   open ccty42g00004 using lr_retorno.cponom,
                           lr_retorno.cpocod
   whenever error continue
   fetch ccty42g00004 into lr_retorno.cpodes
   whenever error stop


   if lr_retorno.cpodes = "S" then
       return true
   end if

   return false

end function

#----------------------------------------------#
 function cty42g00_carrega_placa()
#----------------------------------------------#

   let g_contigencia.flag      = true
   let g_contigencia.tipo      = 1
   let g_contigencia.vcllicnum = mr_param.vcllicnum

end function

#----------------------------------------------#
 function cty42g00_carrega_cpf()
#----------------------------------------------#

   let g_contigencia.flag      = true
   let g_contigencia.tipo      = 2
   let g_contigencia.cgccpfnum = mr_param.cgccpfnum
   let g_contigencia.cgcord    = mr_param.cgcord
   let g_contigencia.cpfdig    = mr_param.cpfdig

end function

#----------------------------------------------#
 function cty42g00_carrega_apolice()
#----------------------------------------------#

   let g_contigencia.flag       = true
   let g_contigencia.tipo       = 3
   let g_contigencia.succod     = mr_param.succod
   let g_contigencia.ramcod     = mr_param.ramcod
   let g_contigencia.aplnumdig  = mr_param.aplnumdig
   let g_contigencia.itmnumdig  = mr_param.itmnumdig


end function

#----------------------------------------------#
 function cty42g00_processando()
#----------------------------------------------#

define lr_retorno record
   cpodes	 like datkdominio.cpodes ,
   cponom  like datkdominio.cponom ,
   cpocod  like datkdominio.cpocod
end record

    if m_prepare is null or
       m_prepare <> true then
       call cty42g00_prepare()
    end if

    initialize lr_retorno.* to null

    let lr_retorno.cponom = "cty42g00_proc"
    let lr_retorno.cpocod = 1

   #--------------------------------------------------------
   # Valida Se a Processa Automaticamente
   #--------------------------------------------------------

   open ccty42g00004 using lr_retorno.cponom,
                           lr_retorno.cpocod
   whenever error continue
   fetch ccty42g00004 into lr_retorno.cpodes
   whenever error stop


   if lr_retorno.cpodes = "S" then
       return true
   end if

   return false

end function

#----------------------------------------------#
 function cty42g00_atualiza(lr_param)
#----------------------------------------------#

define lr_param record
   cpodes	 like datkdominio.cpodes
end record

define lr_retorno record
   cponom  like datkdominio.cponom ,
   cpocod  like datkdominio.cpocod
end record

    if m_prepare is null or
       m_prepare <> true then
       call cty42g00_prepare()
    end if

    initialize lr_retorno.* to null

    let lr_retorno.cponom = "cty42g00_proc"
    let lr_retorno.cpocod = 1

   #--------------------------------------------------------
   # Atualiza Processo
   #--------------------------------------------------------

   whenever error continue
   execute pcty42g00005 using lr_param.cpodes
                            , lr_retorno.cponom
                            , lr_retorno.cpocod


   whenever error continue



end function

#----------------------------------------------#
 function cty42g00_processado(lr_param)
#----------------------------------------------#

define lr_param record
	seqreg like datmcntsrv.seqreg
end record


define lr_retorno record
   cont smallint
end record

    if m_prepare is null or
       m_prepare <> true then
       call cty42g00_prepare()
    end if

    initialize lr_retorno.* to null


   #--------------------------------------------------------
   # Valida Se Ja foi Processado pelo Online
   #--------------------------------------------------------

   open ccty42g00006 using lr_param.seqreg
   whenever error continue
   fetch ccty42g00006 into lr_retorno.cont
   whenever error stop


   if lr_retorno.cont > 0 then
       return true
   end if

   return false

end function