# encoding: utf-8
require 'test_helper'

class OllehTest < GeocoderTestCase

  def setup
    Geocoder.configure(lookup: :olleh, olleh: {
      basic_auth: {
        user: 'OllehMapAPI0100',
        password: 'bncT89dfRT'
      }
    })
  end

  def test_use_https
    lookup = Geocoder::Lookup::Olleh.new

    # defaults to not ssl
    non_ssl_url = lookup.query_url(Geocoder::Query.new('서울특별시 강남구 삼성동 168-1'))
    assert non_ssl_url.start_with?("http://"), "should not be ssl"

    # change the config
    Geocoder.configure(lookup: :olleh, olleh: {
      basic_auth: {
        user: 'OllehMapAPI0100',
        password: 'bncT89dfRT'
      },
      use_https: true
    })

    ssl_url = lookup.query_url(Geocoder::Query.new('서울특별시 강남구 삼성동 168-1'))
    assert ssl_url.start_with?("https://"), "should be ssl"
  end

  def test_query_for_geocode
    lookup = Geocoder::Lookup::Olleh.new
    url = lookup.query_url(Geocoder::Query.new('서울특별시 강남구 삼성동 168-1'))
    assert url.include?('addr%22%3A%22%25EC%2584%259C%25EC%259A%25B8%25ED%258A%25B9%25EB%25B3%2584%25EC%258B%259C%2520%25EA%25B0%2595%25EB%2582%25A8%25EA%25B5%25AC%2520%25EC%2582%25BC%25EC%2584%25B1%25EB%258F%2599%2520168-1%22'), "Invalide address parsing"
  end

  def test_search_by_location_name
    VCR.use_cassette("geocode/samseong-dong") do
      # samseong dong - the district
      result = Geocoder.search('삼성동', provider: :olleh)
      assert_equal "서울특별시 강남구 삼성동", result.first.address
    end
  end

  def test_search_by_address
    VCR.use_cassette("geocode/samseong-dong-address") do
      # an address in samseong dong
      result = Geocoder.search('서울특별시 강남구 삼성동', provider: :olleh)
      assert_equal '서울특별시 강남구 삼성동', result.first.address
    end
  end

  def test_search_coord_by_full_address
    VCR.use_cassette("geocode/samseong-dong-full-address") do
      result = Geocoder.search("서울특별시 강남구 삼성동 168-1", provider: :olleh)
      assert_equal [961376, 1945766], result.first.coordinates
    end
  end

  def test_search_by_landmark
    VCR.use_cassette("geocode/busan-tower") do
      # busan tower
      result = Geocoder.search('부산타워', provider: :olleh)
      assert_equal [], result
    end
  end

  def test_query_for_geocode_address_code_type
    VCR.use_cassette("geocode/samseong-dong-168-1") do
      lookup = Geocoder::Lookup::Olleh.new
      query = Geocoder::Query.new('서울특별시 강남구 삼성동 168-1', {addrcdtype: 'law'})
      result = lookup.search(query).first
      assert_equal "서울특별시 강남구 삼성동 168-1", result.address
      assert_equal [961376, 1945766], result.coordinates
    end
  end

  def test_gecoding_for_seoul_and_busan
    VCR.use_cassette("geocode/check-seoul-busan-coords") do
      lookup = Geocoder::Lookup::Olleh.new
      seoul = "서울특별시 서초구 서초동 1337"
      busan = "부산광역시 동구 초량동 1187-1"
      query1 = Geocoder::Query.new(seoul, {addrcdtype: 'law'})
      query2 = Geocoder::Query.new(busan, {addrcdtype: 'law'})
      r1 = lookup.search(query1).first
      r2 = lookup.search(query2).first
      assert_equal r1.address, "서울특별시 서초구 서초동 1337-6"
      assert_equal r1.coordinates, [958369, 1943657]
      assert_equal r2.address, "부산광역시 동구 초량동 1187-1"
      assert_equal r2.coordinates, [1140600, 1681210]
    end
  end

  def test_gecode_with_options
    query = Geocoder::Query.new('삼성동', {:addrcdtype => 'law'})
    lookup = Geocoder::Lookup::Olleh.new
    url_with_params = lookup.query_url(query)
    assert url_with_params.include? '%22addrcdtype%22%3A0%2C%22'
  end

  def test_check_query_type
    VCR.use_cassette("geocode/samseong-dong-law") do
      query = Geocoder::Query.new('삼성동',{:addrcdtype => 'law'})
      lookup = Geocoder::Lookup::Olleh.new
      assert_equal 2, lookup.search(query).count
    end
  end

  def test_olleh_result_components
    VCR.use_cassette("geocode/samseong-dong-law") do
      query = Geocoder::Query.new('삼성동',{:addrcdtype => 'law'})

      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first

      assert_equal '서울특별시 강남구 삼성동', result.address
      assert_equal 'South Korea', result.country
      assert_equal '서울특별시', result.city
      assert_equal '강남구', result.gu

      assert_equal '삼성동', result.dong
      assert_equal '1168010500', result.dong_code
      assert_equal [960713, 1946274], result.coordinates
    end
  end

  def test_olleh_geocoding_no_result
    VCR.use_cassette("geocode/no-results") do
      query = Geocoder::Query.new('no results',{:addrcdtype => 'law'})
      lookup = Geocoder::Lookup::Olleh.new
      assert_equal [], lookup.search(query)
    end
  end

  def test_olleh_reverse_geocoding
    VCR.use_cassette("reverse_geocode/samseong-dong") do
      query = Geocoder::Query.new([960713, 1946274], { addrcdtype: 'law', new_addr_type: 'new', include_jibun: 'yes' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal '서울특별시 강남구 삼성동 74-14', result.address
    end
  end

  def test_converting_coordinate_utmk_to_wgs
    VCR.use_cassette("convert_coords/utmk_to_wgs84") do
      query = Geocoder::Query.new([960713, 1946274],{coord_in: 'utmk', coord_out: 'wgs84'})
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      # lat, lon
      assert_equal ["127.05543973133743", "37.51491635059331"], result.converted_coord
    end
  end

  def test_converting_coordinate_wgs_to_utmk
    # seoul tower
    VCR.use_cassette("convert_coords/wgs84_to_utmk") do
      query = Geocoder::Query.new([37.5511694, 126.9882266],{coord_in: 'wgs84', coord_out: 'utmk'})
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first

      assert_equal ["5398751.85302942", "7541125.90715467"], result.converted_coord
    end
  end

  def test_olleh_route_searching
    VCR.use_cassette("route/basic") do
      query = Geocoder::Query.new(
        '', {
        start_x: 960713,
        start_y: 1946274,
        end_x: 950000,
        end_y: 1940594,
        priority: 'shortest',
        coord_type: 'utmk'
      })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal '15712', result.total_dist
      assert_equal '43.05', result.total_time
    end

    VCR.use_cassette("route/compare_high_way_to_freeway_1") do
      query = Geocoder::Query.new(
        '', {
        start_x: 958369,
        start_y: 1943657,
        end_x: 1140600,
        end_y: 1681210,
        priority: 'high_way',
        coord_type: 'utmk'
      })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal result.total_dist, '388240'
      assert_equal result.total_time, '254.3'
    end

    VCR.use_cassette("route/compare_high_way_to_freeway_2") do
      query = Geocoder::Query.new(
        '', {
        start_x: 958369,
        start_y: 1943657,
        end_x: 1140600,
        end_y: 1681210,
        priority: 'free_way',
        coord_type: 'utmk'
      })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal result.total_dist, '410536'
      assert_equal result.total_time, '423.58'
    end
  end

  def test_multi_waypoints_with_different_order_1
    VCR.use_cassette("route/waypoints_with_different_order_1") do
      query1 = Geocoder::Query.new(
          "", {
          start_x: 957760.25,
          start_y: 1944925.0,
          end_x: 946545.625,
          end_y: 1953371.125,
          vx1: 956895.0625,
          vy1: 1942818.5,
          priority: 'high_way',
          coord_type: 'utmk'
        })
      lookup = Geocoder::Lookup::Olleh.new
      assert_equal true, lookup.query_url(query1).include?("VX1")
      result = lookup.search(query1).first
      assert_equal '23790', result.total_dist
      assert_equal '28.21', result.total_time
    end

    VCR.use_cassette("route/waypoints_with_different_order_2") do
      query2 = Geocoder::Query.new(
          "", {
          start_x: 957760.25,
          start_y: 1944925.0,
          end_x: 956895.0625,
          end_y: 1942818.5,
          vx1: 946545.625,
          vy1: 1953371.125,
          priority: 'high_way',
          coord_type: 'utmk'
        })
      lookup = Geocoder::Lookup::Olleh.new
      assert_equal true, lookup.query_url(query2).include?("VX1")
      result = lookup.search(query2).first
      assert_equal '42257', result.total_dist
      assert_equal '45.08', result.total_time
    end
  end

  def test_olleh_route_searching_with_waypoints
    VCR.use_cassette("route/waypoints") do
      query = Geocoder::Query.new(
        "", {
        start_x: 960713,
        start_y: 1946274,
        end_x: 961596,
        end_y: 1944521,
        vx1: 951285,
        vy1: 1942777,
        vx2: 957907,
        vy2: 1947861,
        vx3: 960364,
        vy3: 1941907,
        priority: 'optimal',
        coord_type: 'utmk'
      })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal true, lookup.query_url(query).include?("VX3")
      assert_equal '37662', result.total_dist
      assert_equal '108.17', result.total_time
    end
  end

  def test_olleh_km2_local_search
    VCR.use_cassette("address/km2_local_search_1") do
      query = Geocoder::Query.new('서초동 1337', { places: 70, sr: 'RANK', isaddr: 'search_address_only' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)
      assert_equal result[0].old_addr, "서울특별시 서초구 서초2동 1337"
      assert_equal result[0].new_addr, "서울특별시 서초구  사임당로 174"

      assert_equal result[1].old_addr, "서울특별시 서초구 서초동 1337"
      assert_equal result[1].new_addr, "서울특별시 서초구  사임당로 174"

      assert_equal result[2].old_addr, "서울특별시 서초구 서초2동 1337-1"
      assert_equal result[2].new_addr, "서울특별시 서초구  사임당로 174"

      assert_equal result[3].old_addr, "서울특별시 서초구 서초동 1337-1"
      assert_equal result[3].new_addr, "서울특별시 서초구  사임당로 174"

      assert_equal result[4].old_addr, "서울특별시 서초구 서초동 1337-2"
      assert_equal result[4].new_addr, "서울특별시 서초구  효령로77길 34"
    end

    VCR.use_cassette("address/km2_local_search_2") do
      query = Geocoder::Query.new('서초동 1337-1', { places: 70, sr: 'RANK', isaddr: 'search_names_too' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)
      assert_equal result.first.old_addr, "서울특별시 서초구 서초동 1337-1"
      assert_equal result.first.new_addr, "서울특별시 서초구  사임당로 174"
      assert_equal result.last.old_addr, "서울특별시 서초구 서초2동 1337-1"
      assert_equal result.last.new_addr, "서울특별시 서초구  사임당로 174"
    end

    VCR.use_cassette("address/km2_local_search_3") do
      query = Geocoder::Query.new('서초동 1337-7', { places: 5, sr: 'RANK', isaddr: 'search_names_too' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)
      assert_equal result[0].old_addr, "서울특별시 서초구 서초동 1337-7"
      assert_equal result[0].new_addr, ""
      assert_equal result[1].old_addr, "서울특별시 서초구 서초2동 1337-7"
      assert_equal result[1].new_addr, ""
    end

    VCR.use_cassette("address/km2_local_search_4") do
      query = Geocoder::Query.new('서초동 1337-16', { places: 5, sr: 'RANK', isaddr: 'search_names_too' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)
      assert_equal result[0].old_addr, "서울특별시 서초구 서초동 1337-16"
      assert_equal result[0].new_addr, ""
      assert_equal result[1].old_addr, "서울특별시 서초구 서초2동 1337-16"
      assert_equal result[1].new_addr, ""
    end

    VCR.use_cassette("address/km2_local_search_5") do
      query = Geocoder::Query.new('서초동 1337-34', { places: 5, sr: 'RANK', isaddr: 'search_names_too' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)
      assert_equal result[0].old_addr, "서울특별시 서초구 서초동 1337-34"
      assert_equal result[0].new_addr, "서울특별시 서초구  강남대로 331"
      assert_equal result[1].old_addr, "서울특별시 서초구 서초2동 1337-34"
      assert_equal result[1].new_addr, "서울특별시 서초구  강남대로 331"
    end

    VCR.use_cassette("address/km2_local_search_6") do
      query = Geocoder::Query.new('사임당로 174', { places: 100, sr: 'RANK', isaddr: 'search_address_only' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)
      assert_equal result[0].old_addr, "서울특별시 서초구 서초동 1337-1"
      assert_equal result[0].new_addr, "서울특별시 서초구 사임당로 174"
    end

    VCR.use_cassette("address/km2_local_search_7") do
      query = Geocoder::Query.new('국회대로', { places: 100, sr: 'RANK', isaddr: 'search_address_only' })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query)

      assert_equal result[0].old_addr, ""
      assert_equal result[0].new_addr, "서울특별시 양천구 국회대로"

      assert_equal result[1].old_addr, ""
      assert_equal result[1].new_addr, "서울특별시 강서구 국회대로"

      assert_equal result[2].old_addr, ""
      assert_equal result[2].new_addr, "서울특별시 영등포구 국회대로"
    end
  end

  def test_olleh_addr_step_search
    VCR.use_cassette("address/address_step_search") do
      query = Geocoder::Query.new('', {l_code: 11})
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal '서울특별시', result.addr_step_sido
      assert_equal '종로구', result.addr_step_sigungu
      assert_equal '11110', result.addr_step_l_code
      assert_equal ['954050', '1952755'], result.coordinates
      assert_equal '009000023000000', result.addr_step_p_code
    end
  end

  def test_olleh_result_wgs_coordinates
    VCR.use_cassette("address/address_step_search_plus_coordinates") do
      query = Geocoder::Query.new('', {l_code: 11})
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal ['954050', '1952755'], result.coordinates
      assert_equal ["126.97963993563258", "37.57302324409918"], result.wgs_coordinates
    end
  end

  def test_olleh_addr_nearest_position_search
    VCR.use_cassette("address/nearest_position") do
      query = Geocoder::Query.new(
        '', {
        px: 966759,
        py: 1947935,
        radius: 100
      })
      lookup = Geocoder::Lookup::Olleh.new
      result = lookup.search(query).first
      assert_equal "서울특별시 강동구 성내동 540", result.position_address
    end
  end
end
