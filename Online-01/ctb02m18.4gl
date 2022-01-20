###############################################################################
# Nome do Modulo: CTB02M18                                           Wagner   #
#                                                                             #
# Informa periodo para obter saldo de locacoes por prorrogacao.      Ago/2001 #
###############################################################################
# Alteracoes:                                                                 # 
#                                                                             # 
# DATA        SOLICITACAO  RESPONSAVEL  DESCRIÇÃO                             # 
#-----------------------------------------------------------------------------# 
###############################################################################

 database porto

 globals  "/homedsa/projetos/geral/globals/glct.4gl"

#--------------------------------------------------------------
 function ctb02m18(d_ctb02m18)                 
#--------------------------------------------------------------
 
 define d_ctb02m18     record
    socopgnum          like dbsmopg.socopgnum,
    atdsrvnum          like datmservico.atdsrvnum,
    atdsrvano          like datmservico.atdsrvano,
    rsrincdat          like dbsmopgitm.rsrincdat, 
    rsrfnldat          like dbsmopgitm.rsrfnldat 
 end record 

 define ws             record
    rsrincdat          like dbsmopgitm.rsrincdat, 
    rsrfnldat          like dbsmopgitm.rsrfnldat,
    totqtd             integer, 
    confirma           char(1) 
 end record 
 
 let int_flag =  false
 initialize ws.* to null

 let ws.rsrincdat = d_ctb02m18.rsrincdat
 let ws.rsrfnldat = d_ctb02m18.rsrfnldat

 open window ctb02m18 at 12,19 with form "ctb02m18"
    attribute (form line 1, border, comment line last - 1)

 message " (F17)Abandona"

 while true

    input by name d_ctb02m18.rsrincdat,
                  d_ctb02m18.rsrfnldat  without defaults

       before field rsrincdat
          display by name d_ctb02m18.rsrincdat attribute (reverse)

       after  field rsrincdat
          display by name d_ctb02m18.rsrincdat

          if d_ctb02m18.rsrincdat is null  then
             error " Informe a data inicial do periodo!"
             next field rsrincdat
          end if 

          if d_ctb02m18.rsrincdat > today  then
             error " Data inicial nao pode ser maior que hoje!"
             next field rsrincdat
          end if 

          if d_ctb02m18.rsrincdat < today - 120 units day  then
             error " Data inicial nao pode ser anterior a 120 dias!"
             next field rsrincdat
          end if 

       before field rsrfnldat
          display by name d_ctb02m18.rsrfnldat attribute (reverse)
   
       after  field rsrfnldat
          display by name d_ctb02m18.rsrfnldat
   
          if fgl_lastkey() = fgl_keyval("up")    or 
             fgl_lastkey() = fgl_keyval("left")  then
             next field rsrincdat
          end if 
          if d_ctb02m18.rsrfnldat is null  then
             error " Informe a data final periodo!"                  
             next field rsrfnldat
          end if 
          if d_ctb02m18.rsrfnldat > today  then
             error " Data final nao pode ser maior que hoje!"
             next field rsrfnldat
          end if 
          if d_ctb02m18.rsrfnldat < today - 120 units day  then
             error " Data de ocorrencia nao pode ser anterior a 120 dias!"
             next field rsrfnldat
          end if 
          if d_ctb02m18.rsrfnldat < d_ctb02m18.rsrincdat then
             error " Data final nao pode ser menor que data inicial!"
             next field rsrfnldat
          end if 
    
       on key (interrupt)
          initialize d_ctb02m18.rsrincdat, d_ctb02m18.rsrfnldat to null
          exit input

    end input

    if d_ctb02m18.rsrincdat is null and 
       d_ctb02m18.rsrfnldat is null then
       exit while 
    else
       let ws.totqtd = 0
       select sum(aviprodiaqtd)
         into ws.totqtd
         from datmprorrog
        where atdsrvnum = d_ctb02m18.atdsrvnum
          and atdsrvano = d_ctb02m18.atdsrvano
          and aviprostt = "A"
          and vclretdat between d_ctb02m18.rsrincdat 
                            and d_ctb02m18.rsrfnldat
       
       if ws.totqtd is not null and
          ws.totqtd <> 0        then
          exit while
       else
          call cts08g01("A","N","NAO HA PRORROGACOES/RESERVAS PARA ","",
                                "ESTE SERVICO NO PERIODO INFORMADO !", "")
              returning ws.confirma

          let d_ctb02m18.rsrincdat = ws.rsrincdat 
          let d_ctb02m18.rsrfnldat = ws.rsrfnldat 
          
       end if 
    end if  

 end while

close window ctb02m18
let int_flag = false
return d_ctb02m18.rsrincdat, d_ctb02m18.rsrfnldat 

end function  #  ctb02m18
