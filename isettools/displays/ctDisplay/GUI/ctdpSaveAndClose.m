function ctdpSaveAndClose(hObject);
% Close the main vDisplay window. 

ButtonName=questdlg('Do you want to save the display models?', ...
    'Exit ...', ...
    'Yes', 'No', 'Cancel', 'Yes');

switch ButtonName,
    case 'Yes',
        res=ctdpSaveAllDisplayModels(hObject);
        if res==1
            ieProcessFigCloseRequestEvent(hObject);
        end;
    case 'No',
        ieProcessFigCloseRequestEvent(hObject);
    case 'Cancel',
        return;
end % switch

