#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema........: Porto Socorro                                             #
# Modulo.........: bdbsa010                                                  #
# Analista Resp..: Celso Carvalho                                            #
# PSI/OSF........: 211982                                                    #
#                  Extracao dos servicos da Portoseg                         #
# ...........................................................................#
# Desenvolvimento: Luiz Alberto, Meta                                        #
# Liberacao......: 27/09/2007                                                #
# ...........................................................................#
#                                                                            #
#                           * * * Alteracoes * * *                           #
#                                                                            #
# Data       Autor Fabrica    Origem    Alteracao                            #
# ---------- --------------   --------- -------------------------------------#
#----------------------------------------------------------------------------#

 globals "/homedsa/projetos/geral/globals/glct.4gl"

   define m_arquivo       char(100)
   define m_lidos         smallint
   define m_log           char(080)   

main

  let m_log   = null
  let m_lidos = 0
  let m_arquivo = f_path('DBS', 'RELATO')
  let m_log = f_path('DBS','LOG')

  if m_arquivo is null or
     m_arquivo = ' '   then
     let m_arquivo = '.'
  end if

  if m_log is null or
      m_log = ' '   then
      let m_log = '.'
   end if

  let m_arquivo = m_arquivo  clipped, "/bdbsa010.xls"
 
  let m_log = m_log clipped, '/dbs_bdbsa010.log'
  call startlog(m_log)
 
  display '----------------------------------------------------------------------'
  let m_log = 'bdbsa010 - Inicio: ', today, ' ', current hour to second
  display m_log  clipped
  call errorlog(m_log)
  display ''

  call bdbsa010_prepare()
  call bdbsa010()

  display ''
  display ''
  let m_log = 'Numero de registros lidos: ', m_lidos
  display m_log  clipped
  call errorlog(m_log)
  display ''
  let m_log = 'bdbsa010 - Final: ', today, ' ', current hour to second
  display m_log  clipped
  call errorlog(m_log)
  display '----------------------------------------------------------------------' 

end main

#-------------------------------#
 function bdbsa010_prepare()
#-------------------------------#

 define l_sql     char(300)

 let l_sql = 'select atdsrvnum, atdsrvano, nom '
             ,' from datmservico '
            ,' where atddat = ? ' 
              ,' and ciaempcod = 40 '

 prepare pbdbsa010001 from l_sql
 declare cbdbsa010001 cursor for pbdbsa010001

end function

#--------------------#
function bdbsa010()
#--------------------#

 define lr_param record
                      resultado     smallint
                     ,erro          integer
                     ,mensagem      char(60)
                     ,atdsrvnum     like datmservico.atdsrvnum 
                     ,atdsrvano     like datmservico.atdsrvano
                     ,lignum        like datmligacao.lignum   
                     ,cgccpfnum     like datrligcgccpf.cgccpfnum
                     ,cgcord        like datrligcgccpf.cgcord
                     ,cgccpfdig     like datrligcgccpf.cgccpfdig
                     ,nom           like datmservico.nom  
                     ,cidnom        like datmlcl.cidnom
                     ,ufdcod        like datmlcl.ufdcod
                     ,socntzcod     like datmsrvre.socntzcod
                     ,espcod        like datmsrvre.espcod
                     ,socntzdes     like datksocntz.socntzdes
                     ,socntzgrpcod  like datksocntz.socntzgrpcod
                     ,atdetpcod     like datmsrvacp.atdetpcod
                     ,atdetpdes     like datketapa.atdetpdes  
                     ,orcvlr        like datmsrvorc.orcvlr    
                     ,atznum        like datmsrvorc.atznum   
                 end record

 define l_data  date

 initialize lr_param to null
 let l_data  = today - 1

 start report bdbsa010_rel to m_arquivo

 open cbdbsa010001 using l_data

 foreach cbdbsa010001 into lr_param.atdsrvnum
                          ,lr_param.atdsrvano
                          ,lr_param.nom      

         ##------ Obter a ligacao do servico 
            let lr_param.lignum = cts20g00_servico(lr_param.atdsrvnum, lr_param.atdsrvano) 

         ##------ Obter o cgc/cpf 
            call ctd06g02_ligacao_cgccpf(lr_param.lignum)
                 returning lr_param.resultado
                          ,lr_param.mensagem
                          ,lr_param.cgccpfnum
                          ,lr_param.cgcord
                          ,lr_param.cgccpfdig
            if lr_param.resultado <> 1 then
               let m_log = "bdbsa010 / ctd06g02_ligacao_cgccpf() / ", lr_param.lignum
               call errorlog(m_log)
               exit foreach
            end if

         ##------ obter a cidade e uf                                                                  
            call ctx04g00_cidade_uf(lr_param.atdsrvnum, lr_param.atdsrvano, 1)
                 returning lr_param.resultado
                          ,lr_param.mensagem
                          ,lr_param.cidnom
                          ,lr_param.ufdcod 
            if lr_param.resultado <> 1 then
               let m_log = "bdbsa010 / ctx04g00_cidade_uf()"
                          ," / ", lr_param.atdsrvnum
                          ," / ", lr_param.atdsrvano
                          ," / 1"
               call errorlog(m_log)
               exit foreach
            end if

         ##------ obter a natureza do servico                                                          
            call cts26g00_obter_natureza(lr_param.atdsrvnum, lr_param.atdsrvano)
                 returning lr_param.resultado
                          ,lr_param.mensagem
                          ,lr_param.socntzcod
                          ,lr_param.espcod 
            if lr_param.resultado <> 1 then
               let m_log = "bdbsa010 / cts26g00_obter_natureza()"
                          ," / ", lr_param.atdsrvnum
                          ," / ", lr_param.atdsrvano
               call errorlog(m_log)
               exit foreach
            end if

         ##------ obter a descricao da natureza do servico                                 
            call ctc16m03_inf_natureza(lr_param.socntzcod, "A")                                           
                 returning  lr_param.resultado
                           ,lr_param.mensagem             
                           ,lr_param.socntzdes   
                           ,lr_param.socntzgrpcod
            if lr_param.resultado <> 1 then
               let m_log = "bdbsa010 / ctc16m03_inf_natureza()"
                          ," / ", lr_param.socntzcod
                          ," / A"
               call errorlog(m_log)
               exit foreach
            end if
                                                     
         ##----- obter o codigo da etapa do servico                                                    
            let lr_param.atdetpcod = cts10g04_ultima_etapa(lr_param.atdsrvnum, lr_param.atdsrvano)
            if lr_param.resultado <> 1 then
               let m_log = "bdbsa010 / cts10g04_ultima_etapa()"
                          ," / ", lr_param.atdsrvnum
                          ," / ", lr_param.atdsrvano
               call errorlog(m_log)
               exit foreach
            end if
                             
         ##----- obter a descricao da etapa                                             
            call cts10g05_desc_etapa(3, lr_param.atdetpcod)                                                   
                 returning lr_param.erro
                          ,lr_param.atdetpdes
            if lr_param.resultado <> 1 then
              let m_log = "bdbsa010 / cts10g05_desc_etapa() "
                          ," 3 " 
                          ," / ", lr_param.atdetpcod
               call errorlog(m_log)
               exit foreach
            end if

         ##----- obter o valor do orcamento                                                            
            call ctd09g00_sel_orc(2, lr_param.atdsrvnum, lr_param.atdsrvano)                  
                     returning  lr_param.resultado 
                               ,lr_param.mensagem
                               ,lr_param.orcvlr
                               ,lr_param.atznum 
            if lr_param.resultado <> 1 then
               let m_log = "bdbsa010 / ctd09g00_sel_orc() "
                          ," 2 " 
                          ," / ", lr_param.atdsrvnum
                          ," / ", lr_param.atdsrvano
               call errorlog(m_log)
               exit foreach
            end if

            output to report bdbsa010_rel (lr_param.cgccpfnum
                                          ,lr_param.cgcord   
                                          ,lr_param.cgccpfdig 
                                          ,lr_param.nom      
                                          ,lr_param.cidnom   
                                          ,lr_param.ufdcod     
                                          ,lr_param.atdsrvnum
                                          ,lr_param.atdsrvano
                                          ,lr_param.atdetpdes     
                                          ,lr_param.socntzdes
                                          ,lr_param.orcvlr   
                                          ,lr_param.atznum)  

 end foreach

 finish report bdbsa010_rel                                     

 call bdbsa010_enviar_email(m_arquivo)  
 close cbdbsa010001 

end function

#------------------------------#
 report bdbsa010_rel(lr_param)
#------------------------------#

 define lr_param  record
                      cgccpfnum     like datrligcgccpf.cgccpfnum  
                     ,cgcord        like datrligcgccpf.cgcord     
                     ,cgccpfdig     like datrligcgccpf.cgccpfdig   
                     ,nom           like datmservico.nom          
                     ,cidnom        like datmlcl.cidnom           
                     ,ufdcod        like datmlcl.ufdcod           
                     ,atdsrvnum     like datmservico.atdsrvnum    
                     ,atdsrvano     like datmservico.atdsrvano       
                     ,atdetpdes     like datketapa.atdetpdes      
                     ,socntzdes     like datksocntz.socntzdes     
                     ,orcvlr        like datmsrvorc.orcvlr           
                     ,atznum        like datmsrvorc.atznum           
                  end record

 output
   right  margin 113
   left   margin 0
   bottom margin 0
   top    margin 0
   page   length 1

 format
     on every row
        if pageno = 1 then
           print 'CPF'              ,ascii(9)
                ,'CLIENTE'          ,ascii(9)
                ,'CIDADE'           ,ascii(9)
                ,'UF'               ,ascii(9)
                ,'SERVICO'          ,ascii(9)
                ,'ANO'              ,ascii(9)
                ,'ETAPA'            ,ascii(9)
                ,'NATUREZA'         ,ascii(9)
                ,'VALOR'            ,ascii(9)
                ,'TRANSACAO'        ,ascii(9)
        end if

        print lr_param.cgccpfnum    using "&&&&&&&&&/"           
             ,lr_param.cgcord       using "&&&&"        
             ,"-"
             ,lr_param.cgccpfdig    using "&&", ascii(9) 
             ,lr_param.nom          ,ascii(9)            
             ,lr_param.cidnom       ,ascii(9)            
             ,lr_param.ufdcod       ,ascii(9)            
             ,lr_param.atdsrvnum    ,ascii(9)            
             ,lr_param.atdsrvano    ,ascii(9)            
             ,lr_param.atdetpdes    ,ascii(9)            
             ,lr_param.socntzdes    ,ascii(9)            
             ,lr_param.orcvlr       ,ascii(9)            
             ,lr_param.atznum       ,ascii(9)            

 let m_lidos = m_lidos + 1

end report               
                         
#------------------------------------------
 function bdbsa010_enviar_email(l_arquivo)
#------------------------------------------
   define l_arquivo   char(100)
   define l_resultado smallint
   define l_erro      smallint

   let l_resultado = null

   call ctx22g00_envia_email('BDBSA010'
                            ,'Extracao de servicos Portoseg'
                            ,l_arquivo)                                                  
        returning l_erro                              

   if l_resultado <> 0 then                                                           
      if l_resultado <> 99 then                                                    
           display "Erro ao enviar email ", l_arquivo
      else                                                                       
           display "Nao existe email cadastrado para o modulo bdbsa010"
      end if                                                         
   end if                                                               
                                                                                  
end function

function fonetica2()
end function 

