require 'geocoder/results/base'

module Geocoder::Result
  class Olleh < Base

    def latitude
      coordinates[0].to_f
    end

    def longitude
      coordinates[1].to_f
    end

    def address
      @data['ADDRESS'].gsub('+', ' ')
    end

    def city
      @data['ADDRESS'].split('+').first
    end

    def gu
      @data['ADDRESS'].split('+')[1]
    end

    def dong
      @data['ADDRESS'].split('+')[2]
    end

    def dong_code
      @data['DONG_CODE']
    end

    alias_method :region, :country

    def state_code
      ""
    end

    alias_method :state, :state_code

    def country
      "South Korea"
    end

    alias_method :country_code, :country

    def postal_code
      ""
    end

    def coordinates
      [@data['X'], @data['Y']]
    end

    #########
    # methods for returning wgs coordiates from
    #
    def wgs_coordinates
      return @data["WGS_COORDINATES"] if @data["WGS_COORDINATES"]
      query = Geocoder::Query.new(
        coordinates, {
        coord_in: 'utmk',
        coord_out: 'wgs84'
      })
      lookup = Geocoder::Lookup::Olleh.new
      wgs = lookup.search(query).first.converted_coord
      @data["WGS_COORDINATES"] = wgs
      wgs
    end

    def address_data
      @data['ADDRESS']
    end

    def self.response_attributes
      %w[bbox name confidence entityType]
    end

    ##
    # methods for converting coord system
    #
    def coord_type
      @data[1]['COORDTYPE']
    end

    def converted_coord
      [@data[1]["X"], @data[1]["Y"]]
    end

    ##
    # methods for route search results
    # total_time : minutes
    # total_dist : meter
    #
    def total_time
      @data[1]['ROUTE']['total_time']
    end

    def total_dist
      @data[1]['ROUTE']['total_dist']
    end

    def rg_count
      @data[1]['ROUTE']['rg_count']
    end

    def rg_links
      @data[1]['ROUTE']['rg']
    end

    ##
    # methods for parsing address step search
    #
    # 법정동 - 시도
    def addr_step_sido
      @data["SIDO"]
    end

    ##
    # 법정동 - 시군구
    def addr_step_sigungu
      sanitize_addr(@data["SIGUNGU"])
    end

    def addr_step_dong
      @data["DONG"]
    end

    def addr_step_li
      @data["LI"]
    end
    ##
    # 법정동코드
    def addr_step_l_code
      @data["L_CODE"]
    end
    ##
    # 행정동코드
    def addr_step_h_code
      @data["H_CODE"]
    end
    ##
    # 파란코드
    def addr_step_p_code
      @data["P_CODE"]
    end

    ##
    # methods for parsing nearest position search
    #
    def position_address
      "#{@data['SIDO']} #{@data['L_SIGUN_GU']} #{@data['L_DONG']} #{@data['GIBUN']}"
    end

    ##
    # addr used when we call km2_LocalSearch
    # using old address system
    def old_addr
      if @data["ADDR"]
        sanitize_addr(@data["ADDR"])
      elsif @data["ADDRESS"]
        sanitize_addr(@data["ADDRESS"])
      elsif @data["M_ADDR1"]
        sanitize_addr(@data["M_ADDR1"]) + " " + sanitize_addr(@data["M_ADDR2"])
      else
        ""
      end
    end

    ##
    # addr used when we call km2_LocalSearch
    # using new address system
    def new_addr
      if @data["NEW_ADDR"]
        sanitize_addr(@data["NEW_ADDR"])
      elsif @data["M_NEWADDR1"] && @data["M_NEWADDR2"]
        sanitize_addr(@data["M_NEWADDR1"]) + " " + sanitize_addr(@data["M_NEWADDR2"])
      else
        ""
      end
    end

    ##
    # NAME used when we call km2_LocalSearch
    def name
      @data["NAME"]
    end

    ##
    # UTMK X coordinate used when we call km2_LocalSearch
    def x
      @data["X"]
    end

    ##
    # UTMK Y coordinate used when we call km2_LocalSearch
    def y
      @data["Y"]
    end

    def sanitize_addr(text)
      return unless text
      text.gsub("++", " ").gsub("+", " ")
    end

    response_attributes.each do |a|
      define_method a do
        @data[a]
      end
    end
  end
end
