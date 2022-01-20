#############################################################################
# Nome do Modulo: CTS20G00                                         Marcelo  #
#                                                                  Gilberto #
# Funcoes genericas de acesso a tabelas da Central 24 Horas        Set/1999 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 30/03/2000  PSI 10079-0  Akio         Atendimento da perda parcial        #
#---------------------------------------------------------------------------#
# 29/01/2001  psi 12479-6  Ruiz         Relacionamento ligacaoxagendamento  #
#---------------------------------------------------------------------------#
# 03/06/2002  psi 14178-0  Ruiz         Relacionamento ligacaoXaverbacao    #
#---------------------------------------------------------------------------#
# 22/04/2003  Aguinaldo Costa     PSI.168920     Resolucao 86
#############################################################################
#                                                                           #
#                         * * * Alteracoes * * *                            #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- --------------------------------- #
# 25/11/2003 Meta, Bruno       PSI 172111 Implementar cursor ccts20g00005,  #
#                              OSF 29343  na funcao cts20g00_ligacao().     #
#                                                                           #
# 22/07/2004 Meta, Robson      PSI 183431 Verifica ligacao para a proposta  #
#                              OSF036439                                    #
#                                                                           #
# 11/04/2005 Robson Carmo,Meta PSI 189790 Verifica a existencia de uma      #
#                                         ligacao de complemento no servico.#
#                                                                           #
# 06/06/2005 James,Meta        PSI 189790 Obter o assunto da ultima ligacao #
#                                         de complemento do servico.        #
# ---------- --------------    ---------  ----------------------------------#
# 30/01/2006 T.Solda, Meta     PSI194387  Passar o "vcompila" no modulo     #
# 22/09/06   Ligia Mattge      PSI 202720 Implementacao do cartao Saude     #
#---------------------------------------------------------------------------#
# 10/03/2009 Carla Rampazzo    PSI 235580 Auto Jovem-Curso Direcao Defensiva#
#                              Selecionar e retornar o Nro.Agendamento Curso#
#---------------------------------------------------------------------------#

 database porto

 define m_prep_sql    smallint   # PSI 172111

#----------------------------------------------------------------------------
 function cts20g00_prepare()
#----------------------------------------------------------------------------

 define ws           record
    sql              char (1500)
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  ws.*  to  null

 let ws.sql = "select datmligacao.lignum,     ",
              "       datrligsrv.atdsrvnum,   ",
              "       datrligsrv.atdsrvano,   ",
              "       datrligsinvst.sinvstnum,",
              "       datrligsinvst.sinvstano,",
              "       datrligsinvst.ramcod,   ",
              "       datrligsinavs.sinavsnum,",
              "       datrligsinavs.sinavsano,",
              "       datrligsin.sinnum,      ",
              "       datrligsin.sinano,      ",
              "       datrligagn.vstagnnum,   ",
              "       datrligtrpavb.trpavbnum,",
              "       datrligsau.crtnum,      ",
              "       datrdrscrsagdlig.drscrsagdcod ",
              "  from datmligacao ,            ",
              " outer datrligsrv   , outer datrligsinvst, ",
              " outer datrligsinavs, outer datrligsin, ",
              " outer datrligagn   , outer datrligtrpavb, ",
              " outer datrligsau   , outer datrdrscrsagdlig   ",
              " where datmligacao.lignum   = ?",
              "   and datrligsrv.lignum    = datmligacao.lignum",
              "   and datrligsinvst.lignum = datmligacao.lignum",
              "   and datrligsinavs.lignum = datmligacao.lignum",
              "   and datrligsin.lignum    = datmligacao.lignum",
              "   and datrligagn.lignum    = datmligacao.lignum",
              "   and datrligtrpavb.lignum = datmligacao.lignum",
              "   and datrligsau.lignum    = datmligacao.lignum",
              "   and datrdrscrsagdlig.lignum  = datmligacao.lignum"
 prepare p_cts20g00_001 from ws.sql
 declare c_cts20g00_001 cursor with hold for p_cts20g00_001

 let ws.sql = "select datrligsrv.lignum       ",
              "  from datrligsrv              ",
              " where datrligsrv.atdsrvnum = ?",
              "   and datrligsrv.atdsrvano = ?",
              " order by lignum               "
 prepare p_cts20g00_002 from ws.sql
 declare c_cts20g00_002 cursor with hold for p_cts20g00_002

 let ws.sql = "select datrligsinavs.lignum       ",
              "  from datrligsinavs              ",
              " where datrligsinavs.sinavsnum = ?",
              "   and datrligsinavs.sinavsano = ?",
              " order by lignum                  "
 prepare p_cts20g00_003 from ws.sql
 declare c_cts20g00_003 cursor with hold for p_cts20g00_003

 let ws.sql = "select datrligsinvst.lignum,      ",
              "       datrligsinvst.ramcod       ",
              "  from datrligsinvst              ",
              " where datrligsinvst.sinvstnum = ?",
              "   and datrligsinvst.sinvstano = ?",
              " order by lignum                  "
 prepare p_cts20g00_004 from ws.sql
 declare c_cts20g00_004 cursor with hold for p_cts20g00_004

# --- PSI 172111 - Inicio ---

 let ws.sql = "select cnslignum     ",
              "  from datrligcnslig ",
              " where lignum = ?    "
 prepare p_cts20g00_005 from ws.sql
 declare c_cts20g00_005 cursor for p_cts20g00_005

# --- PSI 172111 - Final ---

# PSI 183431 - Inicio - Robson

 let ws.sql = " select prporg, prpnumdig "
             ,"   from datrligprp "
             ,"  where lignum = ? "
 prepare p_cts20g00_006 from ws.sql
 declare c_cts20g00_006 cursor for p_cts20g00_006

# PSI 183431 - Fim - Robson

 let ws.sql = ' select a.c24astcod '
               ,' from datmligacao a '
              ,' where a.atdsrvnum = ? '
                ,' and a.atdsrvano = ? '
                ,' and a.c24astcod in ("ALT", "CAN", "REC", "RET") '
                ,' and a.lignum = (select max(b.lignum) '
                                 ,'  from datmligacao b '
                                 ,' where b.atdsrvnum = a.atdsrvnum '
                                 ,'   and b.atdsrvano = a.atdsrvano)'
 prepare p_cts20g00_007 from ws.sql
 declare c_cts20g00_007 cursor for p_cts20g00_007
 
 let ws.sql = ' select clscod,ramcod ',
              ' from datrsrvcls ',
              ' where atdsrvnum = ? ',
              ' and atdsrvano = ? '
 prepare pcts20g00008 from ws.sql
 declare ccts20g00008 cursor for pcts20g00008
 
 
 

 let m_prep_sql = true

end function  ###  cts20g00_prepare

#----------------------------------------------------------------------------
 function cts20g00_ligacao(param)
#----------------------------------------------------------------------------

 define param        record
    lignum           like datmligacao.lignum
 end record

 define ws           record
    atdsrvnum        like datrligsrv.atdsrvnum,
    atdsrvano        like datrligsrv.atdsrvano,
    sinvstnum        like datrligsinvst.sinvstnum,
    sinvstano        like datrligsinvst.sinvstano,
    ramcod           like datrligsinvst.ramcod,
    sinavsnum        like datrligsinavs.sinavsnum,
    sinavsano        like datrligsinavs.sinavsano,
    sinnum           like datrligsin.sinnum,
    sinano           like datrligsin.sinano,
    vstagnnum        like datrligagn.vstagnnum,
    trpavbnum        like datrligtrpavb.trpavbnum,
    cnslignum        like datrligcnslig.cnslignum,   # PSI 172111
    crtsaunum        like datrligsau.crtnum,         ### PSI 202720
    drscrsagdcod     like datrdrscrsagdlig.drscrsagdcod
 end record

 # --- PSI 172111 - Inicio



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  ws.*  to  null

   if m_prep_sql is null or m_prep_sql <> true then
      call cts20g00_prepare()
   end if

 # --- PSI 172111 - Final

 initialize ws.*      to null

 if param.lignum is null  then
    error " Parametro invalido! AVISE A INFORMATICA!"
    return ws.*
 end if

 whenever error continue
    open  c_cts20g00_001 using param.lignum
    if status <> 0 then
       call cts20g00_prepare()
       open c_cts20g00_001 using param.lignum
    end if
 whenever error stop

 fetch c_cts20g00_001 into  param.lignum,
                        ws.atdsrvnum,
                        ws.atdsrvano,
                        ws.sinvstnum,
                        ws.sinvstano,
                        ws.ramcod,
                        ws.sinavsnum,
                        ws.sinavsano,
                        ws.sinnum,
                        ws.sinano,
                        ws.vstagnnum,
                        ws.trpavbnum,
                        ws.crtsaunum,
                        ws.drscrsagdcod
 close c_cts20g00_001

 # --- PSI 172111 - Inicio ---

 open  c_cts20g00_005    using param.lignum
 whenever error continue
 fetch c_cts20g00_005    into ws.cnslignum
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode <> notfound then
       error 'Erro SELECT datrligcnslig ',sqlca.sqlcode, '|',sqlca.sqlerrd[2] sleep 3
       error 'cts20g00_ligacao()/',param.lignum  sleep 3
    else
       let ws.cnslignum = null
    end if
 end if

 # --- PSI 172111 - Final ---

 return ws.*

end function  ###  cts20g00_ligacao

#----------------------------------------------------------------------------
 function cts20g00_servico(param)
#----------------------------------------------------------------------------

 define param        record
    atdsrvnum        like datrligsrv.atdsrvnum,
    atdsrvano        like datrligsrv.atdsrvano
 end record

 define ws           record
    lignum           like datrligsrv.lignum
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  ws.*  to  null

 initialize ws.*      to null

 if param.atdsrvnum is null  or
    param.atdsrvano is null  then
    error " Parametro invalido! AVISE A INFORMATICA!"
    return ws.*
 end if

 whenever error continue
    open  c_cts20g00_002 using param.atdsrvnum,
                               param.atdsrvano
    if status <> 0 then
       call cts20g00_prepare()
       open  c_cts20g00_002 using param.atdsrvnum,
                                  param.atdsrvano
    end if
 whenever error stop

 open  c_cts20g00_002 using param.atdsrvnum,
                            param.atdsrvano
 fetch c_cts20g00_002 into  ws.lignum
 close c_cts20g00_002

 return ws.*

end function  ###  cts20g00_servico

#----------------------------------------------------------------------------
 function cts20g00_sinavs(param)
#----------------------------------------------------------------------------

 define param        record
    sinavsnum        like datrligsinavs.sinavsnum,
    sinavsano        like datrligsinavs.sinavsano
 end record

 define ws           record
    lignum           like datrligsinavs.lignum
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  ws.*  to  null

 initialize ws.*      to null

 if param.sinavsnum is null  or
    param.sinavsano is null  then
    error " Parametro invalido! AVISE A INFORMATICA!"
    return ws.*
 end if

 whenever error continue
    open  c_cts20g00_003 using param.sinavsnum,
                               param.sinavsano
    if status <> 0 then
       call cts20g00_prepare()
       open  c_cts20g00_003 using param.sinavsnum,
                                  param.sinavsano
    end if
 whenever error stop

 fetch c_cts20g00_003 into  ws.lignum
 close c_cts20g00_003

 return ws.*

end function  ###  cts20g00_sinavs

#----------------------------------------------------------------------------
 function cts20g00_sinvst(param)
#----------------------------------------------------------------------------

 define param        record
    sinvstnum        like datrligsinvst.sinvstnum,
    sinvstano        like datrligsinvst.sinvstano,
    ramgrp           dec (1,0)
 end record

 define ws           record
    lignum           like datrligsinvst.lignum,
    ramcod           like datrligsinvst.ramcod
 end record





#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#


	initialize  ws.*  to  null

 initialize ws.*      to null

 if param.sinvstnum is null  or
    param.sinvstano is null  then
    error " Parametro invalido! AVISE A INFORMATICA!"
    return ws.lignum
 end if

 whenever error continue
    open    c_cts20g00_004 using param.sinvstnum,
                                 param.sinvstano
    if status <> 0 then
       call cts20g00_prepare()
       open    c_cts20g00_004 using param.sinvstnum,
                                    param.sinvstano
    end if
 whenever error stop

 foreach c_cts20g00_004 into  ws.lignum, ws.ramcod
    if param.ramgrp = 1  then
       if ws.ramcod <> 31 and
          ws.ramcod <> 531  then
          continue foreach
       end if
    else
       if ws.ramcod = 31   or
          ws.ramcod = 531  then
          continue foreach
       end if
    end if
 end foreach

 return ws.lignum

end function  ###  cts20g00_sinvst

# PSI183431 - Inicio - Robson
#-----------------------------------#
function cts20g00_proposta(l_lignum)
#-----------------------------------#
   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,prporg        like datrligprp.prporg
         ,prpnumdig     like datrligprp.prpnumdig
   end record

   define l_msg         char(60)
         ,l_lignum      like datrligprp.lignum


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cts20g00_prepare()
   end if

   open c_cts20g00_006 using l_lignum
   whenever error continue
   fetch c_cts20g00_006 into lr_retorno.prporg, lr_retorno.prpnumdig
   whenever error stop
   if sqlca.sqlcode = 0 then
      let lr_retorno.resultado = 1
   else
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "Ligacao nao cadastrada para a proposta!"
         #let l_msg = "Ligacao nao cadastrada para a proposta!"
         #call errorlog(l_msg)
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em datrligprp"
         let l_msg = " Erro de SELECT - cts20g00002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2],"-cts20g00_proposta"
         call errorlog(l_msg)
      end if
   end if
   close c_cts20g00_006
   return lr_retorno.*
end function
# PSI183431 - Fim - Robson

#-----------------------------------#
function cts20g00_lig_compl(lr_param)
#-----------------------------------#

 define lr_param record
    atdsrvnum like datmligacao.atdsrvnum
   ,atdsrvano like datmligacao.atdsrvano
 end record

 define lr_retorno record
    resultado smallint
   ,mensagem  char(60)
   ,c24astcod like datmligacao.c24astcod
 end record

 define l_log char(60)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_log  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	initialize  lr_retorno.*  to  null

 initialize lr_retorno to null

 let l_log                = null
 let lr_retorno.resultado = 1

 if m_prep_sql is null or m_prep_sql <> true then
    call cts20g00_prepare()
 end if

 open c_cts20g00_007 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano

 whenever error continue
 fetch c_cts20g00_007 into lr_retorno.c24astcod
 whenever error stop
 if sqlca.sqlcode <> 0 then
    if sqlca.sqlcode = notfound then
       let lr_retorno.resultado = 2
       let lr_retorno.mensagem = "Complemento nao encontrado"
       #let l_log = "Complemento nao encontrado"
       #call errorlog(l_log)
    else
       let lr_retorno.resultado = 3
       let lr_retorno.mensagem = "Erro" ,sqlca.sqlcode, "em datmligacao"
       let l_log = " Erro SELECT - c_cts20g00_007 ", sqlca.sqlcode,"/",sqlca.sqlerrd[2]," cts20g00_lig_compl() / ", lr_param.atdsrvnum, '/', lr_param.atdsrvano
       call errorlog(l_log)
    end if
 end if
 close c_cts20g00_007

 return lr_retorno.*

end function

#==========================================
function cts20g00_clausula(lr_param)
#==========================================    
    define lr_param record 
         atdsrvnum like datmservico.atdsrvnum 
        ,atdsrvano like datmservico.atdsrvano 
    end record 
    
    define lr_retorno record 
          coderro    smallint, 
          mensagem   char(400),
          clscod     like datrastcls.clscod, 
          ramcod     like datrastcls.ramcod 
    end record 
    
    if m_prep_sql is null or 
       m_prep_sql = false then 
       call cts20g00_prepare()
    end if
    
    initialize lr_retorno.* to null 
    
    whenever error continue 
       open ccts20g00008 using lr_param.atdsrvnum,
                                lr_param.atdsrvano 
       fetch ccts20g00008 into lr_retorno.clscod,
                               lr_retorno.ramcod
    whenever error stop
    
    if sqlca.sqlcode <> 0 then       
         let lr_retorno.coderro = sqlca.sqlcode
         let lr_retorno.mensagem = "Erro <",sqlca.sqlcode ,"> ao localizar o servico na tabela datrsrvcls !"
         call errorlog(lr_retorno.mensagem)
    else  
       let lr_retorno.coderro = 0       
    end if           
    
    close ccts20g00008
                             
    return lr_retorno.*      

   
end function