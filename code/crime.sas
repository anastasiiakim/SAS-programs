/*read data files*/
/*data from freedman.txt*/
data freedman;
infile "/.../freedman.txt" dsd dlm=' ' firstobs=2;
input city_name :$20. fr_population :$10. nonwhite $ density $ crime;
city = upcase(city_name); /*convert to uppercase*/
fr_population = 1000*fr_population; /*times by 1000 to obtain correct value*/
run;

data wiki; /*data from wikipedia*/
infile "/.../wiki.txt" dsd dlm='	' firstobs=2;
input state :$20. city_name :$20. wiki_population :$10. violent_crime murder rape $ robbery assault property $ burglary  larceny $ vehicle;
city = upcase(city_name); 
run;


/*sort data by city before merging*/
proc sort data=freedman;
by city;
run;

proc sort data=wiki;
by city;
run;


/*#1 merging data by city name*/
data crime;
merge freedman(in=city_first) wiki (in=city_second); /*to avoid duplicate cities*/
by city;
if city_first and city_second;
keep city_name state fr_population crime wiki_population violent_crime; /*only keep these var-s*/
run;

proc print data=crime;
title 'Merging data by city name';
run;



/*#2 missing values*/
/*I've repeated code without $ signs for some var-s to apply proc means n nmiss*/
data freedman;
infile "/.../freedman.txt" dsd dlm=' ' firstobs=2;
input city_name :$20. fr_population nonwhite  density crime;
city = upcase(city_name);
fr_population = 1000*fr_population;
run;

data wiki;
infile "/.../wiki.txt" dsd dlm='	' firstobs=2;
input state :$20. city_name :$20. wiki_population violent_crime;
city = upcase(city_name);
run;

proc sort data=freedman;
by city;
run;

proc sort data=wiki;
by city;
run;

data crime;
merge freedman(in=city_first) wiki (in=city_second);
by city;
if city_first and city_second;
keep city_name state fr_population crime wiki_population violent_crime;
run;

proc means data=crime n nmiss;
title 'Number of missing values for variables of interest';
var _numeric_; /*count # of missing values for numeric var-s*/
run;

data crime;
merge freedman(in=city_first) wiki (in=city_second);
by city;
if city_first and city_second;
keep city_name state fr_population crime wiki_population violent_crime missingsAll;
missingsAll = (fr_population = .)+ (crime = .)+ (wiki_population = .)+ (city_name = " ")+ (state = " ") + (violent_crime = .); /*count # of missing values in each row*/
run;
/*
proc print data=crime;
title 'Pattern in missing data';
var city_name state fr_population wiki_population crime violent_crime missingsAll; 
run;
*/

/*#3 changes in population and crime*/
data crime;
merge freedman(in=city_first) wiki (in=city_second);
by city;
if city_first and city_second;
keep city_name fr_population wiki_population changed_population crime violent_crime changed_viol_crime;
changed_population = wiki_population - fr_population; /*change in population*/
changed_viol_crime = violent_crime - crime; /*change in crime*/
run;


proc print data=crime;
title 'The change in population size from 1975 to 2012';
var city_name fr_population wiki_population changed_population;
run;

proc sort data=crime out=sorted_pop; /*save sorted results in sorted_pop*/
by changed_population;
run;

proc print data=sorted_pop;
title 'The cities which have decreased in population size';
var city_name changed_population; /*consider only these var-s*/
run;

proc print data=crime;
title 'The change in violent crime from 1975 to 2012';
var city_name crime violent_crime changed_viol_crime;
run;

/*plot changed_population vs changed_violent_crime*/
proc gplot data=crime;
title 'The changes in population vs the changes in crime rate';
symbol v=square color=cornflowerblue; /*points form and color*/
plot changed_population*changed_viol_crime; /*plot y vs x*/
run;

proc corr data=crime; /*correlation between var-s listed below*/
var changed_viol_crime changed_population; 
run;

/*#4 compare the "crime" ranks between two data sets*/
data crime;
merge freedman(in=city_first) wiki (in=city_second); /*merging by city_name*/
by city;
if city_first and city_second;
keep city_name crime violent_crime;
run;

proc rank descending data=crime out=rankings; /*get ranks for cities, save result in 'rankings' data*/
var crime violent_crime;
ranks fr_rank wiki_rank;
run;

proc print data=rankings; 
title 'The ranks of the cities in terms of their crime';
run;

/*plot the ranks of the cities in terms of their crime rate from wiki data vs those from freedman.txt*/
proc gplot data=rankings;
title 'The ranks on Wikipedia vs ranks in Freedman';
symbol v=square color=darkorange;
plot wiki_rank*fr_rank; /*y vs x*/
run;

proc corr data=rankings; /*correlation to see relationship of var-s*/
var fr_rank wiki_rank; 
run;

/*5 for each state get the city with the highest crime rate and the city with the lowest crime rate*/
data crime_an; 
set wiki;
infile "/.../wiki.txt" dsd dlm='	' firstobs=2;
input state :$20. city_name :$20. wiki_population violent_crime;
keep city_name state violent_crime; /*set from wiki with only these var-s*/
run;

proc sort data=crime_an out=crime_analysis;
by state violent_crime; /*sorting by this var*/
run;

/*after sorting we can get first(lowest) and last observations(highest) for each state*/
data low_crime;
set crime_analysis;
by state; 
fs=first.state; 
if fs then lowCrimeCity=city_name;
run;

data low_crime_analysis (rename=(violent_crime=lowCrime)); /*rename this var to avoid overriding during merging*/
set low_crime;
where lowCrimeCity^=" "; /*drop rows when we don't have lowCrimeCity (it's empty)*/
run;


data high_crime; /*do the same things as with low_crime*/
set crime_analysis;
by state; 
ls=last.state;
if ls then highCrimeCity=city_name;
run;

data high_crime_analysis (rename=(violent_crime=highCrime));
set high_crime;
where highCrimeCity^=" ";
run;

/*merging by state*/
data merge_crime_analysis;
merge low_crime_analysis(in=state_name_low) high_crime_analysis(in=state_name_high);
by state;
if state_name_low and state_name_high;
run;
 
proc print data=merge_crime_analysis;
title 'The cities with the lowest ann highest crime rates for each state';
var state LowCrime lowCrimeCity highCrime highCrimeCity;
run;

