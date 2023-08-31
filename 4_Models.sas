* CDR regression models , and predictive modeling of severity in ADAMS and HRS
* input file: n.HRS_ADAMSA_final_version;

libname n "/schaeffer-a/sch-projects/dua-data-projects/HRS_Sensitive/nfouladi/ADAMS";
libname HRS "/schaeffer-a/sch-data-library/public-data/HRS/Unrestricted/RAND-HRS";
proc format cntlin=HRS.sasfmts cntlout=formats; 
run;

****REGRESSION MODELS****;
*ols;
proc glm data = n.HRS_ADAMSA_final_version;
	
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		  CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_n3 = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate 
						   ADL_cat IADL_cat CIDI_CESD/solution clparm;
	store out=OLS_adams;
run;

*predicting severity in HRS;
proc plm restore=OLS_adams;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_ols
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=OLS_adams;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_ols
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*distribution of predicted severity in HRS wave 6;
proc means data=hrs6_final_scored_ols n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*distribution of predicted severity in ADAMS wave A;
proc means data=HRS_ADAMSA_scored_ols n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_ols_r;
	set HRS_ADAMSA_scored_ols;

	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_n3;
run;


*OLS_binary 0,1 CDR;
proc glm data = n.HRS_ADAMSA_final_version;
	
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		  CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_bin = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams  
						ADL_cat IADL_cat CIDI_CESD cogstate /solution clparm;
	store out=OLS01_adams;
	
run;

*predicting severity in HRS;
proc plm restore=OLS01_adams;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_OLS01
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=OLS01_adams;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_OLS01
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*distribution of predicted severity in HRS wave 6;
proc means data=hrs6_final_scored_OLS01 n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*distribution of predicted severity in ADAMS wave A;
proc means data=HRS_ADAMSA_scored_OLS01 n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_OLS01_r;
	set HRS_ADAMSA_scored_OLS01;
	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_bin;
run;

*poisson;
proc genmod data=n.HRS_ADAMSA_final_version;
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		  CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_n3 = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate 
						   ADL_cat IADL_cat CIDI_CESD / dist=POISSON ;
	
	store out=Poisson_adams;
run;

*predicting severity in HRS;
proc plm restore=Poisson_adams;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_Poisson
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=Poisson_adams;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_Poisson
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*distribution of predicted severity measure in HRS wave 6;
proc means data=hrs6_final_scored_Poisson n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*distribution of predicted severity measure in ADAMS wave A;
proc means data=HRS_ADAMSA_scored_Poisson n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_Poisson_r;
	set HRS_ADAMSA_scored_Poisson;
	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_n3;
run;

*Negative binomial;
proc genmod data=n.HRS_ADAMSA_final_version;
	
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		  CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_n3 = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate 
							   ADL_cat IADL_cat CIDI_CESD/dist=NEGBIN link=log;
	store out=NegBin_adams;
run;

*predicting severity in HRS;
proc plm restore=NegBin_adams;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_NB
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=NegBin_adams;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_NB
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*distribution of predicted severity in HRS wave 6;
proc means data=hrs6_final_scored_NB n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*distribution of predicted severity in ADAMS wave A;
proc means data=HRS_ADAMSA_scored_NB n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_NB_r;
	set HRS_ADAMSA_scored_NB;

	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_n3;
run;


*zero inflated;
proc genmod data=n.HRS_ADAMSA_final_version;
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		  CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_n3 = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate 
						ADL_cat IADL_cat CIDI_CESD / dist=ZIP;
	
	zeromodel AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate ADL_cat IADL_cat CIDI_CESD /link=logit;
	store out=ZI_adams;
run;

*predicting severity in HRS;
proc plm restore=ZI_adams;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_ZI
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=ZI_adams;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_ZI
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*distribution of predicted severity in HRS wave 6;
proc means data=hrs6_final_scored_ZI n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*distribution of predicted severity in ADAMS wave A;
proc means data=HRS_ADAMSA_scored_ZI n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_ZI_r;
	set HRS_ADAMSA_scored_ZI;
	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_n3;
run;


*Zero Inflated Negative Binomial;
proc genmod data=n.HRS_ADAMSA_final_version;
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		  CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_n3 = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate 
						ADL_cat IADL_cat CIDI_CESD / dist=zinb;
	
	zeromodel AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate ADL_cat IADL_cat CIDI_CESD /link=logit;
	store out=ZI_adams_nb;
run;

*predicting severity in HRS;
proc plm restore=ZI_adams_nb;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_ZINB
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=ZI_adams_nb;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_ZINB
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*distribution of predicted severity in HRS wave 6;
proc means data=hrs6_final_scored_ZINB n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*distribution of predicted severity in ADAMS wave A;
proc means data=HRS_ADAMSA_scored_ZINB n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_ZINB_r;
	set HRS_ADAMSA_scored_ZINB;
	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_n3;

run;

*Logistic CDR=1 vs. CDR=0;
proc means data=n.HRS_ADAMSA_final_version n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
	var ADCDRSTG_bin;
run;

PROC LOGISTIC DATA = n.HRS_ADAMSA_final_version ;
	
	class GENDER (ref="1") racethn(ref="1") EDYRS_new (ref="1") ADL_cat(ref="0") IADL_cat(ref="0") 
		      		   CIDI_CESD(ref="0") proxy_adams(ref="0") cogstate(ref="3");
	model ADCDRSTG_bin(event="1") = AAGE age_sqrd GENDER EDYRS_new racethn proxy_adams cogstate 
					      ADL_cat IADL_cat CIDI_CESD;

	store out=logistic_adams ;
run;

*predicting severity in HRS;
proc plm restore=logistic_adams;
	score data=n.HRS6_70yr_NoFmt out=hrs6_final_scored_log
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*predicting severity in adams again;
proc plm restore=logistic_adams;
	score data=n.HRS_ADAMSA_final_version out=HRS_ADAMSA_scored_log
	pred=Predicted lcl=Lower ucl=Upper/ilink;
run;

*Distribution of severity in HRS;
proc means data=hrs6_final_scored_log n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

*Distribution of severity in ADAMS;
proc means data=HRS_ADAMSA_scored_log n nmiss mean std min p1 p5 p10 p25 p50 p75 p90 p95 max maxdec=2;
var predicted;
run;

data HRS_ADAMSA_scored_log_r;
	set HRS_ADAMSA_scored_log;

	pred_rounded=round(predicted);
	difference = predicted - ADCDRSTG_bin;

run;



