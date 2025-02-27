// Merge and analyze eRaktKosh data
clear 

cd "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/"
global data "/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Data/India Blood Banks/eRaktKosh_scraped/"


local file_list: dir "${data}" files "*.csv"   // Replace "*.dta" with the file extension you are interested in
tempfile x
tempfile y


foreach file in `file_list' {
    // Your code to process each file goes here
    import delim "${data}/`file'", clear  // Display the current file name as an example
    local date = substr("`file'", 19, 10)
    gen date = "`date'"
    save `y', replace
    capt use `x', clear
    if _rc!=0 {
	    save `x', replace
	    }
	else {
	    append using `y'
	    save `x', replace 
	    }
}

gsort stateid districtid name date
order stateid districtid name date

duplicates drop stateid districtid name address date, force
 
/*----------------------------------------------------*/
   /* [>   1.  Clean variables   <] */ 
/*----------------------------------------------------*/

/* [> State codes <] */


/* [> District IDs <] */  


/* [> Names <] */ 


/* [> Phone <] */ 
replace phone = "" if phone=="0" | phone=="-" | phone=="000"
replace phone = subinstr(phone, " ", "", 10)
replace phone = subinstr(phone, "-", "", 10)
split phone, p(",")


/* [> Email <] */ 
replace email = "" if email=="0" | email=="-" | email=="000"
split email, p(",")

/* [> Category <] */ 
encode category, gen(cat)

/* [> Availability <] */ 
replace availability = subinstr(availability, "Available, ", "", 1)

foreach grp in "A" "B" "AB" "O" {
   gen `grp'Pos = regexs(1) if regexm(availability, " `grp'\+Ve:([0-9]+)") 
   destring `grp'Pos, replace  
   replace `grp'Pos=0 if missing(`grp'Pos)
   gen `grp'Neg = regexs(1) if regexm(availability, " `grp'\-Ve:([0-9]+)") 
   destring `grp'Neg, replace  
   replace `grp'Neg=0 if missing(`grp'Neg)

   }


/* [> Last update <] */ 
gen live = 0
replace live = 1 if lastupdate=="<img src='../hisglobal/bbpublic/images/transparent/live_stock.png'>"
replace lastupdate = "" if lastupdate=="<img src='../hisglobal/bbpublic/images/transparent/live_stock.png'>"

gen lastupdate_num = clock(lastupdate, "YMD hms")
format lastupdate_num %tc
format latest_update %tc

order lastupdate_num, after(lastupdate)

bys date: egen latest_update = max(lastupdate_num)
replace lastupdate_num = latest_update if live==1 

gen update_diff = latest_update - lastupdate_num
format update_diff %tc
cap drop update_diff2
gen update_diff2 =  clockdiff(lastupdate_num, latest_update, "s")
replace update_diff2 = update_diff2/(3600*24)

/* [> Final cleaning <] */ 
rename *, lower
cap drop date2
gen date2 = date(date, "YMD")
cap drop bbid
egen bbid = group(stateid districtid name address)
gen one = 1

bys bbid: egen obs_per_bbid=count(one)

xtset bbid date2

reg apos aneg bpos bneg abpos abneg opos oneg
xtreg apos aneg bpos bneg abpos abneg opos oneg, fe

reghdfe apos aneg bpos bneg abpos abneg opos oneg, noabsorb
reghdfe apos aneg bpos bneg abpos abneg opos oneg, absorb(districtid date2)

reghdfe apos  c.update_diff##c.update_diff i.live, noabsorb
reghdfe apos aneg bpos bneg abpos abneg opos oneg c.update_diff##c.update_diff i.live, noabsorb

egen total_wb = rowtotal(apos aneg bpos bneg abpos abneg opos oneg)
egen total_wb_pos = rowtotal(apos bpos abpos  opos )
egen total_wb_neg = rowtotal(aneg bneg abneg  oneg )


gen lupdate = log(update_diff)
gen ltotal_wb = log(total_wb)

gen lup = log(update_diff2+1)


reghdfe total_wb  update_diff2 , noabsorb
  qui sum total_wb if e(sample)
  estadd scalar lmean = r(mean)
est sto reg1 



reghdfe total_wb  update_diff2 , absorb(districtid date2 institutiontype category)
  qui sum total_wb if e(sample)
  estadd scalar lmean = r(mean)
est sto reg2 

reghdfe total_wb  update_diff2 , absorb(districtid date2 institutiontype category bbid)
  qui sum total_wb if e(sample)
  estadd scalar lmean = r(mean)
est sto reg3




#delimit ;
estout 
reg1 reg2  reg3 
using "Output/Tables/suggestive.tex" , style(tex)  
wrap varwidth(85) 
varlabels(update_diff2 "Time since last update, in days"  _cons "Constant" 
  )
   cells(b(star fmt(%9.3f)) se(par)) 
 hlinechar("{hline @1}")
stats( lmean N   , fmt(%9.3fc  %9.0fc ) labels( "\midrule  Mean of DV" "Observations"))
starlevels(* 0.1 ** 0.05 *** 0.01)
nolabel replace collabels(none) mlabels(none)
note("\bottomrule")
  ; 
#delimit cr 



