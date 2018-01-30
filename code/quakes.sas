/*data initialization*/
data earthquakes;
infile "/.../quakes.csv" dsd firstobs=2; /*space delimited data, starting read var-s from 2nd line*/
input publicid $ eventtype :$20. origintime :$24. modificationtime :$10. longitude latitude magnitude depth;
time = input(origintime, yymmdd10.);  /*convert to numeric and getting only date*/
modtime = input(modificationtime, yymmdd10.);
run;

data quakes;
set earthquakes; /*set that is only with earthquakes*/
where eventtype="earthquake";
run;

/*# of detectable earthquakes*/
proc freq data=earthquakes;
tables eventtype;
run;

/*correlation matrix*/
proc corr data=quakes;
var time longitude latitude magnitude depth;
run;

/*plot the latitude against magnitude of the earthquakes*/
proc gplot data=quakes;
title 'The plot of the latitude against magnitude of the earthquakes';
symbol v=square color=coral; /*assign form and color to the points*/
plot magnitude*latitude; /*plot y vs x*/
run;

/*To see relationship in more accurate way*/
/*ods graphics on;
proc reg data=quakes;
model magnitude=latitude;
run;
ods graphics off;*/

/*dealing with missing values*/
/*code missing values*/
data earthquakes;
infile "/.../quakes.csv" dsd firstobs=2;
input publicid $ eventtype :$20. origintime :$24. modificationtime :$10. longitude latitude magnitude depth;
time = input(origintime, yymmdd10.);
if (time = . | longitude = . | latitude = . | magnitude = . | depth = .) then missing = 1; /*assign to missing var 1 or 0*/
else missing = 0;
run;

data quakes;
set earthquakes;
where eventtype="earthquake";
run;

proc print data=quakes;
title 'Pattern in missing data';
where missing = 1;
run;

data quakes;
set earthquakes;
where eventtype="earthquake";
keep time longitude magnitude latitude depth; /*keep only these var-s in the set*/
run;

proc means data=quakes n nmiss;
title 'Number of missing values for variables of interest';
var _numeric_; /*count a number of the missing number for num var-s*/
run;


/*count the number of earthquakes on each day and the largest magnitude of the earthquakes that occurred that day*/
data earthquakes;
infile "/.../quakes.csv" dsd firstobs=2;
input publicid $ eventtype :$20. origintime :$24. modificationtime :$10. longitude latitude magnitude depth;
time = input(origintime, yymmdd10.);
run;

data quakes;
set earthquakes;
where eventtype="earthquake";
run;

proc means data=quakes noprint nway; /*save results to earth_means*/
class time;
format time yymmdd10.;
output out=earth_means(drop=_:) maxid(magnitude(magnitude))=; /*get max value for each class*/
run;

proc sort data=quakes; /*sort before merging*/
by time;
run;

proc freq data=quakes noprint; /*save results in earth_freq*/
tables time*eventtype / out=earth_freq nocum nopercent nocol norow; 
format time yymmdd10.;
run;

proc sort data=earth_freq; /*sort data by time before merging*/
by time;
run;

data dataset; /*merging*/
merge earth_freq (in=time_date) earth_means(in=date_time); 
by time;
if time_date and date_time;
keep time COUNT magnitude; 
run;

proc print data=dataset;
title 'The numbers of earthquakes on each day and the largest magnitude of the earthquakes that occured that day';
run;

/*scatterplot*/
/*
proc gplot data=quakes;
title 'The plot of the latitude against longitude of the earthquakes';
symbol v=square color=coral;
plot latitude*longitude; 
run;*/
proc gplot data=quakes;
title 'The plot of the magnitude against depth of the earthquakes';
symbol v=square color=bipb; /*assign form and color to the points*/
plot magnitude*depth; /*plot y vs x*/
run;

/*time series plot*/
proc sgplot data=quakes;
title 'The time series plot of the earthquakes depths';
symbol v=square color=bib;
series x=time y=depth;
format time yymmdd10.; /*display time in yymmdd10. format*/
run;
/*
proc sgplot data=quakes;
title 'The time series plot of the earthquakes magnitude';
series x=time y=magnitude;
format time yymmdd10.;
run;

proc sgplot data=quakes;
title 'The time series plot of the earthquakes latitude';
series x=time y=latitude;
format time yymmdd10.;
run;
*/

/*get the times between successive earthquakes*/
data sort_quakes;
set quakes; /*set in which only earthquakes*/
mtime = substr(origintime, 12, 12); /*get a part from string for time variable starting from 12th element with length=12*/
my_time = input(mtime, time12.3); /*convert time to numeric*/
last_time=lag1(my_time);
diff_time=last_time-my_time; /*count difference*/
if (diff_time < 0) then diff_time=new_time + 24*60*60; /*to avoid incorrect results, if we have negative diff --> we consider time for different dates*/
run;

proc print data=sort_quakes (obs=25); /*print first 25 obs-s*/
title 'First 25 times between successive earthquakes';
var my_time last_time diff_time;
format my_time last_time diff_time time12.; /*print time in the correct format*/
run;

title 'Histogram of the times between successive earthquakes';
proc univariate data=sort_quakes noprint;
histogram diff_time;
format diff_time time12.; 
run;



