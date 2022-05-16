function f_DA_browse_udf(app)

q = figure('Renderer', 'painters', 'Position', [-100 -100 0 0]); %create a dummy figure so that uigetfile doesn't minimize our GUI
% see
% https://www.mathworks.com/matlabcentral/answers/296305-appdesigner-window-ends-up-in-background-after-uigetfile
% Onur Ozdemir solution 
% Hacky but whatever, at least it doesn't blink


% function to select UDF
[f,p] = uigetfile('*.mat','Select User-Defined Features File');
app.file_UDF = fullfile(p,f);
app.UDFFilePath.Value = app.file_UDF;

delete(q);
end
