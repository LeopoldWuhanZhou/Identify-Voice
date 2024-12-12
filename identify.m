file='m5.wav'
[x,fs]=audioread(file); 

%======Pretreatment======
% Take audio clips
threshold = 0.01; 
voiced_indices = find(abs(x) > threshold);
x_voiced = x(min(voiced_indices):max(voiced_indices), :);

% Denoising
x_denoised = x_voiced - mean(x_voiced);

% Framing
frame_size = 0.025; 
frame_shift = 0.05; 
frame_length = round(frame_size * fs);
frame_step = round(frame_shift * fs);
num_frames = floor((length(x_denoised) - frame_length) / frame_step) + 1;

frames = zeros(num_frames, frame_length);
for i = 1:num_frames
    start_index = (i-1) * frame_step + 1;
    end_index = start_index + frame_length - 1;
    frames(i, :) = x_denoised(start_index:end_index);
end

%======Time Domain Image======  
data=x_denoised(:); 
n=0:length(data)-1;

time=n/fs;
figure(1);
plot(time,data);
title('Time Domain')  
xlabel('Time/s');       
ylabel('Amplitude');        
grid on;               

%=======Frequency Domain Image======
N=length(data);
Y1=fft(data,N);
mag=abs(Y1);
f=n*fs/N;
figure(2);
plot(f(1:fix(N/2)),mag(1:fix(N/2)));
title('Frequency Domain');
xlabel('Frequency/Hz');
ylabel('Amplitude');

%======Fundamental Frequency Selection======
[~,index]=max(data);
timewin=floor(0.015*fs);
xwin=data(index-timewin:index+timewin);
[y,~]=xcov(xwin);
ylen=length(y);
halflen=(ylen+1)/2 +30;
yy=y(halflen: ylen);
[~,maxindex] = max(yy);
fmax=fs/(maxindex+30);
disp([file,' Fundamental frequency is ', num2str(fmax), ' Hz'])

%======Judgement======
if fmax<150;
    disp([file,' is male voice file']);
else
    disp([file,' is female voice file']);
end;

%======MFCC======
% MFCC
coeffs = mfcc(x, fs);

% Mean of MFCC coefficients
mean_coeffs = mean(coeffs);
disp([file,' Mean of MFCC is ',num2str(mean_coeffs(1))]);

%======Judgement======
threshold = -7.15; 

if mean_coeffs(1) < threshold
    disp([file, ' is female voice file']);
else
    disp([file, ' is male voice file']);
end;
