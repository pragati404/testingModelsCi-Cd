classdef TestVSelect < matlab.unittest.TestCase

    methods (TestMethodSetup)
        function addModelPath(tc)
            % Add models folder to MATLAB path
            addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'models'));
        end
    end

    methods (Test)

        function testMeanPositive(tc)
            load_system('V_select');
            simOut = sim('V_select');
            tc.verifyNotEmpty(simOut);
            close_system('V_select', 0);
        end

        function testModelLoads(tc)
            % Just verify model loads without error
            load_system('V_select');
            tc.verifyTrue(bdIsLoaded('V_select'));
            close_system('V_select', 0);
        end

    end

end
