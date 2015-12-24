require 'geocoder/lookups/base'
require "geocoder/results/olleh"
require 'base64'
require 'uri'
require 'json'
module Geocoder::Lookup
  ##
  # Route Search
  # shortest : ignore traffic. shortest path
  # high way : include high way
  # free way : no charge
  # optimal  : based on traffic
  class Olleh < Base


    PRIORITY = {
      'shortest' => 0, # 최단거리 우선
      'high_way' => 1, # 고속도로 우선
      'free_way' => 2, # 무료도로 우선
      'optimal'  => 3  # 최적경로
    }

    ADDR_CD_TYPES = {
      'law'            => 0, # 법정동
      'administration' => 1, # 행정동
      'law_and_admin'  => 2,
      'road'           => 3
    }

    NEW_ADDR_TYPES = {
      'old'     => 0,
      'new'     => 1
    }

    INCLUDE_JIBUN = {
      'no'      => 0,
      'yes'     => 1
    }

    COORD_TYPES = {
      'utmk'    => 0,
      'tm_west' => 1,
      'tm_mid'  => 2,
      'tm_east' => 3,
      'katec'   => 4,
      'utm52'   => 5,
      'utm51'   => 6,
      'wgs84'   => 7,
      'bessel'  => 8
    }

    ROUTE_COORD_TYPES = {
      'geographic'=> 0,
      'tm_west'   => 1,
      'tm_mid'    => 2,
      'tm_east'   => 3,
      'katec'     => 4,
      'utm52'     => 5,
      'utm51'     => 6,
      'utmk'      => 7
    }

    NEW_ADDR_SEARCH_OPTIONS = {
      'search_names_too' => 0,
      'search_address_only' => 1
    }

    def use_ssl?
      true
    end

    def name
      "Olleh"
    end

    def query_url(query)
      base_url(query) + url_query_string(query)
    end

    def self.new_addr_search_options
      NEW_ADDR_SEARCH_OPTIONS
    end

    def self.priority
      PRIORITY
    end

    def self.addrcdtype
      ADDR_CD_TYPES
    end

    def self.new_addr_types
      NEW_ADDR_TYPES
    end

    def self.include_jibun
      INCLUDE_JIBUN
    end

    def self.coord_types
      COORD_TYPES
    end

    def self.route_coord_types
      ROUTE_COORD_TYPES
    end

    def auth_key
      token
    end

    def self.check_query_type(query)

      options = query.options
      return options[:query_type] if options[:query_type]

      query_type = case
      when options.include?(:priority)
        'route_search'
      when query.reverse_geocode? && options.include?(:include_jibun)
        'reverse_geocoding'
      when options.include?(:coord_in)
        'convert_coord'
      when options.include?(:l_code)
        'addr_step_search'
      when options.include?(:places)
        'addr_local_search'
      when options.include?(:radius)
        'addr_nearest_position_search'
      else
        'geocoding'
      end

      options[:query_type] = query_type
    end

    private # ----------------------------------------------

    # results goes through structure and check returned hash.
    def results(query)
      data = fetch_data(query)
      return [] unless data
      return [] if blank?(data["payload"])
      return [] if data["error"]
      doc = JSON.parse(URI.decode(data["payload"]))
      if doc['ERRCD'] != nil && doc['ERRCD'] != 0
        Geocoder.log(:warn, "Olleh API error: #{doc['ERRCD']} (#{doc['ERRMS'] if doc['ERRMS']}).")
        return []
      end

      case Olleh.check_query_type(query)
      when 'addr_local_search'
        result = local_search_result(doc["RESULTDATA"])
        return [] if  result.nil? || result.size == 0
        return result
      when 'geocoding'
        return [] if doc['RESDATA']['COUNT'] == 0
        return doc['RESDATA']['ADDRS']
      when 'reverse_geocoding'
        return [] if doc['RESDATA']['COUNT'] == 0
        return doc['RESDATA']['ADDRS'] || []
      when 'route_search'
        return [] if doc['RESDATA']['SROUTE']['isRoute'] == 'false'
        return doc['RESDATA'] || []
      when 'convert_coord'
        return doc['RESDATA'] || []
      when 'addr_step_search'
        return doc['RESULTDATA'] || []
      when 'addr_nearest_position_search'
        return doc['RESULTDATA'] || []
      else
        []
      end
    end

    def local_search_result(result_data)
      if result_data["addr"] && !blank?(result_data["addr"]["Data"])
        result_data["addr"]["Data"]
      elsif result_data["New_addrs"] && !blank?(result_data["New_addrs"]["Data"])
        result_data["New_addrs"]["Data"]
      elsif result_data["place"] && !blank?(result_data["place"]["Data"])
        result_data["place"]["Data"]
      else
        nil
      end
    end

    def blank?(obj)
      obj.nil? || obj.empty?
    end

    def base_url(query)
      case Olleh.check_query_type(query)
      when "addr_local_search"
        "https://openapi.kt.com/maps/search/km2_LocalSearch?params="
      when "route_search"
        "https://openapi.kt.com/maps/etc/RouteSearch?params="
      when "reverse_geocoding"
        "https://openapi.kt.com/maps/geocode/GetAddrByGeocode?params="
      when "convert_coord"
        "https://openapi.kt.com/maps/etc/ConvertCoord?params="
      when "addr_step_search"
        "https://openapi.kt.com/maps/search/AddrStepSearch?params="
      when "addr_nearest_position_search"
        "https://openapi.kt.com/maps/search/AddrNearestPosSearch?params="
      else #geocoding
        "https://openapi.kt.com/maps/geocode/GetGeocodeByAddr?params="
      end
    end

    def query_url_params(query)
      case Olleh.check_query_type(query)
      when "addr_local_search"
        # option 2 is for sorting based on location of user.
        # we are using default. "1"
        #
        # we can add UTMK X, Y coordinates for that.
        # but i am not using it. it's optional.
        # isarea = 1 should be used in this case.
        # r is for setting radius. (300, 500, 1000, 2000, 40000)
        #
        # places is for number of results. 100 is the maximum.
        #
        # sr is for
        # isaddr for searching address only. excluding building name, etc.
        # s: "AN" means it will return old / new style addresses.
        #
        hash = {
          query: URI.encode(query.text),
          option: "1",
          s: "AN",
          places: query.options[:places],
          sr: query.options[:sr],
          isaddr: Olleh.new_addr_search_options[query.options[:isaddr]] || "1"
        }
      when "route_search"
        hash = {
          SX: query.options[:start_x],
          SY: query.options[:start_y],
          EX: query.options[:end_x],
          EY: query.options[:end_y],
          RPTYPE: 0,
          COORDTYPE: Olleh.route_coord_types[query.options[:coord_type]] || 7,
          PRIORITY: Olleh.priority[query.options[:priority]]
        }
        (1..3).each do |x|
          s = [query.options[:"vx#{x}"], query.options[:"vy#{x}"]]
          hash.merge!({ "VX#{x}" => s[0], "VY#{x}" => s[1]}) unless s[0].nil? && s[1].nil?
        end
      when "convert_coord"
        hash = {
          x: query.text.first,
          y: query.text.last,
          inCoordType: Olleh.coord_types[query.options[:coord_in]],
          outCoordType: Olleh.coord_types[query.options[:coord_out]]
       }
      when "reverse_geocoding"
        hash = {
          x: query.text.first,
          y: query.text.last,
          addrcdtype: Olleh.addrcdtype[query.options[:addrcdtype]] || 0,
          newAddr: Olleh.new_addr_types[query.options[:new_addr_type]] || 0,
          isJibun: Olleh.include_jibun[query.options[:include_jibun]] || 0
       }
      when "addr_step_search"
        hash = {
          l_Code: query.options[:l_code]
        }
      when "addr_nearest_position_search"
        hash = {
          px: query.options[:px],
          py: query.options[:py],
          radius: query.options[:radius]
        }
      else # geocoding
        hash = {
          addr: URI.encode(query.sanitized_text),
          addrcdtype: Olleh.addrcdtype[query.options[:addrcdtype]]
        }
      end

      hash.merge!(timestamp: now)
      JSON.generate(hash)
    end

    def now
      Time.now.strftime("%Y%m%d%H%M%S%L")
    end

    def url_query_string(query)
      URI.encode(
        query_url_params(query)
      ).gsub(':','%3A').gsub(',','%2C').gsub('https%3A', 'https:')
    end

    ##
    # Need to delete timestamp from cache_key to hit cache
    #
    def cache_key(query)
      Geocoder.config[:cache_prefix] + query_url(query).split('timestamp')[0]
    end
  end
end
