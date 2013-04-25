function roiData = vcGetROIData(obj,roiLocs,dataType)
% Retrieve data within the region of interest (ROI)
%
%   roiData = vcGetROIData(obj,roiLocs,dataType)
%
% Region of interest data (roiData) are retrieved from the window of any of
% the ISET objects, (SCENE,OPTICALIMAGE,ISA or VCIMAGE).  The locations,
% roiLocs, can be selected using the routine vcROISelect.  These are an Nx2
% matrix of rows and columns.
%
% When roiLocs is sent in as a 4D row vector, the meaning is [col, row,
% width, height];  The first data point is drawn from the position
% [col,row].  For unfortunate historical reasons, which could be fought
% here, the spatial size of the returned data are width+1 and height+1.
% Thus, [col,row,1,1] returns four positions.
%
% A variety of data types and windows can be chosen. These are:
%
%   scene:         photons (default) or energy
%   opticalimage:  photons (default) or energy
%   sensor:        volts   (default) or electrons 
%   vcimage:       results (default) or input
%
% The data are returned in a matrix (XW format), roiData.  The rows
% represent each of the positions and the data across the columns represent
% the values.  The number of columns depends on whether the data are
% wavelength, rgb, or electrons.
%
% Related:  vcROISelect, sensorGET(isa,'roielectrons');
%
% Examples:
%
%  vci = vcGetObject('vci');
%  roiLocs = vcROISelect(vci);
%  result = vcGetROIData(vci,roiLocs,'result');          % Nx3
%
%  For sensor, data are Nx3 and missing values are NaNs
%
%  sensor = vcGetObject('isa');
%  roiLocs = vcROISelect(sensor);
%  electrons = vcGetROIData(sensor,roiLocs,'electrons'); % Nx3
%
%  scene = vcGetObject('scene');
%  roiLocs = vcROISelect(scene);
%  photons = vcGetROIData(scene,roiLocs,'photons');      % Nx31
%  reflectance = vcGetROIData(scene,roiLocs,'reflectance');
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('obj'),     error('Object must be defined'); end

% The variable might be locs or a rect. We check and make sure it is locs.
if ieNotDefined('roiLocs'), error('ROI locations must be defined'); 
elseif size(roiLocs,2) == 4, roiLocs = ieRoi2Locs(roiLocs); 
end

objType = vcGetObjectType(obj);

switch lower(objType)
    case {'scene'}
        if ieNotDefined('dataType'), dataType = 'photons'; end

        data = sceneGet(obj,dataType);
        if isempty(data)
            if strcmp(dataType ,'energy')
                photons = sceneGet(obj,'photons');
                wavelength = sceneGet(obj,'wavelength');
                data = Quanta2Energy(wavelength,photons);
            else errordlg('No data to plot.');
            end
        end

        [img,r,c] = RGB2XWFormat(data);

        % Should we keep the data in bounds?
        roiLocs(:,1) = ieClip(roiLocs(:,1),1,r);
        roiLocs(:,2) = ieClip(roiLocs(:,2),1,c);

        imgLocs = sub2ind([r,c],roiLocs(:,1),roiLocs(:,2));
        roiData = img(imgLocs,:);
    case {'opticalimage','oi'}
        if ieNotDefined('dataType'), dataType = 'photons'; end

        data = oiGet(obj,dataType);
        if isempty(data)
            if strcmp(dataType ,'energy')
                photons = oiGet(obj,'photons');
                wavelength = oiGet(obj,'wavelength');
                data = Quanta2Energy(wavelength,photons);
            else errordlg('No data to plot.');  
            end
        end

        [img,r,c] = RGB2XWFormat(data);

        % Should we keep the data in bounds?
        roiLocs(:,1) = ieClip(roiLocs(:,1),1,r);
        roiLocs(:,2) = ieClip(roiLocs(:,2),1,c);

        imgLocs = sub2ind([r,c],roiLocs(:,1),roiLocs(:,2));
        roiData = img(imgLocs,:);

    case {'isa','sensor'}
        if ieNotDefined('dataType'), dataType = 'volts'; end

        data = sensorGet(obj,dataType);  % volts or dv

        nSensors = sensorGet(obj,'nSensors');
        if nSensors > 1, data = plane2rgb(data,obj); end

        [r,c,w] = size(data);

        % Should we keep the data in bounds?
        roiLocs(:,1) = ieClip(roiLocs(:,1),1,r);
        roiLocs(:,2) = ieClip(roiLocs(:,2),1,c);

        ind = sub2ind(size(data(:,:,1)),roiLocs(:,1),roiLocs(:,2));

        nPoints = size(roiLocs,1);
        roiData = zeros(nPoints,nSensors);
        for ii=1:nSensors
            tmp = data(:,:,ii);
            tmp = tmp(ind);
            roiData(:,ii) = tmp(:);
        end

    case 'vcimage'

        if ieNotDefined('dataType'), dataType = 'results'; end

        data = imageGet(obj,dataType);  %input, result
        [img,r,c] = RGB2XWFormat(data);

        % Should we keep the data in bounds?
        roiLocs(:,1) = ieClip(roiLocs(:,1),1,r);
        roiLocs(:,2) = ieClip(roiLocs(:,2),1,c);

        imgLocs = sub2ind([r,c],roiLocs(:,1),roiLocs(:,2));
        roiData = img(imgLocs,:);
end

return;