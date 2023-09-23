fs = 500;%������
f1 = 5;%�ź�Ƶ��
f2 = 10;%�ź�Ƶ��
T = 1;%ʱ��1s
n = round(T*fs);%���������
t = linspace(0,T,n);%ʱ�������

% �Ӵ�Hamming

x = 3+cos(2*pi*f1*t) + 2.*cos(2*pi*f2*t);%�γ���Ƶ�ź�,ע��ڶ���Ƶ���źŷ���Ϊ2��ֱ������Ϊ3
figure(1);
plot(t,x);%��ʱ��ͼ
xlabel('t/s')
grid on

X = fftshift(fft(x./(n))); %��fft�ó���ɢ����Ҷ�任
f=linspace(-fs/2,fs/2-1,n);%Ƶ������꣬ע���ο�˹�ز����������ԭ�ź����Ƶ�ʲ���������Ƶ�ʵ�һ��
figure(2)
plot(f,abs(X));%��˫��Ƶ�׷���ͼ
xlabel('f/Hz')
ylabel('����')
grid on
