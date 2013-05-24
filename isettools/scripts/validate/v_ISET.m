% v_ValidateAll
%
% Run a set of scripts to check a wide variety of functions These are a
% subset of the demonstration and tutorial scripts.  We run these whenever
% there are significant changes to ISET and prior to checking in the new
% code.  
%
% There is a plan to add more tests of 
%  * color correction related calculations (vcimage)
%  * zemax/optics ray-trace calculations
%  * a way to test selective portions
%  * quantitative unit testing
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Initialize
s_initISET

%% Scene tests
h = msgbox('Scene','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_Scene

%% Optics tests
h = msgbox('Optics','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_oiDemo
v_Diffuser
v_opticsSI

%% Sensor tests
h = msgbox('Sensor','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_Sensor

%% Pixel tests
h = msgbox('Pixel ','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_Pixel

close all

%% Human visual system tests
h = msgbox('Human PSF','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_Human


%% Image processing 
h = msgbox('Image Processor','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_imageProcessor

%% Metrics tests
h = msgbox('Metrics','ISET Tests','replace');
set(h,'position',round([36.0000  664.1379  124.7586   50.2759]));
v_Metrics

%%
close(h)
%% End
