package tests;

import math.IntRect;
import utest.ui.Report;
import utest.Runner;

import tests.math.IntRectTest;
import tests.utils.ColorTest;
import tests.extenders.FloatExtenderTest;
import tests.extenders.StringExtenderTest;
import tests.extenders.TileExtenderTest;
import tests.utils.Direction4Test;
import tests.utils.FiniteGridTest;
import tests.utils.GridTest;

class NoExitReport extends utest.ui.text.PrintReport {
    override function complete(result:utest.ui.common.PackageResult) {
      this.result = result;
      if (handler != null) handler(this);
    }
  }

class Main extends hxd.App {
    static private function main () {
        new Main();
    }

    override private function init (): Void {
        trace("init");

        var runner = new Runner();
    
        runner.addCase(new ColorTest());
        runner.addCase(new Direction4Test());
        runner.addCase(new FiniteGridTest());
        runner.addCase(new GridTest());
        runner.addCase(new EventTest());
        runner.addCase(new IntRectTest());
        runner.addCase(new FloatExtenderTest());
        runner.addCase(new StringExtenderTest());
        runner.addCase(new TileExtenderTest());
    
        new NoExitReport(runner);
        runner.run();

        hxd.System.exit();
    }
}