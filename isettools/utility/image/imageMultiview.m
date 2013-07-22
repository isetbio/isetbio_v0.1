function selectedObjs = imageMultiview(objType, selectedObjs)
% Display multiple windows with images of selected GUI objects
%
%  selectedObjs = imageMultiview(objType, whichObjs)
%
% This routine lets the user compare the images side by side, rather than
% flipping through them in the GUI window.
%
% objType:       Which window (scene, oi, sensor, or vcimage)
% selectedObjs:  List of the selected object numbers, e.g., [1 3 5]
%
% See also: imageMontage
%
% Example:
%  objType = 'scene';
%  imageMultiview(objType);
% 
%  selectedObjs = [1 6];
%  imageMultiview(objType,whichObj);
%
%  objType = 'vcimage';
%  selectedObjs = [2 3 5];
%  imageMultiview(objType,whichObj);
% 
% Copyright Imageval Consultants, LLC, 2013

if ieNotDefined('objType'), error('Object type required.'); end

% Allows some aliases to be used
objType = vcEquivalentObjtype(objType);

% Get the objects
[objList nObj] = vcGetObjects(objType);
if    isempty(objList), fprintf('No objects of type %s\n',objType); return;
end

% Show a subset or all
if ieNotDefined('selectedObjs')
    lst = cell(1,nObj);
    for ii=1:nObj, lst{ii} = objList{ii}.name; end
    selectedObjs = listdlg('ListString',lst);
end

%% This is the display loop
for ii=selectedObjs
    f = vcNewGraphWin;
    gam = 1/1.7;  % Figure out a rationale for this.
    switch objType
        case 'SCENE'
            sceneShowImage(objList{ii},true,gam);
            set(gcf,'name',sprintf('Scene %d - %s',ii,sceneGet(objList{ii},'name')));
        case 'OPTICALIMAGE'
            oiShowImage(objList{ii},true,gam);
            set(gcf,'name',sprintf('OI %d - %s',ii,oiGet(objList{ii},'name')));
        case 'ISA'
            scaleMax = 1;
            sensorShowImage(objList{ii},'volts',gam,scaleMax)
            set(gcf,'name',sprintf('Sensor %d - %s',ii,sensorGet(objList{ii},'name')));
        case 'VCIMAGE'
            imageShowImage(objList{ii},gam,true,f);
            set(gcf,'name',sprintf('VCI %d - %s',ii,imageGet(objList{ii},'name')));
        otherwise
            error('Unsupported object type %s\n', objType);
    end
end

end