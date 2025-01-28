function [magnitudes, durations] = mags_durs_diffsLR(spm_result, averages)

%% PURPOSE: CALCULATE THE AVERAGE MAGNITUDE AND DURATION THAT THE SPM SHOWS AS DIFFERENT IN L VS. R
% Inputs:
% spm_result: struct, where each field is one SPM result (e.g. 'HAM' as the
% result of running SPM on 'LHAM' vs. 'RHAM')
% averages: struct, where each field is the average of the time-normalized
% 1 x N timeseries data, where N probably equals 100/101 points (% of gait
% cycle/timeseries).
%
% NOTE: This relies on the field names of averages being the same as the
% field names of spm_result, just with 'L' or 'R' prepended.

spm_fields = fieldnames(spm_result);
for i = 1:length(spm_fields)
    spm_field = spm_fields{i};

    endpoints = spm_result.(spm_field);

    % Initialize the structs
    magnitudes.(spm_field) = zeros(size(endpoints,1),1);
    durations.(spm_field) = zeros(size(endpoints,1),1);    

    if all(endpoints(1,:) == 0) && size(endpoints,1) == 1
        continue; % No differences found.
    end

    fieldL = ['L' spm_field];
    fieldR = ['R' spm_field];
    for j = 1:size(endpoints,1)
        curr_start = endpoints(j,1);
        curr_end = endpoints(j,2);
        currMag = abs(mean(averages.(fieldL)(curr_start:curr_end)) - mean(averages.(fieldR)(curr_start:curr_end)));
        currDur = abs(curr_end - curr_start);
        magnitudes.(spm_field)(j) = currMag;
        durations.(spm_field)(j) = currDur;
    end
end