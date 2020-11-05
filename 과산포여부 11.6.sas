data Artisan;
input defect person $ @@;
cards;
12 A 24 A 12 A 32 A 22 A 21 A 21 A
12 B 32 B 32 B 23 B 21 B 22 B 12 B 32 B
12 C 34 C 43 C 34 C 23 C 22 C
;
run;

/* Q1. 포아송회귀를 수행해서 과산포인지 판단하라 */
proc genmod data = Artisan;
class person ;
model defect = person / dist = poi link = log ;
run;

/* Q2. 수직축을 분산, 수평축을 평균으로 과산포 여부를 판단하라 */
proc means data = Artisan ;
class person;
output out = OVD_test mean = mean_X var = var_Y ;
run;

proc print data = OVD_test ;
run;

data X_Y;
input X Y @@;
cards;
1 1 49 49 70 70 123 123
;
run;

data OVD_test_new ;
set OVD_test ;
set X_Y ;
run;

proc sgplot data = OVD_test_new  ;
scatter x = mean_X y = var_Y / group = person ;
reg x = X y = Y  ;
run;

/* Q3. 음이항회귀를 수행해서 과산포 여부를 판단하라 */
proc genmod data = Artisan;
class person ;
model defect = person / dist = negbin link = log ;
run;
