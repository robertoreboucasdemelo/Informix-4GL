#===========================================================================
# Sistema   : Porto Socorro - ctg07
# Modulo    : ctn55g00.4gl
# Objetivo  : Pop-up de socorristas para conferencia de guias de recolhimento
#             de impostos 
# Analista  : Fabio Costa
# Liberacao : 26/02/2009
#===========================================================================
database porto

define l_prep smallint

#----------------------------------------------------------------
function ctn55g00(l_socopgnum)
#----------------------------------------------------------------

  define l_sql        char(1000) ,
         l_date       date       ,
         l_pstcoddig  dec(6,0)   ,
         l_arr        integer    ,
         l_qtdqras    integer    ,
         l_pstvintip  dec(1,0)   ,
         l_message    char(63)   ,
         l_socopgnum  like dbsmopg.socopgnum ,
         l_cur        integer
         
  define l_qra_arr array[400] of record  # nao identificado mais de 250 QRAs/PRS
         srrcoddig  like datrsrrpst.srrcoddig ,
         srrnom     like datksrr.srrnom       ,
         viginc     date                      ,
         pstvindes  char(11)
  end record
  
  whenever error continue
  if l_prep = false   -- nao repetir prepares
     then
     let l_sql = " select distinct o.pstcoddig     ",
                 " from dbsmopg o                  ",
                 "    , dbsmopgitm i               ",
                 "    , datmservico s              ",
                 "    , dpaksocor k                ",
                 " where o.socopgnum = i.socopgnum ",
                 "   and o.pstcoddig = k.pstcoddig ",
                 "   and i.atdsrvnum = s.atdsrvnum ",
                 "   and i.atdsrvano = s.atdsrvano ",
                 "   and s.ciaempcod = 1           ",  -- empresa Porto
                 "   and o.soctip in (1,3)         ",  -- Auto e RE
                 "   and k.qldgracod = 1           ",  -- Padrao qualid. Porto
                 "   and o.socopgnum = ?           "
     prepare p_pstops from l_sql
     declare c_pstops cursor for p_pstops
     
     -- montar lista de QRAs com ligacao prestador/socorrista, condicao
     -- socorrista ativo e vigente para o Prestador
     let l_sql = " select p.srrcoddig, s.srrnom, p.viginc, p.pstvintip ",
                 " from dpaksocor k, datrsrrpst p, datksrr s           ",
                 " where k.pstcoddig = p.pstcoddig                     ",
                 "   and p.srrcoddig = s.srrcoddig                     ",
                 "   and today between p.viginc and p.vigfnl           ",
                 "   and s.srrstt    = 1                               ",
                 "   and k.pstcoddig = ?                               ",
                 " order by 1,2                                        "
     prepare p_qrapst from l_sql
     declare c_qrapst cursor for p_qrapst
  end if
  whenever error stop
  
  let l_pstcoddig = null
  
  whenever error continue
  open c_pstops using l_socopgnum
  fetch c_pstops into l_pstcoddig
  whenever error stop
  
  # so mostrar lista de QRAs se a OP atende aos requisitos
  if l_pstcoddig is null or l_pstcoddig = 0
     then
     return
  end if
  
  let int_flag = false
  initialize l_qra_arr to null
  
  let l_arr = 1
  let l_pstvintip = null
  
  whenever error continue
  open c_qrapst using l_pstcoddig
  foreach c_qrapst into l_qra_arr[l_arr].srrcoddig ,
                        l_qra_arr[l_arr].srrnom    ,
                        l_qra_arr[l_arr].viginc    ,
                        l_pstvintip
     
     whenever error continue
     select cpodes
      into l_qra_arr[l_arr].pstvindes
      from iddkdominio
     where cponom  = "pstvintip"
       and cpocod  = l_pstvintip
     whenever error stop
     
     if l_qra_arr[l_arr].pstvindes is null or l_qra_arr[l_arr].pstvindes = ' '
        then
        let l_qra_arr[l_arr].pstvindes = 'N/D'
     end if
     
     if l_arr > 400  then
        error " Limite excedido. Existem mais de 400 QRAS ligados ao prestador!"
        exit foreach
     end if
     
     let l_arr = l_arr + 1
     let l_pstvintip = null
     
  end foreach
  whenever error stop
  
  let l_qtdqras = l_arr - 1
  
  if l_qtdqras >= 1 
     then
     
     open window ctn55g00 at 10,15 with form "ctn55g00"
          attribute(form line 1, border, message line last)
     
     let l_message = " ATENCAO:VERIFIQUE RECOLHIMENTO DE IMPOSTOS DE ", 
                     l_qtdqras using "###", " FUNCIONARIOS"
     message l_message attribute (reverse)
     
     call set_count(l_qtdqras)
     
     display array l_qra_arr to s_ctn55g00.*
  
        on key (interrupt, control-c, F8, esc, accept)
           #let l_cur = arr_curr()   # Trava de verificacao nao sera utilizada
           #if l_cur < arr_count()
           #   then
           #   error "Para sair va ate o ultimo registro"
           #else
              initialize l_qra_arr to null
              exit display
           #end if
           
     end display
     
     let int_flag = false
     close window ctn55g00
  else
     error " Nao foram encontrados QRAs cadastrados" attribute (reverse)
  end if
  
end function

