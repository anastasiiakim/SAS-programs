/*get a 95% bootstrap percentile interval for the difference in medians 
between normal body temperature for people aged <= 75 vs those > 75 
ignoring the sex of the individuals*/
data temperature;
infile "/.../normtemp.txt" dsd dlm='	';
input temperature sex $ age;
run;

data new_temperature;
set temperature;
if age <= 75 then temp1=temperature;
else temp1=.;
if age > 75 then temp2=temperature;
else temp2=.;
run;

proc surveyselect data=new_temperature out=outboot
seed=201411 method=urs 
samprate = 1 outhits rep = 1000;
run;

proc means data=outboot noprint;
class Replicate;
var temperature;
output out=meanboot1 median(temp1)=med1;
run;

proc means data=outboot noprint;
class Replicate;
var temperature;
output out=meanboot2 median(temp2)=med2;
run;

data meanboot;
merge meanboot1(in=mb1) meanboot2(in=mb2);
by Replicate;
if mb1 and mb2;
medtemp = med1-med2;
run;

ods select quantiles;
proc univariate data=meanboot;
var medtemp;
output out=percentiles pctlpts=2.5 97.5 pctlpre=medtemp;
run;

proc print data=percentiles;
run;

proc means data=meanboot;
where Replicate>=1;
var medtemp;
run;

proc means data=meanboot1;
where Replicate>=1;
var med1;
run;

proc means data=meanboot2;
where Replicate>=1;
var med2;
run;

proc univariate data=meanboot;
var medtemp;
histogram / normal;
run;


