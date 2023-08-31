*Input file: adams.adamsa, HRS.rndHRS_p, HRS.sasfmts
*output file: n.HRS_ADAMSA_All
*Creating the adams wave variable from hrs waves 5 and 6;

libname HRS "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS";
libname sas "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/SAS";
libname adams "/schaeffer-a/sch-data-library/dua-data/HRS/Sensitive/Adams/Sas";
libname n "/schaeffer-a/sch-projects/dua-data-projects/HRS_Sensitive/nfouladi/ADAMS";

*to run the formats for HRS;
proc format cntlin=HRS.sasfmts cntlout=formats; 
run;

*keeping only interview dates from wave 5 and 6 to match with adams wave A;
data HRS;
	set HRS.rndHRS_p (keep= HHIDPN R5IWEND R6IWEND);
				
run;

*keeping the year and month variables to create an interview date for adams wave A;
data ADAMSa;
	set adams.adamsa (keep= HHIDPN AYEAR AMONTH) ;
run;

*merging;
proc sort data=HRS;
by HHIDPN;
run;

proc sort data=ADAMSa;
by HHIDPN;
run;

data ADAMS_HRS;
	merge HRS (in=a) ADAMSa (in=b);
	by HHIDPN;

	HRS=a;
	ADAMSa=b;
run;

data ADAMS_HRS;
	set ADAMS_HRS;
	where HRS=1 and ADAMSa=1;
run;

*check;
proc print data=ADAMS_HRS (obs=5);
var HHIDPN R5IWEND R6IWEND ayear amonth;
run;

proc print data=ADAMS_HRS;
var ayear;
where ayear =9997;
run;

*creating adamsdt;
data ADAMS_HRS_a;
	set ADAMS_HRS;

	if ayear ne 9997 then adamsdt=mdy(amonth, 15, ayear);
	format adamsdt mmddyy10.;
	format R5IWEND mmddyy10.;
	format R6IWEND mmddyy10.;
run;

proc print data=ADAMS_HRS_a;
where adamsdt=.;
var adamsdt;
run;

data ADAMS_HRS_b;
	set ADAMS_HRS_a;
	if adamsdt=. then delete;
run;

proc print data=ADAMS_HRS_b (obs=15);
var HHIDPN R5IWEND R6IWEND ayear amonth adamsdt;
run;

data ADAMS_HRS_b;
	set ADAMS_HRS_b;
	date15=abs(adamsdt-R5IWEND); 
	date16=abs(adamsdt-R6IWEND);
run;

proc print data=ADAMS_HRS_b (obs=5);
var HHIDPN R5IWEND R6IWEND adamsdt date15 date16;
run;

data ADAMS_HRS_c;
	set ADAMS_HRS_b;

	date1=.;
	if (date15<date16 or date15=date16) and date15 ne . then date1=date15;
	if date16<date15 and date16 ne . then date1=date16;
run;

*filling the missings;
data ADAMS_HRS_d;
	set ADAMS_HRS_c;
	
	if date1 = . then do;
	if date16=. and date15 ne . then date1=date15;
	if date15=. and date16 ne . then date1=date16;
	end;
run;

*creating ADAMS wave variable;
data ADAMS_HRS_e;
	set ADAMS_HRS_d;

	adamswave=.;
	if date1=date15 and date15 ne . then adamswave=5;
	if date1=date16 and date16 ne . then adamswave=6;
run;

proc freq data=ADAMS_HRS_e;
	tables adamswave/missing;
run;


data n.ADAMS_w;
	set ADAMS_HRS_e;
run;

*renaming adamswave to wave_numeric (what it is called in HRS)/not a necessary step;
data n.ADAMS_w;
	set n.ADAMS_w;
	wave_numeric=adamswave;
run;

*creating final version of adams a wave where everyone has a wave assigned;
proc sql;
create table n.ADAMS_Complete as select
a.*, b.wave_numeric, b.date15, b.date16, b.date1
from n.ADAMS_a as a left join n.ADAMS_w as b
on a.hhidpn=b.hhidpn;
quit;


proc sort data=n.ADAMS_Complete;
by HHIDPN wave_numeric;
run;

proc sort data=n.HRS_Final_with_Demog;
by HHIDPN wave_numeric;
run;

*merging with HRS demographics for random checkings;
data n.HRS_ADAMSA_All;
	merge n.ADAMS_Complete(in=a) n.HRS_Final_with_Demog(in=b);
	by HHIDPN wave_numeric;
	if a and b;

run;

proc contents data=n.HRS_ADAMSA_All;
run;


