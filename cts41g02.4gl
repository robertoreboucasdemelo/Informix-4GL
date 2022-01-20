#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : cts41g00.4gl                                        #
# Analista Resp.: Priscila Staingel                                   #
# OSF/PSI       : 202363                                              #
#                Trata cotas para serviço imediato                    #
#                                                                     #
# Desenvolvedor  : Priscila Staingel                                  #
# DATA           : 29/08/2006                                         #
#                                                                     #
# Objetivo: Funcoes de "busca" para servicos ainda nao acionados      #
#           dentro de uma area determinada e com mesmo grupo de nat.  #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
# 02/03/2010  Adriano Santos PSI252891 Inclusao do padrao idx 4 e 5   #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prepare smallint

#-----------------------------------------------------#
function cts41g02_prepare()
#-----------------------------------------------------#

   define l_sql    char(800)
   let l_sql = " select socntzgrpcod ",
               " from datksocntz     ",
               " where socntzcod = ? "
   prepare pcts41g02001 from l_sql
   declare ccts41g02001 cursor for pcts41g02001
   let l_sql =  " select c.lclltt,                       ",
                "        c.lcllgt,                       ",
                "        a.socntzcod,                    ",
                "        a.atdorgsrvnum,                 ",
                "        b.atdsrvnum,                    ",
                "        b.atdsrvano                     ",
                "  from datmsrvre a,                     ",
                "       datmservico b,                   ",
                "       datmlcl c                        ",
                "  where a.atdsrvnum = b.atdsrvnum       ",
                "    and a.atdsrvano = b.atdsrvano       ",
                "    and b.atdsrvnum = c.atdsrvnum       ",
                "    and b.atdsrvano = c.atdsrvano       ",
                "    and ((b.atddatprg = ?               ",
                "          and b.atdhorprg <= ? )        ",
                "          or (b.atddat = ?              ",
                "              and b.atddatprg is NULL)) ",
                "    and b.atdfnlflg in ('A', 'N')       ",
                "    and c.c24lclpdrcod in (3,4,5)     "  ##ligia 12/12/06 ## PSI 252891
   prepare pcts41g02002 from l_sql
   declare ccts41g02002 cursor for pcts41g02002
   let m_prepare = true
end function


#-----------------------------------------------------#
function cts41g02_obter_qtd_srv(param)
#-----------------------------------------------------#
   define param record
       lclltt       like datmlcl.lclltt,            #latitude do servico
       lcllgt       like datmlcl.lcllgt,            #longitude do servico
       atdvtrdst    like datkatmacnprt.atdvtrdst,   #distancia
       socntzgrpcod like datksocntz.socntzgrpcod,    #grupo de naturezas
       data         date,
       hora_limite  char(05)           #hora limite para busca de serviços
   end record
   define servico record
       lclltt       like datmlcl.lclltt,            #latitude do servico
       lcllgt       like datmlcl.lcllgt,            #longitude do servico
       socntzcod    like datksocntz.socntzcod,
       atdorgsrvnum like datmsrvre.atdorgsrvnum,
       atdsrvnum    like datmsrvre.atdsrvnum,
       atdsrvano    like datmsrvre.atdsrvano
   end record
   define retorno record
       qtde_servicos    smallint
   end record
   define l_socntzgrpcod            like datksocntz.socntzgrpcod  #auxiliar grupo de natureza
   define l_distancia               decimal(8,4)                  #distancia entre serviços
   define l_srv_lidos               smallint
   define l_srv_desprezados         smallint
   define l_servico_original        like datmservico.atdsrvnum
   define l_ano_original            like datmservico.atdsrvano
   define l_resultado               smallint
   define l_mensagem                char(10)
   initialize retorno.* to null
   initialize servico.* to null
   let l_socntzgrpcod = null
   let l_distancia = null
   let l_srv_lidos = 0
   let l_srv_desprezados = 0
   let l_resultado = null
   let l_mensagem = null
   let l_srv_lidos = 0
   let retorno.qtde_servicos = 0
   if m_prepare <> true then
      call cts41g02_prepare()
   end if
   #buscar serviços não acionados com mesmo grupo de natureza
   # e com data/hora programada até a hora limite
   open ccts41g02002 using param.data,
                           param.hora_limite,
                           param.data
   foreach ccts41g02002 into servico.lclltt,
                             servico.lcllgt,
                             servico.socntzcod,
                             servico.atdorgsrvnum,
                             servico.atdsrvnum,
                             servico.atdsrvano

       let l_srv_lidos = l_srv_lidos + 1

       if servico.lclltt is null or
          servico.lcllgt is null or
          servico.atdorgsrvnum is not null then #ligia, desprezar RET
          #ignorar servicos não indexados
          let l_srv_desprezados = l_srv_desprezados + 1
          continue foreach
       end if

       let l_servico_original = null
       let l_ano_original = null

       ## desprezar os servicos multiplos
       call cts29g00_consistir_multiplo(servico.atdsrvnum
                                       ,servico.atdsrvano)
            returning l_resultado
                     ,l_mensagem
                     ,l_servico_original
                     ,l_ano_original
       if l_servico_original is not null then
          let l_srv_desprezados = l_srv_desprezados + 1
          continue foreach
       end if

       let l_distancia = cts18g00 (param.lclltt,
                                   param.lcllgt,
                                   servico.lclltt,
                                   servico.lcllgt )
       #se distancia entre servicos maior que a distncia parametrizada
       # ignorar servico
       if l_distancia > param.atdvtrdst then
          let l_srv_desprezados = l_srv_desprezados + 1
          continue foreach
       end if
       #buscar grupo de natureza do servico lido
       open ccts41g02001 using servico.socntzcod
       fetch ccts41g02001 into l_socntzgrpcod
       #se grupo diferente - ignora servico
       if l_socntzgrpcod <> param.socntzgrpcod then
          let l_srv_desprezados = l_srv_desprezados + 1
          continue foreach
       end if
       let retorno.qtde_servicos = retorno.qtde_servicos + 1
   end foreach

   #if g_issk.funmat = 9034 or g_issk.funmat = 600614 then
   #   display 'Srv RET, multiplos, s/coordenadas, fora da distancia'
   #   display 'QTD servicos desprezados ', l_srv_desprezados
   #end if
   return  retorno.qtde_servicos
end function

#retorna a hora fechada limite
# hora atual + hora recebida como parametro (hora parametrizada
#  para acionar servico) + 1 hora (proxima hora)
#-----------------------------------------------------#
function cts41g02_hora_limite_servico(param)
#-----------------------------------------------------#
    define param record
        hora   datetime hour to minute
    end record
     define l_data         date
     define l_hora_atual   datetime hour to minute
     define l_hora_char1   char(05)
     define l_hora_char2   char(05)
     define l_hora_char3   char(06)
     define l_hora_inter1  interval hour to minute
     define l_hora_inter2  interval hour to minute
     define l_hora_inter3  interval hour to minute
     define l_hora_calc    interval hour to minute
     define l_hora_limite  char(05)
     let l_data         = null
     let l_hora_atual   = null
     let l_hora_char1   = null
     let l_hora_char2   = null
     let l_hora_inter1  = null
     let l_hora_inter2  = null
     let l_hora_inter3  = null
     let l_hora_calc    = null
     let l_hora_limite  = null
     call cts40g03_data_hora_banco(2)
         returning l_data,
                   l_hora_atual
     #copia as variaveis datetime para variaveis char
     let l_hora_char1 = param.hora
     let l_hora_char2 = l_hora_atual

     #copia variaveis char para variaveis interval
     let l_hora_inter1 = l_hora_char1
     let l_hora_inter2 = l_hora_char2
     let l_hora_inter3 = "01:00"

     #calcula hora
     let l_hora_calc = l_hora_inter1 + l_hora_inter2 + l_hora_inter3
     if l_hora_calc > "23:59" then
        let l_hora_calc = (l_hora_calc - "24:00")
     end if
     #copiar variavel interval para um char de 6 posições
     let l_hora_char3 = l_hora_calc
     let l_hora_limite = l_hora_char3[2,3], ":00"
     return l_hora_limite

end function
