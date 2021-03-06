#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: TELEATENDIMENTO - CENTRAL 24 HORAS                         #
# MODULO.........: CTD02G00                                                   #
# ANALISTA RESP..: CARLOS ANTONIO RUIZ                                        #
# PSI/OSF........: 205.206 - AZUL SEGUROS                                     #
#                  RETORNA O CODIGO(DOC HANDLE) DO XML DAS APOLICES DA AZUL.  #
# ........................................................................... #
# DESENVOLVIMENTO: LUCAS SCHEID                                               #
# LIBERACAO......: 17/11/2006                                                 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# --------   --------------  ---------- ------------------------------------- #
# 21/11/11   Marcos Goes                Funcao original ctd02g00_agrupaXML    #
#                                       renomeada para ctd02g00_agrupaXML2.   #
#                                       A nova funcao corrige o problema de   #
#                                       propostas recusadas no Informix       #
#                                       buscando o endosso anterior.          #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


database porto

  define m_ctd02g00_prep smallint

#-------------------------#
function ctd02g00_prepare()
#-------------------------#

  define l_sql char(2000)

  let l_sql = null

  let l_sql = " select azlapldsc ",
                " from datkazlaplcmp ",
               " where azlaplcod = ? "

  prepare pctd02g00001 from l_sql
  declare cctd02g00001 cursor for pctd02g00001


  let l_sql = "SELECT FIRST 1 B.azlaplcod       "
              ,"FROM datkazlapl A, datkazlapl B  "
              ,"WHERE B.succod = A.succod        "
              ,"AND   B.ramcod = A.ramcod        "
              ,"AND   B.aplnumdig = A.aplnumdig  "
              ,"AND   B.itmnumdig = A.itmnumdig  "
              ,"AND   B.edsnumdig < A.edsnumdig  "
              ,"AND   A.azlaplcod = ?            "
              ,"ORDER BY B.edsnumdig DESC        "
   prepare p_ctd02g00_002 from l_sql
   declare c_ctd02g00_002 cursor for p_ctd02g00_002


  let m_ctd02g00_prep = true

end function

#--------------------------------------#
function ctd02g00_agrupaXML2(l_azlaplcod)
#--------------------------------------#

  define l_azlaplcod  like datkazlaplcmp.azlaplcod,
         l_azlapldsc  like datkazlaplcmp.azlapldsc,
         l_doc_handle integer,
         l_xml        char(6000)

  if m_ctd02g00_prep is null or
     m_ctd02g00_prep <> true then
     call ctd02g00_prepare()
  end if

  # -> INICIALIZACAO DAS VARIAVEIS
  let l_azlapldsc  = null
  let l_xml        = null
  let l_doc_handle = null

  if l_azlaplcod is not null then
     open cctd02g00001 using l_azlaplcod
     foreach cctd02g00001 into l_azlapldsc

       # -> MONTA O XML DE RETORNO
       let l_xml = l_xml clipped, l_azlapldsc

     end foreach
     close cctd02g00001
  end if

  if l_xml is not null and
     l_xml <> " " then
     # -> APOS OBTER O XML, BUSCA O DOC HANDLE(CODIGO) DO XML
     call figrc011_fim_parse()
     call figrc011_inicio_parse()
     let l_doc_handle = figrc011_parse(l_xml)
  end if

  return l_doc_handle

end function



#------------------------------------------------#
 function ctd02g00_agrupaXML(l_azlaplcod)
#------------------------------------------------#
   define l_azlaplcod     like datkazlaplcmp.azlaplcod
   define l_azlaplcod_aux like datkazlaplcmp.azlaplcod
   define l_doc_handle  integer
   define l_situacao    char(10)

   if m_ctd02g00_prep is null or
     m_ctd02g00_prep <> true then
     call ctd02g00_prepare()
  end if

   let g_indexado.azlaplcod = l_azlaplcod 
   
   let l_doc_handle = ctd02g00_agrupaXML2(l_azlaplcod)

   let l_situacao = figrc011_xpath(l_doc_handle,"/APOLICE/SITUACAO")
   let l_situacao = l_situacao clipped

   #display "----- TESTE MARCOS -----"
   #display "SITUACAO: ", l_situacao
   #display "------------------------"

   if l_situacao = "RECUSADA" then
      # Entra a primeira vez no loop apenas se for RECUSADA.
      # Sai do loop ate que seja diferente de RECUSADA e PROPOSTA.

      while l_situacao = "RECUSADA"
         or l_situacao = "PROPOSTA"

         let l_azlaplcod_aux = null

         open c_ctd02g00_002 using l_azlaplcod
         whenever error continue
         fetch c_ctd02g00_002 into l_azlaplcod_aux
         whenever error stop
         close c_ctd02g00_002

         let  l_azlaplcod = l_azlaplcod_aux

         #display "l_azlaplcod: ", l_azlaplcod

         if sqlca.sqlcode <> 0 or
            l_azlaplcod is null or
            l_azlaplcod = 0 then

            # Caso nao encontre azlaplcod valido, considera o ultimo valido.
            exit while
         end if

         let l_doc_handle = ctd02g00_agrupaXML2(l_azlaplcod)

         let l_situacao = figrc011_xpath(l_doc_handle,"/APOLICE/SITUACAO")
         let l_situacao = l_situacao clipped

         #display "----- TESTE MARCOS -----"
         #display "SITUACAO: ", l_situacao
         #display "------------------------"

      end while
   end if

   return l_doc_handle

 end function