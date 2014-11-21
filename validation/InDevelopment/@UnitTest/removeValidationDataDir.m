% Method to remove the root validationData directory
function removeValidationDataDir(obj)
    if (exist(obj.validationDataDir, 'dir'))
        rmpath(obj.validationDataDir);
    end
    system(sprintf('rm -r -f %s', obj.validationDataDir));
end
        