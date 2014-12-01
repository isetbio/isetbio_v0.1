% Method to generate the directory path/subDir, if this directory does not exist
function generateDirectory(obj, path, subDir)
    fullDir = sprintf('%s/%s', path, subDir);
    if (~exist(fullDir, 'dir'))
        mkdir(fullDir);
    end
end