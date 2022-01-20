function subtrai_datas( data1, data2 ) {

  var dias = 0;

  var dia1 = 0;
  var dia2 = 0;
  var mes1 = 0;
  var mes2 = 0;
  var ano1 = 0;
  var ano2 = 0;

  var anos = 0;
  var meses ;
  var i= 0 ;

  var dias_ano = 365;

  var diasNoMes = new Array( 0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

  dia1 = data1.substring( 0, 2 );
  dia2 = new Number(data2.substring( 0, 2 ));
  mes1 = data1.substring( 3, 5 );
  mes2 = data2.substring( 3, 5 );
  ano1 = data1.substring( 6, 10 );
  ano2 = data2.substring( 6, 10 );

  anos = ano2 - ano1;

  if (anos > 0) {

     // Calculo do 1º ano do intervalo
     meses = 12 - mes1;
     for (i=parseInt(mes1) + 1 ; i<=12 ; i++){
       dias = dias + diasNoMes[i];
     }

     if (mes1 <=2) {
       dias = dias + dias_Fevereiro(ano1);
     }

     dias = dias + diasNoMes[parseInt(mes1)] - dia1;

     // Calculo dos anos intermediarios
     for (i=parseInt(ano1)+1; i< ano2; i++){
      dias = dias + dias_ano + dias_Fevereiro(i) ;
     }

     // Calculo do ultimo ano
     for (i=1 ; i<mes2 ; i++){
       dias = dias + diasNoMes[i];
     }

     if (mes2 >1) {
       dias = dias + dias_Fevereiro(ano2);
     }

     dias = parseInt(dias) + parseInt(dia2);

  }
  else {
    meses = mes2 - mes1;

    if ( meses > 0){
        for (i=parseInt(mes1)+ 1 ; i<= parseInt(mes2) - 1 ; i++){
        //alert ('mes ' + i );
        dias = dias + diasNoMes[i];
        //alert (dias);
      }
      //Soma primeiro mes
      dias = parseInt(dias) + parseInt(diasNoMes[parseInt(mes1)]) - dia1;
      //Soma ultimo mes
      dias = parseInt(dias) + parseInt(dia2);
      if (mes1 >= 1) {
       dias = dias + dias_Fevereiro(ano1);
     }
    }
    else {
        dias = dia2 - dia1;
    }
  }
    return dias;
}

function dias_Fevereiro( ano ) {
  /* Fevereiro tem 29 dias em qualquer ano divisivel por quatro,
     EXCETO para anos de seculos que nao sao divisiveis por 400. */
  return ( ((ano % 4 == 0) && ( (!(ano % 100 == 0)) || (ano % 400 == 0) ) ) ? 1 : 0 );
}
