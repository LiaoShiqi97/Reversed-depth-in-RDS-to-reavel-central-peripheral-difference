% This is an simplified implementation for experiment 1 of paper Reversed depth in anti-correlated random dot stereograms and the central-peripheral
% difference in visual inference.
% This is based on jinyouZou's example coding.

%% some useful pre-setup

% clear all exist variables and close all graphic buffer
clear all; sca;

% Unify key code for different operating system
KbName('UnifyKeyNames');

% Useful when you program on your laptop
Screen('Preference', 'SkipSyncTests', 1);

% Shuffle seeds for random number generator, otherwise the random number
% sequence would be the same every time when you restart MATLAB.
rng('shuffle');

% Move cursor to command window in case you modify your script while running
commandwindow;

% RestrictKeysForKbCheck(KbName('s'));
%% parameter

% input some information and use them as the name of the log file
subjectName = input('## Please input subject name: ', 's');
sessionNumber = input('## Please input session number: ');

% initialize as empty
params = []; 
% specify which monitor to use
params.screen.SCREEN_NUM = 2;  
% stereomode 6 means red-green anaglyph
params.screen.STEREO_MODE = 6;
% background color grey
params.screen.BACK_COLOR = [128, 128, 128];
% foreground color
params.screen.FOR_COLOR = 200;
% red cross line width
params.screen.lineWidthPix = 4;
% color red
params.screen.RED_COLOR = [255,0,0];
% color green
params.screen.GREEN_COLOR = [0,255,0];
% button to report disk is in fornt of the surrounding ring
params.screen.FRONT_REPORT = KbName('y');
% button to report disk is behind the surrounding ring
params.screen.BEHIND_REPORT = KbName('n');

%---------------Stimulus and screen size ----------------------------------
% These parameter would determine the stimulus size, please varify them.
params.screen.displayPhysicalWidthMM = Screen('DisplaySize', params.screen.SCREEN_NUM);  %mm
params.screen.viewingDistanceMM = 200;  %mm
% The specific parameters for the experiment1, merge central and peripheralg
% parameters into one.

params.stim.sDeg = 0.348; % size of Dot in Deg
params.stim.rDeg = 3; % radius of Central Disk in Deg
params.stim.RDeg = 4.3; % radius of Surrounding Ring in Deg
params.stim.dAbsoluteStepDeg = 0.087; % absolute of disparity step in Deg
params.stim.maxdStep = 6; % maximal Steps for absolute of disparity step
params.stim.e0Deg = 3.65; % distance from red cross to Central Disk Center At Central View in Deg
params.stim.sfDeg = 0.44; % size of Red Cross in Deg
params.stim.e1Deg = 10.1; % distance from red cross to Central Disk Center At Peripheral View in Deg
params.stim.greenCircle = 0; % whether to plot green circle
params.stim.dotRatio = 0.25; % 25% of the disk area would be covered by the dots if they did not occlude each other
params.stim.binocularRectangularWidthDeg = 0.2; % binocular rectangular frame width
params.stim.colorBinocularRectangular = [0,0,0]; % color of binocular rectangular frame
params.stim.fixationPeriodTimeMS = 0.7; % fixation period time 0.7 s

params.stim.NTrialsGroup1 = 10; % Ntrials group 1 todo
params.stim.fixationPeriodTimeMSGroup1 = 2; % fixationPeriodTimeMSGroup1:2 s
params.stim.fixationPeriodTimeMSGroup234 = 1.5; % fixationPeriodTimeMSGroup1:2 s
params.stim.NTrialsGroup2 = 10; % Ntrials group 2 todo
params.stim.NTrialsGroup3 = 10; % Ntrials group 3 todo
params.stim.NorderTrialGroup3 = 2;
params.stim.NfixationPositionGroup3 = 2;  % NfixationPositionGroup3
params.stim.NfixationPositionGroup4 = 2;  % NfixationPositionGroup4
params.stim.NTypesRDSCorrelationGroup4 = 3;  % NTypesRDSCorrelationGroup4 
params.stim.NTrialsPerConditionGroup4 = 1; % NTrialsPerConditionGroup4

%---------------Stimulus conditons -----------------------------------------------------------
% --- Conditions included in this session, each row indicate a condition
params.stim.NTrialsPerCondition = 50; % Number of trials per condition todo
params.stim.NfixationPosition = 2; % Number of fixation position 1 = Red Cross At Central View, 2 = Red Cross At Peripheral View
params.stim.NTypesRDSCorrelation = 3; % Number of types of RDS Correlation 1 = Correlated, 2 = Half-matched, 3 = Anticorrelated
NConditions = params.stim.NfixationPosition * params.stim.NTypesRDSCorrelation; % Total number of conditions
params.stim.fixationPositions = ["Central Viewing", "Peripheral Viewing"]; % Names of fixation positions
params.stim.TypesRDSCorrelations = ["Correlated RDS", "Half_matched RDS", "Anticorrelated RDS"];  % Types of RDS Correlation

%% open screen and draw buffers
% Open double-buffered onscreen window with the requested stereo mode,
[windowPtr, windowRect] = PsychImaging('OpenWindow', params.screen.SCREEN_NUM, ...
    params.screen.BACK_COLOR, [], [], [], params.screen.STEREO_MODE);


% return the center point coordinate of the screen
[Screen_center(1),Screen_center(2)]  = RectCenter(windowRect);

%------------------ calculate the pixel size ----------------------
PixelPerDegreeVA = windowRect(3) / (2 * atand(params.screen.displayPhysicalWidthMM / 2 / params.screen.viewingDistanceMM));

s_Pix = round(params.stim.sDeg * PixelPerDegreeVA);
r_Pix = round(params.stim.rDeg * PixelPerDegreeVA);
R_Pix = round(params.stim.RDeg * PixelPerDegreeVA);
dAbsoluteStep_Pix = round(params.stim.dAbsoluteStepDeg * PixelPerDegreeVA);
e0_Pix = round(params.stim.e0Deg * PixelPerDegreeVA);
sf_Pix = round(params.stim.sfDeg * PixelPerDegreeVA);
e1_Pix = round(params.stim.e1Deg * PixelPerDegreeVA);
binocularRectangularFrameWidth_Pix = round(params.stim.binocularRectangularWidthDeg * PixelPerDegreeVA);

% compute relative rectangular coordinates for Red Cross
crossXCoords = [-sf_Pix/2 sf_Pix/2 0 0];
crossYCoords = [0 0 -sf_Pix/2 sf_Pix/2];
crossAllCoords = [crossXCoords; crossYCoords];

% compute the space within the balck rectangluar frame
windowRect_dot = [Screen_center(1)-e1_Pix-100, ...
    Screen_center(2)-e1_Pix-100, ...
    Screen_center(1)+e1_Pix+100, ...
    Screen_center(2)+e1_Pix+100];

% --------------------------------------------------------
% Buffer: Waiting page
% --------------------------------------------------------
WaitInstructionPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('DrawText',WaitInstructionPage, 'Wait ...', Screen_center(1)-50,Screen_center(2), params.screen.FOR_COLOR);
Screen('FrameRect', WaitInstructionPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);


% --------------------------------------------------------
% Buffer: Prefixation page
% --------------------------------------------------------
% Instruct the subjects to press any button
PrefixationCentralPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
Screen('BlendFunction', PrefixationCentralPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FrameRect', PrefixationCentralPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
Screen('DrawLines', PrefixationCentralPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', PrefixationCentralPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', PrefixationCentralPage,  'Press any button',  Screen_center(1)-200, Screen_center(2)-e0_Pix-10, params.screen.FOR_COLOR);
Screen('DrawText', PrefixationCentralPage,  'For the next trial',  Screen_center(1)+20, Screen_center(2)-e0_Pix-10, params.screen.FOR_COLOR);

PrefixationPeripheralPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
Screen('BlendFunction', PrefixationPeripheralPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FrameRect', PrefixationPeripheralPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
Screen('DrawLines', PrefixationPeripheralPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', PrefixationPeripheralPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', PrefixationPeripheralPage,  'Press any button',  Screen_center(1)-200, Screen_center(2)-e1_Pix-10, params.screen.FOR_COLOR);
Screen('DrawText', PrefixationPeripheralPage,  'For the next trial',  Screen_center(1)+20, Screen_center(2)-e1_Pix-10, params.screen.FOR_COLOR);

% --------------------------------------------------------
% Buffer: Fixation Page
% --------------------------------------------------------
% compute Ndots
areaOuterDisk_Pix2 =  pi*R_Pix^2;
areaDot_Pix2 = s_Pix * s_Pix;
Ndots = round(areaOuterDisk_Pix2/areaDot_Pix2 * params.stim.dotRatio);
% generate random dots (rect and color) by sampling polar coordinates
NtotalTrials = params.stim.NfixationPosition * params.stim.NTypesRDSCorrelation * params.stim.NTrialsPerCondition;
TypeViewsSelceted = ones(NtotalTrials,1);
randTypeViews  = randperm(NtotalTrials, params.stim.NTypesRDSCorrelation * params.stim.NTrialsPerCondition);
TypeViewsSelceted(randTypeViews) = 2;
TypeRDSCorrelation = ones(NtotalTrials,1);
randTypeRDSCorrelation = randperm(NtotalTrials);
randType2RDSCorrelation = randTypeRDSCorrelation(params.stim.NfixationPosition*params.stim.NTrialsPerCondition+1 : 2*params.stim.NfixationPosition*params.stim.NTrialsPerCondition);
randType3RDSCorrelation = randTypeRDSCorrelation(2*params.stim.NfixationPosition*params.stim.NTrialsPerCondition+1 : NtotalTrials);
TypeRDSCorrelation(randType2RDSCorrelation) = 2;
TypeRDSCorrelation(randType2RDSCorrelation) = 3;

rectDots = zeros(NtotalTrials, 2, 4, Ndots);
colorDots = zeros(NtotalTrials, 2, 3, Ndots);
dSigns = zeros(NtotalTrials, 1);
dSteps = zeros(NtotalTrials, 1);
ds_Pix = zeros(NtotalTrials, 1);
dotsInnerDiskLabels = zeros(NtotalTrials, Ndots);

for itrial = 1 : NtotalTrials
    itypesRDSCorrelation = TypeRDSCorrelation(itrial);
    randAngle_Deg = unifrnd(0, pi*2, 1, Ndots);
    randLength_Pix = unifrnd(0, R_Pix+s_Pix, 1, Ndots);
    xSelected = Screen_center(1) + randLength_Pix.*cos(randAngle_Deg);
    ySelected = Screen_center(2) + randLength_Pix.*sin(randAngle_Deg);
    dotsInnerDiskLabel = randLength_Pix < r_Pix;
    dotsInnerDiskLabels(itrial, :)=dotsInnerDiskLabel;
    dSign = rand()>0.5;
    dSigns(itrial, :) = dSign;
    randdStep = round(rand() * params.stim.maxdStep);
    dSteps(itrial, :) = randdStep;
    d_Pix = (2*dSign-1) * dAbsoluteStep_Pix * randdStep;
    ds_Pix(itrial, :) = d_Pix;

    if mod(d_Pix, 2) == 0
        xLeftSelected = xSelected + d_Pix/2 * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected - d_Pix/2 * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    else
        shifts = [(abs(d_Pix) + 1)/2, (abs(d_Pix) - 1)/2];
        shiftRand = rand()>0.5;
        xLeftSelected = xSelected + shifts(shiftRand+1) * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected + shifts(2 - shiftRand) * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    end 
    rectDots(itrial, 1, :, :) = vertcat(xLeftSelected, yLeftSelected, xLeftSelected+s_Pix, yLeftSelected+s_Pix);
    rectDots(itrial, 2, :, :) = vertcat(xRightSelected, yRightSelected, xRightSelected+s_Pix, yRightSelected+s_Pix);
    
    colorSelected = repmat(((rand(Ndots, 1)>0.5) * 255)', 3, 1);
    colorDots(itrial, 1, :, :) = colorSelected;
    if itypesRDSCorrelation == 1 % correlated RDS
        colorDots(itrial, 2, :, :) = colorSelected;
    elseif itypesRDSCorrelation == 2 % half-matched RDS
        randDismatchedDotsLabel = repmat(((rand(Ndots, 1)>0.5))', 3, 1);
        colorDots(itrial, 2, :, :) = abs(colorSelected - (randDismatchedDotsLabel.*repmat(dotsInnerDiskLabel, 3, 1))*255);              
    elseif itypesRDSCorrelation == 3 % anticorrelated RDS
        colorDots(itrial, 2, :, :) = abs(colorSelected-repmat(dotsInnerDiskLabel, 3, 1) * 255); 
    end  
end

% --------------------------------------------------------
% Buffer3: Report Page
% --------------------------------------------------------
ReportPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
Screen('BlendFunction', ReportPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', ReportPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', ReportPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('FrameRect', ReportPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
Screen('DrawText', ReportPage,  'Report on the depth order of disk.',  Screen_center(1)-300, Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', ReportPage,  'If Central Disk is in front of the surrounding ring, press y',  Screen_center(1)-300, Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', ReportPage,  'Otherwise press any other button.',  Screen_center(1)-300, Screen_center(2)+40, params.screen.FOR_COLOR);

% --------------------------------------------------------
% Buffer4: End page
% --------------------------------------------------------
ExperimentFinishPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
Screen('BlendFunction', ExperimentFinishPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawText',ExperimentFinishPage,  'Trials completed --- Thank you very much!!',  Screen_center(1)-100,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText',ExperimentFinishPage,  'please tell the experimenter your comments/observations',  Screen_center(1)-100,Screen_center(2)+30, params.screen.FOR_COLOR);

% --------------------------------------------------------
% Buffer: IntroPracticeGroupPage
% --------------------------------------------------------
IntroPracticeGroupPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', IntroPracticeGroupPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', IntroPracticeGroupPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', IntroPracticeGroupPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', IntroPracticeGroupPage, 'Welcome to join Liao Shiqi PTB experiment!', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'It inclueds a four practice sessions and', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'an offical test session. Each session includes some', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'trials. Each trial you will first see two red crosses', Screen_center(1)-300,Screen_center(2)+60, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'within a black rectangular. Stare at the red cross', Screen_center(1)-300,Screen_center(2)+80, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'among words and press any button. Next, you will', Screen_center(1)-300,Screen_center(2)+100, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'see a disk of dots. Try to distinguish whether the', Screen_center(1)-300,Screen_center(2)+120, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'central disk is in front of or behind the surrounding', Screen_center(1)-300,Screen_center(2)+140, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'ring. And you report it in next Page. Good Luck!', Screen_center(1)-300,Screen_center(2)+160, params.screen.FOR_COLOR);
Screen('DrawText', IntroPracticeGroupPage, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+180, params.screen.FOR_COLOR);
Screen('FrameRect', IntroPracticeGroupPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

% --------------------------------------------------------
% Buffer: Statement Group1 Page
% --------------------------------------------------------
StatementGroup1Page = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementGroup1Page, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementGroup1Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementGroup1Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementGroup1Page, 'Practice Session 1', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'you will do a session of 10 trials.', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'You need to stare at the red cross among words', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'and distinguish whether the central disk is in', Screen_center(1)-300,Screen_center(2)+60, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'front of or behind the surrounding ring. And', Screen_center(1)-300,Screen_center(2)+80, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'finally you press the button y to report the', Screen_center(1)-300,Screen_center(2)+100, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'centraldisk is in front of the surrounding ring', Screen_center(1)-300,Screen_center(2)+120, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'or press any other button if you think it is', Screen_center(1)-300,Screen_center(2)+140, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'behind the surrounding ring. ', Screen_center(1)-300,Screen_center(2)+160, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup1Page, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+180, params.screen.FOR_COLOR);
Screen('FrameRect', StatementGroup1Page, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);


% --------------------------------------------------------
% Buffer: FixationGroup1 Page
% --------------------------------------------------------
% generate random dots (rect and color) by sampling polar coordinates
rectDotsGroup1 = zeros(params.stim.NTrialsGroup1, 2, 4, Ndots);
colorDotsGroup1 = zeros(params.stim.NTrialsGroup1, 2, 3, Ndots);
dSignsGroup1 = zeros(params.stim.NTrialsGroup1, 1);
dStepsGroup1 = params.stim.maxdStep * ones(params.stim.NTrialsGroup1, 1);
ds_PixGroup1 = zeros(params.stim.NTrialsGroup1, 1);
dotsInnerDiskLabelsGroup1 = zeros(params.stim.NTrialsGroup1, Ndots);
for itrial = 1 : params.stim.NTrialsGroup1
    randAngle_Deg = unifrnd(0, pi*2, 1, Ndots);
    randLength_Pix = unifrnd(0, R_Pix+s_Pix, 1, Ndots);
    xRightSelected = Screen_center(1) + randLength_Pix.*cos(randAngle_Deg);
    yRightSelected = Screen_center(2) + randLength_Pix.*sin(randAngle_Deg);
    dotsInnerDiskLabel = randLength_Pix < r_Pix;
    dotsInnerDiskLabelsGroup1(itrial, :)=dotsInnerDiskLabel;
    dSign = rand()>0.5;
    dSignsGroup1(itrial, :) = dSign;
    d_Pix = (2*dSign-1) * dAbsoluteStep_Pix * params.stim.maxdStep;
    ds_PixGroup1(itrial, :) = d_Pix;

    xLeftSelected = xRightSelected + d_Pix*dotsInnerDiskLabel;
    yLeftSelected = yRightSelected;   
    rectDotsGroup1(itrial, 1, :, :) = vertcat(xLeftSelected, yLeftSelected, xLeftSelected+s_Pix, yLeftSelected+s_Pix);
    rectDotsGroup1(itrial, 2, :, :) = vertcat(xRightSelected, yRightSelected, xRightSelected+s_Pix, yRightSelected+s_Pix);
    colorSelected = repmat(((rand(Ndots, 1)>0.5) * 255)', 3, 1);
    colorDotsGroup1(itrial, 1, :, :) = colorSelected;
    colorDotsGroup1(itrial, 2, :, :) = colorSelected;
end

% --------------------------------------------------------
% Buffer: Statement Group2 Page
% --------------------------------------------------------
StatementGroup2Page = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementGroup2Page, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementGroup2Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementGroup2Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementGroup2Page, 'Practice Session 2', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'you will do a session of 10 trials.', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'You need to stare at the red cross among words', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'and distinguish whether the central disk is in', Screen_center(1)-300,Screen_center(2)+60, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'front of or behind the surrounding ring. And', Screen_center(1)-300,Screen_center(2)+80, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'finally you press the button y to report the', Screen_center(1)-300,Screen_center(2)+100, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'centraldisk is in front of the surrounding ring', Screen_center(1)-300,Screen_center(2)+120, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'or press any other button if you think it is', Screen_center(1)-300,Screen_center(2)+140, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'behind the surrounding ring. ', Screen_center(1)-300,Screen_center(2)+160, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup2Page, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+180, params.screen.FOR_COLOR);
Screen('FrameRect', StatementGroup2Page, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

% --------------------------------------------------------
% Buffer: FixationGroup2 Page
% --------------------------------------------------------
% generate random dots (rect and color) by sampling polar coordinates
rectDotsGroup2 = zeros(params.stim.NTrialsGroup2, 2, 4, Ndots);
colorDotsGroup2 = zeros(params.stim.NTrialsGroup2, 2, 3, Ndots);
dSignsGroup2 = zeros(params.stim.NTrialsGroup2, 1);
dStepsGroup2 = zeros(params.stim.NTrialsGroup2, 1);
ds_PixGroup2 = zeros(params.stim.NTrialsGroup2, 1);
dotsInnerDiskLabelsGroup2 = zeros(params.stim.NTrialsGroup2, Ndots);
for itrial = 1 : params.stim.NTrialsGroup2
    randAngle_Deg = unifrnd(0, pi*2, 1, Ndots);
    randLength_Pix = unifrnd(0, R_Pix+s_Pix, 1, Ndots);
    xSelected = Screen_center(1) + randLength_Pix.*cos(randAngle_Deg);
    ySelected = Screen_center(2) + randLength_Pix.*sin(randAngle_Deg);
    dotsInnerDiskLabel = randLength_Pix < r_Pix;
    dotsInnerDiskLabelsGroup2(itrial, :)=dotsInnerDiskLabel;
    dSign = rand()>0.5;
    dSignsGroup2(itrial, :) = dSign;
    randdStep = round(rand() * params.stim.maxdStep);
    dStepsGroup2(itrial, :) = randdStep;
    d_PixGroup2 = (2*dSign-1) * dAbsoluteStep_Pix * randdStep;
    ds_PixGroup2(itrial, :) = d_PixGroup2;
    if mod(d_PixGroup2, 2) == 0
        xLeftSelected = xSelected + d_PixGroup2/2 * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected - d_PixGroup2/2 * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    else
        shifts = [(abs(d_PixGroup2) + 1)/2, (abs(d_PixGroup2) - 1)/2];
        shiftRand = rand()>0.5;
        xLeftSelected = xSelected + shifts(shiftRand+1) * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected + shifts(2 - shiftRand) * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    end 

    rectDotsGroup2(itrial, 1, :, :) = vertcat(xLeftSelected, yLeftSelected, xLeftSelected+s_Pix, yLeftSelected+s_Pix);
    rectDotsGroup2(itrial, 2, :, :) = vertcat(xRightSelected, yRightSelected, xRightSelected+s_Pix, yRightSelected+s_Pix);
    colorSelected = repmat(((rand(Ndots, 1)>0.5) * 255)', 3, 1);
    colorDotsGroup2(itrial, 1, :, :) = colorSelected;
    colorDotsGroup2(itrial, 2, :, :) = colorSelected;
end


% --------------------------------------------------------
% Buffer: Statement Group3 Page
% --------------------------------------------------------
StatementGroup3Page = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementGroup3Page, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementGroup3Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementGroup3Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementGroup3Page, 'Practice Session 3', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'you will do a session of 20 trials.', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'You need to stare at the red cross among words', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'and distinguish whether the central disk is in', Screen_center(1)-300,Screen_center(2)+60, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'front of or behind the surrounding ring. And', Screen_center(1)-300,Screen_center(2)+80, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'finally you press the button y to report the', Screen_center(1)-300,Screen_center(2)+100, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'centraldisk is in front of the surrounding ring', Screen_center(1)-300,Screen_center(2)+120, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'or press any other button if you think it is', Screen_center(1)-300,Screen_center(2)+140, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'behind the surrounding ring. ', Screen_center(1)-300,Screen_center(2)+160, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup3Page, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+180, params.screen.FOR_COLOR);
Screen('FrameRect', StatementGroup3Page, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);


% --------------------------------------------------------
% Buffer: FixationGroup3 Page
% --------------------------------------------------------
% generate random dots (rect and color) by sampling polar coordinates
NtotalTrialsGroup3 = params.stim.NfixationPositionGroup3 * params.stim.NTrialsGroup3;
TypeViewsSelcetedGroup3 = ones(NtotalTrialsGroup3,1);
randTypeViewsGroup3  = randperm(NtotalTrialsGroup3);
randType1ViewsGroup3  = randTypeViewsGroup3(1:params.stim.NTrialsGroup3);
randType2ViewsGroup3  = randTypeViewsGroup3(params.stim.NTrialsGroup3+1:NtotalTrialsGroup3);
TypeViewsSelcetedGroup3(randType2ViewsGroup3) = 2;

rectDotsGroup3 = zeros(NtotalTrialsGroup3, 2, 4, Ndots);
colorDotsGroup3 = zeros(NtotalTrialsGroup3, 2, 3, Ndots);
dSignsGroup3 = zeros(NtotalTrialsGroup3, 1);
dStepsGroup3 = zeros(NtotalTrialsGroup3, 1);
ds_PixGroup3 = zeros(NtotalTrialsGroup3, 1);
dotsInnerDiskLabelsGroup3 = zeros(NtotalTrialsGroup3, Ndots);
for itrial = 1: NtotalTrialsGroup3
    randAngle_Deg = unifrnd(0, pi*2, 1, Ndots);
    randLength_Pix = unifrnd(0, R_Pix+s_Pix, 1, Ndots);
    xSelected = Screen_center(1) + randLength_Pix.*cos(randAngle_Deg);
    ySelected = Screen_center(2) + randLength_Pix.*sin(randAngle_Deg);
    dotsInnerDiskLabel = randLength_Pix < r_Pix;
    dotsInnerDiskLabelsGroup3(itrial, :)=dotsInnerDiskLabel;
    dSign = rand()>0.5;
    dSignsGroup3(itrial, :) = dSign;
    randdStep = round(rand() * params.stim.maxdStep);
    dStepsGroup3(itrial, :) = randdStep;
    d_PixGroup3 = (2*dSign-1) * dAbsoluteStep_Pix * randdStep;
    ds_PixGroup3(itrial, :) = d_PixGroup3;

    if mod(d_PixGroup3, 2) == 0
        xLeftSelected = xSelected + d_PixGroup3/2 * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected - d_PixGroup3/2 * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    else
        shifts = [(abs(d_PixGroup3) + 1)/2, (abs(d_PixGroup3) - 1)/2];
        shiftRand = rand()>0.5;
        xLeftSelected = xSelected + shifts(shiftRand+1) * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected + shifts(2 - shiftRand) * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    end 
    rectDotsGroup3(itrial, 1, :, :) = vertcat(xLeftSelected, yLeftSelected, xLeftSelected+s_Pix, yLeftSelected+s_Pix);
    rectDotsGroup3(itrial, 2, :, :) = vertcat(xRightSelected, yRightSelected, xRightSelected+s_Pix, yRightSelected+s_Pix);
    colorSelected = repmat(((rand(Ndots, 1)>0.5) * 255)', 3, 1);
    colorDotsGroup3(itrial, 1, :, :) = colorSelected;
    colorDotsGroup3(itrial, 2, :, :) = colorSelected;
end

% --------------------------------------------------------
% Buffer: Statement Group4 Page
% --------------------------------------------------------
StatementGroup4Page = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementGroup4Page, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementGroup4Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementGroup4Page, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementGroup4Page, 'Practice Session 4', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'you will do a session of 6 trials.', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'You need to stare at the red cross among words', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'and distinguish whether the central disk is in', Screen_center(1)-300,Screen_center(2)+60, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'front of or behind the surrounding ring. And', Screen_center(1)-300,Screen_center(2)+80, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'finally you press the button y to report the', Screen_center(1)-300,Screen_center(2)+100, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'centraldisk is in front of the surrounding ring', Screen_center(1)-300,Screen_center(2)+120, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'or press any other button if you think it is', Screen_center(1)-300,Screen_center(2)+140, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'behind the surrounding ring. ', Screen_center(1)-300,Screen_center(2)+160, params.screen.FOR_COLOR);
Screen('DrawText', StatementGroup4Page, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+180, params.screen.FOR_COLOR);
Screen('FrameRect', StatementGroup4Page, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);


% --------------------------------------------------------
% Buffer: FixationGroup4 Page
% --------------------------------------------------------
% generate random dots (rect and color) by sampling polar coordinates
NtotalTrialsGroup4 = params.stim.NfixationPositionGroup4 * params.stim.NTypesRDSCorrelationGroup4 * params.stim.NTrialsPerConditionGroup4;
TypeViewsSelcetedGroup4 = ones(NtotalTrialsGroup4,1);

randTypeViewsGroup4  = randperm(NtotalTrialsGroup4);
randType1ViewsGroup4  = randTypeViewsGroup4(1:params.stim.NTypesRDSCorrelationGroup4*params.stim.NTrialsPerConditionGroup4);
randType2ViewsGroup4  = randTypeViewsGroup4(params.stim.NTypesRDSCorrelationGroup4*params.stim.NTrialsPerConditionGroup4+1:NtotalTrialsGroup4);
TypeViewsSelcetedGroup4(randType2ViewsGroup4) = 2;

TypeRDSCorrelationGroup4 = ones(NtotalTrialsGroup4,1);
randTypeRDSCorrelationGroup4 = randperm(NtotalTrialsGroup4);
randType1RDSCorrelationGroup4 = randTypeRDSCorrelationGroup4(1 : params.stim.NfixationPositionGroup4*params.stim.NTrialsPerConditionGroup4);
randType2RDSCorrelationGroup4 = randTypeRDSCorrelationGroup4(params.stim.NfixationPositionGroup4*params.stim.NTrialsPerConditionGroup4+1 : 2*params.stim.NfixationPositionGroup4*params.stim.NTrialsPerConditionGroup4);
randType3RDSCorrelationGroup4 = randTypeRDSCorrelationGroup4(2*params.stim.NfixationPositionGroup4*params.stim.NTrialsPerConditionGroup4+1 : NtotalTrialsGroup4);
TypeRDSCorrelationGroup4(randType2RDSCorrelationGroup4) = 2;
TypeRDSCorrelationGroup4(randType3RDSCorrelationGroup4) = 3;

rectDotsGroup4 = zeros(NtotalTrialsGroup4, 2, 4, Ndots);
colorDotsGroup4 = zeros(NtotalTrialsGroup4, 2, 3, Ndots);
dSignsGroup4 = zeros(NtotalTrialsGroup4, 1);
dStepsGroup4 = zeros(NtotalTrialsGroup4, 1);
ds_PixGroup4 = zeros(NtotalTrialsGroup4, 1);
dotsInnerDiskLabelsGroup4 = zeros(NtotalTrialsGroup4, Ndots);

for itrial = 1 : NtotalTrialsGroup4
    itypesRDSCorrelation = TypeRDSCorrelationGroup4(itrial);
    randAngle_Deg = unifrnd(0, pi*2, 1, Ndots);
    randLength_Pix = unifrnd(0, R_Pix+s_Pix, 1, Ndots);
    xSelected = Screen_center(1) + randLength_Pix.*cos(randAngle_Deg);
    ySelected = Screen_center(2) + randLength_Pix.*sin(randAngle_Deg);
    dotsInnerDiskLabel = randLength_Pix < r_Pix;
    dotsInnerDiskLabelsGroup4(itrial, :)=dotsInnerDiskLabel;
    dSign = rand()>0.5;
    dSignsGroup4(itrial, :) = dSign;
    randdStep = round(rand() * params.stim.maxdStep);
    dStepsGroup4(itrial, :) = randdStep;
    d_Pix = (2*dSign-1) * dAbsoluteStep_Pix * randdStep;
    ds_PixGroup4(itrial, :) = d_Pix;

    if mod(d_Pix, 2) == 0
        xLeftSelected = xSelected + d_Pix/2 * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected - d_Pix/2 * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    else
        shifts = [(abs(d_Pix) + 1)/2, (abs(d_Pix) - 1)/2];
        shiftRand = rand()>0.5;
        xLeftSelected = xSelected + shifts(shiftRand+1) * dotsInnerDiskLabel;
        yLeftSelected = ySelected;
        xRightSelected = xSelected + shifts(2 - shiftRand) * dotsInnerDiskLabel;
        yRightSelected = ySelected;
    end 
    rectDotsGroup4(itrial, 1, :, :) = vertcat(xLeftSelected, yLeftSelected, xLeftSelected+s_Pix, yLeftSelected+s_Pix);
    rectDotsGroup4(itrial, 2, :, :) = vertcat(xRightSelected, yRightSelected, xRightSelected+s_Pix, yRightSelected+s_Pix);
    
    colorSelected = repmat(((rand(Ndots, 1)>0.5) * 255)', 3, 1);
    colorDotsGroup4(itrial, 1, :, :) = colorSelected;
    if itypesRDSCorrelation == 1 % correlated RDS
        colorDotsGroup4(itrial, 2, :, :) = colorSelected;
    elseif itypesRDSCorrelation == 2 % half-matched RDS
        randDismatchedDotsLabel = repmat(((rand(Ndots, 1)>0.5))', 3, 1);
        colorDotsGroup4(itrial, 2, :, :) = abs(colorSelected - (randDismatchedDotsLabel.*repmat(dotsInnerDiskLabel, 3, 1))*255);              
    elseif itypesRDSCorrelation == 3 % anticorrelated RDS
        colorDotsGroup4(itrial, 2, :, :) = abs(colorSelected-repmat(dotsInnerDiskLabel, 3, 1) * 255); 
    end  
end

% --------------------------------------------------------
% Buffer: Statement Practice End Page
% --------------------------------------------------------
StatementFailPracticePage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementFailPracticePage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementFailPracticePage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementFailPracticePage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementFailPracticePage, 'You have failed the practice. Thanks for your work', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementFailPracticePage, 'Now you can leave', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementFailPracticePage, 'Press any button before you leave', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('FrameRect', StatementFailPracticePage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

% --------------------------------------------------------
% Buffer: Statement Practice End Page
% --------------------------------------------------------
StatementPracticeEndPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementPracticeEndPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementPracticeEndPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementPracticeEndPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementPracticeEndPage, 'You have finished the practice successfully', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementPracticeEndPage, 'Now you will enter the offical test session', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementPracticeEndPage, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('FrameRect', StatementPracticeEndPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

% --------------------------------------------------------
% Buffer: Statement Group4 Page
% --------------------------------------------------------
StatementTestPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
% Display some texts on screen
Screen('BlendFunction', StatementTestPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawLines', StatementTestPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
Screen('DrawLines', StatementTestPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
Screen('DrawText', StatementTestPage, 'Offical Test Session', Screen_center(1)-300,Screen_center(2), params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'you will do a session of 300 trials.', Screen_center(1)-300,Screen_center(2)+20, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'You need to stare at the red cross among words', Screen_center(1)-300,Screen_center(2)+40, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'and distinguish whether the central disk is in', Screen_center(1)-300,Screen_center(2)+60, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'front of or behind the surrounding ring. And', Screen_center(1)-300,Screen_center(2)+80, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'finally you press the button y to report the', Screen_center(1)-300,Screen_center(2)+100, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'centraldisk is in front of the surrounding ring', Screen_center(1)-300,Screen_center(2)+120, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'or press any other button if you think it is', Screen_center(1)-300,Screen_center(2)+140, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'behind the surrounding ring. ', Screen_center(1)-300,Screen_center(2)+160, params.screen.FOR_COLOR);
Screen('DrawText', StatementTestPage, 'Press any button if you are ready', Screen_center(1)-300,Screen_center(2)+180, params.screen.FOR_COLOR);
Screen('FrameRect', StatementTestPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

%% trial loop
%--------------------------------------------------------------------------
% EXPERIMENT
%--------------------------------------------------------------------------

% get time information
day = date; clocktime = clock;
% define the log file name
fn =[subjectName, '-r', num2str(sessionNumber), '-', day, '-', num2str(clocktime(4)), '-', num2str(clocktime(5)), '.mat'];

% Wait Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, WaitInstructionPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, WaitInstructionPage)
Screen('Flip', windowPtr);
pause(0.7);

% -- practice sessions
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, IntroPracticeGroupPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, IntroPracticeGroupPage)
Screen('Flip', windowPtr);
KbWait;

% practice session 1: 10 central trials with fully correlated RDSs
% Statement Group1 Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, StatementGroup1Page)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, StatementGroup1Page)
Screen('Flip', windowPtr);
pause(0.5);
KbWait;

Group1_reports = zeros(params.stim.NTrialsGroup1, 1);
for itrial = 1 : params.stim.NTrialsGroup1
    % prefixation Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    Screen('Flip', windowPtr);
    pause(0.5);
    KbWait;

    % prepare the stimulus for fixation page
    FixationLeftPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    FixationRightPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    Screen('BlendFunction', FixationLeftPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('BlendFunction', FixationRightPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if params.stim.greenCircle == 1
        Screen('FrameOval', FixationLeftPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
        Screen('FrameOval', FixationRightPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
    end

    Screen('FillRect', FixationLeftPage, squeeze(colorDotsGroup1(itrial, 1, :, :)), squeeze(rectDotsGroup1(itrial, 1, :, :)));
    Screen('FillRect', FixationRightPage, squeeze(colorDotsGroup1(itrial, 2, :, :)), squeeze(rectDotsGroup1(itrial, 2, :, :)));
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('FrameRect', FixationLeftPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
    Screen('FrameRect', FixationRightPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

    % fixation page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, FixationLeftPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,FixationRightPage)
    Screen('Flip', windowPtr);
    pause(params.stim.fixationPeriodTimeMSGroup1);

    % Report Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, ReportPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,ReportPage)
    Screen('Flip', windowPtr);    
    [keyPressTimeSec, keyCode] = KbWait;
    report = keyCode(params.screen.FRONT_REPORT) == 1;
    FlushEvents('keyDown');	

    % Clear buffers and textures
    Screen('Close', FixationLeftPage);
    Screen('Close', FixationRightPage);
    
    % save the data..............
    Group1_reports(itrial, :) = report;
end

% group 2: 10 central trials with fully correlated RDSs
% Statement Group2 Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, StatementGroup2Page)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, StatementGroup2Page)
Screen('Flip', windowPtr);
pause(0.5);
KbWait;

Group2_reports = zeros(params.stim.NTrialsGroup2, 1);
for itrial = 1 : params.stim.NTrialsGroup2
    % prefixation Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    Screen('Flip', windowPtr);
    pause(0.5);
    KbWait;

    % prepare the stimulus for fixation page
    FixationLeftPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    FixationRightPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    Screen('BlendFunction', FixationLeftPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('BlendFunction', FixationRightPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if params.stim.greenCircle == 1
        Screen('FrameOval', FixationLeftPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
        Screen('FrameOval', FixationRightPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
    end

    Screen('FillRect', FixationLeftPage, squeeze(colorDotsGroup2(itrial, 1, :, :)), squeeze(rectDotsGroup2(itrial, 1, :, :)));
    Screen('FillRect', FixationRightPage, squeeze(colorDotsGroup2(itrial, 2, :, :)), squeeze(rectDotsGroup2(itrial, 2, :, :)));
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('FrameRect', FixationLeftPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
    Screen('FrameRect', FixationRightPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

    % fixation page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, FixationLeftPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,FixationRightPage)
    Screen('Flip', windowPtr);
    pause(params.stim.fixationPeriodTimeMSGroup234);

    % Report Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, ReportPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,ReportPage)
    Screen('Flip', windowPtr);    
    [keyPressTimeSec, keyCode] = KbWait;
    report = keyCode(params.screen.FRONT_REPORT) == 1;
    FlushEvents('keyDown');	

    % Clear buffers and textures
    Screen('Close', FixationLeftPage);
    Screen('Close', FixationRightPage);
    
    % save the data..............
    Group2_reports(itrial, :) = report;
end

% group 3: 20 trials of the fully correlated RDS, of which 10 each(central and peripheral views), in a randomized order
% Statement Group3 Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, StatementGroup3Page)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, StatementGroup3Page)
Screen('Flip', windowPtr);
pause(0.5);
KbWait;

Group3_reports = zeros(NtotalTrialsGroup3, 1);
for itrial = 1: NtotalTrialsGroup3
    ifixationPosition = TypeViewsSelcetedGroup3(itrial);
    % Prefixation page
    if ifixationPosition == 1
        Screen('SelectStereoDrawBuffer',windowPtr,0);
        Screen('DrawTexture', windowPtr, PrefixationCentralPage)
        Screen('SelectStereoDrawBuffer',windowPtr,1);
        Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    else
        Screen('SelectStereoDrawBuffer',windowPtr,0);
        Screen('DrawTexture', windowPtr, PrefixationPeripheralPage)
        Screen('SelectStereoDrawBuffer',windowPtr,1);
        Screen('DrawTexture', windowPtr, PrefixationPeripheralPage)
    end
    Screen('Flip', windowPtr);
    pause(0.5);
    KbWait;

    % prepare the stimulus for fixation page
    FixationLeftPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    FixationRightPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    Screen('BlendFunction', FixationLeftPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('BlendFunction', FixationRightPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if params.stim.greenCircle == 1
        Screen('FrameOval', FixationLeftPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
        Screen('FrameOval', FixationRightPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
    end

    Screen('FillRect', FixationLeftPage, squeeze(colorDotsGroup3(itrial, 1, :, :)), squeeze(rectDotsGroup3(itrial, 1, :, :)));
    Screen('FillRect', FixationRightPage, squeeze(colorDotsGroup3(itrial, 2, :, :)), squeeze(rectDotsGroup3(itrial, 2, :, :)));
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('FrameRect', FixationLeftPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
    Screen('FrameRect', FixationRightPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

    % fixation page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, FixationLeftPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,FixationRightPage)
    Screen('Flip', windowPtr);
    pause(params.stim.fixationPeriodTimeMSGroup234);

    % Report Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, ReportPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,ReportPage)
    Screen('Flip', windowPtr);    
    [keyPressTimeSec, keyCode] = KbWait;
    report = keyCode(params.screen.FRONT_REPORT) == 1;
    FlushEvents('keyDown');	

    % Clear buffers and textures
    Screen('Close', FixationLeftPage);
    Screen('Close', FixationRightPage);
    
    % save the data..............
    Group3_reports(ifixationPosition, itypesRDSCorrelation, itrial, :) = report;
end

% determine whether to enter group 4
fraction_group1 = sum(dSignsGroup1 == Group1_reports)/params.stim.NTrialsGroup1;
fraction_group2 = sum(dSignsGroup2 == Group2_reports)/params.stim.NTrialsGroup2;
fraction_group31 = sum(dSignsGroup3(randType1ViewsGroup3) == Group3_reports(randType1ViewsGroup3))/params.stim.NTrialsGroup3;
fraction_group32 = sum(dSignsGroup3(randType1ViewsGroup4) == Group3_reports(randType1ViewsGroup4))/params.stim.NTrialsGroup3;
if(fraction_group1 < 0.9 | fraction_group2 < 0.9 | fraction_group31 < 0.9|fraction_group32 < 0.9)
    % Statement Fail the Practice Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, StatementFailPracticePage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr, StatementFailPracticePage)
    Screen('Flip', windowPtr);
    pause(0.5);
    KbWait;

    save(fn)
    sca    
end

% group 4: 6 example trials, one for each of the six experimental conditions
% Statement Group4 Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, StatementGroup4Page)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, StatementGroup4Page)
Screen('Flip', windowPtr);
pause(0.5);
KbWait;

Group4_reports = zeros(NtotalTrialsGroup4, 1);
for itrial = 1 : NtotalTrialsGroup4
    ifixationPosition = TypeViewsSelcetedGroup4(itrial);
    % Prefixation page
    if ifixationPosition == 1
        Screen('SelectStereoDrawBuffer',windowPtr,0);
        Screen('DrawTexture', windowPtr, PrefixationCentralPage)
        Screen('SelectStereoDrawBuffer',windowPtr,1);
        Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    else
        Screen('SelectStereoDrawBuffer',windowPtr,0);
        Screen('DrawTexture', windowPtr, PrefixationPeripheralPage)
        Screen('SelectStereoDrawBuffer',windowPtr,1);
        Screen('DrawTexture', windowPtr, PrefixationPeripheralPage)
    end
    Screen('Flip', windowPtr);
    pause(0.5);
    KbWait;

    % prepare the stimulus for fixation page
    FixationLeftPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    FixationRightPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    Screen('BlendFunction', FixationLeftPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('BlendFunction', FixationRightPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if params.stim.greenCircle == 1
        Screen('FrameOval', FixationLeftPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
        Screen('FrameOval', FixationRightPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
    end

    Screen('FillRect', FixationLeftPage, squeeze(colorDotsGroup4(itrial, 1, :, :)), squeeze(rectDotsGroup4(itrial, 1, :, :)));
    Screen('FillRect', FixationRightPage, squeeze(colorDotsGroup4(itrial, 2, :, :)), squeeze(rectDotsGroup4(itrial, 2, :, :)));
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('FrameRect', FixationLeftPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
    Screen('FrameRect', FixationRightPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

    % fixation page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, FixationLeftPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,FixationRightPage)
    Screen('Flip', windowPtr);
    pause(params.stim.fixationPeriodTimeMSGroup234);

    % Report Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, ReportPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,ReportPage)
    Screen('Flip', windowPtr);    
    [keyPressTimeSec, keyCode] = KbWait;
    report = keyCode(params.screen.FRONT_REPORT) == 1;
    FlushEvents('keyDown');	

    % Clear buffers and textures
    Screen('Close', FixationLeftPage);
    Screen('Close', FixationRightPage);
    
    % save the data..............
    Group4_reports(ifixationPosition, itypesRDSCorrelation, itrial, :) = report;
end
  

% Statement Practice Group Ending and Offical Experiment Starting Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, StatementPracticeEndPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, StatementPracticeEndPage)
Screen('Flip', windowPtr);
pause(0.5);
KbWait;

% -- offical test page
% Statement test Page
Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, StatementTestPage)
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, StatementTestPage)
Screen('Flip', windowPtr);
pause(0.5);
KbWait;

reports = zeros(NtotalTrials, 1);
for itrial = 1 : NtotalTrials
    ifixationPosition = TypeViewsSelceted(itrial);
    % Prefixation page
    if ifixationPosition == 1
        Screen('SelectStereoDrawBuffer',windowPtr,0);
        Screen('DrawTexture', windowPtr, PrefixationCentralPage)
        Screen('SelectStereoDrawBuffer',windowPtr,1);
        Screen('DrawTexture', windowPtr, PrefixationCentralPage)
    else
        Screen('SelectStereoDrawBuffer',windowPtr,0);
        Screen('DrawTexture', windowPtr, PrefixationPeripheralPage)
        Screen('SelectStereoDrawBuffer',windowPtr,1);
        Screen('DrawTexture', windowPtr, PrefixationPeripheralPage)
    end
    Screen('Flip', windowPtr);
    pause(0.5);
    KbWait;

    % prepare the stimulus for fixation page
    FixationLeftPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    FixationRightPage = Screen('OpenOffscreenWindow', windowPtr, params.screen.BACK_COLOR);
    Screen('BlendFunction', FixationLeftPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('BlendFunction', FixationRightPage, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if params.stim.greenCircle == 1
        Screen('FrameOval', FixationLeftPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
        Screen('FrameOval', FixationRightPage, params.screen.GREEN_COLOR, [Screen_center(1)-r_Pix Screen_center(2)-r_Pix Screen_center(1)+r_Pix, Screen_center(2)+r_Pix]);
    end

    Screen('FillRect', FixationLeftPage, squeeze(colorDots(itrial, 1, :, :)), squeeze(rectDots(itrial, 1, :, :)));
    Screen('FillRect', FixationRightPage, squeeze(colorDots(itrial, 2, :, :)), squeeze(rectDots(itrial, 2, :, :)));
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e0_Pix], 2);
    Screen('DrawLines', FixationLeftPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('DrawLines', FixationRightPage, crossAllCoords, params.screen.lineWidthPix, params.screen.RED_COLOR, [Screen_center(1) Screen_center(2)-e1_Pix], 2);
    Screen('FrameRect', FixationLeftPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);
    Screen('FrameRect', FixationRightPage, params.stim.colorBinocularRectangular, windowRect_dot, binocularRectangularFrameWidth_Pix);

    % fixation page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, FixationLeftPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,FixationRightPage)
    Screen('Flip', windowPtr);
    pause(params.stim.fixationPeriodTimeMSGroup234);

    % Report Page
    Screen('SelectStereoDrawBuffer',windowPtr,0);
    Screen('DrawTexture', windowPtr, ReportPage)
    Screen('SelectStereoDrawBuffer',windowPtr,1);
    Screen('DrawTexture', windowPtr,ReportPage)
    Screen('Flip', windowPtr);    
    [keyPressTimeSec, keyCode] = KbWait;
    report = keyCode(params.screen.FRONT_REPORT) == 1;
    FlushEvents('keyDown');	

    % Clear buffers and textures
    Screen('Close', FixationLeftPage);
    Screen('Close', FixationRightPage);
    
    % save the data..............
    reports(ifixationPosition, itypesRDSCorrelation, itrial, :) = report;
end


%% Finish

Screen('SelectStereoDrawBuffer',windowPtr,0);
Screen('DrawTexture', windowPtr, ExperimentFinishPage);
Screen('SelectStereoDrawBuffer',windowPtr,1);
Screen('DrawTexture', windowPtr, ExperimentFinishPage);
Screen('Flip', windowPtr);
% leave the ending page on the screen until a key press is received
pause(1);
KbWait;

% save all variables into file named fn
save(fn)
% short for "Screen('CloseAll')"
% close all buffers and textures and exit PTB 
sca







