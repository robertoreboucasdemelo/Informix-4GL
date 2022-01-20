#############################################################################
# Nome do Modulo: CTS02M03                                            Pedro #
#                                                                   Marcelo #
# Laudo - Remocoes (Previsao de Termino do Servico)                Dez/1994 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
# 28/04/1999  PSI 7547-7   Gilberto     Alteracao do conteudo do campo      #
#                                       ATDFNLFLG (flag finalizacao).       #
#---------------------------------------------------------------------------#
# 03/03/2006  Zeladoria    Priscila     Buscar data e hora do banco de dados#
# 21/10/2010  Alberto Rodrigues         Correcao de ^M                      #
#---------------------------------------------------------------------------#
#############################################################################
globals "/homedsa/projetos/geral/globals/glct.4gl"
 
define m_prep smallint
 
function cts02m03_prepare()
   define l_sql char(300)
   let l_sql = " select agdlimqtd   ",
               " from datksrvtip ",
               " where atdsrvorg = ? "
   prepare pcts02m03001 from l_sql
   declare ccts02m03001 cursor for pcts02m03001
   let m_prep = true


end function

#-----------------------------------------------------------
 function cts02m03(param, k_cts02m03)
#-----------------------------------------------------------

 define param      record
    atdfnlflg      like datmservico.atdfnlflg,
    imdsrvflg      char (01)
 end record

 define k_cts02m03 record
    atdhorpvt      like datmservico.atdhorpvt,
    atddatprg      like datmservico.atddatprg,
    atdhorprg      like datmservico.atdhorprg,
    atdpvtretflg   like datmservico.atdpvtretflg
 end record

 define d_cts02m03 record
    atdhorpvt      like datmservico.atdhorpvt,
    atddatprg      like datmservico.atddatprg,
    atdhorprg      like datmservico.atdhorprg,
    atdpvtretflg   like datmservico.atdpvtretflg
 end record

 define lr_cts32g00 record
    res             smallint,
    msg             char(50),
    atdprvtmp       like datracncid.atdprvtmp
 end record

 define lr_ctd01g00 record
    res             smallint,
    msg             char(50),
    cidsedcod       like datrcidsed.cidsedcod
 end record

 define l_tmpc      char(10)
 define lr_retorno record
        coderro    smallint ,
        mens       char(300),
        agdlimqtd  like datksrvtip.agdlimqtd
 end record
 define l_mens char(300)
 define l_data_limite date


 define prompt_key char (01)

 define l_data            date,
        l_hora2           datetime hour to minute ,
        l_hora3           datetime hour to minute,
        l_erro_atdhorprg  smallint

	let	prompt_key  =  null
	let	l_tmpc  =  null	
	let     l_mens = null

	initialize  d_cts02m03.*   to  null
	initialize  lr_cts32g00.*  to  null
	initialize  lr_ctd01g00.*  to  null
	initialize  lr_retorno.*   to null

 if k_cts02m03.atdpvtretflg  is null   then
    let k_cts02m03.atdpvtretflg = "N"
 end if
 let d_cts02m03.* = k_cts02m03.*
 #----------------------------------------------------------------------
 # Busca limite de agendamento
 #----------------------------------------------------------------------
   call cts02m03_busca_limite()
        returning lr_retorno.*
 ## PSI 232700 - ligia - 12/11/08
 if g_documento.atdsrvnum is null then
    if g_atmacnprtcod is not null and g_atmacnprtcod <> 0 and
       g_cidcod is not null and g_cidcod <> 0 then

       call ctd01g00_obter_cidsedcod(1, g_cidcod)
            returning lr_ctd01g00.*

       if lr_ctd01g00.cidsedcod is not null then

          call cts32g00_dados_cid_ac (1, g_atmacnprtcod, lr_ctd01g00.cidsedcod)
               returning lr_cts32g00.*
          let l_tmpc = lr_cts32g00.atdprvtmp
          #let l_tmpc = l_tmpc using "<<#:##"
          if lr_cts32g00.atdprvtmp is not null then
             let d_cts02m03.atdhorpvt = l_tmpc
             let k_cts02m03.atdhorpvt = l_tmpc
          end if

       end if
    end if
 end if

 let l_erro_atdhorprg = false

 open window cts02m03 at 11,54 with form "cts02m03"
                      attribute(border,form line 1)

 let int_flag = false

 display by name d_cts02m03.*

 input by name d_cts02m03.atdhorpvt,
               d_cts02m03.atdpvtretflg,
               d_cts02m03.atddatprg,
               d_cts02m03.atdhorprg
       without defaults

   before field atdhorpvt
          display by name k_cts02m03.*
          let d_cts02m03.* = k_cts02m03.*
          if param.atdfnlflg = "S"  then
             prompt " (F17)Abandona " for char  prompt_key
             exit input
          end if

          if param.imdsrvflg = "N"  then
             initialize d_cts02m03.atdhorpvt to null
             next field atddatprg
          else
             initialize d_cts02m03.atdhorprg to null
             initialize d_cts02m03.atddatprg to null
          end if

          if lr_cts32g00.atdprvtmp is not null then
             next field atdpvtretflg
          end if

          display by name d_cts02m03.atdhorpvt attribute (reverse)

   after  field atdhorpvt
          display by name d_cts02m03.atdhorpvt

          if d_cts02m03.atdhorpvt is null then
             error " Previsao em horas deve ser informada para servico imediato!"
             next field atdhorpvt
          end if

   before field atdpvtretflg
          display by name d_cts02m03.atdpvtretflg attribute (reverse)

   after  field atdpvtretflg
          display by name d_cts02m03.atdpvtretflg

          if fgl_lastkey() <> fgl_keyval("up")   and
             fgl_lastkey() <> fgl_keyval("left") then
             if d_cts02m03.atdpvtretflg is null   or
                (d_cts02m03.atdpvtretflg <> "S"   and
                 d_cts02m03.atdpvtretflg <> "N")  then
                error " Retorno ao Segurado deve ser (S)im ou (N)ao!"
                next field atdpvtretflg
             end if

             if d_cts02m03.atdhorpvt is not null then
                exit input
             end if
          end if

   before field atddatprg
          display by name d_cts02m03.atddatprg attribute (reverse)

   after  field atddatprg
          display by name d_cts02m03.atddatprg

          if d_cts02m03.atddatprg is null or
             d_cts02m03.atddatprg =  0    then
             error " Data programada deve ser informada para servico programado!"
             next field atddatprg
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2

          if d_cts02m03.atddatprg < l_data   then
             error " Data programada menor que data atual!"
             next field atddatprg
          end if

          let l_data_limite = l_data + lr_retorno.agdlimqtd units day
          if d_cts02m03.atddatprg > l_data_limite and
             g_documento.ciaempcod <> 27                 then
             let l_mens = " Data programada para mais de ",lr_retorno.agdlimqtd clipped , " dias !"
             error l_mens
             let d_cts02m03.atddatprg = null
             next field atddatprg
          end if

   before field atdhorprg
          display by name d_cts02m03.atdhorprg attribute (reverse)

   after  field atdhorprg
          display by name d_cts02m03.atdhorprg

          if fgl_lastkey() = fgl_keyval("up")   or
             fgl_lastkey() = fgl_keyval("left") then
             next field atddatprg
          end if

          if d_cts02m03.atdhorprg is null or
             d_cts02m03.atdhorprg =  0    then
             error " Hora programada deve ser informada para servico programado!"
             next field atdhorprg
          end if

          call cts40g03_data_hora_banco(2)
               returning l_data, l_hora2
               
              let l_hora3 = l_hora2 + 1 units hour
          if d_cts02m03.atddatprg = l_data   and
             d_cts02m03.atdhorprg < l_hora3  then
             error " Hora programada não pode ser menor que a carencia minima!"             
             let l_erro_atdhorprg = true
             next field atdhorprg
          end if
          
          if d_cts02m03.atddatprg = l_data and 
             d_cts02m03.atdhorprg < l_hora2 then
             error "Nao e' possivel abrir servico com hora retroativa"
             let l_erro_atdhorprg = true
             next field atdhorprg
          end if

   on key (interrupt)
      if l_erro_atdhorprg then
         let d_cts02m03.atdhorprg = null
         let l_erro_atdhorprg = false
         next field atdhorprg
      end if      

      ## PSI 202363
     ## if g_documento.atdsrvorg = 9 then
    ##     initialize d_cts02m03.* to null
     ## end if


      exit input

 end input

 if int_flag then
    let int_flag = false
 end if

 close window cts02m03

 return d_cts02m03.*

end function  ###  cts02m03

function cts02m03_busca_limite()
    define l_agdlimqtd like datksrvtip.agdlimqtd
    define lr_retorno record
           coderro smallint,
           mens    char(300)
    end record
    initialize lr_retorno.* to null
    let l_agdlimqtd = null
    if m_prep is null or
       m_prep = false then
       call cts02m03_prepare()
    end if
    whenever error continue
      open ccts02m03001 using g_documento.atdsrvorg
      fetch ccts02m03001 into l_agdlimqtd
    whenever error stop
    if sqlca.sqlcode <> 0 then
       if sqlca.sqlcode = 100 then
          let lr_retorno.coderro = sqlca.sqlcode
          let lr_retorno.mens = "Erro <",lr_retorno.coderro ,"> ao buscar limite de agendamento, Avise a informatica !"
          error lr_retorno.mens
          #call errorlog(lr_retorno.mens)
       else
          let lr_retorno.coderro = sqlca.sqlcode
          let lr_retorno.mens = "Erro <",lr_retorno.coderro ,"> ao buscar limite de agendamento, Avise a informatica !"
          error lr_retorno.mens
          #call errorlog(lr_retorno.mens)
       end if
    end if
   return lr_retorno.*,l_agdlimqtd
end function

