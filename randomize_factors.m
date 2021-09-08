function [tTrials,sTrials] = randomize_factors(factor,nRepetitions,table_filename)
% setup your experimental factors and repetitions, this will
% churn out the experimental conditions in random order for a full
% factorial design
% author: Samuel A. Acuña, PhD
% updated: 08 Sep 2021
%
% REQUIRED INPUTS:
% factor : a structure with fields for name and conditions
%
% OPTIONAL INPUTS
% nRepetitions : the number of repetitions of the conditions, default is 1
% table_filename : the name of the table to save
%
% OUTPUTS:
% randomize_factors(factors,nRepetitions) : a table of randomized experimental factors will be saved to the working directory as 'table_filename.xls'
% [tTrials] = randomize_factors(factors,nRepetitions) : tTrials is the table of randomized experimental factors
% [tTrials,sTrials] = randomize_factors(factors,nRepetitions) : sTrials are strings listing the table of randomized experimental factors
%
% EXAMPLE:
% factors(1).name = 'Factor A'; % name of factor
% factors(1).conditions = {'A1','A2'}; % name the conditions
% factors(2).name = 'Factor B';
% factors(2).conditions = {'B1','B2'};
% factors(3).name = 'Factor C';
% factors(3).conditions = {'C1','C2','C3'};
% nRepetitions = 2;
% randomize_factors(factors,nRepetitions);
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs
if nargin < 2
    nRepetitions = 1;
end

if nargin < 3
    table_filename = 'trials.xls';
end

if ~isfield(factor,'name')
    error('Must include name as a field in your factor structure.')
end
if ~isfield(factor,'conditions')
    error('Must include conditions as a field in your factor structure.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% full factorial design

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tTrials : output trials as a table
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

tTrials = cell2table(table_data,'VariableNames',factorNames);

writetable(tTrials,table_filename,'WriteMode','replacefile');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sTrials : output trials as strings
sTrials = cell(nTrials,1);
for iT = 1:nTrials
    trialStrings_row = '';
    for iF = 1:length(factor)
        trialStrings_row = [trialStrings_row factor(iF).name ': ' factor(iF).conditions{trials(iT,iF)} ', '];
    end
    trialStrings_row = ['Trial Number: ' num2str(iT) ', ' trialStrings_row, 'Repetition: ' num2str(trials(iT,iF+1))];
    sTrials{iT} = trialStrings_row;
end

end

