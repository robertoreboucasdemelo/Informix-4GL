###############################################################################
# Nome do Modulo: CTS11G00                                           Marcelo  #
#                                                                    Gilberto #
# Exibicao das informacoes da digitacao do formulario                Nov/1998 #
###############################################################################

 database porto

define m_prep smallint

function cts11g00_prepare()

define l_sql char(300)

   let l_sql = "select count(*) ",
               " from datmligfrm ",
               " where lignum = ? "
   prepare p_cts11g00_001 from l_sql
   declare c_cts11g00_001 cursor with hold for p_cts11g00_001
  let m_prep = true

end function

#-----------------------------------------------------------
 function cts11g00(param)
#-----------------------------------------------------------

 define param        record
    lignum           like datmligfrm.lignum
 end record

 define d_cts11g00   record
    caddat           like datmligfrm.caddat,
    cadhor           like datmligfrm.cadhor,
    cademp           like datmligfrm.cademp,
    cadmat           like datmligfrm.cadmat,
    cadnom           like isskfunc.funnom
 end record

 define prompt_key   char (01)


	let	prompt_key  =  null

	initialize  d_cts11g00.*  to  null

 let int_flag  =  false
 initialize d_cts11g00.*  to null

 select caddat, cadhor,
        cademp, cadmat
   into d_cts11g00.caddat,
        d_cts11g00.cadhor,
        d_cts11g00.cademp,
        d_cts11g00.cadmat
   from datmligfrm
  where lignum = param.lignum

 if sqlca.sqlcode = notfound  then
    return
 else
    if sqlca.sqlcode < 0  then
       error " Erro (", sqlca.sqlcode, ") na localizacao dos dados do responsavel pela digitacao. AVISE A INFORMATICA!"
       return
    end if
 end if

 let d_cts11g00.cadnom = "** NAO CADASTRADO **"

 select funnom
   into d_cts11g00.cadnom
   from isskfunc
  where empcod = d_cts11g00.cademp  and
        funmat = d_cts11g00.cadmat

 let d_cts11g00.cadnom = upshift(d_cts11g00.cadnom)

 open window cts11g00 at 13,24 with form "cts11g00"
                         attribute (border, form line 1)

 display by name d_cts11g00.*

 prompt " (F17)Abandona" for char prompt_key

 close window cts11g00
 let int_flag = false

end function  ###  cts11g00

function cts11g00_verifica_formulario(lr_param)


  define lr_param record
       lignum like datmligacao.lignum
  end record
  define l_count integer,
         l_ret   smallint
  let l_count = 0
  let l_ret = false
  if m_prep is null or
     m_prep = false then
     call cts11g00_prepare()
  end if
  whenever error continue
  open c_cts11g00_001 using lr_param.lignum
  fetch c_cts11g00_001 into l_count
  whenever error stop
  if sqlca.sqlcode <> 0 then
     error " Erro (", sqlca.sqlcode, ") ao localizar a ligacao na tabela DATMLIGFRM. AVISE A INFORMATICA!"
  end if
  close c_cts11g00_001
  if l_count > 0 then
     let l_ret = true
  end if
  return l_ret
end function
