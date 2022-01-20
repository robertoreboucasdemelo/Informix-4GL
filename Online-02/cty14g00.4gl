#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: CTY14G00                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: PSI 205206 - Atendimento Azul seguros                      #
# Objetivo.......: Acesso a tabela gabkemp                                    #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 16/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 24/09/2007 Ana Raquel,Meta PSI211982  Incluir na selecao da popup a emp.40  #
# 11/08/2009 Fabio Costa     PSI198404  Func define nome abreviado da empresa #
# 09/03/2010 Sergio Burini   PAS086894  Inclusao da empresa 84 (ISAR)         #
#-----------------------------------------------------------------------------#
database porto

define m_cty14g00_prep smallint

#-------------------------#
function cty14g00_prepare()
#-------------------------#
   define l_sql char(300)

   let l_sql = "select empsgl "
              ," from gabkemp "
              ," where empcod = ? "
   prepare p_cty14g00_001 from l_sql
   declare c_cty14g00_001 cursor for p_cty14g00_001
   
   let l_sql = "select empnom "                    
              ," from gabkemp "                    
              ," where empcod = ? "                
   prepare p_cty14g00_002 from l_sql               
   declare c_cty14g00_002 cursor for p_cty14g00_002
   

   let m_cty14g00_prep = true

end function

#-----------------------------#
function cty14g00_empresa(lr_parametro)
#-----------------------------#
   define lr_parametro record
       tp_retorno    smallint,
       empcod        like gabkemp.empcod
   end record

   define lr_dados record
       empsgl   like gabkemp.empsgl
   end record

   define l_ret       smallint
   define l_mensagem  char(80)

   initialize lr_dados.* to null
   let l_ret = 0
   let l_mensagem = null

   if lr_parametro.empcod <> 1  and   ---> Porto
      lr_parametro.empcod <> 27 and   ---> Patrimonial
      lr_parametro.empcod <> 35 and   ---> Azul
      lr_parametro.empcod <> 40 and   ---> Cartao
      lr_parametro.empcod <> 43 and   ---> PS Servico
      lr_parametro.empcod <> 50 and   ---> Saude
      lr_parametro.empcod <> 84 and   ---> Itau
      lr_parametro.empcod <> 14 then  ---> Funeral
      let l_ret = 4
      let l_mensagem = "Informe a empresa: 1-Porto, 14-Prev, 27-PSeguro Prot, 35-Azul, 40-PSEG, 84-Itau"
   else

      if m_cty14g00_prep is null or
         m_cty14g00_prep <> true then
         call cty14g00_prepare()
      end if

      open c_cty14g00_001 using lr_parametro.empcod
      whenever error continue
      fetch c_cty14g00_001 into lr_dados.empsgl
      whenever error stop
      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode = 100 then
            let l_ret = 2
            let l_mensagem = "Código de empresa não cadastrado!", lr_parametro.empcod
         else
            let l_ret = 3
            let l_mensagem = "Erro ", sqlca.sqlcode, "em ccty14g00001. AVISE A INFORMATICA"
         end if
      else
         let l_ret = 1
      end if
   end if

   case lr_parametro.tp_retorno
        when 1    #retornar nome/sigla da empresa
            return l_ret,
                   l_mensagem,
                   lr_dados.empsgl
        otherwise
            return l_ret,
                   l_mensagem
   end case

end function

#---------------------------------------------#
function cty14g00_popup_empresa()
#---------------------------------------------#

 define lr_popup       record
        lin            smallint   # Nro da linha
       ,col            smallint   # Nro da coluna
       ,titulo         char (054) # Titulo do Formulario
       ,tit2           char (012) # Titulo da 1a.coluna
       ,tit3           char (040) # Titulo da 2a.coluna
       ,tipcod         char (001) # Tipo do Codigo a retornar
                                  # 'N' - Numerico
                                  # 'A' - Alfanumerico
       ,cmd_sql        char (1999)# Comando SQL p/ pesquisa
       ,aux_sql        char (200) # Complemento SQL apos where
       ,tipo           char (001) # Tipo de Popup
                                  # 'D' Direto
                                  # 'E' Com entrada
 end  record

 define lr_retorno     record
        erro           smallint,
        ciaempcod      like gabkemp.empcod,
        empnom         like gabkemp.empnom
 end record
 define l_empresa char(100),
        l_aux     char(005),
        l_ind     smallint

 initialize lr_retorno.*  to  null
 initialize lr_popup.*    to  null
 initialize l_empresa, l_aux to null
 let l_ind = 0

 let lr_popup.lin    = 6
 let lr_popup.col    = 2
 let lr_popup.titulo = "Empresas"
 let lr_popup.tit2   = "Codigo"
 let lr_popup.tit3   = "Nome"
 let lr_popup.tipcod = "N"
 let l_ind = 1
 declare cq_empresas cursor for
  select cpocod
    from iddkdominio
   where cponom = 'empatdpso'
 foreach cq_empresas into l_aux
     if  l_ind > 1 then
         let l_aux = ",", l_aux
     end if
     let l_empresa = l_empresa clipped, l_aux
     let l_ind = l_ind + 1
 end foreach
 let lr_popup.cmd_sql = "select empcod, empnom ",
                        "  from gabkemp ",
                        " where empcod in (", l_empresa clipped, ")",
                        " order by empcod "
 let lr_popup.tipo   = "D"

 call ofgrc001_popup(lr_popup.*)
      returning lr_retorno.*

 if lr_retorno.erro = 0 then
    let lr_retorno.erro = 1
 else
    if lr_retorno.erro = 1 then
       let lr_retorno.erro = 2
    else
       let lr_retorno.erro = 3
    end if
 end if

 let int_flag = false

 return lr_retorno.*

end function

#----------------------------------------------------------------
function cty14g00_empresa_abv(l_empcod)
#----------------------------------------------------------------
# Funcao retorna nome abreviado das empresas. Foi feito em hardcode por
# nao haver disponivel nesta forma na tabela gabkemp

  define l_empcod like gabkemp.empcod
  define l_ret       smallint
  define l_mensagem  char(70)
  define l_empdes    char(5)
  initialize l_ret, l_mensagem, l_empdes to null

  if l_empcod is null or
     l_empcod <= 0
     then
     let l_mensagem = 'Parametro invalido'
     return 99, l_mensagem, 'N/D'
  end if
  case l_empcod
     when 1
        let l_empdes = 'PORTO'
     when 35
        let l_empdes = 'AZUL'
     when 14
        let l_empdes = 'PREVI'
     when 27
        let l_empdes = 'PROT'
     when 40
        let l_empdes = 'PSEG'
     when 43
        let l_empdes = 'PSS'
     when 50
        let l_empdes = 'SAUDE'
     when 84
        let l_empdes = 'ITAU'
     otherwise
        let l_empdes = 'N/D'
  end case
  return 0, '', l_empdes
end function

#--------------------------------------------#          
function cty14g00_empresa_nome(lr_parametro)  
#--------------------------------------------#

define lr_parametro record               
    empcod    like gabkemp.empcod    
end record                               

define lr_retorno record                                                                       
   empnom     like gabkemp.empnom ,                                          
   erro          integer          ,                                                 
   mensagem      char(50)                                                                      
end record                                                                                     
                                                                                             
if m_cty14g00_prep is null or                                                                        
   m_cty14g00_prep <> true then                                                                      
   call cty14g00_prepare()                                                                     
end if                                                                                         
                                                                                               
initialize lr_retorno.* to null                                                                
let lr_retorno.erro = 0                                                                        
                                                                                               
   open c_cty14g00_002 using lr_parametro.empcod                                                   
   whenever error continue                                                                     
   fetch c_cty14g00_002 into lr_retorno.empnom                                              
   whenever error stop                                                                         
                                                                                               
   if sqlca.sqlcode <> 0  then                                                                 
      if sqlca.sqlcode = notfound  then                                                        
         let lr_retorno.mensagem = "Empresa nao Encontrada!"                                 
         let lr_retorno.erro     = 1                                                           
      else                                                                                     
         let lr_retorno.mensagem = "Erro ao selecionar o cursor c_cty14g00_002 ", sqlca.sqlcode
         let lr_retorno.erro     = sqlca.sqlcode                                               
      end if                                                                                   
   end if                                                                                      
                                                                                               
   close c_cty14g00_002                                                                        
                                                                                               
   return lr_retorno.empnom ,                                                               
          lr_retorno.erro   ,                                                               
          lr_retorno.mensagem                                                                  
                                                                                               
end function                                                                                   