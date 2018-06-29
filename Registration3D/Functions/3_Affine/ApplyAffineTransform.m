function [] = ApplyAffineTransform(plane, pathaffineshifts)

% Affine align using turboreg in ImageJ
            nchunks = ceil(nframes/chunksize);
            ootform = cell(1, nchunks);
            ootrans = cell(1, nchunks);
            for c = 1:nchunks
                ootform{c} = tform((c-1)*chunksize+1:...
                min(nframes, c*chunksize));
            end

            % Get the current parallel pool or initailize
            openParallel();

            parfor c = 1:nchunks
                ootrans{c} = sbxAlignAffinePlusDFT(path, ...
                    (c-1)*chunksize+1, chunksize, bigref, ...
                    ootform{c}, p.pmt, p.edges);
            end

            for c = 1:nchunks
                pos = (c - 1)*chunksize + 1;
                upos = min(c*chunksize, nframes);
                trans(pos:upos, :) = ootrans{c};
            end
        end

        afalign = [path(1:strfind(path,'.')-1) '.alignaffine' p.save_title];
        save(afalign, 'tform', 'trans', 'binframes');
    out = 1;
    end
    