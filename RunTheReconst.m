% Reconstruction process main script

% Settings
showPlots = true;
alphabet = 3;

% Data File
data_file = 'Data/IBM.csv';

% Open the file
[T, P, err] = getPricesFromFile(data_file);

% Get the 1-day returns
[ r_time , returns , r_err ] = nDayReturns( T , P );

% Get the code
[ code, c_err ] = codify( returns , alphabet );

% Split the code in two roughly equal parts
n = length( code );
N = floor( n/2 );
firstHalf = code(1:N);
secondHalf = code(N+1:end);

% Get the Markov matrix for the first half
[ probMtx, m_err ] = markovMatrix(firstHalf);

% Generate the sequence through a reconstruction process
[ forecast, f_err ] = procRcnst(probMtx, secondHalf);