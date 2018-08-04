TestFunctions = {}

-- Compare two lists
function TestFunctions.compareList(t1,t2)
    if isNil(t1) or isNil(t2) then
        err = ''
        if isNil(t1) then
            err = 'left table is nil'
        end

        if isNil(t2) then
            if err ~= '' then
                err = err .. ', '
            end
            err = err .. 'right table is nil'
        end

        return false,err
    end

    if #t1 == #t2 then
        local output = ''
        local correct = true
        for i in pairs(t1) do
            output = output .. v .. ':' .. t1[i] .. '\t' .. t2[i]
            if t1[i] ~= t2[i] then
                output = output .. '\tERR!'
                correct = false
            end
        end

        return correct,output
    end

    return false,"list different size " .. #t1 .. ' vs ' .. #t2
end

-- Simple value compare
function TestFunctions.compareValue(v1,v2)
    -- Booleans don't concat by default grumble grumble
    if type(v1) == 'boolean' then
        if v1 == true then
            v1 = 'true'
        else
            v1 = 'false'
        end

        if v2 == true then
            v2 = 'true'
        else
            v2 = 'false'
        end
    end

    if v1 ~= v2 then
        return false,"value compare failed:\n"..'v1:'..v1..'\n'..'v2:'..v2
    else
        return true,'success'
    end
end

function TestFunctions.createObjectTest(obj,fnName,args,expected)
    local test = {}

    test.obj = obj
    test.fnName = fnName
    test.testFn = testFn
    test.args = args
    test.expected = expected

    test.run = function(self)
        if self.args == nil then
            self.args = {}
        end

        local actual = self.obj[self.fnName](unpack(self.args))
        local type = type(self.expected)
        if type == 'table' then
            valid,output = TestFunctions.compareList(actual,self.expected)
        else
            valid,output = TestFunctions.compareValue(actual,self.expected)
        end
        return valid,output
    end

    return test
end

function TestFunctions.runTests(suiteName,listOfTests)
    local numberFailed = 0
    local totalTests = #listOfTests

    for i,test in ipairs(listOfTests) do
        local valid,output = test:run()
        if not valid then
            numberFailed = numberFailed + 1
            print('Test [' .. i .. ']' .. ' failed for ' .. suiteName .. ' ' .. test.fnName)
        end
    end

    print(suiteName .. ': ' .. totalTests .. ' tests ran, ' .. numberFailed .. ' tests failed.')
end

function isNil(tb)
    return tb == nil
end