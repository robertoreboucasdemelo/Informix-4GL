#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta00m24.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Espelho dos Documentos                                     #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 20/01/2010                                                #
#----------------------------------------------------------------------------#


database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"
globals "/homedsa/projetos/geral/globals/sg_glob3.4gl"
globals "/homedsa/projetos/geral/globals/figrc072.4gl"


define a_cta00m24 array[500] of record
       psscntcod   integer   ,
       viginc      date      ,
       vigfnl      date      ,
       sitdoc      char(30)
end record

define m_prep_cta00m24 smallint

#------------------------------------------------------------------------------
function cta00m24_prepare()
#------------------------------------------------------------------------------

  define l_sql char(500)
  let l_sql = " select cpodes "       ,
              " from iddkdominio  "   ,
              " where cpocod = ? "    ,
              " and   cponom = 'sitprod' "
  prepare pcta00m24001 from l_sql
  declare ccta00m24001 cursor for pcta00m24001
  let m_prep_cta00m24 = true

end function

#------------------------------------------------------------------------------
function cta00m24_cria_temp()
#------------------------------------------------------------------------------
 call cta00m24_drop_temp()
 whenever error continue
      create temp table cta00m24_temp(psscntcod    char(110)    ,
                                      situacao     char(30)     ,
                                      viginc       date         ,
                                      vigfnl       date          ) with no log
  whenever error stop
      if sqlca.sqlcode <> 0  then
	 if sqlca.sqlcode = -310 or
	    sqlca.sqlcode = -958 then
	        call cta00m24_drop_temp()
	  end if
	 return false
     end if
     return true
end function
#------------------------------------------------------------------------------
function cta00m24_drop_temp()
#------------------------------------------------------------------------------
    whenever error continue
        drop table cta00m24_temp
    whenever error stop
    return
end function
#--------------------------------------------
function cta00m24_prep_temp()
#--------------------------------------------
    define l_sql char(500)
    let l_sql = "select * from " ,
                "cta00m24_temp " ,
                "order by 1    "
    prepare pcta00m24002 from l_sql
    declare ccta00m24002 cursor for pcta00m24002
    let l_sql = "select count(*) from " ,
                "cta00m24_temp "
    prepare pcta00m24003 from l_sql
    declare ccta00m24003 cursor for pcta00m24003
    let l_sql = 'insert into cta00m24_temp'
	     , ' values(?,?,?,?)'
    prepare p_insert from l_sql
end function

#------------------------------------
function cta00m24(lr_param)
#------------------------------------

define lr_param record
       cgccpfnum like gsakpes.cgccpfnum    ,
       cgcord    like gsakpes.cgcord       ,
       cgccpfdig like gsakpes.cgccpfdig    ,
       pesnom    like gsakpes.pesnom       ,
       pestip    char(1)
end record

define lr_retorno record
       psscntcod integer  ,
       erro      smallint ,
       qtd       integer
end record

define lr_cta00m24 record
       psscntcod   integer  ,
       sitdoc      char(30) ,
       viginc      date     ,
       vigfnl      date
end record

define l_index integer

initialize lr_retorno.* to null

let lr_retorno.erro = 0
let l_index = 0

if not cta00m24_cria_temp() then
    let lr_retorno.erro = 1
    error  "Erro na Criacao da Tabela Temporaria!"
end if

for     l_index  =  1  to  500
        initialize  a_cta00m24[l_index].* to  null
end  for

    if lr_retorno.erro = 0  then
        let l_index = 0
        if m_prep_cta00m24 is null or
           m_prep_cta00m24 <> true then
           call cta00m24_prepare()
        end if
        call cta00m24_prep_temp()
        message " Aguarde, pesquisando..." attribute (reverse)
        # Recupero o Contrato
        call cta00m24_rec_contrato(lr_param.cgccpfnum ,
                                   lr_param.cgcord    ,
                                   lr_param.cgccpfdig ,
                                   lr_param.pestip    )
        open ccta00m24003
        whenever error continue
        fetch ccta00m24003 into lr_retorno.qtd
        whenever error stop
        if lr_retorno.qtd = 0 or
           lr_retorno.qtd is null then
             error "Nenhum Contrato Encontrado!"
        end if
        close ccta00m24003
        if lr_retorno.qtd > 0 then
            open ccta00m24002
            foreach ccta00m24002 into lr_cta00m24.*
                let l_index = l_index + 1
                let a_cta00m24[l_index].psscntcod = lr_cta00m24.psscntcod
                let a_cta00m24[l_index].sitdoc    = lr_cta00m24.sitdoc
                let a_cta00m24[l_index].viginc    = lr_cta00m24.viginc
                let a_cta00m24[l_index].vigfnl    = lr_cta00m24.vigfnl
            end foreach
            if l_index = 1 then
               let lr_retorno.psscntcod = a_cta00m24[l_index].psscntcod
               call cta00m24_carrega_global(a_cta00m24[l_index].sitdoc ,
                                            a_cta00m24[l_index].viginc ,
                                            a_cta00m24[l_index].vigfnl )
            else
                message " "
                 open window cta00m24 at 11,09 with form "cta00m24"
                 attribute(border, form line first, message line last - 1)
                 message "              (F8)Seleciona (F17)Abandona"
                 call set_count(l_index)
                 display array a_cta00m24 to s_cta00m24.*
                 on key (interrupt)
                     exit display
                 on key(f8)
                     let l_index  = arr_curr()
                     let lr_retorno.psscntcod = a_cta00m24[l_index].psscntcod
                     call cta00m24_carrega_global(a_cta00m24[l_index].sitdoc ,
                                                  a_cta00m24[l_index].viginc ,
                                                  a_cta00m24[l_index].vigfnl )
                     exit display
                 end display
                 close window cta00m24
            end if
        end if
    end if
    return lr_retorno.psscntcod
end function

#------------------------------------------------------------------------------
function cta00m24_rec_contrato(lr_param)
#------------------------------------------------------------------------------
define lr_param record
       cgccpfnum like gsakpes.cgccpfnum ,
       cgcord    like gsakpes.cgcord    ,
       cgccpfdig like gsakpes.cgccpfdig ,
       pestip    char(1)
end record
define lr_retorno record
       prod       smallint ,
       situacao   char(30) ,
       documento  char(110),
       resultado  smallint
end record
define l_qtd integer
define l_array integer
initialize lr_retorno.* to null
let lr_retorno.prod = 25 # Produto PSS
let l_qtd           = null
let l_array         = null
       call osgtf550_pesquisa_negocios_cpfcnpj(lr_param.cgccpfnum,
                                               lr_param.cgcord   ,
                                               lr_param.cgccpfdig,
                                               lr_param.pestip   )
       returning lr_retorno.resultado, l_qtd
       if l_qtd is not null and
          l_qtd > 0         then
           for l_array = 1 to l_qtd
              if g_a_gsakdocngcseg[l_array].unfprdcod = lr_retorno.prod then
                    # Formata Documento
                    call cta00m24_formata_doc(g_a_gsakdocngcseg[l_array].doc1  ,
                                              g_a_gsakdocngcseg[l_array].doc2  ,
                                              g_a_gsakdocngcseg[l_array].doc3  ,
                                              g_a_gsakdocngcseg[l_array].doc4  ,
                                              g_a_gsakdocngcseg[l_array].doc5  ,
                                              g_a_gsakdocngcseg[l_array].doc6  ,
                                              g_a_gsakdocngcseg[l_array].doc7  ,
                                              g_a_gsakdocngcseg[l_array].doc8  ,
                                              g_a_gsakdocngcseg[l_array].doc9  ,
                                              g_a_gsakdocngcseg[l_array].doc10 )
                    returning lr_retorno.documento
                    # Recupera a situacao do documento
                    open ccta00m24001 using g_a_gsakdocngcseg[l_array].docsitcod
                    whenever error continue
                    fetch ccta00m24001  into lr_retorno.situacao
                    close ccta00m24001
                    whenever error stop
                    case g_a_gsakdocngcseg[l_array].docsitcod
                       when 1
                         let lr_retorno.situacao = lr_retorno.situacao[1,5]
                       when 2
                         let lr_retorno.situacao = lr_retorno.situacao[1,9]
                    end case
                    if g_a_gsakdocngcseg[l_array].docsitcod = 0 then
                       let lr_retorno.situacao = "VENCIDO"
                    end if
                    if sqlca.sqlcode <> 0  then
                       error "Erro ao recuperar a situacao do documento"
                    end if
                    # Verifica se o documento e vigente
                    if g_a_gsakdocngcseg[l_array].viginc  >= today and
                       g_a_gsakdocngcseg[l_array].vigfnl  <= today then
                       let lr_retorno.situacao = "VENCIDO"
                    end if
                    whenever error continue
                    execute p_insert using  lr_retorno.documento
                                           ,lr_retorno.situacao
                                           ,g_a_gsakdocngcseg[l_array].viginc
                                           ,g_a_gsakdocngcseg[l_array].vigfnl
                    whenever error stop
              end if
          end for
       end if
    return
end function

#------------------------------------------------------------------------------
function cta00m24_rec_dados(lr_param)
#------------------------------------------------------------------------------
define lr_param record
       cgccpfnum like gsakpes.cgccpfnum   ,
       cgcord    like gsakpes.cgcord      ,
       cgccpfdig like gsakpes.cgccpfdig   ,
       pestip    char(1)                  ,
       psscntcod like kspmcntrsm.psscntcod
end record
define lr_retorno record
       prod       smallint ,
       situacao   char(30) ,
       documento  char(110),
       resultado  smallint
end record
define l_qtd integer
define l_array integer
initialize lr_retorno.* to null
let lr_retorno.prod = 25 # Produto PSS
let l_qtd           = null
let l_array         = null

       if m_prep_cta00m24 is null or
          m_prep_cta00m24 <> true then
          call cta00m24_prepare()
       end if
       call osgtf550_pesquisa_negocios_cpfcnpj(lr_param.cgccpfnum,
                                               lr_param.cgcord   ,
                                               lr_param.cgccpfdig,
                                               lr_param.pestip   )
       returning lr_retorno.resultado, l_qtd
       if l_qtd is not null and
          l_qtd > 0         then
           for l_array = 1 to l_qtd
              if g_a_gsakdocngcseg[l_array].unfprdcod = lr_retorno.prod then
                    # Formata Documento
                    call cta00m24_formata_doc(g_a_gsakdocngcseg[l_array].doc1  ,
                                              g_a_gsakdocngcseg[l_array].doc2  ,
                                              g_a_gsakdocngcseg[l_array].doc3  ,
                                              g_a_gsakdocngcseg[l_array].doc4  ,
                                              g_a_gsakdocngcseg[l_array].doc5  ,
                                              g_a_gsakdocngcseg[l_array].doc6  ,
                                              g_a_gsakdocngcseg[l_array].doc7  ,
                                              g_a_gsakdocngcseg[l_array].doc8  ,
                                              g_a_gsakdocngcseg[l_array].doc9  ,
                                              g_a_gsakdocngcseg[l_array].doc10 )
                    returning lr_retorno.documento
                    if lr_param.psscntcod = lr_retorno.documento then
                           # Recupera a situacao do documento
                           open ccta00m24001 using g_a_gsakdocngcseg[l_array].docsitcod
                           whenever error continue
                           fetch ccta00m24001  into lr_retorno.situacao
                           close ccta00m24001
                           whenever error stop
                           case g_a_gsakdocngcseg[l_array].docsitcod
                              when 1
                                let lr_retorno.situacao = lr_retorno.situacao[1,5]
                              when 2
                                let lr_retorno.situacao = lr_retorno.situacao[1,9]
                           end case
                           if g_a_gsakdocngcseg[l_array].docsitcod = 0 then
                              let lr_retorno.situacao = "VENCIDO"
                           end if
                           if sqlca.sqlcode <> 0  then
                              error "Erro ao recuperar a situacao do documento"
                           end if
                           # Verifica se o documento e vigente
                           if g_a_gsakdocngcseg[l_array].viginc  >= today and
                              g_a_gsakdocngcseg[l_array].vigfnl  <= today then
                              let lr_retorno.situacao = "VENCIDO"
                           end if
                           call cta00m24_carrega_global(lr_retorno.situacao               ,
                                                        g_a_gsakdocngcseg[l_array].viginc ,
                                                        g_a_gsakdocngcseg[l_array].vigfnl )
                   end if
              end if
          end for
       end if
    return
end function

#------------------------------------------------------------------------------
function cta00m24_carrega_global(lr_param)
#------------------------------------------------------------------------------

define lr_param record
  sitdoc      char(30)  ,
  viginc      date      ,
  vigfnl      date
end record

   let g_pss.situacao = lr_param.sitdoc
   let g_pss.viginc   = lr_param.viginc
   let g_pss.vigfnl   = lr_param.vigfnl

end function

#---------------------------------------------------------------------
function cta00m24_formata_doc(lr_param)
#---------------------------------------------------------------------
define lr_param record
   doc1    char(10)
  ,doc2    char(10)
  ,doc3    char(10)
  ,doc4    char(10)
  ,doc5    char(10)
  ,doc6    char(10)
  ,doc7    char(10)
  ,doc8    char(10)
  ,doc9    char(10)
  ,doc10   char(10)
end record
define lr_retorno record
       documento char(110)
end record
initialize lr_retorno.* to null
  if lr_param.doc1 is not null then
      let lr_retorno.documento = lr_param.doc1 clipped
  end if
  if lr_param.doc2 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped, "." , lr_param.doc2 clipped
  end if
  if lr_param.doc3 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped, "." , lr_param.doc3 clipped
  end if
  if lr_param.doc4 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc4 clipped
  end if
  if lr_param.doc5 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc5 clipped
  end if
  if lr_param.doc6 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc6 clipped
  end if
  if lr_param.doc7 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc7 clipped
  end if
  if lr_param.doc8 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc8 clipped
  end if
  if lr_param.doc9 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc9 clipped
  end if
  if lr_param.doc10 is not null then
      let lr_retorno.documento = lr_retorno.documento clipped ,"." , lr_param.doc10 clipped
  end if
return lr_retorno.documento
end function
