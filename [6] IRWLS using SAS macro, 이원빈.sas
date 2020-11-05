/** [6]  �� [5]���� ���Ƽ�ȸ�͸����� SAS �� ��ũ�� ���α׷���  PROC REG �� WEIGHT ���� Ȱ���Ͽ� 3�� �� iteration ���� IRWLS �˰������� ����ġ�� ���ϴ� SAS ���α׷��� �ۼ��϶�. (���Ϸ� ������ ��) **/

/**** DATA ���� ****/
data midterm ;
input HY_X Count_Y @@ ;
datalines;
0 8 1 18 1 15 1 23 0 5 1 13 0 4 1 19 1 33 1 119 0 10 1 22
0 2 1 18 0 18 1 21
;
run;

/****** �ʱⰪ ������ ������ �� case ******/

/*		proc reg data=midterm plots = none noprint ;				*/
/*		model Count_Y = HY_X ;												*/
/*		output out = IRWLS_0 p = pred_0 ;								*/
/*		run ;quit ;																		*/

/*		data IRWLS_0 ;																*/
/*		set IRWLS_0 ;																*/
/*		wt = 1;																	    	*/
/*		Pseudo_Y = pred_0 + Count_Y / exp(pred_0) -1 ;		*/
/*		run ;																				*/

/******   �̷��� ���ָ� full rank�� �ƴ϶� �ذ� ������ �����ϰ� �˴ϴ�. �׷��� �ʱⰪ�� ���Ƿ� �����߽��ϴ�.   ******/

/******   �ʱⰪ ����   ******/
/*		�ʱⰪ : intercept : 0 ,   slope : 3		*/

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


/* 9�� ������ �����մϴ�. */
%do_IRWLS(9) ;

/*		intercept : 2.05839 ,   slope : 1.34614		*/
/* [4]���� proc genmod �� ���� ���� ���� ����� �����ϴ�. */
