*This program creates the summary data necessary to complete the tables in the annual report;

* Main directory;
%let directory=\\cdphdcdc_01\Groups\STD\Office of Adult Viral Hepatitis Prevention\State Surveillance\;
libname mainfldr "&directory.Adam Coutts Code Folder\Datasets";

* Set libnames and create user-defined formats;
%let homeloc=\\cdphdcdc_01\Groups\STD\Office of Adult Viral Hepatitis Prevention\State Surveillance\Adam Coutts Code Folder\Production;
%include "&homeloc.\Production20072011Data\01 Standard_Header _20120328.sas";

data main01; *deduplicated dataset - one record per case;
set mainfldr.main01;
first_lhj=upcase(first_lhj);
common_lhj=upcase(common_lhj);
where overall_diagnosis in (1,2);
run;

data main02; *duplicated  dataset - all records for each person;
set mainfldr.main02;
attrib firstdate length = 8. format = MMDDYY10. informat = MMDDYY10.;
firstdate = min (episode_date_1, episode_date_2, episode_date_3, episode_date_4, collection_date, result_date);
firstyear=year(firstdate);
local_health_juris=upcase(local_health_juris);
if diagnosis not in ('Confirmed') and diagnosis2 not in (1,2) then delete;
run;

*Number of HCV case reports received by CDPH during 1999-2011;
proc freq data=main02;
table firstyear;
where 1999<=firstyear<=2011 and upcase(local_health_juris) ne "OUT OF STATE";
run;

*Number of deduplicated HCV cases;
proc freq data=main01;
table firstyear;
where 1999<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HCV cases by age; *Should we exclude age = 0?;
proc freq data=main01;
table age*firstyear/missing norow nopercent;
format age agechart.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

proc sort data=main01;
by firstyear;
run;

proc univariate data=main01;
by firstyear;
var age;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HCV cases by race/ethnicity;
proc freq data=main01;
table race_ethnicity*firstyear/missing norow nopercent;
format race_ethnicity $raceamal.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HCV cases by gender;
proc freq data=main01;
table sex*firstyear/missing norow nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*HCV cases by age group, sex, race/ethnicity;
*Total;
proc freq data=main01;
table age*race_ethnicity/missing nopercent;
format age agechart. race_ethnicity $raceamal.;
where firstyear=2011 and first_lhj ne "OUT OF STATE";
run;

*Males;
proc freq data=main01;
table age*race_ethnicity/missing nopercent;
format age agechart. race_ethnicity $raceamal.;
where firstyear=2011 and sex='M' and first_lhj ne "OUT OF STATE";
run;

*Females;
proc freq data=main01;
table age*race_ethnicity/missing nopercent;
format age agechart. race_ethnicity $raceamal.;
where firstyear=2011 and sex='F' and first_lhj ne "OUT OF STATE";
run;

*Transgender/Unknown;
proc freq data=main01;
table race_ethnicity;
format age agechart. race_ethnicity $raceamal.;
where firstyear=2011 and sex in ('T','U') and first_lhj ne "OUT OF STATE";
run;

*Jurisdiction;
proc freq data=main01;
table first_lhj*firstyear/norow nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE";
run;

*Incarcerated at first report by Jurisdiction;
proc freq data=main01;
table first_lhj*firstyear/norow nocol nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE" and prison_firstrpt='Y';
run;

*Incarcerated if ever report by Jurisdiction;
proc freq data=main01;
table first_lhj*firstyear/norow nocol nopercent;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE" and prison_ever='S';
run;

/* Analysis of incarecerated persons */
/* Incarcerated at first report */

*Age;
proc freq data=main01;
table age*firstyear/missing norow nopercent;
format age agechart.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE" and prison_firstrpt='Y';
run;

proc univariate data=main01;
by firstyear;
var age;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE" and prison_firstrpt='Y';
run;



/* Incarcerated ever */

*Age;
proc freq data=main01;
table age*firstyear/missing norow nopercent;
format age agechart.;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE" and prison_ever='S';
run;

proc univariate data=main01;
by firstyear;
var age;
where 2007<=firstyear<=2011 and first_lhj ne "OUT OF STATE" and prison_ever='S';
run;
