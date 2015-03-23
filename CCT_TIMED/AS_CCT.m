function AS_CCT(screenNum)

    % Reset the random number generator
rand('twister', sum(100*clock));


%% Session Parameters

% Skip the instructions/intro? (for testing)
    p.skipIntro = 0;

% How many rounds/trials do you want total?
    p.numRounds = 5;

% Use "hot" (1) or "cold" (0) version of task?
    p.hotTrials = 1; 

% Are you using fixed feedback? (see parameters below if yes)
    p.usingFixedFeedback = 0;


% If using cold, do you want to use the original version where you just
% choose the number (1) or a slightly revised (warmer) version where you click on
% all the cards you want (0)?
    p.origCold = 0;   

% Use random colors? (can base this off of a conditioned set of colors)
% Set to 0 for all same (default: gray), set to 1 for random assortment of colors:
    p.randomColors = 0;

% CCT parameter settings: 
    p.lossAmts = [250 750];
    p.gainAmts = [10 30];
    p.lossProbs = [1 3];

% How many total cards in the array and how many rows?
    p.numCards = 32;
    p.numRows = 4;

% How much time to allow per trial?
    p.trialTimeLimit = 45;

    
% How long to wait between registeting mouse clicks (secs)?
    p.waitBetweenClicks = 0.04;
    
% % ADJUST these appropriately if using fixed feedback:
        if p.usingFixedFeedback
            % Number and range of fixed-feedback trials (choice number for loss fixed):
              p.numLowProbFixed = 21;   % Sets to last possible card choice (MUST be less than numRounds!)
              p.numHighProbFixed = 4;   % MUST be less than numRounds!
              p.highProbRange = 2:25;   % Range of possible choice numbers in high-probability case
        else
               p.numLowProbFixed = 0; p.numHighProbFixed = 0; p.highProbRange = [];   
        end    
    
    % Using multiple of full factorial of above parameters
   singleFullFact = fullfact([length(p.lossAmts) length(p.gainAmts) length(p.lossProbs)]);
   p.trialConds = [];
   for ffi = 1:ceil(p.numRounds/size(singleFullFact,1))
       p.trialConds = [p.trialConds; singleFullFact];
   end
        % Randomize order of trial conditions:
   randOrder = randperm(size(p.trialConds,1)); p.trialConds = p.trialConds(randOrder(1:p.numRounds),:);
   
    % p.trialConds columns: (1) loss amt, (2) gain amt, (3) loss prob
   p.trialConds(:,1) = p.lossAmts(p.trialConds(:,1));
   p.trialConds(:,2) = p.gainAmts(p.trialConds(:,2));
   p.trialConds(:,3) = p.lossProbs(p.trialConds(:,3));
   
   % Set trial fixed choice values (0 if not fixed, sample from
   % highProbRange if highProb, max(cards)-lossCards if lowProb):
   if p.numHighProbFixed>0
   p.trialFixedChoices = [randsample(p.highProbRange,p.numHighProbFixed,true) ...
       100*ones(1,p.numLowProbFixed) ...
       zeros(1,(p.numRounds-p.numLowProbFixed-p.numHighProbFixed))];
   else
   p.trialFixedChoices = [100*ones(1,p.numLowProbFixed) ...
       zeros(1,(p.numRounds-p.numLowProbFixed-p.numHighProbFixed))];       
   end
       % Randomize:
   p.trialFixedChoices = p.trialFixedChoices(randperm(length(p.trialFixedChoices)));
   loProbTrials = find(p.trialFixedChoices==100);
   p.trialFixedChoices(loProbTrials) = p.numCards-p.trialConds(loProbTrials,3)+1;


   
%% Set up output data structure:

D.subjectID      = {}; % subject ID
D.date        = {}; % date
D.isHot        = []; % 0 = cold (original); 0.5 = cold (warmer version); 1 = hot
D.trialNumber   = [];  % 
D.lossAmt       = [];    % 
D.gainAmt       = [];    % 
D.lossCards     = [];    % 
D.fixedChoice   = [];  % 0 if not fixed, otherwise the choice number at which loss occurs
D.numChosen     = [];  % Number of cards chosen before trial ended
D.lossChosen    = [];  % 0 = no loss card chosen; 1 = loss card chosen
D.trialReinf    = [];  % Net gain/loss for a trial



%% Set up screen and stuff:
if ~exist('screenNum')
    p.screenNum = 0;
else
    p.screenNum = screenNum;
end
p.date = datestr(now,'mm-dd-yy');
p.startTime = datestr(now,'HH:MM:SS.FFF PM');
p.subID = (input('What is the subject #? (e.g., 005): ','s'));
p.alloutdir = 'CCT_Results';   % ALL results files will save here
if ~exist(p.alloutdir,'dir')
    mkdir(p.alloutdir);
end
p.alloutfile = ['CCT',p.subID,'_',date];   % ALL results files will save here


curFID  = fopen(fullfile(p.alloutdir,[p.alloutfile '.xls']), 'a');
writeHeaderToFile(D, curFID);


load('StimColors.mat');
p.stimColors = stimColors;
if p.randomColors
    p.numColors = length(stimColors);
else
    p.numColors = 1;    
end

p.white=[255 255 255]; %WhiteIndex(wPtr);
p.black=[0 0 0]; %BlackIndex(wPtr);
p.red=[255 0 0]; %BlackIndex(wPtr);
p.grey = [228 228 228];
p.grey2 = [100 100 100];
p.greyBoxes = [200 200 200];
p.cardChooseWidth = 7;

p.cardRect=[0 0 75 100];
p.baseXshift = 125;
p.baseYshift = 250;
p.Xsep = 100;
p.Ysep = 125;
p.baseShift = [p.baseXshift p.baseYshift p.baseXshift p.baseYshift];
p.XsepMult = [p.Xsep 0 p.Xsep 0];
p.YsepMult = [0 p.Ysep 0 p.Ysep];

p.coldRect=[0 0 20 40];     % original cold card (1-32)
p.coldBaseXshift = 30;
p.coldBaseYshift = 175;
p.coldXsep = 30;
p.coldXsepMult = [p.coldXsep 0 p.coldXsep 0];
p.coldBaseShift = [p.coldBaseXshift p.coldBaseYshift p.coldBaseXshift p.coldBaseYshift];


p.ncRect = [250 175 350 225];
p.stopRect = [375 175 560 225];
p.nextRect = [585 175 725 225];
p.ncText = [260,188];
p.stopText = [390,188];
p.nextText = [600,188];

    %%%% CARD MATRIX %%%%
for xi=1:8
    for yi=1:4
        p.cardRects(xi,yi,:) = (p.cardRect+p.baseShift+p.XsepMult*(xi-1)+p.YsepMult*(yi-1));
    end
end


    %%%% ORIGINAL COLD CARD MATRIX (1-32) %%%%
    p.coldCardLabels = [];
for xi=1:32
        p.coldRects(xi,1,:) = (p.coldRect+p.coldBaseShift+p.coldXsepMult*(xi-1));
        p.coldCardLabels = [p.coldCardLabels,num2str(xi),'    '];
end
p.coldBounds = [p.coldRects(1,1,1) p.coldRects(1,1,2) p.coldRects(32,1,3) p.coldRects(1,1,4)];

p.reinfSymbols = {'+','-'};


%% Load Screen

Screen('Preference', 'SkipSyncTests',1);
Screen('Preference', 'VisualDebuglevel', 3);
Screen('Preference', 'SuppressAllWarnings', 1);

[w,rect]=Screen('OpenWindow',p.screenNum,0,[0 0 1920 1080]);
p.res = rect(2:4);
p.centerX = p.res(1)/2; % x center of main window
p.centerY = p.res(2)/2; % y center of main window

Screen('FillRect',w,p.grey);
Screen('Flip',w);
ListenChar(2);

Screen(w, 'TextFont', 'Arial');
Screen(w, 'TextStyle', 0);
Screen(w, 'TextSize', 20);

if ~p.skipIntro
%% Instructions

load('AS_CCT_instr.mat');

    %%%% Intro & Explanation:  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr1=[];
for ni = 1:length(CCTi.CCTinstr1);
    if ni<length(CCTi.CCTinstr1)     % Leaving out point about distractions for now...
        p.instr1=[p.instr1,'\n\n',CCTi.CCTinstr1{ni}];
    end
end
AS_DrawFormattedText(w,p.instr1,75,30,p.black,100,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,680,p.black,100,1.3);
Screen('Flip',w);
WaitSecs(2.0);
KbWait(-1);

    %%%% Unknown card example: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr2=[];
for ni = 1:length(CCTi.CCTinstr2);
        p.instr2=[p.instr2,'\n\n',CCTi.CCTinstr2{ni}];
end
Screen(w, 'TextSize', 24);
AS_DrawFormattedText(w,p.instr2,75,30,p.black,100,1.3);

pracP = p;
pracT.practiceCard = 1;
pracT.cardColors(1,1) = 6;
pracT.flippedCards(1,1) = 0;
pracT.curReinfs(1,1) = 0;
pracT.hot = 1;
pracT.flipAll = 0;
pracT.onColdCard = 0;
pracP.cardRects = [];
pracP.cardRects(1,1,:) = p.cardRects(4,1,:);
w=AS_CCT_drawCards(w,pracP,pracT);
Screen('Flip',w);

SetMouse(p.centerX, p.centerY+70,w)
ShowCursor(0);
while (1) % track movement
    [theX, theY, buttons] = GetMouse(w);

    if buttons(1)       % clicked on scale
        cardX = intersect(find(pracP.cardRects(:,:,1)<=theX),find(pracP.cardRects(:,:,3)>=theX));
        cardY = intersect(find(pracP.cardRects(:,:,2)<=theY),find(pracP.cardRects(:,:,4)>=theY));
        cardInd = intersect(cardX,cardY);
        if ~isempty(cardInd)
            [cx,cy] = ind2sub([size(pracP.cardRects,1),size(pracP.cardRects,2)],cardInd);
            pracT.flippedCards(cx,cy) = ~pracT.flippedCards(cx,cy);
            Screen(w, 'TextSize', 24);
            AS_DrawFormattedText(w,p.instr2,75,30,p.black,100,1.3);
            AS_DrawFormattedText(w,'Please press any key to continue...',75,680,p.black,100,1.3);
            w=AS_CCT_drawCards(w,pracP,pracT);
            Screen('Flip',w);
            break
        end
    end
    Screen(w, 'TextSize', 24);
    AS_DrawFormattedText(w,p.instr2,75,30,p.black,100,1.3);
    w=AS_CCT_drawCards(w,pracP,pracT);
    Screen('Flip',w);
end
WaitSecs(0.5);
KbWait(-1);
HideCursor;

    %%%% Gain/Loss card examples: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr3=[];
for ni = 1:length(CCTi.CCTinstr3);
        p.instr3=[p.instr3,'\n\n',CCTi.CCTinstr3{ni}];
end
pracP.cardRects = [];
pracP.cardRects(1,1,:) = p.cardRects(7,1,:);
pracP.cardRects(2,1,:) = p.cardRects(7,3,:);
pracT.cardColors(1:2,1) = 6;
pracT.flippedCards(1:2,1) = 1;
pracT.curReinfs(1,1) = 0; pracT.curReinfs(2,1) = 1;
w=AS_CCT_drawCards(w,pracP,pracT);
Screen(w, 'TextSize', 20);
AS_DrawFormattedText(w,p.instr3,75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,680,p.black,100,1.3);
AS_DrawFormattedText(w,'A Gain Card',815,280,p.black,10,1.3);
AS_DrawFormattedText(w,'A Loss Card',815,525,p.black,10,1.3);

Screen('Flip',w);
WaitSecs(2.0);
KbWait(-1);


    %%%% Trial example 1: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr4=[];
for ni = 1:length(CCTi.CCTinstr4);
    if ni<length(CCTi.CCTinstr4)     % Final point addressed post-trial
        p.instr4=[p.instr4,'\n\n',CCTi.CCTinstr4{ni}];
    end
end
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,p.instr4,75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,720,p.black,100,1.3);

Screen('Flip',w);
WaitSecs(1.0);
KbWait(-1);

exP = p;
exT.round = 1;
exT.lossAmount = 750;
exT.gainAmount = 10;
exT.lossCards = 1;
exT.practiceCard = 0;
exT.onColdCard = 0;
exT.hot = 1; % set to 1 for "hot" or flip as you go
exT.drawnCards = {[1,1],[5,1],[5,2],[4,3],[7,3],[8,3],[2,4]};
exT.rigLossCards = {};
exT.rigChoiceNumber = 10;
exRUsession = [];

[w,exP,exT,exRUsession] = AS_CCT_runTrial(w,exP,exT,exRUsession);
w=AS_CCT_drawCards(w,exP,exT);
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,'Please press any key to continue...',75,740,p.black,100,1.3);
Screen('Flip',w);
WaitSecs(1.0);
KbWait(-1);

Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,CCTi.CCTinstr4{ni},75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,720,p.black,100,1.3);
Screen('Flip',w);
WaitSecs(.5);
KbWait(-1);



    %%%% Trial example 2: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr5=[];
for ni = 1:length(CCTi.CCTinstr5);
    if ni<length(CCTi.CCTinstr5)     % Final point addressed post-trial
        p.instr5=[p.instr5,'\n\n',CCTi.CCTinstr5{ni}];
    end
end
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,p.instr5,75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,720,p.black,100,1.3);

Screen('Flip',w);
WaitSecs(1.0);
KbWait(-1);

clear exP; clear exT;
exP = p;
exT.round = 1;
exT.lossAmount = 250;
exT.gainAmount = 30;
exT.lossCards = 3;
exT.practiceCard = 0;
exT.onColdCard = 0;
exT.hot = 1; % set to 1 for "hot" or flip as you go
exT.drawnCards = {[1,1],[1,4],[8,2],[4,1]};
exT.rigLossCards = {[4,1],[6,3],[5,2]};
exRUsession = [];

[w,exP,exT,exRUsession] = AS_CCT_runTrial(w,exP,exT,exRUsession);
w=AS_CCT_drawCards(w,exP,exT);
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,'Please press any key to continue...',75,740,p.black,100,1.3);
Screen('Flip',w);
WaitSecs(1.0);
KbWait(-1);

Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,CCTi.CCTinstr5{ni},75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,720,p.black,100,1.3);
Screen('Flip',w);
WaitSecs(.5);
KbWait(-1);


    %%%% Practice Round 1: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr6=[];
for ni = 1:length(CCTi.CCTinstr6);
        p.instr6=[p.instr6,'\n\n',CCTi.CCTinstr6{ni}];
end
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,p.instr6,75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,720,p.black,100,1.3);

Screen('Flip',w);
WaitSecs(1.0);
KbWait(-1);

clear exP; clear exT;
exP = p;
exT.round = 1;
exT.lossAmount = 250;
exT.gainAmount = 30;
exT.lossCards = 1;
exT.practiceCard = 0;
exT.onColdCard = 0;
exT.hot = p.hotTrials; % set to 1 for "hot" or flip as you go
exT.drawnCards = {};
exT.rigLossCards = {};
exRUsession = [];

[w,exP,exT,exRUsession] = AS_CCT_runTrial(w,exP,exT,exRUsession);
% % w=AS_CCT_drawCards(w,exP,exT);
% % Screen(w, 'TextSize', 22);
% % AS_DrawFormattedText(w,'Please press any key to continue...',75,740,p.black,100,1.3);
% % Screen('Flip',w);
% % WaitSecs(1.0);
% % KbWait(-1);



    %%%% Practice Round 2: %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.instr7=[];
for ni = 1:length(CCTi.CCTinstr7);
        p.instr7=[p.instr7,'\n\n',CCTi.CCTinstr7{ni}];
end
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,p.instr7,75,100,p.black,65,1.3);
AS_DrawFormattedText(w,'Please press any key to continue...',75,720,p.black,100,1.3);

Screen('Flip',w);
WaitSecs(1.0);
KbWait(-1);

clear exP; clear exT;
exP = p;
exT.round = 2;
exT.lossAmount = 750;
exT.gainAmount = 10;
exT.lossCards = 3;
exT.practiceCard = 0;
exT.onColdCard = 0;
exT.hot = p.hotTrials; % set to 1 for "hot" or flip as you go
exT.drawnCards = {};
exT.rigLossCards = {};
exRUsession = [];

[w,exP,exT,exRUsession] = AS_CCT_runTrial(w,exP,exT,exRUsession);

p.instr8=[];
for ni = 1:length(CCTi.CCTinstr8);
        p.instr8=[p.instr8,'\n\n',CCTi.CCTinstr8{ni}];
end
Screen(w, 'TextSize', 22);
AS_DrawFormattedText(w,p.instr8,75,100,p.black,65,1.3);
Screen('Flip',w);
WaitSecs(.5);
KbWait(-1);

end

%% TRIALS

t.practiceCard = 0;
CCTsession = [];
for round = 1:p.numRounds
        % p.trialConds columns: (1) loss amt, (2) gain amt, (3) loss prob

    t.round = round;
    t.lossAmount = p.trialConds(round,1);
    t.gainAmount = p.trialConds(round,2);
    t.lossCards = p.trialConds(round,3);
    t.drawnCards = {};
    t.rigLossCards = {};
    t.onColdCard = 0;
    t.usingFixedFeedback = p.usingFixedFeedback;
    t.rigChoiceNumber = p.trialFixedChoices(round);
    t.hot = p.hotTrials; % set to 1 for "hot" or flip as you go
    t.lossChosen = 0;
    [w,p,t,CCTsession] = AS_CCT_runTrial(w,p,t,CCTsession);
    CCTsession.flippedCards{round} = t.flippedCards;
    if p.origCold && p.hotTrials==0
        CCTsession.numFlippedCards(round) = t.onColdCard;
    else
        CCTsession.numFlippedCards(round) = length(find(t.flippedCards(:)));
    end
    CCTsession.finalReinf(round) = t.curTotal;
    CCTsession.tPars(round) = t;
    CCTsession.coldCard(round) = t.onColdCard;
    
    save(fullfile(p.alloutdir,p.alloutfile),'p','t','CCTsession','D');

    D.subjectID{round}      = p.subID; % subject ID
    D.date{round}        = p.date; % date
    if p.origCold
        D.isHot(round)        = 0; % 0 = cold (original); 0.5 = cold (warmer version); 1 = hot
    else
        D.isHot(round)        = (p.hotTrials+1)/2;
    end
    D.trialNumber(round)   = round;  %
    D.lossAmt(round)       = t.lossAmount;    %
    D.gainAmt(round)       = t.gainAmount;    %
    D.lossCards(round)     = t.lossCards;    %
    D.fixedChoice(round)   = t.rigChoiceNumber;  % 0 if not fixed, otherwise the choice number at which loss occurs
    D.numChosen(round)     = CCTsession.numFlippedCards(round);  % Number of cards chosen before trial ended
    D.lossChosen(round)    = t.lossChosen;  % 0 = no loss card chosen; 1 = loss card chosen
    D.trialReinf(round)    = t.curTotal;  % Net gain/loss for a trial

    writeTrialToFile(D, round, curFID);

end

    fclose(curFID);


for xyz=1:4
    ShowCursor;
end
ListenChar;

fclose('all');
sca;
clear all;
sca








%% function [p,t] = AS_CCT_runTrial(w,p,t)
function [w,p,t,CCTsession] = AS_CCT_runTrial(w,p,t,CCTsession)

t.curTrialStartSecs = GetSecs;

if ~isfield(t,'rigChoiceNumber')
    t.rigChoiceNumber=0;
end
if ~isfield(t,'rigLossCards')
    t.rigLossCards={};
end
t.curTotal = 0;

% Setting up a certain choice number (e.g., 3rd card chosen or last card chosen) to be a loss:
if (t.rigChoiceNumber>0)   % Single number indicating choice number (0 = no rigging)  
    t.curReinfs = reshape(zeros(1,p.numCards),[],p.numRows);
% Setting up a normal randomly chosen set of loss cards for the trial:
elseif isempty(t.rigLossCards)
    t.curReinfs = [ones(1,t.lossCards) zeros(1,p.numCards-t.lossCards)];
    reinfScramble = randperm(p.numCards);
    t.curReinfs = reshape(t.curReinfs(reinfScramble),[],p.numRows);
% Setting up certain cards to be loss in advance (e.g., for using example paths):
else    
    t.curReinfs = reshape(zeros(1,p.numCards),[],p.numRows);
    for rlci = 1:length(t.rigLossCards)
        t.curReinfs(t.rigLossCards{rlci}(1),t.rigLossCards{rlci}(2))=1;
    end
end

t.cardColors=reshape(mod(randperm(p.numCards),p.numColors)+1,[],p.numRows);
if ~p.randomColors
    t.cardColors = t.cardColors*6;  % grey is currently stimColors{6}
end
CCTsession.cardColors{t.round} = t.cardColors;
t.onNC = 0;
t.onStop = 0;
t.onNext = 0;
t.flipAll = 0;
t.onColdCard = 0;

t.drawPlace = 0; % if cards pre-drawn, will advance through the list of coords
t.flippedCards = zeros(size(p.cardRects,1),size(p.cardRects,2));    % which cards have been chosen
w=AS_CCT_drawCards(w,p,t);
Screen('Flip',w);

if isempty(t.drawnCards)
    moveStart = GetSecs;
    SetMouse(p.centerX, p.centerY+70,w)
    ShowCursor(0);
end
lastCardCoords = [0 0];
lastCardSecs = 0;

while (1) 
    if isempty(t.drawnCards)
        [theX, theY, buttons] = GetMouse(w);    % track movement
    elseif ~t.flipAll    % cards pre-drawn
        t.drawPlace = t.drawPlace+1;
        curDrawCoords = t.drawnCards{t.drawPlace};
        theX = mean([p.cardRects(curDrawCoords(1),curDrawCoords(2),1),...
            p.cardRects(curDrawCoords(1),curDrawCoords(2),3)]);
        theY = mean([p.cardRects(curDrawCoords(1),curDrawCoords(2),2),...
            p.cardRects(curDrawCoords(1),curDrawCoords(2),4)]);
        
        if ~isempty(t.rigLossCards)   % see if the current pre-drawn card is rigged as a loss
            for li=1:length(t.rigLossCards)
                if ~isempty(findstr(t.rigLossCards{li},curDrawCoords))  % creating rigged loss
                    if ~t.curReinfs(curDrawCoords)
                        t.curReinfs(curDrawCoords) = 1;
                        [swapXs,swapYs] = find(~t.flippedCards.*t.curReinfs);   % find unflipped, loss card
                        if ~isempty(swapXs)
                            chooseInd = ceil(rand*length(swapXs));
                            t.curReinfs([swapXs(chooseInd),swapYs(chooseInd)]) = 0;
                        end
                    end
                elseif li==length(t.rigLossCards)     % creating rigged win if no matching rigged loss
                    if t.curReinfs(curDrawCoords)
                        t.curReinfs(curDrawCoords) = 0;
                        [swapXs,swapYs] = find(~t.flippedCards.*~t.curReinfs);   % find unflipped, gain card
                        if ~isempty(swapXs)
                            chooseInd = ceil(rand*length(swapXs));
                            t.curReinfs([swapXs(chooseInd),swapYs(chooseInd)]) = 1;
                        end
                    end
                end
            end
        end
        % && ~isempty(t.drawnCards)

        buttons(1)=1;
    end

    if buttons(1)       % clicked on scale

        cardX = intersect(find(p.cardRects(:,:,1)<=theX),find(p.cardRects(:,:,3)>=theX));
        cardY = intersect(find(p.cardRects(:,:,2)<=theY),find(p.cardRects(:,:,4)>=theY));
        cardInd = intersect(cardX,cardY);
        
        if ~t.hot && p.origCold && t.onColdCard
%             disp('blah')
            WaitSecs(0.1);
            break 
        elseif ~t.hot && p.origCold
            ;
        elseif ~isempty(cardInd)
            [cx,cy] = ind2sub([size(p.cardRects,1),size(p.cardRects,2)],cardInd);
            
            if ~t.flipAll && (isempty(findstr(lastCardCoords,[cx,cy])) ...
                    || GetSecs>(lastCardSecs+p.waitBetweenClicks))
                if ~t.hot || ~t.flippedCards(cx,cy)
                    t.flippedCards(cx,cy) = ~t.flippedCards(cx,cy);
                        % If rigging by choice number and this is the n'th
                        % flipped card, changing it to be a loss:
                    if t.rigChoiceNumber && (length(find(t.flippedCards(:))) == t.rigChoiceNumber)
                        t.curReinfs(cx,cy) = 1;
                        % Also, make sure to set an appropriate number of
                        % losses among the unflipped:
                        if t.lossCards>1
                            remainingUnflipped = find(~t.flippedCards(:));
                            t.curReinfs([randsample(remainingUnflipped,t.lossCards-1)]) = 1;
                        end
                    end
                    if t.hot && t.curReinfs(cx,cy)
                        t.flipAll = 1;
                        t.curTotal = t.curTotal - t.lossAmount;
                        t.lossChosen = 1;
                        t.curTrialEndSecs = GetSecs;
                    elseif t.hot && ~t.curReinfs(cx,cy)
                        t.curTotal = t.curTotal + t.gainAmount;
                    end

                end
                lastCardCoords = [cx,cy];
                lastCardSecs = GetSecs;

            end
            %             w=AS_CCT_drawCards(w,p,t);
            %             Screen('Flip',w);
        elseif t.onStop
            % Make sure to set an appropriate number of
            % losses among the unflipped (in case pre-rigged):
            if t.rigChoiceNumber && t.lossCards>length(find(t.curReinfs(:)))
                remainingUnflipped = intersect(find(~t.flippedCards(:)),find(~t.curReinfs(:)));
                t.curReinfs([randsample(remainingUnflipped,t.lossCards-length(find(t.curReinfs(:))))]) = 1;
            end
            if ~t.hot
               t.curTotal = t.gainAmount*length(intersect(find(t.flippedCards(:)),find(~t.curReinfs(:))))...
               - t.lossAmount*length(intersect(find(t.flippedCards(:)),find(t.curReinfs(:))));
            end
                
            t.flipAll = 1;
            t.curTrialEndSecs = GetSecs;
                                    
            %                 WaitSecs(0.1);
            %                 break
        elseif isempty(find(t.flippedCards)) && t.onNC
            % Make sure to set an appropriate number of
            % losses among the unflipped (in case pre-rigged):
            if t.rigChoiceNumber && t.lossCards>length(find(t.curReinfs(:)))
                remainingUnflipped = intersect(find(~t.flippedCards(:)),find(~t.curReinfs(:)));
                t.curReinfs([randsample(remainingUnflipped,t.lossCards-length(find(t.curReinfs(:))))]) = 1;
            end

            t.flipAll = 1;
            t.curTrialEndSecs = GetSecs;

            %                 WaitSecs(0.1);
            %                 break
        elseif t.flipAll && t.onNext
            WaitSecs(0.05);
            break
        end

    end
    if AS_inBounds([theX,theY],p.ncRect)
        t.onNC = 1;
    else
        t.onNC = 0;
    end
    if AS_inBounds([theX,theY],p.stopRect)
        t.onStop = 1;
    else
        t.onStop = 0;
    end
    if AS_inBounds([theX,theY],p.nextRect)
        t.onNext = 1;
    else
        t.onNext = 0;
    end
       if ~t.hot && p.origCold && AS_inBounds([theX,theY],p.coldBounds)
           coldXintersect = intersect(find(squeeze(p.coldRects(:,1,1))<=theX),...
               find(squeeze(p.coldRects(:,1,3))>=theX));
           if ~isempty(coldXintersect)
               t.onColdCard = coldXintersect;
           else
               t.onColdCard = 0;               
           end
       else
           t.onColdCard = 0;
       end

       w=AS_CCT_drawCards(w,p,t);
    Screen('Flip',w);
    if ~isempty(t.drawnCards)
        WaitSecs(0.4);
       if t.drawPlace==length(t.drawnCards)
           if ~t.flipAll
               % Make sure to set an appropriate number of
               % losses among the unflipped (in case pre-rigged):
               if t.rigChoiceNumber && t.lossCards>length(find(t.curReinfs(:)))
                   remainingUnflipped = intersect(find(~t.flippedCards(:)),find(~t.curReinfs(:)));
                   t.curReinfs([randsample(remainingUnflipped,t.lossCards-length(find(t.curReinfs(:))))]) = 1;
               end

               t.flipAll = 1;
               t.curTrialEndSecs = GetSecs;
           else
               break
           end
       end
    end

end

return

%% function writeHeaderToFile(D, fid)
% =========================================================================
function writeHeaderToFile(D, fid)

h = fieldnames(D);

for i=1:length(h)
    fprintf(fid, '%s\t', h{i});
end
fprintf(fid, '\n');
% =========================================================================


%% function writeTrialToFile(D, trial, fid)
% =========================================================================
function writeTrialToFile(D, trial, fid)

h = fieldnames(D);
for i=1:length(h)
    data = D.(h{i})(trial);
    if isnumeric(data)   
        fprintf(fid, '%s\t', num2str(data));
    elseif iscell(data)
        fprintf(fid, '%s\t', char(data));
    else
        error('wrong format!')
    end
end     
fprintf(fid, '\n');
% =========================================================================

