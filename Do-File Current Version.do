global mypath "C:\Users\Joachim\Box Sync\Joe\Research\CMU\Christina Fong\DG_AE\"
insheet using "${mypath}Master_Data_DG_AE_exit1.csv", clear

recode drugabuse (-1=.)
recode giveinfo9 (-1=.)
recode giveinfo10 (-1=.)
recode giveknown9 (-1=.)
recode giveknown10 (-1=.)
recode giveunknown10 (-1=.)

* Treatment reminders:
* CHOICE: 
* Info = choiceinfo9
* no info = choicenoinfo10
* EXOG:
* info $9 = nochoiceinfo9
* info $10 = nochoiceinfo10
* no info = nochoicenoinfo10

* TPeriod treaments (stands for in which period you have one of the treatments below):
* 1 = nochoicenoinfo10 
* 2 = nochoiceinfo10
* 3 = nochoiceinfo9
* 4 = choice
* e.g. t4period stands for in which period do you have the choice treatment.s

* cluster by condition order 
gen order = .

replace order = 1 if (t1period == 4 & t2period == 3 & t3period==2 & t4period == 1)
replace order = 2 if (t1period == 4 & t2period == 2 & t3period==3 & t4period == 1)
replace order = 3 if (t1period == 4 & t2period == 3 & t3period==1 & t4period == 2)
replace order = 4 if (t1period == 4 & t2period == 2 & t3period==1 & t4period == 3)
replace order = 5 if (t1period == 4 & t2period == 1 & t3period==2 & t4period == 3)
replace order = 6 if (t1period == 4 & t2period == 1 & t3period==3 & t4period == 2)

replace order = 7 if (t1period == 3 & t2period == 4 & t3period==2 & t4period == 1)
replace order = 8 if (t1period == 2 & t2period == 4 & t3period==3 & t4period == 1)
replace order = 9 if (t1period == 3 & t2period == 4 & t3period==1 & t4period == 2)
replace order = 10 if (t1period == 2 & t2period == 4 & t3period==1 & t4period == 3)
replace order = 11 if (t1period == 1 & t2period == 4 & t3period==2 & t4period == 3)
replace order = 12 if (t1period == 1 & t2period == 4 & t3period==3 & t4period == 2)

replace order = 13 if (t1period == 3 & t2period == 2 & t3period==4 & t4period == 1)
replace order = 14 if (t1period == 2 & t2period == 3 & t3period==4 & t4period == 1)
replace order = 15 if (t1period == 3 & t2period == 1 & t3period==4 & t4period == 2)
replace order = 16 if (t1period == 2 & t2period == 1 & t3period==4 & t4period == 3)
replace order = 17 if (t1period == 1 & t2period == 2 & t3period==4 & t4period == 3)
replace order = 18 if (t1period == 1 & t2period == 3 & t3period==4 & t4period == 2)

replace order = 19 if (t1period == 3 & t2period == 2 & t3period==1 & t4period == 4)
replace order = 20 if (t1period == 2 & t2period == 3 & t3period==1 & t4period == 4)
replace order = 21 if (t1period == 3 & t2period == 1 & t3period==2 & t4period == 4)
replace order = 22 if (t1period == 2 & t2period == 1 & t3period==3 & t4period == 4)
replace order = 23 if (t1period == 1 & t2period == 2 & t3period==3 & t4period == 4)
replace order = 24 if (t1period == 1 & t2period == 3 & t3period==2 & t4period == 4)

gen ordchoice = . 
replace ordchoice = cond(t1period == 4, 1, cond(t2period == 4, 2, cond(t3period == 4, 3, 4)))

gen choice = .
replace choice = cond(giveinfo9 != ., giveinfo9, cond(giveinfo10 != ., giveinfo10, .))

gen choiceinfo9 = .
replace choiceinfo9 = giveinfo9

gen choicenoinfo10 = .
replace choicenoinfo10 = giveinfo10

gen nochoiceinfo9 = .
replace nochoiceinfo9 = giveknown9

gen nochoiceinfo10 = .
replace nochoiceinfo10 = giveknown10

gen nochoicenoinfo10 = .
replace nochoicenoinfo10 = giveunknown10

gen Tchoice = .
replace Tchoice = cond(choiceinfo9 != . | choicenoinfo10 != ., 1, 0) 

gen white = .
replace white = cond(race == 1, 1, 0)

gen non_white =.
replace non_white = cond(race != 1, 1, 0)

gen disabled = .
replace disabled = cond(drugabuse == 0, 1, 0)

gen periodsq = period*period

gen periodnew = period - 1

egen offer = rowtotal (choicenoinfo10 choiceinfo9 nochoicenoinfo10 nochoiceinfo9 nochoiceinfo10), missing

* This produced 7 missing values, they have no data at all, so we omit these in our analysis

drop if offer == .

egen sum_offer = sum(offer), by(id)


gen p2 = .
replace p2 = cond(period == 2, 1, 0)

gen p3 = .
replace p3 = cond(period == 3, 1, 0)

gen p4 = .
replace p4 = cond(period == 4, 1, 0)

save Master_Data_DG_AE_cond, replace

* Eliminating participants with more or less than 4 lines

sort id

gen count = .

local N = _N
qui forvalues i = 1/`N'{
	if(id[`i'] != id[`i'-1]){
		replace count = 1 in `i'
	}
	else if(id[`i'] == id[`i'-1]){
		replace count = count[`i'-1] + 1 in `i'
	}
	local i = `i' + 1
}

gen finalcount = .

local i = 1
local N = _N
qui forvalues i = 1/`N'{
	if(id[`i'] == id[`i']){
		replace finalcount = count[`i'] in `i'
	}
	if(id[`i'] == id[`i'+1]){
		replace finalcount = count[`i'+1] in `i'
	}
	if(id[`i'] == id[`i'+2]){
		replace finalcount = count[`i'+2] in `i'
	}
	if(id[`i'] == id[`i'+3]){
		replace finalcount = count[`i'+3] in `i'
	}
	if(id[`i'] == id[`i'+4]){
		replace finalcount = count[`i'+4] in `i'
	}
	if(id[`i'] == id[`i'+5]){
		replace finalcount = count[`i'+5] in `i'
	}
	if(id[`i'] == id[`i'+6]){
		replace finalcount = count[`i'+6] in `i'
	}
	if(id[`i'] == id[`i'+7]){
		replace finalcount = count[`i'+7] in `i'
	}
	local i = `i' + 1
}

gen lines = . 
replace lines = cond(finalcount != 4, 1, 0)

sort lines id

drop if lines == 1

save Master_Data_DG_AE_cond, replace

*** Checking for multiple reicipients. ***

gen multiplerecip = .
replace multiplerecip = .
gsort +id -recipientid
local N = _N
qui forvalues i = 1/`N'{
	if(id[`i'-1] == id[`i']){
		if(recipientid[`i'] == recipientid[`i' - 1]){
			replace multiplerecip = 1 in `i'
			local i = `i' -1
			replace multiplerecip = 1 in `i'
			local i = `i' -1 
			replace multiplerecip = 1 if id[`i'+2] == id[`i'] in `i'
			local i = `i' -1 
			replace multiplerecip = 1 if id[`i'+3] == id[`i'] in `i'
			local i = `i' -1 
			replace multiplerecip = 1 if id[`i'+4] == id[`i'] in `i'
			
			local i = `i' + 5
			replace multiplerecip = 1 if id[`i'-1] == id[`i'] in `i'
			local i = `i' + 1
			replace multiplerecip = 1 if id[`i'-2] == id[`i'] in `i'
			local i = `i' + 1
			replace multiplerecip = 1 if id[`i'-3] == id[`i'] in `i'
			local i = `i' + 1
			replace multiplerecip = 1 if id[`i'-4] == id[`i'] in `i'
			
		}
	}
}

drop if multiplerecip == 1

save Master_Data_DG_AE_cond, replace

*** Creating types ***

gen d_choicenoinfo = .
replace d_choicenoinfo = cond(choicenoinfo10 != . , 1, 0)

gen d_choiceinfo = .
replace d_choiceinfo = cond(choiceinfo9 != ., 1, 0)

gsort +id +d_choiceinfo -d_choicenoinfo

* type 1 are those who bought information 
gen type1 = .

local N = _N
qui forvalues i = 1/`N' {
		if (d_choiceinfo[`i'] == 1) {
			replace type1 = 1 in `i'
			local i = `i' - 1
			replace type1 = 1 in `i'
			local i = `i' - 1
			replace type1 = 1 in `i'
			local i = `i' - 1
			replace type1 = 1 in `i'
		}
		else {
			replace type1 = 0 in `i'
			local i = `i' + 1
		}
}

label variable disabled "Disabled"

gen earnings = .
replace earnings = cond(type1 == 1, 38 - sum_offer, cond(type1 == 0, 39 - sum_offer, .))

save Master_Data_DG_AE_cond, replace

***********************************************
********* MAIN ANALYSIS BEGINS HERE ***********
***********************************************

********* TABLE 1 ON PAGE 16 **********
* Below is right side of the table, the two big cells for no info 

sort period 
by period: summarize choicenoinfo10 nochoicenoinfo10 if choicenoinfo10 != . | nochoicenoinfo10 !=.

* Next, the two CHOICE cells with $9 (bottom left), ignore drugabuse = .

sort period drugabuse
by period drugabuse: summarize choiceinfo9 if choiceinfo9 != .

* Upper left 2x2 matrix for EXOG-INFO condition, ignore drugabuse = .

sort period drugabuse
by period drugabuse: summarize nochoiceinfo9 nochoiceinfo10 if nochoiceinfo9 != . | nochoiceinfo10 !=.

********** TABLE 9 ON PAGE 26 ***********

keep if type1 == 1

sort period 
by period: summarize choicenoinfo10 nochoicenoinfo10 if choicenoinfo10 != . | nochoicenoinfo10 !=.

* Next, the two CHOICE cells with $9 (bottom left), ignore drugabuse = .

sort period drugabuse
by period drugabuse: summarize choiceinfo9 if choiceinfo9 != .

* Upper left 2x2 matrix for EXOG-INFO condition, ignore drugabuse = .

sort period drugabuse
by period drugabuse: summarize nochoiceinfo9 nochoiceinfo10 if nochoiceinfo9 != . | nochoiceinfo10 !=.

*********** TABLE 8 ON PAGE 25 ************
use Master_Data_DG_AE_cond, clear
keep if type1 == 0

sort period 
by period: summarize choicenoinfo10 nochoicenoinfo10 if type1 == 0

* Next, the two CHOICE cells with $9 (bottom left), ignore drugabuse = .

sort period drugabuse
by period drugabuse: summarize choiceinfo9 if choiceinfo9 != . 

* Upper left 2x2 matrix for EXOG-INFO condition, ignore drugabuse = .

sort period drugabuse
by period drugabuse: summarize nochoiceinfo9 nochoiceinfo10 if nochoiceinfo9 != . | nochoiceinfo10 !=.


******** TABLE X ON PAGE 13 ******** 
use Master_Data_DG_AE_cond, clear

gen choicevnoinfo = .
replace choicevnoinfo = cond(choiceinfo9 != . | choicenoinfo10 != ., 1, cond(nochoicenoinfo10 != ., 0, .)) 

gen choicedisvnoinfo = .
replace choicedisvnoinfo = cond((choiceinfo9 != . | choicenoinfo10 != .) & disabled==1, 1, cond(nochoicenoinfo10 != ., 0, .)) 

gen choicedrugvnoinfo = .
replace choicedrugvnoinfo = cond((choiceinfo9 != . | choicenoinfo10 != .) & disabled==0, 1, cond(nochoicenoinfo10 != ., 0, .)) 


** Pooled Periods **
* All Types

sum offer if choicedisvnoinfo == 1 
sum offer if choicedrugvnoinfo == 1 
sum offer if choicedrugvnoinfo == 0

ranksum offer, by(choicedisvnoinfo) 
ranksum offer, by(choicedrugvnoinfo) 

sum offer if choicevnoinfo == 1 
sum offer if choicevnoinfo == 0

ranksum offer, by(choicevnoinfo)

* Type 1

sum offer if choicedisvnoinfo == 1 & type1 == 1
sum offer if choicedrugvnoinfo == 1 & type1 == 1
sum offer if choicedrugvnoinfo == 0 & type1 == 1

ranksum offer if type1 == 1, by(choicedisvnoinfo) 
ranksum offer if type1 == 1, by(choicedrugvnoinfo) 

sum offer if choicevnoinfo == 1 & type1 == 1
sum offer if choicevnoinfo == 0 & type1 == 1

ranksum offer if type1 == 1, by(choicevnoinfo)

* Type 2

sum offer if choicedisvnoinfo == 1 & type1 == 0
sum offer if choicedrugvnoinfo == 1 & type1 == 0
sum offer if choicedrugvnoinfo == 0 & type1 == 0

ranksum offer if type1 == 0, by(choicedisvnoinfo) 
ranksum offer if type1 == 0, by(choicedrugvnoinfo) 

sum offer if choicevnoinfo == 1 & type1 == 0
sum offer if choicevnoinfo == 0 & type1 == 0

ranksum offer if type1 == 0, by(choicevnoinfo)

****** PAGE 15 TABLE WITH 3 PANELS *******

gen earned = .
replace earned = cond(nochoiceinfo10 != . | choicenoinfo != . | nochoicenoinfo10 != ., 10 - offer, cond(choiceinfo9 != . | nochoiceinfo9 != ., 9 - offer, . ))

gen exog9vchoice = .
replace exog9vchoice = cond(Tchoice == 1, 1, cond(nochoiceinfo9 !=., 0, .))

gen exog10vchoice = .
replace exog10vchoice = cond(Tchoice == 1, 1, cond(nochoiceinfo10 !=., 0, .))


* Panel A - Choice v No Info 

sum earned if choicevnoinfo == 1 & type1 == 1
sum earned if choicevnoinfo == 0 & type1 == 1

ranksum earned if type1 == 1, by(choicevnoinfo)

sum earned if choicevnoinfo == 1 & type1 == 0
sum earned if choicevnoinfo == 0 & type1 == 0

ranksum earned if type1 == 0, by(choicevnoinfo)

sum offer if choicevnoinfo == 1 & disabled == 0
sum offer if choicevnoinfo == 0 & disabled == 0

ranksum offer if disabled == 0, by(choicevnoinfo)

sum offer if choicevnoinfo == 1 & disabled == 1
sum offer if choicevnoinfo == 0 & disabled == 1

ranksum offer if disabled == 1, by(choicevnoinfo)


* Panel B - Choice vs Info 10

sum earned if exog10vchoice == 1 & type1 == 1
sum earned if exog10vchoice == 0 & type1 == 1

ranksum earned if type1 == 1, by(exog10vchoice)

sum earned if exog10vchoice == 1 & type1 == 0
sum earned if exog10vchoice == 0 & type1 == 0

ranksum earned if type1 == 0, by(exog10vchoice)

sum offer if exog10vchoice == 1 & disabled == 1
sum offer if exog10vchoice == 0 & disabled == 1

ranksum offer if disabled == 1, by(exog10vchoice)

sum offer if exog10vchoice == 1 & disabled == 0
sum offer if exog10vchoice == 0 & disabled == 0

ranksum offer if disabled == 0, by(exog10vchoice)

* Panel C - Choice vs Info 9

sum earned if exog9vchoice == 1 & type1 == 1
sum earned if exog9vchoice == 0 & type1 == 1

ranksum earned if type1 == 1, by(exog9vchoice)

sum earned if exog9vchoice == 1 & type1 == 0
sum earned if exog9vchoice == 0 & type1 == 0

ranksum earned if type1 == 0, by(exog9vchoice)

sum offer if exog9vchoice == 1 & disabled == 1
sum offer if exog9vchoice == 0 & disabled == 1

ranksum offer if disabled == 1, by(exog9vchoice)

sum offer if exog9vchoice == 1 & disabled == 0
sum offer if exog9vchoice == 0 & disabled == 0

ranksum offer if disabled == 0, by(exog9vchoice)

******** TABLE 2 ON PAGE 17 **********

* Period 1 

sum offer if choicevnoinfo == 1 & period == 1
sum offer if choicevnoinfo == 0 & period == 1 

ranksum offer if period == 1, by(choicevnoinfo) 
eststo clear 
eststo: reg offer Tchoice male age yredu race if period == 1 & (nochoicenoinfo != . | Tchoice == 1)
eststo: tobit offer Tchoice male age yredu race if period == 1 & (nochoicenoinfo != . | Tchoice == 1), ll(0) ul(10)
esttab using choicevsexognoinfop1.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("OLS" "Tobit") title("Period 1 subset of Nochoicenoinfo and Choice")

* Period 2

sum offer if choicevnoinfo == 1 & period == 2
sum offer if choicevnoinfo == 0 & period == 2

ranksum offer if period == 2, by(choicevnoinfo) 
eststo clear 
eststo: reg offer Tchoice if period == 2 & (nochoicenoinfo != . | Tchoice == 1)
eststo: tobit offer Tchoice if period == 2 & (nochoicenoinfo != . | Tchoice == 1), ll(0) ul(10)
esttab using choicevsexognoinfop2.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("OLS" "Tobit") title("Period 2 subset of Nochoicenoinfo and Choice")

* Period 3
sum offer if choicevnoinfo == 1 & period == 3
sum offer if choicevnoinfo == 0 & period == 3

ranksum offer if period == 3, by(choicevnoinfo) 
eststo clear 
eststo: reg offer Tchoice if period == 3 & (nochoicenoinfo != . | Tchoice == 1)
eststo: tobit offer Tchoice if period == 3 & (nochoicenoinfo != . | Tchoice == 1), ll(0) ul(10)
esttab using choicevsexognoinfop3.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("OLS" "Tobit") title("Period 3 subset of Nochoicenoinfo and Choice")


* Period 4
sum offer if choicevnoinfo == 1 & period == 4
sum offer if choicevnoinfo == 0 & period == 4

ranksum offer if period == 4, by(choicevnoinfo) 
eststo clear 
eststo: reg offer Tchoice if period == 4 & (nochoicenoinfo != . | Tchoice == 1)
eststo: tobit offer Tchoice if period == 4 & (nochoicenoinfo != . | Tchoice == 1), ll(0) ul(10)
esttab using choicevsexognoinfop4.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("OLS" "Tobit") title("Period 4 subset of Nochoicenoinfo and Choice")


******** TABLE 3 ON PAGE 17 ***********

eststo clear
eststo: reg offer periodnew if Tchoice == 1
eststo: tobit offer periodnew if Tchoice == 1, ll(0) ul(10)
eststo: reg offer periodnew if nochoicenoinfo10 != . 
eststo: tobit offer periodnew if nochoicenoinfo10 != ., ll(0) ul(10)
esttab using periodeff.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.  Tobits use lower limits of 0 and upper limits of 10.") se /*
*/ mtitles ("OLS of Choice subset" "Tobit of Choice subset" "OLS of No Choice No Info subset" "Tobit of No Choice No Info subset") title("OLS and Tobit regressions with Offer as DV on subsets as indicated by column titles.")

******* TABLE 4 ON PAGE 18 ************ 

gen drug_period = periodnew*drugabuse

eststo clear 
eststo: reg offer periodnew drugabuse drug_period if choiceinfo9 != . & Tchoice == 1
eststo: tobit offer periodnew drugabuse drug_period if choiceinfo9 != . & Tchoice == 1, ll(0) ul(10)
eststo: reg offer periodnew if choicenoinfo10 != . & Tchoice == 1
eststo: tobit offer periodnew if choicenoinfo10 != . & Tchoice == 1, ll(0) ul(10)
esttab using typesper.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.  Tobits use lower limits of 0 and upper limits of 10.") se /*
*/ mtitles ("OLS of offer for Type 1" "Tobit of offer for Type 1" "OLS of offer for Type 2" "Tobit of offer for Type 2") title("Choice condition only.  Comparing how giving is different between those who bought info and those who did not.")

******* TABLE 5 ON PAGE 19 ***********

* Panel A
eststo clear
eststo: reg offer periodnew if (choiceinfo9 != . & disabled == 0)
eststo: reg offer periodnew if (choiceinfo9 != . & disabled == 1)
eststo: reg offer periodnew if (choicenoinfo10 != .)
eststo: reg offer periodnew if (choiceinfo9 != . & disabled == 1) | choicenoinfo10 != .
esttab using table5a.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("Bought info paired w/ drug user" "Bought info paired w/ disabled" "Did not buy info" "Columns 2 and 3 combined.") ///
title("Time trends of subsets of the Choice condition using OLS.  The DV is offer and subsets are given in column titles.")

* Panel B
eststo clear
eststo: tobit offer periodnew if (choiceinfo9 != . & disabled == 0), ll(0) ul(10)
eststo: tobit offer periodnew if (choiceinfo9 != . & disabled == 1), ll(0) ul(10)
eststo: tobit offer periodnew if (choicenoinfo10 != .), ll(0) ul(10)
eststo: tobit offer periodnew if (choiceinfo9 != . & disabled == 1) | choicenoinfo10 != ., ll(0) ul(10)
esttab using table5b.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01. Lower limits are 0 and upper limits are 10.") se /*
*/ mtitles ("Bought info paired w/ drug user" "Bought info paired w/ disabled" "Did not buy info" "Columns 2 and 3 combined.") ///
title("Time trends of subsets of the Choice condition using Tobit.  The DV is offer and subsets are given in column titles.")

******** TABLE 6 ON PAGE 20 *************

gen treatment = .
replace treatment = cond(choicenoinfo10 != ., 0, cond(choiceinfo9 != ., 1, cond(nochoiceinfo10 != ., 2, cond(nochoiceinfo9 != ., 3, cond(nochoicenoinfo10 != ., 4, .)))))

gen received = .
replace received = cond(treatment == 0 | treatment == 1, 10, cond(treatment == 2, 10, cond(treatment == 3, 9, cond(treatment == 4, 10,.))))

sort id

gen wealth = .
replace wealth = .
local N = _N
forvalues i = 1/`N' {
	if(id[`i'] != id[`i'-1]){
		replace wealth = received in `i'
	}
	if(id[`i'] == id[`i'-1]){
		replace wealth = wealth[`i'-1] + received[`i'] in `i'
	}
	local i = `i' + 1	
}

save Master_Data_DG_AE_cond, replace

eststo clear 
xtset id
eststo: xtreg offer wealth, fe 
xtset, clear 
eststo: reg offer wealth if treatment == 1 | treatment == 0
eststo: reg offer wealth if treatment == 2
eststo: reg offer wealth if treatment == 3 
eststo: reg offer wealth if treatment == 4 
esttab using wealth.rtf, varwidth(10) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("FE" "Choice" "Info10" "Info9" "NoInfo") ///
title("Table 6. Wealth Effects.  Column 1 uses wealth fixed effects on the whole sample.  Columns 2-5 use OLS regressions to test whether wealth predicts offers in each of the 4 conditions.")

********* TABLE 7 ON PAGE 21 ************

gen afterfreeinfo = .
replace afterfreeinfo = cond(t4period == 4 | t2period == 4 & (t1period == 1 | t1period == 2) | t3period == 4, 1, 0)

* Panel A

eststo clear
eststo: reg offer p2 p3 p4 if treatment == 1 & disabled == 1 
eststo: reg offer afterfreeinfo if treatment == 1 & disabled == 1 
eststo: reg offer p2 p3 p4 afterfreeinfo if treatment == 1 & disabled == 1 
esttab using diss.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ title ("Panel A. Subset of Choice with Info and Paired with Disabled") mtitles ("Offer" "Offer" "Offer")

* Panel B

eststo clear
eststo: reg offer p2 p3 p4 if treatment == 0
eststo: reg offer afterfreeinfo if treatment == 0
eststo: reg offer p2 p3 p4 afterfreeinfo if treatment == 0
esttab using noinfo.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ title ("Panel B. Subset of Choice without Information") mtitles ("Offer" "Offer" "Offer")

* Panel C

eststo clear
eststo: reg offer p2 p3 p4 if treatment == 0 | treatment == 1
eststo: reg offer afterfreeinfo if treatment == 0 | treatment == 1
eststo: reg offer p2 p3 p4 afterfreeinfo if treatment == 0 | treatment == 1
esttab using choice.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ title ("Panel C. Subset of Choice Condition Pooled - i.e. every subgroup of Choice condition") mtitles ("Offer" "Offer" "Offer")

********* TABLE 8 ON PAGE 22 *************

gen Choice_Dis = disabled*Tchoice

gen choice_exog = .
replace choice_exog = cond(t1period == 4 | (t2period == 4 & t1period == 1), 1, 0)

gen exog_choice = .
replace exog_choice = cond(t1period == 2 | t1period == 3 | (t2period == 2 & t1period != 4) | (t2period == 3 & t1period != 4) | t4period == 4, 1, 0)

eststo clear
eststo: reg offer Tchoice if choice_exog == 1 & type1 == 1 & (Tchoice == 1 | nochoiceinfo9 !=. | nochoiceinfo10 != .)
eststo: reg offer Tchoice disabled Choice_Dis if choice_exog == 1 & type1 == 1 & (Tchoice == 1 | nochoiceinfo9 !=. | nochoiceinfo10 != .)
eststo: reg offer Tchoice if exog_choice == 1 & type1 == 1 & (Tchoice == 1 | nochoiceinfo9 !=. | nochoiceinfo10 != .)
eststo: reg offer Tchoice disabled Choice_Dis if exog_choice == 1 & type1 == 1 & (Tchoice == 1 | nochoiceinfo9 !=. | nochoiceinfo10 != .)
esttab using useinfo.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("Endogenous Before Exogenous Info for Type 1" "Endogenous Before Exogenous Info for Type 1" "Exogenous info Before Endogenous for Type 1" "Exogenous info Before Endogenous for Type 1") ///
title ("Table 8. Subset of Type 1 participants and testing their giving depending on when they saw the information.  From the interaction we see that participants did not feel the need to use information bought in any period.") 

********* TABLE 9 ON PAGE 23 **************
* Below replicates table in paper, however, I think this is not what we wanted, I think we wanted period 1 only?  
* This subsets participants who had nochoicenoinfo10 in period 4, not choice in period 1.  I think I made a coding error.

eststo clear
eststo: reg offer Tchoice if t1period == 4 & type1 == 1 & (Tchoice == 1 | nochoiceinfo9 !=. | nochoiceinfo10 != .)
eststo: reg offer Tchoice disabled Choice_Dis if t1period == 4 & type1 == 1 & (Tchoice == 1 | nochoiceinfo9 !=. | nochoiceinfo10 != .)
esttab using bought.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("Endogenous before Exogenous Info in Period 1 for Type 1" "Endogenous before Exogenous Info in Period 1 for Type 1") ///
title ("Table 9. Analogous to Table 8 only using Period 1.") 

******** TABLE 10 ON PAGE 23 **************

* Panel A 

eststo clear
eststo: reg offer type1
eststo: reg offer type1 p2 p3 p4 
esttab using panelA.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("Offer" "Offer") title("Panel A. OLS regression on whole sample to test for differences in giving conditional on whether they bought or did not buy the information, controlling for period effects in column 2.")

* Panel B 

eststo clear
eststo: reg earnings type1
esttab using earnings.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") /*
*/ mtitles ("DV: Earnings") title("Panel B.  OLS on whole sample showing that participants who bought information earned significantly less")

* Panel C of Type1 characteristics - ie they give discrimnantly to disabled people 

gen dis_type1 = disabled*type1

eststo clear
eststo: reg offer type1 disabled dis_type1 if period == 1
eststo: reg offer type1 disabled dis_type1 if period == 2
eststo: reg offer type1 disabled dis_type1 if period == 3
eststo: reg offer type1 disabled dis_type1 if period == 4
eststo: reg offer type1 disabled dis_type1 
esttab using panelC.rtf, varwidth(10) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("Period 1" "Period 2" "Period 3" "Period 4" "Pooled") title("Panel C. OLS on whole showing that those who buy info only give more to disabled recipient. Their giving is highly conditional on recipient type. ")




