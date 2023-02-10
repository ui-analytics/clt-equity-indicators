




	
	
	local datadir "C:/Users/E-ITX/Dropbox (UNC Charlotte)/Work/Projects/UI-Equity Indicators Mini Project/Data/Raw"
	
	local maindir "C:/Users/E-ITX/Dropbox (UNC Charlotte)/Work/Projects/UI-Equity Indicators Mini Project"
	
	cd `maindir'

	foreach k in 6 7 8 {
		
			di "Load NC ACS PUMS Person file for the year"

			cd `datadir'
	
			copy https://www2.census.gov/programs-surveys/acs/data/pums/201`k'/1-Year/csv_hnc.zip hnc`k'.zip
			
			unzipfile hnc`k'.zip, replace
			
			copy https://www2.census.gov/programs-surveys/acs/data/pums/201`k'/1-Year/csv_pnc.zip pnc`k'.zip
			
			unzipfile pnc`k'.zip, replace
	
			cd `maindir'
			
			di "Start the log"

			log using psam_h37_201`k', replace
			
			import delimited "Data/Raw/psam_p37.csv", clear
			
			save psam_p37_201`k'.dta, replace
			
			import delimited "Data/Raw/psam_h37.csv", clear

			save psam_h37_201`k'.dta, replace
			
			

			merge 1:m serialno using "Data/PUMS NC/psam_p37_201`k'.dta"

			keep if relp == 0 | relp == 16 | relp == 17 | _merge == 1
			
			di "integrate poverty guidelines data for each household based on household size"
			
			merge m:1 np using  "Data/PUMS NC/pove_guide_201`k'.dta", gen(_merge_pov)

			di " Setting Survey Weights"

			svyset [pw=wgtp], sdr(wgtp1 - wgtp80) vce(sdr) mse

			local meck "puma == 3101 | puma == 3102 | puma == 3103 | puma == 3104 | puma == 3105 | puma == 3106 | puma == 3107 | puma == 3108"

			di "Indicator Variable for Charlotte-Mecklenburg using PUMA codes"

			gen charmeck = 0
			replace charmeck = 1 if `meck'
			
			di "Median Household Income By Race"

			di "calculate adjusted household income"

			gen adj_hincp = hincp * adjinc/1000000

			di "Black"

			epctile adj_hincp, p(25 50 75) svy subpop(if rac1p ==2 & charmeck == 1 )

			di "White"
			epctile adj_hincp, p(25 50 75) svy subpop(if rac1p ==1 & charmeck == 1 )

			di "Asian"

			epctile adj_hincp, p(25 50 75) svy subpop(if rac1p ==6 & charmeck == 1 )

			di "Houesholds below Poverty Line - Poverty Guide dataset (pov_inc) used as reference to generating poverty_indicator"

			di "Black"

			di "Adjusted Family Income to 2019 dollars - (not used - hh income used instead)"

			gen adj_fincp = fincp * adjinc/1000000

			di "Generate indicator variable for household in poverty"
			
			gen pov_fam = 0
			replace pov_fam = 1 if adj_hincp <= pov_inc

			di "Percentage families in  by race"

			di "Black"
			svy sdr, subpop(if rac1p ==2 & charmeck == 1 ) mse : tabulate pov_fam, cell se ci deff

			di "White"
			svy sdr, subpop(if rac1p ==1 & charmeck == 1 ) mse : tabulate pov_fam, cell se ci deff

			di "Asian"
			svy sdr, subpop(if rac1p ==6 & charmeck == 1 ) mse : tabulate pov_fam, cell se ci deff


			di "Percentage families with children (<17 years) below poverty "
			 
			di "Black"
			svy sdr, subpop(if rac1p ==2 & charmeck == 1 & hupac < 4 ) mse : tabulate pov_fam, cell se ci deff

			di "White"
			svy sdr, subpop(if rac1p ==1 & charmeck == 1 & hupac < 4 ) mse : tabulate pov_fam, cell se ci deff


			di "Child Food Insecurity (PUMS) - percentages of Black and White households with children under 18 that received SNAP benefits in the past 12 months"

			di"Black"
			svy sdr, subpop(if rac1p ==2 & charmeck == 1 & hupac < 4 ) mse : tabulate fs, cell se ci deff

			di "White"
			svy sdr, subpop(if rac1p ==1 & charmeck == 1 & hupac < 4 ) mse : tabulate fs, cell se ci deff


			di "Home Ownership"

			di " Generate Home owner indicator"

			gen homeown = 0
			replace homeown = 1 if ten < 3

			di "Percentage of households that are owned by race"

			di "Black"

			svy sdr, subpop(if rac1p ==2 & charmeck == 1 ) mse : tabulate homeown, cell se ci deff

			di "White"
			svy sdr, subpop(if rac1p ==1 & charmeck == 1 ) mse : tabulate homeown, cell se ci deff


			di " Rent Burden"

			di " Generate Indicator for rent burdened households"

			gen rent_burden = 0
			replace rent_burden = 1 if grpip >= 30

			di " Percentage of households in race that are rent burdened - spent 30% or more of their hh income on rent"

			di "Black"
			svy sdr, subpop(if rac1p ==2 & charmeck == 1 & ten==3) mse : tabulate rent_burden, cell se ci deff

			di "White"
			svy sdr, subpop(if rac1p ==1 & charmeck == 1 & ten==3) mse : tabulate rent_burden, cell se ci deff

			di "Print Logs"

			translate psam_h37_201`k'.smcl psam_h37_201`k'.pdf, replace
			translate psam_h37_201`k'.smcl psam_h37_201`k'.txt, replace

			di "Close the Log"

			log close

			clear

		}


