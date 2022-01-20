#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cts20g03                                                   #
# Analista Resp.: Ligia Mattge                                               #
# PSI           : 190772                                                     #
# Desricao      : Funcoes cts20g03_dados_ligacao, cts20g03_sit_recl          #
#                 cts20g03_recl_ligacao, cts20g03_vstsin_ligacao,            #
#                 cts20g03_sin_ligacao, cts20g03_agn_ligacao,                #
#                 cts20g03_msg_ligacao, cts20g03_avb_ligacao                 #
#............................................................................#
# Desenvolvimento: Pietro - META                                             #
# Liberacao      : 03/03/2005                                                #
#............................................................................#
#                   * * * Alteracoes * * *                                   #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 15/02/2006 Andrei, Meta      PSI196878  Incluir consistencia para nivel de #
#                                         retorno 3 em cts20g03_dados_ligacao#
#----------------------------------------------------------------------------#
# 16/03/2009 Carla Rampazzo    PSI 235580 Auto Jovem-Curso Direcao Defensiva #
#                              Selecionar e retornar o Nro.Agendamento Curso #
#----------------------------------------------------------------------------#

database porto

define m_sql smallint

#-------------------------#
function cts20g03_prepare()
#-------------------------#
define l_sql char (300)

 let l_sql = ' select ligdat '
                  ,' ,lighorinc '
                  ,' ,c24funmat '
                  ,' ,c24solnom '
                  ,' ,c24soltipcod  '
                  ,' ,c24astcod '
                  ,' ,c24paxnum '
              ,' from datmligacao '
             ,' where lignum = ? '
 prepare p_cts20g03_001 from l_sql
 declare c_cts20g03_001 cursor for p_cts20g03_001

 let l_sql = ' select max(c24rclsitcod) '
              ,' from datmsitrecl '
             ,' where lignum = ? '
 prepare p_cts20g03_002 from l_sql
 declare c_cts20g03_002 cursor for p_cts20g03_002

 let l_sql = ' select atdsrvnum '
                  ,' ,atdsrvano '
               ,'from datmreclam '
              ,'where lignum = ? '
 prepare p_cts20g03_003 from l_sql
 declare c_cts20g03_003 cursor for p_cts20g03_003

 let l_sql = ' select lignum '
              ,' from datrligsinvst '
             ,' where sinvstnum = ? and '
                   ,' sinvstano = ? '
 prepare p_cts20g03_004 from l_sql
 declare c_cts20g03_004 cursor for p_cts20g03_004

 let l_sql = ' select ligsinpndflg '
              ,' from datrligsin '
             ,' where lignum = ? '
 prepare p_cts20g03_005 from l_sql
 declare c_cts20g03_005 cursor for p_cts20g03_005

 let l_sql = ' select vstagnnum '
                  ,' ,vstagnstt '
              ,' from datrligagn '
             ,' where lignum = ? '
 prepare p_cts20g03_006 from l_sql
 declare c_cts20g03_006 cursor for p_cts20g03_006

 let l_sql = ' select mstnum '
              ,' from datrligmens '
             ,' where lignum = ? '
 prepare p_cts20g03_007 from l_sql
 declare c_cts20g03_007 cursor for p_cts20g03_007

 let l_sql = ' select trpavbnum '
              ,' from datrligtrpavb '
             ,' where lignum = ? '
 prepare p_cts20g03_008 from l_sql
 declare c_cts20g03_008 cursor for p_cts20g03_008

 let l_sql = ' select drscrsagdcod '
                  ,' ,agdligrelstt '
              ,' from datrdrscrsagdlig '
             ,' where lignum = ? '
 prepare p_cts20g03_009 from l_sql
 declare c_cts20g03_009 cursor for p_cts20g03_009

 let m_sql = true

end function  # cts20g03_prepare()

#---------------------------------------#
function cts20g03_dados_ligacao(lr_param)
#---------------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,lignum  like datmligacao.lignum
 end record

 define lr_retorno1 record
    resultado    smallint
   ,mensagem     char(60)
   ,ligdat       like datmligacao.ligdat
   ,lighorinc    like datmligacao.lighorinc
   ,funmat       like datmligacao.c24funmat
   ,c24solnom    like datmligacao.c24solnom
   ,c24soltipcod like datmligacao.c24soltipcod
   ,c24astcod    like datmligacao.c24astcod
   ,c24paxnum    like datmligacao.c24paxnum
 end record

 initialize lr_retorno1 to null

 let lr_retorno1.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 if lr_param.nivel_retorno = 1 then
    open c_cts20g03_001 using lr_param.lignum
    whenever error continue
       fetch c_cts20g03_001 into lr_retorno1.ligdat
                              ,lr_retorno1.lighorinc
                              ,lr_retorno1.funmat
                              ,lr_retorno1.c24solnom
                              ,lr_retorno1.c24soltipcod
                              ,lr_retorno1.c24astcod
                              ,lr_retorno1.c24paxnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno1.resultado = 2
          let lr_retorno1.mensagem = 'Ligacao Nao Encontrada'
       else
          let lr_retorno1.resultado = 3
          let lr_retorno1.mensagem  = 'Erro de SELECT - c_cts20g03_001 ',sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno1.mensagem)
          let lr_retorno1.mensagem = 'cts20g03_dados_ligacao() ', lr_param.lignum
          call errorlog(lr_retorno1.mensagem)
          let lr_retorno1.mensagem = 'Erro ', sqlca.sqlcode, ' em datmligacao '
       end if
    end if
    close c_cts20g03_001

    return lr_retorno1.*
 end if

 if lr_param.nivel_retorno = 2 then
    open c_cts20g03_001 using lr_param.lignum
    whenever error continue
       fetch c_cts20g03_001 into lr_retorno1.ligdat
                              ,lr_retorno1.lighorinc
                              ,lr_retorno1.funmat
                              ,lr_retorno1.c24solnom
                              ,lr_retorno1.c24soltipcod
                              ,lr_retorno1.c24astcod
                              ,lr_retorno1.c24paxnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno1.resultado = 2
          let lr_retorno1.mensagem  = 'Ligacao Nao Encontrada'
       else
          let lr_retorno1.resultado = 3
          let lr_retorno1.mensagem   = 'Erro SELECT - c_cts20g03_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno1.mensagem)
          let lr_retorno1.mensagem = 'cts20g03_dados_ligacao()', lr_param.lignum
          call errorlog(lr_retorno1.mensagem)
          let lr_retorno1.mensagem = 'Erro ', sqlca.sqlcode, ' em datmligacao '
       end if
    end if
    close c_cts20g03_001
    return lr_retorno1.resultado
          ,lr_retorno1.mensagem
          ,lr_retorno1.c24astcod
 end if
 if lr_param.nivel_retorno = 3 then
    open c_cts20g03_001 using lr_param.lignum

    whenever error continue
    fetch c_cts20g03_001 into lr_retorno1.ligdat
                           ,lr_retorno1.lighorinc
                           ,lr_retorno1.funmat
                           ,lr_retorno1.c24solnom
                           ,lr_retorno1.c24soltipcod
                           ,lr_retorno1.c24astcod
                           ,lr_retorno1.c24paxnum
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno1.resultado = 2
          let lr_retorno1.mensagem  = 'Ligacao Nao Encontrada'
       else
          let lr_retorno1.resultado = 3
          let lr_retorno1.mensagem   = 'Erro SELECT - c_cts20g03_001 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno1.mensagem)
          let lr_retorno1.mensagem = 'cts20g03_dados_ligacao()', lr_param.lignum
          call errorlog(lr_retorno1.mensagem)
          let lr_retorno1.mensagem = 'Erro ', sqlca.sqlcode, ' em datmligacao '
       end if
    end if
    close c_cts20g03_001
    return lr_retorno1.resultado
          ,lr_retorno1.mensagem
          ,lr_retorno1.c24soltipcod
          ,lr_retorno1.c24solnom
 end if

end function  # cts20g03_dados_ligacao()

#-----------------------------------#
function cts20g03_sit_recl(lr_param)
#-----------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,lignum        like datmsitrecl.lignum
 end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(60)
   ,c24rclsitcod like datmsitrecl.c24rclsitcod
 end record

 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 if lr_param.nivel_retorno = 1 then

    open c_cts20g03_002 using lr_param.lignum
    whenever error continue
       fetch c_cts20g03_002 into lr_retorno.c24rclsitcod
    whenever error stop
    if sqlca.sqlcode <> 0 then
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem   = 'Erro SELECT - c_cts20g03_002 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cts20g03_sit_recl()', lr_param.lignum
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datmsitrecl '
    end if
    close c_cts20g03_002

    if lr_retorno.c24rclsitcod is null then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Situacao da reclamacao nao encontrada'
    end if

    return lr_retorno.*
 end if

end function  # cts20g03_sit_recl()

#--------------------------------------#
function cts20g03_recl_ligacao(lr_param)
#--------------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,lignum        like datmreclam.lignum
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,atdsrvnum like datmreclam.atdsrvnum
   ,atdsrvano like datmreclam.atdsrvano
 end record

 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 if lr_param.nivel_retorno = 1 then

    open c_cts20g03_003 using lr_param.lignum
    whenever error continue
       fetch c_cts20g03_003 into lr_retorno.atdsrvnum
                              ,lr_retorno.atdsrvano
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Reclamacao nao encontrada'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem   = 'Erro SELECT - c_cts20g03_003 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'cts20g03_recl_ligacao()',lr_param.lignum
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datmreclam '
       end if
    end if
    close c_cts20g03_003

    return lr_retorno.*
 end if

end function  # cts20g03_recl_ligacao()

#-----------------------------------------#
function cts20g03_vstsin_ligacao(lr_param)
#-----------------------------------------#
 define lr_param record
    sinvstnum like datrligsinvst.sinvstnum
   ,sinvstano like datrligsinvst.sinvstano
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,lignum    like datrligsinvst.lignum
 end record

 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 open c_cts20g03_004 using lr_param.sinvstnum
                        ,lr_param.sinvstano
 whenever error continue
    fetch c_cts20g03_004 into lr_retorno.lignum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Ligacao nao encontrada'
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem  = 'Erro SELECT - c_cts20g03_004 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cts20g03_vstsin_ligacao()',lr_param.sinvstnum, '/'
                                                            ,lr_param.sinvstano
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datrligsinvst '
    end if
 end if
 close c_cts20g03_004

 return lr_retorno.*

end function  # cts20g03_vstsin_ligacao()


#--------------------------------------#
function cts20g03_sin_ligacao(lr_param)
#--------------------------------------#
 define lr_param record
    nivel_retorno smallint
   ,lignum        like datrligsin.lignum
 end record

 define lr_retorno record
    resultado    smallint
   ,mensagem     char(60)
   ,ligsinpndflg like datrligsin.ligsinpndflg
 end record

 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 if lr_param.nivel_retorno = 1 then

    open c_cts20g03_005 using lr_param.lignum
    whenever error continue
       fetch c_cts20g03_005 into lr_retorno.ligsinpndflg
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem  = 'Ligacao nao encontrada'
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem   = 'Erro SELECT - c_cts20g03_005 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'cts20g03_sin_ligacao()',lr_param.lignum
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datrligsin '
       end if
    end if
    close c_cts20g03_005

    return lr_retorno.*
 end if

end function  # cts20g03_sin_ligacao()

#--------------------------------------#
function cts20g03_agn_ligacao(lr_param)
#--------------------------------------#
 define lr_param record
    lignum like datrligagn.lignum
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,vstagnnum like datrligagn.vstagnnum
   ,vstagnstt like datrligagn.vstagnstt
 end record

 define ws    record
    c24astcod like datmligacao.c24astcod
 end record

 initialize ws         to null
 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 # verifica se a ligacao e de agendamento de curso
 select c24astcod
   into ws.c24astcod
   from datmligacao
  where lignum = lr_param.lignum

 if ws.c24astcod = "D15" or
    ws.c24astcod = "D18" or
    ws.c24astcod = "D68" then
    open c_cts20g03_006 using lr_param.lignum
    whenever error continue
       fetch c_cts20g03_006 into lr_retorno.vstagnnum
                              ,lr_retorno.vstagnstt
 else

    ---> Agendamento Curso Direcao Defensiva
    if ws.c24astcod = "D00" or    ---> Agendar
       ws.c24astcod = "D10" or    ---> Consultar
       ws.c24astcod = "D11" or    ---> Alterar
       ws.c24astcod = "D12" then  ---> Cancelar

       open c_cts20g03_009 using lr_param.lignum
       whenever error continue
          fetch c_cts20g03_009 into lr_retorno.vstagnnum
                                 ,lr_retorno.vstagnstt
    end if
 end if

 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Agendamento nao encontrado'
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem  = 'Erro SELECT - c_cts20g03_006 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cts20g03_agn_ligacao()',lr_param.lignum
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datrligagn '
    end if
 end if
 close c_cts20g03_006
 return lr_retorno.*

end function  # cts20g03_agn_ligacao()

#--------------------------------------#
function cts20g03_msg_ligacao(lr_param)
#--------------------------------------#
 define lr_param record
    lignum like datrligmens.lignum
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,mstnum    like datrligmens.mstnum
 end record

 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 open c_cts20g03_007 using lr_param.lignum
 whenever error continue
    fetch c_cts20g03_007 into lr_retorno.mstnum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Mensagem nao encontrada'
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem  = 'Erro SELECT - c_cts20g03_007 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cts20g03_msg_ligacao()',lr_param.lignum
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datrligmens '
    end if
 end if
 close c_cts20g03_007

 return lr_retorno.*

end function  # cts20g03_msg_ligacao()

#-------------------------------------#
function cts20g03_avb_ligacao(lr_param)
#-------------------------------------#
 define lr_param record
    lignum like datrligtrpavb.lignum
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,trpavbnum like datrligtrpavb.trpavbnum
 end record

 initialize lr_retorno to null

 let lr_retorno.resultado = 1

 if m_sql is null or m_sql <> true then
    call cts20g03_prepare()
 end if

 open c_cts20g03_008 using lr_param.lignum
 whenever error continue
    fetch c_cts20g03_008 into lr_retorno.trpavbnum
 whenever error stop

 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = 100 then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem  = 'Averbacao nao encontrada'
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem  = 'Erro SELECT - c_cts20g03_008 ', sqlca.sqlcode,'/',sqlca.sqlerrd[2]
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'cts20g03_avb_ligacao()',lr_param.lignum
       call errorlog(lr_retorno.mensagem)
       let lr_retorno.mensagem = 'Erro ', sqlca.sqlcode, ' em datrligtrpavb '
    end if
 end if
 close c_cts20g03_008

 return lr_retorno.*

end function  # cts20g03_avb_ligacao

