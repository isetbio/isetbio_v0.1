function ctSaveVirtualDisplayImage(hObject);
% Save virtual display image.
%
%  ctSaveVirtualDisplayImage(hObject);
%
%Purpose:
%   Save the displayed image of the virtual display as a jpeg or tiff file.

displayGD=ctGetObject('display');
aImageRendered=displayGet(displayGD, 'ImageRendered');
aImageRendered=aImageRendered/max(aImageRendered(:))*255;
if isempty(aImageRendered), return; end;

%Since the image itself is within [0, 1].
ieImageSave(aImageRendered, 'Virtual Display', 'Save Virtual Display image as ...');

return;