% filename.txt 为要保存的文件名，data 为工作区中的变量
% 2023.4.26

% 创建文件
% fid=fopen('data/0403-1_downsample.txt','w');%建立文件
fid=fopen('0403-1_downsample-338750.txt','w');%建立文件
% 循环写入数据
% for i=1:length(x_ds_sample)
%     fprintf(fid,'%.5f\t%.2f\t%.2f\r\n',x_ds_sample(i),y_ids_sample(i),y_qds_sample(i));% 保存小数点后8位
% end

for i=1:length(x_ds)
    fprintf(fid,'%.5f\t%.2f\t%.2f\r\n',x_ds(i),y_ids(i),y_qds(i));% 保存小数点后8位
end

fclose(fid);