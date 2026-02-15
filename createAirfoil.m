
%% input parameters

wu = [ 1 1 1 1 1];               % weight on upper airfoil surface
wl = [-0.1 -1 -0.1 -0.1 -0.1];   % weight on lower airfoil surface
te = 0;                          % trailing edge thickness, typically 0
N  = 100;                        % number of coordinates along airfoil to output
name = 'airfoil.txt'             % name of airfoil file to output

%% generate airfoil
coordinates = CST_airfoil(wl, wu, te, N);

%% plot airfoil to screen
plot(coordinates(:,1), coordinates(:,2))
axis equal

%% output file
fid = fopen(name,"w");
for i=1:N
    fprintf(fid, "%8.4f %8.4f\n", coordinates(i,1), coordinates(i,2));
end

% add last coordinate to close airfoil
fprintf(fid, "%8.4f %8.4f\n", 1, 0);
