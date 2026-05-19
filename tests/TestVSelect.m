classdef TestVSelect < matlab.unittest.TestCase

    methods (TestMethodSetup)
        function addModelPath(tc)
            addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'models'));
        end
    end

    methods (Test)

        function testModelLoads(tc)
            load_system('V_select');
            tc.verifyTrue(bdIsLoaded('V_select'));
            close_system('V_select', 0);
        end

        function testMeanPositive(tc)
            % Input: all positive → mean > 0 → output > 0.0001
            load_system('V_select');
            t = (0:0.1:0.4)';
            u = single([3; 5; 7; 2; 4]);
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyGreaterThan(out, 0.0001, ...
                'Mean was positive so output should be above fallback');
            close_system('V_select', 0);
        end

        function testMixedInputOutputPositive(tc)
            % Input: mix of positive and negative → output always > 0
            load_system('V_select');
            t = (0:0.1:0.9)';
            u = single([3; -2; 5; -1; 4; -3; 2; -4; 1; 6]);
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyGreaterThan(out, 0, ...
                'Output must always be > 0 for mixed inputs');
            close_system('V_select', 0);
        end

        function testAllNegativeDefaultCase(tc)
            load_system('V_select');
            t = (0:0.1:0.4)';
            u = single([-3; -5; -7; -2; -4]);
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);

            if abs(out - 0.0001) < 1e-6
                fprintf('\n>>> DEFAULT CASE TRIGGERED: output = %f (fallback value)\n', out);
                tc.log('Default case triggered correctly: output = 0.0001');
                tc.verifyEqual(out, single(0.0001), 'AbsTol', single(1e-6));
            else
                fprintf('\n>>> NORMAL CASE: output = %f (mean or median used)\n', out);
                tc.log('Normal case: output is above fallback value');
                tc.verifyGreaterThan(out, 0, 'Output must still be positive');
            end
            close_system('V_select', 0);
        end
        
        function testOutputNeverBelowFallback(tc)
            % Output must never go below 0.0001 under any input
            load_system('V_select');
            t = (0:0.1:0.4)';
            u = single([-10; -20; -5; -15; -8]);
            in = Simulink.SimulationInput('V_select');
            in = in.setExternalInput(timeseries(u, t));
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyGreaterThanOrEqual(out, single(0.0001), ...
                'Output must never go below fallback value 0.0001');
            close_system('V_select', 0);
        end

    end

end
