#-----------------------------------------------------------------------------#
# Sistema....: Porto Socorro                                                  #
# Modulo.....: bdbsr114                                                       #
# Analista Resp.: Beatriz Araujo                                              #
# PSI......: PSI-2010-02124-PR - Relatorio/Arquivo de provisionamento Itau    #
#                     carga: Arquivo txt                                      #
#                     res  : Documento com resumo de pagamento                #
# --------------------------------------------------------------------------- #
# Desenvolvimento: Beatriz Araujo                                             #
# Liberacao...: 29/07/2011                                                    #
# --------------------------------------------------------------------------- #
#                                 Alteracoes                                  #
# --------------------------------------------------------------------------- #
# Data        Autor           Origem     Alteracao                            #
# ----------  --------------  ---------- -------------------------------------#
# 15/04/2013  Jorge Modena PSI-2013-08022EV Variar o Valor do Provisionamento #
#                                            por Origem do Serviço            #
#-----------------------------------------------------------------------------#
# 08/06/2015  RCP, Fornax     RELTXT     Criar versao .txt dos relatorios.    #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_data        char(10) ,
       m_patharq     char(100),
       m_pathres     char(100),
       m_pathresex   char(100),
       m_pathresumo  char(100),
       m_pathtxt2    char(100), #--> RELTXT
       m_datautil    char(10) ,
       m_valorPRV    decimal(16,2) ,
       m_valorTotPRV decimal(16,2) ,
       m_seqArq      like datkgeral.grlinf,
       m_path2       char(100),
       m_texto       char(400),
       m_tiposql     smallint,
       m_desc        like iddkdominio.cpodes


define m_total record     
       prc     integer, 
       prv     integer, 
       errprv  integer, 
       antprv  integer, 
       srvdsp  integer  
end record              


#------------------------------
main
#------------------------------
  define l_pathtxt    char(100),
         l_ciaempcod  smallint ,
         l_hostname   char(3)  ,
         l_comando    char(200),
         l_retorno    smallint 
         

 #------------------------------------------------------------
 # inicializa as variaveis
 #------------------------------------------------------------
  initialize l_pathtxt,l_ciaempcod,l_hostname,l_comando,l_retorno  to null 
  
 #------------------------------------------------------------
 # Abre conexao com o banco de dados e pega o caminho do arquivo e log
 #------------------------------------------------------------
   call fun_dba_abre_banco("CT24HS")

   set isolation to dirty read

   let m_path2 = f_path("DBS","LOG")
   if m_path2 is null then
      let m_path2 = "."
   end if

   let m_path2 = m_path2 clipped, "bdbsr114.log"
   call startlog(m_path2)
   
   display "Log: ",m_path2
   
   let m_patharq = f_path("DBS", "ARQUIVO")
   if m_patharq is null then
      let m_patharq = "."
   end if  
   
   # quando for executar eventual tirar o comentario 
   #para gerar os arquivos no lugar correto
   #let m_patharq ="/adbs" 
   
   # inicializa a sequencia
   let m_seqArq = null
   let m_tiposql = 0
   

 #------------------------------------------------------------      
 # verifica a data para o processamento
 #------------------------------------------------------------      
  let m_data = arg_val(1)
  let m_seqArq = arg_val(2) 
  let m_tiposql = arg_val(3) 

  ##  Verifica data recebida como parametro  ##
  if m_data is null or
     m_data = " "   then
      let m_data = today - 1
  else
     if m_data > today then
         display "*** ERRO NO PARAMETRO: DATA INVALIDA! *** ", m_data
         exit program
     end if
  end if

  display 'Data referencia: ', m_data
 
  #------------------------------------------------------------      
  # Cria o caminho juntamente com o nome do arquivo
  #------------------------------------------------------------      
  let l_pathtxt = m_patharq clipped,"/ITAU.PRV.", m_data[7,10], m_data[4,5], m_data[1,2], ".txt"
  let m_pathtxt2 = m_patharq clipped,"/ITAU.PRV.", m_data[7,10], m_data[4,5], m_data[1,2], ".02.txt" #--> RELTXT
  let m_pathresex = m_patharq clipped,"/PRV_ITAU_", m_data[7,10], m_data[4,5], m_data[1,2], ".xls"
  let m_pathresumo = m_patharq clipped,"/PRV_ITAU_", m_data[7,10], m_data[4,5], m_data[1,2], ".txt"
  

  display 'Arquivos:'
  display 'l_pathtxt: ', l_pathtxt clipped
  display 'm_pathtxt2: ', m_pathtxt2 clipped #--> RELTXT
  display "m_pathresex: ", m_pathresex clipped
  display "m_pathresumo: ", m_pathresumo clipped
 
  #------------------------------------------------------------ 
  # Cria o prepare
  #------------------------------------------------------------ 
     call bdbsr114_prepare()
   
  #------------------------------------------------------------ 
  # Inicializa os contadores
  #------------------------------------------------------------  
    initialize m_total.* to null
    
    let m_total.prc    = 0
    let m_total.prv    = 0
    let m_total.errprv = 0
    let m_total.antprv = 0
    let m_total.srvdsp = 0 
    let m_valorPRV     = 0
    let m_valorTotPRV  = 0
    let m_texto        = null
    
  
  #------------------------------------------------------------ 
  # Abre o relatorio
  #------------------------------------------------------------ 

     start report bdbsr114_resumo to m_pathresumo  # abre o relatorio de erro que sera enviado

     call bdbsr114(l_pathtxt)

   display 'Relatorio finalizado'
     
    #-----------------------------------------------------
    # Update para atualizar a ultima versão enviada
    #-----------------------------------------------------
    whenever error continue 
       execute pbdbsr114007 using m_seqArq
    whenever error stop
  
    display "------------------------------------------------------------"
    display " RESUMO - BDBSR114(provisionamento de servicos):"
    display " Servicos processados..............: ", m_total.prc    using "####&&"
    display " Servicos provisionamento OK.......: ", m_total.prv    using "####&&"
    display " Servicos com erro.................: ", m_total.errprv using "####&&" 
    display " Servicos desprezados..............: ", m_total.srvdsp using "####&&" 
    display "------------------------------------------------------------"
    
    let m_texto = "------------------------------------------------------------"
    output to report bdbsr114_resumo(m_texto clipped)
    let m_texto = " RESUMO - BDBSR114(provisionamento de servicos):"
    output to report bdbsr114_resumo(m_texto clipped)
    let m_texto = " Servicos processados..............: ", m_total.prc    using "####&&"
    output to report bdbsr114_resumo(m_texto clipped)
    let m_texto = " Servicos provisionamento OK.......: ", m_total.prv    using "####&&"
    output to report bdbsr114_resumo(m_texto clipped)
    let m_texto = " Servicos com erro.................: ", m_total.errprv using "####&&"
    output to report bdbsr114_resumo(m_texto clipped)
    let m_texto = " Servicos desprezados..............: ", m_total.srvdsp using "####&&"
    output to report bdbsr114_resumo(m_texto clipped)
    let m_texto = "------------------------------------------------------------"        
    output to report bdbsr114_resumo(m_texto clipped)
    
    finish report bdbsr114_resumo   # fecha o relatorio de erros
    
  #------------------------------------------------------------ 
  # Envia e-mail com os pagamentos
  #------------------------------------------------------------ 
  
  call bdbsr114_email(l_pathtxt,"Arquivo de provisionamento ITAU AUTO E RESIDENCIA")
  call bdbsr114_email(m_pathresex,"Excel de provisionamento ITAU AUTO E RESIDENCIA")
  call bdbsr114_email_erro(m_pathresumo,"Erro no provisionamento para o dia: ")
  
  
      
end main


#=============================================================================
function bdbsr114_prepare()
#=============================================================================

 define sql_comando  char(800)
  
 # o cursor cbdbsr114001 estah na funcao bdbsr114()
 
   let sql_comando = " select min(lignum)  ",
                     "   from datmligacao  ",
                     "  where atdsrvnum = ?",
                     "    and atdsrvano = ?"
   prepare pbdbsr114002 from sql_comando
   declare cbdbsr114002 cursor with hold for pbdbsr114002

  let sql_comando = " select a.ligdat,          ",
                    "        a.lighorinc,       ",
                    "        b.itaciacod,       ",
                    "        b.itaramcod,       ",
                    "        b.itaaplnum,       ",
                    "        b.itaaplitmnum,    ",
                    "        b.aplseqnum,       ",
                    "        a.c24astcod        ",
                    "   from datmligacao a,     ",
                    "        outer datrligitaaplitm b ",
                    "  where a.lignum = b.lignum",
                    "    and a.lignum = ?       "
  prepare pbdbsr114003 from sql_comando
  declare cbdbsr114003 cursor with hold for pbdbsr114003
  
  let sql_comando = " select asitipdes "
                  , " from datkasitip "
                  , " where asitipcod = ? "
                  
  prepare pbdbsr114004 from sql_comando
  declare cbdbsr114004 cursor with hold for pbdbsr114004
  
  let sql_comando = " select socntzcod+1000,nvl(socntzdes,'')  ",             
                    "   from datksocntz                        ",             
                    "  where socntzcod = (select socntzcod     ",             
                    "                       from datmsrvre     ", 
                    "                      where atdsrvnum = ? ",
                    "                        and atdsrvano = ?)"
  prepare pbdbsr114005 from sql_comando                   
  declare cbdbsr114005 cursor with hold for pbdbsr114005
  
  let sql_comando = "select grlinf                 ",  
                    "  from datkgeral              ",  
                    " where grlchv ='BDBDR114_PRVARQ'"  
              
  prepare pbdbsr114006 from sql_comando               
  declare cbdbsr114006 cursor with hold for pbdbsr114006 
  
  let sql_comando = "update datkgeral", 
                    "   set grlinf = ?",
                    " where grlchv ='BDBDR114_PRVARQ'"                
  prepare pbdbsr114007 from sql_comando  
  
  # o cursor cbdbsr114008 estah na funcao bdbsr114_trsrvce()
  
    
    ## Verifica se o prestador e acionado pelo radio //
    let sql_comando = " select pstcoddig "
                     ,"   from datkveiculo  "
                     ," where pstcoddig = ?  "
                     ,"   and socctrposflg = 'S'  "
                     ,"   and socoprsitcod in(1,2) "

    prepare pbdbsr114009 from sql_comando
    declare cbdbsr114009 cursor with hold for pbdbsr114009
    
    ## Verifica se o prestador e pessoa juridica //
    let sql_comando = " select pestip "
               ,"   from dpaksocor  "
               ," where pstcoddig = ? "
    prepare pbdbsr114010 from sql_comando
    declare cbdbsr114010 cursor with hold for pbdbsr114010
    
                                                               
    ### // Seleciona os dados da tarifa de locação //      
    let sql_comando = "  select prtsgrvlr, diafxovlr "           
                     ,"    from  datklocaldiaria  "              
                     ,"   where avivclcod    = ? "    #Codigo do veiculo            
                     ,"     and lcvlojtip    = ? "    #Tipo da loja de locacao de veiculos         
                     ,"     and lcvregprccod = ? "    #Codigo regional da locadora de veiculos          
                     ,"     and lcvcod       = ? "    #Codigo da locadora de veiculos           
                     ,"     and ? between viginc and vigfnl " #Data de Inicio e Fim de Vigencia   
                     ,"     and ? between fxainc and fxafnl " #faixa inicial e Final               
                                                           
    prepare pbdbsr114011 from sql_comando                        
    declare cbdbsr114011 cursor for pbdbsr114011  
    
    let sql_comando = "select a.avivclcod  , ",      
                      "       a.lcvcod     , ",  
                      "       a.aviprvent  , ",  
                      "       b.lcvlojtip  , ",  
                      "       b.lcvregprccod,", 
                      "       a.avidiaqtd,   ", 
                      "       a.avivclvlr    ",
                      "  from datmavisrent a,     ",  
                      "       datkavislocal b     ",  
                      " where a.lcvcod = b.lcvcod ",  
                      "   and a.aviestcod = b.aviestcod",  
                      "   and a.atdsrvnum = ?          ",  
                      "   and a.atdsrvano = ?          "  
         
     prepare pbdbsr114012 from sql_comando        
     declare cbdbsr114012 cursor for pbdbsr114012
     
     let sql_comando = "select cidnom,",
                       "       ufdcod,",
                       "       brrnom ",
                       "  from datmlcl",
                       " where atdsrvnum = ?",
                       "   and atdsrvano = ?",
                       "   and c24endtip = 1"
     prepare pbdbsr114013 from sql_comando       
     declare cbdbsr114013 cursor for pbdbsr114013 
     
     
     let sql_comando = "select cpodes",              
                       "  from iddkdominio",         
                       " where cponom = 'ITAPRVETAPA'"
     prepare pbdbsr114014 from sql_comando       
     declare cbdbsr114014 cursor for pbdbsr114014
      
     let sql_comando = " select cpodes"
                      ,"   from iddkdominio"
                      ,"  where cponom = 'MTVPRV'"
                      ,"    and cpocod = 84"
     prepare pbdbsr114015 from sql_comando              
     declare cbdbsr114015 cursor for pbdbsr114015  
     
     
     let sql_comando = "update iddkdominio",
                       "   set cpodes = ?",           
                       " where cponom = 'ITAPRVETAPA'" 
     prepare pbdbsr114016 from sql_comando             
        
        
     let sql_comando = "select c24astagp   ",
                       "  from datkassunto ",
                       " where c24astcod = ?"
     prepare pbdbsr114017 from sql_comando       
     declare cbdbsr114017 cursor for pbdbsr114017
     
     
      let sql_comando  = "select cpodes                     ",                    
                  "from iddkdominio                  ",
                  "where cponom = 'valor_padrao'     ",          
                  "and cpocod = ?                    "
               
     prepare pbdbsr114018 from sql_comando             
     declare cbdbsr114018 cursor for pbdbsr114018  
   
   
     let sql_comando  = "select grlinf                     ",   
                  "from datkgeral                    ",
                  "where grlchv = 'PSOVLRPDRPVS'     "   
               
     prepare pbdbsr114019 from sql_comando             
     declare cbdbsr114019 cursor for pbdbsr114019
     
     
    
end function
    
    
#=============================================================================
function bdbsr114_email(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
    let l_comando = "gzip -c ", param.path clipped ," > ",param.path clipped, ".gz" 
    run l_comando
    let param.path = param.path clipped, ".gz"
     
    let l_retorno = ctx22g00_envia_email("BDBSR114", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsr114 "
       end if
    end if
 whenever error stop 

end function 

#=============================================================================
function bdbsr114_email_erro(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(50)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
     
    let param.descricao = param.descricao clipped, m_data 
    let l_retorno = ctx22g00_mail_anexo_corpo("BDBSR114", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo bdbsr114 "
       end if
    end if    
 whenever error stop 

end function 


#=============================================================================
function bdbsr114(l_pathtxt)
#=============================================================================

define l_pathtxt    char(100)

  define d_bdbsr114   record
     atdsrvorg     like datmservico.atdsrvorg,           
     atdsrvnum     like datmservico.atdsrvnum,           
     atdsrvano     like datmservico.atdsrvano,           
     pgtdat        like datmservico.pgtdat   ,           
     srvprlflg     like datmservico.srvprlflg,           
     pstcoddig     like datmsrvacp.pstcoddig,           
     cnldat        like datmservico.cnldat   ,           
     atdfnlhor     like datmservico.atdfnlhor,           
     atdfnlflg     like datmservico.atdfnlflg,           
     asitipcod     like datmservico.asitipcod,           
     atdetpcod     like datmsrvacp.atdetpcod,            
     atdetpdat     like datmsrvacp.atdetpdat,            
     atdetphor     like datmsrvacp.atdetphor,            
     lignum        like datmligacao.lignum   ,           
     ligdat        like datmligacao.ligdat   ,           
     lighorinc     like datmligacao.lighorinc,           
     itaciacod     like datmitaaplitm.itaciacod,         
     itaramcod     like datmitaaplitm.itaramcod,
     itaaplnum     like datmitaaplitm.itaaplnum,
     itaaplitmnum  like datmitaaplitm.itaaplitmnum, 
     aplseqnum     like datmitaaplitm.aplseqnum,
     c24astcod     like datmligacao.c24astcod,
     c24astagp     like datkassunto.c24astagp,
     asitipdes     like datkasitip.asitipdes,
     socntzcod     like datksocntz.socntzcod,
     socntzdes     like datksocntz.socntzdes,
     atddat        like datmservico.atddat,   
     atddatprg     like datmservico.atddatprg,
     atdhor        like datmservico.atdhor,  
     atdhorprg     like datmservico.atdhorprg,
     cidnom        like datmlcl.cidnom,
     ufdcod        like datmlcl.ufdcod,
     brrnom        like datmlcl.brrnom
  end record
  
  define lr_retorno record  
     err    smallint,       
     msgerr char(200),      
     valor  decimal(16,2)   
  end record                
  
   define l_assistencia     char(30),
          l_codigo          integer ,
          l_processa        smallint,
          l_seq             integer,
          l_dataLigacao     char(014),                          
          l_dataAcionamento char(014),
          l_dataPrestacao   char(014),
          l_tipo            char(1),
          sql_comando       char(5000),
          l_data_valida     smallint,
          l_vago            char(97),
          l_while           smallint,
          l_companhia       smallint
  
   initialize d_bdbsr114.* to null   
   
   let l_data_valida = false
   let l_seq = 1 
   let l_assistencia = 30 space
   let l_vago = 97 space 
   let l_while = 2  
   let l_companhia = 0
  
  #------------------------------------------------------------ 
  # Verifica qual foi a ultima sequencia do arquivo de provisionamento 
  # enviado para a Itau
  #------------------------------------------------------------ 
  display "m_seqArq: ",m_seqArq
  if m_seqArq is null or m_seqArq = " " then     
     whenever error continue
        open cbdbsr114006  
        fetch cbdbsr114006 into m_seqArq 
        if sqlca.sqlcode <> 0 then   
           display "sqlca.sqlcode para sequencia: ",sqlca.sqlcode
           let m_seqArq = 0        
        end if  
     whenever error stop
     
  end if 
  
  let m_seqArq = m_seqArq + 1  
  display "m_seqArq2: ",m_seqArq
  start report bdbsr114_TXT_itau to l_pathtxt # Abre o relatorio do TXT
  start report bdbsr114_TXT_itau2 to m_pathtxt2 # Abre o relatorio do TXT #--> RELTXT
  start report bdbsr114_EXE_itau to m_pathresex   # Abre o relatorio do EXE 
    
    
    
  # verifica quais etapas dos servicos devem ser enviadas no arquivo de provisionamento
  call bdbsr114_itaprvetapa() 
  
  
  # Monta o comando do cursor principal do programa
  call bdbsr114_montaSQLprincipal(m_tiposql)
      returning sql_comando   
                      
  display "sql_comando: ",sql_comando clipped
  prepare pbdbsr114001 from sql_comando                                      
  declare cbdbsr114001 cursor with hold for pbdbsr114001                     
  
  #------------------------------------------------------------
  # Cursor principal para buscar todas os servicos ITAU que devem ser provisionados          
  #------------------------------------------------------------ 
  
  case m_tiposql
     when 1
        open cbdbsr114001
     
     otherwise
        open cbdbsr114001  using m_data
        
  end case
  
  
  foreach cbdbsr114001 into  d_bdbsr114.atdsrvorg,
                             d_bdbsr114.atdsrvnum,
                             d_bdbsr114.atdsrvano,
                             d_bdbsr114.pgtdat   ,
                             d_bdbsr114.srvprlflg,
                             d_bdbsr114.pstcoddig,
                             d_bdbsr114.cnldat   ,
                             d_bdbsr114.atdfnlhor,
                             d_bdbsr114.atdfnlflg,
                             d_bdbsr114.asitipcod,
                             d_bdbsr114.atdetpcod,
                             d_bdbsr114.atdetpdat,
                             d_bdbsr114.atdetphor,
                             d_bdbsr114.atddat   ,  
                             d_bdbsr114.atddatprg,
                             d_bdbsr114.atdhor   ,  
                             d_bdbsr114.atdhorprg,
                             d_bdbsr114.cidnom,
                             d_bdbsr114.ufdcod,
                             d_bdbsr114.brrnom
                                                              
     
     # Atualiza a quantidade de servicos processados
     let m_total.prc = m_total.prc + 1  
      
     #---------------------------------------------------------------
     # Obtem o numero da ligacao do servico
     #---------------------------------------------------------------     
     whenever error continue
     open  cbdbsr114002 using d_bdbsr114.atdsrvnum, 
                              d_bdbsr114.atdsrvano 
     fetch cbdbsr114002 into  d_bdbsr114.lignum
     
     if sqlca.sqlcode <> 0 then
        # Atualiza a quantidade de servicos com Erro  
        let m_total.errprv = m_total.errprv + 1   
        let m_texto = "ERRO(",sqlca.sqlcode,") ao encontrar o numero da ligacao do servico ", d_bdbsr114.atdsrvnum,"-",d_bdbsr114.atdsrvano
        display m_texto clipped
        output to report bdbsr114_resumo(m_texto clipped)
        continue foreach
     end if 
     close cbdbsr114002
     whenever error stop
     
     #---------------------------------------------------------------
     # Obtem os dados da ligacao do servico
     #---------------------------------------------------------------     
     whenever error continue
     open  cbdbsr114003 using d_bdbsr114.lignum
     fetch cbdbsr114003 into  d_bdbsr114.ligdat   ,     
                              d_bdbsr114.lighorinc,   
                              d_bdbsr114.itaciacod,   
                              d_bdbsr114.itaramcod,   
                              d_bdbsr114.itaaplnum,   
                              d_bdbsr114.itaaplitmnum,
                              d_bdbsr114.aplseqnum,
                              d_bdbsr114.c24astcod
     if sqlca.sqlcode <> 0 then
        # Atualiza a quantidade de servicos com Erro  
        let m_total.errprv = m_total.errprv + 1   
        let m_texto = "ERRO(",sqlca.sqlcode,") ao encontrar a data da Ligacao do serviço ", d_bdbsr114.atdsrvnum,"-",d_bdbsr114.atdsrvano
        display m_texto clipped
        output to report bdbsr114_resumo(m_texto clipped)
        continue foreach
     else
        display "Ligacao: ",d_bdbsr114.lignum, " Data: ",d_bdbsr114.ligdat," Servico: ", d_bdbsr114.atdsrvnum,"-",d_bdbsr114.atdsrvano 
     end if 
     
     close cbdbsr114003
     whenever error stop
     
     if d_bdbsr114.itaciacod is null then     
        let d_bdbsr114.itaciacod = 0          
     end if                               
                                          
     if d_bdbsr114.itaramcod is null then     
        
        open  cbdbsr114017 using d_bdbsr114.c24astcod
        fetch cbdbsr114017 into d_bdbsr114.c24astagp
        close cbdbsr114017
        
        if d_bdbsr114.c24astagp = 'IRE' then
           let d_bdbsr114.itaramcod = 14
        else
           let d_bdbsr114.itaramcod = 31
        end if
     end if                               
                                          
     if d_bdbsr114.itaaplnum is null then  
        let d_bdbsr114.itaaplnum = 0       
     end if  
     
     if d_bdbsr114.itaaplitmnum is null then  
        let d_bdbsr114.itaaplitmnum = 0       
     end if  
       
     if d_bdbsr114.itaciacod = 0 then     
       select count(distinct itaciacod) 
         into l_companhia
         from datrligitaaplitm
        where itaramcod = d_bdbsr114.itaramcod
          and itaaplnum = d_bdbsr114.itaaplnum
          and aplseqnum = d_bdbsr114.aplseqnum
          and itaaplitmnum = d_bdbsr114.itaaplitmnum 
          and itaciacod <> 0
       display "l_companhia count: ",l_companhia
       if l_companhia = 1 then
          
          select distinct itaciacod 
            into l_companhia
            from datrligitaaplitm
           where itaramcod = d_bdbsr114.itaramcod                        
             and itaaplnum = d_bdbsr114.itaaplnum                        
             and aplseqnum = d_bdbsr114.aplseqnum                        
             and itaaplitmnum = d_bdbsr114.itaaplitmnum                                 
             and itaciacod <> 0  
          display "l_companhia codigo: ",l_companhia                                        
          let d_bdbsr114.itaciacod = l_companhia
       else
          let d_bdbsr114.itaciacod = 0
       end if 
     end if   
       
       
     #---------------------------------------------------------------   
     # Verifica se o servico deve ser desprezado
     #---------------------------------------------------------------     
     
     let l_processa = bdbsr114_despreza(d_bdbsr114.atdsrvorg,
                                        d_bdbsr114.atdsrvnum, 
                                        d_bdbsr114.atdsrvano, 
                                        d_bdbsr114.pgtdat   , 
                                        d_bdbsr114.srvprlflg, 
                                        d_bdbsr114.pstcoddig, 
                                        d_bdbsr114.atdetpcod, 
                                        d_bdbsr114.c24astcod, 
                                        d_bdbsr114.atdfnlflg, 
                                        d_bdbsr114.cnldat   , 
                                        d_bdbsr114.atdfnlhor)
     if not l_processa then
        # Atualiza a quantidade de servicos desprezados
        let m_total.srvdsp = m_total.srvdsp + 1
        continue foreach
     end if
     
     
     #---------------------------------------------------------------   
     # Verifica o valor do servico                  
     #---------------------------------------------------------------   
     call bdbsr114_valor_prv(d_bdbsr114.atdsrvorg,
                             d_bdbsr114.atdsrvnum,
                             d_bdbsr114.atdsrvano,
                             d_bdbsr114.atddat)
          returning lr_retorno.err,   
                    lr_retorno.msgerr,
                    lr_retorno.valor 
     
     if lr_retorno.err <> 0 or lr_retorno.valor = 0 then
        # Atualiza a quantidade de servicos com Erro  
        let m_total.errprv = m_total.errprv + 1   
        let m_texto = "ERRO:",lr_retorno.msgerr clipped," Serviço ", d_bdbsr114.atdsrvnum,"-",d_bdbsr114.atdsrvano," despresado."
        output to report bdbsr114_resumo(m_texto clipped)
        continue foreach
     end if 
     
     #---------------------------------------------------------------   
     # Verifica a assintencia/natureza do servico                
     #---------------------------------------------------------------               
     call bdbsr114_assitencia(d_bdbsr114.asitipcod,
                              d_bdbsr114.atdsrvorg,
                              d_bdbsr114.atdsrvnum,
                              d_bdbsr114.atdsrvano)
       returning l_assistencia,
                 l_codigo
           
     if l_assistencia is null or l_assistencia = ' ' then
        let m_texto = 'Nao foi encontrado assistencia para o servico: ',
                       d_bdbsr114.atdsrvnum,'-',d_bdbsr114.atdsrvano
        output to report bdbsr114_resumo(m_texto clipped) 
     end if 
     
     
     #---------------------------------------------------------------   
     # Verifica se a data da ligacao eh valida para envia para o itau
     #---------------------------------------------------------------  
     let l_data_valida =  bdbsr114_valida_data(d_bdbsr114.ligdat,
                                               d_bdbsr114.atdsrvnum,
                                               d_bdbsr114.atdsrvano,"Ligacao") 
     
     if l_data_valida then
        let l_dataLigacao = bdbsr114_data_hora(d_bdbsr114.ligdat,d_bdbsr114.lighorinc)    
     else
        let l_dataLigacao = bdbsr114_data_hora(" "," ")
     end if 
     
     #Inicializa para validar a data de acionamento
     let l_data_valida = false
     
     #---------------------------------------------------------------   
     # Verifica se a data do acionamento eh valida para envia para o itau
     #--------------------------------------------------------------- 
     let l_data_valida =  bdbsr114_valida_data(d_bdbsr114.atdetpdat,
                                               d_bdbsr114.atdsrvnum,
                                               d_bdbsr114.atdsrvano,"Acionamento") 
     if l_data_valida then
        let l_dataAcionamento = bdbsr114_data_hora(d_bdbsr114.atdetpdat,d_bdbsr114.atdetphor)   
     else
        let l_dataAcionamento = bdbsr114_data_hora(" "," ")
     end if 
      
     #Inicializa para validar a data da prestacao do servico
     let l_data_valida = false
     
     #---------------------------------------------------------------   
     # Verifica se a data da prestacao do servico eh valida para envia para o itau
     #--------------------------------------------------------------- 
     if d_bdbsr114.atddatprg is null or d_bdbsr114.atddatprg = ' ' then
        let l_data_valida =  bdbsr114_valida_data(d_bdbsr114.atddat,
                                               d_bdbsr114.atdsrvnum,
                                               d_bdbsr114.atdsrvano,"Atendimento") 
        if l_data_valida then
           let l_dataPrestacao = bdbsr114_data_hora(d_bdbsr114.atddat,d_bdbsr114.atdhor)    
        else
           let l_dataPrestacao = bdbsr114_data_hora(" "," ")
        end if 
     else
        let l_data_valida =  bdbsr114_valida_data(d_bdbsr114.atddatprg,
                                               d_bdbsr114.atdsrvnum,
                                               d_bdbsr114.atdsrvano,"Programada") 
        if l_data_valida then                                                                           
           let l_dataPrestacao = bdbsr114_data_hora(d_bdbsr114.atddatprg,d_bdbsr114.atdhorprg)
        else                                                                                        
           let l_dataPrestacao = bdbsr114_data_hora(" "," ")                                                 
        end if                                                                                      
     end if     
     
      
     #---------------------------------------------------------------  
     # Coloca o valor nas variaveis e soma o total do provisionamento                
     #---------------------------------------------------------------
     let m_valorPRV  = lr_retorno.valor 
     let m_valorTotPRV  = m_valorTotPRV + m_valorPRV
     
     
     let l_seq = l_seq + 1
     
     if d_bdbsr114.itaciacod = 0 then     
        let d_bdbsr114.itaciacod = "  "         
     end if                               
                                          
     if d_bdbsr114.itaramcod = 0 then     
        let d_bdbsr114.itaramcod = "   "          
     end if                               
                                          
     if d_bdbsr114.itaaplnum = 0 then  
        let d_bdbsr114.itaaplnum = "         "       
     end if  
     
     if d_bdbsr114.itaaplitmnum = 0 then  
        let d_bdbsr114.itaaplitmnum = "       "       
     end if  
     
         
     let l_while = 2
     while l_while <> 0
        
        display "d_bdbsr114.atdetpcod: ",d_bdbsr114.atdetpcod
        display "l_while: ",l_while
        
        # verifica se eh abertura ou cancelamento de provisionamento
        if d_bdbsr114.atdetpcod = 5 then
           display "param.atdsrvnum: ",d_bdbsr114.atdsrvnum
           display "param.atdsrvano: ",d_bdbsr114.atdsrvano
           select distinct 1 
             from datmsrvacp 
            where atdsrvnum = d_bdbsr114.atdsrvnum 
              and atdsrvano = d_bdbsr114.atdsrvano
              and atdetpcod in (3,4)
           
           if sqlca.sqlcode <> 0 then
              let l_while = 0
              let l_tipo = "C"
           else
              if l_while = 2 then
                 let l_tipo = "A"
                 let l_while = 1
              else
                 let l_seq = l_seq + 1
                 let l_tipo = "C"
                 let l_while = 0 
              end if
           end if 
        else
           let l_tipo = "A"
           let l_while = 0
        end if
        display "l_while2: ",l_while
        
        output to report bdbsr114_TXT_itau(l_seq,                  
                                           d_bdbsr114.atdsrvnum,   
                                           d_bdbsr114.atdsrvano,   
                                           l_dataLigacao,          
                                           l_dataAcionamento,      
                                           l_dataPrestacao,        
                                           d_bdbsr114.itaciacod,   
                                           d_bdbsr114.itaramcod,   
                                           d_bdbsr114.itaaplnum,   
                                           d_bdbsr114.itaaplitmnum,
                                           l_assistencia,          
                                           l_codigo,
                                           bdbsr114_valor(m_valorPRV),
                                           l_tipo,
                                           d_bdbsr114.cidnom,
                                           d_bdbsr114.ufdcod,                       
                                           d_bdbsr114.brrnom,
                                           l_vago)                                        

	#--> RELTXT (inicio)
        output to report bdbsr114_TXT_itau2(l_seq,                  
                                           d_bdbsr114.atdsrvnum,   
                                           d_bdbsr114.atdsrvano,   
                                           l_dataLigacao,          
                                           l_dataAcionamento,      
                                           l_dataPrestacao,        
                                           d_bdbsr114.itaciacod,   
                                           d_bdbsr114.itaramcod,   
                                           d_bdbsr114.itaaplnum,   
                                           d_bdbsr114.itaaplitmnum,
                                           l_assistencia,          
                                           l_codigo,
                                           bdbsr114_valor2(m_valorPRV),
                                           l_tipo,
                                           d_bdbsr114.cidnom,
                                           d_bdbsr114.ufdcod,                       
                                           d_bdbsr114.brrnom,
                                           l_vago)                                           
	#--> RELTXT (final) 

        #------------------------------------------------------------             
        # Monta a linha do relatorio  do EXE                           
        #------------------------------------------------------------ 
        output to report bdbsr114_EXE_itau(l_seq,                  
                                           d_bdbsr114.atdsrvnum,   
                                           d_bdbsr114.atdsrvano,   
                                           l_dataLigacao,          
                                           l_dataAcionamento,      
                                           l_dataPrestacao,        
                                           d_bdbsr114.itaciacod,   
                                           d_bdbsr114.itaramcod,   
                                           d_bdbsr114.itaaplnum,   
                                           d_bdbsr114.itaaplitmnum,
                                           l_assistencia,          
                                           l_codigo,
                                           bdbsr114_valor(m_valorPRV),
                                           l_tipo,
                                           d_bdbsr114.cidnom,
                                           d_bdbsr114.ufdcod,                       
                                           d_bdbsr114.brrnom)
              if l_while = 0 then
                 initialize d_bdbsr114.* to null
                 let l_tipo =  null             
                 let m_valorPRV = 0
              end if 
     end while
  end foreach      
     
   if l_seq = 1 then
      start report bdbsr114_TXT_branco to l_pathtxt       # Abre o relatorio do TXT
      output to report bdbsr114_TXT_branco(l_seq)
      finish report bdbsr114_TXT_branco        # Fecha o relatorio do TXT
   end if 
  
  
  
 finish report bdbsr114_TXT_itau  # Fecha o relatorio do TXT
 finish report bdbsr114_TXT_itau2 # Fecha o relatorio do TXT #--> RELTXT
 finish report bdbsr114_EXE_itau # Fecha o relatorio do EXE
 
 let m_total.prv = l_seq - 1
          
end function

#----------------------------------------------------------------
function bdbsr114_trsrvauto(param)
#----------------------------------------------------------------
  define param record
      atdsrvnum  like datmservico.atdsrvnum,
      atdsrvano  like datmservico.atdsrvano,
      cnldat     like datmservico.cnldat   ,
      atdfnlhor  like datmservico.atdfnlhor,
      atdetpcod  like datmsrvacp.atdetpcod,
      pstcoddig  like datmsrvacp.pstcoddig
  end record
  
  define l_pstcoddig like dpaksocor.pstcoddig
  
  define l_pestip like dpaksocor.pestip   
  
  define l_canpgtcod       dec(1,0),
         l_difcanhor       datetime hour to minute
  
  
  ### Somente etapas 4=Acionado/Final e 5=Cancelado //
  if param.atdetpcod <> 4 and
     param.atdetpcod <> 5 then
      let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado pois etapa: ",param.atdetpcod
      output to report bdbsr114_resumo(m_texto clipped)
      return false
  end if

  ### Se etapa 5=Cancelado verifica o flag de pagamento //
  if param.atdetpcod = 5 then

      
      ###  Verifica o codigo de cancelamento de pagamento //
      call ctb00g00(param.atdsrvnum,
                    param.atdsrvano,
                    param.cnldat   ,
                    param.atdfnlhor)
          returning l_canpgtcod,
                    l_difcanhor

      if l_canpgtcod <> 1 and
         l_canpgtcod <> 2 and
         l_canpgtcod <> 4 and
         l_canpgtcod <> 5 then
          let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado pois Codgo de cancelamento: ",l_canpgtcod
          output to report bdbsr114_resumo(m_texto clipped)
          return false
      end if
  else
     ###  // Verifica se o servico esta sem prestador //
     if param.pstcoddig is null then
        display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," não tem prestador, despresado."
        let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," não tem prestador, despresado."
        output to report bdbsr114_resumo(m_texto clipped)
        return false
     else
        ### // Verifica se o prestador tem tipo de Pessoa //
        open cbdbsr114010 using param.pstcoddig
        fetch cbdbsr114010 into l_pestip
        
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode < 0 then
               display "ERRO DE ACESSO cbdbsa101003, sqlcode = ", sqlca.sqlcode
               let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," desprezado pois erro ao verificar prestador: ",sqlca.sqlcode
               output to report bdbsr114_resumo(m_texto clipped)
               return false
           end if
        end if
        
        if l_pestip is null then
           display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," com prestador(",param.pstcoddig,") sem tipo pessoa, despresado."
           let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," com prestador sem tipo pessoa, despresado."
           output to report bdbsr114_resumo(m_texto clipped)
            return false
        end if   
     end if    
   end if ## // m_bdbsr114.atdetpcod = 5 //
 
 return true
 
end function

#--------------------------------------------------------------------------#
function bdbsr114_trsrvce(param)
#--------------------------------------------------------------------------#

  define param record
      atdsrvnum  like datmservico.atdsrvnum,
      atdsrvano  like datmservico.atdsrvano,
      atdetpcod  like datmsrvacp.atdetpcod,
      atdfnlflg  like datmservico.atdfnlflg
  end record
  
  define l_avialgmtv  like datmavisrent.avialgmtv ,
         l_desc       like iddkdominio.cpodes  ,
         sql_comando  char(500) 
  
  ### Somente etapa 4=Acionado/Final //
  if param.atdetpcod <> 4 and
     param.atdetpcod <> 5 then
      let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado pois etapa: ",param.atdetpcod
      output to report bdbsr114_resumo(m_texto clipped)
      return false
  end if

  ### Somente servicos finalizados //
  if param.atdfnlflg <> "S" then
      let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado pois flag de finalizacao: ",param.atdfnlflg
      output to report bdbsr114_resumo(m_texto clipped)
      return false
  end if
  
  whenever error continue
   open cbdbsr114015              
   fetch cbdbsr114015 into l_desc 
  whenever error stop 
  
  ## Recupera o motivo da locacao que tenha cadastrado no dominio //
  let sql_comando = " select avialgmtv "
                   ,"   from datmavisrent "
                   ," where atdsrvnum = ? "
                   ,"   and atdsrvano = ? "
                   ,"   and avialgmtv in (",l_desc,")"
  prepare pbdbsr114008 from sql_comando
  declare cbdbsr114008 cursor with hold for pbdbsr114008
    
  ### Recupera o motivo da locacao //
  open cbdbsr114008 using param.atdsrvnum,
                          param.atdsrvano
  fetch cbdbsr114008 into l_avialgmtv
  
    if sqlca.sqlcode = notfound or sqlca.sqlcode <> 0  then
       let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado, pois ocorreu erro ao pesquisar o motivo: ",sqlca.sqlcode
       output to report bdbsr114_resumo(m_texto clipped)
       return false
    else
       return true
    end if
  close cbdbsr114008

end function

#--------------------------------------------------------------------------#
function bdbsr114_trsrvre(param)
#--------------------------------------------------------------------------#
  define param record
      atdsrvnum  like datmservico.atdsrvnum,
      atdsrvano  like datmservico.atdsrvano,
      atdetpcod  like datmsrvacp.atdetpcod,
      c24astcod  like datmligacao.c24astcod,
      pstcoddig  like datmsrvacp.pstcoddig
  end record
  
  define l_pestip like dpaksocor.pestip
  
  ### Somente etapas 3=Acionado/Acomp e 10=Retorno //
  if param.atdetpcod <>  3 and
     param.atdetpcod <> 10 and
     param.atdetpcod <>  5 then
     let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado pois etapa: ",param.atdetpcod
     output to report bdbsr114_resumo(m_texto clipped)
     return false
  end if

  if param.c24astcod = "RET" then
     let m_texto = "Servico ",param.atdsrvnum,"-",param.atdsrvano," deprezado pois Assunto: ",param.c24astcod
     output to report bdbsr114_resumo(m_texto clipped)
     return false
  end if
  
  
  ###  // Verifica se o servico esta sem prestador //
  if param.atdetpcod <> 5 then
     if param.pstcoddig is null then
        display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," não tem prestador, despresado."
        let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," não tem prestador, despresado."
        output to report bdbsr114_resumo(m_texto clipped)
        return false
     else
        ### // Verifica se o prestador tem tipo de Pessoa //
        open cbdbsr114010 using param.pstcoddig
        fetch cbdbsr114010 into l_pestip
        
        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode < 0 then
               display "ERRO DE ACESSO cbdbsa101003, sqlcode = ", sqlca.sqlcode
               let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," desprezado pois erro ao verificar prestador: ",sqlca.sqlcode
               output to report bdbsr114_resumo(m_texto clipped)
               return false
           end if
        end if
        
        if l_pestip is null and param.pstcoddig is not null then
           display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," com prestador(",param.pstcoddig,") sem tipo pessoa, despresado."
           let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," com prestador sem tipo pessoa, despresado."
           output to report bdbsr114_resumo(m_texto clipped)
            return false
        end if   
     end if    
  end if

  return true

end function


#--------------------------------------------------------------------------#
function bdbsr114_despreza(param)
#--------------------------------------------------------------------------#
  define param record
      atdsrvorg  like datmservico.atdsrvorg,
      atdsrvnum  like datmservico.atdsrvnum,
      atdsrvano  like datmservico.atdsrvano,
      pgtdat     like datmservico.pgtdat,   
      srvprlflg  like datmservico.srvprlflg,
      pstcoddig  like datmsrvacp.pstcoddig,
      atdetpcod  like datmsrvacp.atdetpcod,
      c24astcod  like datmligacao.c24astcod,
      atdfnlflg  like datmservico.atdfnlflg,
      cnldat     like datmservico.cnldat   ,
      atdfnlhor  like datmservico.atdfnlhor
  end record
  
  define l_processa    smallint
  
  let l_processa = true
  
  case param.atdsrvorg
     when 8
        let l_processa = bdbsr114_trsrvce(param.atdsrvnum,
                                          param.atdsrvano,
                                          param.atdetpcod,
                                          param.atdfnlflg)
        
     when 9
        let l_processa = bdbsr114_trsrvre(param.atdsrvnum,
                                          param.atdsrvano,
                                          param.atdetpcod,
                                          param.c24astcod,
                                          param.pstcoddig)
     when 13
        let l_processa = bdbsr114_trsrvre(param.atdsrvnum,
                                          param.atdsrvano,
                                          param.atdetpcod,
                                          param.c24astcod,
                                          param.pstcoddig)
     otherwise
        let l_processa = bdbsr114_trsrvauto(param.atdsrvnum, 
                                            param.atdsrvano, 
                                            param.cnldat   ,
                                            param.atdfnlhor,
                                            param.atdetpcod,
                                            param.pstcoddig)
  end case
   
  ### // Verifica se tem data de pagamento //
  if param.pgtdat is not null and 
     (m_tiposql is null or m_tiposql = 0) then
      display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," tem data de pagamento, despresado."
      let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," tem data de pagamento, despresado."
      output to report bdbsr114_resumo(m_texto clipped)
      let l_processa = false
  end if

  ###  // Verifica se o servico e particular (Pago pelo cliente) //
  if param.srvprlflg = "S" then
      display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," e particular, despresado."
      let m_texto = "Serviço ", param.atdsrvnum,"-",param.atdsrvano," e particular, despresado."
      output to report bdbsr114_resumo(m_texto clipped)
      let l_processa = false
  end if
  
  
  #if param.atdetpcod = 5 then
  #   display "param.atdsrvnum: ",param.atdsrvnum
  #   display "param.atdsrvano: ",param.atdsrvano
  #   select distinct 1 
  #     from datmsrvacp 
  #    where atdsrvnum = param.atdsrvnum 
  #      and atdsrvano = param.atdsrvano
  #      and atdetpcod in (3,4)
  #   
  #   if sqlca.sqlcode <> 0 then
  #      display "Serviço ", param.atdsrvnum,"-",param.atdsrvano," cancelado e nao tem etapa de acionamento, despresado."
  #      let m_texto = "Erro: (",sqlca.sqlcode,")Serviço ", param.atdsrvnum,"-",param.atdsrvano," cancelado e nao tem etapa de acionamento, despresado."
  #      output to report bdbsr114_resumo(m_texto clipped)
  #      let l_processa = false
  #   end if 
  #end if 
  
  return l_processa
  
end function

#--------------------------------------------------------------------------
function bdbsr114_assitencia(param)
#--------------------------------------------------------------------------
  
  define param record
     asitipcod  like datmservico.asitipcod,
     atdsrvorg  like datmservico.atdsrvorg,
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano
  end record  
  
  define l_asitipdes   like datkasitip.asitipdes,
         l_socntzcod   like datksocntz.socntzcod,
         l_socntzdes   like datksocntz.socntzdes, 
         l_assistencia char(30),
         l_codigo      integer 
  
    
  let l_assistencia = null
    
  #--------------------------------------------------------------- 
  # buscar tipo de assistencia
  #--------------------------------------------------------------- 
  if param.asitipcod is null or
     param.asitipcod <= 0
     then
     #--------------------------------------------------------------- 
     # origem 8 forcado porque asitipcod nao e gravado no servico
     #--------------------------------------------------------------- 
     if param.atdsrvorg = 8
        then
        let l_asitipdes = 'LOCACAO DE VEICULO'
        let l_assistencia = l_asitipdes
        let l_codigo = 26
     end if 
  else
     whenever error continue
     open cbdbsr114004 using param.asitipcod
     fetch cbdbsr114004 into l_asitipdes
     whenever error stop
     
     let l_assistencia = l_asitipdes 
     let l_codigo      = param.asitipcod
  end if
        
  if param.atdsrvorg = 9 or param.atdsrvorg = 13 then
     
     open cbdbsr114005 using param.atdsrvnum,param.atdsrvano
     fetch cbdbsr114005 into l_socntzcod,
                             l_socntzdes 
     
     let l_assistencia = l_socntzdes 
     let l_codigo      = l_socntzcod 
                 
  end if 
  
  let l_assistencia = ctx14g00_TiraAcentos(l_assistencia)
  
  return l_assistencia,
         l_codigo     
         
end function



#--------------------------------------------------------------------------
function bdbsr114_valor_prv(param)
#--------------------------------------------------------------------------
  
  define param record
     atdsrvorg  like datmservico.atdsrvorg,
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano,
     atddat     like datmservico.atddat
  end record  
  
  define lr_retorno record
     err    smallint,
     msgerr char(200),
     valor  decimal(16,2)
  end record
  
    define l_socntzcod   smallint
    define l_vlrmaximo   dec(12,2)
    define l_vlrdiferenc dec(12,2)
    define l_vlrmltdesc  dec(12,2)
    define l_nrsrvs      smallint
    define l_flgtab      smallint
          
  #--------------------------------------------------------------- 
  # Verifica a origem de carro-extra
  #--------------------------------------------------------------- 
  display "param.atdsrvorg: ",param.atdsrvorg
  case param.atdsrvorg
    when 8 
      call bdbsr114_vlrce(param.atdsrvnum,param.atdsrvano,param.atddat)
           returning lr_retorno.err,    
                     lr_retorno.msgerr, 
                     lr_retorno.valor 
                     
    # Inicio PSI-2013-08022EV - Variar o Valor do Provisionamento por Origem do Serviço            
    #when 9
    #   call ctx15g00_vlrre(param.atdsrvnum,param.atdsrvano) 
    #                returning l_socntzcod, lr_retorno.valor, l_vlrmaximo,    
    #                          l_vlrdiferenc, l_vlrmltdesc, l_nrsrvs, l_flgtab 
    #       let  lr_retorno.err    = 0  
    #       let  lr_retorno.msgerr = " "                 
    #
    #when 13        
    #   call ctx15g00_vlrre(param.atdsrvnum,param.atdsrvano) 
    #                returning l_socntzcod, lr_retorno.valor, l_vlrmaximo,    
    #                          l_vlrdiferenc, l_vlrmltdesc, l_nrsrvs, l_flgtab 
    #                          
    #     let  lr_retorno.err    = 0  
    #     let  lr_retorno.msgerr = " "
         
    otherwise
       #call ctx15g02_vlrauto(param.atdsrvnum,param.atdsrvano)
       #     returning lr_retorno.err,   
       #               lr_retorno.msgerr,
       #               lr_retorno.valor 
                      
       
                      
       #whenever error continue
       open cbdbsr114018 using param.atdsrvorg  
           fetch cbdbsr114018 into lr_retorno.valor
       close cbdbsr114018
       display "Valor pesquisado" , lr_retorno.valor
       #whenever error stop
    
        if sqlca.sqlcode != 0 then
            #display 'OCORREU UM ERRO EM cctb00g03114 - SqlCode ',sqlca.sqlcode
            whenever error continue 
               open cbdbsr114017
                  fetch cbdbsr114017 into lr_retorno.valor
               close cbdbsr114017
               display "Valor pesquisado 2" , lr_retorno.valor
            whenever error stop    
        end if
    
    # Fim PSI-2013-08022EV - Variar o Valor do Provisionamento por Origem do Serviço
         
  end case
  
  return lr_retorno.err,   
         lr_retorno.msgerr,
         lr_retorno.valor 

         
end function

#--------------------------------------------------------------------------   
function bdbsr114_vlrce(param)                                            
#--------------------------------------------------------------------------   
   define param record
     atdsrvnum  like datmservico.atdsrvnum,
     atdsrvano  like datmservico.atdsrvano,
     atddat     like datmservico.atddat
   end record
   
   
   define lr_retorno record
     avivclcod    like datmavisrent.avivclcod ,
     lcvcod       like datmavisrent.lcvcod    ,
     aviprvent    like datmavisrent.aviprvent ,
     lcvlojtip    like datkavislocal.lcvlojtip,  
     lcvregprccod like datkavislocal.lcvregprccod,
     prtsgrvlr    like datklocaldiaria.prtsgrvlr,
     diafxovlr    like datklocaldiaria.diafxovlr,
     avidiaqtd    like datmavisrent.avidiaqtd,
     avivclvlr    like datmavisrent.avivclvlr,
     err          smallint,    
     msgerr       char(200),   
     valor        decimal(16,2)
  end record 
  
   whenever error continue 
    
     open cbdbsr114012 using param.atdsrvnum,param.atdsrvano
   
     fetch cbdbsr114012 into lr_retorno.avivclcod   , 
                             lr_retorno.lcvcod      ,
                             lr_retorno.aviprvent   ,
                             lr_retorno.lcvlojtip   ,
                             lr_retorno.lcvregprccod,
                             lr_retorno.avidiaqtd   ,
                             lr_retorno.avivclvlr
                
   whenever error stop
   
   whenever error continue 
    
     open cbdbsr114011 using lr_retorno.avivclcod, 
                             lr_retorno.lcvlojtip, 
                             lr_retorno.lcvregprccod,
                             lr_retorno.lcvcod,
                             param.atddat,
                             lr_retorno.aviprvent
     
     fetch cbdbsr114011 into lr_retorno.prtsgrvlr,
                             lr_retorno.diafxovlr
     
     if sqlca.sqlcode = 0 then
        ### // Calcula o valor do provisionamento //
        if lr_retorno.diafxovlr > 0 then
           let lr_retorno.valor = lr_retorno.diafxovlr * lr_retorno.avidiaqtd
        else
           if lr_retorno.prtsgrvlr > 0 then
              let lr_retorno.valor = lr_retorno.prtsgrvlr * lr_retorno.avidiaqtd
           else
              let lr_retorno.valor = lr_retorno.avivclvlr * lr_retorno.avidiaqtd 
           end if   
        end if 
     else
        let lr_retorno.valor = 0
        let lr_retorno.err  = sqlca.sqlcode  
        let lr_retorno.msgerr = "Erro(",sqlca.sqlcode,")ao consultar valor(bdbsr114_vlrce)"
        display "lr_retorno.err: ",lr_retorno.err
         display "lr_retorno.msgerr: ",lr_retorno.msgerr
        return lr_retorno.err   ,
               lr_retorno.msgerr,
               lr_retorno.valor 
     end if            
   whenever error stop
  display "lr_retorno.err: ",lr_retorno.err
  
  if lr_retorno.valor = 0 then
     call ctx15g02_valor_padrao(8,600.00)
     returning lr_retorno.err   ,
               lr_retorno.msgerr,
               lr_retorno.valor 
  end if
  
  let lr_retorno.err  = 0
  let lr_retorno.msgerr = " "
  return lr_retorno.err   ,
         lr_retorno.msgerr,
         lr_retorno.valor 

end function

#--------------------------------#
 function bdbsr114_valor(l_param)
#--------------------------------#

     define l_param  decimal(16,2),
            l_valor  char(018),
            l_valorInt  char(13),
            l_valorDec  char(2),
            l_return char(018),
            l_ind    smallint,
            l_pos    smallint

     display "l_param: ",l_param
     let l_valor = l_param using "<<<<<<<<<<<<<<&.&&"
     let l_return = ""

     for l_ind = 1 to length(l_valor)
         if  l_valor[l_ind] <> ',' and l_valor[l_ind] <> '.' then
             let l_return = l_return clipped, l_valor[l_ind]
         else
            let l_valorInt = l_return clipped 
            let l_return   = null
         end if
     end for
     let l_valorDec = l_return clipped 
     let l_return = "*",l_valorInt using "&&&&&&&&&&&&&","*",l_valorDec using "&&","*"
  
  return l_return

 end function
 
#--------------------------------#
 function bdbsr114_valor2(l_param)
#--------------------------------#

     define l_param  decimal(16,2),
            l_valor  char(018),
            l_valorInt  char(13),
            l_valorDec  char(2),
            l_return char(018),
            l_ind    smallint,
            l_pos    smallint

     display "l_param: ",l_param
     let l_valor = l_param using "<<<<<<<<<<<<<<&.&&"
     let l_return = ""

     for l_ind = 1 to length(l_valor)
         if  l_valor[l_ind] <> ',' and l_valor[l_ind] <> '.' then
             let l_return = l_return clipped, l_valor[l_ind]
         else
            let l_valorInt = l_return clipped 
            let l_return   = null
         end if
     end for
     let l_valorDec = l_return clipped 
     let l_return = l_valorInt using "&&&&&&&&&&&&&,",l_valorDec using "&&"
  
  return l_return

 end function
 
#------------------------------#
 function bdbsr114_valida_data(l_data,l_atdsrvnum,l_atdsrvano,l_tipo)
#------------------------------#

     define l_data      date,
            l_atdsrvnum like datmservico.atdsrvnum,
            l_atdsrvano like datmservico.atdsrvano,
            l_tipo      char(50)

     if  l_data is not null and l_data <> " " then
         if l_data < today - 1 units year or 
            l_data > today + 1 units year then
               let m_texto = "Data(",l_tipo clipped,")invalida:",l_data," do servico: ",l_atdsrvnum,'-',l_atdsrvano
               output to report bdbsr114_resumo(m_texto clipped)
               return false      
         end if 
     else
        let m_texto = "Data(",l_tipo clipped,"):",l_data," em branco do servico: ",l_atdsrvnum,'-',l_atdsrvano
        output to report bdbsr114_resumo(m_texto clipped)  
        return false    
     end if

     return true

 end function
 
 

#------------------------------#
 function bdbsr114_data_hora(m_data,m_hora)
#------------------------------#

     define m_data date,
            m_hora datetime hour to second,
            l_return char(14)

     let l_return = " "

     if  m_data is not null and m_data <> " " and 
         m_hora is not null and m_hora <> " " then
         let l_return = extend(m_data, day to day)clipped,
                        extend(m_data, month to month) clipped,
                        extend(m_data, year to year) clipped,
                        extend(m_hora, hour to hour) clipped,
                        extend(m_hora, minute to minute) clipped,
                        extend(m_hora,  second to second)
     else
        let l_return = extend(current, day to day)clipped,
                       extend(current, month to month) clipped,
                       extend(current, year to year) clipped,
                       extend(current, hour to hour) clipped,
                       extend(current, minute to minute) clipped,
                       extend(current, second to second)   
     end if

     return l_return

 end function

#--------------------------------------------------------------------------
report bdbsr114_resumo(l_linha)
#--------------------------------------------------------------------------
  define l_linha char(300)

  output
     left margin     0
     bottom margin   0
     top margin      0
     right margin  125
     page length    60

  format
     on every row
        print column 1, l_linha clipped

end report

#-------------------------------------#
report bdbsr114_TXT_itau(l_param)
#-------------------------------------#

define l_param record
       seq                 integer 
     , atdsrvnum           like datmservico.atdsrvnum
     , atdsrvano           like datmservico.atdsrvano
     , l_dataLigacao       char(14) 
     , l_dataAcionamento   char(14)
     , l_dataPrestacao     char(14) 
     , itaciacod           char(2)
     , itaramcod           char(3)
     , itaaplnum           char(9)
     , itaaplitmnum        char(7)
     , asitipdes           char(30)
     , asitipcod           integer
     , valor               char(18)
     , tipo                char(1)
     , cidnom              char(30)
     , ufdcod              char(2)
     , brrnom              char(30)
     , vago                char(97)
     
     
end record

define l_header record
       dataEnvio char(14)
end record

  output
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00
    page length    01 

  format
       
      on every row
        # Nao foi utilizado o first page header, pois ele completa com enter o que sobra da pagina
        # e a Itau soh estah esperando receber um enter apos o ultimo registro, favor nao alterar
        # para que nao ocorra problemas no envio dos arquivos
        if l_param.seq = 2 then
           let l_header.dataEnvio = bdbsr114_data_hora(" "," ")
           print column 0001, "000",
                 column 0004, "0000000001"  ,
                 column 0014, "ITAU PROVISAO PORTO SOCORRO" ,
                 column 0041, m_seqArq using '&&&&&&&',
                 column 0048, l_header.dataEnvio,
                 column 0062, "1",238 space   
        end if 
        
        print column 0001, "001"                                , # 01 CÓDIGO DA INTERFACE                                      
              column 0004, l_param.seq  using '&&&&&&&&&&'      , # 02 NO SEQUENCIAL DO REGISTRO                       
              column 0014, l_param.atdsrvano using "&&"         , # 03 ANO DO SERVICO                                
              column 0016, l_param.atdsrvnum using "&&&&&&&&&"  , # 04 NUMERO DO SERVICO                  
              column 0025, l_param.l_dataLigacao                , # 05 DATA DA LIGACAO   
              column 0039, l_param.l_dataAcionamento            , # 06 DATA DO ACIONAMENTO   
              column 0053, l_param.l_dataPrestacao              , # 07 DATA DA PRESTACAO DO SERVICO   
              column 0067, l_param.itaciacod using "&&"         , # 08 CODIGO DA COMPANHIA
              column 0069, l_param.itaramcod using "&&&"        , # 09 CODIGO DO RAMO
              column 0072, l_param.itaaplnum using "&&&&&&&&&"  , # 10 NUMERO DA APOLICE
              column 0081, l_param.itaaplitmnum using "&&&&&&&" , # 11 ITEM DA APOLICE
              column 0088, l_param.asitipcod using "&&&&&"      , # 12 CODIGO DA ASSISTENCIA
              column 0093, l_param.asitipdes                    , # 13 DESCRICAO DA ASSISTENCIA
              column 0123, l_param.valor                        , # 14 VALOR DO PROVISIONAMENTO
              column 0141, l_param.tipo                         , # 19 TIPO DO PROVISIONAMENTO
              column 0142, l_param.ufdcod                       , # 20 UF DO SERVICO
              column 0144, l_param.cidnom                       , # 21 CIDADE DO SERVICO
              column 0174, l_param.brrnom                       , # 22 BAIRRO DO SERVICO
              column 0204, l_param.vago                           # 23 VAGO
          
          
        on last row 
         print column 0001, "999",
               column 0004, l_param.seq+1 using '&&&&&&&&&&',
               column 0014, l_param.seq+1 using '&&&&&&&&&&',
               column 0024,277 space
  end report

#----------------------------------#
report bdbsr114_TXT_itau2(l_param) #--> RELTXT
#----------------------------------#

define l_param record
       seq                 integer 
     , atdsrvnum           like datmservico.atdsrvnum
     , atdsrvano           like datmservico.atdsrvano
     , l_dataLigacao       char(14) 
     , l_dataAcionamento   char(14)
     , l_dataPrestacao     char(14) 
     , itaciacod           char(2)
     , itaramcod           char(3)
     , itaaplnum           char(9)
     , itaaplitmnum        char(7)
     , asitipdes           char(30)
     , asitipcod           integer
     , valor               char(18)
     , tipo                char(1)
     , cidnom              char(30)
     , ufdcod              char(2)
     , brrnom              char(30)
     , vago                char(97)
end record

define l_header record
       dataEnvio char(14)
end record

output
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00
    page length    01 

format
  on every row
    print "001"                               ,ASCII(09) # 01 CÓDIGO DA INTERFACE
        , l_param.seq  using '&&&&&&&&&&'     ,ASCII(09) # 02 NO SEQUENCIAL DO REGISTRO
        , l_param.atdsrvano using "&&"        ,ASCII(09) # 03 ANO DO SERVICO
        , l_param.atdsrvnum using "&&&&&&&&&" ,ASCII(09) # 04 NUMERO DO SERVICO
        , l_param.l_dataLigacao               ,ASCII(09) # 05 DATA DA LIGACAO   
        , l_param.l_dataAcionamento           ,ASCII(09) # 06 DATA DO ACIONAMENTO   
        , l_param.l_dataPrestacao             ,ASCII(09) # 07 DATA DA PRESTACAO SERVICO
        , l_param.itaciacod using "&&"        ,ASCII(09) # 08 CODIGO DA COMPANHIA
        , l_param.itaramcod using "&&&"       ,ASCII(09) # 09 CODIGO DO RAMO
        , l_param.itaaplnum using "&&&&&&&&&" ,ASCII(09) # 10 NUMERO DA APOLICE
        , l_param.itaaplitmnum using "&&&&&&&",ASCII(09) # 11 ITEM DA APOLICE
        , l_param.asitipcod using "&&&&&"     ,ASCII(09) # 12 CODIGO DA ASSISTENCIA
        , l_param.asitipdes                   ,ASCII(09) # 13 DESCRICAO DA ASSISTENCIA
        , l_param.valor                       ,ASCII(09) # 14 VALOR DO PROVISIONAMENTO
        , l_param.tipo                        ,ASCII(09) # 15 TIPO DO PROVISIONAMENTO
        , l_param.ufdcod                      ,ASCII(09) # 16 UF DO SERVICO
        , l_param.cidnom                      ,ASCII(09) # 17 CIDADE DO SERVICO
        , l_param.brrnom                      ,ASCII(09) # 18 BAIRRO DO SERVICO
        , l_param.vago                                   # 19 VAGO

end report

#-------------------------------------#
report bdbsr114_EXE_itau(l_param)
#-------------------------------------#

define l_param record
       seq                 integer 
     , atdsrvnum           like datmservico.atdsrvnum
     , atdsrvano           like datmservico.atdsrvano
     , l_dataLigacao       char(14) 
     , l_dataAcionamento   char(14)
     , l_dataPrestacao     char(14) 
     , itaciacod           char(2)
     , itaramcod           char(3)
     , itaaplnum           char(9)
     , itaaplitmnum        char(7)
     , asitipdes           char(30)
     , asitipcod           integer
     , valor               char(18)
     , tipo                char(1)
     , cidnom              char(30)
     , ufdcod              char(2)
     , brrnom              char(30)
end record

define l_header record
       dataEnvio date
end record

 output
    page length    04
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format
    
     first page header  
       let l_header.dataEnvio = bdbsr114_data_hora(" "," ")
       print column 0001, "000",
             column 0004, "0000000001"  ,
             column 0014, "ITAU PROVISAO PORTO SOCORRO" ,
             column 0041, m_seqArq using '&&&&&&&',
             column 0048, l_header.dataEnvio,
             column 0062, "1",238 space
             
       print "CÓDIGO DA INTERFACE          ", ASCII(9); 
       print "NO SEQUENCIAL DO REGISTRO    ", ASCII(9);
       print "ANO DO SERVICO               ", ASCII(9);
       print "NUMERO DO SERVICO            ", ASCII(9);
       print "DATA DA LIGACAO              ", ASCII(9);
       print "DATA DO ACIONAMENTO          ", ASCII(9);
       print "DATA DA PRESTACAO DO SERVICO ", ASCII(9);
       print "CODIGO DA COMPANHIA          ", ASCII(9);
       print "CODIGO DO RAMO               ", ASCII(9);
       print "NUMERO DA APOLICE            ", ASCII(9);
       print "ITEM DA APOLICE              ", ASCII(9);
       print "CODIGO DA ASSISTENCIA        ", ASCII(9);
       print "DESCRICAO DA ASSISTENCIA     ", ASCII(9);
       print "VALOR DO PROVISIONAMENTO     ", ASCII(9);
       print "TIPO DO PROVISIONAMENTO      ", ASCII(9);
       print "UF DO SERVICO                ", ASCII(9);
       print "CIDADE DO SERVICO            ", ASCII(9);
       print "BAIRRO DO SERVICO            ", ASCII(9);
       print "VAGO                         ", ASCII(9);
       
      on last row
      print column 0001, "999",
            column 0004, l_param.seq+1 using '&&&&&&&&&&',
            column 0014, l_param.seq+1 using '&&&&&&&&&&',
            column 0024, 177 space
     
      on every row
        
        if l_param.itaciacod = 0 then     
           let l_param.itaciacod = "  "         
        end if                               
                                             
        if l_param.itaramcod = 0 then     
           let l_param.itaramcod = "   "          
        end if                               
                                             
        if l_param.itaaplnum = 0 then  
           let l_param.itaaplnum = "         "       
        end if  
        
        if l_param.itaaplitmnum = 0 then  
           let l_param.itaaplitmnum = "       "       
        end if 
        print column 0001, "001"                                , ASCII(9);# 01 CÓDIGO DA INTERFACE                                      
        print column 0004, l_param.seq  using '&&&&&&&&&&'      , ASCII(9);# 02 NO SEQUENCIAL DO REGISTRO                       
        print column 0014, l_param.atdsrvano using "&&"         , ASCII(9);# 03 ANO DO SERVICO                                
        print column 0016, l_param.atdsrvnum using "&&&&&&&&&"  , ASCII(9);# 04 NUMERO DO SERVICO                  
        print column 0025, l_param.l_dataLigacao                , ASCII(9);# 05 DATA DA LIGACAO   
        print column 0039, l_param.l_dataAcionamento            , ASCII(9);# 06 DATA DO ACIONAMENTO   
        print column 0053, l_param.l_dataPrestacao              , ASCII(9);# 07 DATA DA PRESTACAO DO SERVICO   
        print column 0067, l_param.itaciacod                    , ASCII(9);# 08 CODIGO DA COMPANHIA
        print column 0069, l_param.itaramcod                    , ASCII(9);# 09 CODIGO DO RAMO
        print column 0072, l_param.itaaplnum                    , ASCII(9);# 10 NUMERO DA APOLICE
        print column 0081, l_param.itaaplitmnum                 , ASCII(9);# 11 ITEM DA APOLICE
        print column 0088, l_param.asitipcod using "&&&&&"      , ASCII(9);# 12 CODIGO DA ASSISTENCIA
        print column 0093, l_param.asitipdes                    , ASCII(9);# 13 DESCRICAO DA ASSISTENCIA
        print column 0123, l_param.valor                        , ASCII(9);# 14 VALOR DO PROVISIONAMENTO
        print column 0141, l_param.tipo                         , ASCII(9);# 19 TIPO DO PROVISIONAMENTO
        print column 0142, l_param.ufdcod                       , ASCII(9);# 20 UF DO SERVICO
        print column 0144, l_param.cidnom                       , ASCII(9);# 21 CIDADE DO SERVICO
        print column 0174, l_param.brrnom                       , ASCII(9);# 22 BAIRRO DO SERVICO
        print column 0204, 97 spaces                                       # 23 VAGO   
                                                                                                                            
 end report 
 
#-------------------------------------#  
report bdbsr114_TXT_branco(l_param)     
#-------------------------------------#  

define l_param record 
    seq  integer 
end record


define l_header record
       dataEnvio char(14)
end record

 output
    page length    02
    left margin    00
    right margin   00
    top margin     00
    bottom margin  00

  format
       
     first page header  
     let l_header.dataEnvio = bdbsr114_data_hora(" "," ")
       print column 0001, "000",
             column 0004, "0000000001"  ,
             column 0014, "ITAU PROVISAO PORTO SOCORRO" ,
             column 0041, m_seqArq using '&&&&&&&',
             column 0048, l_header.dataEnvio,
             column 0062, "1",238 space
     
      on last row
         print column 0001, "999",
               column 0004, l_param.seq+1 using '&&&&&&&&&&',
               column 0014, l_param.seq+1 using '&&&&&&&&&&',
               column 0024, 277 space


end report                                                                                                                                                       



#------------------------------------------------------------            
# Funcao para verifica quais etapas dos servicos devem ser enviadas para a itau      
#------------------------------------------------------------            
function bdbsr114_itaprvetapa()

  #------------------------------------------------------------            
  # Busca as etapas dos servicos que devem ser enviadas para a itau      
  #------------------------------------------------------------            
     
  whenever error continue
       open cbdbsr114014
       fetch cbdbsr114014 into m_desc
       close cbdbsr114014
  whenever error stop
  
  
  #------------------------------------------------------------            
  # Verifica se não estamos gerando um arquivo com serviços 
  # cancelados que serao pagos      
  #------------------------------------------------------------     
  #if (m_tiposql is null or m_tiposql = 0) and m_data = today -1 then
  #    let m_desc = m_desc clipped, ",5"
  #    whenever error continue                   
  #       execute pbdbsr114016 using m_desc    
  #    whenever error stop                     
  #    
  #    whenever error continue          
  #       open cbdbsr114014             
  #       fetch cbdbsr114014 into m_desc
  #       close cbdbsr114014
  #    whenever error stop              
  #
  #end if 
  
  display "m_tiposql: ",m_tiposql
  display "m_desc: ",m_desc

end function



function bdbsr114_montaSQLprincipal(l_tiposql)


define l_tiposql     smallint

define sql_comando   char(5000)

let sql_comando =  "select s.atdsrvorg,",                                    
                           " s.atdsrvnum,",                                    
                           " s.atdsrvano,",                                    
                           " s.pgtdat,   ",                                    
                           " s.srvprlflg,",                                    
                           " a.pstcoddig,",                                    
                           " s.cnldat   ,",                                    
                           " s.atdfnlhor,",                                    
                           " s.atdfnlflg,",                                    
                           " s.asitipcod,",                                    
                           " a.atdetpcod,",                                    
                           " a.atdetpdat,",                                    
                           " a.atdetphor,",                                    
                           " s.atddat,   ",                                    
                           " s.atddatprg,",                                    
                           " s.atdhor,   ",                                    
                           " s.atdhorprg,",                                    
                           " v.cidnom, ",                                      
                           " v.ufdcod, ",                                      
                           " v.brrnom ",                                       
                       "from datmservico s,",                                  
                           " datmsrvacp a,  ",                                 
                           " outer datmlcl v ",                                
                     "where s.atdsrvnum = a.atdsrvnum",                        
                      " and s.atdsrvano = a.atdsrvano",                        
                      " and s.atdsrvnum = v.atdsrvnum",                        
                      " and s.atdsrvano = v.atdsrvano",                        
                      " and v.c24endtip = 1 ",                                 
                      " and s.ciaempcod = 84",                                 
                      " and a.atdetpcod is not null  ",                        
                      " and a.atdetpcod in (",m_desc clipped,")",
                      " and a.atdsrvseq = s.atdsrvseq",
                      " and s.atdsrvorg <> 10"
     
        case l_tiposql
           when 1
              let sql_comando = sql_comando clipped," and s.atdsrvnum in (4226729,4395775,4404432,4276779,4292882,4395887,4327067,",
                      " 4343069,4353626,4281126,4311325,4321193,4295287,4290837,",
                      " 4409662,4331051,4327872,4323215,4322437,4394149,4439708,",
                      " 4358364,4396463,4303501,4315018,4339558,4448537,4502258)",
                      " and s.atdsrvano = 11",
                      " order by s.atdsrvnum,s.atdsrvano,a.atdsrvseq" 
           when 2
              let sql_comando = sql_comando clipped," and s.atdsrvnum = ? and s.atdsrvano = ?",
                      " order by s.atdsrvnum,s.atdsrvano,a.atdsrvseq"    
           otherwise
              let sql_comando = sql_comando clipped," and a.atdetpdat = ? order by s.atdsrvnum,s.atdsrvano,a.atdsrvseq"   
        end case        
     
 return sql_comando


end function
