function [whichKey, rt_first, breakKeyPressed,rt_end] = AS_collectResponse(responseWait,deviceNum,keyArray,breakKey)

%% Currently set to return after button press



FlushEvents('keyDown');


if nargin > 1
    dGiven = 1;
else
    dGiven = 0;
    deviceNum = -1;
end
if ~exist('breakKey','var')
    breakKey = '';
end


t1 = GetSecs;
t2 = 0;
responseExit = t1 + responseWait;

breakKeyPressed = 0;

% while(1)
    [t2, keyCodeX, RTstruct.timeToFirst] = AS_KbWait(deviceNum,0,responseExit-GetSecs);
%     t1_while = GetSecs;
    
    if ~isempty(breakKey) && ~isempty(find(~isnan(keyCodeX))) ...
           && ~isempty(find(strcmpi(KbName(keyCodeX),breakKey)))
        breakKeyPressed = 1;
        ch1 = nan; ch2 = nan;
    elseif ~isnan(keyCodeX) 
        [ch1, RTstruct.when1]=AS_GetChar;
        [ch2, RTstruct.when2]=AS_GetChar(1,0,.25);
        
        if ~isletter(ch2) && isempty(str2num(ch2))
            ch1 = nan; ch2 = nan;
        end
    else
        ch1 = nan; ch2 = nan;
    end
% end
t_end = GetSecs-t1;

whichKey = [ch1,ch2];
   
if length(unique(whichKey))<2
    whichKey = nan;
end

% The reaction time is converted from seconds to
% milliseconds by multiplying it by 1000 and rounding.

nonResponse = 0;

if isnan(whichKey(1)) || length(whichKey)<2 % if timed out!
    whichKey = -1;
elseif length(whichKey)~=2
    disp('length ~= 2')
    keyboard
else
    for ri = 1:length(whichKey)
        % %         whichKey(ri)
        % %         (find(keyArray == (whichKey(ri))))
        % keyboard
        if ~isempty((find(keyArray == (whichKey(ri)))))
            tmpKeys(ri) = (find(keyArray == (whichKey(ri))));
        else
            tmpKeys(ri) = nan;
            nonResponse = 1;
        end
    end
    if ~nonResponse
        whichKey = tmpKeys;
    else
        whichKey = -1;
    end
end
% % % % elseif exist('keyArray','var')
% % % %     whichKey = find(keyArray == str2num(whichKey(1)));
% % % %     if isempty(whichKey)
% % % %         whichKey = -1;
% % % %     end
% % % % elseif ischar(whichKey(1))
% % % %     whichKey = str2num(whichKey(1));
% % % % else
% % % %     whichKey = whichKey(1);
% % % % end

rt_first = (t2 - t1) * 1000;
rt_first = round(rt_first);
rt_end = t_end * 1000;
rt_end = round(rt_end);
% % else
% % 	whichKey = NaN;
% % 	rt = NaN;
% % end

% This return indicates the end of the function.
% whichKey
% rt
return
