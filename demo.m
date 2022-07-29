% Filename: demo.m
% Name:   Samuel Acuña
% Date:   13 Sep 2021
% Description: demonstration of the function randomize_factors.m
% so, setup your experimental factors and repetitions, this will
% churn out the experimental conditions in random order for a full
% factorial design

% experimental factors (independent variables) influence your outcome measures (dependent variables)


clear; clc; close all;
%% INPUT OPTION 1: ENUMERATE LEVELS

levels = [2 3 2]; % 3 factors, the first with 2 levels, second with 3 levels, third with 2 levels
repetitions = 3; % number of repetitions of the factors and levels

s1 = study_design(levels, repetitions);

clear levels repetitions

%% INPUT OPTION 2: NAME THE FACTORS AND LEVELS
factor_names = {'A','B','C'};
level_names = {{'A1' 'A2'},{'B1' 'B2' 'B3'},{'C1' 'C2'}};
repetitions = 3; 

s2 = study_design(factor_names,level_names,repetitions);

clear factor_names level_names repetitions

%% INPUT OPTION 3: LIST EXPERIMNETAL FACTORS using structures

factors(1).name = 'A';
factors(1).levels = {'A1' 'A2'};
factors(2).name = 'B';
factors(2).levels = {'B1' 'B2' 'B3'};
factors(3).name = 'C';
factors(3).levels = {'C1' 'C2'};
% default nRepetitions == 1

s3 = study_design(factors);

clear factors

%% EXAMINE PROPERTIES
clc
s1.nFactors
s1.nLevels
s1.nRepetitions
s1.factors
s1.levels
s1.design
s1.nTrials
s1.order 

% display the randomized study design
s1.design_ordered
s1.table
s1.text

%% display individual trials
clc
s1.display_trial(10); % display the 10th trial
disp(' ')
s1.display_trial(10,0); % display the 10th trial, no repetition number shown 


%% save design to file
s1.write_table('table_filename.xls');
s1.write_text('text_filename.txt')

%% re-randomize the design
clc
s1.design_ordered
s1.randomize_order();
s1.design_ordered

%% example usage during data collection
clc;
disp('Starting data collection:');
for i = 1:s1.nTrials
    while 1
        disp(' ')
        disp(' ')
        disp(' ')
        s1.display_trial(i);
        disp(' ')
        reply = input('[1] next trial, [2] repeat trial, [3] quit. Choose: ');
        switch reply
            case 1
                clc; disp('Next trial:');
                break;
            case 2
                clc; disp('Repeat trial:');
            case 3
                disp('Quit.')
                return
            otherwise
                clc; disp('Invalid Reponse.');
        end
    end
end


