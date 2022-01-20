#############################################################################
# Nome do Modulo: CTX08G00                                             Akio #
#                                                                      Ruiz #
# Atendimento ao corretor - Funcao de gravacao ligacao x proposta  Abr/2000 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#############################################################################

 database porto

globals "/homedsa/projetos/geral/globals/glct.4gl" 

 define g_ctx08g00        char(01)

#-------------------------------------------------------------------------------
 function ctx08g00( p_ctx08g00 )
#-------------------------------------------------------------------------------

   define p_ctx08g00      record
          tipo            smallint                    ,
          corlignum       like dacmlig.corlignum      ,
          corligitmseq    like dacmligass.corligitmseq,
          prporgpcp       like dacrligorc.prporgpcp   ,
          prpnumpcp       like dacrligorc.prpnumpcp   ,
          prporgidv       like dacrligorc.prporgidv   ,
          prpnumidv       like dacrligorc.prpnumidv   ,
          corligano       like dacmlig.corligano
   end record

   define w_ret           record
          cod             smallint,
          msg             char(70)
   end record




	initialize  w_ret.*  to  null

   whenever error continue

   let w_ret.cod = 0
   let w_ret.msg = "TABELA DE RELACIONAMENTO GRAVADA COM SUCESSO"

   while true

   if  p_ctx08g00.tipo  < 1  or
       p_ctx08g00.tipo  > 2  then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO - TIPO"
       exit while
   end if

   if  p_ctx08g00.corlignum    is null  or
       p_ctx08g00.corligitmseq is null  then
       let w_ret.cod = 1
       let w_ret.msg = "PARAMETRO INVALIDO - NUMERO DA LIGACAO"
       exit while
   end if

   if  p_ctx08g00.prporgpcp is null  or
       p_ctx08g00.prpnumpcp is null  or
       p_ctx08g00.prporgidv is null  or
       p_ctx08g00.prpnumidv is null  then
       if  p_ctx08g00.tipo  = 1 then
           let w_ret.cod = 1
           let w_ret.msg = "PARAMETRO INVALIDO - PROPOSTA ORCAMENTO"
       else
           let w_ret.cod = 1
           let w_ret.msg = "PARAMETRO INVALIDO - PROPOSTA RS"
       end if
       exit while
   end if


   case p_ctx08g00.tipo

      #-------------------------------------------------------------------------
      # Grava relacionamento ligacao x orcamento
      #-------------------------------------------------------------------------
        when 1     insert into dacrligorc( corlignum,
                                           corligano,
                                           corligitmseq,
                                           prporgpcp,
                                           prpnumpcp,
                                           prporgidv,
                                           prpnumidv    )
                               values( p_ctx08g00.corlignum   ,
                                       p_ctx08g00.corligano   ,
                                       p_ctx08g00.corligitmseq,
                                       p_ctx08g00.prporgpcp   ,
                                       p_ctx08g00.prpnumpcp   ,
                                       p_ctx08g00.prporgidv   ,
                                       p_ctx08g00.prpnumidv    )

      #-------------------------------------------------------------------------
      # Grava relacionamento ligacao x renovacao simplificada
      #-------------------------------------------------------------------------
        when 2     insert into dacrligsmprnv( corlignum,
                                              corligano,
                                              corligitmseq,
                                              prporgpcp,
                                              prpnumpcp,
                                              prporgidv,
                                              prpnumidv    )
                               values( p_ctx08g00.corlignum   ,
                                       p_ctx08g00.corligano   ,
                                       p_ctx08g00.corligitmseq,
                                       p_ctx08g00.prporgpcp   ,
                                       p_ctx08g00.prpnumpcp   ,
                                       p_ctx08g00.prporgidv   ,
                                       p_ctx08g00.prpnumidv    )

   end case

   if  sqlca.sqlcode = 0  then
       exit while
   else
    if  sqlca.sqlcode = -268  then
        if  p_ctx08g00.tipo  = 1  then
            let w_ret.cod = 2
            let w_ret.msg = "ORCAMENTO JA GRAVADO PARA ESTE ITEM DA LIGACAO. ",
                            "INCLUA NOVO ASSUNTO."
            exit while
        else
            let w_ret.cod = 2
            let w_ret.msg = "RS JA GRAVADA PARA ESTE ITEM DA LIGACAO. ",
                            "INCLUA NOVO ASSUNTO."
            exit while
        end if
    else
        if  p_ctx08g00.tipo  = 1  then
            let w_ret.cod = 99
            let w_ret.msg = "ERRO ", sqlca.sqlcode, " NA GRAVACAO DA ",
                            "TABELA DACRLIGORC. AVISE A INFORMATICA. "
            exit while
        else
            let w_ret.cod = 99
            let w_ret.msg = "ERRO ", sqlca.sqlcode, " NA GRAVACAO DA ",
                            "TABELA DACRLIGSMPRNV. AVISE A INFORMATICA. "
            exit while
        end if
    end if
   end if

   end while

   if  p_ctx08g00.tipo = 1 and w_ret.cod = 2 then
      select * from  dacmatdpndsit
       where corlignum    = p_ctx08g00.corlignum
         and corligano    = p_ctx08g00.corligano
         and corligitmseq = p_ctx08g00.corligitmseq

      if sqlca.sqlcode <> 100 then
         let w_ret.cod = 0
      end if

   end if

   whenever error stop

   return w_ret.*

end function

#-------------------------------------------------------------------------------
function ctx08g00_grava_pendencia(p_ctx08g00_grava)
#-------------------------------------------------------------------------------

   define p_ctx08g00_grava record
     corlignum    like dacmatdpndsit.corlignum
    ,corligano    like dacmatdpndsit.corligano
    ,corligitmseq like dacmatdpndsit.corligitmseq
    ,cademp       like dacmatdpndsit.cademp
    ,cadmat       like dacmatdpndsit.cadmat
   end record

   define l_count smallint


	let	l_count  =  null

   let l_count = null
   select count(*)
   into l_count
   from dacmatdpndsit
   where corlignum     = p_ctx08g00_grava.corlignum
     and corligano     = p_ctx08g00_grava.corligano
     and corligitmseq  = p_ctx08g00_grava.corligitmseq

   if l_count = 0 then
      whenever error continue
         insert into dacmatdpndsit
            (corlignum
            ,corligitmseq
            ,c24pndsitcod
            ,caddat
            ,cadhor
            ,cademp
            ,cadmat
            ,corligano)
            values
            (p_ctx08g00_grava.corlignum
            ,p_ctx08g00_grava.corligitmseq
            ,0
            ,today
            ,current
            ,p_ctx08g00_grava.cademp
            ,p_ctx08g00_grava.cadmat
            ,p_ctx08g00_grava.corligano)

      whenever error stop
      if sqlca.sqlcode <> 0 then
         error "Problemas ao inserir o registro na tabela dacmatdpndsit"
         sleep 2
         error ""
      else
         error "Pendencia gerada"
         sleep 2
         error ""
      end if

      select * from dacmpndret
       where corlignum     = p_ctx08g00_grava.corlignum
         and corligano     = p_ctx08g00_grava.corligano

      if status = notfound then
         whenever error continue
         insert into dacmpndret
               (corlignum
               ,corligano)
               values
               (p_ctx08g00_grava.corlignum
               ,p_ctx08g00_grava.corligano)
         whenever error stop
         if sqlca.sqlcode <> 0 then
            error "Problemas ao inserir o registro na tabela dacmpndret"
            sleep 2
            error ""
         end if
      end if
   end if

end function

#-------------------------------------------------------------------------------
function ctx08g00_atualiza_pendencia( p_ctx08g00_atualiza)
#-------------------------------------------------------------------------------

   define p_ctx08g00_atualiza record
      prporgpcp   like dacrligorc.prporgpcp
     ,prpnumpcp   like dacrligorc.prpnumpcp
     ,prporgidv   like dacrligorc.prporgidv
     ,prpnumidv   like dacrligorc.prpnumidv
     ,cademp      like dacmatdpndsit.cademp
     ,cadmat      like dacmatdpndsit.cadmat
   end record

   define l_ctx08g00 record
      corlignum    like dacrligorc.corlignum
     ,corligitmseq like dacrligorc.corligitmseq
     ,corligano    like dacrligorc.corligano
   end record

   define ws         record
      seq          smallint
   end record

   define w_idvok char(01)

   define l_sql char(200)


	let	w_idvok  =  null
	let	l_sql  =  null

	initialize  l_ctx08g00.*  to  null

	initialize  ws.*  to  null

   let w_idvok = "S"

   let l_sql = "update dacmatdpndsit set "
             , " (c24pndsitcod, caddat, cadhor ) = "
             , " (2, today, current) "
             , " where corlignum    = ? "
             , "   and corligano    = ? "
             , "   and corligitmseq = ? "
   prepare pctx08g00002 from l_sql

   initialize l_ctx08g00 to null

   if p_ctx08g00_atualiza.prporgidv is not null and
      p_ctx08g00_atualiza.prpnumidv is not null then

    # select corlignum, corligitmseq, corligano
    # into l_ctx08g00.corlignum, l_ctx08g00.corligitmseq, l_ctx08g00.corligano
    # from dacrligorc
    # where prporgpcp = p_ctx08g00_atualiza.prporgpcp
    #   and prpnumpcp = p_ctx08g00_atualiza.prpnumpcp
    #   and prporgidv = p_ctx08g00_atualiza.prporgidv
    #   and prpnumidv = p_ctx08g00_atualiza.prpnumidv
    # if sqlca.sqlcode = notfound then
      ----------------------------------------------[ ruiz ]------------
      initialize l_ctx08g00.corlignum to null
      declare c_dacrligorc cursor for
         select corlignum, corligitmseq, corligano
             from dacrligorc
             where prporgpcp = p_ctx08g00_atualiza.prporgpcp
               and prpnumpcp = p_ctx08g00_atualiza.prpnumpcp
               and prporgidv = p_ctx08g00_atualiza.prporgidv
               and prpnumidv = p_ctx08g00_atualiza.prpnumidv
      foreach c_dacrligorc into l_ctx08g00.corlignum,
                                l_ctx08g00.corligitmseq,
                                l_ctx08g00.corligano
           exit foreach
      end foreach
      if l_ctx08g00.corlignum is null then
         let w_idvok = "N"
      else
       # select max(corligitmseq)
       #        into ws.seq
       #        from dacmatdpndsit
       #        where corlignum = l_ctx08g00.corlignum
       #          and corligano = l_ctx08g00.corligano
       # if status = notfound  then
       #    let ws.seq = 0
       # end if

         select max(corligitmseq)
                into ws.seq
                from dacmatdpndsit
                where corlignum    = l_ctx08g00.corlignum
                  and corligano    = l_ctx08g00.corligano
                  and corligitmseq = l_ctx08g00.corligitmseq
                  and c24pndsitcod = 2
         if ws.seq is null     then
            insert into dacmatdpndsit (corlignum   ,
                                       corligano   ,
                                       corligitmseq,
                                       c24pndsitcod,
                                       cadmat,
                                       caddat      ,
                                       cadhor,
                                       cademp)
                             values (l_ctx08g00.corlignum,
                                     l_ctx08g00.corligano,
                                   # ws.seq,
                                     l_ctx08g00.corligitmseq,
                                     2,
                                     g_issk.funmat, today, current,
                                     g_issk.empcod )
            if sqlca.sqlcode <> 0 then
               error "Problemas na atualizacao da pendencia"
               sleep 2
               error ""
            else
               error "Pendencia concluida"
               sleep 2
               error ""
            end if
         else
            error "Problemas na atualizacao da pendencia"
            sleep 2
            error ""
         end if
      end if
   end if

   if (p_ctx08g00_atualiza.prporgidv is null  or
       p_ctx08g00_atualiza.prpnumidv is null) or
       w_idvok = "N"                          then

      declare cctx08g00001 cursor with hold for
      select corlignum, corligitmseq, corligano
      from dacrligorc
      where prporgpcp = p_ctx08g00_atualiza.prporgpcp
        and prpnumpcp = p_ctx08g00_atualiza.prpnumpcp

      foreach cctx08g00001 into l_ctx08g00.corlignum
                               ,l_ctx08g00.corligitmseq
                               ,l_ctx08g00.corligano
        #select max(corligitmseq)
        #       into ws.seq
        #       from dacmatdpndsit
        #       where corlignum = l_ctx08g00.corlignum
        #         and corligano = l_ctx08g00.corligano
        #if status = notfound  then
        #   let ws.seq = 0
        #end if

         select max(corligitmseq)
                into ws.seq
                from dacmatdpndsit
                where corlignum    = l_ctx08g00.corlignum
                  and corligano    = l_ctx08g00.corligano
                  and corligitmseq = l_ctx08g00.corligitmseq
                  and c24pndsitcod = 2
         if ws.seq is null     then
            insert into dacmatdpndsit (corlignum   ,
                                       corligano   ,
                                       corligitmseq,
                                       c24pndsitcod,
                                       cadmat,
                                       caddat      ,
                                       cadhor,
                                       cademp)
                             values (l_ctx08g00.corlignum,
                                     l_ctx08g00.corligano,
                                   # ws.seq,
                                     l_ctx08g00.corligitmseq,
                                     2,
                                     g_issk.funmat, today, current,
                                     g_issk.empcod )

            if sqlca.sqlcode <> 0 then
               error "Problemas na atualizacao da pendencia"
               sleep 2
               error ""
            else
               error "Pendencia concluida"
               sleep 2
               error ""
            end if
         else
            error "Problemas na atualizacao da pendencia"
            sleep 2
            error ""
         end if
      end foreach
   end if

end function

function ctx08g00_rec_assunto(lr_param)

define lr_param record
     corlignum     like dacmlig.corlignum    ,
     corligano     like dacmlig.corligano    ,
     corligitmseq  like dacmligass.corligitmseq 
end record

define lr_retorno record
     corasscod like dacmligass.corasscod ,
     resultado smallint
end record

initialize lr_retorno.* to null    

    select corasscod                         
    into lr_retorno.corasscod                                 
    from dacmligass                         
    where corlignum  = lr_param.corlignum     
    and corligano    = lr_param.corligano 
    and corligitmseq = lr_param.corligitmseq  
    
    if status = notfound  then
        let lr_retorno.resultado = 1 
    else
        if lr_retorno.corasscod = 36 then 
           let lr_retorno.resultado = 1             
        else
           let lr_retorno.resultado = 0
        end if    
    end if
    
    
return lr_retorno.resultado    
    
                          
end function
{
#-------------------------------------------------------------------------------
function ctx08g00_atualiza_pendencia( p_ctx08g00_atualiza)
#-------------------------------------------------------------------------------

   define p_ctx08g00_atualiza record
      prporgpcp   like dacrligorc.prporgpcp
     ,prpnumpcp   like dacrligorc.prpnumpcp
     ,prporgidv   like dacrligorc.prporgidv
     ,prpnumidv   like dacrligorc.prpnumidv
     ,cademp      like dacmatdpndsit.cademp
     ,cadmat      like dacmatdpndsit.cadmat
   end record

   define l_ctx08g00 record
      corlignum    like dacrligorc.corlignum
     ,corligitmseq like dacrligorc.corligitmseq
     ,corligano    like dacrligorc.corligano
   end record

   define w_idvok char(01)

   define l_sql char(200)

   let w_idvok = "S"

   let l_sql = "update dacmatdpndsit set "
             , " (c24pndsitcod, caddat, cadhor ) = "
             , " (2, today, current) "
             , " where corlignum    = ? "
             , "   and corligano    = ? "
             , "   and corligitmseq = ? "
   prepare pctx08g00002 from l_sql

   initialize l_ctx08g00 to null

   if p_ctx08g00_atualiza.prporgidv is not null and
      p_ctx08g00_atualiza.prpnumidv is not null then

      select corlignum, corligitmseq, corligano
      into l_ctx08g00.corlignum, l_ctx08g00.corligitmseq, l_ctx08g00.corligano
      from dacrligorc
      where prporgpcp = p_ctx08g00_atualiza.prporgpcp
        and prpnumpcp = p_ctx08g00_atualiza.prpnumpcp
        and prporgidv = p_ctx08g00_atualiza.prporgidv
        and prpnumidv = p_ctx08g00_atualiza.prpnumidv

      if sqlca.sqlcode = notfound then
         let w_idvok = "N"
      else
         execute pctx08g00002 using l_ctx08g00.corlignum
                                   ,l_ctx08g00.corligano
                                   ,l_ctx08g00.corligitmseq
         if sqlca.sqlcode <> 0 then
            error "Problemas na atualizacao da pendencia"
            sleep 2
            error ""
         else
            error "Pendencia concluida"
            sleep 2
            error ""
         end if
      end if
   end if

   if (p_ctx08g00_atualiza.prporgidv is null  or
       p_ctx08g00_atualiza.prpnumidv is null) or
       w_idvok = "N"                          then

      declare cctx08g00001 cursor with hold for
      select corlignum, corligitmseq, corligano
      from dacrligorc
      where prporgpcp = p_ctx08g00_atualiza.prporgpcp
        and prpnumpcp = p_ctx08g00_atualiza.prpnumpcp

      foreach cctx08g00001 into l_ctx08g00.corlignum
                               ,l_ctx08g00.corligitmseq
                               ,l_ctx08g00.corligano

         execute pctx08g00002 using l_ctx08g00.corlignum
                                   ,l_ctx08g00.corligano
                                   ,l_ctx08g00.corligitmseq
         if sqlca.sqlcode <> 0 then
            error "Problemas na atualizacao da pendencia"
            sleep 2
            error ""
         else
            error "Pendencia concluida"
            sleep 2
            error ""
         end if
      end foreach
   end if

end function
}
 
 
