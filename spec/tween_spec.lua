local tween = require 'tween'

describe('tween', function()

  local counter = 0
  local function count(x)
    x = x or 1
    counter = counter + x
  end

  local function assert_table_equal(t1, t2)
    local type1, type2 = type(t1), type(t2)
    assert_equal(type1, type2)
    if type(t1)=='table' then
      for k,v in pairs(t1) do assert_table_equal(v, t2[k]) end
    else
      assert_equal(t1, t2)
    end
  end

  local function testEasing(easing, values)
    test(easing .. ' works as expected', function()
      local subject = {0}
      local steps = #values
      local target = {values[steps]}
      local dt = 1
      tween(steps, subject, target, easing)
      for i=1, steps do
        tween.update(dt)
        assert_less_than(math.abs(subject[1] - values[i]), 0.1)
      end
    end)
  end

  before(function()
    counter = 0
    tween.stopAll()
  end)

  describe('tween.start', function()

    describe('parameters', function()
      test('time should be a positive number', function()
        assert_error(function() tween.start(0, {}, {}) end)
        assert_error(function() tween.start(-1, {}, {}) end)
        assert_error(function() tween.start('foo', {}, {}) end)
        assert_not_error(function() tween.start(1, {}, {}) end)
      end)

      test('subject should be a table or userdata', function()
        assert_error(function() tween.start(1, 1, {}) end)
        assert_error(function() tween.start(1, "foo", {}) end)

        assert_not_error(function() tween.start(1, {}, {}) end)

        local f = io.input()
        assert_type(f, "userdata")
        assert_not_error(function() tween.start(1, f, {}) end)
      end)

      test('target should be a table', function()
        assert_error(function() tween.start(1, {}, 1) end)
        assert_error(function() tween.start(1, {}, "foo") end)
        assert_not_error(function() tween.start(1, {}, {}) end)
      end)

      test('target data can only be numbers or tables with numbers', function()
        assert_error(function() tween.start(1, {1,2}, {'a', 'b'}) end)
        assert_error(function() tween.start(1, {x=1}, {x = print}) end)
        assert_not_error(function() tween.start(1, {x=1}, {x = 2}) end)
        assert_not_error(function() tween.start(1, {color={255,255,255}}, {color={0,0,0}}) end)
      end)

      test('subject data must correspond to target data', function()
        assert_error(function() tween.start(1, {}, {x=1}) end)
        assert_error(function() tween.start(1, {y=1}, {x = 1}) end)
        assert_error(function() tween.start(1, {y=1}, {y = {1,2,3}}) end)
        assert_error(function() tween.start(1, {a={b={c=3}}}, {a=1}) end)
        assert_not_error(function() tween.start(1, {1, a={b={c=3}}}, {3, a={b={c=1}}}) end)
      end)

      test('easing must be a function or valid easing function name, or nil', function()
        assert_error(function() tween.start(1, {}, {}, 'foo') end)
        assert_not_error(function() tween.start(1, {}, {}, function() end) end)
        assert_not_error(function() tween.start(1, {}, {}, 'linear') end)
      end)

      test('callback must be callable or nil', function()
        assert_error(function() tween.start(1, {}, {}, 'linear', 'foo') end)
        assert_not_error(function() tween.start(1, {}, {}, 'linear', function() end) end)
        assert_not_error(function() tween.start(1, {}, {}, 'linear', tween) end)
      end)

    end)

  end)

  describe('tween', function()
    test('Should work just like tween.start', function()
      assert_not_error(function() tween(1, {}, {}) end)
      assert_not_nil(tween(1, {}, {}))
    end)
  end)

  describe('tween.update', function()
    test('Should only admit positive numbers for dt', function()
      assert_error(function() tween.update(-1) end)
      assert_error(function() tween.update(0) end)
      assert_error(function() tween.update('foo') end)
      assert_not_error(function() tween.update(1) end)
    end)

    test('Tweening should happen recursively', function()
      local subject = {1, a = {1, {2, 3}}}
      local target =  {a = {4, {8, 12}}}
      tween(3, subject, target)
      tween.update(1)
      assert_table_equal(subject, {1, a = {2, {4, 6}}})
      tween.update(1)
      assert_table_equal(subject, {1, a = {3, {6, 9}}})
      tween.update(1)
      assert_table_equal(subject, {1, a = {4, {8, 12}}})
    end)

    test('Tweening should be chainable', function()
      local subject = {1}
      local t = tween(1, subject, {2}, 'linear', tween, 1, subject, {3}, 'linear', tween, 1, subject, {4})
      tween.update(1)
      assert_equal(subject[1], 2)
      tween.update(1)
      assert_equal(subject[1], 3)
      tween.update(1)
      assert_equal(subject[1], 4)
    end)

    test('Traffic Light', function()
      local trafficLight = { color1 = {255,0,0}, color2 = {0,0,0}, color3 = {0,0,0} }
      local yellow = { color1 = {0,0,0}, color2 = {255,255,0}, color3 = {0,0,0} }
      local green = { color1 = {0,0,0}, color2 = {0,0,0}, color3 = {0,255,0} }

      tween(1, trafficLight, yellow, 'linear', tween, 1, trafficLight, green)
      tween.update(1)
      assert_table_equal(trafficLight, yellow)
      tween.update(1)
      assert_table_equal(trafficLight, green)
    end)

    test('tweens are not spontaneously garbage-collected', function()
      local subject = {0}
      tween(1, subject, {1})
      collectgarbage('collect')
      tween.update(1)
      assert_table_equal({1}, subject)
    end)

    test('When easing is finished, subject values should be goals', function()
      local a = {1}
      local b = {x = 1, y = 1}
      local c = {color = {0,0,0}}

      tween(1, a, {2}, 'linear', count)
      tween(3, b, {x = 2, y = 2}, 'linear', count, 2)
      tween(5, c, {color = {255,30,50}})

      tween.update(1)           -- 1
      assert_equal(a[1], 2)
      assert_equal(counter, 1)

      tween.update(1)           -- 2
      assert_equal(a[1], 2)
      assert_equal(counter, 1)

      tween.update(1)           -- 3
      assert_table_equal(b, {x=2, y=2})
      assert_equal(counter, 3)

      tween.update(2)           -- 5
      assert_table_equal(b, {x=2, y=2})
      assert_table_equal(c, {color={255,30,50}})
      assert_equal(counter, 3)
    end)
  end)

  describe('tween.reset', function()

    test('it does nothing if the id isnt on the tween list', function()
      assert_not_error(function() tween.reset(nil) end)
      assert_not_error(function() tween.reset(1) end)
      assert_not_error(function() tween.reset('foo') end)
    end)

    test('it moves the subject back to its initial state, and cancels movement', function()
      local subject = {1}
      local id = tween(2, subject, {3})
      tween.update(1)
      tween.reset(id)
      assert_equal(subject[1], 1)
    end)

  end)

  describe('tween.resetAll', function()
    test('it moves all the subjects back to their initial state', function()
      local a,b = {1},{1}
      tween(2, a, {3})
      tween(2, b, {3})
      tween.update(1)
      tween.resetAll()
      assert_equal(a[1], 1)
      assert_equal(b[1], 1)
    end)
  end)

  describe('tween.stop', function()

    test('it does nothing if the id isnt on the tween list', function()
      assert_not_error(function() tween.stop(nil) end)
      assert_not_error(function() tween.stop(1) end)
      assert_not_error(function() tween.stop('foo') end)
    end)

    test('it moves stops any tween - without resetting their state', function()
      local subject = {1}
      local id = tween(2, subject, {3})
      tween.update(1)
      tween.stop(id)
      tween.update(1)
      assert_equal(subject[1], 2)
    end)

  end)

  describe('tween.stopAll', function()
    test('it stops all the tweens', function()
      local a,b = {1},{1}
      tween(2, a, {3})
      tween(2, b, {3})
      tween.update(1)
      tween.stopAll()
      tween.update(1)
      assert_equal(a[1], 2)
      assert_equal(b[1], 2)
    end)
  end)

  describe('easing', function()
    testEasing('inBack', {-0.07832505,-0.2862844,-0.58335435,-0.9290112,-1.28273125,-1.6039908,-1.85226615,-1.9870336,
                          -1.96776945,-1.75395,-1.30505155,-0.5805504,0.46007715,1.8573548,3.65180625,5.8839552,
                          8.59432535,11.8234404,15.61182405,20})
    testEasing('inBounce', {0.309375,0.2375,1.096875,1.2,0.546875,1.3875,3.346875,4.55,4.996875,4.6875,3.621875,
                            1.8,1.471875,6.3875,10.546875,13.95,16.596875,18.4875,19.621875,20})
    testEasing('inCirc', {0.025015644561821,0.1002512578676,0.22628006671481,0.40408205773458,
                          0.63508326896291,0.92121597166109,1.2650060048048,1.6696972201766,2.1394289005082,
                          2.6794919243112,3.2967069115099,4,4.8013158464293,5.7171431429143, 6.771243444677,
                          8,9.4643462471473,11.282202112919,13.755002001602,20})
    testEasing('inCubic', {0.0025,0.02,0.0675,0.16,0.3125,0.54,0.8575,1.28,1.8225,2.5,3.3275,4.32,5.4925,6.86,
                           8.4375,10.24,12.2825,14.58,17.1475,20})
    testEasing('inElastic', {0.01381067932005,0.0390625,0.027621358640099,-0.0390625,-0.1104854345604,-0.078125,
                             0.1104854345604,0.3125,0.2209708691208,-0.3125,-0.88388347648318,-0.625,
                             0.88388347648318,2.5,1.7677669529664,-2.5,-7.0710678118655,-5,7.0710678118655,20})
    testEasing('inExpo', {0.0076213586400995,0.0190625,0.035242717280199,0.058125,0.090485434560398,
                          0.13625,0.2009708691208,0.2925,0.42194173824159,0.605,0.86388347648318,
                          1.23,1.7477669529664,2.48,3.5155339059327,4.98,7.0510678118655,9.98,14.122135623731,20})
    testEasing('inOutBack', {-0.223541855,-0.75037104,-1.364792985,-1.85111312,-1.993636875,
                             -1.57666968,-0.384516965,1.79851584,5.188123305,10,14.811876695,18.20148416,
                             20.384516965,21.57666968,21.993636875,21.85111312,21.364792985,20.75037104,20.223541855,20})
    testEasing('inOutBounce',{0.11875,0.6,0.69375,2.275,2.34375,0.9,3.19375,6.975,9.24375,10,10.75625,13.025,16.80625,
                              19.1,17.65625,17.725,19.30625,19.4,19.88125,20})
    testEasing('inOutCirc', {0.0501256289338,0.20204102886729,0.46060798583054,0.83484861008832,1.3397459621556,
                             2,2.8585715714572,4,5.6411010564593,10,14.358898943541,16,17.141428428543,18,
                             18.660254037844,19.165151389912,19.539392014169,19.797958971133,19.949874371066,20})
    testEasing('inOutCubic', {0.01,0.08,0.27,0.64,1.25,2.16,3.43,5.12,7.29,10,12.71,
                             14.88,16.57,17.84,18.75,19.36,19.73,19.92,19.99,20})
    testEasing('inOutElastic', {0.01953125,-0.01953125,-0.0390625,0.15625,-0.15625,-0.3125,1.25,-1.25,-2.5,
                                10,22.5,21.25,18.75,20.3125,20.15625,19.84375,20.0390625,20.01953125,19.98046875,20})
    testEasing('inOutExpo',  {0.00953125,0.0290625,0.068125,0.14625,0.3025,0.615,1.24,2.49,4.99,10.005,15.0075,
                              17.50875,18.759375,19.3846875,19.69734375,19.853671875,
                              19.9318359375,19.97091796875,19.990458984375,20})
    testEasing('inOutQuad', {0.1,0.4,0.9,1.6,2.5,3.6,4.9,6.4,8.1,10,11.9,13.6,15.1,16.4,17.5,18.4,19.1,19.6,19.9,20})
    testEasing('inOutQuart',  {0.001,0.016,0.081,0.256,0.625,1.296,2.401,4.096,6.561,10,
                               13.439,15.904,17.599,18.704,19.375,19.744,19.919,19.984,19.999,20})
    testEasing('inOutQuint', {0.0001,0.0032,0.0243,0.1024,0.3125,0.7776,1.6807,3.2768, 5.9049,10,14.0951,16.7232,
                              18.3193,19.2224,19.6875,19.8976,19.9757,19.9968,19.9999,20})
    testEasing('inOutSine', {0.12311659404862,0.48943483704846,1.0899347581163,1.9098300562505,
                             2.9289321881345,4.1221474770753,5.4600950026045,6.9098300562505,8.4356553495977,
                             10,11.564344650402,13.090169943749,14.539904997395,15.877852522925,17.071067811865,
                             18.090169943749,18.910065241884,19.510565162952,19.876883405951,20})
    testEasing('inQuad', {0.05,0.2,0.45,0.8,1.25,1.8,2.45,3.2,4.05,5,6.05,7.2,8.45,9.8,11.25,12.8,14.45,16.2,18.05,20})
    testEasing('inQuart', {0.000125,0.002,0.010125,0.032,0.078125,0.162,0.300125,0.512,0.820125,1.25,
                           1.830125,2.592,3.570125,4.802,6.328125,8.192,10.440125,13.122,16.290125,20})
    testEasing('inQuint',  {6.25e-06,0.0002,0.00151875,0.0064,0.01953125,0.0486,0.10504375,
                            0.2048,0.36905625,0.625,1.00656875,1.5552,2.32058125,3.3614,
                            4.74609375,6.5536,8.87410625,11.8098,15.47561875,20})
    testEasing('inSine', {0.061653325337442,0.24623318809724,0.55260159204647,0.97886967409693,
                          1.5224093497743,2.1798695162326,2.9471967129182,3.8196601125011,4.7918806879994,
                          5.857864376269,7.0110390333963,8.2442949541505,9.550028705681,10.920190005209,
                          12.346331352698,13.819660112501,15.331092722882,16.871310699195,18.430818085443,20})
    testEasing('linear', {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20})
    testEasing('outBack', {4.38817595,8.1765596,11.40567465,14.1160448,16.34819375,18.1426452,
                           19.53992285,20.5805504,21.30505155,21.75395,21.96776945,
                           21.9870336,21.85226615,21.6039908,21.28273125,20.9290112,20.58335435,
                           20.2862844,20.07832505,20})
    testEasing('outBounce',  {0.378125,1.5125,3.403125,6.05,9.453125,13.6125,18.528125,18.2,16.378125,
                              15.3125,15.003125,15.45,16.653125,18.6125,19.453125,18.8,18.903125,19.7625,19.690625,20})
    testEasing('outCirc', {6.2449979983984,8.7177978870813,10.535653752853,12,13.228756555323,14.282856857086,
                           15.198684153571,16,16.70329308849,17.320508075689,17.860571099492,18.330302779823,
                           18.734993995195,19.078784028339,19.364916731037,19.595917942265,
                           19.773719933285,19.899748742132,19.974984355438,20})
    testEasing('outCubic', {2.8525,5.42,7.7175,9.76,11.5625,13.14,14.5075,15.68,16.6725,17.5,
                            18.1775,18.72,19.1425,19.46,19.6875,19.84,19.9325,19.98,19.9975,20})
    testEasing('outElastic', {12.928932188135,25,27.071067811865,22.5,18.232233047034,17.5,19.116116523517,
                              20.625,20.883883476483,20.3125,19.779029130879,19.6875,19.88951456544,20.078125,
                              20.11048543456,20.0390625,19.97237864136,19.9609375,19.98618932068,20})
    testEasing('outExpo', {5.8637222406453,10.01,12.941861120323,15.015,16.480930560161,17.5175,
                           18.250465280081,18.76875,19.13523264004,19.394375,19.57761632002,
                           19.7071875,19.79880816001,19.86359375,19.909404080005,19.941796875,
                           19.964702040003,19.9808984375,19.992351020001,20})
    testEasing('outInBack', {4.0882798,7.0580224,9.0713226,10.2902752,10.876975,10.9935168,10.8019954,
                             10.4645056,10.1431422,10,9.8568578,9.5354944,9.1980046,9.0064832,
                             9.123025,9.7097248,10.9286774,12.9419776,15.9117202,20})
    testEasing('outInBounce', {0.75625,3.025,6.80625,9.1,7.65625,7.725,9.30625,9.4,9.88125,10,
                               10.11875,10.6,10.69375,12.275,12.34375,10.9,13.19375,16.975,19.24375,20})
    testEasing('outInCirc',  {4.3588989435407,6,7.1414284285428,8,8.6602540378444,9.1651513899117,
                              9.5393920141695,9.7979589711327,9.9498743710662,10,10.050125628934,
                              10.202041028867,10.460607985831,10.834848610088,11.339745962156,
                              12,12.858571571457,14,15.641101056459,20})
    testEasing('outInCubic', {2.71,4.88,6.57,7.84,8.75,9.36,9.73,9.92,9.99,10,
                              10.01,10.08,10.27,10.64,11.25,12.16,13.43,15.12,17.29,20})
    testEasing('outInElastic',{12.5,11.25,8.75,10.3125,10.15625,9.84375,10.0390625,
                               10.01953125,9.98046875,10,10.01953125,9.98046875,9.9609375,
                               10.15625,9.84375,9.6875,11.25,8.75,7.5,20})
    testEasing('outInExpo', {5.005,7.5075,8.75875,9.384375,9.6971875,9.85359375,9.931796875,
                             9.9708984375,9.99044921875,10,10.00953125,10.0290625,
                             10.068125,10.14625,10.3025,10.615,11.24,12.49,14.99,20})
    testEasing('outInQuad', {1.9,3.6,5.1,6.4,7.5,8.4,9.1,9.6,9.9,10,10.1,10.4,10.9,11.6,12.5,13.6,14.9,16.4,18.1,20})
    testEasing('outInQuart', {3.439,5.904,7.599,8.704,9.375,9.744,9.919,9.984,9.999,10,10.001,
                              10.016,10.081,10.256,10.625,11.296,12.401,14.096,16.561,20})
    testEasing('outInQuint', {4.0951,6.7232,8.3193,9.2224,9.6875,9.8976,9.9757,9.9968,9.9999,
                              10,10.0001,10.0032,10.0243,10.1024,10.3125,10.7776,
                              11.6807,13.2768,15.9049,20})
    testEasing('outInSine', {1.5643446504023,3.0901699437495,4.5399049973955,5.8778525229247,7.0710678118655,
                             8.0901699437495,8.9100652418837,9.5105651629515,9.8768834059514,
                             10,10.123116594049,10.489434837048,11.089934758116,11.909830056251,
                             12.928932188135,14.122147477075,15.460095002605,16.909830056251,18.435655349598,20})
    testEasing('outQuad', {1.95,3.8,5.55,7.2,8.75,10.2,11.55,12.8,13.95,15,
                           15.95,16.8,17.55,18.2,18.75,19.2,19.55,19.8,19.95,20})
    testEasing('outQuart', {3.709875,6.878,9.559875,11.808,13.671875,15.198,16.429875,17.408,
                            18.169875,18.75,19.179875,19.488,19.699875,19.838,19.921875,
                            19.968,19.989875,19.998,19.999875,20})
    testEasing('outQuint', {4.52438125,8.1902,11.12589375,13.4464,15.25390625,16.6386,17.67941875,
                            18.4448,18.99343125,19.375,19.63094375,19.7952,19.89495625,19.9514,19.98046875,
                            19.9936,19.99848125,19.9998,19.99999375,20})
    testEasing('outSine', {1.5691819145569,3.1286893008046,4.6689072771181,6.1803398874989,7.6536686473018,
                           9.0798099947909,10.449971294319,11.755705045849,12.988960966604,
                           14.142135623731,15.208119312001,16.180339887499,17.052803287082,
                           17.820130483767,18.477590650226,19.021130325903,19.447398407954,
                           19.753766811903,19.938346674663,20})
  end)
  
  describe( 'preserve-metatables', function()
    test('A completed tween should preserve metatables in the interpolated table', function()
      local mt = {}
      local a = { val = 1}
      local b = { val = 2}

      setmetatable(a, mt)
      setmetatable(b, mt)

      tween(1, a, b)
      
      tween.update(1)           -- 1

      assert_equal(b.val, 2)
      assert_not_nil(getmetatable(a))
      assert_equal(mt, getmetatable(a))
    end)
    test('A completed tween should preserve metatables in the interpolated subtable', function()
      local mt = {}
      local a = { val = 1}
      local b = { val = 2}

      setmetatable(a, mt)
      setmetatable(b, mt)

      local c = { t = a }

      tween(1, c, { t = b })
      
      tween.update(1)           -- 1

      assert_equal(c.t.val, 2)
      assert_not_nil(getmetatable(c.t))
      assert_equal(mt, getmetatable(c.t))
    end)
  end)

  describe('copy-target', function()
    test('a changing target should not affect a tween in progress', function()
      local a = {1}
      local b = {3}

      tween(2, a, b, 'linear', count)

      b[1] = 10
      tween.update(1)           -- 1
      assert_equal(a[1], 2)

      tween.update(1)           -- 2
      assert_equal(a[1], 3)
    end)
    test('a changing target should not affect final values of a tween', function()
      local a = {1}
      local b = {3}

      tween(2, a, b, 'linear', count)

      tween.update(1)           -- 1

      b[1] = 10
      tween.update(1)           -- 2
      assert_equal(a[1], 3)
    end)
  end)

end)


