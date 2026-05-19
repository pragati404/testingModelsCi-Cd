classdef TestVSelect < matlab.unittest.TestCase

    methods (Test)

        function testMeanPositive(tc)
            % When mean > 0, output should equal mean
            in = Simulink.SimulationInput('V_select');
            in = in.setVariable('inputSignal', [3, 5, 7, 2, 4]);
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyGreaterThan(out, 0, 'Output should be mean when mean > 0');
        end

        function testMedianUsedWhenMeanNegative(tc)
            % When mean <= 0 but median > 0, output should be median
            in = Simulink.SimulationInput('V_select');
            in = in.setVariable('inputSignal', [-10, -10, 5, -10, -10]);
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyGreaterThan(out, 0, 'Output should be median when mean <= 0');
        end

        function testFallbackValue(tc)
            % When both mean and median <= 0, output should be 0.0001
            in = Simulink.SimulationInput('V_select');
            in = in.setVariable('inputSignal', [-5, -3, -7, -2, -4]);
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyEqual(out, 0.0001, 'AbsTol', 1e-6, ...
                'Output should be 0.0001 when both mean and median <= 0');
        end

        function testOutputNeverZero(tc)
            % Output should never be exactly zero
            in = Simulink.SimulationInput('V_select');
            in = in.setVariable('inputSignal', [-1, -1, -1, -1, -1]);
            simOut = sim(in);
            out = simOut.yout{1}.Values.Data(end);
            tc.verifyNotEqual(out, 0, 'Output should never be zero');
        end

    end

end