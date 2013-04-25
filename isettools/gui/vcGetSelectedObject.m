function [val,sOBJECT] = vcGetSelectedObject(objType)
%Returns the number of the currently selected object of some type
%
%   [val,sOBJECT] = vcGetSelectedObject(objType)
%
% This routine returns both the number and object itself, if requested. You
% may wish to use vcGetObject(objType) in general.  That routine returns
% the currently selected object, of objType.
%
% The set of possible objects returned are:
%
%   SCENE, PIXEL, OPTICS, {OPTICALIMAGE,OI}, VCIMAGE, GRAPHWIN, {ISA, SENSOR}
%
%  Originally, this routine was the main one used to return objects.
%
%  val = vcGetSelectedObject('SCENE')
% [val, pixel] = vcGetSelectedObject('PIXEL')
% [val, sensor] = vcGetSelectedObject('SENSOR')
% [val, vci] = vcGetSelectedObject('VCIMAGE')
% [val, vci] = vcGetSelectedObject('IMGPROC')
% [val, display] = vcGetSelectedObject('DISPLAY')
%
% As of May 2004, I started using
%    obj = vcGetObject(objType)
%    obj = vcGetObject(objType,val)
%
% Currently, I only use this routine if I need the val
%
%    val = vcGetSelectedObject('foo')
%
% Copyright ImagEval Consultants, LLC, 2005.

global vcSESSION

val = [];

if strcmpi(objType,'oi'), objType = 'OPTICALIMAGE'; end
objType = upper(objType);

if ieNotDefined('val')
    switch lower(objType)
        case 'scene'
            if checkfields(vcSESSION,'SELECTED','SCENE'), val = vcSESSION.SELECTED.SCENE;  end
        case {'opticalimage','optics','oi'}
            if checkfields(vcSESSION,'SELECTED','OPTICALIMAGE'), val = vcSESSION.SELECTED.OPTICALIMAGE;  end
        case {'isa','pixel','sensor'}
            if checkfields(vcSESSION,'SELECTED','ISA'), val = vcSESSION.SELECTED.ISA;  end
        case {'vcimage','imgproc','display'}
            if checkfields(vcSESSION,'SELECTED','VCIMAGE'), val = vcSESSION.SELECTED.VCIMAGE;  end
        otherwise,
            error('Unknown object type.');
    end
end

if nargout == 2
    sOBJECT = vcGetObject(objType,val);
end

return
