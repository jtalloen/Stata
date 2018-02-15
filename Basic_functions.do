* This is setting the path/directory of stata and the loading the data set using the insheet function
* Notice the ${mypath} and .csv and also the "\" and not "/"

global mypath "C:\Users\Joachim\Box Sync\Joe\Research\CMU\Christina Fong\DG_AE\"
insheet using "${mypath}Master_Data_DG_AE_exit1.csv", clear

* Creating variables
* You usually do gen to generate the variable and then replace it with what you want.
* This is because you might get something wrong in defining the variable in gen but once it's generated you can't run that function again
* So you might as well just use replace

gen choiceinfo9 = .
replace choiceinfo9 = giveinfo9

gen interaction = iv*iv /* creating an interaction between two independent variables; just create new variable which is multiplication of both */

* Another way to create a variable is using cond, and this is my preferred way.
* Cond is basically an if then function taking the form (condition, value if condition true, value if condition not true)
* So below, we are creating a variable which takes value of 1 if the DV is strictly greater than 3 and 0 otherwise

gen t1 = cond(dv > 3, 1, 0)


* Sort variable first to analyze data over periods or something. 
* This will basically output a summary statistics table for each period for those variables
* Also notice how easy it is to use if statements at the end of functions (also applies to reg functions for regressions). 
* Look up online for basic binary meanings but should be self explanatory 

sort period 
by period: summarize choicenoinfo10 nochoicenoinfo10 if choicenoinfo10 != . | nochoicenoinfo10 !=.

* The egen function is very useful but I don't know much myself yet
* Basically here it sums all the columns in one row and creates offer.
* With Christina this just results in basically getting one variable that has all offers, and then you have an IV for condition

egen offer = rowtotal (choicenoinfo10 choiceinfo9 nochoicenoinfo10 nochoiceinfo9 nochoiceinfo10), missing

* Running loops 
* Learning how to write them well took some time
* There are a lot of weird specifics
* Notice that I also introduced the if function.  There are again specifics such as when you cannot start your else if statement
* on the same line as you end the first if.
* I use this set up of loops the most because it loops over all the rows in the data set

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


* Now some simple graphs
* First you will need to create the data points 
* For example, here we are creating means of a DV called "switch" for different runlengths
* Then, we make some simple graphs with labels

bysort runlength: egen switch__m = mean(switch)

twoway (scatter switch_run runlength, sort) (lfit switch_run runlength, sort), by(q33) ////
legend(label(1 "Data") label(2 "Regression Fit")) ////
xtitle("Runlength") ytitle("Probability of Switching") ////
yscale(range(0 1)) ylabel(0(.1)1) 

* Here is your simple OLS regression
* Format: reg DV IV IV IV if...
* Then for interactions you can do # or ##. 
* # will only you get you the actual interaction, ## will also get you main effects
* the by(id) whill just do the within subject analysis and do this for every id

reg offer Tchoice##period /* could add "if period == 1" here to only do the regression for period 1 */
reg offer Tchoice##period, by(id)


* This is to create tables 
* So eststo clear tells stata to clear everything eststo might have saved
* Then you tell it to add these regressions, they are always added chronologically
* Esttab then tell it to make a table with all estto's saved.
* You can see it is saved in tablemain.rtf, .rtf is the standard word output, nothing else (took me a while to catch that)
* Then you can also see that I change the width of the first columns displaying the variable names
* Then I tell stata to change how it assigns stars (it doesn't do this the standard way everyone's used to
* Lastly I add a note specifying how stars assigned, say that standard errors should be reported and I change the titles in table
* The table is saved under tablemain.rtf and was located in my documents folder under my username or something (took me a while to find)
* Additionally # or ## will NOT work in outputting tables, you have to create the interaction variable, i.e. replace int = Tchoice*period1 for example.

eststo clear
eststo:reg offer choicevnoinfo if period==1 & choicevnoinfo != .
eststo:reg offer choicevnoinfo if period==2 & choicevnoinfo != .
eststo:reg offer choicevnoinfo if period==3 & choicevnoinfo != .
eststo:reg offer choicevnoinfo if period==4 & choicevnoinfo != .
esttab using tablemain.rtf, varwidth(20) star(* 0.10 ** 0.05 *** 0.01) nonote addnote("* p < 0.10, ** p < 0.05, *** p < 0.01.") se /*
*/ mtitles ("Period 1" "Period 2" "Period 3" "Period 4")

* Sign rank and rank sums
* I haven't used these much but here are the simple functions

signrank p1 = p234
ranksum offer if period==1&(choicenoinfo10 !=.|nochoicenoinfo10 !=.), by(Tchoice)

* Misc
* These are just simple drop and keep, pretty self explanatory

keep if t0periodnoinfop4 == 1
drop if asdfasdfasdf

* Doing Chi squares in stata
* tab DV IV, chi2

tab t1 cfvcv, chi2



