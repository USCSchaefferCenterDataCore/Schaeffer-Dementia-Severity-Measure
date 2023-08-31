*Creating depression variable in ADAMS: cidi-sf;
*Input file: n.HRS_ADAMSA_All;
*output file: n.HRS_ADAMSA_final_version;

libname HRS "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS";
libname n "/schaeffer-a/sch-projects/dua-data-projects/HRS_Sensitive/nfouladi/ADAMS";
proc format cntlin=HRS.sasfmts cntlout=formats; 
run;

proc print data=n.HRS_ADAMSA_all ;
var totcog tics_adams;
where tics_adams=. or totcog=.;
run;
proc print data=n.HRS_ADAMSA_all ;
var ADL_ADAMS IADL_ADAMS;
where ADL_ADAMS=. or IADL_ADAMS=.;
run;

*filling the missings of ADAMS wave A, with HRS;
data n.HRS_ADAMSA_all_fill;
	set n.HRS_ADAMSA_all;
	
	ADL=ADL_ADAMS;
	if ADL_ADAMS=. then do;
		ADL=coalesce (ADLA, ADL_ADAMS);
	end;

	IADL=IADL_ADAMS;
	if IADL_ADAMS=. then do;
		IADL=coalesce (IADLZA, IADL_ADAMS);
	end;

	TICS=tics_adams;
	if tics_ADAMS =. then do;
		TICS=coalesce (totcog, tics_adams);
	end;
	
run;
proc freq data=n.HRS_ADAMSA_all_fill;
	tables  TICS CESD ADL IADL;
	run;

*Creating depression variable;
data n.HRS_ADAMSA_all_fill;
	set n.HRS_ADAMSA_all_fill;

		if (ABC1>5 or ABC1=97) and (ABC14>5 or ABC14=97) then
			cidimiss=1;
		else
			cidimiss=0;

		if cidimiss=1 then cidimeds=. ;
		else if ABC1=2 or ABC14=2 then cidimeds=1;
		else cidimeds=0;
			

		*Begin CIDI;
		array symps (21) dsymp1-dsymp7 asymp1-asymp7 symp1-symp7;

		do i=1 to 21;

			if cidimiss=0 then
				symps(i)=0;
		end;


		if ABC1=1 and (ABC2=1 or ABC2=2) and (ABC3=1 or ABC3=2) then
			do;
				sfd=1;


				*Lost interest in things (anhedonia);
				if ABC4=1 then
					dsymp1=1;

				*Felt tired;
				if ABC5=1 then
					dsymp2=1;

				*Change in appetite (increase or decrease);
				if (ABC6=1 or ABC7=1) then
					dsymp3=1;

				*Trouble sleeping for nearly every night or every night;
				if (ABC9=1 or ABC9=2) then
					dsymp4=1;

				*Trouble concentrating;
				if ABC10=1 then
					dsymp5=1;

				*Feeling down on self;
				if ABC11=1 then
					dsymp6=1;

				*Thoughts of death;
				if ABC12=1 then
					dsymp7=1;
			end;

		if sfd=0 and ABC14=1 and (ABC15=1 or ABC15=2) and (ABC16=1 or ABC16=2) then
			do;

				*Felt tired;
				if ABC17=1 then
					asymp2=1;

				*Change in appetite (increase or decrease);
				if (ABC18=1 or ABC19=1) then
					asymp3=1;

				*Trouble sleeping for nearly every night or every night;
				if (ABC21=1 or ABC21=2) then
					asymp4=1;

				*Trouble concentrating;
				if ABC22=1 then
					asymp5=1;

				*Feeling down on self;
				if ABC23=1 then
					asymp6=1;

				*Thoughts of death;
				if ABC24=1 then
					asymp7=1;
			end;

		*Create variable indicating symptom regardless of stem question (i.e. SYMP1= DSYMP1+ASYMP1, etc.);

		do i=1 to 7;
			symps(i+14)=symps(i)+symps(i+7);
		end;

		*Create the total CIDI score by summing symptoms 1 through 7;
		ciditot=sum (of symp1-symp7);


		*Create two dichotomous variables for suggested cut points of A3 or more symptoms@ (cidi3pl) and A5
			or more symptoms@ (cidi5pl);
		cidi3pl=.;
		if ciditot>2 then cidi3pl=1;
		if ciditot in (0,1,2) then cidi3pl=0;
			
		cidi5pl=.;
		if ciditot>4 then cidi5pl=1;
		if ciditot in (0,1,2,3,4) then cidi5pl=0;

		*creating a variable for combination of cidi-sf and those who take meds for depression;
		
		if cidi5pl=0 then ciditot_cat=0;
		if cidi5pl=1 or cidimeds=1 then ciditot_cat=1;
		
	
		*NPI;
		if ABNPD16 > 4 then ABNPD16=.;
		if ABNPD17 > 3 then ABNPD17=.;

		NPI=ABNPD16*ABNPD17;

		NPI_bin=.;
		if 0 =< NPI <4 then NPI_bin=0;
		if NPI ge 4 then NPI_bin=1;

		any_depression=max(NPI_bin,ciditot_cat);

		*missing categories;
		if ciditot_cat=. then ciditot_cat=2;
		if any_depression=. then any_depression=2;

run;

***final recodings to prepare variables for regression models;
data n.HRS_ADAMSA_final_version;
	set n.HRS_ADAMSA_all_fill;

	age_sqrd=AAGE*AAGE;
	
	racethn=.;
	if race=1 and ethnic ne 3 then racethn=1; /*white, non hispanic*/
	if race=2 and ethnic ne 3 then racethn=2; /*black, non hispaniuc*/
	if ethnic=3 then racethn=3; /*hispanic*/
	if race=7 and ethnic ne 3 then racethn=4; /*others non hispanic*/

	EDYRS_new=.;
	if EDYRS in (0:11) then EDYRS_new=1;
	if EDYRS in (12:15) then EDYRS_new=2;
	if EDYRS in (16:17) then EDYRS_new=3;

	ADL_cat=.;
	if ADL =0 then ADL_cat=0;
	if ADL in (1:2) then ADL_cat=1;
	if ADL in (3:5) then ADL_cat=2;

	IADL_cat=.;
	if IADL=0 then IADL_cat=0;
	if IADL in (1:2) then IADL_cat=1;
	if IADL in (3:5) then IADL_cat=2;
	
	
	if cidi5pl=. then cidi5pl=2;
	if CESD=. then CESD=9;

	CESD_HRS=.;
	if CESD in (0:2) then CESD_HRS=0;
	else if CESD in (3:8) then CESD_HRS=1;

	*Depression filled with HRS CESD;
	if ciditot_cat=2 and CESD_HRS ne . then CIDI_CESD= min (ciditot_cat, CESD_HRS);
	else CIDI_CESD=ciditot_cat;

	if CESD_HRS=. then CESD_HRS=2;

	*for the distribution table;
	if ciditot=. then ciditot=8;
	if TICS=. then TICS=26;

	if ADCDRSTG in (.,97) then delete;

	*version of CDR that would go into models ;
	ADCDRSTG_n3=.; 
	if ADCDRSTG = 0 then ADCDRSTG_n3=0;
	if ADCDRSTG = 0.5 then ADCDRSTG_n3=1;
	if ADCDRSTG = 1 then ADCDRSTG_n3=2;
	if ADCDRSTG in (2,3) then ADCDRSTG_n3=3;
	if ADCDRSTG in (4,5) then ADCDRSTG_n3=4;

	*binary version;
	ADCDRSTG_bin=.; 
	if ADCDRSTG = 0 then ADCDRSTG_bin=0;
	if ADCDRSTG in (0.5,1,2,3,4,5) then ADCDRSTG_bin=1;

	*another version of CDR caregorization for distribution table, table 1;
	ADCDRSTG_f=.; 
	if ADCDRSTG = 0 then ADCDRSTG_f=0;
	if ADCDRSTG = 0.5 then ADCDRSTG_f=0.5;
	if ADCDRSTG = 1 then ADCDRSTG_f=1;
	if ADCDRSTG = 2 then ADCDRSTG_f=2;
	if ADCDRSTG = 3 then ADCDRSTG_f=3;
	if ADCDRSTG in (4,5) then ADCDRSTG_f=4;
	
run;

******final dataset to use for regression models: n.HRS_ADAMSA_final_version;;



