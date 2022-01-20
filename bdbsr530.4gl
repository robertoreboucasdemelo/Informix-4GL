#----------------------------------------------------------------------------#
# Sistema       :  SAPS                                                      #
# Modulo        :  bdbsr530.4gl                                             #
# Analista Resp.:  Marcia  Franzon                                           #
# PSI           :                                                            #
#                  Relatorio de utilizacao de dados cadastrais               #
#                                                                            #
#                                                                            #
#                                                                            #
# Desenvolvimento: Marcia  Franzon                                           #
#----------------------------------------------------------------------------#
#                           * * * Alteracoes * * *                           #
#   Data        Autor Fabrica  Origem    Alteracao                           #
# -------       ----- -------  ------    ---------                           #
#                                                                            #
#----------------------------------------------------------------------------#

  database porto

  globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
  globals '/homedsa/projetos/dssqa/producao/I4GLParams.4gl'           
  globals '/homedsa/projetos/geral/globals/glct.4gl'                  
  globals "/homedsa/projetos/geral/globals/figrc072.4gl"   -- > 223689

  define m_rel record   
         atdsrvnum     like datrasitipsug.atdsrvnum 
        ,atdsrvano     like datrasitipsug.atdsrvano
        ,asitipcod     like datrasitipsug.asitipcod    
        ,atddat        like datrasitipsug.atddat    
        ,atlusrtipcod  like datrasitipsug.atlusrtipcod 
        ,atlempcod     like datrasitipsug.atlempcod
        ,atlfunmatnum  like datrasitipsug.atlfunmatnum    
  end record 
             
  define m_dataini     date
  define m_datafim     date
  define m_datchar     char(10)

  define lr_retorno record
         coderro         smallint
        ,msgerro         char(10000)
        ,pcapticrpcod    like fcomcaraut.pcapticrpcod
  end record

  define ws          record
     dirfisnom       like ibpkdirlog.dirfisnom,
     pathrel         char (60)                  
  end record

  define m_arqMensal char(50)                 
  define m_path   char(1000)
                             
#---------------------------------------------------------
 main
#---------------------------------------------------------

    call fun_dba_abre_banco("CT24HS")
    set isolation to dirty read
    set lock mode to wait 10
    let m_datchar = TODAY
    let m_datchar = '01/' , m_datchar[4,10]
    let m_dataini = m_datchar
    let m_dataini = m_dataini - 1 units month 
    let m_datafim = m_dataini + 1 units month  -1 units day
    

    initialize m_rel.*, lr_retorno.* , ws.* , m_path to null 

    call bdbsr530_prepare()

    call bdbsr530_processa()
  
    call bdbsr530_envia_email()      

end main
  
#---------------------------------------------------------
  function bdbsr530_prepare()
#---------------------------------------------------------
 
    define l_cmd    char(1000)
  
#-----------------------------------------------------------------------------
# Dados de atendimentos
#-----------------------------------------------------------------------------
    let l_cmd = " select atdsrvnum    , atdsrvano "
               ,"       ,asitipcod    , atddat    "
               ,"       ,atlusrtipcod , atlempcod "
               ,"       ,atlfunmatnum "
               ," from   datrasitipsug a " 
               ," where a.atddat  between  ?  and ? " 
               ," order by a.atddat  "
    prepare pm_rel001 from l_cmd
    declare cm_rel001 cursor with hold for pm_rel001
    
  end function

#---------------------------------------------------------
  function bdbsr530_processa()
#---------------------------------------------------------    
    
    #Arquivos de extração
    

    #---------------------------------------------------------------
    # Define diretorios para relatorios e arquivos
    #---------------------------------------------------------------
    call f_path("DBS", "RELATO")
         returning m_path
    display "<187> relatorio-> Diretorio-> <", m_path,">"

    if m_path is null then
       let  m_path = "." 
    end if 
    
    let m_path = m_path clipped, "/bdbsr530.xls"
    
    #Diretorio dos arquivos
    
    let m_arqMensal   =  m_path
    display "<205> relatorio-> Aarquivo gerado em:- ", m_path
    #Start Relatorios

    start report bdbsr530_rel_Mensal to  m_arqMensal
    
    open cm_rel001 using m_dataini , m_datafim , m_dataini , m_datafim
    
    foreach cm_rel001 into m_rel.atdsrvnum
                          ,m_rel.atdsrvano
                          ,m_rel.asitipcod
                          ,m_rel.atddat
                          ,m_rel.atlusrtipcod
                          ,m_rel.atlempcod
                          ,m_rel.atlfunmatnum

          output to report bdbsr530_rel_Mensal()

    end foreach                              
  
  finish report bdbsr530_rel_Mensal   
 
  end function
  
#---------------------------------------------------------
  report bdbsr530_rel_Mensal()
#---------------------------------------------------------

   define l_cgccpf    char(19)
   
   output
    left   margin    00
    right  margin    00
    top    margin    00
    bottom margin    00
    page   length    07

   
   format


	 
   first page header
         print column 001,"Numero do Servico " 
                ,ascii(9),"Ano do Servico "   
                ,ascii(9),"Codigo da assistencia" 
                ,ascii(9),"Data de Atendimento " 
                ,ascii(9),"Tipo Atendente" 
                ,ascii(9),"Matricula Atendente" 
      
   on every row

      print column 001,m_rel.atdsrvnum  using "###&&&&&&&&&"
                      ,ascii(9),m_rel.atdsrvano  using "&&"
                      ,ascii(9),m_rel.asitipcod 
                      ,ascii(9),m_rel.atddat 
                      ,ascii(9),m_rel.atlusrtipcod
                      ,ascii(9),m_rel.atlfunmatnum 

  end report

 #----------------------------------------------------------------------------
 function bdbsr530_envia_email()
 #----------------------------------------------------------------------------
 
    #Arquivos de extração                         
                                                  
    define l_chave  like iddkdominio.cponom 


    define l_assunto    char(100)
 
    define l_cmd        char(5000)
          ,l_log        char(300) 
          ,l_erro_envio smallint

    let l_cmd   = null
    let l_log   = null
    let l_chave = "bdbsr530" 

    # COMPACTA ARQUIVO GERADO

    let l_cmd = "gzip -f " , m_arqMensal
    run l_cmd

    # let m_arqMensal = m_arqMensal  clipped, ".gz "

    initialize l_cmd to null

    display ''
    let l_log = 'Inicio do envio do email: ',today,' as: ',time
    display l_log

    #Diretorio dos arquivos                       
 
    let l_assunto = "Relatorio Mensal  de Sugestao de Cadastro "

    let l_erro_envio = ctx22g00_envia_email("BDBSR530",l_assunto,m_arqMensal)
       
     if l_erro_envio <> 0 then
        if  l_erro_envio <> 99 then
            display "Erro ao enviar email(ctx22g00) - ", l_erro_envio
        else
            display "Nao existe email cadastrado para o modulo - BDBSR530"
        end if
     end if 

end function 
