cd "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Data/"
set scheme mine 

import excel "./Tweets/owid-covid-data.xlsx", clear firstr

keep if location=="India"
keep date *_cases *_deaths 
save "./Tweets/covid.dta", replace 

import delim "./Tweets/df_for_analysis.csv", clear varnames(1)  bindquote(strict)

split timestamp, gen(date) p(" ")
ren date2 time 
// ren date1 date

gen one = 1 
collapse (sum) units one , by(date) 


merge 1:1 date using "./Tweets/covid.dta"
drop if _merge==2

foreach v of varlist total_cases new_cases total_deaths new_deaths {
	replace `v'=0 if `v'==.
}

gen year = substr(date,1,4)
destring year, replace 
gen month = substr(date,6,2)
destring month, replace 


collapse (sum) units one new_cases new_deaths, by(year month)

gen datem = ym(year, month)
format datem %tm 
tsset datem 

tsline one 
tsline units
gen lu = log(units)
tsline lu

cap drop covid  
gen covid = 0
replace covid = 1 if date==ym(2021, 4)
replace covid = 1 if date==ym(2021, 5)
replace covid = 1 if date==ym(2021, 6)
replace covid = 1 if date==ym(2021, 7)
replace covid = 1 if date==ym(2021, 8)
replace covid = 1 if date==ym(2021, 9)

reg one c.datem##c.datem##c.datem##c.datem##c.datem new_deaths c new_cases ib1.month
coefplot, drop(_cons datem *date* *ovid new* *new*)

reg units c.datem##c.datem##c.datem##c.datem##c.datem new_deaths c new_cases ib1.month
coefplot, drop(_cons datem *date* *ovid new* *new*)



 noci


