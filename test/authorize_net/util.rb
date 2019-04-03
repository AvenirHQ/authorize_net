require 'nokogiri'
require 'authorize_net'
require 'minitest/autorun'

class TestUtil < Minitest::Test

  def test_get_xml_basic
    value = "Hello"
    xml = Nokogiri::XML.parse("<greeting>#{value}</greeting>")
    assert_equal(value, AuthorizeNet::Util.getXmlValue(xml, "greeting"))
  end

  def test_get_xml_missing_key
    xml = Nokogiri::XML.parse("<randomness>junkjunkjunk</randomness>")
    assert_nil(AuthorizeNet::Util.getXmlValue(xml, "order"))
    assert_nil(AuthorizeNet::Util.getXmlValue(xml, "peace"))
    assert_nil(AuthorizeNet::Util.getXmlValue(xml, 100))
    assert_nil(AuthorizeNet::Util.getXmlValue(xml, {:some_hash => "things"}))
  end

  def test_get_xml_non_xml
    assert_nil(AuthorizeNet::Util.getXmlValue("blankness", "something"))
    assert_nil(AuthorizeNet::Util.getXmlValue(nil, "anything"))
    assert_nil(AuthorizeNet::Util.getXmlValue(1984, "nothing"))
    assert_nil(AuthorizeNet::Util.getXmlValue({:some_hash => true}, "everything"))
  end

  def test_get_xml_multiple
    value1 = "hi"
    value2 = "bonjour"
    xml = Nokogiri::XML.parse("<greeting>#{value1}</greeting><dialogue><greeting>#{value2}</greeting></dialogue>")
    assert_equal(value1, AuthorizeNet::Util.getXmlValue(xml, "greeting"))
  end

  def test_build_xml
    hash = {
      "XML" => {
        "Life" => 42,
        "People" => [
          "Bootsy Collins",
          "Barack Obama",
          "Bill Evans",
        ],
        "Tree" => {
          "Species" => "Oak",
          "Height" => 45,
          "HeightUnit" => "Feet",
        }
      }
    }
    xml = "<XML><Life>42</Life><People>Bootsy Collins</People><People>Barack Obama</People><People>Bill Evans</People><Tree><Species>Oak</Species><Height>45</Height><HeightUnit>Feet</HeightUnit></Tree></XML>"

    assert_equal(xml, AuthorizeNet::Util.buildXmlFromObject(hash))
  end

  def test_build_xml_nonsense
    hi = Object.new
    assert_equal(hi.to_s, AuthorizeNet::Util.buildXmlFromObject(hi))
    assert_equal("", AuthorizeNet::Util.buildXmlFromObject(nil))
  end

end
