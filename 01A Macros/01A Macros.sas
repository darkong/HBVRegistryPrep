*=====================================================================;
* Analyst : Adam Coutts
* Created : June 30, 2011
* Last Updated: April 27, 2012 by Alexia Exarchos
* Purpose : Install regularly-used macros
*=====================================================================;


* Norm lev macro - used briefly in 05 Matching, often in 06 Matched Pair program - creates number
	score for how close two words are, lexically;

%macro normlev(var1,var2);
	complev(&var1.,&var2.)/max(length(&var1.),length(&var2.))
%mend;


* Macros for code that is used many times in deduplicating process - to save space and have clear code in
	main code block;
* A score that is lower if one of the two names being compared is common;
%macro score(var1,var2,fmt=);
	min(input(put(&var1.,&fmt.),8.3),input(put(&var2.,&fmt.),8.3))
%mend;


* Macro to check if two names can be considered the same.  Two versions - one that checks for nickname matches 
	(for first and middle name checks) and one that doesnt (for last name matches);

%macro samef (var1,var2);
(&var1. = &var2. | indexw(put(&var1.,$nickname.),&var2.) | indexw(put(&var2.,$nickname.),&var1.) | 
(index (&var1.,strip(&var2.)) > 0 & length(&var2.) > 3) |
(index (&var2.,strip(&var1.)) > 0 & length(&var1.) > 3) | (%normlev(&var1.,&var2.)<=0.2)
| substr(&var2.,1,length(&var1.)) = &var1. | substr(&var1.,1,length(&var2.)) = &var2.)
%mend;


%macro samel (var1,var2);
(&var1. = &var2. | (index (&var1.,strip(&var2.)) > 0 & length(&var2.) > 3) |
(index (&var2.,strip(&var1.)) > 0 & length(&var1.) > 3) | (%normlev(&var1.,&var2.)<=0.2))
%mend;

%macro MMWRyear (date); * Returns pWeek, a numeric variable, for pDate, a date variable, in a data step.
pWeek must be large enough to hold a date variable temporarily;
format MmwrWeek 8.;
if (date > mdy(12,30,year(&date))) and (weekday(&date) < 4) then do;
      weeknum = 1;
end; 
else if (date > mdy(12,29,year(&date))) and (weekday(&date) < 3) then do;
      weeknum = 1;
end; 
else if (date > mdy(12,28,year(&date))) and (weekday(&date) < 2) then do;
      weeknum = 1;
end; 
else do;
      if weekday(mdy(1,1,year(&date))) < 2 then weeknum = week(&date, 'u');
      else if weekday(mdy(1,1,year(&date))) < 5 then weeknum = week(&date, 'u') + 1;
      else weeknum = week(&date, 'u');
      if weeknum = 0 then do; 
            weeknum = mdy(12,31,year(&date)-1);
            if weekday(mdy(1,1,year(weeknum))) < 2 then weeknum = week(weeknum, 'u');
            else if weekday(mdy(1,1,year(weeknum))) < 5 then weeknum = week(weeknum, 'u') + 1;
            else weeknum = week(weeknum, 'u');
      end; * if week zero;
end; * if last three days in year;
year=year(&date);
month=month(&date);
if month=12 and weeknum=1 then mmwr_year= year+1;
if month=1 and weeknum>=52 then mmwr_year= year-1;
if weeknum<10 then MmwrWeek=trim(left(mmwr_year))||'0'||trim(left(weeknum));
else MmwrWeek=trim(left(mmwr_year))||trim(left(weeknum));
%mend;

%macro words(str,delim=%str( ));
  %local i;
  %let i=1;
  %do %while(%length(%qscan(&str,&i,&delim)) GT 0);
    %let i=%eval(&i + 1);
  %end;
%eval(&i - 1)
%mend words;

%macro lookahead(dsin=,dsout=,bygroup=,vars=,lookahead=);

%local error i;
%let error=0;


            /*--------------------------------------*
               Check we have enough parameters set
             *--------------------------------------*/

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (lookahed) Nothing specified to dsin= parameter;
%end;

%if not %length(&bygroup) %then %do;
  %let error=1;
  %put ERROR: (lookahed) Nothing specified to bygroup= parameter;
%end;

%if not %length(&vars) %then %do;
  %let error=1;
  %put ERROR: (lookahed) Nothing specified to vars= parameter;
%end;

%if &error %then %goto error;

%if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());

%if not %length(&lookahead) %then %let lookahead=1;



            /*--------------------------------------*
                   Start processing the data
             *--------------------------------------*/

data _look;
  retain _seq 0;
  set &dsin;
  by &bygroup;
  if first.%scan(&bygroup,-1,%str( )) then _seq=0;
  _seq=_seq+1;
run;

%do i=1 %to &lookahead;
  data _look&i;
    set _look(keep=_seq &bygroup &vars);
    _seq=_seq-&i;
    rename
    %do j=1 %to %words(&vars);
      %scan(&vars,&j,%str( ))=%scan(&vars,&j,%str( ))&i
    %end;
    ;
  run;  
%end;

data &dsout;
  merge _look(in=_look)
  %do i=1 %to &lookahead;
        _look&i
  %end;
        ;
  by &bygroup _seq;
  if _look;
  drop _seq;
run;



            /*--------------------------------------*
                         Tidy up and exit
             *--------------------------------------*/

proc datasets nolist;
  delete _look
  %do i=1 %to &lookahead;
    _look&i
  %end;
  ;
run; 
quit;


%goto skip;
%error:
%put ERROR: (lookahead) Leaving macro due to error(s) listed.;
%skip:
%mend;




* Create nickname format - for use in determining name matches - code copied from Glenn Wright;
%let nicknames_source = nick.link_king_nicknames;

proc sql;
      create      table nicknames_1 as
      select      nickname1 as start, nickname2 as nickname
      from        &nicknames_source.
      UNION
      select      nickname2 as start, nickname1 as nickname
      from        &nicknames_source.
      order       by start, nickname
      ;

data nicknames_2;
      length label $ 32767;
      set nicknames_1 end=last;
      by start;
      fmtname = "$nickname";
      retain label;
      if first.start then label = nickname;
      else label = strip(label) || ' ' || strip(nickname);
      if last.start then output;
      if last then do;
            hlo = 'o';
            label = '*';
            output;
      end;
run;

proc sql noprint; select max(length(label)) into :label_length from nicknames_2;

data nicknames_3;
      length label $ &label_length.;
      set nicknames_2;

proc format library = work cntlin = work.nicknames_3;
	run;
