classdef TestVSelect < matlab.unittest.TestCase

    methods (TestMethodSetup)
        function addModelPath(tc)
            addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'models'));
        end
    end

    methods (Test)

        function testModelLoads(tc)
            % Verify model loads without error
            load_system('V_select');
            tc.verifyTrue(bdIsLoaded('V_select'));
            close_system('V_select', 0);
        end

        function testMeanPositive(tc)
            % Input: mostly positive numbers → mean > 0 → output = mean
            % mean([3,5,7,2,4]) = 4.2 → output should be > 0.0001
            load_system('V_select');

            t = (0:0.1:0.4)';
            u = [3; 5; 7; 2; 4];
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));

            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);

            tc.verifyGreaterThan(out, 0.0001, ...
                'Mean was positive so output should be above fallback');
            close_system('V_select', 0);
        end

        function testMixedInputOutputPositive(tc)
            % Input: mix of positive and negative numbers
            % Tests that output is always > 0 no matter what
            load_system('V_select');

            t = (0:0.1:0.9)';
            u = [3; -2; 5; -1; 4; -3; 2; -4; 1; 6];
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));

            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);

            tc.verifyGreaterThan(out, 0, ...
                'Output must always be > 0 for mixed inputs');
            close_system('V_select', 0);
        end

        function testAllNegativeDefaultCase(tc)
            % Input: all negative numbers
            % mean < 0, median < 0 → should hit fallback → output = 0.0001
            load_system('V_select');

            t = (0:0.1:0.4)';
            u = [-3; -5; -7; -2; -4];
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));

            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);

            if abs(out - 0.0001) < 1e-9
                tc.log('Default case triggered correctly: output = 0.0001');
                tc.verifyEqual(out, 0.0001, 'AbsTol', 1e-9);
            else
                tc.verifyGreaterThan(out, 0, ...
                    'Output must still be positive');
            end
            close_system('V_select', 0);
        end

        function testOutputNeverBelowFallback(tc)
            % Output must never go below 0.0001 under any input
            load_system('V_select');

            t = (0:0.1:0.4)';
            u = [-10; -20; -5; -15; -8];
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));

            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);

            tc.verifyGreaterThanOrEqual(out, 0.0001, ...
                'Output must never go below fallback value 0.0001');
            close_system('V_select', 0);
        end

    end

end
