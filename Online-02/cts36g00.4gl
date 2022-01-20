#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema........: Central 24hrs                                             #
# Modulo.........: cts36g00                                                  #
# Objetivo.......: Obter dados da locacao do carro extra                     #
# Analista Resp. : Ligia Mattge                                              #
# PSI            : 196878                                                    #
#............................................................................#
# Desenvolvimento: Alinne, META                                              #
# Liberacao      : 15/02/2006                                                #
#............................................................................#
#                  * * *  ALTERACOES  * * *                                  #
#                                                                            #
# Data       Autor Fabrica PSI       Alteracao                               #
# --------   ------------- ------    ----------------------------------------#
#                                                                            #
#----------------------------------------------------------------------------#

database porto

   define m_prep_cts36g00 smallint

#-----------------------------------------#
 function cts36g00_prepare()
#-----------------------------------------#
   define l_sql char(400)
   let l_sql = ' select lcvcod       '
              ,'       ,avivclcod    '
              ,'       ,avivclvlr    '
              ,'       ,locsegvlr    '
              ,'       ,avilocnom    '
              ,'       ,avidiaqtd    '
              ,'       ,aviestcod    '
              ,'       ,aviretdat    '
              ,'       ,avirethor    '
              ,'       ,aviprvent    '
              ,'       ,avialgmtv    '
              ,'       ,avioccdat    '
              ,'       ,avirsrgrttip '
              ,'       ,cdtoutflg    '
              ,'       ,locrspcpfnum '
              ,'       ,locrspcpfdig '
              ,'   from datmavisrent '
              ,'  where atdsrvnum = ? '
              ,'    and atdsrvano = ? '
   prepare pcts36g00001 from l_sql
   declare ccts36g00001 cursor for pcts36g00001
   let m_prep_cts36g00 = true

 end function

#-----------------------------------------#
function cts36g00_dados_locacao(lr_param)
#-----------------------------------------#

   define lr_param record
                   nivel     smallint
                  ,atdsrvnum like datmavisrent.atdsrvnum
                  ,atdsrvano like datmavisrent.atdsrvano
                   end record
   define lr_retorno record
                     resultado    smallint
                    ,mensagem     char(080)
                    ,lcvcod       like datmavisrent.lcvcod
                    ,avivclcod    like datmavisrent.avivclcod
                    ,avivclvlr    like datmavisrent.avivclvlr
                    ,locsegvlr    like datmavisrent.locsegvlr
                    ,avilocnom    like datmavisrent.avilocnom
                    ,avidiaqtd    like datmavisrent.avidiaqtd
                    ,aviestcod    like datmavisrent.aviestcod
                    ,aviretdat    like datmavisrent.aviretdat
                    ,avirethor    like datmavisrent.avirethor
                    ,aviprvent    like datmavisrent.aviprvent
                    ,avialgmtv    like datmavisrent.avialgmtv
                    ,avioccdat    like datmavisrent.avioccdat
                    ,avirsrgrttip like datmavisrent.avirsrgrttip
                    ,cdtoutflg    like datmavisrent.cdtoutflg
                    ,locrspcpfnum like datmavisrent.locrspcpfnum
                    ,locrspcpfdig like datmavisrent.locrspcpfdig
                     end record
   initialize lr_retorno to null
   if m_prep_cts36g00 is null or
      m_prep_cts36g00 <> true then
      call cts36g00_prepare()
   end if
      open ccts36g00001 using lr_param.atdsrvnum
                             ,lr_param.atdsrvano
      whenever error continue
      fetch ccts36g00001 into lr_retorno.lcvcod
                             ,lr_retorno.avivclcod
                             ,lr_retorno.avivclvlr
                             ,lr_retorno.locsegvlr
                             ,lr_retorno.avilocnom
                             ,lr_retorno.avidiaqtd
                             ,lr_retorno.aviestcod
                             ,lr_retorno.aviretdat
                             ,lr_retorno.avirethor
                             ,lr_retorno.aviprvent
                             ,lr_retorno.avialgmtv
                             ,lr_retorno.avioccdat
                             ,lr_retorno.avirsrgrttip
                             ,lr_retorno.cdtoutflg
                             ,lr_retorno.locrspcpfnum
                             ,lr_retorno.locrspcpfdig
      whenever error stop
      if sqlca.sqlcode = 0 then
         let lr_retorno.resultado = 1
      else
         if sqlca.sqlcode = notfound then
            let lr_retorno.resultado = 2
            let lr_retorno.mensagem  = 'Dados da locacao nao encontrada'
         else
            let lr_retorno.resultado = 3
            let lr_retorno.mensagem  = 'Erro: ', sqlca.sqlcode, '/',sqlca.sqlerrd[2]
                                      ,' em datmavisrent - cts36g00_dados_locacao'
         end if
      end if
   if lr_param.nivel = 1 then
      return lr_retorno.resultado
            ,lr_retorno.mensagem
            ,lr_retorno.lcvcod
            ,lr_retorno.avivclcod
            ,lr_retorno.avivclvlr
            ,lr_retorno.locsegvlr
            ,lr_retorno.avilocnom
            ,lr_retorno.avidiaqtd
            ,lr_retorno.aviestcod
            ,lr_retorno.aviretdat
            ,lr_retorno.avirethor
            ,lr_retorno.aviprvent
            ,lr_retorno.avialgmtv
            ,lr_retorno.avioccdat
            ,lr_retorno.avirsrgrttip
            ,lr_retorno.cdtoutflg
            ,lr_retorno.locrspcpfnum
            ,lr_retorno.locrspcpfdig
   end if

   if lr_param.nivel = 2 then
      return lr_retorno.lcvcod,
             lr_retorno.aviestcod
   end if

 end function
