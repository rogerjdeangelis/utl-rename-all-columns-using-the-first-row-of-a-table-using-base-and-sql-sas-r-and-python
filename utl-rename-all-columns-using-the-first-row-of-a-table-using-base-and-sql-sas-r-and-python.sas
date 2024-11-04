%let pgm=utl-rename-all-columns-using-the-first-row-of-a-table-using-base-and-sql-sas-r-and-python;

%stop_submission;

Examples of meta data processing

Rename all columns using the first row of a table using base and sql sas r and python

The sas solution uses two macros that are on the end of this post.
Macrosg by Ian Whitlock and Søren Lassen (useful general purpose macros)
SAS macro processing is uniquely suited for meta processing.

Working on a array and do_over macros in R for creating SQL Array based code?

github
https://tinyurl.com/mr34m4r2
https://stackoverflow.com/questions/78940039/how-to-convert-first-row-of-a-sas-dataset-into-header

   SOLUTIONS

       1 sas proc datasets
       2 r colnames function
       3 python panda language iloc index (took the most time to figure out)
       4 sas sql template
       5 sas sql rename macro
       6 sas sql alias a as x..
       7 r sql alias
       8 python sql alias
       9 usefull macros for meta processing

github
https://tinyurl.com/yc57dd5r
https://github.com/rogerjdeangelis/utl-rename-all-columns-using-the-first-row-of-a-table-using-base-and-sql-sas-r-and-python

macros
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*                              |                                               |                                         */
/*     INPUT                    |              PROCESSES                        |      OUTPUT                             */
/*     =====                    |              =========                        |      ======                             */
/*                              |                                               |                                         */
/*   A    B    C                | 5 SAS SQL RENAME VARLIST MACROS               |     X    Y    Z                         */
/*                              | ===============================               |                                         */
/*   X    Y    Z <- NEW NAMES   |                                               |     X    Y    Z                         */
/*   1    4    7                |  select                                       |     1    4    7                         */
/*   2    5    8                |    catx(' ',                                  |     2    5    8                         */
/*   3    6    9                |      %utl_varlist(sd1.have,od=%str(,)))       |     3    6    9                         */
/*                              |  into                                         |                                         */
/*                              |    :nams                                      |                                         */
/*                              |  from                                         |                                         */
/*                              |    sd1.have(obs=1)                            |                                         */
/*                              |  ;                                            |                                         */
/*                              |  create                                       |                                         */
/*                              |    table want as                              |                                         */
/*                              |  select                                       |                                         */
/*                              |    *                                          |                                         */
/*                              |  from                                         |                                         */
/*                              |    sd1.have                                   |                                         */
/*                              |    (rename=                                   |                                         */
/*                              |     (%utl_renamel(old=                        |                                         */
/*                              |       %utl_varlist(sd1.have),new=&nams        |                                         */
/*                              |    )))                                        |                                         */
/*                              |                                               |                                         */
/*                              -------------------------------------------------                                         */
/*                              |                                               |                                         */
/*                              | 2 R COLNAMES FUNCTION (NICE ONE LINER)        |                                         */
/*                              | =======================================       |                                         */
/*                              | LIKE OTHER MATRIX LANGUAGES?                  |                                         */
/*                              |                                               |                                         */
/*                              | colnames(have)<-have[1,];                     |                                         */
/*                              |                                               |                                         */
/*                              |-----------------------------------------------|                                         */
/*                              |                                               |                                         */
/*                              | 7 R SQL ALIAS PREP SQL CODE IN SAS            |                                         */
/*                              | ==================================            |                                         */
/*                              |                                               |                                         */
/*                              | data _null_;                                  |                                         */
/*                              |   set sd1.have(obs=1);                        |                                         */
/*                              |   array chrs[*] _character_;                  |                                         */
/*                              |   retain sql '                       ';       |                                         */
/*                              |   do i=1 to dim(chrs);                        |                                         */
/*                              |     vv=cats(vname(chrs[i]),'=',chrs[i]);      |                                         */
/*                              |     sql = catx(','                            |                                         */
/*                              |        ,sql,catx(' '                          |                                         */
/*                              |        ,vname(chrs[i]),'as',chrs[i]));        |                                         */
/*                              |   end;                                        |                                         */
/*                              |   call symputx('sql',sql);                    |                                         */
/*                              |                                               |                                         */
/*                              | R                                             |                                         */
/*                              | want <- sqldf("select &sql from have")        |                                         */
/*                              |                                               |                                         */
/*                              |-----------------------------------------------|                                         */
/*                              |                                               |                                         */
/*                              | 6 SAS SQL ALIAS A AS X                        |                                         */
/*                              | =======================                       |                                         */
/*                              |                                               |                                         */
/*                              | data _null_;                                  |                                         */
/*                              |   set sd1.have(obs=1);                        |                                         */
/*                              |   array chrs[*] _character_;                  |                                         */
/*                              |   retain sql '                       ';       |                                         */
/*                              |   do i=1 to dim(chrs);                        |                                         */
/*                              |     vv=cats(vname(chrs[i]),'=',chrs[i]);      |                                         */
/*                              |     sql = catx(',',sql,catx(' '               |                                         */
/*                              |     ,vname(chrs[i]),'as',chrs[i]));           |                                         */
/*                              |   end;                                        |                                         */
/*                              |   call symputx('sql',sql);                    |                                         */
/*                              |                                               |                                         */
/*                              | create                                        |                                         */
/*                              |    table want as                              |                                         */
/*                              | select                                        |                                         */
/*                              |    &sql                                       |                                         */
/*                              | from                                          |                                         */
/*                              |    sd1.have                                   |                                         */
/*                              |                                               |                                         */
/*                              |-----------------------------------------------|                                         */
/*                              |                                               |                                         */
/*                              | 1 SAS PROC DATASETS                           |                                         */
/*                              | ===================                           |                                         */
/*                              |                                               |                                         */
/*                              | * CREATE MACRO VARIABLE NAMS WITH NAMS=X Y Z; |                                         */
/*                              |                                               |                                         */
/*                              | data _null_;                                  |                                         */
/*                              |   set sd1.have(obs=1);                        |                                         */
/*                              |   array chrs[*] _character_;                  |                                         */
/*                              |   call symputx('nams',catx(' ',of chrs[*]));  |                                         */
/*                              | run;quit;                                     |                                         */
/*                              |                                               |                                         */
/*                              | * CREATE MACRO VARIABLE                       |                                         */
/*                              |    RENAM WITH RENAM=A = X  B = Y  C = Z;      |                                         */
/*                              |                                               |                                         */
/*                              | %let renam =                                  |                                         */
/*                              |   %utl_renamel(%utl_varlist(sd1.have),&nams); |                                         */
/*                              |                                               |                                         */
/*                              | * rename variable;                            |                                         */
/*                              | proc datasets lib=sd1 nolist nodetails;       |                                         */
/*                              |   modify have;                                |                                         */
/*                              |      rename                                   |                                         */
/*                              |          &renam                               |                                         */
/*                              | ;run;quit;                                    |                                         */
/*                              |                                               |                                         */
/*                              |-----------------------------------------------|                                         */
/*                              |                                               |                                         */
/*                              | 4 SAS SQL TEMPLATE                            |                                         */
/*                              | ==================                            |                                         */
/*                              |                                               |                                         */
/*                              | select                                        |                                         */
/*                              |   catx(' char(8) ,'                           |                                         */
/*                              |    ,%utl_varlist(                             |                                         */
/*                              |        sd1.have                               |                                         */
/*                              |       ,od=%str(,))||' char(8)')               |                                         */
/*                              | into                                          |                                         */
/*                              |   :nams                                       |                                         */
/*                              | from                                          |                                         */
/*                              |   sd1.have(obs=1)                             |                                         */
/*                              | ;                                             |                                         */
/*                              | create                                        |                                         */
/*                              |    table template                             |                                         */
/*                              |       (                                       |                                         */
/*                              |       &nams                                   |                                         */
/*                              |       );                                      |                                         */
/*                              |  create                                       |                                         */
/*                              |    table want as                              |                                         */
/*                              | select                                        |                                         */
/*                              |      *                                        |                                         */
/*                              | from                                          |                                         */
/*                              |      template                                 |                                         */
/*                              | union                                         |                                         */
/*                              |      all                                      |                                         */
/*                              | select                                        |                                         */
/*                              |      *                                        |                                         */
/*                              | from                                          |                                         */
/*                              |      sd1.have                                 |                                         */
/*                              |                                               |                                         */
/*                              |-----------------------------------------------|                                         */
/*                              |                                               |                                         */
/*                              | 8 python sql alias                            |                                         */
/*                              | ==================                            |                                         */
/*                              |                                               |                                         */
/*                              | data _null_;                                  |                                         */
/*                              |   set sd1.have(obs=1);                        |                                         */
/*                              |   array chrs[*] _character_;                  |                                         */
/*                              |   retain sql '                       ';       |                                         */
/*                              |   do i=1 to dim(chrs);                        |                                         */
/*                              |     vv=cats(vname(chrs[i]),'=',chrs[i]);      |                                         */
/*                              |     sql = catx(','                            |                                         */
/*                              |        ,sql,catx(' ',vname(chrs[i]),'as',chrs[|i]));                                    */
/*                              |   end;                                        |                                         */
/*                              |   call symputx('sql',sql);                    |                                         */
/*                              |                                               |                                         */
/*                              | R                                             |                                         */
/*                              | want=pdsql("select &sql from have")           |                                         */
/*                              |                                               |                                         */
/*                              |-----------------------------------------------|                                         */
/*                              |                                               |                                         */
/*                              | 3 PYTHON PANDA LANGUAGE (WEIRD?)              |                                         */
/*                              | =================================             |                                         */
/*                              | NOT LIKE ANY OTHER LANGUAGE?                  |                                         */
/*                              | TOOK ME A LOMG TIME                           |                                         */
/*                              |                                               |                                         */
/*                              | have.columns = have.iloc[0]                   |                                         */
/*                              |                                               |                                         */
/*                              | NEED THIS TO PRINT HEADINGS?                  |                                         */
/*                              | have = have.reset_index(drop=False)           |                                         */
/*                              | print(have)                                   |                                         */
/*                              |                                               |                                         */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
input (a b c) (3*$2.);
cards4;
X Y Z
1 4 7
2 5 8
3 6 9
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  A    B    C                                                                                                           */
/*                                                                                                                        */
/*  X    Y    Z                                                                                                           */
/*  1    4    7                                                                                                           */
/*  2    5    8                                                                                                           */
/*  3    6    9                                                                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                                             _       _                 _
/ |  ___  __ _ ___   _ __  _ __ ___   ___   __| | __ _| |_ __ _ ___  ___| |_ ___
| | / __|/ _` / __| | `_ \| `__/ _ \ / __| / _` |/ _` | __/ _` / __|/ _ \ __/ __|
| | \__ \ (_| \__ \ | |_) | | | (_) | (__ | (_| | (_| | || (_| \__ \  __/ |_\__ \
|_| |___/\__,_|___/ | .__/|_|  \___/ \___| \__,_|\__,_|\__\__,_|___/\___|\__|___/
                    |_|
*/

* REPEAT SO YOU CAN RERUN;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
input (a b c) (3*$2.);
cards4;
X Y Z
1 4 7
2 5 8
3 6 9
;;;;
run;quit;

* PROCESS ;

* CREATE MACRO VARIABLE NAMS WITH NAMS=X Y Z;

data _null_;
  set sd1.have(obs=1);
  array chrs[*] _character_;
  call symputx('nams',catx(' ',of chrs[*]));
run;quit;

* CREATE MACRO VARIABLE
   RENAM WITH RENAM=A = X  B = Y  C = Z;

%let renam =
  %utl_renamel(%utl_varlist(sd1.have),&nams);

* RENAME COLUMNS;

proc datasets lib=sd1 nolist nodetails;
  modify have;
     rename
         &renam
;run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*    X    Y    Z                                                                                                         */
/*                                                                                                                        */
/*    X    Y    Z                                                                                                         */
/*    1    4    7                                                                                                         */
/*    2    5    8                                                                                                         */
/*    3    6    9                                                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                     _                                   __                  _   _
|___ \   _ __    ___ ___ | |_ __   __ _ _ __ ___   ___  ___  / _|_   _ _ __   ___| |_(_) ___  _ __
  __) | | `__|  / __/ _ \| | `_ \ / _` | `_ ` _ \ / _ \/ __|| |_| | | | `_ \ / __| __| |/ _ \| `_ \
 / __/  | |    | (_| (_) | | | | | (_| | | | | | |  __/\__ \|  _| |_| | | | | (__| |_| | (_) | | | |
|_____| |_|     \___\___/|_|_| |_|\__,_|_| |_| |_|\___||___/|_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|
*/

* REPEAT SO YOU CAN RERUN;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
input (a b c) (3*$2.);
cards4;
X Y Z
1 4 7
2 5 8
3 6 9
;;;;
run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
colnames(have)<-have[1,];
have;
fn_tosas9x(
      inp    = have
     ,outlib ="d:/sd1/"
     ,outdsn ="rrwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rrwant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*     X     Y     Z         ROWNAMES    X    Y    Z                                                                      */
/*                                                                                                                        */
/*   1 X     Y     Z             1       X    Y    Z                                                                      */
/*   2 1     4     7             2       1    4    7                                                                      */
/*   3 2     5     8             3       2    5    8                                                                      */
/*   4 3     6     9             4       3    6    9                                                                      */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____               _   _                                         _
|___ /   _ __  _   _| |_| |__   ___  _ __    _ __   __ _ _ __   __| | __ _
  |_ \  | `_ \| | | | __| `_ \ / _ \| `_ \  | `_ \ / _` | `_ \ / _` |/ _` |
 ___) | | |_) | |_| | |_| | | | (_) | | | | | |_) | (_| | | | | (_| | (_| |
|____/  | .__/ \__, |\__|_| |_|\___/|_| |_| | .__/ \__,_|_| |_|\__,_|\__,_|
        |_|    |___/                        |_|
*/

* REPEAT SO YOU CAN RERUN;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
input (a b c) (3*$2.);
cards4;
X Y Z
1 4 7
2 5 8
3 6 9
;;;;
run;quit;

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
# Set the column names using the first row
have.columns = have.iloc[0]
have.info()
have = have.reset_index(drop=False)
print(have)
have.info()
fn_tosas9x(have,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx(resolve=Y);

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                     |                                                                                                  */
/* Python              |SAS                                                                                               */
/*                     |                                                                                                  */
/* 0  index  X  Y  Z   |INDEX    X    Y    Z                                                                              */
/*                     |                                                                                                  */
/* 0      0  X  Y  Z   |  0      X    Y    Z                                                                              */
/* 1      1  1  4  7   |  1      1    4    7                                                                              */
/* 2      2  2  5  8   |  2      2    5    8                                                                              */
/* 3      3  3  6  9   |  3      3    6    9                                                                              */
/*                     |                                                                                                  */
/**************************************************************************************************************************/

/*  _                               _  _                       _       _
| || |    ___  __ _ ___   ___  __ _| || |_ ___ _ __ ___  _ __ | | __ _| |_ ___
| || |_  / __|/ _` / __| / __|/ _` | || __/ _ \ `_ ` _ \| `_ \| |/ _` | __/ _ \
|__   _| \__ \ (_| \__ \ \__ \ (_| | || ||  __/ | | | | | |_) | | (_| | ||  __/
   |_|   |___/\__,_|___/ |___/\__, |_| \__\___|_| |_| |_| .__/|_|\__,_|\__\___|
                                 |_|                    |_|
*/

proc datasets lib=work nodetails nolist;delete want;run;quit;

%symdel names / nowarn;

proc sql;
  select
    catx(' char(8) ,'
    ,%utl_varlist(
         sd1.have
        ,od=%str(,))||' char(8)')
  into
    :nams
  from
    sd1.have(obs=1)
  ;
  create
     table template
        (
        &nams
        );
   create
      table want as
   select
        *
   from
        template
   union
        all
   select
        *
   from
        sd1.have
;quit;

proc print data=want;
run;quit;

/**************************************************************************************************************************/
/* SAME OUTPUT                                                                                                            */
/**************************************************************************************************************************/

/*___
| ___|   ___  __ _ ___   _ __ ___ _ __   __ _ _ __ ___   ___   _ __ ___   __ _  ___ _ __ ___
|___ \  / __|/ _` / __| | `__/ _ \ `_ \ / _` | `_ ` _ \ / _ \ | `_ ` _ \ / _` |/ __| `__/ _ \
 ___) | \__ \ (_| \__ \ | | |  __/ | | | (_| | | | | | |  __/ | | | | | | (_| | (__| | | (_) |
|____/  |___/\__,_|___/ |_|  \___|_| |_|\__,_|_| |_| |_|\___| |_| |_| |_|\__,_|\___|_|  \___/
*/

proc datasets lib=work nodetails nolist;delete want;run;quit;

%symdel nams / nowarn;

proc sql;
  select
    catx(' ',
      %utl_varlist(
         sd1.have,od=%str(,))
      )
  into
    :nams
  from
    sd1.have(obs=1)
  ;
  /*--  names = X Y Z --*/
  select
    *
  from
    sd1.have
    (rename=
     (
       %utl_renamel
        (
         old=%utl_varlist(sd1.have)
        ,new=&nams
        )
     )
    )
;quit;

proc print data=want;
run;quit;

/*__                               _         _ _
 / /_    ___  __ _ ___   ___  __ _| |   __ _| (_) __ _ ___
| `_ \  / __|/ _` / __| / __|/ _` | |  / _` | | |/ _` / __|
| (_) | \__ \ (_| \__ \ \__ \ (_| | | | (_| | | | (_| \__ \
 \___/  |___/\__,_|___/ |___/\__, |_|  \__,_|_|_|\__,_|___/
                                |_|
*/

%symdel sql / nowarn; /*-- only for development? --*/

data _null_;
  set sd1.have(obs=1);
  array chrs[*] _character_;
  retain sql '                       ';
  do i=1 to dim(chrs);
    vv=cats(vname(chrs[i]),'=',chrs[i]);
    sql = catx(',',sql,catx(' ',vname(chrs[i]),'as',chrs[i]));
  end;
  call symputx('sql',sql);
run;quit;

%put &sql;

proc sql;
   create
      table want as
   select
      &sql
   from
      sd1.have
;quit;

proc print data=want;
run;quit;

/*____                    _         _ _
|___  |  _ __   ___  __ _| |   __ _| (_) __ _ ___
   / /  | `__| / __|/ _` | |  / _` | | |/ _` / __|
  / /   | |    \__ \ (_| | | | (_| | | | (_| \__ \
 /_/    |_|    |___/\__, |_|  \__,_|_|_|\__,_|___/
                       |_|
*/

%symdel sql / nowarn; /*-- only for development? --*/

/*-- create code for sqllite          --*/
/*-- easy to write r code to do this  --*/
data _null_;
  set sd1.have(obs=1);
  array chrs[*] _character_;
  retain sql '                       ';
  do i=1 to dim(chrs);
    vv=cats(vname(chrs[i]),'=',chrs[i]);
    sql = catx(','
       ,sql,catx(' '
       ,vname(chrs[i]),'as',chrs[i]));
  end;
  call symputx('sql',sql);
run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
want <- sqldf("
    select
       &sql
    from
       have
    ")
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rwant;
run;quit;

/**************************************************************************************************************************/
/*              |                                                                                                         */
/*   > want     |                                                                                                         */
/*              |                                                                                                         */
/*     X Y Z    | ROWNAMES    X    Y    Z                                                                                 */
/*              |                                                                                                         */
/*   1 X Y Z    |     1       X    Y    Z                                                                                 */
/*   2 1 4 7    |     2       1    4    7                                                                                 */
/*   3 2 5 8    |     3       2    5    8                                                                                 */
/*   4 3 6 9    |     4       3    6    9                                                                                 */
/*              |                                                                                                         */
/**************************************************************************************************************************/

/*___                _   _                             _         _ _
 ( _ )   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |   __ _| (_) __ _ ___
 / _ \  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |  / _` | | |/ _` / __|
| (_) | | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | | | (_| | | | (_| \__ \
 \___/  | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|  \__,_|_|_|\__,_|___/
        |_|    |___/                                |_|
*/

%symdel sql / nowarn; /*-- only for development? --*/

/*-- create code for sqllite          --*/
/*-- easy to write r code to do this  --*/
data _null_;
  set sd1.have(obs=1);
  array chrs[*] _character_;
  retain sql '                       ';
  do i=1 to dim(chrs);
    vv=cats(vname(chrs[i]),'=',chrs[i]);
    sql = catx(','
       ,sql,catx(' ',vname(chrs[i]),'as',chrs[i]));
  end;
  call symputx('sql',sql);
run;quit;

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
want=pdsql("select &sql from have")
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx(resolve=Y);

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                   |                                                                                                    */
/*     X  Y  Z    X  |  Y    Z                                                                                            */
/*                   |                                                                                                    */
/*  0  X  Y  Z    X  |  Y    Z                                                                                            */
/*  1  1  4  7    1  |  4    7                                                                                            */
/*  2  2  5  8    2  |  5    8                                                                                            */
/*  3  3  6  9    3  |  6    9                                                                                            */
/*                   |                                                                                                    */
/**************************************************************************************************************************/


%macro utl_renamel ( old , new ) ;
    /* Take two cordinated lists &old and &new and  */
    /* return another list of corresponding pairs   */
    /* separated by equal sign for use in a rename  */
    /* statement or data set option.                */
    /*                                              */
    /*  usage:                                      */
    /*    rename = (%renamel(old=A B C, new=X Y Z)) */
    /*    rename %renamel(old=A B C, new=X Y Z);    */
    /*                                              */
    /* Ref: Ian Whitlock <whitloi1@westat.com>      */

    %local i u v warn ;
    %let warn = Warning: RENAMEL old and new lists ;
    %let i = 1 ;
    %let u = %scan ( &old , &i ) ;
    %let v = %scan ( &new , &i ) ;
    %do %while ( %quote(&u)^=%str() and %quote(&v)^=%str() ) ;
        &u = &v
        %let i = %eval ( &i + 1 ) ;
        %let u = %scan ( &old , &i ) ;
        %let v = %scan ( &new , &i ) ;
    %end ;

    %if (null&u ^= null&v) %then
        %put &warn do not have same number of elements. ;

%mend  utl_renamel ;


/************************************************************
         Name: VarList.sas
         Type: Macro function
  Description: Returns variable list from table
   Parameters:
           Data       - Name of table <libname.>memname
           Keep=      - variables to keep
           Drop=      - variables to drop
           Qstyle=    - Quote style:
                          DOUBLE is like "Name" "Sex" "Weight"...
                          SAS is like 'Name'n 'Sex'n 'Weight'n...
                          Anything else is like Name Sex Weight...
           Od=%str( ) - Output delimiter
           prx=       - PRX expression
       Notes: An error provokes %ABORT CANCEL
    Examples:
           %put %varlist(sashelp.class,keep=_numeric_);
           %put %varlist(sashelp.class,qstyle=sas);
           %put %varlist(sashelp.class,qstyle=DOUBLE,od=%str(,));
           %put %varlist(sashelp.class,prx=/ei/i);
           %put %varlist(sashelp.class,prx=funky error); %* provokes error;

   Author: Søren Lassen, s.lassen@post.tele.dk
 **************************************************************/
 %macro utl_varlist(data,keep=,drop=,qstyle=,od=%str( ),prx=);
   %local dsid1 dsid2 i w rc error prxid prxmatch od2;

  %let qstyle=%upcase(&qstyle);

  %let dsid1=%sysfunc(open(&data));
   %if &dsid1=0 %then %do;
     %let error=1;
     %goto done;
     %end;

  %let dsid2=%sysfunc(open(&data(keep=&keep drop=&drop)));
   %if &dsid2=0 %then %do;
     %let error=1;
     %goto done;
     %end;

  %if %length(&prx) %then %do;
     %let prxid=%sysfunc(prxparse(&prx));
     %if &prxid=. %then %do;
       %let prxid=;
       %let error=1;
       %goto done;
       %end;
     %end;
   %else %let prxmatch=1;

  %do i=1 %to %sysfunc(attrn(&dsid1,NVARS));
     %let w=%qsysfunc(varname(&dsid1,&i));
     %if %sysfunc(varnum(&dsid2,&w)) %then %do;
       %if 0&prxid %then
         %let prxmatch=%sysfunc(prxmatch(&prxid,&w));
       %if &prxmatch %then %do;
         %if SAS=&qstyle %then
           %do;&od2.%str(%')%qsysfunc(tranwrd(&w,%str(%'),''))%str(%')n%end;
         %else %if DOUBLE=&qstyle %then
           %do;%unquote(&od2.%qsysfunc(quote(&w)))%end;
         %else
           %do;&od2.&w%end;
         %let od2=&od;
         %end;
       %end;
     %end;

%done:
   %if 0&dsid1 %then
     %let rc=%sysfunc(close(&dsid1));
   %if 0&dsid2 %then
     %let rc=%sysfunc(close(&dsid2));
   %if 0&prxid %then
     %syscall prxfree(prxid);
   %if 0&error %then %do;
     %put %sysfunc(sysmsg());
     %abort cancel;
     %end;

%mend utl_varlist;

/*___                   _
 / _ \   _ __ ___   ___| |_ __ _   _ __ ___   __ _  ___ _ __ ___  ___
| (_) | | `_ ` _ \ / _ \ __/ _` | | `_ ` _ \ / _` |/ __| `__/ _ \/ __|
 \__, | | | | | | |  __/ || (_| | | | | | | | (_| | (__| | | (_) \__ \
   /_/  |_| |_| |_|\___|\__\__,_| |_| |_| |_|\__,_|\___|_|  \___/|___/
                                     _
 _ __ ___ _ __   __ _ _ __ ___   ___| |
| `__/ _ \ `_ \ / _` | `_ ` _ \ / _ \ |
| | |  __/ | | | (_| | | | | | |  __/ |
|_|  \___|_| |_|\__,_|_| |_| |_|\___|_|

*/



%macro utl_renamel ( old , new ) ;
    /* Take two cordinated lists &old and &new and  */
    /* return another list of corresponding pairs   */
    /* separated by equal sign for use in a rename  */
    /* statement or data set option.                */
    /*                                              */
    /*  usage:                                      */
    /*    rename = (%renamel(old=A B C, new=X Y Z)) */
    /*    rename %renamel(old=A B C, new=X Y Z);    */
    /*                                              */
    /* Ref: Ian Whitlock <whitloi1@westat.com>      */

    %local i u v warn ;
    %let warn = Warning: RENAMEL old and new lists ;
    %let i = 1 ;
    %let u = %scan ( &old , &i ) ;
    %let v = %scan ( &new , &i ) ;
    %do %while ( %quote(&u)^=%str() and %quote(&v)^=%str() ) ;
        &u = &v
        %let i = %eval ( &i + 1 ) ;
        %let u = %scan ( &old , &i ) ;
        %let v = %scan ( &new , &i ) ;
    %end ;

    %if (null&u ^= null&v) %then
        %put &warn do not have same number of elements. ;

%mend  utl_renamel ;

/*               _ _     _
__   ____ _ _ __| (_)___| |_
\ \ / / _` | `__| | / __| __|
 \ V / (_| | |  | | \__ \ |_
  \_/ \__,_|_|  |_|_|___/\__|

*/

/************************************************************
         Name: VarList.sas
         Type: Macro function
  Description: Returns variable list from table
   Parameters:
           Data       - Name of table <libname.>memname
           Keep=      - variables to keep
           Drop=      - variables to drop
           Qstyle=    - Quote style:
                          DOUBLE is like "Name" "Sex" "Weight"...
                          SAS is like 'Name'n 'Sex'n 'Weight'n...
                          Anything else is like Name Sex Weight...
           Od=%str( ) - Output delimiter
           prx=       - PRX expression
       Notes: An error provokes %ABORT CANCEL
    Examples:
           %put %varlist(sashelp.class,keep=_numeric_);
           %put %varlist(sashelp.class,qstyle=sas);
           %put %varlist(sashelp.class,qstyle=DOUBLE,od=%str(,));
           %put %varlist(sashelp.class,prx=/ei/i);
           %put %varlist(sashelp.class,prx=funky error); %* provokes error;

   Author: Søren Lassen, s.lassen@post.tele.dk
 **************************************************************/
 %macro utl_varlist(data,keep=,drop=,qstyle=,od=%str( ),prx=);
   %local dsid1 dsid2 i w rc error prxid prxmatch od2;

  %let qstyle=%upcase(&qstyle);

  %let dsid1=%sysfunc(open(&data));
   %if &dsid1=0 %then %do;
     %let error=1;
     %goto done;
     %end;

  %let dsid2=%sysfunc(open(&data(keep=&keep drop=&drop)));
   %if &dsid2=0 %then %do;
     %let error=1;
     %goto done;
     %end;

  %if %length(&prx) %then %do;
     %let prxid=%sysfunc(prxparse(&prx));
     %if &prxid=. %then %do;
       %let prxid=;
       %let error=1;
       %goto done;
       %end;
     %end;
   %else %let prxmatch=1;

  %do i=1 %to %sysfunc(attrn(&dsid1,NVARS));
     %let w=%qsysfunc(varname(&dsid1,&i));
     %if %sysfunc(varnum(&dsid2,&w)) %then %do;
       %if 0&prxid %then
         %let prxmatch=%sysfunc(prxmatch(&prxid,&w));
       %if &prxmatch %then %do;
         %if SAS=&qstyle %then
           %do;&od2.%str(%')%qsysfunc(tranwrd(&w,%str(%'),''))%str(%')n%end;
         %else %if DOUBLE=&qstyle %then
           %do;%unquote(&od2.%qsysfunc(quote(&w)))%end;
         %else
           %do;&od2.&w%end;
         %let od2=&od;
         %end;
       %end;
     %end;

%done:
   %if 0&dsid1 %then
     %let rc=%sysfunc(close(&dsid1));
   %if 0&dsid2 %then
     %let rc=%sysfunc(close(&dsid2));
   %if 0&prxid %then
     %syscall prxfree(prxid);
   %if 0&error %then %do;
     %put %sysfunc(sysmsg());
     %abort cancel;
     %end;

%mend utl_varlist;


/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
