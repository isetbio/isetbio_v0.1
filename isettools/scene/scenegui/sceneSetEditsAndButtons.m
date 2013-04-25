function sceneSetEditsAndButtons(handles)
% Fill scene window fields based on the current scene information
%
%    sceneSetEditsAndButtons(handles)
%
% Fill the fields  the current scene information, including editdistance,
% editluminance, FOV, etc.  
%
% Display of the image data is handled separately by sceneShowImage.
%
% Copyright ImagEval Consultants, LLC, 2003.

scene = vcGetObject('SCENE');
figNum = vcSelectFigure('SCENE'); 
figure(figNum);

if isempty(scene)
    str = [];
    set(handles.editDistance,'String',str);
    set(handles.editLuminance,'String',str);
    set(handles.editHorFOV,'String',str);
    
    % Select scene popup contents
    set(handles.popupSelectScene,...
        'String','No Scenes',...
        'Value',1);
else
    % Text boxes on right: we should reduce the fields in SCENE.
    set(handles.editDistance,'String',num2str(sceneGet(scene,'distance')));
    meanL = sceneGet(scene,'mean luminance');
   
    set(handles.editLuminance,'String',num2str(meanL));
    set(handles.editHorFOV,'String',num2str(scene.wAngular));
    
    % Select scene popup contents
    set(handles.popupSelectScene,...
        'String',vcGetObjectNames('SCENE'),...
        'Value',vcGetSelectedObject('SCENE'));    
end

% Description box on upper right
set(handles.txtSceneDescription,'String',sceneDescription(scene));

gam = str2double(get(handles.editGamma,'String'));

% Get the displayFlag from the scene window.
displayFlag = get(handles.popupDisplay,'Value');
sceneShowImage(scene,displayFlag,gam);

return;
