% Method to plot mistmatched validation data and their difference
function figureName = plotDataAndTheirDifference(obj, field1, field2, field1Name, field2Name)
  
    obj.dataMismatchFigNumber = obj.dataMismatchFigNumber + 1;
    h = figure(obj.dataMismatchFigNumber);
    figureName = sprintf('''%s'' vs. ''%s''', field1Name, field2Name);
    set(h, 'Name', figureName);
    clf;
    
    
    if (ndims(field1) == 2) && (all(size(field1) > 1))
        
        diff = field1 - field2;
        minAll = min([min(field1(:)) min(field2(:))]);
        maxAll = max([max(field1(:)) max(field2(:))]);
        maxDiff = max(abs(diff(:)));
        
        set(h, 'Position', [100 100 1400 380]);
        subplot(1,3,1);
        imagesc(field1);
        colorbar
        set(gca, 'CLim', [minAll maxAll]);
        title(sprintf('''%s''', field1Name));

        subplot(1,3,2);
        imagesc(field2);
        set(gca, 'CLim', [minAll maxAll]);
        colorbar
        title(sprintf('''%s''', field2Name));

        subplot(1,3,3);
        imagesc(diff);
        set(gca, 'CLim', maxDiff*[-1 1]);
        colorbar
        title(sprintf('''%s'' - \n''%s''', field1Name, field2Name));
        colormap(gray(256));
        
    elseif (ndims(field1) == 1) || ((ndims(field1)==2) && (any(size(field1)==1)))  
        
        diff = field1 - field2;
        minAll = min([min(field1(:)) min(field2(:))]);
        maxAll = max([max(field1(:)) max(field2(:))]);
        maxDiff = max(abs(diff(:)));
        delta = (maxAll-minAll)/10;
        
        set(h, 'Position', [100 100 1400 380]);
        subplot(1,3,1);
        plot(field1, 'bs-', 'MarkerFaceColor', [0.8 0.8 1]);
        set(gca, 'YLim', [minAll-delta maxAll+delta]);
        title(sprintf('''%s''', field1Name));
        
        subplot(1,3,2);
        plot(field2, 'bs-',  'MarkerFaceColor', [0.8 0.8 1]);
        set(gca, 'YLim', [minAll-delta maxAll+delta]);
        title(sprintf('''%s''', field2Name));
        
        subplot(1,3,3);
        plot(field1 - field2, 'bs-',  'MarkerFaceColor', [0.8 0.8 1]);
        set(gca, 'YLim', maxDiff*[-1.1 1.1]);
        title(sprintf('''%s'' - \n''%s''', field1Name, field2Name));

        
    elseif (ndims(field1) == 3)
        
        diff = field1 - field2;
        minAll = min([min(field1(:)) min(field2(:))]);
        maxAll = max([max(field1(:)) max(field2(:))]);
        maxDiff = max(abs(diff(:)));
        
        [d1, d2, d3] = size(field1);
        if (d3 > 50)
            figSize = [2350 810];
            showTicks = false;
            wMargin = 0.005;
        else
            figSize = [1800 800];
            showTicks = true;
            wMargin = 0.01;
        end
        set(h, 'Position', [100 100  figSize(1)  figSize(2)]);
        
        halfD = round(d3/2);
        posVectors = getSubPlotPosVectors(...
            'rowsNum', 6, 'colsNum', halfD, ...
            'widthMargin', wMargin, 'heightMargin', 0.01, ...
            'leftMargin', 0.02', ...
            'bottomMargin', 0.01, 'topMargin', 0.01);

        for k = 1:halfD
           row = 1;
           col = k;
           subplot('Position', posVectors(row,col).v);
           imagesc(squeeze(field1(:,:,k)));
           if (k == 1)
               ylabel(field1Name, 'Color', [1 0 0]);
           end
           axis 'image'
           if (~showTicks)
              set(gca, 'XTick', [], 'YTick', []);
           end
           set(gca, 'CLim', [minAll maxAll]);
           title(sprintf('i=%d', k), 'Color', [1 0 0]);
           %colorbar('horiz');
           
           
           row = 2;
           col = k;
           subplot('Position', posVectors(row,col).v);
           imagesc(squeeze(field2(:,:,k)));
           if (k == 1)
               ylabel(field2Name, 'Color', [0 0 1]);
           end
           axis 'image'
           if (~showTicks)
              set(gca, 'XTick', [], 'YTick', []);
           end
           set(gca, 'CLim', [minAll maxAll]);
           title(sprintf('i=%d', k), 'Color', [0 0 1]);
           %colorbar('horiz');
           
           
           row = 3;
           col = k;
           subplot('Position', posVectors(row,col).v);
           imagesc(squeeze(diff(:,:,k)));
           if (k == 1)
               ylabel(sprintf('groundTruthData\n - validationData'));
           end
           axis 'image'
           if (~showTicks)
              set(gca, 'XTick', [], 'YTick', []);
           end
           set(gca, 'CLim', maxDiff*[-1 1]);
           title(sprintf('i=%d', k));
           %colorbar('horiz');
           
        end
        
        for k = halfD+1:d3
           row = 4;
           col = k-halfD;
           subplot('Position', posVectors(row,col).v);
           imagesc(squeeze(field1(:,:,k)));
           if (k == halfD+1)
               ylabel(field1Name, 'Color', [1 0 0]);
           end
           axis 'image'
           if (~showTicks)
              set(gca, 'XTick', [], 'YTick', []);
           end
           set(gca, 'CLim', [minAll maxAll]);
           title(sprintf('i=%d', k), 'Color', [1 0 0]);
           %colorbar('horiz');
           
           
           row = 5;
           col = k-halfD;
           subplot('Position', posVectors(row,col).v);
           imagesc(squeeze(field2(:,:,k)));
           if (k == halfD+1)
               ylabel(field2Name, 'Color', [0 0 1]);
           end
           axis 'image'
           if (~showTicks)
              set(gca, 'XTick', [], 'YTick', []);
           end
           set(gca, 'CLim', [minAll maxAll]);
           title(sprintf('i=%d', k), 'Color', [0 0 1]);
           %colorbar('horiz');
           
           row = 6;
           col = k-halfD;
           subplot('Position', posVectors(row,col).v);
           imagesc(squeeze(diff(:,:,k)));
           if (k == halfD+1)
               ylabel(sprintf('groundTruthData\n - validationData'));
           end
           axis 'image'
           if (~showTicks)
              set(gca, 'XTick', [], 'YTick', []);
           end
           set(gca, 'CLim', maxDiff*[-1 1]);
           title(sprintf('i=%d', k));
           
        end
        
        
        colormap(gray(512));
    end
    
end


function posVectors = getSubPlotPosVectors(varargin)

    self.rowsNum        = 2;
    self.colsNum        = 2;
    self.widthMargin    = 0.01;
    self.heightMargin   = 0.01;
    self.leftMargin     = 0.06;
    self.bottomMargin   = 0.08;
    self.topMargin      = 0.08;
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('rowsNum',         self.rowsNum);
    parser.addParamValue('colsNum',         self.colsNum);
    parser.addParamValue('widthMargin',     self.widthMargin);
    parser.addParamValue('heightMargin',    self.heightMargin);
    parser.addParamValue('leftMargin',      self.leftMargin);
    parser.addParamValue('bottomMargin',    self.bottomMargin); 
    parser.addParamValue('topMargin',       self.topMargin);

    
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       self.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    plotWidth  = ((1.0-self.leftMargin) - self.widthMargin*(self.colsNum-1) - 0.01)/self.colsNum;
    plotHeight = ((1.0-self.bottomMargin-self.topMargin) - self.heightMargin*(self.rowsNum-1) - 0.01)/self.rowsNum;
    
    for row = 1:self.rowsNum
        yo = 0.99 - self.topMargin - (row)*(plotHeight+self.heightMargin) + self.heightMargin;
        for col = 1:self.colsNum
            xo = self.leftMargin + (col-1)*(plotWidth+self.widthMargin);
            posVectors(row,col).v = [xo yo plotWidth plotHeight];
        end
    end
 end
    