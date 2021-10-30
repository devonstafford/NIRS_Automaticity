restString = {'Rest and quietly count forward from 1','Stop and Rest. Quietly count forward from 1'};
endString = {'Relax'};
dispStringsB = {'Stand and alphabet, every 2 letters. Start with B',...
   'Walk and alphabet, every 2 letters. Start with B',...
   'Walk', 'Stand and alphabet, every 3 letters. Start with B', ...
   'Walk and alphabet, every 3 letters. Start with B'};
dispStringsA = {'Stand and alphabet, every 2 letters. Start with A',...
   'Walk and alphabet, every 2 letters. Start with A',...
   'Walk', 'Stand and alphabet, every 3 letters. Start with A', ...
   'Walk and alphabet, every 3 letters. Start with A'};
dispStrings = {dispStringsB;dispStringsC};

%%
for ite = 1:3
disp('')
randomOrder = randperm(5,5)
% randAlpha = randi([0,1],[1,5]) + 1
% now balance the letters, try with 1/3 vs 2/3 probability
randAlpha = nan(1,5);
for j = 1:5
    if (rand(1) < 2/3)
        randAlpha(j) = 2;
    else
        randAlpha(j) = 1;
    end
end
randAlpha
disp(restString{1})
for i = 1:5
    disp(dispStrings{randAlpha(i)}{randomOrder(i)})
    disp(restString{2})
end
disp(endString{1})
disp('')
end

%% generate numbers rep of the task string
dispStrings = {'Stand and alphabet, every 2 letters. Start with A',...
   'Walk and alphabet, every 2 letters. Start with A',...
   'Walk', 'Stand and alphabet, every 3 letters. Start with A', ...
   'Walk and alphabet, every 3 letters. Start with A',...
   'Stand and alphabet, every 2 letters. Start with B',...
   'Walk and alphabet, every 2 letters. Start with B',...
   'Stand and alphabet, every 3 letters. Start with B', ...
   'Walk and alphabet, every 3 letters. Start with B'};
taskOrdersNum = nan(12,5);
for row = 1:12
    colIdx = 1;
    for col = [2,4,6,8,10]
        taskOrdersNum(row, colIdx) = find(strcmp(dispStrings, AutomaticityTaskOrdersCell{row, col}));
        colIdx = colIdx + 1;
    end
end
taskOrdersNum = taskOrdersNum;

for row = 1:12
    fprintf('%d %d %d %d %d;',taskOrdersNum(row,1),taskOrdersNum(row,2),taskOrdersNum(row,3),taskOrdersNum(row,4),taskOrdersNum(row,5))
end
