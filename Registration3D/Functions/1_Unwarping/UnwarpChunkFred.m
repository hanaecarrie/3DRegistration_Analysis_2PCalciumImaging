function unwarp_chunk = UnwarpChunkFred(vol30,nbchunck,...
    tforms_optitune,reg_target,xmin,xmax,ymin,ymax,Nz,pxshift)
      
    for i = 1:nbchunck
        c_i = 1:Nz:size(vol30,4);
        temp_vol = vol30(:,:,:,c_i(i):c_i(i)+(Nz-1));
        for j = 1:Nz %correct distortion due to optitune
            red_slice = squeeze(temp_vol(2,:,:,j));
            red_slice = uint16(shift_correction(red_slice,pxshift));
            red_slice = red_slice(ymin:ymax,xmin:xmax);
            
            green_slice = squeeze(temp_vol(1,:,:,j));
            green_slice = uint16(shift_correction(green_slice,pxshift));
            green_slice = green_slice(ymin:ymax,xmin:xmax);
            
%             unwarp_vol(1,:,:,j,i) = imwarp(red_slice,tforms_optitune(j),'OutputView',imref2d(size(red_slice)));
%             unwarp_vol(2,:,:,j,i) = imwarp(green_slice,tforms_optitune(j),'OutputView',imref2d(size(green_slice)));
            
            unwarp_vol(1,:,:,j) = imwarp(red_slice,tforms_optitune(j),'OutputView',imref2d(size(red_slice)));
            unwarp_vol(2,:,:,j) = imwarp(green_slice,tforms_optitune(j),'OutputView',imref2d(size(green_slice)));
        end
        
        unwarp_chunk(:,:,:,:,i) = unwarp_vol;

        %get translation from red channel
        reg_source = squeeze(mean(unwarp_chunk(1,:,:,:,i),4));
        transform = GetTransformFFT(reg_source, reg_target, 1);
        %apply registration to red channel
        unwarp_chunk(1,:,:,:,i) = ApplyTranslationFFT(squeeze(unwarp_chunk(1,:,:,:,i)),transform);
        %apply registration to green channel
        unwarp_chunk(2,:,:,:,i) = ApplyTranslationFFT(squeeze(unwarp_chunk(2,:,:,:,i)),transform);
        clear temp_vol
    end
    vol30 = [];
end