#------------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                              #
#------------------------------------------------------------------------------#
# Sistema    : PORTO SOCORRO                                                   #
# Modulo     : ctb00g15.4gl                                                    #
# Objetivo   : Qualificar a telemetria com o socorrista                        #
# Projeto    : PSI 258610                                                      #
# Analista   : Fabio Costa                                                     #
# Liberacao  : 24/08/2010                                                      #
# Observacoes: Quando houver erro de SQL ou de lógica, considerar qualificado  #
#------------------------------------------------------------------------------#
# ALTERACOES                                                                   #
# Data        Responsavel         PSI     Alteracao                            #
# ----------  ------------------  ------  -------------------------------------#
#------------------------------------------------------------------------------#
database porto

define m_prep smallint

#-------------------------------------------------------------------------------
function ctb00g15_prep()
#-------------------------------------------------------------------------------

  define l_sql char(1000)

  let m_prep = false

  let l_sql = ' select mdtbotprgseq, caddat, cadhor, lcllgt, lclltt, snsetritv '
            , '      , case mdtbotprgseq when 1 then "REC"        '
            , '                          when 2 then "INI"        '
            , '                          when 3 then "FIM"        '
            , '        end botao '
            , ' from datmmdtmvt m               '
            , ' where m.mdtmvttipcod = 2        '  # botao acionado
            , '   and m.mdtmvtstt    = 2        '  # processado
            , '   and m.mdtbotprgseq in (1,2,3) '  # REC/INI/FIM
            , '   and m.atdsrvano    = ?        '
            , '   and m.atdsrvnum    = ?        '
            , '   and m.mdtmvtseq = (select min(mdtmvtseq) from datmmdtmvt b '
            , '                      where b.atdsrvnum = m.atdsrvnum         '
            , '                        and b.atdsrvano = m.atdsrvano         '
            , '                        and b.mdtbotprgseq = m.mdtbotprgseq ) '
            , ' order by m.mdtbotprgseq '
  prepare p_sel_botoes_mdt from l_sql
  declare c_sel_botoes_mdt cursor with hold for p_sel_botoes_mdt

  let m_prep = true

end function

#-------------------------------------------------------------------------------
function ctb00g15_qualiftele(l_param)
#-------------------------------------------------------------------------------

  define l_param record
         atdsrvano     like datmservico.atdsrvano ,
         atdsrvnum     like datmservico.atdsrvnum ,
         prtbnfgrpcod  integer                    ,
         prslocflg     like datmservico.prslocflg
  end record

  define l_botoes_mdt array[03] of record
         mdtbotprgseq  like datmmdtmvt.mdtbotprgseq ,
         caddat        like datmmdtmvt.caddat       ,
         cadhor        like datmmdtmvt.cadhor       ,
         lcllgt        like datmmdtmvt.lcllgt       ,
         lclltt        like datmmdtmvt.lclltt       ,
         snsetritv     like datmmdtmvt.snsetritv    ,
         botabvdes     char(03)
  end record

  define l_retorno record
         coderro      integer  ,  # Codigo erro retorno / 0=Ok <>0=Error
         msgerro      char(150),  # Mensagem erro retorno
         qualificado  char(01)    # Sim ou Nao
  end record

  define l_ctb00g15 record
         errcod        integer                 ,
         txtwhe        char(50)                ,
         relpamtxt     char(75)                ,
         toldecrecini  decimal(5,2)            ,
         toldecinifim  decimal(5,2)            ,
         tolitvrecini  interval hour to second ,
         tolitvinifim  interval hour to second
  end record
  
  define l_aux record
         dathorinitxt  char(19)                ,
         dathorfimtxt  char(19)                ,
         hora_ini      datetime year to second ,
         hora_fim      datetime year to second
  end record

  define l_errcod, l_arr  smallint
  define l_botoes         char(15)
  
  initialize l_botoes_mdt, l_errcod, l_arr, l_botoes  to null
  initialize l_retorno.*, l_ctb00g15.*, l_aux.* to null
  initialize l_botoes_mdt to null

  if m_prep is null or m_prep != true
     then
     call ctb00g15_prep()
     if m_prep != true
        then
        return 0, '', 'S'
     end if
  end if

  let l_retorno.coderro = 0
  let l_retorno.msgerro = ''
  let l_retorno.qualificado = "S"
  
  # obter tolerancias cadastradas para a Telemetria
  #----------------------------------------------------------------
  let l_ctb00g15.txtwhe[01,04] = '|08|'
  let l_ctb00g15.txtwhe[05,06] = l_param.prtbnfgrpcod using "&&"
  let l_ctb00g15.txtwhe[07,07] = '|'
  let l_ctb00g15.txtwhe        = ' and relpamtxt matches "*',
                                 l_ctb00g15.txtwhe clipped,'*"'

  call ctd30g00_sel_igbm_whe(1, 'CRTBNFTOLRECINI', l_param.prtbnfgrpcod, 1, l_ctb00g15.txtwhe clipped)
       returning l_ctb00g15.errcod, l_ctb00g15.relpamtxt
       
  if l_ctb00g15.errcod != 0
     then
     if l_ctb00g15.errcod = 100
        then
        display ' Tolerancia nao cadastrada para TELEMETRIA grupo ',
              l_param.prtbnfgrpcod
     else
        display ' Erro na consulta a tolerancia: ', l_ctb00g15.errcod
     end if
     let l_ctb00g15.toldecrecini = 0
  else
     let l_ctb00g15.toldecrecini = l_ctb00g15.relpamtxt[8,13]
  end if

  let l_ctb00g15.errcod    = null
  let l_ctb00g15.relpamtxt = null
  
  call ctd30g00_sel_igbm_whe(1, 'CRTBNFTOLINIFIM', l_param.prtbnfgrpcod, 1, l_ctb00g15.txtwhe clipped)
       returning l_ctb00g15.errcod, l_ctb00g15.relpamtxt
       
  if l_ctb00g15.errcod != 0
     then
     if l_ctb00g15.errcod = 100
        then
        let l_retorno.msgerro = ' Tolerância não cadastrada para TELEMETRIA grupo ',
                                l_param.prtbnfgrpcod
     else
        let l_retorno.msgerro = ' Erro na consulta a tolerância: ', l_ctb00g15.errcod
     end if
     let l_ctb00g15.toldecinifim = 0
  else
     let l_ctb00g15.toldecinifim = l_ctb00g15.relpamtxt[8,13]
  end if
  
  # tolerancias nao cadastradas, nao encontradas ou nao convertidas,
  # bonifica
  #----------------------------------------------------------------
  if l_ctb00g15.toldecrecini = 0 or
     l_ctb00g15.toldecinifim = 0
     then
     let l_retorno.coderro = 0
     return l_retorno.coderro, l_retorno.msgerro, 'S'
  end if
  
  whenever error continue
  
  call ctb00g15_mindectoitvhs(l_ctb00g15.toldecrecini)
       returning l_ctb00g15.tolitvrecini

  call ctb00g15_mindectoitvhs(l_ctb00g15.toldecinifim)
       returning l_ctb00g15.tolitvinifim
       
  whenever error stop
       
  if l_ctb00g15.tolitvrecini is null or l_ctb00g15.tolitvrecini = '00:00:00' or
     l_ctb00g15.tolitvinifim is null or l_ctb00g15.tolitvinifim = '00:00:00'
     then
     let l_retorno.coderro = 0
     let l_retorno.msgerro = 'Tolerancia para telemetria nao identificada'
     return l_retorno.coderro, l_retorno.msgerro, 'S'
  end if
  
  # obter dados dos botoes digitados para comparar com as tolerancias
  #----------------------------------------------------------------
  let l_arr = 1
  let l_retorno.coderro = 0

  whenever error continue
  open c_sel_botoes_mdt using l_param.atdsrvano, l_param.atdsrvnum
  
  foreach c_sel_botoes_mdt into l_botoes_mdt[l_arr].mdtbotprgseq ,
                                l_botoes_mdt[l_arr].caddat       ,
                                l_botoes_mdt[l_arr].cadhor       ,
                                l_botoes_mdt[l_arr].lcllgt       ,
                                l_botoes_mdt[l_arr].lclltt       ,
                                l_botoes_mdt[l_arr].snsetritv    ,
                                l_botoes_mdt[l_arr].botabvdes   
     let l_arr = l_arr + 1
     
     if l_arr = 4
        then
        exit foreach
     end if
  end foreach
  
  whenever error stop
  
  if l_botoes_mdt[01].caddat is null or
     l_botoes_mdt[02].caddat is null or
     l_botoes_mdt[03].caddat is null
     then
     
     initialize l_botoes to null
     
     case
        when l_botoes_mdt[01].caddat is null
           let l_botoes = " REC"
        when l_botoes_mdt[02].caddat is null
           let l_botoes = l_botoes clipped, " INI"
        when l_botoes_mdt[03].caddat is null
           let l_botoes = l_botoes clipped, " FIM"
     end case
     
     let l_retorno.coderro = 0
     let l_retorno.msgerro = 'Botoes nao localizados para o servico: ', l_botoes clipped
     
     return l_retorno.coderro, l_retorno.msgerro, 'S'
  end if
  
  # verificar se REC/INI é menor que a tolerancia
  initialize l_aux.* to null
  
  if l_botoes_mdt[2].snsetritv is null
     then
     let l_aux.dathorinitxt = l_botoes_mdt[01].caddat using "yyyy-mm-dd", " ", 
                              l_botoes_mdt[01].cadhor
     let l_aux.hora_ini = l_aux.dathorinitxt
     
     let l_aux.dathorfimtxt = l_botoes_mdt[02].caddat using "yyyy-mm-dd", " ", 
                              l_botoes_mdt[02].cadhor
     let l_aux.hora_fim = l_aux.dathorfimtxt
  
     let l_botoes_mdt[2].snsetritv = l_aux.hora_fim - l_aux.hora_ini
  end if
  
  if l_botoes_mdt[2].snsetritv is null
     then
     let l_retorno.coderro = 0
     let l_retorno.msgerro = ' Nao e possivel determinar intervalo REC/INI '
     return l_retorno.coderro, l_retorno.msgerro, 'S'
  else
     if l_param.prslocflg is not null and 
        l_param.prslocflg = "S"    # prestador no local, REC/INI sempre valido 
        then
        let l_retorno.qualificado = "S"
     else
        if l_botoes_mdt[2].snsetritv >= l_ctb00g15.tolitvrecini
           then
           let l_retorno.qualificado = "S"
        else
           let l_retorno.qualificado = "N"
        end if
     end if
  end if
  
  # verificar se INI/FIM é menor que a tolerancia, se REC/INI estiver qualificado
  initialize l_aux.* to null
  
  if l_retorno.qualificado = "S"
     then
     if l_botoes_mdt[3].snsetritv is null
        then
        let l_aux.dathorinitxt = l_botoes_mdt[02].caddat using "yyyy-mm-dd", " ", 
                                 l_botoes_mdt[02].cadhor
        let l_aux.hora_ini = l_aux.dathorinitxt
        
        let l_aux.dathorfimtxt = l_botoes_mdt[03].caddat using "yyyy-mm-dd", " ", 
                                 l_botoes_mdt[03].cadhor
        let l_aux.hora_fim = l_aux.dathorfimtxt
     
        let l_botoes_mdt[3].snsetritv = l_aux.hora_fim - l_aux.hora_ini
     end if
     
     if l_botoes_mdt[3].snsetritv is null
        then
        let l_retorno.coderro = 0
        let l_retorno.msgerro = ' Nao e possivel determinar intervalo INI/FIM '
        return l_retorno.coderro, l_retorno.msgerro, 'S'
     else
        if l_botoes_mdt[3].snsetritv >= l_ctb00g15.tolitvinifim
           then
           let l_retorno.qualificado = "S"
        else
           let l_retorno.coderro = 99
           let l_retorno.qualificado = "N"
        end if
     end if
  else
     let l_retorno.coderro = 99
     let l_retorno.qualificado = "N"
  end if
  
  # texto para o relatorio ao prestador
  # Intervalo minimo REC-INI 0:10:00 | Intervalo realizado 0:10:00 / Intervalo minimo INI-FIM 0:10:00 | Intervalo realizado 0:10:00
  let l_retorno.msgerro = 'Intervalo REC-INI Min '   , l_ctb00g15.tolitvrecini   , 
                          ' | Intervalo realizado '  , l_botoes_mdt[2].snsetritv ,
                          ' / Intervalo INI-FIM Min ', l_ctb00g15.tolitvinifim   , 
                          ' | Intervalo realizado '  , l_botoes_mdt[3].snsetritv 
 
  return l_retorno.coderro, l_retorno.msgerro, l_retorno.qualificado
  
end function

#----------------------------------------------------------------
function ctb00g15_mindectoitvhs(l_numdec)
#----------------------------------------------------------------
# recebe quantidade de minutos em decimal e devolve em intevalo 
# hour to second 
  define l_numdec  decimal(10,2)
  
  define l_dtoh record
         itvhts   interval hour to second ,
         segint   integer  ,
         minint   integer  ,
         horint   integer  ,
         itvchr   char(08)
  end record
  
  initialize l_dtoh.* to null
  
  let l_dtoh.segint = 0
  let l_dtoh.minint = 0
  let l_dtoh.horint = 0
  
  # define intervalo REC/
  if l_numdec < 0
     then
     let l_dtoh.itvchr  = '00:00:', l_numdec * 60
     
  else
  
     if l_numdec >= 60
        then
        let l_dtoh.horint = l_numdec / 60  # horas
        let l_numdec = l_numdec - (l_dtoh.horint * 60)
     end if
     
     let l_dtoh.minint = l_numdec  # minutos
     let l_dtoh.segint = (l_numdec - l_dtoh.minint) * 60  # seg
     
     let l_dtoh.itvchr = l_dtoh.horint using "&&", ':',
                         l_dtoh.minint using "&&", ':',
                         l_dtoh.segint using "&&"
  end if
  
  let l_dtoh.itvhts = l_dtoh.itvchr
  
  return l_dtoh.itvhts
  
end function
