#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : CTC59M02.4gl                                        #
# Analista Resp.: Raji                                                #
# OSF/PSI       :                                                     #
#                                                                     #
# Desenvolvedor  :                                                    #
# DATA           : Jul/2002                                           #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 29/08/2006  Priscila       PSI202363 Atualizar cotas disponiveis e  #
#                                      utilizadas, caso nao tenha mais#
#                                      cota, mas permitiu locar cota  #
#                                      por ter veiculo em QRV         #
#---------------------------------------------------------------------#
# 10/11/2006  Priscila       AS         Chamar funcao para acessar    #
#                                       tabela datrcidsed             #
#---------------------------------------------------------------------#
# 13/11/2011  Robert Lima  PSI201105440 Alterado o calculo da hora    #
#                                       para hora quebrada em 1/2 hora#
#---------------------------------------------------------------------#

globals  "/homedsa/projetos/geral/globals/glct.4gl"
 
#--------------------------------------------------------------
 function ctc59m02(p_ctc59m02)
#--------------------------------------------------------------
 define p_ctc59m02   record
    cidnom           like glakcid.cidnom,
    ufdcod           like glakcid.ufdcod,
    atdsrvorg        like datmsrvrgl.atdsrvorg,
    srvrglcod        like datmsrvrgl.srvrglcod,
    rgldat           like datmsrvrgl.rgldat,
    rglhor           char(5),
    flgdisponivel    smallint                    #PSI202363
 end record

 define ws record
    cotqtd           like datmsrvrgl.cotqtd,
    utlqtd           like datmsrvrgl.utlqtd,
    cont             smallint,
    srvrglcod        like datmsrvrgl.srvrglcod,
    rglflg           smallint,
    cidcod           like glakcid.cidcod,
    cidsedcod        like glakcid.cidcod,
    horstr           char(5),
    hora             like datmsrvrgl.rglhor,
    socntrzgrpcod    like datksocntzgrp.socntzgrpcod
 end record

 define l_ret smallint       #AS 10/11
 define l_mensagem char(50)  #AS 10/11

	initialize  ws.*  to  null

 initialize ws.* to null

 let ws.rglflg = 0

 # Calcula hora cheia
 #let ws.horstr = p_ctc59m02.rglhor[1,2], ":00"
 #let ws.hora   = ws.horstr
 
 #Calcula hora quebrada
 let  ws.horstr   = p_ctc59m02.rglhor[4,5]
 
 if ws.horstr >= 30 and ws.horstr > 0 then
    let ws.horstr = p_ctc59m02.rglhor[1,2], ":30"    
 else
    let ws.horstr = p_ctc59m02.rglhor[1,2]
    let ws.horstr = ws.horstr[1,2],":00"
 end if
 
 let ws.hora   = ws.horstr

 #Priscila - AS - 10/11/06
 # Verifica se a cidade esta cadastrada
 #declare c_glakcid cursor for
 #   select cidcod
 #     from glakcid
 #    where cidnom = p_ctc59m02.cidnom
 #      and ufdcod = p_ctc59m02.ufdcod
 #
 # open  c_glakcid
 # fetch c_glakcid  into  ws.cidcod
 call cty10g00_obter_cidcod(p_ctc59m02.cidnom, p_ctc59m02.ufdcod)
      returning l_ret, l_mensagem, ws.cidcod

 # Verifica se a cidade e atendida por uma cidade sede
 #declare c_datrcidsed cursor for
 #   select cidsedcod
 #     from datrcidsed
 #    where cidcod = ws.cidcod
 #
 #open c_datrcidsed
 #fetch c_datrcidsed into ws.cidsedcod
 call ctd01g00_obter_cidsedcod(1, ws.cidcod)
      returning l_ret, l_mensagem, ws.cidsedcod

 #if sqlca.sqlcode <> 0 then
 if l_ret <> 1 then
    let ws.cidsedcod = ws.cidcod
 end if

 # Se RE Busca grupo de natureza
 let ws.srvrglcod = p_ctc59m02.srvrglcod
 if p_ctc59m02.atdsrvorg = 9 then
    select socntzgrpcod
           into ws.srvrglcod
      from datksocntz
     where socntzcod = p_ctc59m02.srvrglcod
    if sqlca.sqlcode <> 0 then
       let ws.srvrglcod = p_ctc59m02.srvrglcod
    end if
 end if

 whenever error continue
 set lock mode to not wait

 let ws.cont = 1
 while true
    let ws.cont = ws.cont + 1

    let ws.cotqtd = 0
    let ws.utlqtd = 0

    # Busca registro do regulador
    select cotqtd, utlqtd
           into ws.cotqtd, ws.utlqtd
      from datmsrvrgl
     where cidcod = ws.cidsedcod
       and rgldat = p_ctc59m02.rgldat
       and rglhor = ws.hora
       and atdsrvorg = p_ctc59m02.atdsrvorg
       and srvrglcod = ws.srvrglcod

    if sqlca.sqlcode = 0 then
       if ws.cotqtd > ws.utlqtd then
          let ws.cont = 1
          while true
             let ws.cont   = ws.cont   + 1
             let ws.utlqtd = ws.utlqtd + 1
             
             update datmsrvrgl             
                set utlqtd = ws.utlqtd
              where cidcod = ws.cidsedcod
                and rgldat = p_ctc59m02.rgldat
                and rglhor = ws.hora
                and atdsrvorg = p_ctc59m02.atdsrvorg
                and srvrglcod = ws.srvrglcod

             if  sqlca.sqlcode = -243 or
                 sqlca.sqlcode = -245 or
                 sqlca.sqlcode = -246 then
                 if  ws.cont < 11  then
                     sleep 1
                     continue while
                 else
                     error " Selecao do Regulador do servico travado!"
                 end if
             end if
             exit while
          end while
       else          
          if p_ctc59m02.flgdisponivel = true then
             while true
                let ws.cont   = ws.cont   + 1
                let ws.utlqtd = ws.utlqtd + 1
                let ws.cotqtd = ws.cotqtd + 1
                 
                update datmsrvrgl
                   set utlqtd = ws.utlqtd,
                       cotqtd = ws.cotqtd
                 where cidcod = ws.cidsedcod
                   and rgldat = p_ctc59m02.rgldat
                   and rglhor = ws.hora
                   and atdsrvorg = p_ctc59m02.atdsrvorg
                   and srvrglcod = ws.srvrglcod
             
                if  sqlca.sqlcode = -243 or
                    sqlca.sqlcode = -245 or
                    sqlca.sqlcode = -246 then
                    if  ws.cont < 11  then
                        continue while
                    else                        
                        error " Selecao do Regulador do servico travado!"
                    end if
                end if
                exit while
             end while
          else
             let ws.rglflg = 1 # Bloqueio por limite de utilizacao
          end if   #PSI202363   
       end if
    else
       if  sqlca.sqlcode = -243 or
           sqlca.sqlcode = -245 or
           sqlca.sqlcode = -246 then
           if  ws.cont < 11  then
               sleep 1
               continue while
           else
               Error " Selecao do Regulador do servico travado!"
           end if
       #else
       #  if  p_ctc59m02.atdsrvorg = 9 then
       #      error 'Horario nao disponivel '
       #      let ws.rglflg = 1 # Bloqueio por limite de utilizacao #####
       #  end if #Conforme contato c/Guilherme em 24/05
       end if
    end if
    exit while
 end while

 set lock mode to wait
 whenever error stop

 return ws.rglflg

end function  #  ctc59m02
