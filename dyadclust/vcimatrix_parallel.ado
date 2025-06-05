cap prog drop vcimatrix_parallel
prog def vcimatrix_parallel, eclass
	syntax [anything], lats(string) lons(string) [weightss(string) absorbs(string) groups(string) parallel]
	gettoken subcmd 0 : 0
	gettoken formula 0 : 0, parse(",")
	qui {
		* To split the loop
		u uids, clear
		local nunique: word count $unique
		local sunique= ceil(`nunique'/$PLL_CHILDREN)
		gen lle=_n
		forvalues cch=1/$PLL_CHILDREN {
			replace lle=`cch' if lle>=`=`cch'-1'*`sunique' & lle<=`cch'*`sunique'
			levelsof uid if lle==`cch', l(unique)
			local uniqued_`cch'=""
			foreach ids of local unique {
				local uniqued_`cch'="`uniqued_`cch'' `ids'"
				global uniqued_`cch'="`uniqued_`cch''"
			}
		}
		macro drop unique
		* Loading the dataset
		u bridge, clear
		qui: tempvar _lat_scale
		qui: tempvar _lon_scale
		gen `_lat_scale'=cos(`lats'*3.1416/180)*111
		gen `_lon_scale'=111
		forvalues cch=1/$PLL_CHILDREN {
			cap mat drop V_C_`cch'
			* Executing parallel instance
			if ($pll_instance == `cch') { 
				levelsof `groups', l(_times)
				foreach _t of local _times {
				qui foreach ids of global uniqued_`cch' {
					tempvar i_cl
					
					scalar _lon_scale = cos(lat1[i,1]*pi()/180)*111 if 
					lat_scale = 111
							
					window_i = distance_i :<= dist_cutoff

					//----------------------------------------------------------------
					// adjustment for the weights if a "bartlett" kernal is selected as an option
			
					if ("`bartlett'"=="bartlett"){
					
						// this weights observations as a linear function of distance
						// that is zero at the cutoff distance
						
						weight_i = 1:- distance_i:/dist_cutoff

						window_i = window_i:*weight_i
					}


					gen `i_cl'=-99 if `lats'=="`ids'"
					replace `i_cl'=-99 if `lons'=="`ids'"
					replace `i_cl'=_n if `i_cl'==.
					tostring `i_cl', replace

					if "`absorbs'"=="" {
						qui: `formula' [aw=`weightss'], cluster(`i_cl')
					}
					else {
						tokenize `formula'
						local formula= subinstr("`formula'","`1'","reghdfe",1)
						qui: `formula' [aw=`weights'], r absorb(`absorbs')
					}
					* Updating the V_C matrix
					cap matrix V_C_`cch'=V_C_`cch'+e(V)
					if _rc != 0 {
						matrix V_C_`cch'=e(V)
					}
					drop `i_cl'
				}
				clear
				svmat double V_C_`cch'
				save `cch'_V_C, replace
				macro drop uniqued_`cch'
			}
		}
	}
end
