function [vns_stim, time_axis] = examine_VNS_dutyCycle(h5_file, ekg_chan, varargin)
%
% Inputs:
% 1: h5_file - string listing the file directory of an hdf5 file containing
% clinical data with VNS stimulation present
%
% 2: ekg_chan - integer denoting the channel that contains ekg data
%
% Variable Inputs:
%
% 1 - stimulation frequency (default 25 hz);
%

fs_stim = 25; 
if length(varargin)>0
    if ~isempty(varargin{1})
        fs_stim =varargin{1};
    end
end

% Get sample frequency:
sampFreq = find_sampFreq_h5(h5_file);

% Load EKG Data:

 data=hdf5read(h5_file,'ECoG Array');
 ekg_data = data(ekg_chan,:);

vns_stim = extract_vns_stim_i(ekg_data, sampFreq, fs_stim);

time_axis = linspace(0, (length(ekg_data)/sampFreq),length(ekg_data));

plot_out = true;
if plot_out
    figure;
    plot(time_axis, vns_stim)
    xlabel('Time (s)')
    ylabel('VNS Intensity')
    title('Plot of VNS intensity in Clinical Recording Block')
end

end

