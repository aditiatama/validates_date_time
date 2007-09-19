require File.dirname(__FILE__) + '/abstract_unit'

class DateTimeTest < Test::Unit::TestCase
  def test_various_formats
    formats = {
      '2006-01-01 01:01:01' => /Jan 01 01:01:01 [\+-]?[\w ]+ 2006/,
      '2/2/06 7pm'          => /Feb 02 19:00:00 [\+-]?[\w ]+ 2006/,
      '10 AUG 04 6.23am'    => /Aug 10 06:23:00 [\+-]?[\w ]+ 2004/,
      '6 June 1981 10 10'   => /Jun 06 10:10:00 [\+-]?[\w ]+ 1981/,
      'September 01, 2007 06:10' => /Sep 01 06:10:00 [\+-]?[\w ]+ 2007/
    }
    
    formats.each do |value, result|
      assert_update_and_match result, :date_and_time_of_birth => value
    end
    
    with_us_date_format do
      formats.each do |value, result|
        assert_update_and_match result, :date_and_time_of_birth => value
      end
    end
  end
  
  def test_invalid_formats
    ['29 Feb 06 1am', '1 Jan 06', '7pm'].each do |value|
      assert_invalid_and_errors_match /date time/, :date_and_time_of_birth => value
    end
  end
  
  def test_before_and_after_restrictions_parsed_as_date_times    
    assert_invalid_and_errors_match /before/, :date_and_time_of_birth => '2008-01-02 00:00:00'
    assert p.update_attributes!(:date_and_time_of_birth => '2008-01-01 01:01:00')
    
    assert_invalid_and_errors_match /after/, :date_and_time_of_birth => '1981-01-01 01:00am'
    assert p.update_attributes!(:date_and_time_of_birth => '1981-01-01 01:02am')
  end
  
  def test_multi_parameter_attribute_assignment_with_valid_date_time
    assert_nothing_raised do
      assert p.update_attributes('time_of_birth(1i)' => '2006', 'time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '20',
        'time_of_birth(4i)' => '23', 'time_of_birth(5i)' => '10', 'time_of_birth(6i)' => '40')
    end
    
    assert_equal Time.local(2000, 1, 1, 23, 10, 40), p.time_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_invalid_date_time
    assert_nothing_raised do
      assert !p.update_attributes('time_of_birth(1i)' => '2006', 'time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '10',
        'time_of_birth(4i)' => '30', 'time_of_birth(5i)' => '88', 'time_of_birth(6i)' => '100')
    end
    
    assert p.errors[:time_of_birth]
  end
  
  def test_incomplete_multi_parameter_attribute_assignment
    assert_nothing_raised do
      assert !p.update_attributes('time_of_birth(1i)' => '2006', 'time_of_birth(2i)' => '1')
    end
    
    assert p.errors[:time_of_birth]
  end
end
