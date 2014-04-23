function ctdpImageZoomView(ctDisplayW)
% Use imtool to show a zoomed view of the main image
%
%   ctdpImageZoomView(hObject)
%
%

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

aImageRendered=displayGet(displayGD,'ImageRendered');
if isempty(aImageRendered),  return;  end;

%hImage=imview(aImageRendered);
hImage=imtool(aImageRendered/max(aImageRendered(:)));

return;

%set(handles.figure1, 'WindowStyle', 'normal');

% hImage.setTitle('Detailed View -- Virtual Image');
% hImage.setMaximized(1);
% % % bResult=vdBringWindowToTop(h.getHWnd(), 0); %setting from 0 to 1 will
% % % work. But that's too preemptive, even more preemptive than Matlab. So I
% % % gave up. I decide to leave these windows as they are, but just miximize
% % % them so the users can at least notice the change...
% hImage.requestFocus();
% hImage.setVisible(1);
% hImage.show();
% hImage.setMaximized(1);
% % %h.requestFocusinwindow();

