###############################################################################
# Nome do Modulo: CTA00M00                                           Pedro    #
#                                                                    Marcelo  #
# Mostra todos convenios e registra convenio do atendimento(global)  Abr/1995 #
###############################################################################
#                                                                             #
#                          * * * Alteracoes * * *                             #
#                                                                             #
# Data       Autor Fabrica     Origem     Alteracao                           #
# ---------- ----------------- ---------- ------------------------------------#
# 22/07/2004 Robson, Meta      PSI183431  Alterado o nome do metodo, retornar #
#                              OSF036439  o cpocod selecionado com F8, inibir #
#                                         chamada do cta00m001.               #
#-----------------------------------------------------------------------------#

globals '/homedsa/projetos/geral/globals/glct.4gl'

database porto

define  m_prep_sql smallint

function cta00m00_prepare()

  define l_sql       char(300)
  let l_sql = "select cpodes              ",
              "from  datkdominio          ",
              "where cponom = ?           ",
              "and cpocod   =?            "
  prepare pcta00m00001 from l_sql
  declare ccta00m00001  cursor for pcta00m00001
  let m_prep_sql = true
end function

#-----------------------------------------------------------
 function cta00m00_convenios()                       
#-----------------------------------------------------------

 define a_cta00m00  array[60] of record
    cpodes          like datkdominio.cpodes,
    cpocod          like datkdominio.cpocod
 end record

 define arr_aux    integer
       ,l_retorno  like iddkdominio.cpocod
       ,l_cponom   like datkdominio.cponom           

	define	w_pf1	integer

	let	arr_aux   = null
   let   l_retorno = null
   let   l_cponom  = null                     

	for	w_pf1  =  1  to  60
		initialize  a_cta00m00[w_pf1].*  to  null
	end	for

 call cts14g02("N", "cta00m00")


 open window cta00m00 at 08,12 with form "cta00m00"
                      attribute(form line 1, border)

 let int_flag = false
 initialize  a_cta00m00   to null
 
 if g_documento.ciaempcod = 43 then
    let l_cponom = "ligcvntip_pss"
 else
    let l_cponom = "ligcvntip"          
 end if
 

 declare c_cta00m00_001    cursor for
   select  cpocod, cpodes
     from  datkdominio
     where cponom = l_cponom

 let arr_aux  = 1

 foreach c_cta00m00_001 into a_cta00m00[arr_aux].cpocod,
                             a_cta00m00[arr_aux].cpodes

    let arr_aux = arr_aux + 1
    if arr_aux  >  60   then
       error " Limite excedido, tabela de convenios com mais de 60 itens!"
       exit foreach
    end if

 end foreach


 message "     (F1)Ajuda, (F8)Seleciona, (F9)Procedimentos"
 call set_count(arr_aux-1)

 display array a_cta00m00 to s_cta00m00.*

    on key (interrupt,control-c,f17)
       initialize a_cta00m00   to null
       let l_retorno = null                           
       exit display

    #-------------------------------------------------------------------
    # Sistema de Ajuda e procedimentos
    #-------------------------------------------------------------------
    on key (F1)
       call cts14g02("N","cta00m00")

    on key (F8)
       let arr_aux = arr_curr()
       let l_retorno = a_cta00m00[arr_aux].cpocod     
       exit display

      on key (F9)
         let arr_aux = arr_curr()
         let l_retorno = a_cta00m00[arr_aux].cpocod   
         call ctn13c00(l_retorno)                     
         exit display

 end display

 close window  cta00m00
 close c_cta00m00_001

 let int_flag = false

 return l_retorno                                   

end function  

#-------------------------------------------
function cta00m00_recupera_convenio(lr_param)
#-------------------------------------------

define lr_param record
   cpocod like datkdominio.cpocod
end record

define lr_retorno record
   cpodes like datkdominio.cpodes,
   cponom like datkdominio.cponom
end record

initialize lr_retorno.* to null

 if m_prep_sql is null or
    m_prep_sql <> true then
    call cta00m00_prepare()
 end if   
 
 if g_documento.ciaempcod = 43 then
    let lr_retorno.cponom = "ligcvntip_pss"
 else
    let lr_retorno.cponom = "ligcvntip"          
 end if

 open ccta00m00001 using lr_retorno.cponom ,
                         lr_param.cpocod
 whenever error continue
 fetch ccta00m00001  into lr_retorno.cpodes
 whenever error stop
 close ccta00m00001
 return lr_retorno.cpodes

end function
