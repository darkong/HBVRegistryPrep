*=====================================================================;
* Analyst: 		Adam Coutts
* Created: 		May 19, 2011
Last Updated:	May 3, 2012 by Alexia Exarchos
* Purpose: 		Find matched pairs of cases - for deduplcating purposes
*=====================================================================;


* Prepare main dataset for merging process;
* Apply index - for rapid lookups;
data setx11 (index = (id first_name last_name zip date_of_birth ssn));
	informat zip $5.;
	* Just keep certain variables;
	set set101 (keep = first_name last_name ssn date_of_birth sex patient_zip_code race_ethnicity
		account_zip_code local_health_juris id prison middle_name patient_id country countrybirth data_source);
	* Create a single zip code for georgraphical location comparisons - take patient zip first, account zip
			if patient is not available;
	if patient_zip_code > 0 then zip = strip(put(patient_zip_code,8.));
		else zip = strip(put(account_zip_code,8.));
	* Strip out leading/trailing blanks so as to make double extra sure that all these variables show up as missing if
		they are indeed missing;
	local_health_juris = strip (local_health_juris);
	first_name = strip (first_name);
	last_name = strip (last_name);
	middle_name = strip (middle_name);

	* Drop first names with numbers in them;
	if anydigit (first_name) then first_name = '';

	* For comparison purposes, combine Asian and PI race/enthicity values into one;
	if strip(race_ethnicity) in ("Cambodian","Chinese","Filipino","Guamanian","Hawiian","Hmong","Japanese","Korean","Laotian",
		"Other/Unknown Asian","Pacific Islander","Samoan","Vietnamese","Asian Indian") 
		then race_ethnicity = "Asian/Pacific Islander";
	*if race_ethnicity = "Other" then race_ethnicity = "Unknown"; *Other is a legitimate race/ethnicity category (n=24205 records);
	if race_ethnicity="Multirace" then race_ethnicity="Other";

*	where substr(last_name,1,1) = "Y";

	drop patient_zip_code account_zip_code;
run;




* Calculate distances between zip codes - code copied from Glenn Wright;
proc sql;
	create	table zips as
	select	distinct zip from setx11
	;
	create	table zipzips as
	select	a.zip||b.zip as zipzip, zipcitydistance(a.zip,b.zip) as dist
	from	zips as a INNER JOIN zips as b
	on		a.zip ^= b.zip
	;
	create	table zip25 as
	select	zipzip
	from	zipzips
	where	0 <= dist <= 25
	;
	create	table zip50 as
	select	zipzip
	from	zipzips
	where	25 < dist <= 50
	;
quit;

*Macro to create weights for how frequent values of various variables are - an exact or near match of a rare name 
	(or bday, or zip code address) is more of a sign of an actual match than a match of something more common
	- code copied from Glenn Wright;

%macro create_weights_fmt (data=, var=, fmtname=,log=, asian_adjust=FALSE);

	%* First create datasets ("asian" and "not_asian") to use in counting relative frequency;
	%* Seperate adjustment for asian names because names that are written almost the same but are different names 
		are more common;
	%if (&asian_adjust. = TRUE) %then %do;
    	proc sql;
       	create table asian as
           	select &var., count(&var.) as freq
			from &data.
			where race_ethnicity = "Asian/Pacific Islander" 
			group by &var.
            ;

		create table not_asian as
        	select &var., count(&var.) as freq
			from &data.
			where race_ethnicity not in ("Asian/Pacific Islander","Other","Unknown") 
            group by &var.
            ;


		create table highly_asian as
			select a.&var., a.freq
			from asian as a LEFT JOIN not_asian as b
            on a.&var. = b.&var.
			where a.freq > b.freq
			;

		drop table asian, not_asian
			;
		quit;
	%end;

	%* Count total numbers of value of variable and insert that count into n variable;
	proc sql noprint;
		select count(&var.) into :n from &data.;
      	quit;

%if &log = 1 %then %do;

%* create variable freq which is amount each value of a variable shows up as a percent of all valid values
		insert value of variable into new variable start - do proceedure differently for logarithmic weights 
		and for straight-up counts;
	proc sql;
		create table temp as
		select &var. as start, count(&var.)/&n. as freq
            from &data.
            where &var. is not missing
            group by &var.;
      	quit;

	%* Create a format - variable value maps to the left side ("start"), result of equasion maps to ("label");
	data temp2;
		set temp end=last;

		fmtname = "$&fmtname";

		label = put(-log2(freq),z8.3);

		if last then do;
			start = '';
			hlo = 'o';
			label = put(log2(&n.),z8.3);
        end;
		run;
%end;


%if &log = 2 %then %do;
	%* Do the same thing, but with unadjusted counts;
	proc sql;
		create table temp as
		select &var. as start, count(&var.) as freq
            from &data.
            where &var. is not missing
            group by &var.;
      	quit;

	data temp2;
		set temp end=last;

		fmtname = "$&fmtname";

		label = put(freq,8.);

		if last then do;
			start = '';
			hlo = 'o';
			label = 1;
        	end;
		run;
%end;
		
	%* Do same procedure but add modifier for frequency of Asian names;
	%if (&asian_adjust. = TRUE) %then %do;

	proc sql;
		create table temp2 as
			select start, hlo, fmtname,

			case when start in (select first_name from highly_asian) then put(-0.8*log2(freq),z8.3)
				else label end as label
			from temp2
			;

			drop table highly_asian
			;
		quit;

	%end;


	%* Actually create functions;
	proc format library = work cntlin = work.temp2;
		run;

	%* Drop tables no longer needed;
	proc sql;
		drop table temp, temp2;
		quit;
%mend;

* Create logarithmic weights for comparisons;
%create_weights_fmt (data=mainfldr.main01, var=first_name, fmtname=fname_w,log=1);
%create_weights_fmt (data=mainfldr.main01, var=first_name, fmtname=fname_a, log=1, asian_adjust=TRUE);
%create_weights_fmt (data=mainfldr.main01, var=last_name, fmtname=lname_w,log=1);
%create_weights_fmt (data=setx11, var=zip, fmtname=zip_w,log=1);
%create_weights_fmt (data=mainfldr.main01, var=date_of_birth, fmtname=dob_w,log=1);
%create_weights_fmt (data=setx11, var=local_health_juris, fmtname=lhj_w,log=1);
* Create un-logarithmic weights for comparisons;
%create_weights_fmt (data=mainfldr.main01, var=first_name, fmtname=fname_c,log=2);
%create_weights_fmt (data=mainfldr.main01, var=last_name, fmtname=lname_c,log=2);


/* 
* Add middle names longer than two characters;
data setfname;
	set mainfldr.main01 (keep = first_name)
		mainfldr.main01 (keep = middle_name rename = (middle_name = first_name));
	if missing(first_name) or length(strip(first_name)) < 3 then delete;
	run;

%create_weights_fmt (data=setfname, var=first_name, fmtname=fname_c,log=2);	*/



* Before comparing - reverse first and last name, if a person clearly has a first name for a last name, 
	and vice versa;
data setx11 (drop = tempname);
	set setx11;
	attrib tempname length = $22. format = $22. informat = $22.;

	if (((put(last_name,$fname_c.) / put(last_name,$lname_c.)) /
	(put(first_name,$fname_c.) / put(first_name,$lname_c.))) > 10) then do;
		tempname = last_name;
		last_name = first_name;
		first_name = tempname;
		end;

	* If first and last name are the same, and one is a lot more common as a first name or last name, then take that one;
	if first_name = last_name then do;
		if put(first_name,$fname_c.) / put(first_name,$lname_c.) > 1.5 then last_name = "";
		if put(first_name,$fname_c.) / put(first_name,$lname_c.) < .75 then first_name = "";
		if put(first_name,$fname_c.) / put(first_name,$lname_c.) = 1.0 then first_name = "";
		end;
	run;

*Main pair-finding code - for cases that have the same non-missing values for whatever variable the code block is 
	called on (it gets called for ssn, f name, l name, and dob), examine the two cases on various criteria 
	(similarity of f name, l name, m name, ssn, dob, race, sex, prisoner status, and location) to create a score that 
	estimates how certain we can be that these two cases are the same person.  End up with a dataset containing 
	various variables chosen at top of code;

%macro sql_blocking(var1,var2,var3);

	select  a.id as id1, b.id as id2,
			a.race_ethnicity as race1, b.race_ethnicity as race2,
			a.sex as sex1, b.sex as sex2,
			a.prison as prison1, b.prison as prison2,
			a.ssn as ssn1, b.ssn as ssn2,
				%if &var3 = 1 %then %do;
			a.zip as zip1, b.zip as zip2,
			a.local_health_juris as lhj1, b.local_health_juris as lhj2, 
				%end;
				%if &var3 = 2 %then %do;
			a.common_lhj as common_lhj1, b.common_lhj as common_lhj2,
			a.first_lhj as first_lhj1, b.first_lhj as first_lhj2, 
				%end;
			a.date_of_birth as dob1 format=date9., b.date_of_birth as dob2 format=date9.,
			a.first_name as fname1, b.first_name as fname2,
			a.middle_name as m1, b.middle_name as m2,
			a.last_name as lname1, b.last_name as lname2,

	case when a.ssn = . or b.ssn = . then 0
			when a.ssn = b.ssn then 17
			/* close matches - one number difference between two ssns*/
			when a.ssn > 10000 & countc (put(abs(a.ssn-b.ssn),8.),"123456789") = 1 then 15
			/* two number difference */
			when a.ssn > 10000 & countc (put(abs(a.ssn-b.ssn),8.),"123456789") = 2 then 9
			/* three number difference */
			when a.ssn > 10000 & countc (put(abs(a.ssn-b.ssn),8.),"123456789") = 3 then -1
			else -15 end as score_ssn,

	case when a.prison ne '-' & b.prison ne '-' then 3
		when a.prison = '-' & b.prison = '-' then 1
		else -1 end as score_pris,

	case  /* zero weight for missing sex */
   		when a.sex in ('','U') or b.sex in ('','U') then 0
		/* large weight for match on transexual */
		when a.sex = 'T' and b.sex = 'T' then 8
		/* no weight for disagreement if one record is transexual (think about it) */
		when a.sex = 'T' or b.sex = 'T' then 0
		/* matches */
		when (a.sex = 'F' and b.sex = 'F') | a.sex = 'M' and b.sex = 'M' then 1
		/* cases withe heavily gendered names (like "MARY" for women, "JOHN" for men) 
			when sex information is probably wrong */
		when (b.sex = 'M' & a.sex = 'F' & (put(a.first_name,$name_sex.) = 'M' | put(b.first_name,$name_sex.) = 'F')) |
		(b.sex = 'F' & a.sex = 'M' & (put(a.first_name,$name_sex.) = 'F' | put(b.first_name,$name_sex.) = 'M')) then 0
		/* large penalty for disagreeing sex */
		else -6 end as score_sex,

	case  /* zero weight for missing race */
		when a.race_ethnicity in ('Unknown','','Other') or b.race_ethnicity in ('Unknown','','Other') then 0
		/* small weight for same race, which correlates with names */
		when a.race_ethnicity = b.race_ethnicity then 2
		/* large penalty for disagreeing race */
		else -4.5 end as score_race,

/* Only do geographic matching the first time deduplicating - no simple geo variable to match on in final 
		Main01 dataset*/ 
%if &var3 = 1 %then %do;

	case  /* zero weight for missing geographical data*/
		when (missing(a.zip) or missing(b.zip)) and (missing(a.local_health_juris) or missing (b.local_health_juris)) 
			then 0
		when (missing(a.zip) or missing(b.zip)) and (a.local_health_juris = b.local_health_juris) then 
			0.9*%score(a.local_health_juris,b.local_health_juris,fmt=$lhj_w.)
		when (a.zip = '' or b.zip = '') and (a.local_health_juris ^= b.local_health_juris) then -3
		when a.zip = b.zip then 0.9*%score(a.zip,b.zip,fmt=$zip_w.)
		/* if one zip code is a major prison, then don't ding as much - hep people move far away to go to prison */
		when a.zip in ("91710", "91720", "91760", "92179", "92225", "92233", "92251", "93204", "93210", "93212", "93215", 
		"93280", "93409", "93423", "93536", "93561", "93610", "93960", "94964", "95213", "95304", "95327", "95532", 
		"95640", "95671", "95687", "96127", "96130") | b.zip in ("91710", "91720", "91760", "92179", "92225", "92233", 
		"92251", "93204", "93210", "93212", "93215", "93280", "93409", "93423", "93536", "93561", "93610", "93960", 
		"94964", "95213", "95304", "95327", "95532", "95640", "95671", "95687", "96127", "96130") then 0
		when a.zip||b.zip in (select zipzip from zip25) then 2
		when a.zip||b.zip in (select zipzip from zip50) then 0
		when a.local_health_juris = b.local_health_juris then
			0.9*%score(a.local_health_juris,b.local_health_juris,fmt=$lhj_w.)
		when complev(a.zip,b.zip)=1 then 0
		else -3 end as score_geo,

%end;

%if &var3 = 2 %then %do;

	case  /* zero weight for missing geographical data*/
		when (missing(a.common_lhj) or missing(b.common_lhj)) and (missing(a.first_lhj) or missing (b.first_lhj)) 
			then 0
		when (missing(a.common_lhj) or missing(b.common_lhj)) and (a.first_lhj = b.first_lhj) then 
			0.9*%score(a.first_lhj,b.first_lhj,fmt=$lhj_w.)
		when (a.common_lhj = '' or b.common_lhj = '') and (a.first_lhj ^= b.first_lhj) then -3
		when a.common_lhj = b.common_lhj then 0.9*%score(a.common_lhj,b.common_lhj,fmt=$lhj_w.)
		when a.first_lhj = b.first_lhj then
			0.9*%score(a.first_lhj,b.first_lhj,fmt=$lhj_w.)
		else -3 end as score_geo,

%end;

	case /* zero weight for missing names */
		when missing(a.first_name) or missing(b.first_name) then 0
		/* special handling for very short names, which mess with matching algorithms */
		when (length(a.first_name)=1 or length(b.first_name)=1) and substr(a.first_name,1,1)
			= substr(b.first_name,1,1) then 3.5
		when (length(a.first_name)=1 or length(b.first_name)=1) and substr(a.first_name,1,1)
			^= substr(b.first_name,1,1) then -5.5
		when (length(a.first_name)=2 or length(b.first_name)=2) and substr(a.first_name,1,2)
			= substr(b.first_name,1,2) then 7
		when (length(a.first_name)=2 or length(b.first_name)=2) and substr(a.first_name,1,2)
			^= substr(b.first_name,1,2) then -6.5
		/* Full weight for exact name matching */
		/* Asian first names get adjusted weight (using $fname_a instead of $fname_w) */	
		when a.first_name = b.first_name then %score(a.first_name,b.first_name,fmt=$fname_a.)
		/* near-full weighting for matching on nicknames, using nickname format lookup */
		when indexw(put(a.first_name,$nickname.),b.first_name) then 
			0.9 * %score(a.first_name,b.first_name,fmt=$fname_a.)
		/* reduced weight for approximate matches */
		when index(a.first_name,strip(b.first_name)) or index(b.first_name,strip(a.first_name)) 
			then 0.9*%score(a.first_name,b.first_name,fmt=$fname_a.)
		when %normlev(a.first_name,b.first_name)<=0.25 then (1-%normlev(a.first_name,b.first_name))
			* %score(a.first_name,b.first_name,fmt=$fname_a.)
		when %normlev(a.first_name,b.first_name)<=0.45 then 0
		/* first and last name reversed, or first and last name are the same for one case */
		when (%samef(a.first_name,b.last_name) & %samef(b.first_name,a.last_name)) |
			((b.first_name = b.last_name | a.first_name = a.last_name) & 
			(a.first_name = b.last_name | b.first_name = a.last_name)) then 4
		/* subtract points for disagreeing last name */
		else -8 end as score_fname,

	case  /* zero weight for missing names */
		when missing(a.last_name) or missing(b.last_name) then 0
		/* special handling for very short names, which mess with matching algorithms */
		when (length(a.last_name)=1 or length(b.last_name)=1) and substr(a.last_name,1,1)
			=substr(b.last_name,1,1) then 4.5
		when (length(a.last_name)=1 or length(b.last_name)=1) and substr(a.last_name,1,1)
			^=substr(b.last_name,1,1) then -5
		when (length(a.last_name)=2 or length(b.last_name)=2) and substr(a.last_name,1,2)
			=substr(b.last_name,1,2) then 10
		when (length(a.last_name)=2 or length(b.last_name)=2) and substr(a.last_name,1,2)
			^=substr(b.last_name,1,2) then -5
		/* full weight for exact name matching */
		when a.last_name = b.last_name then min(16,max(7,(%score(a.last_name,b.last_name,fmt=$lname_w.))))
		/* reduced weight for approximate matches */
		when index(a.last_name,strip(b.last_name)) or index(b.last_name,strip(a.last_name)) then 
			0.7*%score(a.last_name,b.last_name,fmt=$lname_w.)
		when %normlev(a.last_name,b.last_name)<=0.25 then (1-%normlev(a.last_name,b.last_name))
			*%score(a.last_name,b.last_name,fmt=$lname_w.)
		when %normlev(a.last_name,b.last_name)<=0.45 then 0
		/* first and last name reversed, or first and last name are the same for one case */
		when (%samef(a.first_name,b.last_name) & %samef(b.first_name,a.last_name)) |
			((b.first_name = b.last_name | a.first_name = a.last_name) & 
			(a.first_name = b.last_name | b.first_name = a.last_name)) then 6
		/* penalize females less for last name disagreement, which could be maiden vs married name */
		when a.sex = 'F' or b.sex = 'F' then 0
		else -10 end as score_lname,

	case /* zero weight for missing middle names */
		when missing(a.middle_name) | missing (b.middle_name) then 0
		/* full, non-initial matches */
		when length (a.middle_name) > 1 & length (b.middle_name) > 1 & a.middle_name = b.middle_name then 8
		/* One name is initial, matches with first letter of other name */
		when (length (a.middle_name) = 1 & a.middle_name = substr(b.middle_name,1,1)) |
		(length (b.middle_name) = 1 & b.middle_name = substr(a.middle_name,1,1)) then 6
		/* Two initials match */
		when length (a.middle_name) = 1 & length (b.middle_name) = 1 & a.middle_name = b.middle_name then 4
		/* Diagreement, and one is an initial */
		when length (a.middle_name) = 1 | length (b.middle_name) = 1 then -4.5
		/* reduced weight for approximate matches */
		when index(a.middle_name,strip(b.middle_name)) or index(b.middle_name,strip(a.middle_name)) 
			then 0.9*%score(a.middle_name,b.middle_name,fmt=$fname_a.)
		when %normlev(a.middle_name,b.middle_name)<=0.25 then (1-%normlev(a.middle_name,b.middle_name))
			* %score(a.middle_name,b.middle_name,fmt=$fname_a.)
		when %normlev(a.middle_name,b.middle_name)<=0.45 then 0
		/* Disagreement between full names */
		else -8 end as score_middle,

	case when a.date_of_birth = . or b.date_of_birth = . then 0
		when a.date_of_birth = b.date_of_birth then 14
		/* if day and month are reversed */
		when year(a.date_of_birth)=year(b.date_of_birth) & day(a.date_of_birth)
			= month(b.date_of_birth) & month(a.date_of_birth)=day(b.date_of_birth) then 11
		/* if year and day, or year and month, agree, but month or day, respectively, disagree */
		when (year(a.date_of_birth)=year(b.date_of_birth) & day(a.date_of_birth)=day(b.date_of_birth)) then 5
		when (year(a.date_of_birth)=year(b.date_of_birth) & month(a.date_of_birth)=month(b.date_of_birth)) then 5
		/* DOB is sometimes estimated to be Jan 1st for refugees without known DOBs - should not show up as a matched 
			DOB unless year is the same - this part will only get triggered if year is different */
		when (month(a.date_of_birth)=1 & month(b.date_of_birth)= 1 & day(a.date_of_birth)= 1 & day(b.date_of_birth)= 1)
			then -8
		/* month and day agree, year disagrees */
		when (month(a.date_of_birth)=month(b.date_of_birth) & day(a.date_of_birth)=day(b.date_of_birth)) then 5
		/* year agrees, month and day different */
		when year(a.date_of_birth)=year(b.date_of_birth) then -7
		/* Complete disagreement */
			else -11 end as score_dob,

	calculated score_ssn + calculated score_sex + calculated score_fname + calculated score_pris + 
		calculated score_lname + calculated score_dob + calculated score_race + calculated score_middle 
		+ calculated score_geo as score

	from	&var2. as a INNER JOIN &var2. as b
	on		a.id > b.id
	and		a.&var1. = b.&var1.
	where	calculated score >= 21
	and 	a.&var1. is not missing
	and		b.&var1. is not missing
%mend;


* Call the comparison macro above, using four different various values as seed variable to match before 
	doing comparisons with the rest of the variables;
proc sql;
	create table linked_pairs as
	%sql_blocking(ssn,setx11,1)
	UNION
	%sql_blocking(date_of_birth,setx11,1)
	UNION
	%sql_blocking(first_name,setx11,1)
	UNION
	%sql_blocking(last_name,setx11,1)
	;
	quit;


proc sort data=linked_pairs; by descending score; run;

* Make a chart to show linked pairs.  Should be a nice bell curve, with a long right-handed tail;
proc gchart data=linked_pairs;
	vbar score;
	run; 
	quit;

* Sort by last name, first name, dob - so as to be able to glance quickly at matched cases in the 
		almost a match dataset;
proc sort data=linked_pairs;
	by lname1 fname1 lname2 fname2 dob1 dob2;
	run;

* Create dataset of pairs that were almost a match (5/10/12 first HBV match = score between 23.5 and 30) for data cleaning purposes
	 (this dataset is used for finding type II errors - false negatives);
data look_carefully;
	set linked_pairs;
	where score >23.5 and score <30;
run;
proc sort data = look_carefully;
by score;
run;
data mainfldr.look_carefully_ChronicHBV;
set look_carefully;
run;
/* Code to allow for matches with score <30 to be counted as matches */

data callmatchtemp;
set linked_pairs;
if 23.5<=score<30 then do;
	* identify records where at least one value is missing/unknown in a linked pair;
	if race1='' or race1='Unknown' or race1='' or race2='Unknown' then missrace=1; else missrace=0;
	if sex1='' or sex1='U' or sex2='' or sex2='U' then misssex=1; else misssex=0;
	if prison1='' or prison2='' then missprison=1; else missprison=0;
	if ssn1=. or ssn2=. then missssn=1; else missssn=0;
	if zip1='' or zip2='' then misszip=1; else misszip=0;
	if lhj1='' or lhj2='' then misslhj=1; else misslhj=0;
	if dob1=. or dob2=. then missdob=1; else missdob=0;
	if fname1='' or fname2='' then missfname=1; else missfname=0;
	if m1='' or m2='' then missm=1; else missm=0;
	if lname1='' or lname2='' then misslname=1; else misslname=0;

	* Identify records where values are identical and not missing/unknown;
	if race1 = race2 and missrace=0 then samerace=1; else samerace=0;
	if sex1 = sex2 and misssex=0 then samesex=1; else samesex=0;
	if prison1 = prison2 and missprison=0 then sameprison=1; else sameprison=0;
	if ssn1 = ssn2 and missssn=0 then samessn=1; else samessn=0;
	if zip1 = zip2 and misszip=0 then samezip=1; else samezip=0;
	if lhj1 = lhj2 and misslhj=0 then samelhj=1; else samelhj=0;
	if dob1 = dob2 and missdob=0 then samedob=1; else samedob=0;
	if fname1 = fname2 and missfname=0 then samefname=1; else samefname=0;
	if m1 = m2 and missm=0 then samem=1; else samem=0;
	if lname1 = lname2 and misslname=0 then samelname=1; else samelname=0;

	*Identify where records have negative scores;
	format prob $45.;
	if .<score_fname<0 then prob='fname';
	if .<score_lname<0 then prob=catx(',',prob,'lname');
	if .<score_middle<0 then prob=catx(',',prob,'m');
	if .<score_ssn<0 then prob=catx(',',prob,'ssn');
	if .<score_dob<0 then prob=catx(',',prob,'dob');
	if .<score_geo<0 then prob=catx(',',prob,'geo');
	if .<score_race<0 then prob=catx(',',prob,'race');
	if .<score_sex<0 then prob=catx(',',prob,'sex');
	if .<score_pris<0 then prob=catx(',',prob,'prison');

	*define groups to look at for possible legitimate matches;
	format matchvars $45.;
	if samefname=1 and samelname=1 then do;
		matchvars='fname,lname';
		if samem=1 then matchvars=catx(',',matchvars,'m');
		if samessn=1 then matchvars=catx(',',matchvars,'ssn');
		if samedob=1 then matchvars=catx(',',matchvars,'dob');
		if samezip=1 then matchvars=catx(',',matchvars,'zip');
		if samelhj=1 then matchvars=catx(',',matchvars,'lhj');
		if samerace=1 then matchvars=catx(',',matchvars,'race');
		if samesex=1 then matchvars=catx(',',matchvars,'sex');
		if sameprison=1 then matchvars=catx(',',matchvars,'prison');
	end;
end;
if matchvars ne '';
run;

proc sort data=callmatchtemp;
by matchvars prob;
run;

proc univariate data=callmatchtemp noprint;
var score;
by matchvars prob;
output out=statsmatch p1=p1;
run;


*get the mean and median for first percentile on score and use 
that to select the scores to call a match when also have DOB;
proc sort data = statsmatch; by p1; run;
proc means data = statsmatch n mean median;
var p1;
run;

proc sort data=statsmatch;
by matchvars prob;
run;
proc sort data=callmatchtemp;
by matchvars prob;
run;

data callmatchtemp2;
merge callmatchtemp statsmatch;
by matchvars prob;
keep id1 id2 p1 samefname samelname prob matchvars;
run;

proc sort data=callmatchtemp2;
by id1 id2;
run;

proc sort data=linked_pairs;
by id1 id2;
run;

data callmatch;
merge linked_pairs callmatchtemp2;
by id1 id2;
if score >= 30 then match=1;
if 23.5<=score<30 and samefname=1 and samelname=1 then do;
	if index(matchvars,'ssn') then match=1;
	if index(matchvars,'dob') and length(strip(fname1))>1 and p1>24.7 then match=1;
end;
drop samefname samelname;
run;

proc sort data= callmatch;
by match;
run;

* Sort by last name, first name, dob - so as to be able to glance quickly at matched cases in the 
		almost a match dataset;
proc sort data=callmatch out=mainfldr.linked_pairs_AcuteHBV;
	by lname1 fname1 lname2 fname2 dob1 dob2;
	run;
