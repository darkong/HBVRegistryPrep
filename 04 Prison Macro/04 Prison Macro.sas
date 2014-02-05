*===========================================================================;
* Analyst: 		Adam Coutts
* Created: 		May 4, 2011
* Last updated:	February 9, 2012 by Erin Murray	
* Purpose: 		A macro, used twice in 05 Merging.sas program, that looks
				 for a sign that a person is in a prison (mostly CA state
				 prisons, a few large local jails as well) and fills in 
				 additional information for that prison/jail
				 Account name, account address, and patient address have
				 already been mostly standardized with $prison format - so 
				 ususally do not need to look for variation of addresses;
*===========================================================================;


%macro prisonch;

if (account_address in ("ATASCADERO STATE HOSPITAL", "10333 EL CAMINO REAL PO BOX 7001") |
	patient_address in ("ATASCADERO STATE HOSPITAL", "10333 EL CAMINO REAL PO BOX 7001") |
	(patient_address = "PO BOX 7001" & patient_city = "ATASCADERO") |
	account_name = "ATASCADERO STATE HOSPITAL") then do;

	if strip(account_name) = '' then account_name = "ATASCADERO STATE HOSPITAL";
	if strip(account_address) = '' then account_address = "10333 EL CAMINO REAL PO BOX 7001";
	if strip(account_city) = '' then account_city = "ATASCADERO";
	if account_zip_code = . then account_zip_code = 93423;
	if strip(patient_address) in ('', "PO BOX 7001") then 
		patient_address = "10333 EL CAMINO REAL PO BOX 7001";
	if strip(patient_city) = '' then patient_city = "ATASCADERO";
	if patient_zip_code = . then patient_zip_code = 93423;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris="SAN LUIS OBISPO";
	local_health_juris="SAN LUIS OBISPO";
	end;


if (account_address = "AVENAL STATE PRISON" | patient_address = "AVENAL STATE PRISON" | 
	(substr (account_address,1,6) = "1 KING" & account_zip_code = 93204) | 
	(substr (patient_address,1,6) = "1 KING" & patient_zip_code = 93204) |
	account_name = "AVENAL STATE PRISON" | index (ordering_doctor,"(ASP)") > 0) then do;

	if strip(account_name) = '' then account_name = "AVENAL STATE PRISON";
	if strip(account_address) = ''  | substr (account_address,1,6) = "1 KING"
		then account_address = "1 KINGS WAY, PO BOX 8";
	if strip(account_city) = '' then account_city = "AVENAL";
	if account_zip_code = . then account_zip_code = 93204;
	if strip(patient_address) = '' | substr (patient_address,1,6) = "1 KING"
		then patient_address = "1 KINGS WAY, PO BOX 8";
	if strip(patient_city) = '' then patient_city = "AVENAL";
	if patient_zip_code = . then patient_zip_code = 93204;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KINGS";
	local_health_juris = "KINGS";
	end;
if account_address='AVENAL' and data_source='Foundation Lab' then do;
	account_name = "AVENAL STATE PRISON";
	account_address = "1 KINGS WAY, PO BOX 8";
	account_city = "AVENAL";
	account_zip_code = 93204;
	if strip(patient_address) = '' | substr (patient_address,1,6) = "1 KING"
		then patient_address = "1 KINGS WAY, PO BOX 8";
	if strip(patient_city) = '' then patient_city = "AVENAL";
	if patient_zip_code = . then patient_zip_code = 93204;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KINGS";
	local_health_juris = "KINGS";
	end;

if (account_address in ("CA CORRECTION CENTER","711-045 CENTER ROAD PO BOX 790") |
	(patient_address = "PO BOX 790" & patient_city = "SUSANVILLE") |
	(account_address = "PO BOX 790" & account_city = "SUSANVILLE") |
	patient_address in ("CA CORRECTION CENTER","711-045 CENTER ROAD PO BOX 790") | 
	account_name = "CA CORRECTION CENTER") then do;

	if strip(account_name) = ''  then account_name = "CA CORRECTION CENTER";
	if strip(account_address) in ("PO BOX 790", '')  then account_address = "711-045 CENTER ROAD PO BOX 790";
	if strip(account_city) = ''  then account_city = "SUSANVILLE";
	if account_zip_code = . then account_zip_code = 96127;
	if strip(patient_address) in ("PO BOX 790", '')  then patient_address = "711-045 CENTER ROAD PO BOX 790";
	if strip(patient_city) = ''  then patient_city = "SUSANVILLE";
	if patient_zip_code = . then patient_zip_code = 96127;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "LASSEN";
	local_health_juris = "LASSEN";
	end;


if (account_address = "CA CORRECTION INSTITUTE" | index (account_address,'24900 HIGH') = 1 |
	patient_address = "CA CORRECTION INSTITUTE" | index (patient_address,'24900 HIGH') = 1 |
	account_name = "CA CORRECTION INSTITUTE" | index (ordering_doctor,"CCI") > 0) then do;

	if strip(account_name) = '' then account_name = "CA CORRECTION INSTITUTE";
	if (strip(account_address) = ''  | index (account_address,'24900 HIGH') = 1) 
		then account_address = "24900 HIGHWAY 202";
	if strip(account_city) = '' then account_city = "TEHACHAPI";
	if account_zip_code = . then account_zip_code = 93561;
	if (strip(patient_address) = ''  | index (patient_address,'24900 HIGH') = 1)
		then patient_address ="24900 HIGHWAY 202";
	if strip(patient_city) = '' then patient_city = "TEHACHAPI";
	if patient_zip_code = . then patient_zip_code = 93561;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;
if account_address='CAL CORRECTION' and data_source='Foundation Lab' then do;
	account_name = "CA CORRECTION INSTITUTE";
	account_address = "24900 HIGHWAY 202";
	account_city = "TEHACHAPI";
	account_zip_code = 93561;
	if (strip(patient_address) = ''  | index (patient_address,'24900 HIGH') = 1)
		then patient_address ="24900 HIGHWAY 202";
	if strip(patient_city) = '' then patient_city = "TEHACHAPI";
	if patient_zip_code = . then patient_zip_code = 93561;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;


if (account_address = "CA INSTITUTE FOR MEN" | patient_address = "CA INSTITUTE FOR MEN" | 
	account_name = "CA INSTITUTE FOR MEN" | ((index (patient_address,"14901") > 0 | 
	index (account_address,"14901") > 0) & (account_city = "CHINO" | patient_city = "CHINO" & 
	patient_zip_code = 91710 & account_zip_code = 91710)) | index (ordering_doctor,"(CIM)") > 0) then do;

	if strip(account_name) = '' then account_name = "CA INSTITUTE FOR MEN";
	if strip(account_address) = '' | index (account_address,"14901") > 0
			then account_address = "14901 S CENTRAL AVE";
	if strip(account_city) = '' then account_city = "CHINO";
	if account_zip_code = . then account_zip_code = 91710;
	if patient_address = '' | index (patient_address,"14901") > 0
		then patient_address = "14901 S CENTRAL AVE";
	if strip(patient_city) = '' then patient_city = "CHINO";
	if patient_zip_code = . then patient_zip_code = 91710;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SAN BERNARDINO";
	local_health_juris = "SAN BERNARDINO";
	end;


if(account_address in ("CA INSTITUTION FOR WOMEN", "16756 CHINO CORONA RD") |
	patient_address in ("CA INSTITUTION FOR WOMEN", "16756 CHINO CORONA RD") |
	account_name = "CA INSTITUTION FOR WOMEN" |	index (ordering_doctor,"(CIW)") > 0 |
	((index(patient_address,"CHINO") > 0 | patient_address = "0" | index(patient_address,"16587") > 0 | 
	index(patient_address,"167456") > 0) & sex = "F" & (account_zip_code in (92878,91720) | 
	patient_zip_code in (92878,91720) | account_city in ("CORONA","FRONTERA") | patient_city in 
	("CORONA","FRONTERA")))) then do;

	if strip(account_name) = '' then account_name = "CA INSTITUTION FOR WOMEN";
	if strip(account_address) = '' then account_address = "16756 CHINO CORONA RD";
	if strip(account_city) in ('',"FRONTERA") then account_city = "CORONA";
	if account_zip_code in (92878,.) then account_zip_code = 91720;
	if (index(patient_address,"CHINO") > 0 | strip(patient_address) in ("","0") | 
		index(patient_address,"16587") > 0 | index(patient_address,"167456") > 0)
		then patient_address = "16756 CHINO CORONA RD";
	if strip(patient_city) in ('',"FRONTERA") then patient_city = "CORONA";
	if patient_zip_code in (92878,.)then patient_zip_code = 91720;
	prison = "F";
	*if missing(local_health_juris) then local_health_juris = "SAN BERNARDINO";
	local_health_juris = "SAN BERNARDINO";
	end;


if (account_address in ("1600 CALIFORNIA DR PO BOX 2000", "CA MED FACILITY") | patient_address in 
	("1600 CALIFORNIA DR PO BOX 2000", "CA MED FACILITY") | account_name = "CA MED FACILITY" |
	(index(patient_address,"BOX 2000") > 0 & patient_city = "VACAVILLE") |
	(index(account_address,"BOX 2000") > 0 & account_city = "VACAVILLE")) then do;

	if strip(account_name) = '' then account_name = "CA MED FACILITY";
	if strip(account_address) in ('',"BOX 2000") then account_address = "1600 CALIFORNIA DR PO BOX 2000";
	if strip(account_city) = '' then account_city = "VACAVILLE";
	if account_zip_code = . then account_zip_code = 95687;
	if strip(patient_address) in ('',"BOX 2000","PO BOX 2000") 
		then patient_address = "1600 CALIFORNIA DR PO BOX 2000";
	if strip(patient_city) = '' then patient_city = "VACAVILLE";
	if patient_zip_code = . then patient_zip_code = 95687;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SOLANO";
	local_health_juris = "SOLANO";
	end;


if (account_address = "CA MEN'S COLONY" | patient_address  = "CA MEN'S COLONY" | 
	account_name = "CA MEN'S COLONY" | substr (patient_address,1,5) = "CMC/D" |
	(patient_address in ("HIGHWAY 1","PO BOX 8101") & patient_city = "SAN LUIS OBISPO") |
	(account_address in ("HIGHWAY 1","PO BOX 8101") & account_city = "SAN LUIS OBISPO")
	| index (ordering_doctor,"CMC") > 0) then do;

	if strip(account_name) = '' then account_name = "CA MEN'S COLONY";
	if strip(account_address) in ("","HIGHWAY 1","PO BOX 8101") 
		then account_address = "HIGHWAY 1 PO BOX 8101";
	if strip(account_city) = '' then account_city = "SAN LUIS OBISPO";
	if account_zip_code = . then account_zip_code = 93409;
	if strip(patient_address) in ("","HIGHWAY 1","PO BOX 8101")
		then patient_address = "HIGHWAY 1 PO BOX 8101";
	if strip(patient_city) = '' then patient_city = "SAN LUIS OBISPO";
	if patient_zip_code = . then patient_zip_code = 93409;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SAN LUIS OBISPO";
	local_health_juris = "SAN LUIS OBISPO";
	end;


if (account_address = "CA REHABILITATION CENTER" | patient_address = "CA REHABILITATION CENTER"
	| account_name = "CA REHABILITATION CENTER" | (patient_address = "PO BOX 1841" & patient_city = "NORCO") |
	(account_address = "PO BOX 1841" & account_city = "NORCO") | index (ordering_doctor,"CRC") > 0 |
	(substr(account_address,1,3) = "5TH" & index(account_address,"WESTERN") > 0) |
	(substr(patient_address,1,3) = "5TH" & index(patient_address,"WESTERN") > 0)) then do;

	if strip(account_name) = '' then account_name = "CA REHABILITATION CENTER";
	if (strip(account_address) = ''  | (substr(account_address,1,3) = "5TH" & index(account_address,"WESTERN") > 0)
		| account_address = "PO BOX 1841") then account_address = "5TH ST & WESTERN AVE PO BOX 1841";
	if strip(account_city) = '' then account_city = "NORCO";
	if account_zip_code = . then account_zip_code = 92860;
	if (strip(patient_address) = ''  | (substr(account_address,1,3) = "5TH" & index(account_address,"WESTERN") > 0)
		| patient_address = "PO BOX 1841") then patient_address = "5TH ST & WESTERN AVE PO BOX 1841";
	if strip(patient_city) = '' then patient_city = "NORCO";
	if patient_zip_code = . then patient_zip_code = 92860;
	* State prison - but only one that is currently co-ed;
	if (sex = "M" | (sex in ('',"U") & put(first_name,$name_sex.) = "M")) then prison = "M";
		else if (sex = "F" | (sex in ('',"U") & put(first_name,$name_sex.) = "F")) then prison = "F";
		else prison = "O";
	*if missing(local_health_juris) then local_health_juris = "RIVERSIDE";
	local_health_juris = "RIVERSIDE";
	end;


if (account_address = "CA STATE PRISON CENTINELA" | patient_address = "CA STATE PRISON CENTINELA" | 
	account_name = "CA STATE PRISON CENTINELA" | (index(patient_address,"BROWN") > 0 & patient_zip_code = 92251) | 
	(index(account_address,"BROWN") > 0 & account_zip_code = 92251) | index (ordering_doctor,"(CEN)") > 0) then do;

	if strip(account_name) = '' then account_name = "CA STATE PRISON CENTINELA";
	if (strip(account_address) = '' | index(account_address,"BROWN") > 0) then account_address = "2302 BROWN ROAD";
	if strip(account_city) = '' then account_city = "IMPERIAL";
	if account_zip_code = . then account_zip_code = 92251;
	if (strip(patient_address) = '' | index(patient_address,"BROWN") > 0) then patient_address = "2302 BROWN ROAD";
	if strip(patient_city) = '' then patient_city = "IMPERIAL";
	if patient_zip_code = . then patient_zip_code = 92251;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "IMPERIAL";
	local_health_juris = "IMPERIAL";
	end;
if account_address='CENTINELA STATE' and data_source='Foundation Lab' then do;
	account_name = "CA STATE PRISON CENTINELA";
	account_address = "2302 BROWN ROAD";
	account_city = "IMPERIAL";
	account_zip_code = 92251;
	if (strip(patient_address) = '' | index(patient_address,"BROWN") > 0) then patient_address = "2302 BROWN ROAD";
	if strip(patient_city) = '' then patient_city = "IMPERIAL";
	if patient_zip_code = . then patient_zip_code = 92251;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "IMPERIAL";
	local_health_juris = "IMPERIAL";
	end;


if (account_address = "CA STATE PRISON CORCORAN" | substr (account_address,1,9) = "4001 KING" |
	patient_address = "CA STATE PRISON CORCORAN" | account_name = "CA STATE PRISON CORCORAN" |
	(substr (patient_address,1,9) = "4001 KING" & patient_city = "CORCORAN")
	| index (ordering_doctor,"(COR)") > 0 | index (ordering_doctor,"(CSP)") > 0) then do;

	if strip(account_name) = '' then account_name = "CA STATE PRISON CORCORAN";
	if strip(account_address) = '' | substr (account_address,1,9) = "4001 KING" 
		then account_address = "4001 KING AVE";
	if strip(account_city) = '' then account_city = "CORCORAN";
	if account_zip_code = . then account_zip_code = 93212;
	if strip(patient_address) = '' | substr (patient_address,1,9) = "4001 KING" 
		then patient_address = "4001 KING AVE";
	if strip(patient_city) = '' then patient_city = "CORCORAN";
	if patient_zip_code = . then patient_zip_code = 93212;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KINGS";
	local_health_juris = "KINGS";
	end;
if account_address='CSP-CORCORAN' and data_source='Foundation Lab' then do;
	account_name = "CA STATE PRISON CORCORAN";
	account_address = "4001 KING AVE";
	account_city = "CORCORAN";
	account_zip_code = 93212;
	if strip(patient_address) = '' | substr (patient_address,1,9) = "4001 KING" 
		then patient_address = "4001 KING AVE";
	if strip(patient_city) = '' then patient_city = "CORCORAN";
	if patient_zip_code = . then patient_zip_code = 93212;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KINGS";
	local_health_juris = "KINGS";
	end;

if (account_address = "CA STATE PRISON LOS ANGELES" | substr (account_address,1,10) = "44750 60TH" |
	patient_address = "CA STATE PRISON LOS ANGELES" | substr (patient_address,1,10) = "44750 60TH" |
	account_name = "CA STATE PRISON LOS ANGELES" | index (ordering_doctor,"(LAC)") > 0
	| (scanq(ordering_doctor,2) = "LAC" & scanq(ordering_doctor,3) = "")) then do;

	if strip(account_name) = '' then account_name = "CA STATE PRISON LOS ANGELES";
	if strip(account_address) = '' | substr (account_address,1,10) = "44750 60TH" 
		then account_address = "44750 60TH STREET WEST";
	if strip(account_city) = '' then account_city = "LANCASTER";
	if account_zip_code = . then account_zip_code = 93536;
	if strip(patient_address) = '' | substr (patient_address,1,10) = "44750 60TH" 
		then patient_address = "44750 60TH STREET WEST";
	if strip(patient_city) = '' then patient_city = "LANCASTER";
	if patient_zip_code = . then patient_zip_code = 93536;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "LOS ANGELES";
	local_health_juris = "LOS ANGELES";
	end;


if (account_address in ("CA STATE PRISON SACRAMENTO", "100 PRISON RD PO BOX 29") |
	patient_address in ("CA STATE PRISON SACRAMENTO", "100 PRISON RD PO BOX 29") |
	account_name = "CA STATE PRISON SACRAMENTO" | (patient_address = "CSP" & patient_zip_code = 95671)) 
	then do;

	if strip(account_name) = '' then account_name = "CA STATE PRISON SACRAMENTO";
	if strip(account_address) = '' then account_address = "100 PRISON RD PO BOX 29";
	if strip(account_city) = '' then account_city = "REPRESA";
	if account_zip_code = . then account_zip_code = 95671;
	if strip(patient_address) = '' then patient_address = "100 PRISON RD PO BOX 29";
	if strip(patient_city) = '' then patient_city = "REPRESA";
	if patient_zip_code = . then patient_zip_code = 95671;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SACRAMENTO";
	local_health_juris = "SACRAMENTO";
	end;


if (account_address = "CA STATE PRISON SOLANO" | substr (account_address,1,12) = "2100 PEABODY" |
	patient_address = "CA STATE PRISON SOLANO" | substr (patient_address,1,12) = "2100 PEABODY" |
	((patient_address in ("CA STATE PRISON","CSP") | index (patient_address,"BOX 640") > 0 |
	index (patient_address,"BOX 4000") > 0) & patient_city = "VACAVILLE") | 
	account_name = "CA STATE PRISON SOLANO") then do;

	if strip(account_name) = '' then account_name = "CA STATE PRISON SOLANO";
	if strip(account_address) = '' | substr (account_address,1,12) = "2100 PEABODY"
		then account_address = "2100 PEABODY RD";
	if strip(account_city) = '' then account_city = "VACAVILLE";
	if account_zip_code = . then account_zip_code = 95687;
	if strip(patient_address) in ("CA STATE PRISON","CSP",'') | substr (patient_address,1,12) = "2100 PEABODY" |
		index (patient_address,"BOX 640") > 0 | index (patient_address,"BOX 4000") > 0
		then patient_address = "2100 PEABODY RD";
	if strip(patient_city) = '' then patient_city = "VACAVILLE";
	if patient_zip_code = . then patient_zip_code = 95687;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SOLANO";
	local_health_juris = "SOLANO";
	end;


if (account_address = "CAL SUBST ABUSE TREATMENT FCLTY" | substr (account_address,1,10) = "900 QUEBEC" |
	patient_address = "CAL SUBST ABUSE TREATMENT FCLTY" | substr (patient_address,1,10) = "900 QUEBEC" |
	account_name in ("CAL SUBST ABUSE TREATMENT FCLTY","CAL SUBSTANCE ABUSE TREATMENT F") |
	(patient_address = "PO BOX 7100" & patient_zip_code = 93212) | index (ordering_doctor,"CSATF") > 0) then do;

	if strip(account_name) in ('',"CAL SUBSTANCE ABUSE TREATMENT F")
		then account_name = "CAL SUBST ABUSE TREATMENT FCLTY";
	if strip(account_address) = '' | substr (account_address,1,10) = "900 QUEBEC" 
		then account_address = "900 QUEBEC AVE PO BOX 7100";
	if strip(account_city) = '' then account_city = "CORCORAN";
	if account_zip_code = . then account_zip_code = 93212;
	if strip(patient_address) = '' | substr (patient_address,1,10) = "900 QUEBEC"
		then patient_address = "900 QUEBEC AVE PO BOX 7100";
	if strip(patient_city) = '' then patient_city = "CORCORAN";
	if patient_zip_code = . then patient_zip_code = 93212;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KINGS";
	local_health_juris = "KINGS";
	end;


if (account_address = "CALIPATRIA STATE PRISON" | substr (account_address,1,10) = "7018 BLAIR" |
	patient_address = "CALIPATRIA STATE PRISON" | substr (patient_address,1,10) = "7018 BLAIR" |
	account_name = "CALIPATRIA STATE PRISON" | account_zip_code = 92233 | patient_zip_code = 92233
	| index (ordering_doctor,"(CAL)") > 0 | (last_name = "CDC" & patient_city in ("BRAWLEY","CALIPATRA"))) then do;

	if strip(account_name) = '' then account_name = "CALIPATRIA STATE PRISON";
	if strip(account_address) = '' | substr (account_address,1,10) = "7018 BLAIR"
			then account_address = "7018 BLAIR ROAD";
	if strip(account_city) = '' then account_city = "CALIPATRIA";
	if account_zip_code = . then account_zip_code = 92233;
	if strip(patient_address) = '' | substr (patient_address,1,10) = "7018 BLAIR"
			then patient_address = "7018 BLAIR ROAD";
	if strip(patient_city) = '' then patient_city = "CALIPATRIA";
	if patient_zip_code = . then patient_zip_code = 92233;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "IMPERIAL";
	local_health_juris = "IMPERIAL";
	if last_name = "CDC" then last_name = "";
	end;


if (account_address in ("CENTRAL CA WOMENS FACILITY", "23370 RD 22 PO BOX 1501") |
	patient_address in ("CENTRAL CA WOMENS FACILITY", "23370 RD 22 PO BOX 1501") |
	(index(patient_address,"1501") > 0 & patient_zip_code = 93610) |
	account_name = "CENTRAL CA WOMENS FACILITY" | index (ordering_doctor,"CCWF") > 0) then do;

	if strip(account_name) = '' then account_name = "CENTRAL CA WOMENS FACILITY";
	if strip(account_address) = '' then account_address = "23370 RD 22 PO BOX 1501";
	if strip(account_city) = '' then account_city = "CHOWCHILLA";
	if account_zip_code = . then account_zip_code = 93610;
	if strip(patient_address) = '' | index(patient_address,"1501") > 0
		then patient_address = "23370 RD 22 PO BOX 1501";
	if strip(patient_city) = '' then patient_city = "CHOWCHILLA";
	if patient_zip_code = . then patient_zip_code = 93610;
	prison = "F";
	*if missing(local_health_juris) then local_health_juris = "MADERA";
	local_health_juris = "MADERA";
	end;


if (account_address = "CHUCKAWALLA VALLEY STATE PRISON" | substr (account_address,1,11) = "19025 WILEY" |
	patient_address = "CHUCKAWALLA VALLEY STATE PRISON" | substr (patient_address,1,11) = "19025 WILEY" |
	(patient_address = "PO BOX 2289" & patient_city = "BLYTHE") |
	(account_address = "PO BOX 2289" & account_city = "BLYTHE") |
	account_name = "CHUCKAWALLA VALLEY STATE PRISON" | index (ordering_doctor,"CVSP") > 0) then do;

	if strip(account_name) = '' then account_name = "CHUCKAWALLA VALLEY STATE PRISON";
	if strip(account_address) in ('',"PO BOX 2289") | substr (account_address,1,11) = "19025 WILEY"
		then account_address = "19025 WILEY'S WELL RD PO BOX 2289";
	if strip(account_city) = '' then account_city = "BLYTHE";
	if account_zip_code = . then account_zip_code = 92225;
	if strip(patient_address) = '' | substr (patient_address,1,11) = "19025 WILEY"
		then patient_address = "19025 WILEY'S WELL RD PO BOX 2289";
	if strip(patient_city) = '' then patient_city = "BLYTHE";
	if patient_zip_code = . then patient_zip_code = 92225;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "RIVERSIDE";
	local_health_juris = "RIVERSIDE";
	end;


if (account_address in ("HIGHWAY 101N PO BOX 686", "CORRECTIONAL TRAINING FACILITY") |
	patient_address in ("HIGHWAY 101N PO BOX 686", "CORRECTIONAL TRAINING FACILITY") |
	(patient_address in ("HIGHWAY 101N", "HWY 101 N") & patient_city = "SOLEDAD") |
	(account_address in ("HIGHWAY 101N", "HWY 101 N") & account_city = "SOLEDAD") |
	account_name = "CORRECTIONAL TRAINING FACILITY" | index (ordering_doctor,"CTF ") > 0) then do;

	if strip(account_name) = '' then account_name = "CORRECTIONAL TRAINING FACILITY";
	if strip(patient_address) in ('', "HIGHWAY 101N", "HWY 101 N")
		then account_address = "HIGHWAY 101N PO BOX 686";
	if strip(account_city) = '' then account_city = "SOLEDAD";
	if account_zip_code = . then account_zip_code = 93960;
	if strip(patient_address) in ('', "HIGHWAY 101N", "HWY 101 N") 
		then patient_address = "HIGHWAY 101N PO BOX 686";
	if strip(patient_city) = '' then patient_city = "SOLEDAD";
	if patient_zip_code = . then patient_zip_code = 93960;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "MONTEREY";
	local_health_juris = "MONTEREY";
	end;


if (account_address = "DEUEL VOCATIONAL INST" |	substr (account_address,1,12) = "23500 KASSON" |
	patient_address = "DEUEL VOCATIONAL INST" |	substr (patient_address,1,12) = "23500 KASSON" |
	account_name = "DEUEL VOCATIONAL INST" | occupation = "Inmate DVI") then do;

	if strip(account_name) = '' then account_name = "DEUEL VOCATIONAL INST";
	if strip(account_address) = '' | substr (account_address,1,12) = "23500 KASSON"
		then account_address = "23500 KASSON RD";
	if strip(account_city) = '' then account_city = "TRACY";
	if account_zip_code = . then account_zip_code = 95304;
	if strip(patient_address) = '' | substr (patient_address,1,12) = "23500 KASSON"
		then patient_address = "23500 KASSON RD";
	if strip(patient_city) = '' then patient_city = "TRACY";
	if patient_zip_code = . then patient_zip_code = 95304;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SAN JOAQUIN";
	local_health_juris = "SAN JOAQUIN";
	if occupation = "Inmate DVI" then occupation = "Inmate";
	end;



if (index(patient_address,"3901 KLEIN") > 0 | index(patient_address,"3901 KLIEN") > 0 |
	index(patient_address,"3600 GUARD") > 0 | account_address = "3901 KLEIN BLVD" |
	account_name = "FEDERAL PENITENTIARY LOMPOC" | patient_address = "FEDERAL PENITENTIARY LOMPOC" | 
	patient_city = "LOF-FCI, 3600 GUARD") then do;

	if strip(account_name) in ('',"US PENITENTIARY") then account_name = "FEDERAL PENITENTIARY LOMPOC";
	if strip(account_address) in ('',"3901 KLEIN BLVD") then account_address = "3901 KLEIN BLVD-3600 GUARD RD";
	if strip(account_city) = '' then account_city = "LOMPOC";
	if account_zip_code = . then account_zip_code = 93436;
	patient_address = "3901 KLEIN BLVD-3600 GUARD RD";
	patient_city = "LOMPOC";
	if patient_zip_code = . then patient_zip_code = 93436;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris = "SANTA BARBARA";
	local_health_juris = "SANTA BARBARA";
	end;



if (account_address in ("300 PRISON RD PO BOX 71", "FOLSOM STATE PRISON") |
	patient_address in ("300 PRISON RD PO BOX 71", "FOLSOM STATE PRISON") |
	(patient_address = "PO BOX 71" & patient_city = "REPRESA") |
	(account_address = "PO BOX 71" & account_city = "REPRESA") |
	account_name = "FOLSOM STATE PRISON") then do;

	if strip(account_name) = '' then account_name = "FOLSOM STATE PRISON";
	if strip(account_address) in ("PO BOX 71",'') then account_address = "300 PRISON RD PO BOX 71";
	if strip(account_city) = '' then account_city = "REPRESA";
	if account_zip_code = . then account_zip_code = 95671;
	if strip(patient_address) in ("PO BOX 71",'') then patient_address = "300 PRISON RD PO BOX 71";
	if strip(patient_city) = '' then patient_city = "REPRESA";
	if patient_zip_code = . then patient_zip_code = 95671;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SACRAMENTO";
	local_health_juris = "SACRAMENTO";
	end;



if (account_address in ("475-750 RICE CANYON RD PO BOX 750", "HIGH DESERT STATE PRISON") |
	patient_address in ("475-750 RICE CANYON RD PO BOX 750", "HIGH DESERT STATE PRISON") |
	(patient_address = "PO BOX 750" & patient_city = "SUSANVILLE") |
	(account_address = "PO BOX 750" & account_city = "SUSANVILLE") |
	account_name = "HIGH DESERT STATE PRISON") then do;

	if strip(account_name) = '' then account_name = "HIGH DESERT STATE PRISON";
	if strip(account_address) in ('',"PO BOX 750") then account_address 
		= "475-750 RICE CANYON RD PO BOX 750";
	if strip(account_city) = '' then account_city = "SUSANVILLE";
	if account_zip_code in (.,96130) then account_zip_code = 96127;
	if strip(patient_address) in ('',"PO BOX 750") then patient_address 
		= "475-750 RICE CANYON RD PO BOX 750";
	if strip(patient_city) = '' then patient_city = "SUSANVILLE";
	if patient_zip_code in (.,96130) then patient_zip_code = 96127;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "LASSEN";
	local_health_juris = "LASSEN";
	end;



if (account_address = "IRONWOOD STATE PRISON" | substr (account_address,1,11) = "19005 WILEY" |
	patient_address = "IRONWOOD STATE PRISON" | substr (patient_address,1,11) = "19005 WILEY" |
	(patient_address = "PO BOX 2229" & patient_city = "BLYTHE") |
	(account_address = "PO BOX 2229" & account_city = "BLYTHE") |
	account_name = "IRONWOOD STATE PRISON" | index (ordering_doctor,"(ISP)") > 0) then do;

	if strip(account_name) = '' then account_name = "IRONWOOD STATE PRISON";
	if strip(account_address) in ('',"PO BOX 2229") | substr (account_address,1,11) = "19005 WILEY"
		then account_address = "19005 WILEY'S WELL RD PO BOX 2229";
	if strip(account_city) = '' then account_city = "BLYTHE";
	if account_zip_code = . then account_zip_code = 92225;
	if strip(patient_address) in ('',"PO BOX 2229") | substr (patient_address,1,11) = "19005 WILEY"
		then patient_address = "19005 WILEY'S WELL RD PO BOX 2229";
	if strip(patient_city) = '' then patient_city = "BLYTHE";
	if patient_zip_code = . then patient_zip_code = 92225;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "RIVERSIDE";
	local_health_juris = "RIVERSIDE";
	end;



if (account_address = "KERN VALLEY STATE PRISON" | patient_address = "KERN VALLEY STATE PRISON" | 
	substr (patient_address,1,12) = "3000 W CECIL" | substr (account_address,1,12) = "3000 W CECIL" | 
	account_name = "KERN VALLEY STATE PRISON" | index (ordering_doctor,"KVSP") > 0) then do;

	if strip(account_name) = '' then account_name = "KERN VALLEY STATE PRISON";
	if strip(account_address) = '' | substr (account_address,1,12) = "3000 W CECIL"
		then account_address = "3000 WEST CECIL AVE";
	if strip(account_city) = '' then account_city = "DELANO";
	if account_zip_code = . then account_zip_code = 93215;
	if strip(patient_address) = '' | substr (patient_address,1,12) = "3000 W CECIL"
		then patient_address = "3000 WEST CECIL AVE";
	if strip(patient_city) = '' then patient_city = "DELANO";
	if patient_zip_code = . then patient_zip_code = 93215;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;
if account_address='KERN VALLEY' and data_source='Foundation Lab' then do;
	account_name = "KERN VALLEY STATE PRISON";
	account_address = "3000 WEST CECIL AVE";
	account_city = "DELANO";
	account_zip_code = 93215;
	if strip(patient_address) = '' | substr (patient_address,1,12) = "3000 W CECIL"
		then patient_address = "3000 WEST CECIL AVE";
	if strip(patient_city) = '' then patient_city = "DELANO";
	if patient_zip_code = . then patient_zip_code = 93215;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;



if (account_address in ("LA COUNTY JAIL TWIN TOWERS","450 BAUCHET ST FL 2") | 
	(index (patient_address,"BAUCHET") > 0 & patient_zip_code = 90012) |
	patient_address = "LA COUNTY JAIL TWIN TOWERS" | account_name = "LA COUNTY JAIL TWIN TOWERS") then do;

	if strip(account_name) = '' then account_name = "LA COUNTY JAIL TWIN TOWERS";
	if strip(account_address) = '' | index(account_address,"BAUCHET") > 0 
		then account_address = "450 BAUCHET ST FL 2";
	if strip(account_city) = '' then account_city = "LOS ANGELES";
	if account_zip_code = . then account_zip_code = 90012;
	if strip(patient_address) = '' | index(patient_address,"BAUCHET") > 0 
		then patient_address = "450 BAUCHET ST FL 2";
	if strip(patient_city) = '' then patient_city = "LOS ANGELES";
	if patient_zip_code = . then patient_zip_code = 90012;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris = "LOS ANGELES";
	local_health_juris = "LOS ANGELES";
	end;



if ((index(patient_address,"LAS COLINAS") > 0 & patient_zip_code = 92071) | account_name = "LAS COLINAS DETENTION" | 
	account_address = "9000 COTTONWOOD AVE" | index(patient_address,"9000 COTTONWOOD") > 0) then do;

	if strip(account_name) = '' | account_name = "LAS COLINAS DETENTION" then 
		account_name = "LAS COLINAS DETENTION CENTER";
	if strip(account_address) = '' then account_address = "9000 COTTONWOOD AVE";
	if strip(account_city) = '' then account_city = "SANTEE";
	if account_zip_code = . then account_zip_code = 92071;
	if strip(patient_address) = '' | index(patient_address,"LAS COLINAS") > 0 | 
		index(patient_address,"9000 COTTONWOOD") > 0 then patient_address = "9000 COTTONWOOD AVE";
	if strip(patient_city) = '' then patient_city = "SANTEE";
	if patient_zip_code = . then patient_zip_code = 92071;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris = "SAN DIEGO";
	local_health_juris = "SAN DIEGO";
	end;



if (((index(patient_address,"INDUSTRIAL FARM") > 0 | index(patient_address,"17635") > 0) & patient_zip_code = 93308) |
	patient_address = "LERDO JAIL FACILITY") then do;

	if strip(account_name) = '' then account_name = "LERDO JAIL FACILITY";
	if strip(account_address) = '' then account_address = "17635 INDUSTRIAL FARM RD";
	if strip(account_city) = '' then account_city = "BAKERSFIELD";
	if account_zip_code = . then account_zip_code = 93308;
	if strip(patient_address) = '' | index(patient_address,"INDUSTRIAL FARM") > 0 | 
		index(patient_address,"17635") > 0 then patient_address = "17635 INDUSTRIAL FARM RD";
	if strip(patient_city) = '' then patient_city = "BAKERSFIELD";
	if patient_zip_code = . then patient_zip_code = 93308;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;



if (account_address in ("MULE CREEK STATE PRISON", "4001 HIGHWAY 104 PO BOX 409099") |
	patient_address in ("MULE CREEK STATE PRISON", "4001 HIGHWAY 104 PO BOX 409099") |
	account_name = "MULE CREEK STATE PRISON") then do;

	if strip(account_name) = '' then account_name = "MULE CREEK STATE PRISON";
	if strip(account_address) = '' then account_address = "4001 HIGHWAY 104 PO BOX 409099";
	if strip(account_city) = '' then account_city = "IONE";
	if account_zip_code = . then account_zip_code = 95640;
	if strip(patient_address) = '' then patient_address = "4001 HIGHWAY 104 PO BOX 409099";
	if strip(patient_city) = '' then patient_city = "IONE";
	if patient_zip_code = . then patient_zip_code = 95640;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "AMADOR";
	local_health_juris = "AMADOR";
	end;



if (account_address = "NORTH KERN STATE PRISON" | patient_address = "NORTH KERN STATE PRISON" | 
	substr (patient_address,1,12) = "2737 W CECIL" | substr (account_address,1,12) = "2737 W CECIL" | 
	account_name = "NORTH KERN STATE PRISON" | (patient_address = "PO BOX 567" & patient_city = "DELANO")
	| index (ordering_doctor,"NKSP") > 0) then do;

	if strip(account_name) = '' then account_name = "NORTH KERN STATE PRISON";
	if strip(account_address) = '' | substr (account_address,1,12) = "2737 W CECIL"
		then account_address = "2737 WEST CECIL AVE";
	if strip(account_city) = '' then account_city = "DELANO";
	if account_zip_code = . then account_zip_code = 93215;
	if strip(patient_address) = '' | substr (patient_address,1,12) = "2737 W CECIL"
		then patient_address = "2737 WEST CECIL AVE";
	if strip(patient_city) = '' then patient_city = "DELANO";
	if patient_zip_code = . then patient_zip_code = 93215;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;
if account_address='NORTH KERN' and data_source='Foundation Lab' then do;
	account_name = "NORTH KERN STATE PRISON";
	account_address = "2737 WEST CECIL AVE";
	account_city = "DELANO";
	account_zip_code = 93215;
	if strip(patient_address) = '' | substr (patient_address,1,12) = "2737 W CECIL"
		then patient_address = "2737 WEST CECIL AVE";
	if strip(patient_city) = '' then patient_city = "DELANO";
	if patient_zip_code = . then patient_zip_code = 93215;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;


if patient_address = "7150 ARCH ROAD PO BOX 213006" then do;

	if strip(account_name) = '' then account_name = "NORTHERN CA WOMENS FACILITY";
	if strip(account_address) = '' then account_address = "7150 ARCH ROAD PO BOX 213006";
	if strip(account_city) = '' then account_city = "STOCKTON";
	if account_zip_code = . then account_zip_code = 95213;
	if strip(patient_city) = '' then patient_city = "STOCKTON";
	if patient_zip_code = . then patient_zip_code = 95213;
	prison = "F";
	*if missing(local_health_juris) then local_health_juris = "SAN JOAQUIN";
	local_health_juris = "SAN JOAQUIN";
	end;



if (account_address = "PELICAN BAY STATE PRISON" | patient_address = "PELICAN BAY STATE PRISON" | 
	account_name = "PELICAN BAY STATE PRISON" | substr (patient_address,1,16) = "5905 LAKE EARL D" | 
	substr (account_address,1,16) = "5905 LAKE EARL D" | account_zip_code = 95532 | 
	patient_zip_code = 95532 | index (ordering_doctor,"(BUD)") > 0 | (last_name = "CDC" & patient_city = "CRESCENT CITY")) 
	then do;

	if strip(account_name) = '' then account_name = "PELICAN BAY STATE PRISON";
	if strip(account_address) = '' | substr (account_address,1,16) = "5905 LAKE EARL D"
		then account_address = "5905 LAKE EARL DRIVE";
	if strip(account_city) = '' then account_city = "CRESCENT CITY";
	if account_zip_code = . then account_zip_code = 95532;
	if strip(patient_address) = '' | substr (patient_address,1,16) = "5905 LAKE EARL D"
		then patient_address = "5905 LAKE EARL DRIVE";
	if strip(patient_city) = '' then patient_city = "CRESCENT CITY";
	if patient_zip_code = . then patient_zip_code = 95532;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "DEL NORTE";
	local_health_juris = "DEL NORTE";
	if last_name = "CDC" then last_name = "";
	end;



if (account_address = "PLEASANT VALLEY STATE PRISON" | substr (account_address,1,10) = "24863 W JA" |
	patient_address = "PLEASANT VALLEY STATE PRISON" | substr (patient_address,1,10) = "24863 W JA" |
	account_name = "PLEASANT VALLEY STATE PRISON" | index (ordering_doctor,"PVSP") > 0) then do;

	if strip(account_name) = '' then account_name = "PLEASANT VALLEY STATE PRISON";
	if strip(account_address) = '' | substr (account_address,1,10) = "24863 W JA" 
		then account_address = "24863 W JAYNE AVE";
	if strip(account_city) = '' then account_city = "COALINGA";
	if account_zip_code = . then account_zip_code = 93210;
	if strip(patient_address) = ''  | substr (patient_address,1,10) = "24863 W JA"
		then patient_address = "24863 W JAYNE AVE";
	if strip(patient_city) = '' then patient_city = "COALINGA";
	if patient_zip_code = . then patient_zip_code = 93210;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "FRESNO";
	local_health_juris = "FRESNO";
	end;
if account_address='PLEASANT VALLEY STATE' and data_source='Foundation Lab' then do;
	account_name = "PLEASANT VALLEY STATE PRISON";
	account_address = "24863 W JAYNE AVE";
	account_city = "COALINGA";
	account_zip_code = 93210;
	if strip(patient_address) = ''  | substr (patient_address,1,10) = "24863 W JA"
		then patient_address = "24863 W JAYNE AVE";
	if strip(patient_city) = '' then patient_city = "COALINGA";
	if patient_zip_code = . then patient_zip_code = 93210;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "FRESNO";
	local_health_juris = "FRESNO";
	end;


if (account_address = "RJ DONOVAN CORRCTNL FACLTY" | patient_address = "RJ DONOVAN CORRCTNL FACLTY" | 
	account_name = "RJ DONOVAN CORRCTNL FACLTY" | index (patient_address,"480 ALTA") > 0 | 
	index (account_address,"480 ALTA R") > 0 | ((index(patient_address,"INMATE") > 0 | 
	index(patient_address,"DONOVAN") > 0 | index(patient_address,"CDC") > 0) & patient_zip_code = 92179)
	| index (ordering_doctor,"RJD") > 0) then do;

	if strip(account_name) = '' then account_name = "RJ DONOVAN CORRCTNL FACLTY";
	if strip(account_address) = '' | index (account_address,"480 ALTA R") > 0
		then account_address = "480 ALTA ROAD";
	if strip(account_city) = '' then account_city = "SAN DIEGO";
	if account_zip_code = . then account_zip_code = 92179;
	if strip(patient_address) = '' | index (patient_address,"480 ALTA") > 0 | 
		(index(patient_address,"INMATE") > 0 | index(patient_address,"DONOVAN") > 0 | 
		index(patient_address,"CDC") > 0) 
		then patient_address = "480 ALTA ROAD";
	if strip(patient_city) = '' then patient_city = "SAN DIEGO";
	if patient_zip_code = . then patient_zip_code = 92179;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SAN DIEGO";
	local_health_juris = "SAN DIEGO";
	end;
if index(account_address,'RJ DONOVAN COR FAC-') and data_source='Foundation Lab' then do;
	account_name = "RJ DONOVAN CORRCTNL FACLTY";
	account_address = "480 ALTA ROAD";
	account_city = "SAN DIEGO";
	account_zip_code = 92179;
	if strip(patient_address) = '' | index (patient_address,"480 ALTA") > 0 | 
		(index(patient_address,"INMATE") > 0 | index(patient_address,"DONOVAN") > 0 | 
		index(patient_address,"CDC") > 0) 
		then patient_address = "480 ALTA ROAD";
	if strip(patient_city) = '' then patient_city = "SAN DIEGO";
	if patient_zip_code = . then patient_zip_code = 92179;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "SAN DIEGO";
	local_health_juris = "SAN DIEGO";
	end;



if (substr (account_address,1,8) = "651 I ST" | substr (patient_address,1,8) = "651 I ST" |
	(index(patient_address,"JAIL") > 0 & patient_zip_code = 95814) | 
	(index(account_name,"JAIL") > 0 & account_zip_code = 95814)) then do;

	if strip(account_name) = '' | index(account_name,"JAIL") > 0
		then account_name = "SACRAMENTO COUNTY MAIN JAIL";
	if strip(account_address) = '' | substr (account_address,1,8) = "651 I ST" 
		then account_address = "651 I ST";
	if strip(account_city) = '' then account_city = "SACRAMENTO";
	if account_zip_code = . then account_zip_code = 95814;
	if strip(patient_address) = '' | substr (patient_address,1,8) = "651 I ST" 
		then patient_address = "651 I ST";
	if strip(patient_city) = '' then patient_city = "SACRAMENTO";
	if patient_zip_code = . then patient_zip_code = 95814;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris = "SACRAMENTO";
	local_health_juris = "SACRAMENTO";
	end;



if (account_address in ("SALINAS VALLEY STATE PRISON", "31625 HIGHWAY 101 S PO BOX 1020") |
	patient_address in ("SALINAS VALLEY STATE PRISON", "31625 HIGHWAY 101 S PO BOX 1020") |
	account_name = "SALINAS VALLEY STATE PRISON" | index (patient_address,"SVSP") > 0 | 
	(patient_address = "PO BOX 1020" & (patient_zip_code = 93960 | patient_city = "SOLEDAD"))
	| index (ordering_doctor,"(SVSP)") > 0) then do;

	if strip(account_name) = '' then account_name = "SALINAS VALLEY STATE PRISON";
	if strip(account_address) = '' then account_address = "31625 HIGHWAY 101 S PO BOX 1020";
	if strip(account_city) = '' then account_city = "SOLEDAD";
	if account_zip_code = . then account_zip_code = 93960;
	if strip(patient_address) in ("PO BOX 1020",'') | index (patient_address,"SVSP") > 0
		then patient_address = "31625 HIGHWAY 101 S PO BOX 1020";
	if strip(patient_city) = '' then patient_city = "SOLEDAD";
	if patient_zip_code = . then patient_zip_code = 93960;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "MONTEREY";
	local_health_juris = "MONTEREY";
	end;



if ((index (patient_address,"CENTRAL DETENTION") > 0 & patient_zip_code = 92101) |
	(index (account_name,"CENTRAL DETENTION") > 0 & account_zip_code = 92101)) then do;

	if index (account_name,"CENTRAL DETENTION") > 0 | strip(account_name) = ''
		then account_name = "SAN DIEGO CENTRAL DETENTION FCLTY";
	if strip(account_address) = '' then account_address = "1173 FRONT ST";
	if strip(account_city) = '' then account_city = "SAN DIEGO";
	if account_zip_code = . then account_zip_code = 92101;
	if index (patient_address,"CENTRAL DETENTION") > 0 | strip(patient_address) = '' 
		then patient_address = "1173 FRONT ST";
	if strip(patient_city) = '' then patient_city = "SAN DIEGO";
	if patient_zip_code = . then patient_zip_code = 92101;
	prison = "O";
	*if missing(local_health_juris) then local_health_juris = "SAN DIEGO";
	local_health_juris = "SAN DIEGO";
	end;


if (((index (patient_address,"425 7TH") > 0 | (index (patient_address,"425 SEVENTH") > 0) & patient_zip_code=94103) | 
	((index (account_address,"425 7TH") > 0 | (index (account_address,"425 SEVENTH") > 0) & account_zip_code=94103))) |
	((index (patient_address,"850 BRYANT") > 0 & patient_zip_code=94103) | 
	(index (account_address,"850 BRYANT") > 0 & account_zip_code=94103)) |
	((index (patient_address,"1 MORELAND") > 0 & (index (patient_address,"BOX 67") > 0 | index (patient_address,"BOX 907") > 0) & patient_zip_code=94066) |
	(index (account_address,"1 MORELAND") > 0 & (index (account_address,"BOX 67") > 0 | index (account_address,"BOX 907") > 0) & account_zip_code=94066)))
	then do;
		if strip(account_city) = '' then account_city = "SAN FRANCISCO";
		if account_zip_code = . & index (patient_address,"1 MORELAND") = 0 & index (account_address,"1 MORELAND") = 0 then account_zip_code = 94103;
		if account_zip_code = . & (index (patient_address,"1 MORELAND") > 0 | index (account_address,"1 MORELAND") > 0) then account_zip_code = 94066;
		if strip(patient_city) = '' then patient_city = "SAN FRANCISCO";
		if patient_zip_code = . & index (patient_address,"1 MORELAND") = 0 & index (account_address,"1 MORELAND") = 0 then account_zip_code = 94103;
		if patient_zip_code = . & (index (patient_address,"1 MORELAND") > 0 | index (account_address,"1 MORELAND") > 0) then account_zip_code = 94066;
		prison = "O";
		*if missing(local_health_juris) then local_health_juris = "SAN FRANCISCO";
		local_health_juris = "SAN FRANCISCO";
end;

if (account_zip_code = 94964 | patient_zip_code = 94964 | account_address in ("1 SAN QUENTIN", 
	"SAN QUENTIN STATE PRISON") | patient_address in ("1 SAN QUENTIN", "SAN QUENTIN STATE PRISON") 
	| account_name = "SAN QUENTIN STATE PRISON") then do;

	if strip(account_name) = '' then account_name = "SAN QUENTIN STATE PRISON";
	if strip(account_address) = '' then account_address = "1 SAN QUENTIN";
	if strip(account_city) = '' then account_city = "SAN QUENTIN";
	if account_zip_code = . then account_zip_code = 94964;
	if strip(patient_address) = '' then patient_address = "1 SAN QUENTIN";
	if strip(patient_city) = '' then patient_city = "SAN QUENTIN";
	if patient_zip_code = . then patient_zip_code = 94964;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "MARIN";
	local_health_juris = "MARIN";
	end;



if (account_address = "SIERRA CONSERVATION CENTER" | 
	patient_address = "SIERRA CONSERVATION CENTER" |
	(index (patient_address,"BYRNES FERRY") > 0 & index (patient_address,"5100") > 0) | 
	(index (account_address,"BYRNES FERRY") > 0 & index (account_address,"5100") > 0) | 
	account_name = "SIERRA CONSERVATION CENTER") then do;

	if strip(account_name) = '' then account_name = "SIERRA CONSERVATION CENTER";
	if strip(account_address) = '' | (index (account_address,"BYRNES FERRY") > 0 & 
	index (account_address,"5100") > 0) then account_address = "5100 O'BYRNES FERRY ROAD";
	if strip(account_city) = '' then account_city = "JAMESTOWN";
	if account_zip_code = . then account_zip_code = 95327;
	if strip(patient_address) = '' | (index (patient_address,"BYRNES FERRY") > 0 & 
	index (patient_address,"5100") > 0)then patient_address = "5100 O'BYRNES FERRY ROAD";
	if strip(patient_city) = '' then patient_city = "JAMESTOWN";
	if patient_zip_code = . then patient_zip_code = 95327;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "TUOLUMNE";
	local_health_juris = "TUOLUMNE";
	end;



if (account_address in ("VALLEY STATE PRISON FOR WOMEN", "21633 RD 24") |
	patient_address in ("VALLEY STATE PRISON FOR WOMEN", "21633 RD 24") |
	(index(patient_address,"BOX 9") > 0 & patient_zip_code = 93610) |
	account_name = "VALLEY STATE PRISON FOR WOMEN" | index (ordering_doctor,"(VSPW)") > 0) then do;

	if strip(account_name) = '' then account_name = "VALLEY STATE PRISON FOR WOMEN";
	if strip(account_address) = '' then account_address = "21633 RD 24";
	if strip(account_city) = '' then account_city = "CHOWCHILLA";
	if account_zip_code = . then account_zip_code = 93610;
	if strip(patient_address) = '' | index(patient_address, "BOX 9") > 0
		then patient_address = "21633 RD 24";
	if strip(patient_city) = '' then patient_city = "CHOWCHILLA";
	if patient_zip_code = . then patient_zip_code = 93610;
	prison = "F";
	*if missing(local_health_juris) then local_health_juris = "MADERA";
	local_health_juris = "MADERA";
	end;



if ((index (account_address,'701') = 1 & index (account_address,'SCOFI') > 1) | 
	(index (patient_address,'701') = 1 & index (patient_address,'SCOFI') > 1) |
	(patient_address = "PO BOX 8800" & (patient_city = "WASCO" | patient_zip_code = 93280)) |
	patient_address = "WASCO STATE PRISON" | patient_address = "WASCO STATE PRISON" | 
	account_name = "WASCO STATE PRISON" | index (ordering_doctor,"(WSP)") > 0) then do;

	if strip(account_name) = '' then account_name = "WASCO STATE PRISON";
	if (strip(account_address) in ('',"PO BOX 8800") 
		| (index (account_address,'701') = 1 & index (account_address,'SCOFI') > 1)) 
		then account_address = "701 SCOFIELD AVE PO BOX 8800";
	if strip(account_city) = '' then account_city = "WASCO";
	if account_zip_code = . then account_zip_code = 93280;
	if (strip(patient_address) in ('',"PO BOX 8800") 
		| (index (patient_address,'701') = 1 & index (patient_address,'SCOFI') > 1))
		then patient_address = "701 SCOFIELD AVE PO BOX 8800";
	if strip(patient_city) = '' then patient_city = "WASCO";
	if patient_zip_code = . then patient_zip_code = 93280;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;
if account_address='WASCO' and data_source='Foundation Lab' then do;
	account_name = "WASCO STATE PRISON";
	ccount_address = "701 SCOFIELD AVE PO BOX 8800";
	account_city = "WASCO";
	account_zip_code = 93280;
	if (strip(patient_address) in ('',"PO BOX 8800") 
		| (index (patient_address,'701') = 1 & index (patient_address,'SCOFI') > 1))
		then patient_address = "701 SCOFIELD AVE PO BOX 8800";
	if strip(patient_city) = '' then patient_city = "WASCO";
	if patient_zip_code = . then patient_zip_code = 93280;
	prison = "M";
	*if missing(local_health_juris) then local_health_juris = "KERN";
	local_health_juris = "KERN";
	end;

%mend;
