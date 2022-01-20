###############################################################################
# Nome do Modulo: ctc25m00                                           Marcus   #
#                                                                             #
# Cadastro dos procedimentos de tela                                 Abr/2002 #
###############################################################################
#                                                                             #
#                        * * * Alteracoes * * *                               #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------  #
# 10/09/2003  Meta,Bruno     PSI175269 Implementacao do campo departamento.   #
#                            OSF25780                                         #
# --------------------------------------------------------------------------- #
###############################################################################

 globals "/homedsa/projetos/geral/globals/glct.4gl"   

# PSI 175269 - Inicio 
 
 define m_prep_sql   smallint

 function ctc25m00_prepare()
 
    define l_sql        char(500)
        
    let l_sql = 'select dptnom from isskdepto ',
                ' where dptsgl = ? '  
    prepare pctc25m0001   from l_sql
    declare cctc25m0001   cursor for pctc25m0001

    let l_sql = 'insert into datktelprc (prcsitcod ',
                '                       ,telprccod ',
                '                       ,viginchordat ',
                '                       ,vigfnlhordat ',
                '                       ,telcod ',
                '                       ,empcod ',
                '                       ,atlusrtip ',
                '                       ,atlmat ',
                '                       ,dptsgl) ',
                'values ("A",?,?,?,?,?,?,?,?)'
    prepare pctc25m0002   from l_sql

    let m_prep_sql = true
    
 end function
 
# PSI 175269 - Fim

#------------------------------------------------------------
 function ctc25m00()
#------------------------------------------------------------

 define d_ctc25m00   record
    telcod           like datktel.telcod,
    telnom           like datktel.telnom,
    teldsc           like datktel.teldsc,
    viginc           date,
    viginchor        datetime hour to minute,
    vigfnl           date,
    vigfnlhor        datetime hour to minute,
    dptsgl           like datktelprc.dptsgl,  # PSI 175269
    dptnom           like isskdepto.dptnom    # PSI 175269
 end record


 define ws           record
    tabnum           like itatvig.tabnum,
    telprccod        like datktelprc.telprccod,
    viginchordat     like datktelprc.viginchordat,
    vigfnlhordat     like datktelprc.vigfnlhordat,
    horaatu          char(05),
    data1            char(10),
    data2            char(16),
    acao             char(01),
    count            integer,
    confirma         char(01),
    cabtxt           char(18)
 end record
 
 define arr_aux        integer
 define scr_aux        integer
 define ws_conta       integer

 # PSI 175269 - Inicio
 
 define l_dpt_pop    record
    lin              smallint,
    col              smallint,
    title            char(054),
    col_tit_1        char(012),
    col_tit_2        char(040),
    tipcod           char(001),
    cmd_sql          char(600),
    comp_sql         char(200),
    tipo             char(001)
 end record 
 
 define l_achou      smallint

 if m_prep_sql is null or m_prep_sql = false then
    call ctc25m00_prepare()
 end if
 
 ## PSI 175269 - Fim   

 open window w_ctc25m00 at 6,2 with form "ctc25m00"
      attribute (form line 1)

 let int_flag  =  false
 let arr_aux   =  1

 while not int_flag

    initialize ws.*          to null
    initialize d_ctc25m00.*  to null
    clear form

    input by name  d_ctc25m00.telcod,
                   d_ctc25m00.telnom,
                   d_ctc25m00.teldsc,
                   d_ctc25m00.viginc,
                   d_ctc25m00.viginchor,
                   d_ctc25m00.vigfnl,
                   d_ctc25m00.vigfnlhor,
                   d_ctc25m00.dptsgl,                     # PSI 175269
                   d_ctc25m00.dptnom  without defaults    # PSI 175269

    before field telnom
       display by name d_ctc25m00.telnom attribute (reverse)

    after field telnom
       display by name d_ctc25m00.telnom
       
       if d_ctc25m00.telnom is NULL then
          error "Nome da tela deve ser informada"
          call ctc25m04() returning d_ctc25m00.telcod, 
                                    d_ctc25m00.telnom,
                                    d_ctc25m00.teldsc

          display by name d_ctc25m00.telcod,
                          d_ctc25m00.telnom,
                          d_ctc25m00.teldsc

          next field viginc
       else
          select telcod,
                 teldsc
            into d_ctc25m00.telcod,
                 d_ctc25m00.teldsc
            from datktel
          where telnom = d_ctc25m00.telnom
   
          if sqlca.sqlcode = NOTFOUND then
            error "Tela nao cadastrada" 
            next field telnom
          end if
       end if

       display by name d_ctc25m00.teldsc
       
    before field viginc
       display by name d_ctc25m00.viginc attribute (reverse)

    after  field viginc
       display by name d_ctc25m00.viginc

       if d_ctc25m00.viginc is null   then
          error " Data inicio de vigencia deve ser informada!"
          next field viginc
       end if

       if d_ctc25m00.viginc  <  today   then
          error " Data inicio de vigencia nao deve ser anterior data atual!"
          next field viginc
       end if

    before field viginchor
       display by name d_ctc25m00.viginchor attribute (reverse)

    after  field viginchor
       display by name d_ctc25m00.viginchor

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field viginc
       end if

       if d_ctc25m00.viginchor is null then
          error " Hora inicio de vigencia deve ser informado!"
          next field viginchor
       end if

       if d_ctc25m00.viginc = today   then
          let ws.horaatu  =  current hour to minute
          if d_ctc25m00.viginchor < current hour to minute  then
             error " Horario vig inicial nao deve ser menor que hora atual --> ", ws.horaatu
             next field viginchor
            end if
       end if

       let ws.data1  =  d_ctc25m00.viginc
       let ws.data2  =  ws.data1[7,10], "-",
                        ws.data1[4,5],  "-",
                        ws.data1[1,2],  " ",
                        d_ctc25m00.viginchor

       let ws.viginchordat  =  ws.data2

    before field vigfnl
       let d_ctc25m00.vigfnl = "31/12/2099"
       display by name d_ctc25m00.vigfnl  attribute (reverse)

    after  field vigfnl
       display by name d_ctc25m00.vigfnl

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field viginchor
       end if

       if d_ctc25m00.vigfnl is null then
          error " Data final de vigencia deve ser informada!"
          next field vigfnl
       end if

       if d_ctc25m00.vigfnl < d_ctc25m00.viginc then
         error " Final de vigencia nao deve ser menor que inicio de vigencia!"
          next field vigfnl
       end if

    before field vigfnlhor
       display by name d_ctc25m00.vigfnlhor attribute (reverse)

    after  field vigfnlhor
       display by name d_ctc25m00.vigfnlhor

       if fgl_lastkey() = fgl_keyval("up")   or
          fgl_lastkey() = fgl_keyval("left") then
          next field vigfnl
       end if

       if d_ctc25m00.vigfnlhor is null then
          error " Hora final de vigencia deve ser informado!"
          next field vigfnlhor
       end if

       if d_ctc25m00.vigfnl = today   then
          let ws.horaatu  =  current hour to minute
          if d_ctc25m00.vigfnlhor < current hour to minute  then
             error " Horario vig final nao deve ser menor que hora atual --> ", ws.horaatu
             next field vigfnlhor
          end if
       end if

       if d_ctc25m00.viginc = d_ctc25m00.vigfnl then
          if d_ctc25m00.vigfnlhor < d_ctc25m00.viginchor then
             error " Hora final vigencia menor que hora inicial vigencia!"
             next field vigfnlhor
          end if
       end if

# PSI 175269 - Inicio 

       before field dptsgl

          if d_ctc25m00.dptsgl is null then 
             let d_ctc25m00.dptsgl = g_issk.dptsgl
          end if
          if d_ctc25m00.dptsgl is not null then 
             open cctc25m0001  using d_ctc25m00.dptsgl
             whenever error continue
             fetch cctc25m0001 into d_ctc25m00.dptnom
             whenever error stop
             if  sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = notfound then
                   let d_ctc25m00.dptnom = null
                else 
                   display 'Erro SELECT dptnom ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                   let int_flag = true
                   exit input
                end if
             end if  
             display by name d_ctc25m00.dptnom
          end if 

          display by name d_ctc25m00.dptsgl

       after  field dptsgl
          display by name d_ctc25m00.dptsgl

          let d_ctc25m00.dptnom = null
          if d_ctc25m00.dptsgl is not null then
             open cctc25m0001  using d_ctc25m00.dptsgl
             whenever error continue
             fetch cctc25m0001 into d_ctc25m00.dptnom
             whenever error stop
             if  sqlca.sqlcode <> 0 then
                if sqlca.sqlcode = notfound then
                   let d_ctc25m00.dptnom = null
                else 
                   display 'Erro SELECT dptnom ',sqlca.sqlcode, '|',sqlca.sqlerrd[2]
                   let int_flag = true
                   exit input
                end if
             end if  
          end if 
          display by name d_ctc25m00.dptnom
 
          let ws.data1  =  d_ctc25m00.vigfnl
          let ws.data2  =  ws.data1[7,10], "-",
                           ws.data1[4,5],  "-",
                           ws.data1[1,2],  " ",
                           d_ctc25m00.vigfnlhor
   
          let ws.vigfnlhordat = ws.data2
        
          call ctc25m00_insere(d_ctc25m00.telcod,
                               ws.viginchordat,
                               ws.vigfnlhordat,
                               d_ctc25m00.dptsgl)    ## PSI 175269
               returning ws.telprccod
   
          call ctc21m06(1,0,ws.telprccod)
          
          let int_flag = false
          
          exit input
      
        on key(f5)

            initialize l_dpt_pop    to null                  
            let l_dpt_pop.lin       = 10
            let l_dpt_pop.col       =  2
            let l_dpt_pop.title     = 'Departamentos'
            let l_dpt_pop.col_tit_1 = 'Sigla'
            let l_dpt_pop.col_tit_2 = 'Nome Departamento'
            let l_dpt_pop.tipcod    = 'A'
            let l_dpt_pop.tipo      = 'D'
            let l_dpt_pop.cmd_sql   = 'select dptsgl, dptnom ',
                                      '  from isskdepto ',
                                      ' order by dptnom'
            call ofgrc001_popup(l_dpt_pop.*) returning l_achou,
                                                       d_ctc25m00.dptsgl,
                                                       d_ctc25m00.dptnom
                                             
            if   l_achou = 1 then
                 let d_ctc25m00.dptsgl = null
                 let d_ctc25m00.dptnom = null
            end if
            
            display by name d_ctc25m00.dptsgl
            display by name d_ctc25m00.dptnom
                                                
# PSI 175269 - Final          
       
       on key (interrupt)
          exit input
          
    end input
          
    if int_flag then
       exit while
    end if
          
    call set_count(arr_aux - 1)
    let arr_aux = 1
          
 end while
          
 let int_flag = false
 close window w_ctc25m00
          
end function   ###--- ctc25m00
          
#------------------------------------------------------------------------------
function ctc25m00_insere(param)
#------------------------------------------------------------------------------

define param record 
  telcod         like datktelprc.telcod,
  viginchordat   like datktelprc.viginchordat,
  vigfnlhordat   like datktelprc.vigfnlhordat,
  dptsgl         like datktelprc.dptsgl     ## PSI 175269
 end record

define aux_telprccod like datktelprc.telprccod

## PSI 175269 - Inicio

 if m_prep_sql is null or m_prep_sql = false then
    call ctc25m00_prepare()
 end if

## PSI 175269 - Fim

select max(telprccod)
  into aux_telprccod
  from datktelprc

if aux_telprccod is NULL then
   let aux_telprccod = 0
end if

let aux_telprccod = aux_telprccod + 1

 ## PSI 175269 - Inicio
  begin work
  whenever error continue
  execute pctc25m0002  using aux_telprccod,
                             param.viginchordat,
                             param.vigfnlhordat,
                             param.telcod,
                             g_issk.empcod,
                             g_issk.usrtip,
                             g_issk.funmat,
                             param.dptsgl
  whenever error stop
## PSI 175269 - Fim
 
  if sqlca.sqlcode <> 0  then
    error " Erro (", sqlca.sqlcode, ") na inclusao de procedimento de tela!"
    let aux_telprccod = -1
    rollback work
  else
    commit work
  end if
   
return aux_telprccod
end function
