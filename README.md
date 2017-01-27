# VNS_analysis
Functions for VNS analysis


VNS Analysis Functions

The purpose of this document is to list the functions that have been developed to help analyze clinical data with Vagal Nerve Stimulation. This will serve as both a manual to help people understand and operate these functions as well as an explanation of the analyses that have been produced.

Analysis Overview: The VNS analysis functions are intended to be generalizable to suit the idiosyncrasies of several subjects. Since each subject could have a different VNS duty cycle and stimulation frequency it is important to asses these features and incorporate these differences into subsequent function calls.
Currently, the analysis architecture is centered around a wrapper for a given patient. This script contains constants like file directories and stimulation settings that are unique to a given patient and uses this information to call the primary data processing functions to generate a set of summary statistics and figures.

To begin the analysis process for a given subject you will need to download a block of converted clinical onto your local drive as well as the anatomy and brain meshes for the subject. These must then be stored in a particular folder format (see below).
The analysis of a given subject is given as a sequence of commands given in a wrapper found in the subfolder VNS_Analysis_Functions/Subject_Wrappers/subject_name.m
Since individual subjects have different stimulation parameters this wrapper still has parameters that are hard coded and patient specific. Additionally, since the saving of images has not been automated yet, it is recommended that this script be run line by line in the console until a further stage of development.

Data Folder Format:
For a given subject data should be stored in a folder with the following subfolder structure. The hdf5 files for a particular recording block should each be given their own folder. In order to plot information about anatomy and to plot data on the brain, a folder title ‘BrainPlot’ (note the capitalization) should be created that contains the free surfer meshes as well as the anatomy file ‘clinical_elects_all.mat’. The subfolder structure should resemble to the presentation given below:

root_directory
data_folder1
tdt hdf5 files
data_folder2
tdt hdf5 files
…
BrainPlot
clinical_elects_all.mat
brain_meshes
The data for the BrainPlot Folder should be found in DataStore2/Imaging/SUBJECT_FOLDER
The meshes can be found in a folder called ‘meshes’, which contains the mesh .mat file (‘lh_subject_pial.mat’). The electrodes can be found in the folder called ‘elecs’, under the name ‘clinical elecs all.mat’ (this file is essential for the proper functioning of the subsequent analyses).


Running Analysis:
To run the analysis of a VNS subject’s data, first open the general analysis wrapper script in VNS_analysis/Subject_Wrappers/VNS_analysis_script_gen_1.m
You will need to modify the first few lines to match the local data directories and the parameters of the experiment. The file directories will be dictated by where you have saved the relevant recordings on your local desktop. Experimental parameters like the sample frequency and the VNS duty cycle should be determined by both an examination of the raw data, and checking with the trial recording notes.
To help inspect the data, you can use the functions ‘find_sampFreq_h5.m’ and ‘examine_VNS_dutyCycle.m’ to find the sample frequency and look at the time course of VNS stimulation (found in ‘VNS_Functions_DirSubject_Wrappers/helper_functions/’). Additionally, you will need to find a list of relevant electrodes. This can be found in the trial notes for the subject. It is important to note the ekg channel since this is used for time alignment. There are often two ekg channels, and while they will both show similar data, one often has less noise and is thus preferable. This feature can be determined by visual inspection of the VNS pulses using ‘examine_VNS_dutyCycle.m’ to look at which ekg channel has a cleaner response. Also note that eeg electrodes must, in general, be excluded from the analysis since they tend to pick up large amounts of electrical interference from the VNS stimulation.




Functions:
The repository of VNS_Functions is organized into the following sub-folders, whose contents will be explained in greater detail further on.

Analysis Functions - contains the functions that analyze raw data.


Plotting_functions - contains functions necessary for some of the data visualizations


Preliminary Processing Functions - contains functions to process raw data into hilbert transformed analytic envelopes, erps, or other measurements taken from the raw.

Subject Wrappers - contains wrapper scripts for individual subjects to execute a sequence of commands to analyze a subject’s data. These all follow a similar form, however this has not yet reached a state of development where it is fully automated. As a general rule, it is best to review a subject’s data by hand to verify the sample rate and the stimulation parameters.

The full set of VNS functions that are used are described below in the order of their appearance in a given subject’s analysis wrapper:

To being the analysis of a subject you will need to create a subject wrapper. Templates can be found in the subject wrappers for existing subjects 

VNS_process_raw - this is the primary function for loading raw hdf5 files and converting them into useful ECoG measurements such as hilbert transformed envelope, phase, ERPs. The output is a structured array (VNS_dat) that contains these measurements as well as information about the timing of VNS stimulation. This data structure is commonly used in subsequent data analysis functions.
The inputs of the function are described in more detail in the function. The basic form of the input is list the directory of the data, the ekg channel in the data, the relevant electrodes to be analyzed and the call various flags to analyze particular aspects of the ECoG.











VNS_Onset_Detection_Functions:
One of the most important features of the VNS processing function is finding the correct timing of VNS stimulation. This is done using an algorithm that finds the power of the VNS stimulation frequency in the EKG channel and then uses this information to find the times that most closely resemble an idealized pulse with the timing information given by the duty cycle of the VNS stimulation.

These functions rely on being given the correct information about the stimulation frequency and duty cycle of the VNS.

find_vns_stim_on:
This function finds the timing of the VNS stimulation. It is necessary for all subsequent analysis of VNS locked data. Hence it is always run by VNS_process_raw.
It uses the ekg channel as well as data about the frequency of the data, the stimulation and its  duration and uses this to measure the power of VNS stimulation over time and then synchronizes this with the theoretical VNS power trace given by the duty cycle of the stimulation. The data is also downsampled to match the sample rate used by other ecog measurements like high gamma.
Inputs:
ekg_data: 1d array of data from the ekg channel 
fs_in: sample rate of the ekg channel

Variable inputs:
1: fs_out (default 100) - the sample rate to down sample VNS onset measurement to. 
Should match sample rate of other ecog measurements
2: stim_freq (default 25) the frequency of VNS stimulation pulses
3: dutycycle_params (default [30,2]) the timing of the profile of the theoretical trace of the VNS power, array, first value is the duration of peak power, the second value is the duration (in seconds of the onset/offset ramping time).

Ex:  is_stim_on = find_vns_stim_on(ekg_data, 1024, 100, 25, [30,2]);


extract_vns_stim_i:
This function extracts the VNS stimulation power. This is taken to be the power (as measured by the analytic amplitude) of the ekg channel bandpassed filtered for the VNS stimulation frequency at its harmonics. This is used in the first step toward finding the timing of VNS stimulation artifacts.
Inputs:
data - 1d array of ekg data
Variable Inputs:
1: sample rate of data (default 1024)
2: sample_rate of stimulation (default 25)
Ex: vns_stim = extract_vns_stim_i(data, 1024, 25);



Find_boolean_on:
This function takes a boolean array and determines the time points where this boolean transitions from OFF to ON (onsets) as well as the points where the boolean transitions from ON to OFF (offsets).
If the boolean array starts with an ON, it will add an onset at the starting index, if the array ends with an ON, it will add an offset at the ending index.
Variable input - minimum_duration threshold (rejects intervals whose duration (in time points is less than a minimum length). 
Ex: [onsets, offsets] = find_boolean_on(is_on, 2*sample_frequency);


generate_ideal_vns_pulse:
Generates a theoretical representation of the intensity of the VNS pulse for a given duty cycle setting and sampling rate.
Inputs:
sample rate of the ekg channel
Variable inputs:
1 - pulse peak time - the duration (in seconds) of peak VNS power
2 - pulse onset/offset time - the duration (in seconds) of the ramp to peak power
Output: vns_pulse (an idealized trace of the power of a single VNS stimulation pulse given the characteristic duty cycle and sample rate)
Ex: [vns_pulse] = generate_ideal_vns_pulse(1024, 30, 2);






Artifact_Detection:
These functions are used to automatically find bad channels and bad time points.

Plot_spectra_debug:
This function automatically flags bad channels in clinical data on the basis of the spectrograms of their raw data. By default it will generate spectrograms of the raw data for each channel and determine whether a channel is measuring real neurological signal or not based on whether it follows a pink noise distribution. Additionally it generates a plot the spectrograms of each channel (with problematic ones outlined in red) so that a human can review the selection of bad channels.
Inputs: VNS_raw - VNS data structure with Raw Data ERPs included
Variable Inputs:
var1 - sample rate (default 1024, has been seen at 1000 and 512)
var2 - correlation threshold (default 0.6 - raise to reject more bad chans)
var3 - VNS frequency (default 25hz, has been seen at 10 hz before) the harmonics of this and 60 hz frequency are excluded in the estimate of pink noise.
var4 - clear white matter electrodes (default true) electrodes labeled as white matter will be automatically labeled as bad channels
var5 - plot_out (default true) generates a plot of the spectrogram of each channel 

outputs:
is_bad_chan - 1d boolean array (ON if channel is found defective)
Ex: [is_bad_chan] = plot_spectra_debug(VNS_raw, 1024, [], 25, true, true);




Artifact_detector_3:
This function finds bad time points in the envelope data of the 5 major frequency bands and appends 5 separate boolean arrays which lists the bad points in each of these 5 bands to the original VNS data structure.
Bad time points are determined by times where the number of channels have unusually high activity in a given band (as determined by a simple threshold). The result will append a set of 5 booleans (1 for each band) listing time where the data in a given band was high for each band to the original data structure.
Inputs: 
VNS_dat - VNS data structure that includes envelope measurements

Variable Inputs
var1 - power_thresh - (default 8) threshold z-score for bad time points.
var2 - bad_ch_thresh - (default 1) the threshold number of channels where envelope exceeds power_thresh for a time point to be considered bad
var3 - bad_time_spread (default 20 points (200ms at 100 hz)) the number of points centered around a bad time point that are also considered to be bad time points.

Output:
VNS_dat - same data structure as input with bad_time_point booleans added
 
Ex: VNS_dat = artifact_detector_3(VNS_dat, 8,1,20);





Analysis Functions:
This folder contains functions that perform the basic analysis of the ecog measurements. Most of these analyses are supported by analysis scripts which carry out a set of specific measurements and return a list of summary statistics and graphics.
There are also some specialized functions for carrying out particular analyses and supporting functions that are generally useful toward analyzing the ecog measurements.

Summary Stat Scripts:
These include specific sets of steps to be taken to create the standard set of summary statistics and analysis figures that have been displayed in the initial investigation summaries.



Generate_block_analysis:
This function generates the standard set of comparisons of the means variances and pairwise correlations between the time blocks when stimulation is present and the time blocks when stimulation is absent. Note that all statistical comparisons use the t-test, except for pair-wise correlation which uses the ks-test owing to the natural skew in the distributions that results from the fact that correlation coefficients are bounded between [-1, 1].
Inputs:
VNS_dat - standard VNS data structure with envelope data included
Variable Inputs:
1 - window_size (the size the analysis window for blocks relative to onset (default 30 - means compare means of data 30 after onsets to means 30 seconds before onsets)
2 - plot_erps (boolean, default true), plot the onset locked ERPs for each band.
3 - p_thresh, the p value threshold for significance
Output: out_table - table containing the percentage of of electrodes that show significant difference between stim on and stim off blocks. Also generates ERP plots
Ex: out_table = generate_block_analysis(VNS_dat, 30, true, 0.05);



generate_block_analysis_lump:
This function generates the analysis comparing ALL data points in the time window before stimulation to All data points in the time window after stimulation. It returns a table showing the percentage of electrodes in each band that show a significant difference between these two populations and also list the average effect sizes among the significant electrodes as a variable option in will plot the magnitude of the signifcance (Cohen's D) on the brain.
Inputs:
VNS_dat - VNS data structure that includes envelope data
Variable Inputs:
1 - window length (pre vs post stim, will be symmetric on both sides)
2 - the directory of brain data (necessary for brain plots)
3 - subject name (ex ‘EC131’)
4 - brain hemisphere to plot (default ‘lh’, also can do, ‘rh’ or ‘both’)
5 - p_thresh, the p value threshold for significance (default 0.05/nchans)

Outputs: Data Table containing percentage of significant electrodes per band and the average effect size of among these electrodes. Also will plot brain plots of this effect.

Ex:  [out_table] = generate_block_analysis_lump(VNS_dat, 30, ‘\dir\data\brain_dat’, ‘ECXXX’, ‘both’);




generate_block_analysis_phase:
This function generates the standard set of comparisons of the circular  means variances and pairwise correlations on the PHASE data between the time blocks when stimulation is present and the time blocks when stimulation is absent. Note that here significance is determined by the Kuiper Test, except the circular pairwise correlation coefficients which use the KS-test.

Inputs:
VNS_dat - standard VNS data structure with phase data included
variable inputs:
1 - window_size (the size the analysis window for blocks relative to onset (default 30 - means compare means of data 30 after onsets to means 30 seconds before onsets) - is a variable with VNS duty cycle
2 - plot_mean_dist (boolean, default true), plot the histogram of the circular means for each band
3 - p_thresh, the p value threshold for significance

Output: out_table, table containing the percentage of of electrodes that show significant difference between stim on and stim off blocks.  also makes some graphs...
Ex: [out_table] = generate_block_analysis_phase(VNS_dat, 30, true, 0.05);




KL-Divergence:
One of the more prominent methods for studying the effect of VNS stimulation has been using the time evolution of KL divergence to look at how distribution of ecog data shifts with the onset of VNS. This is primarily done in a single function that generates time courses and spectrograms for the KL-divergence.


kl_get_spectrograms:
This function measures and plots the evolution of the KL divergence in each band and each channel over time. The KL divergence is taken as the distance in the distribution of a data that occurs within a certain time window before the onset to a sliding time window.

The time evolution of the KL divergence for each channel and each band is then plotted as a time series and also as pseudo-spectrograms.

Inputs:
VNS_dat - VNS output structure that contains envelope data
plot_out - boolean (must be true to generate plots)

Variable inputs:
1 - anatomical label (n_chans cell array listing the anatomic description of each channel)
2 - electrode colors - useful for comparing to brain anatomy
3 - window length (default 10) the size of the sliding window use to agglomerate data to compare the changes in the distribution of data. 
4 - kl_timecouse window (default [-30 60] the span of time about onsets to study the evolution of KL divergence.
5 - image save_directory, directory to save output images in
6 - figure title appelation (only possible if variable input 4 is not empty)

outputs:
kl_spectrograms (n_chan x time_pts x frequency_bands matrix)
time_axis = (timepts) time axis for kl_spectrograms 
f_axis = n_frequency_bands axis representing the midpoint frequency for each of the 5 classic frequency bands

Ex: [kl_spectrograms, time_axis, f_axis] = kl_get_spectrograms(VNS_dat, true, VNS_dat.anatomy, [], 10);





kl_divergence_time_course_2:
This function is takes a n_channel x time_pts matrix of ecog data and forms it into erps to use to measure the changes in the distribution of data over time relative to VNS onset. The kl_divergence between data points that occur before onsets and data points that occur within a sliding window of times is then measured and compared and measuring over times.
Inputs:
ecog - n_channel x time_pts matrix of ecog data
onsets - n_trails array of the onset indices of VNS
fs - sample rate of the data
window_len - the size of the sliding window used to form the distribution
outputs:
Kl_div - the kl_divergence between a baseline distribution of ecog and a sliding window time lock to the onset of VNS.
time_axis - the corresponding time axis for this data.
Ex: [kl_div, time_axis] = kl_divergence_time_course_2(ecog, onsets, 100, 30







Supporting Functions:

Make_vns_erps:
This is a very central function for several analyses. It uses timing data about the onset of VNS stimulations to create time locked data that can be used to form average responses to the stimulus. (it’s use is not limited to VNS)

Inputs:
data - N_channels x Timepts data matrix of ecog data
onset_inds - n_trialx 1 array containing the indices (on timepts) where VNS stimulation begins (if onset_inds(k) = 999, then data(:,999) is measured at the start of an onset, and would correspond to the eprs(:, find(time_axis == 0) ,k);
fs - sample frequency of data
erp_win - time window (in seconds) about the onset where Ex ([-10 10]) means that ERP data extending from 10 seconds before the onset to 10 seconds after the onset are included in the final erp matrix

Outputs:
erps - N_chan x n_Timepts x n_trials erp matrix
time_axis - n_timepts array of the time, relative to onset. Data in erps(:, k, :); all occures time_axis(k) seconds relative to the VNS onset.


Circular_functions: This folder contains several functions that generate statistical measures that are value for data point in a circular topology (since a circle loops 0 and 2pi are the same, thus is it necessary to modify several traditional statistics which implicitly assume that there are greater than less than relationships between data points.)
This folder contains the following functions that have been used for analysis of phase data:

Only a brief description is provided here, but the documentation in the functions is sufficient since they have all been downloaded from or uploaded to matlab file exchange.

Circ_corcoeff, for a n_rows x n_colums returns a n_col x n_col matrix X whose i,jth entry corresponds to the circular analog for pearson’s correlation coefficient between the ith and jth columns of X.

Circ_kuiper_eq, runs a non parametric statistical test on two 1d arrays of angular data and returns a p-value that they come from statistically distinct distributions. This is determined from the Kuiper Statistic and and equation approximating the p-values of this statistic.

Circ_mean - returns the mean of angular data

Circ_std - returns the standard deviation of angular data

Circ_var - returns the variance of angular data.










Plotting Functions:
These functions are mainly tools to help generate figures. In general these are all fairly simple in the operation, and documentation for these exists elsewhere. Hence the description given here will be limited to a cursory overview.

Position_subplot_grid:
Generates a set of position vectors to tile a figure with n subplots.
Input: number of subplots (n)
Variable Input: spacing between plots (between 0 and 1, a value of ~0.2 is recommended for aesthetic reasons.
Output: nx4 matrix, where each row defines a subplot specified through
Ex: num_plots = 77;
[sub_plot_coords] = position_subplot_grid(num_plots, 0.2);
figure;
for i = 1:num_plots
subplot(‘Position’, output(i,:)); plot(x,y)
end


Plot_brain_elecs_dat:
This function plots a reconstruction of a brain with the electrodes on it. The electrode color is shaded according to the values of the input array ‘dat’. This function uses a colormap where positive values of dat are red and negative values are blue. Electrodes whose value is exactly 0 are left clear and only a black ring indicates their position (this is useful for omitting bad channels or irrelevant points).
Inputs: 
dat - num_electrodes long array containing some statistic relevant to the electrode.
Brain_dir - directory containing anatomy files and the mesh files
Variable inputs:
Var 1 - subject name (default 'EC131') in general this will need to be changed for each subject
Var 2 - hemisphere (default 'lh') possible options ('rh', 'lh', 'both') entering 'both' will plot both the right and left hemisphere recons.
Var 3 - brain alpha (number [0,1], default 0.5) sets the transparency of the brain surface
Var 4 - sort electrodes by alphabetical order - boolean (default true, since this occurs in the VNS data structure as a default, could be switch in future iterations).




