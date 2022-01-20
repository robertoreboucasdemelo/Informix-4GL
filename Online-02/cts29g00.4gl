#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Central 24h                                                #
# Modulo         : CTS29G00                                                   #
# Analista Resp. : Ligia Mattge                                               #
# PSI            : 189790                                                     #
#.............................................................................#
# Desenvolvimento: Alinne, META                                               #
# Liberacao      : 8/04/2005                                                  #
#.............................................................................#
#                  * * *  ALTERACOES  * * *                                   #
#                                                                             #
# Data      Autor Fabrica PSI     Alteracao                                   #
# --------  ------------- --------  ------------------------------------------#
# 14/06/05  Andrei, Meta  PSI189790  Inclusao da funcao cts29g00_obter_qtd_   #
#                                    multiplo                                 #
#-----------------------------------------------------------------------------#
database porto

  define m_prep_cts29g00 smallint

#--------------------------#
function cts29g00_prepare()
#--------------------------#

   define l_sql char(500)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_sql  =  null

   let l_sql = 'select atdsrvnum,atdsrvano '
              ,'   from datratdmltsrv '
              ,'  where atdmltsrvnum = ? '
              ,'    and atdmltsrvano = ? '

   prepare p_cts29g00_001 from l_sql
   declare c_cts29g00_001 cursor for p_cts29g00_001

   let l_sql = 'select atdmltsrvnum,atdmltsrvano '
              ,'  from datratdmltsrv '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '

   prepare p_cts29g00_002 from l_sql
   declare c_cts29g00_002 cursor for p_cts29g00_002

   let l_sql = 'select count(*) '
              ,'  from datratdmltsrv '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '

   prepare p_cts29g00_003 from l_sql
   declare c_cts29g00_003 cursor for p_cts29g00_003

   let l_sql = 'select min(atdmltsrvnum) '
              ,'      ,min(atdmltsrvano) '
              ,'  from datratdmltsrv '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '

   prepare p_cts29g00_004 from l_sql
   declare c_cts29g00_004 cursor for p_cts29g00_004

   let l_sql = 'select atdmltsrvnum,atdmltsrvano '
              ,'  from datratdmltsrv '
              ,' where atdsrvnum    = ? '
              ,'   and atdsrvano    = ? '
              ,'   and atdmltsrvnum > ? '

   prepare p_cts29g00_005 from l_sql
   declare c_cts29g00_005 cursor for p_cts29g00_005

   let l_sql = 'insert into datratdmltsrv(atdsrvnum,atdsrvano '
              ,'                         ,atdmltsrvnum,atdmltsrvano)'
              ,'       values(?,?,?,?)'

   prepare p_cts29g00_006 from l_sql

   let l_sql = 'delete from datratdmltsrv '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
              ,'   and atdmltsrvnum = ? '
              ,'   and atdmltsrvano = ? '

   prepare p_cts29g00_007 from l_sql

   let l_sql = 'delete from datratdmltsrv '
              ,' where atdmltsrvnum = ? '
              ,'   and atdmltsrvano = ? '

   prepare p_cts29g00_008 from l_sql

   let l_sql = 'select count(*) '
              ,'  from datratdmltsrv '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '

   prepare p_cts29g00_009 from l_sql
   declare c_cts29g00_006 cursor for p_cts29g00_009

   
   let l_sql = "select ciaempcod ",
               " from datmservico ",
               "where atdsrvnum = ?",
               "  and atdsrvano = ?"
      
    prepare p_cts29g00_010 from l_sql                
    declare c_cts29g00_010 cursor for p_cts29g00_010 
   
   
   let l_sql = 'select atdsrvnum,atdsrvano '
              ,'  from datratdmltsrv '
              ,' where atdmltsrvnum = ? '
              ,'   and atdmltsrvano = ? '

   prepare p_cts29g00_011 from l_sql
   declare c_cts29g00_011 cursor for p_cts29g00_011
   
   let l_sql = 'delete from datratdmltsrv '
              ,' where atdsrvnum = ? '
              ,'   and atdsrvano = ? '
   prepare p_cts29g00_012 from l_sql

   let m_prep_cts29g00 = true

end function

#----------------------------------------------#
function cts29g00_consistir_multiplo(lr_param)
#----------------------------------------------#

 define lr_param     record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum
       ,atdmltsrvano like datratdmltsrv.atdmltsrvano
 end record

 define l_atdsrvnum  like datratdmltsrv.atdsrvnum
 define l_atdsrvano  like datratdmltsrv.atdsrvano
 define l_resultado  smallint
 define l_mensagem   char(100)


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_atdsrvnum  =  null
	let	l_atdsrvano  =  null
	let	l_resultado  =  null
	let	l_mensagem  =  null

   let l_atdsrvnum = null
   let l_atdsrvano = null
   let l_resultado = 1
   let l_mensagem  = null

   if m_prep_cts29g00 is null or
      m_prep_cts29g00 <> true then
      call cts29g00_prepare()
   end if

   if lr_param.atdmltsrvnum is null or lr_param.atdmltsrvano is null then
      let l_resultado = 3
      let l_mensagem  = 'Parametros nulos'
      return l_resultado,l_mensagem
            ,l_atdsrvnum,l_atdsrvano
   end if

   open c_cts29g00_001 using lr_param.atdmltsrvnum,lr_param.atdmltsrvano

   whenever error continue
   fetch c_cts29g00_001 into l_atdsrvnum,l_atdsrvano
   whenever error stop
   if sqlca.sqlcode = 0 then
      let l_resultado = 1
      let l_mensagem = 'Servico e multiplo de ',l_atdsrvnum,' / ',l_atdsrvano
   else
      if sqlca.sqlcode = 100 then
         let l_resultado = 2
         let l_mensagem  = 'Servico nao e multiplo'
      else
         if sqlca.sqlcode <> 0 then
            let l_mensagem = 'Erro SELECT c_cts29g00_001 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
            call errorlog(l_mensagem)
            let l_mensagem = 'CTS29G00 / cts29g00_consistir_multiplo() / ',lr_param.atdmltsrvnum,' / '
                                                                          ,lr_param.atdmltsrvano
            call errorlog(l_mensagem)

            let l_resultado = 3
            let l_mensagem  = 'Erro ',sqlca.sqlcode,' em datratdmltsrv'
         end if
      end if
   end if
   close c_cts29g00_001
   
   return l_resultado
         ,l_mensagem
         ,l_atdsrvnum
         ,l_atdsrvano

end function

#-------------------------------------------#
function cts29g00_obter_multiplo(lr_param)
#-------------------------------------------#

 define lr_param record
        nivel_consulta smallint #1-Obter todos os servicos multiplos 2-Obter servicos que ainda estao pendentes para acionamento
       ,atdsrvnum      like datmsrvre.atdsrvnum
       ,atdsrvano      like datmsrvre.atdsrvano
 end record

 define al_retorno array[10] of record
        atdmltsrvnum like datratdmltsrv.atdmltsrvnum
       ,atdmltsrvano like datratdmltsrv.atdmltsrvano
       ,socntzdes    like datksocntz.socntzdes
       ,espdes       like dbskesp.espdes
       ,atddfttxt    like datmservico.atddfttxt
 end record

 define l_atdmltsrvnum like datratdmltsrv.atdmltsrvnum
 define l_atdmltsrvano like datratdmltsrv.atdmltsrvano
 define l_atdfnlflg    char(1)
 define l_socntzdes    like datksocntz.socntzdes
 define l_socntzcod    like datmsrvre.socntzcod
 define l_espcod       like datmsrvre.espcod
 define l_espdes       like dbskesp.espdes
 define l_espsit       like dbskesp.espsit
 define l_atddfttxt    like datmservico.atddfttxt
 define l_socntzgrpcod like datksocntz.socntzgrpcod
 define l_resultado    smallint
 define l_mensagem     char(100)
 define l_cont         smallint


	define	w_pf1	integer

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_atdmltsrvnum  =  null
	let	l_atdmltsrvano  =  null
	let	l_atdfnlflg  =  null
	let	l_socntzdes  =  null
	let	l_socntzcod  =  null
	let	l_espcod  =  null
	let	l_espdes  =  null
	let	l_espsit  =  null
	let	l_atddfttxt  =  null
	let	l_socntzgrpcod  =  null
	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	l_cont  =  null

#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	for	w_pf1  =  1  to  10
		initialize  al_retorno[w_pf1].*  to  null
	end	for

   if m_prep_cts29g00 is null or
      m_prep_cts29g00 <> true then
      call cts29g00_prepare()
   end if

   let l_cont = 0

   #Selecionar os servicos multiplos   
   open c_cts29g00_002 using lr_param.atdsrvnum,lr_param.atdsrvano
   foreach c_cts29g00_002 into l_atdmltsrvnum,l_atdmltsrvano
       #Obter somente os servicos multiplos que ainda nao estao finalizados
      if lr_param.nivel_consulta = 2 then
         call cts10g06_dados_servicos(4,l_atdmltsrvnum,l_atdmltsrvano)
            returning l_resultado,l_mensagem,l_atdfnlflg

         if l_resultado <> 1 then
            exit foreach
         end if

         if l_atdfnlflg = 'S' then #Servico multiplo finalizado, depreza-se
            continue foreach
         end if
      end if

      #Obter codigo da natureza do servico multiplo
      call cts26g00_obter_natureza(l_atdmltsrvnum,l_atdmltsrvano)
         returning l_resultado,l_mensagem,l_socntzcod, l_espcod

      if l_resultado <> 1 then
         exit foreach
      end if
      #Obter descricao da natureza
      call ctc16m03_inf_natureza(l_socntzcod,'A')
         returning l_resultado,l_mensagem,l_socntzdes,l_socntzgrpcod

      if l_resultado <> 1 then
         exit foreach
      end if

      #como estou apenas buscando a descricao, nao importando se especialidade
      # esta ativa ou nao, passar null
      let l_espsit = null
      call cts31g00_descricao_esp (l_espcod, l_espsit) returning l_espdes

      call cts10g06_dados_servicos(3,l_atdmltsrvnum,l_atdmltsrvano)
         returning l_resultado,l_mensagem,l_atddfttxt

      if l_resultado <> 1 then
         exit foreach
      end if

      let l_cont = l_cont + 1
      if l_cont > 10 then
         exit foreach
      end if

      let al_retorno[l_cont].atdmltsrvnum = l_atdmltsrvnum
      let al_retorno[l_cont].atdmltsrvano = l_atdmltsrvano
      let al_retorno[l_cont].socntzdes    = l_socntzdes
      let al_retorno[l_cont].espdes       = l_espdes
      let al_retorno[l_cont].atddfttxt    = l_atddfttxt

   end foreach

   if l_cont = 0 then
      let l_resultado = 2
      let l_mensagem  = 'Nao existem servicos multiplos'
   else
      let l_resultado = 1
      let l_mensagem  = ' '
   end if

   return l_resultado
         ,l_mensagem
         ,al_retorno[1].*
         ,al_retorno[2].*
         ,al_retorno[3].*
         ,al_retorno[4].*
         ,al_retorno[5].*
         ,al_retorno[6].*
         ,al_retorno[7].*
         ,al_retorno[8].*
         ,al_retorno[9].*
         ,al_retorno[10].*

end function

#--------------------------------------------#
function cts29g00_remover_multiplo(lr_param)
#--------------------------------------------#

   define lr_param record
          atdsrvnum like datratdmltsrv.atdsrvnum
         ,atdsrvano like datratdmltsrv.atdsrvano
   end record

   define l_quantidade       smallint
   define l_resultado        smallint
   define l_mensagem         char(100)
   define l_servico_original like datratdmltsrv.atdsrvnum
   define l_ano_original     like datratdmltsrv.atdsrvano
   define l_atdmltsrvnum     like datratdmltsrv.atdmltsrvnum
   define l_atdmltsrvano     like datratdmltsrv.atdmltsrvano


#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_quantidade  =  null
	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	l_servico_original  =  null
	let	l_ano_original  =  null
	let	l_atdmltsrvnum  =  null
	let	l_atdmltsrvano  =  null

   if m_prep_cts29g00 is null or
      m_prep_cts29g00 <> true then
      call cts29g00_prepare()
   end if

   let l_resultado = 1
   let l_mensagem  = null

   display "cts29g00_remover_multiplo ", lr_param.atdsrvnum, " ", lr_param.atdsrvano
   
   #Selecionar os servicos multiplos
   open c_cts29g00_001 using lr_param.atdsrvnum,
                             lr_param.atdsrvano
   whenever error continue
   fetch c_cts29g00_001
   whenever error stop
   #Se o servico nao e multiplo, entao o servico recebido e original
   if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = 100 then
        #Selecionar quantos multiplos tem o servico original
        open c_cts29g00_003 using lr_param.atdsrvnum,lr_param.atdsrvano
        whenever error continue
        fetch c_cts29g00_003 into l_quantidade
        whenever error stop
        if sqlca.sqlcode <> 0 then
           let l_mensagem = 'Erro SELECT c_cts29g00_003 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
           call errorlog(l_mensagem)
           let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                       ,lr_param.atdsrvano
           call errorlog(l_mensagem)
           let l_resultado = 3
           let l_mensagem  = 'Erro ',sqlca.sqlcode,' em datratdmltsrv'
           return l_resultado,l_mensagem
        end if
        close c_cts29g00_003
        
        #Se nao achar os multiplos com o original, retornar da funcao
        if l_quantidade = 0 then
           let l_resultado = 2
           let l_mensagem  = 'Servico nao possui multiplos'
           return l_resultado,l_mensagem
        end if
        #Se tiver mais de 1 servico multiplo para o original, montar nova estrutura na tabela
        #para manter os servicos multiplos e remover o servico original vindo do parametro
        if l_quantidade > 1 then
           #Obter o 1o servico multiplo que passara a ser o servico original na nova estrutura
           open c_cts29g00_004 using lr_param.atdsrvnum,lr_param.atdsrvano
           whenever error continue
           fetch c_cts29g00_004 into l_servico_original,l_ano_original
           whenever error stop
           if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = notfound then
                 let l_resultado = 2
                 let l_mensagem  = 'Primeiro servico multiplo nao encontrado'
              else
                 let l_mensagem = 'Erro SELECT c_cts29g00_004 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
                 call errorlog(l_mensagem)
                 let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                             ,lr_param.atdsrvano
                 call errorlog(l_mensagem)
                 let l_resultado = 3
                 let l_mensagem  = 'Erro ',sqlca.sqlcode,' em datratdmltsrv'
              end if
              return l_resultado,l_mensagem
           end if
           close c_cts29g00_004
           
           #Obter os outros servicos multiplos para gravar na nova estrutura
           open c_cts29g00_005 using lr_param.atdsrvnum,lr_param.atdsrvano, l_servico_original
           foreach c_cts29g00_005 into l_atdmltsrvnum,l_atdmltsrvano
           	
              #Gravar o 1o servico multiplo como original e o restante como multiplos dele
              whenever error continue
              execute p_cts29g00_006 using l_servico_original, l_ano_original
                                        ,l_atdmltsrvnum,l_atdmltsrvano
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 let l_mensagem = 'Erro INSERT p_cts29g00_006 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
                 call errorlog(l_mensagem)
                 let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',l_servico_original,' / '
                                                                             ,l_ano_original,' / '
                                                                             ,l_atdmltsrvnum,' / '
                                                                             ,l_atdmltsrvano
                 call errorlog(l_mensagem)
                 let l_resultado = 3
                 let l_mensagem  = 'Erro ',sqlca.sqlcode,' em datratdmltsrv'
                 exit foreach
              end if
              
              #Remover o servico original vindo do parametro
              whenever error continue
              execute p_cts29g00_007 using lr_param.atdsrvnum,lr_param.atdsrvano,l_atdmltsrvnum,l_atdmltsrvano
              whenever error stop
              if sqlca.sqlcode <> 0 then
                 let l_mensagem = 'Erro DELETE p_cts29g00_007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
                 call errorlog(l_mensagem)
                 let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                             ,lr_param.atdsrvano
                 call errorlog(l_mensagem)
                 let l_resultado = 3
                 let l_mensagem  = 'Erro ',sqlca.sqlcode, ' em datratdmltsrv'
                 return l_resultado,l_mensagem
              end if
              
              call cts00g07_apos_grvlaudo(l_atdmltsrvnum,l_atdmltsrvano)
           end foreach
           
           #Remover o servico original vindo do parametro
           whenever error continue
           execute p_cts29g00_007 using lr_param.atdsrvnum,lr_param.atdsrvano, l_servico_original, l_ano_original
           whenever error stop
           if sqlca.sqlcode <> 0 then
              let l_mensagem = 'Erro DELETE p_cts29g00_007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
              call errorlog(l_mensagem)
              let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                          ,lr_param.atdsrvano
              call errorlog(l_mensagem)
              let l_resultado = 3
              let l_mensagem  = 'Erro ',sqlca.sqlcode, ' em datratdmltsrv'
              return l_resultado,l_mensagem
           end if
           call cts00g07_apos_grvlaudo(l_servico_original, l_ano_original)

           if l_resultado = 3 then
              return l_resultado,l_mensagem
           end if
        else
        	 # QUANDO E SO UM MULTIPLO apaga relacionamento
        	 open c_cts29g00_002 using lr_param.atdsrvnum
                                    ,lr_param.atdsrvano

           whenever error continue
           fetch c_cts29g00_002 into l_atdmltsrvnum,l_atdmltsrvano
           whenever error stop
           close c_cts29g00_002
           
           whenever error continue
           execute p_cts29g00_007 using lr_param.atdsrvnum,lr_param.atdsrvano, l_atdmltsrvnum, l_atdmltsrvano
           whenever error stop
           if sqlca.sqlcode <> 0 then
              let l_mensagem = 'Erro DELETE p_cts29g00_007 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
              call errorlog(l_mensagem)
              let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                          ,lr_param.atdsrvano
              call errorlog(l_mensagem)
              let l_resultado = 3
              let l_mensagem  = 'Erro ',sqlca.sqlcode, ' em datratdmltsrv'
              return l_resultado,l_mensagem
           end if
           call cts00g07_apos_grvlaudo(l_atdmltsrvnum, l_atdmltsrvano)
        end if
     else
        let l_mensagem = 'Erro SELECT c_cts29g00_002 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
        call errorlog(l_mensagem)
        let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                    ,lr_param.atdsrvano
        call errorlog(l_mensagem)
        let l_resultado = 3
        let l_mensagem  = 'Erro ',sqlca.sqlcode, ' em datratdmltsrv'
        return l_resultado,l_mensagem
     end if
   else
     #Remover o servico multiplo vindo do parametro
     whenever error continue
     execute p_cts29g00_008 using lr_param.atdsrvnum,lr_param.atdsrvano
     whenever error stop
     if sqlca.sqlcode <> 0 then
        let l_mensagem = 'Erro DELETE p_cts29g00_008 / ',sqlca.sqlcode,' / ',sqlca.sqlerrd[2]
        call errorlog(l_mensagem)
        let l_mensagem = 'CTS29G00 / cts29g00_remover_multiplo() / ',lr_param.atdsrvnum,' / '
                                                                    ,lr_param.atdsrvano
        call errorlog(l_mensagem)
        let l_resultado = 3
        let l_mensagem  = 'Erro ',sqlca.sqlcode, ' em datratdmltsrv'
        return l_resultado,l_mensagem
     end if
     
     call cts00g07_apos_grvlaudo(lr_param.atdsrvnum,lr_param.atdsrvano)
   end if
   close c_cts29g00_001

   let l_resultado = 1
   let l_mensagem  = null

   return l_resultado,l_mensagem

end function

#--------------------------------------------#
function cts29g00_obter_qtd_multiplo(lr_param)
#--------------------------------------------#

 define lr_param record
                 atdsrvnum like datratdmltsrv.atdsrvnum
                ,atdsrvano like datratdmltsrv.atdsrvano
                 end record


 define l_resultado   smallint
       ,l_mensagem    char(100)
       ,l_quantidade  smallint



#@INICIALIZADA PELA COMPILADA-NAO APAGAR@#

	let	l_resultado  =  null
	let	l_mensagem  =  null
	let	l_quantidade  =  null

 if m_prep_cts29g00 is null or
    m_prep_cts29g00 <> true then
    call cts29g00_prepare()
 end if

 let l_quantidade = 0
 let l_resultado  = 0
 let l_mensagem   = null

 let l_resultado  = 1
 let l_mensagem   = 'Servico possui servicos multiplos'

 open c_cts29g00_006 using lr_param.atdsrvnum
                        ,lr_param.atdsrvano

 whenever error continue
 fetch c_cts29g00_006 into l_quantidade
 whenever error stop

 if sqlca.sqlcode <> 0 then
    let l_resultado = 3
    let l_mensagem = 'Erro SELECT  c_cts29g00_006 /', sqlca.sqlcode, '/'
                    , sqlca.sqlerrd[2]
    call errorlog(l_mensagem)
    let l_mensagem = 'CTS29G00 / cts29g00_obter_qtd_multiplo()'
    call errorlog(l_mensagem)
 end if
 close c_cts29g00_006

 if l_quantidade = 0 then
    let l_resultado = 2
    let l_mensagem = 'Servico nao possui multiplo'
 end if

 return l_resultado, l_mensagem, l_quantidade

end function


#--------------------------------------------#
function cts29g00_texto_itau_limite_multiplo(lr_param)
#--------------------------------------------#
 define lr_param record
   atdsrvnum      like datmsrvre.atdsrvnum,
   atdsrvano      like datmsrvre.atdsrvano
 end record

 
 define l_multiplo record
     atdmltsrvnum like datratdmltsrv.atdmltsrvnum,
     atdmltsrvano like datratdmltsrv.atdmltsrvano,
     socntzcod    like datksocntz.socntzcod      ,
     socntzdes    like datksocntz.socntzdes      
 end record

 define l_msg          char(500)
 define l_valor        char(50)
 define l_atdfnlflg    char(1)
 define l_resultado    smallint
 define l_mensagem     char(100)
 define l_socntzdes    like datksocntz.socntzdes
 define l_socntzcod    like datmsrvre.socntzcod
 define l_espcod       like datmsrvre.espcod
 define l_socntzgrpcod like datksocntz.socntzgrpcod
 define l_mobrefvlr    like dpakpecrefvlr.mobrefvlr 
 define l_pecmaxvlr    like dpakpecrefvlr.pecmaxvlr 
 define l_ciaempcod    like datmservico.ciaempcod  
 define l_atdsrvnum    like datmsrvre.atdsrvnum 
 define l_atdsrvano    like datmsrvre.atdsrvano  
 
 initialize l_multiplo.* to null
 initialize l_msg       ,
            l_valor     ,
            l_atdfnlflg ,  
            l_resultado ,  
            l_mensagem  ,  
            l_socntzdes ,  
            l_socntzcod ,  
            l_espcod    ,  
            l_socntzgrpcod to null
 
 if m_prep_cts29g00 is null or
    m_prep_cts29g00 <> true then
    call cts29g00_prepare()
 end if
 
  open c_cts29g00_011 using lr_param.atdsrvnum,lr_param.atdsrvano
  fetch c_cts29g00_011 into l_atdsrvnum,l_atdsrvano 
  
  if sqlca.sqlcode <> notfound then
     let lr_param.atdsrvnum = l_atdsrvnum
     let lr_param.atdsrvano = l_atdsrvano
  end if
  close c_cts29g00_011
  
  
 #Obter codigo da natureza do servico multiplo
  call cts26g00_obter_natureza(lr_param.atdsrvnum,lr_param.atdsrvano)
     returning l_resultado,l_mensagem,l_socntzcod, l_espcod

  #Obter descricao da natureza
  call ctc16m03_inf_natureza(l_socntzcod,'A')
     returning l_resultado,l_mensagem,l_socntzdes,l_socntzgrpcod
 
  
  open c_cts29g00_010 using lr_param.atdsrvnum,lr_param.atdsrvano
  fetch c_cts29g00_010 into l_ciaempcod
  close c_cts29g00_010
 
  select mobrefvlr,               
         pecmaxvlr                
    into l_mobrefvlr,             
         l_pecmaxvlr              
    from dpakpecrefvlr            
   where socntzcod = l_socntzcod 
     and empcod    = l_ciaempcod 
 
 if l_msg is null then
    let l_msg = l_msg clipped, l_socntzdes clipped,': ', l_pecmaxvlr using "<<<<<<<<<.<<" clipped
 else
    let l_msg = l_msg clipped,' , ', l_socntzdes clipped,': ', l_pecmaxvlr using "<<<<<<<<<.<<" clipped
 end if 
 
   
 #Selecionar os servicos multiplos                                    
 open c_cts29g00_002 using lr_param.atdsrvnum,
                           lr_param.atdsrvano      
 foreach c_cts29g00_002 into l_multiplo.atdmltsrvnum,
                             l_multiplo.atdmltsrvano            
     
     call cts10g06_dados_servicos(4,l_multiplo.atdmltsrvnum,l_multiplo.atdmltsrvano)
        returning l_resultado,l_mensagem,l_atdfnlflg

     if l_atdfnlflg = 'S' then #Servico multiplo finalizado, depreza-se
        continue foreach
     end if
    
     #Obter codigo da natureza do servico multiplo
      call cts26g00_obter_natureza(l_multiplo.atdmltsrvnum,l_multiplo.atdmltsrvano)
         returning l_resultado,l_mensagem,l_socntzcod, l_espcod

      if l_resultado <> 1 then
         continue foreach
      end if
      #Obter descricao da natureza
      call ctc16m03_inf_natureza(l_socntzcod,'A')
         returning l_resultado,l_mensagem,l_socntzdes,l_socntzgrpcod

      if l_resultado <> 1 then
         continue foreach
      end if
     
     open c_cts29g00_010 using l_multiplo.atdmltsrvnum,l_multiplo.atdmltsrvano
     fetch c_cts29g00_010 into l_ciaempcod
     close c_cts29g00_010 
     
     
     select mobrefvlr,               
           pecmaxvlr                
      into l_mobrefvlr,             
           l_pecmaxvlr              
      from dpakpecrefvlr            
     where socntzcod = l_socntzcod 
       and empcod    = l_ciaempcod 
     
     #display "l_pecmaxvlr: ",l_pecmaxvlr
     if l_msg is null then
        let l_msg = l_msg clipped, l_socntzdes clipped,': ', l_pecmaxvlr using "<<<<<<<<<.<<" 
     else
        let l_msg = l_msg clipped,' , ', l_socntzdes clipped,': ', l_pecmaxvlr using "<<<<<<<<<.<<"
     end if 
 
 end foreach
  
  if l_ciaempcod <> 84 then
     let l_msg = null
     return l_msg clipped
  else
     return l_msg clipped
  end if 
end function
