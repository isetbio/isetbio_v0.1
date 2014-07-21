# Run unit test in matlab
/Applications/MATLAB_R2014a.app/bin/matlab -nodesktop -nosplash -nodisplay -r "unitTest"
if [ "$?" == "0" ];
then
    echo Unit test passed!
    exit 0
else
    echo Unit Test Failed
    exit 1
fi