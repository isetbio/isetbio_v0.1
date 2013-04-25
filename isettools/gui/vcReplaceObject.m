function vcReplaceObject(obj,val)
%Replace an object in the vcSESSION variable
%
%    vcReplaceObject(obj,[val])
%
% Replace an existing object, either a SCENE,VCIMAGE,OPTICS, PIXEL,
% OPTICALIMAGE, or ISA, in the vcSESSION global variable.
%
% val is  the number of the object to be replaced.  If val is not
% specified, then the currently selected object is replaced. 
%
% When  replacing OPTICS or PIXEL the val refers to the OPTICALIMAGE or
% SENSOR that contain the OPTICS or PIXEL.
%
% The object that is replaced is not necessarily selected as the current
% object.  To replace and select, use vcReplaceAndSelectObject, or
% vcSetSelectedObject. 
%
% Examples:
%   vcReplaceObject(oi,3);
%   vcReplaceObject(oi);
%   vcReplaceObject(ISA,val);
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming TODO
% Rather than make the assignments here, we should probably add this to
% ieSessionSet. as in 
%     ieSessionSet('scene',scene,val); or
%     ieSessionSet('oi',oi,3);
%
% Right now, ieSession doesn't support these assignments.  Sigh.

global vcSESSION;

objType = vcGetObjectType(obj);
objType = vcEquivalentObjtype(objType);

% We select the object, too, if there were no previous objects
selectToo = 0;

if ieNotDefined('val')
    val = vcGetSelectedObject(objType); 
    if isempty(val),  val = 1;  selectToo = 1; end
end


switch lower(objType)
    case 'scene'
        vcSESSION.SCENE{val} = obj;
    case 'opticalimage'
        vcSESSION.OPTICALIMAGE{val} = obj;
    case 'optics'
        vcSESSION.OPTICALIMAGE{val}.optics = obj;
    case 'isa'
        vcSESSION.ISA{val} = obj;
    case 'pixel'
        vcSESSION.ISA{val}.pixel = obj;
    case 'vcimage'
        vcSESSION.VCIMAGE{val} = obj;
    otherwise
        error('Unknown object type');
end

if selectToo, vcSetSelectedObject(objType,val); end


return;
