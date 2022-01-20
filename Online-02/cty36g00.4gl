#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cty36g00                                                    #
# Objetivo.......: Tarifa de Dezembro 2013 - Controlador de Limites Clausulas  #
# Analista Resp. : Moises Gabel                                                #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: R.Fornax                                                    #
# Liberacao      : 03/04/2014                                                  #
#..............................................................................#
#..............................................................................#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_prepare smallint
define m_acesso  smallint

#----------------------------------------------#
 function cty36g00_prepare()
#----------------------------------------------#

  define l_sql char(500)

  let l_sql = ' select count(*)                '
           ,  ' from datkdominio               '
           ,  ' where cponom = ?               '
           ,  ' and   cpocod = ?               '
           ,  ' and   cpodes[01,10] <= ?       '
           ,  ' and   cpodes[12,21] >= ?       '
  prepare pcty36g00001  from l_sql
  declare ccty36g00001  cursor for pcty36g00001

  let l_sql = '  select cpocod                  '
          ,   '  from datkdominio               '
          ,   '  where cponom = ?               '
          ,   '  and   cpodes[01,10] <= ?       '
          ,   '  and   cpodes[12,21] >= ?       '
  prepare pcty36g00002 from l_sql
  declare ccty36g00002 cursor for pcty36g00002


  let l_sql = '  select cpodes[31,31],          '
           ,  '         cpodes[27,27],          '
           ,  '         cpodes[29,29],          '
           ,  '         cpodes[33,35],          '
           ,  '         cpocod                  '
           ,  '  from datkdominio               '
           ,  '  where cponom = ?               '
           ,  '  and   cpodes[01,03]  = ?       '
           ,  '  and   cpodes[05,14] <= ?       '
           ,  '  and   cpodes[16,25] >= ?       '
  prepare pcty36g00003 from l_sql
  declare ccty36g00003 cursor for pcty36g00003


  let l_sql = '  select cpodes[23,25]           '
           ,  '  from datkdominio               '
           ,  '  where cponom = ?               '
           ,  '  and   cpocod = ?               '
           ,  '  and   cpodes[01,10] <= ?       '
           ,  '  and   cpodes[12,21] >= ?       '
  prepare pcty36g00004 from l_sql
  declare ccty36g00004 cursor for pcty36g00004


  let l_sql = '  select cpodes[05,05],         '
          ,  '          cpodes[07,10]          '
          ,  '  from datkdominio               '
          ,  '  where cponom = ?               '
          ,  '  and   cpodes[01,03] = ?        '
  prepare pcty36g00005 from l_sql
  declare ccty36g00005 cursor for pcty36g00005


  let l_sql = ' select cpodes           '
          ,  '  from datkdominio        '
          ,  '  where cponom = ?        '
          ,  '  order by cpocod         '
  prepare pcty36g00006 from l_sql
  declare ccty36g00006 cursor for pcty36g00006


  let l_sql = '  select cpodes[01,01],  '
          ,  '          cpodes[03,06]   '
          ,  '  from datkdominio        '
          ,  '  where cponom = ?        '
          ,  '  and   cpocod = ?        '
  prepare pcty36g00007 from l_sql
  declare ccty36g00007 cursor for pcty36g00007

  let l_sql = 'select cpodes[23,26]           '
         ,  '  from datkdominio               '
         ,  '  where cponom = ?               '
         ,  '  and   cpocod = ?               '
         ,  '  and   cpodes[01,10] <= ?       '
         ,  '  and   cpodes[12,21] >= ?       '
  prepare pcty36g00008 from l_sql
  declare ccty36g00008 cursor for pcty36g00008


  let l_sql = '  select cpocod                 '
          ,  '  from datkdominio               '
          ,  '  where cponom = ?               '
  prepare pcty36g00009 from l_sql
  declare ccty36g00009 cursor for pcty36g00009


  let l_sql = ' select count(*)                '
           ,  ' from datkdominio               '
           ,  ' where cponom = ?               '
           ,  ' and   cpodes = ?               '
  prepare pcty36g00010 from l_sql
  declare ccty36g00010 cursor for pcty36g00010

  let l_sql = ' select count(*)                '
           ,  ' from datkdominio               '
           ,  ' where cponom = ?               '
           ,  ' and   cpocod = ?               '
  prepare pcty36g00011 from l_sql
  declare ccty36g00011 cursor for pcty36g00011

  let m_prepare = true

end function


#----------------------------------------------#
 function cty36g00_valida_natureza(lr_param)
#----------------------------------------------#

define lr_param record
	  c24astcod  like datkassunto.c24astcod,
    socntzcod  like datksocntz.socntzcod
end record

define lr_retorno record
	  chave like datkdominio.cponom	,
	  cont  integer
end record

initialize lr_retorno.* to null

if m_prepare is null or
   m_prepare <> true then
   call cty36g00_prepare()
end if
    let lr_retorno.chave = ctc53m06_monta_chave(g_nova.perfil, lr_param.c24astcod)

    #--------------------------------------------------------
    # Valida Se Pode Exibir a Natureza
    #--------------------------------------------------------

    open ccty36g00001 using lr_retorno.chave   ,
                            lr_param.socntzcod ,
                            g_nova.dt_cal      ,
                            g_nova.dt_cal

    whenever error continue
    fetch ccty36g00001 into lr_retorno.cont
    whenever error stop

    close ccty36g00001

    if  cty31g00_valida_natureza_corte2(lr_param.socntzcod) then
        if not cty31g00_nova_regra_corte2() then
        		return false
        end if
    end if

    if lr_retorno.cont >  0 then
      return true
    end if


    return false

end function

#----------------------------------------------#
 function cty36g00_valida_perfil()
#----------------------------------------------#

  if g_nova.perfil is not null then
     return true
  else
  	 return false
  end if

end function

#----------------------------------------------#
 function cty36g00_valida_clausula_fluxo1()
#----------------------------------------------#

define lr_retorno record
    cont  smallint,
    chave char(20)
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0


    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    let lr_retorno.chave = ctc53m23_monta_chave()

    #--------------------------------------------------------
    # Recupera as Clausulas do Fluxo 1
    #--------------------------------------------------------

    open ccty36g00010 using lr_retorno.chave,
                            g_nova.clscod
    whenever error continue
    fetch ccty36g00010 into lr_retorno.cont
    whenever error stop

    close ccty36g00010


   if lr_retorno.cont > 0 then
      return true
   else
   	  return false
   end if

end function

#----------------------------------------------#
 function cty36g00_valida_data()
#----------------------------------------------#

define lr_retorno  record
   data_corte date
end record

initialize lr_retorno.* to null

  let lr_retorno.data_corte = ctc53m02_recupera_data()

  if g_nova.dt_cal >= lr_retorno.data_corte then
     return true
  else
  	 return false
  end if

end function

#----------------------------------------------#
 function cty36g00_acesso_perfil(lr_param)
#----------------------------------------------#

define lr_param record
    c24astcod   like datkassunto.c24astcod
end record

    if g_nova.perfil <> 2 then
    	 return true
    else
    	 if lr_param.c24astcod = "S80" or
    	 	  lr_param.c24astcod = "SLV" or
    	 	  lr_param.c24astcod = "SLT" or 
    	 	  lr_param.c24astcod = "S40" then
    	    return true
    	 else
    	 	  return false
    	 end if
    end if

end function

#----------------------------------------------#
 function cty36g00_nova_regra_clausula(lr_param)
#----------------------------------------------#

define lr_param record
    c24astcod   like datkassunto.c24astcod
end record

  if cty36g00_valida_data()            and
  	 cty36g00_valida_perfil()          and
  	 cty36g00_valida_clausula_fluxo1() then

  	  if cty36g00_acesso_perfil(lr_param.c24astcod) then
  	  	   return true
  	  else
           return false
  	  end if

  else
      return false
  end if

end function

#----------------------------------------------#
 function cty36g00_acesso()
#----------------------------------------------#

define lr_retorno  record
   liberado char(01)
end record

initialize lr_retorno.* to null

  let lr_retorno.liberado = ctc53m02_recupera_liberacao()

  if lr_retorno.liberado = "S" then
     return true
  else
  	 return false
  end if

end function

#---------------------------------------------------#
 function cty36g00_valida_motivo_clausula(lr_param)
#---------------------------------------------------#

define lr_param record
  clscod1      like abbmclaus.clscod        ,
  clscod2      like abbmclaus.clscod        ,
  flag         char(01)                     ,
  avialgmtv    like datmavisrent.avialgmtv  ,
  c24astcod    like datkassunto.c24astcod
end record

define lr_retorno record
  atende        char(01)               ,
  motivos       char(500)              ,
  clscod        like abbmclaus.clscod  ,
  avialgmtv     integer                ,
  avialgdes     char(60)               ,
  chave         like datkdominio.cponom
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    if lr_param.flag = "N" then
    	 let lr_retorno.clscod = lr_param.clscod1
    else
       let lr_retorno.clscod = lr_param.clscod2
    end if

    if lr_param.clscod1 = "033" and

       lr_param.clscod2 = "035" then

       let lr_retorno.clscod = lr_param.clscod1

    end if

    let lr_retorno.atende = "N"

    let lr_retorno.chave = ctc53m15_monta_chave(g_nova.perfil     ,
                                                lr_param.c24astcod,
                                                lr_retorno.clscod )

    #--------------------------------------------------------
    # Monta os Motivos
    #--------------------------------------------------------

    open ccty36g00002 using lr_retorno.chave   ,
                            g_nova.dt_cal      ,
                            g_nova.dt_cal

    foreach ccty36g00002 into lr_retorno.avialgmtv


         #--------------------------------------------------------
         # Se nao Tiver a Clausula 26 Desconsidera
         #--------------------------------------------------------

         if lr_param.flag = "N"      and
         	  lr_retorno.avialgmtv = 1 then
              continue foreach
         end if

         #--------------------------------------------------------
         # Se nao Tiver Tapete Azul Desconsidera
         #--------------------------------------------------------

         if g_flag_azul <> "S"     and
         	 lr_param.avialgmtv = 20 then
            continue foreach
         end if


         #--------------------------------------------------------
         # Recupera a Descricao do Motivo
         #--------------------------------------------------------

         call ctc69m04_recupera_descricao(13,lr_retorno.avialgmtv )
         returning lr_retorno.avialgdes

         let lr_retorno.motivos = lr_retorno.motivos   clipped     ,"|",
                                  lr_retorno.avialgmtv using "<&"  ," - ",
                                  lr_retorno.avialgdes clipped

         if lr_param.avialgmtv = lr_retorno.avialgmtv then
             let lr_retorno.atende = "S"
         end if

    end foreach

    let lr_retorno.motivos = lr_retorno.motivos[02,500] clipped

    return  lr_retorno.atende  ,
            lr_retorno.motivos



end function

#----------------------------------------------#
 function cty36g00_valida_limite(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  perfil      smallint                    ,
  socntzcod   like datksocntz.socntzcod
end record

define lr_retorno record
  limite      integer                  ,
  agrega      integer                  ,
  is          char(01)                 ,
  okm         char(01)                 ,
  flag_nat    char(01)                 ,
  chave       like datkdominio.cponom  ,
  cpocod      like datkdominio.cpocod
end record

initialize lr_retorno.* to null


    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    let lr_retorno.limite = 0
    let lr_retorno.agrega = 0

    let lr_retorno.chave = ctc53m07_monta_chave(lr_param.perfil, lr_param.c24astcod)

    #--------------------------------------------------------
    # Recupera os Limites da Clausula
    #--------------------------------------------------------

    open ccty36g00003 using lr_retorno.chave   ,
                            lr_param.clscod    ,
                            g_nova.dt_cal      ,
                            g_nova.dt_cal

    whenever error continue
    fetch ccty36g00003 into lr_retorno.flag_nat,
                            lr_retorno.is      ,
                            lr_retorno.okm     ,
                            lr_retorno.limite  ,
                            lr_retorno.cpocod
    whenever error stop

    close ccty36g00003

    if lr_retorno.flag_nat = "S" then

        let lr_retorno.chave = ctc53m08_monta_chave(lr_param.perfil, lr_param.c24astcod, lr_param.clscod,lr_retorno.cpocod)

        #--------------------------------------------------------
        # Recupera os Limites da Natureza
        #--------------------------------------------------------


        open ccty36g00004 using lr_retorno.chave    ,
                                lr_param.socntzcod  ,
                                g_nova.dt_cal       ,
                                g_nova.dt_cal

        whenever error continue
        fetch ccty36g00004 into lr_retorno.limite
        whenever error stop

        close ccty36g00004

    end if

    if lr_retorno.is = "S" then

    	  #----------------------------------------------#
    	  # Verifica a Importancia Segurada
    	  #----------------------------------------------#
    	  let lr_retorno.agrega = cty31g00_agrega_alta_IS()
        let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


    end if

    if lr_retorno.okm = "S" then

    	  #----------------------------------------------#
    	  # Verifica Se o Veiculo e 0KM
    	  #----------------------------------------------#
    	  let lr_retorno.agrega = cty31g00_agrega_veiculo_0KM()
        let lr_retorno.limite = lr_retorno.limite + lr_retorno.agrega


    end if

    return  lr_retorno.limite


end function

#----------------------------------------------#
 function cty36g00_valida_km(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  perfil      smallint                    ,
  asitipcod   like datkasitip.asitipcod   ,
  asimvtcod   smallint
end record

define lr_retorno record
  limite_km    integer ,
  flag_atende  char(01),
  chave        char(20),
  limite       integer ,
  atende       char(01)
end record

initialize lr_retorno.* to null

let lr_retorno.flag_atende = "S"

    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if


    #--------------------------------------------------------
    # Recupera os Limites da Clausula
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m09_monta_chave(lr_param.perfil, lr_param.c24astcod)

    open ccty36g00005 using lr_retorno.chave    ,
                            lr_param.clscod

    whenever error continue
    fetch ccty36g00005 into lr_retorno.atende,
                            lr_retorno.limite
    whenever error stop

    close ccty36g00005

    if sqlca.sqlcode <> 0 then

      return lr_retorno.limite_km   ,
             lr_retorno.flag_atende

    end if

    #--------------------------------------------------------
    # Verifica Alerta da Clausula
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m22_monta_chave(lr_param.perfil, lr_param.c24astcod, lr_param.clscod)

    call cty36g00_recupera_alerta(lr_retorno.chave)

    let lr_retorno.limite_km   = lr_retorno.limite
    let lr_retorno.flag_atende = lr_retorno.atende

    if lr_retorno.limite_km = "N" then

       return lr_retorno.limite_km   ,
              lr_retorno.flag_atende

    end if


    #--------------------------------------------------------
    # Recupera os Limites do Tipo de Assistencia
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m10_monta_chave(lr_param.perfil, lr_param.c24astcod, lr_param.clscod)

    open ccty36g00007 using lr_retorno.chave    ,
                            lr_param.asitipcod

    whenever error continue
    fetch ccty36g00007 into lr_retorno.atende,
                            lr_retorno.limite
    whenever error stop

    close ccty36g00007

    if sqlca.sqlcode <> 0 then

      return lr_retorno.limite_km   ,
             lr_retorno.flag_atende

    end if

    #--------------------------------------------------------
    # Verifica Alerta do Tipo de Assistencia
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m12_monta_chave(lr_param.perfil    ,
                                                lr_param.c24astcod ,
                                                lr_param.clscod    ,
                                                lr_param.asitipcod)

    call cty36g00_recupera_alerta(lr_retorno.chave)

    let lr_retorno.limite_km   = lr_retorno.limite
    let lr_retorno.flag_atende = lr_retorno.atende

    if lr_retorno.limite_km = "N" then

       return lr_retorno.limite_km   ,
              lr_retorno.flag_atende

    end if


    #--------------------------------------------------------
    # Recupera os Limites do Motivo
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m11_monta_chave(lr_param.perfil   ,
                                                lr_param.c24astcod,
                                                lr_param.clscod   ,
                                                lr_param.asitipcod)

    open ccty36g00007 using lr_retorno.chave    ,
                            lr_param.asimvtcod

    whenever error continue
    fetch ccty36g00007 into lr_retorno.atende,
                            lr_retorno.limite
    whenever error stop

    close ccty36g00007

    if sqlca.sqlcode <> 0 then

      return lr_retorno.limite_km   ,
             lr_retorno.flag_atende

    end if

    #--------------------------------------------------------
    # Verifica Alerta do Motivo
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m13_monta_chave(lr_param.perfil    ,
                                                lr_param.c24astcod ,
                                                lr_param.clscod    ,
                                                lr_param.asitipcod ,
                                                lr_param.asimvtcod )

    call cty36g00_recupera_alerta(lr_retorno.chave)

    let lr_retorno.limite_km   = lr_retorno.limite
    let lr_retorno.flag_atende = lr_retorno.atende

    if lr_retorno.limite_km = "N" then

       return lr_retorno.limite_km   ,
              lr_retorno.flag_atende

    end if


    return lr_retorno.limite_km   ,
           lr_retorno.flag_atende


end function

#----------------------------------------------#
 function cty36g00_recupera_alerta(lr_param)
#----------------------------------------------#

define lr_param record
  chave        char(20)
end record

define lr_retorno record
  acesso       smallint,
  confirma     char(01),
  linha1       char(40),
  linha2       char(40),
  linha3       char(40),
  linha4       char(40)
end record

define la_cty36g00 array[04] of record
      linha char(40)
end record

define arr_aux     smallint

initialize lr_retorno.* to null

for  arr_aux  =  1  to  04
   initialize  la_cty36g00[arr_aux].* to  null
end  for

let arr_aux = 1

    #--------------------------------------------------------
    # Recupera os Dados do Alerta
    #--------------------------------------------------------


    open ccty36g00006  using  lr_param.chave
    foreach ccty36g00006 into la_cty36g00[arr_aux].linha

        let arr_aux = arr_aux + 1

    end foreach

    let lr_retorno.linha1 = la_cty36g00[1].linha
    let lr_retorno.linha2 = la_cty36g00[2].linha
    let lr_retorno.linha3 = la_cty36g00[3].linha
    let lr_retorno.linha4 = la_cty36g00[4].linha

    if lr_retorno.linha1 is not null or
       lr_retorno.linha2 is not null or
       lr_retorno.linha3 is not null or
       lr_retorno.linha4 is not null then


       call cts08g01("A","N",lr_retorno.linha1
                            ,lr_retorno.linha2
                            ,lr_retorno.linha3
                            ,lr_retorno.linha4)
       returning lr_retorno.confirma


    end if


end function

#----------------------------------------------#
 function cty36g00_valida_diaria(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  clscod      like abbmclaus.clscod       ,
  perfil      smallint                    ,
  avialgmtv   like datmavisrent.avialgmtv
end record

define lr_retorno record
  limite      integer,
  chave       char(20)
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    #--------------------------------------------------------
    # Recupera as Diarias
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m15_monta_chave(lr_param.perfil   ,
                                                lr_param.c24astcod,
                                                lr_param.clscod   )


    open ccty36g00008 using lr_retorno.chave    ,
                            lr_param.avialgmtv  ,
                            g_nova.dt_cal       ,
                            g_nova.dt_cal


    whenever error continue
    fetch ccty36g00008 into lr_retorno.limite
    whenever error stop

    close ccty36g00008

    if lr_retorno.limite is null then
    	 let lr_retorno.limite = 00
    end if

    return  lr_retorno.limite

end function

#----------------------------------------------#
 function cty36g00_valida_bloco(lr_param)
#----------------------------------------------#

define lr_param record
  c24astcod   like datkassunto.c24astcod  ,
  perfil      smallint                    ,
  socntzcod1  like datksocntz.socntzcod   ,
  socntzcod2  like datksocntz.socntzcod
end record

define lr_retorno record
  chave       char(20)  ,
  blocod      integer   ,
  cont1       integer   ,
  cont2       integer
end record

initialize lr_retorno.* to null

    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    #--------------------------------------------------------
    # Recupera os Blocos
    #--------------------------------------------------------

    let lr_retorno.chave = ctc53m27_monta_chave(lr_param.perfil   ,
                                                lr_param.c24astcod)

    open ccty36g00009 using lr_retorno.chave
    foreach ccty36g00009 into lr_retorno.blocod

    	     let lr_retorno.cont1 = 0
    	     let lr_retorno.cont2 = 0

    	     let lr_retorno.chave = ctc53m28_monta_chave(lr_param.perfil   ,
    	                                                 lr_param.c24astcod,
    	                                                 lr_retorno.blocod )

    	     #--------------------------------------------------------
    	     # Verifica a Primeira Natureza
    	     #--------------------------------------------------------

    	     open ccty36g00001 using lr_retorno.chave    ,
    	                             lr_param.socntzcod1 ,
    	                             g_nova.dt_cal       ,
    	                             g_nova.dt_cal


    	     whenever error continue
    	     fetch ccty36g00001 into lr_retorno.cont1
    	     whenever error stop

           close ccty36g00001

           #--------------------------------------------------------
           # Verifica a Segunda Natureza
           #--------------------------------------------------------

           open ccty36g00001 using lr_retorno.chave    ,
                                   lr_param.socntzcod2 ,
                                   g_nova.dt_cal       ,
                                   g_nova.dt_cal


           whenever error continue
           fetch ccty36g00001 into lr_retorno.cont2
           whenever error stop

           close ccty36g00001

           if lr_retorno.cont1 > 0 and
              lr_retorno.cont2 > 0 then
               return true
           end if


    end foreach


    return false


end function

#----------------------------------------------#
 function cty36g00_restringe_natureza(lr_param)
#----------------------------------------------#

define lr_param record
	  c24astcod  like datkassunto.c24astcod,
    socntzcod  like datksocntz.socntzcod
end record

define lr_retorno record
  chave       char(20),
  cont        smallint
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0

    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    let lr_retorno.chave = ctc53m17_monta_chave(lr_param.c24astcod)

    #--------------------------------------------------------
    # Valida Se Pode Restringir a Natureza
    #--------------------------------------------------------

    open ccty36g00001 using lr_retorno.chave   ,
                            lr_param.socntzcod ,
                            g_nova.dt_cal      ,
                            g_nova.dt_cal

    whenever error continue
    fetch ccty36g00001 into lr_retorno.cont
    whenever error stop

    close ccty36g00001

    if lr_retorno.cont >  0 then
      return true
    end if

    return false

end function

#--------------------------------------------------#
 function cty36g00_valida_clausula_fluxo2(lr_param)
#--------------------------------------------------#

define lr_param record
  clscod      like abbmclaus.clscod
end record


define lr_retorno record
    cont  smallint,
    chave char(20)
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0


    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    let lr_retorno.chave = ctc53m24_monta_chave()

    #--------------------------------------------------------
    # Recupera as Clausulas do Fluxo 2
    #--------------------------------------------------------

    open ccty36g00010 using lr_retorno.chave,
                            lr_param.clscod
    whenever error continue
    fetch ccty36g00010 into lr_retorno.cont
    whenever error stop

    close ccty36g00010


   if lr_retorno.cont > 0 then
      return true
   else
   	  return false
   end if

end function

#--------------------------------------------------#
 function cty36g00_valida_grupo_problema(lr_param)
#--------------------------------------------------#

define lr_param record
	  codper        smallint                    ,
	  c24astcod     like datkassunto.c24astcod  ,
    c24pbmgrpcod  like datkpbmgrp.c24pbmgrpcod
end record

define lr_retorno record
    cont  smallint,
    chave char(20)
end record

initialize lr_retorno.* to null

let lr_retorno.cont = 0


    if m_prepare is null or
       m_prepare <> true then
       call cty36g00_prepare()
    end if

    let lr_retorno.chave = ctc53m30_monta_chave(lr_param.codper, lr_param.c24astcod)


    #--------------------------------------------------------
    # Valida Se Pode Exibir o Problema
    #--------------------------------------------------------

    open ccty36g00011 using lr_retorno.chave      ,
                            lr_param.c24pbmgrpcod
    whenever error continue
    fetch ccty36g00011 into lr_retorno.cont
    whenever error stop

    close ccty36g00011


    if lr_retorno.cont >  0 then
      return true
    else
    	return false
    end if



end function