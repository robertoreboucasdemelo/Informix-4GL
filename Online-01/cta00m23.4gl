#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m23.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Recupera Clientes PSS                                      #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 12/01/2010                                                #
#............................................................................#


globals  "/homedsa/projetos/geral/globals/glct.4gl"
globals  "/homedsa/projetos/geral/globals/sg_glob3.4gl"


define  m_prepare  smallint

define mr_array array[500] of record
       cgccpf    like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pesnom    like gsakpes.pesnom    ,
       pestip    like gsakpes.pestip    ,
       pesnum    like gsakpes.pesnum    ,
       endlgd    like gsakpesend.endlgd ,
       endbrr    like gsakpesend.endbrr ,
       endcid    like gsakpesend.endcid ,
       endufd    like gsakpesend.endufd ,
       obs       char(70)
end record

define a_cta00m23 array[500] of record
       seta    char(01)            ,
       cgccpf  char(20)            ,
       pesnom  like gsakpes.pesnom ,
       endcep  char(09)
end record


#------------------------------------------------------------------------------
function cta00m23_sql_cliente()
#------------------------------------------------------------------------------
define l_sql  char(200)
    let l_sql = " select * from cta00m23_temp"  ,
                " order by pesnom "
    prepare pcta00m23001 from l_sql
    declare ccta00m23001 cursor for pcta00m23001
    return
end function

#------------------------------------------------------------------------------
function cta00m23_cria_temp()
#------------------------------------------------------------------------------
 call cta00m23_drop_temp()
 whenever error continue
      create temp table cta00m23_temp (pesnom    char(70)
                                      ,cgccpfnum decimal(12,0)
                                      ,cgcord    decimal(4,0)
                                      ,cgccpfdig decimal(2,0)
                                      ,pestip    char(01)
                                      ,pesnum    decimal(12,0)
                                      ,endcep    char(09)
                                      ,endlgd    char(40)
                                      ,endbrr    char(40)
                                      ,endcid    char(40)
                                      ,endufd    char(02)) with no log
 create unique index idx_tmpcta00m23 on cta00m23_temp (cgccpfnum)
  whenever error stop
      if sqlca.sqlcode <> 0  then
	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cta00m23_drop_temp()
	  end if
	 return false
     end if
     return true
end function

#------------------------------------------------------------------------------
function cta00m23_drop_temp()
#------------------------------------------------------------------------------
    whenever error continue
        drop table cta00m23_temp
    whenever error stop
    return
end function
#------------------------------------------------------------------------------
function cta00m23_prep_temp()
#------------------------------------------------------------------------------
    define w_ins char(1000)
    let w_ins = 'insert into cta00m23_temp'
	     , ' values(?,?,?,?,?,?,?,?,?,?,?)'
    prepare p_insert from w_ins
end function


#------------------------------------------------------------------------------
function cta00m23_rec_cliente(lr_param)
#------------------------------------------------------------------------------
define lr_param record
       pesnom      like gsakpes.pesnom   ,
       pestip      like gsakpes.pestip   ,
       cgccpfnum   like gsakpes.cgccpfnum,
       cgcord      like gsakpes.cgcord   ,
       cgccpfdig   like gsakpes.cgccpfdig
end record

define ws record
       sqlcode integer,
       qtd smallint
end record

define lr_cta00m23 record
       pesnom      like gsakpes.pesnom     ,
       cgccpfnum   like gsakpes.cgccpfnum  ,
       cgcord      like gsakpes.cgcord     ,
       cgccpfdig   like gsakpes.cgccpfdig  ,
       pestip      like gsakpes.pestip     ,
       pesnum      like gsakpes.pesnum     ,
       cep         char(09)                ,
       endlgd      like gsakpesend.endlgd  ,
       endbrr      like gsakpesend.endbrr  ,
       endcid      like gsakpesend.endcid  ,
       endufd      like gsakpesend.endufd
end record

define lr_retorno record
       erro      smallint                      ,
       mens      char(50)                      ,
       cgccpf    like gsakpes.cgccpfnum        ,
       cgcord    like gsakpes.cgcord           ,
       cgccpfdig like gsakpes.cgccpfdig        ,
       pesnom    like gsakpes.pesnom           ,
       pestip    like gsakpes.pestip           ,
       prod      like gsakprdunfseg.unfprdcod  ,
       psscntcod like kspmcntrsm.psscntcod     ,
       pesnum    like gsakpes.pesnum
end record

define lr_cta00m25 record
       endlgdtip  like gsakpesend.endlgdtip   ,
       endlgd     like gsakpesend.endlgd      ,
       endnum     like gsakpesend.endnum      ,
       endcmp     like gsakpesend.endcmp      ,
       endcep     like gsakpesend.endcep      ,
       endcepcmp  like gsakpesend.endcepcmp   ,
       endbrr     like gsakpesend.endbrr      ,
       endcid     like gsakpesend.endcid      ,
       endufd     like gsakpesend.endufd
end record

define lr_aux record
   sqlcode   smallint,
   aux_qtd   smallint,
   cep       char(09)
end record


define l_index  integer
define l_index2 integer

initialize lr_retorno.*  ,
           lr_cta00m23.* ,
           lr_aux.*      ,
           ws.* to null
let lr_retorno.erro = 0
for     l_index  =  1  to  500
        initialize  a_cta00m23[l_index].* to  null
        initialize  mr_array[l_index].*   to  null
end  for

let l_index         = 0
let l_index2        = 0
let lr_retorno.prod = 25 # Produto PSS

  if lr_param.pesnom is not null then
        if not cta00m23_cria_temp() then
            let ws.sqlcode = 1
            error  "Erro na Criacao da Tabela Temporaria!"
        else
            let ws.sqlcode = 0
        end if
        if ws.sqlcode = 0 then
            call cta00m23_prep_temp()
            # Recupera todos os Clientes
            message " Aguarde, pesquisando Base de Clientes Unificados..." attribute (reverse)
            # Carrego os Dados dos Clientes - gsakpes
            call osgtf550_busca_cliente_por_fonetica(lr_param.pesnom,
                                                     lr_param.pestip,
                                                     "U")
            returning ws.*
            for l_index  =  1  to ws.qtd
               if ga_gsakpes[l_index].cgccpfnum <> 0 and
                  ga_gsakpes[l_index].cgccpfnum is not null then
                  call osgtf550_lista_unfclisegcod_por_pesnum(ga_gsakpes[l_index].pesnum ,lr_retorno.prod)
                  returning lr_aux.sqlcode,lr_aux.aux_qtd
                    if lr_aux.aux_qtd > 0 then
                        if l_index2 > 500 then
                           error  " Mais de 500 Registros Selecionados,",
                                  " Complemente a sua Consulta!"
                           let lr_retorno.erro = 2
                           return  lr_retorno.cgccpf    ,
                                   lr_retorno.cgcord    ,
                                   lr_retorno.cgccpfdig ,
                                   lr_retorno.pesnom    ,
                                   lr_retorno.pestip    ,
                                   lr_retorno.psscntcod ,
                                   lr_retorno.pesnum    ,
                                   lr_retorno.erro
                        end if
                        # Recupera o Endereco
                        call cta00m25_endereco_pss(ga_gsakpes[l_index].pesnum)
                        returning  lr_cta00m25.endlgdtip ,
                                   lr_cta00m25.endlgd    ,
                                   lr_cta00m25.endnum    ,
                                   lr_cta00m25.endcmp    ,
                                   lr_cta00m25.endufd    ,
                                   lr_cta00m25.endbrr    ,
                                   lr_cta00m25.endcid    ,
                                   lr_cta00m25.endcep    ,
                                   lr_cta00m25.endcepcmp
                        if lr_cta00m25.endlgd is not null then
                           let lr_cta00m25.endlgd = lr_cta00m25.endlgdtip clipped ,
                                                    " "                           ,
                                                    lr_cta00m25.endlgd    clipped ,
                                                    " "                           ,
                                                    lr_cta00m25.endnum    clipped
                           let lr_aux.cep = lr_cta00m25.endcep clipped , "-",
                                            lr_cta00m25.endcepcmp using "<<<<<<<<"
                        end if
                        whenever error continue
                        execute p_insert using  ga_gsakpes[l_index].pesnom
                                               ,ga_gsakpes[l_index].cgccpfnum
                                               ,ga_gsakpes[l_index].cgcord
                                               ,ga_gsakpes[l_index].cgccpfdig
                                               ,ga_gsakpes[l_index].pestip
                                               ,ga_gsakpes[l_index].pesnum
                                               ,lr_aux.cep
                                               ,lr_cta00m25.endlgd
                                               ,lr_cta00m25.endbrr
                                               ,lr_cta00m25.endcid
                                               ,lr_cta00m25.endufd
                        whenever error stop
                        let l_index2 = l_index2 + 1
                     end if
               end if
            end for
            call cta00m23_sql_cliente()
            let l_index = 0
            if l_index2 > 0 then
                 open ccta00m23001
                 foreach ccta00m23001 into lr_cta00m23.*
                    let l_index = l_index + 1
                    let mr_array[l_index].pesnom    = lr_cta00m23.pesnom
                    let mr_array[l_index].cgccpf    = lr_cta00m23.cgccpfnum
                    let mr_array[l_index].cgcord    = lr_cta00m23.cgcord
                    let mr_array[l_index].cgccpfdig = lr_cta00m23.cgccpfdig
                    let mr_array[l_index].pestip    = lr_cta00m23.pestip
                    let mr_array[l_index].pesnum    = lr_cta00m23.pesnum
                    let mr_array[l_index].endlgd    = lr_cta00m23.endlgd
                    let mr_array[l_index].endbrr    = lr_cta00m23.endbrr
                    let mr_array[l_index].endcid    = lr_cta00m23.endcid
                    let mr_array[l_index].endufd    = lr_cta00m23.endufd
                    let a_cta00m23[l_index].pesnom = lr_cta00m23.pesnom
                    let a_cta00m23[l_index].cgccpf = cta00m23_formata_cgccpf(lr_cta00m23.cgccpfnum,
                                                                             lr_cta00m23.cgcord   ,
                                                                             lr_cta00m23.cgccpfdig)
                    let a_cta00m23[l_index].endcep = lr_cta00m23.cep
                 end foreach
                 message ""
                 open window cta00m23 at 04,02 with form "cta00m23"
                                       attribute(form line 1)
                 call set_count(l_index)
                 options insert   key F40
                 options delete   key F35
                 options next     key F30
                 options previous key F25
                 let mr_array[1].obs = "                        (F8)Seleciona (F17)Abandona"
                 display by name mr_array[1].obs
                 input array a_cta00m23 without defaults from s_cta00m23.*
                 before field seta
                 let l_index  = arr_curr()
                 display by name mr_array[l_index].endlgd
                 display by name mr_array[l_index].endbrr
                 display by name mr_array[l_index].endcid
                 display by name mr_array[l_index].endufd
                 after field seta
                  if  fgl_lastkey() <> fgl_keyval("up")   and
                      fgl_lastkey() <> fgl_keyval("left") then
                           if a_cta00m23[l_index + 1 ].pesnom is null then
                                 next field seta
                           end if
                  end if
                 on key (interrupt)
                     let lr_retorno.erro      = 1
                     let lr_retorno.cgccpf    = null
                     let lr_retorno.cgcord    = null
                     let lr_retorno.cgccpfdig = null
                     let lr_retorno.pesnom    = null
                     let lr_retorno.pestip    = null
                     let lr_retorno.psscntcod = null
                     let lr_retorno.pesnum    = null
                     exit input
                 on key(f8)
                     let l_index  = arr_curr()
                     let lr_retorno.cgccpf    =  mr_array[l_index].cgccpf
                     let lr_retorno.cgcord    =  mr_array[l_index].cgcord
                     let lr_retorno.cgccpfdig =  mr_array[l_index].cgccpfdig
                     let lr_retorno.pesnom    =  mr_array[l_index].pesnom
                     let lr_retorno.pestip    =  mr_array[l_index].pestip
                     let lr_retorno.pesnum    =  mr_array[l_index].pesnum
                     call cta00m24(lr_retorno.cgccpf    ,
                                   lr_retorno.cgcord    ,
                                   lr_retorno.cgccpfdig ,
                                   lr_retorno.pesnom    ,
                                   lr_retorno.pestip    )
                     returning lr_retorno.psscntcod
                     if lr_retorno.psscntcod is not null then
                        exit input
                     end if
                 end input
                 close window cta00m23
            else
                 let lr_retorno.erro = 3
            end if
        end if
  else
        if lr_param.cgcord is null then
           let lr_param.cgcord = 0
         end if
         # Recupera pela gsakpes
         call osgtf550_busca_cliente_cgccpf (lr_param.cgccpfnum ,
                                             lr_param.cgcord    ,
                                             lr_param.cgccpfdig ,
                                             lr_param.pestip    )
         returning ws.sqlcode, ws.qtd
         for l_index  =  1  to ws.qtd
               call osgtf550_lista_unfclisegcod_por_pesnum(g_a_cliente[l_index].pesnum,lr_retorno.prod)
               returning lr_aux.sqlcode,lr_aux.aux_qtd
               if lr_aux.aux_qtd > 0 then
                  let lr_retorno.cgccpf    = g_a_cliente[1].cgccpfnum
                  let lr_retorno.cgcord    = g_a_cliente[1].cgcord
                  let lr_retorno.cgccpfdig = g_a_cliente[1].cgccpfdig
                  let lr_retorno.pesnom    = g_a_cliente[1].pesnom
                  let lr_retorno.pestip    = g_a_cliente[1].pestip
                  let lr_retorno.pesnum    = g_a_cliente[1].pesnum
                  call cta00m24(lr_retorno.cgccpf    ,
                                lr_retorno.cgcord    ,
                                lr_retorno.cgccpfdig ,
                                lr_retorno.pesnom    ,
                                lr_retorno.pestip    )
                  returning lr_retorno.psscntcod
                  if lr_retorno.psscntcod is not null then
                     exit for
                  else
                     let lr_retorno.erro = 1
                     exit for
                  end if
               end if
         end for
         if lr_aux.aux_qtd = 0 or
            lr_aux.aux_qtd is null then
              let lr_retorno.erro = 3
         end if
  end if
   return  lr_retorno.cgccpf    ,
           lr_retorno.cgcord    ,
           lr_retorno.cgccpfdig ,
           lr_retorno.pesnom    ,
           lr_retorno.pestip    ,
           lr_retorno.psscntcod ,
           lr_retorno.pesnum    ,
           lr_retorno.erro
end function

#------------------------------------------------------------------------------
function cta00m23_formata_cgccpf(l_param)
#------------------------------------------------------------------------------
define l_param record
   cgccpfnum like gsakpes.cgccpfnum    ,
   cgcord    like gsakpes.cgcord       ,
   cgccpfdig like gsakpes.cgccpfdig
end record
define l_cgccpf char(12)
define l_format char(20)
    let l_cgccpf = l_param.cgccpfnum using '&&&&&&<<<<<<'
    let l_cgccpf = l_cgccpf[4,6],".",l_cgccpf[7,9],".",l_cgccpf[10,12]
    if l_param.cgcord is null or
       l_param.cgcord = 0     then
          let l_format =  l_cgccpf clipped ,"-", l_param.cgccpfdig using '&&'
    else
          let l_format =  l_cgccpf clipped ,"/", l_param.cgcord using '&&&&' ,"-", l_param.cgccpfdig using '&&'
    end if
    return l_format
end function












































































































































































































































































































































































