function [x_clean,fs] = denoise(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input: filename = text string with file extension of audio file to be
%                   cleaned. This was written for a class where it was
%                   specified that there would be 1-3 sinusoidal noise
%                   signals that occur on multiples of 50 Hz.
%
% Output: x_clean = cleaned speech signal without sinusoidal noise.
%         fs = sampling frequency of original audio signal.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[x,fs] = audioread(filename);

figure()
plotspecDB(x, fs, 500, 80)


for i = 1:6
    Xk = fft(x);
    %figure()
    %plotspecDB(x, fs, 500, 80)
    %figure()
    %stem(Xk);
    % Find index of max value in the frequency domain signal
    [mx, indx] = max(Xk);
    start_indx = indx - 6;
    if start_indx < 1
        start_indx = 1;
    end
    Xk_reduced = Xk;
    Xk_reduced(start_indx:start_indx+12)=0;
    % Determine if removed peak contains atleast 1% of the total sum of the
    % sequence
    if sum(abs(Xk_reduced)) > 0.99*sum(abs(Xk))
        break
    end
    
    % Find frequency to null
    fnull = (indx-1)/length(Xk)*fs;
    fnull = round(fnull/50)*50;
    
    a = -2*cos(2*pi*fnull/fs);
    h = [1 a 1];
    % Convolve with nulling filter to remove frequency
    x = conv(x, h);
    x = x(3:length(x)-2);
end

figure()
plotspecDB(x, fs, 500, 80)
x_clean = x;

% Listen to the cleaned audio file
%soundsc(x_clean,fs);

end