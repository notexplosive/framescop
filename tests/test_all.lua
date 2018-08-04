require('tests.framework')

-- Unit test the test functions, who watches the watchmen?
local fakeObject = {
    alwaysFalse = function() return false end,
}

local frameworkTests = {
    TestFunctions.createObjectTest(
        fakeObject,
        'alwaysFalse',
        nil,
        false),
    TestFunctions.createObjectTest(
        TestFunctions,
        'compareValue',
        {'this is identical','this is identical'},
        true),
    TestFunctions.createObjectTest(
        TestFunctions,
        'compareValue',
        {1,1},
        true),
    TestFunctions.createObjectTest(
        TestFunctions,
        'compareValue',
        {'this is identical','this no identical'},
        false)
}

TestFunctions.runTests('TestFramework',frameworkTests)
