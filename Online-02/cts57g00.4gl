#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema..: Porto Socorro                                                   #
# Modulo...: cts57g00                                                        #
# Objetivo.: Regra para definir tipo de veiculo de atendimento               #
# Analista.: Fabio Costa                                                     #
# PSI      : 246174 - iPhone                                                 #
# Liberacao: 17/11/2009                                                      #
#............................................................................#
# Observacoes                                                                #
#............................................................................#
# Alteracoes                                                                 #
#----------------------------------------------------------------------------#
globals "/homedsa/projetos/geral/globals/glct.4gl"

#----------------------------------------------------------------
function cts57g00_tipo_veiculo_atend(l_param)
#----------------------------------------------------------------

  define l_param record
         succod        like datrligapol.succod   ,
         ramcod        like datrservapol.ramcod  ,
         aplnumdig     like datrligapol.aplnumdig,
         itmnumdig     like datrligapol.itmnumdig,
         edsnumref     like datrligapol.edsnumref,
         asitipcod     like datmservico.asitipcod,
         camflg        char(01)
  end record
  
  define l_aux record
         atdvcltip  like datmservico.atdvcltip,
         vclatmflg  smallint
  end record
  
  initialize l_aux.* to null
  
  #----------------------------------------------------------------
  # Verifica se veiculo possui CAMBIO HIDRAMATICO/AUTOMATICO
  if l_param.ramcod = 31    or
     l_param.ramcod = 531  then
     let l_aux.vclatmflg = cts57g00_cambio(l_param.succod   ,
                                           l_param.aplnumdig,
                                           l_param.itmnumdig)
  end if
  
  #----------------------------------------------------------------
  # Quando o guincho nao for pequeno, atribui a flag de cambio
  # automatico ( 1->tem / null->nao tem ) (?????)
  
  if l_aux.atdvcltip != 2
     then
     let l_aux.atdvcltip = l_aux.vclatmflg
  end if
  
  #----------------------------------------------------------------
  # Verifica solicitacao de guincho para caminhao
  if l_param.asitipcod = 1  or       # Guincho
     l_param.asitipcod = 3  then     # Guincho/Tecnico
     if l_param.camflg = "S"  then
        let l_aux.atdvcltip = 3
     end if
  end if
  
  return l_aux.atdvcltip

end function

#---------------------------------------------------------------
function cts57g00_cambio(l_param)
#---------------------------------------------------------------

  define l_param record
         succod     like datrservapol.succod   ,
         aplnumdig  like datrservapol.aplnumdig,
         itmnumdig  like datrservapol.itmnumdig
  end record
  
  define l_cts57g00 record
         atdvcltip  like datmservico.atdvcltip,
         vclatmflg  like abbmveic.vclatmflg   ,
         vclchsfnl  like avlmveic.vclchsfnl   ,
         vcllicnum  like avlmveic.vcllicnum   ,
         vclcoddig  like avlmveic.vclcoddig   ,
         vstnumdig  like avlmlaudo.vstnumdig  ,
         vstdat     like avlmlaudo.vstdat     ,
         vsthor     like avlmlaudo.vsthor
  end record
  
  define l_sql        char(500)               ,
         l_vstnumdig  like avlmlaudo.vstnumdig,
         l_asstip     like avlmaces.asstip    ,
         l_asscoddig  like avlmaces.asscoddig

  
  initialize l_cts57g00.* to null
  initialize l_sql, l_vstnumdig, l_asstip, l_asscoddig to null
  
  if l_param.succod    is null  or
     l_param.aplnumdig is null  or
     l_param.itmnumdig is null 
     then
     return l_cts57g00.atdvcltip
  end if
  
  # prepares
  whenever error continue
  
  let l_sql = ' select vclatmflg   , vclcoddig, ',
              '        vcllicnum   , vclchsfnl  ',
              ' from abbmveic ',
              ' where succod    = ? ',
              '   and aplnumdig = ? ',
              '   and itmnumdig = ? ',
              '   and dctnumseq = ? '
  prepare p_veic_sel from l_sql
  declare c_veic_sel cursor for p_veic_sel
  
  let l_sql = ' select l.vstdat, l.vsthor, l.vstnumdig ',
              ' from avlmveic v, avlmlaudo l           ',
              ' where l.vstnumdig = v.vstnumdig        ',
              '   and (l.vstldostt = 0 or l.vstldostt is null) ',
              '   and v.vclchsfnl  = ? ',
              '   and v.vcllicnum  = ? ',
              '   and v.vclcoddig  = ? ',
              ' order by 1 desc, 2 desc '
  prepare p_laudovp_sel from l_sql
  declare c_laudovp_sel cursor for p_laudovp_sel
  
  let l_sql = ' select vstnumdig ',
              ' from avlmaces ',
              ' where vstnumdig = ? ',
              '   and asstip    = ? ',
              '   and asscoddig = ? '
  prepare p_aces_sel from l_sql
  declare c_aces_sel cursor for p_aces_sel
  
  whenever error stop
  
  if sqlca.sqlcode != 0
     then
     return l_cts57g00.atdvcltip
  end if

  #---------------------------------------------------------------
  # Obtem a ULTIMA SITUACAO do veiculo
  call f_funapol_ultima_situacao(l_param.succod, l_param.aplnumdig, 
                                 l_param.itmnumdig)
       returning g_funapol.*
  
  #---------------------------------------------------------------
  # Verifica se veiculo possui CAMBIO AUTOMATICO/HIDRAMATICO
  whenever error continue
  open c_veic_sel using l_param.succod, l_param.aplnumdig, l_param.itmnumdig,
                        g_funapol.vclsitatu
  fetch c_veic_sel into l_cts57g00.vclatmflg, l_cts57g00.vclcoddig,
                        l_cts57g00.vcllicnum, l_cts57g00.vclchsfnl
  whenever error stop
  
  if l_cts57g00.vclatmflg is not null and
     l_cts57g00.vclatmflg = "S" 
     then
     let l_cts57g00.atdvcltip = 1
     return l_cts57g00.atdvcltip
  end if
  
  #---------------------------------------------------------------
  # Obtem o ULTIMO NUMERO DE VISTORIA atraves da Vistoria Previa
  initialize l_cts57g00.vstnumdig to null
  
  if ( l_cts57g00.vclchsfnl is null or l_cts57g00.vclchsfnl = " " ) and
     ( l_cts57g00.vcllicnum is null or l_cts57g00.vcllicnum = " " )
     then
     return l_cts57g00.atdvcltip
  else
     whenever error continue
     open c_laudovp_sel using l_cts57g00.vclchsfnl, l_cts57g00.vcllicnum,
                              l_cts57g00.vclcoddig

     foreach c_laudovp_sel into l_cts57g00.vstdat, l_cts57g00.vsthor,
                                l_cts57g00.vstnumdig
         exit foreach
     end foreach
     whenever error stop
  end if
  
  if l_cts57g00.vstnumdig = 0  or  l_cts57g00.vstnumdig is null
     then
     initialize l_cts57g00.atdvcltip to null
  else

     # verifica nos ACESSORIOS da V.P. se existe cambio hidramatico
     whenever error continue
     
     let l_asstip    = 1
     let l_asscoddig = 175
     
     open c_aces_sel using l_cts57g00.vstnumdig, l_asstip, l_asscoddig
     fetch c_aces_sel into l_vstnumdig
     
     if sqlca.sqlcode <> 0  
        then
        let l_asscoddig = 2518
        
        open c_aces_sel using l_cts57g00.vstnumdig, l_asstip, l_asscoddig
        fetch c_aces_sel into l_vstnumdig
        
        if sqlca.sqlcode <> 0  then
           initialize l_cts57g00.atdvcltip to null
        else
           let l_cts57g00.atdvcltip = 1
        end if
     end if
     
     whenever error stop
     
  end if
  
  return l_cts57g00.atdvcltip

end function


