function [displayString] = displayTrial(T,i,repFlag)
% displays the selected trial conditions as a string
% 
% INPUTS:
% T : a table of conditions, first column is the trial number, last column is the repetition number, and the columns in between are different factor conditions.
%     for convenience, recommended to tuse function randomize_factors.m
% i : the trial number to display
%
% OPTIONAL INPUTS:
% repFlag : 0 = don't display the repetition number
%           1 = display the repetition number (default)

if nargin < 3
    repFlag = 1;
end

% pull factor names
col_names = T.Properties.VariableNames(2:end-1);
nFactors = length(col_names);

% find length of character names
for j = 1:nFactors
    factorNameLength(j) = length(col_names{j});
    longestConditionNameLength = length(T{1,j+1});
    for k = 2:height(T)
        if length(char(T{k,j+1})) > longestConditionNameLength
            longestConditionNameLength = length(char(T{k,j+1}));
        end
    end
    if factorNameLength > longestConditionNameLength
        conditionLength(j) = factorNameLength(j);
    else
        conditionLength(j) = longestConditionNameLength;
    end
end

% assemble header string
headerString = sprintf('%10s','TRIAL#:');
for j = 1:nFactors
    
    factorString = upper([col_names{j} ':']); 
    
    if conditionLength(j) <= 10 % default number of characters to display
        nCharacters{j} = 10;
    else % use a multiple of 5 for number of characters
        nCharacters{j} = 5*idivide(conditionLength(j)+1,int16(5),'ceil');
    end
    formatString = ['%' num2str(nCharacters{j}) 's'];

    headerString = [headerString sprintf(formatString,factorString)];
end
if repFlag
    headerString = [headerString sprintf('%10s','REP:')];
end

% assemble trial string
trialString = sprintf('%10d',T{i,1});
for j = 1:nFactors
    
    factorString = char(T{i,j+1}); 
    formatString = ['%' num2str(nCharacters{j}) 's'];
    trialString = [trialString sprintf(formatString,factorString)];
end
if repFlag
    trialString = [trialString sprintf('%10s',char(T{i,end}))];
end

% display trial strings
displayString = [headerString;trialString];
if nargout == 0
    disp([headerString;trialString]);
end
end