function []= WriteVideo(SavingPath, Matrix)
% WRITEVIDEO: this function writes and saves a video file from a matrix

v = VideoWriter(SavingPath);

open(v);

for k = 1 : size(Matrix,3)
    writeVideo(v, mat2gray(double(Matrix(:,:,k))));
end

close(v);

end