% NRMSE from Fessler nufft toolbox

function nn = nrmse(xtrue, xhat, dummy)

nn = norm(xhat(:) - xtrue(:)) / norm(xtrue(:));
