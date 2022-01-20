#############################################################################
# Nome do Modulo: CTS00M32                              Fabrida de Software #
#                                                                     Paula #
# Funcao para verificar ultima atividadepor viatura                Out/2001 #
#############################################################################
# Alteracoes:                                                               #
#                                                                           #
# DATA        SOLICITACAO  RESPONSAVEL  DESCRICAO                           #
#---------------------------------------------------------------------------#
#                                                                           #
#############################################################################


 database porto

#------------------------------------
function cts00m32(l_socvclcod)
#------------------------------------

 define l_socvclcod  like dattfrotalocal.socvclcod

 define      l_dados record
   data      like dattfrotalocal.cttdat,
   hora      like dattfrotalocal.ctthor,
   atlemp    like dattfrotalocal.atlemp,
   atlmat    like dattfrotalocal.atlmat,
   atlusrtip like dattfrotalocal.atlusrtip,
   nome      char(30),
   srrcoddig like dattfrotalocal.srrcoddig,
   pstcoddig like dpaksocor.pstcoddig,
   nomrazsoc like dpaksocor.nomrazsoc,
   rspnom    like dpaksocor.rspnom,
   teltxt    like dpaksocor.teltxt
 end record

 define l_res   smallint,
        l_msg   char(40)

 let l_res = null
 let l_msg = null

 initialize l_dados.*  to  null

 let int_flag = false

 open window l_cts00m32 at 8,20 with form "cts00m32"
      attribute (border)

      ## Obtem os dados da dattfrotalocal
      call ctd10g00_dados_frotalocal(1, l_socvclcod)
           returning l_res, l_msg,
                     l_dados.srrcoddig,
                     l_dados.data,
                     l_dados.hora,
                     l_dados.atlemp,
                     l_dados.atlmat,
                     l_dados.atlusrtip

      ## Obtem o prestador atraves do socorrista
      call ctd11g00_inf_socor(1, l_dados.srrcoddig)
           returning l_res, l_msg, l_dados.pstcoddig

      ## Obtem dados do prestador
      call ctd12g00_dados_pst(1, l_dados.pstcoddig)
           returning l_res, l_msg,   l_dados.nomrazsoc,
                     l_dados.rspnom, l_dados.teltxt

      ## Obter nome do funcionario
      if l_dados.atlusrtip is null then
         let l_dados.atlusrtip = "F"
      end if

      call cty08g00_nome_func(l_dados.atlemp, l_dados.atlmat,
                              l_dados.atlusrtip)
           returning l_res, l_msg, l_dados.nome

      display by name l_dados.nome
      display by name l_dados.data
      display by name l_dados.hora
      display by name l_dados.pstcoddig
      display by name l_dados.nomrazsoc
      display by name l_dados.rspnom
      display by name l_dados.teltxt

      let int_flag = false
      prompt "(F17)Abandona" for char l_msg
      let int_flag = true

      clear form
      close window l_cts00m32

end function
