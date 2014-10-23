require 'spec_helper'

describe LivePaper::Trigger do
  before do
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
    stub_request(:post, LivePaper::Trigger.api_url).to_return(:body => lpp_trigger_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::Trigger::DOWNLOAD_URL}/id/image").to_return(:body => lpp_watermark_response, :status => 200)
    stub_request(:get, "#{LivePaper::Trigger.api_url}/trigger_id").to_return(:body => lpp_trigger_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::Trigger.api_url}/trigger_not_existent").to_return(:body => '{}', :status => 404)

    @data = {
      id: 'id',
      name: 'name',
      watermark: {strength: 10, imageURL: 'url'},
      subscription: 'subscription'
    }
  end

  describe '#initialize' do
    before do
      @trigger = LivePaper::Trigger.new @data
    end

    it 'should map the watermark attribute.' do
      @trigger.watermark.should == @data[:watermark]
    end

    it 'should map the subscription attribute.' do
      @trigger.subscription.should == @data[:subscription]
    end
  end

  describe '#save' do
    context 'when all needed attributes are provided,' do
      before do
        @data.delete :id
        @trigger = LivePaper::Trigger.new @data
      end

      it 'should make a POST to the trigger URL with body.' do
        @trigger.save
        assert_requested :post, LivePaper::Trigger.api_url, :body => {
          trigger: {
            name: 'name',
            watermark: {
              outputImageFormat: 'JPEG',
              resolution: 75,
              strength: 10,
              imageURL: 'url'
            },
            subscription: {package: 'month'}
          }
        }.to_json
      end
    end

    context 'when we do not have all needed data,' do
      it 'should raise exception if the name is no provided.' do
        @data.delete :name
        trigger = LivePaper::Trigger.new @data
        expect { trigger.save }.to raise_error
      end

      it 'should raise exception if the watermark is no provided.' do
        @data.delete :watermark
        trigger = LivePaper::Trigger.new @data
        expect { trigger.save }.to raise_error
      end
    end
  end

  describe '#parse' do
    before do
      @trigger = LivePaper::Trigger.parse(lpp_trigger_response_json)
    end

    it 'should return a Trigger object.' do
      @trigger.should be_a LivePaper::Trigger
    end

    it 'should map the id attribute.' do
      @trigger.id.should == 'trigger_id'
    end
    it 'should map the name attribute.' do
      @trigger.name.should == 'name'
    end

    it 'should map the watermark attribute.' do
      @trigger.watermark.should == 'watermark'
    end

    it 'should map the subscription attribute.' do
      @trigger.subscription.should == 'subscription'
    end
  end

  describe '.find' do
    context 'the requested trigger exists.' do
      before do
        @trigger = LivePaper::Trigger.find('trigger_id')
      end

      it 'should return the requested trigger.' do
        @trigger.id.should == 'trigger_id'
        @trigger.name.should == 'name'
        @trigger.watermark.should == 'watermark'
        @trigger.subscription.should == 'subscription'
      end
    end

    context 'the requested trigger does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::Trigger.find('trigger_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        LivePaper::Trigger.find('trigger_not_existent').should be_nil
      end
    end
  end

  describe '#download_watermark' do
    before do
      @trigger = LivePaper::Trigger.new @data
    end

    it 'should return the watermark image data.' do
      @trigger.download_watermark.should == 'watermark_data'
    end
  end
end