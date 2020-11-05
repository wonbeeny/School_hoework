data USPopulation ;
input Population @@ ;
retain Year 1780 ;
retain t 0 ;
Year = Year + 10 ;
YearSq = Year * Year ;
t = t + 1 ;
Population = Population / 1000 ;
datalines ;
3929 5308 7239 9638 12866 17069 23191 31443 39818 50155
62947 75994 91972 105710 122775 131669 151325 179323 203211
226542 248710 281422
;
run;

proc sgplot data = USPopulation ;
scatter x=Year y=Population ;
run;

proc sgplot data = USPopulation ;
scatter x=t y=Population ;
run;


proc nlin data=USPopulation METHOD=GAUSS ;
parameters beta1=0 to 2 by 0.5 beta2=0 to 2 by 0.5 beta3=0 to 2 by 0.5;
model Population = beta1 / ( 1+exp(beta2 + beta3*t) ) ;
run;
