###############################################################################
# Nome do Modulo: cta01m26                                           Marcelo  #
#                                                                    Gilberto #
# Clausulas de apolice de R.E.                                       Set/1997 #
###############################################################################
#  DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                            #
#-----------------------------------------------------------------------------#
# 11/06/2001   PSI 120316   RAJI         Acesso ao Con_ct24h via (F5)         #
#-----------------------------------------------------------------------------#
# 18/07/2001                Ruiz         Tecla de funcao para consulta        #
#                                        telefone do segurado.                #
#-----------------------------------------------------------------------------#
# 27/12/2001   PSI 14451-7  Ruiz         Chamar funcao de email do segurado.  #
#-----------------------------------------------------------------------------#
# 27/03/2002   PSI 14131-8  Raji         Visualiza textos para clausula.      #
#-----------------------------------------------------------------------------#
# 25/09/2002   PSI 158607   Mariana      Qdo for PPT, exibir clausulas que a  #
#                                        a funcao 'orptc020' retorna.         #
#                                        Qdo for PPT, exibir somente teclas   #
#                                        (F6) e (F9).                         #
# 22/04/03     Resolucao 86 Aguinaldo Costa                                   #
#-----------------------------------------------------------------------------#
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- ---------------------------------------#
# 24/11/2003  Paulo, Meta    PSI172057 Alterar o menu da tela incluindo a     #
#                            OSF 28991 opcao F1 e alterando a nomenclatura    #
#                                      da opcao F5 e F8                       #
# 23/07/2004  Marcio Meta    PSI186376 Incluir a chamada da funcao cta01m10   #
#                            OSF038105 com a tecla F1.                        #
# 16/11/2006  Ligia Mattge   PSI205206 ciaempcod                              #
# 17/08/2007  Klaus, Meta    PSI211915 Alteracao de sql para contemplar a ta  #
#                                      bela rgfkmrsapccls                     #
#-----------------------------------------------------------------------------# 
# 06/10/2008 Roberto,Porto  PSI 223689                                        #
#                                       Inclusao da funcao figrc072():        # 
#                                       essa funcao evita que o programa      # 
#                                       caia devido ha uma queda da           # 
#                                       instancia da tabela de origem para    # 
#                                       a tabela de replica                   # 
#-----------------------------------------------------------------------------# 
# 30/06/2009 Amilton, Meta              Incluindo chamada da funcao cta00m06  # 
#                                       para controle de acesso ao acionamento# 
#-----------------------------------------------------------------------------#
# 23/03/2010 Carla Rampazzo PSI 219444  .Para ramo Re tirar acessos diretos e # 
#                                        chamar a funcao framo240 que retorna # 
#                                        as clausulas do documento            # 
#-----------------------------------------------------------------------------#


globals '/homedsa/projetos/geral/globals/glct.4gl'
globals "/homedsa/projetos/geral/globals/figrc072.4gl"  

define m_prep_sql smallint       

#-----------------------------------------------#
 function cta01m26_prepare()
#-----------------------------------------------#
  define l_sql char(100)

  let l_sql = " select cvnnum "
             ,"   from rsdmcvnnum "
             ,"  where prporg    = ? "
             ,"    and prpnumdig = ? "

  prepare pcta01m26001 from l_sql
  declare ccta01m26001 cursor for pcta01m26001

  let m_prep_sql = true

end function  

#------------------------------------------------------------------------------
 function cta01m26(param)
#------------------------------------------------------------------------------

 define param         record
        ramcod        like rsamseguro.ramcod,
        subcod        like rsamseguro.subcod,
        prporg        like rsdmlocal.prporg,
        prpnumdig     like rsdmlocal.prpnumdig,
        lclnumseq     like rsdmlocal.lclnumseq,
        rmemdlcod     like rsamseguro.rmemdlcod,
        sgrorg        like rsdmdocto.sgrorg,
        sgrnumdig     like rsdmdocto.sgrnumdig,
        viginc        like rsdmdocto.viginc,
        vigfnl        like rsdmdocto.vigfnl,
        dctnumseq     like rsdmdocto.dctnumseq
 end record

 define a_cta01m26    array[50] of record
        clscod        like rgfkclaus2.clscod,
        clsdes        like rgfkclaus2.clsdes
 end record

 define ws            record
        comando       char(400),
        vidramflg     char(01),
        traramflg     char(01),
        ret           integer,
        segnumdig     like rsdmdocto.segnumdig,
        cvnnum        like rsdmcvnnum.cvnnum
 end record

 define lr_ctx14g00   record
        coderr        smallint,
        mensagem      char(50)
 end record

 define arr_aux       smallint
       ,ret_clscod    char(3)
       ,l_confirma    char(01)
       ,l_acesso      smallint
       ,l_par1        char(007)
       ,l_par2        char(023)
       ,w_pf1	      integer
       ,l_param       smallint    
       ,l_resultado   smallint 
       ,l_mensagem    char(60)    


 let arr_aux    = null
 let ret_clscod = null

 for w_pf1  =  1  to  50
    initialize  a_cta01m26[w_pf1].*  to  null
 end for

 initialize  ws.*, l_resultado, l_mensagem to  null

 let int_flag  = false
 let arr_aux   = 1
 let l_param   = 0   

 let l_par1 = "FUNCOES"                  
 let l_par2 = "Carta_Transf_Corretagem"  

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cta01m26_prepare()
 end if
 

 #-----------------------------------------------------
 # Verifica se apolice e' de Vida ou de Transporte
 #-----------------------------------------------------

  if g_ppt.cmnnumdig is not null then

     for arr_aux  = 1  to 5

        let a_cta01m26[arr_aux].clscod = g_a_pptcls[arr_aux].clscod

        select clsdes
          into a_cta01m26[arr_aux].clsdes
          from agfkclaus
         where ramcod    = param.ramcod
           and clscod    = g_a_pptcls[arr_aux].clscod

     end for
  else

     let ws.vidramflg = "n"

     if param.ramcod = 57   or  param.ramcod = 457   or
        param.ramcod = 80   or  param.ramcod = 981   or
        param.ramcod = 81   or  param.ramcod = 982   or
        param.ramcod = 83   or  param.ramcod = 589   or
        param.ramcod = 91   or  param.ramcod = 991   or
        param.ramcod = 93   or  param.ramcod = 993   or
        param.ramcod = 1391 or  param.ramcod = 1329  or
        param.ramcod = 997  or  param.ramcod = 980   or
        param.ramcod = 990  then
        let ws.vidramflg = "s"
     end if

     let ws.traramflg = "n"

     if param.ramcod = 21   or param.ramcod = 621 or
        param.ramcod = 22   or param.ramcod = 622 or
        param.ramcod = 24   or param.ramcod = 632 or
        param.ramcod = 25   or param.ramcod = 525 or
        param.ramcod = 33   or param.ramcod = 433 or
        param.ramcod = 35   or param.ramcod = 435 or
        param.ramcod = 52   or param.ramcod = 652 or
        param.ramcod = 54   or param.ramcod = 654 or
        param.ramcod = 55   or param.ramcod = 655 or
        param.ramcod = 56   or param.ramcod = 656 then
        let ws.traramflg = "s"
     end if


     if ws.traramflg = "n" then

        if ws.vidramflg = "n" then

           ---> Define Valores p/ Seq. Local Risco e Bloco, pois os servicos 
           ---> antigos nao tem estes dados relacionados a ele              

           if g_documento.lclnumseq is null then
              let g_documento.lclnumseq = 1
           end if

           if g_documento.rmerscseq is null then
              if param.ramcod = 116 then ---> Condominio
                 let g_documento.rmerscseq = 1
              else 
                 let g_documento.rmerscseq = 0
              end if
           end if

           ---> Retorna Clausulas do Documento
           call framo240(param.prporg
                        ,param.prpnumdig
                        ,g_documento.lclnumseq
                        ,g_documento.rmerscseq
                        ,param.ramcod
                        ,param.rmemdlcod)
               returning l_resultado
                        ,l_mensagem
                        ,a_cta01m26[1].*
                        ,a_cta01m26[2].*
                        ,a_cta01m26[3].*
                        ,a_cta01m26[4].*
                        ,a_cta01m26[5].*
                        ,a_cta01m26[6].*
                        ,a_cta01m26[7].*
                        ,a_cta01m26[8].*
                        ,a_cta01m26[9].*
                        ,a_cta01m26[10].*
                        ,a_cta01m26[11].*
                        ,a_cta01m26[12].*
                        ,a_cta01m26[13].*
                        ,a_cta01m26[14].*
                        ,a_cta01m26[15].*
                        ,a_cta01m26[16].*
                        ,a_cta01m26[17].*
                        ,a_cta01m26[18].*
                        ,a_cta01m26[19].*
                        ,a_cta01m26[20].*
                        ,a_cta01m26[21].*
                        ,a_cta01m26[22].*
                        ,a_cta01m26[23].*
                        ,a_cta01m26[24].*
                        ,a_cta01m26[25].*
                        ,a_cta01m26[26].*
                        ,a_cta01m26[27].*
                        ,a_cta01m26[28].*
                        ,a_cta01m26[29].*
                        ,a_cta01m26[30].*
                        ,a_cta01m26[31].*
                        ,a_cta01m26[32].*
                        ,a_cta01m26[33].*
                        ,a_cta01m26[34].*
                        ,a_cta01m26[35].*
                        ,a_cta01m26[36].*
                        ,a_cta01m26[37].*
                        ,a_cta01m26[38].*
                        ,a_cta01m26[39].*
                        ,a_cta01m26[40].*
                        ,a_cta01m26[41].*
                        ,a_cta01m26[42].*
                        ,a_cta01m26[43].*
                        ,a_cta01m26[44].*
                        ,a_cta01m26[45].*
                        ,a_cta01m26[46].*
                        ,a_cta01m26[47].*
                        ,a_cta01m26[48].*
                        ,a_cta01m26[49].*
                        ,a_cta01m26[50].* 

           if l_resultado <> 0 then
              error " Problema na busca das CLAUSULAS!" 
                    ,l_resultado , "-" , l_mensagem
           end if

	   ---> Tratamento para nao apresentar a msg "NENHUMA CLAUSULA"
           if a_cta01m26[1].clscod is not null and
              a_cta01m26[1].clscod <> "    "   then

              let arr_aux = 51          
	   end if
        else ---> Vida

           let ws.comando = "select clsdes        ",
                            "  from rgfkclaus     ",
                            " where ramcod    = ? ",
                            "   and rmemdlcod = ? ",
                            "   and clscod    = ? "

           prepare comando_aux2 from  ws.comando
           declare c_cta01m262 cursor for  comando_aux2
        end if

        ---> Tratamento so para o Vida
        if ws.vidramflg = "s" then

           declare c_rsdmclaus cursor for

              select clscod
                from rsdmclaus
               where prporg    = param.prporg     and
                     prpnumdig = param.prpnumdig  and
                     lclnumseq = param.lclnumseq  and
                     clsstt    = "A"

           whenever error continue

           foreach c_rsdmclaus  into  a_cta01m26[arr_aux].clscod

              let a_cta01m26[arr_aux].clsdes = "** NAO CADASTRADA **"

              open c_cta01m262 using param.ramcod
                                    ,param.rmemdlcod
                                    ,a_cta01m26[arr_aux].clscod

              fetch c_cta01m262  into  a_cta01m26[arr_aux].clsdes
 
              let arr_aux = arr_aux + 1
  
              if arr_aux  >  50   then
                 error " Limite excedido, documento c/ mais de 50 clausulas!"
                 exit foreach
              end if
           end foreach

           whenever error stop

           if sqlca.sqlcode <> 0    and
              sqlca.sqlcode <> 100  then
              error " Informacoes sobre CLAUSULAS nao disponiveis no momento!"
              let a_cta01m26[2].clscod = " ***"
              let a_cta01m26[2].clsdes = "SEM CONSULTA NO MOMENTO  ***"
              let arr_aux = 3
           end if
        end if
     end if

     if arr_aux = 1  then

        if ws.traramflg  = "s" or #--> Transporte
           param.ramcod  = 11 or param.ramcod = 111 or  #--> Incendio
           param.ramcod  = 71 or param.ramcod = 171 or
           param.ramcod = 195 then #--> Riscos Diversos/Garantia Estendida
           let a_cta01m26[2].clscod = " ***"
           let a_cta01m26[2].clsdes = "CONSULTA NAO DISPONIVEL  ***"
           let arr_aux = 3
        else
           let a_cta01m26[2].clscod = " ***"
           let a_cta01m26[2].clsdes = "NENHUMA CLAUSULA  ***"
           let arr_aux = 3
        end if
     end if
  end if

  initialize ws.ret  to null

  call acess_prog("Con_ct24h", "ctg3")  returning ws.ret

  if ws.ret  <>  -1   then
     if param.ramcod = 16 or param.ramcod = 524  then
        message "(F1)Func,(F4)Proc,(F5)ConCt24h,(F6)Tel/e-mail,(F7)IS,(F8)Loc/cob/frq,(F9)Parc,(F10)Auto"  
     else
        message "(F1)Func (F4)Proc,(F5)ConCt24h,(F6)Tel/e-mail,(F7)IS,(F8)Loc/cob/frq,(F9)Parc"  
     end if

     if param.ramcod = 06 then  
        message "(F1)Func,(F4)Proc,(F5)ConCt24h,(F6)Tel/e-mail,(F9)Parc"    
     end if 
  else
     if param.ramcod = 16 or param.ramcod = 524   then
        message "(F1)Func,(F4)Proc,(F6)Tel/e-mail,(F7)IS,(F8)Loc/cob/frq,(F9)Parc,(F10)Auto," 
     else
        message "(F1)Func,(F4)Proc,(F6)Tel/e-mail,(F7)IS,(F8)Loc/cob/frq,(F9)Parc"  
     end if

     if param.ramcod = 06 then
        message "(F1)Func,(F4)Proc,(F5)ConCt24h,(F6)Tel/e-mail,(F9)Parc" 
     end if  
  end if

  #-----------------------------------------------------------
  # Verifica se existe ligacao para advertencia ao atendente
  #-----------------------------------------------------------
  call cta00m06_acionamento(g_issk.dptsgl)
       returning l_acesso 
 
  if l_acesso = true then 
     call cta01m09(g_documento.succod,
                   g_documento.ramcod,
                   g_documento.aplnumdig,
                   0)
  end if                     
    
  open window cta01m26 at 16,02 with form "cta01m26"
                       attribute(form line first)

  call set_count(arr_aux - 1)

  display array a_cta01m26 to s_cta01m26.*

    on key (F1)
       # Se for protecao patrimonial   
       if g_ppt.cmnnumdig is not null then
          call cta01m10_propat(g_ppt.segnumdig, l_param)
       else
          open ccta01m26001 using param.prporg,
                                  param.prpnumdig
          whenever error continue
          fetch ccta01m26001 into ws.cvnnum
          whenever error stop

          if sqlca.sqlcode <> 0 then

             if sqlca.sqlcode <> notfound then
                error " Erro select ccta01m26001",sqlca.sqlcode,'/',sqlca.sqlerrd[2] sleep 2
                error " cta01m26()",param.prporg,'/',param.prpnumdig sleep 2
                exit display
             else
                let ws.cvnnum = 0
             end if
          end if

          call cta01m10_re_transp(g_documento.ramcod,
                                  g_documento.succod,
                                  g_documento.aplnumdig,
                                  g_documento.prporg,
                                  g_documento.prpnumdig,
                                  ws.cvnnum)
       end if

    on key (F4)
       if g_ppt.cmnnumdig is null then
          select cvnnum
              into ws.cvnnum
              from rsdmcvnnum
             where prporg    = param.prporg
               and prpnumdig = param.prpnumdig
          if sqlca.sqlcode = notfound then
             let ws.cvnnum = 0  # convenio Porto Seguro
          end if
       else
          let ws.cvnnum = 0  # convenio Porto Seguro
       end if
       call ctn13c00(ws.cvnnum)

    on key (F5)  ###  Consultas Genericas (Con_ct24h)
       if ws.ret  <>  -1   then
          initialize ws.ret  to null
          call chama_prog("Con_ct24h", "ctg3", "")  returning ws.ret
          if ws.ret  =  -1   then
             error " Modulo Con_ct24h nao disponivel no momento!"
          end if
       end if

    on key (F6)  ### Telefones/email  do Segurado
       if (param.ramcod    is not null  and
           param.sgrorg    is not null  and
           param.sgrnumdig is not null ) or
           g_ppt.cmnnumdig is not null  then
          if g_ppt.cmnnumdig is not null  then
             let ws.segnumdig = g_ppt.segnumdig
          else
             select segnumdig
               into ws.segnumdig
               from rsdmdocto
              where prporg    = param.sgrorg
                and prpnumdig = param.sgrnumdig
             if sqlca.sqlcode <> 0  then
                exit display
             end if
          end if

          call figrc072_setTratarIsolamento() 
          
          call cty17g00_ssgtemail(ws.segnumdig,g_documento.c24soltipcod) ## psi201987
          
          if g_isoAuto.sqlCodErr <> 0 then                
             error "Atualizacao do E-mail Temporariamente Indisponivel! Erro: " 
                   ,g_isoAuto.sqlCodErr                   
          end if                                          
          
          call figrc072_setTratarIsolamento()
          
          call cty17g00_ssgttel  (2, ws.segnumdig,g_documento.c24soltipcod) ## psi201987
          
          if g_isoAuto.sqlCodErr <> 0 then                                         
             error "Atualizacao de Telefone Temporariamente Indisponivel! Erro: "    
                   ,g_isoAuto.sqlCodErr                                            
          end if                                                                   
       
       end if

    on key (F7)  ###  Importancias seguradas
       call cta01m25(param.ramcod   ,  param.prporg,
                     param.prpnumdig,  param.rmemdlcod,
                     param.sgrorg   ,  param.sgrnumdig,
                     param.dctnumseq)

    on key (F8)  ###  Locais/coberturas/franquias
       call cta01m21(param.prporg   , param.prpnumdig, param.sgrorg,
                     param.sgrnumdig, param.rmemdlcod, param.viginc,
                     param.vigfnl)

    on key (F9)  ###  Parcelas
       if g_ppt.cmnnumdig is null then
          call cta01m06(g_documento.succod,
                        g_documento.ramcod,
                        param.subcod,
                        g_documento.aplnumdig)
       else
          call rpt80m00 ("C",g_ppt.cmnnumdig)
       end if


    on key (F10) ### Garantia Estendida - Veiculo
       if param.ramcod = 16 or param.ramcod = 524  then
          call cta01m28(param.prporg,
                        param.prpnumdig)
       end if

    on key (return)
       let arr_aux = arr_curr()
       let ret_clscod = a_cta01m26[arr_aux].clscod

       call ctc56m03(g_documento.ciaempcod,
                     param.ramcod,
                     param.rmemdlcod,
                     ret_clscod)


    on key (interrupt,control-c)

       if g_documento.atdnum is null or
          g_documento.atdnum =  0    then

          initialize l_confirma to null

          while l_confirma = "N"      or
                l_confirma = " "      or
                l_confirma is null

             call cts08g01("A","S",""
                          ,"CONFIRMOU OS DADOS DO CLIENTE ? "
                          ,"","")
                  returning l_confirma
          end while
       end if
       exit display

 end display

 close window cta01m26
 let int_flag = false

end function  ###  cta01m26
