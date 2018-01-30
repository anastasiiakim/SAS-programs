data temperature;
infile "/.../normtemp.txt" dsd dlm='	';
input temperature sex $ age;
run;

/*set age categories*/
proc format;
value age 56-<60= "less than 60"
60-<64 = "60 to less than 64" 
64-<68 = "64 to less than 68" 
68-<72 = "68 to less than 72" 
72-<76 = "72 to less than 76" 
76-<80 = "76 to less than 80"
80-<84 = "80 to less than 84" 
84-<88 = "84 to less than 88"
88-<92 = "88 to less than 92";
run;

proc sort data=temperature;
by age;
format age age.;
run;

/*plot the boxplots*/
proc sgplot data=temperature;
format age age.;
vbox temperature / group=age category=sex boxwidth=0.3;
run;

