cap prog drop dyadclust
prog def dyadclust, eclass
	syntax [anything], EGOid(varname) ALTERid(varname) [weights(varname) absorb(varlist) PARallel]
	* Obtain regresison equation
	gettoken subcmd 0 : 0
	gettoken equation 0 : 0, parse(",")
	* Define temporary variables
	qui: tempvar _id1
	qui: tempvar _id2
	qui: tempvar _id3
	if "`weights'"=="" {
		tempvar weights
		gen `weights'=1 
	}
	* Temporary matrices and scalars
	tempname V_D V_0 V_dyad
	
	* Generating strings out of id variables for ease
	cap qui tostring `egoid', generate(`_id1')
	cap qui tostring `alterid', generate(`_id2') 
	cap qui gen `_id1'=`egoid'
	cap qui gen `_id2'=`alterid'
	
	* Generating id for dyads
	egen `_id3'=group(`_id1' `_id2')
	cap qui tostring `_id3', force replace
	* Unique values for ego and alter combined
	qui {
		tempfile fdata
		save `fdata'
		mata: dyad = st_sdata(.,("`_id1'","`_id2'"))
		mata: uid= uniqrows(uniqrows(dyad[.,1])\uniqrows(dyad[.,2])) 
		clear
		getmata uid
		mata: mata clear
		qui levelsof uid, l(unique)
		global unique=""
		foreach ids of local unique {
			global unique="$unique `ids'"
		}
		if "`parallel'"!="" {
			save uids, replace
		}
		u `fdata', clear	
	}
	qui local ndd=0
	qui foreach ids of local unique {
		local ++ndd
	}

	* Obtaining the V_Ci 
	if "`parallel'"=="" {
		vcimatrix: `equation', id1(`_id1') id2(`_id2') weightss(`weights')
	}
	else {
		cap vcimatrix_parallel
		save bridge, replace
		cap parallel numprocessors
		if _rc!=0 {
			di "{error: PARALLEL is not installed. Install it from here: }"
			di `"{browse "https://github.com/gvegayon/parallel": Parallel package.}"' 
			exit 198
		}
		parallel initialize `=`r(numprocessors)'-1', f	
		parallel, nodata prog(vcimatrix_parallel): vcimatrix_parallel: `equation', id1("`_id1'") id2("`_id2'") weightss("`weights'") parallel
		qui {
			clear
			local files : dir "`c(pwd)'" files "*V_C.dta"
			local nf=0
			foreach file of local files {
				local ++nf
				u `file', clear
				mkmat *, matrix(V_C_`nf')
				local msize=_N
				erase `file'
			}
			matrix V_C = J(`msize',`msize',0)
			forvalues mid=1/`nf' {
				matrix V_C = V_C+V_C_`mid'
				matrix drop V_C_`mid'
			}
		}
		u bridge, clear
		erase bridge.dta
		erase uids.dta
	}
	* Obtaining V_D
	if "`absorb'"=="" {
		qui: `equation' [aw=`weights'], cluster(`_id3')
	}
	else {
		tokenize `equation'
		local equation= subinstr("`equation'","`1'","reghdfe",1)
		qui: `equation' [aw=`weights'], cluster(`_id3') absorb(`absorb')
	}
	
	matrix `V_D' = e(V)
	
	* Obtaining V_0
	if "`absorb'"=="" {
		qui: `equation' [aw=`weights'], r
	}
	else {
		tokenize `equation'
		local equation= subinstr("`equation'","`1'","reghdfe",1)
		qui: `equation' [aw=`weights'], vce(robust) absorb(`absorb')
	}
	matrix `V_0' = e(V)
	
	* Reposting the variance-covariance matrix
	matrix `V_dyad' = V_C - `V_D' - (`ndd'-2)*`V_0'
	matrix drop V_C
	ereturn repost V = `V_dyad'
	ereturn scalar df_r = .
	if "`absorb'"=="" {
		regress
	}
	else{
		reghdfe
	}
end
