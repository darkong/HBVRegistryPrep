*==========================================================================================;
* Analyst : 		Alexia Exarchos
* Created : 		May 16, 2012 by Alexia Exarchos
* Last Updated : 	June 19, 2012 by Alexia Exarchos
* Purpose : 		Creates summary tables for Annual Report
*==========================================================================================;

* Set libnames and create user-defined formats;
%let homeloc=R:\State Surveillance\HBV Data Analysis\HBV Match 2012\;
%include "&homeloc.\SAS Code\01_Standard_Header\01 Standard_Header _20120607.sas";


data main01; *deduplicated dataset - one record per case;
set mainfldr.Chronic_HBV_Registry01;
firstyear=year(firstdate);
first_lhj=upcase(first_lhj);
common_lhj=upcase(common_lhj);
run;

data main02; *duplicated  dataset - all records for each person;
set mainfldr.Chronic_HBV_Registry02;
attrib firstdate length = 8. format = MMDDYY10. informat = MMDDYY10.;
firstyear=year(firstdate);
local_health_juris=upcase(local_health_juris);
run;

*Number of HBV Case reports since reporting mandated in CA;
proc freq data=main02;
table firstyear;
where 1978<=firstyear<=2011 and local_health_juris ne "OUT OF STATE";
run;

*Number of deduplicated HBV cases since reporting mandated in CA;
proc freq data=main01;
table firstyear;
where 1978<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HBV cases by age; 
proc freq data=main01;
table age*firstyear/missing norow nopercent;
format age agechart.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;
data age;
set main01;
if age ne ' ';
run;
proc freq data=age;
table age*firstyear/missing norow nopercent;
format age agechart.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;
proc sort data = main01;
by firstyear;
run;
proc univariate data=main01;
by firstyear;
var age;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HBV cases by race/ethnicity;
proc freq data=main01;
table race_ethnicity*firstyear/missing norow nopercent;
format race_ethnicity $raceamal.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;
data race;
set main01;
if race_ethnicity ne 'Unknown';
run;
proc freq data=race;
table race_ethnicity;
format race_ethnicity $raceamal.;
where firstyear=2011 and first_lhj ne "OUT OF STATE";
run;

*HBV cases by gender;
proc freq data=main01;
table sex*firstyear/missing norow nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;
data sex;
set main01;
if sex ne 'U';
run;
proc freq data=sex;
table sex*firstyear/missing norow nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HBV cases by age group and race/ethnicity;

data race2;
set main01;

if race_ethnicity = 'Native American/Alaska' then race_ethnicity = 'Native American/Alaskan Native';
run;

proc freq data=race2;
table age*race_ethnicity/missing nopercent;
format age agechart. race_ethnicity $raceamal.;
where firstyear=2011 and first_lhj ne "OUT OF STATE";
run;
*HBV by sex and race;
proc freq data=main01;
table race_ethnicity*sex/missing nopercent;
format race_ethnicity $raceamal.;
where firstyear=2011 and first_lhj ne "OUT OF STATE";
run;
*HBV cases by LHJ;
proc freq data=main01;
table first_lhj*firstyear/missing nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

data test;
set main01;
if first_lhj = ' ';
run;

*Data dictionary - printout of variables;
proc contents data = main01 varnum;
run;
proc contents data = main02 varnum;
run;







********************************************************************************************************************
*DATA REQUESTS;
**********************************************************************************************************************

*2010 - LA, SF, SANTA CLARA, CA Total;

proc freq data=main02;
table firstyear*local_health_juris;
where firstyear=2010 and local_health_juris ne "OUT OF STATE" and local_health_juris in ('SANTA CLARA','SAN FRANCISCO','LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES by SELECTED LHJs, 2010';
run;
proc freq data=main01;
table firstyear*first_lhj;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj in ('SANTA CLARA','SAN FRANCISCO','LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES by SELECTED LHJs, 2010';
run;

*HBV cases by age; 
proc freq data=main01;
table firstyear*age*first_lhj/missing norow nopercent;
format age agechart.;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj in ('SANTA CLARA','SAN FRANCISCO','LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES by AGE, 2010';
run;
proc freq data=main01;
table firstyear*age/missing norow nopercent;
format age agechart.;
where firstyear=2010 and first_lhj ne "OUT OF STATE";
title 'REPORTED CHRONIC HEPATITIS B CASES by AGE, 2010';
run;

*HBV cases by race/ethnicity;
proc freq data=main01;
table firstyear*race_ethnicity*first_lhj/missing norow nopercent;
format race_ethnicity $raceamal.;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj in ('SANTA CLARA','SAN FRANCISCO','LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES by RACE/ETHNICITY, 2010';
run;
proc freq data=main01;
table race_ethnicity/missing norow nopercent;
format race_ethnicity $raceamal.;
where firstyear=2010 and first_lhj ne "OUT OF STATE";
title 'REPORTED CHRONIC HEPATITIS B CASES by RACE/ETHNICITY, 2010';
run;

*HBV cases by gender;
proc freq data=main01;
table firstyear*sex*first_lhj/missing norow nopercent;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj in ('SANTA CLARA','SAN FRANCISCO','LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES by GENDER, 2010';
run;
proc freq data=main01;
table sex/missing norow nopercent;
where firstyear=2010 and first_lhj ne "OUT OF STATE" ;
title 'REPORTED CHRONIC HEPATITIS B CASES by GENDER, 2010';
run;

* Look at the time between an acute diagnosis date and a chronic diagnosis date among the matched acute/chronic cases - 
assume acute date is first;
data datedif;
set masterchronic;

if acute_dxdate ne ' ';

daydiff = datdif(acute_dxdate, chronic_dxdate,'ACT/ACT');
modiff = daydiff/30;
yrdiff = daydiff/365.25;
format modiff 4.;
format yrdiff 4.;
yrdiff1 = input(yrdiff,$4.);

if yrdiff1 = ' ' then diff = daydiff;
else diff = yrdiff1;

if dxyear <=1999 then period = '<=1999';
                 else period = '2000+';

if daydiff <0 then difference = 'negative';
else if daydiff >=0 then difference = 'positive';

if difference ne 'negative';
run;
proc freq data = datedif;
table period*difference;
run;
proc sort data = datedif; by period;
run;
proc means data = datedif n mean median;
var daydiff;
by period;
run;

*2010 - deduplicated case reports no in LA/SF;

proc freq data=main01;
table firstyear;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj notin ('SAN FRANCISCO','LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES (not LA/SF), 2010';
run;
data notLA (keep = first_lhj firstyear race_ethnicity);
set main01;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj notin ('LOS ANGELES') and race_ethnicity = 'Unknown';
run;

data notSFLA;
set main01;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj notin ('SAN FRANCISCO','LOS ANGELES') and race_ethnicity = 'Unknown';
run;

proc freq data=main01;
table firstyear;
where firstyear=2010 and first_lhj ne "OUT OF STATE" and first_lhj notin ('LOS ANGELES');
title 'REPORTED CHRONIC HEPATITIS B CASES (not LA), 2010';
run;

*API Breakdown;
proc freq data=main01;
table race_ethnicity*firstyear/missing norow nopercent;
*format race_ethnicity $raceamal.;
where firstyear>=2010 and first_lhj ne "OUT OF STATE";
run;
data race;
set main01;
if race_ethnicity ne 'Unknown';
run;
proc freq data=race;
table race_ethnicity;
format race_ethnicity $raceamal.;
where firstyear=2011 and first_lhj ne "OUT OF STATE";
run;

data api;
set morbfile;
if ctyear >=2010;
run;

proc freq data=api;
table race/list;
run;
