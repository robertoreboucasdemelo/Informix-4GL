#############################################################################
# Nome do Modulo: CTS00M04                                         Pedro    #
#                                                                  Marcelo  #
# Mostra todas as funcoes do RADIO                                 Abr/1995 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 14/10/1998  PSI 6895-0   Gilberto     Incluir funcao RETORNOS MARCADOS.   #
#---------------------------------------------------------------------------#
# 03/03/1999  PSI 7913-8   Wagner       Incluir funcao VIDROS.              #
#---------------------------------------------------------------------------#
# 23/10/2000  PSI 118168   Marcus       Incluir funcao INCONSISTENCIAS      #
#---------------------------------------------------------------------------#
# 24/01/2001  PSI 120187   Wagner       Incluir funcao ENVIO MSG TELETRIM   #
#---------------------------------------------------------------------------#
# 23/08/2001  PSI 136220   Ruiz         Incluir funcao INTERNET.            #
#---------------------------------------------------------------------------#
# 17/10/2002  PSI 162884   Paula        Incluir atend. ct24h RADIO RE       #
#---------------------------------------------------------------------------# 
# 29/01/2003  PSI 159204   Wagner       Incluir acesso cadastros P.Socorro  #
#---------------------------------------------------------------------------#
# 18/11/2003  Meta, Jefferson 179345    Incluir um item de menu quando      #
#                              28851    nivel >= 8                          #
#...........................................................................#
#                                                                           #
#                          * * * Alteracoes * * *                           #
#                                                                           #
# Data       Autor Fabrica     Origem     Alteracao                         #
# ---------- ----------------- ---------- ----------------------------------#
# 27/01/2005 Daniel, Meta      PSI190489  Receber origem como parametro     #
#                                         Implementar no array              #
#---------------------------------------------------------------------------#
# 25/06/2010 Danilo Sgrott     PSI257664  Cria��o de nova fun��o no menu    #
#            F0111099                     "REG ATENDIMENTO"                 #
#---------------------------------------------------------------------------#
# 07/02/2013 Sergio Burini   PSI-2013-00435/EV Listar servi�os pr�ximos a   #
#                                              endere�o                     #
#---------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

#-----------------------------------------------------------
function cts00m04(l_origem)
#-----------------------------------------------------------

 define l_origem  smallint

 define a_cts00m04  array[30] of record
    fundes          char (20),
    funcod          char (03)
 end record

 define scr_aux     smallint
 define arr_aux     smallint

 let	scr_aux  =  null
 let	arr_aux  =  null

 initialize a_cts00m04 to null
 open window cts00m04 at 09,54 with form "cts00m04"
             attribute(form line 1, border)

 let int_flag = false
 initialize a_cts00m04   to null


  if g_issk.acsnivcod <= 6 then
     let arr_aux = 22
  else
     if g_issk.acsnivcod < 9 then
        let arr_aux = 29
     else
        let arr_aux = 30
     end if
  end if


 
 if l_origem = 0 then
    let a_cts00m04[arr_aux].fundes = "TIPO ASSISTENCIA"
    let a_cts00m04[arr_aux].funcod = "tpa"
 else
    if l_origem = 9 then
       let a_cts00m04[arr_aux].fundes = "GRUPO NATUREZA"
       let a_cts00m04[arr_aux].funcod = "grp"
    end if
 end if

 let a_cts00m04[01].fundes = "POSICAO FROTAS"
 let a_cts00m04[01].funcod = "frt"
 let a_cts00m04[02].fundes = "LOCALIZA SERVICO"
 let a_cts00m04[02].funcod = "loc"
 let a_cts00m04[03].fundes = "REG ATENDIMENTO"
 let a_cts00m04[03].funcod = "reg"
 let a_cts00m04[04].fundes = "INCONSIST. FROTAS"
 let a_cts00m04[04].funcod = "inc"
 let a_cts00m04[05].fundes = "INTERNET"
 let a_cts00m04[05].funcod = "int"
 let a_cts00m04[06].fundes = "ACOMPANHAMENTO"
 let a_cts00m04[06].funcod = "acp"
 let a_cts00m04[07].fundes = "CANCELADOS"
 let a_cts00m04[07].funcod = "can"
 let a_cts00m04[08].fundes = "CANCELADOS JIT"
 let a_cts00m04[08].funcod = "caj"
 let a_cts00m04[09].fundes = "CANCELADOS RE"
 let a_cts00m04[09].funcod = "car"
 let a_cts00m04[10].fundes = "SEM PREVISAO"
 let a_cts00m04[10].funcod = "spr"
 let a_cts00m04[11].fundes = "RETORNOS MARCADOS"
 let a_cts00m04[11].funcod = "ret"
 let a_cts00m04[12].fundes = "RESERVAS"
 let a_cts00m04[12].funcod = "rsv"
 let a_cts00m04[13].fundes = "ACIONANDO"
 let a_cts00m04[13].funcod = "eam"
 let a_cts00m04[14].fundes = "VISTORIAS"
 let a_cts00m04[14].funcod = "vst"
 let a_cts00m04[15].fundes = "PROGRAMADOS"
 let a_cts00m04[15].funcod = "prg"
 let a_cts00m04[16].fundes = "NAO LIBERADOS"
 let a_cts00m04[16].funcod = "nli"
 let a_cts00m04[17].fundes = "VIDROS"
 let a_cts00m04[17].funcod = "vds"
 let a_cts00m04[18].fundes = "MENSAGENS MDTs"
 let a_cts00m04[18].funcod = "mdt"
 let a_cts00m04[19].fundes = "ENVIO MENS TELETRIM"
 let a_cts00m04[19].funcod = "emt"
 let a_cts00m04[20].fundes = "PREST. NAO LOGADOS"
 let a_cts00m04[20].funcod = "pnl"
 let a_cts00m04[21].fundes = "LISTAR SERVICO"
 let a_cts00m04[21].funcod = "lst"


#if g_issk.acsnivcod  >=  8   then   ## Nivel SUPERVISOR
  if g_issk.acsnivcod >= 7 then
     let a_cts00m04[22].fundes = "EXIBICAO DE V.P."
     let a_cts00m04[22].funcod = "exb"
     let a_cts00m04[23].fundes = "EXIBICAO DE JIT"
     let a_cts00m04[23].funcod = "exj"
     let a_cts00m04[24].fundes = "EXIBICAO DE RE"
     let a_cts00m04[24].funcod = "exr"
     let a_cts00m04[25].fundes = "EXIBICAO DE CARTAO"     # PSI 235970 - Tela Cartao Porto Seguro
     let a_cts00m04[25].funcod = "exc"                    #
     let a_cts00m04[26].fundes = "EXIBICAO SRV ATENCAO "  # PSI 241733
     let a_cts00m04[26].funcod = "eat"
     let a_cts00m04[27].fundes = "ACIONAMENTO DEMANDA"
     let a_cts00m04[27].funcod = "acd"
     let a_cts00m04[28].fundes = "CARGA CONTINGENCIA"
     let a_cts00m04[28].funcod = "ctg"
     let arr_aux = 29
  else
      let arr_aux = 22
  end if
  
  if g_issk.acsnivcod = 9 then
     let a_cts00m04[29].fundes = "CADASTROS P.SOCORRO"
     let a_cts00m04[29].funcod = "cps"     
     let arr_aux = 30
  end if


 message "(F8)Seleciona"
 call set_count(arr_aux)

 display array a_cts00m04 to s_cts00m04.*

    on key (interrupt,control-c)
       initialize a_cts00m04   to null
       exit display

    on key (F8)
       let arr_aux = arr_curr()
       let scr_aux = scr_line()
       exit display

 end display

 close window  cts00m04
 let int_flag = false

 return a_cts00m04[arr_aux].funcod
end function  ###  cts00m04
