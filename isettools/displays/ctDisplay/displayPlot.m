function displayPlot(disGD,pType)
% Display object plot routines
%
%     displayPlot(disGD,'mesh')
%
% Example
%   displayPlot(disGD,'mesh')
%

dixel  = displayGet(disGD,'dixel');
psf    = dixelGet(dixel,'psf');
sPos = psfGet(psf{1},'support');   % Sample position in um

% Set up the window
n = length(psf); nWin(1) = ceil(sqrt(n)); nWin(2) = ceil(n/nWin(1));
fig = vcNewGraphWin;
set(fig,'Position',[300  100 nWin(1)*300 nWin(2)*300]);

switch lower(pType)
    case 'mesh'
        % The mesh is too finely sampled to look nice.   Consider what to
        % do.
        for ii=1:n
            data = psfGet(psf{ii},'data');
            data = max(data,0);
            subplot(nWin(1),nWin(2),ii); mesh(sPos{1}(1,:),sPos{2}(:,1),data); 
            colormap(0.2 + 0.4*gray(256))
            xlabel('um'); ylabel('um'); zlabel('radiance');
            if isequal(ii,1), title(psfGet(psf{1},'name')); end
        end
    case 'image'
        for ii=1:n
            data = psfGet(psf{ii},'data');
            data = max(data,0);
            subplot(nWin(1),nWin(2),ii); imagesc(sPos{1}(1,:),sPos{2}(:,1),data); axis image
            xlabel('um'); ylabel('um');
            if isequal(ii,1), title(psfGet(psf{1},'name')); end
        end
end

return;

