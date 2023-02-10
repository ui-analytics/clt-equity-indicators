cd "C:\Users\mkhatun\Dropbox (UNC Charlotte)\UI-Equity Indicators\Analysis"


di "Load NC ACS PUMS Person file for the year"

import delimited "C:\Users\mkhatun\Dropbox (UNC Charlotte)\UI-Equity Indicators\Data\psam_p37_2019.csv", clear

di "Start the log"

di "Indicator Variable for Charlotte-Mecklenburg using PUMA codes"

gen charmeck = 0

replace charmeck = 1 if puma == 3101 | puma == 3102 | puma == 3103 | puma == 3104 | puma == 3105 | puma == 3106 | puma == 3107 | puma == 3108

label define rac1p 1 "White" 2 "Black" 3 "American Indian" 4 "Alaska Native" 5 "AI or AN Tribes specified" 6 "Asian" 7 "Native Hawaiian" 8 "Other Single Race" 9 "Multi-race"
ds, has(vallabel)

di " Setting Survey Weights"

svyset [pw=pwgtp], sdr(pwgtp1 - pwgtp80) vce(sdr) mse
**#Using single races only. Could use racblk or racasn later to encompass all blacks and asians later on
foreach k in 1 2 6 9 {

di "Labor Force Non-Participation for Black and White Population - use #6 in the categories for proportion"

di "`k' : `: label rac1p `k''"
svy sdr, subpop(if rac1p ==`k' & charmeck == 1 & agep >=25 & agep <64 & esr !=4 & esr !=5) mse : tabulate esr, cell se ci deff
clear
}


foreach k in 1 2 6 9 {

di "Median Personal Total Income for Asian, Black, White and Mixed Race population (rac1p = 1 (white), 2(black) 6(asian), 9 (multiple races))"

di "Adjusting Income for 2019 dollars"

gen adj_pincp = pincp * adjinc/1000000

di "generating income percentiles"

di "`k' : `: label rac1p `k''"

epctile adj_pincp, p(25 50 75) svy subpop(if rac1p ==`k' & charmeck == 1 & agep >=25 & agep <64 & esr ==1 & wkhp >=30 )
clear

}

foreach k in 1 2 6 9 {

di "Business Ownership - Percentage of self-employed adults (25-64) in black and white populations"

di "`k' : `: label rac1p `k''"

svy sdr, subpop(if rac1p ==`k' & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate cow, cell se ci deff

svy sdr, subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate cow, cell se ci deff
clear

}

foreach k in 1 2 6 9 {

di "Generate indicator for self employment"

gen selfempl = 0
replace selfempl = 1 if cow==6 | cow==7

di "Use self employed indicator to recalculate - use this for the result"

di "`k' : `: label rac1p `k''"

svy sdr, subpop(if rac1p ==`k' & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate selfempl, cell se ci deff
clear

}

foreach k in 1 2 6 9 {

di "Health Insurance Non-Coverage"

di "`k' : `: label rac1p `k''"
svy sdr, subpop(if rac1p ==`k' & charmeck == 1  ) mse : tabulate hicov, cell se ci deff
clear

}

foreach k in 1 2 6 9 {

di "Educational Attainment - Bachelor's Degree or Higher"

di "Generate bachelors degree indicator"

gen bachelor = 0
replace bachelor = 1 if schl>=21

di "`k' : `: label rac1p `k''"

svy sdr, subpop(if rac1p ==`k' & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate bachelor, cell se ci deff
clear

}
foreach k in 1 2 6 9 {

di "Commute Time - Mean Commute Time"

di "`k' : `: label rac1p `k''"

svy sdr, subpop(if rac1p ==`k' & charmeck == 1 & agep >=25 & agep <64 ) mse : mean jwmnp
clear

}
