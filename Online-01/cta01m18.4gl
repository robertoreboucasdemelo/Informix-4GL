#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m18.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Espelho da Proposta                                        #
#............................................................................#
# Desenvolvimento: Patricia Wissinievski                                     #
# Liberacao      : Out/2010                                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#                          * * * Alteracoes * * *                            #
#                                                                            #
# Data       Autor Fabrica  Origem     Alteracao                             #
# ---------- -------------- ---------- --------------------------------------#
# 20/09/2010 Patricia W.    Psi 260479 Criacao                               #
#----------------------------------------------------------------------------#
# 07/12/2015 Alberto        Sol 715257 Alerta Itau                           #
#----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_hostname   char(12)



                                
# ------------------------------------------------------------------------------
function cta01m18(p_prporgpcp,p_prpnumpcp)
# ------------------------------------------------------------------------------
   define p_prporgpcp like apbmclaus.prporgpcp,
          p_prpnumpcp like apbmclaus.prpnumpcp

   define l_retorno_estip record
          segnom    like gsakseg.segnom,
          dddcod    like gsakend.dddcod,
          teltxt    like gsakend.teltxt
   end record
   define l_retorno_capa record
          viginc like apamcapa.viginc,
          vigfnl like apamcapa.vigfnl,
          succod like apamcapa.succod,
          prpstt like apamcapa.prpstt,
          sucnom like gabksuc.sucnom,
          aplnumdig like apamcapa.aplnumdig,
          dscstt like iddkdominio.cpodes,
          cvnnum like apamcapa.cvnnum,
          prpqtditm like apamcapa.prpqtditm
   end record
   define l_retorno_corr record
          corsus like apamcor.corsus,
          cornom like gcakcorr.cornom
   end record
   define l_retorno_cattrf record
          ctgtrfcod like apbmcasco.ctgtrfcod,
          cbtcod    like apbmcasco.cbtcod,
          clcdat    like apbmcasco.clcdat,
          frqclacod like apbmcasco.frqclacod,
          imsvlr    like apbmcasco.imsvlr
   end record

   define l_retorno_veic record
          vcllicnum like apbmveic.vcllicnum,
          vclmrccod like agbkveic.vclmrccod,
          vcltipcod like agbkveic.vcltipcod,
          vclmdlnom like agbkveic.vclmdlnom,
          vclmrcnom like agbkmarca.vclmrcnom,
          vcltipnom like agbktip.vcltipnom,
          vclanofbc like apbmveic.vclanofbc,
          vclanomdl like apbmveic.vclanomdl,
          vclchsinc like apbmveic.vclchsinc,
          vclchsfnl like apbmveic.vclchsfnl
   end record


   define r_gcakfilial    record
         endlgd          like gcakfilial.endlgd
        ,endnum          like gcakfilial.endnum
        ,endcmp          like gcakfilial.endcmp
        ,endbrr          like gcakfilial.endbrr
        ,endcid          like gcakfilial.endcid
        ,endcep          like gcakfilial.endcep
        ,endcepcmp       like gcakfilial.endcepcmp
        ,endufd          like gcakfilial.endufd
        ,dddcod          like gcakfilial.dddcod
        ,teltxt          like gcakfilial.teltxt
        ,dddfax          like gcakfilial.dddfax
        ,factxt          like gcakfilial.factxt
        ,maides          like gcakfilial.maides
        ,crrdstcod       like gcaksusep.crrdstcod
        ,crrdstnum       like gcaksusep.crrdstnum
        ,crrdstsuc       like gcaksusep.crrdstsuc
        ,status          smallint
   end record

   define l_retorno_historico record
          tfades char(30),
          tfacod smallint
   end record


   define l_segteltxt char(40),
          l_corteltxt char(40),
          l_qtde_clausulas smallint,
          l_chassi char(20),
          l_cvnnom char(25),
          l_cbtdes char(19),
          l_numprop char(15),
          l_stt_proposta char(23),
          l_st_erro       smallint

   define l_flag           char(01)
         ,l_msg            char(60)
         ,l_msgfuncoes     char(100)
         ,l_confirma       char(01)

   define lr_retorno       record
          resultado        smallint
         ,mensagem         char(60)
   end record
   
   define perfil char (50) 
   define atd    char (20) 
   define def    char (20)                        

   initialize l_retorno_estip.* to null
   initialize l_retorno_capa.* to null
   initialize l_retorno_corr.* to null
   initialize l_retorno_cattrf.* to null
   initialize l_retorno_veic.* to null
   initialize r_gcakfilial.* to null
   initialize l_retorno_historico.* to null

   let l_cvnnom = ""
   let l_cbtdes = ""
   let l_chassi = ""
   let l_stt_proposta = ""
   let l_corteltxt = ""
   let l_numprop = ""
   let l_segteltxt = ""
   let perfil = ""
   let atd    = ""
   let def    = ""              
                

   #-----------------------------------------------------------
   # CHAMADA DAS FUNCOES PARA CARREGAR VARIAVEIS DE TELA
   #-----------------------------------------------------------
   call faemc916_prepare()

   call faemc916_capa_proposta(p_prporgpcp, p_prpnumpcp)
      returning l_retorno_capa.*

   call cta01m18_convenio(l_retorno_capa.cvnnum)
      returning l_cvnnom

   call faemc916_estipulante(p_prporgpcp, p_prpnumpcp)
      returning l_retorno_estip.*
   let l_segteltxt = "(" , l_retorno_estip.dddcod clipped,
                     ")", l_retorno_estip.teltxt clipped

   call faemc916_corretor(p_prporgpcp, p_prpnumpcp)
      returning l_retorno_corr.*

   call fgckc811(l_retorno_corr.corsus)
      returning r_gcakfilial.*
   let l_corteltxt = "(" , r_gcakfilial.dddcod clipped,
                     ")", r_gcakfilial.teltxt clipped

   call faemc916_categ_tarif(p_prporgpcp, p_prpnumpcp)
      returning l_retorno_cattrf.*

   call cta01m18_cobertura(l_retorno_cattrf.cbtcod,l_retorno_cattrf.imsvlr)
      returning l_cbtdes

   if l_retorno_capa.prpqtditm <= 1 then
      # so busca clausulas se nao for proposta coletiva
      call faemc916_clausulas_proposta(p_prporgpcp, p_prpnumpcp)
         returning l_qtde_clausulas

   # so busca o item se nao for proposta coletiva
      call faemc916_dados_veiculo(p_prporgpcp, p_prpnumpcp)
         returning l_retorno_veic.*
      let l_chassi = l_retorno_veic.vclchsinc clipped,
                     l_retorno_veic.vclchsfnl clipped
   end if


   call faemc916_historico_proposta(p_prporgpcp, p_prpnumpcp)
      returning l_retorno_historico.*

   #-----------------------------------------------------------
   # ABERTURA DA TELA
   #-----------------------------------------------------------

   open window cta01m18 at 03,02 with form "cta01m18"
      attribute(form line 1)
   message "(F1)Funcoes,(F6) Consulta Proposta,(F17) Abandona  "


   if l_retorno_capa.cvnnum = 105 then

      #===========================================================
      # Frase alterada a pedido do Willian Michel em 07/01/2011
      #===========================================================

       #call cts08g01("A"," *CONVENIO ITAU* ",
       #                  "N","Esta e uma proposta do convênio Itaú .",
       #                  "Observe os procedimentos diferenciados",
       #                  "a seguir e através do F1.")
       call cts08g01("A","* Atenção proposta do Convênio Itaú *", 
                         "Observe os procedimentos na Base do  ", 
                         "conhecimento.Comunidade Central 24   ",  
                         "horas / Convênios / Convênio Marcep  ")  
       returning l_confirma

      #call cts08g01_6l ("A","N","Problemas com proposta: cliente contata",
      #                          "gerente, gerente liga p/ 0800-7230004. ",
      #                          "Endosso: transf seg/ger p/ 2441 (Porto)",
      #                          "e 2442 (Azul).Renovações: transf seg/ger",
      #                          " p/ 1111. Demais assuntos: atender cfe ",
      #                          "procedimentos vigentes.")
      #         returning l_confirma

   end if


   error " Aguarde, verificando procedimentos... " attribute (reverse)
   call cts14g00_proposta("",
                 g_documento.ramcod,
                 p_prporgpcp,
                 p_prpnumpcp ,
                 "",
                 "",
                 "N",
                 "2099-12-31 23:00")

   error ""

      #-----------------------------------------------------------
      # INICIO DISPLAYS
      #-----------------------------------------------------------

      #let l_numprop = p_prporgpcp clipped, p_prpnumpcp clipped

      display p_prpnumpcp to proposta
      display p_prporgpcp to origem

      if g_documento.atdnum is not null and
         g_documento.atdnum <> 0 then
         display by name g_documento.atdnum attribute(reverse)
      end if

      if g_documento.solnom is not null and
         g_documento.solnom <> " " then
         display by name g_documento.solnom attribute(reverse)
      end if
      
      #-------------------------------------------- 
      # Recupera o Segmento   
      #-------------------------------------------- 
      
      call cty31g00_recupera_segmento_proposta(p_prporgpcp,
                                               p_prpnumpcp)
                                  
      returning g_nova.perfil    ,
                g_nova.dctsgmcod 
               
      #-------------------------------------------- 
      # Recupera a Descricao do  Segmento   
      #--------------------------------------------
            
      call cty31g00_descricao_segmento(g_nova.perfil)
      returning perfil
      
      if perfil is not null then 
         display by name perfil attribute (reverse)
      end if
      
      #-------------------------------------------- 
      # Recupera o Tipo de Atendimento                         
      #-------------------------------------------- 
      
      call cty31g00_recupera_dados_proposta(p_prporgpcp,
                                            p_prpnumpcp)
      returning g_nova.clisgmcod                                            
               
      
      #--------------------------------------------              
      # Verifica se o Atendimento e Auto Premium                 
      #--------------------------------------------              
                                                                 
      call cty31g00_recupera_descricao_premium()                 
      returning atd                                   
                                                                 
                                                                 
      if atd is not null then                         
         display by name atd attribute(reverse)       
      end if  
      
      #-------------------------------------------------            
      # Verifica se a Proposta e de Deficiente Fisico            
      #-------------------------------------------------         
                                                            
      call cty31g00_recupera_descricao_fisico_proposta(p_prporgpcp,
                                                       p_prpnumpcp)                                                               
      returning def                             
                                                            
                                                            
      if def is not null then                    
         display by name def attribute(reverse)     
      end if                                                                                                                
                
                                                        
      display by name l_retorno_estip.segnom
      display l_segteltxt to segteltxt
      display l_corteltxt to corteltxt
      display by name l_retorno_capa.viginc
      display by name l_retorno_capa.vigfnl

      if l_cvnnom is not null then
         display l_cvnnom to cvnnom attribute(reverse)
      end if


      display l_retorno_historico.tfades to dscstt attribute(reverse)

      display by name l_retorno_capa.sucnom

      # so mostra o item se nao for proposta coletiva
      if l_retorno_capa.prpqtditm <= 1 then
         display by name l_retorno_veic.vclmrcnom
         display by name l_retorno_veic.vcltipnom
         display by name l_retorno_veic.vclmdlnom
         display l_chassi to vclchs
         display by name l_retorno_veic.vcllicnum
         display by name l_retorno_veic.vclanofbc
         display by name l_retorno_veic.vclanomdl
      end if

      display by name l_retorno_corr.cornom
      display by name l_retorno_corr.corsus
      display by name l_retorno_cattrf.ctgtrfcod

      if l_retorno_capa.prpqtditm > 1 then
         display 'PROPOSTA = COLETIVA' to situacao attribute(reverse)
      else
         display 'PROPOSTA' to situacao attribute(reverse)
      end if

      display l_cbtdes to cbtdes
      display l_retorno_cattrf.cbtcod to cbtcod
      display l_retorno_cattrf.cbtcod to cbtcod

      if l_qtde_clausulas < 1  then
         let g_clausulas_proposta[2].clscod = "***"
         let g_clausulas_proposta[2].clsdes = "NENHUMA CLAUSULA  ***"
         call set_count(3)
      else
         call set_count(l_qtde_clausulas)
      end if


      display array g_clausulas_proposta to s_cta01m18.*

         on key (F1)
            let m_hostname = null
            call cta13m00_verifica_status(m_hostname)
            returning l_st_erro,l_msgfuncoes

            if l_st_erro = true then
               call cta01m10_auto(g_documento.ramcod,
                                g_documento.succod,
                                g_documento.aplnumdig,
                                g_documento.itmnumdig,
                                g_funapol.dctnumseq,
                                g_documento.prporg,
                                g_documento.prpnumdig,
                                l_retorno_capa.cvnnum,
                                2)
            else
               error "Tecla F1 não disponivel no momento ! ",l_msgfuncoes ," ! Avise a Informatica "
               sleep 2
            end if

         on key (F6)
            # trecho retirado do cta00m01 - apresentacao do historico da proposta
            call cty02g00_opacc149(p_prporgpcp,p_prpnumpcp)
                 returning l_flag,l_msg
            if l_flag = "N" then
               let lr_retorno.resultado = 2
               let lr_retorno.mensagem  = "Proposta nao digitada para acompanhamento!"
               let l_msg = "Proposta nao digitada para acompanhamento!"
               call errorlog(l_msg)
            else
               if l_msg is null or
                  l_msg = " " then
                  error l_msg
                  call errorlog(l_msg)
               end if
            end if
            # fim trecho retirado do cta00m01
      end display
   close window cta01m18

   return lr_retorno.*

end function

# ------------------------------------------------------------------------------
function cta01m18_convenio(p_cvnnum)
# ------------------------------------------------------------------------------
# FUNCAO PARA APRESENTACAO DO CONVENIO

   define p_cvnnum like apamcapa.cvnnum,
          l_cvnnom char(25)

   let l_cvnnom = ""

   whenever error continue

   select cpodes into l_cvnnom
     from datkdominio
    where cponom = "cvnnum"  and
          cpocod = p_cvnnum
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> notfound then
         error "(cta01m18) Nao foi possivel ler Convenio!!"
      end if
   end if

   return l_cvnnom

end function

# ------------------------------------------------------------------------------
function cta01m18_cobertura(p_cbtcod,p_imsvlr)
# ------------------------------------------------------------------------------
   define p_cbtcod like apbmcasco.cbtcod,
          p_imsvlr like apbmcasco.imsvlr,
          l_cbtdes char (19)

   if p_cbtcod is null  then
    initialize l_cbtdes to null
   else
    if p_cbtcod = 1  then
       let l_cbtdes = "COMPREENSIVA"
       if p_imsvlr is null or p_imsvlr = 0 then
          initialize p_cbtcod to null
          initialize l_cbtdes to null
       end if
    else
       if p_cbtcod = 2  then
          let l_cbtdes = "INCENDIO/ROUBO"
       else
          if p_cbtcod = 6  then
             let l_cbtdes = "COLISAO"
          else
             if p_cbtcod = 0  then
                let l_cbtdes = "SEM COB. CASCO"
             else
                let l_cbtdes = "** NAO PREVISTA **"
             end if
          end if
       end if
    end if
   end if

   return l_cbtdes
end function