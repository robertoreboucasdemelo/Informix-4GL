#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#..............................................................................#
# Sistema........: Central 24 Horas                                            #
# Modulo.........: cta00m22                                                    #
# Objetivo.......: Envio de E-mail para o Segurado Utilizar o Portal           #
# Analista Resp. : Roberto Melo                                                #
# PSI            :                                                             #
#..............................................................................#
# Desenvolvimento: Roberto Melo                                                #
# Liberacao      : 20/09/2009                                                  #
#..............................................................................#
#                  * * *  ALTERACOES  * * *                                    #
#                                                                              #
# 29/12/2009 Patricia W.                    Projeto SUCCOD - Smallint          #
#------------------------------------------------------------------------------#


globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/figrc012.4gl"


database porto

define m_prepare smallint

#----------------------------------------------#
 function cta00m22_prepare()
#----------------------------------------------#
define l_sql char(500)
  
  let l_sql = "select cpodes      ",
              " from datkdominio  ",
              " where cponom  = ? ",
              " order by cpocod   "
  prepare pcta00m22m00001  from l_sql
  declare ccta00m22m00001  cursor for pcta00m22m00001
  
  let l_sql = "select segnumdig   ",
              " from abbmdoc      ",
              " where succod  = ? ",
              " and aplnumdig = ? ",
              " and itmnumdig = ? ",
              " and dctnumseq = ? "
  prepare pcta00m22m00003  from l_sql
  declare ccta00m22m00003  cursor for pcta00m22m00003
  
  let l_sql = "select sgrorg, sgrnumdig ",
              " from rsamseguro         ",
              " where succod    = ?     ",
              " and   ramcod    = ?     ",
              " and   aplnumdig = ?     "
 prepare pcta00m22m00004  from l_sql
 declare ccta00m22m00004  cursor for pcta00m22m00004
 
 let l_sql = "select segnumdig     ",
             " from rsdmdocto      ",
             " where prporg    = ? ",
             " and   prpnumdig = ? "
 prepare pcta00m22m00005  from l_sql
 declare ccta00m22m00005  cursor for pcta00m22m00005
 
 let l_sql = "select segnom        ",
             " from gsakseg        ",
             " where segnumdig = ? "
 prepare pcta00m22m00006  from l_sql
 declare ccta00m22m00006  cursor for pcta00m22m00006
 let m_prepare = true


end function

#----------------------------------------------#
function cta00m22(lr_param)
#----------------------------------------------#

define lr_param record
   ramcod      like datrservapol.ramcod   ,
   succod      like datrservapol.succod   ,
   aplnumdig   like datrservapol.aplnumdig,
   itmnumdig   like datrservapol.itmnumdig
end record

define lr_retorno record
   maides    like gsakendmai.maides        ,
   segnom    like gsakseg.segnom           ,
   c24astcod like datkassunto.c24astcod    ,
   cponom    like datkdominio.cponom       ,
   permissao smallint                      ,
   segnumdig like gsakseg.segnumdig
end record

initialize lr_retorno.* to null

let lr_retorno.cponom     = "assunto_link" 
let lr_retorno.permissao = false

    if m_prepare is null or
       m_prepare <> true then
       call cta00m22_prepare()
    end if
    
    while true
      
      # Somente para a Empresa 1
      if g_documento.ciaempcod <> 1 then
         exit while
      end if
      
      # Recupera o Numero do Segurado
      call cta00m22_recupera_segnumdig (lr_param.ramcod    ,
                                        lr_param.succod    ,
                                        lr_param.aplnumdig ,
                                        lr_param.itmnumdig )
      returning lr_retorno.segnumdig
      
      # Verifica se o Processo de Notificacao ao Segurado Pode Ser Enviado
      
      if lr_retorno.segnumdig is not null then
         
         # Recupera o E-mail do Segurado
         let lr_retorno.maides = cty17g00_ssgtseg02_ct24h_rec_email(lr_retorno.segnumdig)
         
         if lr_retorno.maides is not null then      
            # Recupera o Nome do Segurado
            let lr_retorno.segnom = cta00m22_recupera_segnom(lr_retorno.segnumdig)
         else
            error "E-mail Não Cadastrado!"
            exit while
         end if
         
         # Verifica se Entrou por Motivo de Envio do Link para Assunto B01
         if g_documento.c24astcod    = "B01" then
            
            case g_documento.rcuccsmtvcod 
              
              when 20                
                  # Dispara o E-mail Link Sinistro
                  call cta00m22_envia_email(lr_retorno.maides ,
                                            lr_retorno.segnom ,
                                            lr_param.succod   ,
                                            lr_param.aplnumdig )
              when 26 
                 # Dispara o E-mail Link Porto Vias
                  call cta00m22_envia_email3(lr_retorno.maides , 
                                             lr_retorno.segnom , 
                                             lr_param.succod   , 
                                             lr_param.aplnumdig )
            end case    
                             
         else
               # Verifica se o Assunto tem Permissão de Envio
               open ccta00m22m00001 using lr_retorno.cponom
               foreach ccta00m22m00001 into lr_retorno.c24astcod
              
                  if g_documento.c24astcod = lr_retorno.c24astcod then
                     let lr_retorno.permissao = true
                     exit foreach
                  end if
               
               end foreach
               
               if lr_retorno.permissao   then
                  # Dispara o E-mail
                  call cta00m22_envia_email(lr_retorno.maides  ,
                                            lr_retorno.segnom  ,
                                            lr_param.succod    ,
                                            lr_param.aplnumdig )                                                     
               end if  
               
         end if
               
         exit while
      
      end if
    
    end while

end function


#----------------------------------------------#
 function cta00m22_recupera_segnumdig(lr_param)
#----------------------------------------------#

define lr_param  record
   ramcod      like datrservapol.ramcod   ,
   succod      like datrservapol.succod   ,
   aplnumdig   like datrservapol.aplnumdig,
   itmnumdig   like datrservapol.itmnumdig
end record
define lr_retorno record
   segnumdig   like gsakseg.segnumdig   ,
   sgrorg      like rsamseguro.sgrorg   ,
   sgrnumdig   like rsamseguro.sgrnumdig
end record

  if m_prepare is null or
     m_prepare <> true then
     call cta00m22_prepare()
  end if
 
  initialize lr_retorno.* to null
    
      #-----------------------------------------------------------
      # Localiza numero do segurado conforme ramo
      #-----------------------------------------------------------
      if lr_param.ramcod = 31  or
         lr_param.ramcod = 531 then
        
         if lr_param.succod    is not null  and
            lr_param.aplnumdig is not null  and
            lr_param.itmnumdig is not null  then
            
            if g_funapol.dctnumseq is null  then
               call f_funapol_ultima_situacao (lr_param.succod,
                                               lr_param.aplnumdig,
                                               lr_param.itmnumdig)
                    returning g_funapol.*
            end if
            
            open ccta00m22m00003  using lr_param.succod    ,
                                        lr_param.aplnumdig ,
                                        lr_param.itmnumdig ,
                                        g_funapol.dctnumseq
            whenever error continue
            fetch ccta00m22m00003 into lr_retorno.segnumdig
            whenever error stop
           
            if sqlca.sqlcode <> 0  then
               error " Erro (", sqlca.sqlcode, ") na localizacao do documento (AUTOMOVEL). AVISE A INFORMATICA!"
            end if
            
            close ccta00m22m00003
         end if
      else
         if lr_param.ramcod    is not null  and
            lr_param.succod    is not null  and
            lr_param.aplnumdig is not null  then
            
            open ccta00m22m00004  using lr_param.succod    ,
                                        lr_param.ramcod    ,
                                        lr_param.aplnumdig
            whenever error continue
            fetch ccta00m22m00004 into lr_retorno.sgrorg   ,
                                       lr_retorno.sgrnumdig
            whenever error stop
            if sqlca.sqlcode <> 0  then
               error "Erro (", sqlca.sqlcode, ") na localizacao do seguro (RAMOS ELEMENTARES). AVISE A INFORMATICA!"
            else
                open ccta00m22m00005  using lr_retorno.sgrorg   ,
                                            lr_retorno.sgrnumdig
                whenever error continue
                fetch ccta00m22m00005 into  lr_retorno.segnumdig
                whenever error stop
                if sqlca.sqlcode <> 0  then
                   error " Erro (", sqlca.sqlcode, ") na localizacao do documento (RAMOS ELEMENTARES). AVISE A INFORMATICA!"
                end if
            end if
         end if
      end if
      
      return lr_retorno.segnumdig

end function

#----------------------------------------------#
 function cta00m22_envia_email(lr_param)
#----------------------------------------------#

define lr_param record
  maides    like gsakendmai.maides        ,
  segnom    like gsakseg.segnom           ,
  succod    like datrligapol.succod       ,
  aplnumdig like datrligapol.aplnumdig
end record

define lr_mail record
  rem     char(50)   ,
  des     char(800)  ,
  ccp     char(250)  ,
  cco     char(250)  ,
  ass     char(150)  ,
  msg     char(32000),
  idr     char(20)   ,
  tip     char(4)
end record

define lr_retorno record
  comando  char(15000)             ,
  erro     smallint                ,
  msgerro  char(100)               ,
  confirma char(01)                ,
  cpodes   like datkdominio.cpodes
end record

define a_link array[03] of record
  cponom like datkdominio.cponom,
  cpodes char(200)
end record

define l_index smallint

for l_index  =  1  to  3
     initialize  a_link[l_index].*  to  null
end for


initialize lr_retorno.*,
           lr_mail.*    to null

  if m_prepare is null or
     m_prepare <> true then
     call cta00m22_prepare()
  end if
  
  let a_link[1].cponom = "endereco_link1"
  let a_link[2].cponom = "endereco_link2"
  let a_link[3].cponom = "endereco_link3"
  
  # Recupera a Instancia do Banco
  if  not figrc012_sitename("cta00m22","","") then
     display "ERRO NO SITENAME !"
  end if

  call cts08g01("I","N","SERA ENVIADO POR EMAIL UM LINK DO PORTAL",
                        " DO CLIENTE QUE PERMITE O PREENCHIMENTO",
                        " DO AVISO/CONSULTA DE PROCESSO SINISTRO",
                        " AUTO E INFS SOBRE SUA APOLICE")
  returning lr_retorno.confirma
 
  for l_index = 1 to 3
      open ccta00m22m00001 using a_link[l_index].cponom
      foreach ccta00m22m00001 into lr_retorno.cpodes
         let a_link[l_index].cpodes = a_link[l_index].cpodes clipped , lr_retorno.cpodes
      end foreach
  end for
  
  # Se for Banco de Producao Envia o E-mail
  if not g_outFigrc012.Is_Teste then
       
       let lr_mail.rem = "Porto-Seguro"
       let lr_mail.ass = "Link Portal do Segurado"
       let lr_mail.des = lr_param.maides clipped
       let lr_mail.ccp = ""
       let lr_mail.cco = ""
       let lr_mail.idr = "F0104364"
       let lr_mail.tip = "html"
       let lr_mail.msg = "<html><body><font face='Arial' size='3'>"
       let lr_mail.msg = lr_mail.msg clipped, "Caro(a) cliente, ", lr_param.segnom clipped , "<br><br>"
       let lr_mail.msg = lr_mail.msg clipped, "A Porto Seguro criou um Portal exclusivo para voc&ecirc;: o Portal do Cliente!.<br>"
       let lr_mail.msg = lr_mail.msg clipped, "&Eacute; um meio de atendimento que possibilita o "
       let lr_mail.msg = lr_mail.msg clipped, "<b> preenchimento do aviso de sinistro, consulta e acompanhamento do seu "
       let lr_mail.msg = lr_mail.msg clipped, " processo</b>, bem como obter informa&ccedil;&otilde;es sobre sua ap&oacute;lice e servi&ccedil;os.<br><br>"
       let lr_mail.msg = lr_mail.msg clipped, "Para acessar voc&ecirc; s&oacute; precisa ter em m&atilde;os o n&uacute;mero de sua ap&oacute;lice e seu CPF<br><br>"
       let lr_mail.msg = lr_mail.msg clipped, "Ap&oacute;lice ", lr_param.succod using '<<<<&' , "-", lr_param.aplnumdig using '<<<&&&&&&', ", selecione uma das op&ccedil;&otilde;es:<br><br>" 
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[1].cpodes, "' target='_blank'><u><font size='3' color='#0000FF' face='Arial'> Clique Aqui,</font></u></a><font size='3' face='Arial'>"
       let lr_mail.msg = lr_mail.msg clipped, " para come&ccedil;ar a aproveitar agora mesmo todos esses benef&iacute;cios.<br><br>"
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[2].cpodes, "' target='_blank'><u><font size='3' color='#0000FF' face='Arial'> Clique Aqui,</font></u></a><font size='3' face='Arial'>"
       let lr_mail.msg = lr_mail.msg clipped, " se voc&ecirc; j&aacute; possui o cadastro no Portal do Cliente.<br><br>"
       let lr_mail.msg = lr_mail.msg clipped, "Portal do Cliente, mais uma inova&ccedil;&atilde;o da Porto Seguro.</font><br><br>"
       let lr_mail.msg = lr_mail.msg clipped, "<div><font size='2' face='Arial'>Essa mensagem foi gerada automaticamente e n&atilde;o pode ser respondida.<br>"
       let lr_mail.msg = lr_mail.msg clipped, "Para atendimento online,"
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[3].cpodes, "' target='_blank'><u><font size='1' color='#0000FF' face='Tahoma'> Clique Aqui</font></u></a><font size='2' face='Tahoma'>.</font>"
       let lr_mail.msg = lr_mail.msg clipped, "</div></body></html>"
       
       call figrc009_mail_send1(lr_mail.*)
            returning lr_retorno.erro,
                      lr_retorno.msgerro
      
       if lr_retorno.erro <> 0 then
          error "Erro no Envio de E-mail para ", lr_param.maides ," !" sleep 2
       else
          error "E-mail Enviado para ", lr_param.maides sleep 2
       end if
       
       error ""
  
  end if
end function

#----------------------------------------------#
 function cta00m22_recupera_segnom(lr_param)
#----------------------------------------------#

define lr_param record
   segnumdig like gsakseg.segnumdig
end record

define lr_retorno record
   segnom like gsakseg.segnom
end record

 initialize lr_retorno.* to null
 if m_prepare is null or
    m_prepare <> true then
    call cta00m22_prepare()
 end if
   open ccta00m22m00006  using lr_param.segnumdig
   whenever error continue
   fetch ccta00m22m00006 into lr_retorno.segnom
   whenever error stop

   if sqlca.sqlcode <> 0  then
      error " Erro (", sqlca.sqlcode, ") na localizacao do nome do segurado. AVISE A INFORMATICA!"
   end if

   return lr_retorno.segnom

end function

#----------------------------------------------# 
 function cta00m22_terceiro()         
#----------------------------------------------# 

define lr_retorno record                              
   maides    like gsakendmai.maides        ,          
   segnom    like gsakseg.segnom           ,          
   c24astcod like datkassunto.c24astcod    ,          
   cponom    like datkdominio.cponom       ,          
   permissao smallint                                  
end record                                            

initialize lr_retorno.* to null

let lr_retorno.cponom    = "assunto_link_terc"    
let lr_retorno.permissao = false                  

    if m_prepare is null or    
       m_prepare <> true then  
       call cta00m22_prepare() 
    end if                     

    # Verifica se o Assunto tem Permissão de Envio Terceiro                   
    open ccta00m22m00001 using lr_retorno.cponom                            
    foreach ccta00m22m00001 into lr_retorno.c24astcod                         
                                                                  
       if g_documento.c24astcod = lr_retorno.c24astcod then                   
          let lr_retorno.permissao = true                                     
          exit foreach                                                        
       end if                                                                 
                                                                              
    end foreach                                                                  
                                                                              
    if lr_retorno.permissao   then                                            
       
        # Recupera o E-mail do Terceiro
    
        let lr_retorno.maides = cty17g00_email()
    
        if lr_retorno.maides is not null then
       
            # Dispara o E-mail Terceiro                                            
            
            call cta00m22_envia_email2(lr_retorno.maides  ,                        
                                       lr_retorno.segnom  )    
        end if 
                                                                                                                                                                                              
    end if     
    
    return lr_retorno.permissao                                                               
    
end function

#----------------------------------------------#                                                                                                                                                                                                                                                                                                                                          
 function cta00m22_envia_email2(lr_param)                                                                                                                                                                                                                                                                                                                                                    
#----------------------------------------------#                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                          
define lr_param record                                                                                                                                                                                                                                                                                                                                                                    
  maides    like gsakendmai.maides        ,                                                                                                                                                                                                                                                                                                                                               
  segnom    like gsakseg.segnom                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
end record                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                          
define lr_mail record                                                                                                                                                                                                                                                                                                                                                                     
  rem     char(50)   ,                                                                                                                                                                                                                                                                                                                                                                    
  des     char(800)  ,                                                                                                                                                                                                                                                                                                                                                                    
  ccp     char(250)  ,                                                                                                                                                                                                                                                                                                                                                                    
  cco     char(250)  ,                                                                                                                                                                                                                                                                                                                                                                    
  ass     char(150)  ,                                                                                                                                                                                                                                                                                                                                                                    
  msg     char(32000),                                                                                                                                                                                                                                                                                                                                                                    
  idr     char(20)   ,                                                                                                                                                                                                                                                                                                                                                                    
  tip     char(4)                                                                                                                                                                                                                                                                                                                                                                         
end record                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                          
define lr_retorno record                                                                                                                                                                                                                                                                                                                                                                  
  comando  char(15000)             ,                                                                                                                                                                                                                                                                                                                                                      
  erro     smallint                ,                                                                                                                                                                                                                                                                                                                                                      
  msgerro  char(100)               ,                                                                                                                                                                                                                                                                                                                                                      
  confirma char(01)                ,
  cpodes   like datkdominio.cpodes ,
  data     date                    ,
  hora     datetime hour to minute ,
  mensagem char(60)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
end record  

define a_link array[03] of record
  cponom like datkdominio.cponom,
  cpodes char(200)
end record

define l_index smallint

for l_index  =  1  to  3
     initialize  a_link[l_index].*  to  null
end for

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
initialize lr_retorno.*,                                                                                                                                                                                                                                                                                                                                                                  
           lr_mail.*    to null                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
  if m_prepare is null or                                 
     m_prepare <> true then                               
     call cta00m22_prepare()                              
  end if                                                  
                                                          
  let a_link[1].cponom = "endereco_link4"                 
  let a_link[2].cponom = "endereco_link5"                 
  let a_link[3].cponom = "endereco_link3"                 
                                                          
  # Recupera a Instancia do Banco                         
  if  not figrc012_sitename("cta00m22","","") then        
     display "ERRO NO SITENAME !"                         
  end if                                                  
  
    
  call cts08g01("I","N","SERA ENVIADO POR EMAIL UM LINK DO PORTAL",                                                                                                                                                                                                                                                                                                                       
                        " DO TERCEIRO QUE PERMITE O PREENCHIMENTO",                                                                                                                                                                                                                                                                                                                        
                        " DO AVISO E CONSULTA DE PROCESSO DE",                                                                                                                                                                                                                                                                                                                        
                        " SINISTRO AUTO")                                                                                                                                                                                                                                                                                                                                 
  returning lr_retorno.confirma                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
  for l_index = 1 to 3                                                                    
      open ccta00m22m00001 using a_link[l_index].cponom                                   
      foreach ccta00m22m00001 into lr_retorno.cpodes                                                                                                                                                                                                                                                                                                                                                                                                                              
         let a_link[l_index].cpodes = a_link[l_index].cpodes clipped , lr_retorno.cpodes  
      end foreach                                                                         
  end for                                                                                 

  
  # Se for Banco de Producao Envia o E-mail                                                                                                                                                                                                                                                                                                                                               
  if not g_outFigrc012.Is_Teste then                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                          
       let lr_mail.rem = "Porto-Seguro"                                                                                                                                                                                                                                                                                                                                                   
       let lr_mail.ass = "Link Portal do Terceiro"                                                                                                                                                                                                                                                                                                                                        
       let lr_mail.des = lr_param.maides clipped                                                                                                                                                                                                                                                                                                                                          
       let lr_mail.ccp = ""                                                                                                                                                                                                                                                                                                                                                               
       let lr_mail.cco = ""                                                                                                                                                                                                                                                                                                                                                               
       let lr_mail.idr = "F0104364"                                                                                                                                                                                                                                                                                                                                                       
       let lr_mail.tip = "html"                                                                                                                                                                                                                                                                                                                                                           
       let lr_mail.msg = "<html><body><font face='Arial' size='3'>"                                                                                                                                                                                                                                                                                                                 
       let lr_mail.msg = lr_mail.msg clipped, "Caro(a) reclamante, <br><br>"                                                                                                                                                                                                                                                                             
       let lr_mail.msg = lr_mail.msg clipped, "A Porto Seguro disponibilizou para voc&ecirc; a possibilidade do preenchimento<br>"                                                                                                                                                                                                                                                 
       let lr_mail.msg = lr_mail.msg clipped, "do seu Aviso de Sinistro e a Consulta de Processo. <br><br>"                                                                                                                                                                                                                                                                                  
       let lr_mail.msg = lr_mail.msg clipped, "Para acessar, basta clicar nos links abaixo:<br><br>"                                                                                                                                                                                                                
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[1].cpodes, "' target='_blank'><u><font size='3' color='#0000FF' face='Arial'> Clique Aqui,</font></u></a><font size='3' face='Arial'>"                                                                                                                                                                     
       let lr_mail.msg = lr_mail.msg clipped, " para preencher o Aviso de Sinistro.<br><br>"                                                                                                                                                                                                                                                
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[2].cpodes, "' target='_blank'><u><font size='3' color='#0000FF' face='Arial'> Clique Aqui,</font></u></a><font size='3' face='Arial'>"                                                                                                                                                                     
       let lr_mail.msg = lr_mail.msg clipped, " para consultar o andamento do processo.<br><br>"                                                                                                                                                           
       let lr_mail.msg = lr_mail.msg clipped, "Portal do Terceiro, mais uma inova&ccedil;&atilde;o da Porto Seguro.</font><br><br>"                                                                                                                                                                                                                                                  
       let lr_mail.msg = lr_mail.msg clipped, "<div><font size='2' face='Arial'>Essa mensagem foi gerada automaticamente e n&atilde;o pode ser respondida.<br>"                                                                                                                                                                                                                     
       let lr_mail.msg = lr_mail.msg clipped, "Para atendimento online,"                                                                                                                                                                                                                                                                                                            
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[3].cpodes, "' target='_blank'><u><font size='1' color='#0000FF' face='Tahoma'> Clique Aqui</font></u></a><font size='2' face='Tahoma'>.</font>"                                                                                                                                                            
       let lr_mail.msg = lr_mail.msg clipped, "</div></body></html>"                                                                                                                                                                                                                                                                                                                
       
       call figrc009_mail_send1(lr_mail.*)                                                                                                                                                                                                                                                                                                                                                
            returning lr_retorno.erro,                                                                                                                                                                                                                                                                                                                                                    
                      lr_retorno.msgerro                                                                                                                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                                                                                                                                          
       if lr_retorno.erro <> 0 then                                                                                                                                                                                                                                                                                                                                                       
          error "Erro no Envio de E-mail para ", lr_param.maides ," !" sleep 2                                                                                                                                                                                                                                                                                                            
       else                                                                                                                                                                                                                                                                                                                                                                               
          error "E-mail Enviado para ", lr_param.maides sleep 2                                                                                                                                                                                                                                                                                                                           
       end if                                                                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                                                                                          
       error "" 
       
       # Grava o E-mail no Historico da Ligacao
       
       if g_documento.lignum is not null then
          
          call cts40g03_data_hora_banco(2)    
              returning lr_retorno.data, 
                        lr_retorno.hora       
       
          let lr_retorno.mensagem = "MENSAGEM ENVIADA PARA: ", lr_param.maides clipped
          
          call ctd06g01_ins_datmlighist(g_documento.lignum  ,     
                                        g_issk.funmat       ,         
                                        lr_retorno.mensagem ,   
                                        lr_retorno.data     ,    
                                        lr_retorno.hora     ,    
                                        g_issk.usrtip       ,     
                                        g_issk.empcod       )    
               returning lr_retorno.erro,                        
                         lr_retorno.msgerro                      
                  
         if lr_retorno.erro <> 0 then                                                
            error lr_retorno.msgerro      
         end if                                                                      
               
       end if 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
  end if 
                                                                                                                                                                                                                                                                                                                                                                                   
end function   

#----------------------------------------------#                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
 function cta00m22_envia_email3(lr_param)                                                                                                                                                                                       
#----------------------------------------------#                                                                                                                                                                               
                                                                                                                                                                                                                               
define lr_param record                                                                                                                                                                                                         
  maides    like gsakendmai.maides        ,                                                                                                                                                                                    
  segnom    like gsakseg.segnom           ,                                                                                                                                                                                    
  succod    like datrligapol.succod       ,                                                                                                                                                                                    
  aplnumdig like datrligapol.aplnumdig                                                                                                                                                                                         
end record                                                                                                                                                                                                                     
                                                                                                                                                                                                                               
define lr_mail record                                                                                                                                                                                                          
  rem     char(50)   ,                                                                                                                                                                                                         
  des     char(800)  ,                                                                                                                                                                                                         
  ccp     char(250)  ,                                                                                                                                                                                                         
  cco     char(250)  ,                                                                                                                                                                                                         
  ass     char(150)  ,                                                                                                                                                                                                         
  msg     char(32000),                                                                                                                                                                                                         
  idr     char(20)   ,                                                                                                                                                                                                         
  tip     char(4)                                                                                                                                                                                                              
end record                                                                                                                                                                                                                     
                                                                                                                                                                                                                               
define lr_retorno record                                                                                                                                                                                                       
  comando  char(15000)             ,                                                                                                                                                                                           
  erro     smallint                ,                                                                                                                                                                                           
  msgerro  char(100)               ,                                                                                                                                                                                           
  confirma char(01)                ,                                                                                                                                                                                           
  cpodes   like datkdominio.cpodes                                                                                                                                                                                             
end record                                                                                                                                                                                                                     
                                                                                                                                                                                                                               
define a_link array[03] of record                                                                                                                                                                                              
  cponom like datkdominio.cponom,                                                                                                                                                                                              
  cpodes char(200)                                                                                                                                                                                                             
end record                                                                                                                                                                                                                     
                                                                                                                                                                                                                               
define l_index smallint                                                                                                                                                                                                        
                                                                                                                                                                                                                               
for l_index  =  1  to  3                                                                                                                                                                                                       
     initialize  a_link[l_index].*  to  null                                                                                                                                                                                   
end for                                                                                                                                                                                                                        
                                                                                                                                                                                                                               
                                                                                                                                                                                                                               
initialize lr_retorno.*,                                                                                                                                                                                                       
           lr_mail.*    to null                                                                                                                                                                                                
                                                                                                                                                                                                                               
  if m_prepare is null or                                                                                                                                                                                                      
     m_prepare <> true then                                                                                                                                                                                                    
     call cta00m22_prepare()                                                                                                                                                                                                   
  end if                                                                                                                                                                                                                       
                                                                                                                                                                                                                               
  let a_link[1].cponom = "endereco_link6"                                                                                                                                                                                      
  let a_link[2].cponom = "endereco_link3"                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                               
  # Recupera a Instancia do Banco                                                                                                                                                                                              
  if  not figrc012_sitename("cta00m22","","") then                                                                                                                                                                             
     display "ERRO NO SITENAME !"                                                                                                                                                                                              
  end if                                                                                                                                                                                                                       
                                                                                                                                                                                                                               
  call cts08g01("I","N"," ","SERA ENVIADO POR EMAIL PARA O CLIENTE",                                                                                                                                                            
                            " UM LINK DE ACESSO AO PORTO VIAS ",                                                                                                                                                                                                                                                                                                          
                            " ")                                                                                                                                                                      
  returning lr_retorno.confirma                                                                                                                                                                                                
                                                                                                                                                                                                                               
  for l_index = 1 to 2                                                                                                                                                                                                         
      open ccta00m22m00001 using a_link[l_index].cponom                                                                                                                                                                        
      foreach ccta00m22m00001 into lr_retorno.cpodes                                                                                                                                                                           
         let a_link[l_index].cpodes = a_link[l_index].cpodes clipped , lr_retorno.cpodes                                                                                                                                       
      end foreach                                                                                                                                                                                                              
  end for                                                                                                                                                                                                                      
                                                                                                                                                                                                                               
  # Se for Banco de Producao Envia o E-mail                                                                                                                                                                                    
  if not g_outFigrc012.Is_Teste then                                                                                                                                                                                                   
                                                                                                                                                                                                                               
       let lr_mail.rem = "Porto-Seguro"                                                                                                                                                                                        
       let lr_mail.ass = "Link Porto Vias"                                                                                                                                                                             
       let lr_mail.des = lr_param.maides clipped                                                                                                                                                                               
       let lr_mail.ccp = ""                                                                                                                                                                                                    
       let lr_mail.cco = ""                                                                                                                                                                                                    
       let lr_mail.idr = "F0104364"                                                                                                                                                                                            
       let lr_mail.tip = "html"                                                                                                                                                                                                
       let lr_mail.msg = "<html><body><font face='Arial' size='3'>"                                                                                                                                                      
       let lr_mail.msg = lr_mail.msg clipped, "Prezado (a) Segurado (a), ", lr_param.segnom clipped , "<br><br>"                                                                                                                  
       let lr_mail.msg = lr_mail.msg clipped, "Utilize tamb&eacute;m o PortoVias, nosso servi&ccedil;o de monitoramento de tr&acirc;nsito em tempo real, para tra&ccedil;ar o melhor caminho.<br>"                                                                                          
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[1].cpodes, "' target='_blank'><u><font size='3' color='#0000FF' face='Arial'> Clique Aqui,</font></u></a><font size='3' face='Arial'>"          
       let lr_mail.msg = lr_mail.msg clipped, " e acesse o PortoVias. Veja a dist&acirc;ncia estimada para voc&ecirc; chegar ao seu destino.<br><br>"                                                                                     
       let lr_mail.msg = lr_mail.msg clipped, " O destino &eacute; o mesmo. O caminho &eacute; o mais r&aacute;pido.<br><br>"                                                                                                                                                                                               
       let lr_mail.msg = lr_mail.msg clipped, "<div><font size='2' face='Arial'>Essa mensagem foi gerada automaticamente e n&atilde;o pode ser respondida.<br>"                                                          
       let lr_mail.msg = lr_mail.msg clipped, "Para atendimento online,"                                                                                                                                                 
       let lr_mail.msg = lr_mail.msg clipped, "</font><a href='", a_link[2].cpodes, "' target='_blank'><u><font size='1' color='#0000FF' face='Tahoma'> Clique Aqui</font></u></a><font size='2' face='Tahoma'>.</font>" 
       let lr_mail.msg = lr_mail.msg clipped, "</div></body></html>"                                                                                                                                                     
       
      
       call figrc009_mail_send1(lr_mail.*)                                                                                                                                                                                     
            returning lr_retorno.erro,                                                                                                                                                                                         
                      lr_retorno.msgerro                                                                                                                                                                                       
                                                                                                                                                                                                                               
       if lr_retorno.erro <> 0 then                                                                                                                                                                                            
          error "Erro no Envio de E-mail para ", lr_param.maides ," !" sleep 2                                                                                                                                                 
       else                                                                                                                                                                                                                    
          error "E-mail Enviado para ", lr_param.maides sleep 2                                                                                                                                                                
       end if                                                                                                                                                                                                                  
                                                                                                                                                                                                                               
       error ""                                                                                                                                                                                                                
                                                                                                                                                                                                                               
  end if                                                                                                                                                                                                                       
end function                                                                                                                                                                                                                   