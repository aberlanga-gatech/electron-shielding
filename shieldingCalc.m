%% Alfredo Berlanga 
% Georgia Institute of Technology
% BS Mechanical Engineering
% aberlanga@gatech.edu
%
%% Vers: 1.1.3
%% Last updated: April 5 2021
%% * Changelog *
%     - Implements recursion
%     - Returns a graph of Zeff as a function of Z given if 'g' is passed
%     - Added datatips and fixed graph
%     - Added exceptions in case noble gas config is erroneous
%     - Exceptions need polishing (idk how to do exceptions correctly)
%
%% * Description *
% A function that returns the electrostatic character of an element given
% the noble gas configuration and s,p valence electrons for elements up to
% Xenon based on what was taught in CHEM 1310 according to Slater's Rules:
% S_tot = (E_core * 0.85)+ 0.35*(E_valence - 1)
%
%%

function out = shieldingCalc(nob,spVal)
% args: (nob,spVal)
%       --> noble gas config
%       --> s and p valence electrons
% args: ('g') --> prints a graph of Zeff as f(Z)
%       --> if singular arg & ~= 'g', ignores arg
% no args: prompts user to define nob and spVal

    % recursion 1: check if only one argument == 'g', display graph if true
    if nargin == 1
        if lower(nob) == 'g'
            out = shieldingGraph();
            return;
        else
            out = shieldingCalc();
            return;
        end
    end

    % recursion 2: check if no args, prompt to define nob and spVal
    if ~nargin
        nob = input('Noble Config: ','s');
        if lower(nob) == 'h'
            spVal = 1;
        else
            spVal = input('Number of s and p valence electrons: ');
        end
    end

    % check [Ne] configuration input, if d subshell, add 10 electrons
    % only non-transition elements can be calculated bc idk the theory for
    % the rest; it's not in the syllabus and has many exceptions
    try
        switch lower(nob)
            case 'h'
                core = 0;
            case 'he'
                core = 2;
            case 'ne'
                core = 10;
            case 'ar'
                if spVal > 2, core = 28; else, core = 18; end
            case 'kr'
                if spVal > 2, core = 46; else, core = 36; end
            case 'xe'
                if spVal > 2, core = 64; else, core = 54; end
            otherwise
                invalidGas = MException('MyComponent:noSuchVariable');
        end
    catch invalidGas
        out = shieldingCalc();
        return;
    end
    
    % output data as a struct, that way, you can get all the info fast
    out = struct();
    out.S = (core*0.85)+((spVal-1)*(0.35));
    out.Z = core+spVal;
    out.Zeff = out.Z - out.S;
    out.ZeffPerc = out.Zeff / out.Z;
    disp(out); % when running with 'g' arg, 34 disps... needs addressing 
    
    % function to plot all non-transition elements from hydrogen to xenon
    % in a graph that has labels and tells you the element name. would be a
    % good idea to add more data to inspect in the future...
    function graph = shieldingGraph()
        load('elementNames.mat','names');
        X = [1,2]; % init with hydrogen and helium; exceptions to the rule
        Y = [1,1.7]; % '' '' ''
        for n = {'he','ne','ar','kr'} % iterate through shells
            for v = 1:8 % iterate through valence electrons
                curr = shieldingCalc(n{1},v); % recursion 3, SE
                Y = [Y curr.Zeff];
                X = [X curr.Z];
            end
        end
        
        % plotting stuff... pretty straight forward
        graph = plot(X,Y,'Marker','o');
        axes = gca;
        xaxis = xlabel(axes,'Z');
        yaxis = ylabel(axes,'Zeff');
        graph.DataTipTemplate.DataTipRows(1).Label = 'Z:';
        graph.DataTipTemplate.DataTipRows(2).Label = 'Zeff:';
        graph.DataTipTemplate.DataTipRows(3) = dataTipTextRow('Element:',names);
    end

end