#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: Porto Socorro                                              #
# MODULO.........: ctd06g02                                                   #
# ANALISTA RESP..: Ligia Mattge                                               #
# PSI............: 211982                                                     #
# OBJETIVO.......: Obter o cgc/cpf atraves do nr da ligacao                   #
# ........................................................................... #
# DESENVOLVIMENTO: Luciano Lopes, META                                        #
# LIBERACAO......: 18/09/2007                                                 #
# ........................................................................... #
#                                                                             #
#                          * * * ALTERACOES * * *                             #
#                                                                             #
# DATA       AUTOR FABRICA      ORIGEM     ALTERACAO                          #
# ---------- ------------------ ---------- -----------------------------------#
#                                                                             #
#-----------------------------------------------------------------------------#
database porto                                                                 

define m_ctd06g02_prep smallint

#---------------------------#
function ctd06g02_prepare()
#---------------------------#
   define l_sql_stmt  char(500)

   let l_sql_stmt = " select cgccpfnum, cgcord, cgccpfdig " 
                   ,"   from datrligcgccpf                "
                   ,"   where lignum = ?                  "

   prepare pctd06g02001 from l_sql_stmt
   declare cctd06g02001 cursor for pctd06g02001
   
   let m_ctd06g02_prep = true
end function

#-----------------------------------------#
function ctd06g02_ligacao_cgccpf(lr_param)
#-----------------------------------------#
   define lr_param         record
          lignum           like datrligcgccpf.lignum
   end record

   define lr_retorno       record
             resultado     smallint
            ,mensagem      char(60)
            ,cgccpfnum     like datrligcgccpf.cgccpfnum 
            ,cgcord        like datrligcgccpf.cgcord 
            ,cgccpfdig     like datrligcgccpf.cgccpfdig
   end record

   if m_ctd06g02_prep is null or
      m_ctd06g02_prep <> true then
      call ctd06g02_prepare()
   end if
   
   initialize lr_retorno to null
   let lr_retorno.resultado  = 1
  
   open cctd06g02001 using lr_param.lignum

   whenever error continue
   fetch cctd06g02001 into lr_retorno.cgccpfnum
                          ,lr_retorno.cgcord   
                          ,lr_retorno.cgccpfdig
   whenever error stop

   if sqlca.sqlcode <> 0 then
      if sqlca.sqlcode = notfound then
         let lr_retorno.resultado = 2
         let lr_retorno.mensagem = "Nao achou ligacao cadastrada: " , lr_param.lignum 
      else
         let lr_retorno.resultado = 3
         let lr_retorno.mensagem = "Erro no acesso a tabela datrligcgccpf: ", sqlca.sqlcode
      end if
   end if
   
   return lr_retorno.resultado
         ,lr_retorno.mensagem
         ,lr_retorno.cgccpfnum
         ,lr_retorno.cgcord
         ,lr_retorno.cgccpfdig
end function
