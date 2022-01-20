###############################################################################
# Nome do Modulo: cte02m01                                          Ruiz      #
#                                                                   Akio      #
# Mostra todas as funcoes das pendencias                           Mai/2000   #
###############################################################################
# Alteracoes:                                                                 #
#                                                                             #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                             #
#-----------------------------------------------------------------------------#
# 13/09/2000  PSI 11546-0  Raji         Adicionado funcoes ETAPAS/IMPRESSAO   #
#-----------------------------------------------------------------------------#
# 13/07/2001  Claudinha    Ruiz         tirar o prepare gcaksusep,gcakfilial, #
#                                       gcakcorr.                             #
###############################################################################
#                                                                             #
#                       * * * Alteracoes * * *                                #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -----------------------------------    #
# 28/01/2004  ivone meta     PSI172308 Adaptar modulo para atender a tela de  #
#                            OSF31216  oendencias de Estudo de Aceitacao      #
#-----------------------------------------------------------------------------#
# 17/12/2009  Ricardo, Meta  PSI244597 Inclusão rotina da nova tela de        #
#                                      parâmetros/condições da Aceitação.     #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glcte.4gl"

 define m_prep_sql  smallint,
        m_erro      smallint
 define m_hostname  char(10)
 
#-------------------------#
function cte02m01_prepara()
#-------------------------#

  define l_sql char(400)
  
  
  let l_sql = ' select corsus ',
                ' from apamcor ',
               ' where prporgpcp = ? ',
                 ' and prpnumpcp = ? '

  prepare pcte02m01001 from l_sql
  declare ccte02m01001 cursor for pcte02m01001
  
    
  let l_sql = ' select aacatdsitcod ',
                ' from aacmatd ',
               ' where aacdptatdcod = ? ',
                 ' and aacatdano = ? ',
                 ' and aacatdnum = ? '

  prepare pcte02m01002 from l_sql
  declare ccte02m01002 cursor for pcte02m01002

  let l_sql = " select corasspndflg ",
                " from dackass ",
               " where corasscod = ? "

  prepare pcte02m01003 from l_sql
  declare ccte02m01003 cursor for pcte02m01003

  let l_sql = " select dddcod, ",
                     " ctttel, ",
                     " faxnum, ",
                     " pndretcttnom ",
                " from dacmpndret ",
               " where corlignum = ? ",
                 " and corligano = ? "

  prepare pcte02m01004 from l_sql
  declare ccte02m01004 cursor for pcte02m01004

  let l_sql = " select cornom ",
                " from gcaksusep a, ",
                     " gcakcorr b ",
               " where a.corsus = ? ",
                 " and b.corsuspcp = a.corsuspcp "

  prepare pcte02m01005 from l_sql
  declare ccte02m01005 cursor for pcte02m01005

  let l_sql = " select funnom ",
                " from isskfunc ",
               " where funmat = ? ",
                 " and empcod = ? ",
                 " and usrtip = 'F' "

  prepare pcte02m01006 from l_sql
  declare ccte02m01006 cursor for pcte02m01006

  let l_sql = " select corsus ",
                " from dacrligsus ",
               " where corlignum = ? ",
                 " and corligano = ? "

  prepare pcte02m01007 from l_sql
  declare ccte02m01007 cursor for pcte02m01007

  let l_sql = " select empcod, ",
                     " funmat ",
                " from dacrligfun ",
               " where corlignum = ? ",
                 " and corligano = ? "

  prepare pcte02m01008 from l_sql
  declare ccte02m01008 cursor for pcte02m01008

  let l_sql = " select c24paxnum, ",
                     " cademp, ",
                     " cadmat ",
                " from dacmlig ",
               " where corlignum = ? ",
                 " and corligano = ? "

  prepare pcte02m01009 from l_sql
  declare ccte02m01009 cursor for pcte02m01009

  let l_sql = " select a.caddat, ",
                      " a.cadhor, ",
                      " a.cademp, ",
                      " a.cadmat, ",
                      " b.c24solnom ",
                 " from dacmatdpndsit a, dacmlig b ",
                " where a.corlignum = ? ",
                  " and a.corligano = ? ",
                  " and a.corligitmseq = ? ",
                  " and b.corlignum = a.corlignum ",
                  " and b.corligano = a.corligano "

  prepare sel_dados from l_sql
  declare c_dados cursor for sel_dados

  let l_sql = " select prpnumpcp ",
                " from dacrligorc ",
               " where corligitmseq = ? ",
                 " and corlignum = ? ",
                 " and corligano = ? "

  prepare sel_orcamento from l_sql
  declare c_orcamento cursor for sel_orcamento

  let l_sql = " select prgsgl ",
                " from dackprgext ",
               " where prgextcod = 3 "

  prepare sel_programa from l_sql
  declare c_programa cursor for sel_programa

  let m_prep_sql = true

end function

#----------------------#
function cte02m01(entra)
#----------------------#

 define entra        record
        corlignum    like dacmatdpndsit.corlignum,
        corligano    like dacmatdpndsit.corligano,
        corligitmseq like dacmatdpndsit.corligitmseq,
        aacdptatdcod like aacmatd.aacdptatdcod,
        aacatdnum    like aacmatd.aacatdnum,
        aacatdano    like aacmatd.aacatdano,
        aacatdasscod like aacmatd.aacatdasscod,
        prporgpcp    like apamorc.prporgpcp,
        prpnumpcp    like apamorc.prpnumpcp
 end record

 define ws           record
        data         like dacmatdpndsit.caddat,
        hora         like dacmatdpndsit.cadhor,
        solnom       like dacmlig.c24solnom,
        empcod       like dacmatdpndsit.cademp,
        funmat       like dacmatdpndsit.cadmat,
        corasscod    like dackass.corasscod
 end record

 define a_cte02m01   array[08] of record
        fundes       char(16),
        funcod       decimal(2,0)
 end record

 define scr_aux      smallint,
        arr_aux      smallint,
        l_codigo     smallint

    
 
 if m_prep_sql <> true or
    m_prep_sql is null then
    call cte02m01_prepara()  
 end if

 if entra.corlignum   is null   then
    error " Numero de ligacao nao informado, AVISE INFORMATICA!"
    return
 end if

 let l_codigo = null

 open window cte02m01 at 11,59 with form "cte02m01"
    attribute(form line 1, border)

 let int_flag = false

 initialize a_cte02m01 to null

 if g_issk.sissgl = "Pnd_cor24h" then

    open c_dados  using entra.corlignum,
                        entra.corligano,
                        entra.corligitmseq
    fetch c_dados  into ws.data,
                        ws.hora,
                        ws.empcod,
                        ws.funmat,
                        ws.solnom
    close c_dados
    if  sqlca.sqlcode <> 0  then
        error " Ligacao nao encontrada, AVISE INFORMATICA!"
        return
    end if

    select corasscod
      into ws.corasscod
      from dacmligass
     where corlignum = entra.corlignum
       and corligano = entra.corligano
       and corligitmseq = entra.corligitmseq

     if sqlca.sqlcode <> 0  then
        initialize ws.corasscod to null
     end if

  end if

 let a_cte02m01[01].fundes = "HISTORICO"
 let a_cte02m01[01].funcod = 01
 let a_cte02m01[02].fundes = "ESPELHO"
 let a_cte02m01[02].funcod = 02
 let a_cte02m01[03].fundes = "LIGACOES"
 let a_cte02m01[03].funcod = 03
 let a_cte02m01[04].fundes = "ETAPAS"
 let a_cte02m01[04].funcod = 04
 let a_cte02m01[05].fundes = "IMPRESSAO"
 let a_cte02m01[05].funcod = 05
 let a_cte02m01[06].fundes = "ORCAMENTO"
 let a_cte02m01[06].funcod = 06
 let arr_aux = 06
 
 
 if g_issk.sissgl = "Pnd_Estudo" or g_issk.sissgl = "Estudo_act" then       #psi 172308 ivone
    let a_cte02m01[07].funcod = 07
    let a_cte02m01[07].fundes = "ESTUDO"
    let arr_aux = 07
 end if

 let l_codigo = cte02m01_mostra_contato(ws.corasscod)

 if l_codigo = 2 then
    close window cte02m01
    let int_flag = false
    return
 end if

 if l_codigo <> 1 then
    if a_cte02m01[07].funcod is null then
       let a_cte02m01[07].funcod = 08
       let a_cte02m01[07].fundes = "CONTATO"
       let arr_aux = 08
    else
       let a_cte02m01[08].funcod = 08
       let a_cte02m01[08].fundes = "CONTATO"
       let arr_aux = 08
    end if
 end if

 message "(F8)Seleciona"
 call set_count(arr_aux)

 display array a_cte02m01 to s_cte02m01.*

    on key (interrupt,control-c, control-o)
       initialize a_cte02m01   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let scr_aux = scr_line()

       call cte02m01_chamada(entra.*,
                             ws.*,
                             a_cte02m01[arr_aux].funcod)

       if m_erro then
          let m_erro = false
          exit display
       end if

 end display

 close window  cte02m01

 let int_flag = false

end function  #--  cte02m01

#----------------------------------------#
function cte02m01_chamada(param,ws,param2)
#----------------------------------------#

 define param        record
        corlignum    like dacmatdpndsit.corlignum,
        corligano    like dacmatdpndsit.corligano,
        corligitmseq like dacmatdpndsit.corligitmseq,
        aacdptatdcod like aacmatd.aacdptatdcod,
        aacatdnum    like aacmatd.aacatdnum,
        aacatdano    like aacmatd.aacatdano,
        aacatdasscod like aacmatd.aacatdasscod,
        prporgpcp    like apamorc.prporgpcp,
        prpnumpcp    like apamorc.prpnumpcp
 end record

 define ws           record
        data         like dacmatdpndsit.caddat,
        hora         like dacmatdpndsit.cadhor,
        solnom       like dacmlig.c24solnom,
        empcod       like dacmatdpndsit.cademp,
        funmat       like dacmatdpndsit.cadmat,
        corasscod    like dackass.corasscod
 end record

 define ws1          record
        corsus       like dacrligsus.corsus,
        cornom       like gcakcorr.cornom,
        funnom       like isskfunc.funnom,
        data         like dacmatdpndsit.caddat,
        hora         like dacmatdpndsit.cadhor
 end record

 define param2       record
        funcod       dec(2,0)
 end record

 define l_prpnumpcp  like dacrligorc.prpnumpcp,
        l_param      char(42),
        l_prgsgl     char(10),
        l_ret        smallint

 define l_retsitcod  like aacmatd.aacatdsitcod,
        l_aux        char(001),
        l_codigo     smallint,
        l_msg        char(100),
        l_st_erro       smallint


 #-------------------------------------
 # Aciona telas para funcao selecionada
 #-------------------------------------

 let ws1.data   = today
 let ws1.hora   = current hour to minute
 let ws1.corsus = null
 let l_codigo   = null
 let l_st_erro  = 1  
 

 case param2.funcod

    when  01

         if g_issk.sissgl = "Pnd_cor24h" then
            call cte01m04("A","N",param.corlignum, param.corligano,
                          param.corligitmseq,ws.corasscod)
         end if
         if g_issk.sissgl = "Pnd_Estudo" or g_issk.sissgl = "Estudo_act" then
            let l_aux = "A"
            
            call cty02g02_oaaca152(l_aux,param.aacdptatdcod,param.aacatdnum,
                                   param.aacatdano,param.aacatdasscod)
                 returning l_msg                   
            if l_msg is not null then
                 error l_msg
            end if                              
            
            {call oaaca152(l_aux,param.aacdptatdcod,param.aacatdnum,
                             param.aacatdano,param.aacatdasscod)}
        end if

    when  02

         if g_issk.sissgl = "Pnd_cor24h" then
            open ccte02m01007 using param.corlignum,
                                param.corligano
            whenever error continue
            fetch ccte02m01007 into ws1.corsus
            whenever error stop

            if sqlca.sqlcode <> 0 then
               initialize ws1.corsus to null
            end if
         end if

         if g_issk.sissgl = "Pnd_Estudo" or g_issk.sissgl = "Estudo_act" then
              open ccte02m01001  using param.prporgpcp, param.prpnumpcp
              whenever error continue
              fetch ccte02m01001  into ws1.corsus
              whenever error stop
              if sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = 100 then
                   initialize ws1.corsus to null
                else
                   error "Erro Select cctem02m01001 ",sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]  sleep 2
                   error "cte02m01_selec_estudo() : ", param.corlignum, param.corligano sleep 2
                   let m_erro = true
                   return
                end if
              end if

         end if
         
          # Função colocada Devido o Desligamento do Banco U37 29/09/2010
          let m_hostname = null                                                           
          call cta13m00_verifica_instancias_u37()                                   
            returning l_st_erro,l_msg                                                     
                                                                                          
          if l_st_erro = true then                                                                 
             call ctn09c00(ws1.corsus)         
          else                                                                            
            error "Função não disponivel no momento ! ",l_msg ," ! Avise a Informatica "
            sleep 2                                                                       
          end if                                                                                                     
         
         #call ctn09c00(ws1.corsus)
         
    when  03
         
         if g_issk.sissgl = "Pnd_cor24h" then
            open ccte02m01007 using param.corlignum,
                                param.corligano
            whenever error continue
            fetch ccte02m01007 into ws1.corsus
            whenever error stop
         
            if sqlca.sqlcode <> 0 then
               initialize ws1.corsus to null
            end if
         end if

         if g_issk.sissgl = "Pnd_Estudo" or g_issk.sissgl = "Estudo_act" then
            open ccte02m01001  using param.prporgpcp, param.prpnumpcp
            whenever error continue
            fetch ccte02m01001  into ws1.corsus
            whenever error stop
            if sqlca.sqlcode <> 0 then
              if sqlca.sqlcode = 100 then
                 let ws1.corsus = null
              else
                 error "Erro Select cctem02m01001 ",sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]  sleep 2
                 error "cte02m01_chamada(): ",param.prporgpcp,'/',param.prpnumpcp sleep 2
                 let m_erro = true
                 return
              end if
            end if
         end if

         select gcakcorr.cornom
             into ws1.cornom
             from gcaksusep, gcakcorr
            where gcaksusep.corsus = ws1.corsus
              and gcaksusep.corsuspcp = gcakcorr.corsuspcp

         open ccte02m01006 using ws.funmat, ws.empcod
         fetch ccte02m01006 into ws1.funnom

         call cte01m03(ws.data,ws.hora,ws.solnom,ws1.corsus,ws1.cornom,
                       ws.empcod,ws.funmat,ws1.funnom,"",ws.corasscod)


    when  04
         # Visualizacao das etapas para ligacao

         #inicio psi172308 ivone
         if g_issk.sissgl = "Pnd_cor24h" then
            call cte01m05(param.corlignum, param.corligano, param.corligitmseq)   ## PSI 172308
         end if

         if g_issk.sissgl = "Pnd_Estudo" or g_issk.sissgl = "Estudo_act" then
              
              call cty02g02_oaaca151(param.aacdptatdcod,param.aacatdnum,
                             param.aacatdano,param.aacatdasscod)              
                   returning l_msg          
              
              if l_msg is not null then 
                 error l_msg
              end if                                                                               
              {call oaaca151(param.aacdptatdcod,param.aacatdnum,
                             param.aacatdano,param.aacatdasscod)}
         end if
         #fim psi172308 ivone

    when  05
         # Impressao historico da ligacao do corretor

         if g_issk.sissgl = "Pnd_cor24h" then
            call cte02m02(param.corlignum, param.corligano, param.corligitmseq)   ## PSI 172308
         end if

         if g_issk.sissgl = "Pnd_Estudo" or g_issk.sissgl = "Estudo_act" then
            error "Funcao nao disponivel"    sleep 2
         end if

    when 06
         #Orcamento
         let l_prpnumpcp = null

         if g_issk.sissgl = "Pnd_cor24h" then
             open c_orcamento using param.corligitmseq
                                   ,param.corlignum
                                   ,param.corligano
             fetch c_orcamento into l_prpnumpcp
             close c_orcamento
         end if

         let l_prgsgl = null

         open c_programa
         fetch c_programa into l_prgsgl
         close c_programa

         let l_param = null
         let l_param[01,05]= "ctg12"
         let l_param[06,10]= "00000"
         let l_param[11,20]= param.corlignum using "&&&&&&&&&&"
         let l_param[21,25]= param.corligitmseq using "&&&&&"
         let l_param[26,30]= g_c24paxnum
         let l_param[31,34]= param.corligano

         if l_prpnumpcp is not null  then
            let l_param[35,42] = l_prpnumpcp
         else
            let l_param[35,42] = param.prpnumpcp
         end if

         if g_issk.funmat = 601566 or
            g_issk.funmat = 7339   then
            display "chama_prog = ", l_prgsgl," ",l_param
         end if
         # Passa a pendencia para "Em Analise"!

         if g_issk.sissgl = "Pnd_cor24h" then
            select c24pndsitcod from dacmatdpndsit
             where corlignum    = param.corlignum
               and corligano    = param.corligano
               and corligitmseq = param.corligitmseq
               and c24pndsitcod = 1

            if status = notfound then
               insert into dacmatdpndsit(corlignum,corligano,corligitmseq,
                                         c24pndsitcod, caddat, cadhor, cademp,
                                         cadmat)
                      values(param.corlignum, param.corligano, param.corligitmseq,
                             1, ws1.data, ws1.hora, g_issk.empcod, g_issk.funmat)
            end if
        end if

         call chama_prog("Orc_ct24h2", l_prgsgl, l_param)
         returning l_ret

         if l_ret <> 0 then
            error "Erro ao executar o Orcamento!"
         end if

    when 07

         open ccte02m01002  using param.aacdptatdcod,
                                  param.aacatdano,
                                  param.aacatdnum
         whenever error continue
         fetch ccte02m01002  into l_retsitcod
         whenever error stop
         if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = 100 then
              let l_retsitcod = null
           else
              error "Erro Select cctem02m01002 ",sqlca.sqlcode, ' / ',sqlca.sqlerrd[2]  sleep 2
              error "cte02m01_chamada() : ", param.aacdptatdcod, ' / ',
                                             param.aacatdano, ' / ',
                                             param.aacatdnum sleep 2
              let m_erro = true
              return
           end if
         end if

         if l_retsitcod is not null and
            l_retsitcod = 6 or l_retsitcod = 5 then
            
            call cty02g02_oaacc220(param.aacdptatdcod,param.aacatdnum,param.aacatdano,"A",
                                   param.prporgpcp, param.prpnumpcp)  #PSI 244597 - passagem dos parametros prporgpcp e prpnumpcp
                 returning l_msg
            #call oaacc220(param.aacdptatdcod,param.aacatdano,param.aacatdnum,"A")
            
            if l_msg is not null then
                 error l_msg
            end if       
            
         else            
            call cty02g02_oaaca150(param.aacdptatdcod,param.aacatdano,param.aacatdnum,true,
                                   param.prporgpcp, param.prpnumpcp)                          
                 returning l_retsitcod,l_msg
                 
            if l_msg is not null then 
                 error l_msg
            end if       
                 
                 
            {call oaaca150(param.aacdptatdcod,param.aacatdano,param.aacatdnum,true,
                          param.prporgpcp, param.prpnumpcp)
                 returning l_retsitcod}
         end if

    when 08
      let l_codigo = cte02m01_exibe_info_contato(param.corlignum,
                                                 param.corligano)
      if l_codigo <> 0 then
         let m_erro = true
      end if

 end case

 let int_flag = false

end function  #--  cte02m01_chamada

#-------------------------------------------#
function cte02m01_mostra_contato(l_corasscod)
#-------------------------------------------#

  define l_corasscod    like dackass.corasscod,
         l_corasspndflg like dackass.corasspndflg,
         l_codigo       smallint

  #-------------------------------------------#
  # --DESCRICAO DOS POSSIVEIS RETORNO DE CODIGO

      # 0 = EXIBE A LINHA "CONTATO"
      # 1 = NAO EXIBE A LINHA "CONTATO"
      # 2 = ERRO DE ACESSO A BASE DE DADOS
  #-------------------------------------------#

  let l_corasspndflg = null
  let l_codigo       = null

  open ccte02m01003 using l_corasscod

  whenever error continue
  fetch ccte02m01003 into l_corasspndflg
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let l_codigo = 1
     else
        error "Erro SELECT ccte02m01003 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
        error "cte02m01_mostra_contato() | ,", l_corasscod sleep 2
        let l_codigo = 2
     end if
  else
    if l_corasspndflg = "S" then
       let l_codigo = 0
    else
       let l_codigo = 1
    end if
  end if

  return l_codigo

end function

#------------------------------------------------#
function cte02m01_exibe_info_contato(lr_parametro)
#------------------------------------------------#

  define lr_parametro    record
         corlignum       like dacmatdpndsit.corlignum,
         corligano       like dacmatdpndsit.corligano
  end record

  define lr_dados        record
         dddcod          like dacmpndret.dddcod,
         ctttel          like dacmpndret.ctttel,
         faxnum          like dacmpndret.faxnum,
         pndretcttnom    like dacmpndret.pndretcttnom,
         corsus          like dacrligsus.corsus,
         cornom          like gcakcorr.cornom,
         empcod          like dacrligfun.empcod,
         funmat          like dacrligfun.funmat,
         funnom          like isskfunc.funnom,
         c24paxnum       like dacmlig.c24paxnum,
         cademp          like dacmlig.cademp,
         cadmat          like dacmlig.cadmat,
         nome_atend      like isskfunc.funnom,
         susep_ou_funmat char(48),
         atendnome       char(27),
         msg             char(10),
         erro            smallint, # 0 - Ok | 1 - Erro de acesso a base de dados
         espera          char(02)
  end record

  initialize lr_dados to null

  let lr_dados.erro = 0

  # --BUSCA DDD, TELEFONE, FAX E CONTATO
  open ccte02m01004 using lr_parametro.corlignum,
                          lr_parametro.corligano

  whenever error continue
  fetch ccte02m01004 into lr_dados.dddcod,
                          lr_dados.ctttel,
                          lr_dados.faxnum,
                          lr_dados.pndretcttnom
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_dados.dddcod       = null
        let lr_dados.ctttel       = null
        let lr_dados.faxnum       = null
        let lr_dados.pndretcttnom = null
     else
        error "Erro SELECT ccte02m01004 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
        error "cte02m01_exibe_info_contato() | ,", lr_parametro.corlignum, "|",
                                                   lr_parametro.corligano sleep 2
        let lr_dados.erro = 1
     end if
  end if

  # --BUSCA A SUSEP DO CORRETOR
  open ccte02m01007 using lr_parametro.corlignum,
                          lr_parametro.corligano

  whenever error continue
  fetch ccte02m01007 into lr_dados.corsus
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then

        # --BUSCA A EMPRESA E A MATRICULA DO FUNCIONARIO
        open ccte02m01008 using lr_parametro.corlignum,
                                lr_parametro.corligano

        whenever error continue
        fetch ccte02m01008 into lr_dados.empcod,
                                lr_dados.funmat
        whenever error stop

        if sqlca.sqlcode <> 0 then
           if sqlca.sqlcode = notfound then
              let lr_dados.empcod = null
              let lr_dados.funmat = null
           else
              error "Erro SELECT ccte02m01008 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
              error "cte02m01_exibe_info_contato() | ,", lr_parametro.corlignum, "|",
                                                         lr_parametro.corligano sleep 2
              let lr_dados.erro = 1
           end if
        else
          # --BUSCA O NOME DO FUNCIONARIO
          open ccte02m01006 using lr_dados.funmat,
                                  lr_dados.empcod

          whenever error continue
          fetch ccte02m01006 into lr_dados.funnom
          whenever error stop

          if sqlca.sqlcode <> 0 then
             if sqlca.sqlcode = notfound then
                let lr_dados.funnom = null
             else
                error "Erro SELECT ccte02m01006 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
                error "cte02m01_exibe_info_contato() | ,", lr_dados.funmat, "|",
                                                           lr_dados.empcod sleep 2
                let lr_dados.erro = 1
             end if
          end if

          let lr_dados.msg             = "Matricula:"
          let lr_dados.susep_ou_funmat = lr_dados.funmat using "<<<<<&", " ", lr_dados.funnom

        end if

     else
        error "Erro SELECT ccte02m01007 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
        error "cte02m01_exibe_info_contato() | ,", lr_parametro.corlignum, "|",
                                                   lr_parametro.corligano sleep 2
        let lr_dados.erro = 1
     end if
  else

     # --BUSCA O NOME DO CORRETOR
     open ccte02m01005 using lr_dados.corsus

     whenever error continue
     fetch ccte02m01005 into lr_dados.cornom
     whenever error stop

     if sqlca.sqlcode <> 0 then
        if sqlca.sqlcode = notfound then
           let lr_dados.cornom = null
        else
           error "Erro SELECT ccte02m01005 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
           error "cte02m01_exibe_info_contato() | ,", lr_dados.corsus sleep 2
           let lr_dados.erro = 1
        end if
     end if

     let lr_dados.msg             = "Susep....:"
     let lr_dados.susep_ou_funmat = lr_dados.corsus, " ", lr_dados.cornom

  end if

  # --BUSCA O NUMERO DA PA, A EMPRESA E A MATRICULA DO ATENDENTE
  open ccte02m01009 using lr_parametro.corlignum,
                          lr_parametro.corligano

  whenever error continue
  fetch ccte02m01009 into lr_dados.c24paxnum,
                          lr_dados.cademp,
                          lr_dados.cadmat
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_dados.c24paxnum = null
        let lr_dados.cademp    = null
        let lr_dados.cadmat    = null
     else
        error "Erro SELECT ccte02m01009 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
        error "cte02m01_exibe_info_contato() | ,", lr_parametro.corlignum, "|",
                                                   lr_parametro.corligano sleep 2
        let lr_dados.erro = 1
     end if
  end if

  # --BUSCA O NOME DO ATENDENTE
  open ccte02m01006 using lr_dados.cadmat,
                          lr_dados.cademp

  whenever error continue
  fetch ccte02m01006 into lr_dados.nome_atend
  whenever error stop

  if sqlca.sqlcode <> 0 then
     if sqlca.sqlcode = notfound then
        let lr_dados.nome_atend = null
     else
        error "Erro SELECT ccte02m01006 ", sqlca.sqlcode, "|", sqlca.sqlerrd[2] sleep 2
        error "cte02m01_exibe_info_contato() | ,", lr_dados.cadmat, "|",
                                                   lr_dados.cademp sleep 2
        let lr_dados.erro = 1
     end if
  end if

  let lr_dados.atendnome = lr_dados.cadmat using "<<<<<&", " ", lr_dados.nome_atend

  if lr_dados.erro <> 1 then

     open window w_cte02m01a at 7,2 with form "cte02m01a"
        attributes(border, form line 1)

     display by name lr_dados.dddcod,
                     lr_dados.ctttel,
                     lr_dados.faxnum,
                     lr_dados.pndretcttnom,
                     lr_dados.msg,
                     lr_dados.susep_ou_funmat,
                     lr_dados.c24paxnum,
                     lr_dados.atendnome

     input by name lr_dados.espera without defaults

        after field espera
           next field espera

        on key(f17, control-c, interrupt)
           exit input

     end input

     close window w_cte02m01a

     let int_flag = false

  end if

  return lr_dados.erro

end function
