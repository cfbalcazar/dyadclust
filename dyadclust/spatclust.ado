cap prog drop pointclust
prog def pointclust, eclass
	syntax [anything], LATitude(varname numeric) LONgitude(varname numeric) CUToff(real 1) [weights(varname) absorb(varlist) PARallel BARTlett GROUPvar(varname)]
	* Obtain regresison equation
	gettoken subcmd 0 : 0
	gettoken equation 0 : 0, parse(",")
	* Define temporary variables
	qui: tempvar _lat
	qui: tempvar _lon
	qui: tempvar _point
	if "`weights'"=="" {
		tempvar weights
		gen `weights'=1 
	}
	if "`groupvar'"=="" {
		tempvar groupvar
		gen `groupvar'=1
	}
	* Temporary matrices and scalars
	tempname V_D V_0 V_spatial
	
	* Generating strings out of id variables for ease
	cap qui tostring `latitude', generate(`_lat')
	cap qui tostring `longitude', generate(`_lon') 
	
	* Generating id for points
	egen `_point'=group(`_lat' `_lon')
	cap qui tostring `_point', force replace
	* Unique values for ego and alter combined
	qui {
		tempfile fdata
		save `fdata'
		mata: point = st_sdata(.,("`_lat'","`_lon'"))
		mata: uid= uniqrows(uniqrows(point[.,1])\uniqrows(point[.,2])) 
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
		vcimatrix: `equation', id1(`_lat') id2(`_lon') weightss(`weights') groups(`groupvar') cuts(`cutoff')
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
		parallel, nodata prog(vcimatrix_parallel): vcimatrix_parallel: `equation', id1("`_lat'") id2("`_lon'") absorbs("`absorb'") groups("`groupvar'") weightss("`weights'") cuts("`cutoff'") parallel
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
		qui: `equation' [aw=`weights'], cluster(`_point')
	}
	else {
		tokenize `equation'
		local equation= subinstr("`equation'","`1'","reghdfe",1)
		qui: `equation' [aw=`weights'], cluster(`_point') absorb(`absorb')
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
	matrix `V_spatial' = V_C - `V_D' - (`ndd'-2)*`V_0'
	matrix drop V_C
	ereturn repost V = `V_spatial'
	ereturn scalar df_r = .
	if "`absorb'"=="" {
		regress
	}
	else{
		reghdfe
	}
end
