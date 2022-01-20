#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
#............................................................................#
# Sistema       : Central 24hs                                               #
# Modulo        : cta01m64.4gl                                               #
# Analista Resp : Roberto Reboucas                                           #
#                 Localiza Cobertura Provisoria e Vistoria Previa por Nome   #
#............................................................................#
# Desenvolvimento: Roberto Reboucas                                          #
# Liberacao      : 03/06/2007                                                #
#............................................................................#

database porto


#---------------------------------------------------------------------------
function cta01m64_seleciona_vistoria()
#---------------------------------------------------------------------------
define l_comando char(200)
  let l_comando = " select vstnumdig    ,  ",
                  "        vstdat       ,  ",
                  "        vstcpodomdes ,  ",
                  "        segnom          ",
                  " from fvpic012_vistoria ",
                  " order by segnom,       ",
                  "          vstdat        "
  prepare pcta01m64001 from l_comando
  declare ccta01m64001 cursor for pcta01m64001
  return
end function

#---------------------------------------------------------------------------
function cta01m64_seleciona_cobertura()
#---------------------------------------------------------------------------
define l_comando char(200)
  let l_comando = " select cbpnum    ,      ",
                  "        soldat    ,      ",
                  "        vststtdes ,      ",
                  "        segnom           ",
                  " from fvpic012_cobertura ",
                  " order by segnom,        ",
                  "          soldat         "
  prepare pcta01m64002 from l_comando
  declare ccta01m64002 cursor for pcta01m64002
  return
end function

#---------------------------------------------------------------------------
function cta01m64(lr_param)
#---------------------------------------------------------------------------

define lr_param record
    documento char(1)
end record

define dr_cta01m64 record
   pesnom char(50) ,
   doc    char(10) ,
   obs    char(30)
end record

define lr_retorno record
    erro    smallint ,
    docnum  integer
end record

initialize lr_retorno.* ,
           dr_cta01m64.* to null

   open window cta01m64 at 05,02 with form "cta01m64"
                        attribute(form line 1)
   input by name dr_cta01m64.pesnom without defaults


   before field pesnom
      display by name dr_cta01m64.pesnom  attribute (reverse)
      let dr_cta01m64.obs = "(F8)Seleciona (F17)Abandona "
      display by name dr_cta01m64.obs
      case lr_param.documento
        when "V"
            let  dr_cta01m64.doc = "Vistoria"
        when "C"
            let  dr_cta01m64.doc = "Cobertura"
      end case
      display by name dr_cta01m64.doc
   after field pesnom
      display by name dr_cta01m64.pesnom
      if  dr_cta01m64.pesnom is null then
          error 'Nome do Cliente deve ser Informado!'
          next field pesnom
      end if
      if (length (dr_cta01m64.pesnom))  < 10  then
          error " Complemente o Nome do Segurado (minimo 10 caracteres)!"
          next field pesnom
      end if
      call cta01m64_carrega_array(lr_param.documento,
                                  dr_cta01m64.pesnom)
      returning lr_retorno.erro,
                lr_retorno.docnum
      if lr_retorno.erro <> 0 then
         next field pesnom
      end if
    on key (interrupt)
      exit input
   end input
   close window cta01m64
   return lr_retorno.docnum
end function

#---------------------------------------------------------------------------
function cta01m64_carrega_array(lr_param)
#---------------------------------------------------------------------------

define lr_param record
   documento char(1) ,
   pesnom    char(50)
end record

define a_cta01m64 array[200] of record
   seta    char(1)       ,
   docnum  char(9)       ,
   segnom  char(50)      ,
   datsol  date
end record
define a_aux array[200] of record
  situacao char(50)
end record

define lr_retorno record
    erro     smallint      ,
    docnum   decimal(9,0)  ,
    sit      char(50)      ,
    situacao char(50)
end record
define arr_aux integer
for  arr_aux  =  1  to  200
   initialize  a_cta01m64[arr_aux].* to  null
   initialize  a_aux[arr_aux].*      to  null
end  for

initialize lr_retorno.* to null
   let arr_aux         = 1
   let lr_retorno.erro = 0
   if lr_param.documento = "V" then
      let lr_retorno.erro = fvpic012_rec_vistoria_nome(lr_param.pesnom)
      let lr_retorno.sit = "Situacao da Vistoria:"
      if lr_retorno.erro = 0 then
        call cta01m64_seleciona_vistoria()
        open ccta01m64001
        foreach ccta01m64001 into a_cta01m64[arr_aux].docnum ,
                                  a_cta01m64[arr_aux].datsol ,
                                  a_aux[arr_aux].situacao    ,
                                  a_cta01m64[arr_aux].segnom
            let arr_aux  = arr_aux + 1
        end foreach
      end if
   end if
   if lr_param.documento = "C" then
      let lr_retorno.erro = fvpic012_rec_cobertura_nome(lr_param.pesnom)
      let lr_retorno.sit = "Situacao da Cobertura:"
      if lr_retorno.erro = 0 then
        call cta01m64_seleciona_cobertura()
        open ccta01m64002
        foreach ccta01m64002 into a_cta01m64[arr_aux].docnum ,
                                  a_cta01m64[arr_aux].datsol ,
                                  a_aux[arr_aux].situacao    ,
                                  a_cta01m64[arr_aux].segnom
            let a_cta01m64[arr_aux].docnum  =  a_cta01m64[arr_aux].docnum using '&&&&&&&&&'
            let arr_aux  = arr_aux + 1
        end foreach
      end if
   end if
   if arr_aux = 1  then
      error "Segurado nao Encontrado!"
      let lr_retorno.erro = 1
   else
      if arr_aux > 200 then
         error "Existem mais de 200 Segurados Selecionados, " ,
               "Complemente o Nome do Segurado!"
         let lr_retorno.erro = 1
      end if
   end if
   if lr_retorno.erro = 0 then
            options insert   key F40
            options delete   key F35
            options next     key F30
            options previous key F25
            call set_count(arr_aux-1)
            input array a_cta01m64 without defaults from s_cta01m64.*
              before field seta
               let arr_aux  = arr_curr()
               let lr_retorno.situacao = lr_retorno.sit clipped ," ",
                                         a_aux[arr_aux].situacao clipped
               display by name lr_retorno.situacao attribute (reverse)
              after field seta
              if  fgl_lastkey() <> fgl_keyval("up")   and
                  fgl_lastkey() <> fgl_keyval("left") then
                       if a_cta01m64[arr_aux + 1 ].segnom is null then
                             next field seta
                       end if
              end if
              on key (interrupt)
                exit input
              on key (f8)
                 let arr_aux  = arr_curr()
                 let lr_retorno.docnum =  a_cta01m64[arr_aux].docnum
                 exit input
            end input
   end if
   return lr_retorno.erro,
          lr_retorno.docnum
end function


