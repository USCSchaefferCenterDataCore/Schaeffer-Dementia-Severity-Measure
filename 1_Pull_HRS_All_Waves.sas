libname HRS "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS";
libname n "/schaeffer-a/sch-projects/dua-data-projects/HRS_Sensitive/nfouladi/ADAMS";
libname sas "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/SAS";
proc format cntlin=HRS.sasfmts cntlout=formats; 
run;

data HRS;
	set HRS.rndHRS_p (keep= HHIDPN HACOHORT INW: RABDATE RADDATE RAGENDER RARACEM RAHISPAN RAEDUC
			R1WTRESP R2WTRESP R3WTRESP R4WTRESP R5WTRESP R6WTRESP R7WTRESP R8WTRESP R9WTRESP R10WTRESP R11WTRESP 
			R1PROXY R2PROXY R3PROXY R4PROXY R5PROXY R6PROXY R7PROXY R8PROXY R9PROXY R10PROXY R11PROXY 
			R2IADLZA R3IADLZA R4IADLZA R5IADLZA R6IADLZA R7IADLZA R8IADLZA R9IADLZA R10IADLZA R11IADLZA  
			R2ADLA R3ADLA R4ADLA R5ADLA R6ADLA R7ADLA R8ADLA R9ADLA R10ADLA R11ADLA
			R2CESD R3CESD R4CESD R5CESD R6CESD R7CESD R8CESD R9CESD R10CESD R11CESD
			R2BWC20 R3BWC20 R4BWC20 R5BWC20 R6BWC20 R7BWC20 R8BWC20 R9BWC20 R10BWC20 R11BWC20 
			R2FBWC20 R3FBWC20 R4FBWC20 R5FBWC20 R6FBWC20 R7FBWC20 R8FBWC20 R9FBWC20 R10FBWC20 R11FBWC20  
			R1FIMRC R2FIMRC R3FIMRC R4FIMRC R5FIMRC R6FIMRC R7FIMRC R8FIMRC R9FIMRC R10FIMRC R11FIMRC 
			R1FDLRC R2FDLRC R3FDLRC R4FDLRC R5FDLRC R6FDLRC R7FDLRC R8FDLRC R9FDLRC R10FDLRC R11FDLRC  
			R2ATR20 R3TR20 R4TR20 R5TR20 R6TR20 R7TR20 R8TR20 R9TR20 R10TR20 R11TR20 
			R2FSER7 R3FSER7 R4FSER7 R5FSER7 R6FSER7 R7FSER7 R8FSER7 R9FSER7 R10FSER7 R11FSER7  
			R2SER7 R3SER7 R4SER7 R5SER7 R6SER7 R7SER7 R8SER7 R9SER7 R10SER7 R11SER7  
			R1SLFMEM R2SLFMEM R3SLFMEM R4SLFMEM R5SLFMEM R6SLFMEM R7SLFMEM R8SLFMEM R9SLFMEM R10SLFMEM R11SLFMEM
			R1IWSTAT R2IWSTAT R3IWSTAT R4IWSTAT R5IWSTAT R6IWSTAT R7IWSTAT R8IWSTAT R9IWSTAT R10IWSTAT R11IWSTAT
			R1AGEY_E R2AGEY_E R3AGEY_E R4AGEY_E R5AGEY_E R6AGEY_E R7AGEY_E R8AGEY_E R9AGEY_E R10AGEY_E R11AGEY_E
			R1CESDM R2CESDM R3CESDM R4CESDM R5CESDM R6CESDM R7CESDM R8CESDM R9CESDM R10CESDM R11CESDM 
			R1IWEND R2IWEND R3IWEND R4IWEND R5IWEND R6IWEND R7IWEND R8IWEND R9IWEND R10IWEND R11IWEND);
run;

*making a demographic file separately to merge later at the end;
data n.HRS_DEMOG;
	set HRS (keep=HHIDPN HACOHORT RABDATE RADDATE RAGENDER RARACEM RAHISPAN RAEDUC);
run;
	
data HRS1;
	set HRS;
	rename R2ATR20 = R2TR20 ;
	drop R1PROXY R1WTRESP INW1 R1FIMRC R1FDLRC;
run;

%macro renvars(oldlist,newlist=,oldpre=,oldsuf=,newpre=,newsuf=);
   
   %if %length(&newlist)=0 %then %let newlist=&oldlist;
   
   %let v=1;
   %let oldvar=%scan(&oldlist,&v);
   %do %while (%length(&oldvar)>0);
       
       %if %length(%scan(&newlist,&v))=0 %then %do;
           %put WARNING: old variable list is longer than new variable list.  Skipping renames from old var &oldvar on.;
           %let oldvar=;
       %end;
       
       %else %do;
           
           &oldpre&oldvar&oldsuf = &newpre%scan(&newlist,&v)&newsuf
           
           %let v=%eval(&v+1);
           %let oldvar=%scan(&oldlist,&v);
       %end;
              
   %end;
   %if %length(%scan(&newlist,&v))>0 %then 
       %put WARNING: new variable list is longer than old variable list.  Skipping renames from new var %scan(&newlist,&v) on.;

%mend renvars;

/*To change names for example from R1WTRESP to WTRESP*/
data HRS2;
	set HRS1;

	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=WTRESP,newpre=WTRESP);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=PROXY,newpre=PROXY);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=IADLZA,newpre=IADLZA);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=ADLA,newpre=ADLA);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=CESD,newpre=CESD);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=BWC20,newpre=BWC20);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=FBWC20,newpre=FBWC20);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=FIMRC,newpre=FIMRC);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=FDLRC,newpre=FDLRC);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=TR20,newpre=TR20);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=FSER7,newpre=FSER7);
	rename %renvars(1 2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=SLFMEM,newpre=SLFMEM);
	rename %renvars(2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=SER7,newpre=SER7);
	rename %renvars(1 2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=IWSTAT,newpre=IWSTAT);
	rename %renvars(1 2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=AGEY_E,newpre=AGEY_E);
	rename %renvars(1 2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=CESDM,newpre=CESDM);
	rename %renvars(1 2 3 4 5 6 7 8 9 10 11,oldpre=R,oldsuf=IWEND,newpre=IWEND);

run;

%macro transpose(data=, out=, pre=);
	proc transpose data=&data name=wave_ch out=temp_&out (rename=(col1=&pre));		
	by HHIDPN HACOHORT; 
        var &pre:;
	run;

	data &out;
       		set temp_&out;
        	wave=transtrn(wave_ch, "&pre", '');	
		drop wave_ch;
	run;

%mend;

%transpose(data=hrs2,pre=INW,out=INW_long);
%transpose(data=hrs2,pre=WTRESP,out=WTRESP_long);
%transpose(data=hrs2,pre=PROXY,out=PROXY_long);
%transpose(data=hrs2,pre=IADLZA,out=IADLZA_long);
%transpose(data=hrs2,pre=BWC20,out=BWC20_long);
%transpose(data=hrs2,pre=FBWC20,out=FBWC20_long);
%transpose(data=hrs2,pre=FIMRC,out=FIMRC_long);
%transpose(data=hrs2,pre=FDLRC,out=FDLRC_long);
%transpose(data=hrs2,pre=TR20,out=TR20_long);
%transpose(data=hrs2,pre=FSER7,out=FSER7_long);
%transpose(data=hrs2,pre=SLFMEM,out=SLFMEM_long);
%transpose(data=hrs2,pre=SER7,out=SER7_long);
%transpose(data=hrs2,pre=IWSTAT,out=IWSTAT_long);
%transpose(data=hrs2,pre=IWEND,out=IWEND_long);
%transpose(data=hrs2,pre=CESDM,out=CESDM_long);
%transpose(data=hrs2,pre=CESD,out=CESD_long);
%transpose(data=hrs2,pre=AGEY_E,out=AGEY_E_long);
%transpose(data=hrs2,pre=ADLA,out=ADLA_long);

proc sort data=INW_long;
 	by HHIDPN HACOHORT wave;
run;

proc sort data=WTRESP_long;
	by HHIDPN HACOHORT wave;
run;

proc sort data=PROXY_long;
	by HHIDPN HACOHORT wave;
run;

proc sort data=ADLA_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=IADLZA_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=BWC20_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=FBWC20_long;
        by HHIDPN HACOHORT wave;
run;

proc sort data=FIMRC_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=FDLRC_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=TR20_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=FSER7_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=SLFMEM_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=SER7_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=IWSTAT_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=IWEND_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=CESD_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=CESDM_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=AGEY_E_long;
  	by HHIDPN HACOHORT wave;
run;

proc sort data=IWEND_long;
  	by HHIDPN HACOHORT wave;
run;

data HRS4;
    merge INW_long WTRESP_long PROXY_long IADLZA_long ADLA_long BWC20_long FBWC20_long FIMRC_long FDLRC_long TR20_long 
		  FSER7_long SLFMEM_long SER7_long IWSTAT_long IWEND_long AGEY_E_long CESDM_long CESD_long; 
    by HHIDPN HACOHORT wave;
run;

data HRS5;
	set HRS4;
	selfmem=.;
	if slfmem in (1,2,3) then selfmem = 1; /*"Exc/VG/Good"*/
	if slfmem = 4 then selfmem = 2; /*"Fair"*/
	if slfmem = 5 then selfmem = 3; /*"Poor"*/
	if slfmem in (.c,.s,.x) then  selfmem=.;
run; 

/* besides using the imputed variables, make a version that is missing if >2 measures were imputed */
data HRS6;
	set HRS5;
  
	if INW = 1 then totcog = sum(of BWC20, SER7, TR20); 
	totcog_imp = sum (of FIMRC, FDLRC, FSER7, FBWC20);
	
run;

/* version with totcog set to missing if more than 2 measures were imputed */
data HRS7;
	set HRS6;
	totcogA = totcog;
	if totcog_imp gt 2 then totcogA=.;
run;

/* USE DATA FROM 1995-2006    weihanch - update to 2010  
   Making each list a macro variable */

/* List of years for each file */
%let yrlist = 93 95 96 98 00 02 04 06 08 10 12 13 14;

/* List of files */
%let filelist = ad93f2a ad95f2a h96f4a hd98f2b h00f1c h02f2b h04f1a h06f2a h08f1b h10f3a h12f2a h14f2b h16f2b ;

/* List of waves for each file*/
%let wavelist = 2 3 3 4 5 6 7 8 9 10 11 12 13;

/* List of the variables for proxy memory assessment */
%let proxy_memvars = b323 d1056 e1056 f1373 g1527 hd501 jd501 kd501 ld501 MD501 nd501 od501 pd501;

/* List of the variables for interviewer assesment of cognitive limitations */
%let inter_cogvars = none none none none g517 ha011 ja011 ka011 la011 MA011 na011 oa011 pa011;

/* Eileen's replacements for IQCODE aka Jorg Score */
%macro concat_data;

	%do i=1 %to 13;
		%let filename=%scan(&filelist, &i);
		%let wave=%scan(&wavelist, &i);
		%let yr=%scan(&yrlist, &i);
		%let memvar=%scan(&proxy_memvars, &i);
		%let intervar=%scan(&inter_cogvars, &i);

		data temp&i;
		length HHIDPN 8;
		length wave $ 8;
		set sas.&filename;

		if &memvar le 5 then do;
			proxy_mem=&memvar - 1;
		end;

		%if &intervar ne none %then %do;

			if &intervar=1 then
			inter_cogstate=0;
			else if &intervar=2 then
			inter_cogstate=1;
			else if &intervar in (3, 4) then
			inter_cogstate=2;
			else
			inter_cogstate=.;
			%end;
			%else
			%do;
			inter_cogstate=.;
		%end;

		wave="&wave";
		yr="&yr";
		run;

		%if &intervar ne none %then %do;
			proc freq data=temp&i;
			tables &intervar*inter_cogstate/missing;
			run;
		%end;

		proc freq data=temp&i;
		tables proxy_mem*&memvar;
		run;

		data temp&i(keep=HHIDPN wave yr proxy_mem inter_cogstate);
		set temp&i;
		run;

		proc append base=tics_temp data=temp&i force;
		run;

%end;

%mend;

proc sql;
	drop table tics_temp;
quit;

%concat_data;

data HRS8;
	length wave_n $ 8;
	set HRS7;
	wave_n=strip(wave);
	
run;

data tics_temp_n;
	length wave_n $ 8;
	set tics_temp;
	wave_n=strip(wave);
	
run;

proc sort data=HRS8;
	by HHIDPN wave_n;
run;

proc sort data=tics_temp_n;
	by HHIDPN wave_n;
run;

data merged_tics_temp_HRS8;
	merge tics_temp_n (in=a) HRS8(in=b);
	by HHIDPN wave_n;

	tics=a;
	hrs=b;

run;
	
/* rename and make wave numeric*/
data HRS9;
	set merged_tics_temp_HRS8;
	wave_numeric = wave_n+0;
	drop wave_n;
run;

data HRS9;
	set HRS9;

	rename wtresp=weight;

	proxy_nonmissB=0;
	proxy_nonmissx=0; /*used to make proxy_nonmiss*/
	nmiss_proxy=0;
	nmiss_proxyB=0;
	maxpcog=9;
run;

data HRS10;
	set HRS9;

	proxy_memA=.;
	if proxy_mem in (0, 1, 2) then proxy_memA = 0; 
	if proxy_mem = 3 then proxy_memA = 1; 
	if proxy_mem = 4 then proxy_memA = 2; 
	else if proxy_mem = . then proxy_memA=.;
run;

data HRS10;
	set HRS10;

	proxy_selfmem=.;
	if proxy_mem in (0, 1, 2) then proxy_selfmem = 1; *"Exc/VG/Good";
	if proxy_mem = 3 then proxy_selfmem = 2; *"Fair";
	if proxy_mem = 4 then proxy_selfmem = 3; *"Poor";
	else if proxy_mem = . then proxy_selfmem=.;

run;

data HRS11;
	set HRS10;
	if proxy = 1 then do;
		selfmem = proxy_selfmem ;
	end;

run;

%macro compute_proxyB;

	%let varlist = iadlza proxy_mem inter_cogstate;

	%do i = 1 %to 3;
		%let var = %scan(&varlist, &i);

			if &var = . then nmiss_proxyB = nmiss_proxyB +1;
			if &var ne . then proxy_nonmissB = proxy_nonmissB + &var;
			
	%end;

%mend;

%macro compute_maxpcog;

	%let varlist = iadlza proxy_memA inter_cogstate;

	%do i = 1 %to 3;
		%let var = %scan(&varlist, &i);

			if &var = . then nmiss_proxy = nmiss_proxy + 1;

		if &var = . and "&var" = "iadlza" then maxpcog = maxpcog - 5;
		if &var = . and "&var" = "proxy_memA" then maxpcog = maxpcog - 2;
		if &var = . and "&var" = "inter_cogstate" then maxpcog = maxpcog - 2;
		if &var  ne .  then proxy_nonmissx =  proxy_nonmissx + &var;

	%end;

%mend;

data HRS12;
	set HRS11;

	%compute_proxyB;
	%compute_maxpcog;
run;

data HRS12;
	set HRS12;
	proxy_nonmiss =  iadlza + proxy_mem + inter_cogstate;
run;

data HRS13;
	set HRS12;
	if nmiss_proxy > 0 then proxy_nonmiss = round(proxy_nonmissx * (11/maxpcog),1.0);  /* missing values: adjust to make scale 0-11 */
run;

data HRS14;
set HRS13;

	cogstate_self = .;
	if totcog in (0:6) then cogstate_self = 1;
	if totcog in (7:11) then cogstate_self = 2;
	if totcog in (12:27) then cogstate_self = 3;
	if totcog = . then cogstate_self = .;

	cogstate_selfA = .;
	if totcogA in (0:6) then cogstate_selfA = 1;
	if totcogA in (7:11) then cogstate_selfA = 2;
	if totcogA in (12:27) then cogstate_selfA = 3;
	if totcogA = . then cogstate_selfA = .;

	cogstate_proxy = .;
	if proxy_nonmiss in (0, 1, 2) then cogstate_proxy = 3;
	if proxy_nonmiss in (3:5) then cogstate_proxy = 2;
	if proxy_nonmiss in (6:11) then cogstate_proxy = 1;
	if proxy_nonmiss = . then cogstate_proxy = .;

	if nmiss_proxy > 2 then cogstate_proxy = .;


/*this version uses sum of measures adjusted to total of 11 if any part is missing*/
	cogstate_proxyB = .;
	if proxy_nonmissB in (0:2) then cogstate_proxyB = 3;
	if proxy_nonmissB in (3:5) then cogstate_proxyB = 2;
	if proxy_nonmissB in (6:11) then cogstate_proxyB = 1;
	if proxy_nonmissB = . then cogstate_proxyB = .;

	if nmiss_proxy > 2 then cogstate_proxyB = .;

run;

data HRS15;
	set HRS14;

	cogstateB = .;
	if cogstate_proxyB ne . then do;
		cogstateB = cogstate_proxyB;
	end;

	if cogstate_self ne . then do;
		cogstateB = cogstate_self;
	end;

	/*Flag for imputed proxy cogstate*/
	proxy_cogX=.;
	if cogstate_proxy ne . then do;
		proxy_cogX = (nmiss_proxy>0);
	end;

	
	if cogstate_self ne . then do;
		proxy_cogX = 0;
	end;


	cogstate=.;
	if cogstate_proxy ne . then do;
		cogstate = cogstate_proxy;
	end;

	if cogstate_self ne . then do;
		cogstate = cogstate_self;
	end;

run;

data HRS16;
	set HRS15;
		label cogstateB = "Cognitive Ability (old)"
			  cogstate = "Cognitive Ability / proxy adj if miss"
      		  cogstate_self = "Cognitive Ability, Self Respondents"
      	      cogstate_selfA = "Cognitive Ability, Self Respondents/=. if >2 imputes"
       		  cogstate_proxyB = "Cognitive Ability, Proxy Respondents (old)"
     		  cogstate_proxy = "Cognitive Ability, Proxy Respondents / adj if any miss"
              proxy_cogX = "Whether any missing part of cogstate_proxy"
              selfmem = "Self-rating overall memory status";

run;
proc format;
	value selfmem 1 = 'Excellent/VG/Good'
				  2 = 'Fair'
				  3 = 'Poor';
run;

/*Dementia dummy variable and an absorbed version*/
data HRS16;
	set HRS16;
	
	Dementia=.;
	if cogstate = 1 then Dementia = 1;
	if cogstate in (2, 3) then Dementia = 0;
	else if cogstate=. then Dementia=.;
run;

Data n.HRS_Final_without_Demog;
	set HRS16 (keep= ADLA IADLZA AGEY_E BWC20 CESD CESDM Dementia Cogstate FBWC20 FDLRC FIMRC
					 FSER7 HACOHORT HHIDPN INW IWSTAT PROXY SER7 SLFMEM TR20 wave_numeric wave
					 totcog totcogA selfmem proxy_nonmiss CESD CESDM IWEND);
run;

proc contents data=n.HRS_Final_without_Demog;
run;

*merge demographics+HRS;
proc sql; 
create table n.HRS_Final_with_Demog as select
a.*, b.RABDATE, b.RADDATE, b.RAGENDER, b.RARACEM, b.RAHISPAN, b.RAEDUC
from n.HRS_Final_without_Demog as a left join n.HRS_DEMOG as b
on a.HHIDPN=b.HHIDPN;
quit;

proc contents data=n.HRS_Final_with_Demog;
run;



