#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                    OUT/2008 #
#-----------------------------------------------------------------------------#
# SISTEMA..: Teleatendimento                                                  #
# MODULO...: ctd02g02 - Modulo Consulta na transferencia-> datmatdtrn         #
# ANALISTA : Alberto Rodrigues                                                #
# PSI......: 230650 - Adaptacoes no Sistema referente ao Decreto 6523         #
#-----------------------------------------------------------------------------#
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_ctd02m02_prep smallint

#-----------------------------------------------------------------------------#
function ctd02m02_prepare()
#-----------------------------------------------------------------------------#

   define l_sql  char(2000)

   ---> Seleciona dados da transferencia
   let l_sql = "select atdnum       "
                    ,",atdtrnnum    "
                    ,",trnlignum    "
                    ,",necgerlignum "
                    ,",atdpripanum  "
                    ,",atdpridptsgl "
                    ,",atdprifunmat "
                    ,",atdpriusrtip "
                    ,",atdpriempcod "
                    ,",trndat       "
                    ,",trnhor       "
                    ,",atdsegpanum  "
                    ,",atdsegdptsgl "
                    ,",atdsegfunmat "
                    ,",atdsegusrtip "
                    ,",atdsegempcod "
                    ,",trncapdat    "
                    ,",trncaphor    "
               ," from  datmatdtrn "
               ," where atdnum = ? "
               ," and   atdtrnnum = ? "
               ##," and   trncapdat is not null "
               ##," and   trncaphor is not null "
   prepare pctd02m02001 from l_sql
   declare cctd02m02001 cursor for pctd02m02001

   ---> Seleciona dados da transferencia
   let l_sql = "select max (atdtrnnum) "
                ,"from datmatdtrn "
               ,"where atdnum = ? "

   prepare pctd02m02001a from l_sql
   declare cctd02m02001a cursor for pctd02m02001a

   ---> Atualiza Captura da Transferencia
   let l_sql = " update datmatdtrn set (atdsegpanum  "
                                    ,",atdsegdptsgl "
                                    ,",atdsegfunmat "
                                    ,",atdsegusrtip "
                                    ,",atdsegempcod "
                                    ,",trncapdat "
                                    ,",trncaphor)= (?, ?, ?, ?, ?, ?, ?) "
               ," Where atdnum = ? "
               ," and   atdtrnnum = ? "

   prepare pctd02m02002 from l_sql

   ---> Busca Ligacao
   let l_sql = "select c24astcod    "
               ," from  datmligacao "
               ," where lignum  = ? "
   prepare pctd02m02003 from l_sql
   declare cctd02m02003 cursor for pctd02m02003






   let m_ctd02m02_prep = true

end function

#-----------------------------------------------------------------------------#
function ctd02g02(lr_param)
#-----------------------------------------------------------------------------#

   define lr_param         record
          atdnum           like datmatd6523.atdnum
   end record

   define lr_retorno            record
          atdnum                 like datmatdtrn.atdnum
         ,atdtrnnum              like datmatdtrn.atdtrnnum
         ,trnlignum              like datmatdtrn.trnlignum
         ,necgerlignum           like datmatdtrn.necgerlignum
         ,atdpripanum            like datmatdtrn.atdpripanum
         ,atdpridptsgl           like datmatdtrn.atdpridptsgl
         ,atdprifunmat           like datmatdtrn.atdprifunmat
         ,atdpriusrtip           like datmatdtrn.atdpriusrtip
         ,atdpriempcod           like datmatdtrn.atdpriempcod
         ,trndat                 like datmatdtrn.trndat
         ,trnhor                 like datmatdtrn.trnhor
         ,atdsegpanum            like datmatdtrn.atdsegpanum
         ,atdsegdptsgl           like datmatdtrn.atdsegdptsgl
         ,atdsegfunmat           like datmatdtrn.atdsegfunmat
         ,atdsegusrtip           like datmatdtrn.atdsegusrtip
         ,atdsegempcod           like datmatdtrn.atdsegempcod
         ,trncapdat              like datmatdtrn.trncapdat
         ,trncaphor              like datmatdtrn.trncaphor
         ,c24astcod              like datmligacao.c24astcod
   end record

   define l_resultado      smallint
         ,l_mensagem       char(60)

   if m_ctd02m02_prep is null or
      m_ctd02m02_prep <> true then
      call ctd02m02_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   initialize lr_retorno.* to null

   ---> Seleciona Ultimo Atendimento da Transferencia
   open cctd02m02001a using lr_param.atdnum
   fetch cctd02m02001a into lr_retorno.atdtrnnum
   close cctd02m02001a

   ---> Seleciona Dados relacionados ao Atendimento
   open cctd02m02001 using lr_param.atdnum,
                           lr_retorno.atdtrnnum
   whenever error continue
   fetch cctd02m02001 into lr_retorno.atdnum
                          ,lr_retorno.atdtrnnum
                          ,lr_retorno.trnlignum
                          ,lr_retorno.necgerlignum
                          ,lr_retorno.atdpripanum
                          ,lr_retorno.atdpridptsgl
                          ,lr_retorno.atdprifunmat
                          ,lr_retorno.atdpriusrtip
                          ,lr_retorno.atdpriempcod
                          ,lr_retorno.trndat
                          ,lr_retorno.trnhor
                          ,lr_retorno.atdsegpanum
                          ,lr_retorno.atdsegdptsgl
                          ,lr_retorno.atdsegfunmat
                          ,lr_retorno.atdsegusrtip
                          ,lr_retorno.atdsegempcod
                          ,lr_retorno.trncapdat
                          ,lr_retorno.trncaphor
   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let l_resultado = 2
         let l_mensagem = "Este Atendimento nao foi transferido. " 
      else
         let l_resultado = 3
         let l_mensagem = "Erro no acesso a tabela datmatdtrn - ", sqlca.sqlcode
      end if
   else
      if lr_retorno.trncapdat is not null and
         lr_retorno.trncaphor is not null   then
         let l_resultado = 2
         let l_mensagem  = "Atendimento ja transferido para atendente : ", lr_retorno.atdsegfunmat sleep 1
      else
         ---> Seleciona Assunto da ligacao de Transferencia
         open cctd02m02003 using lr_retorno.trnlignum
         fetch cctd02m02003 into lr_retorno.c24astcod
         close cctd02m02003
      end if
   end if

   return l_resultado
         ,l_mensagem
         ,lr_retorno.*

end function 
