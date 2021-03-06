function [w] = AS_CCT_drawCards(w,p,t)

% Josh Rose: Whoever did this hardcoded all of the width information, so I'm making a
% generic 'change width' variable to use to shift every width over by
% whatever one specifies 'd_width' to be. It should shift the entire game
% over by that many pixels
d_width = -293;

if ~t.practiceCard
    Screen(w, 'TextSize', 18);
    Screen(w, 'TextStyle', 0);
    Screen('FillRect', w,p.greyBoxes,[494+d_width 25 659+d_width 75]);
    Screen('FrameRect', w,p.black,[494+d_width 25 659+d_width 75],3);
    Screen('DrawText', w,['Game Round: ',num2str(t.round)],504+d_width,40,4);
    Screen('FillRect', w,p.greyBoxes,[1173+d_width 25 1419+d_width 75]);
    Screen('FrameRect', w,p.black,[1173+d_width 25 1419+d_width 75],3);
    Screen('DrawText', w,['Current Round Total:   ',num2str(t.curTotal)],1179+d_width,40,4);
    Screen('FillRect', w,p.greyBoxes,[529+d_width 100 689+d_width 150]); %EG: Original [85 100 260 150]
    Screen('FrameRect', w,p.black,[529+d_width 100 689+d_width 150],3); %EG: Original [85 100 260 150]
    Screen('DrawText', w,['Loss Amount: ',num2str(t.lossAmount)],539+d_width,115,4);
    Screen('FillRect', w,p.greyBoxes,[869+d_width 100 1031+d_width 150]); %EG: Original [425 100 590 150]
    Screen('FrameRect', w,p.black,[869+d_width 100 1031+d_width 150],3); %EG: width162 Original [425 100 590 150]
    Screen('DrawText', w,['Gain Amount: ',num2str(t.gainAmount)],879+d_width,115,4); %EG: original 435, 115,4
    Screen('FillRect', w,p.greyBoxes,[1144+d_width 100 1404+d_width 150]); %EG: width260 [700 100 940 150]
    Screen('FrameRect', w,p.black,[1144+d_width 100 1404+d_width 150],3); %EG: Original [700 100 940 150]
    Screen('DrawText', w,['Number of Loss Cards:  ',num2str(t.lossCards)],1154+d_width,115,4);
    
    Screen('FillRect', w,p.greyBoxes,[829+d_width 25 1059+d_width 75]);
    Screen('FrameRect', w,p.black,[829+d_width 25 1059+d_width 75],3);
    
    if ~t.flipAll
        Screen('DrawText', w,['Time Remaining:   ',...
            num2str(p.trialTimeLimit-floor(GetSecs-t.curTrialStartSecs))],859+d_width,40,4);
    else  % trial over - freeze timer:
        Screen('DrawText', w,['Time Remaining:   ',...
            num2str(p.trialTimeLimit-floor(t.curTrialEndSecs-t.curTrialStartSecs))],859+d_width,40,4);
    end

    if ~t.hot && p.origCold
        Screen('FillRect', w,p.greyBoxes,squeeze(p.coldRects(:,1,:))');
        Screen('FrameRect', w,p.black,squeeze(p.coldRects(:,1,:))',1);
        
        if t.onColdCard
            Screen('FillRect', w,p.white,squeeze(p.coldRects(t.onColdCard,1,:)));
            Screen('FrameRect', w,p.black,squeeze(p.coldRects(t.onColdCard,1,:)),3);
        end
        Screen(w, 'TextSize', 14);
%         Screen('DrawText', w,p.coldCardLabels,p.coldRects(1,1,1),p.coldRects(1,1,4)-20,4);
for xi=1:size(p.coldRects,1)
    if xi<10
        Screen('DrawText', w,num2str(xi),p.coldRects(xi,1,1)+6,p.coldRects(xi,1,4)-25,4);
    else
        Screen('DrawText', w,num2str(xi),p.coldRects(xi,1,1)+2,p.coldRects(xi,1,4)-25,4);
    end
end
      
% %         if t.onColdCard && (t.onColdCard==xi)
% %                 if t.onColdCard && (t.onColdCard==xi)
% %                     Screen('FillRect', w,p.white,squeeze(p.coldRects(xi,1,:)));
% %                     Screen('FrameRect', w,p.black,squeeze(p.coldRects(xi,1,:)),3);
% %                 else
% %                     Screen('FillRect', w,p.greyBoxes,squeeze(p.coldRects(xi,1,:)));
% %                     Screen('FrameRect', w,p.black,squeeze(p.coldRects(xi,1,:)),1);
% %                 end
% %             end
% %         end
    else
        Screen(w, 'TextSize', 20);
        Screen(w, 'TextStyle', 1);
        if t.onNC || t.flipAll || ~isempty(find(t.flippedCards))
            Screen('FillRect', w,p.greyBoxes,p.ncRect);
        else
            Screen('FillRect', w,p.white,p.ncRect);
        end
        Screen('FrameRect', w,p.black,p.ncRect,5);
        Screen('DrawText', w,['No Card'],p.ncText(1),p.ncText(2),4);

        if t.onStop || t.flipAll
            Screen('FillRect', w,p.greyBoxes,p.stopRect);
        else
            Screen('FillRect', w,p.white,p.stopRect);
        end
        Screen('FrameRect', w,p.black,p.stopRect,5);
        Screen('DrawText', w,['STOP/Turn Over'],p.stopText(1),p.stopText(2),4);

        if (t.onNext && t.flipAll) || ~t.flipAll
            Screen('FillRect', w,p.greyBoxes,p.nextRect);
        else
            Screen('FillRect', w,p.white,p.nextRect);
        end
        Screen('FrameRect', w,p.black,p.nextRect,5);
        Screen('DrawText', w,['Next Round'],p.nextText(1),p.nextText(2),4);
    end
end

Screen(w, 'TextSize', 50);
Screen(w, 'TextStyle', 0);
% make more efficient by submitting all rects to one FillRect call? test!
for xi=1:size(p.cardRects,1)
    for yi=1:size(p.cardRects,2)
% %         p.cardRects(xi,yi,:) = (p.cardRect+p.baseShift+p.XsepMult*(xi-1)+p.YsepMult*(yi-1));
        Screen('FillRect', w,p.stimColors{t.cardColors(xi,yi)},squeeze(p.cardRects(xi,yi,:)));
        if t.flippedCards(xi,yi)
            Screen('FrameRect', w,p.black,squeeze(p.cardRects(xi,yi,:)),p.cardChooseWidth);
        else
            Screen('FrameRect', w,p.black,squeeze(p.cardRects(xi,yi,:)),2);
        end
        
        if (t.hot && t.flippedCards(xi,yi)) || t.flipAll
            if t.curReinfs(xi,yi)
                Screen(w, 'TextSize', 45);
                Screen('DrawText', w, p.reinfSymbols{t.curReinfs(xi,yi)+1}, squeeze(p.cardRects(xi,yi,1))+round(p.cardRect(3)*.355),...
                    squeeze(p.cardRects(xi,yi,4))-round(p.cardRect(4)*.8),p.grey);
            else
                Screen(w, 'TextSize', 45);
                Screen('DrawText', w, p.reinfSymbols{t.curReinfs(xi,yi)+1}, squeeze(p.cardRects(xi,yi,1))+round(p.cardRect(3)*.285),...
                    squeeze(p.cardRects(xi,yi,4))-round(p.cardRect(4)*.8),p.grey);
            end
        else
            Screen(w, 'TextSize', 40);
            Screen('DrawText', w, '?', squeeze(p.cardRects(xi,yi,1))+round(p.cardRect(3)*.3),...
                squeeze(p.cardRects(xi,yi,4))-round(p.cardRect(4)*.8),p.black);
        end
    end
end

return