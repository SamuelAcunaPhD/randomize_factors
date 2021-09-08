% Filename: randomize_factorial.m
% Name:   Samuel Acuña
% Date:   08 Sep 2021
% Description: setup your experimental factors and repetitions, this will
% churn out the experimental conditions in random order for a full
% factorial design

% experimental factors (independent variables) influence your outcome measures (dependent variables)

clear; clc; close all

%% LIST EXPERIMENTAL FACTORS (independent variables)
% nRepetitions = 2;
% 
% factor(1).name = 'Factor A'; % name of factor
% factor(1).conditions = {'A1','A2'}; % name the conditions
% 
% factor(2).name = 'Factor B';
% factor(2).conditions = {'B1','B2'};
% 
% factor(3).name = 'Factor C';
% factor(3).conditions = {'C1','C2','C3'};

nRepetitions = 2;

factor(1).name = 'Factor A'; % name of factor
factor(1).conditions = {'A1','A2'}; % name the conditions

factor(2).name = 'Factor B';
factor(2).conditions = {'B1','B2'};

factor(3).name = 'Factor C';
factor(3).conditions = {'C1','C2','C3'};

%% full factorial design

% pull number of conditions for each factor
conditions = [];
for iF = 1:length(factor) % cycle through experimental factors
    conditions = [conditions, length(factor(iF).conditions)];
end
conditions = [conditions, nRepetitions]; % do not forget the repetitions!

% assemble full factorial design
trials = fullfact(conditions);
nTrials = size(trials,1);

% randomize order
rTrials = randperm(nTrials);
trials = trials(rTrials,:);

%% output trials as a table
table_data = cell(size(trials));
for iT = 1:nTrials
    table_data{iT,1} = iT; % trial number
    for iF = 1:length(factor)
       table_data{iT,iF+1} = factor(iF).conditions{trials(iT,iF)} ;
    end 
    table_data{iT,iF+2} = num2str(trials(iT,iF+1));
end

% pull factor names for column names
factorNames{1} = 'TRIAL NUMBER';
for iF = 1:length(factor) 
    factorNames{iF+1} = factor(iF).name;
end
factorNames{iF+2} = 'REPETITION'; %repetition

table_data = [table_data];

tTrials = cell2table(table_data,'VariableNames',factorNames)

writetable(tTrials,'trials.xls')



%% output trials as strings
trial_strings = cell(nTrials,1);

for iT = 1:nTrials
    trialStrings_row = '';
    for iF = 1:length(factor)
        trialStrings_row = [trialStrings_row factor(iF).name ': ' factor(iF).conditions{trials(iT,iF)} ', '];
    end
    trialStrings_row = ['Trial Number: ' num2str(iT) ', ' trialStrings_row, 'Repetition: ' num2str(trials(iT,iF+1))];
    trial_strings{iT} = trialStrings_row;
end

trial_strings;
clear conditions factorNames iF iT rTrials table_data trials trialStrings_row


