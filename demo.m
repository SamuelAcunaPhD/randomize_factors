% Filename: demo.m
% Name:   Samuel Acuña
% Date:   08 Sep 2021
% Description: demonstration of the function randomize_factors.m
% so, setup your experimental factors and repetitions, this will
% churn out the experimental conditions in random order for a full
% factorial design

% experimental factors (independent variables) influence your outcome measures (dependent variables)

clear; clc; close all;

%% LIST EXPERIMENTAL FACTORS (independent variables)

factor(1).name = 'Factor A'; % name of factor
factor(1).conditions = {'A1','A2'}; % name the conditions

factor(2).name = 'Factor B';
factor(2).conditions = {'B1','B2'};

factor(3).name = 'Factor C';
factor(3).conditions = {'C1','C2','C3'};

nRepetitions = 2;

%% full factorial design
[T,S] = randomize_factors(factor,nRepetitions);

