


if "`c(username)'"=="jonathanold" {
	
	cd "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Data"
	gl data "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Data"
	gl output "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Output"
	set scheme mine
}


use "${data}/WVS/WVS_Cross-National_Wave_7_stata_v4_0 2.dta", clear

ren *, lower
tostring b_country, gen(cid)
order cid

decode b_country, gen(country)
order country

save "${data}/_gen/wvs_7.dta", replace 

import excel using "${data}/WHO/who_gender_shares.xlsx", firstrow cellrange(A2)  clear
drop if Location==""
drop D-I
ren Location country
replace country = strtrim(country) 
replace country="Russia" if country=="Russian Federation"
replace country="Taiwan ROC" if country=="Taiwan"



replace country="Iran" if country=="Iran (Islamic Republic of)"
replace country="Laos" if country=="Lao People's Democratic Republic"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Brunei" if country=="Brunei Darussalam"
replace country="South Korea" if country=="Republic of Korea"
replace country="Moldova" if country=="Republic of Moldova"
replace country="United States" if country=="United States of America"
replace country="Vietnam" if country=="Viet Nam"
replace country="Macedonia" if country=="the former Yugoslav Republic of Macedonia"

ren donationfemaledonors share_fem_donors
replace share_fem_donors = share_fem_donors*100



save "${data}/_gen/who_gender.dta", replace 


import excel using "${data}/Blood Supply and Demand/lancet-hematology_data.xlsx", firstrow cellrange(A2) sheet("Appendix 2 Table S2") clear
ren *, lower
ren location country

replace country="Russia" if country=="Russian Federation"
replace country="Taiwan ROC" if country=="Taiwan"
merge 1:1 country using "${data}/_gen/who_gender.dta"

drop _merge
merge 1:m country using "${data}/_gen/wvs_7.dta"

keep if _merge==3




gen lgdp = log(gdppercap2)

split totalunitsavailableper10000, p("(")
ren totalunitsavailableper100001 units 
replace units = subinstr(units, ",", "", 9)
destring units, replace 

gen one = 1


pca q58 q59 q60 q61 q62 q63 q64 q65 q66 q67 q68 q69 q70 q71 q72 q73 q74 q75 q76 q77 q78 q79 q80 q81 q82 q83 q84 q85 q86 q87 q88 q89, comp(3)
predict pc_micro_1 pc_micro_2 pc_micro_3 , score

local mvars q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q26 q49 q47 q51 q52 q53 q54 q58 q59 q60 q61 q62 q63 q64 q65 q66 q67 q68 q69 q70 q71 q72 q73 q74 q75 q76 q77 q78 q79 q80 q81 q82 q83 q84 q85 q86 q87 q88 q89 q94 q95 q96 q97 q98 q99 q100 q101 q102 q103 q104 q105
local cvars fhregion polregfh freestfh prfhrat prfhscore clfhrat clfhscore democ autoc polity durable regtype ruleoflaw corrupttransp electintegr btiregion btistatus btidemstatus btistate btipolpart btiruleoflaw btistability btiintegration btimarket btigovindex btigoveperform btiregime regionwb incomewb landwb gdppercap1 gdppercap2 giniwb incrichest10p popwb1990 popwb2000 popwb2019 lifeexpect popgrowth urbanpop laborforce deathrate unemployfem unemploymale unemploytotal accessclfuel accesselectr renewelectr co2emis co2percap easeofbusiness militaryexp trade healthexp educationexp medageun meanschooling educationhdi compulseduc gii dgi womenparl hdi incomeindexhdi humanineqiality lifeexpecthdi homiciderate refugeesorigin internetusers mobphone migrationrate schoolgpi femchoutsch choutsch v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_cspart v2xeg_eqdr v2excrptps v2exthftps v2juaccnt v2cltrnslw v2clacjust v2clsocgrp v2clacfree v2clrelig v2csrlgrep v2mecenefm v2mecenefi v2mebias v2pepwrses v2pepwrgen v2peedueq v2pehealth v2peapsecon v2peasjsoecon v2clgencl v2peasjgen v2peasbgen v2cafres v2cafexch v2x_corr v2x_gender v2x_gencl v2x_genpp v2x_rule v2xcl_acjst id_gps id_partyfacts partyname partyabb cparty cpartyabb type_values type_populism type_populist_values type_partysize_vote type_partysize_seat gps_v4_scale gps_v6_scale gps_v8_scale gps_v9 gps_v10 gps_v11 gps_v12 gps_v13 gps_v14 gps_v15 gps_v16 gps_v17 wvs_lr_partyvoter wvs_libcon_partyvoter wvs_polmistrust_partyvoter wvs_lr_medianvoter wvs_libcon_medianvoter v2psbars v2psorgs v2psprbrch v2psprlnks v2psplats v2xnp_client v2xps_party
foreach v in `mvars' `cvars' {
    local l`v' : variable label `v' 
}

collapse (mean) `mvars' pc_micro_1 pc_micro_2 pc_micro_3 ///
			(firstnm) units share_fem_donors `cvars' lgdp b_country_alpha ///
			(sum) one ///
			, by(country)

foreach v in `mvars' `cvars' {
         label var `v' "`l`v''" 
}



pca q58 q59 q60 q61 q62 q63 q64 q65 q66 q67 q68 q69 q70 q71 q72 q73 q74 q75 q76 q77 q78 q79 q80 q81 q82 q83 q84 q85 q86 q87 q88 q89, comp(3)
predict pc_country_1 pc_country_2 pc_country_3 , score

stop


cap file close fh
file open fh using "${output}/Tables/wvs_results.tex", replace write
		file write fh "\caption{Correlations (from linear OLS) betweeen units collected and WVS questions} \label{tab:wvs} \\ " _n
		file write fh "\toprule\relax" _n
		file write fh " & Independent variable & Coefficient & (se) & With controls & (se)  \\ " _n
		file write fh "\midrule\relax" _n
		file write fh "\endhead" _n


replace units = log(units)

local n=0
foreach v in `mvars' {
	local n = `n'+1
	reg units `v' [aw=popwb2019], robust

	tempname M
	mat `M' = r(table)
	loc b_`v'  = string(`M'[1,1], "%15.2fc") 
	loc se_`v' = string(`M'[2,1], "%12.2fc")
	loc p_`v'  = string(`M'[4,1], "%12.2fc")
	loc star_`v'=cond(`p_`v''<=.01,"***",cond(`p_`v''<=.05,"**",cond(`p_`v''<=.1,"*","")))

	reg units `v' polity c.gdppercap2##c.gdppercap2 [aw=popwb2019], robust
	tempname M
	mat `M' = r(table)
	loc b2_`v'  = string(`M'[1,1], "%15.2fc") 
	loc se2_`v' = string(`M'[2,1], "%12.2fc")
	loc p2_`v'  = string(`M'[4,1], "%12.2fc")
	loc star2_`v'=cond(`p2_`v''<=.01,"***",cond(`p2_`v''<=.05,"**",cond(`p2_`v''<=.1,"*","")))
	
	local l`v' : variable label `v' 

	file write fh "(`n') 	&  `l`v'' 	& `b_`v''`star_`v'' & (`se_`v'') & `b2_`v''`star2_`v'' & (`se2_`v'')  \\ " _n

}

file write fh "\bottomrule\relax" _n	
file close fh 











cap file close fh
file open fh using "${output}/Tables/wvs_results_female.tex", replace write
		file write fh "\caption{Correlations (from linear OLS) betweeen share of female donors and WVS questions} \label{tab:wvs_female} \\ " _n
		file write fh "\toprule\relax" _n
		file write fh " & Independent variable & Coefficient & (se) & With controls & (se)  \\ " _n
		file write fh "\midrule\relax" _n
		file write fh "\endhead" _n


replace units = log(units)

local n=0
foreach v in `mvars' {
	local n = `n'+1
	reg share_fem_donors `v' [aw=popwb2019], robust

	tempname M
	mat `M' = r(table)
	loc b_`v'  = string(`M'[1,1], "%15.2fc") 
	loc se_`v' = string(`M'[2,1], "%12.2fc")
	loc p_`v'  = string(`M'[4,1], "%12.2fc")
	loc star_`v'=cond(`p_`v''<=.01,"***",cond(`p_`v''<=.05,"**",cond(`p_`v''<=.1,"*","")))

	reg share_fem_donors `v' polity c.gdppercap2##c.gdppercap2 [aw=popwb2019], robust
	tempname M
	mat `M' = r(table)
	loc b2_`v'  = string(`M'[1,1], "%15.2fc") 
	loc se2_`v' = string(`M'[2,1], "%12.2fc")
	loc p2_`v'  = string(`M'[4,1], "%12.2fc")
	loc star2_`v'=cond(`p2_`v''<=.01,"***",cond(`p2_`v''<=.05,"**",cond(`p2_`v''<=.1,"*","")))
	
	local l`v' : variable label `v' 

	file write fh "(`n') 	&  `l`v'' 	& `b_`v''`star_`v'' & (`se_`v'') & `b2_`v''`star2_`v'' & (`se2_`v'')  \\ " _n

}

file write fh "\bottomrule\relax" _n	
file close fh 

sc units q71 , m(i) mlab(b_country_alpha)

stop

sc share_fem_donors meanschooling, m(i) mlab(b_country_alpha)
stop

sc share_fem_donors meanschooling, m(i) mlab(b_country_alpha)
sc units share_fem_donors , m(i) mlab(b_country_alpha)

reg units share_fem_donors polity lgdp [aw=popwb2019], robust


reg  share_fem_donors lgdp lifeexpect unemployfem    healthexp educationexp meanschooling womenparl  [aw=popwb2019], robust
