#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: CENTRAL 24 HORAS - TELEATENDIMENTO                         #
# MODULO.........: ctc00m03                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: PSI 205206 - Atendimento Azul seguros                      #
# Objetivo.......: Tela para escolha das empresas para o cadastro de prestador#
#                  , veiculo e locadora                                       #
# ........................................................................... #
# DESENVOLVIMENTO: Priscila Staingel                                          #
# LIBERACAO......: 22/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 07/10/2011 Celso Yamahaki  CT-2011-   Inutilizacao da variavel Navega no    #
#                                       input array, abertura no popup de     #
#                                       empresas                              #
#-----------------------------------------------------------------------------#
# 17/08/2010  PSI-2012-31349EV Burini  Inclusão do relacionamento de          #
#                                      LOJA x EMPRESA                         #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define am_empresas array[15] of record
#   navega    smallint,
    ciaempcod like gabkemp.empcod,
    empsgl    like gabkemp.empsgl
end record

define m_count  smallint

#a funcao é unica para montar tela/buscar/incluir empresas
#mas pode ser utilizada para cadastrar as empresas por
#prestador (dparpstemp), veiculos(datrvclemp) e locadoras(datravsemp)
#-------------------------#
function ctc00m03(tp_dado, param)
#-------------------------#
    define tp_dado    smallint          #1-prestador, 2-veiculo, 3-locadora
    define param record
        ciaempcod1  like gabkemp.empcod,
        ciaempcod2  like gabkemp.empcod,
        ciaempcod3  like gabkemp.empcod,
        ciaempcod4  like gabkemp.empcod,
        ciaempcod5  like gabkemp.empcod,
        ciaempcod6  like gabkemp.empcod,
        ciaempcod7  like gabkemp.empcod,
        ciaempcod8  like gabkemp.empcod,
        ciaempcod9  like gabkemp.empcod,
        ciaempcod10  like gabkemp.empcod,
        ciaempcod11  like gabkemp.empcod,
        ciaempcod12  like gabkemp.empcod,
        ciaempcod13  like gabkemp.empcod,
        ciaempcod14  like gabkemp.empcod,
        ciaempcod15  like gabkemp.empcod
    end record    

    define retorno record
        ret       smallint,
        mensagem  char(60)
    end record
    
    define l_aux  smallint

    #inicializando variaveis
    initialize am_empresas to null
    initialize retorno.* to null
    let l_aux = 0

    let retorno.ret = 1
    
    #copia parametros para am_empresas
    let am_empresas[1].ciaempcod = param.ciaempcod1  
    let am_empresas[2].ciaempcod = param.ciaempcod2  
    let am_empresas[3].ciaempcod = param.ciaempcod3  
    let am_empresas[4].ciaempcod = param.ciaempcod4  
    let am_empresas[5].ciaempcod = param.ciaempcod5  
    let am_empresas[6].ciaempcod = param.ciaempcod6  
    let am_empresas[7].ciaempcod = param.ciaempcod7  
    let am_empresas[8].ciaempcod = param.ciaempcod8  
    let am_empresas[9].ciaempcod = param.ciaempcod9  
    let am_empresas[10].ciaempcod = param.ciaempcod10  
    let am_empresas[11].ciaempcod = param.ciaempcod11 
    let am_empresas[12].ciaempcod = param.ciaempcod12
    let am_empresas[13].ciaempcod = param.ciaempcod13  
    let am_empresas[14].ciaempcod = param.ciaempcod14  
    let am_empresas[15].ciaempcod = param.ciaempcod15  
    
    let l_aux = 1    
    
    while l_aux <= 15
        #carrega array
        if am_empresas[l_aux].ciaempcod is not null then
           call cty14g00_empresa(1, am_empresas[l_aux].ciaempcod)
                returning retorno.ret, 
                          retorno.mensagem, 
                          am_empresas[l_aux].empsgl
           let l_aux = l_aux + 1  
        else
           exit while              
        end if
    end while

    #m_count recebe o total de empresas
    let m_count = (l_aux - 1)

    #abre janela para visualizar/incluir empresas
    call ctc00m03_janela(tp_dado)
    if int_flag = true then
       #display "pessionou f17"
       let retorno.ret = 2
       let retorno.mensagem = "Nao salvou dados da empresa em ctc03m00!"
    else
       #display "salvou!!!"
       let retorno.ret = 1
       let retorno.mensagem = null   
    end if       

    return retorno.ret,
           retorno.mensagem,
           am_empresas[1].ciaempcod,
           am_empresas[2].ciaempcod,
           am_empresas[3].ciaempcod,
           am_empresas[4].ciaempcod,
           am_empresas[5].ciaempcod,
           am_empresas[6].ciaempcod,
           am_empresas[7].ciaempcod,
           am_empresas[8].ciaempcod,
           am_empresas[9].ciaempcod,
           am_empresas[10].ciaempcod,
           am_empresas[11].ciaempcod,    
           am_empresas[12].ciaempcod,    
           am_empresas[13].ciaempcod,    
           am_empresas[14].ciaempcod,    
           am_empresas[15].ciaempcod     

end function


#-------------------------#
function ctc00m03_janela(l_tp_dado)
#-------------------------#
    define l_tp_dado   smallint

    define l_texto   char(50)
    
    define scr_aux   smallint,
           arr_aux   smallint
           
    define l_ciaempcod_old  like gabkemp.empcod,
           l_operacao       char(1),
           l_aux            smallint,
           l_confirma       char(1)
           
    define l_ret   smallint,
           l_mensagem  char(50)        
    
    let l_texto = null
    let l_ciaempcod_old = null
    let l_operacao = "x"
    let l_ret = 0
    let l_mensagem = null

    case l_tp_dado
        when 1
           let l_texto = "RELACAO DE EMPRESAS ATENDIDAS PELO PRESTADOR"
        when 2
           let l_texto = "RELACAO DE EMPRESAS ATENDIDAS PELO VEICULO"
        when 3
           let l_texto = "RELACAO DE EMPRESAS ATENDIDAS PELA LOCADORA"
        when 4
           let l_texto = "RELACAO DE EMPRESAS ATENDIDAS PELA LOJA"           
    end case    

    open window w_ctc00m03 at 08,13 with form "ctc00m03"
        attribute(border, form line first) 
        
    display l_texto to texto   
    
    options
        insert key f1, 
        delete key control-y
        
    call set_count(m_count)    
    
    while true
          input array am_empresas without defaults from s_ctc00m03.*     
          
             before row
                 let scr_aux = scr_line()
                 let arr_aux = arr_curr()
          
#            before insert                 
#                let arr_aux = arr_curr()
#                let scr_aux = scr_line()
#                next field ciaempcod
                 
             #before field navega
             
#            after field navega
#                if fgl_lastkey() = fgl_keyval("right") or
#                   fgl_lastkey() = 13 then   #enter
#                   if am_empresas[arr_aux].ciaempcod is not null then
#                      next field navega   
#                   end if
#                end if         
          
             before field ciaempcod
                 display am_empresas[arr_aux].ciaempcod to 
                          s_ctc00m03[scr_aux].ciaempcod attribute(reverse)
                            
             after field ciaempcod
                 display am_empresas[arr_aux].ciaempcod to 
                          s_ctc00m03[scr_aux].ciaempcod 
          
#                if fgl_lastkey() = fgl_keyval("up")   or
#                   fgl_lastkey() = fgl_keyval("left") then
#                   next field navega
#                end if   
#         
                 if (fgl_lastkey() = fgl_keyval("right")    or
                     fgl_lastkey() = fgl_keyval("down")     or
                     fgl_lastkey() = fgl_keyval("return"))  then

                     if am_empresas[arr_aux].ciaempcod is null then
                       #abrir pop-up para escolha da empresa
                        call cty14g00_popup_empresa()
                             returning l_ret,
                                       am_empresas[arr_aux].ciaempcod,
                                       am_empresas[arr_aux].empsgl

                        let int_flag = false              

                        if am_empresas[arr_aux].ciaempcod is null then
                           next field ciaempcod
                        end if
                     end if
          
                     #se veio até esse campo é insercao, entao validar empresa
                     if am_empresas[arr_aux].ciaempcod is not null then
                        #verificar se nova empresa informada já não está carregada no array
                        #em outra posição
                        
                        if am_empresas[arr_aux].empsgl is null then
                           #Buscar a descricao da empresa
                           call cty14g00_empresa(1, am_empresas[arr_aux].ciaempcod)
                                returning l_ret, 
                                          l_mensagem, 
                                          am_empresas[arr_aux].empsgl    
                           if l_ret <> 1 then
                              error "Código de empresa invalido."
                              next field ciaempcod
                           end if        
                        end if
                        display am_empresas[arr_aux].empsgl to 
                                 s_ctc00m03[scr_aux].empsgl
                     end if
                 end if
#                next field navega
          
             on key(f2)
                  call ctc00m03_deleta_linha(arr_aux,scr_aux)
          
             on key (f17, control-c, interrupt)
                   let int_flag = true
                   exit input
                   
             on key (f8)
                   let int_flag = false
                   exit input                
          
          end input          
          
          if  not int_flag then
              for l_aux = 1 to 15
                  if  am_empresas[l_aux].ciaempcod is not null then
                      exit while
                  end if 
              end for
          end if          
          
          call cts08g01("A","N",
                      " Senhor Usuario,  ",
                      "","E obrigatorio informar pelo menos uma","empresa.")
             returning l_confirma
          
    end while
          
    close window w_ctc00m03  
                     
end function

#---------------------------------------#
function ctc00m03_deleta_linha(l_arr, l_scr)
#---------------------------------------#

  define l_arr        smallint,
         l_scr        smallint,
         l_cont       smallint

  for l_cont = l_arr to 14   #uma posição antes do limite do array
     if am_empresas[l_arr].ciaempcod is not null then
        let am_empresas[l_cont].* = am_empresas[l_cont + 1].*
     else
        initialize am_empresas[l_arr].* to null
     end if
  end for

  for l_cont = l_scr to 4
     display am_empresas[l_arr].ciaempcod to s_ctc00m03[l_cont].ciaempcod
     display am_empresas[l_arr].empsgl to s_ctc00m03[l_cont].empsgl
     let l_arr = l_arr + 1
  end for

end function
