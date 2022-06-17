function varargout = mainGUI(varargin)
% MAINGUI MATLAB code for mainGUI.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainGUI

% Last Modified by GUIDE v2.5 17-Aug-2014 20:48:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mainGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
addpath('utilities');

% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainGUI (see VARARGIN)

% Choose default command line output for mainGUI
handles.output = hObject;



%% load camera sensitivity functions
handles.cam_name = 'Canon_1D_Mark_III';
handles.wavelength = 400:10:700;
load(['data\cameras_cmf\' handles.cam_name]);
handles.csf=(interp1(F.',CRF.',handles.wavelength))';
plotCSF(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnLoadImage.
function btnLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*.mat','Select the MATLAB data file');
handles.fn = [PathName FileName];
% load a hyperspectral image
load([PathName FileName]);

% show RGB image
[R_exact, sw, sh] = showRGBImage(handles, tensor, illumination);

handles.L_exact = illumination;
handles.R_exact = R_exact;

handles.X = 1;
handles.Y = 1;
handles.sw = sw;
handles.sh = sh;
handles.Rflag = 1;

showIllumination(handles,1);
showReflectance(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btnReconstruct.
function btnReconstruct_Callback(hObject, eventdata, handles)
% hObject    handle to btnReconstruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (exist(['models\' handles.cam_name '_reflectance_model.mat'], 'file') && ...
    exist(['models\' handles.cam_name '_illumination_model.mat'], 'file'))
    
    load(['models\' handles.cam_name '_reflectance_model.mat']);
    load(['models\' handles.cam_name '_illumination_model.mat']);
else
    [reflectance_model, illumination_model] = training(handles.cam_name, handles.csf);
end

[R_exact, ~, R_recon, L_recon, ~, ~] = reconstructSpectra(handles.csf, reflectance_model, ...
                                                                    illumination_model, handles.fn, 1);
handles.R_exact = R_exact;
handles.R_recon = R_recon;
handles.L_recon = L_recon;
handles.Rflag = 2;

% show spectral illumination
showIllumination(handles,2);
showReflectance(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos = get(gca,'CurrentPoint');
handles.X = round(pos(1,2));
handles.Y = round(pos(1,1));

if (handles.X > 1) && (handles.X <= handles.sw) && ...
   (handles.Y > 1) && (handles.Y <= handles.sh)
    showReflectance(handles);
end


% --- Plot Camera Sensitivity Functions 
function plotCSF(handles)

axes(handles.axesCSF);
plot(handles.wavelength, handles.csf(1,:), 'r',...
     handles.wavelength, handles.csf(2,:), 'g',...
     handles.wavelength, handles.csf(3,:), 'b');
 title(handles.cam_name,'Interpreter','none');

 
% --- Plot RGB image
function [R_exact, w, h] = showRGBImage(handles, tensor, illumination)
[w, h, b] = size(tensor);
tensor = reshape(tensor, [], b);
RGBImage = tensor * handles.csf';
RGBImage = RGBImage / max(RGBImage(:));
RGBImage = reshape(RGBImage, w, h, 3);
% show
axes(handles.axesRGBImage);
imshow(RGBImage);
R_exact = tensor * diag(1./illumination);
R_exact = R_exact / max(R_exact(:));
R_exact = reshape(R_exact, w, h, b);


% --- Plot spectral illumination
function showIllumination(handles,flag)
axes(handles.axesIllumination);
if(flag == 2)
    handles.L_recon = adjust_and_normalize(handles.L_exact, handles.L_recon);
    plot(handles.wavelength, handles.L_exact, 'k', ...
         handles.wavelength, handles.L_recon, 'r');
    legend('Groundtruth', 'Reconstruct');
else
    plot(handles.wavelength, handles.L_exact, 'k');
    legend('Groundtruth');
end

% --- Plot spectral reflectance
function showReflectance(handles)
axes(handles.axesReflectance);
if(handles.Rflag == 2)
    relect_exact = reshape(handles.R_exact(handles.X, handles.Y, :),[],1);
    relect_recon = reshape(handles.R_recon(handles.X, handles.Y, :),[],1);
    relect_recon = adjust_and_normalize(relect_exact, relect_recon);
    plot(handles.wavelength, relect_exact, 'k', ...
         handles.wavelength, relect_recon, 'r');
    legend('Groundtruth', 'Reconstruct');
else
    relect_exact = reshape(handles.R_exact(handles.X, handles.Y, :),[],1);    
    plot(handles.wavelength, relect_exact, 'k');
    legend('Groundtruth');
end
set(handles.textReflectance,'String', ['Spectral Reflectance (' num2str(handles.X) ', ' num2str(handles.Y) ')']);

function B = adjust_and_normalize(A, B)
B(B < 0) = 0;
B = B * (mean(A)/(mean(B) + 0.000001)); % avoid divided by zero
