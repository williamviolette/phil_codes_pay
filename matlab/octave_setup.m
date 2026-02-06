% octave_setup.m - Octave compatibility setup
% Call this at the top of main scripts (after 'clear') to ensure
% Octave packages are loaded and compatibility shims are in place.
%
% Safe to call from MATLAB -- it detects the environment and does nothing.

if exist('OCTAVE_VERSION', 'builtin')
    % Load the optim package (provides fminunc, fmincon, etc.)
    try
        pkg load optim;
    catch
        warning('octave_setup: optim package not installed. fminunc will fall back to fminsearch.');
        warning('Install with: pkg install -forge optim');
    end

    % Load the statistics package (provides additional stat functions)
    try
        pkg load statistics;
    catch
        % Not critical -- only warn if needed
    end
end
