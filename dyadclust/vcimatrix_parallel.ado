cap prog drop vcimatrix_parallel
prog def vcimatrix_parallel, eclass
	syntax [anything], id1(string) id2(string) [weightss(string) absorbs(string) parallel]
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
		forvalues cch=1/$PLL_CHILDREN {
			cap mat drop V_C_`cch'
			* Executing parallel instance
			if ($pll_instance == `cch') { 
				qui foreach ids of global uniqued_`cch' {
					tempvar i_cl
					gen `i_cl'=-99 if `id1'=="`ids'"
					replace `i_cl'=-99 if `id2'=="`ids'"
					replace `i_cl'=_n if `i_cl'==.
					tostring `i_cl', replace
					if "`absorbs'"=="" {
						qui: `formula' [aw=`weightss'], cluster(`i_cl')
					}
					else {
						tokenize `formula'
						local formula= subinstr("`formula'","`1'","reghdfe",1)
						qui: `formula' [aw=`weights'], r absorb(`absorb')
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
