require 'spec_helper'

describe GreenOnion::Compare do

  describe 'Comparing Screenshots' do

    before(:each) do
      @configuration = GreenOnion::Configuration.new
      @comparison = GreenOnion::Compare.new(@configuration)
      @spec_shot1 = './spec/skins/spec_shot.png'
      @spec_shot2 = './spec/skins/spec_shot_fresh.png'
      @spec_shot_resize = './spec/skins/spec_shot_resize.png'
      @diff_shot = './spec/skins/spec_shot_diff.png'
    end

    after(:all) do
      FileUtils.rm('./spec/skins/spec_shot_diff.png', :force => true)
    end

    it 'should get a percentage of difference between two shots' do
      @comparison.percentage_diff(@spec_shot1, @spec_shot2)
      @comparison.percentage_changed.should eq(66.0)
    end

    it 'should create a new file with a visual diff between two shots' do
      @comparison.visual_diff(@spec_shot1, @spec_shot2)
      File.exist?(@diff_shot).should be_true
    end

    it 'should not throw error when dimensions are off' do
      expect { @comparison.visual_diff(@spec_shot1, @spec_shot_resize) }.to_not raise_error
    end

    it 'should raise error when dimensions are off if fail_on_different_dimensions is set' do
      @configuration.fail_on_different_dimensions = true
      expect { @comparison.visual_diff(@spec_shot1, @spec_shot_resize) }.to raise_error
    end
  end
end
