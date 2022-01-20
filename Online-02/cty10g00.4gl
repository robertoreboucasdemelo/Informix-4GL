#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cty10g00.4gl                                               #
# Analista Resp : Ligia Mattge                                               #
# PSI           : 183.431                                                    #
# OSF           : 036.439                                                    #
#                 Obter nome e uf da cidade no guia postal;                  #
#                 Obter o grupo de acordo com o ramo/empresa;                #
#                 Selecionar a descricao do ramo;                            #
#                 Obter a descricao da gtakmodal;                            #
#                 Obter a descricao da gfakmda;                              #
#                 Obter descricao da forma de pagamento;                     #
#............................................................................#
# Desenvolvimento: Meta, Robson Inocencio                                    #
# Liberacao      : 22/07/2004                                                #
#............................................................................#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 20/12/2004 Daniel, Meta      PSI187887  Incluir funcao cty10g00_nome_sucur #
#                                         sal()                              #
#----------------------------------------------------------------------------#
# 24/02/2006 Priscila          PSI 198390 Criacao funcao cty10g00_dados_cid  #
# 06/04/2009 Ligia Mattge      PSI198404  Incluir cty10g00_dados_sucursal    #
#----------------------------------------------------------------------------#

database porto

define m_prep_sql   smallint

#--------------------------#
function cty10g00_prepare()
#--------------------------#

  define l_sql        char(300)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_sql  =  null

  let l_sql = " select cidnom, ufdcod "
             ,"   from glakcid        "
             ,"  where cidcod = ?     "
  prepare p_cty10g00_001  from l_sql
  declare c_cty10g00_001  cursor for p_cty10g00_001

  let l_sql = " select ramgrpcod  "
             ,"   from gtakram     "
             ,"  where ramcod = ? "
             ,"    and empcod = ? "
  prepare p_cty10g00_002  from l_sql
  declare c_cty10g00_002  cursor for p_cty10g00_002

  let l_sql = " select ramnom,ramsgl "
             ,"   from gtakram    "
             ,"  where ramcod = ? "
             ,"    and empcod = ? "
  prepare p_cty10g00_003  from l_sql
  declare c_cty10g00_003  cursor for p_cty10g00_003

  let l_sql = " select rmemdlnom     "
             ,"   from gtakmodal     "
             ,"  where empcod    = ? "
             ,"    and ramcod    = ? "
             ,"    and rmemdlcod = ? "
  prepare p_cty10g00_004  from l_sql
  declare c_cty10g00_004  cursor for p_cty10g00_004

  let l_sql = " select mdanom     "
             ,"   from gfakmda    "
             ,"  where mdacod = ? "
  prepare p_cty10g00_005  from l_sql
  declare c_cty10g00_005  cursor for p_cty10g00_005

  let l_sql = " select pgtfrmdes  "
             ,"   from gfbkfpag   "
             ,"  where pgtfrm = ? "
  prepare p_cty10g00_006  from l_sql
  declare c_cty10g00_006  cursor for p_cty10g00_006

  let l_sql = " select sucnom from gabksuc "
             ," where succod = ? "

  prepare p_cty10g00_007  from l_sql
  declare c_cty10g00_007  cursor for p_cty10g00_007

  let l_sql = " select cidcod ",
                " from glakcid ",
               " where cidnom = ? ",
                 " and ufdcod = ? "

  prepare p_cty10g00_008 from l_sql
  declare c_cty10g00_008 cursor for p_cty10g00_008

  let l_sql = " select cidcod, ufdcod, cidnom ",
              " from glakcid          ",
              " where cidcep = ?      ",
              "   and cidcepcmp = ?   "
  prepare p_cty10g00_009 from l_sql
  declare c_cty10g00_009 cursor for p_cty10g00_009

  let l_sql = " select endufd, endcid, cidcod from gabksuc "
             ," where succod = ? "

  prepare p_cty10g00_010  from l_sql
  declare c_cty10g00_010  cursor for p_cty10g00_010

  let m_prep_sql = true

end function

#------------------------------------#
function cty10g00_nome_sucursal(l_succod)
#------------------------------------#

 define l_succod like gabksuc.succod

 define lr_retorno    record
        resultado     smallint
       ,mensagem      char(60)
       ,sucnom        like gabksuc.sucnom
 end record



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cty10g00_prepare()
 end if

 let lr_retorno.resultado = 1
 let lr_retorno.mensagem = ""
 let lr_retorno.sucnom = ""

 if l_succod is null then
    let lr_retorno.resultado = 3
    let lr_retorno.mensagem = "Sucursal nula"
 else
    open c_cty10g00_007 using l_succod

    whenever error continue
    fetch c_cty10g00_007 into lr_retorno.sucnom
    whenever error stop

    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = notfound then
          let lr_retorno.resultado = 2
          let lr_retorno.mensagem = "Sucursal nao encontrada"
       else
          let lr_retorno.resultado = 3
          let lr_retorno.mensagem = " Erro SELECT - c_cty10g00_007 ",sqlca.sqlcode," / ",sqlca.sqlerrd[2]
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem = "cty10g00 / cty10g00_nome_sucursal() / ", l_succod
          call errorlog(lr_retorno.mensagem)
          let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em gabksuc"
       end if
    end if
 end if
    return lr_retorno.*
end function


#------------------------------------#
function cty10g00_cidade_uf(l_cidcod)
#------------------------------------#
   define lr_retorno     record
          resultado     smallint
         ,mensagem      char(60)
         ,nome_cidade   like glakcid.cidnom
         ,uf_cidade     like glakcid.ufdcod
   end record

   define l_cidcod      like glakcid.cidcod
         ,l_msg         char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cty10g00_prepare()
   end if

   if l_cidcod is not null then
      open c_cty10g00_001 using l_cidcod
      whenever error continue
      fetch c_cty10g00_001 into lr_retorno.nome_cidade, lr_retorno.uf_cidade
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Cidade/uf nao encontrada"
            let l_msg = "Cidade/uf nao encontrada"
            call errorlog(l_msg)
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em glakcid"
            let l_msg = " Erro de SELECT - c_cty10g00_001 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(l_msg)
            let l_msg = " cty10g00_cidade_uf() / ",l_cidcod
            call errorlog(l_msg)
         end if
      end if
      close c_cty10g00_001
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Parametros nulos - cty10g00_cidade_uf()"
      let l_msg = 'Parametros nulos - cty10g00_cidade_uf()'
      call errorlog(l_msg)
   end if

   return lr_retorno.*
end function

#------------------------------------#
function cty10g00_grupo_ramo(lr_param)
#------------------------------------#
   define lr_param       record
          empcod        like gtakram.empcod
         ,ramcod        like gtakram.ramcod
   end record

   define lr_retorno     record
          resultado     smallint
         ,mensagem      char(60)
         ,ramgrpcod     like gtakram.ramgrpcod
   end record

   define l_msg         char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cty10g00_prepare()
   end if

   if lr_param.empcod is not null and
      lr_param.ramcod is not null then
      open c_cty10g00_002 using lr_param.ramcod, lr_param.empcod
      whenever error continue
      fetch c_cty10g00_002 into lr_retorno.ramgrpcod
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Grupo do ramo nao encontrado"
            let l_msg = "Grupo do ramo nao encontrado"
            call errorlog(l_msg)
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "Erro ", sqlca.sqlcode, " em gtakram"
            let l_msg = " Erro de SELECT - c_cty10g00_002 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(l_msg)
            let l_msg = " cty10g00_grupo_ramo() / ",lr_param.empcod, " / ",
                                                    lr_param.ramcod
            call errorlog(l_msg)
         end if
      end if
      close c_cty10g00_002
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Parametros nulos - cty10g00_grupo_ramo()"
      let l_msg = 'Parametros nulos - cty10g00_grupo_ramo()'
      #call errorlog(l_msg)
   end if

   return lr_retorno.*
end function

#------------------------------------------#
function cty10g00_obter_cidcod(lr_parametro)
#------------------------------------------#

  # --FUNCAO QUE RETORNA O CODIGO DA CIDADE DA TABELA glakcid

  define lr_parametro record
         cidnom       like glakcid.cidnom,
         ufdcod       like glakcid.ufdcod
  end record

  define lr_retorno   record
         resultado    smallint,  # (0) = Ok   (1) = Not Found   (2) = Erro de acesso
         mensagem     char(100),
         cidcod       like glakcid.cidcod
  end record

  define l_msg        char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

  if m_prep_sql is null or
     m_prep_sql <> true then
     call cty10g00_prepare()
  end if

  # --INICIALIZACAO DAS VARIAVEIS
  initialize lr_retorno to null

  let l_msg = null

  open c_cty10g00_008 using lr_parametro.cidnom,
                          lr_parametro.ufdcod

  whenever error continue
  fetch c_cty10g00_008 into lr_retorno.cidcod
  whenever error stop

  if sqlca.sqlcode <> 0 then
     initialize lr_retorno to null
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 1
        let lr_retorno.mensagem  = "Nao encontrou o codigo da cidade."
     else
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Erro SELECT c_cty10g00_008 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]

        call errorlog(lr_retorno.mensagem)

        let l_msg = "CTY10G00/cty10g00_obter_cidcod() / ",
                     lr_parametro.cidnom, "/",
                     lr_parametro.ufdcod

        call errorlog(l_msg)
     end if
  else
     let lr_retorno.resultado = 0
     let lr_retorno.mensagem  = null
  end if

  close c_cty10g00_008

  return lr_retorno.resultado,
         lr_retorno.mensagem,
         lr_retorno.cidcod

end function


#---------------------------------------------------#
function cty10g00_dados_cid(l_cep, l_cepcmp)
#---------------------------------------------------#
     define l_cep    like glakcid.cidcep,
            l_cepcmp like glakcid.cidcepcmp

     define lr_retorno   record
           resultado  smallint,
           mensagem   char(100),
           cidcod     like glakcid.cidcod,
           cidnom     like glakcid.cidnom,
           ufdcod     like glakcid.ufdcod
     end record

     define l_msg  char(100)

     initialize  lr_retorno.*  to  null

     if m_prep_sql is null or m_prep_sql <> true then
         call cty10g00_prepare()
     end if

     open c_cty10g00_009 using l_cep
                            ,l_cepcmp
     whenever error continue
     fetch c_cty10g00_009 into lr_retorno.cidcod,
                             lr_retorno.ufdcod,
                             lr_retorno.cidnom
     whenever error stop
     if sqlca.sqlcode = 0 then
        let lr_retorno.resultado = 0
     else
        if sqlca.sqlcode = notfound then
           let lr_retorno.resultado = 1
           let lr_retorno.mensagem  = "Cep nao cadastrado"
           let l_msg = "Cep nao cadastrado"
           call errorlog(l_msg)
      else
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em glakcid"
         let l_msg = " Erro de SELECT - c_cty10g00_009 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
         call errorlog(l_msg)
         let l_msg = " cty10g00_dados_cid() / ",l_cep
         call errorlog(l_msg)
      end if
   end if
   close c_cty10g00_009
   return lr_retorno.*
end function


#---------------------------------------------------#
function cty10g00_descricao_ramo(l_ramcod, l_empcod)
#---------------------------------------------------#
   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,ramnom        like gtakram.ramnom
         ,ramsgl        char(15)
   end record

   define l_ramcod      like gtakram.ramnom
         ,l_empcod      like gtakram.empcod
         ,l_msg         char(60)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cty10g00_prepare()
   end if

   open c_cty10g00_003 using l_ramcod
                          ,l_empcod
   whenever error continue
   fetch c_cty10g00_003 into lr_retorno.ramnom,
                           lr_retorno.ramsgl
   whenever error stop
   if sqlca.sqlcode = 0 then
      let lr_retorno.resultado = 1
   else
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem  = "Ramo nao cadastrado"
         let l_msg = "Ramo nao cadastrado"
         call errorlog(l_msg)
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gtakram"
         let l_msg = " Erro de SELECT - c_cty10g00_003 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
         call errorlog(l_msg)
         let l_msg = " cty10g00_descricao_ramo() / ",l_ramcod
         call errorlog(l_msg)
      end if
   end if
   close c_cty10g00_003
   return lr_retorno.*
end function

#-----------------------------------------------#
function cty10g00_descricao_modalidade(lr_param)
#-----------------------------------------------#
   define lr_param      record
          empcod        like gtakmodal.empcod
         ,ramcod        like gtakmodal.ramcod
         ,rmemdlcod     like gtakmodal.rmemdlcod
   end record

   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,rmemdlnom     like gtakmodal.rmemdlnom
   end record

   define l_msg         char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cty10g00_prepare()
   end if

   if lr_param.empcod    is not null and
      lr_param.ramcod    is not null and
      lr_param.rmemdlcod is not null then

      open c_cty10g00_004 using lr_param.empcod
                             ,lr_param.ramcod
                             ,lr_param.rmemdlcod
      whenever error continue
      fetch c_cty10g00_004 into lr_retorno.rmemdlnom
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Descricao da modalidade nao encontrado"
            let l_msg = "Descricao da modalidade nao encontrado"
            call errorlog(l_msg)
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gtakmodal"
            let l_msg = " Erro de SELECT - c_cty10g00_004 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(l_msg)
            let l_msg = " cty10g00_descricao_modalidade() / ",lr_param.empcod, " / "
                                                             ,lr_param.ramcod, " / "
                                                             ,lr_param.rmemdlcod
            call errorlog(l_msg)
         end if
      end if
      close c_cty10g00_004
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  =
          "Parametros nulos - cty10g00_descricao_modalidade()"
      let l_msg = 'Parametros nulos - cty10g00_descricao_modalidade()'
      call errorlog(l_msg)
   end if

   return lr_retorno.*

end function

#-----------------------------------------------#
function cty10g00_descricao_moeda(l_mdacod)
#-----------------------------------------------#
   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,mdanom        like gfakmda.mdanom
   end record

   define l_mdacod      like gfakmda.mdacod
         ,l_msg         char(60)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cty10g00_prepare()
   end if

   if l_mdacod is not null then
      open c_cty10g00_005 using l_mdacod
      whenever error continue
      fetch c_cty10g00_005 into lr_retorno.mdanom
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Descricao da moeda nao encontrado"
            let l_msg = "Descricao da moeda nao encontrado"
            call errorlog(l_msg)
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gfakmda"
            let l_msg = " Erro de SELECT - c_cty10g00_005 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(l_msg)
            let l_msg = " cty10g00_descricao_moeda() / ",l_mdacod
            call errorlog(l_msg)
         end if
      end if
      close c_cty10g00_005
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Parametros nulos - cty10g00_descricao_moeda()"
      let l_msg = 'Parametros nulos - cty10g00_descricao_moeda()'
      call errorlog(l_msg)
   end if

   return lr_retorno.*

end function

#-----------------------------------------------#
function cty10g00_descricao_forma_pagto(l_pgtfrm)
#-----------------------------------------------#
   define lr_retorno    record
          resultado     smallint
         ,mensagem      char(60)
         ,pgtfrmdes     like gfbkfpag.pgtfrmdes
   end record

   define l_pgtfrm      like gfbkfpag.pgtfrm
         ,l_msg         char(60)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        let     l_msg  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

        initialize  lr_retorno.*  to  null

   initialize lr_retorno to null

   if m_prep_sql is null or m_prep_sql <> true then
      call cty10g00_prepare()
   end if

   if l_pgtfrm is not null then
      open c_cty10g00_006 using l_pgtfrm
      whenever error continue
      fetch c_cty10g00_006 into lr_retorno.pgtfrmdes
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = "Descricao Forma de pagto nao encontrada"
            let l_msg = "Descricao Forma de pagto nao encontrada"
            call errorlog(l_msg)
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = "ERRO ", sqlca.sqlcode, " em gfbkfpag"
            let l_msg = " Erro de SELECT - c_cty10g00_006 ",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
            call errorlog(l_msg)
            let l_msg = " cty10g00_descricao_forma_pagto() / ",l_pgtfrm
            call errorlog(l_msg)
         end if
      end if
      close c_cty10g00_006
   else
      let lr_retorno.resultado = 3
      let lr_retorno.mensagem  = "Parametros nulos - cty10g00_descricao_forma_pagto()"
      let l_msg = 'Parametros nulos - cty10g00_descricao_forma_pagto()'
      call errorlog(l_msg)
   end if

   return lr_retorno.*

end function

#----------------------------------------------------------------
function cty10g00_dados_sucursal(l_nivel_retorno, l_succod)
#----------------------------------------------------------------

  define l_nivel_retorno smallint,
         l_succod like gabksuc.succod
  define lr_retorno    record
         resultado     smallint
        ,mensagem      char(60)
        ,endufd        like gabksuc.endufd
        ,endcid        like gabksuc.endcid
        ,cidcod        like gabksuc.cidcod
  end record
  initialize  lr_retorno.*  to  null
  if m_prep_sql is null or
     m_prep_sql <> true then
     call cty10g00_prepare()
  end if
  let lr_retorno.resultado = 1
  open c_cty10g00_010 using l_succod
  whenever error continue
  fetch c_cty10g00_010 into lr_retorno.endufd,
                          lr_retorno.endcid,
                          lr_retorno.cidcod
  whenever error stop
  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_retorno.resultado = 2
        let lr_retorno.mensagem = "Sucursal nao encontrada"
     else
        let lr_retorno.resultado = 3
        let lr_retorno.mensagem = " Erro SELECT - c_cty10g00_010 ",sqlca.sqlcode,
                                  " / ",sqlca.sqlerrd[2]
        call errorlog(lr_retorno.mensagem)
     end if
  end if
  if l_nivel_retorno = 1 then
     return lr_retorno.resultado,
            lr_retorno.mensagem,
            lr_retorno.endufd,
            lr_retorno.endcid,
            lr_retorno.cidcod
  end if

end function
