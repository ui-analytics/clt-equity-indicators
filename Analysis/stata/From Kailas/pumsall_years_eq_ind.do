
	
cd "C:\Users\kvenkita\Dropbox (UNC Charlotte)\PUMS NC"

foreach k in 6 7 8 9 {


di "Load NC ACS PUMS Person file for the year"

import delimited "C:\Users\kvenkita\Dropbox (UNC Charlotte)\PUMS NC\psam_p37_201`k'.csv", clear


di "Start the log"

log using psam_p37_201`k'

di " Setting Survey Weights"

svyset [pw=pwgtp], sdr(pwgtp1 - pwgtp80) vce(sdr) mse

local meck "puma == 3101 | puma == 3102 | puma == 3103 | puma == 3104 | puma == 3105 | puma == 3106 | puma == 3107 | puma == 3108"

di "Indicator Variable for Charlotte-Mecklenburg using PUMA codes"

gen charmeck = 0

replace charmeck = 1 if `meck'


di "Labor Force Non-Participation for Black and White Population - use #6 in the categories for proportion"

di "White"

svy sdr, subpop(if rac1p ==1 & charmeck == 1 & agep >=25 & agep <64 & esr !=4 & esr !=5) mse : tabulate esr, cell se ci deff

di "Black "

svy sdr, subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 & esr !=4 & esr !=5) mse : tabulate esr, cell se ci deff


di "Median Personal Total Income for Asian, Black and White population (rac1p = 1 (white), 2(black) 6(asian))"

di "Adjusting Income for 201`k' dollars"

gen adj_pincp = pincp * adjinc/1000000

di "generating income percentiles"

di "Black "
epctile adj_pincp, p(25 50 75) svy subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 & esr ==1 & wkhp >=30 )
di "White"
epctile adj_pincp, p(25 50 75) svy subpop(if rac1p ==1 & charmeck == 1 & agep >=25 & agep <64 & esr ==1 & wkhp >=30 )
di "Asian"
epctile adj_pincp, p(25 50 75) svy subpop(if rac1p ==6 & charmeck == 1 & agep >=25 & agep <64 & esr ==1 & wkhp >=30 )

di "Business Ownership - Percentage of self-employed adults (25-64) in black and white populations"

di "White"
svy sdr, subpop(if rac1p ==1 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate cow, cell se ci deff
di "Black "
svy sdr, subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate cow, cell se ci deff

di "Generate indicator for self employment"

gen selfempl =0
replace selfempl = 1 if cow==6 | cow==7

di "Use self employed indicator to recalculate - use this for the result"

di "White"
svy sdr, subpop(if rac1p ==1 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate selfempl, cell se ci deff
di "Black"
svy sdr, subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate selfempl, cell se ci deff

di "Health Insurance Non-Coverage"

di "White"
svy sdr, subpop(if rac1p ==1 & charmeck == 1  ) mse : tabulate hicov, cell se ci deff
di "Black"
svy sdr, subpop(if rac1p ==2 & charmeck == 1  ) mse : tabulate hicov, cell se ci deff

di "Educational Attainment - Bachelor's Degree or Higher"

di "Generate bachelors degree indicator"

gen bachelor = 0
replace bachelor = 1 if schl>=21

di "Black"
svy sdr, subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate bachelor, cell se ci deff
di "White"
svy sdr, subpop(if rac1p ==1 & charmeck == 1 & agep >=25 & agep <64 ) mse : tabulate bachelor, cell se ci deff

di "Commute Time - Mean Commute Time"

di "White"
svy sdr, subpop(if rac1p ==1 & charmeck == 1 & agep >=25 & agep <64 ) mse : mean jwmnp
di "Black"
svy sdr, subpop(if rac1p ==2 & charmeck == 1 & agep >=25 & agep <64 ) mse : mean jwmnp


di "Print Logs"

translate psam_p37_201`k'.smcl psam_p37_201`k'.pdf
translate psam_p37_201`k'.smcl psam_p37_201`k'.txt

di "Close the Log"

log close

clear

}