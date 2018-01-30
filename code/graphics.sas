data temperature;
infile "/.../normtemp.txt" dsd dlm='	';
input temperature sex $ age;
run;

proc format;
value age 56-<60= "[56,60)"
60-<64 = "[60,64)" 
64-<68 = "[64,68)" 
68-<72 = "[68,72)" 
72-<76 = "[72,76)" 
76-<80 = "[76,80)"
80-<84 = "[80,84)" 
84-<88 = "[84,88)"
88-<92 = "[88,92)";
run;

proc template;
   define statgraph Panel;
      begingraph / designheight=1000px designwidth=1000px; /*set height and width*/
    
         layout lattice / rows=3 columns=1; /*view in three rows and one column*/     

            layout overlay / wallcolor=darksalmon; /*assign wallcolor*/
               scatterplot y=temperature x=age/ markerattrs=(color=darkblue symbol=square); /*scatterplot with markerattrs*/
            endlayout;
   
            /*barchart, set y-axis from 97 to 101*/
			layout overlay / cycleattrs=true wallcolor=lemonchiffon yaxisopts=(linearopts=(viewmin=97 viewmax=101)) yaxisopts=(display=(line ticks tickvalues));
              barchart x=age y=temperature / stat=mean; /*stat: specifies the statistic to be computed for the Y-axis*/
           endlayout;
 
			layout overlay / cycleattrs=true wallcolor=bibg yaxisopts=(linearopts=(viewmin=97 viewmax=101)) yaxisopts=(display=(line ticks tickvalues));
			  boxplot x=age y=temperature; /*boxplots*/
           endlayout;        
            
         endlayout;
      endgraph;
   end;
run;

/*use sgrender based on the template above*/
proc sgrender data=temperature template=panel;
title "Scatterplot, bar graph and boxplots of temperature vs. age if Sex = 1";
format age age.;
where sex="1";
run;


proc sgrender data=temperature template=panel;
title "Scatterplot, bar graph and boxplots of temperature vs. age if Sex = 2";
format age age.;
where sex="2";
run;