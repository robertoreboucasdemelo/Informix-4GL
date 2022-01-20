#############################################################################
# Nome do Modulo: bdbsr126                                         Raji     #
# Gera relatorio de monitoramento de passagem de veiculos PS em via crítica #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL     DESCRICAO                        #
#---------------------------------------------------------------------------#
# 16-07-2012  CT2012-19719 Celso Yamahaki  Set Isolation to dirty Read      #
#---------------------------------------------------------------------------#
# 05-06-2015  RCP,Fornax   RELTXT          Criar versao .txt dos relatorios #
#############################################################################
database porto

define  ws_tab   char(1),
        ws_i     smallint

main

define ws record
   data       date,
   metros     smallint,
   lclltt     like datmmdtmvt.lclltt,
   lcllgt     like datmmdtmvt.lcllgt,
   local      char(40),
   difcoo     dec(16,8),
   lttmin     like datmmdtmvt.lclltt,
   lttmax     like datmmdtmvt.lclltt,
   lgtmin     like datmmdtmvt.lcllgt,
   lgtmax     like datmmdtmvt.lcllgt,
   mvtcaddat  like datmmdtmvt.caddat,
   mvtcadhor  like datmmdtmvt.cadhor,
   mvtmdtcod  like datmmdtmvt.mdtcod,
   mvtlclltt  like datmmdtmvt.lclltt,
   mvtlcllgt  like datmmdtmvt.lcllgt,
   atdsrvnum  like datmservico.atdsrvnum,
   atdsrvano  like datmservico.atdsrvano,
   mdtmvtseq  like datmmdtmvt.mdtmvtseq,
   mvtdist    dec(16,8),
   mvtdistmin dec(16,8),
   
   coordcount smallint,
  
   dirfisnom  like ibpkdirlog.dirfisnom,
   dirfis     like ibpkdirlog.dirfisnom,
   dirfis_txt like ibpkdirlog.dirfisnom, #--> RELTXT
   sqlcmd     char(1000)
end record

define a_coordenadas array[10] of record
   lclltt like datmmdtmvt.lclltt,
   lcllgt like datmmdtmvt.lcllgt,
   local  char(40)
end record

let ws_tab = "	"

call fun_dba_abre_banco("CT24HS") 
set isolation to dirty read

let ws.sqlcmd = "select caddat,cadhor,mdtcod,lclltt,lcllgt,atdsrvnum,atdsrvano, mdtmvtseq",
                "  from datmmdtmvt  ",
                " where caddat = ? ",
                "   and lclltt >= ? and lclltt <= ? ",
                "   and lcllgt >= ? and lcllgt <= ? "
prepare p_bdbsr126 from ws.sqlcmd
declare c_bdbsr126 cursor for p_bdbsr126

let ws.sqlcmd = "select atdvclsgl, socvcltip ",
                "  from datkveiculo ",
                " where mdtcod = ? "
prepare p_bdbsr126_1 from ws.sqlcmd
declare c_bdbsr126_1 cursor for p_bdbsr126_1

let ws.sqlcmd = "select cpodes ",
                "  from iddkdominio ",
                " where cponom = 'socvcltip' and cpocod = ? "
prepare p_bdbsr126_2 from ws.sqlcmd
declare c_bdbsr126_2 cursor for p_bdbsr126_2

# Informações fixas para atender demanda emergencial
let ws.metros = 100

let a_coordenadas[1].lclltt = -23.607624
let a_coordenadas[1].lcllgt = -46.465065
let a_coordenadas[1].local  = "Phobus"

let a_coordenadas[2].lclltt = -23.606484
let a_coordenadas[2].lcllgt = -46.463413
let a_coordenadas[2].local  = "Phobus"

let a_coordenadas[3].lclltt = -23.605383
let a_coordenadas[3].lcllgt = -46.461804
let a_coordenadas[3].local  = "Phobus"

let a_coordenadas[4].lclltt = -23.604282
let a_coordenadas[4].lcllgt = -46.460066
let a_coordenadas[4].local  = "Phobus"

let a_coordenadas[5].lclltt = -23.525992
let a_coordenadas[5].lcllgt = -46.690274
let a_coordenadas[5].local  = "Cornelia"

let ws.coordcount = 6

# Transforma distancia em metros para coordenandas (media)
let ws.difcoo = ws.metros / 1000 / 108

# Monta uma janela de coordenadas para filtrar consulta
let ws.lttmin = a_coordenadas[1].lclltt
let ws.lttmax = a_coordenadas[1].lclltt
let ws.lgtmin = a_coordenadas[1].lcllgt
let ws.lgtmax = a_coordenadas[1].lcllgt

for ws_i=1 to ws.coordcount
    let ws.lclltt = a_coordenadas[ws_i].lclltt
    let ws.lcllgt = a_coordenadas[ws_i].lcllgt
    
    if ws.lttmin > (ws.lclltt - ws.difcoo) then
       let ws.lttmin = ws.lclltt - ws.difcoo
    end if
    
    if ws.lttmax < (ws.lclltt + ws.difcoo) then
       let ws.lttmax = ws.lclltt + ws.difcoo
    end if

    if ws.lgtmin > (ws.lcllgt - ws.difcoo) then
       let ws.lgtmin = ws.lcllgt - ws.difcoo
    end if

    if ws.lgtmax < (ws.lcllgt + ws.difcoo) then
       let ws.lgtmax = ws.lcllgt + ws.difcoo
    end if
end for

# Data de processamento
let ws.data   = today - 1 units day

#---------------------------------------------------------------
# Define diretorios para relatorios e arquivos
#---------------------------------------------------------------
call f_path("DBS", "ARQUIVO")
     returning ws.dirfisnom

if ws.dirfisnom is null then
   let ws.dirfisnom = "."
end if

let ws.dirfis = ws.dirfisnom clipped,
                "/RDBS126_", year(ws.data) using "&&&&", "_",
                             month(ws.data) using "&&", "_",
                             day(ws.data) using "&&" , ".xls"
start report bdbsr126_rpt to ws.dirfis

#--> RELTXT (inicio)
let ws.dirfis_txt = ws.dirfisnom clipped,
                "/BDBSR126_", year(ws.data) using "&&&&",
                             month(ws.data) using "&&",
                               day(ws.data) using "&&" , ".txt"
start report bdbsr126_rpt_txt to ws.dirfis_txt
#--> RELTXT (final) 

open c_bdbsr126 using ws.data,
                      ws.lttmin,         
                      ws.lttmax,
                      ws.lgtmin,
                      ws.lgtmax

foreach c_bdbsr126 into ws.mvtcaddat,
                        ws.mvtcadhor,
                        ws.mvtmdtcod,
                        ws.mvtlclltt,
                        ws.mvtlcllgt,
                        ws.atdsrvnum,
                        ws.atdsrvano,
                        ws.mdtmvtseq
                        
   let ws.mvtdistmin = 9999
   let ws.local = ""
   for ws_i=1 to ws.coordcount

      let ws.lclltt = a_coordenadas[ws_i].lclltt
      let ws.lcllgt = a_coordenadas[ws_i].lcllgt
      
      let ws.mvtdist = cts18g00(ws.mvtlclltt,
                                ws.mvtlcllgt,
                                ws.lclltt,
                                ws.lcllgt)
                        
      let ws.mvtdist = ws.mvtdist * 1000

      if ws.mvtdist < ws.mvtdistmin then
         let ws.mvtdistmin = ws.mvtdist
         let ws.local = a_coordenadas[ws_i].local
      end if
   
   end for

   if ws.mvtdistmin >= ws.metros then
      continue foreach
   end if

   output to report bdbsr126_rpt( ws.mvtcaddat,
                                  ws.mvtcadhor,
                                  ws.mvtmdtcod,
                                  ws.mvtlclltt,
                                  ws.mvtlcllgt,
                                  ws.local,
                                  ws.mvtdistmin,
                                  ws.atdsrvnum,
                                  ws.atdsrvano )

   #--> RELTXT (inicio)
   output to report bdbsr126_rpt_txt( ws.mvtcaddat
                                     ,ws.mvtcadhor
                                     ,ws.mvtmdtcod
                                     ,ws.mvtlclltt
                                     ,ws.mvtlcllgt
                                     ,ws.local
                                     ,ws.mvtdistmin
                                     ,ws.atdsrvnum
                                     ,ws.atdsrvano
                                     ,ws.mdtmvtseq)
   #--> RELTXT (final) 

end foreach   

finish report bdbsr126_rpt
finish report bdbsr126_rpt_txt #--> RELTXT

call bdbsr126_mail(ws.dirfis)

end main   

#----------------------------------------------------------------------------#
report bdbsr126_rpt(out)
#----------------------------------------------------------------------------#
 define out record
   data      date,
   mvtcadhor like datmmdtmvt.cadhor,
   mvtmdtcod like datmmdtmvt.mdtcod,
   mvtlclltt like datmmdtmvt.lclltt,
   mvtlcllgt like datmmdtmvt.lcllgt,
   local     char(40),
   mvtdist   dec(16,8),
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano
 end record

 define rpt record
   atdvclsgl like datkveiculo.atdvclsgl,
   mvtcadhor like datmmdtmvt.cadhor,
   mvtmdtcod like datmmdtmvt.mdtcod,
   mvtlclltt like datmmdtmvt.lclltt,
   mvtlcllgt like datmmdtmvt.lcllgt,
   mvtdist   dec(16,8),
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   socvcltip like datkveiculo.socvcltip,
   socvcldes char(20)
 end record

  output
      left   margin  000
      top    margin  000
      bottom margin  000

  order by out.data,out.mvtcadhor

  format
      first page header
           print "PONTO",     ws_tab,
                 "MID",       ws_tab,
                 "SIGLA",     ws_tab,
                 "TIPO VEICULO",     ws_tab,
                 "DATA",      ws_tab,
                 "HORA",      ws_tab,
                 "DISTANCIA (METROS)", ws_tab,
                 "COORDENADA",  ws_tab,
                 "SERVICO",   ws_tab            

      on every row
           initialize rpt.* to null
           
           open c_bdbsr126_1 using out.mvtmdtcod
           fetch c_bdbsr126_1 into rpt.atdvclsgl,
                                   rpt.socvcltip
           close c_bdbsr126_1
           
           open c_bdbsr126_2 using rpt.socvcltip
           fetch c_bdbsr126_2 into rpt.socvcldes
           close c_bdbsr126_2
           
           print out.local clipped, ws_tab,
                 out.mvtmdtcod, ws_tab,
                 rpt.atdvclsgl clipped, ws_tab,
                 rpt.socvcltip using "<&", " ", rpt.socvcldes clipped, ws_tab,
                 extend(out.data, year to year ),'-',
                 	extend(out.data, month to month),'-',
                 	extend(out.data, day to day),      ws_tab,
                 out.mvtcadhor, ws_tab,
                 out.mvtdist using "<<<<&",  ws_tab,
                 out.mvtlclltt, " , ", out.mvtlcllgt, ws_tab;
                 
           if out.atdsrvnum is not null then
              print out.atdsrvnum using "&&&&&&&", "-", out.atdsrvano using "&&", ws_tab
           else
              print ws_tab
           end if
   
end report

#----------------------------------------------------------------------------#
report bdbsr126_rpt_txt(out) #--> RELTXT 
#----------------------------------------------------------------------------#
 define out record
   data      date,
   mvtcadhor like datmmdtmvt.cadhor,
   mvtmdtcod like datmmdtmvt.mdtcod,
   mvtlclltt like datmmdtmvt.lclltt,
   mvtlcllgt like datmmdtmvt.lcllgt,
   local     char(40),
   mvtdist   dec(16,8),
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   mdtmvtseq like datmmdtmvt.mdtmvtseq
 end record

 define rpt record
   atdvclsgl like datkveiculo.atdvclsgl,
   mvtcadhor like datmmdtmvt.cadhor,
   mvtmdtcod like datmmdtmvt.mdtcod,
   mvtlclltt like datmmdtmvt.lclltt,
   mvtlcllgt like datmmdtmvt.lcllgt,
   mvtdist   dec(16,8),
   atdsrvnum like datmservico.atdsrvnum,
   atdsrvano like datmservico.atdsrvano,
   socvcltip like datkveiculo.socvcltip,
   socvcldes char(20)
 end record

  output
      left   margin  000
      top    margin  000
      bottom margin  000
      page   length  001

  order by out.data,out.mvtcadhor

  format
      on every row
           initialize rpt.* to null
           
           open c_bdbsr126_1 using out.mvtmdtcod
           fetch c_bdbsr126_1 into rpt.atdvclsgl,
                                   rpt.socvcltip
           close c_bdbsr126_1
           
           open c_bdbsr126_2 using rpt.socvcltip
           fetch c_bdbsr126_2 into rpt.socvcldes
           close c_bdbsr126_2
           
           print out.local clipped,                                    ASCII(09),
                 out.mvtmdtcod,                                        ASCII(09),
                 rpt.atdvclsgl clipped,                                ASCII(09),
                 rpt.socvcltip using "<&", " ", rpt.socvcldes clipped, ASCII(09),
                 extend(out.data, year to year ),'-',
                 	extend(out.data, month to month),'-',
                 	extend(out.data, day to day),                        ASCII(09),
                 out.mvtcadhor,                                        ASCII(09),
                 out.mvtdist using "<<<<&",                            ASCII(09),
                 out.mvtlclltt, " , ", out.mvtlcllgt,                  ASCII(09);
                 
           if out.atdsrvnum is not null then
              print out.atdsrvnum using "&&&&&&&", "-", 
                    out.atdsrvano using "&&",                          ASCII(09);
           else
              print ASCII(09);
           end if
           
           print out.mdtmvtseq, ASCII(09);
           
           print today
   
end report

#-----------------------------------------------------------
function bdbsr126_mail(p_bdbsr126_mail)
#-----------------------------------------------------------
 define p_bdbsr126_mail record
        arquivo         char(80)
 end record

 define comando        char(600)
 define l_retorno      smallint

 let comando = "Monitoramento_passagem_veiculos_via_critica"
 
 let l_retorno = ctx22g00_envia_email("BDBSR126",
                                      comando,
                                      p_bdbsr126_mail.arquivo)
 if l_retorno <> 0 then
    if l_retorno <> 99 then
       display "Erro de envio de email(cx22g00)- ",p_bdbsr126_mail.arquivo
    else
       display "Nao ha email cadastrado para o modulo BDBSR126 "
    end if
 end if

end function  ### bdbsr126_mail
