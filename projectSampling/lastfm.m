addpath('bin'); clc;
% read data
filename = 'data\lastfm.dat';
delimiter = '\t';
startRow = 2;
formatSpec = '%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, ...
    'Delimiter', delimiter, ...
    'EmptyValue' ,NaN,...
    'HeaderLines' ,startRow-1, ...
    'ReturnOnError', false);
fclose(fileID);
userID = dataArray{:, 1};
itemID = dataArray{:, 2};
tagID = dataArray{:, 3};
posts = dataArray{:, 4};

% construct sparse tensor
sp_tensor = sptensor([userID,itemID,tagID],posts);
clearvars filename delimiter startRow formatSpec ;
clearvars fileID dataArray ans ;
clearvars tagID userID posts itemID;

% use cp_als to do decomposition
Rank = 200;
CP = cp_als(sp_tensor,Rank); 
lambda = CP.lambda;
A = zeros(size(CP.u{1}));
B = zeros(size(CP.u{2}));
C = zeros(size(CP.u{3}));
for i =1:Rank
    A(:,i) = CP.u{1}(:,i)*lambda(i); 
    B(:,i) = CP.u{2}(:,i)*lambda(i); 
    C(:,i) = CP.u{3}(:,i)*lambda(i);
end
clearvars sp_tensor CP lambda Rank;
% save the result
save('data\lastfm\A.mat','A');
save('data\lastfm\B.mat','B');
save('data\lastfm\C.mat','C');

% vars to record

samples = power(10,3:7); % number of samples
top = power(10,0:3); % find the top-t value
varSize = [size(samples,2),size(top,2)];
diamondRecall = zeros(varSize); % recall of diamond sampling 
wedgeRecall = zeros(varSize); % recall of wedge sampling
diamondTimes = zeros(size(samples));
wedgeTimes = zeros(size(samples));

% do exhaustive search
A = A'; B = B'; C= C';
tic;
valueTrue = exact_search_three_order_tensor(A,B,C);
exactTime = toc*ones(size(samples));
% save the true value and time
save('data\lastfm\valueTrue.mat','valueTrue');
save('data\lastfm\exactTime.mat','exactTime');

% arrange data formate to do sampling
B = B'; C = C';
% sampling
for i = 1:size(samples,2) 
    tic;
    [~,wedgeValues] = wedgeTensor(A,B,C,samples(i),samples(i)); 
    wedgeTimes(i) = toc;
    tic; 
    [~,diamondValues] = diamondTensor(A,B,C,samples(i),samples(i));
    diamondTimes(i) = toc;
    for j = 1 : size(top,2)
        t = top(j);
        if(size(diamondValues,1) < t)
            t = size(diamondValues,1);
        end
        diamondRecall(i,j) = sum(diamondValues(1:t) >= valueTrue(t))/t;
        t = top(j);
        if(size(wedgeValues,1) < t)
            t = size(wedgeValues,1);
        end        
        wedgeRecall(i,j) = sum(wedgeValues(1:t) >= valueTrue(t))/t; 
    end
end

% draw time - sample
timeSample = figure; hold on;title('Time-Samples'); 
xlabel('log_{10}Samples'); 
ylabel('log_{10}T(sec)'); 
plot(log10(samples),log10(exactTime),'b','LineWidth',2);
plot(log10(samples),log10(diamondTimes),'r','LineWidth',2); 
plot(log10(samples),log10(wedgeTimes),'--g','LineWidth',2);
legend('exhaustive','diamond','wedge');
saveas(timeSample,'sample-time-diamond.png'); 
% draw recall - sample
recallSample = figure; hold on; title('Recall'); 
xlabel('log_{10}Samples'); 
ylabel('recall');
c = ['r','b','k','g'];

for i = 1:size(top,2)
    plot(log10(samples),diamondRecall(:,i),c(i),'LineWidth',2);
    plot(log10(samples),wedgeRecall(:,i),['--',c(i)],'LineWidth',2); 
end
legend('diamond:t=1','wedge:t=1',...
       'diamond:t=10','wedge:t=10',...
       'diamond:t=100','wedge:t=100',...
       'diamond:t=1000','wedge:t=1000');  
saveas(recallSample,'sample-recall-diamond.png'); 