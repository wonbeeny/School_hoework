/* data 불러오기 */
proc import datafile = "C:\Users\WonBeen\Desktop\xydata.xlsx"  out = xydata dbms = xlsx replace ;
getnames = yes ;
run;

/* (1-1) 산점도 */
title "산점도" ;
proc sgplot data = xydata ;
scatter x = x y = y ;
run;

/* (1-2) 상자그림 */
title "상자그림" ;
proc sgplot data = xydata ;
vbox y / category = x ;
run;

/* (1-3) 히스토그램 */
title "히스토그램" ;
proc sgplot data = xydata ;
histogram y / group = x transparency = 0.3 ;
run;

/* (1-4) proc sgplot의 히스토그램으로 y값을 7등분 하여 group = 1, 2, ... , 7의 수치를 부여 */
data xydata_group;
set xydata ;
if y>=0 & y<5.5 then i=1 ;
if y>=5.5 & y<11 then i=2 ;
if y>=11 & y<16.5 then i=3 ;
if y>=16.5 & y<22 then i=4 ;
if y>=22 & y<26.5 then i=5 ;
if y>=26.5 & y<33 then i=6 ;
if y>=33 & y<38.5 then i=7 ;
run;

/* (1-4-1) group의 오름차순  */
proc sort data = xydata_group out = xydata_group_sort ;
by i y ;
run; 

/* (1-4-2) 그룹당 y의 평균값 계산 */
title "group별 y의 평균값" ;
proc means data = xydata_group_sort mean ;
var y ;
class i ;
output out = y_mean mean = y_i_bar ;
run;

/* (1-5) proc nlin을 이용한 group당 s^2 계산 */
title "";
proc nlin data = xydata_group_sort ;
output out = residual residual = res2 ;
parameters beta0 = 2 beta1 = 1 ;
model y = exp(beta0 + beta1 * x) ;
run;

data residual ;
set residual ;
res2 = res2 * res2 ;
run;

title "group별 잔차 제곱 평균 계산" ;
proc means data = residual mean ;
var res2 ;
class i ;
output out = s2_maen mean = s_square ;
run;

/* (1-6) group별 x-axis=y 평균, y-axis=잔차제곱평균 */
data y_s2_plot ;
set y_mean ;
set s2_maen ;
run;

title "group별 산점도" ;
proc sgplot data = y_s2_plot ;
scatter x = y_i_bar y = s_square / group = i datalabel = i ;
run;

/* (2-1) 각 모형의 적합도 검정 */

/* poisson regression */
title "poisson regression";
proc genmod data=xydata ;
model y = x / dist=poisson  link=log ;
run;

/* negative binomial regression */
title "negative binomial regression";
proc genmod data=xydata ;
model y = x / dist=negbin link=log ;
run;

/* overdispersed poisson regression */
title "overdispersed poisson regression";
proc genmod data=xydata ;
model y = x / dist=poisson  link=log DSCALE;
run;

/* zero-inflated poisson regression */
title "zero-inflated poisson regression";
proc countreg data = xydata ;
model y = x / dist = zip ;
zeromodel y ~ x ;
run;

/* [4] 산점도 */
data scatter_plot ;
set xydata ;
by x;
PO_E_y = exp(2.6596 - 2.1355 * x) ;
PO_V_y = exp(2.6596 - 2.1355 * x) ;
OP_E_y = exp(2.6596 - 2.1355 * x) ;
OP_V_y = 7.4217 * exp(2.6596 - 2.1355 * x) ;
NB_E_y = exp(2.6596 - 2.1355 * x) ;
NB_V_y = exp(2.6596 - 2.1355 * x) + 2.7671 * exp(2.6596 - 2.1355 * x) * exp(2.6596 - 2.1355 * x) ;
ZIP_E_y = exp(2.6596 - 0.8504 * x) * (1 - exp(-56.2405+57.2018*x)/(1+exp(-56.2405+57.2018*x))) ;
ZIP_V_y = exp(2.6596 - 0.8504 * x) * (1 - exp(-56.2405+57.2018*x)/(1+exp(-56.2405+57.2018*x))) * (1 + exp(-56.2405+57.2018*x)/(1+exp(-56.2405+57.2018*x)) * exp(2.6596 - 0.8504 * x)) ;
run;

data new ;
set scatter_plot  y_s2_plot ;
run;

title "model sgplot";
proc sgplot data = new ;
yaxis label = 'Variance';
xaxis label = 'Expected value';
loess    x = PO_E_y y = PO_V_y / degree=2 lineattrs=(color=red) nomarkers legendlabel = 'PO' ;
loess    x = OP_E_y y = OP_V_y / degree=2 lineattrs=(color=green) nomarkers legendlabel = 'OP' ;
loess    x = NB_E_y y = NB_V_y / degree=2 lineattrs=(color=blue) nomarkers legendlabel = 'NB';
loess    x = ZIP_E_y y = ZIP_V_y / degree=2 lineattrs=(color=black) nomarkers legendlabel = 'ZIP';
scatter x = y_i_bar y = s_square ;
run;

/* (4-2) */
title "model sgplot";
proc sgplot data = new ;
yaxis label = 'Variance';
xaxis label = 'Expected value';
loess    x = PO_E_y y = PO_V_y / degree=2 lineattrs=(color=red) nomarkers legendlabel = 'PO' ;
loess    x = OP_E_y y = OP_V_y / degree=2 lineattrs=(color=green) nomarkers legendlabel = 'OP' ;
loess    x = ZIP_E_y y = ZIP_V_y / degree=2 lineattrs=(color=black) nomarkers legendlabel = 'ZIP';
scatter x = y_i_bar y = s_square ;
run;


proc sort data = xydata ;
by y ;
run;

proc freq data = xydata ;
by y ;
run;
