cap prog drop vcimatrix
prog def vcimatrix, eclass
	syntax [anything], id1(varname) id2(varname) [weightss(varname) absorbs(varlist) parallel]
	gettoken subcmd 0 : 0
	gettoken formula 0 : 0, parse(",")
	* Obtaining V_C
	qui foreach ids in $unique {
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
			qui: `formula' [aw=`weights'], r absorb(`absorbs')
		}
		* Updating the V_C matrix
		cap matrix V_C=V_C+e(V)
		if _rc != 0 {
			matrix V_C=e(V)
		}
		drop `i_cl'
	}
	macro drop unique
end
