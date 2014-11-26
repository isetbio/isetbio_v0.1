 % Method to return the filename of the SVN-hosted ground truth data set
function dataSetFilename = svnHostedGroundTruthDataSetsFileName(obj)
    fullPathDataSetFileName = obj.groundTruthDataSetsFileName;    
    
    [pathstr,name,ext]  = fileparts(fullPathDataSetFileName);
    obj.ISETBIO_DataSets_Local_SVN_DIR = sprintf('%s/SVNDIR',pathstr);
    dataSetFilename = sprintf('%s/%s%s', obj.ISETBIO_DataSets_Local_SVN_DIR, name,ext);
end
