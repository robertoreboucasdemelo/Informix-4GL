#---------------------------------------------------------------------------#
#Porto Seguro Cia Seguros Gerais                                            #
#...........................................................................#
#Sistema       : Central 24hs                                               #
#Modulo        : cts61m02                                                   #
#Analista Resp : Roberto Reboucas                                           #
#                Tela de laudos de residencia                               #
#...........................................................................#
#Desenvolvimento: Amilton Pinto / Meta                                      #
#Liberacao      : 20/08/2014                                                #
#...........................................................................#
#Liberacao      : 13/05/2015     PJ                                         #
#############################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

define m_cts61m02_prep smallint

#--------------------------#
function cts61m02_prepare()
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
            ,"and b.c24astcod not in ('CON','ALT','CAN','RET','IND','REC')"
 prepare p_cts61m02_001 from l_sql
 declare c_cts61m02_001 cursor for p_cts61m02_001



 let l_sql = ' select count(*) '
              ,' from datmsrvre '
             ,' where atdsrvnum = ?'
             ,' and atdsrvano = ? '
             ,' and socntzcod = ? '

 prepare p_cts61m02_002 from l_sql
 declare c_cts61m02_002 cursor for p_cts61m02_002
 	
 
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
            ,"and b.c24astcod not in ('CON','ALT','CAN','RET','IND','REC')"
 prepare p_cts61m02_003 from l_sql
 declare c_cts61m02_003 cursor for p_cts61m02_003	

 let m_cts61m02_prep = true

end function


#----------------------------------------#
function cts61m02_qtd_servico(lr_entrada)
#----------------------------------------#
 define lr_entrada record
    itaciacod    like datmitaapl.itaciacod
   ,itaramcod    like datmitaapl.itaramcod
   ,itaaplnum    like datmitaapl.itaaplnum
   ,itaaplitmnum like datmitaaplitm.itaaplitmnum
   ,socntzcod    like datksocntz.socntzcod
   ,itaasiplncod like datkitaasipln.itaasiplncod  
 end record

 define lr_servico record
    atdsrvnum like datrservapol.atdsrvnum
   ,atdsrvano like datrservapol.atdsrvano
 end record

 define l_qtd integer
       ,l_resultado smallint
       ,l_mensagem  char(60)

 if m_cts61m02_prep is null or
    m_cts61m02_prep <> true then
    call cts61m02_prepare()
 end if

 initialize lr_servico to null

 let l_qtd       = 0
 let l_resultado = null
 let l_mensagem  = null

    ##-- Obter os servicos dos atendimentos realizados pela apolice --##
    if lr_entrada.itaaplnum is not null then

       if not cty22g00_verifica_empresarial(lr_entrada.itaasiplncod) then
           
           
           open c_cts61m02_001 using lr_entrada.itaciacod
                                    ,lr_entrada.itaramcod
                                    ,lr_entrada.itaaplnum
                                    ,lr_entrada.itaaplitmnum
           
           
           
           foreach c_cts61m02_001 into lr_servico.*
           
           
           
            call cts61m02_consiste_servico(lr_servico.*,
                                           lr_entrada.socntzcod)
                 returning l_resultado
           
           
              if l_resultado = 1 then
                 let l_qtd  = l_qtd + 1
              else
                 if l_resultado = 3 then
                    error l_mensagem sleep 2
                    exit foreach
                 end if
              end if
           
           end foreach
           
           close c_cts61m02_001
      else
      	   
      	   open c_cts61m02_003 using lr_entrada.itaciacod
                                    ,lr_entrada.itaramcod
                                    ,lr_entrada.itaaplnum
                                           
           foreach c_cts61m02_003 into lr_servico.*
           
           
           
            call cts61m02_consiste_servico(lr_servico.*,
                                           lr_entrada.socntzcod)
                 returning l_resultado
           
           
              if l_resultado = 1 then
                 let l_qtd  = l_qtd + 1
              else
                 if l_resultado = 3 then
                    error l_mensagem sleep 2
                    exit foreach
                 end if
              end if
           
           end foreach
           
           close c_cts61m02_003
      

      end if
      
      
      
      
      	     
    end if

 return l_qtd

end function


#---------------------------------------------#
function cts61m02_consiste_servico(lr_entrada)
#---------------------------------------------#
 define lr_entrada record
    atdsrvnum like datmservico.atdsrvnum
   ,atdsrvano like datmservico.atdsrvano
   ,socntzcod like datksocntz.socntzcod
 end record

 define l_resultado smallint
       ,l_mensagem  char(60)
       ,l_atdetpcod like datmsrvacp.atdetpcod
       ,l_qtde    integer

 initialize l_resultado to  null
 initialize l_mensagem  to  null
 initialize l_atdetpcod to  null

 if not m_cts61m02_prep then
    call cts61m02_prepare()
 end if

 ##-- Obtem a ultima etapa do servico --##
 let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                        ,lr_entrada.atdsrvano)

 ##-- Para servico a residencia, conta servicos Liberados(1) e Acionados(3)
 #display "l_atdetpcod = ",l_atdetpcod
 if  l_atdetpcod          = 1   or
     l_atdetpcod          = 3   then
    let l_resultado = 1
 else
    let l_resultado = 0
 end if


 if l_resultado = 1 then
    whenever error continue
    open c_cts61m02_002 using lr_entrada.atdsrvnum,
                              lr_entrada.atdsrvano,
                              lr_entrada.socntzcod
    fetch c_cts61m02_002 into l_qtde
    whenever error stop

    #display "l_qtde = ",l_qtde
    if l_qtde = 0 then
       let l_resultado = 0
    else
       let l_resultado = 1
    end if
    close c_cts61m02_002
 end if
 return l_resultado

end function