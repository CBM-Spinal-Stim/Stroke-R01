

%%
SUBJ_list = ["01"]%, "01","02", "03", "04", "05", "06"];%, "08", "09", "10"];
TP_list = ["PRE","POST"]; 

INTER_list = ["RMT30", "TOL30", "RMT50", "TOL50", "SHAM1", "SHAM2"]; 
             

%% Read in master TEPs file
% Obtains the bad pulses for each MEP trial. 

aim1_folder = "Y:\Spinal Stim_Stroke R01\AIM 1"; 
subj_path = fullfile(aim1_folder, 'Subject Data');




%% Iterate through the struct saved from B_Smers
max_strutcs = struct();
for SUBJ_i = 1:length(SUBJ_list)
    missingFiles = {};
    SUBJ = SUBJ_list(SUBJ_i);
    subj_path = "Y:\Spinal Stim_Stroke R01\AIM 1\Subject Data\SS" + SUBJ +"\TEPs";
    filename_preprocessed = SUBJ+"_B_TEPs_PulsesFeatsStruct.mat";
    final_path = fullfile(subj_path, filename_preprocessed);
    % Load the struct:
    load(final_path) % ALL_SUBJ_STRUCT
    
    combinedTable = table();
    
    figure;
    
            
    for TP_i = 1: length(TP_list)
            TP = TP_list(TP_i);
            if TP == "PRE"
                subplot_i = 0; % odd side 
            elseif TP == "POST"
                subplot_i = 1; % even side
            end
            
            for INTER_i = 1: length(INTER_list)
                INTER = INTER_list(INTER_i);
            final_muscles_list_fieldNames = fieldnames(ALL_SUBJ_STRUCT.("SS"+SUBJ).(INTER).(TP));
            
            % List to keep track of maxes
            max_p2p_LIST = zeros(1, 10);
            max_AUC_lat_100_LIST= zeros(1, 10);
            max_AUC_lat_pickedEnd_LIST= zeros(1, 10);
            max_AUC_smoothed_LIST= zeros(1, 10);
            
            for mus_i =1: length(final_muscles_list_fieldNames)
                
                
                muscle_channel = final_muscles_list_fieldNames{mus_i}; 
                if muscle_channel == "plotMethod"
                    continue;
                end
                
                P2P_AUC_table = ALL_SUBJ_STRUCT.("SS"+SUBJ).(INTER).(TP).(muscle_channel);
                P2P_AUC_table_MEAN = groupsummary(P2P_AUC_table, {'SUBJ','INTER', 'TP', 'Var4','intensity_value'}, 'mean', {'p2p', 'AUC_lat_100', 'AUC_lat_pickedEnd', ...
                                        'AUC_smoothed', 'latency', 'latency_fromOnset_idx', 'End','sitmIDX_picked','endIDX_picked' }); 
                
                
                
                
                % FINDING MAXIMUMS - TO BE ABLE TO NORMALIZE 
                
                MaxP2P                = max(P2P_AUC_table_MEAN.mean_p2p);
                MaxInt                = max(P2P_AUC_table_MEAN.intensity_value);
                Max_AUC_lat_100       = max(P2P_AUC_table_MEAN.mean_AUC_lat_100);
                Max_AUC_lat_pickedEnd = max(P2P_AUC_table_MEAN.mean_AUC_lat_pickedEnd);
                Max_AUC_smoothed      = max(P2P_AUC_table_MEAN.mean_AUC_smoothed);
                
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).MaxP2P                = MaxP2P;
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).MaxInt                = MaxInt;
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).Max_AUC_lat_100       = Max_AUC_lat_100;
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).Max_AUC_lat_pickedEnd = Max_AUC_lat_pickedEnd;
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).Max_AUC_smoothed      = Max_AUC_smoothed;
                
                max_p2p_LIST(mus_i)               = MaxP2P;
                max_AUC_lat_100_LIST(mus_i)       = Max_AUC_lat_100;
                max_AUC_lat_pickedEnd_LIST(mus_i) = Max_AUC_lat_pickedEnd;
                max_AUC_smoothed_LIST(mus_i)      = Max_AUC_smoothed;
                
                % 1) Normalize to max_y (within same data rc) - Max
                % intensity is 1
                P2P_AUC_table_MEAN.norm_P2P_to1               = normalize_to_max_y(P2P_AUC_table_MEAN.mean_p2p); 
                P2P_AUC_table_MEAN.norm_AUC_lat_100_to1       = normalize_to_max_y(P2P_AUC_table_MEAN.mean_AUC_lat_100); 
                P2P_AUC_table_MEAN.norm_AUC_lat_pickedEnd_to1 = normalize_to_max_y(P2P_AUC_table_MEAN.mean_AUC_lat_pickedEnd); 
                P2P_AUC_table_MEAN.norm_AUC_smoothed_to1      = normalize_to_max_y(P2P_AUC_table_MEAN.mean_AUC_smoothed); 
                
                % 2) Normalize intensity 
                P2P_AUC_table_MEAN.norm_MaxInt               = normalize_to_max_y(P2P_AUC_table_MEAN.intensity_value); 
                
                
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).MeanTable_P2P_AUC = P2P_AUC_table_MEAN;
                max_strutcs.("SS"+SUBJ).(INTER).(TP).(muscle_channel).AllPulsesTable_P2P_AUC = P2P_AUC_table;
                
                
                % Plot the recruitment curve
                subplot(6,2,INTER_i+subplot_i)
                plot_metric = "mean_p2p";
                
                plot(P2P_AUC_table_MEAN.intensity_value, P2P_AUC_table_MEAN.(plot_metric), 'o')
                hold on;
                
                
            % Save table for the same intervention pre/post all muscles
                combinedTable = [combinedTable; P2P_AUC_table];    
            end
            subplot_i = subplot_i + 1;
           
            
            title([INTER + TP]);
            
            
        end
     
    end
    sgtitle(plot_metric)
    
    SAVEPATH = fullfile(subj_path, SUBJ+"_C_TEPs_P2Ps_Table_ALLinterPrePost.xlsx");
    writetable(combinedTable,SAVEPATH)
    
    % save struc
    SAVEPATH = fullfile(subj_path, SUBJ+"_C_TEPs_CalculatedMat.mat");
    save(SAVEPATH, "max_strutcs")
end

% Save the table:




% Now i need a separate for loop that iterates through max_strutcs, and
% obtains the max of each and normalizes the others by it 

%% Functions:

%% 1. Normalize each curve to max y-axis
function normalized_toMax = normalize_to_max_y(data_string)
    max_y = max(data_string);
    normalized_toMax = (data_string / max_y) ;
end

%% 3. Normalize within participant for single muscle (to max y of the muscle)
function normalized_data = normalize_to_max_within_participant(P2P_amplitude, Intensity, muscle_max)
    normalized_y = (P2P_amplitude / muscle_max) * 100;
    normalized_data = [Intensity, normalized_y];
end

%% 4. Normalize each curve to max x-axis (Intensity)
function normalized_data = normalize_to_max_x(P2P_amplitude, Intensity)
    max_x = max(Intensity);
    normalized_x = Intensity / max_x;
    normalized_data = [normalized_x, P2P_amplitude];
end

%% 5. Normalize within participant for single muscle and max intensity
function normalized_data = normalize_to_max_within_participant_x_and_y(P2P_amplitude, Intensity, muscle_max, participant_max)
    normalized_y = (P2P_amplitude / muscle_max) * 100;
    normalized_x = Intensity / participant_max;
    normalized_data = [normalized_x, normalized_y];
end

%% 6. Normalize y-axis (0 to 100%) and x-axis to max muscle (Intensity)
function normalized_data = normalize_to_max_x_and_y(P2P_amplitude, Intensity, muscle_max)
    max_y = max(P2P_amplitude);
    max_x = max(Intensity);
    normalized_y = (P2P_amplitude / max_y) * 100;
    normalized_x = Intensity / max_x;
    normalized_data = [normalized_x, normalized_y];
end