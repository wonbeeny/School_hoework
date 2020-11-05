/** [6]  위 [5]번의 포아송회귀모형은 SAS 의 매크로 프로그램과  PROC REG 의 WEIGHT 문을 활용하여 3번 의 iteration 으로 IRWLS 알고리즘으로 추정치를 구하는 SAS 프로그램을 작성하라. (파일로 제출할 것) **/

/**** DATA 생성 ****/
data midterm ;
input HY_X Count_Y @@ ;
datalines;
0 8 1 18 1 15 1 23 0 5 1 13 0 4 1 19 1 33 1 119 0 10 1 22
0 2 1 18 0 18 1 21
;
run;

/****** 초기값 선정시 오류가 난 case ******/

/*		proc reg data=midterm plots = none noprint ;				*/
/*		model Count_Y = HY_X ;												*/
/*		output out = IRWLS_0 p = pred_0 ;								*/
/*		run ;quit ;																		*/

/*		data IRWLS_0 ;																*/
/*		set IRWLS_0 ;																*/
/*		wt = 1;																	    	*/
/*		Pseudo_Y = pred_0 + Count_Y / exp(pred_0) -1 ;		*/
/*		run ;																				*/

/******   이렇게 해주면 full rank가 아니라서 해가 여러개 존재하게 됩니다. 그래서 초기값을 임의로 선정했습니다.   ******/

/******   초기값 선정   ******/
/*		초기값 : intercept : 0 ,   slope : 3		*/

data IRWLS_0 ;
set midterm ;
wt = 1;
Pseudo_Y = 0 + 3 * HY_X + Count_Y / exp(0 + 3 * HY_X) -1 ;
run;

proc reg data = IRWLS_0 plots = none noprint ;
model  Pseudo_Y = HY_X ;
output out = IRWLS_0 p = pred_0 ;
run;quit;


/****** macro ******/

/* 3번 돌렸을 때 */
%macro do_IRWLS (num);

%do i=1 %to &num ;

data IRWLS_&i. ;
set IRWLS_%eval(&i.-1) ;
Pseudo_Y = pred_%eval(&i.-1) + Count_Y / exp(pred_%eval(&i.-1)) -1 ;
wt = exp(pred_%eval(&i.-1)) ;
run;

proc reg data = IRWLS_&i. plots = none ;
model Pseudo_Y = HY_X ;
weight wt ;
output out = IRWLS_tmp_&i. p = pred_&i. ;
run; quit ;

data IRWLS_&i. ;
set IRWLS_tmp_&i. ;
run;

%end;
%mend do_IRWLS ;

%do_IRWLS(3) ;

/*		intercept : 3.92496 ,   slope : -0.52043		*/


/* 9번 돌리면 수렴합니다. */
%do_IRWLS(9) ;

/*		intercept : 2.05839 ,   slope : 1.34614		*/
/* [4]에서 proc genmod 를 했을 때와 같은 결과를 가집니다. */
