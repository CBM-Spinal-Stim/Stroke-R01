configPath = 'Y:\LabMembers\MTillman\GitRepos\Stroke-R01\Ameen_EMG_kinematics\config.json';
config = jsondecode(fileread(configPath));

subjectRegex = [config.REGEXS.SUBJECT_ID '\>']; % \> is for the end of a word, to avoid returning "SS14_" folder

subjectFolder = config.PATHS.ROOT_LOAD;
dirItems = dir(subjectFolder); % Get all items in subject data directory

% Get the directory names
dirNames = {dirItems([dirItems.isdir]).name};
dirNames = dirNames(~ismember(dirNames, {'.', '..'}));

subjects = {};
for i = 1:length(dirNames)
    if regexp(dirNames{i}, subjectRegex)
        subjects = [subjects; dirNames{i}];
    end
end

% Remove unwanted subjects
% 8, 9, 10 are the ones with muscle renamings needed. CHECK THE MUSCLES
% WITH OTHER SUBJECTS!
subjectsToRemove = {'SS27'};
subjects(ismember(subjects, subjectsToRemove)) = [];

% Subjects to redo
subjectsToRedo = {};

%% Iterate over each subject
doPlot = true;
for subNum = 1:length(subjects)
    subject = subjects{subNum};    
    subjectSavePath = fullfile(config.PATHS.ROOT_SAVE, subject, [subject '_' config.PATHS.SAVE_FILE_NAME]);
    if isfile(subjectSavePath) && ~ismember(subject, subjectsToRedo)
        disp(['Skipping subject (' num2str(subNum) '/' num2str(length(subjects)) '): ' subject]);
        continue; % Skip the subjects that have already been done.
    end
    disp(['Now running subject (' num2str(subNum) '/' num2str(length(subjects)) '): ' subject]);
    mainOneSubject; % Run the main pipeline.
end

%% Combine all of the tables for all subjects into one main table
% 1. Scalar values only
% 2. Visit, trial, and gait cycle level
% 3. Split the name column by underscores, one column per part of the name
splitNameColumnsVisit = {'Subject','Intervention','PrePost','Speed'};
pathTemplate = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\{subject}\{subject}_Overground_EMG_Kinematics.mat';
visitTableAll = combineSubjectTables(subjects, pathTemplate, 'visitTable', splitNameColumnsVisit);
splitNameColumnsTrial = {'Subject','Intervention','PrePost','Speed', 'TrialNum'};
trialTableAll = combineSubjectTables(subjects, pathTemplate, 'trialTable', splitNameColumnsTrial);
splitNameColumnsCycle = {'Subject','Intervention','PrePost', 'Speed', 'TrialNum','CycleNum'};
cycleTableAll = combineSubjectTables(subjects, pathTemplate, 'matchedCycleTable', splitNameColumnsCycle);

%% Write the tables to file.
visitTablePath = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\VisitTable.csv';
writetable(visitTableAll, visitTablePath);
trialTablePath = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\TrialTable.csv';
writetable(trialTableAll, trialTablePath);
cycleTablePath = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\CycleTable.csv';
writetable(cycleTableAll, cycleTablePath);