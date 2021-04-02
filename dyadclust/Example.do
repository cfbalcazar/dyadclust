clear all

cd "`c(pwd)'"

u datasim, clear

expand 7

timer clear

timer on 1
dyadclust: reg dY dX, ego(dyad1) alter(dyad2)  
timer off 1

timer on 2
dyadclust: reg dY dX, ego(dyad1) alter(dyad2)  par
timer off 2

* Testing the absorb option
gen randn=runiform()
egen fe = cut(randn), group(5)

timer on 3
dyadclust: reg dY dX, ego(dyad1) alter(dyad2)  absorb(fe)
timer off 3

timer on 4
dyadclust: reg dY dX, ego(dyad1) alter(dyad2)  absorb(fe) par
timer off 4

timer list



