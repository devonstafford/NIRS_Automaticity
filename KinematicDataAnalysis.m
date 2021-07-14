adaptDataPre=load('/Users/mac/OneDrive - University of Pittsburgh/SML/Projects/fNIR Project/Code_NIRS_Automaticity/data/S04_MarcelaV03params.mat');
adaptDataPre = adaptDataPre.adaptData;
adaptDataPre.plotAvgTimeCourse(adaptDataPre,'netContributionNorm2');
adaptDataPre.plotAvgTimeCourse(adaptDataPre,'singleStanceSpeedFastAbsANK');


adaptDataIntervention=load('/Users/mac/OneDrive - University of Pittsburgh/SML/Projects/fNIR Project/Code_NIRS_Automaticity/data/S04_MarcelaV05params.mat');
adaptDataIntervention = adaptDataIntervention.adaptData;
adaptDataIntervention.plotAvgTimeCourse(adaptDataIntervention,'netContributionNorm2')

