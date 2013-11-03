require 'open-uri'
require 'nokogiri'

DEFAULT_MAX_TITLE_LENGTH = 20
DEFAULT_MAX_DESCRIPTION_LENGTH = 45
DEFAULT_MAX_VIDEO_LINE_LENGTH = 6

class Videos2Controller < ApplicationController
  def index
    vimeo_channels = Array['staffpicks']

    @videos_array = []
    vimeo_channels.each do |channel|
      uri = URI("http://vimeo.com/api/v2/channel/#{channel}/videos.xml");
      xml = Nokogiri::XML(uri.read)
      videos_doc = xml.root()

      video_infos = []
      video_elements = videos_doc.xpath('video')
      video_elements.each_with_index do |video_element, i|

        video_info = {
          title: substring(video_element.xpath('title').text, DEFAULT_MAX_TITLE_LENGTH),
          url: video_element.xpath('url').text,
          image: video_element.xpath('thumbnail_medium').text,
          description: substring(video_element.xpath('description').text, DEFAULT_MAX_DESCRIPTION_LENGTH),
          upload_date: video_element.xpath('upload_date').text
        }

        video_infos << video_info

        tmp_index = i + 1
        if tmp_index.modulo(DEFAULT_MAX_VIDEO_LINE_LENGTH) == 0
          @videos_array << video_infos
          video_infos = []
        end
      end
    end
  end

  private

  def substring(text, max_length)
    if text.length > max_length
      text[0..max_length] + '...'
    else
      text
    end
  end

end
