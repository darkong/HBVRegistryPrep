*========================================================================;
* Analyst: 		Adam Coutts
* Created: 		June 2, 2011
Last updated:	May 17, 2012 by Alexia Exarchos
* Purpose: 		Create link_id variable that matches matched pairs, and 
				find best values of various variables (name, dob, ssn, 
				diagnosis status, race, sex, etc) for each deduplicated 
				person
*========================================================================;

* Do a few data cleaning steps while in posession of specific matches pairs;

data setx12;
	set callmatch;

	* Cut-off values at a certain point - only want matched pairs where there is reasonable certainty that they
		are in fact the same person;
	where match = 1;

	* Where there is disagreement about sex, but the first name is heavily gendered and indicates
		one name over the other, create a flag variable;
/*	if (sex1 = 'F' & sex2 = 'M' & put(fname1,$name_sex.) = 'M') then flag_sex_name = id1;*/
/*	if (sex1 = 'M' & sex2 = 'F' & put(fname1,$name_sex.) = 'F') then flag_sex_name = id1;*/
/*	if (sex2 = 'F' & sex1 = 'M' & put(fname2,$name_sex.) = 'M') then flag_sex_name = id2;*/
/*	if (sex2 = 'M' & sex1 = 'F' & put(fname2,$name_sex.) = 'F') then flag_sex_name = id2;*/
	*Commented out per discussion with Rachel McLean;

	* Where it looks like first and last names may be reversed for one of two records, create a flag;
	if (%samef(fname1,lname2) & %samef (fname2,lname1)) then flag_name_rev = id1;

	* In situations where first and last name are the same for a case - compare against first and 
		last name in other case, and decide if one name is inaccurate;
	if (%samef(fname1,lname1) & %samef(fname1,fname2) 
		& not %samel (lname1,lname2) & length(lname1) > 2) then lnamedel = id1;
	if (%samef(fname1,lname1) & %samel(lname1,lname2) 
		& not %samef (fname1,fname2) & length(fname1) > 2) then fnamedel = id1;
	if (%samef(fname2,lname2) & %samef(fname1,fname2) 
		& not %samel (lname1,lname2) & length(lname2) > 2) then lnamedel = id2;
	if (%samef(fname2,lname2) & %samel(lname1,lname2) 
		& not %samef (fname1,fname2) & length(fname2) > 2) then fnamedel = id2;

	drop match;
	run;


* Create datasets that contain only the cases where paired matching indicates sex misatribution and name reversal;
* First - sex misatribution;
/*data sex_name (rename = (flag_sex_name = id));*/
/*	set mainfldr.setx12 (keep = flag_sex_name);*/
/*	where not missing (flag_sex_name);*/
/*	run;*/
/**/
/*proc sort data = sex_name nodupkey; by id; run;*/

* Names look to be reversed in one case;
data reversal (rename = (flag_name_rev = id));
	set setx12 (keep = flag_name_rev);
	where not missing (flag_name_rev);
	run;

proc sort data = reversal nodupkey; by id; run;

* First and last name are the same, and it looks like first name is the one that is in error;
data fnamedel (rename = (fnamedel = id));
	set setx12 (keep = fnamedel);
	where not missing (fnamedel);
	run;

* First and last name are the same, and it looks like last name is the one that is in error;
data lnamedel (rename = (lnamedel = id));
	set setx12 (keep = lnamedel);
	where not missing (lnamedel);
	run;


* This data step links together all records that are transitively related to each other
  	For an explanation as to the mechanism, see Glenn Wrights's paper, "Transitive Record 
	Linkage in SAS using Hash Objects", WUSS San Diego 2011;

data setx12a;
	set setx12 (keep = id1 id2);
	run;

data setx13 (keep = link_id old_id);
	length id1 id2 link_id old_id this_key dummy_key 8.;
	if _n_ = 1 then do;
		declare hash h1(dataset: "setx12a", multidata: 'yes');
		h1.definekey ("id1");
		h1.definedata(all: 'yes');
		h1.definedone();
		declare hash h2(dataset: "setx12a", multidata: 'yes');
		h2.definekey ("id2");
		h2.definedata(all: 'yes');
		h2.definedone();
		declare hash buffer();
		buffer.definekey('this_key');
		buffer.definedata('this_key');
		buffer.definedone();
		declare hiter loop('buffer');
		declare hash checklist();
		checklist.definekey('dummy_key');
		checklist.definedata('dummy_key');
		checklist.definedone();
		call missing(dummy_key);
	end;

set setx12a;
	if checklist.check(key: id1)=0 or checklist.check(key: id2)=0 then return;
	buffer.ref(key: id1, data: id1);
	buffer.ref(key: id2, data: id2);
	checklist.ref(key: id1, data: id1);
	checklist.ref(key: id2, data: id2);

	do until(buffer.num_items - starting_size = 0);
		starting_size = buffer.num_items;
		do while(loop.next()=0);
			if(h1.find(key: this_key)=0) then do until(h1.find_next(key: this_key)^=0);
			buffer.ref(key: id1, data: id1);
			buffer.ref(key: id2, data: id2);
				checklist.ref(key: id1, data: id1);
				checklist.ref(key: id2, data: id2);
			end;	
			if(h2.find(key: this_key)=0) then do until(h2.find_next(key: this_key)^=0);
				buffer.ref(key: id1, data: id1); 
				buffer.ref(key: id2, data: id2);     
				checklist.ref(key: id1, data: id1);
				checklist.ref(key: id2, data: id2);
			end;
		end;
	end;
	loop.first();
	link_id = this_key;
	do until(loop.next()^=0);
		old_id = this_key;
		output;
	end;
	buffer.clear();  
	run;


* Sort linked up dataset, main dataset, and first/last name deletion datasets for merging;
proc sort data=setx13 (rename = (old_id = id)) nodup; by id; run;
proc sort data=set101; by id; run;
proc sort data=fnamedel; by id; run;
proc sort data=lnamedel; by id; run;


* Merge those datasets, to create main dataset to find best values from;
data setx14;
	merge set101 setx13 /*sex_name (in = sex_name)*/ reversal (in = reversal)
	fnamedel (in = fnamedel) lnamedel (in = lnamedel);
	by id;
	patient_city = upcase(patient_city);
	account_city = upcase(account_city);
	* Set link_id (which in the code block above found multiple records per person) for cases where 
		only one record for the person;
	if link_id = . then link_id = id;
	
	* Delete first or last name if it is the same as the other (first or last) name, and comparison with
		another record indicates that that one is incorrect - this allows other names, in other matched pairs
		to be the ones taken in picking best name;
	if fnamedel then first_name = '';
	if lnamedel then last_name = '';

	* Reverse sex if that is indicated above;
/*	if sex_name then do;*/
/*		if sex = "F" then sex = "M";*/
/*		if sex = "M" then sex = "F";*/
/*		end;*/

	attrib firstdate length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib dxdate	 length = 8. format = MMDDYY10. informat = MMDDYY10.;

	* set date values to missing if they are before the date_of_birth;
	if episode_date_1<date_of_birth or year(episode_date_1) < 1984 then episode_date_1=.;
	if episode_date_2<date_of_birth or year(episode_date_2) < 1984 then episode_date_2=.;
	if episode_date_3<date_of_birth or year(episode_date_3) < 1984 then episode_date_3=.;
	if episode_date_4<date_of_birth or year(episode_date_4) < 1984 then episode_date_4=.;
	if collection_date<date_of_birth then collection_date=.;
	if result_date<date_of_birth then result_date=.;
	if date_of_diagnosis<date_of_birth then date_of_diagnosis=.;
	* Of various data values (date of data transmission, of sample collection, etc) - find the earliest, first date;
	firstdate = min (episode_date_1, episode_date_2, episode_date_3, episode_date_4, collection_date, result_date);
	* If "date of diagnosis" is less than ~three years before the new firstdate variable, check if it might be 
		the earliest date to affiliate with this episode;
	*if (firstdate - date_of_diagnosis < 1000) then firstdate = min (firstdate, date_of_diagnosis);
	dxdate=min(date_of_diagnosis, firstdate);

	if reversal then reversal_flag = 1;
run;

**DK CHANGE (calculate city variables);
* clean up LHJ variable, if possible;
* Hierarchy for assigning LHJ: 	1) LHJ assignment from prisonch macro = current value of local_health_juris
								2) LHJ that entered CMR data = current value of local_health_juris
								3) Patient address
									a) patient city
									b) patient zip code
								4) Account address
									a) account city
									b) account zip code
								5) current value of local_health_juris;

data cacitylhj;
set sashelp.zipcode;
where statecode='CA';
label city=' ';
city=upcase(city);
if city in ('BERKELEY','LONG BEACH','PASADENA') then lhj=upcase(city);
else lhj=upcase(countynm);
keep city lhj;
run;

proc sort data=cacitylhj nodupkey; by city; run;

data caziplhj;
set sashelp.zipcode;
where statecode='CA';
city=upcase(city);
label zip=' ';
label city = ' ';
if city in ('BERKELEY','LONG BEACH','PASADENA') then lhj=upcase(city);
else lhj=upcase(countynm);
keep zip lhj city;
run;

proc sort data=caziplhj; by zip; run;

proc sort data=setx14;
by patient_city;
run;


data ptcity;
merge setx14 (in=a) cacitylhj (rename=(city=patient_city));
by patient_city;
if a;
if prison in ('M','F','O') and local_health_juris ne '' then do;
	lhjassignmethod='PRISON';
	newlhj=local_health_juris;
end;
if lhjassignmethod='' and (index(data_source,'CalREDIE') or data_source in ('Morb','Rawvp', 'PHPP')) then do;
	lhjassignmethod='CMR';
	newlhj=local_health_juris;
end;
if lhjassignmethod='' and lhj ne '' then do;
	lhjassignmethod='PTCITY';
 	newlhj=lhj;
end;
if prison in ('M','F','O') and patient_city ne '' then do;
	cityassignmethod='PRISON';
	newpatient_city=patient_city;
end;
if cityassignmethod='' and patient_city ne '' and (index(data_source,'CalREDIE') or data_source in ('Morb','Rawvp', 'PHPP')) then do;
	cityassignmethod='CMR';
	newpatient_city=patient_city;
end;
drop lhj;
run;

proc sort data=ptcity;
by patient_zip_code;
run;

data ptzip;
merge ptcity (in=a) caziplhj (rename=(zip=patient_zip_code));
by patient_zip_code;
if a;
if lhjassignmethod='' and lhj ne '' then do;
	lhjassignmethod='PTZIP';
 	newlhj=lhj;
end;
if cityassignmethod = '' and city ne '' then do;
	cityassignmethod = 'PTZIP';
	newpatient_city = city;
end;
drop lhj city;
run;

proc sort data=ptzip;
by account_city;
run;

data actcity;
merge ptzip (in=a) cacitylhj (rename=(city=account_city));
by account_city;
if a;
if lhjassignmethod='' and lhj ne '' then do;
	lhjassignmethod='ACTCIT';
 	newlhj=lhj;
end;
if cityassignmethod = '' and account_city ne '' then do;
	cityassignmethod = 'ACTCIT'; 
	newpatient_city = account_city;
end;
drop lhj;
run;

proc sort data=actcity;
by account_zip_code;
run;

data setx14;
merge actcity (in=a) caziplhj (rename=(zip=account_zip_code));
by account_zip_code;
if a;
if lhjassignmethod='' and lhj ne '' then do;
	lhjassignmethod='ACTZIP';
 	newlhj=lhj;
end;
if local_health_juris ne '' and newlhj='' then do;
	lhjassignmethod='DEFAUL';
	newlhj=local_health_juris;
end;
if cityassignmethod = '' and city ne '' then do;
	cityassignmethod = 'ACTZIP';
	newpatient_city = city;
end;
if cityassignmethod = '' and newlhj in ('SAN FRANCISCO', 'BERKELEY', 'LONG BEACH', 'PASADENA') then do;
	cityassignmethod = 'DEFAUL';
	newpatient_city = newlhj;
end;
local_health_juris=newlhj;
patient_city = newpatient_city;
drop lhj newlhj city newpatient_city;
run;

* Dataset of people to reverse first name and last name;
data reversal2 (drop = reversal_flag);
	set setx14 (keep = reversal_flag link_id);
	if reversal_flag = 1;
	run;

proc sort data = reversal2; by link_id; run;
proc sort data = setx14; by link_id; run;

data setx14 (drop = tempname);
	merge setx14 reversal2 (in = reversal);
	by link_id;
	attrib tempname length = $22. format = $22. informat = $22.;

	* Reverse first and last name, where called for;
	if reversal & 
	(((put(last_name,$fname_c.) / put(last_name,$lname_c.)) /
	(put(first_name,$fname_c.) / put(first_name,$lname_c.))) > 1) then do;
		tempname = last_name;
		last_name = first_name;
		first_name = tempname;
		end;

	if (((put(last_name,$fname_c.) / put(last_name,$lname_c.)) /
	(put(first_name,$fname_c.) / put(first_name,$lname_c.))) > 10) then do;
		tempname = last_name;
		last_name = first_name;
		first_name = tempname;
		end;
run;

* Save group IDs of trangendered folks - to set all values of that group to T later (some data systems
	only allow M/F values - so, assume that if a person is identified as "T" in one system, T may be best
	choice no matter what other values day);
data transg (keep = link_id); 
	set setx14 (keep = link_id sex);
	where sex = 'T'; 
	run;


* Compute best sex value;
* First, get frequencies;
proc freq data = setx14 order = freq noprint;
	by link_id;
	where sex ^= 'U';
	tables sex / out = best_sex;
	run;

* What percent female;
data prcntfem (drop = sex);
	set best_sex (keep = sex link_id percent);
	where sex = 'F';
	rename percent = percentf;
	run;

* What percent male;
data prcntmale (drop = sex);
	set best_sex (keep = sex link_id percent);
	where sex = 'M';
	rename percent = percentm;
	run;

proc sort data=prcntmale; by link_id; run;
proc sort data=prcntfem; by link_id; run;

* Figure out which is more common;
data name_sex (keep = link_id sex);
	merge prcntmale prcntfem
		setx14 (keep = link_id first_name);
	by link_id;
	* Take more common sex;
	if percentm > 50 then sex = "M";
	else if percentf > 50 then sex = "F";
	* Take nothing for exact percentage ties;
	else delete; 
	run;

proc sort data=name_sex nodup; by link_id; run;


* Compute most common ssn value;
* First take frequency;
proc freq data = setx14 order = freq noprint;
	by link_id;
	where ssn ^= .;
	tables ssn / out = best_ssn;
	run;

* If do not have 100 percent match, then may be a problem - look into it;
data SSNprob (keep = link_id ssn);
	set best_ssn;
	where percent < 100;
	run;

* If there is less than 3/4th agreement among group cases, then consider data is not trustworthy;
data best_ssn (keep = link_id ssn);
	set best_ssn;
	if percent < 75 then delete;
	run;

* Delete ssns that are only off by one or two numbers from problem ssn set - only take differences
		of more than three characters;
data ssnprob;
	merge ssnprob (in = inprob)
		best_ssn (rename = (ssn = best_ssn));
	by link_id;
	if inprob;
	if best_ssn > 10000 & countc (put(abs(best_ssn-ssn),8.),"123456789") < 3 then delete;
	run;


* Compute most common dob value;
* First, break each dob into parts;
data dobparts;
	set setx14 (keep = date_of_birth link_id);
	ydob = year (date_of_birth);
	mdob = month (date_of_birth);
	ddob = day (date_of_birth);
	run;

proc sort data=dobparts; by link_id; run;


* Take the most common value of each of year, month, day;
%macro dobsort (var1);

proc freq data = dobparts order = freq noprint;
	by link_id;
	where &var1.dob ^= .;
	tables &var1.dob / out = best_&var1.dob;
	run;

proc sort data=best_&var1.dob ; by link_id descending percent; run;
proc sort data=best_&var1.dob (keep = link_id &var1.dob) nodupkey; by link_id; run;

%mend;

%dobsort(y);
%dobsort(m);
%dobsort(d);


* Put the parts back together to create best dob;
data best_dob (keep = link_id date_of_birth);
	attrib date_of_birth length = 8. format = MMDDYY10. informat = MMDDYY10.;
	merge best_ydob best_mdob best_ddob;
	by link_id;
	date_of_birth = mdy (mdob,ddob,ydob);
	run;

**DK CHANGE compute using a simpler algorithm to compute best race/ethnicity value;
* First, create frequencies;
proc freq data = setx14 order = freq noprint;
	by link_id;
	where race_ethnicity ^= 'Unknown';
	tables race_ethnicity / out = best_race;
	run;

proc sort data = best_race;
by link_id percent;
run;

data best_race;
set best_race;
by link_id;
id_comp = lag1(link_id);
comprace = lag1(race_ethnicity);
comppercent = lag1(percent);
if last.link_id then do;
	if link_id = id_comp and percent = comppercent then do;
	 	if race_ethnicity in ('White', 'Hispanic/Latino') and comprace in ('White', 'Hispanic/Latino') then race_ethnicity = 'Hispanic/Latino';
	 	else race_ethnicity = 'Unknown';
	end;
end;
if last.link_id;
keep link_id race_ethnicity;
run;


* Has the person ever been in prison;

data prison_ever;
	set setx14 (keep = prison link_id);
	if prison = '-' then delete;
		* Merge male and female state prison statuses into one value;
		else if prison in ("M","F") then prison_ever = "S";
	run; 

* Was the person in prison when first reported;
proc sort data=setx14 out=prison_firstrpt1;
by link_id firstdate;
run;

data prison_firstrpt;
set prison_firstrpt1;
by link_id firstdate;
if first.link_id;
format prison_firstrpt $1.;
informat prison_firstrpt $1.;
if prison in ('M','F') then prison_firstrpt='Y';
	else if prison in ('O','-') then prison_firstrpt='-';
keep link_id prison_firstrpt;
run;

* Best date of death information for person;
proc freq data = setx14 order = freq noprint;
	by link_id;
	where date_of_death ne .;
	tables date_of_death / out = best_dod;
	run;

* Cases where date of death is in conflict;
data dodprob;
	set best_dod;
	if percent ne 100;
	run;

* Take best date of death - should be 100 percent agreement in most cases - if is disagreement, more than 
		two thirds agreement indicates a good choice;
data best_dod (keep = link_id date_of_death);
	set best_dod;
	if percent > 70;
	run;

* Take date of first contact - any;
data date_set;
	set setx14 (keep = link_id firstdate);
	where firstdate ne .;
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=date_set; by link_id firstdate; run;

proc sort data=date_set nodupkey; by link_id; run;


* Take date of first contact - chronic;
data date_set_ch;
	set setx14 (keep = link_id firstdate dis);
	where firstdate ne . and dis ^= 'HEP-B';
	drop dis;
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=date_set_ch; by link_id firstdate; run;

proc sort data=date_set_ch nodupkey; by link_id; run;

data chronics;
set date_set_ch;
chronic = 1;
drop firstdate;
run;

* Take date of first contact - acute;
data date_set_ac;
	set setx14 (keep = link_id firstdate dis);
	where firstdate ne . and dis = 'HEP-B';
	drop dis;
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=date_set_ac; by link_id firstdate; run;

proc sort data=date_set_ac nodupkey; by link_id; run;

data acutes;
set date_set_ac;
acute = 1;
drop firstdate;
run;

* Take date of first diagnosis - any;
data dxdate_set;
	set setx14 (keep = link_id dxdate);
	where dxdate ne .;
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=dxdate_set; by link_id dxdate; run;
* Take first diagnosis date;
proc sort data=dxdate_set nodupkey; by link_id; run;


* Take date of first diagnosis - chronic;
data dxdate_set_ch;
	set setx14 (keep = link_id dxdate dis);
	where dxdate ne . and dis ^= 'HEP-B';
	drop dis;
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=dxdate_set_ch; by link_id dxdate; run;
* Take first diagnosis date;
proc sort data=dxdate_set_ch nodupkey; by link_id; run;


* Take local health jurisdiction at time of first contact;
data lhj_set;
	set setx14 (keep = link_id firstdate local_health_juris  rename = (local_health_juris = first_lhj));
	where firstdate ne . & first_lhj ne "";
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=lhj_set; by link_id firstdate; run;
* Delete all other dates per person, only take first date and link_id;
proc sort data=lhj_set (keep = link_id first_lhj) nodupkey; by link_id; run;


* Compute most common LHJ;
* First, create frequencies;
proc freq data = setx14 order = freq noprint;
	by link_id;
	where local_health_juris ^= '';
	tables local_health_juris / out = best_lhj;
	run;

proc sort data=best_lhj; by link_id percent; run;

data best_lhj;
set best_lhj;
by link_id;
id_comp = lag1(link_id);
percent_comp = lag1(percent);
if last.link_id then do;
	if link_id = id_comp and percent = percent_comp then local_health_juris = '';
end;
if last.link_id;
keep link_id local_health_juris;
run;

**DK CHANGE to get city stats;
* Take city at time of first contact;
data city_set;
	set setx14 (keep = link_id firstdate patient_city  rename = (patient_city = first_city));
	where firstdate ne . & first_city ne "";
	run;

* Sort, so that earliest date is first record for each person;
proc sort data=city_set; by link_id firstdate; run;
* Delete all other dates per person, only take first date and link_id;
proc sort data=city_set (keep = link_id first_city) nodupkey; by link_id; run;

* Compute most common city;
* First, create frequencies;
proc freq data = setx14 order = freq noprint;
	by link_id;
	where patient_city ^= '';
	tables patient_city/ out = best_city;
	run;

proc sort data=best_city; by link_id percent; run;

data best_city;
set best_city;
by link_id;
id_comp = lag1(link_id);
percent_comp = lag1(percent);
if last.link_id then do;
	if link_id = id_comp and percent = percent_comp then patient_city = '';
end;
if last.link_id;
keep link_id patient_city;
run;


* Count number of records per link_id (i.e. how many episodes per deduplicated person-level record);
proc freq data = setx14 order = freq noprint;
	tables link_id / out = num_link_id;
	run;




* Macro to calculate best first, middle, and last name for each person;

* First - macro to replace best choice for name (and its attendant date collected, commonality in the dataset as a whole, 
		and percent of records for this particular linked_id (ie unduplicated person));
%macro replace;
do; name_comp = &var1._name; comm_comp = common; perc_comp = percent; end
%mend;

* Main macro to identify best first, middle, last name for each person;
%macro cntname (var1,var2,var3,var4);

* First, calculate the frequency of each name for this person;
proc freq data = setx14 (keep = link_id &var1._name) order = freq noprint;
	by link_id;
	where &var1._name ^= '';
	tables &var1._name / out = best_name;
	run;

* For middle names, if there is disagreement between possibilities and one value matches the first letter of the 
		chosen best first name, then delete that value;
%if &var3 = m %then %do;
data best_name (keep = middle_name percent link_id);
	merge best_name best_fname;
	by link_id;
	if percent < 100 & middle_name = substr(first_name,1,1) then delete;
	run;
%end;


* Find how common each name is in the dataset at large;
data best_name;
	merge best_name (in = a) name_sex; * date_set;
	by link_id;
	if a;
	common = put(&var1._name,$&var2.name_c.);
	run;

* Sort so that the most name each person is most often called shows up first, with how common the name 
	is in the dataset at large used as a tiebreaker;
proc sort data=best_name; by link_id descending percent descending common; run;

data best_&var3.name (keep = link_id &var1._name);
	set best_name;
	by link_id;

	* Create some variables to retain, and compare one name value against another;
	attrib name_comp length = $20.;
	attrib perc_comp length = 8. format = 8.3;
	attrib comm_comp length = 8. format = 8.3;

	retain name_comp perc_comp comm_comp flag;

	* If its the first record for this person, set the comparison variables as this records values;
	if first.link_id then do;
		name_comp = &var1._name;
		perc_comp = percent;
		comm_comp = common;
		flag = 0;
		end;

	* If theres only one name used for the person, then no issue - just use that;
	if percent = 100 then do;
		* Set flag variable that indicates that variable has already been output;
		flag = 1;
		output;
		end;

	else do;

	&var1._name = strip(&var1._name);
	name_comp = strip(name_comp);

	* For non-first ("comparison") records, compare them against the first, to see if they are a better choice;
	if not first.link_id then do;
		* If the comparison value starts with the current best name choice and then is longer, take the comparison value;
		if length(&var1._name) > length(name_comp) then do;
			if (name_comp = (substr(&var1._name,1,length(name_comp)))) then %replace;
			end;
		* If the current best name choice is four or more char and is contained within the comparison value, then take
			the comparison value;
		if length(name_comp) > 3 & index (&var1._name,name_comp) > 0 then %replace;
		* If the current best name choice is short, and the comparison value is considerably longer, 
			then take the comparison value;
		if (length(name_comp) < 3 & (length(&var1._name)/length(name_comp)) > 2.4) then %replace;
		/* For women, if last names are flat-out different, then take the most recent name (that is the name the woman
				is going by now, and will be better for matching with future records);
		%if &var4. = 1 %then %do;
		else if sex = "F" & not %samel(&var1._name,name_comp) & firstdate > date_comp then %replace;
		%end;*/
		* If the current best choice is used for the person a lot more times than the next most common value, then go
			ahead and crown that one the winner;
		if perc_comp > (percent * 2.5) & flag ne 1 & length(name_comp) > 1 then do;
			&var1._name = name_comp;
			flag = 1;
			output;
			end;
		* If comparison value is a much more common spelling than the current best name choice, 
				take the comparison value;
		if (common / comm_comp > 20) & length(&var1._name) > 2 then %replace;
		* If percentage is tied, take the more common spelling;
		if percent = perc_comp & (common > comm_comp) & 
			((length(&var1._name) / length(name_comp)) > .5 | length(&var1._name) > 2) then %replace;
		end;
	
	end;

	* If its the last of the possible name variables, then output the best name choice;
	if last.link_id & flag ne 1 then do;
		&var1._name = name_comp;
		output;
		end;

	run;

proc sort data = best_&var3.name nodup; by link_id; run;


* Find people with the completely different names but still linked up as one case, to examine as part of QC;
data &var3.nameprob (keep = link_id);
	merge best_&var3.name (rename = (&var1._name = best_name)) setx14 (keep = link_id &var1._name sex);
	by link_id;

	if missing(best_name) | missing (&var1._name) then delete;

	%if &var4. = 1 %then %do;
	if %samel(best_name,&var1._name) then delete;
	* Delete female last name cases - names may be totally different because of maiden/married name;
	if sex = "F" then delete;
	%end;

	%if &var4. = 0 %then %do;
	if %samef(best_name,&var1._name) then delete;
  	%end;

	run;

proc sort data = &var3.nameprob nodup; by link_id; run;

%mend;

%cntname (first,f,f,0);
%cntname (middle,f,m,0);
%cntname (last,l,l,1);


data look_first (drop = link_id);
	merge best_fname (rename = (first_name = best_fname)) setx14 (keep = link_id first_name);
	by link_id;
	if not missing (first_name) & not %samef(best_fname,first_name);
	if length(first_name) = 1 or length(best_fname) = 1 then delete; 
	if length(best_fname) > length(first_name) then do;
		if substr(best_fname,1,length(strip(first_name))) = strip(first_name) then delete;
		end;
	run;

data look_last (drop = link_id);
	merge best_lname (rename = (last_name = best_lname)) setx14 (keep = link_id last_name);
	by link_id;
	if not missing (last_name) & not %samef(best_lname,last_name); 
	if length(last_name) = 1 or length(best_lname) = 1 then delete; 
	if length(best_lname) > length(last_name) then do;
		if substr(best_lname,1,length(strip(last_name))) = strip(last_name) then delete;
		end;
	run;

proc sort nodup data=look_first; by best_fname; run;
proc sort nodup data=look_last; by best_lname; run;

data look_last look_last2;
	set look_last;
	if substr(last_name,1,2) = substr(best_lname,1,2) then output look_last;
		else output look_last2;
	run;

data look_first look_first2;
	set look_first;
	if substr(first_name,1,2) = substr(best_fname,1,2) then output look_first;
		else output look_first2;
	run;


* In situations where there is no middle name information, and there are several possible conflicting values for 
	first name, save the first name that is an initial, or less common, as the middle name;
* First - find cases where there is no middle name information, and first name conflicts exist;
data new_middle (keep = link_id first_name rename = (first_name = middle_name));
	merge best_mname best_fname (rename = (first_name = best_fname)) setx14 (keep = link_id first_name);
	by link_id;
	* Only take cases where (1) middle name is missing or it is a initial subtring (usually, first initial) 
		of the alternate first name, (2) there is a value for first name that is clearly different (not a 
		nickname, not linguistically similar, not a intial substring) than the first name which was taken);
	if (missing(middle_name) | substr(first_name,1,length(strip(middle_name))) = strip(middle_name))
		& not missing (first_name) & not %samef(best_fname,first_name) 
		& not (substr(best_fname,1,length(strip(first_name))) = strip(first_name));
	run;

proc sort nodup data=new_middle; by link_id; run;

* Only take cases with one new middle name (ie one alternative first name);
data new_middle;
	set new_middle;
	by link_id;
	if first.link_id & last.link_id;
	run;

* Create dataset with valid middle names;
data best_mname;
	set best_mname;
	if not missing(middle_name);
	run;

* Combine traditionally found middle names and new middle names;
data best_mname;
	set best_mname new_middle;
	run;

proc sort data=best_mname; by link_id; run;

* Sort all datasets for merging together on link_id;
proc sort data=name_sex nodup; by link_id; run;
proc sort data=best_ssn; by link_id; run;
proc sort data=best_race ; by link_id; run;
proc sort data=best_dob; by link_id; run;
proc sort data=best_dod; by link_id; run;
proc sort data=transg nodupkey; by link_id; run;
proc sort data=num_link_id (keep = link_id count rename = (count = records_per)); by link_id; run;
proc sort data=chronics; by link_id; run;
proc sort data=acutes; by link_id; run;
proc sort data=date_set; by link_id; run;
proc sort data=date_set_ac; by link_id; run;
proc sort data=date_set_ch; by link_id; run;
proc sort data=dxdate_set; by link_id; run;
proc sort data=dxdate_set_ch; by link_id; run;
proc sort data=best_lhj; by link_id; run;
proc sort data = lhj_set; by link_id; run;
proc sort data = city_set; by link_id; run;
proc sort data = best_city; by link_id; run;
proc sort data=prison_ever; by link_id descending prison_ever; run;
* First prison data sort so that S (state prison history) is over O (other prison/jail history), and 
	so O is over blanks;
proc sort data=prison_firstrpt; by link_id; run;
* Then delete so as to only take the highest ranking record;
proc sort data=prison_ever nodupkey; by link_id; run;



* Merge all best values together with main set (setx14 - with values that are being replaced/standardized/optomized
	deleted);
**DK CHANGE (CREATE BEST VARIABLES, ADD IN CITY DATASETS, DON'T REMOVE SETX14 VARIABLES);
data setx15;
	merge setx14 (drop = prison firstdate dxdate)
	    name_sex (rename = (sex = best_sex))
		best_ssn (rename = (ssn = best_ssn))
		best_race (rename = (race_ethnicity = best_race_ethnicity))
		best_dob (rename = (date_of_birth = best_date_of_birth))
		best_dod (rename = (date_of_death = best_date_of_death))
		prison_ever
		prison_firstrpt
		transg (in = trans)
		acutes
		chronics
	    date_set
	    date_set_ch (rename = (firstdate = firstdate_ch))
		date_set_ac (rename = (firstdate = firstdate_ac))
	    dxdate_set
	    dxdate_set_ch (rename = (dxdate = dxdate_ch))
		lhj_set
		best_lhj (rename = (local_health_juris = common_lhj))
		city_set
		best_city (rename = (patient_city = common_city))
		best_fname (rename = (first_name = best_first_name))
		best_lname (rename = (last_name = best_last_name))
		best_mname (rename = (middle_name = best_middle_name))
		num_link_id; 
		by link_id;
/*	if strip(sex) in ('','U') then sex = put(first_name,$name_sex.);*/
	if sex = '' then sex = 'U';
	if trans then sex = 'T';
	if missing(prison_ever) then prison_ever = '-';
	if missing(prison_firstrpt) then prison_firstrpt = '-';
	if race_ethnicity ='' then race_ethnicity = 'Unknown';

	attrib firstyear length = 8. format = 8. informat = 8.;
	attrib dxyear length = 8. format = 8. informat = 8.;
	attrib age length = 8. format = z8.1 informat = 8.1;
	attrib agedx length = 8. format = z8.1 informat = 8.1;
	firstyear = year (firstdate);
	dxyear = year (dxdate);
	age =  (firstdate - best_date_of_birth) / 365.25;
	agedx = (dxdate - best_date_of_birth) / 365.25;
	run;


* Sort problem cases by link_id, for merging;
**DK CHANGE (REMOVE LHJPROB);

proc sort data=ssnprob nodupkey; by link_id; run;
proc sort data=fnameprob nodupkey; by link_id; run;
proc sort data=mnameprob nodupkey; by link_id; run;
proc sort data=lnameprob nodupkey; by link_id; run;
proc sort data=dodprob nodupkey; by link_id; run;


* Merge all "problem" datasets - create text variable that identifies what the specific incongruence is;
**DK CHANGE (REMOVE LHJPROB RACEPROB);
data problems;
	informat prob $30.;
	merge ssnprob (in=b) fnameprob (in=c) mnameprob (in = d) lnameprob (in = e) dodprob (in = f);
	by link_id;
	if b then prob = "ssn";
	if c then prob = catx(", ",prob,"first name");
	if d then prob = catx(", ",prob,"mid init");
	if e then prob = catx(", ",prob,"last name");
	if f then prob = catx(", ",prob,"date of death");
if substr(prob,1,2) = ", " then prob = substr(prob,3,(length(prob)-1));
	run;

* Create dataset of "problems" to examine as part of QA process (this dataset is used for finding type I errors);
**DK CHANGE (NO NEED TO RENAME SETX15 VARIABLES);
data problems2;
	merge setx14 (keep = link_id id first_name last_name middle_name ssn sex race_ethnicity date_of_birth 
	date_of_death patient_zip_code race_ethnicity account_zip_code local_health_juris prison data_source)
		problems (in = a)
		setx15 (keep = link_id best_first_name best_last_name best_middle_name best_date_of_birth);
*	merge mainfldr.main01
		&var1. (in = a);
	by link_id;
	if prob = "last name" & sex = "F" then delete;
	if a;
	run;


	




