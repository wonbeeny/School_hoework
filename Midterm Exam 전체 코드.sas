/**** DATA 생성 ****/
data midterm ;
input HY_X Count_Y @@ ;
datalines;
0 8 1 18 1 15 1 23 0 5 1 13 0 4 1 19 1 33 1 119 0 10 1 22
0 2 1 18 0 18 1 21
;
run;

/** [1] 수평축을 X, 수직축을 Y으로 하는 산점도를 그려라. **/
proc sgplot data=midterm ;
scatter x=HY_X y=Count_Y ;
run;

/** [2] 선형모형을 이용한 단순회귀식을 proc reg 코드를 작성하고, 다음을 완성하라. **/
proc reg data=midterm ;
model Count_Y = HY_X ;
run;
* Count_Y = 7.83333 + 22.26667 * HY_X ;

/** 위 식을 얻기위한 OLS 의 다음 행렬과 벡터를 작성하라. **/

/** [3] 같은 자료를 아래와 같은 ~~ 작성하고, 다음을 완성하라. **/
proc nlin data=midterm METHOD=GAUSS ;
parameters beta0 = 2 to 3 by 0.5 beta1 = 0.8 to 1.8 by 0.5 ;
model Count_Y = exp(beta0 + beta1*HY_X) ;
run;

/** [4] 같은 자료를 포아송회귀모형을 이용해서 PROC GENMOD 를 이용한 코드를 작성하고, 다음을 완성하라. **/
proc genmod data=midterm ;
model Count_Y = HY_X / dist=poisson  link=log ;
run;

/** [6] 위 [5]번의 포아송회귀모형은 ~~ 작성하라. **/

/****** 초기값 선정시 오류가 난 case ******/

/*proc reg data=midterm plots = none noprint ;*/
/*model Count_Y = HY_X ;*/
/*output out = IRWLS_0 p = pred_0 ;*/
/*run;quit;*/

/*data IRWLS_0 ;*/
/*set IRWLS_0 ;*/
/*wt = 1;*/
/*Pseudo_Y = pred_0 + Count_Y / exp(pred_0) -1 ;*/
/*run;*/

/****** 이렇게 해주면 full rank가 아니라서 해가 여러개 존재하게 됩니다. 그래서 초기값을 임의로 선정했습니다. ******/

/****** 초기값 선정 ******/
/*초기값 : intercept : 0 , slope : 3*/

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
%macro do_IRWLS (num) ;

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

%do_IRWLS (3) ;

/* intercept : 3.92496 , slope : -0.52043 */


/* 9번 돌리면 수렴합니다. */
%do_IRWLS(9) ;

/* intercept : 2.05839 , slope : 1.34614 */
/* [4]에서 proc genmod 를 했을 때와 같은 결과를 가집니다. */


/** [7] 같은 자료를 음이항회귀를 이용하여 proc genmod로 작성하는 코드를 적어보고, 아래를 완성하라.. **/
proc genmod data=midterm ;
model Count_Y = HY_X / dist=poisson  link=log ;
run;

/* Pearson Chi-Square , Value/DF = 22.9717 */
/* Overdispersed Poisson because of (Value/DF > 1) */
/* We need to use Negative Binomial Regressiion !! */

proc genmod data=midterm ;
model Count_Y = HY_X / dist=negbin link=log ;
run;
/* Dispersion 의 Estimate = 0.4102 >0 이므로 Overdispersion 되었다는 걸 알 수 있다. */
/* Dispersion Estimate : variance parameter */
