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

timer list
