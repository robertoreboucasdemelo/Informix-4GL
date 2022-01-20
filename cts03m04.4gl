#----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                            #
# ...........................................................................#
# Sistema       : Central 24hrs.                                             #
# Modulo        : cts03m04.                                                  #
# Analista Resp.: Amilton Pinto#
# PSI           : 205206                                                     #
#                 Obter os limites de utilizacao para a clausula 46/46R      #
#............................................................................#
# Desenvolvimento: Amilton Pinto                                             #
# Liberacao      :                                                           #
#............................................................................#
#                                                                            #
#                   * * * Alteracoes * * *                                   #
#                                                                            #
# Data       Autor Fabrica     Origem     Alteracao                          #
# ---------- ----------------- ---------- -----------------------------------#
#............................................................................#
globals "/homedsa/projetos/geral/globals/glct.4gl"

define m_prep_sql smallint

#---------------------------------------------------------------------------#
function cts03m04_prepare()
#---------------------------------------------------------------------------#
 define l_sql char(600)

 let l_sql = " select clscod from abbmclaus ",
             " where ",
             " succod = ? ",
             " and aplnumdig = ? ",
             " and itmnumdig = ? ",
             " and dctnumseq = ? ",
             " and clscod in ('034','033','035','044','44R','046','46R','47R','047','048','48R') "

 prepare pcts03m04001 from l_sql
 declare ccts03m04001 cursor with hold for pcts03m04001

 let l_sql = ' select count(*) '
            ,' from datrservapol a, datmservico b, datmligacao c '
            ,' where a.ramcod    = ? '
            ,' and a.succod    = ? '
            ,' and a.aplnumdig = ? '
            ,' and a.itmnumdig = ? '
            ,' and a.atdsrvnum = b.atdsrvnum '
            ,' and a.atdsrvano = b.atdsrvano '
            ,' and a.atdsrvnum = c.atdsrvnum '
            ,' and a.atdsrvano = c.atdsrvano '
            ,' and c.c24astcod = "S10" '
            ,' and b.asitipcod not in (4,50)'
            ,' and b.atdetpcod not in (5,6) '
 prepare pcts03m04002 from l_sql
 declare ccts03m04002 cursor for pcts03m04002

 let l_sql = ' select count(*) '
            ,' from datrservapol a, datmservico b, datmligacao c '
            ,' where a.ramcod    = ? '
            ,' and a.succod    = ? '
            ,' and a.aplnumdig = ? '
            ,' and a.itmnumdig = ? '
            ,' and a.atdsrvnum = b.atdsrvnum '
            ,' and a.atdsrvano = b.atdsrvano '
            ,' and a.atdsrvnum = c.atdsrvnum '
            ,' and a.atdsrvano = c.atdsrvano '
            ,' and c.c24astcod = "S10" '
            ,' and b.asitipcod in (4,50)'
            ,' and b.atdetpcod not in (5,6) '
 prepare pcts03m04003 from l_sql
 declare ccts03m04003 cursor for pcts03m04003





  let m_prep_sql = true

end function

#---------------------------------------------------------------------------#
function cts03m04_limite(lr_entrada)
#---------------------------------------------------------------------------#
   define lr_entrada record
          ramcod    like datrservapol.ramcod
         ,succod    like datrservapol.succod
         ,aplnumdig like datrservapol.aplnumdig
         ,itmnumdig like datrservapol.itmnumdig
         ,edsnumref like datrservapol.edsnumref
         ,asitipcod like datmservico.asitipcod
         ,c24astcod like datmligacao.c24astcod
   end record

   define lr_servico record
          gui_util    integer,
          gui_lim     integer,
          chav_util   integer,
          chav_lim    integer
   end record

   define l_clscod like abbmclaus.clscod
   define l_resp char(01)

   initialize lr_servico.* to null

   let l_clscod = null



   if m_prep_sql is null or
      m_prep_sql <> true then
      call cts03m04_prepare()
   end if

        call f_funapol_ultima_situacao
                 (g_documento.succod, g_documento.aplnumdig,
                  g_documento.itmnumdig)
                  returning g_funapol.*

            if g_funapol.dctnumseq is null  then
               select min(dctnumseq)
                 into g_funapol.dctnumseq
                 from abbmdoc
                where succod    = g_documento.succod
                  and aplnumdig = g_documento.aplnumdig
                  and itmnumdig = g_documento.itmnumdig
            end if

          open ccts03m04001 using g_documento.succod
                                 ,g_documento.aplnumdig
                                 ,g_documento.itmnumdig
                                 ,g_funapol.dctnumseq
          whenever error continue
          foreach ccts03m04001 into l_clscod

            if l_clscod = "034" or
               l_clscod = "071" or
               l_clscod = "077" then
              if cta13m00_verifica_clausula(g_documento.succod ,
                                            g_documento.aplnumdig,
                                            g_documento.itmnumdig,
                                            g_funapol.dctnumseq ,
                                            l_clscod) then

               continue foreach

              end if
            end if
          end foreach
          whenever error stop


  if l_clscod = '046' or
     l_clscod = '46R' or
     l_clscod = '44R' or
     l_clscod = '48R' then

     # Limite para a clausula 46R,44R e 48R
     if l_clscod = '46R' or l_clscod = '44R' or l_clscod = '48R' then
        let lr_servico.gui_lim = 3
        let lr_servico.chav_lim = 3
     end if

     ##-- Obter os servicos dos atendimentos realizados pela apolice para guincho
     whenever error continue
     open ccts03m04002 using lr_entrada.ramcod
                            ,lr_entrada.succod
                            ,lr_entrada.aplnumdig
                            ,lr_entrada.itmnumdig

     fetch ccts03m04002 into lr_servico.gui_util
     whenever error stop
     close ccts03m04002

     whenever error continue
     open ccts03m04003 using lr_entrada.ramcod
                            ,lr_entrada.succod
                            ,lr_entrada.aplnumdig
                            ,lr_entrada.itmnumdig

     fetch ccts03m04003 into lr_servico.chav_util
     whenever error stop
     close ccts03m04003

     open window t_cts03m04 at 8,15 with form "cts03m04"
          attribute(form line 1, border)

        display by name lr_servico.gui_util
                       ,lr_servico.gui_lim
                       ,lr_servico.chav_util
                       ,lr_servico.chav_lim


     #if int_flag then
     #   let int_flag = false
     #end if

       prompt "Pressione <Enter> para sair " for char l_resp
     close window t_cts03m04
end if

if (lr_servico.gui_util >= lr_servico.gui_lim) and
   (lr_servico.chav_util >= lr_servico.chav_lim)  then
    return true
else
    return false

end if

#return true


end function

#---------------------------------------------------------------------------#
function cts03m04_limite_azul()
#---------------------------------------------------------------------------#

   define lr_retorno record
          gui_util    integer,
          gui_lim     integer,
          chav_util   integer,
          chav_lim    integer
   end record  
   
   define l_resp char(01) 
   
   initialize lr_retorno.* to null
   
   call cts43g00_recupera_limites() 
   returning lr_retorno.gui_util  , 
             lr_retorno.gui_lim   ,
             lr_retorno.chav_util ,
             lr_retorno.chav_lim 
   

   open window t_cts03m04 at 8,15 with form "cts03m04"
        attribute(form line 1, border)

   display by name lr_retorno.gui_util
                  ,lr_retorno.gui_lim
                  ,lr_retorno.chav_util
                  ,lr_retorno.chav_lim


   
   prompt "Pressione <Enter> para sair " for char l_resp
   close window t_cts03m04



end function