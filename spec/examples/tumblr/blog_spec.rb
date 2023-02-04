require 'spec_helper'

describe Tumblr::Blog do
  let(:blog_name) { 'seejohnrun.tumblr.com' }
  let(:post_id) { 45_693_025 }
  let(:other_blog_name) { 'staff' }
  let(:consumer_key) { 'ckey' }
  let(:client) do
    Tumblr::Client.new(consumer_key: consumer_key)
  end

  describe '.blog_info' do
    it 'makes a request to v2/blog/seejohnrun.tumblr.com/info' do
      expect(client)
        .to receive(:get)
        .once
        .with('v2/blog/seejohnrun.tumblr.com/info', { api_key: consumer_key })
        .and_return 'response'

      r = client.blog_info blog_name
      expect(r).to eq('response')
    end

    it 'can handle a short blog name' do
      expect(client)
        .to receive(:get)
        .once
        .with('v2/blog/b.tumblr.com/info', { api_key: consumer_key })
        .and_return 'response'

      r = client.blog_info 'b'
      expect(r).to eq('response')
    end
  end

  describe '.avatar' do
    context 'when supplying a size' do
      before do
        allow(client)
          .to receive(:get_redirect_url)
          .once
          .with("v2/blog/#{blog_name}/avatar/128")
          .and_return('url')
      end

      it 'constructs a request to 2/blog/{blog_name}/avatar/128' do
        r = client.avatar blog_name, 128

        expect(client)
          .to have_received(:get_redirect_url)
          .exactly(:once)
          .with("v2/blog/#{blog_name}/avatar/128")

        expect(r).to eq('url')
      end
    end

    context 'when no size is specified' do
      before do
        allow(client)
          .to receive(:get_redirect_url)
          .once
          .with("v2/blog/#{blog_name}/avatar")
          .and_return('url')
      end

      it 'constructs a request to v2/blog/{blog_name}/avatar' do
        r = client.avatar blog_name

        expect(client)
          .to have_received(:get_redirect_url)
          .exactly(:once)
          .with("v2/blog/#{blog_name}/avatar")

        expect(r).to eq('url')
      end
    end
  end

  describe '.followers' do
    context 'with invalid parameters' do
      it 'raises an error' do
        expect { client.followers blog_name, not: 'an option' }.to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:get)
          .once
          .with("v2/blog/#{blog_name}/followers", { limit: 1 })
          .and_return('response')
      end

      it 'constructs a request to v2/blog/{blog_name}/followers' do
        r = client.followers blog_name, limit: 1

        expect(client)
          .to have_received(:get)
          .exactly(:once)
          .with("v2/blog/#{blog_name}/followers", { limit: 1 })

        expect(r).to eq('response')
      end
    end
  end

  describe '.blog_following' do
    context 'with invalid parameters' do
      it 'raises an ArgumentError' do
        expect { client.blog_following blog_name, not: 'an option' }.to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:get)
          .once
          .with("v2/blog/#{blog_name}/following", { limit: 1 })
          .and_return('response')
      end

      it 'constructs a request to v2/blog/{blog_name}/following' do
        r = client.blog_following(blog_name, { limit: 1 })

        expect(client)
          .to have_received(:get)
          .once
          .with("v2/blog/#{blog_name}/following", limit: 1)

        expect(r).to eq 'response'
      end
    end
  end

  describe '.followed_by' do
    context 'with invalid parameters' do
      it 'raises an ArgumentError' do
        expect { client.followed_by blog_name, other_blog_name, { not: 'an option' } }
          .to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:get)
          .once
          .with("v2/blog/#{blog_name}/followed_by", { query: other_blog_name })
          .and_return('response')
      end

      it 'should construct the request properly' do
        r = client.followed_by blog_name, other_blog_name

        expect(client)
          .to have_received(:get)
          .exactly(:once)
          .with("v2/blog/#{blog_name}/followed_by", { query: other_blog_name })

        expect(r).to eq 'response'
      end
    end
  end

  describe :blog_likes do

    context 'with invalid parameters' do

      it 'should raise an error' do
        expect(lambda {
          client.blog_likes blog_name, :not => 'an option'
        }).to raise_error ArgumentError
      end

    end

    context 'with valid parameters' do

      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/likes", {
          :limit => 1,
          :api_key => consumer_key
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.blog_likes blog_name, :limit => 1
        expect(r).to eq('response')
      end
    end
  end

  describe '.posts' do
    context 'without a type supplied' do
      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts", {
          :limit => 1,
          :api_key => consumer_key
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.posts blog_name, :limit => 1
        expect(r).to eq('response')
      end
    end

    context 'when supplying a type' do
      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts/audio", {
          :limit => 1,
          :api_key => consumer_key,
          :type => 'audio'
        }).and_return('response')
      end

      it 'should construct the request properly' do
        r = client.posts blog_name, :limit => 1, :type => 'audio'
        expect(r).to eq('response')
      end

    end

  end

  describe :get_post do
    context 'with invalid parameters' do
      it 'should raise an error' do
        expect(lambda {
          client.get_post blog_name, post_id, not: 'an option'
        }).to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts/#{post_id}", {}).and_return('response')
      end
      it 'should construct the request properly' do
        r = client.get_post blog_name, post_id
        expect(r).to eq('response')
      end
    end
  end # describe :get_post

  describe :notes do
    context 'with invalid parameters' do
      it 'should raise an error' do
        expect(lambda {
          client.notes blog_name, post_id, not: 'an option'
        }).to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:get)
          .once
          .with("v2/blog/#{blog_name}/notes", { id: post_id })
          .and_return('response')
      end

      it 'makes a request to v2/blog/{blog_name}/notes' do
        r = client.notes blog_name, post_id

        expect(client)
          .to have_received(:get)
          .exactly(:once)
          .with("v2/blog/#{blog_name}/notes", { id: post_id })

        expect(r).to eq('response')
      end
    end
  end

  # These are all just lists of posts with pagination
  [:queue, :draft, :submissions].each do |type|

    ext = type == :submissions ? 'submission' : type.to_s # annoying

    describe type do

      context 'when using parameters other than limit & offset' do

        it 'should raise an error' do
          expect(lambda {
            client.send type, blog_name, :not => 'an option'
          }).to raise_error ArgumentError
        end

      end

      context 'with valid options' do

        it 'should construct the call properly' do
          limit = 5
          expect(client).to receive(:get).once.with("v2/blog/#{blog_name}/posts/#{ext}", {
            :limit => limit
          }).and_return('response')
          r = client.send type, blog_name, :limit => limit
          expect(r).to eq('response')
        end

      end

    end

  end # [:queue, :draft, :submissions].each

  describe :reorder_queue do
    context 'with invalid parameters' do
      it 'should raise an error' do
        expect(lambda {
          client.reorder_queue blog_name, not: 'an option'
        }).to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:post)
          .once
          .with("v2/blog/#{blog_name}/posts/queue/reorder", { post_id: 1, insert_after: 2 })
          .and_return('response')
      end

      it 'makes a call to v2/blog/#blog_name}/posts/queue/reorder' do
        r = client.reorder_queue blog_name, post_id: 1, insert_after: 2

        expect(client)
          .to have_received(:post)
          .once
          .with("v2/blog/#{blog_name}/posts/queue/reorder", { post_id: 1, insert_after: 2 })

        expect(r).to eq('response')
      end
    end
  end

  describe '.shuffle_queue' do
    it 'should construct the request properly' do
      expect(client).to receive(:post).once.with("v2/blog/#{blog_name}/posts/queue/shuffle").and_return('response')
      r = client.shuffle_queue blog_name
      expect(r).to eq('response')
    end
  end # describe :shuffle_queue

  describe :notifications do
    context 'with invalid parameters' do
      it 'should raise an error' do
        expect(lambda {
          client.notifications blog_name, not: 'an option'
        }).to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      it 'makes a GET requst to v2/blog/seejohnrun/notifications' do
        timestamp = Time.now.to_i

        expect(client)
          .to receive(:get)
          .once
          .with("v2/blog/#{blog_name}/notifications", { before: timestamp })
          .and_return('response')

        r = client.notifications blog_name, before: timestamp
        expect(r).to eq('response')
      end
    end
  end

  describe '.blocks' do
    context 'with invalid parameters' do
      it 'raises an AegumentError' do
        expect { client.blocks blog_name, not: 'an option' }.to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:get)
          .once
          .with("v2/blog/#{blog_name}/blocks", { limit: 1 })
          .and_return('response')
      end

      it 'makes a GET request to v2/blog/seejohnrun.tumblr.com/blocks' do
        r = client.blocks blog_name, limit: 1

        expect(client)
          .to have_received(:get)
          .once
          .with('v2/blog/seejohnrun.tumblr.com/blocks', { limit: 1 })

        expect(r).to eq('response')
      end
    end
  end # describe :blocks

  describe :block do
    context 'with invalid parameters' do
      it 'should raise an error' do
        expect(lambda {
          client.block blog_name, other_blog_name, not: 'an option'
        }).to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:post)
          .once
          .with('v2/blog/seejohnrun.tumblr.com/blocks', { blocked_tumblelog: other_blog_name })
          .and_return('response')
      end

      it 'makes a POST request to v2/blog/seejohnrun.tumblr.com/blocks' do
        r = client.block blog_name, other_blog_name

        expect(client)
          .to have_received(:post)
          .exactly(:once)
          .with('v2/blog/seejohnrun.tumblr.com/blocks', { blocked_tumblelog: other_blog_name })

        expect(r).to eq('response')
      end
    end
  end # describe :block

  describe :unblock do
    context 'with invalid parameters' do
      it 'should raise an error' do
        expect(lambda {
          client.unblock blog_name, other_blog_name, not: 'an option'
        }).to raise_error ArgumentError
      end
    end

    context 'with valid parameters' do
      before do
        allow(client)
          .to receive(:delete)
          .once
          .with("v2/blog/#{blog_name}/blocks", { blocked_tumblelog: other_blog_name })
          .and_return('response')
      end
      it 'should construct the request properly' do
        r = client.unblock blog_name, other_blog_name
        expect(r).to eq('response')
      end
    end
  end

end