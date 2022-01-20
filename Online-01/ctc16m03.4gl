#---------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                     #
# ....................................................................#
# Sistema       : Central 24h                                         #
# Modulo        : ctc16m03                                            #
# Analista Resp.: Ligia Mattge                                        #
# PSI           : 188239                                              #
# Objetivo      : Obter Descricao da Natureza do servico              #
#.....................................................................#
# Desenvolvimento: Mariana , META                                     #
# Liberacao      : 25/10/2004                                         #
#.....................................................................#
#                                                                     #
#                  * * * Alteracoes * * *                             #
#                                                                     #
# Data        Autor Fabrica  Origem    Alteracao                      #
# ----------  -------------- --------- ------------------------------ #
#---------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"


define m_prepare                smallint

#--------------------------#
function ctc16m03_prepare()
#--------------------------#

define l_comando         char(400)

   let l_comando = "select socntzdes, socntzgrpcod "
                  ,"  from datksocntz    "
                  ," where socntzcod = ? "
                  ,"   and socntzstt = ? "

   prepare pctc16m03001 from l_comando
   declare cctc16m03001 cursor for pctc16m03001


   let l_comando = "select a.socntzdes, b.socntzgrpcod ",
                   "from datksocntz a, datrgrpntz b, datrempgrp c ",
                   "where a.socntzcod = b.socntzcod ",
                   "and b.socntzgrpcod = c.socntzgrpcod ",
                   "and a.socntzcod = ?  ",
                   "and a.socntzstt    = ? ",
                   "and c.empcod = ? " ,
                   "and c.c24astcod = ? "
   prepare pctc16m03002 from l_comando
   declare cctc16m03002 cursor for pctc16m03002


   let m_prepare = true

end function

#----------------------------------------------------#
function ctc16m03_inf_natureza(l_socntzcod,l_socntzstt)
#----------------------------------------------------#

define l_socntzcod           like datksocntz.socntzcod
     , l_socntzstt           like datksocntz.socntzstt
     , l_socntzdes           like datksocntz.socntzdes
     , l_socntzgrpcod        like datksocntz.socntzgrpcod
     , l_resultado           smallint
     , l_mensagem            char(80)

   let l_mensagem     = null
   let l_socntzgrpcod = null
   let l_socntzdes    = null

   if l_socntzcod is null or
      l_socntzstt is null then
      let l_mensagem = "Parametros incorretos !(ctc16m03_inf_natureza()) "
      let l_resultado = 3
      return l_resultado, l_mensagem
            ,l_socntzdes, l_socntzgrpcod
    end if

    if m_prepare is null or
       m_prepare <> true then
       call ctc16m03_prepare()
    end if


    if ( g_documento.ciaempcod = 40      or
         g_documento.ciaempcod = 43    ) and  # PSI 247936 Empresas 27
         g_documento.c24astcod <> "RET"  then

      whenever error continue
      open cctc16m03002 using l_socntzcod
                             ,l_socntzstt
                             ,g_documento.ciaempcod
                             ,g_documento.c24astcod
      fetch cctc16m03002 into l_socntzdes
                             ,l_socntzgrpcod
      whenever error stop

      if sqlca.sqlcode <> 0 then
         if sqlca.sqlcode < 0 then
            let l_mensagem  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," no acesso a tabela datksocntz "
            let l_resultado = 3
         else
            let l_mensagem  = "Natureza nao Cadastrada "
            let l_resultado = 2
         end if
      else
         let l_resultado = 1
      end if

    else

         whenever error continue
         open cctc16m03001 using l_socntzcod
                                ,l_socntzstt
         fetch cctc16m03001 into l_socntzdes
                                ,l_socntzgrpcod
         whenever error stop

         if sqlca.sqlcode <> 0 then
            if sqlca.sqlcode < 0 then
               let l_mensagem  = "Erro : ", sqlca.sqlcode, '/', sqlca.sqlerrd[2] ," no acesso a tabela datksocntz "
               let l_resultado = 3
            else
               let l_mensagem  = "Natureza nao Cadastrada "
               let l_resultado = 2
            end if
         else
            let l_resultado = 1
         end if

    end if

    return l_resultado, l_mensagem
          ,l_socntzdes, l_socntzgrpcod

end function                                                               