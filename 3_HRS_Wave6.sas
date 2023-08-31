libname HRS "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS";
libname n "/schaeffer-a/sch-projects/dua-data-projects/HRS_Sensitive/nfouladi/ADAMS";
libname sas "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/SAS";
libname adams "/schaeffer-a/sch-data-library/dua-data/HRS/Sensitive/Adams/Sas";
proc format cntlin=HRS.sasfmts cntlout=formats; 
run;

*HRS wave 6 only;
data n.HRS6_final;
	set n.HRS_Final_with_Demog;
	where wave_numeric=6;
run;

*recoding for HRS wave 6 to match adams variables ;
data n.HRS6_final;
	set n.HRS6_final;

	AgeSQRD=AGEY_E*AGEY_E;

	Race_Ethnicity=.;
		if RARACEM=1 and RAHISPAN=0 then Race_Ethnicity=1;
		else if RARACEM=2 and RAHISPAN=0 then Race_Ethnicity=2;
		else if RAHISPAN=1 then Race_Ethnicity=3;
		else if RARACEM=3 and RAHISPAN=0 then Race_Ethnicity=4;
		else delete;/*missing*/
		
	Education=.;
		if RAEDUC=1 then Education=1;
		else if RAEDUC in (2,3,4) then Education=2;
		else if RAEDUC=5 then Education=3;
		else delete;/*missing*/

	ADLA_cat=.;
		if ADLA =0 then ADLA_cat=0;
		else if ADLA in (1:2) then ADLA_cat=1;
		else if ADLA in (3:5) then ADLA_cat=2;
		else delete; /*missing*/

	IADLZA_cat=.;
		if IADLZA=0 then IADLZA_cat=0;
		else if IADLZA in (1:2) then IADLZA_cat=1;
		else if IADLZA in (3:5) then IADLZA_cat=2;
		else delete; /*missing*/

		if cogstate=. then delete;

	*cut off of 3 for CESD, to match cidi5pl(cut-off of 5 symptoms and more that indicates depression) in ADAMS;
	CESD_3=.;
		if CESD in (0:2) then CESD_3=0;
		else if CESD in (3:8) then CESD_3=1;
		else CESD_3=2;
run;

****final dataset for HRS wave 6, keeping only age 70 and higher to match ADAMS age restriction;
data n.HRS6_final_age70;
	set n.HRS6_final;
	if AGEY_E lt 70 then delete;
run;

*n.HRS6_final_age70 >> N=7640;
*Removing formats to not get warnings for regression models;
data n.HRS6_70yr_NoFmt;
	set n.HRS6_final_age70 ; 

	*HRS variables to ADAMS-A variables;
	rename Agey_e= AAGE;
	rename AgeSQRD =age_sqrd;
	rename CESD_3=CIDI_CESD;
	rename ADLA_cat=ADL_cat;
	rename IADLZA_cat=IADL_cat;
	rename race_ethnicity=racethn;
	rename proxy=proxy_adams;
	rename education=edyrs_new;
	rename ragender=gender;

	format _all_;
	informat _all_;
run;
