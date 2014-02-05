*=====================================================================;
* Analyst: 		Adam Coutts
* Created: 		March 27, 2011
* Last updated:	May 29, 2012 by Alexia Exarchos
* Purpose: 		Prepare data from various datasets for merging - 
					rename data, recode, etc. - then save to permanent 
					datasets
*=====================================================================;


* Create empty template dataset, so as to standardize capitalization of variable names, variable order in 
		the dataset, and variable lengths - this template dataset will set the standard for the 
		merged dataset for all of those attributes because it will be the first one merged in;

data set000;
	attrib first_name length = $20. format = $20. informat = $20.;
	attrib last_name length = $35. format = $35. informat = $35.;
	attrib middle_name length = $20. format = $20. informat = $20.;
	attrib ssn length = 8. format = 9. informat = 9.;
	attrib sex length = $1. format = $1. informat = $1.;
	attrib race_ethnicity length = $35. format = $35. informat = $35.;
	attrib occupation length = $25. format = $25. informat = $25.;
	attrib date_of_birth length = 8. format = MMDDYY10. informat = MMDDYY10.;
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
	attrib reporter_type length = $9. format = $9. informat = $9.;
	attrib prison length = $1. format = $1. informat = $1.;
	attrib test_name length = $45. format = $45. informat = $45.;
	attrib result_name length = $36. format = $36. informat = $36.;
	attrib order_name length = $41. format = $41. informat = $41.;
	attrib result_value length = $20. format = $20. informat = $20.;
	attrib result_comment length = $200. format = $200. informat = $200.;
	attrib patient_id length = $22. format = $22. informat = $22.;
	attrib id length = 8. format = 8. informat =8.;
	attrib data_source length = $30. format = $30. informat = $30.;	
	run;

*Revise Morbfile dataset - merge SSNs, make SSN numeric, make ID character to match template 'set000' formats, merge 
occupation variable from three diferent datasets on morbfile;

data HBVprep;
set morbfile;

SSN1 = SSN;

occupation2 = occupation;
if occupation = ' ' then occupation2 = Xocc;

drop ssn occupation xocc;

if LHD = 'SAN DIEGO' and RE = 'AA' then race = ' ';
if LHD = 'SAN DIEGO' and RE = 'AA' then ethnicity = ' ';
run;
data HBVprep1;
	set HBVprep;

* Create size and type of new variables that will be calculated;
	format episode_date_1 mmddyy10. episode_date_2 mmddyy10. episode_date_3 mmddyy10. episode_date_4 mmddyy10. date_of_onset mmddyy10.
		date_of_diagnosis mmddyy10. date_of_death mmddyy10. date_of_birth mmddyy10.;
	informat patient_id $20. race $35. data_source $22. ssn 9. 
		account_address $80. account_city $22. account_zip_code patient_zip_code 8. 
		middle_name $20. occupation2 $25. local_health_juris $20. ordering_doctor $30.
		episode_date_1 mmddyy10. episode_date_2 mmddyy10. episode_date_3 mmddyy10. episode_date_4 mmddyy10. date_of_onset mmddyy10.
		date_of_diagnosis mmddyy10. date_of_death mmddyy10. date_of_birth mmddyy10.;

* Convert from numeric to character;
	patient_id = put(ID,8.);

* Some situations where zip code information ends up in state variable;
	if (notdigit(state) > 6 | notdigit(state) = 0) & length(state) = 5 
		& missing(Zip) then Zip = state;

* If middle name not missing and first name is, make middle name first name;
if missing (FNA) & not missing (MNA) then do;
	FNA = MNA;
	MNA = '';
	end;
middle_name=MNA;

* Abreviate sex variable from full word down to one letter, so as to make 
		compatible with other datasets;
sex = substr(sex,1,1);

* Calculate race_ethnicity variable from seperate CalREDIE race and ethnicity variables;
* Calculate race_ethnicity variable from seperate CalREADIE race and ethnicity variables;
	if index(race, "Black") then race_ethnicity = 'Black/African-American';
	if race = 'White' then race_ethnicity = 'White';
	if race = "American Indian/Alaska Native" then race_ethnicity = "Native American/Alaskan Native";
	if index(race,"Asian - ") then race_ethnicity = "Asian/Pacific Islander";
	if index(race,"Pacific Islander") then race_ethnicity = "Asian/Pacific Islander";
	
	if race = "Multiple Races" then race_ethnicity = "Multirace";
	if ethnicity = "Hispanic/Latino" then race_ethnicity = "Hispanic/Latino";
	else if race_ethnicity = ' ' then race_ethnicity = race;
	if (ethnicity = "Unknown" & race_ethnicity ='') then race_ethnicity = "Unknown";


* Standardize case;
local_health_juris = upcase(LHD);
Occupation2 = upcase(Occupation2);

* Ordering doctor and account name calculated from several variables;
ordering_doctor = upcase(RSName);
	if missing(strip(ordering_doctor)) then ordering_doctor = Submitter;
if missing (rslocation) then rslocation = ordering_doctor; 
account_address = upcase(RSaddress);
if missing(account_address) & anydigit(substr(rslocation,1,1)) = 1 
	then account_address = upcase(rslocation);
account_city = upcase(RSCITY);
account_zip_code = put(substr(RSZipcode,1,5),8.);

* Clean ssn information - make unknown values blank, remove blanks and dashes, translate into numeric;
if ssn1 in ("000-00-0000","UNK","000000001","999999999","000-00-0001","999-99-9999") then ssn1 = '';
if ssn1 notin ('','.') then ssn = put(compress (ssn1,"0123456789",'k'),9.);
	else ssn = .;		

* Translate from character to numeric - take only first five chars of zip, and only if all five are numbers;
if (notdigit(zip) > 5 | notdigit(strip(zip)) = 0) then 
	patient_zip_code = put (substr(zip,1,5),8.);

* Rename variables to standardize them with other datasets;
	rename
		LNA = last_name 
		FNA = first_name
		ADDR = patient_address
		CITY = patient_city
		REPORT = data_source
		DOB = date_of_birth
		DON = date_of_onset
		DDX = date_of_diagnosis
		DTH = date_of_death
		DAT = episode_date_1
		TD = episode_date_2
		DUP = episode_date_3;

* Select CHRONIC HBV cases;
if dis = 'HEP-B-CR';

* Drop unnneeded variables;
drop age aptno ctract cellphone CENSUSBLOCK CLUSTERID CMRNUMBER CntyOfResid 
	DISEASE DiseaseGrp DtAdmit DtArrival DtClosed DtDischarge 
	DtLabRpt DtSent EDD ethnicity FinalDispo HOMEPHONE 
	HOSPITAL IndexCase INPATIENT LATITUDE LONGITUDE 
	MRN namesuffix OccLocation OccSettingType OccSettingSpec
	OutbreakNum OUTBREAKTYPE pregnant PStatus PtDiedIllness PtHospitalized race  
	RPTBy RSNAME ssn1 STATE Submitter TStatus Zip id;

run;


* Process SF city/county data;

data set004;
	set sfftp;

* Create size and type of new variables that will be calculated;
	informat data_source $22. race_ethnicity $35. local_health_juris $20. patient_city $25.
		account_name $40. account_address $80. account_city $22. account_zip_code 8.  occupation $25.;
	* reason_testing $110. risk_factors $250.;

* Identify data source;
	data_source = "SF eFTP";

* Recode multiple race and ethnicity variables down into one variable;
	if race_amind = '1' then race_ethnicity = 'Native American/Alaskan Native';  
	if race_asian = '1' then race_ethnicity = 'Asian/Pacific Islander';
	if race_pacisland = '1' then race_ethnicity = 'Asian/Pacific Islander';
	if race_black = '1' then race_ethnicity = 'Black/African-American';  
	if race_white = '1' then race_ethnicity = 'White';  
	if race_other = '1' then race_ethnicity = 'Other';  
	if ethnic_grp = '1' then race_ethnicity = 'Hispanic/Latino';
	if race_ethnicity = '' then race_ethnicity = 'Unknown';


	local_health_juris = "SAN FRANCISCO";
	if cnty_res = "San Francisco" then patient_city = "SAN FRANCISCO";
	
* Rename variables to standardize them with other datasets;
	rename
		birth_dt = date_of_birth
		local_id = patient_id 
		rep_dt = episode_date_1
		birth_dt = date_of_birth
		fname = first_name
		lname = last_name
		;

* Drop unneeded variables;
	drop race_amind race_asian race_black race_white race_other ethnic_grp race_pacisland 
		NETSS_ID NETSS_YR event birth_country reastest_acutehep specoth_birthcountry reastest_acutehep 
		reastest_livenzymes reastest_riskfact reastest_donor reastest_norisk reastest_followup reastest_prenatal 
		reastest_other reastest_unknown specoth_reastest specoth_race cnty_res; 

run;
