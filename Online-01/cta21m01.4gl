#-----------------------------------------------------------------------------#
# Porto Seguro Cia Seguros Gerais                                             #
#.............................................................................#
# Sistema........: Auto e RE - Itau Seguros                                   #
# Modulo.........: cta21m01                                                   #
# Objetivo.......: Espelho do Itau Residencia - Consulta Endereco             #
# Analista Resp. : Ligia - Fornax                                             #
# PSI            : PSI-2012-1?5798 PR - Atendimento Itau Residencia           #
#.............................................................................#
# Desenvolvimento: Hamilton - Fornax                                          #
# Data...........: 21/07/2012
#.............................................................................#
#                         * * * ALTERACOES * * *                              #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto

globals "/homedsa/projetos/geral/globals/glct.4gl"

define mr_tela record
       rsclgdnom    like datmresitaaplitm.rsclgdnom      ,  #--> logradouro_risco;
       rsclgdnum    like datmresitaaplitm.rsclgdnum      ,  #--> numero_risco;
       rsccpldes    like datmresitaaplitm.rsccpldes      ,  #--> complemento_risco;
       rscbrrnom    like datmresitaaplitm.rscbrrnom      ,  #--> bairro_risco;
       rsccepcod    like datmresitaaplitm.rsccepcod      ,  #--> cep_risco;
       rsccepcplcod like datmresitaaplitm.rsccepcplcod   ,  #--> compementocep_risco
       rsccidnom    like datmresitaaplitm.rsccidnom      ,  #--> cidade_risco;
       rscestsgl    like datmresitaaplitm.rscestsgl      ,  #--> uf_risco;
       ddd_telefone_risco char(04)                                          ,  #--> ddd_telefone_risco
       telefone_risco     char(10)                                          ,  #--> telefone_risco;

       seglgdnom    like datmresitaapl.seglgdnom         ,  #--> logradouro_seg;
       seglgdnum    like datmresitaapl.seglgdnum         ,  #--> numero_seg;
       seglcacpldes like datmresitaapl.seglcacpldes      ,  #--> complemento_seg;
       brrnom       like datmresitaapl.brrnom            ,  #--> bairro_seg;
       cepcod       like datmresitaapl.cepcod            ,  #--> cep_seg;
       cepcplcod    like datmresitaapl.cepcplcod         ,  #--> compementocep_seg;
       segcidnom    like datmresitaapl.segcidnom         ,  #--> cidade_seg;
       estsgl       like datmresitaapl.estsgl            ,  #--> uf_seg;
       dddcod       like datmresitaapl.dddcod            ,  #--> telefone_seg;
       telnum       like datmresitaapl.telnum            #--> telefone_seg;
end record
#------------------------------------------------------------------------------#

function cta21m01()

   define l_resp char(01)

   initialize mr_tela.* to null

 select a.rsclgdnom    , #logradouro,
          a.rsclgdnum    , #numero,
          a.rsccpldes    , #complemento,
          a.rscbrrnom    , #bairro,
          a.rsccepcod    , #cep,
          a.rsccepcplcod , #complemento_cep ,
          a.rsccidnom    , #cidade,
          a.rscestsgl    , #uf,
          b.dddcod       , #ddd_risco
          b.telnum       , #tel_risco
          b.seglgdnom    , #logradouro_seg,
          b.seglgdnum    , #numero_seg,
          b.seglcacpldes , #complem_seg,
          b.brrnom       , #bairro_seg,
          b.cepcod       , #cep_seg,
          b.cepcplcod    , #compl_cep_seg,
          b.segcidnom    , #cidade_seg,
          b.estsgl       , #uf_seg,
          b.dddcod       , #ddd_seg,
          b.telnum         #tel_seg
   into mr_tela.*
   from datmresitaaplitm a,
        datmresitaapl    b
    where a.itaciacod    = b.itaciacod
      and a.itaramcod    = b.itaramcod
      and a.aplnum       = b.aplnum
      and a.aplseqnum    = b.aplseqnum
      and a.itaciacod    = g_doc_itau[1].itaciacod
      and a.itaramcod    = g_doc_itau[1].itaramcod
      and a.aplnum       = g_doc_itau[1].itaaplnum
      and a.aplseqnum    = g_doc_itau[1].aplseqnum
      and a.aplitmnum    = g_doc_itau[1].itaaplitmnum


   open window w_cta21m01 at 4,2 with form 'cta21m01'
      attribute (prompt line last)

      display by name mr_tela.*
      if mr_tela.cepcplcod is not null then
	 display '-' at 16,72
      end if
      if mr_tela.cepcod is not null then
	 display '-' at 16,72
      end if

      prompt "Pressione <Enter> para sair " for char l_resp

   close window w_cta21m01

end function #--> cta21m01()
#---------------------------------------------------------- Final do Modulo ---#
