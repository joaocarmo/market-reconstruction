% Reconstruction process main script

% Settings
showPlots = true; % Display results in plots
saveErrors = false; % Save the error values in a file
alphabet = 5; % How many intervals to use for the coding alphabet
K = 8; % How long should the max k-markov chain be
numSim = 10; % How many simulations to run
logTheResults = false; % Should store the results in a text file
writeToFolder = 'Results'; % Where to store the results

% Data File
% data_file = 'Data/IBM.csv';
% data_file = 'Data/FB.csv';
data_file = 'Data/GOOG.csv';

% Open the file
[ T0, P0, ~ ] = getPricesFromFile(data_file);

% Detred the data with a given polynomial degree
poly = 3;
[ T, P, ~ ] = preProcess(T0, P0, poly);

% Get the 1-day returns
[ r_time , returns , r_err ] = nDayReturns( T , P );

% Get the code
[ code, c_err ] = codify( returns , alphabet );

% Split the code into two roughly equal parts
n = length( code );
N = floor( n/2 );
firstHalf = code(1:N);
secondHalf = code(N+1:2*N);

% Pre-allocate the memory for the errors
errorsArr1 = cell(K-1, 1);
errorsArr2 = cell(K-1, 1);
errorsArr3 = cell(K-1, 1);
errorsRandArr1 = cell(K-1, 1);
errorsRandArr2 = cell(K-1, 1);
errorsRandArr3 = cell(K-1, 1);

% And for the plots
method1 = zeros(K-1, 1);
method2 = zeros(K-1, 1);
method3 = zeros(K-1, 1);
methodRand1 = zeros(1, 1);
methodRand2 = zeros(1, 1);
methodRand3 = zeros(1, 1);

% And the Ks
kAxis = linspace(2,K,K-1);

% Do the simulations for all Ks
for j=2:K

    % Display the current calculation
    disp(['K = ',num2str(j)]);
    
    % Pre-allocate the memory for the forecasts
    forecastArr = cell(numSim, 1);
    randForecastArr = cell(numSim, 1);

    for i=1:numSim
        % Get the forecast for the second half of coded data
        display(['Calculating forescast ',num2str(i),' of ',num2str(numSim)]);
        [ forecastArr{i}, randForecastArr{i}, ~ ] = procBlockRcnst(firstHalf, secondHalf, K, alphabet);
    end

    % Calculate the errors
    %errorsArr1{j-1} = calcBlockErrors(forecastArr, secondHalf, 1);
    %errorsArr2{j-1} = calcBlockErrors(forecastArr, secondHalf, 2);
    errorsArr3{j-1} = calcBlockErrors(forecastArr, secondHalf, 3);
    %errorsRandArr1{j-1} = calcBlockErrors(randForecastArr, secondHalf, 1);
    %errorsRandArr2{j-1} = calcBlockErrors(randForecastArr, secondHalf, 2);
    errorsRandArr3{j-1} = calcBlockErrors(randForecastArr, secondHalf, 3);

    % Write the results to a text file in the specified sub-folder
    if logTheResults
        writeToFile(writeToFolder, forecastArr, firstHalf, secondHalf, alphabet, K);
    end
    
    % disp(mean(errorsArr1{j-1}));
    %method1(j-1) = mean(errorsArr1{j-1});
    % disp(mean(errorsRandArr1{j-1}));
    %methodRand1(j-1) = mean(errorsRandArr1{j-1});
    
    % disp(mean(errorsArr2{j-1}));
    %method2(j-1) = mean(errorsArr2{j-1});
    % disp(mean(errorsRandArr2{j-1}));
    %methodRand2(j-1) = mean(errorsRandArr2{j-1});
    
    % disp(mean(errorsArr3{j-1}));
    method3(j-1) = mean(errorsArr3{j-1});
    % disp(mean(errorsRandArr3{j-1}));
    methodRand3(j-1) = mean(errorsRandArr3{j-1});
    
end

% Display the results
if showPlots
    %figure;
    %plot(kAxis,method1,'x',kAxis,methodRand1,'o');
    %xlabel('K');
    %ylabel('Error: Method 1');
    %title('Average error of the simulations');
    %legend('Markov','Random','Location','best');

    %figure;
    %plot(kAxis,method2,'x',kAxis,methodRand2,'o');
    %xlabel('K');
    %ylabel('Error: Method 2');
    %title('Average error of the simulations');
    %legend('Markov','Random','Location','best');
    
    figure;
    plot(kAxis,method3,'x',kAxis,methodRand3,'o');
    xlabel('K');
    ylabel('Error');
    title('Average error of the simulations');
    legend('Markov','Random','Location','best');
end

% Save the error values in a file
if saveErrors
    writeErrorsToFile(writeToFolder, kAxis, method1, methodRand1)
    writeErrorsToFile(writeToFolder, kAxis, method2, methodRand2)
    writeErrorsToFile(writeToFolder, kAxis, method3, methodRand3)
end