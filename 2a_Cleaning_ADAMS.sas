*Input file: adams.adamsa 
*output file:n.ADAMS_A
* cleaning/recoding the ADAMS-wave A variables and creating some of the variables for regression models;
libname n "/schaeffer-a/sch-projects/dua-data-projects/HRS_Sensitive/nfouladi/ADAMS";
libname adams "/schaeffer-a/sch-data-library/dua-data/HRS/Sensitive/Adams/Sas";
proc contents data=adams.ADAMSA;
run;

data ADAMSA_1;
	set adams.ADAMSA;
	if ADCDRSTG=. then delete;
run;

data ADAMSA_2;
	set ADAMSA_1;

	if ANBWC201 IN (6,97, 99) then ANBWC201=.;
	if ANBWC202 IN (97, 99) then ANBWC202=.;

/*ADLA*/
	if AGQ30A =5 then AGQ30A=0;
	if AGQ30B =5 then AGQ30B=0;
	if AGQ30C =5 then AGQ30C=0;
	if AGQ30D =5 then AGQ30D=0;
	if AGQ30E =5 then AGQ30E=0;

	if AGQ30A =8 then AGQ30A=.;
	if AGQ30B =8 then AGQ30B=.;
	if AGQ30C =8 then AGQ30C=.;
	if AGQ30D =8 then AGQ30D=.;
	if AGQ30E =8 then AGQ30E=.;

/*IADL*/		
	if AGQ30K =5 then AGQ30K=0;
	if AGQ30G =5 then AGQ30G=0;
	if AGQ30H =5 then AGQ30H=0;
	if AGQ30I =5 then AGQ30I=0;
	if AGQ30J =5 then AGQ30J=0;

	if AGQ30K in (7, 8) then AGQ30K=.;
	if AGQ30G in (7, 8) then AGQ30G=.;
	if AGQ30H in (7, 8) then AGQ30H=.;
	if AGQ30I in (7, 8) then AGQ30I=.;
	if AGQ30J in (7, 8) then AGQ30J=.;

	if ANIMMCR1 = 97 then ANIMMCR1=.;
	if ANDELCOR = 97 then ANDELCOR=.;

	IF ANSER7T=97 THEN ANSER7T=.;

run;

data ADAMSA_2;
	set ADAMSA_2;

	ADL_ADAMS = sum (of AGQ30A AGQ30B AGQ30C AGQ30D AGQ30E);
	IADL_ADAMS = sum (of AGQ30I AGQ30J AGQ30K AGQ30H AGQ30G);
	TICS_ADAMS = sum (of ANIMMCR1 ANDELCOR ANSER7T ANBWC201 ANBWC202);

	*rename proxy to not mix up with proxy from HRS;
	proxy_adams=proxy;
	
run;

data n.ADAMS_A;
	set ADAMSA_2(keep=HHIDPN AAAGESEL AAGE AAGEBKT GENDER RACE ETHNIC EDYRS  
					  ADCDRSTG SESTRAT SECLUST AASAMPWT_F  ABNPD16 ABNPD17 ABNPD1
					  ADL_ADAMS IADL_ADAMS TICS_ADAMS Proxy_ADAMS GPROXY HPROXY
					  AYEAR AMONTH VITSTAT WAVESEL GIWYEAR ABC:);
run;

proc contents data=n.ADAMS_A;
run;

***NOTE****
*final dataset is n.ADAMS_A (DOES NOT HAVE WAVES YET, GO TO 2b TO CREATE ADAMS WAVES);





