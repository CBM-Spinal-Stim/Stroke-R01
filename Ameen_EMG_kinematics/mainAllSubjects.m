configPath = 'Y:\LabMembers\MTillman\GitRepos\Stroke-R01\Ameen_EMG_kinematics\config.json';
config = jsondecode(fileread(configPath));

subjectRegex = [config.REGEXS.SUBJECT_ID '\>']; % \> is for the end of a word, to avoid returning "SS14_" folder

subjectFolder = config.PATHS.ROOT_LOAD;
dirItems = dir(subjectFolder); % Get all items in subject data directory

% Get the directory names
dirNames = {dirItems([dirItems.isdir]).name};
dirNames = dirNames(~ismember(dirNames, {'.', '..'}));

allSubjects = {};
for i = 1:length(dirNames)
    if regexp(dirNames{i}, subjectRegex)
        allSubjects = [allSubjects; dirNames{i}];
    end
end

% Remove unwanted subjects
% 8, 9, 10 are the ones with muscle renamings needed. CHECK THE MUSCLES
% WITH OTHER SUBJECTS!
subjectsToRemove = {'SS27'};
allSubjects(ismember(allSubjects, subjectsToRemove)) = [];

% Subjects to redo
subjectsToRedo = allSubjects;
subjectsToRedo(ismember(subjectsToRedo, {'SS01', 'SS02','SS03','SS04','SS05','SS06','SS08','SS09','SS10','SS13','SS18','SS20'})) = [];

%% Iterate over each subject
doPlot = false;
for subNum = 1:length(allSubjects)
    subject = allSubjects{subNum};    
    subjectSavePath = fullfile(config.PATHS.ROOT_SAVE, subject, [subject '_' config.PATHS.SAVE_FILE_NAME]);
    if isfile(subjectSavePath) && ~ismember(subject, subjectsToRedo)
        disp(['Skipping subject (' num2str(subNum) '/' num2str(length(allSubjects)) '): ' subject]);
        continue; % Skip the subjects that have already been done.
    end
    disp(['Now running subject (' num2str(subNum) '/' num2str(length(allSubjects)) '): ' subject]);
    mainOneSubject; % Run the main pipeline.
end

%% Combine all of the tables for all subjects into one main table
% 1. Scalar values only
% 2. Visit, trial, and gait cycle level
% 3. Split the name column by underscores, one column per part of the name
pathTemplate = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\{subject}\{subject}_Overground_EMG_Kinematics.mat';
colsToConvertToNumeric = {'Trial','Cycle'};
grColsToConvertToNumeric = {'Trial','GaitRiteRow'};
trialColToConvertToNumeric = {'Trial'};
splitNameColumns.trialTable = {'Subject','Intervention','PrePost','Speed', 'Trial'};
splitNameColumns.cycleTableContraRemoved = {'Subject','Intervention','PrePost','Speed', 'Trial', 'Cycle', 'Side'};
splitNameColumns.prePostCycleChangeTable = {'Subject','Intervention','Speed', 'Trial', 'Cycle', 'Side'};
splitNameColumns.matchedCycleTable = splitNameColumns.cycleTableContraRemoved;
splitNameColumns.prePostChangeMatchedCycleTable = splitNameColumns.prePostCycleChangeTable;
splitNameColumns.grDistributedTable = {'Subject','Intervention','PrePost','Speed', 'Trial', 'GaitRiteRow', 'Side'};
splitNameColumns.prePostChangeGRDistributedTable = {'Subject','Intervention','Speed', 'Trial', 'GaitRiteRow', 'Side'};
splitNameColumns.grSymTable = splitNameColumns.grDistributedTable;
splitNameColumns.prePostGRSymTable = splitNameColumns.prePostChangeGRDistributedTable;

% trialTable
trialTableAll = combineSubjectTables(allSubjects, pathTemplate, 'trialTable', splitNameColumns.trialTable, trialColToConvertToNumeric);
% cycleTableContraRemoved
cycleTableContraRemovedTableAll = combineSubjectTables(allSubjects, pathTemplate, 'cycleTableContraRemoved', splitNameColumns.cycleTableContraRemoved, colsToConvertToNumeric);
% prePostCycleChangeTable
prePostCycleChangeTableAll = combineSubjectTables(allSubjects, pathTemplate, 'prePostCycleChangeTable', splitNameColumns.prePostCycleChangeTable, colsToConvertToNumeric);
% matchedCycleTable
matchedCycleTableAll = combineSubjectTables(allSubjects, pathTemplate, 'matchedCycleTable', splitNameColumns.matchedCycleTable, colsToConvertToNumeric);
% prePostChangeMatchedCycleTable
prePostChangeMatchedCycleTableAll = combineSubjectTables(allSubjects, pathTemplate, 'prePostChangeMatchedCycleTable', splitNameColumns.prePostChangeMatchedCycleTable, colsToConvertToNumeric);
% grDistributedTable
grDistributedTableAll = combineSubjectTables(allSubjects, pathTemplate, 'grDistributedTable', splitNameColumns.grDistributedTable, grColsToConvertToNumeric);
% prePostChangeGRDistributedTable
prePostChangeGRDistributedTableAll = combineSubjectTables(allSubjects, pathTemplate, 'prePostChangeGRDistributedTable', splitNameColumns.prePostChangeGRDistributedTable, grColsToConvertToNumeric);
% grSymTable
grSymTableAll = combineSubjectTables(allSubjects, pathTemplate, 'grSymTable', splitNameColumns.grSymTable, grColsToConvertToNumeric);
% prePostGRSymTable
prePostGRSymTableAll = combineSubjectTables(allSubjects, pathTemplate, 'prePostGRSymTable', splitNameColumns.prePostGRSymTable, grColsToConvertToNumeric);

%% Write the tables to file.
tablesPathPrefixUnmerged = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\Overground_EMG_Kinematics\UnmergedTables';
% trialTableAll
writetable(trialTableAll, fullfile(tablesPathPrefixUnmerged, 'trialTableAll.csv'));
% cycleTableContraRemoved
writetable(cycleTableContraRemovedTableAll, fullfile(tablesPathPrefixUnmerged, 'cycleTableContraRemoved.csv'));
% prePostCycleChangeTable
writetable(prePostCycleChangeTableAll, fullfile(tablesPathPrefixUnmerged, 'prePostCycleChangeTable.csv'));
% matchedCycleTable
writetable(matchedCycleTableAll, fullfile(tablesPathPrefixUnmerged, 'matchedCycleTable.csv'));
% prePostChangeMatchedCycleTable
writetable(prePostChangeMatchedCycleTableAll, fullfile(tablesPathPrefixUnmerged, 'prePostChangeMatchedCycleTable.csv'));
% grDistributedTable
writetable(grDistributedTableAll, fullfile(tablesPathPrefixUnmerged, 'grDistributedTable.csv'));
% prePostChangeGRDistributedTable
writetable(prePostChangeGRDistributedTableAll, fullfile(tablesPathPrefixUnmerged, 'prePostChangeGRDistributedTable.csv'));
% grSymTable
writetable(grSymTableAll, fullfile(tablesPathPrefixUnmerged, 'grSymTable.csv'));
% prePostGRSymTable
writetable(prePostGRSymTableAll, fullfile(tablesPathPrefixUnmerged, 'prePostGRSymTable.csv'));

%% Merge the tables that can be merged.
colNamesToMergeBy = {'GaitRiteRow', 'Cycle'};
mergedMatchedCycleTable = mergeTables(grSymTableAll, matchedCycleTableAll, colNamesToMergeBy);
mergedPrePostMatchedCycleTable = mergeTables(prePostGRSymTableAll, prePostChangeMatchedCycleTableAll, colNamesToMergeBy);
mergedUnmatchedCycleTable = mergeTables(grDistributedTableAll, cycleTableContraRemovedTableAll, colNamesToMergeBy);
mergedPrePostUnmatchedCycleTable = mergeTables(prePostChangeGRDistributedTableAll, prePostCycleChangeTableAll, colNamesToMergeBy);

%% Add session number
tepsLogPath = 'Y:\Spinal Stim_Stroke R01\AIM 1\Subject Data\TEPs_log.xlsx';
tepsLog = readExcelFileOneSheet(tepsLogPath, 'Subject','Sheet1');
allColNames = tepsLog.Properties.VariableNames;
colNames = {'Subject', 'SessionOrder', 'SessionCode'};
colNamesIdx = ismember(allColNames, colNames);
reducedTEPsLog = unique(tepsLog(:, colNamesIdx), 'rows');
for i = 1:height(reducedTEPsLog)
    reducedTEPsLog.Subject{i} = ['SS' reducedTEPsLog.Subject{i}];
end
% Map the intervention names
mappedInterventions = containers.Map(config.INTERVENTION_FOLDERS, config.MAPPED_INTERVENTION_FIELDS);
reducedTEPsLog.SessionCode = cellfun(@(x) mappedInterventions(x), reducedTEPsLog.SessionCode, 'UniformOutput', false);
sessionOrderColName = 'SessionOrder';
sessionCodeColName = 'SessionCode';
interventionColName = 'Intervention';
trialTableAllSessionNum = addSessionOrder(trialTableAll, reducedTEPsLog, sessionOrderColName, sessionCodeColName, interventionColName, interventionColName);
mergedMatchedCycleTableSessionNum = addSessionOrder(mergedMatchedCycleTable, reducedTEPsLog, sessionOrderColName, sessionCodeColName, interventionColName, interventionColName);
mergedPrePostMatchedCycleTableSessionNum = addSessionOrder(mergedPrePostMatchedCycleTable, reducedTEPsLog, sessionOrderColName, sessionCodeColName, interventionColName, interventionColName);
mergedUnmatchedCycleTableSessionNum = addSessionOrder(mergedUnmatchedCycleTable, reducedTEPsLog, sessionOrderColName, sessionCodeColName, interventionColName, interventionColName);
mergedPrePostUnmatchedCycleTableSessionNum = addSessionOrder(mergedPrePostUnmatchedCycleTable, reducedTEPsLog, sessionOrderColName, sessionCodeColName, interventionColName, interventionColName);

%% Save the merged tables
tablesPathPrefixMerged = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\Overground_EMG_Kinematics\MergedTables';
writetable(trialTableAllSessionNum, fullfile(tablesPathPrefixMerged, 'trialTableAll.csv'));
writetable(mergedMatchedCycleTableSessionNum, fullfile(tablesPathPrefixMerged, 'matchedCycles.csv'));
writetable(mergedPrePostMatchedCycleTableSessionNum, fullfile(tablesPathPrefixMerged, 'matchedCyclesPrePost.csv'));
writetable(mergedUnmatchedCycleTableSessionNum, fullfile(tablesPathPrefixMerged, 'unmatchedCycles.csv'));
writetable(mergedPrePostUnmatchedCycleTableSessionNum, fullfile(tablesPathPrefixMerged, 'unmatchedCyclesPrePost.csv'));

%% Adjust the L & R sides to "U" and "A" for unaffected and affected sides
tepsLogPath = 'Y:\Spinal Stim_Stroke R01\AIM 1\Subject Data\TEPs_log.xlsx';
tepsLog = readExcelFileOneSheet(tepsLogPath, 'Subject','Sheet1');
colNames = {'Subject','PareticSide'};
inputTableSideCol = 'Side';
tepsLogSideCol = 'PareticSide';
allColNames = tepsLog.Properties.VariableNames;
colNamesIdx = ismember(allColNames, colNames);
reducedTEPsLog = unique(tepsLog(:, colNamesIdx), 'rows');
for i = 1:height(reducedTEPsLog)
    reducedTEPsLog.Subject{i} = ['SS' reducedTEPsLog.Subject{i}];
end
mergedMatchedCycleTableUA = convertLeftRightSideToAffectedUnaffected(mergedMatchedCycleTableSessionNum, reducedTEPsLog, inputTableSideCol, tepsLogSideCol);
mergedPrePostMatchedCycleTableUA = convertLeftRightSideToAffectedUnaffected(mergedPrePostMatchedCycleTableSessionNum, reducedTEPsLog, inputTableSideCol, tepsLogSideCol);
mergedUnmatchedCycleTableUA = convertLeftRightSideToAffectedUnaffected(mergedUnmatchedCycleTableSessionNum, reducedTEPsLog, inputTableSideCol, tepsLogSideCol);
mergedPrePostUnmatchedCycleTableUA = convertLeftRightSideToAffectedUnaffected(mergedPrePostUnmatchedCycleTableSessionNum, reducedTEPsLog, inputTableSideCol, tepsLogSideCol);

%% Save the unaffected and affected side tables
tablesPathPrefixMergedUA = 'Y:\LabMembers\MTillman\SavedOutcomes\StrokeSpinalStim\Overground_EMG_Kinematics\MergedTablesAffectedUnaffected';
writetable(trialTableAllSessionNum, fullfile(tablesPathPrefixMergedUA, 'trialTableAll.csv'));
writetable(mergedMatchedCycleTableUA, fullfile(tablesPathPrefixMergedUA, 'matchedCycles.csv'));
writetable(mergedPrePostMatchedCycleTableUA, fullfile(tablesPathPrefixMergedUA, 'matchedCyclesPrePost.csv'));
writetable(mergedUnmatchedCycleTableUA, fullfile(tablesPathPrefixMergedUA, 'unmatchedCycles.csv'));
writetable(mergedPrePostUnmatchedCycleTableUA, fullfile(tablesPathPrefixMergedUA, 'unmatchedCyclesPrePost.csv'));

%% Widen the unaffected and affected side tables
inputTableSideCol = 'Side';
mergedMatchedCycleTableUAWide = widenTableBySides(mergedMatchedCycleTableUA, inputTableSideCol);