# dyadclust


This repository contains the command ```dyadclust``` for Stata, which estimates cluster-robust standard errors for dyadic data using multiway decomposition as described in [Aronow et al. (2015)](https://www.cambridge.org/core/journals/political-analysis/article/abs/clusterrobust-variance-estimation-for-dyadic-data/D43E12BF35240100C7A4ED3C28912C95). 

The package also supports parallel computing. For parallelization, the [parallel package](https://github.com/gvegayon/parallel) needs to be installed.

To install the package and update it the following command can be used in Stata:
```
net install dyadclust, from (https://raw.githubusercontent.com/cfbalcazar/dyadclust/main/dyadclust/) replace force all
```

Improvements to the code are welcomed.

An R implementation can be found [here](https://github.com/jbisbee1/dyadRobust/).

Keywords: dyadic clustering stata

