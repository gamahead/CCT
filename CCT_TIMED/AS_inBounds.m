function [isInBounds] = AS_inBounds(coords,rect)
% Are the current 1x2 coordinates within the given 1x4 rectangle [x1 y1 x2 y2]? (0/1)

isInBounds = (rect(1)<=coords(1) && rect(3)>=coords(1) && ...
    (rect(2)<=coords(2) && rect(4)>=coords(2))...
    || (rect(2)>=coords(2) && rect(4)<=coords(2)));


return