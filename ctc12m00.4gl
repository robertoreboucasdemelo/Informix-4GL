###############################################################################
# Nome do Modulo: CTC12M00                                              Pedro #
#                                                                             #
# Manutencao no Cadastro da Lista de Empresas                        Jan/1995 #
###############################################################################
#                                                                             #
#                  * * * Alteracoes * * *                                     #
#                                                                             #
# Data        Autor Fabrica  Origem    Alteracao                              #
# ----------  -------------- --------- -------------------------------------- #
# 25/09/2006  Priscila       PSI202290 Remover verificacao nivel de acesso    #
#-----------------------------------------------------------------------------#

database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define wresp char (01)

#---------------------------------------------
# rotina principal
#----------------------------------------------

define r_ctc12m00       record
       emplstcod        like dpaklista.emplstcod   ,
       empnom           like dpaklista.empnom      ,
       endlgd           like dpaklista.endlgd      ,
       endbrr           like dpaklista.endbrr      ,
       endcid           like dpaklista.endcid      ,
       endufd           like dpaklista.endufd      ,
       endcep           like dpaklista.endcep      ,
       endcepcmp        like dpaklista.endcepcmp   ,
       dddcod           like dpaklista.dddcod      ,
       teltxt           like dpaklista.teltxt      ,
       horsegsexinc     like dpaklista.horsegsexinc,
       horsegsexfnl     like dpaklista.horsegsexfnl,
       horsabinc        like dpaklista.horsabinc   ,
       horsabfnl        like dpaklista.horsabfnl   ,
       hordominc        like dpaklista.hordominc   ,
       hordomfnl        like dpaklista.hordomfnl   ,
       hs24flg          like dpaklista.hs24flg
end record

define seq              dec(6,0),
       seq_dig          dec(6,0),
       operacao_aux     char(1)

define k_ctc12m00       record
       emplstcod        like dpaklista.emplstcod
end record

define ws_resp          dec(2,0)

#----------------------------------------------
function ctc12m00()
#----------------------------------------------
# Menu do modulo
#---------------

    #PSI 202290
    #if not get_niv_mod(g_issk.prgsgl, "ctc12m00") then
    #   error "Modulo sem nivel de consulta e atualizacao!"
    #   return
    #end if

    open window w_ctc12m00 at 4,2 with form "ctc12m00"

    let int_flag = false

    initialize  r_ctc12m00.*    to   null
    initialize  k_ctc12m00.*    to   null

    menu "LISTA_OESP"
       before menu
          hide option all
          #PSI 202290
          #if  g_issk.acsnivcod >= g_issk.acsnivcns  then
          #      show option "Seleciona", "Proximo", "Anterior",
          #                  "serVicos" , "pesQuisa"
          #end if
          #if  g_issk.acsnivcod >= g_issk.acsnivatl  then
                show option "Seleciona", "Proximo", "Anterior", "Modifica",
                            "Remove"   , "Inclui" , "pesQuisa", "serVicos"
          #end if

          show option "Encerra"

    command key ("S") "Seleciona" "Pesquisa tabela conforme criterios"
                 call seleciona_ctc12m00() returning k_ctc12m00.*
                 message ""
                 if k_ctc12m00.emplstcod is not null then
                    next option "Proximo"
                 else
                    error "Nenhum registro selecionado!"
                    message ""
                    next option "Seleciona"
                 end if

    command key ("P") "Proximo"   "Mostra proximo registro selecionado"
                 message ""
                 if k_ctc12m00.emplstcod is not null then
                    call proximo_ctc12m00(k_ctc12m00.*)
                         returning k_ctc12m00.*
                 else
                    error "Nao ha' mais registro nesta direcao!"
                    next option "Seleciona"
                 end if

    command key ("A") "Anterior" "Mostra registro anterior selecionado"
                 message ""
                 if k_ctc12m00.emplstcod is not null then
                    call anterior_ctc12m00(k_ctc12m00.*)
                         returning k_ctc12m00.*
                 else
                    error "Nao ha' mais registro nesta direcao!"
                    next option "Seleciona"
                 end if

    command key ("M") "Modifica" "Modifica registro corrente selecionado"
                 message ""
                 if k_ctc12m00.emplstcod is not null then
                    call modifica_ctc12m00(k_ctc12m00.*)
                         returning k_ctc12m00.*
                    next option "Seleciona"
                 else
                    error "Nenhum registro selecionado!"
                    next option "Seleciona"
                 end if

    command key ("R") "Remove"  "Remove registro corrente selecionado"
                 message ""
                 if k_ctc12m00.emplstcod is not null then
                    call remove_ctc12m00(k_ctc12m00.*)
                         returning k_ctc12m00.*
                    next option "Seleciona"
                 else
                    error "Nenhum registro selecionado!"
                    next option "Seleciona"
                 end if

    command key ("I") "Inclui"  "Inclui Registro na Tabela"
                 message ""
                 call inclui_ctc12m00()
                 next option "Seleciona"

    command key ("Q") "pesQuisa"      "Pesquisa estabelecimento"
                 message ""
                 call ctc12m01() returning k_ctc12m00.emplstcod
                 next option "Seleciona"

    command key ("V") "serVicos"      "Servicos do estabelecimento"
                 message ""
                 if r_ctc12m00.emplstcod is not null then
                    call ctc13m00(r_ctc12m00.emplstcod, r_ctc12m00.empnom)
                 else
                    error "Nenhum registro selecionado!"
                    next option "Seleciona"
                 end if

    command key (interrupt,E) "Encerra" "Retorna ao menu anterior"
                exit menu
    end menu

    close window w_ctc12m00

end function # ctc12m00

#---------------------------------------
function seleciona_ctc12m00()
#---------------------------------------

    let int_flag = false

    input by name k_ctc12m00.emplstcod without defaults
       before field emplstcod
          display by name k_ctc12m00.emplstcod attribute (reverse)

          if k_ctc12m00.emplstcod is null then
             let k_ctc12m00.emplstcod = 0
          end if

       after  field emplstcod
          display by name k_ctc12m00.emplstcod

       on key (interrupt)
          exit input
    end input

    if int_flag then
       let int_flag = false
       initialize r_ctc12m00.* to null
       error "Operacao cancelada!"
       clear form
       return k_ctc12m00.*
    end if

    if k_ctc12m00.emplstcod  =  0   then

       select min (dpaklista.emplstcod)
       into   k_ctc12m00.emplstcod
       from   dpaklista
       where  dpaklista.emplstcod > 0

       display by name k_ctc12m00.emplstcod
    end if

    call sel_cons_ctc12m00(k_ctc12m00.*) returning r_ctc12m00.*

    if status = 0 then
       display  by  name
                      r_ctc12m00.empnom,
                      r_ctc12m00.endlgd   ,
                      r_ctc12m00.endbrr   ,
                      r_ctc12m00.endcid   ,
                      r_ctc12m00.endufd   ,
                      r_ctc12m00.endcep   ,
                      r_ctc12m00.endcepcmp,
                      r_ctc12m00.dddcod   ,
                      r_ctc12m00.teltxt   ,
                      r_ctc12m00.horsegsexinc,
                      r_ctc12m00.horsegsexfnl,
                      r_ctc12m00.horsabinc,
                      r_ctc12m00.horsabfnl,
                      r_ctc12m00.hordominc,
                      r_ctc12m00.hordomfnl,
                      r_ctc12m00.hs24flg
    else
       error "Registro nao cadastrado!"
       initialize r_ctc12m00.* to null
       initialize k_ctc12m00.* to null
    end if

    return k_ctc12m00.*

end function # seleciona_ctc12m00

#---------------------------------------------------------
  function inclui_ctc12m00()
#---------------------------------------------------------

    clear form

    initialize r_ctc12m00.* to null
    initialize k_ctc12m00.* to null

    call cri_input_ctc12m00("i",k_ctc12m00.*,r_ctc12m00.*)
                                   returning r_ctc12m00.*

    if int_flag  then
       let int_flag = false
       initialize r_ctc12m00.* to null
       error "Operacao cancelada!"
       clear form
       return
    end if

    whenever error continue

    declare c_xgral cursor with hold for
            select  grlinf
            from    igbkgeral
            where   igbkgeral.mducod = "C24"      and
                    igbkgeral.grlchv = "LISTA"
            for update

    foreach c_xgral into k_ctc12m00.emplstcod
        exit foreach
    end foreach

   if k_ctc12m00.emplstcod is null then
      begin work
        insert into igbkgeral (mducod, grlchv, grlinf, atlult)
                       values ("C24", "LISTA", "0", today)

        if sqlca.sqlcode <> 0 then
           error "Erro (", sqlca.sqlcode,") na criacao do IGBKGERAL. ",
                 "AVISE A INFORMATICA!"
           rollback work
           return
        end if
     commit work
     let k_ctc12m00.emplstcod = 0
   end if

   begin work
    declare i_xgral cursor with hold for
            select  grlinf
            from    igbkgeral
            where   igbkgeral.mducod = "C24"  and
                    igbkgeral.grlchv = "LISTA"
            for update

    foreach i_xgral into k_ctc12m00.emplstcod
      let k_ctc12m00.emplstcod = k_ctc12m00.emplstcod + 1
      let seq                  = k_ctc12m00.emplstcod

      call F_FUNDIGIT_DIGITO11(k_ctc12m00.emplstcod) returning seq_dig

      let k_ctc12m00.emplstcod = seq_dig
      let r_ctc12m00.emplstcod = k_ctc12m00.emplstcod

      insert into dpaklista ( emplstcod              ,
                              empnom                 ,
                              endlgd                 ,
                              endbrr                 ,
                              endcid                 ,
                              endufd                 ,
                              endcep                 ,
                              endcepcmp              ,
                              dddcod                 ,
                              teltxt                 ,
                              horsegsexinc           ,
                              horsegsexfnl           ,
                              horsabinc              ,
                              horsabfnl              ,
                              hordominc              ,
                              hordomfnl              ,
                              hs24flg                )
                     values ( r_ctc12m00.emplstcod   ,
                              r_ctc12m00.empnom      ,
                              r_ctc12m00.endlgd      ,
                              r_ctc12m00.endbrr      ,
                              r_ctc12m00.endcid      ,
                              r_ctc12m00.endufd      ,
                              r_ctc12m00.endcep      ,
                              r_ctc12m00.endcepcmp   ,
                              r_ctc12m00.dddcod      ,
                              r_ctc12m00.teltxt      ,
                              r_ctc12m00.horsegsexinc,
                              r_ctc12m00.horsegsexfnl,
                              r_ctc12m00.horsabinc   ,
                              r_ctc12m00.horsabfnl   ,
                              r_ctc12m00.hordominc   ,
                              r_ctc12m00.hordomfnl   ,
                              r_ctc12m00.hs24flg     )

      if sqlca.sqlcode <> 0 then
         error "Erro (", sqlca.sqlcode, ") na inclusao da empresa. ",
               "AVISE A INFORMATICA!"
         rollback work
         return
      end if

      update igbkgeral
           set (grlinf,atlult) =
               (seq   ,today)
           where igbkgeral.mducod = "C24" and
                 igbkgeral.grlchv = "LISTA"

      if sqlca.sqlcode <> 0  then
         error  "Erro (", sqlca.sqlcode, ") na inclusao do registro IGBKGERAL.",
                " AVISE A INFORMATICA!"
         rollback work
         return
      end if

      whenever error stop

      commit work

      exit foreach

    end foreach

    display by name r_ctc12m00.emplstcod attribute (reverse)
    error "Verifique o codigo da empresa e tecle ENTER!"
    prompt "" for char wresp
    error "Inclusao efetuada com sucesso!"
    clear form

    call ctc13m00 (r_ctc12m00.emplstcod, r_ctc12m00.empnom)

end function

#-----------------------------------------------------------
function proximo_ctc12m00(k_ctc12m00)
#-----------------------------------------------------------

    define k_ctc12m00       record
           emplstcod        like dpaklista.emplstcod
    end record

    let int_flag = false

    select min (dpaklista.emplstcod)
    into   r_ctc12m00.emplstcod
    from   dpaklista
    where
           dpaklista.emplstcod > k_ctc12m00.emplstcod

    if r_ctc12m00.emplstcod is not null then
       let k_ctc12m00.emplstcod = r_ctc12m00.emplstcod
    end if

    select
       emplstcod,
       empnom,
       endlgd   ,
       endbrr   ,
       endcid   ,
       endufd   ,
       endcep   ,
       endcepcmp,
       dddcod   ,
       teltxt   ,
       horsegsexinc,
       horsegsexfnl,
       horsabinc,
       horsabfnl,
       hordominc,
       hordomfnl,
       hs24flg
    into   r_ctc12m00.*
    from   dpaklista
    where  dpaklista.emplstcod = r_ctc12m00.emplstcod


    if status = 0 then
       display  by  name r_ctc12m00.*
    else
       error "Nao ha' mais registro neta direcao!"
       initialize r_ctc12m00.* to null
    end if

    return k_ctc12m00.*

end function  #  proximo_ctc12m00

#-----------------------------------------------------------
function anterior_ctc12m00(k_ctc12m00)
#-----------------------------------------------------------

    define k_ctc12m00       record
           emplstcod        like dpaklista.emplstcod
    end record

    let int_flag = false

    select max (dpaklista.emplstcod)
    into   r_ctc12m00.emplstcod
    from   dpaklista
    where
           dpaklista.emplstcod < k_ctc12m00.emplstcod

    if r_ctc12m00.emplstcod is not null then
       let k_ctc12m00.emplstcod = r_ctc12m00.emplstcod
    end if

    select
      emplstcod,
      empnom,
      endlgd   ,
      endbrr   ,
      endcid   ,
      endufd   ,
      endcep   ,
      endcepcmp,
      dddcod   ,
      teltxt   ,
      horsegsexinc,
      horsegsexfnl,
      horsabinc,
      horsabfnl,
      hordominc,
      hordomfnl,
      hs24flg
    into   r_ctc12m00.*
    from   dpaklista
    where  dpaklista.emplstcod = r_ctc12m00.emplstcod

    if status = 0 then
       display  by  name r_ctc12m00.*
    else
       error "Nao ha' mais registro nesta direcao!"
       initialize r_ctc12m00.* to null
    end if

    return k_ctc12m00.*

end function  #  anterior

#-----------------------------------------------------------
function modifica_ctc12m00(k_ctc12m00)
#-----------------------------------------------------------

    define k_ctc12m00       record
           emplstcod        like dpaklista.emplstcod
    end record

    let int_flag = false

    call cri_input_ctc12m00("a",k_ctc12m00.*,r_ctc12m00.*)
                                   returning r_ctc12m00.*

    if int_flag then
       let int_flag = false
       initialize r_ctc12m00.* to null
       error "Operacao cancelada!"
       clear form
       return k_ctc12m00.*
    end if

    begin work
      update dpaklista set
                         empnom        =  r_ctc12m00.empnom,
                         endlgd        =  r_ctc12m00.endlgd   ,
                         endbrr        =  r_ctc12m00.endbrr   ,
                         endcid        =  r_ctc12m00.endcid   ,
                         endufd        =  r_ctc12m00.endufd   ,
                         endcep        =  r_ctc12m00.endcep   ,
                         endcepcmp     =  r_ctc12m00.endcepcmp,
                         dddcod        =  r_ctc12m00.dddcod   ,
                         teltxt        =  r_ctc12m00.teltxt   ,
                         horsegsexinc  =  r_ctc12m00.horsegsexinc,
                         horsegsexfnl  =  r_ctc12m00.horsegsexfnl,
                         horsabinc     =  r_ctc12m00.horsabinc,
                         horsabfnl     =  r_ctc12m00.horsabfnl,
                         hordominc     =  r_ctc12m00.hordominc,
                         hordomfnl     =  r_ctc12m00.hordomfnl,
                         hs24flg       =  r_ctc12m00.hs24flg
                    where
                         dpaklista.emplstcod = k_ctc12m00.emplstcod

    if status <> 0  then
       error  "Erro na alteracao do registro, AVISE A INFORMATICA!"
       rollback work
       initialize r_ctc12m00.*  to null
       initialize k_ctc12m00.*  to null
       return k_ctc12m00.*
    else
       error "Alteracao efetuada com sucesso!"
    end if

    whenever error stop

    commit work

    clear form
    message ""

    return k_ctc12m00.*

end function # modifica_ctc12m00

#-----------------------------------------------------------
function remove_ctc12m00(k_ctc12m00)
#-----------------------------------------------------------

  define k_ctc12m00       record
         emplstcod        like dpaklista.emplstcod
  end record

menu "Confirma exclusao ?"

      command "Nao" "Cancela exclusao do registro"
              clear form
              initialize r_ctc12m00.* to null
              initialize k_ctc12m00.* to null
              error "Exclusao cancelada!"
              exit menu

      command "Sim" "Exclui registro"
              call sel_cons_ctc12m00(k_ctc12m00.*)
                   returning r_ctc12m00.*

              if status = notfound then
                 initialize r_ctc12m00.* to null
                 initialize k_ctc12m00.* to null
	         error "Registro nao localizado!"
                 exit menu
              end if

              let ws_resp = 0
		
              select max (dparservlista.emplstcod)
                into ws_resp
                from dparservlista
               where
                     dparservlista.emplstcod = k_ctc12m00.emplstcod

              if ws_resp <> 0       then
                 error "Empresa nao pode ser removida, existe servico cadastrado!"
                 exit menu
              end if

              delete
              from   dpaklista
              where  dpaklista.emplstcod = k_ctc12m00.emplstcod

              error "Registro excluido!"
              clear form
              exit menu
      end menu

      return k_ctc12m00.*

end function # remove_ctc12m00
	
#-----------------------------------------------------------
function sel_cons_ctc12m00(k_ctc12m00)
#-----------------------------------------------------------

  define k_ctc12m00       record
         emplstcod        like dpaklista.emplstcod
  end record

  select
     emplstcod,
     empnom,
     endlgd   ,
     endbrr   ,
     endcid   ,
     endufd   ,
     endcep   ,
     endcepcmp,
     dddcod   ,
     teltxt   ,
     horsegsexinc,
     horsegsexfnl,
     horsabinc,
     horsabfnl,
     hordominc,
     hordomfnl,
     hs24flg
  into   r_ctc12m00.*
  from   dpaklista
  where  dpaklista.emplstcod = k_ctc12m00.emplstcod

  return r_ctc12m00.*

end function # sel_cons_ctc12m00

#--------------------------------------------------------------
function cri_input_ctc12m00(operacao_aux,k_ctc12m00,r_ctc12m00)
#--------------------------------------------------------------

  define r_ctc12m00       record
         emplstcod        like dpaklista.emplstcod,
         empnom           like dpaklista.empnom   ,
         endlgd           like dpaklista.endlgd   ,
         endbrr           like dpaklista.endbrr   ,
         endcid           like dpaklista.endcid   ,
         endufd           like dpaklista.endufd   ,
         endcep           like dpaklista.endcep   ,
         endcepcmp        like dpaklista.endcepcmp,
         dddcod           like dpaklista.dddcod   ,
         teltxt           like dpaklista.teltxt   ,
         horsegsexinc     like dpaklista.horsegsexinc,
         horsegsexfnl     like dpaklista.horsegsexfnl,
         horsabinc        like dpaklista.horsabinc,
         horsabfnl        like dpaklista.horsabfnl,
         hordominc        like dpaklista.hordominc,
         hordomfnl        like dpaklista.hordomfnl,
         hs24flg          like dpaklista.hs24flg
  end record

  define k_ctc12m00       record
         emplstcod        like dpaklista.emplstcod
  end record

  define w_contador       decimal(6,0)
  define w_retlgd         char(40)
  define operacao_aux     char(1)

  let int_flag = false

  input by name  r_ctc12m00.empnom,
                 r_ctc12m00.endlgd   ,
                 r_ctc12m00.endbrr   ,
                 r_ctc12m00.endcid   ,
                 r_ctc12m00.endufd   ,
                 r_ctc12m00.endcep   ,
                 r_ctc12m00.endcepcmp,
                 r_ctc12m00.dddcod   ,
                 r_ctc12m00.teltxt   ,
                 r_ctc12m00.horsegsexinc,
                 r_ctc12m00.horsegsexfnl,
                 r_ctc12m00.horsabinc,
                 r_ctc12m00.horsabfnl,
                 r_ctc12m00.hordominc,
                 r_ctc12m00.hordomfnl,
                 r_ctc12m00.hs24flg
                 without defaults

  before field   empnom
         display by name r_ctc12m00.empnom attribute (reverse)

  after  field   empnom
         display by name r_ctc12m00.empnom

  before field   endlgd
         display by name r_ctc12m00.endlgd    attribute (reverse)

  after  field   endlgd
         display by name r_ctc12m00.endlgd

  before field   endbrr
         display by name r_ctc12m00.endbrr    attribute (reverse)

  after  field   endbrr
         display by name r_ctc12m00.endbrr

  before field   endcid
         display by name r_ctc12m00.endcid    attribute (reverse)

  after  field   endcid
         display by name r_ctc12m00.endcid

  before field   endufd
         display by name r_ctc12m00.endufd    attribute (reverse)

  after  field   endufd
         display by name r_ctc12m00.endufd

         if fgl_lastkey()  <>  fgl_keyval("up")   and
            fgl_lastkey()  <>  fgl_keyval("left") then
            select  ufdcod
              from  glakest
             where
                    glakest.ufdcod = r_ctc12m00.endufd

            if status = notfound then
               error "Unidade  Federativa nao cadastrada!"
               next field endufd
            end if
         end if

  before field   endcep
         display by name r_ctc12m00.endcep    attribute (reverse)

  after  field   endcep
         display by name r_ctc12m00.endcep

         if fgl_lastkey()    <>     fgl_keyval("up")   and
            fgl_lastkey()    <>     fgl_keyval("left") then

            let w_contador   =      0

            select  count(*)
              into  w_contador
              from  glakcid
              where glakcid.cidcep  =  r_ctc12m00.endcep

            if w_contador           =  0  then
               let w_contador       =  0

               select  count(*)
                 into  w_contador
                 from  glaklgd
                 where glaklgd.lgdcep  =  r_ctc12m00.endcep

               if w_contador =         0  then

                  call  C24GERAL_TRATSTR(r_ctc12m00.endlgd, 40)
                                         returning  w_retlgd

                  error "Cep nao cadastrado - Consulte pelo logradouro!"

                  call  ctn11c02(r_ctc12m00.endufd,r_ctc12m00.endcid,w_retlgd)
                                         returning r_ctc12m00.endcep,
                                                   r_ctc12m00.endcepcmp

                  if r_ctc12m00.endcep is null then
                     error "Ver cep por cidade - Consulte pela cidade"

                     call  ctn11c03(r_ctc12m00.endcid)
                                            returning r_ctc12m00.endcep
                  end if

                  next  field endcep
               end if
            end if
         end if

  before field   endcepcmp
         display by name r_ctc12m00.endcepcmp  attribute (reverse)

  after  field   endcepcmp
         display by name r_ctc12m00.endcepcmp

  before field   dddcod
         display by name r_ctc12m00.dddcod     attribute (reverse)

  after  field   dddcod
         display by name r_ctc12m00.dddcod

  before field   teltxt
         display by name r_ctc12m00.teltxt     attribute (reverse)

  after  field   teltxt
         display by name r_ctc12m00.teltxt

  before field   horsegsexinc
         display by name r_ctc12m00.horsegsexinc attribute (reverse)

  after  field   horsegsexinc
         display by name r_ctc12m00.horsegsexinc

  before field   horsegsexfnl
         display by name r_ctc12m00.horsegsexfnl  attribute (reverse)

  after  field   horsegsexfnl
         display by name r_ctc12m00.horsegsexfnl

  before field   horsabinc
         display by name r_ctc12m00.horsabinc  attribute (reverse)

  after  field   horsabinc
         display by name r_ctc12m00.horsabinc

  before field   horsabfnl
         display by name r_ctc12m00.horsabfnl  attribute (reverse)

  after  field   horsabfnl
         display by name r_ctc12m00.horsabfnl

  before field   hordominc
         display by name r_ctc12m00.hordominc  attribute (reverse)

  after  field   hordominc
         display by name r_ctc12m00.hordominc

  before field   hordomfnl
         display by name r_ctc12m00.hordomfnl  attribute (reverse)

  after  field   hordomfnl
         display by name r_ctc12m00.hordomfnl

  before field   hs24flg
         display by name r_ctc12m00.hs24flg    attribute (reverse)

  after  field   hs24flg
         display by name r_ctc12m00.hs24flg

  on key (interrupt)
     exit input

  end input

  if int_flag  then
     initialize r_ctc12m00.* to null
     return r_ctc12m00.*
  end if

  return r_ctc12m00.*

end function # cri_input_ctc12m00

