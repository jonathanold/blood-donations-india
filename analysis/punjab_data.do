// Punjab.do
cd "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Data/Punjab/"

set scheme mine 

import excel using "Updated Compiled data for the year 2022-23(1).xlsx", ///
		sheet("April 2022") clear cellrange(A6)
save "../_gen/Punjab_all.dta", replace
gen month="April"
gen year=2022

foreach month in January February March April May June July August September October November December {
	foreach year in 2022 2023 {
	cap import excel using "Updated Compiled data for the year 2022-23(1).xlsx", ///
		sheet("`month' `year'") clear cellrange(A6)
	if _rc==0 {
		gen month = "`month'"
		gen year = `year'
		save "../_gen/Punjab_`month'_`year'.dta", replace
		use "../_gen/Punjab_all.dta", clear
		append using "../_gen/Punjab_`month'_`year'.dta", force
		save "../_gen/Punjab_all.dta", replace
		}
	}
}

use "../_gen/Punjab_all.dta", clear
duplicates drop A B C month year , force



ren (A B C D E F G) ///
	(sno district bb_name male_v_bb female_v_bb male_v_camp female_v_camp)
ren (H I J K L M N O P) ///
	(male_family female_family male_replacement female_replacement total_collected vbd_collected vbd_camp vbd_total share_vbd)
ren (Q R S T U V W X Y Z) ///
	(no_camps discard_outdated discard_sero_react discard_others discard_total discard_share discard_excl_tti discard_share_excl_tti hiv_v_tested hiv_v_positive)

ren (BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM) ///
	(repeat_male repeat_female repeat_total counseled_mal counseled_female counceled_total anemia_male anemia_female anemia_total uw_ua_male uw_ua_female uw_ua_total medical_male medical_female medical_total highrisk_male highrisk_female highrisk_total others_male others_female others_total deferred_male_ttl deferred_female_ttl deferred_ttl_ttl)

cap drop moy
cap ren month mox
gen moy = month(date(mox, "M"))

reg total_collected i.moy no_camps
reg vbd_collected i.moy no_camps
reg male_family i.moy no_camps, vce(cluster district)

encode district, gen(d)
reg total_collected male_replacement i.moy i.d
reg total_collected male_family male_replacement i.moy ib1.d

gen share_vol_camp = vbd_camp/total_collected

reg share_vol_camp  i.moy 
reg male_replacement  i.moy 
 coefplot, keep(1.moy 2.moy 3.moy 4.moy 5.moy 6.moy 7.moy 8.mou 9.moy 10.moy 11.moy 12.moy)




hist share_vol_camp


