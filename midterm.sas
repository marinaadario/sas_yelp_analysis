
/*import data*/

FILENAME REFFILE "/folders/myfolders/sasuser.v94/midterm.csv" TERMSTR=CR;

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.MIDTERM;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.MIDTERM; RUN;

DATA WORK.RESTAURANTS;
	SET WORK.MIDTERM;
	where categories contains 'Restaurants';
	RUN;


/*descriptive statistics about rating*/

PROC UNIVARIATE DATA=WORK.RESTAURANTS;
	VAR stars;
RUN;

/*How does the ambience of a restaurant
affect its rating?*/

/*create dummy variables
for the categirocal variables*/

%LET Var = attributes_Ambience_casual;
%LET Var = attributes_Ambience_classy;
%LET Var = attributes_Ambience_hipster;
%LET Var = attributes_Ambience_intimate;
%LET Var = attributes_Ambience_romantic;
%LET Var = attributes_Ambience_touristy;
%LET Var = attributes_Ambience_trendy;
%LET Var = attributes_Ambience_upscale;

%LET DummyVar = CasualAmbience;
%LET DummyVar = ClassyAmbience;
%LET DummyVar = HipsterAmbience;
%LET DummyVar = IntimateAmbience;
%LET DummyVar = RomanticAmbience;
%LET DummyVar = TouristyAmbience;
%LET DummyVar = TrendyAmbience;
%LET DummyVar = UpscaleAmbience;


%MACRO AMBIENCE(Var, DummyVar);

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;	
	IF &Var = 'TRUE' THEN &DummyVar = 1;
	ELSE &DummyVar = 0;
RUN;

%MEND AMBIENCE;

%AMBIENCE(attributes_Ambience_casual, CasualAmbience);
%AMBIENCE(attributes_Ambience_classy, ClassyAmbience);
%AMBIENCE(attributes_Ambience_hipster, HipsterAmbience);
%AMBIENCE(attributes_Ambience_intimate, IntimateAmbience);
%AMBIENCE(attributes_Ambience_romantic, RomanticAmbience);
%AMBIENCE(attributes_Ambience_touristy, TouristyAmbience);
%AMBIENCE(attributes_Ambience_trendy, TrendyAmbience);
%AMBIENCE(attributes_Ambience_upscale, UpscaleAmbience);
RUN;


/*put them all under one variable for ANOVA and create a bar graph (ANOVA will be done later)*/

PROC FORMAT;
VALUE AmbienceLabel 1 = 'Casual'
			   		2 = 'Classy'
			   		3 = 'Hipster'
			   		4 = 'Intimate'
			   		5 = 'Romantic'
			  		6 = 'Toursty'
			  		7 = 'Trendy'
			  		8 = 'Upscale'
RUN;

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;
	IF CasualAmbience = 1 THEN Ambience = 1;
	IF ClassyAmbience = 1 THEN Ambience = 2;
	IF HipsterAmbience = 1 THEN Ambience = 3;
	IF IntimateAmbience = 1 THEN Ambience = 4;
	IF RomanticAmbience = 1 THEN Ambience = 5;
	IF TouristyAmbience = 1 THEN Ambience = 6;
	IF TrendyAmbience = 1 THEN Ambience = 7;
	IF UpscaleAmbience = 1 THEN Ambience = 8;
	FORMAT Ambience AmbienceLabel.;
RUN;



/*mean ranking for each ambience*/

%LET DummyVar = CasualAmbience;
%LET DummyVar = ClassyAmbience;
%LET DummyVar = HipsterAmbience;
%LET DummyVar = IntimateAmbience;
%LET DummyVar = RomanticAmbience;
%LET DummyVar = TouristyAmbience;
%LET DummyVar = TrendyAmbience;
%LET DummyVar = UpscaleAmbience;

%MACRO AMBIENCE_MEANS(DummyVar);

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where &DummyVar = 1;
RUN;

%MEND AMBIENCE_MEANS;

%AMBIENCE_MEANS(CasualAmbience);
%AMBIENCE_MEANS(ClassyAmbience);
%AMBIENCE_MEANS(HipsterAmbience);
%AMBIENCE_MEANS(IntimateAmbience);
%AMBIENCE_MEANS(RomanticAmbience);
%AMBIENCE_MEANS(TouristyAmbience);
%AMBIENCE_MEANS(TrendyAmbience);
%AMBIENCE_MEANS(UpscaleAmbience);
RUN;

/*bar graph of means*/

PROC SGPLOT DATA=WORK.RESTAURANTS;
	Title "Ambience and Rating";
	VBAR Ambience / RESPONSE=stars fillattrs=(color=lightblue)
		datalabel Stat=Mean Name='Bar';
	xaxis label="Ambience";
	yaxis label="Ranking (stars)" grid;
RUN;

/*ANOVA*/

PROC ANOVA DATA=WORK.RESTAURANTS;
	CLASS Ambience;
	MODEL stars=Ambience;
RUN;

/*There is a difference among group means,
ambience is a significant predictor of raking*/

/*t-tests to determine which ambiences are significant
in predicting ranking*/

%LET DummyVar = CasualAmbience;
%LET DummyVar = ClassyAmbience;
%LET DummyVar = HipsterAmbience;
%LET DummyVar = IntimateAmbience;
%LET DummyVar = RomanticAmbience;
%LET DummyVar = TouristyAmbience;
%LET DummyVar = TrendyAmbience;
%LET DummyVar = UpscaleAmbience;

%MACRO AMBIENCETTEST(DummyVar=);

PROC TTEST DATA=WORK.RESTAURANTS;
	CLASS &DummyVar;
	VAR stars;
RUN;

%MEND AMBIENCETTEST;

%AMBIENCETTEST(CasualAmbience);
%AMBIENCETTEST(ClassyAmbience);
%AMBIENCETTEST(HipsterAmbience);
%AMBIENCETTEST(IntimateAmbience);
%AMBIENCETTEST(RomanticAmbience);
%AMBIENCETTEST(TouristyAmbience);
%AMBIENCETTEST(TrendyAmbience);
%AMBIENCETTEST(UpscaleAmbience);
RUN;

/*Results: Each of these ambiences has an effect
on the ranking of the restaurant. All of them besides
touristy caused the ranking to increase.  Touristy
caused the ranking to decrease.*/


/*I want to see if having any ambience listed vs.
no ambience makes a difference in ranking*/

/*create a new variable for "No Ambience"*/

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;	
	IF 	CasualAmbience = 0 and ClassyAmbience = 0 and
		HipsterAmbience = 0 and IntimateAmbience = 0 and
		RomanticAmbience = 0 and TouristyAmbience = 0 and
		TrendyAmbience = 0 and UpscaleAmbience = 0 
	THEN NoAmbience = 1;
	ELSE NoAmbience = 0;
RUN;

/*ttest*/

PROC TTEST DATA=WORK.RESTAURANTS;
	CLASS NoAmbience;
	VAR stars;
RUN;

/*Results: significant difference*/
	

/*Which places are most popular-
breakfast, brunch, lunch, dinner, or latenight?*/

/*create dummy variables
for the categorical variables*/

%LET Var = attributes_Good_For_breakfast;
%LET Var = attributes_Good_For_brunch;
%LET Var = attributes_Good_For_dessert;
%LET Var = attributes_Good_For_dinner;
%LET Var = attributes_Good_For_latenight;
%LET Var = attributes_Good_For_lunch;

%LET DummyVar = GoodBreakfast;
%LET DummyVar = GoodBrunch;
%LET DummyVar = GoodDessert;
%LET DummyVar = GoodDinner;
%LET DummyVar = GoodLatenight;
%LET DummyVar = GoodLunch;

%MACRO GoodFor(Var, DummyVar);

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;	
	IF &Var = 'TRUE' THEN &DummyVar = 1;
	ELSE &DummyVar = 0;
RUN;

%MEND GoodFor;

%GoodFor(attributes_Good_For_breakfast, GoodBreakfast);
%GoodFor(attributes_Good_For_brunch, GoodBrunch);
%GoodFor(attributes_Good_For_dessert, GoodDessert);
%GoodFor(attributes_Good_For_dinner, GoodDinner);
%GoodFor(attributes_Good_For_latenight, GoodLatenight);
%GoodFor(attributes_Good_For_lunch, GoodLunch);
RUN;

/*put them all under one variable for ANOVA and bar graphs
(ANOVA will be done later)*/

PROC FORMAT;
VALUE GoodForLabel  1 = 'Breakfast'
			   		2 = 'Brunch'
			   		3 = 'Dessert'
			   		4 = 'Dinner'
			   		5 = 'Latenight'
			  		6 = 'Lunch';
RUN;

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;
	IF GoodBreakfast = 1 THEN GoodFor = 1;
	IF GoodBrunch = 1 THEN GoodFor = 2;
	IF GoodDessert = 1 THEN GoodFor = 3;
	IF GoodDinner = 1 THEN GoodFor = 4;
	IF GoodLatenight = 1 THEN GoodFor = 5;
	IF GoodLunch = 1 THEN GoodFor = 6;
	FORMAT GoodFor GoodForLabel.;
RUN;

/*calculate means*/

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where GoodBreakfast = 1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where GoodBrunch = 1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where GoodDessert = 1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where GoodDinner = 1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where GoodLatenight = 1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	where GoodLunch = 1;
RUN;

/*bar graph*/

PROC SGPLOT DATA=WORK.RESTAURANTS;
	Title "'Good For ...' and Ratings";
	VBAR GoodFor / RESPONSE=stars fillattrs=(color=CX00BBBB)
		datalabel Stat=Mean Name='Bar';
	xaxis label="Good For ...";
	yaxis label="Ranking (stars)" grid;
RUN;

/*ANOVA*/

PROC ANOVA DATA=WORK.RESTAURANTS;
	CLASS GoodFor;
	MODEL stars=GoodFor;
RUN;

/*it is a significant predictor*/

/*ttests*/


%LET DummyVar = GoodBreakfast;
%LET DummyVar = GoodBrunch;
%LET DummyVar = GoodDessert;
%LET DummyVar = GoodDinner;
%LET DummyVar = GoodLatenight;
%LET DummyVar = GoodLunch;

%MACRO GOODFORTTEST(DummyVar);

PROC TTEST DATA=WORK.RESTAURANTS;
	CLASS &DummyVar;
	VAR stars;
RUN;

%MEND GOODFORTTEST;

%GOODFORTTEST(GoodBreakfast);
%GOODFORTTEST(GoodBrunch);
%GOODFORTTEST(GoodDessert);
%GOODFORTTEST(GoodDinner);
%GOODFORTTEST(GoodLatenight);
%GOODFORTTEST(GoodLunch);
RUN;

/*see if no "good for" listed vs having a "good for"
listed is significant*/

/*create dummy variable for "No 'Good For'"*/

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;	
	IF 	CasualAmbience = 0 and ClassyAmbience = 0 and
		HipsterAmbience = 0 and IntimateAmbience = 0 and
		RomanticAmbience = 0 and TouristyAmbience = 0 and
		TrendyAmbience = 0 and UpscaleAmbience = 0 
	THEN NoAmbience = 1;
	ELSE NoAmbience = 0;
RUN;

/*ttest*/

PROC TTEST DATA=WORK.RESTAURANTS;
	CLASS NoAmbience;
	VAR stars;
RUN;


/*Does price range affect ranking?*/

/*mean rankings for each price range*/

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE attributes_Price_Range=1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE attributes_Price_Range=2;
RUN; 

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE attributes_Price_Range=3;
RUN; 

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE attributes_Price_Range=4;
RUN;

/*bar graph*/

PROC SGPLOT DATA=WORK.RESTAURANTS;
	Title "Price Range and Rating";
	VBAR attributes_Price_Range / RESPONSE=stars fillattrs=(color=lightgreen)
		datalabel Stat=Mean Name='Bar';
	xaxis label="Price Range";
	yaxis label="Ranking (stars)" grid;
RUN;

/*ANOVA*/	

PROC ANOVA DATA=WORK.RESTAURANTS;
	CLASS attributes_Price_Range;
	MODEL stars = attributes_Price_Range;
RUN;

/*we can conclude that price range does affect ranking*/

/*Does price affect ranking more for some ambiences than others?*/

/*create new data sets for each ambience and run regressions*/

DATA WORK.CasualAmbience;
	SET WORK.RESTAURANTS;	
	where CasualAmbience = 1;
RUN;

PROC REG DATA=WORK.CasualAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.ClassyAmbience;
	SET WORK.RESTAURANTS;	
	where ClassyAmbience = 1;
RUN;

PROC REG DATA=WORK.ClassyAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.HipsterAmbience;
	SET WORK.RESTAURANTS;	
	where HipsterAmbience = 1;
RUN;

PROC REG DATA=WORK.HipsterAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.IntimateAmbience;
	SET WORK.RESTAURANTS;	
	where IntimateAmbience = 1;
RUN;

PROC REG DATA=WORK.IntimateAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.RomanticAmbience;
	SET WORK.RESTAURANTS;	
	where RomanticAmbience = 1;
RUN;

PROC REG DATA=WORK.RomanticAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.TouristyAmbience;
	SET WORK.RESTAURANTS;	
	where TouristyAmbience = 1;
RUN;

PROC REG DATA=WORK.TouristyAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.TrendyAmbience;
	SET WORK.RESTAURANTS;	
	where TrendyAmbience = 1;
RUN;

PROC REG DATA=WORK.TrendyAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.UpscaleAmbience;
	SET WORK.RESTAURANTS;	
	where UpscaleAmbience = 1;
RUN;

PROC REG DATA=WORK.UpscaleAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

/*price does not affect ranking for places with
a romantic, touristy, or trendy ambience*/

/*ordinal logistic regression*/

/*make sure that the "stars" variable is read in the correct order*/
DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;
	IF stars = 1 THEN OrderedStars = 1.0;
	IF stars = 1.5 THEN OrderedStars = 1.5;
	IF stars = 2 THEN OrderedStars = 2.0;
	IF stars = 2.5 THEN OrderedStars = 2.5;
	IF stars = 3 THEN OrderedStars = 3.0;
	IF stars = 3.5 THEN OrderedStars = 3.5;
	IF stars = 4 THEN OrderedStars = 4.0;
	IF stars = 4.5 THEN OrderedStars = 4.5;
	IF stars = 5 THEN OrderedStars = 5.0;
RUN;


PROC LOGISTIC DATA=WORK.RESTAURANTS;
	TITLE "Ordinal Logistic Regression for Price and Ranking";
	MODEL OrderedStars= attributes_Price_Range;
	Label attributes_Price_Range = "Price Range";
	Label OrderedStars = Ranking (Stars);
RUN;


/*graphic describing results of ordinal logistic regression*/

DATA WORK.GRAPHICS;
INPUT pr 1 rating 3-5 odds 7-12;
DATALINES;  
1 1.5 0.018
1 2   0.062
1 2.5 0.189
1 3   0.542
1 3.5 1.733
2 1.5 0.015
2 2   0.052
2 2.5 0.158
2 3   0.452
2 3.5 1.445
3 1.5 0.013
3 2   0.043
3 2.5 0.132
3 3   0.377
3 3.5 1.208
4 1.5 0.011
4 2   0.036
4 2.5 0.1
4 3   0.316
4 3.5 1.001
;
RUN;

PROC SGPLOT DATA=WORK.GRAPHICS;
	VBAR rating / RESPONSE=odds GROUP=pr groupdisplay=Cluster Stat=Mean Name='Bar';
	yaxis grid;
	LABEL pr = "Price Range" rating = "Rating (Stars)" odds = "Odds";
RUN;

/*Ranking increases as price range increases-
more expensive restaurants are more popular*/

/*Does price affect ranking more for some ambiences than others?*/

/*create new data sets for each ambience and run regressions*/

DATA WORK.CasualAmbience;
	SET WORK.RESTAURANTS;	
	where CasualAmbience = 1;
RUN;

PROC REG DATA=WORK.CasualAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.ClassyAmbience;
	SET WORK.RESTAURANTS;	
	where ClassyAmbience = 1;
RUN;

PROC REG DATA=WORK.ClassyAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.HipsterAmbience;
	SET WORK.RESTAURANTS;	
	where HipsterAmbience = 1;
RUN;

PROC REG DATA=WORK.HipsterAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.IntimateAmbience;
	SET WORK.RESTAURANTS;	
	where IntimateAmbience = 1;
RUN;

PROC REG DATA=WORK.IntimateAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.RomanticAmbience;
	SET WORK.RESTAURANTS;	
	where RomanticAmbience = 1;
RUN;

PROC REG DATA=WORK.RomanticAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.TouristyAmbience;
	SET WORK.RESTAURANTS;	
	where TouristyAmbience = 1;
RUN;

PROC REG DATA=WORK.TouristyAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.TrendyAmbience;
	SET WORK.RESTAURANTS;	
	where TrendyAmbience = 1;
RUN;

PROC REG DATA=WORK.TrendyAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

DATA WORK.UpscaleAmbience;
	SET WORK.RESTAURANTS;	
	where UpscaleAmbience = 1;
RUN;

PROC REG DATA=WORK.UpscaleAmbience;
	MODEL stars = attributes_Price_Range;
RUN;

/*price does not affect ranking for places with
a romantic, trendy, or touristy ambience*/



/*Does noise level affect ranking? Does it differ with ambience?*/

/*create one ordinal variable for noise level*/

DATA WORK.RESTAURANTS;
	SET WORK.RESTAURANTS;
	IF attributes_Noise_Level = "quiet" THEN NoiseLevel = 1;
	IF attributes_Noise_Level = "average" THEN NoiseLevel = 2;
	IF attributes_Noise_Level = "loud" THEN NoiseLevel = 3;
	IF attributes_Noise_Level = "very_lo" THEN NoiseLevel = 4;
RUN;

/*mean rankings for each noise level*/

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE NoiseLevel=1;
RUN;

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE NoiseLevel=2;
RUN; 

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE NoiseLevel=3;
RUN; 

PROC MEANS DATA=WORK.RESTAURANTS;
	VAR stars;
	WHERE NoiseLevel=4;
RUN;

/*drastic decrease!!!!*/

/*bar graph*/

PROC SGPLOT DATA=WORK.RESTAURANTS;
	Title "Noise Level and Rating";
	VBAR NoiseLevel / RESPONSE=stars fillattrs=(color=lightblue)
		datalabel stat=Mean name='Bar';
	xaxis label="Noise Level";
	yaxis label="Ranking (stars)" grid;
RUN;
	
/*ANOVA*/

PROC ANOVA DATA=WORK.RESTAURANTS;
	CLASS NoiseLevel;
	MODEL stars=NoiseLevel;
RUN;

/*for different ambiences*/

PROC REG DATA=WORK.CasualAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.ClassyAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.HipsterAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.IntimateAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.RomanticAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.TouristyAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.TrendyAmbience;
	MODEL stars = NoiseLevel;
RUN;

PROC REG DATA=WORK.UpscaleAmbience;
	MODEL stars = NoiseLevel;
RUN;

/*ordinal logistic regression*/

PROC LOGISTIC DATA=WORK.RESTAURANTS;
	TITLE "Ordinal Logistic Regression for Noise Level and Ranking";
	MODEL OrderedStars = NoiseLevel;
	Label attributes_Price_Range = "Price Range";
	Label OrderedStars = Ranking (Stars);
RUN;

/*graphic to show results of the ordinal logistic regression*/

DATA WORK.GRAPHICS2;
INPUT noiselevel 1 rating 3-5 odds 7-12;
DATALINES;  
1 1.5 0.008
1 2   0.029
1 2.5 0.094
1 3   0.29
1 3.5 0.993
2 1.5 0.012
2 2   0.043
2 2.5 0.143
2 3   0.439
2 3.5 1.502
3 1.5 0.018
3 2   0.065
3 2.5 0.216
3 3   0.663
3 3.5 2.27
4 1.5 0.027
4 2   0.099
4 2.5 0.326
4 3   1.002
4 3.5 3.431
;
RUN;

PROC SGPLOT DATA=WORK.GRAPHICS2;
	VBAR rating / RESPONSE=odds GROUP=noiselevel groupdisplay=Cluster Stat=Mean Name='Bar';
	yaxis grid;
	LABEL noiselevel = "Noise Level" rating = "Rating (Stars)" odds = "Odds";
RUN;

