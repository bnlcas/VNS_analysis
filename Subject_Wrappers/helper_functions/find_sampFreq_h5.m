function sampFreq = find_sampFreq_h5(hdf5filename)
%% Thus function finds the sample frequency of a clinical ecog recording
% Input: the full filename of an .h5 file containing clinical ecog data
%
% output: the sample frequency rounded to the nearest integer

timestamps = hdf5read(hdf5filename, 'timestamp vector');
duration = timestamps(end) - timestamps(1);
sampFreq = round(length(timestamps)/duration); %samples/sec (must be integer)


end