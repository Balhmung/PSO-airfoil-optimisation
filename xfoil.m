    function [y]=xfoil(x)
        %% input parameters
        wu = [x(1), x(2), x(3)];    % weight on upper airfoil surface
        wl = [x(4), x(5), x(6)];
    
        
        te = 0;                     % trailing edge thickness, typically 0
        N  = 100;                   % number of coordinates along airfoil to output
        name = 'airfoil.txt';       % name of airfoil file to output
        
        %% generate airfoil
        coordinates = CST_airfoil(wl, wu, te, N);  
        
        %% output file
        fid = fopen(name,"w");
         for i=1:N
            fprintf(fid, "%8.4f %8.4f\n", coordinates(i,1), coordinates(i,2)); end
        
        % add last coordinate to close airfoil
        %fprintf(fid, "%8.4f %8.4f\n", 1, 0);
         %% runing xfoil
        system('run.bat',"-echo")
         %% Read output file 
        lines=readlines("out.txt");
    
        iii = 0;
        for i = lines.length: -1: 1
            if contains(lines(i), 'Cm =')
                iii = i;
                break;
            end
        end
        if iii == 0
            % Parsing failed (likely XFOIL crash)
            fclose(fid);
            y(1) = 0;   % CL = 0
            y(2) = 1e4; % CD = HUGE (High penalty)
            return;
        end
    
        %CL
        try
            myString = lines(iii-1);
            str=extractBetween(myString,30,35);
            left_coefficient = str2double(str);
            cl = left_coefficient;
            y(1) = cl;
            %CD
            str=extractBetween(lines(iii),30,36);
            Drag_coefficient = str2double(str);
            cd = Drag_coefficient;
            y(2) = cd;
        catch
            % Parsing error inside try block
            y(1) = 0;
            y(2) = 1e4; 
        end
    
    
        fclose(fid);
      
    end