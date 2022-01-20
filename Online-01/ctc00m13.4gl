#-----------------------------------------------------------------------------#
# PORTO SEGURO CIA SEGUROS GERAIS                                             #
# ........................................................................... #
# SISTEMA........: PORTO SOCORRO - CENTRAL 24H                                #
# MODULO.........: CTC00M13                                                   #
# ANALISTA RESP..: Priscila Staingel                                          #
# PSI/OSF........: 197858 - Melhorias no Portal de negocios.                  #
#                  Manter Historico Prestador                                 #
# ........................................................................... #
# DESENVOLVIMENTO: PRISCILA STAINGEL                               29/06/2006 #
# ........................................................................... #
#                                                                             #
#                           * * * ALTERACOES * * *                            #
#                                                                             #
# DATA       AUTOR FABRICA   ORIGEM     ALTERACAO                             #
# ---------- --------------  ---------- ------------------------------------- #
# 03/09/2008  Norton-Meta               Qtde linhas do array de 200 p/ 1000   #
#-----------------------------------------------------------------------------#

globals "/homedsa/projetos/geral/globals/glct.4gl"

database porto

 define d_ctc00m13 record
    caddat         like dbsmhstprs.caddat,
    cadmat         like dbsmhstprs.cadmat,
    cademp         like dbsmhstprs.cademp,
    cadusrtip      like dbsmhstprs.cadusrtip,
    prshstdes      like dbsmhstprs.prshstdes
 end record
 
 define a_linha  array[1000] of record
    texto          char(70)
 end record
 
 
 define m_prep_sql       smallint

#----------------------------------------------
function ctc00m13_prepare()
#----------------------------------------------
 define l_sql    char(5000)
 
 let l_sql = "select caddat, cadmat, cademp, cadusrtip, prshstdes "
            ," ,dbsseqcod                      "
            ," from dbsmhstprs                 "
            ," where pstcoddig = ?             "
            ," order by caddat desc, dbsseqcod  " 
 prepare pctc00m13001 from l_sql
 declare cctc00m13001 cursor for pctc00m13001      
 
 let l_sql = "select funnom "
            ," from isskfunc "
            ," where funmat = ? " 
            ,"   and empcod = ? "
            ,"   and usrtip = ? "     
 prepare pctc00m13002 from l_sql
 declare cctc00m13002 cursor for pctc00m13002   

  let l_sql = "insert into dbsmhstprs (pstcoddig, dbsseqcod, "
             ," prshstdes, caddat, cademp, cadusrtip, cadmat)"
             ," values(?,?,?,?,?,?,?) "
 prepare pctc00m13003 from l_sql
 
 let l_sql = "select max(dbsseqcod) "
            ," from dbsmhstprs      "
            ," where pstcoddig = ?  "
 prepare pctc00m13004 from l_sql
 declare cctc00m13004 cursor for pctc00m13004      
 
 let l_sql = "select nomgrr "
            ," from dpaksocor      "
            ," where pstcoddig = ?  "
 prepare pctc00m13005 from l_sql
 declare cctc00m13005 cursor for pctc00m13005    

 let m_prep_sql = true

end function


#---------------------------------------------------------------
 function ctc00m13(k_ctc00m13)
#---------------------------------------------------------------

 define k_ctc00m13 record
     pstcoddig    like dbsmhstprs.pstcoddig
 end record

 define l_nomgrr       like dpaksocor.nomgrr
 
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc00m13_prepare()
   end if

 open cctc00m13005 using k_ctc00m13.pstcoddig
 fetch cctc00m13005 into l_nomgrr
 
 #abre janela
 open window w_ctc00m13 at 04,02 with form "ctc00m13"
   attributes(form line 1, message line last - 1)

 #exibe codigo e nome prestador na tela
 display k_ctc00m13.pstcoddig to pstcoddig
 display l_nomgrr             to nomgrr
 
 #menu
 menu "HISTORICO"
      command "Implementa"
              "Insere um novo item de historico para o prestador selecionado"
              call ctc00m13_implementa(k_ctc00m13.pstcoddig)
      
      command "Consulta"
              "Consulta historico do prestador selecionado"
              call ctc00m13_consulta(k_ctc00m13.pstcoddig)
      
      command key (interrupt,E) "Encerra"
              "Retorna ao menu anterior"
              exit menu
      
 end menu

 close window w_ctc00m13

end function       
 
#---------------------------------------------------------------
function ctc00m13_consulta(l_pstcoddig)
#---------------------------------------------------------------
   define l_pstcoddig  like dbsmhstprs.pstcoddig
   
   define l_data_antes   like dbsmhstprs.caddat
   define l_cadmat_antes like dbsmhstprs.cadmat
   define l_dbsseqcod    like dbsmhstprs.dbsseqcod
   define l_aux_linha    smallint
   define l_aux          smallint
   define l_nome         like isskfunc.funnom
   
   let l_data_antes = null
   let l_cadmat_antes = null
   let l_aux_linha = 0
   let l_aux = 0
   let l_nome = null
   
   initialize  d_ctc00m13.*  to  null
   initialize  a_linha  to  null
 
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc00m13_prepare()
   end if
   
   open cctc00m13001 using l_pstcoddig
   foreach cctc00m13001 into d_ctc00m13.caddat, 
                             d_ctc00m13.cadmat, 
                             d_ctc00m13.cademp, 
                             d_ctc00m13.cadusrtip,
                             d_ctc00m13.prshstdes,
                             l_dbsseqcod
         if l_data_antes is null or                   #caso seja o 1º registro lido
            l_data_antes <> d_ctc00m13.caddat or      #ou seja um outro registro (outra data)
            l_cadmat_antes <> d_ctc00m13.cadmat then  #ou seja mesma data mas com outra matricula
            let a_linha[l_aux_linha].texto = ""
            let l_aux_linha = l_aux_linha + 1
            #encontrou registros de outra data
            open cctc00m13002 using d_ctc00m13.cadmat, 
                                    d_ctc00m13.cademp,
                                    d_ctc00m13.cadusrtip
            fetch cctc00m13002 into l_nome                  
            let a_linha[l_aux_linha].texto = "Em: ", d_ctc00m13.caddat,
                                             " Por: ", l_nome
            let l_aux_linha = l_aux_linha + 1
         end if   
         let a_linha[l_aux_linha].texto = d_ctc00m13.prshstdes
         let l_aux_linha = l_aux_linha + 1
         let l_data_antes = d_ctc00m13.caddat
         let l_cadmat_antes = d_ctc00m13.cadmat
         initialize d_ctc00m13.* to null
         if l_aux_linha > 1000 then
            error "Historico estourou o permitido em tela"
            exit foreach
         end if
   end foreach

   call set_count(l_aux_linha)
   
   display array a_linha to s_ctc00m13.*

      on key(f17,control-c,interrupt)
         exit display

   end display

end function


#---------------------------------------------------------------
function ctc00m13_implementa(l_pstcoddig)
#---------------------------------------------------------------
   define l_pstcoddig  like dbsmhstprs.pstcoddig
   
   define arr_aux   smallint,
          scr_aux   smallint,
          l_dbsseqcod   like dbsmhstprs.dbsseqcod
          
   define l_hora datetime hour to minute    
   
   let arr_aux = null
   let scr_aux = null
   let l_dbsseqcod = 0
   initialize  d_ctc00m13.*  to  null
   initialize  a_linha  to  null
   
   if m_prep_sql is null or
      m_prep_sql <> true then
      call ctc00m13_prepare()
   end if   
   
   #carrega dados fixos
   call cts40g03_data_hora_banco(2)
       returning d_ctc00m13.caddat, l_hora 
   let d_ctc00m13.cadmat = g_issk.funmat
   let d_ctc00m13.cademp = g_issk.empcod
   let d_ctc00m13.cadusrtip = g_issk.usrtip

   while true
       input array a_linha without defaults from s_ctc00m13.*
          before row
             let arr_aux = arr_curr()
             let scr_aux = scr_line()
       
          before field prshstdes
             display a_linha[arr_aux].texto to
                     s_ctc00m13[scr_aux].prshstdes attribute (reverse)
       
          after field prshstdes
             display a_linha[arr_aux].texto to
                     s_ctc00m13[scr_aux].prshstdes
       
             if fgl_lastkey() = fgl_keyval("left")  or
                fgl_lastkey() = fgl_keyval("up")    then
                error " Alteracoes e/ou correcoes nao sao permitidas!"
                next field prshstdes
             else
                if a_linha[arr_aux].texto is null  or
                   a_linha[arr_aux].texto =  "  "  then
                   error " Complemento deve ser informado!"
                   next field prshstdes
                end if
             end if
       
          on key (interrupt)
             exit input
       
          after row
             if a_linha[arr_aux].texto is null  or
                a_linha[arr_aux].texto =  "  "  then
                display "texto não foi digitado"
                next field prshstdes
             else
                #Buscar ultimo item de histórico cadastrado para o prestador
                open cctc00m13004 using l_pstcoddig 
                fetch cctc00m13004 into l_dbsseqcod
                
                if l_dbsseqcod is null or
                   l_dbsseqcod = 0 then
                   let l_dbsseqcod = 1
                else
                   let l_dbsseqcod = l_dbsseqcod + 1
                end if

                let d_ctc00m13.prshstdes = a_linha[arr_aux].texto

                # Grava HISTORICO do servico  
                execute pctc00m13003 using l_pstcoddig,
                                           l_dbsseqcod,
                                           d_ctc00m13.prshstdes,
                                           d_ctc00m13.caddat,
                                           d_ctc00m13.cademp,
                                           d_ctc00m13.cadusrtip,
                                           d_ctc00m13.cadmat
                if sqlca.sqlcode <> 0  then
                    error "Erro (", sqlca.sqlcode, ") na inclusao do historico. ",
                          "Favor re-digitar a linha."
                    next field prshstdes
                end if
             end if   
           
       end input
       
       if int_flag  then
          exit while
       end if
   
   end while   
   
end function
