function ctProcessScalingFactorEvents(hObject, strX, strY);
% --- Helper function for processing adjusting scaling factor events.

displayGD=ctGetObject('display');
fX=displayGet(displayGD, 'm_objVirtualDisplay', 'ScalingFactorX');
fY=displayGet(displayGD, 'm_objVirtualDisplay', 'ScalingFactorY');

switch strX(1)
    case 'x'
        strX=strX(2:end);
        strY=strY(2:end);
        try
            evalc(['fSX=' strX]);
            evalc(['fSY=' strY]);
        catch
            uiwait(errordlg('Invalid scaling factor! Please check you number and try again ...', 'Error', 'modal'));
            return;
        end;
        if isequal(fSX, 1) && isequal(fSY, 1), return; end;
        fNewX=fSX*fX;
        fNewY=fSY*fY;
    case '?'
        cellDefaultAnswers={strrep(rats(fX), ' ', ''), strrep(rats(fY), ' ', '')};
        cellPrompts={'Please enter your horizontal scaling factor...', 'Please enter your vertical scaling factor...'};
        strDlgTitle='Scaling Factor';
        cellInputs=ieInputDlgNumeric(cellPrompts, cellDefaultAnswers, strDlgTitle)
        if ~(length(cellInputs)==0)
            if isequal(fX, cellInputs{1}) && isequal(fY, cellInputs{2}), return; end;
            fNewX=cellInputs{1};
            fNewY=cellInputs{2};
        end;
end;


displayGD=displaySet(displayGD, 'm_objVirtualDisplay', 'ScalingFactorX', fNewX);
displayGD=displaySet(displayGD, 'm_objVirtualDisplay', 'ScalingFactorY', fNewY);

displayGD=displaySet(displayGD, 'm_bIsMainImageDirty', 1);

ctSetObject('display', displayGD)'
ctdpRefreshGUIWindow(hObject);
