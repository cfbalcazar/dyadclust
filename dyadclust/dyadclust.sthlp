{smcl}
{* *! version 1.0 22MAR2021}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:dyadclust} {hline 2}}Linear regression using dyadic clustering {p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2} {cmd:dyadclust:}
{cmd: {ul:reg}ress} {depvar} {indepvars} {cmd:,} {opth ego:id(varname)}  {opth alter:id(varname)} [{opth weights(varname)} {opth absorb(varlist)} {cmd: {ul:par}allel} ] {p_end}

{marker opt_summary}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model }
{synopt: {opt ego:id(varname)}} variable indicating the first element of the dyad (e.g., country of destination). {p_end}
{synopt: {opt alter:id(varname)}} variable indicating the second element of the dyad (e.g., country of origin).{p_end}
	
{syntab:Optional}
{synopt :{opt weights(varname)}} runs the regression using the specified analytic weights.{p_end}
{synopt :{opt absorb(varlist)}} categorical variables that identify the fixed effects to be absorbed. This option implements {browse "https://github.com/sergiocorreia/reghdfe": reghdfe}. 
	(Caution: the user should not use reghdfe instead of {cmd:{ul:reg}ress} after {cmd:dyadclust:}). {p_end}
{synopt :{opt par:allel}} parallel computing implementation. This option works better with a large number of dyads and CPUs. To use this option, the
{browse "https://github.com/gvegayon/parallel": parallale package} needs to be installed. {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:dyadclust} estimates cluster-robust standard errors for dyadic data using multiway decomposition
 as described in {browse "https://www.cambridge.org/core/journals/political-analysis/article/abs/clusterrobust-variance-estimation-for-dyadic-data/D43E12BF35240100C7A4ED3C28912C95": Aronow et al. (2015)}.{p_end}

{marker postestimation}{...}
{title:Postestimation Syntax}

Exactly the same as in {help regress}. If the {cmd: absorb} option is used, posestimation follows the rules of {help reghdfe}.

{marker Stored}{...}
{title:Stored results}

Exactly the same as in {help regress}. If the {cmd: absorb} option is used, the stored results follow the rules of {help reghdfe}.

{hline}
{marker examples}{...}
{title:Example}

{pstd}Using the data from {browse "https://github.com/cfbalcazar/dyadclust/tree/main/dyadclust": github repository}: {p_end}

{phang2}{cmd: u "https://raw.githubusercontent.com/cfbalcazar/dyadclust/main/dyadclust/datasim.dta", clear}{p_end}
{pstd} {p_end}

{pstd} Simple example: {p_end}

{phang2}{cmd: dyadclust: reg dY dX, ego(dyad1) alter(dyad2)  }{p_end}

{pstd} Example using parallelization: {p_end}

{phang2}{cmd: dyadclust: reg dY dX, ego(dyad1) alter(dyad2) par }{p_end}

{pstd} Example using absorb and parallelization: {p_end}

{phang2}{cmd: gen randn=runiform()}  {p_end}
{phang2}{cmd: egen fe = cut(randn), group(5)}  {p_end}
{phang2}{cmd: dyadclust: reg dY dX, ego(dyad1) alter(dyad2) absorb(fe) par }{p_end}
{hline}
{hline}

{marker contact}{...}
{title:Author}

{pstd}Felipe Balcazar{break}
New York University, Wilf Department of Politics.{break}
Email: {browse "mailto:cfbalcazar@nyu.edu ":cfbalcazar@nyu.edu }
{p_end}

{marker updates}{...}
{title:Updates}

{phang2}For updating the package please use: {p_end}

{phang2}{cmd: net install dyadclust, from (https://raw.githubusercontent.com/cfbalcazar/dyadclust/main/dyadclust/) replace force all}

{marker references}{...}
{title:References}

{p 0 0 2}
{phang}
Aronow, Peter M., Cyrus Samii, and Valentina A. Assenova. 
"Cluster–robust variance estimation for dyadic data." 
{it:Political Analysis (2015): 564-577.}
{browse "https://www.cambridge.org/core/journals/political-analysis/article/abs/clusterrobust-variance-estimation-for-dyadic-data/D43E12BF35240100C7A4ED3C28912C95":[link]}
