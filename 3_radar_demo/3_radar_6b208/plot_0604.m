figure;
n = 50;     % 在N个chip中取第n个chirp并显示

% plotSamples = numADCSamples;
plotSamples = 25;
process_adc_fft = abs(fft(process_adc(:,n)));   % 250*1,是否应该用fftshitf?
plot((1:plotSamples)*delta_R, db(process_adc_fft(1:plotSamples))); 
xlabel('距离（m）');
ylabel('幅度(dB)');
title('Fig.1.距离维FFT(1个chirp)');
grid on

%% todo 2023.6.4
% 按照YonseiU的配置重新测量，在0.6m为间距，测0.6,1.2,1.8m，先看能不能找出信号强的点
% [53]YonseiU的配置：
% 参考[54]TexusU的算法流程
