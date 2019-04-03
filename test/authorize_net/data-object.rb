require 'nokogiri'
require 'authorize_net'
require 'minitest/autorun'

class TestObject < AuthorizeNet::DataObject
  ATTRIBUTES = {
    :x => {:key => "xVal"},
    :y => {:key => "yVal"},
    :radius => nil,
    :color => nil,
  }

  self::ATTRIBUTES.keys.each do |attr|
    attr_accessor attr
  end
end

class TestParent < AuthorizeNet::DataObject
  ATTRIBUTES = {
    :circles => {
      :type => AuthorizeNet::DataObject::TYPE_OBJECT_ARRAY,
      :class => TestObject,
    },
    :middle_circle => {
      :key => "middleCircle",
      :type => AuthorizeNet::DataObject::TYPE_OBJECT,
      :class => TestObject,
    },
    :things => {
      :type => AuthorizeNet::DataObject::TYPE_ARRAY,
    }
  }

  self::ATTRIBUTES.keys.each do |attr|
    attr_accessor attr
  end
end


class TestUtil < Minitest::Test

  def test_parse
    x = 1
    y = 2
    radius = 5
    color = "green"

    xml = Nokogiri::XML.parse("<circle><xVal>#{x}</xVal><yVal>#{y}</yVal><radius>#{radius}</radius><color>#{color}</color>")
    test = TestObject.parse(xml)

    assert_equal(x.to_s, test.x)
    assert_equal(y.to_s, test.y)
    assert_equal(radius.to_s, test.radius)
    assert_equal(color, test.color)
  end

  def test_nested
    xml = Nokogiri::XML.parse("<parentObject><circles><xVal>2</xVal><yVal>4</yVal></circles><circles><radius>10</radius><color>blue</color></circles><middleCircle><xVal>9</xVal><yVal>11</yVal><color>orange</color><radius>3</radius></middleCircle><things>A</things><things>B</things><things>C</things></parentObject>")

    test = TestParent.parse(xml)
    assert_equal(2, test.circles.length)
    circle1 = test.circles[0]
    circle2 = test.circles[1]
    middle_circle = test.middle_circle

    assert_equal('2', circle1.x)
    assert_equal('4', circle1.y)
    assert_nil(circle1.radius)
    assert_nil(circle1.color)

    assert_nil(circle2.x)
    assert_nil(circle2.y)
    assert_equal('10', circle2.radius)
    assert_equal('blue', circle2.color)

    assert_equal('9', middle_circle.x)
    assert_equal('11', middle_circle.y)
    assert_equal('3', middle_circle.radius)
    assert_equal('orange', middle_circle.color)

    assert_equal(3, test.things.length)
    assert_equal('A', test.things[0])
    assert_equal('B', test.things[1])
    assert_equal('C', test.things[2])
  end

  def test_partial_parse
    x = 1
    color = "green"

    xml = Nokogiri::XML.parse("<circle><xVal>#{x}</xVal><color>#{color}</color></circle>")
    test = TestObject.parse(xml)

    assert_equal(x.to_s, test.x)
    assert_nil(test.y)
    assert_nil(test.radius)
    assert_equal(color, test.color)
  end

  def test_parse_bad_xml
    test = TestObject.parse("nothing here")
    assert_nil(test)

    test = TestObject.parse({:still => "junk"})
    assert_nil(test)

    test= TestObject.parse(1394083120598)
    assert_nil(test)
  end

  def test_to_h
    test = TestObject.new
    test.x = 1
    test.y = 2
    test.color = "blue"
    test.radius = 400

    hash = test.to_h
    assert_equal(test.x, hash["xVal"])
    assert_equal(test.y, hash["yVal"])
    assert_equal(test.color, hash["color"])
    assert_equal(test.radius, hash["radius"])

    test2 = TestObject.new
    test2.x = 9000
    test2.color = "black"

    hash2 = test2.to_h
    assert_equal(test2.x, hash2["xVal"])
    assert_nil(hash2["yVal"])
    assert_equal(test2.color, hash2["color"])
    assert_nil(hash2["radius"])
  end

  def test_serialize
    c1 = TestObject.new
    c1.x = 1
    c1.y = 2
    c1.color = "blue"
    c1.radius = 4

    c2 = TestObject.new
    c2.x = 10
    c2.y = 20
    c2.color = "green"
    c2.radius = 40

    mid = TestObject.new
    mid.x = 100
    mid.y = 200

    parent = TestParent.new
    parent.circles = [c1, c2]
    parent.middle_circle = mid
    parent.things = ['a', 'b', 'c']

    hash = parent.serialize
    assert_equal(2, hash[:circles].length)
    assert_equal(3, hash[:things].length)

    h_mid = hash[:middle_circle]
    assert_equal(100, h_mid[:x])
    assert_equal(200, h_mid[:y])
    assert_nil(h_mid[:radius])
    assert_nil(h_mid[:color])

    h_c1 = hash[:circles][0]
    assert_equal(1, h_c1[:x])
    assert_equal(2, h_c1[:y])
    assert_equal(4, h_c1[:radius])
    assert_equal('blue', h_c1[:color])

    h_c2 = hash[:circles][1]
    assert_equal(10, h_c2[:x])
    assert_equal(20, h_c2[:y])
    assert_equal(40, h_c2[:radius])
    assert_equal('green', h_c2[:color])

    h_things = hash[:things]
    assert_equal('a', h_things[0])
    assert_equal('b', h_things[1])
    assert_equal('c', h_things[2])
  end

end
