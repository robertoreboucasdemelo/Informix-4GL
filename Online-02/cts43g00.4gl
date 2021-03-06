#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts43g00.                                                  #
# Analista Resp.: Ligia Mattge.                                              #
# PSI           : 205206                                                     #
#                 Obter os limites de utilizacao da Azul.                    #
#............................................................................#
# Desenvolvimento: Ligia Mattge                                              #
# Liberacao      : 14/12/2006                                                #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
# 01/04/2008 Amilton,Meta                 Tratar os assuntos K17,K18,K19     #
# 30/05/2008 Amilton,Meta                 Tratar os assuntos K21             #
#                                                                            #
#----------------------------------------------------------------------------#
# 18/08/2008 Carla Rampazzo               Acerto na Mensagem sobre Clausula  #
#                                         Contrata (nao cabia so em 1 linha) #
#----------------------------------------------------------------------------#
# 24/09/2008 Carla Rampazzo               Ver ao final deste programa Tabela #
#                                         de Regras e trecho transcrito do   #
#                                         correio enviado pelo cliente com   #
#                                         as definicoes usadas no pgm. (*)   #
#----------------------------------------------------------------------------#
# 21/11/2009 Carla Rampazzo               Tratar novas Clausulas:            #
#                                         37A: Assist.24h - Rede Referenciada#
#                                         37B: Assist.24h - Livre Escolha    #
#----------------------------------------------------------------------------#
# 05/02/2010 Carla Rampazzo               Tratar nova Clausula:              #
#                                         37C : Assist.24h - Assit.Gratuita  #
#----------------------------------------------------------------------------#
# 16/07/2010 Carla Rampazzo               Tratar Clausula 37A e 37B:         #
#                                         KM Guincho de: 250 p/ 400          #
#----------------------------------------------------------------------------#
# 12/08/2012 Fornax-Hamilton PSI-2012-16125/EV Inclusao de tratativas para as#
#                                              clausulas 37D, 37E, 37F, 37G  #
#----------------------------------------------------------------------------#
database porto

define m_prep_sql smallint     

define mr_entrada record
	utl_gui   smallint,
  utl_cha   smallint,
  guincho   smallint,
  chaveiro  smallint 
end record	


#---------------------------------------------------------------------------#
function cts43g00_prepare()
#---------------------------------------------------------------------------#
 define l_sql char(600)

 let l_sql = ' select a.atdsrvnum '
                  ,' ,a.atdsrvano '
                  ,' ,b.asitipcod '
              ,' from datrservapol a, datmservico b '
             ,' where a.ramcod    = ? '
               ,' and a.succod    = ? '
               ,' and a.aplnumdig = ? '
               ,' and a.itmnumdig = ? '
               ,' and a.atdsrvnum = b.atdsrvnum '
               ,' and a.atdsrvano = b.atdsrvano '
 prepare p_cts43g00_001 from l_sql
 declare c_cts43g00_001 cursor for p_cts43g00_001

 let l_sql = 'select 1 '
            ,' from datmligacao '
           ,' where atdsrvnum = ? '
             ,' and atdsrvano = ? '
             ,' and c24astcod in ("K10")'
             ,' and ligdat   >= ? '
             ,' and ligdat   <= ? '
 prepare p_cts43g00_002 from l_sql
 declare c_cts43g00_002 cursor for p_cts43g00_002

 let m_prep_sql = true

end function

#---------------------------------------------------------------------------#
function cts43g00_limite_azul(lr_entrada)
#---------------------------------------------------------------------------#
   define lr_entrada record
          ramcod    like datrservapol.ramcod
         ,succod    like datrservapol.succod
         ,aplnumdig like datrservapol.aplnumdig
         ,itmnumdig like datrservapol.itmnumdig
         ,edsnumref like datrservapol.edsnumref
         ,asitipcod like datmservico.asitipcod
         ,c24astcod like datmligacao.c24astcod
   end record

   define lr_servico record
          atdsrvnum like datmservico.atdsrvnum,
          atdsrvano like datmservico.atdsrvano,
          asitipcod like datmservico.asitipcod
   end record

   define lr_apolice record
          viginc     date,
          vigfnl     date,
          emsdat     date,
          km         integer,
          qtd        integer
   end record

   define l_resultado       smallint,
          l_msg             char(80),
          l_doc_handle      integer,
          l_chaveiro        integer,
          l_guincho         integer,
          l_ind             integer,
          l_conta           integer,
          l_contados        integer,
          l_tem             smallint,
          l_sair            smallint,
          l_limite          smallint,
	        l_cls_001         smallint,  ---> Colisao
	        l_cls_002         smallint,  ---> Roubo/Incendio
	        l_cls_037         smallint,  ---> Assistencia
	        l_cls_37A         smallint,  ---> Assistencia - Rede Referenciada
	        l_cls_37B         smallint,  ---> Assistencia - Livre Escolha
	        l_cls_37C         smallint,  ---> Assistencia - Gratuita
	        l_cls_37D         smallint,  ---> Assistencia - Rede Referenciada 400 km
	        l_cls_37E         smallint,  ---> Assistencia - Rede Referenciada s/limite de Km
	        l_cls_37F         smallint,  ---> Assistencia - Livre escolha 400 km
	        l_cls_37G         smallint,  ---> Assistencia - Livre escolha sem limite de Km 
	        l_cls_37H         smallint,  ---> Assistencia - Nova Gratuita  
          l_descricao       char(50),  ---> Descricao da Assistencia
          l_excedeu_gui     smallint,
          l_excedeu_cha     smallint

   define a_cts43g00  array[50] of record
          asitipcod   like datkasitip.asitipdes, #datmservico.asitipcod,
          qtd_util    integer,
          qtd_lim     integer
   end record

   initialize lr_apolice.* to null
   initialize lr_servico.* to null 
   initialize mr_entrada.* to null
   initialize a_cts43g00 to null

   let l_resultado     = null
   let l_msg           = null
   let l_doc_handle    = null
   let l_chaveiro      = null
   let l_guincho       = null
   let l_descricao     = null
   let l_ind           = 1
   let l_conta         = 1
   let l_contados      = 1
   let l_limite        = true
   let l_tem           = false
   let l_cls_001       = false
   let l_cls_002       = false
   let l_cls_037       = false
   let l_cls_37A       = false
   let l_cls_37B       = false
   let l_cls_37C       = false
   let l_cls_37D       = false
   let l_cls_37E       = false
   let l_cls_37F       = false
   let l_cls_37G       = false 
   let l_cls_37H       = false 
   let l_excedeu_gui   = false
   let l_excedeu_cha   = false
  
   let mr_entrada.utl_gui  = 0
   let mr_entrada.utl_cha  = 0

   if lr_entrada.c24astcod <> "K10" and
      lr_entrada.c24astcod <> "K15" and
      lr_entrada.c24astcod <> "K17" and # Amilton
      lr_entrada.c24astcod <> "K18" and # Amilton
      lr_entrada.c24astcod <> "K19" and # Amilton
      lr_entrada.c24astcod <> "K21" and # Amilton
      lr_entrada.c24astcod <> "K37" and
      lr_entrada.c24astcod <> "K23" and
      lr_entrada.c24astcod <> "K33" and
      lr_entrada.c24astcod <> "KPT" then
      return false
   end if

   ---> Unificando assistencias: Tecnico(2) - Gui/Tec(3) - Tecnico2 (61)
   ---> na assistencia do Guincho (1)
   if lr_entrada.asitipcod = 2  or
      lr_entrada.asitipcod = 3  or
      lr_entrada.asitipcod = 61 then
      let lr_entrada.asitipcod = 1
   end if

   ##Unificando os codigos de assistencia chavauto e cod/pantog
   ## somene no chavauto.
   if lr_entrada.asitipcod = 50 then
      let lr_entrada.asitipcod = 4
   end if

   if m_prep_sql is null or
      m_prep_sql <> true then
      call cts43g00_prepare()
   end if


   --> Consistir a clausula 001 --> Colisao
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "001")
        returning l_cls_001


   --> Consistir a clausula 002 --> Incendio/Roubo
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "002")
        returning l_cls_002


   --> Consistir a clausula 37 --> Assistencia
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "037")
        returning l_cls_037


   --> Consistir a clausula 37A --> Assistencia - Rede Referenciada
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37A")
        returning l_cls_37A


   --> Consistir a clausula 37B --> Assistencia - Livre EScolha
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37B")
        returning l_cls_37B


   --> Consistir a clausula 37C --> Assistencia - Gratuita
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37C")
        returning l_cls_37C

   --> Consistir a clausula 37D --> Assistencia - Rede Referenciada 400 km
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37D")
        returning l_cls_37D
   
   --> Consistir a clausula 37E --> Assistencia - Rede Referenciada s/limite de Km
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37E")
        returning l_cls_37E
   
   --> Consistir a clausula 37F --> Assistencia - Livre escolha 400 km
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37F")
        returning l_cls_37F
   
   --> Consistir a clausula 37G --> Assistencia - Livre escolha sem limite de Km
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                 lr_entrada.edsnumref, "37G")
        returning l_cls_37G 
   
   --> Consistir a clausula 37H --> Assistencia - Nova Gratuita       
   call cts44g00(lr_entrada.succod   , lr_entrada.ramcod,                               
                 lr_entrada.aplnumdig, lr_entrada.itmnumdig,                            
                 lr_entrada.edsnumref, "37H")                                           
        returning l_cls_37H                                                             
   #display "l_cls_37H ", l_cls_37H    
        

   ##Obter codigo de acesso da apolice
   call cts42g00_doc_handle(lr_entrada.succod   , lr_entrada.ramcod   ,
                            lr_entrada.aplnumdig, lr_entrada.itmnumdig,
                            lr_entrada.edsnumref)
        returning l_resultado, l_msg, l_doc_handle


   ##Obter vigencia da apolice
   call cts40g02_extraiDoXML(l_doc_handle, "APOLICE_VIGENCIA")
        returning lr_apolice.viginc,
                  lr_apolice.vigfnl
                  
                  
  ##Obter a Data de Emissao da Apolice
   call cts40g02_extraiDoXML(l_doc_handle, "APOLICE_EMISSAO")
        returning lr_apolice.emsdat
                  

   ##Obter km limite e quantidade da apolice
   call cts40g02_extraiDoXML(l_doc_handle, "ASSISTENCIA_GUINCHO")
        returning lr_apolice.km,
                  lr_apolice.qtd

   if lr_apolice.km is null then
      let lr_apolice.km = 0
   end if


   ---> Busca descricao da Assistencia
   call cts40g02_extraiDoXML(l_doc_handle,'ASSISTENCIA_DESCRICAO')
        returning l_descricao


   ---> Nao permite Apolices sem Clausula 001, 002, 037, 37A, 37B e 37C
   if l_cls_001 = false  and  ---> Colisao
      l_cls_002 = false  and  ---> Incendio/Roubo
      l_cls_037 = false  and  ---> Assistencia tecnica
      l_cls_37A = false  and  ---> Assistencia tecnica - Rede Referenciada
      l_cls_37B = false  and  ---> Assistencia tecnica - Livre Escolha
      l_cls_37C = false  and  ---> Assistencia tecnica - Gratuita
      l_cls_37D = false  and  ---> Assistencia tecnica - Rede Referenciada 400 km
      l_cls_37E = false  and  ---> Assistencia tecnica - Rede Referenciada s/limite de Km
      l_cls_37F = false  and  ---> Assistencia tecnica - Livre escolha 400 km
      l_cls_37G = false  and  ---> Assistencia tecnica - Livre escolha sem limite de Km
      l_cls_37H = false  then ---> Assistencia tecnica - Nova Gratuita

      call cts08g01("A","N","*****  ATENCAO  *****", " "
                   ,"DOCUMENTO SEM CLAUSULA OU" ,"ASSISTENCIA CONTRATADA")
           returning l_cls_001
      return true
   end if

   ---> Tratar Assuntos K15, K17 e K37
   if lr_entrada.c24astcod = "K15" or
      lr_entrada.c24astcod = "K17" or
      lr_entrada.c24astcod = "K37" then

      ---> Se Apolice nao tem Clausula 001(Colisao) nao permite os servicos
      if l_cls_001 = false  then

         call cts08g01("A","N","*****  ATENCAO  *****", " "
		      ,"DOCUMENTO SEM CLAUSULA OU", "ASSISTENCIA CONTRATADA")
              returning l_cls_001
         return true
      else
         ---> Se Apolice tem Clausula 001(Colisao) sempre permite o assunto
         return false
      end if
   end if


   ---> Sempre liberar os Servicos K18,K19,K21 e KPT independente das
   ---> Clausulas Contratadas
   if lr_entrada.c24astcod = "K18" or
      lr_entrada.c24astcod = "K19" or
      lr_entrada.c24astcod = "K21" or
      lr_entrada.c24astcod = "KPT" then
      return false
   else
      ---> Se houver so a Clausula 002 nao permitir outros tipos de Servico
      if l_cls_001 = false  and  ---> Colisao
         l_cls_002 = true   and  ---> Incendio/Roubo
         l_cls_037 = false  and  ---> Assistencia tecnica
         l_cls_37A = false  and  ---> Assistencia tecnica - Rede Referenciada
         l_cls_37B = false  and  ---> Assistencia tecnica - Livre Escolha
         l_cls_37C = false  and  ---> Assistencia tecnica - Gratuita
         l_cls_37D = false  and  ---> Assistencia tecnica - Rede Referenciada 400 km
         l_cls_37E = false  and  ---> Assistencia tecnica - Rede Referenciada s/limt de Km
         l_cls_37F = false  and  ---> Assistencia tecnica - Livre escolha 400 km
         l_cls_37G = false  and  ---> Assistencia tecnica - Livre escolha sem limite de Km  
         l_cls_37H = false  then ---> Assistencia tecnica - Nova Gratuita  

         call cts08g01("A","N","*****  ATENCAO  *****",
                       " ","DOCUMENTO SEM CLAUSULA OU","ASSISTENCIA CONTRATADA")
              returning l_cls_002
         return true
      end if
   end if


   ##Obter a qtd limite do tipo de assistencia por tipo de plano.
   call cts43g00_obter_limites(lr_apolice.km,l_descricao)
        returning l_chaveiro, l_guincho

   if lr_entrada.c24astcod = "K10" then
      case
	 when l_cls_37D = true
	    let l_chaveiro = 2
	    let l_guincho  = 999
	 when l_cls_37E = true
	    let l_chaveiro = 2
	    let l_guincho  = 999
	 when l_cls_37F = true
	    let l_chaveiro = 2
	    let l_guincho  = 3
	 when l_cls_37G = true
	    let l_chaveiro = 2
	    let l_guincho  = 3  
	 when l_cls_37H = true     
	    let l_chaveiro = 2     
	      
	      if lr_apolice.emsdat >= "01/09/2013" then
	          let l_guincho  = 3
	      else
	      	  let l_guincho  = 999
	      end if 	
	      
	      let mr_entrada.guincho  = l_guincho
	      let mr_entrada.chaveiro = l_chaveiro
	           	    
      end case
   end if
  
   ##Caso nao possua clausula e km
   if l_cls_037     = false and
      l_cls_37A     = false and
      l_cls_37B     = false and
      l_cls_37C     = false and
      l_cls_37D     = false and
      l_cls_37E     = false and
      l_cls_37F     = false and
      l_cls_37G     = false and 
      l_cls_37H     = false and 
      lr_apolice.km = 0     then

      call cts08g01("A","N","*****  ATENCAO  *****",
                    " ","DOCUMENTO SEM CLAUSULA OU", "ASSISTENCIA CONTRATADA")
                    returning l_cls_037
      let l_limite = true
      return l_limite
   end if

   ## para os assuntos K23 e K33, verifica somente a clausula e assitencia
   if lr_entrada.c24astcod = "K23" then

      if l_cls_37C  =  true then

         ---> Para Clausula 37C nao permite gerar estes laudos
         call cts08g01("A","N"
                      ,"APOLICE POSSUI CLAUSULA "
                      ,"37C - ASSISTENCIA GRATUITA."
                      ,"NAO HA COBERTURA PARA "
                      ,"ASSISTENCIA A PASSAGEIROS.")
              returning l_cls_37C
         let l_limite = true
         return l_limite
      end if

      return false
   end if

   if lr_entrada.c24astcod = "K33" then


      if l_cls_37C = true then

         ---> Para Clausula 37C nao permite gerar estes laudos
         call cts08g01("A","N"," "
                      ,"APOLICE POSSUI CLAUSULA "
                      ,"37C - ASSISTENCIA GRATUITA."
                      ,"NAO HA COBERTURA PARA HOSPEDAGEM.")
              returning l_cls_37C
         let l_limite = true
         return l_limite
      end if

      return false
   end if

   ---> Se chegou neste ponto do pgm eh porque o Assunto = K10

   ##-- Obter os servicos dos atendimentos realizados pela apolice --##
   open c_cts43g00_001 using lr_entrada.ramcod
                            ,lr_entrada.succod
                            ,lr_entrada.aplnumdig
                            ,lr_entrada.itmnumdig

   foreach c_cts43g00_001 into lr_servico.atdsrvnum, lr_servico.atdsrvano,
                             lr_servico.asitipcod

      ---> Unificando assistencias: Tecnico(2) - Gui/Tec(3) - Tecnico2 (61)
      ---> na assistencia do Guincho (1)
      if lr_servico.asitipcod = 2  or
         lr_servico.asitipcod = 3  or
         lr_servico.asitipcod = 61 then
         let lr_servico.asitipcod = 1
      end if

      ##Unificando os codigos de assistencia chavauto e cod/pantog
      ## somene no chavauto.
      if lr_servico.asitipcod = 50 then
         let lr_servico.asitipcod = 4
      end if
      #--> INICIO - PSI-2012-16125/EV
      #--> Se possuir as clausulas 37F e 37G as assistencias do servico K10
      #    sao limitados a 3 utilizacoes no periodo de vigencia
      #    Unificando todos os servicos que nao forem chaveiro para contagem
      #    do limite
      #---------------------------------------------------------------------
      if l_cls_37F = true or
	       l_cls_37G = true then
         if lr_servico.asitipcod <> 4 and
	          lr_servico.asitipcod <> 1 then
	          let lr_servico.asitipcod = 1
         end if
      end if
      #--> FINAL - PSI-2012-16125/EV
      #-----------------------------

      if lr_entrada.asitipcod is not null and
         lr_entrada.asitipcod <> 0 then

         if lr_entrada.asitipcod <> lr_servico.asitipcod  then
            continue foreach
         end if
      end if

      ##-- Consiste o servico para considera-lo na contagem --##
      call cts43g00_srv_acn(lr_servico.atdsrvnum
                           ,lr_servico.atdsrvano
                           ,lr_entrada.c24astcod
                           ,lr_apolice.viginc
                           ,lr_apolice.vigfnl)
           returning l_resultado, l_msg
       
      if l_resultado = 1 then

         let l_tem =  false
         for l_conta = 1 to l_ind
             
             
             if a_cts43g00[l_conta].asitipcod = lr_servico.asitipcod then
                let a_cts43g00[l_conta].qtd_util =
                    a_cts43g00[l_conta].qtd_util  + 1
                let l_tem = true
                
                 if a_cts43g00[l_conta].asitipcod = 1 then
                 	   let mr_entrada.utl_gui = a_cts43g00[l_conta].qtd_util
                 end if 
                 
                 if a_cts43g00[l_conta].asitipcod = 4 then
                 	   let mr_entrada.utl_cha = a_cts43g00[l_conta].qtd_util
                 end if 
                
                
                
                
                
                exit for
             end if
         end for

         if l_tem = false then
            let a_cts43g00[l_ind].asitipcod = lr_servico.asitipcod
            let a_cts43g00[l_ind].qtd_util = 1
            let l_ind = l_ind + 1
         end if

         let l_contados = l_contados + 1

      else
         if l_resultado = 3 then
            error l_msg sleep 1
            exit foreach
         end if
      end if
      
     
   end foreach
   
   


   let l_ind = l_ind - 1
   let l_contados = l_contados - 1
   
   if l_contados = 0 then
      let l_limite = false
      return l_limite
   end if

   ## Retorna flag de limite do tipo de assistencia


   if lr_entrada.asitipcod  = 1 then

      if l_contados = l_guincho then
         let l_limite = true
         return l_limite
      end if
   end if

   if lr_entrada.asitipcod  = 4 then
      if l_contados = l_chaveiro then
         let l_limite = true
         return l_limite
      end if
   end if

   ## Inserindo os limites no array por tipo de assistencia
   let l_sair          = true
   let l_excedeu_gui   = false
   let l_excedeu_cha   = false

   for l_conta = 1 to l_ind

       if a_cts43g00[l_conta].asitipcod = 1 then

          let a_cts43g00[l_conta].asitipcod = "GUINCHO/TECNICO"
          let a_cts43g00[l_conta].qtd_lim = l_guincho
          let mr_entrada.utl_gui = a_cts43g00[l_conta].qtd_util  
          
          if a_cts43g00[l_conta].qtd_util = a_cts43g00[l_conta].qtd_lim  then
             let l_excedeu_gui = true
             let l_sair        = false

             ---> Clausula 37C-Gratuita - Nenhuma utilizacao de Chaveiro
             ---> Qdo Guincho chegar no limite atribuo o limite p/ Chaveiro
             if l_cls_37C = true then
                let l_excedeu_cha = true
             end if
          end if

          if a_cts43g00[l_conta].qtd_lim = 999 then
             let a_cts43g00[l_conta].qtd_lim = null
          end if
       end if

       if a_cts43g00[l_conta].asitipcod = 4 then

          let a_cts43g00[l_conta].asitipcod = "CHAVEIRO"
          let a_cts43g00[l_conta].qtd_lim = l_chaveiro
          let mr_entrada.utl_cha = a_cts43g00[l_conta].qtd_util 
          
          if a_cts43g00[l_conta].qtd_util = a_cts43g00[l_conta].qtd_lim then
             let l_excedeu_cha = true
             let l_sair        = false
          end if
       end if
   end for
   if l_sair = true then
      let l_limite = false
      return l_limite
   end if

   ---> Se o Guincho ou Chaveiro estiver no Limite de utilizacoes
   ---> e a chamada deste pgm for no campo do Assunto entao mostra lim/utilz
   if lr_entrada.asitipcod is null or
      lr_entrada.asitipcod =  0    then

      call set_count(l_ind)

      open window t_cts43g00 at 8,15 with form "cts43g00"
           attribute(form line 1, border)

      display array a_cts43g00 to s_cts43g00.*
      end display

      close window t_cts43g00

      if l_excedeu_gui = true  and
         l_excedeu_cha = true  then

         call cts08g01('A' ,'S'
                      ,'LIMITE ESGOTADO.'
                      ,'CONSULTE A COORDENACAO, '
                      ,'PARA ENVIO DE ATENDIMENTO. '
                      ,'')
              returning l_msg
          
         call cts03m04_limite_azul()
                         
         let l_limite = true
      else
         let l_limite = false
      end if
   end if


   return l_limite

end function

#---------------------------------------------------------------------------#
function cts43g00_srv_acn(lr_entrada)
#---------------------------------------------------------------------------#
   define lr_entrada record
          atdsrvnum like datmservico.atdsrvnum
         ,atdsrvano like datmservico.atdsrvano
         ,c24astcod like datmligacao.c24astcod
         ,viginc    date
         ,vigfnl    date
   end record

   define l_resultado smallint
         ,l_mensagem  char(60)
         ,l_atdetpcod like datmsrvacp.atdetpcod

   let l_resultado = null
   let l_mensagem  = null
   let l_atdetpcod = null

   ##Obtem o tipo de assistencia dentro da vigencia da apolice
   open c_cts43g00_002 using lr_entrada.atdsrvnum
                          ,lr_entrada.atdsrvano
                          ,lr_entrada.viginc
                          ,lr_entrada.vigfnl
   whenever error continue
   fetch c_cts43g00_002
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = 100 then
         let l_resultado = 2
      else
         let l_resultado = 3
         let l_mensagem = 'Erro', sqlca.sqlcode, ' em datmservico '
      end if
   else
      ##-- Obtem a ultima etapa do servico --##
      let l_atdetpcod = cts10g04_ultima_etapa(lr_entrada.atdsrvnum
                                             ,lr_entrada.atdsrvano)

      ##-- Para envio de socorro, considera os servicos Acionados (4). --##
      if l_atdetpcod = 4 then
         let l_resultado = 1
      else
         let l_resultado = 2
      end if
   end if
   close c_cts43g00_002

   return l_resultado, l_mensagem

end function

#---------------------------------------------------------------------------#
function cts43g00_obter_limites(l_km,l_descricao)
#---------------------------------------------------------------------------#

   define l_km         integer,
          l_descricao  char(50), ---> descricao do Tipo de Assistencia
          l_chaveiro   integer,
          l_guincho    integer

   let l_chaveiro = 0
   let l_guincho  = 0


   if l_descricao = "ASSISTENCIA PLUS I"             or
      l_descricao = "ASSISTENCIAPLUS I"              or
      l_descricao = "ASSISTENCIA PLUSI"              or
      l_descricao = "ASSISTENCIA PLUS II"            or
      l_descricao = "ASSISTENCIAPLUS II"             or
      l_descricao = "ASSISTENCIA PLUSII"             or
      l_descricao = "ASSISTENCIA REDE REFERENCIADA"  or
      l_descricao = "ASSISTENCIAREDE REFERENCIADA"   or
      l_descricao = "ASSISTENCIA REDEREFERENCIADA"   then
      let l_chaveiro = 2
      let l_guincho  = 999
   end if

   if l_descricao = "ASSISTENCIA LIVRE ESCOLHA"           or
      l_descricao = "ASSISTENCIALIVRE ESCOLHA"            or
      l_descricao = "ASSISTENCIA LIVREESCOLHA"            or
      l_descricao = "ASSISTENCIA PLUS II - LIVRE ESCOLHA" or
      l_descricao = "ASSISTENCIAPLUS II - LIVRE ESCOLHA"  or
      l_descricao = "ASSISTENCIA PLUSII - LIVRE ESCOLHA"  or
      l_descricao = "ASSISTENCIA PLUS II- LIVRE ESCOLHA"  or
      l_descricao = "ASSISTENCIA PLUS II -LIVRE ESCOLHA"  or
      l_descricao = "ASSISTENCIA PLUS II - LIVREESCOLHA"  then
      let l_chaveiro = 2
      let l_guincho  = 3
   end if

   if l_km = 100                         or
      l_descricao = "ASSISTENCIA BASICA" or
      l_descricao = "ASSISTENCIABASICA"  then
      let l_chaveiro = 2
      let l_guincho  = 3
   end if


   ---> Condicao relacionada a Clausula 37C - Gratuita
   if l_km = 100                               and
     (l_descricao = "ASSISTENCIA GRATUITA 100 KM" or
      l_descricao = "ASSISTENCIAGRATUITA100KM"     )then
      let l_chaveiro = 0
      let l_guincho  = 2
   end if

   return l_chaveiro, l_guincho

end function

#---------------------------------------------------------------------------#    
function cts43g00_recupera_limites()                                            
#---------------------------------------------------------------------------#

     return mr_entrada.utl_gui  , 
            mr_entrada.guincho  ,
            mr_entrada.utl_cha  ,
            mr_entrada.chaveiro

end function   

{
############################################################################
---> (*) Conforme comentario no inicio do pgm de 24/09/08
############################################################################

---> Conforme Correio enviado por: Anapaula Debastiani em 03/09/2008

CLAUSULA 37 (PLANO BASICO E PLUS)

Apolices sem clausulas 37 com cobertura colisao, incendio e roubo:
1. nao permitir a abertura do codigo K10;
2. permitir a abertura dos codigos K15, K17, K18, K19, K21 e KPT,sem limite de
   utilizacoes.

Apolices com clausulas 37 basico com cobertura colisao, incendio e roubo:
1. permitir a abertura do codigo K10, limitado a tres utilizacoes + chaveiro 02
   utilizacoes
2. permitir a abertura dos codigos K15, K17, K18, K19, K21 e KPT, sem limite de
   utilizacoes.

Apolices com clausulas 37 (plano plus) com cobertura colisao, incendio e roubo:
1. permitir a abertura do codigo K10 sem limite de utilizacao , incluindo limite
   para chaveiro (02 utilizacoes)
2. permitir a abertura dos codigos K15, K17, K18, K19, K21 e KPT, sem limite de
   utilizacoes.

Apolices sem clausulas 37 (plano basico e plano plus) com cobertura incendio e  roubo:
1. nao permitir a abertura do codigo K10;
2. permitir a abertura dos codigos K18, K19, K21 e KPT, sem limite de utiliza-
   coes.

Apolices com clausulas 37 (plano basico) com cobertura incendio e roubo:
1. permitir a abertura do codigo K10, limitado a tres utilizacoes + chaveiro 02
   utilizacoes
2. permitir a abertura dos codigos K18, K19, K21 e KPT, sem limite de utiliza-
   coes.

Apolices com clausulas 37 (plano plus) com cobertura incendio e roubo:
1. permitir a abertura do codigo K10 sem limite de utilizacao; chaveiro apenas
   02 utilizacoes
2. permitir a abertura dos codigos K18, K19, K21 e KPT, sem limite de utiliza-
   coes.

############################################################################

---> Conforme Correio enviado por: Anapaula Debastiani em 30/09/2008


DESPACHANTE - permanece como assistencia e continua sem limites de utilizacao
LEI SECA    - nao deve mais constar como assistencia
TECNICO2    - permanece como assistencia, porem deve ser considerado na contagem
              de utilizacoes do "GUINCHO".


############################################################################

T A B E L A   D E   R E G R A S
-------------------------------

#---------+---------+---------+---------+---------+---------+--------+---------+
#Assisten | Colisao |Inc/Roubo| K15,K17 |K18,K19  | K23,K33 |  K10   |   K10   |
#         |         |         |         |K21,KPT  |         | Guincho|Chaveiro |
# cls 037 | cls 001 | cls 002 |s/limite |s/limite |s/limite | limites| limites |
#---------+---------+---------+---------+---------+---------+--------+---------+
#N        |    S    |  S ou N |    S    |    S    |    N    |   N    |    N    |
#---------+---------+---------+---------+---------+---------+--------+---------+
#S-basico |    S    |  S ou N |    S    |    S    |    S    |  S-3   |   S-2   |
#---------+---------+---------+---------+---------+---------+--------+---------+
#S-plus   |    S    |  S ou N |    S    |    S    |    S    |S-s/limt|   S-2   |
#---------+---------+---------+---------+---------+---------+--------+---------+
#N        |    N    |  S ou N |    N    |    S    |    N    |   N    |    N    |
#---------+---------+---------+---------+---------+---------+--------+---------+
#S-basico |    N    |  S ou N |    N    |    S    |    S    |  S-3   |   S-2   |
#---------+---------+---------+---------+---------+---------+--------+---------+
#S-plus   |    N    |  S ou N |    N    |    S    |    S    |S-s/limt|   S-2   |
#---------+---------+---------+---------+---------+---------+--------+---------+
#N        |    N    |    N    |    N    |    N    |    N    |   N    |    N    |
#---------+---------+---------+---------+---------+---------+--------+---------+  


}
