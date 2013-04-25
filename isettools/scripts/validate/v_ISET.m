%% Validate VSET distribution
%
% This distribution is intended to be a visual system engineering toolbox
% (VSET). It is  useful for calculating the front end (image formation,
% color matching, cone absorptions) for human and animal systems.
%
% Imageval provide this subset of ISET, freely and in open-source format.
% The full ISET distribution can be obtained from www.imageval.com.  That
% distribution includes an array of metrics to analyze the properties of
% the scene, optics, and sensor.  It further includes a set of Demosaicing,
% Color Balancing, and other image processing operations - and metrics for
% those - that are important for evaluating the digital imaging pipeline
% but not important for the analysi sof the human visual pathways.
%
% (c) Imageval Consulting, LLC 2012

%% Prepare for the validation
s_initISET

%% validate the scene functdions
v_Scene

%% validate optics
v_oiDemo
v_opticsSI

%% validate sensor (retinal absorptions)
v_Sensor
v_Human

%% A few tutorials
t_humanLineSpread
t_airyDisk
t_ColorMetamerism

%% End