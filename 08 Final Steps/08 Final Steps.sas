*=====================================================================;
* Analyst : Adam Coutts
* Created : June 14, 2011
* Las Updated: May 10, 2012 by Alexia Exarchos
* Purpose : THIS PROGRAM SHOULD ONLY BE RUN IF OTHER PROGRAMS RUN
			SUCCESSFULLY AND ERROR-FREE
			It breaks final, best-choice-demographic dataset (setx15 
			from 07 Deduplicating program) into final two datasets 
			(person-level and episode-level, and then generates 
			descriptive statistics;
*=====================================================================;

* Back up previous mainfldr.main01 and mainfldr.main02 datasets to archive folder prior to creating new files;
data archive.main01_&sysdate9;
set mainfldr.main01;
run;

data archive.main02_&sysdate9;
set mainfldr.main02;
run;

* Split data so as to create two final datasets - main01 (stem, unduplicated, person level, lower numbers) and 
	main02 (leaf, multiple records per person, episode level, higher numbers);

data main01 (keep = link_id first_name last_name middle_name ssn sex race_ethnicity date_of_birth 
		date_of_death prison_ever prison_firstrpt records_per firstdate dxdate main_diagnosis overall_diagnosis first_lhj common_lhj age agedx firstyear dxyear)
	main02 (keep = link_id id occupation date_of_onset date_of_diagnosis mmwr_year patient_address 
		patient_city patient_zip_code census_tract account_name account_address account_city account_zip_code
		local_health_juris laboratory diagnosis ordering_doctor episode_date_1 episode_date_2 episode_date_3
		episode_date_4 collection_date result_date firstdate reporter_type prison patient_id data_source result_comment 
		result_name result_value test_name order_name diagnosis2);
	set setx15;
	run;


* Templates - so as to properly order variables in dataset;

data template01;
	attrib link_id length = 8. format = 8. informat = 8.;
	attrib first_name length = $20. format = $20. informat = $20.;
	attrib last_name length = $35. format = $35. informat = $35.;
	attrib middle_name length = $20. format = $20. informat = $20.;
	attrib ssn length = 8. format = 9. informat = 9.;
	attrib sex length = $1. format = $1. informat = $1.;
	attrib race_ethnicity length = $35. format = $35. informat = $35.;
	attrib date_of_birth length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib date_of_death length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib firstdate length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib dxdate length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib prison_ever length = $1. format = $1. informat = $1.;
	attrib prison_firstrpt length = $1. format = $1. informat = $1.;
	attrib main_diagnosis length = 8. format = 1. informat = 1.;
	attrib overall_diagnosis length = 8. format = 1. informat = 1.;
	attrib first_lhj length = $20. format = $20. informat = $20.;
	attrib records_per length = 8. format = 4. informat = 4.;
	run;

data main01;
	set template01 (in = a) main01;
	if a then delete;
	race_ethnicity=strip(race_ethnicity);
	run;


/*data dedup01;*/
/*	set main01 (keep = link_id race_ethnicity sex prison_ever ssn date_of_birth first_name */
/*		middle_name last_name common_lhj first_lhj rename = (link_id = id prison_ever = prison));*/
/*	* to test code uncomment out the below code;*/
/*	if substr(last_name,1,1) = "M";*/
/*	run;*/
/**/
/*proc sql;*/
/*	create table linked_pairs2 as*/
/*	%sql_blocking(ssn,dedup01,2)*/
/*	UNION*/
/*	%sql_blocking(date_of_birth,dedup01,2)*/
/*	UNION*/
/*	%sql_blocking(first_name,dedup01,2)*/
/*	UNION*/
/*	%sql_blocking(last_name,dedup01,2)*/
/*	;*/
/*	quit;*/



data template02;
	attrib link_id length = 8. format = 8. informat = 8.;
	attrib id length = 8. format = 8. informat = 8.;
	attrib data_source length = $30. format = $30. informat = $30.;	
	attrib occupation length = $25. format = $25. informat = $25.;
	attrib date_of_onset length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib date_of_diagnosis length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib mmwr_year length = 8. format = 6. informat = 6.; 
	attrib date_of_death length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib patient_address length = $50. format = $50. informat = $50.;
	attrib patient_city length = $25. format = $25. informat = $25.;
	attrib patient_zip_code length = 8. format = 8. informat = 8.;
	attrib census_tract length = $10. format = $10. informat = $10.;
	attrib account_name length = $40. format = $40. informat = $40.;
	attrib account_address length = $80. format = $80. informat = $80.;
	attrib account_city length = $24. format = $24. informat = $24.;
	attrib account_zip_code length = 8. format = 8. informat = 8.;
	attrib local_health_juris length = $20. format = $20. informat = $20.;
	attrib laboratory length = $50. format = $50. informat = $50.;
	attrib diagnosis length = $20. format = $20. informat = $20.;
	attrib diagnosis2 length = 8. format = 1. informat = 1.;
	attrib ordering_doctor length = $30. format = $30. informat = $30.;
	attrib episode_date_1 length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib episode_date_2 length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib episode_date_3 length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib episode_date_4 length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib collection_date length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib result_date length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib firstdate length = 8. format = MMDDYY10. informat = MMDDYY10.;
	attrib reporter_type length = $9. format = $9. informat = $9.;
	attrib prison length = $1. format = $1. informat = $1.;
	attrib test_name length = $45. format = $45. informat = $45.;
	attrib result_name length = $36. format = $36. informat = $36.;
	attrib order_name length = $41. format = $41. informat = $41.;
	attrib result_value length = $20. format = $20. informat = $20.;
	attrib result_comment length = $200. format = $200. informat = $200.;
	attrib patient_id length = $22. format = $22. informat = $22.;
	run;

data main02 mainfldr.main02;
	set template02 (in = a) main02;
	if a then delete;
	run;


* Deduplicate person-level dataset - each link_id should have the same demographic information
		(last name, dob, ssn, sex), so eliminate cases who have the same values - should work the
		same as just taking one record per link_id;
proc sort data=main01 nodupkey; 
	by link_id last_name first_name date_of_birth ssn sex; 
	run;

* Look for cases where deduplicating may not have worked - ie where there are more than one link_id;
data duplink1;
	set main01 (keep = link_id);
	run; 

proc sort data=duplink1 nodupkey; by link_id; run;

data mainfldr.main01;
set main01;
run;

* Run descriptive statistics;

* Group various asian/PIs and other/unknown for race_ethnicity variable before freqs;
proc freq data=main01;
	tables sex race_ethnicity prison_ever age firstyear dxyear first_lhj;
	format race_ethnicity $raceamal. age agechart.;
	run;

proc freq data=main01;
	tables firstyear ;
	where overall_diagnosis in (1,2);
	run;

* Create year of birth varoable, and run stats on that (with the yobs grouped using yobchart format);
data yob (drop = date_of_birth);
	set main01 (keep = race_ethnicity date_of_birth);
	attrib year_of_birth length = 8. format = 8. informat = 8.;
	yob = year (date_of_birth);	
	run;

proc freq data=yob;
	tables yob yob*race_ethnicity;
	format race_ethnicity $raceamal. yob yobchart.;
	run;

* Look at episode-level dataset - number of prison-based episodes per LHJ;
proc freq data = main02;
	tables prison*local_health_juris;
	run;
proc tabulate data = main02;
	class prison local_health_juris;
	table prison, local_health_juris;
	run;

