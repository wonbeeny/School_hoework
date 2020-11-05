/**** DATA ���� ****/
data midterm ;
input HY_X Count_Y @@ ;
datalines;
0 8 1 18 1 15 1 23 0 5 1 13 0 4 1 19 1 33 1 119 0 10 1 22
0 2 1 18 0 18 1 21
;
run;

/** [1] �������� X, �������� Y���� �ϴ� �������� �׷���. **/
proc sgplot data=midterm ;
scatter x=HY_X y=Count_Y ;
run;

/** [2] ���������� �̿��� �ܼ�ȸ�ͽ��� proc reg �ڵ带 �ۼ��ϰ�, ������ �ϼ��϶�. **/
proc reg data=midterm ;
model Count_Y = HY_X ;
run;
* Count_Y = 7.83333 + 22.26667 * HY_X ;

/** �� ���� ������� OLS �� ���� ��İ� ���͸� �ۼ��϶�. **/

/** [3] ���� �ڷḦ �Ʒ��� ���� ~~ �ۼ��ϰ�, ������ �ϼ��϶�. **/
proc nlin data=midterm METHOD=GAUSS ;
parameters beta0 = 2 to 3 by 0.5 beta1 = 0.8 to 1.8 by 0.5 ;
model Count_Y = exp(beta0 + beta1*HY_X) ;
run;

/** [4] ���� �ڷḦ ���Ƽ�ȸ�͸����� �̿��ؼ� PROC GENMOD �� �̿��� �ڵ带 �ۼ��ϰ�, ������ �ϼ��϶�. **/
proc genmod data=midterm ;
model Count_Y = HY_X / dist=poisson  link=log ;
run;

/** [6] �� [5]���� ���Ƽ�ȸ�͸����� ~~ �ۼ��϶�. **/

/****** �ʱⰪ ������ ������ �� case ******/

/*proc reg data=midterm plots = none noprint ;*/
/*model Count_Y = HY_X ;*/
/*output out = IRWLS_0 p = pred_0 ;*/
/*run;quit;*/

/*data IRWLS_0 ;*/
/*set IRWLS_0 ;*/
/*wt = 1;*/
/*Pseudo_Y = pred_0 + Count_Y / exp(pred_0) -1 ;*/
/*run;*/

/****** �̷��� ���ָ� full rank�� �ƴ϶� �ذ� ������ �����ϰ� �˴ϴ�. �׷��� �ʱⰪ�� ���Ƿ� �����߽��ϴ�. ******/

/****** �ʱⰪ ���� ******/
/*�ʱⰪ : intercept : 0 , slope : 3*/

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

/* 3�� ������ �� */
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


/* 9�� ������ �����մϴ�. */
%do_IRWLS(9) ;

/* intercept : 2.05839 , slope : 1.34614 */
/* [4]���� proc genmod �� ���� ���� ���� ����� �����ϴ�. */


/** [7] ���� �ڷḦ ������ȸ�͸� �̿��Ͽ� proc genmod�� �ۼ��ϴ� �ڵ带 �����, �Ʒ��� �ϼ��϶�.. **/
proc genmod data=midterm ;
model Count_Y = HY_X / dist=poisson  link=log ;
run;

/* Pearson Chi-Square , Value/DF = 22.9717 */
/* Overdispersed Poisson because of (Value/DF > 1) */
/* We need to use Negative Binomial Regressiion !! */

proc genmod data=midterm ;
model Count_Y = HY_X / dist=negbin link=log ;
run;
/* Dispersion �� Estimate = 0.4102 >0 �̹Ƿ� Overdispersion �Ǿ��ٴ� �� �� �� �ִ�. */
/* Dispersion Estimate : variance parameter */
