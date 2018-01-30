/*combine all enrollment files to create single data set*/
%macro loop;
options spool;
%let n=60;
%do i=1 %to &n;
data enroll&i;
infile "/.../enrollment&i..txt" dsd dlm='	';
input number name $ city $ year_original $ form $ stud :$10.;
st=compress(stud, ",");
students=input(st, 10.);
year = input(year_original, 4.);
run;

%end;
%mend;
%loop;


%macro combine;
%let j=60;
data final;
set
%do i = 1 %to &j;
enroll&i
%end;;
run;
%mend;
%combine;

proc print data=final;
var number name city year form students;
run;


proc report data=final;
column form students;
define form/group;
where form="Private";
define students/analysis sum "Total enrollment at private universities";
run;

proc report data=final;
column name students;
define name/group;
where name like "United S%";
define students/analysis sum "Total enrollment in the US schools";
run;

proc corr data=final;
var year students;
run;
