#############################################################################
# Nome do Modulo: bdbsr007                                         Beatriz  #
#                                                                   Araujo  #
# Relatorio diario de ligacoes da Ura da central de operacoes      Nov/2012 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

 define m_data char(010)
               
 define m_path char(100)
 define m_path_2 char(100)

 main
 
    call fun_dba_abre_banco("CT24HS") 

    set isolation to dirty read

    let m_path = f_path("DBS","LOG")
    if m_path is null then
       let m_path = "."
    end if
    let m_path = m_path clipped,"/bdbsr007.log"

    call startlog(m_path)
    
    let m_path_2 = f_path("DBS","RELATO")
    if m_path_2 is null then
       let m_path_2 = "."
    end if
    let m_path_2 = m_path_2 clipped,"/bdbsr007.xls"
    
    call bdbsr007()
    
    
    # envia o arquivo por e-mail
    
    call bdbsr007_email(m_path_2,"Relatorio diario de ligacoes priorizaadas na URA C.O.")
       
 end main



#------------------------------------------------------
 function bdbsr007_prepare()
#------------------------------------------------------

define l_sql char(500)
   let l_sql = "select atdsrvnum,",
               "       atdsrvano,",
               "       lighordat,",
               "       atdsrvorg,",
               "       ciaempcod,",
               "       c24astcod,",
               "       pstcoddig,",
               "       atdvclsgl,",
               "       srrcoddig,",
               "       ligpddcod ",
               "  from datkuraligcad",
               " where date(lighordat) = ?"

    prepare pbdbsr007001 from l_sql
    declare cbdbsr007001 cursor for pbdbsr007001
    
    let l_sql = "select c24astdes ",
                "  from datkassunto",
                " where c24astcod = ?"
    prepare pbdbsr007002 from l_sql
    declare cbdbsr007002 cursor for pbdbsr007002
    
    
    let l_sql = "select nomgrr ",
                "  from dpaksocor",
                " where pstcoddig = ?"
    prepare pbdbsr007003 from l_sql
    declare cbdbsr007003 cursor for pbdbsr007003
    
    
    let l_sql = "select srrabvnom ", 
                "  from datksrr",
                " where srrcoddig = ?"
    prepare pbdbsr007004 from l_sql
    declare cbdbsr007004 cursor for pbdbsr007004

                
    let l_sql = "select atdlibdat,", 
                "       atdlibhor,",
                "       atddatprg,",
                "       atdhorprg,",
                "       atdhorpvt ",
                "  from datmservico",                            
                " where atdsrvnum = ?", 
                "   and atdsrvano = ?"                     
    prepare pbdbsr007005 from l_sql                          
    declare cbdbsr007005 cursor for pbdbsr007005             
                
 
end function

#---------------------------------------------------------------
 function bdbsr007()
#---------------------------------------------------------------

 define d_bdbsr007    record
    
    atdsrvnum   like datkuraligcad.atdsrvnum,     
    atdsrvano   like datkuraligcad.atdsrvano,     
    lighordat   like datkuraligcad.lighordat,            
    atdsrvorg   like datkuraligcad.atdsrvorg,     
    ciaempcod   like datkuraligcad.ciaempcod,     
    c24astcod   like datkuraligcad.c24astcod,     
    c24astdes   like datkassunto.c24astdes  ,
    pstcoddig   like datkuraligcad.pstcoddig, 
    nomgrr      like dpaksocor.nomgrr       ,
    atdvclsgl   like datkuraligcad.atdvclsgl,     
    srrcoddig   like datkuraligcad.srrcoddig,
    srrabvnom   like datksrr.srrabvnom      ,     
    ligpddcod   like datkuraligcad.ligpddcod,
    atdlibdat   like datmservico.atdlibdat  ,
    atdlibhor   like datmservico.atdlibhor  ,
    atddatprg   like datmservico.atddatprg  ,
    atdhorprg   like datmservico.atdhorprg  ,
    atdhorpvt   like datmservico.atdhorpvt  
 end record
 
 define lr_hora record
   hora      char(2),
   minuto    char(2),
   combinada datetime year to minute
 
 end record

 define l_data date

#---------------------------------------------------------------
# Inicializacao das variaveis
#---------------------------------------------------------------

 initialize d_bdbsr007.*  to null
 initialize lr_hora.*,
            l_data to null
 
#---------------------------------------------------------------
# Abre os cursores 
#---------------------------------------------------------------
 call bdbsr007_prepare()
 
 
#---------------------------------------------------------------
# Data para execucao
#---------------------------------------------------------------

 let l_data = arg_val(1)

 if l_data is null  or
    l_data =  "  "  then
      let l_data = today - 1 units day
 else
    if length(l_data) < 10  then
       display "                      *** ERRO NO PARAMETRO: DATA INVALIDA! ***"
       exit program
    end if
 end if

 #---------------------------------------------------------------
 # Abre relatorio
 #---------------------------------------------------------------
 
 start report rep_bdbsr007 to m_path_2
 
 #---------------------------------------------------------------
 # Inicio da leitura principal
 #---------------------------------------------------------------
 
 display "l_data: ",l_data
 
 
 open cbdbsr007001 using l_data 
 
 foreach cbdbsr007001  into d_bdbsr007.atdsrvnum,
                            d_bdbsr007.atdsrvano,
                            d_bdbsr007.lighordat,
                            d_bdbsr007.atdsrvorg,
                            d_bdbsr007.ciaempcod,
                            d_bdbsr007.c24astcod,
                            d_bdbsr007.pstcoddig,
                            d_bdbsr007.atdvclsgl,
                            d_bdbsr007.srrcoddig,
                            d_bdbsr007.ligpddcod
 
        
         open  cbdbsr007002 using d_bdbsr007.c24astcod
         fetch cbdbsr007002 into d_bdbsr007.c24astdes
         close cbdbsr007002
         
         open  cbdbsr007003 using d_bdbsr007.pstcoddig 
         fetch cbdbsr007003 into d_bdbsr007.nomgrr
         close cbdbsr007003
         
         open  cbdbsr007004 using d_bdbsr007.srrcoddig 
         fetch cbdbsr007004 into d_bdbsr007.srrabvnom
         close cbdbsr007004
         
         open  cbdbsr007005 using d_bdbsr007.atdsrvnum,
                                  d_bdbsr007.atdsrvano
         fetch cbdbsr007005 into  d_bdbsr007.atdlibdat,
                                  d_bdbsr007.atdlibhor,
                                  d_bdbsr007.atddatprg,
                                  d_bdbsr007.atdhorprg,
                                  d_bdbsr007.atdhorpvt 
         close cbdbsr007005
         
         
         if d_bdbsr007.atdhorprg is null then
           
           if d_bdbsr007.atdhorpvt is not null then
              let lr_hora.hora = extend(d_bdbsr007.atdhorpvt, hour to hour)
              let lr_hora.minuto = extend(d_bdbsr007.atdhorpvt, minute to minute)
              let lr_hora.combinada = d_bdbsr007.atdlibhor +  
                                      lr_hora.hora units hour +
                                      lr_hora.minuto units minute
               
              display "d_bdbsr007.atdsrvnum: ",d_bdbsr007.atdsrvnum
              display "d_bdbsr007.atdsrvano: ",d_bdbsr007.atdsrvano
              display "lr_hora.hora     : ",lr_hora.hora      
              display "lr_hora.minuto   : ",lr_hora.minuto    
              display "lr_hora.combinada: ",lr_hora.combinada
              
           else
              let lr_hora.combinada = d_bdbsr007.atdlibhor
           end if
                   
         else
            let lr_hora.combinada = d_bdbsr007.atdhorprg
         end if                             
         
         output to report rep_bdbsr007(d_bdbsr007.atdsrvnum,
                                       d_bdbsr007.atdsrvano,
                                       d_bdbsr007.lighordat,
                                       d_bdbsr007.atdsrvorg,
                                       d_bdbsr007.ciaempcod,
                                       d_bdbsr007.c24astcod,
                                       d_bdbsr007.c24astdes,
                                       d_bdbsr007.pstcoddig,
                                       d_bdbsr007.nomgrr   ,
                                       d_bdbsr007.atdvclsgl,
                                       d_bdbsr007.srrcoddig,
                                       d_bdbsr007.srrabvnom,
                                       d_bdbsr007.ligpddcod,
                                       d_bdbsr007.atdlibdat,
                                       d_bdbsr007.atdlibhor,
                                       d_bdbsr007.atddatprg,
                                       d_bdbsr007.atdhorprg,
                                       d_bdbsr007.atdhorpvt,
                                       lr_hora.combinada)
                                       
    initialize d_bdbsr007.*  to null
 
 end foreach

 end function  ###  bdbsr007

#---------------------------------------------------------------------------
 report rep_bdbsr007(param)
#---------------------------------------------------------------------------
  
 define param    record
    
    atdsrvnum      like datkuraligcad.atdsrvnum,     
    atdsrvano      like datkuraligcad.atdsrvano,     
    lighordat      like datkuraligcad.lighordat,            
    atdsrvorg      like datkuraligcad.atdsrvorg,     
    ciaempcod      like datkuraligcad.ciaempcod,     
    c24astcod      like datkuraligcad.c24astcod,     
    c24astdes      like datkassunto.c24astdes  ,
    pstcoddig      like datkuraligcad.pstcoddig, 
    nomgrr         like dpaksocor.nomgrr       ,
    atdvclsgl      like datkuraligcad.atdvclsgl,     
    srrcoddig      like datkuraligcad.srrcoddig,
    srrabvnom      like datksrr.srrabvnom      ,     
    ligpddcod      like datkuraligcad.ligpddcod,
    atdlibdat      like datmservico.atdlibdat  ,
    atdlibhor      like datmservico.atdlibhor  ,
    atddatprg      like datmservico.atddatprg  ,
    atdhorprg      like datmservico.atdhorprg  ,
    atdhorpvt      like datmservico.atdhorpvt  ,
    hora_combinada like datmservico.atdlibhor
     
 end record 
  
   output
    left   margin  00
    right  margin  00
    top    margin  00
    bottom margin  00
 
 format

  first page header
  
     print "NUMERO DO SERVICO   ", ASCII(9);
     print "ANO DO SERVICO      ", ASCII(9);
     print "DATA HORA DA LIGACAO", ASCII(9);
     print "ORIGEM DO SERVICO   ", ASCII(9);
     print "EMPRESA             ", ASCII(9);
     print "CODIGO DO ASSUNTO   ", ASCII(9);
     print "DESCRICAO DO ASSUNTO", ASCII(9);
     print "CODIGO DO PRESTADOR ", ASCII(9);
     print "NOME DE GUERRA      ", ASCII(9);
     print "SIGLA DO VEICULO    ", ASCII(9);
     print "CODIGO DO SOCORRISTA", ASCII(9);
     print "NOME ABREVIADO      ", ASCII(9);
     print "DATA LIBERACAO      ", ASCII(9);
     print "HORA LIBERACAO      ", ASCII(9);
     print "DATA PROGRAMADA     ", ASCII(9);
     print "HORA PROGRAMADA     ", ASCII(9);
     print "PREVISAO INFORMADA  ", ASCII(9);
     print "HORA COMBINADA      ",ASCII(9); 
     print "CODIGO DA PRIORIDADE", ASCII(9)
  
  on every row
        
        print  param.atdsrvnum     , ASCII(9); 
        print  param.atdsrvano     , ASCII(9);
        print  param.lighordat     , ASCII(9);
        print  param.atdsrvorg     , ASCII(9);
        print  param.ciaempcod     , ASCII(9);
        print  param.c24astcod     , ASCII(9);
        print  param.c24astdes     , ASCII(9);
        print  param.pstcoddig     , ASCII(9);
        print  param.nomgrr        , ASCII(9);
        print  param.atdvclsgl     , ASCII(9);
        print  param.srrcoddig     , ASCII(9);
        print  param.srrabvnom     , ASCII(9);
        print  param.atdlibdat     , ASCII(9);
        print  param.atdlibhor     , ASCII(9);
        print  param.atddatprg     , ASCII(9);
        print  param.atdhorprg     , ASCII(9);
        print  param.atdhorpvt     , ASCII(9);
        print  param.hora_combinada, ASCII(9);
        print  param.ligpddcod     , ASCII(9)
  
 end report  ###  rep_bdbsr007
 
 
 
 
 #=============================================================================
function bdbsr007_email(param)
#=============================================================================
 
 define param record
    path        char(100),     
    descricao   char(100)
 end record
 
 define l_comando    char(200),
        l_retorno    smallint
 
 
 whenever error continue
    let l_comando = "gzip -c ", param.path clipped ," > ",param.path clipped, ".gz" 
    run l_comando
    let param.path = param.path clipped, ".gz"
     
    let l_retorno = ctx22g00_envia_email("BDBSR007", param.descricao, param.path)
    if l_retorno <> 0 then
       if l_retorno <> 99 then
          display "Erro de envio de email(cx22g00)- ",param.path
       else
          display "Nao ha email cadastrado para o modulo BDBSR007 "
       end if
    end if
 whenever error stop 

end function 
