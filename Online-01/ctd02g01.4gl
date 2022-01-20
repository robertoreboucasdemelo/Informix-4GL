#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTD02G01                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 205.206 - AZUL SEGUROS                                     #
#                  RETORNA O AZLAPLCOD DE UMA APOLICE DA AZUL                 #
# ........................................................................... #
# DESENVOLVIMENTO: Ligia Mattge                                               #
# LIBERACAO......: 23/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA      AUTOR FABRICA   ORIGEM     ALTERACAO                              #
# --------  --------------  ---------- -------------------------------------- #
# 15/04/10  Fabio Costa     PSI198404  Incluir consulta por CPF/CNPJ          #
#-----------------------------------------------------------------------------#

database porto

  define m_ctd02g01_prep smallint

#-------------------------#
function ctd02g01_prepare()
#-------------------------#

  define l_sql char(500)

  let l_sql = null

  let l_sql = " select azlaplcod ",
                " from datkazlapl ",
               " where succod = ? ",
               " and   ramcod = ? ",
               " and   aplnumdig = ? ",
               " and   itmnumdig = ? ",
               " and   edsnumdig = ? "

  prepare pctd02g01001 from l_sql
  declare cctd02g01001 cursor for pctd02g01001

  let l_sql = " select azlaplcod ",
                " from datkazlapl ",
               " where succod = ? ",
               " and   ramcod = ? ",
               " and   aplnumdig = ? ",
               " and   itmnumdig = ? ",
               " and   edsnumdig in (select max(edsnumdig) from datkazlapl ",
                                     " where succod = ? ",
                                     " and   ramcod = ? ",
                                     " and   aplnumdig = ? ",
                                     " and   itmnumdig = ?) "

  prepare pctd02g01002 from l_sql
  declare cctd02g01002 cursor for pctd02g01002

  let l_sql = " select vcllicnum, cgccpfnum, cgcord, cgccpfdig ",
                " from datkazlapl ",
                " where azlaplcod = ? "

  prepare pctd02g01003 from l_sql
  declare cctd02g01003 cursor for pctd02g01003

  let m_ctd02g01_prep = true

end function

#--------------------------------------#
function ctd02g01_azlaplcod(lr_param)
#--------------------------------------#

  define lr_param     record
         succod       like datkazlapl.succod,
         ramcod       like datkazlapl.ramcod,
         aplnumdig    like datkazlapl.aplnumdig,
         itmnumdig    like datkazlapl.itmnumdig,
         edsnumdig    like datkazlapl.edsnumdig
         end record

  define l_azlaplcod  like datkazlapl.azlaplcod,
         l_resultado  smallint,
         l_mensagem   char(80)

  if m_ctd02g01_prep is null or
     m_ctd02g01_prep <> true then
     call ctd02g01_prepare()
  end if

  let l_azlaplcod = null
  let l_resultado = 1
  let l_mensagem  = null

  whenever error continue

  if lr_param.edsnumdig is not null then
     open cctd02g01001 using lr_param.succod, lr_param.ramcod,
                             lr_param.aplnumdig, lr_param.itmnumdig,
                             lr_param.edsnumdig
     fetch cctd02g01001 into l_azlaplcod
  else
     open cctd02g01002 using lr_param.succod, lr_param.ramcod,
                             lr_param.aplnumdig, lr_param.itmnumdig,
                             lr_param.succod, lr_param.ramcod,
                             lr_param.aplnumdig, lr_param.itmnumdig
     fetch cctd02g01002 into l_azlaplcod
  end if

  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_resultado = 2
        let l_mensagem  = "Nao encontrou o codigo da apolice "
     else
        let l_resultado = 3
        let l_mensagem = "Erro SELECT cctd02g01001 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
  end if

  if lr_param.edsnumdig is not null then
     close cctd02g01001
  else
     close cctd02g01002
  end if

  return l_resultado, l_mensagem, l_azlaplcod

end function


#----------------------------------------------------------------
function ctd02g01_azlapl_sel(lr_param)
#----------------------------------------------------------------

  define lr_param record
         nivel_retorno  smallint                 ,
         cgccpfnum      like datkazlapl.cgccpfnum,
         cgcord         like datkazlapl.cgcord   ,
         cgccpfdig      like datkazlapl.cgccpfdig
  end record
  
  define l_azlapl record
         segnom     like datkazlapl.segnom   ,
         pestip     like datkazlapl.pestip   ,
         succod     like datkazlapl.succod   ,
         ramcod     like datkazlapl.ramcod   ,
         aplnumdig  like datkazlapl.aplnumdig,
         itmnumdig  like datkazlapl.itmnumdig,
         vcllicnum  like datkazlapl.vcllicnum,
         azlaplcod  like datkazlapl.azlaplcod
  end record
  
  define l_res  integer
       , l_msg  char(60)
       , l_sql  char(500)
       , l_whe  char(100)
  
  initialize l_res, l_msg, l_sql, l_whe to null
  initialize l_azlapl.* to null
  
  let l_res = 0
  
  if lr_param.cgcord is null
     then
     let l_whe = " where cgccpfnum = ? ",
                 "   and cgccpfdig = ? "
  else
     let l_whe = " where cgccpfnum = ? ",
                 "   and cgcord    = ", lr_param.cgcord, 
                 "   and cgccpfdig = ? "
  end if
  
  let l_sql = " select segnom, pestip, succod, ramcod, aplnumdig, ",
              "        itmnumdig, vcllicnum, azlaplcod ",
              " from datkazlapl ",
              l_whe clipped
  prepare p_seg_azl_sel from l_sql
  declare c_seg_azl_sel cursor for p_seg_azl_sel
  
  whenever error continue
  open c_seg_azl_sel using lr_param.cgccpfnum, lr_param.cgccpfdig
  fetch c_seg_azl_sel into l_azlapl.*
  whenever error stop
  
  let l_res = sqlca.sqlcode
  
  close c_seg_azl_sel
  
  if l_res != 0
     then
     if l_res = 100
        then
        let l_msg = 'Segurado Azul nao encontrado'
        else
        let l_msg = 'Erro na selecao Segurado Azul: ', l_res
     end if
  end if
  
  if lr_param.nivel_retorno = 1
     then
     return l_res, l_msg, l_azlapl.segnom   ,
                          l_azlapl.pestip   ,
                          l_azlapl.succod   ,
                          l_azlapl.ramcod   ,
                          l_azlapl.aplnumdig,
                          l_azlapl.itmnumdig,
                          l_azlapl.vcllicnum,
                          l_azlapl.azlaplcod
  end if
  
  if lr_param.nivel_retorno = 2
     then
     return l_res, l_msg, l_azlapl.segnom
  end if
  
end function

#--------------------------------------#
function ctd02g01_dados_azul(lr_param)
#--------------------------------------#

  define lr_param       record
         nivel_retorno  smallint,
         azlaplcod      like datkazlapl.azlaplcod
         end record

  define lr_azul        record
         vcllicnum      like datkazlapl.vcllicnum,
         cgccpfnum      like datkazlapl.cgccpfnum,
         cgcord         like datkazlapl.cgcord   ,
         cgccpfdig      like datkazlapl.cgccpfdig
  end record
  
  define l_resultado  smallint,
         l_mensagem   char(80)

  if m_ctd02g01_prep is null or
     m_ctd02g01_prep <> true then
     call ctd02g01_prepare()
  end if

  let l_resultado = 1
  let l_mensagem  = null

  whenever error continue
  open cctd02g01003 using lr_param.azlaplcod
  fetch cctd02g01003 into lr_azul.*
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_resultado = 2
        let l_mensagem  = "Nao encontrou dados da apolice "
     else
        let l_resultado = 3
        let l_mensagem = "Erro SELECT cctd02g01003 / ",
                                   sqlca.sqlcode, "/",
                                   sqlca.sqlerrd[2]
     end if
 
     let lr_azul.cgccpfnum = '00000000000'
     let lr_azul.cgcord = '0000'
     let lr_azul.cgccpfdig = '00'
     let lr_azul.vcllicnum = '0000000'

  end if

  close cctd02g01003

  if lr_param.nivel_retorno = 1 then
     return l_resultado, l_mensagem, lr_azul.vcllicnum,
            lr_azul.cgccpfnum, lr_azul.cgcord, lr_azul.cgccpfdig
  end if

end function
