#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO                                              #
# MODULO.........: BDBSR038                                                   #
# ANALISTA RESP..: RAFAEL MOREIRA GOMES                                       #
# PSI/OSF........: Extracao Telefone/Referencia                               #
# ........................................................................... #
# DESENVOLVIMENTO: FORNAX TECNOLOGIA, RCP                                     #
# LIBERACAO......: 08/05/2015                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
#                                                                             #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_path       char(100),
       m_path_txt   char(100),
       m_data       date
       
define mr_telefone record
       atddat            like datmservico.atddat
      ,atdsrvnum         like datmservico.atdsrvnum
      ,atdsrvano         like datmservico.atdsrvano
      ,dddcod            like datmlcl.dddcod
      ,lcltelnum         like datmlcl.lcltelnum
      ,celteldddcod      like datmlcl.celteldddcod
      ,celtelnum         like datmlcl.celtelnum
      ,lclrefptotxt      like datmlcl.lclrefptotxt
end record

main

    call fun_dba_abre_banco("CT24HS")
   
    call bdbsr038_busca_path()

    call bdbsr038_prepare()

    call cts40g03_exibe_info("I","BDBSR038")

    set isolation to dirty read
  
    call bdbsr038_teleFone()
    
    call bdbsr038_envia_email()
    
    call cts40g03_exibe_info("F","BDBSR038")

end main

#------------------------------#
 function bdbsr038_busca_path()
#------------------------------#

    define l_dataarq char(8)
    define l_data    date
    
    let l_data = today
    display "l_data: ", l_data
    let l_dataarq = extend(l_data, year to year),
                    extend(l_data, month to month),
                    extend(l_data, day to day)
    display "l_dataarq: ", l_dataarq

    # ---> INICIALIZACAO DAS VARIAVEIS
    let m_path = null

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE LOG
    let m_path = f_path("DBS","LOG")

    if m_path is null then
       let m_path = "."
    end if

    let m_path = m_path clipped, "/bdbsr038.log"

    call startlog(m_path)

    # ---> CHAMA A FUNCAO PARA BUSCAR O CAMINHO DO ARQUIVO DE RELATORIO
    let m_path = f_path("DBS","RELATO")

    if m_path is null then
       let m_path = "."
    end if
    
    let m_path_txt = m_path clipped
    
    let m_path = m_path clipped, "/BDBSR038.xls"
    
    let m_path_txt = m_path_txt clipped, "/BDBSR038_", l_dataarq, ".txt" 
    
    display "m_path: ", m_path
    display "m_path_txt: ", m_path_txt
        
 end function

#---------------------------#
 function bdbsr038_prepare()
#---------------------------#
  define l_sql char(2000)
  define l_data_atual date,
         l_hora_atual datetime hour to minute

  let l_data_atual = arg_val(1)
   
  # ---> OBTER A DATA E HORA DO BANCO
  if l_data_atual is null then
     call cts40g03_data_hora_banco(2)
          returning l_data_atual,
                    l_hora_atual
  end if                

   let m_data = l_data_atual - 1 units day # ---> Programa de processamento diário
   display "m_data: ", m_data
    
  # ---> OBTEM DADOS PARA O RELATORIO
  initialize l_sql to null
  let l_sql = " select srv.atddat       "
             ,"       ,srv.atdsrvnum    "
             ,"       ,srv.atdsrvano    "
             ,"       ,lcl.dddcod       "
             ,"       ,lcl.lcltelnum    "
             ,"       ,lcl.celteldddcod "
             ,"       ,lcl.celtelnum    "
             ,"       ,replace(replace(replace(lcl.lclrefptotxt, chr(13), ''), chr(10), ''), chr(09), ' ')  "
             ,"   from datmservico srv, datmlcl lcl  "
             ,"  where srv.atdsrvnum = lcl.atdsrvnum "
             ,"    and srv.atdsrvano = lcl.atdsrvano "
             ,"    and lcl.c24endtip = 1             " # - End de ocorrencia
	           ,"    and srv.atddat = ?                "
  prepare pbdbsr038001 from l_sql            
  declare cbdbsr038001 cursor for pbdbsr038001    
  
end  function

#----------------------------#
 function bdbsr038_teleFone()
#----------------------------#

   initialize mr_telefone.* to null
   
   start report bdbsr038_relatorio to m_path
   start report bdbsr038_relatorio_txt to m_path_txt

   open cbdbsr038001 using m_data
   
   foreach cbdbsr038001 into  mr_telefone.atddat
                             ,mr_telefone.atdsrvnum
                             ,mr_telefone.atdsrvano
                             ,mr_telefone.dddcod
                             ,mr_telefone.lcltelnum
                             ,mr_telefone.celteldddcod
                             ,mr_telefone.celtelnum
                             ,mr_telefone.lclrefptotxt
                       
      output to report bdbsr038_relatorio()
      output to report bdbsr038_relatorio_txt()
                       
      initialize mr_telefone.* to null
    
   end foreach

   finish report bdbsr038_relatorio       
   finish report bdbsr038_relatorio_txt
                                          
 end function                             

#-------------------------------#
 function bdbsr038_envia_email()
#-------------------------------#

   define l_assunto     char(100),
          l_comando     char(200),
          l_anexo       char(200),
          l_erro_envio  integer

   # ---> INICIALIZACAO DAS VARIAVEIS
   let l_comando    = null
   let l_erro_envio = null
   let l_assunto    = "Relatorio Telefone/Referência - ", m_data, " - BDBSR038"

   # Colocamos o whenever para que o programa nao aborte quando ocorrer erro no envio de email
   # pois a nova funcao nao retorna o erro, ela aborta o programa
   whenever error continue
    
   # ---> COMPACTA O ARQUIVO DO RELATORIO
   let l_comando = "gzip -f ", m_path
   run l_comando
   let m_path = m_path clipped, ".gz"

   #let l_anexo = m_path clipped, ",", m_path_b clipped

   let l_erro_envio = ctx22g00_envia_email("BDBSR038", l_assunto, m_path)

   if  l_erro_envio <> 0 then
       if  l_erro_envio <> 99 then
           display "Erro ao enviar email(ctx22g00) - ", m_path clipped
       else
           display "Nao existe email cadastrado para o modulo - BDBSR038"
       end if
   end if

   whenever error stop

end function

#---------------------------#
 report bdbsr038_relatorio()
#---------------------------#

output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    02

  format

     first page header
        print "SERVICO"          ,ascii(9),
              "ANO"              ,ascii(9),
              "DDD"              ,ascii(9),
              "TELEFONE"         ,ascii(9),
              "DDD"              ,ascii(9),
              "CELULAR"          ,ascii(9),
              "PONTO_REFERENCIA" ,ascii(9),
              "DATA_ATENDIMENTO" 

     on every row
        print  mr_telefone.atdsrvnum           ,ascii(9)
              ,mr_telefone.atdsrvano           ,ascii(9)
              ,mr_telefone.dddcod              ,ascii(9)
              ,mr_telefone.lcltelnum           ,ascii(9)
              ,mr_telefone.celteldddcod        ,ascii(9)
              ,mr_telefone.celtelnum           ,ascii(9)
              ,mr_telefone.lclrefptotxt clipped,ascii(9)
              ,mr_telefone.atddat
             
 end report
 
#---------------------------#
 report bdbsr038_relatorio_txt()
#---------------------------#

output

     left   margin    00
     right  margin    00
     top    margin    00
     bottom margin    00
     page   length    01

  format

     on every row
        print  mr_telefone.atdsrvnum           ,ascii(9)
              ,mr_telefone.atdsrvano           ,ascii(9)
              ,mr_telefone.dddcod              ,ascii(9)
              ,mr_telefone.lcltelnum           ,ascii(9)
              ,mr_telefone.celteldddcod        ,ascii(9)
              ,mr_telefone.celtelnum           ,ascii(9)
              ,mr_telefone.lclrefptotxt clipped,ascii(9)
              ,mr_telefone.atddat
             
 end report
