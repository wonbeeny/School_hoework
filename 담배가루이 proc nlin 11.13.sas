
/* 1. */
/*data 생성 */
proc import out = Temp 
datafile = 'C:\Users\user\Desktop\Dambe.xlsx'
DBMS = XLSX replace ;
run;

/* proc nlin 을 활용한 비선형 회귀선 구하기 */
proc nlin data = Temp METHOD=GAUSS ;
parms g = 1 h = 1 b = 1 ;
model cumulative_proportion= 1 - exp( -( (physiological_age - g) / h ) ** b ) ;
run; quit;


/* 2. */
/* Non linear regression line Graph */
proc glmselect data=Temp noprint;
  effect spl = spline(physiological_age / details naturalcubic basis=tpf(noint) knotmethod=percentiles(5) ) ;
  model cumulative_proportion = spl / selection=none ;
  output out=SplineOut predicted=Fit ;
run ; quit ;

proc sgplot data=SplineOut noautolegend;
   scatter x=physiological_age y=cumulative_proportion;
   series x=physiological_age  y=Fit / lineattrs=(thickness=3 color=red);
run; quit ;

/* Simple linear regression line Graph */
proc sgplot data=Temp ;
   scatter x=physiological_age y=cumulative_proportion ;
   reg x=physiological_age y=cumulative_proportion ;
   run; quit;

/* Time-series Graph */
symbol1 i=join v = circle c = black;
proc gplot data = Temp  ;
plot cumulative_proportion * physiological_age = 1  ;
run; quit;

