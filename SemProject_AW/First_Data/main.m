
%% Load data already processed.
clc
clear all
close all

load('EMG_final_ok.mat');

%% Train an ESN on each time window and plot the test success rate

ESN_class_perTW();


%% Train a single ESN for all the time windows and plot the test success rate

figure
ESN_class_single();

%% Try classifying using LDA

LDA_class();

