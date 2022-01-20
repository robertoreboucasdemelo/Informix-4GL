#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts64m03                                                   #
#Analista Resp : Roberto Reboucas                                           #
#                Quantidade de Locacao por Motivo                           #
#...........................................................................#
#Desenvolvimento: R.Fornax                                                  #
#Liberacao      : 20/08/2014                                                #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_cts64m03_prep smallint
define m_qtd           smallint

#--------------------------#
function cts64m03_prepare()
#--------------------------#
 define l_sql char(600)

 let l_sql = "select a.atdsrvnum ,"
            ,"       a.atdsrvano "
            ,"from datmservico a, "
            ,"     datmligacao b, "
            ,"     datrligitaaplitm d "
            ,"where a.atdsrvnum = b.atdsrvnum "
            ,"and a.atdsrvano = b.atdsrvano "
            ,"and b.lignum    = d.lignum "
            ,"and d.itaciacod = ? "
            ,"and d.itaramcod = ? "
            ,"and d.itaaplnum = ? "
            ,"and d.itaaplitmnum = ? "               
 prepare p_cts64m03_001 from l_sql
 declare c_cts64m03_001 cursor for p_cts64m03_001
 
 
 let l_sql =  ' select aviprvent     '                  
             ,' from datmavisrent    '
             ,' where atdsrvnum = ?  '             
             ,' and atdsrvano = ?    '
             ,' and avialgmtv = ?    '                          

 prepare p_cts64m03_002 from l_sql
 declare c_cts64m03_002 cursor for p_cts64m03_002  
  
 let m_cts64m03_prep = true

end function


#----------------------------------------#
function cts64m03_qtd_servico(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    itaciacod    like datmitaapl.itaciacod   
   ,itaramcod    like datmitaapl.itaramcod   
   ,itaaplnum    like datmitaapl.itaaplnum      
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum 
   ,avialgmtv    like datmavisrent.avialgmtv
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_cts64m03_prep is null or
    m_cts64m03_prep <> true then        
    call cts64m03_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null  
 let m_qtd       = 0

    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.itaaplnum is not null then
                               
       open c_cts64m03_001 using lr_entrada.itaciacod
                                ,lr_entrada.itaramcod
                                ,lr_entrada.itaaplnum
                                ,lr_entrada.itaaplitmnum
       
       
       foreach c_cts64m03_001 into lr_servico.*        
          call cts64m03_consiste_servico(lr_servico.*, lr_entrada.avialgmtv)       
       end foreach
       
       close c_cts64m03_001
    
    end if      

 return m_qtd

end function


#---------------------------------------------#
function cts64m03_consiste_servico(lr_entrada)
#---------------------------------------------#
 define lr_entrada record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,avialgmtv like datmavisrent.avialgmtv
 end record

 define l_resultado smallint
       ,l_mensagem  char(60)
       ,l_atdetpcod like datmsrvacp.atdetpcod
       ,l_qtd       smallint

 initialize l_resultado to  null
 initialize l_mensagem  to  null
 initialize l_atdetpcod to  null
 
 let l_qtd = 0 

 if not m_cts64m03_prep then
    call cts64m03_prepare()
 end if

 ##-- Obtem a ultima etapa do servico --##
 let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                        ,lr_entrada.atdsrvano)
 
 ##-- Para servico a residencia, conta servicos Liberados(1) e Acionados(3)     

 if  l_atdetpcod  = 1   or               
     l_atdetpcod  = 3   then               
    let l_resultado = 1           
 else
    let l_resultado = 0           
 end if                  
 
 
 if l_resultado = 1 then 
    whenever error continue 
    open c_cts64m03_002 using lr_entrada.atdsrvnum,
                              lr_entrada.atdsrvano,
                              lr_entrada.avialgmtv
    fetch c_cts64m03_002 into l_qtd
    whenever error stop 
        
    let m_qtd = m_qtd + l_qtd 
    
    close c_cts64m03_002
 end if    


end function