#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema        : PORTO SOCORRO                                              #
# Modulo         : ctd00g00                                                   #
#                  Função para validação de tarifas Porto Seguro pametrizado  #
# Analista Resp. : Sergio Burini                                              #
# PSI            :                                                            #
#.............................................................................#
#                                                                             #
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data        Autor Fabrica  Data   Alteracao                                 #
# ----------  -------------  ------ ------------------------------------------#
# 29/12/2009  Fabio Costa    PSI 198404 Tratar fim de linha windows Ctrl+M    #
#-----------------------------------------------------------------------------#

database porto

#---------------------------#
 function ctd00g00_prepare()
#---------------------------#

     define l_sql char(5000)
     
     let l_sql = "select socvcltip ",
                  " from datmservico srv, datkveiculo vcl ",
                 " where atdsrvnum = ? ",
                   " and atdsrvano = ? ",
                   " and srv.socvclcod = vcl.socvclcod "
     
     prepare prctd00g00_01 from l_sql
     declare cqctd00g00_01 cursor for prctd00g00_01 
     
     let l_sql = "select grlinf ",
                  " from datkgeral ",     
                 " where grlchv = ? "
     
     prepare prctd00g00_02 from l_sql
     declare cqctd00g00_02 cursor for prctd00g00_02    
     
     let l_sql = "select * from iddkdominio ",
                 " where cponom ='tipvclsemadcnot' ",
                   " and cpocod = ? "
     
     prepare prctd00g00_03 from l_sql
     declare cqctd00g00_03 cursor for prctd00g00_03     
     
     let l_sql = " select atdsrvorg ", 
                   " from datmservico ", 
                  " where atdsrvnum = ? ",
                    " and atdsrvano = ? "
                      
     prepare prctd00g00_04 from l_sql
     declare cqctd00g00_04 cursor for prctd00g00_04      

 end function
  
#----------------------------------# 
 function ctd00g00_vlrprmpgm(param)
#----------------------------------#

     define param record
         atdsrvnum like datmservico.atdsrvnum,
         atdsrvano like datmservico.atdsrvano,
         tipval    char(003)
     end record
     
     define lr_aux record
         socvcltip like datkveiculo.socvcltip,
         vlrprm    like dbsksrvrmeprc.srvrmevlr,
         atdsrvorg like datmservico.atdsrvorg,
         tipsrv    char(005),
         param     char(025)
     end record

     call ctd00g00_prepare()
     
     open cqctd00g00_01 using param.atdsrvnum,
                              param.atdsrvano
     fetch cqctd00g00_01 into lr_aux.socvcltip

     open cqctd00g00_04 using param.atdsrvnum,
                              param.atdsrvano
     fetch cqctd00g00_04 into lr_aux.atdsrvorg     

     if  lr_aux.atdsrvorg = 9 or lr_aux.atdsrvorg = 13 then
         let lr_aux.tipsrv = "RE"
     else
         let lr_aux.tipsrv = "AUTO"
     end if
     
     let lr_aux.param = "PSO", param.tipval , "VCL", lr_aux.socvcltip using "<<&", lr_aux.tipsrv

     open cqctd00g00_02 using lr_aux.param
     fetch cqctd00g00_02 into lr_aux.vlrprm

     return lr_aux.vlrprm,
            sqlca.sqlcode
     
 end function 
 
#--------------------------------# 
 function ctd00g00_compvlr(param)  
#--------------------------------# 
 
 define param record
     vlrsugerido like dbsksrvrmeprc.srvrmevlr,
     vlrprm      like dbsksrvrmeprc.srvrmevlr
 end record
 
 if  (param.vlrsugerido > param.vlrprm ) or
     (param.vlrsugerido = 1 and param.vlrprm > 1)  then    
     let param.vlrsugerido = param.vlrprm
 end if

 return param.vlrsugerido
 
 end function