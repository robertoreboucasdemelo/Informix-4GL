#############################################################################
# Nome do Modulo: CTS37G00                                         Priscila #
#                                                                  Mai/2006 #
# Funcoes para servico de apoio  (laudos de remocao e socorro               #
#...........................................................................#
#                                                                           #
#                        * * * Alteracoes * * *                             #
#                                                                           #
# Data        Autor Fabrica  Origem    Alteracao                            #
# ----------  -------------- --------- ------------------------------------ #
#############################################################################

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_cts37g00_prepara  smallint

#--------------------------------------------------------------------#
function cts37g00_prepare()
#--------------------------------------------------------------------#
 define l_sql   char(700)

 let l_sql = "select atdsrvnum, atdsrvano from datratdmltsrv "
            ," where atdmltsrvnum = ? and atdmltsrvano = ?   "
 prepare p_cts37g00_001 from l_sql
 declare c_cts37g00_001 cursor for p_cts37g00_001

 let l_sql = "select atdmltsrvnum, atdmltsrvano from datratdmltsrv "
            ," where atdsrvnum = ? and atdsrvano = ?               "
 prepare p_cts37g00_002 from l_sql
 declare c_cts37g00_002 cursor for p_cts37g00_002

 let l_sql = "select a.asitipcod, b.asitipdes   "
            ," from datmservico a, datkasitip b "
            ," where a.atdsrvnum = ?            "
            ,"   and a.atdsrvano = ?            "
            ,"   and a.asitipcod = b.asitipcod  "
 prepare p_cts37g00_003 from l_sql
 declare c_cts37g00_003 cursor for p_cts37g00_003

 let  m_cts37g00_prepara =  true
end function

#--------------------------------------------------------------------#
function cts37g00_existeServicoApoio(param)
#--------------------------------------------------------------------#
  #funcao verifica se servico recebido como parametro é
  #1 - servico normal (não tem apoio e nem é de apoio)
  #2 - servico original (tem outros servicos de apoio)
  #3 - servico de apoio (gerado atraves de um local/condicao do servico original)

  define param         record
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano
  end record

  define l_ret    smallint

  define l_atdsrvnum  like datmservico.atdsrvnum,
         l_atdsrvano  like datmservico.atdsrvano

  if m_cts37g00_prepara is null or
     m_cts37g00_prepara <> true then
     call cts37g00_prepare()
  end if

  let l_ret = 0

  open c_cts37g00_002 using param.atdsrvnum,
                          param.atdsrvano
  foreach c_cts37g00_002 into l_atdsrvnum,
                            l_atdsrvano
         #se encontrou servico e pq servico recebido tem servicos de apoio
         let l_ret = 2
         exit foreach
  end foreach
  if l_ret = 0 then
     whenever error continue
     open c_cts37g00_001 using param.atdsrvnum,
                             param.atdsrvano
     whenever error stop
     fetch c_cts37g00_001 into l_atdsrvnum,
                             l_atdsrvano
     if sqlca.sqlcode = 0 then
        #servico e um servico de apoio
        let l_ret = 3
     else
        let l_ret = 1
     end if
  end if
  return l_ret
end function

#--------------------------------------------------------------------#
function cts37g00_buscaServicoOriginal(param)
#--------------------------------------------------------------------#
  define param         record
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano
  end record

  define l_atdsrvnum like datmservico.atdsrvnum,
         l_atdsrvano like datmservico.atdsrvano,
         l_ret       smallint

  let l_ret = 0

  if m_cts37g00_prepara is null or
     m_cts37g00_prepara <> true then
     call cts37g00_prepare()
  end if

  whenever error continue
  open c_cts37g00_001 using param.atdsrvnum,
                          param.atdsrvano
  whenever error stop
  fetch c_cts37g00_001 into l_atdsrvnum,
                          l_atdsrvano
  if sqlca.sqlcode <> 0 then
     let l_ret = 1
  end if

  return l_ret,
         l_atdsrvnum,
         l_atdsrvano

end function

#--------------------------------------------------------------------#
function cts37g00_buscaServicoApoio(param)
#--------------------------------------------------------------------#
#1 - retorna lista de servicos de apoio
#2 - retorna 1 servico de apoio selecionado em uma lista
  define param         record
        tiporet       smallint,
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano
  end record

  #variavel array com tamenho 3 porque hoje so e possivel 3 servicos de apoio por laudo
  # SUBSOLO -- VEICULO TRANCADO -- QUEBRA/PERDA CHAVE CODIFICADA
  define cts37g00_servApoio array[3] of record
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano
  end record

  define l_aux    smallint

  initialize cts37g00_servApoio to null

  let l_aux = 1

  if m_cts37g00_prepara is null or
     m_cts37g00_prepara <> true then
     call cts37g00_prepare()
  end if

  open c_cts37g00_002 using param.atdsrvnum,
                          param.atdsrvano
  foreach c_cts37g00_002 into cts37g00_servApoio[l_aux].atdsrvnum,
                            cts37g00_servApoio[l_aux].atdsrvano
         #se encontrou servico e pq servico recebido tem servicos de apoio
         let l_aux = l_aux + 1
  end foreach

  let l_aux = l_aux - 1  #atualiza quantidade correta de servicos de apoio

  if param.tiporet = 1 then #solicitou lista de servicos de apoio
     return cts37g00_servApoio[1].*,
            cts37g00_servApoio[2].*,
            cts37g00_servApoio[3].*
  else
     if l_aux = 1 then    #encontrou apenas 1 servico de apoio
        return cts37g00_servApoio[l_aux].*
     end if
  end if

  #solicitou apenas 1 servico de apoio e foram encontrados mais de 1 servico de apoio
  #abrir janela com lista de servicos
  call cts37g00_listaServicosApoio(param.atdsrvnum, param.atdsrvano)
     returning cts37g00_servApoio[1].atdsrvnum,
               cts37g00_servApoio[1].atdsrvano

  return cts37g00_servApoio[1].*

end function


#--------------------------------------------------------------------#
function cts37g00_listaServicosApoio(param)
#--------------------------------------------------------------------#
  define param  record
        atdsrvnum     like datmservico.atdsrvnum,
        atdsrvano     like datmservico.atdsrvano
  end record

  define am_tela array[5] of record
        asitipcod     like datkasitip.asitipcod,
        asitipdes     like datkasitip.asitipdes,
        numanoserv    char(13)
  end record

  define l_atdsrvnum     like datmservico.atdsrvnum,
         l_atdsrvano     like datmservico.atdsrvano

  define l_aux    smallint,
         l_arr    smallint

  if m_cts37g00_prepara is null or
     m_cts37g00_prepara <> true then
     call cts37g00_prepare()
  end if

  let l_aux = 0
  let l_arr = null

  open c_cts37g00_002 using param.atdsrvnum,
                          param.atdsrvano
  foreach c_cts37g00_002 into l_atdsrvnum,
                            l_atdsrvano
         let l_aux = l_aux + 1
         #monta variavel com numero e ano servico apoio
         let am_tela[l_aux].numanoserv = l_atdsrvnum using "#########&", "/",
                                         l_atdsrvano using "&&"

         #busca tipo assistencia servico de apoio
         whenever error continue
         open c_cts37g00_003 using l_atdsrvnum,
                                 l_atdsrvano
         whenever error stop
         fetch c_cts37g00_003 into am_tela[l_aux].asitipcod,
                                 am_tela[l_aux].asitipdes
         if sqlca.sqlcode <> 0 then
            exit foreach
         end if
  end foreach

  open window w_cts37g00 at 11,23 with form "cts37g00"
       attribute(form line 1, border)

  call set_count(l_aux)

  display array am_tela to s_tela.*
       on key(F8)
          let l_arr = arr_curr()
          exit display

       on key(interrupt, f17, control-c)
          let l_arr = 1
          initialize am_tela to null
          exit display

  end display

  close window w_cts37g00

  let l_atdsrvnum = am_tela[l_arr].numanoserv[1, 10]
  let l_atdsrvano = am_tela[l_arr].numanoserv[12,13]

  return l_atdsrvnum,
         l_atdsrvano

end function
