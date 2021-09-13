classdef study_design < handle
    % study_design : setup your experimental factors and repetitions, this
    % will churn out the experimental conditions in random order for a full
    % factorial design 
    % author: Samuel A. Acuña, PhD 
    % updated: 10 Sep 2021
    %
    % see constructor to see various examples on how to setup the class
    %
    % example of usage in a data collection:
    %     s1 = study_design([2 3 2],3);
    %     disp('Starting data collection:');
    %     for i = 1:s1.nTrials
    %         while 1
    %             s1.display_trial(i);%             
    %             reply = input('[1] next trial, [2] repeat trial, [3] quit. Choose: ');
    %             switch reply
    %                 case 1
    %                     clc; disp('Next trial:');
    %                     break;
    %                 case 2
    %                     clc; disp('Repeat trial:');
    %                 case 3
    %                     disp('Quit.')
    %                     return
    %             end
    %         end
    %     end

    
    
    properties
        % instantiated by constructor:
        nFactors; % number of factors
        nLevels; % number of levels (i.e., conditions) for each factor
        nRepetitions; % the number of repetitions of the conditions, default is 1
        factors; % names of the factors
        levels; % the number of conditions for each factor
        design; % the study design, listed as levels for each condition
        nTrials; % total number of trials in the study design
        order; % the order in which to execute the study design
    end
    properties (Dependent)
        design_ordered; % the study design in order
        table; % table of the ordered design
        text; % text of the ordered design
    end
    properties (Hidden)
        longestNameLengths; % length of factor name or level name, whichever is the longest
        columnCharacterWidths; % column character widths when displaying trials 
        headerString; % useful for displaying trials
        headerString_noRep; % header string without repetition column
    end
    properties (Hidden, Constant)
        defaultColumnCharacterWidth = 10; % default width, for displaying correct spacing between columns
    end
    methods
        function obj = study_design(varargin)
            % CONSTRUCTOR FUNCTION. Goal: instantiate the undefined
            % properties. If user doesnt specify when constructing this
            % object, provide default values.
            %
            %
            % INPUT OPTION 1:
            % nLevels : the number of levels (i.e. conditions) for each
            %   factor. Automatically defines nFactors by size of the
            %   vector.
            % nRepetitions : (optional) the number of repetitions for each
            %   level, default is 1.
            %
            %   EXAMPLE:
            %       nLevel = [2 3 2]
            %
            %       this inputs 3 factors. The first has 2 levels, the
            %       second has 3 levels, and the third has 2 levels
            %
            % INPUT OPTION 2:
            % factors : cell array of the names of the factors
            % levels : cell array of the names of the levels (i.e.
            %   conditions)
            % nRepetitions : (optional) the number of repetitions for each
            %   level, default is 1.
            %
            %   EXAMPLE:
            %       factors = {'A','B','C'}
            %       levels = {{'A1' 'A2'},{'B1' 'B2' 'B3'},{'C1' 'C2'}}
            %
            % INPUT OPTION 3:
            % factors : a structure, with fields for name and levels (or
            %   conditions)
            % nRepetitions : (optional) the number of repetitions for each
            %   level, default is 1.
            %
            %   EXAMPLE:
            %       factor(1).name = 'A';
            %       factor(1).levels = {'A1' 'A2'};
            %       factor(2).name = 'B';
            %       factor(2).levels = {'B1' 'B2' 'B3'}
            %       factor(3).name = 'C';
            %       factor(3).levels = {'C1' 'C2'};
            %
            
            
            % DETERMINE WHICH INPUT OPTION IS USED:
            if ~isempty(varargin{1}) && ismatrix(varargin{1}) && isnumeric(varargin{1}) && ~isscalar(varargin{1})
                % INPUT OPTION 1
                obj.input_option_1(varargin{:});
            elseif iscell(varargin{1}) && ~isempty(varargin{1}) && length(varargin{1}) > 1
                % INPUT OPTION 2
                obj.input_option_2(varargin{:});
            elseif isstruct(varargin{1})
                % INPUT OPTION 3
                obj.input_option_3(varargin{:});
            end
            
            % prepare text for displaying in command window
            obj.prepareDisplayFormatting();
            
            % ASSEMBLE FULL FACTORIAL DESIGN
            obj.assemble_full_factorial()
            
            % RANDOMIZE TRIAL ORDER
            obj.randomize_order()
        end
        function randomize_order(obj)
            % randomize order of trials
            obj.order = randperm(obj.nTrials)';
        end
        function display_trial(obj,trialNumber,repetitionFlag)
            % INPUTS:
            % trialNumber : the trial number to display
            %
            % OPTIONAL INPUTS:
            % repeitionFlag :   0 = don't display the repetition number
            %                   1 = display the repetition number (default)
            %
            
            if nargin <3
                repetitionFlag = 1;
                if nargin < 2
                    error('Must include a trial number.')
                end
            end
            
            if trialNumber <= 0 || trialNumber > obj.nTrials
                error('the trial number is outside the range of available trials');
            end
            
            % assemble and display
            header = obj.getHeaderString(repetitionFlag);
            trial = obj.getTrialString(trialNumber,repetitionFlag);
            
            disp([header; trial]);

        end
        function write_table(obj,filename)
            % writes the table to a file
            % example:
            %   obj.write_table('table1.xls'))
            %
            if nargin == 1
                filename = 'study_design_table.xls';
            end
            writetable(obj.table,filename,'WriteMode','replacefile');
            disp(['Study design table saved as: ' filename]);
        end
        function write_text(obj,filename)
            % writes the table to a text file
            % example:
            %   obj.write_text('table1.txt'))
            %
            if nargin == 1
                filename = 'study_design_text.txt';
            end
            
            fid = fopen(filename,'wt');
            for i = 1:height(obj.text)
                fprintf(fid,'%s\n',obj.text(i,:));
            end
            fclose(fid);
            disp(['Study design text saved as: ' filename]);
        end
        function output = get.design_ordered(obj)
            % display design in the assigned order
            output = obj.design(obj.order,:);
        end
        function output = get.table(obj)
            % output study design as a table
            table_data = cell(obj.nTrials,obj.nFactors+2);
            
            for iT = 1:obj.nTrials
                table_data{iT,1} = iT; % trial number
                for iF = 1:obj.nFactors
                    table_data{iT,iF+1} = obj.levels{iF}{obj.design_ordered(iT,iF)};
                end
                table_data{iT,iF+2} = obj.design_ordered(iT,iF+1);
            end
            
            % assemble column names
            factorNames = ['TRIAL_NUMBER' obj.factors 'REPETITION'];
           
            % assemble table
            output = cell2table(table_data,'VariableNames',factorNames);
        end
        function output = get.text(obj)
             % output study design as text
             output = obj.headerString;
             for iT = 1:obj.nTrials
                 output = [output;obj.getTrialString(iT,1)];
             end
        end
        
    end
    methods (Access = 'private')
        function input_option_1(obj,varargin)
            % INPUT OPTION 1:
            % nLevels : the number of levels (i.e. conditions) for each
            %   factor. Automatically defines nFactors by size of the
            %   vector.
            % nRepetitions : (optional) the number of repetitions for each
            %   level, default is 1.
            %
            %   EXAMPLE:
            %       nLevel = [2 3 2]
            %
            %       this inputs 3 factors. The first has 2 levels, the
            %       second has 3 levels, and the third has 2 levels
            %
            
            % nFactors
            obj.nFactors = length(varargin{1});
            
            % nLevels
            nLevels = varargin{1};
            obj.nLevels = reshape(nLevels,1,length(nLevels));
            
            % nRepetitions
            if nargin==2
                obj.nRepetitions = 1; % default
            else
                obj.nRepetitions = varargin{2};
            end
            
            % factors
            factors = cell(1,obj.nFactors);
            for iF = 1:obj.nFactors
                factors{iF} = [ 'F' num2str(iF)];
            end
            obj.factors = factors;
            
            % levels
            levels = cell(1,obj.nFactors);
            for iF = 1:obj.nFactors
                levels2 = cell(1,obj.nLevels(iF));
                for iL = 1:obj.nLevels(iF)
                    levels2{iL} = [factors{iF} 'L' num2str(iL)];
                end
                levels{iF} = levels2;
            end
            obj.levels = levels;
        end
        function input_option_2(obj,varargin)
            % INPUT OPTION 2:
            % factors : cell array of the names of the factors
            % levels : cell array of the names of the levels (i.e.
            %   conditions)
            % nRepetitions : (optional) the number of repetitions for each
            %   level, default is 1.
            %
            %   EXAMPLE:
            %       factors = {'A','B','C'}
            %       levels = {{'A1' 'A2'},{'B1' 'B2' 'B3'},{'C1' 'C2'}}
            %
            % nFactors
            obj.nFactors = length(varargin{1});
            
            % nLevels
            nLevels = zeros(1,obj.nFactors);
            for iF = 1:obj.nFactors
                nLevels(iF) = length(varargin{2}{iF});
            end
            obj.nLevels = nLevels;
            
            % nRepetitions
            if nargin==2
                obj.nRepetitions = 1; % default
            else
                obj.nRepetitions = varargin{3};
            end
            
            % factors
            obj.factors = reshape(varargin{1},1,obj.nFactors);
            
            % levels
            levels = reshape(varargin{2},1,obj.nFactors);
            for iF = 1:obj.nFactors
                levels{iF} = reshape(levels{iF},1,length(levels{iF}));
            end
            obj.levels = levels;
        end
        function input_option_3(obj,varargin)
            % INPUT OPTION 3:
            % factors : a structure, with fields for name and levels (or
            %   conditions)
            % nRepetitions : (optional) the number of repetitions for each
            %   level, default is 1.
            %
            %   EXAMPLE:
            %       factor(1).name = 'A';
            %       factor(1).levels = {'A1' 'A2'};
            %       factor(2).name = 'B';
            %       factor(2).levels = {'B1' 'B2' 'B3'}
            %       factor(3).name = 'C';
            %       factor(3).levels = {'C1' 'C2'};
            %
            % clean up structures
            factors = varargin{1};
            if ~isfield(factors,'name')
                error('Must include name as a field in your factor structure.')
            end
            if ~isfield(factors,'levels') && isfield(factors,'conditions')
                for i = 1:length(factors)
                    factors(i).levels = factors(i).conditions;
                end
                factors = rmfield(factors,'conditions');
            end
            if ~isfield(factors,'levels') && ~isfield(factors,'conditions')
                error('Must include levels (or conditions) as a field in your factor structure.')
            end
            
            % nFactors
            obj.nFactors = length(factors);
            
            % nLevels
            nLevels = zeros(1,obj.nFactors);
            for iF = 1:obj.nFactors
                nLevels(iF) = length(factors(iF).levels);
            end
            obj.nLevels = nLevels;
                        
            % nRepetitions
            if length(varargin)==1
                obj.nRepetitions = 1; % default
            else
                obj.nRepetitions = varargin{2};
            end
            
            % factors
            obj.factors = {factors.name};
            
            % levels
            levels = cell(1,obj.nFactors);
            for iF = 1:obj.nFactors
                levels2 = cell(1,obj.nLevels(iF));
                for iL = 1:obj.nLevels(iF)
                    levels2{iL} = factors(iF).levels{iL};
                end
                levels{iF} = levels2;
            end
            obj.levels = levels;
        end
        function assemble_full_factorial(obj)
            % assemble full factorial design
            
            % pull data
            nF = obj.nFactors;
            nL = obj.nLevels;
            nR = obj.nRepetitions;
            f = obj.factors;
            
            % add repetitions as a level
            L = [nL nR];
            
            % assemble full factorial design
            obj.design = fullfact(L);
            obj.nTrials = size(obj.design,1);
        end
        function prepareDisplayFormatting(obj)
            % find length of factor name or level name, whichever is the
            % longest, and store lengths in a hidden property: obj.longestNameLength
            for j = 1:obj.nFactors
                factorNameLength = length(obj.factors{j});
                longestLevelNameLength = length(obj.levels{j}{1});
                for k = 2:length(obj.levels{j})
                    levelNameLength = length(obj.levels{j}{k});
                    if levelNameLength > longestLevelNameLength
                        longestLevelNameLength = levelNameLength;
                    end
                end
                if factorNameLength > longestLevelNameLength
                    obj.longestNameLengths(j) = factorNameLength;
                else
                    obj.longestNameLengths(j) = longestLevelNameLength;
                end
            end
            
            % find column character widths, for displaying correct spacing
            % between columns
            columnCharacterWidths_temp = obj.defaultColumnCharacterWidth*ones(obj.nFactors+2,1);
            for iF = 1:obj.nFactors
                if obj.longestNameLengths(iF) <= obj.defaultColumnCharacterWidth % default number of characters to display
                    columnCharacterWidths_temp(iF+1) = obj.defaultColumnCharacterWidth;
                else % use a multiple of 5 for number of characters
                    columnCharacterWidths_temp(iF+1) = 5*idivide(obj.longestNameLengths(iF)+1,int16(5),'ceil');
                end
            end
            columnCharacterWidths_temp(end) = obj.defaultColumnCharacterWidth;
            obj.columnCharacterWidths = columnCharacterWidths_temp;
            
            % assemble header string
            headerString_temp = sprintf(['%' num2str(obj.columnCharacterWidths(1)) 's'],'TRIAL#:');
            for iF = 1:obj.nFactors
                
                factorString = upper([obj.factors{iF} ':']); % pull factor name
                formatString = ['%' num2str(obj.columnCharacterWidths(iF+1)) 's'];
                
                headerString_temp = [headerString_temp sprintf(formatString,factorString)];
            end

            obj.headerString_noRep = headerString_temp;
            obj.headerString = [headerString_temp sprintf(['%' num2str(obj.columnCharacterWidths(end)) 's'],'REP:')];
            
        end
        function trial = getTrialString(obj,trialNumber,repetitionFlag)
            % assemble trial string
            trial = sprintf(['%' num2str(obj.columnCharacterWidths(1)) 'd'],trialNumber);
            for iF = 1:obj.nFactors
                levelName = obj.levels{iF}{obj.design_ordered(trialNumber,iF)};
                trial = [trial sprintf(['%' num2str(obj.columnCharacterWidths(iF+1)) 's'], levelName)];
            end
            
            if repetitionFlag
                trial = [trial sprintf(['%' num2str(obj.columnCharacterWidths(end)) 'd'],obj.design_ordered(trialNumber,end))];
            end
        end
        function header = getHeaderString(obj,repetitionFlag)
            % choose the correct header to diplay
            if repetitionFlag

                header = obj.headerString;
            else
                header= obj.headerString_noRep;
            end
        end
    end
end

