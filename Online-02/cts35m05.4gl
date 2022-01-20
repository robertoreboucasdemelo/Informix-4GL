#------------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                              #
# ...........................................................................  #
# SISTEMA........: CENTRAL 24 HORAS                                            #
# MODULO.........: CTS35M05                                                    #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                         #
# PSI/OSF........: PAS                                                         #
#                  CARGA DE FURTO E ROUBO                                      #
# ...........................................................................  #
# DESENVOLVIMENTO: ROBERTO REBOUCAS                                            #
# LIBERACAO......:                                                             #
# .............................................................................#
#  Data        Autor Fabrica     Alteracao                                     #
#  ----------  -------------     --------------------------------------------- #
#  04/01/2010  Amilton           Projeto sucursal smallint                     #
#----------------------------------------------------------------------------- #


globals '/homedsa/projetos/geral/globals/glct.4gl'

database porto

define m_prepare  smallint

function cts35m05_prepare()

define l_sql char(500)

   let l_sql = " select relpamseq ",
               " from igbmparam   ",
               " where relsgl = ? "
   prepare p_cts35m05_001 from l_sql
   declare c_cts35m05_001 cursor for p_cts35m05_001
   let l_sql = " insert into igbmparam " ,
               " values (?,?,?,?)    "
   prepare pcts35m05002 from l_sql

   let l_sql = " select count(*) ",
               " from igbmparam   ",
               " where relsgl = ? "
   prepare pcts35m05003 from l_sql
   declare ccts35m05003 cursor for pcts35m05003
   let l_sql = " select relpamseq,",
               "        relpamtxt ",
               " from igbmparam   ",
               " where relsgl = ? "
   prepare pcts35m05004 from l_sql
   declare ccts35m05004 cursor for pcts35m05004
   let l_sql = " delete from igbmparam " ,
               " where relsgl =  ?     " ,
               " and relpamseq = ?     "
   prepare pcts35m05005 from l_sql
   let m_prepare = true

end function

#--------------------------------------------------------
function cts35m05(l_chamada)
#--------------------------------------------------------

define l_chamada smallint

define lr_aux record
   relsgl     like igbmparam.relsgl     ,
   cont       integer                   ,
   msg        char(200)                 ,
   confirma   char(01)                  ,
   relpamseq  like igbmparam.relpamseq  ,
   relpamtxt  like igbmparam.relpamtxt  ,
   atdsrvano  like datmcntsrv.atdsrvano ,
   atdsrvnum  like datmcntsrv.atdsrvnum ,
   index      integer                   ,
   index_erro integer                   ,
   erro       integer
end record

initialize lr_aux.* to null

let lr_aux.relsgl     = "cts35f10"
let lr_aux.cont       = 0
let lr_aux.index      = 0
let lr_aux.index_erro = 0

   if m_prepare is null or
      m_prepare <> true then
      call cts35m05_prepare()
   end if

   open ccts35m05003 using lr_aux.relsgl
   fetch ccts35m05003 into lr_aux.cont
   close ccts35m05003
   if lr_aux.cont = 0 then
      if l_chamada = 0 then
         error "NAO HA CARGA DE FURTO E ROUBO PENDENTE!"
      end if
   else
      let lr_aux.msg = "TOTAL REG. P/ F10 : ", lr_aux.cont using "<<<<&"
      if not cty42g00_valida() then
         call cts08g01("C","F"
                       ,"CONFIRMA A CARGA DO FURTO E ROUBO ?"
                       ,"",lr_aux.msg clipped,"")
         returning lr_aux.confirma
      end if
      if lr_aux.confirma = "N" then
         return
      end if
      open ccts35m05004 using lr_aux.relsgl
      foreach ccts35m05004 into  lr_aux.relpamseq ,
                                 lr_aux.relpamtxt
        let lr_aux.atdsrvano = lr_aux.relpamtxt[1,2]
        let lr_aux.atdsrvnum = lr_aux.relpamtxt[4,13]
        let lr_aux.erro = cts35m05_chama_mq(lr_aux.atdsrvano,lr_aux.atdsrvnum)
        if lr_aux.erro = 0 then
           # Remove a Chave para o proximo Tratamento
           let lr_aux.erro = cts35m05_remove_furto(lr_aux.relsgl ,lr_aux.relpamseq)
           if lr_aux.erro <> 0  then
              let lr_aux.index_erro = lr_aux.index_erro + 1
           end if
        else
           let lr_aux.index_erro = lr_aux.index_erro + 1
        end if
        let lr_aux.index = lr_aux.index + 1
        error "PROCESSANDO ", lr_aux.index, " DE ", lr_aux.cont ," SERVICOS..."
      end foreach
      if lr_aux.index_erro > 0 then
         error "OCORRERAM ", lr_aux.index_erro , " ERRO(S) DURANTE A CARGA, POR FAVOR FACA A RECARGA!"
      else
          error "*****  C A R G A   F 1 0   L I B E R A D A ******"
      end if
    end if
end function
#--------------------------------------------------------
function cts35m05_grava_furto(lr_param)
#--------------------------------------------------------

define lr_param record
    atdsrvano       like datmcntsrv.atdsrvano,
    atdsrvnum       like datmcntsrv.atdsrvnum
end record

define lr_aux record
    relsgl     like igbmparam.relsgl    ,
    relpamtip  like igbmparam.relpamtip ,
    relpamseq  like igbmparam.relpamseq ,
    relpamtxt  like igbmparam.relpamtxt
end record

initialize lr_aux.* to null

let lr_aux.relsgl = "cts35f10"

   if m_prepare is null or
      m_prepare <> true then
      call cts35m05_prepare()
   end if

   open c_cts35m05_001 using lr_aux.relsgl
   fetch c_cts35m05_001 into lr_aux.relpamseq

   if sqlca.sqlcode = notfound  then
      let lr_aux.relpamseq = 1
   else
      let lr_aux.relpamseq = lr_aux.relpamseq + 1
   end if
   close c_cts35m05_001
   let lr_aux.relpamtxt = lr_param.atdsrvano using '&&' , "|", lr_param.atdsrvnum using '<<<&&&&&&&'
   whenever error continue
   execute pcts35m05002 using lr_aux.relsgl    ,
                              lr_aux.relpamseq ,
                              lr_aux.relpamtip ,
                              lr_aux.relpamtxt
   whenever error stop
   return
end function

#--------------------------------------------------------
function cts35m05_chama_mq(lr_param)
#--------------------------------------------------------

define lr_param record
    atdsrvano       like datmcntsrv.atdsrvano,
    atdsrvnum       like datmcntsrv.atdsrvnum
end record

define lr_aux record
     xml       char(32766)              ,
     online    smallint                 ,
     msg       char(100)                ,
     hora_unix datetime hour to second  ,
     erro      integer                  ,
     ano       char(04)
end record

define lr_figrc006 record
     coderro    integer   ,
     menserro   char(30)  ,
     msgid      char(24)  ,
     correlid   char(24)
end record



initialize lr_aux.*      ,
           lr_figrc006.* to null
 # Converto o Ano para 4 posicoes
 let lr_aux.ano = "20", lr_param.atdsrvano using "&&"
 # Chama Funcao para Montar o XML
 let lr_aux.xml = cts35m05_monta_xml(lr_param.atdsrvnum,lr_aux.ano, "I")
 # Chama Funcao de Envio para MQ
 let lr_aux.erro   = null
 let lr_aux.online = online()

 ## Inclui Passagem pela Rotina de Envio de Mensagem pelo MQ
 let lr_aux.hora_unix = current
 let lr_aux.msg       = "<cts35m05 ",lr_aux.hora_unix,"> CT24H enviando a msg de Servico F10"

 call ssata603_grava_erro(lr_aux.ano        ,
                          lr_param.atdsrvnum,
                          2                 ,
                          lr_aux.msg        ,
                          g_issk.funmat     ,
                          1                 )

 ## Fica Registrado que a Central 24 Horas Chamou a Rotina do MQ
 call figrc006_enviar_datagrama_mq_rq ("SIAUTOANALISE4GLD",lr_aux.xml,"CORRELID",lr_aux.online)
      returning lr_figrc006.*
 if lr_figrc006.coderro <> 0 then
    let lr_aux.msg= lr_figrc006.coderro,' - ',lr_figrc006.menserro clipped
    call ssata603_grava_erro(lr_aux.ano        ,
                             lr_param.atdsrvnum,
                             2                 ,
                             lr_aux.msg        ,
                             g_issk.funmat     ,
                             1                 )
 end if
 return lr_figrc006.coderro
end function

#-------------------------------------------------------------#
 function cts35m05_monta_xml(lr_param)
#-------------------------------------------------------------#
 define lr_param  record
  sinvstnum like datmvstsin.sinvstnum ,
  sinvstano like datmvstsin.sinvstano ,
  tipprd    char(1)
 end record
 define l_xml  char(32766)
 let l_xml = "<mq>",
             "<servico>","EMISLAUDO","</servico>",
             "<param>",lr_param.sinvstnum using "<<<<<&","</param>",
             "<param>",lr_param.sinvstano,"</param>",
             "<param>",lr_param.tipprd,"</param>",
             "<param>","CT","</param>",
             "<param>",g_issk.succod using "<<<&&","</param>",#"&&","</param>",  ## Codigo da Sucursal Projeto succod
             "<param>",g_issk.empcod using "&&","</param>",     ## Codigo da empresa
             "<param>",g_issk.dptsgl clipped,"</param>",        ## Codigo do depatramento
             "<param>",g_issk.funmat using "&&&&&&","</param>", ## Matricula do Solicitante
             "</mq>"
 return l_xml
 end function
#-------------------------------------------------------------#
 function cts35m05_remove_furto(lr_param)
#-------------------------------------------------------------#
define lr_param record
  relsgl     like igbmparam.relsgl    ,
  relpamseq  like igbmparam.relpamseq
end record
  whenever error continue
  execute pcts35m05005 using lr_param.relsgl,
                             lr_param.relpamseq
  whenever error stop
return sqlca.sqlcode

end function
