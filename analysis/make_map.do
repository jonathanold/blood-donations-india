 
/*----------------------------------------------------*/
   /* [>   0.  Set globals and file paths   <] */ 
/*----------------------------------------------------*/


global cd "/Volumes/GoogleDrive/My Drive/_Berkeley Research/Blood Donations/"
cd "$cd"

cd "${cd}/Data/Maps/gadm36_IND_shp/"



import delim using "../../India Blood Banks/blood-banks.csv",  bindquote(strict) clear
gen redcross=0
replace redcross = 1 if strpos(bloodbankname," Red ")>0
replace redcross = 1 if strpos(bloodbankname," RED ")>0

replace redcross = 1 if strpos(bloodbankname," Cross ")>0
replace redcross = 1 if strpos(bloodbankname,"IRCS")>0

label define redcrosslbl 0 "Other blood bank" 1 "Red Cross blood bank"
label values redcross redcrosslbl
save "bloodbanks.dta", replace 
use bloodbanks, clear






spshape2dta gadm36_IND_1, ///
		saving(india_states_stata) replace 

use india_states_stata, clear

gen symbol = "✙"

spmap  using india_states_stata_shp, id(_ID) ///
ocolor(gs10) osize(thin) ///
legend(size(*1.5) position(5)) ///
point(data("bloodbanks.dta") xcoord(longitude) ycoord(latitude) ///
	by(redcross) fcol(dkgreen%20  cranberry) ocol(dkgreen cranberry) size(small medlarge) osize(none medthick) shape(smcircle smplus)  ///
	select(keep if latitude>=-5 & latitude<=38 & longitude>=30) ///
	 legenda(on)  leglabel(1 "Red Cross blood bank" 0 "Other blood bank")) 
graph export india_bloodbanks.png, replace






shp2dta using "${cd}/Maps/India_Districts_2016/polbnda_ind.shp", ///
		database("./Maps/India_Districts_2016/polbnda_ind_data.dbf") ///
		coordinates("./Maps/India_districts_centroids.dta") gencentroids(midpoint) genid(id_district) ///
		replace

use "${cd}/Maps/India_Districts_2016/polbnda_ind_data.dbf", clear
save "${cd}/Data/India_Map_with_Coal.dta", replace



 spmap count_county using kencoord, id(county_id)
point(data("cities_population") xcoord(longitude) ycoord(latitude)
proportional(population) fcolor(orange) ocolor(black) select(keep if
population>350000) legenda(on) leglabel(Cities with population >
350,000)) legend(on) fcolor(Blues) clbreaks(0 1001 2001 3001 5001 10001
50000) clmethod(custom) legend(label(2 "0 to 1,000") label(3 "1,001 to
2,000") label(4 "2,001 to 3,000" ) label(5 "3,001 to 5,000" ) label(6
"5,001 to 10,000" ) label(7 "10,000+" ))
graph export establishments_census_cities.png, replace




 /*----------------------------------------------------*/
    /* [>   Map with coal info  <] */ 
 /*----------------------------------------------------*/
 // Uses QGIS output as input

/* [> Map of coalfields 1845 <] */ 
 cd "${cd}/Maps/QGIS_Projects/"
spshape2dta coalfields_1845_referenced, ///
		saving(coalfields_1845-stata) replace 

use coalfields_1845-stata_shp, clear
gen idx_1845 = _n
save coalfields_1845-stata_shp, replace 

 /* [> 1845 map overlay <] */ 
 cd "${cd}/Maps/QGIS_Projects/Districts_with_Coal_New/"

spshape2dta  districts-coal, ///
		saving(districts-coal-stata) replace 


/* [> Modern Map overlay <] */ 
 cd "${cd}/Maps/QGIS_Projects/Map_Districts_With_Modern_Coalfields/"

spshape2dta  intersection, ///
		saving(intersection-stata) replace 

spshape2dta  districts, ///
		saving(districts-stata) replace 

use intersection-stata_shp, clear
gen idx = _n
save intersection-stata_shp, replace 

use districts-stata, clear
merge 1:m idd using  intersection-stata

collapse (firstnm) area_mod (sum) area_it, by(nam laa)

save districts-stata, replace 

cd "$cd"

use "${cd}/Maps/QGIS_Projects/Districts_with_Coal_New/districts-coal-stata.dta", clear
ren Intersec13 area_coal
replace area_coal=0 if missing(area_coal)
gen share_area_coal = area_coal/area

keep _CY _CX fid  nam laa  area share_area_coal area_coal 

ren fid id_district

merge 1:1 nam laa using "${cd}/Maps/QGIS_Projects/Map_Districts_With_Modern_Coalfields/districts-stata.dta"
drop _merge

gen share_area_coal_modern = area_it/area
drop area area_mod area_it
save "${cd}/Data/India_Map_with_Coal.dta", replace



/* [> Map data (for modern districts) <] */ 
use "${cd}/Data/India_Map_with_Coal.dta", replace
keep id_district nam laa share_area_coal share_area_coal_modern
replace nam = lower(nam)
replace laa = lower(laa)
ren nam sname_map
ren laa dname_map
ren id_district did_map
gen sname_original = sname_map
statecodes, sv(sname_original)
/* [> Old state codes <] */ 
replace code="UP" if code=="UT"
replace code="BR" if code=="JH"
replace code="MP" if code=="CT"

replace dname_map="madras" if dname_map=="chennai"

gen matchitname = code + "_" + dname_map

replace matchitname = "MP_shahdol" if matchitname=="MP_umaria"
replace matchitname = "OR_sambalpur" if matchitname=="OR_jharsuguda"
replace matchitname = "BR_giridih" if matchitname=="BR_bokaro"
replace matchitname = "WB_hooghly" if matchitname=="WB_hugli"
replace matchitname = "WB_medinipur" if matchitname=="WB_pashchim medinipur"

save "${cd}/Data/_gen/map_id.dta",  replace 



 /*----------------------------------------------------*/
    /* [>   Crosswalk   <] */ 
 /*----------------------------------------------------*/
import excel using "${cd}/Data/IDs/id_crosswalk.xlsx", firstr clear
save "${cd}/Data/_gen/ids.dta", replace



/*----------------------------------------------------*/
   /* [>   Make district level dataset - merge mines to 2016 district map   <] */ 
/*----------------------------------------------------*/
import delim "${cd}/Data/Coal by Mine/1910_geocoded.csv",  clear 
replace lat_manual="" if lat_manual=="NA"
replace long_manual="" if long_manual=="NA"

destring lat_manual, replace 
destring long_manual,  replace  force

geoinpoly lat_manual long_manual ///
	using "${cd}/Maps/QGIS_Projects/Districts_with_Coal_New/districts-coal-stata_shp.dta", ///
	unique
ren  _ID id_district

merge m:1 id_district using "${cd}/Data/India_Map_with_Coal.dta"
keep if _merge==3

ren id_district did_map

ren workedbyjointstockcompanies joint_sto_co
ren workedbyprivateowners private_owner
ren workedbygovernmentofindia gov_mine
foreach v of varlist joint_sto_co private_owner gov_mine nonactmines {
	replace `v'="0" if `v'=="NA"
	destring `v', replace
} 

replace whenopened = "" if whenopened=="NA"
replace whenopened = substr(whenopened,1,4)
destring whenopened, replace

ren v22 coal_production_1910 
drop v13-v21

save "${cd}/Data/_gen/mines_to_districts.dta", replace

use "${cd}/Data/_gen/mines_to_districts.dta", replace
preserve
keep if joint_sto_co==1 
save "${cd}/Data/_gen/mines_jointstock.dta", replace
restore, preserve
keep if private_owner==1 
save "${cd}/Data/_gen/mines_private.dta", replace
restore, preserve
keep if coal_production_1910!=0
save "${cd}/Data/_gen/active_mines.dta", replace



gen one = 1 
collapse (min) whenopened (mean) joint_sto_co private_owner gov_mine ///
			(sum) coal_production_1910 one, by(nam did_map)

label var whenopened "Year of first coal mine in district"
label var joint_sto_co "Proportion of mines run by joint stock companies"
label var private_owner "Proportion of mines run by private owners"
label var gov_mine "Proportion of mines run by government"
label var coal_production_1910 "Total district-level coal production in 1910"
ren one no_mines
label var no_mines "Number of mines in district in 1910"
 
 save "${cd}/Data/_gen/district_mine_data.dta", replace








/*----------------------------------------------------*/
   /* [>   Clean secondary datasets   <] */ 
/*----------------------------------------------------*/

/* [> Xu <] */ 
use "${cd}/Data/Xu_bureaucrat-representation/data/crosswalk.dta", clear
drop cid
collapse (firstnm) town, by(state district)
drop town
ren district dname_xu
ren state pname_xu
save "${cd}/Data/_gen/xu_id.dta",  replace 

/* [> Iyer <] */ 
use "${cd}/Data/Iyer_Indirect-rule/Rawfiles/dist_brit.dta", clear
keep dist_81 state dist_91 dist_old province dcode_full
foreach v of varlist dist_81 state dist_91 dist_old province  {
	replace `v' = subinstr(`v', "+", " ", 9)
	replace `v' = subinstr(`v', "  ", " ", 10)
	replace `v' = subinstr(`v', "  ", " ", 10)
	replace `v' = lower(`v')
}
ren dcode_full did_iyer
ren province pname_iyer
ren state sname_iyer

ren dist_81 dname_iyer_81
ren dist_91 dname_iyer_91
ren dist_old dname_iyer_old

statecodes, sv(sname_iyer)
/* [> Old state codes <] */ 
replace code="UP" if code=="UT"
replace code="BR" if code=="JH"
replace code="MP" if code=="CT"

gen matchitname = code + "_" + dname_iyer_91
duplicates drop matchitname, force
save "${cd}/Data/_gen/iyer_id.dta",  replace 


/* [> Donaldson <] */ 
use "${cd}/Data/Donaldson_railways/Data/crosswalks/district-block_correlation.dta", clear
ren provname pname_donaldson
ren distname dname_donaldson

keep pname_donaldson dname_donaldson 
save "${cd}/Data/_gen/donaldson_id.dta",  replace 



/* [> Prepare Iyer data <] */ 
use "${cd}/Data/Iyer_Indirect-rule/table4.dta", clear

ren dcode_full did_iyer

save "${cd}/Data/_gen/iyer_full.dta", replace 





 
/*----------------------------------------------------*/
   /* [>   Make district level dataset- for historic data with Iyer data   <] */ 
/*----------------------------------------------------*/
use "${cd}/Data/Iyer_Indirect-rule/table11b.dta", clear

ren province p_iyer
ren dist_old d_iyer
save "${cd}/Data/_gen/iyer_historic.dta", replace 



import delim "${cd}/Data/Coal by Mine/1910_geocoded.csv",  clear 
replace lat_manual="" if lat_manual=="NA"
replace long_manual="" if long_manual=="NA"

destring lat_manual, replace 
destring long_manual,  replace  force


ren workedbyjointstockcompanies joint_sto_co
ren workedbyprivateowners private_owner
ren workedbygovernmentofindia gov_mine
foreach v of varlist joint_sto_co private_owner gov_mine nonactmines {
	replace `v'="0" if `v'=="NA"
	destring `v', replace
} 

replace whenopened = "" if whenopened=="NA"
replace whenopened = substr(whenopened,1,4)
destring whenopened, replace

ren v22 coal_production_1910 

gen one=1
collapse (firstnm) sno (min) whenopened ///
			(mean) joint_sto_co private_owner gov_mine ///
			(sum) coal_production_1910 one ///
			, by(province district)
drop if district=="NA"


merge 1:1 province district using "${cd}/Data/_gen/ids.dta"
drop _merge

drop if mi(p_iyer)
drop if mi(d_iyer)
merge 1:1 p_iyer d_iyer using "${cd}/Data/_gen/iyer_historic.dta"

ren one no_mines
replace coal_production_1910=0 if coal_production_1910==.
replace no_mines=0 if no_mines==.
 
gen log_coal = ln(coal_production_1910+1)

 save "${cd}/Data/_gen/ready_for_analysis/analysis_with_iyer_historical.dta",  replace 




/*----------------------------------------------------*/
   /* [>   Make district level dataset- for historic data with Xu data   <] */ 
/*----------------------------------------------------*/

use "${cd}/Data/Xu_bureaucrat-representation/data/influenza_town_panel.dta", clear 
collapse (firstnm) year, by(cid did)
drop year 
merge 1:1 cid using "${cd}/Data/Xu_bureaucrat-representation/data/crosswalk.dta"
collapse (firstnm) cid, by(did state district)

ren (state district) (pname_xu	dname_xu)
drop cid
merge 1:1 did using "${cd}/Data/Xu_bureaucrat-representation/data/influenza_allocation_level.dta"
drop _merge
save "${cd}/Data/_gen/xu_data.dta", replace


import delim "${cd}/Data/Coal by Mine/1910_geocoded.csv",  clear 
replace lat_manual="" if lat_manual=="NA"
replace long_manual="" if long_manual=="NA"

destring lat_manual, replace 
destring long_manual,  replace  force


ren workedbyjointstockcompanies joint_sto_co
ren workedbyprivateowners private_owner
ren workedbygovernmentofindia gov_mine
foreach v of varlist joint_sto_co private_owner gov_mine nonactmines {
	replace `v'="0" if `v'=="NA"
	destring `v', replace
} 

replace whenopened = "" if whenopened=="NA"
replace whenopened = substr(whenopened,1,4)
destring whenopened, replace

ren v22 coal_production_1910 

gen one=1
collapse (firstnm) sno (min) whenopened ///
			(mean) joint_sto_co private_owner gov_mine ///
			(sum) coal_production_1910 one ///
			, by(province district)
drop if district=="NA"


merge 1:1 province district using "${cd}/Data/_gen/ids.dta"
drop _merge


drop if mi(pname_xu)
drop if mi(dname_xu)

merge 1:1 pname_xu dname_xu using "${cd}/Data/_gen/xu_data.dta",


ren one no_mines
replace coal_production_1910=0 if coal_production_1910==.
replace no_mines=0 if no_mines==.
 
 gen log_coal = ln(coal_production_1910+1)

 save "${cd}/Data/_gen/ready_for_analysis/analysis_with_xu.dta",  replace 







 
/*----------------------------------------------------*/
   /* [>   Make district level dataset - for contemporary IYER analysis  <] */ 
/*----------------------------------------------------*/

// Merge using matchit
		//  matchit idmaster txtmaster using filename.dta , idusing(varname) txtusing(varname)
use "${cd}/Data/_gen/map_id.dta",  replace       
matchit did_map matchitname using "${cd}/Data/_gen/iyer_id.dta", idusing(did_iyer) txtusing(matchitname)

// Drop observations from different states
drop if  substr(matchitname,1,2)!=substr(matchitname1,1,2)

replace similscore = round(similscore, 0.0001)
cap drop max_*
bysort matchitname: egen max_1 = max(similscore)
bysort matchitname1: egen max_2 = max(similscore) 


cap drop keep
gen keep = 0
replace keep = 1 if round(similscore,0.0001) == round(max_1,0.0001) & round(max_1,0.0001) == round(max_2,0.0001)
bysort matchitname1: egen max_3 = max(keep)
bysort matchitname: egen max_4 = max(keep)

// Notes and manual changes
//BR_saraikela - was part of BR_pashchimi singhbhum
replace matchitname1 = "BR_pashchim singhbhum" if matchitname=="BR_saraikela"
replace did_iyer=329 if matchitname=="BR_saraikela"
//JK_gilgit - drop
drop if matchitname=="JK_gilgit"
// JK-riasi - Was part of JK_udhampur
replace matchitname1 = "JK_udhampur" if matchitname=="JK_riasi"
replace did_iyer=814 if matchitname=="JK_riasi"
replace similscore=1 if matchitname=="JK_riasi"


//TN_karur - was part of TN_tiruchirapalli
replace matchitname1 = "TN_tiruchirapalli" if matchitname=="TN_karur"
replace did_iyer=2119 if matchitname=="TN_karur"

//TN_ariyalur - was part of TN_tiruchirapalli
replace matchitname1 = "TN_tiruchirapalli" if matchitname=="TN_ariyalur"
replace did_iyer=2119 if matchitname=="TN_ariyalur"


replace matchitname1="AS_goalpara" if matchitname=="AS_bongaigaon"
replace matchitname1="BR_bhagalpur" if matchitname=="BR_banka"
replace matchitname1="BR_rohtas" if matchitname=="BR_bhabhua"
replace matchitname1="BR_hazaribag" if matchitname=="BR_chatra"
replace matchitname1="BR_palamau" if matchitname=="BR_garhwa"
replace matchitname1="BR_dumka" if matchitname=="BR_jamtara"
replace matchitname1="BR_hazaribag" if matchitname=="BR_kodarma"
replace matchitname1="BR_munger" if matchitname=="BR_lakhisarai"
replace matchitname1="BR_palamau" if matchitname=="BR_latehar"
replace matchitname1="BR_sahibganj" if matchitname=="BR_pakur"
replace matchitname1="BR_munger" if matchitname=="BR_sheikhpura"
replace matchitname1="BR_sitamarhi" if matchitname=="BR_sheohar"
replace matchitname1="BR_gumla" if matchitname=="BR_simdega"


replace did_iyer=207 if matchitname=="AS_bongaigaon"
replace did_iyer=304 if matchitname=="BR_banka"
replace did_iyer=335 if matchitname=="BR_bhabhua"
replace did_iyer=315 if matchitname=="BR_chatra"
replace did_iyer=327 if matchitname=="BR_garhwa"
replace did_iyer=309 if matchitname=="BR_jamtara"
replace did_iyer=315 if matchitname=="BR_kodarma"
replace did_iyer=323 if matchitname=="BR_lakhisarai"
replace did_iyer=327 if matchitname=="BR_latehar"
replace did_iyer=337 if matchitname=="BR_pakur"
replace did_iyer=323 if matchitname=="BR_sheikhpura"
replace did_iyer=340 if matchitname=="BR_sheohar"
replace did_iyer=314 if matchitname=="BR_simdega"


replace keep=1 if matchitname=="AS_bongaigaon"
replace keep=1 if matchitname=="BR_banka"
replace keep=1 if matchitname=="BR_bhabhua"
replace keep=1 if matchitname=="BR_chatra"
replace keep=1 if matchitname=="BR_garhwa"
replace keep=1 if matchitname=="BR_jamtara"
replace keep=1 if matchitname=="BR_kodarma"
replace keep=1 if matchitname=="BR_lakhisarai"
replace keep=1 if matchitname=="BR_latehar"
replace keep=1 if matchitname=="BR_pakur"
replace keep=1 if matchitname=="BR_sheikhpura"
replace keep=1 if matchitname=="BR_sheohar"
replace keep=1 if matchitname=="BR_simdega"


replace similscore=1 if matchitname=="AS_bongaigaon"
replace similscore=1 if matchitname=="BR_banka"
replace similscore=1 if matchitname=="BR_bhabhua"
replace similscore=1 if matchitname=="BR_chatra"
replace similscore=1 if matchitname=="BR_garhwa"
replace similscore=1 if matchitname=="BR_jamtara"
replace similscore=1 if matchitname=="BR_kodarma"
replace similscore=1 if matchitname=="BR_lakhisarai"
replace similscore=1 if matchitname=="BR_latehar"
replace similscore=1 if matchitname=="BR_pakur"
replace similscore=1 if matchitname=="BR_sheikhpura"
replace similscore=1 if matchitname=="BR_sheohar"
replace similscore=1 if matchitname=="BR_simdega"


keep if keep==1
drop if similscore <= 0.55

drop max_1 max_2 max_3 max_4 keep
cap drop t1 t2 t3

duplicates drop did_map, force

save "${cd}/Data/_gen/matchit.dta", replace
use "${cd}/Data/_gen/matchit.dta", clear

ren matchitname1 dname_iyer_91
// duplicates drop dname_iyer_91, force
gen code = substr(dname_iyer_91,1,2)
replace dname_iyer_91 = substr(dname_iyer_91, 4, .)

			   
merge m:1 dname_iyer_91 code using "${cd}/Data/_gen/iyer_id.dta"
drop _merge

merge m:1 did_iyer using "${cd}/Data/_gen/iyer_full.dta"
// keep if _merge ==3
drop _merge 

drop if did_map==. 

merge 1:1 did_map using "${cd}/Data/_gen/district_mine_data.dta"
drop _merge 

merge 1:1 did_map using "${cd}/Data/_gen/map_id.dta"
drop _merge

replace coal_production_1910=0 if coal_production_1910==.
replace no_mines=0 if no_mines==.
 
 gen log_coal = ln(coal_production_1910+1)


// Change britdum for wrong classifications (see jhaImpact2021)
replace britdum = 0 if dname_iyer_91 == "solan"
replace britdum = 0 if dname_iyer_91 == "bastar"
replace britdum = 0 if dname_iyer_91 == "balangir"
replace britdum = 0 if dname_iyer_91 == "dangs"

replace britdum = 1 if dname_iyer_91 == "chamoli"

gen idx = sname_map+dname_map
save "${cd}/Data/_gen/ready_for_analysis/analysis_with_iyer_contemp.dta",  replace 

export delim using  "${cd}/Maps/QGIS_Projects/csv-with-iyer.csv", replace




/*----------------------------------------------------*/
   /* [>   Village maps  <] */ 
/*----------------------------------------------------*/
 cd "${cd}/Data/Village Maps/Intersected/"

 // Uses QGIS output as input
spshape2dta  jrkd, ///
		saving(jrkd-stata) replace 

spshape2dta  wb, ///
		saving(wb-stata) replace 

use "jrkd-stata.dta", clear
gen _X = _CX
gen _Y = _CY
save "jrkd-stata.dta", replace 

use "wb-stata", clear
gen _X = _CX
gen _Y = _CY
save "wb-stata.dta", replace 






 cd "$cd"

/*----------------------------------------------------*/
   /* [>   ACLED DATA READ IN   <] */ 
/*----------------------------------------------------*/

import delim using "./Data/ACLED/acled_india.csv", clear delim(";")
keep if geo_precision == 1 | geo_precision==2
gen one = 1
 

geoinpoly latitude longitude ///
	using "./Data/Village Maps/Intersected/jrkd-stata_shp.dta", ///
	unique
collapse (sum) one fatalities , by(_ID)
ren one conflict_events

merge 1:1 _ID using "./Data/Village Maps/Intersected/jrkd-stata.dta"
drop _merge
save "./Data/Village Maps/Intersected/jrkd-stata.dta", replace 



import delim using "./Data/ACLED/acled_india.csv", clear delim(";")
keep if geo_precision == 1 | geo_precision==2
gen one = 1

geoinpoly latitude longitude ///
	using "./Data/Village Maps/Intersected/wb-stata_shp.dta", ///
	unique

collapse (sum) one fatalities , by(_ID)
ren one conflict_events

merge 1:1 _ID using "./Data/Village Maps/Intersected/wb-stata.dta"
drop _merge
save "./Data/Village Maps/Intersected/wb-stata.dta", replace 



 cd "${cd}/Data/Village Maps/Intersected/"

use "jrkd-stata.dta", clear
append using "wb-stata", force

drop _ID

geoinpoly _CY _CX ///
	using "${cd}/Maps/QGIS_Projects/Districts_with_Coal_New/districts-coal-stata_shp.dta", ///
	unique

ren  _ID id_district
ren *, lower
br state area*

ren area area_old 
ren area_1 area
ren i_area_i area_coal
replace area_coal = iwb_area_i if mi(area_coal)

replace area_coal = 0 if mi(area_coal)
replace area_coal=1 if area_coal!=0

ren *, lower

gen plit = p_lit/tot_p
gen work = tot_work_p / tot_p
gen health = (all_hosp + h_cntr)/tot_p 
gen relhosp = (all_hosp)/tot_p 

// reg relhosp area_coal

drop if vill_code=="" 
duplicates drop vill_code sid, force

gen did_map = id_district
merge m:1 did_map using "${cd}/Data/_gen/ready_for_analysis/analysis_with_iyer_contemp.dta", force
drop if _merge==2
drop _merge 

drop whenopened-no_mines
drop iwb_sid-iwb_coor_1
drop i_sid-i_coordi_1
save "${cd}/Data/_gen/villages-with-coal.dta", replace



/*----------------------------------------------------*/
   /* [>   Merge villages with SHRUG data   <] */ 
/*----------------------------------------------------*/
cd "$cd"

use "${cd}/Data/SHRUG/shrug-v1.2.samosa-keys-dta/shrug_pc01r_key.dta", clear
compress

gen c_code01 = pc01_state_id+ pc01_district_id+ pc01_subdistrict_id+ pc01_village_id

merge 1:1 c_code01 using "${cd}/Data/_gen/villages-with-coal.dta"
keep if _merge==3
drop _merge
duplicates drop shrid, force
merge 1:1 shrid using "${cd}/Data/SHRUG/shrug-v1.5.samosa-nl-dta/shrug-v1.5.samosa-nl-dta/shrug_nl_wide.dta"

// reg mean_light_1994 area_coal
// reg total_light_cal_2004 area_coal tot_p area

drop _merge 
merge 1:1 shrid using "${cd}/Data/SHRUG/shrug-v1.5.samosa-secc-dta/shrug-v1.5.samosa-secc-dta/shrug_secc.dta"
drop _merge
compress

merge 1:1 shrid using "${cd}/Data/SHRUG/shrug-v1.5.samosa-pop-econ-census-dta/shrug-v1.5.samosa-pop-econ-census-dta/shrug_ec.dta"
drop _merge
compress


merge 1:1 shrid using "${cd}/Data/SHRUG/shrug-v1.5.samosa-pop-econ-census-dta/shrug-v1.5.samosa-pop-econ-census-dta/shrug_pc11.dta"
drop _merge
compress

drop death* dsp* depose* 


/*----------------------------------------------------*/
   /* [>   Calculate distance to nearest coal mines   <] */ 
/*----------------------------------------------------*/
geonear shrid _CY _CX using "${cd}/Data/_gen/mines_to_districts.dta" , neighbors(sno lat_manual long_manual) 
ren (nid km_to_nid) (nid_all km_to_nid_all)

geonear shrid _CY _CX using "${cd}/Data/_gen/mines_jointstock.dta" , neighbors(sno lat_manual long_manual) 
ren (nid km_to_nid) (nid_joint km_to_nid_joint)

geonear shrid _CY _CX using "${cd}/Data/_gen/mines_private.dta" , neighbors(sno lat_manual long_manual) 
ren (nid km_to_nid) (nid_private km_to_nid_private)

geonear shrid _CY _CX using "${cd}/Data/_gen/active_mines.dta" , neighbors(sno lat_manual long_manual) 
ren (nid km_to_nid) (nid_active km_to_nid_active)

geonear shrid _CY _CX using "${cd}/Maps/QGIS_Projects/Map_Districts_With_Modern_Coalfields/intersection-stata_shp.dta", neighbors(idx _Y _X) 
ren (nid km_to_nid) (idx_modern km_to_nearest_field_modern)

geonear shrid _CY _CX using "${cd}/Maps/QGIS_Projects/coalfields_1845-stata_shp.dta", neighbors(idx_1845 _Y _X) 
ren (nid km_to_nid) (idx_old km_to_nearest_field_1845)



compress
cap drop death* dsp* depose* 

save "${cd}/Data/_gen/ready_for_analysis/analysis_with_villages_and_shrug.dta",  replace 






	
	
	
	
	
	
	

/* Garbage bin



shp2dta using "${cd}/Maps/India_Districts_2016/polbnda_ind.shp", ///
		database("./Maps/India_Districts_2016/polbnda_ind_data.dbf") ///
		coordinates("./Maps/India_districts_centroids.dta") gencentroids(midpoint) genid(id_district) ///
		replace

use "${cd}/Maps/India_Districts_2016/polbnda_ind_data.dbf", clear
save "${cd}/Data/India_Map_with_Coal.dta", replace





/*
  shp2dta using "${cd}/Maps/QGIS_Projects/Districts_with_Coal_New/districts-coal.shp", ///
		database("${cd}/Maps/QGIS_Projects/Districts_with_Coal_New/districts-coal.dbf") ///
		coordinates("./Maps/India_districts_centroids_new.dta") gencentroids(midpoint) genid(id_district) ///
		replace
*/



 ivreg2 pprimary (log_coal=share_area_coal)
/*----------------------------------------------------*/
   /* [>   4.  Geoinpoly: Match mines to present-day districts   <] */ 
/*----------------------------------------------------*/

geoinpoly latitude longitude ///
	using "./Maps/India_Maps_New/assembly-constituencies/India_AC.dta", ///
	unique


 
/*----------------------------------------------------*/
   /* [>   5.  Match mines to mine ownership data   <] */ 
/*----------------------------------------------------*/



