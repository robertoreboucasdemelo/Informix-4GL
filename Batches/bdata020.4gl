#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Ct24h                                               #
# Modulo        : bdata020                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI           : 187887                                              #
# Objetivo      : Ler servicos de locacao de carro extra que estao mar#
#                 cados para reverter o motivo da locacao. Para cada  #
#                 servico, buscar apolice do segurado e chamar funcao #
#                 p/ aplicar regras de conversao do motivo/tipo de    #
#                 locacao.                                            #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 21/12/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 28/12/2004  Lucas, Meta    PSI187887 Obtencao dos servicos de       #
#                                      locacao de carro extra.        #
#                                      Implementacao das chamadas das #
#                                      funcoes ctx01g04_ver_sinistro()#
#                                      ctx01g06_liberar() e cts10g02_ #
#                                      historico.                     # 
#---------------------------------------------------------------------#
# 18/01/2005 Daniel, Meta   PSI187887  Selecionar prporg, prpnumdig,  #
#                                      avioccdat de datmavisrent.     #
#                                      Chamar a funcao sinitfopc()    #
#---------------------------------------------------------------------#
#                  * * *  A L T E R A C O E S  * * *                          #
#                                                                             #
# Data       Autor Fabrica         PSI    Alteracoes                          #
# ---------- --------------------- ------ ------------------------------------#
# 10/09/2005 Helio (Meta)       Melhorias incluida funcao fun_dba_abre_banco. #
###############################################################################

database porto

  define m_path char(80)

main

   call fun_dba_abre_banco("CT24HS") 
   set isolation to dirty read 
   
   let m_path = f_path("DAT", "LOG")
   
   if m_path is null then 
      let m_path = 'bdata020.log'
   else
      let m_path = m_path clipped, '/bdata020.log'
   end if 
   
   call startlog(m_path)

   call bdata020_prepare()
   call bdata020()

end main

#---------------------------#
function bdata020_prepare()
#---------------------------#

  define l_comando char(600)
  
  let l_comando = 'select a.atdsrvnum, ',
                        ' a.atdsrvano, ',
                        ' a.avialgmtv, ',
                        ' a.lcvsinavsflg, ',
                        ' a.prporg, ',          
                        ' a.prpnumdig, ',       
                        ' a.avioccdat ',                        
                   ' from datmavisrent a, ',   
                        ' datmservico b ',
                  ' where a.atdsrvnum = b.atdsrvnum ',     
                     'and a.atdsrvano = b.atdsrvano ',
                     'and b.atdsrvorg = 8 ',
                     'and b.atddat > ? ' 
                        
  prepare pbdata020001 from l_comando                               
  declare cbdata020001 cursor for pbdata020001                      
  
end function

#---------------------#
function bdata020()
#---------------------#  

define l_atdsrvnum          like datmavisrent.atdsrvnum
      ,l_atdsrvano          like datmavisrent.atdsrvano
      ,l_avialgmtv          like datmavisrent.avialgmtv
      ,l_lcvsinavsflg       like datmavisrent.lcvsinavsflg
      ,l_linha1             char(70)
      ,l_linha2             char(30)
      ,l_nulo               char(01) 
      ,l_coderro            smallint
      ,l_data               date  
      ,l_hora               datetime hour to minute 
      
define lr_cts28g00          record
       resultado            smallint
      ,mensagem             char(50)      
      ,ramcod               like datrservapol.ramcod             
      ,succod               like datrservapol.succod
      ,aplnumdig            like datrservapol.aplnumdig
      ,itmnumdig            like datrservapol.itmnumdig
                            end record
                            
define l_resultado          smallint                            
      ,l_mensagem           char(50)
      ,l_motivo             decimal(1,0)

define l_code      integer                      
define l_tabname   char (30)                    
define l_prporg    like datmavisrent.prporg     
define l_prpnumdig like datmavisrent.prpnumdig  
define l_avioccdat like datmavisrent.avioccdat  


      
  initialize lr_cts28g00.* to null
  
  let l_atdsrvnum    = null
  let l_atdsrvano    = null
  let l_avialgmtv    = null                            
  let l_resultado    = null
  let l_mensagem     = null
  let l_lcvsinavsflg = null
  let l_motivo       = null
  let l_nulo         = null
  let l_linha1       = null
  let l_linha2       = null
  let l_coderro      = null
  let l_data         = today - 10 units day
  let l_code         = null
  let l_tabname      = null
  let l_prporg       = null
  let l_prpnumdig    = null
  let l_avioccdat    = null
  
  # --Obter os servicos de locacao de carro extra-- #
  open cbdata020001 using l_data      
  foreach cbdata020001 into l_atdsrvnum, l_atdsrvano, l_avialgmtv, l_lcvsinavsflg 
                           ,l_prporg,l_prpnumdig, l_avioccdat
     
     # --Desprezar as locacoes nao marcadas para avisar sinistro-- #
     if l_lcvsinavsflg is null or
        l_lcvsinavsflg = 'N' then 
        continue foreach
     end if
     
     # --Obter apolice do segurado do servico-- #
     call cts28g00_apol_serv(1, l_atdsrvnum, l_atdsrvano)
          returning lr_cts28g00.*
                           
     if lr_cts28g00.resultado <> 1 then
        display lr_cts28g00.mensagem
        exit foreach
     end if
     
     # --Verificar as consistencias na base do sinistro-- # 
     call ctx01g04_ver_sinistro (l_atdsrvnum, 
                                 l_atdsrvano, 
                                 lr_cts28g00.succod, 
                                 lr_cts28g00.aplnumdig,
                                 lr_cts28g00.itmnumdig)
          returning l_resultado, l_mensagem, l_motivo
          
     if l_resultado = 2 then
        display l_mensagem
        continue foreach 
     end if
     
     if l_motivo = 3 then
        #Interface com Sinistro
        call sinitfopc ("", "", lr_cts28g00.succod, lr_cts28g00.aplnumdig
                       ,lr_cts28g00.itmnumdig,l_prporg,l_prpnumdig,l_avioccdat
                       ,"", 'C', 999999, 'S')
           returning l_code,l_tabname
     
        if l_code <> 0 then
              display "Erro ", l_code, " na interface com sinistro - ", l_tabname
              continue foreach
        end if
     end if     
      
     # --Liberar o beneficio do carro extra-- #
     call ctx01g06_liberar (l_atdsrvnum, 
                            l_atdsrvano,
                            l_motivo,
			    "N")
                            # l_lcvsinavsflg)    
          returning l_resultado, l_mensagem                    
     
     if l_resultado = 1 then
        let l_linha1  = 'Reversao Automatica de tipo de locacao de ', l_avialgmtv, ' para ', l_motivo
        let l_linha2  = 'EM: ', today, ' as ', time
        let l_hora    = current
        let l_coderro = cts10g02_historico (l_atdsrvnum,
                                            l_atdsrvano,
                                            today,
                                            l_hora,
					    999999,
                                            l_linha1,
                                            l_linha2,
                                            l_nulo,
                                            l_nulo,
                                            l_nulo)
        
        if l_coderro <> 0 then
           display 'Erro na inclusao do historico do servico.'
        end if                                    
     else
        display l_mensagem
     end if
    
  end foreach                       
    
end function     
