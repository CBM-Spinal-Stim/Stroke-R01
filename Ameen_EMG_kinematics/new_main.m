%% Created by MT 01/16/25
% The main pipeline for R01 Stroke Spinal Stim Aim 1
clc;
clearvars;
subject = 'SS13';
% Folder to load the data from.
subjectLoadPath = fullfile('Y:\Spinal Stim_Stroke R01\AIM 1\Subject Data', subject);
% Path to save the data to.
subjectSavePath = strcat('Y:\Spinal Stim_Stroke R01\AIM 1\Subject Data\Processed Outcomes\', subject, '_Outcomes.mat');
codeFolderPath = 'Y:\Spinal Stim_Stroke R01\AIM 1\GitRepo\Stroke-R01\Ameen_EMG_kinematics';
addpath(genpath(codeFolderPath));

%% Get configuration
configFilePath = fullfile(codeFolderPath,'config.json');
disp(['Loading configuration from: ' configFilePath])
config = jsondecode(fileread(configFilePath));

intervention_folders = config.INTERVENTION_FOLDERS;
intervention_field_names = config.MAPPED_INTERVENTION_FIELDS;
mapped_interventions = containers.Map(intervention_folders, intervention_field_names);
gaitriteConfig = config.GAITRITE;
delsysConfig = config.DELSYS_EMG;
xsensConfig = config.XSENS;

%% Delsys Processing
disp('Preprocessing Delsys');
subject_delsys_folder = fullfile(subjectLoadPath, delsysConfig.FOLDER_NAME);
% Process each intervention
for i = 1:length(intervention_folders)   
    intervention_folder = intervention_folders{i};        
    intervention_folder_path = fullfile(subject_delsys_folder, intervention_folder);
    intervention_field_name = mapped_interventions(intervention_folder);
    delsys_processed_intervention.(intervention_field_name) = processDelsysEMGOneIntervention(delsysConfig, intervention_folder_path, subject);
end

%% GaitRite Processing
disp('Preprocessing Gaitrite');
subject_gaitrite_folder = fullfile(subjectLoadPath, gaitriteConfig.FOLDER_NAME);
% Process each intervention
for i = 1:length(intervention_folders)
    intervention_folder = intervention_folders{i};    
    intervention_folder_path = fullfile(subject_gaitrite_folder, intervention_folder);
    intervention_field_name = mapped_interventions(intervention_folder);
    gaitrite_processed_intervention.(intervention_field_name) = processGaitRiteOneIntervention(gaitriteConfig, intervention_folder_path);
end

%% XSENS Processing
disp('Preprocessing XSENS');
subject_xsens_folder = fullfile(subjectLoadPath, xsensConfig.FOLDER_NAME);
% Process each intervention
for i = 1:length(intervention_folders)
    intervention_folder = intervention_folders{i};    
    intervention_folder_path = fullfile(subject_xsens_folder, intervention_folder);
    intervention_field_name = mapped_interventions(intervention_folder);
    xsens_processed_intervention.(intervention_field_name) = processXSENSOneIntervention(xsensConfig, intervention_folder_path);
end

%% Time Synchronization
% Get gait event indices, phase durations, etc. in Delsys & XSENS indices
for i = 1:length(intervention_field_names)
    intervention_field_name = intervention_field_names{i};
    trialNames = fieldnames(gaitrite_processed_intervention.(intervention_field_name));
    for trialNum = 1:length(trialNames)
        trialName = trialNames{trialNum};        
        secondsStruct = gaitrite_processed_intervention.(intervention_field_name).(trialName).seconds;
        delsys_processed_intervention.(intervention_field_name).(trialName).frames = getHardwareIndicesFromSeconds(secondsStruct, delsysConfig.SAMPLING_FREQUENCY);
        xsens_processed_intervention.(intervention_field_name).(trialName).frames = getHardwareIndicesFromSeconds(secondsStruct, xsensConfig.SAMPLING_FREQUENCY);          
    end    
end

%% Split Data by Gait Cycle
for i = 1:length(intervention_field_names)
    intervention_field_name = intervention_field_names{i};
    trialNames = fieldnames(gaitrite_processed_intervention.(intervention_field_name));
    for trialNum = 1:length(trialNames)
        trialName = trialNames{trialNum};
        delsysDataStruct = delsys_processed_intervention.(intervention_field_name);
        xsensDataStruct = xsens_processed_intervention.(intervention_field_name);
        delsys_processed_intervention.(intervention_field_name).(trialName).musclesByGaitCycle = splitDelsysTrialByGaitCycle(delsysDataStruct.(trialName).muscles, delsysDataStruct.(trialName).frames.gaitEvents.leftHeelStrikes);
        xsens_processed_intervention.(intervention_field_name).(trialName).jointsByGaitCycle = splitXSENSTrialByGaitCycle(xsensDataStruct.(trialName).joints, xsensDataStruct.(trialName).frames.gaitEvents.leftHeelStrikes);
    end
end

%% Pre-Post Analysis