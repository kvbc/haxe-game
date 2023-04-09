package tests.extenders;

import utest.Assert;
using extenders.StringExtender;

class StringExtenderTest extends utest.Test {
    private function test () {
        var s = "test";

        Assert.equals(s.padRight(10, ' '), "      test");
        Assert.equals(s.padLeft(10, ' '), "test      ");
        Assert.equals(s.repeat(3), "testtesttest");
    }
}