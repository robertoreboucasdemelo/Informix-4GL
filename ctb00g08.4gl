#------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                        #
#........................................................................#
# Sistema        : Teleatendimento/Porto Socorro                         #
# Modulo         : ctb00g08                                              #
# Analista.Resp  : Carlos Zyon                                           #
# PSI            : 188603                                                #
# Objetivo       : Qualificar os seguros do veiculo/socorrista           #
#........................................................................#
# Desenvolvimento: Adriana Schneider - Fabrica de Software  -Meta        #
# Liberacao      : 07/04/2005                                            #
#........................................................................#
#                    * * * Alteracoes * * *                              #
#                                                                        #
#    Data      Autor Fabrica   Origem  Alteracao                         #
#  ----------  -------------  -------- ----------------------------------#
#------------------------------------------------------------------------#
database porto

define m_prep smallint

##------------------------------------##
function ctb00g08_prep()
##------------------------------------##
define l_sql char(1000)

let l_sql = " select cgccpfnum,cgccpfdig ",
            " from datksrr               ",
            " where srrcoddig = ?        "

prepare pctb00g08001 from l_sql
whenever error continue
declare cctb00g08001 cursor for pctb00g08001
whenever error stop
if sqlca.sqlcode <> 0 then
   error "Erro cctb00g08001:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
   sleep 3
   error "ctb00g08_prep"
   sleep 3
   error ""
   return 1
end if

let l_sql = " select vcllicnum, vclchsfnl, socvcltip      ",
            " from   datkveiculo    ",
            " where  socvclcod =  ? "

prepare pctb00g08002 from l_sql
whenever error continue
declare cctb00g08002 cursor for pctb00g08002
whenever error stop
if sqlca.sqlcode <> 0 then
   error "Erro cctb00g08002:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
   sleep 3
   error "ctb00g08_prep"
   sleep 3
   error ""
   return 1
end if

let l_sql = " select caddat,cadhor,lclltt,lcllgt  ",
            " from  datmmdtmvt                       ",
            " where atdsrvnum    = ?  and ",
            "       atdsrvano    = ?  and ",
            "       mdtmvtstt    = 2  and ",## Apenas Status 2=Processado OK
            "       mdtmvttipcod = 2  and ",## Apenas Tipo de Movimento = Botao
            "       mdtbotprgseq = 2      " ## Apenas QRU-INI
prepare pctb00g08003 from l_sql
whenever error continue
declare cctb00g08003 cursor for pctb00g08003
whenever error stop
if sqlca.sqlcode <> 0 then
   error "Erro cctb00g08003:",sqlca.sqlcode,"/",sqlca.sqlerrd[2]
   sleep 3
   error "ctb00g08_prep"
   sleep 3
   error ""
   return 1
end if

let m_prep = true
display "Seguro", "	",
        "Codigo do socorrista", "	",
        "Codigo do veiculo", "	",
        "Codigo do Prestador", "	",
        "Nome do Prestador", "	",
        "Data para vigencia", "	",
        "Numero do CPF", "	",
        "Digito do CPF", "	",
        "Codigo erro func externas", "	",
        "Mensagem erro func externas", "	",
        "Valor IS Morte Natura", "	",
        "Valor IS Inval Acidental", "	",
        "Valor IS Inval Doenca", "	",
        "Valor IS Morte Acidental", "	",
        "Placa do veiculo", "	",
        "Tipo do veiculo", "	",
        "Valor da cobertura DM", "	",
        "Valor da cobertura DP", "	",
        "Codigo erro", "	",
        "Mensagem erro", "	",
        "Qualificado", "	"

return 0

end function

##------------------------------------##
function ctb00g08_qualifseg(lr_param)
##------------------------------------##
define lr_param record
       srrcoddig   like datksrr.srrcoddig,     ## Codigo do socorrista
       socvclcod   like datkveiculo.socvclcod, ## Codigo do veiculo
       pstcoddig   like dpaksocor.pstcoddig,   ## Codigo do Prestodor
       nomgrr      like dpaksocor.nomgrr,      ## Nome do Prestodor
       datavig     date                        ## Data para vigencia dos seguros
end record

define l_ret  record
       coderro     integer,  ## Codigo erro retorno / 0=Ok <>0=Error
       msgerro     char(50), ## Mensagem erro retorno
       qualificado char(01)  ## Sim ou Nao
end record

define l_trab record
    cgccpfnum   like datksrr.cgccpfnum,     ## CPF do socorrista
    cgccpfdig   like datksrr.cgccpfdig,     ## Digito do CPF do socorrista
    coderro     integer,                    ## Codigo erro func externas
    msgerro     char(50),                   ## Mensagem erro func externas
    valorbas    dec(17,2),                  ## Valor IS Morte Natural
    valoripd    dec(17,2),                  ## Valor IS Inval Acidental
    valoripa    dec(17,2),                  ## Valor IS Inval Doenca
    valormap    dec(17,2),                  ## Valor IS Morte Acidental
    vcllicnum   like datkveiculo.vcllicnum, ## Placa do veiculo
    vclchsfnl   like abbmveic.vclchsfnl,
    valordm     like abbmcobertura.imsvlr,  ## Valor da cobertura DM
    valordp     like abbmcobertura.imsvlr,  ## Valor da cobertura DP
    valorinv    like abbmapp.imsinvvlr,
    valormor    like abbmapp.imsmorvlr,   
    socvcltip   like datkveiculo.socvcltip,
    rcostt      smallint     
end record

define l_retorno smallint ,
       l_hour datetime hour to minute

## Inicializa variaveis
initialize l_trab.*  to null
let l_ret.coderro     = 0
let l_ret.msgerro     = "Irregular / Irregular"
let l_ret.qualificado = "N"

if m_prep is null or
   m_prep <> true then
   let l_retorno = ctb00g08_prep()

   if l_retorno <> 0 then
      return  1,0,""
   end if
end if


## Recupera o CPF do socorrista
open cctb00g08001 using lr_param.srrcoddig
whenever error continue
fetch cctb00g08001 into l_trab.cgccpfnum,
                        l_trab.cgccpfdig
whenever error stop
if sqlca.sqlcode <> 0 then
   if sqlca.sqlcode <> 100 then
      let l_ret.coderro = sqlca.sqlcode
      let l_ret.msgerro = "Erro ao selecionar CPF Socorrista datksrr (ctb00g08): ",sqlca.sqlerrd[2]
   end if
display "Seguro", "	",
        lr_param.srrcoddig, "	",
        lr_param.socvclcod, "	",
        lr_param.pstcoddig, "	",
        lr_param.nomgrr, "	",
        lr_param.datavig, "	",
        l_trab.cgccpfnum, "	",
        l_trab.cgccpfdig, "	",
        l_trab.coderro, "	",
        l_trab.msgerro, "	",
        l_trab.valorbas, "	",
        l_trab.valoripd, "	",
        l_trab.valoripa, "	",
        l_trab.valormap, "	",
        l_trab.vcllicnum, "	",
        l_trab.valordm, "	",
        l_trab.valordp, "	",
        l_ret.coderro, "	",
        l_ret.msgerro, "	",
        l_ret.qualificado, "	"

   return l_ret.*
end if

## Recupera os valores de seguro de vida
   call fvdgc308(l_trab.cgccpfnum,l_trab.cgccpfdig,lr_param.datavig)
               returning l_trab.coderro,
                         l_trab.msgerro,
                         l_trab.valorbas,
                         l_trab.valoripd,
                         l_trab.valoripa,
                         l_trab.valormap


## Recupera a placa do veiculo
   open cctb00g08002 using lr_param.socvclcod
   whenever error continue
   fetch cctb00g08002 into l_trab.vcllicnum, l_trab.vclchsfnl, l_trab.socvcltip 

   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> 100 then
         let l_ret.coderro = sqlca.sqlcode
         let l_ret.msgerro = "Erro ao selecionar datkveiculo(ctb00g08): ",sqlca.sqlerrd[2]
      end if
display "Seguro", "	",
        lr_param.srrcoddig, "	",
        lr_param.socvclcod, "	",
        lr_param.pstcoddig, "	",
        lr_param.nomgrr, "	",
        lr_param.datavig, "	",
        l_trab.cgccpfnum, "	",
        l_trab.cgccpfdig, "	",
        l_trab.coderro, "	",
        l_trab.msgerro, "	",
        l_trab.valorbas, "	",
        l_trab.valoripd, "	",
        l_trab.valoripa, "	",
        l_trab.valormap, "	",
        l_trab.vcllicnum, "	",
        l_trab.valordm, "	",
        l_trab.valordp, "	",
        l_ret.coderro, "	",
        l_ret.msgerro, "	",
        l_ret.qualificado, "	"

      return l_ret.*
   end if

display "Seguro", "	",
        lr_param.srrcoddig, "	",
        lr_param.socvclcod, "	",
        lr_param.pstcoddig, "	",
        lr_param.nomgrr, "	",
        lr_param.datavig, "	",
        l_trab.cgccpfnum, "	",
        l_trab.cgccpfdig, "	",
        l_trab.coderro, "	",
        l_trab.msgerro, "	",
        l_trab.valorbas, "	",
        l_trab.valoripd, "	",
        l_trab.valoripa, "	",
        l_trab.valormap, "	",
        l_trab.vcllicnum, "	",
        l_trab.valordm, "	",
        l_trab.valordp, "	",
        l_ret.coderro, "	",
        l_ret.msgerro, "	",
        l_ret.qualificado, "	"

   return l_ret.*

end function

##------------------------------------##
function ctb00g08_qualifsrr(lr_param)
##------------------------------------##
define lr_param record
       srrcoddig   like datksrr.srrcoddig, ## Codigo do veiculo
       socvclcod   like datkveiculo.socvclcod, ## Codigo do veiculo
       pstcoddig   like dpaksocor.pstcoddig,   ## Codigo do Prestodor
       nomgrr      like dpaksocor.nomgrr,      ## Nome do Prestodor
       datavig     date                        ## Data para vigencia dos seguros
end record

define l_ret  record
       coderro     integer,  ## Codigo erro retorno / 0=Ok <>0=Error
       msgerro     char(50), ## Mensagem erro retorno
       qualificado char(01)  ## Sim ou Nao
end record

define l_trab record
    cgccpfnum   like datksrr.cgccpfnum,     ## CPF do socorrista
    cgccpfdig   like datksrr.cgccpfdig,     ## Digito do CPF do socorrista
    coderro     integer,                    ## Codigo erro func externas
    msgerro     char(50),                   ## Mensagem erro func externas
    valorbas    dec(17,2),                  ## Valor IS Morte Natural
    valoripd    dec(17,2),                  ## Valor IS Inval Acidental
    valoripa    dec(17,2),                  ## Valor IS Inval Doenca
    valormap    dec(17,2)                   ## Valor IS Morte Acidental
end record

define lr_seguro record 
       seguro1 smallint,
       seguro2 smallint,
       seguro3 smallint,
       seguro4 smallint,
       seguro5 smallint,
       seguro6 smallint,
       seguro7 smallint
end record

define lr_retvid record
       erro        smallint,
       msg         char(80),   ---> Funeral
       tipo        char(02),   ---> Funeral
       existe_massa smallint,  ---> Funeral
       succod      like  vtamdoc.succod        ,
       empcod      dec(2,0)                    ,  ---> Funeral
       ramcod      smallint                    ,  ---> Funeral
       aplnumdig   like  vtamdoc.aplnumdig     ,
       vdapdtcod   like  vtamseguro.vdapdtcod  ,
       vdapdtdes   like  vgpkprod.vdapdtdes    ,
       prporg      like  vtamdoc.prporg        ,
       prpnumdig   like  vtamdoc.prpnumdig     ,
       emsdat      like  vtamdoc.emsdat        ,
       viginc      like  vtamdoc.viginc        ,
       vigfnl      like  vtamdoc.vigfnl        ,
       prpstt      like  vtamdoc.prpstt        ,
       cpodes      like iddkdominio.cpodes     ,
       segnumdig   like  gsakseg.segnumdig     ,
       segnom      like  gsakseg.segnom        ,
       nscdat      like  gsakseg.nscdat        ,
       segsex      like  gsakseg.segsex        ,
       endlgdtip   like  gsakend.endlgdtip     ,
       endlgd      like  gsakend.endlgd        ,
       endnum      like  gsakend.endnum        ,
       endbrr      like  gsakend.endbrr        ,
       endcid      like  gsakend.endcid        ,
       endufd      like  gsakend.endufd        ,
       endcep      like  gsakend.endcep        ,
       corsuspcp   like  gcakcorr.corsuspcp    ,
       cornom      like  gcakcorr.cornom
end record

define l_retorno smallint

## Inicializa variaveis
initialize l_trab.*  to null
let l_ret.coderro     = 0
let l_ret.msgerro     = ""
let l_ret.qualificado = "N"

if m_prep is null or m_prep <> true then
   let l_retorno = ctb00g08_prep()
   if l_retorno <> 0 then
      return  1,0,""
   end if
end if

## Recupera o CPF do socorrista
open cctb00g08001 using lr_param.srrcoddig
whenever error continue
fetch cctb00g08001 into l_trab.cgccpfnum,
                        l_trab.cgccpfdig
whenever error stop
if sqlca.sqlcode <> 0 then
   if sqlca.sqlcode <> 100 then
      let l_ret.coderro = sqlca.sqlcode
      let l_ret.msgerro = "Erro ao selecionar CPF Socorrista datksrr (ctb00g08): ",sqlca.sqlerrd[2]
   end if
display "Seguro Vida", "	",
        lr_param.srrcoddig, "	",
        lr_param.socvclcod, "	",
        lr_param.pstcoddig, "	",
        lr_param.nomgrr, "	",
        lr_param.datavig, "	",
        l_trab.cgccpfnum, "	",
        l_trab.cgccpfdig, "	",
        l_trab.coderro, "	",
        l_trab.msgerro, "	",
        l_trab.valorbas, "	",
        l_trab.valoripd, "	",
        l_trab.valoripa, "	",
        l_trab.valormap, "	",
        " ", "	", #placa
        " ", "	", #tipo veic
        " ", "	", #valor dm
        " ", "	", #valor dp
        l_ret.coderro, "	",
        l_ret.msgerro, "	",
        l_ret.qualificado, "	"

   return l_ret.*
end if

call ovgea017(0, 0, l_trab.cgccpfnum, 0, l_trab.cgccpfdig, 7)                    
     returning lr_seguro.*
     
     display "ctb00g08 - retorno ovgea017"
     display "lr_seguro.seguro1 :",lr_seguro.seguro1 
     display "lr_seguro.seguro2 :",lr_seguro.seguro2 
     display "lr_seguro.seguro3 :",lr_seguro.seguro3 
     display "lr_seguro.seguro4 :",lr_seguro.seguro4 
     display "lr_seguro.seguro5 :",lr_seguro.seguro5 
     display "lr_seguro.seguro6 :",lr_seguro.seguro6 
     display "lr_seguro.seguro7 :",lr_seguro.seguro7 


if  (lr_seguro.seguro3 is not null and lr_seguro.seguro3 <> 0) or 
    (lr_seguro.seguro4 is not null and lr_seguro.seguro4 <> 0) or 
    (lr_seguro.seguro6 is not null and lr_seguro.seguro6 <> 0) or 
    (lr_seguro.seguro7 is not null and lr_seguro.seguro7 <> 0) then 
    let l_ret.qualificado = "S"
else
    let l_ret.qualificado = "N"
end if

     display "l_ret.qualificado: ", l_ret.qualificado
     display "-----------------------"

return l_ret.*


end function

##------------------------------------##
function ctb00g08_qualifvcl(lr_param)
##------------------------------------##
define lr_param record
       srrcoddig   like datksrr.srrcoddig,
       socvclcod   like datkveiculo.socvclcod, ## Codigo do veiculo
       pstcoddig   like dpaksocor.pstcoddig,   ## Codigo do Prestodor
       nomgrr      like dpaksocor.nomgrr,      ## Nome do Prestodor
       datini      date,                       ## Data inicial para vigencia dos seguros  
       datfim      date                        ## Data final para vigencia dos seguros
end record

define l_ret  record
       coderro     integer,  ## Codigo erro retorno / 0=Ok <>0=Error
       msgerro     char(50), ## Mensagem erro retorno
       qualificado char(01),  ## Sim ou Nao
       socvcltip   like datkveiculo.socvcltip
end record

define l_trab record
    coderro     integer,                    ## Codigo erro func externas
    msgerro     char(50),                   ## Mensagem erro func externas
    vcllicnum   like datkveiculo.vcllicnum, ## Placa do veiculo
    valordm     like abbmcobertura.imsvlr,  ## Valor da cobertura DM
    valordp     like abbmcobertura.imsvlr,  ## Valor da cobertura DP
    socvcltip   like datkveiculo.socvcltip,
    vclchsfnl   like abbmveic.vclchsfnl,
    valorinv    like abbmapp.imsinvvlr,
    valormor    like abbmapp.imsmorvlr,
    rcostt      smallint              
end record

define l_retorno smallint

## Inicializa variaveis
initialize l_trab.*  to null
let l_ret.coderro     = 0
let l_ret.msgerro     = ""
let l_ret.qualificado = "N"

if m_prep is null or m_prep <> true then
   let l_retorno = ctb00g08_prep()
   if l_retorno <> 0 then
      return  1,0,""
   end if
end if

## Recupera a placa do veiculo
   open cctb00g08002 using lr_param.socvclcod
   whenever error continue
   fetch cctb00g08002 into l_trab.vcllicnum, l_trab.vclchsfnl, l_trab.socvcltip

   let l_ret.socvcltip = l_trab.socvcltip

   whenever error stop
   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode <> 100 then
         let l_ret.coderro = sqlca.sqlcode
         let l_ret.msgerro = "Erro ao selecionar datkveiculo(ctb00g08): ",sqlca.sqlerrd[2]
      end if
display "Seguro VCL", "	",
        lr_param.srrcoddig, "	",
        lr_param.socvclcod, "	",
        lr_param.pstcoddig, "	",
        lr_param.nomgrr, "	",
        " ", "	", ##cpf
        " ", "	", ##digito
        l_trab.coderro, "	",
        l_trab.msgerro, "	",
        " ", "	", ##valor is
        " ", "	", ##valor is
        " ", "	", ##valor is
        " ", "	", ##valor is
        l_trab.vcllicnum, "	",
        l_trab.socvcltip, "	",
        l_trab.valordm, "	",
        l_trab.valordp, "	",
        l_ret.coderro, "	",
        l_ret.msgerro, "	",
        l_ret.qualificado, "	"
      return l_ret.*
   end if





## Recupera o valor do seguro auto
   call ctb00g13(l_trab.vcllicnum, l_trab.vclchsfnl, l_trab.socvcltip, lr_param.datini, lr_param.datfim)
        returning l_ret.coderro,
                  l_ret.msgerro,
                  l_ret.qualificado

   if l_trab.coderro <> 0 then
      display "Seguro Veiculo ",lr_param.socvclcod," ", l_trab.msgerro
   end if
   
display "Seguro VCL", "	",
        lr_param.srrcoddig, "	",
        lr_param.socvclcod, "	",
        lr_param.pstcoddig, "	",
        lr_param.nomgrr, "	",
        " ", "	", ##cpf
        " ", "	", ##digito
        l_trab.coderro, "	",
        l_trab.msgerro, "	",
        " ", "	", ##valor is
        " ", "	", ##valor is
        " ", "	", ##valor is
        " ", "	", ##valor is
        l_trab.vcllicnum, "	",
        l_trab.socvcltip, "	",
        l_trab.valordm, "	",
        l_trab.valordp, "	",
        l_trab.valorinv, "	",
        l_trab.valormor, "	",
        l_trab.rcostt, "	",
        l_ret.coderro, "	",
        l_ret.msgerro, "	",
        l_ret.qualificado, "	"

   return l_ret.*

end function
