require "oily_png"
require "rainbow"

module GreenOnion
  class Compare

    attr_accessor :percentage_changed, :total_px, :changed_px
    attr_reader :diffed_image

    def initialize(configuration)
      @configuration = configuration
    end

    # Pulled from Jeff Kreeftmeijer's post here: http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
    # Thanks Jeff!
    def diff_images(org, fresh)
      @images = [
        ChunkyPNG::Image.from_file(org),
        ChunkyPNG::Image.from_file(fresh)
      ]

      @diff_index = []
      begin
        diff_iterator
      rescue ChunkyPNG::OutOfBounds
        message = "Skins are different sizes. Please delete #{org} and/or #{fresh}."

        if @configuration.fail_on_different_dimensions?
          raise message
        else
          warn message.color(:yellow)
        end
      end
    end

    # Run through all of the pixels on both org image, and fresh image. Change the pixel color accordingly.
    def diff_iterator
      @images.first.height.times do |y|
        @images.first.row(y).each_with_index do |pixel, x|
          unless pixel == @images.last[x,y]
            @diff_index << [x,y]
            pixel_difference_filter(pixel, x, y)
          end
        end
      end
    end

    # Changes the pixel color to be the opposite RGB value
    def pixel_difference_filter(pixel, x, y)
      chans = []
      [:r, :b, :g].each do |chan|
        chans << channel_difference(chan, pixel, x, y)
      end
      @images.last[x,y] = ChunkyPNG::Color.rgb(chans[0], chans[1], chans[2])
    end

    # Interface to run the R, G, B methods on ChunkyPNG
    def channel_difference(chan, pixel, x, y)
      ChunkyPNG::Color.send(chan, pixel) + ChunkyPNG::Color.send(chan, @images.last[x,y]) - 2 * [ChunkyPNG::Color.send(chan, pixel), ChunkyPNG::Color.send(chan, @images.last[x,y])].min
    end

    # Returns the numeric results of the diff of 2 images
    def percentage_diff(org, fresh)
      diff_images(org, fresh)
      @total_px = @images.first.pixels.length
      @changed_px = @diff_index.length
      @percentage_changed = ( (@diff_index.length.to_f / @images.first.pixels.length) * 100 ).round(2)
    end

    # Returns the visual results of the diff of 2 images
    def visual_diff(org, fresh)
      diff_images(org, fresh)
      save_visual_diff(org, fresh)
    end

    # Saves the visual diff as a separate file
    def save_visual_diff(org, fresh)
      x, y = @diff_index.map{ |xy| xy[0] }, @diff_index.map{ |xy| xy[1] }
      @diffed_image = org.insert(-5, '_diff')

      begin
        @images.last.rect(x.min, y.min, x.max, y.max, ChunkyPNG::Color.rgb(0,255,0))
      rescue NoMethodError
        puts "Both skins are the same.".color(:yellow)
      end

      @images.last.save(@diffed_image)
    end

  end
end
